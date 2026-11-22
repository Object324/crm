<!--*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/
-->
<!--修改编码格式:统一编码：UTF-8-->
<!--<script src="include/js/json.js" type="text/javascript" charset="utf-8"></script>-->

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilter.js?v={$GLOBALMINVERSION}"></script>
{if $JS_DATEFORMAT eq ''}
	{assign var="JS_DATEFORMAT" value='YYYY-mm-ddd'|@parse_calendardate}
{/if}
<input type="hidden" id="jscal_dateformat" name="jscal_dateformat" value="{$JS_DATEFORMAT}" />
<input type="hidden" id="image_path" name="image_path" value="{$IMAGE_PATH}" />
<input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
<input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />
<div name='adv_filter_div'>
    <div style="padding: 8px 24px 0;">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</div>
        </div>
    </div>
    <div style="width: 100%;padding: 0 10px;">
        <div style="background-color: #fff;padding-right: 0px;width: 100%" class="advanceFilterNoDashedDiv" name="pop_adv_filter_div" id="pop_adv_filter_div" >
            <div name="advanceFilterDashedDiv" class="advanceFilterDashedDiv">
                <div name="advanceFilterGroupAddBtn" class="advanceFilterGroupAddBtn">
                    <i tag="addGroup" class="ld-fonticon ld-fonticon-add"></i>
                    <span tag="addGroup" style="padding-left: 4px">{'NEWCOMBINATION'|@getFixedLabel}</span>
                </div>
            </div>
        </div>
    </div>
</div>