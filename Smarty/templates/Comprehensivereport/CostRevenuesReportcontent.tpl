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
    <th>采购订单编号</th>
    <th>合同主体</th>
    <th>客户来源</th>
    <th>客户类型</th>
    <th>客户/二代名称</th>
    <th>广告主名称</th>
    <th>客户所属行业</th>
    <th>投放媒体</th>
    <th>产品线</th>
    <th>月份</th>
    <th>媒体后台到账金额</th>
    <th>客户配送（结算）比例</th>
    <th>客户折扣比例</th>
    <th>客户结算金额</th>
    <th>媒体配送比例</th>
    <th>媒体折扣比例</th>
    <th>媒体付款金额</th>
    <th>服务费金额</th>
    <th>收入</th>
    <th>成本</th>
    <th>利润</th>
	<th>上级合同</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$work.cf_1529}</td>
    <td nowrap="nowrap">{$work.purchaseorder_no}</td>
    <td nowrap="nowrap">{$work.cf_1476}</td>
    <td nowrap="nowrap">{$work.cf_1469}</td>
    <td nowrap="nowrap">{$work.carrier}</td>
    <td nowrap="nowrap">{$work.accountname}</td>
    <td nowrap="nowrap">{$work.cf_1461}</td>
    <td nowrap="nowrap">{$work.cf_1467}</td>
    <td nowrap="nowrap">{$work.productname}</td>
    <td nowrap="nowrap">{$work.productsheet}</td>
    <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap">{$work.sf7}</td>
    <td nowrap="nowrap">{$work.sf727}</td>
    <td nowrap="nowrap">{$work.sf805}</td>
    <td nowrap="nowrap">{$work.carrier2}</td>
    <td nowrap="nowrap">{$work.sf963}</td>
    <td nowrap="nowrap">{$work.sf1042}</td>
    <td nowrap="nowrap">{$work.taxprice}</td>
    <td nowrap="nowrap">{$work.sf5}</td>    
    <td nowrap="nowrap">{$work.shouru}</td>
    <td nowrap="nowrap">{$work.taxprice}</td>
    <td nowrap="nowrap">{$work.lirun}</td>
	<td nowrap="nowrap">{$work.shangji}</td>
</tr>
{/foreach}
</table>
