/**
 * 高级查找平铺
 * XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
 */
function AdvanceFilterTiled(dom,popupobj) {
    cls_advanceFilter.call(this);
    this.divobj = dom;
    this.searchDivObj = '';
    this.popupobj = popupobj;

    this.tiledColumnArr = {};//存储平铺字段
    this.tiledColumnIndex = -1;
    this.showSelectStyle = 'no';
    this.objectSource = 'AdvanceFilterTiled';
    this.selectOptionMaxNum = 30;
    this.getAdvanceFilterStatus = false;

    var that = this;

    this.init = function (){
        that.searchDivObj = that.divobj.find('#AdvanceTiledSearchDiv');
        that.getCriteriaGroupsArr();
    }

    this.getSearchDivObj = function () {
        return that.divobj;
    }


    this.showAdvanceFilter = function (advft_criteria) {
        that.getAdvanceFilterInfo();
        if(empty(advft_criteria)) {
            return false;
        }
        var criteria_groups_arr = that.getCriteriaGroupsArr();
        criteria_groups_arr[1].columns = JSON.parse(advft_criteria);
        if(!criteria_groups_arr[1].columns || criteria_groups_arr[1].columns.length <= 0 ) {
            that.criteria_groups_arr[1].columns = {};
            return false;
        }
        // that.showAdvanceFilterPopup();
        // 获取信息
        var tiledColumnArr = {};
        var tiledColumnIndex = -1;
        that.setCriteriaGroups(criteria_groups_arr);
        var columns = criteria_groups_arr[1].columns;
        if (!empty(columns)){
            that.divobj.show();
        }
        ld.each(columns,function (index,info) {
            // info.value = '';
            // info.valueLabel = '';
            var columnname = info.columnname;
            if (tiledColumnArr.hasOwnProperty(columnname) || empty(info.comparator)){
                return true;
            }else {
                tiledColumnIndex++;
                tiledColumnArr[columnname] = tiledColumnIndex;
            }
            var columnindex = tiledColumnIndex;
            that.showAdvanceFilterRow(columnindex, info);
            that.showHideFval(columnindex);
        });
        that.showHideFilter();
        that.tiledColumnArr = tiledColumnArr;
        that.tiledColumnIndex = tiledColumnIndex;

    }
    
    this.showAdvanceFilterPopup = function () {
        var popupObj = new CrmPopup();
        popupObj.module = that.module;
        popupObj.divid = 'AdvanceTiledSearch';
        that.popupJqObj = ld('#'+that.divid);
        CrmPopup.global_listPopupObj.push(popupObj);
        that.setPopupobj(popupObj);
    }

    this.getAdvanceFilterInfo = function () {
        if (that.getAdvanceFilterStatus){
            return false;
        }
        var module = that.prevpopupobj.module;
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=getAdvanceSearchPopup&showSearchHistory=no';
        var params = '';
        if (that.criteria_groups_arr == ''){
            params = {'advft_criteria':that.advft_criteria,'advft_criteria_groups':that.getAdvftCriteriaGroups()}
        }
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        if(that.prevpopupobj.frommodule && that.prevpopupobj.frommodule === "Approve") {
            params.fromModule = that.prevpopupobj.frommodule;
        }
        ldAjaxsync(url, params, function(data){
            if(data.code == 1){
                that.setParams(data.result);
                that.getAdvanceFilterStatus = true;
            }
            else{

            }
            DelProgressObjs();
        });
    }

    this.getAdvftCriteriaGroups = function () {
        if(!that.advft_criteria_groups) {
            that.advft_criteria_groups = JSON.stringify([null,{"groupcondition":""}]);
        }
        return that.advft_criteria_groups;
    }

    this.getCriteriaGroupsArr = function () {
        if(!that.criteria_groups_arr) {
            that.criteria_groups_arr = {
                1: {
                    columns: {},
                }
            }
        }
        return that.criteria_groups_arr;
    }

    //添加平铺字段条件行
    this.addAdvanceFilterRow = function (columnInfo) {
        var columnname = columnInfo.columnname;
        that.tiledColumnIndex++;
        that.tiledColumnArr[columnname] = that.tiledColumnIndex;
        var columnIndex = that.tiledColumnIndex;
        that.criteria_groups_arr[1].columns[columnIndex] = columnInfo;
        that.showAdvanceFilterRow(columnIndex,columnInfo);
        that.showHideFval(columnIndex);
        that.showHideFilter();
    }

    //改变平铺字段显示条件和字段
    this.changeAdvanceFilterRow = function (lastColumnName,columnInfo){
        var lastColumnIndex = that.tiledColumnArr[lastColumnName];
        that.criteria_groups_arr[1].columns[lastColumnIndex] = columnInfo;
        var advft_criteria = JSON.stringify(that.criteria_groups_arr[1].columns);
        delete that.tiledColumnArr[lastColumnName];
        that.tiledColumnArr[columnInfo.columnname] = lastColumnIndex;
        that.searchDivObj.html('');
        that.showAdvanceFilter(advft_criteria);
    }

    //删除平铺字段显示条件
    this.delAdvanceFilterRow = function (columnName) {
        var columnIndex = that.tiledColumnArr[columnName];
        if(!that.criteria_groups_arr || !(that.criteria_groups_arr[1].columns) || !(that.criteria_groups_arr[1].columns[columnIndex])) {
            return false;
        }
        delete that.criteria_groups_arr[1].columns[columnIndex];
        delete that.tiledColumnArr[columnName];
        var rowObj = that.getSearchDivObj().find('#conditioncolumn_1_'+columnIndex);
        rowObj.remove();
        that.showHideFilter();
    }

    //显示平铺条件
    this.showAdvanceFilterRow = function (columnIndex, columnInfo) {
        var searchDivObj =  that.getSearchDivObj();
        var divObj =  that.getDivObj();
        if(!columnInfo){
            if (searchDivObj !== undefined && searchDivObj.find(`[tag="conditionColumn"]`).length === 0){
                searchDivObj.hide();
            }
            return false;
        }
        var columnname = columnInfo.columnname;
        var comparator = columnInfo.comparator;
        var value = columnInfo.value;
        var columncondition = columnInfo.columncondition;
        var valueLabel = columnInfo.valueLabel ? columnInfo.valueLabel : '';
        var groupid = 1;
        var columnArr = columnname.split(':');
        var fieldLabel = columnArr[3].split('_').pop();
        var searchField = '';
        var name = `conditioncolumn_${groupid}_${columnIndex}`;
        searchField += `<div class="conditionColunm ld-advance-tiled-row" id="${name}" name="${name}" groupindex="${groupid}" columnIndex="${columnIndex}" tag="conditionColumn">`;
        searchField += '<div id="controlWidth_'+columnIndex+'" style="display: flex;align-items: center;width: 100%">';
        searchField += `<div class="ld-advance-tiled-row-column ld-flex-wrap" style="width: 210px;min-width: 210px;display: flex;align-self: normal">`;
        searchField += `<div class="ld-form-item-content fcolDiv " name="fcolDiv_${groupid}_${columnIndex}" style="padding-top: 2px;width: 98px">`+
                            `<label class="overflow-space" style="max-width: 90px;display: inline-block" tag="showtitle" data-tip="${fieldLabel}" data-direction="top" data-type="position">${fieldLabel}:</label>` +
                            `<select class="ld-select-inner overflow-space" name="fcol${columnIndex}" id="fcol${columnIndex}" style="width: 190px; display: none;" disabled>` +
                                `<option value="${columnname}" selected>${fieldLabel}</option>` +
                            `</select >` +
                        `</div>`;
        searchField += `<div class="ld-form-item-content ld-advance-tiled-row-op" id="fopDiv_${groupid}_${columnIndex}" name="fopDiv_${groupid}_${columnIndex}" style="width: 95px;padding: 0;">`+
                            `<select class="ld-select-inner overflow-space" name="fop${columnIndex}" id="fop${columnIndex}" style="display: none">` +
                                '<option value="">'+arrJsPopLabel['NONE']+'</option>' +
                                that.advfilterhtml+
                            `</select >` +
                            `<div id="fopCom_${groupid}_${columnIndex}"></div>` +
                        `</div>`;
        searchField += `</div>`;
        searchField += `<div class="ld-form-item-content " id="fvalDiv_${groupid}_${columnIndex}" name="fvalDiv_${groupid}_${columnIndex}" style="min-width: 296px;padding: 0 24px 0 8px;display: flex;">`;
        if (that.source !== 'report' && that.source !== 'usereports') {
            searchField += `<input class="ld-input-inner overflow-space" style="width: 30%;min-width: 250px;" name="fval${columnIndex}" id="fval${columnIndex}" groupindex="${groupid}">`;
        }
        searchField += `</div>`;
        searchField += `</div>`;
        searchField += `</div>`;

        that.getDivObj().append(searchField)
        that.updatefOptions(columnIndex);
        AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
        var selectObj = searchDivObj.find(`#fop${columnIndex}`),
            selectDivObj = searchDivObj.find(`#fopCom_${groupid}_${columnIndex}`),
            selectedFlag = false,
            optionArr = Object.values(selectObj.get(0).childNodes).map(v => {
                var item = {value: v.value, label: v.label};
                if(comparator === v.value) {
                    item.selected = true;
                    selectedFlag = true;
                }
                return item;
            });
        if (optionArr[0].value == ''){
            optionArr.splice(0,1);
        }
        if(!selectedFlag && optionArr.length > 0) {
            optionArr[0].selected = true;
        }
        ld_Select.showSelect(selectDivObj.get(0), {
            list: optionArr,
            width: '95px',
            optionwidth: '95px',
            showtype: 'click',
            optionobjattr: ['value'],
            filterable: true,
            change: function (evt){
                selectObj.val(evt.NavBarItem.value);
                that.addRequiredElements(columnIndex);
                that.showHideFval(columnIndex)
                that.showHideFilter()
            }
        });
        selectObj.val(comparator);
        that.addRequiredElements(columnIndex);
        that.setRequiredElement(columnIndex, {
            comparator,
            value,
            valueArr: value.toString().split(','),
            valueLabel:valueLabel
        });

        if (that.objectSource && that.objectSource == 'AdvanceFilterTiled'){
            tooltip(that.divobj.find('[tag=showtitle]'), {transition: true, time: 200});
        }

        var popupObj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
        if(popupObj && !popupObj.AdvanceFilterTiledObj ) {
            popupObj.AdvanceFilterTiledObj = that;
        }

        var dataBindObj = that.getDataBindObj();
        dataBindObj.setDataBindByJqObj(selectObj, columnInfo, 'comparator');


    }
    
    this.getDivObj  = function () {
        return that.searchDivObj;
    }

    /** 无需 */
    this.addConditionGroup = function () {
        
    }

    //处理平铺字段条件
    this.checkAdvancedFilter = function () {
        var conditionColumns = that.searchDivObj.find('[tag=conditionColumn]');
        that.advft_criteria = '';
        that.criteria_groups_arr = '';
        that.getCriteriaGroupsArr();
        if (conditionColumns.length > 0){
            conditionColumns.each(function (index, item) {
                var tmpColIndex = ld(item).attr('columnindex');
                var tmpColumnInfo = that.checkAdvancedFilterRow(tmpColIndex);
                tmpColumnInfo.showAsTiled = 'yes';
                tmpColumnInfo.columncondition = 'and';
                that.criteria_groups_arr[1].columns[tmpColIndex] = tmpColumnInfo;
            });
            that.advft_criteria = JSON.stringify(that.criteria_groups_arr[1].columns);
            that.advft_criteria_groups = '[null,{"groupcondition":""}]';
        }
        // if(that.popupobj) {
        //     that.popupobj.advft_criteria = that.advft_criteria;
        //     that.popupobj.advft_criteria_groups = that.advft_criteria_groups;
        // }
        return true;
    }

    /** 根据fieldInfo获取关键字内容部分 */
    this.addRequiredElementsByField = function (columnName, opt) {
        var fieldInfo = that.getFieldInfoByColumnName(columnName);
        if(!fieldInfo)
            return false;
        var bigType = fieldInfo.bigType;
        if(that.requiredElementsList[bigType]) {
            return that.requiredElementsList[bigType](fieldInfo, opt);
        }
        return false;
    }

    this.requiredElementsList = {
        picklist : function (fieldInfo, opt) {
            var { fcol_value, fval_value, fop_value, fvalDivObj, columnIndex, groupIndex } = opt,
                columnInfo = that.getColumnInfoByIndex(groupIndex, columnIndex),
                belongFlag = that.newBelongArr.includes(fop_value),
                equalFlag = that.equalArr.includes(fop_value);
            if(columnInfo) {
                fval_value = columnInfo.value;
            }
            if(!belongFlag && !equalFlag ) {
                return false;
            }
            var optionList = that.getAvailableKeyValueByField(fieldInfo, { value: fval_value, comparator: fop_value, columnStr: fcol_value }),
                type = belongFlag ? 'checkbox' : 'radio',
                html = this.getOptionListHtml(fieldInfo, opt, optionList, type);
            fvalDivObj.html(html);
            if (Object.keys(optionList).length > that.selectOptionMaxNum && type === 'checkbox'){
                that.divobj.find('#fval'+columnIndex).select2(that.multiSettingsInfo);
                var select2ValueArr = optionList.filter(function (item){
                    if (item.selected === 'selected'){
                        return item.value;
                    }
                });
                that.divobj.find('#fval'+columnIndex).val(select2ValueArr).select2(that.multiSettingsInfo);//设置多选框选中值
            }
            if (Object.keys(optionList).length <= that.selectOptionMaxNum){
                that.setPickListWidth(columnIndex);
            }
            return true;
        },
        picklist_key : function (fieldInfo, opt) {
            return this.picklist(fieldInfo, opt);
        },
        multipicklist : function (fieldInfo, opt) {
            var { fcol_value, fval_value, fop_value, fvalDivObj, columnIndex, groupIndex } = opt,
                columnInfo = that.getColumnInfoByIndex(groupIndex, columnIndex),
                belongFlag = that.newBelongArr.includes(fop_value),
                equalFlag = that.equalArr.includes(fop_value);
            if(columnInfo) {
                fval_value = columnInfo.value;
            }
            if(!belongFlag && !equalFlag ) {
                return false;
            }
            var optionList = that.getAvailableKeyValueByField(fieldInfo, { value: fval_value, comparator: fop_value, columnStr: fcol_value }),
                html = this.getOptionListHtml(fieldInfo, opt, optionList);
            fvalDivObj.html(html);
            if (Object.keys(optionList).length > that.selectOptionMaxNum){
                that.divobj.find('#fval'+columnIndex).select2(that.multiSettingsInfo);
                var select2ValueArr = optionList.filter(function (item){
                    if (item.selected === 'selected'){
                        return item.value;
                    }
                });
                that.divobj.find('#fval'+columnIndex).val(select2ValueArr).select2(that.multiSettingsInfo);//设置多选框选中值
            }
            if (Object.keys(optionList).length <= that.selectOptionMaxNum){
                that.setPickListWidth(columnIndex);
            }

            return true;
        },
        multipicklist_key : function (fieldInfo, opt) {
            return this.multipicklist(fieldInfo, opt);
        },
        users : function (fieldInfo, opt) {
            var { fval_value, fop_value, fvalDivObj, columnIndex, groupIndex } = opt;
            if(!that.newBelongArr.includes(fop_value) && !that.equalArr.includes(fop_value)) {
                return false;
            }
            var html = '';
            html += `` +
                `<input class="ld-input-inner ld-input-inner-add" name="fval${columnIndex}" id="fval${columnIndex}" data-type="user" groupindex="${groupIndex}" value="" type="text" readonly="" data-scope="" placeholder="请选择用户">` +
                `<a name="chooseScopeUser" class="ld-text-select" href="javascript:;" data-value="user" style="right: 30px">+</a>` +
                `<a class="ld-text-clear" href="javascript:;" draggable="false" style="right: 55px">+</a>` +
                ``;
            fvalDivObj.html(html);
            that.chooseScopeInit(fvalDivObj.find(`[name="chooseScopeUser"]`), opt);
            return true;
        },
        selectoneuser : function (fieldInfo, opt) {
            return this.users(fieldInfo, opt);
        },
        selectmultiuser : function (fieldInfo, opt) {
            return this.users(fieldInfo, opt);
        },
        boolean: function (fieldInfo, opt) {
            var { fcol_value, fop_value, fval_value, fvalDivObj, groupIndex, columnIndex } = opt,
                columnInfo = that.getColumnInfoByIndex(groupIndex, columnIndex);
            columnInfo && (fval_value = columnInfo.value);
            if(!['e', 'n'].includes(fop_value) ) {
                return false;
            }
            var optionList = that.getAvailableKeyValueByField(fieldInfo, { value: fval_value, comparator: fop_value, columnStr: fcol_value }),
                html = this.getOptionListHtml(fieldInfo, opt, optionList, 'radio');
            fvalDivObj.html(html);
            return true;
        },
        getOptionListHtml: function (fieldInfo, opt, optionList, type = 'checkbox') {
            if(optionList.length === 0){
                optionList = [{'label':'','value':'','selected':'selected'}];
            }
            var { fval_value, columnIndex, groupIndex } = opt,
                valObjId = 'fval' + columnIndex,
                html = '',
                options = '';
            if (Object.keys(optionList).length > that.selectOptionMaxNum){
                if (type === 'checkbox'){
                    html += '<select name="fval'+columnIndex+'" multiple id="fval'+columnIndex+'" class="ld-select-inner select2 select2-offscreen select2-hidden-accessible" style="width: 100%" data-type="select2">'
                }else {
                    html += '<select name="fval'+columnIndex+'" id="fval'+columnIndex+'" class="ld-select-inner" style="width: 100%" data-type="select">'
                }
                ld.each(optionList, function(index, info) {
                    if(info.value === '') {
                        return true;
                    }
                    var columnName = fieldInfo.columnName,
                        name = columnIndex + '_' + columnName,
                        id = columnIndex + '_' + columnName + '_' + index,
                        selected = info.selected === 'selected' ? 'selected' : '';
                    html += '<option value="'+info.value+'" '+selected+'>'+info.label+'</option>';
                });
                html += '</select>'
            }else {
                ld.each(optionList, function(index, info) {
                    if(info.value === '') {
                        return true;
                    }
                    var columnName = fieldInfo.columnName,
                        name = columnIndex + '_' + columnName,
                        id = that.divid + '_' + columnIndex + '_' + columnName + '_' + index,
                        checked = info.selected === 'selected' ? 'checked' : '';
                    options += '' +
                        `<div class="ld-advance-check-item item" tag="checkitemDiv">` +
                        `<input type="${type}" id="${id}" name="${name}" ${checked} value="${info.value}"><label for="${id}" style="margin-top: -1px;">${info.label}</label>` +
                        `</div>`;
                });
            }
            html += `<div id="${valObjId}" data-type="select" name="${valObjId}" class="ld-flex-start ld-flex-wrap ld-advance-check-div" groupindex="${groupIndex}" value="${fval_value}">${options}</div>`;
            return html;
        },
    }

    //下拉平铺显示的宽度控制
    this.setPickListWidth = function (columnIndex){
        var conditioncolumnobj = that.divobj.find('#conditioncolumn_1_'+columnIndex);
        conditioncolumnobj.css('width','100%');
        var searchDiv_width = parseInt(that.searchDivObj.width());
        var fval_width = parseInt(that.searchDivObj.find('#fval'+columnIndex).width());
        var fvaldiv_width = fval_width + 218;
        if (fvaldiv_width > searchDiv_width * 0.66){

        }else if (fvaldiv_width > searchDiv_width * 0.33 && fvaldiv_width <= searchDiv_width * 0.66){
            conditioncolumnobj.css('width','66%');
        }else if (fvaldiv_width <= searchDiv_width * 0.33){
            that.divobj.find('#conditioncolumn_1_'+columnIndex).css('width','34%');
        }

    }

    this.showHideFval = function (columnindex){
        var fvalDivObj = that.searchDivObj.find('#fvalDiv_1_'+columnindex);
        var showHideBtnDivObj = that.searchDivObj.find('#showHideBtnDiv_'+columnindex);
        var fvalObj = fvalDivObj.find('#fval'+columnindex);
        if (fvalObj.data('type') !== 'select' || fvalObj.css('display') == 'none' || fvalObj.outerHeight() <= 32){
            showHideBtnDivObj.css('display','none');
            return false;
        }
        var conditionRowObj = that.searchDivObj.find('#conditioncolumn_1_'+columnindex);
        if (showHideBtnDivObj.length == 0){
            var html = '<div name="showHideBtnDiv_'+columnindex+'" id="showHideBtnDiv_'+columnindex+'" style="width: 80px;min-width: 80px;align-self: normal" >'
            html += ' <div id="showHideFvalBtn_'+columnindex+'" data-columnindex="'+columnindex+'" style="float: right"  data-colomnindex="'+columnindex+'" class="ld_Select-component ld-advance-tiled-showhidebtn-div" data-status="hidden">';
            html += '<span style="margin-right: 5px">'+arrJsPopLabel['EXPANSION']+'</span><b class="ld_Select_arrowicon" style="margin: -14px 2px 0 2px;"></b>'
            html += '</div></div>';
            conditionRowObj.append(html);
            conditionRowObj.find('#showHideFvalBtn_'+columnindex).off('click').on('click',function () {
                var columnindex = ld(this).data('columnindex')
                var fvalObj = that.searchDivObj.find('#fval'+columnindex);
                var checkitemDivObj = fvalObj.find('[tag=checkitemDiv]');
                var status = ld(this).data('status');
                if (status === 'hidden'){
                    ld(this).data('status','show');
                    checkitemDivObj.css('display','');
                    ld(this).html('<span style="margin-right: 5px">'+arrJsPopLabel['COLLAPSE']+'</span><b class="ld_Select_arrowicon activeicon" style="margin: -5px 2px 0 2px;"></b>');
                }else {
                    ld(this).data('status','hidden');
                    var offsetTop = -1;
                    ld.each(checkitemDivObj,function (index,obj){
                        offsetTop = offsetTop === -1 ? obj.offsetTop : offsetTop;
                        if (obj.offsetTop != offsetTop){
                            ld(obj).css('display','none');
                        }
                    })
                    ld(this).html('<span style="margin-right: 5px">'+arrJsPopLabel['EXPANSION']+'</span><b class="ld_Select_arrowicon" style="margin: -14px 2px 0 2px;"></b>');
                }
                setContentHeight(that.popupobj.module);
            });
        }
        that.divobj.find('#showHideBtnDiv_'+columnindex).css('display','');
        var status = that.divobj.find('#showHideFvalBtn_'+columnindex).data('status');
        var checkitemDivObj = fvalObj.find('[tag=checkitemDiv]');
        if (fvalObj.outerHeight() > 32 && status === 'hidden'){
            var offsetTop = -1;
            ld.each(checkitemDivObj,function (index,obj){
                offsetTop = offsetTop === -1 ? obj.offsetTop : offsetTop;
                if (obj.offsetTop != offsetTop){
                    ld(obj).css('display','none');
                }
            })
        }else {
            checkitemDivObj.css('display','');
        }
    }

    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    this.checkAdvancedFilterByField = function (fieldInfo, opt) {
        if(!fieldInfo || !opt)
            return false;
        var bigType = fieldInfo.bigType;
        if(that.checkFun[bigType]) {
            return that.checkFun[bigType](fieldInfo, opt);
        }
        return false;
    }

    this.checkFun = {
        picklist : function (fieldInfo, opt) {
            var { comparatorValue } = opt,
                value = '';
            // 下拉框字段 属于不属于 / 等于不等于 的处理
            if(that.newBelongArr.includes(comparatorValue) || that.equalArr.includes(comparatorValue)) {
                value = this.getOptionValue(fieldInfo, opt);
                return { value };
            }
            return false;
        },
        picklist_key : function (fieldInfo, opt) {
            return this.picklist(fieldInfo, opt);
        },
        multipicklist : function (fieldInfo, opt) {
            var { comparatorValue } = opt,
                value = '', valueLabel = '';
            // 下拉框字段 属于不属于 / 等于不等于 的处理
            if(that.newBelongArr.includes(comparatorValue)) {
                value = this.getOptionValue(fieldInfo, opt);
                valueLabel = value.replaceAll('|', ',');
                return { value, valueLabel };
            }
            else if(that.equalArr.includes(comparatorValue)) {
                value = this.getOptionValue(fieldInfo, opt);
                valueLabel = value.replaceAll('|', ',');
                value = value.replaceAll('|', ' |##| ');
                return { value, valueLabel };
            }
            return false;
        },
        multipicklist_key : function (fieldInfo, opt) {
            return this.multipicklist(fieldInfo, opt);
        },
        // 用户字段属于不属于的处理
        users : function (fieldInfo, opt) {
            var { fvalobj, comparatorValue } = opt,
                value = '', valueLabel = '';
            if(that.newBelongArr.includes(comparatorValue)) {
                var scopeData = fvalobj.data('scope-data');
                value = scopeData.scopeVal.toString().replaceAll(',', '|');
                valueLabel = scopeData.scopeValLabel;
                return { value, valueLabel };
            }else if (that.equalArr.includes(comparatorValue)){
                var scopeData = fvalobj.data('scope-data');
                value = scopeData.scopeValLabel;
                valueLabel = scopeData.scopeVal;
                return { value, valueLabel };
            }
            return false;
        },
        selectoneuser : function (fieldInfo, opt) {
            return this.users(fieldInfo, opt);
        },
        selectmultiuser : function (fieldInfo, opt) {
            return this.users(fieldInfo, opt);
        },
        boolean: function (fieldInfo, opt) {
            var { comparatorValue } = opt,
                value = '';
            // 复选框字段 等于不等于 的处理
            if(that.equalArr.includes(comparatorValue) ) {
                value = this.getOptionValue(fieldInfo, opt);
                return { value };
            }
            return false;
        },
        getOptionValue: function (fieldInfo, opt) {
            var { fvalobj } = opt,
                checkObjs = fvalobj.find('input'),
                valueArr = [];
            checkObjs.each( (index, checkObj) => {
                checkObj = ld(checkObj);
                if(checkObj.prop('checked')) {
                    var id = checkObj.attr('id'),
                        optionIndex = id.split('_').pop(),
                        optionValue = that.getKeyValueByIndex(fieldInfo, optionIndex);
                    if(optionValue) {
                        valueArr.push(optionValue);
                    }
                }
            })
            return valueArr.join('|');
        }
    }

    this.saveAdvanceTiled = function () {
        // var save = that.debounce(that.saveAdvanceTiledFun, 500);
        // save();
        that.saveAdvanceTiledFun();
    }

    this.saveAdvanceTiledFun = function () {
        that.checkAdvancedFilter();
        setContentHeight(that.popupobj.module);
        var viewid = ld('#'+that.popupobj.divid).find('#viewname').val();
        ldAjax(that.getAjaxUrl(), {
            funName: 'saveAdvanceTiled',
            advft_criteria: that.advft_criteria,
            viewid: viewid,
        }, function (data) {
            DelProgressObjs();
        })
    }

    // 清空数据
    this.clear = function () {
        that.criteria_groups_arr = that.getCriteriaGroupsArr();
        that.criteria_groups_arr[1].columns = {};
        that.advft_criteria = '';
        that.advft_criteria_groups = '';
        that.getSearchDivObj().find(`[tag="conditionColumn"]`).remove();
    }
    
    this.clearAllFValInput = function () {
        var columns = that.criteria_groups_arr[1].columns;
        ld.each(columns,function (columnindex,column) {
            that.clearFvalInput(columnindex);
        })
    }

    // 获取用于查找的高级查找条件，过滤关键字值为空的条件
    this.getSearchAdvftCriteria = function () {
        if(that.advft_criteria === '')
            return '';
        var tmpAdvftCriteria = JSON.parse(that.advft_criteria),
            newArr = [];
        ld.each(tmpAdvftCriteria,function (index,tmpColInfo) {
            if(!empty(tmpColInfo.value)) {
                newArr.push(tmpColInfo);
            }
        })
        return JSON.stringify(newArr);
    }

    //加载和绑定事件
    this.setEvents = function (){
        that.setShowHideEvents();
    }
    //展开收起事件
    this.setShowHideEvents = function (){
        var showHideObj = that.getSearchDivObj().find('#showHideTiledBtn_div');
        showHideObj.off('click').on('click',function (){
            var status = ld(this).data('status');
            var newStatus = status === 'hidden' ? 'show' : 'hidden';
            if (status === 'hidden'){
                ld(this).data('status',newStatus);
                ld(this).html('<span style="margin-right: 5px">'+arrJsPopLabel['COLLAPSE']+'</span><b class="ld_Select_arrowicon activeicon" style="margin: -5px 2px 0 2px;"></b>');
                that.searchDivObj.find('[tag=conditionColumn]').css('display','');
            }else {
                ld(this).data('status',newStatus);
                ld(this).html('<span style="margin-right: 5px">'+arrJsPopLabel['EXPANSION']+'</span><b class="ld_Select_arrowicon" style="margin: -14px 2px 0 2px;"></b>');
                var offsetTop = -1;
                var hiddeType = false;
                ld.each(that.searchDivObj.find('[tag=conditionColumn]'),function (index,obj){
                    if (hiddeType){
                        ld(obj).css('display','none');
                    }else {
                        offsetTop = offsetTop === -1 ? obj.offsetTop : offsetTop;
                        if (obj.offsetTop != offsetTop){
                            hiddeType = true;
                            ld(obj).css('display','none');
                        }
                    }
                });
            }
            //调整列表table高度
            setContentHeight(that.popupobj.module);
            //记住展开收起状态
            var url = that.getAjaxUrl();
            var viewid = ld('#'+that.popupobj.divid).find('#viewname').val();
            var params = {viewid:viewid,funName:'setAdvanceTiledShowStatus',status:newStatus}
            ldAjaxNoProgress(url,params,function (data) {

            })
        })
    }

    //显示条件隐藏按钮的展开收起
    this.showHideFilter = function (){
        var conditionColumnobj = that.searchDivObj.find('[tag=conditionColumn]');
        if (conditionColumnobj.length === 0){
            that.divobj.hide();
        }else {
            that.divobj.show();
            var offsetTop = -1;
            var showHideTiledBtn_divobj = that.divobj.find('#showHideTiledBtn_div');
            showHideTiledBtn_divobj.hide();
            var status = showHideTiledBtn_divobj.data('status');
            if (status == 'hidden'){
                that.getSearchDivObj().find('#showHideTiledBtn_div').html('<span style="margin-right: 5px">'+arrJsPopLabel['EXPANSION']+'</span><b class="ld_Select_arrowicon" style="margin: -14px 2px 0 2px;"></b>');
            }else {
                that.getSearchDivObj().find('#showHideTiledBtn_div').html('<span style="margin-right: 5px">'+arrJsPopLabel['COLLAPSE']+'</span><b class="ld_Select_arrowicon activeicon" style="margin: -5px 2px 0 2px;"></b>');
            }
            var hideType = false;
            ld.each(that.searchDivObj.find('[tag=conditionColumn]'),function (index,obj){
                if (hideType && status === 'hidden'){
                    ld(obj).css('display','none');
                }else {
                    offsetTop = offsetTop === -1 ? obj.offsetTop : offsetTop;
                    if (obj.offsetTop != offsetTop){
                        showHideTiledBtn_divobj.show();
                        if (status === 'hidden'){
                            hideType = true;
                            ld(obj).css('display','none');
                        }
                    }
                }
            });
        }
        setContentHeight(that.popupobj.module);
    }

    //设置平铺条件
    this.refresh = function (tiledFilter){
        that.criteria_groups_arr[1].columns = tiledFilter;
        that.searchDivObj.html('');
        if (tiledFilter.length === 0 || empty(tiledFilter)){
            that.divobj.hide();
            that.saveAdvanceTiled();
        }else {
            var advft_criteria = JSON.stringify(that.criteria_groups_arr[1].columns);
            that.showAdvanceFilter(advft_criteria);
        }
    }
}
AdvanceFilterTiled.prototype = Object.create(cls_advanceFilter.prototype);
AdvanceFilterTiled.prototype.constructor = AdvanceFilterTiled;

/**
 * @returns {AdvanceFilterTiled}
 */
AdvanceFilterTiled.getInstance = function (dom,popupobj) {
    popupobj = !popupobj ? CrmPopup.getPopupObj('last') : popupobj;
    dom = !dom ? ld('#'+popupobj.divid).find('#AdvanceTiledSearch') : dom;
    dom = ld(dom).get(0);
    if(!dom || typeof(dom) == "undefined") {
       return false;
    }else {
        if(dom.AdvanceFilterTiledObj) {
            return dom.AdvanceFilterTiledObj;
        }
        dom.AdvanceFilterTiledObj = new AdvanceFilterTiled(ld(dom),popupobj);
        dom.AdvanceFilterTiledObj.init();
        return dom.AdvanceFilterTiledObj;
    }
}