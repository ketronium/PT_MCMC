PRO mcmc_pt, CHECK=CHECK, $
             PARAM_FILE=PARAM_FILE,$
             SAVE_ALL=SAVE_ALL
             


;+
;
; Parallel tempering of 6 chains. This basically just keeps
; track of the swapping and writes the first chain to disk. 
; Probabilities are calculated in mcmc_swap.pro (which is 
; basically just a Metropolis-Hastings MCMC algorithm). This
; version is for the SIMULATIONS. If you want to run the method
; on a real data set, run mcmc_pt_vla.pro.
;
; INPUTS:
;
;     -CHECK: Prints parameters of first chain to the screen,
;             so as to check the sampling/obvious computation errors.
;
;     -PARAM_FILE: name of file containing MCMC parameters. mcmc.param
;                  by default.
;
;     -SAVE_ALL: set this if you want to save all the chains. In doing
;                so, you should also set beta_min = beta_max = 1.0,
;                and N_SWAP = NITER. In this way the code effectively
;                becomes a Metropolis-Hastings algorithm and 6 chains
;                will be run in parallel.
;
;
; Ketron 12/2012
;
;-


COMPILE_OPT HIDDEN


;;- Set up the global structure
IF (n_elements(PARAM_FILE) EQ 0) THEN PARAM_FILE = 'mcmc.param'
global_params = define_global_params(PARAM_FILE)


;;- Parameter checks
N_SWAP = global_params.n_swap
NITER = global_params.niter
INTEGRAL_RESOLUTION = global_params.integral_resolution
IF (N_swap EQ 0) THEN                           N_SWAP = 1000. 
IF (NITER EQ 0) THEN                             NITER = 1e5
IF (INTEGRAL_RESOLUTION EQ 0) THEN INTEGRAL_RESOLUTION = 7e3 
IF N_ELEMENTS(SWAP_SENSITIVE) EQ 0 THEN SWAP_SENSITIVE = 1.0
IF ((SWAP_SENSITIVE GT 1.0) OR (SWAP_SENSITIVE LE 0.0)) THEN $
   MESSAGE, 'The SWAP_SENSITIVE keyword must be > 0.0 and < 1.0.'
IF keyword_set(SAVE_ALL) THEN BEGIN
   IF total(global_params.beta_max) NE 1.0 THEN message, $
      "You've requested to save all the chains, but your beta_max "+$
      "is not set to 1.0."
ENDIF
IF global_params.beta_max NE 1.0 THEN message, 'Your first chain '+$
   'does not have beta = 1.0'
IF N_SWAP LE global_params.NBINS-1 THEN message, 'N_SWAP must be >= NBINS.'

pth = global_params.savedir
IF keyword_set(VARY_RMS) THEN BEGIN
   global_params.vary_rms = 1L
   message,'Varying the rms.', /INF
ENDIF

IF (strupcase(global_params.linear) EQ 'TRUE') THEN BEGIN
   fluxbins = linbins(global_params.NBINS, $
                      global_params.MINBIN,$
                      global_params.MAXBIN)
ENDIF ELSE BEGIN
   fluxbins = logbins(global_params.NBINS, $
                      global_params.MINBIN,$
                      global_params.MAXBIN)
ENDELSE
global_params.fluxbins = fluxbins


;;-----------------------------------------------------
;;- Make SIMULATED DISTRIBUTION -- a fake ("measured"), 
;;  noise confused distribution (need k values). trueN needs
;; to be resampled (gaussian & poisson) at each iteration.
global_trueparams = define_global_params(PARAM_FILE)  

;;**** TRUE PARAMETER VALUES: 
global_trueparams.Smin = 1.0
global_trueparams.alpha = -1.5
global_trueparams.norm = 40. 
global_trueparams.smax = 20.0
global_trueparams.fluxbins = fluxbins
trueN = get_nsource(_EXTRA=global_trueparams)

randomp, sim, global_trueparams.alpha, trueN, $
               RANGE_ = [global_trueparams.Smin, global_trueparams.Smax]

