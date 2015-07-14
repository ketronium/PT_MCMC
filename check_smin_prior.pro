FUNCTION check_smin_prior, Tsmin, Tsmax, TNorm, Talpha,$
                           _EXTRA=global_params


;+
;
; The minimum, noise-free, model flux should be above some
; lower threshold, otherwise confusion noise becomes non-negligible
; and a pixel may have a flux contribution from more than one galaxy. 
; This method fails if that happens. We quantify this limit with a 
; relation to the shot-noise:
;
;        /Smax
;  Sqrt( |     dN/dS * dOmega * S^2 dS )  <  rms / div.
;        /Smin
;
;    where dOmega is the pixel size (in the same units as dN/dS * S).
;
;
; Currently this is hard-coded with an analytical soulution to
; a dN/dS model following C*S^-alpha. If your parameterization
; is different, change accordingly.
;
;-

!EXCEPT = 0
COMPILE_OPT HIDDEN

div = 2.0

;;- I do everything in units of /Jy /sr for dN/dS!!! (i.e. C is /sr) 
; => so your pixel scale, global_params.dOmega *must* be in units 
; of SR already!
mult = flux_units(_EXTRA=global_params)
Tsmin  *= mult
Tsmax  *= mult
Trms    = (global_params.rms)  * mult
TdOmega = global_params.dOmega


CHECK_SMIN = ( (Tsmax^(3 + Talpha)) - $
               (((3 + Talpha) * Trms^2) / $
                (Tnorm * TdOmega * div^2)) )^(1. / (3 + Talpha))


;;- NaN implies result is negative real number 
;   plus imaginary number, i.e. smin is OK.
IF finite(CHECK_SMIN) EQ 0 THEN BEGIN
   result = 1L  
   RETURN, result
ENDIF

IF check_smin LE Tsmin THEN result = 1L ELSE result = 0L

RETURN, result

END
