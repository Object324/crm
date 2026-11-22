{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/OrgSharingDetailView.js?v={$GLOBALMINVERSION}"></script>
{literal}
<style>
DIV.fixedLay{
	border:3px solid #CCCCCC;
	background-color:#FFFFFF;
	width:500px;
	position:fixed;
	left:250px;
	top:98px;
	display:block;
}
</style>
{/literal}
{literal}
<!--[if lte IE 6]>
<STYLE type=text/css>
DIV.fixedLay {
	POSITION: absolute;
}
</STYLE>
<![endif]-->

{/literal}
<form action="index.php" method="post" name="new" id="orgSharingform" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Users">
<input type="hidden" name="action" value="OrgSharingEditView">
<input type="hidden" name="parenttab" value="Settings">
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_SHARING_ACCESS'|@getFixedLabel}{if $HelpHtml.OrgSharingDetailView neq '' }{$HelpHtml.OrgSharingDetailView}{/if}<font>（{'MANAGEMODULESHARE'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" onclick="OrgSharingDetailView.edit()" class="ld-button ld-button-primary" title="{'MODIFYRULE'|@getFixedLabel}">{'MODIFYRULE'|@getFixedLabel}</a>
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
            <div class="ControlDiv3">
                <div class="ControlDiv3_title">{'SHARERULE_EXPLAIN'|@getFixedLabel}</div>
                <div class="ControlDiv3_content">{'SHARERULE_ONE'|@getFixedLabel}</div>
                <div class="ControlDiv3_content">{'SHARERULE_TWO'|@getFixedLabel}</div>
                <div class="ControlDiv3_content">{'SHARERULE_THREE'|@getFixedLabel}</div>
            </div>
            <div id="globaldiv">
                <table cellspacing="0" cellpadding="0" class="settingTable fir-center" width="100%">
                    <tr style="position: sticky; top:0px;z-index:1;">
                        <th>#</th>
                        <th title="{'MODULE'|@getFixedLabel}">{'MODULE'|@getFixedLabel}</th>
                        <th title="{'LBL_SHARING_ACCESS'|@getFixedLabel}">{'LBL_SHARING_ACCESS'|@getFixedLabel}</th>
                        <th width="200px" title="{'CUSTOMRULES'|@getFixedLabel}">{'CUSTOMRULES'|@getFixedLabel}</th>
                    </tr>
                    {assign var="i" value=0}
                    {assign var="modulenamenum" value='1'}
                    {foreach item=module name=modulenum from=$DEFAULT_SHARING}
                        {assign var="MODULELABEL" value=$module.0}
                        {if $module.0|@getTranslatedString:$module.0 neq ''}
                            {assign var="MODULELABEL" value=$module.0|@getTranslatedString:$module.0}
                        {/if}
                        {assign var="j" value=$i++}
                        {if $j mod 2 eq '0'}
                            <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                        {else}
                            <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                        {/if}
                                <td>{$modulenamenum}</td >
                                <td><span title="{$MODULELABEL}">{$MODULELABEL}</span></td>
                                <td>
                                {if $module.1 neq 'Private' && $module.1 neq 'Hide Details'}
                                    <img src="{'public.png'|@lingdang_imageurl:$THEME}" align="absmiddle" style="margin-bottom: 3px;">
                                {else}
                                    <img src="{'private.png'|@lingdang_imageurl:$THEME}" align="absmiddle" style="margin-bottom: 3px;">
                                {/if}
                                    <span title="{$module.1}">{$module.1}</span>
                                </td>
                                <!-- <td width="50%" nowrap><span title="{$module.2}">{$module.2}</span></td> -->
                                <td><b name="showCustomrules_btn" style="cursor: pointer;margin-left: 10px;" module='{$module.3}' onclick="OrgSharingDetailView.showCustomrules(this)" stauts="hide"  data-tip="{'EXPANSION'|@getFixedLabel}" data-direction='top' data-type='position' class='ld-category-icon ld-category-expansion sort-tip-items'></b></td>
                            </tr>
                        {assign var="modulenamenum" value=$modulenamenum+1}
                    {/foreach}
                </table>
            </div>
        </div>
    </div>
</div>
</form>

<div id="tempdiv" class="D_pop_box LdPopWidth400px" style="display:none;position:absolute;width:400px;"></div>

<!-- For Disabling Window -->
<!--<div id="confId"  class='D_pop_box LdPopWidth400px' style="display: none; z-index: 9999; position: fixed; left: 50%; top: 50%; margin-top: -60px; margin-left: -152px;">-->
<div id="confId"  class='D_pop_box LdPopWidth400px' style="display: none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'LBL_SHARING_ACCESS'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('confId');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    <table class="D_pop_bod" border="0" cellpadding="1" cellspacing="1">
        <tr>
        	<td>
            	{'AYSYWTRSR'|@getFixedLabel}
            </td>
        </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'YES'|@getFixedLabel}" onclick="return disableStyle('confId');"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'NO'|@getFixedLabel}" onclick="fninvshnew('confId');"/>
        <!--<a class="D_pbtncancel_a" onclick="hideOptions('changeLayoutDiv');puyoungJS_DialogBox.unblock();" >{'CANCEL'|@getFixedLabel}</a>-->
    </div>

