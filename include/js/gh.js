/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
function getSelected(txtid){
    cbobj=document.getElementsByName('cb_select_user');
    txtidobj=document.getElementById(txtid);
    txtobj=document.getElementById('txt_select_user');
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
        txtobj.value=txtobj_str;
        txtidobj.value=txtidobj_str;
    }
}
function showCalc(fldName) {
	var currObj=getObj(fldName)
	openPopUp("calcWin",currObj,"/crm/Calc.do?currFld="+fldName,"Calc",170,220,"menubar=no,toolbar=no,location=no,status=no,scrollbars=no,resizable=yes")
}

function showLookUp(fldName,fldId,fldLabel,searchmodule,hostName,serverPort,username) {
	var currObj=getObj(fldName)

	//var fldValue=currObj.value.replace(/^\s+/g, '').replace(/\s+$/g, '')

	//need to pass the name of the system in which the server is running so that even when the search is invoked from another system, the url will remain the same

	openPopUp("lookUpWin",currObj,"/crm/Search.do?searchmodule="+searchmodule+"&fldName="+fldName+"&fldId="+fldId+"&fldLabel="+fldLabel+"&fldValue=&user="+username,"LookUp",500,400,"menubar=no,toolbar=no,location=no,status=no,scrollbars=yes,resizable=yes")
}
function setExpandCollapse_gen()
{
	var x = leftpanelistarray.length;
	for (i = 0 ; i < x ; i++)
	{
		var listObj=getObj(leftpanelistarray[i])
		var tgImageObj=getObj("img_"+leftpanelistarray[i])
		var status = get_cookie_gen(leftpanelistarray[i])

		if (status == "block") {
			listObj.style.display="block";
			tgImageObj.src="themes/images/toggle2.gif";
		} else if(status == "none") {
			listObj.style.display="none";
			tgImageObj.src="themes/images/toggle1.gif";
		}
	}
}

function showLocateMapMenu()
{
	getObj("dropDownMenu").style.display="block"
	getObj("dropDownMenu").style.left=findPosX(getObj("locateMap"))
	getObj("dropDownMenu").style.top=findPosY(getObj("locateMap"))+getObj("locateMap").offsetHeight
}


function hideLocateMapMenu(ev)
{
	if (browser_ie)
		currElement=window.event.srcElement
	else if (browser_nn4 || browser_nn6)
		currElement=ev.target

	if (currElement.id!="locateMap")
		if (getObj("dropDownMenu").style.display=="block")
			getObj("dropDownMenu").style.display="none"
}
function getCalendarPopup(imageid,fieldid,dateformat)
{
	Calendar.setup ({
		inputField : fieldid,
		ifFormat : dateformat,
		showsTime : false,
		button : imageid,
		singleClick : true,
		step : 1
	});
}

function rel_toggleSelectAll_Records(module,relmodule,state,relCheckName) {

	 rel_toggleSelect(state,relCheckName,relmodule);
	 if(state == true) {
		$(module+'_'+relmodule+'_selectallActivate').value = 'true';
		$(module+'_'+relmodule+'_selectAllRec').style.display = 'none';
		$(module+'_'+relmodule+'_deSelectAllRec').style.display = 'inline';
	} else {
		$(module+'_'+relmodule+'_selectallActivate').value = 'false';
		$(module+'_'+relmodule+'_excludedRecords').value = '';
		$(module+'_'+relmodule+'_selectCurrentPageRec').checked = false;
		$(module+'_'+relmodule+'_selectAllRec').style.display = 'inline';
		$(module+'_'+relmodule+'_deSelectAllRec').style.display = 'none';
		$(module+'_'+relmodule+'_linkForSelectAll').hide();
	}
}
function fnvshobjsearch(obj,Lay){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	if(Lay == 'editdiv')
	{
		leftSide = leftSide - 225;
		topSide = topSide - 125;
	}else if(Lay == 'transferdiv')
	{
		leftSide = leftSide - 10;
		topSide = topSide;
	}
	var IE = document.all?true:false;
	if(IE) {
		if($("repposition1")) {
			if(topSide > 1200) {
				topSide = topSide-250;
			}
		}
	}

	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ) {
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 91 + 'px';
	} else {
		tagName.style.left= leftSide - 324 + 'px';
	}
	tagName.style.top= topSide + 33 + 'px';
	tagName.style.display = 'block';
	tagName.style.visibility = "visible";
}
function fnDropDownUser(obj,Lay){
	var tagName = document.getElementById(Lay);
	var leftSide = findPosX(obj);
	var topSide = findPosY(obj);
	var maxW = tagName.style.width;
	var widthM = maxW.substring(0,maxW.length-2);
	var getVal = eval(leftSide) + eval(widthM);
	if(getVal  > document.body.clientWidth ){
		leftSide = eval(leftSide) - eval(widthM);
		tagName.style.left = leftSide + 34 + 'px';
	}
	else
		tagName.style.left= leftSide  - 50 + 'px';
		tagName.style.top= topSide + 28 +'px';
		tagName.style.display = 'block';
}

