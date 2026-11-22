{*editor:gyq_86 reason:库存报表 2018/11/22 15:50*}
{if $USEREPORTSNAME eq 'InventoryLedger' && $ILPRODUCTIDSCOUNT gt 0}
    {assign var="productinfo" value="$ILPRODUCTINFO"}
    <div class="inventoryReport ltextalign marB5">
        <input id="productinfo" type="hidden" value="{$ILPRODUCTINFO}">
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td>
                    <table border="0" cellspacing="0" cellpadding="5">
                        <tr style="height:35px;">
                            <td align="left">
                               <ul class="lfloat">
                                    <li class="font13" style="padding-left: 15px;">
{*                                        BUG0054894	zxm 20220812 已分派	系统错误	*}
{*                                        常用报表-库存台账：<> 里面没有内容？？*}
                                        <span style="float:left">{'TOTALOF'|@getFixedLabel}{$ILPRODUCTIDSCOUNT}{'PRODUCTS'|@getFixedLabel}&nbsp;&nbsp;</span>
                                        <a id="houtui" href="javascript:void(0);" onClick="redirect_record('houtui','')" class="no-icon-prevpage inventoryReporticon"></a>
                                        <span style="float:left" id="product_number">1</span>
                                        <span style="float:left"> /{$ILPRODUCTIDSCOUNT}</span>
                                        <a id="qianjin" href="javascript:void(0);" onClick="redirect_record('qianjin','')" class="icon-nextpage inventoryReporticon"></a>
                                    </li>
                                    <li class="font13">{'USEREPORTENTRIESTITLE1'|@getFixedLabel}:<a href="javascript:void(0);" onclick="redirect_record_detail(this);">
                                    <span ex_attr="productdetail" >{$ILPRODUCTINFO_ORIGN[0]['productname']}</span>
                                    </a></li>
                                   {*editor:gyq_140 reason:库存报表优化，增加显示列产地、生产日期,made_in/productdate  2019/8/30 11:17*}
                                   {foreach item=fieldlabel key=columnname  from=$ILPRODUCTLABEL}
                                       <li class="font13">{$fieldlabel}:<span ex_attr="productdetail">{$ILPRODUCTINFO_ORIGN[0]["{$columnname}"]}</span></li>
                                   {/foreach}
                               </ul>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </div>  
{/if}
<div id="UseReportEntries">
    {include file="modules/OftenUseReport/UseReportListContent.tpl"}
</div>
	