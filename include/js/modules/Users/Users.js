/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *
 ********************************************************************************/

var user_pagetype="edit_detail";


function set_return(user_id, user_name) {
	
     if(window.opener.document.EditView.reports_to_name!=undefined)
     {
        window.opener.document.EditView.reports_to_name.value = user_name;
		window.opener.document.EditView.reports_to_id.value = user_id;
     }
     else if(window.opener.document.EditView.approveby_name!=undefined)
     {
        window.opener.document.EditView.approveby_name.value = user_name;
		window.opener.document.EditView.approveby.value = user_id;
     }
    	
       
}
//	0020671: 控制面板>用户管理新增、编辑界面：【审批委托】停用时，【审批委托人】没有置灰并清空用户，用户无法清除，导致停用审批委托后审批还是走的委托步骤
function UpdateApproveby_name(obj){
    
	if(obj.value == 1){
		if(document.getElementById('approveby_name') != undefined){
			document.getElementById('approveby').value = '';
			document.getElementById('approveby_name').innerHTML = '';
			if(document.getElementById('approveby_img') != undefined){
				document.getElementById('approveby_img').style.display='none';
			}
		}
	}else{
		if(document.getElementById('approveby_img') != undefined){
		  document.getElementById('approveby_name').innerHTML = '';
          document.getElementById('approveby').value = '';
			document.getElementById('approveby_img').style.display='';
		}
	}
}
/**
 * 弹出框用户选择事件
 * @reason 0008999 审批委托人 无法选择用户
 * @author Tujt 2014-05-26
 */
function set_return_specific(user_id, user_name) {
	if(window.opener.document.EditView.reports_to_name!=undefined){
		window.opener.document.EditView.reports_to_name.value = user_name;
		window.opener.document.EditView.reports_to_id.value = user_id;
	}
    else if(window.opener.document.EditView.approveby_name!=undefined){
		window.opener.document.EditView.approveby_name.value = user_name;
		window.opener.document.EditView.approveby.value = user_id;
	}
    /**
    *by andy
    *公海客户改进
    */
    else if(window.opener.document.EditView.user_name!=undefined){
		if(document.getElementById('allotaccount') != undefined && document.getElementById('allotaccount').value == 'true')
		{
			window.opener.document.EditView.allotuser_name.value = user_name;
			window.opener.document.EditView.allotuserid.value = user_id;
		}
		else{
			window.opener.document.EditView.user_name.value = user_name;
			window.opener.document.EditView.userid.value = user_id;
		}
		
	}

}

var fckEditoFrame = '';



var state = 'none';
var state2 = 'none';


function resetuser(recordid,page){
	getUserAttachment(recordid,'Attachment',page);
}
function getUserAttachEntries_js(module,url)
{
    getUserAttachment.url=url;
    var recordid=getUrlParam("record");
    
    getUserAttachment(recordid,'Attachment',1);
}
/*
zyh
用户详情页增加附件
PROT197 
20150420
*/
function getUserAttachment(recordid,frommodule,page){
    var url = 'module=Users&action=UsersAjax&file=getUserAttachment&record='+recordid+'&frommodule='+frommodule+'&page='+page;
    if(getUserAttachment.url!='')
    {
       url+="&"+getUserAttachment.url;
    }
    
    new Ajax.Request(
		'index.php',
		{	queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: url,
			onComplete: function(response) {

				var results = trim(response.responseText);
                if(results !=''){
                    document.getElementById('RelatedContent').style.display = 'inline';
                    document.getElementById('RelatedContent').innerHTML = results;
                }
                
			}	
		}
	);
}
getUserAttachment.url='';

function deleteUser(obj,userid,BLOCKIDSETTING,FIELDIDSETTING){
	if(ld('#ListViewContents tr').hasClass('selectedbj')){
        ld('#ListViewContents tr').removeClass('selectedbj');
    }
	//设置当前字段所在为黄色
    ld('input[name=userlistview'+userid+']').parent().parent().addClass('selectedbj');
    var url = 'index.php?action=UsersAjax&file=UserDeleteStep1&return_action=ListView&return_module=Users&module=Users&parenttab=Settings&record='+userid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING;
    //ZXM 20230815  kfbcrm-成员管理-删除成员，转换负责任下拉框搜索功能不生效  将弹出层改成统一的弹出层  transferUser的js方法也改了
    ldAjaxNoProgress(url,'',function(res) {
        //transferUser('{$delete_user_id}','{$blockidsetting1}','{$fieldidsetting1}')"
        var tmpwidth = "600px";
        var Popupobj = CrmPopup.load(res.result.title, transferUser, "", tmpwidth, 'Users', "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
        Popupobj.setParams(res.result.title, transferUser, '', tmpwidth, 'Users', [res.result.delete_user_id,res.result.blockidsetting1,res.result.fieldidsetting1], arrJsPopLabel['SAVE'], "",  arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,res.result.content);
        //下拉框
        var tmpobj1 = ld("#" + Popupobj.divid + " #UserDelete");
        if(tmpobj1.length>0) {
            var cls_resetComboxHtmlobj = new cls_resetComboxHtml(tmpobj1.attr("name"));
            cls_resetComboxHtmlobj.setPickListContent(res.result.picklistcontent)
            cls_resetComboxHtmlobj.searchhtmltype='html';
            cls_resetComboxHtmlobj.setPopupObj(Popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj1, 200);
        }
    });
}
function transferUser(del_userid,BLOCKIDSETTING,FIELDIDSETTING)
{
    var popupobj=CrmPopup.getPopupObj('last');
    //edit:can 2021-02-28 44777: （http://51mis.com/ys/standard0223 [^]）成员管理，删除成员时加载进度条修改为圆圈状加载中
    var trans_userid=ld('#'+popupobj.divid).find('#UserDelete').val();
    var urlstring='index.php?module=Users&action=UsersAjax&file=DeleteUser&ajax=true&delete_user_id='+del_userid+'&transfer_user_id='+trans_userid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING;
        ldAjaxHtml(urlstring,{},function(response){
            puyoungJS_DialogBox.unblock();
            //	0026359: 控制面板>用户管理：输入查找条件筛选出单据，删除一条后刷出了所有单据
            if(popupobj.type==ListPagePopup.type) {
                 // var pagenum=ld("#ListViewContents [name=pagenum]").val();
            }else {
                popupobj.CancelEvent();
            }
            var valuefinfo=getEmptyValueInfo();
            
            var tmparr=[];
            tmparr.push(0);
            var tmmodules=[];
            tmmodules.push('Users');
            var tmpobj= new AfterUpdatePrevPopupObjContent('Users',valuefinfo,tmparr);
            tmpobj.eachrefreshlistbyModules(tmmodules);
            DelProgressObjs();
            MessagePopup.TipZero_success(arrJsPopLabel['SUCCESS']);
        })
}

 /*
用户管理改进
PROT202
zyh
20150423
设置状态
*/
/*
bug修改
andy
20150508
控制面板>用户管理,关于删除用户的问题
*/
function setStatus(obj,userid,status){
    var blockidsetting = 4;
    var fieldidsetting = 2;

    var datafilter = 'module=Users&action=UsersAjax&file=setstatus&ajax=true&userid='+userid+'&status='+status+'&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting;
  
    ld.ajax({
       url:'index.php',
       data:datafilter,
       type:'post',
       success:function(rest){
         if(rest.indexOf('###ERROR###')>=0)
         {
            var results=rest.split('###ERROR###');
            alert(results[1]);
            return false;
         }
         
         
          var pagenum=ld("#ListViewContents [name=pagenum]").val();
                            
         getListViewEntries_js('Users','parenttab=Tools&start='+pagenum);
       } 
    });
}


/*
用户管理改进
PROT202
zyh
20150423
设置角色
*/
function setProfile(obj,userid){
	if(ld('#ListViewContents tr').hasClass('selectedbj')){
        ld('#ListViewContents tr').removeClass('selectedbj');
    }
	 //设置当前字段所在为黄色
    var selectids=ld("#allselectedboxes").val();
    if(selectids=="")
    {
        alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
        return false;
    }
    var datafilter = 'module=Users&action=UsersAjax&file=setProfile&ajax=true&select=profileid&userid='+userid+"&selectids="+selectids;
    ld.ajax({
        url:'index.php',
        data:datafilter,
        type:'post',
        success:function(rest){
            if(rest == '') return false;
            var rarray = JSON.parse(rest);
            var ispermit=rarray['permitted'];
            var display="none";
            if(ispermit=='yes')
            {
                display=" ";
                
            }
            createElementDiv('setProfile_div');
          
            document.getElementById('setProfile_div').className='D_pop_box LdPopWidth600px';
           // document.getElementById('setProfile_div').style.height='305px';
           // document.getElementById('setProfile_divcontent').style.height='';
            document.getElementById('setProfile_divcontent').className='';
            ld('#setProfile_divcontent').css('overflow-y','visible');
			document.getElementById('setProfile_divcontent').style.maxHeight='305px';
            ld('#setProfile_div .D_pop_tit .D_ptita').html(arrJsPopLabel['SETTHEPERMISSIONS']);
            ld('#setProfile_div #setProfile_divcontent').html('<input type="hidden" id="userid" value="'+userid+'"/>'+
                        '<table cellspacing="1" cellpadding="1" border="0" class="D_pop_bod">'+
                            '<tr>'+
                                '<td align="right" width="35%">'+arrJsPopLabel['SETTHEPERMISSIONSAS']+'</td>'+
                                '<td><select id="selectrole"></select></td>'+
                            '</tr>'+
                        '</table>'+
                        '<table cellspacing="1" cellpadding="1" border="0" class="D_pop_bod"  style="display:'+display+'">'+
                            '<tr>'+
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['Allowtoviewotherusers']+'</td>'+'<td><input name="viewothers" id="viewothers" type="checkbox" tabindex="" style="margin-right:5px;"><font class="greyFont9">'
                                +arrJsPopLabel['VIEWTHEDETAILS']+'</font></td>'+
                            '</tr>'+
                            '<tr>'+
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['Allowtoeditotherusers']+'</td>'+'<td><input name="editothers" id="editothers" type="checkbox" tabindex="" >'
                                +'</font></td>'+
                            '</tr>'+
                            '<tr>'+
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['Allowtodeleteotherusers']+'</td>'+'<td><input name="delothers" id="delothers" type="checkbox" tabindex="" >'
                                +'</font></td>'+
                            '</tr>'+
                            '<tr>'+
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['Allowtoqueryotherusers']+'</td>'+'<td><input name="viewselfbills" id="viewselfbills" type="checkbox" tabindex="" >'
                                +'</font></td>'+
                            '</tr>'+
							'<tr>'+
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['Allowtoeditotherusersmobile']+'</td>'+'<td><input name="edit_other_mobile" id="edit_other_mobile" type="checkbox" tabindex="" >'
                                +'</font></td>'+
                            '</tr>'+
							'<tr>'+
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['phonenumstyleaccordingtoparameters']+'</td>'+'<td><input name="is_mobile_style" id="is_mobile_style" type="checkbox" tabindex="" >'
                                +'</font></td>'+
                            '</tr>'+
                        '</table>');
            //var rest = JSON.parse(rest);
             fnvshobj(obj, 'setProfile_div');
        
            var rest = rarray.selectarray;
            var sr=document.getElementById('selectrole');
            sr.length=0;
            for(var i in rest){
                if(rest.hasOwnProperty(i)){
                   sr.options[sr.length] = new Option(rest[i],i);
                }
            }
            var userscope = rarray.userscope;
            ld("#selectrole").val(userscope.profileid);
			if(userscope.viewothers=='1')
            document.getElementById("viewothers").checked=true;
            if(userscope.editothers=='1')
            document.getElementById("editothers").checked=true;
            if(userscope.delothers=='1')
            document.getElementById("delothers").checked=true;
            if(userscope.viewselfbills=='1')
            document.getElementById("viewselfbills").checked=true;
			if(userscope.edit_other_mobile=='1')
            document.getElementById("edit_other_mobile").checked=true;
			if(userscope.is_mobile_style=='1')
            document.getElementById("is_mobile_style").checked=true;
            //alert(ld('#selectrole').length)
            if(ld(obj).parent().parent().find('td:eq(3)').find('a').attr('profileid') > 0){
                ld('#selectrole').val(ld(obj).parent().parent().find('td:eq(3)').find('a').attr('profileid'));
            }
            var issubmit = 1;
            ld('#setProfile_div .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                if(issubmit != 1) return false;
                var selectids=ld("#allselectedboxes").val();
                var sr2 = document.getElementById('selectrole');
                var userid = document.getElementById('userid');
                var datafilter = 'module=Users&action=UsersAjax&file=saveRoleProfile&ajax=true&profileid='+sr2.value+'&selectids='+selectids;
                
                var viewothers = Number(document.getElementById('viewothers').checked);
                var editothers = Number(document.getElementById('editothers').checked);
                var delothers = Number(document.getElementById('delothers').checked);
                var viewselfbills = Number(document.getElementById('viewselfbills').checked);
				var edit_other_mobile = Number(document.getElementById('edit_other_mobile').checked);
				var is_mobile_style = Number(document.getElementById('is_mobile_style').checked);
                datafilter+='&viewothers='+viewothers+'&editothers='+editothers+'&delothers='+delothers+'&viewselfbills='+viewselfbills+'&edit_other_mobile='+edit_other_mobile+'&is_mobile_style='+is_mobile_style;
               
                ld.ajax({
                   url:'index.php',
                   data:datafilter,
                   type:'post',
                   success:function(rest){
                        if(rest=='') return false;
                       // document.getElementById('ListViewContents').innerHTML = rest;
                        fninvshnew('setProfile_div');   
                           var pagenum=ld("#ListViewContents [name=pagenum]").val();
                            
                             getListViewEntries_js('Users','parenttab=Tools&start='+pagenum);
                   }
                }); 
                issubmit = 1;                   
            });   
        }
    });
}

