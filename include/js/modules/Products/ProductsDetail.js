
var ProductsDetail = function () {
    var that = this;
    that.detailInit= function(){
        if(!empty(that.restBlocks)){
            var ContainShopDetail = that.restBlocks.ContainShopDetail;
            //这个判断是判断产品详情上方的那个图片轮播区域是否显示--订货商城开启 且 是从订货商城或者购物车打开才需要显示这块区域  BUG20241218-04
            if(ContainShopDetail=='yes')
                that.showPropertiesInfo();

            if(that.restBlocks['fieldValueList'] && that.restBlocks['fieldValueList'].length>0) {
                that.showProductPropertyDetails();
                var propertyBodyHtml = that.createPropertyTbodyHtml();
                that.productpropertyDiv.find('#productproperty_list_body').html(propertyBodyHtml);
            }
        }
    }
    that.showPropertiesInfo = function(){

        AjaxJSPage("ProductsPropertyChange_js", 'include/js/modules/Products/ProductsPropertyChange.js');

        var productsPropertyChangeObj = new productsPropertyChange();
        productsPropertyChangeObj.ProductsDetailObj = that;
        productsPropertyChangeObj.popupObj = that.popupObj;
        productsPropertyChangeObj.popupJqObj = that.popupJqObj;
        productsPropertyChangeObj.restBlocks = that.restBlocks;
        productsPropertyChangeObj.displayObj = that.displayObj;
        productsPropertyChangeObj.showProductShopDetail();
    }
    //属性组合表格的表体
    that.createPropertyTbodyHtml = function(){
        var restBlocks = that.restBlocks;
        var tableHeader = restBlocks['tableHeader'];
        var fieldArr = restBlocks['fieldArr'];
        var fieldValueList = restBlocks['fieldValueList'];
        var html = '';
        var line_number = 1;
        ld.each(fieldValueList,function(i,line){
            if(line.selected===true) {
                html += '<tr rowindex="' + line_number + '">';
                ld.each(fieldArr, function (j, fieldname) {
                    if(fieldname!='action') {
                        html += '<td detailfieldname="' + fieldname + '" class="ld-form-item-content-entry" >';
                        if (fieldname == 'attribute_combination') {
                            var attribute_combination_tmp = line[fieldname];
                            ld.each(attribute_combination_tmp, function (k, attr_info) {
                                html += attr_info['productproperty_name'] + ':' + attr_info['property_value_name'] + ' ';
                            });
                        } else if (fieldname == 'line_status' || fieldname == 'setdefault') {
                            html += line[fieldname] == 1 ? arrJsPopLabel['YES'] : arrJsPopLabel['NO'];
                        } else {
                            html += line[fieldname];
                        }
                        html += '</td>';
                    }
                });
                html += '</tr>';
                line_number++;
            }
        });
        return html;
    }
    that.showProductPropertyDetails= function(){
        var html = '<div tag="productproperty_div"><table class="ld-createedit-tablecontent" style="width:100%;table-layout: fixed;" cellspacing="0" cellpadding="0" border="0">\n' +
            '  <tbody><tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>';
        html += that.getBlockNameHtml();
        //属性表格的表头
        html += that.gettableHeaderHtml();
        html += '</tbody></table></div>';
        that.displayObj.after(html);
        that.productpropertyDiv = that.popupJqObj.find('[tag=productproperty_div]');
    }
    //区块名称html
    that.getBlockNameHtml= function(){
        var html = '<div class="DivCName DivCNamehover tip-items-list bindtip" data-direction="left" data-type="position" data-tip="'+arrJsPopLabel['COLLAPSE']+'" onclick="showHideStatus(\'productproperty_list_div\',\'ppdetailtitle\');">' +
            '<span class="" id="ppdetailtitle" name="ppdetailtitle"></span>'+arrJsPopLabel["Product_Property"]+'</div>'
        return html;

    }
    //属性组合表格的表头
    that.gettableHeaderHtml= function(){
        var html = '<tr tag="productproperty_block"><td colspan="4" class="ld-table-container ld-table-container-lines">';
        html += '<div name="productproperty_list_div">' +
            '<table name="productproperty_list" id="productproperty_list" cellspacing="0" cellpadding="0" border="0">' +
            '<thead>' +
            '<tr>';

        //表头的内容
        var tableHeaderArr = that.restBlocks.tableHeader;
        ld.each(tableHeaderArr,function(i,th){
            if(th.fieldtype!='action'){
                html += '<th width="'+th.width+'">'+th.label+'</th>';
            }

        });

        html += '</tr></thead>' +
            '<tbody id="productproperty_list_body"></tbody>' +
            '</table>' +
            '</div>';
        html += '</td></tr>';
        return html;
    }

}
ProductsDetail.moduleDetail= function() {
    var ProductsDetailObj = new ProductsDetail(),
        popupObj = ProductsDetailObj.popupObj = CrmPopup.getPopupObj('last'),
        popupJqObj = ProductsDetailObj.popupJqObj = ld(`#${popupObj.divid}`),
        displayObj = ProductsDetailObj.displayObj = popupJqObj.find('#DetailContent').find('[name="displayfields"]'),
        restBlocks = ProductsDetailObj.restBlocks = popupObj.moduleData.restBlocks;

    ProductsDetailObj.detailInit();
}