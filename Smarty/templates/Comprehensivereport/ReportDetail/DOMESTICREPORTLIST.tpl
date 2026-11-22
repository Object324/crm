<!--内销报表-->
<div id="change_table_div_DOMESTICREPORTLIST" style="margin-top:-1px;margin-left:-1px;min-height:295px; display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.DOMESTICREPORTLIST.BYPROVINCE.name eq 'BYPROVINCE' && $PRESENCE.DOMESTICREPORTLIST.BYPROVINCE.presence eq 0}
    <tr>
      <td class="f6">{'SALESREPORTLIST'|@getFixedLabel}--{'BYPROVINCE'|@getFixedLabel}</td> 
      <td></td>                   
      <td><a href="javascript:popup_insourcingdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_insourcingdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
    {if $PRESENCE.DOMESTICREPORTLIST.BYPRODUCT.name eq 'BYPRODUCT' && $PRESENCE.DOMESTICREPORTLIST.BYPRODUCT.presence eq 0}
    <tr>
      <td class="f6">{'SALESREPORTLIST'|@getFixedLabel}--{'BYPRODUCT'|@getFixedLabel}</td>
      <td></td>
      <td><a href="javascript:popup_productdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_productdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
    {if $PRESENCE.DOMESTICREPORTLIST.BYEXAMINATION.name eq 'BYEXAMINATION' && $PRESENCE.DOMESTICREPORTLIST.BYEXAMINATION.presence eq 0}
    <tr>
      <td class="f6">{'SALESREPORTLIST'|@getFixedLabel}--{'BYEXAMINATION'|@getFixedLabel}</td>
      <td><a href="javascript:popup_assessdetial(0)">{'ANNUALTABLE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_assessdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
    {if $PRESENCE.DOMESTICREPORTLIST.BYNETWORK.name eq 'BYNETWORK' && $PRESENCE.DOMESTICREPORTLIST.BYNETWORK.presence eq 0}
    <tr>
      <td class="f6">{'SALESREPORTLIST'|@getFixedLabel}--{'BYNETWORK'|@getFixedLabel}</td>
      <td><a href="javascript:popup_latticepointdetial(0)">{'ANNUALTABLE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_latticepointdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
    {if $PRESENCE.DOMESTICREPORTLIST.BYMODELS.name eq 'BYMODELS' && $PRESENCE.DOMESTICREPORTLIST.BYMODELS.presence eq 0}
    <tr>
      <td class="f6">{'SALESREPORTLIST'|@getFixedLabel}--{'BYMODELS'|@getFixedLabel}</td>
      <td><a href="javascript:popup_HelpDeskdetial(0)">{'ANNUALTABLE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(1)">{'JANUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(3)">{'MARCH'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(4)">{'APRIL'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(5)">{'MAY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(6)">{'JUNE'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(7)">{'JULY'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(8)">{'AUGUST'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(10)">{'OCTOBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
      <td><a href="javascript:popup_HelpDeskdetial(12)">{'DECEMBER'|@getFixedLabel}</a></td>
    </tr>
    {/if}
  </table>
</div>