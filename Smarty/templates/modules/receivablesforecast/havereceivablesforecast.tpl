<!--修改编码格式:统一编码：UTF-8-->
{include file="modules/receivablesforecast/receivablesforecastorderinfo.tpl"}
        <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPOPRECEIVABLESFORECASTAMOUNT}"/>  
        <tr>
            <td colspan='2' style="padding:0;">
                <div class="Logscroll" style="height: 150px;">
                <table id="tabreceivablesforecast" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
					<tr>
						<th width="8%" style="text-align:center;">{"OPERATING"|@getFixedLabel}</th>
                        <th width="20%">{'RATIO'|@getFixedLabel}</th>
						<th width="20%">{"AMOUNT"|@getFixedLabel}</th>
						<th width="30%">{$PLANDATENAME}</th>
					</tr>
					<tr id='row1'>
                        <td align="center"><i class="ld-fonticon ld-fonticon-del" onclick='deletetr(this)'></i></td>
                        <input type="hidden" name="periodtime1"  id="periodtime1" size="10" value="{$PERIODTIME}" />
                        <td><input type="text" name="ratio1" id="ratio1" size="10" value="{if $NOPOPRECEIVABLESFORECASTAMOUNT < 0 }0.00{else}100.00{/if}" onchange="changeamountn(this,'amount1','ratio1','{$NOPOPRECEIVABLESFORECASTAMOUNT}');" class="ld-input-inner"/></td>
                        <td><input type="text" name="amount1" id="amount1" size="10" value="{if $NOPOPRECEIVABLESFORECASTAMOUNT < 0 }0.00{else}{$NOPOPRECEIVABLESFORECASTAMOUNT}{/if}" onchange="changeratio(this,'ratio1','amount1','{$NOPOPRECEIVABLESFORECASTAMOUNT}');" class="ld-input-inner"/></td>
                        <td class="ld-form-item-content">
                            <input type="text" name="plandate1" size="15" id="plandate1" readonly="true" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner"/>
                        </td>
                    </tr>
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
    </div>
    
</form>