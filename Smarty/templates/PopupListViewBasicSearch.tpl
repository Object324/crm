<div id="basicsearchcolumns_real" style="width:100px;">
    {*onchange事件  去获取基本查找历史*}
    <select name="search_field" id="bas_searchfield" class="commonSelectPop gwidth100" style="border-radius: 4px 0 0 4px;border-right:none;">
        {if $MODULE eq 'SalesOrder' && $FROMMODULE eq 'ServiceContracts' &&  $POPUPTYPE eq 'specific'}<option value="all">{'AllFields'|@getFixedLabel}</option>{/if}
        {html_options  options=$SEARCHLISTHEADER selected=$SEARCHFIELDNAME}
    </select>
</div>
<div class="ld-listview-basicsearch">
    <input type="text" class="commonSelectPop gwidth100 padR40" onclick="advanceFilterSearch.getInstance().getBasicFieldSearchHistoryNew(this)"
           onkeyup="{if $RELATED_MODULE eq 'Products' && $MODULE eq 'PriceBooks'}fun_ProductPriceBooks.getInstance().searchRelatedProductsByEnter(this,event){else}fun_setCrmPopupWindow.searchSubmit(event,'Basic'){/if}"
           name="search_text" value="{$SEARCHVALUE}" autocomplete="off" style="border-radius: 0 4px 4px 0;"
           oninput="{if $RELATED_MODULE eq 'Products' && $MODULE eq 'PriceBooks'}{else}fun_setCrmPopupWindow.showClearBtn(this){/if}">
    <b style="position: absolute;right:30px;top:0;cursor: pointer;display:none" name="clearSearchBtn" id="clearSearchBtn" class="ld-icon-clearsearch" onclick="fun_setCrmPopupWindow.clearPopupLayerSearch(this);"></b>
    <b class="categorysear-search ld-listview-search" id="listview-search" name="listview-search"
       {if $RELATED_MODULE eq 'Products' && $MODULE eq 'PriceBooks'}onclick="fun_ProductPriceBooks.getInstance().searchRelatedProducts()"{else}onclick="fun_setCrmPopupWindow.callSearch('Basic');"{/if}>

    </b>
    <div style="position: absolute;right:0;top:30px;width:100%;background-color: #fff;z-index:902;">
        <ol class="D_more_menua_searchbtn" id="basicSearchList">
        </ol>
    </div>
</div>