/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
/*
edit:can
date:20130717
reason:转普通/转公海
0:转普通，1:转公海
*/
function convertaccount(start,recordid,customtype)
{
     var searchScope='',customtypename='',viewname='';
     //17912: (新账套 192.168.1.169:85/crm)产品>明细,关于相关信息客户处转换客户类型的问题
    if(document.massdelete!=undefined&&document.massdelete.publicaccounttype!=undefined)//产品相关信息客户
          customtypename=document.massdelete.publicaccounttype.value;
    if(document.getElementById("SmOwnerSearchScope")!=undefined)//产品相关信息客户
    
        searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    if(document.getElementById("viewname")!=undefined)
        viewname=document.getElementById("viewname").value;
	if(customtypename == ''){
		customtypename = 'ALLACCOUNT';
	}
   window.location="index.php?module=Accounts&record="+recordid+"&pagepublicaccounttype="+customtypename+"&action=ConvertAccount&customtype="+customtype+"&SearchScope="+searchScope+"&viewname="+viewname;
    
}
/*
edit:can
date:20130727
reason:延期界面
*/
function DeskDelayaccount(start,recorid,obj,divid)
{
    var  customtypename=document.massdelete.publicaccounttype.value;
    var  customtypename=document.massdelete.publicaccounttype.value;
    var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var viewname=document.getElementById("viewname").value;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth500px",'Accounts',"",'none',"","");
	crmPopupobj.prevshow();
	ld.ajax({
		url: "index.php?module=Accounts&action=DeskDelayAccount&parenttab=Parent Accounts&record="+recorid+"&pagepublicaccounttype="+customtypename+"&SearchScope="+searchScope+"&viewname="+viewname,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth500px",'Accounts',"","","","");  
				crmPopupobj.show(data.result.content);
			}
		}
	})
}
/*
edit:can
date:20130727
reason:延期操作

*/
function funDelayAccount(recorid)
{
     if(trim(document.DelayAccount.txtdelay.value)=="")
     {
        //延期天数不能为空！
        var confirm_str = arrJsPopLabel['POSTPONEDFEWDAYSCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        document.DelayAccount.txtdelay.focus();
        
        return false;
     }
     if(isNaN(document.DelayAccount.txtdelay.value))
     {
        //非法延期天数！
        var confirm_str = arrJsPopLabel['ILLEGALPOSTPONEDFEWDAYS'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        document.DelayAccount.txtdelay.focus();
        return false;
     }
     if(document.DelayAccount.txtdelay.value<=0||document.DelayAccount.txtdelay.value.split(".").length>1)
     {
        //延期天数只能录入正整数！
        var confirm_str = arrJsPopLabel['POSTPONEDFEWDAYPOSITIVEINT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        document.DelayAccount.txtdelay.focus();
        return false;
     }
     
    var  customtypename=document.massdelete.publicaccounttype.value;
    var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var viewname=document.getElementById("viewname").value;
    return true;
   
}
/*
edit:can
date:20130727
reason:释放已分配客户
*/
function Releaseaccount(start,recordid)
{
    var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var viewname=document.getElementById("viewname").value;
    var  accounttype=document.massdelete.publicaccounttype.value;
	var crmPopupobj=CrmPopup.load("","","","",'Accounts',"",'none',"","");
	crmPopupobj.prevshow();
	crmPopupobj.setParams(arrJsPopLabel['RELEASE'],ReleaseaccountSubmit,"","LdPopWidth600px",'Accounts',"",arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
	var  shtml = '<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">';
	shtml += '<tr><td>';
	shtml += '<form name="formreleasaccount" method="post">';
	shtml += '<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">';
	shtml += '<input type="hidden" name="record" id = "record" value="'+recordid+'">';
	shtml += '<tr><td width="120px;">';
	shtml += '<span style="color: red;">*&nbsp;</span>'+arrJsPopLabel['RELEASEACCOUNTTREASON']+':';
	shtml += '</td><td>';
	shtml += '<textarea style="width: 370px;height: 90px;max-height: 90px;max-width: 370px" class="releaseAccountReason" name="releaseAccountReasons"></textarea>';
	shtml += '</td></tr>';
	shtml += '</table>';
	shtml += '</form>';
	shtml += '</td></tr>';
	shtml += '</table>';
	
	crmPopupobj.show(shtml);
	return false;
}

var ReleaseaccountSubmit = function(){
	var  popupobj=CrmPopup.getPopupObj("last");
	var releaseAccountReasons = CrmPopup.findHtmlobj(popupobj.divid,'releaseAccountReasons').val();
	if(releaseAccountReasons == ''){
		var confirm_str = ReleanAccountReason+arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		CrmPopup.findHtmlobj(popupobj.divid,'releaseAccountReasons').focus();
		return false;
	}else{
		var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
		var viewname=document.getElementById("viewname").value;
		var  accounttype=document.massdelete.publicaccounttype.value;
		var recordid = CrmPopup.findHtmlobj(popupobj.divid,'record').val();
		//alert("index.php?module=Accounts&record="+recordid+"&pagepublicaccounttype="+accounttype+"&action=ReleaseAccount&SearchScope="+searchScope+"&viewname="+viewname);
		//return false;
		ld.ajax("index.php?module=Accounts&record="+recordid+"&pagepublicaccounttype="+accounttype+"&action=AccountsAjax&file=ReleaseAccount&SearchScope="+searchScope+"&viewname="+viewname+"&releaseAccountReasons="+releaseAccountReasons)
		.done(function(results){
			getListViewEntries_js('Accounts', results);//刷新页面
			cancelCrmPopup();
			return false;
		})
	}
	return false;
}
/*
 edit:can
 date:20130719
 reason:公海客户批量释放

 */
function massrelease()
{
    /* if(!selectchoice())
     {
     return false;
     }*/

    var select_options = document.getElementById('allselectedboxes').value;

    var count=select_options.split(";").length-1;
    if(select_options=='all')
    {
        count=$('numOfRows').value;
    }
    if(count <= 0){
        RemindsMsg("","LdPopWidth400px","","yes","","");
        return false;
    }

    if(count > getMaxMassOperationLimit()) {
        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count,getMaxMassOperationLimit(),'');
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		//确定按钮
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			confirmMassrelease(select_options);
		})
		return false;
    } else {
        confirmMassrelease(select_options);
    }
    //"您确定要释放选定的"+count+"条记录至公海未分配吗？"
	confirmMassrelease(select_options);
}
//批量释放
function confirmMassrelease(select_options){
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


    //初始化 GYQ1230
    ld("#ReleanseAccountDiv .releaseAccountReason").val('');
    fnvshobj('', 'ReleanseAccountDiv');
    document.forms['formreleasaccount'].releaseAccountReasons.focus();
    //绑定取消按钮  selectall selected_id
    ld("#ReleanseAccountDiv .D_ptcancel").unbind("click").on("click",function(){

        ld("[name='selected_id']").removeAttr("checked");//取消全选
        ld("[name='selectall']").removeAttr("checked");//取消全选
    });

    // 绑定确认按钮
    ld("#ReleanseAccountDiv .D_ptconfrim").unbind("click").on("click",function(){
        if(trim(ld("#ReleanseAccountDiv .releaseAccountReason").val())!='')
        {

            var releaseaccountreason = trim(ld("#ReleanseAccountDiv .releaseAccountReason").val());

 
                ld("#ReleanseAccountDiv").css('display','none');


            /*
            * editor: gyq
            * reason: Jquery,居中修正
            * date :  2016 1 4
            * */
            url ="index.php?module=Accounts&action=AccountsAjax&file=MassReleaseAccount"+gstart;
            ld.post(url,{parenttab:'Parent Accounts',idstring:select_options,pagepublicaccounttype:accounttype,
                    SearchScope:searchScope,viewname:viewname,excludedRecords:excludedRecords, releaseAccountReasons:(releaseaccountreason)},
                function(response){

                    $("status").style.display="none";
                    if(empty(response)) return false;
                  /*  var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);*/
                    var restobj = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);

                    createElementDiv('releaseConvert');//创建DIV

                    ld('#releaseConverttitlename').html(restobj.title.value);
                    ld('#releaseConverttitlename').html(restobj.title.value);
                    //sethtml(document.getElementById('releaseConvertcontent'),restobj.log.value);

                    ld('#releaseConvertcontent').html(restobj.log.value);
                    ld('#releaseConvertcontent').css('overflow-y','auto');
                    ld('#releaseConvertcontent').css('max-height','350px');
                    ld('#releaseConvert .D_pbtn .D_pbtncancel').css('display','none');
                    ld('#releaseConvert .D_pbtn .D_pbtnok').unbind('click').on('click',function() {

                        fninvshnew('releaseConvert');
                        lingdangJS_DialogBox.unblock();
                        ld('#current_page_boxes').val('');//清空所选单据checkbox
                        ld('#allselectedboxes').val('');//清空选择全部参数
                        ld('#selectedboxes').val('');
                        getListViewEntries_js('Accounts', restobj.start.value);//刷新页面
                    });

                    fnvshobj('', 'releaseConvert');

                });

        }

        else
        {
            var confirm_str = ReleanAccountReason+arrJsPopLabel['CANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            document.forms['formreleasaccount'].releaseAccountReasons.focus();
            return false;
        }
    });
}



function massconvertaccount(customtype)
{
    
    var select_options = document.getElementById('allselectedboxes').value;
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
    if(selectchoice())
    {
         massConvert_Load(select_options,customtype);  
    }
}
function selectchoice()
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
            RemindsMsg("","LdPopWidth400px","","yes","","");
			return false;
		}
	}
    return false;
}
function massConvert_Load(select_options,customtype)
{
	var count=select_options.split(";").length-1;
	if(select_options=='all')
	{
		count=$('numOfRows').value;
	}
    var confirm_str="";
    var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
      
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
	var excludedRecords = $('excludedRecords').value;
	var viewid = getviewId();
    $("status").style.display="inline";
    if(count < getMaxMassOperationLimit()) {
		if(customtype==0)
		{
			 //confirm_str="确定要转换选定的"+count+"条记录为普通客户吗"
			 confirm_str=arrJsPopLabel['SUREWANTCONVERTSELECTED']+count+arrJsPopLabel['RECORDSTHEORDINARYCLIENTS']
		}
		else
		{
			//confirm_str="确定要转换选定的"+count+"条记录为公海客户吗？";
			confirm_str=arrJsPopLabel['SUREWANTCONVERTSELECTED']+count+arrJsPopLabel['RECORDSTHEHIGHSEASCLIENTS'];
		}
		$("status").style.display="none";
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
			var confirm_status = true;
			var numOfRows=document.getElementById("numOfRows").value; 
			//alert("module=Accounts&action=AccountsAjax&file=ConvertAccount&parenttab=Parent Accounts&idstring="+select_options+"&customtype="+customtype+"&excludedRecords="+excludedRecords+"&viewname="+viewid+"&pagepublicaccounttype="+accounttype+"&ajax=true&mass_convert_totalrows="+numOfRows,);
				new Ajax.Request
				(
						'index.php',
						{
							queue: {
								position: 'end',
								scope: 'command'
							},
							method: 'post',
							postBody:"module=Accounts&action=AccountsAjax&file=ConvertAccount&parenttab=Parent Accounts&idstring="+select_options+"&customtype="+customtype+"&excludedRecords="+excludedRecords+"&viewname="+viewid+"&pagepublicaccounttype="+accounttype+"&ajax=true&mass_convert_totalrows="+numOfRows,
							onComplete: function(response)
							 {
								$("status").style.display="none";
								if(empty(response.responseText)) return false;
								var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
								createElementDiv('massConvert');//创建DIV
								ld('#massConverttitlename').html(restobj.title.value);
								sethtml(document.getElementById('massConvertcontent'),restobj.log.value);
								ld('#massConvert .D_pbtn .D_pbtncancel').css('display','none');
								fnvshobj(this,'massConvert');
								ld('#massConvert .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
									fninvshnew('massConvert');lingdangJS_DialogBox.unblock();
									if(document.getElementById('allselectedboxes') != undefined){
										document.getElementById('allselectedboxes').value='';   
									}
									if(document.getElementById('selectedboxes') != undefined){
										document.getElementById('selectedboxes').value='';   
									}
									getListViewEntries_js('Accounts',restobj.start.value);//刷新页面
								});
								return false;
								
							 }
						}
				  );
		});
	}else{
		var confirm_status = true;
			var numOfRows=document.getElementById("numOfRows").value; 
			//alert("module=Accounts&action=ConvertAccount&parenttab=Parent Accounts&idstring="+select_options+"&customtype="+customtype+"&excludedRecords="+excludedRecords+"&viewname="+viewid+"&pagepublicaccounttype="+accounttype);
				new Ajax.Request
				(
						'index.php',
						{
							queue: {
								position: 'end',
								scope: 'command'
							},
							method: 'post',
							postBody:"module=Accounts&action=AccountsAjax&file=ConvertAccount&parenttab=Parent Accounts&idstring="+select_options+"&customtype="+customtype+"&excludedRecords="+excludedRecords+"&viewname="+viewid+"&pagepublicaccounttype="+accounttype+"&ajax=true&mass_convert_totalrows="+numOfRows,
							onComplete: function(response)
							 {
								$("status").style.display="none";
								if(empty(response.responseText)) return false;
								var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
								createElementDiv('massConvert');//创建DIV
								ld('#massConverttitlename').html(restobj.title.value);
								sethtml(document.getElementById('massConvertcontent'),restobj.log.value);
								ld('#massConvert .D_pbtn .D_pbtncancel').css('display','none');
								fnvshobj(this,'massConvert');
								ld('#massConvert .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
									fninvshnew('massConvert');lingdangJS_DialogBox.unblock();
									if(document.getElementById('allselectedboxes') != undefined){
										document.getElementById('allselectedboxes').value='';   
									}
									if(document.getElementById('selectedboxes') != undefined){
										document.getElementById('selectedboxes').value='';   
									}
									getListViewEntries_js('Accounts',restobj.start.value);//刷新页面
								});
								return false;
								
							 }
						}
				  );
	}
    
    
	
}
function AllocatetaccountDetails(recordid,allocatetype,assigneduserid,assignedusername){
    Allocatetaccount.page_type='detail';
   
    Allocatetaccount(0,recordid,allocatetype,assigneduserid,assignedusername);
    
}
Allocatetaccount.obj=new Object();
Allocatetaccount.page_type='list';
Allocatetaccount.obj.list_allocation=function()
{
    Allocatetaccount.obj.searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
     if(Allocatetaccount.obj.allocatetype==2)
     {
         var splitrecord=Allocatetaccount.obj.recordid.split(";");
         Allocatetaccount.obj.recordid=trim(splitrecord[0]);
     }
     Allocatetaccount.obj.pagepublicaccounttype=document.massdelete.publicaccounttype.value; 
   if(document.forms['massdelete'].pagenum!=undefined)
     {
            Allocatetaccount.obj.gstart="&start="+document.forms['massdelete'].pagenum.value;
     }
     else
     {
            Allocatetaccount.obj.gstart="&start="+document.forms['massdelete'].pagenum[0].value;
     }
     Allocatetaccount.obj.viewname=document.getElementById("viewname").value; 
                       
     
}
Allocatetaccount.obj.re_load=function()
{
    if(Allocatetaccount.page_type=='list')
    {
                                                
        window.location="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&record="+Allocatetaccount.obj.recordid+"&allocatetype="+Allocatetaccount.obj.allocatetype+"&start"+Allocatetaccount.obj.start+"&pagepublicaccounttype="+Allocatetaccount.obj.accounttype+"&SearchScope="+Allocatetaccount.obj.searchScope+"&viewname="+Allocatetaccount.obj.viewname;
    }
    else
    {
        
        window.location="index.php?module=Accounts&action=DetailView&record="+Allocatetaccount.obj.recordid;
    }
    $("status").style.display="none";
                                           
}


