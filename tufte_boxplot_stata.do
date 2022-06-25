  ssc install palettes, replace
  ssc install colrspace, replace
  ssc install schemepack, replace
  
  sysuse auto, clear
	
	* Name of variable to use for box plot:
	local variable price
	
	* Display boxplot by which group?
	local group foreign
	
	* Choose color scheme:
	local scheme tableau
	
	
	* No need to change code ahead unless you want to add new things
	capture separate `variable', by(`group')
	
	levelsof `group', local(lvl)
	local count : word count `lvl'
	
	foreach level of local lvl {
		sort `variable'
		
		quietly summ `group'
		local max = `r(max)'
		local min = `r(min)'
		local scale = `r(max)' - `r(min)'
		local offset : display abs(`scale'*0.025)
	
		quietly summ `variable' if `group' == `level', detail
		local level = `level' + 1
		local xlab "`xlab' `level' `" "`:lab (`group') `=`level'-1''" "'"
		
		local mean_`level' = `r(mean)'
		local med_p_`level' = `r(p50)'
		local p75_`level' = `r(p75)'
		local p25_`level' = `r(p25)'
		local iqr_`level' = `p75_`level'' - `p25_`level''
		
		generate `variable'`=`level'-1'uq = `variable'`=`level'-1' if `variable'`=`level'-1' <= `=`p75_`level''+(1.5*`iqr_`level'')'
		generate `variable'`=`level'-1'lq = `variable'`=`level'-1' if `variable'`=`level'-1' >= `=`p25_`level''-(1.5*`iqr_`level'')'
		
		quietly summ `variable'`=`level'-1'uq
		local max_`level' = `r(max)'
		quietly summ `variable'`=`level'-1'lq
		local min_`level' = `r(min)'		
				
		colorpalette `scheme', nograph n(`count')	
		local 	lines `lines' ///
				(scatteri `p75_`level'' `level' `max_`level'' `level', recast(line) lpattern(solid) lcolor("`r(p`level')'") lwidth(1)) || ///
				(scatteri `p25_`level'' `level' `min_`level'' `level', recast(line) lpattern(solid) lcolor("`r(p`level')'") lwidth(1)) || ///
				(scatteri `p75_`level'' `=`level' + `offset'' `p25_`level'' `=`level' + `offset'', recast(line) lpattern(solid) lcolor("`r(p`level')'") lwidth(1)) || ///
				(scatteri `med_p_`level'' `=`level' + `offset'', ms(square) mcolor(background)) || ///
				(scatteri `mean_`level'' `=`level'', ms(oh) mcolor(background) msize(*1.25)) || ///
				(scatteri `mean_`level'' `=`level'', ms(oh) mcolor(foreground) msize(*.9)) || ///

}
	
	drop price? price???
	
	twoway `lines', ///
			ytitle("`: variable label `variable''") ///
			ylabel(2000(2000)10000, nogrid) ///
			xtitle("") ///
			xlabel(`xlab', nogrid) ///
			xscale(range(`=`min' + 0.5' `=`max' + 1.5')) ///
			scheme(white_tableau) ///
			title("{bf}Tufte Styled Box Plot", pos(11) margin(b+3) size(*.7)) ///
			subtitle("`: variable label `variable'' grouped by `: variable label `group''", pos(11) margin(b+6 t=-3) size(*.6)) ///
			legend(off)
