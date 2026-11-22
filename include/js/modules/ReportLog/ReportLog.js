/*
{*修改编码格式:统一编码：UTF-8*}
*/ 


var module="ReportLog";
var action="WeekReportLog";
var userid="SmOwner_Search_Me";
 var StartDate="";
 var EndDate="";
 var AccountId="all";
 var CalendarStatus="allcategor";
 var gbmode="write";
 /*记录上次查询日期，查询创建人，客户，点击的日程状态*/
 function ChangeObj(ReportLogType)
 {
    
    action="WeekReportLog";
    if(ReportLogType==0)
    {
        action="DailyReportLog";
    }
    else if(ReportLogType==1)
    {
        action="WeekReportLog";
    }
    else 
    {
        action="MonthReportLog";
        
    }
    if(document.forms['ReportLogHref'] != undefined){
		StartDate=document.forms['ReportLogHref'].StartDate.value;
		EndDate=document.forms['ReportLogHref'].EndDate.value;
		if(ReportLogType!=0){
			AccountId=document.getElementById("cu_id").options[document.getElementById("cu_id").selectedIndex].value;
		document.forms['ReportLogHref'].AccountId.value=AccountId;
		}
		
		if(document.forms['ReportLogHref'].SearchScope!=undefined)
		{
			userid=document.forms['ReportLogHref'].searchOwner.options[document.forms['ReportLogHref'].searchOwner.selectedIndex].value;
			document.forms['ReportLogHref'].SearchScope.value=userid;
		}
	}
	if(document.forms['ReportLog'] != undefined){
		StartDate=document.forms['ReportLog'].StartDate.value;
		EndDate=document.forms['ReportLog'].EndDate.value;
		if(ReportLogType!=0){
			AccountId=document.getElementById("cu_id").options[document.getElementById("cu_id").selectedIndex].value;
			document.forms['ReportLog'].AccountId.value=AccountId;
		}
		
		if(document.forms['ReportLog'].SearchScope!=undefined)
		{
			userid=document.forms['ReportLog'].searchOwner.options[document.forms['ReportLog'].searchOwner.selectedIndex].value;
			document.forms['ReportLog'].SearchScope.value=userid;
		}
	}
    if(ReportLogType!=0){
        document.forms['ReportLog'].AccountId.value=AccountId;
        }
    
    
    $("status").style.display="inline";
    return true;
 }
 /**
 *edit:can
 *date:20130513
 *reason:日程点击
 **/
 var ACalendar=undefined;
 function CalendarClick(ReportLogType)
 {
    if( $("status").style.display=="inline")
    {
        ACalendar.href="#";
       
    }
    ChangeObj(ReportLogType);
    document.forms['ReportLog'].CalendarStatus.vaule=CalendarStatus;
    document.forms['ReportLogHref'].CalendarStatus.value=CalendarStatus;
    ChangeAjax("");
 }
 /**
 *edit:Can
 *date:20130513
 *reason:客户查询变更
 **/
function ChangeAccount(obj,ReportLogType)
{
    if( $("status").style.display=="inline")
    {
        return false;
    }
    ChangeObj(ReportLogType);
     ChangeAjax(obj);
  
}
/*
edit:can
date:20130507
reason:查询范围的变更
*/
function ChangeSearchOwner(obj,ReportLogType)
{
    if( $("status").style.display=="inline")
    {
        return false;
    }
    ChangeObj(ReportLogType);
    ChangeAjax(obj);
      
}
function ChangeAjax(obj)
{   
	var yearOpt;
	var monthOpt;
	  if(document.getElementById('yearOpt') != undefined && document.getElementById('monthOpt') != undefined){
		  yearOpt = ld('#yearOpt').val(); 
		  monthOpt = ld('#monthOpt').val();
		  StartDate = yearOpt+"-"+monthOpt+"-01";
		  EndDate = yearOpt+"-"+monthOpt+"-20";
	  }
	  if(ld('#searchOwner') != undefined){
		userid = ld('#searchOwner').val();
	  }
      new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)
            +"&mode="+gbmode+"&SearchScope="+userid+"&StartDate="+encodeURIComponent(StartDate)+"&EndDate="+EndDate+'&yearOpt='+yearOpt+'&monthOpt='+monthOpt
            +"&AccountId="+AccountId+"&CalendarStatus="+encodeURIComponent(CalendarStatus)+"&Look=look&look=look&ReportHeader=dheader",
			onComplete: function(response) {
				$("status").style.display="none";
				var result = response.responseText.split("#####Success:::");
                var ret=result[1];
              
                $("LookReportLog").update(ret);  
                     
			}
		}
		);
}

