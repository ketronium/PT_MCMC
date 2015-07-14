PRO gridpar, _EXTRA=global_params


!EXCEPT = 0

num = long(global_params.num)
openw,1,global_params.savedir+'grid'+strim(num,l=2)+'.txt',/APPEND
IF NOT keyword_set(INTEGRAL_RESOLUTION) THEN $
   global_params.integral_resolution=7e3
;print, global_params.integral_resolution
kvals = (global_params.kvals)[0:(global_params.NBINS - 2)]
fluxbins = (global_params.fluxbins)[0:(global_params.NBINS - 1)]

;;- INIT
Agrid  = (global_params.Agrid)[where(global_params.Agrid NE 0.)]
Sgrid  = (global_params.Sgrid)[where(global_params.Sgrid NE 0.)]
Sxgrid = (global_params.Sxgrid)[where(global_params.Sxgrid NE 0.)]
Ngrid  = (global_params.Ngrid)[where(global_params.Ngrid NE 0.)]
Pcount = 0

;print, global_params.integral_resolution
FOR t = 0L, N_ELEMENTS(Agrid) - 1 DO BEGIN   
   global_params.alpha = Agrid[t]

   FOR ts = 0L, N_ELEMENTS(Sgrid) - 1 DO BEGIN
      global_params.Smin = Sgrid[ts]

      FOR tsx = 0L, N_ELEMENTS(Sxgrid) - 1 DO BEGIN
         global_params.Smax = Sxgrid[tsx]

         FOR tn = 0L, N_ELEMENTS(Ngrid) - 1 DO BEGIN
            global_params.NORM = Ngrid[tn]
 

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
            

            ;;- Total probability is just the permutation of all the bins
            Parr = product(Probs)
            
            IF (Pcount MOD 1000) THEN BEGIN
               close,1
               openw,1,global_params.savedir+'grid'+strim(num,l=2)+'.txt',/APPEND
;              Message, strim(Pcount), /INF
            ENDIF
            IF parr GT 0.0 THEN BEGIN 
               printf,1,strim(global_params.alpha,l=6)+'  '+$
                      strim(global_params.Smin,l=15)+'  '+$
                      strim(global_params.Smax,l=15)+'  '+$
                      strim(global_params.Norm,l=15)+'  '+$
                      strim(Parr,l=15)+'  ',$
                      format = '(200A)'
            ENDIF
            
            Pcount += 1
         ENDFOR
      ENDFOR
   ENDFOR
ENDFOR

close,1

END
