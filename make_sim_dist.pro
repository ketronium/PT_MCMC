PRO make_sim_dist, LINEAR=LINEAR, VERBOSE=VERBOSE


;+
;
; This will generate a simulated dN/dS distribution
; given the parameters in the global structure. 
; Setting /LOG will do the analysis with log binning;
; linear by default.
;
;-


;;- Size of array used to generate P(N) at each bin.
N_ITER = 1e4 
VERB = KEYWORD_SET(VERBOSE)
dir = '$cts/'
datadir = '$cts/';'$cts/simcheck/'


global_params = define_global_params()
;; Change the four unknowns accordingly...
global_params.alpha = -1.50
global_params.Smin  = 1.0
global_params.smax  = 15.0
global_params.NORM  = 40. ; **  /JANSKYS/deg^2   **
global_params.NBINS=10
global_params.minbin=1.0
global_params.maxbin=20.0

;;- force a normalization using dn/ds=1.2e5 S^-1.5 at the max bin.
;global_params = force_normalization(_extra=global_params)
NSOURCE = get_nsource(_EXTRA=global_params)

IF keyword_set(LINEAR) THEN BEGIN
   fluxbins = linbins(global_params.NBINS, $
                      global_params.minbin, $
                      global_params.maxbin) 
ENDIF ELSE BEGIN
   fluxbins = logbins(global_params.NBINS, $
                      global_params.minbin, $
                      global_params.maxbin) 
ENDELSE


files_there = file_search(datadir+'*')
IF VERB THEN BEGIN
   message,'Using '+ strim(global_params.NBINS) + ' BINS', /INF
   message, 'FLUXBINS = ', /INF
   print, fluxbins
   message,'RMS = '+strim(global_params.RMS), /INF
   message, 'Using '+strim(round(NSOURCE)) + ' sources for '+$
            strim(global_params.Smin)+' < S < '+$
            strim(global_params.SMAX), /INF
   message, 'Analysis over ' + strim(global_params.sky_area)+$
            ' '+strim(global_params.sky_units),/INF
ENDIF


;Put various stuff to keep track of in struct1
struct1 = {fluxbins:fltarr(global_params.NBINS)} 
struct1.fluxbins = fluxbins


;;- Set up pointer to keep track of stuff.
PTR = PTRARR(N_ITER+1,/ALLOCATE_HEAP)
*PTR[0] = struct1
PSTRUCT = {dn:fltarr(global_params.NBINS)}


fname = '_alpha'+strim(global_params.alpha, l=5) + $
         '_Smin'+strim(global_params.Smin,  l=5) + $
         '_Smax'+strim(global_params.SMAX,  l=5) + $
         '_C' +  strim(global_params.norm, l=11)              

tstart = systime(/SEC)
trueN = NSOURCE
FOR i = 0L, N_ITER - 1 DO BEGIN
   NSOURCE = randomn(seed,1,POISSON=TRUEN)

   randomp, sim, global_params.alpha, NSOURCE, $
            RANG = [global_params.SMIN, global_params.smax]

   sim += ( randomn(seed, NSOURCE) * global_params.RMS )

   res = bindata(fluxbins, sim)
   ds = abs(deriv(res[*,2]))
   dn = res[*,1]

   pstruct.dn = dn

   (*ptr[i+1]) = pstruct 

   IF VERB THEN BEGIN
      IF (i EQ 0) THEN BEGIN
         dt = (systime(/sec) - tstart) / 60.
         time = dt * N_ITER 
         MESSAGE, 'Estimated time until complete: '+$
                  strim(time,l=5) +' minutes.', /INF
      ENDIF
      IF (i MOD 500 EQ 0) THEN BEGIN
         c = (float(i) / float(N_ITER)) * 100.
         c = string(c)
         p = strpos(c,'.')
         strc = strtrim(strmid(c,0,p+2),2)
         message, strc+'%',/INF        
      ENDIF

   ENDIF
ENDFOR


save, PTR, filename = $
      datadir+'ptr_sig'+$
      strim(global_params.rms,len=4)+$
      fname+'.sav'


tend = systime(/sec)
min = (tend - tstart) / 60.
MESSAGE, 'T = '+strim(min)+' minutes', /INF


END