function set_password(form) {
/**
 * @by andy
 * @reason 0008213: 非管理员：个人设置界面，修改密码，当用户的旧密码为空时，无法修改密码系统提示：请输入您的旧密码!
 * @date 20140527
 * @others NONE
*/
    var popupobj=CrmPopup.getPopupObj('last');


	if (trim(ld("#"+popupobj.divid+" [name=new_password]").val()) == "") {
        var confirm_str = arrJsPopLabel['ENTERNEWPASSWORD'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if (trim(ld("#"+popupobj.divid+" [name=confirm_new_password]").val()) == "") {
        var confirm_str = arrJsPopLabel['ENTERNEWPASSWORDAGAIN'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if (trim(ld("#"+popupobj.divid+" [name=new_password]").val()) == trim(ld("#"+popupobj.divid+" [name=confirm_new_password]").val())) {
        var old_pwd=ld("#"+popupobj.divid+" [name=old_password]").val();
        var new_pwd=ld("#"+popupobj.divid+" [name=new_password]").val();
        var confirm_new_password=ld("#"+popupobj.divid+" [name=confirm_new_password]").val();//document.getElementById("confirm_new_password").value;
        var tmpurlstring = 'module=Users&action=UsersAjax&file=SavePwd&oldpwd='+encodeURIComponent(old_pwd)+'&newpwd='+encodeURIComponent(new_pwd)+'&confirmpwd='+encodeURIComponent(confirm_new_password)+'&userid='+popupobj.record;

        ldAjaxHtml('index.php',tmpurlstring,function (ajaxhtml){
            DelProgressObjs();
            if(ajaxhtml.indexOf('SUCCESS') > -1)
            {
                popupobj.CancelEvent();//管理修改密码弹框
                if (CrmPopup.getPopupObj('last').record == ld('#oamenubar a').attr('referencerecord')) {
                    var confirm_str = arrJsPopLabel['OfflineNotification'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                    //确定按钮
                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                        window.location.reload();
                    });
                }
            }
            else if (ajaxhtml.indexOf('REPEAT') > -1) {
                var duplication =  arrJsPopLabel['PASSWORD_DUPLICATION'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",duplication);
            }
            else {
                puyoungJS_DialogBox.unblock();
                var results=ajaxhtml.split('$$error$$');
                RemindsMsg("","LdPopWidth400px","","yes","yes",results[1]);
                return false;
            }
        });
		return true;
	}
	else {
        var confirm_str = arrJsPopLabel['PASSWORDINCONSISTENT'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
}
set_password.funname='set_password';

function check_registerCount()
 {
     var recordid=document.EditView.record.value;
	 var userstatus;
	 if(document.EditView.status != undefined){
		userstatus=document.EditView.status.options[document.EditView.status.selectedIndex].value;
	 }
      if (recordid=="")
      {
      recordid=-1;
      }
      
	
    	new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Users&action=UsersAjax&file=Save&ajax=true&register_check=true&userStatus='+userstatus+'&userid='+recordid,
                        onComplete: function(response) {
							if(response.responseText.indexOf('SUCCESS') > -1)
							{
						          if(recordid>0)
                                  {
                                    document.EditView.submit();
                                  }
								
                                return true;
							}
			       				else {
			       					puyoungJS_DialogBox.unblock();
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",response.responseText);
                                    return false;
						        }
			            }
                }
        );

}
/*function check_duplicate()
{
	var user_name = window.document.EditView.user_name.value;
	if(user_name == '')
	{
		puyoungJS_DialogBox.unblock();
		return true;
	}
	var status = CharValidation(user_name,'name');
	var recordid=document.EditView.record.value;
	var userstatus;
	if(document.EditView.status != undefined&&document.EditView.status.selectedIndex!=undefined){
		userstatus=document.EditView.status.options[document.EditView.status.selectedIndex].value;	
	}
	var dup_check=false;
      if (recordid=="")
      {
		  recordid=-1;
		  dup_check=true;
      }
     
        if(status)
	{
        	new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'module=Users&action=UsersAjax&file=Save&ajax=true&dup_check='+dup_check+'&register_check=yes&userName='+user_name+'&userStatus='+userstatus+'&userid='+recordid,
                                onComplete: function(response) {

        							if(response.responseText.indexOf('SUCCESS') > -1)
        							{
                                        if(ALLSETROLEDATAPROFILE=='no'&&USER_MODE!='edit')
                                        {
                                            var confirm_str = arrJsPopLabel['USESAVEREMINDROLEPROFILE'];
                                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                        }
        							//	$('user_status').disabled = false;
        								document.EditView.submit();
        							}
        			       				else 
                                        {
        			       					//puyoungJS_DialogBox.unblock();
//                                            if(response.responseText.indexOf('用户账户已经存在！') > -1)
//                                            {
//                                                var confirm_str = arrJsPopLabel['USERACCOUNTEXISTS'];
//                                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
//                                            }
//                                            else
//                                            {
//                                                var confirm_str = response.responseText;
//                                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
//                                            }
        						        }
        			            }
                        }
                );
	}
	/!*else
     {
                var confirm_str = arrJsPopLabel['ACCOUNTBYTO'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                //puyoungJS_DialogBox.unblock();
     }*!/
}*/


function set_fieldfocus(errorMessage,oMiss_field){
		alert(arrJsPopLabel['ERR_MISSING_REQUIRED_FIELDS']);
		oMiss_field.focus();	
}

function User_verify_data(form) {
     //puyoungJS_DialogBox.block();
     var popupobj=CrmPopup.getPopupObj('last');
     
     if((form.find("[name=approvestatus]").length>0&&form.find("[name=approvestatus]").val()==0))
     {
      
        ////edit:can 2020-09-03042572: （61mis.com/kfbcrm）（王耀文客户问题）成员管理模块编辑界面>启用审批委托：选择审批委托人后点击“保存”按钮，提示“审批委托人不允许为空。”（需要补丁）
       if(ld.trim(form.find("[name=cmb_span_optiontext_approvestatus]").val())!=''&&form.find("[name=approveby]").val()<=0)
        {
            //37160: PC端-成员管理-编辑：审批委托并没有开启，但是保存的时候审批委托启用了要设置审批委托人
            //数据库值是空的
            var confirm_str = arrJsPopLabel['APPROVINGCLIENTCANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
               // puyoungJS_DialogBox.unblock();
                return false;
        }
   }

    
        var isError = false;
	var errorMessage = "";
	
	
	if (form.find("[name=last_name]").val() == "") {
		isError = true;
		errorMessage += "\\n$lbl_last_name";
		oField_miss =form.find("[name=last_name]");
	}



	if (trim(form.find("[name=user_name]").val()) == "") {
		isError = true;
		errorMessage += "\\n$lbl_user_name";
		oField_miss =form.find("[name=user_name]");
	}

	/*if (trim(form.find("[name=groupid_name]").val()) == "") {
		isError = true;
		oField_miss =form.find("[name=groupid_name]");
	}*/

	if (isError == true) {
	    puyoungJS_DialogBox.unblock();
		set_fieldfocus(errorMessage,oField_miss);
		return false;
	}
	var status = CharValidation(trim(form.find("[name=user_name]").val()),'name');
	if(!status){
		var confirm_str = arrJsPopLabel['ACCOUNTBYTO'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if( form.find("[name=email1]").length>0){
		form.find("[name=email1]").val(trim(form.find("[name=email1]").val())) ;
		if (form.find("[name=email1]").val() != "" && !/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(form.find("[name=email1]").val())) {
            var confirm_str = "$the_emailid"+form.find("[name=email1]").val()+"$email_field_is";
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			 //puyoungJS_DialogBox.unblock();
			form.find("[name=email1]").val().focus();
		   
			return false;
		}
	}
	if(form.find("[name=email2]").length>0){
		form.find("[name=email2]").val(trim(form.find("[name=email2]").val())) ;
		if (form.find("[name=email2]").val()!= "" && !/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(form.find("[name=email2]").val())) {
            var confirm_str = "$the_emailid"+form.find("[name=email2]").val()+"$other_email_field_is";
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			form.find("[name=email2]").focus();
			return false;
		}
	}


    if(form.find("[name=imagename]").length>0){//Liver bug0027411: 控制面板>用户管理：隐藏用户头像字段，用户管理编辑无法保存。
       	if(! upload_filter("imagename", "jpg|gif|bmp|png|JPG|GIF|BMP|PNG") )
    	{
    	    puyoungJS_DialogBox.unblock();
    		form.find("[name=imagename]").focus();
    		return false;
    	} 
    }


	if(form.find("[name=mode]").val()!= 'edit')
	{
		if(trim(form.find("[name=user_password]").val()) != trim(form.find("[name=confirm_password]").val()))
		{
			//puyoungJS_DialogBox.unblock();
            var confirm_str = arrJsPopLabel['THE_PASSWORD'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		
	}
	/**
	edit:can
	reason:12954,新增用户时，超过最大许多用户数时，程序没有判断，直接保存成功
	**/
	//check_duplicate();
 
    return true;    
}

function Op_UserGroup (htmlobj)
{
     var that=this;
    this.htmlobj=htmlobj;
    this.initGroup =function(){
         this.mode="";//编辑edit，新增create，删除del，隐藏hide
         this.htmlobj=htmlobj;
         this.parentgrouphtmlobj=that.htmlobj;
         this.recordhtmlobj=htmlobj;

         if(Op_UserGroup.curr_group_obj!=undefined&&Op_UserGroup.curr_group_obj!="")
         {
            //zkt 20221014 BUG0057599成员管理部门浮显的界面问题
            Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").parent().parent().css("color","");
            Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").css("display","inherit");//#666
         }
         this.recordhtmlobj.find("label").css("display","inherit");
         this.recordhtmlobj.find("label").parent().parent().css("color","#3B7CFF");

          while(this.recordhtmlobj.prop("tagName")!=undefined&&this.recordhtmlobj.prop("tagName").toLowerCase()!="span")
          {
            this.recordhtmlobj=this.recordhtmlobj.parent();
          }

          this.records=this.recordhtmlobj.attr("record").split("_");
          this.record=this.records[1];//获取部门ID
         while(this.parentgrouphtmlobj.prop("tagName")!=undefined&&this.parentgrouphtmlobj.prop("tagName").toLowerCase()!="li")
         {
            this.parentgrouphtmlobj=Tools.getParentobjByChild(this.parentgrouphtmlobj,'li');
         }

       Op_UserGroup.curr_group_obj=this;
    }
      this.initGroup();
}

Op_UserGroup.curr_group_obj="";
Op_UserGroup.EditGroup=function()
{
    //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
    var popupobj=CrmPopup.getlastPopupObjByPageType('listpage');
    if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
        popupobj.groupobj.initGroup();
    }
    var module="Users";
    var urlstring="index.php?module=Users&action=UsersAjax&file=getUserGroup&record="+Op_UserGroup.curr_group_obj.record;
    var group_type = 'crm';
    if(popupobj.user_type){
        group_type = popupobj.user_type;
    }
    urlstring += '&group_type='+group_type;
    ld.ajax({
            url: urlstring,
            type: 'POST',
            data:'',
           dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code==1)
                {
                    //zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 获取字段启用状态
                    Op_UserGroup.isDepartmentNumber=data.result.departmentNumber;
                    Op_UserGroup.isDepartmentRemark=data.result.departmentRemark;

                     $("status").style.display="none";
                    var Popupobj=CrmPopup.load(data.result.title,Op_UserGroup.save,"","LdPopWidth800px",module,"",data.result.oktext,"",data.result.canceltext);
                    Popupobj.group_type = group_type;
                    Popupobj.show(data.result.content);
                    Op_UserGroup.curr_group_obj.mode='edit';
                    ld('#'+Popupobj.divid+' a[tag=clearselectgroup]').on('click',function(){
                    	 ld('#'+Popupobj.divid+" input[name=parentid]").val('');
                    	 if(ld('#'+Popupobj.divid+" input[name=parentid_name]").length > 0){
                             ld('#'+Popupobj.divid+" input[name=parentid_name]").val('');
                         }
                       if(ld('#'+Popupobj.divid+" div[name=parentid_name]").length > 0){
                           ld('#'+Popupobj.divid+" div[name=parentid_name]").html('');
                       }
                  	});
                    ld('#'+Popupobj.divid+' a[tag=clearselectrelated]').on('click',function(){
                        ld('#'+Popupobj.divid+" input[name=related_crmid]").val('');
                        if(ld('#'+Popupobj.divid+" input[name=related_crmid_name]").length > 0){
                            ld('#'+Popupobj.divid+" input[name=related_crmid_name]").val('');
                        }
                        if(ld('#'+Popupobj.divid+" div[name=related_crmid_name]").length > 0){
                            ld('#'+Popupobj.divid+" div[name=related_crmid_name]").html('');
                        }
                    });


                    return Popupobj;
                }

            }
        });
}
Op_UserGroup.AddGroup=function()
    {

        //zkt 0046701: （81mis.com/kfbcrm）系统设置-成员管理，新增成员直接关闭界面，然后点击新增部门，没有显示上级部门是跟部门
        //reason：新增成员界面关闭后，原Op_UserGroup对象丢失，传输的parentid对应的record值为空，导致弹出框出错（没有上级部门选项）

        //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
        var popupobj=CrmPopup.getlastPopupObjByPageType('listpage');
        if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
            popupobj.groupobj.initGroup();
        }
        var module="Users";
        var urlstring="index.php?module=Users&action=UsersAjax&file=getUserGroup&parentid="+Op_UserGroup.curr_group_obj.record;
        var group_type = 'crm';
        if(popupobj.user_type){
            group_type = popupobj.user_type;
        }
        urlstring += '&group_type='+group_type;
        ld.ajax({
            url: urlstring,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                if(data.code==1)
                {
                    //zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 获取字段启用状态
                    Op_UserGroup.isDepartmentNumber=data.result.departmentNumber;
                    Op_UserGroup.isDepartmentRemark=data.result.departmentRemark;
                    $("status").style.display="none";
                    var Popupobj=CrmPopup.load(data.result.title,Op_UserGroup.save,"","LdPopWidth800px",module,"",data.result.oktext,"",data.result.canceltext);
                    Popupobj.group_type = group_type;
                    Popupobj.show(data.result.content);
                    Op_UserGroup.curr_group_obj.mode='create';
                    //BUG0068235 txy 2023.06.18 后台设置成员管理，新增部门打开光标应该停留在部门名称上，目前没有光标
                    ld('#'+Popupobj.divid).find("[name='groupname']").focus();

                    ld('#'+Popupobj.divid+' a[tag=clearselectrelated]').on('click',function(){
                        ld('#'+Popupobj.divid+" input[name=related_crmid]").val('');
                        if(ld('#'+Popupobj.divid+" input[name=related_crmid_name]").length > 0){
                            ld('#'+Popupobj.divid+" input[name=related_crmid_name]").val('');
                        }
                        if(ld('#'+Popupobj.divid+" div[name=related_crmid_name]").length > 0){
                            ld('#'+Popupobj.divid+" div[name=related_crmid_name]").html('');
                        }
                    });
                }

            }
        });
    }
Op_UserGroup.listfirst=1;
Op_UserGroup.listparams={CustomViewObj:"",viewid:0};
Op_UserGroup.nowdepth=0;
Op_UserGroup.nodecount=[];
Op_UserGroup.setEvent=function()
{


    if(ld("#viewuserlist span[tag=user_group]")!=undefined&&ld("#viewuserlist span[tag=user_group]").length>0)
    {
                //部门节点点击事件
               ld("#viewuserlist span[tag=user_group]").unbind("click").on("click",function(event){

                    var parentliobj=Tools.getParentobjByChild(this,'li');
                    if(ld.inArray(ld(this).attr("record"), Op_UserGroup.nodecount)<0&&Op_UserGroup.nodecount[0]!="")
                    {
                        Op_UserGroup.nodecount=[];
                    }
                    //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
                    var popupobj=CrmPopup.getPopupObj('last');
                    if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
                        popupobj.groupobj.initGroup();
                    }
                    Op_UserGroup.nodecount.push(ld(this).attr("record"));
                    if(ld(this).prev()!=undefined&&ld(this).prev().length>0&&ld.inArray(ld(this).attr("record"), Op_UserGroup.nodecount)>=0&&Op_UserGroup.nodecount.length>=2)
                    {
                        ld(this).prev().click();
                        // ld(this).prev().html("收缩");
                        //  parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','block');
                        //  ld(this).prev().attr("class","group_node_collapse");
                    }
                    else
                    {
                        Op_UserGroup.CreateObj(ld(this));
                        showDefaultCustomView(Op_UserGroup.listparams['CustomViewObj'],"Users","",Op_UserGroup.listparams['viewid']);

                    }

               });

      //展开收缩事件
      ld("#viewuserlist span[name=group_expand_collapse]").unbind("click").on("click",function(event){
          event.stopPropagation();
        var parentliobj=Tools.getParentobjByChild(this,'li');
        var nowdepth=ld(this).attr("depth");
        if(ld(this).attr("class").indexOf("group_node_collapse")>=0)//如果是收缩
        {
          // console.log('收缩');
          parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','none');
          ld(this).attr("class","group_node_expand");
          ld(this).addClass("tree-right");
        }
        else //如果是展开
        {
          // console.log('展开');
          parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','block');
          ld(this).attr("class","group_node_collapse");
          ld(this).addClass("tree-down");
        }
        //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
            popupobj.groupobj.initGroup();
        }
        Op_UserGroup.CreateObj(ld(this).next());
        if(event.target == this){

        }else{
            showDefaultCustomView(Op_UserGroup.listparams['CustomViewObj'],"Users","",Op_UserGroup.listparams['viewid']);
        }

      });
    }

    //zkt 鼠标离开更多操作（新增、编辑、删除子部门）div事件
    ld('#user-libutton-box').unbind("mouseleave").bind("mouseleave",function(){
        ld('#user-libutton-box').hide();
        hideGroupMenu();

    })

    //成员管理显示title
    tooltip('#viewuserlist .file', {transition: true, time: 200});
}

//zkt 更多按钮点击事件
function moreclick(nowobj){
    ld('#user-libutton-box').hide();
    var nowdivobj=ld(nowobj).parent().parent();
    var adduldiv=ld('#user-libutton-box');
    var depth=ld(nowobj).parent().prev().attr('depth');
    var divheight = ld(nowobj).parent().height();
    var divTop = ld(nowobj).parent().offset().top;
    var windowHeight = ld(window).height();
    var pageheadheight=ld('#pagehead').height();
    //zkt 20240126 BUG20240126-43 8624：部门编辑不了
    var listviewscreenheight=0;
    if(ld("#ld-listview-screen").length>0){
        listviewscreenheight = ld("#ld-listview-screen").height();
    }
    var top = parseInt(divTop) - parseInt(pageheadheight) - parseInt(listviewscreenheight)-20;//head与下方间距
    ld('#user-libutton-box').show();
    //BUG0068239 txy 6.16 判断底部不够，向上对齐
    if(window.s_height - nowobj.offset().top < adduldiv.get(0).offsetHeight){
      top = top - adduldiv.get(0).offsetHeight + nowobj.get(0).offsetHeight;
    }
    ld(adduldiv).css('top',top+'px');

    // var tmp_left = parseInt(structureTreeobj.treeWidth);
    // tmp_left = tmp_left - 20;
    // console.log(ld('#pageleft_unfold'));
    ld(adduldiv).css('left',nowobj.offset().left-ld('#pageleft_unfold').width()+'px');
    //鼠标移至更多操作框事件，调整部门的背景颜色及显示状态
    ld('#user-libutton-box').unbind("mouseover").bind("mouseover",function(){
        ld(nowdivobj).parent().css('background-color','#ebf3ff');//部门div背景色
        ld(nowdivobj).find('span[tag=user_group]').css('color','#3B7CFF');//部门div所在span颜色设置
        ld(nowdivobj).find('div[name=operate_group]').css('display','inline-block');//操作按钮（上移、下移、更多）显示

        var divwidth = ld(nowdivobj).width();
        var liobj=Tools.getParentobjByChild(nowdivobj,'li');
        var opwidth =  20;
        //控制上移、下移的显示
        if(liobj.prev()!=undefined&&liobj.prev().length>0){
            ld(nowdivobj).find("a[tag=moveup]").attr('style','');
            opwidth = opwidth + 20;
        }
        else{
            ld(nowdivobj).find("a[tag=moveup]").attr('style','display:none');
        }
        if(liobj.next()!=undefined&&liobj.next().length>0){
            ld(nowdivobj).find("a[tag=movedown]").attr('style','');
            opwidth = opwidth + 27;
        }
        else{
            ld(nowdivobj).find("a[tag=movedown]").attr('style','display:none');
        }
        var spanobj = ld(nowdivobj).find("span[tag=user_group]");
        var spanwidth = divwidth - 15 - opwidth;//20:更多;
        var labelwidth = ld(spanobj).find("label").width();
        var multiple = parseInt(labelwidth/divwidth)+1;

        // ld(spanobj).css('width',spanwidth);
    });
    //编辑按钮点击
    ld('#user-libutton-box').find('a[name=editgroup]').unbind("click").on("click",function(){
        ld('#user-libutton-box').hide();
        var tmpeditspan=ld(nowdivobj).find('span[tag=user_group]');
        Op_UserGroup.CreateObj(tmpeditspan);
        Op_UserGroup.EditGroup();
    })
    //新增按钮点击
    ld('#user-libutton-box').find('a[name=addgroup]').unbind("click").on("click",function(){
        ld('#user-libutton-box').hide();
        var tmpaddspan=ld(nowdivobj).find('span[tag=user_group]');
        Op_UserGroup.CreateObj(tmpaddspan);
        Op_UserGroup.AddGroup();
    })
    //删除按钮点击
    ld('#user-libutton-box').find('a[name=deletegroup]').unbind("click").on("click",function(){
        ld('#user-libutton-box').hide();
        var tmpdeletespan=ld(nowdivobj).find('span[tag=user_group]');
        Op_UserGroup.CreateObj(tmpdeletespan);
        Op_UserGroup.deleteGroup();
    })
    //字段设置弹出框
    ld('#user-libutton-box').find('a[name=fieldSetting]').unbind("click").on("click",function(){
        ld('#user-libutton-box').hide();
        var tmpdeletespan=ld(nowdivobj).find('span[tag=user_group]');
        var module="Users";
        var crmPopUpObj=CrmPopup.load(arrJsPopLabel['SETFIELD'],"","","LdPopWidth800px",module,"","","","");
        var urlstring="index.php?module=Users&action=UsersAjax&file=setUserGroupField";
        ldAjaxNoProgress(urlstring,'',function(res){
            if(res.code==1)
            {
                crmPopUpObj.setParams(arrJsPopLabel['SETFIELD'],userGroupFieldSave,"","LdPopWidth450px",module,"",res.result.oktext,"",res.result.canceltext);
                crmPopUpObj.show(res.result.content);
            }
        })
    })
    //隐藏部门按钮点击
    ld('#user-libutton-box').find('a[name=hidegroup]').unbind("click").on("click",function(){
        ld('#user-libutton-box').hide();
        var tmphidespan=ld(nowdivobj).find('span[tag=user_group]');
        Op_UserGroup.CreateObj(tmphidespan);
        Op_UserGroup.hideGroup();
    })
    //恢复隐藏部门按钮点击
    ld('#user-libutton-box').find('a[name=recovergroup]').unbind("click").on("click",function(){
        ld('#user-libutton-box').hide();
        var tmphidespan=ld(nowdivobj).find('span[tag=user_group]');
        Op_UserGroup.CreateObj(tmphidespan);
        Op_UserGroup.recoverGroup();
    })

    return ;
}

//zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数
function userGroupFieldSave(){
    var popupobj=CrmPopup.getPopupObj("last");
    var urlstring="index.php?module=Users&action=UsersAjax&file=SaveGroup";
    if(popupobj!=undefined)
    {
        var departmentNumber=CrmPopup.getHtmlobjval(popupobj.divid,"departmentNumber");
        var departmentRemark=CrmPopup.getHtmlobjval(popupobj.divid,"departmentRemark");
        departmentNumber=(departmentNumber==0?'no':'yes');
        departmentRemark=(departmentRemark==0?'no':'yes');
        urlstring+="&departmentNumber="+encodeURIComponent(departmentNumber)+"&departmentRemark="+encodeURIComponent(departmentRemark);
        ldAjaxNoProgress(urlstring,'',function (res) {
            if (res.code == 1) {
                if(res.result.departmentNumber=='no'){
                    ld("span.departmentNumber").css('display', 'none');
                }
                else{
                    ld("span.departmentNumber").css('display', 'unset');
                }
                popupobj.CancelEvent();
            }
        })
    }
    return ;
}

//zkt 鼠标离开事件，不显示上移、下移、更多按钮
function  hideGroupMenu()
{

    ld("div[name=user_group]").css('background-color','');//所有部门div背景色取消
    ld("div[name=user_group]").find('span[tag=user_group]').each(function(){
        ld(this).css('color','');//所有部门span color取消
        // var thiswidth = ld(this).parent().width()-15;
        // ld(this).css('width',thiswidth);

    });
    ld("#viewuserlist").find('div[name=operate_group]').css('display','none');//操作按钮（上移、下移、更多）div
    return ;
}
//鼠标经过部门事件，显示上移、下移、更多按钮
function showGroupMenu(obj)
{
    var divobj=obj;
    ld('#user-libutton-box').hide();
    ld("div[name=user_group]").css('background-color','');
    var liobj=Tools.getParentobjByChild(divobj,'li');
    ld(divobj).css('background-color','#ebf3ff');//当前部门设置背景色
    ld(divobj).find('span[tag=user_group]').css('color','#3B7CFF');//当前部门span color设置
    ld(divobj).find('div[name=operate_group]').css('display','inline-block');//当前部门操作按钮显示

    var divwidth = ld(divobj).width();
    var opwidth =  20;
    //控制上移、下移的显示
    if(liobj.prev()!=undefined&&liobj.prev().length>0){
        ld(divobj).find("a[tag=moveup]").attr('style','');
        opwidth = opwidth + 20;
    }
    else{
        ld(divobj).find("a[tag=moveup]").attr('style','display:none');
    }
    if(liobj.next()!=undefined&&liobj.next().length>0){
        ld(divobj).find("a[tag=movedown]").attr('style','');
        opwidth = opwidth + 27;
    }
    else{
        ld(divobj).find("a[tag=movedown]").attr('style','display:none');
    }

    //ld(divobj).find("a[tag=more]").attr('style','');
    var spanobj = ld(divobj).find("span[tag=user_group]");
    var spanwidth = divwidth - 15 - opwidth;//20:更多;
    var labelwidth = ld(spanobj).find("label").width();
    var multiple = parseInt(labelwidth/divwidth)+1;

    // ld(spanobj).css('width',spanwidth);

    //添加更多点击事件
    ld(divobj).find("a[tag=more]").unbind("click").on('click',function(){
        ld('#user-libutton-box').find('a[name=deletegroup]').parent().attr('style','');
        ld('#user-libutton-box').find('a[name=hidegroup]').parent().attr('style','');
        ld('#user-libutton-box').find('a[name=recovergroup]').parent().attr('style','display:none');
        //当前部门为根部门时不显示删除
        if(ld(divobj).find('span[tag=user_group]').attr('depth')=='0'){
            ld('#user-libutton-box').find('a[name=deletegroup]').parent().attr('style','display:none');
            ld('#user-libutton-box').find('a[name=hidegroup]').parent().attr('style','display:none');
            ld('#user-libutton-box').find('a[name=recovergroup]').parent().attr('style','');
        }
        moreclick(ld(this));
    })
    //添加上移点击事件
    ld(divobj).find("a[tag=moveup]").unbind("click").on("click",function(event){
        var tmpspan = ld(this).parent().parent().find('span[tag=user_group]');
        Op_UserGroup.moveGroup(tmpspan,'moveup');
    })
    //添加下移点击事件
    ld(divobj).find("a[tag=movedown]").unbind("click").on("click",function(event){
        var tmpspan = ld(this).parent().parent().find('span[tag=user_group]');
        Op_UserGroup.moveGroup(tmpspan,'movedown');
    })

    return ;
}
Op_UserGroup.init=function()
{

     if(ld("#viewuserlist span[tag=user_group]")!=undefined&&ld("#viewuserlist span[tag=user_group]").length>0)
    {
        if(Op_UserGroup.listfirst==1)
            {

                if(USER_GROUP_LIST_ID>1)
                {
                    ld("#viewuserlist span[tag=user_group]").each(function()
                    {
                         var records=ld(this).attr('record').split("_");
                         if(records[1]==USER_GROUP_LIST_ID)
                         {

                            Op_UserGroup.nowdepth=ld(this).attr("depth");

                            Op_UserGroup.CreateObj(ld(this));
                            Op_UserGroup.expandAllParent(ld(this));
                            Op_UserGroup.nodecount.push(ld(this).attr("record"));
                             // duan 20240423 加载树结构后滚动到点击位置
                             var all_parent_boxobj = ld('#viewuserlist'); //父节点
                             all_parent_boxobj.get(0).scrollTop = 0; //将父节点滚动条置为空
                             var location_info = ld(this).get(0).getBoundingClientRect(); //子节点到屏幕边框的距离
                             var parent_location_info = all_parent_boxobj.get(0).getBoundingClientRect();//父节点到屏幕边框的距离
                             //计算出子节点到父元素顶部的距离,减去父元素一半的高度,使子节点居中
                             var scroll_height = location_info.top - parent_location_info.top - all_parent_boxobj.height()/2;
                             if(scroll_height >0)all_parent_boxobj.get(0).scrollTop = scroll_height;

                            return false;
                         }
                    });
                }
                else
                {
                     Op_UserGroup.nowdepth=0;

                     Op_UserGroup.nodecount.push(ld("#viewuserlist span[depth=0][tag=user_group]").attr("record"));
                     Op_UserGroup.CreateObj(ld("#viewuserlist span[depth=0][tag=user_group]"));
                }
                Op_UserGroup.listparams['CustomViewObj']="";
                Op_UserGroup.listparams['CustomViewObj']=ld(".currdataClass").attr("viewid");
            }
            //duan 20240407 界面布局变化，每次点树结构都要重新加载
            //Op_UserGroup.listfirst++;
    }
    //zkt 20221216 BUG0060020成员管理左侧树结构列，缺少垂直滚动条
    var pageheadheight=ld('#pagehead').height();
    var ulmaxheight = CrmPopup.getClientHeight()-pageheadheight;
    if(ld('#users_left_top_title').length > 0){
        ulmaxheight = ulmaxheight - 40;
    }
    ld("#viewuserlist").css('overflow-y','auto');
    if(ld('.ld-listview-screen').length > 0){
        ulmaxheight = ulmaxheight - ld('.ld-listview-screen').get(0).offsetHeight - 9;
    }
    ld("#viewuserlist").css('height',ulmaxheight);
    ld("#viewuserlist").slimscroll({
        // width: '100%', //可滚动区域宽度
        height: ulmaxheight, //可滚动区域高度
        size: '5px', //滚动条宽度，即组件宽度
        color: '#DCDEE0', //滚动条颜色
        position: 'right', //组件位置：left/right
        distance: '0px', //组件与侧边之间的距离
        start: 'top', //默认滚动位置：top/bottom
        opacity: 1, //滚动条透明度
        alwaysVisible: false, //是否 始终显示组件
        disableFadeOut: true, //是否 鼠标经过可滚动区域时显示组件，离开时隐藏组件
        // railVisible: true, //是否 显示轨道
        // railColor: 'rgba(15,41,80,1)', //轨道颜色
        // railOpacity: 1, //轨道透明度
        // railDraggable: true, //是否 滚动条可拖动
        // railClass: 'slimScrollRail', //轨道div类名
        barClass: 'slimScrollBar', //滚动条div类名
        wrapperClass: 'slimScrollDiv', //外包div类名
        allowPageScroll: true, //是否 使用滚轮到达顶端/底端时，滚动窗口
        wheelStep: 5, //滚轮滚动量
        touchScrollStep: 50, //滚动量当用户使用手势
        borderRadius: '7px', //滚动条圆角
        railBorderRadius: '7px' //轨道圆角
    });
}
Op_UserGroup.CreateObj=function(obj)
{
    var popupobj=CrmPopup.getPopupObj('first');
    var groupobj=new Op_UserGroup(obj);
    popupobj.groupobj=groupobj;
    return groupobj;
}
/**
移动部门
**/
Op_UserGroup.moveGroup=function(obj,direction){

    //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
    var popupobj=CrmPopup.getPopupObj('last');
    if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
        popupobj.groupobj.initGroup();
    }
    var oldobj = Op_UserGroup.curr_group_obj.recordhtmlobj;
    Op_UserGroup.CreateObj(obj);//创建当前点击Op_UserGroup对象

        var urlstring = "index.php?module=Users&action=UsersAjax&file=MoveGroup&direction="+direction+"&record="+Op_UserGroup.curr_group_obj.record+'';
        ld.ajax({
        url: urlstring,
        type: 'POST',
        data:'',
       dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            if(data.code==1){
                $("status").style.display="none";


                //刷新列表

                var tmpobj = Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'li'); //点击的对象所在li
                var tmptranobj = "";
                if(direction=='moveup'){

                    if(ld(tmpobj).prev()!=undefined&&ld(tmpobj).prev().length>0){
                        tmptranobj = ld(tmpobj).prev();
                        ld('<li>'+tmptranobj.html()+'</li>').insertAfter(tmpobj);
                        ld(tmptranobj).remove();
                    }
                }
                else if(direction=='movedown'){
                    if(ld(tmpobj).next()!=undefined&&ld(tmpobj).next().length>0){
                        tmptranobj = ld(tmpobj).next();
                        ld('<li>'+tmptranobj.html()+'</li>').insertBefore(tmpobj);
                        ld(tmptranobj).remove();
                    }
                }
                Op_UserGroup.CreateObj(oldobj);//创建点击前Op_UserGroup对象，保证点击前后对象一致
                Op_UserGroup.setEvent();
            }
        }
    });
}
/**
删除部门
**/
Op_UserGroup.deleteGroup=function(){
        //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
            popupobj.groupobj.initGroup();
        }

        var module="Users";
            var urlstring="index.php?module=Users&action=UsersAjax&file=DeleteGroup&record="+Op_UserGroup.curr_group_obj.record;
             ld.ajax({
            url: urlstring,
            type: 'POST',
            data:'',
           dataType:'json',
            async: true,//
            timeout: 10000,
            success: function(data)
            {
                if(data.code==1)
                {
                    //zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 获取字段启用状态
                    Op_UserGroup.isDepartmentNumber=data.result.departmentNumber;
                    Op_UserGroup.isDepartmentRemark=data.result.departmentRemark;
                     $("status").style.display="none";

                    var Popupobj=CrmPopup.load(data.result.title,Op_UserGroup.save,"","LdPopWidth800px",module,"",data.result.oktext,"",data.result.canceltext);
                    Popupobj.show(data.result.content);
                    Op_UserGroup.curr_group_obj.mode='delete';
                    	//清除所选部门转移用户按钮
            		ld('#'+Popupobj.divid+' a[tag=cleardelusertogroup]').on('click',function(){

                      	ld('#'+Popupobj.divid+' input[name=delusertogroup]').val('');
                        ld('#'+Popupobj.divid+' input[name=delusertogroup_name]').val('');

            		});
                    	//清除所选部门转移下级部门按钮
            		ld('#'+Popupobj.divid+' a[tag=cleardellowertogroup]').on('click',function(){
            		   ld('#'+Popupobj.divid+' input[name=dellowertogroup]').val('');
                        ld('#'+Popupobj.divid+' input[name=dellowertogroup_name]').val('');

            		});

                }
                else{
                    if(data.code=='-1')
                    {
                        RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                        return false;
                    }
                         if(data.code=="-2")
                         {
                            RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                Op_UserGroup.curr_group_obj.mode='delete';
                                Op_UserGroup.save();
                            });
                         }
                    }

            }
        });

}
/**
隐藏部门
**/
Op_UserGroup.hideGroup=function(){
        //Op_UserGroup对象丢失时，获取当前的Op_UserGroup对象（即选中的部门span）
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.groupobj!=undefined&&Op_UserGroup.curr_group_obj==""){
            popupobj.groupobj.initGroup();
        }

        var module="Users";
        var urlstring="index.php?module=Users&action=UsersAjax&file=HideGroup&record="+Op_UserGroup.curr_group_obj.record;
        ldAjaxNoProgress(urlstring, '', function(data){
            if(data.code==1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    Op_UserGroup.curr_group_obj.mode='hide';
                    Op_UserGroup.save();
                });
            }
            else{
                if(data.code=='-1')
                {
                    RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                    return false;
                }
                 if(data.code=="-2")
                 {
                    RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                    return false;
                 }
            }
        })

}

