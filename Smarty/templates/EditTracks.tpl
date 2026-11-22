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
<div class="divPopOverflow">
  <form  name="savetrackpostionform" >
      <input type="hidden" id="trackpostion_id" value="{$TRACKPOSTIONID}"/>
      <input type="hidden" id="operatetype" value="{$OPERATETYPE}"/>
      <table class="ld-public-content-small" width="100%"  border="0" cellspacing="1" cellpadding="0">
          <tr>
              <td colspan="2" class="ld-form-item-label">
                  <div class="ld-pop-contnet-title-items">
                      <div class="ld-pop-contnet-title-item">
                          {'BASICINFORMATION'|@getFixedLabel}
                      </div>
                  </div>
              </td>
          </tr>
          <tr class="ld-form-item">
              <td class="ld-form-item-label"><label><font color="red">*</font>{'TRACKGROUPNAME'|@getFixedLabel}</label></td>
              <td class="ld-form-item-content"><input type="text" class="ld-input-inner"   id="trackpostion" value="{$TRACKPOSTIONNAME}" /></td>
          </tr>
          <tr class="ld-form-item">
              <td colspan="2" class="ld-form-item-label">
                      <div class="ld-pop-contnet-title-items">
                          <div class="ld-pop-contnet-title-item">
                              {'POSTIONTIME'|@getFixedLabel}
                          </div>
                      </div>

              </td>
          </tr>
          <tr class="ld-form-item">
              <td class="ld-form-item-label"><label><font color="red">*</font>{'STARTTIME'|@getFixedLabel}</label></td>
              <td class="ld-form-item-content">
                  <input id="starttime" class="Wdate ld-input-inner" style="width: 50%;" type="text" size="15" maxlength="25" onclick="WdatePicker({ldelim}startDate:'%H:%M',dateFmt:' HH:mm',alwaysUseStartDate:true{rdelim})" value="{$STARTTIME}"/>
                  &nbsp;&nbsp;&nbsp;<span >{'STARTTIMEPERDAY'|@getFixedLabel}</span>
              </td>

          </tr>
          <tr class="ld-form-item">
              <td class="ld-form-item-label"><label><font color="red">*</font>{'EndTime'|@getFixedLabel}</label></td>
              <td class="ld-form-item-content">
                  <input id="stoptime" class="Wdate ld-input-inner" style="width: 50%;" type="text" value="{$STOPTIME}" size="15" maxlength="25" onclick="WdatePicker({ldelim}startDate:'%H:%M',dateFmt:' HH:mm',alwaysUseStartDate:true{rdelim})"/>
                  &nbsp;&nbsp;&nbsp;<span>{'ENDTIMEPERDAY'|@getFixedLabel}</span>
              </td>
          </tr>
          <tr class="ld-form-item">
              <td class="ld-form-item-label">{'TRACKPERIOD'|getFixedlabel}</td>
              <td class="ld-form-item-content">
                  <select name="cycle">
                      <option value="workday" {if $cycle eq 'workday' } selected{/if}>{'WorkdDay'|@getFixedlabel}</option>
                      <option value="nolimit" {if $cycle eq 'nolimit' } selected{/if}>{'NOLIMITS'|@getFixedLabel}</option>
                  </select>
              </td>
          </tr>
          <tr class="ld-form-item">
              <td class="ld-form-item-label">{'LocationFrequency'|@getFixedLabel}</td>
              <td class="ld-form-item-content">
                  <select name="frequency">
                      <option value="1" {if $frequency eq '1' } selected{/if}>1{"MINUTE"|@getFixedLabel}</option>
                      <option value="3" {if $frequency eq '3' } selected{/if}>3{"MINUTE"|@getFixedLabel}</option>
                      <option value="5" {if $frequency eq '5' } selected{/if}>5{"MINUTE"|@getFixedLabel}</option>
                      <option value="30" {if $frequency eq '30' } selected{/if}>30{"MINUTE"|@getFixedLabel}</option>
                      <option value="60" {if $frequency eq '60' } selected{/if}>1{"HOUR"|@getFixedLabel}</option>
                      <option value="180" {if $frequency eq '180' } selected{/if}>3{"HOUR"|@getFixedLabel}</option>
                      <option value="300" {if $frequency eq '300' } selected{/if}>5{"HOUR"|@getFixedLabel}</option>
                  </select>
              </td>
          </tr>
    </table>
  </form>
</div>
<!--中间 end-->


