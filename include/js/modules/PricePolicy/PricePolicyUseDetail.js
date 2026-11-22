
var PricePolicyUseDetail = (function () {
    AjaxJSPage(`PricePolicyDetail`, `include/js/modules/PricePolicy/PricePolicyDetail.js`);
    class PricePolicyUseDetail extends PricePolicyDetail {
        constructor() {
            super();
        }

        /** @return {PricePolicyUseDetail} */
        static getInstance(obj) {
            return super.getInstance(obj).getUseDetailInstance();
        }

        initProperty() {
            var that = this;
            that.fieldCon.label = function (rowIndex, blockData, field) {
                var label = blockData.val[rowIndex][field];
                return label.join(',');
            };
        }

        moduleDetail() {
            var that = this,
                popupObj = that.popupObj = CrmPopup.getPopupObj('last'),
                popupJqObj = that.popupJqObj = ld(`#${popupObj.divid}`),
                detailTableObj = popupJqObj.find('#DetailContent').find('[name="detailtable"]'),
                restBlocks = popupObj.moduleData.restBlocks;
            ld.each(restBlocks,function (index,block) {
                detailTableObj.after(that.getBlock(block));
            })
        }

        getPricePolicyBlock(block) {
            return this.getTableBlock(block);
        }

    }

    return PricePolicyUseDetail;
})();