/*
edit:can
date:20130718
reason:公海客户(allocatetype)2:分配,3:领取
*/
function Allocatetaccount(start,recordid,allocatetype,assigneduserid,assignedusername)
{
    
     Allocatetaccount.obj.start=start;
     Allocatetaccount.obj.recordid=recordid;
     Allocatetaccount.obj.allocatetype=allocatetype;
     Allocatetaccount.obj.accounttype=""; 
     Allocatetaccount.obj.gstart="";
     Allocatetaccount.obj.viewname=""; 
     Allocatetaccount.obj.pagepublicaccounttype='';
     Allocatetaccount.obj.assigneduserid=assigneduserid;
     Allocatetaccount.obj.assignedusername=assignedusername;
     if(Allocatetaccount.page_type=='list')//列表界面
     {
        Allocatetaccount.obj.list_allocation();
     }
     $("status").style.display="inline";
      var url="module=Accounts&action=AccountsAjax&file=AllocateAccount&record="+Allocatetaccount.obj.recordid+"&allocatetype="+Allocatetaccount.obj.allocatetype+"&start"+Allocatetaccount.obj.start+"&maxaccount=1";
      if(Allocatetaccount.obj.allocatetype==2)
      {
            var userid= Allocatetaccount.obj.assigneduserid;
          //var userid=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].value;
          url=url+"&userid="+userid;
         
      }      
    new Ajax.Request
    (
        'index.php',
        {
            queue: {
            position: 'end',
            scope: 'command'
            },
            method: 'post',
            postBody:url,
            onComplete: function(response)
                {
                   if(response.responseText.indexOf("###error###")!=-1)
                   {
                        var results= response.responseText.split("###error###");
                        
                        if(results[1] == 3&&Allocatetaccount.obj.allocatetype==2) //已领取
                        {
                            confirm_str = arrJsPopLabel['THEHIGHTSEAHASBEENRECEIVERD'];
                        }
                        else if(results[1]==2&&Allocatetaccount.obj.allocatetype==2)//已分配
                        {
                            confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
                        }
                        else if(results[1] == 3&&Allocatetaccount.obj.allocatetype==3) //已领取
                        {
                            confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE'];
                        }
                        else if(results[1]==2&&Allocatetaccount.obj.allocatetype==3)//已分配
                        {
                            confirm_str = arrJsPopLabel['THEHIGHTSEAHASBEENALLOCATE'];
                        }
                        else
                        {
                            if(Allocatetaccount.obj.allocatetype==3)
                                //您拥有的公海客户数量已经达到上限，领取失败！
                                confirm_str = arrJsPopLabel['HIGHSEASREACHEDTHELIMITCOLLECT'];
                            else
                            {
                                var username=Allocatetaccount.obj.assignedusername;
                                // var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
                                //alert(username+"拥有的公海客户数量已经达到上限，分配失败！");
                                //拥有的公海客户数量已经达到上限，分配失败！
                                confirm_str = username+arrJsPopLabel['HIGHSEASREACHEDTHELIMITALLOCATION'];
                            }   
                        }    
                         RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                         $("status").style.display="none";
                         return false;
                   }
                   else
                   {
                        var results= response.responseText.split("###");
                        
                        var confirm_str="";
                       
                       if(Allocatetaccount.obj.allocatetype==3)
                       {
                            //confirm_str="确定要领取公海客户:"+results[1]+"？";
                            confirm_str=arrJsPopLabel['SUREWANTRECEIVEHIGHSEAS']+results[1]+"？";
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                            //确定按钮
		                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                new Ajax.Request
                                    (
                                        'index.php',
                                        {
                                            queue: {
                                            position: 'end',
                                            scope: 'command'
                                            },
                                            method: 'post',
                                            postBody:url,
                                            onComplete: function(response)
                                            {
                                               Allocatetaccount.obj.accounttype="NOALLOCATE";  
                                               Allocatetaccount.obj.re_load();
                                                
                                            }
                                        }
                                    );
		                    });
                            
                            //关闭、取消按钮
		                    ld('input[onclick="msgConfirm()"]').unbind('click').on('click',function(){
		                      ld("#status").css('display','none');
		                    });                                                                              
                       }
                       else
                       {         
                             var username=Allocatetaccount.obj.assignedusername;
                             var userid=Allocatetaccount.obj.assigneduserid;
                            //var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
                            //var userid=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].value;
                            var allotUrl = "module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+Allocatetaccount.obj.recordid+";&allocatetype="+Allocatetaccount.obj.allocatetype+"&start="+Allocatetaccount.obj.start+"&pagepublicaccounttype="+Allocatetaccount.obj.pagepublicaccounttype+"&SearchScope="+Allocatetaccount.obj.searchScope+"&viewname="+Allocatetaccount.obj.viewname+"&username="+encodeURIComponent(username)+"&assign_name="+userid+'&userid='+userid;
                         
                            new Ajax.Request
                            (
                                'index.php',
                                {
                                    queue: {
                                    position: 'end',
                                    scope: 'command'
                                    },
                                    method: 'post',
                                    postBody:allotUrl,
                                    onComplete: function(response)
                                    {
                                        
                                          Allocatetaccount.obj.re_load();
                                    }
                                }
                            )
                       }
                       
                   }
                                                                   
              
               }
            }
    )
}

