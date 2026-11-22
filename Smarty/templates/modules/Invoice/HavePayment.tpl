<!--修改编码格式:统一编码：UTF-8-->
{include file="modules/Invoice/Invoiceinfo.tpl"}
      <input type="hidden" name="pliststr" id="pliststr" value="{$PLISTSTR}"/>  
      <input type="hidden" name="setsystem" id="setsystem" value="{$SETSYSTEM}"/>  
      <input type="hidden" name="paymentamount" id="paymentamount" value="{$NOPAYMENTAMOUNT}"/>  
      <input  type="hidden" name="planremarktypeofdata" value="{$PLANREMARKTYPEOFDATA}" id="planremarktypeofdata"/>
      <input  type="hidden" name="planremarklabel" value="{$PLANDREMARK}" id="planremarklabel"/>
        <tr>
            <td colspan='2'>
            <div class="Logscroll" style="height: 150px;width:100%;overflow:auto;">
				<table id="tabpaymentplan"  border="0" cellspacing="1" cellpadding="0" class="listEntries">
					<tr>
						<th width="6%"  style="text-align:center;">{'OPERATING'|@getFixedLabel}</th>
						<th>{$PERIODTIMENAME}</th>
                        <th>{'RATIO'|@getFixedLabel}</th>
						<th>{'AMOUNT'|@getFixedLabel}</th>
    					<th>{'PAYMENTPLANDATE'|@getFixedLabel}</th>
                        <th>{$PLANDREMARK}</th>
					</tr>
					<tr id='row1'>
                        <td align="center"><i class="ld-fonticon ld-fonticon-del" onclick='deletetr(this)'></i></td>
                        <td><input type="text" name="periodtime1" id="periodtime1" size="10" value="{$PERIODTIME}" class="ld-input-inner gwidth100" /></td>
                        <td><input type="text" name="ratio1" id="ratio1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}100.00{/if}" onchange="changeamountn(this,'amount1','ratio1','{$NOPAYMENTAMOUNT}');" class="ld-input-inner gwidth100" /></td>
                        <td><input type="text" name="amount1" id="amount1" size="10" value="{if $NOPAYMENTAMOUNT < 0 }0.00{else}{$NOPAYMENTAMOUNT}{/if}" onchange="changeratio(this,'ratio1','amount1','{$NOPAYMENTAMOUNT}');" class="ld-input-inner gwidth100"/></td>
                        <td class="ld-form-item-content">
                            <input type="text" name="plandate1" size="15" id="plandate1" readonly="true" value="{$PLANDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner" />
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
			<ul class="LdPop_ul12" style="padding: 0 5px;line-height: 26px;margin: 6px 0px;">
                <li><span>{'PERIODLOAD'|@getFixedLabel}</span>:</li>
                <li><input  type="text" value="" name="OkPeriodTime" id="OkPeriodTime" size="5" class="ld-input-inner" style="width: 60px;" />&nbsp;&nbsp;{'PERIOD'|@getFixedLabel},{'FIRSTBACKSECTION'|@getFixedLabel}:&nbsp;&nbsp;<input type="text" name="startplandate" size="15" id="startplandate" readonly="true" value="{$NOWDATE}" onClick="WdatePicker()" class="Wdate ld-input-inner"/></li>
                <!--<li><img style="float:left;margin-top:4px;" src='themes/softed/images/btnL3Calendar.gif' onclick='showCalendar("startplandate","%Y-%m-%d",true,"12",this)'/></li>-->
                <li><a class="Anu3_a" style="padding: 0 5px;line-height: 23px;margin:2px 0px;" onclick="LoadPeriodTime(this)" href="javascript:;">{'RECALCULATE'|@getFixedLabel}</a></li>
            </ul>
            </td>
          </tr>
        </table> 
</form>