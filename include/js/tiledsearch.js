/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 *********************************************************************************/

var tiled_column_key = 'tiled_column';
var tiled_group_key = 'tiled_group';
var tiled_filter_div = 'tiled_filter_div';


function tiled_updatefOptions(sel, opSelName) {
    var selObj = document.getElementById(opSelName);
    var fieldtype = null;

    if (selObj == undefined || selObj == null || sel == undefined || sel == null) {
        return;
    }
    if (selObj.selectedIndex < 0 || sel.selectedIndex < 0) {
        return;
    }
    var currOption = selObj.options[selObj.selectedIndex];
    var currField = sel.options[sel.selectedIndex];

    if (currField.value != null && currField.value.length != 0) {
        fieldtype = trimfValues(currField.value);
        ops = typeofdata[fieldtype];
        //alert(fieldtype);
        var off = 0;
        if (ops != null) {

            var nMaxVal = selObj.length;
            for (nLoop = 0; nLoop < nMaxVal; nLoop++) {
                selObj.remove(0);
            }
            //by LD Can 20121130 none修改为无
            selObj.options[0] = new Option(jsnone, '');
            if (currField.value == '') {
                selObj.options[0].selected = true;
            }
            off = 1;
            var k = 0;

            for (var i = 0; i < ops.length; i++) {
                var label = fLabels[ops[i]];

                if (label == null) continue;

                if (currField.value.indexOf('publicaccount:publicaccount:Accounts') > 0 || currField.value.indexOf('currency_id') > 0)//客户模块中是否公海字段
                {
                    if (ops[i] != 'e' && ops[i] != 'n') {
                        continue;
                    }
                }
                if (currField.value.indexOf('content:content:PublicAnnouncement') > 0)//客户模块中是否公海字段
                {
                    if (ops[i] != 'c') {
                        continue;
                    }
                }
                if (currField.value.indexOf("conversion_rate") > 0) {

                    if (ops[i] == 'isnull' || ops[i] == 'isnotnull') {
                        continue;
                    }
                }

                var option = new Option(fLabels[ops[i]], ops[i]);
                selObj.options[k + off] = option;
                k++;
                if (currOption != null && currOption.value == option.value) {
                    option.selected = true;
                }
            }
            //36087: 单据列表界面>高级查找弹出层>选择时间字段：区间字段默认放在第二。（所有的帐套都要更改）

            if (fieldtype == 'D' || fieldtype == 'DT') {
                var resultobj = datetimestr;//eval('.popupobj.datatimestr.');
                /* var option = new Option (arrJsPopLabel['Interval'], 'bw');
                 selObj.options[k + off] = option;
                 k++;*/


                ld.each(datetimestr, function (value, resultobj) {


                    var option = new Option(resultobj[2], value);
                    selObj.options[k + off] = option;
                    k++;
                });

            }
			//获取字段信息
            var popupobj = CrmPopup.getPopupObj("last");
            var fieldsinfo = [];
            if(CrmPopup.global_listPopupObj.length>0){
                for(var i=CrmPopup.global_listPopupObj.length-1;i>=0;i--)
                {
                     if(CrmPopup.global_listPopupObj[i].module==popupobj.module&&CrmPopup.global_listPopupObj[i].fields!= undefined)
                     {
                         fieldsinfo = CrmPopup.global_listPopupObj[i].fields;
                         break;
                     }
                }
            }
            //zkt 20220518 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
           if(fieldsinfo.length>0){
				//判断字段类型，若为用户字段，则条件下拉框增加当前用户选项
                var string_array = currField.value.split(":");
                var fieldname = string_array[2];
                ld.each(fieldsinfo,function(index){
                    var fieldinfo = fieldsinfo[index];
                    if(fieldinfo['fieldname']==fieldname){
                        if(global_multiuser_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
                            var option = new Option (fLabels['includeuser'], 'curuser');
                            selObj.options[k + off] = option;
                            k++;
                        }
                        else if(global_user_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
                            var option = new Option (fLabels['curuser'], 'curuser');
    				        selObj.options[k + off] = option;
                             k++;   
                        }
                    }
                })
           }
        }
    } else {
        if (currField.value == '') {
            selObj.options[0].selected = true;
        }
    }
}

