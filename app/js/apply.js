var applyHandleObj = {};
// 定义跳转到crm-dashboard-view(仪表盘首页)的方法 及click处理定义
ViewObj['create-crm-dashboard-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '仪表盘', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '仪表盘', '', ''], opts_obj);
        scope.prve_header = ViewObj.getInfo('prev_header');
        var urlstring = 'module=Dashboard&action=ListView';
        WordReportAjax(urlstring, function (rest) {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var listhtml = '<ul class="crm-homelists">';
            ld.each(restobj.result.list, function (key, list) {
                listhtml += '<li tag="' + list.name + '" reportid="' + list.record + '">' +
                    '    <a href="javascript:void(0);"><img src="images/' + list.image + '.png"/></a>' +
                    '    <span>' + list.fieldlabel + '<i class="lnr-chevron-right"></i></span>' +
                    '</li>';
            });
            listhtml += '</ul>';
            ld('#crm-dashboard-view').html(listhtml);
            ViewObj.onSwitchAfter(opts_obj);
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {// 头部左边
            ViewObj.switchView('crm-main-view', 'back', {
                __scroll_top: 'origin',
                __app_header: scope.prve_header
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li[tag]');
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            var dashboardTag = _this.attr('tag'),
                dashboardTitle = _this.find('span').text(),
                defaultTag = 'month',
                viewrange = 'SmOwner_Search_Me',
                selectuid = '',
                switchopts = {
                    'reportid': _this.attr('reportid'),
                    'dashboard_type': dashboardTag,
                    'viewrange': viewrange,
                    'selectuid': userid,
                    __init_delay: 200
                };
            switch (dashboardTag) {
                case 'weeklystatistics':
                    //dashboardTitle = '周月统计';
                    var d_cache_ws_timeStr = CacheObj.get('d_cache_ws_time');
                    if (d_cache_ws_timeStr != '' && d_cache_ws_timeStr != undefined) {
                        defaultTag = d_cache_ws_timeStr;
                    }
                    switchopts.ws_reporttype = defaultTag;
                    choose_db_useridobj = CacheObj.get('d_cache_ws_view');
                    choose_db_nameobj = CacheObj.get('d_cache_ws_name');
                    break;
                case 'salesfunnel':
                    //dashboardTitle = '销售漏斗';
                    var d_cache_sf_timeStr = CacheObj.get('d_cache_sf_time');
                    if (d_cache_sf_timeStr != '' && d_cache_sf_timeStr != undefined) {
                        defaultTag = d_cache_sf_timeStr;
                    }
                    switchopts.sf_reporttype = defaultTag;
                    choose_db_useridobj = CacheObj.get('d_cache_sf_view');
                    choose_db_nameobj = CacheObj.get('d_cache_sf_name');
                    break;
                case 'contractamount':
                    //dashboardTitle = '签约额度同比';
                    choose_db_useridobj = CacheObj.get('d_cache_ct_view');
                    choose_db_nameobj = CacheObj.get('d_cache_ct_name');
                    break;
                case 'salessituation':
                    //dashboardTitle = '最近6个月销售情况';
                    choose_db_useridobj = CacheObj.get('d_cache_ss_view');
                    choose_db_nameobj = CacheObj.get('d_cache_ss_name');
                    break;
                case 'returnamount':
                    //dashboardTitle = '回款额月度同比';
                    choose_db_useridobj = CacheObj.get('d_cache_ra_view');
                    choose_db_nameobj = CacheObj.get('d_cache_ra_name');
                    break;
                case 'signednumber':
                    //dashboardTitle = '签约数量龙虎榜';
                    switchopts.sn_reporttype = defaultTag;
                    switchopts.viewrange = 'SmOwner_Search_All';
                    var statusTag = 'all',
                        d_cache_sn_statusStr = CacheObj.get('d_cache_sn_status');
                    if (d_cache_sn_statusStr != '' && d_cache_sn_statusStr != undefined) {
                        statusTag = d_cache_sn_statusStr;
                    }
                    switchopts.sn_status = statusTag;
                    choose_db_useridobj = CacheObj.get('d_cache_sn_view');
                    choose_db_nameobj = CacheObj.get('d_cache_sn_name');
                    break;
                case 'signedamount':
                    //dashboardTitle = '签约金额龙虎榜';
                    switchopts.sa_reporttype = defaultTag;
                    switchopts.viewrange = 'SmOwner_Search_All';
                    var statusTag = 'all',
                        d_cache_sa_statusStr = CacheObj.get('d_cache_sa_status');
                    if (d_cache_sa_statusStr != '' && d_cache_sa_statusStr != undefined) {
                        statusTag = d_cache_sa_statusStr;
                    }
                    switchopts.sa_status = statusTag;
                    choose_db_useridobj = CacheObj.get('d_cache_sa_view');
                    choose_db_nameobj = CacheObj.get('d_cache_sa_name');
                    break;
                case 'paymentamount':
                    //dashboardTitle = '回款金额龙虎榜';
                    switchopts.pa_reporttype = defaultTag;
                    switchopts.viewrange = 'SmOwner_Search_All';
                    choose_db_useridobj = CacheObj.get('d_cache_pa_view');
                    choose_db_nameobj = CacheObj.get('d_cache_pa_name');
                    break;
                case 'coststatistics':
                    //dashboardTitle = '费用佣金统计表';
                    switchopts.ca_reporttype = defaultTag;
                    switchopts.viewrange = 'SmOwner_Search_All';
                    var statusTag = 'all';
                    d_cache_ca_statusStr = CacheObj.get('d_cache_ca_status');
                    if (d_cache_ca_statusStr != '' && d_cache_ca_statusStr != undefined) {
                        statusTag = d_cache_ca_statusStr;
                    }
                    switchopts.ca_status = statusTag;
                    choose_db_useridobj = CacheObj.get('d_cache_ca_view');
                    choose_db_nameobj = CacheObj.get('d_cache_ca_name');
                    break;
                case 'daylog':
                    //dashboardTitle = '日志统计表';
                    switchopts.dl_reporttype = Tools.CurentTime.dateEn();
                    switchopts.viewrange = 'SmOwner_Search_All';
                    choose_db_useridobj = CacheObj.get('d_cache_dl_view');
                    choose_db_nameobj = CacheObj.get('d_cache_dl_name');
                    break;
                case 'weeklog':
                    //dashboardTitle = '周计划统计表';
                    switchopts.wl_reporttype = Tools.CurentTime.dateEn();
                    switchopts.viewrange = 'SmOwner_Search_All';
                    choose_db_useridobj = CacheObj.get('d_cache_wl_view');
                    choose_db_nameobj = CacheObj.get('d_cache_wl_name');
                    break;
                case 'monthlog':
                    //dashboardTitle = '月计划统计表';
                    switchopts.ml_reporttype = 'year';
                    switchopts.viewrange = 'SmOwner_Search_All';
                    choose_db_useridobj = CacheObj.get('d_cache_ml_view');
                    choose_db_nameobj = CacheObj.get('d_cache_ml_name');
                    break;
            }
            switchopts.__app_header = ['<', '', '', dashboardTitle, '', '筛选'];
            if (choose_db_useridobj.length > 0) {
                if (ld.inArray('all', choose_db_useridobj) > -1) {
                    switchopts.viewrange = 'SmOwner_Search_All';
                    switchopts.selectuid = 'all';
                }
                else if (choose_db_useridobj.length === 1 && ld.inArray('me', choose_db_useridobj) === 0) {
                    switchopts.viewrange = 'SmOwner_Search_Me';
                    switchopts.selectuid = userid;
                }
                else {
                    ld.each(choose_db_useridobj, function (key, id) {
                        selectuid += id + ',';
                    });
                    switchopts.viewrange = 'smowner_search_senior';
                    switchopts.selectuid = selectuid.substring(0, selectuid.length - 1);
                }
            }
            switch (switchopts.viewrange) {
                case 'SmOwner_Search_All':
                    switchopts.selectuid = 'all';
                    break;
                case 'SmOwner_Search_Me':
                    switchopts.selectuid = userid;
                    break;
            }
            if (dashboardTag == 'signednumber' || dashboardTag == 'signedamount' ||
                dashboardTag == 'paymentamount' || dashboardTag == 'coststatistics' || 
                dashboardTag == 'daylog' || dashboardTag == 'weeklog' || dashboardTag == 'monthlog' ) {

                if (choose_db_useridobj.length == 0) {
                    choose_db_useridobj = [];
                    choose_db_nameobj = [];
                    choose_db_useridobj[0] = 'all';
                    choose_db_nameobj[0] = '全部';

                    switch (dashboardTag) {
                        case 'signednumber':
                            CacheObj.set('d_cache_sn_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_sn_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                        case 'signedamount':
                            CacheObj.set('d_cache_sa_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_sa_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                        case 'paymentamount':
                            CacheObj.set('d_cache_pa_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_pa_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                        case 'coststatistics':
                            CacheObj.set('d_cache_ca_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_ca_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                        case 'daylog':
                            CacheObj.set('d_cache_dl_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_dl_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                        case 'weeklog':
                            CacheObj.set('d_cache_wl_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_wl_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                        case 'monthlog':
                            CacheObj.set('d_cache_ml_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                            CacheObj.set('d_cache_ml_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                            break;
                    }
                }
            }
            //Tools.print_array(choose_db_nameobj);
            ViewObj.switchView('crm-dashboarddetail-view', 'init', switchopts);
        }
    };
};

// 定义跳转到crm-dashboarddetail-view(仪表盘明细页面)的方法 及click处理定义
ViewObj['create-crm-dashboarddetail-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, [], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, [], opts_obj);
        var urlstring = '',
            chart_data = {},
            chart_options = {},
            chart_panel = null;
        listhtml = '',
            viewrange = opts_obj.viewrange,
            selectuid = opts_obj.selectuid,
            color = ['#FFDA95', '#F5866A', '#F58220', '#B6A3C4', '#648FCB', '#B2E0E1'];
        ld('#crm-dashboarddetail-view .statistics-top').html('');
        ld('#dashboarddetail').html('<div id="chart-panel"></div>');
        scope.reportid = opts_obj.reportid;
        scope.dashboard_type = opts_obj.dashboard_type;
        scope.viewrange = viewrange;
        scope.selectuid = selectuid;

        urlstring = 'module=Dashboard&action=DetailView&scopeType=' + viewrange + '&selectuid=' + selectuid;
        //周月统计
        if (scope.dashboard_type === 'weeklystatistics') {
            scope.ws_reporttype = opts_obj.ws_reporttype;
            urlstring += '&reporttype=' + opts_obj.ws_reporttype + '&record=' + opts_obj.reportid;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                ld.each(restobj.result.list, function (key, list) {
                    listhtml += '<div class="sta-list"><h3>' + list.name + '</h3>';
                    listhtml += '    <span>' + restobj.result.describeinfo.typename + '：<b>' + list.now + '</b><br/>';
                    listhtml += '    ' + restobj.result.describeinfo.lasttypename + '：<b>' + list.last + '</b></span>';
                    if (Number(list.rate) < 0) {
                        listhtml += '<span class="f-greens">-';
                    }
                    else {
                        listhtml += ' <span class="f-reds">';
                    }
                    listhtml += Math.abs(Tools.Number.toDecimal(list.rate * 100, 2)) + '%';
                    listhtml += '</span></div>';
                });
                ld('#crm-dashboarddetail-view #dashboarddetail').append(listhtml);
                ViewObj.onSwitchAfter(opts_obj);
            });
            //销售漏斗
        } else if (scope.dashboard_type === 'salesfunnel') {
            ld("#dashboarddetail #chart-panel").css({
                "width": SwiperObj.PHONE_WIDTH * 1,
                "margin": "0 auto",
                "text-align": "center"
            });
            scope.sf_reporttype = opts_obj.sf_reporttype;

            urlstring += '&reporttype=' + opts_obj.sf_reporttype + '&record=' + opts_obj.reportid;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                applyHandleObj.dashboardDescribeInfo(restobj.result.describeinfo, scope.dashboard_type);//仪表盘，读取其他信息
                var divSalesfunnel = [];
                var allNumber = 0;
                ld.each(restobj.result.list.funnel_data, function (key, list) {
                    if (empty(list)) return false;
                    divSalesfunnel[key] = [];
                    divSalesfunnel[key][0] = list.name;
                    divSalesfunnel[key][1] = eval(list.number);
                    allNumber += eval(list.number);
                });
                if(allNumber <=0 ){
                    divSalesfunnel = [];
                }
                ld('#chart-panel').highcharts({
                    chart: {
                        type: 'funnel',
                        marginRight: 100
                    },
                    title: {
                        text: '',
                        x: -50
                    },
                    plotOptions: {
                        series: {
                            dataLabels: {
                                enabled: true,
                                format: '<b>{point.name}</b> ({point.y:,.0f})',
                                color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black',
                                softConnector: true
                            },
                            neckWidth: '30%',
                            neckHeight: '40%'
                        }
                    },
                    legend: {
                        enabled: true
                    },
                    series: [{
                        name: ' ',
                        data: divSalesfunnel
                    }]
                });

                ViewObj.onSwitchAfter(opts_obj);
            });
            //最近6个月销售情况
        } else if (scope.dashboard_type === 'salessituation') {
            chart_panel = ld('#chart-panel').css({
                'height': SwiperObj.PHONE_WIDTH * 1,
                'width': SwiperObj.PHONE_WIDTH * 1,
                'margin': '10px auto'
            });
            chart_options = {
                textStyle: {
                    color: '#555'
                },
                tooltip: {
                    trigger: 'axis'
                },
                grid: {
                    left: '3%',
                    right: '3%',
                    bottom: '0',
                    containLabel: true
                },
                dataZoom: {
                    show: false,
                    start: 0,
                    end: 100
                },
                xAxis: [
                    {
                        type: 'category',
                        boundaryGap: true,
                        data: [],
                        splitLine: {
                            show: false
                        }
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        scale: true,
                        name: '金额',
                        splitLine: {
                            show: false
                        },
                        // 修改Y轴（左侧），数字过大
                        axisLabel: {
                            formatter: Tools.formAtChartData
                        }
                    },
                    {
                        type: 'value',
                        scale: true,
                        name: '数量',
                        splitLine: {
                            show: false
                        },
                        // 修改Y轴（右侧），数字过大
                        axisLabel: {
                            formatter: Tools.formAtChartData
                        }
                    }
                ],
                series: [
                    {
                        type: 'bar',
                        name: '金额',
                        /*
                         label:{
                         normal:{
                         show:true,
                         position:'insideBottom',
                         // 修改 条形数据 数字过大
                         formatter:Tools.formAtChartData,
                         textStyle:{
                         color:'#000'
                         }
                         }
                         },
                         */
                        barMinHeight: '30',
                        data: [],
                    },
                    {

                        name: '数量',
                        type: 'line',
                        /*
                         label:{
                         normal:{
                         show:true,
                         position:'top',
                         // 修改 折线数据 数字过大
                         formatter:Tools.formAtChartData,
                         textStyle:{
                         color:'#000'
                         }
                         }
                         },
                         */
                        yAxisIndex: 1,
                        data: []
                    }
                ],
                color: ['#AFD8F8', '#F6BD0F']//金额：AFD8F8；数字：F6BD0F
            };
            urlstring += '&record=' + opts_obj.reportid;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息

                chart_data.sales_data = restobj.result.list;
                chart_options.series[0].data = chart_data.sales_data.money_data;
                chart_options.series[1].data = chart_data.sales_data.number_data;
                chart_options.xAxis[0].data = chart_data.sales_data.month_data;
                var salessituation_chart = echarts.init(chart_panel[0]);
                salessituation_chart.setOption(chart_options);

                ViewObj.onSwitchAfter(opts_obj);
            });
            //签约额度同比 或者 回款额月度同比
        } else if (scope.dashboard_type === 'contractamount' ||
            scope.dashboard_type === 'returnamount') {

            chart_panel = ld('#chart-panel').css({
                'height': SwiperObj.PHONE_WIDTH * 3,
                'width': SwiperObj.PHONE_WIDTH * 1,
                'margin': '10px auto'
            });
            chart_options = {
                textStyle: {
                    color: '#555'
                },
                tooltip: {
                    trigger: 'axis'
                },
                grid: {
                    right: '5%',
                    width: '80%',
                    height: '90%',
                    top: '2%'
                },
                yAxis: [
                    {
                        type: 'category',
                        data: ['1月', '2月', '3月', '4月', '5月', '6月', '7月', '8月', '9月', '10月', '11月', '12月'],
                        inverse: true,
                        splitLine: {
                            show: false
                        }
                    }
                ],
                xAxis: [{
                    position: 'bottom',
                    type: 'value',
                    // 修改x轴，数据过大
                    axisLabel: {
                        formatter: Tools.formAtChartDataVertical
                    }
                }
                ],
                series: [
                    {
                        /*
                         label:{
                         normal:{
                         show:true,
                         position:'right',
                         // 修改 数据条 数字过大
                         formatter:Tools.formAtChartData
                         }
                         },
                         */
                        name: '去年',
                        type: 'bar',
                        barMinHeight: '3',
                        data: []
                    },
                    {
                        /*
                         label:{
                         normal:{
                         show:true,
                         position:'right',
                         // 修改 数据条 数字过大
                         formatter:Tools.formAtChartData
                         }
                         },
                         */
                        name: '今年',
                        type: 'bar',
                        barMinHeight: '3',
                        data: [],
                    }
                ],
                color: ['#AFD8F8', '#F6BD0F']//去年：AFD8F8；今年：F6BD0F
            };
            //签约额度同比
            if (scope.dashboard_type === 'contractamount') {
                urlstring += '&record=' + opts_obj.reportid;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                    applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息

                    chart_data.contract_data = restobj.result.list;
                    chart_options.series[0].data = chart_data.contract_data.last_year;
                    chart_options.series[1].data = chart_data.contract_data.this_year;
                    var contractamount_chart = echarts.init(chart_panel[0]);
                    contractamount_chart.setOption(chart_options);
                    ViewObj.onSwitchAfter(opts_obj);
                });
                //回款额月度同比
            } else if (scope.dashboard_type === 'returnamount') {
                urlstring += '&record=' + opts_obj.reportid;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                    applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息

                    chart_data.amount_data = restobj.result.list;
                    chart_options.series[0].data = chart_data.amount_data.last_year;
                    chart_options.series[1].data = chart_data.amount_data.this_year;
                    var returnamount_chart = echarts.init(chart_panel[0]);
                    returnamount_chart.setOption(chart_options);

                    ViewObj.onSwitchAfter(opts_obj);
                });
            }
            //签约数量龙虎榜、签约金额龙虎榜、回款金额龙虎榜
        } else if (scope.dashboard_type === 'signednumber' || scope.dashboard_type === 'signedamount' ||
            scope.dashboard_type === 'paymentamount') {

            chart_panel = ld('#chart-panel').css({
                'height': SwiperObj.PHONE_WIDTH * 1,
                'width': SwiperObj.PHONE_WIDTH * 1,
                'margin': '10px auto'
            });
            chart_options = {
                textStyle: {
                    color: '#666'
                },
                tooltip: {
                    trigger: 'axis',
                    axisPointer: {
                        type: 'shadow'
                    },
                    formatter: function (params, ticket, callback) {
                        //console.log(params);
                        var res = params[0].name;
                        var ticketArr = ticket.split('_');
                        for (var i = 0, l = params.length; i < l; i++) {
                            res += '<br/>排名 : ' + ViewObj.rootScope.paiming[params[i].value];
                            res += '<br/>' + params[i].seriesName + ' : ' + params[i].value;
                        }
                        setTimeout(function () {
                            // 仅为了模拟异步回调
                            callback(ticket, res);
                        }, 1000)
                        return 'loading';
                    }
                },
                legend: {
                    data: []
                },
                grid: {
                    left: '2%',
                    right: '9%',
                    bottom: '3%',
                    containLabel: true
                },
                xAxis: {
                    name: '数量',
                    type: 'value',
                    boundaryGap: [0, 0.01],
                    axisLabel: {
                        formatter: Tools.formAtChartDataVertical
                    }
                },
                yAxis: {
                    name: '人员',
                    type: 'category',
                    data: [],
                    splitLine:{
                        show:false
                    }
                },
                series: [
                    {
                        type: 'bar',
                        data: []
                    }
                ],
                color: ['#AFD8F8']
            };
            //签约数量龙虎榜
            if (scope.dashboard_type === 'signednumber') {
                scope.sn_reporttype = opts_obj.sn_reporttype;
                scope.sn_status = opts_obj.sn_status;
                urlstring += '&applovetype=' + opts_obj.sn_status + '&reporttype=' + opts_obj.sn_reporttype + '&record=' + opts_obj.reportid;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    var reportHeight = 1,
                        nameObj = restobj.result.list.name;
                    if(nameObj != null){
                        if (Tools.Number.toInt(nameObj.length / 8) < 1) {
                            reportHeight = 1;
                        }
                        else{
                            reportHeight = Tools.Number.toInt(nameObj.length / 8);
                        }    
                    }
                    chart_panel = ld('#chart-panel').css({
                        'height': SwiperObj.PHONE_WIDTH * reportHeight
                    });

                    applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                    applyHandleObj.dashboardDescribeInfo(restobj.result.describeinfo, scope.dashboard_type);//仪表盘，读取其他信息

                    chart_data.contract_data = restobj.result.list;
                    chart_options.legend.data = chart_data.contract_data.legend;
                    chart_options.xAxis.name = '数量'.split("").join("\n");
                    chart_options.yAxis.data = chart_data.contract_data.name;
                    chart_options.series[0].name = chart_data.contract_data.legend;
                    chart_options.series[0].data = chart_data.contract_data.data;
                    ViewObj.rootScope.paiming = chart_data.contract_data.pmdata;//排名数组
                    if(chart_data.contract_data.name!=null){
                        var contractamount_chart = echarts.init(chart_panel[0]);
                        contractamount_chart.setOption(chart_options);
                    }
                    ViewObj.onSwitchAfter(opts_obj);
                });
                //签约金额龙虎榜
            } else if (scope.dashboard_type === 'signedamount') {
                scope.sa_reporttype = opts_obj.sa_reporttype;
                scope.sa_status = opts_obj.sa_status;
                urlstring += '&applovetype=' + opts_obj.sa_status + '&reporttype=' + opts_obj.sa_reporttype + '&record=' + opts_obj.reportid;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    var reportHeight = 1,
                        nameObj = restobj.result.list.name;
                    if(nameObj != null){
                        if (Tools.Number.toInt(nameObj.length / 8) < 1) {
                            reportHeight = 1;
                        }
                        else{
                            reportHeight = Tools.Number.toInt(nameObj.length / 8);
                        }    
                    }
                    chart_panel = ld('#chart-panel').css({
                        'height': SwiperObj.PHONE_WIDTH * reportHeight
                    });

                    applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                    applyHandleObj.dashboardDescribeInfo(restobj.result.describeinfo, scope.dashboard_type);//仪表盘，读取其他信息

                    chart_data.contract_data = restobj.result.list;
                    chart_options.legend.data = chart_data.contract_data.legend;
                    chart_options.xAxis.name = '金额'.split("").join("\n");
                    chart_options.yAxis.data = chart_data.contract_data.name;
                    chart_options.series[0].name = chart_data.contract_data.legend;
                    chart_options.series[0].data = chart_data.contract_data.data;
                    ViewObj.rootScope.paiming = chart_data.contract_data.pmdata;//排名数组
                    if(chart_data.contract_data.name!=null){
                        var contractamount_chart = echarts.init(chart_panel[0]);
                        contractamount_chart.setOption(chart_options);
                    }
                    ViewObj.onSwitchAfter(opts_obj);
                });
                //回款金额龙虎榜
            } else if (scope.dashboard_type === 'paymentamount') {
                scope.pa_reporttype = opts_obj.pa_reporttype;
                urlstring += '&reporttype=' + opts_obj.pa_reporttype + '&record=' + opts_obj.reportid;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    var reportHeight = 1,
                        nameObj = restobj.result.list.name;
                    if(nameObj != null){
                        if (Tools.Number.toInt(nameObj.length / 8) < 1) {
                            reportHeight = 1;
                        }
                        else{
                            reportHeight = Tools.Number.toInt(nameObj.length / 8);
                        }    
                    }
                    chart_panel = ld('#chart-panel').css({
                        'height': SwiperObj.PHONE_WIDTH * reportHeight
                    });

                    applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                    applyHandleObj.dashboardDescribeInfo(restobj.result.describeinfo, scope.dashboard_type);//仪表盘，读取其他信息

                    chart_data.contract_data = restobj.result.list;
                    chart_options.legend.data = chart_data.contract_data.legend;
                    chart_options.xAxis.name = '金额'.split("").join("\n");
                    chart_options.yAxis.data = chart_data.contract_data.name;
                    chart_options.series[0].name = chart_data.contract_data.legend;
                    chart_options.series[0].data = chart_data.contract_data.data;
                    ViewObj.rootScope.paiming = chart_data.contract_data.pmdata;//排名数组
                    if(chart_data.contract_data.name!=null){
                        var contractamount_chart = echarts.init(chart_panel[0]);
                        contractamount_chart.setOption(chart_options);
                    }
                    ViewObj.onSwitchAfter(opts_obj);
                });
            }
            // 费用报销统计表
        } else if (scope.dashboard_type === 'coststatistics') {
            chart_panel = ld('#chart-panel').css({
                'height': SwiperObj.PHONE_WIDTH * 1.5,
                'width': SwiperObj.PHONE_WIDTH * 1,
                'margin': '10px auto'
            });
            
            scope.ca_reporttype = opts_obj.ca_reporttype;
            scope.ca_status = opts_obj.ca_status;
            urlstring += '&applovetype=' + opts_obj.ca_status + '&reporttype=' + opts_obj.ca_reporttype + '&record=' + opts_obj.reportid;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                applyHandleObj.dashboardDescribeInfo(restobj.result.describeinfo, scope.dashboard_type);//仪表盘，读取其他信息

                chart_data.contract_data = restobj.result.list;
                if(chart_data.contract_data.legendcost && chart_data.contract_data.legendcomm){
                    chart_options = {
                        textStyle: {
                            color: '#666'
                        },
                        tooltip: {
                            trigger: 'axis',
                            axisPointer: {
                                type: 'shadow'
                            }
                        },
                        legend: {
                            data: []//['费用', '佣金']
                        },
                        grid: {
                            left: '2%',
                            right: '9%',
                            bottom: '3%',
                            containLabel: true
                        },
                        xAxis: {
                            type: 'value',
                            boundaryGap: [0, 0.01],
                            axisLabel: {
                                formatter: Tools.formAtChartDataVertical
                            }
                        },
                        yAxis: {
                            type: 'category',
                            data: []//['邓茜茜','祁先慧','贲媛媛','刘影','郭芳芳','总经理']
                        },
                        series: [
                            {
                                name: '',//费用
                                type: 'bar',
                                data: []//[18203, 23489, 29034, 104970, 131744, 630230]
                            },
                            {
                                name: '',//佣金
                                type: 'bar',
                                data: []//[19325, 23438, 31000, 121594, 134141, 681807]
                            }
                        ],
                        color: ['#AFD8F8', '#F6BD0F']//费用报销金额：AFD8F8；佣金报销金额：F6BD0F
                    };
                }
                else{
                    chart_options = {
                        textStyle: {
                            color: '#666'
                        },
                        tooltip: {
                            trigger: 'axis',
                            axisPointer: {
                                type: 'shadow'
                            }
                        },
                        legend: {
                            data: []
                        },
                        grid: {
                            left: '2%',
                            right: '9%',
                            bottom: '3%',
                            containLabel: true
                        },
                        xAxis: {
                            type: 'value',
                            boundaryGap: [0, 0.01],
                            axisLabel: {
                                formatter: Tools.formAtChartDataVertical
                            }
                        },
                        yAxis: {
                            type: 'category',
                            data: []//['邓茜茜','祁先慧','贲媛媛','刘影','郭芳芳','总经理']
                        },
                        series: [
                            {
                                name: '',//费用
                                type: 'bar',
                                data: []//[18203, 23489, 29034, 104970, 131744, 630230]
                            }
                        ],
                        color: ['#AFD8F8']
                    };
                }

                chart_options.legend.data = chart_data.contract_data.legend;
                chart_options.xAxis.name = '金额'.split("").join("\n");
                chart_options.yAxis.data = chart_data.contract_data.name;

                if(chart_data.contract_data.legendcost && chart_data.contract_data.legendcomm){
                    chart_options.series[0].name = chart_data.contract_data.legendcost;
                    chart_options.series[0].data = chart_data.contract_data.costdata;    
                    chart_options.series[1].name = chart_data.contract_data.legendcomm;
                    chart_options.series[1].data = chart_data.contract_data.commdata;
                }
                else{
                    if(chart_data.contract_data.legendcost){
                        chart_options.series[0].name = chart_data.contract_data.legendcost;
                        chart_options.series[0].data = chart_data.contract_data.costdata;  
                    }
                    if(chart_data.contract_data.legendcomm){
                        chart_options.series[0].name = chart_data.contract_data.legendcomm;
                        chart_options.series[0].data = chart_data.contract_data.commdata;
                    }
                }

                var contractamount_chart = echarts.init(chart_panel[0]);
                contractamount_chart.setOption(chart_options);
                ViewObj.onSwitchAfter(opts_obj);
            });
            // 日志统计表、周计划统计表、月计划统计表
        } else if (scope.dashboard_type === 'daylog' || scope.dashboard_type === 'weeklog' ||
            scope.dashboard_type === 'monthlog') {

            var logtype = 'day',
                logreporttype = '',
                urlstring = 'module=Dashboard&action=DetailView';
            if (scope.dashboard_type === 'daylog') {
                logtype = 'day';
                logreporttype = opts_obj.dl_reporttype;
                scope.dl_reporttype = opts_obj.dl_reporttype;
            }
            else if (scope.dashboard_type === 'weeklog') {
                logtype = 'week';
                logreporttype = opts_obj.wl_reporttype;
                scope.wl_reporttype = opts_obj.wl_reporttype;
            }
            else if (scope.dashboard_type === 'monthlog') {
                logtype = 'month';
                logreporttype = opts_obj.ml_reporttype;
                scope.ml_reporttype = opts_obj.ml_reporttype;
            }            
            urlstring += '&scopeType=' + viewrange + '&selectuid=' + selectuid;;
            urlstring +=  '&reporttype=' + logreporttype + '&record=' + opts_obj.reportid;
            WordReportAjax(urlstring, function (rest) {
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);

                applyHandleObj.dashboardUserInfo(restobj.result.userinfo);//仪表盘，读取头部用户信息
                listhtml = restobj.result.html;
                ld('#crm-dashboarddetail-view #dashboarddetail').append(listhtml);
                ViewObj.onSwitchAfter(opts_obj);
            });
        }
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {
            ViewObj.switchView('crm-dashboard-view', 'back',
            {
                __scroll_top: 'origin'
            });
        }
        else if (t_id === 'head_rig') {
            var defaultTag = '',
                switchopts = {
                    'reportid': scope.reportid,
                    'dashboard_type': scope.dashboard_type,
                    'viewrange': scope.viewrange,
                    'selectuid': scope.selectuid,
                    'statisticstext': ld('#crm-dashboarddetail-view .statistics-top').text()
                };
            switch (scope.dashboard_type) {
                case 'weeklystatistics':
                    switchopts.ws_reporttype = scope.ws_reporttype;
                    break;
                case 'salesfunnel':
                    switchopts.sf_reporttype = scope.sf_reporttype;
                    break;
                case 'signednumber':
                    switchopts.sn_reporttype = scope.sn_reporttype;
                    switchopts.sn_status = scope.sn_status;
                    break;
                case 'signedamount':
                    switchopts.sa_reporttype = scope.sa_reporttype;
                    switchopts.sa_status = scope.sa_status;
                    break;
                case 'paymentamount':
                    switchopts.pa_reporttype = scope.pa_reporttype;
                    break;
                case 'coststatistics':
                    switchopts.ca_reporttype = scope.ca_reporttype;
                    switchopts.ca_status = scope.ca_status;
                    break;
                case 'daylog':
                    switchopts.dl_reporttype = scope.dl_reporttype;
                    break;
                case 'weeklog':
                    switchopts.wl_reporttype = scope.wl_reporttype;
                    break;
                case 'monthlog':
                    switchopts.ml_reporttype = scope.ml_reporttype;
                    break;
            }
            ViewObj.switchView('crm-dashboardsearch-view', 'init', switchopts);
        }
    };
};