sim += (randomn(seed, trueN)*global_trueparams.rms)
sim = sim[where( (sim GT global_trueparams.minbin) AND $
          (sim LT global_trueparams.maxbin))]
res = bindata(fluxbins, sim)
kvals = res[*,1]
;;-----------------------------------------------------


;;- Initialize chains
betas = linbins(6, global_params.beta_max, global_params.beta_min)
alphas = global_params.alphas
smins =  global_params.smins
smaxs =  global_params.smaxs
norms =  global_params.norms
;alphas = shift(alphas,1)*.9
;smins = shift(smins,1)*.9
;smaxs =  shift(smaxs,1)*.9
;norms = shift(norms,1)*.9
cptr = init_chains(alphas, smins, smaxs, norms, betas, $
                   N_SWAP=N_SWAP, NITER=NITER,$
                   INTEGRAL_RESOLUTION=INTEGRAL_RESOLUTION,$
                   FLUXBINS=FLUXBINS,$
                   KVALS=KVALS, PARAM_FILE=param_file)
gp1 = *cptr[0] & gp2 = *cptr[1]
gp3 = *cptr[2] & gp4 = *cptr[3] 
gp5 = *cptr[4] & gp6 = *cptr[5]


;;- Shrink proposal distributions.
gp1.adaptA  *= global_params.WIDTH_A1
gp1.adaptS  *= global_params.WIDTH_S1
gp1.adaptSx *= global_params.WIDTH_SX1
gp1.adaptN  *= global_params.WIDTH_C1

gp2.adaptA  *= global_params.WIDTH_A2
gp2.adaptS  *= global_params.WIDTH_S2
gp2.adaptSx *= global_params.WIDTH_SX2
gp2.adaptN  *= global_params.WIDTH_C2


IF keyword_set(CHECK) THEN gp1.check = 1L


;;- PT INIT
converged = 0L
ct = 0
NLOOP = floor(float(NITER)/float(n_swap))
global_count = 0
area = strim(long(strim(global_trueparams.sky_area,l=4)))

IF keyword_set(SAVE_ALL) THEN nameloop = 6 ELSE nameloop = 1
FOR jkl = 1, nameloop DO BEGIN
   r = string(randomn(seed,1)*1d)
   p = strpos(r,'.')
   randstr = strmid(r, p+1, 6)
   CASE jkl OF
      1: BEGIN
         name1 = !SAVEDIR+'chain' + area +'-' + $
                 randstr + '.txt'
         openw, f1, name1, /GET_LUN
         printf, f1,'#alpha    smin      smax       C'
         printf, f1,'#-----------------------------------'
         close,f1
      END
      2: BEGIN
         name2 =  !SAVEDIR+'chain' + area +'-' + $
                  randstr + '.txt'
         openw, f2, name2, /GET_LUN
         printf, f2,'#alpha    smin      smax       C'
         printf, f2,'#-----------------------------------'
         close,f2
      END
      3: BEGIN
         name3 = !SAVEDIR+'chain' + area +'-' + $
                 randstr + '.txt'
         openw, f3, name3, /GET_LUN
         printf, f3,'#alpha    smin      smax       C'
         printf, f3,'#-----------------------------------'
         close,f3
      END
      4: BEGIN
         name4 = !SAVEDIR+'chain' + area +'-' + $
                 randstr + '.txt'
         openw, f4, name4, /GET_LUN
         printf, f4,'#alpha    smin      smax       C'
         printf, f4,'#-----------------------------------'
         close,f4
      END
      5: BEGIN
         name5 = !SAVEDIR+'chain' + area +'-' + $
                 randstr + '.txt'
         openw, f5, name5, /GET_LUN
         printf, f5,'#alpha    smin      smax       C'
         printf, f5,'#-----------------------------------'
         close,f5
      END
      6:BEGIN
         name6 = !SAVEDIR+'chain' + area +'-' + $
                 randstr + '.txt'
         openw, f6, name6, /GET_LUN
         printf, f6,'#alpha    smin      smax       C'
         printf, f6,'#-----------------------------------'
         close,f6
      END
   ENDCASE
