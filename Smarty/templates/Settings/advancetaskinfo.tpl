<!-- 阶段任务名称和任务内容   -->
<input type="hidden" id="tasktype_{$stagenum}" name="tasktype_{$stagenum}" value="{$type}" />
{if $type eq 'module' && is_array($taskvalue) && sizeof($taskvalue)>0}
    {assign var = modulestr value =""}
    {assign var = modulenamestr value =""}
    {assign var = j value = 0}
    {foreach item = taskinfo from = $taskvalue}
        {assign var = modulename  value = $taskinfo.tasklabel|@getTranstab}
        {assign var = effect_range  value = $taskinfo.effect_range}
        {assign var = approve_demand  value = $taskinfo.approve_demand}
        {if $j >0 }
            {assign var = modulestr value =$modulestr|cat:","|cat:$taskinfo.tasklabel}
            {assign var = modulenamestr value =$modulenamestr|cat:","|cat:$modulename}
        {else}
            {assign var = modulestr value =$modulestr|cat:$taskinfo.tasklabel}
            {assign var = modulenamestr value =$modulenamestr|cat:$modulename}
        {/if}
        {assign var = j value =$j+1}
    {/foreach}
    <input readonly="readonly" modulestr="{$modulestr}" name="modulename_{$stagenum}"  class="advanceTextBox gwidth85 bgwhite ld-input-inner" type="text" value="{$modulenamestr}"
           onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','edit')" style="cursor: pointer;" data-effect_range="{$effect_range}" data-approve_demand="{$approve_demand}" />
{elseif $type eq "checkbox" && is_array($taskvalue) && sizeof($taskvalue)>0}
    <div class="DivCR" id="div_selectinfo"> 
    {assign var=fldname value='checkbox_'|cat:$stagenum}
        <select id="checkinfo_{$stagenum}" name="checkinfo_{$stagenum}" style="display:none">
        {assign var=checkinfo value=''}
        {foreach item=label from=$taskvalue}
            <option value="{$label.tasklabel}" >{$label.tasklabel}</option>
            {assign var=checkinfo value=$checkinfo|cat:$label.tasklabel|cat:"  "}
        {/foreach}
        </select>
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','div_selectinfo')" style="width: 90%;overflow:hidden;">
             	<a style="cursor: pointer;{if sizeof($taskvalue) neq 1 || $taskvalue.0.tasklabel neq ""}border: none;{/if}" class="chzn-single" onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','edit')" tabindex="-1"
                 name="cmb_a_{$fldname}">
                {foreach item=label from=$taskvalue}
                    {if $label.tasklabel neq ""}
                        <span class="detailedViewTextBox bgwhite" type="text" autocomplete="off" style="margin: 0px 8px 1px -8px;width: auto;height:30px;padding: 0 7px 0 7px;cursor: pointer;" tabindex="0" value="{$label.tasklabel}">{$label.tasklabel}</span>
                    {/if}
                {/foreach}
        	    </a>
         	   
            </div>	
        </div>
{elseif $type eq "select" && is_array($taskvalue) && sizeof($taskvalue)>0}
    {assign var=label value=$taskvalue.0.tasklabel}
    {if $SELECTTASKNAME neq ''}{assign var=label value=$SELECTTASKNAME}{/if}
    <div class="DivCR" id="div_selectinfo"> 
    {assign var=fldname value='select_'|cat:$stagenum}
        <select id="selectinfo_{$stagenum}" name="selectinfo_{$stagenum}" style="display:none">
        {foreach item=selectinfo from=$taskvalue.0.selectinfo }
            <option value="{$selectinfo}">{$selectinfo}</option>
        {/foreach}
        </select>
            <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','div_selectinfo')" style="width: 85%;">
             	<a style="width:100%;height:32px;" class="chzn-single" onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','edit')"  tabindex="-1"
                 name="cmb_a_{$fldname}">
					<input readonly="readonly" name="selecttaskname_{$stagenum}" tasktype ="{$type}" class="advanceTextBox bgwhite ld-input-inner" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;cursor: pointer;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','div_selectinfo')" onKeyUp="com_chosen(event,'{$fldname}','div_selectinfo')" value="{$label}">
        	    </a>
            </div>	
        </div>
{elseif $type eq "field"}
    {if !$fieldnamestr || $fieldnamestr eq ''}
        {assign var = fieldnamestr value =""}
        {assign var = fieldlabelstr value =""}
        {assign var = j value = 0}
        {foreach item = taskinfo from = $taskvalue}
            {* {assign var = modulename  value = $taskinfo.tasklabel|@getTranstab} *}
            {assign var = effect_range  value = $taskinfo.effect_range}
            {if $j >0 }
                {assign var = fieldnamestr value =$fieldnamestr|cat:","|cat:$taskinfo.tasklabel}
                {assign var = fieldlabelstr value =$fieldlabelstr|cat:","|cat:$taskinfo.fieldlabel}
            {else}
                {assign var = fieldnamestr value =$fieldnamestr|cat:$taskinfo.tasklabel}
                {assign var = fieldlabelstr value =$fieldlabelstr|cat:$taskinfo.fieldlabel}
            {/if}
            {assign var = j value =$j+1}
        {/foreach}
    {/if}
    <input readonly="readonly" fieldnamestr="{$fieldnamestr}" name="fieldname_{$stagenum}"  class="advanceTextBox gwidth85 bgwhite ld-input-inner" type="text" value="{$fieldlabelstr}" onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','edit')" style="cursor: pointer;" data-effect_range="{$effect_range}" />
{elseif $type eq "validata"}
    {assign var=label value=$taskvalue.0.showlabel}
    {assign var=validataid value=$taskvalue.0.tasklabel}
    <input readonly="readonly"  name="validata_{$stagenum}" data-validataid="{$validataid}"  class="advanceTextBox gwidth85 bgwhite ld-input-inner" type="text" value="{$label}" onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','edit')" style="cursor: pointer;"/>
{else}
    <input readonly="readonly" class="advanceTextBox gwidth85 bgwhite ld-input-inner" type="text" style="cursor: pointer" value="" onclick="AdvanceRelation.setAdvancetask('{$FROMMODULE}','{$stagenum}','{$type}','create')"/>
{/if}
