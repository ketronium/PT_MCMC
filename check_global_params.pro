FUNCTION check_global_params, global_params


;+
;
; Error checking for user-input global_parameter values.
; This should be improved.
;
;-


COMPILE_OPT HIDDEN


IF global_params.prior_minSmin GT global_params.prior_maxSmin THEN BEGIN
   t = global_params.prior_minSmin
   global_params.prior_minSmin = global_params.prior_maxSmin
   global_params.prior_maxSmin = t
ENDIF


IF global_params.prior_minalpha GT global_params.prior_maxalpha THEN BEGIN
   t = global_params.prior_minalpha
   global_params.prior_minalpha = global_params.prior_maxalpha
   global_params.prior_minalpha = t
ENDIF


IF global_params.savedir EQ '' THEN $
   MESSAGE, 'You need to set global_params.savedir' ELSE $
      defsysv, '!SAVEDIR', global_params.savedir


IF global_params.codedir EQ '' THEN $
   MESSAGE, 'You need to set global_params.codedir' ELSE $
      defsysv, '!CODEDIR', global_params.codedir


CHECK_SMIN = check_smin_prior(global_params.Smin,  $
                              global_params.Smax,  $
                              global_params.Norm,  $
                              global_params.alpha, $
                              _EXTRA=global_params) ;

IF CHECK_SMIN EQ 0L THEN message, 'Your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'


RETURN, 1

END
