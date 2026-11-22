{*@edit:liushuai,2021-04-08,reason:【ID1001517】附件增加下载和预览次数及操作日志（操作日志弹出层）*}
<div class="ld-pop-container ld-table-container ld-table-container-lines">
    <input type="hidden" name="fileId" value="{$fileId}"/>
    <input type="hidden" name="frommodule" value="{$frommodule}"/>
    <input type="hidden" name="operating_type" value="{$operating_type}"/>
    <div class="padB16">
        <b>{'SELECTUSER'|@getFixedLabel} </b>
        <select id="selectOperator"  class="ld-select-inner width100" onchange="selectOperator(this)">
            <option value="">{'NONE'|@getFixedLabel}</option>
            {foreach key=userid item=username from=$operator_list}
                <option value="{$userid}">{$username}</option>
            {/foreach}
        </select>
    </div>
    <div class="divPopOverflow" name="file_operation_log_detail">
        {include file="FileOperationLogDetail.tpl"}
    </div>
</div>