/**
恢复隐藏部门
**/
Op_UserGroup.recoverGroup=function(){
    var urlstring1="index.php?module=Users&action=UsersAjax&file=RecoverGroup&type=popup";
    ldAjaxNoProgress(urlstring1, '', function(data)
    {
        if(data.code==1)
        {
            getJsScript('include/js/SystemPopup/PopupRecoverGroup.js',function(){
                var popupobj=PopupRecoverGroup.load(data.result.groupid);
                popupobj.triggertype='recover';
                popupobj.show();
            });
        }
        else
        {
            var confirm_str = data.msg;
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        }
    });
}

Op_UserGroup.save=function()
{
     var popupobj=CrmPopup.getPopupObj("last");
     var urlstring="index.php?module=Users&action=UsersAjax&file=SaveGroup";
     if(popupobj!=undefined)
    {
         var groupname=CrmPopup.getHtmlobjval(popupobj.divid,"groupname");
         var groupno=CrmPopup.getHtmlobjval(popupobj.divid,"groupno");
         var parentid=CrmPopup.getHtmlobjval(popupobj.divid,"parentid");
         urlstring+="&groupname="+encodeURIComponent(groupname)+"&groupno="+encodeURIComponent(groupno);

         if(ld('#'+popupobj.divid+' #related_crmid').length > 0){
             urlstring += '&related_crmid='+ld('#'+popupobj.divid+' #related_crmid').val();
         }
         if(popupobj.group_type){
             urlstring += '&group_type='+popupobj.group_type;
         }
    }
     if(Op_UserGroup.curr_group_obj.mode=='edit')
     {
         urlstring+="&description="+encodeURIComponent(CrmPopup.getHtmlobjval(popupobj.divid,"description"));
         urlstring+="&record="+Op_UserGroup.curr_group_obj.record+"&parentid="+parentid+"&oldparentid="+CrmPopup.getHtmlobjval(popupobj.divid,"oldparentid");
         if(groupname=='')
         {
            var confirm_str = arrJsPopLabel['GROUPNAME']+arrJsPopLabel['CANOTEMPTY'];//部门名称不能为空
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
         }
         if(groupno==''&&Op_UserGroup.isDepartmentNumber!='no')
         {
             var confirm_str = arrJsPopLabel['LBL_SUPEGROUPNO']+arrJsPopLabel['CANOTEMPTY'];//部门编号不能为空
             RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
             return false;
         }
         //根据当前选中部门对象的前一个span的depth属性是否为'0'判断当前节点是否为根部门，若不为根部门，则判断上级部门是否为空。
         if(Op_UserGroup.curr_group_obj.recordhtmlobj.prev().attr('depth')!='0')
             if(parentid==""||parentid<=0)
             {
                var confirm_str = arrJsPopLabel['LBL_SUPEGROUP']+arrJsPopLabel['CANOTEMPTY'];//上级部门不能为空
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
             }
         if(parentid==Op_UserGroup.curr_group_obj.record)
         {
            //35581: （1.6）成员管理明细界面>编辑任意一个子部门>将上级部门改为当前部门>保存>结果：该部门直接消失了。
            var confirm_str ="上级部门不能为当前编辑的部门";

            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
         }
     }
     else  if(Op_UserGroup.curr_group_obj.mode=='delete')
     {
         urlstring+="&delrecord="+Op_UserGroup.curr_group_obj.record;
         if(ld("#"+popupobj.divid+" input[name=delusertogroup]")!=undefined&&ld("#"+popupobj.divid+" input[name=delusertogroup]").length>0)
         {
                if(ld("#"+popupobj.divid+" input[name=delusertogroup]").val()=='')
             {
                var confirm_str = arrJsPopLabel['transferassociatedusers']+arrJsPopLabel['CANOTEMPTY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
             }
             urlstring+="&userto="+ld("#"+popupobj.divid+" input[name=delusertogroup]").val();
             if(document.getElementById("dellowertogroupTr").style.display!='none')
            {
                if(ld("#"+popupobj.divid+" input[name=dellowertogroup]").val()=='')
                {
                    var confirm_str = arrJsPopLabel['LBL_GROUPOTRANSFER1']+arrJsPopLabel['CANOTEMPTY'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    return false;
                }
            }
             urlstring+="&groupto="+ld("#"+popupobj.divid+" input[name=dellowertogroup]").val();
         }
     }
    else  if(Op_UserGroup.curr_group_obj.mode=='hide')
     {
         urlstring+="&hiderecord="+Op_UserGroup.curr_group_obj.record;
     }
     else if(Op_UserGroup.curr_group_obj.mode=='create')
     {
        urlstring+="&description="+encodeURIComponent(CrmPopup.getHtmlobjval(popupobj.divid,"description"));
         urlstring+="&parentid="+Op_UserGroup.curr_group_obj.record;
          if(groupname=='')
         {
            var confirm_str = arrJsPopLabel['GROUPNAME']+arrJsPopLabel['CANOTEMPTY'];//部门名称不能为空
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
         }else if(groupno==''&&Op_UserGroup.isDepartmentNumber!='no'){
            var confirm_str = arrJsPopLabel['GROUPNO']+arrJsPopLabel['CANOTEMPTY'];//部门编号不能为空
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
          }

     }
      var module="Users";

            ld.ajax({
            url: urlstring,
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
                     //BUG0068484 txy 2023.06.26 kfbcrm-成员管理-新增部门-新增的部门没有上移按钮
                    var nextobj=Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent().next();  //获取下一个li或ul对象
                    var groupname=data.result.groupname;
                    var groupno=data.result.groupno;
                    var groupid=data.result.groupid;
                    if(Op_UserGroup.curr_group_obj.mode=='create')
                    {
                        var parentdiv=Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'div');
                        // var tmpwidth=parseInt(ld(parentdiv).width())-10;
                        var operatediv = '';
                        //获取当前操作div的html（包含本身），作为新增部门操作div
                        operatediv = ld(parentdiv).find('div[name=operate_group]').prop('outerHTML');

                         if(nextobj&&nextobj.length>0)
                        {
                            // zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 如果不启用字段编号后编辑部门，保存后做特殊处理
                            // 部门编号字段启用
                            if(Op_UserGroup.isDepartmentNumber!='no'){
                                nextobj.append("<li><div class='groupuser-treediv' name='user_group' onmouseover='showGroupMenu(this)' onmouseout='hideGroupMenu(this)'><div class='groupuser-treediv-span'><span group_margin_right='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' style='margin-right:15px'></span><span class='file' tag='user_group' depth='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' record='group_"+groupid+"_1' data-tip='"+groupname+"' data-direction='top' data-type='position'><label>"+groupname+"<span class=\"departmentNumber\">("+groupno+")</span></label></span>"+operatediv+"</div></div></li>");
                            }
                            //部门编号字段不启用
                            if(Op_UserGroup.isDepartmentNumber=='no'){
                                nextobj.append("<li><div class='groupuser-treediv' name='user_group' onmouseover='showGroupMenu(this)' onmouseout='hideGroupMenu(this)'><div class='groupuser-treediv-span'><span group_margin_right='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' style='margin-right:15px'></span><span class='file' tag='user_group' depth='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' record='group_"+groupid+"_1' data-tip='"+groupname+"' data-direction='top' data-type='position'><label>"+groupname+"<span class=\"departmentNumber\" style=\"display: none\">("+groupno+")</span></label></span>"+operatediv+"</div></div></li>");
                            }
                            // nextobj.append("<li><div class='groupuser-treediv' name='user_group' onmouseover='showGroupMenu(this)' onmouseout='hideGroupMenu(this)'><div class='groupuser-treediv-span'><span group_margin_right='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' style='margin-right:15px'></span><span class='file' tag='user_group' depth='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' record='group_"+groupid+"_1' data-tip='"+groupname+"' data-direction='top' data-type='position'><label>"+groupname+"("+groupno+")"+"</label> </span>"+operatediv+"</div></div></li>");
                        }
                        else
                        {
                            var parentli=Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'li');
                             var depth=parseInt(Op_UserGroup.nowdepth);
                             Op_UserGroup.curr_group_obj.recordhtmlobj.prev().remove();
                             parentdiv.prepend("<span class='group_node_collapse tree-down' depth='"+depth+"'  name='group_expand_collapse'></span>");//收缩
                            //edit:can 20210602 46184: （81mis.com/kfbcrm）系统设置-成员管理-公司部门设置；新建的“分部门”，点击上级部门无法被收起
                            if(Op_UserGroup.isDepartmentNumber!='no'){
                                parentli.append("<ul depth='"+(parseInt(Op_UserGroup.nowdepth))+"'><li><div class='groupuser-treediv' name='user_group' onmouseover='showGroupMenu(this)' onmouseout='hideGroupMenu(this)'><div class='groupuser-treediv-span'><span style='margin-right:15px'></span><span class='file' tag='user_group' depth='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' record='group_"+groupid+"_1' data-tip='"+groupname+"' data-direction='top' data-type='position'><label>"+groupname+"<span class=\"departmentNumber\">("+groupno+")</span></label> </span>"+operatediv+"</div></div></li></ul>");
                            }
                            //部门编号字段不启用
                            if(Op_UserGroup.isDepartmentNumber=='no'){
                                parentli.append("<ul depth='"+(parseInt(Op_UserGroup.nowdepth))+"'><li><div class='groupuser-treediv' name='user_group' onmouseover='showGroupMenu(this)' onmouseout='hideGroupMenu(this)'><div class='groupuser-treediv-span'><span style='margin-right:15px'></span><span class='file' tag='user_group' depth='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' record='group_"+groupid+"_1' data-tip='"+groupname+"' data-direction='top' data-type='position'><label>"+groupname+"<span class=\"departmentNumber\" style=\"display: none\">("+groupno+")</span></label> </span>"+operatediv+"</div></div></li></ul>");
                            }
                             // parentli.append("<ul depth='"+(parseInt(Op_UserGroup.nowdepth))+"'><li><div class='groupuser-treediv' name='user_group' onmouseover='showGroupMenu(this)' onmouseout='hideGroupMenu(this)'><div class='groupuser-treediv-span'><span style='margin-right:15px'></span><span class='file' tag='user_group' depth='"+(parseInt(Op_UserGroup.nowdepth)+1)+"' record='group_"+groupid+"_1' data-tip='"+groupname+"' data-direction='top' data-type='position'><label>"+groupname+"("+groupno+")"+"</label> </span>"+operatediv+"</div></div></li></ul>");
                        }

                        Op_UserGroup.setEvent();
                       //设置当前选中的节点为当前新增的节点

                      // Op_UserGroup.nowdepth=parseInt(Op_UserGroup.nowdepth)+1;
                       ld("#viewuserlist span[record='group_"+groupid+"_1']").click();
                      Op_UserGroup.expandAllParent(Op_UserGroup.curr_group_obj.recordhtmlobj);
                       //Op_UserGroup.CreateObj(ld("#viewuserlist span[record='group_"+groupid+"_1']"));

                    }
                    else if(Op_UserGroup.curr_group_obj.mode=='delete')
                    {

                         var parentul=Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'ul');//获取span所在ul,获取选择的节点的所在上级节点
                         var nextul= Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent().next();//获取删除节点的子节点
                         var childspan=nextul.find("span[tag=user_group]");//获取子节点中所有span元素
                         var childul=nextul.find("ul");//获取子节点中所有ul元素
                         var expandcollapsespan=nextul.find("span[name=group_expand_collapse]");//获取子节点中所有展开收缩元素
                         var tmpparentobj="";

                         if(data.result.grouptreehtml!="")
                         {
                            ld("#viewuserlist span[tag=user_group]").each(function(){
                                 var records=ld(this).attr("record").split("_");
                                 if(records[1]==data.result.parentid)//获取转移到的父节点
                                 {
                                     var todepth=ld(this).attr("depth");
                                      var towidth=ld(this).parent().width();
                                      tmpparentobj=ld(this);
                                     var minusdepth=parseInt(todepth)-parseInt(Op_UserGroup.nowdepth);
                                     var minuswidth=parseInt(towidth)-parseInt(Op_UserGroup.curr_group_obj.recordhtmlobj.parent().width());

                                     //重新给节点的子节点的depth属性、子节点所属div的width属性重新赋值
                                     if(childspan!=undefined)
                                      {
                                        childspan.each(function(){
                                             var childspandepth=parseInt(ld(this).attr("depth"));
                                             ld(this).attr("depth",childspandepth+minusdepth);

                                             var childdivwidth=parseInt(ld(this).parent().width());
                                             // ld(this).parent().css('width',childdivwidth+minuswidth);
                                        });

                                      }
                                      if(childul!=undefined)
                                      {
                                         childul.each(function(){

                                            var childspandepth=parseInt(ld(this).attr("depth"));
                                             ld(this).attr("depth",childspandepth+minusdepth);
                                         });
                                      }
                                      if(expandcollapsespan!=undefined)
                                      {
                                         expandcollapsespan.each(function(){

                                            var childspandepth=parseInt(ld(this).attr("depth"));
                                             ld(this).attr("depth",childspandepth+minusdepth);
                                         });
                                      }
                                       var nextulhtml=nextul.html();

                                     var nextobj=ld(this).parent().next();

                                      if(nextobj!=undefined&&nextobj.length>0)
                                      {
                                        nextobj.append(nextulhtml);
                                      }
                                      else
                                      {

                                        ld(this).parent().find("[group_margin_right='"+todepth+"']").remove();
                                        if(ld(this).parent().find('span[name=group_expand_collapse]').length > 0){
                                        }else{
                                            ld(this).parent().prepend('<span name="group_expand_collapse" depth="'+todepth+'" class="group_node_collapse tree-down"></span>');
                                        }
                                        if(ld(this).parent().parent().parent().find('ul').length > 0){
                                            ld(this).parent().parent().next().append(nextulhtml);
                                        }else{
                                            ld(this).parent().parent().parent().append('<ul depth="'+todepth+'">'+nextulhtml+'</ul>');
                                        }
                                      }
                                      tmpparentobj=ld(this);

                                 }
                            });
                         }



                          Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent().parent().remove();//获取span所在li，删除所选节点
                         if(parentul.find("span")==undefined||parentul.find("span").length<=0)
                            {
                                //如果选择的删除节点的上级节点没有子节点，则删除展开收缩
                                var tmpdepth=parseInt(Op_UserGroup.curr_group_obj.recordhtmlobj.attr("depth"))-1;//得到上级节点的depth
                                parentul.prev().prepend('<span group_margin_right="'+tmpdepth+'" style="margin-right:15px">');
                                parentul.prev().find("span[name=group_expand_collapse]").remove();

                                parentul.remove();
                            }
                         Op_UserGroup.setEvent();
                         if(tmpparentobj!=undefined&&tmpparentobj!='')
                         {

                            tmpparentobj.click();
                            Op_UserGroup.expandAllParent(tmpparentobj);//把上级节点全部展开
                         }
                         else
                         {
                            //32227: 成员管理序时簿界面：选中部门名称，再删除部门，结果没有默认选中根部门名称
                            Op_UserGroup.nowdepth=0;

                             Op_UserGroup.nodecount.push(ld("#viewuserlist span[depth=0][tag=user_group]").attr("record"));
                             Op_UserGroup.CreateObj(ld("#viewuserlist span[depth=0][tag=user_group]"));
                             showDefaultCustomView(Op_UserGroup.listparams['CustomViewObj'],"Users","",Op_UserGroup.listparams['viewid']);
                         }


                    }else if(Op_UserGroup.curr_group_obj.mode=='hide')
                    {

                         var parentul=Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'ul');//获取span所在ul,获取选择的节点的所在上级节点
                         var tmpparentobj="";

                         
                          Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent().parent().remove();//获取span所在li，删除所选节点
                         if(parentul.find("span")==undefined||parentul.find("span").length<=0)
                            {
                                //如果选择的删除节点的上级节点没有子节点，则删除展开收缩
                                var tmpdepth=parseInt(Op_UserGroup.curr_group_obj.recordhtmlobj.attr("depth"))-1;//得到上级节点的depth
                                parentul.prev().prepend('<span group_margin_right="'+tmpdepth+'" style="margin-right:15px">');
                                parentul.prev().find("span[name=group_expand_collapse]").remove();
                                
                                parentul.remove();
                            }
                         Op_UserGroup.setEvent();
                         if(tmpparentobj!=undefined&&tmpparentobj!='')
                         {
                           
                            tmpparentobj.click();
                            Op_UserGroup.expandAllParent(tmpparentobj);//把上级节点全部展开
                         }
                         else
                         {
                            //32227: 成员管理序时簿界面：选中部门名称，再删除部门，结果没有默认选中根部门名称
                            Op_UserGroup.nowdepth=0;
                   
                             Op_UserGroup.nodecount.push(ld("#viewuserlist span[depth=0][tag=user_group]").attr("record"));
                             Op_UserGroup.CreateObj(ld("#viewuserlist span[depth=0][tag=user_group]"));
                             showDefaultCustomView(Op_UserGroup.listparams['CustomViewObj'],"Users","",Op_UserGroup.listparams['viewid']);
                         }
                       
                         
                    }
                    else if(Op_UserGroup.curr_group_obj.mode=='edit')
                    {
                        //如果更改了上级部门
                         if(data.result.grouptreehtml!="")
                         {
                             // Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").html(groupname+'('+groupno+')');
                             // zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 如果不启用字段编号后编辑部门，保存后做特殊处理
                             // 部门编号字段启用
                             if(Op_UserGroup.isDepartmentNumber!='no'){
                                 var editdata=groupname+"<span class=\"departmentNumber\">("+groupno+")</span>";
                             }
                             //部门编号字段不启用
                             if(Op_UserGroup.isDepartmentNumber=='no'){
                                 var editdata=groupname+"<span class=\"departmentNumber\" style=\"display: none\">("+groupno+")</span>";
                             }
                             Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").html(editdata);
                             var parentli=Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'li');
                             var parentul=Tools.getParentobjByChild(Op_UserGroup.curr_group_obj.recordhtmlobj,'ul');//获取span所在ul,获取选择的节点的所在上级节点
                             var childspan=parentli.find("span[tag=user_group]");//获取子节点中所有span元素
                             var childul=parentli.find("ul");//获取子节点中所有ul元素
                             var expandcollapsespan=parentli.find("span[name=group_expand_collapse]");//获取子节点中所有展开收缩元素
                            var tmpparentobj="";
                            ld("#viewuserlist span[tag=user_group]").each(function(){
                                 var records=ld(this).attr("record").split("_");
                                 if(records[1]==data.result.parentid)
                                 {
                                    
                                      var todepth=ld(this).attr("depth");
                                      var towidth=ld(this).parent().width();
                                      tmpparentobj=ld(this);
                                     var minusdepth=parseInt(todepth)-parseInt(Op_UserGroup.nowdepth)+1;
                                     var minuswidth=parseInt(towidth)-parseInt(Op_UserGroup.curr_group_obj.recordhtmlobj.parent().width())-10;
                                     
                                      //重新给删除节点的子节点的depth属性、子节点所在div的width属性重新赋值
                                     if(childspan!=undefined)
                                      {
                                        childspan.each(function(){
                                             var childspandepth=parseInt(ld(this).attr("depth"));
                                             ld(this).attr("depth",childspandepth+minusdepth);
                                             
                                             var childdivwidth=parseInt(ld(this).parent().width());
                                             // ld(this).parent().css('width',childdivwidth+minuswidth);
                                        });
                                          
                                      }
                                      if(childul!=undefined)
                                      {
                                         childul.each(function(){
                                            
                                            var childspandepth=parseInt(ld(this).attr("depth"));
                                             ld(this).attr("depth",childspandepth+minusdepth);
                                         });
                                      }
                                      if(expandcollapsespan!=undefined)
                                      {
                                         expandcollapsespan.each(function(){
                                            
                                            var childspandepth=parseInt(ld(this).attr("depth"));
                                             ld(this).attr("depth",childspandepth+minusdepth);
                                         });
                                      }


                                     var nextobj=ld(this).parent().parent().next();
                                      if(nextobj!=undefined&&nextobj.length>0)
                                      {
                                        nextobj.append("<li>"+parentli.html()+"</li>");
                                      }
                                      else
                                      {
                                        
                                        
                                        ld(this).parent().find("[group_margin_right='"+todepth+"']").remove();
                                         ld(this).parent().prepend("<span class='group_node_collapse tree-down' depth='"+parseInt(ld(this).attr("depth"))+"'  name='group_expand_collapse'></span>");
                                        ld(this).parent().parent().parent().append('<ul depth="'+todepth+'"><li>'+parentli.html()+'</li></ul>');
                                      }
                                 }
                            });
                            Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent().remove();
                            if(parentul.children()==undefined||parentul.children().length<=0){
                                  //如果选择的删除节点的上级节点没有子节点，则删除展开收缩
                                var tmpdepth=parseInt(parentul.prev().find("span[tag=user_group]").attr("depth"));//得到上级节点的depth
                                parentul.prev().prepend('<span group_margin_right="'+tmpdepth+'" style="margin-right:15px">');
                                parentul.prev().find("span[name=group_expand_collapse]").remove();
                                
                                parentul.remove();
                            }
                             var editnoderecord=Op_UserGroup.curr_group_obj.recordhtmlobj.attr("record");
                            Op_UserGroup.setEvent();
                            
                           Op_UserGroup.expandAllParent(ld("#viewuserlist span[record='"+editnoderecord+"']"));
                           ld("#viewuserlist span[record='"+editnoderecord+"']").click();
                           Op_UserGroup.expandAllParent(tmpparentobj);//把上级节点全部展开
                         }
                         else
                         {
                             ////zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数 如果不启用字段编号后编辑部门，保存后做特殊处理
                             //部门编号字段启用
                             if(Op_UserGroup.isDepartmentNumber!='no'){
                                 var editdata=groupname+"<span class=\"departmentNumber\">("+groupno+")</span>";
                             }
                             //部门编号字段不启用
                             if(Op_UserGroup.isDepartmentNumber=='no'){
                                 var editdata=groupname+"<span class=\"departmentNumber\" style=\"display: none\">("+groupno+")</span>";
                             }
                             Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").html(editdata);
                             Op_UserGroup.curr_group_obj.recordhtmlobj.click();
                             Op_UserGroup.expandAllParent(Op_UserGroup.curr_group_obj.recordhtmlobj);
                         }
                         
                        
                    }
                    popupobj.CancelEvent();
                }else if(data.code==-1){
                    if(data.msg=='groupnorepeat'){
                        var confirm_str = arrJsPopLabel['GROUPNO']+arrJsPopLabel['CANNOTREPEAT'];//部门编号不能重复
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                    }
                }
            
            }
        });
}
Op_UserGroup.save.funname="Op_UserGroup_save";


