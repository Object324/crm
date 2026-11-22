
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

function set_values(form) {

	if (form.duedate_flag.checked) {

		form.duedate_flag.value='on';

		form.duedate.value="";

		form.duetime.value="";

		form.duedate.readOnly=true;

		form.duetime.readOnly=true;

		document.images.jscal_trigger.width = 0;

		document.images.jscal_trigger.height = 0;

	}

	else {

		form.duedate_flag.value='off';

		form.duedate.readOnly=false;

		form.duetime.readOnly=false;

		if (form.duetime.readonly){
			RemindsMsg("","LdPopWidth400px","","yes","yes",alert_arr.READONLY);
		}

		document.images.jscal_trigger.width = 16;

		document.images.jscal_trigger.height = 16;

	}

}
function toggleTime(fldName)
{
	if(getObj("notime").checked)
	{
		getObj("notime").value = 'on';
		getObj("duration_hours").disabled = true;
		getObj("duration_minutes").disabled = true;
	}
	else
	{
		getObj("notime").value = 'off';
        getObj("duration_minutes").disabled = false;
		getObj("duration_hours").disabled = false;
	}
	setFromCheckBox(fldName);
}

function toggleAssignType(currType)

{

        if (currType=="U")

        {

                getObj("assign_user").style.display="block"

                getObj("assign_team").style.display="none"

        }

        else

        {

                getObj("assign_user").style.display="none"

                getObj("assign_team").style.display="block"

        }

}

function showActivityView(selectactivity_view)
{
	//script to reload the page with the view type when the combo values are changed
	View_name = selectactivity_view.options[selectactivity_view.options.selectedIndex].value;
	document.frmOpenLstView.action = "index.php?module=Home&action=index&activity_view="+View_name;
	document.frmOpenLstView.submit();
}	

function exportCalendar(){
	if(document.getElementsByName('exportCalendar')[0].value == 'iCal'){
	   
		var filename = $('ics_filename').value;
		puyoungJS_DialogBox.block();
	
      	var url = "index.php?module=Calendar&action=iCalExport&filename="+filename;
		location.href = url;
        puyoungJS_DialogBox.unblock();
		ghide('CalExport')
	}
}

function importCalendar(){
	var file = document.getElementById('ics_file').value;
	if (file != '') {
		if (file.indexOf('.ics') != (file.length - 4)) {
			var confirm_str = alert_arr.PLS_SELECT_VALID_FILE+".ics";
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		}
		else {
			document.ical_import.action.value='iCalImport';
			document.ical_import.module.value='Calendar';
			document.ical_import.submit();
		}
	}
}


/*********************************************************************************

** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

function DisableSharing()
{

        x = document.SharedList.selected_id.length;
        idstring = "";
        xx = 0;
        if ( x == undefined)
        {

                if (document.SharedList.selected_id.checked)
                {
                        document.SharedList.idlist.value=document.SharedList.selected_id.value;
                }
                else
                {
						var confirm_str = arrJsPopLabel['PLEASESELECTMERAGETEMPLATES'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                }
        }
        else
        {
                for(i = 0; i < x ; i++)
                {
                        if(document.SharedList.selected_id[i].checked)
                        {
                                idstring = document.SharedList.selected_id[i].value +";"+idstring
                        xx++
                        }
                }
                if (xx != 0)
                {
                        document.SharedList.idlist.value=idstring;
                }
                else
                {
                        var confirm_str = arrJsPopLabel['PLEASESELECTMERAGETEMPLATES'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                }
        }
        if(confirm(alert_arr.DISABLE_SHARING_CONFIRMATION+xx+alert_arr.USERS))
        {
                document.SharedList.action="index.php?module=Calendar&action=disable_sharing&return_module=Calendar&return_action=calendar_share";
        }
        else
        {
                return false;
        }
}



function showhide(argg)
{
	var x=document.getElementById(argg).style;
	if (x.display=="none")
	{
		x.display="block"

	}
	else {
			x.display="none"
		  }
}


function showhideRepeat(argg1,argg2)
{
	var x=document.getElementById(argg2).style;
	var y=document.getElementById(argg1).checked;

	if (y)
	{
		x.display="block";
	}
	else {
		x.display="none";
	}

}

function fnAddEvent(obj,CurrObj,start_date,end_date,start_hr,start_min,start_fmt,end_hr,end_min,end_fmt,viewOption,subtab,eventlist){
	/*var tagName = document.getElementById(CurrObj);
	var left_Side = findPosX(obj);
	var top_Side = findPosY(obj);
	tagName.style.left= left_Side  + 'px';
	tagName.style.top= top_Side + 22+ 'px';
	tagName.style.display = 'block';
	eventlist = eventlist.split(";");
	for(var i=0;i<(eventlist.length-1);i++){
		document.getElementById("add"+eventlist[i].toLowerCase()).href="javascript:gshow('addEvent','"+eventlist[i]+"','"+start_date+"','"+end_date+"','"+start_hr+"','"+start_min+"','"+start_fmt+"','"+end_hr+"','"+end_min+"','"+end_fmt+"','"+viewOption+"','"+subtab+"');fnRemoveEvent();";
	}
	document.getElementById("addtodo").href="javascript:gshow('createTodo','todo','"+start_date+"','"+end_date+"','"+start_hr+"','"+start_min+"','"+start_fmt+"','"+end_hr+"','"+end_min+"','"+end_fmt+"','"+viewOption+"','"+subtab+"');fnRemoveEvent();";*/
    eventlist = eventlist.split(";");
    gshow('addEvent',eventlist[i],start_date,end_date,start_hr,start_min,start_fmt,end_hr,end_min,end_fmt,viewOption,subtab);
}

function gshow(argg1,type,startdate,enddate,starthr,startmin,startfmt,endhr,endmin,endfmt,viewOption,subtab)
{    
	smin = parseInt(startmin,10);
        smin = smin - (smin%5);
	var y=document.getElementById(argg1).style;

		if(type != 'todo' && type!='')
		{
			/*for(var i=0;;i++){
				if( document.EditView.activitytype[i].value == type){
					document.EditView.activitytype[i].selected='yes';
					triggerOnChangeHandler(('activitytype'));
					break;
				}
			}*/

			smin = _2digit(smin);
			document.EditView.date_start.value = startdate;
			document.EditView.starthr.value = starthr;
			document.EditView.startmin.value = smin;
			document.EditView.startfmt.value = startfmt;
			document.EditView.viewOption.value = viewOption;
            document.EditView.subtab.value = subtab;
			calDuedatetime(type);
		}
		if(type == 'todo')
		{
                        smin = _2digit(smin);
			document.createTodo.task_date_start.value = startdate;
			document.createTodo.task_due_date.value = enddate;
			document.createTodo.starthr.value = starthr;
                        document.createTodo.startmin.value = smin;
                        document.createTodo.startfmt.value = startfmt;
			document.createTodo.viewOption.value = viewOption;
                        document.createTodo.subtab.value = subtab;
		}
		if (y.display=="none")
	        {
			y.display="block";
		}
}

