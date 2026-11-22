<!--销售汇总表-->
<div id="change_table_div_SALESSUMMARYLIST" style="margin-top:-1px;margin-left:-1px;min-height:295px; display:none;">
  <div id="year_1" style="display:none;">{$now}</div>
  {if $PRESENCE.SALESSUMMARYLIST.SALESSTATISTICSLIST.name eq 'SALESSTATISTICSLIST' && $PRESENCE.SALESSUMMARYLIST.SALESSTATISTICSLIST.presence eq 0}
    <table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
      <tr>
        <th>{'TABLENAME'|@getFixedLabel}</th>
      </tr>
      <tr>
        <td class="f6">
          <a href="javascript:popup_marketAll()">{'SALESSTATISTICSLIST'|@getFixedLabel}——{'SUMMARYTABLE'|@getFixedLabel}</a>
        </td>
      </tr>
    </table>
  {/if}
</div>