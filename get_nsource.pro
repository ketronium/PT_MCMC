FUNCTION get_nsource, _EXTRA=global_params
  

;+
;
; Calculates the number of sources between MINFLUX and MAXFLUX
; to be used in randomp, assuming the normalization from 
; Condon 1984 (Condon+ 2012). Returns NSOURCE for 3 different 
; units of area: /Sr, /deg2, or /arcmin2. This is only used for
; the simulations!!!
;
;-

COMPILE_OPT HIDDEN


mult = flux_units(_EXTRA=global_params)

SMIN = (global_params.SMIN) * mult
SMAX = (global_params.SMAX) * mult


;;- integrate over model to get total number of sources in flux range.
; This integral will return the number of sources in the DNDS units
; defined in the parameter file. This needs to be consistent with 
; the area of the survey.
QSIMP, 'dnds_model', SMIN, SMAX, N, _EXTRA=global_params


Smin /= mult
Smax /= mult


;;- Return the number of sources for the given sky area.
mult = sky_units(_EXTRA=global_params)
RETURN, N * mult * global_params.sky_area


END
