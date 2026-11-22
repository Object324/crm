{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************+*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="javascript" type="text/javascript" src="../crmcommon/js/My97DatePicker/WdatePicker.js"></script>


<div style="hegiht:30%;">
<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="100%">
	<tr class="lvtColData">
		<td valign="top" class="DetailedTd1Label select-input" style="width:30%;">
		  &nbsp;手&nbsp;机&nbsp号：<input type="text" value="{$SAIC_MOBILE}" name="userMobile" style="width:150px;" class="detailedViewTextBox">&nbsp;&nbsp;
		  <input type="radio" value="1" name="complaintSource" checked><label>&nbsp;乘客&nbsp;</label>
		  <input type="radio" value="2" name="complaintSource"><label>&nbsp;司机</label>
		</td>
		<td valign="top" class="DetailedTd1Label" style="width:30%;">
		  &nbsp;MIS订单号：<input type="text" value="" name="orderId" style="width:220px;" class="detailedViewTextBox">
		</td>
		<td valign="top" class="DetailedTd1Label" style="width:30%;">
		  &nbsp;车&nbsp;牌&nbsp;号：<input type="text" value="" name="vehicleNo" style="width:200px;" class="detailedViewTextBox">
		</td>
	  </tr>
	  <tr class="lvtColData">
		<td valign="top" class="L" style="border-bottom: 1px solid #ddd;">
		  下单时间：<input name="startTime" class="Wdate" autocomplete="off" tabindex="q" type="text" fieldonly="0" style="border:1px solid #dbdbdb;width:100px" size="20" maxlength="10" value="{$STARTDATE}" onclick="WdatePicker()">&nbsp;至&nbsp;<input name="endTime" class="Wdate" autocomplete="off" tabindex="q" type="text" fieldonly="0" style="border:1px solid #dbdbdb;width:100px" size="20" maxlength="10" value="{$ENDDATE}" onclick="WdatePicker()">
		</td>
		<td valign="top" class="L" style="border-bottom: 1px solid #ddd;">
		   接&nbsp;单&nbsp;时&nbsp;间：<input name="matchOrderTimeStart" class="Wdate" autocomplete="off" tabindex="q" type="text" fieldonly="0" style="border:1px solid #dbdbdb;width:100px" size="20" maxlength="10" value="" onclick="WdatePicker()">&nbsp;至&nbsp;<input name="matchOrderTimeEnd" class="Wdate" autocomplete="off" tabindex="q" type="text" fieldonly="0" style="border:1px solid #dbdbdb;width:100px" size="20" maxlength="10" value="" onclick="WdatePicker()">
		</td>
		<td valign="top" class="L" style="border-bottom: 1px solid #ddd;">
		  订单来源：
		  <select name="appId" style="width:120px">
			<option value="" selected="-------"></option>
			<option value="1000000001">高德</option>
			<option value="open_app_Eg77IK8qngB97nOP">携程</option>
			<option value="open_app_BwH96b6vfFgBtsaa">滴滴</option>
			<option value="open_app_vimGI55RFagCOQ51">平安</option>
			<option value="saic_taxi">出租车</option>
		  </select>
		  &nbsp;&nbsp;&nbsp;<input name="button" id="Accounts_saic_search_btnok" class="E_pbtnok" value="立即查找" onclick="saic_search()" type="button">
		</td>
	  </tr>
</table>
<div name="saic_content">
{include file='saic/saic_content.tpl'}
</div>
</div>
