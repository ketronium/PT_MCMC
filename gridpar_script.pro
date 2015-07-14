pro gridpar_script
 
restore, '/home/ketron/grid/gparams0.sav'
pth = global_params.savedir
obridge0 = obj_new("IDL_IDLBridge",output="")
obridge0->setvar,'pth',pth
obridge0->execute,'!path += pth'
obridge0->execute, '@' + PREF_GET('IDL_STARTUP')
obridge0->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge0
obridge0->execute, "t=erf(1)"
obridge0->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status0=obridge0->status()
  
restore, '/home/ketron/grid/gparams1.sav'
pth = global_params.savedir
obridge1 = obj_new("IDL_IDLBridge",output="")
obridge1->setvar,'pth',pth
obridge1->execute,'!path += pth'
obridge1->execute, '@' + PREF_GET('IDL_STARTUP')
obridge1->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge1
obridge1->execute, "t=erf(1)"
obridge1->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status1=obridge1->status()
  
restore, '/home/ketron/grid/gparams2.sav'
pth = global_params.savedir
obridge2 = obj_new("IDL_IDLBridge",output="")
obridge2->setvar,'pth',pth
obridge2->execute,'!path += pth'
obridge2->execute, '@' + PREF_GET('IDL_STARTUP')
obridge2->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge2
obridge2->execute, "t=erf(1)"
obridge2->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status2=obridge2->status()
  
restore, '/home/ketron/grid/gparams3.sav'
pth = global_params.savedir
obridge3 = obj_new("IDL_IDLBridge",output="")
obridge3->setvar,'pth',pth
obridge3->execute,'!path += pth'
obridge3->execute, '@' + PREF_GET('IDL_STARTUP')
obridge3->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge3
obridge3->execute, "t=erf(1)"
obridge3->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status3=obridge3->status()
  
restore, '/home/ketron/grid/gparams4.sav'
pth = global_params.savedir
obridge4 = obj_new("IDL_IDLBridge",output="")
obridge4->setvar,'pth',pth
obridge4->execute,'!path += pth'
obridge4->execute, '@' + PREF_GET('IDL_STARTUP')
obridge4->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge4
obridge4->execute, "t=erf(1)"
obridge4->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status4=obridge4->status()
  
restore, '/home/ketron/grid/gparams5.sav'
pth = global_params.savedir
obridge5 = obj_new("IDL_IDLBridge",output="")
obridge5->setvar,'pth',pth
obridge5->execute,'!path += pth'
obridge5->execute, '@' + PREF_GET('IDL_STARTUP')
obridge5->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge5
obridge5->execute, "t=erf(1)"
obridge5->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status5=obridge5->status()
  
restore, '/home/ketron/grid/gparams6.sav'
pth = global_params.savedir
obridge6 = obj_new("IDL_IDLBridge",output="")
obridge6->setvar,'pth',pth
obridge6->execute,'!path += pth'
obridge6->execute, '@' + PREF_GET('IDL_STARTUP')
obridge6->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge6
obridge6->execute, "t=erf(1)"
obridge6->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status6=obridge6->status()
  
restore, '/home/ketron/grid/gparams7.sav'
pth = global_params.savedir
obridge7 = obj_new("IDL_IDLBridge",output="")
obridge7->setvar,'pth',pth
obridge7->execute,'!path += pth'
obridge7->execute, '@' + PREF_GET('IDL_STARTUP')
obridge7->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge7
obridge7->execute, "t=erf(1)"
obridge7->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status7=obridge7->status()
  
restore, '/home/ketron/grid/gparams8.sav'
pth = global_params.savedir
obridge8 = obj_new("IDL_IDLBridge",output="")
obridge8->setvar,'pth',pth
obridge8->execute,'!path += pth'
obridge8->execute, '@' + PREF_GET('IDL_STARTUP')
obridge8->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge8
obridge8->execute, "t=erf(1)"
obridge8->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status8=obridge8->status()
  
