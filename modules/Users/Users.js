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

document.write("<script type='text/javascript' src='include/js/Mail.js'></"+"script>");
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
			document.getElementById('approveby_name').value = '';
			if(document.getElementById('approveby_img') != undefined){
				document.getElementById('approveby_img').style.display='none';
			}
		}
	}else{
		if(document.getElementById('approveby_img') != undefined){
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

function deleteUser(obj,userid,BLOCKIDSETTING,FIELDIDSETTING)
{
	if(ld('#ListViewContents tr').hasClass('selectedbj')){
        ld('#ListViewContents tr').removeClass('selectedbj');
    }
	 //设置当前字段所在为黄色
    ld('input[name=userlistview'+userid+']').parent().parent().addClass('selectedbj');
	$("status").style.display="inline";
	new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
					method: 'post',
					postBody: 'action=UsersAjax&file=UserDeleteStep1&return_action=ListView&return_module=Users&module=Users&parenttab=Settings&record='+userid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
					onComplete: function(response) {
							$("status").style.display="none";
							$("tempdiv").innerHTML= response.responseText;
			                 fnvshobj(obj,"tempdiv");
					}
			}
	);
}
function transferUser(del_userid,BLOCKIDSETTING,FIELDIDSETTING)
{
        $("status").style.display="inline";
        $("DeleteLay").style.display="none";
        //var trans_userid=$('transfer_user_id').options[$('transfer_user_id').options.selectedIndex].value;
        var trans_userid=document.getElementById('selectuserid').value;
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Users&action=UsersAjax&file=DeleteUser&ajax=true&delete_user_id='+del_userid+'&transfer_user_id='+trans_userid+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
                        onComplete: function(response) {
                                lingdangJS_DialogBox.unblock();
                                $("status").style.display="none";
                                //$("ListViewContents").innerHTML= response.responseText;
                                //	0026359: 控制面板>用户管理：输入查找条件筛选出单据，删除一条后刷出了所有单据
                                if(user_pagetype=='list')
                                  {
                                      var pagenum=ld("#ListViewContents [name=pagenum]").val();
                                   getListViewEntries_js('Users','parenttab=Tools&start='+pagenum);
                                  }
                                  else
                                  {
                                    window.location.href="index.php?module=Users&action=index&parenttab=&blockidsetting=&fieldidsetting=&query_session=1;";
                                    
                                  }
                        }
                }
        );

}

 function selectdelectid(selectView){
    var viewid =  encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);
    document.getElementById("selectuserid").value=viewid;
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
                                '<td align="right" width="60%" class="DetailedTd1Label">'+arrJsPopLabel['Allowtoviewotherusers']+'</td>'+'<td><input name="viewothers" id="viewothers" type="checkbox" tabindex="" style="margin-right:5px;"><font class="greyFont">'
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

	if (trim(form.new_password.value) == "") {
        var confirm_str = arrJsPopLabel['ENTERNEWPASSWORD'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
	if (trim(form.confirm_new_password.value) == "") {
        var confirm_str = arrJsPopLabel['ENTERNEWPASSWORDAGAIN'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}

  //  var formname=document.forms['ChangePassword'];
	if (trim(form.new_password.value) == trim(form.confirm_new_password.value)) {
	   
          
		//if (form.is_admin.value == 1) document.DetailView.old_password.value = form.old_password.value;
	//	document.DetailView.new_password.value = form.new_password.value;
	//	document.DetailView.return_module.value = 'Users';
	//	document.DetailView.return_action.value = 'DetailView';
	//	document.DetailView.changepassword.value = 'true';
	//	document.DetailView.return_id.value =document.DetailView.record.value;
	//	document.DetailView.action.value = 'Save';
		//document.DetailView.submit();
        var old_pwd=document.getElementById("old_password").value;
        var new_pwd=document.getElementById("new_password").value;
        var confirm_new_password=document.getElementById("confirm_new_password").value;
      
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Users&action=UsersAjax&file=SavePwd&oldpwd='+old_pwd+'&newpwd='+new_pwd+'&confirmpwd='+confirm_new_password+'&userid='+recordid,
                        onComplete: function(response) {
							if(response.responseText.indexOf('SUCCESS') > -1)
							{
						         /* if(recordid>0)
                                  {
                                    document.EditView.submit();
                                  }
								*/
                                window.location.reload();
                                return true;
							}
			       				else {
			       					lingdangJS_DialogBox.unblock();
                                    var results=response.responseText.split('$$error$$');
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",results[1]);
                                    return false;
						        }
			            }
                }
        );

		return true;
       
	}
	else {
        var confirm_str = arrJsPopLabel['PASSWORDINCONSISTENT'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
}


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
			       					lingdangJS_DialogBox.unblock();
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",response.responseText);
                                    return false;
						        }
			            }
                }
        );

}
function check_duplicate()
{
	var user_name = window.document.EditView.user_name.value;
	if(user_name == '')
	{
		lingdangJS_DialogBox.unblock();
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
        			       					lingdangJS_DialogBox.unblock();
                                            if(response.responseText.indexOf('用户账户已经存在！') > -1)
                                            {
                                                var confirm_str = arrJsPopLabel['USERACCOUNTEXISTS'];
                                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            }
                                            else
                                            {
                                                var confirm_str = response.responseText;
                                                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                            }
        						        }
        			            }
                        }
                );
	}
	else
     {
                var confirm_str = arrJsPopLabel['ACCOUNTBYTO'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                //lingdangJS_DialogBox.unblock();
     }
}