/*
edit:can
reason:批量分配保存
*/
function massAllocate(Allocatetype)
{
	
    if(Allocatetype != 2){
		if(!selectchoice()){
			return false;
		}
	}
	var select_options = document.getElementById('allselectedboxes').value; 
	massAllocate_Load(select_options,Allocatetype);
   
}//11903;3
function massAllocate_Load(select_options,allocatetype,assigneduserid,assignedusername)
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
    var url="module=Accounts&action=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&maxaccount=1&excludedRecords="+excludedRecords+"&viewname="+viewname+"&SearchScope="+searchScope;
    //var url="module=Accounts&action=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&maxaccount=1&pagepublicaccounttype="+accounttype+"&excludedRecords="+excludedRecords+"&viewname="+viewname+"&SearchScope="+searchScope;
    if(allocatetype==2)
    {
          var userid=assigneduserid;
          //var userid=document.getElementById('assigned_user_id').value;
          url=url+"&userid="+userid+"&assign_name="+assignids+"&id="+idlist;
    }

   	new Ajax.Request(
               	'index.php',
                {queue: {position: 'end', scope: 'command'},
                       	method: 'post',
                        async: false,
                        postBody:url,
                        onComplete: function(response) {
                          if(allocatetype==3)//领取
                          {
                            $("status").style.display="none";
                            if(response.responseText.indexOf("###error###2")!=-1)
                            {
                                confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENALLOCATE'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                return false;  
                            }
                            else if(response.responseText.indexOf("###error###3")!=-1)
                            {
                                confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENRECEIVERD_RECEIVER'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                return false; 
                            }
                            else if(response.responseText.indexOf("###error###")!=-1)
                            {
                                 //您拥有的公海客户数量已经达到上限，领取失败！
                                 confirm_str = arrJsPopLabel['HIGHSEASREACHEDTHELIMITCOLLECT'];
                                 RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                 return false;
                            }
                             
                           
                          }
                         if(allocatetype==2)//分配
                          {
                               $("status").style.display="none";
                               if(response.responseText.indexOf("###error###2")!=-1)
                               {
                                 confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENALLOCATE_ALLOCATEFAILUR'];
                                 RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                               }
                               else if(response.responseText.indexOf("###error###3")!=-1)
                               {
                                 confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENRECEIVERD'];
                                 RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                               }
                               else if(response.responseText.indexOf("###error###")!=-1)
                                {
                                  var username=assignedusername;
                                  //var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
                                  //拥有的公海客户数量已经达到上限，分配失败！
                                  confirm_str = username+arrJsPopLabel['HIGHSEASREACHEDTHELIMITALLOCATION'];
                                  RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                  return false;
                                }
                            }
                         
                          var results=response.responseText.split("###");
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
                                        $("status").style.display="none";
                                        return false;
                                   }
                                        var receiveUrl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&assign_name="+assignids+"&id="+idlist+"&viewname="+viewname;
                                        //var receiveUrl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&pagepublicaccounttype="+accounttype+"&assign_name="+assignids+"&id="+idlist+"&viewname="+viewname;
                                        http_reqfield=createfieldXMLHTTP();
                                        http_reqfield.open("POST",receiveUrl,false);
                                        isDuplicate=false;
                                        http_reqfield.onreadystatechange=setAllocateAccount;
                                        http_reqfield.setRequestHeader("If-Modified-Since","0");
                                        http_reqfield.send(null);
                                        //点击确认
                                        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                            if(isDuplicate == false)
                                            {
                                                window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;                                        //return true;
                                                //window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&pagepublicaccounttype="+accounttype+"&viewid="+viewname;                                        //return true;
                                            }
                                        });                        
                            }
                            else
                            {     
                                  //var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
                                  // var userid=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].value;
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
										username=encodeURIComponent(username);
										var assign_name=document.getElementById('assign_name').value
                                        var receiveUrl ="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
										//var receiveUrl ="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&pagepublicaccounttype="+accounttype+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
										//alert(receiveUrl);
										http_reqfield=createfieldXMLHTTP();
										http_reqfield.open("POST",receiveUrl,false);
										isDuplicate=false;
										http_reqfield.onreadystatechange=setAllocateAccount;
										http_reqfield.setRequestHeader("If-Modified-Since","0");
										http_reqfield.send(null);
                                        if(selectType==2)
                                        {
                                             window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                                        }
                                        else
                                        {
                                            //点击确定按钮
                                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                                if(isDuplicate == false)
                                                {
                                                    window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                                                }
                                            });   
                                        }
                                        
								  }else{
								    
									  if(confirm(confirm_str))
									  {
											username=encodeURIComponent(username);
											var assign_name=document.getElementById('assign_name').value
                                            var receiveUrl ="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
											//var receiveUrl ="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&pagepublicaccounttype="+accounttype+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
											
											http_reqfield=createfieldXMLHTTP();
											http_reqfield.open("POST",receiveUrl,false);
											isDuplicate=false;
											http_reqfield.onreadystatechange=setAllocateAccount;
											http_reqfield.setRequestHeader("If-Modified-Since","0");
											http_reqfield.send(null);
                                            if(selectType=1)
                                           {
                                                 window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                                           }
                                           else
                                           {
                                                 ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                                    if(isDuplicate == false)
                                                    {
                                                        window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                                                    }
                                                }); 
                                           } 
									  }
									  else
									  {
										$("status").style.display="none";
									  }
								  }
                            }
                        }
                }
	);
    
}
var http_reqfield;

function createfieldXMLHTTP()
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
function setAllocateAccount()
{
  
    if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
    {
        var str=http_reqfield.responseText;
        var results=str.split('###');
        lingdangJS_DialogBox.unblock();
        if(results[3] == 3)   //批量领取
        {
            var prompt = arrJsPopLabel['BATCHRECEIVE'];
        }
        else
        {
            var prompt = arrJsPopLabel['BATCHALLOCATION'];
        }
        
		if(selectType == 1){
			if(results[2] == 0)
			{
                confirm_str = arrJsPopLabel['SUCCESS']+prompt+" "+results[1]+" "+arrJsPopLabel['RECORDS'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);	
			}
			else
			{
                confirm_str = arrJsPopLabel['SUCCESS']+prompt+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			}
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
function massDeskAllocatetaccount(obj)
{
   if(!selectchoice())
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
        
	var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
	var module = 'Accounts';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = '';
           cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes';
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						return false;
                    }else{
						ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
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
						massAllocate_Load(select_id,2,assigneduserid,assignedusername);
					}
                });
            }
		});
	});
}
function massDeskAllocatetaccountDetails(obj,record){
	new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
					method: 'post',
					postBody:"module=Accounts&action=AllocateUsers&pagepublicaccounttype=&idstring="+record+"&record="+record+"&totalrows=1&detailview=1",
					onComplete: function(response) {
						if(response.responseText.indexOf("###error###2")!=-1){//已分配
							var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
							$("status").style.display="none";
							return false;
						}
                        else if(response.responseText.indexOf("###error###3")!=-1)
                        {
                            //已领取
                             var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE'];
                             RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                             $("status").style.display="none";
							return false;
                        }


						var scopepopupobj;//自定义弹出层页面html，绑定事件
						var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
						var module = 'Accounts';
						getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
							scopepopupobj =  new ScopePopupObj(module);
							scopepopupobj.popup_caption_value = popup_caption_value;//标题title
							getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
							   cls_ScopePopup.prop.popup_module = module;//模块
							   cls_ScopePopup.prop.popup_value = '';
							   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes';
							   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
								//重写确认按钮事件
								scopepopupobj.setEventBtnOk=function(){
									ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
										if(empty(cls_ScopePopup.return_obj.return_id)){
										  var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
										  RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
										}else{
											ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
											var assigneduserid=cls_ScopePopup.return_obj.return_id;//选中的用户id 
											var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
											var savefilter = '';var mode = '';
											AllocatetaccountDetails(record,2,assigneduserid,assignedusername);
										}
									});
								}
							});
						});
                      
					}
			}
	);
}
function DeskAllocatetaccount(obj,start,record,divid)
{
    $("status").style.display="inline";
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
                    postBody:"module=Accounts&action=AllocateUsers&start=1&viewid="+viewName+"&listview=1&SearchScope="+searchScope+"&pagepublicaccounttype="+accounttype+"&record="+record,
                    onComplete: function(response) {
                    if(response.responseText.indexOf("###error###")!=-1)
                    {
                        var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        $("status").style.display="none";
                        return false;
                    }
					var scopepopupobj;//自定义弹出层页面html，绑定事件
					var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
					var module = 'Accounts';
					getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
						scopepopupobj =  new ScopePopupObj(module);
						scopepopupobj.popup_caption_value = popup_caption_value;//标题title
						getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
						   cls_ScopePopup.prop.popup_module = module;//模块
						   cls_ScopePopup.prop.popup_value = '';
						   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes';
						   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
							//重写确认按钮事件
							scopepopupobj.setEventBtnOk=function(){
								ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
									if(empty(cls_ScopePopup.return_obj.return_id)){
										RemindsMsg("","LdPopWidth400px","","yes","","");
										return false;
									}else{
										ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
										var assigneduserid=cls_ScopePopup.return_obj.return_id;//选中的用户id 
										var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
										var savefilter = '';var mode = '';
										massAllocate_Load(record,2,assigneduserid,assignedusername);
									}
								});
							}
						});
					});
                   
                    }
            }
	);
    
    
    
}

