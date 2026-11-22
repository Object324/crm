<!--红不让计表-->
<div id="change_table_div_HBRREPORT" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.HBRREPORT.HBRREPORT.name eq 'HBRREPORT' && $PRESENCE.HBRREPORT.HBRREPORT.presence eq 0}
    <tr>
      <td class="f6">{'HBRREPORT'|@getFixedLabel}</td>                  
      <td><a href="javascript:popup_HBRreports(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HBRreports(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
  </table>
</div>