function CreateEvent(argg1,type,startdate,enddate,starthr,startmin,startfmt,endhr,endmin,endfmt,viewOption,subtab){
    starthr=parseInt(starthr,10);
    endhr=parseInt(endhr,10);
    if(startfmt != '')
	{
	   if(startfmt == 'pm')
         {
			if(starthr == 12){
				starthr = 23;
                startmin= 59+':'+59;
			}
			else
 		     starthr = starthr + 12;
        }
    }
    if(endfmt != '')
	{
	   if(endfmt == 'pm')
         {
			if(endhr == 12){
			 endhr = 23;
                endmin= 59+':'+59;
			}
			else
 		     endhr = endhr + 12;
        }
    }
    var time_start = starthr + ":" + startmin;
    var time_end = endhr + ":" + endmin;
    //32192: 日程管理>日历视图：点击“+”创建日程管理时，开始时间自动默认为当前选中的时间。结束时间默认为空
    var objparams=new CreatePagePopup.params();
    CreatePagePopup.showpage("Calendar","&start_date="+ startdate+"&end_date=&start_hr="+starthr+"&start_min="+startmin+"&end_hr="+endhr+"&end_min="+endmin+"&viewOption="+viewOption+"&time_start="+time_start+"&time_end="+time_end+"&Create=true",objparams);
  
  
   //CreatePagePopup.showpage("Calendar","&start_date="+ startdate+"&end_date=&start_hr="+starthr+"&start_min="+startmin+"&end_hr="+endhr+"&end_min="+endmin+"&viewOption="+viewOption+"&time_start="+time_start+"&time_end="+time_end+"&Create=true",CreatePagePopup.params);

    //var url = "index.php?module=Calendar&action=EditView&start_date="+ startdate+"&end_date="+enddate+"&start_hr="+starthr+"&start_min="+startmin+"&end_hr="+endhr+"&end_min="+endmin+"&viewOption="+viewOption+"&time_start="+time_start+"&time_end="+time_end+"&Create=true";
    //location.href=url;
} 

function rptoptDisp(Opt){
	var currOpt = Opt.options[Opt.selectedIndex].value;
	if(currOpt == "Daily")
	{
		ghide('repeatWeekUI');
		ghide('repeatMonthUI');
	}
	else if(currOpt == "Weekly")
	{
		if(document.getElementById('repeatWeekUI').style.display == "none");
			document.getElementById('repeatWeekUI').style.display = "block";
		ghide('repeatMonthUI');
	}
	else if(currOpt == "Monthly")
	{
		ghide('repeatWeekUI');
		if(document.getElementById('repeatMonthUI').style.display == "none");
                        document.getElementById('repeatMonthUI').style.display = "block";
	}
	else if(currOpt == "Yearly")
	{
		ghide('repeatWeekUI');
                ghide('repeatMonthUI');
	}
}

function Taskshow(argg1,type,startdate,starthr,startmin,startfmt)
{
	var y=document.getElementById(argg1).style;
	if (y.display=="none")
        {
                document.EditView.date_start.value = startdate;
                document.EditView.starthr.value = starthr;
                document.EditView.startmin.value = startmin;
                document.EditView.startfmt.value = startfmt;
		y.display="block";
	}
}

function ghide(argg2)
{
	var z=document.getElementById(argg2).style;
	if (z.display=="block" )
	{
		z.display="none"

	}
}

 function moveMe(arg1) {
	var posx = 0;
	var posy = 0;
	var e=document.getElementById(arg1);

	if (!e) var e = window.event;

	if (e.pageX || e.pageY)
	{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY)
	{
		posx = e.clientX + document.body.scrollLeft;
		posy = e.clientY + document.body.scrollTop;
	}
 }
function Calendar_switchClass(div_id){
	var popupobj=CrmPopup.getPopupObj("last");
	var obj_cellTabLoop =CrmPopup.findHtmlobj(popupobj.divid,'cellTabLoop');
	var obj_cellTabAlarm =CrmPopup.findHtmlobj(popupobj.divid,'cellTabAlarm');
	var obj_cellTabInvite =CrmPopup.findHtmlobj(popupobj.divid,'cellTabInvite');

	var obj_addEventLoopUI =CrmPopup.findHtmlobj(popupobj.divid,'addEventLoopUI');
	var obj_addEventRelatedtoUI =CrmPopup.findHtmlobj(popupobj.divid,'addEventRelatedtoUI');
	var obj_addEventAlarmUI =CrmPopup.findHtmlobj(popupobj.divid,'addEventAlarmUI');
	if(div_id == 'cellTabAlarm'){
		// var obj_cellTabAlarm =CrmPopup.findHtmlobj(popupobj.divid,'cellTabAlarm');
		// var obj_cellTabInvite =CrmPopup.findHtmlobj(popupobj.divid,'cellTabInvite');
		obj_cellTabLoop.attr('class','dvtUnSelectedCell height20');
		obj_cellTabAlarm.attr('class','dvtSelectedCellCommon dvtSelectedCell height20');
		obj_cellTabInvite.attr('class','dvtUnSelectedCell height20');

		obj_addEventLoopUI.css('display','none');
		obj_addEventRelatedtoUI.css('display','none');
		obj_addEventAlarmUI.css('display','block');
	}else if(div_id == 'cellTabInvite'){
		// var obj_cellTabAlarm =CrmPopup.findHtmlobj(popupobj.divid,'cellTabAlarm');
		// var obj_cellTabInvite =CrmPopup.findHtmlobj(popupobj.divid,'cellTabInvite');
		obj_cellTabLoop.attr('class','dvtUnSelectedCell height20');
		obj_cellTabAlarm.attr('class','dvtUnSelectedCell height20');
		obj_cellTabInvite.attr('class','dvtSelectedCellCommon dvtSelectedCell height20');

		if(popupobj.related_module != 'detailview'){
			var tableobj = ld('#'+popupobj.divid).find("#addEventRelatedtoUI").find('table[name=addEventRelatedtoTable]');
			if(tableobj.find('tr[name=DragTransfer_tr]').length == 0){
				var LeftObj = tableobj.find(" #availableusers");
				var RightObj = tableobj.find(" #selectedusers");
				var Drag_Transfer = new DragTransfer();
				var translabel = {
					available: arrJsPopLabel['USERSCANCHOOSE'],
					selected: arrJsPopLabel['USERHASSELECTED'],
					placeholder: arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'],
				};
				Drag_Transfer.SetTranslabel(translabel);
				Drag_Transfer.right_Sortable = false;
				Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','260');
			}
		}
		obj_addEventRelatedtoUI.css('display','block');
		obj_addEventAlarmUI.css('display','none');
		obj_addEventLoopUI.css('display','none');
	}else if(div_id == 'cellTabLoop'){
		obj_cellTabLoop.attr('class','dvtSelectedCellCommon dvtSelectedCell height20');
		obj_cellTabAlarm.attr('class','dvtUnSelectedCell height20');
		obj_cellTabInvite.attr('class','dvtUnSelectedCell height20');

		obj_addEventLoopUI.css('display','block');
		obj_addEventRelatedtoUI.css('display','none');
		obj_addEventAlarmUI.css('display','none');
	}
}
function switchClass(myModule,toStatus) {
	var x=document.getElementById(myModule);
	if($(x))
	{
		if (toStatus=="on") {
			x.className="dvtSelectedCellCommon dvtSelectedCell";
		}
		if (toStatus=="off") {
			x.className="dvtUnSelectedCell";
		}
	}

}