function getReportLookUrl(reporttype){
	var SearchScope = '';
	if(ld('#searchOwner') != undefined){
		SearchScope = '&SearchScope='+ld('#searchOwner').val();
	}
	if(reporttype == 'Daily'){
		window.location.href='index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&look=look'+SearchScope;
	}else if(reporttype == 'Month'){
		window.location.href='index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&Look=look'+SearchScope;
	}else{
		window.location.href='index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&Look=look'+SearchScope;
	}
}
function changedate(date,stype){
	if(ld('#searchOwner') != undefined){
		userid = ld('#searchOwner').val();
	}
	var page_addurl='&StartDate='+encodeURIComponent(date)+'&look='+stype+'&reporttype='+stype+'&SearchScope='+userid
	page_addurl=encodeURIComponent(page_addurl);

	window.location.href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&page_addurl="+page_addurl;
	//alert('index.php?module=ReportLog&action=DailyReportLog&parenttab=My Home Page&StartDate='+encodeURIComponent(date)+'&look='+stype+'&reporttype='+stype+'&SearchScope='+userid);
	//window.location.href='index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&parenttab=My Home Page;
}
/*
edit:can
date:20130503
reason:暂存
ReportLogType:类型，0：日报，1：周报，2：月报
*/
function btntmpSave(obj,ReportLogType)
{
    var form=document.forms['ReportLog'];
    if(form!=undefined)
    {
         document.forms['ReportLog'].status.value="0";
         //form.action.value='save';
    }
    else 
    {
        //表单丢失！
        alert(arrJsPopLabel['FORMSLOST']);
        return false;
    }
    if(ReportLogType==0)
    {
        DailyReportSave(form);
    }
    else if(ReportLogType==1)
    {
         WeekReportSave(form);
    }
    else 
    {
        MonthReportSave(form);
    }
    return true;
   
}