function fnvshAllocateobj(obj,Lay){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj)-230;
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
    if(Lay == 'editdiv')
	{
		leftSide = leftSide - 2005;
		topSide = topSide - 125;
	}
    else if(Lay == 'transferdiv')
	{
		leftSide = leftSide - 1000;        
		topSide = topSide;
	}
	var IE = document.all?true:false;
	if(IE)
	{
		if($("repposition1"))
		{
			if(topSide > 1200)
			{
				topSide = topSide-250;
			}
		}
	}

	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide + 'px';
	tagName.style.top= topSide + 'px';
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";
}


/*
edit:Can
date:20130716
reason:公海客户需求
*/
function showCustomType(obj,module,customtype)
{
    $("status").style.display="inline";
    
    viewid=document.getElementById("viewname").value;

    if(document.getElementById("SmOwnerSearchScope")!=null)
     var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
     else
     searchScope='';
    
     document.getElementById("viewname").value=viewid;
	var viewName = encodeURIComponent(viewid);
   document.massdelete.publicaccounttype.value=customtype;
     var listview_page=new ListView_Page(module,"module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&SearchScope="+searchScope+"&pagepublicaccounttype="+customtype,"ListViewContents");
    listview_page.callback_fun=function()
    {
        setReiszeTable_Init(module,'ajax');
        setContentHeight(module);//计算内容高度    
    }
    listview_page.page();
    

}

function set_return(product_id, product_name) {
	if(document.getElementById('from_link').value != '') {
        window.opener.document.QcEditView.parent_name.value = product_name;
        window.opener.document.QcEditView.parent_id.value = product_id;
	} else {
        window.opener.document.EditView.parent_name.value = product_name;
        window.opener.document.EditView.parent_id.value = product_id;
	}
}
function set_return_specific(product_id, product_name) {
        
        //getOpenerObj used for DetailView 
	if(document.getElementById('from_link').value != '')
	{
		var fldName = window.opener.document.QcEditView.accounts_name;
		var fldId = window.opener.document.QcEditView.account_id;
	}else
	{	
		var fldName = window.opener.document.EditView.accounts_name;
		var fldId = window.opener.document.EditView.account_id;
	}
        fldName.value = product_name;
        fldId.value = product_id;
}
function set_CashBill_specific(product_id, product_name,mode)
{
     
      var fldName = getOpenerObj("account_name");
        var fldId = getOpenerObj("account_id");
      
        fldName.value = product_name;
        
        fldId.value = product_id;
        
	if(mode != 'DetailView'&& window.opener.document.EditView.salesorder_id.value=="")
	{
		//window.opener.document.EditView.action.value = 'EditView';
        
        window.opener.document.EditView.accounts_name.value = product_name;
        window.opener.document.EditView.account_id.value = product_id;
	}
    else 
    {
        window.opener.document.EditView.accounts_name.value = account_name;
        window.opener.document.EditView.account_id.value = account_id;
    }
}
function add_data_to_relatedlist(entity_id,recordid) {
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:"module=Emails&action=updateRelations&destination_module=Accounts&entityid="+entity_id+"&parentid="+recordid,
		onComplete: function(response) {
			var popupobj=CrmPopup.getPopupObj('lastprev');
			var divid = popupobj.divid;
			var related_id = CrmPopup.findHtmlobj(divid,'hidden_related_id_Accounts').val();
			var viewid = CrmPopup.findHtmlobj(divid,'viewname_Accounts').val();
			cancelCrmPopup();
			showRelatedCustomView(related_id,viewid);
			setRelatedResizeTable_Init('Accounts');
			set_rel_count();
		}
	}
	);
}
function set_return_formname_specific(formname,product_id, product_name) {
        window.opener.document.EditView1.accounts_name.value = product_name;
        window.opener.document.EditView1.account_id.value = product_id;
}
//added to populate address
function set_return_contact_address(account_id, account_name, bill_street, ship_street, bill_city, ship_city, bill_state, ship_state, bill_code, ship_code, bill_country, ship_country,bill_pobox,ship_pobox ) {
	if(document.getElementById('from_link').value != '') {
		if(typeof(window.opener.document.QcEditView.accounts_name) != 'undefined')
                window.opener.document.QcEditView.accounts_name.value = account_name;
        if(typeof(window.opener.document.QcEditView.account_id) != 'undefined')
                window.opener.document.QcEditView.account_id.value = account_id;		
	} else if(typeof(window.opener.document.EditView) != 'undefined'){
		if(typeof(window.opener.document.EditView.accounts_name) != 'undefined')
                window.opener.document.EditView.accounts_name.value = account_name;
        if(typeof(window.opener.document.EditView.account_id) != 'undefined')
                window.opener.document.EditView.account_id.value = account_id;
        if(typeof(window.opener.document.EditView.mailingstreet) != 'undefined')
                window.opener.document.EditView.mailingstreet.value = bill_street;
        if(typeof(window.opener.document.EditView.otherstreet) != 'undefined')
                window.opener.document.EditView.otherstreet.value = ship_street;
        if(typeof(window.opener.document.EditView.mailingcity) != 'undefined')
                window.opener.document.EditView.mailingcity.value = bill_city;
        if(typeof(window.opener.document.EditView.othercity) != 'undefined')
                window.opener.document.EditView.othercity.value = ship_city;
        if(typeof(window.opener.document.EditView.mailingstate) != 'undefined')
                window.opener.document.EditView.mailingstate.value = bill_state;
        if(typeof(window.opener.document.EditView.otherstate) != 'undefined')
                window.opener.document.EditView.otherstate.value = ship_state;
        if(typeof(window.opener.document.EditView.mailingzip) != 'undefined')
                window.opener.document.EditView.mailingzip.value = bill_code;
        if(typeof(window.opener.document.EditView.otherzip) != 'undefined')
                window.opener.document.EditView.otherzip.value = ship_code;
        if(typeof(window.opener.document.EditView.mailingcountry) != 'undefined')
                window.opener.document.EditView.mailingcountry.value = bill_country;
        if(typeof(window.opener.document.EditView.othercountry) != 'undefined')
                window.opener.document.EditView.othercountry.value = ship_country;
        if(typeof(window.opener.document.EditView.mailingpobox) != 'undefined')
                window.opener.document.EditView.mailingpobox.value = bill_pobox;
        if(typeof(window.opener.document.EditView.otherpobox) != 'undefined')
                window.opener.document.EditView.otherpobox.value = ship_pobox;
    }
    /**
     * @edit:chj
     * @date:2014-9-24
     * @reason:客户和联系人关联模块  选择客户 快速创建
     * @description:
     */
    if(window.opener.document.getElementById('bemodulestatus') != undefined && window.opener.document.getElementById('bemodulestatus').value == 'YES')
    {
        if(window.opener.document.EditView.contact_id != undefined)
        {
            var contact_id = window.opener.document.EditView.contact_id.value;
        }
        var frommodule = window.opener.document.EditView.module.value;
        window.opener.onClickgetAccountsContactsInfo(account_id,contact_id,frommodule,'EditView');
    }
   /**
	*@author:andy
	*@data:20141027
	*@reason:选择客户带出联系人，及相关字段信息
	*@version:v5.8
	*/
	if(window.opener.document.EditView.contacts_name != undefined && window.opener.document.EditView.contact_id != undefined)
	{
		//if(window.opener.document.EditView.contact_id.value == '' || window.opener.document.EditView.contact_id.value == 0)
		//{
			var form=window.opener.document.EditView;
			var frommodule = document.getElementById('frommodule').value;
			window.opener.customerintocontact(account_id,form,frommodule,'Accounts');//带入该客户的联系人
		//}
	}
}

//added by rdhital/Raju for emails
function submitform(id){
		document.massdelete.entityid.value=id;
		document.massdelete.submit();
}	

