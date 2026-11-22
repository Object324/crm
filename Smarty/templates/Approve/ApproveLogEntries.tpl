<div>
    <table id="approve_log_table" width="100%" class="applovelistdata" cellspacing="1" cellpadding="0" border="0">
    <tr>
        {*editor:gyq_05 reason:div宽度调整 date:2016 3 14*}
        <th style="width:3%;text-align: center;">#</th>
        <th title="{'OPERATING'|@getFixedLabel}" style="width: 10%">{'OPERATING'|@getFixedLabel}</th>
        <th title="{'APPROVALSTEP'|@getFixedLabel}" style="width: 10%">{'APPROVALSTEP'|@getFixedLabel}</th>
        <th title="{'operatoroer'|@getFixedLabel}" style="width: 10%">{'operatoroer'|@getFixedLabel}</th>
        <th title="{'APPROVALRESULT'|@getFixedLabel}" style="width: 15%">{'APPROVALRESULT'|@getFixedLabel}</th>
        <th title="{'NEXTOPERATOR'|@getFixedLabel}" style="width: 15%">{'NEXTOPERATOR'|@getFixedLabel}</th>
{*        @edit:liushuai 20200715 @reason: 审批中心查询优化：单据详情界面“审批日志”，“下一步处理人”右边增加列“下一审批步骤”*}
        <th title="{'NEXTSTEPNAME'|@getFixedLabel}" style="width: 10%">{'NEXTSTEPNAME'|@getFixedLabel}</th>
        <!--edit:chj,date:2020-07-13,reason:审批意见增加手写签名功能-->
		{if $AUTOGRAPH eq 1}
			<th title="{'REMARK'|@getFixedLabel}" style="width: 12%">{'APPROVALSUGGESTION'|@getFixedLabel}</th>
			<th title="{'handwriting'|@getFixedLabel}" style="width: 10%">{'handwriting'|@getFixedLabel}</th>
		{else}
			<th title="{'REMARK'|@getFixedLabel}" style="width: 22%">{'APPROVALSUGGESTION'|@getFixedLabel}</th>
		{/if}
        <th title="{'operatoroertime'|@getFixedLabel}" style="width: 15%">{'operatoroertime'|@getFixedLabel}</th>
    </tr>
    {assign var=approvenum value=$APPROVE|@count}
    {foreach item=approve name=loop key=index from=$APPROVE}
    <tr bgcolor="white">
        <td align="center">{$approvenum}</td>
        <td title="{$approve.OPERATE}">{$approve.OPERATE}</td>
        <td title="{$approve.STEPNAME}">{$approve.STEPNAME}</td>
        {if $iskehu001 eq 'yes'}
            <td>{$approve.OPERATOR}</td>
        {else}
            <td title="{$approve.OPERATOR}">{$approve.OPERATOR}</td>
        {/if}
        <td title="{$approve.APPROVERESULT}">{$approve.APPROVERESULT}</td>
        {if $iskehu001 eq 'yes'}
            <td>{$approve.NEXTSTEPBYNAME}</td>  
        {else}
            <td title="{$approve.NEXTSTEPBYNAME}">{$approve.NEXTSTEPBYNAME}</td>  
        {/if}
        {if $iskehu001 eq 'yes'}
            <td>{$approve.NEXTSTEPNAME}</td>
        {else}
            <td title="{$approve.NEXTSTEPNAME}">{$approve.NEXTSTEPNAME}</td>
        {/if}
        <td title="{$approve.DESCRIPTION}" style="{if $approve.BACKUP eq 'YES'}color:red;{else}color:#428bca;{/if}">{$approve.DESCRIPTION}</td>
		{if $AUTOGRAPH eq 1}
			<td>
                {if $approve.APPROVEAUTOGRAPHPATH neq ''}
                    <img id="{$approve.APPROVEID}_img" style='cursor:pointer;width:100%;height:100px;' onclick="previewImage(document.getElementById({$approve.APPROVEID}_img))" border=0 src='{$approve.APPROVEAUTOGRAPHPATH}'>        
                {/if}
            </td>
		{/if}
        <td nowrap="nowrap" title="{$approve.CREATEDTIME}">{$approve.CREATEDTIME}</td>
    </tr>
    {assign var=approvenum value=$approvenum-1}
    {/foreach}
    </table>
</div>
<script>
    // 使用listview.js中的previewImage函数 展示图片
    ld(function(){
        var images= ld('#approve_log_table img');
        if(images.length>0){
            ld.each(images,function (i,val) {
                // 使用previewImage函数 需要提前加载加载事件。要不会出现第一次点击不能弹出
                previewImage(val);
            })
        }
    })
</script>