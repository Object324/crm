/*
edit:duan
time:2021-8-30
reason:购物车的操作js，
*/
function shopcart(){
    var that=this;
    that.ShowPropertyEditDiv = '';


    this.init = function(){
        //价格政策
        AjaxJSPage('PricePolicyUse', 'include/js/modules/PricePolicy/PricePolicyUse.js');

        that.popupobj = new CrmPopup();
        that.popupobj.module = 'SalesOrder';//价格政策 作用范围是这个模块的
        that.divid = that.popupobj.divid = "ShopCartContent";
        that.popupJqObj = ld('#'+that.divid);
        that.detaildatavalue_arr = [];
        that.total = 0;
        CrmPopup.global_listPopupObj.push(that.popupobj);
        that.initEvent();
        that.getPricePolicyBlock();
    }
    this.getPricePolicyBlockInfo = function () {
        var pricePolicyBlock;
        var useObj = PricePolicyUse.getInstance(that.popupobj);
        ldAjaxsync(useObj.getAjaxUrl(), useObj.getUrlParam({
            funName: 'getPricePolicyBlockRequest',
            fromModule: that.popupobj.module,
            productLicencePrice:that.total,
            detailData: JSON.stringify(that.detaildatavalue_arr),
        }), function (data) {
            if(data.code === 1) {
                pricePolicyBlock = data.result;
            }
            DelProgressObjs();
        });
        return this.pricePolicyBlock = pricePolicyBlock;
    }
    this.getPricePolicyBlock = function(){
        that.getPricePolicyBlockInfo();
        var useObj = PricePolicyUse.getInstance(that.popupobj);
        useObj.popupJqObj = ld('#'+that.popupobj.divid);
        useObj.getBlockInfo = function () {
            return that.pricePolicyBlock;
        }
        useObj.getBlockData = function () {
            return useObj.getBlockInfo().val;
        }
        var cardsDivJqObj = useObj.getCardsDivJqObj();
        if(cardsDivJqObj && cardsDivJqObj.length > 0) {
            cardsDivJqObj.html(useObj.getCards());
        }
        else {
            var html = useObj.getBlock();
            that.popupJqObj.find('#CartPolicyBlock').html(html);
        }
        that.popupJqObj.find('[name=PricePolicyCard]').css('width','calc(100% - 20px)');
        useObj.init()
    }
    this.initEvent = function(){
        //购物车属性点击编辑事件
        that.popupJqObj.find('[tag=shopcart_propertyedit]').unbind('click').bind('click',function(e){
            that.closeChangeProperty(e);
            var cartid = ld(this).data('cartid');
            var productid = ld(this).data('productid');
            var productdetail_lineitem_id = ld(this).data('productdetail_lineitem_id');
            var propertydetail_lineitem_id_combin = ld(this).data('propertydetail_lineitem_id_combin');

            var tmpdivid = "shopcart_propertyedit_displaydiv_" + cartid;
            that.ShowPropertyEditDiv = tmpdivid;
            if(ld('#' + tmpdivid).css('display')!='none'){
                return false;
            }
            ld('#' + tmpdivid).show(500);
            ld('#rptContentLoading').show();
            ld(this).addClass('cart-selected');

            AjaxJSPage("ProductsPropertyChange_js", 'include/js/modules/Products/ProductsPropertyChange.js');
            ldAjaxNoProgress('index.php?module=Products&action=ProductsAjax&file=ProductPropertyApi&funName=getProductPropertyBlockRequest',
                {"productid": productid,"cartid": cartid},
                function (ajaxdata) {
                    var restBlocks = ajaxdata.result.restBlocks;
                    var tmppopupObj = new CrmPopup();

                    tmppopupObj.divid = tmpdivid;
                    var tmppopupJqObj = ld('#' + tmpdivid);

                    tmppopupObj.columnfields_value = ajaxdata.result.columnfields_value;//字段值信息
                    tmppopupObj.filejsondata = ajaxdata.result.filejsondata;//主表图片
                    tmppopupObj.detailfilejsondata = ajaxdata.result.detailfilejsondata;//分录图片

                    var tmpdisplayObj = that.popupJqObj.find('#shopcart_propertyedit_display_' + cartid);
                    var productsPropertyChangeObj = new productsPropertyChange();
                    productsPropertyChangeObj.pageHtmlArr = ['img','haveSelected','price','productproperty','confirmBtn'];
                    productsPropertyChangeObj.popupObj = tmppopupObj;
                    productsPropertyChangeObj.popupJqObj = tmppopupJqObj;
                    productsPropertyChangeObj.restBlocks = restBlocks;
                    productsPropertyChangeObj.imgwidth = 200;
                    productsPropertyChangeObj.imgheight = 160;
                    productsPropertyChangeObj.cartid = cartid;
                    productsPropertyChangeObj.productid = productid;
                    productsPropertyChangeObj.displayObj = '';
                    productsPropertyChangeObj.productdetail_lineitem_id = productdetail_lineitem_id;//选中的产品属性
                    productsPropertyChangeObj.showProductShopDetail();
                    //点击事件
                    var propertydetail_lineitem_id_combin_arr = propertydetail_lineitem_id_combin.split('|##|');
                    ld.each(propertydetail_lineitem_id_combin_arr,function(k,lineid){
                        tmppopupJqObj.find('#lineitem_id_'+lineid).click();
                    });

                    ld('#rptContentLoading').hide();
            });
        })
        //点击页面其他地方 将这个弹出框关闭
        ld(document).unbind('click').bind('click',function(e) {
            that.closeChangeProperty(e);
        });
    }

    this.closeChangeProperty = function(e){
        if(that.ShowPropertyEditDiv!='') {
            var tdobj = Tools.getParentobjByChild('#' + that.ShowPropertyEditDiv, 'td');
            ld(tdobj).find('[tag=shopcart_propertyedit]').removeClass('cart-selected');
            var dialog = ld('#' + that.ShowPropertyEditDiv);
            if (dialog.css('display') == 'none') {
                return false;
            }
            if (!tdobj.is(e.target) && tdobj.has(e.target).length === 0) {
                dialog.hide(); // 如果点击在对话框外部，则关闭对话框
            }
        }
    }
}