/*
edit:can
date:20130503
reason:提交
ReportLogType:类型，0：日报，1：周报，2：月报
*/
function btnSubmit(obj,ReportLogType)
{
    var form=document.forms['ReportLog'];
    if(form!=undefined)
    {
         document.forms['ReportLog'].status.value="1";
         //form.action.value='save';
    }
    else 
    {
        //表单丢失！
        var confirm_str = arrJsPopLabel['FORMSLOST'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    if(ReportLogType==0)
    {
       DailyReportSave(form);
    }
    else if(ReportLogType==1)
    {
        WeekReportSave(form);
    }
    else 
    {
        MonthReportSave(form);
    }
}
var CkWorkSummary;
var ckNextWeekPlan;
function WeekReportSave(form)
{   //puyoungJS_DialogBox.block();
    var content = workSummaryEditor.getContent();
    if(content=="")
    {
		//puyoungJS_DialogBox.unblock();
        //本周总结不能为空！
        var confirm_str = arrJsPopLabel['WEEKSUMMARYCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	var fromdata = new FormData(ld(".ajax_form")[0]);
    var url = 'index.php?module=ReportLog&action=ReportLogAjax&file=save';
    ldAjax_File(url,fromdata,function (data) {
        if (data.code == 1){
            DelProgressObjs();
            MessagePopup.TipZero_success(arrJsPopLabel['SAVE']+arrJsPopLabel['SUCCESS']);
        }
    })
    //form.submit();
}

var CKNextMonthPlan;
/*
edit:can
date:20130508
reason:月报保存
*/
function MonthReportSave(form)
{
	//puyoungJS_DialogBox.block();
    var content = workSummaryEditor.getContent();
    if(content=="")
    {
		//puyoungJS_DialogBox.unblock();
        //本月总结不能为空！
        var confirm_str = arrJsPopLabel['MONTHSUMMARYCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    var nextcontent = nextMonthEditor.getContent();
    if(nextcontent == "")
    {puyoungJS_DialogBox.unblock();
        //下月计划不能为空！
        var confirm_str = arrJsPopLabel['MONTHPLANCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	var fromdata = new FormData(ld(".ajax_form")[0]);
	ld('#rptContentLoading').show();
    var url = 'index.php?module=ReportLog&action=ReportLogAjax&file=save';
    ldAjax_File(url,fromdata,function (data) {
        if (data.code == 1){
            DelProgressObjs();
            MessagePopup.TipZero_success(arrJsPopLabel['SAVE']+arrJsPopLabel['SUCCESS']);
        }
    })
    //form.submit();
}

/*
reason:月报查看年份改变
edit:can
date:20130508
*/
function YearChange(obj)
{
     ChangeObj(2);
   var form=document.forms['ReportLogHref'];
    var montbol=ld('#monthOpt').val();
    var StartDate=obj.options[obj.selectedIndex].value+"-"+montbol+"-01";
    var EndDate=obj.options[obj.selectedIndex].value+"-"+montbol+"-20";
    /* form.action.value="MonthReportLog";
    form.submit();*/
    var page_addurl=encodeURIComponent("&StartDate="+StartDate+"&EndDate="+EndDate);
    window.location.href='index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&page_addurl='+page_addurl;
    
}
/*
edit:can
date:20130507
reason:日期超链接跳转
*/
/*
edit:andrew
date:20140113
reason:没年最后1个月跳转错误
*/
function WeekReportLogHref(obj,ReportLogType){
	var form=document.forms['ReportLogHref'];
	form.AHref.value=obj.id;
	form.action.value="WeekReportLog";
	var page_addurl="&StartDate="+form.StartDate.value+"&EndDate="+form.EndDate.value+"&ReportLogType=1&AHref="+obj.id;
	page_addurl=encodeURIComponent(page_addurl);
	//alert("index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&page_addurl="+page_addurl);
	window.location.href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&page_addurl="+page_addurl;
	//form.submit();
}
function ReportLogHref(obj,ReportLogType)
{
    if(ReportLogType==0)
    {
    }
    else if(ReportLogType==1)
    {
        var form=document.forms['ReportLogHref'];
        form.AHref.value=obj.id;
        form.action.value="WeekReportLog";
		var page_addurl="&StartDate="+form.StartDate.value+"&EndDate="+form.EndDate.value+"&ReportLogType=1";
		page_addurl=encodeURIComponent(page_addurl);
		//alert("index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&page_addurl="+page_addurl);
		window.location.href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&page_addurl="+page_addurl;
        //form.submit();
    }
    else 
    {
         var form=document.forms['ReportLogHref'];
        // form.AHref.value=obj.id;
          var yearbol=document.getElementById('yearOpt').value;
          var monthbol=document.getElementById('monthOpt').value
          if(obj.id=="prev")
          {
               
            monthbol=monthbol-1;
            if(monthbol<=0)
            {
				var select_month_len = document.getElementById('monthOpt').length;
				if(select_month_len < 12){
					for(var i = select_month_len; i <= 12; i++){
						ld("#monthOpt").append( "<option value="+i+">"+i+"</option>" );
					}
				}
                yearbol=yearbol-1;
                monthbol=12;
            }
          }
          else if(obj.id=="next")
          { 
             
             monthbol=parseInt(monthbol)+1;
             //alert(monthbol);
             if(monthbol>12)
             {
                yearbol=parseInt(yearbol)+1;
                monthbol=1;
             }
          }

          form.StartDate.value=yearbol+"-"+monthbol+"-01";
          form.EndDate.value=yearbol+"-"+monthbol+"-20";
		  form.yearOpt.value = yearbol;
		  form.monthOpt.value = monthbol;
		  form.action.value="MonthReportLog";
          var page_addurl="&StartDate="+yearbol+"-"+monthbol+"-01&EndDate="+form.EndDate.value+"&yearOpt="+yearbol+"&monthOpt="+monthbol;
          page_addurl=encodeURIComponent(page_addurl);
            
		  window.location.href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&page_addurl="+page_addurl;
          //form.submit();
    }
   // return false;
}
/*
reason:月报查看月份改变
edit:can
date:20130508
*/
function MonthChange(obj)
{
   // ChangeObj(2);
    var form=document.forms['ReportLogHref'];
    var yearbol=form.yearOpt.options[form.yearOpt.selectedIndex].value;
    var StartDate=yearbol+"-"+obj.options[obj.selectedIndex].value+"-01";
	var monthOpt = obj.options[obj.selectedIndex].value;
    
    var EndDate=yearbol+"-"+obj.options[obj.selectedIndex].value+"-20";
  
    var page_addurl=encodeURIComponent("&StartDate="+StartDate+"&EndDate="+EndDate+"&monthOpt="+monthOpt);
    window.location.href='index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&page_addurl='+page_addurl;
}
/*
edit:can
date:20130513
reason:日程管理
*/
function reportMove(obj)
{   
    window.open("index.php?action=DetailView&module=Calendar&record="+obj.id+"&activity_mode=Events");
}
/*
edit:cdw
date:20130513
reason:0004591: 当周行动和日报参考: 点击日历中的联系记录进行链接，结果系统提示“没有找到您需要的记录”
*/
function reportMove2(obj)
{
    //跳转到联系记录详细页面
    window.open("index.php?module=ContactRecords&parenttab=Parent Accounts&action=DetailView&record="+obj.id);
}
function DailyReportSave(form){
    //puyoungJS_DialogBox.block();
    var content=dailySummaryEditor.getContent();
   // dailySummaryEditor = UE.getEditor('DailySummary').getContent(); //获取编辑器内容
    //if(dailySummaryEditor.html()=="")
    if(content == "")
    {
        //puyoungJS_DialogBox.unblock();
        //今日总结不能为空！
        var confirm_str = arrJsPopLabel['TODAYSUMMARYCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
	var fromdata = new FormData(ld(".ajax_form")[0]);
    var url = 'index.php?module=ReportLog&action=ReportLogAjax&file=save';
    ldAjax_File(url,fromdata,function (data) {
        if (data.code == 1){
            DelProgressObjs();
            MessagePopup.TipZero_success(arrJsPopLabel['SAVE']+arrJsPopLabel['SUCCESS']);
        }
    })
    //form.submit();
}
function AddModComments(obj,ReportLogId,ReportLogType){
    var module='ReportLog';
    var action='SaveModComments';
    var form=document.forms['ReportLogHref'];
    var modComment=form.txtbox_ModCommentsDetailViewBlockCommentWidget.value;
	//回复内容不能为空
	if(modComment == ''){
        var confirm_str = arrJsPopLabel['replycontentcannotbeempty'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)+"&ModComments="+encodeURIComponent(modComment)
            +"&ReportLogId="+ReportLogId+"&ReportLogType="+ReportLogType,
			onComplete: function(response) {
			 $('txtbox_ModCommentsDetailViewBlockCommentWidget').value='';
				var result = response.responseText.split("#####");
                var ret=result[1];
                $('ModCommentsDetailView').innerHTML =ret;
			}
		}
		);
}

function reloadContentFiltering(obj,ReportLogId,ReportLogType){
    var ReportLogHref=document.forms['ReportLogHref']; 
    var Scope=obj.options[obj.selectedIndex].value;
    var module='ReportLog';
    var action='SaveModComments';
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)+"&Scope="+Scope
            +"&ReportLogId="+ReportLogId+"&ReportLogType="+ReportLogType,
			onComplete: function(response) {
			 $('txtbox_ModCommentsDetailViewBlockCommentWidget').value='';
				var result = response.responseText.split("#####");
                var ret=result[1];
                $('ModCommentsDetailView').innerHTML =ret;
			}
		}
		);
}
function SelectWay(obj0,obj1){
    var form=document.forms['DailySummary'];
    obj0.checked=true;
    obj1.checked=false;
    if(obj0.id=='rbSummary'){
        form.type.value=0;
        $('dailysummarys').style.display='block';
        $('referencedates').style.display='none';
    }else{
        form.type.value=1;
        $('dailysummarys').style.display='none';
        $('referencedates').style.display='block';
    }
}
function CheckDate(){
    var form=document.forms['DailySummary'];
    var sdate=form.sdate.value;
    var edate=form.edate.value;
	var module = form.module.value;
	var file = form.file.value;
    var reDate = /^\d{4}(\-|\/|\.)\d{1,2}\1\d{1,2}$/;
    if(!reDate.test(sdate)){
        //开始日期格式不正确！
        var confirm_str = arrJsPopLabel['STARTDATEFORMATINCORRECT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.sdate.focus();
        return false;
    }
    if(!reDate.test(edate)){
        //结束日期格式不正确！
        var confirm_str = arrJsPopLabel['ENDDATEFORMATINCORRECT'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.edate.focus();
        return false;
    }
    if(sdate>edate){
        //开始日期不能大于结束日期！
        var confirm_str = arrJsPopLabel['STARTDATECANOTGREATERENDDATE'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        form.edate.focus();
        return false;
    }else{
		var SearchScope = '';
		if(ld('#searchOwner') != undefined){
			SearchScope = ld('#searchOwner').val();
		}
		var _type = form.type.value;
		ld('#rptContentLoading').show();
		//alert("module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module)+"Ajax&file="+file+"&searchOwner="+SearchScope+"&sdate="+sdate+"&edate="+edate+"&ajax=yes&type="+_type);
        new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module)+"Ajax&file="+file+"&searchOwner="+SearchScope+"&sdate="+sdate+"&edate="+edate+"&ajax=yes&type="+_type,
				onComplete: function(response) {
					//var result = response.responseText.split("#####");
					//var ret=result[1];
					ld('#rptContentLoading').hide();
					ld('#dailysummary_content').html(response.responseText);
				}
			}
		);
        //form.submit();
    }
}
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
function selectType(obj0,obj1){
    var form=document.forms['WeekAndMonthSummary'];
    obj0.checked=true;
    obj1.checked=false;
    if(obj0.id=='week'){
        form.type.value=1;
        document.getElementById('WeekSummaryDetail').style.display='block';
        document.getElementById('MonthSummaryDetail').style.display='none';
        }
        else
        {
            form.type.value=2;
            document.getElementById('WeekSummaryDetail').style.display='none';
            document.getElementById('MonthSummaryDetail').style.display='block';
        }
}


function chkSubmit() {
var form=document.forms['WeekAndMonthSummary'];
var flag = false;
var allcheckvals=$$('.StepUserClass');
var userid;
var userids='';
for( i=0; i <allcheckvals.length; i++ ) {
    var el=allcheckvals[i];
    if(el.checked ) {
        userid =el.value;
        userids=userids+userid+',';
    flag = true;
    }
}
form.userid.value=userids;
if( !flag ) {
    //请选择人员
    alert(arrJsPopLabel['PLEASESELECTPERSONNEL']);
    return false;
}
var module='ReportLog';
var action='WeekAndMonthSummary';
var type=form.type.value;
if(type==1){
    var start=form.start.value;
var end=form.end.value;
var syear=form.syear.value;
var eyear=form.eyear.value;
}
else{
    var start=form.monthstart.value;
var end=form.monthend.value;
var syear=form.monthsyear.value;
var eyear=form.montheyear.value;
}




    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module)+"Ajax&file=WeekAndMonthSummary&ajax=true&start="+start
            +"&end="+end+"&syear="+syear+"&eyear="+eyear+"&userids="+userids+"&type="+type,
			onComplete: function(response) {
				var result = response.responseText.split("#####");
                var ret=result[1];
                if(type==1)
                $('WeekSummaryDetail').innerHTML =ret;
                else
                $('MonthSummaryDetail').innerHTML =ret;
			}
		}
		);
}
function submitdate(date){
    var form=document.forms['WeekAndMonthSummary'];
    var date=date;
    var module='ReportLog';
    var action='WeekAndMonthSummary';
    var userids=form.userid.value;
    var type=form.type.value;
    if(type==1){
        url="&date="+date
    }else{
        url="&monthdate="+date;
    }
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module)+"Ajax&file=WeekAndMonthSummary&ajax=true&userids="+userids+"&type="+type+url,
			onComplete: function(response) {
				var result = response.responseText.split("#####");
                var ret=result[1];
                if(type==1)
                $('WeekSummaryDetail').innerHTML =ret;
                else
                $('MonthSummaryDetail').innerHTML =ret;
			}
		}
		);
}
function ChangeDateContorl(obj,ReportLog){
    var module="ReportLog";
    var action="DailyReportLog";
    var ReportLogHref=document.forms['ReportLogHref'];    
    var selectindex=ReportLogHref.searchOwner.options.selectedIndex;
    var userid=ReportLogHref.searchOwner.options[selectindex].value;
    ReportLogHref.SearchScope.value=userid;
    var StartDate=ReportLogHref.date_only.value;
    var EndDate=ReportLogHref.date_only.value;
    ReportLogHref.StartDate.value=StartDate;
    ReportLogHref.EndDate.value=EndDate;
      new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)
            +"&mode=ajax&SearchScope="+userid+"&StartDate="+encodeURIComponent(StartDate)+"&EndDate="+EndDate+"&look=look",
			
            onComplete: function(response) {
				$("status").style.display="none";
				var result = response.responseText.split("#####Success:::");
                var ret=result[1];         
                $("LookReportLog").update(ret);  
                     
			}
		}
		);
}

