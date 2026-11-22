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
<script>
{literal}
function dothis(obj)
{
    if(obj.checked){                           
    //alert('shownext'+obj.value);
    //document.getElementById('shownext'+obj.value).style.display = 'block';
    //document.getElementById('shownow'+obj.value).style.display = 'none';
    }
}
function submitFrom(){
	var form = document.getElementById('search_form');
	form.submit();
}
function editfrom(exform)
{
    var alluserid = document.getElementById('alluserid').value;
    var allmouth = document.getElementById('allmouth').value;
	var module_look = document.getElementById('module_look').value;
    var userArr = alluserid.split(',');
    var mouthArr = allmouth.split(',');
    var reg = /^(([0-9]+)|([0-9]+\.[0-9]{1,9}))$/;
    for(var i = 0; i<userArr.length; i++)
    {
        for(var j=0; j<mouthArr.length; j++)
        {
			if(module_look == 'contractamount'){
				if(document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+1) != undefined){
					var contractamount = document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+1).value;
					if((reg.test(contractamount) == false && contractamount!= '')){
						var confirm_str = arrJsPopLabel['CANNOTENTERNUMBERS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						//focus()
						return false;
					}
				}
			}else if(module_look == 'paymentamount'){
				if(document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+2) != undefined){
					var paymentamount = document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+2).value;
					if((reg.test(paymentamount) == false && paymentamount!= '')){
						var confirm_str = arrJsPopLabel['CANNOTENTERNUMBERS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						//focus()
						return false;
					}
				}
			}else if(module_look == 'accountsnumber'){
				if(document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+3) != undefined){
					var accountsnumber = document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+3).value;
					if((reg.test(accountsnumber) == false && accountsnumber!= '')){
						var confirm_str = arrJsPopLabel['CANNOTENTERNUMBERS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						//focus()
						return false;
					}
				}
			}else if(module_look == 'invoiceamount'){
				if(document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+4) != undefined){
					var invoiceamount = document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+4).value;
					if((reg.test(invoiceamount) == false && invoiceamount!= '')){
						var confirm_str = arrJsPopLabel['CANNOTENTERNUMBERS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						//focus()
						return false;
					}
				}
			}else if(module_look == 'outboundorderamount'){
				if(document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+5) != undefined){
					var outboundorderamount = document.getElementById(userArr[i]+'-'+mouthArr[j]+'-'+5).value;
					if((reg.test(outboundorderamount) == false && outboundorderamount!= '')){
						var confirm_str = arrJsPopLabel['CANNOTENTERNUMBERS'];
						RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						//focus()
						return false;
					}
				}
			}
        }
    }
    //return false;
    exform.submit();
}