function set_fieldfocus(errorMessage,oMiss_field){
		alert(arrJsPopLabel['ERR_MISSING_REQUIRED_FIELDS']);
		oMiss_field.focus();	
}

function verify_data(form) {
     //lingdangJS_DialogBox.block();
     if((form.find("[name=approveby]").length>0&&form.find("[name=approveby]").val()=='')&&(form.find("[name=approvestatus]").length>0&&form.find("[name=approvestatus]").val()==0))
     {
        var confirm_str = arrJsPopLabel['APPROVINGCLIENTCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
       // lingdangJS_DialogBox.unblock();
        return false;
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
	    lingdangJS_DialogBox.unblock();
		set_fieldfocus(errorMessage,oField_miss);
		return false;
	}
	if( form.find("[name=email1]").length>0){
		form.find("[name=email1]").val(trim(form.find("[name=email1]").val())) ;
		if (form.find("[name=email1]").val() != "" && !/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/.test(form.find("[name=email1]").val())) {
            var confirm_str = "$the_emailid"+form.find("[name=email1]").val()+"$email_field_is";
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			 //lingdangJS_DialogBox.unblock();
			form.find("[name=email1]").val().focus();
		   
			return false;
		}
	}
	if(form.find("[name=email2]").length>0){
		form.find("[name=email2]").val(trim(form.find("[name=email2]").val())) ;
		if (form.find("[name=email2]").val()!= "" && !/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/.test(form.find("[name=email2]").val())) {
            var confirm_str = "$the_emailid"+form.find("[name=email2]").val()+"$other_email_field_is";
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			form.find("[name=email2]").focus();
			return false;
		}
	}


    if(form.find("[name=imagename]").length>0){//Liver bug0027411: 控制面板>用户管理：隐藏用户头像字段，用户管理编辑无法保存。
       	if(! upload_filter("imagename", "jpg|gif|bmp|png|JPG|GIF|BMP|PNG") )
    	{
    	    lingdangJS_DialogBox.unblock();
    		form.find("[name=imagename]").focus();
    		return false;
    	} 
    }


	if(form.find("[name=mode]").val()!= 'edit')
	{
		if(trim(form.find("[name=user_password]").val()) != trim(form.find("[name=confirm_password]").val()))
		{
			//lingdangJS_DialogBox.unblock();
            var confirm_str = arrJsPopLabel['THE_PASSWORD'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		
	}
	/**
	edit:can
	reason:12954,新增用户时，超过最大许多用户数时，程序没有判断，直接保存成功
	**/
	check_duplicate();
 
    return true;    
}

function Op_UserGroup (htmlobj)
{
     
     
     this.mode="";//编辑edit，新增create，删除del
    this.htmlobj=htmlobj;
     this.parentgrouphtmlobj=htmlobj;
     this.recordhtmlobj=htmlobj;
    
     if(Op_UserGroup.curr_group_obj!=undefined&&Op_UserGroup.curr_group_obj!="")
     {
        Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").css("color","#475059");
        Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").css('font-weight',"normal");
     }
     this.recordhtmlobj.find("label").css("color","#2a6496");
	 this.recordhtmlobj.find("label").css("font-weight","bold");
      while(this.recordhtmlobj.prop("tagName")!=undefined&&this.recordhtmlobj.prop("tagName").toLowerCase()!="span")
      {
        this.recordhtmlobj=this.recordhtmlobj.parent();
      }
    
      this.records=this.recordhtmlobj.attr("record").split("_");
      this.record=this.records[1];//获取部门ID
     while(this.parentgrouphtmlobj.prop("tagName")!=undefined&&this.parentgrouphtmlobj.prop("tagName").toLowerCase()!="li")
     {
        this.parentgrouphtmlobj=this.parentgrouphtmlobj.parent();
     }
     
   Op_UserGroup.curr_group_obj=this;
   
}

Op_UserGroup.curr_group_obj="";
Op_UserGroup.EditGroup=function()
{
    var module="Users";
    var urlstring="index.php?module=Users&action=UsersAjax&file=getUserGroup&record="+Op_UserGroup.curr_group_obj.record;
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
                    var Popupobj=CrmPopup.load(data.result.title,Op_UserGroup.save,"","LdPopWidth700px",module,"",data.result.oktext,"",data.result.canceltext);
                    
                    Popupobj.show(data.result.content);
                   Op_UserGroup.curr_group_obj.mode='edit';
                   ld('#'+Popupobj.divid+' a[tag=clearselectgroup]').on('click',function(){
                    	 ld('#'+Popupobj.divid+" input[name=parentid]").val('');
	                       ld('#'+Popupobj.divid+" input[name=parentid_name]").val('');
                  	});
    
                   
                    return Popupobj;
                }
            
            }
        });
}
Op_UserGroup.AddGroup=function()
    {
            var module="Users";
            var urlstring="index.php?module=Users&action=UsersAjax&file=getUserGroup&parentid="+Op_UserGroup.curr_group_obj.record;
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
                    var Popupobj=CrmPopup.load(data.result.title,Op_UserGroup.save,"","LdPopWidth700px",module,"",data.result.oktext,"",data.result.canceltext);
                    Popupobj.show(data.result.content);
                    Op_UserGroup.curr_group_obj.mode='create';
                  
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
               ld("#viewuserlist span[tag=user_group]").unbind("click").on("click",function(event){
                 
                    var parentliobj=ld(this).parent();
                    if(ld.inArray(ld(this).attr("record"), Op_UserGroup.nodecount)<0&&Op_UserGroup.nodecount[0]!="")
                    {
                        Op_UserGroup.nodecount=[];
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
                  var parentliobj=ld(this).parent();
                 
                  var nowdepth=ld(this).attr("depth");
                  if(ld(this).attr("class").indexOf("group_node_collapse")>=0)//如果是收缩
                  {
                   // ld(this).html("展开");
                    parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','none');
                    ld(this).attr("class","group_node_expand");
                    ld(this).addClass("tree-right");
                  }
                  else //如果是展开
                  {
                       // ld(this).html("收缩");
                      parentliobj.find("ul[depth='"+(nowdepth)+"']").css('display','block');
                      ld(this).attr("class","group_node_collapse");
                      ld(this).addClass("tree-down");
                  }
                   Op_UserGroup.CreateObj(ld(this).next());  
                    showDefaultCustomView(Op_UserGroup.listparams['CustomViewObj'],"Users","",Op_UserGroup.listparams['viewid']);                   
                  
      });
        
    }
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
            Op_UserGroup.listfirst++;
    }
}
Op_UserGroup.CreateObj=function(obj)
{
    
    var groupobj=new Op_UserGroup(obj);
    return groupobj;
}
/**
删除部门
**/
Op_UserGroup.deleteGroup=function(){
    
     var module="Users";
            var urlstring="index.php?module=Users&action=UsersAjax&file=DeleteGroup&record="+Op_UserGroup.curr_group_obj.record;
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
                     
                    var Popupobj=CrmPopup.load(data.result.title,Op_UserGroup.save,"","LdPopWidth700px",module,"",data.result.oktext,"",data.result.canceltext);
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
Op_UserGroup.save=function()
{
  
     var popupobj=CrmPopup.getPopupObj("last");
      var urlstring="index.php?module=Users&action=UsersAjax&file=SaveGroup";
     if(popupobj!=undefined)
    {
         var groupname=CrmPopup.getHtmlobjval(popupobj.divid,"groupname");
  
         var parentid=CrmPopup.getHtmlobjval(popupobj.divid,"parentid");
         urlstring+="&groupname="+encodeURIComponent(groupname);
   
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
         if(Op_UserGroup.curr_group_obj.record != USER_GROUP_LIST_ID)
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
     else if(Op_UserGroup.curr_group_obj.mode=='create')
     {
        urlstring+="&description="+encodeURIComponent(CrmPopup.getHtmlobjval(popupobj.divid,"description"));
         urlstring+="&parentid="+Op_UserGroup.curr_group_obj.record;
          if(groupname=='')
         {
            var confirm_str = arrJsPopLabel['GROUPNAME']+arrJsPopLabel['CANOTEMPTY'];//部门名称不能为空
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
                    var nextobj=Op_UserGroup.curr_group_obj.recordhtmlobj.next();
                    var groupname=data.result.groupname;
                    var groupid=data.result.groupid;
                    if(Op_UserGroup.curr_group_obj.mode=='create')
                    {
                         if(nextobj&&nextobj.length>0)
                        {
                          
                            nextobj.append('<li> <span group_margin_right="'+(parseInt(Op_UserGroup.nowdepth)+1)+'" style="margin-right:15px"></span><span class="file" tag="user_group" depth="'+(parseInt(Op_UserGroup.nowdepth)+1)+'" record="group_'+groupid+'_1" ><label>'+groupname+'</label> </span></li>');
                        }
                        else
                        {
                           
                            var parentli=Op_UserGroup.curr_group_obj.recordhtmlobj.parent();
                             var depth=parseInt(Op_UserGroup.nowdepth);
                             Op_UserGroup.curr_group_obj.recordhtmlobj.prev().remove();
                             parentli.prepend("<span class='group_node_collapse tree-down' depth='"+depth+"'  name='group_expand_collapse'></span>");//收缩
                             parentli.append('<ul depth="'+(parseInt(Op_UserGroup.nowdepth)+1)+'"><li> <span style="margin-right:15px"></span><span class="file" tag="user_group" depth="'+(parseInt(Op_UserGroup.nowdepth)+1)+'" record="group_'+groupid+'_1" ><label>'+groupname+'</label> </span></li></ul>');
                        } 
                        
                        Op_UserGroup.setEvent();
                       //设置当前选中的节点为当前新增的节点
                      
                      // Op_UserGroup.nowdepth=parseInt(Op_UserGroup.nowdepth)+1;
                       ld("#viewuserlist span[record='group_"+groupid+"_1']").click();
                       //Op_UserGroup.CreateObj(ld("#viewuserlist span[record='group_"+groupid+"_1']"));        
                              
                    }
                    else if(Op_UserGroup.curr_group_obj.mode=='delete')
                    {
                        
                         var parentul=Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent();//获取span所在ul,获取选择的节点的所在上级节点
                         var nextul= Op_UserGroup.curr_group_obj.recordhtmlobj.next();//获取删除节点的子节点
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
                                     var minusdepth=parseInt(todepth)-parseInt(Op_UserGroup.nowdepth);
                                     //重新给删除节点的子节点的depth属性重新赋值
                                     if(childspan!=undefined)
                                      {
                                        childspan.each(function(){
                                             var childspandepth=parseInt(ld(this).attr("depth"));
                                             
                                             ld(this).attr("depth",childspandepth+minusdepth);
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
                                       
                                     var nextobj=ld(this).next();
                                    
                                      if(nextobj!=undefined&&nextobj.length>0)
                                      {
                                        nextobj.append(nextulhtml);
                                      }
                                      else
                                      {
                                       
                                        ld(this).parent().find("[group_margin_right='"+todepth+"']").remove();
                                        ld(this).parent().prepend('<span name="group_expand_collapse" depth="'+todepth+'" class="group_node_collapse tree-down"></span>');
                                       
                                        ld(this).parent().append('<ul depth="'+todepth+'">'+nextulhtml+'</ul>');
                                      }
                                      tmpparentobj=ld(this);
                                       
                                 }
                            });
                         }
                         
                          Op_UserGroup.curr_group_obj.recordhtmlobj.parent().remove();//获取span所在li，删除所选节点
                         if(parentul.find("span")==undefined||parentul.find("span").length<=0)
                            {
                                //如果选择的删除节点的上级节点没有子节点，则删除展开收缩
                                var tmpdepth=parseInt(Op_UserGroup.curr_group_obj.recordhtmlobj.attr("depth"))-1;//得到上级节点的depth
                                parentul.parent().prepend('<span group_margin_right="'+tmpdepth+'" style="margin-right:15px">');
                                parentul.parent().find("span[name=group_expand_collapse]").remove();
                                
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
                         if(data.result.grouptreehtml!="")
                         {
                             var parentli=Op_UserGroup.curr_group_obj.recordhtmlobj.parent();
                             var parentul=Op_UserGroup.curr_group_obj.recordhtmlobj.parent().parent();//获取span所在ul,获取选择的节点的所在上级节点
                             var childspan=parentli.find("span[tag=user_group]");//获取子节点中所有span元素
                             var childul=parentli.find("ul");//获取子节点中所有ul元素
                             var expandcollapsespan=parentli.find("span[name=group_expand_collapse]");//获取子节点中所有展开收缩元素
                            var tmpparentobj="";
                            ld("#viewuserlist span[tag=user_group]").each(function(){
                                 var records=ld(this).attr("record").split("_");
                                 if(records[1]==data.result.parentid)
                                 {
                                    
                                      var todepth=ld(this).attr("depth");
                                      tmpparentobj=ld(this);
                                     var minusdepth=parseInt(todepth)-parseInt(Op_UserGroup.nowdepth)+1;
                                     
                                      //重新给删除节点的子节点的depth属性重新赋值
                                     if(childspan!=undefined)
                                      {
                                        childspan.each(function(){
                                             var childspandepth=parseInt(ld(this).attr("depth"));
                                             
                                             ld(this).attr("depth",childspandepth+minusdepth);
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
                                      
                                     var nextobj=ld(this).next();
                                      if(nextobj!=undefined&&nextobj.length>0)
                                      {
                                        nextobj.append("<li>"+parentli.html()+"</li>");
                                      }
                                      else
                                      {
                                        
                                        
                                        ld(this).parent().find("[group_margin_right='"+todepth+"']").remove();
                                         ld(this).parent().prepend("<span class='group_node_collapse tree-down' depth='"+parseInt(ld(this).attr("depth"))+"'  name='group_expand_collapse'></span>");
                                        ld(this).parent().append('<ul depth="'+todepth+'"><li>'+parentli.html()+'</li></ul>');
                                      }
                                 }
                            });
                            Op_UserGroup.curr_group_obj.recordhtmlobj.parent().remove();
                             var editnoderecord=Op_UserGroup.curr_group_obj.recordhtmlobj.attr("record");
                            Op_UserGroup.setEvent();
                            
                           Op_UserGroup.expandAllParent(ld("#viewuserlist span[record='"+editnoderecord+"']"));
                           ld("#viewuserlist span[record='"+editnoderecord+"']").click();
                           Op_UserGroup.expandAllParent(tmpparentobj);//把上级节点全部展开
                         }
                         else
                         {
                             Op_UserGroup.curr_group_obj.recordhtmlobj.find("label").html(groupname);
                         }
                         
                        
                    }
                    popupobj.CancelEvent();
                }
            
            }
        });
}
Op_UserGroup.save.funname="Op_UserGroup_save";

ld(function(){
    Op_UserGroup.setEvent();
    Op_UserGroup.init();
});
Op_UserGroup.expandAllParent=function(obj)
{
    
     if(obj==""||obj==undefined)
     {
        ld("#viewuserlist span[depth=0]").click();
        //删除无节点的部门，则obj为空
        return ;
     }
    if(obj.next()!=undefined&&obj.next().length>0)
    {
        obj.next().css("display","block");
    }
    if(obj.prev()!=undefined&&obj.prev().length>0)
      {
        if(obj.prev().hasClass("group_node_expand"))
        {
              obj.prev().attr("class","group_node_collapse");
                obj.prev().addClass("tree-down");
        }
        
      }
  //  obj.prev().html("收缩");
    var parentobj=obj;
   
    while(parentobj!=undefined&&parentobj.length>0&&parseInt(parentobj.attr("depth"))>=0)
    {
       
        parentobj=parentobj.parent().parent();//获取上级节点(ul);
        parentobj.css("display","block");
        parentobj.prev().prev().attr("class","group_node_collapse");
        parentobj.prev().prev().addClass('tree-down');
          
    }
 
}
function selectGroup(field){

     var urlstring="index.php?module=Users&action=UsersAjax&file=selectlistgroup";
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
                    var Popupobj=CrmPopup.load(data.result.title,"","","LdPopWidth700px","Users","","","","");
                    Popupobj.createScrollDiv();
                    Popupobj.show(data.result.content);
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
                			ld('#'+prevdivid+" input[name="+field+'_name]').val(ld(this).find('label').html());
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
                    popupobj.show();
                  
                }
                else{
                        var confirm_str = data.msg;
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    }
            
            }
        });
        
        
}

//选择：审批委托人
function getApproveUser(selected_userid){
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
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        alert(arrJsPopLabel['PLEASESELECTLESTONEUSER']);return false;
                    }else{
						ld('#approveby').val(cls_ScopePopup.return_obj.return_id);
						ld('#approveby_name').val(cls_ScopePopup.return_obj.return_name);
						ld('.D_pbtn .D_pbtncancel').click();
                    }
                });
            }
		});
	});
}