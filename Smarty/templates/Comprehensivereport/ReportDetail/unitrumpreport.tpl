<!--国通计表-->
<div id="change_table_div_unitrumpreport" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.unitrumpreport.Salessummaryreport.name eq 'Salessummaryreport' && $PRESENCE.unitrumpreport.Salessummaryreport.presence eq 0}
      <tr>
        <td class="f6">{'Salessummaryreport'|@getFixedLabel}</td>         
        <td><a href="javascript:popup_Salessummaryreport(0)">{'ANNUALTABLE'|@getFixedLabel}</a></td>         
        <td><a href="javascript:popup_Salessummaryreport(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Salessummaryreport(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.unitrumpreport.youchuangProductSales.name eq 'youchuangProductSales' && $PRESENCE.unitrumpreport.youchuangProductSales.presence eq 0}
      <tr>
        <td class="f6">产品线销售业绩报表</td>  
        <td></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_Productlinesaleperformancereport(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
  </table>
</div>