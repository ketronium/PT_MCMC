PRO rms_density


fluxbins = logbins(8,1,30)
global_trueparams = define_global_params()
global_trueparams.Smin = 1.0
global_trueparams.alpha = -1.5
global_trueparams.norm = 1.2e5
global_trueparams.smax = 20.0
global_trueparams.fluxbins = fluxbins

trueN = get_nsource(_EXTRA=global_trueparams)
resample_trueN = randomn(seed, 1, POISSON=trueN)

rms_fluxes = get_vary_rms_fluxes(resample_trueN, $
                                      _EXTRA=global_trueparams)

S = reform(rms_fluxes[0,*])
rms = reform(rms_fluxes[1,*])


;;;;;;;;;;;;;;;;;;;;;;;;;;
;;- density plot
sssss=setplot()
ujy = textoidl('\mu')
ujy = ujy+'Jy'
set_plot,'ps' & device, filename = '../rms_density.eps',/encaps
sss=setplot()
xr = [-60, 70]
yr = [10, 20]
d1 = hist_2d(S, rms, bin1=0.5, bin2=0.05, min1=xr[0], max1=xr[1],$
              min2=yr[0],max2=yr[1])

d1 = (-1)*d1/total(abs(d1))
pos = [0.08,0.08,0.9,0.95]
win_aspect = float(!d.y_vsize) / float(!d.x_vsize)
imdisp, d1,/norm, $
        margin=0,out_pos=outp,aspect=win_aspect, pos=pos
alpha = textoidl('\alpha')
smax = translate_sub_super('S')
smax = smax + ' (' + uJy + ')'
sigma = textoidl('\sigma')
sigman = translate_sub_super(sigma+'_{n}')
beam = translate_sub_super('beam^{-1}')

plot, S, rms, /nodata,xrang=xr, yrange=yr, $
      xtit=Smax,ytit=sigman + ' (' + uJy + ' ' + beam + ')',$
      /xs,/ys,colo=black,pos=outp,/norm,/noerase,$
      xthick=3,ythick=3,charthick=3,thick=3,charsize=1.1


;tr1 = strim( (findgen(5) /(4) * (MAX(abs(d1))) ) ,l=4 )
;cgcolorbar,COLOR=black,range=[min(d1),max(d1)],/invert,$
;           position=[0.91,0.12,0.94,0.92],/right,/vert,charthick=3,$
;           ticknames=tr1, charsize=0

device, /close
stop

END
