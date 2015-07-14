FUNCTION mcmc_swap_sim, _EXTRA=global_params


;+
;
; Makes/adds to one MCMC chain. To be called in parallel so multiple
; chains can be made at once with tempering (I'm swapping
; parameter states).
;
;-


COMPILE_OPT HIDDEN
!EXCEPT = 0

IF (global_params.BETA EQ 0) THEN MESSAGE,'Beta keyword is not set ' + $
                                          'within the global structure. '+$
                                          'This is manditory to set '+$
                                          'the "temperature".'
IF global_params.integral_resolution LE 0 THEN $
   global_params.integral_resolution=7e3
IF NOT keyword_set(global_params.N_Swap) THEN $
   MESSAGE, 'You need to set the N_swap keyword within the global structure.'
IF NOT keyword_set(global_params.fluxbins) THEN $
   MESSAGE, 'Fluxbins are undefined.'
IF NOT keyword_set(global_params.kvals) THEN $
   MESSAGE, 'k values are undefined.'


;;- INITIALIZE
fluxbins = ((global_params).fluxbins)[0:(global_params.NBINS-1)]
kvals = ((global_params).kvals)[0:(global_params.NBINS-1)]
N_swap = global_params.N_swap
gchain  = fltarr(N_swap)
schain  = fltarr(N_swap)
sxchain = fltarr(N_swap)
nchain  = fltarr(N_swap)


