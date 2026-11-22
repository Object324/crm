<!--修改编码格式:统一编码：UTF-8-->
    {include file="modules/receivablesforecast/receivablesforecastorderinfo.tpl"}
          <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>  
        <tr>
            <td colspan='2'>
                <div class="Logscroll" style="height: 150px;">
                <table id="tabreceivablesforecast" width="100%" border="0" cellspacing="1" cellpadding="0" class="listEntries">
					<tr>
						<th width="20%">{'ExpectedAmount'|@getFixedLabel}</th>
						<th width="30%">{'ExpectedDate'|@getFixedLabel}</th>
					</tr>
						{$SENDPAYMENTSETTING}
				</table>
                </div>
            </td>
        </tr>
    </table>
</form>