Op_UserGroup.expandAllParent=function(obj)
{
    
     if(obj==""||obj==undefined)
     {
        ld("#viewuserlist span[depth=0]").click();
        //删除无节点的部门，则obj为空
        return ;
     }
    if(obj.parent().next()!=undefined&&obj.parent().next().length>0)
    {
        obj.parent().next().css("display","block");
    }
    var prevobj = obj.prev();
    if(prevobj!=undefined&&prevobj.length>0)
      {
        if(prevobj.hasClass("group_node_expand"))
        {
            prevobj.attr("class","group_node_collapse");
            prevobj.addClass("tree-down");
            //duan 20240423 图标显示为展开后,将子节点也显示
            var nowdepth=prevobj.attr("depth");
            var parentliobj=Tools.getParentobjByChild(obj,'li');
            parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','block');
        }
        
      }
  //  obj.prev().html("收缩");
    var parentobj=obj;
   
    while(parentobj!=undefined&&parentobj.length>0&&parseInt(parentobj.attr("depth"))>=0)
    {
       
        parentobj=Tools.getParentobjByChild(parentobj,'ul');//获取上级节点(ul);
        parentobj.css("display","block");
        parentobj.prev().find("span[name=group_expand_collapse]").attr("class","group_node_collapse");
        parentobj.prev().find("span[name=group_expand_collapse]").addClass('tree-down');
          
    }
 
}
function selectGroup(field){
    //date:2021-9-6 edit:duan reason:0047840:,删除某部门时，转移成员和下级部门时 ，没有排除当前删除的部门
    var popupobj=CrmPopup.getPopupObj('last');
    var delgroupid = ld('#'+popupobj.divid+" [name=delgroupid]").val();
    var urlstring="index.php?module=Users&action=UsersAjax&file=selectlistgroup"+"&delgroupid="+delgroupid;
    
    ld.ajax({
            url: urlstring,
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
                    var Popupobj=CrmPopup.load(data.result.title,"","","LdPopWidth800px","Users","","","","");
                    
                    CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);
                    var divid=Popupobj.divid;
                    var prevpopupobj=CrmPopup.getPopupObj('lastprev');
                    var prevdivid=prevpopupobj.divid;
                   	//unbind 移除原有节点的click点击事件
                	ld('#'+Popupobj.divid+' span').unbind('click').on('click',function(event){
                		var parentid = ld('#'+divid+" [name=old"+field+']').val();
                		var parentgroup = ld(this).attr('parent');
                		var isselect = true;
                		if(!empty(parentgroup) && !empty(parentid)){//不允许选择自己和自己的下级
                			var parentgrouparr = parentgroup.split('::');
                			ld.each(parentgrouparr,function(key,val){
                				if(parentid == val){
                					isselect = false;
                					return true;
                				}
                			})
                		}
                        
                		if(isselect){
                			ld('#'+prevdivid+" input[name="+field+']').val(ld(this).attr('record'));
                			if(ld('#'+prevdivid+" input[name="+field+'_name]').length > 0){
                                ld('#'+prevdivid+" input[name="+field+'_name]').val(ld(this).find('label').html());
                            }
                			if(ld('#'+prevdivid+" div[name="+field+'_name]').length > 0){
                                ld('#'+prevdivid+" div[name="+field+'_name]').html(ld(this).find('label').html());
                            }
                			ld('#'+prevdivid+" input[name="+field+'_no]').val(ld(this).find('input').attr('groupno'));
                			Popupobj.CancelEvent();
                		}
                		return false;
                	});
                  
                }
                else{
                         alert(data.msg);
                    }
            
            }
        });
}

