FUNCTION define_global_params, param_file


;+ 
;
; Generates an IDL structure from parameters set in PARAM_FILE
; (named mcmc.param by default).
;
; dOmega: Area of one pixel in STERADIANS. 
;
; Ketron 12/12 
;-


COMPILE_OPT HIDDEN
;IF n_elements(param_file) EQ 0 THEN param_file = 'mcmc.param'
global_params = make_global_structure()

openr, 1, param_file
line = ''
alphas = fltarr(6) & smins = fltarr(6) 
smaxs = fltarr(6) & norms = fltarr(6)
WHILE NOT eof(1) DO BEGIN
   readf, 1, line
   IF ( (strim(line[0]) EQ '#') OR $
        (strim(line) EQ '') ) THEN CONTINUE
   sp = strpos(line, ' ')
   pound = strpos(line, '#')
   IF pound EQ -1 THEN pound = 999
   line = strmid(line, 0, pound)
   name = strim(strmid(line, 0, sp))
   var =  strmid(line, sp+1, 99)
   
   CASE strupcase(name) OF
      '': BREAK
      'N_SWAP': global_params.N_SWAP = float(var) 
      'NITER': global_params.NITER = var
      'BETA_MIN': global_params.BETA_MIN = float(var) 
      'BETA_MAX': global_params.BETA_MAX = float(var) 
      'VERBOSE': global_params.VERBOSE = strim(strupcase(var)) 
      'LINEAR': global_params.LINEAR = strim(strupcase(var)) 
      'NBINS': global_params.NBINS = float(var) + 1
      'MINBIN': global_params.MINBIN = float(var)
      'MAXBIN': global_params.MAXBIN = float(var)
      'BIN_UNITS': global_params.BIN_UNITS = strim(strupcase(var))
      'CATALOG_NAME': global_params.CATALOG_NAME = strim(var) 
      'CATALOG_UNITS': global_params.CATALOG_UNITS = strim(strupcase(var)) 
      'SKY_AREA': global_params.SKY_AREA = float(var)
      'SKY_UNITS': global_params.SKY_UNITS = strim(var)
      'FLUX_UNITS':global_params.FLUX_UNITS = strim(strupcase(var))
      'RMS': global_params.RMS = float(var)
      'RESOLUTION': global_params.dOmega = float(var) * (!pi / 180. / 3600.)^2
      'MIN_ALPHA': global_params.prior_minalpha = float(var)
      'MAX_ALPHA': global_params.prior_maxalpha = float(var)
      'MIN_SMIN': global_params.prior_minSmin  = float(var)
      'MAX_SMIN': global_params.prior_maxSmin  = float(var)
      'MIN_SMAX': global_params.prior_minSx    = float(var)
      'MAX_SMAX': global_params.prior_maxSx    = float(var)
      'MIN_C': global_params.prior_minNorm  = float(var)
      'MAX_C': global_params.prior_maxNorm  = float(var)
      'ALPHAS':BEGIN
         var = strtrim(var,1)
         FOR i = 0, n_elements(alphas) - 1 DO BEGIN
            nsp = strpos(var,' ')
            alphas[i] = float(strmid(var,0,nsp))
            IF alphas[i] EQ 0 THEN message, 'You have to define 6 non-zero'+$
                                            'initial guesses for alpha.'
            var = strtrim( strmid(var,nsp+1,99),1)
         ENDFOR
         global_params.alphas = alphas
      END   
      'SMINS':BEGIN
         var = strtrim(var,1)
         FOR i = 0, n_elements(smins) - 1 DO BEGIN
            nsp = strpos(var,' ')
            smins[i] = float(strmid(var,0,nsp))
            IF smins[i] EQ 0 THEN message, 'You have to define 6 non-zero'+$
                                           'initial guesses for Smin.'
            var = strtrim( strmid(var,nsp+1,99) ,1)
         ENDFOR
         global_params.smins = smins
      END   
      'SMAXS':BEGIN
         var = strtrim(var,1)
         FOR i = 0, n_elements(smaxs) - 1 DO BEGIN
            nsp = strpos(var,' ')
            smaxs[i] = float(strmid(var,0,nsp))
            IF smaxs[i] EQ 0 THEN message, 'You have to define 6 non-zero'+$
                                           'initial guesses for Smax.'
            var = strtrim( strmid(var,nsp+1,99) ,1)
         ENDFOR
         global_params.smaxs = smaxs
      END   
      'NORMS':BEGIN
         var = strtrim(var,1)
         FOR i = 0, n_elements(norms) - 1 DO BEGIN
            nsp = strpos(var,' ')
            norms[i] = float(strmid(var,0,nsp))
            IF norms[i] EQ 0 THEN message, 'One of your initial guesses for C '+$
                                           'is zero...', /INF
            var = strtrim( strmid(var,nsp+1,99), 1)
         ENDFOR
         global_params.norms = norms
      END   
      'SAVEDIR':BEGIN
         IF strpos(var,'/',/REVERSE_SEARCH) NE strlen(var) THEN var = strim(var) + '/'
         global_params.savedir = strim(var)
      END
      'CODEDIR':BEGIN
         IF strpos(var,'/',/REVERSE_SEARCH) NE strlen(var) THEN var = strim(var) + '/'
         global_params.codedir = strim(var)
      END
      'WIDTH_A1':global_params.width_A1 = float(var)
      'WIDTH_S1':global_params.width_S1 = float(var)
      'WIDTH_SX1':global_params.width_SX1 = float(var)
      'WIDTH_C1': global_params.width_C1 = float(var)
      'WIDTH_A2':global_params.width_A2 = float(var)
      'WIDTH_S2':global_params.width_S2 = float(var)
      'WIDTH_SX2':global_params.width_Sx2 = float(var)
      'WIDTH_C2':global_params.width_C2 = float(var)
      'DNDS_FLUX_UNITS':global_params.dnds_flux_units = strupcase(strim(var))
      'DNDS_AREA_UNITS':global_params.dnds_area_units = strupcase(strim(var))
   ENDCASE
ENDWHILE

close, 1

check = CHECK_GLOBAL_PARAMS(global_params)


;;- Set initial proposal distribution widths to be 1/10 of the prior widths.
global_params.adaptA         = 0.002;abs(global_params.prior_minalpha - $
                                    ; global_params.prior_maxalpha)*0.1

global_params.adaptS         = 0.015;abs(global_params.prior_minSmin  - $
                                   ;global_params.prior_maxSmin)*0.1

global_params.adaptSx        = 0.25 ;abs(global_params.prior_minSx - $
                                   ; global_params.prior_maxSx)*0.1

global_params.adaptN         = 1.1 ;abs(global_params.prior_minNorm - $
                                   ; global_params.prior_maxNorm)*0.1

global_params.global_adapt = 0L


RETURN, global_params

END