function tiled_deleteGroup(groupIndex) {
    removeElement('tiled_conditiongroup_' + groupIndex);

    var keyOfTheGroup = tiled_column_index_array.indexOf(groupIndex);
    var isLastElement = true;

    for (var i = keyOfTheGroup; i < tiled_column_index_array.length; ++i) {
        var nextGroupIndex = tiled_column_index_array[i];
        var nextGroupBlockId = "tiled_conditiongroup_" + nextGroupIndex;
        if (document.getElementById(nextGroupBlockId)) {
            isLastElement = false;
            break;
        }
    }


    if (isLastElement) {
        for (var i = keyOfTheGroup - 1; i >= 0; --i) {
            var prevGroupIndex = tiled_column_index_array[i];
            var prevGroupGlueId = "tiled_gpcon" + prevGroupIndex;
            if (document.getElementById(prevGroupGlueId)) {
                removeElement(prevGroupGlueId);
                break;
            }
        }
    }
}
// 无本地搜索条件新行添加后初始化
function tiled_addConditionRowInit(type) {
    var conditionColumnRowElement = document.getElementById('tiled_fcol' + tiled_column_index_count);
    if (type=='init'){
        var index = ld('#tiled_conditiongrouptable_' + tiled_group_index_count + ' tr[name=tiled_conditionColumn]').length;
        // 为新加的列初始化
        conditionColumnRowElement.value =ld("#tiled_fcol" + tiled_column_index_count).find("option").eq(index).val();
    }
    //选择条件赋值
    tiled_addConditionRowInitafter(tiled_column_index_count)
}

function tiled_addConditionRowInitafter(columnIndex){
    var conditionColumnRowElement = document.getElementById('tiled_fop' + columnIndex);

    tiled_updatefOptions(conditionColumnRowElement, 'tiled_fop' + columnIndex);
    document.getElementById('tiled_fop' + columnIndex).value = ld("#tiled_fop"+columnIndex).find("option").eq(1).val();
    //选择条件 改变关键字类型
    tiled_addRequiredElements(columnIndex);
}

// 本地无搜索条件 添加默认列
function tiled_addNewConditionGroup(parentNodeId,module,is_admin) {
    tiled_addConditionGroup(parentNodeId,module,is_admin);
    var ilength = 3;
    //zxm chinamap客户地图  默认显示一行
    if(module=="ChinaMap"){
        ilength = 1;
    }
    // 初始化默认显示3行
    for(var i=0;i<ilength;i++){
        tiled_addConditionRow(tiled_group_index_count);
        tiled_addConditionRowInit();
    }
}

function tiled_deleteColumnRow(groupIndex, columnIndex) {
    //显示新增按钮
    if (ld('#tiled_conditiongrouptable_' + groupIndex + ' tr[name=tiled_conditionColumn]').length >= 5) {
        ld('#tiled_groupfooter_' + groupIndex).show()
    }
    removeElement('tiled_conditioncolumn_' + groupIndex + '_' + columnIndex);
    var groupColumns = tiled_column_index_array[groupIndex];
    var keyOfTheColumn = groupColumns.indexOf(columnIndex);
    var isLastElement = true;

    // tiled_column_index_count --;
    for (var i = keyOfTheColumn; i < groupColumns.length; ++i) {
        var nextColumnIndex = groupColumns[i];
        var nextColumnRowId = 'tiled_conditioncolumn_' + groupIndex + '_' + nextColumnIndex;
        if (document.getElementById(nextColumnRowId)) {
            isLastElement = false;
            if (ld("select[id^='tiled_fcon']").length < 1) {
                ld('#tiledfiltershow').css('display', 'none');
                // @edit:dong @date:2020/08/17 @reason:  只有一条隐藏删除
                ld('#tiled_filter_div .delete_col_button').css('display', 'none');
            }
            break;
        }
    }
    if (isLastElement) {
        for (var i = keyOfTheColumn - 1; i >= 0; --i) {
            var prevColumnIndex = groupColumns[i];
            var prevColumnGlueId = "tiled_fcon" + prevColumnIndex;
            if (document.getElementById(prevColumnGlueId)) {
                removeElement(prevColumnGlueId);
                if (ld("select[id^='tiled_fcon']").length < 1) {
                    ld('#tiledfiltershow').css('display', 'none');
                    // @edit:dong @date:2020/08/17 @reason:  只有一条隐藏删除
                    ld('#tiled_filter_div .delete_col_button').css('display', 'none');
                }
                break;
            }
        }
    }
    //ld("#conditiongrouptable_"+groupIndex+" .deleteauto").click();
    // alert(ld("#conditiongrouptable_"+groupIndex+" tr").length);
    //高级查询>添加新组合：填写数据，当第一行的内容删除时第一行下面的下拉框中的内容也清除。
    if (ld("#tiled_conditiongrouptable_" + groupIndex + " tr").length <= 2)
        tiled_deleteGroup(groupIndex);
}

