/**
 * Edit: xll
 * Date: 2023/08/28
 * Reason: echarts类，实现动态调用返回所有echarts组件的相关方法，包括配置项、自定义工具等方法
 */
function newChart_class() {
    var QTY = arrJsPopLabel['QTY'];//数量
    var AMOUNT = arrJsPopLabel['AMOUNT'];//金额
    var TOLOOKVALUE = arrJsPopLabel['TOLOOKVALUE'];//目标值
    var COMPLETIONVALUE = arrJsPopLabel['COMPLETIONVALUE'];//完成值
    var COMPLETIONRATE = arrJsPopLabel['COMPLETIONRATE'];//完成率
    var INCOMPLETEVALUE = arrJsPopLabel['INCOMPLETEVALUE'];//未完成值
    var that = this;
    this.data = {};
    this.dataSeqType = 'DESC';
    this.dataSeqTypeChange = {DESC:'ASC',ASC:'DESC'};
    this.TargetGaugeTextInfo = {
        'target' : { label : TOLOOKVALUE, color : '#3B7CFF'},
        'done' : { label : COMPLETIONVALUE, color : '#3B7CFF'},
        'undone' : { label : INCOMPLETEVALUE, color : '#000'}
    };
    this.setData = function (data) {
        that.data = data;
    }
    this.setParams = function (params) {
        that.stuffid = params.stuffid;
        that.params = params;
    }
    this.setChildChartData = function (ChildChartData) {
        that.ChildChartData = ChildChartData;
    }
    this.setMychartObj = function (myChart) {
        that.myChart = myChart;
        that.Content_JqueryObj = ld(myChart.getDom());
        //将对象绑定至Dom对象中方便调试
        that.Content_JqueryObj.prop('newChartObj',that);
    }
    //公共的tooltip配置
    this.gettooltip = function(){
        var tooltip = {
            trigger: 'axis',
            axisPointer : { // 坐标轴指示器，坐标轴触发有效
                type : 'shadow' // 默认为直线，可选为：'line' | 'shadow'
            },
            textStyle:{
                align:'left'
            }
        };
        return tooltip;
    }
    //公共的title配置
    this.gettitle = function() {
        var title = {
            text: ''
        };

        return title;
    }
    //公共的grid配置
    this.getgrid = function() {
        var grid = {
            left: '3%',
            right: '4%',
            bottom: '15%',
            top: 40,
            containLabel: true
        };
        return grid;
    }
    //公共的legend配置
    this.getlegend = function() {
        //BUG20240709-03 zxm 20240709 图例色块大小改成正方形 12宽高 文字改12px
        var legend = {
            type: 'scroll',
            bottom: 14,
			itemWidth:12,
            itemHeight:12,
            textStyle:{fontSize:12}        
		};
        return legend;
    }
    this.getOption = function (fun_name) {
        if(typeof fun_name !== "undefined") {
            that.option = that.newChartFun_getOption[fun_name]();
            //datalabel 更改之后实时更新 看板编辑界面的样式 BUG20240829-27
            var curpopobj = CrmPopup.getPopupObj('last');
            var key = 'defaultstuff_'+that.stuffid;
            var labelPosition = '';
            if(typeof curpopobj !=='undefined'&&curpopobj.divid!==''&&typeof curpopobj.StuffOtherSetList !== "undefined"
                && typeof curpopobj.StuffOtherSetList[key] !== "undefined" && typeof curpopobj.StuffOtherSetList[key].datalabel !== "undefined"){

                labelPosition = curpopobj.StuffOtherSetList[key].datalabel;
                var datalabel = labelPosition!=='' ? labelPosition : that.data.datalabel;
                var datalabel_show = datalabel=='none'?false:true;
                if(that.option&&that.option.series){
                    ld.each(that.option.series,function(i,item){
                        item.label = {};
                        item.label.show = datalabel_show;
                        if(datalabel!='none'){
                            item.label.position = datalabel;
                        }
                        if (datalabel=='inside_radial'){
                            item.label.position = 'inside';
                            item.label.rotate = true;
                        }else{
                            item.label.rotate = false;
                        }
                    });
                }
            }
        }else {
            typeof that.option === "undefined" && (that.option = that.newChartFun_getOption['newChart_' + that.stuffid]())
        }
        return that.option;
    }
    this.setOption = function (option) {
        if(typeof option === "undefined")
            option = that.getOption();
        that.myChart.setOption(option);
    }
    
    this.setClick = function () {
        that.myChart.off('click');//无论穿不穿透  都要先解绑绑定事件  不然页签切换会重复绑定   
        if(that.data.can_penetrate === 'yes'){
            that.myChart.on('click', function (params) {
                that.setClickEvent['click_' + that.stuffid](params, that.stuffid);
            });
        }
    }

    //各echarts组件配置项的集合，以便动态动用获取对应的配置项
    this.newChartFun_getOption = {
        //最近6个月销售情况1
        newChart_1 :function(){
            var option = that.data['option'];
            return option;
        },
        //个人最近6个月销售情况9  同1
        newChart_9 : function(){return that.newChartFun_getOption.newChart_1()},
        //签约额月度同比
        newChart_4 : function(){
            var option = that.data['option'];
            return option;
        },
        //收款额月度同比
        newChart_5 : function(){return that.newChartFun_getOption.newChart_4()},
        //19
        newChart_19 : function(){
            var option = that.data['option'];
            return option;
        },
        //近6个月目标完成情况
        newChart_40 : function(){
            var datalabel = that.data.datalabel;
            //zxm 20231017 完成率折线图没有百分号
            var tooltip = {
                trigger: 'axis',
                axisPointer : { // 坐标轴指示器，坐标轴触发有效
                    type : 'shadow' // 默认为直线，可选为：'line' | 'shadow'
                },
                textStyle:{
                    align:'left'
                },
                formatter: function(params) {
                    var res = params[0].name;
                    for (var i = 0, l = params.length; i < l; i++) {
                        // 使用颜色小圆点模拟图例标记
                        res += '<br/><span style="display:inline-block;margin-right:5px;border-radius:10px;width:10px;height:10px;background-color:' + params[i].color + '"></span>';
                        if (params[i].seriesType === 'line') {
                            res += params[i].seriesName + ' : ' + params[i].value + '%';
                        } else {
                            res += params[i].seriesName + ' : ' + params[i].value + that.data['indicator_unit'];
                        }
                    }
                    return res;
                }
            };
            var option = {
                title: that.gettitle(),
                grid: that.getgrid(),
                xAxis: {
                    type: 'category',
                    data: that.data['title'],
                },
                //Y轴名称改成指标单位的值 空即是空 Y轴刻度格式化加上
                yAxis: [{
                    type: 'value',
                    name:that.data['indicator_unit'],
                    min: 0,
                },{
                    type: 'value',
                    name:COMPLETIONRATE,
                    min: 0
                }],
                legend: that.getlegend(),
                tooltip: tooltip,
                series: [{
                    name: TOLOOKVALUE,
                    type: 'bar',
                    barMaxWidth:18,
                    label:datalabel,
                    data: that.data['target']
                }, {
                    name: COMPLETIONVALUE,
                    type: 'bar',
                    barMaxWidth:18,
                    label:datalabel,
                    data: that.data['done']
                }, {
                    name: COMPLETIONRATE,
                    type: 'line',
                    yAxisIndex: 1,
                    label:datalabel,
                    data: that.data['rate']
                }
                ]
            }
            return option;
        },
        //开票额月度同比
        newChart_41 : function(){return that.newChartFun_getOption.newChart_4()},
        //出库额月度同比
        newChart_42 : function(){return that.newChartFun_getOption.newChart_4()},
        //首页增加商机统计图:商机统计图_按销售负责人和销售阶段统计44 45
        newChart_44 : function(){
            var option = that.data['option'];
            return option;
        },
        //首页增加商机统计图:44 商机统计图_按所属行业和销售阶段统计45
        newChart_45 : function(){return that.newChartFun_getOption.newChart_44()},
        //zxm 2020-1130 誉帆 营销对比报告
        newChart_48 : function(){
            var option = {
                tooltip:that.gettooltip(),
                grid: that.getgrid(),
                legend: that.getlegend(),
                xAxis: [
                    {
                        type: 'category',
                        data: that.data.title
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        name:QTY,
                        axisLabel: {
                            formatter: function(value){
                                return yAxisFormatter(value,'');
                            }
                        }
                    }
                ],
                series: [{
                    name: "合同金额",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['hetong']

                }, {
                    name: "开票金额",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['kaipiao']

                }, {
                    name: "回款金额",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['huikuan']

                }]
            };
            return option;
        },
        newChart_53 : function(){return that.newChartFun_getOption.newChart_48()},
        //zxm 2020-1130 誉帆 营销对比报告
        newChart_49 : function(){
            var option = {
                tooltip:that.gettooltip(),
                grid: that.getgrid(),
                legend: that.getlegend(),
                xAxis: [
                    {
                        type: 'category',
                        data: that.data.title
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        name:'金额',
                        axisLabel: {
                            formatter: function(value){
                                return yAxisFormatter(value,'');
                            }
                        }
                    },
                    {
                        type: 'value',
                        name:'毛利率',
                        axisLabel: {
                            formatter: '{value} %'
                        }
                    }
                ],
                series: [{
                    name: "项目产值",
                    type: 'bar',
                    barMaxWidth:18,
                    data: that.data['chanzhi'],
                }, {
                    name: "项目成本",
                    type: 'bar',
                    barMaxWidth:18,
                    data: that.data['chengben'],
                    tooltip: {
                        valueSuffix: ''
                    }
                }, {
                    name: "项目毛利额",
                    type: 'bar',
                    barMaxWidth:18,
                    data: that.data['maoli'],
                    tooltip: {
                        valueSuffix: ''
                    }
                }, {
                    name: "项目毛利率",
                    type: 'line',
                    yAxis: 1,
                    data: data['maoli_rate'],
                    tooltip: {
                        valueSuffix: '%'
                    }
                }]
            };
            return option;
        },
        newChart_55 : function(){return that.newChartFun_getOption.newChart_49()},
        newChart_61 : function(){
            var tooltip = {
                trigger: 'axis',
                confine: true,
                extraCssText: 'white-space: normal; word-break: break-all;'
            }
            var option = {
                tooltip:tooltip,
                grid: that.getgrid(),
                legend:  that.getlegend(),
                xAxis: [
                    {
                        type: 'category',
                        data: that.data.title
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        name:QTY,
                        axisLabel: {
                            formatter: function(value){
                                return yAxisFormatter(value,'');
                            }
                        }
                    }
                ],
                series: [{
                    name: "应收合同额",
                    type:'line',
                    smooth: true,
                    data: that.data['total_order']

                }, {
                    name: "应收总额",
                    type:'line',
                    smooth: true,
                    data: that.data['total_planamount']

                }, {
                    name: "应收余额",
                    type:'line',
                    smooth: true,
                    data: that.data['total_receivable_balance']

                }, {
                    name: "销售收款",
                    type:'line',smooth: true,
                    data: that.data['total_received_amount']

                }, {
                    name: "其他收款",
                    type:'line',smooth: true,
                    data: that.data['total_nonbusinesscash']

                }, {
                    name: "收入",
                    type:'line',smooth: true,
                    data: that.data['total_cash']

                }, {
                    name: "发票",
                    type:'line',smooth: true,
                    data: that.data['total_invoice']

                }, {
                    name: "应付合同额",
                    type:'line',smooth: true,
                    data: that.data['total_purchaseorder']

                }, {
                    name: "应付总额",
                    type:'line',smooth: true,
                    data: that.data['total_sendplanamount']

                }, {
                    name: "费用支出",
                    type:'line',smooth: true,
                    data: that.data['total_expense']

                }, {
                    name: "采购支出",
                    type:'line',smooth: true,
                    data: that.data['total_pay_amount']

                }]
            };
            return option;
        },
        newChart_62 : function(){
            var option = {
                tooltip:that.gettooltip(),
                grid: that.getgrid(),
                legend: that.getlegend(),
                xAxis: [
                    {
                        type: 'category',
                        data: that.data.title
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        name:QTY,
                        axisLabel: {
                            formatter: function(value){
                                return yAxisFormatter(value,'');
                            }
                        }
                    }
                ],
                series: [{
                    name: "应收合同总额",
                    type:'line',
                    smooth: true,
                    data: that.data['total_order']

                }, {
                    name: "应收总额",
                    type:'line',
                    smooth: true,
                    data: that.data['total_planamount']

                }, {
                    name: "收款金额",
                    type:'line',
                    smooth: true,
                    data: that.data['total_cash']

                }, {
                    name: "逾期应收款",
                    type:'line',smooth: true,
                    data: that.data['total_planamount_over']

                }, {
                    name: "开票金额",
                    type:'line',smooth: true,
                    data: that.data['total_invoice']

                }]
            };
            return option;
        },
        newChart_63 : function(){
            var tooltip = {
                trigger: 'axis',
                confine: true,
                extraCssText: 'white-space: normal; word-break: break-all;'
            }
            var option = {
                tooltip:tooltip,
                grid: that.getgrid(),
                legend: that.getlegend(),
                xAxis: [
                    {
                        type: 'category',
                        data: that.data.title,
                        axisLabel:{rotate:45}
                    }
                ],
                yAxis: [
                    {
                        type: 'value',
                        name:QTY,
                        axisLabel: {
                            formatter: function(value){
                                return yAxisFormatter(value,'');
                            }
                        }
                    }
                ],
                series: [{
                    name: "合同总额",
                    type:'bar',
                    barMaxWidth:18,
                    smooth: true,
                    data: that.data['total_order']

                }, {
                    name: "未收合同额",
                    type:'bar',
                    barMaxWidth:18,
                    smooth: true,
                    data: that.data['total_receivable_balance']

                }, {
                    name: "项目收款",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['total_received_amount']

                }, {
                    name: "预计支出金额",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['total_budget']

                }, {
                    name: "项目付款",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['total_sendcashbill']

                }, {
                    name: "采购退款",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['total_purchaseback']

                }, {
                    name: "动态毛利",
                    type:'bar',
                    barMaxWidth:18,
                    data: that.data['total_maoli']

                }]
            };
            return option;
        },
        newChart_57 : function(){
            var option = that.data['option'];
            return option;
        },
        newChart_105 : function(){return that.newChartFun_getOption.newChart_57()},
        newChart_106 : function(){return that.newChartFun_getOption.newChart_57()},
        newChart_107 : function(){return that.newChartFun_getOption.newChart_57()},
        //数据龙虎榜
        newChart_100 : function() {
            if(that.data.userid_arr['id'] == null || that.data.userid_arr['id'] == undefined){
                that.Content_JqueryObj.css('height','100%');
                return false;
            }
            var stuffid = that.stuffid;
            var self_name = 'newChart_'+stuffid;
            var datalabel = that.data.datalabel;
            var datalabel_show = datalabel=='none'?false:true;

            var userinfo = that.data.userinfo;

            var userid_arr = that.data.userid_arr['id'];
            var userid_length = parseInt(userid_arr.length);
            if(that.data.userid_arr['empty'] != undefined && that.data.userid_arr['empty'].length >0)
                userid_arr = userid_arr.concat(that.data.userid_arr['empty']);
            let onClickFunction = function () {
                that.UpdateMychartSeq(self_name);
            }.bind(that);
            var topnumber = parseInt(that.data.topnumber);
            var ChartRowNum = topnumber < userid_length ? topnumber : userid_length;
            ChartRowNum = ChartRowNum < 5 ? 5 : ChartRowNum ;
            userid_arr = userid_arr.slice(0,ChartRowNum);
            that.data.userid_arr1 = userid_arr;//zxm 20240816 降序升序转化需要用到这个数组
            //edit: xll 2024/08/12 BUG20240809-74 仅数据龙虎榜需要修改内容高度
            var ChartHeight = parseInt(that.data.ChartRowHeight) * parseInt(ChartRowNum);
            (that.stuffid === 100) && ( that.Content_JqueryObj.css('height',ChartHeight + 'px') );
            var icon_arr = [];
            if(userinfo.icon)
                icon_arr = userinfo.icon;
            var option = {
                tooltip: {
                    trigger: 'axis',
                    confine: true,
                    maxWidth:100,
                    axisPointer: {
                        type: 'shadow'
                    },
                    formatter: function(params) {
                        let item = params[0]; // 因为是axis触发方式，params是数组
                        let value = item.name;
                        if (!value || !userinfo[value]) return '';
                        let username = userinfo[value]['username'];
                        let groupname = userinfo[value]['groupname'];
                        // 构造并返回完整的提示内容
                        return `<b>${username}</b><br/>${groupname}`;
                    }
                },
                grid: {
                    left: 200,
                    top: 20,
                    bottom: 30,
                },
                toolbox: {
                    orient:'vertical',
                    feature: {
                        myTool1: {
                            show: true,
                            title: arrJsPopLabel['RANKING'+that.dataSeqType],
                            icon: userinfo.sortIcon.path,
                            iconStyle: {
                                color: userinfo.sortIcon.fill,
                            },
                            onclick: onClickFunction
                        },
                    },
                    right: 20,
                },
                xAxis: {
                    type: 'value',
                    name: '',
                    axisLabel: {
                        formatter: function(value){
                            return yAxisFormatter(value,'');
                        }
                    }
                },
                yAxis: {
                    type: 'category',
                    inverse: true,
                    data: that.data.userid_arr1,
                    axisLabel: {
                        show:true,
                        width:160,
                        overflow: 'truncate', //超出的部分截断
                        ellipsis: '...', //截断的部分用...代替
                        color: "#666666",
                        formatter: function (value) {
                            if (!value || !userinfo[value]) return '';
                            let username = userinfo[value]['username'];
                            let groupname = userinfo[value]['groupname'];
                            // 截断用户名和部门名至最大长度
                            let maxUsernameLength = 5;
                            let maxGroupnameLength = 10;
                            if (username.length > maxUsernameLength) {
                                username = username.slice(0, maxUsernameLength) + "...";
                            }
                            groupname = groupname === null ? '' : groupname;
                            if (groupname.length > maxGroupnameLength) {
                                groupname = groupname.slice(0, maxGroupnameLength) + "...";
                            }
                            let icon_num = that.data.userid_arr1.indexOf(parseInt(value));
                            let icon_style = 'icon_top_'+(parseInt(icon_num)+1);
                            let icon_text = '';
                            if(icon_num + 1 > 10) {
                                icon_text = (icon_num + 1);
                                icon_style = 'icon_top_rest';
                            }
                            return '{'+icon_style+'| '+icon_text+' }  {username|' + username + '}\n{groupname|' + groupname + '}';
                        },
                        margin: 40,
                        rich: that.getOptionRich_100(icon_arr),
                    }
                },
                series: [
                    {
                        type: 'bar',
                        barWidth: '50%',
                        data: that.data.userdata_arr,
                        label: {
                            show:datalabel_show,
                            position:datalabel,
                            formatter: function(value) {
                                return that.data.UserdataStringArr[value.dataIndex];

                            }
                        },
                    },
                ]
            };
            return option;
        },
        //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘
        newChart_101 : function(){
            var popupobj = CrmPopup.getPopupObj("last");
            var StuffLabelObj,StuffLabelValueObj ;
            if(popupobj.divid != ''){
                StuffLabelObj = ld('#'+popupobj.divid+' #stuffcont_label_101');
            }
            else{
                StuffLabelObj = ld('#stuffcont_label_101');
            }
            StuffLabelValueObj = StuffLabelObj.find('.stufflabel_value');
            StuffLabelValueObj.each(function(key,LabelValueObj){
                var LabelValueTag = ld(LabelValueObj).attr('tag');
                ld(LabelValueObj).html(that.data[LabelValueTag]);
            });
            //绑定事件
            var params_data = '';
            params_data += '&data_type='+that.params['data_type'];//近六个月目标完成情况 页签切换的值
            params_data += '&targetid='+that.params['targetid'];//近六个月目标完成情况 页签切换的值
            ld('#stuffcont_complate_value').unbind('click').bind('click',function(){
                params_data += '&SeriesName='+encodeURIComponent('完成值');
                params_data += '&SeriesIndex=1';
                var ChartChuantouObj = new HomeStuffChuantou();
                ChartChuantouObj.HomeChartChuantou(101,params_data);
            });
            ld('#stuffcont_salesgoal_value').unbind('click').bind('click',function(){
                params_data += '&SeriesName='+encodeURIComponent('目标值');
                params_data += '&SeriesIndex=0';
                AjaxJSPage('SalesGoal_js','include/js/modules/SalesGoal/SalesGoal.js');
                var ChartChuantouObj = new HomeStuffChuantou();
                ChartChuantouObj.HomeChartChuantou(101,params_data);
            });
            var option = {
                    series: []
                };
            option.series.push(
                that.getGaugeSeries(that.data['rate'],{
                    center: ['50%','55%'],
                    radius: '80%',
                })
            );
            return option ;
        },
        newChart_102 : function(){return that.newChartFun_getOption.newChart_100()},
        newChart_103 : function(){return that.newChartFun_getOption.newChart_100()},
        newChart_104 : function(){return that.newChartFun_getOption.newChart_100()},
        newChart_112 : function(){
            var ChartHeight = 58 * that.data.ydatacount;
            var accountinfo = that.data.accountinfo;
            var barwidth = 58;
            that.Content_JqueryObj.css('height',ChartHeight + 'px');
            var fixedlabellist = that.data.fieldlabellist;
            //转化率的显示 markLineData
            var markLineData = [];

            var maxxdata = that.data.maxxdata;
            var stepnum = that.data.stepnum;
            ld.each(that.data.ydata2,function(index,item){
                markLineData[index] = [
                    {
                        name: that.data.throughrate[index]+'%',
                        xAxis:((index+2)*stepnum)+maxxdata/2,
                        yAxis: that.data.ydata2[0]
                    },
                    {
                        xAxis: ((index+2)*stepnum)+maxxdata/2,
                        yAxis: that.data.ydata2[index+1]
                    }
                ]

            });
            var option = {
                dataset: {
                    dimensions: ['sales_stage', 'throughnum', "curnum", "failnum","successnum"],//图的系列名
                    source: that.data.list
                },
                tooltip: {
                    trigger: 'axis',
                    axisPointer : { // 坐标轴指示器，坐标轴触发有效
                        type : 'shadow' // 默认为直线，可选为：'line' | 'shadow'
                    },
                    textStyle:{
                        align:'left',color:'#eee'

                    },
                    backgroundColor:'#666',
                    borderWidth:0,
                    formatter: function(value){
                        var componentType = value[0].componentType;
                        var linedata = value[0].data;
                        if(componentType=='series'){
                            // edit: xl 2024/02/04 BUG20240115-17 赢单数量显示为零
                            var curNum = parseInt(linedata.successnum) !== 0 ? linedata.successnum : linedata.curnum;
                            return [linedata.sales_stage+'</br>',
                                fixedlabellist['allnums']+'：'+linedata.allcurnum+'</br>',
                                fixedlabellist['TotalAmount']+'：'+linedata.allcuramount+fixedlabellist['unit']+'</br>',
                                fixedlabellist['Conversionrate1']+'：'+(linedata.throughrate)+'%</br>',
                                fixedlabellist['Averagetimeconsumption']+'：'+linedata.shichang+'</br>',
                                fixedlabellist['Currentstay']+'：'+curNum+'</br>',
                                fixedlabellist['Loss']+'：'+linedata.failnum+'</br>',
                                fixedlabellist['Lossrate']+'：'+linedata.failrate+'%</br>',
                            ].join('\n');
                        }
                        if(componentType=='markLine'){
                            return '';
                        }

                    },
                    rich: {
                        a: {
                            color:'#eee',
                            lineHeight: 10,
                            textAlign:'left'
                        },
                    },
                    position: that.TooltipPosition,
                },
                legend: {type:'scroll',selectedMode : accountinfo=='tiandi'?true:false,itemWidth:12,itemHeight:12,textStyle:{fontSize:12}},//BUG20240709-03 zxm 20240709 图例色块大小改成正方形 12宽高 文字改12px
                grid: {
                    left: '3%',
                    right: '3%',
                    top: '30',
                    bottom: '1%',
                    containLabel: true
                },
                xAxis:[
                    {
                        type: 'value',
                        show:false,
                        max:that.data.maxxdata
                    },{
                        type: 'value',
                        show:false,
                        max:that.data.maxxdata
                    }
                ],
                yAxis: [
                    {
                        type: 'category',
                        nameTextStyle:{fontSize:14},
                        data: that.data.ydata
                    }
                    ,{
                        type: 'category',
                        show:false,
                    }
                ],
                series: [
                    {
                        name: fixedlabellist['passthroughnums'],
                        type: 'bar',
                        stack: 'total',
                        barWidth:'40%',
                        barGap:"60%",
                        color:'#3B7CFF',
                        label: {
                            show: true,
                            // offset:[0,parseInt(barwidth*0.6/2)],
                            offset:[0,parseInt(barwidth*0.56/2)],
                            color:'#333',

                            position:'insideLeft',
                            formatter: function(value){
                                var linedata = that.data.list[value.dataIndex];
                                if(linedata.sales_stage==fixedlabellist['Win']){
                                    return '';
                                    // return ['{x|'+linedata.allcurnum+' / '+linedata.allcuramount+fixedlabellist['unit']+'\n}{a|'+fixedlabellist['Winningcycle']+'：'+linedata.shichang+ '  '+fixedlabellist['avgunitprice']+'：}{b|'+linedata.avgamount+fixedlabellist['unit']+'}',
                                    // ].join('\n');
                                }else{
                                    return ['{x|'+linedata.allcurnum+' / '+linedata.allcuramount+fixedlabellist['unit']+'\n}{a|'+linedata.shichang+'  ' +fixedlabellist['Currentstay']+' ：}{b|'+linedata.curnum+'  }{a|'+fixedlabellist['Loss']+'：}{x|'+linedata.failnum+' / '+linedata.failamount+fixedlabellist['unit']+'}',
                                    ].join('\n');
                                }

                            },
                            rich: {
                                a: {
                                    color: '#333',
                                    lineHeight: 10
                                },
                                b: {
                                    color: 'blue',
                                    height: 30
                                },
                                x: {
                                    color: 'blue',
                                    fontSize: 13,
                                    fontFamily: 'Microsoft YaHei',
                                    borderColor: '#449933',
                                    borderRadius: 4
                                }
                            }
                        },
                        emphasis: {
                            disabled: true,
                            focus: 'none'
                        },
                        markLine:{
                            lineStyle: {
                                normal: {
                                    type: 'dashed', // 实线
                                    color: 'rgba(9,9,9,0.4)' // 线条颜色
                                },
                                emphasis: {
                                    color: 'rgba(9,9,9,1)', // 鼠标悬停时的颜色
                                    type: 'dashed'
                                }
                            },
                            itemStyle: {
                                normal: {
                                    borderColor: 'rgba(9,9,9,0.4)', // 箭头边框颜色
                                    borderWidth: 2, // 箭头边框线宽
                                    color: 'rgba(9,9,9,0.4)' // 起始点和结束点的颜色，即箭头的颜色
                                }
                            },
                            data:markLineData,
                            animation:false
                        }
                    },
                    {
                        name: fixedlabellist['curnums'],
                        type: 'bar',
                        stack: 'total',
                        color:'#84B7FF',
                        label: {
                            show: false
                        },
                        emphasis: {
                            disabled: true,
                            focus: 'none'
                        },
                        barWidth:'40%'
                    },
                    {
                        name: fixedlabellist['failnums'],
                        type: 'bar',
                        stack: 'total',
                        color:'#DDE1EA',
                        emphasis: {
                            disabled: true,
                            focus: 'none'
                        },
                        label: {
                            show: false
                        },
                        barWidth:'40%'
                    },
                    {
                        name: fixedlabellist['successnums'],
                        type: 'bar',
                        stack: 'total',
                        color:'#8BD5A8',
                        emphasis: {
                            disabled: true,
                            focus: 'none'
                        },
                        // yAxisIndex:1,
                        // xAxisIndex:1,
                        showBackground: true,
                        barWidth:'40%',
                        barGap:"60%",
                        label: {
                            show: true,
                            // position: 'right',
                            position:'insideLeft',
                            align:'left',
                            formatter: function(value){
                                var linedata = that.data.list[value.dataIndex];
                                if(linedata.sales_stage==fixedlabellist['Win']) {
                                    return ['{x|' + linedata.allcurnum + ' / ' + linedata.allcuramount + fixedlabellist['unit'] + '}',
                                    ].join('\n');
                                }else{
                                    return '';
                                }
                            },
                            rich: {
                                x: {
                                    color: 'blue',
                                    fontSize: 14,
                                    fontFamily: 'Microsoft YaHei',
                                    borderColor: '#449933',
                                    borderRadius: 4
                                }
                            }
                        },
                    }
                ]
            };
            return option;
        },
        //线索漏斗
        newChart_113 : function(){
            var ChartTable = that.getChartTable_113();
            if(that.Content_JqueryObj.siblings('.ChartTable').length > 0)
                that.Content_JqueryObj.siblings('.ChartTable').remove()
            that.Content_JqueryObj.after(ChartTable);
            //表格相关事件（穿透等）
            that.SetChartTableEvent('113');
            newChart_class.changeStuffHeight('113',0);

            var datalabel = that.data.datalabel;

            var pathInfo = that.data.pathInfo;
            var totalPathInfo = that.data.totalPathInfo;
            var total_data = that.data.total_data;
            total_data.salesorder_total = total_data.salesorder_total === undefined ? 0 : parseFloat(total_data.salesorder_total);
            total_data.cashbill_total = total_data.cashbill_total === undefined ? 0 : parseFloat(total_data.cashbill_total);
            /** 模块路径数组 */
            that.modulePath = []
            that.modulePath = that.data.modulePath;
            var total_data_arr = [];
            var xAxisData = [];
            var i;
            var Info;
            //第一列数据
            total_data_arr.push(total_data[pathInfo[1].col_name]);
            xAxisData.push(pathInfo[1].label);
            var salesorder_total = []
            salesorder_total.push(total_data.salesorder_total);
            var cashbill_total = []
            cashbill_total.push(total_data.cashbill_total);
            var ConWdith = that.Content_JqueryObj.get(0).clientWidth;
            var CirWidth = ConWdith * 0.25 * 0.5;
            var markLineData = [];
            var barNum = parseInt((pathInfo.length - 3) / 2) + 1;
            var barWidth = 60 / barNum;
            var total_rate = [],transInfo;
            for (i = 2;i < pathInfo.length - 2; i = i + 2) {
                transInfo = pathInfo[i];
                Info = pathInfo[i+1];
                var col_name = Info.col_name;
                total_data_arr.push(total_data[col_name]);
                xAxisData.push(Info.label);
                var tmp_rate = that.getDataByCalcMethod[transInfo.calc_method](transInfo,total_data);
                total_rate.push(tmp_rate);
                var barPosition = barWidth * parseInt((i - 2) / 2 + 1) + 5.5;
                var markItem = [
                    {
                        y: '50%',
                        x: (barPosition - barWidth * 0.15) + "%",
                    },
                    {
                        y: '50%',
                        x: (barPosition + barWidth * 0.15) + "%",
                    }
                ]
                markLineData.push(markItem);
            }
            //转换率垂直标线
            markLineData.push([
                {
                    x: '70%',
                    y: '15%',
                    label:{
                        show:false
                    }
                },
                {
                    x: '70%',
                    y: '80%',
                }
            ]);

            //总的转换率
            var trans_Info = totalPathInfo[0];
            var total_trans_rate = trans_Info.label + that.getDataByCalcMethod[trans_Info.calc_method](trans_Info,total_data);
            var cashbill_botom = (cashbill_total[0] !== undefined && cashbill_total[0] !== 0) ? 1 : 0;
            var option = {
                legend : {
                    icon: "roundRect",itemWidth:12,
                    itemHeight:12,
                    textStyle:{fontSize:12}
                },
                tooltip: {
                    show: true,
                    trigger: 'axis',
                    axisPointer : { // 坐标轴指示器，坐标轴触发有效
                        type : 'shadow' // 默认为直线，可选为：'line' | 'shadow'
                    },
                    formatter: function(param){
                        var series = param[0];//seriesName
                        var seriesName = '<span style="float: left;">' + series.name + '</span></br>';
                        var seriesData = that.TooltipFormatterMarker(series);
                        if(param[3]){
                            //edit: xll 2024/02/18 BUG20240117-77 首页，组件：线索漏斗测试，鼠标放在圆柱体上，未收金额应该为0，但显示的是341。
                            param[3].data = Math.abs(series.data - param[3].data);
                            var seriesData3 = that.TooltipFormatterMarker(param[3]);
                            return [seriesName,seriesData,seriesData3].join('\n');
                        }
                        return [seriesName,seriesData].join('\n');
                    },
                },
                grid : [
                    {
                        left : '5%',
                        width : '60%',
                    },
                    {
                        left : '70%',
                        width : '25%',
                        bottom: "25%",
                    }
                ],
                xAxis : [
                    {
                        gridIndex: 0,
                        type: 'category',
                        data: xAxisData
                    },
                    {
                        gridIndex: 1,
                        type: 'category',
                        show: false,
                        data: [xAxisData[xAxisData.length - 1] + '总金额']
                    },
                ],
                yAxis : [
                    {
                        gridIndex: 0,
                        type: 'value',
                    },
                    {
                        gridIndex: 1,
                        type: 'value',
                        show: false,
                    },
                ],
                //垂直标线上转换率的数据
                graphic: [
                    {
                        type: 'group',
                        rotation: 0,
                        bounding: 'raw',
                        left: '70%',
                        bottom: "50%",
                        z: 100,
                        cursor: 'default',
                        silent: true,
                        children: [
                            {
                                right: '5%',
                                bottom: "50%",
                                type: 'text',
                                left: 'center',
                                top: 'center',
                                z: 100,
                                style: {
                                    fill: '#000',
                                    lineHeight:30,
                                    textVerticalAlign:'middle',
                                    text: total_trans_rate,
                                    font: '13px sans-serif',
                                    backgroundColor:'#FFF'
                                }
                            }
                        ]
                    }
                ],
                series : [
                    {
                        name: arrJsPopLabel['BILLNUM'],//'单据数量',
                        xAxisIndex: 0,
                        yAxisIndex: 0,
                        data: total_data_arr,
                        type: 'bar',
                        barWidth: 30,
                        label:datalabel,
                        markLine: {
                            data:markLineData,
                            lineStyle: {
                                color:'#999',
                                type: "solid",
                            },
                            silent: true,//不响应鼠标事件
                            animation:true,
                            label: {
                                show:true,
                                position:"middle",
                                distance: 10,
                                color:'#000',
                                formatter: function(param){
                                    return total_rate[param.dataIndex];
                                },
                            },
                        }
                    },
                ],
            };
            //edit: xll 2024/02/01 BUG20240112-22 线索漏斗数据为零时，图中圆柱位置错乱
            if(salesorder_total[0] > 0){
                //圆柱的 series 数组
                var cySeriesArr = [
                    //圆柱数据
                    {
                        xAxisIndex: 1,
                        yAxisIndex: 1,
                        id: 'ReceivedData',
                        name: arrJsPopLabel['AmountReceived'],//'已收金额',
                        type: 'bar',
                        barWidth: CirWidth,
                        z: 1,
                        label: {
                            show: false
                        },
                        itemStyle: {
                            opacity: 1, // 这个是 透明度
                            color: '#3B7CFF',
                        },
                        data: cashbill_total
                    },
                    //圆柱顶部
                    {
                        xAxisIndex: 1,
                        yAxisIndex: 1,
                        id: 'ReceivedTop',
                        name: arrJsPopLabel['AmountReceived'],//'已收金额',
                        type: 'pictorialBar',
                        symbolSize: [CirWidth, CirWidth * 0.3],
                        symbolOffset: [0, CirWidth * 0.15 * (-1)],
                        z: 3,
                        itemStyle: {
                            normal: {
                                opacity: 1,
                                color: '#94AEE2',
                            }
                        },
                        emphasis:{
                            disabled:true,
                            focus:"none"
                        },
                        label: {
                            show: true, // 开启显示
                            position: 'right',
                            offset: [0, 0],
                            distance : 0,
                            textStyle: {
                                // 数值样式
                                color: '#000',
                                fontSize: 14,
                                left: 0
                            },
                            formatter: function (params) {
                                if(salesorder_total[0] === 0)
                                    return '0%';
                                return ((cashbill_total[0] / salesorder_total[0]) * 100).toFixed(2) + '%';
                            }
                        },
                        symbolPosition: 'end',
                        data: cashbill_total
                    },
                    //圆柱底部
                    {
                        xAxisIndex: 1,
                        yAxisIndex: 1,
                        id: 'ReceivedBottom',
                        name: arrJsPopLabel['AmountReceived'],//'已收金额',
                        type: 'pictorialBar',
                        symbolSize: [CirWidth, CirWidth * 0.3],
                        symbolOffset: [0, CirWidth * 0.15 * (-1)],
                        z: 2,
                        itemStyle: {
                            opacity: 1,
                            color: '#3B7CFF',
                            shadowBlur: 10,
                            shadowOffsetY: 10,
                            shadowColor: "#9b9b9b"
                        },
                        label: {
                            show: false, // 开启显示
                        },
                        emphasis:{
                            disabled:true,
                            focus:"none"
                        },
                        symbolPosition: 'end',
                        data: [cashbill_botom] //项目中实际需要0改成1才显示圆圈
                    },
                    //灰色圆柱数据
                    {
                        xAxisIndex: 1,
                        yAxisIndex: 1,
                        id: 'NotReceivedData',
                        name: arrJsPopLabel['AmountNotReceived'],//'未收金额',
                        type: 'pictorialBar',
                        symbolSize: [CirWidth, (1 - cashbill_total[0] / salesorder_total[0]) * 100 + '%'],
                        symbol: "rect",
                        symbolOffset: [0, 0],
                        z: 1,
                        itemStyle: {
                            normal: {
                                opacity: 0.8,
                                color: '#cacaca',
                                label: {
                                    show: false, // 开启显示
                                }
                            }
                        },
                        emphasis:{
                            disabled:true,
                            focus:"none"
                        },
                        symbolPosition: 'end',
                        data: salesorder_total
                    },
                    //灰色圆柱顶部
                    {
                        xAxisIndex: 1,
                        yAxisIndex: 1,
                        id: 'NotReceivedTop',
                        name: arrJsPopLabel['AmountNotReceived'],//'未收金额',
                        type: 'pictorialBar',
                        symbolSize: [CirWidth, CirWidth * 0.3],
                        symbolOffset: [0, CirWidth * 0.15 * (-1)],
                        z: 3,
                        itemStyle: {
                            normal: {
                                opacity: 1,
                                color: '#e0e0e0',
                                label: {
                                    show: false, // 开启显示
                                }
                            }
                        },
                        emphasis:{
                            disabled:true,
                            focus:"none"
                        },
                        label: {
                            show: false, // 开启显示
                        },
                        symbolPosition: 'end',
                        data: salesorder_total
                    },
                    //灰色圆柱底部
                    {
                        xAxisIndex: 1,
                        yAxisIndex: 1,
                        id: 'NotReceivedBottom',
                        name: arrJsPopLabel['AmountNotReceived'],//'未收金额',
                        type: 'pictorialBar',
                        symbolSize: [CirWidth, CirWidth * 0.3],
                        symbolOffset: [0, CirWidth * 0.15 * (-1)],
                        z: 3,
                        itemStyle: {
                            normal: {
                                opacity: 0.7,
                                color: '#cacaca',
                                label: {
                                    show: false, // 开启显示
                                }
                            }
                        },
                        emphasis:{
                            disabled:true,
                            focus:"none"
                        },
                        label: {
                            show: false, // 开启显示
                        },
                        symbolPosition: 'end',
                        data: cashbill_total
                    },
                ];
                option.series = [...option.series,...cySeriesArr];
            }
            return option;
        },
        //目标完成率分析（多仪表盘）
        newChart_114 : function(){
            if(that.data.GaugeNum === 0){
                return false;
            }
            // edit: xll 2024/05/06 BUG20240430-37 移动端纵向排列
            var popupObj = CrmPopup.getPopupObj('last'),
                isMobile = (popupObj && popupObj.boardtype && (popupObj.boardtype === 'MobileReport'||popupObj.boardtype === 'prmMobileHome')),
                colNum = isMobile ? 1 : 3,
                gaugeList = that.data.res_data,
                GaugeNum = that.data.GaugeNum,
                RowNum = Math.ceil(GaugeNum / colNum),
                RowHeight = (that.data.gaugeSet && that.data.gaugeSet.rowHeight) ? that.data.gaugeSet.rowHeight : 400 ,
                rowIndex = 0,
                colIndex = 0,
                widthRate = isMobile ? 45 : 14,
                heightRate1 = 35,
                option = {
                    graphic : [],
                    series : [],
                },
                radiusWidth = that.Content_JqueryObj.get(0).clientWidth * widthRate / 100,
                radiusHeight = RowHeight * heightRate1 / 100,
                radius = radiusWidth < radiusHeight ? radiusWidth : radiusHeight;
            that.Content_JqueryObj.css('height',RowNum * RowHeight + 'px');
            newChart_class.changeStuffHeight('114',0);
            ld.each(gaugeList,function (stuffLabel, gaugeInfo) {
                var left = (5 + colIndex * 3 + widthRate + colIndex * widthRate * 2) + '%',
                    dataObj = {
                        id: stuffLabel,
                        label: gaugeInfo.title,
                        rate: gaugeInfo.rate
                    },
                    gaugeSeries = that.getGaugeSeries(dataObj,{
                        name: stuffLabel,
                        center : [left,RowHeight * rowIndex + RowHeight * 0.5],
                        radius : radius,
                    }),
                    gaugeGraphic = that.getGaugeGraphic(gaugeInfo,{
                        id: stuffLabel,
                        left : left,
                        top : (RowHeight * rowIndex + RowHeight * 0.85),
                    });
                option.graphic.push(gaugeGraphic);
                option.series.push(gaugeSeries);
                colIndex ++;
                if(colIndex === colNum){
                    rowIndex += 1;
                    colIndex = 0;
                }
            });
            return option;
        },
        //天地 特殊开发 销售漏斗（含目标）
        newChart_115 : function(){
            var fixedlabellist = that.data.fieldlabellist;

            var visualMapPieces1 = [
                {gte: 0, lt: 1, color: '#ff8000',opacity:0.7},
                {gte: 1, lt: 2, color: '#ffd22a',opacity:0.7},
                {gte: 2, lt: 3,color: '#94ce55',opacity:0.7},
                {gte: 3, lt: 4, color: '#16b7ae',opacity:0.7},
                {gte: 4, lt: 5,color: '#3082ff',opacity:0.7},
                {gte: 5, lt: 6, color: '#9cc3df',opacity:0.7}
            ];
            var visualMapPieces2 = [
                {gte: 0, lt: 1, color: '#ff8000',opacity:0.4},
                {gte: 1, lt: 2, color: '#ffd22a',opacity:0.4},
                {gte: 2, lt: 3,color: '#94ce55',opacity:0.4},
                {gte: 3, lt: 4, color: '#16b7ae',opacity:0.4},
                {gte: 4, lt: 5,color: '#3082ff',opacity:0.4},
                {gte: 5, lt: 6, color: '#9cc3df',opacity:0.4}
            ];
            var option = {
                graphic:[{
                    id: 'rect1-label',
                    bottom:'20%',
                    left:'5%',
                    type: 'text',
                    style: { font: '18px Microsoft YaHei', text: '项目合计金额: '}
                },{
                    id: 'rect1-data',
                    bottom:'20%',
                    right: '50%',
                    type: 'text',
                    style: { font: '18px Microsoft YaHei', text: that.data.total+fixedlabellist['unit'], textAlign: 'right' }
                },{
                    id: 'rect2-label',
                    bottom:'20%',
                    left:'55%',
                    type: 'text',
                    style: {font: '18px Microsoft YaHei', text: '项目数量合计: '}
                },{
                    id: 'rect2-data',
                    bottom:'20%',
                    right: '5%',
                    type: 'text',
                    style: {font: '18px Microsoft YaHei', text: that.data.totalnum+'  个', textAlign: 'right' }
                },{
                    id: 'rect3-label',
                    bottom:'10%',
                    left:'5%',
                    type: 'text',
                    style:{font: '18px Microsoft YaHei', text: '可见合计金额: ' }
                },{
                    id: 'rect3-data',
                    bottom:'10%',
                    right: '50%',
                    type: 'text',
                    style:{font: '18px Microsoft YaHei', text: that.data.kejian+fixedlabellist['unit'], textAlign: 'right' }
                },{
                    id: 'rect4-label',
                    bottom:'10%',
                    left:'55%',
                    type: 'text',
                    style:{color:'#00ff00',font: '18px Microsoft YaHei',text: '缺口: '},
                },{
                    id: 'rect4-data',
                    bottom:'10%',
                    right: '5%',
                    type: 'text',
                    style:{
                        color:'#00ff00',
                        font: '18px Microsoft YaHei',
                        text: that.data.quekou+fixedlabellist['unit'],
                        textAlign: 'right'
                    },
                }],
                tooltip: {
                    trigger: 'item',
                    formatter: function(value){
                        var listlength = that.data.list.length;
                        var key = listlength-value.dataIndex-1;
                        var linedata = that.data.list[key];
                        return [
                            linedata.stagename+'</br>',
                            fixedlabellist['QUANTITY']+'：'+linedata.countnum_str+'</br>',
                            fixedlabellist['Estimatedprojectamount']+'：'+linedata.sumtotal_str+fixedlabellist['unit']+'</br>',
                            fixedlabellist['TOLOOKVALUE']+'：'+(linedata.targetamount_str)+fixedlabellist['unit']+'</br>'
                        ].join('\n');
                    },
                },
                legend: {
                    show:false,
                },
                grid: {
                    top:'0%',
                    left: '10',
                    right: '10',
                    bottom: '20%',
                    containLabel: true
                },
                xAxis: [
                    {
                        show:false
                    }
                ],
                yAxis: [
                    {
                        type: 'category',
                        show:false,
                        splitLine:{show:false},
                        axisLine:{show:false},
                        axisTick:{show:false},//隐藏刻度线
                        axisLabel:{verticalAlign:'top',lineHeight:50},
                        data: that.data.legend_arr
                    },{
                        type: 'category',
                        show:true,
                        splitLine:{show:false},
                        axisLine:{show:false},
                        axisLabel:{verticalAlign:'top',lineHeight:40},
                        axisTick:{show:false},//隐藏刻度线
                        data:that.data['rate_arr']
                    }
                ],
                visualMap: [{
                    type: 'piecewise',
                    splitNumber:6,
                    show: false,
                    seriesIndex:0,
                    pieces: visualMapPieces1
                },{
                    type: 'piecewise',
                    splitNumber:6, show: false,
                    seriesIndex:1,
                    pieces: visualMapPieces1
                },{
                    type: 'piecewise',
                    splitNumber:6, show: false,
                    seriesIndex:2,
                    pieces: visualMapPieces2
                },{
                    type: 'piecewise',
                    splitNumber:6, show: false,
                    seriesIndex:3,
                    pieces: visualMapPieces2
                }],
                series: [
                    {
                        name: '目标',
                        type: 'line',
                        areaStyle: {},
                        zlevel: 5, // 系列1的zlevel
                        color:'#91cc75',
                        hoverAnimation :false,
                        barWidth:'100%',
                        barGap:'1',
                        smooth: false,
                        label: {
                            show: false,
                            position: 'top',
                            color:'#111',
                            formatter:function(value){
                                var linedata = that.data.list[value.dataIndex];
                                return linedata.countnum_str+' / '+linedata.sumtotal_str+fixedlabellist['unit']+' / '+linedata.targetamount_str+fixedlabellist['unit'];
                            }
                        },
                        emphasis: {
                            focus: 'none',
                            style: {
                                // 在这里定义悬停时的样式，留空表示无变化
                            }
                        },
                        data: that.data['seriesdata1']
                    },
                    {
                        name: '目标',
                        type: 'line',
                        zlevel: 5, // 系列1的zlevel
                        areaStyle: {}, hoverAnimation :false,
                        barWidth:'100%',
                        barGap:'1',
                        smooth: false,
                        color:'#91cc75',
                        label: {
                            show: false,
                            position: 'insideBottomLeft',
                            color:'#111',
                            formatter: function(value){
                                var linedata = that.data.list[value.dataIndex];
                                return linedata.sumtotal_str+fixedlabellist['unit']+' / '+linedata.targetamount_str+fixedlabellist['unit'];
                            },// 标签文本
                        },
                        emphasis: {
                            focus: 'none', style: {
                                // 在这里定义悬停时的样式，留空表示无变化
                            }
                        },
                        data:that.data['seriesdata2']
                    },
                    {
                        name: '实际',
                        type: 'line',
                        zlevel: 1, // 系列1的zlevel
                        areaStyle: {},
                        hoverAnimation :false,
                        barWidth:'100%',
                        barGap:'-100%',
                        smooth: false,
                        label: {
                            show: false
                        },
                        emphasis: {
                            focus: 'none', style: {
                                // 在这里定义悬停时的样式，留空表示无变化
                            }
                        },
                        data: that.data['seriesdata3']
                    },
                    {
                        name: '实际',
                        type: 'line',
                        zlevel: 1, // 系列1的zlevel
                        areaStyle: {}, hoverAnimation :false,
                        color:'#5470c6',
                        barWidth:'100%',
                        barGap:'-100%',
                        smooth: false,
                        label: {
                            show: false
                        },
                        emphasis: {
                            focus: 'none', style: {
                                // 在这里定义悬停时的样式，留空表示无变化
                            }
                        },
                        data:that.data['seriesdata4']
                    },
                    {
                        name: '实际',
                        type: 'funnel',
                        zlevel: 100, // 系列1的zlevel
                        left: '13%',
                        width: '80%',
                        top: '5%',
                        bottom: "30%",
                        gap: 0,
                        colorBy:'data',
                        maxSize: '75%',
                        minSize: '10%',
                        sort : 'none',
                        label: {
                            normal: {
                                opacity:1,
                                color:'#333',
                                borderColor:'#333',
                                shadowColor:'#333',
                                textBorderColor:'#333',
                                position: 'inside',     // 标签的位置:'left'漏斗图的左侧）、'right'(右侧)、'inside'(内部) [ default: 'outside' ]
                                formatter: function(value){
                                    var listlength = that.data.list.length;
                                    var key = listlength-value.dataIndex-1;
                                    var linedata = that.data.list[key];
                                    return linedata.countnum_str+' / '+linedata.stagename+' / '+linedata.sumtotal_str+fixedlabellist['unit']+' / '+linedata.targetamount_str+fixedlabellist['unit'];
                                }
                            },
                        },
                        itemStyle: {
                            normal: {
                                opacity: 0.0,// 系列2图形透明度
                            }
                        },
                        data: [
                            {value: 90, name: '潜在机会',color:'#9CC3DF'},
                            {value: 75, name: '未立项',color:'#99C39C'},
                            {value: 60, name: '立项准备',color:'#F1C64C'},
                            {value: 45, name: '已立项',color:'#ED84A2'},
                            {value: 30, name: '招投标',color:'#A1B5BC'},
                            {value: 15, name: '合同签订',color:'#F18770'},
                        ]
                    }
                ]
            };
            return option;
        },
        newChart_119 : function(){
            var option = that.data['option'];
            return option;
        }
    }

    /** 获取龙虎榜富文本配置项 */
    this.getOptionRich_100 = function (icon_arr) {
        var OptionRich = {
            value: {
                lineHeight: 20,
                align: 'center'
            },
            username: {
                width:80,
                ellipsis:true,
                fontSize:13,
                fontWeight:'bold',
                align: 'right',
                verticalAlign:'bottom'
            },
            groupname: {
                width:116,
                ellipsis:true,
                fontSize:10,
                height: 22,
                padding:[0,0,0,36],
                align: 'right',
                verticalAlign:'top'
            },
            icon_top_rest: {
                width:22,
                align: 'center',
                verticalAlign:'bottom',
                fontSize:13,
            },
        };
        for (let i = 0; i < icon_arr.length; i ++) {
            OptionRich['icon_top_' + (i + 1)] = {
                width:22,
                height: 22,
                align: 'center',
                verticalAlign:'center',
                backgroundColor: {
                    image: icon_arr[i],
                },
            }
        }
        return OptionRich;
    }
    /** 穿透到子图，获取子图的echarts配置项的方法集合 */
    this.getChildChartOption = {
        ChildChart_114 : function () {
            var label = { Target : TOLOOKVALUE, Done : COMPLETIONVALUE},
                data = that.ChildChartData;
            var option =  {
                title: that.gettitle(),
                grid: that.getgrid(),
                xAxis: {
                    type: 'category',
                    data: data.nameArr,
                    axisLabel: {
                        rotate: 30,
                    }
                },
                yAxis: {
                    name: '单位：万',
                    type: 'value',
                    min: 0,
                    axisLabel: {

                    }
                },
                legend: {
                    type: 'scroll',
                    selectedMode : false,
                    top: 14,
                    itemWidth:12,
                    itemHeight:12,
                    textStyle:{fontSize:12},
                    data : [
                        {
                            name : label.Target,
                            itemStyle : data.colorArr.Target
                        },
                        {
                            name : label.Done,
                            itemStyle : data.colorArr.Done,
                        }
                    ]
                },
                tooltip: {
                    show: true,
                    trigger: 'axis',
                    axisPointer : { // 坐标轴指示器，坐标轴触发有效
                        type : 'shadow' // 默认为直线，可选为：'line' | 'shadow'
                    },
                    formatter: function(param){
                        var TopSeries = param[1],
                            BottomSeries = param[0],
                            TopName = TopSeries.data.name,
                            BottomName = BottomSeries.data.name,
                            TargetDoneData = {};
                        TargetDoneData[TopName] = {
                            data : TopSeries.data.value,// + BottomSeries.data.value,
                            marker : TopSeries.marker,
                            seriesName : label[TopName],
                        };
                        TargetDoneData[BottomName] = {
                            data : BottomSeries.data.value,
                            marker : BottomSeries.marker,
                            seriesName : label[BottomName],
                        };
                        var TipHead = '</br>',
                            TipArr = [];
                        ld.each(TargetDoneData,function (type,seriesParam) {
                            TipArr.push(that.TooltipFormatterMarker(seriesParam));
                        });
                        return TipArr.join('\n');
                    },
                },
                series: []
            }
            option.series.push(
                that.getBarSeries({
                    name : label.Target,
                    data : data.BottomData,
                    colorBy : 'data',
                    itemStyle : data.colorArr.Target
                })
            )
            option.series.push(
                that.getBarSeries({
                    name : label.Done,
                    barGap : '-100%',
                    data : data.TopData,
                    colorBy : 'data',
                    itemStyle : data.colorArr.Done
                })
            )
            return option;
        }
    }
    //首页默认组件的点击穿透事件
    this.setClickEvent = {
        click_1 : function(params,stuffid){
            var params_data = '';
            params_data += '&XAxisName='+encodeURIComponent(params.name)+'&SeriesName='+encodeURIComponent(params.seriesName)+'&dataIndex='+params.dataIndex;
            params_data += '&SeriesIndex='+params.seriesIndex;
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(stuffid,params_data);
        },
        click_9 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid);},
        click_4 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_5 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_19 : function(params,stuffid){
            var clickvalueData = that.data['clickvalue'];//漏斗点击信息
            //zxm 20230714 新的穿透
            var boardstuffid=0;
            if(ld('#stuff_19').data('boardstuffid')>0){
                boardstuffid = ld('#stuff_19').data('boardstuffid');
            }
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.home_href_popup(19,boardstuffid,clickvalueData[params.dataIndex]);
        },
        click_40 : function(params,stuffid){
            var params_data = '';
            params_data += '&XAxisName='+encodeURIComponent(params.name)+'&SeriesName='+encodeURIComponent(params.seriesName)+'&dataIndex='+params.dataIndex;
            params_data += '&SeriesIndex='+params.seriesIndex;
            params_data += '&data_type='+that.params['data_type'];//近六个月目标完成情况 页签切换的值
            params_data += '&targetid='+that.params['targetid'];//近六个月目标完成情况 页签切换的值
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(stuffid,params_data);
        },
        click_41 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_42 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_44 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_45 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_48 : function(params,stuffid){return },
        click_53 : function(params,stuffid){return },
        click_49 : function(params,stuffid){return },
        click_55 : function(params,stuffid){return },
        click_61 : function(params,stuffid){return },
        click_62 : function(params,stuffid){return },
        click_63 : function(params,stuffid){
            var projectname = params.name;
            var seriesName = params.seriesName;
            if(seriesName=='未收合同额'||seriesName=='预计支出金额'||seriesName=='动态毛利'){
                return false;//穿透 todo
            }
        },
        click_57 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_105 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_106 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_107 : function(params,stuffid){that.setClickEvent.click_1(params,stuffid); },
        click_100 : function(params,stuffid){
            var params_data = '';
            params_data += '&stufflabel='+that.params['data_type'];//页签  对应l'd_homestuffdetail的stufftitle
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.initParam();
            var unchangeParams = ChartChuantouObj.unchangeParams;
            //edit: xll 2023/11/13 BUG0075284 龙虎榜的查看范围需要特殊处理
            //ChartChuantouObj.changeParams = "&scopeType=smowner_search_senior&selectuserid="+params.name;
            ChartChuantouObj.params_data = "&groupby_value="+params.name;//分组的值
            var boardstuffid=0;
            boardstuffid = ld('#stuff_'+stuffid).data('boardstuffid');
            unchangeParams += "&stuffid="+stuffid+"&boardstuffid="+boardstuffid+"&stufftype=defaultstuff";
            unchangeParams += params_data ;
            // edit: xll 2024/07/22 BUG20240722-11 龙虎榜穿透后查看范围不对，导致切换模块后数据出错
            ChartChuantouObj.setCallBack(function () {
                ChartChuantouObj.popup_ChuantouObj.setScope('smowner_search_senior',params.name);
            });
            ChartChuantouObj.popupchuantou(ChartChuantouObj.surl+unchangeParams,ChartChuantouObj.changeParams,boardstuffid);
        },
        click_101 : function(params,stuffid){
            var params_data = '';
            params_data += '&SeriesName='+encodeURIComponent('完成值');
            params_data += '&SeriesIndex=1';
            params_data += '&data_type='+that.params['data_type'];//近六个月目标完成情况 页签切换的值
            params_data += '&targetid='+that.params['targetid'];//近六个月目标完成情况 页签切换的值
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(stuffid,params_data);
        },
        click_102 : function(params,stuffid){
            that.params.data_type = 'dragontiger_NewSignContractCount';
            that.setClickEvent.click_100(params,stuffid);
        },
        click_103 : function(params,stuffid){
            that.params.data_type = 'dragontiger_NewSignContractAmount';
            that.setClickEvent.click_100(params,stuffid);
        },
        click_104 : function(params,stuffid){
            that.params.data_type = 'dragontiger_NewCashBillAmount';
            that.setClickEvent.click_100(params,stuffid);
        },
        click_112 : function(params,stuffid){
            if(params['componentType']=='markLine'){
                return false;
            }
            var params_data = '';
            params_data += '&XAxisName='+encodeURIComponent(params.name)+'&SeriesName='+encodeURIComponent(params.seriesName);
            params_data += '&SeriesIndex='+params.seriesIndex;
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.SalesPhaseTransformationAnalysisChuantou(stuffid,params_data);
        },
        click_113 : function(params,stuffid){

            var params_data = '&PenetrateType=Chart';
            var moduleIndex = 0;
            var modulePath = that.modulePath;
            //点击左侧柱状图柱子
            if(params.seriesIndex === 0) {
                moduleIndex = params.dataIndex;
            }
            //点击右侧圆柱
            else {
                //点击灰色部分圆柱，即未收金额
                if(params.seriesId.includes('NotReceived')) {
                    moduleIndex = modulePath.length - 2;
                }
                //点击蓝色部分圆柱，即已收金额
                else {
                    moduleIndex = modulePath.length - 1;
                }
            }
            var click_module = modulePath[moduleIndex];
            params_data += '&XAxisName='+click_module;
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(stuffid,params_data);

        },
        click_114 : function (params,stuffid) {
            var seriesIndex;
            var params_data,SeriesName,stufflabel = (params.componentType === 'series') ? params.seriesName : params.name,
                gaugeInfo = that.data.res_data[stufflabel],
                homestuffdetailid = gaugeInfo.homestuffdetailid,gaugeName = gaugeInfo.title;
            if(params.componentType === 'graphic'){
                if(params.info === 'target'){
                    seriesIndex = 'Target';
                    SeriesName = TOLOOKVALUE;
                }
                else if(params.info === 'done'){
                    seriesIndex = 'Done';
                    SeriesName = COMPLETIONVALUE;
                }
            }
            else if(params.componentType === 'series'){
                seriesIndex = 'Done';
                SeriesName = COMPLETIONRATE;
            }
            params_data = '&SeriesIndex='+seriesIndex+'&SeriesName='+encodeURIComponent(SeriesName)+'&targetid='+that.params['targetid'];
            params_data += '&homestuffdetailid='+homestuffdetailid+'&gaugeName='+gaugeName+'&penetrateModule=SalesGoal';
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.setChildChartParam({
                newChartObj : that,
            });
            ChartChuantouObj.HomeStuffToChildChart(stuffid,params_data);
        },
        //天地 特殊开发 销售漏斗（含目标）
        click_115 : function(params,stuffid){
            if(params['componentType']!='series'){
                return false;
            }
            var params_data = '';
            params_data += '&XAxisName='+encodeURIComponent(params.name)+'&SeriesName='+encodeURIComponent(params.seriesName);
            params_data += '&SeriesIndex='+params.seriesIndex;
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(stuffid,params_data);
        },
        click_119 : function(params,stuffid){
            var params_data = '';
            params_data += '&XAxisName='+encodeURIComponent(params.name)+'&SeriesName='+encodeURIComponent(params.seriesName)+'&dataIndex='+params.dataIndex;
            params_data += '&SeriesIndex='+params.seriesIndex;
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(stuffid,params_data);
        }
    }
    //龙虎榜排序修改方法
    this.UpdateMychartSeq = function (fun_name) {
        that.dataSeqType = that.dataSeqTypeChange[that.dataSeqType];
        that.data.userdata_arr = that.data.userdata_arr.reverse();
        that.data.UserdataStringArr = that.data.UserdataStringArr.reverse();
        that.data.userid_arr['id'] = that.data.userid_arr['id'].reverse();
        that.data.userid_arr1 = that.data.userid_arr1.reverse();
        that.setOption(that.getOption(fun_name));
    }
    this.TooltipPosition = function(point, params, dom, rect, size) {
        // point: 鼠标位置 [x, y]。
        // params: 与当前鼠标位置相关的数据信息对象。
        // dom: tooltip 的 DOM 节点。
        // rect: 绑定了 tooltip 的图形的包围盒。
        // size:  包括 size.contentSize 和 size.viewSize，其中每个都是 [width, height] 形式的数组。
        // 返回值是 [x, y] 形式的数组，表示 tooltip 的位置。
        // 以下代码确保 tooltip 不会超出边界
        var result = [point[0], point[1]];
        if (result[0] + size.contentSize[0] > size.viewSize[0]) {
            result[0] = size.viewSize[0] - size.contentSize[0];
        }
        if (result[1] + size.contentSize[1] > size.viewSize[1]) {
            result[1] = size.viewSize[1] - size.contentSize[1];
        }
        return result;
    }
    this.TooltipFormatterMarker = function (seriesParam) {
        var color = seriesParam.marker.split(':');
        color = color[color.length - 1].split(';')[0];
        return '<span style="float: left;margin-right:4px;border-radius:4px;width:10px;height:10px;background-color:'+color+';margin-top: 6px;"></span>'
            + seriesParam.seriesName + '\t' + '<span style="font-weight: bold;margin-right: 5px">' + seriesParam.data + '</span></br>';
    }
    /** 获取线索漏斗的表格 */
    this.getChartTable_113 = function () {
        var data = that.data;
        var pathInfo = data.pathInfo;
        var res_data = data.res_data;
        res_data.push(data.total_data);
        var totalPathInfo = data.totalPathInfo;
        //that.tdWidth = (100 / pathInfo.length - 1).toFixed(2) + '%';
        return '<div class="ChartTable customtable-content" style="width:90%;margin: 30px 5%;overflow: auto;">' +
                   '<table border="0" cellSpacing="1" cellPadding="0" id="thResizable" class="customtable-list" width="100%">' +
                        that.getChartTableHead(pathInfo,totalPathInfo) +
                        that.getChartTableBody(res_data,pathInfo,totalPathInfo) +
                   '</table>' +
               '</div>';
    }
    this.getChartTableHead = function (thList,thTotalList) {
        var ChartTable = '<thead style="font-size: 13px;font-weight:normal !important;">' +
                            '<tr id="reportDetailHeader" style="height:40px;position:sticky;top:0;">';
        var index = 0;
        for (var i = 0; i < thList.length - 2; i ++) {
            var thInfo = thList[i];
            var label = (thInfo.table_col_label) ? thInfo.table_col_label : thInfo.label; //width="'+that.tdWidth+'"
            ChartTable +=       '<th thindex="'+i+'" align="center" style="text-align: center" >'+label+'</th>';
            index ++;
        }
        if(thTotalList && thTotalList.length && thTotalList.length > 0) {
            ld.each(thTotalList,function (thindex,thInfo) {
                var thLabel = (thInfo.table_col_label) ? thInfo.table_col_label : thInfo.label;
                ChartTable +=   '<th thindex="'+(index + thindex)+'" align="center" style="padding-left: 15px;text-align: center" >'+thLabel+'</th>';
            });
        }
        ChartTable +=       '</tr>' +
                        '</thead>';
        return ChartTable;
    }
    this.getChartTableBody = function (trList,tdList,tdTotalList) {
        var ChartTable = '<tbody style="background-color: #fff;" id="reportDetailBody">' ;
        ld.each(trList,function (trindex,trInfo) {
            var trClass = (trindex % 2 === 0) ? 'lvtColData' : 'lvtColDataBj';
            ChartTable +=   '<tr class="'+trClass+'" rowindex="'+trindex+'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),  \'on\')">';
            var thlabel = trInfo[tdList[0].col_name];
            ChartTable +=       '<th tdindex="0" style="padding:0 3px 0' +
                ' 10px;position:sticky;left:0;background-color: #f0f4fc;text-align: center" align="right">'+thlabel+'</th>';
            var index = 1;
            for (var i = 1; i < tdList.length - 2; i ++) {
                var tdInfo = tdList[i];
                var tdLabel = trInfo[tdInfo.col_name];
                if(tdInfo.calc_method && that.getDataByCalcMethod[tdInfo.calc_method])
                    tdLabel = that.getDataByCalcMethod[tdInfo.calc_method](tdInfo,trInfo);
                //穿透
                if(!(tdInfo.can_penetrate && tdInfo.can_penetrate === 'no')){
                    tdLabel = '<a class="Anu3_a" target="_blank" tag="gotoList">' +  tdLabel + '</a>' ;
                }
                ChartTable +=   '<td tdindex="'+index+'" style="padding:0 10px 0 3px;" align="right">' +
                                    tdLabel +
                                '</td>';
                index ++;
            }
            if(tdTotalList && tdTotalList.length && tdTotalList.length > 0) {
                ld.each(tdTotalList,function (tdindex,tdInfo) {
                    var tdLabel = that.getDataByCalcMethod[tdInfo.calc_method](tdInfo,trInfo);
                    //穿透
                    if(!(tdInfo.can_penetrate && tdInfo.can_penetrate === 'no')){
                        tdLabel = '<a class="Anu3_a" target="_blank" tag="gotoList">' +  tdLabel + '</a>' ;
                    }
                    ChartTable +=   '<td tdindex="'+(index + tdindex)+'" style="padding:0 10px 0 3px;" align="right"' +
                        ' width="'+that.tdWidth+'">' +
                                        tdLabel +
                                    '</td>'
                });
            }
            ChartTable +=   '</tr>';
        });
        ChartTable +=   '</tbody>';
        return ChartTable;
    }
    /** 通过计算方法求值 的集合，键为计算方法，键值为函数 该函数参数包括 colInfo字段信息对象，dataInfo数据对象 */
    this.getDataByCalcMethod = {
        rate : function (colInfo,dataInfo) {
            var value;
            var mol_value = dataInfo[colInfo.col_name];
            var den_value = dataInfo[colInfo.before_col];
            if(mol_value  !== undefined && den_value  !== undefined && den_value !== 0)
                value =  (( mol_value / den_value) * 100).toFixed(2);
            else
                value =  '0.00';
            return value + '%';
        },
        value : function (colInfo,dataInfo) {
            var value = dataInfo[colInfo.col_name];
            if(value !== undefined)
                return value;
            else
                return 0;
        },
        value_rate : function (colInfo,dataInfo) {
            var value = dataInfo[colInfo.col_name];
            if(value  !== undefined)
                value = (value * 100).toFixed(2);
            else
                value = '0.00';
            return value + '%';
        },
        multiply_rate : function (colInfo,dataInfo) {
            var data = 1;
            var coef = 1;
            ld.each(colInfo.col_name,function (index,col) {
                if(dataInfo[col] !== undefined)
                    data *= dataInfo[col];
                else{
                    coef = 0;
                    return false;
                }
            });
            data *= coef;
            return (data * 100).toFixed(2) + '%';
        },
    }
    /** 表格相关事件（穿透等） */
    this.SetChartTableEvent = function (stuffid) {
        that.stuffid = stuffid;
        var TableObj = that.Content_JqueryObj.siblings('.ChartTable');
        that.Table_JqueryObj = TableObj;
        var PenetrateObjList = TableObj.find('td a[tag=gotoList]');
        PenetrateObjList.unbind('click').bind('click',function () {
            var Td_JqObj = ld(this).parent('td');
            that.ChartTablePenetrate['Penetrate_'+stuffid](Td_JqObj);
        });
    }
    this.ChartTablePenetrate = {
        Penetrate_113 : function (Td_JqObj) {
            var tdindex = parseInt(Td_JqObj.attr('tdindex'));
            var params_data = '&PenetrateType=Table';
            var moduleIndex = 0;
            var moduleArr = that.data.pathInfo;
            //表格左侧模块数量列
            if(tdindex < moduleArr.length - 2) {
                moduleIndex = tdindex;
            }
            //表格右侧模块汇总列
            else {
                moduleIndex = tdindex - (moduleArr.length - 2);
                moduleArr = that.data.totalPathInfo;
            }
            var click_module = moduleArr[moduleIndex].module;
            params_data += '&XAxisName='+click_module;
            var Tr_JqObj = Td_JqObj.parent('tr');
            var RowIndex = parseInt(Tr_JqObj.attr('rowindex'));
            var Type;
            //合计行为空
            if(RowIndex === that.data.res_data.length - 1){
                Type = '';
            }
            else{
                Type = Tr_JqObj.find('th[tdindex="0"]').text();
            }
            params_data += '&SeriesName='+encodeURIComponent(Type);
            var ChartChuantouObj = new HomeStuffChuantou();
            ChartChuantouObj.HomeChartChuantou(that.stuffid,params_data);
        },
    }
    /** 获取完成率仪表盘的单个series, 根据数据获取单个仪表盘，便于循环获取仪表盘列表
     * @param {float} rate 完成率的值，百分比的数字部分，不含%
     * @param {Object} option 自定义的修改返回值中的配置项
     */
    this.getGaugeSeries = function (data,option) {
        if(typeof data !== 'object'){
            data = { id: '',name: '',rate: data};
        }

        return that.deepAssign({
            type: 'gauge',
            detail: {
                fontSize: 16,
                offsetCenter: [0, '65%'],
                valueAnimation: true,
                formatter: COMPLETIONRATE + ' {value} %',
                color: 'inherit'
            },
            data: [
                {
                    id: data.id,
                    name: data.label,
                    value: data.rate
                }
            ]
        },option);
    }
    /** 获取完成率仪表盘的单个graphic, 根据数据获取描述指定仪表盘的标签（完成值、目标值、未完成值），并根据设置数值穿透
     * @param {Object} data 包含（完成值、目标值、未完成值）的数据对象
     * @param {Object} option 自定义的修改返回值中的配置项
     */
    this.getGaugeGraphic = function (data,option) {
        var textArr = that.TargetGaugeTextInfo,
            graphicText = [],
            textLabel,//that.getGraphicText(target + '\n' + done + '\n' + undone),
            textData,
            index = 0,
            lineHeight = 20,
            top;
        ld.each(textArr,function (textKey, Info){
            top = (index - 1) * lineHeight;
            //文本
            textLabel = that.getGraphicText({text : Info.label},{
                left : -70,
                top : top,
                cursor : 'default',
                silent: true,
            });
            graphicText.push(textLabel);
            //文本对应的值
            //edit: xll 2023/01/30 BUG20240115-51 数值右对齐
            textData = that.getGraphicText({text : data[textKey], fill : Info.color,  textAlign: 'right'},{
                right : -80,
                top : top,
                cursor : 'pointer',
                info : textKey, //用于穿透判断点击的是哪一个值
                name : option.id,
            });
            graphicText.push(textData);
            index ++;
        });
        return Object.assign({
            type: 'group',
            rotation: 0,
            bounding: 'raw',
            left: '70%',
            bottom: "50%",
            z: 1,
            children: graphicText,
        },option);
    }
    /** 获取指定group类型graphic中的text类型子图表
     * @param {Object} textStyle 自定义的修改文本样式（ text 文本内容 , fill 文字颜色）
     * @param {Object} option 自定义的修改返回值中的配置项
     */
    this.getGraphicText = function (textStyle,option) {
        textStyle = Object.assign({
            fill: '#000',
            lineHeight:20,
            textVerticalAlign:'middle',
            text: '',
            font: '14px sans-serif',
            backgroundColor:'#FFF'
        },textStyle);
        return Object.assign({
            type: 'text',
            top: 'center',
            z: 1,
            style: textStyle,
            info: '',
        },option);
    }
    
    this.getBarStackSeries = function (option) {
        return that.deepAssign({
            name: '',
            type: 'bar',
            stack: 'BarStack',
            barMaxWidth:18,
            barGap: '30%',
            data: [],
        },option);
    }
    
    this.getBarSeries = function (option) {
        return that.deepAssign({
            name: '',
            type: 'bar',
            barMaxWidth:18,
            barGap: '30%',
            data: [],
        },option);
    }

    /**
     * 用于将源对象的所有可枚举属性复制到目标对象中（深层复制）,若源对象为 undefined则不做处理
     * @param target 目标对象
     * @param resource 源对象
     */
    this.deepAssign = function (target,resource) {
        if(typeof resource !== 'undefined')
            for (let key in resource) {
                if(resource[key] === null || typeof resource[key] !== 'object'){
                    target[key] = resource[key];
                }
                else {
                    if(!target[key])
                        target[key] = resource[key]
                    else
                        that.deepAssign(target[key],resource[key]);
                }
            }
        return target;
    }
}
//edit:xll 2023/09/02 BUG0071957 单独刷新组件：“最近六个月目标完成情况”和“目标完成率仪表盘”组件中，目标管理的保存，刷新的是整个界面（包括菜单栏）
newChart_class.refresh_stuff = function (stuffid,stuffinfo,boardid=-1) {
    var callbackfun = function(Option){
        loadStuff(Option.stuffid,Option.stufftype,'');
    }
    LoadStuffNavBar(stuffinfo,callbackfun,{stuffid:stuffid,stufftype:stuffinfo['stufftype']});
}
/**
 * 修改组件高度
 * @param stuffid 组件id
 * @param newheight 新的高度，若为0则标识调整内部内容高度
 */