function enableCalstarttime()
{
	if(document.SharingForm.sttime_check.checked == true)
		document.SharingForm.start_hour.disabled = false;
	else
		document.SharingForm.start_hour.disabled = true;
}
function check_form() {

	formSelectColumnString('inviteesid','selectedusers');
	if(trim(document.EditView.subject.value) == "") {
		var confirm_str = arrJsPopLabel['Theme'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		document.EditView.subject.focus()
		return false;
	} else {
	   if(getObj('jscal_field_date_start') !=undefined && getObj('jscal_field_due_date')!=undefined){
        if(!dateTimesecValidate('date_start',arrJsPopLabel['STARTTIME'],'DT'))
        return false;
        else if(!dateTimesecValidate('jscal_field_due_date',arrJsPopLabel['ENDTIME'],'DT'))
        return false;
        var date_start=getObj('jscal_field_date_start').value;
        var due_end=getObj('jscal_field_due_date').value;
        
        if(date_start>due_end){
            var confirm_str = arrJsPopLabel['STARTTIME']+ ' ' +arrJsPopLabel['SHOULDLESSTHANOREQUAL']+' '+arrJsPopLabel['ENDTIME'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        }
    }
		if(document.EditView.record.value != '') {
			document.EditView.mode.value = 'edit';
		} else {
			document.EditView.mode.value = 'create';
		}
        if(getObj('reminderOptions2') !=undefined && getObj('reminderOptions2').style.display=='block'){
            getObj('pop_reminds').value='Yes';           
            getObj('date_time').value=getObj('date_only').value;
        }
        else{
            getObj('pop_reminds').value='No';
        }
        
        if(getObj('reminderOptions') !=undefined && getObj('reminderOptions').style.display=='block'){
            getObj('set_remind').value='Yes';            
         
            getObj('email_time').value=getObj('email_date_only').value;
        }
        else{
            getObj('set_remind').value='No';
        }		
       
		if(getObj("recurringcheck") && document.EditView.recurringcheck.checked == false) {
			document.EditView.recurringtype.value = '--None--';
		}
		return true;
	}
}

function task_check_form()
{
	starthour = parseInt(document.createTodo.starthr.value,10);
        startmin  = parseInt(document.createTodo.startmin.value,10);
        startformat = document.createTodo.startfmt.value;
	if(startformat != '')
	{
        	if(startformat == 'pm')
                {
			if(starthour == 12)
				starthour = 12;
			else
                		starthour = starthour + 12;

                }
                else
                {
			if(starthour == 12)
				starthour = 0;
			else
				starthour = starthour;
                }
        }
	starthour = _2digit(starthour);
        startmin = _2digit(startmin);
        document.createTodo.task_time_start.value = starthour+':'+startmin;
	if(document.createTodo.record.value != '')
        {
        	document.createTodo.mode.value = 'edit';
        }
        else
        {
        	document.createTodo.mode.value = 'create';
        }

}


function maintask_check_form()
{
	starthour = parseInt(document.EditView.starthr.value,10);
        startmin  = parseInt(document.EditView.startmin.value,10);
        startformat = document.EditView.startfmt.value;
        if(startformat != '')
        {
                if(startformat == 'pm')
                {
			if(starthour == 12)
				starthour = 12;
			else
				starthour = starthour + 12;
                }
                else
                {
			if(starthour == 12)
                                starthour = 0;
                        else
                                starthour = starthour;
                }
        }
	starthour = _2digit(starthour);
        startmin = _2digit(startmin);
        document.EditView.time_start.value = starthour+':'+startmin;
}


var moveupLinkObj,moveupDisabledObj,movedownLinkObj,movedownDisabledObj;

function userEventSharing(selectedusrid,selcolid)
{
        formSelectColumnString(selectedusrid,selcolid);
}


function incUser(avail_users,sel_users)
{
	availListObj=getObj(avail_users)
        selectedColumnsObj=getObj(sel_users)
        var selectlength=selectedColumnsObj.length
        var availlength=availListObj.length

	for (i=0;i<selectedColumnsObj.length;i++)
	{
		selectedColumnsObj.options[i].selected=false
	}
	for (i=0;i<availListObj.length;i++)
	{
		if (availListObj.options[i].selected==true)
		{
			var rowFound = false;
			var existingObj = null;
			for (j=0;j<selectedColumnsObj.length;j++)
			{
				if (selectedColumnsObj.options[j].value==availListObj.options[i].value)
				{
				    availListObj.options.remove(i);//无论默认有无，都去掉该备选项 
					rowFound=true;
					existingObj=selectedColumnsObj.options[j]
					break
				}
			}
			if (rowFound!=true)
			{
				var newColObj=document.createElement("OPTION")
					newColObj.value=availListObj.options[i].value
					if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
					else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
						selectedColumnsObj.appendChild(newColObj)
							availListObj.options[i].selected=false
                            availListObj.options.remove(i);
                            i=-1;
							newColObj.selected=true
							rowFound=false
			}
			else
			{
				if (existingObj != null) existingObj.selected=true
			}
		}
	}
}

function rmvUser(sel_users)
{
	selectedColumnsObj=getObj(sel_users)
        var selectlength=selectedColumnsObj.options.length
	for(i = 0; i <= selectlength; i++)
	{
		if(selectedColumnsObj.options.selectedIndex >= 0)
		selectedColumnsObj.remove(selectedColumnsObj.options.selectedIndex)
	}

}
/**
 *@edit:andy 
 *@date:
 *@reason:左右结构点击事件
 *@version:
 */
function addCalendarColumn(source, destination) 
{
    var availListObj=getObj(source)
    var selectedColumnsObj=getObj(destination)


    for (i=0;i<availListObj.length;i++) 
    {
        if (availListObj.options[i].selected==true) 
        {            	
        	var rowFound=false;
        	var existingObj=null;
            for (j=0;j<selectedColumnsObj.length;j++) 
            {
                if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                {
                    rowFound=true
                    existingObj=selectedColumnsObj.options[j]
                    break
                }
            }
            if (rowFound!=true) 
            {
                var newColObj=document.createElement("OPTION")
                newColObj.value=availListObj.options[i].value
                if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                selectedColumnsObj.appendChild(newColObj)
                availListObj.options[i].selected=false
                newColObj.selected=true
                availListObj.remove(i);//20140902，diony，右移时删除左边信息
                rowFound=false
            } 
            else 
            {
                if(existingObj != null) existingObj.selected=true
            }
        }
    }
	formSelectColumnString('inviteesid','selectedusers');
}


// function to delete activity related contact in calendar
var del_ids = new Array();
function removeActContacts()
{
	var avail_contacts = getObj('parentid');
	// this block is to remove contacts and get deleted contact ids
	if(avail_contacts.options.selectedIndex > -1)
	{
		for(m = 0; m < avail_contacts.options.length; m++)
		{
			if(avail_contacts.options[m].selected == true)
			{
				del_ids.push(avail_contacts.options[m].value);
				avail_contacts.options[m] = null;
				removeActContacts();
			}
		}
	}
	document.EditView.deletecntlist.value = del_ids.join(";");

	// this block is to get available id list
	var avail_ids = new Array();
	for(n=0; n<avail_contacts.options.length;n++)
	{
		avail_ids.push(avail_contacts.options[n].value);
	}
	document.EditView.contactidlist.value = avail_ids.join(";");

}
//end
function formSelectColumnString(usr,col)
{
	var selectedColumnsObj=getObj(col)
	var popupobj=CrmPopup.getPopupObj("last");
	var obj_usr =CrmPopup.findHtmlobj(popupobj.divid,usr);
	var selectedColStr = "";
        for (i=0;i<selectedColumnsObj.options.length;i++)
        {
        	selectedColStr += selectedColumnsObj.options[i].value + ";";
        }
	obj_usr.val(selectedColStr);
}

function fnRedirect() {
        //var OptionData = $('view_Option').options[$('view_Option').selectedIndex].value;
        var OptionData='listview';
	if(OptionData == 'listview')
	{
		document.EventViewOption.action.value = "index";
		puyoungJS_DialogBox.block();
		window.document.EventViewOption.submit();
	}
	if(OptionData == 'hourview')
	{
		document.EventViewOption.action.value = "index";
		puyoungJS_DialogBox.block();
		window.document.EventViewOption.submit();
	}
}

function SmownerChange(selectView,baseurl)
{
    
  
    if(baseurl=='')
    {
        baseurl='module=Calendar&action=index';
    }
    //return false;
   // var e=event||window.event;
   // var selectView=e.srcElement||e.target;
    var viewName = encodeURIComponent(selectView.options[selectView.options.selectedIndex].value);

   	if('smowner_search_senior' == viewName){//高级
		SmOwnerSearchSeniorcalendar(selectView,baseurl);return false;
	}
     $("status").style.display="inline";
     //aaaaaaalert(baseurl);
    //index.php?action=index&module=Calendar&parenttab=My Home Page"
    var strsplit=baseurl.split("&");
    var strviewname=strsplit[strsplit.length-1];
    //alert(strviewname);
    if(strviewname.indexOf("SearchScope")!=-1)
    {
        baseurl="";
        for(var i=0;i<strsplit.length-1;i++)
        {
            baseurl=baseurl+strsplit[i]+"&";
            
        }
        arrviewname=strviewname.split("=");
        baseurl=baseurl+arrviewname[0]+"="+viewName;
        window.location="index.php?"+baseurl;
    }
   else 
   {
        window.location="index.php?"+baseurl+"&SearchScope="+viewName;
   }
  
    
}

function SmOwnerSearchSeniorcalendar(ipt,baseurl){
	var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['VIEWRANGESENIOR'];//标题
	var module = 'Calendar';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		scopepopupobj =  new ScopePopupObj(module);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = '';
           cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					if(empty(cls_ScopePopup.return_obj.return_id)){
						var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
						RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
                    }else{
						ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
						ipt.value = cls_ScopePopup.return_obj.return_id; 
						var uid=cls_ScopePopup.return_obj.return_id;
						$("status").style.display="inline";
						//aaaaaaalert(baseurl);
						//index.php?action=index&module=Calendar&parenttab=My Home Page"
						var strsplit=baseurl.split("&");
						var strviewname=strsplit[strsplit.length-1];
						if(strviewname.indexOf("SearchScope")!=-1){
							baseurl="";
							for(var i=0;i<strsplit.length-2;i++){
								baseurl=baseurl+strsplit[i]+"&";
							}
							arrviewname=strviewname.split("=");
							if(arrviewname[0].indexOf('&')<0){
								arrviewname[0]='&'+arrviewname[0];//18227: 日程管理>日历视图：查看范围，点击高级，选择用户后，查看范围显示的是全部。数据也是全部的数据。
							}
							baseurl=baseurl+"&senioruserid="+uid+arrviewname[0]+"=smowner_search_senior";
							window.location="index.php?"+baseurl;
						}else {
							window.location="index.php?"+baseurl+"&senioruserid="+uid+"&SearchScope=smowner_search_senior";
						}  
					}
                });
            }
		});
	});
    
}
function fnRemoveEvent(){
	var tagName = document.getElementById('addEventDropDown').style.display = 'none';
}