restore, '/home/ketron/grid/gparams9.sav'
pth = global_params.savedir
obridge9 = obj_new("IDL_IDLBridge",output="")
obridge9->setvar,'pth',pth
obridge9->execute,'!path += pth'
obridge9->execute, '@' + PREF_GET('IDL_STARTUP')
obridge9->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge9
obridge9->execute, "t=erf(1)"
obridge9->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status9=obridge9->status()
  
restore, '/home/ketron/grid/gparams10.sav'
pth = global_params.savedir
obridge10 = obj_new("IDL_IDLBridge",output="")
obridge10->setvar,'pth',pth
obridge10->execute,'!path += pth'
obridge10->execute, '@' + PREF_GET('IDL_STARTUP')
obridge10->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge10
obridge10->execute, "t=erf(1)"
obridge10->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status10=obridge10->status()
  
restore, '/home/ketron/grid/gparams11.sav'
pth = global_params.savedir
obridge11 = obj_new("IDL_IDLBridge",output="")
obridge11->setvar,'pth',pth
obridge11->execute,'!path += pth'
obridge11->execute, '@' + PREF_GET('IDL_STARTUP')
obridge11->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge11
obridge11->execute, "t=erf(1)"
obridge11->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status11=obridge11->status()
  
restore, '/home/ketron/grid/gparams12.sav'
pth = global_params.savedir
obridge12 = obj_new("IDL_IDLBridge",output="")
obridge12->setvar,'pth',pth
obridge12->execute,'!path += pth'
obridge12->execute, '@' + PREF_GET('IDL_STARTUP')
obridge12->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge12
obridge12->execute, "t=erf(1)"
obridge12->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status12=obridge12->status()
  
restore, '/home/ketron/grid/gparams13.sav'
pth = global_params.savedir
obridge13 = obj_new("IDL_IDLBridge",output="")
obridge13->setvar,'pth',pth
obridge13->execute,'!path += pth'
obridge13->execute, '@' + PREF_GET('IDL_STARTUP')
obridge13->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge13
obridge13->execute, "t=erf(1)"
obridge13->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status13=obridge13->status()
  
restore, '/home/ketron/grid/gparams14.sav'
pth = global_params.savedir
obridge14 = obj_new("IDL_IDLBridge",output="")
obridge14->setvar,'pth',pth
obridge14->execute,'!path += pth'
obridge14->execute, '@' + PREF_GET('IDL_STARTUP')
obridge14->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge14
obridge14->execute, "t=erf(1)"
obridge14->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status14=obridge14->status()
  
restore, '/home/ketron/grid/gparams15.sav'
pth = global_params.savedir
obridge15 = obj_new("IDL_IDLBridge",output="")
obridge15->setvar,'pth',pth
obridge15->execute,'!path += pth'
obridge15->execute, '@' + PREF_GET('IDL_STARTUP')
obridge15->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge15
obridge15->execute, "t=erf(1)"
obridge15->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status15=obridge15->status()
  
restore, '/home/ketron/grid/gparams16.sav'
pth = global_params.savedir
obridge16 = obj_new("IDL_IDLBridge",output="")
obridge16->setvar,'pth',pth
obridge16->execute,'!path += pth'
obridge16->execute, '@' + PREF_GET('IDL_STARTUP')
obridge16->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge16
obridge16->execute, "t=erf(1)"
obridge16->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status16=obridge16->status()
  
restore, '/home/ketron/grid/gparams17.sav'
pth = global_params.savedir
obridge17 = obj_new("IDL_IDLBridge",output="")
obridge17->setvar,'pth',pth
obridge17->execute,'!path += pth'
obridge17->execute, '@' + PREF_GET('IDL_STARTUP')
obridge17->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge17
obridge17->execute, "t=erf(1)"
obridge17->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status17=obridge17->status()
  
restore, '/home/ketron/grid/gparams18.sav'
pth = global_params.savedir
obridge18 = obj_new("IDL_IDLBridge",output="")
obridge18->setvar,'pth',pth
obridge18->execute,'!path += pth'
obridge18->execute, '@' + PREF_GET('IDL_STARTUP')
obridge18->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge18
obridge18->execute, "t=erf(1)"
obridge18->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status18=obridge18->status()
  