ENDFOR


i=0L
sreject = 0 & saccept = 0


WHILE i LT NITER DO BEGIN

   IF (i EQ N_SWAP) THEN tstart = systime(/sec)

   ;;- CHAIN 1. Beta = 1.0 (i.e. proposal 
   ;; distribution is the true distribution).
   obridge = obj_new("IDL_IDLBridge",output='')
   obridge->setvar,'pth',pth
   obridge->execute,'!path += pth'
   obridge->execute, '@' + PREF_GET('IDL_STARTUP')
   obridge->execute,"cd, " + "'" + !CODEDIR + "'"
   struct_pass, gp1, obridge
   obridge->execute,'c1 = mcmc_swap( _EXTRA=gp1 )',/nowait 
   status1=obridge->status()
   

   ;;- CHAIN 2
   obridge2 = obj_new("IDL_IDLBridge", output='')
   obridge2->setvar,'pth',pth
   obridge2->execute,'!path += pth'
   obridge2->execute, '@' + PREF_GET('IDL_STARTUP')
   obridge2->execute,"cd, " + "'" + !CODEDIR + "'"
   struct_pass, gp2, obridge2
   obridge2->execute,'c2 = mcmc_swap( _EXTRA=gp2 )',/nowait 
   status2=obridge2->status()

   
   ;;- CHAIN 3                          
   obridge3 = obj_new("IDL_IDLBridge", output='')
   obridge3->setvar,'pth',pth
   obridge3->execute,'!path += pth'
   obridge3->execute, '@' + PREF_GET('IDL_STARTUP')
   obridge3->execute,"cd, " + "'" + !CODEDIR + "'"
   struct_pass, gp3, obridge3
   obridge3->execute,'c3 = mcmc_swap( _EXTRA=gp3 )',/nowait
   status3=obridge3->status()

   
   ;;- CHAIN 4                                                
   obridge4 = obj_new("IDL_IDLBridge", output='')
   obridge4->setvar,'pth',pth
   obridge4->execute,'!path += pth'
   obridge4->execute, '@' + PREF_GET('IDL_STARTUP')
   obridge4->execute,"cd, " + "'" + !CODEDIR + "'"
   struct_pass, gp4, obridge4
   obridge4->execute,'c4 = mcmc_swap( _EXTRA=gp4 )',/nowait
   status4=obridge4->status()


   ;;- CHAIN 5                                                
   obridge5 = obj_new("IDL_IDLBridge", output='')
   obridge5->setvar,'pth',pth
   obridge5->execute,'!path += pth'
   obridge5->execute, '@' + PREF_GET('IDL_STARTUP')
   obridge5->execute,"cd, " + "'" + !CODEDIR + "'"
   struct_pass, gp5, obridge5
   obridge5->execute,'c5 = mcmc_swap( _EXTRA=gp5 )',/nowait
   status5=obridge5->status()


   ;;- CHAIN 6                                                
   obridge6 = obj_new("IDL_IDLBridge", output='')
   obridge6->setvar,'pth',pth
   obridge6->execute,'!path += pth'
   obridge6->execute, '@' + PREF_GET('IDL_STARTUP')
   obridge6->execute,"cd, " + "'" + !CODEDIR + "'"
   struct_pass, gp6, obridge6
   obridge6->execute,'c6 = mcmc_swap( _EXTRA=gp6 )',/nowait
   status6=obridge6->status()

 
   ;;- Wait here until all the child processes are done.
   WHILE (status1 NE 0) OR (status2 NE 0) OR $
      (status3 NE 0) OR (status4 NE 0) OR $
      (status5 NE 0) OR (status6 NE 0) DO BEGIN

      status1 =  obridge->status()
      status2 = obridge2->status()
      status3 = obridge3->status()
      status4 = obridge4->status()
      status5 = obridge5->status()
      status6 = obridge6->status()

   ENDWHILE


   chain1 = oBridge->GetVar('c1')  
   chain2 = obridge2->GetVar('c2')
   chain3 = obridge3->GetVar('c3')
   chain4 = obridge4->GetVar('c4')
   chain5 = obridge5->GetVar('c5')
   chain6 = obridge6->GetVar('c6')
   OBJ_DESTROY, obridge 
   OBJ_DESTROY, obridge2 
   OBJ_DESTROY, obridge3 
   OBJ_DESTROY, obridge4
   OBJ_DESTROY, obridge5
   OBJ_DESTROY, obridge6
   
   
   khere = gp1.NBINS-2
   gp1.kvals = chain1[0:khere, 5]
   gp2.kvals = chain2[0:khere, 5]
   gp3.kvals = chain3[0:khere, 5]
   gp4.kvals = chain4[0:khere, 5]
   gp5.kvals = chain5[0:khere, 5]
   gp6.kvals = chain6[0:khere, 5]
       

   ;;- Propose a swap.
   U1 = randomu(seed)
   IF (U1 LE SWAP_SENSITIVE) THEN BEGIN

      ;;- Swapping
      U2 = ceil(randomu(seed)*5) ;6 chains
      U3 = randomu(seed)
      CASE U2 OF
         1: BEGIN
            ;;- First check if the likelihood of the first is higer
            ;;  than the second. If not, compute the swap ratio.
            r = get_pt_ratio(gp1, gp2)
            IF ( U3 LE r ) THEN BEGIN
               gp1.alpha = chain2[(N_swap-1),0]
               gp1.smin  = chain2[(N_swap-1),1]
               gp1.smax  = chain2[(N_swap-1),2]
               gp1.norm  = chain2[(N_swap-1),3]
               
               gp2.alpha = chain1[(N_swap-1),0]
               gp2.smin  = chain1[(N_swap-1),1]
               gp2.smax  = chain1[(N_swap-1),2]
               gp2.norm  = chain1[(N_swap-1),3]
               print, 'swapping: 1 <=> 2'