FOR t = 0L, N_swap - 1 DO BEGIN
   
   CHECK_SMIN = 0L ;Smin prior

   ;;- PARAMETER SAMPLING
   IF (t EQ 0) AND (global_params.global_count GT 0) THEN BEGIN         
      oldG  = global_params.alpha     ;; need old values to continue 
      oldS  = global_params.Smin      ;; the chain where it left
      oldSx = global_params.Smax      ;; off before the last swap.
      oldN  = global_params.Norm
      oldP  = global_params.oldP
   ENDIF
   
   IF (t EQ 0) AND (global_params.global_count EQ 0) THEN BEGIN
      newG  = global_params.alpha  ;; if it's the first global loop, 
                                   ;; calculate probabilites
      newS  = global_params.Smin   ;; with what's in the structure -- 
                                   ;; i.e. the init vals.
      newSx = global_params.Smax
      newN  = global_params.norm
      oldG = 0 & oldS = 0 & oldSx = 0 & oldN = 0
   ENDIF ELSE BEGIN
      ;; standard resampling for t > 0.
      newG  = ( randomn(seed) * global_params.adaptA  ) + oldG   
      newS  = ( randomn(seed) * global_params.adaptS  ) + oldS  
      newSx = ( randomn(seed) * global_params.adaptSx ) + oldSx
      newN  = ( randomn(seed) * global_params.adaptN  ) + oldN
   ENDELSE
   

   ;;- PRIOR CONSTRAINTS
   ccct = 0L
   WHILE (CHECK_SMIN EQ 0L) DO BEGIN  ;Smin prior depends on all variables.
      WHILE (newG LT global_params.prior_minalpha) OR $
         (newG GT global_params.prior_maxalpha) DO $
            newG  = ( randomn(seed) * global_params.adaptA  ) + oldG
      
      WHILE (newS LT global_params.prior_minSmin) OR $
         (newS GT global_params.prior_maxSmin) DO $
            newS  = ( randomn(seed) * global_params.adaptS  ) + oldS
      
      WHILE (newSx LT global_params.prior_minSx) OR $
         (newSx GT global_params.prior_maxSx) DO $
            newSx = ( randomn(seed) * global_params.adaptSx ) + oldSx
      
      WHILE (newN LT global_params.prior_minNorm) OR $
         (newN GT global_params.prior_maxNorm) DO $
            newN  = ( randomn(seed) * global_params.adaptN ) + oldN         

      ;CHECK_SMIN = check_smin_prior(newS, newSx, newN, newG,$
      ;                              _EXTRA=global_params)
      check_smin=1L
      ccct +=1
      if ccct gt 50 then message, 'Stuck at CHECK_SMIN...'
   ENDWHILE


   ;;-----------------------------------------------------
   ;;- Make SIMULATED DISTRIBUTION -- a fake ("measured"), 
   ;;  noise confused distribution (need k values). This needs
   ;; to be resampled (gaussian & poisson) at each iteration!
   IF (t EQ 0) THEN BEGIN
      global_trueparams = define_global_params()  
      
      ;;**** TRUE PARAMETER VALUES: ****                     
      global_trueparams.Smin = 1.0
      global_trueparams.alpha = -1.5
      global_trueparams.norm = 40.
      global_trueparams.smax = 20.0
      ;;********************************
      
      trueN = get_nsource(_EXTRA=global_trueparams)
      resample_trueN = randomn(seed, 1, POISSON=trueN)
      
      randomp, sim, global_trueparams.alpha, resample_trueN, $
               RANGE_ = [global_trueparams.Smin, global_trueparams.Smax]
      
      sim += (randomn(seed,resample_trueN)*global_trueparams.rms)
      res = bindata(fluxbins, sim)
      kvals = res[*,1]
      sim = 0.
      global_params.kvals = kvals
   ENDIF

   ;;- Calculate probability via the double integral in eq.(7)
   ;;  at each bin, plug the value of the integral into the Poisson 
   ;;  equation with the k values from the confused (measured) distribution.
   global_params.alpha = newG
   global_params.Smin  = newS
   global_params.Smax  = newSx
   global_params.norm  = newN
   Probs = fltarr(global_params.NBINS-1)
   probs_beta = fltarr(global_params.NBINS-1)

   FOR ibin = 0, global_params.NBINS - 2 DO BEGIN
      k = kvals[ibin]    
      integral = pn_integral(fluxbins[ibin],$,
                             fluxbins[ibin+1],$
                             _EXTRA=global_params,$
                             RESOLUTION=global_params.INTEGRAL_RESOLUTION)
      
      ;;- Poisson equation
      log_P = (k * alog(integral)) - (k * alog(k)) + k - integral
      Probs_beta[ibin] = exp( global_params.beta * log_P ) 
   ENDFOR


   ;;- Total probability is just the product of all the bins
   newP = product(Probs_beta)
   
   
   ;;- First loop just calculates the probability for the 
   ; initialized parameters. So skip the comparison.
   IF (t EQ 0) AND (global_params.global_count EQ 0) THEN BEGIN
      oldP  = newP 
      oldG  = newG  & gchain[t]  = newG
      oldS  = newS  & schain[t]  = newS
      oldSx = newSx & Sxchain[t] = newSx
      oldN  = newN  & nchain[t]  = newN
      CONTINUE
   ENDIF
           

   ;;- ACCEPTANCE/REJECTION
   ;   If the new probability is larger than the old one, keep the new one. 
   ;   Otherwise do a comparison with a uniform random number.
   U = randomu(seed)
   IF (newP GT oldP) OR ( (newP/oldP) GE U) THEN BEGIN
      IF global_params.CHECK THEN BEGIN
         print, 'alpha: '+strim(oldG) + ' --> '    + strim(newG)
         print, 'Smin: ' +strim(oldS) + '  --> '   + strim(newS)
         print, 'Smax: ' +strim(oldSx) + '   --> ' + strim(newSx)
         print, 'Norm: ' +strim(oldN) + '   --> '  + strim(newN)
         print, 'newp = ',newp
      ENDIF 
      oldP  = newP 
      oldG  = newG
      oldS  = newS
      oldSx = newSx
      oldN  = newN
   ENDIF

   IF global_params.check THEN BEGIN
      print, newG,'  ',newS, newSx, newN
     ; print, 'probs: ',probs
      print, 'Old probability: '+strim(oldP)
      print, 'New Probability: '+strim(newP)
      print, oldP
      print, oldG, oldS, oldSx, oldN
      print, '---------------------------'
   ENDIF

   gchain[t]  = oldG
   schain[t]  = oldS
   Sxchain[t] = oldSx
   Nchain[t]  = oldN  

ENDFOR

n = n_elements(gchain)
retarr = dblarr(n,6)
retarr[*,0] = gchain
retarr[*,1] = schain
retarr[*,2] = sxchain
retarr[*,3] = nchain
retarr[0,4] = oldP
khere = global_params.NBINS-2
retarr[0:khere,5] = kvals

RETURN, retarr

END
