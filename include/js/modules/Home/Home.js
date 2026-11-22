//获取首页参数 时间人员审批条件  用来获取简报数据
getHomeAllParams = function(){
    var scopeType = empty(ld('#HomeSmOwnerSearchScope'))?'SmOwner_Search_All':ld('#HomeSmOwnerSearchScope').val();	//查看范围类型
    var selectuserid = empty(ld('#selectuserid'))?'all':ld('#selectuserid').val();	//查看范围用户ID
    var search_date = ld(' .home-header-filter-select .header_value').attr('data-value');
    if(search_date=='custom'){
        search_date= ld("#begin_date").val()+"~"+ ld("#end_date").val();
    }
    //wyt 221114 首页日历默认值
    if(ld(' .home_laydate_div').css('display') == 'block'){
        search_date = ld(' .home_laydate_div .laydate_time_value').attr('data-value');
        if(search_date=='custom') {
            search_date = ld(' .home_laydate_div .laydate_time_hiddenvalue').val();
            search_date = search_date.replace(' - ', '~');
        }
    }
    var search_date_custom_value = typeof search_date=="undefined"?'thismonth':search_date; //自定义查询
    var approve_value = getHomeApproveStatusValue();//审批条件
    var boardid = 0;
    //如果是编辑看板  需要传编辑看板的ID
    var editHomeboardPopobj = CrmPopup.getPopupObj("last");
    if(editHomeboardPopobj && editHomeboardPopobj.divid && editHomeboardPopobj.boardtype){
        boardid = ld('#'+editHomeboardPopobj.divid).find('#boardid').val();
    }
    else if(ld('#boardid')!= undefined&&ld('#boardid').val()!=undefined){
        boardid = ld('#boardid').val();
    }
    var params = "&boardid="+boardid+'&search_date='+search_date+"&search_date_custom_value="+search_date_custom_value+"&approve_value="+approve_value;
    params += "&scopeType="+scopeType+"&selectuserid="+selectuserid+"&selectuid="+selectuserid;
    //用户id 有的地方用selectuserid有的地方用selectuid 那就两个都传吧。-_-
    return params;
}
getHomeApproveStatusValue = function(){
    var approvestatus = [];
    if(typeof global_home_approve !== "undefined"){
        approvestatus = global_home_approve;
    }else{
        ld('input[name="approve_header_select_value[]"]:checked').each(function(){
            approvestatus.push(this.value);
        });
    }
    var approve_value = '';
    if(approvestatus.length == 5 || approvestatus.length == 0){
        approve_value = 'all';
    }else{
        approve_value = approvestatus.join(',');
    }
    return approve_value;
}
//新看板的销售简报设置按钮点击事件
function EditSalesKitSetReport(event,jueryobj,stuffid,tmp,boardid,boardtype){
    getJsScript('include/js/modules/Home/EditHomeStuffDetail.js', function () {
        //首页参数  时间人员审批条件  用来获取简报数据
        var params = getHomeAllParams();
        var stuffId = 35;
        params+='&stuffid='+stuffId;
        var ParamsOption = {
            surl : 'index.php?module=Home&action=HomeAjax&file=SalesKitSet&stuffid='+stuffId+'&mode=NewSalesKitSet&boardid='+boardid+'&boardtype='+boardtype,
            params_data : params,
            delete_str : arrJsPopLabel['CANCELSALESKITSETCHECK'],
        };
        EditHomeStuffDetail(ParamsOption,function (PopupObj,ResData) {
            getJsScript('include/js/modules/Home/SalesKitSetReport.js', function () {
                var dataArr = ResData.result,
                    cls_SalesKitSetobj = new SalesKitSetReport();
                cls_SalesKitSetobj.init();
                cls_SalesKitSetobj.setEvent();
                PopupObj.salesKitSetobj = cls_SalesKitSetobj;

                //zxm 20230725
                //双向绑定简报全局设置信息
                cls_SalesKitSetobj.saleskit_layout = dataArr.saleskit_layout;//简报全局设置信息
                var boardtype = dataArr.saleskit_layout.boardtype;
                //edit: xll 2024/07/02 BUG20240605-41 移动端简报显示同比
                var databindSetarr = {
                        'saleskitset_layout_col': 'colcount',//每行简报数量
                        // 'saleskitset_layout_height': 'height',//每行简报高度
                        'isshowprevious': 'isshowprevious', //是否显示上期对比数据
                        'EqualDuration': 'EqualDuration',   //上期按当前时间为截至时间
                        'ShowPercent': 'ShowPercent',       //显示百分比
                    },
                    DataHtmlBindobj = new DataHtmlBind(),
                    PopupJqObj = ld("#" + PopupObj.divid);
                //移动端工作台看板定制-简报设置没有以下设置
                if(boardtype==='MobileReport'||boardtype==='prmMobileHome') {
                    databindSetarr = {
                        'isshowprevious': 'isshowprevious',  //是否显示上期对比数据
                        'EqualDuration': 'EqualDuration',   //上期按当前时间为截至时间
                        'ShowPercent': 'ShowPercent',   //显示百分比
                    }
                }
                ld.each(databindSetarr, function (formid, keyName) {
                    var JqueryObj = PopupJqObj.find(' #' + formid);
                    if(JqueryObj.length > 0)
                        DataHtmlBindobj.setDataBindByJqObj(JqueryObj, cls_SalesKitSetobj.saleskit_layout, keyName);
                });
                //edit: xll 触发change事件，根据ShowPercent的值确认显示隐藏
                PopupJqObj.find('#isshowprevious').trigger('change');
                PopupJqObj.find('#ShowPercent').trigger('change');
                PopupObj.NewStuffInfoArr = dataArr.NewStuffInfoArr;//新建简报的默认数组格式
                PopupObj.detault_saleskit_list = dataArr.detault_saleskit_list;//所有的简报信息
                PopupObj.selected_saleskit_list = {};
                if (dataArr.saleskit_layout['count'] > 0 && !empty(dataArr.selected_saleskit_list) )
                    PopupObj.selected_saleskit_list = dataArr.selected_saleskit_list;//已被选中的简报信息
                PopupObj.havesaleskit_stufflabelarr = dataArr.havesaleskit_stufflabelarr;//已被选中的stufflabel数组
                PopupObj.JspopLabelarr = dataArr.JspopLabelarr;
                PopupObj.ModuleArr = dataArr.ModuleArr;
                PopupObj.boardid = dataArr.boardid;
                PopupObj.isshowprev = dataArr.isshowprev;
            });
        });
    });
}
//1.销售阶段转化分析  的设置弹框
function EditSalesPhaseTransformationAnalysis(obj,stuffid,boardid,boardstuffid){
    var stuffid=112;
    var surl='index.php?module=Home&action=HomeAjax&file=SalesPhaseTransformationAnalysisSet&stuffid=112&mode=Set&boardid='+boardid;
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Home',"",arrJsPopLabel['CONFIRMED'],"",arrJsPopLabel['CANCEL']);
    ldAjax(surl,{stuffid:stuffid},function (data) {
        if (data.code == 1) {
            crmPopupobj.setParams(data.result.title, SaveSalesPhaseTransformationAnalysis, "", "LdPopWidth600px", 'Home', [crmPopupobj,boardid,stuffid,boardstuffid], arrJsPopLabel['CONFIRMED'], "", arrJsPopLabel['CANCEL'], "");
            crmPopupobj.setlist = data.result.setlist;//设置数据
            crmPopupobj.boardid = data.result.setlist;//设置数据
            var picklistoption_success = '';
            var picklistoption_fail = '';
            ld.each(data.result.picklistvalues,function(index,item){
                var success_selected = '';
                var fail_selected = '';
                if(crmPopupobj.setlist['successlistvalue'].indexOf(item)>-1){
                    success_selected = 'selected';
                }
                if(crmPopupobj.setlist['faillistvalue'].indexOf(item)>-1){
                    fail_selected = 'selected';
                }
                picklistoption_success+='<option '+success_selected+' value="'+item+'">'+item+'</option>';
                picklistoption_fail+='<option '+fail_selected+' value="'+item+'">'+item+'</option>';
            });

            var content = '<div class="padR20 padL20"><table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">\n' +
                '        <tbody>' +
                '        <tr>\n' +
                '            <td width="20%" align="right">'+arrJsPopLabel['Conversionratecalculationmethod']+'</td>\n' +
                '            <td width="80%" align="left">' +
                '<select class="Bornone FieldConText" style="width:100%;height: 30px;background:#F5F8FC;padding-left: 10px;" id="ratecalculationmethod" name="ratecalculationmethod">' +
                '<option '+(crmPopupobj.setlist.ratecalculationmethod=='byopportunitycount'?'selected':'')+' value="byopportunitycount">'+data.result.ByOpportunityCount+'</option>' +
                '<option '+(crmPopupobj.setlist.ratecalculationmethod=='byopportunityamount'?'selected':'')+' value="byopportunityamount">'+data.result.ByOpportunityAmount+'</option>' +
                '</select> </td>\n' +
                '        </tr>\n' +
                '<tr>\n' +
                '            <td width="20%" align="right">'+arrJsPopLabel['wincodition']+'</td>\n' +
                '            <td width="80%" align="left">' +
                '<select class="Bornone FieldConText" id="successlistvalue" name="successlistvalue" multiple>'+picklistoption_success+'</select></td>\n' +
                '        </tr>\n' +
                '        <tr>\n' +
                '            <td width="20%" align="right">'+arrJsPopLabel['failcodition']+'</td>\n' +
                '            <td width="80%" align="left">' +
                '<select class="Bornone FieldConText" id="faillistvalue" name="faillistvalue" multiple>'+picklistoption_fail+'</select></td>\n' +
                '        </tr>\n' +
                '        <tr>\n' +
                '            <td width="20%" align="right">'+arrJsPopLabel['PotentialTotalType']+'</td>\n' +
                '            <td width="80%" align="left">' +
                '<select class="Bornone FieldConText" style="width:100%;height: 30px;background:#F5F8FC;padding-left: 10px;" id="totalcolumn" name="totalcolumn">' +
                '<option '+(crmPopupobj.setlist.totalcolumn=='totalxrate'?'selected':'')+' value="totalxrate">'+data.result.totalcolumnname+'*'+data.result.possibilitycolumnname+'</option>' +
                '<option '+(crmPopupobj.setlist.totalcolumn=='total'?'selected':'')+' value="total">'+data.result.totalcolumnname+'</option>' +
                '</select> </td>\n' +
                '        </tr>\n' +
                '    </tbody></table></div>';
            crmPopupobj.show(content);
            ld('#'+crmPopupobj.divid).find('#successlistvalue').select2({width:'100%',closeOnSelect: true});
            ld('#'+crmPopupobj.divid).find('#faillistvalue').select2({width:'100%',closeOnSelect: true});

            //双向绑定
            var databindArr = {
                'successlistvalue':'successlistvalue',
                'faillistvalue':'faillistvalue',
                'totalcolumn':'totalcolumn',
                'ratecalculationmethod':'ratecalculationmethod'
            }
            ld.each(databindArr,function(idname,keyname) {
                var DataHtmlBindobj = new DataHtmlBind();
                DataHtmlBindobj.setJqueryObj(ld("#" + crmPopupobj.divid + ' #' + idname));
                DataHtmlBindobj.setDataBindByJqueryObj(crmPopupobj.setlist, keyname);
            });
            crmPopupobj.center();
        }
    });
}
function SaveSalesPhaseTransformationAnalysis(crmPopupobj,boardid,stuffid,boardstuffid){
    var surl='index.php?module=Home&action=HomeAjax&file=SalesPhaseTransformationAnalysisSet&stuffid='+stuffid+'&mode=Save&boardid='+boardid+'&boardstuffid='+boardstuffid;
    ldAjax(surl,{setlist:crmPopupobj.setlist},function (data) {
        crmPopupobj.CancelEvent();
        ld('#rptContentLoading').hide();
        //更新统计图
        //zxm 20230830 销售简报编辑保存之后 只刷新简报数据  不全局刷新
        var createboard_popupobj = CrmPopup.getPopupObj("last");
        if(!empty(createboard_popupobj)&&createboard_popupobj.homeboardobj){
            //看板编辑界面  简报的修改也要刷新
            createboard_popupobj.homeboardobj.loadStuff(112,'chart');
        }else{
            loadStuff(112,'chart');
        }
    });
}
//新看板的操作  新增编辑按钮 管理看板等--start
//新增、编辑 看板
function editHomeboard(boardid,boardtype){
    AjaxJSPage('Homestuff','include/js/modules/Home/Homestuff.js');
    if(boardtype=='MobileReport'||boardtype == 'prmMobileHome'){
        editMobileHomeboard(boardid,boardtype);return;
    }
    var module = boardtype;
    ld('#homeboard_List').hide();
    //edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块
    //var module = getUrlParam("pageto_module");
     if(module == 'prmHome'){
         module = 'Home';
     }

    if(boardtype=='MobileReport')module='Settings';

    var surl='index.php?module='+module+'&action='+module+'Ajax&file=CreateHomeboard&boardid='+boardid+'&boardtype='+boardtype;
    //移动端工作台定制
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth1600px",module,"","","","");
    var styleStr1 = (boardid==0) ? '#3B7CFF' : '#999';
    var styleStr2 =(boardid==0)?'#999':'#3B7CFF';
    crmPopupobj.createHeadHtml = function (){
        this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
        this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
        this.popupheadhtml += '<div style="margin: auto;background-color: #fff;margin-left: 60px;float: left;" xmlns="http://www.w3.org/1999/html">\n' +
            '                <label name="step1"><div class="ld_homeboard_head_step" style="background:'+styleStr1+'">1</div>\n' +
            '                <span style="float: left;margin:21px 10px;font-size: 16px;">'+arrJsPopLabel['FILLBASICINFORMATION']+'</span></label>\n' +
            '                <div style="width: 60px; border-bottom: 0.6mm dashed #3B7CFF;float: left;margin: 32px 18px 0 10px;"></div>\n' +
            '                <label name="step2"><div class="ld_homeboard_head_step" style="background-color:'+styleStr2+'">2</div>\n' +
            '                <span style="float: left;margin:21px 10px;font-size: 16px;">'+arrJsPopLabel['SETLAYOUTRULES']+'</span></label>\n' +
            '            </div>';
        this.popupheadhtml +='<div class="E_pop_tit_Second_Right" style="float: right;">';
        this.popupheadhtml += '<div class="ld-button marR20" name="next" id="next">'+arrJsPopLabel['NEXT']+'</div>';
        this.popupheadhtml += '<div class="ld-button" name="astep" id="astep" style="display: none;">'+arrJsPopLabel['ASTEP']+'</div>';
        this.popupheadhtml += '<div class="ld-button ld-button-primary marR20" name="save" id="save" style="display: none;">'+arrJsPopLabel['SAVE']+'</div>';
        this.popupheadhtml += '<div class="E_ptitc" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
        this.popupheadhtml += '</div>';
        this.popupheadhtml += '</div>';
    }

    crmPopupobj.cancelhomeboard = crmPopupobj.CancelEvent;
    crmPopupobj.CancelEvent = function (){
        var delete_str = arrJsPopLabel['CANCELHOMEBOARDCHECK'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",delete_str);
        ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
            crmPopupobj.cancelhomeboard();
        })
    }

    ldAjax(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth1600px",module,"","","","","");
            crmPopupobj.show(data.result.content);
            ld('#'+ crmPopupobj.divid).css('width','100%');
            ld('#'+ crmPopupobj.divid).css('height','100%');
            crmPopupobj.center();
            crmPopupobj.boardtype = boardtype;
            crmPopupobj.DatarangeSetListDefault = data.result.DatarangeSetListDefault;
            crmPopupobj.DatarangeSetList = {};
            if(!empty(data.result.DatarangeSetList)){
                crmPopupobj.DatarangeSetList = data.result.DatarangeSetList;
            }
            if(boardid > 0){
                crmPopupobj.Homeboard_content = data.result.Homeboard_content;
                crmPopupobj.chosedatastyle = data.result.Homeboard_content.timesearchdefault;
            }else{
                crmPopupobj.chosedatastyle = 'thismonth';
            }

            crmPopupobj.data_select = data.result.data_select;
            crmPopupobj.StuffOtherSet = data.result.StuffOtherSet;
            crmPopupobj.StuffOtherSetList = {};
            if(ld('#edithomefromlist').val() == 'yes'){
                crmPopupobj.edithomefromlist = 'yes';
            }else {
                crmPopupobj.edithomefromlist = 'no';
            }
            getJsScript('include/js/modules/Home/Homeboard.js', function () {
                var cls_homeboardobj = Homeboard.getInstance();
                crmPopupobj.homeboardobj = cls_homeboardobj;
                cls_homeboardobj.setModuleName(module)
                if(boardid>0){
                    crmPopupobj.homeboardobj.nextBtnClick();
                }

                tooltip('#'+crmPopupobj.divid+' .tip-items-list', {transition: true, time: 200});
            });
        }
    })
}

