FUNCTION flux_units_cat, _EXTRA=g


;+ 
;
; Returns the multiplicative factor to match the inputted
; bin flux units to the flux units of dN/dS, both of which are
; defined in the parameter file.
;
;-


COMPILE_OPT HIDDEN

dnds_flux_units = strupcase(strim(g.CATALOG_UNITS))
bin_units = strupcase(strim(g.BIN_UNITS))

mult = 1.0
CASE dnds_flux_units OF
   'JY': BEGIN
      CASE BIN_UNITS OF
         'JY' : mult *= 1.0
         'MJY': mult *= 1e-3
         'UJY': mult *= 1e-6
         ELSE: MESSAGE, 'Jy, mJy, or uJy are the only '+ $
                        'accepted input BIN_UNITS.'
      ENDCASE
   END
   'MJY': BEGIN
      CASE BIN_UNITS OF
         'JY' : mult *= 1e3
         'MJY': mult *= 1.0
         'UJY': mult *= 1e-3
         ELSE: MESSAGE, 'Jy, mJy, or uJy are the only '+ $
                        'accepted input BIN_UNITS.'
      ENDCASE
   END
   'UJY': BEGIN
      CASE BIN_UNITS OF
         'JY' : mult *= 1e6
         'MJY': mult *= 1e3
         'UJY': mult *= 1.0
         ELSE: MESSAGE, 'Jy, mJy, or uJy are the only '+ $
                        'accepted input BIN_UNITS.'
      ENDCASE
   END
ENDCASE

RETURN, mult

END
