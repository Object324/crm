{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
*}<!--修改编码格式:统一编码：UTF-8-->
<table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
    	<th colspan="2">
    		{$SELMODULE|@getTranstab} {'MODULENUM'|@getFixedLabel}
    	</th>
    </tr>
    <!--允许手动编码-->
    <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
    	<td>{'ALLOWTOMODIFY'|@getFixedLabel} </td>
        <td>
            <input id="isallow" class="second_switch" type="checkbox" value="{$isallow}" name="isallow" {if $isallow eq 1} checked="true" {/if} {if $SELMODULE eq 'WorkReportList'} disabled {/if}onclick="dataProfileChange(this)"/>
    	</td>
    </tr>
    <!---
    *更新操作
    *负责人:lmx
    *日期：20140310
    *说明：系统编号定制改进，使用用户账号
    -->
    <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
    	<td width="20%">{'USEUSERACCOUNT'|@getFixedLabel} </td>
        <td width="80%">
            <input id="UseUserAccounts" class="second_switch" value="{$USEUSERACCOUNT}"  type="checkbox" name="UseUserAccounts" {if $USEUSERACCOUNT eq '1'} checked="true" {/if} onclick="dataProfileChange(this)"/>
        {*<select id="UseUserAccount" name="UseUserAccount" class="small" style="width:30%">
           <option value="0" {if $USEUSERACCOUNT neq'1'} selected="selected" {/if}>--{'DONOTUSE'|@getFixedLabel}--</option>
           <option value="1" {if $USEUSERACCOUNT eq'1'} selected="selected" {/if}>--{'USE'|@getFixedLabel}--</option>
        </select>*}
    	</td>
    </tr>
    <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
    	<td>{'USEPREFIX'|@getFixedLabel} </td>
        <td>
        <div style="float: left;">
            <select id="prefixtype" name="prefixtype" class="ld-select-inner width150" onchange="controllprefixtype(this.form)">
                <option value="0" {if $prefixtype eq '0' || ($state eq "" && $bill_city eq "" )} selected="selected" {/if}>{'FIXEDCHARATERSTR'|@getFixedLabel}</option>
                {if $SELMODULE eq 'Accounts' || $SELMODULE eq 'Potentials' || $SELMODULE eq 'Vendors'}
                    {if $state neq ""}
                        <option value="1" {if $prefixtype eq '1'} selected="selected" {/if}>{if $languageType eq 'zh'}{$state}{'THEFIRSTLETTEROFSTATE'|@getFixedLabel}{else}{'THEFIRSTLETTEROFSTATE'|@getFixedLabel}{$state} {/if}</option>
                    {/if}
                    {if $bill_city neq ""}
                         <option value="2" {if $prefixtype eq '2'} selected="selected" {/if}>{if $languageType eq 'zh'}{$bill_city}{'THEFIRSTLETTEROFSTATE'|@getFixedLabel}{else}{'THEFIRSTLETTEROFSTATE'|@getFixedLabel}{$bill_city} {/if}</option>
                    {/if}
                {/if}
            </select>
        </div>
        {if $SELMODULE neq 'Accounts' || $SELMODULE neq 'Potentials' || $SELMODULE neq 'Vendors'}
            <div style="float: left;padding-left: 10px;">
                <input type="text" id="recprefix" name="recprefix" class="ld-input-inner width150" style="display:{if $prefixtype neq 0&&($state neq ""||$bill_city neq "" )}none{/if}" value="{$MODNUM_PREFIX}" />
            </div>
        {/if}
        </td>
    </tr>
    <!--
    更新操作
    负责人：karl
    日期：2013.12.17
    说明：系统编号定制改进，增加使用日期
    -->
    <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        <td>{'USEDATE'|@getFixedLabel} </td>
        <td>
        <select id="selectdatetype" name="datetype" class="ld-select-inner width150" onchange="Change_CustomMod(this)">
        {$CUR_DATETYPE}
        </select>
        </td>
    </tr>
	
	<tr id="tr_reset" class="lvtColData" {if $DATETYPE eq 'none' || $DATETYPE eq ''}style="display:none"{/if} onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        <td>{'Theserialnumberisautomaticallyreseteveryday'|@getFixedLabel}</td>
        <td>
			<input id="reset_value" class="second_switch" class="Bornone" type="checkbox" value="{$RESETVALUE}" name="reset_value" {if $RESETVALUE eq 'yes'}checked{/if} onclick="click_resetvalue(this)">
        </td>
    </tr>

	<tr id="tr_complement" class="lvtColDataBj" {if $DATETYPE eq 'none' || $DATETYPE eq ''}style="display:none"{/if} onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        <td>{'Erialnumberautocomplementnumber'|@getFixedLabel} </td>
        <td>
			<select id="complement" name="datetype" class="ld-select-inner width150">
				<option value="0" {if $COMPLEMENT eq 0}selected{/if}>{'Nofilling'|@getFixedLabel}</option>
				<option value="2" {if $COMPLEMENT eq 2}selected{/if}>2</option>
				<option value="3" {if $COMPLEMENT eq 3}selected{/if}>3</option>
				<option value="4" {if $COMPLEMENT eq 4}selected{/if}>4</option>
				<option value="5" {if $COMPLEMENT eq 5}selected{/if}>5</option>
				<option value="6" {if $COMPLEMENT eq 6}selected{/if}>6</option>
				<option value="7" {if $COMPLEMENT eq 7}selected{/if}>7</option>
				<option value="8" {if $COMPLEMENT eq 8}selected{/if}>8</option>
				<option value="9" {if $COMPLEMENT eq 9}selected{/if}>9</option>
				<option value="10" {if $COMPLEMENT eq 10}selected{/if}>10</option>
			</select>
        </td>
    </tr>
    <!--end-->
    <tr id="setting_7" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        <td><font color='red'>*</font>{'CURRENTCODE'|@getFixedLabel} </td>
    	<td>
    	<input type="text" name="recnumber" id="recnumber" class="ld-input-inner width150" value="{$MODNUM}"  />
    	</td>
    </tr>
    <tr id="setting_8" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" style="display:none;">
    	<td colspan="2" align="center">
    		<input type="button" name="Button" class="saveauto b_radius3" value="{'SAVE'|@getFixedLabel}" onclick="updateModEntityNoSetting(this, this.form);" />
    		<input type="button" name="Button" class="cancelauto b_radius3" style="margin-left:10px; display:none" value="{'CANCEL'|@getFixedLabel}" onclick="location.href='index.php?module=Settings&action=index&parenttab=Settings'" />
    	</td>
    </tr>
</table>