//hzx 20240729 prm部门关联客户  选择客户
Op_UserGroup.groupRelatedAccount=function(){
    showrelatedlist('Users','Accounts','select','','related_crmid');
}

Op_UserGroup.setGroupUser=function(){
    
    var select_id = document.getElementById('allselectedboxes').value;
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
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		if(count - 1 > getMaxMassOperationLimit()) {
			var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
			if(confirm(confirm_str)) {
			} else {
				return false;
			}
		}
	}
    var urlstring1="index.php?module=Users&action=UsersAjax&file=setGroupUser&idlist="+select_id+"&type=popup";

    ld.ajax({
        url: urlstring1,
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
                var popupobj=PopupUserGroup.load(data.result.groupid);
                popupobj.userlist=data.result.userid;
                var listPopupobj = CrmPopup.getlastPopupObjByPageType('listpage');
                if(listPopupobj.user_type){
                    popupobj.user_type = listPopupobj.user_type;
                }
                popupobj.show();
            }
            else
            {
                var confirm_str = data.msg;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }            
        }
    });
}

//选择：审批委托人
function getApproveUser(selected_userid){
    if(empty(selected_userid)){
        var popupobj=CrmPopup.getPopupObj('last');
        var approveby_obj = ld('#'+popupobj.divid+" [name=approveby]");
        selected_userid = approveby_obj.val();
    }
	var scopepopupobj;
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=Users&popup_inputtype=radio&popup_selecttype=user';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'no'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = 'Users';//模块
		   cls_ScopePopup.prop.popup_value = selected_userid;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                // @edit:liushuai,2020-8-4,reason:0042258: （61mis.com/kfbcrm）成员管理新增、编辑界面>选择“审批委托人 ”弹出层：勾选委托人后点击确定没有任何反应。（需要补丁）
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        alert(arrJsPopLabel['PLEASESELECTLESTONEUSER']);return false;
                    }else{
                        //duan 20220811 因为选人控件改成弹出层了，所以要获取前一个弹出层上的字段
                        var popupobj=CrmPopup.getPopupObj('lastprev');
                        
                        var approveby_obj = ld('#'+popupobj.divid+" [name=approveby]");
                        var new_approverid = cls_ScopePopup.return_obj.return_id; //新审批委人id
                        var new_approvername = cls_ScopePopup.return_obj.return_name; //新审批委人姓名
                        //edit:can 2020-09-03042572: （61mis.com/kfbcrm）（王耀文客户问题）成员管理模块编辑界面>启用审批委托：选择审批委托人后点击“保存”按钮，提示“审批委托人不允许为空。”（需要补丁）
                        approveby_obj.val(new_approverid);
						ld('#'+popupobj.divid+" [name=approveby_name]").html(new_approvername);
                        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                        {
                                cls_wxOpenDataobj.bindAllOpenDataByPopupObj(popupobj);
                        }
        
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                        //duan 20220916 设置审批委托人后，提示是否需要更新所有待审批的单据
                        if(popupobj.module == 'Users' && popupobj.record >0 && selected_userid != new_approverid){
                            var old_approverid = approveby_obj.attr('old_approver'); //原审批人委托人id
                            var cur_lastname = ld('#'+popupobj.divid+" [name=last_name]").val(); //当前用户姓名
                            //如果新的审批委托人和旧的不同，且不是正在修改的用户，则提示是否需要更新所有待审批的单据
                            if( old_approverid != new_approverid && popupobj.record != new_approverid){
                                var confirmstr = arrJsPopLabel['RESETAPPROVER'];
                                confirmstr = confirmstr.replace('OLDAPPROVER',cur_lastname);
                                confirmstr = confirmstr.replace('NEWAPPORVER',new_approvername);
                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirmstr);
                                approveby_obj.attr('resetapprover','no');
                                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    				approveby_obj.attr('resetapprover','yes');
                                });
                            }
                        }
                        
                    }
                });
            }
		});
	});
}
function setAllowEdituserfield()
{
    var that=this;
    this.init=function()
    {
        
    }
    this.save=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        var chkobjs=ld("#"+popupobj.divid+" [name=popup_selected_id]");
        var arr=[];
        var allfieldid=[];
        ld.each(chkobjs,function(){
            
            if(ld(this).prop("checked"))
            {
               arr.push(ld(this).val()) ;
            }
            allfieldid.push(ld(this).val());
        })
        ld.ajax({
            url:"index.php?module=Users&action=UsersAjax&file=setAllowEditUserField&save=yes&selfieldids="+arr.join(",")+"&allfieldids="+allfieldid.join(","),
            type:"POST",
            dataType:"JSON",
            timeout:10000,
            success:function(data)
            {
                popupobj.CancelEvent();
            }
        })
    }
    this.save.funname="setAllowEdituserfield.save";
    this.setPopuplayer=function(){
        ld.ajax({
            url:'index.php?module=Users&action=UsersAjax&file=setAllowEditUserField',
            type:"post",
            dataType:"json",
            timeout:10000,
            success:function(data){
                //headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText
                if(data.code==1){
                     var popupobj=CrmPopup.load(data.result.title,that.save,"","LdPopWidth600px","Users","",data.result.oktext,"",data.result.canceltext);
                     popupobj.show(data.result.content);
                     // 设置内容最大高度
                     popupobj.setPopBodyMaxHeight(".divPopOverflow");
                }
                else
                {
                    alert(data.msg);
                }
            }
        })
    }
}
setAllowEdituserfield.getInstance=function(){
    
    var popupobj=CrmPopup.getPopupObj("last");
    if(popupobj.allowedituserfieldobj==undefined)
    {
        popupobj.allowedituserfieldobj=new setAllowEdituserfield();
    }
    return popupobj.allowedituserfieldobj;
}


