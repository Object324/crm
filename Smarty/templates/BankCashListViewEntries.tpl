<!--切换导航  end-->
<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>   
    <form name="massdelete" id="massdelete" method="POST">
    <input type="hidden" name="publicaccounttype" value="" />
    <input id="excludedRecords" type="hidden" value="" name="excludedRecords" />
    <input id="allselectedboxes" type="hidden" value="" name="allselectedboxes" />
    <input id="numOfRows" type="hidden" value="" name="numOfRows" />
    <input id="bankcashid" type="hidden" value="{$BANKCASHID}" name="bankcashid" />
    <input id="selectbankcashid" type="hidden" value="" name="selectbankcashid" />
    <input type="hidden" id="idlist" name="idlist" value="" />
        {assign var=listtable_ui_type value=484|@getSys_deploy}
    <tr>
        <td width="100%">
        <div id="ListViewContents" style="width:100%;position:relative;">
            <table class="listEntries {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-nocolor{/if}" border="0" cellspacing="0" cellpadding="0" width="100%">
                <tr>
                    <th style="text-align:center;">#</th>
                    <th width="15%">{'COMPANYACCOUNT'|@getFixedLabel}</th>
                    <th width="8%">{'DATE'|@getFixedLabel}</th>
                    <th width="9%">{'BIll'|@getFixedLabel}</th>
                    <th width="9%">{'DocumentNumber'|@getFixedLabel}</th>
                    <th width="15%">{'ACCOUNTSVENDORS'|@getFixedLabel}</th>
                    <th width="8%">{'STATUS'|@getFixedLabel}</th>
                    <th width="9%">{'RELATEDPERSONNEL'|@getFixedLabel}</th>
                    <th width="7%" style=" color:#FF0000;">{'AMOUNTRECEIVED'|@getFixedLabel}</th>
                    <th width="7%" style=" color:#663300;">{'AMOUNTSPENDING'|@getFixedLabel}</th>
                    <th width="9%" style=" color:#0000FF;">{'BALANCE'|@getFixedLabel}</th>
                </tr>
            {if $BANKLISTNUMROWS > 0}
           
            {assign var='importtotal' value=0}
            {assign var='outtotal' value=0}
            {assign var='foreach_i' value='1'}
          
            {foreach name=bankaccount item=bankvalue key=id from=$BANKLIST}
			
			 
			   
            {assign var="bankascid" value=$smarty.foreach.bankaccount.index}
            {assign var="count" value=0}
            
            {if $bankascid >= 1 && $tmpbankaccountid neq $bankvalue.bankaccountsetid}
                <tr align="right"  class="Subtotal" bgcolor="white">
                    <td colspan="2" align="left">{'SUBTOTAL'|@getFixedLabel}:</td>
                    <td colspan="6">&nbsp;</td>
                    <td style=" color:#FF0000;" title="¥{$importtotal|@setNumberFormat}">¥{$importtotal|@setNumberFormat}</td>
                    <td><span style=" color:#663333;" title="¥{$outtotal|@setNumberFormat}">¥{$outtotal|@setNumberFormat}</td>
                    <td><span style=" color:#0000FF;" title="{'PROFITANDLOSS'|@getFixedLabel}:¥{$balancetotal|@setNumberFormat}">{'PROFITANDLOSS'|@getFixedLabel}:¥{$balancetotal|@setNumberFormat}</td>
                </tr>
                {assign var='foreach_i' value=1}
                {assign var='importtotal' value=0}
                {assign var='outtotal' value=0}
                {assign var="bankascid" value=0}
				
               
            {/if}
				{if ($tmpbankaccountid neq $bankvalue.bankaccountsetid && $BANKCASHID eq 0)||$id eq 0}
			   {assign var='balancetotal' value =$AFTERTOTAL[$bankvalue.bankaccountsetid]}
				
			  {/if}
			  
			   {assign var='tmpbankaccountid' value=$bankvalue.bankaccountsetid}
			{if $bankvalue.currency_id > 1 && $BANKCASHID eq 0}
				{assign var="importtotal" value=$importtotal+$bankvalue.importtotal/$bankvalue.conversion_rate}
				{assign var="outtotal" value=$outtotal+$bankvalue.outtotal/$bankvalue.conversion_rate}
			{else}
				{assign var="importtotal" value=$importtotal+$bankvalue.importtotal}
				{assign var="outtotal" value=$outtotal+$bankvalue.outtotal}
			{/if}
            {if $bankvalue.module eq 'PutCash' || $bankvalue.module eq 'CashDeposit'}
                {if $bankvalue.setcash eq 1}
					{if $bankvalue.currency_id > 1 && $BANKCASHID eq 0}
						{assign var="balancetotal" value=$balancetotal+$bankvalue.importtotal/$bankvalue.conversion_rate}
					{else}
						{assign var="balancetotal" value=$balancetotal+$bankvalue.importtotal}
					{/if}
                {else}
					{if $bankvalue.currency_id > 1 && $BANKCASHID eq 0}
						{assign var="balancetotal" value=$balancetotal-$bankvalue.outtotal/$bankvalue.conversion_rate}
					{else}
						{assign var="balancetotal" value=$balancetotal-$bankvalue.outtotal}
					{/if}
                {/if}
            {elseif $bankvalue.module eq 'CashBill' || $bankvalue.module eq 'PurchaseCashBack'}
			  
				{if $bankvalue.currency_id > 1 && $BANKCASHID eq 0}
					{assign var="balancetotal" value=$balancetotal+$bankvalue.importtotal/$bankvalue.conversion_rate}
				{else}
					{assign var="balancetotal" value=$balancetotal+$bankvalue.importtotal}
				{/if}
				
            {elseif $bankvalue.module eq 'SendCashBill' || $bankvalue.module eq 'Expense' || $bankvalue.module eq 'LoanApply' || $bankvalue.module eq 'CashBack' || $bankvalue.module eq 'Commission' || $bankvalue.module eq 'PurchaseCashBack'}
					
				{if $bankvalue.currency_id > 1 && $BANKCASHID eq 0}
					{assign var="balancetotal" value=$balancetotal-$bankvalue.outtotal/$bankvalue.conversion_rate}
				{else}
					{assign var="balancetotal" value=$balancetotal-$bankvalue.outtotal}
				{/if}
            {elseif $bankvalue.module eq 'BankAccountSet'}
				{if $bankvalue.currency_id > 1 && $BANKCASHID eq 0}
					{assign var="balancetotal" value=$balancetotal+$bankvalue.importtotal/$bankvalue.conversion_rate}
				{else}
					{assign var="balancetotal" value=$balancetotal+$bankvalue.importtotal}
				{/if}
            {/if}
            {assign var="cashid" value=$bankvalue.cashid}
            {if ($foreach_i+1) mod 2 eq '0'}
            <tr align="left"  class="Hover" bgcolor="white">
            {else}
            <tr align="left"  class="lvtColDataBj Hover" bgcolor="white">
            
            {/if}
                <td align="center">{$foreach_i}
                    {assign var='foreach_i' value=$foreach_i+1}
                </td>
                {*BUG0069626 txy 20230718 现金银行流水账，账户增加文字浮显，否则账户名称过长显示省略号无法查看全部显示*}
                <td><span class="tip-items-list" data-tip="{$bankvalue.cashname}" data-direction="top" data-type="position">{$bankvalue.cashname}</span></td>
                <td>{$bankvalue.date}</td>
                <td>{$bankvalue.bill}</td>
                <td>{$bankvalue.billno}</td>
                <td>{$bankvalue.accountid}</td>
                <td>{$bankvalue.status}</td>
                <td>{$bankvalue.person}</td>
                <td align="right" style=" color:#FF0000;" title="{$bankvalue.currency_symbol}{$bankvalue.importtotal|@setNumberFormat}">{$bankvalue.currency_symbol}{$bankvalue.importtotal|@setNumberFormat}</td>
                <td align="right" ><span style=" color:#663333;" title="{$bankvalue.currency_symbol}{$bankvalue.outtotal|@setNumberFormat}">{$bankvalue.currency_symbol}{$bankvalue.outtotal|@setNumberFormat}</span></td>
                <td align="right" ><span style=" color:#0000FF;"title="{$basic_currency_symbol}{$balancetotal|@setNumberFormat}">{$basic_currency_symbol}{$balancetotal|@setNumberFormat}</span></td>
            </tr>
            {if $smarty.foreach.bankaccount.last}
                <tr align="right"  class="Subtotal" bgcolor="white">
                    <td colspan="2" align="left">{'SUBTOTAL'|@getFixedLabel}:</td>
                    <td colspan="6">&nbsp;</td>
                    <td style=" color:#FF0000;"title="{$basic_currency_symbol}{$importtotal|@setNumberFormat}">{$basic_currency_symbol}{$importtotal|@setNumberFormat}</td>
                    <td><span style=" color:#663333;" title="{$basic_currency_symbol}{$outtotal|@setNumberFormat}">{$basic_currency_symbol}{$outtotal|@setNumberFormat}</td>
                    <td><span style=" color:#0000FF;" title="{'PROFITANDLOSS'|@getFixedLabel}:{$basic_currency_symbol}{$balancetotal|@setNumberFormat}">{'PROFITANDLOSS'|@getFixedLabel}:{$basic_currency_symbol}{$balancetotal|@setNumberFormat}</td>
                </tr>
            {/if}
            {/foreach}
            
            {else}
                <tr>
                    <td   style="background-color:#FFF;height:360px;position:relative;" align="center" colspan="11">
                        {* <div class="warningTableContent" style="z-index:600;">
                            <div class="wtc_img">
                                <img src="themes/icon2023/ld-no-records.png">
                            </div>
                            <div class="wtc_content">{'NOTFOUNDANYRECORD'|@getFixedLabel}</div>
                            <div class="wtc_btn"></div><div></div>
                        </div> *}
                        {include file="NoRecords.tpl"}
                    </td>
                </tr>
                
            {/if}
            </table>
        </div>
       </td>
    </tr>
</form>

</table>

