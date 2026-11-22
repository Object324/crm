function TargetAnalysis() {
    var that = this;

    this.getHomeParams = function (ParamOption) {
        that.boardid = ParamOption.boardid;
        that.stuffid = ParamOption.stuffid;
        var homeTopObj = ld('#home_index').children('.home_header_top'),
            scopeObj = homeTopObj.find('#HomeSmOwnerSearchScope'),
            userIdObj = ld('#selectuserid'),
            dateObj = homeTopObj.children('.home_laydate_div').find('.laydate_time_value');
        that.scopeType = scopeObj.length > 0 ? scopeObj.val() : 'SmOwner_Search_All';	    //查看范围类型
        that.selectuserid = userIdObj.length > 0 ? userIdObj.val() : 'all';	                //查看范围用户ID
        that.search_date = dateObj.data('value') === 'custom' ? (dateObj.siblings('.laydate_time_hiddenvalue').val()) : dateObj.data('value');  //时间
        that.approve_value = typeof global_home_approve !== "undefined" ? global_home_approve.join(',') : 'all';
        that.getAjaxUrl();
    }

    this.getAjaxUrl = function () {
        that.AjaxUrl =  'index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&stuffName=TargetAnalysis';
        that.AjaxUrl += that.getUrlParam({
            stuffid : that.stuffid,
            boardid : that.boardid,
            scopeType : that.scopeType,
            selectuserid : that.selectuserid,
            search_date : that.search_date,
            approve_value : that.approve_value,
        });
    }

    this.getUrlParam = function (parmasArr) {
        var params = '';
        ld.each(parmasArr,function (key,val) {
            params += '&'+key+'='+encodeURIComponent(val);
        })
        return params;
    }

    this.setParams = function (ParamOption) {
        that.new_count = 0;
        that.targetGaugeListArr = {};
        that.PopupObj = ParamOption.PopupObj;
        that.PopupObj.TargetAnalysisObj = that;
        that.PopupJqObj = ld('#'+that.PopupObj.divid);
        that.targetid = ParamOption.selTargetId;
        that.scopeModuleList = ParamOption.scopeModuleList;
        that.NavBarList = ParamOption.NavBarList;
        that.stuffDetailList = ParamOption.stuffDetailList;
        that.SelStuffDetailList = ParamOption.SelStuffDetailList;
        that.targetGaugeListArr[that.targetid] = {
            selTargetId : ParamOption.selTargetId,
            scopeModuleList: that.scopeModuleList,
            SelStuffDetailList: that.SelStuffDetailList,
        };
        that.StuffDetailListObj = that.PopupJqObj.find('#StuffDetailList');
        that.emptyStuffDetailObj = that.PopupJqObj.find('#emptyStuffDetail');
        that.GaugeListObj =  that.PopupJqObj.find('#GaugeList');
        that.dataBindObj = new DataHtmlBind();
        var customList = that.StuffDetailListObj.find('#stufflabellist_ul_custom').find('li');
        if(customList.length > 0) {
            that.new_count = customList.length;
        }
    }

    this.init = function () {
        that.loadResources();
        that.showNavBarList();
        that.setEvent();
        that.showGaugeList();
    }
    
    this.loadResources = function () {
        AjaxJSPage('newChart_class','include/js/modules/Home/newChart_class.js');
        that.newChartObj = new newChart_class();
        that.newChartObj.setParams({stuffid: that.stuffid});
    }
    
    this.showNavBarList = function () {
        var LayoutObj = that.NavBarDom = that.PopupJqObj.find('#TargetNavBar').get(0);
        ld_NavBar.ShowNavBar(LayoutObj,that.NavBarList,{
            OnClick : function (evt) {
                that.ChangeSalesGoal(evt.NavBarItem.id);
                //console.log(evt);
            }
        });

        //布局设置、仪表盘设置
        ld_NavBar.ShowNavBar(that.PopupJqObj.find('#StuffDetailSetHead').get(0),[
            { name: 'LayoutSet',label: arrJsPopLabel['LAYOUTSETTING'],selected: 'yes'},
            { name: 'GaugeSet',label: arrJsPopLabel['GaugeSet'],selected: 'no'},
        ],{
            OnClick : function (evt) {
                var SetObj = that.PopupJqObj.find('#StuffDetailSet_'+evt.NavBarItem.name);
                SetObj.show();
                SetObj.siblings('.ld_saleskitset_layout').hide();
            }
        });
    }
    
    this.ChangeSalesGoal = function (newTargetId) {
        //targetid有变化，再操作
        if(newTargetId !== that.targetid){
            that.targetid = newTargetId;
            //是否已请求过
            if(that.targetGaugeListArr[newTargetId] !== undefined){
                that.refreshGaugeList(that.targetGaugeListArr[newTargetId]);
            }
            else{
                var parmas = that.getUrlParam({
                    mode : 'getGaugeListData',
                    targetid : that.targetid,
                });
                ldAjaxNoProgress(that.AjaxUrl,parmas,function (data) {
                    that.targetGaugeListArr[newTargetId] = data.result;
                    that.refreshGaugeList(data.result);
                });
            }
        }
    }

    this.refreshGaugeList = function (targetGaugeList) {
        that.scopeModuleList = targetGaugeList.scopeModuleList;
        that.SelStuffDetailList = targetGaugeList.SelStuffDetailList;

        //移除旧数据
        that.GaugeListObj.children().not('#emptyStuffDetail').remove();
        that.StuffDetailListObj.find('.ld_saleskitlist_stuff').removeClass('ld_listchosestuff');
        if(!that.LayoutSetNavBar){
            that.LayoutSetNavBar = that.PopupJqObj.find('#StuffDetailSetHead').find('[data-navbarname="LayoutSet"]')
        }
        that.LayoutSetNavBar.trigger('click');
        that.showGaugeList();
    }
    
    this.showGaugeList = function () {
        var GaugeList = that.SelStuffDetailList,
            ListInfo = that.StuffDetailListObj;
        ld.each(that.stuffDetailList,function (stufflabel,Info) {
            if(GaugeList.includes(stufflabel)){
                that.stuffDetailList[stufflabel].selected = true;
            }
            else{
                that.stuffDetailList[stufflabel].selected = false;
            }
            that.StuffDetailDblclick(ListInfo.find('#'+stufflabel)[0],'Init');
        });
    }
    
    this.appendGaugeToPage = function (StuffDetailInfo,targetJqObj) {
        if(targetJqObj === undefined){
            targetJqObj = that.emptyStuffDetailObj;
        }
        var stuffLabel = StuffDetailInfo.stufflabel,
            Gauge = that.getGaugeDiv(stuffLabel),
            index = targetJqObj.index();
        if(that.SelStuffDetailList[index] !== stuffLabel)
            that.SelStuffDetailList.splice(index,0,stuffLabel);
        targetJqObj.before(Gauge);
        that.getGaugeData(StuffDetailInfo);
        that.MiddleGaugeEvent(that.GaugeListObj.find('#targetanalysis_'+stuffLabel).get(0));
    }
    
    this.getGaugeDiv = function (stuffLabel) {
        return  '<div id="targetanalysis_'+stuffLabel+'" class="ld_targetanalysis_stuff stuffDetailDiv" style="" data-stufflabel="'+stuffLabel+'">' +
                    '<div class="ld-saleskitview-block-stuff-close" data-stufflabel="'+stuffLabel+'"><i class="icon-close"></i></div>' +
                    '<div class="ld_targetanalysis_content drag-handle ">' +
                        '<div id="gauge_'+stuffLabel+'" style="width: 100%;height: 100%"></div>' +
                    '</div>' +
                '</div>';
    }
    
    this.getGaugeData = function (StuffDetailInfo) {
        var parmas = that.getUrlParam({
                mode : 'getStuffDetailData',
                targetid : that.targetid,
                StuffDetailInfo : JSON.stringify(StuffDetailInfo),
            });
        ldAjaxNoProgress(that.AjaxUrl,parmas,function (data) {
            that.setGaugeOption(StuffDetailInfo.stufflabel,data.result);
        });
    }
    
    this.setGaugeOption = function (stuffLabel,data) {
        var newChartObj = that.newChartObj,
            ChartDom = that.PopupJqObj.find('#gauge_'+stuffLabel).get(0),
            myChart = echarts.init(ChartDom,echartTheme),
            option = {
                graphic : [],
                series : [],
            },
            left = '50%',
            radiusWidth = ChartDom.clientWidth * 0.42,
            radiusHeight = ChartDom.clientHeight * 0.35,
            radius = radiusWidth < radiusHeight ? radiusWidth : radiusHeight,
            gaugeData = {
                id: stuffLabel,
                label: data.title,
                rate: data.rate
            },
            gaugeSeries = newChartObj.getGaugeSeries(gaugeData,{
                name: stuffLabel,
                center : [left,'50%'],
                radius : radius,
            }),
            gaugeGraphic = newChartObj.getGaugeGraphic(data,{
                id: stuffLabel,
                left : left,
                top : '85%',
            });
        option.graphic.push(gaugeGraphic);
        option.series.push(gaugeSeries);
        myChart.setOption(option);
    }
    
    this.setEvent = function () {
        //搜索仪表盘
        that.SearchGauge();
        //左侧li标签仪表盘列表事件：拖动增加、双击增加
        that.BindLeftGaugeEvent();
        //中间预览姐买你仪表盘列表事件：拖动增加、拖动排序，单击设置详情
        that.BindMiddleGaugeEvent();
        //新增自定义龙虎榜
        that.AddNewGauge();
        //保存龙虎榜
        that.SaveGaugeList();
        //区块展开收起
        that.BindBlockEvent();
    }
    
    this.SearchGauge = function () {
        that.PopupJqObj.find('#StuffDetailSearchbox').on('keydown',function (){
            var search_str = ld(this).val();
            if(event.keyCode === 13 || search_str === '') {
                that.SearchFun(search_str);
            }
        });
        that.PopupJqObj.find('#searchBtn').on('click',function (){
            var search_str = ld(this).siblings('input').val();
            that.SearchFun(search_str);
        });
    }

    this.SearchFun = function (search_str) {
        var StuffLabelObjList = that.StuffDetailListObj,
            AllLiObj = StuffLabelObjList.find('li');
        if (search_str === '') {
            AllLiObj.show();
        } else {
            AllLiObj.hide();
            ld.each(that.stuffDetailList,function (StuffLabel,StuffLabelInfo) {
                if(StuffLabelInfo['label'].includes(search_str))
                    AllLiObj.filter('#'+StuffLabel).show();
            });
        }
        if(AllLiObj.filter(":visible").length > 0){
            StuffLabelObjList.find("[name=stuffdetail_notcontent]").hide();
        }else{
            StuffLabelObjList.find("[name=stuffdetail_notcontent]").show();
        }
    }

    this.BindLeftGaugeEvent = function () {
        var dragObjArr = that.StuffDetailListObj.find('ul');
        ld.each(dragObjArr,function (index,dragObj) {
            //绑定拖动
            Sortable.create(dragObj,{
                group: {
                    name : 'stuff',
                    pull : 'clone',
                    put : false,
                },
                draggable: '.drag-handle',
                animation: 150,
                sort: false,
                onEnd: function (evt) {
                    if(evt.to.nodeName !== 'UL'){
                        that.StuffDetailDblclick(evt.clone,'li',ld(evt.to));
                        ld(evt.item).remove();
                        tooltip(evt.clone, {transition: true, time: 200});
                    }
                },
                onMove : function (evt,originalEvent) {
                    /** return -1 元素头部插入、return 1 元素尾部插入、return false 取消插入 */
                    return -1;
                },
            });

            var liObjList = ld(dragObj).find('.ld_saleskitlist_stuff');
            //绑定双击
            liObjList.unbind('dblclick').bind('dblclick',function (){
                that.StuffDetailDblclick(this,'li');
            });

            //edit: xll 2024/02/04 双击选中文字的问题，必须使用 'mousedown' 事件，选中时mouseup时触发，而click事件处于 mouseup后
            liObjList.find('.tip-items-list').bind('mousedown',function (){
                //event.detail 只读属性，记录在短时间内事件触发的次数 第二次mousedown
                if(event.detail > 1){
                    event.preventDefault();
                }
            });
        });

        //自定义仪表盘删除事件
        dragObjArr.filter('#stufflabellist_ul_custom').find('.tag-close').bind('click',function () {
            var alert_str = arrJsPopLabel['COMFIRMTODELETE'],liObj = ld(this).parent('.ld_saleskitlist_stuff');
            RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", alert_str + arrJsPopLabel['WENHAO']);
            //确定按钮
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                var stuffLabel = liObj.attr('id'),
                    StuffLabelInfo = that.stuffDetailList[stuffLabel];
                ldAjax(that.AjaxUrl,that.getUrlParam({
                    mode : 'DeleteCustom',
                    DeleteStuffLabelInfo : JSON.stringify(StuffLabelInfo),
                }),function (data){
                    if(data.code==1){
                        delete that.stuffDetailList[stuffLabel];
                        liObj.remove();
                        DelProgressObjs();
                    }
                });
            });
        });
    }

    this.BindMiddleGaugeEvent = function () {
        var dragObjArr = that.GaugeListObj.find('.stuffDetailDiv');
        ld.each(dragObjArr,function (index,dragObj) {
            that.MiddleGaugeEvent(dragObj);
        });
    }
    
    this.MiddleGaugeEvent = function (gaugeDivDom) {
        Sortable.create(gaugeDivDom,{
            group: 'stuff',
            animation: 150,
            sort: true,
            //draggable: '.drag-handle',
            filter: '.ld_saleskitview_stuff_new',
            onStart : function (evt) {
                that.oldIndex = ld(evt.target).index();
            },
            onEnd: function (evt) {
                var toObj = ld(evt.to),
                    targetObj = ld(evt.target);
                toObj.before(evt.target);
                targetObj.append(evt.item);
                that.SelStuffDetailList.splice(that.oldIndex,1);
                that.SelStuffDetailList.splice(targetObj.index(),0,targetObj.data('stufflabel'));
            },
            onMove : function (evt,originalEvent) {
                return -1;
            },
        });
        var gaugeJqObj = ld(gaugeDivDom),
            DelObj = gaugeJqObj.find('.ld-saleskitview-block-stuff-close');
        gaugeJqObj.not('#emptyStuffDetail').unbind('click').bind('click',function () {
            that.showStuffDetailSet(ld(this).data('stufflabel'));
        })
        DelObj.unbind('click').bind('click',function () {
            var DetailLiDom = that.StuffDetailListObj.find('#'+ld(this).data('stufflabel')).get(0);
            that.StuffDetailDblclick(DetailLiDom,'li');
        });
    }

    this.AddNewGauge = function () {
        that.PopupJqObj.find('#addCustomStuffDetail').unbind('click').bind('click',function () {
            var new_count = that.new_count = that.new_count + 1,
                tmplabel = arrJsPopLabel['CustomGauge'] + new_count,
                tmp_stufflabel = 'NEW_' + new_count,
                customList = ld(this).siblings('ul');
            //增加li标签
            customList.append('' +
                '<li class="ld_saleskitlist_stuff drag-handle newCreate" id="'+tmp_stufflabel+'" data-new_count="'+new_count+'">' +
                    '<span class="tip-items-list" data-tip="'+tmplabel+'" data-direction="top" data-type="position" >' +
                        tmplabel +
                    '</span>' +
                    '<span class="tag""><i class="check"></i></span>' +
                    '<span class="tag-close" data-stufflabel="'+tmp_stufflabel+'">' + //
                        '<i class="icon-close"></i>' +
                    '</span>' +
                '</li>');
            var newLiObj = customList.children('.newCreate').last();
            that.stuffDetailList[tmp_stufflabel] = {
                homestuffdetailid: '',
                stufflabel: tmp_stufflabel,
                stufflabel_zh: tmplabel,
                stufflabel_en: tmplabel,
                is_default: "no",
                selected: "yes",
                sequence: null,
                label: tmplabel,
                SetValue: {
                    TargetScope: "Home",
                    TargetDate: "Month",
                    TargetDateFrom: "HomeEnd",
                    DoneScope: "Home",
                    DoneDate: "Month",
                    DoneDateFrom: "HomeEnd",
                    TargetTimeInfo: {
                        start: "2023-1",
                        end: "2023-12"
                    },
                    DoneTimeInfo: {
                        start: "2023-1",
                        end: "2023-12"
                    }
                }
            };
            //删除事件，未保存的简报仅需删除li标签即可
            newLiObj.children('.tag-close').bind('click',function () {
                var alert_str = arrJsPopLabel['COMFIRMTODELETE'];
                RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", alert_str + arrJsPopLabel['WENHAO']);
                //确定按钮
                ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                    var remove_stufflabel = newLiObj.attr('id');
                    delete that.stuffDetailList[remove_stufflabel];
                    newLiObj.remove();
                    var newCustomList = customList.children('.newCreate');
                    if(newCustomList.length > 0){
                        that.new_count = parseInt(newCustomList.last().data('new_count'));
                    }
                    else {
                        that.new_count = 0;
                    }
                });
            });
            //滚动到可视区域
            newLiObj.get(0).scrollIntoView({ behavior: "smooth" , block : "end"});
            //新增后默认选中
            that.StuffDetailDblclick(newLiObj.get(0),'NewCreate');
            newLiObj.unbind('dblclick').bind('dblclick',function () {
                that.StuffDetailDblclick(this,'li');
            });
            newLiObj.find('.tip-items-list').bind('mousedown',function (){
                if(event.detail > 1){
                    event.preventDefault();
                }
            });
            tooltip(newLiObj, {transition: true, time: 200});
        });
    }

    this.StuffDetailDblclick = function (DetaiLiDom,clickType,appendToJqObj) {
        var stuffLabel = DetaiLiDom.id,
            stuffLabelObj = ld(DetaiLiDom),
            stuffDetailInfo = that.stuffDetailList[stuffLabel];
        //双击已选中的取消选中，初始化按选中状态
        if( (clickType === 'li' && (stuffDetailInfo.selected === 'yes' || stuffDetailInfo.selected === true)) ||
            (clickType === 'Init' && (stuffDetailInfo.selected === 'no' || stuffDetailInfo.selected === false))
        ){
            //console.log(stuffDetailInfo)
            stuffDetailInfo.selected = 'no';
            ld.each(that.SelStuffDetailList,function (index,tmpStuffLabel) {
                if(tmpStuffLabel === stuffLabel){
                    that.SelStuffDetailList.splice(index,1);
                    return false;
                }
            });
            that.GaugeListObj.find('#targetanalysis_'+stuffLabel).remove();
            //移除选中状态
            stuffLabelObj.removeClass('ld_listchosestuff');
            stuffLabelObj.find('.tag').css('display','none');
            stuffLabelObj.removeClass('ld-dragontigerlist-shadow');
            //增加类drag-handle ，可拖动
            stuffLabelObj.addClass('drag-handle');
            //自定义简报悬浮删除 开启
            if(stuffDetailInfo.is_default === 'no')
                stuffLabelObj.addClass('ld-dragontigerlist-deleted');

            //右侧设置界面页签不变，将原选中的仪表盘设置界面清空，出现提示信息
            that.PopupJqObj.find('#StuffDetailSetDiv').html('');
            that.PopupJqObj.find('#emptyTip').show();
        }
        //双击未选中的选中
        else {
            stuffDetailInfo.selected = 'yes';
            that.appendGaugeToPage(stuffDetailInfo,appendToJqObj);
            //增加选中状态
            stuffLabelObj.addClass('ld_listchosestuff');
            //移除类drag-handle ，使不可拖动
            stuffLabelObj.removeClass('drag-handle');
            //自定义简报悬浮删除 关闭
            if(stuffDetailInfo.is_default === 'no')
                stuffLabelObj.removeClass('ld-dragontigerlist-deleted');
            if(clickType !== 'Init')
                that.showStuffDetailSet(stuffLabel);
        }
    }
    
    this.showStuffDetailSet = function (stuffLabel) {
        that.curStuffLabel = stuffLabel;
        //触发页签点击
        if(!that.GaugeSetNavBar){
            that.GaugeSetNavBar = that.PopupJqObj.find('#StuffDetailSetHead').find('[data-navbarname="GaugeSet"]')
        }
        that.GaugeSetNavBar.trigger('click');

        var generalSet =    '<div class="FieldBlock">' +
                                '<div class="marT20 FieldLabel Mandatory justifynormal">' +
                                    '<font color="red">*</font><span>'+arrJsPopLabel['ChineseName']+'</span>' +
                                '</div>' +
                                '<div class="marT5 marB15 FieldCon"><input type="text" id="ZHNAME" class="detailedViewTextBox" style="width: 100%; background:#F5F8FC; "></div>' +
                            '</div>' +
                            '<div class="FieldBlock">' +
                                '<div class="marT20 FieldLabel Mandatory justifynormal">' +
                                    '<font color="red">*</font><span>'+arrJsPopLabel['EnglishName']+'</span>' +
                                '</div>' +
                                '<div class="marT5 marB15 FieldCon">' +
                                    '<input type="text" id="ENNAME" class="detailedViewTextBox" style="width: 100%;background:#F5F8FC;">' +
                                '</div>' +
                            '</div>',
            SetObj = that.PopupJqObj.find('#StuffDetailSet_GaugeSet'),
            emptyTipObj = SetObj.find('#emptyTip'),
            SetConObj = SetObj.find('#StuffDetailSetDiv');
        emptyTipObj.hide();

        var SetBlockList = [
                { name : 'Done' ,label : arrJsPopLabel['DoneSet'],tipLabel: arrJsPopLabel['DoneSetTip']},
                { name : 'Target' ,label : arrJsPopLabel['TargetSet'],tipLabel: arrJsPopLabel['TargetSetTip']},
            ],
            Block = '';
        ld.each(SetBlockList,function (index,Info) {
            Block += that.getStuffDetailSetBlock(Info);
        })
        SetConObj.html(generalSet+Block);
        SetConObj.find('.SetBlockTitle').unbind('click').bind('click',function () {
            var headObj = ld(this),
                contentObj = headObj.next();
            that.BlockExpandingCollapse(ld(this),contentObj);
        })

        //双向绑定
        var stuffDetailInfo = that.stuffDetailList[stuffLabel];
        that.DataBindByArr([
            {id: 'ZHNAME',key: 'stufflabel_zh'},
            {id: 'ENNAME',key: 'stufflabel_en'},
        ],stuffDetailInfo);
        ld.each(['Target','Done'],function (index,type) {
            that.DataBindByArr([
                {id: type + '_viewRange',key: type + 'Scope'},
                {id: type + '_timeRange',key: type + 'Date'},
                {id: type + '_CurMonthFrom',key: type + 'DateFrom'},
            ],stuffDetailInfo.SetValue);
        });

    }
    
    this.getStuffDetailSetBlock = function (BlockInfo) {
        var BlockName = BlockInfo.name,
            BlockLabel = BlockInfo.label,
            tipLabel = BlockInfo.tipLabel;
        return '<div id="StuffDetailSetBlock_"'+BlockName+' class="SetBlockTitle" blocksatus="expand">' +
                    '<div class="BlockName"><span>'+BlockLabel+'</span></div>' +
                '</div>' +
                '<div style="height: unset;overflow: hidden;">' +
                    '<div id="StuffDetailSetBlock_"'+BlockName+' class="filtersetcard" style="margin: 10px 0 15px 0;padding: 0 10px">' +
                        '<div style="width: 100%;height:100%;margin: 15px 0" >' +
                            '<div class="component-setting-title" style="height: auto;line-height: 20px;margin: 10px 0;font-size: 16px;">' +
                                '<span>'+tipLabel+'</span>' +
                            '</div>' +
                            '<div class="component-setting-input input-group">' +
                                '<label>'+arrJsPopLabel['VIEWRANGE']+'</label>' + //<input type="checkbox" id="" class="second_switch marR5">
                                '<select class="commonSelectPop Bornone filterSelect" id="'+BlockName+'_viewRange" style="width: 55%">' +
                                    that.getViewRangeOption() +
                                '</select>' +
                            '</div>' +
                            '<div class="component-setting-input input-group">' +
                                '<label>'+arrJsPopLabel['TIMERANGE']+'</label>' +
                                '<select class="commonSelectPop Bornone filterSelect" id="'+BlockName+'_timeRange" style="width: 55%">' +
                                    that.getTimeRangeOption() +
                                '</select>' +
                            '</div>' +
                            '<div class="component-setting-input input-group">' +
                                '<label>'+arrJsPopLabel['CurMonthValue']+'</label>' +
                                '<select class="commonSelectPop Bornone filterSelect" id="'+BlockName+'_CurMonthFrom" style="width: 55%">' +
                                    '<option value="HomeStart">'+arrJsPopLabel['ByHomeDateStart']+'</option>' +
                                    '<option value="HomeEnd">'+arrJsPopLabel['ByHomeDateEnd']+'</option>' +
                                    '<option value="CurTime">'+arrJsPopLabel['CURRENTTIME']+'</option>' +
                                '</select>' +
                            '</div>' +
                        '</div>' +
                    '</div>' +
                '</div>';
    }
    
    this.getViewRangeOption = function () {
        return that.getOptionList(that.scopeModuleList,'module');
    }
    
    this.getTimeRangeOption = function () {
        return that.getOptionList([
            {value : 'Year',label: arrJsPopLabel['Annual']},
            {value : 'YearProgress',label: arrJsPopLabel['YearProgress']},
            {value : 'Quarter',label: arrJsPopLabel['QUARTERLY'] },
            {value : 'Month',label: arrJsPopLabel['CurMonthly']},
        ],'value');
    }

    this.getOptionList = function (OptionArr,valueKey) {
        var Option = '';
        ld.each(OptionArr,function (index,Info) {
            Option += '<option value="'+Info[valueKey]+'">'+Info.label+'</option>' ;
        });
        return Option;
    }
    
    this.DataBindByArr = function (BindArr,dataObj) {
        ld.each(BindArr,function (index,info) {
            var JqObj = that.PopupJqObj.find('#'+info.id);
            that.dataBindObj.setDataBindByJqObj(JqObj,dataObj,info.key);
            JqObj.unbind('change').bind('change',function () {
                that.getGaugeData(that.stuffDetailList[that.curStuffLabel]);
            });
        });
    }
    
    this.BindBlockEvent = function () {
        //左侧区块展开收起
        that.StuffDetailListObj.find(".ld_homeboard_stuff_title").unbind('click').bind('click',function (){
            var DGLType = ld(this).data('type'),
                ListTypeObj = that.StuffDetailListObj.find("#stufflabellist_"+DGLType);
            that.BlockExpandingCollapse(ld(this),ListTypeObj);
        });
    }
    
    this.BlockExpandingCollapse = function (headObj,contentObj) {
        //contentObj.css('height',scollheight);
        if(headObj.attr('blocksatus') === 'expand'){
            headObj.find('.icon-develop_active').removeClass('icon-develop_active');
            headObj.attr('blocksatus','collapse');
            contentObj.animate({ height: 0},300);
            contentObj.css('height','0px');
        }else{
            headObj.find('.icon-develop').addClass('icon-develop_active');
            headObj.attr('blocksatus','expand');
            contentObj.animate({ height: contentObj.get(0).scrollHeight+'px'},300);
        }
    }

    //保存
    this.SaveGaugeList = function () {
        that.PopupJqObj.find('#save').bind('click',function () {
            that.SaveTargetGaugeList()
        })
    }
    
    this.SaveTargetGaugeList = function () {
        //判断必填项
        var tmppass = true,confirm_str = '';
        ld.each(that.stuffDetailList,function(stuffLabel,stuffDetailInfo){
            if(empty(stuffDetailInfo.stufflabel_zh) || stuffDetailInfo.stufflabel_zh === ''){
                confirm_str = stuffDetailInfo.stufflabel + arrJsPopLabel['ChineseName'];
                tmppass = false;
                return false;
            }else if(empty(stuffDetailInfo.stufflabel_en) || stuffDetailInfo.stufflabel_en === ''){
                confirm_str = stuffDetailInfo.stufflabel + arrJsPopLabel['EnglishName'];
                tmppass = false;
                return false;
            }
        });
        if(!tmppass){
            confirm_str += arrJsPopLabel['Empty'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        var parmas = that.getUrlParam({
            mode : 'saveTargetGaugeList',
            stuffDetailList : JSON.stringify(that.stuffDetailList),
            targetGaugeListArr : JSON.stringify(that.targetGaugeListArr),
            rowNum: that.PopupJqObj.find('#saleskitset_layout_col').val(),
            rowHeight: that.PopupJqObj.find('#saleskitset_layout_height').val(),
        });
        ldAjaxNoProgress(that.AjaxUrl,parmas,function (data) {
            that.PopupObj.canceledit();
            var LayoutObj = ld('#stuff_'+that.stuffid).find('#sales_target_tab').get(0),
                curNavBar = ld_NavBar.getCurNavBar(LayoutObj).target;
            ld(curNavBar).trigger('click');
        });
    }
}
function EditTargetAnalysis(boardid,stuffid) {
    getJsScript('include/js/modules/Home/EditHomeStuffDetail.js', function () {
        var TargetAnalysisObj = new TargetAnalysis();
        TargetAnalysisObj.getHomeParams({
            boardid : boardid,
            stuffid : stuffid,
        });
        var ParamsOption = {
                surl: TargetAnalysisObj.AjaxUrl,
                params_data: TargetAnalysisObj.getUrlParam({
                    mode : 'EditTargetAnalysis',
                    stuff_height : ld('#stuff_'+stuffid).outerHeight(),
                }),
                delete_str: arrJsPopLabel['CancelTargetAnalysis'],
            };
        EditHomeStuffDetail(ParamsOption, function (PopupObj, ResData) {
            //console.log(ResData)
            var dataArr = ResData.result;
            TargetAnalysisObj.setParams({
                PopupObj : PopupObj,
                NavBarList : dataArr.NavBarList,
                stuffDetailList : dataArr.stuffDetailList,
                SelStuffDetailList : dataArr.SelStuffDetailList,
                selTargetId : dataArr.selTargetId,
                scopeModuleList : dataArr.scopeModuleList,
            });
            TargetAnalysisObj.init();

            tooltip('#'+PopupObj.divid+' .tip-items-list', {transition: true, time: 200});
        });
    })
}