;               print, 'L chain1: ',chain1[0,4]
;               print, 'L chain2: ',chain2[0,4]
               
               ;;- What is the probability of the new parameters,
               ;; for the true distribution (beta=1.)
               chain1[0,4] = compute_likelihood(fluxbins, _EXTRA=gp1)
               chain2[0,4] = compute_likelihood(fluxbins, _EXTRA=gp2)
               saccept += 1 
            ENDIF ELSE BEGIN
               ;;- structures are passed back to children -- need to edit
               ;;  parameters to be consistent with last loop in
               ;;  mcmc_swap.                   
               ;;- Unswapped:  
               gp1.alpha = chain1[(N_swap-1),0]
               gp1.smin  = chain1[(N_swap-1),1]
               gp1.smax  = chain1[(N_swap-1),2]
               gp1.norm  = chain1[(N_swap-1),3]
               
               gp2.alpha = chain2[(N_swap-1),0]
               gp2.smin  = chain2[(N_swap-1),1]
               gp2.smax  = chain2[(N_swap-1),2]
               gp2.norm  = chain2[(N_swap-1),3]
            ENDELSE
            ;;- Last four have to be updated regardless of swap.
            gp3.alpha = chain3[(N_swap-1),0]
            gp3.smin  = chain3[(N_swap-1),1]
            gp3.smax  = chain3[(N_swap-1),2]
            gp3.norm  = chain3[(N_swap-1),3] 
            
            gp4.alpha = chain4[(N_swap-1),0]
            gp4.smin  = chain4[(N_swap-1),1]
            gp4.smax  = chain4[(N_swap-1),2]
            gp4.norm  = chain4[(N_swap-1),3]
            
            gp5.alpha = chain5[(N_swap-1),0]
            gp5.smin  = chain5[(N_swap-1),1]
            gp5.smax  = chain5[(N_swap-1),2]
            gp5.norm  = chain5[(N_swap-1),3] 
            
            gp6.alpha = chain6[(N_swap-1),0]
            gp6.smin  = chain6[(N_swap-1),1]
            gp6.smax  = chain6[(N_swap-1),2]
            gp6.norm  = chain6[(N_swap-1),3]

         END
         2: BEGIN
            r = get_pt_ratio(gp2, gp3)
            IF ( U3 LE r ) THEN BEGIN
               gp2.alpha = chain3[(N_swap-1),0]
               gp2.smin  = chain3[(N_swap-1),1]
               gp2.smax  = chain3[(N_swap-1),2]
               gp2.norm  = chain3[(N_swap-1),3]
               
               gp3.alpha = chain2[(N_swap-1),0]
               gp3.smin  = chain2[(N_swap-1),1]
               gp3.smax  = chain2[(N_swap-1),2]
               gp3.norm  = chain2[(N_swap-1),3]
               print, 'swapping: 2 <=> 3'

               chain2[0,4] = compute_likelihood(fluxbins, _EXTRA=gp2)
               chain3[0,4] = compute_likelihood(fluxbins, _EXTRA=gp3)

               saccept += 1 
            ENDIF ELSE BEGIN
               ;;- Unswapped:
               gp2.alpha = chain2[(N_swap-1),0]
               gp2.smin  = chain2[(N_swap-1),1]
               gp2.smax  = chain2[(N_swap-1),2]
               gp2.norm  = chain2[(N_swap-1),3]                    
               
               gp3.alpha = chain3[(N_swap-1),0]
               gp3.smin  = chain3[(N_swap-1),1]
               gp3.smax  = chain3[(N_swap-1),2]
               gp3.norm  = chain3[(N_swap-1),3]
            ENDELSE
            
            gp1.alpha = chain1[(N_swap-1),0]
            gp1.smin  = chain1[(N_swap-1),1]
            gp1.smax  = chain1[(N_swap-1),2]
            gp1.norm  = chain1[(N_swap-1),3]
            
            gp4.alpha = chain4[(N_swap-1),0]
            gp4.smin  = chain4[(N_swap-1),1]
            gp4.smax  = chain4[(N_swap-1),2]
            gp4.norm  = chain4[(N_swap-1),3]

            gp5.alpha = chain5[(N_swap-1),0]
            gp5.smin  = chain5[(N_swap-1),1]
            gp5.smax  = chain5[(N_swap-1),2]
            gp5.norm  = chain5[(N_swap-1),3] 
            
            gp6.alpha = chain6[(N_swap-1),0]
            gp6.smin  = chain6[(N_swap-1),1]
            gp6.smax  = chain6[(N_swap-1),2]
            gp6.norm  = chain6[(N_swap-1),3]
         END
         3: BEGIN
            r = get_pt_ratio(gp3, gp4)
            IF ( U3 LE r ) THEN BEGIN
               gp3.alpha = chain4[(N_swap-1),0]
               gp3.smin  = chain4[(N_swap-1),1]
               gp3.smax  = chain4[(N_swap-1),2]
               gp3.norm  = chain4[(N_swap-1),3]
               
               gp4.alpha = chain3[(N_swap-1),0]
               gp4.smin  = chain3[(N_swap-1),1]
               gp4.smax  = chain3[(N_swap-1),2]
               gp4.norm  = chain3[(N_swap-1),3]
               print, 'swapping: 3 <=> 4'
               
               chain3[0,4] = compute_likelihood(fluxbins, _EXTRA=gp3)
               chain4[0,4] = compute_likelihood(fluxbins, _EXTRA=gp4)

               saccept += 1 
            ENDIF ELSE BEGIN
               ;;- Unswapped:
               gp3.alpha = chain3[(N_swap-1),0]
               gp3.smin  = chain3[(N_swap-1),1]
               gp3.smax  = chain3[(N_swap-1),2]
               gp3.norm  = chain3[(N_swap-1),3]
               
               gp4.alpha = chain4[(N_swap-1),0]
               gp4.smin  = chain4[(N_swap-1),1]
               gp4.smax  = chain4[(N_swap-1),2]
               gp4.norm  = chain4[(N_swap-1),3]
            ENDELSE   
            
            gp1.alpha = chain1[(N_swap-1),0]
            gp1.smin  = chain1[(N_swap-1),1]
            gp1.smax  = chain1[(N_swap-1),2]
            gp1.norm  = chain1[(N_swap-1),3]
            
            gp2.alpha = chain2[(N_swap-1),0]
            gp2.smin  = chain2[(N_swap-1),1]
            gp2.smax  = chain2[(N_swap-1),2]
            gp2.norm  = chain2[(N_swap-1),3]

            gp5.alpha = chain5[(N_swap-1),0]
            gp5.smin  = chain5[(N_swap-1),1]
            gp5.smax  = chain5[(N_swap-1),2]
            gp5.norm  = chain5[(N_swap-1),3] 
            
            gp6.alpha = chain6[(N_swap-1),0]
            gp6.smin  = chain6[(N_swap-1),1]
            gp6.smax  = chain6[(N_swap-1),2]
            gp6.norm  = chain6[(N_swap-1),3]
         END
         4: BEGIN
            r = get_pt_ratio(gp4, gp5)
            IF ( U3 LE r ) THEN BEGIN
               gp4.alpha = chain5[(N_swap-1),0]
               gp4.smin  = chain5[(N_swap-1),1]
               gp4.smax  = chain5[(N_swap-1),2]
               gp4.norm  = chain5[(N_swap-1),3]

               gp5.alpha = chain4[(N_swap-1),0]
               gp5.smin  = chain4[(N_swap-1),1]
               gp5.smax  = chain4[(N_swap-1),2]
               gp5.norm  = chain4[(N_swap-1),3]
               print, 'swapping: 4 <=> 5'
               
               chain4[0,4] = compute_likelihood(fluxbins, _EXTRA=gp4)
               chain5[0,4] = compute_likelihood(fluxbins, _EXTRA=gp5)

               saccept += 1 
            ENDIF ELSE BEGIN
               ;;- Unswapped:
               gp4.alpha = chain4[(N_swap-1),0]
               gp4.smin  = chain4[(N_swap-1),1]
               gp4.smax  = chain4[(N_swap-1),2]
               gp4.norm  = chain4[(N_swap-1),3]

               gp5.alpha = chain5[(N_swap-1),0]
               gp5.smin  = chain5[(N_swap-1),1]
               gp5.smax  = chain5[(N_swap-1),2]
               gp5.norm  = chain5[(N_swap-1),3]
            ENDELSE   
            
            gp1.alpha = chain1[(N_swap-1),0]
            gp1.smin  = chain1[(N_swap-1),1]
            gp1.smax  = chain1[(N_swap-1),2]
            gp1.norm  = chain1[(N_swap-1),3]
            
            gp2.alpha = chain2[(N_swap-1),0]
            gp2.smin  = chain2[(N_swap-1),1]
            gp2.smax  = chain2[(N_swap-1),2]
            gp2.norm  = chain2[(N_swap-1),3]

            gp3.alpha = chain3[(N_swap-1),0]
            gp3.smin  = chain3[(N_swap-1),1]
            gp3.smax  = chain3[(N_swap-1),2]
            gp3.norm  = chain3[(N_swap-1),3]
            
            gp6.alpha = chain6[(N_swap-1),0]
            gp6.smin  = chain6[(N_swap-1),1]
            gp6.smax  = chain6[(N_swap-1),2]
            gp6.norm  = chain6[(N_swap-1),3]
         END
         5: BEGIN
            r = get_pt_ratio(gp5, gp6)
            IF ( U3 LE r ) THEN BEGIN
               gp5.alpha = chain6[(N_swap-1),0]
               gp5.smin  = chain6[(N_swap-1),1]
               gp5.smax  = chain6[(N_swap-1),2]
               gp5.norm  = chain6[(N_swap-1),3]
               
               gp6.alpha = chain5[(N_swap-1),0]
               gp6.smin  = chain5[(N_swap-1),1]
               gp6.smax  = chain5[(N_swap-1),2]
               gp6.norm  = chain5[(N_swap-1),3]
               print, 'swapping: 5 <=> 6'
               
               chain5[0,4] = compute_likelihood(fluxbins, _EXTRA=gp5)
               chain6[0,4] = compute_likelihood(fluxbins, _EXTRA=gp6)

               saccept += 1 
            ENDIF ELSE BEGIN
               ;;- Unswapped:
               gp5.alpha = chain5[(N_swap-1),0]
               gp5.smin  = chain5[(N_swap-1),1]
               gp5.smax  = chain5[(N_swap-1),2]
               gp5.norm  = chain5[(N_swap-1),3]
               
               gp6.alpha = chain6[(N_swap-1),0]
               gp6.smin  = chain6[(N_swap-1),1]
               gp6.smax  = chain6[(N_swap-1),2]
               gp6.norm  = chain6[(N_swap-1),3]
            ENDELSE   
            
            gp1.alpha = chain1[(N_swap-1),0]
            gp1.smin  = chain1[(N_swap-1),1]
            gp1.smax  = chain1[(N_swap-1),2]
            gp1.norm  = chain1[(N_swap-1),3]
            
            gp2.alpha = chain2[(N_swap-1),0]
            gp2.smin  = chain2[(N_swap-1),1]
            gp2.smax  = chain2[(N_swap-1),2]
            gp2.norm  = chain2[(N_swap-1),3]

            gp3.alpha = chain3[(N_swap-1),0]
            gp3.smin  = chain3[(N_swap-1),1]
            gp3.smax  = chain3[(N_swap-1),2]
            gp3.norm  = chain3[(N_swap-1),3]
            
            gp4.alpha = chain4[(N_swap-1),0]
            gp4.smin  = chain4[(N_swap-1),1]
            gp4.smax  = chain4[(N_swap-1),2]
            gp4.norm  = chain4[(N_swap-1),3]
         END
         ELSE: MESSAGE, 'Problem with the second uniform random '+$
                        'distribution. '
      ENDCASE
   ENDIF ELSE BEGIN ;;- NO SWAP -- just update the global 
                    ;; structures and continue MCMC.
      gp1.alpha = chain1[(N_swap-1),0]
      gp1.smin  = chain1[(N_swap-1),1]
      gp1.smax  = chain1[(N_swap-1),2]
      gp1.norm  = chain1[(N_swap-1),3]
      
      gp2.alpha = chain2[(N_swap-1),0]
      gp2.smin  = chain2[(N_swap-1),1]
      gp2.smax  = chain2[(N_swap-1),2]
      gp2.norm  = chain2[(N_swap-1),3]
      
      gp3.alpha = chain3[(N_swap-1),0]
      gp3.smin  = chain3[(N_swap-1),1]
      gp3.smax  = chain3[(N_swap-1),2]
      gp3.norm  = chain3[(N_swap-1),3] 

      gp4.alpha = chain4[(N_swap-1),0]
      gp4.smin  = chain4[(N_swap-1),1]
      gp4.smax  = chain4[(N_swap-1),2]
      gp4.norm  = chain4[(N_swap-1),3]

      gp5.alpha = chain5[(N_swap-1),0]
      gp5.smin  = chain5[(N_swap-1),1]
      gp5.smax  = chain5[(N_swap-1),2]
      gp5.norm  = chain5[(N_swap-1),3]

      gp6.alpha = chain6[(N_swap-1),0]
      gp6.smin  = chain6[(N_swap-1),1]
      gp6.smax  = chain6[(N_swap-1),2]
      gp6.norm  = chain6[(N_swap-1),3]
      sreject += 1
   ENDELSE

   
   ;;- Only keep values from the chain which 
   ;; samples from the true distribution.
   Akeep  = reform( chain1[*,0] )
   Skeep  = reform( chain1[*,1] )
   Sxkeep = reform( chain1[*,2] )
   Nkeep  = reform( chain1[*,3] )


