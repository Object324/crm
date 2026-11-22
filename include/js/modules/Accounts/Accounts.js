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
/*function convertaccount(start,recordid,customtype)
{
	massConvert_Load(recordid+';',customtype);
	return false;*/
	/*var searchScope='',customtypename='',viewname='';
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
    */
/*}*/
/*
edit:can
date:20130727
reason:延期界面
*/
function DeskDelayaccount(start,recorid,obj,divid)
{
	if(document.massdelete.publicaccounttype!=undefined)
        var  customtypename=document.massdelete.publicaccounttype.value; 
    else
        var  customtypename='';
    var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var viewname=document.getElementById("viewname").value;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Accounts',"",'none',"","");
	crmPopupobj.prevshow();
	ld.ajax({
		url: "index.php?module=Accounts&action=AccountsAjax&file=DeskDelayAccount&parenttab=Parent Accounts&record="+recorid+"&pagepublicaccounttype="+customtypename+"&SearchScope="+searchScope+"&viewname="+viewname,
		type: 'POST',
		data:'',
		dataType:'json',
		async: true,//
		timeout: 5000,
		success: function(data)
		{
			if(data.code==1)
			{
				crmPopupobj.setParams(data.result.title,'',"","LdPopWidth600px",'Accounts',"","","","");
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
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        document.DelayAccount.txtdelay.focus();
        
        return false;
     }
     if(isNaN(document.DelayAccount.txtdelay.value))
     {
        //非法延期天数！
        var confirm_str = arrJsPopLabel['ILLEGALPOSTPONEDFEWDAYS'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        document.DelayAccount.txtdelay.focus();
        return false;
     }
     if(document.DelayAccount.txtdelay.value<=0||document.DelayAccount.txtdelay.value.split(".").length>1)
     {
        //延期天数只能录入正整数！
        var confirm_str = arrJsPopLabel['POSTPONEDFEWDAYPOSITIVEINT'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
        document.DelayAccount.txtdelay.focus();
        return false;
     }
    var data = new FormData(ld(".delayaccount_form")[0]);
	var popupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj = CrmPopup.getPopupObj('lastprev');
	var record = ld("#"+popupobj.divid+" [name=record]").val();
	ld('#rptContentLoading').show();
	ld.ajax({
		type: 'POST',
		dataType: 'json',
		processData: false, // 告诉jquery不要处理数据
		contentType: false, // 告诉jquery不要设置contentType
		data: data,
		url: 'index.php?module=Accounts&action=AccountsAjax&file=DelayAccount',
		success: function(json, textStatus, xhr) {
			ld('#rptContentLoading').hide();
			popupobj.CancelEvent();
			var tmparra=new Array();
			tmparra.push(record);
			var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
			//新增刷新列表
			var refreshlistmodules = new Array('Accounts');
			tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
		},
		error: function(xhr, textStatus, errorThrown) {
			//alert(2);
		}
	  })
		  return false;
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
	if(document.massdelete.publicaccounttype!=undefined)
        var  accounttype=document.massdelete.publicaccounttype.value; 
    else
        var  accounttype='';
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Accounts',"",'none',"","");
	crmPopupobj.prevshow();
	crmPopupobj.setParams(arrJsPopLabel['RELEASE'],ReleaseaccountSubmit,"","LdPopWidth600px",'Accounts',"",arrJsPopLabel['CONFIRME'],"",arrJsPopLabel['CANCEL']);
	var  shtml = '<form name="formreleasaccount" method="post">';
	shtml += '<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">';
	shtml += '<input type="hidden" name="record" id = "record" value="'+recordid+'">';
	shtml += '<tr><td class="ld-form-item-label">';
	shtml += '<span style="color: red;">*</span>'+arrJsPopLabel['RELEASEACCOUNTTREASON'];
	shtml += '</td><td class="ld-form-item-content">';
	shtml += '<textarea style="height: 90px;resize: none;" class="ld-textarea-inner" name="releaseAccountReasons"></textarea>';
	shtml += '</td></tr>';
	shtml += '</table>';
	shtml += '</form>';
	
	crmPopupobj.show(shtml);

	return false;
}

var ReleaseaccountSubmit = function(){
	var  popupobj=CrmPopup.getPopupObj("last");
    var prevpopupobj = CrmPopup.getPopupObj('lastprev');
	var releaseAccountReasons = CrmPopup.findHtmlobj(popupobj.divid,'releaseAccountReasons').val();
	if(trim(releaseAccountReasons) == ''){
		var confirm_str = ReleanAccountReason+arrJsPopLabel['CANOTEMPTY'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		CrmPopup.findHtmlobj(popupobj.divid,'releaseAccountReasons').focus();
		return false;
	}else{
		var   searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
		var viewname=document.getElementById("viewname").value;
		if(document.massdelete.publicaccounttype!=undefined)
			var  accounttype=document.massdelete.publicaccounttype.value; 
		else
			var  accounttype='';
		var recordid = CrmPopup.findHtmlobj(popupobj.divid,'record').val();
		//alert("index.php?module=Accounts&record="+recordid+"&pagepublicaccounttype="+accounttype+"&action=ReleaseAccount&SearchScope="+searchScope+"&viewname="+viewname);
		//return false;
		ldAjaxHtmlNoProgress("index.php?module=Accounts&record="+recordid+"&pagepublicaccounttype="+accounttype+"&action=AccountsAjax&file=ReleaseAccount&SearchScope="+searchScope+"&viewname="+viewname+"&releaseAccountReasons="+releaseAccountReasons
        ,{},function (results) {
			// getListViewEntries_js('Accounts', results);//刷新页面
			cancelCrmPopup();
            var tmparra=new Array();
                tmparra.push(Allocatetaccount.obj.recordid);
			var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
			//新增刷新列表
			var refreshlistmodules = new Array('Accounts');
			tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
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
        RemindsMsg("","LdPopWidth400px","","yes","yes","");
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
	// confirmMassrelease(select_options);
}
//批量释放
function confirmMassrelease(select_options){
    var  accounttype=document.massdelete.publicaccounttype.value;
    var gstart='';
	//edit:duan 20231218 分页组件优化，获取当前页数修改
    var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    var listviewpaginationobj = popupobj.listviewpaginationobj;
    if(!empty(listviewpaginationobj)){
        gstart="&start="+listviewpaginationobj.currentpage;
    }else{
        gstart="&start=1";
    }
    /*
    if(document.forms['massdelete'].pagenum!=undefined)
    {
        gstart="&start="+document.forms['massdelete'].pagenum.value;
    }
    else
    {
        gstart="&start="+document.forms['massdelete'].pagenum[0].value;
    }*/
    var viewname=document.getElementById("viewname").value;
    var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var excludedRecords = $('excludedRecords').value;

    var html = '<div id="ReleanseAccountDiv">' +
        '    <form name="formreleasaccount" method="post">' +
        '        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">' +
        '            <tbody>' +
        '            <tr>' +
        '                <td class="ld-form-item-label">' +
        '                    <font color="red">*</font>' + arrJsPopLabel['RELEASEACCOUNTTREASON'] +
        '                </td>' +
        '                <td class="ld-form-item-content">' +
        '                    <textarea style="height: 90px;resize: none;" class="ld-textarea-inner" name="releaseAccountReasons"></textarea>' +
        '                </td>' +
        '            </tr>' +
        '            </tbody>' +
        '        </table>' +
        '    </form>' +
        '</div>';
    var release_popupobj = CrmPopup.load(arrJsPopLabel['RELEASE'],'','','LdPopWidth600px',popupobj.module,'',arrJsPopLabel['CONFIRMED'],'',arrJsPopLabel['CANCEL'])
    release_popupobj.show(html);
    var divobj = ld('#'+release_popupobj.divid);
    divobj.find('[name=releaseAccountReasons]').focus();
    //绑定取消按钮  selectall selected_id
    ld('#'+release_popupobj.divid+'_btncancel').unbind("click").bind("click",function(){
        ld.each(ld("[name='selected_id']:checked"),function (index,obj){
            ld(obj).prop('checked',false);
            ld(obj).removeClass('tb-checkbox-selected');
        });
        ld("[name='selectall']").prop('checked',false);//取消全选
        ld("[name='selectall']").removeClass('tb-checkbox-selected');//取消全选
    });

    // 绑定确认按钮
    ld('#'+release_popupobj.divid+'_btnok').unbind("click").bind("click",function(){
        var releaseaccountreason = trim(divobj.find("#ReleanseAccountDiv [name=releaseAccountReasons]").val());
        if (releaseaccountreason != ''){
            release_popupobj.CancelEvent();
            var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
            var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
            var url ="index.php?module=Accounts&action=AccountsAjax&file=MassReleaseAccount"+gstart+"&pool_id="+pool_id;
            //zkt 树结构显示增加条件，获取树结构点击条件
            if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
                url += '&isshowModuleListTree=yes';
            }
            var params = {parenttab:'Parent Accounts',idstring:select_options,pagepublicaccounttype:accounttype,
                SearchScope:searchScope,viewname:viewname,excludedRecords:excludedRecords, releaseAccountReasons:(releaseaccountreason)};
            ldAjaxHtml(url,params,function (response) {
                response = eval('('+ response +')')?eval('('+ response +')'):JSON.parse(response);
                DelProgressObjs();
                if(empty(response)) return false;
                var releaseConvert_popupobj = CrmPopup.load(response.title.value,'','','LdPopWidth600px',popupobj.module,'',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL'])
                var releaseConvert_html = '<div id="releaseConvertcontent" class="pop_remind_content">'+response.log.value+'</div>';
                releaseConvert_popupobj.show(releaseConvert_html);

                ld('#'+releaseConvert_popupobj.divid+'_btncancel').unbind('click').bind('click',function() {
                    ld('#current_page_boxes').val('');//清空所选单据checkbox
                    ld('#allselectedboxes').val('');//清空选择全部参数
                    ld('#selectedboxes').val('');
                    getListViewEntries_js('Accounts', response.start.value);//刷新页面
                });
                ld('#'+releaseConvert_popupobj.divid+'_btnok').unbind('click').bind('click',function() {
                    releaseConvert_popupobj.CancelEvent();
                    ld('#current_page_boxes').val('');//清空所选单据checkbox
                    ld('#allselectedboxes').val('');//清空选择全部参数
                    ld('#selectedboxes').val('');
                    getListViewEntries_js('Accounts', response.start.value);//刷新页面
                });
            })
        } else
        {
            var confirm_str = arrJsPopLabel['RELEASEACCOUNTTREASON']+arrJsPopLabel['CANOTEMPTY'];
            MessagePopup.TipOne_warning(confirm_str);
            divobj.find('[name=releaseAccountReasons]').focus();
            return false;
        }
    });
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
            RemindsMsg("","LdPopWidth400px","","yes","yes","");
			return false;
		}
	}
    return false;
}

function AllocatetaccountDetails(recordid,allocatetype,assigneduserid,assignedusername,join_url=''){
    Allocatetaccount.page_type='detail';
   
    Allocatetaccount(0,recordid,allocatetype,assigneduserid,assignedusername,join_url);
    
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
     if(document.massdelete.publicaccounttype!=undefined)
        Allocatetaccount.obj.pagepublicaccounttype=document.massdelete.publicaccounttype.value; 
     else
        Allocatetaccount.obj.pagepublicaccounttype='';
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
         var popupobj=CrmPopup.getPopupObj("last");
		var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
		var surl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&parenttab=Parent Accounts&record="+Allocatetaccount.obj.recordid+"&allocatetype="+Allocatetaccount.obj.allocatetype+"&start"+Allocatetaccount.obj.start+"&pagepublicaccounttype="+Allocatetaccount.obj.accounttype+"&SearchScope="+Allocatetaccount.obj.searchScope+"&viewname="+Allocatetaccount.obj.viewname+"&pool_id="+pool_id;
		//alert(surl);
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code == 1){
				 var tmparra=new Array();
				tmparra.push(Allocatetaccount.obj.recordid);
				var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
				//服务单保存后刷新服务单的历史记录(查看界面)
				var refreshdetailmodules = new Array('Accounts');
				tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
				if(Allocatetaccount.obj.recordid>0)
				{
					tmpobj.update();//更新界面字段
				}
			}
		})
        //window.location="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&record="+Allocatetaccount.obj.recordid+"&allocatetype="+Allocatetaccount.obj.allocatetype+"&start"+Allocatetaccount.obj.start+"&pagepublicaccounttype="+Allocatetaccount.obj.accounttype+"&SearchScope="+Allocatetaccount.obj.searchScope+"&viewname="+Allocatetaccount.obj.viewname;
    }
    else if(Allocatetaccount.page_type=='detail'&&(Allocatetaccount.obj.allocatetype == 1||Allocatetaccount.obj.allocatetype==3)){
        var surl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&parenttab=Parent Accounts&record="+Allocatetaccount.obj.recordid+"&allocatetype="+Allocatetaccount.obj.allocatetype+"&start"+Allocatetaccount.obj.start+"&pagepublicaccounttype="+Allocatetaccount.obj.accounttype+"&SearchScope="+Allocatetaccount.obj.searchScope+"&viewname="+Allocatetaccount.obj.viewname;
        surl += "&regetpoolid=yes";
        ldAjaxNoProgress(surl,"",function(data){
            if(data.code == 1){
                var tmparra=new Array();
                tmparra.push(Allocatetaccount.obj.recordid);
                var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
                //服务单保存后刷新服务单的历史记录(查看界面)
                var refreshdetailmodules = new Array('Accounts');
                tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
                tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);
                if(Allocatetaccount.obj.recordid>0)
                {
                    tmpobj.update();//更新界面字段
                }
            }
        })
    }
    else
    {
        var tmparra=new Array();
		tmparra.push(Allocatetaccount.obj.recordid);
		var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
		//服务单保存后刷新服务单的历史记录(查看界面)
		var refreshdetailmodules = new Array('Accounts');
		tmpobj.eachrefreshlistbyModules(refreshdetailmodules);
		tmpobj.eachrefreshDetailViewByModules(refreshdetailmodules);
		if(Allocatetaccount.obj.recordid>0)
		{
			tmpobj.update();//更新界面字段
		}
       // window.location="index.php?module=Accounts&action=DetailView&record="+Allocatetaccount.obj.recordid;
    }
   ld('#rptContentLoading').hide();
                                           
}


/*
edit:can
date:20130718
reason:公海客户(allocatetype)2:分配,3:领取
*/
function Allocatetaccount(start,recordid,allocatetype,assigneduserid,assignedusername,join_url='')
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
    var popupobj=CrmPopup.getPopupObj("last");


    var url="module=Accounts&action=AccountsAjax&file=AllocateAccount&record="+Allocatetaccount.obj.recordid+"&allocatetype="+Allocatetaccount.obj.allocatetype+"&maxaccount=1";
    if(popupobj.pagetype == 'listpage'){
        var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
        url+="&pool_id="+pool_id+"&start="+Allocatetaccount.obj.start;
    }
    else if(popupobj.pagetype == DetailViewPage.pagetype||popupobj.pagetype == DetailViewRelation.pagetype){
        url+="&regetpoolid=yes";
    }
    if(Allocatetaccount.obj.allocatetype==2)
    {
        var userid= Allocatetaccount.obj.assigneduserid;
        //var userid=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].value;
        url=url+"&userid="+userid;
         
    }
    ldAjax('index.php?',url, function (data) {
        DelProgressObjs();
        var tmpmsg = data.msg;
        var restobj = data.result;

        if(data.code == -1){
            var results= tmpmsg.split("###error###");
            if(results[1] == 3&&Allocatetaccount.obj.allocatetype==2) //已领取
            {
                confirm_str = arrJsPopLabel['THEHIGHTSEAHASBEENRECEIVERD'];
            }
            else if(results[1]==2&&Allocatetaccount.obj.allocatetype==2)//已分配
            {
                confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
            }
            else if(results[1]=='obtainaccountmsg'&&Allocatetaccount.obj.allocatetype==3)
            {
                confirm_str=results[2];
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
            return false;
        }
        else if(data.code == 1){
            var results=restobj;
            var confirm_str="";

            if(Allocatetaccount.obj.allocatetype==3)//领取的操作按钮
            {
                //confirm_str="确定要领取公海客户:"+results[1]+"？";
                confirm_str=arrJsPopLabel['SUREWANTRECEIVEHIGHSEAS']+results[1]+"？";
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                //确定按钮
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    ldAjax('index.php?',url,function(data){
                        DelProgressObjs();
                        Allocatetaccount.obj.accounttype="NOALLOCATE";
                        Allocatetaccount.obj.re_load();
                    });
                });
            }
            else
            {
                var username=Allocatetaccount.obj.assignedusername;
                var userid=Allocatetaccount.obj.assigneduserid;
                var allotUrl = "module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+Allocatetaccount.obj.recordid+";&allocatetype="+Allocatetaccount.obj.allocatetype+"&start="+Allocatetaccount.obj.start+"&pagepublicaccounttype="+Allocatetaccount.obj.pagepublicaccounttype+"&SearchScope="+Allocatetaccount.obj.searchScope+"&viewname="+Allocatetaccount.obj.viewname+"&username="+encodeURIComponent(username)+"&assign_name="+userid+'&userid='+userid+"&pool_id="+pool_id;
                allotUrl += join_url;
                ldAjax('index.php?',allotUrl,function(data){
                    DelProgressObjs();
                    Allocatetaccount.obj.re_load();
                });
            }
        }else if(data.code == 'validata'){
            MessagePopup.TipOne_warning(data.msg);
        }
    });
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
function massAllocate_Load(select_options,allocatetype,assigneduserid,assignedusername,join_url='')
{
    //230627 wym 公海未分配-批量领取 加载时弹出加载图片
    ld('#rptContentLoading').show();
    var confirm_str="";
    var gstart='';

    //edit:duan 20231218 分页组件优化，获取当前页数修改
    var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    var listviewpaginationobj = popupobj.listviewpaginationobj;
    if(!empty(listviewpaginationobj)){
        gstart="&start="+listviewpaginationobj.currentpage;
    }else{
        gstart="&start=1";
    }
    /*
    if(document.forms['massdelete'].pagenum!=undefined)
    {
        gstart="&start="+document.forms['massdelete'].pagenum.value;
    }
    else
    {
        gstart="&start="+document.forms['massdelete'].pagenum[0].value;
    }*/
    
    var searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    if(document.massdelete.publicaccounttype!=undefined)
        var accounttype=document.massdelete.publicaccounttype.value; 
    else
        var accounttype='';
    var assignids=document.getElementById("assign_name").value;
    var idlist=document.getElementById("allselectedboxes").value; 
    var viewname=document.getElementById("viewname").value;  
   	var excludedRecords = $('excludedRecords').value;
	 //客户公海分配 - 列表
	if(allocatetype == 2 && selectType == 2){
		//select_options = idlist = document.EditView.record.value;
         idlist=select_options;                
	}
    var url="module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&maxaccount=1&excludedRecords="+excludedRecords+"&viewname="+viewname+"&SearchScope="+searchScope;
    //var url="module=Accounts&action=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&maxaccount=1&pagepublicaccounttype="+accounttype+"&excludedRecords="+excludedRecords+"&viewname="+viewname+"&SearchScope="+searchScope;
    if(allocatetype==2)
    {
          var userid=assigneduserid;
          //var userid=document.getElementById('assigned_user_id').value;
          url=url+"&userid="+userid+"&assign_name="+assignids+"&id="+idlist;
    }
	var popupobj=CrmPopup.getPopupObj("last");
	url += '&pool_id=' + ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
	//zkt 树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   url += '&isshowModuleListTree=yes';
	}
    url += join_url;
    ldAjax('index.php?',url, function (data) {
        DelProgressObjs();
        var tmpmsg = data.msg;
        var restobj = data.result;

        if(data.code == -1){
            if(allocatetype==3)//领取
            {
                if(tmpmsg.indexOf("###error###2")!=-1)
                {
                    confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENALLOCATE'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    return false;
                }
                else if(tmpmsg.indexOf("###error###3")!=-1)
                {
                    confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENRECEIVERD_RECEIVER'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    return false;
                }
                else if(tmpmsg.indexOf("###error###")!=-1)
                {
                    //您拥有的公海客户数量已经达到上限，领取失败！
                    confirm_str = arrJsPopLabel['HIGHSEASREACHEDTHELIMITCOLLECT'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    return false;
                }
            }
            if(allocatetype==2)//分配
            {
                if(tmpmsg.indexOf("###error###2")!=-1)
                {
                    confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENALLOCATE_ALLOCATEFAILUR'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                }
                else if(tmpmsg.indexOf("###error###3")!=-1)
                {
                    confirm_str = arrJsPopLabel['PARTTHEHIGHTSEAHASBEENRECEIVERD'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                }
                else if(tmpmsg.indexOf("###error###")!=-1)
                {
                    var username=assignedusername;
                    //var username=document.EditView.assigned_user_id.options[document.EditView.assigned_user_id.options.selectedIndex].text;
                    //拥有的公海客户数量已经达到上限，分配失败！
                    confirm_str = username+arrJsPopLabel['HIGHSEASREACHEDTHELIMITALLOCATION'];
                    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                    return false;
                }
            }
        }
        else if(data.code == 1){
            var results=restobj;
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
                    return false;
                }
                var receiveUrl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&assign_name="+assignids+"&id="+idlist+"&viewname="+viewname;
                //var receiveUrl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&pagepublicaccounttype="+accounttype+"&assign_name="+assignids+"&id="+idlist+"&viewname="+viewname;
                //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
                receiveUrl= cls_encryptyurl.Puyoung_Encryptyurl(receiveUrl,'');
                http_reqfield=createfieldXMLHTTP();
                http_reqfield.open("POST",receiveUrl,false);
                isDuplicate=false;
                http_reqfield.onreadystatechange=setAllocateAccount;
                http_reqfield.setRequestHeader("If-Modified-Since","0");
                http_reqfield.send();
                //点击确认
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    if(isDuplicate == false)
                    {
                        var tmparra=new Array();
                        var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
                        //服务单保存后刷新服务单的历史记录(查看界面)
                        var refreshlistmodules = new Array('Accounts');
                        tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                        //window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;                                        //return true;
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
                    username = encodeURIComponent(username);
                    var assign_name = document.getElementById('assign_name').value;

                    // @edit:liushuai,2021-03-11,reason:【ID1001390】客户模块公海未分配页签批量分配增加进度条
                    var intervalrow = 2; //默认最大分配数为20
                    if (revenuecount > 20){
                        intervalrow = Math.ceil(revenuecount / 10); //向上取整
                    }
                    //duan 2022-2-28 设置批量操作上限20，如果一次性选中的记录条数大于系统设置的批量操作最大条数10倍以上，会导致进度条未生效
                    if(intervalrow >20){
                        intervalrow = 20;
                    }
                    startMassUnallocated(select_options,allocatetype, viewname, userid, username, assign_name, idlist, revenuecount,0, intervalrow, join_url);

                }else{

                    if(confirm(confirm_str))
                    {
                        username=encodeURIComponent(username);
                        var assign_name=document.getElementById('assign_name').value
                        var receiveUrl ="index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
                        //var receiveUrl ="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&pagepublicaccounttype="+accounttype+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
                        //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
                        receiveUrl= cls_encryptyurl.Puyoung_Encryptyurl(receiveUrl,'');
                        http_reqfield=createfieldXMLHTTP();
                        http_reqfield.open("POST",receiveUrl,false);
                        isDuplicate=false;
                        http_reqfield.onreadystatechange=setAllocateAccount;
                        http_reqfield.setRequestHeader("If-Modified-Since","0");
                        http_reqfield.send();
                        if(selectType=1)
                        {
                            var tmparra=new Array();
                            var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
                            //服务单保存后刷新服务单的历史记录(查看界面)
                            var refreshlistmodules = new Array('Accounts');
                            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                            // window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                        }
                        else
                        {
                            ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                                if(isDuplicate == false)
                                {
                                    var tmparra=new Array();
                                    var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
                                    //服务单保存后刷新服务单的历史记录(查看界面)
                                    var refreshlistmodules = new Array('Accounts');
                                    tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                                    //window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                                }
                            });
                        }
                    }
                }
            }
        }else if(data.code == 'validata'){
            RemindsMsg("","LdPopWidth400px","","yes","",tmpmsg);
            return false;
        }
        else{


            return false;
        }
    });
}

// @edit:liushuai,2021-03-11,reason:【ID1001390】客户模块公海未分配页签批量分配增加进度条（将http_reqfield.onreadystatechange的回调函数setAllocateAccount抽离出来和领取逻辑分开）
function startMassUnallocated(select_options,allocatetype, viewname, userid, username, assign_name, idlist, revenuecount, startrow, intervalrow, join_url='') {
    var endrow = startrow+intervalrow;
    if (endrow > revenuecount){
        endrow = revenuecount;
    }
    var receiveUrl = "index.php?module=Accounts&action=AccountsAjax&file=AllocateAccount&parenttab=Parent Accounts&idstring=" + select_options + "&allocatetype=" + allocatetype + gstart + "&viewid=" + viewname + "&userid=" + userid + "&username=" + username + "&assign_name=" + assign_name + "&id=" + idlist;
    receiveUrl += "&startrow="+startrow+"&endrow="+endrow;
    receiveUrl += join_url;

    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    receiveUrl= cls_encryptyurl.Puyoung_Encryptyurl(receiveUrl,'');
    //var receiveUrl ="index.php?module=Accounts&action=AllocateAccount&parenttab=Parent Accounts&idstring="+select_options+"&allocatetype="+allocatetype+gstart+"&viewid="+viewname+"&pagepublicaccounttype="+accounttype+"&userid="+userid+"&username="+username+"&assign_name="+assign_name+"&id="+idlist;
    //alert(receiveUrl);
    http_reqfield = createfieldXMLHTTP();
    http_reqfield.open("POST", receiveUrl, true);
    isDuplicate = false;
    // http_reqfield.onreadystatechange = setAllocateAccount;
    http_reqfield.onreadystatechange = function () {
        if(http_reqfield.readyState == 4  && http_reqfield.status == 200)
        {
            var data =eval('('+ http_reqfield.responseText +')')?eval('('+ http_reqfield.responseText +')'):JSON.parse(http_reqfield.responseText);
            var results=data.result;

            var tmppopupobjobj;
            if(startrow==0)
            {
                tmppopupobjobj=ProgressPopup.load(arrJsPopLabel['BATCHALLOCATION'],"","",500,'Accounts',"","","","");
                tmppopupobjobj.show();
            }
            else{
                tmppopupobjobj=CrmPopup.getPopupObj('last');
            }

            var maxrows=parseInt(results[4]);
            var percent=parseInt(((startrow+intervalrow)/maxrows*100));

            tmppopupobjobj.setPercentWidth(percent);
            tmppopupobjobj.setTotalNum(results[4]);
            tmppopupobjobj.setCurNum(startrow);
                
            if(parseInt(startrow+intervalrow)<parseInt(results[4]))
            {
                var nextstartrow=startrow + intervalrow;
                var balancedata=parseInt(results[4])-parseInt(startrow+intervalrow);
                if(balancedata<intervalrow)
                {
                    intervalrow=balancedata;
                }
                startMassUnallocated(select_options,allocatetype, viewname, userid, username, assign_name, idlist, revenuecount, nextstartrow, intervalrow, join_url);
                return false;
            }
            else{
                tmppopupobjobj.CancelEvent();
                if(data.code == 'validata'){
                    var confirm_str = confirm_str = arrJsPopLabel['SUCCESS']+arrJsPopLabel['DISTRIBUT']+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS']+'<br>'+data.msg;
                    MessagePopup.TipOne_warning(confirm_str);

                    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                        if (isDuplicate == false) {
                            var tmparra = new Array();
                            var tmpobj = new AfterUpdatePrevPopupObjContent('Accounts', "", tmparra);
                            //服务单保存后刷新服务单的历史记录(查看界面)
                            var refreshlistmodules = new Array('Accounts');
                            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                            // window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                        }
                    });
                    return '';
                }
            }

            puyoungJS_DialogBox.unblock();
            // if(results[3] == 3)   //批量领取
            // {
            //     var prompt = arrJsPopLabel['BATCHRECEIVE'];
            // }
            // else
            // {
            //wym BUG20240117-74 分配一条时，提示信息改为成功分配
            if(results[1]==1){
                var prompt = arrJsPopLabel['DISTRIBUT'];
            }else{
                var prompt = arrJsPopLabel['BATCHALLOCATION'];
            }

            // }
            //0046198: （81mis.com/kfbcrm）客户管理-客户，“默认公海”池，公海未分配页签，在未分配客户列表处操作公海分配，页面没有小刷新也没有成功分配弹窗 注释if
            // if(selectType == 1){
                if(results[2] == 0)
                {
                    confirm_str = arrJsPopLabel['SUCCESS']+prompt+" "+results[1]+" "+arrJsPopLabel['RECORDS'];
                    MessagePopup.TipOne_success(confirm_str);
                }
                else
                {
                    confirm_str = arrJsPopLabel['SUCCESS']+prompt+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS'];
                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                }
            }
            isDuplicate=false;
        // }

        //抽离到回调函数体内 （批量分配  selectType为1 ，后面可以删除if语句体）
        // if (selectType == 2) {
            /*var tmparra = new Array();
            var tmpobj = new AfterUpdatePrevPopupObjContent('Accounts', "", tmparra);
            //服务单保存后刷新服务单的历史记录(查看界面)
            var refreshlistmodules = new Array('Accounts');
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);*/
            //window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
        // } else {
            //点击确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                if (isDuplicate == false) {
                    var tmparra = new Array();
                    var tmpobj = new AfterUpdatePrevPopupObjContent('Accounts', "", tmparra);
                    //服务单保存后刷新服务单的历史记录(查看界面)
                    var refreshlistmodules = new Array('Accounts');
                    tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                    // window.location.href = "index.php?module=Accounts&action=ListView&parenttab=Parent Accounts"+gstart+"&viewid="+viewname;
                }
            });
        // }
    };
    http_reqfield.setRequestHeader("If-Modified-Since", "0");
    http_reqfield.send();
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
        var data =eval('('+ http_reqfield.responseText +')')?eval('('+ http_reqfield.responseText +')'):JSON.parse(http_reqfield.responseText);
        var results=data.result;

        if(data.code == 'validata'){
            confirm_str = arrJsPopLabel['SUCCESS']+arrJsPopLabel['BATCHRECEIVE']+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS']+'<br>'+data.msg;
            MessagePopup.TipOne_warning(confirm_str);
            return '';
        }

        puyoungJS_DialogBox.unblock();
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
                //wym 240126 BUG20240125-52 客户-在公海未分配页签勾选客户批量领取，提示信息样式错误
                MessagePopup.TipOne_success(confirm_str);
			}
			else
			{
                confirm_str = arrJsPopLabel['SUCCESS']+prompt+results[1]+arrJsPopLabel['RECORDS']+','+arrJsPopLabel['LOSE']+results[2]+arrJsPopLabel['RECORDS'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
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
	var popupobj=CrmPopup.getPopupObj("last");
	var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
	var scopepopupobj;//自定义弹出层页面html，绑定事件
	var module = 'Accounts';

    var popup_caption_value;
    var popup_url = '';

    var popupinfo = getAllocateSharePopupInfo('higndistribution', module, pool_id);
    popup_caption_value = popupinfo.poptitle;
    popup_url = popupinfo.popup_url;

	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = '';
           cls_ScopePopup.prop.popup_url = popup_url;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					if(empty(cls_ScopePopup.return_obj.return_id)){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                        // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        MessagePopup.TipOne_warning(confirm_str);
						return false;
                    }else{
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
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
							ld('#rptContentLoading').hide();
							return false;
						}
                        else if(response.responseText.indexOf("###error###3")!=-1)
                        {
                            //已领取
                             var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSFAILURE'];
                             RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            ld('#rptContentLoading').hide();
							return false;
                        }
						var popupobj=CrmPopup.getPopupObj("last");
						var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池

						var scopepopupobj;//自定义弹出层页面html，绑定事件
						var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
						var module = 'Accounts';
						getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
							scopepopupobj =  new ScopePopupObj(module);
							scopepopupobj.popup_caption_value = popup_caption_value;//标题title
							getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
							   cls_ScopePopup.prop.popup_module = module;//模块
							   cls_ScopePopup.prop.popup_value = '';
							   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes&pool_id='+pool_id;
							   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
								//重写确认按钮事件
								scopepopupobj.setEventBtnOk=function(){
									ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
										if(empty(cls_ScopePopup.return_obj.return_id)){
										  var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
										  RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
										}else{
											ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
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
    ld('#rptContentLoading').show();
    selectType = 2;
    var  viewid=document.getElementById("viewname").value;
    if(document.massdelete.publicaccounttype!=undefined)
        var  accounttype=document.massdelete.publicaccounttype.value; 
    else
        var  accounttype='';
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
                        ld('#rptContentLoading').hide();
                    if(response.responseText.indexOf("###error###")!=-1)
                    {
                        var confirm_str = arrJsPopLabel['THEHIGHSEASHASBEENRECEIVINGCUSTOMERSALLOCATION'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                       ld('#rptContentLoading').hide();
                        return false;
                    }
					var popupobj=CrmPopup.getPopupObj("last");
					var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
					var scopepopupobj;//自定义弹出层页面html，绑定事件
					var popup_caption_value = arrJsPopLabel['LBL_DISTRIBUT_HIGHSEAS'];//标题
					var module = 'Accounts';
					getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
						scopepopupobj =  new ScopePopupObj(module);
						scopepopupobj.popup_caption_value = popup_caption_value;//标题title
						getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
						   cls_ScopePopup.prop.popup_module = module;//模块
						   cls_ScopePopup.prop.popup_value = '';
						   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=radio&popup_selecttype=user&ishighseaallocate=yes&pool_id='+pool_id;
						   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
							//重写确认按钮事件
							scopepopupobj.setEventBtnOk=function(){
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
									if(empty(cls_ScopePopup.return_obj.return_id)){
										RemindsMsg("","LdPopWidth400px","","yes","","");
										return false;
									}else{
										ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
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
    ld('#rptContentLoading').show();
    
    viewid=document.getElementById("viewname").value;

    if(document.getElementById("SmOwnerSearchScope")!=null)
     var searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
     else
     searchScope='';
    
     document.getElementById("viewname").value=viewid;


	var viewName = encodeURIComponent(viewid);
   document.massdelete.publicaccounttype.value=customtype;
   var urlstring = "module="+module+"&action="+module+"Ajax&file=ListView&ajax=true&start=1&SearchScope="+searchScope+"&pagepublicaccounttype="+customtype;
   //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
    	   urlstring += '&isshowModuleListTree=yes';
    	}
     var listview_page=new ListView_Page(module,urlstring,"ListViewContents");
    listview_page.callback_fun=function()
    {
        var popupobj=CrmPopup.getPopupObj('last');
         popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
        setContentHeight(module);//计算内容高度   
       
        IsFrameElement();
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
    //38755: (51mis.com/kfbcrm)客户>客户管理>全部（含所有公海）：单据明细界面，左侧相关点击“市场活动”字段，点击“选择”按钮，弹出层任意点击“市场活动名称”，提示报错。
       var detailviewpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
       var popupobj=CrmPopup.getPopupObj('lastprev');
      // alert("module="+detailviewpopupobj.module+"&action="+detailviewpopupobj.module+"Ajax&file=updateRelations&destination_module=Accounts&idlist="+entity_id+"&parentid="+recordid);
	new Ajax.Request(
	'index.php',
	{
		queue: {
			position: 'end',
			scope: 'command'
		},
		method: 'post',
		postBody:"module="+detailviewpopupobj.module+"&action="+detailviewpopupobj.module+"Ajax&file=updateRelations&destination_module="+popupobj.module+"&entityid="+entity_id+"&parentid="+recordid,
		onComplete: function(response) {
			var popupobj=CrmPopup.getPopupObj('lastprev');
         
			cancelCrmPopup();
        
        	var lastpopupobj=CrmPopup.getPopupObj('last');
             var tmparra=new Array();
             tmparra.push(popupobj.record);
                          
             var tmpobj= new AfterUpdatePrevPopupObjContent(lastpopupobj.module,getEmptyValueInfo(),tmparra);
             tmparra=[lastpopupobj.module];
             tmpobj.eachrefreshlistbyModules(tmparra);
             delete tmpobj;
			
			
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
    return curtop-ld('.Tdcenter div.DivCTable').scrollTop();
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
	
		ld('#rptContentLoading').show();

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
    ld('#rptContentLoading').show();
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
               
               ld('#rptContentLoading').hide();
                
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
			DelProgressObjs();
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
					DelProgressObjs();
				});
				return false;
			});
		}
		DelProgressObjs();
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
   // puyoungJS_DialogBox.block();
    var allids=document.forms['DetailView'].record.value;
    var url = "module="+module+"&action=sendEmailField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids;
    ldAjaxHtml('index.php',url,function (response) {
        DelProgressObjs();
        var tmparr = [];
        tmparr.push('Accounts');
        var popupobj = CrmPopup.load(arrJsPopLabel['PLEASESELECTEMAIL'], chosebox_select_btn_email, "", "LdPopWidth500px", module, '', arrJsPopLabel['SAVE'], tmparr, arrJsPopLabel['CANCEL']);
        var results = response.split('&#&#&#');
        popupobj.show(results[1]);
    });
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
        var url = "module="+module+"&action=sendSMSField&parenttab=Parent Accounts&ReportHeader=dbheader&allids="+allids;
        ldAjaxHtml('index.php',url,function (response) {
            var tmparr = [];
            tmparr.push('Accounts');
            var popupobj = CrmPopup.load(arrJsPopLabel['PLEASESELECTEMAIL'], chosebox_select_btn, "", "LdPopWidth500px", module, '', arrJsPopLabel['SAVE'], tmparr, arrJsPopLabel['CANCEL']);
            var results = response.split('&#&#&#');
            popupobj.show(results[1]);
            DelProgressObjs();
        });

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
     
     ld('#rptContentLoading').show();
     puyoungJS_DialogBox.block();//遮罩层
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
                    ld('#rptContentLoading').hide();
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
	 var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
      var objparams=new CreatePagePopup.params();
     if(popupobj.type=="listpage")
                objparams.params['refreshpage']='no';
      CreatePagePopup.showpage('Accounts',"&publicaccount=1&pool_id="+pool_id,objparams);
}
/**
创建公海已分配
**/
 function createpublic_Allocated()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var objparams=new CreatePagePopup.params();
    var module = popupobj.module;
    var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();	//公海池
    if(popupobj.type=="listpage")
        objparams.params['refreshpage']='no';

    var url = 'module='+module+'&action=EditView&return_action=DetailView&Create=true&publicaccount=2';
    var max_url="module=Accounts&action=AllocateAccount&allocatetype=3&maxaccount=1&ReportHeader=dheader&type=createpage&pool_id="+pool_id;
    //zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
    ldAjax('index.php?',max_url,function(data) {
        DelProgressObjs();
        var tmpmsg = data.msg;
        var restobj = data.result;
        if(tmpmsg.indexOf('error')!='-1')
        {
            var confirm_str = arrJsPopLabel['HIGHSEASREACHEDCREATE'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        }
        else
        {
            /// var objparams=new CreatePagePopup.params();
            CreatePagePopup.showpage(module,"&publicaccount=2&pool_id="+pool_id,objparams);
        }

    });
    return false;
}
/**
Liver 2016-12-07 平均分配
**/
function averageDistribution(obj,module,popup_type){    
    //获取要变更的ID
    var selectlen = 1;
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
                // RemindsMsg("","LdPopWidth400px","","yes","yes","");
                MessagePopup.TipOne_warning();
				return false;
			}
			if(count - 1 > getMaxMassOperationLimit()) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
				if(confirm(confirm_str)) {
				} else {
					return false;
				}
			}

            selectlen = count - 1;
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
    var popup_url = '';

    var popupinfo = getAllocateSharePopupInfo(popup_type, module);
    popup_caption_value = popupinfo.poptitle;
    popup_url = popupinfo.popup_url;
    
	var popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><a class="rfloat" href="javascript:;" style="margin-right: 15px;margin-top:-4px;" onclick="getLinksUrl(\'Accounts\',\'Allocate\',\'averageDistribution\');" >'+arrJsPopLabel['ONLINEHELP']+'</a><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
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
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    var array_user=cls_ScopePopup.return_obj.return_id.split(",").length;//选取用户的个数
                    if(empty(cls_ScopePopup.return_obj.return_id) || array_user<2){
                        var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                        // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        MessagePopup.TipOne_warning(confirm_str);
                        return false;
                    }else{
                        var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        //edit:can 2021-03-05 44743: （本地8.3.7）单据平均分配；客户模块，选择客户单据后进行平均分配，先选择一个成员，出现“请至少选择两个成员！”提示后，再加个成员点确定没反应
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click');//解绑防止多次点击。
                        ld('#rptContentLoading').show();
                        // @edit:liushuai,2021-03-02,reason:【ID1001390】批量平均分配增加显示进度条
                        var selected_user_arr=selected_user.split(",");
                        var  intervalrow=selected_user_arr.length;
                        var executeTimeCount=parseInt(selectlen/intervalrow);
                        //edit:can 20210425 45560: （https://61mis.com/kfbcrm [^] ）平均分配时不平均
                         if(executeTimeCount>20)
                         {
                            intervalrow=selected_user_arr.length*2;
                         }
                         if(executeTimeCount>30)
                         {
                            intervalrow=selected_user_arr.length*3;
                         }
                         if(executeTimeCount>30)
                         {
                            intervalrow=selected_user_arr.length*4;
                         }
                         if(executeTimeCount>50)
                         {
                            intervalrow=selected_user_arr.length*5;
                         }
                         if(executeTimeCount>60)
                         {
                            intervalrow=selected_user_arr.length*6;
                         }
                          if(executeTimeCount>70)
                         {
                            intervalrow=selected_user_arr.length*7;
                         }
                         if(intervalrow<8)
                         {
                            intervalrow=selected_user_arr.length*2;
                         }
                        
                        startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, 0, intervalrow);

                    }
                });
            }
		});
	});
}