function fnDropDownUsers(obj,Lay,topY){
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
function calQCduedatetime()
{
	var datefmt = document.QcEditView.dateFormat.value;
	var type = document.QcEditView.activitytype.value;
	var dateval1=getObj('date_start').value.replace(/^\s+/g, '').replace(/\s+$/g, '');
	var dateelements1=splitDateVal(dateval1);
	dd1=parseInt(dateelements1[0],10);
	mm1=dateelements1[1];
	yyyy1=dateelements1[2];
	var date1=new Date();
	date1.setYear(yyyy1);
	date1.setMonth(mm1-1,dd1+1);
	var yy = date1.getFullYear();
	var mm = date1.getMonth() + 1;
	var dd = date1.getDate();
	var date = document.QcEditView.date_start.value;
	var starttime = document.QcEditView.time_start.value;
	if (!timeValidate('time_start',' Start Date & Time','OTH'))
		return false;
	var timearr = starttime.split(":");
	var hour = parseInt(timearr[0],10);
	var min = parseInt(timearr[1],10);
	dd = _2digit(dd);
	mm = _2digit(mm);
	var tempdate = yy+'-'+mm+'-'+dd;
	if(datefmt == '%d-%m-%Y')
		var tempdate = dd+'-'+mm+'-'+yy;
	else if(datefmt == '%m-%d-%Y')
		var tempdate = mm+'-'+dd+'-'+yy;
	if(type == 'Meeting')
	{
		hour = hour + 1;
		if(hour == 24)
		{
			hour = 0;
			date =  tempdate;
		}
		hour = _2digit(hour);
		min = _2digit(min);
		document.QcEditView.due_date.value = date;
		document.QcEditView.time_end.value = hour+':'+min;
	}
	if(type == 'Call')
	{
		if(min >= 55)
		{
			min = min%55;
			hour = hour + 1;
		}else min = min + 5;
		if(hour == 24)
		{
			hour = 0;
			date =  tempdate;
		}
		hour = _2digit(hour);
		min = _2digit(min);
		document.QcEditView.due_date.value = date;
		document.QcEditView.time_end.value = hour+':'+min;
	}

}


function fnCpy(){

	var tagName=document.getElementById("cpy");

	if(tagName.checked==true){
		fnCopy("shipaddress","address");

		fnCopy("shippobox","pobox");

		fnCopy("shipcity","city");

		fnCopy("shipcode","code");

		fnCopy("shipstate","state");

		fnCopy("shipcountry","country");

	}

	else{

		fnClear("shipaddress");

		fnClear("shippobox");

		fnClear("shipcity");

		fnClear("shipcode");

		fnClear("shipstate");

		fnClear("shipcountry");

	}

}
//add by tifa 20130226 for reminds
//联系记录和日程使用
function reset_remindtime(type){
    if(type==0&&getObj('email_remind')!=null){
        txt_hour=getObj('email_remind_hr').options[getObj('email_remind_hr').options.selectedIndex].value;
        txt_min=getObj('email_remind_min').options[getObj('email_remind_min').options.selectedIndex].value;
        if(getObj('date_start')!=null &&getObj('date_start').value!="" )
        {
            txt_date=getObj('date_start').value.split('-'); 
            //alert(getObj('date_start').value);
        }
         
        else if(getObj('nextcontactdate')!=null&&getObj('nextcontactdate').value!='' && getObj('nextcontactdate').value!=undefined)
        txt_date=getObj('nextcontactdate').value.split('-'); 
        else  if(getObj('nextcontactdate')!=null)
        txt_date=getObj('email_date_only').value.split('-');   
        else 
        txt_date=getObj('email_date_only').value.split('-');
        
        pre_time=new Date(txt_date[0],txt_date[1]-1,txt_date[2],txt_hour,txt_min);
        pre_time.setMinutes(pre_time.getMinutes()-5); 
        now_mon=pre_time.getMonth()+1;
        getObj('email_remind').value= pre_time.getFullYear()+'-'+now_mon+'-'+pre_time.getDate();
        //getObj('email_date_only').value= pre_time.getFullYear()+'-'+now_mon+'-'+pre_time.getDate();
        now_hour=pre_time.getHours();
        now_min=pre_time.getMinutes();
        hr_op=getObj('email_remind_hr');
        for(i=0;i<hr_op.options.length;i++){
            if(hr_op.options[i].value==now_hour){
                hr_op.options.selectedIndex=i;
            }
        }
        min_op=getObj('email_remind_min');
        for(i=0;i<min_op.options.length;i++){
            if(min_op.options[i].value==now_min){
                min_op.options.selectedIndex=i;
            }
        }
    }else if(type==1&&getObj('date_time')!=null){
        txt_hour=getObj('date_time_hr').options[getObj('date_time_hr').options.selectedIndex].value;
        txt_min=getObj('date_time_min').options[getObj('date_time_min').options.selectedIndex].value;
        if(getObj('date_time')!=null)
        txt_date=getObj('date_time').value.split('-');  
        else if(getObj('nextcontactdate')!=null&&getObj('nextcontactdate').value!='')
        txt_date=getObj('nextcontactdate').value.split('-'); 
        else 
        txt_date=getObj('date_only').value;          
        pre_time=new Date(txt_date[0],txt_date[1]-1,txt_date[2],txt_hour,txt_min);
        pre_time.setMinutes(pre_time.getMinutes()-5); 
        now_mon=pre_time.getMonth()+1;
        getObj('date_time').value= pre_time.getFullYear()+'-'+now_mon+'-'+pre_time.getDate();
        getObj('date_only').value= pre_time.getFullYear()+'-'+now_mon+'-'+pre_time.getDate();
        now_hour=pre_time.getHours();
        now_min=pre_time.getMinutes();
        hr_op=getObj('date_time_hr');
        for(i=0;i<hr_op.options.length;i++){
            if(hr_op.options[i].value==now_hour){
                hr_op.options.selectedIndex=i;
            }
        }
        min_op=getObj('date_time_min');
        for(i=0;i<min_op.options.length;i++){
            if(min_op.options[i].value==now_min){
                min_op.options.selectedIndex=i;
            }
        }
    }    
}
function ActivityReminderSetupCallbackSaveProcess(message) {
	ActivityReminderProgressIndicator(false);
	$('ActivityReminder_callbacksetupdiv_lay').style.display='none';
}

function ActivityReminderSetupCallbackSave(form) {
	var cbmodule = form.cbmodule.value;
	var cbrecord = form.cbrecord.value;
	var cbaction = form.cbaction.value;

	var cbdate   = form.cbdate.value;
	var cbtime   = form.cbhour.value + ":" + form.cbmin.value;

	if(cbmodule && cbrecord) {
		ActivityReminderProgressIndicator(true);

		new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:"module=Calendar&action=CalendarAjax&ajax=true&file=ActivityReminderSetupCallbackAjax" +
			"&cbaction=" + encodeURIComponent(cbaction) +
			"&cbmodule="+ encodeURIComponent(cbmodule) +
			"&cbrecord=" + encodeURIComponent(cbrecord) +
			"&cbdate=" + encodeURIComponent(cbdate) +
			"&cbtime=" + encodeURIComponent(cbtime),
			onComplete:function (response) {
				ActivityReminderSetupCallbackSaveProcess(response.responseText);
			}
		});
}
}
function ActivityReminderSetupCallback(cbmodule, cbrecord) {
	if(cbmodule && cbrecord) {

		ActivityReminderProgressIndicator(true);
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:"module=Calendar&action=CalendarAjax&ajax=true&file=ActivityReminderSetupCallbackAjax&cbmodule="+
				encodeURIComponent(cbmodule) + "&cbrecord=" + encodeURIComponent(cbrecord),
				onComplete: function(response) {
					$("ActivityReminder_callbacksetupdiv").innerHTML=response.responseText;

					ActivityReminderProgressIndicator(false);

				}
			});
}
}
function toggleSelectDocumentRecords(module,state,relCheckName,parentEleId) {

	toggleSelect_ListView(state,relCheckName,parentEleId);
	if(state == true) {
		$('selectedboxes_'+parentEleId).value = 'all';
		$('selectAllRec_'+parentEleId).style.display = 'none';
		$('deSelectAllRec_'+parentEleId).style.display = 'inline';
	} else {
		$('selectedboxes_'+parentEleId).value = '';
		$('excludedRecords_'+parentEleId).value = '';
		$('currentPageRec_'+parentEleId).checked = false;
		$('selectAllRec_'+parentEleId).style.display = 'inline';
		$('deSelectAllRec_'+parentEleId).style.display = 'none';
		$('linkForSelectAll_'+parentEleId).hide();
	}
}
function toggleSelectAll_Records(module,state,relCheckName) {

	toggleSelect_ListView(state,relCheckName);
	if(state == true) {
		$('allselectedboxes').value = 'all';
		$('selectAllRec').style.display = 'none';
		$('deSelectAllRec').style.display = 'inline';
	} else {
		$('allselectedboxes').value = '';
		$('excludedRecords').value = '';
		$('selectCurrentPageRec').checked = false;
		$('selectAllRec').style.display = 'inline';
		$('deSelectAllRec').style.display = 'none';
		$('linkForSelectAll').hide();
	}
}
function c_toggleAssignType(currType){
		if (currType=="U")
		{
			document.getElementById("c_assign_user").style.display="block";
			document.getElementById("c_assign_team").style.display="none";
		}
		else
		{
			document.getElementById("c_assign_user").style.display="none";
			document.getElementById("c_assign_team").style.display="block";
		}
	}
//added for show/hide 10July
function expandCont(bn)
{
	var leftTab = document.getElementById(bn);
	leftTab.style.display = (leftTab.style.display == "block")?"none":"block";
	img = document.getElementById("img_"+bn);
	img.src=(img.src.indexOf("images/toggle1.gif")!=-1)?"themes/images/toggle2.gif":"themes/images/toggle1.gif";
	set_cookie_gen(bn,leftTab.style.display)

}
//Setting cookies
function set_cookie_gen ( name, value, exp_y, exp_m, exp_d, path, domain, secure )
{
	var cookie_string = name + "=" + escape ( value );

	if ( exp_y )
	{
		var expires = new Date ( exp_y, exp_m, exp_d );
		cookie_string += "; expires=" + expires.toGMTString();
	}

	if ( path )
		cookie_string += "; path=" + escape ( path );

	if ( domain )
		cookie_string += "; domain=" + escape ( domain );

	if ( secure )
		cookie_string += "; secure";

	document.cookie = cookie_string;
}

// Retrieving cookies
function get_cookie_gen ( cookie_name )
{
	var results = document.cookie.match ( cookie_name + '=(.*?)(;|$)' );

	if ( results )
		return ( unescape ( results[1] ) );
	else
		return null;
}

