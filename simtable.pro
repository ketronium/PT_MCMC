PRO simtable


global_params = make_global_structure()
global_params.NBINS=10
global_params.MINBIN = 0.01
global_params.MAXBIN = 10.0
global_params.NORM = 1.2e5 ; **  /JANSKYS/Sr!   **
global_params.SMAX = 10.
global_params.SKY_AREA = 2.
global_params.SKY_UNITS = 'deg2'
global_params.FLUX_UNITS = 'ujy'
global_params.rms = 10.


;; Change the last two accordingly...
global_params.Smin = 0.05
global_params.alpha = -1.50


RMS = global_params.RMS
NSOURCE = get_nsource(_EXTRA=global_params)


randomp, S_TRUE, -1.50, NSOURCE, RANGE_X = $
         [global_params.smin, global_params.smax]
err = randomn( seed, NSOURCE ) * rms
S = S_TRUE + err


fluxbins = logbins(global_params.NBINS, $
                      global_params.minbin, $
                      global_params.maxbin)

b = bindata(fluxbins, S_true)
;ds = b[*,0]
ds = abs(deriv(b[*,2]))
dn = b[*,1]
meanbins = b[*,2]
dnds = dn / ds

bn = bindata(fluxbins, S)
;ds_n = bn[*,0]
ds_n = abs(deriv(bn[*,2]))
dn_n = bn[*,1]
dnds_n = dn_n / ds_n

v = bin_indices(fluxbins, S_TRUE)
vn = bin_indices(fluxbins, S)

means = fltarr(n_elements(fluxbins))
means_n = fltarr(n_elements(fluxbins))
for i = 0, n_elements(fluxbins)-2 do begin
   means[i] = mean(s_true[where(v eq i)])
   means_n[i] = mean(s[where(vn eq i)])
endfor


openw,f1,'$cts/simtable.tex', /GET_LUN
printf,f1,'\hline'
printf,f1,'\hline\\[-2ex]'
printf,f1,'Bin Width & $\langle$Bin$\rangle$ & $N$ & $N_{\sigma}$'+$
       '& $\langle S \rangle$ & $\langle S_{\sigma} \rangle$  & '+$
       '$\text{log_{10}}(dN/dS)$ & $\text{log_{10}}(dN/dS_{\sigma})$ '+$
       '\\ [1.6ex]',format='(1000A)'
printf, f1,'\hline'


;- DO LOG(DNDS)!!
dnds = alog10(dnds)
dnds_n = alog10(dnds_n)

;;- Make strarrys
len=3
d = strpos(strim(fluxbins),'.')
sbins = strim(fluxbins,l=len+d)
sbins = sbins[0,*]


FOR i = 0, n_elements(fluxbins) - 2 DO BEGIN
   d = strpos(strim(fluxbins[i]),'.')
   sbins = strim((fluxbins[i]),l=len+d-1)

   d = strpos(strim(fluxbins[i+1]),'.')
   sbins2 = strim((fluxbins[i+1]),l=len+d-1)

   sbins = sbins +'$-$'+sbins2

   d = strpos(strim(meanbins[i]),'.')
   smeanbins = strim(meanbins[i],l=len+d-1)

   d = strpos(strim(dn[i]),'.')
   sN = strim(dn[i],l=d)

   d = strpos(strim(dn_n[i]),'.')
   sNn = strim(dn_n[i],l=d)

   d = strpos(strim(dnds[i]),'.')
   sdnds = strim(dnds[i],l=d+len+1)

   d = strpos(strim(dnds_n[i]),'.')
   sdnds_n = strim(dnds_n[i],l=d+len+1)

   d = strpos(strim(means[i]),'.')
   smeans = strim(means[i],l=d+len)

   d = strpos(strim(means_n[i]),'.')
   smeans_n = strim(means_n[i],l=d+len)
   
   printf,f1,sbins+'..................... & '+smeanbins + ' & '+sN+$
          ' & '+sNn +' & '+smeans+' & '+smeans_n+' & '+$
          sdnds+' & '+sdnds_n+' \\ [0.2ex]', $
          format = '(1000A)'

ENDFOR
tot = total(dN)
d = strpos(strim(tot),'.')
stot = strim(tot,l=d)

tot2 = total(dN_n)
d = strpos(strim(tot2),'.')
stot2 = strim(tot2,l=d)

meantot = mean(means)
d = strpos(strim(meantot),'.')
smeantot = strim(meantot,l=d+len)

meantot2 = mean(means_n)
d = strpos(strim(meantot2),'.')
smeantot2 = strim(meantot2,l=d+len)

printf,f1,'Total & - & '+stot+' & '+stot2+' & '+smeantot+$
       ' & '+smeantot2+' &- &- \\ [0.2ex]',format='(1000A)'
printf,f1,'\hline'
close,/all
stop
END
