{*<!--
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
 <!--修改编码格式:统一编码：UTF-8-->
-->*}

{*<!-- module header -->*}
{*2020-5-7 为统计图表添加样式*}
{if $senioruserid neq ""}
    <input type="hidden" id="scope_senioruserids" value="{$senioruserid}"/>
{/if}
<script language="javascript" type="text/javascript">
CrmPopup.global_listPopupObj=[];
var Listpagepopupobj=new CrmPopup();
Listpagepopupobj.divid="pagecontent1";
Listpagepopupobj.module="Calendar";
Listpagepopupobj.pagetype="listpage";
Listpagepopupobj.type=ListPagePopup.type;
Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
Listpagepopupobj.url='{$LISTPAGEURL}';

var version_account = '{$VERSION_ACCOUNT}';
//zkt 20230110 BUG0060655日程管理点击进入列表视图后再点击日历视图无法进入相应界面
CrmPopup.global_listPopupObj.push(Listpagepopupobj);
var editviewinfojsonobj='{$FIELDINFOJSON}';
var linkmodulecustom = '{$LINKMODULECUSTOM}';
if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!=''){
	var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
}
var FieldWidthSetting='{$FieldWidthSetting}';
var FieldWidthSettingobj;    
 if(FieldWidthSetting!='')
{
        
    var FieldWidthSettingobj=eval('('+ FieldWidthSetting +')')?eval('('+ FieldWidthSetting +')'):JSON.parse(FieldWidthSetting);
         
}
Listpagepopupobj.fields=fieldinfoobjs;
var tree_enable='{$MODULElISTTREE.enable}';
if(tree_enable == 'yes'){
    structureTreeobj=new structureTree()
    structureTreeobj.setEvent();
    structureTreeobj.treeWidth = '{$MODULElISTTREE.tree_width}';
}
Listpagepopupobj.listresizeobj=new List_ResizeTable(Listpagepopupobj);

Listpagepopupobj.listresizeobj.setReiszeTable_Init('Calendar','');


 function setObjects() 
    {ldelim}
        availListObj=getObj("availList")
        selectedColumnsObj=getObj("selectedColumns")
    {rdelim}

    function addColumn() 
    {ldelim}
    	setObjects();
        for (i=0;i<selectedColumnsObj.length;i++) 
        {ldelim}
            selectedColumnsObj.options[i].selected=false
        {rdelim}

        for (i=0;i<availListObj.length;i++) 
        {ldelim}
            if (availListObj.options[i].selected==true) 
            {ldelim}            	
            	var rowFound=false;
            	var existingObj=null;
                for (j=0;j<selectedColumnsObj.length;j++) 
                {ldelim}
                    if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                    {ldelim}
                        rowFound=true
                        existingObj=selectedColumnsObj.options[j]
                        break
                    {rdelim}
                {rdelim}

                if (rowFound!=true) 
                {ldelim}
                    var newColObj=document.createElement("OPTION")
                    newColObj.value=availListObj.options[i].value
                    if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                    else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                    selectedColumnsObj.appendChild(newColObj)
                    availListObj.options[i].selected=false
                    newColObj.selected=true
                    rowFound=false
                {rdelim} 
                else 
                {ldelim}
                    if(existingObj != null) existingObj.selected=true
                {rdelim}
            {rdelim}
        {rdelim}
    {rdelim}

    function delColumn() 
    {ldelim}
    	setObjects();
        for (i=selectedColumnsObj.options.length;i>0;i--) 
        {ldelim}
            if (selectedColumnsObj.options.selectedIndex>=0)
            selectedColumnsObj.remove(selectedColumnsObj.options.selectedIndex)
        {rdelim}
    {rdelim}
    
    function formSelectColumnString()
    {ldelim}
            var selectedColStr = "";
            setObjects();
            for (i=0;i<selectedColumnsObj.options.length;i++) 
            {ldelim}
                selectedColStr += selectedColumnsObj.options[i].value + ",";
            {rdelim}
            if (selectedColStr == "")
            {ldelim}
                confirm_str = '{'SELECTLEASTONEFIELD'|@getFixedLabel}';
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            	return false;
            {rdelim}
           	var _module = document.mergeDuplicates.module.value;
    		var _action = "FindDuplicateRecords";
    		var url = 'index.php?module='+_module+'&action='+_module+'Ajax&file='+_action+'&selectedColumnsString='+selectedColStr+'&get_rows=yes';
            {literal}
            ldAjax(url,{},function(data){
                if(data.code=='-1')
                {
                     RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
					 DelProgressObjs();
                    return false;
                }
               var popupobj= CrmPopup.load(data.result.title,"","","950",_module,"","","","");
               CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
               
                mergeSelect();
				DelProgressObjs();
            })
            {/literal}
	
        return true;
    {rdelim}
	setObjects();

