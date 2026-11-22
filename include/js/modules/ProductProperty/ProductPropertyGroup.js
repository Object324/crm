/** @class  PropertyGroup */
var ProductPropertyGroup = (function () {
    if(ProductPropertyGroup) {
        return ProductPropertyGroup;
    }
    AjaxJSPage('PropertyGroupUtil', 'include/js/modules/ProductProperty/PropertyGroupUtil.js');
    /**
     * @class   PropertyGroup
     * @author  xll
     * @date    2023/10/26
     * - 单选产品属性组合的类
     * @description 用于产品属性组合的选择
     */
    class PropertyGroup extends PropertyGroupUtil{

        constructor(popupObj) {
            super(popupObj);
        }

        /** 根据时间戳生成单例ID */
        static getInstanceId() {
            return 'propertyGroup_' + (new Date - 0);
        }

        /**
         * 根据对象获取实例
         * @param {(Object | CrmPopup)} [obj=CrmPopup.getPopupObj('last') ] - Popup对象或其他对象
         * @return {PropertyGroup} 单例
         */
        static getInstance(obj) {
            var instanceId;
            if(!obj) {
                obj = CrmPopup.getPopupObj('last');
            }
            if(obj && obj instanceof Object) {
                if(obj.PropertyGroupInstanceId) {
                    instanceId = obj.PropertyGroupInstanceId;
                }
                else {
                    instanceId = obj.PropertyGroupInstanceId = this.getInstanceId();
                    this.instanceList[instanceId] = new PropertyGroup(obj);
                }
            }
            else {
                instanceId = this.getInstanceId();
                this.instanceList[instanceId] = new PropertyGroup();
            }
            return this.instanceList[instanceId];
        }

        /** 清空，释放内存 */
        static clearInstanceList() {
            ld.each(this.instanceList, function(index, instance) {
                if(instance.curPopupObj && instance.curPopupObj.PropertyGroupInstanceId) {
                    delete instance.curPopupObj.PropertyGroupInstanceId;
                }
            })
            this.instanceList = null;
            this.instanceList = {};
        }

        init() {
            super.init();
            this.availableList = {};
            this.selectedPropertyGroup = {};

            this.propertyRowList = {};
            this.propertyTrRowList = {};
        }

        getPropertyGroupHtml(productId, rowObj) {
            var that = this,
                { propertyArr } = that.getPropertyGroupByProduct(productId),
                colspan = rowObj.find('td').length,
                propertyGroupHtml = '';
            ld.each(propertyArr, function(index, propertyInfo) {
                var detailHtml = '';
                ld.each(propertyInfo.details, function(index, detailInfo) {
                    detailHtml += `<div class="propertyBtn ld-button ld-tag-hollow" property_detail="${detailInfo.lineitem_id}">${detailInfo.label}</div>`;
                })
                propertyGroupHtml += `` +
                    `<div class="propertyItem ld-flex-start ld-form-item-div" property_id="${propertyInfo.id}">` +
                        `<div class="propertyTitle">${propertyInfo.label}：</div>` +
                        `<div class="propertyContent ld-flex-start ld-form-item-div">` +
                            detailHtml +
                        `</div>` +
                    `</div>`;
            })
            return `` +
                `<tr id="tr_propertyGroup_${productId}" class="lvtColData lvtColDataSelected">` +
                    `<td></td>` +
                    `<td colspan="${colspan - 1}"><div id="propertyGroup_${productId}" class="propertyRow ld-flex-start ld-form-item-div">${propertyGroupHtml}</div></td>` +
                `</tr>`;
        }

        showPropertyGroup(checkObj) {
            // 价格政策不显示选择属性
            if(empty(this.recordPopupObj)) {
                return;
            }
            if(this.recordPopupObj.module === 'PricePolicy') {
                return;
            }
            // debugger;
            checkObj = ld(checkObj);
            var that = this,
                productId = checkObj.attr('billinfo'),
                rowObj = checkObj.parents('tr[record]');
            if(rowObj.attr('property_status') !== 'yes') {
                return;
            }
            var trJqObj = that.getPropertyTrJqObj(productId);
            // 直接展示
            if(trJqObj.length > 0) {
                trJqObj.show();
                return;
            }
            rowObj.after(that.getPropertyGroupHtml(productId, rowObj));

            that.updateAvailableBtn(productId);

            var btnList = that.getPropertyRowJqObj(productId).find('.propertyBtn');
            btnList.unbind('click').bind('click', function () {
                that.clickPropertyItem(ld(this));
            })
        }

        clickPropertyItem(btnObj) {
            if(btnObj.hasClass('ld-tag-hollow-disable')) {
                return ;
            }
            if(btnObj.hasClass('ld-tag-hollow-active')) {
                this.removePropertyValue(btnObj);
            }
            else {
                this.selectedPropertyValue(btnObj);
            }
        }

        getVariableByBtnObj(btnObj) {
            var propertyItem = btnObj.parents('.propertyItem'),
                propertyRow = propertyItem.parents('.propertyRow'),
                productId = propertyRow.attr('id').split('_').pop();
            this.propertyRowList[`_${productId}`] = propertyRow;
            return {
                productId,
                propertyItem,
                propertyId : propertyItem.attr('property_id'),
                propertyDetailId : btnObj.attr('property_detail'),
            }
        }

        removePropertyValue(btnObj) {
            var that = this,
                { productId, propertyItem, propertyId, propertyDetailId } = that.getVariableByBtnObj(btnObj);
            btnObj.removeClass('ld-tag-hollow-active');
            that.removeSelectedProperty(productId, propertyId);
            that.updateAvailableBtn(productId);
        }

        selectedPropertyValue(btnObj) {
            var that = this,
                { productId, propertyItem, propertyId, propertyDetailId } = that.getVariableByBtnObj(btnObj);
            // 先移除已选中
            propertyItem.find('.ld-tag-hollow-active').removeClass('ld-tag-hollow-active');
            // 标记选中
            btnObj.addClass('ld-tag-hollow-active');
            that.setSelectedProperty(productId, propertyId, propertyDetailId);
            that.updateAvailableBtn(productId);
        }

        /** @return {jQuery} */
        getBtnObj(productId, propertyId, propertyDetailId) {
            return this.getPropertyRowJqObj(productId).find(`[property_id="${propertyId}"]`).find(`[property_detail="${propertyDetailId}"]`);
        }

        /** @param {jQuery} btnObj */
        disabledPropertyValue(btnObj) {
            btnObj.addClass('ld-tag-hollow-disable');
        }

        /** @param {jQuery} btnObj */
        abledPropertyValue(btnObj) {
            btnObj.removeClass('ld-tag-hollow-disable');
        }

        updateAvailableBtn(productId) {
            var that = this,
                unAvailableArr = that.getAvailableArr(productId);

            ld.each(unAvailableArr, function(propertyId, propertyUnAvailable) {
                that.updatePropertyAvailableBtn(productId, propertyId, propertyUnAvailable)
            })
        }

        /** 更新单个属性的可用按钮 */
        updatePropertyAvailableBtn(productId, propertyId, propertyUnAvailable) {
            var that = this,
                { propertyGroupArr } = that.getPropertyGroupByProduct(productId),
                selectedProperty = deepAssign({}, that.getSelectedPropertyGroup(productId)),
                selectedFlag,
                propertyKey = 'property_'+propertyId;
            // 删去已选属性中的当前属性， 仅判断非当前属性的其他属性值是否对应
            if(selectedProperty[propertyKey]) {
                delete selectedProperty[propertyKey];
            }
            selectedFlag = Object.keys(selectedProperty).length > 0;
            ld.each(propertyGroupArr, function(index, info) {
                // 略过 continue
                // if(info.available === 'no') {
                //     return true;
                // }
                // 属性值判断
                if(selectedFlag) {
                    var flag = true;
                    ld.each(selectedProperty, function(key, val) {
                        if(info.value[key].lineitem_id !== val) {
                            return flag = false;
                        }
                    })
                    if(!flag) {
                        return true;
                    }
                }
                // 去掉可用
                ld.each(info.value, function(key, propertyInfo) {
                    var tmpKey = propertyInfo.lineitem_id;
                    if(propertyUnAvailable[tmpKey]) {
                        delete propertyUnAvailable[tmpKey];
                        that.abledPropertyValue(that.getBtnObj(productId, propertyInfo.id, propertyInfo.lineitem_id));
                    }
                })
            })

            ld.each(propertyUnAvailable, function(key, x) {
                var propertyDetailId = key,
                    btnObj = that.getBtnObj(productId, propertyId, propertyDetailId);
                that.disabledPropertyValue(btnObj);
            })
        }

        /**
         * 初始可用按钮列表对象， 每个键表示一个属性值对应的按钮
         * @param productId 产品id
         */
        getAvailableArr(productId) {
            var that = this,
                { propertyArr } = that.getPropertyGroupByProduct(productId),
                emptyArr = {};
            ld.each(propertyArr, function(i, info) {
                emptyArr[info.id] = {};
                ld.each(info.details, function(j, detailInfo) {
                    emptyArr[info.id][detailInfo.lineitem_id] = true;
                })
            })
            return emptyArr;
        }

        /** @return {jQuery} */
        getPropertyRowJqObj(productId) {
            return this.propertyRowList[`_${productId}`] || (this.propertyRowList[`_${productId}`] = this.getCurPopupJqObj().find(`#propertyGroup_${productId}`));
        }

        /** @return {jQuery} */
        getPropertyTrJqObj(productId) {
            var trJqObj = this.propertyTrRowList[`_${productId}`];
            if(!trJqObj) {
                trJqObj = this.getCurPopupJqObj().find(`#tr_propertyGroup_${productId}`);
                if(trJqObj.length > 0) {
                    this.propertyTrRowList[`_${productId}`] = trJqObj;
                }
            }
            return trJqObj;
        }

        hidePropertyGroup(checkObj) {
            checkObj = ld(checkObj);
            var that = this,
                productId = checkObj.attr('billinfo'),
                rowObj = checkObj.parents('tr[record]');
            if(rowObj.attr('property_status') !== 'yes') {
                return;
            }
            that.getPropertyTrJqObj(productId).hide();
        }

        /** @return {Object} */
        getSelectedPropertyGroup(productId) {
            var key = this.getProductKey(productId);
            return this.selectedPropertyGroup[key] || (this.selectedPropertyGroup[key] = {});
        }

        setSelectedProperty(productId, propertyId, propertyDetailId) {
            var selectedProperty = this.getSelectedPropertyGroup(productId);
            selectedProperty['property_'+propertyId] = propertyDetailId;
        }

        removeSelectedProperty(productId, propertyId) {
            var selectedProperty = this.getSelectedPropertyGroup(productId);
            delete selectedProperty['property_'+propertyId];
        }

        /** 获取产品对应的选中属性组合 */
        getProductPropertyGroup(productId) {
            var that = this,
                { propertyGroupArr, defaultIndex} = that.getPropertyGroupByProduct(productId),
                selectedProperty = that.getSelectedPropertyGroup(productId),
                selectedFlag = Object.keys(selectedProperty).length > 0,
                availableIndexArr = [],
                hasDefault = false;
            // 未选任何属性值
            if(!selectedFlag) {
                return propertyGroupArr[defaultIndex];
            }
            ld.each(propertyGroupArr, function(index, info) {
                var flag = true;
                ld.each(selectedProperty, function(key, val) {
                    if(info.value[key].lineitem_id !== val) {
                        return flag = false;
                    }
                })
                if(!flag) {
                    return true;
                }
                if(defaultIndex === index) {
                    hasDefault = true;
                }
                availableIndexArr.push(index);
            })
            // 符合已选属性值的仅一个
            if(availableIndexArr.length === 1) {
                return propertyGroupArr[availableIndexArr.pop()];
            }
            // 符合已选属性值的列表中包括默认
            if(hasDefault) {
                return propertyGroupArr[defaultIndex];
            }
            // 默认：符合已选值中的第一个
            return propertyGroupArr[availableIndexArr.shift()];
        }

        getProductPropertyInfo(opt) {
            return this.getProductPropertyGroup(opt.productId);
        }

        static showProductProperty(recordPopupObj, rowIndex, productInfo) {
            super.showProductProperty(recordPopupObj, rowIndex, productInfo);
            this.clearInstanceList();
        }
    }
    return PropertyGroup;
}) ()