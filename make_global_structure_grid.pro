FUNCTION make_global_structure_grid, vals=vals


;+
;
; This just creates a global parameter structure which will be
; used throughout the analysis.
;
;- 


global_param_structure = {nbins:0.,$
                          minbin:0.,$
                          maxbin:0.,$
                          rms:0.,$
                          sky_area:0.,$
                          sky_units:'',$
                          flux_units:'',$
                          norm_area_units:'',$
                          norm_flux_units:'',$
                          savedir:'',$
                          codedir:'',$
                          fluxbins:fltarr(50),$
                          ALPHA:0d,$ 
                          SMIN:0d,$ 
                          SMAX:0d,$
                          NORM:0d,$
                          BETA:0d,$
                          oldP:0d,$
                          KVALS:fltarr(50),$
                          INTEGRAL_RESOLUTION:0d,$
                          Agrid:dblarr(1.5e2),$
                          Ngrid:dblarr(1.5e2),$
                          Sgrid:dblarr(1.5e2),$
                          Sxgrid:dblarr(1.5e2),$
                          num:0.}



; ADD:
;; input flux array ?

RETURN, global_param_structure

END