function tiled_addRequiredElements(columnindex) {

    var colObj = document.getElementById('tiled_fcol' + columnindex);
    var opObj = document.getElementById('tiled_fop' + columnindex);
    var valObj = document.getElementById('tiled_fval' + columnindex);
    if (colObj == undefined || colObj == null || opObj == undefined || opObj == null) {
        return;
    }
    if (colObj.selectedIndex < 0 || opObj.selectedIndex < 0) {
        return;
    }
    var currField = colObj.options[colObj.selectedIndex];
    var currOp = opObj.options[opObj.selectedIndex];

    //wym BUG0078076 kfbcrm-平铺查找-选择条件为“是空值”“不是空值”时，关键字输入框应不显示
    if(currOp.value=='isnull'||currOp.value=='isnotnull'||currOp.value=='curuser'){
        ld(valObj).css('display','none');
        ld(valObj).siblings('.icon-clear').css('display','none');
        ld(valObj).siblings('.Wdate').css('display','none');
        return;
    }else{
        ld(valObj).css('display','');
        ld(valObj).siblings('.icon-clear').css('display','');
    }

    var fieldtype = null;
    if (currField.value != null && currField.value.length != 0) {
        var fieldInfo = currField.value.split(":");
        var tableName = fieldInfo[0];
        var fieldName = fieldInfo[2];
        fieldtype = fieldInfo[4];
        //如果选择的是不日期和时间移除日期显示格式
        if (fieldtype != 'D' && fieldtype != 'DT' && fieldtype != 'T') {

            var parentObj = valObj.parentNode;
            //edit:can 14275: 所有模块-列表：高级查询，错误。;
            var childs = parentObj.childNodes;
            for (var i = childs.length - 1; i >= 0; i--) {
                parentObj.removeChild(childs.item(i));
            }

            var node5 = document.createElement('input');
            node5.setAttribute('type', 'text');
            node5.setAttribute('class', 'width150 commonTextBoxPop');
            // node5.setAttribute('style', 'width:138px');
            node5.setAttribute('id', 'tiled_fval' + columnindex);
            node5.setAttribute('name', 'tiled_fval' + columnindex);
            //wym 2405278 BUG20240527-55 高级查找、平铺查找中，属于和不属于的时候关键字中没有对应的提示，由于分隔符号变更，提示同步需要修改为“多个值用|隔开”
            if(ld(opObj).val() == 'belong' || ld(opObj).val() == 'notbelong'){
                node5.setAttribute('placeholder',arrJsPopLabel['SEARCHBELONGTIP']);
            }
            /*//18763: 常用报表>销售预测分析表：转到高级查询，录入查找关键字后，按键盘上的Enter键，结果：页面跳转到了首页。
            node5.onkeypress=function(event){
                var e=event||window.event;
                var prevpopupobj=CrmPopup.getPopupObj('lastprev');
                if(e.keyCode==13)
                {
                    if(prevpopupobj.module=='OftenUseReport')
                            generateReport(node5);
                    return false;
                }
            }*/
            parentObj.appendChild(node5);

        } else {
            //直接删除onclick事件，时间和日期切换的时候，控件无法自动切换，先删除橡皮擦，新增个时间或日期输入框，再删除老的输入框
            if (document.getElementById('tiled_fval_ext' + columnindex)) removeElement('tiled_fval_ext' + columnindex);

            if (document.getElementById('tiled_clear_text_ext' + columnindex)) removeElement('tiled_clear_text_ext' + columnindex);
            var timeformat = " %H:%M:%S";
            var showtime = ' HH:mm:ss';
            if (fieldtype == 'D' || (tableName == 'ld_activity' && fieldName == 'date_start')) {
                timeformat = '';
                showtime = '';
            }
            var node5 = document.createElement('input');
            node5.setAttribute('onClick', 'WdatePicker({startDate:"%y-%M-%d' + timeformat + '",dateFmt:"yyyy-MM-dd' + showtime + '",alwaysUseStartDate:true})');
            node5.setAttribute('class', 'Wdate width150 WdateImage');
            node5.setAttribute('type', 'text');
            node5.setAttribute('id', 'tiled_fval' + columnindex);
            node5.setAttribute('name', 'tiled_fval' + columnindex);
            // node5.setAttribute('style','width:138px;');

            var parentObj = valObj.parentNode;
            parentObj.appendChild(node5);

            if (document.getElementById('tiled_fval' + columnindex)) removeElement('tiled_fval' + columnindex);
            valObj = document.getElementById('tiled_fval' + columnindex);
            if (document.getElementById('clearfval_' + columnindex)) removeElement('clearfval_' + columnindex);


        }
        switch (fieldtype) {
            case 'D':
            case 'DT':
            case 'T':
                if (fieldtype == 'T' && tableName.indexOf('ld_crmentity') < 0) {
                    tiled_defaultRequiredElements(columnindex);
                    break;
                }
                var dateformat = $('jscal_dateformat').value;
                var timeformat = " %H:%M:%S";
                var showtime = ' HH:mm:ss';
                if (fieldtype == 'D' || (tableName == 'ld_activity' && (fieldName == 'date_start' || fieldName == 'due_date'))) {
                    timeformat = '';
                    showtime = '';
                }

                if (!document.getElementById('jscal_trigger_fval' + columnindex)) {
                    var node = document.getElementById('tiled_fval' + columnindex);
                    node.setAttribute('onClick', 'WdatePicker({startDate:"%y-%M-%d' + timeformat + '",dateFmt:"yyyy-MM-dd' + showtime + '",alwaysUseStartDate:true})');
                    node.setAttribute('class', 'Wdate width150 WdateImage');
                    // node.setAttribute('style','width:138px;');

                }

                var isexistsdatestr = isExistsDateTimeStr(currOp.value);

                if (currOp.value == 'bw' || isexistsdatestr == 'yes') {
                    if (!document.getElementById('tiled_fval_ext' + columnindex)) {
                        //var fillernode = document.createElement('br');

                        var node1 = document.createElement('input');
                        node1.setAttribute('onClick', 'WdatePicker({startDate:"%y-%M-%d' + timeformat + '",dateFmt:"yyyy-MM-dd' + showtime + '",alwaysUseStartDate:true})');
                        node1.setAttribute('class', 'Wdate width150 WdateImage');
                        node1.setAttribute('type', 'text');
                        node1.setAttribute('id', 'tiled_fval_ext' + columnindex);
                        node1.setAttribute('name', 'tiled_fval_ext' + columnindex);
                        // node1.setAttribute('style','width:138px;');

                        var parentObj = valObj.parentNode;
                        //parentObj.appendChild(fillernode);
                        parentObj.appendChild(node1);
                    }
                    var resultobj = datetimestr;
                    for (var timekey in datetimestr) {

                        if (timekey == currOp.value) {
                            if (fieldtype == 'DT') {
                                document.getElementById('tiled_fval' + columnindex).value = resultobj[timekey][0] + " 00:00:00";
                                document.getElementById('tiled_fval_ext' + columnindex).value = resultobj[timekey][1] + " 23:59:59";
                            } else {
                                document.getElementById('tiled_fval' + columnindex).value = resultobj[timekey][0];
                                document.getElementById('tiled_fval_ext' + columnindex).value = resultobj[timekey][1];
                            }
                            document.getElementById('tiled_fval' + columnindex).disabled = true;
                            document.getElementById('tiled_fval_ext' + columnindex).disabled = true;
                            break;
                        }
                    }
                    if (!document.getElementById('jscal_trigger_tiled_fval_ext' + columnindex)) {
                        var node = document.getElementById('tiled_fval' + columnindex);
                        node.setAttribute('onClick', 'WdatePicker({startDate:"%y-%M-%d' + timeformat + '",dateFmt:"yyyy-MM-dd' + showtime + '",alwaysUseStartDate:true})');
                        node.setAttribute('class', 'Wdate width150 WdateImage');
                        node.setAttribute('style', 'margin-right: 8px;');

                    }

                } else {
                    if (document.getElementById('tiled_fval_ext' + columnindex)) removeElement('tiled_fval_ext' + columnindex);
                    if (document.getElementById('jscal_trigger_tiled_fval_ext' + columnindex)) removeElement('jscal_trigger_tiled_fval_ext' + columnindex);
                    if (document.getElementById('tiled_clear_text_ext' + columnindex)) removeElement('tiled_clear_text_ext' + columnindex);
                }

                break;
            default    :
                tiled_defaultRequiredElements(columnindex);
        }

        if (isexistsdatestr != 'yes') {
            var node6 = document.createElement('input');
            node6.setAttribute('type', 'button');
            node6.setAttribute('id', 'tiled_clear_text_ext' + columnindex);
            node6.setAttribute('class', 'icon-homeimg icon-clear inpb-advSearchreset marL5');
            node6.setAttribute('style', 'display:none');
            node6.style.cursor = "pointer";
            node6.onclick = function () {
                document.getElementById('tiled_fval' + columnindex).value = '';
                document.getElementById('tiled_fval_ext' + columnindex).value = '';
                return false;
            }

            parentObj.appendChild(node6);
        }
        ld('#tiled_clear_text_ext' + columnindex).show();
        if (currOp.value == 'isnull' || currOp.value == 'isnotnull' || currOp.value == 'curuser' ) {
            document.getElementById('tiled_fval' + columnindex).value = '';
            document.getElementById('tiled_fval' + columnindex).setAttribute("readonly", true, 0);
        } else {
            document.getElementById('tiled_fval' + columnindex).removeAttribute("readonly");
        }
    }
}

