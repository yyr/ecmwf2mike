; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Saturday, January  2 2016

;_____________________________________________________________________________
; procedure: put_record_header
;_____________________________________________________________________________
undef("put_record_header")
procedure put_record_header(a:file,t:integer,y:integer,x:integer)
begin


  return
end

;_____________________________________________________________________________
; Function: qs
; Doc:
;_____________________________________________________________________________
undef("qs")
function qs(s:string)
begin
  return(str_get_dq() + s + str_get_dq())
end


begin
  input_filename = "aug-2011.nc"
  output_filename = "aug-2011-mike.txt"
  dt = "06"


  a = addfile(input_filename,"r")
  ; o = addfile(output_filename,"w")

  longs = a->longitude
  lats = a->latitude

  noflongs = dimsizes(longs)
  noflats = dimsizes(lats)

  lat_min = lats(noflats - 1 )
  lat_max = lats(0)

  long_max   = longs(noflongs - 1 )
  long_min = longs(0)

  dx = (long_max - long_min) / (noflongs - 1)
  dy = (lat_max - lat_min) / (noflats - 1)

  time = a->time
  t = ut_calendar(time,0) ; time(time)


  ; print( lat_max + " "  + lat_min)
  ; print( long_max + " "  + long_min)
  ; print ("dx " + dx + " dy " + dy)

  dq = str_get_dq()
  sp = " "

  print(qs("Title") + sp + qs("MM5 Wind"))
  print(qs("Dim") + " 2")
  print(qs("Geo") + sp + qs("LONG/LAT") + sp + long_min\
        + sp + lat_min + " 0")
  print(qs("Time") + sp + qs("EqudistantTimeAxis") + sp \
        + qs(t(0,0) + "-" + t(0,1) + "-" + t(0,2)) + sp \
        + qs(t(0,3) + ":" + t(0,4) + ":" + t(0,5)) + sp + dt + sp + "3600")
  print(qs("NoGridPoints") + sp + noflongs + sp + noflats)
  print(qs("Spacing") + sp + dy + sp + dx)

end
