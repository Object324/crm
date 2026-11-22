<!--fudi报表-->
<div id="change_table_div_fudi" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    {if $PRESENCE.fudi.SumStockSssetsReport.name eq 'SumStockSssetsReport' && $PRESENCE.fudi.SumStockSssetsReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_StockAssetSummary()">存量资产汇总表</a></td>
      </tr>
    {/if}
    {if $PRESENCE.fudi.fudiSalesReport.name eq 'fudiSalesReport' && $PRESENCE.fudi.fudiSalesReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_FuDiSalesReport()">销售报表</a></td>
      </tr>
    {/if}
    {if $PRESENCE.fudi.fudiRentCollectionreport.name eq 'fudiRentCollectionreport' && $PRESENCE.fudi.fudiRentCollectionreport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_RentCollectionReport()">租金收缴报表</a></td>
      </tr>
    {/if}
    {if $PRESENCE.fudi.fudiLeaseReport.name eq 'fudiLeaseReport' && $PRESENCE.fudi.fudiLeaseReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_LeasingReports()">租赁报表</a></td>
      </tr>
    {/if}
    {if $PRESENCE.fudi.fudiHomePageReport.name eq 'fudiHomePageReport' && $PRESENCE.fudi.fudiHomePageReport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_SummaryNationalAssetsAreaReports()">首页显示</a></td>
      </tr>
    {/if}
  </table>
</div>