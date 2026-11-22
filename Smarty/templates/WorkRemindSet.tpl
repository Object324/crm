<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="RemindSet" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="Settings"/>
<input type="hidden" name="parenttab" value="Settings"/>
<input type="hidden" name="action" value="{$ACTION}"/>
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'LBL_REMIND_SET'|@getFixedLabel}<font>（{'LBL_REMIND_SET_DESCRIPTION'|@getFixedLabel}）</font>
        </span>
    </div>
    <div class="grid_tool">
      <a href="javascript:;" class="pg-btn-grey dinline-block lfloat" onclick="return verify_data({$dispcontrol});" title="{'SAVE'|@getFixedLabel}">保存</a>
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
                {'LBL_REMIND_SET'|@getFixedLabel}
              </th>
            </tr>
              <tr id="setting_1" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                <td width="20%">{'DAILYDEADLINE'|@getFixedLabel}</td>
                <td width="80%">
                  <select name="daily" class="btn-radius-system width100">
                  {foreach key=values item=data from=$DAILYARR}
                  {if $data eq $VALUES.0}
                   <option value="{$data}" selected="true">{$data}</option>
                   {else}
                   <option value="{$data}">{$data}</option>
                  {/if}
                  {/foreach}
                  </select>
                  <span class="greyFont9">（{'ONEAHREAREMIND'|@getFixedLabel}）</span>
                </td>
              </tr>
              <tr id="setting_2" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
                <td>{'WEEKLYDEADLINE'|@getFixedLabel}</td>
                <td>
                  <select name="week" class="btn-radius-system width100">
                  {foreach key=values item=data from=$WEEKARR}
                  {if $data eq $VALUES.1}
                   <option value="{$data}" selected="true">{$data}</option>
                   {else}
                   <option value="{$data}">{$data}</option>
                  {/if}
                  {/foreach}
                  </select>
                  <span class="greyFont9">（{'ONEAHEADWEEK'|@getFixedLabel}）</span>
                </td>
              </tr>
              <tr id="setting_3" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                <td>{'MONTHLYDEADLINE'|@getFixedLabel}</td>
                <td>
                  <select name="month" class="btn-radius-system width100">
                  {foreach key=values item=data from=$MONTHARR}
                  {if $data eq $VALUES.2}
                   <option value="{$data}" selected="true">{$data}</option>
                   {else}
                   <option value="{$data}">{$data}</option>
                  {/if}
                  {/foreach}
                   </select>
                  <span class="greyFont9">（{'THREEDAYSREMIND'|@getFixedLabel}）</span>
                </td>
              </tr>
          </table>
        </div>
    </div>
</div>
</form>
	
<script>
function verify_data(dispcontrol)
{ldelim}
var RemindSet=document.forms['RemindSet'];
var daily=RemindSet.daily.options[RemindSet.daily.options.selectedIndex].value;
var week=RemindSet.week.options[RemindSet.week.options.selectedIndex].value;
var month=RemindSet.month.options[RemindSet.month.options.selectedIndex].value;
    //确认要修改日，周，月报的提交期限吗？
    var confirm_str = arrJsPopLabel['WANTMODIFYSUBMISSIONDEADLINE'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    //确定按钮
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){ldelim}
          new Ajax.Request(
              'index.php',
              {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                    method: 'post',
                    postBody: 'module=Settings&action=SaveWorkRemindSet&daily='+daily+'&week='+week+'&month='+month+'&dispcontrol='+dispcontrol,
                    onComplete: function(response) {ldelim}
                    if(response.responseText.indexOf("SUCCESE")>-1){ldelim}
                      //保存成功！
                      var confirm_str = arrJsPopLabel['SUCCESSFULLYSAVED'];
                      // RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                      MessagePopup.TipOne_success(confirm_str);
                    {rdelim}
                    else{ldelim}
                      //修改成功！
                      var confirm_str = arrJsPopLabel['SUCCESSFULLYMODIFIED'];
                      // RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                      MessagePopup.TipOne_success(confirm_str);
                    {rdelim}
                    {rdelim}
          {rdelim});
    {rdelim});
{rdelim}
</script>