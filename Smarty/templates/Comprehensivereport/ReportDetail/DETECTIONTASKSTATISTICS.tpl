<!--检测任务完成情况统计表-->
<div id="change_table_div_DETECTIONTASKSTATISTICS" style="margin-top:-1px;margin-left:-1px;min-height:295px; display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.DETECTIONTASKSTATISTICS.DETECTIONTASKSTATISTICS.name eq 'DETECTIONTASKSTATISTICS' && $PRESENCE.DETECTIONTASKSTATISTICS.DETECTIONTASKSTATISTICS.presence eq 0}
    <tr>
      <td class="f6">{'DETECTIONTASKSTATISTICS'|@getFixedLabel}-{'BYMONTH'|@getFixedLabel}</td> 
      <td></td>                   
      <td><a href="javascript:popup_Testingdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_Testingdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
  </table>
</div>