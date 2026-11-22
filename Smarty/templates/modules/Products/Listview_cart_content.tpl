
    <div class="ShopCartLeft" style="position: relative;">
        <table class="ShopCartTable ShopCartTableTitle" name="cart_header" border="0" cellspacing="0" cellpadding="0">
            <tr style="border:none;">
                <th style="width: 5%;"><input name="checkbox_all" cartid="{$cartid}" type="checkbox" onclick="allselect(this);"/></th>
                {foreach item=label from=$FILEDLABEL}
                <th style="width: {$TDWIDTH}%;">{$label}</th>
                {/foreach}
                <th style="width: 11%;">{'QUANTITY'|@getFixedLabel}</th> 
                <th style="width: 10%;">{'AMOUNT'|@getFixedLabel}</th>
                <th style="width: 6%;">{'OPERATING'|@getFixedLabel}</th>
            </tr>
        </table>
        <div class="ShopCartLeftSroll">
            <table class="ShopCartTable" name="cart_content" border="0" cellspacing="" cellpadding="0" style="table-layout: fixed;">
            {if sizeof($listview_entries) >0}
                {foreach key=cartid item=cartinfo from=$listview_entries}
                    <tr name="shopcart_{$cartid}" style="">
                        <td style="width: 5%;"><input name="checkbox_cart" cartid="{$cartid}" productid="{$cartinfo.productid}" type="checkbox" onclick="cart_checkbox(this)" /></td>
                        <td style="width: {$TDWIDTH}%;">
                        {if $cartinfo.imagepath neq ""}
                            <div id="Carouselsingle" style="text-align: center" >
                                <img src="{$cartinfo.imagepath}"  width="120px" border="0">
                            </div>
                        {else}{*默认图片不设置点击放大*}
                            <div id="defaultimg" style="text-align: center" >
                                <img src="themes/images/default_cartimg.png" width="120px" border="0">
                            </div>
                        {/if}
                        </td>

                        <td class="lineheight20" style="width: {$TDWIDTH}%;">

                        <a module="Products" record="{$cartinfo.productid}" href="javascript:;" lasturl="&ContainShopDetail=yes" onclick="ListLinkClick(ld(this),event)">{$cartinfo.productname}</a>
                        </td>
                        {*zxm @date:2024/10/17 @reason: 产品属性模块激活才显示这个td *}
                        {if $showProductProperty=='yes'}
                        <td style="width: {$TDWIDTH}%;">
                            {**zxm @date:2024/10/16 @reason:产品属性启用 才显示这个按钮 **}
                            {if $cartinfo.property_status==1}
                            <div class="ld-shopcart-property-div">
                                <div class="ld-shopcart-property {if $cartinfo.property_status==1}ld-shopcart-property-hover{/if}" tag="shopcart_propertyedit" data-cartid="{$cartid}" data-productdetail_lineitem_id="{$cartinfo.productdetail_lineitem_id}" data-productid="{$cartinfo.productid}" data-propertydetail_lineitem_id_combin="{$cartinfo.propertydetail_lineitem_id_combin}">
                                    <div class="lineheight20">{$cartinfo.productpropertystr}</div>
                                    <div class="ld-shopcart-property-edit">{'UPDATES'|@getFixedLabel}</div>
                                </div>
                                <div class="ld-shopcart-change-div padR10 padL10" id="shopcart_propertyedit_displaydiv_{$cartid}">
                                </div>
                            </div>
                            {/if}
                        </td>
                        {/if}
                        <td style="width: {$TDWIDTH}%;"><span>{$cartinfo.productsheet}</span></td>
                        <td style="width: {$TDWIDTH}%;">{$cartinfo.currency_symbol}<span style="border:none" currency_id="{$cartinfo.currency_id}" currency_symbol="{$cartinfo.currency_symbol}"  name="unit_price_{$cartid}" cartid="{$cartid}">{$cartinfo.unit_price}</span></td>
                        <td style="width: 11%;white-space:normal">
                            <input type="button" name="reduce" changetype="reduce" value="-" cartid="{$cartid}" onclick="quantity_button(this);" style="width:20%;height: 25px;background-color: #fff;border: 1px solid #dbdbdb;border-top-left-radius: 4px;border-bottom-left-radius: 4px;"/><input name="quantity_{$cartid}" cartid="{$cartid}"  onchange="quantity_change(this);" class="detailedViewTextBox bgwhite" style="width:50%;border-radius: 0;border: 0;border-top: 1px solid #dbdbdb;border-bottom: 1px solid #dbddbb;" type="text" value="{$cartinfo.quantity}" /><input type="button" name="add" changetype="add" value="+" cartid="{$cartid}" onclick="quantity_button(this);" style="width:20%;height: 25px;background-color: #fff;border: 1px solid #dbdbdb;border-top-right-radius: 4px;border-bottom-right-radius: 4px;"/>
                        </td>
                        <td style="width: 10%;">{$cartinfo.currency_symbol}<span name="total_price_{$cartid}" currency_id="{$cartinfo.currency_id}" currency_symbol="{$cartinfo.currency_symbol}" cartid="{$cartid}">{$cartinfo.total_price}</span></td>
                        <td style="width: 6%;"><a onclick="deletecart({$cartid})" style="cursor:pointer;">{'DELETE'|@getFixedLabel}</a></td>
                    </tr>
                {/foreach}
            {else} {*购物车为空时的提示信息*}
                <tr>  
                    <td style="height:340px;position: relative;" colspan="9" align="center">
                        {include file="NoRecords.tpl" NoRecords_CONTENT={'SHOPCARTEMPTY'|@getFixedLabel} NoRecords_IMGSTYLE="margin-left:50px"}
                    </td>
                </tr>
            {/if}
          	</table>
        </div>
        <div class="ShopCart_float" name="Cartfloat">
            <input style="margin-bottom: 1px;" id="allcartchecked" name="checkbox_all" cartid="{$cartid}" type="checkbox" onclick="allselect(this);"/>
            <label class="marL5" for="allcartchecked">{'ALLSELECT'|@getFixedLabel}</label>
            <a class="marL20" onclick="mass_deletecart()" >{'DELETE'|@getFixedLabel}</a>
        </div>
    </div>
    <div class="ShopCartRight" style="overflow-y: auto;">
        <div id="CartPolicyBlock" >

        </div>
        <div class="ShopCartRightHeader">
            <div class="ShopCartRightQtyAmount">{'SELECTEDPRODUCT'|@getFixedLabel}{'QUANTITY'|@getFixedLabel}：<span quantity_decimal="{$QUANTITYDECIMAL}" name="total_quantity">{"0"|number_format:$QUANTITYDECIMAL}</span></div>
            <div class="ShopCartRightQtyAmount">{'TotalAmount'|@getFixedLabel}：<span name="all_total_price" price_decimal="{$PRICEDECIMAL}">{"0"|number_format:$PRICEDECIMAL}</span></div>
        </div>
        <div class="ShopCartRightContent" id="ShopCartRightContent">
            {foreach key=tmpindex item=tmpmodulename from=$MODULEPERMIT}
                <div class="select-input">
                    <input id="choose{$tmpmodulename}" name="chooserecord" type="radio" frommodule="{$tmpmodulename}" onclick="ChooseRecord(this)" {if $tmpindex eq 0}checked=""{/if}><label for="choose{$tmpmodulename}">{{$tmpmodulename}|@getTranstab}</label>
                </div>
            {/foreach}
        </div>
        <div class="ShopCartRightFooter"><a onclick="check_authority()" class="ld-button ld-button-primary">{'NEWDOCUMENT'|@getFixedLabel}</a></div>
    </div>
