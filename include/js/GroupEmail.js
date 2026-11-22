function GroupEmail(){
   var that=this;
   this.ue = '';
}
GroupEmail.initControl=function(){
    GroupEmail.ue = UE.getEditor('description1');
    	getJsScript('include/js/webuploader.js', function () {
				ld("[name=multiple_att").powerWebUpload({ 
					fileTypeDuplicate:'yes',	//附件类型判断
					fileNameDuplicate:'yes',	//同名附件判断
					mode:'',	//当前单据 create or edit
					module:'',	//当前模块
					jsonData:'',	//edit data,编辑界面显示已上传的附件
					record:'',	//单据单据id
					admin:'',//是否是管理员
					uitype:'',
					supportformat:'',//支持格式
					inputFileName:'groupemail',	//选择附件后赋值标签的name
					fileNumLimit:1000,
					special_ins: ''
				});
			});
}
GroupEmail.openEmailWindow = function(surl){
	var crmPopupobj=CrmPopup.load("","","","1200",'Emails',"","","","");
	crmPopupobj.prevshow();
  
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			crmPopupobj.setParams(data.result.title,"","","1200",'Emails',"","","","","");  
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			GroupEmail.initControl();
            
			GroupEmail.ue.ready(function() {
				crmPopupobj.center();
			},2);
		
			var popupobj=CrmPopup.getPopupObj("last");
			if(data.result.toemail != ''){
				ld("#"+popupobj.divid+" [name=parent_name]").val(data.result.toemail);
			}
		}
	})
}

GroupEmail.selectEmail = function(){
	var parent_type = document.EditView.parent_type.value;
	var surl = "module="+parent_type+"&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=set_return_groupemails&select=enable&popup=yes&page_popup=yes";
	CrmPopupWindow('Emails',surl,parent_type);
}