function searchMapLocation(addressType)
{
        var mapParameter = '';
        if (addressType == 'Main')
        {
		if(fieldname.indexOf('bill_street') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_street')]))
	                        mapParameter = document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_street')]).innerHTML+' ';
		}
                if(fieldname.indexOf('bill_city') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_city')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_city')]).innerHTML+' ';
		}
		if(fieldname.indexOf('bill_state') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_state')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_state')]).innerHTML+' ';
		}
                if(fieldname.indexOf('bill_country') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_country')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_country')]).innerHTML+' ';
		}
                if(fieldname.indexOf('bill_code') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_code')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('bill_code')]).innerHTML+' ';
		}
        }
        else if (addressType == 'Other')
        {
		if(fieldname.indexOf('ship_street') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_street')]))
                        	mapParameter = document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_street')]).innerHTML+' ';
		}
                if(fieldname.indexOf('ship_city') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_city')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_city')]).innerHTML+' ';
		}
                if(fieldname.indexOf('ship_state') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_state')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_state')]).innerHTML+' ';
		}
		if(fieldname.indexOf('ship_country') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_country')]))
                        	mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_country')]).innerHTML+' ';
		}
                if(fieldname.indexOf('ship_code') > -1)
		{
			if(document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_code')]))
				mapParameter = mapParameter + document.getElementById("dtlview_"+fieldlabel[fieldname.indexOf('ship_code')]).innerHTML+' ';
		}

        }
	mapParameter = removeHTMLFormatting(mapParameter);
	window.open('http://maps.google.com/maps?q='+mapParameter,'goolemap','height=450,width=700,resizable=no,titlebar,location,top=200,left=250');
}
//javascript function will open new window to display traffic details for particular url using alexa.com
function getRelatedLink()
{
	var param='';
	param = getObj("website").value;
	window.open('http://www.alexa.com/data/details/traffic_details?q=&url='+param,'relatedlink','height=400,width=700,resizable=no,titlebar,location,top=250,left=250');
}

/*
* javascript function to populate fieldvalue in account editview
* @param id1 :: div tag ID
* @param id2 :: div tag ID
*/
function populateData(id1,id2)
{
	document.EditView.description.value = document.getElementById('summary').innerHTML;
	document.EditView.employees.value = getObj('emp').value;
	document.EditView.website.value = getObj('site').value;
	document.EditView.phone.value = getObj('Phone').value;
	document.EditView.fax.value = getObj('Fax').value;
	document.EditView.bill_street.value = getObj('address').value;
	
	showhide(id1,id2);
}
/*
* javascript function to show/hide the div tag
* @param argg1 :: div tag ID
* @param argg2 :: div tag ID
*/
function showhide(argg1,argg2)
{
        var x=document.getElementById(argg1).style;
	var y=document.getElementById(argg2).style;
        if (y.display=="none")
        {
                y.display="block"
		x.display="none"

        }
}

// JavaScript Document

if (document.all) var browser_ie=true
else if (document.layers) var browser_nn4=true
else if (document.layers || (!document.all && document.getElementById)) var browser_nn6=true
/*
edit:can
reason:7466: 客户帐套：客户单据字段设置为唯一性，结果保存时，程序没有判断，直接保存成功，希望修正。(数据库找刘锁)。
*/
function AccountgetObj(n,d) {
  var p,i,x;
   
  if(!d)d=document;
  if((p=n.indexOf("?"))>0&&parent.frames.length) {d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all)x=d.all[n];
  for(i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++)  x=getObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n);
 
   if(x==undefined)
   {
    x=document.getElementById(n);
   }
  return x;
}


function findPosX(obj) {
        var curleft = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent) { curleft += obj.offsetLeft; obj = obj.offsetParent;}
        }
        else if (document.layers) { curleft += obj.x; }
        return curleft;
}


function findPosY(obj) {
        var curtop = 0;
        if (document.getElementById || document.all) {
                while (obj.offsetParent) { curtop += obj.offsetTop; obj = obj.offsetParent; }
        }
        else if (document.layers) {curtop += obj.y;}
        return curtop;
}

ScrollEffect = function(){ };
ScrollEffect.lengthcount=202;
ScrollEffect.closelimit=0;
ScrollEffect.limit=0;


function just(){
        ig=getObj("company");
        if(ScrollEffect.lengthcount > ScrollEffect.closelimit ){closet();return;}
        ig.style.display="block";
        ig.style.height=ScrollEffect.lengthcount+'px';
        ScrollEffect.lengthcount=ScrollEffect.lengthcount+10;
        if(ScrollEffect.lengthcount < ScrollEffect.limit){setTimeout("just()",25);}
        else{ getObj("innerLayer").style.display="block";return;}
}

function closet(){
        ig=getObj("company");
        getObj("innerLayer").style.display="none";
        ScrollEffect.lengthcount=ScrollEffect.lengthcount-10;
        ig.style.height=ScrollEffect.lengthcount+'px';
        if(ScrollEffect.lengthcount<20){ig.style.display="none";return;}
        else{setTimeout("closet()", 25);}
}


function fnDown(obj){
        var tagName = document.getElementById(obj);
        document.EditView.description.value = document.getElementById('summary').innerHTML;
        document.EditView.employees.value = getObj('emp').value;
        document.EditView.website.value = getObj('site').value;
        document.EditView.phone.value = getObj('Phone').value;
        document.EditView.fax.value = getObj('Fax').value;
        document.EditView.bill_street.value = getObj('address').value;
        if(tagName.style.display == 'none')
                tagName.style.display = 'block';
        else
                tagName.style.display = 'none';
}

function set_return_todo(product_id, product_name) {
        window.opener.document.createTodo.task_parent_name.value = product_name;
        window.opener.document.createTodo.task_parent_id.value = product_id;
}
//When changing the Account Address Information  it should also change the related contact address.
function checkAddress(form,id)
{
		var url='';
		if(typeof(form.bill_street) != 'undefined')
     			url +="&bill_street="+form.bill_street.value;
		if(typeof(form.ship_street) != 'undefined')
     			url +="&ship_street="+form.ship_street.value;
		if(typeof(form.bill_city) != 'undefined')
    			url +="&bill_city="+form.bill_city.value;
		if(typeof(form.ship_city) != 'undefined')
     			url +="&ship_city="+form.ship_city.value;
		if(typeof(form.bill_state) != 'undefined')
     			url +="&bill_state="+form.bill_state.value;
		if(typeof(form.ship_state) != 'undefined')
     			url +="&ship_state="+form.ship_state.value;
		if(typeof(form.bill_code) != 'undefined')
    			url +="&bill_code="+ form.bill_code.value;
		if(typeof(form.ship_code) != 'undefined')
			url +="&ship_code="+ form.ship_code.value;
		if(typeof(form.bill_country) != 'undefined')
			url +="&bill_country="+form.bill_country.value;
		if(typeof(form.ship_country) != 'undefined')
			url +="&ship_country="+form.ship_country.value;
		if(typeof(form.bill_pobox) != 'undefined')
			url +="&bill_pobox="+ form.bill_pobox.value;
		if(typeof(form.ship_pobox) != 'undefined')
			url +="&ship_pobox="+ form.ship_pobox.value;

      		url +="&record="+id;		
	
		$("status").style.display="inline";
                        new Ajax.Request(
                              'index.php',
                                {queue: {position: 'end', scope: 'command'},
                                        method: 'post',
                                        postBody:"module=Accounts&action=AccountsAjax&ajax=true&file=AddressChange"+url,
                                        onComplete: function(response) {
						if(response.responseText  == 'address_change')
                                        	{
                                            		if(confirm(alert_arr.WANT_TO_CHANGE_CONTACT_ADDR) == true)
								{
									form.address_change.value='yes';
									form.submit();	
								}
								else
								{	
	                                                                form.submit();
								}
						}
						else
						{
							form.submit();	
						}
                      			}
			}
                        );

}

function showid(idname){
    var isIE = (document.all) ? true : false;
    var isIE6 = isIE && ([/MSIE (\d)\.0/i.exec(navigator.userAgent)][0][1] == 6);
    var newbox=document.getElementById(idname);
    newbox.style.zIndex="9999";
    newbox.style.display="block"
    newbox.style.position = !isIE6 ? "fixed" : "absolute";
    newbox.style.top =newbox.style.left = "50%";
    newbox.style.marginTop = - newbox.offsetHeight / 2 + "px";
    newbox.style.marginLeft = - newbox.offsetWidth / 2 + "px";  
    var layer=document.createElement("div");
    layer.id="layer";
    layer.style.width=layer.style.height="100%";
    layer.style.position= !isIE6 ? "fixed" : "absolute";
    layer.style.top=layer.style.left=0;
    layer.style.backgroundColor="#000";
    layer.style.zIndex="9998";
    layer.style.opacity="0.6";
    document.body.appendChild(layer);
    var sel=document.getElementsByTagName("select");
    for(var i=0;i<sel.length;i++){        
        sel[i].style.visibility="hidden";
    }
    function layer_iestyle(){      
        layer.style.width=Math.max(document.documentElement.scrollWidth, document.documentElement.clientWidth)+ "px";
        layer.style.height= Math.max(document.documentElement.scrollHeight, document.documentElement.clientHeight) +"px";
    }
    function newbox_iestyle(){      
        newbox.style.marginTop = document.documentElement.scrollTop - newbox.offsetHeight / 2 + "px";
        newbox.style.marginLeft = document.documentElement.scrollLeft - newbox.offsetWidth / 2 + "px";
    }
    if(isIE){layer.style.filter ="alpha(opacity=60)";}
    if(isIE6){  
        layer_iestyle()
        newbox_iestyle();
        window.attachEvent("onscroll",function(){                              
            newbox_iestyle();
        })
        window.attachEvent("onresize",layer_iestyle)          
    }  
    layer.onclick=function(){
        //newbox.style.display="none";
        //layer.style.display="none";
        for(var i=0;i<sel.length;i++){
        sel[i].style.visibility="visible";
    }}
}
function hiddenid(idname)
{
    var newbox=document.getElementById(idname);
    var sel=document.getElementsByTagName("select");
    var layer=document.getElementById('layer');
    newbox.style.display="none";
    layer.style.display="none";
    document.body.removeChild(layer);
    for(var i=0;i<sel.length;i++){
        sel[i].style.visibility="hidden";
    }
}
/*
更新操作
edit:can
date:20131119
reason:客户共享(V3.1)
*/
function AccountShare(obj,id)
{
    $("status").style.display="inline";
      new Ajax.Request("index.php",
    	{
    		queue:
            {
    			position:"end",
    			scope:"command"
    		},
    		method:"post",
    		postBody:"module=Accounts&action=AccountAllView&id="+id,
    		onComplete:function (response) {
    		    var results=response.responseText.split('##SUCCESS##');
               
                $('divAccountShare').innerHTML=results[1];
                
                /**
                 *@edit:andy 
                 *@date:
                 *@reason:待使用统一遮罩层
                 *@version:
                 */
                fnvshobj(obj,'divAccountShare');
               
                $("status").style.display="none";
                
              }                
    		
    	});
}
/*
更新操作
edit:can
date:20131119
reason:客户共享(V3.1)
*/
function select_all(checkel,groupname){
    var checkel=$(checkel);
    var thechecked=checkel.checked;
    var allcheckvals=$$('.StepUserClass');
    for(var i=0;i<allcheckvals.length;i++){
    var el=allcheckvals[i];
    var groupnameattr=el.getAttribute("groupname");
    if(groupnameattr==groupname)
    {
       el.checked=thechecked; 
      
    }
   
     
    }
} 

