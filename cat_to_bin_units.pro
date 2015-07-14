FUNCTION cat_to_bin_units, _EXTRA=g


;+ 
;
; Returns the multiplicative factor to match the inputted
; bin flux units to the catalog units, both of which are
; defined in the parameter file. 
;
; Catalog units -> bin units.
;
;-


COMPILE_OPT HIDDEN

cat_units = strupcase(strim(g.CATALOG_UNITS))
bin_units = strupcase(strim(g.BIN_UNITS))

mult = 1.0
CASE BIN_UNITS OF
   'JY': BEGIN
      CASE CAT_UNITS OF
         'JY' : mult *= 1.0
         'MJY': mult *= 1e-3
         'UJY': mult *= 1e-6
         ELSE: MESSAGE, 'Jy, mJy, or uJy are the only '+ $
                        'accepted input BIN_UNITS.'
      ENDCASE
   END
   'MJY': BEGIN
      CASE CAT_UNITS OF
         'JY' : mult *= 1e3
         'MJY': mult *= 1.0
         'UJY': mult *= 1e-3
         ELSE: MESSAGE, 'Jy, mJy, or uJy are the only '+ $
                        'accepted input BIN_UNITS.'
      ENDCASE
   END
   'UJY': BEGIN
      CASE CAT_UNITS OF
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
