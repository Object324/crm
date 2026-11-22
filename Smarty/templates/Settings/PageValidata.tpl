{*
<div class="DivCName DivCNamehover">{'BASICINFO'|@getFixedLabel}<span class=""></span> </div>
*}
<table class="ld-createedit-tablecontent padTB10" cellspacing="0" cellpadding="0" border="0" width="100%">
    <tr class="ld-form-item">
        <td class="ld-form-item-label"><font color="red">*</font>{'RULENAME'|@getFixedLabel}</td>
        <td class="ld-form-item-content" colspan="2"><input type="text" name="rulename" value="{$rulename}" class="ld-input-inner gwidth90"></td>
    </tr>
    <tr class="ld-form-item">
        <td class="ld-form-item-label"><font color="red">*</font>{'ValidationArea'|@getFixedLabel}</td>
        <td class="ld-form-item-content">
            <select class="ld-select-inner width100" name="relatedtable">
                <option value="ld_field" selected >{'BillHeader'|@getFixedLabel}</option>
                {if $detailtype eq 'product'}
                    <option value="ld_producttoolfield">{'DOCUMENTENTRY'|@getFixedLabel}</option>
                {else if $detailtype eq 'detail'}
                    <option value="ld_tabdetailfield">{'DOCUMENTENTRY'|@getFixedLabel}</option>
                {/if}
            </select>
        </td>
        <td class="ld-form-item-label" style="padding-left: 0;width: 300px;">
            {'ACTIVATE'|@getFixedLabel}
            {*wym 240206 BUG20240201-28 工作流程定制--列表、新增、编辑界面的“状态”字段名修改为：“启用”*}
            {* <select class="ld-select-inner" name="status" style="margin:0 5px;" >
            {foreach key=tmp_status item=label from=$status_arr }
                <option value="{$tmp_status}" {if $tmp_status eq $status}selected{/if}>{$label}</option>
            {/foreach}
            </select> *}
            <input name="status" value="{$status}" {if $status eq 'active'}checked=""{/if} type="checkbox" class="second_switch" style="margin-left: 10px;">
        </td>
    </tr>

    <tr class="ld-form-item">
        {if $fromtype eq 'advance'}
            <td class="ld-form-item-label" style="width: 250px;" >
                {'BLOCKEDAFTERPROMPT'|@getFixedLabel}
            </td>
            <td class='ld-form-item-content select-input' ><input type="checkbox" name="actionprevent" value="yes" {if $actionprevent eq 'yes'}checked{/if} class="second_switch" style="margin-left: 10px;"></td>
            <td><input style="display:none;" type='checkbox' name='advance_self' id='advance_self' checked ></td>
        {else}
            <td class="ld-form-item-label">{'ApplicationScenarios'|@getFixedLabel}</td>
            <td class='ld-form-item-content select-input'  >
                {if $fromtype eq 'advance'}
                    <input style="display:none;" type='checkbox' name='advance_self' id='advance_self' checked ><label class='padR10' for='advance_self'>{'ADVANCE'|@getFixedLabel}</label>
                {else}
                    {foreach from=$application_arr key=opreate item=label}
                        <input type='checkbox' name='{$opreate}' id='{$opreate}' {if $opreate|@in_array:$choose_application_arr}checked{/if}><label class='padR10' for='{$opreate}'>{$label}</label>
                    {/foreach}
                {/if}

            </td>
            <td class="ld-form-item-label" style="padding-left: 0;width: 300px;">
                {'BLOCKEDAFTERPROMPT'|@getFixedLabel}
                <input type="checkbox" name="actionprevent" value="yes" {if $actionprevent eq 'yes'}checked{/if} class="second_switch" style="margin-left: 10px;">
            </td>
        {/if}


    </tr>

    <tr class="ld-form-item">
        <td class="ld-form-item-label"><font color="red">*</font>{'TipMsg'|@getFixedLabel}(ZH)</td>
        <td class="ld-form-item-content" colspan="2">
            <select class="ld-select-inner width100" name="tipzhtype" style="float: left;margin-right: 10px;">
            {foreach key=tmp_key item=tmp_label from=$tiptypearr }
                <option value="{$tmp_key}" {if $tmp_key eq $tipzhtype}selected{/if}>{$tmp_label}</option>
            {/foreach}
            </select>
            <textarea class="ld-textarea-inner" name="tipzh" style="resize: none !important;width: calc(90% - 120px);">{$tipzh}</textarea>
        </td>
    </tr>
    <tr class="ld-form-item">
        <td class="ld-form-item-label"><font color="red">*</font>{'TipMsg'|@getFixedLabel}(EN)</td>
        <td class="ld-form-item-content" colspan="2">
            <select class="ld-select-inner width100" name="tipentype" style="float: left;margin-right: 10px;">
            {foreach key=tmp_key item=tmp_label from=$tiptypearr }
                <option value="{$tmp_key}" {if $tmp_key eq $tipentype}selected{/if}>{$tmp_label}</option>
            {/foreach}
            </select>
            <textarea class="ld-textarea-inner" name="tipen" style="resize: none !important;width: calc(90% - 120px);">{$tipen}</textarea>
        </td>
    </tr>
