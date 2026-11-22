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
    table tr.TrBj td, table tr.lvtColData td, table tr.lvtColDataBj td {width:150px;}
  {/literal}
</style>
{*{include file='Buttons_List1.tpl'}*}
<div  id="resize_content_table_divid" style="overflow:auto">



    <div class="ld-ui-tabs">
        <ul class="ld-ui-tabs-nav">
            <li tabindex='0' onclick="SalesGoalTabClick(0)"><a href="javascript:;">{'TREEDIAGRAM'|@getFixedLabel}</a></li>
            {if $DETAILVIEW eq 1}
                <li  class="ld-ui-tabs-active" tabindex='1' onclick="SalesGoalTabClick(1)"><a href="javascript:;">{'OBJECTVIEW_LOOK'|@getFixedLabel}</a></li>
            {/if}
            <li tabindex='2' onclick="SalesGoalTabClick(2)"><a href="javascript:;">{'OBJECTVIEW_EDIT'|@getFixedLabel}</a></li>
            <li tabindex='3' onclick="SalesGoalTabClick(3)"><a href="javascript:;">{'TEMPLATESALESGOALIMG'|@getFixedLabel}</a></li>
        </ul>
    </div>
    <div id="prompt" class="PromptDiv" style="display:none;">
    	<ul>
            <li>1.{'SALESGOALINSTRUCTION4'|@getFixedLabel}</li>
            <li>2.{'SALESGOALINSTRUCTION5'|@getFixedLabel}</li>
            <li>3.{'SALESGOALINSTRUCTION6'|@getFixedLabel} {'SALESGOALINSTRUCTION8'|@getFixedLabel}</li>
        </ul>
    </div>
    <form method="post" onsubmit="return checkfrom();">
    <div class="PromptDiv0" id="dv_salesgoal_smownerscope" name="dv_salesgoal_smownerscope">
        <div class="LdShowselect"  style="padding-right:20px;float:left;">
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
                                    
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_salesgoal_smownerscope')" style="z-index:100;">
             	<a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_salesgoal_smownerscope')" href="javascript:void(0)" tabindex="-1"
                 name="cmb_a_{$fldname}">
                    <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','dv_salesgoal_smownerscope')" onKeyUp="com_chosen(event,'{$fldname}','dv_salesgoal_smownerscope')" value="{$optText}">
                    <div>
                        <b></b>
                    </div>
        	    </a>
        	    <div style=" left:-9000px;width: 117px; top: 27px;" class="chzn-drop" name='dv_drop_{$fldname}' >
        			 <ul class="chzn-results" id="cmb_ul_{$fldname}">
        				{assign var="show" value=0}
						 {assign var="i" value=0} 
                	   {foreach key=User_Key item=User_value from=$Merge_SmOwner}
                        {foreach key=User_id item=User_name from=$User_value}
                            {foreach key=User_name_key item=User_name_value from=$User_name}
     	                          <li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','dv_salesgoal_smownerscope')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_salesgoal_smownerscope')">{$User_name_key}</li>
								   {assign var="i" value=$i+1} 
    							   {if $User_id eq 'smowner_search_senior'}
    									{assign var="show" value=1}
    								{/if}	
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
                <option value="{$next_year}" 
                    {if $YEAREND eq $next_year} selected  {/if}>{$next_year}
                </option>
            {/foreach}
        </select>
        <select name="viewrangetwo_month" id="viewrangetwo_month" class="salesgoaltimeselect btn-radius-system" style='width:50px;margin-right: 20px;'>
            {foreach key=year_id item=mouth from=$MOUTH_ALL}
                <option value="{$mouth}" {if $SECONDMOUTH eq $mouth} selected {/if}>{$mouth}</option>
            {/foreach}
        </select>
        <label>{'SALESINDEX'|@getFixedLabel}:</label>
        <select name="module_look" id="module_look" class="salesgoaltimeselect btn-radius-system">
            <option value="paymentamount" {if $MODULELOOK eq 'paymentamount'} selected {/if}>{'THEAMOUNTOFBACK'|@getFixedLabel}</option>
            <option value="contractamount" {if $MODULELOOK eq 'contractamount'} selected {/if} >{'CONTRACTAMOUNTS'|@getFixedLabel}</option>
            <option value="accountsnumber" {if $MODULELOOK eq 'accountsnumber'} selected {/if}>{'THECUSTOMERNUMER'|@getFixedLabel}</option>
    		{if $INVOICESTATUS eq 'yes'}
    			<option value="invoiceamount" {if $MODULELOOK eq 'invoiceamount'} selected {/if}>{'Invoiceamount1'|@getFixedLabel}</option>
    		{/if}
    		{if $OUTBOUNDORDERSTATUS eq 'yes'}
    			<option value="outboundorderamount" {if $MODULELOOK eq 'outboundorderamount'} selected {/if}>{'outamount'|@getFixedLabel}</option>
    		{/if}
            {*                zxm 2022-0317 应收单 应收额目标  上海庆科*}
            {if $accountinfo eq 'sh_qingke'}
                <option value="receivableamount" {if $MODULELOOK eq 'receivableamount'} selected {/if}>{'receivableamount'|@getFixedLabel}</option>
            {/if}
        </select>
        <input type="hidden" id='editresult' value="{$EDITRESULT}">
        <input type="hidden" id='actionname' value="{$ACTIONNAME}">
        <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="E_pbtnok" onclick="SalesGoalListClick(ld(this))" style="margin-left:20px;" />
        </form>
        <a class="rfloat" href="javascript:;" onclick="showprompt('prompt');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
    </div>
  <div id="salesgoalajax">
  
  
            {include file="SalesGoalListViewAjax.tpl"}
  
  </div>

