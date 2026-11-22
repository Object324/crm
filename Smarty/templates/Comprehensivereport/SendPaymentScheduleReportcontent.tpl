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
    <th>合同订单号</th>
    <th>负责人</th>
    <th>供应商编码</th>
    <th>供应商名称</th>
    <th>主要联系人</th>
    <th>付款日期</th>
    <th>本金金额</th>
    <th>年化利率</th>
    <th>项目启动日期</th>
    <th>本金到期日</th>
    <th>还款方式</th>
    <th>付息形式</th>
    <th>项目名称</th>
    <th>期次</th>
    <th>预计收款日</th>
    <th>应收利息</th>
    <th>收息状态</th>
    <th>应收本金</th>
    <th>本金状态</th>
    <th>摘要</th>
    <th>操作</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$work.purchaseorder_no}</td>
    <td nowrap="nowrap">{$work.cf_1528}</td>
    <td nowrap="nowrap">{$work.vendor_no}</td>
    <td nowrap="nowrap">{$work.vendorname}</td>
    <td nowrap="nowrap">{$work.lastname}</td>
    <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap">{if $work.cf_1510 neq ''}{$work.cf_1510|@setNumberFormat:2}{/if}</td>
    <td nowrap="nowrap">{$work.cf_1512}</td>
    <td nowrap="nowrap">{$work.cf_1509}</td>
    <td nowrap="nowrap">{$work.cf_1511}</td>
    <td nowrap="nowrap">{$work.cf_1516}</td>
    <td nowrap="nowrap">{$work.cf_1515}</td>
    <td nowrap="nowrap">{$work.cf_1527}</td>
    <td nowrap="nowrap">{$work.seq}</td>
    <td nowrap="nowrap">
        <div id="{$smarty.foreach.resultswork.iteration}_time_show">{$work.day}</div>
        <div id="{$smarty.foreach.resultswork.iteration}_time_edit" style="display: none;">
            <input class="input_text" id="time_{$smarty.foreach.resultswork.iteration}" name="day" value="" type="text" />
       </div>
    </td>
    <td nowrap="nowrap">{$work.yingfulixi|@setNumberFormat:2}</td>
    <td nowrap="nowrap">
        <div id="{$smarty.foreach.resultswork.iteration}_paixi_show">{if $work.paixi eq 1}是{else}否{/if}</div>
        <div id="{$smarty.foreach.resultswork.iteration}_paixi_edit" style="display: none;">
            <input class="input_text" id="paixi_{$smarty.foreach.resultswork.iteration}" name="day" value="" type="text" />
        </div>
    </td>
    <td nowrap="nowrap">{$work.yingfubenjin|@setNumberFormat:2}</td>
    <td nowrap="nowrap">
        <div id="{$smarty.foreach.resultswork.iteration}_benjin_show">{if $work.benjinstatus eq 1}是{else}否{/if}</div>
        <div id="{$smarty.foreach.resultswork.iteration}_benjin_edit" style="display: none;">
            <input class="input_text" id="benjin_{$smarty.foreach.resultswork.iteration}" name="day" value="" type="text" />
            <input class="createauto b_radius3" id="btnOK_E" onclick="Save_SendpaymentSchedule({$smarty.foreach.resultswork.iteration},{$work.purchaseorderid},{$work.seq},{$work.yingfulixi})" type="button" value="保存" />
            <input class="createauto b_radius3" id="btnOK_E" onclick="edit_paymentSchedule({$smarty.foreach.resultswork.iteration},2);" type="button" value="取消" /> 
        </div>
    </td>
    <td nowrap="nowrap">{$work.cf_1526}</td>
    {if $work.purchaseorder_no neq '小计'&& $work.purchaseorder_no neq '合计'}
    <td nowrap="nowrap">
    <div id="{$smarty.foreach.resultswork.iteration}">
    <input class="createauto b_radius3" id="btnOK_E" onclick="edit_paymentSchedule({$smarty.foreach.resultswork.iteration},1);" type="button" value="编辑" />
    {if $work.benjinstatus eq 1 && $work.typetiqian neq 1}
        <input class="createauto b_radius3" id="btnOK_E" onclick="tiqian_SendpaymentSchedule({$smarty.foreach.resultswork.iteration},{$work.purchaseorderid},{$work.seq})" type="button" value="提前还款" />
    {/if}
    </div>
    </td>
    {else}
    <td nowrap="nowrap"></td>
    {/if}
</tr>
{/foreach}
</table>