//新首页看板列表
function HomeboardListview(module){
    ld('#homeboard_List').hide();
    var surl='index.php?module='+module+'&action='+module+'Ajax&file=HomeboardListview&from_module='+module;
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
    crmPopupobj.ishaveEditKanban = 'no';
    crmPopupobj.createHeadHtml = function (){
        this.popupheadhtml = '<div class="E_pop_tit" id="' + this.divid + '_head" style="cursor:move">';
        this.popupheadhtml += '<strong class="E_ptita">' + this.headtitle + '</strong>';
        this.popupheadhtml +='<div class="E_pop_tit_Second_Right" style="float: right;">';
        //edit: xll 2023/07/18 BUG0069672 kfbcrm，可视化分析，管理数据看板，有两个新增按钮
        if(module != 'VisualAnalysis'){
            this.popupheadhtml += '<a href="javascript:;" class="ld-button ld-button-primary" style="line-height: 30px;padding: 0 15px;" onclick="editHomeboard(0,\'Home\')" title="'+arrJsPopLabel['NEW']+'">'+arrJsPopLabel['NEW']+'</a>';
        }
        this.popupheadhtml += '<div class="E_ptitc" value="' + arrJsPopLabel['LBL_CLOSE'] + '" title="' + arrJsPopLabel['LBL_CLOSE'] + '" id="' + this.divid + '_imgclose"></div>';
        this.popupheadhtml += '</div>';
        this.popupheadhtml += '</div>';
    }
    ldAjax(surl,"",function(data){
        if(data.code==1){
            crmPopupobj.setParams(data.result.title,"","","LdPopWidth800px",module,"","","","","");
            CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
            // 设置内容最大高度
            crmPopupobj.setPopBodyMaxHeight(".divPopOverflow");
            ld('#rptContentLoading').hide();
            ld('#'+crmPopupobj.divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
                if(crmPopupobj.ishaveEditKanban=='yes'){
                    window.location.reload();
                }
                return false;
            });
            tooltip('#'+crmPopupobj.divid+' .tip-items-list',{transition:true,time:200});
            homeboardlistdrag(module);
        }
    })
}

