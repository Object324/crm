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
<!--中间-->
	<!--修改编码格式:统一编码：UTF-8-->
<div class="D_pop_box LdPopWidth600px">
  <form  name="saveworkcalenderform" >  
    <input type="hidden" id="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" id="fieldidsetting" value="{$FIELDIDSETTING}"/>    
	<div class="D_pop_tit">
        {if $OPERATETYPE eq 'edit'}
           	<strong class="D_ptita">{'EDIT'|@getFixedLabel}&nbsp;{'WORKCALENDER'|@getFixedLabel}</strong>
        {else}
            <strong class="D_ptita">{'NEW'|@getFixedLabel}&nbsp;{'WORKCALENDER'|@getFixedLabel}</strong> 
        {/if}	
		<a href="javascript:fninvshnew('EditWorkingSpace');showPopDiv('listworkcalender');" class="D_ptitc">
			<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
		</a>
	</div>
    <table class="D_pop_bod" width="100%"  border="0" cellspacing="1" cellpadding="0">    
        <tr>           
          <td align="right" style="background-color:#fafafa"><label><font color="red">*</font>{'CALENDERNAME'|@getFixedLabel}</label></td>
          <td colspan="2"><input {if $WORKCALENDERID eq 1} disabled="true"{/if} type="text"  id="workcalender_name" value="{$WORKCALENDER_NAME}" /></td>
        </tr>
    </table>
    <div class="definedworkday">
        <span>{'DEFINEDWORKINGDAYS'|@getFixedLabel}</span>
        <span>{$DEFWORKDAYSHTML}</span>
    </div>
    <div id="workingday">
         {$WORKINGDAY}
    </div>
    <div class="D_pbtn">
		<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveWorkingSpace('{$WORKCALENDERID}','{$OPERATETYPE}')"/><span>&nbsp;</span>
		<input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('EditWorkingSpace');showPopDiv('listworkcalender');"/> 
	</div>
</form>
</div>
<!--中间 end-->