</div>

<div id="divId" class="veil_new" style="position:absolute;width:100%;display:none;top:0px;left:0px;">
<table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">
<tbody><tr>
		<td class="big" align="center">
		    <img src="themes/images/plsWaitAnimated.gif"/>
		</td>
	</tr>
</tbody>
</table>
</div>


<script>
function callEditDiv(obj,modulename,mode,id)
{ldelim}
        $("status").style.display="inline";
        new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                        method: 'post',
                        postBody: 'module=Settings&action=SettingsAjax&orgajax=true&mode='+mode+'&sharing_module='+modulename+'&shareid='+id,
                        onComplete: function(response) {ldelim}
                                $("status").style.display="none";
                                $("tempdiv").innerHTML=response.responseText;
				                fnvshobj(obj,"tempdiv");
                            puyoungJS_DialogBox.block();
                                //Drag.init(document.getElementById("createSharingRuleHeading"),document.getElementById("tempdiv"));
                                if(mode == 'edit')
                                {ldelim}
                                        setTimeout("",10000);
                                        var related = $('rel_module_lists').value;
                                        fnwriteRules(modulename,related);

                                {rdelim}
                        {rdelim}
                {rdelim}
        );
{rdelim}

function fnwriteRules(module,related)
{ldelim}
		var modulelists = new Array();
		modulelists = related.split('###');
		var relatedstring ='';
		var relatedtag;
		var relatedselect;
		var modulename;
		for(i=0;i < modulelists.length-1;i++)
		{ldelim}
			modulename = modulelists[i]+"_accessopt";
			relatedtag = document.getElementById(modulename);
			relatedselect = relatedtag.options[relatedtag.selectedIndex].text;
			relatedstring += modulelists[i]+':'+relatedselect+' ';
		{rdelim}
		var tagName = document.getElementById(module+"_share");
		var tagName2 = document.getElementById(module+"_access");
		var tagName3 = document.getElementById('share_memberType');
		var soucre =  document.getElementById("rules");
		var soucre1 =  document.getElementById("relrules");
		var select1 = tagName.options[tagName.selectedIndex].text;
		var select2 = tagName2.options[tagName2.selectedIndex].text;
		var select3 = tagName3.options[tagName3.selectedIndex].text;

		if(module == '{"Accounts"|@getTranstab}')
		{ldelim}
			module = '{"Accounts"|@getTranstab} {'AND'|@getFixedLabel} {"Contacts"|@getTranstab}';	//bylingdang
		{rdelim}
/*
edit by LDＣａｎ
ｄａｔｅ：20130307
reason:0003330: 控制面板 共享规则里面新增一个规则之后，点击 编辑，弹出的界面共享规则说明中Accounts、ContactRecords等信息没有翻译
*/
		//soucre.innerHTML = module +" {$APP.LBL_LIST_OF} <b>\"" + select1 + "\"</b> {$CMOD.LBL_CAN_BE_ACCESSED} <b>\"" +select2 + "\"</b> {$CMOD.LBL_IN_PERMISSION} "+select3;
	//	soucre1.innerHTML = "<b>{$CMOD.LBL_RELATED_MODULE_RIGHTS}</b> " + relatedstring;
{rdelim}

        /*
        *更新操作
        *edit:diony
        *time:2013-11-26
        *reson:BUG编号5812，同时在对应zh_cn.lang.php中增加ARE_YOU_SURE_Delete中文描述
        */
		function confirmdelete(url)
		{ldelim}
			if(confirm(arrJsPopLabel['SUREWANTDELETE']))
			{ldelim}
				document.location.href=url;
			{rdelim}
		{rdelim}

	function disableStyle(id)
	{ldelim}
			$('orgSharingform').action.value = 'RecalculateSharingRules';
			$('orgSharingform').submit();
 			$(id).style.display = 'none';

			if(browser_ie && (gBrowserAgent.indexOf("msie 7.")!=-1))//for IE 7
                        {ldelim}
                                document.body.removeChild($('freeze'));
                        {rdelim}else if(browser_ie)
                        {ldelim}
                             var oDivfreeze = $('divId');
                             oDivfreeze.style.height = document.documentElement['clientHeight'] + 'px';

                        {rdelim}
                        $('divId').style.display = 'block';
	{rdelim}

	function freezeBackground()
	{ldelim}
        /*
	    var oFreezeLayer = document.createElement("DIV");
	    oFreezeLayer.id = "freeze";
	    oFreezeLayer.className = "veil";

	     if (browser_ie) oFreezeLayer.style.height = (document.body.offsetHeight + (document.body.scrollHeight - document.body.offsetHeight)) + "px";
	     else if (browser_nn4 || browser_nn6) oFreezeLayer.style.height = document.body.offsetHeight + "px";
        puyoungJS_DialogBox.block();
	    oFreezeLayer.style.width = "100%";
	    document.body.appendChild(oFreezeLayer);
	    document.getElementById('confId').style.display = 'block';
	    hideSelect();
        */
        fnvshobj(this,'confId');
	{rdelim}

    {literal}
    tooltip('.sort-tip-items', {transition: true, time: 200});
    {/literal}


</script>