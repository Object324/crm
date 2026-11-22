/** @class  PropertyGroupBase */
var PropertyGroupUtil = (function () {
    if(PropertyGroupUtil) {
        return PropertyGroupUtil;
    }
    /**
     * @class   PropertyGroupBase
     * @author  xll
     * @date    2023/10/26
     * - 选择产品属性组合的基类
     * @description 用于产品属性组合的选择
     */


    class PropertyGroupBase {

        constructor(popupObj) {
            if(popupObj && popupObj instanceof CrmPopup) {
                this.curPopupObj = popupObj;
            }
        }


        static getInstance() {
            return new PropertyGroupBase();
        }

        init() {
            var that = this,
                recordPopupObj = CrmPopup.getlastPopupObjByPageType('create_edit_modulepage');
            that.recordPopupObj = recordPopupObj;
            if(!recordPopupObj.productPropertyArr) {
                /** 存储每一行分录的产品属性值，键为 `product_${productId}_${rowIndex}` */
                recordPopupObj.productPropertyArr = {};
            }
            that.productPropertyGroupArr = recordPopupObj.productPropertyGroupArr = (recordPopupObj.productPropertyGroupArr || {});
        }

        getProductKey(productId) {
            return 'product_'+productId;
        }

        setPropertyGroupByProduct(productId) {
            var that = this;
            return ldAjaxsync(that.getAjaxUrl(), that.getUrlParam({
                funName: 'getPropertyGroupInfo',
                productid: productId,
            }), function (data) {
                if(data.code === 1) {
                    var key = that.getProductKey(productId);
                    that.productPropertyGroupArr[key] = data.result;
                    that.availableList[key] = [];
                }
                DelProgressObjs();
            })
        }

        getPropertyGroupByProduct(productId) {
            var that = this,
                key = that.getProductKey(productId);
            if(!that.productPropertyGroupArr) {
                that.init();
            }
            if(!that.productPropertyGroupArr[key]) {
                that.setPropertyGroupByProduct(productId)
            }
            return that.productPropertyGroupArr[key];
        }

        /** @return {jQuery} */
        getCurPopupJqObj() {
            return this.curPopupJqObj || (this.curPopupJqObj = ld(`#${this.curPopupObj.divid}`));
        }

        getAjaxUrl() {
            var that = this;
            if(!that.ajaxUrl) {
                that.ajaxUrl = `index.php?module=Products&action=ProductsAjax&file=ProductPropertyApi`;
            }
            return that.ajaxUrl;
        }

        getUrlParam(parmaArr) {
            var params = '';
            ld.each(parmaArr,function (key,val) {
                params += '&'+key+'='+encodeURIComponent(val);
            });
            return params;
        }

        getProductPropertyInfo(opt) {
            return opt.propertyGroup;
        }

        /**
         * 设置产品对象中的信息
         * @param {CrmPopup} popupObj 选择产品弹窗对象
         * @param rowIndex 行号
         * @param {Object} productInfo 产品对象
         * @param {Object} [propertyGroup] 可选参数：产品属性组合对象，用于多选
         */
        static setProductPropertyGroup(popupObj, rowIndex, productInfo, propertyGroup) {
            var productId = productInfo.productid,
                instance = this.getInstance(popupObj),
                // 直接传参则无需调用方法获取，用于多选
                propertyGroupInfo = instance.getProductPropertyInfo({ propertyGroup, productId }),
                recordPopupObj = instance.recordPopupObj,
                currencyKey = 'currency_' + recordPopupObj.selectproductobj.currencyid,
                currencyInfo = propertyGroupInfo.currencyInfo[currencyKey],
                costModuleArr = ['PurchaseOrder','PurchaseInquiryOrder','PurchaseBack','Stock','PurchaseInvoice'];
            productInfo.productdetail_lineitem_id = propertyGroupInfo.id;
            if(currencyInfo) {
                // productInfo.unit_price = currencyInfo.unit_price;
                // productInfo.procostprice = currencyInfo.procostprice;
                if(costModuleArr.includes(recordPopupObj.module)) {
                    productInfo.taxprice = productInfo.listprice = currencyInfo.procostprice;
                }
                else {
                    productInfo.taxprice = productInfo.listprice = currencyInfo.unit_price;
                }
            }
            // productInfo.propertyGroupInfo = propertyGroupInfo;
            recordPopupObj.productPropertyArr[`product_${productId}_${rowIndex}`] = propertyGroupInfo;
            return productInfo;
        }

        /**
         * 新增编辑弹窗
         * @typedef {CreatePagePopup | PageRecordPopup} recordPopupObj
         * @property {Object} productPropertyArr - 存储每一行分录的产品属性值，键为 `product_${productId}_${rowIndex}`
         */
        /**
         * 显示产品属性字段的内容
         * @param {CreatePagePopup | PageRecordPopup} recordPopupObj
         * @param rowIndex
         * @param productInfo
         */
        static showProductProperty(recordPopupObj, rowIndex, productInfo) {
            var productId = productInfo.productid,
                colName = 'productdetail_lineitem_id',
                propertyGroupInfo = recordPopupObj.productPropertyArr[`product_${productId}_${rowIndex}`],
                tdJqObj = recordPopupObj.getDetailFieldTdJqObj(rowIndex, colName);
            if(!propertyGroupInfo) {
                return;
            }
            var that = this,
                label = propertyGroupInfo.label.join('<br>'),
                productPropertyObj = tdJqObj.find('.productProperty');
            // 已有则修改内容即可
            if(productPropertyObj.length > 0) {
                productPropertyObj.find('.productPropertyLabel').html(label);
                return;
            }
            tdJqObj.find(`[name="${colName}"]`).hide();
            tdJqObj.find(`[name="span_${colName}"]`).hide();
            var con = '' +
                `<div class="productProperty ld-flex-start ld-form-item-div" name="productProperty" fieldName="${colName}">` +
                    // edit: xll 2024/10/24 XUQIU20240909-02 选择产品增加产品属性的选择（需求暂停）
                    // `<div class="ld-shopcart-property ld-shopcart-property-hover"><div class="productPropertyLabel lineheight20" >${label}</div></div>` +
                    `<div class="productPropertyLabel lineheight20" >${label}</div>` +
                    `<i class="productPropertyBtn ld-fonticon ld-fonticon-more ld-fonticon-more-circle" data-product="${productId}"></i>` +
                    `` +
                `</div>`;
            tdJqObj.append(con);
            var moreBtnObj = tdJqObj.find('.productPropertyBtn');
            moreBtnObj.unbind('click').click('click', function () {
                that.showMultiPropertyPopup(ld(this));
            })
        }

        static showMultiPropertyPopup(btnObj) {
            AjaxJSPage('MultiProductPropertyGroup', 'include/js/modules/ProductProperty/MultiProductPropertyGroup.js');
            MultiProductPropertyGroup.showPopup(btnObj);
        }
    }
    PropertyGroupBase.instanceList = {};
    return PropertyGroupBase;
}) ()