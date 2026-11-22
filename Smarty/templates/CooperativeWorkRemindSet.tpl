<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="RemindSet" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action" value="{$ACTION}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_cooperative_REMIND_SET'|@getFixedLabel}
        </span>
    </div>
    <div class="grid_tool">
        <div class="displayflex">
            <a href="javascript:;" class="ld-button ld-button-primary" onclick="return verify_data({$dispcontrol});" title="{'SAVE'|@getFixedLabel}">{'SAVE'|@getFixedLabel}</a>
            {if 'oem_crm'|@getCommonVersion eq 'no'}
              <a href="javascript:;" class="ld-button" onclick="getLinksUrl('','Settings','WorkRemindSet');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
            {/if}
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
        </div>
        <div class="cont_wrap clear_float">
          <table border="0" cellspacing="0" cellpadding="0" width="100%" class="settingTable">
            <tr>
              <th colspan="2">
                {'LBL_REMIND_SET_DESCRIPTION'|@getFixedLabel}
              </th>
            </tr>
            <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td width="20%">{'DailySubmitDeadLine'|@getFixedLabel}</td>
              <td width="80%">
                <select name="daily" class="ld-select-inner width150">
                {foreach key=values item=data from=$DAILYARR}
                {if $data eq $VALUES.0}
                 <option value="{$data}" selected="true">{$data}</option>
                 {else}
                 <option value="{$data}">{$data}</option>
                {/if}
                {/foreach}
                </select>
                <span class="greyFont9">（{'DailySubmitDeadLineDescription'|@getFixedLabel}）</span>
              </td>
            </tr>
            <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'WeekSubmitDeadLine'|@getFixedLabel}</td>
              <td>
                <select name="week" class="ld-select-inner width150">
                {foreach key=values item=data from=$WEEKARR}
                {if $data eq $VALUES.1}
                 <option value="{$data}" selected="true">{$data}</option>
                 {else}
                 <option value="{$data}">{$data}</option>
                {/if}
                {/foreach}
                </select>
                <span class="greyFont9">（{'WeekSubmitDeadLineDescription'|@getFixedLabel}）</span>
              </td>
            </tr>
            <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
              <td>{'MonthSubmitDeadLine'|@getFixedLabel}</td>
              <td>
                <select name="month" class="ld-select-inner width150">
                {foreach key=values item=data from=$MONTHARR}
                {if $data eq $VALUES.2}
                 <option value="{$data}" selected="true">{$data}</option>
                 {else}
                 <option value="{$data}">{$data}</option>
                {/if}
                {/foreach}
                 </select>
                <span class="greyFont9">（{'MonthSubmitDeadLineDescription'|@getFixedLabel}）</span>
              </td>
            </tr>
          </table>
        </div>
    </div>
</div>
</form>
	
<script>
var tmptip='{"ConfirmSubmitCooperativeWorkRemind"|@getFixedLabel}';

function verify_data(dispcontrol)

{ldelim}
var RemindSet=document.forms['RemindSet'];
var daily=RemindSet.daily.options[RemindSet.daily.options.selectedIndex].value;
var week=RemindSet.week.options[RemindSet.week.options.selectedIndex].value;
var month=RemindSet.month.options[RemindSet.month.options.selectedIndex].value;
    //确认要修改日，周，月报的提交期限吗？
    var confirm_str = tmptip;
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){ldelim}
          new Ajax.Request(
              'index.php',
              {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                    method: 'post',
                    postBody: 'module=Settings&action=SaveCooperativeWorkRemindSet&daily='+daily+'&week='+week+'&month='+month+'&dispcontrol='+dispcontrol,
                    onComplete: function(response) {ldelim}
                    if(response.responseText.indexOf("SUCCESE")>-1){ldelim}
                      //保存成功！
                      var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
                      // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                      MessagePopup.TipOne_success(confirm_str);
                    {rdelim}
                    else{ldelim}
                      //修改成功！
                      var confirm_str = arrJsPopLabel['SUCCESSFULLYMODIFIED'];
                      // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                      MessagePopup.TipOne_success(confirm_str);
                    {rdelim}
                    {rdelim}
          {rdelim});
    {rdelim});
{rdelim}
</script>