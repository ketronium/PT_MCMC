function bin_indices, x, y


NBINS = n_elements(x) - 1
v = value_locate(x, y)
btwn_bins = where( (v gt -1) AND (v le (NBINS-1)) )
v = v[ btwn_bins ]
dn = histogram(v)

dx = fltarr(NBINS)
for b = 0, NBINS-1 do dx[b] = mean( [x[b], x[b+1]] )
meanbins = dx
dx = abs(deriv(dx))             ;

bin_ind = v
return, v

end
