//选择分摊
var showAllocations = function(module,mode,recordid,fldname){
	$("status").style.display="inline";
	var surl="module=Users&action=UsersAjax&file=ShareEqually&mode="+mode+"&recordid="+recordid+'&frommodule='+module+'&fieldname='+fldname;
	if(!empty(ld('input[name='+fldname+'_shareequally_value_count]')) != undefined){
		var shareequally_value_count = ld('input[name='+fldname+'_shareequally_value_count]').val();
		if(shareequally_value_count >= 1){
			var shareequally_value = new Array();
			for(var i = 1; i <= shareequally_value_count; i++){
				//_1
				shareequally_value[i-1] = ld('input[name='+fldname+'_shareequally_value_'+i+']').val();
			}
			surl += '&shareequally_value='+shareequally_value.join('|');
			surl += '&shareequally_type='+ld('input[name='+fldname+'_shareequally_type]').val();
		}
	}
	//alert(surl);
	//return false;
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                
				$("status").style.display="none";
				var crmPopupobj=CrmPopup.load(data.result.title,validate_shareequally,"","LdPopWidth600px",module,'',data.result.oktext,"",data.result.canceltext);
				crmPopupobj.show(data.result.content);
				crmPopupobj.fieldname = fldname;
				crmPopupobj.fieldlabel = data.result.title;
				showAllocations.EventBind(crmPopupobj);
            }
        }
    });
}
//事件绑定
showAllocations.EventBind = function(crmPopupobj){
	var _this = this;
	//分摊方式
	CrmPopup.findHtmlobj(crmPopupobj.divid,"share_type").unbind('click').on('click',function(){
		_this.shareType(ld(this).val(),crmPopupobj);
	});
	
	//添加行
	CrmPopup.findHtmlobj(crmPopupobj.divid,"addShare_row").unbind('click').on('click',function(){
		_this.addRow(crmPopupobj);
	});
	//table里的选项事件绑定
	_this.TableEventBind(crmPopupobj);
	var share_type = ld("#"+crmPopupobj.divid+" input[name='share_type']:checked").val(); 
	if(share_type > 0){
		_this.shareType(share_type,crmPopupobj);	
	}
}
//删除行事件绑定
showAllocations.TableEventBind = function(crmPopupobj){
	var _this = this;
	//删除行
	CrmPopup.findHtmlobj(crmPopupobj.divid,"delShare_row").each(function(){
		ld(this).unbind('click').on('click',function(){
			var row_id = ld(this).attr('tag');
			_this.delRow(row_id,crmPopupobj);
		});
	});
	//选择源单
	CrmPopup.findHtmlobj(crmPopupobj.divid,"selectSourceModule").each(function(){
		ld(this).unbind('click').on('click',function(){
			var row_id = ld(this).attr('tag');
			_this.selectSourceModule(row_id,crmPopupobj);
		});
	});
	//清除源单
	CrmPopup.findHtmlobj(crmPopupobj.divid,"clearSourceModule").each(function(){
		ld(this).unbind('click').on('click',function(){
			var row_id = ld(this).attr('tag');
			if(row_id >= 1){
				CrmPopup.findHtmlobj(crmPopupobj.divid,"share_entitytype_"+row_id).val('');
				CrmPopup.findHtmlobj(crmPopupobj.divid,"share_entitytypeid_"+row_id).val('');
			}
		});
	});
	//源单类型
	var row_id = CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find("tr").length;
	if(row_id - 2 > 0){
		for(var i = 1; i <= row_id - 2; i++){
			CrmPopup.findHtmlobj(crmPopupobj.divid,"sourcemodule"+i).unbind('change').on('change',function(){
				var row_id = ld(this).attr('tag');
				if(row_id >= 1){
					CrmPopup.findHtmlobj(crmPopupobj.divid,"share_entitytype_"+row_id).val('');
					CrmPopup.findHtmlobj(crmPopupobj.divid,"share_entitytypeid_"+row_id).val('');
				}
			})
		}
	}
	
}
//新增行
showAllocations.addRow = function(crmPopupobj){
	var row_id = CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find("tr").length;
	var share_type = ld("#"+crmPopupobj.divid+" input[name='share_type']:checked").val(); 
	if(row_id - 2 >= 1){
		var cur_row_id = row_id - 1;
		var trHtml = "<tr class='lvtColData' name='list_row_"+cur_row_id+"'>";
		trHtml += "<td align=\"center\"><a class=\"icon-homeimg icon-sdel\" href=\"javascript:;\" tag="+cur_row_id+" name=\"delShare_row\" title="+arrJsPopLabel['DELETE']+"></a></td>";
		trHtml += "<td><select class=\"ld-select-inner\" name='sourcemodule"+cur_row_id+"' tag="+cur_row_id+">";
		var sourcemodule_json = ld('#sourcemodule_json').val();
		if(!empty(sourcemodule_json) && sourcemodule_json != null && sourcemodule_json != 'null'){
			var sourcemodule_arr = eval("("+sourcemodule_json+")")?eval("("+sourcemodule_json+")"):Json.parse(sourcemodule_json);
			for(var module in sourcemodule_arr){
				var _selected = '';
				if(sourcemodule_arr[module].default==1){
					_selected = 'selected="true"';
				}
				if(sourcemodule_arr[module].presence != 1){
					trHtml += "<option value="+module+" "+_selected+">"+sourcemodule_arr[module].label+"</option>";
				}
			}
		}
		trHtml += "</select></td>";
		trHtml += "<td class=\"ld-form-item-content\"><input type=\"text\" class=\"ld-input-inner ld-input-inner-add\" readonly=\"\" name='share_entitytype_"+cur_row_id+"'><input type=\"hidden\" name='share_entitytypeid_"+cur_row_id+"'>";
		trHtml += "<a class=\"ld-text-select\" href=\"javascript:;\" title="+arrJsPopLabel['SELECT']+" name=\"selectSourceModule\" tag="+cur_row_id+">+</a>";
		trHtml += "<a class=\"ld-text-clear\" href=\"javascript:;\" title="+arrJsPopLabel['CLEAR']+" name=\"clearSourceModule\" tag="+cur_row_id+">+</a>";
		trHtml += "</td>";
		if(share_type == 2){
			trHtml += "<td class=\"ld-form-item-content\">";
		}else{
			trHtml += "<td class=\"ld-form-item-content\" style=\"display: none;\">";
		}
		trHtml += "<input type=\"text\" class=\"ld-input-inner\" name='percent_"+cur_row_id+"' value=\"0\"><a class=\"ld-text-span\" href=\"javascript:;\">%</a>";
		trHtml += "</td>";
		trHtml += "</tr>";
		//sourcemodule_json
		$tr = CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find("tr").eq(row_id - 2);
		$tr.after(trHtml);
		this.TableEventBind(crmPopupobj);
	}
}

