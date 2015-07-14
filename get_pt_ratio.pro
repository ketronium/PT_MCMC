FUNCTION get_pt_ratio, tc1, tc2, vary_rms=vary_rms


;+
;
; Calculates acceptance criteria ratio for the Parallel
; Tempering algorithm. Defined as:
;
;
;        {     P(Xi+1|Bi) P(Xi|Bi+1) }
; r = min{ 1, ---------------------- }
;        {     P(Xi|Bi) P(Xi+1|Bi+1) }
;
;
; where i is the chain index, X denotes the parameters for
; that chain at this iteration time, and B is the inverse
; temperature for chain i.
;
; Inputs tc1 and tc2 are two global structures for the two
; chains being proposed to be swapped.
;
;-


fluxbins = ((tc1).fluxbins)[0:(tc1.NBINS-1)]

;IF NOT keyword_set(vary_rms) THEN BEGIN
;;- Get un-tempered log-likelihoods at each bin.
   log_p1 = compute_likelihood(fluxbins, /logP, _EXTRA=tc1) 
   log_p2 = compute_likelihood(fluxbins, /logP, _EXTRA=tc2) 
   

;;- Calculate ratio with un-tempered probabilities.
   top = product( exp(log_p2 * tc1.beta) ) * product( exp(log_p1 * tc2.beta) )
   bot = product( exp(log_p1 * tc1.beta) ) * product( exp(log_p2 * tc2.beta) )
   
   eval = top/bot
   test = product(exp(log_p1))
   
   IF (finite(eval) EQ 0) THEN eval = 0.0 
   IF ( (eval GT 1.0) OR (test EQ 0.0) ) THEN r = 1.0 ELSE r = eval

;ENDIF ELSE BEGIN

;   restore, !SAVEDIR + 'kvals_ptr' + tc1.chain_num + '.sav'
;   FOR i = 0, n_elments(kvals_ptr) - 1 DO BEGIN
      
      

   
print, top
print, bot
RETURN, r

END