function fnShowEvent(){
		var tagName = document.getElementById('addEventDropDown').style.display= 'block';
}

function getMiniCal(url){
	if(url == undefined)
		url = 'module=Calendar&action=ActivityAjax&type=minical&ajax=true';
	else
		 url = 'module=Calendar&action=ActivityAjax&'+url+'&type=minical&ajax=true';
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: url,
                        onComplete: function(response) {
                                $("miniCal").innerHTML=response.responseText;
                                fnvshobj(this,"miniCal");
                        }
                }

          );
}

function getCalSettings(url){
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'module=Calendar&action=ActivityAjax&'+url+'&type=settings&ajax=true',
                        onComplete: function(response) {
                                $("calSettings").innerHTML=response.responseText;
                                fnvshobj('','calSettings');
                        }
                        
                }

          );
}

function updateStatus(record,status,view,hour,day,month,year,type){
	if(type == 'event')
	{
		//var OptionData = $('view_Option').options[$('view_Option').selectedIndex].value;
        var OptionData='listview';

		new Ajax.Request(
                	'index.php',
                	{queue: {position: 'end', scope: 'command'},
                        	method: 'post',
                        	postBody: 'module=Calendar&action=ActivityAjax&record='+record+'&'+status+'&view='+view+'&hour='+hour+'&day='+day+'&month='+month+'&year='+year+'&type=change_status&viewOption='+OptionData+'&subtab=event&ajax=true',
                        	onComplete: function(response) {
                        document.EventViewOption.action.value = "index";
						window.document.EventViewOption.submit();
                  

               }}
		);
	}
	if(type == 'todo')
        {
		new Ajax.Request(
                        'index.php',
			{queue: {position: 'end', scope: 'command'},
                                method: 'post',
				postBody: 'module=Calendar&action=ActivityAjax&record='+record+'&'+status+'&view='+view+'&hour='+hour+'&day='+day+'&month='+month+'&year='+year+'&type=change_status&subtab=todo&ajax=true',
                                onComplete: function(response) {
					result = response.responseText.split('####');
					$("total_activities").innerHTML = result[1];
					$("mnuTab2").innerHTML=result[0];
                                }
                        }
                )
	}
}

