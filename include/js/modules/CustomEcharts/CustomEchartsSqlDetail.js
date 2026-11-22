if(ld==undefined){
    var ld = $;
}
function CustomEchartsSqlDetail(){
    this.popupobj = "";
    this.divid = "";
    this.report_id = 0;
    var that = this;
    this.report_type='sqlchart';
    this.chart_type='line';
    this.chart_info={};
    this.pageto_module = 'ReportAnalysis';//现在只有报表分析模块了   直接写死
    this.homeparams = '';
    this.mychartjqobj = '';
    this.mytablejqobj = '';

    this.ChartSetInfo = null;
    this.sqlFilterArr = null;
    /** 筛选弹窗的内容Html */
    this.Searchhtml = '';
    this.LastSqlConditions = '';

    this.init = function(){
        if(that.popupobj && that.popupobj.divid){
            that.popupobj.ReportDetailObj = that;
        }
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
    this.SetChartJqObj = function (mychartjqobj) {
        that.mychartjqobj = mychartjqobj;
    }
    this.SetTableJqObj = function (mytablejqobj) {
        that.mytablejqobj = mytablejqobj;
    }
    this.show = function(popupobj,divid,report_id,chart_type,homeparams){
        that.setPopupobj(popupobj);
        that.setDivid(divid);
        that.setReportId(report_id);
        that.setChartType(chart_type);
        that.setHomeParams(homeparams);
        that.init();
        /*if(that.mychartjqobj==''){
            that.mychartjqobj=ld('#'+that.divid+' #myChart_' + that.report_id);
        }
        if(that.mytablejqobj==''){
            that.mytablejqobj=ld('#'+that.divid+' #chartTable_' + that.report_id);
        }*/
        that.getReportInfo();
        that.setEvent();
    }
    //设置事件
    this.setEvent = function(){
        //筛选按钮点击事件
        if(that.Searchhtml === '') {
            var SearchObj = ld('#'+that.divid+' #searchList');
            if(SearchObj.length > 0){
                SearchObj.css('display','block');
                // SearchObj.css('width','1000px');
                that.Searchhtml = SearchObj.get(0).outerHTML;
                SearchObj.remove();
            }
        }
        ld('#'+that.divid).find('#OtherCondition').unbind('click').bind('click',function() {
            that.SetOtherCondition();
        });
    }

    this.SetOtherCondition = function () {
        var allwidth = ld(window).width();
        var widthcss = "LdPopWidth1100px";
        if(allwidth<1000){
            widthcss = "LdPopWidth"+allwidth+"px";
        }
        if(that.Searchhtml !== ''){
            var Popupobj = CrmPopup.load( arrJsPopLabel['CONDITION'], that.getReportInfo, "", widthcss, "CustomEcharts", "", arrJsPopLabel['SEARCHCAPITAL'], "", arrJsPopLabel['CANCEL']);
            //Popupobj.createScrollDiv();//创建滚动条
            Popupobj.prevshow();
            Popupobj.show(that.Searchhtml);
            //Popupobj.center();
            var JqPopupobj = ld('#'+Popupobj.divid);
            if(allwidth<1000) {
                JqPopupobj.css('left', '0');
            }
            var SearchObj = JqPopupobj.find(' #searchList');
            SearchObj.css('display','block');
            //记住上一次的搜索值
            if(that.LastSqlConditions !== ''){
                //edit: xll 2024/07/02 BUG20240611-39 审批勾选取消保存后，仍显示勾选
                SearchObj.find("[name='sqlvar_approvestatus[]']").prop('checked',false);
                ld.each(that.LastSqlConditions.split('&'),function (index,filterInfo) {
                    var Info = filterInfo.split('=');
                    var filterName = decodeURIComponent(Info[0]);
                    var filterValue = decodeURIComponent(Info[1]);
                    var filterObj = SearchObj.find("[name='"+filterName+"']");
                    var filterType = filterObj.parents('td').attr('var_type');
                    if(that.SetFilterObjVal[filterType])
                        that.SetFilterObjVal[filterType](filterObj,filterValue);
                    else
                        filterObj.attr('value',filterValue);
                });
            }
            //多选框特殊处理
            var MultiSel_TdObj = JqPopupobj.find('#conditionColumnList td[var_type="multiselect"]');
            MultiSel_TdObj.children(' .select2').remove();
            MultiSel_TdObj.find(' select').select2({width:'100%',closeOnSelect: true});
            that.SearchPopupobj = Popupobj;
        }
        else {

        }
    }
    this.SetFilterObjVal = {
        select : function (filterObj,filterValue) {
            filterObj.find("option[value='"+filterValue+"']").prop('selected',true);
        },
        multiselect : function (filterObj,filterValue) {
            filterObj.find("option[value='"+filterValue+"']").prop('selected',true);
        },
        checkbox : function (filterObj,filterValue) {
            filterObj.prop('checked',(filterValue === 'on'));
        },
        approvestatus : function (filterObj,filterValue) {
            filterObj.filter("[value='"+filterValue+"']").prop('checked',true);
        },
    }

    this.getReportInfo = function(){
        var filterParams = '';
        if(that.SearchPopupobj && that.SearchPopupobj.divid) {
            var SearchObj = ld('#'+that.SearchPopupobj.divid+' #searchList');
            var SqlConditions = SearchObj.find('#SqlConditionsForm').serialize();
            that.LastSqlConditions = SqlConditions;

            that.Searchhtml = SearchObj.get(0).outerHTML;
            filterParams += '&' + SqlConditions;
            that.SearchPopupobj.CancelEvent();
        }
        ld('#rptContentLoading').show();
        var divid = that.divid;
        var report_id = that.report_id;
        var params = '&report_id='+report_id;
        // if(that.ChartSetInfo !== null){
        //     params += '&ChartSetInfo='+ JSON.stringify(that.ChartSetInfo);
        // }
        if(that.sqlFilterArr !== null){
            params += filterParams;
        }
        //设置首页条件
        params += that.homeparams;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SqlEchartsDetailView&function_name=getChartData';
        ldAjaxNoProgress(url,params,function(res) {
            if(res.code==-1){
                var tmpmsg = empty(res.msg)?arrJsPopLabel['NODATAFOUND']:res.msg;

                ld('#myChart_'+that.report_id).html('<div class="home_nomsg_div" style="height:calc(100% - 55px)">\n' +
                    '          <div>\n' +
                    '              <img class="icon-empty" alt="'+tmpmsg+'" src="themes/images/emptyinfo.png">\n' +
                    '              <span>'+tmpmsg+'</span>\n' +
                    '          </div>\n' +
                    '      </div>');
                if(that.mytablejqobj)
                    that.mytablejqobj.html('');
                return;
            }
            if (res.code == 1) {
                var chart_info = res.result;
                if(that.mytablejqobj) {
                    that.mytablejqobj.html(chart_info['chartSet']['table']);
                    var tableHeight = that.mytablejqobj.outerHeight();
                    if (tableHeight >= 300) {
                        tableHeight = 300;
                        that.mytablejqobj.css('height', '300px').css('overflow-y', 'auto');
                    }
                    if(that.mychartjqobj!='') {
                        that.mychartjqobj.css('height', 'calc(100% - ' + tableHeight + 'px)');
                    }
                    that.setScroll(tableHeight);
                }

                getJsScript('include/js/modules/CustomEcharts/renderChart.js',function() {
                    var customRenderChart = new customRenderChartFun();
                    if(that.mychartjqobj!='')
                    {
                        customRenderChart.SetChartJqObj(that.mychartjqobj);
                    }
                    customRenderChart.setChart(chart_info['chartSet'], chart_info.mainInfo.report_id, chart_info.fromhome);

                    that.ChartSetInfo = chart_info.ChartSetInfo;
                    that.sqlFilterArr = chart_info.sqlFilterArr;
                    ld('#rptContentLoading').hide();
                });
            }
        });
    }
    //滚动条
    this.setScroll = function(tableHeight){
        getJsScript('include/js/menucommon.js', function () {
            var windowWidth = that.mytablejqobj.outerWidth();
            var ld_tableContentObj = ld("#" + that.divid).find('[tag=ld_tableContent]');
            if (ld_tableContentObj.length > 0) {
                ld.each(ld_tableContentObj, function (i, itemobj) {
                    var options = {'height':(tableHeight/ld_tableContentObj.length)-10, 'width': windowWidth, 'thwidth': 145};
                    lockingHeaderColumn(itemobj, options);
                })
            }
        });
    }
}

