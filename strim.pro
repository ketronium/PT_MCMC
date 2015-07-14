function strim, input,len = len

COMPILE_OPT HIDDEN

output = strtrim(string(input),2)
if keyword_set(len) then output = strmid(output,0,len)

return, output

end