//删除
showAllocations.delRow = function(row_id,crmPopupobj){
	CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find("tr").eq(row_id).css('display','none');
}

//选择源单
showAllocations.selectSourceModule = function(row_id,crmPopupobj){
	var sourcemodule = CrmPopup.findHtmlobj(crmPopupobj.divid,"sourcemodule"+row_id).val();
	if(sourcemodule == 'Users'){
		var module = 'Home';
		var popup_caption_value = arrJsPopLabel['SELECT']+arrJsPopLabel['LBL_USERS']; 
		var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user';
		getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
			var methodObj = {'popup_check_inactiveuser':'yes'};
			scopepopupobj =  new ScopePopupObj(methodObj);
			scopepopupobj.popup_caption_value = popup_caption_value;//标题title
			getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
			   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
			   cls_ScopePopup.prop.popup_module = module;//模块
			   cls_ScopePopup.prop.popup_value = '';
			   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
				//重写确认按钮事件
				scopepopupobj.setEventBtnOk=function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
						//没有选择任何用户，则给出提示
						if(empty(cls_ScopePopup.return_obj.return_id)){
							var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
							RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
							return false;
						}else{
							var mid = cls_ScopePopup.return_obj.return_id;
							var mname = cls_ScopePopup.return_obj.return_name;
							CrmPopup.setHtmlobjval(crmPopupobj.divid,'share_entitytypeid_'+row_id,mid);
							ld("#"+crmPopupobj.divid+" input[name=share_entitytype_"+row_id+"]").val(mname);
							ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
						}
					});
				}
			});
		});
	}else{
		showrelatedlist(crmPopupobj.module,""+sourcemodule+"","select","","shareequally_"+row_id+"");
	}
}
//分摊方式
showAllocations.shareType = function(sharetype,crmPopupobj){
	if(sharetype == 1){//均摊
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr').find('td:eq(3)').hide();
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr').find('th:eq(3)').hide();
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr:last').find('td').attr('colspan',3);
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr:first').find('th:eq(2)').attr('width','65%');
	}else {	//比例
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr').find('td:eq(3)').show();
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr').find('th:eq(3)').show();
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr:last').find('td').attr('colspan',4);
		CrmPopup.findHtmlobj(crmPopupobj.divid,"share_table").find('tr:first').find('th:eq(2)').attr('width','50%');
	}
}