// Delete cookies
function delete_cookie_gen ( cookie_name )
{
	var cookie_date = new Date ( );  // current date & time
	cookie_date.setTime ( cookie_date.getTime() - 1 );
	document.cookie = cookie_name += "=; expires=" + cookie_date.toGMTString();
}
function selectContact(check,type,frmName)
{
	var record = document.getElementsByName("record")[0].value;
	if($("single_accountid"))
	{
		var potential_id = '';
		if($("potential_id"))
			potential_id = frmName.potential_id.value;
		account_id = frmName.account_id.value;
		if(potential_id != '')
		{
			record_id = potential_id;
			module_string = "&parent_module=Potentials";
		}
		else
		{
			record_id = account_id;
			module_string = "&parent_module=Accounts";
		}
		if(record_id != '')
			window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&form=EditView"+module_string+"&relmod_id="+record_id,"test","width=840,height=602,resizable=1,scrollbars=1");
		else
			window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&form=EditView","test","width=840,height=602,resizable=1,scrollbars=1");
	}
	else if(($("parentid")) && type != 'task')
	{
		if(getObj("parent_type")){
			rel_parent_module = frmName.parent_type.value;
			record_id = frmName.parent_id.value;
			module = rel_parent_module.split("&");
			if(record_id != '' && module[0] == "Leads")
			{
				alert(alert_arr.CANT_SELECT_CONTACTS);
			}
			else
			{
				if(check == 'true')
					search_string = "&return_module=Calendar&select=enable&popuptype=detailview&form_submit=false";
				else
					search_string="&popuptype=specific";
				if(record_id != '')
					window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&form=EditView"+search_string+"&relmod_id="+record_id+"&parent_module="+module[0],"test","width=840,height=602,resizable=0,scrollbars=0");
				else
					window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&form=EditView"+search_string,"test","width=840,height=602,resizable=0,scrollbars=0");

			}
		}else{
			window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&return_module=Calendar&select=enable&popuptype=detailview&form=EditView&form_submit=false","test","width=840,height=602,resizable=0,scrollbars=0");
		}
	}
	else if(($("contact_name")) && type == 'task')
	{
		var formName = frmName.name;
		var task_recordid = '';
		if(formName == 'EditView')
		{
			if($("parent_type"))
			{
				task_parent_module = frmName.parent_type.value;
				task_recordid = frmName.parent_id.value;
				task_module = task_parent_module.split("&");
				popuptype="&popuptype=specific";
			}
		}
		else
		{
			if($("task_parent_type"))
			{
				task_parent_module = frmName.task_parent_type.value;
				task_recordid = frmName.task_parent_id.value;
				task_module = task_parent_module.split("&");
				popuptype="&popuptype=toDospecific";
			}
		}
		if(task_recordid != '' && task_module[0] == "Leads" )
		{
			alert(alert_arr.CANT_SELECT_CONTACTS);
		}
		else
		{
			if(task_recordid != '')
				window.open("index.php?module=Contacts&action=Popup&html=Popup_picker"+popuptype+"&form="+formName+"&task_relmod_id="+task_recordid+"&task_parent_module="+task_module[0],"test","width=840,height=602,resizable=0,scrollbars=0");
			else
				window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&form="+formName,"test","width=840,height=602,resizable=0,scrollbars=0");
		}

	}
	else
	{
		window.open("index.php?module=Contacts&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&recordid="+record,"test","width=840,height=602,resizable=0,scrollbars=0");
	}
}
//to get Select Potential Popup
function selectPotential()
{
	// To support both B2B and B2C model
	var record_id = '';
	var parent_module = '';
	var acc_element = document.EditView.account_id;
	var cnt_element = document.EditView.contact_id;
	if (acc_element != null) {
		record_id= acc_element.value;
		parent_module = 'Accounts';
	} else if (cnt_element != null) {
		record_id= cnt_element.value;
		parent_module = 'Contacts';
	}
	if(record_id != '')
		window.open("index.php?module=Potentials&action=Popup&html=Popup_picker&popuptype=specific_potential_account_address&form=EditView&relmod_id="+record_id+"&parent_module="+parent_module,"test","width=840,height=602,resizable=1,scrollbars=1");
	else
		window.open("index.php?module=Potentials&action=Popup&html=Popup_picker&popuptype=specific_potential_account_address&form=EditView","test","width=840,height=602,resizable=1,scrollbars=1");
}
//to select Quote Popup
function selectQuote()
{
	// To support both B2B and B2C model
	var record_id = '';
	var parent_module = '';
	var acc_element = document.EditView.account_id;
	var cnt_element = document.EditView.contact_id;
	if (acc_element != null) {
		record_id= acc_element.value;
		parent_module = 'Accounts';
	} else if (cnt_element != null) {
		record_id= cnt_element.value;
		parent_module = 'Contacts';
	}
	if(record_id != '')
		window.open("index.php?module=Quotes&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&relmod_id="+record_id+"&parent_module="+parent_module,"test","width=840,height=602,resizable=1,scrollbars=1");

	else
		window.open("index.php?module=Quotes&action=Popup&html=Popup_picker&popuptype=specific&form=EditView","test","width=840,height=602,resizable=1,scrollbars=1");
}
//to get select SalesOrder Popup
function selectSalesOrder()
{
	// To support both B2B and B2C model
	var record_id = '';
	var parent_module = '';
	var acc_element = document.EditView.account_id;
	var cnt_element = document.EditView.contact_id;
    var module=document.EditView.module.value;
    
	if (acc_element != null) {
		record_id= acc_element.value;
		parent_module = 'Accounts';
	} else if (cnt_element != null) {
		record_id= cnt_element.value;
		parent_module = 'Contacts';
	}
    if(module=="CashBill")
    {
        record_id=document.EditView.record.value;
   	    if(record_id != '')
		window.open("index.php?module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&&fromModule=CashBill&form=EditView&relmod_id="+record_id+"&parent_module=Finical","test","width=840,height=602,resizable=0,scrollbars=0");
	   else
		window.open("index.php?module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&fromModule=CashBill","test","width=840,height=602,resizable=0,scrollbars=0");
        return ;
    }
	if(record_id != '')
		window.open("index.php?module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&form=EditView&relmod_id="+record_id+"&parent_module="+parent_module,"test","width=840,height=602,resizable=0,scrollbars=0");
	else
		window.open("index.php?module=SalesOrder&action=Popup&html=Popup_picker&popuptype=specific&form=EditView","test","width=840,height=602,resizable=0,scrollbars=0");
}

function checkEmailid(parent_module,emailid,secondaryemail)
{
	var check = true;
	if(emailid == '' && secondaryemail == '')
	{
		alert(alert_arr.LBL_THIS+parent_module+alert_arr.DOESNOT_HAVE_MAILIDS);
		check=false;
	}
	return check;
}

function confirmdelete(url)
{   //alert(1);
     if(url.toLocaleLowerCase().indexOf("paymentplan")!=-1)
     {
        
         PaymentplanDel(arrJsPopLabel['SUREWANTDELETE'],url);
         //return false; 
     }
     else if(url.toLocaleLowerCase().indexOf("cashbill")!=-1)
     {
    
        alert_str=arrJsPopLabel['CANOTRESTOREDAFTERDELETION'];
        if(confirm(alert_str))
    	{  
    		document.location.href=url;
    	}
     }
     else 
     {
        if(confirm(arrJsPopLabel['SUREWANTDELETE']))
    	{  
    		document.location.href=url;
    	}
     }
	
}


function PaymentPlanDetialDel(confirmationMsg,formName,action)
{
    $("status").style.display="inline";

    var delrecord=document.getElementById("recordid").value;

    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=PaymentPlan&action=DeleteAjax&delrecord="+delrecord,
					onComplete: function(response) {
						$("status").style.display="none";
                       
                        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                 if(confirm(confirmationMsg))
                                   {
                                     submitFormForAction(formName,action);
                                   }
                            }
                            else 
                            {
                                //您选择的记录有已收款或者部分已收款的单据，删除失败！
                                alert(arrJsPopLabel['SELECTHASRECEIVINGDELETINGFAILED']);
                            }
					}
				}
				);
}


