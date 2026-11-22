/**
 * Edit: xll
 * Date: 2023/08/25
 * Reason: XUQIU1001645 ，PC龙虎榜组件的类，含设置龙虎榜的所偶有方法
 */
function DragonTigerList(){
    var that = this;
    var popupobj = CrmPopup.getPopupObj("last");
    popupobj.DragonTigerObj = that;
    var PopupJqObj = ld('#'+popupobj.divid);

    this.dragontigerlist_new_count = 0;
    this.DragonTigerList_JsonArr = {};
    this.CurStuffLabelInfo = {};
    this.stuffinfo = {
        stufflisttype : 'defaultstuff',
        stuffid : 100,
        stufftype : 'DragonTigerList',
    };
    this.stuffid = this.stuffinfo.stuffid;
    this.stufftype = this.stuffinfo.stufftype;
    this.boardid ;
    this.DragonTigerList_Seq = [];
    this.ClickFrom = '';      //是否点击页签，true则选中龙虎榜，false则将龙虎榜是否选中状态转换
    this.AfterPreview = {};

    this.init = function(){
        that.setEvent();
    }

    this.setBoardId = function (boardid) {
        that.boardid = boardid;
    }

    //初始化事件
    this.setEvent = function (){
        //搜索龙虎榜
        that.SearchDGL();
        //拖动龙虎榜排序
        that.SortDGL();
        //新增自定义龙虎榜
        that.AddNewDGL();
        //选中龙虎榜
        that.BindChooseDGL();
        //保存龙虎榜
        that.SaveDGL();
        //区块展开收起
        that.BindBlockEvent();
        //初始默认选中当前页签对应的龙虎榜，初次预览
        that.InitStuffLabel();
        //window.DragonTigerListObj = that;
    }
    
    this.BindBlockEvent = function () {
        var DGLListObj = PopupJqObj.find("#dragontigerlist");
        //edit: xll 2023/12/05 XUQIU1002171 龙虎榜优化，划分为两个区块
        DGLListObj.find(".ld_homeboard_stuff_title[name^=stufflist_title_]").unbind('click').bind('click',function (){
            var DGLType = ld(this).data('type');
            var ListTypeObj = DGLListObj.find(".ld_homeboard_stuff_list[name=stufflabellist_"+DGLType+"]");
            var scollheight = ListTypeObj.get(0).scrollHeight;
            ListTypeObj.css('height',scollheight+'px');
            if(ld(this).find('.icon-develop_active').length > 0){
                ld(this).find('.icon-develop_active').removeClass('icon-develop_active');
                ListTypeObj.animate({ height: 0},200);
                ListTypeObj.css('height','0px');
            }else{
                ld(this).find('.icon-develop').addClass('icon-develop_active');
            }
        });
    }

    //搜索龙虎榜
    this.SearchDGL = function (){
        PopupJqObj.find('#dragontiger_searchbox').on('keydown',function (){
            var search_str = ld(this).val();
            if(event.keyCode === 13 || search_str === '') {
                that.SearchDGLFun(search_str);
            }
        });
        PopupJqObj.find('#searchIcon').on('click',function (){
            var search_str = ld(this).siblings('input').val();
            that.SearchDGLFun(search_str);
        });
    }

    this.SearchDGLFun = function (search_str) {
        var StuffLabelObjList = PopupJqObj.find('#dragontigerlist');
        var AllLiObj = StuffLabelObjList.find('li');
        if (search_str === '') {
            AllLiObj.show();
        } else {
            AllLiObj.hide();
            ld.each(that.DragonTigerList_JsonArr,function (StuffLabel,StuffLabelInfo) {
                if(StuffLabelInfo['label'].includes(search_str))
                    AllLiObj.filter('#'+StuffLabel).show();
            });
        }
        if(AllLiObj.filter(":visible").length > 0){
            StuffLabelObjList.find("[name=dragontiger_list_notcontent]").hide();
        }else{
            StuffLabelObjList.find("[name=dragontiger_list_notcontent]").show();
        }
    }

    //拖动龙虎榜进行排序
    this.SortDGL = function (){
        that.getStuffLabelSeq();
        var sortObj = PopupJqObj.find(' #SortDragonTigerList');
        sortObj.bind('click',function () {
            var sortPopupObj = CrmPopup.load( arrJsPopLabel['SORT'], that.CompleteSort, "", 'LdPopWidth400px', '', "", arrJsPopLabel['Confirm'], "", arrJsPopLabel['CANCEL']);
            that.sortPopupObj = sortPopupObj;
            var html = '<div id="SortDragonTigrtDiv" style="width: 100%;height: 370px"></div>';
            CrmPopup.setPopupobjHtmlContent_scroll_jquery(sortPopupObj,html);
            var searchLabel = PopupJqObj.find('#dragontiger_searchbox').attr('placeholder');

            getJsScript('include/js/DragTransfer.js',function(){
                var SortDiv = ld('#'+sortPopupObj.divid).find("#SortDragonTigrtDiv");
                var RightObj = that.DragonTigerList_Seq;
                var Drag_Transfer = new DragTransfer();
                var labelOption = {
                    available: '',
                    selected: '',
                    placeholder: searchLabel,
                };
                Drag_Transfer.SetTranslabel(labelOption);
                Drag_Transfer.need_resetLabelClick = false;
                Drag_Transfer.SetDragTransfer(SortDiv,"",RightObj,'set','320');
            });
        })
        /*
        that.getStuffLabelSeq();
        var dragobj = PopupJqObj.find('#dragontigerlist').get(0);
        Sortable.create(dragobj, {
            draggable: '.drag-handle',
            animation: 150,
            sort: true,
            onEnd: function (evt) {
                var newIndex = evt.newIndex;
                var oldIndex = evt.oldIndex;
                var movedItem = that.DragonTigerList_Seq.splice(oldIndex, 1)[0];
                that.DragonTigerList_Seq.splice(newIndex, 0, movedItem);

                that.PreviewDGL();
            }
        });
         */
    }

    this.CompleteSort = function () {
        that.DragonTigerList_Seq = []; //清空列表
        var sortPopupObj = that.sortPopupObj;
        var DragonTigerList_JsonArr = that.DragonTigerList_JsonArr;
        var DGLList = ld('#'+sortPopupObj.divid).find("#selectedAssmablyColumns_Right input");
        ld.each(DGLList,function (index,Obj) {
            var tmpStuffLabel = ld(Obj).attr('id');
            var tmpInfo = DragonTigerList_JsonArr[tmpStuffLabel];
            that.PushSeqList(tmpInfo);
        });
        that.PreviewDGL();
        sortPopupObj.CancelEvent();
    }

    this.getStuffLabelSeq = function () {
        if(that.DragonTigerList_Seq.length === 0){
            var DragonTigerList_JsonArr = that.DragonTigerList_JsonArr;
            ld.each(DragonTigerList_JsonArr,function (StuffLabel,StuffLabelInfo) {
                if(StuffLabelInfo.selected === 'yes'){
                    that.PushSeqList(StuffLabelInfo);
                }
            });
        }
        return that.DragonTigerList_Seq;
    }

    this.PushSeqList = function (StuffLabelInfo) {
        var tmpInfo = {
            value : StuffLabelInfo.stufflabel,
            text : StuffLabelInfo.label,
        }
        tmpInfo = Object.assign(tmpInfo,StuffLabelInfo);
        that.DragonTigerList_Seq.push(tmpInfo);
        StuffLabelInfo.seqIndex = that.DragonTigerList_Seq.length - 1;
    }

    //新增自定义龙虎榜
    this.AddNewDGL = function (){
        PopupJqObj.find(' #addCustomDrangonTigerList').unbind('click').bind('click',function (){
            that.dragontigerlist_new_count=that.dragontigerlist_new_count+1;
            var tmplabel = arrJsPopLabel['ADDCUSTOMDRAGONTIGER']+that.dragontigerlist_new_count;
            var tmp_stufflabel = 'custom_dragontiger_'+that.dragontigerlist_new_count+'_new';
            //增加li标签
            PopupJqObj.find('#dragontigerstuff_custom').append('' +
                ' <li class="ld_saleskitlist_stuff drag-handle" id="'+tmp_stufflabel+'" title="'+tmplabel+'">' +
                '     <span class="tip-items-list" data-tip="'+tmplabel+'" data-direction="top" data-type="position">'+
                          tmplabel +
                '     </span>' +
                '     <span class="tag"  style="display: none;"><i class="check"></i></span>' +
                '     <span class="tag-close"><i class="icon-close"></i></span>' +
                '</li>');
            //自定义
            that.DragonTigerList_JsonArr[tmp_stufflabel] = {
                'homestuffdetailid':'',
                'stufflabel':tmp_stufflabel,
                'selected':'yes',
                'zh':tmplabel,
                'en':tmplabel,
                'label':tmplabel,
                'computeinfo':[
                    {

                    },
                ],
                'sequence':'',
                'icon':'',
                'css':'',
                'is_default':'no',
                'topnumber':5,
                'SetValue':[{'showZero':false,'can_penetrate':true}]
            };
            //绑定点击
            var CurStuffLabelObj = PopupJqObj.find('#'+tmp_stufflabel);
            CurStuffLabelObj.unbind('click').bind('click',function (){
                that.ClickFrom = 'LiItem';
                that.ChooseDGL(this);
            });
            //自定义龙虎榜删除事件
            CurStuffLabelObj.find('.tag-close').unbind('click').bind('click',function (){
                that.DeleteCustom(this,'New');
            });
            //拖动
            //that.SortDGL();
            //默认选中新增的龙虎榜
            that.ClickFrom = 'NewButton';
            that.ChooseDGL(CurStuffLabelObj);
            //滚动到该龙虎榜
            that.ScrollToCurStuffLabel();
        });
    }

    //选中龙虎榜事件绑定
    this.BindChooseDGL = function (){
        //每个标签绑定选中事件
        PopupJqObj.find('.ld_saleskitlist_stuff').unbind('click').bind('click',function (){
            that.ClickFrom = 'LiItem';
            that.ChooseDGL(this);
        });
        //预览区域的点击事件也触发选中
        PopupJqObj.find('#stuff_'+that.stuffid).unbind('click').bind('click',function (){
            //设置延迟，先进行页签点击事件、后进行选中对应龙虎榜
            setTimeout(() => {
                that.InitStuffLabel();
            }, 100);
        });
        //自定义龙虎榜删除事件绑定
        PopupJqObj.find('.ld_saleskitlist_stuff .tag-close').unbind('click').bind('click',function (){
            that.DeleteCustom(this,'Old');
        });
    }

    //初始化龙虎榜，选中当前页签对应的龙虎榜
    this.InitStuffLabel = function () {
        var CurStuffLabelObj = PopupJqObj.find('#sales_target_tab').find('.ld-NavBarList').children('.cur');
        if(CurStuffLabelObj.length > 0) {
            var CurStuffLabel = CurStuffLabelObj.attr('data-NavBarName');
            var ChooseObj = PopupJqObj.find('#'+CurStuffLabel).get(0);
            that.ClickFrom = 'NavBarItem';
            that.ChooseDGL(ChooseObj);
            that.ScrollToCurStuffLabel();
        }
        else {
            that.AfterPreview.InitStuffLabel = that.InitStuffLabel;
            that.PreviewDGL();
        }
    }

    //滚动到当前页签所处的li标签
    this.ScrollToCurStuffLabel = function () {
        var CurStuffLabelObj = PopupJqObj.find('#'+that.CurStuffLabelInfo.stufflabel);
        CurStuffLabelObj.get(0).scrollIntoView({ behavior: "smooth" , block : "end"});
    }

    //选中龙虎榜函数
    this.ChooseDGL = function (ChooseObj) {
        //当前选择的stuff对象
        var ChooseStuffLabel = ld(ChooseObj).attr('id');
        var CurStuffLabelInfo = that.DragonTigerList_JsonArr[ChooseStuffLabel];
        //点击默认开启
        //点击选中、再次点击关闭
        if((CurStuffLabelInfo.selected === true || CurStuffLabelInfo.selected === 'yes') && that.ClickFrom === 'LiItem') {
            CurStuffLabelInfo.selected = false;
            ld(ChooseObj).addClass('ld-dragontigerlist-deleted');
            ld.each(that.DragonTigerList_Seq,function (index,tmpInfo) {
                if(tmpInfo.stufflabel === ChooseStuffLabel){
                    that.DragonTigerList_Seq.splice(index,1);
                    return false;
                }
            });
        } else {
            CurStuffLabelInfo.selected = true;
            ld(ChooseObj).removeClass('ld-dragontigerlist-deleted');
            if(that.ClickFrom === 'LiItem' || that.ClickFrom === 'NewButton')
                that.PushSeqList(CurStuffLabelInfo);
        }
        //that.ClickFrom = '';
        that.CurStuffLabelInfo = CurStuffLabelInfo;

        //标签样式修改
        PopupJqObj.find('.ld_saleskitlist_stuff').css('border','');
        //ld(ChooseObj).siblings().removeClass('choose');
        //去除其他标签的选中
        PopupJqObj.find('#dragontigerlist ul li.drag-handle').removeClass('choose');
        ld(ChooseObj).addClass('choose');
        //标签打勾
        that.ChossCurStuffLabelObj();

        //右侧设置界面的展示
        PopupJqObj.find('.ld_saleskitset_saleskitset').addClass('ld_saleskitset_saleskitset_border');
        PopupJqObj.find('.ld_saleskitset_layout').show();

        //获取统计条件内容
        that.StuffDetailSearchContent();

    }

    //对当前的龙虎榜设置进行预览展示，默认展示选中的页签
    this.PreviewDGL = function () {
        if(that.ClickFrom === 'NavBarItem') {
            that.ClickFrom = '';
            return false;
        }
        that.ClickFrom = '';
        var CurStuffLabel = that.CurStuffLabelInfo.stufflabel;
        if(that.CurStuffLabelInfo.selected === false || that.CurStuffLabelInfo.selected === 'no')
            CurStuffLabel = '';
        var PageTabList = that.DragonTigerList_Seq;
        var url = 'index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&mode=getStuffPageTabHtml';
        var params = '&DefaultStuffLabel='+CurStuffLabel+'&PageTabList='+JSON.stringify(PageTabList);
        params += '&getPageTabList=yes';
        ldAjax(url,params,function (data){
            if(data.code==1){
                //ld('#'+ popupobj.divid + ' #maincont_row_'+that.stuffid).find('.tab').html(data.result.PageTabHtml);
                //console.log(data);
                LoadStuffNavBar_callback(that.stuffid,data);
                if(that.AfterPreview.InitStuffLabel) {
                    that.AfterPreview.InitStuffLabel();
                    delete that.AfterPreview.InitStuffLabel;
                }
                that.PreviewChart();
                DelProgressObjs();
            }
        });
    }

    //加载echarts图表
    this.PreviewChart = function () {
        if(!that.previewChartObj)
            that.previewChartObj = PopupJqObj.find('#preview_stuffcont_'+that.stuffid)
        if(that.DragonTigerList_Seq.length === 0){
            that.previewChartObj.before(`<div style="display: flex;justify-content: center;align-items: center;width: 100%;height: 100%;">${'+' + arrJsPopLabel['EditDragonTigerEmptyTip']}</div>`);
            that.previewChartObj.css('display','none');
        }
        else{
            that.previewChartObj.css('display','block');
            that.previewChartObj.siblings().remove();
        }
        loadStuff(that.stuffid,that.stufftype,'');
    }

    //设置中非查询条件的内容的展示（修改值、双向绑定）
    this.ShowDGLSet = function () {
        //修改界面内容和值保持一致，并进行双向绑定
        var CurStuffLabelInfo = that.CurStuffLabelInfo;
        var databindSetarr = {
            'isenable': 'selected',     //是否启用
            'ZHNAME': 'zh',  //中文标签
            'ENNAME': 'en',  //英文标签
            'topnumber': 'topnumber',  //英文标签
        };
        that.DataBindByArr(databindSetarr,CurStuffLabelInfo);
        var setValArr = {
            'showZero': 'showZero',  //英文标签
            'can_penetrate': 'can_penetrate',  //是否能穿透
        };
        console.log(CurStuffLabelInfo['SetValue']);
        if(typeof CurStuffLabelInfo['SetValue'].length !== "undefined" && CurStuffLabelInfo['SetValue'].length === 0)
            CurStuffLabelInfo['SetValue'] = {};
        that.DataBindByArr(setValArr,CurStuffLabelInfo['SetValue']);
    }

    //根据DOM对象的id，json对应数据键名构成的json对象进行双向绑定
    //并在绑定前修改界面内容与数值一致
    this.DataBindByArr = function (databindSetarr,dataObj){
        if(typeof that.DataHtmlBindObj === "undefined")
            that.DataHtmlBindObj = new DataHtmlBind();
        ld.each(databindSetarr,function (JqueryObjId,KeyName) {
            //根据类型修改值为一致
            var JqueryObj = PopupJqObj.find('#'+JqueryObjId);
            if(JqueryObj.length > 0){
                var Data = dataObj[KeyName];
                var NodeName = PopupJqObj.find('#'+JqueryObjId)[0].localName;
                var NodeType = '';
                if(NodeName === 'input')
                    NodeType =  '_' + PopupJqObj.find('#'+JqueryObjId)[0].type;
                var fun_name = 'modify_' + NodeName + NodeType;
                that.modify_fun[fun_name](JqueryObj,Data);
                //进行绑定
                that.DataHtmlBindObj.setDataBindByJqObj(JqueryObj,dataObj,KeyName);
            } else {
                console.log('JqueryObj ' + JqueryObjId + ' is not exists');
            }
        });
    }

    //各Dom元素类型修改值的方法集合
    this.modify_fun = {
        modify_input_checkbox : function (JqueryObj,Data){
            var tmpvalue = (Data=='yes' || Data==true) ? true : false;
            //edit: xll 2023/09/04 BUG0072087 数据龙虎榜点击默认开启
            ld(JqueryObj).prop('checked',tmpvalue);
        },
        modify_input_text : function (JqueryObj,Data){
            ld(JqueryObj).val(Data);
        },
        modify_select : function (JqueryObj,Data) {

            if(Data == ''||Data == null)
                ld(JqueryObj).prop('selectedIndex',0);
            else
                ld(JqueryObj).val(Data);
            //设置下拉款可搜索
            var width = JqueryObj.parents('.FieldBlock').outerWidth();
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(JqueryObj.attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(popupobj);

            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(JqueryObj,width);
        }
    }

    //统计模块部分的修改值及双向绑定
    this.ShowDGLSearchSet = function () {
        var CurStuffLabelInfo = that.CurStuffLabelInfo;
        var is_default = CurStuffLabelInfo.is_default;
        //修改值一致、双向绑定
        var computeinfo_arr = CurStuffLabelInfo.computeinfo;
        //需要循环
        ld.each(computeinfo_arr,function (index,computeinfo) {
            var computetype = computeinfo.computetype;
            var databindSetarr = { };
            databindSetarr['mainmodule_' + index] = 'computemodule';    //统计模块
            databindSetarr['computetype_' + index] = 'computetype';     //统计类型
            databindSetarr['computecolumns_' + computetype + '_' + index] = 'computecolumns';   //统计字段
            databindSetarr['groupby_' + index] = 'groupby';         //分组字段
            databindSetarr['viewrange_' + index] = 'viewrange';         //查看范围
            databindSetarr['daterange_' + index] = 'daterange';         //时间范围
            databindSetarr['viewrange_isrelated_' + index] = 'viewrange_isrelated';   //是否开启查看范围
            databindSetarr['daterange_isrelated_' + index] = 'daterange_isrelated';   //是否开启时间范围
            that.DataBindByArr(databindSetarr,computeinfo);
        });
    }

    //设置区域的事件绑定
    this.setSearchSetEvent = function () {
        //要绑定的对象id和事件类型
        var ObjIdArr = {
            'isenable': 'change',     //是否启用
            'ZHNAME': 'change',     //中文名
            'ENNAME': 'change',     //英文名
        };
        that.SetObjEvent(ObjIdArr);
        var computeinfo_arr = that.CurStuffLabelInfo.computeinfo;
        ld.each(computeinfo_arr,function (index,computeinfo) {
            var SearchObjIdArr = {};
            SearchObjIdArr['mainmodule_'+index] = 'change';
            SearchObjIdArr['computetype_'+index] = 'change';
            SearchObjIdArr['otherconditions_'+index] = 'click';
            SearchObjIdArr['viewrange_isrelated_'+index] = 'change';
            SearchObjIdArr['daterange_isrelated_'+index] = 'change';
            that.SetObjEvent(SearchObjIdArr);
        });
    }

    //根据ObjIdArr数组，对界面中的Dom元素进行事件绑定
    this.SetObjEvent = function (ObjIdArr) {
        //ObjIdArr，json格式，键名为对象id，键值为事件类型
        ld.each(ObjIdArr,function (ObjId,EventType) {
            var Obj = PopupJqObj.find('#'+ObjId);
            var ObjIdArr = ObjId.split("_");
            ObjIdArr.length > 1 && (ObjIdArr.pop())
            var ObjName = ObjIdArr.join('_');
            var Fun_Name = EventType + '_' + ObjName;

            if(Obj.length>0 && that.SetObjEvent_Fun[Fun_Name]){
                PopupJqObj.find('#'+ObjId).unbind(EventType).bind(EventType,function (){
                    var JqueryObj = this;
                    that.SetObjEvent_Fun[Fun_Name](JqueryObj);
                });
            } else {
                console.log('Bind Error');
                console.log(ObjName);
                console.log(Obj);
                console.log(that.SetObjEvent_Fun[Fun_Name]);
            }
        });
    }

    //Dom对象事件的方法集合
    this.SetObjEvent_Fun = {
        change_isenable : function (JqueryObj) {
            that.ClickFrom = 'LiItem';
            ld(JqueryObj).prop('checked',!ld(JqueryObj).prop('checked'));
            that.ChooseDGL(PopupJqObj.find('#'+that.CurStuffLabelInfo.stufflabel));
            //开启关闭都需要重新展示预览
            that.PreviewDGL();
        },
        change_mainmodule : function (JqueryObj) {
            var computeinfo_arr = that.CurStuffLabelInfo.computeinfo;
            var ObjId = ld(JqueryObj).attr('id');
            var ObjIndex = ObjId.split('_')[1];
            var selectedmodule = computeinfo_arr[ObjIndex].computemodule;
            that.getModuleFields(selectedmodule,ObjIndex);
        },
        change_computetype : function (JqueryObj) {
            var computeinfo_arr = that.CurStuffLabelInfo.computeinfo;
            var ObjIndex = ld(JqueryObj).attr('rowindex');
            var computetype = computeinfo_arr[ObjIndex].computetype;
            var SelectColumnObjId = 'computecolumns_'+computetype+'_'+ObjIndex;
            var SelectColumnObj = PopupJqObj.find('#'+SelectColumnObjId);
            var OtherSelectObj = SelectColumnObj.siblings();
            OtherSelectObj.hide();
            SelectColumnObj.show();
            var width = SelectColumnObj.parent().outerWidth();
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(SelectColumnObj.attr("name"));
            cls_resetComboxHtmlobj.setPopupObj(popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(SelectColumnObj,width);

            //计算方法改变、需要重新进行绑定，否则统计字段仍读取初次次被绑定的下拉框值
            var databindSetarr = { };
            databindSetarr[SelectColumnObjId] = 'computecolumns';   //统计字段
            that.DataBindByArr(databindSetarr,computeinfo_arr[ObjIndex]);
        },
        click_otherconditions : function (JqueryObj) {
            var rowindex = ld(JqueryObj).attr('rowindex');
            var CurStuffLabelInfo = that.CurStuffLabelInfo;
            getJsScript('include/js/modules/Home/SetOtherConditions.js', function () {
                var SetOtherConditionsObj = new SetOtherConditions();
                SetOtherConditionsObj.SetDirDataObjByRowIndex(CurStuffLabelInfo,rowindex);
                SetOtherConditionsObj.fun_other_conditions();
            });
        },
        change_ZHNAME : function (JqueryObj) {
            if(language === 'zh-cn'){
                var new_ZHNAME = ld(JqueryObj).val();
                that.ChangeName(new_ZHNAME);
            }
        },
        change_ENNAME : function (JqueryObj) {
            if(language === 'en'){
                var new_ENNAME = ld(JqueryObj).val();
                that.ChangeName(new_ENNAME);
            }
        },
        change_viewrange_isrelated : function(JqueryObj){
            var controlid = ld(JqueryObj).attr('name');
            PopupJqObj.find('[data-control='+controlid+']').toggle();
            //BUG20241118-60 当开启了允许穿透的参数，筛选器查看范围映射字段开启再关闭后，允许穿透参数应该也是关闭状态
            var curstatus = ld(JqueryObj).prop('checked');
            if(curstatus==false){
                PopupJqObj.find('#can_penetrate').prop('checked',false);
            }
        },
        change_daterange_isrelated : function(JqueryObj){
            var controlid = ld(JqueryObj).attr('name');
            PopupJqObj.find('[data-control='+controlid+']').toggle();
        }
    }
    
    this.ChangeName = function (NewName) {
        //页签内容变化
        var CurStuffLabel = that.CurStuffLabelInfo.stufflabel;
        var PageTabListObj = PopupJqObj.find('#maincont_row_'+that.stuffid + ' .tab');
        var CurPageTabObj =  PageTabListObj.find('[data-NavBarName='+CurStuffLabel+']');
        CurPageTabObj.text(NewName);
        CurPageTabObj.attr('data-tip',NewName);
        //li标签内容变化
        var CurStuffLabelObj = PopupJqObj.find('#'+that.CurStuffLabelInfo.stufflabel);
        CurStuffLabelObj.find('span').text(NewName);
    }

    this.ChossCurStuffLabelObj = function () {
        var CurStuffLabelObj = PopupJqObj.find('#'+that.CurStuffLabelInfo.stufflabel);
        var isenable = that.CurStuffLabelInfo.selected;
        if(isenable===true || isenable==='yes'){
            CurStuffLabelObj.addClass('ld-dragontigerlist-shadow');
            CurStuffLabelObj.addClass('ld-dragontigerlist-selected');
            CurStuffLabelObj.find('.tag').show();
        }else if(isenable===false || isenable==='no'){
            CurStuffLabelObj.removeClass('ld-dragontigerlist-shadow');
            CurStuffLabelObj.removeClass('ld-dragontigerlist-selected');
            CurStuffLabelObj.find('.tag').hide();
        }
    }

    //展示选中组件类型的查询条件设置界面
    this.StuffDetailSearchContent = function (){
        var CurStuffLabelInfo = that.CurStuffLabelInfo;
        var computeinfo = '';
        if(CurStuffLabelInfo.computeinfo.length>0){
            computeinfo = JSON.stringify(CurStuffLabelInfo.computeinfo);
        }
        var params = '&computeinfo='+computeinfo;
        params += '&boardid='+that.boardid;
        var url = 'index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&mode=getStuffDetailSetContent';
        ldAjax(url,params,function (data){
            if(data.code==1){
                //查询条件部分的设置内容
                var StuffDetailSearchHtml = data.result.StuffDetailSearchHtml;
                CurStuffLabelInfo.computeinfo = data.result.computeinfo_arr;
                PopupJqObj.find('#StuffDetailSearch').html(StuffDetailSearchHtml);
                //设置界面的事件绑定
                that.setSearchSetEvent();
                //展示查询条件部分的设置内容（初始化、双向绑定）
                that.ShowDGLSet();
                that.ShowDGLSearchSet();
                //中间界面的预览效果
                that.PreviewDGL();
                DelProgressObjs();
            }
        });
    }

    //根据模块获取字段
    this.getModuleFields = function (selectedmodule,ObjIndex=0){
        var params = '&selectedmodule='+selectedmodule;
        params += '&boardid='+that.boardid;
        var url = 'index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&mode=getModuleFields';
        ldAjax(url,params,function (data){
            if(data.code==1){
                var modulefield_arr = data.result;
                //更改其他select框的option
                var SelectObjIdArr = { };
                SelectObjIdArr['computecolumns_sum_'+ObjIndex] = 'sumFieldOption';
                SelectObjIdArr['computecolumns_count_'+ObjIndex] = 'countFieldOption';
                SelectObjIdArr['groupby_'+ObjIndex] = 'smowneridFieldOption';//分组字段
                SelectObjIdArr['viewrange_'+ObjIndex] = 'smowneridFieldOption';
                SelectObjIdArr['daterange_'+ObjIndex] = 'timeFieldOption';
                ld.each(SelectObjIdArr,function (ObjId,DataKey) {
                    var SelectObj = PopupJqObj.find('#'+ObjId);
                    SelectObj.html(modulefield_arr[DataKey]);
                });
                DelProgressObjs();
            }
        });
    }

    this.DeleteCustom = function (DeleteCustomObj,DelType) {
        event.preventDefault();
        event.stopPropagation();
        var StuffLabelObj = ld(DeleteCustomObj).parent();
        var DeleteCustomStuffLabel = StuffLabelObj.attr('id');
        if(!DeleteCustomStuffLabel)
            return false;
        var alert_str=arrJsPopLabel['COMFIRMTODELETE'];
        RemindsMsg("", "LdPopWidth400px", '', "yes", "yes", alert_str + arrJsPopLabel['WENHAO']);
        //确定按钮
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
            that.DeleteCustomDGL[DelType](DeleteCustomStuffLabel);
            StuffLabelObj.remove();
        });
    }

    this.DeleteCustomDGL = {
        //新增加的直接删除即可
        New : function (DeleteCustomStuffLabel) {
            delete that.DragonTigerList_JsonArr[DeleteCustomStuffLabel];
        },
        //已存数据库的需要删除数据
        Old : function (DeleteCustomStuffLabel) {
            var DeleteStuffLabelInfo = that.DragonTigerList_JsonArr[DeleteCustomStuffLabel];
            var params = '&DeleteStuffLabelInfo='+JSON.stringify(DeleteStuffLabelInfo);
            params += '&boardid='+that.boardid;
            var url = 'index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&mode=DeleteCustom';
            ldAjax(url,params,function (data){
                if(data.code==1){
                    that.DeleteCustomDGL.New(DeleteCustomStuffLabel);
                    DelProgressObjs();
                }
            });
        }
    }

    //保存龙虎榜
    this.SaveDGL = function (){
        PopupJqObj.find('#save').unbind('click').bind('click',function(){
            //判断必填项
            var tmppass=true;
            ld.each(that.DragonTigerList_JsonArr,function(index,item){
                if(item.is_default === 'yes'){
                    tmppass=true;
                }else{
                    var confirm_str;
                    if(empty(item.zh) ||item.zh===''){
                        confirm_str = item.label+arrJsPopLabel['ChineseName']+arrJsPopLabel['Empty'];
                        tmppass=false;
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }else if(empty(item.en) ||item.en===''){
                        confirm_str = item.label+arrJsPopLabel['EnglishName']+arrJsPopLabel['Empty'];
                        tmppass=false;
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                        return false;
                    }
                }
            });
            if(!tmppass){
                return false;
            }
            //获取排列顺序
            ld.each(that.DragonTigerList_Seq,function (index,info){
                var tmpstufflabel = info.stufflabel;
                var curobj = that.DragonTigerList_JsonArr[tmpstufflabel];
                curobj.sequence = index + 1;
            });
            var SaveInfo = that.DragonTigerList_JsonArr;
            SaveInfo=JSON.stringify(SaveInfo);
            var boardid = that.boardid,stuffid=that.stuffid;
            var url='index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&mode=SaveDragonTigerList';
            var param='&boardid='+boardid+'&DragonTigerListInfo='+SaveInfo+'&stuffid='+stuffid;
            ldAjax(url,param,function(data){
                if(data.code==1){
                    newChart_class.refresh_stuff(stuffid,that.stuffinfo,boardid);
                    DelProgressObjs();
                    popupobj.canceledit();
                }
            })
        });
    }
}


//设置龙虎榜
function EditDragonTigerList(event,boardid){
    getJsScript('include/js/modules/Home/EditHomeStuffDetail.js', function () {
        var stuffid = 100,
            ParamsOption = {
                surl: "index.php?module=Home&action=HomeAjax&file=DragonTigerListSet&mode=EditDragonTigerList&boardid="+boardid,
                params_data: '&stuff_height='+ld('#stuff_'+stuffid).outerHeight()+'&stuffName=DragonTigerList&stuffid='+stuffid,
                delete_str: arrJsPopLabel['CANCELDRAGONTIGERLIST'],
            };
        EditHomeStuffDetail(ParamsOption, function (PopupObj, ResData) {
            var cls_DragonlistSetobj = new DragonTigerList();
            cls_DragonlistSetobj.setBoardId(boardid);
            cls_DragonlistSetobj.DragonTigerList_JsonArr = ResData.result.drangontigerlist;
            cls_DragonlistSetobj.init();
            PopupObj.drangontigerSetobj = cls_DragonlistSetobj;

            tooltip('#'+PopupObj.divid+' .tip-items-list', {transition: true, time: 200});
        });
    });
}



