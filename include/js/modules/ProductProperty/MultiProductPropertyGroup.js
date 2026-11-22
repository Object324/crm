/** @class  MultiPropertyGroup */
var MultiProductPropertyGroup = (function () {
    if(MultiProductPropertyGroup) {
        return MultiProductPropertyGroup;
    }
    AjaxJSPage('PropertyGroupUtil', 'include/js/modules/ProductProperty/PropertyGroupUtil.js');
    /**
     * @class   MultiPropertyGroup
     * @author  xll
     * @date    2023/10/26
     * - 多选产品属性组合的类
     * @description 用于产品属性组合的选择
     */
    class MultiPropertyGroup extends PropertyGroupUtil{

        constructor(popupObj) {
            super(popupObj);
        }

        /** 根据时间戳生成单例ID */
        static getInstanceId() {
            return 'multiPropertyGroup_' + (new Date - 0);
        }

        /** @return {MultiPropertyGroup} */
        static getInstance(obj) {
            var instanceId;
            if(!obj) {
                obj = CrmPopup.getPopupObj('last');
            }
            if(obj && obj instanceof Object) {
                if(obj.MultiPropertyGroupInstanceId) {
                    instanceId = obj.MultiPropertyGroupInstanceId;
                }
                else {
                    instanceId = obj.MultiPropertyGroupInstanceId = this.getInstanceId();
                    this.instanceList[instanceId] = new MultiPropertyGroup(obj);
                }
            }
            else {
                instanceId = this.getInstanceId();
                this.instanceList[instanceId] = new MultiPropertyGroup();
            }
            return this.instanceList[instanceId];
        }

        /** 清空，释放内存 */
        static clearInstanceList() {
            ld.each(this.instanceList, function(index, instance) {
                if(instance.curPopupObj && instance.curPopupObj.MultiPropertyGroupInstanceId) {
                    delete instance.curPopupObj.MultiPropertyGroupInstanceId;
                }
            })
            this.instanceList = null;
            this.instanceList = {};
        }

        static showPopup(btnObj) {
            if(btnObj.data('product') === undefined) {
                return;
            }
            var title = arrJsPopLabel["selectproperties"],
                width = 'LdPopWidth800px',
                module = 'Products',
                okText = arrJsPopLabel['CONFIRMED'],
                cancelText = arrJsPopLabel['CANCEL'],
                popupObj = CrmPopup.load(title,  '',"", width, module, '', okText, "", cancelText),
                instance = this.getInstance(popupObj);
            popupObj.setParams(title, () => instance.confirmFun(), '', width, module, '', okText, '', cancelText);
            instance.init();
            instance.setBtnObj(btnObj);
            instance.show();
            instance.setEvent();
        }

        show() {
            // debugger;
            var that = this,
                popupObj = this.curPopupObj,
                { propertyGroupArr, theadArr, } = that.getPropertyGroupByProduct(that.productId),
                thead = '', tbody = '', conHtml = '';
            popupObj.prevshow();
            ld.each(theadArr,function(i, thLabel){
                thead += `<th>${thLabel}</th>`;
            })
            ld.each(propertyGroupArr, function(i, line){
                var trClassArr = [],
                    propertyTd = '', combinLabelArr = [];
                i%2 === 0 ? trClassArr.push("lvtColDataBj") : trClassArr.push("lvtColData");
                ld.each(line.value, function(j, propertyInfo) {
                    propertyTd += `<td class="ld-form-item-content" >${propertyInfo.label}</td>`;
                    combinLabelArr.push(propertyInfo.label);
                })
                tbody += `` +
                    `<tr class="${trClassArr.join(' ')}" row-index="${i}">` +
                        `<td style="width:25px;" class="ld-form-item-content">` +
                            `<input type="checkbox" class="propertyGroupItem" data-lineitem_id="${line.id}" data-index="${i}">` +
                        `</td>` +
                        `<td class="ld-form-item-content" >${combinLabelArr.join('/')}</td>` +
                        `${propertyTd}` +
                    `</tr>`;
            });
            conHtml = '' +
                '<div class="ld-description">' +
                    '<b class="info-icon"></b>' +
                    `<div class="ld-description-content">${arrJsPopLabel['properties_explanation']}</div>` +
                '</div>' +
                '<div id="MergeTableDiv" class="ld-table-container ld-table-container-lines ld-table-container-bgcolor" style="overflow: auto; width: 100%; max-height: 492px; height: 492px;">' +
                    '<table id="productproperty_select_list" class="MergeTable marT10" width="100%" cellspacing="0" cellpadding="0" border="0">' +
                        `<thead><tr>${thead}</tr></thead>` +
                        `<tbody>${tbody}</tbody>` +
                    `</table>` +
                `</div>`;
            CrmPopup.setPopupobjHtmlContent_scroll(popupObj, conHtml);
            popupObj.center();
        }

        init() {
            super.init();
            this.selectedProductDetail = {};
        }

        setBtnObj(btnObj) {
            var rowObj = btnObj.parents('tr[rowindex]').first(),
                rowIndex = rowObj.attr('rowindex');
            this.btnObj = btnObj;
            this.productId = btnObj.data('product');
            this.rowIndex = parseInt(rowIndex);
        }

        getTableJqObj() {
            return this.tableJqObj || (this.tableJqObj = this.getCurPopupJqObj().find(`#productproperty_select_list`));
        }

        setEvent() {
            var that = this,
                tableJqObj = that.getCurPopupJqObj(),
                itemList = tableJqObj.find('.propertyGroupItem');
            //双向绑定
            itemList.unbind('click').bind('click', function () {
                that.setSelectedProductDetail(ld(this));
            })
        }

        setSelectedProductDetail(checkObj) {
            var that = this,
                productDetailId = checkObj.data('lineitem_id'),
                key = 'productDetail_' + productDetailId,
                index = checkObj.data('index');
            if(checkObj.prop('checked')) {
                this.selectedProductDetail[key] = index;
            }
            else {
                delete this.selectedProductDetail[key];
            }
        }

        getSelectedProductDetail() {
            return this.selectedProductDetail;
        }

        confirmFun() {
            var that = this,
                index = 0,
                btnObj = that.btnObj,
                rowIndex = that.rowIndex,
                popupObj = that.curPopupObj,
                recordPopupObj = that.recordPopupObj,
                selectedList = that.getSelectedProductDetail(),
                { propertyGroupArr, } = that.getPropertyGroupByProduct(that.productId);
            popupObj.CancelEvent();
            ld.each(selectedList, function(key, propertyGroupIndex) {
                // 复制行
                ProductCopyRowAfterassingIndex(btnObj);
                index ++;
                // 设置并显示对应的产品属性值
                var productDetailId = key.split('_').pop(),
                    propertyGroupInfo = propertyGroupArr[parseInt(propertyGroupIndex)],
                    tmpRowIndex = rowIndex + index,
                    tmpDetailRowInfo = recordPopupObj.detaildatavalue_arr[tmpRowIndex - 1];
                MultiProductPropertyGroup.setProductPropertyGroup(popupObj, tmpRowIndex, tmpDetailRowInfo, propertyGroupInfo);
                MultiProductPropertyGroup.showProductProperty(recordPopupObj, tmpRowIndex, tmpDetailRowInfo);

                btnObj = recordPopupObj.getDetailRowJqObj(tmpRowIndex).find('.productPropertyBtn');
            });

            // 释放内存
            MultiProductPropertyGroup.clearInstanceList();
        }
    }
    return MultiPropertyGroup;
}) ()