/*
edit:Can
date:20130627
reason:优化
function validateFileSize(form_ele,uploadSize) {
    //因在iE下无法获取文件大小
    //所以不做判断
    // Edit by LD Can
    //return ; hiden by kjl and change LBL_SIZE_SHOULDNOTBE_GREATER with LBL_ONLOAD_FAIL,LBL_MAX_SIZE
	if (form_ele.value == '') return true;
	var fileSize = form_ele.files[0].size;
	if(fileSize > uploadSize) {
		alert(alert_arr.LBL_ONLOAD_FAIL+alert_arr.LBL_MAX_SIZE+ uploadSize/1000000+alert_arr.LBL_FILESIZEIN_MB);
		form_ele.value = '';
		document.getElementById('displaySize').innerHTML= '';
	} else {
		displayFileSize(form_ele);
	}
}


function displayFileSize(form_ele) {
	var fileSize = form_ele.files[0].size;
	if (fileSize < 1024)
		document.getElementById('displaySize').innerHTML = fileSize + alert_arr.LBL_FILESIZEIN_B;
	else if (fileSize > 1024 && fileSize < 1048576)
		document.getElementById('displaySize').innerHTML = Math.round(fileSize / 1024, 2) + alert_arr.LBL_FILESIZEIN_KB;
	else if (fileSize > 1048576)
		document.getElementById('displaySize').innerHTML = Math.round(fileSize / (1024 * 1024), 2) + alert_arr.LBL_FILESIZEIN_MB;
}
*/


function fnAddSrch(){

	var tableName = document.getElementById('adSrc');

	var prev = tableName.rows.length;

	var count = prev;

	var row = tableName.insertRow(prev);

	if(count%2)

		row.className = "dvtCellLabel";

	else

		row.className = "dvtCellInfo";

	var fieldObject = document.getElementById("Fields0");
	var conditionObject = document.getElementById("Condition0");
	var searchValueObject = document.getElementById("Srch_value0");

	var columnone = document.createElement('td');
	var colone = fieldObject.cloneNode(true);
	colone.setAttribute('id','Fields'+count);
	colone.setAttribute('name','Fields'+count);
	colone.setAttribute('value','');
	colone.onchange = function() {
		updatefOptions(colone, 'Condition'+count);
	}
	columnone.appendChild(colone);
	row.appendChild(columnone);

	var columntwo = document.createElement('td');
	var coltwo = conditionObject.cloneNode(true);
	coltwo.setAttribute('id','Condition'+count);
	coltwo.setAttribute('name','Condition'+count);
	coltwo.setAttribute('value','');
	columntwo.appendChild(coltwo);
	row.appendChild(columntwo);

	var columnthree = document.createElement('td');
	var colthree = searchValueObject.cloneNode(true);
	colthree.setAttribute('id','Srch_value'+count);
	colthree.setAttribute('name','Srch_value'+count);
	colthree.setAttribute('value','');
	colthree.value = '';
	columnthree.appendChild(colthree);
	row.appendChild(columnthree);

	updatefOptions(colone, 'Condition'+count);
}

function totalnoofrows()
{
	var tableName = document.getElementById('adSrc');
	document.basicSearch.search_cnt.value = tableName.rows.length;
}

/*
* javascript function to delete field rows in advance search
* @param void :: void
*/
function delRow()
{

	var tableName = document.getElementById('adSrc');

	var prev = tableName.rows.length;

	if(prev > 1)

		document.getElementById('adSrc').deleteRow(prev-1);

}

function fnVis(obj){

	var profTag = document.getElementById("prof");

	var moreTag = document.getElementById("more");

	var addrTag = document.getElementById("addr");


	if(obj == 'prof'){

		document.getElementById('mnuTab').style.display = 'block';

		document.getElementById('mnuTab1').style.display = 'none';

		document.getElementById('mnuTab2').style.display = 'none';

		profTag.className = 'dvtSelectedCellCommon dvtSelectedCell';

		moreTag.className = 'dvtUnSelectedCell';

		addrTag.className = 'dvtUnSelectedCell';

	}


	else if(obj == 'more'){

		document.getElementById('mnuTab1').style.display = 'block';

		document.getElementById('mnuTab').style.display = 'none';

		document.getElementById('mnuTab2').style.display = 'none';

		moreTag.className = 'dvtSelectedCellCommon dvtSelectedCell';

		profTag.className = 'dvtUnSelectedCell';

		addrTag.className = 'dvtUnSelectedCell';

	}


	else if(obj == 'addr'){

		document.getElementById('mnuTab2').style.display = 'block';

		document.getElementById('mnuTab').style.display = 'none';

		document.getElementById('mnuTab1').style.display = 'none';

		addrTag.className = 'dvtSelectedCellCommon dvtSelectedCell';

		profTag.className = 'dvtUnSelectedCell';

		moreTag.className = 'dvtUnSelectedCell';

	}

}

function delimage(id) {
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'module=Contacts&action=ContactsAjax&file=DelImage&recordid='+id,
			onComplete: function(response) {
				if(response.responseText.indexOf("SUCCESS")>-1)
					$("replaceimage").innerHTML=alert_arr.LBL_IMAGE_DELETED;
				else
					alert(alert_arr.ERROR_WHILE_EDITING);
			}
		}
		);
}

function delUserImage(id) {
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'module=Users&action=UsersAjax&file=Save&deleteImage=true&recordid='+id,
			onComplete: function(response) {
				if(response.responseText.indexOf("SUCCESS")>-1)
					$("replaceimage").innerHTML=alert_arr.LBL_IMAGE_DELETED;
				else
					alert(alert_arr.ERROR_WHILE_EDITING);
			}
		}
		);
}

function movefields()
{
	availListObj=getObj("availlist")
	selectedColumnsObj=getObj("selectedCol")
	for (i=0;i<selectedColumnsObj.length;i++)
	{

		selectedColumnsObj.options[i].selected=false
	}

	movefieldsStep1();
}

function movefieldsStep1()
{

	availListObj=getObj("availlist")
	selectedColumnsObj=getObj("selectedCol")
	document.getElementById("selectedCol").style.width="164px";
	var count=0;
	for(i=0;i<availListObj.length;i++)
	{
		if (availListObj.options[i].selected==true)
		{
			count++;
		}

	}
	var total_fields=count+selectedColumnsObj.length;
	if (total_fields >4 )
	{
		alert(alert_arr.MAX_RECORDS)
		return false
	}
	if (availListObj.options.selectedIndex > -1)
	{
		for (i=0;i<availListObj.length;i++)
		{
			if (availListObj.options[i].selected==true)
			{
				var rowFound=false;
				for (j=0;j<selectedColumnsObj.length;j++)
				{
					selectedColumnsObj.options[j].value==availListObj.options[i].value;
					if (selectedColumnsObj.options[j].value==availListObj.options[i].value)
					{
						var rowFound=true;
						var existingObj=selectedColumnsObj.options[j];
						break;
					}
				}

				if (rowFound!=true)
				{
					var newColObj=document.createElement("OPTION")
					newColObj.value=availListObj.options[i].value
					if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
					else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
					selectedColumnsObj.appendChild(newColObj)
					newColObj.selected=true
				}
				else
				{
					existingObj.selected=true
				}
				availListObj.options[i].selected=false
				movefieldsStep1();
			}
		}
	}
}



