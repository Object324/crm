<!--乐瑞固总帐款销售表-->
<div id="change_table_div_lotrecreport" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>	
  <table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.lotrecreport.lotrectotalreceivablesalesreport.name eq 'lotrectotalreceivablesalesreport' && $PRESENCE.lotrecreport.lotrectotalreceivablesalesreport.presence eq 0}
      <tr>
        <td class="f6">{'lotrectotalreceivablesalesreport'|@getFixedLabel}</td>         
        <td><a href="javascript:popup_LOTRECreport(0)">{'ANNUALTABLE'|@getFixedLabel}</a></td>         
        <td><a href="javascript:popup_LOTRECreport(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_LOTRECreport(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
  </table>
</div>