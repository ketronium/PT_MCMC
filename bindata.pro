function bindata, x, y, $
                  MEDIAN=MEDIAN,$
                  MAX=MAX,$
                  MIN=MIN
                  
;+
;
; Does binning at median x location between points -- 
; so it returns n_elements(x) - 1 values by default.
; If you set /MAX then the x values are used as bin
; maximums, and everything below max(X) is used. If you set
; /MIN then the x values are used as bin minimums, and 
; everything above min(x) is used.
;
; -MEDIAN (default):
;              x[0]      x[1]       x[2]       x[3]
; returns:           y0        y1          y2
;
; -MAX:
;                x[0]      x[1]       x[2]       x[3]
; returns:  y0         y1         y2         y3
;
; -MIN
;              x[0]      x[1]       x[2]       x[3]
; returns:           y0        y1          y2        y3    
;
;
; Ketron 12/12
;
;-

COMPILE_OPT HIDDEN

IF keyword_set(MAX) THEN BEGIN
   NBINS = n_elements(x)
   v = value_locate(x, y) + 1.
   v = v[ where(v le (nbins - 1)) ]
   dn = histogram(v)
   
   dx = abs(deriv(x))

ENDIF ELSE IF keyword_set(MIN) THEN BEGIN
   NBINS = n_elements(bins)
   v = value_locate(x, y)
   v = v[ where(v ge 0) ]
   dn = histogram(v)

   dx = abs(deriv(x))

ENDIF ELSE BEGIN
   NBINS = n_elements(x) - 1
   v = value_locate(x, y)
   btwn_bins = where( (v gt -1) AND (v le (NBINS-1)) )
   v = v[ btwn_bins ]
   dn = histogram(v)

   dx = fltarr(NBINS)
   for b = 0, NBINS-1 do dx[b] = mean( [x[b], x[b+1]] )
   meanbins = dx
   dx = abs(deriv(dx));

   ;;- sometimes there will be nothing in some of the bins -- keep
   ;;  track and set to zero!
   totbins = lindgen(NBINS)
   dup = v[rem_dup(v)]
   fix = lonarr(NBINS)
   IF n_elements(totbins) NE n_elements(dup) THEN BEGIN
      same = where(dup EQ totbins)
      fix[same] = 1L
      FOR i = 0, n_elements(fix) -1 DO BEGIN
         IF fix[i] EQ 1L THEN fix[i] = dn[i]
      ENDFOR
      dn = fix
   ENDIF

ENDELSE

;if n_elements(dx) ne n_elements(dn) then begin
;   dx = fltarr(NBINS) & dn = dx
;;   stop
;endif

return, [[dx],[dn],[meanbins]]

end
