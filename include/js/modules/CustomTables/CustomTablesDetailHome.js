AjaxJSPage("CustomTablesDetail_js", 'include/js/modules/CustomTables/CustomTablesDetail.js');

function CustomTablesDetailHome(){
    CustomTablesDetail.call(this);
    var that = this;
    this.homeparams = '';
    this.showtype = 'Kanban';//报表展现类型  Kanban显示在看板 Popup弹窗显示  不同形式主要是计算高度宽度有差别
    this.class_name = 'cls_CustomTablesDetailViewHome';
    this.init = function(){
        //表体 对象
        that.reportDetailBodyObj = ld('#'+that.divid).find('[tag=reportDetailBody]');
        that.reportDetailHeaderObj = ld('#'+that.divid).find('[tag=reportDetailHeader]');
    }
    this.setShowType = function(showtype){
        that.showtype = showtype;
    }
    //获取统计表表格   的 url
    this.getTableUrl = function(){
        var url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=CustomTablesDetailView&class_name="+that.class_name+"&function_name=getDetailData";
        url+="&limitrecord=200";
        url+="&pagenum=1";
        url+='&pagemode=detail';
        return url;
    }
    //获取统计表表格   的 参数
    this.getTableParams = function(){
        var params = '&report_id='+that.report_id;
        params += that.homeparams;
        var chartInfoForm = ld('#'+that.divid).find('#chartInfoForm').serialize();//页面上所有的字段值
        params += '&'+chartInfoForm;
        return params;
    }
    //设置首页条件
    this.setHomeParams = function(homeparams){
        that.homeparams = homeparams;
    }
    this.show = function(popupobj,divid,report_id,homeparams){
        that.setPopupobj(popupobj);
        that.setDivid(divid);
        that.setReportId(report_id);
        that.init();
        that.setHomeParams(homeparams);
        that.renderReportTable();
    }
}
CustomTablesDetailHome.showTableDetail = function(report_id,homeParams){
    var tmpwidth = ld(window).width();//全屏宽度
    var module = 'CustomTables';
    var Popupobj = CrmPopup.load("",  "","", tmpwidth, module, "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['LBL_CLOSE']);
    Popupobj.isShowDetail = 'yes';
    Popupobj.setParams("查看统计表","",'',tmpwidth,module,"" ,arrJsPopLabel['Confirm'],"", arrJsPopLabel['LBL_CLOSE']);
    Popupobj.prevshow();
    var file = 'CustomTablesDetailView';
    var url = "index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file="+file+"&class_name=cls_CustomTablesDetailViewHome&function_name=index&report_id="+report_id;
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
                    this.popupheadhtml += '<div class="ld-button" data-id="' + report_id + '" frompage="fromdetail" tag="editTable">' + arrJsPopLabel["EDIT"] + '</div>';
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
            var CustomTablesDetailHomeObj = new CustomTablesDetailHome();
            CustomTablesDetailHomeObj.setShowType('Popup');
            CustomTablesDetailHomeObj.show(Popupobj,Popupobj.divid,report_id,homeParams);
            CustomTablesDetailHomeObj.renderCondition();
            CustomTablesDetailHomeObj.setEvent();
            CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
            //表头拖动
            ld('#thResizable').resizableColumns('thResizable',report_id,CustomTablesDetailHomeObj);
        }
    });
}
