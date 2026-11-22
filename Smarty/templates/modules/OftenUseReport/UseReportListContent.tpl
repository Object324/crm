{*editor:gyq_86 reason:库存报表 2018/11/22 15:50*}
{*editor:gyq_135 reason:打卡报表 2019/8/8 21:57*}
{if $parent_type eq 'kucun' || $parent_type eq 'checkin' }
    <div style="clear: both;padding: 5px 15px;">
    <div class="clearBoth padB2 lfloat">
      {if $PrintPermit eq "yes"}
        <a href="javascript:void(0);" title="{'PRINT'|@getFixedLabel}" onclick="UseReportPrint(this);"
             class="report-newsystem">{'PRINT'|@getFixedLabel}</a>
      {/if}
      {if $SETCOLUMNS eq 1 && $isADMIN eq 1 }
        <a href="javascript:void(0);" title="{'DISPLAYCOLUMNSET'|@getFixedLabel}"
           onclick="UseReportColumnSet('{$USEREPORTID}',this,'UseReportSet');" name="submit"
           class="report-newsystem" style="padding-left:5px;">{'DISPLAYCOLUMNSET'|@getFixedLabel}</a>
        <a href="javascript:void(0);" title="{'COLUMNNAMESET'|@getFixedLabel}"
           onclick="EditUseReportColumn('{$USEREPORTID}',this,'EditUseReportColum');" name="editsubmit"
           class="report-newsystem" style="padding-left:5px;">{'COLUMNNAMESET'|@getFixedLabel}</a>
      {/if}
			{if $USEREPORTSNAME eq 'InventoryLedger' || $USEREPORTSNAME eq 'InventoryAccount'|| $USEREPORTSNAME eq 'InventoryQuery'}
				<a href="javascript:void(0);" title="{'CUSTOMIZESEARCH'|@getFixedLabel}"
                   onclick="oftenusereport_advSearch('{$USEREPORTSNAME}');" name="editsubmit"
                   class="report-newsystem" style="padding-left:5px;">{'CUSTOMIZESEARCH'|@getFixedLabel}</a>
			{/if}
      {if $ExportExcelPermit eq "yes"}
        <a href="javascript:void(0);" title="{'EXPORT'|@getFixedLabel}"
             onclick="Exproteoftenusereport({$USEREPORTID});" name="editsubmit" class="report-newsystem"
             style="border-right:none;padding-left:5px;">{'EXPORT'|@getFixedLabel}Excel</a>
      {/if}
    </div>
    <div class="PageDiv0" style="margin-top:0;">
      <div class="ld-flex-start">
        <div class="ld-pagenum-div">{$recordListRange}</div>
        {$NAVIGATION}
      </div>
    </div>
  </div>
{/if}
<input type="hidden" name="productids" id="productids" value="{$ILPRODUCTIDS}"/>
<input type="hidden" name="productids_current" id="productids_current" value="{$ILPRODUCTIDSCURRENT}"/>
<input type="hidden" name="productids_name" id="productids_name" value="{$ILPRODUCTIDSNAME}"/>
<input type="hidden" id="productid_current" value=""/>
<input type="hidden" id="printsearchType" value="{$SEARCHTYPE}"/>
<div id="AjaxTimeSheetTable">
    <table class="rptTable TableOften" width="{$PAGEWIDTHPERCENT}%" cellspacing="0" cellpadding="0" style="margin-left: -1px">
        <!-- Table Headers -->
        {if $USEREPORTSNAME eq 'TimeSheet personal monthly summary'}
            {$REPORTFILTERHTML}
        {elseif $USEREPORTSNAME eq 'Sign_in_track' || $USEREPORTSNAME eq 'SignDistribution' }
                
                <div class="divMapRight">
        			<div id="map_div_signin" name="map_div_signin" style="width:100%;">
        		
        			</div>
                    <input type='hidden' name='signin_info' value='{$REPORTFILTERHTML}'  tag='1' />
                    
        		</div>
        {else}
            {$REPORTFINDHEADER}
            <!-- Table Contents -->
            {$REPORTFILTERHTML}
        {/if}
    </table>
</div>