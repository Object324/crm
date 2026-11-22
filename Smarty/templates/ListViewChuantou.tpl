{if count($penetrateModuleArr)>1}
<div class="D_Tab_div tabHieght LayoutBlocklistTable_stickytop marB5" id="LayoutBlocklistTable">
    <table width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody>
        <tr>
            <td class="L" valign="top">
                <ul>
                    {foreach $penetrateModuleArr as $tmpmodulename}
                    <li name="modulelist_li" data-modulename="{$tmpmodulename}">
                        <a {if $penetrateModule==$tmpmodulename}class="On"{/if}>{$tmpmodulename|@getTranstab}</a>
                    </li>
                    {/foreach}
                </ul>
            </td>
        </tr>
        </tbody>
    </table>
</div>
{/if}
<table class="ld-drag-area" border=0 cellspacing=0 cellpadding=0 width=100% align=center>
    <tr>
        <td valign="top">
            <div id="ListViewContents" style="width:100%;">
                <div class="main_grid lfloat main_grid_list">
                    <div class="main_grid_top">
                        {include file='ListViewBtnAndSeachChuantou.tpl'}
                        <div class="clear"></div>
                    </div>
                    <div class="main_grid_box" id="chuantou_listview_content">
                {if get_file_address($MODULE,'ProductDetails') == true || $MODULE eq 'MarketSpread'|| get_file_address($MODULE,'DocumentsDetails') || get_file_address($MODULE,'AttachmentDetails') || get_file_address($MODULE,'VendorsDetails') || get_file_address($MODULE,'ContactsDetails')|| get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}
                    {include file="ProductListViewEntriesChuantou.tpl"}
                {else}
                    {include file="ListViewEntriesChuantou.tpl"}
                {/if}
                    </div>
                </div>
            </div>
        </td>
    </tr>
</table>

