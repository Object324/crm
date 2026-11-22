<!--销售明细表-->
<div id="change_table_div_SALESLIST" style="margin-top:-1px;margin-left:-1px;min-height:295px; display:none;">
  <div id="year_1" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th>{'TABLENAME'|@getFixedLabel}</th>
      <th colspan="13">{'TIMEPERIOD'|@getFixedLabel}</th>
    </tr>
    <!--人员签单明细表-->
    {if $PRESENCE.SALESLIST.PERSONNELSIGNINGLIST.name eq 'PERSONNELSIGNINGLIST' && $PRESENCE.SALESLIST.PERSONNELSIGNINGLIST.presence eq 0}
      <tr>
        <td class="f6">{'PERSONNELSIGNINGLIST'|@getFixedLabel}</td>                 
        <td><a href="javascript:popup_user_salesorder(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_salesorder(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    <!--人员回款明细表-->
    {if $PRESENCE.SALESLIST.PERSONNELCOLLECTIONLIST.name eq 'PERSONNELCOLLECTIONLIST' && $PRESENCE.SALESLIST.PERSONNELCOLLECTIONLIST.presence eq 0}
      <tr>
        <td class="f6">{'PERSONNELCOLLECTIONLIST'|@getFixedLabel}</td>
        <td><a href="javascript:popup_user_cashbill(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup_user_cashbill(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    <!--客户回款明细表-->
    {if $PRESENCE.SALESLIST.CUSTOMERCOLLECTIONLIST.name eq 'CUSTOMERCOLLECTIONLIST' && $PRESENCE.SALESLIST.CUSTOMERCOLLECTIONLIST.presence eq 0}
      <tr>
        <td class="f6">{'CUSTOMERCOLLECTIONLIST'|@getFixedLabel}</td>
        <td><a href="javascript:popup(0)" tag="annualtable">{'ANNUALTABLE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(1)">{'JANUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(2)">{'FEBRUARY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(3)">{'MARCH'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(4)">{'APRIL'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(5)">{'MAY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(6)">{'JUNE'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(7)">{'JULY'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(8)">{'AUGUST'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(9)">{'SEPTEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(10)">{'OCTOBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(11)">{'NOVEMBER'|@getFixedLabel}</a></td>
        <td><a href="javascript:popup(12)">{'DECEMBER'|@getFixedLabel}</a></td>
      </tr>
    {/if}
  </table>
</div>