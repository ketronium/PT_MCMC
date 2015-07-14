PRO make_sim_dist_grid, LINEAR=LINEAR, VERBOSE=VERBOSE


;+
;
; This will generate a simulated dN/dS distribution
; given the parameters in the global structure. 
; Setting /LINEAR will do the analysis with log binning;
; linear by default.
;
;-


;;- Size of array used to generate P(N) at each bin.
N_ITER = 5e4 
VERB = KEYWORD_SET(VERBOSE)
dir = '$cts/'
datadir = '$cts/pdata/';'$cts/simcheck/'

;global_params = make_global_structure()
;global_params.NBINS=10
;global_params.MINBIN = 0.1
;global_params.MAXBIN = 10.0
;global_params.NORM = 1.2e5 ; **  /JANSKYS/Sr!   **
;global_params.SMAX = 10.
;global_params.SKY_AREA = 2.
;global_params.SKY_UNITS = 'deg2'
;global_params.FLUX_UNITS = 'ujy'
;global_params.rms = 10.

global_params = define_global_params()


;; Change the last two accordingly...
global_params.Smin = 0.5
global_params.alpha = -1.50


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
   message, 'Using '+strim(NSOURCE) + ' sources for '+$
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


;;- make grids for alpha and Smin:
alpha_grid = (-1) * ((findgen(76))/50 + 1.0)
Smin_grid = (findgen(10)/10) +.1
NTOT = N_ELEMENTS(alpha_grid) * N_ELEMENTS(Smin_grid)


tstart = systime(/SEC)
tcount = 0
FOR AG = 0, N_ELEMENTS(alpha_grid) - 1 DO BEGIN
   global_params.alpha = alpha_grid[AG]

   FOR SG = 0, N_ELEMENTS(Smin_grid) - 1 DO BEGIN
      global_params.Smin = Smin_grid[SG]
      
      fname = '_alpha'+strim(global_params.alpha, l=5) + $
              '_Smin'+strim(global_params.Smin,l=5)+$
              '_Smax'+strim(global_params.SMAX,l=5)
      
      FOR i = 0L, N_ITER - 1 DO BEGIN
         NSOURCE = get_nsource(_EXTRA=global_params)
         
         IF NSOURCE LE 10. THEN BEGIN
            MESSAGE, 'Not enough sources for this alpha (' + $
                     strim(alpha) + ') and Smin (' + $
                     strim(global_params.Smin) +'; try increasing the '+$
                     'sky area. Skipping this iteration.', /INF
            CONTINUE
         ENDIF
         
         randomp, sim, global_params.alpha, NSOURCE, $
                  RANG = [global_params.SMIN, global_params.smax]
         
         sim += ( randomn(seed, NSOURCE) * global_params.RMS )
         
         res = bindata(fluxbins, sim)
         if res[0] eq 1 then begin
            message, "something's fucked here...",/INF
            continue
         endif

         ds = abs(deriv(res[*,2]))
         dn = res[*,1]

         pstruct.dn = dn
         
         (*ptr[i+1]) = pstruct 
         
      ENDFOR
      save, PTR, filename = $
            datadir+'ptr_sig'+$
            strim(global_params.rms,len=4)+$
            fname+'.sav'      

      IF VERB THEN BEGIN
         IF (i MOD 5 EQ 0) THEN BEGIN
            c = (float(tcount) / float(N_ITER)) * 100.
            c = string(c)
            p = strpos(c,'.')
            strc = strtrim(strmid(c,0,p+2),2)
            message, strc+'%',/INF        
         ENDIF      
      ENDIF

      IF (AG EQ 0) AND (SG EQ 0) THEN BEGIN
         dt = ( systime(/sec) - tstart ) * NTOT / 3600.
         message, 'Approximate time to completion is '+$
                  strim(dt,len=4)+' hours.',/INF
      ENDIF 
      tcount+=1        
   ENDFOR
ENDFOR



tend = systime(/sec)
min = (tend - tstart) / 60.
MESSAGE, 'T = '+strim(min)+' minutes', /INF


END
