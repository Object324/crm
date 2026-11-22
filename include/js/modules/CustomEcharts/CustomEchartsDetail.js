if(ld==undefined){
    var ld = $;
}
function CustomEchartsDetail(){
    this.popupobj = "";
    this.divid = "";
    this.report_id = 0;
    var that = this;
    this.report_type='chart';
    this.chart_type='line';
    this.chart_info = {};
    this.pageto_module = 'ReportAnalysis';//报表分析模块  现在确定是报表分析模块  写死
    this.homeparams = '';
    this.mychartjqobj = '';
    this.mytablejqobj = '';

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
    this.SetOtherCondition = function () {
        var afterOkfunTask = function () {

            that.getReportInfo();
        }
        //edit: xll 20/11/14 BUG0074940 企业微信移动端，报表->测试单折线图 点击“筛选”操作按钮没有反应
        var fun = function () {
            var SetOtherConditionsObj = new SetOtherConditions();
            SetOtherConditionsObj.SetDirDataObj(that.ChartSetInfo.OtherCondition);
            SetOtherConditionsObj.addTaskAfterOkfun(afterOkfunTask,{});
            SetOtherConditionsObj.fun_other_conditions();
        }
        getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
            if(frommobile !== undefined && frommobile === 'yes'){
                getJsScript('include/js/SystemPopup/PopupLayer.js', function () {
                getJsScript('include/js/SystemPopup/PopupDrag.js', function () {
                getJsScript('include/js/modules/CustomView/CustomView.js', function () {
                getJsScript('include/js/advancefilter.js', function () {
                getJsScript('include/js/SystemPopup/PageRecordPopup.js', function () {
                    fun();
                });
                });
                });
                });
                });
            }
            else {
                fun();
            }
        });
    }
    this.setEvent = function() {
        //筛选按钮点击事件
        ld('#'+that.divid).find('#OtherCondition').unbind('click').bind('click',function() {
            that.SetOtherCondition();
        });
        //表格穿透 gotoList
        ld('#' + that.divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
            that.gotoList(this);
        });
        tooltip('.sort-tip-items', {transition: true, time: 200});
    }
    this.gotoList = function(obj){
        //获取这个td是这一行的第几个
        var tdindex = ld(obj).parent().attr('tdindex');
        var tmpxaxisname = ld(obj).data('xaxisname');//嵌套饼图 有2行th 不好取 直接写个属性吧
        var rowindex = Tools.getParentobjByChild(obj,'tr').attr('rowindex');
        var thobj = Tools.getParentobjByChild(ld(obj),'tr').find('td:first');//这个应该是当前行的th zxm 20231120 BUG0075737	kfbcrm-报表分析“两个维度”统计图，勾选了允许穿透，下方报表点击超链接 弹出层中显示单据数
        var tableobj = Tools.getParentobjByChild(ld(obj),'table');//点击的哪个表格
        let url = "index.php?module="+that.pageto_module+"&action="+that.pageto_module+"Ajax&file=SelfDefinedReport";
        var fromhome='no';
        var XAxisName = tableobj.find('thead th[thindex='+tdindex+']').text();
        if(tmpxaxisname){
            XAxisName = tmpxaxisname;
        }

        var SeriesName = thobj.text();
        var params_data = '&ChartSetInfo='+encodeURIComponent(JSON.stringify(that.ChartSetInfo));
        params_data += '&XAxisName='+encodeURIComponent(XAxisName)+'&SeriesName='+encodeURIComponent(SeriesName);
        params_data += '&SeriesIndex='+rowindex+'&fromhome='+fromhome;
        //移动端
        if(typeof frommobile !== 'undefined' && frommobile === 'yes' && typeof environment !== 'undefined') {
            var YAxis = that.ChartSetInfo.AxisFields.YAxis;
            var cur_computeinfo;

            if(that.ChartSetInfo['chart_type']=='nesting_pie'||YAxis.length==1){
                //嵌套饼图就一个统计字段
                cur_computeinfo = YAxis[0];
            }else{
                cur_computeinfo = YAxis[rowindex];
            }

            customRenderChartFun.ChartPenetrateMobile({
                url : url,
                params_data : params_data,
                frommobile : frommobile,
                environment : environment,
                mainmodule : mainmodule,
                penetrateModule : cur_computeinfo['FieldModule'],
                modulelabel : modulelabel,
                crm_url : crm_url,
            });
        }
        //pc端
        else {
            url += '&function_name=getPenetrateModuleList';
            var options = {
                report_id : that.report_id,
            }
            getJsScript('include/js/modules/Home/HomeStuffChuantou.js', function () {
                var ChartChuantouObj = new HomeStuffChuantou();
                if(fromhome === 'yes')
                    ChartChuantouObj.CustomEchartsChuantou_Home(url,params_data,options);
                else
                    ChartChuantouObj.CustomEchartsChuantou_Report(url,params_data);
            });
        }
    }
    this.setFieldRes=function(rowindex){
        that.countFieldRes[rowindex] = {};
        that.sumFieldRes[rowindex] = {};
    }
    this.getReportInfo = function(){
        var param = '&is_ajax=yes&step=0&function_name=getChartData&is_ajax=yes&report_id='+that.report_id;
        if(that.ChartSetInfo){
            var advance_demand = that.ChartSetInfo.OtherCondition.advance_demand;
            var advance_demand_groups = that.ChartSetInfo.OtherCondition.advance_demand_groups;
            //edit:can 20240111-41 客户自己做的一个销售订单漏斗图，设置按创建时间筛选的时候下面数据都没有变化，条件不生效，麻烦查一下
            param+='&is_search=yes';
            param += '&advance_demand='+advance_demand+'&advance_demand_groups='+advance_demand_groups;
        }
        //设置首页条件
        param += that.homeparams;
        var url = 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file=SelfDefinedReport';
        ldAjaxNoProgress(url,param,function (e) {
            if(e.code==-1) {
                var tmpmsg = empty(e.msg) ? arrJsPopLabel['NODATAFOUND'] : e.msg;

                ld('#myChart_' + that.report_id).html('<div class="home_nomsg_div" style="height:calc(100% - 55px)">\n' +
                    '          <div>\n' +
                    '              <img class="icon-empty" alt="' + tmpmsg + '" src="themes/images/emptyinfo.png">\n' +
                    '              <span>' + tmpmsg + '</span>\n' +
                    '          </div>\n' +
                    '      </div>');
                if (that.mytablejqobj) {
                    that.mytablejqobj.html('');
                    return;
                }
            }
            that.chart_info = e.result.list;
            //记住搜索条件，ChartSetInfo不应该重新赋值
            if (!that.ChartSetInfo) {
                that.ChartSetInfo = e.result.ChartSetInfo;
            }
            var chart_info = e.result.list;
            if (that.mytablejqobj) {
                that.mytablejqobj.html(chart_info.table);
                var tableHeight = that.mytablejqobj.outerHeight();
                if (tableHeight >= 300) {
                    tableHeight = 300;
                    that.mytablejqobj.css('height', '300px').css('overflow-y', 'auto');
                }
                if (that.mychartjqobj != '') {
                    that.mychartjqobj.css('height', 'calc(100% - ' + tableHeight + 'px)');
                }
                that.setScroll(chart_info,tableHeight);
            }

            getJsScript('include/js/modules/CustomEcharts/renderChart.js', function () {
                var customRenderChart = new customRenderChartFun();
                if (that.mychartjqobj != '') {
                    customRenderChart.SetChartJqObj(that.mychartjqobj);
                }
                customRenderChart.setChart(e.result.list, that.report_id, that.chart_info.fromhome);
                customRenderChart.SetChartInfo({
                    ChartSetInfo: that.ChartSetInfo,
                });

                //表格穿透 gotoList
                ld('#' + that.divid).find('[tag=gotoList]').unbind('click').bind('click', function () {
                    that.gotoList(this);
                });
            });

        });
    }

    this.setScroll = function(chart_info,tableHeight){
        //var windowWidth = ld("#"+that.divid).outerWidth();
        getJsScript('include/js/menucommon.js', function () {
            var windowWidth = that.mytablejqobj.outerWidth();
            var ld_tableContentObj = ld("#" + that.divid).find('[tag=ld_tableContent]');
            if (ld_tableContentObj.length > 0) {
                ld.each(ld_tableContentObj, function (i, itemobj) {
                    var options = {'height': (tableHeight/ld_tableContentObj.length)-10, 'width': windowWidth, 'thwidth': 145};
                    lockingHeaderColumn(itemobj, options);
                })
            }
        });
    }
}
