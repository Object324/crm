 <!--小白熊报表-->
<div id="change_table_div_SNOWBEARREPORTS" style="margin-top:-1px;margin-left:-1px;display:none;">
  <div id="year_4" style="display:none;">{$now}</div>
	<table width="100%" border="0" cellspacing="1" cellpadding="0" class="D_Table" style="text-align: center;">
    <tr>
    	<th width="30%" rowspan='13'>{'SNOWBEARREPORTS'|@getFixedLabel}</th>
      <th width="70%">{'TABLENAME'|@getFixedLabel}</th>
    </tr>
    {if $PRESENCE.SNOWBEARREPORTS.SNOWBEARRPISP.name eq 'SNOWBEARRPISP' && $PRESENCE.SNOWBEARREPORTS.SNOWBEARRPISP.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearrpisp()">{'SNOWBEARRPISP'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.SNOWBEARRPSL.name eq 'SNOWBEARRPSL' && $PRESENCE.SNOWBEARREPORTS.SNOWBEARRPSL.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearrpisppeijianminxi()">{'SNOWBEARRPSL'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.SNOWBEARHNSRSR.name eq 'SNOWBEARHNSRSR' && $PRESENCE.SNOWBEARREPORTS.SNOWBEARHNSRSR.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearSNOWBEARHNSRSR()">{'SNOWBEARHNSRSR'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.ComplainSummaryreports.name eq 'ComplainSummaryreports' && $PRESENCE.SNOWBEARREPORTS.ComplainSummaryreports.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearCCARflash()">{'ComplainSummaryreports'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.Customercomplaintanalysisreport.name eq 'Customercomplaintanalysisreport' && $PRESENCE.SNOWBEARREPORTS.Customercomplaintanalysisreport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearCCAR()">{'Customercomplaintanalysisreport'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.Returnamountregionaldatasummaryreport.name eq 'Returnamountregionaldatasummaryreport' && $PRESENCE.SNOWBEARREPORTS.Returnamountregionaldatasummaryreport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearraordsr()">{'Returnamountregionaldatasummaryreport'|@getFixedLabel}</a></td>
      </tr>
    {/if}
     {if $PRESENCE.SNOWBEARREPORTS.Returnnumberregionaldatasummaryreport.name eq 'Returnnumberregionaldatasummaryreport' && $PRESENCE.SNOWBEARREPORTS.Returnnumberregionaldatasummaryreport.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearrnordsr()">{'Returnnumberregionaldatasummaryreport'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.Productcustomerservicefaultsummarytable.name eq 'Productcustomerservicefaultsummarytable' && $PRESENCE.SNOWBEARREPORTS.Productcustomerservicefaultsummarytable.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearCCARflash2()">{'Productcustomerservicefaultsummarytable'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.Productcustomerservicenumberfailurestatistics.name eq 'Productcustomerservicenumberfailurestatistics' && $PRESENCE.SNOWBEARREPORTS.Productcustomerservicenumberfailurestatistics.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearPcsnofs()">{'Productcustomerservicenumberfailurestatistics'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.Productcustomerservicefailurein.name eq 'Productcustomerservicefailurein' && $PRESENCE.SNOWBEARREPORTS.Productcustomerservicefailurein.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearCCARflash3()">{'Productcustomerservicefailurein'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.Customerservicenumberofsummarytableoffaultarea.name eq 'Customerservicenumberofsummarytableoffaultarea' && $PRESENCE.SNOWBEARREPORTS.Customerservicenumberofsummarytableoffaultarea.presence eq 0}
      <tr>
        <td><a href="javascript:popup_snowbearCsnostofa()">{'Customerservicenumberofsummarytableoffaultarea'|@getFixedLabel}</a></td>
      </tr>
    {/if}
    {if $PRESENCE.SNOWBEARREPORTS.SinglewiretransfertableHotline.presence eq 0 || $PRESENCE.SNOWBEARREPORTS.Analysisofthetablecustomerservicefailure.presence eq 0}
      <tr>
        <td>
        {if $PRESENCE.SNOWBEARREPORTS.SinglewiretransfertableHotline.name eq 'SinglewiretransfertableHotline' && $PRESENCE.SNOWBEARREPORTS.SinglewiretransfertableHotline.presence eq 0}
          <a href="javascript:popup_snowbearCCARflash400()">{'SinglewiretransfertableHotline'|@getFixedLabel}</a><br />
        {/if}
         {if $PRESENCE.SNOWBEARREPORTS.Analysisofthetablecustomerservicefailure.name eq 'Analysisofthetablecustomerservicefailure' && $PRESENCE.SNOWBEARREPORTS.Analysisofthetablecustomerservicefailure.presence eq 0}
          <a href="javascript:popup_snowbearAtcsf()">{'Analysisofthetablecustomerservicefailure'|@getFixedLabel}</a></td>
        {/if}
        </td>
      </tr>
    {/if}
  </table>
</div>