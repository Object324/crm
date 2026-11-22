(function (root, factory) {
    if (typeof define === 'function' && define.amd) {
        // AMD. Register as an anonymous module.
        define(['exports', 'echarts'], factory);
    } else if (typeof exports === 'object' && typeof exports.nodeName !== 'string') {
        // CommonJS
        factory(exports, require('echarts'));
    } else {
        // Browser globals
        factory({}, root.echarts);
    }
}(this, function (exports, echarts) {
    var log = function (msg) {
        if (typeof console !== 'undefined') {
            console && console.error && console.error(msg);
        }
    };
    if (!echarts) {
        log('ECharts is not Loaded');
        return;
    }
    //这个对应的深色主题是dark.js
    echarts.registerTheme('light', {
        "color":[
            "#3b7cff",
            "#34e1ec",
            "#3bd052",
            "#f5cd39",
            "#f37538",
            "#e4408b",
            "#b642db",
            "#825df8"
        ],
        "backgroundColor": "rgba(255,255,255,255)",
        "textStyle": {},
        "title": {
            "textStyle": {
                "color": "#333333"
            },
            "subtextStyle": {
                "color": "#999999"
            }
        },
        "line": {
            "itemStyle": {
                "borderWidth": "2"
            },
            "lineStyle": {
                "width": "2"
            },
            "symbolSize": "6",
            "symbol": "emptyCircle",
            "smooth": false
        },
        // "radar": {
        //     "itemStyle": {
        //         "borderWidth": "2"
        //     },
        //     "lineStyle": {
        //         "width": "2"
        //     },
        //     "symbolSize": "6",
        //     "symbol": "emptyCircle",
        //     "smooth": false
        // },
        "bar": {
            "itemStyle": {
                "barBorderWidth": "2",
                "barBorderColor": "#ffffff"
            },
            "label":{
                "color":"#333",
                "textBorderColor":'#333'
            },
        },
        "pie": {
            "itemStyle": {
                "borderWidth": "2",
                "borderColor": "#ffffff"
            },
            "label":{
                "color":"#333",
                "textBorderColor":'#333',
            },
        },
        // "scatter": {
        //     "itemStyle": {
        //         "borderWidth": "2",
        //         "borderColor": "#ffffff"
        //     }
        // },
        // "boxplot": {
        //     "itemStyle": {
        //         "borderWidth": "2",
        //         "borderColor": "#ffffff"
        //     }
        // },
        // "parallel": {
        //     "itemStyle": {
        //         "borderWidth": "2",
        //         "borderColor": "#ffffff"
        //     }
        // },
        // "sankey": {
        //     "itemStyle": {
        //         "borderWidth": "2",
        //         "borderColor": "#ffffff"
        //     }
        // },
        "funnel": {
            "itemStyle": {
                "borderWidth": "2",
                "borderColor": "#ffffff"
            },
            "label":{
                "color":"#333",
                "textBorderColor":'#333'
            }
        },
        "gauge": {
            "startAngle": 210,
            "endAngle": -30,
            "title":{
                "show": true,
                "offsetCenter" : ['0%','-120%'],
            },
            "itemStyle": {
                "borderWidth": "2",
                "borderColor": "#ffffff"
            },
            "axisLine":{
                "lineStyle":{
                    "width": 15,
                    "color": [
                        [0.4, '#E52F4A'],
                        [0.8, '#f37538'],
                        [1, '#3b7cff']
                    ]
                }
            },
            "pointer": {
                "itemStyle": {
                    "color": 'auto'
                }
            },
            "axisTick": {
                "distance": -15,
                "length": 8,
                "lineStyle": {
                    "color": '#fff',
                    "width": 2
                }
            },
            "splitLine":{
                "distance": -15,
                "length": 15,
                "lineStyle": {
                    "color": '#fff',
                    "width": 4
                }
            },
            "axisLabel": {
                "color": 'inherit',
                "distance": 20,
                "fontSize": 13,
            },
        },
        // "candlestick": {
        //     "itemStyle": {
        //         "color": "#f37538",
        //         "color0": "#ffffff",
        //         "borderColor": "#f37538",
        //         "borderColor0": "#3b7cff",
        //         "borderWidth": "2"
        //     }
        // },
        // "graph": {
        //     "itemStyle": {
        //         "borderWidth": "2",
        //         "borderColor": "#ffffff"
        //     },
        //     "lineStyle": {
        //         "width": 1,
        //         "color": "#aaa"
        //     },
        //     "symbolSize": "6",
        //     "symbol": "emptyCircle",
        //     "smooth": false,
        //     "color": [
        //         "#3b7cff",
        //         "#5e99ff",
        //         "#3bd052",
        //         "#94e449",
        //         "#f7da5b",
        //         "#f5cd39",
        //         "#f37538"
        //     ],
        //     "label": {
        //         "color": "#ffffff"
        //     }
        // },
        // "map": {
        //     "itemStyle": {
        //         "areaColor": "#f3f3f3",
        //         "borderColor": "#516b91",
        //         "borderWidth": 0.5
        //     },
        //     "label": {
        //         "color": "#000"
        //     },
        //     "emphasis": {
        //         "itemStyle": {
        //             "areaColor": "#a5e7f0",
        //             "borderColor": "#516b91",
        //             "borderWidth": 1
        //         },
        //         "label": {
        //             "color": "#516b91"
        //         }
        //     }
        // },
        // "geo": {
        //     "itemStyle": {
        //         "areaColor": "#f3f3f3",
        //         "borderColor": "#516b91",
        //         "borderWidth": 0.5
        //     },
        //     "label": {
        //         "color": "#000"
        //     },
        //     "emphasis": {
        //         "itemStyle": {
        //             "areaColor": "#a5e7f0",
        //             "borderColor": "#516b91",
        //             "borderWidth": 1
        //         },
        //         "label": {
        //             "color": "#516b91"
        //         }
        //     }
        // },
        // "categoryAxis": {
        //     "axisLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": "#dcdee0"
        //         }
        //     },
        //     "axisTick": {
        //         "show": false,
        //         "lineStyle": {
        //             "color": "#333"
        //         }
        //     },
        //     "axisLabel": {
        //         "show": true,
        //         "color": "#666666"
        //     },
        //     "splitLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": [
        //                 "#ebedf0"
        //             ]
        //         }
        //     },
        //     "splitArea": {
        //         "show": false,
        //         "areaStyle": {
        //             "color": [
        //                 "rgba(250,250,250,0.05)",
        //                 "rgba(200,200,200,0.02)"
        //             ]
        //         }
        //     }
        // },
        // "valueAxis": {
        //     "axisLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": "#dcdee0"
        //         }
        //     },
        //     "axisTick": {
        //         "show": false,
        //         "lineStyle": {
        //             "color": "#333"
        //         }
        //     },
        //     "axisLabel": {
        //         "show": true,
        //         "color": "#666666"
        //     },
        //     "splitLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": [
        //                 "#ebedf0"
        //             ]
        //         }
        //     },
        //     "splitArea": {
        //         "show": false,
        //         "areaStyle": {
        //             "color": [
        //                 "rgba(250,250,250,0.05)",
        //                 "rgba(200,200,200,0.02)"
        //             ]
        //         }
        //     }
        // },
        // "logAxis": {
        //     "axisLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": "#dcdee0"
        //         }
        //     },
        //     "axisTick": {
        //         "show": false,
        //         "lineStyle": {
        //             "color": "#333"
        //         }
        //     },
        //     "axisLabel": {
        //         "show": true,
        //         "color": "#666666"
        //     },
        //     "splitLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": [
        //                 "#ebedf0"
        //             ]
        //         }
        //     },
        //     "splitArea": {
        //         "show": false,
        //         "areaStyle": {
        //             "color": [
        //                 "rgba(250,250,250,0.05)",
        //                 "rgba(200,200,200,0.02)"
        //             ]
        //         }
        //     }
        // },
        // "timeAxis": {
        //     "axisLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": "#dcdee0"
        //         }
        //     },
        //     "axisTick": {
        //         "show": false,
        //         "lineStyle": {
        //             "color": "#333"
        //         }
        //     },
        //     "axisLabel": {
        //         "show": true,
        //         "color": "#666666"
        //     },
        //     "splitLine": {
        //         "show": true,
        //         "lineStyle": {
        //             "color": [
        //                 "#ebedf0"
        //             ]
        //         }
        //     },
        //     "splitArea": {
        //         "show": false,
        //         "areaStyle": {
        //             "color": [
        //                 "rgba(250,250,250,0.05)",
        //                 "rgba(200,200,200,0.02)"
        //             ]
        //         }
        //     }
        // },
        // "toolbox": {
        //     "iconStyle": {
        //         "borderColor": "#999999"
        //     },
        //     "emphasis": {
        //         "iconStyle": {
        //             "borderColor": "#3b7cff"
        //         }
        //     }
        // },
        "legend": {
            "textStyle": {
                "color": "#999999",
                "fontSize":12
            },
            "itemWidth":12,
            "itemHeight":12,
        },
        // "tooltip": {
        //     "axisPointer": {
        //         "lineStyle": {
        //             "color": "#cccccc",
        //             "width": 1
        //         },
        //         "crossStyle": {
        //             "color": "#cccccc",
        //             "width": 1
        //         }
        //     }
        // },
        // "timeline": {
        //     "lineStyle": {
        //         "color": "#c8c9cc",
        //         "width": 1
        //     },
        //     "itemStyle": {
        //         "color": "#ebedf0",
        //         "borderWidth": "0.5"
        //     },
        //     "controlStyle": {
        //         "color": "#3b7cff",
        //         "borderColor": "#3b7cff",
        //         "borderWidth": 0.5
        //     },
        //     "checkpointStyle": {
        //         "color": "#3b7cff",
        //         "borderColor": "#ffffff"
        //     },
        //     "label": {
        //         "color": "#666666"
        //     },
        //     "emphasis": {
        //         "itemStyle": {
        //             "color": "#c8c9cc"
        //         },
        //         "controlStyle": {
        //             "color": "#3b7cff",
        //             "borderColor": "#3b7cff",
        //             "borderWidth": 0.5
        //         },
        //         "label": {
        //             "color": "#666666"
        //         }
        //     }
        // },
        // "visualMap": {
        //     "color": [
        //         "#133aa6",
        //         "#3b7cff",
        //         "#a3cbff"
        //     ]
        // },
        // "dataZoom": {
        //     "backgroundColor": "rgba(0,0,0,0)",
        //     "dataBackgroundColor": "rgba(255,255,255,0.3)",
        //     "fillerColor": "rgba(167,183,204,0.4)",
        //     "handleColor": "#a7b7cc",
        //     "handleSize": "100%",
        //     "textStyle": {
        //         "color": "#333"
        //     }
        // },
        // "markPoint": {
        //     "label": {
        //         "color": "#ffffff"
        //     },
        //     "emphasis": {
        //         "label": {
        //             "color": "#ffffff"
        //         }
        //     }
        // }
    });
}));
