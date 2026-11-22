//渲染统计图的js
var renderChartFun = function() {
    this.myChartObj = '';//图表对象
    this.chartType = 'bar';//图表类型 默认给bar
    this.report_id = 0;//报表ID
    this.color = ['#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de', '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc',
        '#005f73','#099396','#94d2bd','#e9d7a5','#ee9b00','#ca6604','#bb3e04','#ae2012','#9b2227',
        '#cb997e','#fec5ba','#fcd5ce','#d7e2dc','#48cae4','#2a9d8e','#ddbea9','#6b705c','#9b5de6'];//颜色系列 27个  超过27个颜色一次循环使用
    var that = this;
    this.init = function(report_id,data,chartType){
        that.chartType = chartType;
        that.myChartObj = echarts.init(document.getElementById('myChart_' + that.chartType +report_id));
        var option;
        switch (chartType) {
            case "bar": option= that.barData(data);break;
            case "line": option= that.lineData(data);break;
            case "pie": option= that.pieData(data);break;
        }

        that.myChartObj.setOption(option);
    }

    this.barData = function(data){
        var option =  {
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'shadow'
                }
            },
            xAxis: {
                type: 'category',
                    data: data.legend
            },
            yAxis: {
                type: 'value'
            },
            series: [
                {
                    data: data.datas,
                    type: 'bar'
                }
            ]
        };
        return option;
    }
    this.lineData = function(data){
        var option = {
            xAxis: {
                type: 'category',
                data: data.legend
            },
            yAxis: {
                type: 'value'
            },
            series: [
                {
                    data: data.datas,
                    type: 'line'
                }
            ]
        };
        return option;
    }
    this.pieData = function(data){
        var option = {
            tooltip: {
                trigger: 'item'
            },
            legend: {
                orient: 'vertical',
                left: 'left',
                data: data.legend
            },
            series: [
                {
                    name: 'Access From',
                    type: 'pie',
                    radius: '50%',
                    data: data.datas,
                    emphasis: {
                        itemStyle: {
                            shadowBlur: 10,
                            shadowOffsetX: 0,
                            shadowColor: 'rgba(0, 0, 0, 0.5)'
                        }
                    }
                }
            ]
        };
        return option;
    }
}