//添加到购物车
//zxm @date:2024/10/12 @reason: 产品添加购物车 产品选择属性组合
function addtocarts(record,productdetail_lineitem_id=0){
    var module = 'Products';
    var mode = 'add';
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Cartchange';
    surl += '&record=' +record+'&mode='+mode;
    ldAjax(surl,{productdetail_lineitem_id:productdetail_lineitem_id},function(data){
        if(data.code == 1){
            DelProgressObjs();
            var confirmstr = data.result.confirmstr;
            var cartdetail_num = data.result.cartdetail_num;
            var popupobj=CrmPopup.getPopupObj('last');
            ld("#"+popupobj.divid+" b[name=opencart]").html('['+cartdetail_num+']');
            MessagePopup.TipZero_success(confirmstr);
        }
    })
}

//批量添加到购物车
function mass_addtocart(){
    var mode = 'mass_add';
    var module = 'Products';
    var popupobj=CrmPopup.getPopupObj('last');
    var selectid =ld("#"+popupobj.divid+" [name=allselectedboxes]").val();
    var selectlen = 0;
    if (selectid != 'all') {//非全选状态，依次获取选中的单据ID
        var selectobj = document.getElementsByName("selected_id");
        var selectobjlen = selectobj.length;
        selectid = '';
        for (var i = 0; i < selectobjlen; i++) {
            if (selectobj[i].checked) {//获取选中的ID
                selectid += selectobj[i].value + ',';
                selectlen++;
            }
        }
        if (selectid == '') {//请至少选择一条记录
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
            return false;
        }
    } else {
        selectlen = parseInt(document.getElementById('numOfRows').value);//获取全选的条数
    }
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Cartchange';
    surl += '&selectid=' +selectid+'&selectlen='+selectlen+'&mode='+mode;
    //zkt 模块树结构显示增加条件，获取树结构点击条件
    if(ld("#isshowModuleListTree")!=undefined&&ld("#isshowModuleListTree").val()=='yes'){
	   surl += '&isshowModuleListTree=yes';
	}
    ldAjax(surl,"",function(data){
        if(data.code == 1){
            DelProgressObjs();
            var confirmstr = data.result.confirmstr;
            var cartdetail_num = data.result.cartdetail_num;
            var popupobj=CrmPopup.getPopupObj('last');
            ld("#"+popupobj.divid+" b[name=opencart]").html('['+cartdetail_num+']');
            // RemindsMsg("", "LdPopWidth400px", module, "yes", "yes",confirmstr);
            MessagePopup.TipOne_success(confirmstr);
        }
    })
}

