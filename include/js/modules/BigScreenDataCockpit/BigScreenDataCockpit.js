
function BigScreenDataCockpit() {
    var that = this,
        pageContentObj = ld('#pagecontent1');
    BigScreenDataCockpitObj = that;
    this.module = 'BigScreenDataCockpit';
    this.mapName = 'china';

    this.init = function () {
        that.CockpitData = {};
        that.getAjaxUrl();
    }

    this.showDataCockpit = function () {
        that.init();

        pageContentObj.html(that.getCockpitHtml());

        that.getCockpitData();

    }

    this.getCockpitHtml = function () {
        var CockpitHtml = '';
        CockpitHtml += '<div class="fullscreenDiv">' +
            '<div id="dark" class="ld-button ld-button-primary" >深色</div>' +
            '<div id="light" class="ld-button" style="margin-right: 25px;">浅色</div>' +
            '<div id="fullscreenBtn" class="ld-fonticon ld-fonticon-gobig" style="margin-top: 5px;" data-tip="全屏" data-direction="top" data-type="position" ></div>' +
            '</div>' ;
        CockpitHtml += '<div id="dataCockpitIndex" class="dataCockpitIndex">' +
            '<div id="dataCockpitTop" class="dataCockpitTop">' +
            '<div id="salesAreaList" class="salesAreaList"></div>' +
            '</div>' +
            '<div class="dataCockpitBottom">' +
            '<div id="salesMap" class="salesMap">' +
            '<div id="salesMapEcharts" class="salesMapEcharts"></div>' +
            '<div id="salesMapPop" class="salesMapPop"></div>' +
            '</div>' +
            '<div id="salesProvinceList" class="salesProvinceList"></div>' +
            '<div class="salesDetailList">' +
            '<div id="salesAreaDetail" class="salesAreaDetail"></div>' +
            '<div id="salesProvinceDetailLegend" class="salesProvinceDetailLegend"></div>' +
            '<div id="salesProvinceDetail" class="salesProvinceDetail customtable-content"></div>' +
            '</div>' +
            '</div>'+
            '</div>';
        return CockpitHtml;
    }

    this.getCockpitData = function () {
        ldAjax(that.AjaxUrl,that.getUrlParam({
            mode: 'getCockpitData',
        }),function (data) {
            that.CockpitData = data.result;
            that.themeOption = that.theme[that.CockpitData.themeName];
            that.changeCssVar();
            ld.get('chinamap/json/china.json', function (mapJson) {
                echarts.registerMap(that.mapName, mapJson);
                that.showAllChart();
                that.setEvent();
            });
            DelProgressObjs();
        });
    }

    this.showAllChart = function () {
        that.showSalesArea();
        that.chooseArea('area_all');
    }

    this.showSalesArea = function () {
        if(!that.salesAreaListObj)
            that.salesAreaListObj = pageContentObj.find('#salesAreaList');
        ld.each(that.CockpitData.salesArea,function (index,info) {
            that.salesAreaListObj.append(that.getAreaDiv(info));
        });
        that.salesAreaListObj.append('<div style="min-width: 10px"></div>');
    }

    this.echartOption = {
        salesMap: {
            tooltip: {
                trigger: 'item',
                backgroundColor:"#ffffff",
                textStyle:{color:"#000000"},
                formatter: function (result){
                    var str = '',
                        dataInfo;
                    if(result.data !== undefined){
                        dataInfo = that.CockpitData.salesProvince[result.data.areaKey][result.data.provinceKey];
                        str = `<span style="font-size: 16px">${dataInfo.label}</span></br>
                                <span style="font-size: 14px">客户数：${dataInfo.accountArr.length}</span></br>
                                <span style="font-size: 14px">装机总量：${dataInfo.salesNum}</span>`;
                    }
                    return str;
                }
            },
            title:{
                text:arrJsPopLabel['ANTIONALDATAOVERVIEW'],
                //subtext:'',
                x:'center',
                y:'top',
                textAlign:'left',
                textStyle: {
                    color: "",
                },
            },
            series: [{
                type: 'map',
                map: that.mapName,
                roam:true,
                scaleLimit: { min: 1.2, max: 3.9 },    //缩放
                mapLocation:{
                    x : 'center',
                    y : 'center'
                },
                itemStyle:{
                    normal: {
                        borderWidth: .5,//区域边框宽度
                        borderColor: '#009fe8',//区域边框颜色
                        areaColor: "#ffefd5",//区域颜色
                    },
                    emphasis: {
                        borderWidth: .5,
                        borderColor: '#4b0082',
                        areaColor: "#F09451",
                    }
                },
                label: {
                    normal: {
                        show: false,//显示省份标签
                        textStyle:{color:"#000000"}//省份标签字体颜色
                    },
                    emphasis: {//对应的鼠标悬浮效果
                        show: false,
                        textStyle:{color:"#800080"}
                    }
                },
                data: [],
            }]
        },
        salesAreaDetail: {
            grid: { containLabel: true},
            tooltip: {
                trigger: 'item'
            },
            series: [
                {
                    name: '',
                    type: 'pie',
                    center: ['50%','50%'],
                    radius: ['40%', '70%'],
                    avoidLabelOverlap: true,
                    label: {
                        show: true,
                        fontSize: 15,
                        position: 'outside',
                        formatter: '{b}: {d}%',
                    },
                    emphasis: {
                        label: {
                            show: true,
                            fontSize: 17,
                            fontWeight: 'bold'
                        }
                    },
                    labelLine: {
                        show: true
                    },
                    data: [],
                }
            ]
        },
    }

    this.showSalesMap = function (areaInfo) {
        var option,mapData = [],provinceArr = areaInfo.provinceArr,
            areaKey = 'area_'+areaInfo.pickId;
        // if(areaInfo.pickId === 'all')
        //     provinceArr = Object.keys(that.CockpitData.salesMap['area_'+areaInfo.pickId]);
        if(!that.salesProvinceObj)
            that.salesProvinceObj = pageContentObj.find('#salesProvinceList');
        that.salesProvinceObj.html('');
        ld.each(provinceArr,function (index,provinceKey) {
            var provinceData = that.CockpitData.salesMap[areaKey][provinceKey];
            //edit: xll 2024/04/03 国能龙源，首页驾驶舱，一个省份属于多个区域的问题，显示颜色按照区域颜色显示
            if(areaKey !== 'area_all')
                provinceData.itemStyle.areaColor = areaInfo.color;
            mapData.push(provinceData);
            that.showSalesProvince(provinceData.name,that.CockpitData.salesProvince[areaKey][provinceKey]);
        });
        that.showSalesProvinceDetail(that.CockpitData.salesProvinceDetail[areaKey][provinceArr[0]]);
        if(!that.chinaChart)
            that.chinaChart = echarts.init(pageContentObj.find('#salesMapEcharts').get(0));
        option = that.echartOption.salesMap;
        option.series[0].map = that.mapName;
        option.series[0].data = mapData;
        option.series[0].itemStyle.normal.areaColor = that.themeOption.areaColor;
        option.series[0].itemStyle.normal.borderColor = that.themeOption.borderColor;
        option.title.textStyle.color = that.themeOption.fontColor;
        that.chinaChart.setOption(option);
        that.ChartResize(that.chinaChart);
        if(!that.salesMapPopObj)
            that.salesMapPopObj = pageContentObj.find('#salesMapPop');
        that.salesMapPopObj.html(that.getAreaDiv(areaInfo));
    }

    this.showSalesProvince = function (provinceName,provinceInfo) {
        var provinceOption,provinceChart,echartDivObj,
            provinceKey = 'province_' + provinceInfo.pickId;
        that.provinceChartList = [];
        that.salesProvinceObj.append(`<div id="${provinceKey}" class="provinceDiv"></div>`);
        echartDivObj = that.salesProvinceObj.find('#'+provinceKey);
        ld.get('chinamap/json/'+provinceName+'/'+provinceName+'.json', function(CityMap) {
            provinceChart = echarts.init(echartDivObj.get(0));
            that.provinceChartList.push(provinceChart);
            echarts.registerMap(provinceName, CityMap);
            provinceOption = {
                tooltip: {
                    show: false,
                },
                title:{
                    text: provinceName,
                    subtext:`客户数：${provinceInfo.accountArr.length}\n装机总数：${provinceInfo.salesNum}`,
                    subtextStyle : {
                        fontSize: 14,
                        fontWeight: 'bold',
                        lineHeight: 20
                    },
                    x:'center',
                    y:'top',
                    textAlign:'left',
                    textStyle: {},
                },
                series: [{
                    name: provinceName,
                    type: 'map',
                    map: provinceName,
                    roam: 'move',
                    zoom: 1,
                    layoutCenter: ['50%', '50%'],
                    layoutSize: 160,
                    emphasis: {
                        disabled: true,
                        label: {
                            show: false,
                        },
                        itemStyle: {
                            borderWidth: .5,
                            borderColor: that.themeOption.areaColor,
                            areaColor: that.themeOption.areaColor,
                        },
                    },
                    selectedMode: false,
                    itemStyle: {
                        borderWidth: .5,//区域边框宽度
                        borderColor: that.themeOption.areaColor,//'#ffefd5',//区域边框颜色
                        areaColor: that.themeOption.areaColor,//"#ffefd5",//区域颜色
                    },
                    label: {
                        show: false,
                    },
                    data : [],
                    silent: false,
                }],
                animation: true,
            };
            that.provinceInterval(provinceChart,provinceOption);
            that.ChartResize(provinceChart);
            //provinceChart.setOption(provinceOption);
        })
        echartDivObj.bind('click',function () {
            var areaKey = provinceInfo.areaKey;
            that.showSalesProvinceDetail(that.CockpitData.salesProvinceDetail[areaKey][provinceKey]);
        })
    }

    this.provinceInterval = function (provinceChart,provinceOption) {
        var zoom = 0,interval,
            chartObj = provinceChart,
            option = provinceOption;
        interval = setInterval(function() {
            zoom += 0.5;
            option.series[0].zoom = zoom;
            option.title.textStyle.color = that.themeOption.fontColor;
            option.title.subtextStyle.color = that.themeOption.subFontColor;
            chartObj.setOption(option);
            if(zoom === 1){
                clearInterval(interval)
            }
        }, 200);
    }

    this.showSalesAreaDetail = function (areaKey) {
        var option = that.echartOption.salesAreaDetail;
        option.series[0].data = [...that.transToIterable(that.CockpitData.salesAreaDetail[areaKey])];
        if(!that.areaDetailChart)
            that.areaDetailChart = echarts.init(pageContentObj.find('#salesAreaDetail').get(0));
        option.series[0].label.color = that.themeOption.fontColor;
        that.areaDetailChart.setOption(option);
        that.ChartResize(that.areaDetailChart);
    }

    this.thList = [
        { colName: "accountName", label : "客户名称"},
        { colName: "salesNum", label : "装机总量<br>(MW)"},
        { colName: "businessType", label : "业务分布"},
        { colName: "amount", label : "历史签约额<br>(万元)"},
    ];

    this.showSalesProvinceDetail = function (provinceDetail) {
        var table = '',legendList = '',
            trList = [...that.transToIterable(provinceDetail)];//style="color: #3B4859"
        table += `<table border="0" cellSpacing="1" cellPadding="0" id="thResizable" class="customtable-list" width="100%" >
                        ${that.getChartTableHead()}
                        ${that.getChartTableBody(trList)}
                    </table>`;
        if(!that.provinceDetailObj)
            that.provinceDetailObj = pageContentObj.find('#salesProvinceDetail');
        that.provinceDetailObj.html(table);
        ld.each(that.CockpitData.businessColorArr,function (businessKey,info) {
            legendList += `${that.getFlagSvg(info.color,20)}<span id="${businessKey}" style="margin-right: 5px">${info.label}</span>`;
        });
        if(!that.provinceDetailLegendObj)
            that.provinceDetailLegendObj = pageContentObj.find('#salesProvinceDetailLegend');
        that.provinceDetailLegendObj.html(legendList);
    }

    this.ChartResize = function (echartsObj) {
        var observer = new ResizeObserver(function (entries, observer) {
            echartsObj.resize();
        });
        observer.observe(echartsObj.getDom());
    }

    this.getAreaDiv = function (areaInfo) {
        return `<div id="area_${areaInfo.pickId}" class="areaDiv" style="background-color: ${areaInfo.color}">
                    <div class="areaName">${areaInfo.label}</div>
                    <div class="areaAccountNum">客户数 : ${areaInfo.accountArr.length}</div> 
                    <div class="areaSalesNum">装机总量 : ${areaInfo.salesNum}</div>
                </div>`
    }

    this.getChartTableHead = function () {
        var ChartTable = '<thead style="">' +
            '<tr id="reportDetailHeader" style="height:40px;position:sticky;top:0;">';
        ld.each(that.thList,function (index,thInfo) {
            ChartTable += `<th thindex="${index}" align="center" style="padding-left: 15px;text-align: center;" >${thInfo.label}</th>`;
        })
        ChartTable += '</tr>' +
            '</thead>';
        return ChartTable;
    }

    this.getChartTableBody = function (trList) {
        var totalTr = { accountName : "合计", salesNum: 0, businessType: new Set(), amount: 0},
            ChartTable = '<tbody style="background-color: #fff;" id="reportDetailBody">';
        ld.each(trList,function (trIndex,trInfo) {
            ChartTable += that.getChartTableTr(trIndex,trInfo,totalTr);
        });
        //合计行
        ChartTable += `<tr class="totalRow" rowindex="${trList.length}" style="position: sticky;bottom: 0;">`;
        ChartTable += that.getChartTableTdList(totalTr,{ accountName : "合计", salesNum: 0, businessType: new Set(), amount: 0});
        ChartTable += '</tr>';
        ChartTable += '</tbody>';
        return ChartTable;
    }

    this.getChartTableTr = function (trIndex,trInfo,totalTr) {
        var Tr = '';
        Tr += `<tr class="${trIndex % 2 === 0 ? 'lvtColData' : 'lvtColDataBj'}" rowindex="${trIndex}" onmouseover="this.classList.add('lvtColDataHover')" onmouseout="this.classList.remove('lvtColDataHover')">`;
        Tr += that.getChartTableTdList(trInfo,totalTr);
        Tr += '</tr>';
        return Tr;
    }

    this.getChartTableTdList = function (trInfo,totalTr) {
        var tdList = ''
        ld.each(that.thList,function (index,tdInfo) {
            tdList += `<td tdindex="${index}" style="padding:10px 10px 10px 3px;white-space: unset;" align="right">${that.getChartTableTdValue[tdInfo.colName](trInfo[tdInfo.colName],totalTr)}</td>`;
        });
        return tdList;
    }

    this.getChartTableTdValue = {
        accountName : function (tdValue,totalTr) {
            return tdValue;
        },
        salesNum : function (tdValue,totalTr) {
            totalTr.salesNum += tdValue;
            return tdValue;
        },
        businessType : function (tdValue,totalTr) {
            var newValue = '';
            ld.each(tdValue,function (index,color) {
                totalTr.businessType.add(color);
                newValue += that.getFlagSvg(color,20);

            })
            return newValue;
        },
        amount : function (tdValue,totalTr) {
            totalTr.amount += tdValue;
            return tdValue;
        },
    }

    this.getFlagSvg = function (color,size) {
        return `<svg  viewBox="0 0 1024 1024" version="1.1" width="${size}" height="${size}">
                    <path d="M299.1 79.8v863.7" fill="#73D8A5"></path>
                    <path d="M299.1 959.5c-8.8 0-16-7.2-16-16V79.9c0-8.8 7.2-16 16-16s16 7.2 16 16v863.6c0 8.8-7.2 16-16 16z" fill="#4C4848"></path>
                    <path d="M726 326.3L299.1 572.8v-493z" fill="${color}" data-spm-anchor-id="a313x.search_index.0.i2.70e83a813h3Q1t" ></path>
                    <path d="M299.1 588.8c-2.8 0-5.5-0.7-8-2.1-5-2.9-8-8.1-8-13.9v-493c0-5.7 3-11 8-13.9 4.9-2.8 11.1-2.8 16 0L734 312.5c5 2.9 8 8.1 8 13.9s-3 11-8 13.9L307.1 586.7c-2.5 1.4-5.3 2.1-8 2.1z m16-481.2v437.6l379-218.8-379-218.8z" fill="#4C4848" ></path>
                </svg>`;
    }

    this.getAjaxUrl = function () {
        var module = that.module;
        that.AjaxUrl =  'index.php?module='+module+'&action='+module+'Ajax&file=ListView';
        that.AjaxUrl += that.getUrlParam({

        });
    }

    this.getUrlParam = function (parmasArr) {
        var params = '';
        ld.each(parmasArr,function (key,val) {
            params += '&'+key+'='+encodeURIComponent(val);
        });
        return params;
    }

    this.chooseArea = function (areaKey) {
        that.areaKey = areaKey;
        var areaInfo = that.CockpitData.salesArea[areaKey];
        that.showSalesMap(areaInfo);
        that.showSalesAreaDetail(areaKey);
    }

    this.setEvent = function () {
        that.salesAreaListObj.find('.areaDiv').bind('click',function () {
            that.chooseArea(ld(this).attr('id'))
        });

        var fullscreenBtnObj = pageContentObj.find('#fullscreenBtn');
        fullscreenBtnObj.bind('click',function () {
            launchFullscreen(pageContentObj.find('#dataCockpitIndex').get(0));
        });
        var dataCockpitTopObj = pageContentObj.find('#dataCockpitTop')
        dataCockpitTopObj.bind('wheel',function(){
            event.preventDefault();
            dataCockpitTopObj.get(0).scrollLeft -= event.wheelDeltaY;
        });
        tooltip('#fullscreenBtn',{transition: true, time: 200});

        var darkObj = pageContentObj.find('#dark');
        darkObj.bind('click',function(){
            that.setTheme('dark');
        });


        var lightObj = pageContentObj.find('#light');
        lightObj.bind('click',function(){
            that.setTheme('light');
        });


    }

    this.theme = {
        dark: {
            bgColor: "rgb(20,49,107)",
            fontColor: "#fff",
            subFontColor: "#eee",
            areaColor: "rgb(48,99,209)",
            borderColor: "#d6d6d6",
            thColor: "rgb(41,42,94)",
            oddTdColor: "rgb(58,69,105)",
            evenTdColor: "rgb(15,38,84)",
        },
        light: {
            bgColor: "#fff",
            fontColor: "#464646",
            subFontColor: "#6E7079",
            areaColor: "#ffefd5",
            borderColor: "#009fe8",
            thColor: "#f0f4fc",
            oddTdColor: "#ffffff",
            evenTdColor: "#F7F9FB",
        }
    }

    this.setTheme = function(themeName){
        if(themeName === undefined || themeName === '')
            themeName = 'dark';
        that.themeOption = that.theme[themeName];
        that.changeCssVar();
        that.chooseArea(that.areaKey);
        ldAjax(that.AjaxUrl,that.getUrlParam({
            mode: 'setDataCockpitTheme',
            themeName: themeName,
        }),function (data) {
            DelProgressObjs();
        });
    }

    this.changeCssVar = function(){
        var styleObj = pageContentObj.get(0).style;
        ld.each(that.themeOption,function(key,value){
            styleObj.setProperty('--'+key,value);
        })
    }

    /** 为对象增加Symbol.iterator属性，将对象改为可迭代对象 */
    this.transToIterable = function (obj) {
        obj[Symbol.iterator] = function () {
            let i = 0, keyArr = Object.keys(obj), that = this;
            return {
                next: function() {
                    if (i < keyArr.length) {
                        return {
                            value: that[keyArr[i++]],
                            done: false
                        };
                    } else {
                        return {
                            value: undefined,
                            done: true
                        };
                    }
                }
            };
        }
        return obj;
    }
}

//css路径
ld('<link>', {
    rel: 'stylesheet',
    type: 'text/css',
    href: 'themes/softed/BigScreenDataCockpit.css?v=0.1',
}).appendTo('head');
ld('<link>', {
    rel: 'stylesheet',
    type: 'text/css',
    href: 'themes/softed/CustomTable.css',
}).appendTo('head');

function launchFullscreen(element) {
    //此方法不可以在異步任務中執行，否則火狐無法全屏
    if (element.requestFullscreen) {
        element.requestFullscreen();
    } else if (element.mozRequestFullScreen) {
        element.mozRequestFullScreen();
    } else if (element.msRequestFullscreen) {
        element.msRequestFullscreen();
    } else if (element.oRequestFullscreen) {
        element.oRequestFullscreen();
    } else if (element.webkitRequestFullscreen) {
        element.webkitRequestFullScreen();
    } else {
        var docHtml = document.documentElement;
        var docBody = document.body;
        var videobox = document.getElementById('videobox');
        var cssText = 'width:100%;height:100%;overflow:hidden;';
        docHtml.style.cssText = cssText;
        docBody.style.cssText = cssText;
        videobox.style.cssText = cssText + ';' + 'margin:0px;padding:0px;';
        document.IsFullScreen = true;
    }
}


