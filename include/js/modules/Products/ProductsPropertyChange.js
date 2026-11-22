function productsPropertyChange(){
    var that=this;
    that.flex_direction = 'column';
    that.imgwidth = '400';
    that.imgheight = '260';
    that.separator = '|##|';
    that.selectPropertiesCombin = '';//选中的属性组合 lineitem_id用|##|链接
    that.selectPropertiesValuenameCombin = '';//选中的属性组合 属性值名称
    that.productdetail_lineitem_id = '';//选中的产品属性
    //'haveSelected','confirmBtn','qty'
    that.pageHtmlArr = ['img','pname','price','kucun','productproperty','addcartBtn'];

    this.setSelectProductEvent = function(){
        that.popupJqObj.find('[tag=property_value_name]').unbind('click').bind('click',function(){
            var cur_productpropertyid = ld(this).data('productpropertyid');
            var cur_lineitem_id = ld(this).data('lineitem_id');
            that.selectPropertiesValuenameCombin = '';
            that.popupJqObj.find('#productpropertyid_'+cur_productpropertyid+' [tag=property_value_name]').removeClass('ld-tag-hollow-active');
            ld(this).addClass('ld-tag-hollow-active');

            var selectPropertiesCombin_arr = [];
            var productproperty_arr = that.restBlocks['productproperty_arr'];
            
            var activeObj = that.popupJqObj.find('#ProductDetailInfo').find('.ld-tag-hollow-active');
            ld.each(activeObj, function (j, tmpactiveObj) {
                selectPropertiesCombin_arr.push(ld(tmpactiveObj).data('lineitem_id'));
            });

            ld.each(productproperty_arr,function(i,propertyInfo) {
                if (propertyInfo.productpropertyid != cur_productpropertyid){
                    that.popupJqObj.find('#ProductDetailInfo [data-productpropertyid='+propertyInfo.productpropertyid+']').addClass('ld-tag-hollow-disable');
                }
            });

            that.selectPropertiesCombin = selectPropertiesCombin_arr.join(that.separator);//选择的组合 lineitem_id 用|##|拼接
            //获取价格
            var columnfields_value = that.popupObj.columnfields_value;
            columnfields_value.unit_price = columnfields_value.unit_price?columnfields_value.unit_price:'0.00';
            var fieldValueList = that.restBlocks['fieldValueList'];

            var price = columnfields_value.unit_price;
            ld.each(fieldValueList,function(i,linedata){
                if(linedata.propertydetail_lineitem_id_combin.indexOf(cur_lineitem_id)!=-1&&linedata.selected==true){
                    var tmppropertydetail_lineitem_id_combin = linedata.propertydetail_lineitem_id_combin.split(that.separator);
                    ld.each(tmppropertydetail_lineitem_id_combin,function(kk,tmplineitem_id){
                        that.popupJqObj.find('#lineitem_id_'+tmplineitem_id).removeClass('ld-tag-hollow-disable');
                    });
                }
                if(linedata.propertydetail_lineitem_id_combin == that.selectPropertiesCombin){
                    price = linedata.line_unit_price;//如果选了产品属性组合  展示产品属性的价格

                    that.productdetail_lineitem_id = linedata.lineitem_id;
                    that.selectPropertiesValuenameCombin = linedata.property_value_name_combin;
                    that.popupJqObj.find('[tag=haveSelected]').text(''+arrJsPopLabel['isselect']+':'+that.selectPropertiesValuenameCombin.split(that.separator).join(','));
                }
            });

            that.popupJqObj.find('[tag=productprice]').text('￥'+price);

            //图片
            if(that.pageHtmlArr.indexOf("img")!=-1) {
                ld.each(that.productImgArr, function (i, imginfo) {
                    if (imginfo.lineitem_id == that.productdetail_lineitem_id) {
                        that.swiper.slideTo(i);
                        return false;
                    }
                })
            }
        });

        that.popupJqObj.find('[tag=addtocartNew]').unbind('click').bind('click',function(){
            that.addtocartNew();
        });
        //购物车产品属性 更改 保存
        that.popupJqObj.find('[tag=save_cart_properties]').unbind('click').bind('click',function(){
            var cartid = that.cartid;
            var productdetail_lineitem_id = that.productdetail_lineitem_id;
            var productid = that.productid;
            ldAjaxNoProgress('index.php?module=Products&action=ProductsAjax&file=Cartchange&mode=saveCartProductProperty',
                {"cartid": cartid,"productid": productid,"productdetail_lineitem_id": productdetail_lineitem_id},
                function (ajaxdata) {
                    // 刷新购物车  属性 价格 总金额
                    ld('#ShopCartContent').html(ajaxdata.result.content);
                    change_tablewidth();//调整上下table标签的宽度
                    load_previewimg();//为产品图片设置预览功能，默认图片不可预览
                    shopcartObj.init();
                });
        });
        //购物车产品属性 取消
        that.popupJqObj.find('[tag=cartCancel]').unbind('click').bind('click',function(){
            that.popupJqObj.prev().removeClass('cart-selected');
            that.popupJqObj.html("");
            that.popupJqObj.hide();
        });
        //产品详情--创建订单
        that.popupJqObj.find('[tag=createNewPopup]').unbind('click').bind('click',function(){
            //var createmodule = 'SalesOrder';
            var createmodule = ld(this).data('module');
            var columnfields_value = that.popupObj.columnfields_value;
            var surl = "";
            surl += "&fromid="+columnfields_value['record_id']+"&frommodule=Products"+"&productdetail_lineitem_id="+that.productdetail_lineitem_id;
            var objparams = new CreatePagePopup.params();
            objparams.params['isduplicate'] = 'no';
            objparams.params['createdtype'] = 'create';
            CreatePagePopup.showpage(createmodule, surl ,objparams);
        })
    }
    //订货商城--产品详情显示图片区块
    this.showProductShopDetail = function(){
        ld('<link>', {
            rel: 'stylesheet',
            type: 'text/css',
            href: 'crmcommon/js/swiper/swiper-bundle.min.css'
        }).appendTo('head');

        var html = '<div tag="productShopDetail_div" class="ld-flex-start">';
        //左边--图片
        if(that.pageHtmlArr.indexOf("img")!=-1){
            html += '<div id="ProductCarouselImgsList" style="width:' + that.imgwidth + 'px;height:' + that.imgheight + 'px;">';
            html += that.loadCarouselImgs();
            html += '</div>';
        }
        //右边
        html += '<div id="ProductDetailInfo">';
        html += that.showProductCartDetail();
        html += '</div>';

        html += '</div>';
        html += that.confirmBtnHtml();
        if(that.displayObj){
            //产品详情的
            that.displayObj.before(html);
        }else{
            that.popupJqObj.html(html);
        }


        that.setSelectProductEvent();
        that.ProductShopDetailDiv = that.popupJqObj.find('[tag=productShopDetail_div]');

        if(that.pageHtmlArr.indexOf("img")!=-1) {
            getCommonJsScript('crmcommon/js/swiper/swiper-bundle.min.js', function () {
                that.swiper = new Swiper(that.popupJqObj.find('#swiper_171').get(0), {
                    // Optional parameters
                    direction: 'horizontal',
                    loop: true,
                    // If we need pagination
                    pagination: {
                        el: '.swiper-pagination',
                        clickable: true
                    },
                    // Navigation arrows
                    navigation: {
                        nextEl: '.swiper-button-next',
                        prevEl: '.swiper-button-prev',
                    },
                    autoplay: {
                        delay: 1000,
                        pauseOnMouseEnter: true,
                    },
                });
            });
        }
    }
    //轮播图
    this.loadCarouselImgs = function(){

        var imgArr = [];
        var image_main = that.popupObj.filejsondata;//主表图片
        if(!empty(image_main)){
            ld.each(image_main,function(fieldname,imgs){
                ld.each(imgs,function(i,imginfo) {
                    var tmpimg = {'path':imginfo.filepath_noEncrpt,'type':'main','title':''};
                    imgArr.push(tmpimg);
                });
            });
        }

        var image_detail = that.popupObj.detailfilejsondata;//分录图片

        if(!empty(image_detail)){
            ld.each(image_detail,function(j,linedata){
                ld.each(linedata,function(fieldname,imgs) {
                    ld.each(imgs, function (i, imginfo) {

                        var tmpimg = {'path': imginfo.filepath_noEncrpt, 'type': 'detail','title':'','lineitem_id':imginfo.lineitem_id};
                        imgArr.push(tmpimg);
                    });
                });
            });
        }
        if(imgArr.lenth==0){
            //默认图片
            var tmpimg = {'path': 'themes/images/default_cartimg.png', 'type': 'default'};
            imgArr.push(tmpimg);
        }
        that.productImgArr = imgArr;
        let stuffCon,
            carouselList = '',
            swiperId = 'swiper_171';
        ld.each(imgArr,function (index, info) {
            carouselList += '' +
                `<div class="swiper-slide">` +
                `<div class = "swiper-material-wrapper" >` +
                `<div class = "swiper-material-content" >` +
                `<img class = "material-image" data-swiper-material-scale = "1.25" src = "${info.path}" alt="${info.title}">` +
                `<span class = "material-label swiper-material-animate-opacity" >` +
                `${info.title}` +
                `</span>` +
                `</div>` +
                `</div>` +
                `</div>`;
        })
        stuffCon = `<div class="swiper swiper-material padL10 padR10" id="${swiperId}">` +
            `<div class="swiper-wrapper">` +
            carouselList +
            `</div>` +
            `<div class="swiper-pagination"></div>` +
            `<div class="swiper-button-prev"></div>` +
            `<div class="swiper-button-next"></div>` +
            `</div>`;
        return stuffCon;
    }
    //右边的产品信息
    this.showProductCartDetail = function(){
        var columnfields_value = that.popupObj.columnfields_value;

        columnfields_value.unit_price = columnfields_value.unit_price?columnfields_value.unit_price:'0.00';
        var price = parseFloat(columnfields_value.unit_price,10).toFixed(that.restBlocks.PriceDecimal);
        var discountprice = columnfields_value.unit_price;

        var ProductPropertyListHtml = "";
        if(that.restBlocks['fieldValueList'] && that.restBlocks['fieldValueList'].length>0){
            ProductPropertyListHtml = that.getProductPropertyListHtml();//所有的属性信息；
            var fieldValueList = that.restBlocks['fieldValueList'];
            ld.each(fieldValueList,function(i,linedata){
                if(linedata.propertydetail_lineitem_id_combin == that.selectPropertiesCombin){
                    discountprice = linedata.line_unit_price;
                    price = linedata.line_unit_price;//如果选了产品属性组合  展示产品属性的价格
                    that.productdetail_lineitem_id = linedata.lineitem_id;
                    return false;
                }
            })
        }
        var html = '<div class="ld-flex-start padL20 padTB10 padR20" style="flex-direction: '+that.flex_direction+';">';

        html += that.haveSelectedHtml();
        html += that.pnameHtml(columnfields_value.productname);
        //价格
        html += that.priceHtml(price,discountprice);
        //库存
        html +=that.kucunHtml(columnfields_value.qtyinstock);

        html += ProductPropertyListHtml;//所有的属性信息

        html += that.qtyHtml();

        //加入购物车 生成订单按钮
        html += that.addcartBtnHtml();

        html += '</div>';
        return html;
    }

    this.productproperty = function(ProductPropertyListHtml){
        return ProductPropertyListHtml;
    }
    this.pnameHtml = function(productname){
        if(that.pageHtmlArr.indexOf("pname")==-1){
            return '';
        }
        return '<div class="ld-pname-title marT5 marB5">'+productname+'</div>';
    }
    this.haveSelectedHtml = function(){
        if(that.pageHtmlArr.indexOf("haveSelected")==-1){
            return '';
        }
        return '<div class="marT5 marB5" style="text-align:left" tag="haveSelected">'+arrJsPopLabel['isselect']+':'+that.selectPropertiesValuenameCombin.split(that.separator).join(',')+'</div>';
    }
    this.priceHtml = function(price,discountprice){
        if(that.pageHtmlArr.indexOf("price")==-1){
            return '';
        }
        var html = '';
        html += '<div class="ld-flex-start ld-pname-title marT5 marB5">' +
            '<div class="padR10">'+arrJsPopLabel['Price']+'：</div>';//原价
        html += '<div class="ld-font-color-orange" tag="productprice">￥'+price+'</div>';
        if(discountprice<price){
            html += '<div class="padR10 padL10">'+arrJsPopLabel['discountprice']+'：</div>' +//优惠价
                '<div class="ld-font-color-orange" tag="productprice">￥'+discountprice+'</div>';
        }
        html += '</div>';
        return html;
    }
    this.kucunHtml = function(qtyinstock){
        if(that.pageHtmlArr.indexOf("kucun")==-1){
            return '';
        }
        qtyinstock = empty(qtyinstock)?0:qtyinstock;
        qtyinstock = parseFloat(qtyinstock, 10).toFixed(that.restBlocks.QuantityDecimal)
        return '<div class="ld-flex-start marT5 marB5"><div class="padR10">'+arrJsPopLabel['INVENTORY']+'：</div>' +
            '<div class="ld-font-color-orange" tag="qtyinstock">'+qtyinstock+'</div>' +
            '</div>';
    }

    this.qtyHtml = function(){
        if(that.pageHtmlArr.indexOf("qty")==-1){
            return '';
        }
        return '<div class="ld-flex-start ld-form-item-div marT5 marB5">' +
            '<div class="padR10">'+arrJsPopLabel['QTY']+':</div>' +
            '<div><input class="ld-input-inner" type="number" value="1"/></div>' +
            '</div>';
    }
    this.addcartBtnHtml = function(){
        if(that.pageHtmlArr.indexOf("addcartBtn")==-1){
            return '';
        }
        var createModuleArr = that.restBlocks['createModuleArr'];
        if(createModuleArr.length==0){
            return '';
        }
        var html = '<div class="ld-flex-start marT5 marB5 create-entity-toolbar lfloat prelative E_pop_tit_Second_Right">' +
            '<div class="ld-button" tag="addtocartNew">'+arrJsPopLabel['ADDTOCART']+'</div>' +
            '<div class="ld-button ld-button-primary" data-module="'+createModuleArr[0]['module']+'" tag="createNewPopup">' +
            '<span>'+arrJsPopLabel['ORDERIMMEDIATELY']+'</span>';

        if(createModuleArr.length>1){
            html += '<b class="ld-button-arrow-down"></b>';
        }
        if(createModuleArr.length>1) {
            html +=  '<ol class="D_more_menua" style="display: none;">';
            ld.each(createModuleArr,function(tmpi,tmpmoduleinfo){
                html += '<li tag="createNewPopup" data-module="'+tmpmoduleinfo['module']+'">\n' +
                    '<a title="'+tmpmoduleinfo['label']+'" style="margin:0;">'+tmpmoduleinfo['label']+'</a>\n' +
                    '</li>';
            });
            html += '</ol>';
        }
        html += '</div>';
        html +=  '</div>';
        return html;
    }
    this.confirmBtnHtml = function(){
        if(that.pageHtmlArr.indexOf("confirmBtn")==-1){
            return '';
        }

        var html = '<div class="ld-flex-center marT5 marB5">' +
            '<div class="ld-button  ld-button-primary" tag="save_cart_properties">'+arrJsPopLabel['Confirm']+'</div>' +
            '<div class="ld-button" tag="cartCancel">'+arrJsPopLabel['CANCEL']+'</div>' +
            '</div>';
        return html;
    }
    //单个添加购物车
    this.addtocartNew = function(){
        getJsScript('include/js/modules/Products/shopcart.js',function(){
            addtocarts(that.popupObj.columnfields_value['record_id'],that.productdetail_lineitem_id);
        });
    }
    //根据获取的属性数组 生成属性行html
    this.getProductPropertyListHtml = function(){
        //产品属性数组
        var productproperty_arr = that.restBlocks['productproperty_arr'];
        var html = '';

        var fieldValueList = that.restBlocks['fieldValueList'];
        console.log(fieldValueList)
        if(fieldValueList.length==0){
            return "";
        }
        if(that.productdetail_lineitem_id==''){
            ld.each(fieldValueList,function(i,linedata){
                if(linedata.setdefault ==1){
                    that.productdetail_lineitem_id = linedata.lineitem_id;
                    that.selectPropertiesCombin =  linedata.propertydetail_lineitem_id_combin;
                    that.selectPropertiesValuenameCombin = linedata.property_value_name_combin
                }
            });
            //如果没有设为默认的属性组合  取第一条为默认
            if(that.selectPropertiesCombin==''){
                that.productdetail_lineitem_id = fieldValueList[0].lineitem_id;
                that.selectPropertiesCombin =  fieldValueList[0].propertydetail_lineitem_id_combin;
                that.selectPropertiesValuenameCombin = fieldValueList[0].property_value_name_combin
            }
        }else{
            ld.each(fieldValueList,function(i,linedata){
                if(linedata.lineitem_id ==that.productdetail_lineitem_id){
                    that.selectPropertiesCombin =  linedata.propertydetail_lineitem_id_combin;
                    that.selectPropertiesValuenameCombin = linedata.property_value_name_combin
                }
            });
        }
        ld.each(productproperty_arr,function(i,propertyInfo){
            html += '<div class="ld-flex-start ld-form-item-div marT5 marB5" id="productpropertyid_'+propertyInfo.productpropertyid+'">' +
                '<div class="padR10">'+propertyInfo.productproperty_name+':</div>';
            ld.each(propertyInfo.details,function(j,propertydetail){
                var tmpsetdefaultclass='';
                var tmpDisable ='';
                if(propertydetail.selected==1){
                    if(that.selectPropertiesCombin.indexOf(propertydetail.lineitem_id)!=-1){
                        tmpsetdefaultclass='ld-tag-hollow-active';
                    }
                }else{
                    tmpsetdefaultclass = 'ld-tag-hollow-disable';
                    tmpDisable = 'style="pointer-events: none;cursor: not-allowed; background-color:#fefefe;" ';
                }

                html += '<div id="lineitem_id_'+propertydetail.lineitem_id+'" tag="property_value_name" data-productpropertyid="'+propertyInfo.productpropertyid+'" data-lineitem_id="'+propertydetail.lineitem_id+'" class="ld-button ld-tag-hollow '+tmpsetdefaultclass+'"  '+tmpDisable+'>'+propertydetail.property_value_name+'</div>';

            });
            html += '</div>';
        });

        return html;
    }
}
