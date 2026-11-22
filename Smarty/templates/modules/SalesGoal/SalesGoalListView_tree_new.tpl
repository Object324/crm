{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<style type="text/css">
    {literal}
    table tr.TrBj td, table tr.lvtColData td, table tr.lvtColDataBj td {
        width: 150px;
    }

    {/literal}
</style>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/search.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript">
    AjaxJSPage("jquery_orgchart_d_js","include/js/modules/SalesGoal/jquery.orgchart.d.js");
</script>
<link rel="stylesheet" href="{$CSSURL}themes/softed/jquery.orgchart.css" type="text/css"/>
{*{include file='Buttons_List1.tpl'}*}
<div id="resize_content_table_divid" style="overflow:auto">

    {include file='ListViewNavBar.tpl'}
    {*<div class="ld-ui-tabs">
        <ul class="ld-ui-tabs-nav">
            <li class="ld-ui-tabs-active" tabindex='0' onclick="SalesGoalTabClick(0)"><a
                        href="javascript:;">{'TREEDIAGRAM'|@getFixedLabel}</a></li>
            <li tabindex='3' onclick="SalesGoalTabClick(3)"><a href="javascript:;">{'TEMPLATESALESGOALIMG'|@getFixedLabel}</a></li>
            {if $DETAILVIEW eq 1}
                <li tabindex='1' onclick="SalesGoalTabClick(1)"><a
                            href="javascript:;">{'OBJECTVIEW_LOOK'|@getFixedLabel}</a></li>
            {/if}
            <li tabindex='2' onclick="SalesGoalTabClick(2)"><a href="javascript:;">{'OBJECTVIEW_EDIT'|@getFixedLabel}</a></li>

        </ul>
    </div>*}
    <form method="post" onsubmit="return checkfrom();">
        <div class="PromptDiv0" id="dv_salesgoaledit_smownerscope">


            <label>{'TIMESLOT'|@getFixedLabel}:</label>
            <select name="viewrangeone_year" id="viewrangeone_year" class="salesgoaltimeselect btn-radius-system">
                {foreach item=last_year from=$LASTYEAR}
                    <option value="{$last_year}" {if $YEARSTART eq $last_year} selected {/if}>{$last_year}</option>
                {/foreach}
            </select>
            <select name="viewrangeone_month" id="viewrangeone_month" class="salesgoaltimeselect btn-radius-system" style='width:50px;'>
                {foreach key= year_id item=mouth from=$MOUTH_ALL}
                    <option value="{$mouth}" {if $ONEMOUTH eq $mouth} selected{/if}>{$mouth}</option>
                {/foreach}
            </select><label>{'TO'|@getFixedLabel}</label>
            <select name="viewrangetwo_year" id="viewrangetwo_year" class="salesgoaltimeselect btn-radius-system">
                {foreach item=next_year from=$LASTYEAR}
                    <option value="{$next_year}" {if $YEARMEND eq $next_year} selected {/if}>{$next_year}</option>
                {/foreach}
            </select>
            <select name="viewrangetwo_month" id="viewrangetwo_month" class="salesgoaltimeselect btn-radius-system" style='width:50px;margin-right: 20px;'>
                {foreach key=year_id item=mouth from=$MOUTH_ALL}
                    <option value="{$mouth}" {if $SECONDMOUTH eq $mouth} selected {/if}>{$mouth}</option>
                {/foreach}
            </select>
            <label>{'INDICATORSNAME'|@getFixedLabel}:</label>
            <div id="TargetListContent" class="chzn-container chzn-container-single"  style="z-index:100;height: 30px;">
                {include file="modules/SalesGoal/SalesGoalPicklist.tpl"}
            </div>

            <div class="LdShowselect" id="UserSmOwnerSearchScope" style="float:left;margin-left: 15px;{if $default_arr.modulename neq 'Users'}display:none;{/if}">
                {assign var=fldname value='SmOwnerSearchScope'}
                <label>{'VIEWRANGE'|@getFixedLabel}</label>
                <select onchange="SalesSmOwnerSearchScope(this,'{$MODULE}')" id="SmOwnerSearchScope" name="SmOwnerSearchScope" style="display:none">

                    {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                        {foreach key=User_id item=User_name from=$User_value}
                            {foreach key=User_name_key item=User_name_value from=$User_name}

                                {if $User_id eq $SELECTEDSCOPE || $User_id eq 'SmOwner_Search_All'}
                                    {assign var='optText' value=$User_name_key}
                                    <option value="{$User_id}" selected="true">{$User_name_key}</option>
                                {else}
                                    <option value="{$User_id}">{$User_name_key}</option>
                                {/if}

                            {/foreach}
                        {/foreach}
                    {/foreach}
                </select>
                <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_salesgoaledit_smownerscope')" style="z-index:100;">
                    <a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_salesgoaledit_smownerscope')" href="javascript:void(0)" tabindex="-1"
                       name="cmb_a_{$fldname}">
                        <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;position: relative;top: -2px;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','dv_salesgoaledit_smownerscope')" onKeyUp="com_chosen(event,'{$fldname}','dv_salesgoaledit_smownerscope')" value="{$optText}">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;width: 117px; top: 30px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                        <ul class="chzn-results" name="cmb_ul_{$fldname}">
                            {assign var="show" value=0}{assign var="i" value=0}
                            {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                                {foreach key=User_id item=User_name from=$User_value}
                                    {foreach key=User_name_key item=User_name_value from=$User_name}
                                        <li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','dv_salesgoaledit_smownerscope')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_salesgoaledit_smownerscope')">{$User_name_key}</li>
                                        {if $User_id eq 'smowner_search_senior'}
                                            {assign var="show" value=1}
                                        {/if}
                                        {assign var="i" value=$i+1}
                                    {/foreach}
                                {/foreach}
                            {/foreach}

                            <li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
                {if $show eq 1}
                    <a class="icon-range" href="javascript:void(0);" title="{'VIEWRANGE'|@getFixedLabel}"  onclick="SmOwnerScopehightuser()"></a>
                {/if}
            </div>
            <input type="hidden" id='editresult' value="{$EDITRESULT}">
            <input type="hidden" id='actionname' value="{$ACTIONNAME}">
            <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button ld-button-primary marL20" onclick="SalesGoalListClickSearch(ld(this))" />
    </form>
</div>
<input type="hidden" id="isadmin" name="isadmin" value="{$ISADMIN}"/>
<!--中间-->
<div id="salesgoalajax" >
    {$treeHtml}
</div>
<input type="hidden" id="scope_senioruserids" value="{$ALLUSERID}">
<script type="text/javascript">



    ld("#resize_content_table_divid").css("width", getRightWidth());
    ld("#resize_content_table_divid .PrompLeftCenter").css("width", getRightWidth());

    ld("#resize_content_table_divid .PromptDiv1").css("width", getRightWidth());

    var Listpagepopupobj = new CrmPopup();

    Listpagepopupobj.module = 'SalesGoal';
    Listpagepopupobj.divid='pagecontent1';
    Listpagepopupobj.type=ListPagePopup.type;
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
    Listpagepopupobj.pagetype = ListPagePopup.pagetype;//

    setContentHeight("SalesGoal");//计算内容高度

    var a = ld(' #resize_content_table_divid').outerHeight(true);//头部高度
    ld('#container_treediagram').css('height',a-105);
    ld('#container_treediagram').css('width','calc(100% - 10px)');
    ld('#container_treediagram').show();
    ld('#container_treediagram').css('opacity',1);
    ld('#container_treediagram').css('transition-duration','0.8s');
    setTimeout(function(){
        ld('#salesgoaltips2').show();
    },800);
    {literal}
    tooltip('.tip-items-goal', {transition: true, time: 200});
    function SalesGoalListClick(jqueryobj) {
        var tableindex = ld(" .ld-ui-tabs-active").attr('tabindex');
        var searchscope = ld("#SmOwnerSearchScope").val();
        var viewrangeone_year = ld("#viewrangeone_year").val();
        var viewrangeone_month = ld("#viewrangeone_month").val();
        var viewrangetwo_year = ld("#viewrangetwo_year").val();
        var viewrangetwo_month = ld("#viewrangetwo_month").val();
        var module_look = ld("#module_look").val();
        var tmps = {
            "SmOwnerSearchScope": searchscope, 'viewrangeone_year': viewrangeone_year
            , 'viewrangeone_month': viewrangeone_month, 'viewrangetwo_year': viewrangetwo_year
            , 'viewrangetwo_month': viewrangetwo_month, 'module_look': module_look
        };
        var url = "index.php?module=SalesGoal&file=ListView_tree&action=SalesGoalAjax&ajax=yes";
        if (searchscope == 'smowner_search_senior') {
            if(global_var.salesgoal !== undefined && global_var.salesgoal[tableindex] != undefined){
                tmps.senioruserid = global_var.salesgoal[tableindex];
            }else{
                tmps.senioruserid = ld('#scope_senioruserids').val();
            }
        }
        ldAjax(url, tmps, function (data) {
            ld("#salesgoaltree").html(data.result.content);
            DelProgressObjs();
        })


    }

    {/literal}
</script>