function CopyUsers(id){
    var objparams=new CreatePagePopup.params();
    objparams.params['isduplicate']='yes';
    CreatePagePopup.showpage('Users',"&record="+id+"&isDuplicate=true",objparams);
}
function cls_Users()
{
    var that=this;
    //ZXM 20220722 同步微信公众号用户
    this.OffiaccountUser = function(){
        // var confirm_str = "正在同步，请不要关闭或者刷新浏览器！";
        // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        ldAjax("index.php?module=Users&action=UsersAjax&file=OffiaccountUserSync","",function(data){
            if(data.code==-1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);return;
            }
            RemindsMsg("","LdPopWidth400px","","yes","yes",'已同步完成！');
        });
        return;
    }
    //ls 2021-12-15 【1002160】企业微信通讯录及部门同步
    this.AddressbookSync = function () {
        //检查admin账号是否绑定企业微信通讯录账号wx_userid
        ldAjax("index.php?module=Users&action=UsersAjax&file=AddressbookSync&mode=check","",function(data){
            if (data.code == 1) {//未绑定
                var popupobj=CrmPopup.load(data.result.title,that.saveAddressbookAdminname,"",'LdPopWidth600px','Users',"",data.result.oktext,"",data.result.canceltext);
                // CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
                popupobj.show(data.result.content);
                // 设置内容最大高度
                popupobj.setPopBodyMaxHeight(".divPopOverflow");
                DelProgressObjs();
            }else if(data.code == 2){//已绑定
                var popupobj=CrmPopup.load(data.result.title,that.nextAgreeRule,"",'LdPopWidth600px','Users',"",data.result.oktext,"",data.result.canceltext);
                popupobj.show(data.result.content);
                // 设置内容最大高度
                popupobj.setPopBodyMaxHeight(".divPopOverflow");
                DelProgressObjs();
            }
            return;
        })
    };
    this.saveAddressbookAdminname = function () {
        var popupobj=CrmPopup.getPopupObj("last");
        var admin_name_obj = CrmPopup.findHtmlobj(popupobj.divid,'admin_name');
        var admin_name = admin_name_obj.val().trim();
        if (empty(admin_name)){
            var confirm_str = admin_name_obj.attr("tag") + arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            DelProgressObjs();
            return false;
        }

        //绑定admin关联账号
        ldAjax("index.php?module=Users&action=UsersAjax&file=AddressbookSync&admin_name="+encodeURIComponent(admin_name),"",function(data){
            if (data.code == 1) {//绑定成功
                CrmPopup.getPopupObj("last").CancelEvent();
                that.AddressbookSync();
            } else if (data.code == -1) {//crm已存在或者企业微信不存在
                RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                DelProgressObjs();
                return false;
            }
        })
    }
    this.saveAddressbookAdminname.funname='saveAddressbookAdminname';

    //同意同步规则后再开始同步
    this.nextAgreeRule = function () {
        var popupobj=CrmPopup.getPopupObj("last");
        var agree_rule = ld("#"+popupobj.divid+" [name=agree_rule]:checked").val();
        if (agree_rule != 'yes'){
            var confirm_str = arrJsPopLabel['AddressbookAgreerule'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);//同步企业微信通讯录组织架构前，您需先同意上述同步规则，否则将无法进行同步操作
            DelProgressObjs();
            return false;
        }else{
            CrmPopup.getPopupObj("last").CancelEvent();
        }

        that.startAddressbookSync();
    }

    this.startAddressbookSync = function () {
        ldAjax("index.php?module=Users&action=UsersAjax&file=AddressbookSync","",function(data){
            if (data.code == '-1'){//没有需要同步的成员时
                RemindsMsg("","LdPopWidth400px",'Users',"yes","",data.msg);
                return false;
            }
            var tmppopupobjobj;
            if(data.result.start == 0)
            {
                tmppopupobjobj=ProgressPopup.load(data.result.title,"","",500,'Users',"","","","");
                tmppopupobjobj.show();
            }
            else{
                tmppopupobjobj=CrmPopup.getPopupObj('last');
            }

            if (data.code == 1) {
                tmppopupobjobj.showhtml("<div style='text-align: center;padding: 10px 10px;'>"+arrJsPopLabel['Synchronizedsuccess']+"</div>");
                CrmPopup.getPopupObj("last").CancelEvent();//关闭进度条
                // getListViewEntries_js(Users,'start=1');//刷新页面
                DelProgressObjs();
                window.location.reload();
            }else if (data.code == 2) { //继续当前请求
                tmppopupobjobj.setPercentWidth(data.result.percent);
                tmppopupobjobj.setTotalNum(data.result.total);
                tmppopupobjobj.setCurNum(data.result.end);
                that.startAddressbookSync();
            }

        })
    }

      this.setLoginControlPopup=function(){
        //登录控制界面
        ldAjax("index.php?module=Users&action=UsersAjax&file=LoginControlPopup",{},function(ajaxdata){
            var popupobj=CrmPopup.load(ajaxdata.result.title,that.savelogincontrol,"",'LdPopWidth600px','Users',"",ajaxdata.result.oktext,"",ajaxdata.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll(popupobj,ajaxdata.result.content);
            // 帮助
            if(ajaxdata.result.helpHtml && ajaxdata.result.helpHtml!=""){
                ld('#'+popupobj.divid + " #" + popupobj.divid + '_head').find('.E_ptita').after(ajaxdata.result.helpHtml);
            }
            var selectsmsobj=ld('#'+popupobj.divid).find("[name=smstemplatelist]");

            if(selectsmsobj.length>0&&selectsmsobj!=undefined) {
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectsmsobj.attr("name"));
                cls_resetComboxHtmlobj.setPopupObj(popupobj);
                cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectsmsobj, 200);
            }

            DelProgressObjs();
        })
        
      }
      this.savelogincontrol=function(){
            //登录控制保存
         var popupobj=CrmPopup.getPopupObj('last');
         var pwdcheckvalue=ld("#"+popupobj.divid+" input[name='pwdcheck']:checked").val();//设置用户的密码是否严格管理
         var checkcodevalue=ld("#"+popupobj.divid+" input[name='checkcode']:checked").val();//设置系统登录时是否启用验证码
         var timelimitvalue=ld("#"+popupobj.divid+" input[name='timelimit']:checked").val();//设置系统登陆时密码连续输错3次后，不允许登陆的限制时长（为空表示不限制时长，允许登陆）
         var timelimittag=ld("#"+popupobj.divid+" input[name='timelimit']:checked").attr("tag");
         if(timelimittag=='custom')
            timelimitvalue=ld("#"+popupobj.divid+" input[name='customminute']").val();

          var smstemplateid = '';
          if (ld("#"+popupobj.divid+" select[name=smstemplatelist]").length>0) {
              smstemplateid = ld("#"+popupobj.divid+" select[name=smstemplatelist]").val();
              if (smstemplateid<1) {
                  MessagePopup.TipZero_warning(arrJsPopLabel['SELECTSMSTEMPLATES']);
                  return false;
              }
          }
          ldAjax("index.php?module=Users&action=UsersAjax&file=LoginControlSave&checkcodevalue="+checkcodevalue+"&customtime="+ld("#"+popupobj.divid+" input[name='customtime']").val()
                ,{'pwdcheckvalue':pwdcheckvalue,'timelimitvalue':timelimitvalue,'timelimittag':timelimittag,'smstemplateid':smstemplateid},function(ajaxdata){
                DelProgressObjs();
               if(ajaxdata.code=='-1')
               {
                    RemindsMsg("","LdPopWidth400px",'Users',"yes","",ajaxdata.msg);
                    
                    return false;
               }
               popupobj.CancelEvent();
            
        });
      }
      that.savelogincontrol.funname='savelogincontrol';
      
      this.UnLockAccountPopup=function(){
         ldAjax("index.php?module=Users&action=UsersAjax&file=UnLockAccountPopup",{},function(ajaxdata){
             var popupobj=CrmPopup.load(ajaxdata.result.title,"","",'LdPopWidth600px','Users',"","","","");
             popupobj.show(ajaxdata.result.content);
             // 设置内容最大高度
             popupobj.setPopBodyMaxHeight(".divPopOverflow");
             DelProgressObjs();
             popupobj.center();
             ld("#"+popupobj.divid+' [name=btn_unlock]').unbind("click").bind("click",function(){
                //解锁
                var userid=ld(this).attr("tag");
                var btnobj=ld(this);
                var trobj=ld(btnobj).parent();
                while(true)
                {
                     if(ld(trobj).prop("tagName").toLowerCase()=='tr')
                     {
                        break;
                     }
                     trobj=ld(trobj).parent();
                }
               // alert(userid);
                ldAjax("index.php?module=Users&action=UsersAjax&file=UnLockAccountOperate",{"userid":userid},function(ajaxdata){
                    MessagePopup.TipOne_success(ajaxdata.msg);
                   // popupobj.CancelEvent();
                   trobj.remove();
                    var tableobj=ld("#"+popupobj.divid+' [name=unlockuser_table]');
                    if(ld(tableobj).find("tr").length<=0)
                        popupobj.CancelEvent();
                    DelProgressObjs();
                })
            });
        })
      }
}
cls_Users.getInstance=function(){
    return new cls_Users();
}

