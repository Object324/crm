var check_advance_click = function(obj,module,recordid,stype){
	getJsScript('include/js/AdvanceStage.js',function(){
		AdvanceStage.refershtype = 'list';
		AdvanceStage.show(recordid,module);
	});
	return false;

}
/**
 创建普通销售线索
 **/
function createNormal_Leads()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var objparams=new CreatePagePopup.params();
	if(popupobj.type=="listpage")
		objparams.params['refreshpage']='no';
	CreatePagePopup.showpage('Leads',"&publicaccount=0",objparams);
}
/**
 创建公海未分配销售线索
 **/
function createpublic_notallocated()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
	var objparams=new CreatePagePopup.params();
	if(popupobj.type=="listpage")
		objparams.params['refreshpage']='no';
	CreatePagePopup.showpage('Leads',"&publicaccount=1&pool_id="+pool_id,objparams);
}
/**
 创建公海已分配销售线索
 **/
function createpublic_Allocated()
{
	var popupobj=CrmPopup.getPopupObj("last");
	var module = popupobj.module;
	var objparams=new CreatePagePopup.params();
	var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
	if(popupobj.type=="listpage")
		objparams.params['refreshpage']='no';
	var max_url="module="+module+"&action=AllocateLeads&allocatetype=3&maxaccount=1&ReportHeader=dheader&type=createpage&pool_id="+pool_id;
	ldAjax('index.php?',max_url,function(data) {
		DelProgressObjs();
		var tmpmsg = data.msg;
		var restobj = data.result;
		if(tmpmsg.indexOf('error')!='-1')
		{
			var confirm_str = arrJsPopLabel['HIGHSEASREACHEDCREATE'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		}
		else
		{
			/// var objparams=new CreatePagePopup.params();
			CreatePagePopup.showpage(module,"&publicaccount=2&pool_id="+pool_id,objparams);
		}

	});
	return false;
}
//销售线索 推进升级
function advance_stage_upgrade(recordid){
	var isinit = 0;
	ld('#rptContentLoading').show();
	// wym XUQIU20240204-09 销售线索可编辑追踪字段 从界面上获取推进的mapmodule
	var popupobj=CrmPopup.getPopupObj("last");
	if(popupobj.pagetype =='detailview_modulepage'){
		var mapmodule = ld("#"+popupobj.popupdivid+" [name=next_mapmodule]").val();
	}else{
		var advance_stage_type = ld("#"+popupobj.divid+" [name=advance_stage_type]:checked").val();
		var mapmodule = '';
		if(advance_stage_type == 'next'){
			mapmodule = ld("#"+popupobj.popupdivid+" [name=next_advance_stage]").find("option:selected").attr('data-mapmodule');
		}else{
			mapmodule = ld("#"+popupobj.popupdivid+" [name=specified_advance_stage]").find("option:selected").attr('data-mapmodule');
		}
	}
	ld.ajax('index.php?module=Leads&action=LeadsAjax&file=setFieldsMapping&select_mapfields=no&record='+recordid+'&mapmodule='+mapmodule)
	.done(function(res){
		ld('#rptContentLoading').hide();
		if(ld('#fieldmap_div').length == 1){
			if(0 == isinit) isinit = 1;
		}
		fninvshnew('leads_mappingfields');
		var divobj = createElementDivs('fieldmap_div');
		ld(divobj).find('.E_pop_tit .E_ptita').html(arrJsPopLabel['LBL_Field']+arrJsPopLabel['FIELDSMAPPING']);
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
		ld('#fieldmap_div .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
			ld('#rptContentLoading').show();
			var mappingfields_info = {};
			var hasProp = false;
			ld("select[name^='mapmodule']").each(function(i, el) {
				var columnname = ld(this).attr('tag');
				var mapmodule = ld(this).val();
				if(ld('#'+columnname+'_mapfield') != undefined){
					var mapfield_value =  ld('#'+columnname+'_mapfield').val();
					var mapfield_disabled = ld('#'+columnname+'_mapfield').attr('disabled');
                    var mapped_field = ld('#'+columnname+'_mappedfield').val();
					var is_disabled = 0;
					if(mapfield_disabled == 'disabled'){
						is_disabled = 1;
					}
					if(!empty(mapfield_value)){
                        if(mapped_field != undefined){
                            mappingfields_info[columnname] = mapmodule + '|'+mapfield_value+'|'+is_disabled+'|'+mapped_field;
                        }else{
                            mappingfields_info[columnname] = mapmodule + '|'+mapfield_value+'|'+is_disabled;
                        }
						hasProp = true;
					}
				}
			});
			if(hasProp){
				ld.ajax('index.php?module=Leads&action=LeadsAjax&file=setFieldsMapping&save=yes&record='+recordid+'&mappingfields_info='+JSON.stringify(mappingfields_info)+'&mapmodule='+mapmodule)// wym XUQIU20240204-09 映射模块是客户商机时,是从客户再关联创建商机
				.done(function(rest){
					ld('#rptContentLoading').hide();
					if(rest.indexOf('success') > -1){
						fninvshnew('fieldmap_div');
                       
						//fnvshobj(obj,'leads_mappingfields');
						DelProgressObjs();
					}
				})
			}
		});
		//映射-取消事件
		ld('#fieldmap_div .E_pbtn .E_pbtncancel').unbind('click').on('click',function(){
			fninvshnew('fieldmap_div');
			//fnvshobj(obj,'leads_mappingfields');
		});
	})
}







