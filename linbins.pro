FUNCTION linbins, NBINS, MIN, MAX


linbin = (findgen(NBINS) /(NBINS -1) * (MAX - MIN) ) + MIN

RETURN, linbin

END
