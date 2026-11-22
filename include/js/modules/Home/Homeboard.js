
function Homeboard(){
    var that=this;
    this.module = 'Home';
    this.EmptyLeaveTimer = {};
    var popupobj = CrmPopup.getPopupObj("last");

    var PopupJqObj = ld('#'+popupobj.divid),step2Obj = PopupJqObj.find(" #step2");
    that.popupobj = popupobj;
    //使用ld_NavBar生成页签的Stuffid数组
    this.NavBar_StuddIdArr = ['39','40','101','100','114','118'];
    that.boardid = popupobj.recode = PopupJqObj.find('#boardid').val();
  //  this.module = popupobj.boardtype=='MobileReport'?'Settings':popupobj.boardtype;
    this.setModuleName=function(modulename){
        this.module=modulename;
    }
    //组件显示html
    this.get_draw_block_stuffhtml = function (stuffid,stuffstyle,stufftitle,stuffliststyle,stufftitle_label,height,stufftitle_zh,stufftitle_en,boardstuffid){
        var draw_block_stuffhtml = '';
        //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘(近六个月目标完成情况和目标完成率仪表盘中的指标页签动态读取目标管理中的指标)
        var stuffid_arr = that.NavBar_StuddIdArr;
        if(stuffid_arr.includes(stuffid.toString())){
            var tmpurl = 'index.php?module=Home&action=HomeAjax&file=HomeBoardStuff_PreHtml';
            var tmpbody = '';
            tmpbody += '&stufftype='+stuffstyle+'&stufftitle='+stufftitle+'&stufftitle_label='+encodeURIComponent(stufftitle_label);
            tmpbody += '&height='+height+'&stufftitle_zh='+encodeURIComponent(stufftitle_zh)+'&stufftitle_en='+encodeURIComponent(stufftitle_en);
            tmpbody += '&boardstuffid='+boardstuffid+'&stuffid='+stuffid+'&stufflisttype='+stuffliststyle+'&boardid='+popupobj.recode;
            var Previewhtml = '';
            ldAjaxNoProgresssync(tmpurl,tmpbody,function (data) {
                Previewhtml = data.result.content;
            });
            draw_block_stuffhtml += Previewhtml;
        } else {
            var content_height = parseInt(height.split('px')[0]);
            if(stuffstyle == 'saleskit' || stuffid == '47' || stuffid == '51' || stuffid == '64' || stuffid == '65'){
                draw_block_stuffhtml += '<div id="stuff_' + stuffid + '" data-boardstuffid="'+boardstuffid+'" data-stuffid="'+stuffid+'" data-stuffstyle="'+stuffstyle+'" data-stuffliststyle="'+stuffliststyle+'" name="homeboard_draw_block_stuff" class="ld_homeboard_draw_block_stuff" style="overflow: hidden;">';
            }else {
                if(stuffid==108)height="262px";//移动端常用模块组件
                draw_block_stuffhtml += '<div id="stuff_' + stuffid + '" data-boardstuffid="'+boardstuffid+'" data-stuffid="'+stuffid+'" data-stuffstyle="'+stuffstyle+'" data-stuffliststyle="'+stuffliststyle+'" name="homeboard_draw_block_stuff" class="ld_homeboard_draw_block_stuff" style="overflow: hidden;height: '+height+';">';
            }
            draw_block_stuffhtml += '<input value="'+stufftitle_zh+'" type="hidden" id="stuff_label_zh_'+stuffid+'">';
            draw_block_stuffhtml += '<input value="'+stufftitle_en+'" type="hidden" id="stuff_label_en_'+stuffid+'">';
            draw_block_stuffhtml += '<div class="ld_homeboard_draw_block_stuff_close" data-stuffid="'+stuffid+'" data-stuffstyle="'+stuffstyle+'"><i class="icon_close"></i></div>';

            var headHeight = 50;

            if(stuffliststyle == 'customreport'||stuffliststyle == 'customtable') {
                var idname = 'myChart_';
                var contenthtml = '';
                if(stuffliststyle=='customtable'){
                    //自定义统计表放首页
                    idname = 'myTable_';
                    contenthtml = '<div class="customtable-content"><div class="report-detail marL20 marR20" tag="div_thResizableContent">\n' +
                        '<table border="0" cellspacing="1" cellpadding="0" id="thResizable" class="customtable-list" style="margin:0 auto;">' +
                        '    <thead style="">\n' +
                        '    <tr tag="reportDetailHeader" style="height:40px;position:sticky;top:0;">' +
                        '        <th class="empty-field" style="width:100%;">暂无字段</th>' +
                        '    </tr>' +
                        '    </thead>' +
                        '    <tbody style="background-color: #fff;" tag="reportDetailBody">' +
                        '    </tbody>' +
                        '</table>' +
                        '</div></div>'
                }
                draw_block_stuffhtml += '<div class="MatrixLayer_row twoColumnWidget" style="overflow: hidden;">' +
                    '    <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">' +
                    '        <tr id="headerrow_charts_'+stuffid+'" >' +
                    '            <th class="N_con_tit">' +
                    '                <div class="ld-stuff-tit-name" style="float: left;">' +
                    '                    <span class="icon-bluelt">'+stufftitle+'</span>' +
                    '                </div>' +
                    '            </th>' +
                    '        </tr>' +
                    '    </table>' +
                    '    <table width="100%" cellpadding="0" cellspacing="0" class="small" >' +
                    '        <tr id="maincont_row_'+stuffid+'">' +
                    '            <td colspan="2">' +
                    '                <div id="'+idname+stuffid+'" class="EchartDiv" style="width: 100%;height:'+(content_height-headHeight)+'px;">'+contenthtml+'</div>' +
                    '            </td>' +
                    '        </tr>' +
                    '    </table>' +
                    '</div>';
            }
            else if(stuffliststyle == 'defaultstuff'){
                draw_block_stuffhtml += '<div class="MatrixLayer_row" style="overflow: hidden;">';
                draw_block_stuffhtml += '<table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">' +
                    '<tr id="headerrow_'+stuffid+'" >' +
                    '<th class="N_con_tit">' +
                    '<div class="ld-stuff-tit-name" style="float: left;">' +
                    '<span class="icon-bluelt"></span>' + stufftitle_label;
                var seticonhtml = '';
                if(stuffid==35){
                    seticonhtml = '<i class="ld-fonticon ld-fonticon-set lineheight24" onclick="EditSalesKitSetReport(event,ld(this),35,\'\','+popupobj.recode+',\''+popupobj.boardtype+'\')"></i>';
                }
                if(stuffid==112){
                    seticonhtml = '<i class="ld-fonticon ld-fonticon-set lineheight24" onclick="EditSalesPhaseTransformationAnalysis(this,112,'+popupobj.recode+','+boardstuffid+')"></i>';
                }
                draw_block_stuffhtml += '</div>'+seticonhtml+'</th>' +
                    '<th colspan="2" class="N_con_tit" align="right"></th>' +
                    '</tr>' +
                    '</table>';
                draw_block_stuffhtml += '<table width="100%" cellpadding="0" cellspacing="0" class="small"' +
                    ' style="table-layout: fixed">' +
                    '<tr id="maincont_row_'+stuffid+'">' +
                    '<td colspan="2">';
                if(stuffstyle == 'saleskit'){
                    draw_block_stuffhtml += '<div id="preview_stuffcont_'+stuffid+'" style="overflow:hidden;width:100%;"></div>';
                }
                else if(stuffid == 112){
                    draw_block_stuffhtml +='<div style="overflow-y: auto;width:100%;height:'+(content_height-50)+'px;"><div id="preview_stuffcont_'+stuffid+'" style="overflow-x:hidden;"></div></div>'
                }
                else if(parseInt(stuffid) === 113){
                    var ChartHeight = ((content_height-headHeight) < 320) ? (content_height-headHeight) : 320;
                    draw_block_stuffhtml +='<div style="overflow-y: auto;width:100%;height:'+(content_height-headHeight)+'px;">' +
                        '<div id="preview_stuffcont_'+stuffid+'" style="overflow-x:hidden;width:100%;height:'+ChartHeight+'px;"></div>' +
                        '</div>'
                }
                else{
                    draw_block_stuffhtml += '<div id="preview_stuffcont_'+stuffid+'" style="overflow-y: auto; overflow-x:hidden;width:100%;height:'+(content_height-headHeight)+'px;"></div>';
                }
                draw_block_stuffhtml += '</td></tr></table></div>';
            }
            draw_block_stuffhtml += '</div>';
        }
        return draw_block_stuffhtml;
    }

    //加载显示内容
    this.loadStuff = function (stuffid,stufftype){
        var data_type='contractamount';
        var selectuid = '1';
        var search_date = 'thismonth';
        var approve_value = 'all';
        //edit: xll 2023/08/09 BUG0070875 看板编辑时组件的数据应和看板的默认数据范围保持一致
        var popupobj = CrmPopup.getPopupObj("last");
        if(popupobj.divid != '' && popupobj.Homeboard_content && popupobj.Homeboard_content != ''){
            var Homeboard_content = popupobj.Homeboard_content;
            search_date = Homeboard_content.timesearchdefault;
            approve_value=Homeboard_content.approve_value;
            var date_custom='';
            date_custom=Homeboard_content.customDateValue.split(' - ').join('~');
        }
        var url='index.php?module=Home&action=HomeAjax&file=HomeBlock&homestuffid='+stuffid+'&blockstufftype='+stufftype+'&search_date='+search_date+'&approve_value='+approve_value;
        if(loadStuff.param!="")
        {
            url+="&"+loadStuff.param;
        }
        //edit: zsk 2024/3/12 如果是自定义时间范围,参数中增加&date_custom=
        if(date_custom!=""&&!empty(date_custom)){
            url+='&date_custom='+date_custom;}
        //edit: xll 2023/08/14 BUG0070875 首页组件增加目标完成率仪表盘
        //含页签的组件id数组

        var stuffid_arr = that.NavBar_StuddIdArr;

        if(stuffid_arr.includes(stuffid.toString())){
            var popupobj = CrmPopup.getPopupObj("last");
            var CurTabObj;
            if(popupobj.divid != ''){
                CurTabObj = PopupJqObj.find('#stuff_' + stuffid).find('.ld-NavBarList').children('.cur');
            } else {
                CurTabObj = ld('#stuff_' + stuffid).find('.ld-NavBarList').children('.cur');
            }
            var targetid = '';
            if(CurTabObj.length > 0){
                data_type = CurTabObj.attr('data-NavBarName');
                targetid = CurTabObj.attr('data-NavBarId');
                url+="&targetid="+targetid;
            }
            url+="&data_type="+data_type;
        }
        if(stuffid==50||stuffid==56){
            url+="&data_type="+data_type;
        }
        //zxm 20230707 注释改行 其他组件请求后台也需要boardid
        //if(stuffid==35){//wyt 230621 BUG0068625  新增数据看板时，添加数据简报，新数据看板应该没有预置数据简报组件
        if(popupobj.recode==0){
            url+="&boardid=-1";
        }
        else
            url+="&boardid="+popupobj.recode;
        //}
        url+="&scopeType=SmOwner_Search_All";//zxm 编辑新增界面默认全部数据范围
        //zxm 20231013
        url+="&from_module="+popupobj.from_module;
        // if(stuffid.toString() === '113'||stuffid.toString() === '33'||stuffid.toString() === '57'||stuffid.toString() === '60'){
        var ajaxparams = {'selectuid':selectuid};
        if(popupobj.StuffOtherSetList&&popupobj.StuffOtherSetList['defaultstuff_'+stuffid]){
            var OtherSet = popupobj.StuffOtherSetList['defaultstuff_'+stuffid];
            if(OtherSet){
                url+="&classifyField="+OtherSet.classifyField;
                url+="&countType="+OtherSet.countType;
                url+="&can_penetrate="+OtherSet.can_penetrate;
                url+="&datalabel="+OtherSet.datalabel;
                ajaxparams['showfields'] = OtherSet.showfields;
            }
        }
        ldAjaxHtml(url,ajaxparams,function(data){

            loadStuff.param="";
            DelProgressObjs();

            var newCharArr = ['1','4','5','9','19','40','41','42','44','45','48','49','53','55','57','61','62','63','101','100','102','103','104','105','106','107','112','113','114','115','119'],
                newStuffArr = ['116','117'];
            stuffid = parseInt(stuffid)
            if(newCharArr.includes(stuffid.toString())){
                var restobj = eval('(' + data + ')') ? eval('(' + data + ')') : JSON.parse(data);
                newChart(stuffid, restobj.result,data_type);
            }
            else if(newStuffArr.includes(stuffid.toString())) {
                data = eval('(' + data + ')') ? eval('(' + data + ')') : JSON.parse(data);
                AjaxJSPage('LoadStuffClass','include/js/modules/Home/LoadStuffClass.js');
                LoadStuffClass.showStuff(stuffid,PopupJqObj.find('#preview_stuffcont_'+stuffid),data.result);
            }
            else{
                PopupJqObj.find('#preview_stuffcont_'+stuffid).html(data);
                // 日程管理 @edit:zhouxiaomei @date:2020-9-9 @reason: 首页日程管理
                if(stuffid === 43){
                    intStart();
                    WorkListBind();
                    //屏幕大小变换
                    PopupJqObj.find('#preview_stuffcont_'+stuffid).resize(function(){
                        var div_width = CrmPopup.getClientWidth()-getLeftMenuWidth()-16;
                        PopupJqObj.find('#preview_stuffcont_'+stuffid+' .widget-content .salekit-list .salekit-item').css('width', parseInt((div_width-28)/count)+'px');
                        PopupJqObj.find('#preview_stuffcont_'+stuffid+' #MainMatrix [tag=2]').css('width', (div_width/2-13)+'px');
                        intStart();
                        WorkListBind();
                    });
                }
            }

            //视图标签的事件绑定--20241025  	kys看板-编辑->销售排行榜组件，点其他页签切换不了页签  BUG20241021-18
            home_menu_stuff_bind('preview_stuffcont_'+stuffid);
            getJsScript('include/js/modules/Home/newChart_class.js', function () {
                if(stuffid !== 35 && stuffid !== 114&& stuffid !== 118)
                    newChart_class.changeStuffHeight(stuffid, 0)
                if(stuffid==118){
                    newChart_class.setEvent(stuffid);
                }
            });
        })
    }
    this.loadWidgets = function (stuffid,stuffstyle,stufftitle,stuffliststyle,chart_type){
        if(stuffliststyle == 'customreport'||stuffliststyle == 'customtable'){
            var report_id,
                params = '',
                approve_value = 'all',
                selectuid = '1',
                search_date = PopupJqObj.find('#homeboard_laydata_value').val(),    //时间默认值
                date_custom = '',
                boardstuffid;
            search_date = search_date.split(' - ').join('~');
            if(stuffid.split('_').length > 1){
                report_id = stuffid.split('_')[1];
            }else{
                report_id = stuffid;
            }

            if(stuffliststyle == 'customreport'){
                boardstuffid = PopupJqObj.find('#stuff_customEchart_'+report_id).data('boardstuffid');
            }
            if(stuffliststyle == 'customtable'){
                boardstuffid = PopupJqObj.find('#stuff_customtable_'+report_id).data('boardstuffid');
            }
            params = '&fromhome=yes&selectuid='+selectuid+'&search_date='+search_date+'&date_custom='+date_custom+'&approve_value='+approve_value;
            params += "&scopeType=SmOwner_Search_All"+'&boardid='+that.boardid+'&boardstuffid='+boardstuffid;
            if(stuffstyle=='sqlchart'){
                //zxm 20230512 XUQIU1001246	统计表	报表分析->SQL统计图：增加设置，允许添加到首页组件中显示
                var popupobj = new CrmPopup();
                var divid = "chartInfoForm";//链接模块
                getScriptBackWithURL('include/js/modules/CustomEcharts/CustomEchartsSqlDetail.js',function(){
                    var CustomEchartsSqlDetailObj = new CustomEchartsSqlDetail();
                    CustomEchartsSqlDetailObj.show(popupobj,divid,report_id,chart_type,params);
                });
            }else if(stuffstyle=='chart'){
                var popupobj = new CrmPopup();
                var divid ='searchInfo';
                getScriptBackWithURL('include/js/modules/CustomEcharts/CustomEchartsDetail.js',function(){
                    var CustomEchartsDetailObj = new CustomEchartsDetail();
                    CustomEchartsDetailObj.show(popupobj,divid,report_id,chart_type,params);
                });
                //selfDefinedReportInfo.search(report_id,'no','yes',params);
            }else if(stuffstyle=='selectfield'){
                //自定义统计表
                var Popupobj = new CrmPopup();
                Popupobj.divid = "myTable_customtable_"+report_id;
                getScriptBackWithURL('include/js/modules/CustomTables/CustomTablesDetailHome.js', function () {
                    var CustomTablesDetailHomeObj = new CustomTablesDetailHome();
                    CustomTablesDetailHomeObj.show(Popupobj,Popupobj.divid,report_id,params);
                });
            }else if(stuffstyle=='sql'){
                //SQL统计表
                var Popupobj = new CrmPopup();
                Popupobj.divid = "myTable_customtable_"+report_id;
                getScriptBackWithURL('include/js/modules/CustomTables/CustomTablesSqlDetailHome.js', function () {
                    var CustomTablesSqlDetailHomeObj = new CustomTablesSqlDetailHome();
                    CustomTablesSqlDetailHomeObj.show(Popupobj,Popupobj.divid,report_id,params);
                });
            }
        }else if(stuffliststyle == 'defaultstuff'){
            var callbackfun = function(Option){
                that.loadStuff(Option.stuffid, Option.stuffstyle);
            }
            if(that.NavBar_StuddIdArr.includes(stuffid.toString())){
                var StuffInfo = {
                    stuffid : stuffid,
                    stufflisttype : stuffliststyle,
                    stufftype : stuffstyle,
                };
                LoadStuffNavBar(StuffInfo,callbackfun,{stuffid:stuffid, stuffstyle:stuffstyle});
            }else {
                that.loadStuff(stuffid, stuffstyle);
            }
        }
    }

    //拖动后绑定事件
    this.bindMoveAfter = function (){
        step2Obj.find("[name=homeboard_draw_layout_block] .ld_homeboard_draw_block_stuff .ld_homeboard_draw_block_stuff_close").unbind('click').bind('click',function(event){
            var stuffid = ld(this).data('stuffid');
            var stuffliststyle = ld(this).parent().data('stuffliststyle');
            var stuffkey = stuffliststyle=='defaultstuff'?'defaultstuff_'+stuffid:stuffid;
            var plateid = step2Obj.find("#stuff_"+stuffid).parent().data('plateid');

            //zxm 20230614 删除一个组件 数据范围设置数组也应该删除
            if(!empty(popupobj.DatarangeSetList['plate_'+plateid])&&popupobj.DatarangeSetList['plate_'+plateid][stuffkey]){
                delete popupobj.DatarangeSetList['plate_'+plateid][stuffkey];
            }
            //区块中的组件被删完了  重新出现空态提示
            if(empty(popupobj.DatarangeSetList['plate_'+plateid])){
                PopupJqObj.find('#stuff_'+stuffid).parent().append('<div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+'+arrJsPopLabel['dragstuff']+'</div>');
            }
            step2Obj.find("#stuff_"+stuffid).remove();
            step2Obj.find("#li_stuff_"+stuffid).removeClass('ld_listchosestuff');
            step2Obj.find("#li_stuff_"+stuffid).addClass('drag-handle');
            step2Obj.find("#li_stuff_"+stuffid).find('.tag').css('display','none');
            step2Obj.find("#optional-setting_content").html('');
        });
        step2Obj.find(" [name=homeboard_draw_layout_block] .ld_homeboard_draw_block_stuff").unbind('click').bind('click',function (event) {
            var plateid = ld(this).parent().data('plateid');//区块id
            var stuffid = ld(this).data('stuffid');//组件id
            stuffid = isNaN(stuffid) ? stuffid : parseInt(stuffid);
            var stuffstyle = ld(this).data('stuffstyle');//组件类型
            var stuffliststyle = ld(this).data('stuffliststyle');
            //zxm 20230607 组件数据范围设置
            //看板中已有组件的设置 DatarangeSetList
            var datarange_set;
            if (stuffliststyle == 'defaultstuff') {
                datarange_set = popupobj.DatarangeSetList['plate_' + plateid]['defaultstuff_' + stuffid];
            } else {
                datarange_set = popupobj.DatarangeSetList['plate_' + plateid][stuffid];
            }
            var StuffOtherSet;
            // if(stuffid === 113||stuffid === 33||stuffid ===57||stuffid ===60||stuffid === 100||stuffid === 102||stuffid === 103||stuffid === 104){
            if (popupobj.StuffOtherSet && popupobj.StuffOtherSet['defaultstuff_' + stuffid]) {
                StuffOtherSet = popupobj.StuffOtherSet['defaultstuff_' + stuffid];
            }

            var stufflabel_zh = ld(this).find('#stuff_label_zh_' + stuffid).val();
            var stufflabel_en = ld(this).find('#stuff_label_en_' + stuffid).val();
            var stuff_height = step2Obj.find(" #stuff_" + stuffid).get(0).offsetHeight;
            var newheight = parseInt(stuff_height);
            var setting_html = '', onlyNameArr = [43, 109, 110, 114,118];//简报 和列举的这些组件  不显示高度设置
            var zhLabel = that.getInputHtml(`input_stufflabelzh_stuffid_${stuffid}`,stuffid,stufflabel_zh),
                enLabel = that.getInputHtml(`input_stufflabelen_stuffid_${stuffid}`,stuffid,stufflabel_en);
            if (stuffstyle != 'saleskit' && !onlyNameArr.includes(stuffid)) {
                var heightCon = that.getInputHtml(`input_height_stuffid_${stuffid}`,stuffid,stuff_height,'number');
                    heightCon += '<div class="height-arrow">' +
                        '<div class="height-arrow-up"></div><div class="height-arrow-down"></div>' +
                        '</div>';
                setting_html += that.getSetFieldHtml(arrJsPopLabel['COMPONENTHEIGHT'], heightCon);
            }
            setting_html += that.getSetFieldHtml(arrJsPopLabel['COMPONENTCHNAME'], zhLabel);
            setting_html += that.getSetFieldHtml(arrJsPopLabel['COMPONENTENNAME'], enLabel);
            //最新销售机会 最新合同订单 customsheet类别的组件 显示列设置按钮
            if(StuffOtherSet && StuffOtherSet.showfields){
                setting_html +='<div class="FieldBlock"><div id="StuffOtherSet_'+stuffid+'_showfieldsbtn" class="FieldLabel Mandatory" style="height: 30px;width: 100%;line-height: 45px;font-size:14px;"><a style="padding: 0 10px;" href="javascript:void(0);" class="report-newsystem">'+StuffOtherSet.showfields+'</a></div></div>';
            }
            if (stuffid === 113) {
                setting_html += that.getSelectHtml(stuffid, StuffOtherSet, arrJsPopLabel['CategoricalFields'], 'classifyField');
                setting_html += that.getSelectHtml(stuffid, StuffOtherSet, arrJsPopLabel['TransitionRateMethod'], 'countType');
            }
            // echarts统计图标签位置
            if (StuffOtherSet && StuffOtherSet.datalabel) {
                setting_html += that.getSelectHtml(stuffid, StuffOtherSet, arrJsPopLabel['datalabel'], 'datalabel');
            }

            // 轮播图组件
            if(stuffid === 117) {
                var timerCon = that.getInputHtml(`StuffOtherSet_${stuffid}_CarouselTimer`,stuffid,StuffOtherSet.CarouselTimer,'number','0.1', '80%')
                    + `<span style="margin: 0 5px;">${arrJsPopLabel['Second']}</span>`;
                var ImgList = '';
                ld.each(StuffOtherSet.CarouselImgs,function (index,info) {
                    ImgList += that.getCarouselRow(info);
                })
                setting_html += '<div id="CarouselSet" style="margin-top: 30px;">' +
                                    `<div id="CarouselSetTitle" class="ld_homeboard_drawingboard_setting_title "><span>${arrJsPopLabel['CarouselSet']}</span></div>` +
                                    that.getSetFieldHtml(arrJsPopLabel['CarouselTimer'], timerCon) +
                                    '<div id="CarouselImg" class="CarouselImg">'+
                                        `<div id="addCarouselRow" class="addCarouselRow"><span id="addCarouselImg" class="addCarouselImg">${arrJsPopLabel['AddCarousel']}</span></div>` +
                                        '<div id="CarouselImgList" class="CarouselImgList">' +
                                            ImgList +
                                        '</div>' +
                                    '</div>' +
                                '</div>';
            }
            //销售排行榜、跟进频次排行榜、产品销售排行榜、数据龙虎榜   增加是否允许穿透的参数--移动端看板不要
            //合同简报 增加是否允许穿透的参数
            if ((StuffOtherSet && 'can_penetrate' in StuffOtherSet) || (stuffid === 33 || stuffid === 60)) {
                var tmpCheck = (StuffOtherSet.can_penetrate === true) ? 'checked' : '',
                    checkHtml = '<input id="StuffOtherSet_' + stuffid + '_can_penetrate" type="checkbox" class="second_switch marL10" ' + tmpCheck + '>';
                setting_html += that.getSetFieldHtml(arrJsPopLabel['Permissiblepenetration'],checkHtml);
            }
            setting_html += '<div id="homedefault_component_datasetting" class="marT20 padT10"></div>';
            var setConJqObj = step2Obj.find(" #optional-setting #optional-setting_content");
            setConJqObj.html(setting_html);
            //zxm 20230613  数据范围设置
            PopupJqObj.find('#homedefault_component_datasetting').empty();
            that.dataRangeSetHtml(datarange_set,stuffliststyle,plateid,stuffid);
            //edit: xll 2023/11/20 组件的其他设置信息

            that.dataBindOtherSet(StuffOtherSet,stuffliststyle,stuffid);
            //高级查找条件按钮事件
            PopupJqObj.find("[name=high_search_click]").unbind('click').bind('click',function (){
                that.fun_other_conditions(this,datarange_set);
            });
            step2Obj.find(" #homeboard_draw .ld_homeboard_draw_block_stuff_active").removeClass('ld_homeboard_draw_block_stuff_active');
            ld(this).addClass('ld_homeboard_draw_block_stuff_active');

            //高度
            setConJqObj.find(" #input_height_stuffid_"+stuffid).on('keydown',function (){
                if(window.event.keyCode == 13){
                    if(parseInt(ld(this).get(0).value) > 0){
                        if(parseInt(ld(this).get(0).value) < 260){
                            newheight = 260;
                        }else if(parseInt(ld(this).get(0).value) >1000){
                            newheight = 1000;
                        }else{
                            newheight = parseInt(ld(this).get(0).value);
                        }
                    }
                    ld(this).get(0).value = newheight;
                    newChart_class.changeStuffHeight(stuffid,newheight);
                }
            });
            step2Obj.find(" #optional-setting_content #input_height_stuffid_"+stuffid).focusout(function (){
                if(parseInt(ld(this).get(0).value) > 0){
                    if(parseInt(ld(this).get(0).value) < 260){
                        newheight = 260;
                    }else if(parseInt(ld(this).get(0).value) >1000){
                        newheight = 1000;
                    }else{
                        newheight = parseInt(ld(this).get(0).value);
                    }
                }
                ld(this).get(0).value = newheight;
                newChart_class.changeStuffHeight(stuffid,newheight);
            });
            //中文名称
            setConJqObj.find(" #input_stufflabelzh_stuffid_"+stuffid).on('keydown',function (){
                if(window.event.keyCode == 13){
                    var stufflabel_zh = ld(this).val();
                    step2Obj.find(" #stuff_" + stuffid + " #stuff_label_zh_" + stuffid).val(stufflabel_zh)
                }
            });
            setConJqObj.find(" #input_stufflabelzh_stuffid_"+stuffid).focusout(function (){
                var stufflabel_zh = ld(this).val();
                step2Obj.find(" #stuff_" + stuffid + " #stuff_label_zh_" + stuffid).val(stufflabel_zh)
            });
            //英文名称
            setConJqObj.find(" #input_stufflabelen_stuffid_"+stuffid).on('keydown',function (){
                if(window.event.keyCode == 13){
                    var stufflabel_en = ld(this).val();
                    step2Obj.find(" #stuff_" + stuffid + " #stuff_label_en_" + stuffid).val(stufflabel_en)
                }
            });
            setConJqObj.find(" #input_stufflabelen_stuffid_"+stuffid).focusout(function (){
                var stufflabel_en = ld(this).val();
                step2Obj.find(" #stuff_" + stuffid + " #stuff_label_en_" + stuffid).val(stufflabel_en)
            });
            //txy 20231012 input[type=number] 上下箭头绑定
            setConJqObj.find(` .height-arrow-up`).unbind('click').bind('click',function(){
                var inputElement1 = ld(this).parents('.FieldCon').find("input");
                var newheight = inputElement1.val();
                newheight = parseInt(newheight, 10) + 1;
                inputElement1.get(0).value = newheight;
            });
            setConJqObj.find(` .height-arrow-down`).unbind('click').bind('click',function(){
                var inputElement2 = ld(this).parents('.FieldCon').find("input");
                var newheight = inputElement2.val();
                newheight = parseInt(newheight, 10) - 1;
                inputElement2.get(0).value = newheight;
            });
        });
    }
    this.showfieldsSet = function(stuffid){
        //获取可选字段 已选字段 弹框显示穿梭狂
        var module=that.module;
        var surl='index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard&mode=showfieldsSet&boardid='+popupobj.recode;
        surl+='&boardtype='+popupobj.boardtype;//看板类型
        surl+='&stuffid='+stuffid;
        var tmpPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
        tmpPopupobj.prevshow();
        var tmpselectshowfields = [];
        if(popupobj.StuffOtherSetList&&popupobj.StuffOtherSetList['defaultstuff_'+stuffid]) {
            var tmpOtherSet = popupobj.StuffOtherSetList['defaultstuff_' + stuffid];
            if (tmpOtherSet&&tmpOtherSet.showfields) {
                tmpselectshowfields = tmpOtherSet.showfields;
            }
        }

        ldAjaxNoProgress(surl,{showfields:tmpselectshowfields},function(data) {

            tmpPopupobj.setParams(data.result.title, that.confirmEvent, "", "LdPopWidth800px", module, [stuffid,tmpPopupobj], data.result.oktext, "", data.result.canceltext);
            var table_html = '<div id="ModuleTransferDiv" style="padding: 15px;"></div>';
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
                available: data.result['OPTIONALFIELD'],
                selected: data.result['Selected_Fields'],
                placeholder: data.result['pleaseenterthecategoryyouarelookingforfield'],
            };
            Drag_Transfer.SetTranslabel(translabel);
            Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'set','260');
            tmpPopupobj.center();
        });
    }
    //显示列设置 确认事件
    this.confirmEvent = function(stuffid,tmpPopupobj){
        var Drag_Transfer = new DragTransfer();
        Drag_Transfer.tableObj = ld('#'+tmpPopupobj.divid).find("div#ModuleTransferDiv");
        var selected_arr = Drag_Transfer.getData('right');// 获取已选值的value

        var tmpkey = 'defaultstuff_'+stuffid;//目前只有预制组件有这个设置  先写死

        if(!popupobj.StuffOtherSetList[tmpkey]) {
            popupobj.StuffOtherSetList[tmpkey] = {};
        }

        popupobj.StuffOtherSetList[tmpkey]['showfields'] = JSON.stringify(selected_arr);
        tmpPopupobj.CancelEvent();
        that.loadStuff(stuffid,'customsheet');
    }
    this.getSetLabel = function (setLabel) {
        return '<div class="FieldLabel Mandatory" style="height: 30px;width: 100%;line-height: 45px;font-size:14px;">' +
                    '<span style="padding: 0 10px;">'+setLabel+':</span>' +
                '</div>';
    }
    this.getSetCon = function (setCon) {
        return '<div class="FieldCon" style="height: 30px;width: 100%;line-height: 30px;font-size:14px;">' +
                    setCon +
                '</div>';
    }
    this.getSetFieldHtml = function (setLabel,setCon) {
        return '<div class="FieldBlock">' +
                    that.getSetLabel(setLabel) +
                    that.getSetCon(setCon) +
                '</div>';
    }
    this.getSelectHtml = function(stuffid,StuffOtherSet,setLabel,othersetname){
        var setCon = '<select class="commonSelectPop Bornone" id="StuffOtherSet_'+stuffid+'_'+othersetname+'" style="width: 90%;margin-left: 10px;background-color: #F5F8FC;height: 30px;">' +
                        that.getOptionListHtml(StuffOtherSet[othersetname]) +
                    '</select>';
        return that.getSetFieldHtml(setLabel,setCon);
    }
    this.getOptionListHtml = function (OptionList) {
        var Option = '';
        ld.each(OptionList,function (index,OptionInfo) {
            if(OptionInfo.selected === true || OptionInfo.selected === 'yes')
                Option += '<option value="' + OptionInfo.value +'" selected>' + OptionInfo.label + '</option>';
            else
                Option += '<option value="' + OptionInfo.value +'">' + OptionInfo.label + '</option>';
        });
        return Option;
    }
    this.getInputHtml = function (setKey,stuffid,setVal,type='text',step='',width='90%') {
        type === "number" && (step = `step="${step}"`)
        return `<input type="${type}" ${step} id="${setKey}" data-stuffid="${stuffid}" value="${setVal}" `+
                    `class="detailedViewTextBox Bornone FieldConText hlineheight30" style="width: ${width};margin-left: 10px;">`;
    }
    this.getSetBlockTitle = function (name,label) {
        return `<div class="SetBlockTitle" style="margin:10px 15px 10px 10px" blocksatus="expand" name="${name}">` +
                    '<div data-tip="${label}" class="BlockName tip-items-list ld-overflow-hidden-listcontent" data-direction="top" data-type="position">'+
                        `${label}`+
                    '</div>'+
                '</div>';
    }

    //数据范围设置的html生成
    this.dataRangeSetHtml = function(datarange_set,stuffliststyle,plateid,stuffid){
        if(datarange_set==undefined){
            return;
        }
        var tmpkey = stuffid;
        if(stuffliststyle=='defaultstuff') {
            tmpkey = 'defaultstuff_'+stuffid;
        }
        var platekey = 'plate_'+plateid;
        //数据绑定数组  name值  kayname值
        var databindArr = {
            'homedefault_component_smownerid_check':'usercomponent_isrelated',
            'homedefault_component_approvestatus_check':'approvestatuscomponent_isrelated',
        }
        ld.each(datarange_set,function(rowindex,item){
            var filterset_html ='';
            var html = '';
            var gaplabel = '';
           
            if(!empty(item.modulelabel))gaplabel='-';
            filterset_html += that.getSetBlockTitle(`homedefault_component_setting${tmpkey}_${rowindex}`,arrJsPopLabel['filtersetting']+gaplabel+item.modulelabel);
            html += '<div class="pad8 filtersetcard" style="margin: 20px 15px 10px 10px;"' +
                ' name="content_homedefault_component_setting' + tmpkey + '_' + rowindex + '">' +
                '        <div class="component-setting-title padL10" style="height: auto;line-height: 20px;margin: 4px 0px;font-size: 16px;">' +
                '            <span>'+arrJsPopLabel['selectfilter']+'</span>';
            if(item.modulelabel!=''){
                html +='<span>->'+item.modulelabel+'</span>';
            }
            html += '        </div>';

            if(!empty(item.usercomponent_modulesoption)||!empty(item.usercomponent_fieldsoption)) {
                html +='        <div class="component-setting-input input-group padL10">' +
                    '            <label><input type="checkbox" id="homedefault_component_smownerid_check' + tmpkey + '_' + rowindex + '" class="second_switch marR5">' + arrJsPopLabel['VIEWRANGE'] + '</label>';
            }
            if(!empty(item.usercomponent_modulesoption)) {
                databindArr['homedefault_component_filtermodule'] = 'usercomponent_filtermodule';
                html += '            <select  data-control="homedefault_component_smownerid_check'+tmpkey+'_'+rowindex+'" class="commonSelectPop Bornone" id="homedefault_component_filtermodule' + tmpkey + '_' + rowindex + '" style="width: calc(60% - 20px);margin-left: 10px;background-color: #F5F8FC;height: 25px;">' +
                    item.usercomponent_modulesoption +
                    '            </select>';
            }
            if(!empty(item.usercomponent_fieldsoption)) {
                databindArr['homedefault_component_smownerid'] = 'usercomponent_filters';
                html +='            <select data-control="homedefault_component_smownerid_check'+tmpkey+'_'+rowindex+'" class="commonSelectPop Bornone" id="homedefault_component_smownerid' + tmpkey + '_' + rowindex + '" style="width:  calc(60% - 20px);margin-left: 10px;background-color: #F5F8FC;">' +
                    item.usercomponent_fieldsoption +
                    '            </select>';
            }
            if(!empty(item.usercomponent_modulesoption)||!empty(item.usercomponent_fieldsoption)) {
                html += '        </div>';
            }

            if(!empty(item.timecomponent_fieldsoption)){
                databindArr['homedefault_component_timerange_check'] = 'timecomponent_isrelated';
                databindArr['homedefault_component_timerange'] = 'timecomponent_filters';
                html += '        <div class="component-setting-input input-group padL10">' +
                    '            <label><input type="checkbox" id="homedefault_component_timerange_check'+tmpkey+'_'+rowindex+'" class="second_switch marR5">'+arrJsPopLabel['TIMERANGE']+'</label>' +
                    '            <select data-control="homedefault_component_timerange_check'+tmpkey+'_'+rowindex+'"  class="commonSelectPop Bornone" id="homedefault_component_timerange'+tmpkey+'_'+rowindex+'" style="width:  calc(60% - 20px);margin-left: 10px;background-color: #F5F8FC;height: 25px;">' +
                    item.timecomponent_fieldsoption+
                    '            </select>' +
                    '        </div>';
            }
            if(!empty(item.timecomponent1_fieldsoption)){
                databindArr['homedefault_component1_timerange_check'] = 'timecomponent1_isrelated';
                databindArr['homedefault_component1_timerange'] = 'timecomponent1_filters';
                html += '        <div class="component-setting-input input-group padL10">' +
                    '            <label><input type="checkbox" id="homedefault_component1_timerange_check'+tmpkey+'_'+rowindex+'" class="second_switch marR5">时间起</label>' +
                    '            <select data-control="homedefault_component1_timerange_check'+tmpkey+'_'+rowindex+'" class="commonSelectPop Bornone" id="homedefault_component1_timerange'+tmpkey+'_'+rowindex+'" style="width:  calc(60% - 20px);margin-left: 10px;background-color: #F5F8FC;">' +
                    item.timecomponent1_fieldsoption+
                    '            </select>' +
                    '        </div>';
            }
            if(!empty(item.timecomponent2_fieldsoption)){
                databindArr['homedefault_component2_timerange_check'] = 'timecomponent2_isrelated';
                databindArr['homedefault_component2_timerange'] = 'timecomponent2_filters';
                html += '        <div class="component-setting-input input-group padL10">' +
                    '            <label><input type="checkbox" id="homedefault_component2_timerange_check'+tmpkey+'_'+rowindex+'" class="second_switch marR5">时间止</label>' +
                    '            <select class="commonSelectPop Bornone" data-control="homedefault_component2_timerange_check'+tmpkey+'_'+rowindex+'"  id="homedefault_component2_timerange'+tmpkey+'_'+rowindex+'" style="width:  calc(60% - 20px);margin-left: 10px;background-color: #F5F8FC;">' +
                    item.timecomponent2_fieldsoption+
                    '            </select>' +
                    '        </div>';
            }
            if(!empty(item.approvestatuscomponent_stuffmodule)||!empty(item.approvestatuscomponent_fieldsoption)) {
                html += '        <div class="component-setting-input input-group padL10">' +
                    '            <label><input type="checkbox" id="homedefault_component_approvestatus_check' + tmpkey + '_' + rowindex + '"  class="second_switch marR5">' + arrJsPopLabel['APPROVESTATUS'] + '</label>';
                if (!empty(item.approvestatuscomponent_fieldsoption)) {
                    databindArr['homedefault_component_approvestatus'] = 'approvestatuscomponent_filters';
                    html += '            <select class="commonSelectPop Bornone" id="homedefault_component_approvestatus' + tmpkey + '_' + rowindex + '" style="width:  calc(60% - 20px);margin-left: 10px;background-color: #F5F8FC;">' +
                        item.approvestatuscomponent_fieldsoption +
                        '            </select>';
                }
                html += '        </div>';
            }
            if(!empty(item.advance_demand)) {
                html += '        <div class="component-setting-title padL10" style="height: auto;line-height: 20px;margin: 4px 0;">' +
                    '            <span>'+arrJsPopLabel['Addcustomquery']+'</span>';
                if(item.modulelabel!=''){
                    html +='<span>->'+item.modulelabel+'</span>';
                }
                html += '        </div>';

                html += '        <div class="component-setting-title padL10 advancedsearch high_search_icon tip-items-list" data-tip="'+arrJsPopLabel['advancedsearch']+'" data-direction="top" data-type="position">' +
                    '            <div class="font14 displayflex div-text-hidden " data-plateid="' + plateid + '" data-stuffid="' + stuffid + '" data-stuffliststyle="' + stuffliststyle + '" ' +
                    'data-index="' + rowindex + '" data-frommodule="' + item.modulename + '" name="high_search_click" style="width: calc(100% - 18px);" >' + arrJsPopLabel['advancedsearch'] + '</div>' +
                    '        </div>';
                html += '    </div>';
            }
            PopupJqObj.find('#homedefault_component_datasetting').append(filterset_html);
            PopupJqObj.find('#homedefault_component_datasetting').append(html);
            //首页看板或简报、龙虎榜设置界面，关闭“查看范围或时间筛选器”后，建议不要再显示筛选器的查询字段下拉框了  BUG20240808-14
            //绑定开关事件 homedefault_component_smownerid_check homedefault_component_timerange_check homedefault_component2_timerange_check homedefault_component1_timerange_check
            var bindswitcharr = ['homedefault_component_smownerid_check','homedefault_component_timerange_check','homedefault_component2_timerange_check','homedefault_component1_timerange_check']
            ld.each(bindswitcharr,function(i,keyName){
                var controlid = keyName+tmpkey + '_' + rowindex;
                if(item[databindArr[keyName]]==true){
                    PopupJqObj.find('[data-control='+controlid+']').show();
                }else{
                    PopupJqObj.find('[data-control='+controlid+']').hide();
                }
                PopupJqObj.find('#'+keyName+tmpkey + '_' + rowindex).unbind('change').bind('change',function(){
                    //var checkedvalue = ld(this).prop('checked');
                    PopupJqObj.find('[data-control='+controlid+']').toggle();
                })
            });


            tooltip('#'+popupobj.divid+' #optional-setting_content .tip-items-list', {transition: true, time: 200});
            //edit: xll 2021/02/26 BUG20240223-37  	kfbcrm-新增加的同比环比sql统计图，放到首页看板显示时，筛选器没有默认值，应默认下拉框的第一个
            //zxm 数据绑定
            var DataHtmlBindObj =new DataHtmlBind();
            ld.each(databindArr,function(name,keyName){
                var JqueryObj = PopupJqObj.find('#'+name+tmpkey+'_'+rowindex);

                if(JqueryObj.length > 0)
                    DataHtmlBindObj.setDataBindByJqObj(JqueryObj, popupobj.DatarangeSetList[platekey][tmpkey][rowindex] ,keyName);
            });
            //txy 20231012 筛选器设置展开收起
            step2Obj.find(" #optional-setting_content #homedefault_component_datasetting [name^=homedefault_component_setting]").unbind('click').bind('click',function(){
                var div_filterset_name = ld(this).attr('name');
                var div_blocksatus = ld(this).attr('blocksatus');
                if(ld(this).length > 0){
                    if(div_blocksatus == 'collapse'){
                        ld(this).attr("blocksatus","expand");
                        step2Obj.find(" #optional-setting_content #homedefault_component_datasetting [name=content_"+div_filterset_name+"]").css('display','block');
                    }else{
                        ld(this).attr("blocksatus","collapse");
                        step2Obj.find(" #optional-setting_content #homedefault_component_datasetting [name=content_"+div_filterset_name+"]").css('display','none');}
                }
            });
        });
    }

    this.dataBindOtherSet = function (StuffOtherSet,stuffliststyle,stuffid) {
        if(StuffOtherSet === undefined){
            return false;
        }
        var tmpkey = stuffid;
        if(stuffliststyle === 'defaultstuff') {
            tmpkey = 'defaultstuff_'+stuffid;
        }
        if(!popupobj.StuffOtherSetList[tmpkey]) {
            popupobj.StuffOtherSetList[tmpkey] = {};
        }

        var DataObj = popupobj.StuffOtherSetList[tmpkey];
        var DataHtmlBindObj = new DataHtmlBind();
        //edit: xll 2024/03/22 线索漏斗设置保存后再编辑的展示问题
        ld.each(StuffOtherSet,function (setKey,setInfo) {
            var JqueryObj = PopupJqObj.find('#StuffOtherSet_'+stuffid+'_'+setKey);
            if(JqueryObj.length > 0) {
                if (typeof DataObj[setKey] === "undefined") {
                    DataObj[setKey] = DataHtmlBindObj.getBindFunList(JqueryObj).get(JqueryObj);
                }
                DataHtmlBindObj.setDataBindByJqObj(JqueryObj, DataObj, setKey);
            }
            //类型事件 (一般性事件)
            if(that.OtherSetEvent[setKey])
                that.OtherSetEvent[setKey](JqueryObj,stuffid);
            //类型-组件事件 (特殊事件，组件独有)
            if(that.OtherSetEvent[setKey+'_'+stuffid])
                that.OtherSetEvent[setKey+'_'+stuffid](JqueryObj,stuffid);
        })
    }

    this.OtherSetEvent = {
        classifyField_113 : function (JqueryObj,stuffid) {
            JqueryObj.unbind('change').bind('change',function () {
                that.loadStuff(stuffid,'chart');
            })
        },
        countType_113 : function (JqueryObj,stuffid) {
            this.classifyField_113(JqueryObj,stuffid);
        },
        datalabel : function(JqueryObj,stuffid){
            JqueryObj.unbind('change').bind('change',function () {
                var curposition = ld(JqueryObj).val();
                var Selector = ' #preview_stuffcont_' + stuffid;
                var myChart_jsObj;
                if (ld('#' + that.popupobj.divid + Selector).length > 0)
                    myChart_jsObj = ld('#' + that.popupobj.divid + Selector).get(0);
                else {
                    myChart_jsObj = ld(Selector).get(0);
                }
                var newChartObj = ld(myChart_jsObj).prop('newChartObj');
                newChartObj.labelPosition = curposition;
                var fun_name = 'newChart_' + stuffid;
                var option = newChartObj.getOption(fun_name);
                newChartObj.setOption(option);
            });
        },
        CarouselTimer_117 : function (JqueryObj,stuffId) {
            var tmpkey = 'defaultstuff_'+stuffId,
                CarouselData = popupobj.StuffOtherSetList[tmpkey],
                timer = JqueryObj.val();
            JqueryObj.unbind('blur').bind('blur',function () {
                timer = parseFloat(this.value) > 0 ? parseFloat(this.value) : timer;
                this.value = timer

                //更新预览
                var CarouselJqObj = PopupJqObj.find('#preview_stuffcont_'+stuffId)
                AjaxJSPage('LoadStuffClass','include/js/modules/Home/LoadStuffClass.js');
                LoadStuffClass.showStuff(stuffId,CarouselJqObj,CarouselData);
            })
        },
        CarouselImgs_117 : function (JqueryObj,stuffId) {
            var tmpkey = 'defaultstuff_'+stuffId,
                CarouselListObj = PopupJqObj.find('#CarouselImgList'),
                RowList = CarouselListObj.find('.CarouselImgRow'),
                CarouselData = popupobj.StuffOtherSetList[tmpkey];
            CarouselData['CarouselImgs'] = popupobj.StuffOtherSet[tmpkey]['CarouselImgs'];
            var setInfo = CarouselData['CarouselImgs'];
            // 排序事件
            Sortable.create(CarouselListObj.get(0), {
                draggable:".CarouselImgRow",
                handle: ".drag-handle",
                animation: 150,
                sort: true,
                onEnd: function (evt){
                    var item = setInfo.splice(evt.oldIndex,1).pop();
                    setInfo.splice(evt.newIndex,0,item);

                    //更新预览
                    var CarouselJqObj = PopupJqObj.find('#preview_stuffcont_'+stuffId)
                    AjaxJSPage('LoadStuffClass','include/js/modules/Home/LoadStuffClass.js');
                    LoadStuffClass.showStuff(stuffId,CarouselJqObj,CarouselData);
                },
            });
            //编辑、删除、点击预览
            RowList.each(function (index, row) {
                var left = ld(row).find('.CarouselImgRowLeft');
                previewImage(left.find('img').get(0));

                that.CarouselRowEvent(ld(row));
            })
            if(RowList.length === 1) {
                RowList.find('.ld-category-del').hide();
                RowList.find('.ld-category-drag').hide();
            }
        },
        addCarouselImg_117 : function (JqueryObj,stuffid) {
            PopupJqObj.find('#addCarouselImg').unbind('click').bind('click',function () {
                var tmpkey = 'defaultstuff_'+stuffid,
                    defaultCarousel = popupobj.StuffOtherSet[tmpkey]['addCarouselImg']['defaultCarousel'],
                    index = popupobj.StuffOtherSetList[tmpkey]['CarouselImgs'].length;
                that.addCarousel({
                    title: defaultCarousel.title,
                    path: '',
                    link: '',
                },'add',index)
            })
        },
        showfields: function (JqueryObj,stuffid) {
            //显示字段设置点击事件
            PopupJqObj.find('#StuffOtherSet_'+stuffid+'_showfieldsbtn').unbind('click').bind('click',function(){
                that.showfieldsSet(stuffid);
            });
        },
    }

    that.addCarousel = function (carouselImgInfo,type,index) {
        carouselImgInfo = Object.assign({},carouselImgInfo);
        var carouselPop = '',
            fileList = type === 'add' ? [] : [carouselImgInfo],
            carouselPopCon = [
                {
                    'label' : arrJsPopLabel['CarouselTitle'],
                    'con' : `<input type="text" class="ld-input-inner gwidth90" id="carouselTitle" value="${carouselImgInfo.title}">`,
                },
                {
                    'label' : arrJsPopLabel['Choosepictures'],
                    'con' : `<div id="carouselSelImg" class="ld-button-primary ld-button">选择图片</div>`+
                        `<span style="color: red;font-size: 12px;margin-left: 20px">建议图片尺寸比例宽*高：2680 * 640</span>` +
                        `<div id="carouselSelImgHidden"  style="display: none"></div>` +
                        `<div class="ld-file-watermark-image-show" id="carouselImgInfo" style="display:none;"></div>`,
                },
                {
                    'label' : arrJsPopLabel['CarouselLink'],
                    'con' : `<input type="text" placeholder="`+arrJsPopLabel['MSWHttpOrHttps']+`" class="ld-input-inner gwidth90" id="carouselLink" value="${carouselImgInfo.link}">`,
                },
            ],
            popTitle = type === 'add' ? arrJsPopLabel['NewCarousel'] : arrJsPopLabel['EditCarousel'];
        ld.each(carouselPopCon,function (index,info) {
            carouselPop += that.getTableTrCon(info.label,info.con);
        })
        carouselPop = that.getTableCon(carouselPop);
        var popupObj = CrmPopup.load('','','','LdPopWidth650px','Home','','','','');
        popupObj.prevshow();
        var tmpPopupJqObj = ld('#'+popupObj.divid)
        var addFun = function () {
            var stuffId = 117;
            if(empty(popupObj.carouselImgInfo.path)) {
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ImgPathNoEmpty']);
                return false;
            }
            popupObj.carouselImgInfo.title = tmpPopupJqObj.find('#carouselTitle').val()
            popupObj.carouselImgInfo.link = tmpPopupJqObj.find('#carouselLink').val()
            var CarouselData = popupobj.StuffOtherSetList['defaultstuff_'+stuffId]
            CarouselData['CarouselImgs'][index] = popupObj.carouselImgInfo;

            var ListObj = PopupJqObj.find('#CarouselImgList');
            if(type === 'add') {
                var newRow = that.getCarouselRow(popupObj.carouselImgInfo)
                ListObj.append(newRow);
                var rowList = ListObj.find('.CarouselImgRow'),
                    last = rowList.last(),
                    left = last.find('.CarouselImgRowLeft');
                that.CarouselRowEvent(last);
                previewImage(left.find('img').get(0));

                if(index === 1) {
                    rowList.first().find('.ld-category-del').show();
                    rowList.first().find('.ld-category-drag').show();
                }
            }
            else {
                var editRow = ListObj.find('.CarouselImgRow').get(index)
                ld(editRow).find('img').attr('src',popupObj.carouselImgInfo.path);
            }

            popupObj.CancelEvent();

            //更新预览
            var CarouselJqObj = PopupJqObj.find('#preview_stuffcont_'+stuffId)
            AjaxJSPage('LoadStuffClass','include/js/modules/Home/LoadStuffClass.js');
            LoadStuffClass.showStuff(stuffId,CarouselJqObj,CarouselData);

        }
        popupObj.setParams(popTitle, addFun, '', 'LdPopWidth650px', 'Home', '', arrJsPopLabel['CONFIRME'], '', arrJsPopLabel['CANCEL']);
        popupObj.show(carouselPop);
        popupObj.carouselImgInfo = carouselImgInfo
        getJsScript('include/js/modules/Home/WebUploaderClass.js', function () {
            var carouselUpObj = new InitWebUpload_Carousel(),
                carouselHidden = tmpPopupJqObj.find('#carouselSelImgHidden');
            carouselUpObj.setPopupJqObj(tmpPopupJqObj);
            carouselUpObj.webUpload(carouselHidden,{
                fileTypeDuplicate: 'yes',	//附件类型判断
                fileNameDuplicate: 'yes',	//同名附件判断
                module: 'Home',
                listId: 'carouselImgInfo',  // 容器
                jsonData: fileList,
                inputFileName: 'image'	//选择附件后赋值标签的name
            })
            tmpPopupJqObj.find('#carouselSelImg').bind('click',function (event) {
                carouselHidden.find(' input[name=file]').click();
            })
        });
    }
    
    that.CarouselRowEvent = function (rowJqObj) {
        var stuffId = 117,
            tmpkey = 'defaultstuff_'+stuffId,
            CarouselData = popupobj.StuffOtherSetList[tmpkey];
        CarouselData['CarouselImgs'] = popupobj.StuffOtherSet[tmpkey]['CarouselImgs'];
        var setInfo = CarouselData['CarouselImgs'];
        // 编辑事件
        rowJqObj.find('.ld-category-edit').unbind('click').bind('click',function () {
            var index = ld(this).parents('.CarouselImgRow').index(),
                carouselImgInfo = setInfo[index];
            that.addCarousel(carouselImgInfo,'edit',index)
        })
        // 删除事件
        rowJqObj.find('.ld-category-del').unbind('click').bind('click',function () {
            var rowObj = ld(this).parents('.CarouselImgRow'),
                restRowList = rowObj.siblings(),
                index = rowObj.index();
            setInfo.splice(index,1);
            rowObj.remove();

            //更新预览
            var CarouselJqObj = PopupJqObj.find('#preview_stuffcont_'+stuffId)
            AjaxJSPage('LoadStuffClass','include/js/modules/Home/LoadStuffClass.js');
            LoadStuffClass.showStuff(stuffId,CarouselJqObj,CarouselData);

            if(restRowList.length === 1) {
                restRowList.find('.ld-category-del').hide();
                restRowList.find('.ld-category-drag').hide();
            }
        })
    }

    that.getCarouselRow = function (info) {
        return '<div class="CarouselImgRow">' +
                    '<div  class="CarouselImgRowLeft">' +
                        `<img src="${info.path}" alt="" style="max-width: 100%;max-height: 100%;">` +
                    '</div>'+
                    '<div class="CarouselImgRowRight">' +
                        '<b class="ld-category-icon ld-category-edit" style="margin-left: 6px;cursor: pointer;"></b>' +
                        '<b class="ld-category-icon ld-category-del" style="margin-left: 6px;cursor: pointer;"></b>' +
                        '<b class="ld-category-icon ld-category-drag drag-handle" style="cursor: move;"></b>' +
                    '</div>'+
                '</div>';
    }

    that.getTableCon = function (tableCon) {
        return `<table class="ld-public-content padTB10" border="0" cellpadding="0" cellspacing="0" width="100%"> 
                    <tbody>${tableCon}</tbody> 
                </table>`;
    }
    that.getTableTrCon = function (setLabel,setCon) {
        return `<tr>
                    <td class="ld-form-item-label">
                        <label>${setLabel}</label>
                    </td>
                    <td class="ld-form-item-content">
                        ${setCon}
                    </td>
                </tr>`;
    }

    that.fun_other_conditions = function (curobj,datarange_set){
        //zxm 20230718 新建简报 点击高级查找条件报错的问题
        if(datarange_set==undefined){
            return;
        }
        var frommodule = ld(curobj).data('frommodule');//模块
        var lineindex = ld(curobj).data('index');
        var stuffliststyle = ld(curobj).data('stuffliststyle');//组件类型
        var stuffid = ld(curobj).data('stuffid');//组件ID
        var plateid = ld(curobj).data('plateid');//区块ID
        var OkfunParamObj = [lineindex,stuffliststyle,plateid,stuffid];//参数
        var advance_demand = datarange_set[lineindex]['advance_demand'];
        var advance_demand_groups = datarange_set[lineindex]['advance_demand_groups'];

        var module = 'Home';
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=SalesKitSetOtherCondition&frommodule='+frommodule;
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",module,"","","","");
        var advft_criteria_groups_json = advance_demand_groups;
        var advft_criteria_json = advance_demand;
        crmPopupobj.rowindex = lineindex;
        var params = {'advft_criteria':advft_criteria_json,'advft_criteria_groups':advft_criteria_groups_json};

        crmPopupobj.prevshow();
        ldAjaxNoProgress(surl,params,function(data){
            if(data.code==1){
                crmPopupobj.setParams(arrJsPopLabel['SettingOtherConditionJS'],that.set_advancedemand,'',"LdPopWidth800px",'Settings',OkfunParamObj,data.result.oktext,"",data.result.canceltext,"");
                crmPopupobj.createScrollDiv();
                crmPopupobj.show(data.result.content);

                var advancefilterobj = new cls_advanceFilter();
                that.advancefilterobj = advancefilterobj;
                var params = {};
                params.columnOptionHtml = data.result.columns_block;
                params.fLabels = data.result.flabels;
                params.datetimestr = data.result.datetimestr;
                params.advfilterhtml = data.result.foption;
                params.fieldsinfo = data.result.fieldinfo;
                params.criteria_groups_arr = data.result.criteria_groups_arr;
                params.module = module;
                advancefilterobj.showAdvanceFilter(crmPopupobj,params);
            }
        })
    }

    //获取高级查询条件
    that.set_advancedemand = function (lineindex,stuffliststyle,plateid,stuffid){
        var curpopupobj = CrmPopup.getPopupObj('last');
        if(that.advancefilterobj.checkAdvancedFilter()==false)
        {
            return false;
        }
        var advft_criteria =that.advancefilterobj.advft_criteria;
        var advft_criteria_groups = that.advancefilterobj.advft_criteria_groups;
        var tmpkey = stuffid;
        if(stuffliststyle=='defaultstuff') {
            tmpkey = 'defaultstuff_'+stuffid;
        }
        popupobj.DatarangeSetList['plate_'+plateid][tmpkey][lineindex]["advance_demand"] = advft_criteria;
        popupobj.DatarangeSetList['plate_'+plateid][tmpkey][lineindex]['advance_demand_groups'] = advft_criteria_groups;
        curpopupobj.CancelEvent();
    }

    //应用范围
    that.setchooseScopePopup=function(jqueryobj,selectvalue){

        var module=that.module;
        var popup_user_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_scopetype=private&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user&checkprivilege=no';
        var popup_groups_url ='module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module='+module+'&selecttype=group&popup_inputtype=checkbox&popup_selecttype=group';
        var popup_role_url ='module=Users&action=UsersAjax&file=viewprofileinfo&view=private&fld_module='+module+'&popup_selecttype=profile&popup_inputtype=checkbox';

        if(selectvalue=='user'||selectvalue=='group'||selectvalue=='role')
        {

            getJsScript('include/js/ScopePopup/ScopePopupObj.js',function()
            {
                scopepopupobj =  new ScopePopupObj(module);
                scopepopupobj.popup_caption_value = arrJsPopLabel['APPLICABLESCOPE'];//标题title
                scopepopupobj.popup_header =  '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+scopepopupobj.popup_searchvalue+'\'></div><div id="selectUserCheck" class="select-input"><input type="checkbox" id=\'viewuser_disableuser\'><label for=\'viewuser_disableuser\'>'+arrJsPopLabel['LBL_VIEWDISABLEUSER']+'</label></div>';
                scopepopupobj.popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];//查询框默认显示内容

                getJsScript('include/js/ScopePopup/ScopePopup.js',function()
                {
                    cls_ScopePopup.popup_selecttype = ld(jqueryobj).val();
                    cls_ScopePopup.prop.popup_module = module;//模块
                    if(PopupJqObj.find("[name=selectallocatetype]").val() == selectvalue){
                        cls_ScopePopup.prop.popup_value = PopupJqObj.find("[name=selectallocateid]").val();
                    }else{
                        cls_ScopePopup.prop.popup_value = '';
                    }
                    if(selectvalue=='user')
                    {
                        cls_ScopePopup.prop.popup_url = popup_user_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
                    }
                    else if(selectvalue=='group')
                    {
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP'];
                        cls_ScopePopup.prop.popup_url = popup_groups_url
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+scopepopupobj.popup_searchvalue+'\'><input id=\'viewuser_unfoldsubgroup\' type="checkbox"><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';

                    }
                    else
                    {

                        cls_ScopePopup.prop.popup_url = popup_role_url
                        scopepopupobj.popup_searchvalue=arrJsPopLabel['pleaseenterprofile'];
                        scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+scopepopupobj.popup_searchvalue+'\'></div>';
                    }
                    var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                    var parentsetEventBtnCancel=scopepopupobj.setEventBtnCancel;
                    //重写确认按钮事件
                    scopepopupobj.setEventBtnOk=function(){
                        ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').unbind('click').on('click',function(){
                            var selected_groupid = cls_ScopePopup.return_obj.return_id;
                            if(empty(selected_groupid)){
                                if(selectvalue == 'group'){
                                    confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }else{
                                    confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
                                    RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                                    return false;
                                }
                            }


                            ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
                            var selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                            PopupJqObj.find("[name=selectallocateid]").val(selected_user);
                            PopupJqObj.find("[name=selectallocatetype]").val(selectvalue);
                            return false;
                        });
                    }
                });
            });
        }
    }

    //保存看板
    that.SaveHomeboard = function (){
        var curKanbanBoardid = ld('#home_index #boardid').val();//用户当前首页展示的看板是哪个看板
        //var module = getUrlParam("pageto_module");
        //if(module=='Settings')
           //module='Home'
        var module = that.module;

        var boardname = that.htmlspecialchars(PopupJqObj.find("#step1 #homeboardname").val());
        var description = that.htmlspecialchars(PopupJqObj.find("#step1 #Homeboard_description").val());
        var boardlayout = PopupJqObj.find("#step1 #homeboardchoselayout").val();
        var timesearchdefault = step2Obj.find(" #homeboard_draw #homeboard_laydata_value").val();
        var approve_value_array = [];
        step2Obj.find(" #homeboard_draw .home_header_top .home-header-approve-select input[name=homeboard_hear_approve]:checked").each(function(){
            approve_value_array.push(this.value);
        });
        if(approve_value_array.length > 0){
            approve_value = approve_value_array.join(',');
        }else{
            approve_value = '';
        }
        var homeboard_plate = [];
        step2Obj.find(" #homeboard_draw [name=homeboard_draw_layout] [name=homeboard_draw_layout_block]").each(function (plate_index,plate_obj){
            var platewidth = '1-1';
            switch(plate_obj.style.width){
                case '100%':
                    platewidth = '1-1';
                    break;
                case '66%':
                    platewidth = '2-3';
                    break;
                case '34%':
                    platewidth = '1-3';
                    break;
                case '50%':
                    platewidth = '1-2';
                    break;
                default:
                    break;
            }
            var homeboard_plate_stuff = [];
            ld(plate_obj).find('div[name=homeboard_draw_block_stuff]').each(function (stuff_index,stuff_obj){
                var stuffid = ld(stuff_obj).data('stuffid');
                var boardstuffid = ld(stuff_obj).data('boardstuffid');
                if (parseInt(stuffid) == 43){
                    var stuffheight='auto';
                }else {
                    var stuffheight = stuff_obj.style.height;
                }
                var stufftitle_zh = ld(stuff_obj).find('#stuff_label_zh_'+stuffid).val();
                var stufftitle_en = ld(stuff_obj).find('#stuff_label_en_'+stuffid).val();
                var homeboard_plate_stuff_array = {
                    'stuffid' : stuffid,
                    'boardstuffid' : boardstuffid,//ld_homeboard_plate_stuff主键ID
                    'stufftype' : ld(stuff_obj).data('stuffliststyle'),
                    'height' : stuffheight,
                    'stufftitle_zh' : stufftitle_zh,
                    'stufftitle_en' : stufftitle_en
                }
                homeboard_plate_stuff.push(homeboard_plate_stuff_array);
            })
            var homeboard_plate_array = {
                'plateid' : ld(plate_obj).data('plateid'),
                'platetype' : ld(plate_obj).data('platetype'),
                'platewidth' : platewidth,
                'homeboard_plate_stuff' : homeboard_plate_stuff
            }
            homeboard_plate.push(homeboard_plate_array);
        });

        var homeboard_content = {
            'boardname' : boardname,
            'description' : description,
            'boardlayout' : boardlayout,
            'timesearchdefault' : timesearchdefault,
            'approve_value' : approve_value,
            'homeboard_plate' : homeboard_plate,
            'scope' : PopupJqObj.find("#step1 [name=selectallocatetype]").val(),
            'scope_list' : PopupJqObj.find("#step1 [name=selectallocateid]").val(),
        }
        var homeboard_json = JSON.stringify(homeboard_content);
        var surl='index.php?module='+module+'&action='+module+'Ajax&file=SaveHomeboard&boardid='+popupobj.recode;
        surl+='&boardtype='+popupobj.boardtype;//看板类型

        //zxm 20230627 将数组中的模块label和option删掉,防止参数传输产生问题
        ld.each(popupobj.DatarangeSetList,function(plateid,plateinfo){
            ld.each(plateinfo,function(stuffid,stuffinfo){
                ld.each(stuffinfo,function(key,conditioninfo){
                    if(!empty(conditioninfo['approvestatuscomponent_fieldsoption'])){
                        delete conditioninfo['approvestatuscomponent_fieldsoption'];
                    }
                    if(!empty(conditioninfo['modulelabel'])){
                        delete conditioninfo['modulelabel'];
                    }
                    if(!empty(conditioninfo['timecomponent_fieldsoption'])){
                        delete conditioninfo['timecomponent_fieldsoption'];
                    }

                    if(!empty(conditioninfo['usercomponent_modulesoption'])){
                        delete conditioninfo['usercomponent_modulesoption'];
                    }
                });
            });
        });
        //edit:xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块（增加看板图标上传）
        var formData = new FormData();
        formData.append('homeboard_json',homeboard_json);
        formData.append('datarange_set',JSON.stringify(popupobj.DatarangeSetList));
        formData.append('StuffOtherSet',JSON.stringify(popupobj.StuffOtherSetList));
        var icon_path = PopupJqObj.find("#" + module + "_icon_image").attr('src');
        var icon_url = "&icon_path=" + icon_path;
        ldAjax_File(surl  + icon_url, formData, function (data){
            if(data.code == -1){
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
            }else{
                var saved_boardid = data.result.saved_boardid;
                var boardname = data.result.boardname;
                if(popupobj.edithomefromlist == 'yes'){
                    freshen_homeboardlist(popupobj.boardtype);
                }
                //编辑的看板正好是当前看板 就刷新  不然不刷新
                if(saved_boardid==curKanbanBoardid){
                    window.location.reload();
                }else if(popupobj.boardtype=='MobileReport'){
                    LeftMenuSettingClick(event,ld('[name=mobile_home_setting]'))
                }else{
                    var homeBoardListObj = ld('#homeboard_List').find('#sortable-list')
                    if(popupobj.recode<=0){
                        //zxm 20230905 kfbcrm-首页-新建看板-点击保存，看板列表没有自动更新
                        homeBoardListObj.append('<li class="ld-category-draggable" data-boardid="'+saved_boardid+'">' +
                            '<div onclick="Homeboard_changing_over('+saved_boardid+')" style="margin-left:31px;" class="homeboard_label" title="'+boardname+'">' +
                            boardname+
                            '</div>' +
                            '<div class="ld_homeboard_head_select_edit">' +
                            //edit: xll 2024/03/11 BUG20240311-44 看板新增后无法编辑
                            `<b onclick="editHomeboard(${saved_boardid},'${popupobj.boardtype}')" data-tip="${arrJsPopLabel['EDIT']}" data-direction="top"` +
                            ' data-type="position" style="cursor: pointer;" class="ld-category-icon ld-category-edit sort-tip-items"></b>' +
                            '<b class="ld-category-icon ld-category-drag drag-handle sort-tip-items" data-tip="'+arrJsPopLabel['DRAGTOSORT']+'" data-direction="left" data-type="position" style="cursor: move;"></b>' +
                            '</div>' +
                            '</li>');
                        //BUG20240719-40 首页，新建数据看板，将左侧数据简报拖动中间区域后，数据简报没有显示“设置”按钮
                        popupobj.saleskitObj.saveSalesKitAjaxFun(saved_boardid);
                    }
                    else {
                        //edit: xll BUG20240108-33 更改看板名-点击保存后，看板名没有发生相应改变，需要刷新界面才会变化。
                        homeBoardListObj.find('li').filter((index,liObj) => {
                            var tmpBoardId = ld(liObj).data('boardid');
                            return tmpBoardId !== undefined && tmpBoardId.toString() === saved_boardid.toString();
                        }).find('.homeboard_label').text(boardname);
                    }
                }
                popupobj.cancelhomeboard();
            }

            ld('#rptContentLoading').hide();
        })

    }

    that.focushomeboardname = function(){
        var range, el = document.getElementById('homeboardname');
        if (el.setSelectionRange) {
            el.focus();
            el.setSelectionRange(el.value.length, el.value.length)
        } else {
            range = el.createTextRange();
            range.collapse(false);
            range.select();
        }
    }
    that.htmlspecialchars = function(str) {
        str = str.replace(/&/g, '&amp;');
        str = str.replace(/</g, '&lt;');
        str = str.replace(/>/g, '&gt;');
        str = str.replace(/"/g, '&quot;');
        str = str.replace(/'/g, '&#039;');
        // return encodeURIComponent(str);
        return str;
    }

    that.nextBtnClick = function (){
        //edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块
        //var module = getUrlParam("pageto_module");
        //if(module=='Settings')
            //module='Home'
        var module = that.module;
        var homeboardname_label = CrmPopup.findHtmlobj(popupobj.divid,'homeboardname_label').val();
        if(ld('#homeboardname').length > 0 && ld('#homeboardname').val() == '' || empty(ld('#homeboardname').val())){
            var confirm_str = homeboardname_label+arrJsPopLabel['CANOTEMPTYGTH'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        var formData = new FormData();
        var editIconAreaDivid = 'editarea_'+module+'_action';
        var editIconAreaDivobj = PopupJqObj.find("#"+editIconAreaDivid+" [name=active_icon]");
        if(editIconAreaDivobj.length>0&&editIconAreaDivobj.get(0).files.length>0)
        {
            formData.append('active_icon', ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files[0]);
            formData.append('active_icon_name', ld("#"+editIconAreaDivid+" [name=active_icon_name]").val());
            formData.append("active_icon_size",ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files[0].size);
            formData.append("active_icon_type",ld("#"+editIconAreaDivid+" [name=active_icon]").get(0).files[0].type);
        }
        var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=HomeboardNextStep&boardid='+popupobj.recode+'&homeboardname='+that.htmlspecialchars(ld('#homeboardname').val());
        surl+='&boardtype='+popupobj.boardtype;//看板类型
        ld('#rptContentLoading').show();
        ldAjax_File(surl, formData, function (data){
            ld('#rptContentLoading').hide();
            if(data.code == 1){
                //成功
                ld('#rptContentLoading').hide();
                PopupJqObj.find('#step').val(2);
                PopupJqObj.find('#step1').hide();
                PopupJqObj.find('#step2').show();
                PopupJqObj.find('#next').hide();
                PopupJqObj.find('#astep').show();
                PopupJqObj.find('#save').show();
                ld('#' + popupobj.divid + '_head [name=step1] .ld_homeboard_head_step').css('background-color','#999');
                ld('#' + popupobj.divid + '_head [name=step2] .ld_homeboard_head_step').css('background-color','#3B7CFF');
                //edit: xll BUG0069735 kfbcrm-可视化分析-新建数据看板-当上传封面失败时，在点击下一步时就弹出提示信息
                PopupJqObj.find("#" + module + "_icon_image").attr('src',data.result);
                // PopupJqObj.find("#" + module + "_icon_image").show();

                ld.each(step2Obj.find(" #homeboard_stuff_list [name^=stufflist_title_]"),function(index,obj){
                    if(ld(this).find('.icon-develop_active').length > 0){
                        var div_list_name = ld(this).attr('name');
                        var scollheight = step2Obj.find(" #homeboard_stuff_list [name=content_"+div_list_name+"]").get(0).scrollHeight;
                        step2Obj.find(" #homeboard_stuff_list [name=content_"+div_list_name+"]").css('height',scollheight+'px');
                    }
                })
                if(popupobj.Homeboard_content != '' && popupobj.Homeboard_content!= undefined && popupobj.recode>0) {
                    for (let i = 0; i < homeboard_plate.length; i++) {
                        var plate_stuff = homeboard_plate[i].homeboard_plate_stuff;
                        for (let j = 0; j < plate_stuff.length; j++) {
                            that.loadWidgets(plate_stuff[j].stuffid, plate_stuff[j].stufftype, plate_stuff[j].stufftitle, plate_stuff[j].stufflisttype,plate_stuff[j].chart_type);
                            that.bindMoveAfter();
                        }
                    }
                }

                PopupJqObj.find('#step2 #optional-list #search_stufflist').on('keydown',function (){
                    var search_str = ld(this).val();
                    if(window.event.keyCode === 13 || search_str === ''){
                        that.searchStuff(search_str);
                    }
                });

                PopupJqObj.find('#step2 #optional-list #search_stufflist').focusout(function (){
                    var search_str = ld(this).val();
                    that.searchStuff(search_str);
                });

                PopupJqObj.find('#step2 #optional-list #searchBtn').bind('click',function (){
                    var search_str = ld(this).siblings('input').val();
                    that.searchStuff(search_str);
                });
            }
            else if(data.code == -2){
                //仅名字重复
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['HOMEBOARDDUPLICATE']);
                return false;
            }
            else if(data.code == -1){
                //名字重复并且图片上传失败
                RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['HOMEBOARDDUPLICATE'] + '</br>' + data.msg);
                return false;
            }
            else if(data.code == -3){
                //仅图片上传失败
                RemindsMsg("","LdPopWidth400px","","yes","",data.msg);
                return false;
            }
            that.focushomeboardname();
        })

    }


    that.focushomeboardname();

    //下一步 头部按钮
    PopupJqObj.find('#' + popupobj.divid + '_head #next').unbind('click').bind('click',function (){
        that.nextBtnClick();
    });

    //下一步step2按钮
    PopupJqObj.find('#' + popupobj.divid + '_head').find('label[name=step2]').unbind('click').bind('click',function (){
        that.nextBtnClick();
    });

    that.searchStuff = function (search_str) {
        if(search_str == ''){
            PopupJqObj.find('#step2 #optional-list li').show();
        }else{
            PopupJqObj.find('#step2 #optional-list li').hide();
            PopupJqObj.find('#step2 #optional-list li[data-stufftitle_label*='+search_str+']').show();
        }
        ld.each(step2Obj.find(" #homeboard_stuff_list [name^=content_stufflist_title_] ul"),function(index,obj){
            ld(this).show();
            if(ld(this).find('li:visible').length > 0) {
                ld(this).parent().find("#homeboard_list_notcontent").hide();
                var scollheight = ld(this).get(0).scrollHeight;
                ld(this).parent().css('height', scollheight + 'px');
            }else{
                ld(this).hide();
                ld(this).parent().find("#homeboard_list_notcontent").show();
                ld(this).parent().css('height', '40px');
            }
        })
        ld.each(step2Obj.find(" #homeboard_stuff_list .icon-develop"),function (){
            ld(this).addClass('icon-develop_active');
        });
    }

    //点击上一步触发函数
    that.lastBtnClick = function () {
        PopupJqObj.find('#step').val(1);
        PopupJqObj.find('#step1').show();
        PopupJqObj.find('#step2').hide();
        PopupJqObj.find('#next').show();
        PopupJqObj.find('#astep').hide();
        PopupJqObj.find('#save').hide();
        ld('#' + popupobj.divid + '_head [name=step2] .ld_homeboard_head_step ').css('background-color','#999');
        ld('#' + popupobj.divid + '_head [name=step1] .ld_homeboard_head_step').css('background-color','#3B7CFF');
        that.focushomeboardname();
    }
    //上一步 头部按钮
    PopupJqObj.find('#' + popupobj.divid + '_head #astep').unbind('click').bind('click',function (){
        that.lastBtnClick();
    });

    //上一步 step1按钮
    PopupJqObj.find('#' + popupobj.divid + '_head').find('label[name=step1]').unbind('click').bind('click',function (){
        that.lastBtnClick();
    });

    //保存 头部按钮
    PopupJqObj.find('#' + popupobj.divid + '_head #save').unbind('click').bind('click',function (){
        that.SaveHomeboard();
    });

    //适用范围绑定
    PopupJqObj.find("#step1 [name=radiotype]").unbind("click").bind("click",function(){
        //设置审批流程适用范围
        //that.approvedatainfo_arr.approveallocatetype=ld(this).val();
        if(ld(this).val()==1)
            var selectvalue='group';
        else if(ld(this).val()==2)
            var selectvalue='user'
        else if(ld(this).val()==3)
            var selectvalue='role'

        if(ld(this).val() == 0){
            PopupJqObj.find("#step1 [name=selectallocateid]").val('');
            PopupJqObj.find("#step1 [name=selectallocatetype]").val('all');
        }else{
            that.setchooseScopePopup(ld(this),selectvalue);
        }
    })

    //编辑 加载各组件内容
    if(popupobj.Homeboard_content != '' && popupobj.Homeboard_content!= undefined && popupobj.recode>0){
        var homeboard_plate = popupobj.Homeboard_content.homeboard_plate;
        for(let i = 0;i<homeboard_plate.length;i++){
            var plateid = homeboard_plate[i].plateid;
            var plate_stuff = homeboard_plate[i].homeboard_plate_stuff;

            var draw_block_stuffhtml = '';
            for(let j = 0;j<plate_stuff.length;j++){
                var tmp_stufflisttype = plate_stuff[j].stufflisttype;
                var tmp_boardstuffid = plate_stuff[j].boardstuffid;
                if(tmp_stufflisttype == 'customreport'){
                    var tmp_stuffid = 'customEchart_' + plate_stuff[j].stuffid;
                }else if(tmp_stufflisttype == 'customtable'){
                    var tmp_stuffid = 'customtable_' + plate_stuff[j].stuffid;
                }else{
                    var tmp_stuffid = plate_stuff[j].stuffid;
                }
                draw_block_stuffhtml += that.get_draw_block_stuffhtml(tmp_stuffid,plate_stuff[j].stufftype,plate_stuff[j].stufftitle,plate_stuff[j].stufflisttype,plate_stuff[j].stufftitle_label,plate_stuff[j].height,plate_stuff[j].stufftitle_zh,plate_stuff[j].stufftitle_en,tmp_boardstuffid);
            }

            if(draw_block_stuffhtml!='')
                PopupJqObj.find('#step2 #homeboard_drawingboard #homeboard_draw [data-plateid='+plateid+']').html(draw_block_stuffhtml);

        }
    }

    //选择模板
    PopupJqObj.find('#step1 [name=homeboardlayout]').unbind('click').bind('click', function () {
        var layouttype = ld(this).data('layout');
        popupobj.layouttype = layouttype;
        PopupJqObj.find('#step1 .ld_homeboard_layout_chose').removeClass('ld_homeboard_layout_chose');
        PopupJqObj.find('#step1 #homeboardlayout_'+layouttype).addClass('ld_homeboard_layout_chose');
        PopupJqObj.find('#step1 #homeboardchoselayout').val(layouttype);

        if(layouttype == 'tl1r1'){
            PopupJqObj.find('#step2 #homeboard_draw [name=homeboard_draw_layout] [data-platetype=left]').css('width','50%');
            PopupJqObj.find('#step2 #homeboard_draw [name=homeboard_draw_layout] [data-platetype=right]').css('width','50%');
        }else if(layouttype == 'tl2r1'){
            PopupJqObj.find('#step2 #homeboard_draw [name=homeboard_draw_layout] [data-platetype=left]').css('width','66%');
            PopupJqObj.find('#step2 #homeboard_draw [name=homeboard_draw_layout] [data-platetype=right]').css('width','34%');
        }else if(layouttype == 'tl1r2'){
            PopupJqObj.find('#step2 #homeboard_draw [name=homeboard_draw_layout] [data-platetype=left]').css('width','34%');
            PopupJqObj.find('#step2 #homeboard_draw [name=homeboard_draw_layout] [data-platetype=right]').css('width','66%');
        }
    });

    //绑定拖动
    ld.each(step2Obj.find(" #homeboard_drawingboard #homeboard_stuff_list [name=homeboard_stuff_list_ul]"),function(index,obj){
        //拖动事件
        Sortable.create(ld(this).get(0), {
            group: {name: 'stuff',pull:'clone',put:false},
            sort:false,
            draggable:".drag-handle",
            onStart : function () {

            },
            onEnd: function (evt){
                that.StuffLiDragEndEvent(evt);
            },
        });
        var liObjList = ld(this).find('li');
        //双击选中事件
        liObjList.bind('dblclick',function () {
            event.preventDefault();
            //未选中的双击后选中，即包含类drag-handle
            if(this.classList.contains("drag-handle")) {
                var toObj = PopupJqObj.find('#homeboard_draw .ld_homeboard_draw_layout_block').last().get(0);
                var cloneObj = this;
                var itemObj = this.cloneNode(true);
                var fromObj = this.parentNode;
                //目标DOM对象末尾追加li标签以供定位
                toObj.append(itemObj);
                var SorTableEvent = {
                    to : toObj,
                    clone : cloneObj,
                    item : itemObj,
                    from : fromObj,
                };
                that.StuffLiDragEndEvent(SorTableEvent);
            }
            else{
                var stuffid = ld(this).data('stuffid');
                var stuffObj = PopupJqObj.find('#homeboard_draw #stuff_'+stuffid);
                stuffObj.length > 0 ? stuffObj.find('.ld_homeboard_draw_block_stuff_close').trigger('click') : null ;
            }
        });

        liObjList.find('.tip-items-list').bind('mousedown',function (){
            if(event.detail > 1){
                event.preventDefault();
            }
        });
    });

    /** 组件Li标签拖动结束事件
     * @param SorTableEvent SorTable拖动事件Event对象
     */
    that.StuffLiDragEndEvent = function (SorTableEvent){
        if(SorTableEvent.to.tagName != 'UL') {
            //移除了drag-handle类名，即选中不可拖动
            SorTableEvent.clone.className = 'ld_listchosestuff';
            ld(SorTableEvent.clone).find('.tag').css('display','block');

            var liobj = ld(SorTableEvent.item);
            var liObjId = liobj.attr('id');

            var stuffid = liobj.data('stuffid');
            var stuffstyle = liobj.data('stuffstyle');
            var plateid = ld(SorTableEvent.to).data('plateid');//区块ID
            //zxm 20230512 XUQIU1001246	统计表	报表分析->SQL统计图：增加设置，允许添加到首页组件中显示
            var chart_type = liobj.data('chart_type');
            var stufftitle = liobj.data('stufftitle');
            var stuffliststyle = liobj.data('stuffliststyle');
            var stufftitle_label = liobj.data('stufftitle_label');
            //zhouxm 20230614 拖动一个组件过来  增加数据范围信息数据到设置数组中
            if(empty(popupobj.DatarangeSetList['plate_'+plateid])){
                popupobj.DatarangeSetList['plate_'+plateid] = {};//处理区块没有定义的情况
            }
            var curstuffkey = stuffliststyle=='defaultstuff'?'defaultstuff_'+stuffid:stuffid;
            popupobj.DatarangeSetList['plate_'+plateid][curstuffkey] = popupobj.DatarangeSetListDefault[curstuffkey];

            var default_height = '386px';
            //XUQIU20240613-05 移动端工作台定制--增加组件高度设置，可以自由设置组件高度  移动端组件高度默认给400

            if(popupobj.boardtype=='MobileReport'||popupobj.boardtype=='prmMobileHome'){
                //多加50是标题和上下编剧,小光前端返回减去这个50 ,但是PC端设置需要将这个值加进去
                default_height = '350px';//默认组件 默认高度 300
                if(stuffid==112)default_height = '550px';//销售阶段转化分析 原来的高度500
                if(stuffid==19)default_height = '290px';//销售漏斗 原来的图高度240
                if(stuffid==115)default_height = '450px';//天地特殊开发的销售漏斗 原来的图高度400
                if(stuffliststyle == 'customreport')default_height = '400px';//自定义统计图  默认给400高度  图的高度350
            }

            var draw_block_stuffhtml = that.get_draw_block_stuffhtml(stuffid,stuffstyle,stufftitle,stuffliststyle,stufftitle_label,default_height,'','',0);

            ld(SorTableEvent.to).find('.empty-block-tip').remove();//把空态删除

            //edit: xll 用于定位的li标签
            var DragObj = ld(SorTableEvent.to).find('.drag-handle');
            DragObj.after(draw_block_stuffhtml);
            DragObj.next().get(0).scrollIntoView({ behavior: "smooth" , block : "center"});

            //zxm 20231021 常用模块组件永远在最上面
            if(PopupJqObj.find('#stuff_108').length>0){
                PopupJqObj.find('[name=homeboard_draw_layout_block]').prepend(PopupJqObj.find('#stuff_108'));
                PopupJqObj.find('#stuff_108').after(PopupJqObj.find('.home_header_top'));
            }

            that.loadWidgets(stuffid,stuffstyle,stufftitle,stuffliststyle,chart_type);
            DragObj.remove();
            if(PopupJqObj.find('#step2 .ld_homeboard_draw_layout_block #stuff_'+stuffid).length > 0){
                that.bindMoveAfter();
                PopupJqObj.find('#step2 .ld_homeboard_draw_layout_block #stuff_'+stuffid).click();
            }

            tooltip('#'+popupobj.divid+' #'+liObjId+' .tip-items-list', {transition: true, time: 200});
        }
    }

    /** 拖动悬浮时，隐藏空态提示
     * @param {HTMLElement} BlockObj 区块DOM对象
     */
    that.BindDragEmtyEvent = function (BlockObj){
        ld(BlockObj).unbind('drop').bind('drop',function () {
            ld(this).removeClass('DragOver');
        });
        ld(BlockObj).unbind('dragenter').bind('dragenter',function () {
            ld(this).addClass('DragOver');
        });
        ld(BlockObj).unbind('dragleave').bind('dragleave',function () {
            //通过计时器间歇判断区块中是否还有li标签，进而判断是否隐藏空态提示
            that.DragEmptyLeave(this);
        });
    }

    that.DragEmptyLeave = function (LeaveEle) {
        var LeaveEleJqObj = ld(LeaveEle)
        var plateid = LeaveEleJqObj.data('plateid');
        if(that.EmptyLeaveTimer[plateid] !== undefined && that.EmptyLeaveTimer[plateid] !== null)
            clearTimeout(that.EmptyLeaveTimer[plateid]);
        that.EmptyLeaveTimer[plateid] = null;
        var isDragObjInEle = (ld(LeaveEle).find('li.drag-handle').length > 0);
        if(!isDragObjInEle) {
            ld(LeaveEle).removeClass('DragOver');
        }
        else {
            that.EmptyLeaveTimer[plateid] = setTimeout(function () {
                that.DragEmptyLeave(LeaveEle);
            },400);
        }
    }

    //绑定拖动
    ld.each(step2Obj.find(" #homeboard_drawingboard [name='homeboard_draw_layout_block']"),function(index,obj){
        var BlockObj = this;
        Sortable.create(BlockObj, {
            group: 'stuff',
            sort:true,
            filter:'.empty-block-tip',
            onEnd: function (evt){
                //zxm 20230512 XUQIU1001246 组件拖动区块之后 需要将设置信息更换
                var plateid = ld(evt.to).data('plateid');//区块ID
                var curdiv_obj = ld(evt.item);
                var stuffid = curdiv_obj.data('stuffid');

                var pre_plateid = ld(evt.from).data('plateid');//区块ID
                var pre_plate_obj = ld(evt.from);
                var stuffliststyle = curdiv_obj.data('stuffliststyle');
                //将组件信息放到看板数组中
                var curstuffkey = stuffliststyle=='defaultstuff'?'defaultstuff_'+stuffid:stuffid;
                if(empty(popupobj.DatarangeSetList['plate_'+plateid])){
                    popupobj.DatarangeSetList['plate_'+plateid] = {};//处理区块没有定义的情况
                }

                ld(evt.to).find('.empty-block-tip').remove();//把空态删除
                //zxm 20231021 常用模块组件永远在最上面  时间筛选器在常用模块后面
                if(PopupJqObj.find('#stuff_108').length>0) {
                    PopupJqObj.find('[name=homeboard_draw_layout_block]').prepend(PopupJqObj.find('#stuff_108'));
                    PopupJqObj.find('.home_header_top').css('margin-left','8px').css('margin-right','8px');
                    PopupJqObj.find('#stuff_108').after(PopupJqObj.find('.home_header_top'));
                }
                //zxm 20230728 同一个plate区块中拖动不需要增减设置数组
                if(plateid!=pre_plateid&&!empty(popupobj.DatarangeSetList['plate_'+pre_plateid])&&!empty(popupobj.DatarangeSetList['plate_'+pre_plateid][curstuffkey])){
                    popupobj.DatarangeSetList['plate_'+plateid][curstuffkey] = popupobj.DatarangeSetList['plate_'+pre_plateid][curstuffkey];
                    //删除一个组件
                    delete  popupobj.DatarangeSetList['plate_'+pre_plateid][curstuffkey];
                }
                //区块中的组件被删完了  重新出现空态提示
                if(empty(popupobj.DatarangeSetList['plate_'+pre_plateid])){
                    pre_plate_obj.append('<div class="empty-block-tip" style="height: 100%;margin-top:40px;margin-bottom:40px;text-align: center;">+'+arrJsPopLabel['dragstuff']+'</div>');
                }
                ld(evt.item).click();
            },
        });
        that.BindDragEmtyEvent(BlockObj);
    });

    //列表展开收起
    step2Obj.find(" #homeboard_stuff_list [name^=stufflist_title_]").unbind('click').bind('click',function (){
        var div_list_name = ld(this).attr('name');
        if(ld(this).find('.icon-develop_active').length > 0){
            ld(this).find('.icon-develop_active').removeClass('icon-develop_active');
            step2Obj.find(" #homeboard_stuff_list [name=content_"+div_list_name+"]").css('height','0px');
        }else{
            ld(this).find('.icon-develop').addClass('icon-develop_active');
            var scollheight = step2Obj.find(" #homeboard_stuff_list [name=content_"+div_list_name+"]").get(0).scrollHeight;
            step2Obj.find(" #homeboard_stuff_list [name=content_"+div_list_name+"]").css('height',scollheight+'px');
        }
    });

}
Homeboard.funname = 'Homeboard';

Homeboard.getInstance = function (popupObj) {
    if(!popupObj) {
        popupObj = CrmPopup.getPopupObj('last');
    }
    if(popupObj && popupObj.divid) {
        return popupObj.HomeBoardInstance ? popupObj.HomeBoardInstance : (popupObj.HomeBoardInstance = new Homeboard())
    }
    return new Homeboard();
}