var fLabels = new Array();
fLabels['bw'] = '{'Interval'|@getFixedLabel}';
fLabels['e'] = '{'EQ'|@getFixedLabel}';
fLabels['n'] = '{'NEQ'|@getFixedLabel}';
fLabels['c'] = '{'IN'|@getFixedLabel}';
fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
fLabels['l'] = '{'LT'|@getFixedLabel}';
fLabels['g'] = '{'GT'|@getFixedLabel}';
fLabels['m'] = '{'LE'|@getFixedLabel}';;
fLabels['h'] = '{'GE'|@getFixedLabel}';
fLabels['b'] = '{'Before'|@getFixedLabel}';
fLabels['a'] = '{'After'|@getFixedLabel}';
fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
//zkt 20220524 52055（https://81mis.com/kfbtest）首页》日程管理》 列表视图》 管理分类   选择字段创建人， 选择条件时无当前用户选项
fLabels['curuser'] = '{'CURUSER'|@getFixedLabel}';
fLabels['includeuser'] = '{'INCULDECURUSER'|@getFixedLabel}';
var tmpstr='{$DATETIMESTR}';
var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
var searchtype_btn = '';
var module="Calendar";
var noneLabel;
</script>

<script language="javascript">
function checkgroup()
{ldelim}

  if(document.change_ownerform_name.user_lead_owner[1].checked)
  {ldelim}
          document.change_ownerform_name.lead_group_owner.style.display = "block";
          document.change_ownerform_name.lead_owner.style.display = "none";
  {rdelim}
  else
  {ldelim}
          document.change_ownerform_name.lead_owner.style.display = "block";
          document.change_ownerform_name.lead_group_owner.style.display = "none";
  {rdelim}    
  
{rdelim}
function alphabetic(module,url,dataid)
{ldelim}
        for(i=1;i<=26;i++)
        {ldelim}
                var data_td_id = 'alpha_'+ eval(i);
                getObj(data_td_id).className = 'searchAlph';

        {rdelim}
        getObj(dataid).className = 'searchAlphselected';
    var divid = 'ListViewContents';
    var urlstring = 'module='+module+'&action='+module+'Ajax&file=ListView&ajax=true&search=true&'+url
    var listview_page=new ListView_Page(module,urlstring,divid);
    listview_page.callback_fun=function()
    {ldelim}
    {rdelim}
    listview_page.page();
{rdelim}

</script>

{*{include file='Buttons_List.tpl'}*}
<div id="searchingUI" style="display:none;text-align:cenger;">
    <img src="{'searching.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SEARCHING}"  title="{$APP.LBL_SEARCHING}">
</div>
<!--切换导航-->
<div class="ld-listview-screen ld-bg-color">
    <div class="ld-listview-screen-content">
        {*hzx 20231215 列表页面页签优化*}
        {include file='ListViewNavBarAndBtn.tpl'}
        {include file='ListViewBtnAndSeach.tpl'}    </div>
