{*订货商城展示内容*}
    {if $noofrows >0 }
    <div class="ld-flex-start padB20 ld-bg-color" style="height:300px;flex-wrap: wrap;overflow-y: auto;" id="resize_content_table_divid">
    {foreach $productdata as $pid=>$linedata}
        <a module="Products" record="{$pid}" href="index.php?pageto_module=Products&pageto_action=index&pageto_record={$pid}" lasturl="&ContainShopDetail=yes" onclick="ListLinkClick(ld(this),event)" class="marL10 marR10 marT20 padLR10 padT10 padB10 ld-shopcart-item">
            <div class="ld-flex-center padL20 padR20 padTB10"><img src="{$linedata['imagename']}" style="height:100px;display:block;"></div>
            {foreach $list_fieldname as $k=>$tmpfieldname}
                {if $tmpfieldname=='imagename'}

                {elseif $tmpfieldname=='productname'}
                    <div class="ld-overflow-hidden-listcontent ld-pname-title tip-items-list marT5 marB5" data-tip="{$linedata.productname}" data-direction="top" data-type="position">{$linedata.productname}</div>
                {elseif $tmpfieldname=='unit_price'}
                    <div class="ld-font-color-orange">￥{$linedata.unit_price}</div>
                {else}
                    <div class="ld-overflow-hidden-listcontent marT5 marB5">{$linedata[$tmpfieldname]}</div>
                {/if}
            {/foreach}
        </a>
    {/foreach}
    </div>
    {else}
    <div class="ld-flex-start padB20" style="height:300px;flex-wrap: wrap;overflow-y: auto;background-color: #fff;" id="resize_content_table_divid">
        <div class="warningTableContent" style="z-index:600;padding-top:30px;">
            <div class="wtc_img" style="margin: auto;text-align: center;">
                <img src="themes/icon2023/ld-no-records.png"></div>
            <div class="wtc_content" style="text-align: center;">{'NODATAFOUND'|@getFixedLabel}</div>
        </div>
    </div>
    {/if}
