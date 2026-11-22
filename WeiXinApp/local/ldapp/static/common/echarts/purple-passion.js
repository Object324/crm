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
    echarts.registerTheme('purple-passion', {
        "color": [
            "#619bff",
            "#a383f9",
            "#ace86c",
            "#4fbf60",
            "#65ebf0",
            "#616bff",
            "#795dd7",
            "#89e190",
            "#69d9a9",
            "#69d976"
        ],
        "backgroundColor": "rgba(25,25,25,1)",
        "textStyle": {},
        "title": {
            "textStyle": {
                "color": "#ffffff"
            },
            "subtextStyle": {
                "color": "#a3a3a3"
            }
        },
        "line": {
            "itemStyle": {
                "borderWidth": 1
            },
            "lineStyle": {
                "width": 2
            },
            "symbolSize": "4",
            "symbol": "circle",
            "smooth": false
        },
        "radar": {
            "itemStyle": {
                "borderWidth": 1
            },
            "lineStyle": {
                "width": 2
            },
            "symbolSize": "4",
            "symbol": "circle",
            "smooth": false
        },
        "bar": {
            "itemStyle": {
                "barBorderWidth": "0",
                "barBorderColor": "#ffffff"
            }
        },
        "pie": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "scatter": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "boxplot": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "parallel": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "sankey": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "funnel": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "gauge": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            }
        },
        "candlestick": {
            "itemStyle": {
                "color": "#f5955d",
                "color0": "#619bff",
                "borderColor": "#f5955d",
                "borderColor0": "#619bff",
                "borderWidth": 1
            }
        },
        "graph": {
            "itemStyle": {
                "borderWidth": "0",
                "borderColor": "#ffffff"
            },
            "lineStyle": {
                "width": 1,
                "color": "#aaaaaa"
            },
            "symbolSize": "4",
            "symbol": "circle",
            "smooth": false,
            "color": [
                "#619bff",
                "#a383f9",
                "#ace86c",
                "#69d976",
                "#65ebf0",
                "#616bff",
                "#a383f9",
                "#89e190",
                "#4fbf60",
                "#69d976"
            ],
            "label": {
                "color": "#ffffff"
            }
        },
        "map": {
            "itemStyle": {
                "areaColor": "#eee",
                "borderColor": "#444",
                "borderWidth": 0.5
            },
            "label": {
                "color": "#000"
            },
            "emphasis": {
                "itemStyle": {
                    "areaColor": "rgba(255,215,0,0.8)",
                    "borderColor": "#444",
                    "borderWidth": 1
                },
                "label": {
                    "color": "rgb(100,0,0)"
                }
            }
        },
        "geo": {
            "itemStyle": {
                "areaColor": "#eee",
                "borderColor": "#444",
                "borderWidth": 0.5
            },
            "label": {
                "color": "#000"
            },
            "emphasis": {
                "itemStyle": {
                    "areaColor": "rgba(255,215,0,0.8)",
                    "borderColor": "#444",
                    "borderWidth": 1
                },
                "label": {
                    "color": "rgb(100,0,0)"
                }
            }
        },
        "categoryAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#d9d9d9"
                }
            },
            "axisTick": {
                "show": false,
                "lineStyle": {
                    "color": "#eeeeee"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#d1d1d1"
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#303030"
                    ]
                }
            },
            "splitArea": {
                "show": false,
                "areaStyle": {
                    "color": [
                        "#eeeeee"
                    ]
                }
            }
        },
        "valueAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#d9d9d9"
                }
            },
            "axisTick": {
                "show": false,
                "lineStyle": {
                    "color": "#eeeeee"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#d1d1d1"
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#303030"
                    ]
                }
            },
            "splitArea": {
                "show": false,
                "areaStyle": {
                    "color": [
                        "#eeeeee"
                    ]
                }
            }
        },
        "logAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#d9d9d9"
                }
            },
            "axisTick": {
                "show": false,
                "lineStyle": {
                    "color": "#eeeeee"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#d1d1d1"
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#303030"
                    ]
                }
            },
            "splitArea": {
                "show": false,
                "areaStyle": {
                    "color": [
                        "#eeeeee"
                    ]
                }
            }
        },
        "timeAxis": {
            "axisLine": {
                "show": true,
                "lineStyle": {
                    "color": "#d9d9d9"
                }
            },
            "axisTick": {
                "show": false,
                "lineStyle": {
                    "color": "#eeeeee"
                }
            },
            "axisLabel": {
                "show": true,
                "color": "#d1d1d1"
            },
            "splitLine": {
                "show": true,
                "lineStyle": {
                    "color": [
                        "#303030"
                    ]
                }
            },
            "splitArea": {
                "show": false,
                "areaStyle": {
                    "color": [
                        "#eeeeee"
                    ]
                }
            }
        },
        "toolbox": {
            "iconStyle": {
                "borderColor": "#999999"
            },
            "emphasis": {
                "iconStyle": {
                    "borderColor": "#619bff"
                }
            }
        },
        "legend": {
            "textStyle": {
                "color": "#a3a3a3"
            }
        },
        "tooltip": {
            "axisPointer": {
                "lineStyle": {
                    "color": "#666666",
                    "width": "1"
                },
                "crossStyle": {
                    "color": "#666666",
                    "width": "1"
                }
            }
        },
        "timeline": {
            "lineStyle": {
                "color": "#a3a3a3",
                "width": 1
            },
            "itemStyle": {
                "color": "#a3a3a3",
                "borderWidth": "0.5"
            },
            "controlStyle": {
                "color": "#619bff",
                "borderColor": "#619bff",
                "borderWidth": 0.5
            },
            "checkpointStyle": {
                "color": "#619bff",
                "borderColor": "#ffffff"
            },
            "label": {
                "color": "#d1d1d1"
            },
            "emphasis": {
                "itemStyle": {
                    "color": "#d1d1d1"
                },
                "controlStyle": {
                    "color": "#619bff",
                    "borderColor": "#619bff",
                    "borderWidth": 0.5
                },
                "label": {
                    "color": "#d1d1d1"
                }
            }
        },
        "visualMap": {
            "color": [
                "#173da6",
                "#619bff",
                "#a9ceff"
            ]
        },
        "dataZoom": {
            "backgroundColor": "rgba(47,69,84,0)",
            "dataBackgroundColor": "rgba(255,255,255,0.3)",
            "fillerColor": "rgba(167,183,204,0.4)",
            "handleColor": "#a7b7cc",
            "handleSize": "100%",
            "textStyle": {
                "color": "#eeeeee"
            }
        },
        "markPoint": {
            "label": {
                "color": "#ffffff"
            },
            "emphasis": {
                "label": {
                    "color": "#ffffff"
                }
            }
        }
    });
}));
