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

{if $MODE eq 'edit'}
    <div class="divPopOverflow">
{/if}
<input type="hidden" name='mode'/>
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="action" value="SMSSetting"/>
<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
{if $MODE neq 'edit'}
  <div class="main_grid_top">
      <div class="grid-view-title lfloat overflow-hidden">
          <span class="grid-view-name dinline-block lfloat">
            {'LBL_SMS_SETTINGS'|@getFixedLabel}{if $HelpHtml.SMSSetting neq '' }{$HelpHtml.SMSSetting}{/if}
          </span>
      </div>
      <div class="grid_tool">
          <div class="displayflex">
                <a href="javascript:;" class="ld-button ld-button-primary" onclick="editSmsSetting()" title="{'EDIT'|@getFixedLabel}">{'EDIT'|@getFixedLabel}</a>
                <a href="javascript:;" class="ld-button" onclick="CancelSmsSetting()" title="{'LOGOUTS'|@getFixedLabel}">{'LOGOUTS'|@getFixedLabel}</a>
          </div>
      </div>
  </div>
{/if}
{if $MODE neq 'edit'}
	<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        <table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable">
            <tr>
              <th colspan="2">{'SMSPlatform'|@getFixedLabel}</th>
            </tr>

            <tr id="setting_0" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td width="20%"><span title="{'SMSPlatform'|@getFixedLabel}">{'SMSPlatform'|@getFixedLabel}</span></td>
              <td width="80%">{if $PLATFORM eq 'aliyun'}{'AliCloud'|@getFixedLabel}{else}{'TencentCloud'|@getFixedLabel}{/if} </td>
            </tr>

          </table>
        </div>
        <div class="cont_wrap clear_float">
          <table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable">
            <tr>
              <th colspan="2">{'LBL_SMS_SETTINGS'|@getFixedLabel}</th>
            </tr>
            <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">

              <td width="20%"><span>{if $PLATFORM eq 'aliyun'}AccessKey ID{else}SDK AppID{/if}</span></td>
              <td width="80%"><span title="{$USERNAME}">{$USERNAME}</span> </td>
            </tr>
            <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">

              <td><span>{if $PLATFORM eq 'aliyun'}AccessKey Secret{else}App Key{/if}</span> </td>
              <td>{if $PASSWORD neq ''}<span title="******">******</span>{/if}</td>
            </tr>
            <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td><span title="{'SMS_Signature'|@getFixedLabel}">{'SMS_Signature'|@getFixedLabel}</span> </td>
              <td><span title="{$AUTOGRAPH}">{$AUTOGRAPH}</span></td>
            </tr>
            <tr id="setting_4" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td><span title="{'EVALUATESETTING04'|@getFixedLabel}">{'EVALUATESETTING04'|@getFixedLabel}</span> </td>
              <td><span title="{$SERVTEL}">{$SERVTEL}</span></td>
            </tr>
          </table>
          <div class="listRloesHelp">
            <font color="red">{'TIP'|@getFixedLabel}:</font>
              <ul>
              {if $PLATFORM eq 'aliyun'}
              <li>1、{'sdkappidandappkeyaliyun'|@getFixedLabel}</li>
              <li>2、{'smsmustbeapprovedbyaliyun'|@getFixedLabel}</li>
              {else}
              <li>{'sdkappidandappkey'|@getFixedLabel}</li>
              <li>{'smssignaturemustbesigned'|@getFixedLabel}</li>
              <li>{'smsmustbeapprovedbytencent'|@getFixedLabel}</li>
              {/if}
              </ul>
          </div>
        </div>
    </div>
  </div>
{else}

    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'SMSPlatform'|@getFixedLabel}</div>
                </div>
            </th>
        </tr>
	    <tr>
		  <td class="ld-form-item-label"><font color="red">*</font>{'SMSPlatform'|@getFixedLabel}</td>
		  <td class="ld-form-item-content">
			  <select name="sms_platform" class="ld-select-inner" onchange="SmsSetting.getInstance().selectSmsType(this)">
                    <option value="tencent">{'TencentCloud'|@getFixedLabel}</option>
                    <option value="aliyun" {if $PLATFORM eq 'aliyun'}selected{/if}>{'AliCloud'|@getFixedLabel}</option>
                </select>
		  </td>
		</tr>
	</table>


	<table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <th colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'LBL_SMS_SETTINGS'|@getFixedLabel}</div>
                </div>
            </th>
        </tr>
		<tr>

		  <td class="ld-form-item-label""><font color="red">*</font><span name="sms_account_name">{if $PLATFORM eq 'aliyun'}AccessKey ID{else}SDK AppID{/if}</span></td>
		  <td class="ld-form-item-content">
				<input class="ld-input-inner" type="text" name="sms_username" value="{$USERNAME}">
			  {if $ERROR_MSG neq ''}
				  <font class="warning"><span title="{$ERROR_MSG}">{$ERROR_MSG}</span></font>
				{/if}
		  </td>
		</tr>
		<tr>

		  <td class="ld-form-item-label"><font color="red">*</font><span name="sms_account_pwd">{if $PLATFORM eq 'aliyun'}AccessKey Secret{else}App Key{/if}</span></td>
		  <td class="ld-form-item-content">
		    <input class="ld-input-inner" type="password" value="{$PASSWORD}" name="sms_password"/>
		  </td>
		</tr>
		<tr>
		  <td class="ld-form-item-label">
              <font color="red">*</font>
              <span title="{'SMS_Signature'|@getFixedLabel}">{'SMS_Signature'|@getFixedLabel}</span>
          </td>
		  <td class="ld-form-item-content">
				<input class="ld-input-inner" type="text" name="sms_autograph" value="{$AUTOGRAPH}" tag="{'SMS_Signature'|@getFixedLabel}">
		  </td>
		</tr>
		<tr>
			<td class="ld-form-item-label"><span title="{'EVALUATESETTING04'|@getFixedLabel}">{'EVALUATESETTING04'|@getFixedLabel}</span> </td>
			<td class="ld-form-item-content">
				<input class="ld-input-inner" type="text" name="service_tel" value="{$SERVTEL}" tag="{'EVALUATESETTING04'|@getFixedLabel}">
			</td>
		</tr>
	</table>
{/if}
{if $MODE eq 'edit'}
      </div>
{/if}