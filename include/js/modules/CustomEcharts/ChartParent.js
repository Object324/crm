/**
 * Edit: xll
 * Date: 2023/09/12
 * Description: 报表的父类
 */
function ChartParent() {
    var that = this;
    this.ChartType = 'ChartParent';
    this.ChartTypeArr = [
        {
            ParentType : 'line',
            SecondType: {
                'line': arrJsPopLabel['SINGLELINECHART'],
                'multiple_line': arrJsPopLabel['MULTIPLELINECHART'],
            },
            Label: arrJsPopLabel['LINECHART'],
        },
        {
            ParentType : 'bar',
            SecondType: {
                'bar': arrJsPopLabel['SINGLEBARCHART'],
                'multiple_bar': arrJsPopLabel['MULTIPLEBARCHART'],
                'bar_stack': arrJsPopLabel['STACKBARCHART'],
                'line_bar': arrJsPopLabel['MIXEDLINEBARCHART'],
                'simple_strip': arrJsPopLabel['SINGLESTRIPCHART'],
                'multiple_strip': arrJsPopLabel['MULTIPLESTRIPCHART'],
                'stack_strip': arrJsPopLabel['STACKSTRIPCHART']
            },
            Label: arrJsPopLabel['BARCHART'],
        },
        {
            ParentType : 'pie',
            SecondType: {
                'pie': arrJsPopLabel['HOLLOWPIECHART'],
                'solid_pie': arrJsPopLabel['SOLIDPIECHART'],
                'rose_pie': arrJsPopLabel['ROSECHART'],
                'nesting_pie': arrJsPopLabel['NESTEDPIECHART']
            },
            Label: arrJsPopLabel['PIECHART'],
        },
        {
            ParentType : 'funnel',
            SecondType: {
                'funnel': arrJsPopLabel['TRAPEFUNNELCHART'],
                'triangle': arrJsPopLabel['TRIANGLEFUNNELCHART'],
                'bowls': arrJsPopLabel['BOWLFUNNELCHART']
            },
            Label: arrJsPopLabel['FUNNELCHART'],
        },
        {
            ParentType : 'scatter',
            SecondType: {
                'basic_scatter': arrJsPopLabel['SINGLESCATTERCHART'],
                'multiple_dimension': arrJsPopLabel['MULTIPLESCATTERCHART']
            },
            Label: arrJsPopLabel['SCATTERCHART'],
        },
        {
            ParentType : 'sunburst',
            SecondType: {
                'simple_sunburst': arrJsPopLabel['SUNRISECHART']
            },
            Label: arrJsPopLabel['SUNRISECHART'],
        },
    ];
    this.BlockFieldList = {
        ModuleSel : [
            {
                FieldId : 'MainModule',
                FieldType : 'Select',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['MAINMODULE'],
                CssClass : 'Mandatory',
            },
            {
                FieldId : 'RelModule',
                FieldType : 'Select',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['RELATEDMODULE'],
                CssClass : '',
            },
            {
                FieldId : 'FieldSearch',
                FieldType : 'Input',
                FieldEvent : 'Event:keyup',
                FieldLabel : arrJsPopLabel['SEARCHFIELD'],
                CssClass : '',
            },
        ],
        ConfigHead : [
            {
                FieldId : 'ChartName',
                FieldType : 'Input',
                FieldEvent : 'Bind:report_name',
                FieldLabel : arrJsPopLabel['CHARTNAME'],  //'统计图名称',
                CssClass : 'Mandatory',//必填
            },
            {
                FieldId : 'FolderOptions',
                FieldType : 'Option',
                FieldEvent : 'Bind:analysisfolder_id',
                FieldLabel : arrJsPopLabel['SELECTFOLDERS'],  //'选择文件夹',
                CssClass : 'Mandatory',
            },
            {
                FieldId : 'ChartDescript',
                FieldType : 'Textarea',
                FieldEvent : 'Bind:report_desc',
                FieldLabel : arrJsPopLabel['CHARTDESCRIPTION'],  //'统计图描述'
                CssClass : '',
            },
        ],
        ConfigX : [
            {
                FieldId : 'XAxis',
                FieldType : 'Axis',
                SetNum : 'One',
                DefaultSetNum : 'One',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['StatisticalDimension'],  //'统计维度',
                CssClass : '',
                ConLabel : arrJsPopLabel['MAINMODULEFIELDLAY'],  //'请拖动主模块字段到此处',
            },
        ],
        ConfigY : [
            {
                FieldId : 'YAxis',
                FieldType : 'Axis',
                SetNum : 'Multi',
                DefaultSetNum : 'Multi',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['StatisticsField'],  //'统计字段',
                CssClass : '',
                ConLabel : arrJsPopLabel['StatisticsFieldLay'],  //'请拖动字段到此处',
            },
        ],
        ConfigSeq : [
            {
                FieldId : 'NewSeq',
                FieldType : 'SeqButton',
                FieldEvent : 'Event:click',
                FieldLabel : arrJsPopLabel['NEW'],  //'新增',
                CssClass : '',
            },
            {
                FieldId : 'SeqSet',
                FieldType : 'SeqSet',
                FieldEvent : '',
                FieldLabel : '',
                CssClass : '',
            },
        ],
        SeqBlock : [
            {
                FieldId : 'SeqHead',
                FieldType : 'SeqHead',
                FieldEvent : '',
                FieldLabel : '',
                CssClass : '',
            },
            {
                FieldId : 'SeqType',
                FieldType : 'Select',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['SORTTYPE'],  //'排序类型',
                CssClass : '',
            },
            {
                FieldId : 'SeqField',
                FieldType : 'Option',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['SORTFIELD'],  //'排序字段',
                CssClass : '',
            },
            {
                FieldId : 'SeqMethod',
                FieldType : 'Select',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['SORTMETHOD'],  //'排序方式',
                CssClass : '',
            },
        ],
        XAxisFieldBlock : [
            {
                FieldId : 'FieldBlockHead',
                FieldType : 'FieldBlockHead',
                FieldEvent : 'Event',
                FieldLabel : '',
                CssClass : '',
            },
            {
                FieldId : 'DragField',
                FieldType : 'DragField',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['Dimensionfield'],  //'维度字段',
                CssClass : '',
            },
        ],
        TimeMethod : {
            FieldId : 'TimeMethod',
            FieldType : 'Select',
            FieldEvent : '',
            FieldLabel : arrJsPopLabel['TIMEMETHOD'],  //'时间统计方式',
            CssClass : 'Width50',
        },
        YAxisFieldBlock : [
            {
                FieldId : 'FieldBlockHead',
                FieldType : 'FieldBlockHead',
                FieldEvent : '',
                FieldLabel : '',
                CssClass : '',
            },
            {
                FieldId : 'DragField',
                FieldType : 'DragField',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['StatisticsField'],  //'统计字段',
                CssClass : '',
            },
            {
                FieldId : 'CalcMethod',
                FieldType : 'Select',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['COMPUTINGMETHOD'],  //'计算方法',
                CssClass : '',
            },
            {
                FieldId : 'DisplayName',
                FieldType : 'Input',
                FieldEvent : '',
                FieldLabel : arrJsPopLabel['DISPLAYNAME'],  //'显示名称',
                CssClass : '',
            },
        ],
        SeriesType : {
            FieldId : 'SeriesType',
            FieldType : 'Select',
            FieldEvent : '',
            FieldLabel : arrJsPopLabel['DISPLAYSERIES'],  //'展示形式',
            CssClass : '',
        },
        YAxisIndex : {
            FieldId : 'YAxisIndex',
            FieldType : 'Select',
            FieldEvent : '',
            FieldLabel : arrJsPopLabel['SELECTAXIS'],  //'选择Y轴',
            CssClass : '',
        },
        CompareSelect : {
            FieldId : 'CompareSelect',
            FieldType : 'Select',
            FieldEvent : '',
            FieldLabel : arrJsPopLabel['qoq'],  //'同环比',//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
            CssClass : '',
        },
        ConfigOther : [
            {
                FieldId : 'LinkModule',
                FieldType : 'Check',
                FieldEvent : 'Bind:linkmodulecheck',
                FieldLabel : arrJsPopLabel['SETASLINKMODULE'],  //'设为链接模块',
                CssClass : 'Width50',
            },
            {
                FieldId : 'BoardStuff',
                FieldType : 'Check',
                FieldEvent : 'Bind:show_athome',
                FieldLabel : arrJsPopLabel['showAtPcHome'],  //'设为看板可选组件',
                CssClass : 'Width50',
            },
        ],
        StyleHead : [
            {
                FieldId : 'TitleSwitch',
                FieldType : 'Check',
                FieldEvent : 'Bind:TitleSwitch',
                FieldLabel : arrJsPopLabel['MAILTITLE'],  //'标题',
                CssClass : '',
            },
            {
                FieldId : 'AlignSet',
                FieldType : 'IconRow',
                FieldEvent : 'SelfBind:AlignSet;Event:mouseenter',
                FieldLabel : arrJsPopLabel['ALIGNMENT'],  //'对齐方式',
                CssClass : '',
                DefaultSet : 'AlignLeft',
            },
        ],
        StyleTheme : [
            {
                FieldId : 'ThemeSet',
                FieldType : 'IconBlockEmpty',
                FieldEvent : 'SelfBind:ThemeSet;Event:mouseenter',
                FieldLabel : arrJsPopLabel['THEME'],  //'主题',
                CssClass : '',
                DefaultSet : 'Default',
            },
        ],
        StyleLegend : [
            {
                FieldId : 'LegendLocate',
                FieldType : 'IconBlock',
                FieldEvent : 'SelfBind:LegendLocate;Event:mouseenter',
                FieldLabel : arrJsPopLabel['Legendposition'],  //'图例位置',
                CssClass : '',
                DefaultSet : 'RightTop',
            },
            {
                FieldId : 'LegendOrient',
                FieldType : 'Select',
                FieldEvent : 'Bind:LegendOrient',
                FieldLabel : arrJsPopLabel['Legendorientation'],  //'图例朝向',
                CssClass : '',
            },
            {
                FieldId : 'LegendType',
                FieldType : 'Select',
                FieldEvent : 'Bind:LegendType',
                FieldLabel : arrJsPopLabel['LegendType'],  //'图例类型',
                CssClass : '',
            },
        ],
        StyleAxis : [
            {
                FieldId : 'AxisTab',
                FieldType : 'AxisTab',
                FieldEvent : 'MultiEvent:mouseenter',
                FieldLabel : arrJsPopLabel['Axis'],  //'坐标轴',
                CssClass : '',
                AxisTab : {
                    XAxis : arrJsPopLabel['XAxis'],  //'X轴',
                    YAxis : arrJsPopLabel['YAxis'],  //'Y轴',
                },
                Selector : ' #CustomEchartsSet .StyleSet .SetBlock .FieldRow .AxisTab',
            },
        ],
        StyleSeriesDataLabel : [
            {
                FieldId : 'SeriesDataLabel',
                FieldType : 'Select',
                FieldEvent : 'Bind:SeriesDataLabel',
                FieldLabel : arrJsPopLabel['datalabel'],  //'数据标签',
                CssClass : '',
            }
        ],
        StyleReport : [
            {
                FieldId : 'ReportStyle',
                FieldType : 'IconBlock',
                FieldEvent : 'SelfBind:ReportStyle;Event:mouseenter',
                FieldLabel : arrJsPopLabel['ReportLocation'],  //'报表位置',
                CssClass : '',
                DefaultSet : 'Bottom',
            },
        ],
        AxisTabXAxis : [
            {
                FieldId : 'XAxisBottomName',
                FieldType : 'Input',
                FieldEvent : 'Bind:xaxis_bottom_name',//xaxis_top_name,
                FieldLabel : arrJsPopLabel['AxisName'],  //'名称',
                CssClass : '',
            },
            {
                FieldId : 'DisplayLimit',
                FieldType : 'Input',
                FieldEvent : 'Bind:limit',
                FieldLabel : arrJsPopLabel['Displaythenumberofcategories'],  //'显示类目条数',
                CssClass : 'Width50',
            },
            {
                FieldId : 'ScaleRotate',
                FieldType : 'Input',
                FieldEvent : 'Bind:xaxis_name_rotate',
                FieldLabel : arrJsPopLabel['Scalerotationdegree'],  //'刻度值旋转度数',
                CssClass : 'Width50',
            },
        ],
        AxisTabXAxis_Top : {
            FieldId : 'XAxisTopName',
            FieldType : 'Input',
            FieldEvent : 'Bind:xaxis_top_name',
            FieldLabel : arrJsPopLabel['UpperXaxisname'],  //'上X轴名称',
            CssClass : '',
        },
        AxisTabYAxis : [
            {
                FieldId : 'YAxisLeftName',
                FieldType : 'Input',
                FieldEvent : 'Bind:yaxis_left_name',//xaxis_top_name,
                FieldLabel : arrJsPopLabel['AxisName'],  //'名称',
                CssClass : '',
            },

        ],
        AxisTabYAxis_Right : {
            FieldId : 'YAxisRightName',
            FieldType : 'Input',
            FieldEvent : 'Bind:yaxis_right_name',
            FieldLabel : arrJsPopLabel['RIGHTYAXISNAME'],  //'右Y轴名称',
            CssClass : '',
        },
        YAxisLabelPosition : {
            FieldId : 'YAxisLabelPosition',
            FieldType : 'Select',
            FieldEvent : 'Bind:YAxisLabelPosition',
            FieldLabel : arrJsPopLabel['AxisLabelPosition'],  //刻度标签是否显示在图形内部,
            CssClass : 'Width50',
        },
        CanPenetrate : {
            FieldId : 'CanPenetrate',
            FieldType : 'Check',
            FieldEvent : 'Bind:can_penetrate',
            FieldLabel : arrJsPopLabel['Permissiblepenetration'],  //'允许穿透',
            CssClass : '',
        },
        ShowToolbox : {
            FieldId : 'ShowToolbox',
            FieldType : 'Check',
            FieldEvent : 'Bind:show_toolbox',
            FieldLabel : arrJsPopLabel['showtoolbox'],  //'显示工具栏/显示下载按钮',
            CssClass : '',
        },
        ShowPercent : {
            FieldId : 'ShowPercent',
            FieldType : 'Check',
            FieldEvent : 'Bind:show_percent',
            FieldLabel : arrJsPopLabel['Displaypercentage'],  //'显示百分比',
            CssClass : '',
        },
        DataLabelIsRotate : {
            FieldId : 'DataLabelIsRotate',
            FieldType : 'Check',
            FieldEvent : 'Bind:DataLabelIsRotate',
            FieldLabel : arrJsPopLabel['Isitdisplayedvertically'],  //'是否垂直显示',
            CssClass : '',
        },
        //zxm @date:2024/12/20 @reason: XUQIU20240926-04 统计图表增加行合计和列合计（谭成）
        ShowRowTotalData : {
            FieldId : 'ShowRowTotalData',
            FieldType : 'Check',
            FieldEvent : 'Bind:show_rowtotal',
            FieldLabel : arrJsPopLabel['ShouRowTotal'],  //'显示行合计',
            CssClass : '',
        },
        ShowColumnTotalData : {
            FieldId : 'ColumnTotalData',
            FieldType : 'Check',
            FieldEvent : 'Bind:show_columntotal',
            FieldLabel : arrJsPopLabel['ShouColumnTotal'],  //'显示列合计',
            CssClass : '',
        },
        //6."空心饼图”时 图表中显示合计 其他有列合计的图类型 显示:图表中显示列合计
        ShowTotalDataInChart : {
            FieldId : 'ShowTotalDataInChart',
            FieldType : 'Check',
            FieldEvent : 'Bind:show_alltotal_inchart',
            FieldLabel : arrJsPopLabel['ShouTotalInchart'],  //'图表中显示合计',
            CssClass : '',
        },
        ShowColumnTotalDataInChart : {
            FieldId : 'ShowColumnTotalDataInChart',
            FieldType : 'Check',
            FieldEvent : 'Bind:show_columntotal_inchart',
            FieldLabel : arrJsPopLabel['ShouColumnTotalInchart'],  //'图表中显示列合计',
            CssClass : '',
        },

    };
    this.SetBlockList = {
        Config : {
            Head : {
                BlockLabel : arrJsPopLabel['DisplaySetting'],  //'基本信息',
            },
            X : {
                BlockLabel : arrJsPopLabel['StatisticalDimension'],  //'维度',
            },
            Y : {
                BlockLabel : arrJsPopLabel['StatisticsField'],  //'字段',
            },
            Seq : {
                BlockLabel : arrJsPopLabel['SortSetting'],  //'排序设置',
            },
            Other : {
                BlockLabel : arrJsPopLabel['OtherSetting'],  //'其他设置',
            },

        },
        Style : {
            Head : {
                BlockLabel : arrJsPopLabel['DisplaySetting'],  //'基本信息',
            },
            Theme : {
                BlockLabel : arrJsPopLabel['THEME'],  //'主题',
            },
            Legend : {
                BlockLabel : arrJsPopLabel['LENGEND'],  //'图例',
            },
            Axis : {
                BlockLabel : arrJsPopLabel['Axis'],  //'坐标轴',
            },
            SeriesDataLabel : {
                BlockLabel : arrJsPopLabel['datalabel'],  //'数据标签',//增加数据标签的设置
            },
            Report : {
                BlockLabel : arrJsPopLabel['REPORTSETTING'],  //'报表格式',
            },
        },
    };
    this.IconList = {
        AlignSet : {
            AlignLeft : {
                IconType : 'Tip',
                Class : 'AlignLeft',
                Label : arrJsPopLabel['AlignLeft'],  //'左对齐',
            },
            AlignCenter : {
                IconType : 'Tip',
                Class : 'AlignCenter',
                Label : arrJsPopLabel['AlignCenter'],  //'居中对齐',
            },
            AlignRight : {
                IconType : 'Tip',
                Class : 'AlignRight',
                Label : arrJsPopLabel['AlignRight'],  //'右对齐',
            },
        },
        ThemeSet : {
            Default : {
                IconType : 'Image',
                Class : 'Default',
                Label : arrJsPopLabel['DefaultTheme'],  //'默认',
            },
            Light : {
                IconType : 'Image',
                Class : 'Light',
                Label : arrJsPopLabel['LightTheme'],  //'',light.js 对应黑色主题是dark.js
            },
            Westeros : {
                IconType : 'Image',
                Class : 'Westeros',
                Label : arrJsPopLabel['WesterosTheme'],  //' ',westeros.js 对应黑色主题是purple-passion.js
            },
            Black : {
                IconType : 'Image',
                Class : 'Black',
                Label : arrJsPopLabel['DarkTheme'],  //'科技黑',dark.js
            },
            Purple : {
                IconType : 'Image',
                Class : 'Purple',
                Label : arrJsPopLabel['PurpleTheme'],  //'紫色',purple-passion.js
            },
        },
        LegendLocate : {
            Bottom : {
                IconType : 'Label',
                Class : 'Bottom',
                Label : arrJsPopLabel['Bottom'],  //'底部',
            },
            Top : {
                IconType : 'Label',
                Class : 'Top',
                Label : arrJsPopLabel['Top'],  //'顶部',
            },
            LeftTop : {
                IconType : 'Label',
                Class : 'LeftTop',
                Label : arrJsPopLabel['LeftTop'],  //'左上',
            },
            LeftBottom : {
                IconType : 'Label',
                Class : 'LeftBottom',
                Label : arrJsPopLabel['LeftBottom'],  //'左下',
            },
            RightTop : {
                IconType : 'Label',
                Class : 'RightTop',
                Label : arrJsPopLabel['RightTop'],  //'右上',
            },
            RightBottom : {
                IconType : 'Label',
                Class : 'RightBottom',
                Label : arrJsPopLabel['RightBottom'],  //'右下',
            },
            None : {
                IconType : 'Label',
                Class : 'None',
                Label : arrJsPopLabel['NONE'],  //'无',
            },
        },
        ReportStyle : {
            Top : {
                IconType : 'Label',
                Class : 'Top',
                Label : arrJsPopLabel['Top'],  //'顶部',
            },
            Bottom : {
                IconType : 'Label',
                Class : 'Bottom',
                Label : arrJsPopLabel['Bottom'],  //'底部',
            },
            None : {
                IconType : 'Label',
                Class : 'None',
                Label : arrJsPopLabel['NONE'],  //'无',
            },
        },
    };
    this.PreviewPermitArr = {
        Length1 : ['AxisFields.XAxis','AxisFields.YAxis'],
    }
    this.ChangeBlockLabelToX = function () {
        //记录维度为X轴
        that.Coordinate = 'X';
        that.SetBlockList.Config.X.BlockLabel = arrJsPopLabel['Xaxiscategory'];  //'X轴（类目）';
        that.SetBlockList.Config.Y.BlockLabel = arrJsPopLabel['Yaxisvalue'];  //'Y轴（数值）';
    };
    this.ChangeBlockLabelToY = function () {
        //记录维度为Y轴
        that.Coordinate = 'Y';
        that.SetBlockList.Config.X.BlockLabel = arrJsPopLabel['Yaxiscategory'];  //'Y轴（类目）';
        that.SetBlockList.Config.Y.BlockLabel = arrJsPopLabel['Xaxisvalue'];  //'X轴（数值）';
        //修改名称
        that.BlockFieldList.YAxisIndex.FieldLabel = arrJsPopLabel['SELECTXAXIS'];  //'选择X轴';
    };
    this.ChangeAxisSetNum = {
        MultiY : function () {
            //y轴拖动字段增加选择y轴
            var YAxisIndex = that.BlockFieldList.YAxisIndex;
            that.BlockFieldList.YAxisFieldBlock.push(YAxisIndex);
        },
        OneX_OneY : function () {
            that.BlockFieldList.ConfigX[0].SetNum = 'One';
            that.BlockFieldList.ConfigX[0].DefaultSetNum = 'One';
            that.BlockFieldList.ConfigY[0].SetNum = 'One';
            that.BlockFieldList.ConfigY[0].DefaultSetNum = 'One';
        },
        OneX_MultiY : function () {
            that.BlockFieldList.ConfigX[0].SetNum = 'One';
            that.BlockFieldList.ConfigX[0].DefaultSetNum = 'One';
            that.BlockFieldList.ConfigY[0].SetNum = 'Multi';
            that.BlockFieldList.ConfigY[0].DefaultSetNum = 'Multi';
            this.MultiY();
        },
        TwoX_OneY : function () {
            that.BlockFieldList.ConfigX[0].SetNum = 'Two';
            that.BlockFieldList.ConfigX[0].DefaultSetNum = 'Two';
            that.BlockFieldList.ConfigY[0].SetNum = 'One';
            that.BlockFieldList.ConfigY[0].DefaultSetNum = 'One';
        },
        TwoX_MultiY : function () {
            that.BlockFieldList.ConfigX[0].SetNum = 'Two';
            that.BlockFieldList.ConfigX[0].DefaultSetNum = 'Two';
            that.BlockFieldList.ConfigY[0].SetNum = 'Multi';
            that.BlockFieldList.ConfigY[0].DefaultSetNum = 'Multi';
            this.MultiY();
        },
    };
    this.ChangeToMultiSeries = function () {
        var SeriesType = that.BlockFieldList.SeriesType;
        that.BlockFieldList.YAxisFieldBlock.push(SeriesType);
    };
    //zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
    this.ChangeToCompareSelect = function(){
        var CompareSelect = that.BlockFieldList.CompareSelect;
        //that.BlockFieldList.YAxisFieldBlock.push(CompareSelect);
        that.BlockFieldList.YAxisFieldBlock.splice(3,0,CompareSelect);
    }
    this.AddYAxisRightName = function () {
        //y轴设置增加设置右y轴名称
        var AxisTabYAxis_Right = that.BlockFieldList.AxisTabYAxis_Right;
        that.BlockFieldList.AxisTabYAxis.splice(1,0,AxisTabYAxis_Right);
    };
    this.AddYAxisLabelPosition = function () {
        //y轴设置增加刻度标签的位置
        var YAxisLabelPosition = that.BlockFieldList.YAxisLabelPosition;
        that.BlockFieldList.AxisTabYAxis.push(YAxisLabelPosition);
    };

    this.AddXAxisTopName = function () {
        //x轴设置增加设置上x轴名称
        var AxisTabXAxis_Top = that.BlockFieldList.AxisTabXAxis_Top;
        //添加到第二个位置
        that.BlockFieldList.AxisTabYAxis.splice(1,0,AxisTabXAxis_Top);
    };
    this.DelStyleAxis = function () {
        delete that.SetBlockList.Style.Axis;
    };
    this.DelConfigSeq = function () {
        delete that.SetBlockList.Config.Seq;
    };
    this.DelStyleSeriesDataLabel = function () {
        delete that.SetBlockList.Style.SeriesDataLabel;
    };
    //增加允许穿透控制
    this.AddPenetrate = function () {
        var CanPenetrate = that.BlockFieldList.CanPenetrate;
        that.BlockFieldList.ConfigOther.push(CanPenetrate);
    };
    //增加显示工具栏的控制
    this.AddShowToolbox = function () {
        var ShowToolbox = that.BlockFieldList.ShowToolbox;
        that.BlockFieldList.ConfigOther.push(ShowToolbox);
    };
    //增加显示百分比控制---从其他设置中移除  放到数据标签下 BUG20241217-46
    this.AddShowPercent = function () {
        var ShowPercent = that.BlockFieldList.ShowPercent;
        //that.BlockFieldList.ConfigOther.push(ShowPercent);
        that.BlockFieldList.StyleSeriesDataLabel.push(ShowPercent);
    };
    //增加数据标签是否旋转
    this.AddDataLabelIsRotate = function () {
        var DataLabelIsRotate = that.BlockFieldList.DataLabelIsRotate;
        that.BlockFieldList.StyleSeriesDataLabel.push(DataLabelIsRotate);
    };
    //增加显示行合计
    this.AddRowTotalData = function(){
        var ShowRowTotalData = that.BlockFieldList.ShowRowTotalData;
        that.BlockFieldList.StyleReport.push(ShowRowTotalData);
    }
    //增加显示列合计
    this.AddColumnTotalData = function(){
        var ShowColumnTotalData = that.BlockFieldList.ShowColumnTotalData;
        that.BlockFieldList.StyleReport.push(ShowColumnTotalData);
    }
    //增加显示 列合计是否显示在图标上的配置
    this.AddShowTotalDataInChart = function(){
        var ShowTotalDataInChart = that.BlockFieldList.ShowTotalDataInChart;
        that.BlockFieldList.StyleReport.push(ShowTotalDataInChart);
    }
    //增加显示 饼图是否显示总合计的配置
    this.AddShowColumnTotalDataInChart = function(){
        var ShowColumnTotalDataInChart = that.BlockFieldList.ShowColumnTotalDataInChart;
        that.BlockFieldList.StyleReport.push(ShowColumnTotalDataInChart);
    }

    //删除样式设置中的图例设置区块
    this.DelStyleLegend = function () {
        delete that.SetBlockList.Style.Legend;
    };
    this.DelStyleTheme = function () {
        delete that.SetBlockList.Style.Theme;
    };
    this.DelStyleReport = function () {
        delete that.SetBlockList.Style.Report;
    };
    this.EmptyConfirm = '';
    this.getEmptyConfirm = function () {
        if(that.EmptyConfirm !== '')
            return that.EmptyConfirm;
        var XSetNum = that.BlockFieldList.ConfigX[0].SetNum;
        var YSetNum = that.BlockFieldList.ConfigY[0].SetNum;
        var NumLabel = {
            One : arrJsPopLabel['NUMONE'],
            Two : arrJsPopLabel['NUMTWO'],
            Multi : arrJsPopLabel['NUMONEORMULTI'],
        }
        if(this.ParentType === 'scatter')
            NumLabel.Multi = arrJsPopLabel['NUMMULTI'];
        var XNumLabel = NumLabel[XSetNum] + arrJsPopLabel['StatisticalDimension'];
        var YNumLabel = NumLabel[YSetNum] + arrJsPopLabel['StatisticsField'];
        var SparateLabel = (language === 'zh-cn') ? '，' : ', '
        that.EmptyConfirm = arrJsPopLabel['EmptyConfirm'] + XNumLabel + SparateLabel + YNumLabel;
        return that.EmptyConfirm;
    }
 
    this.AddPenetrate();
    this.AddShowToolbox();

    //数据标签 下拉框值的过滤
    this.filterOptionFun = function(optionArr){
        var newOptionArr = [];
        ld.each(optionArr,function(i,option){
            var ParentType = that.ParentType;
            if(that.ChartType=='simple_strip'||that.ChartType=='multiple_strip'||that.ChartType=='stack_strip'){
                ParentType = 'strip';//条形图
            }
            if(option.filter==ParentType){
                newOptionArr.push(option);
            }
        })
        return newOptionArr;
    }
    this.filterOption = {
        SeriesDataLabel : function (optionArr) {
            return that.filterOptionFun(optionArr);
        }
    }
}