//购物车界面显示
function opencart(){
    var url ="index.php?pageto_module=Products&pageto_action=Listview_cart";
    window.open(url,"_blank")
}
//删除一条购物车记录
function deletecart(cartid){
    var confirmstr = arrJsPopLabel['SUREWANTDELETE'];
    RemindsMsg("", "LdPopWidth400px","", "yes", "yes",confirmstr);
    var  popupobj=CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid+' .E_pbtnok').click(function(){
        var nodename = "shopcart_"+cartid;
        var element = ld("tr[name="+nodename+"]");
        element.remove();
        all_total_price();
        change_tablewidth();
        var mode = 'deletecart';
        var module = 'Products';
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Cartchange';
        surl += '&cartid=' +cartid+'&mode='+mode;
        ldAjax(surl,"",function(data){
            if(data.code == 1){
                DelProgressObjs();;
                checkShopcart();
            }
        })
    })
}
//批量删除记录
function mass_deletecart(){
    var checkbox_name = "checkbox_cart";
    var checkbox_objs = ld("input[name="+checkbox_name+"]");
    var tmp_cartid ;
    var cartid_str = "";
    var cartid_count = 0;
    ld.each(checkbox_objs,function(){
        if(ld(this).is(':checked')){
            cartid_count++;
        }
    });
    if(cartid_count==0){
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", "");
        return false;
    }
    var confirmstr = arrJsPopLabel['REMOVEWILLDELETEOTHER']+cartid_count+arrJsPopLabel['RECORDS']+'?';
    RemindsMsg("", "LdPopWidth400px","", "yes", "yes",confirmstr);
    var  popupobj=CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid+' .E_pbtnok').click(function(){
        ld.each(checkbox_objs,function(){
            if(ld(this).is(':checked')){
                tmp_cartid = ld(this).attr('cartid');
                var nodename = "shopcart_"+tmp_cartid;
                var element = ld("tr[name="+nodename+"]");
                element.remove();
                if(cartid_str==""){
                    cartid_str += tmp_cartid;
                }else{
                    cartid_str += "," + tmp_cartid;
                }
            }
        });
        //如果滚动条消失需要重设上下层的宽度
        change_tablewidth();
        all_total_price();
        var module = "Products";
        var mode = "mass_deletecart";
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Cartchange';
        surl += '&cartid_str=' +cartid_str+'&mode='+mode;
        ldAjax(surl,"",function(data){
            DelProgressObjs();
            checkShopcart();
        })
    }) 
}

//加减购物车数量
function quantity_button(obj){
    var cartid = ld(obj).attr('cartid');
    var changetype = ld(obj).attr('changetype');
    var divname = "quantity_"+cartid;
    var quantity_obj = ld("input[name="+divname+"]");
    var quantity = quantity_obj.val();
    if(ld.isNumeric(quantity)){
        quantity = parseFloat(quantity);
    }else{
        var confirmstr =arrJsPopLabel['ENTERCORRECTNUMBER'];
        cart_remind(quantity_obj,confirmstr,'number');
        return false;
    }
    if(changetype == 'add'){
        quantity += 1;
    }else{
        quantity -= 1;
    }
    if(quantity<1){//数量不能小于1
        quantity=1;
        var confirmstr =arrJsPopLabel['QUANTITYNOTLESS']+'1!';
        cart_remind(quantity_obj,confirmstr,'quantity');
    }
    //设置显示小数位
    var quantity_decimal = ld("span[name=total_quantity]").attr('quantity_decimal');
    quantity_obj.val(quantity.toFixed(quantity_decimal));
    quantity_change(quantity_obj.get(0));
}
//购物车数量变化
function quantity_change(obj){
    //设置显示小数位
    var quantity_decimal = ld("span[name=total_quantity]").attr('quantity_decimal');
    var price_decimal = ld("span[name=all_total_price]").attr('price_decimal');
    
    var cartid = ld(obj).attr('cartid');
    var quantity = ld(obj).val();
    if(ld.isNumeric(quantity)){ //判断输入的是不是数字
        quantity = parseFloat(quantity);
        if(quantity<1){
            quantity = (1).toFixed(quantity_decimal);
            ld(obj).val(quantity);
            var confirmstr =arrJsPopLabel['QUANTITYNOTLESS']+'1!';
            cart_remind(ld(obj),confirmstr,'quantity');
        }
    }else{
        quantity = (1).toFixed(quantity_decimal)
        ld(obj).val(quantity);
        var confirmstr =arrJsPopLabel['ENTERCORRECTNUMBER'];
        cart_remind(ld(obj),confirmstr,'number');
        return false;
    }
    var unit_price = ld("span[name=unit_price_"+cartid+"]").text();
    if(unit_price!=undefined &&parseFloat(unit_price)!=0){
        var total_price = parseFloat(unit_price)*quantity;
        ld("span[name=total_price_"+cartid+"]").text(total_price.toFixed(price_decimal));
    }
    all_total_price();
    var mode = 'quantity_change';
    var module = 'Products';
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Cartchange';
    surl += '&cartid=' +cartid+'&quantity='+quantity+'&mode='+mode;
    ldAjax(surl,"",function(data){
        if(data.code == 1){
            DelProgressObjs();
        }
    })
    
}
//全选按钮点击
function allselect(obj){
    var allcheck_name = "checkbox_all";
    var allcheck_obj = ld("input[name="+allcheck_name+"]");
    
    var checkbox_objs = ld("input[name='checkbox_cart']");
    //调整每行按钮和全选按钮状态
    if(ld(obj).is(':checked')){
        checkbox_objs.prop("checked",true);
        allcheck_obj.prop("checked",true);
        checkbox_objs.parent().parent().addClass('cartseleced');
    }else{
        checkbox_objs.prop("checked",false);
        allcheck_obj.prop("checked",false);
        checkbox_objs.parent().parent().removeClass('cartseleced');
    }	
    all_total_price();
}

