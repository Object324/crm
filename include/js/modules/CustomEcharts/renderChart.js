//渲染统计图的js
function customRenderChartFun   () {
    this.myChartObj = '';//图表对象
    this.chartType = 'line';//图表类型 默认给line
    this.data = "";//图标数据
    this.option = {};//option
    this.report_id = 0;//报表ID
    this.fromhome = "no";//是否是显示在 首页的
    var that = this;
    this.myChartId = 'myChart';
    this.pageto_module = 'ReportAnalysis';
    this.mychartjqobj = '';
    this.setMyChartId = function(myChartId){
        that.myChartId = myChartId;
    }
    this.SetChartInfo = function (Option) {
        that.ChartSetInfo = Option.ChartSetInfo;
    }
    this.SetChartJqObj = function (mychartjqobj) {
        that.mychartjqobj = mychartjqobj;
    }
    this.theme_filename_arr = {
        default : 'default',
        light : 'light',
        westeros : 'westeros',
        black : 'dark',
        purple : 'purple-passion',
    };
    this.theme_css_title = {
      default : {backColor:'#fff',fontColor:'#333'},
      light : {backColor:'#fff',fontColor:'#333'},
      westeros : {backColor:'#fff',fontColor:'#333'},
      black : {backColor:'rgba(51,51,51,1)',fontColor:'#eeeeee'},
      purple : {backColor:'rgba(25,25,25,1)',fontColor:'#ffffff'},
    };
    this.setChart = function (data, report_id, fromhome) {
        if(data.themename === null)
            data.themename = 'default';
        that.themename = that.theme_filename_arr[data.themename.toLowerCase()];
        var theme_css_title = that.theme_css_title[data.themename.toLowerCase()];//看板组件标题行的背景色和字体颜色
        if(that.myChartObj)
            that.myChartObj.dispose();
        getCommonJsScript('crmcommon/js/jquery/echartTheme/'+that.themename+'.js',function(){
            that.data = data;
            that.report_id = report_id;
            that.fromhome = fromhome;
            var themename = that.themename;
            //edit: xll 2023/10/31 BUG0074756 主题色更改需要更换新的DOM对象
            var oldContainer;
            if(that.mychartjqobj!=''){
                oldContainer = that.mychartjqobj.get(0);
            }else if (report_id > 0) {
                //有report_id 说明是首页来的请求
                var popupobj = CrmPopup.getPopupObj("last");
                //首页的请求  或者报表分析模块弹框
                if((typeof popupobj != 'undefined'&&popupobj.divid != ''&&that.fromhome=='yes')){
                    oldContainer = document.getElementById('myChart_customEchart_' + report_id);
                    ld('#headerrow_charts_customEchart_'+report_id).css('background-color',theme_css_title.backColor);
                    ld('#headerrow_charts_customEchart_'+report_id).find('.icon-bluelt').css('color',theme_css_title.fontColor);
                }else{
                    if(that.fromhome=='yes'){
                        oldContainer = document.getElementById('myChart_' + report_id);
                        ld('#headerrow_charts_'+report_id).css('background-color',theme_css_title.backColor);
                        ld('#headerrow_charts_'+report_id).find('.icon-bluelt').css('color',theme_css_title.fontColor);
                    }else{
                        var mychartjqobj;
                        //zxm 20230705 首页放了统计图A 链接模块也放了统计图A 在首页打开这个连接模块的时候 两个ID一样导致弹窗中的图显示不出来
                        if((typeof popupobj != 'undefined'&&popupobj.divid != '')){
                            mychartjqobj = ld('#'+popupobj.divid+' #myChart_'+report_id);
                        }else{
                            mychartjqobj = ld(' #myChart_'+report_id);
                        }
                        oldContainer = mychartjqobj.get(0);
                    }
                }
            }
            else {
                oldContainer = document.getElementById('myChart');
            }
            var newContainer = oldContainer;
            that.myChartObj = echarts.init(newContainer, themename);

            that.chartType = data.chart_type;
            that.myChartObj.clear();
            switch (that.chartType) {
                case "line":
                case "multiple_line":
                case "bar":
                case "multiple_bar":
                case "line_bar":
                case "bar_stack":
                    that.option = data.option;
                    break;
                case "simple_strip":
                case "multiple_strip":
                case "stack_strip":
                    that.option = data.option;

                    //edit: xll 2024/03/14 XUQIU1002148 条形图柱子宽度控制、超出高度滚动
                    var rowHeight = 30,
                        conHeight = 0,
                        parentNodeId = newContainer.id + '_parent';

                    //edit: xll 2024/03/18 高度优化
                    ld.each(that.option.series,function (index,info) {
                        conHeight += (info.data.length * rowHeight);
                    })

                    if(typeof that.option.grid === "object"){
                        if(typeof that.option.grid.top !== "undefined") {
                            conHeight += parseInt(that.option.grid.top);
                            if(typeof that.option.grid.bottom !== "undefined") {
                                conHeight += parseInt(that.option.grid.bottom);
                            }
                            else{
                                conHeight += parseInt(that.option.grid.top);
                            }
                        }
                        else{
                            if(typeof that.option.grid.bottom !== "undefined") {
                                conHeight += (parseInt(that.option.grid.bottom) * 2);
                            }
                            else{
                                conHeight *= 2;
                            }
                        }
                    }
                    if(ld('#'+parentNodeId).length === 0) {
                        var parentNode = document.createElement('div');
                        parentNode.id = newContainer.id + '_parent';
                        parentNode.classList = newContainer.classList;
                        parentNode.style.height = newContainer.style.height;
                        parentNode.style.width = newContainer.style.width;
                        ld(newContainer).before(parentNode);
                        ld(parentNode).html(newContainer);
                        ld(parentNode).css('overflow','auto');
                    }else{
                        var parentNode = ld('#'+parentNodeId);
                        ld(parentNode).html(newContainer);
                        ld(parentNode).css('overflow','auto');
                    }
                    //zxm 20240628 设置最小高度 防止计算出来的高度太低显示太拥挤
                    conHeight = conHeight<=350?350:conHeight;
                    newContainer.style.height = conHeight + 'px';
                    that.myChartObj.resize();
                    break;
                case "basic_scatter":
                case "multiple_dimension":
                    that.option = that.scatterData(data);
                    break;
                default:
                    that.option = data.option;
            }
            window.rederChartObj = that;
            that.myChartObj.setOption(that.option);
            window.addEventListener("resize", function () {
                that.myChartObj.resize();
            });
            if((typeof popupobj != 'undefined'&&popupobj.divid != ''&&that.fromhome=='yes')) {
                document.getElementById("stuff_customEchart_"+report_id).addEventListener("dragenter", function () {
                    that.myChartObj.resize();
                });
                let MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
                let element = ld('#'+popupobj.divid+' #stuff_customEchart_'+report_id).get(0);
                let observer = new MutationObserver((mutationList) => {
                    that.myChartObj.resize();
                })
                observer.observe(element, { attributes: true, attributeFilter: ['style'], attributeOldValue: true })
            }
            //设置穿透点击--只有饼图和漏斗图需要穿透
            //允许穿透的图表类型数组
            if (data.can_penetrate == "yes") {
                that.setEventClick(data.chart_type, report_id, data.mainmodule, fromhome);
            }
        });
    }
    //设置穿透点击
    this.setEventClick = function (chartType, report_id, mainmodule, fromhome) {
        this.myChartObj.off('click').on('click', function (params) {
            var module = that.pageto_module;
            var url = "index.php?module="+module+"&action="+module+"Ajax&file=SelfDefinedReport";
            var params_data = '&ChartSetInfo='+encodeURIComponent(JSON.stringify(that.ChartSetInfo));
            params_data += '&XAxisName='+encodeURIComponent(params.name)+'&SeriesName='+encodeURIComponent(params.seriesName);
            params_data += '&SeriesIndex='+params.seriesIndex+'&fromhome='+fromhome;
            if(chartType == 'simple_sunburst')
                params_data += '&treePathInfo='+encodeURIComponent(JSON.stringify(params.treePathInfo));

            var YAxis = that.ChartSetInfo.AxisFields.YAxis;
            var cur_computeinfo;
            if(that.ChartSetInfo['chart_type']=='nesting_pie'||YAxis.length==1){
                //嵌套饼图就一个统计字段
                cur_computeinfo = YAxis[0];
            }else{
                cur_computeinfo = YAxis[params.seriesIndex];
            }
            if(empty(cur_computeinfo)) return;
            //同环比  环比增长值 环比增长率 同比增长值 同比增长率 这四个不穿透
            var noChuantouCompareSelectArr = ['prev_growth','prev_growth_percent','prev_growth_lastyear','prev_growth_percent_lastyear'];
            var compare_select = cur_computeinfo.compare_select;
            //zxm @date:2024/12/4 @reason:  XUQIU20241127-02 统计图增加同环比功能 环比增长值 环比增长率 同比增长值 同比增长率 这四个不穿透
            if(noChuantouCompareSelectArr.indexOf(compare_select)>=0){
                return;
            }
            //移动端
            if(typeof frommobile !== 'undefined' && frommobile === 'yes' && typeof environment !== 'undefined') {
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
                    report_id : report_id,
                }
                getJsScript('include/js/modules/Home/HomeStuffChuantou.js', function () {
                    var ChartChuantouObj = new HomeStuffChuantou();
                    if(fromhome === 'yes')
                        ChartChuantouObj.CustomEchartsChuantou_Home(url,params_data,options);
                    else
                        ChartChuantouObj.CustomEchartsChuantou_Report(url,params_data);
                });
            }
        });
    }
    //散点图
    this.scatterData = function (data) {
        var option = data.option;
        option.yAxis[0].scale = true;
        option.yAxis[0].type = "value";

        option.yAxis[0].scale = true;
        option.xAxis[0].type = "value";
        option.tooltip = {};
        let series = data.series;
        ld.each(series, function (idx, itm) {
            that.deepAssign(itm,{
                itemStyle: {
                    shadowBlur: 10,
                    shadowColor: '#eee',
                    shadowOffsetY: 5
                },
                symbolSize : function (data) {
                    let chenji = 1;
                    ld.each(data, function (index, item) {
                        if (typeof item == 'number' && item > 0) {
                            chenji = chenji * item;
                        }
                    });
                    return (Math.log10(chenji + 20)) * 6;
                }
            });
        });
        that.deepAssign(option.tooltip,{
            backgroundColor: ['rgba(255,255,255,0.7)'],
            formatter: function (obj) {
                //显示框数据
                var value = obj.value;
                let totalColumnLength = 0;
                let totalColumn = data.totalColumns;
                let totalColumnHtml = '';
                ld.each(totalColumn, function (index, item) {
                    totalColumnHtml += item.chart_column_name + ':' + value[index] + '<br>';
                    totalColumnLength = index;
                });

                var groupInfo = data.groupInfo;
                let groupInfoHtml = '';
                //edit: xll 2024/01/18 BUG0077937 散点图无法正常显示图形，读取的列子为undefined
                ld.each(groupInfo, function (idx, itm) {
                    groupInfoHtml += itm.groupbyname + ': ' + value[idx + totalColumnLength + 1] + '<br>';
                });
                return '<div style="border-bottom: 1px solid rgba(255,255,255,.3); font-size: 18px;padding-bottom: 7px;margin-bottom: 7px"> ' + groupInfoHtml
                    + '</div>'
                    + totalColumnHtml;
            }
        });
        option.series = series;
        return option;
    }
    /**
     * 用于将源对象的所有可枚举属性复制到目标对象中（深层复制）,若源对象为 undefined则不做处理
     * @param target 目标对象
     * @param resource 源对象
     */
    this.deepAssign = function (target,resource) {
        target = target === undefined ? {} : target;
        if(typeof resource !== 'undefined')
            for (let key in resource) {
                if(resource[key] === null || typeof resource[key] !== 'object'){
                    target[key] = resource[key];
                }
                else
                    that.deepAssign(target[key],resource[key]);
            }
    }
}