</div>
{*<div class="ld-ui-tabs" id="calendartab">
    <ul class="ld-ui-tabs-nav">
        <li><a onclick="CalendarTabClick(0,CrmPopup.getPopupObj('last'))" href="javascript:;">{'CALENDARVIEW'|@getFixedLabel}</a></li>
        <li class="ld-ui-tabs-active"><a onclick="CalendarTabClick(1,CrmPopup.getPopupObj('last'))" href="javascript:;">{'LISTVIEW'|@getFixedLabel}</a></li>
        *}{*0048329*}{*
    </ul>
</div>*}
{*<!-- Contents -->*}
<table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 width=100% align=center>
     <tr>
        {*<td valign="top" width=100% > 0049981: 【产品通用问题】V8.4.5.6（开发部CRM：https://81mis.com/kfbcrm [^]）日程管理无法启用树状结构，启用不生效*}
        {if $MODULElISTTREE.enable eq 'yes'}
            <td valign="top" class="user-left-td">
                {include file="ModuleListTree.tpl"}
                <div class="sidebar-drag"></div>
            </td>
{*            <td class="tip-items-list" data-tip="" data-direction="right" data-type="position">*}
{*                <span class="tree-closeopen tree-close"></span>*}
{*            </td>*}
            <td valign="top">
      	{else}
        <td valign="top" width="100%" >
      	{/if}
      
        <!-- end </div>	-->
        
	    <div id="ListViewContents" style="width:100%;">

            {include file="ListViewEntriesforC.tpl"}
        </div>	
     </td>
   </tr>
</table>

<!--
chang:kara
date:2013-06-09
reason:bug:4094
-->
<div id="changeowner" class="LdPop_box LdPopWidth300px" style="display:none;">
	<div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" /><span class="Name">{'ALLOCATE'|@getFixedLabel}</span>
		<a href="javascript:fninvshnew('changeowner');">
			<img src="themes/softed/tier/icon_close.png" class="Close" />
		</a>
	</div>		
    <div class="Content_div">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="Note">
        		<ul class="LdPop_ul0">
            		<li>{'Transfer_ownership_relationships'|@getFixedLabel}：</li>            
            		<li>
						<form name="change_ownerform_name">
						<input type = "radio" id= "user_checkbox"  style="display:none" name = "user_lead_owner"   checked>
						<select name="lead_owner" id="lead_owner" class="Width150">
    						{$CHANGE_OWNER}
    					</select>
                        </form>
    				</li>   
            	</ul>
            </td>
          </tr>
        </table>
    </div>
    <div class="Bottom">
        <div class="Bottom_div width145">
            <input type="button" value="{'SAVE'|@getFixedLabel}" class="Button_saveGreen width60" onclick="ajaxChangeStatus('owner');"/><span>&nbsp;</span>
            <a onclick="fninvshnew('changeowner');" class="Button_backOrg width60">{'CANCEL'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<!--end--->


<div class="List3Box">
<!--两秒自动消失的提示，单据编号重复的提示-->

</div>
<script>
    var module="Calendar";
{literal}


function ajaxChangeStatus(statusname)
{
    var viewid = document.getElementById("viewname").value;
	var excludedRecords=document.getElementById("excludedRecords").value;
	var idstring = document.getElementById('allselectedboxes').value;

	if(statusname == 'status')
	{
		fninvshnew('changestatus');
		var url='&leadval='+document.getElementById('lead_status').options[document.getElementById('lead_status').options.selectedIndex].value;
		var urlstring ="module=Users&action=updateLeadDBStatus&return_module=Leads"+url+"&viewname="+viewid+"&idlist="+idstring+"&excludedRecords="+excludedRecords;
	}
	else if(statusname == 'owner')
	{

	   if($("user_checkbox").checked)
	   {
		    fninvshnew('changeowner');
		    var url='&owner_id='+document.getElementById('lead_owner').options[document.getElementById('lead_owner').options.selectedIndex].value+'&owner_type=User';
		    {/literal}
		        var urlstring ="module=Users&action=updateLeadDBStatus&return_module={$MODULE}"+url+"&viewname="+viewid+"&idlist="+idstring+"&excludedRecords="+excludedRecords;
		    {literal}
     }
    else
    {
        fninvshnew('changeowner');
		    var url='&owner_id='+document.getElementById('lead_group_owner').options[document.getElementById('lead_group_owner').options.selectedIndex].value+'&owner_type=Group';
	       {/literal}
		        var urlstring ="module=Users&action=updateLeadDBStatus&return_module={$MODULE}"+url+"&viewname="+viewid+"&idlist="+idstring+"&excludedRecords="+excludedRecords;
		    {literal}
    }

	}
    var divid='ListViewContents';
    var popupobj=CrmPopup.getPopupObj("last");
    var listview_page=new ListView_Page("Calendar",urlstring,divid);
    listview_page.callback_fun=function(){

    }
    listview_page.page();

}
//切换页码
// function ldSelectPageNum(obj,pagenum,totalrows){
//      var divobj = ld(obj).parent().parent().parent();
//      divobj.find('#pagenum').val(pagenum);
//      divobj.find('#pagenum_show').html(pagenum+'/'+totalrows+'&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">'+totalrows+'</b>');
//      divobj.find('#pagenum').change();
//  }
//moveMe('searchAcc');
//Edit by LD Can
//date:20130319
//searchshowhide('searchAcc','advSearch');
//mergehide('mergeDup')
getJsScript('include/js/ldcrm.category.js',function(){});
</script>
{/literal}

<div id="SubmitApprove" class="D_pop_box LdPopWidth400px" style="display:none;"></div>
<!--修改负责人-->
<div id="smowneredit" class="D_pop_box LdPopWidth400px" style="display:none;">
<div id="smowneredit_form_div"></div>
</div>

<!-- 批量修改 -->
<div id="massedit" class="D_pop_box LdPopWidth900px" style="z-Index:2147483647;position:absolute;display:none;">
<div id="massedit_form_div" ></div>
</div>
