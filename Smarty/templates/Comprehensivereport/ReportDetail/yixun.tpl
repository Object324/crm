<!--yixun报表-->
<div id="change_table_div_yixun" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    {if $PRESENCE.yixun.yixunOperateReport.name eq 'yixunOperateReport' && $PRESENCE.yixun.yixunOperateReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_Operationsreport()">运营报表</a></td>
      </tr>
    {/if}
    {if $PRESENCE.yixun.yixunFinacialReport.name eq 'yixunFinacialReport' && $PRESENCE.yixun.yixunFinacialReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_FinancialReport()">财务报表</a></td>
      </tr>
    {/if}
    {if $PRESENCE.yixun.yixunContractOostReport.name eq 'yixunContractOostReport' && $PRESENCE.yixun.yixunContractOostReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_hetonggangReport()">合同岗报表</a></td>
      </tr>
    {/if}
  </table>
</div>