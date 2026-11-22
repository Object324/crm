//自定义统计图 sql模式 字段显示设置
var CustomEchartsSqlColumnFieldShow =function() {
    //line
    //simple_strip
    //bar     没有新增按钮、没有删除按钮 的类型    line，simple_strip，bar和所有的饼图
    this.simple = {
    'newButton':'no',
    'field':[
        {
            'label':'行',
            'type':'sequence',
            'width':'8%',
            'name':''
        },{
            'label':'选择统计字段',
            'type':'field',
            'width':'42.4%',
            'name':'columns'
        },{
            'label':'显示名称',
            'type':'text',
            'width':'42.4%',
            'name':'chart_column_name',
            'inputwidth':'100%'
        },{
            'label':'',
            'type':'action',
            'width':'7.2%',
            'options':[{"label":"","value":""}],
            'name':''
        }
    ]
}
    // 漏斗图
    this.funnel = {
        'newButton':'no',
        'field':[
            {
                'label':'行',
                'type':'sequence',
                'width':'8%',
                'name':''
            },{
                'label':'选择统计字段',
                'type':'field',
                'width':'42.4%',
                'name':'columns'
            },{
                'label':'显示名称',
                'type':'text',
                'width':'42.4%',
                'name':'chart_column_name'
            },{
                'label':'',
                'type':'action',
                'width':'7.2%',
                'options':[{"label":"","value":""}],
                'name':''
            }
        ]
    }
    //混合 折柱混合line_bar  需要选择展现形式与Y轴
    this.blend = {
    'newButton':'yes',
    'field':[
        {
            'label':'行',
            'type':'sequence',
            'width':'8%',
            'name':''
        },{
            'label':'选择统计字段',
            'type':'field',
            'width':'30%',
            'name':'columns'
        },{
            'label':'显示名称',
            'type':'text',
            'width':'30%',
            'name':'chart_column_name'
        },{
            'label':'展示形式',
            'type':'picklist',
            'options':[{"label":"柱状","value":"bar"},{"label":"折线","value":"line"}],
            'width':'17.4%',
            'name':'chart_column_type'
        },{
            'label':'选择Y轴',
            'type':'picklist',
            'options':[{"label":"左Y轴","value":"left"},{"label":"右Y轴","value":"right"}],
            'width':'17.4%',
            'name':'yaxisindex'
        },{
            'label':'操作',
            'type':'action',
            'options':[{"label":"删除","value":"delete"}],
            'width':'7.2%',
            'name':''
        }
    ]
}
    //多条形图、条形堆叠图 可选择X轴
    this.strip = {
    'newButton':'yes',
    'field':[
        {
            'label':'行',
            'type':'sequence',
            'width':'8%',
            'name':''
        },{
            'label':'选择统计字段',
            'type':'field',
            'width':'30%',
            'name':'columns'
        },{
            'label':'显示名称',
            'type':'text',
            'width':'30%',
            'name':'chart_column_name'
        },{
            'label':'选择X轴',
            'type':'picklist',
            'options':[{"label":"下X轴","value":"bottom"},{"label":"上X轴","value":"top"}],
            'width':'22.8%',
            'name':'yaxisindex'//跟Y轴存同一个字段，程序判断图表类型
        },{
            'label':'操作',
            'type':'action',
            'options':[{"label":"删除","value":"delete"}],
            'width':'7.2%',
            'name':''
        }
    ]
}
    //散点图
    this.scatter = {
    'newButton':'yes',
    'field':[
        {
            'label':'行',
            'type':'sequence',
            'width':'8%',
            'name':''
        },{
            'label':'选择统计字段',
            'type':'field',
            'width':'42.4%',
            'name':'columns'
        },{
            'label':'显示名称',
            'type':'text',
            'width':'42.4%',
            'name':'chart_column_name'
        },{
            'label':'操作',
            'type':'action',
            'options':[{"label":"删除","value":"delete"}],
            'width':'7.2%',
            'name':''
        }
    ]
}

    //其他 多柱状图、stack_bar柱状堆叠图 可选择Y轴
    this.other = {
    'newButton':'yes',
    'field':[
        {
            'label':'行',
            'type':'sequence',
            'width':'8%',
            'name':''
        },{
            'label':'选择统计字段',
            'type':'field',
            'width':'30%',
            'name':'columns'
        },{
            'label':'显示名称',
            'type':'text',
            'width':'30%',
            'name':'chart_column_name'
        },{
            'label':'选择Y轴',
            'type':'picklist',
            'options':[{"label":"左Y轴","value":"left"},{"label":"右Y轴","value":"right"}],
            'width':'22.8%',
            'name':'yaxisindex'
        },{
            'label':'操作',
            'type':'action',
            'options':[{"label":"删除","value":"delete"}],
            'width':'7.2%',
            'name':''
        }
    ]
}

    this.ColumnsListObj = {};
    //获取列头
    this.getColumnsList = function(name){
        switch (name) {
            case "line":
            case "simple_strip":
            case "bar":
                this.ColumnsListObj = this.simple;
                break;
            case "pie"://空心饼图 不需要显示名称列
            case "solid_pie"://实心饼图
            case "rose_pie"://玫瑰图
            case "nesting_pie"://嵌套饼图
            case "simple_sunburst"://旭日图
            case "funnel"://漏斗图不需要显示名称列
            case "triangle":
            case "bowls":
                this.ColumnsListObj = this.funnel;
                break;
            case "line_bar"://折柱混合图需要选择展现形式
                this.ColumnsListObj = this.blend;
                break;
            case "basic_scatter":
            case "multiple_dimension"://散点图
                this.ColumnsListObj=this.scatter;
                break;
            case "multiple_strip":
            case "stack_strip":
                this.ColumnsListObj = this.strip;
                break;
            default:
                this.ColumnsListObj = this.other;
                break;
        }
        return this.ColumnsListObj;
    }
};
CustomEchartsSqlColumnFieldShowObj = new CustomEchartsSqlColumnFieldShow();