function tiled_defaultRequiredElements(columnindex) {
    if (document.getElementById('jscal_trigger_fval' + columnindex)) removeElement('jscal_trigger_fval' + columnindex);
    if (document.getElementById('tiled_fval_ext' + columnindex)) removeElement('tiled_fval_ext' + columnindex);
    if (document.getElementById('jscal_trigger_tiled_fval_ext' + columnindex)) removeElement('jscal_trigger_tiled_fval_ext' + columnindex);
    if (document.getElementById('tiled_clear_text_ext' + columnindex)) removeElement('tiled_clear_text_ext' + columnindex);
}

function tiled_checkAdvancedFilter() {
    var escapedOptions = new Array('account_id', 'contactid', 'contact_id', 'product_id', 'parent_id', 'campaignid', 'potential_id', 'assigned_user_id1', 'quote_id', 'accountname', 'salesorder_id', 'vendor_id', 'time_start', 'time_end', 'lastname', 'accountid');

    var conditionColumns = vt_getElementsByName('tr', "tiled_conditionColumn");
    var criteriaConditions = []; //设置的条件 全部保存
    var criteriaConditionsSearch = []; //搜索需要的条件，过滤部分
    for (var i = 0; i < conditionColumns.length; i++) {

        var columnRowId = conditionColumns[i].getAttribute("id");
        var columnRowInfo = columnRowId.split("_");
        // @edit:dong @date:2020/08/17 @reason: 添加了前缀分割后数组变大了
        var columnGroupId = columnRowInfo[2];
        var columnIndex = columnRowInfo[3];

        var columnId = "tiled_fcol" + columnIndex;
        var columnObject = getObj(columnId);
        var selectedColumn = trim(columnObject.value);
        var selectedColumnIndex = columnObject.selectedIndex;
        var selectedColumnLabel = columnObject.options[selectedColumnIndex].text;

        var comparatorId = "tiled_fop" + columnIndex;
        var comparatorObject = getObj(comparatorId);
        var comparatorValue = trim(comparatorObject.value);

        var valueId = "tiled_fval" + columnIndex;
        var valueObject = getObj(valueId);
        var specifiedValue = trim(valueObject.value);
        //alert(specifiedValue);
        if (specifiedValue == '' && comparatorValue != "" && comparatorValue != 'isnull' && comparatorValue != 'isnotnull') {//32089: 单据序时簿界面：高级查找弹出层中，选择字段和条件后，不输入关键字立即查找，结果没有提示请输入查找关键字
            // @edit:dong @date:2020/08/21 @reason: 除去条件判断
            // var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
            // RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
            // return false;
        }

        var extValueId = "tiled_fval_ext" + columnIndex;
        var extValueObject = getObj(extValueId);
        if (extValueObject) {
            extendedValue = trim(extValueObject.value);
            if (extendedValue == '' && comparatorValue != 'isnull' && comparatorValue != 'isnotnull') {//32089: 单据序时簿界面：高级查找弹出层中，选择字段和条件后，不输入关键字立即查找，结果没有提示请输入查找关键字
                // @edit:dong @date:2020/08/21 @reason: 除去条件判断
                // var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
                // RemindsMsg("", "LdPopWidth400px", "", "yes", "", confirm_str);
                // return false;
            }
        }

        var glueConditionId = "tiled_fcon" + columnIndex;
        var glueConditionObject = getObj(glueConditionId);
        var glueCondition = '';
        if (glueConditionObject) {
            glueCondition = trim(glueConditionObject.value);
        }

        // If only the default row for the condition exists without user selecting any advanced criteria, then skip the validation and return.
        if (conditionColumns.length == 1 && selectedColumn == '' && comparatorValue == '' && specifiedValue == '')
            return true;

        // @edit:dong @date:2020/08/21 @reason: 除去条件判断
        // //if (!emptyCheck(columnId," Column ","text"))
        // if (!emptyCheck(columnId, " " + arrJsPopLabel['CONDITION'] + ' ', "text"))
        //     return false;
        // //if (!emptyCheck(comparatorId,selectedColumnLabel+" Option","text"))
        // if (!emptyCheck(comparatorId, selectedColumnLabel + ' ' + arrJsPopLabel['OPTIONS'] + ' ', "text"))
        //     return false;

        var col = selectedColumn.split(":");

        if (escapedOptions.indexOf(col[3]) == -1) {
            if (col[4] == 'T' || col[4] == 'DT') {
                var datime = specifiedValue.split(" ");
                if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length - 1) != "$") {
                    if (datime.length > 1) {
                        if (!re_dateValidate(datime[0], selectedColumnLabel, "OTH")) {
                            return false
                        }
                        if (!re_patternValidate(datime[1], selectedColumnLabel, "TIMESECONDS")) {
                            return false
                        }
                    } else if (col[0] == 'ld_activity' && col[2] == 'date_start') {
                        if (ld('#' + comparatorId).val() != 'isnull' && ld('#' + comparatorId).val() != 'isnotnull') {
                            if (!dateValidate(valueId, selectedColumnLabel, "OTH"))
                                return false;
                        }
                    } else if (col[0] == 'ld_activity' && col[2] == 'due_date') {
                        if (ld('#' + comparatorId).val() != 'isnull' && ld('#' + comparatorId).val() != 'isnotnull') {

                            if (!dateValidate(valueId, selectedColumnLabel, "OTH"))
                                return false;
                        }
                    } else if (ld('#' + comparatorId).val() != 'isnull' && ld('#' + comparatorId).val() != 'isnotnull') {

                        if (!re_patternValidate(datime[0], selectedColumnLabel, "TIMESECONDS")) {
                            return false
                        }
                    }
                }

                if (extValueObject) {
                    var datime = extendedValue.split(" ");
                    if (extendedValue.charAt(0) != "$" && extendedValue.charAt(extendedValue.length - 1) != "$") {
                        if (datime.length > 1) {
                            if (!re_dateValidate(datime[0], selectedColumnLabel, "OTH")) {
                                return false
                            }
                            if (!re_patternValidate(datime[1], selectedColumnLabel, "TIMESECONDS")) {
                                return false
                            }
                        } else if (col[0] == 'ld_activity' && col[2] == 'date_start') {
                            if (!dateValidate(extValueId, selectedColumnLabel, "OTH"))
                                return false
                        } else if (col[0] == 'ld_activity' && col[2] == 'due_date') {
                            if (!dateValidate(extValueId, selectedColumnLabel, "OTH"))
                                return false
                        } else {
                            if (comparatorValue != 'isnull' && !re_patternValidate(datime[0], selectedColumnLabel, "TIMESECONDS")) {
                                return false
                            }
                        }
                    }
                }
            } else if (col[4] == 'D') {
                if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length - 1) != "$" && ld('#' + comparatorId).val() != 'isnull' && ld('#' + comparatorId).val() != 'isnotnull') {
                    if (!dateValidate(valueId, selectedColumnLabel, "OTH"))
                        return false
                }
                if (extValueObject) {
                    if (!dateValidate(extValueId, selectedColumnLabel, "OTH"))
                        return false
                }
            } else if (col[4] == 'I') {
                if (!intValidate(valueId, selectedColumnLabel + i))
                    return false
            } else if (col[4] == 'N') {
                if (!numValidate(valueId, selectedColumnLabel, "any", true))
                    return false
            }
            /*else if(col[4] == 'E')
            {
                if (!patternValidate(valueId,selectedColumnLabel+" (Email Id)","EMAIL"))
                    return false
            }*/
        }

        //Added to handle yes or no for checkbox fields in reports advance filters.
        if (col[4] == "C") {
            if (specifiedValue == "1")
                specifiedValue = getObj(valueId).value = 'yes';
            else if (specifiedValue == "0")
                specifiedValue = getObj(valueId).value = 'no';
        }
        if (extValueObject && extendedValue != null && extendedValue != '') specifiedValue = specifiedValue + ',' + extendedValue;

        criteriaConditions[columnIndex] = {
            "groupid": columnGroupId,
            "columnname": selectedColumn,
            "comparator": comparatorValue,
            "value": specifiedValue,
            "columncondition": glueCondition
        };
        // @edit:dong @date:2020/08/21 @reason: 过滤搜索条件
        if((comparatorValue !='' && specifiedValue!='') || comparatorValue == 'isnull' || comparatorValue =='isnotnull' || comparatorValue =='curuser')
        criteriaConditionsSearch[columnIndex] = {
            "groupid": columnGroupId,
            "columnname": selectedColumn,
            "comparator": comparatorValue,
            "value": specifiedValue,
            "columncondition": glueCondition
        };

    }

    criteriaConditionsSearch = criteriaConditionsSearch.filter(function (val,key) {
        if(val != undefined){
            return val;
        }
    })
    if(criteriaConditionsSearch.length != 0)
    criteriaConditionsSearch[criteriaConditionsSearch.length-1].columncondition='';

    document.getElementById('tiledsearch_criteria').value = JSON.stringify(criteriaConditionsSearch);
    setLocalStorage(tiled_column_key, criteriaConditions);

    //$('advft_criteria').value = JSON.stringify(criteriaConditions);

    var conditionGroups = vt_getElementsByName('div', "tiled_conditionGroup");
    var criteriaGroups = [];
    for (var i = 0; i < conditionGroups.length; i++) {
        var groupTableId = conditionGroups[i].getAttribute("id");
        var groupTableInfo = groupTableId.split("_");

        var groupIndex = groupTableInfo[2];

        var groupConditionId = "tiled_gpcon" + groupIndex;
        var groupConditionObject = getObj(groupConditionId);
        var groupCondition = '';
        if (groupConditionObject) {
            groupCondition = trim(groupConditionObject.value);
        }
        criteriaGroups[groupIndex] = {"groupcondition": groupCondition};

    }
    document.getElementById('tiledsearch_criteria_groups').value = JSON.stringify(criteriaGroups);
    setLocalStorage(tiled_group_key, criteriaGroups);
    //$('advft_criteria_groups').value = JSON.stringify(criteriaGroups);
    return true;
}

