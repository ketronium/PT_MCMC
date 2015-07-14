FUNCTION dnds_model, S, _EXTRA=global_params

COMPILE_OPT HIDDEN

RETURN, global_params.NORM * S^(global_params.alpha)

END