// @edit:liushuai,2021-03-02,reason:【ID1001390】批量平均分配增加显示进度条
function startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, startrow, intervalrow, join_url="")
{
    var endrow = startrow+intervalrow;
    if (endrow > selectlen){
        endrow = selectlen;
    }
    var urlstring = 'module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
    urlstring += '&from_module='+module+'&changetype='+popup_type+'&mode='+mode;
    urlstring += '&select_id='+select_id+'&caterorid='+selected_user+'&excludedRecords='+excludedRecords;
    
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    //edit:can 20220214 49934: https://www.51mis.com/hy/liuuu [^] 客户管理>客户档案>单据全选，平均分配>分配方式存在错误
    if(mode=='list'&&ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   urlstring += '&isshowModuleListTree=yes';
	}
    
    urlstring+="&startrow="+startrow+"&endrow="+endrow;
    urlstring += join_url;
    ldAjax('index.php?',urlstring, function (data){
        DelProgressObjs();
        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
        var tmpmsg = data.msg;
        var restobj = data.result;
        if(data.code == -1){
            if(tmpmsg.indexOf('###REACHMAXCUSTOMER###')>-1){
                var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                return false;
            }
        }
        else if(data.code == 1){
            if(mode=='list')
            {
                var tmppopupobjobj;
                if(startrow==0)
                {
                    tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,module,"","","","");
                    tmppopupobjobj.show();

                }
                else{
                    tmppopupobjobj=CrmPopup.getPopupObj('last');

                }
                var maxrows=parseInt(restobj.maxrows);
                var percent=parseInt(((startrow+intervalrow)/maxrows*100));
                //var width=parseInt((500*(startrow+intervalrow)/maxrows));

                tmppopupobjobj.setPercentWidth(percent);
                tmppopupobjobj.setTotalNum(restobj.selectrows);
                tmppopupobjobj.setCurNum(startrow);
                if(maxrows!=restobj.selectrows)
                {
                    tmppopupobjobj.setValidataNum(maxrows);
                }
                if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
                {
                    startAverageDistribution(module, popup_type, mode, select_id, selected_user, selectlen, excludedRecords, startrow + intervalrow, intervalrow);
                    return false;
                }
                else{
                    tmppopupobjobj.CancelEvent();
                }
            }
            if(ld('input[name=selected_id]').length == 0){//Liver 2016/09/07 去掉&&module!='Documents'，原因是bug0024278: 知识管理明细：更多中点击-更改创建人，确定后，界面显示了更改创建人的提示消息
                puyoungJS_DialogBox.block();

                if(module == 'HelpDesk'){
                    var help_url = window.location.href;
                    help_url = help_url.replace('&sendtype=yes','');
                    if(help_url.indexOf('&sendtype=yes')<0 && popup_type=='Allocate'){
                        help_url += '&sendtype=yes';
                    }
                    window.location.href=help_url;
                    return false;
                }
                puyoungJS_DialogBox.unblock();
                fninvshnew('selectpopup_1');
                changeUser.afterOperation(popup_type,selected_user,cls_ScopePopup.return_obj.return_name,module);
                //window.location.reload();
                return false;
            }
            getJsScript('include/js/ldcrm.base.js',function(){
                resultRemindsMsg(restobj.title.value,"LdPopWidth600px","","yes","",restobj.log.value);
                var popupobj=CrmPopup.getPopupObj('last');
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
                }


                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    fninvshnew('mass_advancer');puyoungJS_DialogBox.unblock();
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
        else{
            return false;
        }
    })
}

// lius 20230613 XUQIU1001607 圣拉维CRM项目：客户自动分配功能
function cls_autoDistribution(){
    this.ruleid='';
    var that = this;

    this.autoDistribution_pop = function(obj,module,popup_type){
        //获取要变更的ID
        var selectlen = 1;
        var select_id = '';//选择的单据id
        // var mode = 'list';//类型：列表(list)详情页(detail)
        var excludedRecords = '';
        that.module=module;
        if(ld('input[name=selected_id]').length > 0){//列表

            select_id = document.getElementById('allselectedboxes').value;
            if('all' == select_id){
                //获取全选数量
                selectlen = document.getElementById('numOfRows').value;
                excludedRecords = document.getElementById('excludedRecords').value;
            }else {
                var x = select_id.split(';');
                var count = x.length;
                if(0 == ld('input[name=selected_id]:checked').length){
                    // RemindsMsg("","LdPopWidth400px","","yes","yes","");
                    MessagePopup.TipOne_warning();
                    return false;
                }

                selectlen = count - 1;
            }
        }
        else if(document.DetailView == undefined){
            RemindsMsg("","LdPopWidth400px","","yes","","");
            return false;
        }
        // savefilter += '&select_id='+select_id;

        // that.selectlen = selectlen;
        that.select_id = select_id;
        that.excludedRecords = excludedRecords;
        that.popup_type = popup_type;

        var crmPopupobj=CrmPopup.load("","","","LdPopWidth500px",module,"","","","");
        crmPopupobj.prevshow();
        var url = "index.php?module="+module+"&action="+module+"Ajax&file=autoAllocatePop&popup_module="+module;
        ldAjax(url,"",function(data){
            if(data.code==1)
            {
                crmPopupobj.setParams(data.result.title,that.getSelectUsersInfo,"","LdPopWidth500px",module,'',data.result.oktext,"",data.result.canceltext);
                crmPopupobj.show(data.result.content);
                DelProgressObjs();
            }
        })
    }

    //检查所选客户分配规则下的成员
    this.getSelectUsersInfo = function(){
        var popupobj=CrmPopup.getPopupObj("last");

        var customform24_id = CrmPopup.findHtmlobj(popupobj.divid,'customform24_id').val() || '';
        if (empty(customform24_id)) {
            MessagePopup.TipOne_warning('客户分配标准不能为空');
            return false;
        }
        that.ruleid = customform24_id;

        var url = "index.php?module=Users&action=UsersAjax&file=ChangeCreatorInfo&changetype="+that.popup_type+"&setype=getselectusers&ruleid="+customform24_id;
        ldAjax(url,"",function(data){
            if(data.code==1)
            {
                if (data.result.select_users_count < 1 ) {
                    MessagePopup.TipOne_warning('所选分配标准下暂无数据');//客户分配标准下没有设置成员
                    return false;
                }
                DelProgressObjs();
                popupobj.CancelEvent();

                that.startAutoDistribution();
            }
        })
    }

    this.startAutoDistribution = function(){

        var urlstring = 'index.php?module=Users&action=UsersAjax&file=ChangeCreatorInfo&setype=save';
        urlstring += '&from_module='+that.module+'&changetype='+that.popup_type;
        urlstring += '&select_id='+that.select_id+'&excludedRecords='+that.excludedRecords;

        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
            urlstring += '&isshowModuleListTree=yes';
        }

        urlstring += '&ruleid='+that.ruleid;

        ldAjax(urlstring,'',function(data){
            var tmppopupobjobj;
            if(data.result.start == 0)
            {
                tmppopupobjobj=ProgressPopup.load(data.result.progresstitle,"","",500,that.module,"","","","");
                tmppopupobjobj.show();
            }
            else{
                tmppopupobjobj=CrmPopup.getPopupObj('last');
            }

            tmppopupobjobj.setPercentWidth(data.result.percent);
            tmppopupobjobj.setTotalNum(data.result.total);
            tmppopupobjobj.setCurNum(data.result.end);
            DelProgressObjs();
            if (data.code == 2){ //继续当前

                that.startAutoDistribution();
                return false;
            }else{//结束
                tmppopupobjobj.CancelEvent();//关闭弹出框
            }


            getJsScript('include/js/ldcrm.base.js',function(){
                resultRemindsMsg(data.result.title,"LdPopWidth600px","","yes","",data.result.log);
                var popupobj=CrmPopup.getPopupObj('last');
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
                }

                ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
                    fninvshnew('mass_advancer');puyoungJS_DialogBox.unblock();
                    if(ld('input[name=selected_id]').length > 0){
                        $('basicsearchcolumns').innerHTML = '';
                        $('allselectedboxes').value='';
                        $('excludedRecords').value='';
                        getListViewEntries_js(that.module,data.result.pagestart);//刷新页面

                    }else{
                        window.location.reload();
                    }
                });
                return false;
            });
        });

    }
    that.startAutoDistribution.funname='this.startAutoDistribution';

}
var cls_autoDistribution = new cls_autoDistribution();


