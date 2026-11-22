//群发短信
function MassSmsPopup(){
    
    //滚动条
    this.createScrollDiv=function()
    {
       
        this.scrolldiv='<div class="dvpopupsroll" style="max-height:450px;width: 100%;overflow-y:auto;margin: 0 0;diplay:inline">';
        
    }
    
}
MassSmsPopup.type="MassSmsPopup";
MassSmsPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
    
     MassSmsPopup.prototype=new CrmPopup();  
     MassSmsPopup.prototype.constructor=MassSmsPopup;  
     MassSmsPopup.prototype.type=MassSmsPopup.type;
     MassSmsPopup.prototype.curmodule=module;//弹出层所在的模块
     
     var  MassEditPopupObj=new MassSmsPopup();
     MassEditPopupObj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return MassEditPopupObj;
    
}


//群发短讯页面按钮事件
function MassSmsPopupBind(obj)
{
   
}
//选择模块，添加接受人手机
MassSmsPopupBind.selectModuleForByPhone=function(){
	var popupobj=CrmPopup.getPopupObj("last");
    
	var divid=popupobj.divid;
	if(CrmPopup.findHtmlobj(divid,'parent_type') != undefined){
		var parent_type = CrmPopup.findHtmlobj(divid,'parent_type').val();
		var surl = "module="+parent_type+"&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_groupmasssms&select=enable&popup=yes&page_popup=yes";
		var cvid = CrmPopup.findHtmlobj(divid,'parent_type').find("option:selected").attr('cvid');
        if(cvid!=undefined&&cvid>0){
            surl += "&viewname="+cvid;
        }
        CrmPopupWindow('MassSMS',surl,parent_type);	
	}
}
//手动添加手机号
MassSmsPopupBind.addManualAddPhone = function(){
	var headtitle = arrJsPopLabel['IMPORTRECIPIENTPHONE'];//标题
    var OkText = arrJsPopLabel['CONFIRMED'];//确定按钮名称，为空暂时默认为确定
    var CancelText = arrJsPopLabel['CANCEL'];//取消按钮名称
    var content = '<div class="ld-public-content-small"><textarea name="txtarea_import_sms" class="ld-textarea-inner"></textarea></div>';
        
    var MsgPopupobj=MsgPopup.load(headtitle,MassSmsPopupBind.SaveManualAddPhone,'LdPopWidth600px','MassSMS',OkText,CancelText);
    MsgPopupobj.refreshpage='yes';
    MsgPopupobj.show(content); 
}
//手机添加手机号，保存
MassSmsPopupBind.SaveManualAddPhone = function(stype_name){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid=popupobj.divid;
	var reg=/(1[0-9]{10})<(.+)>/g;
	var digit=/^1\d{10}$/g;
	var new_errmsg = '';
	var stype_div = 'txtarea_import_sms';
	if(!empty(stype_name)){
		stype_div = stype_name;
	}
	if(CrmPopup.findHtmlobj(divid,stype_div) != undefined){
		if(CrmPopup.findHtmlobj(divid,stype_div).val() != ''){
			var phones=CrmPopup.findHtmlobj(divid,stype_div).val().split("\n");
			var phone="";
			for(var i=0; i<phones.length;i++)
            {
                var key=phones[i];
				if(key == '')continue;
                var r=key.match(reg);
                if(r!=null)
                {
                    phone+=key+"\n";
                }
                else if(key.match(digit))
                {
                    phone+=key+"\n";
                }else{
					var errmsg = arrJsPopLabel['linethephonenumberiswrong'];
					new_errmsg += errmsg.replace('{hang}',key) + '<br>';
				}
            }
			if(!empty(new_errmsg)){
				RemindsMsg("","LdPopWidth400px","","","",new_errmsg);
				return false;
			}else{
				//手动添加
				if('txtarea_import_sms' == stype_div){
					var prevpopupobj=CrmPopup.getPopupObj('lastprev');
					var divid=prevpopupobj.divid;
					var receivephone = CrmPopup.findHtmlobj(divid,'receivephone').val();
					CrmPopup.findHtmlobj(divid,'receivephone').val(receivephone+phone);
					cancelCrmPopup();
				}
				return true;
			}
		}else{
			RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['PLEASEENTERTHEMOBILEPHONENUMBEREN']);
			return false;
		}
	}
}
//选择短信模板
MassSmsPopupBind.SelectMassSmsTemplate = function(){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid=popupobj.divid;
	var receivetem = CrmPopup.findHtmlobj(divid,'receivetem').val();
	if(receivetem > 0){
		 new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:"module=MassSMS&action=MassSMSAjax&file=SendView&ajax=true&type=addtem&receivetem="+receivetem,
			onComplete: function(response) {
				if(response.responseText.indexOf('#####')>-1){
					var result=response.responseText.split('#####');
					CrmPopup.findHtmlobj(divid,'receivecontent').val(result[1]);
					MassSmsPopupBind.countChar();
				}
			}
		});
	}
}
//计算短信内容字符长度
MassSmsPopupBind.countChar = function(){
	//在鼠标粘贴事件之后获取内容，所以在500毫秒之后执行
	var popupobj=CrmPopup.getPopupObj('last');
	var divid=popupobj.divid;
	setTimeout(function(){
		var valLength = CrmPopup.findHtmlobj(divid,'receivecontent').val().length;
		var SignatureLength = CrmPopup.findHtmlobj(divid,'hidden_autograph').val().length;
		var allLength = valLength + SignatureLength;
		CrmPopup.findHtmlobj(divid,'now_counter').html(valLength);	//当前内容字数
		CrmPopup.findHtmlobj(divid,'signature_counter').html(SignatureLength);	//签名内容字数
		CrmPopup.findHtmlobj(divid,'all_counter').html(allLength);	//总共内容字数
	},500);
}
function SendMassSms()
{
	var popupobj=CrmPopup.getPopupObj('last');
	var divid=popupobj.divid;
	//接收人手机
	var receivephone = CrmPopup.findHtmlobj(divid,'receivephone').val();
	if(receivephone == ''){
		var _msg = CrmPopup.findHtmlobj(divid,'receivephone').attr('tag') + arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","","",_msg);
		CrmPopup.findHtmlobj(divid,'receivephone').focus();
		return false;
	}else{
		if(MassSmsPopupBind.SaveManualAddPhone('receivephone') == true){
			var receivephone_array = new Array();
			receivephone_array = receivephone.split('\n');
			//短信内容
			var receivecontent = CrmPopup.findHtmlobj(divid,'receivecontent').val();
			var template_type = 'ordinary';
			var select_smstemplateid = "";
			var templateparamconf = {};

			var platform = CrmPopup.findHtmlobj(divid,'platform').val();
			if (platform == 'aliyun') {
				select_smstemplateid = ld("#"+popupobj.divid+" [name=smstemplatelist]").val();
				if (select_smstemplateid < 1) {
					var confirm_str = arrJsPopLabel["TEMPLATE"]+arrJsPopLabel["CANOTEMPTY"];
					MessagePopup.TipZero_warning(confirm_str);
					return false;
				}

				try {
					ld.each(SmsContentSetting.getInstance().smsTemplateList,function(tmpindex,tmpsmstemplateinfo){
						if (select_smstemplateid == tmpsmstemplateinfo.templateid) {
							var templateparaminfo = JSON.parse(tmpsmstemplateinfo.templateparaminfo) || eval('('+tmpsmstemplateinfo.templateparaminfo+')');
							if (!empty(templateparaminfo)) {

								ld.each(templateparaminfo,function(tmp_varname,tmp_crmvarname){
									var tmp_crmvarname_value = trim(ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").val());
									if (tmp_crmvarname_value.length == 0) {
										ld("#"+popupobj.divid+" [name=smstemplateparam_table] tbody [name="+tmp_varname+"]").focus();
										var confirm_str = 'CRM' + arrJsPopLabel['VAR'] + arrJsPopLabel['CANOTEMPTY'] + '!';
										MessagePopup.TipZero_warning(confirm_str);
										throw 'ExitLoops';
									}
									templateparamconf[tmp_varname] = tmp_crmvarname_value;

								})


							}
							return false;//跳出循环
						}

					})
				}catch(e){
					if (e === 'ExitLoops') {
						return false;
					}
				}

			}else{
				if(empty(receivecontent)){
					var _msg = CrmPopup.findHtmlobj(divid,'receivecontent').attr('tag') + arrJsPopLabel['CANOTEMPTY'];
					RemindsMsg("","LdPopWidth400px","","","",_msg);
					CrmPopup.findHtmlobj(divid,'receivecontent').focus();
					return false;
				}else{
					if(CrmPopup.findHtmlobj(divid,'receivetem') != undefined && CrmPopup.findHtmlobj(divid,'receivetem').find("option:selected") != undefined && CrmPopup.findHtmlobj(divid,'receivetem').find("option:selected").attr('tag') != undefined){
						template_type =  CrmPopup.findHtmlobj(divid,'receivetem').find("option:selected").attr('tag');
					}
				}
			}
			//发送短信增加进度条
			var intervalrow =10;
			MassSmsPopupBind.SendMassSms_Progress(receivephone_array,receivecontent,template_type,0,intervalrow,platform,select_smstemplateid,templateparamconf);


		}
	}
}

/*
edit:duan 发送短信增加进度条
receivephone_array:电话号码数组,
receivecontent:短信内容,
template_type:模板类型,
tmp_start:每次发送开始位置,
intervalrow:每次发送数量    
*/
MassSmsPopupBind.SendMassSms_Progress = function(receivephone_array,receivecontent,template_type,tmp_start,intervalrow,platform,select_smstemplateid,templateparamconf){
    //获取需要发送的号码
    var num_phone = receivephone_array.length;
    if(tmp_start+intervalrow >= num_phone){
        var tmp_end = num_phone;
    }else{
        var tmp_end = tmp_start+intervalrow;
    }
    var tmp_phonearr = receivephone_array.slice(tmp_start,tmp_end);
    //显示进度条
    if(CrmPopup.getPopupObj('last')!=undefined&&CrmPopup.getPopupObj('last').type == 'ProgressPopup'){//新建或修改进度条弹出层
        tmppopupobjobj=CrmPopup.getPopupObj('last');
        var popupobj=CrmPopup.getPopupObj('lastprev');
    }else{
        var popupobj=CrmPopup.getPopupObj('last');
        tmppopupobjobj=ProgressPopup.load(popupobj.headtitle,"","",500,popupobj.module,"","","","");
        var htmlcontent="<div class='import_process' style='margin-left:30px;'><div class='progressbar batchProgress'></div>";
        htmlcontent+="<div class='import_info'>共需发送<span class='num totalnum'></span>条短信，</span>正在发送第<span class='num curnum'></span>条短信，请稍后……</div></div>";
		tmppopupobjobj.showhtml(htmlcontent);
        tmppopupobjobj.setPercentWidth(0);
        tmppopupobjobj.setTotalNum(num_phone);
       	tmppopupobjobj.setCurNum(tmp_start+1);
    }
    //提交发送短信
    ld.ajax({
        url:"index.php?action=MassSMSAjax&module=MassSMS&file=Send&mode=ajax&template_type="+template_type,
        data:{"jsondata":tojson(tmp_phonearr.join(','),receivecontent),"smstemplateid":select_smstemplateid,"smstemplateparamconf":!empty(templateparamconf)?JSON.stringify(templateparamconf):''},
        type:"POST"
        }).done(function(results){
			var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
			if(restobj.code == 1){
				//更新进度条显示
                if(num_phone==0){//没有获取数据时显示最大进度条
                    tmppopupobjobj.setPercentWidth(100);
                	tmppopupobjobj.setTotalNum(0);
                	tmppopupobjobj.setCurNum(0);
                }else{
                    var percent=parseInt(tmp_start/num_phone*100);
                    tmppopupobjobj.setPercentWidth(percent);
                	tmppopupobjobj.setTotalNum(num_phone);
                	tmppopupobjobj.setCurNum(tmp_end+1);
                }
                //判断是否结束循环
                if(tmp_end>=num_phone){
                    tmppopupobjobj.CancelEvent();
                    popupobj.CancelEvent();
                    var _msg = arrJsPopLabel['smsSendTips'];
					//wym 240326 BUG20240325-18 kfbcrm-群发短信，发送成功的提示信息样式错误
					MessagePopup.TipZero_success(_msg);
                }else{
                    MassSmsPopupBind.SendMassSms_Progress(receivephone_array,receivecontent,template_type,tmp_end,intervalrow,platform,select_smstemplateid,templateparamconf);
                }
			}
		})
}

function SendMassSmsVoice(){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid=popupobj.divid;
	//接收人手机
	var receivephone = CrmPopup.findHtmlobj(divid,'receivephone').val();
	if(receivephone == ''){
		var _msg = CrmPopup.findHtmlobj(divid,'receivephone').attr('tag') + arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","","",_msg);
		CrmPopup.findHtmlobj(divid,'receivephone').focus();
		return false;
	}else{
		if(MassSmsPopupBind.SaveManualAddPhone('receivephone') == true){
			//短信内容
			var receivetem = CrmPopup.findHtmlobj(divid,'receivetem').val();
			var receivephone_array = new Array();
			receivephone_array = receivephone.split('\n');
			if(receivetem == -1){
				var _msg = '短信模板' + arrJsPopLabel['CANOTEMPTY'];
				RemindsMsg("","LdPopWidth400px","","","",_msg);
				CrmPopup.findHtmlobj(divid,'receivecontent').focus();
				return false;
			}else{
                
				//提交发送短信
				ld.ajax("index.php?action=MassSMSAjax&module=MassSMS&file=SendSMSVoice&jsondata="+tojson(receivephone_array.join(','))+"&mode=ajax"+"&receivetem="+receivetem)
					.done(function(results){
						var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
						if(restobj.code == 1){
							cancelCrmPopup();
							var _msg = arrJsPopLabel['smsSendTips'];
							RemindsMsg("","LdPopWidth400px","","","",_msg);
						}
					})
			}
		}
	}
}
SendMassSms.funname="SendMassSms";
function tojson(receivephone,receivecontent){
	var array = [];
	array.push({"receivephone":receivephone,"receivecontent":receivecontent});
	return JSON.stringify(array);
}