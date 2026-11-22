<!--修改编码格式:统一编码：UTF-8-->
        {include file="modules/ServiceContracts/ServiceContractsInfo.tpl"}
        <input type="hidden" name="pliststr" id="pliststr" value="{$PLISTSTR}"/>  
        <input type="hidden" name="setsystem" id="setsystem" value="{$SETSYSTEM}"/>  
        <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>  
        <input type="hidden" name="planremarktypeofdata" value="{$PLANREMARKTYPEOFDATA}" id="planremarktypeofdata"/>
        <input type="hidden" name="planremarklabel" value="{$PLANDREMARK}" id="planremarklabel"/>
        <tr>
            <td colspan='2' style="padding:0;">
                <div class="Logscroll" style="height: 150px;width:100%;overflow:auto;">
        			<table id="tabpaymentplan" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        				<tr>
        					<th width="6%" style="text-align:center;">{'OPERATING'|@getFixedLabel}</th>
        					<th>{$PERIODTIMENAME}</th>
                            <th>{'RATIO'|@getFixedLabel}</th>
        					<th>{'AMOUNT'|@getFixedLabel}</th>
        					{if $PAYMENTTYPEVALUE eq '项目状态'}
        						<th id="paymentpan_date_tr" style="display:none;">{'PAYMENTPLANDATE'|@getFixedLabel}</th><!--计划回款日期-->
        						<th  id="projectstatus_tr">{'Paymentwhentheprojectstatus'|@getFixedLabel}</th><!--回款时项目状态-->
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
        				{$PAYMENTPLANSETTING}
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
                    <li><input  type="text" value="" name="OkPeriodTime" id="OkPeriodTime" size="5" class="ld-input-inner" style="width: 60px;"/>&nbsp;&nbsp;{'PERIOD'|@getFixedLabel},{'FIRSTBACKSECTION'|@getFixedLabel}:&nbsp;&nbsp;<input type="text" name="startplandate" size="15" id="startplandate" readonly="true" value="{$NOWDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner"/></li>
                    <li><a class="Anu3_a" style="padding: 0 5px;line-height: 23px;margin:2px 0px;" onclick="LoadPeriodTime(this)" href="javascript:;">{'RECALCULATE'|@getFixedLabel}</a></li>
                </ul>
            </td>
        </tr>
    </table>
</form>