GroupEmail.submittemplate = function(obj)
{    
	var templateid = obj.value;
	if(templateid > 0){
		var surl = "index.php?module=Users&action=UsersAjax&file=TemplateMerge&templateid="+templateid;
		ldAjax(surl,"",function(data){
			if(data.code == 1){
				document.getElementById('description1').value = data.result.content;
				GroupEmail.ue.focus();
				GroupEmail.ue.execCommand('inserthtml',data.result.content);
			}
            DelProgressObjs();
		})
		
	}
}
//群发
GroupEmail.email_validate = function(oform,mode){
	if(trim(mode) == '')
	{
		return false;
	}
    if(document.EditView.from_email.value==''){
        var confirm_str = arrJsPopLabel['SENDERCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	if(oform.parent_name.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{
        var confirm_str = arrJsPopLabel['THERECOPIENTEMAILCANNOTBEEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    document.EditView.hidden_toid.value='';	
	//oform.mode.value=mode;//设置邮件是否保存还是发送
    var email_regex = /^[a-zA-Z0-9]+([\_\-\.]*[a-zA-Z0-9]+[\_\-]?)*@[a-zA-Z0-9]+([\_\-]?[a-zA-Z0-9]+)*\.+([\_\-]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)*$/;
    if(document.EditView.parent_name != null){
        if(document.EditView.parent_name.value.length >= 1){
			var str = document.EditView.parent_name.value;                     
            arr = new Array();
            arr = str.split("\n");      
            var tmp;
	    	for(var i=0; i<=arr.length-1; i++){
	            tmp = arr[i];
	            if(tmp.match('<') && tmp.match('>')) {
	            	// 0041929: （61mis.com/kfbcrm）联系人模块>序时簿界面：勾选单据点击“群发邮件”，录入主题还内容点击“群发”按钮没反应
	            	// diony 20200707 先注释这个判断
					// if(!findAngleBracket(arr[i])) {
					// 	var confirm_str = mail_err_msg+": "+arr[i];
					// 	RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
					// 	return false;
					// }
                    //edit:can 2020-10-230042940: (61mis.com/kfbcrm)营销-群发邮件；进行新发邮件操作，选择收件人之后，操作发送邮件，显示发送成功；但是只有手动输入的邮箱地址可以收到邮件，其他选择的邮箱都无法收到，因为选择的邮箱地址后带联系人或客户名称，手动删除后才可收到。
                    document.EditView.hidden_toid.value=document.EditView.hidden_toid.value+trim(arr[i])+',';
            	}
				else if(trim(arr[i]) != "" && !(email_regex.test(trim(arr[i]))))
	            {
                        var confirm_str = arrJsPopLabel['YOUREMAILADDRESSISNOTCORRECT']+": "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	                    return false;
	            }
                else if(trim(arr[i]) != "" && email_regex.test(trim(arr[i]))){
                    document.EditView.hidden_toid.value=document.EditView.hidden_toid.value+trim(arr[i])+',';
                }
			}
		}
	}
    
	if(mode == 'send')
	{
	   
		GroupEmail.server_check()	
	}
    else
	{
		return false;
	}
}

GroupEmail.server_check = function(){
    var oform = window.document.EditView;
    var popupobj=CrmPopup.getPopupObj('last');
    
	var surl = "index.php?module=Emails&action=EmailsAjax&file=Save&ajax=true&server_check=true";
    var tmpurl="description1="+encodeURIComponent(ld("#"+popupobj.divid+" [name=description1").val());
	ldAjaxNoProgress(surl,"",function(data){
		if(data.code==1){
			oform.send_mail.value='true';
			oform.action.value='Save';
            var  formdata=ld("#"+popupobj.divid+'.ajax_form').get(0);
            
		  //var dataurl="&parent_name="+document.EditView.hidden_toid.value+"&hidden_toid="+(document.EditView.hidden_toid.value);//+"&description1="+encodeURIComponent(ld("#"+popupobj.divid+" [name=description1").val())+"&subject="+ld("#"+popupobj.divid+" [name=subject").val();
         var parent_name = document.EditView.hidden_toid.value;
         var dataurl ='&from_email='+ld("#"+popupobj.divid+" [name=from_email").val();
        var fieldname='groupemail';
        var divid=popupobj.divid;
        var tmpfilenum = 0;
          for (var k = 1; k < 60; k++) {
                //editor:gyq_169 reason:腾讯云COS文件上传预览    2020/2/26 23:00
                if (CrmPopup.isExistsObj(divid, fieldname + "-file_name_" + k)) {
                    dataurl += "&" + fieldname + "-file_name_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-file_name_" + k));
                    dataurl += "&" + fieldname + "-file_type_" + k + "=" + CrmPopup.getHtmlobjval(divid, fieldname + "-file_type_" + k);
                    dataurl += "&" + fieldname + "-file_size_" + k + "=" + CrmPopup.getHtmlobjval(divid, fieldname + "-file_size_" + k);
                    dataurl += "&" + fieldname + "-file_path_" + k + "=" + CrmPopup.getHtmlobjval(divid, fieldname + "-file_path_" + k);
                    dataurl += "&" + fieldname + "-newfile_name_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-newfile_name_" + k));
                    dataurl += "&" + fieldname + "-upload_from_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-upload_from_" + k));
                   // alert(globalWebUploadType);
                   //考虑历史数据
                  var storage_location=CrmPopup.getHtmlobjval(divid, fieldname + "-storage_location_" + k)
                    if(storage_location=='cos'){
                        dataurl += "&" + fieldname + "-cloud_path_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-cloud_path_" + k));
                    }
                    dataurl += "&" + fieldname + "-storage_location_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-storage_location_" + k));
                    dataurl += "&" + fieldname + "-isEncrypt_" + k + "=" + encodeURIComponent(CrmPopup.getHtmlobjval(divid, fieldname + "-isEncrypt_" + k));
                    tmpfilenum++;
                }

            }

            dataurl += "&" + fieldname + "-file_num=" + tmpfilenum+"&"+fieldname+"-attachmentcolumnname="+fieldinfo.columnname+"&subject="+ld("#"+popupobj.divid+" [name=subject]").val();
			var surl = "";
            
            var reg=/,$/gi;
            parent_name=parent_name.replace(reg,"");
            var receivedemail_array = parent_name.split(',');
            var intervalrow = 1;
            GroupEmail.email_validate_Progress(receivedemail_array,dataurl,tmpurl,0,intervalrow);
			
			return false;
		}else{
			RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
			return false;
		}
	})
}
//分批次发送邮件,parent_name:待发送的邮件列表
GroupEmail.email_validate_Progress = function(receivedemail_array,tmp_dataurl,tmpurl,tmp_start,intervalrow){
    var num_email = receivedemail_array.length;
    if(tmp_start+intervalrow >= num_email){
        var tmp_end = num_email;
    }else{
        var tmp_end = tmp_start+intervalrow;
    }
    var tmp_emailarr = receivedemail_array.slice(tmp_start,tmp_end);
    //显示进度条
    if(CrmPopup.getPopupObj('last')!=undefined&&CrmPopup.getPopupObj('last').type == 'ProgressPopup'){//新建或修改进度条弹出层
        tmppopupobjobj=CrmPopup.getPopupObj('last');
        var popupobj=CrmPopup.getPopupObj('lastprev');
    }else{
        var popupobj=CrmPopup.getPopupObj('last');
        tmppopupobjobj=ProgressPopup.load(popupobj.headtitle,"","",500,popupobj.module,"","","","");
        var htmlcontent="<div class='import_process' style='margin-left:30px;'><div class='progressbar batchProgress'></div>";
        htmlcontent+="<div class='import_info'>共需发送<span class='num totalnum'></span>封邮件，</span>正在发送第<span class='num curnum'></span>封邮件，请稍后……</div></div>";
		tmppopupobjobj.showhtml(htmlcontent);
        tmppopupobjobj.setPercentWidth(0);
        tmppopupobjobj.setTotalNum(num_email);
       	tmppopupobjobj.setCurNum(1);
    }
	var dataurl =tmp_dataurl+ "&parent_name="+tmp_emailarr.join(',')+"&hidden_toid="+tmp_emailarr.join(',');
	var surl = 'index.php?module=Emails&action=EmailsAjax&file=Save&send_mail=true&groupemail=groupemail'+dataurl;
	ldAjaxNoProgress(surl,tmpurl,function(data){
		if(num_email==0){//没有获取数据时显示最大进度条
			tmppopupobjobj.setPercentWidth(100);
			tmppopupobjobj.setTotalNum(0);
			tmppopupobjobj.setCurNum(0);
		}else{
			var percent=parseInt(tmp_start/num_email*100);
			tmppopupobjobj.setPercentWidth(percent);
			tmppopupobjobj.setTotalNum(num_email);
			tmppopupobjobj.setCurNum(tmp_end+1);
		}
		//判断是否结束循环
		if(tmp_end>=num_email){
			tmppopupobjobj.CancelEvent();
			var confirm_str=arrJsPopLabel['SENDSUCCESSFULLY'];
			MessagePopup.TipOne_success(confirm_str);
		}else{
			GroupEmail.email_validate_Progress(receivedemail_array,tmp_dataurl,tmpurl,tmp_end,intervalrow);
		}
	})
	/*
    var dataurl =tmp_dataurl+ "&parent_name="+tmp_emailarr.join(',')+"&hidden_toid="+tmp_emailarr.join(',');
    
	ldAjaxNoProgress(
	 
        'index.php?module=Emails&action=EmailsAjax&file=Save&send_mail=true&groupemail=groupemail'+dataurl,
		 tmpurl,
		  function(data) {
                //更新进度条显示
                if(num_email==0){//没有获取数据时显示最大进度条
                    tmppopupobjobj.setPercentWidth(100);
                	tmppopupobjobj.setTotalNum(0);
                	tmppopupobjobj.setCurNum(0);
                }else{
                    var percent=parseInt(tmp_start/num_email*100);
                    tmppopupobjobj.setPercentWidth(percent);
                	tmppopupobjobj.setTotalNum(num_email);
                	tmppopupobjobj.setCurNum(tmp_end+1);
                }
                //判断是否结束循环
                if(tmp_end>=num_email){
                    tmppopupobjobj.CancelEvent();
                    var confirm_str=arrJsPopLabel['SENDSUCCESSFULLY'];
    				MessagePopup.TipOne_success(confirm_str);
                }else{
                    GroupEmail.email_validate_Progress(receivedemail_array,tmp_dataurl,tmpurl,tmp_end,intervalrow);
                }
		}
	 
     );
	*/
}