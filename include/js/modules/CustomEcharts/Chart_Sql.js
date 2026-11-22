AjaxJSPage('ChartParent_js','include/js/modules/CustomEcharts/ChartParent.js');

function Chart_Sql() {
    var that = this;

    /**
     * 对图表类型对象进行加工，获取SQL统计图图表对象
     * @param {Object} ChartTypeObj 图表类型对象
     * @return {Object} 对应类型的SQL统计图图表对象
     */
    this.getInstance = function (ChartTypeObj) {
        that.ChartTypeObj = ChartTypeObj;
        //增加左侧区块信息
        that.getLeftBlockList();
        //统计字段拖动后，删去计算方法
        that.DelCalcMethod();
        //删去允许穿透
        that.DelPenetrate();
        //删去同环比
        that.DelCompareSelect();
        //删去显示类目条数
        that.DelDisplayLimit();
        //删除右侧导航栏的旭日图部分
        //that.DelSunburst();
        //删除排序区块
        that.ChartTypeObj.DelConfigSeq();
        return ChartTypeObj;
    }

    /**
     * 左侧区块信息，控制左侧区块的生成
     */
    this.getLeftBlockList = function () {
        that.ChartTypeObj.LeftBlockList = {
            SqlField: {
                BlockId : 'SqlField',
                BlockLabel : 'SQL',
                FieldList : {},
                HeadConId : 'EditSql',
            },
            Variable: {
                BlockId : 'Variable',
                BlockLabel : '变量列表',
                FieldList : {},
                HeadConId : 'NewVariable',
                HeadConLabel : '新变量',
            },
        };
    }
    
    this.FindFieldIndexById = function (dataArr,FieldId) {
        for (let i = 0; i < dataArr.length; i++) {
            if(dataArr[i].FieldId === FieldId){
                return i;
            }
        }
    }
    
    this.DelFieldById = function (dataArr,FieldId) {
        dataArr.splice(that.FindFieldIndexById(dataArr,FieldId),1);
    }

    /**
     * 删去计算方法字段
     */
    this.DelCalcMethod = function () {
        that.DelFieldById(that.ChartTypeObj.BlockFieldList.YAxisFieldBlock,'CalcMethod');
    }

    /**
     * 删去允许穿透
     */
    this.DelPenetrate = function () {
        that.DelFieldById(that.ChartTypeObj.BlockFieldList.ConfigOther,'CanPenetrate');
    }
    /**
     * 删去同环比
     */
    this.DelCompareSelect = function () {
        that.DelFieldById(that.ChartTypeObj.BlockFieldList.ConfigOther,'CompareSelect');
    }

    /**
     * 删去显示类目条数
     */
    this.DelDisplayLimit = function () {
        that.DelFieldById(that.ChartTypeObj.BlockFieldList.AxisTabXAxis,'DisplayLimit');
    }

    /**
     * 删除右侧导航栏的旭日图部分
     */
    this.DelSunburst = function () {
        that.ChartTypeObj.ChartTypeArr = [
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
        ];
    }
}