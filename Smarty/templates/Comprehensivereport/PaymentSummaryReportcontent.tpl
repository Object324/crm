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
    <th>销售负责人</th>
    <th>合同订单号</th>
    <th>客户编码</th>
    <th>客户名称</th>
	<th>归属团队</th>
	<th>理财产品</th>
	<th>隶属</th>
	<th>代持人</th>
    <th>进款日期</th>
    <th>进款金额</th>
    <th>项目名称</th>
    <th>年化利率</th>
    <th>还款方式</th>
    <th>项目启动日期</th>
    <th>本金到期日</th>
    <th>应付本金</th>
    <th>还款方式</th>
    <th>应付利息</th>
    <th>已付利息</th>
    <th>未付利息</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$work.cf_1523}</td>
    <td nowrap="nowrap">{$work.salesorder_no}</td>
    <td nowrap="nowrap">{$work.account_no}</td>
    <td nowrap="nowrap">{$work.accountname}</td>
	<td nowrap="nowrap">{$work.cf_1539}</td>
	<td nowrap="nowrap">{$work.cf_1541}</td>
	<td nowrap="nowrap">{$work.cf_1540}</td>
	<td nowrap="nowrap">{$work.cf_1542}</td>
    <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap">{$work.cf_1519|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1522}</td>
    <td nowrap="nowrap">{$work.cf_1501}</td>
    <td nowrap="nowrap">{$work.cf_1502}</td>
    <td nowrap="nowrap">{$work.duedate}</td>
    <td nowrap="nowrap">{$work.cf_1499}</td>
    <td nowrap="nowrap">{$work.yingfubenjin|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1503}</td>
    <td nowrap="nowrap">{$work.yingfulixi|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.yifulixi|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.weifulixi|@setNumberFormat:2}</td>
</tr>
{/foreach}
</table>
