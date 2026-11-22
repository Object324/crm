function cls_ChartSetHtml() {
    var that = this;
    this.ChartSetArr = {};
    this.SetBlockList = {};
    this.MainModule = {};
    this.RelModuleSelArr = [];
    this.ModuleFieldsList = {};
    this.ModuleFieldsBlockHtml = {};
    this.pageto_module = 'ReportAnalysis';
    this.ObjDataBindArr = {};
    this.ObjDataBindArr.Bind = {};
    this.ObjDataBindArr.SelfBind = {};
    this.ObjEventArr = {};
    /** 相关模块初始化的最大数量 */
    this.RelMaxNum = 0;
    this.BlockScrollHeight = {};
    this.SetTypeArr = {
        Config : arrJsPopLabel['ConfigSetting'],  //'配置',
        Style : arrJsPopLabel['StyleSetting'],  //'样式'
    };
    this.CurSetType = 'Config'; //中间设置页签栏当前页签，默认配置页签
    this.CurAxisTab  = 'XAxis'; //样式设置坐标轴页签栏当前页签，默认X轴
    this.AfterShowTask = {
        ModuleField : [],
        AddFieldsCard : {},
    };
    this.AxisSetNum = {};


    this.init = function (Options) {
        //图表创建类对象
        that.Set_ChartCreateObj(Options['ChartCreateObj']);
        //图表对象
        that.Set_ChartObj(Options['ChartObj']);
    }

    this.Set_ChartCreateObj = function (ChartCreateObj) {
        that.ChartCreateObj = ChartCreateObj;
        //图表设置信息
        that.Set_ChartSetInfo(ChartCreateObj.ChartSetInfo);
        //页面设置所需信息
        that.Set_ChartSetArr(ChartCreateObj.ChartSetArr);
        //弹窗对象
        that.Set_Popupobj(ChartCreateObj.Popupobj);
    }

    //图表设置信息
    this.Set_ChartSetInfo = function (ChartSetInfo) {
        that.ChartSetInfo = ChartSetInfo;
        that.CurChartType = that.ChartSetInfo.chart_type;
    }

    //设置图表页面信息
    this.Set_ChartSetArr = function (ChartSetArr) {
        that.ChartSetArr = ChartSetArr;
        var MainModuleInfo = {};
        if(that.ChartSetInfo.mainmodule){
            var MainModule = that.ChartSetInfo.mainmodule;
        }
        if(that.ChartSetArr.ModuleArr[MainModule])
            MainModuleInfo = that.ChartSetArr.ModuleArr[MainModule];
        else{
            //主模块默认选中第一个
            ld.each(that.ChartSetArr.ModuleArr,function (ModuleName,ModuleInfo) {
                MainModuleInfo = ModuleInfo;
                return false;
            });
        }
        MainModuleInfo.Selected = 'yes';
        that.MainModule = MainModuleInfo;
        that.ChartSetInfo.mainmodule = that.MainModule.modulename;
        that.ChartSetInfo.relatedmodule = that.RelModuleSelArr;
    }

    //设置弹窗对象
    this.Set_Popupobj = function (Popupobj) {
        that.Popupobj = Popupobj;
    }

    //设置图表对象
    this.Set_ChartObj = function (ChartObj) {
        that.ChartObj = ChartObj;

        that.BlockFieldList = ChartObj.BlockFieldList;
        that.SetBlockList = ChartObj.SetBlockList;
        that.IconList = ChartObj.IconList;

        //维度为Y，需要修改选择X轴下拉框的翻译
        if(ChartObj.Coordinate === 'Y'){
            that.ChartSetArr.Option.YAxisIndex = [
                { Value : '1', labelbol : 'TopXAxis'},   //上X轴
                { Value : '0', labelbol : 'BottomXAxis'},   //下X轴
            ];
        }
    }

    //获取图表设置界面Html
    this.getChartSetHtml = function () {
        var ChartSetHtml = '';
        ChartSetHtml += '<div class="CustomEchartsSet" id="CustomEchartsSet">';
        ChartSetHtml += that.getLeftContentHtml();
        ChartSetHtml += '<div class="CustomEchartsMiddle">';
        ChartSetHtml += that.getSetHeadHtml();
        ChartSetHtml += that.getSetConHtml();
        ChartSetHtml += '</div>';
        ChartSetHtml += '<div class="CustomEchartsRight">';
        ChartSetHtml += that.getChartTypeNavHtml();
        ChartSetHtml += that.getChartPreviewHtml();
        ChartSetHtml += '</div>';
        ChartSetHtml += '</div>';
        return ChartSetHtml;
    }

    //获取设置界面左侧Html(模块字段选择界面)
    this.getLeftContentHtml = function () {
        var LeftContentHtml = '';
        LeftContentHtml += '<div class="CustomEchartsLeft">';
        //ChartSetHtml +=
        LeftContentHtml += that.getModuleSelHtml();//模块选择
        LeftContentHtml += '<div class="ModuleField_Scroll">';
        LeftContentHtml += that.getMainModuleFieldHtml();
        //LeftContentHtml += that.getModuleFieldHtml(that.RelModuleSelArr);
        LeftContentHtml += '</div>';
        LeftContentHtml += '</div>';
        return LeftContentHtml;
    }

    this.getMainModuleFieldHtml = function () {
        var MainModuleArr = {};
        MainModuleArr[that.MainModule.modulename] = that.MainModule;
        return that.getModuleFieldHtml(MainModuleArr);
    }

    //获取模块选择下拉框
    this.getModuleSelHtml = function () {
        var ModuleSelHtml = '';
        var FieldArr = that.BlockFieldList['ModuleSel'];
        ld.each(FieldArr,function (index,FieldInfo) {
            that.FieldInfoPush(FieldInfo);
            ModuleSelHtml += that.ModuleSel_Fun[FieldInfo['FieldId']](FieldInfo);
        })
        return ModuleSelHtml;
    }

    this.ModuleSel_Fun = {
        MainModule : function (FieldInfo) {
            var SelModuleArr = that.ChartSetArr.ModuleArr;
            var OptionHtml = this.getModuleOption(SelModuleArr);
            //高级查询Icon
            var IconHtml = '<div class="SearchIconDiv">' +
                '<span class="SearchIcon categoryAdvsear-search" id="OtherCondition"></span>' +
                '</div>';
            var ConditionIconEvent = {
                FieldId : 'OtherCondition',
                FieldEvent : 'Event:click',
            }
            that.FieldInfoPush(ConditionIconEvent);
            FieldInfo.SelModuleLabel = that.MainModule.name;
            return this.getModuleSelDiv(OptionHtml,IconHtml,FieldInfo);
        },
        RelModule : function (FieldInfo) {
            var OptionHtml = '';
            var Selector = '#'+FieldInfo['FieldId']+' .ModuleOption';
            if(that.ChartSetArr.RelModuleArr == undefined){
                that.getRelModuleOptionHtml(Selector);
            } else {
                that.getRelModuleOptionHtml(Selector);
                //that.getRelOptionHtmlByRelModuleArr(that.ChartSetArr.RelModuleArr,Selector);
            }
            //高级查询Icon
            var IconHtml = '';
            FieldInfo.SelModuleLabel = '';
            return this.getModuleSelDiv(OptionHtml,IconHtml,FieldInfo);
        },
        getModuleSelDiv : function (OptionHtml,IconHtml,FieldInfo) {
            var FieldId = FieldInfo['FieldId'];
            var SelModuleLabel = FieldInfo.SelModuleLabel;
            var ModuleSelHtml = '';
            ModuleSelHtml += '<div class="ModuleSel">';
            //模块选择框
            ModuleSelHtml += '<div class="ModuleSelCon">';
            //标签
            ModuleSelHtml += '<div class="ModuleLabel">'+FieldInfo['FieldLabel']+'</div>';
            //模块列表
            ModuleSelHtml += '<div class="ModuleSelect" id="'+FieldId+'" tabindex="-11" status="collapse">' +
                                 '<div class="ModuleOptionValue" id="'+FieldId+'_Value">' + SelModuleLabel + '</div>' +
                                 '<div class="ModuleOptionBefore" style="display: none" tabindex="-12">' +
                                     '<div class="ModuleOption" >' +
                                         OptionHtml +
                                     '</div>' +
                                 '</div>' +
                             '</div>';

            ModuleSelHtml += '</div>';
            //查询Icon
            ModuleSelHtml += IconHtml;
            ModuleSelHtml += '</div>';

            return ModuleSelHtml;
        },
        getModuleOption : function (SelModuleArr) {
            var OptionHtml = '';
            ld.each(SelModuleArr,function (ModuleId,ModuleInfo) {
                OptionHtml += '<div value="' + ModuleInfo.modulename + '" ';
                if(ModuleInfo.Selected === 'yes')
                    OptionHtml += 'selected';
                OptionHtml += '>'+ModuleInfo.name+'</div>';
            });
            return OptionHtml;
        },
        FieldSearch : function (FieldInfo) {
            var FieldSearchHtml = '';
            FieldSearchHtml += '<div class="FieldSearch">' +
                    '<input type="text" class="ld-input-inner ld-input-inner-add" id="'+FieldInfo['FieldId']+'" value="" ' +
                        ' placeholder="'+FieldInfo['FieldLabel']+'" autocomplete="off" >' +
                    '<b class="ld-icon-search" id="FieldSearchIcon"></b>' +
                '</div>';
            that.FieldInfoPush(FieldInfo);
            //搜索按钮也需要绑定事件
            var SearchFieldInfo = {
                FieldId : 'FieldSearchIcon',
                FieldEvent : 'Event:click',
            }
            that.FieldInfoPush(SearchFieldInfo);
            return FieldSearchHtml;
        }
    }

    this.getRelModuleOptionHtml = function (Selector) {
        var params = '&mainmodule='+that.MainModule['modulename'];
        that.RelModuleSelArr = {};
        var callback_fun = function (data) {
            var RelModuleArr = data.result.RelMoudleArr;
            that.getRelOptionHtmlByRelModuleArr(RelModuleArr,Selector);
        }
        that.ChartAjaxNoProgress('getRelatedModule',params,callback_fun);
    }

    this.getRelOptionHtmlByRelModuleArr = function (RelModuleArr,Selector) {
        var OptionHtml = '';
        that.ChartSetArr.RelModuleArr = RelModuleArr;
        var i = 0;
        var FirstModuleName = '';
        if(that.ChartSetInfo.AxisFields.YAxis.length > 0){
            ld.each(that.ChartSetInfo.AxisFields.YAxis,function (Index,FieldInfo) {
                if(!FieldInfo.FieldModule)
                    FieldInfo.FieldModule = FieldInfo.FieldValue.split(':')[3].split('_')[0];
                var FieldModule = FieldInfo.FieldModule;
                if(RelModuleArr[FieldModule]){
                    RelModuleArr[FieldModule].Selected = 'yes';
                    that.RelModuleSelArr[FieldModule] = RelModuleArr[FieldModule];
                    i ++;
                }
            });
        }
        ld.each(RelModuleArr,function (ModuleId,ModuleInfo) {
            if(i >= that.RelMaxNum)
                return false;
            ModuleInfo.Selected = 'yes';
            that.RelModuleSelArr[ModuleId] = ModuleInfo;
            i ++ ;
            if(FirstModuleName == '')
                FirstModuleName = ModuleInfo.name;
        });
        //edit: xll 2024/03/14 XUQIU1002148 模块可搜索(相关模块)
        var PopupJqObj = ld('#'+that.Popupobj.divid),
            relModuleObj = PopupJqObj.find('#RelModule'),
            optionList = Object.values(RelModuleArr).map(v => {
                return {
                    selected: v.Selected === "yes",
                    label: v.name,
                    value: v.modulename,
                }
            });
        ld_Select.showSelect(relModuleObj.get(0), {
            list: optionList,
            width: (relModuleObj.width()-25) + 'px',
            showtype: 'click',
            optionwidth: '210px',
            fixwidth: '175px',
            optionobjattr: ['value'],
            filterable: true,
            multiple: true,
            change: function (evt){
                var itemObj = ld(evt.changeItem),tmpModule = itemObj.attr('data-value');
                //if(itemObj.find('.ld_Select-seleced').length > 0){
                if(itemObj.find('.ld_Select-option-seleced').length > 0){
                    that.RelModuleSelArr[tmpModule] = that.ChartSetArr.RelModuleArr[tmpModule];
                    //重新渲染模块字段区域等
                    that.RelModule_change(tmpModule);
                }
                else {
                    PopupJqObj.find('#CustomEchartsSet').find('#Block_'+tmpModule).html('');
                }
            }
        });
        var ModuleField_Con = that.getModuleFieldHtml(that.RelModuleSelArr);
        ld('#'+that.Popupobj.divid+' .ModuleField_Scroll').append(ModuleField_Con);
        that.ExecuteTaskByTaskType('ModuleField',{});
    }

    //获取模块字段界面Html
    this.getModuleFieldHtml = function (ModuleArr) {
        var ModuleFieldHtml = '';
        ld.each(ModuleArr,function (TabId,TabInfo) {
            var tmp_module = TabInfo.modulename;
            ModuleFieldHtml += '<div class="ModuleFieldBlock" id="Block_'+tmp_module+'" >';
            if(that.ModuleFieldsList[tmp_module] === undefined){
                that.ModuleFieldsList[tmp_module] = {};
                that.getModuleFieldList(tmp_module);
            }
            else {
                var ModuleFieldEventItem = {
                    TaskType : 'ModuleField',
                    TaskFun : that.ModuleFieldBlockEvent,
                    TaskParams : tmp_module,
                };
                // console.log('add');
                that.AfterShowTask.ModuleField.push(ModuleFieldEventItem);
                ModuleFieldHtml += that.ModuleFieldsBlockHtml[tmp_module];
            }
            ModuleFieldHtml += '</div>';
        });
        return ModuleFieldHtml;
    }

    this.getModuleFieldList = function (modulename) {
        var params = '&modulename='+modulename+'&MainModule='+that.MainModule.modulename;
        var callback_fun = function (data) {
            var ModuleFieldsList = data.result;
            that.getModuleFieldBlock(modulename,ModuleFieldsList);
            var TaskOption = {
                Module : modulename
            };
            // console.log('callback AddFieldsCard');
            that.ExecuteTaskByTaskType('AddFieldsCard',TaskOption);
        }
        that.ChartAjaxNoProgress('getModuleFieldsList',params,callback_fun);
    };

    this.getModuleFieldBlock = function (modulename,ModuleFieldsList) {
        //记录模块字段列表，避免重复请求
        that.ModuleFieldsList[modulename] = ModuleFieldsList;
        var BlockHtml = '';
        ld.each(ModuleFieldsList,function (FieldType,FieldList) {
            var BlockCon_Id = modulename + '_' + FieldType;
            //头部
            BlockHtml += '<div class="ModuleFieldHead" Block_Id="'+BlockCon_Id+'" blocksatus="expand">' +
                that.ChartSetArr.ModuleArr[modulename]['name'] + that.ModuleFieldHeadLabel[FieldType] +
                         '</div>';
            //字段列表
            BlockHtml += '<div class="ModuleFieldCon" Block_Id="'+BlockCon_Id+'" >' +
                              that.getModuleFieldBlockCon(FieldList) +
                         '</div>';
            //初始化区块展开收起
            // that.BlockScrollHeight[BlockCon_Id] = 0;
        });
        var Selector = ' #Block_'+modulename;
        //置于区块内部
        ld('#'+that.Popupobj.divid+Selector).html(BlockHtml);
        that.ModuleFieldsBlockHtml[modulename] = BlockHtml;
        that.ModuleFieldBlockEvent(modulename);
        return BlockHtml;
    }

    this.ModuleFieldBlockEvent = function (modulename) {
        var Selector = ' #Block_'+modulename;
        //模块字段区块头部收起事件,在回调后进行绑定
        var HeadEventItem = { };
        HeadEventItem['ModuleFieldHead'] = {
            Selector : Selector + ' .ModuleFieldHead',
            EventType : 'click',
        }
        that.ChartCreateObj.SetObjEvent(HeadEventItem);
        //字段拖动事件绑定
        that.ChartCreateObj.FieldDragEvent(Selector+' .ModuleFieldCon');
    }

    this.ModuleFieldHeadLabel = {
        main : '',
        detail : '-' + arrJsPopLabel['Entries'],  //'明细',
    }

    this.getModuleFieldBlockCon = function(FieldList){
        var BlockConHtml = '';
        ld.each(FieldList,function (FieldName,FieldInfo) {
            var label = FieldInfo.label;
            var FieldAfterLabel = that.getFieldAfterLabel[FieldInfo.AxisTypeAll];
            BlockConHtml += '<div class="Field drag-handle" value="'+FieldInfo.value+'" fieldname="'+FieldName+'" ' +
                ' bigtype="'+FieldInfo.bigtype+'" FieldModule="'+FieldInfo.FieldModule+'" FieldType="'+FieldInfo.FieldType+'"' +
                ' data-label="'+label+'" data-afterlabel="'+FieldAfterLabel+'">' +
                                '<span class="FieldLabelSpan">' + FieldInfo.label + '</span>' +
                                '<div class="FieldAfterLabel">' + FieldAfterLabel + '</div>' +
                            '</div>';
        });
        return BlockConHtml;
    }

    this.getFieldAfterLabel =  {
        All : arrJsPopLabel['StatisticalDimension'] + arrJsPopLabel['OR'] + arrJsPopLabel['StatisticsField'],
        XAxis : arrJsPopLabel['StatisticalDimension'],
        YAxis : arrJsPopLabel['StatisticsField'],
        None : '',
    }

    this.getSetHeadHtml = function () {
        var SetTypeArr = that.SetTypeArr;
        var SetHeadHtml = '';
        SetHeadHtml += '<div class="ChartSetHead" >' ;
        ld.each(SetTypeArr,function (SetType,Label) {
            if(SetType == that.CurSetType)
                SetHeadHtml += '<div class="SetType CurSetType" SetType="'+SetType+'">' + Label + '</div>';
            else
                SetHeadHtml += '<div class="SetType" SetType="'+SetType+'">' + Label + '</div>';
        })
        SetHeadHtml += '</div>';
        return SetHeadHtml;
    }

    this.getSetConHtml = function () {
        var SetConHtml = '';
        SetConHtml += '<div class="ChartSetCon" >';
        var SetTypeArr = that.SetTypeArr;
        ld.each(SetTypeArr,function (SetType,Label) {
            SetConHtml += that.getSetTypeBlockHtml(SetType);
        });
        SetConHtml += '</div>';
        return SetConHtml;
    }

    //获取配置界面Html
    this.getConfigSetHtml = function () {
        return that.getSetTypeBlockHtml('Config');
    }

    //获取样式界面Html
    this.getStyleSetHtml = function () {
        return that.getSetTypeBlockHtml('Style');
    }

    this.getSetTypeBlockHtml = function (SetType) {
        var SetTypeBlockHtml = '';
        if(that.CurSetType == SetType)
            SetTypeBlockHtml += '<div class="'+SetType+'Set SetTypeBlock" SetType="'+SetType+'">';
        else
            SetTypeBlockHtml += '<div class="'+SetType+'Set SetTypeBlock" SetType="'+SetType+'" style="display: none">';
        var SetTypeBlock = that.SetBlockList[SetType];

        ld.each(SetTypeBlock,function (BlockName,BlockInfo) {
            SetTypeBlockHtml += that.getSetBlockHtml(SetType,BlockName,BlockInfo);
        });
        SetTypeBlockHtml += '</div>';
        return SetTypeBlockHtml;
    }

    //获取设置区块的Html
    this.getSetBlockHtml = function (SetType,BlockName,BlockInfo) {
        var Block_Id = SetType + BlockName;
        // that.BlockScrollHeight[Block_Id] = 0;
        var SetBlockHtml = '';
        SetBlockHtml += '<div class="SetBlock">';
        //标题
        SetBlockHtml += that.BlockTitleHead(BlockInfo,Block_Id);
        //内容
        var FieldKey = SetType + BlockName;
        SetBlockHtml += that.getBlockContenHtml(FieldKey,BlockInfo,Block_Id);

        SetBlockHtml += '</div>';
        return SetBlockHtml;
    }

    this.BlockTitleHead = function (BlockInfo,Block_Id) {
        var TitleHtml = '';
        TitleHtml += '<div class="SetBlockTitle" Block_Id = "'+ Block_Id +'" blocksatus="expand">' +
            '<div class="BlockName" >' + BlockInfo['BlockLabel'] + '</div>' +
            '</div>';
        return TitleHtml;
    }

    this.getBlockContenHtml = function (FieldKey,BlockInfo,Block_Id) {
        var ContenHtml = '';
        var BlockFields = that.BlockFieldList[FieldKey];
        ContenHtml += '<div class="SetBlockContent" Block_Id = "'+ Block_Id +'">' +
                          that.getFieldListHtml(BlockFields) +
                      '</div>';
        return ContenHtml;
    }

    this.getFieldListHtml = function (FieldList) {
        var FieldListHtml = '';
        ld.each(FieldList,function (index,FieldInfo) {
            var FieldFun = FieldInfo['FieldType'] + 'Html';
            FieldListHtml += that.FieldHtml_FunList[FieldFun](FieldInfo);
        });
        return FieldListHtml;
    }

    /** 获取字段内容Html的方法集合 */
    this.FieldHtml_FunList = {
        //行类型字段内容（空行）
        FieldRowEmpty : function (RowHtml) {
            return '<div class="FieldRow" >' + RowHtml + '</div>';
        },
        //行类型字段内容（含标签）
        FieldRowHtml : function (FieldInfo,ConHtml) {
            var RowHtml = '';
            var CssClass = FieldInfo['CssClass'];
            var Label = FieldInfo['FieldLabel'];
            RowHtml += '<div class="FieldLabel '+CssClass+'" >' + Label + '</div>' +
                       '<div class="FieldCon" >' + ConHtml + '</div>';
            return this.FieldRowEmpty(RowHtml);
        },
        InputHtml : function (FieldInfo) {
            var ConHtml = '';
            var FieldId = FieldInfo['FieldId'];
            ConHtml += '<input type="text" name="'+FieldId+'" id="'+FieldId+'" ' +
                'placeholder="" value="" class="FieldConText" >';
            that.FieldInfoPush(FieldInfo);
            return this.FieldRowHtml(FieldInfo,ConHtml);
        },
        SelectEmpty : function (FieldId,OptionHtml) {
            return '<select name="'+FieldId+'" id="'+FieldId+'" ' +
                'class="FieldConSelect" >'+OptionHtml+'</select>';
        },
        SelectHtml : function (FieldInfo) {
            var OptionHtml = '';
            var FieldId = FieldInfo['FieldId'];
            var OptionArr = that.ChartSetArr.Option[FieldId];
			//数据标签显示设置 
            if(typeof that.ChartObj.filterOption != "undefined" && that.ChartObj.filterOption[FieldId])
                OptionArr = that.ChartObj.filterOption[FieldId](OptionArr);
            ld.each(OptionArr,function (index,OptionInfo) {
                var Label = OptionInfo['Label'];
                if(OptionInfo.labelbol)
                    Label = arrJsPopLabel[OptionInfo.labelbol];
                OptionHtml += '<option value="'+OptionInfo['Value']+'">' +
                                  Label +
                              '</option>';
            });
            var SelectHtml = this.SelectEmpty(FieldId,OptionHtml);
            that.FieldInfoPush(FieldInfo);
            return this.FieldRowHtml(FieldInfo,SelectHtml);
        },
        OptionHtml : function (FieldInfo) {
            var FieldId = FieldInfo['FieldId'];
            var OptionHtml = that.ChartSetArr.Option[FieldId];
            var SelectHtml = this.SelectEmpty(FieldId,OptionHtml);
            that.FieldInfoPush(FieldInfo);
            return this.FieldRowHtml(FieldInfo,SelectHtml);
        },
        TextareaHtml : function (FieldInfo) {
            var ConHtml = '';
            var FieldId = FieldInfo['FieldId'];
            ConHtml += '<textarea class="FieldConTextarea" name="'+FieldId+'"' +
                ' id="'+FieldId+'" aria-label=""></textarea>';
            that.FieldInfoPush(FieldInfo);
            return this.FieldRowHtml(FieldInfo,ConHtml);
        },
        //区块类型字段内容（空区块）
        FieldBlockEmpty : function (BlockHtml) {
            return '<div class="FieldBlock" >' + BlockHtml + '</div>';
        },
        //区块类型字段内容（含标题）
        FieldBlockHtml : function (FieldInfo,LabelHtml,ConHtml) {
            var BlockHtml = '';
            var Label = FieldInfo['FieldLabel'];
            BlockHtml += '<div class="FieldLabel" >' + Label + LabelHtml + '</div>' +
                         '<div class="FieldCon" >' + ConHtml + '</div>' ;
            return this.FieldBlockEmpty(BlockHtml);
        },
        AxisHtml : function (FieldInfo) {
            var FieldId = FieldInfo.FieldId;
            if(FieldId === 'XAxis')
                FieldInfo.DefaultSetNum = that.ChartSetInfo.AxisFields.XAxis.length === 2 ? 'Two' : 'One';
            that.AxisSetNum[FieldId] = FieldInfo.DefaultSetNum;
            var ConHtml = '',LabelHtml='';
            var AxisLabel = this['AxisHead'+FieldInfo.SetNum](FieldInfo);
            LabelHtml += '<div class="AxisHead" >' +
                             AxisLabel +
                         '</div>';
            var AxisCon = this['AxisCon'+FieldInfo.DefaultSetNum](FieldInfo);
            ConHtml += '<div class="AxisCon" id="'+FieldId+'">' +
                            AxisCon +
                       '</div>';
            return this.FieldBlockHtml(FieldInfo,LabelHtml,ConHtml);
        },
        AxisHeadOne : function (FieldInfo) {
            return arrJsPopLabel['NUMONE'];  //'一个';
        },
        AxisHeadTwo : function (FieldInfo) {
            //统计维度切换事件
            var XAxisNumInfo = {
                FieldId : 'XAxisNum',
                Selector : '#CustomEchartsSet .CustomEchartsMiddle .ConfigSet .SetBlockContent .AxisNum div',
                FieldEvent : 'MultiEvent:click',
            };
            that.FieldInfoPush(XAxisNumInfo);
            var AxisHeadHtml = '';
            AxisHeadHtml += '<div class="AxisNum" SetNum="'+FieldInfo.DefaultSetNum+'">' +
                '<div SetNum="One">' + arrJsPopLabel['NUMONE'] + '</div>' +
                '<div SetNum="Two">' + arrJsPopLabel['NUMTWO'] + '</div>' +
                '</div>';
            return AxisHeadHtml;
        },
        AxisHeadMulti : function (FieldInfo) {
            //散点图需多个统计字段
            if(that.ChartObj.ParentType === 'scatter'){
                return arrJsPopLabel['NUMMULTI'];
            }
            return arrJsPopLabel['NUMONEORMULTI'];  //'一个或多个';
        },
        AxisConOne : function (FieldInfo) {
            return this.AxisFieldEmpty(FieldInfo);
        },
        AxisConTwo : function (FieldInfo) {
            var FieldEmptyHtml = this.AxisFieldEmpty(FieldInfo);
            return FieldEmptyHtml + FieldEmptyHtml;
        },
        AxisConMulti : function (FieldInfo) {
            return this.AxisFieldEmpty(FieldInfo);
        },
        AxisFieldEmpty : function (FieldInfo) {
            var Label = FieldInfo['ConLabel'];
            return '<div class="AxisFieldEmpty CardBlock" >' + Label + '</div>';
        },
        AxisFieldBlock : function (DragFieldInfo) {
            var FieldName = DragFieldInfo.FieldName;
            var FieldModule = DragFieldInfo.FieldModule;
            var FieldType = DragFieldInfo.FieldType;
            var FieldId = DragFieldInfo.FieldId;
            var IsTimeField = DragFieldInfo.IsTimeField;
            var FieldArr = that.ModuleFieldsList[FieldModule][FieldType][FieldName];
            var FieldBlockHtml = '';
            FieldBlockHtml += '<div class="AxisFieldBlock" fieldname="'+FieldName+'">' ;
            // console.log(DragFieldInfo);
            var FieldBlockFields = that.BlockFieldList[FieldId+'FieldBlock'];
            if(FieldId === 'XAxis' && IsTimeField === 'yes'){
                FieldBlockFields.push(that.BlockFieldList.TimeMethod);
            }
            DragFieldInfo.FieldBlockFields = FieldBlockFields;
            DragFieldInfo.FieldValue = FieldArr.value;
            DragFieldInfo.FieldLabel = FieldArr.label;
            FieldBlockHtml += that.getFieldListHtml(FieldBlockFields);
            FieldBlockHtml += '</div>';
            return FieldBlockHtml;
        },
        FieldBlockHeadHtml : function (FieldInfo) {
            var RowHtml = this.DelIcon();
            return this.FieldRowEmpty(RowHtml);
        },
        DragFieldHtml : function (FieldInfo) {
            var DragFieldInfo = that.ChartCreateObj.DragFieldInfo;
            var ConHtml = this.DragField(DragFieldInfo);
            return this.FieldRowHtml(FieldInfo,ConHtml);
        },
        DragField : function (DragFieldInfo) {
            var FieldName = DragFieldInfo.FieldName;
            var FieldModule = DragFieldInfo.FieldModule;
            var FieldType = DragFieldInfo.FieldType;
            var BeforeLabel = DragFieldInfo.BeforeLabel;
            var FieldArr = that.ModuleFieldsList[FieldModule][FieldType][FieldName];
            var FieldHtml = '<div class="AxisDragField " fieldname="'+FieldName+'" value="'+FieldArr.value+'">' +
                    BeforeLabel + '—' + FieldArr.label +
                '</div>';
            return FieldHtml;
        },
        SeqButtonHtml : function (FieldInfo) {
            var ButtonHtml = '';
            ButtonHtml += '<div class="SeqSetButton" id="'+FieldInfo.FieldId+'">' + FieldInfo.FieldLabel + '</div>';
            that.FieldInfoPush(FieldInfo);
            return this.FieldRowEmpty(ButtonHtml);
        },
        SeqSetHtml : function (FieldInfo) {
            var SeqSetHtml = '';
            var FieldId = FieldInfo['FieldId'];
            SeqSetHtml += '<div class="SeqSetCon" id="'+FieldId+'">';
            //排序区块内容
            var SeqSetArr = that.ChartSetInfo.SeqSet;
            if(SeqSetArr && SeqSetArr.length > 0){
                ld.each(SeqSetArr,function (index,BlockInfo) {
                    SeqSetHtml += that.FieldHtml_FunList['SeqBlock'](index,BlockInfo);
                });
            }
            SeqSetHtml += '</div>';
            return this.FieldBlockEmpty(SeqSetHtml);
        },
        SeqBlock : function (index,BlockInfo) {
            var SeqBlockHtml = '';
            SeqBlockHtml += '<div class="SeqSetBlock CardBlock" id="SeqBlock_'+index+'" >';
            var SeqBlockFields = that.BlockFieldList['SeqBlock'];
            // console.log('SeqBlockFields')
            SeqBlockHtml += that.getFieldListHtml(SeqBlockFields);
            SeqBlockHtml += '</div>';
            return SeqBlockHtml;
        },
        DelIcon : function () {
            return '<div class="DelIcon"></div>';
        },
        SeqHeadHtml : function (FieldInfo) {
            var RowHtml = this.DelIcon();

            return this.FieldRowEmpty(RowHtml);
        },
        CheckHtml : function (FieldInfo) {
            var ConHtml = '';
            var FieldId = FieldInfo['FieldId'];
            ConHtml += '<input id="'+FieldId+'" type="checkbox" class="second_switch" value="">';
            that.FieldInfoPush(FieldInfo);
            return this.FieldRowHtml(FieldInfo,ConHtml);
        },
        IconRowHtml : function (FieldInfo) {
            var ConHtml = this.IconConHtml(FieldInfo);
            return this.FieldRowHtml(FieldInfo,ConHtml);
        },
        IconBlockHtml : function (FieldInfo) {
            var LabelHtml = '';
            var ConHtml = this.IconConHtml(FieldInfo);
            return this.FieldBlockHtml(FieldInfo,LabelHtml,ConHtml);
        },
        IconBlockEmptyHtml : function (FieldInfo) {
            var ConHtml = this.IconConHtml(FieldInfo);
            return this.FieldBlockEmpty(ConHtml);
        },
        IconConHtml : function (FieldInfo) {
            var ConHtml = '';
            var FieldId = FieldInfo['FieldId'];
            var DefaultSet = FieldInfo['DefaultSet'];
            if(that.ChartSetInfo[FieldId])
                DefaultSet = that.ChartSetInfo[FieldId];
            //默认左对齐
            ConHtml += '<div class="IconBlock '+FieldId+'" id="'+FieldId+'" '+FieldId+'="'+DefaultSet+'">';
            var IconList = that.IconList[FieldId];
            ld.each(IconList,function (IconId,IconInfo) {
                ConHtml += that.FieldHtml_FunList.IconTypeHtml[IconInfo['IconType']](IconId,IconInfo);
            });
            ConHtml += '</div>';
            //记录图表区块双向绑定和事件
            that.FieldInfoPush(FieldInfo);
            return ConHtml;
        },
        IconTypeHtml : {
            //仅图片
            Image : function (IconId,IconInfo) {
                var IconHtml = '';
                IconHtml += '<div class="'+IconInfo['Class']+'" IconId="'+IconId+'" >' +
                    '</div>';
                return IconHtml;
            },
            //带tip
            Tip : function (IconId,IconInfo) {
                var IconHtml = '';
                IconHtml += '<div class="'+IconInfo['Class']+'" IconId="'+IconId+'" ' +
                    'data-tip="'+IconInfo['Label']+'" data-direction="left" data-type="position">' +
                    '</div>';
                return IconHtml;
            },
            //下方出现label
            Label : function (IconId,IconInfo) {
                var IconHtml = '';
                IconHtml += '<div class="IconDiv" IconId="'+IconId+'">' +
                    '<div class="Icon '+IconInfo['Class']+'" ></div>' +
                    '<div class="IconLabel" >' + IconInfo['Label'] + '</div>' +
                    '</div>';
                return IconHtml;
            },
        },
        AxisTabHtml : function (FieldInfo) {
            var AxisTabHtml = '';
            var AxisTab = '';
            var AxisTabBlock = '';
            var AxisTabArr = FieldInfo['AxisTab'];
            ld.each(AxisTabArr,function (AxisName,AxisLabel) {
                if(that.CurAxisTab === AxisName){
                    AxisTab += '<div class="AxisTab CurAxisTab" AxisName="'+AxisName+'">'+AxisLabel+'</div>';
                    AxisTabBlock += '<div class="AxisTabBlock" id="AxisTabBlock'+AxisName+'">';
                }
                else{
                    AxisTab += '<div class="AxisTab" AxisName="'+AxisName+'">'+AxisLabel+'</div>';
                    AxisTabBlock += '<div class="AxisTabBlock" id="AxisTabBlock'+AxisName+'" style="display: none">';
                }
                AxisTabBlock += that.FieldHtml_FunList.AxisTabBlock(FieldInfo,AxisName,);
                AxisTabBlock += '</div>';
            });
            AxisTab = this.FieldRowEmpty(AxisTab);
            AxisTabBlock = this.FieldBlockEmpty(AxisTabBlock);
            AxisTabHtml += AxisTab + AxisTabBlock;
            var AxisTabEvent = {
                FieldId : 'AxisTab',
                Selector : '.CustomEchartsMiddle .StyleSet .SetBlock .SetBlockContent[block_id=StyleAxis] .AxisTab',
                FieldEvent : 'MultiEvent:click',
            }
            that.FieldInfoPush(AxisTabEvent);
            return AxisTabHtml;
        },
        AxisTabBlock : function (FieldInfo,AxisName) {
            var AxisTabBlock = '';
            var AxisTabBlockFields = that.BlockFieldList['AxisTab'+AxisName];
            AxisTabBlock += that.getFieldListHtml(AxisTabBlockFields);
            return AxisTabBlock;
        },
    }

    //获取右侧图表类型导航栏Html
    this.getChartTypeNavHtml = function () {
        var NavHtml = '';
        var ChartTypeArr = that.ChartObj.ChartTypeArr;
        var ParentType = that.ChartObj.ParentType;
        var CurChartType = that.ChartSetInfo.chart_type;
        NavHtml += '<div class="ChartTypeNav" id="ChartTypeNav" ParentType="'+ParentType+'" SecondType="'+CurChartType+'">';
        var ChartTypeWidth = 'calc( 100% / ' + ChartTypeArr.length + ')';
        ld.each(ChartTypeArr,function (Index,ChartInfo) {
            var ChartType = ChartInfo.ParentType;
            NavHtml += '<div class="ChartTypeDiv " style="width:'+ChartTypeWidth+'">' ;
            if(ChartType == ParentType)
                NavHtml += '<div class="ParentChartType ChartTypeConDiv ChartTypeHoverDiv CurParentChartType" >';
            else
                NavHtml += '<div class="ParentChartType ChartTypeConDiv ChartTypeHoverDiv" >';
                     NavHtml += '<div class="ChartImgDiv " ChartType="'+ChartType+'"></div>' +
                                '<div class="ParentTypeNameDiv ChartTypeNameDiv" >'+ChartInfo.Label+'</div>' +
                            '</div>' +
                            that.getChartTypeSec(ChartType,ChartInfo) +
                        '</div>';
        });
        NavHtml += '</div>';
        return NavHtml;
    }

    //图表类型二级目录
    this.getChartTypeSec = function (ChartType,ChartInfo) {
        var DivHtml = '';
        DivHtml += '<div class="ChartTypeSecDiv">';
        DivHtml += '<div class="ChartTypeSecDivScroll">';
        ld.each(ChartInfo['SecondType'],function (SecondType,SecondLabel) {
            if(SecondType == that.ChartSetInfo.chart_type)
                DivHtml += '<div class="SecTypeDiv ChartTypeConDiv SecChartTypeHoverDiv CurSecTypeDiv" >';
            else
                DivHtml += '<div class="SecTypeDiv ChartTypeConDiv SecChartTypeHoverDiv" >';
                    DivHtml += '<div class="ChartImgDiv " ChartType="'+SecondType+'"></div>' +
                               '<div class="SecTypeNameDiv ChartTypeNameDiv" >'+SecondLabel+'</div>' +
                           '</div>';
        });
        DivHtml += '</div>';
        DivHtml += '</div>';
        return DivHtml;
    }

    //获取预览界面Html
    this.getChartPreviewHtml = function () {
        var PreviewHtml = '';
        PreviewHtml += '<div class="ChartPreview" id="ChartPreview">' +
                           '<div class="PreviewChartDiv" id="myChart" style="display: flex;align-items: center;justify-content: center">' +
                               that.getEmptyPreview() +
                           '</div>' +
                           '<div id="chartTable" class="back-color-white"></div>'+
                       '</div>';
        return PreviewHtml;
    }

    this.getEmptyPreview = function () {
        var ConfirmMsg = that.ChartObj.getEmptyConfirm();
        var EmptyPreview = '';
        EmptyPreview += '<div class="EmptyPreview" >' +
                            '<div class="ChartImgDiv TransLarge" ChartType="'+that.CurChartType+'"></div>' +
                            '<p class="EmptyComfirm">' +
                                ConfirmMsg +
                            '</p>' +
                        '</div>';
        that.EmptyPreviewHtml = EmptyPreview;
        return EmptyPreview;
    }

    this.ChartAjaxNoProgress = function (function_name,params,callback_fun) {
        var module = that.pageto_module;
        var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SelfDefinedReport';
        params += '&function_name='+function_name;
        ldAjaxNoProgress(url,params,function(data){
            callback_fun(data);
        });
    }

    this.Show = function () {
        var PopupJqObj = ld('#'+that.Popupobj.divid);
        var ContentObj = PopupJqObj.find(' #'+that.Popupobj.divid+'_scroll');
        //移除旧的新建界面
        if(ContentObj.children('#CustomEchartsSet').length > 0)
            ContentObj.children('#CustomEchartsSet').remove();
        ContentObj.children('div').css('display','none');
        var SetContentHtml = that.getChartSetHtml();
        ContentObj.append(SetContentHtml);

        that.afterShow();
    }

    this.afterShow = function () {
        //渲染后的事件，目前用于主模块、相关模块选择字段对其（SQL统计图无需）
        that.AfterShowEvent();

        // 图例选择”无“时隐藏图例的其他设置
        setTimeout(() => {
            var PopupJqObj = ld('#'+that.Popupobj.divid);
            var LegendLocateObj = PopupJqObj.find(' #LegendLocate');
            if(LegendLocateObj.attr('LegendLocate') === 'None') {
                LegendLocateObj.parents('.FieldBlock').siblings().hide();
            }

            //建议鼠标光标直接定位中“统计图名称”输入框中
            PopupJqObj.find('#ChartName').focus();
        }, 200);

        //图表父类型悬浮呼出第二类型事件
        var ChartTypeDivHoverInfo = {
            FieldId : 'ChartTypeDivHover',
            Selector : '#ChartTypeNav .ChartTypeDiv',
            FieldEvent : 'MultiEvent:mouseenter',
        };
        that.FieldInfoPush(ChartTypeDivHoverInfo);
        //图表次类型悬浮呼出第二类型事件
        var ChartTypeSecDivHoverInfo = {
            FieldId : 'ChartTypeSecDivHover',
            Selector : '#ChartTypeNav .ChartTypeSecDiv',
            FieldEvent : 'MultiEvent:mouseenter',
        };
        that.FieldInfoPush(ChartTypeSecDivHoverInfo);
        //移出隐藏图表次类型
        var ChartTypeDivLeaveInfo = {
            FieldId : 'ChartTypeDivLeave',
            Selector : '#ChartTypeNav .ChartTypeDiv',
            FieldEvent : 'MultiEvent:mouseleave',
        };
        that.FieldInfoPush(ChartTypeDivLeaveInfo);
        //移出隐藏图表次类型
        var ChartTypeSecDivLeaveInfo = {
            FieldId : 'ChartTypeSecDivLeave',
            Selector : '#ChartTypeNav .ChartTypeDiv .ChartTypeSecDiv',
            FieldEvent : 'MultiEvent:mouseleave',
        };
        that.FieldInfoPush(ChartTypeSecDivLeaveInfo);
        //图表类型切换事件
        var ChartSecTypeInfo = {
            FieldId : 'ChartSecType',
            Selector : '#ChartTypeNav .ChartTypeDiv .SecTypeDiv',
            FieldEvent : 'MultiEvent:click',
        };
        that.FieldInfoPush(ChartSecTypeInfo);
        //设置区块头部收起事件
        var SetBlockTitleInfo = {
            FieldId : 'SetBlockTitle',
            Selector : '.CustomEchartsMiddle .SetBlock .SetBlockTitle',
            FieldEvent : 'MultiEvent:click',
        };
        that.FieldInfoPush(SetBlockTitleInfo);
        //设置页签切换事件
        var ChartSetHeadInfo = {
            FieldId : 'SetType',
            Selector : '.CustomEchartsMiddle .ChartSetHead .SetType',
            FieldEvent : 'MultiEvent:click',
        };
        that.FieldInfoPush(ChartSetHeadInfo);

        //that.ExecuteAfterShowTask();
    }

    this.AfterShowEvent = function () {
        setTimeout(() => {
            var PopupJqObj = ld('#'+that.Popupobj.divid);
            //保持主模块和相关模块标签宽度一致
            var lableWidth = PopupJqObj.find(' #RelModule').siblings('.ModuleLabel').outerWidth();
            PopupJqObj.find(' #MainModule').siblings('.ModuleLabel').css('width',lableWidth);
            //相关模块的初始值
            var ConObj = PopupJqObj.find('#RelModule .ModuleOptionBefore');
            var NewText = ConObj.children('.ModuleOption').find('div[selected]:eq(0)').text();
            ConObj.siblings('.ModuleOptionValue').text(NewText);

            //主模块可搜索
            var mainModuleObj = PopupJqObj.find('#MainModule'),
                optionList = Object.values(that.ChartSetArr.ModuleArr).map(v => {
                    return {
                        selected: v.Selected === "yes",
                        label: v.name,
                        value: v.modulename,
                    }
                });
            ld_Select.showSelect(mainModuleObj.get(0), {
                list: optionList,
                width: (mainModuleObj.width()-25) + 'px',
                optionwidth: '210px',
                fixwidth: '175px',
                showtype: 'click',
                optionobjattr: ['value'],
                filterable: true,
                change: function (evt){
                    that.ChartCreateObj.SetObjEvent_Fun.MainModule_change(evt.NavBarItem.value);
                }
            });
        }, 200);
    }

    this.ExecuteAfterShowTask = function () {
        var AfterShowTaskList = that.AfterShowTask;
        // console.log('excute');
        ld.each(AfterShowTaskList,function (TaskType,TaskList) {
            that.ExecuteTask[TaskType](TaskList);
        });
    }

    this.ExecuteTaskByTaskType = function (TaskType,TaskOption) {
        var TaskTypeList = that.AfterShowTask[TaskType];
        that.ExecuteTask[TaskType](TaskTypeList,TaskOption);
    }

    this.ExecuteTask = {
        //模块字段区块的任务，目的为请求返回后设置相关事件
        ModuleField : function (TaskList,TaskOption) {
            ld.each(TaskList,function (index,TaskInfo) {
                var TaskFun = TaskInfo['TaskFun'];
                var TaskParams = TaskInfo['TaskParams'];
                TaskFun(TaskParams);
            });
            delete that.AfterShowTask.ModuleField;
        },
        //字段拖动区域的增加，为了编辑时在界面展示后填充x、y的已选字段
        AddFieldsCard : function (TaskList,TaskOption) {
            var Module = TaskOption.Module;
            if(TaskList[Module]){
                ld.each(TaskList[Module],function (index,TaskInfo) {
                    var TaskFun = TaskInfo['TaskFun'];
                    var TaskParams = TaskInfo['TaskParams'];
                    TaskFun(TaskParams);
                });
                delete TaskList[Module];
            }
        },
    }

    //记录需要进行（双向绑定、事件绑定）操作的字段
    this.FieldInfoPush = function (FieldInfo) {
        //FieldInfo['FieldEvent'] 结构为 类型:补充
        //如 Event:change change类型事件
        //如 Bind:mainmodule 给键名mainmodule进行双向绑定
        //分号分割多个类别的处理
        if(FieldInfo['FieldEvent'] != ''){
            var FieldEventArr = FieldInfo['FieldEvent'].split(';');
            ld.each(FieldEventArr,function (index,FieldEventItem) {
                var FieldEvent = FieldEventItem.split(':')[0];
                that.FieldInfoPush_Fun[FieldEvent](FieldInfo,FieldEventItem);
            });
        }
    }

    this.FieldInfoPush_Fun = {
        //放入双向绑定数组
        Bind : function (FieldInfo,FieldEventItem) {
            var ObjId = FieldInfo['FieldId'];   //对象id
            //数据键名 title.text, .表层级
            var DataKey = FieldEventItem.split(':')[1];
            that.ObjDataBindArr.Bind[ObjId] = DataKey;
        },
        //自定义双向绑定数组
        SelfBind : function (FieldInfo,FieldEventItem) {
            var ObjId = FieldInfo['FieldId'];   //对象id
            //数据键名 title.text, .表层级
            var DataKey = FieldEventItem.split(':')[1];
            that.ObjDataBindArr.SelfBind[ObjId] = DataKey;
        },

        //放入事件绑定数组
        Event : function (FieldInfo,FieldEventItem) {
            var EventId = FieldInfo['FieldId'];
            var Selector = '#' + FieldInfo['FieldId'];
            var EventType = FieldEventItem.split(':')[1];
            //EventItem 包含EventId 事件键值、 Selector jq对象选择器、 EventType事件类型三个属性
            that.ObjEventArr[EventId] = {
                Selector : Selector,
                EventType : EventType,
            };
        },
        //多个DOM对象的事件绑定
        MultiEvent : function (FieldInfo,FieldEventItem) {
            var EventId = FieldInfo['FieldId'];
            var Selector = FieldInfo['Selector'];
            var EventType = FieldEventItem.split(':')[1];
            //EventItem 包含EventId 事件键值、 Selector jq对象选择器、 EventType事件类型三个属性
            that.ObjEventArr[EventId] = {
                Selector : Selector,
                EventType : EventType,
            };
        },
    }

    this.MainModule_change = function () {
        //清空任务数组
        that.AfterShowTask.ModuleField = [];
        var ModuleField_Con = '';
        ModuleField_Con += that.getMainModuleFieldHtml();
        ld('#'+that.Popupobj.divid+' .ModuleField_Scroll').html(ModuleField_Con);
        //重新获取相关模块列表
        that.getRelModuleOptionHtml(' #RelModule .ModuleOptionBefore .ModuleOption');
       // ModuleField_Con += that.getModuleFieldHtml(that.RelModuleSelArr);
        ld('#'+that.Popupobj.divid+' .ModuleField_Scroll').html(ModuleField_Con);

    }

    this.RelModule_change = function (RelModuleName) {
        //清空任务数组
        that.AfterShowTask.ModuleField = [];
        var RelModuleItem = {};
        RelModuleItem[RelModuleName] = that.ChartSetArr.RelModuleArr[RelModuleName];
        var ModuleField_Con = that.getModuleFieldHtml(RelModuleItem);
        ld('#'+that.Popupobj.divid+' .ModuleField_Scroll').append(ModuleField_Con);
        that.ExecuteTaskByTaskType('ModuleField',{});
        //that.ExecuteTaskByTaskType('AddFieldsCard');
    }

}