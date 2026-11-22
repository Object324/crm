{* creator:gyq_13 reason:关联创建弹框 date:20160613 *}
{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Calendar/TemplateCalendar/TemplateCalendar.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/inputAddSubNumberBox.js?v={$GLOBALMINVERSION}"></script>
<div class="E_pop_tit">
    <strong class="E_ptita">{'LBL_Creates'|@getFixedLabel}{'Schedule'|@getFixedLabel}</strong>
    <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" mark="close"></button>
</div>
<form action="index.php" method="post" name="related_calendar_form" id="related_calendar_form" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Calendar"/>
    <input type="hidden" name="action" value="CalendarTemplate"/>
    <input type="hidden" name="template_showtype" value="save_template"/>
    <input type="hidden" name="blockid" value="{$BLOCKID}"/>
    <input type="hidden" name="currentrecord" value='{$CURRENTURLDATE}'/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <input type="hidden" id="template_judgeinfo" name="template_judgeinfo" value="{$APPROVE.0.judgeinfo}"/>
    <input type="hidden" id="template_judgeinfo_groups" name="template_judgeinfo_groups" value="{$APPROVE.0.judgeinfo_groups}"/>
    <input type="hidden" id="template_calendardetail" name="template_calendardetail" value="{$APPROVE.0.calendardetail}"/>
    <input type="hidden" id="template_detailheader" name="" value='{$TEMPLATEDETAILHEADER}'/>
    <input type="hidden" id="currentuser_id" name="currentuser_id" value='{$CURRENTUSERID}'/>
    {* 日程模板明细 *}
    <div id="CalendarDetailContent">
        <table class="settingPopTable lasttdbordernon" style="table-layout: inherit;" id="proTab" border="0" cellpadding="0" cellspacing="0" width="100%">
            <input type="hidden" id="table_width" name="table_width" value="255">
            <tbody>
            <tr align="left">
                {$DERAILHEARDERS}
            </tr>
            {include file='TemplateCalendar/EditCalendarTemplate_DetailRow.tpl'}
            <tr id="bottom_calendar_row" style="display: none;"></tr>
            <tr>
                <td colspan="7">
                    <input type="button" class="createauto" value="{'NEWSIGNAL'|@getFixedLabel}{'Schedule'|@getFixedLabel}"
       onclick="TemplateCalendar.getInstance().addNewCalendarDetail()">        
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</form>
{if $IS_ADMIN neq false}
    <a style="cursor:pointer;margin-left:10px;margin-top: 18px;position: absolute;" onclick="TemplateCalendar.getInstance().popSet_Templates('{$BLOCKID}','{$BLOCKIDSETTING}','{$FIELDIDSETTING}')">{'SETTINGS'|@getFixedLabel}{'LBL_CALENDAR_TEMPLATE'|@getFixedLabel}</a>
{/if}
<div class="E_pbtn">
    <input type="button" mark="confirm" class="E_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" /><span>&nbsp;</span>
    <input type="button" mark="close" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" />
</div>
<script>
    TemplateCalendar.getInstance().init_PopSurfaceButtons();
    inputAddSubNumberBox.getInstance().init(ld('#CalendarDetailContent div[mark="numberbox"]'));
</script>

