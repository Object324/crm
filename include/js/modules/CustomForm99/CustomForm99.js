//东贸：活动配置，满减配置
function setModuleMinus(fieldname,fieldlabel,module){
	var popupobj=CrmPopup.getPopupObj('last');
	var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=setModuleMinus&fieldname='+fieldname;
	surl += '&minus_json='+ld("#"+popupobj.divid+" [name="+fieldname+"]").val();
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(fieldlabel,saveModuleMinus,'',"LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,""); 
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
		}
	});
}
//东贸：活动配置，满减配置   保存
function saveModuleMinus(event,tagobj){
	var popupobj=CrmPopup.getPopupObj("last");
	var prev_popupobj=CrmPopup.getPopupObj("lastprev");
	var fieldname = ld("#"+popupobj.divid+" [name=fieldname]").val();
	var rowobj = ld("#"+popupobj.divid+" [name=table_moduleminus] tr.minus");
	var minus_data = [];
	var rowindex = 0;
	var _result = true;
	ld.each(rowobj,function(tmprowindex,tmprowobj){
		rowindex = tmprowindex + 1;
		var _man = ld(tmprowobj).find(" [name=man]").val();
		var _jian = ld(tmprowobj).find(" [name=jian]").val();
		if((!empty(_man) && empty(_jian)) || (empty(_man) && !empty(_jian))){
			var confirm_str= "第"+rowindex+"行的满减必须大于0！";
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			_result = false;
			return false;
		}
		var minus_string = _man+','+_jian;
		minus_data.push(minus_string);
	});
	if(_result){
		var minus_json = JSON.stringify(minus_data);
		ld("#"+prev_popupobj.divid+" [name="+fieldname+"]").val(minus_json);
		if(prev_popupobj.type == 'detailviewpage'){
			var urlstring = 'index.php?module=CustomForm99&action=CustomForm99Ajax&ajax=true&file=setModuleMinus';
			urlstring += '&record='+prev_popupobj.record+'&minus_json='+minus_json;
			ldAjax(urlstring,"",function(data){
				if(data.code==1){
					popupobj.CancelEvent();
					DelProgressObjs();
				}
			});
			
		}else{
			popupobj.CancelEvent();
		}
		
	}
}
//东贸：活动配置，满减配置   删除行
function delModuleMinus(event,tagobj){
	var popupobj=CrmPopup.getPopupObj("last");
	tagobj.parent().parent().remove();
}

//东贸：活动配置，满减配置  添加行
function addModuleMinus(event){
	var popupobj=CrmPopup.getPopupObj("last");
	var rowcnt = ld("#"+popupobj.divid+" [name=table_moduleminus]").find("tr").length;
	var rowhtml = '<tr name="conditioncolumn_1_0" class="minus"><td width="40%" align="left"><input name="man" id="man" class="width150 commonTextBoxPop" type="text" value=""></td><td width="40%" align="left"><input name="jian" id="jian" class="width150 commonTextBoxPop" type="text" value=""></td><td name="columnconditionglue_0" width="60px" align="left"></td><td width="30px" align="left"><a href="javascript:;" onclick="delModuleMinus(event,ld(this))" title="删除">删除</a></td></tr>';
	var rowindex = rowcnt - 2;
	ld("#"+popupobj.divid+" [name=table_moduleminus] > tbody > tr:eq("+eval(rowindex)+")").after(rowhtml);
}


//东贸：时长配置
function setDurationSetting(fieldname,fieldlabel,module){
	var popupobj=CrmPopup.getPopupObj('last');
	var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=setDurationSetting&fieldname='+fieldname;
	surl += '&durationsetting_json='+ld("#"+popupobj.divid+" [name="+fieldname+"]").val();
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(fieldlabel,saveDurationSetting,'',"LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,""); 
			crmPopupobj.createScrollDiv();
			crmPopupobj.show(data.result.content);
		}
	});
}

//东贸：东贸：时长配置   删除行
function delDurationSetting(event,tagobj){
	var popupobj=CrmPopup.getPopupObj("last");
	tagobj.parent().parent().remove();
}

//东贸：东贸：时长配置  添加行
function addDurationSetting(event){
	var popupobj=CrmPopup.getPopupObj("last");
	var rowcnt = ld("#"+popupobj.divid+" [name=table_moduleminus]").find("tr").length;
	var rowhtml = '<tr name="conditioncolumn_1_0" class="minus"><td width="25%" align="left"><input name="dayu" id="dayu" class="width150 commonTextBoxPop" type="text" value=""></td><td width="25%" align="left"><input name="xiaoyu" id="xiaoyu" class="width150 commonTextBoxPop" type="text" value=""></td><td width="25%" align="left"><input name="shichang" id="shichang" class="width150 commonTextBoxPop" type="text" value=""></td><td name="columnconditionglue_0" width="60px" align="left"></td><td width="30px" align="left"><a href="javascript:;" onclick="delDurationSetting(event,ld(this))" title="删除">删除</a></td></tr>';
	var rowindex = rowcnt - 2;
	ld("#"+popupobj.divid+" [name=table_moduleminus] > tbody > tr:eq("+eval(rowindex)+")").after(rowhtml);
}

//东贸：活动配置，满减配置   保存
function saveDurationSetting(event,tagobj){
	var popupobj=CrmPopup.getPopupObj("last");
	var prev_popupobj=CrmPopup.getPopupObj("lastprev");
	var fieldname = ld("#"+popupobj.divid+" [name=fieldname]").val();
	var rowobj = ld("#"+popupobj.divid+" [name=table_moduleminus] tr.minus");
	var minus_data = [];
	var rowindex = 0;
	var _result = true;
	ld.each(rowobj,function(tmprowindex,tmprowobj){
		rowindex = tmprowindex + 1;
		var _xiaoyu = ld(tmprowobj).find(" [name=xiaoyu]").val();
		var _dayu = ld(tmprowobj).find(" [name=dayu]").val();
		var _shichang = ld(tmprowobj).find(" [name=shichang]").val();
		if(_xiaoyu == '' || _dayu == '' || _shichang == ''){
			var confirm_str= "第"+rowindex+"行的时长设置必须大于0！";
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			_result = false;
			return false;
		}
		if(eval(_dayu) > eval(_xiaoyu)){
			var confirm_str= "第"+rowindex+"行的时长范围设置错误！！";
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			_result = false;
			return false;
		}
		var minus_string = _dayu+','+_xiaoyu+','+_shichang;
		minus_data.push(minus_string);
	});
	if(_result){
		var minus_json = JSON.stringify(minus_data);
		ld("#"+prev_popupobj.divid+" [name="+fieldname+"]").val(minus_json);
		if(prev_popupobj.type == 'detailviewpage'){
			var urlstring = 'index.php?module=CustomForm99&action=CustomForm99Ajax&ajax=true&file=setDurationSetting';
			urlstring += '&record='+prev_popupobj.record+'&durationsetting_json='+minus_json;
			ldAjax(urlstring,"",function(data){
				if(data.code==1){
					popupobj.CancelEvent();
					DelProgressObjs();
				}
			});
			
		}else{
			popupobj.CancelEvent();
		}
		
	}
}