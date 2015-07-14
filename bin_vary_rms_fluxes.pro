FUNCTION bin_vary_rms_fluxes, rms_fluxes, $
                              _EXTRA=global_params



;+ 
;
; Bins (linearly) the fluxes with varying rms values 
; into rms bins, according to binsize. It returns a pointer
; containing the k-values of the binned fluxes according to 
; the binning defined in global_params, and the rms (binned
; according to BINSIZE keyword) which correspond to each set
; of k-values. So for each pointer entry, there's a single
; rms value, and an array of k-values for said rms.
;
;-


COMPILE_OPT HIDDEN


fluxbins = ((global_params).fluxbins)[0:(global_params.NBINS-1)]


;;- First make the rms bins.
S = reform(rms_fluxes[0,*])
rms = reform(rms_fluxes[1,*])
nbins_rms = ceil(( max(rms) - min(rms) ) / global_params.rms_binsize)
rms_bins = linbins(nbins_rms + 1 , min(rms), $
                   max(rms) )


;;- Storage
kvals_ptr = ptrarr(nbins_rms, /allocate_heap)
kvals_struct = {rms_vary:1.0,$
                kvals_vary:fltarr(global_params.NBINS - 1)}


;;- Get arrays of the fluxes for each interval of rms_bins
v = value_locate(rms_bins, rms)
btwn_bins = where( (v GT -1) AND (v LE max(rms_bins)))
v = v[btwn_bins]


;;- Bin the rms binned fluxes... bins of bins...
rms_bin_median = fltarr(nbins_rms)
FOR i = 0, ceil(nbins_rms) - 1 DO BEGIN
   inds = where(v EQ i)
;   rms_bin_median[i] = median( [rms_bins[i], rms_bins[i+1]] )
;   stop
   ;;- Get k-values for this rms bin
   fluxes_thisbin = s[inds]
   res = bindata(fluxbins, fluxes_thisbin)

   kvals_struct.rms_vary = mean( [rms_bins[i], rms_bins[i+1]] )
   kvals_struct.kvals_vary = res[*,1] / global_params.rms_binsize

   (*kvals_ptr[i]) = kvals_struct

ENDFOR


RETURN, kvals_ptr


END
