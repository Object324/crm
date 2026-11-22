
var PricePolicy = (function () {
    var instanceList = PricePolicy ? PricePolicy.getInstanceList() : {};
    class PricePolicyUtil {
        constructor() {
            this.module = 'PricePolicy';
            this.child = {
                Edit: function () {
                    return new PricePolicyEdit()
                },
                Detail: function () {
                    return new PricePolicyDetail()
                },
                Use: function () {
                    return new PricePolicyUse()
                },
                UseDetail: function () {
                    return new PricePolicyUseDetail()
                },
                Set: function () {
                    return new PricePolicySet()
                },
            }
            this.fieldCon = {

            }
        }

        static getInstanceList() {
            return instanceList;
        }

        /**
         * 根据对象获取实例
         * @param {(CrmPopup | HTMLElement)} [obj=CrmPopup.getPopupObj('last') ] - Popup对象或DOM对象
         * @return {PricePolicyUtil} 单例
         */
        static getInstance(obj) {
            var instanceId;
            if(!obj) {
                obj = CrmPopup.getPopupObj('last');
            }
            if(obj) {
                if(obj.PricePolicyInstanceId) {
                    instanceId = obj.PricePolicyInstanceId
                }
                else {
                    instanceId = obj.PricePolicyInstanceId = ('pricePolicy_' + (new Date - 0));
                    instanceList[instanceId] = new PricePolicyUtil();
                }
            }
            else {
                instanceId = 'pricePolicy_' + (new Date - 0);
                instanceList[instanceId] = new PricePolicyUtil();
            }
            return instanceList[instanceId];
        }

        getChildInstance(child) {
            if(!this[child+'Instance']) {
                AjaxJSPage(`PricePolicy${child}`, `include/js/modules/PricePolicy/PricePolicy${child}.js`);
                this[child+'Instance'] = this.child[child]();
            }
            return this[child+'Instance'];
        }

        /**
         * 返回编辑类实例
         * @return {PricePolicyEdit}
         */
        getEditInstance() {
            return this.getChildInstance('Edit');
        }

        /**
         * 返回详情类实例
         * @return {PricePolicyDetail}
         */
        getDetailInstance() {
            return this.getChildInstance('Detail');
        }

        /**
         * 返回使用类实例
         * @return {PricePolicyUse}
         */
        getUseInstance() {
            return this.getChildInstance('Use');
        }

        /**
         * 返回使用类实例
         * @return {PricePolicyUseDetail}
         */
        getUseDetailInstance() {
            return this.getChildInstance('UseDetail');
        }

        /**
         * 返回设置类实例
         * @return {PricePolicySet}
         */
        getSetInstance() {
            return this.getChildInstance('Set');
        }

        getAjaxUrl() {
            var that = this;
            if(!that.ajaxUrl) {
                that.ajaxUrl = `index.php?module=Users&action=UsersAjax&file=PricePolicyApi`;
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

        getTable(tableId, thead, tbody, classArr, extraAttrArr) {
            return '' +
                `<table id="${tableId ? tableId : ''}" class="${Array.isArray(classArr) ? classArr.join() : ''}" cellspacing="0" cellpadding="0" border="0" ${Array.isArray(extraAttrArr) ? extraAttrArr.join() : ''}>` +
                    `<thead><tr>${thead}</tr></thead>` +
                    `<tbody>${tbody}</tbody>` +
                '</table>';
        }

        getTableInner(block,rowProp) {
            var that = this,
                data = block.data,
                thead = '',
                tbody = '';
            ld.each(data.head,function (index,th) {
                thead += `<th width="${th.width}">${th.label}</th>`;
            })
            ld.each(data.val,function (index,tr) {
                tbody += that.getTableTrRow(index, data, rowProp);
            })
            block.extraRow && ( tbody += block.extraRow );
            return {thead, tbody};
        }

        /**
         * 获取 表格行
         * @param index 行索引
         * @param blockData 表头字段列表
         * @param rowProp 获取行索引的方法，或行索引对应的键
         */
        getTableTrRow(index, blockData, rowProp) {

            var that = this,
                trVal = blockData.val[index],
                tdList = '',
                rowIndex = (typeof rowProp === "string") ? trVal[rowProp] : index;

            ld.each(blockData.head,function (i,th) {
                var field = th.field,
                    val = that.getFieldCon(index, blockData, field)
                tdList += `<td class="ld-form-item-content-entry" width="${th.width}" col-field="${field}">${val}</td>`;
            })
            return `<tr row-index="${rowIndex}" >${tdList}</tr>`;
        }

        getFieldCon(rowIndex,blockData,field) {
            return (typeof this.fieldCon[field] === "function") ? this.fieldCon[field](rowIndex, blockData, field) : blockData.val[rowIndex][field];
        }

    }

    return PricePolicyUtil;
})();