<!--毛利统计表-->
<div id="change_table_div_GROSSMARGINSTATISTICS" style="margin-top:-1px;margin-left:-1px;min-height:295px; display:none;">
    <div id="year_2" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="D_Table" style="text-align: center;">
        <tr>
            <th>{'TABLENAME'|@getFixedLabel}</th>
            <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
        </tr>
        {if $PRESENCE.GROSSMARGINSTATISTICS.GROSSMARGINLIST.name eq 'GROSSMARGINLIST' && $PRESENCE.GROSSMARGINSTATISTICS.GROSSMARGINLIST.presence eq 0}
            <tr>
                <td class="f6">{'GROSSMARGINLIST'|@getFixedLabel}</td> <!--毛利明细表-->                
                <td><a href="javascript:popup_grossprofitdetial(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(5)">{'MAY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(7)">{'JULY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_grossprofitdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
            </tr>
        {/if}
        {if $PRESENCE.GROSSMARGINSTATISTICS.GROSSMARGINSUMMARY.name eq 'GROSSMARGINSUMMARY' && $PRESENCE.GROSSMARGINSTATISTICS.GROSSMARGINSUMMARY.presence eq 0}
            <tr>
                <td class="f6">{'GROSSMARGINSUMMARY'|@getFixedLabel}</td><!--毛利汇总明细表-->    
                <td><a href="javascript:popup_costprice_salesorder(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(1)">{'JANUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(3)">{'MARCH'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(4)">{'APRIL'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(5)">{'MAY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(6)">{'JUNE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(7)">{'JULY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(8)">{'AUGUST'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(10)">{'OCTOBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_costprice_salesorder(12)">{'DECEMBER'|@getFixedLabel}</a></td>
            </tr>
        {/if}
        {if $PRESENCE.GROSSMARGINSTATISTICS.PRODUCTGROSSMARGINSTATISTICS.name eq 'PRODUCTGROSSMARGINSTATISTICS' && $PRESENCE.GROSSMARGINSTATISTICS.PRODUCTGROSSMARGINSTATISTICS.presence eq 0}
            <tr>
                <td class="f6">{'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}</td><!--产品毛利统计表-->  
                <td><a href="javascript:popup_product_grossprofit(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(1)">{'JANUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(3)">{'MARCH'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(4)">{'APRIL'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(5)">{'MAY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(6)">{'JUNE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(7)">{'JULY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(8)">{'AUGUST'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(10)">{'OCTOBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_product_grossprofit(12)">{'DECEMBER'|@getFixedLabel}</a></td>
            </tr>
        {/if}
        {if $PRESENCE.GROSSMARGINSTATISTICS.CUSTOMERGROSSMARGINSTATISTICS.name eq 'CUSTOMERGROSSMARGINSTATISTICS' && $PRESENCE.GROSSMARGINSTATISTICS.CUSTOMERGROSSMARGINSTATISTICS.presence eq 0}
            <tr>
                <td class="f6">{'CUSTOMERGROSSMARGINSTATISTICS'|@getFixedLabel}</td><!--客户毛利统计表-->
                <td><a href="javascript:popup_account_grossprofit(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(1)" >{'JANUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(3)">{'MARCH'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(4)">{'APRIL'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(5)">{'MAY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(6)">{'JUNE'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(7)">{'JULY'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(8)">{'AUGUST'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(10)">{'OCTOBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
                <td><a href="javascript:popup_account_grossprofit(12)">{'DECEMBER'|@getFixedLabel}</a></td>
            </tr>
        {/if}
    </table>
</div>