function delFields()
{
	selectedColumnsObj=getObj("selectedCol");
	selected_tab = $("dupmod").value;
	if (selectedColumnsObj.options.selectedIndex > -1)
	{
		for (i=0;i < selectedColumnsObj.options.length;i++)
		{
			if(selectedColumnsObj.options[i].selected == true)
			{
				if(selected_tab == 4)
				{
					if(selectedColumnsObj.options[i].innerHTML == "Last Name")
					{
						alert(alert_arr.DEL_MANDATORY);
						del = false;
						return false;
					}
					else
						del = true;

				}
				else if(selected_tab == 7)
				{
					if(selectedColumnsObj.options[i].innerHTML == "Last Name" || selectedColumnsObj.options[i].innerHTML == "Company")
					{
						alert(alert_arr.DEL_MANDATORY);
						del = false;
						return false;
					}
					else
						del = true;
				}
				else if(selected_tab == 6)
				{
					if(selectedColumnsObj.options[i].innerHTML == "Account Name")
					{
						alert(alert_arr.DEL_MANDATORY);
						del = false;
						return false;
					}
					else
						del = true;
				}
				else if(selected_tab == 14)
				{
					if(selectedColumnsObj.options[i].innerHTML == "Product Name")
					{
						alert(alert_arr.DEL_MANDATORY);
						del = false;
						return false;
					}
					else
						del = true;
				}
				if(del == true)
				{
					selectedColumnsObj.remove(i);
					delFields();
				}
			}
		}
	}
}

