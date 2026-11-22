if(ld==undefined){
    var ld = $;
}
function CustomEchartsSqlCreate(){
    this.popupobj = "";
    this.divid = "";
    this.report_id = 0;
    var that = this;
    this.report_type='sqlchart';
    this.chart_type='line';
    this.chart_info={};
    this.sqlColumnsArr='';//sql解析出来的字段list
    this.sqlColumnsOptions='';//sql解析出来的字段option
    this.pageto_module = 'ReportAnalysis';//现在只有报表分析模块了   直接写死
    this.homeparams = '';
    this.init = function(mode){
        that.mode = mode;
        if(mode=='edit'){
            var option_columnlist = '';//字段option 列表
            ld.each(that.sqlColumnsArr,function(index,column){
                option_columnlist += '<option value="'+column.id+'">'+column.column_label+'</option>';
            });
            CustomEchartsSqlColumnsObj.chart_type=that.chart_type;
            CustomEchartsSqlColumnsObj.sqlColumnsArr = that.sqlColumnsArr;
            CustomEchartsSqlColumnsObj.sqlColumnsOptions = option_columnlist;
            CustomEchartsSqlColumnsObj.init();
            ld.each(that.chart_info.columnInfo,function(i,item) {
                CustomEchartsSqlColumnsObj.addrow(item);
            });
        }
        if(mode=='detail'){
            that.getReportInfo();
        }
        that.chartTypeChange(that.chart_type);
        that.setEvent(mode);
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

    //设置首页条件
    this.setHomeParams = function(homeparams){
        that.homeparams = homeparams;
    }
    this.createChartSql = function(report_id,frompage,parent_id) {
        var tmpwidth = ld(window).width();//全屏宽度
        var module = 'CustomEcharts';
        var Popupobj = CrmPopup.load(arrJsPopLabel['CREATENEWECHARTS'],  '',"", tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['LBL_CLOSE']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.center();
        that.setPopupobj(Popupobj);
        that.setDivid(Popupobj.divid);
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SqlEchartsEditView&function_name=index&report_id='+report_id+"&report_type="+that.report_type+'&frommodule='+that.pageto_module;
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
                    that.frompage = frompage;
                    Popupobj.setParams(arrJsPopLabel['CREATENEWECHARTS'], that.saveAndPreview, '', tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['LBL_CLOSE']);
                    CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, data.result.content);//加载页面
                    CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);//设置全屏
                    //设置表头
                    if (report_id > 0) {
                        that.setReportId(report_id);
                        that.setChartType(that.chart_info.chart_type);
                        that.chart_info = data.result.chart_info;
                        that.sqlColumnsArr = data.result.chart_info.sqlColumnsArr;
                        that.init("edit");
                    }else{
                        that.init("create");
                    }
                    that.setScroll(data.result.chart_info);
                    ld('#' + Popupobj.divid).find('#analysisfolder_id').select2({
                        width: '90%',
                        closeOnSelect: true
                    });
                }
            }
        });
    }
    //设置事件
    this.setEvent = function(mode){
        //图表类型选中事件
        ld('#' + that.divid + ' #chart_type_lists .chart-type-one').unbind('click').bind('click',function(){
            var name = ld(this).attr('data-name');//图表名称
            var label = ld(this).attr('data-label');//图表label
            ld('#chart_type').val(name);
            ld('#chart_type_label').text(label);
            //tab切换到【统计图设置】
            ld('.ld-ui-tabs-nav li').removeClass('ld-ui-tabs-active');
            ld('#chartFormLi').addClass('ld-ui-tabs-active');
            ld('.tab-contents').hide();
            ld('#chartForm').show();
            that.chartTypeChange(name);
            if(mode!='detail') {
                that.setAdvancedSetting(name);//高级设置显示隐藏
            }
            that.chart_type = name;
            //设置表头
            CustomEchartsSqlColumnsObj.chart_type=name;
            CustomEchartsSqlColumnsObj.removeAllRow();
            CustomEchartsSqlColumnsObj.init();
            CustomEchartsSqlColumnsObj.addrow(null);
            that.saveReportInfo("no");
        });
        //标签切换事件
        ld('#'+that.divid).find('.change_tab').unbind('click').bind('click',function(){
            that.changeTab(ld(this));
        });
        //字段list收起 展开
        ld('#'+that.divid).find('[tag=expandFields]').unbind('click').bind('click',function(){
            that.expandFields(ld(this));
        });
        //zxm 20220822 sql编辑事件 editsql
        ld('#'+that.divid).find('[tag=editsql]').unbind('click').bind('click',function(event){
            //阻止事件冒泡
            event.stopPropagation();
            var sqlvalue = ld('#'+that.divid).find('#sqlstr').text();
            var tmpheight = ld(window).height() - 200;//全屏宽度
            var tmpwidth = "1000px";
            var module = 'CustomEcharts';
            var Popupobj = CrmPopup.load( arrJsPopLabel['EDIT']+"SQL", that.sqlparse, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            var html = '<table width="1000px" border="0" cellspacing="0" cellpadding="0" align="left" id="editsql_box" class="settingPopTable settingPopTableNoBot">\n' +
                '      <tbody>';
            html += '<tr><td width="100%">\n' +
                '     <textarea style="margin-top: 3px; overflow: auto; overflow-wrap: break-word; resize: horizontal; height: '+tmpheight+'px;" id="sqlstr_temp">'+sqlvalue+'</textarea>\n' +
                '      </td></tr><tr><td>' +
                '      <span style="line-height:20px;height:20px;display:block">' +
                '     1.SQL中不允许select *，请写出查询的具体字段；</span>' +
                '      <span style="line-height:20px;height:20px;display:block">2.为保证运算正确，请先在数据库工具中将SQL调试正确；</span>\n' +
                '</td>' +
                '</tr></tbody></table>';
            Popupobj.setParams( arrJsPopLabel['EDIT']+"SQL", that.sqlparse, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(html);
        });

        //字段编辑事件 editSqlColumns
        ld('#'+that.divid).find('[tag=editSqlColumns]').unbind('click').bind('click',function(){
            that.editSqlColumns(this);
        });
        //字段选中事件   fieldlists_check
        ld('#'+that.divid).find('[tag=fieldlists_check]').unbind('change').bind('change',function(){
            that.fieldlists_check_change(this);
        });
        //新变量 newvariable
        ld('#'+that.divid).find('[tag=newvariable]').unbind('click').bind('click',function(event){
            //阻止事件冒泡
            event.stopPropagation();
            that.editVariable(this);
        });
        //编辑变量
        ld('#'+that.divid).find('[tag=variableedit]').unbind('click').bind('click',function(){
            that.editVariable(this);
        });
        //变量排序事件
        ld('#'+that.divid).find('[tag=variableup]').unbind('click').bind('click',function(){
            that.variableup(this);
        });
        ld('#'+that.divid).find('[tag=variabledown]').unbind('click').bind('click',function(){
            that.variabledown(this);
        });
        //变量删除事件
        ld('#'+that.divid).find('[tag=variabledelete]').unbind('click').bind('click',function(){
            that.variabledelete(this);
        });
        //详情页搜索区块显示隐藏
        ld('#'+that.divid).find('#toggleSearch').unbind('click').bind('click',function() {
            ld('#'+that.divid).find('#searchList').slideToggle(1000);
            var prop = ld(this).prop('checked');
            var isshow_search = prop?'yes':'no';
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView";
            var param = "is_ajax=yes&function_name=changeReportStatus&reportid=" + that.report_id+'&isshow_search='+isshow_search;
            ldAjaxNoProgress(url,param,function(res) {
                console.log('修改成功');
            });
            setTimeout(function(){that.setScroll(215);},1000);
        });
        //点击搜索按钮事件
        ld('#'+that.divid).find('#toSearch').unbind('click').bind('click',function() {
            that.getReportInfo();
        });
        //详情页是否显示表格
        ld('#' + that.divid).find('#toggleShowTable').unbind('click').bind('click', function () {
            ld('#' + that.divid).find('#chartTable_'+that.report_id).slideToggle(1000);
            var prop = ld(this).prop('checked');
            var isshow_table = prop ? 'yes' : 'no';
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView";
            var param = "is_ajax=yes&function_name=changeReportStatus&reportid=" + that.report_id + '&isshow_table=' + isshow_table;
            ldAjaxNoProgress(url, param, function (res) {
                console.log('修改成功');
            });
        });
        //在PC端首页显示 选中改变事件 --20230627 去掉该设置
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
    //设置高级设置的选项显示隐藏
    this.setAdvancedSetting = function(chart_type){
        var AdvancedSetting = CustomEchartsSqlAdvancedSettingObj.getShowRes(chart_type);
        ld.each(AdvancedSetting,function (index,item) {
            if(item=='no'){
                ld('#'+that.divid).find('#'+index).parent().parent().hide();
                if(index=='groupby_second'){
                    ld('#'+that.divid).find('#'+index+'check').parent().parent().hide();
                }
            }
            if(item=='yes'){
                ld('#'+that.divid).find('#'+index).parent().parent().show();
                if(index=='groupby_second'){
                    ld('#'+that.divid).find('#'+index+'check').parent().parent().show();
                }
            }

        });
    }
    //tab切换事件
    this.changeTab = function(obj){
        var report_name = ld('#'+that.divid+' #report_name').val();
        var report_id = ld('#'+that.divid+' #report_id').val();
        var fortab = ld(obj).attr('for');
        if((fortab=="previewChart"||fortab=="chartAdvanceSet")&&empty(report_name)){
            that.connotempty('统计图名称',ld('#'+that.divid).find('#report_name'));
            return;
        }
        //设置事件
        if(fortab=="chartAdvanceSet") {
            that.setAdvancedSetting(that.chart_type);
        }
        //判断是否选择文件夹
        var parent_id = ld('#'+that.divid).find('#parent_id').val();
        if(parent_id==''){
            alert(arrJsPopLabel['SelectFolder']);
            return false;
        }
        //tab显示隐藏
        ld(obj).siblings().removeClass('ld-ui-tabs-active');
        ld(obj).addClass('ld-ui-tabs-active');
        ld('#'+that.divid).find('.tab-contents').hide();
        ld('#'+that.divid).find('#'+fortab).show();
        that.saveReportInfo("no");
    }
    //自定义统计图-支持SQL语句  SQL运行结果
    this.sqlparse = function(){
        ld('#rptContentLoading').show();
        var popobj = CrmPopup.getPopupObj("last");
        var sqlstr_origin =  ld('#'+popobj.divid).find('#sqlstr_temp').val();
        var sqlstr=Base64.encode(sqlstr_origin);
        sqlstr = encodeURIComponent(sqlstr);
        var report_id = ld('#'+that.divid).find('#report_id').val();
        var report_name = ld('#'+that.divid).find('#report_name').val();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView";
        var param = "is_ajax=yes&function_name=parserSql&report_id="+report_id+"&sqlstr="+sqlstr+"&report_name="+report_name;
        ldAjaxNoProgress(url,param,function(res) {
            if(res.code==1){
                var html_columnlist = '';//字段列表--左侧list
                var option_columnlist = '';//字段option 列表
                var columnsarr = res.result.columnsarr;
                that.sqlColumnsArr = columnsarr;
                ld.each(columnsarr,function(index,column){
                    html_columnlist += ' <li style="display: flex;justify-content: space-between;border-bottom: #fff;"">'+
                        '<span class="user" tag="fieldline'+column.id+'">'+
                        '<label>'+
                        column.columns+
                        '<span>['+column.column_label+']</span>'+
                        '</label>'+
                        '</span><span><a class="Anu3_a">'+
                        '<i class="el-icon-edit-outline"  tag="editSqlColumns" columnid="'+column.id+'"></i>'+
                        '</a>'+
                        '</span>'+
                        '</li>';
                    option_columnlist += '<option value="'+column.id+'">'+column.column_label+'</option>';
                });
                that.sqlColumnsOptions = option_columnlist;
                popobj.CancelEvent();
                var tmpgroupbyvalue = ld('#'+that.divid).find('#groupby').val();
                var tmpgroupby_secondvalue = ld('#'+that.divid).find('#groupby_second').val();
                ld('#'+that.divid).find('#groupby').html(option_columnlist);//统计维度
                ld('#'+that.divid).find('#groupby_second').html(option_columnlist);//第二统计维度
                ld('#'+that.divid).find('#groupby').val(tmpgroupbyvalue);
                ld('#'+that.divid).find('#groupby_second').val(tmpgroupby_secondvalue);
                
                ld('#'+that.divid).find('[tag=fieldlists]').html(html_columnlist);//字段列表
                ld('#'+that.divid).find('#sqlstr').text(sqlstr_origin);//sql字符串
                //事件
                //字段编辑事件 editSqlColumns
                ld('#'+that.divid).find('[tag=editSqlColumns]').unbind('click').bind('click',function(){
                    that.editSqlColumns(this);
                });
                //渲染Y轴数值
                CustomEchartsSqlColumnsObj.sqlColumnsArr = columnsarr;
                CustomEchartsSqlColumnsObj.sqlColumnsOptions = option_columnlist;
                ld('#'+that.divid).find('#columnList [tag=columns]').each(function(i,columnobj){
                    var tmpvalue = ld(columnobj).val();
                    ld(columnobj).html(option_columnlist);
                    ld(columnobj).val(tmpvalue);
                });
                //ld('#'+that.divid).find('#columnList [tag=columns]').html(option_columnlist);
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",res.msg);
            }
            ld('#rptContentLoading').hide();
        });
    };
    //自定义统计图-支持SQL语句  SQL运行 字段编辑事件
    this.editSqlColumns = function(editObj){
        var columnid = ld(editObj).attr('columnid');
        var report_id = that.report_id;
        var tmpwidth = "600px";
        var module = 'CustomEcharts';
        var Popupobj = CrmPopup.load('', that.saveSqlColumns, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=editSqlColumns&columnid="+columnid+"&report_id="+report_id;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            var content = ajaxdata.result.content;
            var title = ajaxdata.result.title;
            Popupobj.setParams(title, that.saveSqlColumns, '', tmpwidth, module, '', arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(content);
        });
    };
    //自定义统计图-支持SQL语句  SQL运行 字段编辑保存
    this.saveSqlColumns = function(){
        var thispopobj =  CrmPopup.getPopupObj("last");
        var param = '';
        var report_id = ld('#'+thispopobj.divid).find('#report_id').val();
        var columnid = ld('#'+thispopobj.divid).find('#columnid').val();
        var column_label = ld('#'+thispopobj.divid).find('#column_label').val();
        var fieldtype = ld('#'+thispopobj.divid).find('#fieldtype').val();

        param += 'columnid='+columnid+'&column_label='+column_label+'&fieldtype='+fieldtype;
        param += '&report_id='+report_id;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=saveSqlColumns";
        ldAjaxNoProgress(url,param,function(ajaxdata){
            popupobj.CancelEvent();
            ld('#'+that.divid).find('[tag=fieldline'+columnid+'] span').text('['+ajaxdata.result.column_label+']');
        });
    };

    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  SQL运行 变量新增 或 编辑
    this.editVariable = function(obj){
        var report_id = ld('#'+that.divid).find('#report_id').val();
        var filterid = ld(obj).attr('filterid');
        var tmpwidth = "800px";
        var module = 'CustomEcharts';
        var Popupobj = CrmPopup.load('', that.saveVariable, "", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=editVariable&filterid="+filterid+"&report_id="+report_id;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            var content = ajaxdata.result.content;
            var title = ajaxdata.result.title;
            Popupobj.setParams(title, that.saveVariable, '', tmpwidth, module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.show(content);

            ld('#'+Popupobj.divid).find('[tag=var_type]').unbind('change').bind('change',function(){
                that.var_type_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('[tag=select_source]').unbind('change').bind('change',function(){
                that.select_source_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('[tag=modulename]').unbind('change').bind('change',function(){
                var var_type = ld('#'+Popupobj.divid).find('[tag=var_type]').val();
                if(var_type=='select'||var_type=='multiselect'){
                    that.modulename_change(Popupobj.divid);
                }
            });
            //$('#test option:selected').val();
            ld('#'+Popupobj.divid).find('#fieldname').unbind('change').bind('change',function(){
                that.fieldname_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('#default_value_selectdate').unbind('change').bind('change',function(){
                that.default_value_selectdate_change(Popupobj.divid);
            });
            ld('#'+Popupobj.divid).find('#selectvalues').unbind('change').bind('change',function(){
                that.selectvalues_change(Popupobj.divid,filterid);
            });
            if(filterid>0){
                ld('#'+Popupobj.divid).find('#default_multivalue_select').select2({width:'90%',closeOnSelect: true});
            }
            that.selectvalues_change(Popupobj.divid,filterid);
            ld('#'+Popupobj.divid).find('#var_type').select2({width:'90%',closeOnSelect: true});
            ld('#'+Popupobj.divid).find('#select_source').select2({width:'90%',closeOnSelect: true});
        });
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  保存变量信息
    this.saveVariable = function(){
        var thispopobj =  CrmPopup.getPopupObj("last");
        var params = ld('#'+thispopobj.divid).find('#editVariable').serialize();
        //验证必填项
        var verification1 = that.connotempty('变量名称',ld('#'+thispopobj.divid).find('#var_name'));
        if(!verification1){
            return;
        }
        var verification2 = that.connotempty('显示名称',ld('#'+thispopobj.divid).find('#display_name'));
        if(!verification2){
            return;
        }
        var verification3 = that.connotempty('变量类型',ld('#'+thispopobj.divid).find('#var_type'));
        if(!verification3){
            return;
        }

        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=saveVariable&"+params;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            if(ajaxdata.code!=1){
                RemindsMsg("","LdPopWidth400px","","yes","yes",ajaxdata.msg);return;
            }else{
                thispopobj.CancelEvent();
                var sqlFilterArr = ajaxdata.result.sqlFilterArr;
                //var show_athome_set = ajaxdata.result.show_athome_set;
                var sqlFilterArrCount = sqlFilterArr.length;
                var html = '';
                ld.each(sqlFilterArr,function(index,item){
                    html += '<li tag="filterlineTr" filterid="'+item.id+'" rowindex="'+(parseInt(index)+1)+'" style="display: flex;justify-content: space-between;border-bottom: #fff;">\n' +
                        '<span class="user" >\n' +
                        '<label>\n' +
                        ''+item.var_name+'\n' +
                        '<span>['+item.display_name+']</span>\n' +
                        '</label>\n' +
                        '</span>' +
                        '<span>\n';
                    var display = "";
                    if(index<=0){
                        display = 'display:none;'
                    }
                    html += '<a class="icon-category category-sup marR8" style="cursor: pointer;'+display+'" title="上移" tag="variableup"></a>\n';
                    var display2 = "";
                    if(index+1>=sqlFilterArrCount){
                        display2 = 'display:none;'
                    }
                    html += '<a class="icon-category category-sdown marR8" style="cursor: pointer;'+display2+'" title="下移" tag="variabledown"></a>\n';
                    html += '<a class="icon-homeimg icon-sdel2 marR8" style="cursor: pointer;" title="删除" tag="variabledelete"></a>\n' +
                        '<a class="Anu3_a"><i class="el-icon-edit-outline" filterid="'+item.id+'" tag="variableedit"></i></a></span>\n' +
                        '</li>';
                });
                //首页显示设置 --20230627 zxm 删除该设置 现在是首页按看板设置
                /*ld('#'+that.divid).find('#show_athome_person_tr').remove();
                ld('#'+that.divid).find('#show_athome_timecheck_tr').remove();
                ld('#'+that.divid).find('#show_athome_approve_tr').remove();
                ld('#'+that.divid).find('#show_athome_title').after(show_athome_set);*/

                ld('#'+that.divid).find('[tag=filterlineTr]').remove();
                ld('#'+that.divid).find('[tag=filterListHeader]').after(html);
                //编辑变量
                ld('#'+that.divid).find('[tag=variableedit]').unbind('click').bind('click',function(){
                    that.editVariable(this);
                });
                //变量排序事件
                ld('#'+that.divid).find('[tag=variableup]').unbind('click').bind('click',function(){
                    that.variableup(this);
                });
                ld('#'+that.divid).find('[tag=variabledown]').unbind('click').bind('click',function(){
                    that.variabledown(this);
                });
                //变量删除事件
                ld('#'+that.divid).find('[tag=variabledelete]').unbind('click').bind('click',function(){
                    that.variabledelete(this);
                });
            }
        });
    }
    //变量上移
    this.variableup = function(obj){
        var liobj = Tools.getParentobjByChild(ld(obj),'li');
        var prev_liobj = liobj.prev();
        var prev_html = prev_liobj[0];
        prev_liobj.remove();
        liobj.after(prev_html);
        liobj.next().find('[tag=variableup]').unbind('click').bind('click',function(){
            that.variableup(this);
        });
        liobj.next().find('[tag=variabledown]').unbind('click').bind('click',function(){
            that.variabledown(this);
        });
        that.resetSqlVarSequence();
    }
    //变量下移动
    this.variabledown = function(obj){
        var liobj = Tools.getParentobjByChild(ld(obj),'li');
        var prev_liobj = liobj.next();
        var prev_html = prev_liobj[0];
        prev_liobj.remove();
        liobj.before(prev_html);
        liobj.prev().find('[tag=variableup]').unbind('click').bind('click',function(){
            that.variableup(this);
        });
        liobj.prev().find('[tag=variabledown]').unbind('click').bind('click',function(){
            that.variabledown(this);
        });
        that.resetSqlVarSequence();
    }
    //变量删除事件
    this.variabledelete = function(obj){
        RemindsMsg( "确定删除变量吗？", "LdPopWidth400px", "", "yes", "yes", "确定删除变量吗");
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            ld('#rptContentLoading').show();
            var liobj = Tools.getParentobjByChild(ld(obj), 'li');
            var filterid = ld(liobj).attr('filterid');
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=variableDelete&filterid=" + filterid;
            ldAjaxNoProgress(url, '', function (ajaxdata) {
                liobj.remove();
                that.resetSqlVarSequence();
                ld('#rptContentLoading').hide();
            });
        });
    }
    this.resetSqlVarSequence=function(){
        var liobjs=ld('#'+that.divid).find("li[tag='filterlineTr']");
        var filterid_str = '';
        var sequence_str = '';
        var trlength = liobjs.length;
        ld.each(liobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
            sequence_str += rowindex + ',';
            var filterid = ld(trobj).attr('filterid');
            filterid_str += filterid + ',';
            ld(trobj).find('[tag=variableup]').show();
            ld(trobj).find('[tag=variabledown]').show();
            if(rowindex<=1){
                ld(trobj).find('[tag=variableup]').hide();
                ld(trobj).find('[tag=variabledown]').show();
            }
            if(rowindex >= trlength){
                ld(trobj).find('[tag=variableup]').show();
                ld(trobj).find('[tag=variabledown]').hide();
            }
        });
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=resetSqlVarSequence&report_id="+that.report_id;
        url+='&filterid_str='+filterid_str+'&sequence_str='+sequence_str;
        ldAjaxNoProgress(url,'',function(ajaxdata){

        });

    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句 变量类型切换事件
    this.var_type_change = function(divid){
        var var_type = ld('#'+divid).find('[tag=var_type]').val();
        if(var_type=='date'){
            ld('#'+divid).find('[tag=datevalue_tr]').css('display','flex');
            ld('#'+divid).find('[tag=datetimevalue_tr]').hide();
        }else if(var_type=='datetime'){
            ld('#'+divid).find('[tag=datevalue_tr]').hide();
            ld('#'+divid).find('[tag=datetimevalue_tr]').css('display','flex');
        }else{
            ld('#'+divid).find('[tag=datevalue_tr]').hide();
            ld('#'+divid).find('[tag=datetimevalue_tr]').hide();
        }
        //下拉框字段来源
        if(var_type=='select'||var_type=='multiselect'){
            ld('#'+divid).find('[tag=select_source_tr]').css('display','flex');
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
            ld('#'+divid).find('[tag=fieldname_tr]').css('display','flex');
            ld('#'+divid).find('[tag=selectvalues_tr]').css('display','flex');
        }else{
            ld('#'+divid).find('[tag=select_source_tr]').css('display','none');
            ld('#'+divid).find('[tag=modulename_tr]').css('display','none');
            ld('#'+divid).find('[tag=fieldname_tr]').css('display','none');
            ld('#'+divid).find('[tag=selectvalues_tr]').css('display','none');
        }
        //默认值  显示隐藏
        if(var_type=='selectuser'||var_type=='multiuser'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }
        else if(var_type=='date'||var_type=='datetime'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }
        else if(var_type=='multiselect'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('#default_multivalue_select').select2({width:'90%',closeOnSelect: true});
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }else if(var_type=='select'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').css('display','flex');
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }else if(var_type=='string'||var_type=='number'){
            if(var_type=='number'){
                ld('#'+divid).find('[tag=default_value_tr]').css('display','flex');
            }else{
                ld('#'+divid).find('[tag=default_value_tr]').hide();
            }

            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }else if(var_type=='checkbox'){
            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').hide();
        }else if(var_type=='approvestatus'){
            //审批组件
            ld('#'+divid).find('[tag=default_value_approvestatus_tr]').css('display','flex');

            ld('#'+divid).find('[tag=default_value_tr]').hide();
            ld('#'+divid).find('[tag=default_value_select_tr]').hide();
            ld('#'+divid).find('[tag=default_value_multiselect_tr]').hide();
            ld('#'+divid).find('[tag=default_value_selectdate_tr]').hide();
        }
        if(var_type=='select'||var_type=='multiselect'){
            that.select_source_change(divid);
        }
        if(var_type=='date'||var_type=='datetime'){
            that.default_value_selectdate_change(divid);
        }
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  下拉框值来源	切换事件
    this.select_source_change = function(divid){
        var select_source = ld('#'+divid).find('[tag=select_source]').val();
        if(select_source=='picklist'){
            ld('#'+divid).find('[tag=modulename_tr]').css('display','flex');
            ld('#'+divid).find('[tag=fieldname_tr]').css('display','flex');
            that.modulename_change(divid);
        }else{
            ld('#'+divid).find('[tag=modulename_tr]').hide();
            ld('#'+divid).find('[tag=fieldname_tr]').hide();
            ld('#'+divid).find('#selectvalues').val("");
            ld('#'+divid).find('#default_multivalue_select').html("").val("");
            ld('#'+divid).find('#default_value_select').html("").val("");
            ld('#'+divid).find('#selectvalues').unbind('change').bind('change',function(){
                that.selectvalues_change(divid,0);
            })
        }
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  模块名称切换事件
    this.modulename_change = function(divid){
        var modulename = ld('#'+divid).find('[tag=modulename]').val();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=getPickListsByModule&modulename="+modulename;
        ldAjaxNoProgress(url,'',function(ajaxdata){
            var html = '';
            var picklists = ajaxdata.result.picklists;
            ld.each(picklists,function(index,item){
                html += '<option pickvalues="'+item.picklist_str+'" value="'+item.columnname+'">'+item.label+'</option>';
            });
            ld('#'+divid).find('#fieldname').html(html);
            that.fieldname_change(divid);
        });
    }
    //XUQIU1000530	统计表 自定义统计表-支持SQL语句  字段名称切换事件
    this.fieldname_change = function(divid){
        var pickvalues = ld('#'+divid).find('#fieldname option:selected').attr('pickvalues');
        ld('#'+divid).find('#selectvalues').val(pickvalues);
        var pickvalues_arr = pickvalues.split(',');
        var html = '';
        ld.each(pickvalues_arr,function(index,item){
            html += '<option value="'+item+'">'+item+'</option>';
        });

        ld('#'+divid).find('#default_value_select').html(html);//默认值
        ld('#'+divid).find('#default_multivalue_select').html(html);//默认值
        ld('#'+divid).find('#modulename').select2({width:'90%',closeOnSelect: true});
        ld('#'+divid).find('#fieldname').select2({width:'90%',closeOnSelect: true});
        ld('#'+divid).find('#default_multivalue_select').select2({width:'90%',closeOnSelect: true});
    };
    this.selectvalues_change = function(divid,filterid){
        ld('#'+divid).find('#modulename').select2({width:'90%',closeOnSelect: true});
        ld('#'+divid).find('#fieldname').select2({width:'90%',closeOnSelect: true});
        if(filterid<=0){
            var selectvalues = ld('#'+divid).find('#selectvalues').val();
            var pickvalues_arr = selectvalues.split(',');
            var html = '';
            ld.each(pickvalues_arr,function(index,item){
                html += '<option value="'+item+'">'+item+'</option>';
            });
            ld('#'+divid).find('#default_value_select').html(html);//默认值
            ld('#'+divid).find('#default_multivalue_select').html(html);//默认值
            ld('#'+divid).find('#default_value_select').select2({width:'90%',closeOnSelect: true});
            ld('#'+divid).find('#default_multivalue_select').select2({width:'90%',closeOnSelect: true});
        }
    }
    this.default_value_selectdate_change = function(divid){
        var default_value_selectdate = ld('#'+divid).find('#default_value_selectdate').val();
        var var_type = ld('#'+divid).find('#var_type').val();
        if(var_type=='date'){
            ld('#'+divid).find('[tag=datevalue_tr]').css('display','flex');
            ld('#'+divid).find('[tag=datetimevalue_tr]').hide();
        }
        if(var_type=='datetime'){
            ld('#'+divid).find('[tag=datevalue_tr]').hide();
            ld('#'+divid).find('[tag=datetimevalue_tr]').css('display','flex');
        }
        if(default_value_selectdate!='selfdefined'){
            ld('#'+divid).find('#datevalue').attr('disabled',true);
            ld('#'+divid).find('#datetimevalue').attr('disabled',true);
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SqlEchartsEditView&function_name=getDefaultDateValue&default_value_selectdate="+default_value_selectdate+"&var_type="+var_type;
            ldAjaxNoProgress(url,'',function(ajaxdata){
                ld('#'+divid).find('#datevalue').val(ajaxdata.result.value_date);
                ld('#'+divid).find('#datetimevalue').val(ajaxdata.result.value);
            });
        }else{
            ld('#'+divid).find('#datevalue').removeAttr('disabled');
            ld('#'+divid).find('#datetimevalue').removeAttr('disabled');
        }
    }
    this.saveAndPreview = function(){
        window.scrollTo(0, document.body.scrollHeight);
        //点保存按钮
        var popupobj = CrmPopup.getPopupObj('last');
        var curdivid = popupobj.divid;
        var report_name = ld('#'+curdivid+' #report_name' ).val();
        if(empty(report_name)){
            RemindsMsg("","LdPopWidth400px","","yes","yes",'统计图名称不能为空!');return;
        }
        that.saveReportInfo('yes');
        return false;
    }
    this.saveAndPreview.funname='this.saveAndPreview';
    //保存报表信息
    this.saveReportInfo = function(isfinish){
        var popupobj = CrmPopup.getPopupObj('last');
        var curdivid = popupobj.divid;
        var params = ld('#'+curdivid+' #chartInfoForm' ).serialize();
        var chartype=ld('#'+curdivid +' #chartInfoForm  input[name=chart_type]').val();
        if(chartype=='basic_scatter'||chartype=='multiple_dimension')
        {
            if(ld('#'+curdivid +' #columnList').find("tr[tag=trTotalColumnList]").length!=2)
            {
                RemindsMsg("","LdPopWidth400px","","yes","yes",'散点图表格统计字段必须是两行!');return;
            }
        }
        //创建链接模块
        let linkmodulecheck = ld('#'+curdivid +' #linkmodulecheck').prop('checked');
        if(linkmodulecheck){
            params += '&linkmodulecheck=yes';
        }else{
            params += '&linkmodulecheck=no';
        }
        params += '&is_ajax=yes';
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SqlEchartsEditView&function_name=saveReportInfo';
        ldAjaxNoProgress(url,params,function(res){
            if(res.code==1){
                //wyt 220817 XUQIU1000504 自定义统计图表或报表的查看界面增加快捷编辑按钮
                var chart_info = res.result.chart_info;
                ld('#'+curdivid +' #report_id').val(chart_info.mainInfo.report_id);
                if(isfinish=='yes') {
                    var popupobj = CrmPopup.getPopupObj('last');
                    popupobj.CancelEvent();
                    if(that.frompage == "fromdetail"){
                        that.init();
                        if(chart_info.columnInfo.length>0){
                            customRenderChart.setChart(chart_info['chartSet'],chart_info.mainInfo.report_id,'no');
                            ld('#'+that.divid).find('#chartTable_'+chart_info.mainInfo.report_id).html(chart_info['chartSet'].table);
                            ld('#'+that.divid).find('#searchList').html(res.result.conditionContent);
                        }
                        that.setScroll(205);
                    }else{
                        if(that.mode!='detail'&&that.mode!='edit'){
                            ReportAnalysisObj.getReportList(0, 'init');
                        }
                    }
                }
                else{
                    if(chart_info.columnInfo.length>0) {
                        customRenderChart.setChart(chart_info['chartSet'], 0, 'no');
                        ld('#' + curdivid).find('#chartTable_' + chart_info.mainInfo.report_id).html(chart_info['chartSet'].table);
                        ld('#'+ curdivid).find('#searchList').html(res.result.conditionContent);
                    }
                    that.setScroll();
                }
            }else{
                RemindsMsg("","LdPopWidth400px","","yes","yes",res.msg);
            }
        });
    }
    this.getReportInfo = function(){
        ld('#rptContentLoading').show();
        var divid = that.divid;
        var report_id = that.report_id;
        var chartInfoForm = ld('#'+divid).find('#chartInfoForm').serialize();//页面上所有的字段值
        var params = '&report_id='+report_id;
        params += '&'+chartInfoForm;
        //设置首页条件
        params += that.homeparams;
        //var sqlstr = ld('#'+divid).find('#sqlstr').text();
        //sqlstr = encodeURIComponent(sqlstr);
        //params += '&sqlstr='+sqlstr;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SqlEchartsDetailView&function_name=getChartData';
        ldAjaxNoProgress(url,params,function(res) {
            if (res.code == 1) {
                var chart_info = res.result;
                ld('#'+divid+' #chartTable_'+report_id).html(chart_info['chartSet']['table']);
                customRenderChart.setChart(chart_info['chartSet'], chart_info.mainInfo.report_id, chart_info.fromhome);
                that.setScroll();
                ld('#rptContentLoading').hide();
            }
        });
    }
    //模块名称点击收起展开
    this.expandFields = function (obj){
        var ulObj = ld(obj).next();
        ulObj.toggle();
        var status = ld(obj).attr('status');
        if(status=="open"){
            ld(obj).attr('status','close');
            ld(obj).addClass('user-right-tip');
        }else{
            ld(obj).attr('status','open');
            ld(obj).removeClass('user-right-tip');
        }
    }
    this.connotempty = function(tips,inputobj){
        var value = ld(inputobj).val();
        if(value==''||value==undefined){
            RemindsMsg("","LdPopWidth400px","","yes","yes",tips+arrJsPopLabel['CANOTEMPTY']);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                ld(inputobj).focus();
            });
            ld('input[class="E_pbtncancel"]').unbind('click').on('click', function () {
                ld(inputobj).focus();
            });
            return false;
        }
        return true;
    }
    //滚动条
    this.setScroll = function(top_height){
        var divid = that.divid;
        var windowWidth = CrmPopup.getClientWidth();
        var windowHeight = CrmPopup.getClientHeight();
        if(ld("#"+divid+" #width_right").length>0){
            var right_width = ld("#"+divid+" #width_right").offset().left;
            top_height = ld("#"+divid+" #width_right").offset().top;//元素距离顶端的高度
        }
        right_width = right_width==undefined?0:right_width;
        if(typeof frommobile!="undefined" && frommobile=='yes'){
            ld("#"+divid+" #div_thResizableContent").css('width',(windowWidth-right_width)+'px');//宽度
            var height=windowHeight-top_height;
        }else{
            ld("#"+divid+" #div_thResizableContent").css('width',(windowWidth-right_width-40)+'px');//宽度
            var height=windowHeight-top_height-80;
        }
        ld("#"+divid+" #sqlfieldListDiv").css('height',((parseInt(height))/2)+'px');
        ld("#"+divid+" #sqlVariableDiv").css('height',((parseInt(height))/2)+'px');
        ld("#"+divid+" #fieldListDiv").css('height',(parseInt(height))+'px');
    }
}
var CustomEchartsSqlCreateObj = new CustomEchartsSqlCreate();