function SaveAccountShare(obj)
{
    var form=document.forms['frmAccountShare'];
    /*
    更新操作
    edit:can
    date:20131130
    reason:5785: 客户单据查看界面，点击”共享“按钮，在“共享”窗口中，若没有勾选任何用户或角色，应该也可以保存。
    */
   /* for(var i=0;i<form.elements.length;i++)
    {
         if(form.elements[i].name=='owners[]'&&form.elements[i].checked==true)
         {
            
            form.submit();
            return true;
         }
    }*/
    
    form.submit();
    return false;
}

/**
 * 点击订单加载订单详细信息
 * @project PROT159 新帆项目：鼎捷订单接口
 * @author Tujt 2015-01-06
 */
var display_index = 0;
function dingjieSalesView(fldkey,fldval,salestype,accountname){
	var urldata = 'module=Accounts&action=AccountsAjax&file=dingjieSalesView';
	urldata += '&fldkey='+fldkey+'&fldval='+fldval+'&salestype='+salestype;
	urldata += '&accountname='+accountname;
	if(display_index > 0){
		urldata += '&display_index='+display_index;
	}
	RequestAjax(urldata,function(rest){
		if('' == rest) return false;
		if(rest.indexOf('###NO###') > -1){
			return false;
		}
		if(rest.indexOf('###SUCCESS###') > -1){
			var results = rest.split("###SUCCESS###");
			var dingjieobj = document.getElementById('dingjieSalesdiv');
			sethtml(dingjieobj,results[1]);
			if(display_index > 0){
				ld('#salesdingjieTab li a[index='+display_index+']').click();
				//display_index = 0;
			}
			fnvshobj('','dingjieSalesdiv');
			dingjieobj.style.marginTop = '-300px';
			//绑定页签事件
			var index;
			ld('#salesdingjieTab li a').on('click',function(event){
				index = ld(this).attr('index');var i=1;
				ld('#salesdingjieTab li a').each(function(){
					if(index == ld(this).attr('index')){
						ld(this).attr('class','On');
						ld('#transaction_'+i).css('display','');
					}else{
						ld(this).attr('class','');
						ld('#transaction_'+i).css('display','none');
					}
					++ i;
				});
				display_index = index;
			});
		
			//绑定小编辑事件
			//光标移入显示小编辑
			ld('.salesLast tr td.sales_edit_td').on('mouseenter',function(){
				if('edit' == ld(this).attr('mode')){
					if('sales_edit' == ld(this).find('.sales_edit').attr('class'))
						return false;
					ld(this).find('span.sales_link a').removeClass('ui-hide');
				}
			});
			//光标移出隐藏小编辑
			ld('.salesLast tr td.sales_edit_td').on('mouseleave',function(){
				if('edit' == ld(this).attr('mode')){
					ld(this).find('span.sales_link a').addClass('ui-hide');
				}
			});
			//小编辑点击事件
			ld('.salesLast tr td.sales_edit_td span.sales_link a').on('click',function(){
				//ld(this).parent().parent().find('.sales_edit').removeClass('ui-hide');
				//ld(this).parent().parent().find('.sales_view').addClass('ui-hide');
				//ld(this).addClass('ui-hide');
				ld('#dingjieSalesdiv').find('.sales_edit').addClass('ui-hide');
				ld('#dingjieSalesdiv').find('.sales_view').removeClass('ui-hide');
				ld(this).parent().parent().find('.sales_edit').removeClass('ui-hide');
				ld(this).parent().parent().find('.sales_view').addClass('ui-hide');
				ld(this).addClass('ui-hide');
				return false;
			});
			//取消按钮事件
			ld('.salesLast tr td.sales_edit_td .sales_edit .cancelbtn').on('click',function(){
				ld(this).parent().addClass('ui-hide');
				ld(this).parent().parent().find('.sales_link').removeClass('ui-hide');
				ld(this).parent().parent().find('.sales_view').removeClass('ui-hide');
				return false;
			});
			//保存按钮事件
			var issubmit = 1;
			ld('.salesLast tr td.sales_edit_td .sales_edit .submitbtn').on('click',function(){
				if(1 != issubmit) return false;
				var updatefld = ld(this).parent().find('input[type=text]').attr('key');
				var updateval = ld(this).parent().find('input[type=text]').val();
				if(trim(updateval) == ''){
					return false;
				}
				var urldata = 'module=Accounts&action=AccountsAjax&file=dingjieSalesView';
				urldata += '&mode=edit&updatefld='+updatefld+'&updateval='+updateval;
				var dingjie_urlfilter = ld('#dingjie_urlfilter').val();
				if('prod' == ld(this).parent().find('input[type=text]').attr('tag')){
					var prodid = ld(this).parent().parent().parent().find('[key=TD003]').attr('val');
					urldata += '&prodid='+prodid;
				}
				urldata += '&'+dingjie_urlfilter;
				issubmit = 2;
				RequestAjax(urldata,function(rest){
					issubmit = 1;
					dingjieSalesView(fldkey,fldval,salestype,accountname);
				});
				return false;
			});
		}
	});
}
/**
更新操作
edit:cdw
date:20131120
reason:客户详细界面群发邮件功能改进
**/
function detailview_email_account_show(module)
{
    //fnvshobj('','Emailedit');
    //document.getElementById('Emailedit').style.display='block';
   // lingdangJS_DialogBox.block();
   var allids=document.forms['DetailView'].record.value;
   $("status").style.display="inline";
          new Ajax.Request
        (
        		'index.php',
        		{
        			queue: {
        				position: 'end',
        				scope: 'command'
        			},
        			method: 'post',
        			postBody:"module="+module+"&action=sendEmailField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids,
        			onComplete: function(response) 
                    {
                    
                        $("status").style.display="none";
                        var results = response.responseText.split('&#&#&#');
                         $("Emailedit").innerHTML=results[1];
                        
                          document.getElementById('Emailedit').style.display = 'block';
                        
                         
                    }
                }
          )
}
		  /**
更新操作
edit:cdw
date:20131120
reason:客户详细界面群发短信功能改进
***/
function detailview_SMS_account_show(type,module)
{
    var allids=document.forms['DetailView'].record.value;
   if(type=='SMS')
    {
         $("status").style.display="inline";
          new Ajax.Request
        (
        		'index.php',
        		{
        			queue: {
        				position: 'end',
        				scope: 'command'
        			},
        			method: 'post',
        			postBody:"module="+module+"&action=sendSMSField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids,
        			onComplete: function(response) 
                    {
                    
                        $("status").style.display="none";
                        var results = response.responseText.split('&#&#&#');
                         $("SMSedit").innerHTML=results[1];
                         document.getElementById('SMSedit').style.display = 'block';
                        
                         
                    }
                }
          )
       
        
    }
    
}
/**
 *edit:cyb
 *date:2016-01-07
 *reason:客户模块相关信息--已购产品下交易历史记录分页跳转。
 **/
function getAccountsBuyProductHistoryEntries_js(start,productid,accountid,database_style)
{
    show_trade_history(start,productid,accountid,database_style);
}
/**
 *edit:cyb
 *date:2015-12-17
 *reason:客户模块相关信息下，已购产品列表中，点击交易历史按钮，弹出交易历史记录。
 *pram:database_style:判断当前属于什么行业。
**/
function show_trade_history(start,productid,accountid,database_style)
{
     
     $("status").style.display="inline";
     lingdangJS_DialogBox.block();//遮罩层  
     var url='module=Accounts&action=AccountsAjax&file=Trade'+database_style+'&accountid='+accountid+'&productid='+productid+'&method=showhistory&start='+start;
        new Ajax.Request
        (
    		'index.php',
    		{
    			queue: {
    				position: 'end',
    				scope: 'command'
    			},
    			method: 'post',
    			postBody:url,
    			onComplete: function(response) 
                {
                    $("TradeHistoryDiv").innerHTML=response.responseText;
                    document.getElementById('TradeHistoryDiv').style.display = 'block';
                     $("status").style.display="none";
                }
            }
        )
}