function moveFieldUp()
{
	selectedColumnsObj=getObj("selectedCol")
	var currpos=selectedColumnsObj.options.selectedIndex
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
	if (currpos>0)
	{
		var prevpos=selectedColumnsObj.options.selectedIndex-1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[prevpos].innerText
			tempdisabled = selectedColumnsObj.options[prevpos].disabled;
			selectedColumnsObj.options[prevpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[prevpos].disabled = false;
			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[prevpos].text
			tempdisabled = selectedColumnsObj.options[prevpos].disabled;
			selectedColumnsObj.options[prevpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[prevpos].disabled = false;
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[prevpos].value
		selectedColumnsObj.options[prevpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp
		selectedColumnsObj.options[prevpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}

}

function moveFieldDown()
{
	selectedColumnsObj=getObj("selectedCol")
	var currpos=selectedColumnsObj.options.selectedIndex
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
	if (currpos<selectedColumnsObj.options.length-1)
	{
		var nextpos=selectedColumnsObj.options.selectedIndex+1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[nextpos].innerText
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];

			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[nextpos].text
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[nextpos].value
		selectedColumnsObj.options[nextpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp

		selectedColumnsObj.options[nextpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}
}

function lastImport(module,req_module)
{
	var module_name= module;
	var parent_tab= document.getElementById('parenttab').value;
	if(module == '')
	{
		return false;
	}
	else

		//alert("index.php?module="+module_name+"&action=lastImport&req_mod="+req_module+"&parenttab="+parent_tab);
		window.open("index.php?module="+module_name+"&action=lastImport&req_mod="+req_module+"&parenttab="+parent_tab,"lastImport","width=750,height=602,menubar=no,toolbar=no,location=no,status=no,resizable=no,scrollbars=yes");
}



function validateInputData(value, fieldLabel, typeofdata) {

	var typeinfo = typeofdata.split('~');
	var type = typeinfo[0];

	if(type == 'T') {
		if(!re_patternValidate(value,fieldLabel+" (Time)","TIMESECONDS"))
			return false;
	} else if(type == 'D' || type == 'DT') {
	    //if(!re_dateValidate(value,fieldLabel+" (Current User Date Format)","OTH"))
        /*
        修改操作，by andy ,20131211,reason:控制面板页面设置，日期错误提示信息有误，
        */
		if(!re_dateValidate(value,fieldLabel,"OTH"))
			return false
	} else if(type == 'I') {
		if(isNaN(value) || value.indexOf(".")!=-1) {
			alert(alert_arr.INVALID+fieldLabel);
			return false
		}
	} else if(type == 'N' || type == 'NN') {

		if(typeof(typeinfo[2]) == "undefined") {
			var numformat = "any";
		} else {
			var numformat = typeinfo[2]
		}

		if(type == 'NN') {
			var negativeallowed = true;
		} else {
			var negativeallowed = false;
		}

		if(numformat != "any") {
			if (isNaN(value)) {
				var invalid=true
			} else {
				var format = numformat.split(",")
				var splitval = value.split(".")

				if (negativeallowed == true) {
					if (splitval[0].indexOf("-") >= 0) {
						if (splitval[0].length-1 > format[0]) {
							invalid=true
						}
					} else {
						if (splitval[0].length > format[0]) {
							invalid=true
						}
					}
				} else {
					if (value < 0) {
						invalid=true
					} else if (format[0] == 2 && splitval[0] == 100 && (!splitval[1] || splitval[1]==0)) {
						invalid=false
					} else if (splitval[0].length > format[0]) {
						invalid=true
					}
				}

				if (splitval[1]) {
					if (splitval[1].length > format[1]) {
						invalid=true
					}
				}
			}

			if (invalid==true) {
				alert(alert_arr.INVALID + fieldLabel)
				return false;
			} else {
				return true;
			}
		} else {
			var splitval = value.split(".")
			var arr_len = splitval.length;
			var len = 0;
			if(splitval[0] > 18446744073709551615) {
				alert( fieldLabel + alert_arr.EXCEEDS_MAX);
				return false;
			}
			if(negativeallowed == true) {
				var re=/^(-|)(\d)*(\.)?\d+(\.\d\d*)*$/
			} else {
				var re=/^(\d)*(\.)?\d+(\.\d\d*)*$/
			}
		}

		//for precision check. ie.number must contains only one "."
		var dotcount=0;
		for (var i = 0; i < value.length; i++) {
			if (value.charAt(i) == ".")
				dotcount++;
		}

		if(dotcount>1) {
			alert(alert_arr.INVALID+fieldLabel)
			return false;
		}

		if (!re.test(value)) {
			alert(alert_arr.INVALID+fieldLabel)
			return false
		}
	} else if(type == 'E') {
		if (!re_patternValidate(value,fieldLabel+" (Email Id)","EMAIL"))
			return false
	}

	return true;
}




function formValidate(){

	return doformValidation('');
}
//閸ф绱潏鎴濃偓鑲╂畱妤犲矁鐦?
function massEditFormValidate(){
	return doformValidation('mass_edit');
}

function doformValidation(edit_type) {    
	//Validation for Portal User
	if(gVTModule == 'Contacts' && gValidationCall != 'tabchange')
	{
		//if existing portal value = 0, portal checkbox = checked, ( email field is not available OR  email is empty ) then we should not allow -- OR --
		//if existing portal value = 1, portal checkbox = checked, ( email field is available     AND email is empty ) then we should not allow
		if(edit_type=='')
		{
			if(getObj('existing_portal') != null
				&& ((getObj('existing_portal').value == 0 && getObj('portal').checked &&
					(getObj('email') == null || trim(getObj('email').value) == '')) ||
				(getObj('existing_portal').value == 1 && getObj('portal').checked &&
					getObj('email') != null && trim(getObj('email').value) == ''))) {

				alert(alert_arr.PORTAL_PROVIDE_EMAILID);
				return false;
			}
		}
		else
		{
			if(getObj('portal') != null && getObj('portal').checked && getObj('portal_mass_edit_check').checked && (getObj('email') == null || trim(getObj('email').value) == '' || getObj('email_mass_edit_check').checked==false))
			{
				alert(alert_arr.PORTAL_PROVIDE_EMAILID);
				return false;
			}
			if((getObj('email') != null && trim(getObj('email').value) == '' && getObj('email_mass_edit_check').checked) && !(getObj('portal').checked==false && getObj('portal_mass_edit_check').checked))
			{
				alert(alert_arr.EMAIL_CHECK_MSG);
				return false;
			}
		}
	}
     
	if(gVTModule == 'SalesOrder') {
		if(edit_type == 'mass_edit') {
			if (getObj('enable_recurring_mass_edit_check') != null
				&& getObj('enable_recurring_mass_edit_check').checked
				&& getObj('enable_recurring') != null) {
				if(getObj('enable_recurring').checked && (getObj('recurring_frequency') == null
					|| trim(getObj('recurring_frequency').value) == '--None--' || getObj('recurring_frequency_mass_edit_check').checked==false)) {
					alert(alert_arr.RECURRING_FREQUENCY_NOT_PROVIDED);
					return false;
				}
				if(getObj('enable_recurring').checked == false && getObj('recurring_frequency_mass_edit_check').checked
					&& getObj('recurring_frequency') != null && trim(getObj('recurring_frequency').value) !=  '--None--') {
					alert(alert_arr.RECURRING_FREQNECY_NOT_ENABLED);
					return false;
				}
			}
		} else if(getObj('enable_recurring') != null && getObj('enable_recurring').checked) {
			if(getObj('recurring_frequency') == null || getObj('recurring_frequency').value == '--None--') {
				alert(alert_arr.RECURRING_FREQUENCY_NOT_PROVIDED);
				return false;
			}
			var start_period = getObj('start_period');
			var end_period = getObj('end_period');
			if (trim(start_period.value) == '' || trim(end_period.value) == '') {
				alert(alert_arr.START_PERIOD_END_PERIOD_CANNOT_BE_EMPTY);
				return false;
			}
		}
	}

    //add by ld tifa 20130304 for reminds time should higher than current time

    if(gVTModule == 'Reminds'||gVTModule == 'ContactRecords'){
        if(gVTModule == 'Reminds'||document.getElementById('pop_reminds')!=undefined&&document.getElementById('pop_reminds').checked){
            txt_hour=getObj('date_time_hr').options[getObj('date_time_hr').options.selectedIndex].value;
            txt_min=getObj('date_time_min').options[getObj('date_time_min').options.selectedIndex].value;
            act_time=getObj('date_only').value+' '+txt_hour+':'+txt_min; 
            getObj('date_time').value=act_time;
            getObj('time_reminds').value=txt_hour+':'+txt_min;
            
            cur_time=new Date();
            cur_time.setMinutes(cur_time.getMinutes()-10);
            now_mon=cur_time.getMonth()+1;
            cur_time=cur_time.getFullYear()+'-'+getDigital(now_mon)+'-'+getDigital(cur_time.getDate())+' '+getDigital(cur_time.getHours())+':'+getDigital(cur_time.getMinutes());
            if(act_time<cur_time ){
                alert(alert_arr.LBL_REMINDTIME_SHOULD);
                return false;
            }
        }
        if(gVTModule == 'Reminds')
        getObj('reltab').value=getObj('related_to_type').options[getObj('related_to_type').options.selectedIndex].text;

        if(gVTModule == 'ContactRecords'&&(document.getElementById('set_remind')!=undefined&&document.getElementById('set_remind').checked)){
            txt_hour=getObj('email_remind_hr').options[getObj('email_remind_hr').options.selectedIndex].value;
            txt_min=getObj('email_remind_min').options[getObj('email_remind_min').options.selectedIndex].value;
            act_time=getObj('email_date_only').value+' '+txt_hour+':'+txt_min; 
            getObj('email_remind').value=act_time;
            getObj('email_time').value=txt_hour+':'+txt_min;
            cur_time=new Date();
            cur_time.setMinutes(cur_time.getMinutes()-10);
            now_mon=cur_time.getMonth()+1;
            cur_time=cur_time.getFullYear()+'-'+getDigital(now_mon)+'-'+getDigital(cur_time.getDate())+' '+getDigital(cur_time.getHours())+':'+getDigital(cur_time.getMinutes());
            if(act_time<cur_time ){
                alert(alert_arr.LBL_REMINDTIME_SHOULD);
                return false;
            }
            textValue = getObj('contents').value;
            if(trim(textValue) == '' || trim(textValue) == '<br>'){
                alert(alert_arr.LBL_CONTENT_SHOULD);
                return false;
            }
        }

    }
   
	for (var i=0; i<fieldname.length; i++) {
		if(edit_type == 'mass_edit') {
			if(fieldname[i]!='salutationtype')
				var obj = getObj(fieldname[i]+"_mass_edit_check");
			if(obj == null || obj.checked == false) continue;
		}
		if(getObj(fieldname[i]) != null)
		{
			var type=fielddatatype[i].split("~")
          
			if (type[1]=="M") {
			 alert(fieldname[i]);
				if (!emptyCheck(fieldname[i],fieldlabel[i],getObj(fieldname[i]).type))
					return false;
			}
			switch (type[0]) {
				case "O"  :
					break;
				case "V"  :
					break;
				case "C"  :
					break;
				case "DT" :                
					if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (type[1]=="M")
							if (!emptyCheck(fieldname[i],fieldlabel[i],type[2]))
								return false
                        if(type[2]=="DT"){//BY LD KEVIN type[2]="DT" 自定义字段添加日期时间控件                               
                            if(!dateTimesecValidate(fieldname[i],fieldlabel[i],type[2]))
                            return false;
                        }else if(typeof(type[3])=="undefined"&&type[2]!="DT") {var currdatechk="OTH"}
						else {var currdatechk=type[3]}
                        //edit:kevin date:2013-05-30 reason:4028 type[2]!='time_start' 时间typeofdata:DT~M~time_start
                        if(type[2]!="DT" && type[2]!='time_start')
                        {
                            if (!dateTimeValidate(fieldname[i],type[2],fieldlabel[i],currdatechk))
							return false;
                        }
						
						if (type[4]&&type[2]!="DT") {
							if (!dateTimeComparison(fieldname[i],type[2],fieldlabel[i],type[5],type[6],type[4]))
								return false

						}
					}
					break;
				case "D"  :
					if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if(typeof(type[2])=="undefined") var currdatechk="OTH"
						else var currdatechk=type[2]

						if (!dateValidate(fieldname[i],fieldlabel[i],currdatechk))
							return false
						if (type[3]) {
							if(gVTModule == 'SalesOrder' && fieldname[i] == 'end_period'
								&& (getObj('enable_recurring') == null || getObj('enable_recurring').checked == false)) {
								continue;
							}
							if (!dateComparison(fieldname[i],fieldlabel[i],type[4],type[5],type[3]))
								return false
						}
					}
					break;
				case "T"  :
					if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if(typeof(type[2])=="undefined") var currtimechk="OTH"
						else var currtimechk=type[2]

						if (!timeValidate(fieldname[i],fieldlabel[i],currtimechk))
							return false
						if (type[3]) {
							if (!timeComparison(fieldname[i],fieldlabel[i],type[4],type[5],type[3]))
								return false
						}
					}
					break;
				case "I"  :
					if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (getObj(fieldname[i]).value.length!=0)
						{
							if (!intValidate(fieldname[i],fieldlabel[i]))
								return false
							if (type[2]) {
								if (!numConstComp(fieldname[i],fieldlabel[i],type[2],type[3]))
									return false
							}
						}
					}
					break;
				case "N"  :
				case "NN" :
					if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (getObj(fieldname[i]).value.length!=0)
						{
							if (typeof(type[2])=="undefined") var numformat="any"
							else var numformat=type[2]
							if(type[0]=="NN")
							{
								if (!numValidate(fieldname[i],fieldlabel[i],numformat,true))
									return false
							}
							else if (!numValidate(fieldname[i],fieldlabel[i],numformat))
								return false
							if (type[3]) {
								if (!numConstComp(fieldname[i],fieldlabel[i],type[3],type[4]))
									return false
							}
						}
					}
					break;
				case "E"  :
                
					if (getObj(fieldname[i]) != null && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0)
					{
						if (getObj(fieldname[i]).value.length!=0)
						{
							var etype = "EMAIL";
							if (!patternValidate(fieldname[i],fieldlabel[i],etype))
								return false;
						}
					}
					break;
			}
			//start Birth day date validation
			if(fieldname[i] == "birthday" && getObj(fieldname[i]).value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0 )
			{
				var now =new Date()
				var currtimechk="OTH"
				var datelabel = fieldlabel[i]
				var datefield = fieldname[i]
				var datevalue =getObj(datefield).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
				if (!dateValidate(fieldname[i],fieldlabel[i],currdatechk))
				{
					try {
						getObj(datefield).focus()
					} catch(error) { }
					return false
				}
				else
				{
					datearr=splitDateVal(datevalue);
					dd=datearr[0]
					mm=datearr[1]
					yyyy=datearr[2]
					var datecheck = new Date()
					datecheck.setYear(yyyy)
					datecheck.setMonth(mm-1)
					datecheck.setDate(dd)
					if (!compareDates(datecheck,datelabel,now,alert_arr.Current_Date,"L"))
					{
						try {
							getObj(datefield).focus()
						} catch(error) { }
						return false
					}
				}
			}
		//End Birth day
		}

	}
    return false;
	if(gVTModule == 'Contacts')
	{
		if(getObj('imagename'))
		{
			if(getObj('imagename').value != '')
			{
				var image_arr = new Array();
				image_arr = (getObj('imagename').value).split(".");
				var image_arr_last_index = image_arr.length - 1;
				if(image_arr_last_index < 0) {
					alert(alert_arr.LBL_WRONG_IMAGE_TYPE);
					return false;
				}
				var image_ext = image_arr[image_arr_last_index].toLowerCase();
				if(image_ext ==  "jpeg" || image_ext ==  "png" || image_ext ==  "jpg" || image_ext ==  "pjpeg" || image_ext ==  "x-png" || image_ext ==  "gif")
				{
					return true;
				}
				else
				{
					alert(alert_arr.LBL_WRONG_IMAGE_TYPE);
					return false;
				}
			}
		}
	}

	//added to check Start Date & Time,if Activity Status is Planned.//start
	for (var j=0; j<fieldname.length; j++)
	{
		if(getObj(fieldname[j]) != null)
		{
			if(fieldname[j] == "date_start" || fieldname[j] == "task_date_start" )
			{
				var datelabel = fieldlabel[j]
				var datefield = fieldname[j]
				var startdatevalue = getObj(datefield).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
			}
			if(fieldname[j] == "time_start" || fieldname[j] == "task_time_start")
			{
				var timelabel = fieldlabel[j]
				var timefield = fieldname[j]
				var timeval=getObj(timefield).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
			}
			if(fieldname[j] == "eventstatus" || fieldname[j] == "taskstatus")
			{
				var statusvalue = getObj(fieldname[j]).value.replace(/^\s+/g, '').replace(/\s+$/g, '')
				var statuslabel = fieldlabel[j++]
			}
		}
	}
	if(statusvalue == "Planned")
	{
		var dateelements=splitDateVal(startdatevalue)

		var hourval=parseInt(timeval.substring(0,timeval.indexOf(":")))
		var minval=parseInt(timeval.substring(timeval.indexOf(":")+1,timeval.length))


		dd=dateelements[0]
		mm=dateelements[1]
		yyyy=dateelements[2]

		var chkdate=new Date()
		chkdate.setYear(yyyy)
		chkdate.setMonth(mm-1)
		chkdate.setDate(dd)
		chkdate.setMinutes(minval)
		chkdate.setHours(hourval)
		if(!comparestartdate(chkdate)) return false;
	}//end

	return true;
}


