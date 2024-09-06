load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "../../../../../DNA/papers/diagnostics_cam.ncl"

begin
  ;===== users define
  case     = "IFS9"
  diro     = "./Figure/"
  latN     = 15
  latS     = -latN

  nDayWin  = 96     ; Wheeler-Kiladis [WK] temporal window length (days)
  nDaySkip = -60    ; time (days) between temporal windows [segments]
                    ; negative means there will be overlapping 
                    ; temporal segments
  opt           = True
  opt@debug     = True
  opt@pltType   = "png"
  opt@cnLinesOn = False
  ;
  spd = 1      ; samples per day (6 hour sampling rate)
  var = "OLR"  ; user specified
  ;
  diri = "../../../../model/IFS9/daily/anomaly/"
  fili = "ttr_ave.day.anom.nc"
  ;========================================

  f        = addfile (diri+fili, "r")
  time     = f->time
  date     = cd_calendar(time, -2)
  iStrt    = ind( date .eq. 20200201 )
  iEnd     = ind( date .eq. 20241231 )
  olr      = f->ttr(iStrt:iEnd,{latS:latN},:)     ; (time,lat,lon)

  wkSpaceTime (olr, diro, case, var             \
              ,latN, spd, nDayWin, nDaySkip, opt)

end