/**
创建普通客户
**/
function createNormal_Account()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var objparams=new CreatePagePopup.params();
     if(popupobj.type=="listpage")
                objparams.params['refreshpage']='no';
    CreatePagePopup.showpage('Accounts',"&publicaccount=0",objparams);
}
/**
创建公海未分配客户
**/
function createpublic_notallocated()
{
     var popupobj=CrmPopup.getPopupObj("last");
      var objparams=new CreatePagePopup.params();
     if(popupobj.type=="listpage")
                objparams.params['refreshpage']='no';
      CreatePagePopup.showpage('Accounts',"&publicaccount=1",objparams);
}
/**
创建公海已分配
**/
 function createpublic_Allocated()
{
        var popupobj=CrmPopup.getPopupObj("last");
        var objparams=new CreatePagePopup.params();
     
     if(popupobj.type=="listpage")
                objparams.params['refreshpage']='no';
                
                var url = 'module=Accounts&action=EditView&return_action=DetailView&Create=true&publicaccount=2';
                var max_url="module=Accounts&action=AllocateAccount&allocatetype=3&maxaccount=1&ReportHeader=dheader&type=createpage";
                new Ajax.Request(
                   	'index.php',
                    {queue: {position: 'end', scope: 'command'},
                           	method: 'post',
                            async: false,
                            postBody:max_url,
                            onComplete: function(response) {
                               
                                     if(response.responseText.indexOf('error')!='-1')
                                     {
                                        var confirm_str = arrJsPopLabel['HIGHSEASREACHEDCREATE'];
                                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                     }
                                     else
                                     {  
                                       /// var objparams=new CreatePagePopup.params();
                                        CreatePagePopup.showpage('Accounts',"&publicaccount=2",objparams);
                                     }
                                
                                }
                    }
                );
     return false;
}
/**
Liver 2016-12-07 平均分配
**/
function averageDistribution(obj,module,popup_type){    
    //获取要变更的ID
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
                RemindsMsg("","LdPopWidth400px","","yes","","");
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


    //2016-12-02 Liver bug0026267: 服务收费管理：分配弹出层的tips显示错误
    if(module=='ServiceCharge'){
        popup_caption_value = arrJsPopLabel['AVERAGEDISTRIBUTIONSERVICECASHER'];
    }else{
        popup_caption_value = arrJsPopLabel['AVERAGEDISTRIBUTIONASSIGNED'];
    }
    //024943: 分配弹出层是否显示所有用户设置为否 当我数据范围是个人的时候 点击分配还弹出全部用户
    var popup_url = 'module='+module+'&action='+module+'Ajax&file=allocatePop&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&popup_type='+popup_type;
	var popup_header =  '<p>'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'<a class="f-r" href="javascript:;" style="margin-right: 15px;margin-top:-4px;"  onclick="getLinksUrl(\'Accounts\',\'Allocate\',\'averageDistribution\');" >'+arrJsPopLabel['ONLINEHELP']+'</a>&nbsp;&nbsp;<input type="text" class="seniorinput"  id=\'popup_locationdiv\' value=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'>&nbsp;&nbsp;<input class="seniorcheckbox input-btn-align"  type="checkbox" id=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</p>';
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
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    var array_user=cls_ScopePopup.return_obj.return_id.split(",").length;//选取用户的个数
                    if(empty(cls_ScopePopup.return_obj.return_id) || array_user<2){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        var array_user=selected_user.split(",");
                          
                        var urlstring = 'module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
                        urlstring += '&from_module='+module+'&changetype='+popup_type+'&mode='+mode;
                        urlstring += '&select_id='+select_id+'&caterorid='+selected_user+'&excludedRecords='+excludedRecords;
                        new Ajax.Request(
                		'index.php',
                		{
                			queue: {
                				position: 'end',
                				scope: 'command'
                			},
                			method: 'post',
                			postBody:urlstring,
                			onComplete: function(response) {
                				$("status").style.display="none";
                                //fninvshnew(divid);
                                if(response.responseText.indexOf('###REACHMAXCUSTOMER###')>-1){
                                    var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                    return false;
                                }
                                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
                                
                				if(empty(response.responseText)) return false;
                				var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
                				if(ld('input[name=selected_id]').length == 0){//Liver 2016/09/07 去掉&&module!='Documents'，原因是bug0024278: 知识管理明细：更多中点击-更改创建人，确定后，界面显示了更改创建人的提示消息 
                					lingdangJS_DialogBox.block();
                                    
                                    if(module == 'HelpDesk'){
                                        var help_url = window.location.href;
                                        help_url = help_url.replace('&sendtype=yes','');
                                        if(help_url.indexOf('&sendtype=yes')<0 && popup_type=='Allocate'){
                                            help_url += '&sendtype=yes';
                                        }
                                        window.location.href=help_url;
                                        return false;
                                    }
                                    lingdangJS_DialogBox.unblock();
                                    fninvshnew('selectpopup_1');
                                    changeUser.afterOperation(popup_type,selected_user,cls_ScopePopup.return_obj.return_name,module);
                					//window.location.reload();
                                    return false;
                				}
								getJsScript('include/js/ldcrm.base.js',function(){
									resultRemindsMsg(restobj.title.value,"LdPopWidth600px","","yes","",restobj.log.value);
									ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
										fninvshnew('mass_advancer');lingdangJS_DialogBox.unblock();
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
                		});
                    }
                });
            }
		});
	});
}
/*
edit:Liver
date:20161209
reason:  公海客户批量平均分配界面生成
*/
function massDeskHighAvgAllocatetaccount(obj)
{
	//该功能不判断被分配用户的公海客户是否达到上限，是否继续？
  var confirm_str = arrJsPopLabel['thisopreationdoesnotcheckthehignseaquantitylimit'];
  RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);

  //点击确认
  ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        //批量操作条目数控制
        if(!selectchoice())
        {
            return false;
        } 
      var scopepopupobj;//自定义弹出层页面html，绑定事件
        var popup_caption_value = arrJsPopLabel['LBL_AVGDISTRIBUT_HIGHSEAS_JSOP'];//标题
      var module = 'Accounts';
        
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
        
        
      getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
        var methodObj = {'popup_check_inactiveuser':'yes'};
        scopepopupobj =  new ScopePopupObj(methodObj);
            scopepopupobj.popup_caption_value = popup_caption_value;//标题title
        getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
               cls_ScopePopup.prop.popup_module = module;//模块
               cls_ScopePopup.prop.popup_value = '';
               cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=&popuboxp_selecttype=user&ishighseaallocate=yes';
           var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                        var array_Highuser=cls_ScopePopup.return_obj.return_id.split(",").length;
              if(empty(cls_ScopePopup.return_obj.return_id) || array_Highuser<2){
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
                        }else{
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
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
                            //massHighAllocate_Load                        
                massHighAllocate_Load(select_id,2,assigneduserid,assignedusername);
              }
                    });
                }
        });
      });
  });
}
function massHighAllocate_Load(select_options,allocatetype,assigneduserid,assignedusername)
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
    
    var url="module=Accounts&action=cls_avghighallocate_account&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&maxaccount=1&pagepublicaccounttype="+accounttype+"&excludedRecords="+excludedRecords+"&viewname="+viewname+"&SearchScope="+searchScope;
    if(allocatetype==2)
    {
          var userid=assigneduserid;
          //var userid=document.getElementById('assigned_user_id').value;
          url=url+"&userid="+userid+"&assign_name="+assignids+"&id="+idlist;
    }
    new Ajax.Request(
                		'index.php',
                		{
                			queue: {
                				position: 'end',
                				scope: 'command'
                			},
                			method: 'post',
                			postBody:url,
                			onComplete: function(response) {
                           
                				$("status").style.display="none";
                                //fninvshnew(divid);
                                if(response.responseText.indexOf('###REACHMAXCUSTOMER###')>-1){
                                    var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                                    return false;
                                }
                                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
                                
                				if(empty(response.responseText)) return false;
                				var restobj = eval('('+ response.responseText +')')?eval('('+ response.responseText +')'):JSON.parse(response.responseText);
                				if(ld('input[name=selected_id]').length == 0){
                					lingdangJS_DialogBox.block();
                                    lingdangJS_DialogBox.unblock();
                                    fninvshnew('selectpopup_1');
                                    changeUser.afterOperation(popup_type,selected_user,cls_ScopePopup.return_obj.return_name,module);
                					//window.location.reload();
                                    return false;
                				}
								getJsScript('include/js/ldcrm.base.js',function(){
									var divobj = createElementDivs('mass_advancer');//创建DIV
									ld(divobj).find('.D_pop_tit .D_ptita').html(restobj.title.value);
									ld('#mass_advancercontent').html(restobj.log.value);
									ld('#mass_advancer .D_pbtn .D_pbtncancel').css('display','none');
									ld('#mass_advancer .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
										fninvshnew('mass_advancer');lingdangJS_DialogBox.unblock();
										if(ld('input[name=selected_id]').length > 0){
											$('basicsearchcolumns').innerHTML = '';
											$('allselectedboxes').value='';
											$('excludedRecords').value='';
											getListViewEntries_js('Accounts',restobj.start.value);//刷新页面
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
                		});
    
}
 //根据客户带出产品的最近一次价格  含税、未税
var getAccountLastPrice = function(accountid,frommodule){
	var currency_id = 1;
	if(document.getElementById('inventory_currency') != undefined){
		var inventory_currency = document.getElementById('inventory_currency');
		currency_id = inventory_currency.value;
	}
	if(ld('#rowcnt') != undefined){
		var rowcnt = ld('#rowcnt').val();
		var pro_arr = [];
		for(var i=1; i <= rowcnt; i++){
			if(ld('#hdnProductId'+i) != undefined){
				var productid = ld('#hdnProductId'+i).val();
				pro_arr[i-1] = productid;
			}
		}
		if(pro_arr.length >= 1){
			var pro_str = pro_arr.join(',');
			ld.ajax('index.php?module=Accounts&action=AccountsAjax&file=getAccountLastPrice&accountid='+accountid+'&frommodule='+frommodule+'&productids='+pro_str+'&currency_id='+currency_id)
			.done(function(response){
				if(response != null && response != 'null'){
					var response = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
					ld.each(response, function (productid, obj) {
						for(var i=1; i <= rowcnt; i++){
							var proid = ld('#hdnProductId'+i).val();
							if(proid == productid){
								ld('#lastlistprice'+i).val(obj.lastlistprice);
								ld('#span_lastlistprice'+i).html(obj.lastlistprice);
								ld('#lasttaxprice'+i).val(obj.lasttaxprice);
								ld('#span_lasttaxprice'+i).html(obj.lasttaxprice);
							}
						}
					});
				}
			})
		}
	}
	return false;
}

//查看客户上下级关系
var getAccountHierarchy = function(accountid,contactstatus){
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var popup_account_url = 'module=Users&action=UsersAjax&file=viewaccountinfo&popup_scopetype=private&popup_module=Accounts&accountid='+accountid+'&popup_selecttype=user';
	var popup_searchTextDiv_html = '<div id=\'popup_search_div\' style=\'padding-left:59px;display: block;position: absolute;top: 104px;\'><div class=\'view-search\' ></div></div>';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj('Accounts');
        scopepopupobj.popup_caption_value = arrJsPopLabel['Viewupperandlowerrelations'];//标题title
		scopepopupobj.popup_searchTextDiv = popup_searchTextDiv_html;
		scopepopupobj.popup_header = '<div style="text-align:left;">';
		if(contactstatus == 'yes'){
			scopepopupobj.popup_header +=  '<input style="margin-top:-2px;" class="seniorcheckbox" type="checkbox" id=\'viewaccount_contacts\' >' + 
                                    '<span id="viewaccount_contacts_span">'+arrJsPopLabel['Displaycontacts']+'</span>';
		}
		scopepopupobj.popup_header += '</div>';
                                   
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = 'Accounts';//模块
		   cls_ScopePopup.prop.popup_url = popup_account_url;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		   ld('#'+cls_ScopePopup.popup_divid).attr('class','D_pop_box LdPopWidth500px ui-popup');
		   ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').hide();
		   ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').val(arrJsPopLabel['LBL_CLOSE']);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
					return false;
                });
            }
		});
	});
}


