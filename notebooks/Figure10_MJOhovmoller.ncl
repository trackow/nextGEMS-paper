load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/diagnostics_cam.ncl"

begin
   
  ;====== users define below
  model = (/ "obs", "model/IFS9", "model/IFS4.4" /)
  year  = (/ 37, 5, 5 /)
  deg   = "1"
  ;--- File information 
  comDir  = "../../../../"+model+"/daily/others/mjocom/com/"
  caseDir = "../../../../"+model+"/daily/others/mjocom/case/"
  ; For obs
  comDir(0)  = "../../../../obs/daily/others/mjocom/com/io/allseason/mjo/"
  caseDir(0) = "../../../../obs/daily/others/mjocom/case/io/allseason/mjo/"  
  ;--- target region
  latS = -10.
  latN = 10.
  lonW = 30.
  lonE = 210.
  lev  = 850
  ;--- variable
  var1     = (/ "olr", "ttr", "ttr" /)
  var2     = "u"
  varname1 = (/ "olr", "ttr_ave", "ttr_ave" /)
  varname2 = "uwnd.850"
  ;--- target lagdays
  lagStrt = -30
  lagEnd  = 30
  ;--- Output
  pltType = "pdf"
  pltDir  = "./Figure/"
  pltFil  = "olr_u850_MJO_hovmoller"
  ;--- level at significance (two-tailed)
  t_test = True
  danger = 0.1
  ;================================================

  ;====== Preparation
  mjovar = "mjo"
  label  = "MJO"
  lagday = ispan(lagStrt,lagEnd,1)
  
  ; For plot
  nexp = dimsizes(model)
  system( "mkdir "+pltDir )
  ;---
  wks   = gsn_open_wks(pltType, pltDir+pltFil)
  plot  = new(nexp, "graphic")
  alpha = (/ "(a) OBS (NOAA & ERAI)", "(b) IFS-9", "(c) IFS-4.4" /)

  do i = 0, nexp-1

    print( "i = "+i+" start..." )

    ;====== file open
    if ( model(i) .eq. "obs" ) then
      comFil1  = "com." +varname1(i)+"."+mjovar+".io.allseason.nc"
      comFil2  = "com." +varname2+"."+mjovar+".io.allseason.nc"
      caseFil1 = "case."+varname1(i)+"."+mjovar+".io.allseason.nc"
      caseFil2 = "case."+varname2+"."+mjovar+".io.allseason.nc"
    else
      comFil1  = "com." +varname1(i)+"."+mjovar+".nc"
      comFil2  = "com." +varname2+"."+mjovar+".nc"
      caseFil1 = "case."+varname1(i)+"."+mjovar+".nc"
      caseFil2 = "case."+varname2+"."+mjovar+".nc"
    end if
    ;
    f1  = addfile( comDir(i)+comFil1,   "r" )
    f2  = addfile( comDir(i)+comFil2,   "r" )
    f1c = addfile( caseDir(i)+caseFil1, "r" )
    f2c = addfile( caseDir(i)+caseFil2, "r" )
    ;
    comvar1  = f1 ->$var1(i)$(  {lagStrt:lagEnd},{latS:latN},:)
    comvar2  = f2 ->$var2$   (  {lagStrt:lagEnd},{latS:latN},:)
    casevar1 = f1c->$var1(i)$(:,{lagStrt:lagEnd},{latS:latN},:)
    casevar2 = f2c->$var2$   (:,{lagStrt:lagEnd},{latS:latN},:)
    ;
    print( "Finish reading data..." )

    ;====== latitudinal mean
    ave1      := dim_avg_n_Wrap(comvar1, 1)
    ave2      := dim_avg_n_Wrap(comvar2, 1)
    ave1_case := dim_avg_n(casevar1, 2)
    ave2_case := dim_avg_n(casevar2, 2)

    ;====== two-tailed t-test
    dims  = dimsizes(ave1_case)
    case  = dims(0)
    df    = case - 1
    prob1 = 1.0 - danger * 0.5
    tval1 = cdft_t(prob1, df)
    delete( dims )
    if ( t_test ) then
      diff_var1     = ave1      
      critval_var1 := tval1 * dim_stddev_n_Wrap(ave1_case,0) / sqrt(case)
      diff_var1 = abs(ave1) - critval_var1
      print( "Finish t-test" )
    end if

    ;====== Hovmoller Plot
    print( "Drawing..." )
    cmap  = read_colormap_file( "nrl_sirkes" )
    cmap2 = read_colormap_file( "temp_diff_18lev" )    
    ;--- Y-axis Label
    incr   = 10
    daystr = sprinti("%2.1i", lagday)
    ylabel = (/ daystr(0::incr) /)

    ;###### Shading plot (u850)
    res1 = True
    ; Basic setting
    res1@gsnDraw  = False
    res1@gsnFrame = False
    if ( i .eq. 2 ) then
      res1@gsnRightString = "OLR, u~B~850~N~"
    else
      res1@gsnRightString = ""
    end if
    res1@gsnLeftString             = alpha(i)+" ["+case+" cases / "+year(i)+" yr]"
    res1@gsnRightStringFontHeightF = 0.034
    res1@gsnLeftStringFontHeightF  = 0.034
    ; y-axis title
    if ( i .eq. 0 ) then      
      res1@tiYAxisString = "Lag [day]"
    else
      res1@tiYAxisString = ""
    end if
    res1@tiYAxisFontHeightF = 0.035
    ; Figure size
    res1@vpWidthF  = 0.9
    res1@vpHeightF = 1.
    ; shading setting
    res1@cnFillOn             = True
    res1@cnLinesOn            = False
    res1@cnInfoLabelOn        = False
    res1@cnLineLabelsOn       = False
    res1@cnLevelSelectionMode = "ManualLevels"
    res1@cnMinLevelValF       = -28.
    res1@cnMaxLevelValF       = 28.
    res1@cnLevelSpacingF      = 3.5
    res1@cnFillPalette        = (/ cmap(0,:), cmap(1,:), cmap(2,:), cmap(4,:), cmap(5,:),  \
                                   cmap(7,:), cmap(8,:), cmap(9,:), cmap(10,:), cmap(10,:), cmap2(10,:), cmap2(11,:), \
                                   cmap2(12,:), cmap2(13,:), cmap2(14,:), cmap2(16,:), cmap2(17,:), cmap2(18,:) /)                                  
    res1@lbLabelBarOn         = False
    ; reverse y-axis
    res1@trYReverse = True
    ; x-axis tickmark
    res1@gsnMajorLonSpacing      = 30.
    res1@gsnMinorLonSpacing      = 10.
    res1@tmXBLabelFontHeightF    = 0.032
    res1@tmXBMajorLengthF        = 0.014
    res1@tmXBMinorLengthF        = 0.007
    res1@tmXBMajorOutwardLengthF = 0.
    res1@tmXBMinorOutwardLengthF = 0.
    res1@tmXBLabelDeltaF         = 0.1 

    ; Y-tickamrk setting
    res1@tmYLMode                = "Explicit"
    res1@tmYLValues              = lagday(0::incr)
    res1@tmYLLabels              = ylabel
    res1@tmYLLabelFontHeightF    = 0.032
    res1@tmYLMajorLengthF        = 0.014
    res1@tmYLMinorLengthF        = 0.007
    res1@tmYLMajorOutwardLengthF = 0.
    res1@tmYLMinorOutwardLengthF = 0. 
    
    ;###### Contour plot (OLR)
    ; [white]
    res2                          = True
    res2@gsnDraw                  = False
    res2@gsnFrame                 = False
    ;
    res2@cnLinesOn                = True
    res2@cnLineLabelsOn           = False
    res2@cnInfoLabelOn            = False
    res2@cnLevelSelectionMode     = "ManualLevels"
    res2@cnMinLevelValF           = 0.
    res2@cnMaxLevelValF           = 6.
    res2@cnLevelSpacingF          = 0.5
    res2@cnLineThicknessF         = 4.5
    res2@cnLineColor              = "white"
    ;
    res2@gsnContourZeroLineThicknessF = 0.
    res2@gsnContourNegLineDashPattern = 1
    ; [black]
    res2b                  = res2
    res2b@cnLineThicknessF = 2.
    res2b@cnLineColor      = "black"

    ;###### Hatch Plot (significance)
    res3                          = True
    res3@gsnDraw                  = False
    res3@gsnFrame                 = False
    res3@cnLinesOn                = False
    res3@cnLineLabelsOn           = False
    res3@cnInfoLabelOn            = False
    ;
    opt                      = True
    opt@gsnShadeFillType     = "pattern"
    opt@gsnShadeHigh         = 17
    opt@gsnShadeFillDotSizeF = 0.0006
    opt@gsnShadeFillScaleF   = 0.9
    
    ;###### Draw
    plot1  = gsn_csm_hov(wks, ave1(:,{lonW:lonE}), res1)
    plot2  = gsn_csm_hov(wks, ave2(:,{lonW:lonE}), res2)
    plot2b = gsn_csm_hov(wks, ave2(:,{lonW:lonE}), res2b)    
    overlay(plot1, plot2)
    overlay(plot1, plot2b)
    ;
    if ( t_test ) then
      if ( i .ne. 0 ) then
        hatch = gsn_csm_hov      (wks, diff_var1(:,{lonW:lonE}), res3)
        hatch = gsn_contour_shade(hatch, -999.,0., opt)
        overlay(plot1, hatch)
      end if
      delete( diff_var1 )
    end if
    ; Dummy
    lnres                   = True
    lnres@gsLineColor       = "chartreuse4"
    ; lnres@gsLineDashPattern = 2    
    lnres@gsLineThicknessF  = 1.25
    ;
    x = (/ 100, 100 /)
    y = (/ -30., 30. /)
    plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)
    x = (/ 140, 140 /)
    y = (/ -30., 30. /)
    plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)

    ;--- Ref. line
    lnres@gsLineDashPattern = 0
    lnres@gsLineThicknessF  = 4.
    ;
    if ( i .eq. 0 ) then
      lnres@gsLineColor = "black"
      ;
      x = (/ 60, 155 /)
      y = (/ 0., 20. /)      
      plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)      
    elseif ( i .eq. 1 ) then
      lnres@gsLineColor = "blue"
      ;
      x = (/ 60, 155 /)
      y = (/ 1., 14.5 /)
      plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)
    elseif ( i .eq. 2 ) then
      lnres@gsLineColor = "black"
      lnres@gsLineDashPattern = 14
      x = (/ 60, 155 /)
      y = (/ 0., 20. /)      
      plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)      
      ;
      lnres@gsLineColor = "blue"
      x = (/ 60, 160 /)
      y = (/ 1., 14.5 /)
      lnres@gsLineDashPattern = 14
      lnres@gsLineThicknessF  = 4.
      plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)
      ;
      x = (/ 60, 160 /)
      y = (/ 0., 16.5 /)
      lnres@gsLineColor       = "red"
      lnres@gsLineDashPattern = 0
      plot1@$unique_string("dum")$ = gsn_add_polyline(wks, plot1, x, y, lnres)
    end if
    ;
    plot(i) = plot1
    ;
    delete( comvar1 )
    delete( comvar2 )
    delete( casevar1 )
    delete( casevar2 )
    ;
  end do

  ;====== Panel
  resP             = True
  resP@gsnMaximize = True
  ;
  resP@gsnPanelLabelBar         = True
  resP@lbLabelBarOn             = True
  resP@pmLabelBarHeightF        = 0.035
  resP@pmLabelBarWidthF         = 0.35
  resP@pmLabelBarOrthogonalPosF = -0.028
  resP@lbTitleOn                = True
  resP@lbLabelFontHeightF       = 0.009
  resP@lbTitleFontHeightF       = 0.009
  resP@lbTitlePosition          = "Bottom"
  resP@lbTitleString            = "OLR [W m~S~-2~N~]"
  resP@lbLabelStride            = 2
  resP@lbBoxSeparatorLinesOn    = False
  ;
  gsn_panel(wks, plot, (/ 1, nexp /), resP)
  ;
end 