function cal_navigation(type,urlstring,start)
{
	var url = urlstring;
	$("status").style.display="inline";
	if(type == 'event')
        {
			var users = document.getElementsByName('onlyforuser');
			var onlyforusers = users[0].value;
			var OptionData = $('view_Option').options[$('view_Option').selectedIndex].value;
	                new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'module=Calendar&action=CalendarAjax&file=ActivityAjax&ajax=true&n_type=nav&viewOption='+OptionData+url+start+'&subtab='+type+'&onlyforuser='+encodeURIComponent(onlyforusers),
                                onComplete: function(response) {
					if(OptionData == 'listview')
                                        {
                                                result = response.responseText.split('####');
                                                $("total_activities").innerHTML = result[1];
                                                $("listView").innerHTML=result[0];
						$("status").style.display="none";
                                        }
                                        if(OptionData == 'hourview')
					{
                                                result = response.responseText.split('####');
                                                $("total_activities").innerHTML = result[1];
                                                $("hrView").innerHTML=result[0];
						$("status").style.display="none";
                                        }
                                }
                        }
                );
        }
	if(type == 'todo')
        {
                new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'module=Calendar&action=CalendarAjax&file=ActivityAjax&ajax=true&n_type=nav'+url+start+'&subtab=todo',
                                onComplete: function(response) {
                                        result = response.responseText.split('####');
                                        $("total_activities").innerHTML = result[1];
                                        $("mnuTab2").innerHTML=result[0];
					$("status").style.display="none";
                                }
                        }
                );
        }
}
/**
推迟
**/
function DelayCalendar(record,activity_mode,view,hour,day,month,year,OptionData,type)
{
    fninvshnew('eventcalAction');
    var Popupobj=PageRecordPopup.loadobj("","","","LdPopWidth950px","Calendar","","","","",record);
    Popupobj.prevshow();
    PageRecordPopup.params['refreshpage']='yes';
    PageRecordPopup.showpage('Calendar',record,"&return_action=index&activity_mode="+activity_mode+"&view="+view+"&hour="+hour+"&day="+day+"&month="+month+"&year="+year+"&viewOption="+OptionData+"&subtab="+type+"&maintab=Calendar",PageRecordPopup.params);
}
function getcalAction(obj,Lay,id,view,hour,dateVal,type){
    var tagName = document.getElementById(Lay);
    var leftSide = findPosX(obj);
    var topSide = findPosY(obj);
    var maxW = tagName.style.width;
    var widthM = maxW.substring(0,maxW.length-2);
    var getVal = eval(leftSide) + eval(widthM);
    var vtDate = dateVal.split("-");
    var day = parseInt(vtDate[2],10);
    var month = parseInt(vtDate[1],10);
    var year = parseInt(vtDate[0],10);
    if(getVal  > window.innerWidth ){
        leftSide = eval(leftSide) - eval(widthM);
        tagName.style.left = leftSide + 'px';
    }
    else
        tagName.style.left= leftSide + 'px';
    tagName.style.top= topSide + 'px';
    tagName.style.display = 'block';
    tagName.style.visibility = "visible";
   //bug:3728 add by kara 
    if(obj.getAttribute('eventstatus')=='瀹稿弶澧界悰')
   {
     document.getElementById('complete').style.display='none';
     document.getElementById('pending').style.display='block';
   }
   else if(obj.getAttribute('eventstatus')=='閺堫亝澧界悰')
   {
     document.getElementById('pending').style.display='none';
     document.getElementById('complete').style.display='block';
   }
   else{
     document.getElementById('complete').style.display='block';
     document.getElementById('pending').style.display='block';
   }
   //add end
    if(type == 'event')
    {
    /*
    *AUTHOR:BY LD KEVIN
    *DATE:20130121
    *DESCRIPTION:濞存粌顑勫▎銏ゆ偐閼哥鍋撴担铏瑰€抽悹鍥ㄥ灴濡埖锛?    */
	//var heldstatus = "eventstatus=Held";
	//var notheldstatus = "eventstatus=Not Held";
    
  //  var heldstatus = "eventstatus="+alert_arr.Held;
  //  var notheldstatus = "eventstatus="+alert_arr.Not_Held;
  var heldstatus = "eventstatus="+arrJsPopLabel['Held'];
    var notheldstatus = "eventstatus="+arrJsPopLabel['NOHeld'];
        var activity_mode = "Events";
	var complete = document.getElementById("complete");
	var pending = document.getElementById("pending");
	var postpone = document.getElementById("postpone");
	var actdelete =	document.getElementById("actdelete");
	var changeowner = document.getElementById("changeowner");
    /*
    *AUTHOR:BY LD KEVIN
    *DATE:20130121
    *DESCRIPTION:濞ｅ浂鍠楅弫绯眜g3164
    */
	//var OptionData = document.getElementById('view_Option').options[document.getElementById('view_Option').selectedIndex].value;
    var OptionData='listview';
    }
    if(type == 'todo')
    {
	var heldstatus = "status=Completed";
        var notheldstatus = "status=Deferred";
	var activity_mode = "Task";
	var complete = document.getElementById("taskcomplete");
        var pending = document.getElementById("taskpending");
        var postpone = document.getElementById("taskpostpone");
        var actdelete = document.getElementById("taskactdelete");
        var changeowner = document.getElementById("taskchangeowner");
	var OptionData = '';
    }
    document.getElementById("idlist").value = id;
    document.change_owner.hour.value = hour;
    document.change_owner.day.value = day;
    document.change_owner.view.value = view;
    document.change_owner.month.value = month;
    document.change_owner.year.value = year;
    document.change_owner.subtab.value = type;
    if(complete) complete.href="javascript:updateStatus("+id+",'"+heldstatus+"','"+view+"',"+hour+","+day+","+month+","+year+",'"+type+"')";
    if(pending) pending.href="javascript:updateStatus("+id+",'"+notheldstatus+"','"+view+"',"+hour+","+day+","+month+","+year+",'"+type+"')";
    if(postpone)
    {
       postpone.onclick=function()
       {
            DelayCalendar(id,activity_mode,view,hour,day,month,year,OptionData,type);
       }
    }
    //if(postpone) postpone.href="index.php?module=Calendar&action=EditView&record="+id+"&return_action=index&activity_mode="+activity_mode+"&view="+view+"&hour="+hour+"&day="+day+"&month="+month+"&year="+year+"&viewOption="+OptionData+"&subtab="+type+"&maintab=Calendar";

    if(actdelete) actdelete.href="javascript:delActivity("+id+",'"+view+"',"+hour+","+day+","+month+","+year+",'"+type+"')";

    if(changeowner) changeowner.href="javascript:fnvshobj('','act_changeowner');";

}

function dispLayer(lay)
{
	var tagName = document.getElementById(lay);
	tagName.style.visibility = 'visible';
	tagName.style.display = 'block';
}

//check whether user form selected or group form selected
function checkgroup()
{
	if($("group_checkbox").checked)
	{
		  document.change_owner.lead_group_owner.style.display = "block";
	          document.change_owner.lead_owner.style.display = "none";
	}
	else
	{
		document.change_owner.lead_group_owner.style.display = "none";
                document.change_owner.lead_owner.style.display = "block";
	}
}

function calendarChangeOwner()
{
   
	var idlist = document.change_owner.idlist.value;
        var view   = document.change_owner.view.value;
        var day    = document.change_owner.day.value;
        var month  = document.change_owner.month.value;
        var year   = document.change_owner.year.value;
        var hour   = document.change_owner.hour.value;
        var subtab = document.change_owner.subtab.value;

	//var checked = document.change_owner.user_lead_owner[0].checked;
		var user_id = document.getElementById('lead_owner').options[document.getElementById('lead_owner').options.selectedIndex].value;
		var url = 'module=Users&action=updateLeadDBStatus&return_module=Calendar&return_action=ActivityAjax&owner_id='+user_id+'&idlist='+idlist+'&view='+view+'&hour='+hour+'&day='+day+'&month='+month+'&year='+year+'&type=change_owner&owner_type=User';
	

	if(subtab == 'event')
	{
        var OptionData='hourview';
		var eventurl = url+'&viewOption='+OptionData+'&subtab=event&ajax=true';
        
	 	new Ajax.Request(
                	'index.php',
                	{queue: {position: 'end', scope: 'command'},
                        	method: 'post',
                        	postBody: eventurl,
                        	onComplete: function(response) {
					if(OptionData == 'listview')
					{
						result = response.responseText.split('####');
                        $("total_activities").innerHTML = result[1];
                        $("listView").innerHTML=result[0];
						document.EventViewOption.action.value = "index";
					//	window.document.EventViewOption.submit();
					}
					if(OptionData == 'hourview')
					{
					   /**
                       *edit:kevin
                       *date:2013-08-08
                       */
						//result = response.responseText.split('####');
                        //$("total_activities").innerHTML = result[1];
                        $("hrView").innerHTML=response.responseText;
						document.EventViewOption.action.value = "index";
						window.document.EventViewOption.submit();
					}
                        	}
                	}
		);
	}
	if(subtab == 'todo')
        {

		var todourl = url+'&subtab=todo&ajax=true';
                new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: todourl,
                                onComplete: function(response) {
					result = response.responseText.split('####');
					$("total_activities").innerHTML = result[1];
					$("mnuTab2").innerHTML=result[0];
                               }
                        }
                );
        }
}

function delActivity(id,view,hour,day,month,year,subtab)
{
	if(subtab == 'event')
	{
		var users = document.getElementsByName('onlyforuser');
		var onlyforuser = users[0].value;
        var OptionData='hourview';
         	new Ajax.Request(
	                	'index.php',
	                	{queue: {position: 'end', scope: 'command'},
	                        	method: 'post',
	                        	postBody: 'module=Users&action=massdelete&return_module=Calendar&return_action=ActivityAjax&idlist='+id+'&view='+view+'&hour='+hour+'&day='+day+'&month='+month+'&year='+year+'&type=activity_delete&viewOption='+OptionData+'&subtab=event&ajax=true&onlyforuser='+encodeURIComponent(onlyforuser),
	                        	onComplete: function(response) {
								document.EventViewOption.action.value = "index";
						        window.document.EventViewOption.submit();
                        	}
                	}
		);
	}
	if(subtab == 'todo')
        {
                new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'module=Users&action=massdelete&return_module=Calendar&return_action=ActivityAjax&idlist='+id+'&view='+view+'&hour='+hour+'&day='+day+'&month='+month+'&year='+year+'&type=activity_delete&subtab=todo&ajax=true',
                                onComplete: function(response) {
					result = response.responseText.split('####');
					$("total_activities").innerHTML = result[1];
					$("mnuTab2").innerHTML=result[0];
                               }
                        }
                );
        }
}


