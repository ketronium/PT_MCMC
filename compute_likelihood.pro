FUNCTION compute_likelihood, fluxbins, $
                             logP = logP,$
                             _EXTRA=global_params


;+
;
; If logP keyword is set this returns the log(P_i) values (array)
; instead of just one number product( exp( log(P_i))).
;
;-


kvals = global_params.kvals
probs_beta = dblarr(global_params.NBINS-1)
FOR ibin = 0, global_params.NBINS - 2 DO BEGIN
   k = kvals[ibin]    
   integral = pn_integral(fluxbins[ibin],$,
                          fluxbins[ibin+1],$
                          _EXTRA=global_params,$
                          RESOLUTION=global_params.INTEGRAL_RESOLUTION)
   
   ;;- Poisson equation
   log_P = (k * alog(integral)) - (k * alog(k)) + k - integral
   Probs_beta[ibin] = exp( global_params.beta * log_P ) 
ENDFOR

;;- Total probability is just the product of all the bins
newP = product(Probs_beta)

IF keyword_set(logP) THEN RETURN, log_P ELSE RETURN, newp

END