//删除看板
function deleteHomeboard(boardid,boardtype){
    var confirm_str = arrJsPopLabel['DELETEDATAKANBAN'];
    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    var module = boardtype;
    if(boardtype=='MobileReport')module='Settings';
    ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=deleteHomeboard&boardid='+boardid
        ldAjax(surl,"",function(data){
            if(data.code == 1){
                var popupobj_list = CrmPopup.getPopupObj("last");
                if(popupobj_list !== undefined && popupobj_list.divid !== undefined)
                    popupobj_list.ishaveEditKanban = 'yes';
                freshen_homeboardlist(boardtype);
                ld('#rptContentLoading').hide();
            }
        });
    });
}

//刷新列表
function freshen_homeboardlist(boardtype){
    var module = boardtype;
    if(boardtype=='MobileReport')module='Settings';
    var popupobj_list = CrmPopup.getPopupObj("last");
    if(popupobj_list !== undefined && popupobj_list.divid !== undefined)
        popupobj_list.ishaveEditKanban = 'yes';
    if(module == 'VisualAnalysis'){
        return_HomeListView('');
    }else if(boardtype == 'MobileReport'){
        ldAjaxNoProgress('index.php?module=Settings&action=mobile_home_setting&parenttab=Settings&from_module=MobileReport&ReportHeader=dheader','',function(data) {
            ld(" [name=SettingRightContent]").html(data.result.content);
        });
    }else{
        var surl='index.php?module='+module+'&action='+module+'Ajax&file=HomeboardListview&ajax=no';
        ldAjax(surl,"",function(data){
            if(data.code==1){
                ld('#homeboard_listview_table .divPopOverflow').html(data.result.content);
            }
            // 设置内容最大高度
            popupobj_list.setPopBodyMaxHeight(".divPopOverflow");
            homeboardlistdrag(boardtype);
        });
    }
}

