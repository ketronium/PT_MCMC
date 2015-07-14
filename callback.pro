pro callback, status, error, oBridge, userdata


CASE status OF
   3: MESSAGE, 'Bridge error: '+error
   4: MESSAGE, 'Bridge error = '+error
   ELSE: BREAK
ENDCASE

result = oBridge->GetVar('c1')


END
