if(ld==undefined){
    var ld = $;
}
function CustomTablesDetail(){
    this.popupobj = "";
    this.divid = "";
    this.moduleHaveSelected = [];
    this.fieldSelected = [];
    this.columnsSelected = [];
    this.columnsFormula = [];
    this.columnsAlias = [];
    this.report_id = 0;
    this.timeValueArr = {};
    var that = this;
    this.pagerows=1;
    this.pagestart=1;
    this.maxpagecount=1;
    this.report_type='selectfield';
    this.chartInfo='';
    this.th_width=0;
    this.pageto_module = 'ReportAnalysis';
    this.pagenum  = 1;//第几页
    this.reportDetailBodyObj;//表体 对象
    this.reportDetailHeaderObj;//表头 对象
    this.showtype = 'Popup';//报表展现类型  Kanban显示在看板 Popup弹窗显示  不同形式主要是计算高度宽度有差别
    this.init = function(mode){
         //表体 对象
        that.reportDetailBodyObj = ld('#'+that.divid).find('[tag=reportDetailBody]');
        that.reportDetailHeaderObj = ld('#'+that.divid).find('[tag=reportDetailHeader]');
        that.renderReportTable();
        that.renderCondition();
        //设置事件
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
    //设置事件
    this.setEvent = function(){
        ld('#'+that.divid).find('#toggleSearch').unbind('click').bind('click',function() {
            ld('#'+that.divid).find('#searchList').toggle(1000);
            var prop = ld(this).prop('checked');
            var isshow_search = prop?'yes':'no';
            var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=CustomTablesEditView";
            var param = "is_ajax=yes&function_name=changeReportStatus&reportid=" + that.report_id+'&isshow_search='+isshow_search;
            ldAjaxNoProgress(url,param,function(res) {
               console.log('修改成功');
            });
            setTimeout(function(){that.setScroll(that.th_width,215);},1000);
        });
        ld('#'+that.divid).find('#toSearch').unbind('click').bind('click',function() {
            ld("#"+that.divid+" [name='pagenum']").val(1);
            that.renderReportTable();
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

        //导出
        ld('#'+that.divid).find('#exportTableDetail').unbind('click').bind('click',function(e) {
            that.exportTableDetail();
        });
        //分屏视图的统计表导出
        ld('#reportanalysis_screen').find('#exportTableDetail').unbind('click').bind('click',function(e) {
            that.exportTableDetail();
        });
        //打印
        ld('#'+that.divid).find('#printTableDetail').unbind('click').bind('click',function(e) {
            that.printTableDetail();
        });
        //分屏视图的打印
        ld('#reportanalysis_screen').find('#printTableDetail').unbind('click').bind('click',function(e) {
            that.printTableDetail();
        });
        ld('#'+that.divid).find('[tag=editTable]').unbind('click').bind('click',function(e) {
            that.editTable(this);
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
    //获取统计表表格   的 url
    this.getTableUrl = function(){
        var divid = that.divid;
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=CustomTablesDetailView&class_name=cls_CustomTablesDetailView&function_name=getDetailData";
        var limitrecord = ld("#"+divid+ " [name=limitrecord]").val();//每页限制条数
        that.pagenum = ld("#"+divid+" [name='pagenum']").val();//第几页
        that.maxpagecount = Math.ceil(that.pagerows/limitrecord) ;
        url+="&limitrecord="+limitrecord;
        url+="&pagenum="+that.pagenum;
        url+='&totalrows='+that.pagerows;
        url+='&pagemode='+that.mode;
        return url;
    }
    //获取统计表表格   的 参数
    this.getTableParams = function(){
        var divid = that.divid;
        var chartInfoForm = ld('#'+divid).find('#chartInfoForm').serialize();//页面上所有的字段值
        var params = '&report_id='+that.report_id;
        params += '&'+chartInfoForm;
        if(typeof frommobile!='undefined' && frommobile=='yes'){
            params += '&frommobile='+frommobile;
        }
        return params;
    }

    //请求和渲染表格数据
    this.renderReportTable = function(){
        ld('#rptContentLoading').show();
        var url = that.getTableUrl();
        var params = that.getTableParams();
        if(that.pagerows>0&&parseInt(that.pagenum)>that.maxpagecount)
        {
            ld('#rptContentLoading').hide();
            return ;
        }

        ldAjaxNoProgress(url,params,function(ajaxdata){
            var content = ajaxdata.result.content;
            that.mergeRowInfo = ajaxdata.result.mergeRowInfo;
            that.reportDetailBodyObj.empty().append(content);//zxm清空原有数据 不重复显示 bug0048343
            var columnsArr = ajaxdata.result.columnsArr;
            that.th_width = that.renderHeader(columnsArr);

            that.setPageStyle(ajaxdata.result,that.pagenum);//分页样式
            ld('#rptContentLoading').hide();
            that.setScrollBytype(that.th_width,130);
            //列固定
            AjaxJSPage("freezecolumns_js", 'include/js/freezecolumns.js');
            var freezecolumnsObj = new FreezeColumns();
            freezecolumnsObj.init('thResizable');//冻结列类初始化
            freezecolumnsObj.setpopupobj(that.popupobj,that.divid);
            var width = freezecolumnsObj.freezeThColumnBeforeAll('set-sticky');
            freezecolumnsObj.freezeTdColumnBeforeAll('set-sticky',width);
            ld('#'+that.divid).find('.customtable-droplist').css('z-index','9999');

            //合并行：隔行换色，背景色
            that.changeRowColor();
        });
    }
    //详情页的表头
    this.renderHeader = function(columnsArr){
        //表头
        var headerHtml = '';
        if(columnsArr.length<=0){
            return 0;
        }
        var all_width = 0;
        var width_style="width:calc(100% - 2px);";
        ld.each(columnsArr,function(index,item){
            var th_width = item.header_width>0?item.header_width:200;
            all_width = parseInt(all_width)+parseInt(th_width);
            var sticky_class = item.issticky=='yes'?'set-sticky':'';
            headerHtml += '<th thindex="'+index+'" tag="'+item.columns+'" class="'+sticky_class+'" style="position: relative;width:'+th_width+'px;'+item.styleset_header+'">\n' +
                '<div class="thead-content">\n';
            headerHtml +='<span class="field-name" style="'+width_style+'text-align: '+item.align+'">'+item.fieldlabel+'</span>\n' +
                '</div>\n' +
                '</th>';
        });
        that.reportDetailHeaderObj.html(headerHtml);
        return all_width;
    }
    //详情页的条件
    this.renderCondition = function(){
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=CustomTablesDetailView&class_name=cls_CustomTablesDetailView&function_name=getReportConditions";
        var params = 'report_id='+that.report_id;
        ldAjaxNoProgress(url,params,function(ajaxdata) {
            that.timeValueArr = ajaxdata.result.timeValueArr;
            var reportConditions = ajaxdata.result.reportConditions;
            var searchFieldRes = ajaxdata.result.searchFieldRes;

            var CustomTablesConditionsObj = new CustomTablesConditions();
            CustomTablesConditionsObj.setPopupobj(that.Popupobj);
            CustomTablesConditionsObj.setDivid(that.divid);
            CustomTablesConditionsObj.init(searchFieldRes, that.timeValueArr, that.mode);//初始化条件表格
            if (reportConditions.length > 0) {
                getJsScript('include/js/modules/CustomTables/CustomTablesConditions.js', function () {
                    //编辑 遍历渲染条件数据
                    //初始删除所有行
                    CustomTablesConditionsObj.removeAllRow();
                    if (reportConditions != null && reportConditions.length > 0) {
                        //渲染条件
                        ld.each(reportConditions, function (idx, itm) {
                            CustomTablesConditionsObj.addrow(itm, null);
                            if (reportConditions.length - 1 == idx) {
                                //最后个空行增加新条件的按钮
                                CustomTablesConditionsObj.addrow({'type': 'emptyline'}, null);
                            }
                        });
                    } else {
                        //BUG0064572  报表新建/编辑/查看界面，“添加组合条件”预置一行查询字段，默认显示第一个字段
                        if (ld('#' + that.divid + ' #conditionColumnBody').find('tr').length == 0) {
                            CustomTablesConditionsObj.addgroupcondition(ld('#' + that.divid + ' [tag=addgroupcondition]'));
                        }
                        //CustomTablesConditionsObj.addrow({'groupid':1});
                    }
                });
            }else{
                if (ld('#' + that.divid + ' #conditionColumnBody').find('tr').length == 0) {
                    CustomTablesConditionsObj.addgroupcondition(ld('#' + that.divid + ' [tag=addgroupcondition]'));
                }
            }
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
    this.editTable = function(obj){
        var  report_id = ld(obj).attr('data-id');
        var  frompage = 'fromlist';
        frompage = ld(obj).attr('frompage');
        var  parent_id = ld(obj).attr('data-parentid');
        getJsScript('include/js/modules/CustomTables/CustomTablesCreate.js', function () {
            CustomTablesCreate.createTable(report_id,frompage,parent_id);
        });
    }
    //导出
    this.exportTableDetail = function(){
        var url = that.getTableUrl();
        var params = that.getTableParams();
        url = url+"&Export=true"+ '&export_first=yes' +"&startExportRow=0" + "&endExportRow=10" + "&listCounts=" + that.pagerows;

        // wsh 20240814 XUQIU20240708-01 报表管理-报表分析-自定义统计表/SQL统计表 导出优化数据多的情况下做成单据列表那种的进度条导出，现在的做法数据多直接内存溢出
        getJsScript('include/js/SystemPopup/ExportPopup.js',function() {
            var crmPopupobj = ExportPopup.load("", "", "", "LdPopWidth500px", that.pageto_module, "", 'none', "", "");
            crmPopupobj.prevshow();
            ldAjaxNoProgress(url,params,function(ajaxdata){
                if (ajaxdata.code === 1) {
                    crmPopupobj.setParams(ajaxdata.result.title, "", "", "LdPopWidth500px", that.pageto_module, "", "", "", "");
                    crmPopupobj.show();
                    that.eachExportCount = that.pagerows > 2000 ? (that.pagerows < 5000 ? 100 : 200) : 20;
                    that.Export_report(crmPopupobj, ajaxdata.result.endExportRow, parseInt(ajaxdata.result.endExportRow, 10) + parseInt(that.eachExportCount, 10));
                }
            });
        });
    }

    this.Export_report = function (crmPopupobj, startExportRow, endExportRow) {
        var url = this.getTableUrl()+"&Export=true"+"&startExportRow=" + startExportRow + "&endExportRow=" + endExportRow+ "&listCounts=" + that.pagerows;
        var is_close = true;
        //点击关闭停止导出
        if(ld("#" + crmPopupobj.divid).length <= 0){
            is_close = false;
        }
        if (is_close == true){
            ldAjaxNoProgress(url,this.getTableParams(),function(ajaxdata){
                //先走后台判断是否已经导出完毕,没有导出完返回code=1继续导出,导出完返回code=2跳转到下载的url
                if (ajaxdata.code == 1) {
                    that.Export_report(crmPopupobj,ajaxdata.result.endExportRow , parseInt(ajaxdata.result.endExportRow, 10) + parseInt(that.eachExportCount, 10));
                    crmPopupobj.update_progress(startExportRow,that.pagerows);//更新进度条
                } else if (ajaxdata.code == 2) {
                    that.exportresulthtml(ajaxdata.result.report_name)
                    ld("#dvExportprogress").css("width", "100%");
                    ld('#rptContentLoading').hide();
                }
            });
        }else {
        }
    }

    this.exportresulthtml = function (report_name) {
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.CancelEvent();
        var surl = 'index.php?module=' + that.pageto_module + "&action=" + that.pageto_module + "Ajax&file=ExportResult&export_type=report" + "&report_name=" + encodeURIComponent(report_name);
        var crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth500px", that.penetrateModule, "", 'none', "", "");
        crmPopupobj.prevshow();
        ldAjaxNoProgress(surl,'',function (data) {
            DelProgressObjs();
            if (data.code == 1) {
                crmPopupobj.setParams(data.result.title, "", "", "LdPopWidth500px", that.penetrateModule, "", "", "", "");
                crmPopupobj.show(data.result.content);
            }
        });
    }
    //打印---纯js
    this.printTableDetail = function(){
        var popupobj = that.popupobj;
        var divid = popupobj.divid;
        ld('#'+divid).find('.module-label').hide();
        ld('#'+divid).find('.customtable-droplist').hide();
        ld('#'+divid).find('.customtable-list').attr('border',1).attr('cellspacing',0);
        ld('#'+divid).find('#thResizable').css('margin','');
        var bdhtml=window.document.body.innerHTML;
        var sprnstr="<!--startprint-->"; //开始打印标识字符串有17个字符
        var eprnstr="<!--endprint-->"; //结束打印标识字符串
        var prnhtml=bdhtml.substr(bdhtml.indexOf(sprnstr)+17); //从开始打印标识之后的内容
        prnhtml=prnhtml.substring(0,prnhtml.indexOf(eprnstr)); //截取开始标识和结束标识之间的内容
        getJsScript('include/js/modules/CustomTables/CustomTables.js',function() {
            CustomTablesObj.customPrint(prnhtml);
        });
        // window.document.body.innerHTML = prnhtml; //把需要打印的指定内容赋给body.innerHTML
        // window.print(); //调用浏览器的打印功能打印指定区域
        // window.document.body.innerHTML=bdhtml;//重新给页面内容赋值；
        // that.setEvent('detail');
        ld('#'+divid).find('.customtable-list').attr('border',0).attr('cellspacing',1);
        ld('#'+divid).find('#thResizable').css('margin','0 auto');
        ld('#'+divid+'_imgclose').bind('click',function(){
            popupobj.CancelEvent();//重新绑定点击事件
        });
        return false;
    }
    //滚动条
    this.setScroll = function(th_width,top_height){
        var windowWidth = CrmPopup.getClientWidth();
        var windowHeight = CrmPopup.getClientHeight();
        var divid = that.divid;
        var right_width = ld("#"+divid+" #div_thResizableContent").offset().left;
        right_width = right_width==undefined?0:right_width;
        top_height = ld("#"+divid+" #div_thResizableContent").offset().top;//元素距离顶端的高度
        if(typeof frommobile!="undefined" && frommobile=='yes'){
            ld("#"+divid+" #div_thResizableContent").css('width',(windowWidth-right_width)+'px');//宽度
            var height=windowHeight-top_height;
        }else{
            ld("#"+divid+" #div_thResizableContent").css('width',(windowWidth-right_width-20)+'px').css('margin-left','20px').css('margin-right','20px');//宽度
            var height=windowHeight-top_height-70;
        }
        if(th_width<=0){
            ld("#"+divid+" #thResizable").css('width',(windowWidth-right_width-57)+'px');
        }else{
            ld("#"+divid+" #thResizable").css('width',(parseInt(th_width)+17)+'px');
        }
        ld("#"+divid+" #div_thResizableContent").css('height',height+'px');//宽度
    }
    this.setScrollBytype = function(th_width,top_height){
        var funName = 'setScroll'+that.showtype;
        var setScrollArr = {
            setScrollKanban:function(th_width,top_height){
                //看板页面显示  滚动条计算
                var divid = that.divid;
                var allWidth = ld("#"+divid).width();
                var allHeight = ld("#"+divid).height();

                ld("#"+divid+" [tag=div_thResizableContent]").css('width',(allWidth-40)+'px').css('overflow','auto');//宽度
                ld("#"+divid+" [tag=div_thResizableContent]").css('height',allHeight+'px');//高度
                if(parseInt(th_width)+17>(allWidth-40)){
                    ld("#"+divid+" #thResizable").css('width',(parseInt(th_width)+17)+'px');
                }else{
                    ld("#"+divid+" #thResizable").css('width',(allWidth-40)+'px');
                }

            },
            setScrollPopup:function(th_width,top_height){
                //表头拖动
                ld('#' + that.divid + " #thResizable").resizableColumns('thResizable', that.report_id,that);
                //穿透弹窗页面  滚动条计算
                that.setScroll(th_width,top_height);

            }
        }
        setScrollArr[funName](th_width,top_height);
    }
}
CustomTablesDetail.showTableDetail = function(report_id){
    var tmpwidth = ld(window).width();//全屏宽度
    var module = 'CustomTables';
    var Popupobj = CrmPopup.load("",  "","", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['LBL_CLOSE']);
    Popupobj.isShowDetail = 'yes';
    Popupobj.setParams("查看统计表","",'',tmpwidth,module,"" ,arrJsPopLabel['Confirm'],"", arrJsPopLabel['LBL_CLOSE']);
    Popupobj.prevshow();
    var file = 'CustomTablesDetailView';
    var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file="+file+"&function_name=index&report_id="+report_id;
    ld.ajax({
        url: url,
        type: 'POST',
        dataType: 'json',
        async: true,
        timeout: 20000,
        success: function (data) {
            var permit_print = data.result.permit_print;//打印权限
            var permit_export = data.result.permit_export;//导出权限
            var permit_editview = data.result.permit_create;//编辑权限
            //重写弹出头
            Popupobj.createHeadHtml = function (){
                this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
                this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
                this.popupheadhtml +='<div class="E_pop_tit_Second_Right" style="float: right;">';
                if (permit_editview != undefined && permit_editview == "yes") {
                    this.popupheadhtml += '<div class="ld-button ld-button-primary" data-id="' + report_id + '" frompage="fromdetail" tag="editTable">' + arrJsPopLabel["EDIT"] + '</div>';
                }
                if (permit_print != undefined && permit_print == "yes") {
                    this.popupheadhtml += '<div class="ld-button" href="javascript:;" id="printTableDetail">' + arrJsPopLabel['PRINT'] + '</div>';
                }
                //zxm 2022-0118  自定义统计表 导出按钮  打印按钮
                if (permit_export != undefined && permit_export == "yes") {
                    this.popupheadhtml += '<div class="ld-button" id="exportTableDetail">' + arrJsPopLabel['ExportExcel'] + '</div>';
                }
                this.popupheadhtml += '<div class="E_ptitc" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
                this.popupheadhtml += '</div>';
                this.popupheadhtml += '</div>';
            }
            //自定义统计表打开详情弹框不要底部按钮
            Popupobj.createBottomHtml = function(){
                this.popupbottomhtml = '';
            }
            var reportName = data.result.title;
            Popupobj.setHeadTitle(reportName);
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);
            var CustomTablesDetailObj = new CustomTablesDetail();
            CustomTablesDetailObj.setPopupobj(Popupobj);
            CustomTablesDetailObj.setDivid(Popupobj.divid);
            CustomTablesDetailObj.setReportId(report_id);
            CustomTablesDetailObj.init();
            CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
            //表头拖动
            ld('#thResizable').resizableColumns('thResizable',report_id,CustomTablesDetailObj);
        }
    });
}