/*
edit:Liver
date:20161209
reason:  公海客户批量平均分配界面生成
*/
function massDeskHighAvgAllocatetaccount(obj)
{
    var selectlen = 1;
    var select_id = '';//选择的单据id

	//该功能不判断被分配用户的公海客户是否达到上限，是否继续？
    var confirm_str = arrJsPopLabel['thisopreationdoesnotcheckthehignseaquantitylimit'];
    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", confirm_str);

    //点击确认
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
        //批量操作条目数控制
        if (!selectchoice()) {
            return false;
        }
        var scopepopupobj;//自定义弹出层页面html，绑定事件
        var module = 'Accounts';

        var popup_caption_value;
        var popup_url = '';
    
        var popupinfo = getAllocateSharePopupInfo('averagehigndistribution', module, pool_id);
        popup_caption_value = popupinfo.poptitle;
        popup_url = popupinfo.popup_url;

        all_select_id = document.getElementById('allselectedboxes').value;

        if ('all' == all_select_id) {
            //获取全选数量
            selectlen = document.getElementById('numOfRows').value;
            excludedRecords = document.getElementById('excludedRecords').value;
            if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
                var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
                if (confirm(confirm_str)) {
                } else {
                    return false;
                }
            }
        }
        var popupobj = CrmPopup.getPopupObj("last");
        var pool_id = ld("#" + popupobj.divid + " [name=pool_id]").val();	//公海池
        getJsScript('include/js/ScopePopup/ScopePopupObj.js', function () {
            var methodObj = {'popup_check_inactiveuser': 'yes'};
            scopepopupobj = new ScopePopupObj(methodObj);
            scopepopupobj.popup_caption_value = popup_caption_value;//标题title
            getJsScript('include/js/ScopePopup/ScopePopup.js', function () {
                cls_ScopePopup.prop.popup_module = module;//模块
                cls_ScopePopup.prop.popup_value = '';
                cls_ScopePopup.prop.popup_url = popup_url;
                var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                //重写确认按钮事件
                scopepopupobj.setEventBtnOk = function () {
                    ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                        var array_Highuser = cls_ScopePopup.return_obj.return_id.split(",").length;
                        if (empty(cls_ScopePopup.return_obj.return_id) || array_Highuser < 2) {
                            var confirm_str = arrJsPopLabel['PLEASESELECTLESTTWOUSER'];
                            RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                            return false;
                        } else {
                            ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
                            var assigneduserid = cls_ScopePopup.return_obj.return_id;//选中的用户id

                            var assignedusername = cls_ScopePopup.return_obj.return_name;//选中用户name;
                            var savefilter = '';
                            var mode = '';
                            if (ld('input[name=selected_id]').length > 0) {//列表
                                select_id = document.getElementById('allselectedboxes').value;
                                if ('all' == select_id) {
                                    //获取全选数量
                                    selectlen = document.getElementById('numOfRows').value;
                                    //savefilter += '&selectlen='+selectlen;
                                }else{
                                    var x = select_id.split(';');
                                    var count = x.length;
                                    if(0 == ld('input[name=selected_id]:checked').length){
                                        RemindsMsg("","LdPopWidth400px","","yes","yes","");
                                        return false;
                                    }
                                    if(count - 1 > getMaxMassOperationLimit()) {
                                        var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT',count - 1,getMaxMassOperationLimit(),'');
                                        if(confirm(confirm_str)) {
                                        } else {
                                            return false;
                                        }
                                    }

                                    selectlen = count - 1;
                                }
                            }
                            //massHighAllocate_Load
                            massHighAllocate_Load(select_id, 2, assigneduserid, assignedusername, selectlen);
                        }
                    });
                }
            });
        });
    });
}
function massHighAllocate_Load(select_options,allocatetype,assigneduserid,assignedusername,selectlen,join_url='')
{
    var confirm_str = "";
    var gstart = '';
    if (document.forms['massdelete'].pagenum != undefined) {
        gstart = "&start=" + document.forms['massdelete'].pagenum.value;
    } else {
        gstart = "&start=" + document.forms['massdelete'].pagenum[0].value;
    }

    var searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
    var accounttype = document.massdelete.publicaccounttype.value;
    var assignids = document.getElementById("assign_name").value;
    var idlist = document.getElementById("allselectedboxes").value;
    var viewname = document.getElementById("viewname").value;
    var excludedRecords = $('excludedRecords').value;
    //客户公海分配 - 列表
    if (allocatetype == 2 && selectType == 2) {
        //select_options = idlist = document.EditView.record.value;
        idlist = select_options;
    }

// @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
    var userid_length = assigneduserid.split(',').length;
    //var intervalrow = Math.ceil((userid_length * selectlen)/10); //向上取整,为了使所选用户平均分配  数据量太大  请求次数过多  会导致执行起来过久
    // var userid_length = assigneduserid.split(',').length;
    var selected_user_arr=assigneduserid.split(",");
    var  intervalrow=selected_user_arr.length;
    var executeTimeCount=parseInt(selectlen/intervalrow);
    //edit:can 20210603 45954: （61mis.com/kfbcrm）客户管理-客户，管理员登录，在公海未分配页签，选择多个客户单据操作公海平均分配；选择管理员和另一成员，只分配给了管理员
     if(executeTimeCount>20)
     {
        intervalrow=selected_user_arr.length*2;
     }
     if(executeTimeCount>30)
     {
        intervalrow=selected_user_arr.length*3;
     }
     if(executeTimeCount>30)
     {
        intervalrow=selected_user_arr.length*4;
     }
     if(executeTimeCount>50)
     {
        intervalrow=selected_user_arr.length*5;
     }
     if(executeTimeCount>60)
     {
        intervalrow=selected_user_arr.length*6;
     }
      if(executeTimeCount>70)
     {
        intervalrow=selected_user_arr.length*7;
     }
     if(intervalrow<8)
     {
        intervalrow=selected_user_arr.length*2;
     }
         
    start_massDeskHighAvgAllocatetaccount(select_options,allocatetype,gstart,accounttype,excludedRecords,viewname,searchScope,assigneduserid,assignids,idlist,selectlen,0, intervalrow, join_url);
    
}
// @edit:liushuai,2021-03-11,reason:【ID1001390】公海未分配批量平均分配增加显示进度条
function start_massDeskHighAvgAllocatetaccount(select_options,allocatetype,gstart,accounttype,excludedRecords,viewname,searchScope,assigneduserid,assignids,idlist,selectlen, startrow, intervalrow, join_url=''){
    var endrow = startrow+intervalrow;
    if (endrow > selectlen){
        endrow = selectlen;
    }
    var url = "module=Accounts&action=AccountsAjax&file=cls_avghighallocate_account&idstring=" + select_options + "&allocatetype=" + allocatetype + gstart + "&maxaccount=1&pagepublicaccounttype=" + accounttype + "&excludedRecords=" + excludedRecords + "&viewname=" + viewname + "&SearchScope=" + searchScope;
    if (allocatetype == 2) {
        var userid = assigneduserid;
        //var userid=document.getElementById('assigned_user_id').value;
        url = url + "&userid=" + userid + "&assign_name=" + assignids + "&id=" + idlist;
    }

    url += "&selectlen="+selectlen+"&startrow="+startrow+"&endrow="+endrow;
    url += join_url;
    new Ajax.Request(
        'index.php',
        {
            queue: {
                position: 'end',
                scope: 'command'
            },
            method: 'post',
            postBody: url,
            onComplete: function (response) {

                ld('#rptContentLoading').hide();
                //fninvshnew(divid);
                if (response.responseText.indexOf('###REACHMAXCUSTOMER###') > -1) {
                    var confirm_str = arrJsPopLabel['REACHMAXCUSTOMERJS'];
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                    return false;
                }
                ld('#' + cls_ScopePopup.popup_divid + ' .D_pbtn .D_pbtncancel').click();

                if (empty(response.responseText)) return false;
                var restobj = eval('(' + response.responseText + ')') ? eval('(' + response.responseText + ')') : JSON.parse(response.responseText);

                var tmppopupobjobj;

                if(startrow==0)
                {
                    tmppopupobjobj=ProgressPopup.load(restobj.title.value,"","",500,'Accounts',"","","","");
                    tmppopupobjobj.show();
                }
                else{
                    tmppopupobjobj=CrmPopup.getPopupObj('last');
                }
                var maxrows=parseInt(restobj.maxrows);
                var percent=parseInt(((startrow+intervalrow)/maxrows*100));

                tmppopupobjobj.setPercentWidth(percent);
                tmppopupobjobj.setTotalNum(restobj.selectrows);
                tmppopupobjobj.setCurNum(startrow);
                if(maxrows!=restobj.selectrows)
                {
                    tmppopupobjobj.setValidataNum(maxrows);
                }
                if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows))
                {
                    start_massDeskHighAvgAllocatetaccount(select_options,allocatetype,gstart,accounttype,excludedRecords,viewname,searchScope,assigneduserid,assignids,idlist,selectlen,startrow + intervalrow, intervalrow, join_url);
                    return false;
                }
                else{
                    tmppopupobjobj.CancelEvent();
                }

                if (ld('input[name=selected_id]').length == 0) {
                    puyoungJS_DialogBox.block();
                    puyoungJS_DialogBox.unblock();
                    fninvshnew('selectpopup_1');
                    changeUser.afterOperation(popup_type, selected_user, cls_ScopePopup.return_obj.return_name, module);
                    //window.location.reload();
                    return false;
                }
                getJsScript('include/js/ldcrm.base.js', function () {
                    var divobj = createElementDivs('mass_advancer');//创建DIV
                    ld(divobj).find('.E_pop_tit .E_ptita').html(restobj.title.value);
                    ld('#mass_advancercontent').html(restobj.log.value);
                    fnvshobj('', 'mass_advancer');
                    ld('#mass_advancercontent').css('overflow', 'auto').css('max-height', '350px').css('padding', '5px');
                    ld('#mass_advancer .D_pbtn .D_pbtncancel').css('display', 'none');
                    //关闭事件
                    ld('#mass_advancer .E_pop_tit .E_ptitc').unbind('click').on('click', function () {
                        ld('#mass_advancer .E_pbtn .E_pbtnok').click();
                        return false;
                    });
                    if (typeof cls_wxOpenDataobj != undefined && typeof cls_wxOpenDataobj != "undefined") {
                        //通讯录(pc端企业微信)
                        cls_wxOpenDataobj.bindAllOpenData();
                    }
                    ld('#mass_advancer .E_pbtn .E_pbtnok').unbind('click').on('click', function () {
                        fninvshnew('mass_advancer');
                        puyoungJS_DialogBox.unblock();
                        if (ld('input[name=selected_id]').length > 0) {
                            $('basicsearchcolumns').innerHTML = '';
                            $('allselectedboxes').value = '';
                            $('excludedRecords').value = '';
                            getListViewEntries_js('Accounts', restobj.start.value);//刷新页面
                            //window.location.reload();
                            if (document.getElementById("SmOwnerSearchScope") != undefined)
                                searchScope = encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
                            var viewid = getviewId();

                        } else {
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
		scopepopupobj.popup_header = '<div class="select-input">';
        scopepopupobj.AccountHierarchy = 'AccountHierarchy';
		if(contactstatus == 'yes'){
			scopepopupobj.popup_header +=  '<input type="checkbox" id=\'viewaccount_contacts\' >' + 
                                    '<label id="viewaccount_contacts_span" for=\'viewaccount_contacts\'>'+arrJsPopLabel['Displaycontacts']+'</label>';
		}
		scopepopupobj.popup_header += '</div>';
                                   
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
            cls_ScopePopup.prop.popup_module = 'Accounts';//模块
            cls_ScopePopup.prop.popup_url = popup_account_url;
            var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
            //ld('#'+cls_ScopePopup.popup_divid).css('left',"55%");
            //ld('#'+cls_ScopePopup.popup_divid).css('top',"45%");
            ld('#'+cls_ScopePopup.popup_divid).attr('class','E_pop_box LdPopWidth500px ui-popup');
            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').hide();
            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').val(arrJsPopLabel['LBL_CLOSE']);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
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
   
    /*
    edit:duan 20230215 需求XUQIU1001057要求去掉这个控制
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
    */
    
    /*
    edit:can
    date:20140211
    reason:6698: 客户，新增客户界面，首要联系人列，没有对邮箱格式进行限制，如图：
    */
    
    // var re=new RegExp(/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/);
    var re=new RegExp(/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/);
    
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

//重算经纬度
function Recalculation_latandlong(module){
	getJsScript('include/js/modules/Accounts/Reset_latandlong.js',function(){
		var cls_reset_latandlong = new Reset_latandlong();
        cls_reset_latandlong.view();
	});
}

function cls_PublicAccount(){
	var that = this;
	//公海池 、公海已分配、公海未分配 标签点击事件
	this.showCustomType = function(inputobj){
		var popupobj=CrmPopup.getPopupObj("last");
		ld('#rptContentLoading').show();
		if(ld(inputobj).prop("tagName") == 'SELECT'){
			var pool_id = ld(inputobj).val();
			var publicaccounttype = ld(inputobj).find("option:selected").attr("accounttype");
		}else{
            var pool_id = ld(inputobj).data('pool_id');
            var publicaccounttype =  ld(inputobj).data('accounttype');
            if(pool_id == undefined){
                pool_id = ld(inputobj).attr('pool_id');
                publicaccounttype =  ld(inputobj).attr('accounttype');
            }else{
                pool_id = pool_id.toString();
            }
		}
		var viewname = encodeURIComponent(ld("#"+popupobj.divid+" [name=viewname]").val());
		var searchScope = '';
		if(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]")!=null)
			searchScope= encodeURIComponent(ld("#"+popupobj.divid+" [name=SmOwnerSearchScope]").val());
		ld("#"+popupobj.divid+" [name=publicaccounttype]").val(publicaccounttype)
        var surl = "module=Accounts&action=AccountsAjax&file=ListView&start=1&SearchScope="+searchScope+"&pagepublicaccounttype="+publicaccounttype+"&pool_id="+pool_id;
        //zkt 模块树结构显示增加条件，获取树结构点击条件
        if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
            surl += '&isshowModuleListTree=yes';
        }
		var listview_page=new ListView_Page('Accounts',surl,"pagecontent1");
		listview_page.callback_fun=function()
		{
			popupobj.listresizeobj.setReiszeTable_Init(module,'ajax');
			setContentHeight(module);//计算内容高度   
			IsFrameElement();
		}
		listview_page.page();
	}

	//转换公海 - 批量
	this.mass_transfer = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var select_options = ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
		var publicaccounttype = ld("#"+popupobj.divid+" [name=publicaccounttype]").val();
		var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();
		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=MassTransferAccount&select_ids='+select_options+'&publicaccounttype='+publicaccounttype+'&pool_id='+pool_id;
		//基本、高级查询条件
		if(!empty(searchtype_btn)){
			surl += '&'+getUrlString(searchtype_btn);
			surl += "&query=true&ajax=true&search=true";
		}
		if(select_options == 'all'){
		      //zkt 模块树结构显示增加条件，获取树结构点击条件
                if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
                    surl += '&isshowModuleListTree=yes';
            	}
			//获取全选数量
			var selectlen = ld("#"+popupobj.divid+" [name=numOfRows]").val();
			if (parseInt(selectlen) > parseInt(getMaxMassOperationLimit())) {
				var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', selectlen, getMaxMassOperationLimit(), '');
				RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
				//确定事件
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
					that.show_transfer(surl);
				});
			}
			else {
				that.show_transfer(surl);
			}
		}else{
			if(select_options != ''){
				var x = select_options.split(';');
				var count = x.length;
				if (parseInt(count) - 1 > parseInt(getMaxMassOperationLimit())) {
					var confirm_str = getThreeVarJsPop('YOUSELECTMAXMASSOPERATIONLIMIT', parseInt(count) - 1, getMaxMassOperationLimit(), '');
					//创建提示弹出层
					RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", confirm_str + arrJsPopLabel['WENHAO']);
					//确定事件
					ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
						that.show_transfer(surl);
					});
				} else {
					that.show_transfer(surl);
				}
			}else{
                MessagePopup.TipOne_warning(arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
		}
	}
	//显示转换公海界面
	this.show_transfer = function(surl){
        
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
                //wym BUG0078083 变更公海--弹窗去除多余空白部分
                var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
                crmPopupobj.prevshow();
                //wym BUG0078083 变更公海--弹窗去除多余空白部分
				crmPopupobj.setParams(data.result.title,that.save_mass_transfer,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.show(data.result.content);
				crmPopupobj.center();
                // ljj 20230904 BUG0072070 kfbcrm-弹出层的× title改为tip
                tooltip(".tip-items-pop", {transition: true, time: 200});
				ld("#"+popupobj.divid+" [name=transfer]").unbind('click').on('click',function(){
					if(ld(this).val() == 'transfer_out'){
						ld("#"+popupobj.divid+" [name=div_select_public_account_pool]").hide();
					}else{
						ld("#"+popupobj.divid+" [name=div_select_public_account_pool]").show();
					}
				});
				//that.set_account_public_bind();
			}else{
                MessagePopup.TipOne_warning(data.msg);
            }
		})
	}
	//转换公海 - 单条记录，如列表 - 详情页
	this.account_transfer = function(record){
		if(!empty(record)){
			var popupobj=CrmPopup.getPopupObj("last");
			var publicaccounttype = ld("#"+popupobj.divid+" [name=publicaccounttype]").val();
			var pool_id = ld("#"+popupobj.divid+" [name=pool_id]").val();
			var surl = 'index.php?module=Accounts&action=AccountsAjax&file=MassTransferAccount&select_ids='+record+';'+'&publicaccounttype='+publicaccounttype+'&pool_id='+pool_id+'&popupobj_type='+popupobj.type;
			that.show_transfer(surl);
		}
	}
	//转换公海 - 保存
	this.save_mass_transfer = function(){
		var popupobj=CrmPopup.getPopupObj("last");
		var prevpopupobj=CrmPopup.getPopupObj('lastprev');
		var transfer = encodeURIComponent(ld("#"+popupobj.divid+" [name=transfer]:checked").val());
		var select_pool_id = 0;
		if(transfer == 'transfer_to' && ld("#"+popupobj.divid+" [name=select_public_account_pool]").val() != undefined){
			select_pool_id = ld("#"+popupobj.divid+" [name=select_public_account_pool]").val();
			if(select_pool_id == 0 || select_pool_id == ''){
				RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Pleaseselectatleastonehighseas']);
				return false;
			}
		}
		var record = ld("#"+popupobj.divid+" [name=record]").val();
		if(record == ''){
			RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
			
		}
		var urlstring = 'index.php?module=Accounts&action=AccountsAjax&file=ConvertAccount&transfer='+transfer+"&select_pool_id="+select_pool_id;
        if(prevpopupobj.pagetype =='detailview_modulepage'){
            urlstring += '&mode=detail';
        }else{
            urlstring += '&mode=list';
        }
		ldAjax(urlstring,{idstring:record},function(restobj){
			popupobj.CancelEvent();
			DelProgressObjs();
            //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（详情页转公海）
            if(restobj.code == -1){//上限错误提示
                RemindsMsg("","LdPopWidth400px","","yes","yes",restobj.msg);
                return false;
            }
			if(prevpopupobj.type == 'detailviewpage'){
				var tmparra=new Array();
				tmparra.push(recordid);
				var refreshlistmodules = new Array('Accounts');
				var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',getEmptyValueInfo(),tmparra);
				tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
			}else{
			    //duan 20240709 如果是详情弹出层且不在详情页面
                var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
                if(!empty(detailpopupobj)){
                    detailpopupobj.refreshDetailHead();
                }

                var massConvert_popupobj = CrmPopup.load(restobj.title.value,'','','LdPopWidth600px',popupobj.module,'',arrJsPopLabel['CONFIRME'],'',arrJsPopLabel['CANCEL']);
                var massConvert_html = '<div id="massConvertcontent" class="pop_remind_content">'+restobj.log.value+'</div>';
                massConvert_popupobj.show(massConvert_html);
                ld('#'+massConvert_popupobj.divid+'_btnok').unbind('click').on('click',function(){
                    massConvert_popupobj.CancelEvent();
                    if(document.getElementById('allselectedboxes') != undefined){
                        document.getElementById('allselectedboxes').value='';
                    }
                    if(document.getElementById('selectedboxes') != undefined){
                        document.getElementById('selectedboxes').value='';
                    }
                    getListViewEntries_js('Accounts',restobj.start.value);//刷新页面
                });
                ld('#'+massConvert_popupobj.divid+'_btncancel').unbind('click').on('click',function(){
                    if(document.getElementById('allselectedboxes') != undefined){
                        document.getElementById('allselectedboxes').value='';
                    }
                    if(document.getElementById('selectedboxes') != undefined){
                        document.getElementById('selectedboxes').value='';
                    }
                    getListViewEntries_js('Accounts',restobj.start.value);//刷新页面
                });
			}
			return false;
		})
	}
	
	//公海参数设置
	this.set_account_public=function(){
        getJsScript('include/js/cls_publicpool_set.js', function () {
            var publicpool_setobj = new cls_publicpool_set('Accounts');
            publicpool_setobj.CreatePopup();
        });
	    return '';

		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=setPublicAccount';
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1) {
                crmPopupobj.setParams(data.result.title, that.save_account_public, "", "LdPopWidth800px", 'Settings', "", data.result.oktext, "", data.result.canceltext, "");
                crmPopupobj.createScrollDiv();
                crmPopupobj.show(data.result.content);
                that.account_pool = data.result.account_pool;
                that.default_pool = data.result.default_pool;
                //回收方案
                if (data.result.condition.length >= 1) {
                    var rowindex = 1;
                    ld.each((data.result.condition), function (index, info) {
                        var rowcount = ld("#" + crmPopupobj.divid + " [name=tablerulecondition]").find("tr").length;
                        var strhtml = '<tr class="lvtColData" detaildeleted = "no" rowindex="' + rowcount + '" name="tr_rowindex_' + rowcount + '">';
                        strhtml += '<input type="hidden" name="normal_json" value="" />';
                        //触发字段
                        strhtml += '<td style="margin:0 auto;text-align:center"><span name="normal_sequence">' + rowcount + '</span></td>';
                        //回收条件
                        strhtml += '<td valign="center" name="basicsearchtd">' + that.createbasicsearchtd(info, rowcount) + "</td>";
                        //回收规则
                        strhtml += '<td name="advancesearchtd">' + that.createruletd(info, rowcount) + "</td>";
                        //回收至公海
                        strhtml += '<td valign="center" style="overflow:inherit;white-space: inherit;" name="triggeroperatetd">' + that.createpools(info, rowcount) + "</td>";
                        //规则备注
                        strhtml += '<td valign="center" style="overflow:inherit;white-space: inherit;" name="triggeroperatetd"><input type="text" value="' + info.description + '" alt="" name="description" class="detailedViewTextBox"></td>';
                        //删除
                        if (rowcount > 1) {
                            strhtml += '<td><a href="javascript:;" tag="del_account_rule" childrowindex="' + rowcount + '" title="' + arrJsPopLabel['DELETE'] + '">' + arrJsPopLabel['DELETE'] + '</a></td>';
                        } else {
                            strhtml += '<td></td>';
                        }

                        strhtml += "</tr>";
                        ld("#" + crmPopupobj.divid + " [name=tablerulecondition]").append(strhtml);
                        that.setrowevent(rowcount);
                    })
                }
                crmPopupobj.setScrollDivMaxHeight();
                crmPopupobj.center();
                that.set_account_public_bind();
            }
        })
    }

    //回收条件
    this.createbasicsearchtd = function (info, rowindex) {
        var popupobj = CrmPopup.getPopupObj('last');
        if (info.advfilter == undefined || info.advfilter == 'undefined'){
			info.advfilter = '';
		}
		if(info.advfilter_grouping == undefined || info.advfilter_grouping == 'undefined'){
			info.advfilter_grouping = '';
		}
		var divid=popupobj.divid;
		var strhtml="";
		strhtml+=' <div style="margin:0 auto;text-align:center">';
		strhtml+='<img src="themes/images/add.png" style="width:28px;height:28px" tag="editbasicsearch" basicsearch_normal_id="'+rowindex+'" advft_criteria=\''+info.advfilter+'\' advft_criteria_groups=\''+info.advfilter_grouping+'\' childrowindex="'+rowindex+'"/>';
		strhtml+='</div>';
		return strhtml;
    }
    
    //回收规则
    this.createruletd=function(info,rowindex)
    {
		if(info.rule_json == undefined || info.rule_json == 'undefined'){
			info.rule_json = '';
		}
        var strhtml="";
        strhtml+=' <div style="margin:0 auto;text-align:center">';
        strhtml+='<img src="themes/images/add.png" style="width:28px;height:28px" tag="editrule" rule_normal_id="'+rowindex+'" normal_rule_json=\''+info.rule_json+'\' childrowindex="'+rowindex+'"/>';
        strhtml+='</div>';
        return strhtml;
       
    }

	//回收至公海
	this.createpools=function(info,rowindex)
    {
        var strhtml="";
        strhtml+=' <div style="margin:0 auto;text-align:center">';
		if(that.account_pool != undefined && that.account_pool != 'undefined'){
			strhtml += '<select class="btn-radius-system" name="select_poolid" style="width: 150px;">';
			ld.each(that.account_pool,function(index,pool_info){
				if(pool_info.pool_id == info.pool_id)
					strhtml += '<option value="'+pool_info.pool_id+'" tag="1" selected>'+pool_info.pool_name+'</option>';
				else{
					strhtml += '<option value="'+pool_info.pool_id+'" tag="1">'+pool_info.pool_name+'</option>';
				}
			});
			strhtml += '</select>';
		}
        strhtml+='</div>';
        return strhtml;
       
    }

	//新增布局规则列表行的事件
    this.setrowevent=function(rowindex)
    {
		var popupobj=CrmPopup.getPopupObj('last');
		var divid=popupobj.divid;
		var tableobj=ld("#"+popupobj.divid+" [name=tablerulecondition]");
		var objs= tableobj.find(" [childrowindex="+rowindex+"]");
		var rowobj=ld("#"+divid+" [rowindex="+rowindex+"]");
        ld.each(objs,function(index,obj){
			ld(obj).unbind('click').bind('click',function(){
                var thatobj=this;
                switch(ld(this).attr("tag"))
                {
					case "editbasicsearch":
						that.show_account_basicsearch_pop(ld(this));	//回收条件
						break;
					case 'editrule':
						that.show_account_normal_rule(ld(this));	//回收规则
						break;
					case 'del_account_rule':
						that.delete_account_normal_tr(ld(this));
						break;
                } 
            });
        });
    }

	//回收方案 - 删除
	this.delete_account_normal_tr = function(obj){
		var popupobj=CrmPopup.getPopupObj('last');
		var divid=popupobj.divid;
		ld("#"+popupobj.divid+" [name=tr_rowindex_"+obj.attr('childrowindex')+"]").hide();
		ld("#"+popupobj.divid+" [name=tr_rowindex_"+obj.attr('childrowindex')+"]").attr('detaildeleted','yes');
		var tableobj=ld("#"+popupobj.divid+" [name=tablerulecondition]");
		var trobjs=ld(tableobj).find("tr[detaildeleted=no]");
		var squence = 1;
		ld.each(ld(trobjs),function(){
			ld(this).find("[name=normal_sequence]").html(squence);
			squence++;
		});
	}

	//回收条件 - 保存
	this.save_account_normal_basicsearch = function(){
		var prev_popupobj=CrmPopup.getPopupObj('lastprev');
		var popupobj=CrmPopup.getPopupObj('last');
		var divid=popupobj.divid;
		var normal_id = ld("#"+popupobj.divid+" [name=normal_id]").val();
		if(popupobj.highersearchobj.checkAdvancedFilter()==false) 
		{
				return false;
		}
		var advft_criteria = ld("#"+popupobj.divid+" [name=advft_criteria]").val();
		var advft_criteria_groups = ld("#"+popupobj.divid+" [name=advft_criteria_groups]").val();
		ld("#"+prev_popupobj.divid+" [basicsearch_normal_id="+normal_id+"]").attr('advft_criteria',advft_criteria);
		ld("#"+prev_popupobj.divid+" [basicsearch_normal_id="+normal_id+"]").attr('advft_criteria_groups',advft_criteria_groups);
		popupobj.CancelEvent();
		return false;
	}

	
	//回收条件 - 显示
	this.show_account_basicsearch_pop = function(obj){
		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=setNormalAccountBasicSearch';
		surl += '&normal_id='+obj.attr('basicsearch_normal_id');
		surl += '&advft_criteria='+encodeURIComponent(obj.attr('advft_criteria'));
		surl += '&advft_criteria_groups='+obj.attr('advft_criteria_groups');
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.save_account_normal_basicsearch,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,""); 
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
				crmPopupobj.highersearchobj=new HigherSearchGroup("adv_filter_div");
                crmPopupobj.highersearchobj.columns_block=data.result.columns_block;//查询字段
                crmPopupobj.highersearchobj.fLabels=data.result.flabels;//查询条件下拉框（等于，不等于，区间 ，大于)
                crmPopupobj.highersearchobj.source=data.result.source;
                crmPopupobj.highersearchobj.foption=data.result.foption;//查询条件下拉框的html
                crmPopupobj.highersearchobj.criteria_groups=data.result.criteria_groups;//高级查询
                crmPopupobj.highersearchobj.mandatorycheck=data.result.mandatorycheck;
                crmPopupobj.showvalues=data.result.showvalues;
                crmPopupobj.datetimestr=data.result.datetimestr;//基本查询
                crmPopupobj.viewnamelabel=data.result.viewnamelabel;
                crmPopupobj.modulelabel=data.result.modulelabel;
                crmPopupobj.highersearchobj.btn_addnewcondtiontext=data.result.btn_addnewcondtiontext;//高级查询 新条件 按钮文字
                crmPopupobj.highersearchobj.btn_addnewcombinationtext=data.result.btn_addnewcombinationtext;//高级查询　“新组合"按钮文字
				var  fori=0;
                if(data.result.criteria_groups)
           	    {
                   	      
					ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
						var GROUP_COLUMNS=GROUP_CRITERIA.columns;
						crmPopupobj.highersearchobj.addConditionGroup();
							ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
								crmPopupobj.highersearchobj.addConditionRow(GROUP_ID);
								var advft_column_index_count=crmPopupobj.highersearchobj.advft_column_index_count;
								var conditionColumnRowElement = CrmPopup.findHtmlobj(crmPopupobj.divid,'fcol'+advft_column_index_count);
								conditionColumnRowElement.val(COLUMN_CRITERIA.columnname) ;
								//zkt 20230519 公海回收条件-编辑-对应高级查找条件
                                var text = conditionColumnRowElement.find("option:selected").text();
                    			if(CrmPopup.findHtmlobj(crmPopupobj.divid,"cmb_span_optiontext_fcol"+advft_column_index_count).length>0){
                                    CrmPopup.findHtmlobj(crmPopupobj.divid,"cmb_span_optiontext_fcol"+advft_column_index_count).val(text);
                                }
								crmPopupobj.highersearchobj.updatefOptions(conditionColumnRowElement, 'fop'+advft_column_index_count);
								CrmPopup.findHtmlobj(crmPopupobj.divid, 'fop'+advft_column_index_count).val(COLUMN_CRITERIA.comparator);
								crmPopupobj.highersearchobj.addRequiredElements(advft_column_index_count);
								var columnvalue = COLUMN_CRITERIA.value;
								if(COLUMN_CRITERIA.comparator == 'bw' && columnvalue != '') {
									var values = columnvalue.split(",");
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(values[0]) ;
									if(values.length == 2 && CrmPopup.isExistsObj(crmPopupobj.divid,'fval_ext'+advft_column_index_count))
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval_ext'+advft_column_index_count).val(values[1]) ;
								}
								else 
								{
									if(columnvalue =='Accepted')
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Accepted);
									else if(columnvalue =='Rejected')
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val(alert_arr.Rejected);
									else{
										var values = columnvalue.split(",");
										CrmPopup.findHtmlobj(crmPopupobj.divid,'fval'+advft_column_index_count).val( values[0]);
									}
								}
							});
								
							ld.each(GROUP_COLUMNS,function(COLUMN_INDEX,COLUMN_CRITERIA){
							   //查询字段下拉框
								if(CrmPopup.isExistsObj(crmPopupobj.divid,'fcon'+fori)) 
									CrmPopup.findHtmlobj(crmPopupobj.divid,'fcon'+fori).val(COLUMN_CRITERIA.column_condition);
								  fori=fori+1;
							});
								
						});
						ld.each(data.result.criteria_groups,function(GROUP_ID,GROUP_CRITERIA){
							//组 且/或
							var GROUP_CRITERIA=data.result.criteria_groups[GROUP_ID];
							if(CrmPopup.isExistsObj(crmPopupobj.divid,'gpcon'+GROUP_ID)) 
								CrmPopup.findHtmlobj(crmPopupobj.divid,'gpcon'+GROUP_ID).val(GROUP_CRITERIA.condition);
					   });
					   
				}
				else
					crmPopupobj.highersearchobj.addNewConditionGroup();
				crmPopupobj.setScrollDivMaxHeight();
				crmPopupobj.center();
			}
		});
	}

	//回收规则 - 显示
	this.show_account_normal_rule = function(obj){
		var surl = 'index.php?module=Accounts&action=AccountsAjax&file=setNormalAccountRule';
		surl += '&normal_id='+obj.attr('rule_normal_id');
		surl += '&normal_rule_json='+obj.attr('normal_rule_json');
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,"",function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.save_account_normal_rule,"","LdPopWidth650px",'Settings',"",data.result.oktext,"",data.result.canceltext,""); 
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
				that.arr_recovery_modules = data.result.arr_recovery_modules;	//回收模块
				//公海客户参与回收，回收规则条件逻辑关系
				ld("#"+crmPopupobj.divid+" [name=completeopt]").unbind('change').on('change',function(){
					if(ld(this).val() == 'and'){
						ld("#"+crmPopupobj.divid+" [name=completeopt_and]").show();
						ld("#"+crmPopupobj.divid+" [name=completeopt_or]").hide();
					}else{
						ld("#"+crmPopupobj.divid+" [name=completeopt_and]").hide();
						ld("#"+crmPopupobj.divid+" [name=completeopt_or]").show();
					}
				})
			}
		});
	}
	//回收规则 - 保存
	this.save_account_normal_rule = function(){
		var prev_popupobj=CrmPopup.getPopupObj('lastprev');
		var popupobj=CrmPopup.getPopupObj('last');
		var divid=popupobj.divid;
		var daysbol = true;
		var account_rule = [];
		var completeopt = ld("#"+popupobj.divid+" [name=completeopt]").val();
		var normal_id = ld("#"+popupobj.divid+" [name=normal_id]").val();
		if(that.arr_recovery_modules.length >= 1){
			ld.each(that.arr_recovery_modules,function(index,tmpmodule){
				if(ld("#"+popupobj.divid+" [name="+tmpmodule+"_completechk]").prop("checked")){
					if(ld("#"+popupobj.divid+" [name=changerule_complete_"+tmpmodule+"]").val()=='no')
					{
						//单次回收
						var textvalue=ld("#"+popupobj.divid+" [name="+tmpmodule+"_single_completedays]").val();
					}
					else
					{
						//循环回收
						//ContactRecords_completedays
						var textvalue=ld("#"+popupobj.divid+" [name="+tmpmodule+"_completedays]").val();
					}
					if((!/^\d+$/.test(textvalue)||textvalue<1))
					{
						daysbol=false;
						return false;
					}
				}
				var completechk = 'inactive';
				if(ld("#"+popupobj.divid+" [name="+tmpmodule+"_completechk]").prop("checked")){
					completechk = 'active';
				}
				//单次  循环回收
				var changerule_complete = 'no';
				var completedays = ld("#"+popupobj.divid+" [name="+tmpmodule+"_single_completedays]").val();
				if(ld("#"+popupobj.divid+" [name=changerule_complete_"+tmpmodule+"]").val()=='yes'){
					changerule_complete = 'yes';
					completedays = ld("#"+popupobj.divid+" [name="+tmpmodule+"_completedays]").val();
				}
				
				var account_rule_str = completechk+'_'+changerule_complete+'_'+completedays+'_'+completeopt+'_'+tmpmodule;
				account_rule.push(account_rule_str);
			 })
			if(!daysbol)
			{
				account_rule = [];
				confirm_str = ld("#"+popupobj.divid+" [name=auto_recovery_rule_label]").val() + arrJsPopLabel['DAYSMUSTGREATERQUZERO'];
				audioRemindsMsg("","","","","",confirm_str);
				return false;
			}
			
		}
		ld("#"+prev_popupobj.divid+" [rule_normal_id="+normal_id+"]").attr('normal_rule_json',JSON.stringify(account_rule));
		popupobj.CancelEvent();
		return false;
	}
    this.showKehu001UserName=function(){
       
        if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                     //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
    }
	//公海参数设置界面按钮事件绑定
	this.set_account_public_bind=function(){
		var popupobj=CrmPopup.getPopupObj("last");
		//公海设置
        
        this.showKehu001UserName();
        //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块
        //普通客户数量上限
        ld("#"+popupobj.divid+" [name=limit_type]").unbind('click').on('click',function(){
            var limit_type = ld(this).attr('value');
            if(limit_type == 'role'){
                ld("#"+popupobj.divid+" [name=select_limit_type_role]").show();
                ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',true);
            }else if(limit_type == 'user'){
                ld("#"+popupobj.divid+" [name=select_limit_type_role]").hide();
                ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',false);
            }else{//不限制
                ld("#"+popupobj.divid+" [name=select_limit_type_role]").hide();
                ld("#"+popupobj.divid+" [name=limit_count]").attr('disabled',true);
            }
        });

		ld("#"+popupobj.divid+" [type=checkbox]").unbind('click').on('click',function(){
			var that_check = this;
			var check_name = ld(that_check).attr('name');
			if(ld(that_check).is(':checked') == true){
				//勾选“启用公海”时，下面增加选项：显示“全部（含所有公海）页签，默认勾选
				if(check_name == 'status'){
					ld("#"+popupobj.divid+" [name=div_show_publicaccount_tab]").show();
					ld("#"+popupobj.divid+" [name=show_publicaccount_tab]").prop('checked',true);
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").show();
					ld("#"+popupobj.divid+" [name=div_show_commonaccount_tab]").show();
					ld("#"+popupobj.divid+" [name=common_account_rule_table]").show();
					ld("#"+popupobj.divid+" [name=show_commonaccount_tab]").prop('checked',true);
					ld("#"+popupobj.divid+" [name=div_is_commonaccount_create]").show();
					ld("#"+popupobj.divid+" [name=is_commonaccount_create]").prop('checked',true);
					ld("#"+popupobj.divid+" [name=div_show_default_tab]").show();//设置默认页签
                    // ld("#"+popupobj.divid+" [name=div_show_default_tab] option[value='COMMONACCOUNT']").prop("selected", true);

                }
				//如果勾选“显示“全部（含所有公海）页签”参数，则下面增加选项：默认“全部（含所有公海）页签。默认不勾选
				if(check_name == 'show_publicaccount_tab'){
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").show();
					//ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").prop('checked',false);
				}
				if(check_name == 'account_rule'){
					ld("#"+popupobj.divid+" [name=account_rule_div]").show();
                    ld("#"+popupobj.divid+" [name=tablerulecondition]").show();
				}
				
			}else{
				if(check_name == 'status'){
					ld("#"+popupobj.divid+" [name=div_show_publicaccount_tab]").hide();
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").hide();
					ld("#"+popupobj.divid+" [name=show_publicaccount_tab]").prop('checked',false);
					//ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").prop('checked',false);
					ld("#"+popupobj.divid+" [name=account_rule_div]").hide();
					ld("#"+popupobj.divid+" [name=account_rule]").prop('checked',false);
					ld("#"+popupobj.divid+" [name=div_show_commonaccount_tab]").hide();
					ld("#"+popupobj.divid+" [name=common_account_rule_table]").hide();
                    //edit:can 20210409 45412: （https://61mis.com/kfbcrm [^]）公海参数设置弹出层中，启用公海再反勾选不启用公海时，“允许新建“普通客户””参数应该不显示
                    ld("#"+popupobj.divid+" [name=is_commonaccount_create]").prop('checked',false);
                    
                    ld("#"+popupobj.divid+" [name=div_is_commonaccount_create]").hide();
                    ld("#"+popupobj.divid+" [name=div_show_default_tab]").hide();//设置默认页签
                    
				}
				if(check_name == 'show_publicaccount_tab'){
					//ld("#"+popupobj.divid+" [name=div_default_publicaccount_tab]").hide();
					//ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").prop('checked',false);
				}
				if(check_name == 'account_rule'){
					ld("#"+popupobj.divid+" [name=account_rule_div]").hide();
				}
			}
			popupobj.setScrollDivMaxHeight();
			popupobj.center();
		});
		//绑定公海超级管理员删除事件
		if(ld('#'+popupobj.divid+' ul.reader-bar-list .remove-h') != undefined){
			ld('#'+popupobj.divid+' ul.reader-bar-list .remove-h').unbind('click').click(function(){
				var remove_userid = ld(this).parent().attr('itemid');
				ld(this).parent().remove();
				var select_administrators_ids = [];
				var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
				select_administrators_ids = select_administrators_id.split(',');
				select_administrators_ids.splice(ld.inArray(remove_userid,select_administrators_ids),1);
				ld("#"+popupobj.divid+" [name=select_administrators_id]").val(select_administrators_ids.join(','));
				return false;
			});
		}
		//新增回收方案
		ld("#"+popupobj.divid+" [name=create_recyclingscheme]").unbind('click').on('click',function(){
            //wym BUG0074214 kfbcrm-公海参数设置- 启用普通客户自动回收规则-新增回收方案-删除行-再点击新增，新增行序数错误
			var rowcount=ld("#"+popupobj.divid+" [name=tablerulecondition]").find("tr").not("[detaildeleted=yes]").length;
			var strhtml='<tr class="lvtColData" detaildeleted="no" name="tr_rowindex_'+rowcount+'" rowindex="'+rowcount+'">';
			strhtml += '<input type="hidden" name="normal_json" value="" />';
			//触发字段
			strhtml+='<td style="margin:0 auto;text-align:center"><span name="normal_sequence">'+rowcount+'</span></td>';
			//回收条件
			strhtml+='<td valign="center" name="basicsearchtd">'+that.createbasicsearchtd([],rowcount)+"</td>";
			//回收规则
			strhtml+='<td name="advancesearchtd">'+that.createruletd([],rowcount)+"</td>";
			//回收至公海
            var default_pool = {
                'pool_id' : that.default_pool,
            }
			strhtml+='<td valign="center" style="overflow:inherit;white-space: inherit;" name="triggeroperatetd">'+that.createpools(default_pool,rowcount)+"</td>";
			//规则备注
			strhtml+='<td valign="center" style="overflow:inherit;white-space: inherit;" name="triggeroperatetd"><input type="text" value="" alt="" name="description" class="detailedViewTextBox"></td>';
			//删除
			if(rowcount > 1){
				strhtml += '<td><a href="javascript:;" tag="del_account_rule" childrowindex="'+rowcount+'" title="'+arrJsPopLabel['DELETE']+'">'+arrJsPopLabel['DELETE']+'</a></td>';
			}else{
				strhtml += '<td></td>';
			}
			strhtml+="</tr>";
			ld("#"+popupobj.divid+" [name=tablerulecondition]").append(strhtml);
			that.setrowevent(rowcount);
			popupobj.setScrollDivMaxHeight();
			popupobj.center();
		});
		that.set_account_public_select_user_bind();
		
	}

	//公海超级管理员
	this.set_account_public_select_user_bind=function(){
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name=select_administrators],[name=select_administrators_div]").unbind('click').on('click',function(){
			var scopepopupobj;//自定义弹出层页面html，绑定事件
			var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
			var module = 'Accounts';
			var select_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
			getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
				scopepopupobj =  new ScopePopupObj(module);
				scopepopupobj.popup_caption_value = popup_caption_value;//标题title
				getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
				   cls_ScopePopup.prop.popup_module = module;//模块
				   cls_ScopePopup.prop.popup_value = select_id;
				   cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=public&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
				   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
					//重写确认按钮事件
					scopepopupobj.setEventBtnOk=function(){
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
							if(empty(cls_ScopePopup.return_obj.return_id)){
								var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
								// RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                MessagePopup.TipOne_warning(confirm_str);
								return false;
							}else{
								ld("#"+popupobj.divid+" [name=select_administrators_id]").val(cls_ScopePopup.return_obj.return_id);
								ld("#"+popupobj.divid+" [name=select_administrators_name]").html(cls_ScopePopup.return_obj.return_name);
								var userid = cls_ScopePopup.return_obj.return_id.split(',');
								var username = cls_ScopePopup.return_obj.return_name.split(',');
								//每次确认之前，先情况之前记录
								ld('#'+popupobj.divid+' ul.reader-bar-list').empty();
								for(var i = 0; i < userid.length; i++){
									//添加新的li
									ld('#'+popupobj.divid+' ul.reader-bar-list').append('<li userid="'+userid[i]+'"><span class="item-name">'+username[i]+'</span><span class="remove-h">×</span></li>');
									//绑定删除事件
									ld('#'+popupobj.divid+' ul.reader-bar-list li[userid='+userid[i]+'] .remove-h').unbind('click').click(function(){
										var liuserid = ld(this).parent().attr('userid');
										ld('#'+popupobj.divid+' ul.reader-bar-list li[userid='+liuserid+']').remove();
										return false;
									});
								}
								ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
							}
                            that.showKehu001UserName();
						});
                         
					}
				});
			});
		});
	}
	this.changeRule = function(type,tabname,obj)
	{
		var selectindex=obj.selectedIndex;
		var selectvalue=obj.options[selectindex].value;
		if(selectvalue=='yes')
		{
			var spanname=type+'_'+tabname+'_span_recycle';
			var hidespanname=type+'_'+tabname+'_span_single';
		}
		else
		{
			var spanname=type+'_'+tabname+'_span_single';
			var hidespanname=type+'_'+tabname+'_span_recycle';
		}
		var popupobj=CrmPopup.getPopupObj("last");
		ld("#"+popupobj.divid+" [name="+spanname+"]").show();
		ld("#"+popupobj.divid+" [name="+hidespanname+"]").hide();
	}
	//公海参数设置 - 保存
	this.save_account_public=function(){
        var expre=/^[0-9]*[1-9][0-9]*$/;
		var popupobj=CrmPopup.getPopupObj("last");
		var _status = 'no';
		var show_publicaccount_tab = 'no';
		var default_publicaccount_tab = 'no';
		var before_status = 'no';
		var show_commonaccount_tab = 'no';
		var show_account_rule = 'no';
		var is_commonaccount_create = 'no';

        //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（公海参数设置保存）
        //普通客户数量上限
        var limit_type = ld("#"+popupobj.divid+" [name=limit_type]:checked").val();
        var limit_count = ld("#"+popupobj.divid+" [name=limit_count]").val();
        if(limit_type == 'user'){
            if(!(expre.test(trim(limit_count)))){
                audioRemindsMsg("","","","","",ld("#"+popupobj.divid+" [name=limit_count]").attr('label')+arrJsPopLabel['CONTENTCANOTEMPTY']);
                ld("#"+popupobj.divid+" [name=limit_count]").focus();
                return false;
            }
        }
		//启用公海
		if(ld("#"+popupobj.divid+" [name=status]").is(':checked') == true){
			_status = 'yes';
		}
		//显示 “全部（含所有公海）”页签
		if(ld("#"+popupobj.divid+" [name=show_publicaccount_tab]").is(':checked') == true){
			show_publicaccount_tab = 'yes';
		}
		//默认 “全部（含所有公海）”页签 
		/*if(ld("#"+popupobj.divid+" [name=default_publicaccount_tab]").is(':checked') == true){
			default_publicaccount_tab = 'yes';
		}*/
		//显示 “全部（普通客户）”页签 
		if(ld("#"+popupobj.divid+" [name=show_commonaccount_tab]").is(':checked') == true){
			show_commonaccount_tab = 'yes';
		}
		//普通客户自动回收规则设置
		if(ld("#"+popupobj.divid+" [name=account_rule]").is(':checked') == true){
			show_account_rule = 'yes';
		}
		//允许创建普通客户
		if(ld("#"+popupobj.divid+" [name=is_commonaccount_create]").is(':checked') == true){
			is_commonaccount_create = 'yes';
		}
		if(ld("#"+popupobj.divid+" [name=before_status]").val() != undefined){
			before_status = ld("#"+popupobj.divid+" [name=before_status]").val();
		}
		//公海超级管理员设置
		var select_administrators_id = ld("#"+popupobj.divid+" [name=select_administrators_id]").val();
		if(select_administrators_id == '' && _status == 'yes'){
			RemindsMsg("","LdPopWidth400px",'',"yes","yes",arrJsPopLabel['Pleasesettheadministratorsjspop1']);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				ld("#"+popupobj.divid+" [name=select_administrators]").click();
			})
			return false;
		}
		if(_status == 'no'){
			show_publicaccount_tab = 'no';
			default_publicaccount_tab = 'no';
			select_administrators_id = '';
		}

		//您启用了公海客户，需要设置回收条件
		var  atleastonechoose=false;
		if(show_account_rule == 'yes'){
			var normal_array = [];
			var tableobj=ld("#"+popupobj.divid+" [name=tablerulecondition]");
			var trobjs=ld(tableobj).find("tr[detaildeleted=no]");
			ld.each(ld(trobjs),function(){
				var normal_array_row = [];
				var advft_criteria = ld(this).find("[tag=editbasicsearch]").attr('advft_criteria');
				var advft_criteria_groups = ld(this).find("[tag=editbasicsearch]").attr('advft_criteria_groups');
				normal_array_row.push(advft_criteria);
				normal_array_row.push(advft_criteria_groups);
				var normal_rule = ld(this).find("[tag=editrule]").attr('normal_rule_json');
				normal_array_row.push(normal_rule);
				var select_poolid = ld(this).find("[name=select_poolid]").val();
				normal_array_row.push(select_poolid);
				var description = ld(this).find("[name=description]").val();
				normal_array_row.push(description);
				normal_array.push(JSON.stringify(normal_array_row));
			});
			ld("#"+popupobj.divid+" [name=normal_json]").val(JSON.stringify(normal_array));
		}
		var form_data = new FormData(ld("#"+popupobj.divid+" [name=save_public_account]")[0]);
		ld('#rptContentLoading').show();
		ld.ajax({
			type: 'POST',
			dataType: 'json',
			processData: false, // 告诉jquery不要处理数据
			contentType: false, // 告诉jquery不要设置contentType
			data: form_data,
			url: 'index.php?module=Accounts&action=AccountsAjax&file=savePublicAccount',
			success: function(data) {
                ld('#rptContentLoading').hide();
				popupobj.CancelEvent();
                var module = getUrlParam("pageto_module");
                //@edit:zhaosk @date:2024/08/08 @reason:后台设置引导页处显示管理看板弹窗，module做特殊处理
                if(module=='Settings') {
                    return ;
                }
				var tmparra=new Array();
				var tmpobj= new AfterUpdatePrevPopupObjContent('Accounts',"",tmparra);
				//服务单保存后刷新服务单的历史记录(查看界面)
				var refreshlistmodules = new Array('Accounts');
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				return false;
				
			},
			error: function(xhr, textStatus, errorThrown) {
				//alert(2);
			}
		  })
		return false;

	
    }
}

var cls_PublicAccount = new cls_PublicAccount();
