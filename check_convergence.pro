function check_convergence, path_to_chains, $
                            N_BURN


;+
;
; Gelman-Rubin Statistic to check convergence
; of MC chains.
;
;-

CONVERGE = 0L

if path_to_chains[n_elements(path_to_chains)-1] ne '/' then $
   path_to_chains += '/'

files = file_search(path_to_chains + '*.sav')
files = files[0:3]

N_CHAIN = n_elements(files)
IF N_CHAIN LE 1 THEN MESSAGE, 'You need more than one '+$
                              'simulation!'

ptr_g = ptrarr(N_CHAIN,/allocate_heap)
ptr_n = ptrarr(N_CHAIN,/allocate_heap)

FOR i = 0, N_CHAIN - 1 DO BEGIN
   restore, files[i]
   (*ptr_g[i]) = struct.gchain
   (*ptr_n[i]) = struct.nchain
   if i eq 0 then t = n_elements(struct.gchain)-1
ENDFOR

n = t - N_BURN
m = N_CHAIN
tW1 = 0
W = 0 & BB = 0
meantheta = fltarr(N_CHAIN)
   
FOR j = 0, N_CHAIN - 1 DO meantheta[j] = mean((*ptr_g[j])[(N_BURN+1):t])
meantheta_tot = mean(meantheta)

FOR j = 0, N_CHAIN - 1 DO BEGIN
   FOR i = N_BURN+1, t DO tW1 += ( (*ptr_g[j])[i] - meantheta[j] )^2.
   W += tW1
   BB += (meantheta[j] - meantheta_tot)^2.
ENDFOR

W *= 1. / (N_CHAIN * (n-1) )
BB *= n / (N_CHAIN - 1)
V = (1 - (1/n))*W + BB/n
GR_gamma = sqrt(V/W)            ;Gelman-Rubin statistic for gamma.


;;- If gamma has converged, then do same statistic for n0.
IF GR_gamma le 1.05 THEN BEGIN
   
   W = 0 & BB = 0
   message, 'gamma converged, checking n0...', /INF
   
   FOR j = 0, N_CHAIN - 1 DO meantheta[j] = mean((*ptr_n[j])[(N_BURN+1):t])
   meantheta_tot = mean(meantheta)
   
   FOR j = 0, N_CHAIN - 1 DO BEGIN
      FOR i = N_BURN+1, t DO tW1 += ( (*ptr_n[j])[i] - meantheta[j] )^2.
      W += tW1
      BB += (meantheta[j] - meantheta_tot)^2.      
   ENDFOR
   
   W *= 1. / (N_CHAIN * (n-1) )
   BB *= n / (N_CHAIN - 1)
   V = (1 - (1/n))*W + BB/n
   GR_n0 = sqrt(V/W)            ; convergence statistic for n0
   
   IF GR_n0 le 1.05 THEN BEGIN
      message, 'Chains converged.', /INF
      CONVERGE = 1L
   ENDIF ELSE CONVERGE = 0L
ENDIF

stop
RETURN, CONVERGE


END
