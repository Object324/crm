if(ld==undefined){
    var ld = $;
}
function CustomTablesCreate(){
    this.popupobj = "";
    this.divid = "";
    this.fieldSelected = [];
    this.columnsSelected = [];
    this.columnsFormula = [];
    this.columnsAlias = [];
    this.report_id = 0;
    this.timeValueArr = {};
    var that = this;
    this.pagerows=0;
    this.pagestart=1;
    this.maxpagecount=0;
    this.report_type='selectfield';
    this.chartInfo='';
    this.th_width=0;
    this.fortab ='';
    this.pageto_module = 'ReportAnalysis';
    this.reportDetailBodyObj;//表体 对象
    this.reportDetailHeaderObj;//表头 对象
    this.init = function(mode){
        //表体 对象
        that.reportDetailBodyObj = ld('#'+that.divid).find('[tag=reportDetailBody]');
        that.reportDetailHeaderObj = ld('#'+that.divid).find('[tag=reportDetailHeader]');
        AjaxJSPage('CustomTablesModule_js','include/js/modules/CustomTables/CustomTablesModule.js');
        that.CustomTablesModuleObj = new CustomTablesModule();
        that.CustomTablesModuleObj.init(that.popupobj);

        that.timeValueArr = timeValueArr;
        that.selecttemplateid = ld('#'+that.divid).find('#selecttemplateid').val();//选择模板创建报表
        //设置事件
        that.setEvent(mode);
        that.mode = mode;
        CustomTablesColumnsObj.init(that.mode,that);//初始化字段表格
        that.changeModuleNames();
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
    //设置事件
    this.setEvent = function(mode){
        //报表模板目录点击事件
        ld('#'+that.divid).find('#left_template_nav li').unbind('click').bind('click',function(){
            ld('#left_template_nav li').removeClass('active');
            ld(this).addClass('active');
        });
        //报表模板选择事件template-type-one
        ld('#'+that.divid).find('.template-type-one').unbind('click').bind('click',function(){
            that.selectTemplate(ld(this));
        });
        //标签切换事件
        ld('#'+that.divid).find('.change_tab').unbind('click').bind('click',function(){
            that.changeTab(ld(this));
        });
        //搜索字段 onkeyup="CustomTablesCreateObj.searchFields(this)"
        ld('#'+that.divid).find('input[tag="searchFields"]').unbind('keyup').bind('keyup',function() {
            that.searchFields(ld(this));
        });
        //添加公式字段
        ld('#'+that.divid).find('#creat_new_formula').unbind('click').bind('click',function() {
            that.creat_new_formula(ld(this));
        });
        //每页条数 改变事件
        ld('#'+that.divid).find('#limitrecord').unbind('change').bind('change',function(){
            var reportDetailBodyObj = that.reportDetailBodyObj;
            reportDetailBodyObj.empty();
            ld("#"+that.divid+" [name=pagenum]").val(1);
            that.renderReportTable();
        });
        //页码改变事件
        ld('#'+that.divid).find('#changePageCount').unbind('change').bind('change',function() {
            that.changePageCount();
        });
        ld('#'+that.divid).find('#changePageCount').unbind('keyup').bind('keyup',function(e) {
            var e = event || window.event;
            if(e.keyCode == 13) {// Enter 回车键
                that.changePageCount();
            }
        });
        //showdetail  是否显示明细 切换事件
        ld('#'+that.divid).find('#show_detail').unbind('click').bind('click',function(e) {
            that.saveReportInfo("no");
        });
        //报表排序方式设置按钮点击事件
        ld('#'+that.divid).find('#reportsortingmethod').unbind('click').bind('click',function(e) {
            that.reportsortingmethod();
        });
    }
    //模块选择事件  新增一个相关模块select---新的
    this.changeModuleNames= function(obj,index){
        that.CustomTablesModuleObj.getRecursionModuleArr(that.report_id,function(data){
            that.moduledata = data;//模块数组信息
            that.getFieldsByModule();
        });
    }
    //模板选择事件
    this.selectTemplate = function(obj){
        //样式
        var selecttemplateid = ld(obj).attr('data-name');
        ld('#'+that.divid).find('.template-type-one .template-img').removeClass('selected').addClass('unselected');
        ld('#'+that.divid).find('.template-type-one .icon-choosed').hide();
        ld(obj).find('.icon-choosed').show();

        ld('#'+that.divid).find('#selecttemplateid').val(selecttemplateid);
        ld(obj).find('.template-img').removeClass('unselected').addClass('selected');

        that.getRecursionModuleArr(selecttemplateid);
        that.changeTab(ld('#'+that.divid).find('#moduleSetLi'));
    }
    this.getRecursionModuleArr = function(selecttemplateid){
        var modulename = '';
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=ModuleInfo&function_name=getRecursionModuleArr&report_id="+selecttemplateid+"&modulename="+modulename;
        ldAjaxNoProgress(url,{},function(data) {
            that.CustomTablesModuleObj.setData(data.result);
            that.CustomTablesModuleObj.show();
            that.moduledata = that.CustomTablesModuleObj.data;//模块数组信息
        });
    }
    //tab切换事件
    this.changeTab = function(obj){
        var prevtab = ld('#'+that.divid).find('.ld-ui-tabs-active').attr('for');//前一个tab
        var selecttemplateid = ld('#'+that.divid+' #selecttemplateid').val();
        var report_type = ld('#'+that.divid).find('#report_type').val();//报表类型 selectfield-字典报表 sql-SQL
        var report_name = ld('#'+that.divid+' #report_name').val();
        var report_id = ld('#'+that.divid+' #report_id').val();
        var fortab = ld(obj).attr('for');
        that.fortab =fortab;
        // 20220819 李金雪需求 允许修改数据来源模块 故注释判断
        if((fortab=="tableSet"||fortab=="advancedSetting")){

            if(report_name==''){
                CustomTablesObj.connotempty('报表名称',ld('#'+that.divid).find('#report_name'));
                return;
            }
            if(empty(that.moduledata.mainmoduleSelected)){//字典报表 必须选模块  SQL报表不用此判断
                alert(arrJsPopLabel['SelectModule']);
                return false;
            }
        }
        if(fortab === "moduleSet"){
            if(empty(that.moduledata.mainmoduleSelected))
                that.getRecursionModuleArr(selecttemplateid);
            else
                that.CustomTablesModuleObj.show();
        }
        //tab显示隐藏
        ld(obj).siblings().removeClass('ld-ui-tabs-active');
        ld(obj).addClass('ld-ui-tabs-active');
        ld('#'+that.divid).find('.tab-contents').hide();
        ld('#'+that.divid).find('#'+fortab).show();

        ld('#'+that.divid+' #report_name').focus();
        //保存信息 --字典报表 第一个tab切换时不保存 后面两个才保存
        if((fortab=="tableSet"||fortab=="advancedSetting"||selecttemplateid>0)&&report_name!='') {
            that.saveReportInfo("no");
        }
    }
    //根据选择的模块 获取字段列表
    this.getFieldsByModule = function(){
        that.CustomTablesModuleObj.getModuleAllFields(that.report_id,function(ajaxdata){
            if(typeof that.moduledata === "object")
                Object.assign(that.moduledata,ajaxdata);
            else
                that.moduledata = ajaxdata;//模块数组信息

            var listdata = ajaxdata.searchFieldRes;
            var columns = ajaxdata.columns;//渲染表头
            var columns_value = ajaxdata.columns_value;//字段选中的值
            var reportConditions = ajaxdata.reportConditions;//条件数据
            if(columns_value!=null){
                that.fieldSelected = columns_value;
            }
            that.columnsSelected = columns;
            that.modulelength = ajaxdata.modulelength;
            that.columnsFormula = ajaxdata.columns_formula;//计算公式字段
            that.columnsAlias = ajaxdata.columns_alias;//取过别名的字段
            if(that.mode!="detail"){
                //详情页不需要渲染字段选择列表
                that.renderFields(listdata,columns_value);//渲染字段选择列表
            }
            var CustomTablesConditionsObj = new CustomTablesConditions();
            CustomTablesConditionsObj.setPopupobj(that.Popupobj);
            CustomTablesConditionsObj.setDivid(that.divid);
            //CustomTablesColumnsObj.init(that.mode,that);//初始化字段表格
            CustomTablesConditionsObj.init(listdata,that.timeValueArr,that.mode);//初始化条件表格

            CustomTablesColumnsObj.setSortable();//设置表头拖动事件
            //编辑 遍历渲染条件数据
            //初始删除所有行
            CustomTablesConditionsObj.removeAllRow();
            if(reportConditions!=null&&reportConditions.length>0){

                //渲染条件
                ld.each(reportConditions,function(idx,itm){
                    CustomTablesConditionsObj.addrow(itm,null);
                    if(reportConditions.length-1==idx){
                        //最后个空行增加新条件的按钮
                        CustomTablesConditionsObj.addrow({'type':'emptyline'},null);
                    }
                });
            }
            else{
                //BUG0064572  报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
                if(ld('#'+that.divid+' #conditionColumnBody').find('tr').length==0){
                    CustomTablesConditionsObj.addgroupcondition(ld('#'+that.divid+' [tag=addgroupcondition]'));
                }
                //CustomTablesConditionsObj.addrow({'groupid':1});
            }
            //编辑 遍历渲染thead  这个时候需要清空表头
            var th_width = 0;
            CustomTablesColumnsObj.setColumns(columns);

            if(columns!=null&&columns.length>0){
                that.reportDetailHeaderObj.empty();
                ld.each(columns,function(index,item){
                    CustomTablesColumnsObj.addTh(item,null);
                    var temp_th_width = item.header_width>0?item.header_width:200;
                    th_width += parseInt(temp_th_width);
                });
            }else{
                that.reportDetailHeaderObj.html('<th class="empty-field" style="width:100%;">'+arrJsPopLabel['PLEASESELECTFIELD']+'!</th>')
            }
            that.th_width = th_width;
            that.setScroll(that.th_width,215);
            //渲染表格
            if(that.report_id>0)
                that.renderReportTable();
        });
    }
    this.changePageCount=function()
    {
        //BUG0065024 zxm20230420 报表分析，点击自定义报表，SQL报表，当输入要跳转页数，大于总页数时，会跳转到一个空值界面（应该跳转到最后一页）
        var pagenum = ld("#"+that.divid+" [name='pagenum']").val();//第几页
        if(pagenum>=that.totalpages){
            ld("#"+that.divid+" [name='pagenum']").val(that.totalpages);
        }
        //分页
        var reportDetailBodyObj = that.reportDetailBodyObj;
        reportDetailBodyObj.empty();
        that.renderReportTable();
    }
    //zxm 20220721 设置报表排序方式  点击事件
    this.reportsortingmethod = function(){
        var report_id = that.report_id;
        var module = 'CustomTables';
        var params = '&report_id='+report_id;
        var show_detail_value = ld('#'+that.divid +" #show_detail").prop('checked');
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=setReportSortingMethodOfTables&mode=set";
        if(show_detail_value){
            url += '&show_detail=yes';
        }else{
            url += '&show_detail=no';
        }
        ldAjaxNoProgress(url,params,function(ajaxdata) {
            var res = ajaxdata.result;
            var Popupobj = CrmPopup.load(res.title, that.saveReportsortingmethod, "", "LdPopWidth600px", module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.setParams(res.title, that.saveReportsortingmethod, '', "LdPopWidth600px", module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            // Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            Popupobj.setHeadTitle(res.title);
            Popupobj.show(res.content);
            // 需要去掉的给高度
            Popupobj.reduceBodyHeight = 89;
            // 设置内容最大高度
            Popupobj.setPopBodyMaxHeight(".divPopOverflow");

            var divid = Popupobj.divid;

            // 设置新增按钮事件
            ld('#'+divid).find('[tag=add_sort]').unbind('click').bind('click',function(){
                var innerhtml = ld('#'+divid).find('[rowindex=0]').html();
                var trobj = ld('#'+divid).find("#sortSetList table tbody tr:last-child");
                trobj.after('<tr tag="trSortColumnList" rowindex="0">'+innerhtml+'</tr>');
                // 需要去掉的给高度
                Popupobj.reduceBodyHeight = 89;
                // 设置内容最大高度
                Popupobj.setPopBodyMaxHeight(".divPopOverflow");
                //新增一行  设置默认值
                var sorttype = ld(trobj).find('[tag=sorttype_change] option')[0].value;
                trobj.find('[tag=columns] option').hide();
                trobj.find('[tag=columns] option[sorttype='+sorttype+']').show();
                if(trobj.find('[tag=columns] option[sorttype='+sorttype+']')[0]){
                    trobj.find('[tag=columns]').val(trobj.find('[tag=columns] option[sorttype='+sorttype+']')[0].value);//默认值设置第一个
                }

                //删除事件
                that.setReportsortingEvent(divid);
                that.resetSortRowindex();
            });
            //设置事件
            that.setReportsortingEvent(divid);
        });
    };
    //zxm 20220721 设置事件  删除事件  排序类型切换事件
    this.setReportsortingEvent = function(divid){
        ld('#'+divid).find('[tag=deleted_sort]').unbind('click').bind('click',function(){
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            trobj.remove();
            that.resetSortRowindex();
        });
        //类型切换事件
        ld('#'+divid).find('[tag=sorttype_change]').unbind('change').bind('change',function(){
            var trobj = Tools.getParentobjByChild(ld(this),'tr');
            var sorttype = ld(this).val();
            trobj.find('[tag=columns] option').hide();
            trobj.find('[tag=columns] option[sorttype='+sorttype+']').show();
            trobj.find('[tag=columns]').val(trobj.find('[tag=columns] option[sorttype='+sorttype+']')[0].value);//默认值设置第一个
        });
    }
    //zxm 20220721 排序方式数据保存方法
    this.saveReportsortingmethod = function(){
        var Popupobj=CrmPopup.getPopupObj('last');
        ld('#rptContentLoading').show();
        ld('#'+Popupobj.divid).find("#sortSetList select[disabled]").each(function() {
            if (parseInt(ld(this).val()) != -1) {
                ld(this).attr("disabled", false);
            }
        });

        var params = ld('#'+Popupobj.divid).find('#sortSetList').serialize();
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=setReportSortingMethodOfTables&mode=save";
        ldAjaxNoProgress(url,params,function(res) {
            ld('#rptContentLoading').hide();
            popupobj.CancelEvent();
            //重新渲染表格
            that.renderReportTable();
        });
    }
    //重设排序方式每一行的index
    this.resetSortRowindex=function(){
        var trobjs=ld(this.tableobj).find("tr[tag='trSortColumnList']");
        ld.each(trobjs,function(tmpindex,trobj){
            var rowindex=parseInt(tmpindex)+1;
            ld(trobj).attr("rowindex",rowindex);
        });
    }
    //请求和渲染表格数据
    this.renderReportTable = function(){
        ld('#rptContentLoading').show();
        var divid = that.divid;
        //字段
        var reportDetailBodyObj =that.reportDetailBodyObj;
        var chartInfoForm = ld('#'+divid).find('#chartInfoForm').serialize();//页面上所有的字段值
        var params = '';//'&report_id='+that.report_id;
        if(!(/[report_id=]/).test(chartInfoForm))
            params += '&report_id='+that.report_id;
        params += '&'+chartInfoForm;
        if(typeof frommobile!='undefined' && frommobile=='yes'){
            params += '&frommobile='+frommobile;
        }
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=CustomTablesDetailView&function_name=getDetailData";
        var pagenum = 1;
        var limitrecord = ld("#"+divid+ " [name=limitrecord]").val();//每页限制条数

        pagenum = ld("#"+divid+" [name='pagenum']").val();//第几页

        that.maxpagecount = Math.ceil(that.pagerows/limitrecord) ;

        url+="&limitrecord="+limitrecord;
        if(that.pagerows>0&&parseInt(pagenum)>that.maxpagecount)
        {
            ld('#rptContentLoading').hide();
            return ;
        }
        url+="&pagenum="+pagenum;
        url+='&totalrows='+that.pagerows;
        url+='&pagemode='+that.mode;
        ldAjaxNoProgress(url,params,function(ajaxdata){
            var content = ajaxdata.result.content;
            that.chartInfo = ajaxdata.result.chartInfo;
            that.mergeRowInfo = ajaxdata.result.mergeRowInfo;

            reportDetailBodyObj.empty();//zxm清空原有数据 不重复显示 bug0048343
            reportDetailBodyObj.html(content);
            that.setPageStyle(ajaxdata.result,pagenum);//分页样式
            ld('#rptContentLoading').hide();
            that.setScroll(that.th_width,130);
            //表头拖动
            ld('#' + that.divid + " #thResizable").resizableColumns('thResizable', that.report_id,that);

            //列固定
            freezecolumnsObj.init('thResizable');//冻结列类初始化
            var width = freezecolumnsObj.freezeThColumnBeforeAll('set-sticky');
            freezecolumnsObj.freezeTdColumnBeforeAll('set-sticky',width);
            ld('#'+that.divid).find('.customtable-droplist').css('z-index','9999');

            //合并行：隔行换色，背景色
            that.changeRowColor();
        });
    }
    this.changeRowColor = function () {
        var rowClass = {
            lvtColData : 'lvtColDataBj',
            lvtColDataBj : 'lvtColData',
        };
        var typeArr = {
            On : 'Off',
            Off : 'On',
        }
        var mergeRowInfo = that.mergeRowInfo;
        var tbodyJqObj = that.reportDetailBodyObj;
        ld.each(mergeRowInfo,function (tdIndex,Info) {
            var styleClass = 'lvtColData';
            var type = 'Off';
            ld.each(Info,function (endRowIndex,rowNum) {
                rowNum = parseInt(rowNum);
                endRowIndex = parseInt(endRowIndex);
                var startRowIndex = endRowIndex - rowNum;
                for (var i = startRowIndex; i < endRowIndex; i ++){
                    var trJqObj = tbodyJqObj.find('tr[rowindex="'+i+'"]');
                    trJqObj.addClass(styleClass);
                    trJqObj.removeClass(rowClass[styleClass]);
                    var merger = trJqObj.attr('merge') === undefined ? '' : trJqObj.attr('merge');
                    merger += startRowIndex + '_';
                    trJqObj.attr('merge',merger);
                    trJqObj.attr('onmouseover','listOnMouseOver(ld(this), \'merge\')');
                    trJqObj.attr('onmouseout','listOnMouseOut(ld(this), \''+type+'\', \'merge\')');
                }
                //切换样式class
                styleClass = rowClass[styleClass];
                type = typeArr[type];
            });
        });
    }
    //设置分页样式
    this.setPageStyle = function(data,pagenum){
        that.pagerows=data.pagerows;//总条数
        that.totalpages=data.totalpages;//总页数
        ld("#"+that.divid+' [name=totaldescription]').html(data.totaldescription);
        ld("#"+that.divid+' #pageoftotalpages').html(pagenum + '/' + data.totalpages);
        that.pagestart++;
        if(pagenum<=1){
            ld('#'+that.divid+' #goleft').removeClass('icon-prevpage').addClass('no-icon-prevpage').attr('title','').unbind('click');
        }else{
            ld('#'+that.divid+' #goleft')
                .removeClass('no-icon-prevpage')
                .addClass('icon-prevpage')
                .attr('title','上一页')
                .unbind('click')
                .bind('click',function(){
                    ld("#"+that.divid+' #changePageCount').val(pagenum-1);
                    that.changePageCount();
                });
        }
        if(pagenum>=data.totalpages){
            ld('#'+that.divid+' #goright').removeClass('icon-nextpage').addClass('no-icon-nextpage').attr('title','').unbind('click');
        }else{
            ld('#'+that.divid+' #goright')
                .removeClass('no-icon-nextpage')
                .addClass('icon-nextpage')
                .attr('title','下一页')
                .unbind('click')
                .bind('click',function(){
                    ld("#"+that.divid+' #changePageCount').val(parseInt(pagenum)+1);
                    that.changePageCount();
                });
        }
    }
    //选择字段列表
    this.renderFields = function(listdata,columns_value){
        var html = '';
        var modulelength = that.modulelength;
        var style1 = '';
        var style2 = '';
        var style3 = '';

        //XUQIU1000501	其他
        // 报表-表格设置-模块字段显示增加纵向滚动框
        if(modulelength>1){
            style1 = 'max-height:275px;overflow-y:auto;padding:0 0 10px 10px;margin:5px 0 ;';
            style2 = 'style="position: sticky;top:0;width:100%;display: inline-block;background-position:0 15px;"';
            style3 = 'style="width:100%;background-color: #F8F8F8;display:inline-block;padding-top:10px;"';
        }else{
            ld('#'+that.divid+' #fieldListDiv').css('overflow-y','scroll');
        }
        ld.each(listdata,function(index,item){
            var mainmodulestyle = 'border-width: 2px;border-style: dashed;border-radius: 8px;border-color: #AEB9CA;';
            if(item.modulename==that.moduledata.mainmoduleSelected){
                //主模块 样式显示着重强调一下
                mainmodulestyle = 'border-width: 2px;border-style: solid;border-radius: 8px;border-color: #3b7cff;box-shadow: 1px 1px 5px 0 #385C8D;';
            }
            html += '<li style="'+style1+mainmodulestyle+'">\n' +
                '<span '+style2+' class="file" status="open" tag="modulename">\n' +
                '    <label '+style3+'>'+item.label+'</label>\n' +
                '</span><ul>';
            ld.each(item.child,function(idx,itm) {
                var checked = "";
                var temp_columns = itm.value;
                var temp_column_pre_length = temp_columns.lastIndexOf('_');
                var temp_column_pre = temp_columns.substring(0,temp_column_pre_length);
                // if(columns_value!=null&&columns_value.indexOf(temp_columns)!=-1){
                //     checked = "checked";
                // }
                //zxm 20230605 原来的判断有问题  如果字段fieldlabel被修改过 判断就不准确 所以才这样改 
                ld.each(columns_value,function(i,columnvalue) {
                    columnvalue = columnvalue.substring(0,temp_column_pre_length);
                    if(temp_column_pre==columnvalue){
                        checked = "checked";
                    }
                });
                html += '<li>\n' +
                    '<span class="user" tag="fieldname">\n' +
                    '<label><input tag="selectedField" class="j-all-checkbox" type="checkbox" '+checked+' fieldlabel="'+itm.label+'" modulelabel="'+item.label+'" columns="'+itm.value+'" columnmodule="'+itm.columnmodule+'" bigtype="'+itm.bigtype+'" typeofdata="'+itm.typeofdata+'" detailField="'+itm.detailField+'" border="0">\n' +
                    itm.label+'</label>\n' +
                    '</span>\n' +
                    '</li>';
            });
            html += '</ul></li>\n';
        });

        ld('#'+that.divid+' #fieldList').empty().append(html);
        //点击事件
        ld('#'+that.divid+' #fieldList').find('[tag=modulename]').unbind('click').bind('click',function(){
            that.expandFields(this);
        });
        this.popupobj.center();
        ld('#'+that.divid+' #fieldList').find('input[tag="selectedField"]').unbind('click').bind('click',function(){
            that.selectedField(ld(this));
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
    //字段模糊搜索
    this.searchFields = function (obj){
        var val = ld(obj).val();
        if(val==undefined||val==""){
            ld('#'+that.divid+' #fieldList ').find('li').show();
            return false;
        }
        //收起的字段全部展开
        var modulenameObj = ld('#'+that.divid+' #fieldList ').find('span[tag="modulename"]');
        var ulObj = ld(modulenameObj).next();
        ulObj.show();
        ld(modulenameObj).attr('status','open');
        ld(modulenameObj).removeClass('user-right-tip');
        //选中的字段高亮
        var fieldObj = ld('#'+that.divid+' #fieldList ').find('span[tag="fieldname"]');
        fieldObj.each(function(){
            //wyt 220826 XUQIU1000500 自定义报表中的字段搜索查找功能优化
            var fieldname = ld(this).find('label').text();
            ld(this).parent().hide();
            if(fieldname.indexOf(val)!=-1){
                ld(this).parent().show();
            }
        });
    }


    //字段勾选事件 --勾选增加th  去除勾选删除th
    this.selectedField = function(obj){
        //报表名称不能为空
        var report_name = ld('#'+that.divid).find('#report_name').val();
        if(report_name==''||report_name==undefined){
            ld(obj).prop('checked',false);
            ld('#rptContentLoading').hide();
            //alert(arrJsPopLabel['FillTheName']);return;
            CustomTablesObj.connotempty('报表名称',ld('#'+that.divid).find('#report_name'));
            return;
        }

        var status = ld(obj).prop('checked');
        var param = {};
        param.columns = ld(obj).attr('columns');
        param.columnmodule = ld(obj).attr('columnmodule');
        param.modulelabel = ld(obj).attr('modulelabel');
        param.fieldlabel = ld(obj).attr('fieldlabel');
        param.bigtype = ld(obj).attr('bigtype');
        param.typeofdata = ld(obj).attr('typeofdata');
        param.detailField = ld(obj).attr('detailField');
        param.tdheader_label = ld(obj).attr('fieldlabel');//初始化 中英文label都取用字段名称
        param.tdheader_label_en = ld(obj).attr('fieldlabel');
        param.alias = '';
        if(status==true){
            //选中 增加一个字段
            CustomTablesColumnsObj.addTh(param,'');
            that.th_width += 200;
            that.setScroll(that.th_width,215);
            //重新渲染表格--没存表的字段也需要加进去
            that.fieldSelected.push(param.columns);
            that.columnsSelected.push(param);
            CustomTablesColumnsObj.setColumns(that.columnsSelected);
            that.saveReportInfo("no");
            //重新渲染表格
            that.renderReportTable();
        }else{
            //判断最后一个字段不允许删除
            var selectedFieldObjs = ld('#'+that.divid+' [tag=selectedField]');
            var selectedFieldNums = 0;
            ld.each(selectedFieldObjs,function(i,item){
                var tmp_prop = ld(item).prop('checked');
                if(tmp_prop==true)selectedFieldNums+=1;
            });
            if(selectedFieldNums<=0){
                ld(obj).prop('checked',true);
                //请至少选择一个字段
                RemindsMsg("","LdPopWidth400px","","yes","yes",'请至少选择一个字段');return;
            }
            //edit: xll 2024/02/01 BUG20240111-67 点取消，销售负责人字段前面的勾选框仍取消了，但字段仍显示。
            event.preventDefault();
            // 弹框确认是否删除
            RemindsMsg(arrJsPopLabel["WARMPROMPT"], "LdPopWidth400px", "", "yes", "yes",arrJsPopLabel["Areyousuretodeleteit"]);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                //去除选中
                CustomTablesColumnsObj.removeTh(param);
                //去除选中字段数组中的值
                var temp_index = that.fieldSelected.indexOf(param.columns);
                that.fieldSelected.splice(temp_index, 1);
                that.saveReportInfo("no");
                ld(obj).prop('checked',false);
                // that.saveReportInfo("no");
                // //重新渲染表格
                // that.renderReportTable();
            });
            ld('input[class="E_pbtncancel"]').unbind('click').on('click', function () {
                ld(obj).prop('checked',true);
                return false;
            });
        }
    }
    this.saveReportInfo = function(isfinish){
        ld('#rptContentLoading').show();
        var popupobj = CrmPopup.getPopupObj('last');
        that.divid = popupobj.divid;
        var report_type = ld('#'+that.divid).find('#report_type').val();//报表类型 selectfield-字典报表 sql-SQL
        var params = ld('#'+that.divid+' #chartInfoForm').serialize();

        //报表名称不能为空
        var report_name = ld('#'+that.divid +" #report_name").val();
        if((report_name==''||report_name==undefined)){//字典报表 保存的时候报表名称必填
            ld('#rptContentLoading').hide();
            CustomTablesObj.connotempty(arrJsPopLabel['ReportName'],ld('#'+that.divid).find('#report_name'));
            ld('#'+that.divid).find('#moduleSetLi').siblings().removeClass('ld-ui-tabs-active');
            ld('#'+that.divid).find('#moduleSetLi').addClass('ld-ui-tabs-active');
            ld('#'+that.divid).find('.tab-contents').hide();
            ld('#'+that.divid).find('#moduleSet').show();
            return;
        }

        if(empty(that.moduledata.mainmoduleSelected)){//字典报表 至少选个主模块
            ld('#rptContentLoading').hide();
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['PLEASESELECTMODULE']);
            ld('#'+that.divid).find('#moduleSetLi').siblings().removeClass('ld-ui-tabs-active');
            ld('#'+that.divid).find('#moduleSetLi').addClass('ld-ui-tabs-active');
            ld('#'+that.divid).find('.tab-contents').hide();
            ld('#'+that.divid).find('#moduleSet').show();
            return;
        }

        //创建链接模块
        var linkmodulecheck = ld('#'+that.divid +" #linkmodulecheck").prop('checked');
        if(linkmodulecheck){
            params += '&linkmodulecheck=yes';
        }else{
            params += '&linkmodulecheck=no';
        }
        //是否放看板显示
        var show_athome = ld('#'+that.divid +" #show_athome").prop('checked');
        if(show_athome){
            params += '&show_athome=yes';
        }else{
            params += '&show_athome=no';
        }
        //显示小计文案
        //显示明细
        var show_subtotal = ld('#'+that.divid +" #show_subtotal").prop('checked');
        if (show_subtotal) {
            params += '&show_subtotal=yes';
        } else {
            params += '&show_subtotal=no';
        }
        var show_detail = ld('#'+that.divid +" #show_detail").prop('checked');
        if (show_detail) {
            params += '&show_detail=yes';
        } else {
            params += '&show_detail=no';
        }
        params += '&is_ajax=yes&isfinish='+isfinish+'&report_type='+report_type;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=CustomTablesEditView&function_name=saveReportInfo";
        url += '&mainmoduleSelected='+that.moduledata.mainmoduleSelected;
        url += '&nextSelectedArr='+JSON.stringify(that.moduledata.nextSelectedArr);
        url += '&prevSelectedArr='+JSON.stringify(that.moduledata.prevSelectedArr);

        ldAjaxNoProgress(url,params,function(res){
            ld('#rptContentLoading').hide();

            if(res.code==1){
                var report_id = res.result.report_info.report_id;
                ld('#'+that.divid +" #report_id").val(report_id);
                ld('#'+that.divid +" #selecttemplateid").val(0);
                that.report_id = report_id;
                if(isfinish=='no') {
                    that.renderReportTable();
                    //wyt 220817 XUQIU1000504 自定义统计图表或报表的查看界面增加快捷编辑按钮
                }else if( that.frompage == "fromdetail"){
                    var popupobj = CrmPopup.getPopupObj('lastprev');
                    that.popupobj.CancelEvent();
                    //edit: xll BUG20240111-78 刷新详情页弹窗的报表名称
                    if(popupobj.headtitle !== report_name){
                        popupobj.headtitle = report_name;
                        ld('#'+popupobj.divid).find('#'+popupobj.divid+'_head').find('.E_ptita').text(report_name);
                        ReportAnalysis.refreshReportName(report_id,report_name);
                    }
                    var CustomTablesDetailObj = new CustomTablesDetail();
                    CustomTablesDetailObj.setPopupobj(popupobj);
                    CustomTablesDetailObj.setDivid(popupobj.divid);
                    CustomTablesDetailObj.setReportId(report_id);
                    CustomTablesDetailObj.init();

                }else if(isfinish=='init'){
                    that.init('edit');
                }else{
                    var popupobj = CrmPopup.getPopupObj('last');
                    popupobj.CancelEvent();
                    ReportAnalysisObj.getReportList(0, 'init');
                }
                if(that.fortab=='tableSet'){
                    //只有从前面页签切换到报表设置页签的时候需要重新请求字段数据
                    that.getFieldsByModule();
                    that.fortab=''
                }
            }else{
                if(isfinish=='no') {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['SaveFailed2']);
                }else{
                    that.reportDetailHeaderObj.empty();
                    that.reportDetailBodyObj.empty();
                    CustomTablesColumnsObj.init(that.mode,that);//初始化字段表格
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", res.msg);
                }

                ld('#'+that.divid).find('#tableSetLi').siblings().removeClass('ld-ui-tabs-active');
                ld('#'+that.divid).find('#tableSetLi').addClass('ld-ui-tabs-active');
                ld('#'+that.divid).find('.tab-contents').hide();
                ld('#'+that.divid).find('#tableSet').show();
                that.getFieldsByModule();
            }


        });
    }

    //新增公式字段 点击事件
    this.creat_new_formula = function(){
        if(that.columnsAlias==null||that.columnsAlias==[]||that.columnsAlias==''||that.columnsAlias.length<=0){
            that.saveReportInfo("no");
        }
        var report_id = that.report_id;
        var module = 'CustomTables';
        //找当前报表设置好统计方式的字段们 条件total_type不为空且total_type!=formula
        var mainmodule = that.moduledata.mainmoduleSelected;
        var relatedmodule = that.moduledata.nextSelectedArr.join(',');
        var params = '&mainmodule='+mainmodule+'&relatedmodule='+relatedmodule+'&report_id='+report_id;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=ModuleInfo&function_name=getModuleFields";
        ldAjaxNoProgress(url,params,function(ajaxdata) {
            var columnsAlias = ajaxdata.result.columns_alias;//取过别名的字段
            var allCurrencies = ajaxdata.result.allCurrencies;//币种列表
            if (!columnsAlias) {
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['NoNumber']);
                ld('#rptContentLoading').hide();
                return;
            }
            var Popupobj = CrmPopup.load(arrJsPopLabel['AddFormulaField'], that.saveColumnsAlias, "", "LdPopWidth600px", module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            Popupobj.setParams(arrJsPopLabel['AddFormulaField'], that.saveColumnsAlias, '', "LdPopWidth600px", module, "", arrJsPopLabel['Confirm'], "",  arrJsPopLabel['CANCEL']);
            Popupobj.createScrollDiv();//创建滚动条
            var tmpheight = Popupobj.getMaxHeight() - 105;
            Popupobj.prevshow();
            var html = '<div style="width:600px;max-height:'+tmpheight+'px;overflow-y: scroll;"><table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" id="toolfieldFormula" class="settingPopTable settingPopTableNoBot">\n' +
                '      <tbody>';
            html += '<tr><th width="200" align="left" class="editrelhead" colspan="2">\n' +
                '      <b class="padL5">'+arrJsPopLabel['DisplaySetting']+'</b>\n' +
                '      </th></tr>';
            html += '<tr><td style="padding-left:10px;" width="20%" align="left"><font color="red">*</font>'+arrJsPopLabel['ChineseName']+'</td><td class="ld-form-item-content"><input type="text" id="tdheader_label" value="" class="ld-input-inner"></td></tr>';
            html += '<tr><td style="padding-left:10px;" align="left"><font color="red">*</font>'+arrJsPopLabel['EnglishName']+'</td><td class="ld-form-item-content"><input type="text"  id="tdheader_label_en" value="" class="ld-input-inner"></td></tr>';
            html += '<tr><td style="padding-left:10px;" align="left">'+arrJsPopLabel['Decimal']+'</td><td class="ld-form-item-content"><input type="number" min="0" id="decimal_places"  value="2" class="ld-input-inner"></td></tr>';
            html += '<tr><td style="padding-left:10px;" align="left">'+arrJsPopLabel['Prefix']+'</td><td class="ld-form-item-content"><select class="ld-select-inner" id="prefix"><option value="">'+arrJsPopLabel['NONE']+'</option>';
            ld.each(allCurrencies, function (i, currency) {
                html += '<option value="'+currency.currencysymbol+'">'+currency.currencysymbol+'</option>';
            });
            html += '</select></td></tr>';

            html += '<tr><td style="padding-left:10px;" align="left">'+arrJsPopLabel['Suffix']+'</td><td class="ld-form-item-content"><input type="text" id="suffix" value="" class="ld-input-inner" placeholder="'+arrJsPopLabel['Example']+'"></td></tr>';

            html += '<tr><td class="editrelhead" colspan="2">\n' +
                '      <b class="padL5">'+arrJsPopLabel['DefineVariable']+'</b></br>' +
                '      </td></tr>';
            html += '    <tr><td style="padding-left:10px;" height="34px">'+arrJsPopLabel['LBL_Field']+'</td><td>'+arrJsPopLabel['VariableName']+'</td></tr>';
            ld.each(columnsAlias, function (idx, aliasColumns) {
                //html += '<tr id="formual_row_' + idx + '"><td>' + aliasColumns.modulelabel + '->' + aliasColumns.fieldlabel;
                html += '<tr id="formual_row_' + idx + '"><td style="padding-left:10px;" >' + aliasColumns.tdheader_label ;
                html += '</td>' +
                    '<td>{' + aliasColumns.alias + '}</td>' +
                    '</tr>';
            });
            html += '<tr><td style="padding-left:10px;" class="editrelhead" colspan="2">\n' +
                '      <font color="red">*</font><b>'+arrJsPopLabel['DefinitionFormula']+'</b></br>' +
                '      </td></tr>';
            html += '<tr><td  class="ld-form-item-content" colspan="2">' +
                '      <input type="text"  id="definitionformula" name="definitionformula" class="ld-input-inner">' +
                '      <span style="line-height:20px;height:20px;display:block">' +
                '      '+arrJsPopLabel['Sentence']+'</span>' +
                '      <span style="line-height:20px;height:20px;display:block">'+arrJsPopLabel['Sentence2']+'</span>\n' +
                '      <span style="line-height:20px;height:20px;display:block">'+arrJsPopLabel['Sentence3']+'</span>\n' +
                '</td></tr>';
             html += '</tbody></table></div>';

            Popupobj.setHeadTitle(arrJsPopLabel['AddFormulaField']);
            Popupobj.show(html);
        });
    }
    this.saveColumnsAlias = function(){
        var popupobj = CrmPopup.getPopupObj("last");
        var divid = popupobj.divid;
        var definitionformula = ld('#'+divid).find('#definitionformula').val();
        var prefix = ld('#'+divid).find('#prefix').val();
        var suffix = ld('#'+divid).find('#suffix').val();
        var decimal_places = ld('#'+divid).find('#decimal_places').val();
        if(decimal_places<=0){
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['NotNegative']);return;
        }
        var tdheader_label = ld('#'+divid).find('#tdheader_label').val();
        var tdheader_label_en = ld('#'+divid).find('#tdheader_label_en').val();
        if(empty(definitionformula)||empty(tdheader_label)||empty(tdheader_label_en)){
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['NotEmpty']);return;
        }
        var param = {};
        param.columns = definitionformula;
        param.columnmodule = '';
        param.modulelabel = '';
        param.fieldlabel = tdheader_label;
        param.bigtype = '';
        param.typeofdata = 'NN';
        param.detailField = 'no';
        param.tdheader_label = tdheader_label;//初始化 中英文label都取用字段名称
        param.tdheader_label_en = tdheader_label_en;
        param.total_type = "formula";
        param.prefix = prefix;
        param.suffix = suffix;
        param.decimal_places = decimal_places;
        param.alias = '';

        CustomTablesColumnsObj.addTh(param,'');
        that.th_width = that.th_width + 200;
        //重新渲染表格--没存表的字段也需要加进去
        that.fieldSelected.push(param.columns);
        popupobj.CancelEvent();
        that.saveReportInfo("no");
        //重新渲染表格
        //that.renderReportTable();
        that.setScroll(that.th_width,215);
    }
    //wyt 220830 XUQIU1000509 自定义统计表选择模块字段增加模糊搜索
    this.fieldfuzzysearch=function(tagname,divid){
        var objs=ld('#' + divid).find('[tag='+tagname+']');
        ld.each(objs,function (i,obj) {
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(ld(obj).attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(that.popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(ld(obj),250);
            // ld(obj).select2({width:'100%',closeOnSelect: true});
        })
    }
    //滚动条
    this.setScroll = function(th_width,top_height){
        var windowWidth = CrmPopup.getClientWidth();
        var windowHeight = CrmPopup.getClientHeight();
        var PopupJqObj = ld('#'+that.divid);
        var right_width = PopupJqObj.find(" #div_thResizableContent").offset().left;
        right_width = right_width==undefined?0:right_width;
        top_height = PopupJqObj.find(" #div_thResizableContent").offset().top;//元素距离顶端的高度
        PopupJqObj.find(" #div_thResizableContent").css('width',(windowWidth-right_width-20)+'px').css('margin-left','20px').css('margin-right','20px');//宽度
        var height=windowHeight-top_height-70;
        if(th_width<=0){
            PopupJqObj.find(" #thResizable").css('width',(windowWidth-right_width-57)+'px');
        }else{
            PopupJqObj.find(" #thResizable").css('width',(parseInt(th_width)+17)+'px');
        }
        PopupJqObj.find(" #div_thResizableContent").css('height',height+'px');//宽度
        PopupJqObj.find(" #fieldListDiv").css('height',(parseInt(height)+60)+'px');
        //edit: xll 2024/03/21
        var scrollObj = PopupJqObj.find('#'+that.divid+'_scroll');
        scrollObj.find('.report-detail').css('height',(scrollObj.height() - 50) + 'px');
    }
    //模板选择页签的滚动条
    this.setTemplateScroll=function(){
        var popupobj = CrmPopup.getPopupObj('last');
        var windowHeight = CrmPopup.getClientHeight();
        var tabHeight = ld('#'+popupobj.divid).find('.ld-ui-tabs').outerHeight();
        var popheader = ld('#'+popupobj.divid+'_head').outerHeight();
        var popbottom = ld('#'+popupobj.divid+'_popupbottom').outerHeight();
        var height = windowHeight-tabHeight-popheader-popbottom;
        //模板选择页签的高度设置
        ld("#"+popupobj.divid+" .template-type-content").css('height',height+'px');
    }
}
CustomTablesCreate.createTable = function(report_id,frompage,parent_id ){
    var tmpwidth = ld(window).width();//全屏宽度
    var module = 'CustomTables';
    var CustomTablesCreateObj = new CustomTablesCreate();
    var Popupobj = CrmPopup.load("",  CustomTablesCreateObj.saveReportInfo,"", tmpwidth, module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
    Popupobj.prevshow();
    CustomTablesCreateObj.pagemode='create_edit';
    var url = "index.php?module="+CustomTablesCreateObj.pageto_module+"&action="+CustomTablesCreateObj.pageto_module+"Ajax&file=CustomTablesEditView&function_name=index&report_id="+report_id+"&report_type="+CustomTablesCreateObj.report_type+"&frommodule="+CustomTablesCreateObj.frommodule;
    if(parent_id!=undefined){
        url += '&parent_id='+parent_id;
    }
    ldAjaxNoProgress(url,{},function(data) {
        Popupobj.setHeadTitle(data.result.title);
        CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);
        var mode = "create";
        if(report_id>0){
            mode  = "edit";
        }
        CustomTablesCreateObj.setPopupobj(Popupobj);
        CustomTablesCreateObj.setDivid(Popupobj.divid);
        CustomTablesCreateObj.setReportId(report_id);
        CustomTablesCreateObj.init(mode);
        CustomTablesCreateObj.frompage = frompage;
        Popupobj.setEvent();
        Popupobj.CustomTablesCreateObj = CustomTablesCreateObj;
        CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
        CustomTablesCreateObj.setTemplateScroll();
        ld('#'+Popupobj.divid).find('#analysisfolder_id').select2({width:'100%',closeOnSelect: true});
    });
}

