FUNCTION pn_integral, bin_min, bin_max, $
                      RESOLUTION=RESOLUTION,$
                      _EXTRA = e


;+
;
; Ketron 11/2012
;
; Integration of eq. (7). 
;
;
;    /smax               /max_bin
;    |     dS * dN/dS *  |        dS' exp(-(S-S')/2/rms^2)
;    /smin               /min_bin
;
; Analytic solution of second integral is error functions.
;
;-


COMPILE_OPT HIDDEN

NORMAL = e.NORM
alpha = e.alpha
Smin = e.Smin
Smax = e.Smax
rms = e.rms


;;- Convert sky_area units to be consistent with dN/dS units.
area_mult = sky_units(_EXTRA=e)
NORMAL *= e.SKY_AREA * area_mult
 

;;- Convert bin_units to be consistent with dN/dS units.
mult = bin_to_dnds_units(_EXTRA=e)
Smin *= mult
Smax *= mult
bin_min *= mult
bin_max *= mult
rms *= mult


; Integration via mid-point rule.
IF NOT KEYWORD_SET(resolution) THEN resolution = 1e3

ds = (Smax - Smin) / resolution
resu = 0.0

FOR i = 1L, LONG(resolution)  DO BEGIN 
   Si = Smin + (i - 0.5) * ds
   erfs = erf( (Si-bin_min)/(sqrt(2)*rms) ) - $
          erf( (Si-bin_max)/(sqrt(2)*rms) )

   resu += ( NORMAL * Si^(alpha) * erfs * ds ) ;this is in */JANSKYS /deg2*
ENDFOR

resu *= 0.5 ;integration constant via analytical solution of Pm(Sm)dSm

IF resu LE 0 THEN message, "Integral < 0",/INF
IF finite(resu) EQ 0 THEN message, 'Integral is NaN.'

smin /= mult
smax /= mult
bin_min /= mult
bin_max /= mult
rms /= mult
NORMAL = NORMAL / e.SKY_AREA / area_mult

;print, alpha, smin
RETURN, resu

END
 

