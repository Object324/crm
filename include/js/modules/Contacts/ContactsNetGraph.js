class ContactsNetGraph {
    constructor() {
        var PopupObj = CrmPopup.getPopupObj('last');
        if(PopupObj && PopupObj.divid)
            PopupObj.ContactsNetGraphObj = this;
    }
    init(ChartJqObj,data) {
        this.layoutObj = ChartJqObj.get(0)
        this.chartObj = echarts.init(this.layoutObj);
        this.setData(data);
    }
    setData(data) {
        this.data = data;
    }
    getGraphOption() {
        this.option = {
            title: {
                text: '人脉图谱',
                subtext: 'Default layout',
                top: 'bottom',
                left: 'right'
            },
            tooltip: {
                formatter: function(params){
                    var str = params.name;
                    if(params.data && params.data.nodeData ){
                        if(typeof params.data.nodeData.fullName !== "undefined") {
                            str = params.data.nodeData.fullName
                        }
                        if(typeof params.data.nodeData.dep === "string" && params.data.nodeData.dep.length > 0) {
                            str += '</br>' + '部门：' + params.data.nodeData.dep
                        }
                        if(typeof params.data.nodeData.zhiwu === "string" && params.data.nodeData.zhiwu.length > 0) {
                            str += '</br>' + '职务：' + params.data.nodeData.zhiwu
                        }
                    }
                    return params.marker + str;
                },
            },
            legend: [
                {
                    data: this.data.legendData,
                }
            ],
            animationDuration: 1500,
            animationEasingUpdate: 'quinticInOut',
            series: [
                {
                    name: '人脉图谱',
                    type: 'graph',
                    zoom: 1,
                    roam: true,
                    layout: 'none',
                    label: {
                        show: true,
                        fontSize: 16,
                        verticalAlign: 'middle',
                    },
                    //top: '12%',
                    data: this.data.nodes,
                    links: this.data.links,
                    categories: this.data.categories
                }
            ]
        };
    }
    showGraph() {
        this.getGraphOption();
        this.chartObj.setOption(this.option);
        this.setPenetrate();
        var that = this,
            observer = new ResizeObserver(function (entries, observer) {
                that.chartObj.resize();
            });
        observer.observe(this.layoutObj);
    }
    setPenetrate() {
        this.chartObj.off('click').on('click', this.graphPenetrate);
    }
    graphPenetrate(params) {
        if(params.dataType !== 'node' || typeof params.data.nodeData !== "object") {
            return false;
        }
        if(params.data.nodeData.nodeType !== 'contact')
            return false;
        var module = 'Contacts',
            record = params.data.nodeData.nodeId,
            lasturl = '';
        AjaxJSPage(module+"_js",'include/js/modules/'+module+'/'+module+'.js');
        EmptyProgressObjs();
        ld(" .first-drawer-wrapper").remove();//关闭抽屉
        DetailViewPage.showpage(module,record,lasturl,{'pageto_module':module,'pageto_action':'DetailView','pageto_record':record});
    }
}