//首页数据看板管理看板列表绑定拖动排序事件
function homeboardlistdrag(boardtype){
    //var crmPopupobj = CrmPopup.getPopupObj("last");

    var divid='homeboard_listview_table';
    ld('#'+divid+' .settingTable tr').hover(function(){
        ld('.ld-dragicon').hide();
        ld(this).find('.ld-dragicon').show();
    });
    if(ld('#'+divid+' .settingTable').length > 0) {
        Sortable.create(ld('#'+divid+' .settingTable tbody').get(0), {
            group: 'homeboardkanbanlist',
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            animation: 150,
            sort: true,
            onEnd: function (evt) {
                var sequence_arr = [];
                ld.each(ld('#'+divid+' .settingTable tbody tr.ld-category-draggable'),function(index,tmpobj){
                    ld(tmpobj).find('td').eq(0).html(index+1);
                    ld(tmpobj).removeClass('lvtColDataBj');
                    ld(tmpobj).removeClass('lvtColData');
                    if(index%2 === 0){
                        ld(tmpobj).addClass('lvtColData');
                        ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                        ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"on")');
                    }else {
                        ld(tmpobj).addClass('lvtColDataBj');
                        ld(tmpobj).attr('onmouseover','listOnMouseOver(ld(this))');
                        ld(tmpobj).attr('onmouseout','listOnMouseOut(ld(this),"On")');
                    }

                    var tmp_boardid = ld(tmpobj).data("boardid");
                    if(tmp_boardid > 0){
                        sequence_arr.push(tmp_boardid);
                    }
                });
                if(sequence_arr.length > 0){
                    sequence_arr = sequence_arr.toString();
                    var update_url="index.php?module=Home&action=HomeAjax&file=SaveHomeboard&submode=HomeBoardsort&boardtype="+boardtype+"&ajax=true&selectedFieldStr="+sequence_arr;
                    ld.ajax({
                        type: "GET",
                        url: update_url,
                        success: function(data){
                            // 处理返回的数据
                            //zxm 20240104 BUG0077759 kfbcrm-首页-管理数据看板-拖动修改看板顺序，不生效，手动刷新后才会生效
                            if(boardtype=='Home'){
                                var curKanbanBoardid = ld('#home_index #boardid').val();//用户当前首页展示的看板是哪个看板
                                Homeboard_changing_over(curKanbanBoardid)
                            }
                        },
                        error: function(error){
                            // 错误处理
                        }
                    });
                }
            }
        });
    }
}


