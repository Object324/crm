<div class="DivCName DivCNamehover" onclick="showHideStatus('serviceinformation','aidserviceinformation');">
	<span class="{$arrawcls}" id="aidserviceinformation" name="aidserviceinformation"></span>{'SERVICEINFORMATION'|@getFixedLabel}
</div>
<div id="serviceinformation" name="serviceinformation" class="DivCNotice ld-shadow-first" style="width: auto; display: block;">
<table border=0 cellspacing=0 cellpadding=0 width="100%" class="DetailContentTable">
{if $CONTENT neq ''}
<tr>{*gettranslabelfields  getFixedLabel('NOTFOUNDANYRECORD')*}
    <td width=15% class="DetailedTd2Info tip-items-list" align="left" data-tip="{'Products'|@gettranslabelfields:'productname'}" data-direction="top" data-type="position">{'Products'|@gettranslabelfields:'productname'}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{'Products'|@gettranslabelfields:'product_no'}" data-direction="top" data-type="position">{'Products'|@gettranslabelfields:'product_no'}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{'PERIODOFSERVICEEND'|@getFixedLabel}" data-direction="top" data-type="position">{'PERIODOFSERVICEEND'|@getFixedLabel}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{'ServiceContracts'|@gettranslabelfields:'contract_no'}" data-direction="top" data-type="position">{'ServiceContracts'|@gettranslabelfields:'contract_no'}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{'ServiceContracts'|@gettranslabelfields:'due_date'}" data-direction="top" data-type="position">{'ServiceContracts'|@gettranslabelfields:'due_date'}</td>
    <td width=25% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{'REMARK'|@getFixedLabel}" data-direction="top" data-type="position">{'REMARK'|@getFixedLabel}</td>
</tr>
{/if}
{foreach item=value from=$CONTENT} 
<tr>
    <td width=15% class="DetailedTd2Info tip-items-list" align="left" data-tip="{$value.productname|@strip_tags}" data-direction="top" data-type="position">{$value.productname}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{$value.product_no}" data-direction="top" data-type="position">{$value.product_no}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{$value.servicecontracts_end_date}" data-direction="top" data-type="position">{$value.servicecontracts_end_date}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{$value.contract_no}" data-direction="top" data-type="position">{$value.contract_no}</td>
    <td width=15% class="DetailedTd2Info borderL tip-items-list" align="left" data-tip="{$value.due_date}" data-direction="top" data-type="position">{$value.due_date}</td>
    <td width=15% class="DetailedTd2Info lineheight20 borderL tip-items-list" align="left" data-tip="{$value.description}" data-direction="top" data-type="position">{$value.description}</td>
</tr>
{foreachelse}
<tr>
    <td width=15% class="DetailedTd2Info" style="padding-left: 5px;color: #666;font-size: 13px;" align="left" colspan="6">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
</tr>
{/foreach}
</table>
</div>