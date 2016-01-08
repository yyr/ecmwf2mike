; Copyright (C) Yagnesh Raghava Yakkala. http://yagnesh.org
; Created: Saturday, January  2 2016

;_____________________________________________________________________________
; Function: qs
;_____________________________________________________________________________
undef("qs")
function qs(s:string)
begin
  return(str_get_dq() + s + str_get_dq())
end

;_____________________________________________________________________________
; procedure: appstring2file
; Doc:
;_____________________________________________________________________________
undef("appstring2file")
procedure appstring2file(filename:string, str:string)
begin
  system("echo " + "'" + str + "'" + " >> " + filename)
  return
end

;_____________________________________________________________________________
; procedure: put_record_header
;_____________________________________________________________________________
undef("put_record_header")
;procedure put_record_header(a:file,t:integer,y:integer)
procedure put_record_header(filename:string, tstep:integer,varno:integer)
begin
  appstring2file(filename, "")
  appstring2file(filename, qs("tstep") + " " + tstep + " " + qs("item") + " " \
        + varno + " " + qs("layer") + " 0"); layer=0, because our data is always 2d
  return
end

begin
  input_filename = "aug-2011.nc"
  o = "aug-2011-mike.txt"
  dt = "06"

  a = addfile(input_filename,"r")
  ; o = addfile(output_filename,"w")
  system("rm -f " + o )
  system("touch " + o )

  ; retrieve data
  longs = a->longitude
  lats = a->latitude

  time = a->time
  tt = ut_calendar(time,0) ; time(time)
  t = floattoint(tt)

  u             = a->u10
  u_offset      = u@add_offset
  u_scalefactor = u@scale_factor
  uu = (u * u_scalefactor) + u_offset

  v             = a->v10
  v_offset      = v@add_offset
  v_scalefactor = v@scale_factor
  vv = (v * v_scalefactor) + v_offset


  p             = a->sp
  p_offset      = p@add_offset
  p_scalefactor = p@scale_factor
  pp = (p * p_scalefactor) + p_offset


  noflongs = dimsizes(longs)
  noflats  = dimsizes(lats)
  noftimes = dimsizes(time)

  lat_min = lats(noflats - 1 )
  lat_max = lats(0)

  long_max   = longs(noflongs - 1 )
  long_min = longs(0)

  dx = (long_max - long_min) / (noflongs - 1)
  dy = (lat_max - lat_min) / (noflats - 1)

  ; print( lat_max + " "  + lat_min)
  ; print( long_max + " "  + long_min)
  ; print ("dx " + dx + " dy " + dy)


  ; start writing out file
  dq = str_get_dq()
  sp = " "

  ; print header
  appstring2file(o, qs("Title") + sp + qs("MM5 Wind"))
  appstring2file(o, qs("Dim") + " 2")
  appstring2file(o, qs("Geo") + sp + qs("LONG/LAT") + sp + long_min\
        + sp + lat_min + " 0")
  appstring2file(o, qs("Time") + sp + qs("EqudistantTimeAxis") + sp \
        + qs(t(0,0) + "-" + sprinti("%0.2i",t(0,1)) + "-" + sprinti("%0.2i",t(0,2))) + sp \
        + qs(sprinti("%0.2i",t(0,3)) + ":" + sprinti("%0.2i",t(0,4)) + ":"  \
        + sprinti("%0.2i",t(0,5))) + sp + noftimes + sp + "3600")
  appstring2file(o, qs("NoGridPoints") + sp + noflongs + sp + noflats)
  appstring2file(o, qs("Spacing") + sp + dy + sp + dx)
  appstring2file(o, qs("NoStaticItems") + " 0")
  appstring2file(o, qs("NoDynamicItems") + " 3")
  appstring2file(o, qs("Item") + sp + qs("U-comp") + sp + qs("U-velocity component") \
        + sp + qs("m/s"))
  appstring2file(o, qs("Item") + sp + qs("V-comp") + sp + qs("V-velocity component") \
        + sp + qs("m/s"))
  appstring2file(o, qs("Item") + sp + qs("SLP") + sp + qs("Surface Level Pressure") \
        + sp + qs("Pa"))
  appstring2file(o, "NoCustomBlocks" + " 1")
  appstring2file(o, qs("M21_Misc") + " 1 7 0 -1E-030 -900 10 -1E-030 -1E-030 -1E-030")
  appstring2file(o, qs("Delete") + " -1E-030")
  appstring2file(o, qs("DataType") + " 0")

  ; write data to output file
  option = True
  option@fout = "tmp"

  ; write_matrix can't append data to outfile, so we are using system's "cat"
  ; command to write data to output file. (ugly and slow but works)

;  do it = 0, 1, 1
  do it = 0, noftimes - 1, 1
    do var = 1, 3, 1
      put_record_header(o, it, var)
      if ( var .eq. 1 ) then
        write_matrix(uu(it,:,:), noflongs + "f11.2", option)
        system("cat " + option@fout + " >>" + o)
      end if
      if ( var .eq. 2 ) then
        write_matrix(vv(it,:,:), noflongs + "f11.2", option)
        system("cat " +  option@fout + " >>" + o)
      end if
      if ( var .eq. 3 ) then
        write_matrix(pp(it,:,:), noflongs + "f11.2", option)
        system("cat " +  option@fout + " >>" + o)
      end if
    end do
  end do
  system("rm -f " + option@fout)
end
