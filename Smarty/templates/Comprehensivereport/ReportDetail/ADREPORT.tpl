<!--爱安得计表-->
<div id="change_table_div_ADREPORT" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
        <tr>
        	<th>{'TABLENAME'|@getFixedLabel}</th>
            <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
        </tr>
        {if $PRESENCE.ADREPORT.Drilldownreports.name eq 'Drilldownreports' && $PRESENCE.ADREPORT.Drilldownreports.presence eq 0}
        <tr>
            <td class="f6">{'Drilldownreports'|@getFixedLabel}</td>                  
            <td><a href="javascript:popup_Drilldownreports(1)">{'JANUARY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(3)">{'MARCH'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(4)">{'APRIL'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(5)">{'MAY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(6)">{'JUNE'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(7)">{'JULY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(8)">{'AUGUST'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(10)">{'OCTOBER'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Drilldownreports(12)">{'DECEMBER'|@getFixedLabel}</a></td>
        </tr>
        {/if}
        {if $PRESENCE.ADREPORT.Summaryreports.name eq 'Summaryreports' && $PRESENCE.ADREPORT.Summaryreports.presence eq 0}
        <tr>
            <td class="f6">{'Summaryreports'|@getFixedLabel}</td>
            <td><a href="javascript:popup_Summaryreports(1)">{'JANUARY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(3)">{'MARCH'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(4)">{'APRIL'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(5)">{'MAY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(6)">{'JUNE'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(7)">{'JULY'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(8)">{'AUGUST'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(10)">{'OCTOBER'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
            <td><a href="javascript:popup_Summaryreports(12)">{'DECEMBER'|@getFixedLabel}</a></td>
        </tr>
        {/if}
    </table>
</div>