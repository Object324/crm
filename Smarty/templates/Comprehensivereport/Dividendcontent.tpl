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
<tr >
    <th>序号</th>
    <th>合同号</th>
    <th>投资人</th>
    <th>身份证号</th>
    <th>开户银行</th>
    <th>卡号</th>
    <th>联系手机</th>
    <th>理财经理</th>
    <th>投资金额</br>（万元）</th>
    <th>利率</th>
    <th>投资期限（月）</th>
    <th>起始日</th>
    <th>第一个月</br>到期日</th>
    <th>第一个月</br>计息天数</th>
    <th>应计利息</br>（元）</th>
    <th>第二个月</br>到期日</th>
    <th>第二个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第三个月</br>到期日</th>
    <th>第三个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第四个月</br>到期日</th>
    <th>第四个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第五个月</br>到期日</th>
    <th>第五个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第六个月</br>到期日</th>
    <th>第六个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第七个月</br>到期日</th>
    <th>第七个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第八个月</br>到期日</th>
    <th>第八个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第九个月</br>到期日</th>
    <th>第九个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第十个月</br>到期日</th>
    <th>第十个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第十一个月</br>到期日</th>
    <th>第十一个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>第十二个月</br>到期日</th>
    <th>第十二个月</br>计算天数</th>
    <th>应计利息</br>（元）</th>
    <th>总计利息</br>（元）</th>
</tr>
{foreach key=results name=resultswork item=work from=$listValue}
{if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
<tr bgcolor="white" class="lvtColDataBj Hover" >
{else}
<tr bgcolor="white" class="Hover">
{/if}
    <td nowrap="nowrap">{$smarty.foreach.resultswork.iteration}</td>
    <td nowrap="nowrap">{$work.salesorder_no}</td>
    <td nowrap="nowrap" bgcolor='99CCFF'>{$work.accountname}</td>
    <td nowrap="nowrap">{$work.shengfenzheng}</td>
    <td nowrap="nowrap">{$work.kaihuyinghang}</td>
    <td nowrap="nowrap">{$work.subject}</td>
    <td nowrap="nowrap">{$work.lianxishouji}</td>
    <td nowrap="nowrap">{$work.last_name}</td>
    <td nowrap="nowrap" align="right">{$work.total|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.sf_5}</td>
    <td nowrap="nowrap">{$work.sf_4}</td>
    <td nowrap="nowrap">{$work.signed_data}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.one_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.one_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.one_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.two_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.two_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.two_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.three_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.three_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.three_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.four_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.four_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.four_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.five_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.five_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.five_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.six_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.six_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.six_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.seven_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.seven_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.seven_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.eight_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.eight_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.eight_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.nine_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.nine_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.nine_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.ten_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.ten_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.ten_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.eleven_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.eleven_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.eleven_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.twelve_day}</td>
    <td nowrap="nowrap" bgcolor="FFFF99">{$work.twelve_count}</td>
    <td nowrap="nowrap" align="right" bgcolor="CCFFCC">{$work.twelve_lixi|@setNumberFormat}</td>
    <td nowrap="nowrap" align="right" bgcolor="FFC06F">{$work.subtotal|@setNumberFormat}</td>
</tr>
{/foreach}
</table>
