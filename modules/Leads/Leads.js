var check_advance_click = function(obj,module,recordid,stype){
	var isinit = 0;
	ld.ajax('index.php?module=Leads&action=LeadsAjax&file=setFieldsMapping&select_mapfields=yes&record='+recordid)
	.done(function(res){
		if(!empty(res)){
			$("leads_mappingfields_div").innerHTML=res;
			fnvshobj(obj,'leads_mappingfields');
			//推进确认事件
			ld('#leads_mappingfields .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
				var radio_status = ld("input[name='status']:checked").val();
				var fileure_reason = '';
				if(radio_status == 'Failedtoclose'){
					fileure_reason = ld('#fileurereason').val();
				}
				var save_status = true;
				if(radio_status == 'Upgrade'){
					var confirm_str = arrJsPopLabel['afteroperationthisrecord']
					if(!confirm(confirm_str)){
						save_status = false;
					}
				}
				if(save_status == true){
					ld.ajax('index.php?module=Leads&action=LeadsAjax&file=updateStatus&record='+recordid+'&select_status_value='+radio_status+'&fileure_reason='+fileure_reason)
					.done(function(rest){
						var restobj = eval('('+ rest +')')?eval('('+ rest +')'):JSON.parse(rest);
						if(restobj.result.value == 'success'){
							fninvshnew('leads_mappingfields');lingdangJS_DialogBox.unblock();
							//刷新页面
							if(stype == 'list'){
								getListViewEntries_js(module,'start='+restobj.start.value);	//列表
							}else{
								if(radio_status == 'Upgrade'){
									window.location.href="index.php?module="+module+'&action=index';	//列表
								}else{
									window.location.href="index.php?module="+module+'&action=DetailView&record='+recordid;	//详情页
								}
							}
						}else{
							if(!empty(restobj.error_mes.value)){
								alert(restobj.error_mes.value);
								return false;
							}
						}
					})
				}
			});
			//点击选项
			ld('#leads_mappingfields .templateprintRadio').unbind('click').on('click',function(){
				if(!empty(this.value)){
					if(this.value == 'Failedtoclose'){
						ld('#fileurereason_div').show();
					}else{
						ld('#fileurereason_div').hide();
					}
				}
			});
			//字段映射设置
			ld('#leads_mappingfields .icon-setup').unbind('click').on('click',function(){
				ld.ajax('index.php?module=Leads&action=LeadsAjax&file=setFieldsMapping&select_mapfields=no&record='+recordid)
				.done(function(res){
					if(ld('#fieldmap_div').length == 1){
						if(0 == isinit) isinit = 1;
					}
					fninvshnew('leads_mappingfields');
					var divobj = createElementDivs('fieldmap_div');
					ld(divobj).find('.D_pop_tit .D_ptita').html(arrJsPopLabel['LBL_Field']+arrJsPopLabel['FIELDSMAPPING']);
					ld(divobj).css('max-height','500px');
					ld('#fieldmap_divcontent').html(res);
					ld('#fieldmap_divcontent').css('max-height','300px');
					ld('#fieldmap_divcontent').css('border','none');
					ld('#fieldmap_divcontent').css('overflow-y','auto');
					if(0 == isinit){//初次加载的时候才显示
						ld('#fieldmap_div').css('top','28%');
					}
					//映射模块 下拉框事件
					ld("select[name^='mapmodule']").unbind('change').on('change',function(){
						var mapmodule = ld(this).val();
						var columnname = ld(this).attr('tag');
						ld('#'+columnname+"_mapfield option").each(function(){
							if(ld(this) != undefined){
								if(ld(this).attr('tag') == ''){
									ld(this).attr("selected",true);
								}else{
									if(ld(this).attr('tag') != mapmodule){
										ld(this).hide();
									}else{
										ld(this).show();
									}
								}
							}
						});
					});
					//映射 - 确定事件
					ld('#fieldmap_div .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						var mappingfields_info = {};
						var hasProp = false;
						ld("select[name^='mapmodule']").each(function(i, el) {
							var columnname = ld(this).attr('tag');
							var mapmodule = ld(this).val();
							if(ld('#'+columnname+'_mapfield') != undefined){
								var mapfield_value =  ld('#'+columnname+'_mapfield').val();
								var mapfield_disabled = ld('#'+columnname+'_mapfield').attr('disabled');
								var is_disabled = 0;
								if(mapfield_disabled == 'disabled'){
									is_disabled = 1;
								}
								if(!empty(mapfield_value)){
									mappingfields_info[columnname] = mapmodule + '|'+mapfield_value+'|'+is_disabled;
									hasProp = true;
								}
							}
						});
						if(hasProp){
							ld.ajax('index.php?module=Leads&action=LeadsAjax&file=setFieldsMapping&save=yes&record='+recordid+'&mappingfields_info='+JSON.stringify(mappingfields_info))
							.done(function(rest){
								if(rest.indexOf('success') > -1){
									fninvshnew('fieldmap_div');
									fnvshobj(obj,'leads_mappingfields');
								}
							})
						}
					});
					//映射-取消事件
					ld('#fieldmap_div .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
						fninvshnew('fieldmap_div');
						fnvshobj(obj,'leads_mappingfields');
					});
				})
			});
		}
	})
}

function averageDistribution(obj,module,popup_type){   
	getJsScript('include/js/modules/Accounts/Accounts.js',function(){averageDistribution(obj,module,popup_type);});
}