//liushuai 20230523 XUQIU1001175 【百特】员工信息对接(输入账号带出关联信息)
function getRelatedOktaUser(obj,event){
    var searchcontent = event.target.value;
    var regex = /^\d+$/; // 匹配数字的正则表达式
    if (!regex.test(searchcontent) || event.key == 'Process') {//输入拼音及非数字时阻止，因为员工账号都是六位的数字
        return;
    }
    var popupobj=CrmPopup.getPopupObj("last");
    getJsScript('include/js/relatedfield.js',function(){
        getRelatedFieldData(popupobj.module,'1','',ld(obj).attr('name'),popupobj.module,'special_noselect');//selecttype可以是其他字符串,record这里没什么实际意义，纯粹是不能为空
    });

}

//hzx 20240726 XUQIU1001729 经销商用PRM成员管理设置
function getuserlist(user_type){
    var crmPopupobj = CrmPopup.getlastPopupObjByPageType('listpage');

    crmPopupobj.user_type = user_type;

    var surl = "module=Users&action=UsersAjax&file=ListView&start=1&user_type="+user_type;
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
        surl += '&isshowModuleListTree=yes';
    }
    var listview_page=new ListView_Page('Users',surl,"pagecontent1");
    listview_page.callback_fun=function()
    {
        popupobj.listresizeobj.setReiszeTable_Init('Users','ajax');
        setContentHeight('Users');//计算内容高度
        IsFrameElement();
    }
    ld('#rptContentLoading').show();
    listview_page.page();
}