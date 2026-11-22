
var PricePolicySet = (function () {
    AjaxJSPage(`PricePolicyEdit_js`,"include/js/modules/PricePolicy/PricePolicyEdit.js");
    class PricePolicySet extends PricePolicyEdit {
        constructor() {
            super();
            var that = this;
            this.fieldCon.module = function (rowIndex, blockData, field) {
                return blockData.val[rowIndex]['moduleLabel'];
            }
            this.fieldCon.accordingTo = function (rowIndex, blockData, field) {
                var rowVal = blockData.val[rowIndex],
                    val = rowVal[field],
                    module = rowVal['module'],
                    moduleLabel = this.module(rowIndex, blockData, 'module');
                return '' +
                    `<div style="display: flex;align-items: center">` +
                        that.rulesCon.label(`当${moduleLabel}`) +
                        that.getSelectHtml(field, {module, selected: val}) +
                        that.rulesCon.label(`在价格政策的有效期内，可使用价格政策`) +
                    `</div>`;
            }
        }

        /** @return {PricePolicySet} */
        static getInstance(obj) {
            return super.getInstance(obj).getSetInstance();
        }

        getHeadObj() {
            return this.headObj || (this.headObj = ld('#PricePolicyHead'))
        }

        getBodyObj() {
            return this.bodyObj || (this.bodyObj = ld('#PricePolicyBody'))
        }

        showContent() {
            var that = this;
            ldAjax(that.getAjaxUrl(), that.getUrlParam({
                funName: 'getSetInfo'
            }), function (data) {
                if(data.code === 1) {
                    that.data = data.result;
                    that.showHead();
                    that.showBody();
                    that.init();
                    DelProgressObjs();
                }
            })
        }

        getHeadData() {
            return this.data.head;
        }

        getBodyData() {
            return this.data.body;
        }

        getModuleFields(module) {
            return this.data.moduleFields[module];
        }

        showHead() {
            var that = this,
                data = that.getHeadData(),
                thead = '',
                tbody = '',
                table = '';
            thead += `<th colspan="2">${data.title}</th>`;
            ld.each(data.val, function (index, row) {
                tbody += '' +
                    `<tr class="headRow">` +
                        `<td class="headRowLabel" width="70%">` +
                            `${row.label}` +
                        `</td>` +
                        `<td class="headRowCon" width="30%">` +
                            that.getSelectHtml(row.field, {selected: row.value}) +
                        `</td>` +
                    `</tr>`;
            });
            table = that.getTable('HeadTitle', thead, tbody)
            that.getHeadObj().html(table);
        }

        showBody() {
            var that = this,
                body = that.getBodyData(),
                {thead, tbody} = that.getTableInner(body, 'module'),
                table = that.getTable(body.conId, thead, tbody),
                bodyObj = that.getBodyObj();
            bodyObj.html(table);
            bodyObj.css('overflow-y', 'auto');
            var rightContentObj = ld('#SettingRightContent'),
                titleObj = rightContentObj.find('.main_grid_top'),
                height = rightContentObj.innerHeight() - titleObj.outerHeight() - that.getHeadObj().outerHeight();
            height -= bodyObj.find('thead').outerHeight();
            bodyObj.css('height', height +'px');
        }

        getOptionData(field, opt) {
            var option = this.data.fieldOptions[field];
            if(field === 'accordingTo') {
                var {module} = opt,
                    fields = this.getModuleFields(module);
                option = [...option, ...fields];
            }
            return option;
        }

        getSelectHtml(field, opt) {
            var option = this.getOptionData(field, opt),
                val = '';
            ld.each(option, function (index, info) {
                var selected = opt.selected === info.value ? 'selected' : '';
                val += `<option value="${info.value}" ${selected}>${info.label}</option>`;
            })
            return `<select class="ld-select-inner" name="${field}" style="width: 220px">${val}</select>`;
        }

        init() {
            var that = this,
                affectNode = 'affectNode',
                accordingTo = 'accordingTo',
                affectNodeObj = that.getHeadObj().find(`[name=affectNode]`),
                accordingToObjs = that.getBodyObj().find(`[name="${accordingTo}"]`);

            affectNodeObj.bind('change',function () {
                that.saveSetValueByType(affectNode, ld(this).val());
            })

            accordingToObjs.bind('change', function () {
                var module = ld(this).parents('tr').attr('row-index');
                that.saveSetValueByType(`${module}_${accordingTo}`, ld(this).val());
            })
        }

        saveSetValueByType(type, value) {
            ldAjax(this.getAjaxUrl(), this.getUrlParam({
                funName: 'saveSetValue',
                type,
                value,
            }), function (data) {
                if(data.code === 1)
                    MessagePopup.TipZero_success('保存成功');
            })
        }
    }

    return PricePolicySet;
})();