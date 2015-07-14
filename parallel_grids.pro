pro parallel_grids



global_params=define_global_params_grid()

minA = 1.
maxA = 2.
incrimentA = 0.01
Na = (maxA-minA) / incrimentA
Agrid = (findgen(Na+1) /(Na) * (maxA - minA) ) + minA
Agrid *= (-1)

minS = 0.1
maxS = 5.
incrimentS = 0.1
Ns = (maxS-minS) / incrimentS
Sgrid = (findgen(Ns+1) /(Ns) * (maxS - minS) ) + minS

;sgrid = [.6,0.7,0.8,0.9,1.,1.1,1.2,1.3,1.4]

minSx = 15.0
maxSx = 30.
incrimentSx = .5
Nsx = (maxSx-minSx) / incrimentSx
Sxgrid = (findgen(Nsx+1) /(Nsx) * (maxSx - minSx) ) + minSx

minN = 5e4
maxN = 5e5
incrimentN = 1e4
Nn = (maxN-minN) / incrimentN
Ngrid = (findgen(Nn+1) /(Nn) * (maxN - minN) ) + minN
;Ngrid = [.1,.2,.3,.4,.5,.6,.7,.8,.9,1.2,2,3,4,5,6,7]*1e6

NTOT = N_ELEMENTS(Agrid) * N_ELEMENTS(Sgrid) * $
       N_ELEMENTS(Ngrid) * N_ELEMENTS(Sxgrid)
IF NTOT eq 0 then message, 'wtf is wrong with your grids?'


;;- Make bins.                                    
IF KEYWORD_SET(LINEAR) THEN BEGIN
   fluxbins = linbins(global_params.NBINS, $
                      global_params.MINBIN,$
                      global_params.MAXBIN)
ENDIF ELSE BEGIN
   fluxbins = logbins(global_params.NBINS, $
                      global_params.MINBIN,$
                      global_params.MAXBIN)
ENDELSE
;;- Make a fake ("measured"), noise confused distribution (need k
;;  values).                        
;   Say distribution follows dN/dS = 1.2e5 S^-1.5                               
global_trueparams = global_params
global_trueparams.smax  = 20.0
global_trueparams.Smin  = 1.0
global_trueparams.alpha = -1.5
global_trueparams.Norm  = 1.2e5
trueN = get_nsource(_EXTRA=global_trueparams)
randomp, sim, global_trueparams.alpha, trueN, $
         RANGE_ = [global_trueparams.Smin, global_trueparams.Smax]
sim += (randomn(seed,trueN)*global_trueparams.rms)
res = bindata(fluxbins, sim)
global_params.kvals = res[*,1]
;-----------------------------------------------------------------


nthread = !CPU.HW_NCPU
thread_len = NTOT / nthread


;;- Call gridPar one time to estimate time until complete.
tstart=systime(/sec)
global_params.Agrid  = [Agrid[0]]
global_params.Ngrid  = [Ngrid[0]]
global_params.Sgrid  = [Sgrid[0]]
global_params.Sxgrid = [Sxgrid[0]]

tstart = systime(/sec)
global_params.num = 99
gridpar, _EXTRA=global_params
dt = (systime(/sec) - tstart) / 60.
time = dt * NTOT / nthread
MESSAGE, 'Estimated time until complete: '+strim(time,l=5) +' minutes.', /INF

pth = global_params.savedir
global_params.fluxbins = fluxbins


;;- Set up params for true analysis...
; Agrid is edited in the loop...
;newtags = ['ngrid','sgrid','sxgrid']
;newvals=[[Ngrid],[Sgrid],[Sxgrid]]
;add_tags, global_params, newtags, newvals
global_params.Ngrid  = [Ngrid]
global_params.Sgrid  = [Sgrid]
global_params.Sxgrid = [Sxgrid]

openw, 5, 'gridpar_script.pro'
printf,5, 'pro gridpar_script'
printf,5,' '

;;- Spilt up grids -- only have to split up one of them...
iterlen = N_elements(Agrid) / nthread
;nthread=2
FOR i = 0, nthread - 1 DO BEGIN
   
   ind = i * iterlen
   IF i eq nthread - 1 THEN $
      global_params.Agrid  = Agrid[ind:iterlen+ind] ELSE $       
         global_params.Agrid  = Agrid[ind:iterlen+ind-1]

   global_params.num = i
   ii = strim(long(i))
   save, global_params,filename=global_params.savedir+'gparams'+$
         strim(long(i))+'.sav'

   printf,5, "restore, '"+global_params.savedir+'gparams'+ii+".sav'"
   printf,5, 'pth = global_params.savedir'
   printf,5, 'obridge'+ii+' = obj_new("IDL_IDLBridge",output="")'
   printf,5, 'obridge'+ii+"->setvar,'pth',pth"
   printf,5, 'obridge'+ii+"->execute,'!path += pth'"
   printf,5, 'obridge'+ii+"->execute, '@' + PREF_GET('IDL_STARTUP')"
   printf,5, 'obridge'+ii+'->execute, "cd,'+"'"+ !CODEDIR + "'"+'"'
   printf,5, 'struct_pass, global_params, obridge'+ii
   printf,5, 'obridge'+ii+'->execute, "t=erf(1)"'
   printf,5, 'obridge'+ii+"->execute,'gridpar, _EXTRA=global_params',/nowait "
   printf,5, 'WAIT, 10.'
;   printf,5, "st = ''"
;   printf,5, 'read,st,prompt=" ... "'
;   printf,5, "IF STRUPCASE(st) EQ 'Q' THEN BEGIN"
;   printf,5, '   obj_destroy,/all & STOP'
;   printf,5, 'ENDIF'
   printf,5, 'status'+ii+'=obridge'+ii+'->status()'
   printf,5,'  '
   
ENDFOR

FOR i = 0, ii DO BEGIN
   IF i eq 0 THEN BEGIN
      printf,5,'WHILE (status'+strim(long(i))+' NE 0) AND $'
   ENDIF ELSE IF i LT (ii) THEN BEGIN
      printf,5,'     (status'+strim(long(i))+' NE 0) AND $'
   ENDIF ELSE BEGIN
      printf,5, '     (status'+strim(long(i))+' NE 0) DO BEGIN'
   ENDELSE
ENDFOR
FOR i = 0, ii DO BEGIN
   printf,5,'   status'+strim(long(i))+'=obridge'+strim(long(i))+'->status()'
   IF i EQ (ii) THEN PRINTF,5,'ENDWHILE'
ENDFOR
printf,5,' '
printf,5,'end'
close,5
;stop

END
