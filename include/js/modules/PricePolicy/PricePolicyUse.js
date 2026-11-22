
var PricePolicyUse = (function () {
    AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
    class PricePolicyUse extends PricePolicy {
        constructor() {
            super();
            var that = this;
            this.selectedPolicy = [];
            this.discountAmount = {
                discount: function (policyVal, val) {
                    return eval(val) * eval(policyVal.content) * 0.01;
                },
                reduced: function (policyVal, val) {
                    return eval(policyVal.content);
                },
                product_discount: function (policyVal, val) {
                    return this.discount(policyVal, val);
                },
                product_reduced: function (policyVal, val) {
                    return this.reduced(policyVal, val);
                },
                product_fixed: function (policyVal, val) {
                    return eval(val) - eval(policyVal.content);
                },
                order_discount: function (policyVal, val) {
                    return this.discount(policyVal, val);
                },
                order_reduced: function (policyVal, val) {
                    return this.reduced(policyVal, val);
                },
            }

            this.decimalList = {};
            this.defaultSelected = {};

            this.triggerReCalculate = true;

            this.disabledDetailColArr = ['taxprice', 'listprice', 'tax_amount'];
        }

        /** @return {PricePolicyUse} */
        static getInstance(obj) {
            return super.getInstance(obj).getUseInstance();
        }

        showBlock() {
            var that = this,
                popupObj = that.popupObj = CrmPopup.getPopupObj('last'),
                popupJqObj = that.popupJqObj = ld('#'+popupObj.divid);
            if(!that.getBlockInfo()) {
                return
            }
            var proTotal = popupJqObj.find('#proTabTotal'),
                ProductTabTotal = popupJqObj.find('.ProductTabTotal');
            //zkt 20241018 BUG20241018-21 盘点单，调用及时库存，进度条一直保持在5%，不动；而且新街界面，选择产品，点击加号，也没有反应
            if(proTotal.length <= 0){
                if(ProductTabTotal.length <= 0) {
                    return;
                }
                ProductTabTotal.after(that.getBlock());
            }
            else {
                proTotal.before(that.getBlock());
            }

            that.init()
        }

        getBlockInfo() {
            return this.popupObj ? this.popupObj.moduleData ? this.popupObj.moduleData.pricePolicyBlock : undefined : undefined;
        }

        getBlockData() {
            return this.blockData || (this.blockData = this.getBlockInfo() ? this.getBlockInfo().val : undefined);
        }

        getPricePolicyList() {
            return this.getBlockData().validity;
        }

        setPricePolicyList(validity) {
            var that = this,
                selected = that.getSelectedPolicys();
            validity = validity.map(item => {
                let policyId = item.id.toString();
                if(item.unavailable === 'no') {
                    if(selected.includes(policyId)) {
                        item.selected = 'yes';
                    }
                    else {
                        if(item.default === 'yes' && !that.defaultSelected[policyId]) {
                            item.selected = 'yes';
                            that.pushPolicyById(item.id);
                        }
                        else {
                            item.selected = 'no';
                            that.removeSelectedPolicyById(item.id);
                        }
                    }
                }
                else {
                    item.selected = 'no';
                    that.removeSelectedPolicyById(item.id);
                }
                return item;
            })
            this.getBlockData().validity = validity;
        }

        getBlock() {
            var that = this,
                block = that.getBlockInfo(),
                cards = that.getCards(),
                hideUnavailable = block.hideUnavailable === 'yes';
            that.blockId = block.conId;
            return '' +
                `<div id="${block.conId}" class="PricePolicyBlock">` +
                    `<div id="PricePolicyHead" class="PricePolicyHead">` +
                        `<div id="PricePolicyTitle" class="PricePolicyTitle">` +
                            `${block.title}` +
                        `</div>` +
                        `<div id="PricePolicyHideButton" class="PricePolicyHideButton">` +
                            `<div><input id="HideButton" class="second_switch" type="checkbox" ${ hideUnavailable ? 'checked' : ''}></div>` +
                            `<label >隐藏不可用的价格政策</label>` +
                        `</div>` +
                    `</div>` +
                    `<div id="PricePolicyContent" class="PricePolicyContent">` +
                        `${cards}` +
                    `</div>` +
                `</div>` +
                '';
        }

        getCards() {
            var that = this,
                cards = '',
                block = that.getBlockInfo(),
                hideUnavailable = block.hideUnavailable === 'yes';
            ld.each(that.getPricePolicyList(), function (index,info) {
                var classArr = [],
                    styleArr = [],
                    thirdRow = '';
                (info.selected === 'yes') && classArr.push('selected');
                (info.recommended === 'yes') && classArr.push('recommended');
                if(info.unavailable === 'yes') {
                    classArr.push('unavailable');
                    hideUnavailable && styleArr.push('display:none');
                    thirdRow = '' +
                        `<div class="unavailableCause PricePolicyCardRow" data-tip="${info.unavailableCause.join('<br>')}" data-direction="top" data-type="position">` +
                            `不可用原因：${info.unavailableCause.join(', ')}` +
                        `</div>`;
                }
                else {
                    thirdRow = '' +
                        `<div class="time PricePolicyCardRow">` +
                            `活动期限：${info.start}-${info.end}` +
                        `</div>`;
                }
                cards += '' +
                    `<div class="PricePolicyCard ${classArr.join(' ')}" name="PricePolicyCard" id="pricePolice_${info.id}" style="${styleArr.join(';')}">` +
                        `<div class="title PricePolicyCardRow">` +
                            `${info.name}` +
                        `</div>` +
                        `<div class="content PricePolicyCardRow" data-tip="${info.label.join('<br>')}" data-direction="top" data-type="position">` +
                            `${info.label.join(', ')}` +
                        `</div>` +
                            thirdRow +
                        `<i class="check"></i>` +
                    `</div>`;
            })
            return cards;
        }

        getBlockJqObj() {
            if(this.pricePolicyObj && this.pricePolicyObj.length > 0) {
                return this.pricePolicyObj;
            }
            return this.pricePolicyObj = this.popupJqObj.find(`#${this.blockId}`);
        }

        getCardsDivJqObj() {
            if(this.cardsDivObj && this.cardsDivObj.length > 0) {
                return this.cardsDivObj;
            }
            return this.cardsDivObj = this.getBlockJqObj().find(`#PricePolicyContent`);
        }

        init() {
            var that = this,
                popupJqObj = that.popupJqObj,
                blockJq = that.getBlockJqObj();
            if(!blockJq || blockJq.length <= 0) {
                return
            }
            var popJqWidth = parseFloat(popupJqObj.outerWidth()),
                leftWidth = parseFloat(popupJqObj.find(" .edit-left").outerWidth()),
                paddingWidth = parseFloat(blockJq.get(0).style.getPropertyValue('--ld-edit-padding')),
                blockWidth = `calc(${popJqWidth - leftWidth}px - var(--ld-edit-padding) - var(--ld-edit-padding))`;

            // 固定宽度
            blockJq.css('width', blockWidth);

            blockJq.find('#HideButton').bind('change',function () {
                var val = ld(this).prop('checked') ? 'yes' : 'no';
                ldAjax(that.getAjaxUrl(), that.getUrlParam({
                    funName: 'saveHideChoose',
                    showHidden: val,
                }),function (data) {
                    that.getBlockInfo().hideUnavailable = val;
                    if(val === 'no') {
                        that.getCardObjs().show()
                    }
                    else {
                        that.getCardObjs().each(function (index, card) {
                            var policyInfo = that.getPricePolicyList()[index];
                            if(policyInfo.unavailable === 'yes') {
                                ld(card).hide();
                            }
                        })
                    }
                    DelProgressObjs();
                })
            })

            that.setSelectedPolicys(that.getBlockData().selected);
            that.setCardsEvent();

            var fieldEventObj = that.getFieldEventObj(),
                fields = that.getBlockData().fields;
            if(fields) {
                ld.each(fields, function (fieldName, colStr) {
                    fieldEventObj.set(fieldName, () => that.updateCards() , { instance: that });
                })
            }
        }

        getCardObjs() {
            return this.getCardsDivJqObj().find('.PricePolicyCard');
        }

        setCardsEvent() {
            var that = this,
                cardList = that.getCardObjs();
            tooltip(cardList.find('.content'), {transition: true, time: 200});
            tooltip(cardList.find('.unavailableCause'), {transition: true, time: 200});
            cardList.each(function (index,card) {
                that.setCardEvent(ld(card))
            });
        }

        setCardEvent(cardObj) {
            var that = this;
            cardObj.unbind('click').bind('click',function () {
                that.clickPolicy(ld(this));
            })
        }

        getFieldEventObj() {
            if(typeof this.fieldEventObj === "undefined") {
                AjaxJSPage(`FieldEvent`, `include/js/field/FieldEvent.js`);
                this.fieldEventObj = FieldEvent.getInstance();
            }
            return this.fieldEventObj;
        }

        updateCards() {
            var that = this,
                //that = (this instanceof PricePolicyUse) ? this : PricePolicyUse.getInstance(CrmPopup.getlastPopupObjByPageType("create_edit_modulepage")) ,
                popupObj = that.popupObj,
                recordData = SaveDataRecord.getFieldValue(popupObj, popupObj.fields, popupObj.getsavedeskpageValue());
            if(!that.getBlockInfo()) {
                return;
            }
            return ldAjaxsync(that.getAjaxUrl(), that.getUrlParam({
                funName: 'updatePolicyList',
                fromModule: popupObj.module,
                productLicencePrice: that.getProductLicencePrice(),
                selected: that.getSelectedPolicys(),
                defaultSelected: JSON.stringify(that.defaultSelected),
                detailData: JSON.stringify(popupObj.detaildatavalue_arr),
            }) + recordData, function (data) {
                if(data.code === 1) {
                    that.setPricePolicyList(data.result.validity);
                    that.getCardsDivJqObj().html(that.getCards());
                    that.setCardsEvent();
                }
                DelProgressObjs();
            })
        }

        getCardById(record) {
            return this.getCardsDivJqObj().find(`#pricePolice_${record}`);
        }

        getIdByCard(cardObj) {
            return cardObj.attr('id').split('_').pop();
        }

        clickPolicy(card) {
            //优惠卷点击事件
            var that = this;
            if(card.hasClass('unavailable')) {
                return
            }
            if(card.hasClass('selected')) {
                that.removePolicy(card);
            }
            else {
                that.usePolicy(card);
            }
        }

        getPolicyInfoById(id) {
            return this.getPricePolicyList().filter(policy => policy.id === id).pop();
        }

        usePolicy(policyId) {
            var that = this,
                cardObj;
            if(policyId instanceof ld) {
                cardObj = policyId;
                policyId = that.getIdByCard(cardObj);
            }
            else {
                cardObj = that.getCardById(policyId);
            }
            cardObj.addClass('selected');
            that.pushPolicyById(policyId);
            that.updateCards();
        }

        pushPolicyById(policyId) {
            var that = this,
                selectedPolicy = that.getSelectedPolicys();
            selectedPolicy.push(policyId.toString());
            that.defaultSelected[policyId] = true;
            that.updateTotal(that.reCalculateTotal().toFixed(that.getTotalDecimal()));
        }

        removePolicy(policyId) {
            this.removeSelectedPolicy(policyId);
            this.updateCards();
        }

        removeSelectedPolicyById(policyId) {
            var that = this,
                selectedPolicy = that.getSelectedPolicys(),
                index = selectedPolicy.indexOf(policyId);
            if(index !== -1) {
                var delPolicyId = selectedPolicy.splice(index, 1).pop(),
                    delPolicy = that.getPolicyInfoById(delPolicyId);
                // 移除赠品行
                if(delPolicy.form.split('_').pop() === 'present') {
                    that.delPrensent(delPolicy);
                }
                that.updateTotal(that.reCalculateTotal().toFixed(that.getTotalDecimal()));
            }
        }

        removeSelectedPolicy(policyId) {
            var that = this,
                cardObj;
            if(policyId instanceof ld) {
                cardObj = policyId;
                policyId = that.getIdByCard(cardObj);
            }
            else {
                cardObj = that.getCardById(policyId);
            }
            cardObj.removeClass('selected');
            that.removeSelectedPolicyById(policyId);
        }

        disablePolicy(policyId) {
            var that = this,
                cardObj = that.getCardById(policyId),
                policyInfo = that.getPolicyInfoById(policyId);
            policyInfo.unavailable = 'yes';
            cardObj.addClass('unavailable');
            that.removeSelectedPolicy(policyId);
        }

        /*

        superpositionHandle(policyId) {
            var that = this,
                policyInfo = that.getPolicyInfoById(policyId),
                superpositionList = policyInfo.superpositionList.split(','),
                policyList = that.getPricePolicyList();
            ld.each(policyList, function (index, tmpPolicy) {
                let tmpPolicyId = tmpPolicy.id;
                if(!superpositionList.includes(tmpPolicyId) ) {
                    tmpPolicy.mutex = 'yes';
                    tmpPolicy.mutexCause = [`政策冲突：${policyInfo.name}`,];

                    if(tmpPolicy.unavailable === 'no') {
                        let tmpCard = that.getCardById(tmpPolicyId),
                            unavailableCause = [...tmpPolicy.mutexCause,...tmpPolicy.unavailableCause];
                        tmpCard.addClass('unavailable');
                        that.setUnavailableCause(tmpCard, unavailableCause);
                        that.sortCards();
                    }
                }
            })
        }

        unSuperpositionHandle() {

        }

        setUnavailableCause(card, label) {
            let unavailableCauseObj = card.find('.unavailableCause');
            unavailableCauseObj.html(label.join(', '));
            unavailableCauseObj.data('tip',label.join('<br>'));
        }

        sortCards(card, cards) {
            let that = this,
                policyId = parseInt(that.getIdByCard(card)),
                policyInfo = that.getPolicyInfoById(policyId),
                oldIndex = card.index(),
                priority = parseFloat(policyInfo.priority);
            if(!cards) {
                cards = that.getCardObjs();
            }
            if(policyInfo.recommended === 'yes') {
                cards.filter('.recommended');
            }
            else {
                cards.not('.recommended');
            }
            ld.each(cards, function (index, tmpCard) {
                let tmpPolicyId = parseInt(that.getIdByCard(tmpCard)),
                    tmpPolicyInfo = that.getPolicyInfoById(tmpPolicyId),
                    tmpPriority = parseFloat(tmpPolicyInfo.priority);
                if(tmpPriority > priority) {
                    card.remove();
                    tmpCard.before(card);
                }
                else if(tmpPriority === priority && policyId > tmpPolicyId) {
                    card.remove();
                    tmpCard.before(card);
                }
            })
        }
        */

        getSelectedPolicys() {
            return this.selectedPolicy;
        }

        setSelectedPolicys(selectedArr) {
            var that = this;
            that.selectedPolicy = selectedArr.map(v => v.toString());
            ld.each(selectedArr, function (index, policyId) {
                that.defaultSelected[policyId] = true;
            });
        }

        getDiscountAmountList(form, policyInfo, opt) {
            if(empty(policyInfo.content))
                return 0;
            if(typeof this.discountAmount[form] === "function") {
                return this.discountAmount[form](policyInfo, opt);
            }
            return 0;
        }

        getProductDiscountAmount(detailInfo, rowId) {
            var that = this;
            if(!that.getBlockData()) {
                return 0;
            }
            var selectedPolicy = that.getSelectedPolicys(),
                productDiscountAmount = 0,
                productDiscountPrice = 0,
                rowObj = that.getDetailRowObjById(rowId),
                taxAmountSpanObj = rowObj.find(`[detailcolumnname="span_tax_amount"]`),
                taxAmountObj = taxAmountSpanObj.length > 0 ? taxAmountSpanObj : rowObj.find(`[detailcolumnname="tax_amount"]`),
                policyTaxAmountObj = taxAmountObj.siblings('[name=policyTaxAmount]'),
                taxPriceSpanObj = rowObj.find(`[detailcolumnname="span_taxprice"]`),
                taxPriceObj = taxPriceSpanObj.length > 0 ? taxPriceSpanObj : rowObj.find(`[detailcolumnname="taxprice"]`),
                policyTaxPriceObj = taxPriceObj.siblings('[name=policyTaxPrice]'),
                quantity = parseFloat(detailInfo.quantity);
            detailInfo.tax_amount_before_discounted = eval(quantity) * eval(detailInfo.tax_price_before_discounted);
            if(isNaN(detailInfo.tax_amount_before_discounted)){
                detailInfo.tax_amount_before_discounted = 0;
            }

            ld.each(selectedPolicy, function (index, policyId) {
                var policy = that.getPolicyInfoById(policyId),
                    policyDetail = policy.value,
                    formArr = policy.form.split('_');
                if(formArr.shift() === 'product') {
                    if (formArr.pop() === 'present') {
                        that.addPresent(policy);
                    } else {
                        ld.each(policyDetail, function (i, info) {
                            let condition = info.condition;
                            if (info.productid === detailInfo.productid && info.thresholdFlag ) {
                                var discountPrice = that.getDiscountAmountList(policy.form, info, parseFloat(detailInfo.tax_price_before_discounted)),
                                    discountAmount = discountPrice * parseFloat(detailInfo.quantity);
                                productDiscountPrice += discountPrice;
                                productDiscountAmount += discountAmount;
                            }
                        })
                    }
                }
            })
            if(productDiscountAmount > 0) {
                detailInfo.tax_amount_before_discounted = parseFloat(detailInfo.tax_amount_before_discounted).toFixed(that.getTaxPriceDecimal())
                detailInfo.tax_price_before_discounted = parseFloat(detailInfo.tax_price_before_discounted).toFixed(that.getTaxAmountDecimal())
                that.disabledDetailRow(rowObj);

                var policyTaxAmount = (eval(detailInfo.tax_amount_before_discounted) - productDiscountAmount).toFixed(that.getTaxAmountDecimal()),
                    policyTaxPrice = (eval(detailInfo.tax_price_before_discounted) - productDiscountPrice).toFixed(that.getTaxPriceDecimal()),
                    amountCon = `原价：${detailInfo.tax_amount_before_discounted}`,
                    priceCon = `原价：${detailInfo.tax_price_before_discounted}`;
                detailInfo.cumulative_benefits = productDiscountAmount;
                detailInfo.product_licence_price = detailInfo.tax_amount_before_discounted;

                // 设为优惠后的价格
                detailInfo.taxprice = detailInfo.taxprice_name = policyTaxPrice;
                detailInfo.tax_amount = detailInfo.tax_amount_name = policyTaxAmount;

                if(policyTaxAmountObj.length > 0) {
                    policyTaxAmountObj.html(amountCon);
                    policyTaxPriceObj.html(priceCon);
                }
                else {
                    taxAmountObj.after(`<span style="text-align: left;color: #999;" name="policyTaxAmount">${amountCon}</span>`);
                    taxPriceObj.after(`<span style="text-align: left;color: #999;" name="policyTaxPrice">${priceCon}</span>`);
                }

            }
            else {
                // 移除优惠提示
                policyTaxAmountObj.remove();
                policyTaxPriceObj.remove();
                //if(that.isNumber(detailInfo.cumulative_benefits) && that.isNumber(detailInfo.tax_price_before_discounted)) {
                if(!empty(detailInfo.cumulative_benefits) && !isNaN(detailInfo.cumulative_benefits)) {
                    detailInfo.cumulative_benefits = undefined;
                    // 恢复原价
                    // 优惠前的含税单价
                    detailInfo.taxprice = detailInfo.taxprice_name = detailInfo.tax_price_before_discounted;
                    // 优惠前的价税合计
                    detailInfo.tax_amount = detailInfo.tax_amount_name = detailInfo.tax_amount_before_discounted;

                    if(that.triggerReCalculate) {
                        that.triggerReCalculate = false;
                        that.popupObj.fieldformulaobj.changeRowDatabyColumnname('taxprice');
                        that.triggerReCalculate = true;
                    }

                    that.abledDetailRow(rowObj);
                }
            }
            return productDiscountAmount;
        }

        /**
         * 判断是否为非NaN的数字，非空字符串进行强制转化后再判断
         * @param value
         * @return {boolean}
         */
        isNumber(value) {
            var type = typeof value;
            if(type === "string") {
                if(value.trim() === '') {
                    return false;
                }
                value = Number(value);
                type = "number";
            }
            if(type === "number") {
                return !Number.isNaN(value);
            }
            return false;
        }

        getOrderDiscountAmount(total) {
            var that = this;
            if(!that.getBlockData()) {
                return 0;
            }
            var selectedPolicy = that.getSelectedPolicys(),
                orderDiscountAmount = 0;
            total = parseFloat(total);
            ld.each(selectedPolicy, function (index, policyId) {
                var policy = that.getPolicyInfoById(policyId),
                    policyDetail = policy.value,
                    formArr = policy.form.split('_');
                if(formArr.shift() === 'order') {
                    let maxThresholdFlag = false;
                    if (formArr.pop() === 'present') {
                        ld.each(policyDetail, function (i, info) {
                            var condition = info.condition[0];
                            info.thresholdFlag = (total >= parseFloat(condition));
                            maxThresholdFlag = (maxThresholdFlag || info.thresholdFlag);
                        })
                        that.addPresent(policy);
                    } else {
                        // todo 因产品优惠导致无法继续使用需要有提示
                        ld.each(policyDetail, function (i, info) {
                            var condition = info.condition[0];
                            //if (total > parseFloat(condition)) {
                            info.thresholdFlag = (total >= parseFloat(condition));
                            maxThresholdFlag = (maxThresholdFlag || info.thresholdFlag);
                            if ( info.thresholdFlag ) {
                                orderDiscountAmount += that.getDiscountAmountList(policy.form, info, total);
                            }
                        })
                    }
                    if(!maxThresholdFlag) {
                        that.disablePolicy(policyId);
                    }
                }
            })
            return orderDiscountAmount;
        }

        addPresent(policy) {
            // 先添加行
            var that = this,
                policyDetail = policy.value,
                proTabObj = that.popupJqObj.find('#proTab'),
                wareId = 0,
                currencyObj = that.popupJqObj.find(" [name=inventory_currency]"),
                currencyId = currencyObj.length > 0 ? currencyObj.val() : 1;
            if(!Array.isArray(policyDetail) || policyDetail.length <= 0) {
                return;
            }
            ld.each(policyDetail, function (index, detail) {
                var present = detail.present,
                    trObj = proTabObj.find('tr[rowindex]').last(),
                    tdObj = trObj.find('#td_seqno'),
                    rowId = parseInt(trObj.attr('rowindex'));
                if(!empty(present) && detail.thresholdFlag ) {
                    var presentAttr = policy.id + '_' + index,
                        presentRow = proTabObj.find(`tr[present="${presentAttr}"]`);
                    if(presentRow.length === 0) {
                        ProductAddRowAfterassingIndex(tdObj);
                        rowId++;
                        var newTr = that.getDetailRowObjById(rowId),
                            spanSeqObj = newTr.find('#td_seqno');
                        newTr.attr('present', presentAttr);
                        spanSeqObj.css('--span-extralContent',"'（赠品）'");
                        that.disabledDetailRow(newTr, 'present');

                        that.popupObj.selectproductobj.setValueByRow(rowId, detail.presentInfo);
                    }
                }
            })
        }

        delPrensent(policy) {
            var that = this,
                policyDetail = policy.value,
                proTabObj = that.getProTabObj();
            if(!Array.isArray(policyDetail) || policyDetail.length <= 0) {
                return;
            }
            ld.each(policyDetail, function (index, detail) {
                var present = detail.present;
                if(!empty(present)) {
                    var presentAttr = policy.id + '_' + index,
                        presentRow = proTabObj.find(`tr[present="${presentAttr}"]`);
                    if(presentRow.length > 0) {
                        deleteRow(presentRow.attr('rowindex'));
                    }
                }
            })
        }

        getProTabObj() {
            return this.proTabObj || (this.proTabObj = this.popupJqObj.find('#proTab'));
        }

        getDetailRowObjById(rowId) {
            return this.getProTabObj().find(`[rowindex=${rowId}]`);
        }

        getProductCumulativeBenefits() {
            var that = this,
                popupObj = that.popupObj,
                cumulativeBenefits = 0;
            ld.each(popupObj.detaildatavalue_arr, function (index, info) {
                // 政策的产品优惠金额
                cumulativeBenefits += that.getProductDiscountAmount(info, index + 1);
            })
            return cumulativeBenefits;
        }

        /** 合计金额重算 */
        reCalculateTotal(total) {
            // 累计优惠金额、产品总价， 合计 = 产品总价 - 累计优惠
            var that = this,
                popupObj = that.popupObj,
                cumulativeBenefits = 0,
                productLicencePrice = 0;
            var selectedPolicy = that.getSelectedPolicys();
            // 产品类政策优惠
            cumulativeBenefits += that.getProductCumulativeBenefits();

            if(that.triggerReCalculate) {
                if(selectedPolicy.length>0){
                    that.triggerReCalculate = false;
                    popupObj.fieldformulaobj.changeRowDatabyColumnname('taxprice');
                    that.triggerReCalculate = true;
                }
            }
            else {
                return total;
            }
            // 此 total 为 productLicencePrice - cumulativeBenefits (产品类优惠)
            total = parseFloat(popupObj.selectproductobj.totalobj.val());
            // 合计 = 产品总价 - 累计优惠 => 产品总价 = 合计 + 累计优惠 (订单优惠前)
            productLicencePrice = total + cumulativeBenefits;

            //政策的整单优惠金额
            cumulativeBenefits += that.getOrderDiscountAmount(total);

            // 订单优惠后（合计 = 产品总价 - 累计优惠）
            total = productLicencePrice - cumulativeBenefits;

            let decimal = that.getTotalDecimal();
            popupObj.productLicencePrice = productLicencePrice.toFixed(decimal);
            popupObj.cumulativeBenefits = cumulativeBenefits.toFixed(decimal);
            return total;
        }

        getProductLicencePrice() {
            var popupObj = this.popupObj;
            if(isNaN(popupObj.productLicencePrice)) {
                let selProObj = popupObj.selectproductobj,
                    productLicencePrice = selProObj.productLicencePriceObj.val()
                popupObj.productLicencePrice = !isNaN(productLicencePrice) ? productLicencePrice : selProObj.totalobj.val();
            }
            popupObj.productLicencePrice = parseFloat(popupObj.productLicencePrice);
            return popupObj.productLicencePrice;
        }

        updateTotal(total) {
            var that = this,
                popupObj = that.popupObj,
                popupJqObj = that.popupJqObj,
                selProObj = popupObj.selectproductobj,
                totalObj = selProObj.totalobj,
                spanTotalObj = selProObj.spanTotalObj || (selProObj.spanTotalObj = popupJqObj.find(" [name=span_total]")),
                cumulativeBenefitsObj = selProObj.cumulativeBenefitsObj,
                cumulativeBenefitsSpanObj = selProObj.cumulativeBenefitsSpanObj,
                productLicencePriceObj = selProObj.productLicencePriceObj,
                productLicencePriceSpanObj = selProObj.productLicencePriceSpanObj,
                grandTotalObj = selProObj.grandTotalobj;
            popupObj.before_totalvalue = total;
            popupObj.now_totalvalue = total;
            totalObj.val(total);
            spanTotalObj.html(total);
            cumulativeBenefitsObj.val(popupObj.cumulativeBenefits);
            cumulativeBenefitsSpanObj.html(popupObj.cumulativeBenefits);
            productLicencePriceObj.val(popupObj.productLicencePrice);
            productLicencePriceSpanObj.html(popupObj.productLicencePrice);
            grandTotalObj.val(total);
        }

        getTotalDecimal() {
            return this.getDecimalByColumnName('total');
        }

        getTaxPriceDecimal() {
            return this.getDecimalByColumnName('taxprice');
        }

        getTaxAmountDecimal() {
            return this.getDecimalByColumnName('tax_amount');
        }

        getDecimalByColumnName(columnName) {
            var that = this,
                decimal = 2,
                detailFields = that.popupObj.detailfields;
            if(this.decimalList[columnName]) {
                return this.decimalList[columnName];
            }
            if (detailFields) {
                var totalFieldInfo;
                for (var i = 0; i < detailFields.length; i++) {
                    if (detailFields[i].columnname === columnName) {
                        totalFieldInfo = detailFields[i];
                        break;
                    }
                }
                if (!empty(totalFieldInfo)) {
                    //金额类型字段，小数位数去typeofdata
                    if (totalFieldInfo.uitype >= 25 && totalFieldInfo.uitype <= 50) {
                        var typeOfData = totalFieldInfo.typeofdata;
                        if (typeOfData) {
                            var typeOfDataArr = typeOfData.split(',');
                            if (typeOfDataArr.length > 1 && !empty(typeOfDataArr[1])) {
                                decimal = typeOfDataArr[1];
                            }
                        }
                    }
                }
            }
            return this.decimalList[columnName] = decimal;
        }

        abledDetailRow(rowObj) {
            var that = this,
                colArr = that.disabledDetailColArr;
            if(!(rowObj instanceof ld)) {
                rowObj = that.getDetailRowObjById(rowObj);
            }
            ld.each(colArr, function (index, col) {
                var tmpObj = rowObj.find(`[detailcolumnname="${col}"]`);
                if(tmpObj.length > 0) {
                    tmpObj.removeAttr('readonly');
                    tmpObj.css('cursor', '');
                }
            })
        }

        disabledDetailRow(rowObj, type) {
            var that = this,
                colArr = that.disabledDetailColArr;
            if(!(rowObj instanceof ld)) {
                rowObj = that.getDetailRowObjById(rowObj);
            }
            if(type === 'present') {
                colArr.push('quantity');
            }
            ld.each(colArr, function (index, col) {
                var tmpObj = rowObj.find(`[detailcolumnname="${col}"]`);
                if(tmpObj.length > 0) {
                    tmpObj.attr('readonly', 'Readonly');
                    tmpObj.css('cursor', 'not-allowed');
                }
            })



        }

        getSaveParams() {
            var that = this;
            if(!that.getBlockInfo()) {
                return '';
            }
            return that.getUrlParam({
                cumulativeBenefits: that.popupObj.cumulativeBenefits,
                cumulative_benefits: that.popupObj.cumulativeBenefits,
                productLicencePrice: that.popupObj.productLicencePrice,
                product_licence_price: that.popupObj.productLicencePrice,
                selectedPolicy: that.selectedPolicy.join(','),
            })
        }
    }

    return PricePolicyUse;
})();