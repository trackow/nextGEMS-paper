;--------------------------------------------------------------------------------------------
begin
;------------------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------
; Converts YYYYMM time to "days since" time.
;----------------------------------------------------------------------
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

function yyyymm_to_time(time)
local ntime, stime, year, month, day, hour, minute, second, units
begin
  ntime  = dimsizes(time)
  stime  = tostring(time)
  year   = toint(str_get_cols(stime,0,3))
  month  = toint(str_get_cols(stime,4,5))
  day    = new(ntime,integer)
  hour   = new(ntime,integer)
  minute = new(ntime,integer)
  second = new(ntime,double)
 
;----------------------------------------------------------------------
; Note: you may need to change the day, hour, minute values depending
; on your definition of "YYYYMM".  Is this the first day and the 
; first hour of the month? Is it the middle of the month?
;----------------------------------------------------------------------
  day    = 1
  hour   = 0
  minute = 0
  second = 0.d
  units  = "days since " + min(year) + "-01-01 00:00"
  newtime = cd_inv_calendar(year,month,day,hour,minute,second,units,0)
  return(newtime)
end


; read in the zonal-mean zonal wind data
fil = addfile("multio_hzfy_u_monthlymean_1x1_alltimes_ZM.nc", "r")
fil2 = addfile("multio_hz9o_u_monthlymean_1x1_alltimes_ZM.nc", "r")
fil3= addfile("ERA5_2020to2024_ZM.nc", "r")
lat=fil3->lat 
wgt  = latRegWgt(lat, "float", 0)

latS=10
latN=-10
u=new((/3,4,60/),"float")
u_0=dim_avg_wgt_Wrap(short2flt(fil->u(:,{10:70},{latS:latN},0)),wgt({latS:latN}),0)
u(0,:,:)=u_0(level |:, time | :)
u3_0=dim_avg_wgt_Wrap(short2flt(fil2->u(:,{10:70},{latS:latN},0)),wgt({latS:latN}),0)
u(1,:,:)=u3_0(level |:, time | :)
u4_0=dim_avg_wgt_Wrap(fil3->u(:,{10:70},{latS:latN},0),wgt({latS:latN}),0)
u(2,:,0:55)=u4_0(level |:, time | :)


time=new(60,"integer")
aa=202001
do i=0,60-1
  if (i.eq.12) then
   aa=202101
  end if
  if (i.eq.24) then
   aa=202201
  end if
  if (i.eq.36) then
   aa=202301
  end if
  if (i.eq.48) then
   aa=202401
  end if
  time(i)=aa
  aa=aa+1
end do

time!0     = "time"
time@units = "YYYYMM"

u!2="time"
u&time=time


;---Convert the time values and reassign as x's time coordinate array
newtime = yyyymm_to_time(time)
u&time  := newtime





wksvec_int  = gsn_open_wks ("pdf","QBO_pres_time")  ; open the work station
; ========================= PLOT 2 ==============================
res2 = True                            ; res2 probability plots
gsn_define_colormap(wksvec_int,"BlWhRe")  ; choose color map


res2@gsnDraw             = False       ; Do not draw plot
res2@gsnFrame            = False       ; Do not advance frome
res2@vpWidthF              = 0.6
res2@vpHeightF              = 0.5
res2@cnInfoLabelOn       = False           ; turn off cn info label
res2@gsnSpreadColors  = True                ; use full range of color map

res2@tiYAxisString         = "pressure [hPa]"         ; y-axis label
res2@trYReverse            = True
res2@cnLineLabelsOn           = False       ; do not draw contour lines

plotco=new(3,graphic)

res2@cnFillOn    = True                        ; turn on color fill
res2@cnLinesOn   = False                       ; turn off the contour lines

res2@lbLabelBarOn=False
res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels;
res2@cnMinLevelValF      = -21.      ; set min contour level
res2@cnMaxLevelValF      = 21.       ; set max contour level
res2@cnLevelSpacingF     = 21.*2./15

;---Set resources necessary to nicely format X axis
restick           = True
restick@ttmFormat = "%c %Y"              ; Jan 2010, Feb 2010, etc.
time_axis_labels(newtime,res2,restick)

res2@gsnLeftString      = "a) Cycle 3, 4.4km, IFS-FESOM"
plotco(0) = gsn_csm_contour(wksvec_int,u(0,:,:),res2)     ; creates
res2@gsnLeftString      = "b) Cycle 3, 9km, IFS-NEMO"
res2@tiYAxisString         = ""
plotco(1) = gsn_csm_contour(wksvec_int,u(1,:,:),res2)     ; creates
res2@gsnLeftString      = "c) ERA5 "
plotco(2) = gsn_csm_contour(wksvec_int,u(2,:,:),res2)     ; creates

resP =True
resP@gsnPanelLabelBar    = True            ; add common colorbar
resP@lbLabelFontHeightF  = 0.007               ; make labels smaller
gsn_panel(wksvec_int,plotco(0:2),(/1,3/),resP)          ; now draw as one plot
print ( "done" )

 





end
