function pn_integral_vary, bin_min, bin_max, $
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

;;- Keep track of UNITS!!!!
NORMAL = e.NORM
SKY_UNITS = strupcase(strim(e.SKY_UNITS))
CASE SKY_UNITS OF
   'Sr'     : NORMAL = NORMAL
   'DEG2'   : NORMAL *= !pi / (180^2)
   'ARCMIN2': NORMAL *= !pi / (180^2) / (60^2)
   ELSE: MESSAGE, 'Sr, deg2, or arcmin2 are the only '+$
                  'accepted input sky_area units.'
ENDCASE

AREA = e.SKY_AREA
NORMAL *=  AREA
 
FLUX_UNITS = strupcase(strim(e.FLUX_UNITS))
CASE FLUX_UNITS OF
   'NJY': mult = 1e-9
   'UJY': mult = 1e-6
   'MJY': mult = 1e-3
   'JY' : mult = 1.
   ELSE: MESSAGE, 'Jy, mJy, uJy or nJy are the only '+$
                     'accepted input flux_unit units.'
ENDCASE

alpha = e.alpha
Smin = e.Smin
Smax = e.Smax
rms = e.rms
S0 = e.rms_min
S1 = e.rms_max

Smin *= mult
Smax *= mult
bin_min *= mult
bin_max *= mult
rms *= mult
S0 *= mult
S1 *= mult

; Integration via mid-point rule.
IF NOT KEYWORD_SET(resolution) THEN resolution = 1e5

ds = (Smax - Smin) / resolution
resu=0.0

FOR i = 1L, LONG(resolution)  DO BEGIN 
   Si = Smin + (i-0.5) * ds
   erfs = erf( (Si-bin_min)/(sqrt(2)*rms) ) - $
          erf( (Si-bin_max)/(sqrt(2)*rms) )

   resu += ( NORMAL * Si^(alpha) * erfs * ds ) ;this is in */JANSKYS /Sr*
ENDFOR

resu *= 0.5 ;integration constant via analytical solution of Pm(Sm)dSm

IF resu LE 0 THEN message, "Integral < 0",/INF

smin /= mult
smax /= mult
bin_min /= mult
bin_max /= mult
rms /= mult
S0 /= mult
S1 /= mult

;print, alpha, smin
RETURN, resu

END
 