//保存
var validate_shareequally = function(){
	var popupobj=CrmPopup.getPopupObj("last");
	var count_row = CrmPopup.findHtmlobj(popupobj.divid,"share_table").find("tr").length;
	var share_type = ld("#"+popupobj.divid+" input[name='share_type']:checked").val();
	var div_html = '';
	var count_html = 0;	//有效的源单总行
	var percent = 0;
	for(var i = 1; i <= count_row - 2; i++){
		if(CrmPopup.findHtmlobj(popupobj.divid,"list_row_"+i+"").css("display") != 'none'){
			if(empty(CrmPopup.findHtmlobj(popupobj.divid,"share_entitytypeid_"+i+"").val())){
				var share_entitytype_label = CrmPopup.findHtmlobj(popupobj.divid,"share_entitytype_label").html();
				var confirm_str = share_entitytype_label + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
			if(share_type == 2){
				var percent_val = CrmPopup.findHtmlobj(popupobj.divid,"percent_"+i+"").val();
				if(percent_val == '' || percent_val < 0){
					var percent_label = CrmPopup.findHtmlobj(popupobj.divid,"percent_label").html();
					var confirm_str = percent_label+arrJsPopLabel['Must_number_greater_than_0'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					return false;
				}else{
					percent += eval(CrmPopup.findHtmlobj(popupobj.divid,"percent_"+i+"").val());
				}
			}
			count_html++;
		}
	}
	//比例合计必须等于100！
	if(percent != 100 && share_type == 2 && count_html > 0){
		var percent_label = CrmPopup.findHtmlobj(popupobj.divid,"percent_label").html();
		var confirm_str = percent_label+arrJsPopLabel['totalamountmust'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	//生成html
	var k =0;
	for(var i = 1; i <= count_row - 2; i++){
		if(CrmPopup.findHtmlobj(popupobj.divid,"list_row_"+i+"").css("display") != 'none'){
			var sourcemodule = CrmPopup.findHtmlobj(popupobj.divid,"sourcemodule"+i+"").val();
			var sourcemodule_label = CrmPopup.findHtmlobj(popupobj.divid,"sourcemodule"+i+"").find('option:selected').text();
			var share_entitytype = CrmPopup.findHtmlobj(popupobj.divid,"share_entitytype_"+i+"").val();
			var share_entitytypeid = CrmPopup.findHtmlobj(popupobj.divid,"share_entitytypeid_"+i+"").val();
			var sourcemodule_percent = CrmPopup.findHtmlobj(popupobj.divid,"percent_"+i+"").val();
			var source_value = sourcemodule + ',' + share_entitytypeid + ',' + sourcemodule_percent;
			var source_label = sourcemodule_label + ' - ' + share_entitytype;
			k++;
			div_html += '<div class="" style="padding-bottom: 5px;">';
			div_html += '<input type="hidden" value = "'+source_value+'" name="'+popupobj.fieldname+'_shareequally_value_'+k+'">';
			div_html += '<span class="info" style="padding-left:25px;">'+source_label+'</span>';
			div_html += '<span class="webuploadDelbtn" style="padding-left:5px">';
			if(share_type == 2){
				div_html += '<span style="padding-left:5px">('+sourcemodule_percent+'%)</span>';
			}
			div_html += '</div>';
		}
	}
	if(!empty(div_html)){
		div_html += '<input type="hidden" value = "'+share_type+'" name="'+popupobj.fieldname+'_shareequally_type">';
		div_html += '<input type="hidden" value = "'+count_html+'" name="'+popupobj.fieldname+'_shareequally_value_count">';
	}
	if(ld('#'+popupobj.fieldname+'_shareequally_div') != undefined){
		if(!empty(div_html)){
			ld('#'+popupobj.fieldname+'_select_shareequally_label').html(arrJsPopLabel['CONTINUEADDING']+popupobj.fieldlabel);
			ld('#'+popupobj.fieldname).val(1);
		}else{
			ld('#'+popupobj.fieldname+'_select_shareequally_label').html(ld('#'+popupobj.fieldname+'_select_shareequally_label').attr('tag')+popupobj.fieldlabel);
			ld('#'+popupobj.fieldname).val('');
		}
		ld('#'+popupobj.fieldname+'_shareequally_div').html(div_html);
		popupobj.CancelEvent();
	}
}
validate_shareequally.funname = 'validate_shareequally';

//设置源单
var setShareSourceModules = function(module,fldname){
	$("status").style.display="inline";
	var surl="module=Users&action=UsersAjax&file=ShareEqually&frommodule="+module+"&fieldname="+fldname+'&setSourceModule=yes';
	//alert(surl);
	ld.ajax({
		url: 'index.php?'+surl,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
				$("status").style.display="none";
				var crmPopupobj=CrmPopup.load(data.result.title,validate_setShareSourceModule,"","LdPopWidth650px",module,'',data.result.oktext,"",data.result.canceltext);
				crmPopupobj.show(data.result.content);
				crmPopupobj.fieldname = fldname;
				setShareSourceModules.EventBind(crmPopupobj);
            }
        }
    });
}

//上移、下移 事件绑定
setShareSourceModules.EventBind = function(crmPopupobj){
	CrmPopup.findHtmlobj(crmPopupobj.divid,"setsourcemodule").each(function(){
		ld(this).unbind('click').on('click',function(){
			var movetype = ld(this).attr('movetype');
			var cur_row_id = ld(this).attr('tag');
			if(movetype == 'movedown')
				var next_row_id = eval(cur_row_id) + 1;
			else{
				var next_row_id = eval(cur_row_id) - 1;
			}
			for(var i = 1; i <= 3; i++){
				if(i == 1){
					var cur_sourcemodule_label = CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+cur_row_id).find("td").eq(1).html();
					var next_sourcemodule_label = CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+next_row_id).find("td").eq(1).html();
					CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+cur_row_id).find("td").eq(1).html(next_sourcemodule_label);
					CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+next_row_id).find("td").eq(1).html(cur_sourcemodule_label);
				}else{
					var cur_sourcemodule_presence = CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+cur_row_id).find("td").eq(i).find('input').attr('checked');
					var next_sourcemodule_label = CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+next_row_id).find("td").eq(i).find('input').attr('checked');
					if(cur_sourcemodule_presence == 'checked'){
						CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+next_row_id).find("td").eq(i).find('input').attr('checked',"true");
					}else{
						CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+next_row_id).find("td").eq(i).find('input').removeAttr("checked");
					}
					if(next_sourcemodule_label == 'checked'){
						CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+cur_row_id).find("td").eq(i).find('input').attr('checked',"true");
					}else{
						CrmPopup.findHtmlobj(crmPopupobj.divid,"row_"+cur_row_id).find("td").eq(i).find('input').removeAttr("checked");
					}
				}
			}
		});
	});
}

