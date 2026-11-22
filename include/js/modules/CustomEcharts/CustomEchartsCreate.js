if(ld==undefined){
    var ld = $;
}
function CustomEchartsCreate(){
    this.popupobj = "";
    this.divid = "";
    var that = this;
    this.mainmodule = '';
    this.relatedModules = '';
    this.selectedModules = {};//已选中的模块们
    this.relatedModuleOptions = '';//options
    this.groupByFieldRes = {};//统计维度options
    this.timeFieldRes = {};//首页时间条件options
    this.countFieldRes = {};//计数字段 options
    this.searchFieldRes = {};//高级查询条件options
    this.sumFieldRes = {};//求和、求均值字段options
    this.mode = "";
    this.chart_info = "";
    this.report_id = 0;
    this.pageto_module = 'ReportAnalysis';//报表分析模块  现在确定是报表分析模块  写死
    this.init = function(mode){
        that.mode = mode;
        if(mode=='detail'){
            that.getReportInfo(that.report_id,'no','no','');
        }
        that.changeModuleNames();
        if(mode=='edit'||mode=='create') {
            totalColumnListTableObj.init(that);
        }
        conditionColumnListTableObj.init(that);
        that.chartTypeChange(that.chart_type);
        that.setEvent();
    }
    this.setPopupobj = function(popupobj){
        that.popupobj = popupobj;
    }
    this.setDivid = function(divid){
        that.divid = divid;
    }
    this.setReportId = function(report_id){
        that.report_id = report_id;
    }
    this.setChartType = function(chart_type){
        that.chart_type = chart_type;
    }
    this.setMainModule = function(mainmodule){
        that.mainmodule = mainmodule;
    }
    //新建模块图表
    this.createChart = function(report_id,frompage,parent_id) {
        var tmpwidth = ld(window).width();//全屏宽度
        var module = 'CustomEcharts';
        var Popupobj = CrmPopup.load(arrJsPopLabel['CREATENEWECHARTS'],  '',"", tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['LBL_CLOSE']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.center();
        that.setPopupobj(Popupobj);
        that.setDivid(Popupobj.divid);
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SelfDefinedReport&function_name=newChart&report_id='+report_id+'&frommodule='+that.frommodule;
        if(parent_id!=undefined){
            url += '&parent_id='+parent_id;
        }
        ld.ajax({
            url: url,
            type: 'POST',
            dataType: 'json',
            async: true,
            timeout: 20000,
            success: function (data) {
                if (data.code == 1) {
                    that.chart_info = data.result.chart_info;
                    Popupobj.setParams(arrJsPopLabel['CREATENEWECHARTS'], that.saveAndPreview, '', tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['LBL_CLOSE']);
                    CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);
                    //设置表头
                    if (report_id > 0) {
                        that.setReportId(report_id);
                        that.setChartType(that.chart_info.chart_type);
                        that.frompage = frompage;
                        that.init("edit");
                    }else{
                        that.init("create");
                    }
                    CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
                    ld('#' + Popupobj.divid).find('#analysisfolder_id').select2({
                        width: '90%',
                        closeOnSelect: true
                    });
                    //edit: xll BUG0062038 自定义统计图表，“统计图配置”页签，下拉框没有搜索功能
                    var selectobj = ld("#" + Popupobj.divid + " select[fieldtype=selecttype]");
                    ld.each(selectobj, function(i,tmpselectobj){
                        var tmpobj = ld(tmpselectobj);
                        if(tmpobj.length>0&&tmpobj!=undefined){
                            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
                            cls_resetComboxHtmlobj.setPopupObj(Popupobj);
                            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,200);
                        }
                    })
                    //selectobj.siblings().find("div[name = dv_chzn_groupbytype]").hide();
                    //selectobj.siblings().find("div[name = dv_chzn_groupbytype_second]").hide();
                }
            }
        });
    }
    this.setEvent = function() {
        ld('#'+that.divid).find('.chart-name').unbind('click').bind('click',function(){
            ld('#'+that.divid).find('#left_chart_nav li').removeClass('active');
            ld(this).parents('li').addClass('active');
        });
        //标签切换事件
        ld('#'+that.divid).find('.change_tab').unbind('click').bind('click',function(){
            that.changeTab(ld(this));
        });
        ld('#'+that.divid).find('#toSearch').unbind('click').bind('click',function() {
            that.getReportInfo(that.report_id,'yes','no','');
        });
        ld('#' + that.divid).find('#toggleSearch').unbind('click').bind('click', function () {
            ld('#' + that.divid).find('#searchCondition').slideToggle(1000);
            var prop = ld(this).prop('checked');
            var isshow_search = prop ? 'yes' : 'no';
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SelfDefinedReport";
            var param = "is_ajax=yes&function_name=changeReportStatus&reportid=" + that.report_id + '&isshow_search=' + isshow_search;
            ldAjaxNoProgress(url, param, function (res) {
                console.log('修改成功');
            });
        });
        ld('#' + that.divid).find('#toggleShowTable').unbind('click').bind('click', function () {
            ld('#' + that.divid).find('#chartTable_'+that.report_id).slideToggle(1000);
            var prop = ld(this).prop('checked');
            var isshow_table = prop ? 'yes' : 'no';
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SelfDefinedReport";
            var param = "is_ajax=yes&function_name=changeReportStatus&reportid=" + that.report_id + '&isshow_table=' + isshow_table;
            ldAjaxNoProgress(url, param, function (res) {
                console.log('修改成功');
            });
        });
        //主模块切换事件
        ld('#'+ that.divid).find('#mainmodule').unbind('change').bind('change', function () {
            that.changeModuleNames();
        });
        //添加组合条件的事件
        ld('#' + that.divid).find('#addNewConditionGroup').unbind('click').bind('click', function () {
            that.addNewConditionGroup(this);
        });
        //图表类型选中事件
        ld('#' + that.divid + ' #chart_type_lists .chart-type-one').unbind('click').bind('click', function () {
            var name = ld(this).attr('data-name');//图表名称
            var label = ld(this).attr('data-label');//图表label
            that.chart_type = name;
            ld('#chart_type').val(name);
            ld('#chart_type_label').text(label);
            //tab切换到【统计图设置】
            ld('.ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
            ld('#chartFormLi').addClass('ld-ui-tabs-active');
            ld('.tab-contents').hide();
            ld('#chartForm').show();
            //设置维度区块，统计字段区块title
            //line,multiple_line,bar,multiple_bar,stack_bar,line_bar
            //折线图，柱状图维度设置区块的title为【X轴（类目）】 维度设置区块title为【Y轴（数值）】 其他title为【统计维度设置】
            //simple_strip,multiple_strip,stack_strip
            //条形图统计字段区块的title为【Y轴（类目）】 统计字段区块title为【X轴（数值）】 其他title为【统计字段设置】
            //设置表头
            that.chartTypeChange(name);
            if(totalColumnListTableObj!=undefined){
                totalColumnListTableObj.init(that);
                totalColumnListTableObj.removeAllRow();
                totalColumnListTableObj.addrow(null);
            }
            if(conditionColumnListTableObj!=undefined){
                conditionColumnListTableObj.removeAllRow();
            }
        });
        //表格穿透 gotoList
        ld('#' + that.divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
            that.gotoList(this);
        });
        tooltip('.sort-tip-items', {transition: true, time: 200});
        //在PC端首页显示 选中改变事件 --zxm 20230627 去掉该设置 现在在首页按看板设置
        /*ld('#'+that.divid).find('#show_athome').unbind('change').bind('change',function(){
            var value = ld(this).prop('checked');
            if(value==true){
                ld('#'+that.divid).find('#show_athome_person_tr').show();
                ld('#'+that.divid).find('#show_athome_timecheck_tr').show();
                ld('#'+that.divid).find('#show_athome_approve_tr').show();
            }else{
                ld('#'+that.divid).find('#show_athome_person_tr').hide();
                ld('#'+that.divid).find('#show_athome_timecheck_tr').hide();
                ld('#'+that.divid).find('#show_athome_approve_tr').hide();
            }
        });*/
    }

    this.changeTab = function(obj){
        var divid = that.divid;
        //判断是否选择类型
        var chart_type = ld('#'+that.divid+' #chart_type').val();
        if(chart_type==''){
            alert('请先选择图表类型');
            return false;
        }
        let fortab = ld(obj).attr('for');
        if(fortab=='chartPreview'||fortab=='advancedSetting') {
            var report_name = ld('#'+divid+' #report_name').val();
            if (report_name == '' || report_name == undefined) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '统计图名称不能为空!');
                return;
            }
        }
        if(fortab=='advancedSetting') {
            //根据类型 高级设置的显示隐藏
            var CustomEchartsAdvancedSettingObj = new CustomEchartsAdvancedSetting();
            var AdvancedSetting = CustomEchartsAdvancedSettingObj.getShowRes(that.charttype);
            var objTd = ld('#groupby_second').parent();
            if(AdvancedSetting.groupby_second=="yes"){
                objTd.parent().show();
                objTd.show();
                objTd.prev().show();
            }else{
                objTd.parent().hide();
                objTd.hide();
                objTd.prev().hide();
            }
            conditionColumnListTableObj.chartType=that.charttype;
            conditionColumnListTableObj.init(that);
            //zxm 20230922 https://81mis.com/kfbtest/--报表分析--统计图--新建一个统计图，设置X轴与Y轴后，高级设置--排序字段没有值
            that.saveInfo(5,'no');
            //排序设置的渲染
            //that.renderSortSetting(that.report_id);
        }
        ld(obj).siblings().removeClass('ld-ui-tabs-active');
        ld(obj).addClass('ld-ui-tabs-active');
        ld('.tab-contents').hide();

        if(fortab=='chartPreview'){
            that.saveInfo(4,'no');
        }
        if(fortab=='chartFormLi'){
            that.init('edit');
        }
        ld('#'+fortab).show();
        //根据类型 高级设置的显示隐藏
        var CustomEchartsAdvancedSettingObj = new CustomEchartsAdvancedSetting();
        var AdvancedSetting = CustomEchartsAdvancedSettingObj.getShowRes(chart_type);
        ld.each(AdvancedSetting,function(index,item){
            var objTd = ld("#"+index).parent();
            if(item=="yes"){
                objTd.parent().show();
                objTd.show();
                objTd.prev().show();
            }else{
                objTd.parent().hide();
                objTd.hide();
                objTd.prev().hide();
            }
        });
    }
    this.gotoList = function(obj){
        //获取这个td是这一行的第几个
        var tdindex = ld(obj).parent().attr('tdindex');
        var seriesIndex = ld(obj).attr('seriesIndex');
        seriesIndex = seriesIndex?seriesIndex:0;
        var thobj = ld('#'+that.divid).find('#thResizable th[thindex='+tdindex+']');
        var name = thobj.text();
        var params_serialize = ld('#searchInfo').serialize();
        let url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SelfDefinedReport&function_name=setModuleSearchForChart&searchKey="+name+"&seriesIndex="+seriesIndex+"&report_id="+that.report_id+"&query_session=1&"+params_serialize;
        var fromhome='no';
        //首页的需要读取首页条件
        if(fromhome=="yes"){
            var selectuserid = ld('#selectuserid').val();	//查看范围
            var search_date = ld('.home-header-filter-select .header_value').attr('data-value');
            var search_date_custom_value = '';
            if(search_date=='custom'){
                search_date_custom_value = ld("#begin_date").val()+"~"+ ld("#end_date").val();
            }
            var approvestatus = [];
            ld('input[name="approve_header_select_value[]"]:checked').each(function(){
                approvestatus.push(obj.value);
            });
            var approve_value = 'all';
            if(approvestatus.length == 5 || approvestatus.length == 0){
                approve_value = 'all';
            }else{
                approve_value = approvestatus.join(',');
            }
            url += "&selectuserid="+selectuserid+"&search_date="+search_date+"&search_date_custom_value="+search_date_custom_value+"&approve_value="+approve_value+"&fromhome=yes"
        }
        if(typeof frommobile!='undefined' && frommobile=='yes'){
            url += '&frommobile='+frommobile;
        }
        ldAjaxNoProgress(url, {},function(res){
            //移动端'ldcrm/index.html#!/listview/' . $r_reltab . '/' . $modulelabel . '/-1/mass_remind/'.$r_related_to;
            if(typeof frommobile!='undefined' && frommobile=='yes'){
                var ids = res.result.ids;
                var mobileurl = 'http://www.51mis.cn/websaas/weixinsaas/'+wx_version+'/ldcrm/index.html#!/listview/' +mainmodule + '/' + modulelabel + '/-1/report_list/'+ids
                window.location.href = mobileurl;
            }else{
                var addurl = encodeURIComponent("&query_session=1");
                window.open('index.php?pageto_module='+mainmodule+'&pageto_action=index'+'&page_addurl='+addurl);
            }
        });
    }
    //图形类型对应页面字段显隐藏
    //name 图表类型
    this.chartTypeChange = function(name){
        switch (name) {
            case "line":
            case "multiple_line":
            case "bar":
            case "multiple_bar":
            case "bar_stack":
            case "line_bar":
                ld('#groupBySetTitle').text("X轴（类目）");
                ld('#columnsSetTitle').text("Y轴（数值）");
                break;
            case "simple_strip":
            case "multiple_strip":
            case "stack_strip":
                ld('#groupBySetTitle').text("Y轴（类目）");
                ld('#columnsSetTitle').text("X轴（数值）");
                break;
            default:
                ld('#groupBySetTitle').text("维度");
                ld('#columnsSetTitle').text("字段");
                break;
        }
        //是否可启用第二维度 simple_line,simple_strip,simple_bar,stack_bar,stack_strip可开启第二维度
        //groupby_secondcheck、groupby_second、groupbytype_second
        switch (name) {
            case "simple_strip":
            case "bar":
            case "stack_bar":
            case "stack_strip":
            case "multiple_bar":
            case "nesting_pie"://嵌套饼图
            case "multiple_dimension"://多维度散点图
                ld('#groupby_secondcheck').show();
                ld('#groupby_secondlabel').show();
                ld('#groupby_second').parent().show();
                ld('#groupbytype_second').hide();
                break;
            default:
                ld('#groupby_secondcheck').hide();
                ld('#groupby_secondlabel').hide();
                ld('#groupby_second').parent().hide();
                ld('#groupbytype_second').hide();
                break;
        }
        //是否有排序设置 饼图 漏斗图 旭日图 没有排序设置
        if(name=="pie"||name=="solid_pie"||name=="rose_pie"||name=="nesting_pie"
            ||name=="funnel"||name=="triangle"||name=="bowls"||name=="simple_sunburst"
        ){
            ld('#sortingsetHeader').hide();
            ld('#sortingset').hide();
        }else{
            ld('#sortingsetHeader').show();
            ld('#sortingset').show();
        }
    }
    //更改主模块的onchange事件
    this.changeModuleNames = function(){
        that.searchFieldRes = {};
        that.mainmodule = ld('#'+that.divid).find('#mainmodule').val();
        that.selectedModules[0] = that.mainmodule;
        //1.更改统计维度、第二统计维度的下拉框值 2.更改【选择统计模块】的下拉框值
        that.getRelatedModule();
    }
    //ajax获取相关模块数据
    this.getRelatedModule = function(){
        that.relatedModuleOptions = '';
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SelfDefinedReport&function_name=getRelatedModule';
        ldAjaxNoProgress(url,{'mainmodule':that.mainmodule},function(e){
            var relatedModule = e.result.relatedModule;
            that.relatedModules = e.result.relatedModule;
            ld.each(relatedModule,function(index,module){
                that.relatedModuleOptions += '<option value="'+module.label+'">'+module.fieldlabel+'</option>'
            });
            //主模块变更 清空字段行所有数据
            totalColumnListTableObj.removeAllRow();
            conditionColumnListTableObj.removeAllRow();
            that.setFieldsByModule(null,null);
        });
    }
    this.setFieldRes=function(rowindex){
        that.countFieldRes[rowindex] = {};
        that.sumFieldRes[rowindex] = {};
    }
    //根据所选择的主模块、统计字段处选择模块获取计算字段
    this.setFieldsByModule = function(obj,callback){
        var rowindex = 1;
        var modulename =  that.mainmodule;
        if(obj){
            //只改变本行的字段下拉框
            rowindex = ld(obj).attr('rowindex');
            modulename = ld(obj).val();
        }
        that.setFieldRes(rowindex);
        that.getFieldsByModule(modulename,
            function(listdata) {
                if(obj==null){
                    //主模块变化
                    that.groupByFieldRes = listdata.groupByFieldRes;//统计维度
                    //统计维度的渲染
                    ld('#groupby').empty().append(that.groupByFieldRes);
                    if(!empty(that.chart_info)&&!empty(that.chart_info.groupInfo)&&!empty(that.chart_info.groupInfo[0])) {
                        ld('#groupby').val(that.chart_info.groupInfo[0].groupcolumns);
                    }
                    var tmpobj = ld("#" + that.divid + " #groupby");
                    if(tmpobj.length>0){
                        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(tmpobj.attr("name"));
                        cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj,200);
                    }

                    ld('#groupby_second').empty().append(that.groupByFieldRes);
                    if(!empty(that.chart_info)&&!empty(that.chart_info.groupInfo)&&!empty(that.chart_info.groupInfo[1])) {
                        ld('#groupby_second').val(that.chart_info.groupInfo[1].groupcolumns);
                    }
                    var tmpobj2 = ld("#" + that.divid + " #groupby_second");
                    if(tmpobj2.length>0) {
                        var cls_resetComboxHtmlobj = new cls_resetComboxHtml(tmpobj2.attr("name"));
                        cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj2, 200);
                    }
                }
                that.timeFieldRes[modulename] = listdata.timeFieldRes;//时间下拉框

                //高级查找条件字段---只显示主表字段
                if(modulename==that.mainmodule){
                    that.searchFieldRes[modulename] = listdata.searchFieldRes;
                }


                //计算字段
                that.countFieldRes[rowindex][modulename] = listdata.countFieldRes;
                that.sumFieldRes[rowindex][modulename] = listdata.sumFieldRes;
                //渲染时间字段下拉框值
                //ld('#show_athome_time').empty().append(that.timeFieldRes);
                that.renderTimeCondition();
                //渲染行数据 --相关模块变动时 更改下拉框值 渲染行数据
                if(obj){
                    var trobj = Tools.getParentobjByChild(obj,'tr');
                    totalColumnListTableObj.changeSelectFields(trobj);
                    //BUG0064572  报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
                    if(ld('#'+that.divid+' #highSearch').find('tr').length==0){
                        that.addNewConditionGroup(ld('#'+that.divid+' #addNewConditionGroup'));
                    }
                }else{
                    that.getTotalColumn();
                }
            }
        );
    }
    //传入模块 查询下属字段
    this.getFieldsByModule = function(modulename,callbackfun){
        var params = '&mainmodule='+modulename+'&relatedmodule='+modulename;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SelfDefinedReport&function_name=getModuleFields';
        ldAjaxNoProgress(url,params,function(ajaxdata){
            var listdata = ajaxdata.result.list;
            callbackfun(listdata);
        });
    }
    //关联首页查询条件-时间条件
    this.renderTimeCondition = function (){
        var timeFieldRes = that.timeFieldRes;
        var timeFieldOptions = '';
        //查询现在选择到的模块
        var column_module_obj = ld('#totalColumnList').find('[tag="column_module"]');
        column_module_obj.push(ld('#mainmodule'));
        timeFieldOptions += timeFieldRes[that.mainmodule];
        ld.each(column_module_obj,function(tmpindex,moduleobj){
            var tempmodule = ld(moduleobj).val();
            if(tempmodule!=that.mainmodule){
                timeFieldOptions += timeFieldRes[tempmodule];
            }
        });
        //ld('#show_athome_time').html(timeFieldOptions);
        //var chart_info = that.chart_info;
        //if (chart_info&&chart_info.show_athome_info) {
            //var show_athome_info_columns = chart_info.show_athome_info.columns;
            //console.log(chart_info.show_athome_info);
            //ld('#show_athome_time option[value="' + show_athome_info_columns + '"]').attr('selected', true);
        //}
    }

    //统计维度change事件
    this.changeGroupBy = function(obj){
        var value = ld(obj).val();
        var type = ld(obj).find('option[value="'+value+'"]').attr('data-type');
       
        if(type=="datetime"||type=='date'){
            ld(obj).parent().next().show();
            ld(obj).removeClass('input-width-70').addClass('input-width-35');
        }else{
            ld(obj).parent().next().find('option').removeAttr('selected');
            ld(obj).parent().next().find('option[value="byField"]').attr('selected',true);
            ld(obj).parent().next().hide();
            ld(obj).removeClass('input-width-35').addClass('input-width-70');
        }
        //统计维度变化  导致变化排序设置变化--不要了 排序设置挪到高级查找
        /**var columns =  ld(obj).val();
        var groupbytype = '';
        var columns_label =  ld(obj).find('option:selected').text();
        if(type=="datetime"||type=='date'){
            groupbytype = ld(obj).next().val();
            columns_label = ld(obj).next().find('option:selected').text();
            columns += '-'+groupbytype;
            columns_label += '-'+columns_label;
        }
        ld('#'+that.divid).find('[tag=sortColumnList] [tag=sortcolumns] option[sorttype=bycolumnname]')[0].attr('value',columns).text(columns_label)*/
    }
    //渲染一行列数据
    this.getTotalColumn = function (){
        var mode = that.mode;
        var chart_info = that.chart_info;
        var countFieldRes = that.countFieldRes;
        var sumFieldRes = that.sumFieldRes;
        //渲染统计字段行
        if (mode == "edit"||mode == "detail") {
            if(!empty(chart_info)&&!empty(chart_info.totalColumns)&&mode == "edit") {
                var totalColumns = chart_info.totalColumns;
                var totalColumnsLength = totalColumns.length;
                if (totalColumnsLength > 0) {
                    ld.each(totalColumns, function (index, item) {
                        totalColumnListTableObj.addrow(item);
                    });
                } else {
                    totalColumnListTableObj.addrow(null);
                }
            }
            if(!empty(chart_info)&&!empty(chart_info.reportConditions)) {
                //渲染条件
                var reportConditions = chart_info.reportConditions;
                if (reportConditions.length > 0) {
                    ld.each(reportConditions, function (index, item) {
                        conditionColumnListTableObj.addrow(item, item.groupid, null);
                        if (reportConditions.length - 1 == index) {
                            //最后个空行增加新条件的按钮
                            conditionColumnListTableObj.addrow({'type': 'emptyline'}, item.groupid, null);
                        }
                    });
                }else{
                    //BUG0064572  报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
                    if(ld('#'+that.divid+' #highSearch').find('tr').length==0){
                        that.addNewConditionGroup(ld('#'+that.divid+' #addNewConditionGroup'));
                    }
                }
                conditionColumnListTableObj.setTableEvent();
            }else{
                //BUG0064572 报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
                if(ld('#'+that.divid+' #highSearch').find('tr').length==0){
                    that.addNewConditionGroup(ld('#'+that.divid+' #addNewConditionGroup'));
                }
            }

            //统计维度的渲染的取值
            if (chart_info.groupInfo != null && chart_info.groupInfo.length == 1) {
                //统计维度的值渲染
                var groupcolumns = chart_info.groupInfo[0].groupcolumns;
                ld('#groupby option[value="' + groupcolumns + '"]').attr('selected', true);
                var tmpobj = ld("#" + that.divid + " #groupby");
                if(tmpobj.length>0) {
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(tmpobj.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj, 200);
                }
            }
            if (chart_info.groupInfo != null && chart_info.groupInfo.length == 2) {
                //统计维度的值渲染
                var groupcolumns = chart_info.groupInfo[0].groupcolumns;
                ld('#groupby option[value="' + groupcolumns + '"]').attr('selected', true);
                var groupcolumnsSecond = chart_info.groupInfo[1].groupcolumns;
                ld('#groupby_second option[value="' + groupcolumnsSecond + '"]').attr('selected', true);
                that.changeGroupBy(ld('#groupby_second'));//第二统计维度的 类型
                var tmpobj1 = ld("#" + that.divid + " #groupby");
                if(tmpobj1.length>0) {
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(tmpobj1.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj1, 200);
                }
                var tmpobj2 = ld("#" + that.divid + " #groupby_second");
                if(tmpobj2.length>0) {
                    var cls_resetComboxHtmlobj = new cls_resetComboxHtml(tmpobj2.attr("name"));
                    cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(tmpobj2, 200);
                }
            }

        } else if (mode == 'init') {
            //BUG0064572  报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
            if(ld('#'+that.divid+' #highSearch').find('tr').length==0){
                that.addNewConditionGroup(ld('#'+that.divid+' #addNewConditionGroup'));
            }
            totalColumnListTableObj.addrow(null);
        } else {
            var trTotalColumnList = ld('#totalColumnList').find("tr[tag='trTotalColumnList']");
            if(trTotalColumnList.length>0){
                trTotalColumnList.each(function (idx, itm) {
                    var totaltype = ld(itm).find('select[tag="total_type"]').val();
                    if (totaltype == 'count') {
                        ld(itm).find('select[tag="field"]').html(countFieldRes);
                    } else {
                        ld(itm).find('select[tag="field"]').html(sumFieldRes);
                    }
                });
            }

            totalColumnListTableObj.addrow(null);
            totalColumnListTableObj.setTableEvent();
            //BUG0064572  报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
            if(ld('#'+that.divid+' #highSearch').find('tr').length==0){
                that.addNewConditionGroup(ld('#'+that.divid+' #addNewConditionGroup'));
            }
            conditionColumnListTableObj.setTableEvent();
        }
    }

    this.saveAndPreview = function(){
        window.scrollTo(0, document.body.scrollHeight)
        that.saveInfo(4,'yes');
        return false;
    }
    this.saveAndPreview.funname='this.saveAndPreview';
    this.saveInfo = function(step,isfinish){
        var params = ld('#'+that.divid+' #chartInfoForm' ).serialize();
        //报表名称不能为空
        var report_name = ld('#'+that.divid +' #report_name').val();
        if(report_name==''||report_name==undefined){
            RemindsMsg("","LdPopWidth400px","","yes","yes",'统计图名称不能为空!');return;
            // alert("统计图名称不能为空!");return;
        }
        //groupby字段的bigtype值
        var groupby_secondcheck = ld('#'+that.divid +' #groupby_secondcheck').prop('checked');
        var groupbyvalue = ld('#'+that.divid +' #groupby').val();
        var groupbybigtype = ld('#'+that.divid +' #groupby option[value="'+groupbyvalue+'"]').attr('data-type');
        var groupby_secondvalue = ld('#'+that.divid +' #groupby_second').val();
        var groupby_secondbigtype = ld('#'+that.divid +' #groupby_second option[value="'+groupby_secondvalue+'"]').attr('data-type');
        if((groupbybigtype=='date'||groupbybigtype=="datetime")&&groupby_secondcheck==true&&(groupby_secondbigtype=='date'||groupby_secondbigtype=="datetime")){
            RemindsMsg("","LdPopWidth400px","","yes","yes",'两个统计维度不能同时为时间类型字段!');return;
        }
       var chartype=ld('#'+that.divid +' #chartInfoForm  input[name=chart_type]').val();
      
        if(chartype=='basic_scatter'||chartype=='multiple_dimension')
        {
            if(ld('#'+that.divid +' #columnList').find("tr[tag=trTotalColumnList]").length!=2)
            {
                RemindsMsg("","LdPopWidth400px","","yes","yes",'散点图表格统计字段必须是两行!');return;
            }
        }
        //创建链接模块
        let linkmodulecheck = ld('#'+that.divid +' #linkmodulecheck').prop('checked');
        if(linkmodulecheck){
            params += '&linkmodulecheck=yes';
        }else{
            params += '&linkmodulecheck=no';
        }

        //是否显示百分比-饼图可勾选
        //var show_percent = ld('#showPercent').prop('checked');
        params += '&is_ajax=yes&step='+step+'&groupbybigtype='+groupbybigtype+'&groupby_secondbigtype='+groupby_secondbigtype;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SelfDefinedReport&function_name=saveReportInfo';
        ldAjaxNoProgress(url,params,function(res){
            if(res.code==1){
                //wyt 220817 XUQIU1000504 自定义统计图表或报表的查看界面增加快捷编辑按钮
                var chart_info = res.result.chart_info;
                ld('#'+that.divid +' #report_id').val(chart_info.report_id);
                if(isfinish=='yes') {
                    var popupobj = CrmPopup.getPopupObj('last');
                    popupobj.CancelEvent();
                    if(that.frompage == "fromdetail"){
                        that.init();
                        customRenderChart.setChart(chart_info,chart_info.report_id,'no');
                        ld('#'+that.divid).find('#chartTable_'+chart_info.report_id).html(chart_info.table);
                        //表格穿透 gotoList
                        ld('#' + that.divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
                            that.gotoList(this);
                        });
                        that.setScroll(chart_info);
                    }else{
                        if(that.mode!='detail'&&that.mode!='edit'){
                            ReportAnalysisObj.getReportList(0, 'init');
                        }
                    }
                }
                else{
                    that.renderSortSetting(chart_info.report_id);//排序设置
                    customRenderChart.setChart(chart_info,0,'no');
                    ld('#'+that.divid).find('#chartTable_'+chart_info.report_id).html(chart_info.table);
                    //表格穿透 gotoList
                    ld('#' + that.divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
                        that.gotoList(this);
                    });
                    that.setScroll(chart_info);
                }
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",res.msg);
            }
        });
    }

    this.getReportInfo = function(report_id,is_search,fromhome,homeParam){
        var param = ld('#searchInfo').serialize();
        if(fromhome=='yes'&&homeParam!=''){
            param+='&'+homeParam+'&fromhome=yes';
        }
        param += '&is_ajax=yes&step=0&function_name=getChartData&is_ajax=yes&report_id='+that.report_id;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SelfDefinedReport&is_search='+is_search;
        ldAjaxNoProgress(url,param,function (e) {
            that.chart_info = e.result.list;
            customRenderChart.setChart(e.result.list,report_id,fromhome);
            var chart_info = e.result.list;
            ld('#chartTable_'+report_id).html(chart_info.table);
            //表格穿透 gotoList
            var popupobj = CrmPopup.getPopupObj("last");
            var divid ='searchInfo';
            if(popupobj){
                divid = popupobj.divid;
            }
            ld('#' + divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
                that.gotoList(this);
            });
            if(homeParam==''||fromhome!='yes') {
                that.setScroll(chart_info);
            }
            if(is_search != 'yes'){
                ld('#mainmodule').val(chart_info.mainmodule);
            }
        });
    }
    this.setScroll = function(chart_info){
        var windowWidth = CrmPopup.getClientWidth();
        if(typeof frommobile!='undefined' && frommobile=='yes'){
            //移动端  zxm20221019
            ld("#"+that.divid+" #div_thResizableContent").css('width',(windowWidth-20)+'px');//宽度
            ld("#"+that.divid+" #thResizable").css('margin','0 auto');
        }else{
            ld("#"+that.divid+" #div_thResizableContent").css('width',(windowWidth*0.8)+'px');//宽度
        }
        //宽度
        ld("#"+that.divid+" #thResizable").css('width',(parseInt(chart_info.th_nums*100)+17)+'px');
        ld("#"+that.divid+" #thResizable").css('min-width',(windowWidth*0.8-17)+'px');
    }

    //添加新的组合条件
    this.addNewConditionGroup = function(obj){
        var conditiontr = ld('#'+that.divid+' #highSearch').children();
        var groupid_before = ld(obj).attr('data-groupid');
        var groupid = parseInt(groupid_before)+1;
        ld(obj).attr('data-groupid',groupid);
        if(conditiontr.length >=2){
            var select = '<tr tag="group" groupid="'+groupid+'">\n' +
                '<td colspan="5">' +
                '<div style="display: flex;justify-content: center">' +
                '<input type="hidden" name="groupid" value="'+groupid+'">'+
                '<select style="width:50px;" class="custom-select detailedViewTextBox" id="" name="group_condition['+groupid_before+']">\n' +
                '<option value="and">且</option>\n' +
                '<option value="or">或</option>\n' +
                '</select></div></td><td><a class="icon-homeimg icon-close" href="javascript:;" title="'+arrJsPopLabel['DELETECOMBINATION'] +'" tag="groupdelete"></a></td></tr>';
            ld('#'+that.divid+' #highSearch').append(select);
        }

        conditionColumnListTableObj.addrow({'groupid':groupid,type:'columns'},groupid,null);
        //新条件按钮
        var addBtn = '<tr tag="addColumnsCondition" groupid="'+groupid+'">\n' +
            '<td></td><td align="left">\n' +
            '<a data-index="0" tag="addrow">'+arrJsPopLabel['NEW2']+'  </a>\n' +
            '</td><td></td><td></td><td></td><td></td>\n' +
            '</tr>';
        ld('#'+that.divid+' #highSearch').append(addBtn);
        conditionColumnListTableObj.resetRowindex();
        conditionColumnListTableObj.setTableEvent();
    }

    //排序设置
    this.renderSortSetting = function(report_id){
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=setReportSortingMethodOfChart&report_id='+report_id;
        ldAjaxNoProgress(url,{},function(res){
            var sorting_list = res.result.sorting_list;
            var columns_list = res.result.columns_list;
            that.column_list = columns_list;
            var column_list_length = columns_list.length;
            var sorting_list_length = sorting_list.length ;
            var sorting_html = '';
            if(sorting_list_length>0){
                ld.each(sorting_list,function(index,item){
                    sorting_html +='<tr tag="trSortColumnList" rowindex="'+index+'">\n' +
                    '               <td class="DetailedTd1Label" align="right" tag="line">#'+(parseInt(index)+1)+'</td>\n' +
                    '                <td align="left">\n' +
                    '                    <select class="commonTextBoxPop" name="sorttype[]" tag="sorttype_change">\n' +
                    '                        <option '+ (item.sorttype=='bycolumnname' ?'selected' :'') +' value="bycolumnname">'+arrJsPopLabel['Groupfieldsby']+'</option>\n' +
                    '                        <option '+ (item.sorttype=='byresult' ?'selected' :'') +' value="byresult">'+arrJsPopLabel['Bystatisticalresult']+'</option>\n' +
                    '                    </select>\n' +
                    '                </td>\n' +
                    '                <td align="center">\n' +
                    '                    <select class="commonTextBoxPop" name="sortcolumns[]" tag="sortcolumns">\n';

                    ld.each(columns_list,function(i,column){
                        sorting_html +='<option sorttype="'+column.sorttype+'" '+ (item.columnmodule_columns==column.columns ?'selected' :'') +' value="'+column.columns+'">'+column.tdheader_label+'</option>\n';
                    });
                    sorting_html +='</select></td>\n' +
                    '                <td align="center">\n' +
                    '                    <select class="commonTextBoxPop" name="sortmethod[]" tag="sortmethod">\n' +
                    '                        <option  '+ (item.sortmethod=='asc' ?'selected' :'') +' value="asc">'+arrJsPopLabel['Ascending']+'</option>\n' +
                    '                        <option  '+ (item.sortmethod=='desc' ?'selected' :'') +' value="desc">'+arrJsPopLabel['Descending']+'</option>\n' +
                    '                    </select>\n' +
                    '                </td>\n' +
                    '                <td align="left"><a href="javascript:;" tag="deleted_sort">'+arrJsPopLabel['DELETE']+'</a></td>\n' +
                    '            </tr>'
                });
            }
            //if(sorting_list_length<column_list_length){
            //排序设置个数 小于 字段个数 才可以新增排序
            sorting_html += '<tr>\n' +
                '            <td class="DetailedTd1Label" align="right"><a href="javascript:;" tag="add_sort">+'+arrJsPopLabel['NEW']+'</a></td>\n' +
                '            <td></td>\n' +
                '            <td></td>\n' +
                '            <td></td>\n' +
                '            <td></td>\n' +
                '        </tr>';
            //}

            ld('#'+that.divid).find('[tag=sortColumnList]').html(sorting_html);
            //绑定事件--排序类型切换
            ld('#'+that.divid).find('[tag=sorttype_change]').unbind('change').bind('change',function(){
                that.sorttype_change(this);
            });
            //绑定事件--添加排序的事件
            ld('#'+that.divid).find('[tag=add_sort]').unbind('click').bind('click',function(){
                that.add_sort(this,columns_list);
            });
            //绑定事件-删除排序的事件
            ld('#'+that.divid).find('[tag=deleted_sort]').unbind('click').bind('click',function(){
                that.deleted_sort(this);
            });
        });
    }
    //排序类型change事件
    this.sorttype_change = function(obj){
        var trobj =  Tools.getParentobjByChild(ld(obj),'tr');
        var sorttype = ld(obj).val();
        ld(trobj).find('[tag=sortcolumns] option').hide();
        ld(trobj).find('[tag=sortcolumns] option[sorttype='+sorttype+']').show();
        ld(trobj).find('[tag=sortcolumns] option').removeAttr('selected');
        ld(trobj).find('[tag=sortcolumns] option[sorttype='+sorttype+']:first').prop('selected','selected');//默认选中第一个
    }
    //增加一行排序事件的事件
    this.add_sort = function(obj,columns_list){
        var trobj =  Tools.getParentobjByChild(ld(obj),'tr');
        var sorting_html ='<tr tag="trSortColumnList" rowindex="0">\n' +
            '               <td class="DetailedTd1Label" tag="line" align="right">#</td>\n' +
            '                <td align="left">\n' +
            '                    <select class="commonTextBoxPop" name="sorttype[]" tag="sorttype_change">\n' +
            '                        <option selected value="bycolumnname">按分组字段值</option>\n' +
            '                        <option value="byresult">按统计结果值</option>\n' +
            '                    </select>\n' +
            '                </td>\n' +
            '                <td align="center">\n' +
            '                    <select class="commonTextBoxPop" name="sortcolumns[]" tag="sortcolumns">\n';

        ld.each(columns_list,function(i,column){
            var display_css = " selected ";
            if(column.sorttype!="bycolumnname"){
                display_css = 'style="display:none;"';
            }
            sorting_html +='<option '+display_css+' sorttype="'+column.sorttype+'" value="'+column.columns+'">'+column.tdheader_label+'</option>\n';
        });
        sorting_html +='</select></td>\n' +
            '                <td align="center">\n' +
            '                    <select class="commonTextBoxPop" name="sortmethod[]" tag="sortmethod">\n' +
            '                        <option  value="asc">升序</option>\n' +
            '                        <option  value="desc">降序</option>\n' +
            '                    </select>\n' +
            '                </td>\n' +
            '                <td align="left"><a href="javascript:;" tag="deleted_sort">删除</a></td>\n' +
            '            </tr>';
        ld(trobj).before(sorting_html);

        that.resetSortRowindex();
        //绑定事件--排序类型切换
        ld('#'+that.divid).find('[tag=sorttype_change]').unbind('change').bind('change',function(){
            that.sorttype_change(this);
        });
        //绑定事件-删除排序的事件
        ld('#'+that.divid).find('[tag=deleted_sort]').unbind('click').bind('click',function(){
            that.deleted_sort(this);
        });
    }
    //删除一个排序设置
    this.deleted_sort = function(obj){
        var trobj =  Tools.getParentobjByChild(ld(obj),'tr');
        ld(trobj).remove();
        that.resetSortRowindex();
    }
    //重设排序方式每一行的index
    this.resetSortRowindex=function(){
        var trobjs=ld('#'+that.divid).find("tr[tag='trSortColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
            ld(trobj).find('[tag=line]').text('#'+rowindex);
        });
    }
}
var CustomEchartsCreateObj = new CustomEchartsCreate();

