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
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js"></script>

    <div id="status" style="position:absolute;display:none;left:850px;top:95px;height:27px;white-space:nowrap;"></div>
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