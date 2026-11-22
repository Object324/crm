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

<form action="index.php" method="post" name="selectmemberform" onsubmit="puyoungJS_DialogBox.block();">
	<input type="hidden" name="action" value="SaveProfileMember">
	<input type="hidden" name="module" value="Settings">
	<input type="hidden" name="profileid" value="{$PROFILEID}">
	<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
	<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
	<input type="hidden" name="selectmember" id="selectmember" value="">
	{assign var=entries value=$CFENTRIES}
	<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
    	<tr>
			<td colspan="2"><b>{'AVAILABLEMEMBER'|@getFixedLabel}</b></td>
			<td colspan="2"><b>{'MEMBERSSELECTED'|@getFixedLabel}</b></td>
		</tr>
    	<tr>
			<td>
				<input class="detailedViewTextBox" type="text" onkeyup="clickSelectMember(this,'AssmablyList')" value="{'PLEASEINPUTYOUWANTTOFINDTHEUSER'|@getFixedLabel}" onblur="return clickOnBlurMember(this)" onfocus="return clickOnFoucusMember(this)" name="allmember" />
			</td>
			<td></td>
			<td>
				<input class="detailedViewTextBox" type="text" onkeyup="clickSelectMember(this,'selectedAssmablyColumns')" value="{'PLEASEINPUTYOUWANTTOFINDTHEUSER'|@getFixedLabel}" onblur="return clickOnBlurMember(this)" onfocus="return clickOnFoucusMember(this)" name="allmember" />
			</td>
			<td></td>
	 	</tr>
	    <tr>
			<td width="200" style="padding-right: 0;">
				<input type="hidden" value="" id="AssmablyColumnsString" name="AssmablyColumnsString">
				<select class="commonMultipleSelect" name="AssmablyList" id="AssmablyList" multiple="" ondblclick="addColumn('AssmablyList','selectedAssmablyColumns')"><!--ondblclick="addColumn();-->
					{foreach key=User_Key item=User_value from=$Merge_SmOwner}
	                    {foreach key=User_id item=User_name from=$User_value}
								<option value="{$User_Key}">{$User_id }</option>
	                    {/foreach}
	                {/foreach}
				</select> 
			   
			</td>
			<td width="50" style="padding: 0;">
				<a class="icon-newhomearr icon-mright" href="javascript:;" onclick="copySelectedOptionsSettingModule('AssmablyList','selectedAssmablyColumns');" title="{'MOVERIGHT'|@getFIxedLabel}"></a>
				<a class="icon-newhomearr icon-mleft" style="margin-top:15px;" href="javascript:;" onclick="copySelectedOptionsSettingModule('selectedAssmablyColumns','AssmablyList');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
			</td>
			<td width="200" style="padding-left: 8px;padding-right: 0px;">
				<input type="hidden" value="" id="selectedAssmablyColumnsString" name="selectedAssmablyColumnsString">
				<select size="11" class="commonMultipleSelect" name="selectedAssmablyColumns" id="selectedAssmablyColumns" multiple="" ondblclick="addColumn('selectedAssmablyColumns','AssmablyList')">
					{foreach key=User_id item=User_name from=$RoleUserArr}
						<option value="{$User_id}"> <ww-open-data type="userName" name="wxopendata" openid="panlulu"></ww-open-data></option>
	                {/foreach}
				</select>
				
			</td>
			<td width="50" style="padding-left: 0;">
				<a class="icon-newhomearr icon-mup" href="javascript:;" onclick="ModuleDetailmoveUp('selectedAssmablyColumns');" title="{'MOVEUP'|@getFIxedLabel}"></a>
				<a class="icon-newhomearr icon-mdown" style="margin-top:15px;" href="javascript:;" onclick="ProductDetailmoveDown('selectedAssmablyColumns');" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
			</td>
	  	</tr>
	</table>
</form>