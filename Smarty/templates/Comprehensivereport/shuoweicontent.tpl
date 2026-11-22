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
    <th>序号</th>
    <th>产品类型</th>
    <th>合同编号</th>
    <th>购买日</th>
    <th>到期日</th>
    <th>客户姓名</th>
    <th>手机</th>
    <th>身份证</th>
    <th>银行卡</th>
    <th>开户行</th>
    <th>销售人员</th>
    <th>付息方式</th>
    <th>投标天数</th>
    <th>投标时常（单位：月）</th>
    <th>利率</th>
    <th>购入金额（单位：元）</th>
    <th>期次</th>
    <th>到期日</th>
    <th>计息天数</th>
    <th>利息（单位：元）</th>
    <th>操作</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$smarty.foreach.resultswork.iteration}</td>
    <td nowrap="nowrap">{$work.productcategory}</td>
    <td nowrap="nowrap">{$work.salesorder_no}</td>
    <td nowrap="nowrap">{$work.createdtime}</td>
    <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap">{$work.accountname}</td>
    <td nowrap="nowrap">{$work.cf_1501}</td>
    <td nowrap="nowrap">{$work.cf_1483}</td>
    <td nowrap="nowrap">{$work.cf_1517}</td>
    <td nowrap="nowrap">{$work.cf_1515}</td>
    <td nowrap="nowrap">{$work.last_name}</td>
    <td nowrap="nowrap">{$work.cf_1546}</td>
    <td nowrap="nowrap">{$work.allcount}</td>
    <td nowrap="nowrap">{$work.qici}</td>
    <td nowrap="nowrap">{$work.cf_1550}</td>
    <td nowrap="nowrap">{$work.total}</td>
    <td nowrap="nowrap">{$work.seq}</td>
    <td nowrap="nowrap">{$work.day}</td>
    <td nowrap="nowrap">{$work.count}</td>
    <td nowrap="nowrap">{$work.value}</td>
    {if $work.paixi neq 1}
    <td nowrap="nowrap">
    <div id="{$smarty.foreach.resultswork.iteration}">
    <input class="createauto b_radius3" id="btnOK_E" onclick="paixi_dividend('{$work.salesorderid}','{$work.seq}','{$work.day}','{$work.value}',{$smarty.foreach.resultswork.iteration});" type="button" value="派息" />
    </div>
    </td>
    {else}
    <td nowrap="nowrap"></td>
    {/if}
</tr>
{/foreach}
</table>