/*
* javascript function to display the div tag
* @param divId :: div tag ID
*/
function cal_show(divId)

{

    var id = document.getElementById(divId);

    id.style.visibility = 'visible';

}

function fnAssignTo(){
		var option_Box = document.getElementById('parent_type');
		var option_select = option_Box.options[option_Box.selectedIndex].value;
		if(option_select == "Leads" || option_select == "Leads&action=Popup")
		{
			document.getElementById('leadLay').style.visibility = 'visible';
		}
		else if(option_select == "Accounts" || option_select == "Accounts&action=Popup")
		{
			document.getElementById('leadLay').style.visibility = 'visible';
		}
		else if(option_select == "Potentials" || option_select == "Potentials&action=Popup")
		{
			document.getElementById('leadLay').style.visibility = 'visible';
		}
		else if(option_select == "Quotes&action=Popup" || option_select == "Quotes&action=Popup")
                {
                        document.getElementById('leadLay').style.visibility = 'visible';
                }
		else if(option_select == "PurchaseOrder" || option_select == "PurchaseOrder&action=Popup")
                {
                        document.getElementById('leadLay').style.visibility = 'visible';
                }
		else if(option_select == "SalesOrder" || option_select == "SalesOrder&action=Popup")
                {
                        document.getElementById('leadLay').style.visibility = 'visible';
                }
		else if(option_select == "Invoice" || option_select == "Invoice&action=Popup")
                {
                        document.getElementById('leadLay').style.visibility = 'visible';
                }
		else if(option_select == "Campaigns" || option_select == "Campaigns&action=Popup")
                {
                        document.getElementById('leadLay').style.visibility = 'visible';
                }
		else{
			document.getElementById('leadLay').style.visibility = 'hidden';
		}
	}

function fnShowPopup(){
	document.getElementById('popupLay').style.display = 'block';
}

function fnHidePopup(){
	document.getElementById('popupLay').style.display = 'none';
}

function getValidationarr(id,activity_mode,opmode,subtab,viewOption)
{
	 new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'module=Calendar&action=ActivityAjax&record='+id+'&activity_mode='+activity_mode+'&ajax=true&type=view&file=DetailView',
                                onComplete: function(response) {
                                        $("dataArray").innerHTML=response.responseText;
					setFieldvalues(opmode,subtab,viewOption);
                                }
                        }
                );

}

function setFieldvalues(opmode,subtab,viewOption)
{
	var st = document.getElementById('activity_cont');
	eval(st.innerHTML);
	if(activity_type == 'Events')
	{
		document.EditView.viewOption.value = viewOption;
                document.EditView.subtab.value = subtab;
		for(x=0;x<key.length;x++)
		{
			if(document.EditView[key[x]] != undefined)
			{

				if(key[x] == 'visibility' && data[x] == 'Public')
					document.EditView.visibility.checked = true;
				if(key[x] == 'visibility' && data[x] == 'Private')
					document.EditView.visibility.checked = false;
				if(key[x] == 'activitytype' && data[x] == 'Call')
				{
					document.EditView.activitytype[0].checked = true;
				}
				else
				{
					document.EditView.activitytype[1].checked = true;
				}
				if(key[x] == 'set_reminder' && data[x] == 'Yes')
				{
					document.EditView.remindercheck.checked = true;
					document.getElementById('reminderOptions').style.display = 'block';
				}
				if(key[x] == 'recurringcheck' && data[x] == 'on')
				{
					document.EditView.recurringcheck.checked = true;
					document.getElementById('repeatOptions').style.display = 'block';
				}
				if(key[x] == 'recurringtype')
				{
					if(data[x] == 'Weekly')
						document.getElementById('repeatWeekUI').style.display = 'block';
					else
						document.getElementById('repeatWeekUI').style.display = 'none';
					if(data[x] == 'Monthly')
						document.getElementById('repeatMonthUI').style.display = 'block';
					else
						document.getElementById('repeatMonthUI').style.display = 'none';
				}
				if(key[x] == 'parent_name')
				{
					if(data[x] != '')
						document.getElementById('leadLay').style.visibility = 'visible';
					else
						document.getElementById('leadLay').style.display = 'hidden';
				}
				document.EditView[key[x]].value = data[x];
			//}
			}
		}
		document.getElementById('addEvent').style.display = 'block';
	}
	else
	{
		document.createTodo.viewOption.value = viewOption;
                document.createTodo.subtab.value = subtab;
		for(x=0;x<key.length;x++)
                {
			if(document.createTodo[key[x]] != undefined)
			{
                                document.createTodo[key[x]].value = data[x];
			}
		}
		document.getElementById('createTodo').style.display = 'block';
	}
}

function doNothing()
{
}

/** This is Javascript Function which is used to toogle between
  * assigntype user and group/team select options while assigning owner to Task.
  */
function toggleTaskAssignType(currType)
{
        if (currType=="U")
        {
                getObj("task_assign_user").style.display="block"
                getObj("task_assign_team").style.display="none"
        }
        else
        {
                getObj("task_assign_user").style.display="none"
                getObj("task_assign_team").style.display="block"
        }
}

function dochange(start,end)
{
        var startdate = document.getElementById(start);
        document.getElementById(end).value = startdate.value;
}

function getSelectedStatus()
{
        var chosen = document.EditView.eventstatus.value;
        if(chosen == "Held")
        {
                document.getElementById('date_table_firsttd').style.width = "33%";
                document.getElementById('date_table_secondtd').style.width = "33%";
                document.getElementById('date_table_thirdtd').style.display = 'block';
        }
        else
        {
                document.getElementById('date_table_firsttd').style.width = "50%";
                document.getElementById('date_table_secondtd').style.width = "50%";
                document.getElementById('date_table_thirdtd').style.display = 'none';
        }

}

function changeEndtime_StartTime(type)
{
	calDuedatetime(type);
	return true;
}