//设置源单 保存
var validate_setShareSourceModule = function(){
	$("status").style.display="inline";
	var popupobj=CrmPopup.getPopupObj("last");
	var count_row = CrmPopup.findHtmlobj(popupobj.divid,"set_sourcemodule_table").find("tr").length;
	var con = new Array();
	var newSourceModule = new Array();
	for(var i = 1; i <= count_row - 1; i++){
		var sourcemodule = CrmPopup.findHtmlobj(popupobj.divid,"row_"+i).find("td").eq(1).find('input').val();
		var sourcemodule_label = CrmPopup.findHtmlobj(popupobj.divid,"row_"+i).find("td").eq(1).find('span').html();
		if(CrmPopup.findHtmlobj(popupobj.divid,"row_"+i).find("td").eq(2).find('input').prop('checked')){
			var sourcemodule_presence = 0;
		}else{
			var sourcemodule_presence = 1;
		}
		if(CrmPopup.findHtmlobj(popupobj.divid,"row_"+i).find("td").eq(3).find('input').prop('checked')){
			var sourcemodule_default = 1;
		}else{
			var sourcemodule_default = 0;
		}
		con[i-1] = sourcemodule +','+sourcemodule_presence+','+sourcemodule_default;
		newSourceModule[sourcemodule] = sourcemodule_label;
	}
	var surl="module=Users&action=UsersAjax&file=SaveShareEqually&setSourceModule=yes&frommodule="+popupobj.module+"&fieldname="+popupobj.fieldname+'&info='+con.join('|');
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: surl,
			onComplete: function(response)
			{
				if(trim(response.responseText) == 'success'){
					var confirm_str = popupobj.headtitle + arrJsPopLabel['SUCCESS'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					$("status").style.display="none";
				}else{
					var confirm_str = popupobj.headtitle + arrJsPopLabel['LOSE'];
					RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
					$("status").style.display="none";
				}
				popupobj.CancelEvent();
			}
		}
	);
}
validate_setShareSourceModule.funname = 'validate_setShareSourceModule';