{*editor:gyq_79 reason:系统右上角呼叫中心报表优化 2018/9/10 14:16 *}
<form name="EditView" action="">
    <input type="hidden" value="" id="account_id" name="account_id">
    <input type="hidden" value="Attachment"  name="module">
	<input type="hidden" value="callbutler"  name="module_type">
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td align="right">
          {'RELATEDTO'|@getFixedLabel}
          <select class="commonSelectPop" style="width: 70px;" id="related_to_type" fieldonly="0" disabled="true" name="related_to_type" onchange="document.EditView.related_to_name.value=''"; document.EditView.related_to.value="";$("qcform").innerHTML=""">
              {foreach item=step from=$MODULEOPTIONS}
                  <option value="{$step.module}" {if $step.module eq 'Potentials'}selected{/if}> {$step.label}</option>
              {/foreach}
          </select>
        </td>
        <td>
            <input id="related_to" name="related_to" type="hidden" value="574">
            <input id="related_to_name" name="related_to_name" readonly="" style="width: 310px;" type="text" value="" class="commonTextBoxPop">
            <a class="icon-homeimg icon-select" href="javascript:;" title="选择" tabindex="r"
             onclick="selectRelatedTo_callbutler('related_to_type','related_to','Attachment','')"></a>
            <input class="icon-homeimg icon-clear inpb-reset" type="button" title="清除"
                 onclick="clear_relatedfielddata('','related_to','related_to_name','','Attachment','popupselectfield');return false;">
        </td>
      </tr>
    </table>
</form>