function calDuedatetime(type)
{
        var dateval1=getObj('date_start').value.replace(/^\s+/g, '').replace(/\s+$/g, '');
        var dateelements1=splitDateVal(dateval1);
        dd1=parseInt(dateelements1[0],10);
        mm1=dateelements1[1];
        yyyy1=dateelements1[2];
        var date1=new Date();
        //date1.setDate(dd1+1);
        date1.setYear(yyyy1);
        date1.setMonth(mm1-1,dd1+1);
	var tempdate = getdispDate(date1);
        var date = document.EditView.date_start.value;
        var hour = parseInt(document.EditView.starthr.value,10);
        var min = parseInt(document.EditView.startmin.value,10);
        var fmt = document.EditView.startfmt.value;
	if(type != 'Call')
        {
                if(fmt == 'pm')
                {
                        if(hour == 11)
                        {
                                date = tempdate;
                                hour = 12;
                                min = min;
                                fmt = 'am';

                        }else if(hour == 12)
                        {
                                hour = 1;
                                min = min;
                                fmt = 'pm';
			}
                	else hour = hour + 1;
			hour = _2digit(hour);
                        min = _2digit(min);
			document.EditView.due_date.value = date;
			document.EditView.calendar_repeat_limit_date.value = date;
			document.EditView.endhr.value = hour;
			document.EditView.endmin.value = min;
			document.EditView.endfmt.value = fmt;
			document.EditView.followup_date.value = date;
                        document.EditView.followup_starthr.value = hour;
                        document.EditView.followup_startmin.value = min;
                        document.EditView.followup_startfmt.value = fmt;
		}else if(fmt == 'am')
		{
                        if(hour == 11)
                        {
                                hour = 12;min = min;fmt = 'pm';
                        }else if(hour == 12)
                        {
                                hour = 1;min = min;fmt = 'am';
                        }
                        else hour = hour + 1;
			hour = _2digit(hour);
                        min = _2digit(min);
                        document.EditView.due_date.value = date;
                        document.EditView.endhr.value = hour;
                        document.EditView.endmin.value = min;
                        document.EditView.endfmt.value = fmt;
			document.EditView.followup_date.value = date;
                        document.EditView.followup_starthr.value = hour;
                        document.EditView.followup_startmin.value = min;
                        document.EditView.followup_startfmt.value = fmt;
                }else
		{
                        hour = hour + 1;
                        if(hour == 24)
                        {
                                hour = 0;
                                date =  tempdate;
                        }
			hour = _2digit(hour);
                        min = _2digit(min);
                        document.EditView.due_date.value = date;
                        document.EditView.endhr.value = hour;
                        document.EditView.endmin.value = min;
			document.EditView.followup_date.value = date;
                        document.EditView.followup_starthr.value = hour;
                        document.EditView.followup_startmin.value = min;
                }
        }
	if(type == 'Call')
        {
                if(fmt == 'pm')
                {
                        if(hour == 11 && min == 55)
                        {
                                hour = 12;min = 0;fmt = 'am';
                                date = tempdate;
                        }
			else if(hour == 12 && min == 55)
			{
				hour = 1;min = 0;fmt = 'pm';
			}
                        else
                        {
                                if(min == 55)
                                {
                                        min = 0;
                                        hour = hour + 1;
                                }
                                else    min = min + 5;
                        }
			hour = _2digit(hour);
                        min = _2digit(min);
                        document.EditView.due_date.value = date;
						document.EditView.calendar_repeat_limit_date.value = date;
                        document.EditView.endhr.value = hour;
                        document.EditView.endmin.value = min;
                        document.EditView.endfmt.value = fmt;
			document.EditView.followup_date.value = date;
                        document.EditView.followup_starthr.value = hour;
                        document.EditView.followup_startmin.value = min;
                        document.EditView.followup_startfmt.value = fmt;
                }else if(fmt == 'am')
		{
                        if(hour == 11 && min == 55)
                        {
                                hour = 12;
                                min = 0;
                                fmt = 'pm';
                        }
			else if(hour == 12 && min == 55)
			{
				hour = 1;
                                min = 0;
				fmt = 'am';
			}
                        else
                        {
                                if(min == 55)
                                {
                                        min = 0;
                                        hour = hour + 1;
                                }
                                else    min = min + 5;
                        }
			hour = _2digit(hour);
                        min = _2digit(min);
                        document.EditView.due_date.value = date;
						document.EditView.calendar_repeat_limit_date.value = date;
                        document.EditView.endhr.value = hour;
                        document.EditView.endmin.value = min;
                        document.EditView.endfmt.value = fmt;
			document.EditView.followup_date.value = date;
                        document.EditView.followup_starthr.value = hour;
                        document.EditView.followup_startmin.value = min;
                        document.EditView.followup_startfmt.value = fmt;
                }
                else
		{
                        if(min == 55)
                        {
                                min = 0;
                                hour = hour + 1;
                        }else min = min + 5;
                        if(hour == 24)
                        {
                                hour = 0;
                                date =  tempdate;
                        }
			hour = _2digit(hour);
                        min = _2digit(min);
                        document.EditView.due_date.value = date;
						document.EditView.calendar_repeat_limit_date.value = date;
                        document.EditView.endhr.value = hour;
                        document.EditView.endmin.value = min;
			document.EditView.followup_date.value = date;
                        document.EditView.followup_starthr.value = hour;
                        document.EditView.followup_startmin.value = min;
                }
        }
}

function cal_fnvshobj(obj,Lay){
    var tagName = document.getElementById(Lay);
    var leftSide = findPosX(obj);
    var topSide = findPosY(obj);
    tagName.style.left = 550 + 'px';
    tagName.style.top= (topSide - 100) + 'px';
    tagName.style.display = 'block';
    tagName.style.visibility = "visible";
}

/**this is for to add a option element while selecting contact in add event page
   lvalue ==> is a contact id
   ltext ==> is a contact name
**/
function addOption(lvalue,ltext)
{
	var optObj = document.createElement('OPTION')
	if (browser_ie) optObj.innerText = ltext;
        else if(browser_nn4 || browser_nn6) optObj.text = ltext;
	else optObj.text = ltext;
	optObj.value = lvalue;
	document.getElementById('parentid').appendChild(optObj);
}

function getdispDate(tempDate)
{
	var datefmt = document.EditView.dateformat.value;
        var dd = _2digit(parseInt(tempDate.getDate(),10));
        var mm = _2digit(parseInt(tempDate.getMonth(),10)+1);
	var yy = tempDate.getFullYear();
	if(datefmt == '%d-%m-%Y') return dd+'-'+mm+'-'+yy;
	else if(datefmt == '%m-%d-%Y') return mm+'-'+dd+'-'+yy;
	else return yy+'-'+mm+'-'+dd;
}

function copySelectedOptionsCalendarModule(source, destination) {

    //var srcObj = $(source);
	//var destObj = $(destination);
    var srcObj = document.getElementById(source);//$(source);
	var destObj = document.getElementById(destination);
	if(typeof(srcObj) == 'undefined' || typeof(destObj) == 'undefined') return;
    for(i=0;i<destObj.length;i++){
        destObj.options[i].selected=false;
    }
    for (i=0;i<srcObj.length;i++) {
		if (srcObj.options[i].selected==true) {
			var rowFound=false;
			var existingObj=null;
			for (j=0;j<destObj.length;j++) {
				if (destObj.options[j].value==srcObj.options[i].value) {
                    srcObj.options.remove(i);//无论默认有无，都去掉该备选项 ,               
					rowFound=true
					existingObj=destObj.options[j]
					break
				}
			}
			if (rowFound!=true) {
				var newColObj=document.createElement("OPTION")
				newColObj.value=srcObj.options[i].value
                if (browser_ie) 
                    newColObj.innerText=srcObj.options[i].innerText
				else if (browser_nn4 || browser_nn6) 
                    newColObj.text=srcObj.options[i].text
				destObj.appendChild(newColObj)//右键
				srcObj.options[i].selected=false
                srcObj.options.remove(i);
                i=-1;
				newColObj.selected=true
				rowFound=false
			} else {
				if(existingObj != null) 
                    existingObj.selected=true
			}
		}
	}
	formSelectColumnString('inviteesid','selectedusers');
}

function calendar_close(record,viewname)
{
	var surl = "index.php?action=CalendarAjax&file=Save&module=Calendar&record="+record+"&change_status=true&maintab=Calendar&return_module=Calendar&return_action=ListView&return_id="+record+"&return_viewname="+viewname+"&eventstatus=已执行&start=1";
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			var tmparra=new Array();
			  tmparra.push(record);
			  var tmpobj= new AfterUpdatePrevPopupObjContent('Calendar',"",tmparra);
			  var refreshlistmodules = new Array('Calendar');
			  tmpobj.eachrefreshlistbyModules(refreshlistmodules);
		}else{
			 RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
			 return false;
		}
        DelProgressObjs();
	})
}

