FUNCTION get_vary_rms_fluxes, Nsource, $
                         rms_min, $
                         rms_max, $
                         _EXTRA=global_params


;+
;
; This generates a noise-confused flux distribution following
; the true dN/dS parameter values in the global structure.
; It will return an array of two columns: noise-confused flux
; densities | corresponding rms. The rms is uniformly distributed
; between rms_min and rms_max.
;
; -


COMPILE_OPT HIDDEN


rms_min = global_params.rms_min
rms_max = global_params.rms_max

rms = ( randomu(seed, Nsource) * (rms_max - rms_min) ) + rms_min

randomp, S, global_params.alpha, Nsource, $
            RANGE_ = [global_params.Smin, global_params.Smax]

S += (randomn(seed, Nsource) * rms)

rms_fluxes = fltarr(2, Nsource)
rms_fluxes[0,*] = S
rms_fluxes[1,*] = rms


RETURN, rms_fluxes

END