customRenderChartFun.getParamsStrByArr = function (ParamsList) {
    var ParamsStr = '';
    var first_param = true;
    ld.each(ParamsList,function (index,param_name) {
        var param_value = getUrlParam(param_name);
        if(param_value !== null){
            if(first_param) {
                ParamsStr += '?' + param_name + '=' + param_value;
                first_param = false;
            }
            ParamsStr += '&' + param_name + '=' + param_value;
        }
    });
    return ParamsStr;
}
customRenderChartFun.ChartPenetrateMobile = function (option) {
    var url = option.url;
    var params_data = option.params_data;
    var frommobile = option.frommobile;
    var environment = option.environment;
    var mainmodule = option.mainmodule;
    var penetrateModule = option.penetrateModule;
    var modulelabel = option.modulelabel;
    var crm_url = option.crm_url;
    url += '&function_name=getPenetrateModuleList_Mobile&frommobile=' + frommobile;
    url += '&environment=' + environment;
    ldAjaxNoProgress(url, params_data, function (res) {
        var ids = res.result.ids;
        var mobileurl;
        var param_list;
        if (environment === 'weixinh5') {
            //企业微信
            mobileurl = 'https://www.51mis.cn/websaas/weixinsaas/' + wx_version + '/ldcrm/index.html#!/listview/' + penetrateModule + '/' + modulelabel + '/-1/report_list/' + ids;
            param_list = ['userid','corpurl','deviceid','corpindex','corpid','agentid','tamptimes','noncestr','signature','agent_signature','expired_type'];
        }
        if (environment === 'yunzhijia') {
            mobileurl = crm_url + 'WeiXinApp/yunzhijia/websaas/ldcrm/index.html#!/listview/' + penetrateModule + '/' + modulelabel + '/-1/report_list/' + ids
            param_list = ['userid','corpurl','corpid'];
        }
        if (environment === 'dingtalk') {
            //钉钉
            mobileurl = crm_url + 'WeiXinApp/dingtalk/websaas/ldcrm/index.html#!/listview/' + penetrateModule + '/' + modulelabel + '/-1/report_list/' + ids
            param_list = ['corpurl','corpid'];
        }
        if (environment === 'app') {
            //app
            mobileurl = 'https://www.51mis.cn/websaas/appsaas/' + wx_version + '/ldcrm/index.html#!/listview/' + penetrateModule + '/' + modulelabel + '/-1/report_list/' + ids
            param_list = ['userid','corpurl','deviceid','corpindex','corpid','appusertoken','expired_time','expired_type'];
        }
        if (environment === 'wxwork' || environment === 'weixin') {
            //edit: xll 2024/03/05 BUG20240227-43 小程序自定义统计图穿透 web-view 组件跳转回小程序
            wx.miniProgram.navigateTo({
                url: '/pages/listview/listview?module='+penetrateModule+'&second_action=report_list&second_para='+ids
            });
            return false;
        }
        mobileurl += customRenderChartFun.getParamsStrByArr(param_list);
        window.location.href = mobileurl;
    });
}