newChart_class.changeStuffHeight = function (stuffid,newheight) {
    //stuffid = parseInt(stuffid);//SQL统计图 stuffid前面有前缀 不能直接变成int
    var popupobj = CrmPopup.getPopupObj('last');
    var stuffJqObj,stuffcont_jqobj;
    //编辑页
    if(popupobj && popupobj.divid){
        stuffJqObj = ld('#'+popupobj.divid).find(" #step2 #stuff_"+stuffid);
        stuffcont_jqobj = stuffJqObj.find(" #preview_stuffcont_"+stuffid);
    }
    //展示页
    else {
        stuffJqObj = ld(" #stuff_"+stuffid);
        stuffcont_jqobj = stuffJqObj.find(" #stuffcont_"+stuffid);
    }
    if(stuffJqObj.length === 0)
        return false;
    //newheight为0则调整内容高度
    if(newheight === 0)
        newheight = stuffJqObj.outerHeight();
    var headHeight = stuffJqObj.find('#headerrow_'+stuffid).outerHeight();
    stuffJqObj.css('height',newheight+'px');
    stuffJqObj.find(" #myChart_"+stuffid).css('height',newheight-headHeight+'px');
    if(stuffcont_jqobj.length === 0)
        return false;
    if(newChart_class.StuffHeightFun[stuffid] && typeof newChart_class.StuffHeightFun[stuffid] === 'function') {
        newChart_class.StuffHeightFun.titleHeight = headHeight;
        newChart_class.StuffHeightFun[stuffid](stuffcont_jqobj,newheight)
    }
    else {
        stuffcont_jqobj.css('height', newheight - headHeight + 'px');
    }
}

