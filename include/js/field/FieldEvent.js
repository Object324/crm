var FieldEvent = (function () {
    /**
     * 监听指定字段值的变化
     */
    class FieldEvent {
        constructor(module, fields) {
            this.module = module;
            this.fields = fields;
        }

        static getInstance(popupObj, module, fields) {
            if(!popupObj) {
                popupObj = CrmPopup.getPopupObj('last');
            }
            if(popupObj && popupObj.divid) {
                if(!module) {
                    module = popupObj.module;
                }
                if(!fields) {
                    fields = popupObj.column_fields || popupObj.fields;
                }
                return popupObj.FieldEventInstance ? popupObj.FieldEventInstance : (popupObj.FieldEventInstance = new FieldEvent(module, fields))
            }
            return new FieldEvent(module, fields);
        }

        set(columnName, eventFun, eventData) {
            var that = this,
                fieldInfo = that.fields[columnName],
                popupObj = CrmPopup.getPopupObj('last'),
                popupJqObj = ld(`#${popupObj.divid}`),
                tmpObj;
            if(typeof fieldInfo === "undefined") {
                return
            }
            var fieldName = fieldInfo.fieldname;
            //BUG0071549 liushuia 20230825 填写起始日期跟截止日期后自动计算出实际工时（不生效）
            if (/.*(d~|dt~|t~).*/.test(fieldInfo.typeofdata.toLocaleLowerCase())) {
                tmpObj = popupJqObj.find(' [name=' + fieldName + "]");
                tmpObj.unbind("blur", eventFun);
                tmpObj.bind("blur", eventData, eventFun);
            }
            else if(fieldInfo.bigtype === 'picklist'){
                tmpObj = popupJqObj.find(' [name=dv_cmb_' + fieldName + "]");
                tmpObj.unbind("click", eventFun);
                tmpObj.bind("click", eventData, eventFun);
            } else {
                if (fieldInfo.displaytype === 3) {
                    if (popupObj.module === "CashBill") {
                        tmpObj = popupJqObj.find(' [name=total]');
                    }
                    else if (popupObj.module === 'SendCashBill') {
                        tmpObj = popupJqObj.find(' [name=total]');
                    }
                    else if (fieldName === 'hdnGrandTotal') {
                        tmpObj = popupJqObj.find(' [name=total]');
                    }
                    //zkt 20220621 0051627(https://81mis.com/kfbtest/index.php)报价单页面设置》设置了字段  金额A  的公式为  合计*1  ；新建报价单时，分录显示异常
                    else if (fieldName === 'hdnSubTotal') {
                        tmpObj = popupJqObj.find(' [name=subtotal]');
                    }
                    else if (fieldName === 'txtAdjustment') {
                        //调整金额字段
                        tmpObj = popupJqObj.find(' [name=adjustment]');
                    }
                    else if (fieldName === 'hdnDiscountAmount') {
                        //整单折扣字段
                        tmpObj = popupJqObj.find(' [name=discount_amount]');
                    }
                } else {
                    tmpObj = popupJqObj.find(' [name=' + fieldName + "]");////ld("#"+that.popupobj.divid+" [name="+tmpcolumn+rowindex+"]")
                }
                if(tmpObj !== undefined){
                    tmpObj.unbind("change", eventFun)
                    tmpObj.bind("change", eventData, eventFun);
                }
            }
        }
    }

    return FieldEvent;
})()