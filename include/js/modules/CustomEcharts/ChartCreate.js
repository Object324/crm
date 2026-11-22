function ChartCreate(){
    var that = this;
    /** 用于Ajax请求的模块名 */
    this.pageto_module = 'ReportAnalysis';  //默认报表分析模块
    /** 用于Ajax请求的文件名 */
    this.AjaxFileName = 'SelfDefinedReport';
    /** 新建、编辑的弹窗对象 */
    this.Popupobj = null;
    /** 搜索字段的结果数组 */
    this.SeachResult = [];
    /** 搜索字段时，当前字段在搜索结果数组中的索引 */
    this.SeachResultIndex = 0;
    /** 搜索字段的搜索内容 */
    this.SeachValue = '';
    /** 展开定时器（用于区块的展开收起） */
    this.expandTimer = null;
    /** 收起定时器（用于区块的展开收起） */
    this.collapseTimer = null;
    /** 区块的展开收起的步长 */
    this.stepHeight = {
        /** 字段区块的展开收起步长 */
        ModuleField : 40,
        /** 设置区块的展开收起步长 */
        SetBlock : 25,
    };
    /** 拖动字段的信息 */
    this.DragFieldInfo = {};
    /** 拖动权限，阻止不符合类型字段的拖动 */
    this.DragPermit = false;
    /** 预览权限，判断当前状态是否可以触发预览 */
    this.PreviewSwitch = false;
    /** 预览应用的防抖延迟 */
    this.PreviewDelay = 200;
    /** 正常状态预览防抖延迟 */
    this.SimplePreviewDelay = 200;
    /** 编辑初始状态预览防抖延迟(避免编辑界面的短时间内多次触发预览) */
    this.EditPreviewDelay = 500;
    /** 定时器标识，用于函数防抖 */
    this.timer = null;
    /** 右侧图表类型快捷导航栏的定时器，用于第二类型区块的显示隐藏 */
    this.ChartTypeSecDivTimer = [];
    /** 标识在何处进入的编辑界面，用于详情页编辑后对详情页进行刷新 */
    this.frompage = 'fromlist';
    /** 标识图标区块是否绑定了点击事件，例如对其方式、主题等设置字段 */
    this.IconBlockEventBind = {};
    /** 拖动的来源，用于区分字段拖动是否时交换顺序 */
    this.DragFrom = '';

    /** 设置统计图初始化(类型确定后的初始化) */
    this.init = function(){
        that.PreviewSwitch = false;
        that.getChartTypeObjFun();   //柱狀圖  饼图等对象,ChartParent.js
        var ChartSetHtmlObj = that.getChartSetHtmlObj();//new cls_ChartSetHtml();
        var Options = {
            ChartObj : that.ChartTypeObj,
            ChartCreateObj : that,
        };
        ChartSetHtmlObj.init(Options);
        ChartSetHtmlObj.Show();
        that.ChartSetHtmlObj = ChartSetHtmlObj;
        //设置信息初始化（包括双向绑定、事件绑定等）
        that.ChartSetInit();
    }

    /** 统计图设置界面生成的对象 */
    this.getChartSetHtmlObj = function () {
        return new cls_ChartSetHtml();
    }

    /** 选择图表类型界面的事件集合 */
    this.ChartTypeEventArrList = {
        /**
         * 新建统计图时，选择图表类型界面的事件列表
         * 包括导航栏点击、图表类型点击、上一步点击、下一步点击、保存点击
         */
        create : {
            ChartTypeNav : {
                Selector : '#left_chart_nav li',
                EventType : 'click',
            },
            ChartTypeObj : {
                Selector : '#chart_type_lists .chart-type-one',
                EventType : 'click',
            },
            NextStep : {
                Selector : '#next',
                EventType : 'click',
            },
            BackStep : {
                Selector : '#astep',
                EventType : 'click',
            },
            Save : {
                Selector : '#save',
                EventType : 'click',
            },
        },
        /**
         * 编辑统计图时，选择图表类型界面的事件列表
         * 包括导保存点击
         */
        edit : {
            Save : {
                Selector : '#save',
                EventType : 'click',
            },
        },
    }

    /** 选择图表类型界面的事件（新增、编辑事件不同） */
    this.SetChartTypeEvent = function () {
        //mode，标识新建和编辑
        var mode = that.ChartSetArr.mode;
        var ObjEventArr = that.ChartTypeEventArrList[mode];
        that.SetObjEvent(ObjEventArr);
        that.AfterObjEventBind[mode]();
    }

    /** 新建、编辑统计图时需要执行的事件 */
    this.AfterObjEventBind = {
        /** 新建需要执行的事件 */
        create : function () {

        },
        /** 编辑统计图时需要执行的事件 (即自动触发下一步、并进行初始化相关事件) */
        edit : function () {
            var NextObj = ld('#'+that.Popupobj.divid+' #next');
            var AstepObj = ld('#'+that.Popupobj.divid+' #astep');

            //编辑时会在短时间内多次触发预览,设置一个较高的防抖延迟
            that.PreviewDelay = that.EditPreviewDelay;

            //维度数量修改
            //that.ChartTypeObj.BlockFieldList.ConfigX[0].DefaultSetNum = that.ChartSetInfo.AxisFields.XAxis.length === 1 ? 'One' : 'Two';

            //触发下一步
            that.SetObjEvent_Fun.NextStep_click(NextObj);

            //删除上一步下一步的按钮
            NextObj.remove();
            AstepObj.remove();

            //处理已有字段和排序设置的添加
            that.AddSetInfo();

            //执行编辑事件
            that.ExcuteEditEvnet();
        },
    }

    /** 执行编辑事件、用于子类使用 */
    this.ExcuteEditEvnet = function () {
        
    }

    /** (编辑时)添加已设置的信息展示在页面上 */
    this.AddSetInfo = function () {
        //添加已有的字段设置信息
        that.AddAxisFieldSetInfo();
        //添加已有的排序设置信息
        //that.AddSeqSetInfo();
    };

    /** (编辑时)添加字段添加事件，待字段请求返回后执行 */
    this.AddAxisFieldSetInfo = function () {
        var AxisFields = that.ChartSetInfo.AxisFields;
        // console.log('ready')
        ld.each(AxisFields,function (AxisType,FieldsList) {
            ld.each(FieldsList,function (Index,FieldInfo) {
                var FieldModule = that.getFieldModule(FieldInfo);
                var CardOption = {
                    'AxisType' : AxisType,
                    'Index' : Index,
                };
                //添加字段信息须在模块字段返回后执行，故加入AfterShowTask中等待执行
                var EventItem = {
                    TaskType : 'AddFieldsCard',
                    TaskFun : that.AddFieldsCard,
                    TaskParams : {
                        'FieldInfo' : FieldInfo,
                        'CardOption' : CardOption,
                    },
                };
                if(!that.ChartSetHtmlObj.AfterShowTask.AddFieldsCard[FieldModule])
                    that.ChartSetHtmlObj.AfterShowTask.AddFieldsCard[FieldModule] = [];
                that.ChartSetHtmlObj.AfterShowTask.AddFieldsCard[FieldModule].push(EventItem);
            });
        });
    }

    /**
     * 获取字段的模块（主要用于SQL统计图使用）
     * @param {object} FieldInfo 字段信息对象
     */
    this.getFieldModule = function (FieldInfo) {
        var FieldValue = FieldInfo.FieldValue;
        FieldInfo.FieldModule = FieldValue.split(':')[3].split('_')[0];
        return FieldInfo.FieldModule;
    }

    /**
     * (编辑时)添加已设置的字段信息，模拟拖动添加卡片
     * @param {object} Option 参数对象
     * @param {object} Option.FieldInfo 字段信息对象
     * @param {object} Option.CardOption 卡片信息(卡片类型和位置索引)
     */
    this.AddFieldsCard = function (Option) {
        var FieldInfo = Option.FieldInfo;
        var CardOption = Option.CardOption;
        var AxisType = CardOption.AxisType;
        var Index = CardOption.Index;
        var CardSelector = ' #' + AxisType + ' .AxisFieldEmpty:eq(' + Index + ')';
        var EventInfo = that.getFieldDragEventArr()[AxisType + 'Field'];
        //that.ModuleFieldDragEvent(CardSelector,EventInfo);
        // console.log('模拟托拽');
        //模拟托拽
        var ItemObj = that.getFieldItemObj(FieldInfo);
        if(ItemObj.length > 0){
            var SortableStartEvent = {
                from : ItemObj.parent().get(0),
                item : ItemObj.get(0),
            }
            that.getDragFieldInfo(SortableStartEvent);
            var DragObj = that.PopupJqObj.find(CardSelector).get(0);
            var SortableAddEvent = {
                to : DragObj,
                clone : ItemObj.get(0),
            };
            that.DragPermit = true;
            that.DragFieldOnAddFun(DragObj,SortableAddEvent,EventInfo);
            that.DragPermit = false;
        } else {
            console.log(ItemObj);
            console.log('error');
        }
    }

    /**
     * 根据字段信息对象获取字段DOM对象的Jquery对象
     * @param FieldInfo 字段信息对象
     * @return {object} 字段DOM对象的Jquery对象
     */
    this.getFieldItemObj = function (FieldInfo) {
        var FieldModule = FieldInfo.FieldModule;
        var FieldName = FieldInfo.FieldValue.split(':')[2];
        var DragBlockObj = ld('#'+that.Popupobj.divid+' #Block_'+FieldModule);
        var ModuleFieldConObj = DragBlockObj.children('.ModuleFieldCon[block_id^='+FieldModule+']');
        var ItemObj = ModuleFieldConObj.children('.Field[fieldname='+FieldName+']');
        return ItemObj;
    }

    this.AddSeqSetInfo = function () {

    }
    //设置同环比是否显示--根据统计维度的字段类型显示隐藏：date datetime 显示
    this.setCompareSelectIsShow = function(){
        var ChartSetInfo = that.ChartSetInfo;
        var XAxis = ChartSetInfo.AxisFields.XAxis;

        //zxm @date:2024/12/9 @reason: 两个统计维度不应该显示同环比
        var fieldrowObj = that.PopupJqObj.find('[name=CompareSelect]').parents('.FieldRow');
        fieldrowObj.hide();
        if(XAxis && XAxis.length>=2){
            //两个统计维度不显示这个同环比设置
            fieldrowObj.hide();
        }else if(XAxis && XAxis.length==1){
            var TimeMethod = XAxis[0]['TimeMethod'];
            var BigType = XAxis[0]['BigType'];
            if(BigType=='date'||BigType=='datetime'){
                fieldrowObj.show();
            }else{
                fieldrowObj.hide();
            }
        }
    }
    /**
     * 单个DOM对象事件的信息对象
     * @typedef ObjEventInfo
     * @property Selector - 对象选择器
     * @property EventType - 事件类型
     */
    /**
     * - 根据ObjIdArr数组，对界面中的Dom元素进行事件绑定
     * - 事件方法名为 键名_事件类型
     * - 方法接受唯一参数即DOM对象的Jquery对象
     * @param {Object.<ObjEventInfo>} ObjEventArr 对象事件数组(键名为ObjEventId，键值为包括选择器、事件类型的对象)
     */
    this.SetObjEvent = function (ObjEventArr) {
        var Popupobj = that.Popupobj;
        //ObjEventArr，键名为ObjEventId，键值为包括选择器、事件类型、事件方法名的对象
        ld.each(ObjEventArr,function (ObjEventId,ObjEventInfo) {
            var Obj = ld('#'+Popupobj.divid+' '+ObjEventInfo['Selector']);
            var Fun_Name = ObjEventId + '_' + ObjEventInfo['EventType'];
            if(Obj.length>0 && that.SetObjEvent_Fun[Fun_Name]){
                var EventType = ObjEventInfo['EventType'];
                Obj.unbind(EventType).bind(EventType,function (){
                    var JqueryObj = ld(this);
                    that.SetObjEvent_Fun[Fun_Name](JqueryObj);
                });
            } else {
                console.log('Bind Error');
                console.log(Obj);
                console.log(Fun_Name);
                console.log(that.SetObjEvent_Fun[Fun_Name]);
            }
        });
    }

    /** Dom对象事件的方法集合 */
    this.SetObjEvent_Fun = {
        /** 图表大类导航栏点击事件 */
        ChartTypeNav_click : function (JqueryObj) {
            ld(JqueryObj).siblings('li').removeClass('active');
            ld(JqueryObj).addClass('active');
        },
        /** 图表类型点击事件 */
        ChartTypeObj_click : function (JqueryObj) {
            var ChartType = ld(JqueryObj).attr('data-name');//图表类型
            that.ChartSetInfo.chart_type = ChartType;
            //触发左侧导航栏点击
            var ParentType = ld(JqueryObj).attr('parentkey');
            var NavLiObj = ld('#'+that.Popupobj.divid+' #left_chart_nav li'+'[parentkey='+ParentType+']');
            NavLiObj.trigger('click',NavLiObj);
            if(that.ChartSetInfo.OldChartType != that.ChartSetInfo.chart_type) {
                that.ChartSetInfo.AxisFields.XAxis = [];
                that.ChartSetInfo.AxisFields.YAxis = [];
            }
            that.AfterSelChartType()
            //触发下一步点击事件
            this.NextStep_click(ld('#'+that.Popupobj.divid+' #next'));
        },
        /** 下一步点击事件 */
        NextStep_click : function (JqueryObj) {
            var ChartType = that.ChartSetInfo.chart_type;
            if(ChartType === undefined || ChartType === null){
                var comfirm_str = arrJsPopLabel['ChooseChartType']; //'请先选择图表类型';
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", comfirm_str);
            }
            else{
                that.init();
                ld(JqueryObj).hide();
                ld(JqueryObj).siblings('.ld-button').show();
            }
        },
        /** 上一步点击事件 */
        BackStep_click : function (JqueryObj) {
            var ContentObj = ld('#'+that.Popupobj.divid).find(' #'+that.Popupobj.divid+'_scroll');
            ContentObj.children('div').css('display','none');
            ContentObj.children('div.main_grid').css('display','block');
            ld(JqueryObj).hide();
            ld(JqueryObj).siblings('#save').hide();
            ld(JqueryObj).siblings('#next').show();
            that.ChartSetInfo.OldChartType = that.ChartSetInfo.chart_type;
        },
        /** 保存点击事件 */
        Save_click : function (JqueryObj) {
            that.SaveChartSet();
        },

        /** 主模块点击事件 */
        /*
        MainModule_click : function (JqueryObj) {
            //绑定模块点击事件
            var Selector = ' #' + ld(JqueryObj).attr('id') + ' .ModuleOptionBefore .ModuleOption div';
            ld(JqueryObj).attr('status','expand');

            var EventItem = {};
            EventItem['ModuleOption'] = {
                Selector : Selector,
                EventType : 'click',
            };
            that.SetObjEvent(EventItem);
            var OptionDiv = ld(JqueryObj).children(' .ModuleOptionBefore');
            if(! OptionDiv.is(':visible')){
                OptionDiv.unbind('blur').bind('blur',function (){
                    setTimeout(function(){
                        //火狐的focus只能在 blur之前，故增加setTimeout使判断生效
                        if(!ld(JqueryObj).is(':focus')){
                            OptionDiv.hide();
                            ld(JqueryObj).attr('status','collapse');
                        }
                    },0);
                });
                OptionDiv.show();
                OptionDiv.focus();
            } else {
                OptionDiv.hide();
                ld(JqueryObj).attr('status','collapse');
            }
            //ld(JqueryObj).children(' .ModuleOptionBefore')  .css('display','unset');
        },
         */
        /** 相关模块点击事件 */
        /*
        RelModule_click :function (JqueryObj) {
            this.MainModule_click(JqueryObj);
        },
         */
        /** 模块列表点击事件 */
        /*
        ModuleOption_click : function (JqueryObj) {
            var ModuleSel = ld(JqueryObj).attr('value');
            var ModuleSelLabel = ld(JqueryObj).text();
            var ConObj = ld(JqueryObj).parent().parent('.ModuleOptionBefore');
            ConObj.siblings('.ModuleOptionValue').text(ModuleSelLabel);
            var ModuleSelId = ConObj.parent().attr('id');
            //其他处理
            this.ModuleOption_Fun[ModuleSelId](JqueryObj,ConObj);
            that.SetObjEvent_Fun[ModuleSelId+'_change'](ModuleSel);
        },
         */
        /*
        ModuleOption_Fun : {
            /** 主模块列表点击事件(单选)
            MainModule : function (JqueryObj,ConObj) {
                ld(JqueryObj).siblings().removeAttr('selected');
                ld(JqueryObj).attr('selected','');
            },
            /** 相关模块列表点击事件(多选)
            RelModule : function (JqueryObj,ConObj) {
                that.RelModuleShow = false;
                if(ld(JqueryObj).attr('selected')){
                    ld(JqueryObj).removeAttr('selected');
                    ld('#'+that.Popupobj.divid+' #CustomEchartsSet #Block_'+ld(JqueryObj).attr('value')).html('');
                    var NewText = ConObj.children('.ModuleOption').find('div[selected]:eq(0)').text();
                    ConObj.siblings('.ModuleOptionValue').text(NewText);
                }
                else{
                    ld(JqueryObj).attr('selected','');
                    that.RelModuleShow = true;
                }
            },
        },
        */
        /** 主模块change事件 */
        MainModule_change : function (Module) {
            that.ChartSetHtmlObj.MainModule = that.ChartSetArr.ModuleArr[Module];
            that.ChartSetInfo.mainmodule = Module;
            //重新渲染模块字段区域等
            that.ChartSetHtmlObj.MainModule_change();
        },
        /** 相关模块change事件 */
        /*
        RelModule_change : function (Module) {
            if(that.RelModuleShow){
                that.ChartSetHtmlObj.RelModuleSelArr[Module] = that.ChartSetArr.RelModuleArr[Module];
                //重新渲染模块字段区域等
                that.ChartSetHtmlObj.RelModule_change(Module);
            }
        },
         */
        /** 字段搜索事件 */
        FieldSearch_keyup : function (JqueryObj) {
            var event = event || window.event;
            var SearchValue = ld(JqueryObj).val();
            var ScrollObj = ld('#'+that.Popupobj.divid+' .ModuleField_Scroll');
            var Style,Options;
            if(event.keyCode === 13 || event.type === "click"){
                if(SearchValue !== '' && SearchValue !== that.SeachValue){
                    //搜索初始化
                    that.SeachResultIndex = 0;
                    that.SeachResult = [];
                    //查找元素
                    var AllFieldsBlockObj = ScrollObj.find('.ModuleFieldBlock');
                    var FieldsSeq = 0;  //用于滚动定位
                    ld.each(AllFieldsBlockObj,function (Blockindex,FieldsBlockObj) {
                        var ModuleFields = ld(FieldsBlockObj).find('div.Field');
                        ld.each(ModuleFields,function (Fieldindex,FieldObj) {
                            var FieldJqObj = ld(FieldObj);
                            //确保转化为 string 类型，避免将字段名设为数字的情况
                            var FieldLabel = FieldJqObj.data('label').toString();
                            if(FieldLabel.includes(SearchValue)){
                                FieldObj.FieldsSeqTop = (FieldsSeq + Fieldindex) * 40 + Blockindex * 5;
                                that.SeachResult.push(FieldObj);
                                var highLightTxt = '<span class="ld-Highlight">' + SearchValue + '</span>';
                                var reg = new RegExp(SearchValue, "g");
                                var newFieldLabel = FieldLabel.replace(reg, highLightTxt);
                                FieldJqObj.find('.FieldLabelSpan').html(newFieldLabel);
                                FieldJqObj.data('highlight',true);
                            } else {
                                if(FieldJqObj.data('highlight') === true){
                                    FieldJqObj.find('.FieldLabelSpan').html(FieldLabel);
                                }
                            }
                        });
                        FieldsSeq += 1 + ModuleFields.length;
                    });
                    //搜索结果为空
                    if(that.SeachResult.length === 0)
                        return false;
                }
                that.SeachValue = SearchValue;
                var Top = that.SeachResult[that.SeachResultIndex].FieldsSeqTop;
                Style = { scrollTop: Top};
                Options = { speed : Math.abs(Top - ScrollObj[0].scrollTop) * 10 };
                ScrollObj.animate(Style,Options);
                that.SeachResultIndex += 1;
                if(that.SeachResultIndex >= that.SeachResult.length)
                    that.SeachResultIndex = 0;
            } else if(SearchValue === ''){
                var FieldObjList = ScrollObj.find('div.Field');
                ld.each(FieldObjList,function (index,FieldObj) {
                    var FieldJqObj = ld(FieldObj);
                    if(FieldJqObj.data('highlight') === true){
                        FieldJqObj.find('.FieldLabelSpan').html(FieldJqObj.data('label'));
                    }
                })
                that.SeachValue = SearchValue;
                that.SeachResultIndex = 0;
                that.SeachResult = [];
                Style = { scrollTop: 0};
                Options = { };
                ScrollObj.animate(Style,Options);
            }
        },
        /** 字段搜索图标点击事件 */
        FieldSearchIcon_click : function (JqueryObj) {
            var InputObj = ld(JqueryObj).siblings('input');
            this.FieldSearch_keyup(InputObj);
        },
        /** 模块字段区块头部点击事件(展开收事件) */
        ModuleFieldHead_click : function (JqueryObj) {
            var Block_Id = ld(JqueryObj).attr('Block_Id');
            var ConObj = ld(JqueryObj).next('[Block_Id='+Block_Id+']');//siblings('[Block_Id='+Block_Id+']');
            var BlockSatus = ld(JqueryObj).attr('blocksatus');
            this.ExpandingAndCollapse[BlockSatus](JqueryObj,ConObj,Block_Id,'ModuleField');
            var event = event || window.event;
            event.stopPropagation();
        },
        /** 展开收起事件集合 */
        ExpandingAndCollapse :  {
            /**
             * - 展开状态，进行收起
             * @param HeadObj   区块头部Jquery对象
             * @param ConObj    区块内容Jquery对象
             * @param Block_Id  区块ID
             * @param BlockType 区块展开收起的状态
             */
            expand : function (HeadObj,ConObj,Block_Id,BlockType) {
                HeadObj.attr('blocksatus','collapse');
                clearInterval(that.expandTimer);
                that.expandTimer = null;
                var height = ConObj[0].offsetHeight;
                //初次收起记录最大高度
                that.ChartSetHtmlObj.BlockScrollHeight[Block_Id] = height;
                that.collapseTimer = setInterval(() => {
                    height -= that.stepHeight[BlockType];
                    if (height <= 0) {
                        // 高度小于等于 0 代表动画完成，将数据进行重置
                        clearInterval(that.collapseTimer);
                        that.collapseTimer = null;
                        ConObj.css('height',0);
                        return false;
                    }
                    ConObj.css('height',height + 'px');
                }, 10);
            },
            /**
             * - 收起状态，进行展开
             * @param HeadObj   区块头部Jquery对象
             * @param ConObj    区块内容Jquery对象
             * @param Block_Id  区块ID
             * @param BlockType 区块展开收起的状态
             */
            collapse : function (HeadObj,ConObj,Block_Id,BlockType) {
                HeadObj.attr('blocksatus','expand');
                clearInterval(that.collapseTimer);
                that.collapseTimer = null;
                // 获取元素当前高度
                var height = ConObj[0].offsetHeight;
                ConObj.css('height',height + 'px');
                that.expandTimer = setInterval(() => {
                    height += that.stepHeight[BlockType];
                    if (height >= that.ChartSetHtmlObj.BlockScrollHeight[Block_Id]) {
                        // 当前高度如果已经到了元素的实际高度，就要清除定时器
                        clearInterval(that.expandTimer);
                        that.expandTimer = null;
                        //ConObj.css('height',that.ChartSetHtmlObj.BlockScrollHeight[Block_Id]);
                        //动画结束后改为auto，避免元素放入时无法撑开父元素
                        ConObj.css('height','auto');
                        return false;
                    }
                    ConObj.css('height',height + 'px');
                }, 10);
            },
        },
        /** 设置区块点击事件(展开收起) */
        SetBlockTitle_click : function (JqueryObj) {
            var Block_Id = ld(JqueryObj).attr('Block_Id');
            var ConObj = ld(JqueryObj).next('[Block_Id='+Block_Id+']');
            var BlockSatus = ld(JqueryObj).attr('blocksatus');
            this.ExpandingAndCollapse[BlockSatus](JqueryObj,ConObj,Block_Id,'SetBlock');
            var event = event || window.event;
            event.stopPropagation();
        },
        /** 设置页签点击事件，切换设置页签 */
        SetType_click : function (JqueryObj) {
            ld(JqueryObj).addClass('CurSetType');
            ld(JqueryObj).siblings().removeClass('CurSetType');
            var SetType = ld(JqueryObj).attr('SetType');
            var ChartSetConObj = ld(JqueryObj).parent().siblings('.ChartSetCon');
            var SetJqueryObj = ChartSetConObj.children('.SetTypeBlock');
            var CurTypeObj = ChartSetConObj.children('.'+SetType+'Set');
            if(CurTypeObj.length > 0){
                SetJqueryObj.css('display','none');
                CurTypeObj.css('display','unset');
            } else {
                var SetTypeHtml = that.ChartSetHtmlObj.getSetTypeBlockHtml(SetType);
                SetJqueryObj.css('display','none');
                ChartSetConObj.append(SetTypeHtml);
            }
        },
        /** 统计维度数量点击事件 */
        XAxisNum_click : function (JqueryObj) {
            var FieldEmptyObj = ld('#'+that.Popupobj.divid+' #XAxis .AxisFieldEmpty ');
            var SetNum = ld(JqueryObj).attr('SetNum');
            ld(JqueryObj).parent().attr('SetNum',SetNum);
            var FunName = SetNum + '_' + FieldEmptyObj.length;
            this.XAxisNum_fun[FunName](FieldEmptyObj);
            
            //zxm @date:2024/12/9 @reason: 设置同环比是否显示
            that.setCompareSelectIsShow();

        },
        //zxm @date:2024/11/28 @reason: 时间统计方式 事件
        TimeMethod_change : function () {
            var XAxis = that.ChartSetInfo.AxisFields.XAxis;
            var TimeMethod = XAxis[0]['TimeMethod'];
            var CompareSelectOption = that.CompareSelectOption[TimeMethod];
            var optionHtml = '';
            ld.each(CompareSelectOption,function (index,OptionInfo) {
                var Label = OptionInfo['Label'];
                if(OptionInfo.labelbol)
                    Label = arrJsPopLabel[OptionInfo.labelbol];
                optionHtml += '<option value="'+OptionInfo['Value']+'">' +
                    Label +
                    '</option>';
            });
            that.PopupJqObj.find('[name=CompareSelect]').html(optionHtml);//将所有同环比的下拉框字段改变
        },
        XAxisNum_fun : {
            One_1 : function (FieldEmptyObj) {

            },
            One_2 : function (FieldEmptyObj) {
                ld(FieldEmptyObj[1]).css('display','none');
                ld(FieldEmptyObj[1]).remove();
                that.ChartSetInfo.AxisFields.XAxis.splice(1,1);
                that.ChartPreview();
            },
            Two_1 : function (FieldEmptyObj) {
                var FieldInfo = that.ChartTypeObj.BlockFieldList.ConfigX[0];
                var FieldEmptyHtml = that.ChartSetHtmlObj.FieldHtml_FunList.AxisFieldEmpty(FieldInfo);
                FieldEmptyObj.after(FieldEmptyHtml);
                var Selector = ' #XAxis .AxisFieldEmpty:eq(1)';
                that.ModuleFieldDragEvent(Selector, that.getFieldDragEventArr().XAxisField);
            },
            Two_2 : function (FieldEmptyObj) {
                ld(FieldEmptyObj[1]).css('display','flex');
            },
        },
        /** 新增排序点击事件 */
        NewSeq_click : function (JqueryObj) {
            var SeqBlockCon = ld(JqueryObj).parents('.SetBlockContent')
            var SeqSetObj = SeqBlockCon.find(' #SeqSet');
            var Index = 0;
            Index = SeqSetObj.find('.SeqSetBlock').length;
            var NewSeqBlockHtml = that.ChartSetHtmlObj.FieldHtml_FunList.SeqBlock(Index, {});
            SeqSetObj.append(NewSeqBlockHtml);
            var NewSeqBlockObj = SeqSetObj.find('.SeqSetBlock:eq('+Index+')');
            that.SetSeqBlockEvent(NewSeqBlockObj,{});
            that.SetSeqBlockDataBind(Index,NewSeqBlockObj);
        },
        /** 坐标轴设置区块切换X、Y点击事件 */
        AxisTab_click : function (JqueryObj) {
            JqueryObj = ld(JqueryObj);
            JqueryObj.addClass('CurAxisTab');
            JqueryObj.siblings().removeClass('CurAxisTab');
            var CurAxisTab = JqueryObj.attr('axisname');
            var CurAxisTabConObj = JqueryObj.parents('.SetBlockContent').find('#AxisTabBlock'+CurAxisTab);
            CurAxisTabConObj.show();
            CurAxisTabConObj.siblings('.AxisTabBlock').hide();
        },
        /** 对齐方式移入事件(进行双向绑定) */
        AlignSet_mouseenter : function (JqueryObj) {
            this.IconBlockBind(JqueryObj);
        },
        /** 主题设置移入事件(进行双向绑定) */
        ThemeSet_mouseenter : function (JqueryObj) {
            this.IconBlockBind(JqueryObj);
        },
        /** 图例位置移入事件(进行双向绑定) */
        LegendLocate_mouseenter : function (JqueryObj) {
            this.IconBlockBind(JqueryObj);
        },
        /** 报表位置移入事件(进行双向绑定) */
        ReportStyle_mouseenter : function (JqueryObj) {
            this.IconBlockBind(JqueryObj);
        },
        /** 图标区块的双向绑定 */
        IconBlockBind : function (IconBlockObj) {
            IconBlockObj = ld(IconBlockObj);
            var BlockId = IconBlockObj.attr('id');
            if(that.IconBlockEventBind['Bind_'+BlockId] === true)
                return false;
            that.IconBlockEventBind['Bind_'+BlockId] = true;
            var IconObjList = IconBlockObj.children('[iconid]');
            IconObjList.unbind('click').bind('click',function () {
                var IconId = ld(this).attr('IconId');
                IconBlockObj.attr(BlockId,IconId);
                if(that.SetObjEvent_Fun.IconBlockClick[BlockId])
                    that.SetObjEvent_Fun.IconBlockClick[BlockId](IconBlockObj,IconId);
                //尝试预览
                that.ChartPreview();
            });
        },
        /** 图表区块字段点击后的特殊事件 */
        IconBlockClick : {
            /** 图例选择”无“时隐藏图例的其他设置 */
            LegendLocate : function (IconBlockObj,IconId) {
                var OtherSetFieldObj = IconBlockObj.parents('.FieldBlock').siblings();
                OtherSetFieldObj.show();
                if(IconId === 'None'){
                    OtherSetFieldObj.hide();
                }
            }
        },
        /** 高级查询条件设置图标的点击事件 */
        OtherCondition_click : function (JqueryObj) {
            var OtherCondition = that.ChartSetInfo.OtherCondition;
            OtherCondition.computemodule = that.ChartSetHtmlObj.MainModule.modulename;
            getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
                var SetOtherConditionsObj = new SetOtherConditions();
                SetOtherConditionsObj.SetDirDataObj(OtherCondition);
                SetOtherConditionsObj.addTaskAfterOkfun(that.ChartPreview,{});
                SetOtherConditionsObj.fun_other_conditions();
            });
        },
        /** 右侧图表类型点击事件 */
        ChartSecType_click : function (JqueryObj) {
            var SecondType = JqueryObj.find('.ChartImgDiv').attr('ChartType');
            //切换类型
            that.ChangeChartType(SecondType);
        },
        ChartTypeDivHover_mouseenter : function (JqueryObj) {
            clearTimeout(that.ChartTypeSecDivTimer[JqueryObj.index()]);
            JqueryObj.find('.ChartTypeSecDiv').css('display','block');
        },
        ChartTypeSecDivHover_mouseenter : function (JqueryObj) {
            clearTimeout(that.ChartTypeSecDivTimer[JqueryObj.index()]);
            JqueryObj.css('display','block');
        },
        ChartTypeDivLeave_mouseleave : function (JqueryObj) {
            var rect = JqueryObj.get(0).getBoundingClientRect();
            var isOutElement = (
                event.clientX <= rect.left ||
                event.clientX >= rect.right ||
                event.clientY <= rect.top
            );
            if(isOutElement)
                JqueryObj.find('.ChartTypeSecDiv').css('display','none');
            else
                that.ChartTypeSecDivTimer[JqueryObj.index()] = setTimeout(() => {
                    JqueryObj.find('.ChartTypeSecDiv').css('display','none');
                }, 200);
        },
        ChartTypeSecDivLeave_mouseleave : function (JqueryObj) {
            JqueryObj.css('display','none');
        },
    }

    /** 根据图表类型获取图表对象 */
    this.getChartTypeObjFun = function () {
        var ChartType = that.ChartSetInfo.chart_type;
        that.ChartTypeObj = that.getChartTypeObj[ChartType]();
    }

    /** 工厂模式：动态生成不同类的对象 目前所有图表类均位于文件ChartParent.js中 */
    this.getChartTypeObj = {
        line : function () {
            return new Chart_line();//Chartparent.js
        },
        multiple_line : function () {
            return new Chart_multiple_line();//Chartparent.js
        },
        bar : function () {
            return new Chart_bar();//Chartparent.js
        },
        multiple_bar : function () {
            return new Chart_multiple_bar();//Chartparent.js
        },
        bar_stack : function () {
            return new Chart_bar_stack();//Chartparent.js
        },
        line_bar : function () {
            return new Chart_line_bar();//Chartparent.js
        },
        simple_strip : function () {
            return new Chart_simple_strip();//Chartparent.js
        },
        multiple_strip : function () {
            return new Chart_multiple_strip();
        },
        stack_strip : function () {
            return new Chart_stack_strip();
        },
        pie : function () {
            return new Chart_pie();
        },
        solid_pie : function () {
            return new Chart_solid_pie();
        },
        rose_pie : function () {
            return new Chart_rose_pie();
        },
        nesting_pie : function () {
            return new Chart_nesting_pie();
        },
        funnel : function () {
            return new Chart_funnel();
        },
        triangle : function () {
            return new Chart_triangle();
        },
        bowls : function () {
            return new Chart_bowls();
        },
        basic_scatter : function () {
            return new Chart_basic_scatter();
        },
        multiple_dimension : function () {
            return new Chart_multiple_dimension();
        },
        //自定义统计图 旭日图 由一个字段找上级级联字段来生成
        simple_sunburst : function () {
            return new Chart_simple_sunburst();
        },
        //SQL统计图  旭日图 由2个统计维度来生成
        multiple_sunburst : function () {
            return new Chart_multiple_sunburst();
        },
    }

    /** 工厂模式：动态生成不同类的对象 目前所有图表类均位于文件ChartParent.js中 */
    this.AfterSelChartType = function () {

    }

    /** 设置信息初始化 */
    this.ChartSetInit = function () {
        that.DataBind();
        that.SetChartSetEvent();
        //window.ChartCreateObj = that;
    }

    /** 设置信息的双向绑定 */
    this.DataBind = function () {
        //主要设置信息的双向绑定
        that.SetChartSetInfoDataBind();

        //排序信息的双向绑定
        that.SeqDataBind();
    }
    
    this.SeqDataBind = function () {
        //排序区块初始绑定
        var SeqBlockCardObjList = ld('#'+that.Popupobj.divid+' #CustomEchartsSet #SeqSet .SeqSetBlock');
        ld.each(SeqBlockCardObjList,function (Index,SeqBlockCardObj) {
            that.SetSeqBlockDataBind(Index,SeqBlockCardObj);
        });
    }

    /** 设置信息初始化 */
    this.SetChartSetInfoDataBind = function () {
        var ChartSetInfo = that.ChartSetInfo;
        var ObjDataBindArr = that.ChartSetHtmlObj.ObjDataBindArr;
        that.DataHtmlBindObj = new DataHtmlBind();
        ld.each(ObjDataBindArr,function (BindType,BindArr) {
            ld.each(BindArr,function (ObjId,DataKeyStr) {
                var JqueryObj = ld('#'+that.Popupobj.divid+' #CustomEchartsSet #'+ObjId);
                if(JqueryObj.length > 0) {
                    var DataKeyArr = DataKeyStr.split('.');
                    var KeyNum = DataKeyArr.length;
                    var DataObj = ChartSetInfo;
                    for (var i = 0; i < KeyNum - 1; i++) {
                        DataObj = DataObj[DataKeyArr[i]];
                    }
                    var DataKey = DataKeyArr[KeyNum - 1];
                    var Data = DataObj[DataKey];
                    that.ModifyObjData(JqueryObj,Data);
                    that.ObjDataBind_Fun[BindType](JqueryObj, DataObj, DataKey);
                } else {
                    console.log('JqueryObj ' + JqueryObjId + ' is not exists');
                }
            });
        });
    }

    /**
     * 初始化DOM对象的值，与设置信息保持一致
     * @param JqueryObj DOM对象对应的Jquery对象
     * @param Data 需要修改的值
     */
    this.ModifyObjData = function (JqueryObj,Data) {
        var NodeName = JqueryObj[0].localName;
        var NodeType = '';
        if(NodeName === 'input')
            NodeType =  '_' + JqueryObj[0].type;
        var fun_name = 'modify_' + NodeName + NodeType;
        // console.log(JqueryObj);
        // console.log(fun_name);
        that.modify_fun[fun_name](JqueryObj,Data);
        //增加change事件以实时预览
        if(JqueryObj.attr('id') !== 'ChartName') {
            JqueryObj.bind('change', function () {
                if(JqueryObj.attr('id') == 'TimeMethod'){
                    //时间统计方式 改变事件 //zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
                    that.SetObjEvent_Fun.TimeMethod_change();
                    //BUG20241204-29 报表分析-新建统计图，主模块为“工作汇报列表”，排序字段为“创建时间”，排序设置的排序方式为“降序”，没起作用
                    that.ChageSeqFieldOption('XAxis');//更改排序字段的下拉框value
                }
                that.ChartPreview();
            });
        }
        else {
            //edit: xll 2024/07/31 BUG20240729-52 统计图名称修改为空不触发预览保存
            JqueryObj.bind('change', function () {
                if(JqueryObj.val() !== '' && JqueryObj.val() !== undefined)
                    that.ChartPreview();
            });
        }
    }

    /** 各Dom元素类型修改值的方法集合 */
    this.modify_fun = {
        modify_input_checkbox : function (JqueryObj,Data){
            var tmpvalue = (Data=='yes' || Data==true) ? true : false;
            ld(JqueryObj).prop('checked',tmpvalue);
        },
        modify_input_text : function (JqueryObj,Data){
            ld(JqueryObj).val(Data);
        },
        modify_textarea : function (JqueryObj,Data) {
            ld(JqueryObj).val(Data);
        },
        modify_select : function (JqueryObj,Data) {
            if(Data === undefined || Data === '')
                ld(JqueryObj).prop('selectedIndex',0);
            else
                ld(JqueryObj).val(Data);
        },
        modify_div : function (JqueryObj,Data) {
            var ObjId = ld(JqueryObj).attr('id');
            ld(JqueryObj).attr(ObjId,Data);
        }
    }

    /** 各Dom元素类型修改值的方法集合 */
    this.ObjDataBind_Fun = {
        Bind : function (JqueryObj, DataObj, DataKey) {
            that.DataHtmlBindObj.setDataBindByJqObj(JqueryObj, DataObj, DataKey);
        },
        //自定义双向绑定，目前用于图表点击类型的设置字段进行双向绑定
        SelfBind : function (JqueryObj, DataObj, DataKey) {
            var Fun_Key = that.SelfBindFunKeyArr[DataKey];
            var Fun_List = that.SelfBindFunList[Fun_Key];
            that.DataHtmlBindObj.setDataBindByJqObj_FunList(JqueryObj, DataObj, DataKey, Fun_List);
        },
    }

    /** 自定义双向绑定中数据键和方法列表键的对应关系数据 */
    this.SelfBindFunKeyArr = {
        AlignSet : 'IconDiv',
        ThemeSet : 'IconDiv',
        LegendLocate : 'IconDiv',
        ReportStyle : 'IconDiv',
    }

    /** 自定义双向绑定中方法列表的数组 */
    this.SelfBindFunList = {
        IconDiv : {
            getVal_Fun: function(JqueryObj) {
                var ObjId = ld(JqueryObj).attr('id');
                return ld(JqueryObj).attr(ObjId);
            },
            setVal_Fun: function(JqueryObj, NewValue) {
                var ObjId = ld(JqueryObj).attr('id');
                ld(JqueryObj).attr(ObjId,NewValue);
            },
        },
    }

    /** 图表设置的事件(包括页面各OM对象事件、模块字段拖动事件、排序事件) */
    this.SetChartSetEvent = function () {
        var ObjEventArr = that.ChartSetHtmlObj.ObjEventArr;
        that.SetObjEvent(ObjEventArr);
        that.SetModuleFieldDragEvent();
        that.SetSeqEvent();
    }

    /**
     * 字段拖动事件的绑定
     * @param Selector 拖动区块Jquery选择器
     */
    this.FieldDragEvent = function (Selector) {
        var DragObjList = ld('#'+that.Popupobj.divid+Selector);
        ld.each(DragObjList,function (index,DragObj) {
            that.BindFieldDragEvent(DragObj);
        });
    }

    /**
     * 字段拖动事件的绑定
     * @param DragObj 拖动区块DOM对象
     */
    this.BindFieldDragEvent = function (DragObj) {
        Sortable.create(DragObj, {
            group: {
                name : 'FieldObj',
                pull : 'clone',
            },
            draggable: '.Field',
            animation: 150,
            sort: false,
            onStart : function (evt) {
                that.getDragFieldInfo(evt);
                evt.preventDefault();
                evt.stopPropagation();
            },
            onEnd: function (evt) {

            },
            onMove : function (evt,originalEvent) {

            },
        });
    }

    /** 计算方法下拉框列表 */
    this.CalcMethodOption = {
        Count : [
            { Value : 'count', Label : arrJsPopLabel['Count'], },  //'计数'
            { Value : 'distinct_count', Label : arrJsPopLabel['UCount'], }, //'唯一计数'
        ],
        Sum : [
            { Value : 'sum', Label : arrJsPopLabel['Sum'], }, //'求和'
            { Value : 'avg', Label : arrJsPopLabel['Mean'], }, //'求均值'
            { Value : 'max', Label : arrJsPopLabel['MaximumValue'], }, //'最大值'
            { Value : 'min', Label : arrJsPopLabel['MinimumValue'], }, //'最小值'
        ],
    };
    /**
     * 同环比 下拉框选项
     */
    this.CompareSelectOption = {
        byYear : [
            { Value : 'cur', Label : arrJsPopLabel['THISPERIOD'] },  //'本期'
            { Value : 'prev', Label : arrJsPopLabel['PREVIOUSDATA']},  //'上期值' 环比上期
            { Value : 'prev_growth', Label : arrJsPopLabel['MOMgrowth']},  //'环比增长值'
            { Value : 'prev_growth_percent', Label :  arrJsPopLabel['MOMgrowthPercent']},  //'环比增长率'
        ],
        byQuarter:[
            { Value : 'cur', Label : arrJsPopLabel['THISPERIOD'] },  //'本期'
            { Value : 'prev', Label : arrJsPopLabel['PREVIOUSDATA']},  //'上期值' 环比上期
            { Value : 'prev_growth', Label : arrJsPopLabel['MOMgrowth'] },  //'环比增长值'
            { Value : 'prev_growth_percent', Label :  arrJsPopLabel['MOMgrowthPercent'] },  //'环比增长率'
            { Value : 'prev_lastyear', Label : arrJsPopLabel['prev_lastyear'] },  //'去年同期'
            { Value : 'prev_growth_lastyear', Label : arrJsPopLabel['YOYgrowth'] },  //'与去年同比增长值'
            { Value : 'prev_growth_percent_lastyear', Label : arrJsPopLabel['YOYgrowthPercent'] },  //'与去年同比增长率'
        ],
        byMonth:[
            { Value : 'cur', Label : arrJsPopLabel['THISPERIOD'] },  //'本期'
            { Value : 'prev', Label : arrJsPopLabel['PREVIOUSDATA']},  //'上期值' 环比上期
            { Value : 'prev_growth', Label : arrJsPopLabel['MOMgrowth'] },  //'环比增长值'
            { Value : 'prev_growth_percent', Label :  arrJsPopLabel['MOMgrowthPercent'] },  //'环比增长率'
            { Value : 'prev_lastyear', Label : arrJsPopLabel['prev_lastyear'] },  //'去年同期'
            { Value : 'prev_growth_lastyear', Label :arrJsPopLabel['YOYgrowth'] },  //'与去年同比增长值'
            { Value : 'prev_growth_percent_lastyear', Label :arrJsPopLabel['YOYgrowthPercent'] },  //'与去年同比增长率'
        ],
        byWeek:[
            { Value : 'cur', Label : arrJsPopLabel['THISPERIOD'] },  //'本期'
            { Value : 'prev', Label : arrJsPopLabel['PREVIOUSDATA']},  //'上期值' 环比上期
            { Value : 'prev_growth', Label : arrJsPopLabel['MOMgrowth'] },  //'环比增长值'
            { Value : 'prev_growth_percent', Label : arrJsPopLabel['MOMgrowthPercent'] },  //'环比增长率'
            { Value : 'prev_lastyear', Label : arrJsPopLabel['prev_lastyear'] },  //'去年同期'
            { Value : 'prev_growth_lastyear', Label : arrJsPopLabel['YOYgrowth'] },  //'与去年同比增长值'
            { Value : 'prev_growth_percent_lastyear', Label : arrJsPopLabel['YOYgrowthPercent'] },  //'与去年同比增长率'
        ],
        byDay:[
            { Value : 'cur', Label : arrJsPopLabel['THISPERIOD'] },  //'本期'
            { Value : 'prev', Label : arrJsPopLabel['PREVIOUSDATA']},  //'上期值' 环比上期
            { Value : 'prev_growth', Label : arrJsPopLabel['MOMgrowth'] },  //'环比增长值'
            { Value : 'prev_growth_percent', Label : arrJsPopLabel['MOMgrowthPercent'] },  //'环比增长率'
            { Value : 'prev_lastyear', Label : arrJsPopLabel['prev_lastyear'] },  //'去年同期'
            { Value : 'prev_growth_lastyear', Label : arrJsPopLabel['YOYgrowth']},  //'与去年同比增长值'
            { Value : 'prev_growth_percent_lastyear', Label : arrJsPopLabel['YOYgrowthPercent'] },  //'与去年同比增长率'
        ]
    },

        /** 不同类型字段的BigTypeArr和计算方法 */
    this.FieldDataTypeArr = {
        XAxisField : {
            BigTypeArr : ['text', 'reference', 'users', 'picklist', 'date', 'datetime'],
            CalcMethodOption : [],
        },
        SumField : {
            BigTypeArr : ['currency','number','num','Num','amount'],//,'moduleno'
            CalcMethodOption : that.CalcMethodOption.Sum,
        },
        CountField : {
            BigTypeArr : ['reference','text','moduleno','mobile','date','datetime'],
            CalcMethodOption : that.CalcMethodOption.Count,
        },
        TimeField : {
            BigTypeArr : ['datetime','date'],
            CalcMethodOption : [],
        },
        SearchField : {
            BigTypeArr : [],
            CalcMethodOption : [],
        },
    };

    /**
     * 获取拖动字段信息对象
     * @param SortableEvent Sortable事件对象
     * @param {HTMLElement} SortableEvent.item 拖动的DOM对象
     */
    this.getDragFieldInfo = function (SortableEvent) {
        delete that.DragFieldInfo;
        that.DragFieldInfo = {};
        var ItemObj = ld(SortableEvent.item);
        var FieldName = ItemObj.attr('fieldname');
        var FieldModule = ItemObj.attr('FieldModule');
        var FieldType = ItemObj.attr('FieldType');
        var FieldArr = that.ChartSetHtmlObj.ModuleFieldsList[FieldModule][FieldType][FieldName];
        that.DragFieldInfo.FieldModule = FieldModule;
        that.DragFieldInfo.FieldType = FieldType;
        that.DragFieldInfo.FieldName = FieldName;
        that.DragFieldInfo.AxisType = that.getFieldAxisType(FieldArr);
        that.DragFieldInfo.BeforeLabel = ItemObj.parent().prev('.ModuleFieldHead').text();
        //字段类别
        var bigtype = ItemObj.attr('bigtype');
        var CalcMethodOption = [];
        var FieldDataTypeArr = that.FieldDataTypeArr;
        ld.each(FieldDataTypeArr,function (FieldType,FieldTypeInfo) {
            that.DragFieldInfo['Is'+FieldType] = 'no';
            if(FieldTypeInfo.BigTypeArr.includes(bigtype)){
                that.DragFieldInfo['Is'+FieldType] = 'yes';
                CalcMethodOption = CalcMethodOption.concat(FieldTypeInfo.CalcMethodOption);
            }
        });
        that.DragFieldInfo.BigType = bigtype;
        that.DragFieldInfo.CalcMethodOption = that.ChartSetArr.Option.CalcMethod = CalcMethodOption;
        //zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
        that.getCompareSelectOption();
        that.DragFrom = 'ModuleField';
    }
    this.getCompareSelectOption = function(){
        //zxm @date:2024/11/27 @reason: 增加同环比设置 XUQIU20241127-02 统计图增加同环比功能
        var XAxis = that.ChartSetInfo.AxisFields.XAxis;
        //只有一个维度需要显示同环比设置

        //if(XAxis && XAxis.length==1){
            var TimeMethod = XAxis[0]['TimeMethod'];
            that.DragFieldInfo.CompareSelectOption = that.ChartSetArr.Option.CompareSelect = that.CompareSelectOption[TimeMethod];
        //}
        that.setCompareSelectIsShow();
    }

    this.getFieldAxisType = function (FieldInfo) {
        var BigType = FieldInfo.bigtype;
        var AxisFieldBigTypeArr = that.ChartSetArr.AxisFieldBigTypeArr;
        var IsXAxisField = (AxisFieldBigTypeArr['XAxis'].includes(BigType)) ? 'Yes' : 'No';
        var IsYAxisField = (AxisFieldBigTypeArr['YAxis'].includes(BigType)) ? 'Yes' : 'No';
        var AxisTypeAll = 'All';
        if(IsXAxisField === 'No')
            AxisTypeAll = 'YAxis';
        if(IsYAxisField === 'No')
            AxisTypeAll = 'XAxis';
        FieldInfo.AxisTypeAll = AxisTypeAll;
        return {
            'XAxis': IsXAxisField,
            'YAxis': IsYAxisField,
        }
    }

    /** 字段拖动事件数组，用于绑定统计维度和统计字段的拖动事件 */
    this.getFieldDragEventArr = function () {
        return {
            XAxisField : {
                Selector : ' #XAxis',
                GroupName : 'XAxisField',
                DragPermit : function () {
                    var IsMainModule = (that.DragFieldInfo.FieldModule === that.ChartSetHtmlObj.MainModule.modulename);
                    var IsXAxisField = (that.DragFieldInfo.AxisType.XAxis === 'Yes');
                    return (IsMainModule && IsXAxisField);
                },
                Keep : 'Keep',
                DataObj : that.ChartSetInfo.AxisFields.XAxis,
            },
            YAxisField : {
                Selector : ' #YAxis',
                GroupName : 'YAxisField',
                DragPermit : function () {
                    var IsYAxisField = (that.DragFieldInfo.AxisType.YAxis === 'Yes');
                    return IsYAxisField;
                },
                AfterAdd : function (TargetObj) {
                    //统计字段为可多选时，自动增加空字段区块
                    that.AddFieldEmpty(TargetObj);
                    //记住相关模块
                    if(!that.ChartSetInfo.relatedmodule.includes(that.DragFieldInfo.FieldModule))
                        that.ChartSetInfo.relatedmodule.push(that.DragFieldInfo.FieldModule);
                },
                Keep : 'KeepLast',
                DataObj : that.ChartSetInfo.AxisFields.YAxis,
            }
        };
    }

    /**
     * 统计字段拖动后，在目标区块后方自动增加空区块
     * @param TargetObj 目标字段区块的Jquery对象
     */
    this.AddFieldEmpty = function (TargetObj) {
        if(that.ChartSetHtmlObj.AxisSetNum.YAxis == 'Multi' && TargetObj.attr('empty') != 'no') {
            TargetObj.attr('empty','no');
            var FieldInfo = that.ChartTypeObj.BlockFieldList.ConfigY[0];
            var FieldEmptyHtml = that.ChartSetHtmlObj.FieldHtml_FunList.AxisFieldEmpty(FieldInfo);
            var FieldEmptyParent = ld(TargetObj).parent();
            FieldEmptyParent.append(FieldEmptyHtml);
            var LastIndex = FieldEmptyParent.find('.AxisFieldEmpty').length;
            var Selector = ' #YAxis .AxisFieldEmpty:nth-child('+LastIndex+')';
            that.ModuleFieldDragEvent(Selector,that.getFieldDragEventArr().YAxisField);
        }
    }

    /** 绑定统计维度和统计字段的拖动事件 */
    this.SetModuleFieldDragEvent = function () {
        var FieldDragEventArr = that.getFieldDragEventArr();
        ld.each(FieldDragEventArr,function (EventId,EventInfo) {
            var Selector = EventInfo.Selector + ' .AxisFieldEmpty';
            that.ModuleFieldDragEvent(Selector,EventInfo);
        });
    }

    /**
     * 为指定区域的字段DOM对象绑定拖动事件
     * @param Selector 区块的Jquery选择器
     * @param Option 字段拖动事件的参数对象
     */
    this.ModuleFieldDragEvent = function (Selector,Option) {
        var GroupName = Option.GroupName;
        var DragPermit = Option.DragPermit;
        var DragObjList = ld('#'+that.Popupobj.divid+Selector);
        ld.each(DragObjList,function (Index,DragObj) {
            DragObj.DragPermit = DragPermit;
            Sortable.create(DragObj, {
                // draggable: '.drag-handle',
                group: {
                    name : GroupName,
                    pull : false,
                    filter: '.AxisFieldBlock',
                    preventOnFilter: false,
                    put : function () {
                        return that.DragPermit;
                    },
                },
                animation: 150,
                sort: false,
                onAdd : function (evt) {
                    that.DragFieldOnAddFun(DragObj,evt,Option);
                    /*
                    //重新初始化当前Sortable实例，避免新的元素可拖动
                    // this.option('pull', false);
                    this.option('filter', '.AxisFieldBlock');
                    NewFieldObj.unbind('click').bind('click',function () {
                        event.stopPropagation();
                    });
                     */
                },
                onEnd : function (evt) {
                    if(that.DragFrom === 'AxisField' && that.DragPermit === true){
                        var toJqObj = ld((event || window.event).target);
                        if(!toJqObj.hasClass('AxisFieldEmpty'))
                            toJqObj = toJqObj.parents('.AxisFieldEmpty');
                        var fromJqObj = ld(evt.from);
                        var AxisType = fromJqObj.parent().attr('id');
                        var AxisFields = that.ChartSetInfo.AxisFields[AxisType];
                        var fromField = AxisFields.splice(fromJqObj.index(),1);
                        AxisFields.splice(toJqObj,0,fromField[0]);
                        toJqObj.before(fromJqObj);
                        //拖动一个字段  设置同环比下拉框值 //zxm @date:2024/11/28 @reason:
                        that.getCompareSelectOption();
                        that.ChartPreview();
                    }
                },
                onStart : function (evt) {
                    that.DragFrom = 'AxisField';
                },
            });
            ld(DragObj).unbind('drop').bind('drop',function () {
                // console.log('drop');
                if(that.DragPermit){
                    ld(this).removeClass('DragOver');
                } else {
                    ld(this).removeClass('DragOverError');
                }
            });
            ld(DragObj).unbind('dragenter').bind('dragenter',function () {
                // console.log('dragenter');
                that.DragPermit = this.DragPermit();
                if(that.DragFrom === 'AxisField')
                    that.DragPermit = true;
                if(that.DragPermit){
                    ld(this).addClass('DragOver');
                } else {
                    ld(this).addClass('DragOverError');
                }
            });
            ld(DragObj).unbind('dragleave').bind('dragleave',function () {
                // console.log('dragleave');
                var rect = this.getBoundingClientRect();
                var borderWidth_str = window.getComputedStyle(this).borderWidth;
                var borderWidth = parseInt(borderWidth_str.slice(0,-2));
                var isInElement = (
                    event.clientX >= rect.left + borderWidth &&
                    event.clientX <= rect.right - borderWidth &&
                    event.clientY >= rect.top + borderWidth &&
                    event.clientY <= rect.bottom - borderWidth
                );
                if(that.DragPermit && !isInElement){
                    ld(this).removeClass('DragOver');
                    that.DragPermit = false;
                } else if (!that.DragPermit && !isInElement) {
                    ld(this).removeClass('DragOverError');
                }
            });
        });
    }

    /**
     * 字段拖动添加事件
     * @param DragObj 拖动的对象
     * @param SortableAddEvent Sortable事件对象
     * @param AddOption 添加事件参数对象
     */
    this.DragFieldOnAddFun = function (DragObj,SortableAddEvent,AddOption) {
        if(!that.DragPermit)
            return that.DragPermit;
        var TargetObj = ld(SortableAddEvent.to);
        if(TargetObj.length === undefined || TargetObj.length === 0){
            return false;
        }
        var FieldId = TargetObj.parents('.AxisCon').attr('id');
        // edit: xll 2024/07/23 BUG20240718-22 字段拖动不允许重复
        var cloneObj = ld(SortableAddEvent.clone);
        //BUG20241018-56  去掉这个提示
        // var cloneObjValue = cloneObj.attr('value');
        // var DragObjValue = TargetObj.find('.AxisDragField').attr('value')
        /*if(cloneObj.length > 0 && cloneObj.data(FieldId) === 'yes' && cloneObjValue!==DragObjValue) {
            RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['NoRepetitionAllowed']);
            return false;
        }*/
        var BlockKey = 'Config' + FieldId.charAt(0);
        var OldLabel = that.ChartTypeObj.BlockFieldList[BlockKey][0].ConLabel;
        //var OldLabel = TargetObj.text();
        var OldHeight = TargetObj.outerHeight();
        that.DragFieldInfo.FieldId = FieldId;
        var NewFieldHtml = that.ChartSetHtmlObj.FieldHtml_FunList.AxisFieldBlock(that.DragFieldInfo);

        TargetObj.html(NewFieldHtml);
        var NewFieldObj = TargetObj.find('.AxisFieldBlock');
        var fullHeight = NewFieldObj.outerHeight(true);
        TargetObj.animate({
            height : fullHeight + 'px',
        },fullHeight * 2);
        if(cloneObj.length > 0) {
            cloneObj.data(FieldId,'yes');
        }
        if(AddOption.AfterAdd)
            AddOption.AfterAdd(TargetObj);
        var DelOption = {
            FieldId : FieldId,
            Label : OldLabel,
            Height : OldHeight,
            Keep : AddOption.Keep,
            DataObj : AddOption.DataObj,
            cloneObj : cloneObj,
        };
        that.SetDelCardEvent(ld(DragObj),DelOption);
        that.SetDragFieldDataBind(TargetObj);
        //每次字段拖动结束后都尝试预览
        // console.log('Try Preview')
        that.ChartPreview();
    };

    /**
     * 卡片删除事件绑定
     * @param CardObj 卡片Jquery对象
     * @param Option 删除事件参数对象
     */
    this.SetDelCardEvent = function (CardObj,Option) {
        CardObj = ld(CardObj);
        if(CardObj.attr('OldHeight')  === undefined){
            CardObj.attr('OldHeight',Option.Height);
        }
        var DelObj = CardObj.find('.DelIcon');
        DelObj.unbind('click').bind('click',function () {
            var tmp_DelObj = ld(this);
            var tmp_CardObj = tmp_DelObj.parents('.CardBlock');
            Option.Index = tmp_CardObj.index();
            that.DelCardEvent_Fun[Option.Keep](tmp_CardObj,Option);
            //删除对应位置的数据
            Option.DataObj.splice(Option.Index,1);
            tmp_CardObj.attr('empty','yes');
            //恢复字段重复判断
            var FieldId = tmp_CardObj.parents('.AxisCon').attr('id'),
                fieldVal = tmp_DelObj.parents('.AxisFieldBlock').find('.AxisDragField').attr('value'),
                fieldJqObj = that.PopupJqObj.find('#CustomEchartsSet').find('.ModuleFieldCon').find('.Field').filter('[value="'+fieldVal+'"]');
            fieldJqObj.data(FieldId,'no')
            that.ChartPreview();

            Option.cloneObj && ( Option.cloneObj.data(Option.FieldId,'no') );
        });
    }

    /** 不同类型的卡片删除事件 */
    this.DelCardEvent_Fun = {
        Keep : function (CardObj,Option) {
            CardObj.html(Option.Label);
            CardObj.css('height',CardObj.attr('OldHeight') + 'px');
            //Option.DataObj[Option.Index] = [];
        },
        KeepLast : function (CardObj,Option) {
            if(CardObj.siblings().length === 0)
                this.Keep(CardObj,Option);
            else
                this.Del(CardObj,Option);
        },
        Del : function (CardObj,Option) {
            CardObj.remove();
            //Option.DataObj = Option.DataObj.splice(Option.Index,1);
        }
    }

    /** 所有排序区块事件绑定 */
    this.SetSeqEvent = function () {
        var SeqBlockObjList = ld('#'+that.Popupobj.divid+' #CustomEchartsSet #SeqSet .SeqSetBlock');
        var Option = {};
        ld.each(SeqBlockObjList,function (Index,SeqBlockObj) {
            that.SetSeqBlockEvent(SeqBlockObj,Option);
        });
    }

    /**
     * 单个排序区块事件绑定
     * @param SeqBlockObj 排序区块Jquery对象
     * @param Option 事件参数对象
     */
    this.SetSeqBlockEvent = function (SeqBlockObj,Option) {
        SeqBlockObj = ld(SeqBlockObj);
        //删除事件
        var DelOption = {
            Keep : 'Del',
            DataObj : that.ChartSetInfo.SeqSet
        };
        that.SetDelCardEvent(SeqBlockObj,DelOption);
        //排序方式点击事件
        var SeqTypeObj = SeqBlockObj.find('#SeqType');
        SeqTypeObj.bind('change',function () {
            var tmp_SeqType = ld(this).val();
            var SeqTypeOption = ld(SeqBlockObj).find('#SeqField option');
            var FilterOption = SeqTypeOption.filter('[seqtype='+tmp_SeqType+']');
            FilterOption.css('display','unset');
            ld(FilterOption[0]).prop('selected',true);
            SeqTypeOption.not('[seqtype='+tmp_SeqType+']').css('display','none');
        });

        var SeqFieldTypeArr = that.SeqFieldTypeArr;
        ld.each(SeqFieldTypeArr,function (FieldType,SeqType){
            that.ChageSeqFieldOption(FieldType);
        });
    }

    /**
     * 字段拖动后字段卡片内部DOM对象和字段设置信息数据的双向绑定
     * @param DragFieldCardObj 字段卡片Jquery对象
     */
    this.SetDragFieldDataBind = function (DragFieldCardObj) {
        DragFieldCardObj = ld(DragFieldCardObj);
        var DragFieldId = that.DragFieldInfo.FieldId;
        var DataObj = that.ChartSetInfo.AxisFields[DragFieldId];
        var Index = DragFieldCardObj.index();
        if(!DataObj[Index])
            DataObj[Index] = {};
        else{
            //需要判断，操作是覆盖原字段，或是删除后重新增加字段，根据卡片内是否为空判断
            var Empty = DragFieldCardObj.attr('empty');
            if(Index === 0 && Empty !== undefined && Empty === 'yes'){
                DataObj.splice(Index,0,{});
            }
        }
        DataObj = DataObj[Index];
        that.getDragDataObj(DataObj);
        var FieldBlockFields = that.DragFieldInfo.FieldBlockFields;
        //从第三个字段开始双向绑定，前两个字段(删除图标、所选字段名)忽略
        for (var i = 2;i < FieldBlockFields.length; i++) {
            var Tmp_FieldInfo = FieldBlockFields[i];
            var FieldId = Tmp_FieldInfo.FieldId;
            var Tmp_JqueryObj = DragFieldCardObj.find('#'+FieldId);
            if(Tmp_JqueryObj.length > 0) {
                that.ModifyObjData(Tmp_JqueryObj,DataObj[FieldId]);
                that.DataHtmlBindObj.setDataBindByJqObj(Tmp_JqueryObj, DataObj, FieldId);
            }
        }
        //维度字段需要特殊处理
        if(DragFieldId === 'XAxis'){
            //时间字段，添加完成后将 FieldBlockFields中的时间统计方式删去，避免影响下一次拖动
            if(that.DragFieldInfo.IsTimeField === 'yes') {
                FieldBlockFields.pop();
            }
            //非时间字段取 byField
            else {
                //先删取避免收已双向绑定的影响，即get拦截器
                delete DataObj['TimeMethod'];
                DataObj['TimeMethod'] = 'byField';
            }
        }
        DragFieldCardObj.attr('empty','no');
        that.ChageSeqFieldOption(DragFieldId);
    }

    /**
     * 字段拖动后，存入所需的字段信息
     * @param DataObj 拖动后字段信息存储的键名指针
     */
    this.getDragDataObj = function (DataObj) {
        DataObj.FieldValue = that.DragFieldInfo.FieldValue;
        DataObj.BigType = that.DragFieldInfo.BigType;
        DataObj.FieldModule = that.DragFieldInfo.FieldModule;
        DataObj.FieldLabel = that.DragFieldInfo.FieldLabel;
    }

    /**
     * 排序区块设置信息的双向绑定
     * @param Index 排序区块顺序索引号
     * @param SeqBlockCardObj 排序区块卡片Jquery对象
     */
    this.SetSeqBlockDataBind = function (Index,SeqBlockCardObj) {
        SeqBlockCardObj = ld(SeqBlockCardObj);
        var DataObj = that.ChartSetInfo.SeqSet;
        if(Index === undefined)
            Index = SeqBlockCardObj.index();
        if(!DataObj[Index])
            DataObj[Index] = {};
        DataObj = DataObj[Index];
        var SeqBlockFields = that.ChartTypeObj.BlockFieldList.SeqBlock;
        //从第二个字段开始双向绑定，删除图标字段忽略
        for (var i = 1;i < SeqBlockFields.length; i++) {
            var Tmp_FieldInfo = SeqBlockFields[i];
            var FieldId = Tmp_FieldInfo.FieldId;
            var Tmp_JqueryObj = SeqBlockCardObj.find('#'+FieldId);
            if(Tmp_JqueryObj.length > 0) {
                that.ModifyObjData(Tmp_JqueryObj,DataObj[FieldId]);
                that.DataHtmlBindObj.setDataBindByJqObj(Tmp_JqueryObj, DataObj, FieldId);
            }
        }
    }

    /** 字段类型和排序类型的对应关系 */
    this.SeqFieldTypeArr = {
        XAxis : 'bycolumnname',
        YAxis : 'byresult',
    }

    /** 排序类型变化事件 */
    this.ChageSeqFieldOption = function (FieldType) {
        var FieldsList = that.ChartSetInfo.AxisFields[FieldType];
        var SeqType = that.SeqFieldTypeArr[FieldType];
        var SeqBlockObjList = ld('#'+that.Popupobj.divid+' #CustomEchartsSet #SeqSet .SeqSetBlock ');
        // console.log('add');
        that.SeqFieldOption = {};
        var OptionHtml = '';
        ld.each(FieldsList,function (index,FieldInfo) {
            //第二维度直接拖动第二个会导致数组中第一个键值为空对象，即FieldInfo == undefined
            if(FieldInfo !== undefined){
                //统计维度则取 TimeMethod，统计字段则取 CalcMethod
                var TotalType = (FieldType === 'XAxis') ? FieldInfo.TimeMethod : FieldInfo.CalcMethod;
                var OptionVal = FieldInfo.FieldValue + '-' + TotalType;
                OptionHtml += '<option SeqType="'+SeqType+'" TotalType="'+TotalType+'" value="'+OptionVal+'">'
                    + FieldInfo.FieldLabel + '</option>';
            }
        });
        //默认按分组字段
        ld.each(SeqBlockObjList,function (index,SeqBlockObj) {
            var SeqTypeObj = ld(SeqBlockObj).find('#SeqType');
            var SeqFieldObj = ld(SeqBlockObj).find('#SeqField');
            SeqFieldObj.find('option[SeqType='+SeqType+']').remove();
            SeqFieldObj.append(OptionHtml);
            SeqTypeObj.trigger('change');
        });
    }

    /** 设置信息保存事件 */
    this.SaveChartSet = function () {
        that.SaveAjaxFun('Save');
    }

    /** 获取当前预览权限(根据不同类型的预览权限数组) */
    this.getPreviewSwitch = function () {
        var PreviewPermitArr = that.ChartTypeObj.PreviewPermitArr;
        var Permit = true;
        ld.each(PreviewPermitArr,function (PermitType,PermitArr) {
            var Tmp_Permit = that.getPreviewPermitByType[PermitType](PermitArr)
            Permit = (Permit && Tmp_Permit);
        });
        that.PreviewSwitch = Permit;
    }

    /** 获取不同类型的预览权限 */
    this.getPreviewPermitByType = {
        DefaultLength : 1,
        Length : function (PermitArr) {
            var Permit = true;
            ld.each(PermitArr,function (Index,PermitKeyStr) {
                var PermitKeyArr = PermitKeyStr.split('.');
                var DataObj = that.ChartSetInfo;
                ld.each(PermitKeyArr,function (KeyIndex,Key) {
                    DataObj = DataObj[Key];
                });
                var Tmp_Permit = (DataObj.length >= that.getPreviewPermitByType.DefaultLength);
                Permit = (Permit && Tmp_Permit);
            });
            //that.PreviewSwitch = Permit;
            return Permit;
        },
        Length2 : function (PermitArr) {
            this.DefaultLength = 2;
            return this.Length(PermitArr);
        },
        Length1 : function (PermitArr) {
            this.DefaultLength = 1;
            return this.Length(PermitArr);
        },
    }

    /** 统计图预览事件(应用防抖) */
    this.ChartPreview = function () {
        that.setCompareSelectIsShow();
        //使用防抖避免短时间多次预览
        var Preview = that.debounce(that.Preview,that.PreviewDelay);
        Preview();
    }

    /** 进行预览 */
    this.Preview = function () {
        that.getPreviewSwitch();
        // console.log(that.PreviewSwitch);
        var PreviewChartDiv = ld('#'+that.Popupobj.divid+' #ChartPreview .PreviewChartDiv');
        var EmptyPreviewObj = PreviewChartDiv.find('.EmptyPreview');
        if(!that.PreviewSwitch) {
            (EmptyPreviewObj.length === 0) && PreviewChartDiv.html(that.ChartSetHtmlObj.EmptyPreviewHtml);
            return false;
        }
        if(EmptyPreviewObj.length > 0)
            EmptyPreviewObj.remove()
        that.SaveAjaxFun('Preview');
        //恢复正常的防抖延迟
        that.PreviewDelay = that.SimplePreviewDelay;
    }

    /** 预览和保存的Ajax请求回调函数 */
    this.SaveAjaxCallBackFun = {
        Save : function (data) {
            if(data.code==1){
                var chart_info = data.result.chart_info;
                that.ChartSetInfo.report_id = chart_info.report_id;
                that.Popupobj.CancelEvent();
                DelProgressObjs();
                //edit: xll 2023/10/19 BUG0074134 保存后需要刷新报表列表，编辑修改名称等也需要刷新
                if(that.ChartSetArr.mode === 'create'){
                    var ReportObj;
                    if(ReportAnalysisObj)
                        ReportObj = ReportAnalysisObj;
                    else
                        ReportObj = new ReportAnalysis();
                    ReportObj.getReportList(0, 'init');
                }
                else{
                    ReportAnalysis.refreshReportName(that.ChartSetInfo.report_id,that.ChartSetInfo.report_name);
                }
                if(that.frompage === 'fromdetail')
                    that.RefreshDetailPage(data);
            }
        },
        Preview : function (data) {
            if(data.code==1){
                var mychartjqobj = that.PopupJqObj.find('#myChart');
                var mytablejqobj = that.PopupJqObj.find('#chartTable');
                if(that.ChartSetInfo.ReportStyle === 'Bottom'){
                    mytablejqobj.show();
                    mychartjqobj.insertBefore(mytablejqobj);
                }else
                if(that.ChartSetInfo.ReportStyle === 'Top'){
                    mytablejqobj.show();
                    mychartjqobj.insertAfter(mytablejqobj);
                }else{
                    mytablejqobj.hide();
                }
                var chart_info = that.getChartInfo(data);
                mytablejqobj.html(chart_info.table);
                var tableHeight = mytablejqobj.outerHeight();
                if(tableHeight>=300){
                    tableHeight = 300;
                    mytablejqobj.css('height','300px').css('overflow-y','auto');
                }
                mychartjqobj.css('height', 'calc(100% - ' + tableHeight + 'px)');

                that.ChartSetInfo.report_id = chart_info.report_id;

                that.customRenderChart.SetChartJqObj(mychartjqobj);
                that.customRenderChart.SetChartInfo({
                    ChartSetInfo : that.ChartSetInfo,
                });
                that.customRenderChart.setChart(chart_info,0,'no');

                var windowWidth = mytablejqobj.outerWidth();
                var ld_tableContentObj = ld("#"+that.Popupobj.divid).find('[tag=ld_tableContent]');
                if(ld_tableContentObj.length>0){
                    ld.each(ld_tableContentObj,function(i,itemobj){
                        var options = {'height':(tableHeight/ld_tableContentObj.length)-10,'width':windowWidth,'thwidth':145};
                        lockingHeaderColumn(itemobj, options);
                    })
                }
                DelProgressObjs();
            }
        },
    }

    /** 获取chartinfo,用于子类应付返回值中对应键值不同的情况 */
    this.getChartInfo = function (data) {
        return data.result.chart_info;
    }

    /** 发起保存的Ajax请求方法 */
    this.SaveAjaxFun = function (SaveType) {
        var ChartSetInfo = that.ChartSetInfo;
        ChartSetInfo.themename = ChartSetInfo.ThemeSet;
        //edit: xll 2024/07/19 BUG20240717-55 仅在保存时提示名称为空
        if(SaveType !== 'SelChartType' && (ChartSetInfo.report_name === '' || ChartSetInfo.report_name === undefined) && SaveType === 'Save'){
            var RemindStr = arrJsPopLabel['CHARTNAMENOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",RemindStr);
            return false;
        }
        var url = that.getAjaxUrl();
        url += '&function_name=saveReportInfo';
        var params = `&saveType=${SaveType}` + '&ChartSetInfo='+encodeURIComponent(JSON.stringify(ChartSetInfo));
        var callback = that.SaveAjaxCallBackFun[SaveType];
        ldAjax(url,params,function (data) {
            callback(data);
            DelProgressObjs();
        });
    }

    /** 防抖方法 */
    this.debounce = function (func, delay) {
        // 设置定时器标识（写在return函数外面，方便下面内部函数获取）
        that.timer;
        // 返回函数，不然调用debounce会立即执行此函数
        return function(...args) {
            clearTimeout(that.timer);
            that.timer = setTimeout(() => {
                func.apply(this, args);
            }, delay);
        };
    }

    /**
     * 详情页进入编辑页，保存后刷新详情页
     * @param data 编辑页保存Ajax请求的返回值Json数据
     */
    this.RefreshDetailPage = function (data) {
        var DetailPopupobj = CrmPopup.getPopupObj("last");
        if(!DetailPopupobj.ReportDetailObj)
            return false;
        var ReportDetailObj = DetailPopupobj.ReportDetailObj;
        //SQL统计图筛选弹窗的内容Html
        if(data.result.conditionContent)
            ReportDetailObj.Searchhtml = data.result.conditionContent;
        ReportDetailObj.init();
        var customRenderChart = new customRenderChartFun();
        var chart_info = that.getChartInfo(data);
        var report_id = chart_info.report_id;
        customRenderChart.SetChartInfo({
            ChartSetInfo : that.ChartSetInfo,
        });
        customRenderChart.setChart(chart_info,report_id,'no');
        var chartTableObj = ld('#'+ReportDetailObj.divid).find('#chartTable_'+report_id);
        chartTableObj.html(chart_info.table);
        var chartTableHtml = chartTableObj.get(0).outerHTML;
        chartTableObj.remove();
        var ChartObj = ld('#'+ReportDetailObj.divid).find('#myChart_'+report_id);
        if(that.ChartSetInfo.ReportStyle === 'Top'){
            ChartObj.before(chartTableHtml);
        }
        if(that.ChartSetInfo.ReportStyle === 'Bottom'){
            ChartObj.after(chartTableHtml);
        }
        chartTableObj = ld('#'+ReportDetailObj.divid).find('#chartTable_'+report_id);
        //表格穿透 gotoList
        var gotoListObj = chartTableObj.find('[tag=gotoList]');
        if(gotoListObj.length > 0) {
            gotoListObj.unbind('click').bind('click', function () {
                ReportDetailObj.gotoList(this);
            });
        }
        ReportDetailObj.setScroll(chart_info);
    }

    /** 统计图类型切换事件 */
    this.ChangeChartType = function (NewChartType) {
        that.ChartSetInfo.chart_type = NewChartType;
        that.PreviewSwitch = false;
        //根据类型将对应字段置空
        that.ChartSetInfo.AxisFields.XAxis = [];
        that.ChartSetInfo.AxisFields.YAxis = [];
        //切换统计图  数据标签的值要重新选中默认值--即选中第一个
        delete that.ChartSetInfo.SeriesDataLabel;
        that.ChartSetInfo.SeriesDataLabel = '';

        // 使用编辑mode
        // that.ChartSetInfo.mode = 'edit';
        // edit: xll 2024/06/01 BUG20240429-08 切换类型时记住主模块和相关模块
        that.ChartSetInfo.mainmodule = that.ChartSetHtmlObj.MainModule.modulename;
        that.ChartSetInfo.relatedmodule = that.ChartSetHtmlObj.RelModuleSelArr;
        var ChartSetHtmlObj = ld('#'+that.Popupobj.divid+' #CustomEchartsSet');
        ChartSetHtmlObj.remove();
        //图标区块需要重新绑定点击事件
        that.IconBlockEventBind = {}
        that.init();
        that.ChangeChartTypeEvent();
    }

    /** 统计图类型切换后需要执行的事件(用于子类) */
    this.ChangeChartTypeEvent = function () {
        
    }

    /**
     * 新建、编辑 统计图 、SQL统计图
     * @param report_id 报表id
     * @param frompage 标识是否是详情页编辑，若是则保存后需要刷新详情页
     * @param parent_id 报表所处文件夹id
     */
    this.createChart = function(report_id,frompage,parent_id) {
        //先载入所需资源
        that.LoadResources();
        that.frompage = frompage;
        var tmpwidth = ld(window).width();//全屏宽度
        var module = 'CustomEcharts';
        var Popupobj = CrmPopup.load(arrJsPopLabel['CREATENEWECHARTS'],  '',"", tmpwidth, module, "", "none", "", "");
        that.Popupobj = Popupobj;
        Popupobj.createHeadHtml = function (){
            this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
            this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';

            this.popupheadhtml +='<div class="E_pop_tit_Second_Right" style="float: right;">';
            this.popupheadhtml += '<div class="ld-button ld-button-primary" name="next" id="next">'+arrJsPopLabel['NEXT']+'</div>';
            this.popupheadhtml += '<div class="ld-button ld-button-primary" name="astep" id="astep" style="display: none;">'+arrJsPopLabel['ASTEP']+'</div>';
            this.popupheadhtml += '<div class="ld-button ld-button-primary" name="save" id="save" style="display: none;">'+arrJsPopLabel['SAVE']+'</div>';
            this.popupheadhtml += '<div class="E_ptitc" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
            this.popupheadhtml += '</div>';
            this.popupheadhtml += '</div>';
        }
        Popupobj.createBottomHtml = function () {
            this.popupbottomhtml = "";
        }
        Popupobj.createScrollDiv();//创建滚动条
        Popupobj.prevshow();
        Popupobj.center();
        var url = that.getAjaxUrl();
        var params = that.getCreateUrlParams(report_id);
        if(parent_id !== undefined){
            params += '&parent_id='+parent_id;
        }



        ldAjax(url,params,function(data){
            if (data.code == 1) {
                Popupobj.setParams(data.result.title,"","",tmpwidth, module,"","","","");
                that.ChartSetInfo = data.result.ChartSetInfo;//设置信息
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj,data.result.content);
                CrmPopup.fullScreen(ld("#" + Popupobj.divid), Popupobj);
                that.ChartSetArr = data.result.ChartSetArr;//设置所需数据信息
                that.Popupobj = Popupobj;
                that.divid = that.Popupobj.divid;
                that.PopupJqObj = ld("#"+that.Popupobj.divid);
                //that.LoadResources();
                //选择图表类型界面的事件
                that.SetChartTypeEvent();
                //将that挂到Popupobj上方便调试
                Popupobj.ChartCreateObj = that;
                that.customRenderChart = new customRenderChartFun();
                DelProgressObjs();
            }
        });
    }

    /** 获取新增编辑时的Ajax请求体参数 */
    this.getCreateUrlParams = function (report_id) {
        return '&function_name=newChart&report_id='+report_id+'&frommodule='+that.pageto_module;
    }

    /** 获取Ajax请求中的URL */
    this.getAjaxUrl = function () {
        return 'index.php?module='+that.pageto_module+'&action='+that.pageto_module+'Ajax&file='+that.AjaxFileName;
    }

    /**
     * 加载所需要的js、css资源
     */
    this.LoadResources = function () {
        //css路径
        ld('<link>', {
            rel: 'stylesheet',
            type: 'text/css',
            href: 'themes/softed/CustomEchartsStyle.css'
        }).appendTo('head');

        AjaxJSPage('cls_ChartSetHtml_js','include/js/modules/CustomEcharts/cls_ChartSetHtml.js');
        AjaxJSPage('ChartParent_js','include/js/modules/CustomEcharts/ChartParent.js');
        AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
        that.LoadOtherResources();
    }

    /**
     * 加载所需要的js、css补充资源(用于子类继承使用)
     */
    this.LoadOtherResources = function () {

    }
}
