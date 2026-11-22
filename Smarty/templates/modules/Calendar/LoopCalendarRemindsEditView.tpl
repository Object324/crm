{*//ls 20240412 XUQIU1002280  优化日程界面及其设置循环日程功能*}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Calendar/LoopCalendar.js"></script>

<div id="addEventLoopUI" name="addEventLoopUI" style="width:100%;display:block;">
    <table>
        <tr class="ld-form-item">
            <td class="ld-form-item-label">
                <font color="red">*</font>{'LoopSchedule'|@getFixedLabel}
            </td>

            <td class="ld-form-item-content" name="td_cmb_loop_type">
                {assign var=loop_type_info value=$PickListData.loop_type_info}
                <select id="loop_type" name="loop_type" {$loop_type_info.selected}>
                    {foreach key=key item=item from=$loop_type_info.options}
                        <option value="{$key}" {if $key == $loop_type_info.selected}selected{/if}>{$item}</option>
                    {/foreach}
                </select>

            </td>

            <td class="ld-form-item-content" name="td_loop_month" style="display: none;">
                <select id="loop_month" name="loop_month[]"  class="ld-input-inner select2 select2-offscreen"  size="4" style="width:201px;" multiple data-mce-placeholder="请选择月份">
                    {foreach item=arr from=$PickListData.loop_month_info}
                        {if $arr[1] neq ''}
                            <option value="{$arr[1]}" {$arr[2]}>
                                {$arr[0]}
                            </option>
                        {/if}
                    {/foreach}
                </select>
                {*<script type="text/javascript">
                    /*这样也可以实现*/
                    ld(document).ready(function() {ldelim}
                        ld("#loop_month").select2({ldelim}closeOnSelect: false{rdelim});
                        {rdelim});
                </script>*}
            </td>

            <td class="ld-form-item-content" name="td_loop_dayvalue" style="display: none;">
                <select id="loop_dayvalue" name="loop_dayvalue[]" style="width:201px;" multiple>
                    {foreach item=arr from=$PickListData.loop_dayvalue_info}
                        {if $arr[1] neq ''}
                            <option value="{$arr[1]}" {$arr[2]}>
                                {$arr[0]}
                            </option>
                        {/if}
                    {/foreach}
                </select>
            </td>
        </tr>

        {*提醒设置*}
        <tr class="ld-form-item" name="tr_reminder_setting">
            <td class="ld-form-item-label">
                {'ReminderSettings'|@getFixedLabel}
            </td>

            <td class="ld-form-item-content" name="td_reminder_setting">
                <select id="reminder_setting" name="reminder_setting[]" style="width:201px;" multiple>
                    {foreach item=arr from=$PickListData.reminder_setting_info}
                        <option value="{$arr[1]}" {$arr[2]}>
                            {$arr[0]}
                        </option>
                    {/foreach}
                </select>
            </td>
        </tr>
        {*到期日期*}
        <tr class="ld-form-item" name="tr_expiredate" style="display: none;">
            <td class="ld-form-item-label">
                {'ExpireDate'|@getFixedLabel}
            </td>

            <td class="ld-form-item-content" name="td_expiredate">
                <input name="expiredate" class="Wdate ld-input-inner" type="text" style="box-sizing: border-box;color:" size="15" maxlength="25" value="{$PickListData.expiredate_info}" autocomplete="off" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true{rdelim});ld('.SearchResult').css('display','none')">
                <input type="hidden" name="expiredate" id="expiredate" value="">
            </td>
        </tr>

    </table>

</div>
<script>
    var picklistdata='{$PickListDataObj}';
    var loopCalendarobj=new LoopCalendar();
    loopCalendarobj.picklistdata = eval('('+ picklistdata +')')?eval('('+ picklistdata +')'):JSON.parse(picklistdata);
    loopCalendarobj.pagemode = '{$PageMode}';
    loopCalendarobj.setEvent();
    popupobj=CrmPopup.getPopupObj('last');
    popupobj.loopCalendarobj = loopCalendarobj;

</script>