function checkfrom()
{
    var viewrangeone_year= document.getElementById('viewrangeone_year').value;
    var viewrangeone_month= document.getElementById('viewrangeone_month').value;
    var viewrangetwo_year= document.getElementById('viewrangetwo_year').value;
    var viewrangetwo_month= document.getElementById('viewrangetwo_month').value;
    if(eval(viewrangeone_year) == eval(viewrangetwo_year))
    {
        if(eval(viewrangeone_month) > eval(viewrangetwo_month))
        {
            var confirm_str = arrJsPopLabel['TOBESURESTRARTNEQEND'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
    else
    {
        if(viewrangeone_year > viewrangetwo_year)
        {
            var confirm_str = arrJsPopLabel['THESTARTTIME'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
    }
}
{/literal}
</script>
<!--修改编码格式:统一编码：UTF-8-->
{*{include file='Buttons_List1.tpl'}*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<div class="ld-ui-tabs">
    <ul class="ld-ui-tabs-nav">
        {if $DETAILVIEW eq 1}
            <li><a href="index.php?action=ListView&module=SalesGoal">{'OBJECTVIEW_LOOK'|@getFixedLabel}</a></li>
        {/if}
        <li class="ld-ui-tabs-active"><a href="index.php?action=ListView_edit&module=SalesGoal">{'OBJECTVIEW_EDIT'|@getFixedLabel}</a></li>
    </ul>
</div>
<div id="prompt" class="PromptDiv" style="display:none;">
	<ul>
        <li>1.{'SALESGOALINSTRUCTION1'|@getFixedLabel}</li>
        <li>2.{'SALESGOALINSTRUCTION2'|@getFixedLabel}</li>
        <li>3.{'SALESGOALINSTRUCTION3'|@getFixedLabel} {'SALESGOALINSTRUCTION7'|@getFixedLabel}</li>
    </ul>
</div>

<div class="PromptDiv0" id="dv_salesgoallist_smownerscope">
    <form method="post" onsubmit="return checkfrom();" id="search_form">
    <div style="padding-right:20px;float:left;">
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
                       
        <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','dv_salesgoallist_smownerscope')" style="z-index:100;">
         	<a style="width:117px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','dv_salesgoallist_smownerscope')" href="javascript:void(0)" tabindex="-1"
             name="cmb_a_{$fldname}">
				<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','dv_salesgoallist_smownerscope')" onKeyUp="com_chosen(event,'{$fldname}','dv_salesgoallist_smownerscope')" value="{$optText}">
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
							<li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$User_id}','{$fldname}','dv_salesgoallist_smownerscope')" onmouseover="cmb_limouseover(event,'{$fldname}','dv_salesgoallist_smownerscope')">{$User_name_key}</li>
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
	
    <label>{'TIMESLOT'|@getFixedLabel}:</label>
    <select name="viewrangeone_year" id="viewrangeone_year" class="salesgoaltimeselect btn-radius-system">
        {foreach item=last_year from=$LASTYEAR}
            <option value="{$last_year}" {if $YEARSTART eq $last_year} selected {/if}>{$last_year}</option>
        {/foreach}
    </select>
    <select name="viewrangeone_month" id="viewrangeone_month" class="salesgoaltimeselect btn-radius-system">
        {foreach key= year_id item=mouth from=$MOUTH_ALL}
            <option value="{$mouth}" {if $ONEMOUTH eq $mouth} selected{/if}>{$mouth}</option>
        {/foreach}
    </select><label>{'TO'|@getFixedLabel}</label>
    <select name="viewrangetwo_year" id="viewrangetwo_year" class="salesgoaltimeselect btn-radius-system">
        {foreach item=next_year from=$LASTYEAR}  
            <option value="{$next_year}" {if $YEARMEND eq $next_year} selected {/if}>{$next_year}</option>
        {/foreach}
    </select>
    <select name="viewrangetwo_month" id="viewrangetwo_month" class="salesgoaltimeselect btn-radius-system">
        {foreach key=year_id item=mouth from=$MOUTH_ALL}
            <option value="{$mouth}" {if $SECONDMOUTH eq $mouth} selected {/if}>{$mouth}</option>
        {/foreach}
    </select>
	<label>{'SALESINDEX'|@getFixedLabel}:</label>
    <select name="module_look" id="module_look" class="salesgoaltimeselect btn-radius-system" onchange="submitFrom()">
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
    <!--<input type="submit" value="{'QUERYTO'|@getFixedLabel}" class="OptBtn saveauto" style="margin-right: 10px;"/>-->
    </form>
    <form  name="Export_Records"  method="POST" onsubmit="puyoungJS_DialogBox.block();">
    <input name="editsalesgoal" id="editsalesgoal" onclick="editfrom(this.form)" type="button" value="{'KEEPTHEGOAL'|@getFixedLabel}" {if $ISADMIN neq '1'} disabled style="background:#D4D0C8;" {else} {/if} class="OptBtn saveauto"/>
    <input type="hidden" name="module" value="SalesGoal">
    <input type="hidden" name="action" value="Save">
    <input type="hidden" name="alluserid" id="alluserid" value="{$ALLUSERID}" />
    <input type="hidden" name="allmouth" id="allmouth" value="{$ALLYEARMOUTH}" />
	<input type="hidden" name="module_look" value="{$MODULELOOK}">
    <a class="rfloat" href="javascript:;" onclick="showprompt('prompt');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
</div>
<!--中间-->
<div class="PrompLeftCenter" id="PrompLeftCenter">
	<div class="PrompLeft">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
          <tr>
            <th>{'MONTH'|@getFixedLabel}</th>
          </tr>
          <tr>
            <td>{'LBL_USERS'|@getFixedLabel}</td>
          </tr>
          {foreach key=user_id item=users from=$USERS}
            <tr>
                <td title="{$users}">
                    <!--</a><input type="checkbox" name="bechosed" id="bechosed{$user_id}" value="{$user_id}" {if $user_id|@getInArray:$USERARR eq true} checked="true"{/if} onclick="return dothis(this)"/>-->
                    {$users}
                </td>
            </tr>
          {/foreach}
        </table>
    </div>
    <!--编辑开始-->
    <div id="listcenter" style="display:block;" class="PrompCenter">
		<table width="100%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
          <tr>
            {foreach key = menu_mouth_id item=mouth_id from=$YEARMOUTH}
                <th style="wdith:3%;">
                {$mouth_id}
                </th>
            {/foreach}
          </tr>
          <tr class="TrBj">
            {foreach key = menu_mouth_id item=mouth_id from=$MOUTH}
                {if $MODULELOOK eq 'contractamount'}
					<td>{'CONTRACTAMOUNTS'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'paymentamount'}
					<td>{'THEAMOUNTOFBACK'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'accountsnumber'}
					<td>{'THECUSTOMERNUMER'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'invoiceamount'}
					<td>{'Invoiceamount1'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'outboundorderamount'}
					<td>{'outamount'|@getFixedLabel}</td>
				{/if}
            {/foreach}
          </tr>
          {$SALESGOALINFO}
        </table>
    </div>
    </form>
    <!--编辑区结束-->
    <div class="PrompRight">
		<table width="{$TABLEWIDTHAFTER}%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
          <tr>
            <th colspan="5">{'SUM'|@getFixedLabel}</th>
          </tr>
          <tr class="TrBj">
            {if $MODULELOOK eq 'contractamount'}
				<td>{'CONTRACTAMOUNTS'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'paymentamount'}
				<td>{'THEAMOUNTOFBACK'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'accountsnumber'}
				<td>{'THECUSTOMERNUMER'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'invoiceamount'}
				<td>{'Invoiceamount1'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'outboundorderamount'}
				<td>{'outamount'|@getFixedLabel}</td>
			{/if}
          </tr>
          {$SALESGOALSUM}
        </table>
    </div>
</div>
<script>

ld("#PrompLeftCenter").css("width",getRightWidth());


</script>