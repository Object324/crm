{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js"></script>
<!--修改编码格式:统一编码：UTF-8-->
    <div id="status" style="position:absolute;display:none;left:850px;top:95px;height:27px;white-space:nowrap;"></div>
    <form style="display:block; width:100%; padding:10px 0px 0px 0px;" class="frmUseReportSearch" name="advSearch" method="post" action="index.php" onSubmit="return callSearch('Advanced');">
        <table cellpadding="0" cellspacing="0" >
            <tr>
                
                <td><span style="float:left; padding:5px 5px 0px 10px;">统计时间：</span>
                    <input style="float:left;" type='text' size=15 readonly=true value='{$startdatemonth}' id='startmonth' name='startmonth' findcolumn= 'ld_paymentplan:plandate:plandate:PaymentPlan_plandate:D' onClick='WdatePicker()' class='Wdate'/> 
                    <!--<img style="float:left; padding:0px 0px 0px 5px;"  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img1' onclick='showCalendar("startmonth","%Y-%m-%d","true","12",this)'/>-->
                </td>
                <td><span style="float:left; padding:2px 5px 0px 10px;">&nbsp;</span>
                    <input style="float:left;" type='text' size=15  readonly=true value='{$enddatemonth}' id='endmonth' name='endmonth' findcolumn= 'ld_paymentplan:plandate:plandate:PaymentPlan_plandate:D' onClick='WdatePicker()' class='Wdate'/> 
                    <!--<img style="float:left; padding:1px 0px 0px 5px;" class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img1' onclick='showCalendar("endmonth","%Y-%m-%d","true","12",this)'/>-->
                </td>
                <td >
                    &nbsp;&nbsp;&nbsp;&nbsp;软件版本：
                              <select style="margin-top:1px;width:80px" name='cversion' id="cversion">
                                    <option value="全部">全部</option>
                                    <option value="jichu">销售通</option>
                                    <option value="biaozhun">标准版</option>
                                    <option value="crm">企业版</option>
                                </select>
                
                </td>
                <td>
                    &nbsp;&nbsp;&nbsp;&nbsp;所在城市：  
                                <select style="margin-top:1px;width:80px" name='city' id="city">
                                    <option value="全部">全部</option>
                                    {foreach item=detail from=$result_city}
                                        <option value="{$detail.Ctitle}">{$detail.Ctitle}</option>
                                    {/foreach}
                                </select>
                
                </td>
                <td>
                    <span style="float:left; padding:5px 5px 0px 10px;">手机号码：</span>
                    <input style="float:left;height:14px" type='text' size=10  value='' id='phone' name='phone' >
        		<td class="small" nowrap >
     			    &nbsp;&nbsp;&nbsp;<input name="submit" type="button" onclick="UserAnalySisSearch(this,'BasicSearch')" class="create"  value=" 立即查找 ">&nbsp;		  
        		</td>
                <td class="small" nowrap >
                    <input type="hidden" name="searchtype" value="BasicSearch">
                    <input type="hidden" id="receiverid" name="receiverid"/>
		            <input type="hidden" name="search_cnt">
                    <input  type="hidden" name="UseReport" value="4"/>
                    <input  type="hidden" name="datefindcolumn" value="ld_paymentplan.plandate"/>
                    <input  type="hidden" name="otherfindcolumn" value="ld_accountpaymentplan.accountname"/>     
    	   	    </td>
            </tr>
        </table>
    </form>
    <div id="UseReportList">
		<table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="90%" style="margin-left:5%;">
        <caption><h2 style="color:#999999">用户试用分析表</h2></caption>
			<tr style="text-align:center;color:#FFFFFF;background:#7B95C7;height:35px;">
				<td>登录时间</td><td>手机号</td><td>CRM版本</td><td>IP地址</td><td>所在城市</td><td>累计登录次数</td>
			</tr>
            {foreach item=detail from=$result}
            <tr style="text-align:center;height:25px;">
				<td>{$detail.login_time}</td>
                <td>{$detail.phone}</td>
                <td>
                     {if $detail.cversion eq 'biaozhun'}
                    标准版
                    {elseif  $detail.cversion eq 'jichu'}
                    销售通
                    {elseif  $detail.cversion eq 'crm'}
                    企业版
                    {else}
                    {$detail.cversion}
                    {/if}
                </td>
                <td>{$detail.user_login_ip}</td>
                <td> {$detail.user_login_ip_city }</td>
                <td>{$detail.scount} 次</td>
			</tr>
            {/foreach}
		</table>
    </div>