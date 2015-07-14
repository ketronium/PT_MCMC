FUNCTION sky_units, _EXTRA=g


;+ 
;
; Returns the multiplicative factor to match the inputted
; survey area units to the units of dN/dS, both of which are
; defined in the parameter file.
;
;-


COMPILE_OPT HIDDEN

dnds_area_units = strupcase(strim(g.DNDS_AREA_UNITS))
sky_units = strupcase(strim(g.SKY_UNITS))

mult = 1.0
CASE dnds_area_units OF
   'SR': BEGIN
      CASE SKY_UNITS OF
         'SR'     : mult *= 1.0
         'DEG2'   : mult *= (!pi / 180.)^2 
         'ARCMIN2': mult *= (!pi / 180. / 60.)^2
         ELSE: MESSAGE, 'Sr, deg2, or arcmin2 are the only '+ $
                        'accepted input sky_area units.'
      ENDCASE
   END
   'DEG2': BEGIN
      CASE SKY_UNITS OF
         'SR'     : mult *= (180. / !pi)^2
         'DEG2'   : mult *= 1.0
         'ARCMIN2': mult *= 3600.
         ELSE: MESSAGE, 'Sr, deg2, or arcmin2 are the only '+ $
                        'accepted input sky_area units.'
      ENDCASE
   END
   'ARCMIN2': BEGIN
      CASE SKY_UNITS OF
         'SR'     : mult *= (60. * 180. / !pi)^2
         'DEG2'   : mult *= 3600.
         'ARCMIN2': mult *= 1.0
         ELSE: MESSAGE, 'Sr, deg2, or arcmin2 are the only '+ $
                        'accepted input sky_area units.'
      ENDCASE
   END
ENDCASE

RETURN, mult

END
