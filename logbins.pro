FUNCTION logbins, NBINS, MIN, MAX


logbn = fltarr(NBINS)
logwidth = (alog10(MAX - MIN + 1) / (NBINS-1) )
logbn[0] = 1.0

FOR i = 0, NBINS-2 DO logbn[i+1] = logbn[i] * 10^logwidth
logbn += MIN - 1.0

;stop
RETURN, logbn

END 
