{* creator:gyq_13 reason:新增日程模板第二步框架 date:20160613 *}
{*<!--修改编码格式:统一编码：UTF-8-->*}
<div class="divPopOverflow">
<form action="index.php" method="post" name="form" id="form" class="ajax_form">
    <input type="hidden" name="blockid" value="{$BLOCKID}"/>
    <input type="hidden" name="record" value="{$RECORD}"/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    <input type="hidden" name="blockidsetting" value="{$blockidsetting}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <input type="hidden" id="template_judgeinfo" name="template_judgeinfo" value="{$APPROVE.0.judgeinfo}"/>
    <input type="hidden" id="template_judgeinfo_groups" name="template_judgeinfo_groups" value="{$APPROVE.0.judgeinfo_groups}"/>
    <input type="hidden" id="template_calendardetail" name="template_calendardetail" value="{$APPROVE.0.calendardetail}"/>
    <input type="hidden" id="template_detailheader" name="" value='{$TEMPLATEDETAILHEADER}'/>
	<input type="hidden" id="image_path" name="image_path" value="" />
	<input type="hidden" name="advft_criteria" id="advft_criteria" value="" />
	<input type="hidden" name="advft_criteria_groups" id="advft_criteria_groups" value="" />
    <input type="hidden" id="approve_allocate_type" name="action_type" value="EditMultiApprove"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>
                {'TEMPLATENAME'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input id="templatename" name="templatename" class="ld-input-inner" type="text"  value="{$APPROVE.0.templatename}"/>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                {'WHETHERTOENABLE'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input id="status" name="status" class="second_switch" type="checkbox" value="1" {if $APPROVE.0.status eq 'close'}{else}checked{/if}  /> </td>
            </td>
        </tr>
         <tr>
             <td class="ld-form-item-label">
                {'AUTOEXECUTEWHENMET'|@getFixedLabel}
             </td>
             <td class="ld-form-item-content">
                <input id="autoexec" name="autoexec" class="second_switch" type="checkbox" value="1" {if $APPROVE.0.autoexec}checked{else}{/if}  />
             </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'REMARK'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><textarea class="ld-textarea-inner" name="base_description">{$APPROVE.0.description}</textarea></td>
        </tr>
    </table>
    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="4">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'APPLICABLESCOPE'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td id="allocate_divcontent" class="ld-form-item-content padL0 select-input"></td>
        </tr>
    </table>
    <div id="mnuTab2" style="display: block;">
        {include file="AdvanceFilterCustViewPopup.tpl"}
    </div>
    {* 日程模板明细 *}
    <div style="padding: 8px 24px 0;">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item padR0">
                {'LBL_CALENDAR_TEMPLATE'|@getFixedLabel}<span>{'REMINDFORCALENDARTEMPLATE'|@getFixedLabel}</span>
                <input type="button" class="ld-button ld-button-primary rfloat" value="{'NEWSIGNAL'|@getFixedLabel}{'Schedule'|@getFixedLabel}"
                       onclick="TemplateCalendar.getInstance().addNewCalendarDetail('settings')">
            </div>
        </div>
    </div>
    <div id="CalendarDetailContent">
        <table class="settingPopTable lasttdbordernon" style="table-layout: inherit;padding: 8px 24px 20px;" id="proTab" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr align="left">
            {$DERAILHEARDERS}
        </tr>
        {include file='TemplateCalendar/EditCalendarTemplate_DetailRow.tpl'}
        <tr id="bottom_calendar_row" style="display:none"></tr>
        </table>
    </div>
</form>
</div>