//Function added for Mass select in Popup - Philip
function SelectAll(mod,parmod)
{
	if(document.selectall.selected_id != undefined)
	{
		x = document.selectall.selected_id.length;
		var y=0;
		if(parmod != 'Calendar')
		{
			var module = window.opener.document.getElementById('RLreturn_module').value
			var entity_id = window.opener.document.getElementById('RLparent_id').value
			var parenttab = window.opener.document.getElementById('parenttab').value
		}
		idstring = "";
		namestr = "";

		if ( x == undefined)
		{

			if (document.selectall.selected_id.checked)
			{
				idstring = document.selectall.selected_id.value;
				if(parmod == 'Calendar')
					namestr = document.getElementById('calendarCont'+idstring).innerHTML;
				y=1;
			}
			else
			{
				alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
		}
		else
		{
			y=0;
			for(i = 0; i < x ; i++)
			{
				if(document.selectall.selected_id[i].checked)
				{
					idstring = document.selectall.selected_id[i].value +";"+idstring;
					if(parmod == 'Calendar')
					{
						idval = document.selectall.selected_id[i].value;
						namestr = document.getElementById('calendarCont'+idval).innerHTML+"\n"+namestr;
					}
					y=y+1;
				}
			}
		}
		if (y != 0)
		{
			document.selectall.idlist.value=idstring;
		}
		else
		{
			alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
			return false;
		}
		if(confirm(alert_arr.ADD_CONFIRMATION+y+alert_arr.RECORDS))
		{
			if(parmod == 'Calendar')
			{
				//this blcok has been modified to provide delete option for contact in Calendar
				idval = window.opener.document.EditView.contactidlist.value;
				if(idval != '')
				{
					var avalIds = new Array();
					avalIds = idstring.split(';');

					var selectedIds = new Array();
					selectedIds = idval.split(';');

					for(i=0; i < (avalIds.length-1); i++)
					{
						var rowFound=false;
						for(k=0; k < selectedIds.length; k++)
						{
							if (selectedIds[k]==avalIds[i])
							{
								rowFound=true;
								break;
							}

						}
						if(rowFound != true)
						{
							idval = idval+';'+avalIds[i];
							window.opener.document.EditView.contactidlist.value = idval;
							var str=document.getElementById('calendarCont'+avalIds[i]).innerHTML;
							window.opener.addOption(avalIds[i],str);
						}
					}
				}
				else
				{
					window.opener.document.EditView.contactidlist.value = idstring;
					var temp = new Array();
					temp = namestr.split('\n');

					var tempids = new Array();
					tempids = idstring.split(';');

					for(k=0; k < temp.length; k++)
					{
						window.opener.addOption(tempids[k],temp[k]);
					}
				}
			//end
			}
			else
			{
				opener.document.location.href="index.php?module="+module+"&parentid="+entity_id+"&action=updateRelations&destination_module="+mod+"&idlist="+idstring+"&parenttab="+parenttab;
			}
			self.close();
		}
		else
		{
			return false;
		}
	}
}


function AjaxDuplicateValidate(module,fieldname,oform)
{
    
	var fieldvalue = encodeURIComponent(trim(getObj(fieldname,oform).value));
    /*
    edit by LD Can var recordid = getObj('record').value;
   reason:快速创建中新增"客户"时，点击保存，程序报错，提示'options' 为空或不是对象，希望修正。
    */
	var recordid = getObj('record',oform).value;
   
	if(fieldvalue == '')
	{
		alert(alert_arr.ACCOUNTNAME_CANNOT_EMPTY);
		return false;
	}
    
	lingdangJS_DialogBox.block();
 
	var url = "module="+module+"&action="+module+"Ajax&file=Save&"+fieldname+"="+fieldvalue+"&dup_check=true&record="+recordid;
	/*
    edit:can
    date:20130531
    reason:创建和编辑权限分开
    
    */
    if(oform.Create!=undefined)
    {
        var create=oform.Create.value;
        url=url+"&Create="+create;
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
				var str = response.responseText
				if(str.indexOf('SUCCESS') > -1)
				{
					oform.submit();
				}else
				{
					lingdangJS_DialogBox.unblock();
					alert(str);
					return false;
				}
			}
		}
		);
}