restore, '/home/ketron/grid/gparams19.sav'
pth = global_params.savedir
obridge19 = obj_new("IDL_IDLBridge",output="")
obridge19->setvar,'pth',pth
obridge19->execute,'!path += pth'
obridge19->execute, '@' + PREF_GET('IDL_STARTUP')
obridge19->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge19
obridge19->execute, "t=erf(1)"
obridge19->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status19=obridge19->status()
  
restore, '/home/ketron/grid/gparams20.sav'
pth = global_params.savedir
obridge20 = obj_new("IDL_IDLBridge",output="")
obridge20->setvar,'pth',pth
obridge20->execute,'!path += pth'
obridge20->execute, '@' + PREF_GET('IDL_STARTUP')
obridge20->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge20
obridge20->execute, "t=erf(1)"
obridge20->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status20=obridge20->status()
  
restore, '/home/ketron/grid/gparams21.sav'
pth = global_params.savedir
obridge21 = obj_new("IDL_IDLBridge",output="")
obridge21->setvar,'pth',pth
obridge21->execute,'!path += pth'
obridge21->execute, '@' + PREF_GET('IDL_STARTUP')
obridge21->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge21
obridge21->execute, "t=erf(1)"
obridge21->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status21=obridge21->status()
  
restore, '/home/ketron/grid/gparams22.sav'
pth = global_params.savedir
obridge22 = obj_new("IDL_IDLBridge",output="")
obridge22->setvar,'pth',pth
obridge22->execute,'!path += pth'
obridge22->execute, '@' + PREF_GET('IDL_STARTUP')
obridge22->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge22
obridge22->execute, "t=erf(1)"
obridge22->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status22=obridge22->status()
  
restore, '/home/ketron/grid/gparams23.sav'
pth = global_params.savedir
obridge23 = obj_new("IDL_IDLBridge",output="")
obridge23->setvar,'pth',pth
obridge23->execute,'!path += pth'
obridge23->execute, '@' + PREF_GET('IDL_STARTUP')
obridge23->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge23
obridge23->execute, "t=erf(1)"
obridge23->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status23=obridge23->status()
  
restore, '/home/ketron/grid/gparams24.sav'
pth = global_params.savedir
obridge24 = obj_new("IDL_IDLBridge",output="")
obridge24->setvar,'pth',pth
obridge24->execute,'!path += pth'
obridge24->execute, '@' + PREF_GET('IDL_STARTUP')
obridge24->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge24
obridge24->execute, "t=erf(1)"
obridge24->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status24=obridge24->status()
  
restore, '/home/ketron/grid/gparams25.sav'
pth = global_params.savedir
obridge25 = obj_new("IDL_IDLBridge",output="")
obridge25->setvar,'pth',pth
obridge25->execute,'!path += pth'
obridge25->execute, '@' + PREF_GET('IDL_STARTUP')
obridge25->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge25
obridge25->execute, "t=erf(1)"
obridge25->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status25=obridge25->status()
  
restore, '/home/ketron/grid/gparams26.sav'
pth = global_params.savedir
obridge26 = obj_new("IDL_IDLBridge",output="")
obridge26->setvar,'pth',pth
obridge26->execute,'!path += pth'
obridge26->execute, '@' + PREF_GET('IDL_STARTUP')
obridge26->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge26
obridge26->execute, "t=erf(1)"
obridge26->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status26=obridge26->status()
  
restore, '/home/ketron/grid/gparams27.sav'
pth = global_params.savedir
obridge27 = obj_new("IDL_IDLBridge",output="")
obridge27->setvar,'pth',pth
obridge27->execute,'!path += pth'
obridge27->execute, '@' + PREF_GET('IDL_STARTUP')
obridge27->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge27
obridge27->execute, "t=erf(1)"
obridge27->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status27=obridge27->status()
  