//列表修改适用范围
function homeboardlist_scope(boardid,obj,boardtype){
    //var module = getUrlParam("pageto_module");
    //if(module=='Settings')
        //module='Home'
    var module = boardtype;
    if(boardtype=='MobileReport'||boardtype == 'prmMobileHome')module='Settings';
    getJsScript('include/js/ScopePopup/ScopePopup_Details.js',function () {
        var scopepopupobj = ScopePopup_Details.getInstance();
        var selectedtype = '0';
        var popupobj_list = CrmPopup.getPopupObj("last");

        if(popupobj_list == undefined){
            var scope = ld('.main_grid .main_grid_box table #homeboard_scope_' + boardid).val();
            var scopeid = ld('.main_grid .main_grid_box table #homeboard_scopeid_' + boardid).val();
            //edit: xll 2023/07/20 BUG0069739 kfbcrm-可视化分析-点击分配，修改看板适用范围，保存，再点击分配，还是显示全部
            if(boardtype == 'VisualAnalysis'){
                var scope = ld(obj).attr('homeboard_scope_' + boardid);
                var scopeid = ld(obj).attr('homeboard_scopeid_' + boardid);
            }
            //zxm 20240820
            if(boardtype == 'MobileReport'||boardtype == 'prmMobileHome'){
                scope = ld('.main_grid_box table #homeboard_scope_' + boardid).val();
                scopeid = ld('.main_grid_box table #homeboard_scopeid_' + boardid).val();
            }
        }else {
            popupobj_list.ishaveEditKanban = 'yes';//编辑过看板信息
            if(boardtype == 'VisualAnalysis'){
                //BUG0072612 kfbcrm-可视化分析-先点击卡片进入看板-返回卡片视图，点击卡片下侧“分配”按钮，界面没反应
                var scope = ld(obj).attr('homeboard_scope_' + boardid);
                var scopeid = ld(obj).attr('homeboard_scopeid_' + boardid);
            }else{
                var scope = ld('#' + popupobj_list.divid + ' .main_grid_box table #homeboard_scope_' + boardid).val();
                var scopeid = ld('#' + popupobj_list.divid + ' .main_grid_box table #homeboard_scopeid_' + boardid).val();
            }
        }
        if(scope=='group')
            selectedtype = '1';
        else if(scope=='user')
            selectedtype = '2';
        else if(scope=='role')
            selectedtype = '3';
        var selectedid = scopeid;
        scopepopupobj.allocateTemplate(obj, 0, 0,selectedid ,selectedtype , 'Homeboard');
        scopepopupobj.validate_url = function (){
            selectedtype = ld('#'+scopepopupobj.firstpop_id+'content input[name="radiotype"]:checked ').val();

            if(selectedtype != 0){
                var new_scopeid = cls_ScopePopup.return_obj.return_id
            }else{
                var new_scopeid = '';
            }

            var new_scope = 'all';
            if(selectedtype==1)
                new_scope='group';
            else if(selectedtype==2)
                new_scope='user'
            else if(selectedtype==3)
                new_scope='role'

            var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Homeboard_scopechange&boardid='+boardid+'&scope='+new_scope+'&scopeid='+new_scopeid+'&boardtype='+boardtype;
            ldAjax(surl,"",function(data){
                if(data.code == 1){
                    if(popupobj_list == undefined){
                        ld('.main_grid .main_grid_box table #homeboard_scope_'+boardid).val(new_scope);
                        ld('.main_grid .main_grid_box table #homeboard_scopeid_'+boardid).val(new_scopeid);
                        //edit: xll 2023/07/20 BUG0069739 kfbcrm-可视化分析-点击分配，修改看板适用范围，保存，再点击分配，还是显示全部
                        if(boardtype == 'VisualAnalysis'){
                            var scope = ld(obj).attr('homeboard_scope_' + boardid,new_scope);
                            var scopeid = ld(obj).attr('homeboard_scopeid_' + boardid,new_scopeid);
                        }
                        if(boardtype == 'MobileReport'||boardtype == 'prmMobileHome'){
                            ld('.main_grid_box table #homeboard_scope_' + boardid).val(new_scope);
                            ld('.main_grid_box table #homeboard_scopeid_' + boardid).val(new_scopeid);
                        }
                    }else {
                        ld('#' + popupobj_list.divid + ' .main_grid_box table #homeboard_scope_' + boardid).val(new_scope);
                        ld('#' + popupobj_list.divid + ' .main_grid_box table #homeboard_scopeid_' + boardid).val(new_scopeid);
                    }
                    ld('#rptContentLoading').hide();
                }
            });
        }
    })

}