//每一行的复选框点击事件
function cart_checkbox(obj){
    all_total_price();
    var allcheck_name = "checkbox_all";
    var allcheck_obj = ld("input[name="+allcheck_name+"]");
    if(!ld(obj).is(':checked')){
        allcheck_obj.prop("checked",false);
        ld(obj).parent().parent().removeClass('cartseleced');
    }
    else{
        ld(obj).parent().parent().addClass('cartseleced');
    }
}
//计算选中的产品总额
function all_total_price(){
    var span_name = "all_total_price";
    var checkbox_name = "checkbox_cart";
    var checkbox_objs = ld("input[name="+checkbox_name+"]");
    var tmp_quantity = 0;
    var sum_quantity = 0;
    var sum_price = 0;
    var tmp_price = 0;
    var cartid = 0;
    var productid = 0;
    var currency_symbol;//货币单位

    ld.each(checkbox_objs,function(){
        if(ld(this).is(':checked')){
            cartid = ld(this).attr('cartid');
            productid = ld(this).attr('productid');
            tmp_price = ld("span[name=total_price_"+cartid+"]").text();
            tmp_quantity = ld("input[name=quantity_"+cartid+"]").val();
            //货币单位
            currency_symbol = ld("span[name=total_price_"+cartid+"]").attr('currency_symbol');
            if(tmp_price!=undefined &&parseFloat(tmp_price)!=0){
                sum_price += parseFloat(tmp_price);
            }
            if(tmp_quantity!=undefined &&parseFloat(tmp_quantity)!=0){
                sum_quantity += parseFloat(tmp_quantity);
            }
            var tmpproductinfo = {'productid':productid,'quantity':tmp_quantity};
            shopcartObj.detaildatavalue_arr.push(tmpproductinfo);
        }
    });
    //设置显示小数位
    var quantity_decimal = ld("span[name=total_quantity]").attr('quantity_decimal');
    var price_decimal = ld("span[name=all_total_price]").attr('price_decimal');
    ld("span[name=total_quantity]").text((sum_quantity).toFixed(quantity_decimal));
    //添加货币单位
    if(currency_symbol != undefined){
        ld("span[name=all_total_price]").text(currency_symbol+sum_price.toFixed(price_decimal));
    }else{
        ld("span[name=all_total_price]").text(sum_price.toFixed(price_decimal));
    }
    //更改政策区块显示
    shopcartObj.total = sum_price;
    shopcartObj.getPricePolicyBlock();
}
//为图片设置点击显示大图事件
function load_previewimg(){
    var pic_objs = ld("div[id=Carouselsingle]");
    pic_objs.unbind('click').bind('click',function(){
        previewImage(this);
    })
}

//调整上下table宽度对齐
function change_tablewidth(){
    var windowHeight = ld(window).height();
    var cart_width = ld(".wrapper-panel-inner").width();
    ld(".ShopCartContent").css('width',cart_width+'px');
    ld(".ShopCartContent").css('height',windowHeight-68+'px');
    var left_width = cart_width-310;
    ld(".ShopCartLeft").css('width', left_width+'px');
    ld("table[name=cart_header]").css('width', left_width-40+'px');
    ld("table[name=cart_content]").css('width', left_width-40+'px');
    ld(".ShopCartLeft .ShopCartLeftSroll").css('height', windowHeight-60-8-40-50-50+'px');
}