function toggleSelect_ListView(state,relCheckName,groupParentElementId) {
	var obj = document.getElementsByName(relCheckName);
  
	if (obj) {
		for (var i=0;i<obj.length;i++) {
			obj[i].checked=state;
			if(typeof(check_object) == 'function') {
				// This function is defined in ListView.js (check for existence)
				check_object(obj[i],groupParentElementId);
			}
		}
	}
   
	/*if($('curmodule') != undefined && $('curmodule').value == 'Documents') {
		if(state==true)	{
			var count = $('numOfRows_'+groupParentElementId).value;
			if(count == '') {
				getNoOfRows(groupParentElementId);
			}
			if(parseInt($('maxrecords').value) < parseInt(count)) {
				$('linkForSelectAll_'+groupParentElementId).show();
			}

		} else {
			if($('selectedboxes_'+groupParentElementId).value == 'all') {
				$('linkForSelectAll_'+groupParentElementId).show();
			} else {
				$('linkForSelectAll_'+groupParentElementId).hide();
			}
		}
	} else {*/
		if(state==true)	{
			var count = $('numOfRows').value;
			if(count == '')	{
				getNoOfRows();
			}
			if(parseInt($('maxrecords').value) < parseInt(count)) {
				$('linkForSelectAll').show();
			}

		} else {
			if($('allselectedboxes').value == 'all') {
				$('linkForSelectAll').show();
			} else {
				$('linkForSelectAll').hide();
			}
		}
	//}
}
function rel_toggleSelect(state,relCheckName,module) {
	var obj = document.getElementsByName(relCheckName);
	if (obj) {
		for (var i=0;i<obj.length;i++) {
			obj[i].checked = state;
			rel_check_object(obj[i],module);
		}
	}
	var current_module = $('return_module').value;
	if(current_module == 'Campaigns') {
		if(state == true) {
			var count = $(current_module+'_'+module+'_numOfRows').value;
			if(count == '')	{
				getNoOfRelatedRows(current_module,module);
			}
			if(parseInt($('maxrecords').value) < parseInt(count)) {
				$(current_module+'_'+module+'_linkForSelectAll').show();
			}
		} else {
			if($(current_module+'_'+module+'_selectallActivate').value == 'true'){
				$(current_module+'_'+module+'_linkForSelectAll').show();
			} else {
				$(current_module+'_'+module+'_linkForSelectAll').hide();
			}
		}
	}
}
//To select the select all check box(if all the items are selected) when the form loads for Campaigns related list:.
function rel_default_togglestate(module)
{
	var all_state=true;
	var currentModule = $('return_module').value;
	if(currentModule == 'Campaigns'){
		var groupElements = document.getElementsByName(currentModule+'_'+module+"_selected_id");
	} else {
		var groupElements = document.getElementsByName(module+"_selected_id");
	}
	if(typeof(groupElements) == 'undefined') return;

	for (var i=0;i<groupElements.length;i++) {
		var state=groupElements[i].checked;
		if (state == false)
		{
			all_state=false;
			break;
		}
	}
	if(getObj(module+"_selectall")) {
		getObj(module+"_selectall").checked=all_state;
	}
}

function rel_check_object(sel_id,module)
{
	var selected;
	var select_global = new Array();
	var cookie_val = get_cookie(module+"_all");
	if(cookie_val == null)
		selected = sel_id.value+";";
	else
		selected = trim(cookie_val);
	select_global = selected.split(";");
	var box_value = sel_id.checked;
	var id = sel_id.value;
	var duplicate = select_global.indexOf(id);
	var size = select_global.length-1;
	var result = "";
	var currentModule = $('return_module').value;
	var excluded = $(currentModule+'_'+module+'_excludedRecords').value;
	if(box_value == true)
	{
		if($(currentModule+'_'+module+'_selectallActivate').value == 'true') {
			$(currentModule+'_'+module+'_excludedRecords').value = excluded.replace(excluded.match(id+";"),'');
		} else {
			if(duplicate == "-1")
			{
				select_global[size]=id;
			}

			size = select_global.length-1;
			var i=0;
			for(i=0;i<=size;i++) {
				if(trim(select_global[i])!='')
					result = select_global[i]+";"+result;
			}
		}
		rel_default_togglestate(module);
	}
	else
	{
		if($(currentModule+'_'+module+'_selectallActivate').value == 'true'){
			$(currentModule+'_'+module+'_excludedRecords').value= id+";"+excluded;
		}
		if(duplicate != "-1")

			select_global.splice(duplicate,1)

		size=select_global.length-1;
		var i=0;
		for(i=size;i>=0;i--) {
			if(trim(select_global[i])!='')
				result=select_global[i]+";"+result;
		}
		getObj(module+"_selectall").checked=false;

	}
	set_cookie(module+"_all",result);
}


function fnSlide2(obj,inner)
{
	var buff = document.getElementById(obj).height;
	closeLimit = buff.substring(0,buff.length);
	menu_max = eval(closeLimit);
	var tagName = document.getElementById(inner);
	document.getElementById(obj).style.height=0 + "px";
	menu_i=0;
	if (tagName.style.display == 'none')
		fnexpanLay2(obj,inner);
	else
		fncloseLay2(obj,inner);
}

function fnexpanLay2(obj,inner)
{
	// document.getElementById(obj).style.display = 'run-in';
	var setText = eval(closeLimit) - 1;
	if (menu_i<=eval(closeLimit))
	{
		if (menu_i>setText){
			document.getElementById(inner).style.display='block';
		}
		document.getElementById(obj).style.height=menu_i + "px";
		setTimeout(function() {
			fnexpanLay2(obj,inner);
		},5);
		menu_i=menu_i+5;
	}
}
function fncloseLay2(obj,inner)
{
	if (menu_max >= eval(openLimit))
	{
		if (menu_max<eval(closeLimit)){
			document.getElementById(inner).style.display='none';
		}
		document.getElementById(obj).style.height=menu_max +"px";
		setTimeout(function() {
			fncloseLay2(obj,inner);
		}, 5);
		menu_max = menu_max -5;
	}
}


function fnDown(obj){
	var tagName = document.getElementById(obj);
	var tabName = document.getElementById("one");
	if(tagName.style.display == 'none'){
		tagName.style.display = 'block';
		tabName.style.display = 'block';
	}
	else{
		tabName.style.display = 'none';
		tagName.style.display = 'none';
	}
}

function toggleSelect(state,relCheckName) {
	if (getObj(relCheckName)) {
		if (typeof(getObj(relCheckName).length)=="undefined") {
			getObj(relCheckName).checked=state
		} else {
			for (var i=0;i<getObj(relCheckName).length;i++)
				getObj(relCheckName)[i].checked=state
		}
	}
}


function clearTextSelection() {

	if (browser_ie) document.selection.empty();

	else if (browser_nn4 || browser_nn6) window.getSelection().removeAllRanges();

}


// Setting cookies
function set_cookie ( name, value, exp_y, exp_m, exp_d, path, domain, secure )
{
	var cookie_string = name + "=" + escape ( value );

	if (exp_y) //delete_cookie(name)
	{
		var expires = new Date ( exp_y, exp_m, exp_d );
		cookie_string += "; expires=" + expires.toGMTString();
	}

	if (path) cookie_string += "; path=" + escape ( path );
	if (domain) cookie_string += "; domain=" + escape ( domain );
	if (secure) cookie_string += "; secure";

	document.cookie = cookie_string;
}

// Retrieving cookies
function get_cookie(cookie_name)
{
	var results = document.cookie.match(cookie_name + '=(.*?)(;|$)');
	if (results) return (unescape(results[1]));
	else return null;
}

// Delete cookies
function delete_cookie( cookie_name )
{
	var cookie_date = new Date ( );  // current date & time
	cookie_date.setTime ( cookie_date.getTime() - 1 );
	document.cookie = cookie_name += "=; expires=" + cookie_date.toGMTString();
}

function mypopup()
{
      mywindow = window.open("copyright.html","mywindow", "height=115, width=575");
      mywindow.moveTo(210,620);
}

function newpopup(str){
                window.open (str,"mywinw","menubar=1,resizable=1,scrollbars=yes");
//              window.parent.close();
}