//切换首页看板
function Homeboard_changing_over(boardid){
    ld('#homeboard_List').hide();
    //edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块
    var module = getUrlParam("pageto_module");
    var surl = 'index.php?module='+module+'&file=Homeboard_index&action='+module+'Ajax';
    if(boardid > 0){
        surl += '&boardid='+boardid;
    }else{//判断是否走新看板   yes表示走，no表示不走
        surl += '&newboard=yes';
    }
    listcontentobj=ld("#pagecontent .wrapper-panel-inner");
    ldAjaxHtml(surl,'',function(data){
        if(module == 'VisualAnalysis') {
            ld('.ld_VisualAnalysis_Content').css('height','calc(100% - 55px)');
            ViewBoardShow(data);
        }
        else
            listcontentobj.html(data);
        ld('#rptContentLoading').hide();
    })
}
//新看板的操作  新增编辑按钮 管理看板等--end

//首页 近六个月目标完成情况 目标完成率仪表盘的目标管理按钮  点击按钮才加载salesgoal.js
function SalesGoalManage(){
    getJsScript('include/js/modules/SalesGoal/SalesGoal.js', function () {
        SalesGoalList();
    });
}
//首页设置龙虎榜，点击设置再加载DragonTigerList.js
function DragonTigerListManage(event,boardid) {
    getJsScript('include/js/modules/Home/DragonTigerList.js', function () {
        EditDragonTigerList(event,boardid);
    });
}
//编辑仪表盘列表
function TargetAnalysisManage(event,boardid,stuffid) {
    getJsScript('include/js/modules/Home/TargetAnalysis.js', function () {
        EditTargetAnalysis(boardid,stuffid);
    });
}
//edit: xll 2024/02/22 BUG20240219-35 kfbcrm-首页看板-点击看板后再打开下拉框，应自动滚动到当前看板位置
function ScrollBoardIntoView(boardid) {
    var boardObj = ld('#homeboard_List').find(`[data-boardid='${boardid}'`)
    if(boardObj.length > 0)
        boardObj.get(0).scrollIntoView({ behavior: "smooth" , block : "center"});
}
//消息中心组件的设置按钮
function newRemindsListManage(e,boardid,stuffid){
    //获取可选字段 已选字段 弹框显示穿梭狂
    var module = 'Home';
    var surl='index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard&mode=newRemindsModuleSet&boardid='+boardid;
    surl+='&stuffid='+stuffid;
    var tmpPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
    tmpPopupobj.prevshow();

    ldAjaxNoProgress(surl,{},function(data) {

        tmpPopupobj.setParams(data.result.title, newRemindsListManageconfirmEvent, "", "LdPopWidth800px", module, [boardid,stuffid,tmpPopupobj], data.result.oktext, "", data.result.canceltext);
        var table_html = '<div id="ModuleTransferDiv" class="ld-pop-container-second"></div>';
        CrmPopup.setPopupobjHtmlContent_scroll_jquery(tmpPopupobj, table_html);
        // 穿梭框
        var leftfields_arr = data.result.leftfields_arr;
        var rightfields_arr = data.result.rightfields_arr;

        if(rightfields_arr.length > 0)
            leftfields_arr = leftfields_arr.filter(leftitem => !rightfields_arr.some(rightitem => rightitem.value == leftitem.value));// 在左侧数组中去掉右侧已选字段
        var tableobj = ld('#'+tmpPopupobj.divid).find("div#ModuleTransferDiv");// 加载穿梭框
        var LeftObj = leftfields_arr;
        var RightObj = rightfields_arr;
        var Drag_Transfer = new DragTransfer();
        var translabel = {
            available: arrJsPopLabel['OptionModules'],
            selected: arrJsPopLabel['Selectedmodule'],
            placeholder: arrJsPopLabel['PleaseEnterModuleSearchFor'],
        };
        Drag_Transfer.SetTranslabel(translabel);
        Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'set','335');
        tmpPopupobj.center();
    });

}
function newRemindsListManageconfirmEvent(boardid,stuffid,tmpPopupobj){
    var Drag_Transfer = new DragTransfer();
    Drag_Transfer.tableObj = ld('#'+tmpPopupobj.divid).find("div#ModuleTransferDiv");
    var selected_arr = Drag_Transfer.getData('right');// 获取已选值的value

    if(!selected_arr || selected_arr.length<=0){
        RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['PLEASESELECTLEASTONEENTITY']);return;
    }
    var module = 'Home';
    var surl='index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard&mode=newRemindsModuleSetSave&boardid='+boardid;
    surl+='&stuffid='+stuffid;
    ldAjaxNoProgress(surl,{"selected_arr":JSON.stringify(selected_arr)},function(data) {
        tmpPopupobj.CancelEvent();
        var navbarobj = ld_NavBar.getCurNavBar(ld('#stuff_118 #sales_target_tab').get(0));
        var curdata_type = navbarobj.NavBarItem.name;
        var callbackfun = function(Option){}
        //更新页签
        var StuffInfo = {
            stuffid : stuffid,
            stufflisttype : 'defaultstuff',
            stufftype : 'customsheet',
        };
        LoadStuffNavBar(StuffInfo,callbackfun,{widgetId:stuffid,widgetType:'customsheet',sales_target_tab:curdata_type});
    });
}
/*
销售简报设置---老看板的简报
*/
function SalesKitSet(event,jqueryobj,stuffid,title){
    EmptyProgressObjs();
    var that=this;
    ldAjax("index.php?module=Home&action=HomeAjax&file=SalesKitSet",{stuffid:stuffid},function(data){
        var popupobj=  CrmPopup.load(title,that.SalesKitSetsave,"",600,'Home',"",data.result.oktext,"",data.result.canceltext);
        CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
        DelProgressObjs();
    })
    that.SalesKitSetsave=function(){
        var popupobj=CrmPopup.getPopupObj('last');
        var leftobjs=ld("#"+popupobj.divid+ ' [name=AssmablyList]').find("option");
        var unselectvalues=[];
        ld.each(leftobjs,function(){
            unselectvalues.push(ld(this).val());
        })
        var selectvalues=[];
        var rightobjs=ld("#"+popupobj.divid+ ' [name=selectedAssmablyColumns]').find("option");

        ld.each(rightobjs,function(){
            selectvalues.push(ld(this).val());
        })

        ldAjax("index.php?module=Home&action=HomeAjax&file=SalesKitSet&type=save&selectvalues="+selectvalues.join(",")+"&unselect="+unselectvalues.join(","),{stuffid:stuffid},function(data){
            popupobj.CancelEvent();
            //zxm 20230830 销售简报编辑保存之后 只刷新简报数据  不全局刷新
            loadStuff(35,'saleskit');
            DelProgressObjs();

        })
    }
    that.SalesKitSetsave.funname='SalesKitSetsave';
}