/** 特殊组件的高度的调整方法集合 键为stuffid 键值为对应的方法，参数包括 stuffid ，stuffcont_jqobj：组件内容框对应的Jquery对象, newheight：新的高度 */
newChart_class.StuffHeightFun = {
    titleHeight: 64,
    navbarHeight: 40,
    39 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight - this.navbarHeight;
        stuffcont_jqobj.css('height',newheight +'px');
    },
    /** 最近六个月完成情况 */
    40 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight - this.navbarHeight;
        stuffcont_jqobj.css('height',newheight +'px');
    },
    43 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight;
        stuffcont_jqobj.css('height',newheight +'px');
    },
    /** 数据龙虎榜 */
    100 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight - this.navbarHeight;
        stuffcont_jqobj.parent().css('height',newheight +'px');
    },
    /** 目标完成率仪表盘 */
    101 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight - this.navbarHeight;
        newheight = newheight +'px';
        stuffcont_jqobj.parent('.ld_stuffcontent').css('height',newheight);
        stuffcont_jqobj.css('height',newheight);
        //stuffcont_jqobj.siblings('.ld_stuffcont_label').css('height',newheight);
    },
    /** 销售阶段转化分析 */
    112 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight;
        stuffcont_jqobj.parent().css('height',newheight +'px');
    },
    /** 线索漏斗 */
    113 : function (stuffcont_jqobj,newheight) {
        newheight = newheight - this.titleHeight;
        var stuff_table_obj = stuffcont_jqobj.siblings('.ChartTable');
        var table_height = stuff_table_obj.outerHeight(true);
        if(newheight > 330 + table_height) {
            stuffcont_jqobj.parent().css('height',newheight + 'px');
            stuffcont_jqobj.css('height',(newheight - table_height) + 'px');
        }
        else {
            stuffcont_jqobj.parent().css('height',newheight + 'px');
            stuffcont_jqobj.css('height',newheight + 'px');
        }
    },
    /** 目标分析仪表盘列表 */
    114 : function (stuffcont_jqobj,newheight) {
        var stuffheight = stuffcont_jqobj[0].clientHeight + this.titleHeight + this.navbarHeight;
        stuffcont_jqobj.parents('#stuff_114').css('height',stuffheight+'px');
    },
}
/**
 * 获取指定年份内所有的天数
 * @param year
 * @return {*[]}
 */