/**
 * IE has a bug where document.getElementsByName doesnt include result of dynamically created
 * elements
 */
function vt_getElementsByName(tagName, elementName) {
    var inputs = document.getElementsByTagName(tagName);
    var selectedElements = [];
    for (var i = 0; i < inputs.length; i++) {
        if (inputs.item(i).getAttribute('name') == elementName) {
            selectedElements.push(inputs.item(i));
        }
    }
    return selectedElements;
}

function tiled_addSubmitButton(parentNodeId,module,is_admin) {
    //ZXM 2021-1015【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
    var html = '<div class="E_pbtn" style="border-top:none;padding: 16px 0 15px;">';
    html +=' <div style="margin: 0;">\n' + '<span style="vertical-align: middle;">'+arrJsPopLabel['AUTOHIDEAFTERFINDING']+'</span>\n' ;
    if(autohideafterfinding == 'yes'){
        html += '<input id="Autohideafterfinding" data-module="'+ module +'" type="checkbox" onclick="setAutohideAfterfinding(this)" class="second_switch" checked="">\n';
    }else{
        html += '<input id="Autohideafterfinding" data-module="' + module + '" type="checkbox" onclick="setAutohideAfterfinding(this)" class="second_switch">\n';
    }
    html +='</div>';

    if(module=="ChinaMap"){
        if(is_admin=="on"){
            html += '<input name="button" onclick="saveMapSearch();" class="ld-button ld-button-primary" value="'+arrJsPopLabel['PreservationConditions']+'" type="button">';
        }
        html += '<input name="button" onclick="callMapSearch(\'yes\');" class="ld-button" value="'+arrJsPopLabel['FINDNOW']+'" type="button"><input class="ld-button ld-button-cancel" value="'+arrJsPopLabel['CANCEL']+'" type="button" onclick="callMapSearch(\'no\');"></div>';
    }else{
        html += '<input name="button" onclick="callSearch(\'Tiled\');" class="ld-button" value="'+arrJsPopLabel['FINDNOW']+'" type="button"><input class="ld-button ld-button-cancel" value="'+arrJsPopLabel['CANCEL']+'" type="button" onclick="TiledSearchShow();"></div>';
    }
    ld('#' + parentNodeId).append(html);
}

