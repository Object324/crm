var CustomEchartsSqlAdvancedSetting = function(){
    //高级设置的输入项显示设置
    //图例类型  图例朝向不需要限制
    //漏斗图--只显示图例设置 其他的都不显示
    this.funnel = {
        "xaxis_bottom_name":"no",//下X轴名称
        "xaxis_name_rotate":"no",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"no",//左Y轴名称
        "yaxis_right_name":"no",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"no",//显示百分比
        "groupby_second":"no"//第二统计维度
    }
    //饼图--是否显示百分比/图例设置 显示 其他的都不显示
    this.pie = {
        "xaxis_bottom_name":"no",//下X轴名称
        "xaxis_name_rotate":"no",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"no",//左Y轴名称
        "yaxis_right_name":"no",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"yes",//显示百分比
        "groupby_second":"no"//第二统计维度
    }
    //嵌套饼图需要第二维度
    this.pie1 = {
        "xaxis_bottom_name":"no",//下X轴名称
        "xaxis_name_rotate":"no",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"no",//左Y轴名称
        "yaxis_right_name":"no",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"yes",//显示百分比
        "groupby_second":"yes"//第二统计维度
    }
    //折线图 有右Y轴的
    this.line1 = {
        "xaxis_bottom_name":"yes",//下X轴名称
        "xaxis_name_rotate":"yes",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"yes",//左Y轴名称
        "yaxis_right_name":"yes",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"no",//显示百分比
        "groupby_second":"no"//第二统计维度
    }
    //折线图  没有右Y轴的
    this.line2 = {
        "xaxis_bottom_name":"yes",//下X轴名称
        "xaxis_name_rotate":"yes",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"yes",//左Y轴名称
        "yaxis_right_name":"no",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"no",//显示百分比
        "groupby_second":"no"//第二统计维度
    }
    // 柱状图 可以有右Y轴的
    this.bar1 = {
        "xaxis_bottom_name":"yes",//下X轴名称
        "xaxis_name_rotate":"yes",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"yes",//左Y轴名称
        "yaxis_right_name":"yes",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"no",//显示百分比
        "groupby_second":"yes"//第二统计维度
    }
    //柱状图 没有右Y轴的
    this.bar2 = {
        "xaxis_bottom_name":"yes",//下X轴名称
        "xaxis_name_rotate":"yes",//X轴刻度旋转角度
        "xaxis_top_name":"no",//上X轴名称
        "yaxis_left_name":"yes",//左Y轴名称
        "yaxis_right_name":"no",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"no",//显示百分比
        "groupby_second":"yes"//第二统计维度
    }
    //条形图
    this.strip = {
        "xaxis_bottom_name":"yes",//下X轴名称
        "xaxis_name_rotate":"no",//X轴刻度旋转角度
        "xaxis_top_name":"yes",//上X轴名称
        "yaxis_left_name":"yes",//左Y轴名称
        "yaxis_right_name":"no",//右Y轴名称
        "legend_position":"yes",//图例位置
        "legend_type":"yes",//图例
        "legend_orient":"yes",//图例
        "showPercent":"no",//显示百分比
        "groupby_second":"no"//第二统计维度
    }
    //获取显隐属性
    this.getShowRes = function(name){
        switch (name) {
            case "line"://没有右Y轴的
                this.showRes = this.line2;
                break;
            case "bar"://没有右Y轴的
                this.showRes = this.bar2;
                break;
            case "multiple_line"://有右Y轴的
                this.showRes = this.line1;
                break;
            case "pie"://空心饼图
            case "solid_pie"://实心饼图
            case "rose_pie"://玫瑰图
                this.showRes = this.pie;
                break;
            case "nesting_pie"://嵌套饼图
                this.showRes = this.pie1;
                break;
            case "funnel"://漏斗图不需要显示名称列
            case "triangle":
            case "bowls":
                this.showRes = this.funnel;
                break;
            case "simple_strip":
            case "multiple_strip":
            case "stack_strip":
                this.showRes = this.strip;
                break;
            case "multiple_dimension"://多维度散点图
                this.showRes = this.bar2;
                break;
            default:
                this.showRes = this.bar1;
                break;
        }
        return this.showRes;
    }
}
var CustomEchartsSqlAdvancedSettingObj = new CustomEchartsSqlAdvancedSetting();