newChart_class.getVirtulData = function (year) {
    year = year || '2017';
    let date = +echarts.number.parseDate(year + '-01-01');  //第一天毫秒时刻
    let end = +echarts.number.parseDate(+year + 1 + '-01-01');  //最后一天毫秒时刻
    let dayTime = 3600 * 24 * 1000; //一天的毫秒数
    let data = [];
    for (let time = date; time < end; time += dayTime) {
        // let items = [];
        // let eventCount = Math.round(Math.random() * pathes.length);
        // for (let i = 0; i < eventCount; i++) {
        //     items.push(Math.round(Math.random() * (pathes.length - 1)));
        // }
        data.push([echarts.format.formatTime('yyyy-MM-dd', time)]);
    }
    return data;
}

/**
 * 获取组件的newChart对象
 * @param el 组件的内容DOM对象
 * @return {Object} newChart_class 的组件实例
 */
newChart_class.getNewChartObj = function (el) {
    return el.newChartObj
}
//设置组件的事件
newChart_class.setEvent=function(stuffid){
    var popupobj = CrmPopup.getPopupObj('last');
    var stuffJqObj,stuffcont_jqobj;
    //编辑页
    if(popupobj && popupobj.divid){
        stuffJqObj = ld('#'+popupobj.divid).find(" #step2 #stuff_"+stuffid);
        stuffcont_jqobj = stuffJqObj.find(" #preview_stuffcont_"+stuffid);
    }
    //展示页
    else {
        stuffJqObj = ld(" #stuff_"+stuffid);
        stuffcont_jqobj = stuffJqObj.find(" #stuffcont_"+stuffid);
    }
    if(stuffJqObj.length === 0)
        return false;
    if(stuffcont_jqobj.length === 0)
        return false;
    if(newChart_class.setEventFunArr['scroll_'+stuffid] && typeof newChart_class.setEventFunArr['scroll_'+stuffid] === 'function') {
        newChart_class.setEventFunArr['scroll_'+stuffid](stuffcont_jqobj,stuffid)
    }
    if(newChart_class.setEventFunArr['resize_'+stuffid] && typeof newChart_class.setEventFunArr['resize_'+stuffid] === 'function') {
        newChart_class.setEventFunArr['resize_'+stuffid](stuffcont_jqobj,stuffid)
    }
}
newChart_class.setEventFunArr = {
    "scroll_118":function(stuffcont_jqobj,stuffid){
        //下拉加载//滚动的事件
        var isLoading = 'no';
        ld(stuffcont_jqobj).parent().off('scroll').on('scroll',function () {
            var scrollBottom = ld(this).height() - ld(this).scrollTop();
            var pagenumobj = ld(this).find('#stuff_' + stuffid + '_pagenum');
            var havenextpageobj = ld(this).find('#stuff_' + stuffid + '_havenextpage');
            var pagenum = pagenumobj.val();
            var havenextpage = havenextpageobj.val();
            if (scrollBottom <= 20 && havenextpage == 'yes' && isLoading == 'no') {
                isLoading = 'yes';
                //请求新一页的数据
                var navbarobj = ld_NavBar.getCurNavBar(ld('#homestuffdiv #stuff_118 #sales_target_tab').get(0));
                var curdata_type = navbarobj.NavBarItem.name;

                var params = getHomeAllParams();
                params += '&pagenum=' + pagenum;
                params += '&data_type=' + curdata_type;
                params += '&loadtype=scroll';
                var url = 'index.php?module=Home&action=HomeAjax&file=HomeBlock&homestuffid=' + stuffid + '&blockstufftype=customsheet';
                ldAjaxHtml(url, params, function (data) {
                    data = JSON.parse(data);
                    ld('#rptContentLoading').hide();
                    if(data.result.havenextpage=='yes'){
                        pagenum = parseInt(pagenum) + 1;
                        pagenumobj.val(pagenum);
                    }
                    havenextpageobj.val(data.result.havenextpage);
                    stuffcont_jqobj.find('table tbody').append(data.result.content);
                    isLoading = 'no';
                });
            }
        });
    },
}