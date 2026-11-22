//敏感规则
function SensitiveRules(){
	var that=this;

	//编辑字段时刷新
	this.refresh = function(fieldid,module){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=SensitiveRules&datatype=list&mode=refresh&frommodule='+module;
		surl += '&fieldid='+fieldid;
		var popupobj=CrmPopup.getPopupObj('last');
		ldAjax(surl,"",function(data){
			if(data.code==1){
				ld("#"+popupobj.divid).find(".SensitiveDiv").html(data.result.content);
			}
			DelProgressObjs();
		})
	}
	//新增字段时刷新
	this.create_refresh = function(new_ruleid,module){
		var popupobj=CrmPopup.getPopupObj('last');
		var ruletrobj = ld("#"+popupobj.divid+' table.SensitiveTable').find('tr[id^=setting_]');
		var ruleid_arr = [];
		ruletrobj.each(function() {//获取已存在的规则
			var exist_ruleid = ld(this).attr('ruleid');
			exist_ruleid = parseInt(exist_ruleid, 10);
			if (exist_ruleid != undefined) {
				ruleid_arr.push(exist_ruleid);
			}
		});
		if(new_ruleid != ''){
			ruleid_arr.push(new_ruleid);
		}
		var ruleids_str = ruleid_arr.join(',');
		var url = 'index.php?module=Settings&action=SettingsAjax&file=SensitiveRules&datatype=list&mode=show&frommodule='+module;
		url += '&ruleids_str='+ruleids_str;
		ldAjax(url,"",function(ajaxdata){
			if(ajaxdata.code==1){
				ld("#"+popupobj.divid).find(".SensitiveDiv").html(ajaxdata.result.content);
			}
			DelProgressObjs();
		})
	}
	//新增,编辑
	this.create = function(fieldid,ruleid,mode,module,blockid=''){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=SensitiveRules&datatype=detail&mode='+mode+'&frommodule='+module;
		surl += '&fieldid='+fieldid;
		surl += '&ruleid='+ruleid;
		var crmPopupobj = CrmPopup.load("","","","LdPopWidth900px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.save,'',"LdPopWidth900px",'Settings',[fieldid,ruleid,module,blockid],data.result.oktext,"",data.result.canceltext);
	
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);

				if(ruleid == 0){
					ld("#"+crmPopupobj.divid+' input[name="rulestatus"]').prop("checked", 'checked'); //新建时启用按钮默认启用
				}
				if(ld("#"+popupobj.divid+" [name=encrypty_end]").find('input').val() == -1){
					ld("#"+popupobj.divid+" [name=encrypty_end]").find('input').val(0);
				}
				crmPopupobj.fields=data.result.fields;
				crmPopupobj.detailfields=data.result.detailfields;
				crmPopupobj.record=ruleid;
				crmPopupobj.frommodule=module;
				crmPopupobj.function_arr=data.result.function_arr;//函数
				crmPopupobj.nonelabel=data.result.nonelabel;
				crmPopupobj.sqllabel=data.result.SQL;
				crmPopupobj.groupbylabel=data.result.groupbylabel;
				crmPopupobj.funtype=data.result.funtype;
				crmPopupobj.detailfuntype=data.result.detailfuntype;
				crmPopupobj.selecttype_arr = data.result.selecttype_arr;
				crmPopupobj.comparatortype_arr = data.result.comparatortype_arr;

				getJsScript('include/js/modules/Settings/cls_validatacondition.js',function(){
					crmPopupobj.filterobj = cls_validatacondition.getInstance();
					crmPopupobj.filterobj.setAdvanceTableParentDivid('sensitiveadvance');
					crmPopupobj.filterobj.field_arr = crmPopupobj.fields;
					if(ruleid > 0)
					{
						var advft_criteria = data.result.advft_criteria;
						var advft_criteria_groups = data.result.advft_criteria_groups;
						crmPopupobj.filterobj.InitAdvftValue(advft_criteria,advft_criteria_groups);
						/*
						if(data.result.funtype=='')
							ld("#"+popupobj.divid+' [name=selectfield]').val(data.result.selectfield);
						ld("#"+popupobj.divid+' [name=comparatortype]').val(data.result.comparatortype);
						if(data.result.detailfuntype=='')
							ld("#"+popupobj.divid+' [name=comparefield]').val(data.result.comparefield);
						*/
					}else{
						crmPopupobj.filterobj.New_addNewConditionGroup();
					}
				});

				// if(data.result.relatedtable == 'ld_field'){
					
				// }else{
				// 	crmPopupobj.filterobj.field_arr = crmPopupobj.detailfields;
				// }
				
				//that.changefields(ld("#"+popupobj.divid+' [name=relatedtable]'));
				// ld("#"+crmPopupobj.divid+' [name=relatedtable]').unbind("change").bind("change",function(){
				// 	crmPopupobj.filterobj.clear();
				// 	if(ld(this).val() == 'ld_field'){
				// 		crmPopupobj.filterobj.field_arr = crmPopupobj.fields;
				// 	}else{
				// 		crmPopupobj.filterobj.field_arr = crmPopupobj.detailfields;
				// 	}
				// 	crmPopupobj.filterobj.New_addNewConditionGroup();
				// })
				
				
				ld("#"+crmPopupobj.divid+" #showsqlwildcard").bind('click',function(){
					that.ShowDescrition(this);
				})

				var disabledscene = '';
				if (data.result.disabledscene){
					disabledscene = data.result.disabledscene;
				}
				ld('#'+crmPopupobj.divid+' #disabledscene').val(disabledscene).select2({
					closeOnSelect: false,
					placeholder:arrJsPopLabel['pleaseselect']+'...',
				});//加载多选框

				
				crmPopupobj.center();
			}
		})
	}

	//保存规则
	this.save = function(fieldid,ruleid,module,blockid){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=SensitiveRules&datatype=detail&mode=save&frommodule='+module;
		surl += '&fieldid='+fieldid;
		surl += '&ruleid='+ruleid;

		var popupobj=CrmPopup.getPopupObj('last');
        var rulename = trim(ld("#"+popupobj.divid+" [name=rulename]").val()); //规则名称
        var ruletype = ld("#"+popupobj.divid+" [name=ruletype]").val(); //规则类型
        var rulestatus = ld("#"+popupobj.divid+" [name=rulestatus]").is(':checked'); //开启状态
		if(rulestatus == true){
			rulestatus = 'yes';
		}
		else{
			rulestatus = 'no'
		}
        var encrypty_way = ld("#"+popupobj.divid+" [name=encrypty_way]").val(); //加密方式
        var encrypty_started = ld("#"+popupobj.divid+" [name=encrypty_started]").find('input').val(); //加密起止位置
        var encrypty_end = ld("#"+popupobj.divid+" [name=encrypty_end]").find('input').val(); //加密起止位置
        var effectivemethod = ld("#"+popupobj.divid+" [name=effectivemethod]").val(); //规则生效方式
        //规则名称不能为空
        if(rulename == ''){
			confirm_str = arrJsPopLabel['RULENAMECANNOTBEEMPTY'];
			MessagePopup.TipZero_warning(confirm_str);
			ld("#"+popupobj.divid+" [name=rulename]").focus();
			return false;
        }
		//部分加密左侧数字不能大于右侧
		if(encrypty_way == 'part'){
			var allowsave = 'yes';
			if(encrypty_started > encrypty_end){
				confirm_str = '部分加密方式左侧数字不能大于右侧';
				allowsave = 'no';
			}
			if( (encrypty_started == 0 || empty(encrypty_started)) && (empty(encrypty_end) || encrypty_end == 0)){
				confirm_str = '部分加密方式两侧数字不能为0或空';
				allowsave = 'no';
			}
			if(allowsave == 'no'){
				MessagePopup.TipZero_warning(confirm_str);
				ld("#"+popupobj.divid+" [name=encrypty_started]").find('input').focus();
				return false;
			}
        }
		var disabledscene = '';
		// if (ruletype == 'allencrypted'){
			var disabledsceneobj = ld('#'+popupobj.divid+' #disabledscene');
			var data = disabledsceneobj.select2('data')
			var disabledscene_arr= new Array();
			ld.each(data,function (index,value){
				disabledscene_arr.push(value.id);
			});
			disabledscene=disabledscene_arr.join(',');
		// }

        var params={'rulename':rulename, 'ruletype':ruletype,'rulestatus':rulestatus,'encrypty_way':encrypty_way,'encrypty_started':encrypty_started,'encrypty_end':encrypty_end,'effectivemethod':effectivemethod,'disabledscene':disabledscene}
        
        if(popupobj.valiadvancefilterobj.New_checkAdvancedFilter()){
            params['advft_criteria'] = popupobj.advft_criteria;
            params['advft_criteria_groups'] = popupobj.advft_criteria_groups;
        }else{
            return false;
        }
        ldAjaxNoProgress(surl,params,function(data){
            if(data.code == 1){
                popupobj.CancelEvent();
				if(fieldid == 0){
					var new_ruleid = data.result.saved_ruleid;//新增的规则id
					that.create_refresh(new_ruleid,module);
				}else{
                	that.refresh(fieldid,module);
					var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
					MessagePopup.TipZero_success(confirm_str);
				}
            }
        })
	}
	//删除单条规则
	this.delete = function(fieldid,ruleid,module){
		var confirm_str = arrJsPopLabel['CANOTRESTOREDAFTERDELETIONDELETEOK'];
		MessagePopup.TipTwo_warning(confirm_str);
		//确认事件
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var surl = 'index.php?module=Settings&action=SettingsAjax&file=SensitiveRules&datatype=list&mode=delete&frommodule='+module;
			// surl += '&fieldid='+fieldid;
			surl += '&ruleid='+ruleid;
			ldAjaxNoProgress(surl,"",function(data){
				if(data.code==1){
					if(fieldid == 0){
						that.create_refresh('',module);
					}else{
						that.refresh(fieldid,module);
					}
					MessagePopup.TipZero_success(data.result.msg);
				}
			})
		});
    }
	//切换单条规则的开启状态
	this.changerulestatus = function(obj,fieldid,ruleid,module){
		var surl = 'index.php?module=Settings&action=SettingsAjax&file=SensitiveRules&datatype=list&mode=changerulestatus&frommodule='+module;
		surl += '&fieldid='+fieldid;
		surl += '&ruleid='+ruleid;
		var rulestatus = ld(obj).is(':checked');
		if(rulestatus == true){
			rulestatus = 'yes';
		}
		else{
			rulestatus = 'no'
		}
		surl += '&rulestatus='+rulestatus;

		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
				MessagePopup.TipZero_success(confirm_str);
			}
		})
		// this.refresh(fieldid,module);
    }
	//切换加密方式
	this.changeencrypty = function(obj){
        var popupobj = CrmPopup.getPopupObj("last");
		var encrypty_way = ld("#"+popupobj.divid+" [name=encrypty_way]").val();
		ld("#"+popupobj.divid+" .encrypty_num").hide();
		if(encrypty_way == 'all'){
			ld("#"+popupobj.divid+" .encrypty_num").hide();
		}else{
			ld("#"+popupobj.divid+" .encrypty_num").css("display","flex");
			ld("#"+popupobj.divid+" .encrypty_num").css("margin-left","10px");
			if(encrypty_way == 'left'){
				ld("#"+popupobj.divid+" [name=encrypty_end]").css("display","none");
				ld("#"+popupobj.divid+" [name=encrypty_middle]").css("display","none");
				ld("#"+popupobj.divid+" [name=encrypty_started]").css("display","flex");
			}else if(encrypty_way == 'right'){
				ld("#"+popupobj.divid+" [name=encrypty_end]").css("display","flex");
				ld("#"+popupobj.divid+" [name=encrypty_started]").css("display","none");
				ld("#"+popupobj.divid+" [name=encrypty_middle]").css("display","none");

			}else{
				ld("#"+popupobj.divid+" [name=encrypty_started]").css("display","flex");
				ld("#"+popupobj.divid+" [name=encrypty_middle]").css("display","flex");
				ld("#"+popupobj.divid+" [name=encrypty_end]").css("display","flex");
			}
		}
    }
	//切换规则类型
	this.changeruletype = function(obj){
        var popupobj = CrmPopup.getPopupObj("last");
		var ruletype = ld("#"+popupobj.divid).find(" [name=ruletype]").val();
		var encrypty_way = ld("#"+popupobj.divid).find("#encrypty_way_tr");
		var disabledscene_tr = ld("#"+popupobj.divid).find("#disabledscene_tr");
		if(ruletype == 'allencrypted'){
			// encrypty_way.show();
			// disabledscene_tr.css('display','');
		}else{
			// encrypty_way.hide();
			// disabledscene_tr.css('display','none');
		}
    }

	this.decrement = function(boxId) {
		var popupobj = CrmPopup.getPopupObj("last");
		var box = ld("#"+popupobj.divid+" #"+boxId + "Box").get(0);
		var leftbox = ld("#"+popupobj.divid+" #leftBox").get(0);
		let value = parseInt(box.value);
		if (isNaN(value)){
			value = 0;
		}
		var isPart = 'no';//判断是否是部分加密
		if (ld("#"+popupobj.divid+" [name=encrypty_end]").is(':visible') && ld("#"+popupobj.divid+" [name=encrypty_started]").is(':visible')) {
			isPart = 'yes';
		}
		// console.log(ld("#"+popupobj.divid+" [name=encrypty_end]").is(':visible'))

		// if (boxId == 'right' && value > 0 && isPart == 'yes') {
		// 	var leftValue = parseInt(leftbox.value);
		// 	if (value > leftValue+1) {
		// 		value--;
		// 	}
		// }else if(value > 0){
		//   	value--;
		// }
		if(value > 0){
			value--;
		}
		box.value = value;
	}

	this.increment = function(boxId) {
		var popupobj = CrmPopup.getPopupObj("last");
		var box = ld("#"+popupobj.divid+" #"+boxId + "Box").get(0);
		var rightbox = ld("#"+popupobj.divid+" #rightBox").get(0);
		let value = parseInt(box.value);
		if (isNaN(value)){
			value = 0;
		}
		var isPart = 'no';//判断是否是部分加密
		if (ld("#"+popupobj.divid+" [name=encrypty_end]").is(':visible') && ld("#"+popupobj.divid+" [name=encrypty_started]").is(':visible')) {
			isPart = 'yes';
		}
		// console.log(ld("#"+popupobj.divid+" [name=encrypty_end]").is(':visible'))
		// if (boxId == 'left' && isPart == 'yes') {
			// var rightValue = parseInt(rightbox.value);
			// if (value < rightValue-1) {
			// value++;
			// }
		// } else  {
			value++;
		// }
		box.value = value;
	}

	this.updateValue = function(boxId) {
		var popupobj = CrmPopup.getPopupObj("last");
		var box = ld("#"+popupobj.divid+" #"+boxId + "Box").get(0);
		var leftbox = ld("#"+popupobj.divid+" #leftBox").get(0);
		var rightbox = ld("#"+popupobj.divid+" #rightBox").get(0);
		var value = parseInt(box.value);
		var regex = /^[0-9]+$/;
		if (isNaN(value)) {
			return; // 输入不是数字，不做任何操作
		}
		if (!regex.test(value)) {
			return;
		}

		if (boxId === 'left') {
			var rightValue = parseInt(rightbox.value);
			if (value > rightValue) {
				rightbox.value = value + 1;
			}
		} else if (boxId === 'right') {
			var leftValue = parseInt(leftbox.value);
			if (value < leftValue) {
				leftbox.value = value - 1;
			}
		}
	}
	this.ShowDescrition = function(obj){
        var status = ld(obj).data('status');
        var childid = ld(obj).data('childid');
        if(status == 'hidden'){
            ld("#"+childid).show();
            ld(obj).data('status','show');
        }else{
            ld("#"+childid).hide();
            ld(obj).data('status','hidden');
        }
        //展开后将滚动条滚动到底部，方便查看
        var popupobj=CrmPopup.getPopupObj('last');
        var scrollobj = ld('#'+popupobj.divid+'_scroll').get(0);
        scrollobj.scrollTop = scrollobj.scrollTopMax;
        popupobj.center();
    }

}
SensitiveRules.curobj = '';
SensitiveRules.getInstance=function(){
	if(!empty(SensitiveRules.curobj)){
	}else{
		SensitiveRules.curobj=new SensitiveRules();
	}
    return SensitiveRules.curobj;
}
