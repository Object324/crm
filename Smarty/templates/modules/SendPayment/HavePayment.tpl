<!--修改编码格式:统一编码：UTF-8-->
<div class="divPopOverflow">
    {include file="modules/SendPayment/PurchaseOrderInfo.tpl"}
        <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>
        </table>
    <div class="" style="padding: 8px 24px 20px;">
        <table id="tabsendpayment" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <th width="6%" style="text-align:center;">{"OPERATING"|@getFixedLabel}</th>
                <th>{$PERIODTIMENAME}</th>
                <th>{'RATIO'|@getFixedLabel}</th>
                <th>{"AMOUNT"|@getFixedLabel}</th>
                <th>{$PLANDATENAME}</th>
                <th>{$PLANDREMARK}</th>
            </tr>
            <tr id='row1'>
                <td align="center"><i class="ld-fonticon ld-fonticon-del" onclick='deletetr(this)'></i></td>
                <td><input type="text" name="periodtime1"  id="periodtime1" size="10" value="{$PERIODTIME}" class="ld-input-inner" /></td>
                <td><input type="text" name="ratio1" id="ratio1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}100.00{/if}" onchange="changeamountn(this,'amount1','ratio1','{$NOPAYMENTAMOUNT}');" class="ld-input-inner" /></td>
                <td><input type="text" name="amount1" id="amount1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}{$NOPAYMENTAMOUNT}{/if}" onchange="changeratio(this,'ratio1','amount1','{$NOPAYMENTAMOUNT}');" class="ld-input-inner" /></td>
                <td class="ld-form-item-content">
                    <input type="text" name="plandate1" size="15" id="plandate1" readonly="true" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner" />
                </td>
                <td><textarea name="description1" id="description1"  value="" cols='100%' class="ld-textarea-inner" style='height: 30px;'></textarea></td>
            </tr>
        </table>
    </div>
</div>
<div style="display: flex;justify-content: space-between;padding: 0 24px">
    <div style="line-height: 44px;">
        <a class="" style="" onclick="Addtr()" href="javascript:;">{"ADDQICI"|@getFixedLabel}</a>
    </div>
    <ul class="LdPop_ul12" style="float: right;padding: 0 5px;line-height: 26px;margin: 6px 0px;">
        <li><span>{'PERIODLOAD'|@getFixedLabel}</span>:</li>
        <li><input type="text" value="" name="OkPeriodTime" id="OkPeriodTime" size="5" class="ld-input-inner" style="width: 60px;"/>&nbsp;&nbsp;{'PERIOD'|@getFixedLabel},{'FIRSTDATEPAYMENT'|@getFixedLabel}:&nbsp;&nbsp;<input type="text" name="startplandate" size="15" id="startplandate" readonly="true" value="{$NOWDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner ld-Wdate width100" /></li>
        <li><a class="Anu3_a" style="padding: 0 5px;line-height: 23px;margin:2px 0px;float:right;" onclick="LoadPeriodTime(this)" href="javascript:;">{'RECALCULATE'|@getFixedLabel}</a></li>
    </ul>
</div>
{if $ISADMIN eq 'on' && $ENTITYTYPE eq 'PurchaseOrder'}
    <a href="javascript:;" onclick="CashSet(document.getElementById('createSendPaymentid'),'SetSendPayment',0);return false;" style="position: absolute;padding: 24px 0 0 24px;">{'Set_the_send_default_ratio'|@getFixedLabel}</a>
{/if}
</form>