//单折线图
function Chart_line() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'line';
    this.ParentType = 'line';
    this.ChangeBlockLabelToX();
    this.ChangeAxisSetNum.OneX_OneY();
    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
    this.AddRowTotalData();//增加显示行合计的设置
}
Chart_line.prototype = Object.create(ChartParent.prototype);
Chart_line.prototype.constructor = Chart_line;

//多折线图
function Chart_multiple_line() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'multiple_line';
    this.ParentType = 'line';

    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
    this.ChangeBlockLabelToX();
    this.ChangeAxisSetNum.OneX_MultiY();
    this.AddYAxisRightName();

    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    this.AddShowColumnTotalDataInChart();
}
Chart_multiple_line.prototype = Object.create(ChartParent.prototype);
Chart_multiple_line.prototype.constructor = Chart_multiple_line;

//单柱状图
function Chart_bar() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'bar';
    this.ParentType = 'bar';
    this.ChangeBlockLabelToX();
    this.AddDataLabelIsRotate();//增加数据标签是否旋转
    this.ChangeAxisSetNum.TwoX_OneY();
    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
    this.AddRowTotalData();//增加显示行合计的设置
    //this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    //this.AddShowColumnTotalDataInChart();
}
Chart_bar.prototype = Object.create(ChartParent.prototype);
Chart_bar.prototype.constructor = Chart_bar;
//多柱状图
function Chart_multiple_bar() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'multiple_bar';
    this.ParentType = 'bar';
    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能

    this.ChangeBlockLabelToX();
    this.AddDataLabelIsRotate();//增加数据标签是否旋转
    this.ChangeAxisSetNum.TwoX_MultiY();
    this.AddYAxisRightName();

    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    this.AddShowColumnTotalDataInChart();
    this.setdataBindValue=function(){

    }
}
Chart_multiple_bar.prototype = Object.create(ChartParent.prototype);
Chart_multiple_bar.prototype.constructor = Chart_multiple_bar;
//柱状堆叠
function Chart_bar_stack() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'bar_stack';
    this.ParentType = 'bar';
    this.ChangeBlockLabelToX();
    this.AddDataLabelIsRotate();//增加数据标签是否旋转
    this.ChangeAxisSetNum.OneX_MultiY();
    this.AddYAxisRightName();
    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    this.AddShowColumnTotalDataInChart();
}
Chart_bar_stack.prototype = Object.create(ChartParent.prototype);
Chart_bar_stack.prototype.constructor = Chart_bar_stack;
//折柱混合图
function Chart_line_bar() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'line_bar';
    this.ParentType = 'bar';
    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能

    this.ChangeBlockLabelToX();
    this.ChangeToMultiSeries(); //多类型Series
    this.AddDataLabelIsRotate();//增加数据标签是否旋转
    this.ChangeAxisSetNum.OneX_MultiY();
    this.AddYAxisRightName();

    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    this.AddShowColumnTotalDataInChart();
}
Chart_line_bar.prototype = Object.create(ChartParent.prototype);
Chart_line_bar.prototype.constructor = Chart_line_bar;
//单条形图
function Chart_simple_strip() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'simple_strip';
    this.ParentType = 'bar';
    this.ChangeBlockLabelToY();
    this.ChangeAxisSetNum.TwoX_OneY();
    this.AddXAxisTopName();
    this.AddYAxisLabelPosition();
    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
    this.AddRowTotalData();//增加显示行合计的设置
    //this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    //this.AddShowColumnTotalDataInChart();
}
Chart_simple_strip.prototype = Object.create(ChartParent.prototype);
Chart_simple_strip.prototype.constructor = Chart_simple_strip;
//多条形图
function Chart_multiple_strip() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'multiple_strip';
    this.ParentType = 'bar';
    this.ChangeToCompareSelect();//zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
    this.ChangeBlockLabelToY();
    this.ChangeAxisSetNum.TwoX_MultiY();
    this.AddXAxisTopName();
    this.AddYAxisLabelPosition();

    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    this.AddShowColumnTotalDataInChart();
}
Chart_multiple_strip.prototype = Object.create(ChartParent.prototype);
Chart_multiple_strip.prototype.constructor = Chart_multiple_strip;
//条形堆叠图
function Chart_stack_strip() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'stack_strip';
    this.ParentType = 'bar';
    this.ChangeBlockLabelToY();
    this.ChangeAxisSetNum.TwoX_MultiY();
    this.AddXAxisTopName();
    this.AddYAxisLabelPosition();

    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    this.AddShowColumnTotalDataInChart();
}
Chart_stack_strip.prototype = Object.create(ChartParent.prototype);
Chart_stack_strip.prototype.constructor = Chart_stack_strip;

