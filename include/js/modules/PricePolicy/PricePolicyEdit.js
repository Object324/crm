//# sourceURL= PricePolicyEdit.js
var PricePolicyEdit = (function () {
    AjaxJSPage('PricePolicy', 'include/js/modules/PricePolicy/PricePolicy.js');
    class PricePolicyEdit extends PricePolicy {
        constructor() {
            super();
            this.initProperty()
        }

        /** @return {PricePolicyEdit} */
        static getInstance(obj) {
            return super.getInstance(obj).getEditInstance();
        }

        initProperty() {
            var that = this;

            that.fieldCon = {
                module: function (rowIndex, blockData, field) {
                    var value = blockData.val[rowIndex][field];
                    if(!that.roleModuleList) {
                        ld.each(that.popupObj.moduleData.picklistcontent,function (index,item) {
                            if(item.fieldname === 'role_module') {
                                that.roleModuleList = item.optionvalue;
                                return false;
                            }
                        })
                    }
                    return that.roleModuleList[value] ? that.roleModuleList[value][0] : value;
                },
                scope: function (rowIndex, blockData, field) {
                    var value = blockData.val[rowIndex][field],
                        scopeLabel = '';
                    ld.each(value,function (index,value) {
                        scopeLabel += `<div style="padding-right: 10px">${value}</div>`;
                    })
                    return scopeLabel;
                },
                operate: function (rowIndex, blockData, field) {
                    var value = blockData[field],
                        conList = '';
                    ld.each(value,function (index,item) {
                        conList += `<b class="ld-category-icon ld-category-${item}"></b>`;
                    })
                    return conList;
                },
                no: function (rowIndex, blockData, field) {
                    return blockData.val[rowIndex][field] = rowIndex + 1;
                },
                rules: function (rowIndex, blockData, field) {
                    var rowVal = blockData.val[rowIndex],
                        form = blockData.form
                    return '' +
                        '<div class="price-policy-role-module-row">' +
                        (typeof that.rulesCon[form] === "function" ? that.rulesCon[form](rowVal,rowIndex) : '') +
                        '</div>';
                },
            }

            that.rulesCon = {
                label: function (label) {
                    return `<span style="padding-right: 10px;overflow: unset;">${label}</span>`;
                },
                product_discount: function (rowVal,rowIndex) {
                    return '' +
                        this.label('购买') +
                        this.selProduct(rowVal,rowIndex) +
                        this.label('满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('至') +
                        this.input(rowVal,rowIndex,'condition[]', '<')+
                        this.label('个，产品单价降价') +
                        this.input(rowVal,rowIndex,'content') +
                        this.label('%') ;
                },
                product_reduced: function (rowVal,rowIndex) {
                    return '' +
                        this.label('购买') +
                        this.selProduct(rowVal,rowIndex) +
                        this.label('满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('至') +
                        this.input(rowVal,rowIndex,'condition[]', '<')+
                        this.label('个，产品单价减免') +
                        this.input(rowVal,rowIndex,'content');
                },
                product_fixed: function (rowVal,rowIndex) {
                    return '' +
                        this.label('购买') +
                        this.selProduct(rowVal,rowIndex) +
                        this.label('满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('至') +
                        this.input(rowVal,rowIndex,'condition[]', '<')+
                        this.label('个，产品单价降至') +
                        this.input(rowVal,rowIndex,'content');
                },
                product_present: function (rowVal,rowIndex) {
                    return '' +
                        this.label('购买') +
                        this.selProduct(rowVal,rowIndex) +
                        this.label('满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('至') +
                        this.input(rowVal,rowIndex,'condition[]', '<')+
                        this.label('个，赠送') +
                        this.input(rowVal,rowIndex,'content') +
                        this.label('个') +
                        this.selProduct(rowVal,rowIndex,'presentName');
                },
                selProduct: function (rowVal,rowIndex,name = 'productname') {
                    var productName = rowVal[name] ? decodeURIComponent(rowVal[name]) : '';
                    return '' +
                        `<div class="sel-product " style="width: 60%" name="${name}">` +
                        `<input class="ld-input-inner ld-input-inner-add" style="" type="text" autocomplete="off" name="productname" value="${productName}" placeholder="请选择产品"` +
                        `onfocus="return clickOnFoucus(this)" onblur="return clickOnBlur(this)" ` +
                        `onkeyup="PricePolicyEdit.getInstance().setProductObj(this);getInventoryProductKeyWords(this,'${rowIndex}','Products',event)" ` +
                        `onkeypress="PricePolicyEdit.getInstance().setProductObj(this);userEnterKey(getInventoryProductKeyWords,[this,'${rowIndex}','Products',event],event)" >` +
                        `<a class="ld-text-select" name="searchIcon" href="javascript:;" title="产品管理" tag="sourcehidebutton" ` +
                        `onclick="PricePolicyEdit.getInstance().setProductObj(this);fun_selectproduct.getProductPopup('${rowIndex}')">` +
                        `+` +
                        `</a>` +
                        `<a class="ld-text-clear" href="javascript:;" title="清除" tag="sourcehidebutton" ` +
                        `onclick="PricePolicyEdit.getInstance().setProductObj(this);fun_selectproduct.btn_clearProductInfo_Row('${rowIndex}')">` +
                        `+` +
                        `</a>` +
                        `<div style="display:none" tag="dv_productbominfo">` +
                        `<span>产品套餐：</span>` +
                        `<span tag="productbomname"></span>` +
                        `<span class="padL5">数量：</span>` +
                        `<span tag="productbomquantity"></span>` +
                        `</div>` +
                        `<div class="clear"></div>` +
                        `<div name="search_productname" class="ProSearchResult" style="display: none;"></div>` +
                        `<div class="proClaer">` +
                        `<input type="hidden" name="hdnProductId" id="hdnProductId" detailcolumnname="hdnProductId" value="">` +
                        `</div>` +
                        `</div>`;
                },
                input: function (rowVal,rowIndex,name,placeholder) {
                    return '' +
                        `<div style="width: 15%">` +
                            `<input style="color:" placeholder="${placeholder ? placeholder : ''}" type="text" tabindex="p" value="" class="ld-input-inner" name="${name}">` +
                        `</div>`;
                },
                order_discount: function (rowVal,rowIndex) {
                    return '' +
                        this.label('产品总价满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('元，合计降价') +
                        this.input(rowVal,rowIndex,'content') +
                        this.label('%') ;
                },
                order_reduced: function (rowVal,rowIndex) {
                    return '' +
                        this.label('产品总价满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('元，合计减免') +
                        this.input(rowVal,rowIndex,'content') +
                        this.label('元');
                },
                order_present: function (rowVal,rowIndex) {
                    return '' +
                        this.label('产品总价满') +
                        this.input(rowVal,rowIndex,'condition[]', '≥')+
                        this.label('元，赠送') +
                        this.input(rowVal,rowIndex,'content') +
                        this.label('个') +
                        this.selProduct(rowVal,rowIndex,'presentName');
                },
            }
        }

        moduleEdit() {

            var popupObj = CrmPopup.getPopupObj('last'),
                popupJqObj = ld(`#${popupObj.divid}`),
                EditTable = popupJqObj.find('#div_pagerecord').children().children('table'),
                restBlocks = popupObj.moduleData.restBlocks,
                that = this;
            that.popupObj = popupObj;
            that.popupJqObj = popupJqObj;
            ld.each(restBlocks,function (index,block) {
                EditTable.append(that.getBlock(block));
            })
            that.showSuperPosition()
            that.editInit()
        }

        getBlock(block) {
            var method = block.method;
            return (typeof this[method] === 'function') ? this[method](block) : '';
        }

        blockUtil(block,blockCon) {
            return '' +
                '<tr>' +
                    '<td colspan=4 >' +
                        '<table class="ld-createedit-tablecontent" cellspacing="0" cellpadding="0" border="0" style="width:100%;table-layout: fixed;">' +
                            '<tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>' +
                            '<tr>' +
                                '<td colspan=4 class="ld-from-headblock e">' +
                                `<div class="ld-from-headblock-title" tag="headblock-title">${block.title}</div>` +
                                '</td>' +
                            '</tr>' +
                            '<tr class="ld-form-item">' +
                                `${blockCon}` +
                            '</tr>' +
                        '</table>' +
                    '</td>' +
                '</tr>';
        }

        getRoleModuleCon(block) {
            var that = this,
                data = block.data;
            that.roleModuleConId = block.conId;
            that.roleModuleData = data;
            return that.getTableBlock(block, 'module');
        }

        getScopeCon(block) {
            var that = this,
                data = block.data,
                scope = data.val.scope,
                con = ``;
            that.scopeConId = block.conId;
            that.scopeData = data;
            ld.each(data.list,function (index,info) {
                con += '' +
                    '<label class="padR10">' +
                    `<input type="radio" name="radiotype" style="margin-right: 5px;margin-top: -2px;" value="${info.value}" ${scope === info.value ? 'checked' : ''}>` +
                    `${info.label}` +
                    '</label>';
            })
            con = '' +
                `<td class="ld-form-item-label" style="">${data.label}</td>` +
                '<td colspan=3 class="ld-form-item-content">' +
                `<div id="${block.conId}" class="select-input">${con}</div>` +
                '</td>';
            return that.blockUtil(block,con);
        }

        getDetailCon(block) {
            var that = this,
                data = block.data;
            that.popupObj.js_detailtablename = that.detailConId = block.conId;
            that.detailHead = data.head;
            that.detailData = data;
            block.extraRow = '' +
                `<tr>` +
                    `<td colspan="3">` +
                        `<div class="addBtn" style="display: flex;align-items: center;color: var(--ld-font-link-color);width: fit-content;">` +
                            `<b class="ld-icon-add ld-icon-add-hover "></b>` +
                            `<span class="" style="padding-left: 5px;cursor: pointer">添加新政策</span>` +
                        `</div>` +
                    `</td>` +
                `</tr>`;
            return that.getTableBlock(block);
        }

        getSuperPositionListCon(block) {
            var that = this,
                con = '';
            that.superPositionData = block.data;
            that.superPositionConId = block.conId;
            con = '' +
                '<td colspan=4 style="padding: 0 10px 0 var(--ld-edit-padding);">' +
                `<div id="${block.conId}">${con}</div>` +
                '</td>';
            return that.blockUtil(block,con);
        }
        showSuperPosition() {
            var that = this,
                left = that.superPositionData.available || [],
                right = that.superPositionData.selected || [];
            if(right.length > 0) {
                left = left.filter(item => !right.some(compare => compare.value === item.value));
            }
            AjaxJSPage('DragTransfer', 'include/js/DragTransfer.js');
            DragTransfer.SetDragTransfer(that.getSuperPositionConObj(),{
                transLabel: {
                    available: '可选价格政策',
                    selected: '已选价格政策',
                    placeholder: '请输入要查找的价格政策',
                },
                left,
                right,
                type: 'set',
                width: '300',
                need_resetLabelClick: false,
            })
        }

        getTableBlock(block,rowProp) {
            var that = this,
                {thead, tbody} = that.getTableInner(block,rowProp),
                table =  that.getTable(block.conId, thead, tbody, ['price-policy-table']);
            return that.blockUtil(block, that.getTableCon(table));
        }

        getTableCon(table) {
            return '' +
                '<td colspan=4 class="ld-pop-container ld-table-container ld-table-container-lines" style="padding: 0 10px 0 var(--ld-edit-padding);">' +
                    `${table}` +
                '</td>';
        }

        getDetailRowByIndex(rowIndex) {
            return this.getDetailTable().find(`tr[row-index="${rowIndex}"]`).first();
        }

        getDetailTable() {
            return this.detailTable || ( this.detailTable = this.popupJqObj.find(`#${this.detailConId}`).find('tbody') );
        }

        getRoleModuleRowByIndex(rowIndex) {
            return this.getRoleModuleTable().find(`tr[row-index="${rowIndex}"]`);
        }

        getRoleModuleTable() {
            return this.roleModuleTable || ( this.roleModuleTable = this.popupJqObj.find(`#${this.roleModuleConId}`).find('tbody') );
        }

        getSuperPositionConObj() {
            return this.superPositionConObj || ( this.superPositionConObj = this.popupJqObj.find(`#${this.superPositionConId}`) );
        }

        setProductObj(obj) {
            this.curProductObj = ld(obj)
        }
        getProductObj(parentObj) {
            return (parentObj || this.getProductParentObj()).find('[name=productname]');
        }
        getProductParentObj() {
            return this.curProductObj.parents('.sel-product');
        }

        addProducts(rowIndex, products) {
            rowIndex = parseInt(rowIndex);
            var that = this,
                productArr = Object.values(products),
                first = productArr.shift(),
                name = that.getProductParentObj().attr('name');
            that.fillProduct(rowIndex, first);
            ld.each(productArr,function (index, product) {
                var rowNum = rowIndex + index + 1,
                    beforRow = that.getDetailRowByIndex(rowNum - 1);
                if(!that.detailData.val[rowNum]) {
                    that.detailData.val.splice(rowNum, 0, {});
                    beforRow.after(that.getTableTrRow(rowNum, that.detailData));
                }
                that.setProductObj(that.getProductObj(beforRow.next().find(`.sel-product[name=${name}]`)))
                that.fillProduct(rowNum, product);
            });
            that.updateDetailRowIndex();
        }

        fillProduct(rowIndex, product) {
            var that = this,
                productInput = that.getProductObj(),
                productId = product.productid,
                productName = decodeURIComponent(product.productname);
            productInput.val(productName)
            productInput.css('cursor','not-allowed');
            productInput.attr('ReadOnly', true);
            if(that.getProductParentObj().attr('name') === 'productname') {
                that.detailData.val[rowIndex].productid = productId;
                that.detailData.val[rowIndex].productname = productName;
            }
            else {
                that.detailData.val[rowIndex].present = productId;
                that.detailData.val[rowIndex].presentName = productName;
            }
            that.setDetailRowEvent(rowIndex);
        }

        delProduct(rowIndex) {
            var that = this,
                productInput = that.getProductObj();
            productInput.val('');
            productInput.css('cursor','');
            productInput.attr('ReadOnly', false);
            if(that.getProductParentObj().attr('name') === 'productname') {
                that.detailData.val[rowIndex].productid = '';
                that.detailData.val[rowIndex].productname = '';
            }
            else {
                that.detailData.val[rowIndex].present = '';
                that.detailData.val[rowIndex].presentName = '';
            }
        }

        editInit() {
            var that = this,
                roleModuleObj = that.popupJqObj.find('#role_module'),
                roleModuleTable = that.getRoleModuleTable(),
                roleModuleArr = roleModuleObj.val();
            // 作用模块切换事件
            roleModuleObj.bind('change',function () {
                // 多选 select 不可用 this.value , 只会获取第一个值，只能用 ld(this).val()
                var newVal = ld(this).val();
                for (var i = 0; i < Math.max(roleModuleArr.length,newVal.length); i ++) {
                    if(newVal[i] !== roleModuleArr[i]) {
                        if(newVal.length > roleModuleArr.length) {
                            var module = newVal[i];
                            that.roleModuleData.val.splice(i,0,{
                                module,
                                scope: [],
                            });
                            var newRow = that.getTableTrRow(i, that.roleModuleData,'module');
                            if(i === 0) {
                                roleModuleTable.append(newRow)
                            }
                            else {
                                that.getRoleModuleRowByIndex(newVal[i - 1]).after(newRow)
                            }
                            that.setRoleModuleRowEvent(module)
                        }
                        else {
                            that.roleModuleData.val.splice(i,1);
                            that.getRoleModuleRowByIndex(roleModuleArr[i]).remove();
                        }
                        break;
                    }
                }
                roleModuleArr = newVal;
            })

            // 编辑模块高级查找事件
            roleModuleTable.find('tr[row-index]').each(function (index,row) {
                that.setRoleModuleRowEvent(ld(row));
            })

            // 单据适用范围绑定
            var scopeCon = that.popupJqObj.find(`#${that.scopeConId}`),
                data = that.scopeData.val || (that.scopeData.val = {
                    scope: 'all',
                    scopeVal: '',
                });
            AjaxJSPage('ChooseScope', 'include/js/ScopePopup/ChooseScope.js');
            ChooseScope.init(scopeCon,{
                module: 'PricePolicy',
                data,
                confirm: function () {

                }
            })

            // 政策形式变化
            var formObj = that.popupJqObj.find('[name="pricepolicy_forms"]');
            formObj.unbind('change').bind('change',function () {
                var fromJq = ld(this);
                that.updateDetailRow(fromJq);
                that.setDetailRowEvent(0);
            })

            that.setDetailEvent();
        }

        getModuleScopeFirstTd(moduleList,colIndex) {
            var options = '';
            ld.each(moduleList,function (module,label) {
                options += `<option value="${module}">${label}</option>`;
            });

            var popupObj = CrmPopup.getPopupObj('last')
            if(popupObj && popupObj.highersearchobj && !popupObj.highersearchobj.updateColmnBlock) {
                //更新字段的change事件
                popupObj.highersearchobj.updateColmnBlock = function (moduleObj,colIndex) {
                    moduleObj = ld(moduleObj);
                    var module = moduleObj.val(),
                        colBlock = module === 'Accounts' ? this.resData.accountsBlock : this.resData.columns_block,
                        selId = `fcol` + colIndex,
                        selObj = moduleObj.parents('tr').first().find(`#${selId}`);
                    selObj.html(`<option value="" >--${jsnone}--</option>${colBlock}`);
                    selObj.val('')

                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(selId);
                    cls_resetComboxHtmlobj.setPopupObj(popupObj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,selObj.parents('td').first().width() - 15);
                }
            }

            return '' +
                `<td align="left" width="15%" >` +
                `<select id="module_${colIndex}" name="module_${colIndex}" class="commonSelectPop" style="width: 100%" onchange="CrmPopup.getPopupObj('last').highersearchobj.updateColmnBlock(this,'${colIndex}')">` +
                `${options}` +
                `</select>` +
                `</td>`;
        }

        setRoleModuleRowEvent(row) {
            var that = this;
            if(! (row instanceof ld) ) {
                row = that.getRoleModuleRowByIndex(row)
            }

            row.find('.ld-category-edit').bind('click',function () {
                that.editRoleModuleRow(ld(this))
            })

        }

        editRoleModuleRow(jqObj) {
            var that = this,
                tmpIndex = jqObj.parents('tr').index(),
                tmpModule = jqObj.parents('tr').attr('row-index'),
                data = that.roleModuleData.val,
                rowData = data[tmpIndex] ? data[tmpIndex] : data[tmpIndex] = {
                    module: tmpModule,
                    advance_demand: '',
                    advance_demand_groups: '',
                };
            getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
                var SetOtherConditionsObj = new SetOtherConditions();
                SetOtherConditionsObj.getAjaxUrl = () => that.getAjaxUrl();
                SetOtherConditionsObj.getParams = () => that.getUrlParam({
                    funName: 'getModuleCondition',
                    includeDetail: 'no',
                    fromModule: tmpModule,
                });
                SetOtherConditionsObj.SetDirDataObj(rowData);
                SetOtherConditionsObj.setpoptitle("政策适用范围");
                SetOtherConditionsObj.addTaskAfterOkfun(that.updateRoleModuleScopeByModule,{ module: tmpModule, index: tmpIndex });
                SetOtherConditionsObj.fun_other_conditions();
            });
        }

        updateRoleModuleScopeByModule(option) {
            var that = PricePolicyEdit.getInstance(),
                { module, index } = option,
                field = 'scope',
                trObj = that.getRoleModuleRowByIndex(module),
                tdObj = trObj.find(`td[col-field="${field}"]`),
                rowData = that.roleModuleData.val[index];
            ldAjaxsync(that.getAjaxUrl(),that.getUrlParam({
                funName: 'getRoleModuleScope',
                row: JSON.stringify(rowData),
            }),function (data) {
                rowData.scope = data.result.scope;
                DelProgressObjs();
            })
            tdObj.html(that.getFieldCon(index,that.roleModuleData,field));
        }

        updateDetailRow(formJqObj) {
            var that = this,
                index = 0;
            that.detailData.form = formJqObj.val();
            that.detailData.val = [ {  } ];
            console.log( that.detailData);
            that.getDetailTable().find('tr[row-index]').remove();
            that.getDetailTable().prepend( that.getTableTrRow(index, that.detailData) );
            that.setDetailEvent();
        }

        setDetailEvent() {
            var that = this,
                detailTable = that.getDetailTable();
            detailTable.find('tr[row-index]').each(function (index,trRow) {
                that.setDetailRowEvent(ld(trRow));
            })
            //新增价格政策事件
            detailTable.find('.addBtn').unbind('click').bind('click',function () {
                if(that.detailData.form === '') {
                    MessagePopup.TipZero_error('请先选择政策形式');
                    return
                }
                var index = that.detailData.val.length,
                    addTrObj = ld(this).parents('tr').first();
                that.detailData.val.push( {} )
                addTrObj.before( that.getTableTrRow(index, that.detailData) );
                that.updateDetailRowIndex();
                that.setDetailRowEvent( index );
            })
        }

        setDetailRowEvent(row) {
            var that = this;
            if(! (row instanceof ld) ) {
                row = that.getDetailRowByIndex(row)
            }
            row.find('.ld-category-copy').unbind('click').bind('click',function () {
                var index = ld(this).parents('tr').first().index(),
                    newRowVal = {};
                deepAssign(newRowVal,that.detailData.val[index]);
                that.detailData.val.splice(index,0,newRowVal);
                that.getDetailRowByIndex(index).after(that.getTableTrRow(index+1, that.detailData));
                that.updateDetailRowIndex();
                that.setDetailRowEvent( index+1 );
            })
            row.find('.ld-category-del').unbind('click').bind('click',function () {
                var index = ld(this).parents('tr').first().index();
                that.detailData.val.splice(index,1);
                that.getDetailRowByIndex(index).remove();
                that.updateDetailRowIndex();
            })

            that.setDetailRowDataBind(row);

        }

        updateDetailRowIndex() {
            var that = this;
            that.getDetailTable().find('tr[row-index]').each(function (index,row) {
                var rowObj = ld(row),
                    field = 'no';
                rowObj.attr('row-index',index);
                rowObj.find(`[col-field="${field}"]`).html( that.getFieldCon(index, that.detailData, field) )
            })
        }

        getDataBindObj() {
            return this.dataBindObj || ( this.dataBindObj = new DataHtmlBind() )
        }

        setDetailRowDataBind(row) {
            var that = this,
                index = row.attr('row-index'),
                data = that.detailData.val[index],
                dataBind = that.getDataBindObj(),
                conditionData = data.condition || ( data.condition = {} ),
                conditionObjs = row.find('[name="condition[]"]'),
                contentBindArr = ['content'];
            if(conditionObjs.length > 0) {
                ld.each(conditionObjs,function (index, conditionObj) {
                    dataBind.setDataBindByJqObj(ld(conditionObj), conditionData, index);
                })
            }
            if(contentBindArr) {
                ld.each(contentBindArr,function (index, name) {
                    dataBind.setDataBindByJqObj(row.find(`[name="${name}"]`), data, name);
                })
            }
        }

        getSuperPositionData() {
            return DragTransfer.getInstance(this.getSuperPositionConObj()).getData('right').join(',');
        }

        getSaveParams() {
            var that = this;
            return that.getUrlParam({
                roleModuleData: JSON.stringify(that.roleModuleData.val),
                scopeData: JSON.stringify(that.scopeData.val),
                detailData: JSON.stringify(that.detailData),
                superPositionData: that.getSuperPositionData(),
            })
        }
    }

    return PricePolicyEdit;
})();