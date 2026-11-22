{if $SHOWTYPE == 'detail'}
    {assign var=fieldtask_num value=0}
    {assign var=task_num value=0}
    {assign var=td1width value='width="1%" style="padding:0;"'}
    {assign var=td2width value='width="39%" style="padding:0;"'}
    {assign var=td3width value='width="60%"'}
    {assign var=text_align value='left'}
    {assign var=fontstyle value='style="font-weight:bold"'}
    <table class="settingadvaceTable" name="advancetask" border="0" cellpadding="0" cellspacing="0" width="100%" >
        {foreach key=index item=task from=$TASKINFO.taskvalue}
            {assign var=taskid value=$task.taskid}

            {if $task.type eq "module"}
                {if $module_show neq 'yes'}
                    <tr>
                        <td {$td2width}>
                            {if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                            <span {$fontstyle}>{'TASK'|@getFixedLabel}</span>->
                            <span {$fontstyle}>{'CREATERECORD'|@getFixedLabel} </td>
                        <td {$td3width}></td>
                    </tr>
                    {assign var=module_show value='yes'}
                {/if}

                {assign var=task_num value=$task_num+1}
                <tr >
                <td {$td2width} style="height:25px;text-align:{$text_align};">{$task.tasklabel|@getTranstab}</span></td>
                {if $TASKLOG.$taskid.effective eq 'yes'}
                    <td {$td3width} style="height:25px;" name="advancetask_module" module="{$task.tasklabel}">
                        <div name="advance_record_div" class="advance_hiderecord" >
                            <div name="advance_record_child" tag="detail_log" class="advance_child_record advance_detail_record_width">
                                {foreach key=tmp_index item=tmp_record_arr from=$TASKLOG.$taskid.record_no_arr}
                                    {if $tmp_index > 0},{/if}
                                    <a module="{$task.tasklabel}" record="{$tmp_record_arr.crmid}"
                                       href="index.php?pageto_module={$task.tasklabel}&pageto_action=index&pageto_record={$tmp_record_arr.crmid}"
                                       onclick="ListLinkClick(ld(this),event)"  title="{$tmp_record_arr.record_no}">{$tmp_record_arr.record_no}</a>
                                {/foreach}
                            </div>
                            <div class="advance_opreation">
                                <a name="show_record_btn" style="display: none" onclick="AdvanceStage.changerecordstatus(this,'show');" title="{'EXPANSION'|@getFixedLabel}" ><span>{'EXPANSION'|@getFixedLabel}</span></a>
                                <a name="hide_record_btn" style="display: none" onclick="AdvanceStage.changerecordstatus(this,'hide');" title="{'COLLAPSE'|@getFixedLabel}" ><span>{'COLLAPSE'|@getFixedLabel}</span></a>
                                {if $task.effect_range eq 'sum' && $ALLOWEDIT eq 'yes'}
                                    <a title="{'LBL_Creates'|@getFixedLabel}" href="javascript:void(0);" onclick="AdvanceStage.completetask(this);related_add_url('index.php?module={$task.tasklabel}&amp;action=EditView&amp;return_module={$task.tasklabel}&amp;return_action=DetailView&amp;relatedcreate=yes&amp;Create=true&amp;frommodule={$MODULENAME}&amp;fromid={$RECORD}&amp;parent_id={$RECORD}&amp;potential_id={$RECORD}','{$MODULENAME}','{$task.tasklabel}','{$RECORD}')" modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="module" record="{$RECORD}" taskid="{$task.taskid}"><span>{'LBL_Creates'|@getFixedLabel}</span></a>
                                {/if}
                            </div>
                        </div>
                    </td>
                {else}
                    <td {$td3width} style="height:25px;color: #999;" name="advancetask_module" module="{$task.tasklabel}" >{'NOCREATED'|@getFixedLabel}
                        {if $ALLOWEDIT eq 'yes'},
                            <a title="{'LBL_Creates'|@getFixedLabel}" href="javascript:void(0);"  onclick="related_add_url('index.php?module={$task.tasklabel}&amp;action=EditView&amp;return_module={$task.tasklabel}&amp;return_action=DetailView&amp;relatedcreate=yes&amp;Create=true&amp;frommodule={$MODULENAME}&amp;fromid={$RECORD}&amp;parent_id={$RECORD}&amp;potential_id={$RECORD}','{$MODULENAME}','{$task.tasklabel}','{$RECORD}')"
                               modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="module" record="{$RECORD}" taskid="{$task.taskid}">
                                <span>{'LBL_Creates'|@getFixedLabel}</span></a>
                        {/if}
                    </td>
                {/if}

            {elseif $task.type eq "checkbox"}
                {if $checkbox_show neq 'yes'}
                    <tr>
                        <td {$td2width}>
                            {if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                            <span {$fontstyle}>{'TASK'|@getFixedLabel}</span>->
                            <span {$fontstyle}>{'CHECKTYPE'|@getFixedLabel} </td>
                        <td {$td3width}></td>
                    </tr>
                    {assign var=checkbox_show value='yes'}
                {/if}

                {assign var=task_num value=$task_num+1}
                <tr >
                <td {$td2width} style="height:25px;text-align:{$text_align};">{$task.tasklabel|@getTranstab}</span></td>
                <td {$td3width} style="height:25px;" class="select-input">
                    <input type="checkbox" {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if}  name="checkbox_{$index}" modulename="{$MODULENAME}" stagename="{$STAGENAME}" tasktype="checkbox" record="{$RECORD}"
                           onclick="AdvanceStage.completetask(this)" value="yes" taskid="{$task.taskid}" {if $TASKLOG.$taskid.taskresult eq 'yes'}checked=""{/if} /><label class="padR10">{'YES'|@getFixedLabel}</label>
                    <input type="checkbox" {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if}  name="checkbox_{$index}" modulename="{$MODULENAME}" stagename="{$STAGENAME}" tasktype="checkbox" record="{$RECORD}"
                           onclick="AdvanceStage.completetask(this)" value="no" taskid="{$task.taskid}" {if $TASKLOG.$taskid.taskresult eq 'no'}checked=""{/if} /><label class="padR10">{'NO'|@getFixedLabel}</label>
                </td>
            {elseif $task.type eq "select"}
                {if $select_show neq 'yes'}
                    <tr>
                        <td {$td2width}>
                            {if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                            <span {$fontstyle}>{'TASK'|@getFixedLabel}</span>->
                            <span {$fontstyle}>{'SELECTTYPE'|@getFixedLabel} </td>
                        <td {$td3width}></td>
                    </tr>
                    {assign var=select_show value='yes'}
                {/if}
                {assign var=task_num value=$task_num+1}
                <tr>
                <td {$td2width} style="height:25px;text-align:{$text_align};">{$task.tasklabel}</span></td>
                <td {$td3width} style="height:25px;">

                    {if $ALLOWEDIT neq 'yes' && $TASKLOG.$taskid.effective eq 'yes'}
                        <span>{$TASKLOG.$taskid.taskresult}</span>
                    {else}
                        <select {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if} class="btn-radius-system" style="min-width: 70px;max-width: 120px;-webkit-appearance: auto;" onchange="AdvanceStage.completetask(this)" modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="select" record="{$RECORD}" name="checkbox_{$index}"  taskid="{$task.taskid}">
                            <option style="display:none;" value="no"></option>
                            {foreach item=optionname from=$task.selectinfo}
                                <option value="{$optionname}" {if $TASKLOG.$taskid.taskresult eq $optionname}selected {/if} >{$optionname}</option>
                            {/foreach}
                        </select>
                    {/if}
                </td>


            {elseif $task.type eq "field"}
                {if $field_show neq 'yes'}
                    <tr>
                        <td {$td2width}>
                            {if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                            <span {$fontstyle}>{'TASK'|@getFixedLabel}</span>->
                            <span {$fontstyle}>{'FieldTasks'|@getFixedLabel} </td>
                        <td {$td3width}></td>
                    </tr>
                    {assign var=field_show value='yes'}
                {/if}
                {assign var=task_num value=$task_num+1}
                {assign var=fieldtask_num value=$fieldtask_num+1}
                <tr  >
                {$task.content}
            {/if}

            </tr>
        {/foreach}
    </table>
    <input type="hidden" name="stagename_now" value="{$STAGENAME}" />
    <input type="hidden" name="task_num" value="{$task_num}" />
    <input type="hidden" name="fieldtask_num" value="{$fieldtask_num}" />
{elseif $SHOWTYPE == 'showadvnacedetail'}
    {assign var=fieldtask_num value=0}
    {assign var=task_num value=0}
    {assign var=td1width value='width="10%"'}
    {assign var=td2width value='width="15%"'}
    {assign var=td3width value='width="30%"'}
    {assign var=text_align value='left'}
    <table class="" name="advancetask" border="0" cellpadding="0" cellspacing="0" width="100%">
        <thead>
        <th width="25%">{'TASK'|@getFixedLabel}</th>
        <th width="25%">{'FIELDS'|@getFixedLabel}</th>
        <th width="50%"></th>
        </thead>
        <tbody>
        {foreach key=index item=task from=$TASKINFO.taskvalue}
            {assign var=taskid value=$task.taskid}
            {if $task.type eq "module"}
                {assign var=task_num value=$task_num+1}
                <tr>
                    <td {$td1width} >{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{/if}{'CREATERECORD'|@getFixedLabel}</td>
                    <td {$td2width} style="text-align:{$text_align};">{$task.tasklabel|@getTranstab}</td>
                    {if $TASKLOG.$taskid.effective eq 'yes'}
                        <td {$td3width} name="advancetask_module" module="{$task.tasklabel}">
                            <div name="advance_record_div" class="advance_hiderecord">
                                <div name="advance_record_child" class="advance_child_record ">
                                    {foreach key=tmp_index item=tmp_record_arr from=$TASKLOG.$taskid.record_no_arr}
                                        {if $tmp_index > 0},{/if}
                                        <a module="{$task.tasklabel}" record="{$tmp_record_arr.crmid}"
                                           href="index.php?pageto_module={$task.tasklabel}&pageto_action=index&pageto_record={$tmp_record_arr.crmid}"
                                           onclick="ListLinkClick(ld(this),event)"  title="{$tmp_record_arr.record_no}">{$tmp_record_arr.record_no}</a>
                                    {/foreach}
                                </div>
                                <div class="advance_opreation">
                                    <a name="show_record_btn" style="display: none" onclick="AdvanceStage.changerecordstatus(this,'show');" title="{'EXPANSION'|@getFixedLabel}" ><span>{'EXPANSION'|@getFixedLabel}</span></a>
                                    <a name="hide_record_btn" style="display: none" onclick="AdvanceStage.changerecordstatus(this,'hide');" title="{'COLLAPSE'|@getFixedLabel}" ><span>{'COLLAPSE'|@getFixedLabel}</span></a>
                                    {if $task.effect_range eq 'sum' && $ALLOWEDIT eq 'yes'}
                                        <a title="{'LBL_Creates'|@getFixedLabel}" href="javascript:void(0);" onclick="AdvanceStage.completetask(this);related_add_url('index.php?module={$task.tasklabel}&amp;action=EditView&amp;return_module={$task.tasklabel}&amp;return_action=DetailView&amp;relatedcreate=yes&amp;Create=true&amp;frommodule={$MODULENAME}&amp;fromid={$RECORD}&amp;parent_id={$RECORD}&amp;potential_id={$RECORD}','{$MODULENAME}','{$task.tasklabel}','{$RECORD}')" modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="module" record="{$RECORD}" taskid="{$task.taskid}"><span>{'LBL_Creates'|@getFixedLabel}</span></a>
                                    {/if}
                                </div>
                            </div>
                        </td>
                    {else}
                        <td {$td3width} style="color: #999;" name="advancetask_module" module="{$task.tasklabel}" >{'NOCREATED'|@getFixedLabel}
                            {if $ALLOWEDIT eq 'yes'},
                                <a title="{'LBL_Creates'|@getFixedLabel}" href="javascript:void(0);"  onclick="related_add_url('index.php?module={$task.tasklabel}&amp;action=EditView&amp;return_module={$task.tasklabel}&amp;return_action=DetailView&amp;relatedcreate=yes&amp;Create=true&amp;frommodule={$MODULENAME}&amp;fromid={$RECORD}&amp;parent_id={$RECORD}&amp;potential_id={$RECORD}','{$MODULENAME}','{$task.tasklabel}','{$RECORD}')"
                                   modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="module" record="{$RECORD}" taskid="{$task.taskid}">
                                    <span>{'LBL_Creates'|@getFixedLabel}</span></a>
                            {/if}
                        </td>
                    {/if}
        {elseif $task.type eq "checkbox"}
                    {assign var=task_num value=$task_num+1}
                <tr>
                    <td {$td1width}>{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{/if}{'CHECKTYPE'|@getFixedLabel}</td>
                    <td {$td2width} style="text-align:{$text_align};">{$task.tasklabel|@getTranstab}</span></td>
                    <td {$td3width} style="" class="select-input">
                        <input type="checkbox" {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if}  name="checkbox_{$index}" modulename="{$MODULENAME}" stagename="{$STAGENAME}" tasktype="checkbox" record="{$RECORD}" onclick="AdvanceStage.completetask(this)" value="yes" taskid="{$task.taskid}" {if $TASKLOG.$taskid.taskresult eq 'yes'}checked=""{/if} /><label class="padR10">{'YES'|@getFixedLabel}</label>
                        <input type="checkbox" {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if}  name="checkbox_{$index}" modulename="{$MODULENAME}" stagename="{$STAGENAME}" tasktype="checkbox" record="{$RECORD}" onclick="AdvanceStage.completetask(this)" value="no" taskid="{$task.taskid}" {if $TASKLOG.$taskid.taskresult eq 'no'}checked=""{/if} /><label class="padR10">{'NO'|@getFixedLabel}</label>
                    </td>
                    {elseif $task.type eq "select"}
                    {assign var=task_num value=$task_num+1}
                <tr>
                <td {$td1width} >{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{/if}{'SELECTTYPE'|@getFixedLabel}</td>
                <td {$td2width} style="text-align:{$text_align};">{$task.tasklabel}</span></td>
                <td {$td3width}>
                    {if $ALLOWEDIT neq 'yes' && $TASKLOG.$taskid.effective eq 'yes'}
                        <span>{$TASKLOG.$taskid.taskresult}</span>
                    {else}
                        <select {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if} class="btn-radius-system" style="min-width: 70px;max-width: 120px;-webkit-appearance: auto;" onchange="AdvanceStage.completetask(this)" modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="select" record="{$RECORD}" name="checkbox_{$index}"  taskid="{$task.taskid}">
                            <option style="display:none;" value="no"></option>
                            {foreach item=optionname from=$task.selectinfo}
                                <option value="{$optionname}" {if $TASKLOG.$taskid.taskresult eq $optionname}selected {/if} >{$optionname}</option>
                            {/foreach}
                        </select>
                    {/if}
                </td>
        {elseif $task.type eq "field"}
                {if $task.show eq 'yes'}
                    {assign var=task_num value=$task_num+1}
                    {assign var=fieldtask_num value=$fieldtask_num+1}
                    <tr>
                    <td {$td1width} ><span style="marfin-right:20px;">{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{/if}{'FieldTasks'|@getFixedLabel}</td>
                    {$task.content}
                {/if}
            {/if}
            </tr>
        {/foreach}
        </tbody>
    </table>
    <input type="hidden" name="stagename_now" value="{$STAGENAME}" />
    <input type="hidden" name="task_num" value="{$task_num}" />
    <input type="hidden" name="fieldtask_num" value="{$fieldtask_num}" />
{else}
    {assign var=fieldtask_num value=0}
    {assign var=task_num value=0}
    {assign var=td1width value='width="10%"'}
    {assign var=td2width value='width="15%"'}
    {assign var=td3width value='width="30%"'}
    {assign var=text_align value='left'}
    <table class="settingadvaceTable padB10" name="advancetask" border="0" cellpadding="0" cellspacing="0" width="100%" >
        {foreach key=index item=task from=$TASKINFO.taskvalue}
            {assign var=taskid value=$task.taskid}

            {if $task.type eq "module"}
                {assign var=task_num value=$task_num+1}
                <tr >
                    <td {$td1width} >{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                        <span style="marfin-right:20px;">{'TASK'|@getFixedLabel}->{'CREATERECORD'|@getFixedLabel} </td>
                    <td {$td2width} style="height:25px;text-align:{$text_align};">{$task.tasklabel|@getTranstab}</span></td>
                    {if $TASKLOG.$taskid.effective eq 'yes'}
                        <td class="ld-form-item-content" {$td3width} name="advancetask_module" module="{$task.tasklabel}">
                            <div name="advance_record_div" class="advance_hiderecord " >
                                <div name="advance_record_child" class="advance_child_record advance_detail_record_maxwidth ">
                                    {foreach key=tmp_index item=tmp_record_arr from=$TASKLOG.$taskid.record_no_arr}
                                        {if $tmp_index > 0},{/if}
                                        <a module="{$task.tasklabel}" record="{$tmp_record_arr.crmid}"
                                           href="index.php?pageto_module={$task.tasklabel}&pageto_action=index&pageto_record={$tmp_record_arr.crmid}"
                                           onclick="ListLinkClick(ld(this),event)"  title="{$tmp_record_arr.record_no}">{$tmp_record_arr.record_no}</a>
                                    {/foreach}
                                </div>
                                <div class="advance_opreation">
                                    <a name="show_record_btn" style="display: none" onclick="AdvanceStage.changerecordstatus(this,'show');" title="{'EXPANSION'|@getFixedLabel}" ><span>{'EXPANSION'|@getFixedLabel}</span></a>
                                    <a name="hide_record_btn" style="display: none" onclick="AdvanceStage.changerecordstatus(this,'hide');" title="{'COLLAPSE'|@getFixedLabel}" ><span>{'COLLAPSE'|@getFixedLabel}</span></a>
                                    {if  $ALLOWEDIT eq 'yes'}
                                        <a title="{'LBL_Creates'|@getFixedLabel}" href="javascript:void(0);" onclick="AdvanceStage.completetask(this);related_add_url('index.php?module={$task.tasklabel}&amp;action=EditView&amp;return_module={$task.tasklabel}&amp;return_action=DetailView&amp;relatedcreate=yes&amp;Create=true&amp;frommodule={$MODULENAME}&amp;fromid={$RECORD}&amp;parent_id={$RECORD}&amp;potential_id={$RECORD}','{$MODULENAME}','{$task.tasklabel}','{$RECORD}')" modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="module" record="{$RECORD}" taskid="{$task.taskid}"><span>{'LBL_Creates'|@getFixedLabel}</span></a>
                                    {/if}
                                </div>
                            </div>
                        </td>
                    {else}
                        <td {$td3width} style="color: #999;" name="advancetask_module" module="{$task.tasklabel}" >{'NOCREATED'|@getFixedLabel}
                            {if $ALLOWEDIT eq 'yes'},
                                <a title="{'LBL_Creates'|@getFixedLabel}" href="javascript:void(0);"  onclick="related_add_url('index.php?module={$task.tasklabel}&amp;action=EditView&amp;return_module={$task.tasklabel}&amp;return_action=DetailView&amp;relatedcreate=yes&amp;Create=true&amp;frommodule={$MODULENAME}&amp;fromid={$RECORD}&amp;parent_id={$RECORD}&amp;potential_id={$RECORD}','{$MODULENAME}','{$task.tasklabel}','{$RECORD}')"
                                   modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="module" record="{$RECORD}" taskid="{$task.taskid}">
                                    <span>{'LBL_Creates'|@getFixedLabel}</span></a>
                            {/if}
                        </td>
                    {/if}
                    {if $inpopup neq 'yes'}
                        <td width="50%"></td>
                    {/if}
                    {elseif $task.type eq "checkbox"}
                    {assign var=task_num value=$task_num+1}
                <tr >
                    <td {$td1width} >{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                        <span style="marfin-right:20px;">{'TASK'|@getFixedLabel}->{'CHECKTYPE'|@getFixedLabel} </td>
                    <td {$td2width} style="height:25px;text-align:{$text_align};">{$task.tasklabel|@getTranstab}</span></td>
                    <td {$td3width} style="height:25px;line-height: 25px;" class="select-input">
                        <input type="checkbox" {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if}  name="checkbox_{$index}" modulename="{$MODULENAME}" stagename="{$STAGENAME}" tasktype="checkbox" record="{$RECORD}"
                               onclick="AdvanceStage.completetask(this)" value="yes" taskid="{$task.taskid}" {if $TASKLOG.$taskid.taskresult eq 'yes'}checked=""{/if} /><label class="padR10">{'YES'|@getFixedLabel}</label>
                        <input type="checkbox" {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if}  name="checkbox_{$index}" modulename="{$MODULENAME}" stagename="{$STAGENAME}" tasktype="checkbox" record="{$RECORD}"
                               onclick="AdvanceStage.completetask(this)" value="no" taskid="{$task.taskid}" {if $TASKLOG.$taskid.taskresult eq 'no'}checked=""{/if} /><label class="padR10">{'NO'|@getFixedLabel}</label>
                    </td>

                    {if $inpopup neq 'yes'}
                        <td width="50%"></td>
                    {/if}
                    {elseif $task.type eq "select"}
                    {assign var=task_num value=$task_num+1}
                <tr>
                <td {$td1width} >{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                    <span style="marfin-right:20px;">{'TASK'|@getFixedLabel}->{'SELECTTYPE'|@getFixedLabel} </td>
                <td {$td2width} style="height:25px;text-align:{$text_align};">{$task.tasklabel}</span></td>
                <td {$td3width} style="height:25px;">

                    {if $ALLOWEDIT neq 'yes' && $TASKLOG.$taskid.effective eq 'yes'}
                        <span>{$TASKLOG.$taskid.taskresult}</span>
                    {else}
                        <select {if $ALLOWEDIT neq 'yes'}disabled="disabled"{/if} class="btn-radius-system" style="min-width: 70px;max-width: 120px;-webkit-appearance: auto;" onchange="AdvanceStage.completetask(this)" modulename="{$MODULENAME}" stagename="{$STAGENAME}"  tasktype="select" record="{$RECORD}" name="checkbox_{$index}"  taskid="{$task.taskid}">
                            <option style="display:none;" value="no"></option>
                            {foreach item=optionname from=$task.selectinfo}
                                <option value="{$optionname}" {if $TASKLOG.$taskid.taskresult eq $optionname}selected {/if} >{$optionname}</option>
                            {/foreach}
                        </select>
                    {/if}
                </td>
                <td width="50%"></td>

            {elseif $task.type eq "field"}
                {if $task.show eq 'yes'}
                    {assign var=task_num value=$task_num+1}
                    {assign var=fieldtask_num value=$fieldtask_num+1}
                    <tr  >
                    <td {$td1width} >{if $task.completerequest eq 'yes'}<font style="color:red">*</font>{else}&nbsp;{/if}
                        <span style="marfin-right:20px;">{'TASK'|@getFixedLabel}->{'FieldTasks'|@getFixedLabel} </td>
                    {$task.content}
                    {if $inpopup neq 'yes'}
                        <td width="50%"></td>
                    {/if}
                {/if}
            {/if}

            </tr>
        {/foreach}
    </table>
    <input type="hidden" name="stagename_now" value="{$STAGENAME}" />
    <input type="hidden" name="task_num" value="{$task_num}" />
    <input type="hidden" name="fieldtask_num" value="{$fieldtask_num}" />
{/if}