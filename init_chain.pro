FUNCTION init_chains, a, s, sx, c, betas, $
                      N_swap = N_swap,$
                      NITER=NITER,$
                      INTEGRAL_RESOLUTION=INTEGRAL_RESOLUTION,$
                      FLUXBINS=FLUXBINS, $
                      KVALS=KVALS


;;- Chain 1
gp1 = define_global_params()
gp1.alpha = a[0]
gp1.smin  = s[0]
gp1.smax  = sx[0]
gp1.norm  = c[0]
gp1.beta = betas[0]
gp1.fluxbins=fluxbins
gp1.N_swap = float(N_swap)
gp1.integral_resolution = integral_resolution
gp1.kvals = kvals
IF keyword_set(check) THEN gp1.check=1L
;gp1.adaptA *= 0.35
;gp1.adaptS *= 0.7
;gp1.adaptSx *= 0.65;0.1
;gp1.adaptN *= 0.2;1.0 ;0.9
gp1.trueChain = 1L
gp1.chain_num = '1'
gp1.global_adapt = 1L
CHECK_SMIN = check_smin_prior(gp1.Smin,  $
                              gp1.Smax,  $
                              gp1.Norm,  $
                              gp1.alpha, $
                              _EXTRA=gp1)
IF CHECK_SMIN EQ 0L THEN message, 'Chain1: your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'


;;- Chain2
gp2 = define_global_params()
gp2.alpha = a[1]
gp2.smin  = s[1]
gp2.smax  = sx[1]
gp2.norm  = c[1]
gp2.beta = betas[1]
gp2.fluxbins=fluxbins
gp2.N_swap = float(N_swap)
gp2.kvals = kvals
gp2.integral_resolution = integral_resolution
gp2.check=0L
gp2.chain_num = '2'
;gp2.adaptA *= 0.7
;gp2.adaptS *= 0.07
;gp2.adaptSx *= 0.07
;gp2.adaptN *= 0.07
IF keyword_set(vary_rms) THEN gp2.vary_rms = 1L

CHECK_SMIN = check_smin_prior(gp2.Smin,  $
                              gp2.Smax,  $
                              gp2.Norm,  $
                              gp2.alpha, $
                              _EXTRA=gp2)
IF CHECK_SMIN EQ 0L THEN message, 'Chain2: your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'


;;- Chain 3
gp3 = define_global_params()
gp3.alpha = a[2]
gp3.smin  = s[2]
gp3.smax  = sx[2]
gp3.norm  = c[2]
gp3.beta = betas[2]
gp3.fluxbins=fluxbins
gp3.N_swap = float(N_swap)
gp3.kvals = kvals
;gp3.adaptA *= 0.7
;gp3.adaptS *= 0.7
;gp3.adaptSx *= 0.7
;gp3.adaptN *= 0.7
gp3.chain_num = '3'
gp3.integral_resolution = integral_resolution
IF keyword_set(vary_rms) THEN gp3.vary_rms = 1L

CHECK_SMIN = check_smin_prior(gp3.Smin,  $
                              gp3.Smax,  $
                              gp3.Norm,  $
                              gp3.alpha, $
                              _EXTRA=gp3)
IF CHECK_SMIN EQ 0L THEN message, 'Chain3: your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'


;;- chain 4
gp4 = define_global_params()
gp4.alpha = a[3]
gp4.smin  = s[3]
gp4.smax  = sx[3]
gp4.norm  = c[3]
gp4.beta = betas[3]
gp4.fluxbins=fluxbins
gp4.N_swap = float(N_swap)
gp4.kvals = kvals
gp4.check = 0L
gp4.chain_num = '4'
gp4.integral_resolution = integral_resolution
IF keyword_set(vary_rms) THEN gp4.vary_rms = 1L

CHECK_SMIN = check_smin_prior(gp4.Smin,  $
                              gp4.Smax,  $
                              gp4.Norm,  $
                              gp4.alpha, $
                              _EXTRA=gp4)
IF CHECK_SMIN EQ 0L THEN message, 'Chain4: your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'


;;- chain 5
gp5 = define_global_params()
gp5.alpha = a[4]
gp5.smin  = s[4]
gp5.smax  = sx[4]
gp5.norm  = c[4]
gp5.beta = betas[4]
gp5.fluxbins=fluxbins
gp5.N_swap = float(N_swap)
gp5.kvals = kvals
gp5.check = 0L
gp5.chain_num = '5'
gp5.integral_resolution = integral_resolution
IF keyword_set(vary_rms) THEN gp5.vary_rms = 1L

CHECK_SMIN = check_smin_prior(gp5.Smin,  $
                              gp5.Smax,  $
                              gp5.Norm,  $
                              gp5.alpha, $
                              _EXTRA=gp5)
IF CHECK_SMIN EQ 0L THEN message, 'Chain5: your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'


;;- chain 6
gp6 = define_global_params()
gp6.alpha = a[5]
gp6.smin  = s[5]
gp6.smax  = sx[5]
gp6.norm  = c[5]
gp6.beta = betas[5]
gp6.fluxbins=fluxbins
gp6.N_swap = float(N_swap)
gp6.kvals = kvals
gp6.check = 0L
gp6.chain_num = '6'
gp6.integral_resolution = integral_resolution
IF keyword_set(vary_rms) THEN gp6.vary_rms = 1L

CHECK_SMIN = check_smin_prior(gp6.Smin,  $
                              gp6.Smax,  $
                              gp6.Norm,  $
                              gp6.alpha, $
                              _EXTRA=gp6)
IF CHECK_SMIN EQ 0L THEN message, 'Chain6: your minimum flux is set too low '+$
                                  'given the 3 other parameter values.'




RET_PTR = ptrarr(6, /ALLOCATE_HEAP)
*RET_PTR[0] = gp1
*RET_PTR[1] = gp2
*RET_PTR[2] = gp3
*RET_PTR[3] = gp4
*RET_PTR[4] = gp5
*RET_PTR[5] = gp6

RETURN, RET_PTR

END
