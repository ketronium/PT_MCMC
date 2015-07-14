FUNCTION make_global_structure, vals=vals


;+
;
; This just creates a global parameter structure which will be
; used throughout the analysis.
;
;- 

COMPILE_OPT HIDDEN

totbins = 20

global_param_structure = {nbins:0.,$
                          minbin:0.,$
                          maxbin:0.,$
                          rms:0.,$
                          sky_area:0.,$
                          sky_units:'',$
                          bin_units:'',$
                          dOmega:0d,$
                          vary_rms:0L,$
                          rms_min:0.,$
                          rms_max:0.,$
                          rms_binsize:0.,$
                          savedir:'',$
                          codedir:'',$
                          prior_minalpha:0.,$
                          prior_maxalpha:0.,$
                          prior_minSmin:0.,$
                          prior_maxSmin:0.,$
                          prior_minSx:0.,$
                          prior_maxSx:0,$
                          prior_minNorm:0.,$
                          prior_maxNorm:0.,$
                          chain_length:0.,$
                          fluxbins:fltarr(totbins+1),$
                          KVALS:fltarr(totbins+1),$
                          ALPHA:0d,$ 
                          SMIN:0d,$ 
                          SMAX:0d,$
                          NORM:0d,$
                          BETA:0d,$
                          oldP:0d,$
                          chain_num:'',$
                          INTEGRAL_RESOLUTION:0d,$
                          N_SWAP:0,$
                          global_count:0,$
                          trueChain:0L,$
                          check:0L,$
                          global_adapt:1L,$
                          trueN:0d,$
                          adaptA:0d,$
                          adaptS:0d,$
                          adaptSx:0d,$
                          adaptN:0d,$
                          NITER:1L,$
                          BETA_MIN:1.,$
                          BETA_MAX:1.,$
                          verbose:'',$
                          linear:'',$
                          catalog_name:'',$
                          catalog_units:'',$
                          WIDTH_A1:1.,$
                          WIDTH_S1:1.,$
                          WIDTH_SX1:1.,$
                          WIDTH_C1: 1.,$
                          WIDTH_A2:1.,$
                          WIDTH_S2:1.,$
                          WIDTH_SX2:1.,$
                          WIDTH_C2:1.,$
                          alphas:fltarr(6),$
                          smins:fltarr(6),$
                          smaxs:fltarr(6),$
                          norms:fltarr(6),$
                          dnds_flux_units:'',$
                          dnds_area_units:'',$
                          param_file:''}

RETURN, global_param_structure

END