</table>
{*wym BUG0076750 后台设置--模块管理--页面设置--验证规则--添加组合规则右侧没有间距*}
<div class="DivCName DivCNamehover">{'VERIFICATIONCONDI'|@getFixedLabel}
    <select class="ld-select-inner commonSelectPop" style="margin-left: 5px;width: 200px;" name="effectivemethod">
        {foreach key=value item=effectivemethod_label from=$effectivemethod_content}
            <option value="{$value}" {if $effectivemethod eq $value}selected{/if}>{$effectivemethod_label}</option>
        {/foreach}
    </select>
    <div style="float: right;padding-right: 10px;"><input type="button" class="ld-button ld-button-primary" style="margin-right: 0px;" value="{'NEWCOMBINATION'|@getFixedLabel}" onclick="cls_validatacondition.getInstance().New_addNewConditionGroup();"></div> </div>

<div name="valiadvance" id="valiadvance">
    <table class="settingPopTable NewApprovePopTable"  cellspacing="1" cellpadding="0" border="0" width="100%">
    <tr>
        <td style="width: 13%;text-align:center"></td>
        <td style="width: 25%;text-align:center" tagname="selectfield">{'Select_field'|@getFixedLabel}</td>
        <td style="width: 15%;text-align:center">{'ComparatorRelationShip'|@getFixedLabel}</td>
        <td style="width: 13%;text-align:center"></td>
        <td style="width: 25%;text-align:center" tagname="comparefield" >{'CompareFields'|@getFixedLabel}</td>
        <td style="width: 6%;text-align:center"></td>
        <td style="width: 3%;text-align:center"></td>     
    </tr>
    
    </table>
</div>
<div>
    <div name="showsqlwildcard" style="line-height: 26px;" ><b id="showsqlwildcard" style="margin:0 5px;" data-status="hidden" data-childid="sqlwildcard" onclick="" title="{'EXPANDCOLLAPSE'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>{'INSTRUCTIONSWILDCARDCHARACTERS'|@getFixedLabel}</div>
    <div id="sqlwildcard" style="padding:5px;display: none;" >
        <div style="line-height: 22px;">1.{'CURRENTDOCUMENTFIELDS'|@getFixedLabel}:{ldelim}tablename.fieldname{rdelim}</div>
        <div style="line-height: 22px;">2.{'CURRENTDOCUMENTID'|@getFixedLabel}:{ldelim}Record.ID{rdelim},{'NOVALUEWHENCREATING'|@getFixedLabel}</div>
        <div style="line-height: 22px;">3.{'LINENUMBERMESSAGE'|@getFixedLabel}:{ldelim}line{rdelim}</div>
        <div style="line-height: 22px;">4.{'CURROPERATOR'|@getFixedLabel}:{ldelim}uuid{rdelim}</div>
        <div style="line-height: 22px;">5.{'QUERYRESULTRENAMED'|@getFixedLabel}</div>
        <div style="line-height: 22px;">6.{'PRODUCTSENTRYFIELD'|@getFixedLabel}</div>
    </div>
</div>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/cls_validatacondition.js"></script>