//饼图父类
function Chart_parent_pie() {
    ChartParent.call(this);
    var that = this;
    this.ParentType = 'pie';
    this.ChangeAxisSetNum.OneX_OneY();
    this.DelStyleAxis();
    this.DelConfigSeq();
    //this.AddPenetrate();
    this.AddShowPercent();

    this.AddRowTotalData();//增加显示行合计的设置

}
Chart_parent_pie.prototype = Object.create(ChartParent.prototype);
Chart_parent_pie.prototype.constructor = Chart_parent_pie;
//空心饼图
function Chart_pie() {
    Chart_parent_pie.call(this);
    var that = this;
    this.ChartType = 'pie';
    this.ParentType = 'pie';
    //空心饼图才显示 图表中显示合计
    this.AddShowTotalDataInChart();
}
Chart_pie.prototype = Object.create(Chart_parent_pie.prototype);
Chart_pie.prototype.constructor = Chart_pie;
//实心饼图
function Chart_solid_pie() {
    Chart_parent_pie.call(this);
    var that = this;
    this.ChartType = 'solid_pie';
    this.ParentType = 'pie';
}
Chart_solid_pie.prototype = Object.create(Chart_parent_pie.prototype);
Chart_solid_pie.prototype.constructor = Chart_solid_pie;
//南丁格尔玫瑰图
function Chart_rose_pie() {
    Chart_parent_pie.call(this);
    var that = this;
    this.ChartType = 'rose_pie';
    this.ParentType = 'pie';

}
Chart_rose_pie.prototype = Object.create(Chart_parent_pie.prototype);
Chart_rose_pie.prototype.constructor = Chart_rose_pie;
//嵌套饼图
function Chart_nesting_pie() {
    Chart_parent_pie.call(this);
    var that = this;
    this.ChartType = 'nesting_pie';
    this.ParentType = 'pie';
    this.ChangeAxisSetNum.TwoX_OneY();
}
Chart_nesting_pie.prototype = Object.create(Chart_parent_pie.prototype);
Chart_nesting_pie.prototype.constructor = Chart_nesting_pie;
//漏斗
function Chart_funnel() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'funnel';
    this.ParentType = 'funnel';
    this.ChangeAxisSetNum.OneX_OneY();
    this.DelStyleAxis();
    this.DelConfigSeq();
    //this.AddPenetrate();

    this.AddRowTotalData();//增加显示行合计的设置
    //this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    //this.AddShowColumnTotalDataInChart();
}
Chart_funnel.prototype = Object.create(ChartParent.prototype);
Chart_funnel.prototype.constructor = Chart_funnel;
//三角形漏斗
function Chart_triangle() {
    Chart_funnel.call(this);
    var that = this;
    this.ChartType = 'triangle';
    this.ParentType = 'funnel';
}
Chart_triangle.prototype = Object.create(Chart_funnel.prototype);
Chart_triangle.prototype.constructor = Chart_triangle;
//碗型漏斗
function Chart_bowls() {
    Chart_funnel.call(this);
    var that = this;
    this.ChartType = 'bowls';
    this.ParentType = 'funnel';
}
Chart_bowls.prototype = Object.create(Chart_funnel.prototype);
Chart_bowls.prototype.constructor = Chart_bowls;
//单维度散点图
function Chart_basic_scatter() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'basic_scatter';
    this.ParentType = 'scatter';
    this.ChangeAxisSetNum.OneX_MultiY();
    this.DelConfigSeq();
    this.DelStyleSeriesDataLabel();//散点图不显示数据标签设置
    //删除选择Y轴
    //3这是显示名称 需要显示
    this.BlockFieldList.YAxisFieldBlock.splice(4,1);
    //散点图统计字段必须>=2
    this.PreviewPermitArr = {
        Length1 : ['AxisFields.XAxis'],
        Length2 : ['AxisFields.YAxis'],
    }

    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();
    //this.AddShowTotalDataInChart();
    //this.AddShowColumnTotalDataInChart();
}
Chart_basic_scatter.prototype = Object.create(ChartParent.prototype);
Chart_basic_scatter.prototype.constructor = Chart_basic_scatter;
//多维度散点图
function Chart_multiple_dimension() {
    ChartParent.call(this);
    var that = this;
    this.ChartType = 'multiple_dimension';
    this.ParentType = 'scatter';


    this.ChangeAxisSetNum.TwoX_MultiY();
    this.DelConfigSeq();
    this.DelStyleSeriesDataLabel();//散点图不显示数据标签设置
    //删除选择Y轴
    //3这是显示名称 需要显示
    this.BlockFieldList.YAxisFieldBlock.splice(4,1);
    //散点图统计字段必须>=2
    this.PreviewPermitArr = {
        Length1 : ['AxisFields.XAxis'],
        Length2 : ['AxisFields.YAxis'],
    }

    //this.AddRowTotalData();//增加显示行合计的设置
    //this.AddColumnTotalData();
}
Chart_multiple_dimension.prototype = Object.create(ChartParent.prototype);
Chart_multiple_dimension.prototype.constructor = Chart_multiple_dimension;
//旭日图
function Chart_simple_sunburst() {
    ChartParent.call(this);
    this.ChartType = 'simple_sunburst';
    this.ParentType = 'sunburst';


    this.ChangeAxisSetNum.OneX_OneY();
    this.DelConfigSeq();
    this.DelStyleAxis();
    this.DelStyleSeriesDataLabel();//旭日图不显示数据标签设置
    this.DelStyleLegend();
    this.DelStyleTheme();
    this.DelStyleReport();


}
Chart_simple_sunburst.prototype = Object.create(ChartParent.prototype);
Chart_simple_sunburst.prototype.constructor = Chart_simple_sunburst;

//SQL统计图的旭日图
function Chart_multiple_sunburst() {
    ChartParent.call(this);
    this.ChartType = 'simple_sunburst';
    this.ParentType = 'sunburst';


    this.ChangeAxisSetNum.TwoX_OneY();
    this.DelConfigSeq();
    this.DelStyleAxis();
    //this.DelStyleSeriesDataLabel();//旭日图不显示数据标签设置
    this.DelStyleLegend();
    //this.DelStyleTheme();
    //this.DelStyleReport();
    this.AddRowTotalData();//增加显示行合计的设置
    this.AddColumnTotalData();

}
Chart_multiple_sunburst.prototype = Object.create(ChartParent.prototype);
Chart_multiple_sunburst.prototype.constructor = Chart_multiple_sunburst;

