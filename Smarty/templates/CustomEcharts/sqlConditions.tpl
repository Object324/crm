<div id="searchList" style="display:none; {if $frommobile=='yes'}width:100%;{else}width:1000px;{/if}margin:0 auto;background-color: transparent;padding: 10px;box-shadow: 0px 1px 2px 2px rgb(0 0 0 / 10%);">
    <form id="SqlConditionsForm">
        <table border="0" cellspacing="0" cellpadding="0" class="{if $frommobile!='yes'}ld-createedit-tablecontent ld-public-content-paddingright{/if}" id="conditionColumnList" style="width: 100%; table-layout: fixed;">
            {foreach $sqlFilterArr as $filterGroup}
                <tr>
                    {foreach $filterGroup as $filterLine}
                        <td class="{if $frommobile!='yes'}ld-form-item-label{/if}" {if $frommobile=='yes'}style="width:60px;"{/if}>
                            <font color="red"></font>{$filterLine.display_name}
                        </td>
                        <td class="ld-form-item-content" var_type="{$filterLine.var_type}">
                            {*模糊查找*}
                            {if $filterLine.var_type=='string'}
                                <input class="ld-input-inner" type="text" name="sqlvar_{$filterLine.var_name}" id="sqlvar_{$filterLine.var_name}" value="{$filterLine.default_value_actual}">
                            {/if}
                            {if $filterLine.var_type=='number' }
                                <input class="ld-input-inner" type="number" name="sqlvar_{$filterLine.var_name}" id="sqlvar_{$filterLine.var_name}" value="{$filterLine.default_value_actual}">
                            {/if}
                            {if $filterLine.var_type=='date'}
                                <input readonly type="text" class="Wdate ld-input-inner" name="sqlvar_{$filterLine.var_name}" autocomplete="off" value="{$filterLine.default_value_actual}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd'{rdelim})">
                            {/if}
                            {if $filterLine.var_type=='datetime'}
                                <input readonly type="text" class="Wdate ld-input-inner" name="sqlvar_{$filterLine.var_name}" autocomplete="off" value="{$filterLine.default_value_actual}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})">
                            {/if}
                            {if $filterLine.var_type=='select'}
                                <select name="sqlvar_{$filterLine.var_name}" id="sqlvar_{$filterLine.var_name}" class="ld-select-inner" >
                                    {foreach item=select_value key=i from=$filterLine['select_values_arr']}
                                        <option {if $select_value==$filterLine['default_value']}selected{/if} value="{$select_value}">{$select_value}</option>
                                    {/foreach}
                                </select>
                            {/if}
                            {if $filterLine.var_type=='multiselect'}
                                <select name="sqlvar_{$filterLine.var_name}[]" id="sqlvar_{$filterLine.var_name}" multiple class="ld-select-inner  sqlvar-detail-selectmulti">
                                    {foreach item=select_value key=i from=$filterLine['select_values_arr']}
                                        <option {if in_array($select_value,$filterLine['default_values_arr']) }selected{/if} value="{$select_value}">{$select_value}</option>
                                    {/foreach}
                                </select>
                                <script>
                                    ld('#sqlvar_{$filterLine.var_name}').select2({ldelim}width:'100%',closeOnSelect: true{rdelim});
                                </script>
                            {/if}
                            {if $filterLine.var_type=='multiuser'}
                                {assign var=usefldlabel value=$filterLine.display_name}
                                {assign var=fldname value=$filterLine.var_name}
                                {assign var=MODULE value=$filterLine.modulename}
                                {assign var=secondvalue value=$filterLine.default_value}
                                {assign var=fldvalue value=$filterLine.usernames_str}
                                <div class="ld-input-inner-div" id="{$fldname}_name" name="{$fldname}_name" style="overflow: hidden;text-overflow: ellipsis;vertical-align: middle;display: inline-block;margin: 0;padding-right: 30px;max-height: 300px;">{$fldvalue}</div>
                                <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","sqlvar_{$fldname}","User","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","private")'>+</a>
                                <input type="hidden" value="{$secondvalue}" id="sqlvar_{$fldname}" name="sqlvar_{$fldname}" />
                            {/if}
                            {if $filterLine.var_type=='checkbox'}
                                <input type="checkbox" id="sqlvar_{$filterLine.var_name}" name="sqlvar_{$filterLine.var_name}">
                            {/if}
                            {*审批组件筛选条件*}
                            {if $filterLine.var_type=='approvestatus'}
                                <div class="home-header-approve-select approve-select" style="margin-top:0;">
                                    <input type="checkbox" id="sqlvar_{$filterLine.var_name}_unapproved" name="sqlvar_{$filterLine.var_name}[]" value="未提交" {if '未提交'|@in_array:$filterLine['approvestatus_default_value_arr']}checked{/if}><label for="sqlvar_{$filterLine.var_name}_unapproved">{'Unapproved'|getFixedLabel}</label>&nbsp;
                                    <input type="checkbox" id="sqlvar_{$filterLine.var_name}_approving" name="sqlvar_{$filterLine.var_name}[]" value="审批中" {if '审批中'|@in_array:$filterLine['approvestatus_default_value_arr']}checked{/if}><label for="sqlvar_{$filterLine.var_name}_approving">{'Approvalof'|getFixedLabel}&nbsp;</label>
                                    <input type="checkbox" id="sqlvar_{$filterLine.var_name}_approved" name="sqlvar_{$filterLine.var_name}[]" value="已批准" {if '已批准'|@in_array:$filterLine['approvestatus_default_value_arr']}checked{/if}><label for="sqlvar_{$filterLine.var_name}_approved">{'APPROVEDSUCCESS'|getFixedLabel} &nbsp;</label>
                                    <input type="checkbox" id="sqlvar_{$filterLine.var_name}_rejected" name="sqlvar_{$filterLine.var_name}[]" value="已拒绝" {if '已拒绝'|@in_array:$filterLine['approvestatus_default_value_arr']}checked{/if}><label for="sqlvar_{$filterLine.var_name}_rejected">{'Rejected'|getFixedLabel}&nbsp;</label>
                                    <input type="checkbox" id="sqlvar_{$filterLine.var_name}_dismissed" name="sqlvar_{$filterLine.var_name}[]" value="已驳回" {if '已驳回'|@in_array:$filterLine['approvestatus_default_value_arr']}checked{/if}><label for="sqlvar_{$filterLine.var_name}_dismissed">{'Dismissed'|getFixedLabel}&nbsp;</label>
                                </div>
                            {/if}
                        </td>
                    {/foreach}
                </tr>
            {/foreach}
        </table>
    </form>
</div>