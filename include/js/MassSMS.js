/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

// MassEdit Feature

function Mass_formValidate(){ 
		if(document.forms['sendSMS'] == undefined) return true;
        var allowedit=document.forms['sendSMS'].allowedit.value;
        
        if(allowedit=='yes')
         var phone = document.forms['sendSMS'].receivephone.value;//接收人手机 
       else
       {

            var phone = document.forms['sendSMS'].receivephonehidden.value;
            var s=phone.split("\n");
            phone="";
            for(var i=0;i<s.length;i++)
            {
                var sphone=s[i];
                if(sphone!='')
                {
                  
                    phone+=Base64.decode(sphone)+"\n";
                }
            }
       }
       
    
    if(phone.length==0){ 
        //接收人不能为空！
        var confirm_str = arrJsPopLabel['RECIPIENTCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
    if(!check(phone))
    {
        //请正确录入接收人信息！
        var confirm_str = arrJsPopLabel['PLEASECORRECTRECIPIENTINFO'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
  
    var mobile_regx=/^1[0-9]\d{9}$/;
    document.sendSMS.hidden_toid.value='';
    if(phone!=null){
        if(phone.length>0){
            arr=new Array();
            arr=phone.split("\n");   
            var tem;
            for(var i=0;i<arr.length;i++){
                tem=arr[i];
               
              if(tem !=''){
                    var ret = '';
                    if (tem.indexOf('<')>0)
                    {
                        var num =tem.indexOf("<")
                        ret = trim(tem.substr(0, num));
                    }
                    else
                    {
                        ret = trim(tem);
                        
                    }
                    if(!mobile_regx.test(ret)){
                        var confirm_str = "接收人手机号码有误："+tem;
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
                    else{
                        document.sendSMS.hidden_toid.value=document.sendSMS.hidden_toid.value+trim(arr[i])+',';
                        
                    }
                }
                else if(trim(arr[i]) != "" && !(mobile_regx.test(trim(arr[i]))))
	            {
                        var confirm_str = "接收人手机号码有误: "+arr[i];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
	                    return false;
	            }
                else if(trim(arr[i]) != "" && mobile_regx.test(trim(arr[i]))){
                    document.sendSMS.hidden_toid.value=document.sendSMS.hidden_toid.value+trim(arr[i])+',';
                }
            }
        }
    }
    
	var content = document.forms['sendSMS'].receivecontent.value;//短信内容
    var accountautograph = document.forms['sendSMS'].accountautograph.value;//通讯账户签名 
    if(content.length==0){ 
        //短信内容不能为空！
        var confirm_str = arrJsPopLabel['CONTENTCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
    /*
    //短信类别提醒
    var messcategory = document.forms['sendSMS'].messcategory.value;
    var messArray=new Array("产品","销售","活动","优惠","营销","Product");
    for(var i=0;i<messArray.length;i++){
        if(messcategory != 'yingx'){
            if(content.search(messArray[i]) >=0){
                alert(arrJsPopLabel['CONFIRMMESSCATEGORY']);
                return false;
            }
        }
    }
    */
    var accountid = document.forms['sendSMS'].accountid.value;//通讯账户ID
    if(accountid.length==0){ 
        //没有设置通讯账户，请使用管理员用户到控制面板中设置！
        var confirm_str = arrJsPopLabel['COMMUNICATIONSACCOUNTNOTSET'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
    var accountflag = document.forms['sendSMS'].accountflag.value;//通讯账户是否停用    
    if(accountflag==0){ 
        //通讯账户已停用，发送失败！
        var confirm_str = arrJsPopLabel['COMMACOUNTDISABLED'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
    
    var accountbalance = document.forms['sendSMS'].accountbalance.value;//通讯账户余额 
    if(phone!=null){
        if(phone.length>0){
            arr=new Array();
            arr=phone.split("\n"); 
            var arrcount = arr.length-1;
            if(arrcount>accountbalance*10)
            {
                //账户余额不足，发送失败！
                var confirm_str = arrJsPopLabel['ACCOUNTBALANCEINSUFFICIENTFAILED'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false; 
            }
        }
    }

    puyoungJS_DialogBox.block();
    marketing_check();    
    
}
/**
更新操作
edit：cdw
date：20131205
reason：营销分组选择，替换通配符{name}{commname}{app}
**/
function replace_wildcard()
{
    //获取所有的选择的客户id
    var accountid = document.getElementById('accountid_chose').value;
    //获取所有的选择的条目
    var num_rows = document.getElementById("row_of_checkbox_account").value;
        var tabid_fieldlabel ="";
        for(var i=0;i<num_rows;i++)
        {   
            var id = i+'_checkbox_MassSMS_SMS';
            var id_check = document.getElementById(id);
            //选中的项目进行处理
            if(id_check.checked==true)
            {
                var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
            }       
        }
        //赋值到对应的hidden，用来获取list
        document.getElementById('account_wildcard_id').value = accountid;
        document.getElementById('account_wildcard_tabid_fieldlabel').value = tabid_fieldlabel;
}
function replace_wildcard_contact_btn_MassSMS()
{
  var contactid = document.getElementById('contactid').value;
    
    //获取所有的弹出框里选择的条目
    var num_rows = document.getElementById("row_of_checkbox_contact_pop").value;
    var tabid_fieldlabel ="";
    for(var i=0;i<num_rows;i++)
    {   
        var id = i+'_checkbox_pop_sms';
        var id_check = document.getElementById(id);
        //选中的项目进行处理
        if(id_check.checked==true)
        {
            var tabid_fieldlabel = tabid_fieldlabel + document.getElementById(id).value+"_";
        }       
    } 
     document.getElementById('contact_btn_MassSMS_wildcard_id').value = accountid;
     document.getElementById('contact_btn_MassSMS_wildcard_tabid_fieldlabel').value = tabid_fieldlabel; 
}

function marketing_check() {
    var oform = window.document.sendSMS;
    var str = charEscape(oform.receivephone.value);
    oform.receivephone.value=str;
    oform.action.value='MassSMSAjax';
	oform.submit();
    return;

}
function set_return_groupmasssms(entityid,parentname,mobile){
    if(parentname!=''){
        var parr=parentname.split(",");
        var marr=mobile.split(",");
    }
    var pn="";
    var mb="";
    for(var i=0;i<parr.length;i++){
        pn =parr[i];
        mb=marr[i];
        if(pn!='')
        window.opener.document.sendSMS.parent_name.value = window.opener.document.sendSMS.parent_name.value+trim(mb)+'<'+trim(pn)+'>\r\n';
    }
	window.opener.document.sendSMS.hidden_toid.value = mobile+','+window.opener.document.sendSMS.hidden_toid.value;
	window.close();
    //return false;
}
//判断字符中是否包含有特殊字符：
function  check(title){        
 var reg = /^[^@\/\'\\\"#$%&()（）？：；《》\^\*]+$/;
 if(reg.test(title)) return true; 
 return false; 
}
//判断字符中是否包含有特殊字符：
function  checkconect(title){        
 var reg = /^[^@\/\'\\\"#%&<>()（）《》\^\*]+$/;
 if(reg.test(title)) return true; 
 return false; 
}


function validate(obj){
    if(obj.sms_username.value==""){
        //用户名不能为空！
        var confirm_str = 'SDK AppID' + arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    if(obj.sms_password.value==""){
        //密码不能为空！
        var confirm_str = 'App Key'+arrJsPopLabel['CANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	if(obj.sms_autograph != undefined){
		var sms_autograph = obj.sms_autograph.getAttribute('tag');
		if(obj.sms_autograph.value == ""){
			var confirm_str = sms_autograph+arrJsPopLabel['CANOTEMPTY'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
	}
    return true;
}

function addTxtPhone()
{
    var receivefile = document.forms['sendSMS'].receivefile.value;//txt地址
    if(receivefile.length==0){ 
        //没有选择所需要导入的txt文件！
        var confirm_str = arrJsPopLabel['TXTFILENOTCHOOSEIMPORT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
    var extensions  = receivefile.substr(receivefile.length-4, 4); 
    if(extensions!='.txt')
    {
        //只能读取后缀名为txt的文件！
        var confirm_str = arrJsPopLabel['TXTFILENAMESUFFIXCANONLYREAD'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false; 
    }
    var oform = window.document.sendSMS;
    oform.action.value='SendView';
    oform.type.value = 'add';    
				oform.submit();
                return;
    

}

function addSMSTemplate(accountautograph)
{    
    var receivetem = document.forms['sendSMS'].receivetem.value;//短信模板
    if(receivetem=='-1')
    {
        //请选择短信模板！
        var confirm_str = arrJsPopLabel['SELECTSMSTEMPLATES'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            SMSTemplateAdd(accountautograph,receivetem);
        });
    }
        return false;
}

function SMSTemplateAdd(accountautograph,receivetem){
    new Ajax.Request(
        'index.php',
            {queue: {position: 'end', scope: 'command'},
                method: 'post',
                    postBody:"module=MassSMS&action=SendView&ajax=true&type=addtem&receivetem="+receivetem,
        onComplete: function(response) {
         if(response.responseText.indexOf('#####')>-1){
             var result=response.responseText.split('#####');
             document.forms['sendSMS'].receivecontent.value = HTMLDecode(result[1]);
         }
             countChar('receivecontent','now_counter','signature_counter','all_counter',accountautograph);
        }
        
        //countChar('receivecontent','now_counter','signature_counter','all_counter','{$accountautograph}');
        }
    );
}
/**
 * html代码反转
 * @reason 0012884: 群发短信界面：选择短信模板后，如果短信模板内容中有引号时，带过来的短信内容中引号显示的为代码：“"
 * @param String text
 * @returns 转换后的html字符串
 * @author Tujt 2014-12-09
 */
function HTMLDecode(text){
    var temp = document.createElement("div");   
    temp.innerHTML = text;   
    var output = temp.innerText || temp.textContent;   
    temp = null;   
    return output;   
} 