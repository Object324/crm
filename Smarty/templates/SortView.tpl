<!--修改编码格式:统一编码：UTF-8-->
<form name="EditView" id="sortview_form" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" name="module" value="{$MODULE}"/>
{if $MODULE eq 'MassSMS'}
<input type="hidden" name="action" value="SendView"/>
{elseif $MODULE eq 'Emails'}
<input type="hidden" name="action" value="GroupEmail"/>
{else}
<input type="hidden" name="action" value="ListView"/>
{/if}
<input type="hidden" name="parenttab" value="{$PARENTTAB}"/>
  <div class="E_pop_tit">
  	<strong class="E_ptita">{'LBL_CHANGEORDER'|@getFixedLabel}</strong>
    <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('sortview');"></button>
  </div>
  <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
     <tr>
         <td>
            <input type="hidden" name="selectedColumnsString2" id="selectedColumnsString2">
            <select id="selectedColumns2" multiple="" class="commonMultipleSelect" style="margin: 10px 0;" onchange="selectedColumnClick(this);" name="selectedColumns2" size="10" >
               {foreach item=viewname key=viewid from=$VIEWLIST}  
               <option value="{$viewid}">{$viewname}</option>
               {/foreach}
            </select>
         </td>
         <td align='center' width="100">
              <a class="icon-newhomearr icon-mup" style="margin-left: 3px;" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}" onclick="ModuleDetailmoveUp('selectedColumns2')"></a><br>
              <a class="icon-newhomearr icon-mdown" style="margin-left: 3px;margin-top: 15px;" href="javascript:;" title="{'MOVEDOWN'|@getFIxedLabel}" onclick="ProductDetailmoveDown('selectedColumns2')"></a>
         </td>
     </tr>
  </table>

  <div class="E_pbtn">
    {* editor:gyq_X160314 reason:序时簿排序弹框界面修改 date:2016 3 14 *}
    <input type="button" class="E_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveViewOrder(this,'sortview','{$MODULE}');"/><span>&nbsp;</span>
    <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('sortview');"/>
  </div>
</form>