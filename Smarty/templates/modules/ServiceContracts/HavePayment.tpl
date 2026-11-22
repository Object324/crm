<!--修改编码格式:统一编码：UTF-8-->
        {include file="modules/ServiceContracts/ServiceContractsInfo.tpl"}
        <input type="hidden" name="pliststr" id="pliststr" value="{$PLISTSTR}"/>  
        <input type="hidden" name="setsystem" id="setsystem" value="{$SETSYSTEM}"/>  
        <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>  
        <input type="hidden" name="planremarktypeofdata" value="{$PLANREMARKTYPEOFDATA}" id="planremarktypeofdata"/>
        <input type="hidden" name="planremarklabel" value="{$PLANDREMARK}" id="planremarklabel"/>
        <tr>
            <td colspan='2' style="padding: 0;">
                <div class="Logscroll" style="height: 150px;width:100%;overflow:auto;">
        			<table id="tabpaymentplan" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tr>
        					<th width="6%" style="text-align:center;">{'OPERATING'|@getFixedLabel}</th>
        					<th>{$PERIODTIMENAME}</th>
                            <th>{'RATIO'|@getFixedLabel}</th>
        					<th>{'AMOUNT'|@getFixedLabel}</th>
        					{if $PAYMENTTYPEVALUE eq '项目状态'}
        						<th id="paymentpan_date_tr" style="display:none;">{'PAYMENTPLANDATE'|@getFixedLabel}</th><!--计划回款日期-->
        						<th id="projectstatus_tr">{'Paymentwhentheprojectstatus'|@getFixedLabel}</th><!--回款时项目状态-->
        					{else}
        						<th id="paymentpan_date_tr">{'PAYMENTPLANDATE'|@getFixedLabel}</th><!--计划回款日期-->
        						<th style="display:none;" id="projectstatus_tr">{'Paymentwhentheprojectstatus'|@getFixedLabel}</th><!--回款时项目状态-->
        					{/if}
                            {if $PLANREMARKTYPEOFDATA eq 'm'}
                                <th><font color='red'>*</font>{$PLANDREMARK}</th>
                            {else}
                                <th>{$PLANDREMARK}</th>
                            {/if}
        				</tr>
        				<tr id='row1'>
                            <td align="center"><i class="ld-fonticon ld-fonticon-del" onclick='deletetr(this)'></i></td>
                            <td><input type="text" class="ld-input-inner" name="periodtime1" id="periodtime1" size="10" value="{$PERIODTIME}" /></td>
                            <td><input type="text" class="ld-input-inner" name="ratio1" id="ratio1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}100.00{/if}" onchange="changeamountn(this,'amount1','ratio1','{$NOPAYMENTAMOUNT}');" /></td>
                            <td><input type="text" class="ld-input-inner" name="amount1" id="amount1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}{$NOPAYMENTAMOUNT}{/if}" onchange="changeratio(this,'ratio1','amount1','{$NOPAYMENTAMOUNT}');"/></td>
        					<td id='paymentpan_date_td_1' class="ld-form-item-content">
                                <input type="text" name="plandate1" size="15" id="plandate1" readonly="true" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner"/>
        					</td>
        					<td id='projectstatus_td_1' style='display:none;'>
                                {$HAVEPAYMENTLIST}
                            </td>
                            <td><textarea name="description1" id="description1" value="" cols='100%' class="ld-textarea-inner" style='height: 22px;'></textarea></td>
                        </tr>
        	  		</table>
                </div>
            </td>
        </tr>  
        <tr>
            <td colspan='2'>
            <span style="float: left; display: block; padding: 2px 0px;">
                <a class="Anu3_a" style="padding: 0 5px;line-height: 23px;margin:6px 0px;" onclick="Addtr()" href="javascript:;">{'ADDQICI'|@getFixedLabel}</a>
            </span>
    		{if $PAYMENTTYPEVALUE eq '项目状态'}
    			<ul class="LdPop_ul12" style="float: right;padding: 0 5px;line-height: 26px;margin: 6px 0px;display:none;" id="paymentplan_times">
    		{else}
    			<ul class="LdPop_ul12" style="float: right;padding: 0 5px;line-height: 26px;margin: 6px 0px;" id="paymentplan_times">
    		{/if}
                <li><span>{'PERIODLOAD'|@getFixedLabel}</span>:</li>
                <li><input  type="text" value="" name="OkPeriodTime" id="OkPeriodTime" size="5"/>&nbsp;&nbsp;{'PERIOD'|@getFixedLabel},{'FIRSTBACKSECTION'|@getFixedLabel}:&nbsp;&nbsp;<input type="text" name="startplandate" size="15" id="startplandate" readonly="true" value="{$NOWDATE}" onClick="WdatePicker()" class="Wdate"/></li>
                <!--<li><img style="float:left;margin-top:4px;" src='themes/softed/images/btnL3Calendar.gif' onclick='showCalendar("startplandate","%Y-%m-%d",true,"12",this)'/></li>-->
                <li><a class="Anu3_a " style="padding: 0 5px;line-height: 23px;margin:2px 0px;" onclick="LoadPeriodTime(this)" href="javascript:;">{'RECALCULATE'|@getFixedLabel}</a></li>
            </ul>
            </td>
        </tr>
    </table>
</form>
<script>
    NewPaymentPlan.planremarktypeofdata='{$PLANREMARKTYPEOFDATA}';
    // alert(NewPaymentPlan.planremarktypeofdata);
</script>