function Reportgetyestday(){
    var module="ReportLog";
    var action="DailyReportLog"; 
    var StartDate=document.getElementById('jscal_field_date').value;    
    var userid = document.getElementById("searchOwner").value;
      new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)
            +"&mode=ajax&modetype=suchday&SearchScope="+userid+"&look=look&StartDate="+encodeURIComponent(StartDate),
			onComplete: function(response) {
				$("status").style.display="none";
				var result = response.responseText.split("#####Success:::");
                var ret=result[1];                
                $("LookReportLog").update(ret);  
                     
			}
		}
		);
}

function Reportgettomorday(){
    var module="ReportLog";
    var action="DailyReportLog"; 
    var StartDate=document.getElementById('jscal_field_date').value;
        var userid = document.getElementById("searchOwner").value;
      new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)
            +"&mode=ajax&modetype=tsuchday&SearchScope="+userid+"&look=look&StartDate="+encodeURIComponent(StartDate),
			onComplete: function(response) {
				$("status").style.display="none";
				var result = response.responseText.split("#####Success:::");
                var ret=result[1];                
                $("LookReportLog").update(ret);  
                     
			}
		}
		);
}
var TomrrowPlan;
//获取明日日程
function getTomorrowCalendar(){
    var module='ReportLog';
    var action='DailyReportLog';
    var ReportLog=document.forms['ReportLog'];
    var StartDate=ReportLog.StartDate.value;
    var EndDate=ReportLog.EndDate.value;
    
    new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(action)
            +"&StartDate="+encodeURIComponent(StartDate)+"&EndDate="+EndDate+"&ajax=true",
			onComplete: function(response) {
				var result = response.responseText.split("#####");
                var ret=result[1];
				 tomrrowPlanEditor.setContent(ret);
                //tomrrowPlanEditor.html(ret);
               // tomrrowPlanEditor.getEditor('TomrrowPlan').execCommand('insertHtml', ret);
                               
                //TomrrowPlan.setData(ret);   
			}
		}
		);
}
function OPEditor()
{
     CKEDITOR.replace( "TomrrowPlan",
                	{
                		extraPlugins : 'uicolor',
                		uiColor: '#dfdff1',
                        height:110,
                			on : {
                				instanceReady : function( ev ) {
                					 this.dataProcessor.writer.setRules( 'p',  {
                						indent : false,
                						breakBeforeOpen : false,
                						breakAfterOpen : false,
                						breakBeforeClose : false,
                						breakAfterClose : false
                                        
                				});
                			}
                		}
                	});
                	 TomrrowPlan = CKEDITOR.instances["TomrrowPlan"];
                     TomrrowPlan.config.height="100";
                     TomrrowPlan.config.width="200";
}
function SelectScope(obj){
    var form=document.forms['DailySummary'];
    userid=form.searchOwner.options[form.searchOwner.selectedIndex].value;
    form.SearchScope.value=userid;
}   


 function positiveInteger(num)
    {
        if (num=="")
        {
                return false;
        }
            
        if (!(/(^[1-9]\d*$)/.test(num)))
        {
                return false;
        }
           
        return true;
    }
    