var selfDefinedReportInfo = {};
//首页组件需要用到这个
selfDefinedReportInfo.search = function(report_id,is_search,fromhome,homeParam){
    var pageto_module = 'ReportAnalysis';
    var scopeType = ld('#HomeSmOwnerSearchScope').val();	//查看范围类型
    var param = ld('#searchInfo').serialize();
    if(fromhome=='yes'&&homeParam!=''){
        param+='&'+homeParam+'&fromhome=yes';
        param+='&'+homeParam+'&fromhome=yes';
        var boardstuffid=0;
        if(ld('#stuff_charts_'+report_id).data('boardstuffid')>0){
            boardstuffid = ld('#stuff_charts_'+report_id).data('boardstuffid');
            param += '&boardstuffid=' + boardstuffid;
        }
    }
    param += '&is_ajax=yes&step=0&function_name=getChartData&is_ajax=yes&report_id='+report_id+'&scopeType='+scopeType;
    var url = 'index.php?module='+pageto_module+'&action='+pageto_module+'Ajax&file=SelfDefinedReport&is_search='+is_search;
    ldAjaxNoProgress(url,param,function (e) {
        customRenderChart.setChart(e.result.list,report_id,fromhome);
        var chart_info = e.result.list;
        ld('#chartTable_'+report_id).html(chart_info.table);
        //表格穿透 gotoList
        var popupobj = CrmPopup.getPopupObj("last");
        var divid ='searchInfo';
        if(popupobj){
            divid = popupobj.divid;
        }
        ld('#' + divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
            CustomEchartsCreateObj.gotoList(this);
        });
        if(homeParam==''||fromhome!='yes') {
            CustomEchartsCreateObj.setScroll(chart_info);
        }
        if(is_search != 'yes'){
            ld('#mainmodule').val(chart_info.mainmodule);
        }
    });
}