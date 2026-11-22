
<form action="index.php" method="post" id="createflow" name="createflow" onsubmit="puyoungJS_DialogBox.block()">
    <input type="hidden" name="record" value="{$RECORD}"/>
    <input type="hidden" name="TemplateId" value="{$TemplateId}"/>

    <div id="" style="max-height: 450px;">
        <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <th colspan="4">
                    {'DYNAMICASSIGNMENT'|@getFixedLabel}
                </th>
            </tr>

            {*控件 开始*}
            {foreach item=Component key=key from=$Components}
                <tr>
                    <td align="right" width="100">
                        {if $Component.ComponentRequired eq true}<font color="red">*</font>{/if}
                        {$Component.ComponentNameLabel}
                    </td>
                    {if $Component.ComponentType eq 'TEXT'}
                        <td align="left">
                            <input id="Components[{$Component.ComponentName}]" name="Components[{$Component.ComponentName}]" class="detailedViewTextBox" value="{$Component.ComponentNameValue}" type="text" {if $Component.ComponentRequired eq true}required{/if}/>
                        </td>
                    {elseif $Component.ComponentType eq 'MULTI_LINE_TEXT'}
                        <td align="left">
                            <textarea id="Components[{$Component.ComponentName}]" name="Components[{$Component.ComponentName}]" class="detailedViewTextBox"  {if $Component.ComponentRequired eq true}required{/if}>{$Component.ComponentNameValue}</textarea>
                        </td>
                    {elseif $Component.ComponentType eq 'DATE'}
                        <td align="left" >
{*                            <input id="Components[{$Component.ComponentName}]" name="Components[{$Component.ComponentName}]" class="detailedViewTextBox" value="" type="datetime-local" {if $Component.ComponentRequired eq true}required{/if}/>*}
                            <input type="text" name="Components[{$Component.ComponentName}]" id="Components[{$Component.ComponentName}]" value="{$Component.ComponentNameValue}" {if $Component.ComponentRequired eq true}required{/if} class="Wdate Q_setTimeWdate" autocomplete="off" style="border:1px solid #dbdbdb;"
                                   size="25" maxlength="10" value="" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim});"/>
                        </td>
                    {else}
                        {*<td align="right" width="100">
                            模板类型
                        </td>
                        <td align="left">
                            <select id="pass" name="pass" class="btn-radius-system" onchange="passStatus(this,'{$BLOCKNAME}')">
                                <option value="1">静默签</option>
                                <option value="2">静默签授权</option>
                                <option value="3">普通模版</option>
                            </select>
                        </td>*}
                    {/if}

                </tr>
            {/foreach}

            <tr>
                <th colspan="4">
                    合同基本信息
                </th>
            </tr>
            <tr>
                <td align="right" width="100"><font color="red">*</font>合同名字</td>
                <td align="left" >
                    <input id="FlowName" name="FlowName" class="detailedViewTextBox" value="" type="text" required/>
                </td>
            </tr>

            <tr>
                <td align="right">合同描述</td>
                <td align="left">
                    <input id="FlowDescription" name="FlowDescription" class="detailedViewTextBox" value="" type="text"/>
                </td>
            </tr>

            <tr>
                <td align="right"><font color="red">*</font>签署截止时间</td>
                <td align="left">
{*                    <input id="Deadline" name="Deadline" class="detailedViewTextBox" value="" type="datetime-local" required/>*}
                    <input type="text" name="Deadline" id="Deadline" value="" required class="Wdate Q_setTimeWdate" autocomplete="off" style="border:1px solid #dbdbdb;"
                           size="25" maxlength="10" value="" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim});"/>
                </td>
            </tr>

            <tr>
                <td align="right">合同类型</td>
                <td align="left">
                    <select id="FlowType" name="FlowType" class="btn-radius-system width150">
                        {*注意:这里flowType 不是枚举,可以自定义*}
                        <option value="劳务">劳务</option>
                        <option value="销售">销售</option>
                        <option value="租赁">租赁</option>
                        <option value="其他" selected>其他</option>
                    </select>
                </td>
            </tr>


            {*【合同个人签署方】  签署人类型SignType为0时（或者公司名称没空），需要签署；需要企业经办人签署的从crm后台取当前登录用户的姓名、手机号*}
            <tr>
                <th colspan="4">
                    个人签署方
                </th>
            </tr>
            <tr>
                <td align="right"><font color="red">*</font>合同签署人姓名</td>
                <td align="left">
                    <input id="FlowApprovers[Name]" name="FlowApprovers[Name]" class="detailedViewTextBox" value="" type="text" required/>
                </td>
            </tr>
            <tr>
                <td align="right"><font color="red">*</font>合同签署人手机号</td>
                <td align="left">
                    <input id="FlowApprovers[Mobile]" name="FlowApprovers[Mobile]" class="detailedViewTextBox" value="" type="text" required/>
                </td>
            </tr>
            <tr>
                <td align="right">合同签署人截止日期(选填)</td>
                <td align="left">
{*                    <input id="FlowApprovers[Deadline]" name="FlowApprovers[Deadline]" class="detailedViewTextBox" value="" type="datetime-local"/>*}
                    <input type="text" name="FlowApprovers[Deadline]" id="FlowApprovers[Deadline]" value="" class="Wdate Q_setTimeWdate" autocomplete="off" style="border:1px solid #dbdbdb;"
                           size="25" maxlength="10" value="" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim});"/>
                </td>
            </tr>

        </table>
    </div>

</form>