</div>
<input type="hidden" id="scope_senioruserids" value="{$ALLUSERID}">
<script type="text/javascript">

ld("#resize_content_table_divid").css("width",getRightWidth()-30);
ld("#resize_content_table_divid .PrompLeftCenter").css("width",getRightWidth()-30);

ld("#resize_content_table_divid .PromptDiv1").css("width",getRightWidth()-30);
setContentHeight("SalesGoal");//计算内容高度 
 var Listpagepopupobj=new CrmPopup();

Listpagepopupobj.module='SalesGoal';
CrmPopup.global_listPopupObj.push(Listpagepopupobj);
Listpagepopupobj.pagetype=ListPagePopup.pagetype;//

    {literal}
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
    var url = "index.php?module=SalesGoal&file=ListView&action=SalesGoalAjax&ajax=yes";
    if (searchscope == 'smowner_search_senior') {
        if (global_var.salesgoal !== undefined && global_var.salesgoal[tableindex] != undefined) {
            tmps.senioruserid = global_var.salesgoal[tableindex];
        } else {
            tmps.senioruserid = ld('#scope_senioruserids').val();
        }
    }
        ldAjax(url,tmps,function(data){
            ld("#salesgoalajax").html(data.result.content);
            DelProgressObjs();
        })
        
        
    }
        function SalesGoalTabClick(tabindex){
            var file ='';
            switch(tabindex){
                case 0:
                    file ='ListView_tree';
                    break;
                case 1:
                    file ='ListView';
                    break;
                case 2:
                    file ='ListView_edit';
                    break;
                case 3:
                    file ='ListView_chart';
                    break;
                default:
                    return false;
                    break;
            }
            ld.ajax({
                url:"index.php?module=SalesGoal&file="+file+"&action=SalesGoalAjax",
                type:"post",
                success:function(data)
                {
                    ChangeWebUrl("index.php?pageto_module=SalesGoal&pageto_action="+file);
                    
                    listcontentobj.html(data);
                    if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                      
                            //通讯录
                            cls_wxOpenDataobj.bindAllOpenData();
                        
                }
                
            })
        }
    {/literal}
</script>
<script>
    {literal}
        //加载tip 20200629 diony
        tooltip('.tip-items-goal', {transition: true, time: 200});
    {/literal}
</script>