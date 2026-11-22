<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopupWindows.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/advancefilternew.js"></script>
{if $RELATED_MODULE eq 'Products' && $MODULE eq 'PriceBooks'}<script type="text/javascript" src="{$JSURL}include/js/modules/PriceBooks/PricebooksImportProduct.js"></script>{/if}

<div class="DivC" style="display: flex;flex-direction: column">
    {*  顶部按钮和翻页  *}
    <div class="Top" name="relatedList_header">
        <div class="D_btn_box b">
            <div class="D_anu_a">
                {$RELATEDLISTDATA.CUSTOM_BUTTON}
            </div>
            {if $showBasicSearchBtn eq 'yes'}
                <div class="marL15 marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv" name="basicSearchNewDiv" style="margin: 3px 5px 3px 0;">
                    {include file="PopupListViewBasicSearch.tpl"}
                </div>
            {/if}
        </div>
        <div style="width: 30%;float: right;padding-top: 3px">
            <div class="PageDiv0"  style="margin-top: 4px;margin-bottom:4px;">
                <div class="ld-flex-start">
                    <div class="ld-pagenum-div" name="totalDiv" id="totalDiv">{$RELATEDLISTDATA.navigation.0}</div>
                    <div name="pageDiv" id="pageDiv" style="display: flex">
                        {$RELATEDLISTDATA.navigation.1}
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div name="relatedList" id="relatedList">
        {include file="DetailView/RelatedListDataWithFixedColumnContent.tpl"}
    </div>

</div>