//日历视图：日、周、月、年
var calendarMenu = function(links,date_str,viewbox,subtab,category){
	//查看范围
	var onlyforuser;
	if(document.getElementById('onlyforuser') != undefined){
		onlyforuser = document.getElementById('onlyforuser').value;
	}
	var senioruserid;
	if(document.getElementById('senioruserid') != undefined){
		senioruserid = document.getElementById('senioruserid').value;
	}
	window.location="index.php?module=Calendar&action=index&view="+links+date_str+"&viewOption="+viewbox+"&subtab="+subtab+"&parenttab="+category+"&onlyforuser="+onlyforuser+"&senioruserid="+senioruserid+'&SearchScope='+onlyforuser;
}


//ｚｘｍ　２０２１－０６３０　日历增加消息提醒设置　
function　showCalendarRemindSet(){
	var url = "index.php?module=Calendar&action=CalendarAjax&file=calendarRemindSet&mode=list";
	var module = 'Calendar';
	//BUG0066958  yujun 2023-6-8 消息提醒设界面“保存”和“取消”按钮未翻译
	var Popupobj = CrmPopup.load(arrJsPopLabel['msgRemindCalendar'],  submitCalendarRemindSet,"", 400, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['LBL_CLOSE']);
	Popupobj.setParams(arrJsPopLabel['msgRemindCalendar'],submitCalendarRemindSet,'',400,module,"" ,arrJsPopLabel['SAVE'],"", arrJsPopLabel['LBL_CLOSE']);
	Popupobj.createScrollDiv();//创建滚动条
	Popupobj.prevshow();
	ld.ajax({
		url: url,
		type: 'POST',
		dataType: 'json',
		async: true,
		timeout: 20000,
		success: function (data) {
			let divid = Popupobj.divid;
			ld('#Calendar_createpage'+divid+'_btnok').click(function(){
				return false;
			});
			if (data.code == 1) {
				Popupobj.show(data.result.content);
			}
		}
	});
}
//zxm 2021-0630 日历增加消息提醒设置　保存设置
function submitCalendarRemindSet(){
	var url = "index.php?module=Calendar&action=CalendarAjax&file=calendarRemindSet&mode=save";
	var params = ld('#remindset_form').serialize();
	ld.ajax({
		url: url,
		type: 'POST',
		data:params,
		dataType: 'json',
		async: true,
		timeout: 20000,
		success: function (data) {
			// ld('#crm_calendar').fullCalendar('refetchEvents');
			calendar.refetchEvents();
			let popupobj = CrmPopup.getPopupObj('last');
			popupobj.CancelEvent();
		}
	});
}
/**
 * editor:ljj
 * time:20231227
 * reason:XUQIU1002423
 * content:日历视图界面，“消息提醒显示设置”修改为“日历设置”，可自定义日周月默认值及默认时间（陈钦帅）
 * node:加载日历视图"日历设置"下拉框
 **/
function setCalendarSettingsSelect(calendarsettingsarr){
	var calendarsettingsobj = ld('[name=calendarSettings]');
	AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
	var calendarsetting_selectobj = ld_Select.showSelect(calendarsettingsobj.get(0),{
		'list': calendarsettingsarr,
		'width': '180px',
		'showfloat': 'right',
		'optionwidth':'180px',
		'selectname': arrJsPopLabel['CalendarSettings'],
		'change': function (evt){
			if (ld(evt.target).find('.ld_Select-option-seleced')){
				ld(evt.target).find('.ld_Select-option-seleced').removeClass('ld_Select-option-seleced');
			}
			var urlstring='index.php?module=Calendar&action=CalendarAjax&file=calendarRemindSet';
			urlstring += '&mode=list';
			var option=evt.NavBarItem.value;
			urlstring += '&option='+option;
			if (option == 'color' || option == 'field'){
				var cssWidth='LdPopWidth800px';
			}else {
				var cssWidth='LdPopWidth600px';
			}
			var popupobj=CrmPopup.load("","","",cssWidth,'Calendar',"","","","");
			popupobj.prevshow();
			ldAjax(urlstring,'',function (data) {
				if (data.code == 1){
					if (option == 'color'){
						popupobj.setParams(data.result.title,saveCalendarSettings,"",cssWidth,'Calendar',"",arrJsPopLabel['LBL_CLOSE'],"","");
					}else {
						popupobj.setParams(data.result.title,saveCalendarSettings,"",cssWidth,'Calendar',"",data.result.oktext,"",data.result.canceltext);
					}
					popupobj.show(data.result.content);
					popupobj.option=option;
					// ljj 20240118 XUQIU1000599 日程管理->日历视图，可自定义单据背景色和字体颜色（杨雅媚）
					if (option == 'color'){
						getJsScript('include/js/modules/Calendar/CalendarColorSettings.js',function () {//加载js内方法
							CalendarColorSettings.getInstance().moveTable();//加载拖拽排序
						});
						ld("#"+popupobj.divid+" #"+popupobj.divid+'_btncancel').bind('click',function (){
							calendar.refetchEvents();
						});
					} else if (option == 'field'){//XUQIU1002448 日程管理->日历视图，可自定义显示字段（陈钦帅）
						var url = 'index.php?module=Settings&action=SettingsAjax&file=TemplatePrintField&tabid=9&printtabid=9&mode=CalendarDisplayContent';
						ldAjaxNoProgress(url,'',function(data){
							ld('#'+popupobj.divid+' #tabField').html(data.result.fieldsel);
						});
					}
				}
			});
		}
	});
	/*if (calendarsettingsobj.find('.ld_Select-content').length > 0){
		calendarsettingsobj.find('.ld_Select-content').css('display','flex');
		calendarsettingsobj.find('.ld_Select-content').css('justify-content','center');
	}
	if (calendarsettingsobj.find('.ld_Select-component ').length > 0){
		calendarsettingsobj.find('.ld_Select-component ').css('width','180px');
	}*/
}

/**
 * editor:ljj
 * time:20231227
 * reason:XUQIU1002423
 * content:日历视图界面，“消息提醒显示设置”修改为“日历设置”，可自定义日周月默认值及默认时间（陈钦帅）
 * node:日历视图-日历设置-保存事件
 **/
function saveCalendarSettings(){
	var popupobj=CrmPopup.getPopupObj('last');
	var divid=popupobj.divid;
	var option=popupobj.option;
	var params='';
	if (option == 'notice'){
		var input=ld('#'+divid+' #remindset_form').find('input');
		var params_arr= new Array();
		ld.each(input,function (index,obj){
			var name=ld(obj).attr('name');
			var checked=ld(obj).prop('checked');
			checked=(checked==false)?'no':'yes';
			params_arr.push(name+'='+checked);
		});
		params=params_arr.join('&');
	}else if (option == 'default') {
		var default_display=ld("#"+divid+" [name=default_display]").val();
		var default_start_time=ld("#"+divid+" [name=default_start_time]").val();
		var default_time_slot=ld("#"+divid+" [name=default_time_slot]").val();
		params={'default_display':default_display,'default_start_time':default_start_time,'default_time_slot':default_time_slot};
	}else if (option == 'color') {
		popupobj.CancelEvent();
		calendar.refetchEvents();
		return false;
	}else if(option == 'field'){
		var content=ld("#"+divid+" [name=CKcontent]").val();
		if (empty(content)){
			MessagePopup.TipZero_warning(arrJsPopLabel['CONTENTTEMPLATECANNOTBEEMPTY']);
			return false;
		}
		params={'content':content};
	}
	var url = "index.php?module=Calendar&action=CalendarAjax&file=calendarRemindSet&mode=save&option="+option;
	ldAjax(url,params,function (data) {
		if (data.code == 1){
			popupobj.CancelEvent();
			if (option == 'default'){
				location.reload(true);
			}else {
				calendar.refetchEvents();
			}
		}
	});
}
