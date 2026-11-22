AjaxJSPage('cls_ChartSetHtml','include/js/modules/CustomEcharts/cls_ChartSetHtml.js');
/**
 * @class  SqlChartSetHtml
 * @author  xll
 * @date  2023/11/1 - 初始版本
 * - SQL统计图 新建编辑页面类
 * @description  生成SQL统计图新建编辑的页面
 */
function SqlChartSetHtml() {
    cls_ChartSetHtml.call(this);
    var that = this;

    /**
     * 页面设置信息、SQL统计图需要删去模块配置部分
     * @param {Object} ChartSetArr - 页面设置信息Json
     */
    this.Set_ChartSetArr = function (ChartSetArr) {
        that.ChartSetArr = ChartSetArr;
    }

    /**
     * SQL统计图新建编辑界面左侧部分
     */
    this.getLeftContentHtml = function () {
        var LeftContentHtml = '';
        LeftContentHtml += '<div class="CustomEchartsLeft">';

        LeftContentHtml += '<div class="ModuleField_Scroll" style="height: 100%">';
        LeftContentHtml += that.getLeftBlock();
        //LeftContentHtml += that.getModuleFieldHtml(that.RelModuleSelArr);
        LeftContentHtml += '</div>';
        LeftContentHtml += '</div>';
        return LeftContentHtml;
    }

    this.getLeftBlock = function () {
        var LeftBlockInfo = that.ChartObj.LeftBlockList;
        var LeftBlock = '';
        LeftBlock += that.getFieldBlock(LeftBlockInfo);
        return LeftBlock;
    }

    /**
     * - 左侧字段托拽区块的生成方法
     * @param {Object} BlockInfoList 区块列表
     * @return {string} 左侧字段托拽区块的Html字符串
     */
    this.getFieldBlock = function (BlockInfoList) {
        var BlockHtml = '';
        ld.each(BlockInfoList,function (BlockId,BlockInfo) {
            var FieldList = BlockInfo.FieldList;
            if(that.ChartSetArr.FieldList && that.ChartSetArr.FieldList[BlockId])
                FieldList = that.ChartSetArr.FieldList[BlockId];
            BlockHtml += '<div class="ModuleFieldBlock" id="Block_'+BlockId+'" >' +
                             //头部
                             '<div class="ModuleFieldHead" Block_Id="'+BlockId+'" blocksatus="expand">' +
                                 BlockInfo.BlockLabel +
                                 that.getBlockHeadCon[BlockInfo.HeadConId](BlockInfo) +
                             '</div>' +
                             //字段列表
                             '<div class="ModuleFieldCon" Block_Id="'+BlockId+'" >' +
                                 that.getFieldBlockCon(FieldList,BlockId) +
                             '</div>' +
                         '</div>';
        });
        that.FieldInfoPush({
            FieldId : 'ModuleFieldHead',
            Selector : ' .ModuleField_Scroll .ModuleFieldHead',
            FieldEvent : 'MultiEvent:click',
        });
        return BlockHtml;
    }

    this.getBlockHeadCon = {
        HeadConPush : function (BlockInfo) {
            var HeadConInfo = {
                FieldId : BlockInfo.HeadConId,
                FieldEvent : 'Event:click',
            };
            that.FieldInfoPush(HeadConInfo);
        },
        EditSql : function (BlockInfo) {
            this.HeadConPush(BlockInfo);
            return '<div id="'+BlockInfo.HeadConId+'" class="BlockHeadCon EditIcon ld-fonticon ld-fonticon-edit"></div>';
        },
        NewVariable : function (BlockInfo) {
            this.HeadConPush(BlockInfo);
            return '<span id="'+BlockInfo.HeadConId+'" class="BlockHeadCon NewVariable" fieldid="0">'+BlockInfo.HeadConLabel+'</span>';
        },
    }

    /**
     * - 左侧字段列表的生成方法
     * @param {Array.<Object>} FieldList 字段列表
     * @param {string} BlockId 区块ID
     * @return {string} Html字符串
     */
    this.getFieldBlockCon = function (FieldList,BlockId) {
        var BlockConHtml = '';
        ld.each(FieldList,function (index,FieldInfo) {
            BlockConHtml += '<div class="Field Block-'+BlockId+'" fieldindex="'+index+'" ' + ' fieldid="'+FieldInfo.id+'">' +
                                that.FieldCon[BlockId](FieldInfo) +
                            '</div>';
        });
        return BlockConHtml;
    }
    
    this.FieldCon = {
        SqlField : function (FieldInfo) {
            var Con = '';
            var FieldAfterLabel = that.getFieldAfterLabel['All'];
            Con +=  this.FieldLabel(FieldInfo.columns,FieldInfo.column_label) +
                    //'<div class="FieldAfterLabel">' + FieldAfterLabel + '</div>' +
                    '<div class="EditFieldIcon ld-fonticon ld-fonticon-edit"></div>';
            return Con;
        },
        Variable : function (FieldInfo) {
            var Con = '';
            Con +=  this.FieldLabel(FieldInfo.var_name,FieldInfo.display_name) +
                    '<div class="SortFieldIcon ld-category-icon ld-category-drag drag-handle"></div>' +
                    '<div class="DelFieldIcon DelIcon"></div>' +
                    '<div class="EditFieldIcon EditVariable ld-fonticon ld-fonticon-edit"></div>';
            return Con;
        },
        /**
         * 字段名Html，格式：字段名 [ 显示名 ]
         * @param {string} var_name 字段名
         * @param {string} display_name 显示名
         * @return {string} 字段名Html
         */
        FieldLabel : function (var_name,display_name) {
            return  '<span class="FieldLabel">' +
                        '<span class="FieldVarName">' + var_name + '</span>' +
                        '<span class="FieldDisplayName"> [ ' + display_name + ' ] </span>' +
                    '</span>'
        }
    }

    this.FieldHtml_FunList = Object.assign(this.FieldHtml_FunList,{
        /**
         * - 根据拖动字段的信息产生对应的字段信息区块，SQL统计图拖动逻辑不同需要重写覆盖
         * @param {Object} DragFieldInfo 拖动字段的信息
         * @return {string} 字段信息区块Html字符串
         */
        AxisFieldBlock : function (DragFieldInfo) {
            var FieldId = DragFieldInfo.FieldId;
            var FieldBlockHtml = '';
            FieldBlockHtml += '<div class="AxisFieldBlock" fieldid="'+DragFieldInfo.id+'" fieldindex="'+DragFieldInfo.fieldindex+'">' ;
            // console.log(DragFieldInfo);
            var FieldBlockFields = that.BlockFieldList[FieldId+'FieldBlock'];
            DragFieldInfo.FieldBlockFields = FieldBlockFields;
            FieldBlockHtml += that.getFieldListHtml(FieldBlockFields);
            FieldBlockHtml += '</div>';
            return FieldBlockHtml;
        },
        /**
         * 托拽后字段名显示行的Html内容，SQL统计图拖动逻辑不同需要重写覆盖
         * @param DragFieldInfo 拖动字段的信息
         */
        DragField : function (DragFieldInfo) {
            return  '<div class="AxisDragField " fieldid="'+DragFieldInfo.id+'" fieldindex="'+DragFieldInfo.fieldindex+'">' +
                        DragFieldInfo.columns +
                    '</div>';
        },
    });

    this.AfterShowEvent = function () {

    }

}
SqlChartSetHtml.prototype = Object.create(cls_ChartSetHtml.prototype);
SqlChartSetHtml.prototype.constructor = SqlChartSetHtml;