;   IF gp1.global_count NE 0 THEN BEGIN
   IF keyword_set(SAVE_ALL) THEN BEGIN
      openw, f1, name1, /APPEND
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f1, $
         strim(Akeep[ii],l=8)  + '  ' + $
         strim(Skeep[ii],l=8)  + '  ' + $
         strim(Sxkeep[ii],l=8) + '  ' + $
         strim(Nkeep[ii],l=8), $
         format = '(5000A)'
      close, f1
      
      openw, f2, name2, /APPEND
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f2, $
         strim( (reform( chain2[*,0] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain2[*,1] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain2[*,2] ))[ii],l=8) + '  ' + $
         strim( (reform( chain2[*,3] ))[ii],l=8), $
         format = '(5000A)'
      close, f2
      
      openw, f3, name3, /APPEND
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f3, $
         strim( (reform( chain3[*,0] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain3[*,1] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain3[*,2] ))[ii],l=8) + '  ' + $
         strim( (reform( chain3[*,3] ))[ii],l=8), $
         format = '(5000A)'
      close, f3
      
      openw, f4, name4, /APPEND
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f4, $
         strim( (reform( chain4[*,0] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain4[*,1] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain4[*,2] ))[ii],l=8) + '  ' + $
         strim( (reform( chain4[*,3] ))[ii],l=8), $
         format = '(5000A)'
      close, f4
      
      openw, f5, name5, /APPEND
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f5, $
         strim( (reform( chain5[*,0] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain5[*,1] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain5[*,2] ))[ii],l=8) + '  ' + $
         strim( (reform( chain5[*,3] ))[ii],l=8), $
         format = '(5000A)'
      close, f5
      
      openw, f6, name6, /APPEND
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f6, $
         strim( (reform( chain6[*,0] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain6[*,1] ))[ii],l=8)  + '  ' + $
         strim( (reform( chain6[*,2] ))[ii],l=8) + '  ' + $
         strim( (reform( chain6[*,3] ))[ii],l=8), $
         format = '(5000A)'
      close, f6
      
   ENDIF ELSE BEGIN
      openw, f1, name1, /APPEND         
      FOR ii = 0L, n_elements(Akeep) - 1 DO printf, f1, $
         strim(Akeep[ii],l=8)  + '  ' + $
         strim(Skeep[ii],l=8)  + '  ' + $
         strim(Sxkeep[ii],l=8) + '  ' + $
         strim(Nkeep[ii],l=8), $
         format = '(5000A)'
      close, f1         
   ENDELSE
