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

<!--分页-->
<!--div class="Paging_div Paging_divBjtop">
<table class="tabPaddingUp" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td class="R">
    	<div class="PageDiv0">
        	<ul>
            	<li>{$recordListRange}</li>
                {$NAVIGATION}
            </ul>
        </div>
    </td>
  </tr>
</table>
</div-->
<!--分页  end-->
<div class="clear"></div>		
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="rptTable TableOften" id="CL_Detial2">
    <tr>
    <th rowspan="2">时间（签约时间）</th>
    <th rowspan="2">业务员</th>
    <th rowspan="2">个人签约额</th>
    <th colspan="3" style="text-align:center;">个人工资提成</th>
    <th colspan="3" style="text-align:center;">团队提成</th>
    <th rowspan="2">总工资</th>
    </tr>
    <tr>
    <th class="borderT">基本工资</th>
    <th class="borderT">提成工资</th>
    <th class="borderT">工资合计</th>
    <th class="borderT">全组签约额</th>
    <th class="borderT">组长提成比例</th>
    <th class="borderT">提成额</th>
    </tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$work.SalesOrder_signed_data}</td>
    <td nowrap="nowrap">{$work.Users_last_name}</td>
    <td nowrap="nowrap">{$work.SalesOrder_total}</td>
    <td nowrap="nowrap">{$work.SalesOrder_jibengz}</td>
    <td nowrap="nowrap">{$work.tichenggz}</td>
    <td nowrap="nowrap">{$work.gzhj}</td>
    <td nowrap="nowrap">{$work.qzgz}</td>
    <td nowrap="nowrap">{$work.gzbl}</td>
    <td nowrap="nowrap" align="right">{$work.qztc}</td>
    <td nowrap="nowrap">{$work.zgz}</td>
</tr>
{/foreach}
</table>
