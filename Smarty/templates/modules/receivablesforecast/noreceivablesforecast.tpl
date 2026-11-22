<!--修改编码格式:统一编码：UTF-8-->
{include file="modules/receivablesforecast/receivablesforecastorderinfo.tpl"}    
        <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>  
        <tr>
            <td colspan='2' style="padding:0;">
                <div class="Logscroll" style="height: 150px;">
                    <table id="tabreceivablesforecast" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    					<tr>
    						<th width="8%" style="text-align:center;">{'OPERATING'|@getFixedLabel}</th>
                            <th width="20%">{'RATIO'|@getFixedLabel}</th>
    						<th width="20%">{'ExpectedAmount'|@getFixedLabel}</th>
    						<th width="30%">{'ExpectedDate'|@getFixedLabel}</th>
    					</tr>
    					{$SENDPAYMENTSETTING}
    				</table>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan='2'>
                <a class="Anu3_a" onclick="Addtr()" href="javascript:;">{"ADDQICI"|@getFixedLabel}</a>
            </td>
        </tr>
    </table>
</form>