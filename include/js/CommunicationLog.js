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

function formSmslistLog()
{
    var receiveContacts = document.forms['smslistLog'].receiveContacts.value;//接收名称  
    if(receiveContacts.length>0){ 
        if(!check(receiveContacts))
        {
            //请正确录入接收名称！
            var confirm_str = arrJsPopLabel['PLEASECORRECTRECEIVESNAME'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    var calledNumber = document.forms['smslistLog'].calledNumber.value;//接收号码    
    if(calledNumber.length>0){ 
        if(!check(calledNumber))
        {
            //请正确录入接收号码！
            var confirm_str = arrJsPopLabel['PLEASECORRECTRECEIVEDNUMBER'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    var smsContent = document.forms['smslistLog'].smsContent.value;//内容
    if(smsContent.length>0){ 
        if(!check(smsContent)){
    
            //请正确录入内容！
            var confirm_str = arrJsPopLabel['PLEASECORRECTCONTENT'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    /**
     * @edit:ls
     * @date:2020-7-9
     * @reason:0041854: （https://61mis.com/kfbtest/ [^]）短信记录，选择发件人点击【查找】，界面跳转到首页界面
     * @description:原来input框改为div了，所以取name值得方法不适用于取div。
     */
    var operator = ld("#operator").text();//员工
    if(operator.length>0){ 
        if(!check(operator))
        {
            //请正确录入员工！
            var confirm_str = arrJsPopLabel['PLEASECORRECTSTAFF'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }

    var smsResultName = document.forms['smslistLog'].smsResultName.value;//状态
    if(smsResultName.length>0){ 
        if(!check(smsResultName))
        {
            //请正确录入状态！
            var confirm_str = arrJsPopLabel['PLEASECORRECTSTATE'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    var typename = document.forms['smslistLog'].typename.value;//类别    
    if(typename.length>0){ 
        if(!check(typename))
        {
            //请正确录入类别！
            var confirm_str = arrJsPopLabel['PLEASECORRECTCATEGORY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    var begin_createdate = document.forms['smslistLog'].begin_createdate.value;//开始时间    
    var end_createdate = document.forms['smslistLog'].end_createdate.value;//结束时间
    if(begin_createdate.length>0&&end_createdate.length>0)
    {
        
        if(begin_createdate>end_createdate) 
        {
            //请正确输入时间范围！
            var confirm_str = arrJsPopLabel['PLEASECORRECTTIME'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    else if(begin_createdate.length>0&&end_createdate.length==0)
    {
        //请正确输入时间范围！
        var confirm_str = arrJsPopLabel['PLEASECORRECTTIME'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false; 
    }
    else if(begin_createdate.length==0&&end_createdate.length>0)
    {
        //请正确输入时间范围！
        var confirm_str = arrJsPopLabel['PLEASECORRECTTIME'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false; 
    }
    var urlstring="&receiveContacts="+encodeURIComponent(receiveContacts)+"&calledNumber="+encodeURIComponent(calledNumber);
    urlstring+="&smsContent="+encodeURIComponent(smsContent)+"&operator="+encodeURIComponent(operator)+"&smsResultName="+encodeURIComponent(smsResultName);
    urlstring+="&typename="+encodeURIComponent(typename)+"&begin_createdate="+begin_createdate+"&end_createdate="+end_createdate;
    urlstring+="&start="+ld("input[name=pagenum]").val();
    urlstring+="&BatchIdAll="+document.getElementById("BatchIdAll").value ;//删除短信记录
    ld.ajax({
        url:"index.php?module=CommunicationLog&action=CommunicationLogAjax&file=smslist&ajax=yes"+urlstring,
        type:"post",
        timeout:20000,
        dataType:"json",
        success:function(data)
        {
            ld("#communcationlog_checksms").html(data.result.content);
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                     //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
            //wsh BUG20240726-36 2024-08-05
            tooltip(ld("#communcationlog_checksms").find("[name=failed_tips]"), {transition: true, time: 200});
        }
    })
    return false;
}

function formSmsworkLog()
{
    var urlstring="";
     urlstring+="&BatchIdAll="+document.getElementById("BatchIdAll").value ;//删除短信记录
    if(document.forms['smsworkLog'].subject!=undefined)
    {
        var subject = document.forms['smsworkLog'].subject.value;//主题 
        urlstring+="&subject="+encodeURIComponent(subject);  
        if(subject.length>0)
        { 
            if(!check(subject))
            {
                //请正确录入主题！
                var confirm_str = arrJsPopLabel['PLEASECORRECTTHEMES'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false; 
            }
        }
    }

    //@edit:liushuai,2020-12-21,reason 0043108: 营销-短信记录-短信批次查询；输入发件人后，点击右上角查找按钮没有反应。
    var operator = ld("#smsworkLog [name=operator]").text();
    urlstring+="&operator="+encodeURIComponent(operator);//发送人
    if(operator.length>0)
    {
        if(!check(operator))
        {
            //请正确录入发送人！
            var confirm_str = arrJsPopLabel['PLEASECORRECTSENDER'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    }
    if(document.forms['smsworkLog'].typename!=undefined)
    {
        var typename = document.forms['smsworkLog'].typename.value;//类别  
        urlstring+="&typename="+encodeURIComponent(typename);
        if(typename.length>0)
        { 
            if(!check(typename))
            {
                //请正确录入类别！
                var confirm_str = arrJsPopLabel['PLEASECORRECTCATEGORY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false; 
            }
        }
    }   
    var begin_createdate = document.forms['smsworkLog'].begin_createdate.value;//开始时间    
    var end_createdate = document.forms['smsworkLog'].end_createdate.value;//结束时间
    if(begin_createdate.length>0&&end_createdate.length>0)
    {
        
        if(begin_createdate>end_createdate) 
        {
            //请正确输入时间范围！
            var confirm_str = arrJsPopLabel['PLEASECORRECTTIME'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false; 
        }
    }
    else if(begin_createdate.length>0&&end_createdate.length==0)
    {
        //请正确输入时间范围！
        var confirm_str = arrJsPopLabel['PLEASECORRECTTIME'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false; 
    }
    else if(begin_createdate.length==0&&end_createdate.length>0)
    {
        //请正确输入时间范围！
        var confirm_str = arrJsPopLabel['PLEASECORRECTTIME'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false; 
    }  
    
    
    urlstring+="&begin_createdate="+begin_createdate+"&end_createdate="+end_createdate;
    urlstring+="&start="+ld("input[name=pagenum]").val();
    ld.ajax({
        url:"index.php?module=CommunicationLog&action=CommunicationLogAjax&file=smswork&ajax=yes"+urlstring,
        type:"post",
        timeout:20000,
        dataType:"json",
        success:function(data)
        {
            ld("#communcationlog_checksms").html(data.result.content);
            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                     //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
            
        }
    })
    return false;
}

function smslistRadionCheck(){  
    if(document.forms['smslistLog'].priorityNormal.checked)
    {
        document.forms['smslistLog'].prioritysms.value = "0";
    }
    else
    {
        document.forms['smslistLog'].prioritysms.value = "1";
    }
}  
function smsworkRadionCheck(){  
    if(document.forms['smsworkLog'].priorityNormal.checked)
    {
        document.forms['smsworkLog'].prioritysms.value = "0";
    }
    else
    {
        document.forms['smsworkLog'].prioritysms.value = "1";
    }
} 
/*
edit:cdw
date:20130723
reason:短信作业查询、短信清单查询点击界面上的 清空，弹出的提示信息：确定要删除吗？ 应该改成：确定要清空吗？
*/

function delCommunicationLog(type){

    if(type=='smslist')
    {
        javascript:DeleteAllCommunication('index.php?module=CommunicationLog&action=DeleteAll&parenttab=Marketing&type=smslist');
    }
    else if(type=='smswork')
    {
        javascript:DeleteAllCommunication('index.php?module=CommunicationLog&action=DeleteAll&parenttab=Marketing&type=smswork');
    }
}

//判断字符中是否包含有特殊字符：
function  check(title){        
 var reg = /^[^@\/\'\\\"#$%&<>()（）《》\^\*]+$/;
 if(reg.test(title)) return true; 
 return false; 
}

function exportCommunicationLog(type)
{
    if(type=='smslist')
    {   
        var url='index.php?module=CommunicationLog&action=CommunicationLogAjax&file=smslist&expt=type&record=57&advft_criteria=&advft_criteria_groups=&defaultReport=57';
        if(document.forms['smslistLog'].begin_createdate!=undefined&&document.forms['smslistLog'].begin_createdate.value!=undefined){
            var begin_createdate=document.forms['smslistLog'].begin_createdate.value
            url+='&begin_createdate='+begin_createdate;
        }
        if(document.forms['smslistLog'].end_createdate!=undefined&&document.forms['smslistLog'].end_createdate.value!=undefined){
            var end_createdate=document.forms['smslistLog'].end_createdate.value
            url+='&end_createdate='+end_createdate;
        }
        if(document.forms['smslistLog'].smsContent!=undefined&&document.forms['smslistLog'].smsContent.value!=undefined){
            var smsContent=document.forms['smslistLog'].smsContent.value
            url+='&smsContent='+smsContent;
        }
        if(document.forms['smslistLog'].calledNumber!=undefined&&document.forms['smslistLog'].calledNumber.value!=undefined){
            var calledNumber=document.forms['smslistLog'].calledNumber.value
            url+='&calledNumber='+calledNumber;
        }
        if(document.forms['smslistLog'].operator!=undefined&&document.forms['smslistLog'].operator.value!=undefined){
            var operator=document.forms['smslistLog'].operator.value
            url+='&operator='+operator;
        }
        if(document.forms['smslistLog'].receiveContacts!=undefined&&document.forms['smslistLog'].receiveContacts.value!=undefined){
            var receiveContacts=document.forms['smslistLog'].receiveContacts.value
            url+='&receiveContacts='+receiveContacts;
        }
        if(document.forms['smslistLog'].smsResultName!=undefined&&document.forms['smslistLog'].smsResultName.value!=undefined){
            var smsResultName=document.forms['smslistLog'].smsResultName.value
            url+='&smsResultName='+smsResultName;
        }
        if(document.forms['smslistLog'].typename!=undefined&&document.forms['smslistLog'].typename.value!=undefined){
            var typename=document.forms['smslistLog'].typename.value
            url+='&typename='+typename;
        }
        javascript:gotourl(url);
    }else if(type=='smswork'){
        var url='index.php?module=CommunicationLog&action=CommunicationLogAjax&file=smswork&expt=type&record=57&advft_criteria=&advft_criteria_groups=&defaultReport=57';
        if(document.forms['smsworkLog'].begin_createdate!=undefined&&document.forms['smsworkLog'].begin_createdate.value!=undefined){
            var begin_createdate=document.forms['smsworkLog'].begin_createdate.value
            url+='&begin_createdate='+begin_createdate;
        }
        if(document.forms['smsworkLog'].end_createdate!=undefined&&document.forms['smsworkLog'].end_createdate.value!=undefined){
            var end_createdate=document.forms['smsworkLog'].end_createdate.value
            url+='&end_createdate='+end_createdate;
        }
        if(document.forms['smsworkLog'].operator!=undefined&&document.forms['smsworkLog'].operator.value!=undefined){
            var operator=document.forms['smsworkLog'].operator.value
            url+='&operator='+operator;
        }
        if(document.forms['smsworkLog'].typename!=undefined&&document.forms['smsworkLog'].typename.value!=undefined){
            var typename=document.forms['smsworkLog'].typename.value
            url+='&typename='+typename;
        }
        javascript:gotourl(url);
    }
}
/*
edit:cdw
date:20130718
reason:按钮清空全部数据
*/
    // @edit:liushuai,2020-11-10,reason:42499: （https://61mis.com/kfbtest [^]）短信记录，短信清单查询和短信批次查询界面，删除和清空所有功能无效，短信记录删除不掉
function emptyAll(type)
{
    //location.href="index.php?module=CommunicationLog&action=DeleteAll&parenttab=Marketing&type=" + type;	  
    ld.ajax({
        url:"index.php?module=CommunicationLog&action=CommunicationLogAjax&file=DeleteAll&type="+type,
        type:"post",
        dataType:"json",
        success:function(data){
            if(type=='smslist')
            {
                  formSmslistLog();
            }
            else if(type=='smswork')
            {
                    formSmsworkLog(); 
            }
        }
    }) 
}
function deleteAll(obj,type)
{
    
    var objdiv_title = 	arrJsPopLabel['WARMPROMPT'];//标题
    var objdiv_content = arrJsPopLabel['SUREDELETEDATABASERECORDS'];//提示内容
    //创建提示弹出层
    MessagePopup.TipTwo_warning(objdiv_content);
    //确定事件
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        emptyAll(type);
        fninvshnew('deleteAllSMS_reminder');
    });
    
    //fnvshobj(obj, 'CL_empty_conf_id'); 
    //document.getElementById('CL_empty_conf_id').style.display = 'block';
    //document.getElementById('CL_Detial').style.display = 'none';
    //document.getElementById('CL_Detial2').style.display = 'none';
}

//ls 2021-12-02 0049072: （81mis.com/kfbcrm/index.php）营销》短信记录》短信批次查询，列表处操作删除短信，会跳转到首页
//短信批次查询（smswork） 列表删除单据
function deleteSingle(obj,type,record)
{
    if (!empty(record)) {
        var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            if(type == "smswork")
            {
                var surl = "index.php?module=CommunicationLog&action=Delete&type=smswork&records="+record;
                ldAjax(surl,"",function(data){
                    if(data.code==1){
                        formSmsworkLog();
                        // ld(obj).parent().parent('tr').remove();
                    }
                    DelProgressObjs();
                })
            }
        })
    }

}

/*
edit:cdw
date:20130723
reason:用于显示弹出框，传值
*/
function checkdetail(BatchNo,Subject,AllCount,SuccessCount,Operator,Createtime,SmsContent,Receive)
{    
    document.getElementById('communicationdetial').style.display = 'block';
    document.getElementById('BatchNo').innerHTML = BatchNo;
    document.getElementById('Subject').innerHTML = Subject;
    document.getElementById('AllCount').innerHTML = AllCount;
    document.getElementById('SuccessCount').innerHTML = SuccessCount;
    document.getElementById('Operator').innerHTML = Operator;
    document.getElementById('Createtime').innerHTML = Createtime;
    document.getElementById('SmsContent').innerHTML = SmsContent;
    document.getElementById('Receive').innerHTML = Receive;
}
function checklistdetail(TaskID,ReceiveContacts,CalledNumber,Operator,Createtime,SmsResultName,Subject,SmsContent)
{
    document.getElementById('communicationdetial').style.display = 'block';
    document.getElementById('TaskID').innerHTML = TaskID;
    document.getElementById('Subject').innerHTML = Subject;
    document.getElementById('SmsContent').innerHTML = SmsContent;
    document.getElementById('Operator').innerHTML = Operator;    
    document.getElementById('Createtime').innerHTML = Createtime;
    document.getElementById('SmsResultName').innerHTML = SmsResultName;
    document.getElementById('Receive').innerHTML = ReceiveContacts+"："+CalledNumber+"";
}
//end
/*
edit:cdw
date:20130724
reason:短信作业查询、短信清单查询中 将员工改成 发送人

1.默认显示为空
2.获取焦点后，显示为下拉选择，下拉选择可显示的用户信息根据当前用户的角色权限显示。可参考提醒中的“提醒人

*/

function fnDropDownUsers(obj,Lay,topY){
    //alert('aaaa');
	var tagName = document.getElementById(Lay);
	var leftSide = findPopX(obj);
	var topSide = findPopY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
        if(topY!=undefined){
        tagName.style.top= topSide + topY+'px';
        tagName.style.width=obj.clientWidth+'px';
        }
        else
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
}
function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('operator');
    if(cbobj!=undefined&&txtobj!=undefined&&txtidobj!=undefined){
        txtobj_str='';
        txtidobj_str='';
        for(i=0;i<cbobj.length;i++){
            if(cbobj[i].checked){
                sp_obj=document.getElementById('sp_user_'+i);
                txt_obj=document.getElementById('txt_user_'+i);
                txtobj_str=txtobj_str+sp_obj.innerHTML+',';
                txtidobj_str=txtidobj_str+txt_obj.value+',';
            }
        }
        txtobj_str=txtobj_str.substr(0,txtobj_str.lastIndexOf(','));
        txtidobj_str=txtidobj_str.substr(0,txtidobj_str.lastIndexOf(','));
        txtobj.value=trim(txtobj_str);
        txtidobj.value=trim(txtidobj_str);
    }
}
//end
function change_check_time(type)
{
    if(type=="smswork")
    {
        document.getElementById('CL_Detial_2').style.display = 'block';
        document.getElementById('CL_Detial').style.display = 'none';
        //document.getElementById('subject').value = '';
        document.getElementById('operator').value = '';
        var all_options = document.getElementById("typename").options;
        all_options[0].selected = true; 
    }
    else
    {
        document.getElementById('CL_Detial_2').style.display = 'block';
        document.getElementById('CL_Detial').style.display = 'none';
        //document.getElementById('subject').value = '';  
        document.getElementById('operator').value = '';
        document.getElementById('smsContent').value = '';
        document.getElementById('receiveContacts').value = '';
        document.getElementById('calledNumber').value = '';
        var all_options = document.getElementById("smsResultName").options;
        all_options[0].selected = true;
        var all_options = document.getElementById("smsResultName").options;
        all_options[0].selected = true;
    }
}
function change_check_all()
{
    document.getElementById('CL_Detial_2').style.display = 'none';
    document.getElementById('CL_Detial').style.display = 'block';
}
//字体加粗
function change_font_work()
{
    $("select_smswork").style.fontWeight='bold';
    ld("#select_smswork").css("class",'on');
    ld("#select_smslist").css("class",'');
    $("select_smslist").style.fontWeight='normal';
    
}
function change_font_list()
{
    $("select_smswork").style.fontWeight='normal';
    $("select_smslist").style.fontWeight='bold';
    ld("#select_smswork").css("class",'');
    ld("#select_smslist").css("class",'on');
}
// --列头全选框被单击---
function chose_all(sonName, cbAllId)
{   
    var arrSon = document.getElementsByName(sonName);
    var cbAll = document.getElementById(cbAllId);
    var tempState=cbAll.checked;
    for(i=0;i<arrSon.length;i++)
    {
        if(arrSon[i].checked!=tempState)
        arrSon[i].click();
    }
}
// --子项复选框被单击---
function ChkSonClick(sonName, cbAllId) 
{
    var arrSon = document.getElementsByName(sonName);
    var cbAll = document.getElementById(cbAllId);
    for(var i=0; i<arrSon.length; i++) 
    {
        if(!arrSon[i].checked) 
        {
            cbAll.checked = false;
            return;
        }
    }
    cbAll.checked = true;
}
//发送人跳转
function to_operator(operator)
{
    //alert(operator);
     new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=CommunicationLog&action=findoperator&operator="+operator,
					onComplete: function(response) 
                    {
    					if(response.responseText.indexOf('###SUCCESS###')>-1)
                        {
    					   var result=response.responseText.split('###SUCCESS###');
                           //alert(result[1]);
                           $id = result[1];
                           window.location.href="index.php?module=Users&action=DetailView&record="+result[1]; 
    					}   
					  
				    }
                }
				);          
}
//批量删除
function checkbox_delete(type)
{
    var type = type;
    var str=document.getElementsByName("selected_id[]");
    //alert(0);
    var objarray=str.length;
    var chestr = '';
    for (var i=0;i<objarray;i++)
    {
      if(str[i].checked == true)
      {
        chestr+=str[i].value+",";   
      }
    }
    if(chestr=="")
    {
        //请选择一条数据
        var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONERECORD'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    //确定要删除吗？
    var confirm_str = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            document.getElementById("BatchIdAll").value += chestr;
            if(type == "smswork")
            {
                formSmsworkLog();
                //document.smsworkLog.submit();
            }
            else
            {
                formSmslistLog();
                //document.smslistLog.submit();
            } 
            document.getElementById("BatchIdAll").value='';
            
            
    });
}

//批量 - 重新发送
function checkbox_resend(type)
{
    var type = type;
    var str=document.getElementsByName("selected_id[]");
    //alert(0);
    var objarray=str.length;
    var chestr = '';
    for (var i=0;i<objarray;i++)
    {
      if(str[i].checked == true)
      {
        chestr+=str[i].value+",";   
      }
    }
    if(chestr=="")
    {
        //请选择一条数据
        var confirm_str = arrJsPopLabel['PLEASESELECTLEASTONERECORD'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        return false;
    }

    //确定要重新发送吗吗？
    var confirm_str = arrJsPopLabel['besuretoresend'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		ld.ajax("index.php?action=MassSMSAjax&module=MassSMS&file=Send&mode=ajax&resend=yes&ids="+chestr)
		.done(function(results){
			RemindsMsg("","LdPopWidth400px","","","",arrJsPopLabel['SENDSUCCESSFULLY']);
			window.location.reload();
		})
    });
}

/**
 * 选择审批步骤指定审批人
 * @author Tujt 2015-04-29
 */
function CommunicationLog_selectuser(){
    var selectuserid = ld('#recieverid').val();
	var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
	var module = 'CommunicationLog';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = '';
		   cls_ScopePopup.prop.popup_value = selectuserid;
           cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user'
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
                    }else{
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						ld('#operator').html(cls_ScopePopup.return_obj.return_name);
						ld('#recieverid').val(cls_ScopePopup.return_obj.return_id);
                            if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                                         //通讯录(pc端企业微信)
                                        cls_wxOpenDataobj.bindAllOpenData();
                                        
					}
                });
            }
		});
	});
}