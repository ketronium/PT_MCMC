FUNCTION define_global_params_grid


;+ 
;
; Edit this directly with your observational-specific values.
; 
;-



global_params = make_global_structure_grid()
global_params.NBINS          = 13.
global_params.MINBIN         = 1.0
global_params.MAXBIN         = 20.0
global_params.SKY_AREA       = 50.
global_params.SKY_UNITS      = 'deg2'
global_params.FLUX_UNITS     = 'ujy'
global_params.rms            = 10.
global_params.savedir        = '/home/ketron/grid/'
global_params.codedir        = '/home/ketron/cts_code/current/'



;;----------------------------------------
;check = CHECK_GLOBAL_PARAMS(global_params)
defsysv,'!CODEDIR',global_params.codedir
RETURN, global_params

END