// 定义跳转到crm-dashboardsearch-view(仪表盘明细，筛选页面)的方法 及click处理定义
ViewObj['create-crm-dashboardsearch-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '筛选', '', '确定'], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '筛选', '', '确定'], opts_obj);
        scope.prve_header = ViewObj.getInfo('prev_header');
        scope.reportid = opts_obj.reportid;
        scope.dashboard_type = opts_obj.dashboard_type;
        scope.viewrange = opts_obj.viewrange;
        scope.selectuid = opts_obj.selectuid;
        var viewrangeStr = '';
        if (scope.viewrange === 'SmOwner_Search_All') {
            viewrangeStr = '全部';
        }
        else if (scope.viewrange === 'SmOwner_Search_Me') {
            viewrangeStr = '我的';
        }
        else {
            viewrangeStr = opts_obj.statisticstext;
        }
        var searchhtml = '<ul class="c-ul c-edit-cell">';
        searchhtml += '<li class="arrow-right" tag="dsviewrange">';
        searchhtml += '    <i>查看范围</i>';
        searchhtml += '    <span class="lnr-chevron-right"></span>';
        searchhtml += '    <b id="dsviewrange" name="dsviewrange" class="text-ellipsis" items="" title_str="查看范围">' + viewrangeStr + '</b>';
        searchhtml += '</li>';
        //时间范围：周月统计、销售漏斗、签约数量龙虎榜、签约金额龙虎榜、回款金额龙虎榜、费用佣金统计表
        if (scope.dashboard_type === 'weeklystatistics' || scope.dashboard_type === 'salesfunnel' ||
            scope.dashboard_type === 'signednumber' || scope.dashboard_type === 'signedamount' ||
            scope.dashboard_type === 'paymentamount' || scope.dashboard_type === 'coststatistics' || 
            scope.dashboard_type === 'monthlog') {
            var itemsStr = '',
                defaultTag = '',
                defaultText = '本月';
            if (scope.dashboard_type === 'weeklystatistics') {//周月统计
                defaultTag = opts_obj.ws_reporttype;
                if (defaultTag === 'week') {
                    defaultText = '本周';
                }
                else if (defaultTag === 'lastweek') {
                    defaultText = '上周';
                }
                else if (defaultTag === 'month') {
                    defaultText = '本月';
                }
                else if (defaultTag === 'lastmonth') {
                    defaultText = '上月';
                }
                itemsStr = "week&&本周|##|lastweek&&上周|##|month&&本月|##|lastmonth&&上月|##|";
            }
            else if (scope.dashboard_type === 'salesfunnel') {//销售漏斗
                defaultTag = opts_obj.sf_reporttype;
                if (defaultTag === 'month') {
                    defaultText = '本月';
                }
                else if (defaultTag === 'quarter') {
                    defaultText = '本季度';
                }
                else if (defaultTag === 'year') {
                    defaultText = '本年';
                }
                else if (defaultTag === 'all') {
                    defaultText = '全部';
                }
                itemsStr = "month&&本月|##|quarter&&本季度|##|year&&本年|##|all&&全部|##|";
            }//签约数量龙虎榜、签约金额龙虎榜、回款金额龙虎榜、费用佣金统计表
            else if (scope.dashboard_type === 'signednumber' || scope.dashboard_type === 'signedamount' ||
                scope.dashboard_type === 'paymentamount' || scope.dashboard_type === 'coststatistics') {

                if (scope.dashboard_type === 'signednumber') {
                    defaultTag = opts_obj.sn_reporttype;
                }
                else if (scope.dashboard_type === 'signedamount') {
                    defaultTag = opts_obj.sa_reporttype;
                }
                else if (scope.dashboard_type === 'paymentamount') {
                    defaultTag = opts_obj.pa_reporttype;
                }
                else if (scope.dashboard_type === 'coststatistics') {
                    defaultTag = opts_obj.ca_reporttype;
                }
                if (defaultTag === 'today') {
                    defaultText = '今日';
                }
                else if (defaultTag === 'yesterday') {
                    defaultText = '昨日';
                }
                else if (defaultTag === 'week') {
                    defaultText = '本周';
                }
                else if (defaultTag === 'lastmonth') {
                    defaultText = '上月';
                }
                else if (defaultTag === 'month') {
                    defaultText = '本月';
                }
                else if (defaultTag === 'year') {
                    defaultText = '本年';
                }
                else if (defaultTag === 'all') {
                    defaultText = '全部';
                }
                itemsStr = "today&&今日|##|yesterday&&昨日|##|week&&本周|##|lastmonth&&上月|##|month&&本月|##|year&&本年|##|all&&全部|##|";
            }
            else if (scope.dashboard_type === 'monthlog') {

                defaultTag = opts_obj.ml_reporttype;
                if (defaultTag === 'previousyear') {
                    defaultText = '前年';
                }
                else if (defaultTag === 'lastyear') {
                    defaultText = '去年';
                }
                else if (defaultTag === 'year') {
                    defaultText = '本年';
                }
                itemsStr = "previousyear&&前年|##|lastyear&&去年|##|year&&本年|##|";
            }
            searchhtml += '<li class="arrow-right" tag="dstimerange">';
            searchhtml += '    <i>时间范围</i>';
            searchhtml += '    <span class="lnr-chevron-right"></span>';
            searchhtml += '    <b id="dstimerange" name="dstimerange" class="text-ellipsis" items="' + itemsStr + '" ';
            searchhtml += '    select_mode="single" show_search="false" title_str="时间范围" popu_select="drop_down_list" tag="' + defaultTag + '">' + defaultText + '</b>';
            searchhtml += '</li>';
        }
        //时间范围：日志统计表、周计划统计表、月计划统计表
        if (scope.dashboard_type === 'daylog' || scope.dashboard_type === 'weeklog') {
            searchhtml += '<li>';
            searchhtml += '    <i>日期筛选</i>';
            searchhtml += '    <input id="datescreen" class="" name="datescreen" tag="date-control-date" readonly="" value="" type="text"> ';            
            searchhtml += '</li>';
            DateContorlObj.addDateControlInfo('crm_datecontrol_field', 'datescreen', 'date', Tools.CurentTime.dateEn());
        }
        //审批状态/统计范围：签约数量龙虎榜、签约金额龙虎榜、费用佣金统计表
        if (scope.dashboard_type === 'signednumber' || scope.dashboard_type === 'signedamount' ||
            scope.dashboard_type === 'coststatistics') {
            var itemsStr = '',
                defaultTag = '',
                defaultText = '全部';
            if (scope.dashboard_type === 'signednumber') {
                defaultTag = opts_obj.sn_status;
            }
            else if (scope.dashboard_type === 'signedamount') {
                defaultTag = opts_obj.sa_status;
            }
            else if (scope.dashboard_type === 'coststatistics') {
                defaultTag = opts_obj.ca_status;
            }
            if (defaultTag === 'all') {
                defaultText = '全部';
            }
            else if (defaultTag === 'approved') {
                defaultText = '已批准';
            }
            itemsStr = "all&&全部|##|approved&&已批准|##|";
            searchhtml += '<li class="arrow-right" tag="dsapproverange">';
            searchhtml += '    <i>审批状态</i>';
            searchhtml += '    <span class="lnr-chevron-right"></span>';
            searchhtml += '    <b id="dsapproverange" name="dsapproverange" class="text-ellipsis" items="' + itemsStr + '" ';
            searchhtml += '    select_mode="single" show_search="false" title_str="审批状态" popu_select="drop_down_list" tag="' + defaultTag + '">' + defaultText + '</b>';
            searchhtml += '</li>';
        }
        searchhtml += '</ul>';
        ld('#crm-dashboardsearch-view #dashboardsearchContent').html(searchhtml);
        DateContorlObj.bingDateContrl('crm_datecontrol_field');
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        if (t_id === 'head_left') {
            ViewObj.switchView('crm-dashboarddetail-view', 'back', {
                __app_header: scope.prve_header,
                __scroll_top: 'origin'
            });
        }
        else if (t_id === 'head_rig') {
            var selectuid = '',
                switchopts = {
                    __app_header: scope.prve_header,
                    'reportid': scope.reportid,
                    'dashboard_type': scope.dashboard_type,
                    __init_delay: 200
                };
            if (choose_db_useridobj.length > 0) {
                if (ld.inArray('all', choose_db_useridobj) > -1) {
                    switchopts.viewrange = 'SmOwner_Search_All';
                    switchopts.selectuid = 'all';
                }
                else if (choose_db_useridobj.length === 1 && ld.inArray('me', choose_db_useridobj) === 0) {
                    switchopts.viewrange = 'SmOwner_Search_Me';
                    switchopts.selectuid = userid;
                }
                else {
                    ld.each(choose_db_useridobj, function (key, id) {
                        selectuid += id + ',';
                    });
                    selectuid = selectuid.replace("me", userid);
                    switchopts.viewrange = 'smowner_search_senior';
                    switchopts.selectuid = selectuid.substring(0, selectuid.length - 1);
                }
            }
            else {
                if (scope.dashboard_type === 'signednumber' ||
                    scope.dashboard_type === 'signedamount' ||
                    scope.dashboard_type === 'paymentamount' ||
                    scope.dashboard_type === 'coststatistics') {
                    switchopts.viewrange = 'SmOwner_Search_All';
                    switchopts.selectuid = 'all';
                }
                else {
                    switchopts.viewrange = 'SmOwner_Search_Me';
                    switchopts.selectuid = userid;
                }
            }
            //周月统计
            if (scope.dashboard_type === 'weeklystatistics') {
                switchopts.ws_reporttype = ld('#dstimerange').attr('tag');

                CacheObj.set('d_cache_ws_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ws_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ws_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ws_time', switchopts.ws_reporttype, 60 * 60 * 24 * 30);
            }
            //销售漏斗
            else if (scope.dashboard_type === 'salesfunnel') {
                switchopts.sf_reporttype = ld('#dstimerange').attr('tag');

                CacheObj.set('d_cache_sf_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sf_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sf_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sf_time', switchopts.sf_reporttype, 60 * 60 * 24 * 30);
            }
            //签约额度同比
            else if (scope.dashboard_type === 'contractamount') {
                CacheObj.set('d_cache_ct_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ct_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ct_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            //最近6个月销售情况
            else if (scope.dashboard_type === 'salessituation') {
                CacheObj.set('d_cache_ss_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ss_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ss_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            //回款额月度同比
            else if (scope.dashboard_type === 'returnamount') {
                CacheObj.set('d_cache_ra_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ra_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ra_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            //签约数量龙虎榜
            else if (scope.dashboard_type === 'signednumber') {
                switchopts.sn_reporttype = ld('#dstimerange').attr('tag');
                switchopts.sn_status = ld('#dsapproverange').attr('tag');
                CacheObj.set('d_cache_sn_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sn_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sn_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sn_status', switchopts.sn_status, 60 * 60 * 24 * 30);
            }
            //签约金额龙虎榜
            else if (scope.dashboard_type === 'signedamount') {
                switchopts.sa_reporttype = ld('#dstimerange').attr('tag');
                switchopts.sa_status = ld('#dsapproverange').attr('tag');
                CacheObj.set('d_cache_sa_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sa_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sa_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_sa_status', switchopts.sa_status, 60 * 60 * 24 * 30);
            }
            //回款金额龙虎榜
            else if (scope.dashboard_type === 'paymentamount') {
                switchopts.pa_reporttype = ld('#dstimerange').attr('tag');
                CacheObj.set('d_cache_pa_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_pa_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_pa_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            //费用佣金统计表
            else if (scope.dashboard_type === 'coststatistics') {
                switchopts.ca_reporttype = ld('#dstimerange').attr('tag');
                switchopts.ca_status = ld('#dsapproverange').attr('tag');
                CacheObj.set('d_cache_ca_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ca_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ca_name', choose_db_nameobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ca_status', switchopts.ca_status, 60 * 60 * 24 * 30);
            }
            //日志统计表
            else if (scope.dashboard_type === 'daylog') {
                switchopts.dl_reporttype = ld('#datescreen').val();
                CacheObj.set('d_cache_dl_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_dl_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_dl_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            //周计划统计表
            else if (scope.dashboard_type === 'weeklog') {
                switchopts.wl_reporttype = ld('#datescreen').val();
                CacheObj.set('d_cache_wl_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_wl_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_wl_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            //月计划统计表
            else if (scope.dashboard_type === 'monthlog') {
                switchopts.ml_reporttype = ld('#dstimerange').attr('tag');
                CacheObj.set('d_cache_ml_lable', ViewObj.rootScope.db_lable, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ml_view', choose_db_useridobj, 60 * 60 * 24 * 30);
                CacheObj.set('d_cache_ml_name', choose_db_nameobj, 60 * 60 * 24 * 30);
            }
            ViewObj.switchView('crm-dashboarddetail-view', 'init', switchopts);
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('li[tag]');
        if (_this.length === 1 ||
            targetobj[0].tagName.toLowerCase() === 'li') {
            _this = _this.length ? _this : targetobj;
            var dssearchTag = _this.attr('tag'),
                return_module = 'Home';
            //签约数量龙虎榜、签约金额龙虎榜、回款金额龙虎榜
            if( scope.dashboard_type === 'signednumber' || scope.dashboard_type === 'signedamount'||
                scope.dashboard_type === 'paymentamount'){
                return_module = 'OftenUseReport';
            }
            switch (dssearchTag) {
                case 'dsviewrange':
                    ViewObj.switchView('cwn-sendrang-view', 'init', {
                        __app_header: ['<', '', '', '查看范围', '', '确定'],
                        view_name: 'dashboarddetail',
                        'dashboard_type': scope.dashboard_type,//仪表盘名称
                        'return_module': return_module,//模块,Dashboard,Home,OftenUseReport
                        'searchtype': 'bymodule',//类型 (bymodule:根据模块权限; byscope:根据授权范围; all:全部)
                        'filterown': 'no',//是否过滤自己(yes:过滤, no:不过滤)
                        'scopetype': 'groupuser',//显示类型( group:只显示部门; user:只显示用户; groupuser:显示部门及用户)
                        'common': 2,//是否显示常用标签(0:不显示;1:常用标签下没有我的选项;2:常用标签下有我的选项)
                        'isactive': 'no',//是否显示禁用用户（yes:显示,no:不显示  默认no）
                        __direction: 'none'
                    });
                    break;
                case 'dstimerange':
                case 'dsapproverange':
                    _this = _this.find('b[popu_select]').eq(0);
                    ViewObj.switchView('cwn-popuselect-view', 'init', {
                        view_name: _this.attr('popu_select'),
                        target_obj: _this
                    });
                    break;
            }
        }
    };
};

// 定义跳转到crm-photo-view(拍照页)的方法 及click处理定义
ViewObj['create-crm-photo-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', modulename, '相机', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '拍照上传', '相机', ''], opts_obj);
        ld('#photovalueName').html('请点击选择');
        ld('#photovalueid').html('');
        ld('#photoinfomation').val('');
        ld('#crm-photo-viewContent').html('');
        scope.prve_header = ViewObj.getInfo('prev_header');
        var tplnode = '<a class="lnr-chevron-right" href="javascript:void(0);" ></a>' +
            '<b class="text-ellipsis"  id="related_to_type" name="related_to_type" >选择模块</b>';
        ld('#divRelateToType').html(tplnode);

        var urlstring = 'module=PhotoGraph&action=index';
        WordReportAjax(urlstring, function (rest) {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            var tplrelated = '';//是否显示搜索框
            if (restobj.code == 1) {
                var _index = 0,
                    _defaultVal = '',
                    _defaultText = '',
                    _listitems = '',
                    targetobj = ld('#related_to_type');
                ld.each(restobj.result.list, function (key, options) {   //构建数组
                    if (_index == 0) {
                        _defaultVal = key;
                        _defaultText = options;
                    }
                    _listitems += key + '&&' + options + '|##|';
                    if (restobj.result.list.length <= 8) {
                        targetobj.attr('show_search', 'false');
                    }
                    else{
                        targetobj.attr('show_search', 'true');
                    }
                    _index++;
                });
                targetobj.attr({
                    'tag': _defaultVal,
                    'items': _listitems,
                    'title_str': '选择模块',
                    'desc': 'photo',
                    'select_mode': 'single',
                    'popu_select': 'drop_down_list'
                });
                //判断是否有缓存
                var photomoduleobj = JSON.parse(window.localStorage.getItem('storage_photo_module'));
                if (photomoduleobj) {
                    targetobj.attr('tag', photomoduleobj.tag);
                    targetobj.html(photomoduleobj.html);
                }
                else {
                    targetobj.html(_defaultText);
                }
                ViewObj.onSwitchAfter(opts_obj);
            }
        });
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id,
            targetobj = ld('#' + t_id),
            _this = null;
        if (t_id === 'head_left') {// 头部左边
            ViewObj.switchView('crm-main-view', 'back',
                {
                    __app_header: scope.prve_header
                });
        } else if (t_id === 'head_rig') {// 头部右边
            logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
        }
    };
    // 底部点击操作
    ViewObj[to_viewid + '-footer-click'] = function (targetobj, clickOpts) {
        //  点击“保存图片按钮”
        if (targetobj.parents('#crm-photo-footer')) {

            if (ld('#crm-photo-footer div').attr('active') === 'false') return

            var related_to_id = ld('#photovalueid').html(),
                photoinfomation = ld('#photoinfomation').val(),
                relatedType = ld('#related_to_type').html(),
                reltab_module = ld('#related_to_type').attr('tag'),
                urlstring = '',
                tipStr = '';
            if (relatedType === '选择模块') {
                tipStr = '请选择模块';
            }
            else if (related_to_id === '') {
                tipStr = relatedType + '名称不能为空';
            }

            if (tipStr !== '') { // 弹出提示框
                PopPromptBox.show(tipStr);
                return false;
            }
            ld("#status").show();
            urlstring = 'module=PhotoGraph&action=Save' +
                '&description=' + photoinfomation + '&photograph=' +
                '&related_to=' + related_to_id + '&reltab=' + reltab_module + '&uuid=' + GVObj.deviceID +
                '&imagefromtype=' + ViewObj.rootScope.imagefrom + '&attachmentsid=' + imgid + '&attachmentdetailid=' + ViewObj.rootScope.attachmentdetailid;
            WordReportAjax(urlstring, function (rest) {
                ld("#status").hide();
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                //成功提示
                if (restobj.code == 1) {
                    PopPromptBox.show({
                        main_text: restobj.msg,
                        yes_fun: function () {
                            imgid = ''; // 全局变量赋值
                            //记录选择模块
                            var photomoduleobj = {
                                'tag': ld('#related_to_type').attr('tag'),
                                'html': ld('#related_to_type').html()
                            };
                            window.localStorage.setItem('storage_photo_module', JSON.stringify(photomoduleobj));
                            ViewObj.switchView('crm-main-view', 'back', {
                                __app_header: scope.prve_header
                                // __footer_id:false
                            }); // 返回crm首页 
                        }
                    }); // 弹框提示框
                } else {
                    PopPromptBox.show(restobj.msg); // 弹框提示框
                }
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        // 点击 选择模块
        if (targetobj.parents('#divRelateToType').length === 1) {
            targetobj = targetobj.parents('#divRelateToType').find('b');
            // 跳转到下拉选择页面
            ViewObj.switchView('cwn-popuselect-view', 'init', {
                view_name: 'drop_down_list',
                target_obj: targetobj
            });
            // 点击选择相关信息
        } else if (targetobj.attr('id') === 'photovalueName') {
            if (ld('#related_to_type').html() == '选择模块') {
                PopPromptBox.show('请选择模块!');
                return false;
            }
            var related_to_typeStr = ld('#related_to_type').attr('tag');
            if (related_to_typeStr === 'ServiceCharge') {
                related_to_typeStr = 'Accounts';
            }
            ld('#photovalueName').attr({
                'fild_id': 'photovalueName',
                'desc': 'photo',
                'flid_lable': '关联' + ld('#related_to_type').html(),
                'choose_module': related_to_typeStr,
                'parentstatus': 'no'
            });
            // 跳转到带刷新的弹出页面
            ViewObj.switchView('cwn-popuselect-view', 'init', {
                view_name: 'choose_module',
                target_obj: targetobj
            });
        }
    };
};

// 定义跳转到crm-sign-view(签到界面->选择地址)的方法 及click处理定义
ViewObj['create-crm-sign-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '外勤签到', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '外勤签到', '', ''], opts_obj);
        GVObj.crmObj.liststatus = 1;
        ld('#sign_address_crm').html('');
        ld('.positionAddressXY').html('');
        ld('#accountid,#accountName').html('');
        ld('#infomation').val('');
        var signtime = Tools.ServerCurentTime.timeZh();//获取日期与时间
        var getdatetime = Tools.ServerCurentTime.getDateTime();//获取
        ld('#signloadTime').val(getdatetime);
        ld('#crm-sign-view [tag=NowTime]').html(signtime);
        ld('#crm-sign-view').width(SwiperObj.PHONE_WIDTH);
        loadLocationJScript();//加载地图
        scope.prve_header = ViewObj.getInfo('prev_header');
        ViewObj.rootScope.sign_prve_header = ViewObj.getInfo('prev_header');
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            GVObj.crmObj.liststatus = 0;
            ld('#sign_address_crm').html('');
            ld('.positionAddressXY').html('');
            ld('#accountid,#accountName').html('');
            ld('#infomation').val('');
            ViewObj.switchView('crm-main-view', 'back',{
                __scroll_top: 'origin',
                __app_header: scope.prve_header
            });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = null;
        //选择客户
        if (targetobj.parents('li').length === 1 || targetobj[0].tagName.toLowerCase() === 'li') {
            _this = targetobj.parents('li');
            _this = typeof _this.length ? _this : targetobj;
            var accountName = _this.find('#accountName');
            if (accountName.length) {
                ViewObj.rootScope.signpage = 'first';
                _this = accountName;
                _this.attr({
                    'fild_id': 'accountName',
                    'flid_lable': '关联客户',
                    'choose_module': 'Accounts',
                    'desc': 'sign',
                    'parentstatus': 'yes'
                });
                //'select_mode':'sign_account',
                ViewObj.switchView('cwn-popuselect-view', 'init', {
                    view_name: 'choose_module',
                    target_obj: _this
                });
            }
        }
        /*
        //外勤签到，添加图片
        if (targetobj.attr('tag') === 'sign_addimg' || targetobj.parents().attr('tag') === 'sign_addimg') {
            var urlstring = 'module=Home&action=ListView&method=getSignPhoto';
            WordReportAjax(urlstring,function(rest){
                if (empty(rest)) return false;
                var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                if(restobj.result.value == '0'){//是
                    ld('#tplPhone div[tag=btnsub_photo]').removeClass('ui-hide');
                }
                else if(restobj.result.value == '1'){//否
                    ld('#tplPhone div[tag=btnsub_photo]').addClass('ui-hide');
                }
                logicHanderObj.popUpMaskToggle('tplPhone');//显示拍照获取方式弹出层和遮罩层
            });
        }
        */
        //外勤签到，定位不准确，点我重试
        if (targetobj.attr('class') === 'sign_info_right' || targetobj.parents().attr('class') === 'sign_info_right') {
            loadLocationJScript();//重新加载地址
        }
        //外勤签到，定位保存
        if (targetobj.attr('class') === 'save_sign' || targetobj.parents().attr('class') === 'save_sign') {
            if (ViewObj.rootScope.savestatus != 'yes') {
                ViewObj.rootScope.savestatus = 'yes';
                if (NetworkObj.checkNetwork()) {
                    applyHandleObj.signRightbutton(function () {
                        ViewObj.rootScope.savestatus = 'no';
                    });
                }
            }
        }
    };
};

// 定义跳转到crm-signchooseAdr-view(crm签到选择位置页)的方法 及click处理定义
ViewObj['create-crm-signchooseAdr-view'] = function (to_viewid, siwtch_type, scope) {
    // 以初始化方式跳转到该页面
    if (siwtch_type === 'init') {
        ViewObj['switch' + to_viewid + siwtch_type] = function (opts_obj) {
            ViewObj.toViewCommon(to_viewid, ['<', '', '', '选择地址', '', ''], opts_obj);
            ViewObj.onSwitchAfter(opts_obj);
        };
    }
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            ViewObj.switchView('crm-sign-view', 'back');
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        var _this = targetobj.parents('div.swiper-slide');
        if (_this.length === 1 || targetobj.attr('class') === 'swiper-slide') {
            var _this = typeof _this.length ? _this : targetobj;
            _this = _this.find('p');
            if (!_this.hasClass('lnr-circle-solid')) {
                ld('#mapAroundlist .swiper-slide p').removeClass('lnr-circle-solid');
                _this.addClass('lnr-circle-solid');
                ld('#sign_address_crm').html(_this.find('span').html());
                ld('#crm-sign-view .positionAddressXY').html(_this.find('i').attr('lng') + ',' + _this.find('i').attr('lat'));
            }
            setTimeout(function () {
                ViewObj.switchView('crm-sign-view', 'back');
            }, 500);
        }
    };
};

//外勤签到，右边签到按钮
applyHandleObj.signRightbutton = function (callback) {
    ld("#infomation").blur();
    var signaccountid = ld('#accountid').html();
    if (signaccountid == '') {
        PopPromptBox.show('客户名称不能为空');
        ViewObj.rootScope.savestatus = 'no';
        return false;
    }
    if (ld('#sign_address_crm').html() == '') {
        PopPromptBox.show('签到地址不能为空');
        ViewObj.rootScope.savestatus = 'no';
        return false;
    }
    //根据客户ID，获取客户地址
    var urlstring = 'module=Users&action=getDetailBlock' +
        '&recordid=' + signaccountid + '&setype=AccountsAddress';
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        var signaccountAddress = restobj.result.list.address;
        if (signaccountAddress != '') {
            var script = document.createElement("script");
            script.type = "text/javascript";
            script.src = "http://api.map.baidu.com/geocoder/v2/?ak=Hgvb6X18khZw223dBW1hFHuT&callback=getLocationformAccounts&output=json&address=" + encodeURIComponent(signaccountAddress);
            document.body.appendChild(script);
        }
        else {
            SaveSign('&accounts_lng=&accounts_lat=');
        }
        callback();
    });
}

//签到
var getLocationformAccounts = function (data) {
    if (data.result != undefined) {
        var urldate = '&accounts_lng=' + data.result.location.lng + '&accounts_lat=' + data.result.location.lat;
        SaveSign(urldate);
    }
    else {
        SaveSign('&accounts_lng=&accounts_lat=');
    }
}
//根据定位地址，反算经纬度（有时定位经纬度不准确）
function SaveSign(urldate) {
    ViewObj.rootScope.signurl = urldate;
    var signaddress = ld('#sign_address_crm').html();
    var script = document.createElement("script");
    script.type = "text/javascript";
    script.src = "http://api.map.baidu.com/geocoder/v2/?ak=Hgvb6X18khZw223dBW1hFHuT&callback=getLocationformSign&output=json&address=" + encodeURIComponent(signaddress);
    document.body.appendChild(script);
}
//将定位地址，定位经纬度，反算经纬度，客户地址经纬度都传值到后台进行处理
var getLocationformSign = function (data) {
    var signlongtitudeInverse = '',
        signlatitudeInverse = '';
    if (data.result != undefined) {
        signlongtitudeInverse = data.result.location.lng;
        signlatitudeInverse = data.result.location.lat;
    }
    var point = ld('.positionAddressXY').html();
    var pointarr = point.split(",");
    var signloadTime = ld('#signloadTime').val(), 
        signcontent = ld('#infomation').val(),
        signaddress = ld('#sign_address_crm').html(),
        signlongtitude = pointarr[0],
        signlatitude = pointarr[1],
        signaccountid = ld('#accountid').html(),
        signdistance = ld('#crm-sign-view .sign_info .sign_info_left').html().replace('误差（米）：','');

    var signsaveTime = Tools.ServerCurentTime.timesEn();//获取日期与时间
    // alert('1:'+signloadTime+'---'+signsaveTime);
    // 判断进入签到页面时间和当前时间间隔，如果超过5分钟，给出提示然后系统自动重新定位一次
    signloadTime = new Date(signloadTime.replace(/-/g, "/"));//new Date(signloadTime);
    signsaveTime = new Date(signsaveTime.replace(/-/g, "/"));//new Date(signsaveTime);
    // alert('2:'+signloadTime+'---'+signsaveTime);
    var s1 = signloadTime.getTime(),
        s2 = signsaveTime.getTime();
    var total = (s2 - s1)/1000;
    var day = parseInt(total / (24*60*60));//计算整数天数
    var afterDay = total - day*24*60*60;//取得算出天数后剩余的秒数
    var hour = parseInt(afterDay/(60*60));//计算整数小时数
    var afterHour = total - day*24*60*60 - hour*60*60;//取得算出小时数后剩余的秒数
    var min = parseInt(afterHour/60);//计算整数分
    // alert(signloadTime+'---'+signsaveTime);
    // alert(s1+'---'+s2+'---'+min);
    // return;
    if(min >= 5){
        PopPromptBox.show({
            main_text: '您当前页面停留超过5分钟，请点击【签到】按钮重新签到',
            btn_type: 'yesno',
            yes_str: '确定',
            no_str: '取消',
            yes_fun: function () {
                var signtime = Tools.ServerCurentTime.timeZh();//获取日期与时间
                var getdatetime = Tools.ServerCurentTime.getDateTime();//获取
                ld('#signloadTime').val(getdatetime);
                ld('#crm-sign-view [tag=NowTime]').html(signtime);
                loadLocationJScript();//重新加载地址
            }
        });
    }
    else{
        var urlstring = 'module=Singin&action=Save' +
            '&content=' + signcontent + '&address=' + signaddress +
            '&longtitude=' + signlongtitude + '&latitude=' + signlatitude +
            '&longtitudeInverse=' + signlongtitudeInverse + '&latitudeInverse=' + signlatitudeInverse +
            '&uuid=' + GVObj.deviceID + '&accountid=' + signaccountid + ViewObj.rootScope.signurl + 
            '&signdistance=' + signdistance;
        //图片功能
        if (imgid != '') {
            urlstring += '&signimgid=' + imgid + '&signimginfo=' + ViewObj.rootScope.imginfo;
        }
        WordReportAjax(urlstring, function (rest) {
            if (empty(rest)) return false;
            var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
            ld("#status").hide();
            imgid = ''; // 全局变量赋值
            //签到成功提示
            PopPromptBox.show({
                main_text: restobj.result.success,
                yes_fun: function () {
                    ViewObj.switchView('crm-main-view', 'back', {
                        __app_header: ViewObj.rootScope.sign_prve_header
                    });
                }
            });
        });
    }
}
//获取签到信息
function getSign(urlstring, callback) {
    ld('#divSearch').html('');
    WordReportAjax(urlstring, function (rest) {
        if (empty(rest)) return false;
        var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
        //头部        
        if (restobj.result.list2.isUserChoose == 'yes') {
            var title = restobj.result.list2.username + '<span>&nbsp;&nbsp;&nbsp;</span>';
            //头部数据分类
            if (module == 'SinginList') {
                var categoryhtml = '';
                categoryhtml += '<li name="我的签到" title="我的签到">我的签到</li>';
                categoryhtml += '<li name="同事" title="同事">同事</li>';
                ld('#pulldown_menulists').html(categoryhtml);
            }
        } else {
            ViewObj.setAppHeader(['<', '', '', '我的签到', '', '']);
        }
        var tplnode = ld('#tplSignNode').html();
        var listhtml = '';
        if (empty(restobj.result.list1)) {
            listhtml = logicHanderObj.NoinfoNotice('数据');
        }
        else {
            listhtml = '<div class="undersignhtylist"><ul class="crm-lists line4">';
            ld.each(restobj.result.list1, function (key, list) {
                var imgclass = '';
                if(list.image != ''){
                    var imginfo = '',
                        img_index = 0,
                        tem_url = '',
                        signimglistlast = '<li class="workimg-upload pictrue-fold picture-preview" achmentid="' + key + '">';
                    ld.each(list.image, function (imgkey, imglist) {
                        if(imginfo.indexOf(imglist.from.value) < 0 ){
                            imginfo += imglist.from.value + '/';
                        }
                        var imgpath = imglist.path.value + imglist.name.value;
                        if (img_index === 0) {
                            tem_url = 'http://' + loginurl + '/' + imgpath;
                        }
                        img_index += 1;
                        signimglistlast += '<span img-detail="http://' + loginurl + '/' + imgpath +
                            '" tag="'+ imglist.from.value +'" style="display:none;"></span>';
                    });                    
                    signimglistlast += '<img src="' + tem_url + '" alt="" class=""><span>' + img_index + '张</span></li>';

                    imgclass = 'signlistimgclass';
                    imginfo = imginfo.substring(0, imginfo.length - 1);
                }
                listhtml += '<li class="' + imgclass + '">' + 
                                '<h5>' + list.A + '</h5>' + 
                                '<p><span>' + list.B + '</span></p>' + 
                                '<p><span>' + list.C + '</span></p>' + 
                                '<p><span>' + list.D + '</span></p>';
                if(list.image != ''){
                    listhtml += '<p><span>' + imginfo + '</span></p>';
                    listhtml += '<ul class="relation-list signlist">' + signimglistlast + '</ul>';
                }
                listhtml += '</li>';                
            });
            listhtml += '</ul></div>';
        }
        ld('#crm-list-view>.pubDetialC').html(listhtml);
        var choosehtml = '';
        choosehtml += '<div class="tabswitch switch-four">';
        ld.each(restobj.result.list, function (key, list) {
            if (list.value == restobj.result.list2.viewname) {
                choosehtml += '<a class="curr" choosename="' + list.value + '">' + list.title + '</a>';
            }
            else {
                choosehtml += '<a choosename="' + list.value + '">' + list.title + '</a>';
            }
        });
        choosehtml += '</div>';
        ld('#divTab').html(choosehtml);
        ld('#divTab').removeClass('ui-hide');
        if (callback) {
            callback();
        }
    });
}

//签到页面加载
function singinFunction() {
    // 按照forword方式(不需要异步读取数据，只做初始化操作)
    ViewObj.switchView('crm-sign-view', 'init');
}

// 定义跳转到crm-uploadlog-view（上传轨迹）的方法及click处理定义
ViewObj['create-crm-uploadlog-view'] = function (to_viewid, siwtch_type, scope) {
    // 以返回方式跳转到该页面
    ViewObj['switch' + to_viewid + 'back'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '上传轨迹', '', ''], opts_obj);
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 以初始化方式跳转到该页面
    ViewObj['switch' + to_viewid + 'init'] = function (opts_obj) {
        ViewObj.toViewCommon(to_viewid, ['<', '', '', '上传轨迹', '', ''], opts_obj);
        GVObj.crmObj.liststatus = 0;
        scope.prve_header = ViewObj.getInfo('prev_header');
        ViewObj.onSwitchAfter(opts_obj);
    };
    // 头部点击操作
    ViewObj[to_viewid + '-header-click'] = function (targetobj, clickOpts) {
        var t_id = clickOpts.target_id;
        // 点击头部左边
        if (t_id === 'head_left') {
            GVObj.crmObj.liststatus = 0;
            ViewObj.switchView('crm-main-view', 'back',
                {
                    __scroll_top: 'origin',
                    __app_header: scope.prve_header
                });
        }
    };
    // 内容点击操作
    ViewObj[to_viewid + '-body-click'] = function (targetobj, clickOpts) {
        if (targetobj.attr('tag') === 'uploadLog') {
            PopPromptBox.show({
                main_text: '您确定要上传轨迹吗？',
                btn_type: 'yesno',
                yes_str: '确定',
                no_str: '取消',
                yes_fun: function () {
                    onConfirmUpload();
                }
            });
        }
    };
};
//确定上传轨迹
function onConfirmUpload() {
    if (phoneversion === 'ios') {
        iosObj.onComfirmUpload();
        return false;
    }
    else if (phoneversion == 'android') {
        //进度条
        PopPromptBox.show('轨迹上传中，请稍后');
        var uploadStatus = androidObj.onComfirmUpload();
        if (uploadStatus === 'yes') {
            PopPromptBox.show('轨迹上传成功');
            return false;
        }
        else {
            PopPromptBox.show('轨迹上传失败');
            return false;
        }
    }
};
//仪表盘，读取头部用户信息
applyHandleObj.dashboardUserInfo = function (userinfo) {
    var userhtml = '<div><img src="http://' + loginurl + '/' + userinfo.userimgpath + '" onload="logicHanderObj.loadimg(this)"></div><span class="text-ellipsis">' + userinfo.lastname + '</span>';
    ld('#crm-dashboarddetail-view .statistics-top').html(userhtml);
}
//仪表盘，读取其他信息
applyHandleObj.dashboardDescribeInfo = function (describeinfo, dashboard_type) {
    var describehtml = '<div class="sta-desc">' +
                        '    <p><i class="lnr-calendar"></i>' + describeinfo.typename + '</p>';
    if (dashboard_type === 'salesfunnel') {
        describehtml += '<p>总金额 <span>' + describeinfo.totalamount + '</span></p>';
    }
    if (dashboard_type === 'signednumber') {
        describehtml += '<p>总数量 <span>' + describeinfo.count + '</span></p>';
    }
    if (dashboard_type === 'signedamount' ||
        dashboard_type === 'paymentamount' || dashboard_type === 'coststatistics') {
        describehtml += '<p>总金额 <span>' + describeinfo.count + '</span></p>';
    }
    describehtml += '</div>';
    ld('#crm-dashboarddetail-view #dashboarddetail').prepend(describehtml);
}