//检查是否有对应模块的创建权限
function check_authority(){
    var radio_objs = ld("#ShopCartRightContent [name=chooserecord]");
    var selectdmodule = '';
    if(radio_objs != undefined){
        ld.each(radio_objs,function(){
            if(ld(this).is(':checked')){
                selectdmodule =ld(this).attr('frommodule');
            }
        })
    }

    var mode = 'create';
    var module = 'Products';
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Listview_cart';
    surl +='&mode='+mode;

    ldAjax(surl,"",function(data){
        DelProgressObjs();
        if(data.code==2){ //有两个以上权限时弹出选择框
            var module_permit = data.result.permit;
            for(var i=0;i<module_permit.length;i++){
                if(selectdmodule == module_permit[i]){
                    create_record(selectdmodule);
                    return false;
                }
            }
        }else if(data.code == 1){
            if(data.result.frommodule == selectdmodule){
                create_record(data.result.frommodule); //只有一种权限时直接显示新建弹出层
            }
        }else if(data.code == -1){
            DelProgressObjs();
            var confirmstr = data.result.confirmstr;
            RemindsMsg("", "LdPopWidth400px", module, "yes", "yes",confirmstr);
        }
    })
    
}

function create_record(module=""){
    var checkbox_name = "checkbox_cart";
    var checkbox_objs = ld("input[name="+checkbox_name+"]");
    var tmp_cartid ;
    var tmp_productid;
    var cartid_str = "";
    var productid_str = "";
    ld.each(checkbox_objs,function(){
        if(ld(this).is(':checked')){
            tmp_cartid = ld(this).attr('cartid');
            tmp_productid = ld(this).attr('productid')
            if(cartid_str==""){
                cartid_str += tmp_cartid;
                productid_str += tmp_productid;
            }else{
                cartid_str += "," + tmp_cartid;
                productid_str += "," + tmp_productid;
            }
        }
    });
    if(module!=undefined){ //通过弹出层选择需要创建的模块
        var radio_objs = ld("#ShopCartRightContent [name=chooserecord]");
        ld.each(radio_objs,function(){
            if(ld(this).is(':checked')){
                module =ld(this).attr('frommodule');
            }
        })
    }
        
    var surl = "";
    if(productid_str!=""){
        surl += "&fromid="+productid_str+"&frommodule=Products"+"&cartid="+cartid_str;
    }
    var objparams = new CreatePagePopup.params();
    objparams.params['isduplicate'] = 'no';
    objparams.params['createdtype'] = 'create';
    objparams.params['cartid'] = cartid_str;
    objparams.params['UpdateShopCartNew'] = UpdateShopCartNew;//更新购物车的函数传递过去
    CreatePagePopup.showpage(module, surl ,objparams);
} 
function UpdateShopCartNew(cartidstr){
    var cartid_arr = cartidstr.split(',');
    ld.each(cartid_arr,function(i,cartid){
        var nodename = "shopcart_"+cartid;
        var element = ld("tr[name="+nodename+"]");
        element.remove();
        all_total_price();
        //change_tablewidth();
        checkShopcart();
    })
}
function UpdateShopCart(product_url){
    var mode = 'update';
    var module = 'Products';
    var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Listview_cart&mode='+mode;
    ldAjax(surl,product_url,function(data){
        DelProgressObjs();
        if(data.code==1){
            location.reload();
        }
    })
}

//选择新建单据的类型时，点击后将其他按钮取消选中
function ChooseRecord(obj){
    var radio_objs = ld("#ShopCartRightContent [name=chooserecord]");
    radio_objs.prop("checked",false);
    ld(obj).prop("checked",true);
    
}

//避免多次提醒
function cart_remind(obj,confirmstr,type){
    if(obj.attr(type)!='yes'){
        RemindsMsg("", "LdPopWidth400px", "", "yes", "yes",confirmstr);
        obj.attr(type,'yes');
    }
}
function checkShopcart(){
    var cartNums = ld('.ShopCartTable tr[name*="cart"]');
    if(cartNums.length<1){
        ld("table[name=cart_content]").append(                
        '<tr>'+
        '<td style="height:340px;text-align:-moz-center;" colspan="9" align="center">'+
            '<div class="warningTableContent" style="z-index:600;">'+
                '<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?'+global_js_version+'"></div>'+
                '<div class="wtc_content">' + arrJsPopLabel['SHOPCARTEMPTY'] + '</div>'+
            '</div>'+
        '</td>'+
        '</tr>'
    );
    }
}