//首页 看板下拉列表拖动事件
//edit: txy 2023/09/04 首页看板增加拖动排序功能
function homeboardListSorting(){
    if(ld("#homeboard_List #sortable-list").length > 0) {
        Sortable.create(ld("#homeboard_List #sortable-list").get(0), {
            group: 'homeboardkanban',
            draggable:".ld-category-draggable",
            handle:".drag-handle",
            animation: 150,
            sort: true,
            onEnd: function (evt) {
                var sequence_arr = [];
                ld.each(ld('#homeboard_List #sortable-list li.ld-category-draggable'),function(index,tmpobj){
                    var tmp_boardid = ld(tmpobj).data("boardid");
                    if(tmp_boardid > 0){
                        sequence_arr.push(tmp_boardid);
                    }
                });
                if(sequence_arr.length > 0){
                    sequence_arr = sequence_arr.toString();
                    var update_url="index.php?module=Home&action=HomeAjax&file=SaveHomeboard&submode=HomeBoardsort&boardtype=Home&ajax=true&selectedFieldStr="+sequence_arr;
                    ld.ajax({
                        type: "GET",
                        url: update_url,
                        success: function(data){
                            // 处理返回的数据
                        },
                        error: function(error){
                            // 错误处理
                        }
                    });
                }
            }
        });
    }
}