;ENDIF


   ;;- Update old probabilities so mcmc_swap effectively continues the
   ;;  MCMC process from the last execution.
   gp1.oldP = double(chain1[0,4])
   gp2.oldp = double(chain2[0,4])
   gp3.oldP = double(chain3[0,4])
   gp4.oldP = double(chain4[0,4])
   gp5.oldP = double(chain5[0,4])
   gp6.oldP = double(chain6[0,4])

   gp1.global_count += 1
   gp2.global_count += 1
   gp3.global_count += 1
   gp4.global_count += 1
   gp5.global_count += 1
   gp6.global_count += 1


   IF (i EQ N_SWAP) THEN BEGIN
      dt = (systime(/sec) - tstart) 
      ttot = dt * floor((float(NITER)/float(N_SWAP))) / 3600.
      MESSAGE, 'Estimated time until complete: '+strim(ttot,l=5) + $
               ' hours.', /INF
   ENDIF

   i += N_SWAP
   c = ( double(i) / double(NITER) ) * 100.
   c = string(c)
   p = strpos(c,'.')
   strc = strtrim(strmid(c,0,p+3),2)
   IF (strupcase(global_params.verbose) EQ 'TRUE') THEN $
      MESSAGE, strc+'%',/INF        
      
ENDWHILE


MESSAGE, strim(float(Sreject) / float(NLOOP) * 100.) + $
         '% of the swaps rejected.', /INF
MESSAGE, strim(float(Saccept) / float(NLOOP) * 100.) + $
         '% of the swaps accepted.', /INF
close, f1


END