restore, '/home/ketron/grid/gparams28.sav'
pth = global_params.savedir
obridge28 = obj_new("IDL_IDLBridge",output="")
obridge28->setvar,'pth',pth
obridge28->execute,'!path += pth'
obridge28->execute, '@' + PREF_GET('IDL_STARTUP')
obridge28->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge28
obridge28->execute, "t=erf(1)"
obridge28->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status28=obridge28->status()
  
restore, '/home/ketron/grid/gparams29.sav'
pth = global_params.savedir
obridge29 = obj_new("IDL_IDLBridge",output="")
obridge29->setvar,'pth',pth
obridge29->execute,'!path += pth'
obridge29->execute, '@' + PREF_GET('IDL_STARTUP')
obridge29->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge29
obridge29->execute, "t=erf(1)"
obridge29->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status29=obridge29->status()
  
restore, '/home/ketron/grid/gparams30.sav'
pth = global_params.savedir
obridge30 = obj_new("IDL_IDLBridge",output="")
obridge30->setvar,'pth',pth
obridge30->execute,'!path += pth'
obridge30->execute, '@' + PREF_GET('IDL_STARTUP')
obridge30->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge30
obridge30->execute, "t=erf(1)"
obridge30->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status30=obridge30->status()
  
restore, '/home/ketron/grid/gparams31.sav'
pth = global_params.savedir
obridge31 = obj_new("IDL_IDLBridge",output="")
obridge31->setvar,'pth',pth
obridge31->execute,'!path += pth'
obridge31->execute, '@' + PREF_GET('IDL_STARTUP')
obridge31->execute, "cd,'/home/ketron/cts_code/current/'"
struct_pass, global_params, obridge31
obridge31->execute, "t=erf(1)"
obridge31->execute,'gridpar, _EXTRA=global_params',/nowait 
WAIT, 10.
status31=obridge31->status()
  
WHILE (status0 NE 0) AND $
     (status1 NE 0) AND $
     (status2 NE 0) AND $
     (status3 NE 0) AND $
     (status4 NE 0) AND $
     (status5 NE 0) AND $
     (status6 NE 0) AND $
     (status7 NE 0) AND $
     (status8 NE 0) AND $
     (status9 NE 0) AND $
     (status10 NE 0) AND $
     (status11 NE 0) AND $
     (status12 NE 0) AND $
     (status13 NE 0) AND $
     (status14 NE 0) AND $
     (status15 NE 0) AND $
     (status16 NE 0) AND $
     (status17 NE 0) AND $
     (status18 NE 0) AND $
     (status19 NE 0) AND $
     (status20 NE 0) AND $
     (status21 NE 0) AND $
     (status22 NE 0) AND $
     (status23 NE 0) AND $
     (status24 NE 0) AND $
     (status25 NE 0) AND $
     (status26 NE 0) AND $
     (status27 NE 0) AND $
     (status28 NE 0) AND $
     (status29 NE 0) AND $
     (status30 NE 0) AND $
     (status31 NE 0) DO BEGIN
   status0=obridge0->status()
   status1=obridge1->status()
   status2=obridge2->status()
   status3=obridge3->status()
   status4=obridge4->status()
   status5=obridge5->status()
   status6=obridge6->status()
   status7=obridge7->status()
   status8=obridge8->status()
   status9=obridge9->status()
   status10=obridge10->status()
   status11=obridge11->status()
   status12=obridge12->status()
   status13=obridge13->status()
   status14=obridge14->status()
   status15=obridge15->status()
   status16=obridge16->status()
   status17=obridge17->status()
   status18=obridge18->status()
   status19=obridge19->status()
   status20=obridge20->status()
   status21=obridge21->status()
   status22=obridge22->status()
   status23=obridge23->status()
   status24=obridge24->status()
   status25=obridge25->status()
   status26=obridge26->status()
   status27=obridge27->status()
   status28=obridge28->status()
   status29=obridge29->status()
   status30=obridge30->status()
   status31=obridge31->status()
ENDWHILE
 
end
