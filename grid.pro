PRO grid, num,$
          VERBOSE=VERBOSE,$
          CHECK=CHECK,$
          INTEGRAL_RESOLUTION=INTEGRAL_RESOLUTION,$
          LINEAR=LINEAR




;;- Define global parameter structure. Smin and alpha are 
;;  initialized when you call this code.
global_params = define_global_params()
verbose = keyword_set(VERBOSE)
check = keyword_set(CHECK)
;;avoid overwriting files:
IF NOT keyword_set(num) THEN num = strim(randomn(seed),l=4) 
IF NOT keyword_set(INTEGRAL_RESOLUTION) THEN $
   global_params.integral_resolution=7e3


;;- Make bins.
IF KEYWORD_SET(LINEAR) THEN BEGIN
   fluxbins = linbins(global_params.NBINS, $
                      global_params.MINBIN,$
                      global_params.MAXBIN)
ENDIF ELSE BEGIN
   fluxbins = logbins(global_params.NBINS, $
                      global_params.MINBIN,$
                      global_params.MAXBIN)
ENDELSE


;;- Make a fake ("measured"), noise confused distribution (need k values).
;   Say distribution follows dN/dS = 1.2e5 S^-1.5
global_trueparams = define_global_params()
global_trueparams.Smin = 0.05
global_trueparams.alpha = -1.5
global_trueparams.Norm = 1.2e5
;global_trueparams = force_normalization(_EXTRA=global_trueparams)
trueN = get_nsource(_EXTRA=global_trueparams)
randomp, sim, global_trueparams.alpha, trueN, $
         RANGE_ = [global_trueparams.Smin, global_trueparams.Smax]
sim += (randomn(seed,trueN)*global_trueparams.rms)
res = bindata(fluxbins, sim)
kvals = res[*,1]


;;- INITIALIZE
;a=findgen(2000)/1000+.5 whole range
avals = (-1)*(findgen(100)/100 +1.)
Svals = findgen(91)/1000+0.01
;avals = (-1) * (findgen(51)/50 +1.)
;svals = findgen(21)/100 + 0.01
sxvals = findgen(30)/1 + 1
normvals = [0.2,.4,.6,.8,1.,1.2,1.4,1.6,1.8,2.]*1e5 ;/Jy/Sr


openw,1,global_params.savedir+strim(num)+'.txt'
printf,1,'# alpha    Smin     Smax     Norm     P'
;for i=0, NTOT-1 do 




NTOT = N_ELEMENTS(avals) * N_ELEMENTS(Svals) * $
       N_ELEMENTS(normvals) * N_ELEMENTS(Sxvals)

gchain = fltarr(NTOT)
schain = fltarr(NTOT)
sxchain = fltarr(NTOT)
normchain = fltarr(NTOT)
Parr  = fltarr( NTOT)
Pcount = 0L


tstart = systime(/sec)
FOR t = 0L, N_ELEMENTS(avals) - 1 DO BEGIN   
   global_params.alpha = avals[t]

   FOR ts = 0L, N_ELEMENTS(svals) - 1 DO BEGIN
      global_params.Smin = svals[ts]

      FOR tsx = 0L, N_ELEMENTS(sxvals) - 1 DO BEGIN
         global_params.Smax = sxvals[tsx]

         FOR tn = 0L, N_ELEMENTS(normvals) - 1 DO BEGIN
            global_params.NORM = normvals[tn]
         
            ;;- Calculate probability for this Smin and gamma (should
            ;;  incorporate Smax into this analysis?) 
            ;;
            ;;- First step is to get the correct number of total 
            ;;  sources given the slope, flux range, and normalization.
            
            
            ;;global_params = force_normalization(_EXTRA=global_params)
            ;; force_normalization just returns the
            ;; NORM tag -- but now I'm fitting for it so it's in the grid.
            NSOURCE = get_nsource(_EXTRA=global_params)
            
            
            ;;- Second step is to calculate the double integral in eq.(7)
            ;;  at each bin, plug the value of the integral into the Poisson 
            ;;  equation with the k values from the confused distribution.
            Probs = fltarr(global_params.NBINS-1)
            FOR ibin = 0, global_params.NBINS - 2 DO BEGIN
               k = kvals[ibin]    
               integral = pn_integral(fluxbins[ibin],$,
                                      fluxbins[ibin+1],$
                                      _EXTRA=global_params,$
                                      RESOLUTION=global_params.INTEGRAL_RESOLUTION)
               
               ;;- Poisson equation
               log_P = (k * alog(integral)) - (k * alog(k)) + k - integral
               Probs[ibin] = exp(log_P)
            ENDFOR
            
            print, Pcount
            ;;- Total probability is just the permutation of all the bins
            Parr[Pcount] = product(Probs)
            
            ;gchain[Pcount] = avals[t]
            ;schain[Pcount] = svals[ts]
            ;sxchain[Pcount] = Sxchain[t
            ;normchain[Pcount] = normvals[tn]
            IF (Pcount MOD 500) THEN BEGIN
               close,1
               openw,1,'$cts/grid'+strim(num)+'.txt',/APPEND
            ENDIF
            
            printf,1,strim(global_params.alpha,l=6)+'  '+$
                   strim(global_params.Smin,l=6)+'  '+$
                   strim(global_params.Smax,l=6)+'  '+$
                   strim(global_params.Norm,l=6)+'  '+$
                   strim(Parr[Pcount],l=6)+'  ',$
                   format = '(200A)'
            
            Pcount += 1
            ;;print, ts
         ENDFOR
      ENDFOR
   ENDFOR
   IF t EQ 0 THEN message, strim( ( systime(/sec) - tstart ) / $
                                  60 * (N_elements(avals)-1),len=5)+$
                           ' minutes unitl complete.', /INF

   IF (t MOD 20) EQ 0 THEN BEGIN
      c = (float(t) / float(N_ELEMENTS(avals))* 100.)
      p = strpos(string(c),'.')
      message, strtrim(strmid(c,0,p+2),2)+'%',/INF
   ENDIF

ENDFOR

close,1
;struct = {GCHAIN:fltarr(NTOT),$
;          SCHAIN:fltarr(NTOT),$
;          PARR:fltarr(NTOT)};

;struct.gchain = gchain
;struct.schain = schain
;struct.Parr = parr
;save, struct, filename = '$cts/grid3.sav'


END
