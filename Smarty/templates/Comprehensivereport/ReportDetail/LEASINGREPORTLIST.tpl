<!--租赁报表-->
<div id="change_table_div_LEASINGREPORTLIST" style="margin-top:-1px;margin-left:-1px;min-height:295px; display:none;">
  <div id="year_5" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.LEASINGREPORTLIST.LEASINGSTATISTICSLIST.name eq 'LEASINGSTATISTICSLIST' && $PRESENCE.LEASINGREPORTLIST.LEASINGSTATISTICSLIST.presence eq 0}
      <tr>
        <td class="f6">{'LEASINGSTATISTICSLIST'|@getFixedLabel}</td>                    
        <td><a href="javascript:popup_HxCrmdetail(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmdetail(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.LEASINGREPORTLIST.RENTPAIDBACKSITUATION.name eq 'RENTPAIDBACKSITUATION' && $PRESENCE.LEASINGREPORTLIST.RENTPAIDBACKSITUATION.presence eq 0}
      <tr>
        <td class="f6">{'RENTPAIDBACKSITUATION'|@getFixedLabel}</td>
        <td><a href="javascript:popup_HxCrmrent(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmrent(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.LEASINGREPORTLIST.ANNUALRENTSCHEDULE.name eq 'ANNUALRENTSCHEDULE' && $PRESENCE.LEASINGREPORTLIST.ANNUALRENTSCHEDULE.presence eq 0}
      <tr>
        <td class="f6">{'ANNUALRENTSCHEDULE'|@getFixedLabel}</td>
        <td><a href="javascript:popup_HxCrmPaymentplan(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmPaymentplan(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.LEASINGREPORTLIST.RENTARREARSLIST.name eq 'RENTARREARSLIST' && $PRESENCE.LEASINGREPORTLIST.RENTARREARSLIST.presence eq 0}
      <tr>
        <td class="f6">{'RENTARREARSLIST'|@getFixedLabel}</td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_HxCrmNoPaymentplan(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
  </table>
</div>