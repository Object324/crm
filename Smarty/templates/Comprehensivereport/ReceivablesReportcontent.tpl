{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<div class="clear"></div>		
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="rptTable TableOften" id="CL_Detial2">
<tr >
    <th>合同编号</th>
    <th>合同主体</th>
    <th>客户/二代名称</th>
    <th>客户简称</th>
    <th>客户来源</th>
    <th>广告主名称</th>
    <th>投放媒体</th>
    <th>产品线</th>
    <th>应收款时间</th>
    <th>应收款金额</th>
    <th>已开票金额</th>
    <th>已回款金额</th>
    <th>应收未收回款项</th>
	 <th>上级合同</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$work.salesorder_no}</td>
    <td nowrap="nowrap">{$work.cf_1476}</td>
    <td nowrap="nowrap">{$work.accountname}</td>
    <td nowrap="nowrap">{$work.cf_1459}</td>
    <td nowrap="nowrap">{$work.cf_1469}</td>
    <td nowrap="nowrap">{$work.cf_1461}</td>
    <td nowrap="nowrap">{$work.productname}</td>
    <td nowrap="nowrap">{$work.productsheet}</td>
    <td nowrap="nowrap">{$work.cf_1518}</td>
    <td nowrap="nowrap">{$work.total}</td>
    <td nowrap="nowrap">{$work.total}</td>
    <td nowrap="nowrap">{$work.yishou}</td>
    <td nowrap="nowrap">{$work.weishou}</td>
	<td nowrap="nowrap">{$work.shangji}</td>
</tr>
{/foreach}
</table>