function setAutohideAfterfinding(obj){
    var modulename = ld(obj).data("module");
    var label = ld(obj).attr('id');

    var urlstring = 'module=Users&action=UsersAjax&file=AutohideAfterfindingSetting&modulename='+modulename;
    urlstring += '&setype=tiledSearchdisplay'+'&'+label+'=';
    if(ld(obj).prop('checked')){
        urlstring += 'yes';
    }else{
        urlstring += 'no';
    }

    new Ajax.Request(
        'index.php',
        {queue: {position: 'end', scope: 'command'},
            method: 'post',
            postBody: urlstring,
            onComplete: function(response) {

            }
        });
}

//保存搜索条件到本地存储
function setLocalStorage(key, value) {

    if (key == tiled_column_key) {
        // 过滤一下去掉empty
        value = value.filter(function (s) {
            if (s != undefined) {
                return s;
            }
        });
    }
    var oldValue = JSON.parse(localStorage.getItem(key));
    if (oldValue == null) {
        oldValue = {}
    }
    oldValue[MODULE] = value;
    localStorage.setItem(key, JSON.stringify(oldValue));
}

//根据类型改变列表显示的高度
function chang_content_table_divid_height(type, groupIndex) {
    var height = ld('#resize_content_table_divid').height();
    var tmpheight;
    switch (type) {
        case 'show':
            tmpheight = -ld('#tiledSearch').height();
            break;
        case 'hidden':
            tmpheight = ld('#tiledSearch').height();
            break;
        case 'addRow':
             if (ld('#tiled_conditiongroup_' + groupIndex )!=undefined&&ld('#tiled_conditiongroup_' + groupIndex ).length>0){
                var tiled_group_divobj = ld('#tiled_conditiongroup_' + groupIndex );
                var max_height_str = ld(tiled_group_divobj).css('max-height');
                if(ld(tiled_group_divobj).css('height')!=max_height_str){
                    tmpheight = -ld("tr[id^=tiled_conditioncolumn").height();
                }
                else{
                    tmpheight = 0;
                }
                //zkt 20220830 BUG0055777平铺查找，新增一个新条件之后，文字就被遮挡，希望能够自动将右边的滑动条滑到最底部（BUG0054711、BUG0055777、BUG0055064）
                ld(tiled_group_divobj).scrollTop(ld(tiled_group_divobj).get(0).scrollHeight);
            }
            break;
        case 'delRow':
            if (ld('#tiled_conditiongrouptable_' + groupIndex + ' tr[name=tiled_conditionColumn]').length == 4) {
                break;//当五个条件删除一条时 会显示增加按钮高度不变
            }
            tmpheight = ld("tr[id^=tiled_conditioncolumn").height();
            break;
        default:
            break;
    }
    var popupobj = CrmPopup.getPopupObj("last");
    //popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type) ;
    // if(popupobj != undefined) {
    //     if (ld("#" + popupobj.divid + " [name=listtag_div]").length > 0) {
    //         if (ld("#" + popupobj.divid + " [name=listtag_div]").css('display') != 'none') {
    //             height += ld("#" + popupobj.divid + " [name=listtag_div]").get(0).offsetHeight;
    //         }
    //     }
    // }
    // ld('#resize_content_table_divid').height(height + tmpheight);
    // hzx BUG0078167 平铺查找-点击添加条件，条件越多，下方列表高度越小
    setContentHeight(popupobj.module);

}
// 获取本地存储的条件并过滤
function  getlocalStorageConditions(module) {
    var criteriaConditions = JSON.parse(localStorage.getItem(tiled_column_key));
    if (criteriaConditions != null){
        criteriaConditions = criteriaConditions[module];
        criteriaConditions = criteriaConditions.filter(function (val,key) {
            if(val.value !='' || val.comparator =='isnull' || val.comparator =='isnotnull'|| val.comparator =='curuser'){
                return val;
            }
        })
        if(criteriaConditions.length != 0)
            criteriaConditions[criteriaConditions.length-1].columncondition='';
        criteriaConditions = JSON.stringify(criteriaConditions);
    }
    return criteriaConditions;
}

// 获取本地的条件组
function  getlocalStorageGroups(module) {
    var criteriaGroups = JSON.parse(localStorage.getItem(tiled_group_key));
    if (criteriaGroups != null) criteriaGroups = JSON.stringify(criteriaGroups[module]);
    return criteriaGroups;
}