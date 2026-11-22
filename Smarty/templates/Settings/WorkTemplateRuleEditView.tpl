<div id="WorkTemplateRuleEditView" name="WorkTemplateRuleEditView" style="height: 600px;">
    <table class="ld-public-content-small padL10" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="4">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr class="ld-form-item">
            <td class="ld-form-item-label"><font color="red">*</font>{'RULENAME'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input id="rule_name" name="rule_name" class="ld-input-inner" type="text"  value="{$info.name}"/></td>
        </tr>
        <tr class="ld-form-item">
            <td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input id="status" name="status" class="second_switch" type="checkbox" value="1" {if $info.status eq 'yes'}checked{/if}/></td>
        </tr>
        {*适用范围*}
        <tr class="ld-form-item" >
            <td class="ld-form-item-label">{'APPLICABLESCOPE'|@getFixedLabel}</td>
            <td class="ld-form-item-content" id="allocate_divcontent" colspan="3">
                <div id='view_scope' class="select-input" >
                    <input type="radio" {if $allocateinfo.rule_range eq 'all'}checked={/if} value="all" changeType="rule_range" changeValue="rule_value" name="radioUser" id="ALLTHEUSERS" onclick="WorkTemplateRule.getInstance().setScopeValue(this,'all')">
                    <label class="padR10" for="ALLTHEUSERS">{'ALLTHEUSERS'|@getFixedLabel}</label>
                    <input type="radio" {if $allocateinfo.rule_range eq 'group'}checked{/if} changeType="rule_range" changeValue="rule_value" onclick="WorkTemplateRule.getInstance().setScopeValue(this,'group')" value="group" name="radioUser" id="setByDepartment">
                    <label class="padR10" for="setByDepartment">{'SETBYDEPARTMENT'|@getFixedLabel}</label>
                    <input type="radio" {if $allocateinfo.rule_range eq 'user'}checked{/if} changeType="rule_range" changeValue="rule_value" onclick="WorkTemplateRule.getInstance().setScopeValue(this,'user')" value="user" name="radioUser" id="setByUser">
                    <label class="padR10" for="setByUser">{'SETBYUSERS'|@getFixedLabel}</label>
                    <input type="radio" {if $allocateinfo.rule_range eq 'role'}checked{/if} changeType="rule_range" changeValue="rule_value" onclick="WorkTemplateRule.getInstance().setScopeValue(this,'role')" value="role" name="radioUser" id="SetByRole">
                    <label class="padR10" for="SetByRole">{'SetByRole'|@getFixedLabel}</label>
                    <input id="rule_range" type="hidden" value="{$allocateinfo.rule_range}" id="rule_range" name="rule_range">
                    <input id="rule_value" type="hidden" value="{$allocateinfo.rule_value}" id="rule_value" name="rule_value">
                </div>
            </td>
        </tr>
        <tr>
            <td class="padT28 padB0" colspan="4">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item" >{'ReviewerAndCCRange'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        {*设置固定点评人*}
        <tr class="ld-form-item">
            <td class="ld-form-item-label">{'SetFixedReviewer'|@getFixedLabel}</td>
            <td name="reuser_td" class="ld-form-item-content" colspan="3">
                <input id="reuser_presence" name="reuser_presence" changename="reuser_set" class="second_switch" type="checkbox"{if $info.reuser_presence eq 'yes'}checked{/if}/>
                <label style="color: #999">({'SetFixedReviewerTip'|@getFixedLabel})</label>
            </td>
        </tr>
        {*点评人类型*}
        <tr class="ld-form-item" name="reuser_set" {if $info.reuser_presence neq 'yes'}style="display: none" {/if}>
            <td class="ld-form-item-label">{'ReuserType'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <select class="ld-select-inner" style="width: 34%" name="reuser_select" id="reuser_select" changeType="select" changeValue="reuser_input" onchange="WorkTemplateRule.getInstance().changeSelect(this)">
                    <option value="user" {if $info.reuser_type eq 'user'}selected{/if}>{'SPECIFYUSER'|@getFixedLabel}</option>
                    {foreach key=fieldname item=item from=$selectUserFieldArr}
                        <option value="Users" module="{$item.module}" columnname="{$item.columnname}" {if $info.reuser_type eq 'Users' && $info.reuser_value eq $item.columnname}selected{/if}>{$item.label}</option>
                    {/foreach}
                </select>
                <div style="overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0;width: 65%;margin-top: -3px;{if $info.reuser_type neq 'user'}display: none;{/if}" type="text"
                     id="reuser_input" name="reuser_input" class="ld-input-inner-div ld-input-inner-add" value_str="{$info.reuser_value}" value="">{$info.reuser_value_label}</div>
                <a {if $info.reuser_type neq 'user'}style="display: none"{/if} class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" name="add" addselect="reuser_select" onclick="WorkTemplateRule.getInstance().addEvent(this)">+</a>
                <a {if $info.reuser_type neq 'user'}style="display: none"{/if} class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" name="clear" clearinput="reuser_input" onclick="WorkTemplateRule.getInstance().clearEvent(this)">+</a>
                <label {if $info.reuser_type eq 'user'}style="display: none"{/if} name="field_select_tip">({'ReuserValueTip'|@getFixedLabel})</label>
            </td>
        </tr>
        {*设置最小抄送范围*}
        <tr class="ld-form-item">
            <td class="ld-form-item-label">{'SetMinCCRange'|@getFixedLabel}</td>
            <td name="ccuser_td" class="ld-form-item-content" colspan="3">
                <input id="ccuser_presence" name="ccuser_presence" changename="ccuser_set" class="second_switch" type="checkbox" {if $info.ccuser_presence eq 'yes'}checked{/if}/>
                <label style="color: #999">({'SetMinCCRangeTip'|@getFixedLabel})</label>
            </td>
        </tr>
        {*抄送人类型*}
        <tr class="ld-form-item" name="ccuser_set" {if $info.ccuser_presence neq 'yes'}style="display: none" {/if}>
            <td class="ld-form-item-label">{'CCuserType'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <select class="ld-select-inner overflow-space" style="width: 34%" name="ccuser_select" id="ccuser_select" changeType="select" changeValue="ccuser_input" onchange="WorkTemplateRule.getInstance().changeSelect(this)">
                    <option value="user" {if $info.ccuser_type eq 'user'}selected{/if}>{'SPECIFYUSER'|@getFixedLabel}</option>
                    <option value="role" {if $info.ccuser_type eq 'role'}selected{/if}>{'SPECIFYROLE'|@getFixedLabel}</option>
                    <option value="group" {if $info.ccuser_type eq 'group'}selected{/if}>{'SPECIFYGROUP'|@getFixedLabel}</option>
                    {foreach key=fieldname item=item from=$selectUserFieldArr}
                        <option value="Users" module="{$item.module}"  columnname="{$item.columnname}" {if $info.ccuser_type eq 'Users' && $info.ccuser_value eq $item.columnname}selected{/if}>{$item.label}</option>
                    {/foreach}
                </select>
                <div style="overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0;width: 65%;margin-top: -3px;{if $info.ccuser_type eq 'Users'}display: none;{/if}" type="text"
                     id="ccuser_input" name="ccuser_input" class="ld-input-inner-div ld-input-inner-add" value_str="{$info.ccuser_value}" value="">{$info.ccuser_value_label}</div>
                <a {if $info.ccuser_type eq 'Users'}style="display: none"{/if} class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" name="add" addselect="ccuser_select" onclick="WorkTemplateRule.getInstance().addEvent(this)">+</a>
                <a {if $info.ccuser_type eq 'Users'}style="display: none"{/if} class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" name="clear"  clearinput="ccuser_input" onclick="WorkTemplateRule.getInstance().clearEvent(this)">+</a>
            </td>
        </tr>

        <tr>
            <td class="padT28 padB0" colspan="4">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item" style="width: auto">{'SetSubmissionDeadlineReminderRule'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        {*提醒截止时间*}
        <tr class="ld-form-item">
            <td class="ld-form-item-label">{'SubmissionDeadline'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <select class="ld-select-inner " style="width: 34%;" id="deadline_date" name="deadline_date" {if $reporttype eq 'day'}disabled{/if}>
                    {foreach key=key item=label from=$deadline_date_arr}
                        <option value="{$key}" {if $info.deadline_date eq $key}selected{/if}>{$label}</option>
                    {/foreach}
                </select>
                {if $reporttype eq 'day'}
{*                    <select class="ld-select-inner" style="width: 34%;margin-left: 2px" id="remind_time" name="remind_time">*}
{*                        {for $hour = 0 to 23}*}
{*                            {if $hour lt 10}*}
{*                                {assign var=time_value value='0'|cat:$hour|cat:":"|cat:'00:00'}*}
{*                            {else}*}
{*                                {assign var=time_value value=$hour|cat:":"|cat:'00:00'}*}
{*                            {/if}*}
{*                            <option value="{$time_value}" {if $info.remind_time eq $time_value}selected{/if}>{$hour}:00</option>*}
{*                        {/for}*}
{*                    </select>*}
                    <input id="remind_time" name="remind_time" class="Wdate ld-input-inner" style="width: 50%;margin-top: -3px" type="text" size="15" maxlength="25" onclick="WdatePicker({ldelim}startDate:'%H:%M',dateFmt:' HH:mm'{rdelim})" value="{$info.remind_time}">
                {/if}
            </td>
        </tr>
        {*提醒次数*}
        <tr class="ld-form-item">
            <td class="ld-form-item-label">{'ReminderFrequency'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <select class="ld-select-inner" style="width: 20%" id="remind_num" name="remind_num">
                    <option value="0" {if $info.remind_num eq '0'}selected{/if}>{'DontRemind'|@getFixedLabel}</option>
                    {for $num = 1 to 3}
                        <option value="{$num}" {if $info.remind_num eq $num}selected{/if}>{$num}{'TIMESNUM'|@getFixedLabel}</option>
                    {/for}
                </select>
            </td>
        </tr>
        {*提醒提前值*}
        <tr class="ld-form-item" name="remind_time_value_tr" {if $info.remind_num eq '0'}style="display: none" {/if}>
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content" colspan="3">
                <div style="display: flex">
                    {for $num = 1 to 3}
                        {if $num eq 1}
                            {assign var=timevalue value=$info.first_value}
                        {elseif $num eq 2}
                            {assign var=timevalue value=$info.second_value}
                        {else}
                            {assign var=timevalue value=$info.third_value}
                        {/if}
                        <div name="{$num}_value_div" {if $info.remind_num lt $num}style="display: none" {/if}>
{*                        <div name="first_value_div" {if $info.remind_num gt $num}style="display: none" {/if}>*}
                            <label >{'VARTIMES'|@getVarFixedLabel:$num}</label>&ensp;
                            <select class="ld-select-inner" style="width: 50px" id="{$num}_value" name="{$num}_value">
                                {if $reporttype eq 'day'}
                                    {for $tmpnum = 1 to 3}
                                        <option value="{$tmpnum}" {if $timevalue eq $tmpnum}selected{/if}>{$tmpnum}</option>
                                    {/for}
                                {else}
                                    {for $tmpnum = 0 to 3}
                                        <option value="{$tmpnum}" {if $timevalue eq $tmpnum}selected{/if}>{$tmpnum}</option>
                                    {/for}
                                {/if}
                            </select>&ensp;
                            <label>{$remind_time_str|@getFixedLabel}</label>&emsp;
                        </div>
                    {/for}
                </div>
            </td>
        </tr>
        {if $reporttype neq 'day'}
        {*提醒时间*}
        <tr class="ld-form-item" name="remind_time_tr" {if $info.remind_num eq '0'}style="display: none" {/if}>
            <td class="ld-form-item-label">{'REMINDTIMES'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <input id="remind_time" name="remind_time" class="Wdate ld-input-inner" style="width: 50%;" type="text" size="15" maxlength="25" onclick="WdatePicker({ldelim}startDate:'%H:%M',dateFmt:' HH:mm'{rdelim})" value="{$info.remind_time}">
{*                <select class="ld-select-inner" style="width: 34%" id="remind_time" name="remind_time">*}
{*                    {for $hour = 0 to 23}*}
{*                        {if $hour lt 10}*}
{*                            {assign var=time_value value='0'|cat:$hour|cat:":"|cat:'00:00'}*}
{*                        {else}*}
{*                            {assign var=time_value value=$hour|cat:":"|cat:'00:00'}*}
{*                        {/if}*}
{*                        <option value="{$time_value}" {if $info.remind_time eq $time_value}selected{/if}>{$hour}:00</option>*}
{*                    {/for}*}
{*                </select>*}
            </td>
        </tr>
        {/if}
        {*其他设置*}
        <tr>
            <td class="padT28 padB0" colspan="4">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'LBL_OTHER_SETTINGS'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        {*汇报日期*}
        <tr  class="ld-form-item" name="report_date_tr" >
            <td class="ld-form-item-label">{'WorkTemplateRuleReportDate'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <select class="ld-select-inner" style="width: 34%" name="report_date" id="report_date">
                    {foreach key=key item=label from=$reportDate}
                        <option value="{$key}" {if $info.report_date eq $key }selected{/if}>{$label}</option>
                    {/foreach}
                </select>
            </td>

        </tr>
        {if $reporttype eq 'day'}
        {*编辑时限*}
        <tr  class="ld-form-item" name="edit_date_tr" >
            <td class="ld-form-item-label">{'WorkTemplateRuleEditDate'|@getFixedLabel}</td>
            <td class="ld-form-item-content" colspan="3">
                <select class="ld-select-inner" style="width: 34%" name="edit_date" id="edit_date">
                    {foreach key=key item=label from=$editDate}
                        <option value="{$key}" {if $info.edit_date eq $key}selected{/if}>{$label}</option>
                    {/foreach}
                </select>
                <span>({'BasedOnReportDate'|@getFixedLabel})</span>
            </td>
        </tr>
        {/if}
        {*XUQIU1002237 工作汇报模板定制，增加“自动生成简报”参数（宋清华）wsh*}
        <tr class="ld-form-item" name="auto_gene_brief_tr">
            <td class="ld-form-item-label">{'AUTOGENERATEBRIEF'|@getFixedLabel}</td>
            <td name="auto_gene_brief_td" class="ld-form-item-content" colspan="3">
                <input id="auto_gene_brief_presence" name="auto_gene_brief_presence" changename="auto_gene_brief_set" class="second_switch" type="checkbox"{if $info.auto_generate_brief eq 'yes'}checked{/if}/>
                {*                <label style="color: #999">({'SetFixedReviewerTip'|@getFixedLabel})</label>*}
            </td>
        </tr>
    </table>
</div>