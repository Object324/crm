<!--国通计表-->
<div id="change_table_div_GUOTONGREPORT" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
  <table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.GUOTONGREPORT.GUOTONGREPORT.name eq 'GUOTONGREPORT' && $PRESENCE.GUOTONGREPORT.GUOTONGREPORT.presence eq 0}
    <tr>
      <td class="f6">{'GUOTONGREPORT'|@getFixedLabel}</td>                  
      <td><a href="javascript:popup_guotongreports(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
    {if $PRESENCE.GUOTONGREPORT.CostStatistics.name eq 'CostStatistics' && $PRESENCE.GUOTONGREPORT.CostStatistics.presence eq 0}
    <tr>
      <td class="f6">{'CostStatistics'|@getFixedLabel}</td>
      <td><a href="javascript:popup_guotongreports2(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports2(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
    {if $PRESENCE.GUOTONGREPORT.Salesrecordslist.name eq 'Salesrecordslist' && $PRESENCE.GUOTONGREPORT.Salesrecordslist.presence eq 0}
    <tr>
      <td class="f6">{'Salesrecordslist'|@getFixedLabel}</td>
      <td><a href="javascript:popup_guotongreports3(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_guotongreports3(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
  </table>
</div>