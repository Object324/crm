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
    <th>订单号</th>
    <th>供应商编码</th>
    <th>供应商名称</th>
    <th>付款日期</th>
    <th>付款金额</th>
    <th>项目名称</th>
    <th>年化利率</th>
    <th>还款方式</th>
    <th>项目启动日期</th>
    <th>本金到期日</th>
    <th>应收本金</th>
    <th>付息形式</th>
    <th>应收利息</th>
    <th>已收利息</th>
    <th>未收利息</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$work.cf_1528}</td>
    <td nowrap="nowrap">{$work.purchaseorder_no}</td>
    <td nowrap="nowrap">{$work.vendor_no}</td>
    <td nowrap="nowrap">{$work.vendorname}</td>
    <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap">{$work.cf_1510|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1527}</td>
    <td nowrap="nowrap">{$work.cf_1512}</td>
    <td nowrap="nowrap">{$work.cf_1516}</td>
    <td nowrap="nowrap">{$work.cf_1509}</td>
    <td nowrap="nowrap">{$work.cf_1511}</td>
    <td nowrap="nowrap">{$work.yingfubenjin|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.cf_1515}</td>
    <td nowrap="nowrap">{$work.yingfulixi|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.yifulixi|@setNumberFormat:2}</td>
    <td nowrap="nowrap">{$work.weifulixi|@setNumberFormat:2}</td>
</tr>
{/foreach}
</table>