/*
edit:cxl
date:2015-4-24
reason:保存客户设置的日，周，月报告模板
*/
var report_issubmit = 1;
function reporttypeSubmit(obj,ReportLogType)
{
   var form=document.forms['ReportLog'];
    if(form!=undefined)
    {
         document.forms['ReportLog'].status.value="1";
         form.action.value='save';
    }
    else 
    {
        //表单丢失
        var confirm_str = arrJsPopLabel['FORMSLOST'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        return false;
    }
    if(1 != report_issubmit) return false;
    report_issubmit = 2;
    ReporttypetempletSave(ReportLogType);    
}
function ReporttypetempletSave(ReportLogType){
    puyoungJS_DialogBox.block();
    var content = reporttypeEditor.getContent(); //获取编辑器内容
    var urlstring = 'module=ReportLog&action=ReportLogAjax&file=reporttempletsave';
    urlstring += '&reporttemplet='+encodeURIComponent(content)+'&ReportLogType='+ReportLogType;
    var reporttempletarr = {0:'DailySummary',1:'WorkSummary','2':'WorkSummary'};
    RequestAjax(urlstring,function(rest){
		if(ReportLogType == 1 || ReportLogType == 2){
			workSummaryEditor.setContent(content);
		}else{
			dailySummaryEditor.setContent(content);
		}
        ld('#reporttemplet_div .D_pbtn .D_pbtncancel').click();
        report_issubmit = 1;
		DelProgressObjs();
    });
}

function delReportLog(reportlogtype,reportlogid){
	var urlstring = 'module=ReportLog&action=ReportLogAjax&file=deleteReportLog';
    urlstring += '&reportlogid='+reportlogid+'&ReportLogType='+reportlogtype;
	RequestAjax(urlstring,function(rest){
		if(reportlogtype == 'month'){
			var yearOpt = ld('#yearOpt').val();
			var monthOpt = ld('#monthOpt').val();
			DelProgressObjs();
			window.location.href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&reporttype=write&yearOpt="+yearOpt+"&monthOpt="+monthOpt;
		}else if(reportlogtype == 'daily'){
			var StartDate = ld('#jscal_field_date').val();
			DelProgressObjs();
			window.location.href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&reporttype=write&StartDate="+StartDate;
		}else if(reportlogtype == 'week'){
			var StartDate = ld('#StartDate').val();
			var EndDate = ld('#EndDate').val();
			DelProgressObjs();
			window.location.href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&reporttype=write&StartDate="+StartDate+"&EndDate="+EndDate;
		}
    });
	//window.open("index.php?module=ContactRecords&parenttab=Parent Accounts&action=DetailView&record="+obj.id);
}

//查看日周月报状态
function viewReportLogSubmit(page_aciton,add_url){
	 var page_addurl='';
	 if(add_url != ''){
		page_addurl=encodeURIComponent(add_url);
	 }
	 window.location.href='index.php?pageto_module=ReportLog&pageto_action='+page_aciton+'&page_addurl='+page_addurl;
}


 