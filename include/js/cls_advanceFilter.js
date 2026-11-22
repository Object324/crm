function cls_advanceFilter (){
    this.advft_column_index_count = -1;
    this.advft_group_index_count = 0;
    this.column_index_array = {};
    this.group_index_array = [];
    this.module = '';//模块
    this.popupobj = '';//高级查找弹窗
    this.prevpopupobj = '';//调用高级查找的弹窗
    this.divid = 'pop_adv_filter_div';//高级查找部分的divid
    this.divobj = '';//对应上面的divid
    this.source = 'CustomView';
    this.hideGroupDeleteBtn = 'no';
    this.isReportModule = false;//是否是报表模块 不带属于和不属于
    this.showSearchHistory = 'yes';//默认显示
    this.advft_criteria_groups = '';
    this.advft_criteria = '';
    this.tmpObj_select = {};
    this.arrJsPopupLabel = {};
    this.proportion = 1; //宽度倍率
    this.fullscreen = 'no';
    this.unJudgedConditionArr = ['isnull','isnotnull','curuser','has_changed'];
    this.filterRowWidth_fcol = 190;
    this.filterRowWidth_fop = 120;
    this.filterRowWidth_fval = 280;
    this.defaultNoneColumns = 'yes';//新增行 默认字段是空还是第一个字段
    this.multiuser_uitype_arr = [ 154, 132, 603 ];
    this.user_uitype_arr = [ 52, 53, 100, 131, 165, 199, 132, 154, 153, 603 ];
    this.makePopupCenter = 'yes';

    this.criteria_groups_arr = '';//初始化的高级查找条件数据
    this.datetimestr = '';//选择条件 时间部分
    this.advfilterhtml = '';//选择条件的html
    this.fLabels = {};//选择条件的翻译数据
    this.columnOptionHtml = '';//选择字段下拉框html
    this.fieldsinfo = '';//字段信息
    this.mandatorycheck = '';

    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    this.equalArr = ['e', 'n'];
    this.newBelongArr = ['new_belong', 'new_notbelong'];
    this.userBigTypeArr = ['users', 'selectoneuser', 'selectmultiuser'];
    this.pickBigTypeArr = ['picklist', 'picklist_key', 'multipicklist', 'multipicklist_key'];
    this.multiSettingsInfo = {
        closeOnSelect: false,
    };
    /** 字段对象数组 */
    this.advanceFields = [];

    //高级查找平铺
    this.showTile = 'no';//是否显示高级查找平铺
    this.tiledGroupIndex = -1;//平铺按钮所在groupindex
    this.tiledColumnArr = {};//存平铺字段
    this.showSelectStyle = 'yes';//多选下拉字段是否显示下拉样式
    this.fvalSpecialType = ['select','select2','user']

    var that = this;

    //变量赋值
    this.setParams = function (paramobj){
        //赋值变量
        ld.each(paramobj,function (key,value) {
            if (that.hasOwnProperty(key) && typeof that[key] !== 'function' && !empty(value)) {
                if (key == 'columnOptionHtml'){
                    value = value.replace(/\\'/g, "'")
                }
                that[key] = value;
            }
        });
    }

    //设置调用高级查找功能的弹窗
    this.setPrevPopupobj = function (prevpopupobj){
        that.prevpopupobj = prevpopupobj;
    }

    //设置高级查找所在的弹窗
    this.setPopupobj = function (popupobj){
        if (popupobj != undefined){
            that.popupobj = popupobj;
            popupobj.advanceFilterObj = that;
        }
    }

    //设置界面来源
    this.setSource = function (source){
        that.source = source;
    }

    //设置高级查找的divid
    this.setDivid = function (divid){
        that.divid = divid;
    }

    //设置显示界面 高级查找条件
    this.setFilterValue = function (advft_criteria,advft_criteria_groups){
        advft_criteria = empty(advft_criteria)?'':advft_criteria;
        advft_criteria_groups = empty(advft_criteria_groups)?'':advft_criteria_groups;
        that.advft_criteria = advft_criteria;
        that.advft_criteria_groups = advft_criteria_groups;
    }

    //设置显示界面 高级查找条件
    this.setCriteriaGroups = function (criteria_groups_arr){
        if (!empty(criteria_groups_arr)){
            that.criteria_groups_arr = criteria_groups_arr;
        }else {
            that.criteria_groups_arr = '';
        }
    }

    //设置 隐藏组合条件删除按钮
    this.setHideGroupDeleteBtn = function (hideGroupDeleteBtn){
        that.hideGroupDeleteBtn = hideGroupDeleteBtn;
    }

    //设置选择字段下拉框option的html
    this.setColumnOptionHtml = function (columnOptionHtml){
        that.columnOptionHtml = columnOptionHtml.replace(/\\'/g, '"');
    }

    //是否显示平铺按钮
    this.setShowTile = function (showTile) {
        that.showTile = showTile;
    }

    //获取高级查找条件
    this.getFilterValue = function (){
        return {'advft_criteria':that.advft_criteria,'advft_criteria_groups':that.advft_criteria_groups};
    }

    //显示高级查找弹窗界面
    //showhistory是否显示历史记录部分
    //callback ok事件(立即查询事件)
    this.showAdvanceFilterPopup = function (showSearchHistory='yes',okbtn_callback){
        that.showSearchHistory = showSearchHistory;
        that.defaultNoneColumns = 'no';
        var module = that.prevpopupobj.module;
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=getAdvanceSearchPopup&showSearchHistory='+showSearchHistory;
        var params = '';
        if (that.criteria_groups_arr == ''){
            params = {'advft_criteria':that.advft_criteria,'advft_criteria_groups':that.advft_criteria_groups}
        }
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        if(that.prevpopupobj.frommodule && that.prevpopupobj.frommodule === "Approve") {
            params.fromModule = that.prevpopupobj.frommodule;
        }
        var popupobj = CrmPopup.load("", "", "", "LdPopWidth800px", module, "", "", "", "");
        popupobj.prevshow();
        ldAjax(url,params,function(data){
            if(data.code == 1){
                popupobj.setParams(data.result.title,'','',"LdPopWidth800px",module,['Advanced'],data.result.oktext,'',data.result.canceltext);
                popupobj.setInnerHtml=function(){
                    if(popupobj.scrolldiv!="") {
                        ld("#"+popupobj.divid).html(popupobj.popupheadhtml+popupobj.scrolldiv+popupobj.htmlcontent+"</div>"+popupobj.popupbottomhtml);
                    }
                    else {
                        ld("#"+popupobj.divid).html(popupobj.popupheadhtml+popupobj.htmlcontent+popupobj.popupbottomhtml);
                    }
                    ld('#'+popupobj.divid).css('display','block');
                }
                popupobj.show(data.result.content);
                that.setPopupobj(popupobj);
                //绑定保存事件
                ld('#'+popupobj.divid+'_btnok').off('click').on('click',function (){
                    var filterData = false;
                    if (that.showTile === 'yes' && that.prevpopupobj.AdvanceFilterTiledObj){
                        filterData = that.getTiledFilter();
                    }
                    okbtn_callback();
                    if(filterData){
                        that.prevpopupobj.AdvanceFilterTiledObj.refresh(filterData);
                    }
                });
                //保存为查询分类
                var addBtnHtml = ''
                //清除所有筛选值按钮
                addBtnHtml += '<input name="button" id="clearAllFilterValue" class="ld-button" value="'+data.result.clearAllText+'" type="button" class="ld-button">';
                if (data.result.customview_permit == 'yes' && that.module != 'Approve' && (that.prevpopupobj.type == 'listpage' || that.prevpopupobj.type == 'calendarview')){
                    if(typeof linkmodulecustom!="undefined"&&linkmodulecustom != undefined && linkmodulecustom == true){

                    }else {
                        addBtnHtml += data.result.customview_btn;
                    }
                }
                ld('#'+popupobj.divid+'_btnok').after(addBtnHtml);
                ld('#'+popupobj.divid).find('#clearAllFilterValue').off('click').on('click',function () {
                    that.clearAllFilterValue();
                })

                popupobj.searchtype='advance';
                popupobj.advanceFilter='yes';
                that.setParams(data.result);
                //高级查找平铺字段
                that.getAdvanceFilter();
                that.init();
                //显示历史搜索记录
                if (that.showSearchHistory == 'yes'){
                    popupobj.searchmode = 'showhistory';
                    popupobj.advancefiltersearch = 'yes';// 2024-09-13 xxy 增加这个参数, 代表是走advanceFilterSearch类中方法, SearchHistory.tpl会根据该参数判断也调用类中的新方法, 可支持公共调用
                    that.showHistory(popupobj);
                }
                //设置弹窗最大高度
                var maxheight = popupobj.getPopContentHeight();
                ld('#'+popupobj.divid).find('#'+that.divid).css('max-height',maxheight);
                if (parseInt(maxheight) > 400){//为了展开历史条件后显示全部
                    ld('#'+popupobj.divid).find('#'+that.divid).css('min-height',400);
                }
                ld('#'+popupobj.divid).find('#'+that.divid).css('overflow','auto');
                popupobj.center();
            }
            else{

            }
            DelProgressObjs();
        });
    }

    //显示高级查找部分
    this.showAdvanceFilter = function (popupobj,params){
        that.setPopupobj(popupobj);
        that.setParams(params);
        that.showSearchHistory = 'no';
        that.showTile = 'no';
        popupobj.searchtype='advance';
        popupobj.advanceFilter='yes';
        if (that.fullscreen == 'no'){
            //设置弹窗最大高度
            var maxheight = popupobj.getPopContentHeight();
            var popupobj_scroll_divobj =  ld('#'+popupobj.divid+'_scroll');
            if (popupobj_scroll_divobj.length > 0 ){
                popupobj_scroll_divobj.css('max-height',maxheight);
                popupobj_scroll_divobj.css('overflow','auto');
            }else {
                ld('#'+popupobj.divid).find('#'+that.divid).css('max-height',popupobj.getPopContentHeight());
                ld('#'+popupobj.divid).find('#'+that.divid).css('overflow','auto');
            }
        }
        that.init();
        if (that.makePopupCenter == 'yes'){
            popupobj.center();
        }
    }


    //初次进入高级查找界面,加载条件部分
    this.init = function (){
        if (that.popupobj == undefined || empty(that.popupobj)){
            that.divobj = ld('#'+that.divid);
        }else {
            that.divobj = ld('#'+that.popupobj.divid+' #'+that.divid);
            if (that.divobj.length == 0){
                that.divobj = ld('#'+that.popupobj.divid+' [name='+that.divid+']');
            }
        }
        var criteria_groups_arr = that.criteria_groups_arr;
        if (empty(criteria_groups_arr)){//添加默认组合条件
            that.addNewConditionGroup();
        }
        else {
            that.showAdvanceCondition(criteria_groups_arr);
        }

        that.setCommonEvents();

    }

    //
    this.getAdvanceFilter = function (){
        if(that.showTile === 'yes') {
            //XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
            var listPopupObj = that.prevpopupobj;
            that.tiledGroupIndex = 1;
            that.filterRowWidth_fcol = 170;
            that.filterRowWidth_fval = 250;
            if (listPopupObj && listPopupObj.AdvanceFilterTiledObj) {
                var advanTiledObj = listPopupObj.AdvanceFilterTiledObj;
                that.advanceTiledObj = advanTiledObj;
                if (advanTiledObj.divobj.find('[tag=conditionColumn]').length > 0){
                    advanTiledObj.checkAdvancedFilter();
                    var searchtype = listPopupObj.searchtype;
                    if (empty(searchtype) && empty(that.criteria_groups_arr)){
                        that.setFilterValue(advanTiledObj.advft_criteria, advanTiledObj.advft_criteria_groups);
                        that.criteria_groups_arr = advanTiledObj.criteria_groups_arr;
                    }else if (searchtype === 'AdvanceTiled'){//列表前一次查询是平铺查询
                        var columns = advanTiledObj.criteria_groups_arr[1].columns;
                        if (!that.criteria_groups_arr){
                            that.setFilterValue(advanTiledObj.advft_criteria, advanTiledObj.advft_criteria_groups);
                            that.criteria_groups_arr = advanTiledObj.criteria_groups_arr;
                        }else {
                            ld.each(that.criteria_groups_arr,function (tmp_index,tmp_columnsInfo){
                                ld.each(tmp_columnsInfo.columns,function (tmp_key,tmp_columninfo){
                                    var tmp_columnname = tmp_columninfo.columnname;
                                    var tmp_showAsTiled = tmp_columninfo.showAsTiled;
                                    if (tmp_showAsTiled == 'yes' && advanTiledObj.tiledColumnArr.hasOwnProperty(tmp_columnname)){
                                        var tmp_columnindex = advanTiledObj.tiledColumnArr[tmp_columnname];
                                        tmp_columnsInfo.columns[tmp_key].comparator = columns[tmp_columnindex].comparator;
                                        tmp_columnsInfo.columns[tmp_key].value = columns[tmp_columnindex].value;
                                        if (columns[tmp_columnindex].hasOwnProperty('valueLabel')){
                                            tmp_columnsInfo.columns[tmp_key].valueLabel = columns[tmp_columnindex].valueLabel;
                                        }
                                    }
                                });
                                that.criteria_groups_arr[tmp_index] = tmp_columnsInfo;
                                return false;

                            });
                        }
                    }else if (searchtype === 'Advanced'){//列表前一次查询是高级查询

                    }
                }
            }
        }
    }

    // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
    this.getFieldInfoByColValue = function (fieldColStr) {
        if(!fieldColStr || !(typeof fieldColStr === "string")) {
            return false
        }
        var colArr = fieldColStr.split(':'),
            columnName = colArr[1];
        return that.getFieldInfoByColumnName(columnName);
    }
    
    /** 根据字段名获取字段fieldInfo */
    this.getFieldInfoByColumnName = function (columnName) {
        if(!columnName) {
            return false;
        }
        if(!that.advanceFields || (that.advanceFields.length && that.advanceFields.length === 0)) {
            return false;
        }
        for (let fieldInfo of that.advanceFields) {
            if(fieldInfo && (fieldInfo.columnName === columnName)) {
                return fieldInfo
            }
        }
        return false;
    }

    /** @returns {DataHtmlBind} */
    this.getDataBindObj = function () {
        return this.dataBindObj || (this.dataBindObj = new DataHtmlBind());
    }

    //初始化 将条件数据转化为界面
    this.showAdvanceCondition = function (criteria_groups_arr){
        that.setCriteriaGroups(criteria_groups_arr);
        var fcon_i = 0;
        var gcon_i = 0;
        var dataBindObj = that.getDataBindObj();

        ld.each(criteria_groups_arr,function (group_id,group_criteria) {
            var group_columns = group_criteria.columns;
            //zkt 20230328 BUG0063212  客户档案的工商信息查询设置，点击设置例外规则，页面就卡死
            if(that.advft_group_index_count+1 != group_id){
                var tmp_index_count = that.advft_group_index_count;
                for(var i=0;i<(group_id-tmp_index_count-1);i++){
                    that.group_index_array.push(that.advft_group_index_count+1);
                    that.advft_group_index_count++;
                }
            }
            //添加一个组合条件
            that.addConditionGroup();

            ld.each(group_columns,function (columns_idex,columns_criteria) {

                columns_criteria.value = columns_criteria.value.toString();

                that.addConditionRow(group_id);

                //条件行
                var conditionRowObj = that.divobj.find('[name=fcol'+that.advft_column_index_count+']');

                //duan 20231113 修复高级查询中，如果字段名称修改，编辑时无法选中的问题
                var tmp_value = columns_criteria.columnname;
                var tmp_arr = tmp_value.split(':');
                var new_value = conditionRowObj.find('option[value*="'+tmp_arr[1]+':'+tmp_arr[2]+'"]').val();
                conditionRowObj.val(new_value);
                that.setColumnEvent();

                //首页数据看板 设置查询条件 中有此部分代码 但是后台并没有返回这个source 暂时保留
                if(that.source === 'PricePolicy_RoleModule') {
                    var tmpModule = tmp_arr[3].split('_').shift();
                    var moduleSelObj = ld('#'+that.popupobj).find('#module_'+that.advft_column_index_count);
                    moduleSelObj.val(tmpModule);
                    moduleSelObj.change();
                }

                //wym 230505 新增字段--点击“其他条件” 显示保存的筛选条件
                //var fcolDivObj = that.divobj.find(''+that.advft_column_index_count+']');
                var fcolDivObj = that.divobj.find(`[name=fcolDiv_${group_id}_${that.advft_column_index_count}`);
                var aobj =  fcolDivObj.find("a[class=chzn-single]");
                var fldname = aobj.attr("dropdownname");
                //zxm 20230810 cmb_span_optiontext_fldname的值应当为下拉框option的text
                var selectedoption_text = fcolDivObj.find('option[value="'+new_value+'"]').text();
                fcolDivObj.find(" [name='cmb_span_optiontext_"+fldname+"']").val(selectedoption_text);

                //更新选择条件
                that.updatefOptions(that.advft_column_index_count);
                var fopObj = that.divobj.find('[name=fop'+that.advft_column_index_count+']');
                if (columns_criteria.comparator == 'belong' || columns_criteria.comparator == 'notbelong'){
                    columns_criteria.comparator = 'new_' + columns_criteria.comparator;
                }
                if (columns_criteria.search_comparator == 'belong' || columns_criteria.search_comparator == 'notbelong'){
                    columns_criteria.search_comparator = 'new_' + columns_criteria.search_comparator;
                }
                var comparator = columns_criteria.comparator;
                var search_comparator = columns_criteria.search_comparator;
                if (search_comparator && comparator && search_comparator != comparator && comparator == 'bw'){//时间条件会更改为bw,但需要显示为原来的
                    columns_criteria.comparator = search_comparator;
                    fopObj.val(search_comparator);
                }else {
                    fopObj.val(comparator);
                }
                // 双向绑定
                dataBindObj.setDataBindByJqObj(fopObj, columns_criteria, 'comparator');
                that.setOptionEvent();

                if (that.source == 'reports' || that.source == 'usereports'){
                    // that.updateRelFieldOptions(conditionRowObj, 'fval'+that.advft_column_index_count);
                }
                var columnvalue = columns_criteria.value;
                var tmp_columnvalue = columnvalue.split(",");
                var valueLabel = columns_criteria.valueLabel ? columns_criteria.valueLabel : '';

                //更新关键字部分
                that.addRequiredElements(that.advft_column_index_count, { value: tmp_columnvalue});

                that.setRequiredElement(that.advft_column_index_count, {
                    comparator:comparator,
                    value: columnvalue,
                    valueArr: tmp_columnvalue,
                    valueLabel:valueLabel
                });
            })

            //设置每行的'且'、'或'条件
            ld.each(group_columns,function (columns_idex,columns_criteria){
                var column_condition = empty(columns_criteria.column_condition) ?  columns_criteria.columncondition : columns_criteria.column_condition ;
                var fconobj = that.divobj.find("#fcon"+fcon_i);
                if(fconobj){
                    fconobj.val(column_condition);
                }
                if(that.showTile === 'yes') {
                    // XUQIU1001599 单据序时簿列表界面，高级查找增加“平铺”和“清除筛选值”功能
                    var showAsTiled = columns_criteria.showAsTiled;
                    var columnname = columns_criteria.columnname;
                    if (showAsTiled === 'yes') {
                        that.tiledColumnArr[columnname] = fcon_i;
                        var showBtnObj = that.divobj.find('#showAsTiled_'+fcon_i);
                        showBtnObj.prop('checked', true);
                        that.disableColumnCondition(fcon_i);
                    }else {
                        if (that.tiledColumnArr.hasOwnProperty(columnname) && columns_idex == that.tiledGroupIndex){
                            that.divobj.find('#showAsTiledDiv_'+fcon_i).hide();
                        }
                    }
                }
                fcon_i++;
            });

        });

        //组合条件区块的筛选条件
        ld.each(criteria_groups_arr,function (group_id,group_criteria){
            gcon_i++;
            var gpconobj = that.divobj.find('[name=gpcon'+gcon_i+']');
            if(gpconobj) {
                var condition=ld.trim(group_criteria.condition);
                if(condition.indexOf("or")>=0) {
                    condition="or";
                }
                gpconobj.val(condition);
            }
        });
    }

    //绑定事件
    this.setCommonEvents = function (){
        //绑定添加组合条件
        that.divobj.find('[name=advanceFilterGroupAddBtn] [tag=addGroup]').off('click').on('click',function (){
            that.addNewConditionGroup();
        });
    }

    //新增组合条件
    this.addConditionGroup = function (){
        if (that.popupobj == undefined || empty(that.divobj)){
            return false;
        }

        //增加前一个组合条件的筛选条件
        for(var i=that.group_index_array.length - 1; i>=0; --i) {
            var prevGroupIndex = that.group_index_array[i];
            var name='conditiongroup_'+prevGroupIndex;
            var tmpobj=that.divobj.find("[name="+name+"]");
            if(tmpobj.length>0) {
                that.addGroupConditionGlue(prevGroupIndex);
                 break;
            }
        }

        // 添加一个组合条件
        var groupIndex = that.advft_group_index_count+1;
        if (that.showTile === 'yes' && that.tiledGroupIndex === -1){
            that.tiledGroupIndex = groupIndex;
        }
        var newNodeId = 'conditiongroup_'+groupIndex;
        var html = ' <div name="'+newNodeId+'" id="'+newNodeId+'" tag="conditionGroup" class="advanceFilterGroupDiv">';
        //组合条件删除按钮
        if (that.hideGroupDeleteBtn == 'no'){
            html += '<div class="advanceFilterGroupDeleteBtn"><i class="ld-fonticon ld-fonticon-reduce" tag="groupDelete"  name="groupDelete_'+groupIndex+'" id="groupDelete_'+groupIndex+'" groupindex="'+groupIndex+'"></i></div>';
        }
        //条件行
        html += '<div class="advanceFilterGroupInfoDiv" name="advanceFilterGroupInfoDiv">';
        //增加条件按钮行
        html += '<div class="conditionColunm" tag="addRowColumn" ><div class="line"></div><div class="padL8"><i name="addRow_'+groupIndex+'" id="addRow_'+groupIndex+'" groupindex="'+groupIndex+'" class="ld-fonticon ld-fonticon-add"></i></div></div>';

        html += '</div>';
        html += '</div>';

        html += '<div tag="conditionGroup" name="groupconditionglueDiv" groupindex="'+groupIndex+'" id="groupconditionglue_'+groupIndex+'" class="advanceFilterGroupGlueDiv">';
        html += '</div>';


        if (that.source == 'AutomaticReminds'){
            that.divobj.append(html);
        }else {
            var advanceFilterGroupAddBtnobj = that.divobj.find('[name=advanceFilterGroupAddBtn]');
            if (advanceFilterGroupAddBtnobj.length == 0){
                var advanceFilterGroupAddBtn_html = ' <div name="advanceFilterDashedDiv" class="advanceFilterDashedDiv">';
                advanceFilterGroupAddBtn_html += '<div name="advanceFilterGroupAddBtn" class="advanceFilterGroupAddBtn">';
                advanceFilterGroupAddBtn_html += '<i tag="addGroup" class="ld-fonticon ld-fonticon-add"></i>';
                advanceFilterGroupAddBtn_html += '<span tag="addGroup" style="padding-left: 4px;padding-bottom: 2px;">'+arrJsPopLabel['NEWCOMBINATION']+'</span>';
                advanceFilterGroupAddBtn_html += '</div></div>';
                that.divobj.append(advanceFilterGroupAddBtn_html);
            }
            that.divobj.find('[name=advanceFilterGroupAddBtn]').before(html);
        }

        that.group_index_array.push(groupIndex);
        that.advft_group_index_count++;

        //事件绑定和处理
        if (that.hideGroupDeleteBtn == 'yes'){
            that.divobj.find('#groupDelete_'+groupIndex).css('display','none');
        }
        //删除组合条件按钮
        that.divobj.find('#groupDelete_'+groupIndex).off('click').on('click',function () {
            that.deleteGroup(groupIndex);
        });
        that.divobj.find('#addRow_'+groupIndex).off('click').on('click',function () {
            that.addConditionRow(groupIndex);
            that.setColumnEvent();
        });
        // that.divobj.scrollTop(that.divobj.find('#'+newNodeId).offset().top+40);
        if (that.popupobj && that.makePopupCenter === 'yes'){
            that.popupobj.center();
        }

    }

    //新增组合条件的筛选条件
    this.addGroupConditionGlue = function (groupIndex){
        var groupConditionGlueDivObj = that.divobj.find("#groupconditionglue_"+groupIndex);
        if(groupConditionGlueDivObj.length>0 ) {
            var html = '<select name="gpcon'+groupIndex+'" id="gpcon'+groupIndex+'"  tag="conditionGroupGlue" groupindex="'+groupIndex+'" class="ld-select-inner overflow-space" style="width: 54px">';
            html += '<option value="and">'+arrJsPopLabel['SEARCHAND']+'</option>';
            html += '<option value="or">'+arrJsPopLabel['OR']+'</option>';
            html += '</select>';
            groupConditionGlueDivObj.html(html);
        }
    }

    //新增条件行
    this.addConditionRow = function (groupIndex){
        if (that.popupobj == undefined || empty(that.divobj)){
            return false;
        }
        var groupColumns = that.column_index_array[groupIndex];
        //增加前一个条件行的筛选条件
        if(typeof(groupColumns) != 'undefined') {
            for(var i=groupColumns.length - 1; i >= 0; --i) {
                var prevColumnIndex = groupColumns[i];
                var tmpobj=that.divobj.find("[name=columnconditionglue_"+prevColumnIndex+"]");
                if(tmpobj != undefined && tmpobj.length > 0) {
                    that.addColumnConditionGlue(prevColumnIndex);
                    break;
                }
            }
        }

        //增加一行条件
        var columnIndex = that.advft_column_index_count+1;
        var addRowBtnobj = that.divobj.find('[name=conditiongroup_'+groupIndex+']').find('[tag=addRowColumn]');
        var group_column_index = groupIndex+'_'+columnIndex;
        var name = 'conditioncolumn_'+group_column_index;
        var html = '<div class="conditionColunm" id="'+name+'" name="'+name+'" groupindex="'+groupIndex+'" columnIndex="'+columnIndex+'" tag="conditionColumn">';
        //线
        html += '<div class="line"></div>';
        //选择字段
        html += '<div class="ld-form-item-content fcolDiv" name="fcolDiv_'+group_column_index+'" style="width: '+(that.filterRowWidth_fcol*that.proportion+8)+'px;">';
        if (that.source == 'report' || that.source == 'usereports'){
            html += '';
        }else {
            html += '<select class="ld-select-inner overflow-space" name="fcol'+columnIndex+'" id="fcol'+columnIndex+'" tag="fcol" style="width: '+that.filterRowWidth_fcol*that.proportion+'px;">';
            html += '<option value="">'+arrJsPopLabel['NONE']+'</option>';
            html += that.columnOptionHtml;
            html += '</select>';
        }
        html += '</div>';

        //选择条件
        html += '<div class="ld-form-item-content" style="width: '+(that.filterRowWidth_fop*that.proportion+8)+'px;padding: 0 0 0 8px" name="fopDiv_'+group_column_index+'">';
        html += '<select class="ld-select-inner overflow-space" name="fop'+columnIndex+'" id="fop'+columnIndex+'" style="width: '+(that.filterRowWidth_fop*that.proportion)+'px;">';
        html += '<option value="">'+arrJsPopLabel['NONE']+'</option>';
        html += that.advfilterhtml;
        html += '</select>';
        html += '</div>';

        //关键字输入部分

        html += '<div class="ld-form-item-content" style="width: '+(that.filterRowWidth_fval*that.proportion+16)+'px;padding: 0 0 0 8px" name="fvalDiv_'+group_column_index+'" id="fvalDiv_'+group_column_index+'">';
        if (that.source == 'report'){

        }else if (that.source == 'usereports'){

        }else {
            html += '<input class="ld-input-inner overflow-space" style="width: 100%;" name="fval'+columnIndex+'" id="fval'+columnIndex+'" groupindex="'+groupIndex+'">';
        }
        html += '</div>';
        html += '<div name="fvalClearBtnDiv_'+columnIndex+'" id="fvalClearBtnDiv_'+columnIndex+'" style="width: 25px">';
        html += '<i class="icon-homeimg icon-clear inpb-advSearchreset marL5" name="fvalClearBtn_'+columnIndex+'" id="fvalClearBtn_'+columnIndex+'" tag="fvalClearBtn" cursor="pointer" style="display: none"></i>';
        html += '</div>';

        //筛选条件
        html += ' <div class="padL8" style="width: 58px;min-width: 58px" id="columnconditionglue_'+columnIndex+'" name="columnconditionglue_'+columnIndex+'">';
        html += '</div>';

        //删除条件
        html += '<div class="padL16 padR16">';
        html += '<i class="ld-fonticon ld-fonticon-reduce" id="deleteRow_'+columnIndex+'" name="deleteRow_'+columnIndex+'" tag="deleteRow" columnIndex="'+columnIndex+'"></i>';
        html += '</div>';

        //平铺按钮
        if (that.showTile === 'yes'){
            html += '<div style="width: 60px;min-width: 60px;" tag="showAsTiledDiv">';
            if (parseInt(groupIndex) == that.tiledGroupIndex){
                html += '<div id="showAsTiledDiv_'+columnIndex+'" class="ld-flex-start">';
                html += '<input type="checkbox" id="showAsTiled_'+columnIndex+'" name="showAsTiled_'+columnIndex+'" tag="showAsTiled" columnindex="'+columnIndex+'">';
                html += '<label style="padding-left: 5px;" >'+arrJsPopLabel['Tile']+'</label>';
                html += '</div>';
            }
            html += '</div>';
        }

        html += '</div>'
        addRowBtnobj.before(html);

        if (typeof(that.column_index_array[groupIndex]) == 'undefined'){
            that.column_index_array[groupIndex] = [];
        }
        that.column_index_array[groupIndex].push(columnIndex);
        that.advft_column_index_count++;

        //自动提醒 有多于两行条件时，显示第一行的删除按钮
        if (that.source == 'AutomaticReminds'){
            if (that.column_index_array[groupIndex] != undefined){
                var first_columnindex = that.column_index_array[groupIndex][0];
                if (that.column_index_array[groupIndex].length == 1){
                    that.divobj.find('#deleteRow_'+first_columnindex).css('visibility','hidden');
                }else if (that.column_index_array[groupIndex].length == 2){
                    that.divobj.find('#deleteRow_'+first_columnindex).css('visibility','visible');
                }
            }
        }

        //事件处理和绑定
        //选择字段
        var columSelectObj = that.divobj.find('#fcol'+columnIndex);
        columSelectObj.get(0).options[1].selected = true;//默认字段
        var columSelectValue = columSelectObj.val();
        if (columSelectValue.indexOf('tag:tag') > -1){//去除标签
            columSelectObj.find('optgroup').each(function (){
                var optionsObj = ld(this).find('option');
                if (optionsObj.length == 1 && optionsObj.val().indexOf('tag:tag') > -1 ){
                    ld(this).remove();
                    return false;
                }
            });
            var optgroupHtml = columSelectObj.find('optgroup').map(function() {
                return ld(this).prop('outerHTML');
            }).get().join('');
            that.columnOptionHtml = optgroupHtml;
        }
        if (that.defaultNoneColumns === 'no'){
            columSelectObj.get(0).options[1].selected = true;
        }else {
            columSelectObj.get(0).options[0].selected = true;
        }
        columSelectValue = columSelectObj.val();

        var optionSelectObj = that.divobj.find('#fop'+columnIndex);
        columSelectObj.off('change').on('change',function () {
            that.updatefOptions(columnIndex);
            that.addRequiredElements(columnIndex);
            that.setOptionEvent();
            that.changeShowTiledColumn(columnIndex);
        });
        // columSelectObj.trigger('change');
        that.updatefOptions(columnIndex);
        that.addRequiredElements(columnIndex);
        that.setOptionEvent();
        //选择条件
        optionSelectObj.off('change').on('change',function () {
            that.addRequiredElements(columnIndex);
            that.changeShowTiledColumn(columnIndex);
        });
        //删除按钮
        that.divobj.find('#deleteRow_'+columnIndex).off('click').on('click',function () {
            that.deleteColumnRow(groupIndex,columnIndex);
        });
        //清除按钮
        that.divobj.find('#fvalClearBtn_'+columnIndex).off('click').on('click',function () {
            that.clearFvalInput(columnIndex);
        });

        if (that.showTile == 'yes'){
            //平铺checkbox
            var showAsTiledCheckBoxobj = that.divobj.find('#showAsTiled_'+columnIndex);
            if (showAsTiledCheckBoxobj.length > 0){
                showAsTiledCheckBoxobj.off('click').on('click',function (){
                    that.changeShowTiledColumn(columnIndex,'click');
                });
                //根据字段显示平铺
                if (that.tiledColumnArr.hasOwnProperty(columSelectValue)){
                    showAsTiledCheckBoxobj.prop('checked',false);
                    that.divobj.find('#showAsTiledDiv_'+columnIndex).hide();
                }
            }
        }

        if (columSelectObj.val() == ''){
            optionSelectObj[0].options[0].selected = true;
        }
        if (that.popupobj && that.makePopupCenter === 'yes'){
            that.popupobj.center();
        }

    }

    //设置选择字段的下拉框
    this.setColumnEvent = function (){
        var columnIndex = that.advft_column_index_count;
        var columSelectObj = that.divobj.find('#fcol'+columnIndex);
        if(that.divobj.find('#fcol'+columnIndex).length>0){
            if(empty(that.popupobj)){
                if (that.tmpObj_select){
                    that.tmpObj_select = new Object();
                    CrmPopup.global_listPopupObj.push(obj);
                    obj.divid=that.divid;
                    obj.CancelEvent=function(){
                        return false;
                    }
                }
                var obj = that.tmpObj_select;
            }else {
                var obj = that.popupobj;
            }
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml('fcol'+columnIndex);
            cls_resetComboxHtmlobj.setPopupObj(obj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(columSelectObj,190*that.proportion);
        }
    }

    //设置选择条件的下拉框
    this.setOptionEvent = function (){
        var columnIndex = that.advft_column_index_count;
        var groupIndex = that.divobj.find('[tag=conditionColumn][columnindex='+columnIndex+']').attr('groupindex');
        var columSelectObj = that.divobj.find('#fop'+columnIndex);
        if(that.divobj.find('#fop'+columnIndex).length>0){
            if(empty(that.popupobj)){
                if (that.tmpObj_select){
                    that.tmpObj_select = new Object();
                    CrmPopup.global_listPopupObj.push(obj);
                    obj.divid=that.divid;
                    obj.CancelEvent=function(){
                        return false;
                    }
                }
                var obj = that.tmpObj_select;
            }else {
                var obj = that.popupobj;
            }
            var fopDivObj = that.divobj.find('[name=fopDiv_'+groupIndex+'_'+columnIndex+']');
            var fopComboxObj = fopDivObj.find('[name=dv_cmb_fop'+columnIndex+']');
            if (fopComboxObj.length > 0){//移除上一次加载的可搜索下拉框部分的html
                fopComboxObj.remove();
            }
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml('fop'+columnIndex);
            cls_resetComboxHtmlobj.setPopupObj(obj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(columSelectObj,120*that.proportion);
        }
    }

    //添加条件行的筛选关系
    this.addColumnConditionGlue = function (columnIndex){
        var columnRowGlueObj = that.divobj.find('#columnconditionglue_'+columnIndex);
        if (columnRowGlueObj.length > 0){
            var html = '<select name="fcon'+columnIndex+'" id="fcon'+columnIndex+'" tag="fcon" class="ld-select-inner overflow-space fcon" style="width: 50px">';
            html += '<option value="and">'+arrJsPopLabel['SEARCHAND']+'</option>';
            html += '<option value="or">'+arrJsPopLabel['OR']+'</option>';
            html += '</select>';
            columnRowGlueObj.html(html);
            if(that.showTile === 'yes') {
                var fconObj = that.divobj.find('#fcon' + columnIndex);
                fconObj.unbind('change').bind('change', function () {
                    that.changeColumnCondition(columnIndex);
                });
                //已平铺
                if (that.divobj.find('#showAsTiled_'+columnIndex).length > 0 && that.divobj.find('#showAsTiled_'+columnIndex).prop('checked') === true){
                    that.disableColumnCondition(columnIndex);
                }
            }
        }
    }

    //添加组合条件(带一行条件)
    this.addNewConditionGroup = function (){
        that.addConditionGroup();
        that.addConditionRow(that.advft_group_index_count);
        that.setColumnEvent();
        that.setOptionEvent();
    }

    //删除组合条件
    this.deleteGroup = async function (groupIndex){
        if(that.showTile === 'yes') {
            await that.checkHaveTiledRow(groupIndex, '');
        }
        //组合条件部分
        var conditionGroupobj = that.divobj.find('#conditiongroup_'+groupIndex);
        if (conditionGroupobj.length > 0){
            conditionGroupobj.remove();
        }
        //组合条件的筛选条件
        var conditionGroupGlueobj = that.divobj.find('#groupconditionglue_'+groupIndex);
        if (conditionGroupGlueobj.length > 0){
            conditionGroupGlueobj.remove();
        }
        //最后一个需要删除前一个组合条件的筛选条件
        var groupindex_key = that.group_index_array.indexOf(groupIndex);
        var groupindex_length = that.group_index_array.length;
        if (groupindex_key == groupindex_length-1){
            var prevGroupIndex =  that.group_index_array[groupindex_key-1];
            var prevConditionGroupGlueobj = that.divobj.find('#gpcon'+prevGroupIndex);
            if (prevConditionGroupGlueobj.length > 0){
                prevConditionGroupGlueobj.remove();
            }
        }
        that.group_index_array.splice(groupindex_key,1);
        delete that.column_index_array[groupIndex];

        if (that.showTile === 'yes'){
            if (that.group_index_array && that.group_index_array.length > 0){
                that.tiledGroupIndex = that.group_index_array[0];
                that.refreshTiledBtn();
            }else {
                that.tiledGroupIndex = -1;
            }
        }


    }

    //删除条件行
    this.deleteColumnRow = async function (groupIndex,columnIndex){
        //条件行部分
        if (that.column_index_array[groupIndex].length == 1){//只剩下一行，删除相当于删除整个组合条件
            if (that.source == 'AutomaticReminds'){//自动提醒 新建/编辑界面
                var first_columnindex = that.column_index_array[groupIndex][0];
                that.divobj.find('#deleteRow_'+first_columnindex).css('visibility','hidden');
                return false;
            }else {
                that.deleteGroup(groupIndex);
            }
        }else {
            if(that.showTile === 'yes') {
                await that.checkHaveTiledRow('', columnIndex);
            }
            var conditionRowobj = that.divobj.find('#conditioncolumn_' + groupIndex + '_' + columnIndex);
            if (conditionRowobj.length > 0) {
                conditionRowobj.remove();
            }
            //如果是最后一行，则删除前一行条件的筛选条件
            var columnIndexArr = that.column_index_array[groupIndex];
            var columnIndex_key = columnIndexArr.indexOf(columnIndex);
            var columnIndex_length = columnIndexArr.length;
            if (columnIndex_key == columnIndex_length - 1) {
                var prevColumnIndex = columnIndexArr[columnIndex_key - 1];
                var prevColumnIndexGlueobj = that.divobj.find('#columnconditionglue_' + prevColumnIndex);
                if (prevColumnIndexGlueobj.length > 0) {
                    prevColumnIndexGlueobj.empty();
                }
            }
            that.column_index_array[groupIndex].splice(columnIndex_key, 1);

            //自动提醒 仅有一行条件时，不显示显示第一行的删除按钮
            if (that.source == 'AutomaticReminds'){
                if (that.column_index_array[groupIndex].length == 1) {//只剩下一行，删除相当于删除整个组合条件
                    var first_columnindex = that.column_index_array[groupIndex][0];
                    that.divobj.find('#deleteRow_'+first_columnindex).css('visibility','hidden');
                }
            }
        }

    }

    //加载字段对应的条件
    this.updatefOptions = function (columnindex){
        var unJudgedConditionArr = that.unJudgedConditionArr;
        if(empty(that.fieldsinfo) && CrmPopup.global_listPopupObj.length>0){
            for(var i=CrmPopup.global_listPopupObj.length-1;i>=0;i--) {
                if(CrmPopup.global_listPopupObj[i].module==that.module && CrmPopup.global_listPopupObj[i].fields!= undefined) {
                    var tmp_fieldsinfo = CrmPopup.global_listPopupObj[i].fields;
                    if (tmp_fieldsinfo != undefined && !empty(tmp_fieldsinfo)){
                        that.fieldsinfo = tmp_fieldsinfo;
                        break;
                    }
                }
            }
        }
        var fieldsinfo = that.fieldsinfo;
        //获取选择字段的选中值index
        var columnSelectObj = that.divobj.find('#fcol'+columnindex);
        //获取选择条件的选中值index
        var optionSelectObj = that.divobj.find('#fop'+columnindex);
        if (columnSelectObj.length == 0 || optionSelectObj.length == 0){
            return false;
        }
        var column_selectindex = columnSelectObj.prop('selectedIndex');
        var option_selectindex = optionSelectObj.prop('selectedIndex');
        if (column_selectindex < 0 || option_selectindex < 0){
            return false;
        }
        var selected_columnField = columnSelectObj[0].options[column_selectindex].value;
        var selected_option = optionSelectObj[0].options[option_selectindex].value;

        var uitype = '';
        if(fieldsinfo != undefined && fieldsinfo.length>0){
            var string_array = selected_columnField.split(":");
            var fieldname = string_array[2];
            var tablename = string_array[0];
            ld.each(fieldsinfo,function(index,fieldinfo){
                if(fieldinfo['fieldname'] == fieldname){
                    uitype = fieldinfo['uitype'];
                    return false;
                }
            })
        }

        if (!empty(selected_columnField)){
            var fieldinfo = that.getFieldInfoByColValue(selected_columnField);
            var isSelectField = false;
            if (fieldinfo){
                var bigType = fieldinfo.bigType;
                if(that.pickBigTypeArr.indexOf(bigType) > -1 ){
                    isSelectField = true;
                }
            }
            var tmp_columFieldArr = selected_columnField.split(":");
            var fieldtype = tmp_columFieldArr[4];
            //字段对应的选择条件下拉选项
            var optionArr = that.getOptionByType(fieldtype);
            //清空下拉选项
            optionSelectObj[0].options.length = 0;
            optionSelectObj[0].options[0] = new Option (arrJsPopLabel['NONE'], '');
            var tmp_key = 1;
            var haveselected = false;
            ld.each(optionArr,function (tmp_index,tmp_value) {
                var flabel = that.fLabels[tmp_value];
                if(empty(flabel)){
                    return true;
                }
                if(selected_columnField.indexOf('publicaccount:publicaccount:Accounts')>0 || selected_columnField.indexOf('currency_id')>0 ){//客户模块中是否公海字段
                    if(tmp_value !='e' && tmp_value != 'n') {
                        return true;
                    }
                }
                if(selected_columnField.indexOf('content:content:PublicAnnouncement')>0){//客户模块中是否公海字段
                    if(tmp_value != 'c') {
                        return true;
                    }
                }
                if(selected_columnField.indexOf("conversion_rate")>0) {
                    if(unJudgedConditionArr.indexOf(tmp_value) > -1) {
                        return true;
                    }
                }
                if (uitype == 222){//手写签名
                    if (unJudgedConditionArr.indexOf(tmp_value) < 0){
                        return true;
                    }
                }
                optionSelectObj[0].options[tmp_key] = new Option(that.fLabels[tmp_value],tmp_value);
                if (isSelectField && tmp_value == 'new_belong'){//下拉框样式字段默认属于
                    optionSelectObj[0].options[tmp_key].selected = true;
                    haveselected = true;
                }
                // else if (tmp_value == selected_option){//注释原因：不保留之前的条件 除特殊默认第一个非无条件
                //     optionSelectObj[0].options[tmp_key].selected = true;
                //     haveselected = true;
                // }
                tmp_key++;
            });
            //日期时间字段 注释原因：不保留之前的条件 除特殊默认第一个非无条件
            if(fieldtype=='D' || fieldtype=='DT'){
                ld.each(that.datetimestr,function (tmp_value,tmp_dataArr){
                    optionSelectObj[0].options[tmp_key] = new Option (tmp_dataArr[2], tmp_value);
                    // if (tmp_value == selected_option){
                    //     optionSelectObj[0].options[tmp_key].selected = true;
                    //     haveselected = true;
                    // }
                    tmp_key++;
                });
            }

            //单选用户字段 选择条件显示"是当前操作员"
            if(that.multiuser_uitype_arr.indexOf(uitype)>-1 || that.user_uitype_arr.indexOf(uitype)>-1){
                optionSelectObj[0].options[tmp_key] = new Option(that.fLabels['curuser'],'curuser');
                // if (selected_option == 'curuser'){//注释原因：不保留之前的条件 除特殊默认第一个非无条件
                //     optionSelectObj[0].options[tmp_key].selected = true;
                //     haveselected = true;
                // }
                tmp_key++;
            }
            //无选中默认选中第一个非无条件
            if(!haveselected && optionSelectObj[0].options[1]){
                optionSelectObj[0].options[1].selected = true;
            }
        }

    }

    //获取字段对应的选择条件
    this.getOptionByType = function (fieldtype){
        fieldtype = empty(fieldtype) ? 'V' : fieldtype;
        var arr = [];
        switch (fieldtype){
            case 'V':
                arr = ['c','e','n','s','ew','k','isnull','isnotnull'];
                if (!that.isReportModule){
                    arr = ['c','e','n','s','ew','k','isnull','isnotnull','new_belong','new_notbelong'];
                }
                break;
            case 'N':
                arr = ['e','n','l','g','m','h','isnull','isnotnull'];
                break;
            case 'T':
                arr =  ['e','n','l','g','m','h','isnull','isnotnull'];
                break;
            case 'I':
                arr = ['e','n','l','g','m','h','isnull','isnotnull'];
                break;
            case 'D':
                arr = ['bw','e','n','l','g','m','h','isnull','isnotnull'];;
                break;
            case 'DT':
                arr = ['bw','e','n','l','g','m','h','isnull','isnotnull'];
                break;
            case 'NN':
                arr = ['e','n','l','g','m','h','isnull','isnotnull'];
                break;
            case 'E':
                arr = ['c','e','n','s','ew','k','isnull','isnotnull'];
                if (!that.isReportModule){
                    arr = ['e','n','l','g','m','h','isnull','isnotnull','new_belong','new_notbelong'];
                }
                break;
            case 'M':
                arr = ['c','e','n','s','ew','k','isnull','isnotnull'];
                break;
            case 'C':
                arr = ['e','n','isnull','isnotnull'];
                break;
        }
        if (that.source == 'WorkflowCustomizationList' || that.source == 'SharingCustomRules'){
            var fieldtype_arr = ['V','N','T','I','C','D','DT','NN','E'];
            if (fieldtype_arr.indexOf(fieldtype) > -1){
                arr.push('has_changed');
                arr.push('has_changed_to');
                arr.push('has_changed_from');
            }
        }

        return arr;
    }

    //加载关键字部分
    this.addRequiredElements = function (columnIndex, opt){
        var fcolObj = that.divobj.find('#fcol'+columnIndex);
        var fopObj = that.divobj.find('#fop'+columnIndex);
        var fvalObj = that.divobj.find('#fval'+columnIndex);
        var fval_extObj = that.divobj.find('#fval_ext'+columnIndex);
        var clearBtnObj = that.divobj.find('#fvalClearBtn_'+columnIndex);
        var groupIndex = fvalObj.attr('groupindex');
        var fvalDivObj = that.divobj.find('#fvalDiv_'+groupIndex+'_'+columnIndex);
        if (fcolObj == undefined || fopObj == undefined || !fcolObj || !fopObj){
            return false;
        }
        var fval_type = fvalObj.data('type');
        var fval_value = (that.fvalSpecialType.indexOf(fval_type) > -1) ? '' :fvalObj.val();
        var fop_value = fopObj.val();
        var fcol_value = fcolObj.val();
        var fval_ext_value = empty(fval_extObj.val())?'':fval_extObj.val();
        var isOpDate = that.isExistsDateTimeStr(fop_value);

        fvalDivObj.find('[delete=yes]').remove();
        clearBtnObj.css('display','none');
        //高级查找平铺界面
        if (that.objectSource && that.objectSource == 'AdvanceFilterTiled'){
            that.divobj.find('#conditioncolumn_1_'+columnIndex).css('width','33%');
        }

        //是空值、不是空值、是当前操作员,无关键字部分
        if(fop_value == 'isnull' || fop_value == 'isnotnull' || fop_value == 'curuser' || fop_value == 'has_changed'){
            fvalObj.css('display','none');
            fval_extObj.css('display','none');
            clearBtnObj.css('display','none');
            return false;
        } else{
            fvalObj.css('display','');
            fval_extObj.css('display','');
        }

        if (fcolObj[0].selectedIndex < 0 || fopObj[0].selectedIndex < 0){
            return false;
        }

        var fieldtype = '';
        var fieldInfo = fcol_value.split(":");
        var tableName = fieldInfo[0];
        var fieldName = fieldInfo[2];
        var columnName = fieldInfo[1],
            flag = that.addRequiredElementsByField(columnName, {
            'fval_value':fval_value,'fop_value':fop_value,'fcol_value':fcol_value,'fvalObj':fvalObj,
            'fvalDivObj': fvalDivObj, 'groupIndex':groupIndex,'columnIndex':columnIndex,
        });
        //&& !empty(fcol_value)
        if (flag === false && !empty(fcol_value)){
            fieldtype = fieldInfo[4];
            //非日期时间格式
            if(fieldtype != 'D' && fieldtype != 'DT' && fieldtype != 'T'){
                var placeholder = '';
                if(fop_value === 'belong' || fop_value === 'notbelong'){
                    placeholder = arrJsPopLabel['SEARCHBELONGTIP'];
                }
                else {
                    placeholder = '请输入';
                }
                var html = `<input class="ld-input-inner overflow-space" style="width: 100%" name="fval${columnIndex}" id="fval${columnIndex}" groupindex="${groupIndex}" value="${fval_value}" placeholder="${placeholder}">`;
                fvalDivObj.html(html);
                //列表高级查找和源单高级查找暂时不用
                /*
                that.divobj.find('#fval'+columnIndex).off('keypress').on('keypress',function (event){
                    var e=event||window.event;
                    if(e.keyCode==13)
                    {
                        var prevpopupobj=CrmPopup.getPopupObj('lastprev');
                        if(prevpopupobj.type==RelateListPage.type) {
                            //相关信息查询
                            DetailViewRelation.callSearch();
                        }
                        if(prevpopupobj.module=='OftenUseReport')
                            generateReport(node5);
                        return false;
                    }
                });
                */
                that.defaultRequiredElements(columnIndex);
                clearBtnObj.css('display','');

            }
            else {
                //日期时间字段 后一个日期input,先取值，后删除日期input
                if (fval_extObj.length > 0) {
                    fval_extObj.remove();
                }
                var timeformat = " %H:%M:%S";
                var showtime = ' HH:mm:ss';
                if (fieldtype == 'D' || (tableName == 'ld_activity' && (fieldName == 'date_start' || fieldName == 'due_date') ) ) {
                    timeformat = '';
                    showtime = '';
                }
                var input_showtitle = '';
                if (that.objectSource && that.objectSource == 'AdvanceFilterTiled'){
                    input_showtitle = ` tag="showtitle" data-tip="${fval_value}" data-direction="top" data-type="position" `;
                }
                var input_class = 'Wdate WdateImage advanceFilterDataInput overflow-space';
                var input_onclick = 'WdatePicker({startDate:\'%y-%M-%d'+timeformat+'\',dateFmt:\'yyyy-MM-dd'+showtime+'\'})';
                var input_html = '<input '+input_showtitle+' onclick="'+input_onclick+'" class="'+input_class+'" type="text" id="fval'+columnIndex+'" name="fval'+columnIndex+'" value="'+fval_value+'" groupindex="'+groupIndex+'" autocomplete="off">';
                //删除原来的input
                fvalObj.remove();
                fvalDivObj.prepend(input_html);
                clearBtnObj.css('display','');

                if (fieldtype=='T' && tableName.indexOf('ld_crmentity') < 0){
                    that.defaultRequiredElements(columnIndex);
                }else {
                    //列表高级查找和源单高级查找暂时无用 不知道哪里有用
                    /*var tmpobj=that.divobj.find("[name=jscal_trigger_fval"+columnIndex+"]");
                    if(tmpobj == undefined || tmpobj.length <= 0) {
                        var node = that.divobj.find("[name=fval"+columnIndex+"]").get(0);
                        node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
                        node.setAttribute('class','Wdate btn-radius-system WdateImage');
                        node.setAttribute('style','width:148px;');
                    }*/
                    //选择条件为时间
                    if (isOpDate || fop_value == 'bw'){
                        //没有第二个选择时间input
                        if (that.divobj.find('#fval_ext'+columnIndex) == undefined || that.divobj.find('#fval_ext'+columnIndex).length == 0){
                            var ext_showtitle = '';
                            if (that.objectSource && that.objectSource == 'AdvanceFilterTiled'){
                                ext_showtitle = ` tag="showtitle" data-tip="${fval_ext_value}" data-direction="top" data-type="position" `;
                            }
                            var ext_class = 'Wdate WdateImage advanceFilterDataInput overflow-space';
                            var ext_onclick = 'WdatePicker({startDate:\'%y-%M-%d'+timeformat+'\',dateFmt:\'yyyy-MM-dd'+showtime+'\'})';
                            var ext_html = '<input '+ext_showtitle+' onclick="'+ext_onclick+'" class="'+ext_class+'" type="text" id="fval_ext'+columnIndex+'" name="fval_ext'+columnIndex+'" groupindex="'+groupIndex+'" value="'+fval_ext_value+'" autocomplete="off">';
                            that.divobj.find('#fval'+columnIndex).after(ext_html);
                        }
                        var datetimestr = that.datetimestr;
                        for(var timekey in datetimestr) {
                            if(timekey == fop_value){
                                if(fieldtype == 'DT') {
                                    that.divobj.find("[name=fval"+columnIndex+"]").val(datetimestr[timekey][0]+" 00:00:00");
                                    that.divobj.find("[name=fval_ext"+columnIndex+"]").val(datetimestr[timekey][1]+" 23:59:59");
                                } else {
                                    that.divobj.find(" [name=fval"+columnIndex+"]").val(datetimestr[timekey][0]);
                                    that.divobj.find("[name=fval_ext"+columnIndex+"]").val(datetimestr[timekey][1]);
                                }
                                that.divobj.find("[name=fval"+columnIndex+"]")[0].disabled = true;
                                that.divobj.find("[name=fval_ext"+columnIndex+"]")[0].disabled = true;
                                clearBtnObj.css('display','none');
                                break;
                            }
                        }
                        //列表高级查找和源单高级查找暂时无用 不知道哪里有用
                        /*if(that.divobj.find("[name=jscal_trigger_fval_ext"+columnIndex+"]").length>0) {
                            var node =  that.divobj.find(" [name=fval"+columnIndex+"]").get(0);//document.getElementById('fval'+columnindex);
                            node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'"})');
                            node.setAttribute('class','Wdate btn-radius-system WdateImage');
                            node.setAttribute('style','width:108px;margin-right: 8px;');
                        }*/
                    }else {
                        that.defaultRequiredElements(columnIndex);
                    }
                }
            }
        }
        else {
            that.defaultRequiredElements(columnIndex);
        }
        if (that.objectSource && that.objectSource == 'AdvanceFilterTiled'){
            tooltip(that.divobj.find('[tag=showtitle]'), {transition: true, time: 200});
        }

    }

    //去除默认部分
    this.defaultRequiredElements = function (columnIndex){
        var fval_extobj = that.divobj.find("[name=fval_ext"+columnIndex+"]");
        var clear_text_obj = that.divobj.find("[name=fvalClearBtn_"+columnIndex+"]");
        if (fval_extobj.length > 0){
            fval_extobj.remove();
        }
        if (clear_text_obj.length > 0){
            // clear_text_obj.remove();
        }
        /*var jscal_trigger_fvalobj = that.divobj.find("[name=jscal_trigger_fval"+columnIndex+"]");
        var jscal_trigger_fval_extobj = that.divobj.find("[name=jscal_trigger_fval_ext"+columnIndex+"]");
        if (jscal_trigger_fvalobj.length > 0){
            jscal_trigger_fvalobj.remove();
        }
        if (jscal_trigger_fval_extobj.length > 0){
            jscal_trigger_fval_extobj.remove();
        }*/

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
            var fcol_value = opt.fcol_value,fval_value = opt.fval_value,fop_value = opt.fop_value,fvalDivObj = opt.fvalDivObj;
            var columnIndex = opt.columnIndex,groupIndex = opt.groupIndex;
            var columnInfo = that.getColumnInfoByIndex(groupIndex, columnIndex),
                belongFlag = that.newBelongArr.includes(fop_value),
                equalFlag = that.equalArr.includes(fop_value);
            if(columnInfo) {
                fval_value = columnInfo.value;
            }
            if(!belongFlag && !equalFlag ) {
                return false;
            }
            fval_value = '';
            var optionList = that.getAvailableKeyValueByField(fieldInfo, { value: fval_value, comparator: fop_value, columnStr: fcol_value });
            var type = belongFlag ? 'checkbox' : 'radio';
            var html = this.getOptionListHtml(fieldInfo, opt, optionList, type);
            fvalDivObj.html(html);
            if (type == 'checkbox' && that.showSelectStyle === 'yes'){
               that.divobj.find('#fval'+columnIndex).select2(that.multiSettingsInfo);
               var select2ValueArr = optionList.filter(function (item){
                    if (item.selected === 'selected'){
                        return item.value;
                    }
                });
                that.divobj.find('#fval'+columnIndex).val(select2ValueArr).select2(that.multiSettingsInfo);//设置多选框选中值
                that.divobj.find('#fval'+columnIndex).next().attr('delete','yes');
                that.divobj.find("[name=fvalClearBtn_"+columnIndex+"]").show();
            }
            return true;
        },
        picklist_key : function (fieldInfo, opt) {
            return this.picklist(fieldInfo, opt);
        },
        multipicklist : function (fieldInfo, opt) {
            var fcol_value = opt.fcol_value,fval_value = opt.fval_value,fop_value = opt.fop_value,fvalDivObj = opt.fvalDivObj;
            var columnIndex = opt.columnIndex,groupIndex = opt.groupIndex;
            var columnInfo = that.getColumnInfoByIndex(groupIndex, columnIndex),
                belongFlag = that.newBelongArr.includes(fop_value),
                equalFlag = that.equalArr.includes(fop_value);
            if(columnInfo) {
                fval_value = columnInfo.value;
            }
            if(!belongFlag && !equalFlag ) {
                return false;
            }
            fval_value = '';
            var optionList = that.getAvailableKeyValueByField(fieldInfo, { value: fval_value, comparator: fop_value, columnStr: fcol_value }),
                html = this.getOptionListHtml(fieldInfo, opt, optionList);
            fvalDivObj.html(html);
            if (that.showSelectStyle === 'yes'){
                that.divobj.find('#fval'+columnIndex).select2(that.multiSettingsInfo);
                var select2ValueArr = optionList.filter(function (item){
                    if (item.selected === 'selected'){
                        return item.value;
                    }
                });
                that.divobj.find('#fval'+columnIndex).val(select2ValueArr).select2(that.multiSettingsInfo);//设置多选框选中值
                that.divobj.find('#fval'+columnIndex).next().attr('delete','yes');
                that.divobj.find("[name=fvalClearBtn_"+columnIndex+"]").show();
            }
            return true;
        },
        multipicklist_key : function (fieldInfo, opt) {
            return this.multipicklist(fieldInfo, opt);
        },
        users : function (fieldInfo, opt) {
            var fcol_value = opt.fcol_value,fval_value = opt.fval_value,fop_value = opt.fop_value,fvalDivObj = opt.fvalDivObj;
            var columnIndex = opt.columnIndex,groupIndex = opt.groupIndex;
            if(!that.newBelongArr.includes(fop_value) && !that.equalArr.includes(fop_value)) {
                return false;
            }
            var html = '';
            html += `` +
                `<input class="ld-input-inner ld-input-inner-add" name="fval${columnIndex}" id="fval${columnIndex}" data-type="user" groupindex="${groupIndex}" value="" type="text" readonly="" data-scope="" placeholder="请选择用户">` +
                `<a delete="yes" name="chooseScopeUser" class="ld-text-select" href="javascript:;" data-value="user" >+</a>` +
                `<a delete="yes" class="ld-text-clear" href="javascript:;" draggable="false">+</a>` +
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
            var fcol_value = opt.fcol_value,fval_value = opt.fval_value,fop_value = opt.fop_value,fvalDivObj = opt.fvalDivObj;
            var columnIndex = opt.columnIndex,groupIndex = opt.groupIndex;
            var columnInfo = that.getColumnInfoByIndex(groupIndex, columnIndex);
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
            var bigType = fieldInfo.bigType;
            if(optionList.length === 0){
                optionList = [{'label':arrJsPopLabel['NONE'],'value':'','selected':'selected'}];
            }
            var { fval_value, columnIndex, groupIndex } = opt,
                valObjId = 'fval' + columnIndex,
                html = '',
                options = '';
            if (that.showSelectStyle == 'yes'){
                if (type == 'checkbox'){
                    html += '<select name="fval'+columnIndex+'" multiple id="fval'+columnIndex+'" groupindex="'+groupIndex+'" class="ld-select-inner select2 select2-offscreen select2-hidden-accessible" style="width: 100%" data-type="select2">'
                }else {
                    html += '<select name="fval'+columnIndex+'" id="fval'+columnIndex+'" groupindex="'+groupIndex+'" class="ld-select-inner" style="width: 100%" data-type="select">'
                }
                ld.each(optionList, function(index, info) {
                    if(info.value === '' && (optionList.length > 1 || type === 'checkbox')) {
                        return true;
                    }else if (info.value === '' && optionList.length === 1){
                        info.label = arrJsPopLabel['NONE'];
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
                        id = columnIndex + '_' + columnName + '_' + index,
                        checked = info.selected === 'selected' ? 'checked' : '';
                    options += '' +
                        `<div class="ld-advance-check-item item">` +
                        `<input type="${type}" id="${id}" name="${name}" ${checked} value="${info.value}"><label for="${id}">${info.label}</label>` +
                        `</div>`;
                })
                html += `<div id="${valObjId}" name="${valObjId}" class="ld-flex-start ld-flex-wrap ld-advance-check-div" groupindex="${groupIndex}" value="${fval_value}">${options}</div>`;
            }
            return html;
        },
    }

    this.chooseScopeInit = function (btnObj, opt) {
        AjaxJSPage('ChooseScope', 'include/js/ScopePopup/ChooseScope.js');
        var { columnIndex } = opt,
            scopeInput = btnObj.siblings(`#fval${columnIndex}`),
            scopeData = {
                scope : 'user',
                scopeVal : scopeInput.data('scope').toString().replace(/\|/g,','),
                scopeValLabel : scopeInput.val(),
            };
        var fop_value = opt.fop_value;
        var inputtype = 'checkbox';
        if (fop_value == 'e' || fop_value == 'ne'){
            inputtype = 'radio';
        }
        scopeInput.data('scope-data', scopeData);
        ChooseScope.init(btnObj,{
            module: that.popupobj.module,
            data: scopeData,
            btnList: {
                user: btnObj
            },
            confirm: function () {
                scopeInput.val(scopeData.scopeValLabel);
                scopeInput.data('scope', scopeData.scopeVal);
            },
            inputtype:inputtype
        })
        btnObj.siblings(`.ld-text-clear`).bind('click', function() {
            that.clearScopeUser(columnIndex);
        })
    }

    this.clearScopeUser = function (columnIndex) {
        var scopeInput = that.divobj.find(`#fval${columnIndex}`),
            scopeData = scopeInput.data('scope-data');
        scopeInput.val('');
        scopeInput.data('scope', '');
        if(scopeData) {
            scopeData.scopeVal = '';
            scopeData.scopeValLabel = '';
        }
    }

    this.getColumnInfoByIndex = function(groupIndex, columnIndex) {
        var groupObj = that.criteria_groups_arr
        if(groupObj && groupObj[groupIndex] && groupObj[groupIndex]['columns'] && groupObj[groupIndex]['columns'][columnIndex]) {
            return groupObj[groupIndex]['columns'][columnIndex];
        }
        return false;
    }

    /** @returns {Array} */
    this.getAvailableKeyValueByField = function (fieldInfo, opt) {
        var columnName = fieldInfo.columnName;
        if(!that.availableKeyValue || !that.availableKeyValue[columnName]) {
            that.setAvailableKeyValueByField(fieldInfo, opt);
        }
        var availableKeyValue = that.availableKeyValue[columnName],
            { value, comparator } = opt,
            bigType = fieldInfo.bigType, valueArr = value.toString().replace(/ \|##\| /g,'|').split('|');
        if(bigType === 'boolean') {
            var optionValue = [ 'YES', 'NO' ],
                selIndex = 1;
            optionValue = optionValue.map( (v, i) => {
                return {
                    label: arrJsPopLabel[v],
                    value: arrJsPopLabel[v],
                    selected: '',
                }
            });
            value = value.toString();
            if(value.toLowerCase() === 'yes' || value === '是' || value === 'true' || value === '1') {
                selIndex = 0;
            }
            optionValue[selIndex].selected = 'selected';
            return that.availableKeyValue[columnName] = optionValue;
        }
        ld.each(availableKeyValue, function(index, option) {
            var tmpFlag = false;
            for (var val of valueArr) {
                if(val === option.value) {
                    tmpFlag = true;
                    break;
                }
            }
            option.selected = tmpFlag ? 'selected' : '';
        })
        return availableKeyValue;
    }

    this.setAvailableKeyValueByField = function (fieldInfo, opt) {
        if(!that.availableKeyValue) {
            that.availableKeyValue = {};
        }
        var columnName = fieldInfo.columnName,
            bigType = fieldInfo.bigType,
            { value, comparator, columnStr } = opt;
        value = value ? value : '';
        if(that.availableKeyValue[columnName]) {
            return that.availableKeyValue[columnName];
        }
        // 复选框
        if(bigType === 'boolean') {
            return that.availableKeyValue[columnName] = [];
        }
        var fromModule = fieldInfo.module,
            columnModule = columnStr.split(':')[3].split('_').shift();
        // 下拉框，多选框，发送请求获取
        ldAjaxsync(that.getAjaxUrl(), getUrlParamsByObj({
            funName: 'getAvailableKeyValueByFieldName',
            fromModule,
            columnModule,
            columnStr,
            columnName,
            value,
            comparator,
        }), function (data) {
            that.availableKeyValue[columnName] = data.result;
            DelProgressObjs();
        })
    }

    this.getKeyValueByIndex = function (fieldInfo, optionIndex) {
        if(!that.availableKeyValue) {
            return  '';
        }
        var columnName = fieldInfo.columnName,
            availableValues = that.availableKeyValue[columnName];
        if(availableValues && availableValues[optionIndex]) {
            return availableValues[optionIndex].value;
        }
        return '';
    }

    this.getAjaxUrl = function () {
        if(!that.ajaxUrl) {
            var module = that.popupobj.module;
            if (module == undefined || empty(module)){
                module = that.module;
            }
            that.ajaxUrl = `index.php?module=${module}&action=${module}Ajax&file=AdvanceSearchApi`;
        }
        return that.ajaxUrl;
    }

    //清空关键字input的值
    this.clearFvalInput = function (columnIndex){
        var fvalobj = that.divobj.find('#fval'+columnIndex);
        var type = fvalobj.data('type');
        if (type == 'select2'){
            fvalobj.val([]).select2(that.multiSettingsInfo);
            fvalobj.next().attr('delete','yes');
        }else if (type == 'user'){
            // 选择用户的值清除
            that.clearScopeUser(columnIndex);
        }
        var fval_extobj = that.divobj.find('#fval_ext'+columnIndex);
        if (fvalobj.length > 0){
            fvalobj.val('');
        }
        if (fval_extobj.length > 0){
            fval_extobj.val('');
        }
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        // 平铺选项的值清除
        var checkInputObjs = fvalobj.find(`input[type="checkbox"]`);
        if(checkInputObjs.length > 0) {
            checkInputObjs.prop('checked', false);
        }
        var radioInputObjs = fvalobj.find(`input[type="radio"`);
        if(radioInputObjs.length > 0) {
            radioInputObjs.prop('checked', false);
        }
    }

    //判断是否是时间条件
    this.isExistsDateTimeStr = function (value) {
        var isexists= false;
        if(that.datetimestr != undefined && !empty(that.datetimestr)){
            ld.each(that.datetimestr,function(key,resultobj){
                if(value == key) {
                    isexists = true;
                    return false ;
                }
            });
        }
        return isexists;
    }

    //获取高级查找条件
    this.checkAdvancedFilter = function (){
        var escapedOptions = new Array('account_id','contactid','contact_id','product_id','parent_id','campaignid','potential_id','assigned_user_id1','quote_id','accountname','salesorder_id','vendor_id','time_start','time_end','lastname','accountid');
        var conditionColumns = that.divobj.find('[tag=conditionColumn]');
        var criteriaConditions = [];
        var unJudgedConditionArr = that.unJudgedConditionArr;
        //获取条件行数据
        for (var i = 0;i<conditionColumns.length;i++){
            var conditionColumn = ld(conditionColumns[i]);
            var columnIndex = ld(conditionColumn).attr('columnIndex');
            var groupIndex = ld(conditionColumn).attr('groupindex');

            var columnId = "fcol"+columnIndex;
            var comparatorId = "fop"+columnIndex;
            var valueId = "fval"+columnIndex;
            var extValueId = "fval_ext"+columnIndex;
            var fcolobj = that.divobj.find('#'+columnId);
            var fopobj = that.divobj.find('#'+comparatorId);
            var fvalobj = that.divobj.find('#'+valueId);
            var fval_extobj = that.divobj.find('#'+extValueId);
            var fconobj = that.divobj.find('#fcon'+columnIndex);

            //选择字段
            var columnObject =fcolobj.get(0);
            var selectedColumn = trim(columnObject.value);
            var selectedColumnIndex = columnObject.selectedIndex;
            var selectedColumnLabel = columnObject.options[selectedColumnIndex].text;
            //选择条件
            var comparatorObject =fopobj.get(0);
            var comparatorValue = trim(comparatorObject.value);
            //关键字
            var valueObject =fvalobj.get(0);
            var specifiedValue = trim(valueObject.value);
            var extValueObject = '';
            var extendedValue = '';
            if (fval_extobj.length > 0){
                extValueObject = fval_extobj.get(0);
                extendedValue = trim(extValueObject.value);
            }
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            var fieldInfo = that.getFieldInfoByColValue(selectedColumn),
                valueObj = that.checkAdvancedFilterByField(fieldInfo, {
                    fvalobj, comparatorValue
                });
            if(valueObj) {
                specifiedValue = valueObj.value;
            }

            //关键字第一部分无值给提示
            if(specifiedValue=='' && comparatorValue != "" && unJudgedConditionArr.indexOf(comparatorValue) < 0) {
                MessagePopup.TipOne_warning(arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH']);
                return false;
            }
            //关键字第二部分无值给提示 日期第二个input
            if (extValueObject && ( extendedValue=='' && unJudgedConditionArr.indexOf(comparatorValue) < 0 )){
                MessagePopup.TipOne_warning(arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH']);
                return false;
            }
            //筛选条件部分
            var glueConditionObject = fconobj.get(0);// getObj(glueConditionId);
            var glueCondition = '';
            if(glueConditionObject){
                glueCondition = trim(glueConditionObject.value);
            }

            if(conditionColumns.length == 1 && selectedColumn == '' && comparatorValue == '' && specifiedValue == ''){
                return true;
            }
            //选择字段不能为空
            if (!emptyCheck("fcol"+columnIndex," "+arrJsPopLabel['SelectField'],"text")){
                return false;
            }
            //选择条件不能为空
            if (!emptyCheck("fop"+columnIndex,selectedColumnLabel+' '+arrJsPopLabel['OPTIONS']+' ',"text")){
                return false;
            }

            var col = selectedColumn.split(":");
            if(escapedOptions.indexOf(col[3]) == -1) {
                //时间 日期时间
                if(col[4] == 'T' || col[4] == 'DT') {
                    var datetime = specifiedValue.split(" ");
                    if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"){
                        if(datetime.length > 1) {
                            if(!re_dateValidate(datetime[0],selectedColumnLabel,"OTH")) {
                                return false
                            }
                            if(!re_patternValidate(datetime[1],selectedColumnLabel,"TIMESECONDS")) {
                                return false
                            }
                        }else if (unJudgedConditionArr.indexOf(comparatorValue) < 0){
                            if (col[0] == 'ld_activity' && (col[2] == 'date_start' || col[2] == 'due_date')){
                                if(!dateValidate(valueId,selectedColumnLabel,"OTH")){
                                    return false
                                }
                            }else {
                                if(!re_patternValidate(datetime[0],selectedColumnLabel,"TIMESECONDS")) {
                                    return false
                                }
                            }
                        }
                    }

                    if(extValueObject) {
                        var datetime = extendedValue.split(" ");
                        if (extendedValue.charAt(0) != "$" && extendedValue.charAt(extendedValue.length-1) != "$"){
                            if(datetime.length > 1) {
                                if(!re_dateValidate(datetime[0],selectedColumnLabel,"OTH")) {
                                    return false
                                }
                                if(!re_patternValidate(datetime[1],selectedColumnLabel,"TIMESECONDS")) {
                                    return false
                                }
                            } else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
                                if(!dateValidate(extValueId,selectedColumnLabel,"OTH")){
                                    return false
                                }
                            } else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
                                if(!dateValidate(extValueId,selectedColumnLabel,"OTH")){
                                    return false
                                }
                            }else {
                                if(unJudgedConditionArr.indexOf(comparatorValue) < 0 && !re_patternValidate(datetime[0],selectedColumnLabel,"TIMESECONDS")) {
                                    return false
                                }
                            }
                        }
                    }

                }
                else if(col[4] == 'D'){
                    if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$" && unJudgedConditionArr.indexOf(comparatorValue) < 0){
                        if(!dateValidate(valueId,selectedColumnLabel,"OTH")){
                            return false
                        }
                    }
                    if(extValueObject && unJudgedConditionArr.indexOf(comparatorValue) < 0) {
                        if(!dateValidate(extValueId,selectedColumnLabel,"OTH")){
                            return false
                        }
                    }
                }
                else if(col[4] == 'I') {
                    if(!intValidate(valueId,selectedColumnLabel+i)){
                        return false
                    }
                }
                else if(col[4] == 'N') {
                    if (!numValidate(valueId,selectedColumnLabel,"any",true)){
                        return false
                    }
                }
                /*else if(col[4] == 'E')
				{
					if (!patternValidate(valueId,selectedColumnLabel+" (Email Id)","EMAIL"))
						return false
				}*/
            }

            if(col[4] == "C") {
                if(specifiedValue == "1"){
                    specifiedValue = getObj(valueId).value = 'yes';
                }
                else if(specifiedValue =="0"){
                    specifiedValue = getObj(valueId).value = 'no';
                }
            }
            if (extValueObject && extendedValue != null && extendedValue != ''){
                specifiedValue = specifiedValue +','+ extendedValue;
            }

            var tmpColInfo = {
                "groupid":groupIndex,
                "columnname":selectedColumn,
                "comparator":comparatorValue,
                "value":specifiedValue,
                "columncondition":glueCondition
            };
            if (that.showTile == 'yes'){
                var showAsTiledObj = that.divobj.find('#showAsTiled_'+columnIndex);
                if (showAsTiledObj.length > 0){
                    tmpColInfo['showAsTiled'] = showAsTiledObj.prop('checked') ? 'yes' : 'no';
                }
            }
            // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
            if(valueObj && valueObj.valueLabel) {
                tmpColInfo.valueLabel = valueObj.valueLabel;
            }

            criteriaConditions[columnIndex] = tmpColInfo;
        }


        //获取组合条件组数据
        var criteriaGroups=[];
        var conditionGroups = that.divobj.find('[name=groupconditionglueDiv]');
        ld.each(conditionGroups,function (index,conditionGroup){
            var groupIndex = ld(conditionGroup).attr('groupindex');
            var groupCondition = '';
            var conditionGroupGlue = ld(conditionGroup).find('[tag=conditionGroupGlue]');
            if(conditionGroupGlue) {
                groupCondition = trim(conditionGroupGlue.val());
            }
            criteriaGroups[groupIndex] = {"groupcondition":groupCondition};
        });

        that.advft_criteria_groups=JSON.stringify(criteriaGroups);
        that.advft_criteria=JSON.stringify(criteriaConditions);
        that.criteria_groups_arr = '';
        that.popupobj.advft_criteria_groups = that.advft_criteria_groups;
        that.popupobj.advft_criteria = that.advft_criteria;
        if(that.prevpopupobj != undefined){
            that.prevpopupobj.advft_criteria_groups = that.advft_criteria_groups;
            that.prevpopupobj.advft_criteria = that.advft_criteria;
        }

        return true;
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
            var {fvalobj, comparatorValue } = opt,
                value = '';
            // 下拉框字段 属于不属于 / 等于不等于 的处理
            if(that.newBelongArr.includes(comparatorValue)) {
                var dataObj = fvalobj.select2('data');
                var dataArr = [];
                ld.each(dataObj,function (index,value){
                    dataArr.push(value.id);
                });
                value = dataArr.join('|');
                return { value };
            }else if (that.equalArr.includes(comparatorValue)){
                value = fvalobj.val();
                return { value };
            }
            return false;
        },
        picklist_key : function (fieldInfo, opt) {
            return this.picklist(fieldInfo, opt);
        },
        multipicklist : function (fieldInfo, opt) {
            var {fvalobj, comparatorValue } = opt,
                value = '', valueLabel = '';
            // 下拉框字段 属于不属于 / 等于不等于 的处理
            if(that.newBelongArr.includes(comparatorValue) || that.equalArr.includes(comparatorValue)) {
                var dataObj = fvalobj.select2('data');
                var dataArr = [];
                ld.each(dataObj,function (index,value){
                    dataArr.push(value.id);
                });
                if (that.newBelongArr.includes(comparatorValue)){
                    value = dataArr.join('|');
                    valueLabel = dataArr.join(',');
                }else {
                    value = dataArr.join(' |##| ');
                    valueLabel = dataArr.join(',');
                }
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
                value = scopeData.scopeVal.toString().replace(/,/g,'|');
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
            var {fvalobj, comparatorValue } = opt,
                value = '';
            // 复选框字段 等于不等于 的处理
            if(that.equalArr.includes(comparatorValue) ) {
                value = fvalobj.val();
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

    //选择源单版getUrlString，显示历史搜索记录
    this.showHistory=function (){
        var popupobj = that.popupobj;
        var prevpopupobj=that.prevpopupobj;
        var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SearchHistory&mode='+popupobj.searchmode;
        url += '&searchtype='+popupobj.searchtype+'&divid='+popupobj.divid;

        url += '&newAdvanceFilter=yes';

        var searchfrom=prevpopupobj.type;
        url += '&searchfrom='+searchfrom;

        if(popupobj.advancefiltersearch == 'yes' && popupobj.searchtype == 'advance'){
            url += '&advancefiltersearch=yes';
        }
        //zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
        // if(popupobj.module == 'Approve'){
        // 	var prevpopupobj = CrmPopup.getPopupObj('lastprev');
        // 	if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
        // 		url += '&searchmodule='+prevpopupobj.module;
        // 	}
        // }
        ldAjax(url,"",function(data){
            DelProgressObjs();
            if(data.code == 1){
                var tmppopupobj=that.popupobj;

                if(data.result.num_rows >0){
                    ld('#'+tmppopupobj.divid+' [name=SearchHistory]').html(data.result.content);
                }else{
                    ld('#'+tmppopupobj.divid+' [name=SearchHistory]').html(data.result.emptycontent);
                }
                var cmb_li_advanceobjs = that.divobj.find('[tag=selectoption]');
                cmb_li_advanceobjs.off('click').on('click',function () {
                    that.changeFilterBySearchHistory(this);
                });
                that.divobj.find('[name=clear_advance]').off('click').on('click',function () {
                    that.clearhistory(this);
                })
            }
        });
    }

    //清除高级查找历史记录
    this.clearhistory=function (obj){
        var searchtype = ld(obj).attr('searchtype');
        var popupobj=that.popupobj;
        popupobj.searchtype = searchtype;
        popupobj.searchmode = 'clearhistory';
        that.showHistory(popupobj);
    }

    //点击历史记录 获取高级查找条件
    this.changeFilterBySearchHistory=function (obj){
        var optionvalue = ld(obj).attr('optionvalue');
        var fldname = ld(obj).attr('fldname');
        var parentdivid = ld(obj).attr('divid');
        cmb_liclick(optionvalue,fldname,parentdivid);
        var popupobj=that.popupobj;
        if(popupobj.searchtype == 'advance'){
            //为高级查询框赋值
            var searchid = ld(obj).attr('searchid');
            popupobj.searchmode = 'choosehistory';
            var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=SearchHistory&mode='+popupobj.searchmode;
            url += '&searchtype='+popupobj.searchtype+'&divid='+popupobj.divid+'&id='+searchid;
            //zkt 20220513 51745（https://81mis.com/kfbcrm/index.php）审批中心》合同订单，点击查找按钮，界面一直转圈
            if(that.module == 'Approve'){
                var prevpopupobj = CrmPopup.getPopupObj('lastprev');
                if(prevpopupobj!=undefined&&prevpopupobj.type=='listpage'){
                    url += '&searchmodule='+prevpopupobj.module;
                }
            }
            ldAjax(url,"",function(data){
                DelProgressObjs();
                if(data.code == 1){
                    that.changeAdvanceCondition(data.result.criteria_groups);
                }
            });
        }
    }

    //切换高级查找界面
    this.changeAdvanceCondition=function (criteria_groups){
        //重置已有查询条件数量
        that.advft_column_index_count = -1;
        that.advft_group_index_count = 0;
        that.column_index_array = [];
        that.group_index_array = [];
        if (that.showTile === 'yes' && that.advanceTiledObj){
            that.tiledGroupIndex = 1;
            var tiledColumnArr = that.tiledColumnArr;
            that.tiledColumnArr = {};
        }
        //清空原有条件
        that.divobj.find('[tag=conditionGroup]').remove();
        //遍历所有查询条件
        if (empty(criteria_groups)){
            that.addNewConditionGroup();
        }else {
            that.showAdvanceCondition(criteria_groups);
        }
        if (that.showTile === 'yes' && that.advanceTiledObj){
            var conditionObj = that.divobj.find('[groupindex=1]');
            var tmp_tiledColumnArr = {};
            ld.each(conditionObj,function (index,obj){
                var tmp_columnindex = ld(obj).attr('columnindex')
                var tmp_fcol_val = ld(obj).find('[tag=fcol]').val();
                var tmp_fconobj = ld(obj).find('[tag=fcon]');
                var tmp_fcon_val = tmp_fconobj.length === 0 ? 'and' : tmp_fconobj.val();
                if (tiledColumnArr.hasOwnProperty(tmp_fcol_val) && !tmp_tiledColumnArr.hasOwnProperty(tmp_fcol_val) && tmp_fcon_val === 'and'){
                    ld(obj).find('[tag=showAsTiled]').prop('checked',true);
                    tmp_tiledColumnArr[tmp_fcol_val] = tmp_columnindex;
                }
            });
            that.tiledColumnArr = tmp_tiledColumnArr;
        }
    }


    //高级查找平铺字段功能

    //
    this.setRequiredElement = function (columnIndex, columnInfo) {
        var comparator = columnInfo.comparator;
        var value = columnInfo.value;
        var valueArr = columnInfo.valueArr;
        var valueLabel = columnInfo.valueLabel;
        var fvalobj = that.divobj.find('#fval'+columnIndex);
        var type = fvalobj.data('type');
        if (type == 'select2' && value != ''){//多选框赋值
            valueArr = value.split('|');
            if (value.indexOf(' |##| ') > -1){
                valueArr = value.split(' |##| ');
            }
            fvalobj.val(valueArr).select2(that.multiSettingsInfo);
            fvalobj.next().attr('delete','yes');
        }else if (type === 'user'){
            if (that.newBelongArr.includes(comparator)){
                fvalobj.val(valueLabel);
                fvalobj.data('scope', value);
                var scopeData =  fvalobj.data('scope-data');
                scopeData.scopeVal = value;
                scopeData.scopeValLabel = valueLabel;
            }else {
                fvalobj.val(value);
                fvalobj.data('scope', valueLabel);
                var scopeData =  fvalobj.data('scope-data');
                scopeData.scopeVal = valueLabel;
                scopeData.scopeValLabel = value;
            }
        }
        else if (comparator == 'bw' && value != ''){
            fvalobj.val(valueArr[0]);
            if(valueArr.length == 2 && that.divobj.find(`[name=fval_ext${columnIndex}]`).length>0){
                that.divobj.find(`[name=fval_ext${columnIndex}]`).val(valueArr[1]);
            }
        }else {
            if(value == 'Accepted'){
                fvalobj.val(alert_arr.Accepted);
            }
            else if(value =='Rejected'){
                fvalobj.val(alert_arr.Rejected);
            }
            else{
                fvalobj.val(valueArr[0]);
            }
        }
    }

    //获取行条件
    this.checkAdvancedFilterRow = function(columnIndex) {
        var conditionColumnobj = that.divobj.find('[tag=conditionColumn]');
        if (conditionColumnobj.length == 1){
            var tmp_columnindex = conditionColumnobj.attr('columnindex');
            if (conditionColumnobj.find('#fcol'+tmp_columnindex).val() == '' && conditionColumnobj.find('#fop'+tmp_columnindex).val() == ''){
                return '';
            }
        }

        var conditionColumn = that.divobj.find(`[columnindex="${columnIndex}"]`),
            groupIndex = ld(conditionColumn).attr('groupindex'),
            columnId = "fcol"+columnIndex,
            comparatorId = "fop"+columnIndex,
            valueId = "fval"+columnIndex,
            extValueId = "fval_ext"+columnIndex,
            fcolobj = that.divobj.find('#'+columnId),
            fopobj = that.divobj.find('#'+comparatorId),
            fvalobj = that.divobj.find('#'+valueId),
            fval_extobj = that.divobj.find('#'+extValueId),
            fconobj = that.divobj.find('#fcon'+columnIndex);

        //选择字段
        var columnObject =fcolobj.get(0),
            selectedColumn = trim(columnObject.value),
            selectedColumnIndex = columnObject.selectedIndex,
            selectedColumnLabel = columnObject.options[selectedColumnIndex].text;
        //选择条件
        var comparatorObject =fopobj.get(0),
            comparatorValue = trim(comparatorObject.value);
        //关键字
        var valueObject =fvalobj.get(0),
            specifiedValue = trim(valueObject.value),
            extValueObject = '',
            extendedValue = '';
        if (fval_extobj.length > 0){
            extValueObject = fval_extobj.get(0);
            extendedValue = trim(extValueObject.value);
        }
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        var fieldInfo = that.getFieldInfoByColValue(selectedColumn),
            valueObj = that.checkAdvancedFilterByField(fieldInfo, {
                fvalobj, comparatorValue
            });
        if(valueObj) {
            specifiedValue = valueObj.value;
        }

        //选择字段不能为空
        if (!emptyCheck("fcol"+columnIndex," "+arrJsPopLabel['SelectField'],"text")){
            return false;
        }
        //选择条件不能为空
        if (!emptyCheck("fop"+columnIndex,selectedColumnLabel+' '+arrJsPopLabel['OPTIONS']+' ',"text")){
            return false;
        }

        var col = selectedColumn.split(":");

        if(col[4] === "C") {
            if(specifiedValue === "1"){
                specifiedValue = getObj(valueId).value = 'yes';
            }
            else if(specifiedValue ==="0"){
                specifiedValue = getObj(valueId).value = 'no';
            }
        }
        if (extValueObject && extendedValue != null && extendedValue != ''){
            specifiedValue = specifiedValue +','+ extendedValue;
        }

        //筛选条件部分
        var glueConditionObject = fconobj.get(0);// getObj(glueConditionId);
        var glueCondition = '';
        if(glueConditionObject){
            glueCondition = trim(glueConditionObject.value);
        }

        var tmpColInfo = {
            "groupid":groupIndex,
            "columnname":selectedColumn,
            "comparator":comparatorValue,
            "value":specifiedValue,
            "columncondition":glueCondition
        };
        // edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
        if(valueObj && valueObj.valueLabel) {
            tmpColInfo.valueLabel = valueObj.valueLabel;
        }

        return tmpColInfo;
    }



    //点击平铺checkbox按钮 或 改变平铺字段的条件或字段
    //eType 触发操作 click点击平铺checkbox change是切换条件或字段
    this.changeShowTiledColumn = function (columnIndex,eType = 'change'){
        if (that.showTile !== 'yes'){
            return false;
        }
        if (!that.advanceTiledObj){
            return false;
        }
        //判断是否勾选平铺
        var showAsTiledobj =  that.divobj.find('#showAsTiled_'+columnIndex);
        var showAsTiledDivobj =  that.divobj.find('#showAsTiledDiv_'+columnIndex);
        var checkBoxValue = showAsTiledobj.prop('checked');
        var tiledGroupIndex = that.tiledGroupIndex;
        var groupColumnIndexArr = that.column_index_array[tiledGroupIndex];

        var fcolobj = that.divobj.find('#fcol'+columnIndex);
        var fcol_value = fcolobj.val();
        var fopobj = that.divobj.find('#fop'+columnIndex);
        var fop_value = fopobj.val();
        var showHideTiledBtn_divobj = that.advanceTiledObj.divobj.find('#showHideTiledBtn_div');

        if (checkBoxValue){//选中 列表平铺显示字段
            //字段+条件不能为空
            var fcol_index = fcolobj.get(0).selectedIndex;
            var fcol_label = fcolobj.get(0).options[fcol_index].text;
            var isempty = false;
            //选择字段不能为空
            if (!emptyCheck("fcol"+columnIndex," "+arrJsPopLabel['SelectField'],"text")){
                showAsTiledobj.prop('checked',false);
                if (eType === 'click'){
                    return false;
                }
                isempty = true;
            }
            //选择条件不能为空
            if (!emptyCheck("fop"+columnIndex,fcol_label+' '+arrJsPopLabel['OPTIONS']+' ',"text")){
                showAsTiledobj.prop('checked',false);
                if (eType === 'click'){
                    return false;
                }
                isempty = true;
            }
            if (eType === 'change'){//已平铺字段 改变字段或条件为空
                var lastColumnname = Object.keys(that.tiledColumnArr).find(key => that.tiledColumnArr[key] === columnIndex);
                ld.each(groupColumnIndexArr,function (index,tmp_columnIndex){
                    var tmp_fcolObj = that.divobj.find('#fcol'+tmp_columnIndex);
                    if (tmp_columnIndex != that.tiledColumnArr[lastColumnname] && tmp_fcolObj.val() == lastColumnname){
                        that.divobj.find('#showAsTiled_'+tmp_columnIndex).prop('checked',false);
                        that.divobj.find('#showAsTiledDiv_'+tmp_columnIndex).show();
                    }
                });
                if (isempty || (that.tiledColumnArr.hasOwnProperty(fcol_value) && that.tiledColumnArr[fcol_value] != columnIndex)){
                    delete that.tiledColumnArr[lastColumnname];
                    that.advanceTiledObj.delAdvanceFilterRow(lastColumnname);
                    that.ableColumnCondition(columnIndex);
                    that.advanceTiledObj.saveAdvanceTiled();
                    if (showHideTiledBtn_divobj.length > 0 && showHideTiledBtn_divobj.data('status') == 'hidden'){
                        showHideTiledBtn_divobj.trigger('click');
                    }
                    //字段不可重复平铺
                    if (that.tiledColumnArr.hasOwnProperty(fcol_value) && that.tiledColumnArr[fcol_value] != columnIndex){
                        showAsTiledDivobj.hide();
                        showAsTiledobj.prop('checked',false);
                    }
                    return false;
                }
            }
            var groupindex = that.divobj.find('[tag=conditionColumn][columnindex='+columnIndex+']').attr('groupindex');
            var fconobj = that.divobj.find('#fcon'+columnIndex);
            var columncondition = fconobj.length > 0 ? 'and' : '';

            var columninfo = that.checkAdvancedFilterRow(columnIndex);
            if (eType == 'click'){//点击平铺checkbox
                that.tiledColumnArr[fcol_value] = columnIndex;
                that.advanceTiledObj.addAdvanceFilterRow(columninfo);
                that.disableColumnCondition(columnIndex)
            }else {//切换字段或条件
                columninfo.value = '';
                columninfo.valueLabel = '';
                var last_columnname = Object.keys(that.tiledColumnArr).find(key => that.tiledColumnArr[key] === columnIndex);
                delete that.tiledColumnArr[last_columnname];
                that.tiledColumnArr[fcol_value] = columnIndex;
                that.advanceTiledObj.changeAdvanceFilterRow(last_columnname,columninfo);
            }
            if (showHideTiledBtn_divobj.length > 0 && showHideTiledBtn_divobj.data('status') == 'hidden'){
                showHideTiledBtn_divobj.trigger('click');
            }

            //其他相同字段去除平铺checkbox
            ld.each(groupColumnIndexArr,function (index,tmp_columnIndex){
                var tmp_fcolObj = that.divobj.find('#fcol'+tmp_columnIndex);
                if (tmp_columnIndex != that.tiledColumnArr[fcol_value] && tmp_fcolObj.val() == fcol_value){
                    that.divobj.find('#showAsTiled_'+tmp_columnIndex).prop('checked',false);
                    that.divobj.find('#showAsTiledDiv_'+tmp_columnIndex).hide();
                }
            });
        }else {
            if (that.tiledColumnArr.hasOwnProperty(fcol_value) && eType === 'click'){//取消选中平铺checkbox
                that.advanceTiledObj.delAdvanceFilterRow(fcol_value);
                delete that.tiledColumnArr[fcol_value];
                that.ableColumnCondition(columnIndex);
                ld.each(groupColumnIndexArr,function (index,tmp_columnIndex){
                    var tmp_fcolObj = that.divobj.find('#fcol'+tmp_columnIndex);
                    if (tmp_fcolObj.val() == fcol_value){
                        that.divobj.find('#showAsTiled_'+tmp_columnIndex).prop('checked',false);
                        that.divobj.find('#showAsTiledDiv_'+tmp_columnIndex).show();
                    }
                });
                if (showHideTiledBtn_divobj.length > 0 && showHideTiledBtn_divobj.data('status') == 'hidden'){
                    showHideTiledBtn_divobj.trigger('click');
                }
            }else if (eType === 'change'){//切换字段
                if (that.tiledColumnArr.hasOwnProperty(fcol_value)){
                    that.divobj.find('#showAsTiledDiv_'+columnIndex).hide();
                }else {
                    that.divobj.find('#showAsTiledDiv_'+columnIndex).show();
                }
                that.divobj.find('#showAsTiled_'+columnIndex).prop('checked',false);
            }
        }
        //保存平铺字段
        if (eType === 'click' || (eType === 'change' && checkBoxValue )){
            that.advanceTiledObj.saveAdvanceTiled();
        }

    }


    //判断删除是否含有平铺
    this.checkHaveTiledRow = function (groupIndex,columnIndex) {
        return new Promise((resolve, reject) => {
            var columnRows = !columnIndex ? that.divobj.find('[tag=showAsTiled]') : that.divobj.find('#showAsTiled_'+columnIndex);
            if (columnRows.length == 0){
                resolve();
                return false;
            }
            var flag = true;
            columnRows.each((index, row) => {
                if(ld(row).prop('checked')) {
                    flag = false;
                }
            })
            if(flag) {
                resolve();
            }
            else {
                MessagePopup.TipTwo_warning(arrJsPopLabel['IsNotDelAdvanceTiledRow']);
                //确定按钮
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    columnRows.each((index, row) => {
                        if(ld(row).prop('checked')) {
                            var tmp_columnindex = ld(row).attr('columnindex');
                            var tmp_columnname = that.divobj.find('#fcol'+tmp_columnindex).val();
                            delete that.tiledColumnArr[tmp_columnname];
                            ld.each(that.column_index_array[that.tiledGroupIndex],function (index,tmp_columnIndex){
                                var tmp_fcolObj = that.divobj.find('#fcol'+tmp_columnIndex);
                                if (tmp_fcolObj.val() == tmp_columnname){
                                    that.divobj.find('#showAsTiled_'+tmp_columnIndex).prop('checked',false);
                                    that.divobj.find('#showAsTiledDiv_'+tmp_columnIndex).show();
                                }
                            });
                            that.advanceTiledObj.delAdvanceFilterRow(tmp_columnname);
                        }
                    })
                    that.advanceTiledObj.saveAdvanceTiled();
                    resolve();
                });
                //取消按钮
                ld('input[tagclick="msgConfirmCancel"]').unbind('click').on('click', function () {
                    reject();
                });
            }
        })
    }

    //固定条件行筛选条件
    this.disableColumnCondition  = function (columnIndex) {
        var conditionObj = that.divobj.find('#fcon'+columnIndex);
        conditionObj.attr('disabled', true);
        conditionObj.css('cursor', 'not-allowed');
    }

    //取消固定条件行筛选条件
    this.ableColumnCondition  = function (columnIndex) {
        var conditionObj = that.divobj.find('#fcon'+columnIndex);
        conditionObj.removeAttr('disabled');
        conditionObj.css('cursor', '');
    }

    //筛选条件 或无平铺 且有平铺
    this.changeColumnCondition = function (columnIndex) {
        var fConObj = that.divobj.find(`#fcon${columnIndex}`),
            conVal = fConObj.val(),
            showDiv = that.divobj.find(`#showAsTiledDiv_${columnIndex}`),
            showBtn = that.divobj.find(`#showAsTiled_${columnIndex}`);
        if(conVal === 'and') {
            showDiv.show()
        }
        else {
            if(showDiv.length > 0 ) {
                showDiv.hide();
                showBtn.prop('checked', false);
            }
        }
    }

    //获取条件中的平铺条件
    this.getTiledFilter = function (){
        var columns = [];
        var conditionObj = that.divobj.find('[tag=conditionColumn][groupindex='+that.tiledGroupIndex+']');
        if (conditionObj.length === 0){
            return columns;
        }
        ld.each(conditionObj,function (index,obj){
            var columnindex = ld(obj).attr('columnindex');
            var showAsTiledObj = ld(obj).find('#showAsTiled_'+columnindex);
            if (showAsTiledObj.length == 0 || !showAsTiledObj.prop('checked')){
                return true;
            }
            var columninfo = that.checkAdvancedFilterRow(columnindex);
            columns.push(columninfo);
        });
        return columns;
    }

    //重新加载平铺按钮
    that.refreshTiledBtn = function (){
        var conditionObj = that.divobj.find('[tag=conditionColumn][groupindex='+that.tiledGroupIndex+']');
        ld.each(conditionObj,function (index,obj){
            var columnIndex = ld(obj).attr('columnindex');
            var showAsTiledDivobj = ld(obj).find('[tag=showAsTiledDiv]');
            var html = '<div id="showAsTiledDiv_'+columnIndex+'" class="ld-flex-start">';
            html += '<input type="checkbox" id="showAsTiled_'+columnIndex+'" name="showAsTiled_'+columnIndex+'" tag="showAsTiled" columnindex="'+columnIndex+'">';
            html += '<label style="padding-left: 5px;" >'+arrJsPopLabel['Tile']+'</label>';
            html += '</div>';
            showAsTiledDivobj.html(html);
            ld(obj).find('#showAsTiled_'+columnIndex).off('click').on('click',function (){
                that.changeShowTiledColumn(columnIndex,'click');
            });
        })

    }

    //清空所有筛选值
    this.clearAllFilterValue = function (){
        ld.each(that.column_index_array,function (groupindex,columnArr){
            ld.each(columnArr,function (index,columnindex) {
                var fvalObj = that.divobj.find('#fval'+columnindex);
                if(fvalObj.length > 0){
                    fvalObj.val('');
                }
                var fval_extObj = that.divobj.find('#fval_ext'+columnindex);
                if(fval_extObj.length > 0){
                    fval_extObj.val('');
                }
                var type = fvalObj.data('type');
                if (type == 'select2'){
                    fvalObj.val([]).select2(that.multiSettingsInfo);
                    fvalObj.next().attr('delete','yes');
                }else if (type == 'user'){
                    that.clearScopeUser(columnindex);
                }

            })
        })
    }


    /*
    //特殊模块 加载字段对应的条件
    this.updateRelFieldOptions = function (sel, opSelName){

    }

    //特殊模块
    this.searchReport = function (event,type){
        var e = event || window.event;
        if(e.keyCode == 13){
            generateReport(1);
        }
    }

    //特殊模块
    this.searchUseReport = function (event){
        var e = event || window.event;
        if(e.keyCode == 13){
            generateReport(this);//??
        }
    }
    */

}
/*
// ljj 2024-10-18 XUQIU20240820-05 【弹出框规范】高级查找界面优化 兼容
function New_checkAdvancedFilter() {
    var popupobj = CrmPopup.getPopupObj('last');
    if (popupobj.advanceFilter == 'yes' && popupobj.advanceFilterObj != undefined) {
        return popupobj.advanceFilterObj.checkAdvancedFilter();
    }
}
function checkAdvancedFilter() {
    var popupobj = CrmPopup.getPopupObj('last');
    if (popupobj.advanceFilter == 'yes' && popupobj.advanceFilterObj != undefined) {
        return popupobj.advanceFilterObj.checkAdvancedFilter();
    }
}*/



