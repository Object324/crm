
var PricePolicyDetail = (function () {
    AjaxJSPage('PricePolicyEdit', 'include/js/modules/PricePolicy/PricePolicyEdit.js');
    class PricePolicyDetail extends PricePolicyEdit {
        constructor() {
            super();
        }

        initProperty() {
            super.initProperty();
            var that = this;

            that._initProperty();
        }

        _initProperty() {
            var that = this;
            that.rulesCon.selProduct = function (rowVal,rowIndex,name = 'productname') {
                var productName = rowVal[name] ? decodeURIComponent(rowVal[name]) : '';
                return that.rulesCon.label(productName);
            }
            that.rulesCon.input = (function () {
                var index = 0, lastRowIndex;
                return function (rowVal, rowIndex, name) {
                    var val = rowVal[name];
                    if(name === "condition[]") {
                        index = index % 2;
                        if(lastRowIndex === rowIndex)
                            index ++;
                        else
                            index=0;
                        val = rowVal['condition'][index];
                        lastRowIndex = rowIndex;
                    }
                    return that.rulesCon.label(val);
                }
            })()
        }

        /** @return {PricePolicyDetail} */
        static getInstance(obj) {
            return super.getInstance(obj).getDetailInstance();
        }

        moduleDetail() {
            var that = this,
                popupObj = that.popupObj = CrmPopup.getPopupObj('last'),
                popupJqObj = that.popupJqObj = ld(`#${popupObj.divid}`),
                displayObj = popupJqObj.find('#DetailContent').find('[name="displayfields"]'),
                restBlocks = popupObj.moduleData.restBlocks;
            // 重新初始化闭包中的值
            that._initProperty();
            ld.each(restBlocks,function (index,block) {
                displayObj.append(that.getBlock(block));
            })
        }

        blockUtil(block, blockCon) {
            return this.blockTitle(block.title, block.conId) + this.blockCon(blockCon, block.conId);
        }

        blockTitle(title, conId) {
            return '' +
            `<table width="100%" cellSpacing="0" cellPadding="0" border="0">` +
                `<tbody>` +
                `<tr width="100%">` +
                    `<td colSpan="4">` +
                        `<div class="DivCName DivCNamehover tip-items-list bindtip" data-direction="left" data-type="position" data-tip="收起"` +
                             `onClick="showHideStatus('${conId}','aid_${conId}');">` +
                            `<span class="" id="aid_${conId}" name="aid_${conId}"></span>` +
                            `${title}` +
                        `</div>` +
                    `</td>` +
                `</tr>` +
                `</tbody>` +
            `</table>`;
        }

        blockCon(blockCon, conId) {
            return '' +
                `<div class="DivCNotice ld-shadow-first ld-table-container ld-table-container-lines" style=" display: block;" id="${conId}" name="${conId}">` +
                    `${blockCon}` +
                `</div>`;
        }

        getDetailCon(block) {
            var that = this,
                data = block.data;
            that.popupObj.js_detailtablename = that.detailConId = block.conId;
            that.detailHead = data.head;
            that.detailData = data;
            return that.getTableBlock(block);
        }

        getTableCon(table) {
            return table;
        }

    }

    return PricePolicyDetail;
})();