/*
edit:can
date:20131010
reason:客户编辑界面首要联系人逻辑判断
*/
function AccontContactValidate()
{

    var form=document.forms['EditView'];
    if(form.lastname==undefined)
    {
         return true;
    }
   

    if(trim(form.lastname.value)==""&&((form.firstname!=undefined&&trim(form.firstname.value)!="")||trim(form.title.value)!=""
        ||(form.mobile!=undefined&&trim(form.mobile.value)!="")||(form.email!=undefined&&trim(form.email.value)!="")||

        (form.qq!=undefined&&trim(form.qq.value)!="")))
    {
        //首要联系人姓名不能为空！
        var confirm_str = arrJsPopLabel['CONTACTNAMECANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.lastname.focus();
        return false;
    }
 
    /*
    edit:can
    date:20140211
    reason:6698: 客户，新增客户界面，首要联系人列，没有对邮箱格式进行限制，如图：
    */
    
    var re=new RegExp(/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/);
    
     if(form.email!=undefined&&trim(form.email.value)!=""&&!re.test(trim(form.email.value)))
    {
        //首要联系人Email格式错误
        var confirm_str = arrJsPopLabel['CONTACTEMAILFORMATERROR'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.email.focus();//add lmx 20140225   0007200 客户新增界面，首要联系人列表，邮件格式设置出错时，点击保存，弹出提示信息，点击确定，光标没有定位；
        return false;
    }
     
    return true;
}

// @edit:dong @date:2020/08/04 @reason: 移动到listview.js
/*
var location_lat = 0;
var location_lng = 0;
function getLocationAddress(fldname,mode){
	
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	//默认省份
	var bill_state = '';
	var bill_city = '';
	if(mode == 'edit'){
		bill_state = CrmPopup.findHtmlobj(divid,'bill_state').val();
		bill_city = CrmPopup.findHtmlobj(divid,'bill_city').val();
	}else if(mode == 'detail'){
		bill_state =trim(ld('#dtlview_bill_state font').html());
		bill_city = trim(ld('#dtlview_bill_city font').html());
	}
	//定位地址
	var address  = '';
	if(!empty(fldname) && CrmPopup.findHtmlobj(divid,fldname).val() != undefined){
		address = CrmPopup.findHtmlobj(divid,fldname).val();
	}
	if(empty(address) && (!empty(bill_state) || !empty(bill_city))){
		address = bill_state + bill_city;
	}
	//详情页
	if(mode == 'detail' && document.getElementById('dtlview_locationaddress') != undefined && document.getElementById('dtlview_locationaddress').innerHTML != ''){
		address = document.getElementById('dtlview_locationaddress').innerHTML;
	}
	var module_mod = '';
	if(mode == 'detail' || mode == 'edit'){
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
	}else{
		var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint_list=yes";	//多、列表
		module_mod = 'select';
	}
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
						if(empty(module_mod)){
							location_lat = restobj['entries']['lat'];
							location_lng = restobj['entries']['lng'];
							//创建script标签
							var script = document.createElement("script");
							//设置标签的type属性
							script.type = "text/javascript";
							//设置标签的链接地址
							script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
							//添加标签到dom
							document.body.appendChild(script);
						}else{
							var info = '';
							for(var i in restobj['entries']){
								if(restobj['entries'][i]['address'] != undefined){
									info += '<li state="'+restobj['entries'][i]['state']+'" city="'+restobj['entries'][i]['city']+'" district="'+restobj['entries'][i]['district']+'" address="'+restobj['entries'][i]['address']+'" point="'+restobj['entries'][i]['point']+'" country="'+restobj['entries'][i]['country']+'">';
									info += '<span>'+restobj['entries'][i]['address']+'</span>';
									info += '</li>';

								}
							}

							CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
							CrmPopup.findHtmlobj(divid,'search_location_address').show();

							  ld('#'+divid).unbind('click').on('click',function(){
								CrmPopup.findHtmlobj(divid,'search_location_address').hide();
							  })


							ld('#search_location_address').find('li').each(function() {
								ld(this).click(function() {
									var district = ld(this).attr('district');
									var state = ld(this).attr('state');
									var city = ld(this).attr('city');
									var address = ld(this).attr('address');
									var point = ld(this).attr('point');
									var country = ld(this).attr('country'); 
									var point_arr = point.split(',');
									location_lat = point_arr[0];
									location_lng = point_arr[1];
									city = trim(city.replace('市',''));
									if(CrmPopup.findHtmlobj(divid,'bill_street').val() != undefined && CrmPopup.findHtmlobj(divid,'bill_street').val() != ''){
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['doyouuselocationaddress']);
										ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
											scriptMap(address,district,city,state,country)
										});
										ld('input[class="D_pbtncancel"]').unbind('click').on('click',function(){
										  CrmPopup.findHtmlobj(divid,'search_location_address').hide();
										});
									}else{
										CrmPopup.findHtmlobj(divid,'locationaddress').val(address);
										scriptMap(address,district,city,state,country)
									}
								})
							})

						}
					}else{
						var info = '<li><span>'+arrJsPopLabel['thelocationaddress']+'</span></li>';
						CrmPopup.findHtmlobj(divid,'search_location_address').html(info);
						CrmPopup.findHtmlobj(divid,'search_location_address').show();
					}
					
				}
			}
	  )
}
//加载地图
function scriptMap(address,district,city,state,country){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	CrmPopup.findHtmlobj(divid,'bill_street').val(address);
	if(CrmPopup.findHtmlobj(divid,'bill_city').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_city').val(city);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_city').html(city);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_state').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_state').val(state);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_state').html(state);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_area').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_area').val(district);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_area').html(district);
	}
	if(CrmPopup.findHtmlobj(divid,'bill_country').val() != undefined){
		CrmPopup.findHtmlobj(divid,'bill_country').val(country);
		CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_bill_country').html(country);
	}
	CrmPopup.findHtmlobj(divid,'search_location_address').hide();
	//创建script标签
	var script = document.createElement("script");
	//设置标签的type属性
	script.type = "text/javascript";
	//设置标签的链接地址
	script.src = "https://map.qq.com/api/js?v=2.exp&callback=initMap&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X";
	//添加标签到dom
	document.body.appendChild(script);
}
//加载地图api后的回调函数
function initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	ld("#"+divid+" [name=location_map_td]").show();
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	 var map = new qq.maps.Map(ld("#"+divid+" [name=container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}

function enlarge_map(address){
	if(empty(address)){
		var popupobj=CrmPopup.getPopupObj("last");
		var divid=popupobj.divid;
		address = CrmPopup.findHtmlobj(divid,'locationaddress').val();
	}
	var urlajax = "module=Accounts&action=AccountsAjax&file=TencentMap&address="+encodeURIComponent(address)+"&getpoint=yes";	//单
	new Ajax.Request
	(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:urlajax,
				onComplete: function(response) 
				{
					var results = trim(response.responseText);
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					if(restobj != ''){
						location_lat = restobj['entries']['lat'];
						location_lng = restobj['entries']['lng'];
						var table_html = '<div name="big_container" id="big_container" style="height:500px;"></div>';
						resultRemindsMsg(arrJsPopLabel['ACCOUNTSMAP'],"LdPopWidth850px","","yes","",table_html);
						//创建script标签
						var script = document.createElement("script");
						//设置标签的type属性
						script.type = "text/javascript";
						//设置标签的链接地址
						script.src = "https://map.qq.com/api/js?v=2.exp&key=P4MBZ-SOX3P-AKJD2-LFRF5-LYRYK-25F5X&callback=Big_initMap";
						//添加标签到dom
						document.body.appendChild(script);
					}
				}
			}
	  )
}
//
function Big_initMap(){
	var popupobj=CrmPopup.getPopupObj("last");
	var divid=popupobj.divid;
	var center = new qq.maps.LatLng(location_lat,location_lng);
	//定义map变量 调用 qq.maps.Map() 构造函数   获取地图显示容器
	var map = new qq.maps.Map(ld("#"+divid+" [name=big_container]")[0], {
		center: center,      // 地图的中心地理坐标。
		zoom:15,                                           // 地图的中心地理坐标。
		disableDefaultUI: true
	});
	//创建标记
	var anchor = new qq.maps.Point(6, 6),
	size = new qq.maps.Size(23, 38),
	origin = new qq.maps.Point(0, 0),
	icon = new qq.maps.MarkerImage('themes/images/location.png', size, origin, anchor);
	var marker = new qq.maps.Marker({
		icon: icon,
		position: center,
		map: map
	});
}*/