//日期组件
function homeboardLaydateRender(){
    // 首页日期加载
    laydate.render({
        elem: '.home_laydate_time',
        theme: 'type-ym',
        trigger: 'click',
        btns: [],
        type: 'date',
        newType: 'date',
        range: true,
        /** 自定义选择时间区间后，触发的时间变化回调函数 */
        change: function (value, date, edate) {
            ld('.home_laydate_time').val(arrJsPopLabel['custom']);//选择日期时赋值custom
            ld('.laydate_time_hiddenvalue').val(value);
            value=value.split(' - ');
            var begin_date=value[0];
            var end_date=value[1];
            value=begin_date+'~'+end_date;
            ld('#search_date_custom').val(value);
            ld(".layui-laydate").remove();//关掉弹出层
        },
        /** 时间选择变化后，触发的回调函数 */
        timeChange: function (value) {
            //增加用户选择时间后,记忆的功能
            var module = 'Home';
            var boardid = ld("#boardid").val()===undefined?0:ld("#boardid").val();
            if(value=='custom'){
                value+=':'+ld('#search_date_custom').val().split('~').join(' - ');
            }
            var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard'+'&boardid='+boardid;
            url += '&chooseTime='+value+'&mode=change';
            ldAjax(url,"",function(data){
                ld('#rptContentLoading').hide();
            });
            initWidgets();
        }
    });
}

//审批组件
function homeboardApproveRender(approvelist){
    var approvedivobj = ld('#homeboard_approve');
    AjaxJSPage('ld_Select','include/js/component/ld_Select.js');
    var homeapproveobj = ld_Select.showSelect(approvedivobj.get(0), {
        'list': approvelist,
        'width': '140px',
        'showtype': 'click',
        'multiple': true,
        'selectname': arrJsPopLabel['APPROVESTATUS'],
        'selecticonurl': 'themes/icon2023/homeapproveselect.png',
        'selecticonhoverurl': 'themes/icon2023/homeapproveselect_hover.png',
        'change': function (evt){
            global_home_approve = [];
            var module = 'Home';
            var boardid = ld("#boardid").val()===undefined?0:ld("#boardid").val();
            var ApproveStatusHistory = '';
            ld.each(evt.NavBarItem,function(){
                ApproveStatusHistory += this.value + ',';
                global_home_approve.push(this.value);
            });
            ApproveStatusHistory = ApproveStatusHistory.slice(0, ApproveStatusHistory.length-1);
            //增加用户设置记忆功能
            var url = 'index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard'+'&boardid='+boardid;
            url += '&ApproveStatusHistory='+ApproveStatusHistory+'&mode=change';
            ldAjax(url,"",function(data){
                ld('#rptContentLoading').hide();
            });
            initWidgets();
        }
    });
}