function cls_PublicLeads(){
	var that = this;
	//公海池 、公海已分配、公海未分配 标签点击事件
	this.showCustomType = function(inputobj){
		var popupobj=CrmPopup.getPopupObj("last");
		ld('#rptContentLoading').show();
		if(ld(inputobj).prop("tagName") == 'SELECT'){
			var pool_id = ld(inputobj).val();
			var publicaccounttype = ld(inputobj).find("option:selected").attr("accounttype");
		}else{
			var pool_id = ld(inputobj).data('pool_id');
			var publicaccounttype =  ld(inputobj).data('accounttype');
			if(pool_id == undefined){
				pool_id = ld(inputobj).attr('pool_id');
				publicaccounttype =  ld(inputobj).attr('accounttype');
			}else{
				pool_id = pool_id.toString();
			}
		}
		var viewname = encodeURIComponent(ld("#"+popupobj.divid+" [name=viewname]").val());
		var searchScope = '';
		if(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]")!=null)
			searchScope= encodeURIComponent(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]").val());
		ld("#"+popupobj.divid+" [name=publicaccounttype]").val(publicaccounttype)
        var urlstring = "module=Leads&action=LeadsAjax&file=ListView&start=1&SearchScope="+searchScope+"&pagepublicaccounttype="+publicaccounttype+"&pool_id="+pool_id;
         //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   urlstring += '&isshowModuleListTree=yes';
    	}
		var listview_page=new ListView_Page('Leads',urlstring,"pagecontent1");
		listview_page.callback_fun=function()
		{
			popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
			setContentHeight(module);//计算内容高度   
			IsFrameElement();
		}
		listview_page.page();
	}

	//转换公海 - 批量
	this.mass_transfer = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var select_options = ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
		var publicaccounttype = ld("#"+popupobj.divid+" [name=publicaccounttype]").val();
		var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();
		var surl = 'index.php?module=Leads&action=LeadsAjax&file=MassTransferLeads&select_ids='+select_options+'&publicaccounttype='+publicaccounttype+'&pool_id='+pool_id;
		//基本、高级查询条件
		if(!empty(searchtype_btn)){
			surl += '&'+getUrlString(searchtype_btn);
			surl += "&query=true&ajax=true&search=true";
		}
		if(select_options == 'all'){
		  //zkt 模块树结构显示增加条件，获取树结构点击条件
                if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
					surl += '&isshowModuleListTree=yes';
            	}
			//获取全选数量
			var selectlen = ld("#"+popupobj.divid+" [name=numOfRows]").val();
			if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
				RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
				//确定事件
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
					that.show_transfer(surl);
				});
			}
			else {
				that.show_transfer(surl);
			}
		}else{
			if(select_options != ''){
				var x = select_options.split(';');
				var count = x.length;
				if (parseInt(count) - 1 > parseInt(getMaxMassOperationLimit())) {
					var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count) - 1, getMaxMassOperationLimit(), '');
					//创建提示弹出层
					RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
					//确定事件
					ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
						that.show_transfer(surl);
					});
				} else {
					that.show_transfer(surl);
				}
			}else{
				MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
		}
	}
	//显示转换公海界面
	this.show_transfer = function(surl){

		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
				crmPopupobj.prevshow();
				crmPopupobj.setParams(data.result.title,that.save_mass_transfer,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.show(data.result.content);
				crmPopupobj.center();
				ld("#"+popupobj.divid+" [name=transfer]").unbind('click').on('click',function(){
					if(ld(this).val() == 'transfer_out'){
						ld("#"+popupobj.divid+" [name=div_select_public_account_pool]").hide();
					}else{
						ld("#"+popupobj.divid+" [name=div_select_public_account_pool]").show();
					}
				});
				//that.set_account_public_bind();
			}else{
                MessagePopup.TipOne_warning(data.msg);
            }
		})
	}
	//转换公海 - 单条记录，如列表 - 详情页
	this.account_transfer = function(record){
		if(!empty(record)){
			var popupobj=CrmPopup.getPopupObj("last");
			var publicaccounttype = ld("#"+popupobj.divid+" [name=publicaccounttype]").val();
			var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();
			var surl = 'index.php?module=Leads&action=LeadsAjax&file=MassTransferLeads&select_ids='+record+';'+'&publicaccounttype='+publicaccounttype+'&pool_id='+pool_id+'&popupobj_type='+popupobj.type;
			that.show_transfer(surl);
		}
	}
	//转换公海 - 保存
	this.save_mass_transfer = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var prevpopupobj=CrmPopup.getPopupObj('lastprev');
		var transfer = encodeURIComponent(ld("#"+popupobj.divid+" [name=transfer]:checked").val());
		var select_pool_id = 0;
		if(transfer == 'transfer_to' && ld("#"+popupobj.divid+" [name=select_public_account_pool]").val() != undefined){
			select_pool_id = ld("#"+popupobj.divid+" [name=select_public_account_pool]").val();
			if(select_pool_id == 0 || select_pool_id == ''){
				RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Pleaseselectatleastonehighseas']);
				return false;
			}
		}
		var record = ld("#"+popupobj.divid+" [name=record]").val();
		if(record == ''){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
			
		}
		var urlstring = 'index.php?module=Leads&action=LeadsAjax&file=ConvertLeads&transfer='+transfer+"&select_pool_id="+select_pool_id;
		if(prevpopupobj.pagetype =='detailview_modulepage'){
			urlstring += '&mode=detail';
		}else{
			urlstring += '&mode=list';
		}
		ldAjax(urlstring,{idstring:record},function(restobj){
			popupobj.CancelEvent();
			DelProgressObjs();
			if(restobj.code == -1){//上限错误提示
				RemindsMsg("","LdPopWidth400px","","yes","yes",restobj.msg);
				return false;
			}
			if(prevpopupobj.type == 'detailviewpage'){
				var tmparra=new Array();
				tmparra.push(recordid);
				var refreshlistmodules = new Array('Leads');
				var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',getEmptyValueInfo(),tmparra);
				tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
			}else{
				var massConvert_popupobj = CrmPopup.load(restobj.title.value,'','','LdPopWidth600px',popupobj.module,'',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL']);
				var massConvert_html = '<div id="massConvertcontent" class="pop_remind_content">'+restobj.log.value+'</div>';
				massConvert_popupobj.show(massConvert_html);
				ld('#'+massConvert_popupobj.divid+'_btnok').unbind('click').on('click',function(){
					massConvert_popupobj.CancelEvent();
					if(document.getElementById('allselectedboxes') != undefined){
						document.getElementById('allselectedboxes').value='';   
					}
					if(document.getElementById('selectedboxes') != undefined){
						document.getElementById('selectedboxes').value='';   
					}
					getListViewEntries_js('Leads',restobj.start.value);//刷新页面
				});
				ld('#'+massConvert_popupobj.divid+'_btncancel').unbind('click').on('click',function(){
					if(document.getElementById('allselectedboxes') != undefined){
						document.getElementById('allselectedboxes').value='';
					}
					if(document.getElementById('selectedboxes') != undefined){
						document.getElementById('selectedboxes').value='';
					}
					getListViewEntries_js('Leads',restobj.start.value);//刷新页面
				});

			}
			return false;
		})
	}
	
	//公海参数设置
	this.set_account_public=function(){
		getJsScript('include/js/cls_publicpool_set.js', function () {
			var publicpool_setobj = new cls_publicpool_set('Leads');
			publicpool_setobj.CreatePopup();
		});
		return '';
		var surl = 'index.php?module=Leads&action=LeadsAjax&file=setPublicLeads';
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.save_account_public,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,""); 
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
				crmPopupobj.highersearchobj=new HigherSearchGroup("adv_filter_div");
                crmPopupobj.highersearchobj.columns_block=data.result.columns_block;//查询字段
                crmPopupobj.highersearchobj.fLabels=data.result.flabels;//查询条件下拉框（等于，不等于，区间 ，大于)
                crmPopupobj.highersearchobj.source=data.result.source;
                crmPopupobj.highersearchobj.foption=data.result.foption;//查询条件下拉框的html
                crmPopupobj.highersearchobj.criteria_groups=data.result.criteria_groups;//高级查询
                crmPopupobj.highersearchobj.mandatorycheck=data.result.mandatorycheck;
                crmPopupobj.showvalues=data.result.showvalues;
                crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
                crmPopupobj.viewnamelabel=data.result.viewnamelabel;
                crmPopupobj.modulelabel=data.result.modulelabel;
                crmPopupobj.highersearchobj.btn_addnewcondtiontext=data.result.btn_addnewcondtiontext;//高级查询 新条件 按钮文字
                crmPopupobj.highersearchobj.btn_addnewcombinationtext=data.result.btn_addnewcombinationtext;//高级查询　“新组合"按钮文字
				var  fori=0;
                if(data.result.criteria_groups)
           	    {
                   	      
					ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
						var GROUP_COLUMNS=GROUP_CRITERIA.columns;
						crmPopupobj.highersearchobj.addConditionGroup();
							ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
								crmPopupobj.highersearchobj.addConditionRow(GROUP_ID);
								var advft_column_index_count=crmPopupobj.highersearchobj.advft_column_index_count;
								var conditionColumnRowElement = CrmPopup.findHtmlobj(crmPopupobj.divid,'fcol'+advft_column_index_count);
								conditionColumnRowElement.val(COLUMN_CRITERIA.columnname) ;
                                //zkt 20230526 高级查找条件加载
                                var text = conditionColumnRowElement.find("option:selected").text();
                    			if(CrmPopup.findHtmlobj(crmPopupobj.divid,"cmb_span_optiontext_fcol"+advft_column_index_count).length>0){
                                    CrmPopup.findHtmlobj(crmPopupobj.divid,"cmb_span_optiontext_fcol"+advft_column_index_count).val(text);
                                }
								crmPopupobj.highersearchobj.updatefOptions(conditionColumnRowElement, 'fop'+advft_column_index_count);
								CrmPopup.findHtmlobj(crmPopupobj.divid, 'fop'+advft_column_index_count).val(COLUMN_CRITERIA.comparator);
								crmPopupobj.highersearchobj.addRequiredElements(advft_column_index_count);
								var columnvalue = COLUMN_CRITERIA.value;
								if(COLUMN_CRITERIA.comparator == 'bw' && columnvalue != '') {
									var values = columnvalue.split(",");
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(values[0]) ;
									if(values.length == 2 && CrmPopup.isExistsObj(crmPopupobj.divid,'fval_ext'+advft_column_index_count))
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval_ext'+advft_column_index_count).val(values[1]) ;
								}
								else 
								{
									if(columnvalue =='Accepted')
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Accepted);
									else if(columnvalue =='Rejected')
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Rejected);
									else{
										var values = columnvalue.split(",");
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val( values[0]);
									}
								}
							});
								
							ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
							   //查询字段下拉框
								if(CrmPopup.isExistsObj(crmPopupobj.divid,'fcon'+fori)) 
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fcon'+fori).val(COLUMN_CRITERIA.column_condition);
								  fori=fori+1;
							});
								
						});
						ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
							//组 且/或
							var GROUP_CRITERIA=data.result.criteria_groups[GROUP_ID];
							if(CrmPopup.isExistsObj(crmPopupobj.divid,'gpcon'+GROUP_ID)) 
								CrmPopup.findHtmlobj(crmPopupobj.divid,'gpcon'+GROUP_ID).val(GROUP_CRITERIA.condition);
					   });
					   
				}
				else
					crmPopupobj.highersearchobj.addNewConditionGroup();
				that.arr_recovery_modules = data.result.arr_recovery_modules;
				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();
				that.set_account_public_bind();
			}
		})
    }
    this.showKehu001UserName=function(){
       
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                     //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
    }
	//公海参数设置界面按钮事件绑定
	this.set_account_public_bind=function(){
		var popupobj=CrmPopup.getPopupObj("last");
		//公海设置
        
        this.showKehu001UserName();
		//普通客户数量上限
		ld("#"+popupobj.divid+" [name=limit_type]").unbind('click').on('click',function(){
			var limit_type = ld(this).attr('value');
			if(limit_type == 'role'){
				ld("#"+popupobj.divid+" [name=select_limit_type_role]").show();
				ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',true);
			}else if(limit_type == 'user'){
				ld("#"+popupobj.divid+" [name=select_limit_type_role]").hide();
				ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',false);
			}else{//不限制
				ld("#"+popupobj.divid+" [name=select_limit_type_role]").hide();
				ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',true);
			}
		});
		ld("#"+popupobj.divid+" [type=checkbox]").unbind('click').on('click',function(){
			var that_check = this;
			var check_name = ld(that_check).attr('name');
			if(ld(that_check).is(':checked') == true){
				//勾选“启用公海”时，下面增加选项：显示“全部（含所有公海）页签，默认勾选
				if(check_name == 'status'){
					ld("#"+popupobj.divid+" [name=div_show_publicaccount_tab]").show();
					ld("#"+popupobj.divid+" [name=show_publicaccount_tab]").prop('checked',true);
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").show();
					ld("#"+popupobj.divid+" [name=div_show_commonaccount_tab]").show();
					ld("#"+popupobj.divid+" [name=common_account_rule_table]").show();
					ld("#"+popupobj.divid+" [name=show_commonaccount_tab]").prop('checked',true);
					ld("#"+popupobj.divid+" [name=div_is_commonaccount_create]").show();
					ld("#"+popupobj.divid+" [name=is_commonaccount_create]").prop('checked',true);
					ld("#"+popupobj.divid+" [name=div_show_default_tab]").show();//设置默认页签
					// ld("#"+popupobj.divid+" [name=div_show_default_tab] option[value='COMMONACCOUNT']").prop("selected", true);
				}
				//如果勾选“显示“全部（含所有公海）页签”参数，则下面增加选项：默认“全部（含所有公海）页签。默认不勾选
				if(check_name == 'show_publicaccount_tab'){
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").show();
					//ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").prop('checked',false);
				}
				if(check_name == 'account_rule'){
					ld("#"+popupobj.divid+" [name=account_rule_div]").show();
					ld("#"+popupobj.divid+" [name=account_rule_advance_div]").show();
				}
				
			}else{
				if(check_name == 'status'){
					ld("#"+popupobj.divid+" [name=div_show_publicaccount_tab]").hide();
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").hide();
					ld("#"+popupobj.divid+" [name=show_publicaccount_tab]").prop('checked',false);
					//ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").prop('checked',false);
					ld("#"+popupobj.divid+" [name=account_rule_div]").hide();
					ld("#"+popupobj.divid+" [name=account_rule_advance_div]").hide();
					ld("#"+popupobj.divid+" [name=account_rule]").prop('checked',false);
					ld("#"+popupobj.divid+" [name=div_show_commonaccount_tab]").hide();
					ld("#"+popupobj.divid+" [name=common_account_rule_table]").hide();
                    //edit:can 20210409 45412: （https://61mis.com/kfbcrm [^]）公海参数设置弹出层中，启用公海再反勾选不启用公海时，“允许新建“普通客户””参数应该不显示
                    ld("#"+popupobj.divid+" [name=is_commonaccount_create]").prop('checked',false);
                    
                    ld("#"+popupobj.divid+" [name=div_is_commonaccount_create]").hide();
					ld("#"+popupobj.divid+" [name=div_show_default_tab]").hide();//设置默认页签
                    
				}
				if(check_name == 'show_publicaccount_tab'){
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").hide();
					//ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").prop('checked',false);
				}
				if(check_name == 'account_rule'){
					ld("#"+popupobj.divid+" [name=account_rule_div]").hide();
					ld("#"+popupobj.divid+" [name=account_rule_advance_div]").hide();
				}
			}
			popupobj.setScrollDivMaxHeight();
			popupobj.center();
		});
		//绑定公海超级管理员删除事件
		if(ld('#'+popupobj.divid+' ul.reader-bar-list .remove-h') != undefined){
			ld('#'+popupobj.divid+' ul.reader-bar-list .remove-h').unbind('click').click(function(){
				var remove_userid = ld(this).parent().attr('itemid');
				ld(this).parent().remove();
				var select_administrators_ids = [];
				var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
				select_administrators_ids = select_administrators_id.split(',');
				select_administrators_ids.splice(ld.inArray(remove_userid,select_administrators_ids),1);
				ld("#"+popupobj.divid+" [name=select_administrators_id]").val(select_administrators_ids.join(','));
				return false;
			});
		}
		//公海客户参与回收，回收规则条件逻辑关系
		ld("#"+popupobj.divid+" [name=completeopt]").unbind('change').on('change',function(){
			if(ld(this).val() == 'and'){
				ld("#"+popupobj.divid+" [name=completeopt_and]").show();
				ld("#"+popupobj.divid+" [name=completeopt_or]").hide();
			}else{
				ld("#"+popupobj.divid+" [name=completeopt_and]").hide();
				ld("#"+popupobj.divid+" [name=completeopt_or]").show();
			}
		})
		that.set_account_public_select_user_bind();
		
	}

	//公海超级管理员
	this.set_account_public_select_user_bind=function(){
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name=select_administrators],[name=select_administrators_div]").unbind('click').on('click',function(){
			var scopepopupobj;//自定义弹出层页面html，绑定事件
			var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
			var module = 'Leads';
			var select_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
			getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
				scopepopupobj =  new ScopePopupObj(module);
				scopepopupobj.popup_caption_value = popup_caption_value;//标题title
				getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
				   cls_ScopePopup.prop.popup_module = module;//模块
				   cls_ScopePopup.prop.popup_value = select_id;
				   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
				   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
					//重写确认按钮事件
					scopepopupobj.setEventBtnOk=function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
							if(empty(cls_ScopePopup.return_obj.return_id)){
								var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
								RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
								return false;
							}else{
								ld("#"+popupobj.divid+" [name=select_administrators_id]").val(cls_ScopePopup.return_obj.return_id);
								ld("#"+popupobj.divid+" [name=select_administrators_name]").html(cls_ScopePopup.return_obj.return_name);
								var userid = cls_ScopePopup.return_obj.return_id.split(',');
								var username = cls_ScopePopup.return_obj.return_name.split(',');
								//每次确认之前，先情况之前记录
								ld('#'+popupobj.divid+' ul.reader-bar-list').empty();
								for(var i = 0; i < userid.length; i++){
									//添加新的li
									ld('#'+popupobj.divid+' ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
									//绑定删除事件
									ld('#'+popupobj.divid+' ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
										var liuserid = ld(this).parent().attr('userid');
										ld('#'+popupobj.divid+' ul.reader-bar-list li[userid='+liuserid+']').remove();
										return false;
									});
								}
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							}
                            that.showKehu001UserName();
						});
                         
					}
				});
			});
		});
	}
	this.changeRule = function(type,tabname,obj)
	{
		var selectindex=obj.selectedIndex;
		var selectvalue=obj.options[selectindex].value;
		if(selectvalue=='yes')
		{
			var spanname=type+'_'+tabname+'_span_recycle';
			var hidespanname=type+'_'+tabname+'_span_single';
		}
		else
		{
			var spanname=type+'_'+tabname+'_span_single';
			var hidespanname=type+'_'+tabname+'_span_recycle';
		}
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name="+spanname+"]").show();
		ld("#"+popupobj.divid+" [name="+hidespanname+"]").hide();
	}
	//公海参数设置 - 保存
	this.save_account_public=function(){
		var expre=/^[0-9]*[1-9][0-9]*$/;
		var popupobj=CrmPopup.getPopupObj("last");
		var _status = 'no';
		var show_publicaccount_tab = 'no';
		var default_publicaccount_tab = 'no';
		var before_status = 'no';
		var show_commonaccount_tab = 'no';
		var show_account_rule = 'no';
		var is_commonaccount_create = 'no';

		//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（公海参数设置保存）
		//普通客户数量上限
		var limit_type = ld("#"+popupobj.divid+" [name=limit_type]:checked").val();
		var limit_count = ld("#"+popupobj.divid+" [name=limit_count]").val();
		if(limit_type == 'user'){
			if(!(expre.test(trim(limit_count)))){
				audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=limit_count]").attr('label')+arrJsPopLabel['NUMONLYINT']);
				ld("#"+popupobj.divid+" [name=limit_count]").focus();
				return false;
			}
		}
		//启用公海
		if(ld("#"+popupobj.divid+" [name=status]").is(':checked') == true){
			_status = 'yes';
		}
		//显示 “全部（含所有公海）”页签
		if(ld("#"+popupobj.divid+" [name=show_publicaccount_tab]").is(':checked') == true){
			show_publicaccount_tab = 'yes';
		}
		//默认 “全部（含所有公海）”页签 
		/*if(ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").is(':checked') == true){
			default_publicaccount_tab = 'yes';
		}*/
		//显示 “全部（普通客户）”页签 
		if(ld("#"+popupobj.divid+" [name=show_commonaccount_tab]").is(':checked') == true){
			show_commonaccount_tab = 'yes';
		}
		//普通客户自动回收规则设置
		if(ld("#"+popupobj.divid+" [name=account_rule]").is(':checked') == true){
			show_account_rule = 'yes';
		}
		//允许创建普通线索
		if(ld("#"+popupobj.divid+" [name=is_commonaccount_create]").is(':checked') == true){
			is_commonaccount_create = 'yes';
		}
		if(ld("#"+popupobj.divid+" [name=before_status]").val() != undefined){
			before_status = ld("#"+popupobj.divid+" [name=before_status]").val();
		}
		//公海超级管理员设置
		var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
		if(select_administrators_id == '' && _status == 'yes'){
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Pleasesettheadministratorsjspop1']);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				ld("#"+popupobj.divid+" [name=select_administrators]").click();
			})
			return false;
		}
		if(_status == 'no'){
			show_publicaccount_tab = 'no';
			default_publicaccount_tab = 'no';
			select_administrators_id = '';
		}

		//您启用了公海客户，需要设置回收条件
		var  atleastonechoose=false;
		if(show_account_rule == 'yes'){
			ld("#"+popupobj.divid+" [accounttype=chkcomplete]").each(function () {
				if(ld(this).is(":checked"))
				{
					atleastonechoose=true;
					return false;
				}
			});
			if(!atleastonechoose)    
			{
				confirm_str = arrJsPopLabel['ATLEASTONECONDITIONSENABLED'];
				audioRemindsMsg("","","","","",confirm_str);
				return false;
			}
			//自动回收规则设置天数必须输入大于等于1的整数！
			var daysbol=true;
			ld.each(that.arr_recovery_modules,function(index,tmpmodule){
				if(ld(" [name="+tmpmodule+"_completechk]").prop("checked"))
				{
					if(ld(" [name=changerule_complete_"+tmpmodule+"]").val()=='no')
					{
						//单次回收
						var textvalue=ld(" [name="+tmpmodule+"_single_completedays]").val();
					}
					else
					{
						//循环回收
						//ContactRecords_completedays
						var textvalue=ld(" [name="+tmpmodule+"_completedays]").val();
					}
					
					if((!/^\d+$/.test(textvalue)||textvalue<1))
					{
						daysbol=false;
						return false;
					}
				}
			 })
			if(!daysbol)
			{
				confirm_str = ld("#"+popupobj.divid+" [name=auto_recovery_rule_label]").val() + arrJsPopLabel['DAYSMUSTGREATERQUZERO'];
				audioRemindsMsg("","","","","",confirm_str);
				return false;
			}
			if(popupobj.highersearchobj.checkAdvancedFilter()==false) 
			{
					return false;
			}
		}
		var form_data = new FormData(ld("#"+popupobj.divid+" [name=save_public_account]")[0]);
		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: form_data,
			url: 'index.php?module=Leads&action=LeadsAjax&file=savePublicLeads',
			success: function(data) {
				popupobj.CancelEvent();
				ld('#rptContentLoading').hide();
				var module = getUrlParam("pageto_module");
				if(module=='Settings')
					return;
				var tmparra=new Array();
				var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
				//服务单保存后刷新服务单的历史记录(查看界面)
				var refreshlistmodules = new Array('Leads');
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				return false;
				
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		  })
		return false;

	
    }
    
    
    
        this.selectchoice=function()
        {
           	var select_options = document.getElementById('allselectedboxes').value;
             var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
           
        	var numOfRows = document.getElementById('numOfRows').value;
        	var excludedRecords = $('excludedRecords').value;
           
        	if(select_options=='all') {
        		var idstring = select_options;
        		var skiprecords = excludedRecords.split(";");
               var end_str=skiprecords[skiprecords.length-1];
               
        		var count = skiprecords.length;
                //16981: 客户>序时簿,关于将客户转公海/转普通的问题
                if(end_str=='')
                 {
                    count-=1;
                 }
        		if(count > getMaxMassOperationLimit()) {
        
        		  //16551: 客户>序时簿,关于批量操作的说明信息有误的问题,edit:can count-1变为count
        			var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
        
        			if(confirm(confirm_str)) {
        				var confirm_status = true;
        			} else {
        				return false;
        			}
        		} else {
        			confirm_status = true;
        		}
        
        		if(confirm_status) {
        	
                   return true;
        		}
        	} else {
        		var x = select_options.split(';');
        		var count = x.length;
                var end_str=x[x.length-1];
              //16981: 客户>序时簿,关于将客户转公海/转普通的问题
                 if(end_str=='')
                 {
                    count-=1;
                 }
        		if(count > 0) {
        			idstring = select_options;
        			if(count > getMaxMassOperationLimit()) {
        				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
        				if(confirm(confirm_str)) {
        					confirm_status = true;
        				} else {
        					return false;
        				}
        			} else {
        				confirm_status = true;
        			}
        
        			if(confirm_status) {
        			       
                          return true;
        			}
        		} else {
                    RemindsMsg("","LdPopWidth400px","","yes","yes","");
        			return false;
        		}
        	}
            return false;
        }
            
        /*
        edit:can
        reason:批量分配保存
        */
        this.massAllocate=function(Allocatetype)
        {
        
            if(Allocatetype != 2){
        		if(!that.selectchoice()){
        			return false;
        		}
        	}
        	var select_options = document.getElementById('allselectedboxes').value; 
        	this.massAllocate_Load(select_options,Allocatetype);
           
        }//11903;3
         var http_reqfield;
         var intervalrow = 2; //默认最大分配数为20
        this.massAllocate_Load=function(select_options,allocatetype,assigneduserid,assignedusername)
        {  
        
            var confirm_str="";
            var gstart='';
             if(document.forms['massdelete'].pagenum!=undefined)
             {
                 gstart="&start="+document.forms['massdelete'].pagenum.value;
             }
             else
             {
                gstart="&start="+document.forms['massdelete'].pagenum[0].value;
             }
            
            var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
            var accounttype=document.massdelete.publicaccounttype.value; 
            var assignids=document.getElementById("assign_name").value;
            var idlist=document.getElementById("allselectedboxes").value; 
            var viewname=document.getElementById("viewname").value;  
           	var excludedRecords = $('excludedRecords').value;
        	 //客户公海分配 - 列表
        	if(allocatetype == 2 && selectType == 2){
        		//select_options = idlist = document.EditView.record.value;
                 idlist=select_options;                
        	}
            var url="module=Leads&action=LeadsAjax&file=AllocateLeads&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&maxaccount=1&excludedRecords="+excludedRecords+"&viewname="+viewname+"&SearchScope="+searchScope;
          
            if(allocatetype==2)
            {
                  var userid=assigneduserid;
                  //var userid=document.getElementById('assigned_user_id').value;
                  url=url+"&userid="+userid+"&assign_name="+assignids+"&id="+idlist;
            }
            
        	var popupobj=CrmPopup.getPopupObj("last");
        	url += '&pool_id=' + ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
        	//zkt 树结构显示增加条件，获取树结构点击条件
            if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
        	   url += '&isshowModuleListTree=yes';
        	}
			ldAjax('index.php?',url,function(data) {
				DelProgressObjs();
				var tmpmsg = data.msg;
				var restobj = data.result;
				if(data.code == -1){
					if(allocatetype==3)//领取
					{
						if(tmpmsg.indexOf("###error###2")!=-1)
						{
							confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENALLOCATE'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
						else if(tmpmsg.indexOf("###error###3")!=-1)
						{
							confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENRECEIVERD_RECEIVER'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
						else if(tmpmsg.indexOf("###error###")!=-1)
						{
							//您拥有的公海客户数量已经达到上限，领取失败！
							confirm_str = arrJsPopLabel['HIGHSEASREACHEDTHELIMITCOLLECT'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
					}
					if(allocatetype==2)//分配
					{
						if(tmpmsg.indexOf("###error###2")!=-1)
						{
							confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENALLOCATE_ALLOCATEFAILUR'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						}
						else if(tmpmsg.indexOf("###error###3")!=-1)
						{
							confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENRECEIVERD'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						}
						else if(tmpmsg.indexOf("###error###")!=-1)
						{
							var username=assignedusername;
							//var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
							//拥有的公海客户数量已经达到上限，分配失败！
							confirm_str = username+arrJsPopLabel['HIGHSEASREACHEDTHELIMITALLOCATION'];
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
					}
				}
				else if(data.code == 1){
					var results=restobj;
					var allowcount=results[1];
					var selectcount=results[2];
					var havecount=results[3];
					var revenuecount=allowcount-havecount;
					if(allocatetype==3)
					{
						//confirm_str="您选择了"+selectcount+"条记录，您最多只能再领取"+revenuecount+"条，是否继续领取前"+revenuecount+"条记录？";
						confirm_str=arrJsPopLabel['YOUSELECTED']+selectcount+arrJsPopLabel['CANONLYRECOLLECT']+revenuecount+arrJsPopLabel['WHETHERCONTION']+revenuecount+arrJsPopLabel['RECORDSNO'];
						if(revenuecount>=selectcount)
						{
							confirm_str='';

						}
						else
						{
							var accountgets=results[4].split(";");
							select_options="";
							for(var i=0;i<revenuecount;i++)
							{
								select_options=select_options+accountgets[accountgets.length-1-i]+";";
							}
						}
						if(confirm_str=='')
						{

						}
						else if(!confirm(confirm_str))
						{
							ld('#rptContentLoading').hide();
							return false;
						}
						var receiveUrl = "index.php?module=Leads&action=LeadsAjax&file=AllocateLeads&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&assign_name="+assignids+"&id="+idlist+"&viewname="+viewname;

						//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
						receiveUrl= cls_encryptyurl.Puyoung_Encryptyurl(receiveUrl,'');
						http_reqfield=that.createfieldXMLHTTP();
						http_reqfield.open("POST",receiveUrl,false);
						isDuplicate=false;
						http_reqfield.onreadystatechange=that.setAllocateAccount;
						http_reqfield.setRequestHeader("If-Modified-Since","0");
						http_reqfield.send();
						//点击确认
						ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
							if(isDuplicate == false)
							{
								var tmparra=new Array();
								var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
								//服务单保存后刷新服务单的历史记录(查看界面)
								var refreshlistmodules = new Array('Leads');
								tmpobj.eachrefreshlistbyModules(refreshlistmodules);

							}
						});
					}
					else
					{

						var userid=assigneduserid;
						var username=assignedusername;
						//confirm_str="您选择了"+selectcount+"条记录，"+username+"最多只能再分配"+revenuecount+"条，是否继续分配前"+revenuecount+"条记录？";
						confirm_str=arrJsPopLabel['YOUSELECTED']+selectcount+arrJsPopLabel['RECORDS']+username+arrJsPopLabel['MAXREDISTRIBUTION']+revenuecount+arrJsPopLabel['WHETHERASSIGNED']+revenuecount+arrJsPopLabel['RECORDSNO'];
						if(revenuecount>=selectcount)
						{
							//confirm_str="确定要分配选定的"+selectcount+"条记录吗？";
							confirm_str=arrJsPopLabel['DISTRIBUTIONSELECTED']+selectcount+arrJsPopLabel['RECORDSNO'];
						}
						else
						{
							var allocates=results[4].split(";");
							select_options="";


							for(var i=0;i<revenuecount;i++)
							{
								select_options=select_options+allocates[allocates.length-1-i]+";";
							}

						}

						if(allocatetype == 2){
							username = encodeURIComponent(username);
							var assign_name = document.getElementById('assign_name').value;

							// @edit:liushuai,2021-03-11,reason:【ID1001390】客户模块公海未分配页签批量分配增加进度条

							if (revenuecount > 20){
								intervalrow = Math.ceil(revenuecount / 10); //向上取整
							}
							//duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
							if(intervalrow >20){
								intervalrow = 20;
							}
							that.startMassUnallocated(select_options,allocatetype, viewname, userid, username, assign_name, idlist, revenuecount,0);

						}else{
							if(confirm(confirm_str))
							{
								username=encodeURIComponent(username);
								var assign_name=document.getElementById('assign_name').value
								var receiveUrl ="index.php?module=Leads&action=LeadsAjax&file=AllocateLeadsidstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;

								//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
								receiveUrl= cls_encryptyurl.Puyoung_Encryptyurl(receiveUrl,'');
								http_reqfield=that.createfieldXMLHTTP();
								http_reqfield.open("POST",receiveUrl,false);
								isDuplicate=false;
								http_reqfield.onreadystatechange=that.setAllocateAccount;
								http_reqfield.setRequestHeader("If-Modified-Since","0");
								http_reqfield.send();
								if(selectType=1)
								{
									var tmparra=new Array();
									var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
									//服务单保存后刷新服务单的历史记录(查看界面)
									var refreshlistmodules = new Array('Leads');
									tmpobj.eachrefreshlistbyModules(refreshlistmodules);

								}
								else
								{
									ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
										if(isDuplicate == false)
										{
											var tmparra=new Array();
											var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
											//服务单保存后刷新服务单的历史记录(查看界面)
											var refreshlistmodules = new Array('Leads');
											tmpobj.eachrefreshlistbyModules(refreshlistmodules);

										}
									});
								}
							}
						}
					}
				}else if(data.code == 'validata'){
					RemindsMsg("","LdPopWidth400px","","yes","",tmpmsg);
					return false;
				}
				else{


					return false;
				}


			});
        }
        
       this.islast=false;  
       var that=this;       
        // @edit:liushuai,2021-03-11,reason:【ID1001390】客户模块公海未分配页签批量分配增加进度条（将http_reqfield.onreadystatechange的回调函数setAllocateAccount抽离出来和领取逻辑分开）
        this.startMassUnallocated=function(select_options,allocatetype, viewname, userid, username, assign_name, idlist, revenuecount, startrow) {
           var endrow=startrow+intervalrow;
            var receiveUrl = "index.php?module=Leads&action=LeadsAjax&file=AllocateLeads&idstring=" + select_options + "&allocatetype=" + allocatetype + gstart + "&viewid=" + viewname + "&userid=" + userid + "&username=" + username + "&assign_name=" + assign_name + "&id=" + idlist;
            receiveUrl += "&startrow="+startrow+"&endrow="+endrow;

			//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
			receiveUrl= cls_encryptyurl.Puyoung_Encryptyurl(receiveUrl,'');
            http_reqfield = that.createfieldXMLHTTP();
            http_reqfield.open("POST", receiveUrl, true);
            isDuplicate = false;
            
            
            http_reqfield.onreadystatechange = function () {

                if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
                {
					var data =eval('('+ http_reqfield.responseText +')')?eval('('+ http_reqfield.responseText +')'):JSON.parse(http_reqfield.responseText);
					var results=data.result;
        
                    var tmppopupobjobj;
                    if(startrow==0)
                    {
                        tmppopupobjobj=ProgressPopup.load(arrJsPopLabel['BATCHALLOCATION'],"","",500,'Leads',"","","","");
                        tmppopupobjobj.show();
                    }
                    else{
                        tmppopupobjobj=CrmPopup.getPopupObj('last');
                    }
        
                    var maxrows=parseInt(results[4]);
                    var percent=parseInt(endrow/maxrows*100);
                    
         
                    tmppopupobjobj.setPercentWidth(percent);
                    tmppopupobjobj.setTotalNum(results[4]);
                    tmppopupobjobj.setCurNum(startrow);
                       
                   
                    if(parseInt(endrow)<parseInt(results[4]))
                    {
                       
                        that.startMassUnallocated(select_options,allocatetype, viewname, userid, username, assign_name, idlist, revenuecount, endrow );
                        return false;
                    }
                     
                    else{
                        tmppopupobjobj.CancelEvent();
                    }
        
                    puyoungJS_DialogBox.unblock();

					//wym BUG20240117-74 分配一条时，提示信息改为成功分配
					if(results[1]==1){
						var prompt = arrJsPopLabel['DISTRIBUT'];
					}else{
						var prompt = arrJsPopLabel['BATCHALLOCATION'];
					}
                    //0046198: （81mis.com/kfbcrm）客户管理-客户，“默认公海”池，公海未分配页签，在未分配客户列表处操作公海分配，页面没有小刷新也没有成功分配弹窗 注释if
                    // if(selectType == 1){
                        if(results[2] == 0)
                        {
                            confirm_str = arrJsPopLabel['SUCCESS']+prompt+" "+results[1]+" "+arrJsPopLabel['RECORDS'];
							//wym 240126 BUG20240125-52 客户-在公海未分配页签勾选客户批量领取，提示信息样式错误
							MessagePopup.TipOne_success(confirm_str);
                        }
                        else
                        {
                            confirm_str = arrJsPopLabel['SUCCESS']+prompt+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        }
                    }
                    isDuplicate=false;
                // }
        
                //抽离到回调函数体内 （批量分配  selectType为1 ，后面可以删除if语句体）
                // if (selectType == 2) {
                //
                // } else {
                    //点击确定按钮
                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                        if (isDuplicate == false) {
                            var tmparra = new Array();
                            var tmpobj = new AfterUpdatePrevPopupObjContent('Leads', "", tmparra);
                            //服务单保存后刷新服务单的历史记录(查看界面)
                            var refreshlistmodules = new Array('Leads');
                            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                            
                        }
                    });
                // }
            };
            http_reqfield.setRequestHeader("If-Modified-Since", "0");
            http_reqfield.send();
        }
    
   
    
    this.createfieldXMLHTTP=function()
    {
        var request;
        var browser=navigator.appName;
     
        if(browser=="Microsoft Internet Explorer")
        {
            var arrVersions=["MSXML2.XMLHttp.5.0","MSXML2.XMLHTTP.4.0","MSXML2.XMLHTTP.3.0","MSXML2.XMLHTTP","Microsoft.XMLHTTP"];
            for( var i=0;i<arrVersions.length;i++)
            {
                try
                {
                     request=new ActiveXObject(arrVersions[i]);
                    return request;
                }
                catch(exception)
                {
                }
            }
        }
        else 
        {
          request=new XMLHttpRequest();
          return request;
        }
     }
     
     
      /**
  * @edit:chj
  * @date:2014-9-17
  * @reason:批量分配、批量领取时， 提示信息
  * @description:
  */
    this.setAllocateAccount=function()
    {
      
        if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
        {
			var data =eval('('+ http_reqfield.responseText +')')?eval('('+ http_reqfield.responseText +')'):JSON.parse(http_reqfield.responseText);
			var results=data.result;
    
            puyoungJS_DialogBox.unblock();
            if(results[3] == 3)   //批量领取
            {
                var prompt = arrJsPopLabel['BATCHRECEIVE'];
            }
            else
            {
                var prompt = arrJsPopLabel['BATCHALLOCATION'];
            }
            
    		if(selectType == 1){
    			if(results[2] == 0){
                    confirm_str = arrJsPopLabel['SUCCESS']+prompt+" "+results[1]+" "+arrJsPopLabel['RECORDS'];
                    // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    			}
    			else{
                    confirm_str = arrJsPopLabel['SUCCESS']+prompt+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS'];
                    // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    			}
    			MessagePopup.TipOne_success(confirm_str);
    		}
            isDuplicate=false;
        }
    }
    
    
        var selectType=1;
        /*
        edit:can
        date:20130718
        reason:批量分配界面生成
        */
        this.massDeskAllocatetaccount=function(obj)
        {
           if(!that.selectchoice())
            {
                return false;
            }
            all_select_id = document.getElementById('allselectedboxes').value;
            
        	if('all' == all_select_id){
        		//获取全选数量
        		selectlen = document.getElementById('numOfRows').value;
                excludedRecords = document.getElementById('excludedRecords').value;
        		if(parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
        			var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',selectlen,getMaxMassOperationLimit(),'');
        			if(confirm(confirm_str)) {
        			} else {
        				return false;
        			}
        		}
        	}
        	var popupobj=CrmPopup.getPopupObj("last");
        	var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
        	var scopepopupobj;//自定义弹出层页面html，绑定事件
        	var module = 'Leads';

			var popup_caption_value;
			var popup_url = '';
		
			var popupinfo = getAllocateSharePopupInfo('higndistribution', module, pool_id);
			popup_caption_value = popupinfo.poptitle;
			popup_url = popupinfo.popup_url;

        	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        		var methodObj = {'popup_check_inactiveuser':'yes'};
        		scopepopupobj =  new ScopePopupObj(methodObj);
                scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
                   cls_ScopePopup.prop.popup_module = module;//模块
                   cls_ScopePopup.prop.popup_value = '';
                   cls_ScopePopup.prop.popup_url = popup_url;
        		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
        		    //重写确认按钮事件
                    scopepopupobj.setEventBtnOk=function(){
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
        					if(empty(cls_ScopePopup.return_obj.return_id)){
                                var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        						return false;
                            }else{
        						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
        						var assigneduserid=cls_ScopePopup.return_obj.return_id;//选中的用户id 
        						var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
        						var savefilter = '';var mode = '';
        						if(ld('input[name=selected_id]').length > 0){//列表
        							select_id = document.getElementById('allselectedboxes').value;
        							if('all' == select_id){
        								//获取全选数量
        								//selectlen = document.getElementById('numOfRows').value;
        								//savefilter += '&selectlen='+selectlen;
        							}else if(0 == ld('input[name=selected_id]:checked').length){
        								RemindsMsg("","LdPopWidth400px","","yes","","");
        								return false;
        							}
        						}
        						that.massAllocate_Load(select_id,2,assigneduserid,assignedusername);
        					}
                        });
                    }
        		});
        	});
        }
        that.massDeskAllocatetaccountDetails=function(obj,record){
        	new Ajax.Request(
        			'index.php',
        			{queue: {position: 'end', scope: 'command'},
        					method: 'post',
        					postBody:"module=Leads&action=AllocateUsers&pagepublicaccounttype=&idstring="+record+"&record="+record+"&totalrows=1&detailview=1",
        					onComplete: function(response) {
        						if(response.responseText.indexOf("###error###2")!=-1){//已分配
        							var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
                                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        							ld('#rptContentLoading').hide();
        							return false;
        						}
                                else if(response.responseText.indexOf("###error###3")!=-1)
                                {
                                    //已领取
                                     var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE'];
                                     RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                    ld('#rptContentLoading').hide();
        							return false;
                                }
        						var popupobj=CrmPopup.getPopupObj("last");
        						var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
        
        						var scopepopupobj;//自定义弹出层页面html，绑定事件
        						var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
        						var module = 'Leads';
        						getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        							scopepopupobj =  new ScopePopupObj(module);
        							scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        							getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
        							   cls_ScopePopup.prop.popup_module = module;//模块
        							   cls_ScopePopup.prop.popup_value = '';
        							   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes&pool_id='+pool_id;
        							   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
        								//重写确认按钮事件
        								scopepopupobj.setEventBtnOk=function(){
        									ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
        										if(empty(cls_ScopePopup.return_obj.return_id)){
        										  var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
        										  RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        										}else{
        											ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
        											var assigneduserid=cls_ScopePopup.return_obj.return_id;//选中的用户id 
        											var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
        											var savefilter = '';var mode = '';
        											that.AllocatetaccountDetails(record,2,assigneduserid,assignedusername);
        										}
        									});
        								}
        							});
        						});
                              
        					}
        			}
        	);
        }
        this.DeskAllocatetaccount=function(obj,start,record,divid)
        {
            ld('#rptContentLoading').show();
            selectType = 2;
            var  viewid=document.getElementById("viewname").value;
            var  accounttype=document.massdelete.publicaccounttype.value; 
            if(document.getElementById("SmOwnerSearchScope")!=null)
                var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
            else
                searchScope='';
            document.getElementById("viewname").value=viewid;
            var viewName = encodeURIComponent(viewid);
        	new Ajax.Request(
                   	'index.php',
                    {queue: {position: 'end', scope: 'command'},
                           	method: 'post',
                            postBody:"module=Leads&action=AllocateUsers&start=1&viewid="+viewName+"&listview=1&SearchScope="+searchScope+"&pagepublicaccounttype="+accounttype+"&record="+record,
                            onComplete: function(response) {
                                ld('#rptContentLoading').hide();
                            if(response.responseText.indexOf("###error###")!=-1)
                            {
                                var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                               ld('#rptContentLoading').hide();
                                return false;
                            }
        					var popupobj=CrmPopup.getPopupObj("last");
        					var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
        					var scopepopupobj;//自定义弹出层页面html，绑定事件
        					var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
        					var module = 'Leads';
        					getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        						scopepopupobj =  new ScopePopupObj(module);
        						scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        						getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
        						   cls_ScopePopup.prop.popup_module = module;//模块
        						   cls_ScopePopup.prop.popup_value = '';
        						   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes&pool_id='+pool_id;
        						   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
        							//重写确认按钮事件
        							scopepopupobj.setEventBtnOk=function(){
        								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
        									if(empty(cls_ScopePopup.return_obj.return_id)){
        										RemindsMsg("","LdPopWidth400px","","yes","","");
        										return false;
        									}else{
        										ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
        										var assigneduserid=cls_ScopePopup.return_obj.return_id;//选中的用户id 
        										var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
        										var savefilter = '';var mode = '';
        										that.massAllocate_Load(record,2,assigneduserid,assignedusername);
        									}
        								});
        							}
        						});
        					});
                           
                            }
                    }
        	);
            
            
            
        }
         /*
        edit:can
        date:20130718
        reason:公海客户(allocatetype)2:分配,3:领取
        */
        this.Allocatetaccount=function(start,recordid,allocatetype,assigneduserid,assignedusername)
        {
           
             this.Allocatetaccount.obj.start=start;
           
             this.Allocatetaccount.obj.recordid=recordid;
             this.Allocatetaccount.obj.allocatetype=allocatetype;
             this.Allocatetaccount.obj.accounttype=""; 
            this.Allocatetaccount.obj.gstart="";
             this.Allocatetaccount.obj.viewname=""; 
             this.Allocatetaccount.obj.pagepublicaccounttype='';
             this.Allocatetaccount.obj.assigneduserid=assigneduserid;
             this.Allocatetaccount.obj.assignedusername=assignedusername;
            
             if(this.Allocatetaccount.page_type=='list')//列表界面
             {
                this.Allocatetaccount.obj.list_allocation();
             }
            
              var popupobj=CrmPopup.getPopupObj("last");
              var url="module=Leads&action=LeadsAjax&file=AllocateLeads&record="+this.Allocatetaccount.obj.recordid+"&allocatetype="
                    +that.Allocatetaccount.obj.allocatetype+"&maxaccount=1";
			if(popupobj.pagetype == 'listpage'){
				var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
				url+="&pool_id="+pool_id+"&start="+this.Allocatetaccount.obj.start;
			}
			else if(popupobj.pagetype == DetailViewPage.pagetype||popupobj.pagetype == DetailViewRelation.pagetype){
				url+="&regetpoolid=yes";
			}
              if(this.Allocatetaccount.obj.allocatetype==2)
              {
                    var userid= this.Allocatetaccount.obj.assigneduserid;
                  //var userid=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].value;
                  url=url+"&userid="+userid;
                 
              }
				//zkt 20231009 XUQIU1001341 SQL注入
              	ldAjax('index.php?',url,function(data) {
					DelProgressObjs();
					var tmpmsg = data.msg;
					var restobj = data.result;
					if(data.code == -1){
						if(tmpmsg.indexOf("###error###")!=-1)
						{
							var results= tmpmsg.split("###error###");
							if(results[1] == 3&&that.Allocatetaccount.obj.allocatetype==2) //已领取
							{
								confirm_str = arrJsPopLabel['THEHIGHTSEAHASBEENRECEIVERD'];
							}
							else if(results[1]==2&&that.Allocatetaccount.obj.allocatetype==2)//已分配
							{
								confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
							}
							else if(results[1]=='obtainaccountmsg'&&that.Allocatetaccount.obj.allocatetype==3)
							{
								confirm_str=results[2];
							}
							else if(results[1] == 3&&that.Allocatetaccount.obj.allocatetype==3) //已领取
							{
								confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE'];
							}
							else if(results[1]==2&&that.Allocatetaccount.obj.allocatetype==3)//已分配
							{
								confirm_str = arrJsPopLabel['THEHIGHTSEAHASBEENALLOCATE'];
							}
							else
							{
								if(that.Allocatetaccount.obj.allocatetype==3)
									//您拥有的公海客户数量已经达到上限，领取失败！
									confirm_str = arrJsPopLabel['HIGHSEASREACHEDTHELIMITCOLLECT'];
								else
								{
									var username=that.Allocatetaccount.obj.assignedusername;
									// var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
									//alert(username+"拥有的公海客户数量已经达到上限，分配失败！");
									//拥有的公海客户数量已经达到上限，分配失败！
									confirm_str = username+arrJsPopLabel['HIGHSEASREACHEDTHELIMITALLOCATION'];
								}
							}
							RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							return false;
						}
					}
					else if(data.code == 1){
						var results= restobj;

						var confirm_str="";

						if(that.Allocatetaccount.obj.allocatetype==3)//领取的操作按钮
						{
							//confirm_str="确定要领取公海客户:"+results[1]+"？";
							confirm_str=arrJsPopLabel['SUREWANTRECEIVEHIGHSEAS']+results[1]+"？";
							RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							//确定按钮
							ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
								ldAjax('index.php?'+url,'',function(data)
								{
									that.Allocatetaccount.obj.accounttype="NOALLOCATE";
									that.Allocatetaccount.obj.re_load();
								});
							});
						}
						else
						{
							var username=that.Allocatetaccount.obj.assignedusername;
							var userid=that.Allocatetaccount.obj.assigneduserid;
							//var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
							//var userid=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].value;
							var allotUrl = "module=Leads&action=LeadsAjax&file=AllocateLeads&idstring="+that.Allocatetaccount.obj.recordid+";&allocatetype="+that.Allocatetaccount.obj.allocatetype+"&start="+that.Allocatetaccount.obj.start+"&pagepublicaccounttype="
								+that.Allocatetaccount.obj.pagepublicaccounttype+"&SearchScope="+that.Allocatetaccount.obj.searchScope+"&viewname="+that.Allocatetaccount.obj.viewname+"&username="+encodeURIComponent(username)+"&assign_name="+userid+'&userid='+userid+"&pool_id="+pool_id;
							ldAjax('index.php?',allotUrl,function(data){
								that.Allocatetaccount.obj.re_load();
							});
						}

					}else if(data.code == 'validata'){
						MessagePopup.TipOne_warning(data.msg);
					}
				});
        }
        this.Allocatetaccount.obj=new Object();
        this.Allocatetaccount.page_type='list';
        this.Allocatetaccount.obj.list_allocation=function()
        {
            
            that.Allocatetaccount.obj.searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
             
             if(that.Allocatetaccount.obj.allocatetype==2)
             {
                 var splitrecord=that.Allocatetaccount.obj.recordid.split(";");
                 that.Allocatetaccount.obj.recordid=trim(splitrecord[0]);
             }
             that.Allocatetaccount.obj.pagepublicaccounttype=document.massdelete.publicaccounttype.value; 
           if(document.forms['massdelete'].pagenum!=undefined)
             {
                    that.Allocatetaccount.obj.gstart="&start="+document.forms['massdelete'].pagenum.value;
             }
             else
             {
                    that.Allocatetaccount.obj.gstart="&start="+document.forms['massdelete'].pagenum[0].value;
             }
            
             that.Allocatetaccount.obj.viewname=document.getElementById("viewname").value; 
                               
             
        }
        this.Allocatetaccount.obj.re_load=function()
        {
            if(that.Allocatetaccount.page_type=='list')
            {
                 var popupobj=CrmPopup.getPopupObj("last");
        		var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
        		var surl = "index.php?module=Leads&action=LeadsAjax&file=AllocateLeads&record="+that.Allocatetaccount.obj.recordid
                        +"&allocatetype="+that.Allocatetaccount.obj.allocatetype+"&start"+that.Allocatetaccount.obj.start
                        +"&pagepublicaccounttype="+that.Allocatetaccount.obj.accounttype+"&SearchScope="+that.Allocatetaccount.obj.searchScope
                        +"&viewname="+that.Allocatetaccount.obj.viewname+"&pool_id="+pool_id;
        		//alert(surl);
        		ldAjaxNoProgress(surl,"",function(data){
        			if(data.code == 1){
        				 var tmparra=new Array();
        				tmparra.push(that.Allocatetaccount.obj.recordid);
        				var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
        				//服务单保存后刷新服务单的历史记录(查看界面)
        				var refreshdetailmodules = new Array('Leads');
        				tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
        				if(that.Allocatetaccount.obj.recordid>0)
        				{
        					tmpobj.update();//更新界面字段
        				}
        			}
        		})
          }
			else if(that.Allocatetaccount.page_type=='detail'&&(that.Allocatetaccount.obj.allocatetype == 1||that.Allocatetaccount.obj.allocatetype==3)){
				var surl = "index.php?module=Leads&action=LeadsAjax&file=AllocateLeads&record="+that.Allocatetaccount.obj.recordid
					+"&allocatetype="+that.Allocatetaccount.obj.allocatetype+"&start"+that.Allocatetaccount.obj.start
					+"&pagepublicaccounttype="+that.Allocatetaccount.obj.accounttype+"&SearchScope="+that.Allocatetaccount.obj.searchScope
					+"&viewname="+that.Allocatetaccount.obj.viewname;
				surl += "&regetpoolid=yes";
				ldAjaxNoProgress(surl,"",function(data){
					if(data.code == 1){
						var tmparra=new Array();
						tmparra.push(that.Allocatetaccount.obj.recordid);
						var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
						//服务单保存后刷新服务单的历史记录(查看界面)
						var refreshdetailmodules = new Array('Leads');
						tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
						tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);console.log('eachrefreshDetailViewByModules');
						if(that.Allocatetaccount.obj.recordid>0)
						{
							tmpobj.update();//更新界面字段
						}
					}
				})
			}
            else
            {
                var tmparra=new Array();
        		tmparra.push(that.Allocatetaccount.obj.recordid);
        		var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
        		//服务单保存后刷新服务单的历史记录(查看界面)
        		var refreshdetailmodules = new Array('Leads');
        		tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
        		tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);
        		if(that.Allocatetaccount.obj.recordid>0)
        		{
        			tmpobj.update();//更新界面字段
        		}
              
            }
           ld('#rptContentLoading').hide();
                                                   
        }

        this.AllocatetaccountDetails=function(recordid,allocatetype,assigneduserid,assignedusername){
            this.Allocatetaccount.page_type='detail';
            this.Allocatetaccount(0,recordid,allocatetype,assigneduserid,assignedusername);
        }
        
                
       
       /*
     edit:can
     date:20130719
     reason:公海客户批量释放
    
     */
    this.massrelease=function()
    {
        
        var select_options = document.getElementById('allselectedboxes').value;
    
        var count=select_options.split(";").length-1;
        if(select_options=='all')
        {
            count=$('numOfRows').value;
        }
        if(count <= 0){
            RemindsMsg("","LdPopWidth400px","","yes","yes","");
            return false;
        }
    
        if(count > getMaxMassOperationLimit()) {
            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    		//确定按钮
    		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
    			that.confirmMassrelease(select_options);
    		})
    		return false;
        } else {
            that.confirmMassrelease(select_options);
        }
        //"您确定要释放选定的"+count+"条记录至公海未分配吗？"
    	// that.confirmMassrelease(select_options);
    }
    //批量释放
    this.confirmMassrelease=function(select_options){
        var  accounttype=document.massdelete.publicaccounttype.value;
        var gstart='';
        if(document.forms['massdelete'].pagenum!=undefined)
        {
            gstart="&start="+document.forms['massdelete'].pagenum.value;
        }
        else
        {
            gstart="&start="+document.forms['massdelete'].pagenum[0].value;
        }
        var viewname=document.getElementById("viewname").value;
        var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        var excludedRecords = $('excludedRecords').value;


		var html = '<div id="ReleanseAccountDiv">' +
			'    <form name="formreleasaccount" method="post">' +
			'        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">' +
			'            <tbody>' +
			'            <tr>' +
			'                <td class="ld-form-item-label">' +
			'                    <font color="red">*</font>' + arrJsPopLabel['RELEASEACCOUNTTREASON'] +
			'                </td>' +
			'                <td class="ld-form-item-content">' +
			'                    <textarea style="height: 90px;resize: none;" class="ld-textarea-inner" name="releaseAccountReasons"></textarea>' +
			'                </td>' +
			'            </tr>' +
			'            </tbody>' +
			'        </table>' +
			'    </form>' +
			'</div>';
		var release_popupobj = CrmPopup.load(arrJsPopLabel['RELEASE'],'','','LdPopWidth600px',popupobj.module,'',arrJsPopLabel['CONFIRMED'],'',arrJsPopLabel['CANCEL'])
		release_popupobj.show(html);
		var divobj = ld('#'+release_popupobj.divid);
		divobj.find('[name=releaseAccountReasons]').focus();
		//绑定取消按钮  selectall selected_id
		ld('#'+release_popupobj.divid+'_btncancel').unbind("click").bind("click",function(){
			ld.each(ld("[name='selected_id']:checked"),function (index,obj){
				ld(obj).prop('checked',false);
				ld(obj).removeClass('tb-checkbox-selected');
			});
			ld("[name='selectall']").prop('checked',false);//取消全选
			ld("[name='selectall']").removeClass('tb-checkbox-selected');//取消全选
		});

		// 绑定确认按钮
		ld('#'+release_popupobj.divid+'_btnok').unbind("click").bind("click",function(){
			var releaseaccountreason = trim(divobj.find("#ReleanseAccountDiv [name=releaseAccountReasons]").val());
			if (releaseaccountreason != ''){
				release_popupobj.CancelEvent();
				var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
				var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
				var url ="index.php?module=Leads&action=LeadsAjax&file=MassReleaseLeads"+gstart+"&pool_id="+pool_id;
				//zkt 树结构显示增加条件，获取树结构点击条件
				if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
					url += '&isshowModuleListTree=yes';
				}
				var params = {idstring:select_options,pagepublicaccounttype:accounttype,
					SearchScope:searchScope,viewname:viewname,excludedRecords:excludedRecords, releaseAccountReasons:(releaseaccountreason)};
				ldAjaxHtml(url,params,function (response) {
					response = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
					DelProgressObjs();
					if(empty(response)) return false;
					var releaseConvert_popupobj = CrmPopup.load(response.title.value,'','','LdPopWidth600px',popupobj.module,'',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL'])
					var releaseConvert_html = '<div id="releaseConvertcontent" class="pop_remind_content">'+response.log.value+'</div>';
					releaseConvert_popupobj.show(releaseConvert_html);

					ld('#'+releaseConvert_popupobj.divid+'_btncancel').unbind('click').bind('click',function() {
						ld('#current_page_boxes').val('');//清空所选单据checkbox
						ld('#allselectedboxes').val('');//清空选择全部参数
						ld('#selectedboxes').val('');
						getListViewEntries_js('Leads', response.start.value);//刷新页面
					});
					ld('#'+releaseConvert_popupobj.divid+'_btnok').unbind('click').bind('click',function() {
						releaseConvert_popupobj.CancelEvent();
						ld('#current_page_boxes').val('');//清空所选单据checkbox
						ld('#allselectedboxes').val('');//清空选择全部参数
						ld('#selectedboxes').val('');
						getListViewEntries_js('Leads', response.start.value);//刷新页面
					});
				})
			} else
			{
				var confirm_str = arrJsPopLabel['RELEASEACCOUNTTREASON']+arrJsPopLabel['CANOTEMPTY'];
				MessagePopup.TipOne_warning(confirm_str);
				divobj.find('[name=releaseAccountReasons]').focus();
				return false;
			}
		});
    }
    
    
    this.DeskDelayaccount=function(start,recorid,obj,divid)
    {
        var  customtypename=document.massdelete.publicaccounttype.value;
        var  customtypename=document.massdelete.publicaccounttype.value;
        var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        var viewname=document.getElementById("viewname").value;
    	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Leads',"",'none',"","");
    	crmPopupobj.prevshow();
    	ld.ajax({
    		url: "index.php?module=Leads&action=LeadsAjax&file=DeskDelayLeads&record="+recorid+"&pagepublicaccounttype="+customtypename+"&SearchScope="+searchScope+"&viewname="+viewname,
    		type: 'POST',
    		data:'',
    		dataType:'json',
    		async: true,//
    		timeout: 5000,
    		success: function(data)
    		{
    			if(data.code==1)
    			{
    				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth600px",'Leads',"","","","");
    				crmPopupobj.show(data.result.content);
    			}
    		}
    	})
    }
    
    
    this.funDelayAccount=function(recorid)
    {
         if(trim(document.DelayAccount.txtdelay.value)=="")
         {
            //延期天数不能为空！
            var confirm_str = arrJsPopLabel['POSTPONEDFEWDAYSCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.DelayAccount.txtdelay.focus();
            
            return false;
         }
         if(isNaN(document.DelayAccount.txtdelay.value))
         {
            //非法延期天数！
            var confirm_str = arrJsPopLabel['ILLEGALPOSTPONEDFEWDAYS'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.DelayAccount.txtdelay.focus();
            return false;
         }
         if(document.DelayAccount.txtdelay.value<=0||document.DelayAccount.txtdelay.value.split(".").length>1)
         {
            //延期天数只能录入正整数！
            var confirm_str = arrJsPopLabel['POSTPONEDFEWDAYPOSITIVEINT'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            document.DelayAccount.txtdelay.focus();
            return false;
         }
        var data = new FormData(ld(".delayaccount_form")[0]);
    	var popupobj=CrmPopup.getPopupObj("last");
    	var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    	var record = ld("#"+popupobj.divid+" [name=record]").val();
    	ld('#rptContentLoading').show();
    	ld.ajax({
    		type: 'POST',
    		dataType: 'json',
    		processData: false, // 告诉jquery不要处理数据
    		contentType: false, // 告诉jquery不要设置contentType
    		data: data,
    		url: 'index.php?module=Leads&action=LeadsAjax&file=DelayLeads',
    		success: function(json, textStatus, xhr) {
    			ld('#rptContentLoading').hide();
    			popupobj.CancelEvent();
    			var tmparra=new Array();
    			tmparra.push(record);
    			var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
    			//新增刷新列表
    			var refreshlistmodules = new Array('Leads');
    			tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
    		},
    		error: function(xhr, textStatus, errorThrown) {
    			//alert(2);
    		}
    	  })
    		  return false;
        var  customtypename=document.massdelete.publicaccounttype.value;
        var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        var viewname=document.getElementById("viewname").value;
        return true;
       
    }
    
    
    this.Releaseaccount=function(start,recordid)
    {
        var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        var viewname=document.getElementById("viewname").value;
        var  accounttype=document.massdelete.publicaccounttype.value;
    	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Leads',"",'none',"","");
    	crmPopupobj.prevshow();
    	crmPopupobj.setParams(arrJsPopLabel['RELEASE'],ReleaseaccountSubmit,"","LdPopWidth600px",'Leads',"",arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
    	var  shtml = '<form name="formreleasaccount" method="post">';
    	shtml += '<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">';
    	shtml += '<input type="hidden" name="record" id = "record" value="'+recordid+'">';
    	shtml += '<tr><td class="ld-form-item-label">';
    	shtml += '<span style="color: red;">*</span>'+arrJsPopLabel['RELEASEACCOUNTTREASON'];
    	shtml += '</td><td class="ld-form-item-content">';
    	shtml += '<textarea style="height: 90px;resize: none;" class="ld-textarea-inner" name="releaseAccountReasons"></textarea>';
    	shtml += '</td></tr>';
    	shtml += '</table>';
    	shtml += '</form>';
    	
    	crmPopupobj.show(shtml);
    	return false;
    }
    
    var ReleaseaccountSubmit = function(){
    	var  popupobj=CrmPopup.getPopupObj("last");
		var prevpopupobj = CrmPopup.getPopupObj('lastprev');
    	var releaseAccountReasons = CrmPopup.findHtmlobj(popupobj.divid,'releaseAccountReasons').val();
    	if(trim(releaseAccountReasons) == ''){
    		var confirm_str = ReleanAccountReason+arrJsPopLabel['CANOTEMPTY'];
    		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    		CrmPopup.findHtmlobj(popupobj.divid,'releaseAccountReasons').focus();
    		return false;
    	}else{
    		var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    		var viewname=document.getElementById("viewname").value;
    		var  accounttype=document.massdelete.publicaccounttype.value;
    		var recordid = CrmPopup.findHtmlobj(popupobj.divid,'record').val();
    	
    		ld.ajax("index.php?module=Leads&record="+recordid+"&pagepublicaccounttype="+accounttype+"&action=LeadsAjax&file=ReleaseLeads&SearchScope="+searchScope+"&viewname="+viewname+"&releaseAccountReasons="+releaseAccountReasons)
    		.done(function(results){
    			cancelCrmPopup();
				var tmparra=new Array();
				tmparra.push(that.Allocatetaccount.obj.recordid);
				var tmpobj= new AfterUpdatePrevPopupObjContent('Leads',"",tmparra);
				//新增刷新列表
				var refreshlistmodules = new Array('Leads');
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
    			return false;
    		})
    	}
    	return false;
    }
    
    
    
    this.massDeskHighAvgAllocatetaccount=function (obj)
    {
        var selectlen = 1;
        var select_id = '';//选择的单据id
    
    	//该功能不判断被分配用户的公海客户是否达到上限，是否继续？
        var confirm_str = arrJsPopLabel['thisopreationdoesnotcheckthehignseaquantitylimit'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
    
        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            //批量操作条目数控制
            if (!that.selectchoice()) {
                return false;
            }
            var scopepopupobj;//自定义弹出层页面html，绑定事件
            var popup_caption_value = arrJsPopLabel['LBL_AVGDISTRIBUT_HIGHSEAS_JSOP'];//标题
            var module = 'Accounts';

			var popup_caption_value;
			var popup_url = '';
		
			var popupinfo = getAllocateSharePopupInfo(popup_type, module, pool_id);
			popup_caption_value = popupinfo.poptitle;
			popup_url = popupinfo.popup_url;
    
            all_select_id = document.getElementById('allselectedboxes').value;
    
            if ('all' == all_select_id) {
                //获取全选数量
                selectlen = document.getElementById('numOfRows').value;
                excludedRecords = document.getElementById('excludedRecords').value;
                if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
                    var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
                    if (confirm(confirm_str)) {
                    } else {
                        return false;
                    }
                }
            }
            var popupobj = CrmPopup.getPopupObj("last");
            var pool_id = ld("#" + popupobj.divid + " [name=pool_id]").val();	//公海池
            getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
                var methodObj = {'popup_check_inactiveuser': 'yes'};
                scopepopupobj = new ScopePopupObj(methodObj);
                scopepopupobj.popup_caption_value = popup_caption_value;//标题title
                getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
                    cls_ScopePopup.prop.popup_module = module;//模块
                    cls_ScopePopup.prop.popup_value = '';
                    cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module=' + module + '&popup_inputtype=&popuboxp_selecttype=user&ishighseaallocate=yes&pool_id=' + pool_id;
                    var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                    //重写确认按钮事件
                    scopepopupobj.setEventBtnOk = function () {
                        ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                            var array_Highuser = cls_ScopePopup.return_obj.return_id.split(",").length;
                            if (empty(cls_ScopePopup.return_obj.return_id) || array_Highuser < 2) {
                                var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                                RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                                return false;
                            } else {
                                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                                var assigneduserid = cls_ScopePopup.return_obj.return_id;//选中的用户id
    
                                var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
                                var savefilter = '';
                                var mode = '';
                                if (ld('input[name=selected_id]').length > 0) {//列表
                                    select_id = document.getElementById('allselectedboxes').value;
                                    if ('all' == select_id) {
                                        //获取全选数量
                                        selectlen = document.getElementById('numOfRows').value;
                                        //savefilter += '&selectlen='+selectlen;
                                    }else{
                                        var x = select_id.split(';');
                                        var count = x.length;
                                        if(0 == ld('input[name=selected_id]:checked').length){
                                            RemindsMsg("","LdPopWidth400px","","yes","yes","");
                                            return false;
                                        }
                                        if(count - 1 > getMaxMassOperationLimit()) {
                                            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
                                            if(confirm(confirm_str)) {
                                            } else {
                                                return false;
                                            }
                                        }
    
                                        selectlen = count - 1;
                                    }
                                }
                                //massHighAllocate_Load
                                that.massHighAllocate_Load(select_id, 2, assigneduserid, assignedusername, selectlen);
                            }
                        });
                    }
                });
            });
        });
    }
    
   this.massHighAllocate_Load= function (select_options,allocatetype,assigneduserid,assignedusername,selectlen)
    {
        var confirm_str = "";
        var gstart = '';
        if (document.forms['massdelete'].pagenum != undefined) {
            gstart = "&start=" + document.forms['massdelete'].pagenum.value;
        } else {
            gstart = "&start=" + document.forms['massdelete'].pagenum[0].value;
        }
    
        var searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
        var accounttype = document.massdelete.publicaccounttype.value;
        var assignids = document.getElementById("assign_name").value;
        var idlist = document.getElementById("allselectedboxes").value;
        var viewname = document.getElementById("viewname").value;
        var excludedRecords = $('excludedRecords').value;
        //客户公海分配 - 列表
        if (allocatetype == 2 && selectType == 2) {
            //select_options = idlist = document.EditView.record.value;
            idlist = select_options;
        }
    
    // @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
        var userid_length = assigneduserid.split(',').length;
         var selected_user_arr=assigneduserid.split(",");
        var  intervalrow=selected_user_arr.length;
        var executeTimeCount=parseInt(selectlen/intervalrow);
        //edit:can 20210425 45560: （https://61mis.com/kfbcrm [^] ）平均分配时不平均
         if(executeTimeCount>20)
         {
            intervalrow=selected_user_arr.length*2;
         }
         if(executeTimeCount>30)
         {
            intervalrow=selected_user_arr.length*3;
         }
         if(executeTimeCount>30)
         {
            intervalrow=selected_user_arr.length*4;
         }
         if(executeTimeCount>50)
         {
            intervalrow=selected_user_arr.length*5;
         }
         if(executeTimeCount>60)
         {
            intervalrow=selected_user_arr.length*6;
         }
          if(executeTimeCount>70)
         {
            intervalrow=selected_user_arr.length*7;
         }
         if(intervalrow<8)
         {
            intervalrow=selected_user_arr.length*2;
         }
        that.start_massDeskHighAvgAllocatetaccount(select_options,allocatetype,gstart,accounttype,excludedRecords,viewname,searchScope,assigneduserid,assignids,idlist,selectlen,0, intervalrow);
        
    }
    // @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
   this.start_massDeskHighAvgAllocatetaccount= function (select_options,allocatetype,gstart,accounttype,excludedRecords,viewname,searchScope,assigneduserid,assignids,idlist,selectlen, startrow, intervalrow){
        var endrow = startrow+intervalrow;
        if (endrow > selectlen){
            endrow = selectlen;
        }
        var url = "module=Leads&action=LeadsAjax&file=cls_avghighallocate_leads&idstring=" + select_options + "&allocatetype=" + allocatetype + gstart + "&maxaccount=1&pagepublicaccounttype=" + accounttype + "&excludedRecords=" + excludedRecords + "&viewname=" + viewname + "&SearchScope=" + searchScope;
        if (allocatetype == 2) {
            var userid = assigneduserid;
            //var userid=document.getElementById('assigned_user_id').value;
            url = url + "&userid=" + userid + "&assign_name=" + assignids + "&id=" + idlist;
        }
    
        url += "&selectlen="+selectlen+"&startrow="+startrow+"&endrow="+endrow;
        new Ajax.Request(
            'index.php',
            {
                queue: {
                    position: 'end',
                    scope: 'command'
                },
                method: 'post',
                postBody: url,
                onComplete: function (response) {
    
                    ld('#rptContentLoading').hide();
                    //fninvshnew(divid);
                    if (response.responseText.indexOf('###REACHMAXCUSTOMER###') > -1) {
                        var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                        RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                        return false;
                    }
                    ld('#' + cls_ScopePopup.popup_divid + ' .D_pbtn .D_pbtncancel').click();
    
                    if (empty(response.responseText)) return false;
                    var restobj = eval('(' + response.responseText + ')') ? eval('(' + response.responseText + ')') : JSON.parse(response.responseText);
    
                    var tmppopupobjobj;
    
                    if(startrow==0)
                    {
                        tmppopupobjobj=ProgressPopup.load(restobj.title.value,"","",500,'Leads',"","","","");
                        tmppopupobjobj.show();
                    }
                    else{
                        tmppopupobjobj=CrmPopup.getPopupObj('last');
                    }
                    var maxrows=parseInt(restobj.maxrows);
                    var percent=parseInt(((startrow+intervalrow)/maxrows*100));
    
                    tmppopupobjobj.setPercentWidth(percent);
                    tmppopupobjobj.setTotalNum(restobj.selectrows);
                    tmppopupobjobj.setCurNum(startrow);
                    if(maxrows!=restobj.selectrows)
                    {
                        tmppopupobjobj.setValidataNum(maxrows);
                    }
                    if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
                    {
                        that.start_massDeskHighAvgAllocatetaccount(select_options,allocatetype,gstart,accounttype,excludedRecords,viewname,searchScope,assigneduserid,assignids,idlist,selectlen,startrow + intervalrow, intervalrow);
                        return false;
                    }
                    else{
                        tmppopupobjobj.CancelEvent();
                    }
    
                    if (ld('input[name=selected_id]').length == 0) {
                        puyoungJS_DialogBox.block();
                        puyoungJS_DialogBox.unblock();
                        fninvshnew('selectpopup_1');
                        changeUser.afterOperation(popup_type, selected_user, cls_ScopePopup.return_obj.return_name, module);
                        //window.location.reload();
                        return false;
                    }
                    getJsScript('include/js/ldcrm.base.js', function () {
                        var divobj = createElementDivs('mass_advancer');//创建DIV
                        ld(divobj).find('.E_pop_tit .E_ptita').html(restobj.title.value);
                        ld('#mass_advancercontent').html(restobj.log.value);
                        fnvshobj('', 'mass_advancer');
                        ld('#mass_advancercontent').css('overflow', 'auto').css('max-height', '350px').css('padding', '5px');
                        ld('#mass_advancer .D_pbtn .D_pbtncancel').css('display', 'none');
                        //关闭事件
                        ld('#mass_advancer .E_pop_tit .E_ptitc').unbind('click').on('click', function () {
                            ld('#mass_advancer .E_pbtn .E_pbtnok').click();
                            return false;
                        });
                        if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
                            //通讯录(pc端企业微信)
                            cls_wxOpenDataobj.bindAllOpenData();
                        }
                        ld('#mass_advancer .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                            fninvshnew('mass_advancer');
                            puyoungJS_DialogBox.unblock();
                            if (ld('input[name=selected_id]').length > 0) {
                                $('basicsearchcolumns').innerHTML = '';
                                $('allselectedboxes').value = '';
                                $('excludedRecords').value = '';
                                getListViewEntries_js('Leads', restobj.start.value);//刷新页面
                                //window.location.reload();
                                if (document.getElementById("SmOwnerSearchScope") != undefined)
                                    searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
                                var viewid = getviewId();
    
                            } else {
                                window.location.reload();
                            }
                        });
                        return false;
                    });
                }
            });
    }
    
    
    
        /**
    Liver 2016-12-07 平均分配
    **/
    this.averageDistribution=function (obj,module,popup_type){    
        //获取要变更的ID
        var selectlen = 1;
    	var select_id = '';//选择的单据id
    	var savefilter = '';//选择的单据个数
        var mode = 'list';//类型：列表(list)详情页(detail)
    	var excludedRecords = '';
    	var oem_crm = ld('#oem_crm').val();
        if(ld('input[name=selected_id]').length > 0){//列表
    
            select_id = document.getElementById('allselectedboxes').value;
    		if('all' == select_id){
    			//获取全选数量
    			selectlen = document.getElementById('numOfRows').value;
                excludedRecords = document.getElementById('excludedRecords').value;
    			if(parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
    				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',selectlen,getMaxMassOperationLimit(),'');
    				if(confirm(confirm_str)) {
    				} else {
    					return false;
    				}
    			}
    			savefilter += '&selectlen='+selectlen;
    		}else {
    			var x = select_id.split(';');
    			var count = x.length;
    			if(0 == ld('input[name=selected_id]:checked').length){
                    RemindsMsg("","LdPopWidth400px","","yes","yes","");
    				return false;
    			}
    			if(count - 1 > getMaxMassOperationLimit()) {
    				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
    				if(confirm(confirm_str)) {
    				} else {
    					return false;
    				}
    			}
    
                selectlen = count - 1;
    		}
    	}
        else if(document.DetailView == undefined){
            RemindsMsg("","LdPopWidth400px","","yes","","");
            return false;
        }else{//详情页
    		select_id = document.DetailView.record.value;
            mode = 'detail';
    	}
    	savefilter += '&select_id='+select_id;
      
    
    	//自定义弹出层页面html，绑定事件
        //alert(popup_url);
    	var scopepopupobj;
        var popup_caption_value;
		var popup_url = '';

		var popupinfo = getAllocateSharePopupInfo(popup_type, module);
		popup_caption_value = popupinfo.poptitle;
		popup_url = popupinfo.popup_url;
        
    	var popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top:-4px;"  onclick="getLinksUrl(\'Accounts\',\'Allocate\',\'averageDistribution\');" >'+arrJsPopLabel['ONLINEHELP']+'</a><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
    	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
    		scopepopupobj =  new ScopePopupObj(module);
            scopepopupobj.popup_caption_value = popup_caption_value;//标题title
    		if(oem_crm == 'no'){
    			scopepopupobj.popup_header = popup_header;
    		}
    		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
    		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
               cls_ScopePopup.prop.popup_module = module;//模块
    		   cls_ScopePopup.prop.popup_value = '';
    		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
    		    //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                        //没有选择任何用户，则给出提示
                        var array_user=cls_ScopePopup.return_obj.return_id.split(",").length;//选取用户的个数
                        if(empty(cls_ScopePopup.return_obj.return_id) || array_user<2){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                           RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                          
                            return false;
                        }else{
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            //edit:can 2021-03-05 44743: （本地8.3.7）单据平均分配；客户模块，选择客户单据后进行平均分配，先选择一个成员，出现“请至少选择两个成员！”提示后，再加个成员点确定没反应
                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click');//解绑防止多次点击。
                            ld('#rptContentLoading').show();
                            // @edit:liushuai,2021-03-02,reason:【ID1001390】批量平均分配增加显示进度条
                            var selected_user_arr=selected_user.split(",");
                            var  intervalrow=selected_user_arr.length;
                            var executeTimeCount=parseInt(selectlen/intervalrow);
                            //edit:can 20210425 45560: （https://61mis.com/kfbcrm [^] ）平均分配时不平均
                             if(executeTimeCount>20)
                             {
                                intervalrow=selected_user_arr.length*2;
                             }
                             if(executeTimeCount>30)
                             {
                                intervalrow=selected_user_arr.length*3;
                             }
                             if(executeTimeCount>30)
                             {
                                intervalrow=selected_user_arr.length*4;
                             }
                             if(executeTimeCount>50)
                             {
                                intervalrow=selected_user_arr.length*5;
                             }
                             if(executeTimeCount>60)
                             {
                                intervalrow=selected_user_arr.length*6;
                             }
                              if(executeTimeCount>70)
                             {
                                intervalrow=selected_user_arr.length*7;
                             }
                             if(intervalrow<8)
                             {
                                intervalrow=selected_user_arr.length*2;
                             }
                            that.startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, 0, intervalrow);
    
                        }
                    });
                }
    		});
    	});
    }
    
    // @edit:liushuai,2021-03-02,reason:【ID1001390】批量平均分配增加显示进度条
   that.startAverageDistribution= function (module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, startrow, intervalrow)
    {
        var endrow = startrow+intervalrow;
        if (endrow > selectlen){
            endrow = selectlen;
        }
        var urlstring = 'module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
        urlstring += '&from_module='+module+'&changetype='+popup_type+'&mode='+mode;
        urlstring += '&select_id='+select_id+'&caterorid='+selected_user+'&excludedRecords='+excludedRecords;
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(mode=='list'&&ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   urlstring += '&isshowModuleListTree=yes';
    	}
        
        urlstring+="&startrow="+startrow+"&endrow="+endrow;
		ldAjax('index.php?',urlstring,function(data) {
			DelProgressObjs();
			ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
			var tmpmsg = data.msg;
			var restobj = data.result;
			ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();

			if(empty(restobj)) return false;
			var restobj = data.result;
			if(data.code == -1){
				if(tmpmsg.indexOf('###REACHMAXCUSTOMER###')>-1){
					var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}
			}
			else if(data.code == 1) {
				if(mode=='list')
				{
					var tmppopupobjobj;

					if(startrow==0)
					{
						tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,module,"","","","");
						tmppopupobjobj.show();

					}
					else{
						tmppopupobjobj=CrmPopup.getPopupObj('last');

					}
					var maxrows=parseInt(restobj.maxrows);
					var percent=parseInt(((startrow+intervalrow)/maxrows*100));
					//var width=parseInt((500*(startrow+intervalrow)/maxrows));

					tmppopupobjobj.setPercentWidth(percent);
					tmppopupobjobj.setTotalNum(restobj.selectrows);
					tmppopupobjobj.setCurNum(startrow);
					if(maxrows!=restobj.selectrows)
					{
						tmppopupobjobj.setValidataNum(maxrows);
					}
					if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
					{
						that.startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, startrow + intervalrow, intervalrow);
						return false;
					}
					else{
						tmppopupobjobj.CancelEvent();
					}
				}

				if(ld('input[name=selected_id]').length == 0){//Liver 2016/09/07 去掉&&module!='Documents'，原因是bug0024278: 知识管理明细：更多中点击-更改创建人，确定后，界面显示了更改创建人的提示消息
					puyoungJS_DialogBox.block();

					if(module == 'HelpDesk'){
						var help_url = window.location.href;
						help_url = help_url.replace('&sendtype=yes','');
						if(help_url.indexOf('&sendtype=yes')<0 && popup_type=='Allocate'){
							help_url += '&sendtype=yes';
						}
						window.location.href=help_url;
						return false;
					}
					puyoungJS_DialogBox.unblock();
					fninvshnew('selectpopup_1');
					changeUser.afterOperation(popup_type,selected_user,cls_ScopePopup.return_obj.return_name,module);
					//window.location.reload();
					return false;
				}
				getJsScript('include/js/ldcrm.base.js',function(){
					resultRemindsMsg(restobj.title.value,"LdPopWidth600px","","yes","",restobj.log.value);
					var popupobj=CrmPopup.getPopupObj('last');
					if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
					{
						//通讯录(pc端企业微信)
						cls_wxOpenDataobj.bindAllOpenData();
					}


					ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
						fninvshnew('mass_advancer');puyoungJS_DialogBox.unblock();
						if(ld('input[name=selected_id]').length > 0){
							$('basicsearchcolumns').innerHTML = '';
							$('allselectedboxes').value='';
							$('excludedRecords').value='';
							getListViewEntries_js(module,restobj.start.value);//刷新页面
							//window.location.reload();
							if(document.getElementById("SmOwnerSearchScope")!=undefined)
								searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
							var viewid = getviewId();

						}else{
							window.location.reload();
						}
					});
					return false;
				});
			}
			else{
				return false;
			}
		});
    }
    
    /*
    edit:Liver
    date:20161209
    reason:  公海客户批量平均分配界面生成
    */
    that.massDeskHighAvgAllocatetaccount=function (obj)
    {
        var selectlen = 1;
        var select_id = '';//选择的单据id
    
    	//该功能不判断被分配用户的公海客户是否达到上限，是否继续？
        var confirm_str = arrJsPopLabel['thisopreationdoesnotcheckthehignseaquantitylimit'];
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);
    
        //点击确认
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            //批量操作条目数控制
            if (!that.selectchoice()) {
                return false;
            }
            var scopepopupobj;//自定义弹出层页面html，绑定事件
            var module = 'Leads';
    
            all_select_id = document.getElementById('allselectedboxes').value;
    
            if ('all' == all_select_id) {
                //获取全选数量
                selectlen = document.getElementById('numOfRows').value;
                excludedRecords = document.getElementById('excludedRecords').value;
                if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
                    var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
                    if (confirm(confirm_str)) {
                    } else {
                        return false;
                    }
                }
            }
            var popupobj = CrmPopup.getPopupObj("last");
            var pool_id = ld("#" + popupobj.divid + " [name=pool_id]").val();	//公海池

			var popup_caption_value;
			var popup_url = '';
		
			var popupinfo = getAllocateSharePopupInfo('averagehigndistribution', module, pool_id);
			popup_caption_value = popupinfo.poptitle;
			popup_url = popupinfo.popup_url;

            getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
                var methodObj = {'popup_check_inactiveuser': 'yes'};
                scopepopupobj = new ScopePopupObj(methodObj);
                scopepopupobj.popup_caption_value = popup_caption_value;//标题title
                getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
                    cls_ScopePopup.prop.popup_module = module;//模块
                    cls_ScopePopup.prop.popup_value = '';
                    cls_ScopePopup.prop.popup_url = popup_url;
                    var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                    //重写确认按钮事件
                    scopepopupobj.setEventBtnOk = function () {
                        ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                            var array_Highuser = cls_ScopePopup.return_obj.return_id.split(",").length;
                            if (empty(cls_ScopePopup.return_obj.return_id) || array_Highuser < 2) {
                                var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                                RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                                return false;
                            } else {
                                ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                                var assigneduserid = cls_ScopePopup.return_obj.return_id;//选中的用户id
    
                                var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
                                var savefilter = '';
                                var mode = '';
                                if (ld('input[name=selected_id]').length > 0) {//列表
                                    select_id = document.getElementById('allselectedboxes').value;
                                    if ('all' == select_id) {
                                        //获取全选数量
                                        selectlen = document.getElementById('numOfRows').value;
                                        //savefilter += '&selectlen='+selectlen;
                                    }else{
                                        var x = select_id.split(';');
                                        var count = x.length;
                                        if(0 == ld('input[name=selected_id]:checked').length){
                                            RemindsMsg("","LdPopWidth400px","","yes","yes","");
                                            return false;
                                        }
                                        if(count - 1 > getMaxMassOperationLimit()) {
                                            var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
                                            if(confirm(confirm_str)) {
                                            } else {
                                                return false;
                                            }
                                        }
    
                                        selectlen = count - 1;
                                    }
                                }
                                //massHighAllocate_Load
                                that.massHighAllocate_Load(select_id, 2, assigneduserid, assignedusername, selectlen);
                            }
                        });
                    }
                });
            });
        });
    }
}

var PublicLeadsObj = new cls_PublicLeads();