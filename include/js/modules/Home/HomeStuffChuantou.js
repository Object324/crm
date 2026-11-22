function HomeStuffChuantou (){
    var that=this;
    /** 请求中的不可变参数，放于请求体中避免参数数据过大*/
    this.params_data = '';
    this.surl = 'index.php?module=Home&action=HomeAjax&file=GetPenetrateModuleList&function_name=getListView';
    /** 穿透到子图的变量列表对象*/
    this.ChildChartParam = {};
    //获取首页查询条件公共的条件 boardid scopeType selectuserid search_date_custom_value approve_value
    this.initParam = function(){
        that.scopeType = empty(ld('#HomeSmOwnerSearchScope'))?'SmOwner_Search_All':ld('#HomeSmOwnerSearchScope').val();	//查看范围类型
        that.selectuserid = empty(ld('#selectuserid'))?'all':ld('#selectuserid').val();	//查看范围用户ID
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
        that.search_date_custom_value = typeof search_date=='undefined'?'thismonth':search_date; //自定义查询

        var approvestatus = [];
        if(typeof global_home_approve !== "undefined"){
            approvestatus = global_home_approve;
        }else{
            ld('input[name="approve_header_select_value[]"]:checked').each(function(){
                approvestatus.push(this.value);
            });
        }

        if(approvestatus.length == 5 || approvestatus.length == 0){
            that.approve_value = 'all';
        }else{
            that.approve_value = approvestatus.join(',');
        }
        that.boardid = 0;
        if(ld('#boardid')!= undefined&&ld('#boardid').val()!=undefined){
            that.boardid = ld('#boardid').val();
        }

        //edit: xll 2024/08/09 BUG20240730-30 穿透时间默认值问题
        var popupobj = CrmPopup.getPopupObj("last");
        
        if(popupobj != undefined && popupobj.divid != '' && popupobj.Homeboard_content && popupobj.Homeboard_content != ''){
            var Homeboard_content = popupobj.Homeboard_content;
            search_date = Homeboard_content.timesearchdefault;
            that.approve_value=Homeboard_content.approve_value;
            that.search_date_custom_value = search_date;
            (search_date === "custom") && (that.search_date_custom_value = Homeboard_content.customDateValue.split(' - ').join('~'));
        }
        //穿透弹窗不变的参数
        that.unchangeParams = "&boardid="+that.boardid+"&search_date_custom_value="+that.search_date_custom_value+"&approve_value="+that.approve_value;
        //穿透弹窗会改变的参数
        that.changeParams = "&scopeType="+that.scopeType+"&selectuserid="+that.selectuserid;
    }
    //销售简报穿透 首页的参数 公共的 格式是'键=值&键=值&'  看板id,查看范围类型 查看范围userid,日期,审批状态
    this.setSalesKitChuantou = function(stufflabel,stuffid,jqueryobj){
        that.initParam();
        that.fromHome='yes';//wym 231220 BUG0077444 首页穿透要全屏，报表穿透不全屏，所以要用这个参数区分出首页和报表
        if(stufflabel.match(/NEW_/i)){
            //新建简报不给穿透
            return false;
            //RemindsMsg("","LdPopWidth400px","","yes","yes",'新建简报未保存不允许穿透');
        }
        var unchangeParams = that.unchangeParams;
        var changeParams = that.changeParams;
        var searchtype=ld(jqueryobj).attr("searchtype");
        var boardstuffid = ld('#stuff_'+stuffid).data('boardstuffid');
        unchangeParams += "&stufftype=defaultstuff"
        unchangeParams += "&boardstuffid="+boardstuffid;
        unchangeParams += '&stuffid='+stuffid+'&stufflabel='+stufflabel+'&searchtype='+searchtype;
        //edit: xll 2024/02/21 BUG20240130-53 首页--销售排行榜--穿透时没有传负责人条件
        //edit: xll 2024/03/05 BUG20240305-19 简报上期穿透不对
        var smownerParams = '';
        if(parseInt(stuffid) === 33) {
            changeParams = '';
            smownerParams = that.changeParams.split('&').map(v => {
                let keyArr = v.split('=');
                if(keyArr[0] === 'scopeType') {
                    keyArr[1] = 'smowner_search_senior';
                }
                else if(keyArr[0] === 'selectuserid') {
                    keyArr[1] = ld(jqueryobj).attr('uid');
                }
                else {
                    if(keyArr[0].length > 0)
                        changeParams += '&' + keyArr.join('=');
                }
                return keyArr.join('=');
            }).join('&');
            that.changeParams = changeParams;
        }
        that.params_data = '';
        that.params_data = unchangeParams + smownerParams;
        that.popupchuantou(that.surl,changeParams,boardstuffid);
    }
    //首页默认组件穿透 比如更多按钮 --除销售简报外的
    this.home_href_popup = function(stuffid,boardstuffid,keyvalue,surl,page_addurl){
        that.fromHome='yes';//wym 231220 BUG0077444 首页穿透要全屏，报表穿透不全屏，所以要用这个参数区分出首页和报表
        if(stuffid=='34'||stuffid=='6'){
            //待审批的跳转/交易//统计/应收/应付款汇总
            if(page_addurl != ''){
                page_addurl = '&page_addurl='+encodeURIComponent(page_addurl);
            }
            OpenNewWebTab(surl+page_addurl);
            return;
        }
        if(stuffid=='39'){
            var targetid = ld('#stuff_' + stuffid).find('.ld-NavBarList').children('.cur').data('navbarid');
            if(empty(targetid)){
                targetid = 0;
            }
            page_addurl += '&tabtype='+targetid;
            page_addurl = '&page_addurl='+encodeURIComponent(page_addurl);
            OpenNewWebTab(surl+page_addurl);
            return ;
        }

        that.initParam();
        var unchangeParams = that.unchangeParams;
        var changeParams = that.changeParams;
        unchangeParams += "&stuffid="+stuffid+"&boardstuffid="+boardstuffid+"&stufftype=defaultstuff";
        if(!empty(keyvalue)){
            unchangeParams+="&keyvalue="+keyvalue;
        }
        that.params_data = unchangeParams+changeParams;
        that.popupchuantou(that.surl,changeParams,boardstuffid);
    }

    //自定义统计图穿透 --饼图和漏斗图
    this.customecharts_chuantou = function(report_id,searchKey,seriesIndex){
        that.initParam();
        var unchangeParams = that.unchangeParams;
        var changeParams = that.changeParams;
        unchangeParams += "&stufftype=customreport";
        var boardstuffid=0;
        if(ld('#stuff_charts_'+report_id).data('boardstuffid')>0){
            boardstuffid = ld('#stuff_charts_'+report_id).data('boardstuffid');
        }
        unchangeParams += "&boardstuffid="+boardstuffid;
        unchangeParams += "&searchKey=" + searchKey + "&seriesIndex=" + seriesIndex + "&stuffid=" + report_id;
        that.popupchuantou(that.surl+unchangeParams,changeParams,boardstuffid);
    }
    //自定义统计表 更多按钮的穿透 reporttype sql/selectfield
    this.CustomTablesChuantou_Home = function (report_id,boardstuffid,report_type) {
        that.initParam();
        that.fromHome='yes';
        var unchangeParams = that.unchangeParams+'&boardstuffid='+boardstuffid+"&selectuid="+that.selectuserid;//selectuid 跟homestuff.js中参数是selectuid  参数名称不一致
        var changeParams = that.changeParams;

        //根据reporttype不同 调用两个自定义统计表显示类
        //自定义统计表---首页条件作为隐藏条件 无法去掉
        //SQL统计表 关联的首页条件需要传到弹框--用户可再次更改查询
        if(report_type=='sql'){
            getJsScript('include/js/modules/CustomTables/CustomTablesSqlDetailHome.js',function() {
                CustomTablesSqlDetailHome.showTableDetail(report_id,unchangeParams+changeParams);
            });
        }else{
            getJsScript('include/js/modules/CustomTables/CustomTablesDetailHome.js',function() {
                CustomTablesDetailHome.showTableDetail(report_id,unchangeParams+changeParams);
            });
        }
    }
    //zxm @date:2024/12/19 @reason: 自定义统计图放首页 增加更多按钮 点击之后弹出统计图详情 带首页条件
    this.CustomEchartsMoreChuantou_Home = function(report_id,boardstuffid,report_type){
        that.initParam();
        that.fromHome='yes';
        var unchangeParams = that.unchangeParams+'&boardstuffid='+boardstuffid+"&selectuid="+that.selectuserid;//selectuid 跟homestuff.js中参数是selectuid  参数名称不一致
        var changeParams = that.changeParams;
        getJsScript('include/js/modules/ReportAnalysis/ReportAnalysis.js',function() {
            var ReportAnalysisObj = new ReportAnalysis();
            ReportAnalysisObj.init();
            ReportAnalysisObj.showEchartDetail(report_id,report_type);
        });

    }
    //报表分析模块-自定义统计图的穿透
    this.CustomEchartsChuantou_Home = function (url,params_data,options) {
        that.surl = url;
        that.changeParams = '';
        that.unchangeParams = '';
        that.initParam();
        that.ClassName = 'CustomEchartsChuantou';
        that.params_data = params_data + '&ClassName='+that.ClassName;
        var unchangeParams = that.unchangeParams;
        var changeParams = that.changeParams;
        var boardstuffid=0;
        if(ld('#stuff_charts_'+options.report_id).data('boardstuffid')>0){
            boardstuffid = ld('#stuff_charts_'+options.report_id).data('boardstuffid');
        }
        unchangeParams += "&boardstuffid="+boardstuffid+"&stuffid=" +options.report_id+"&stufftype=customreport";
        that.popupchuantou(url + unchangeParams,changeParams,boardstuffid);
    }

    //报表分析模块-自定义统计图的穿透
    this.CustomEchartsChuantou_Report = function (url,params_data) {
        that.surl = url;
        that.ClassName = 'CustomEchartsChuantou_Report';
        that.params_data = params_data + '&ClassName='+that.ClassName;
        that.scopeType = 'SmOwner_Search_All';
        that.selectuserid = '';
        that.search_date_custom_value = '';
        that.approve_value = '';
        that.boardid = 0;
        var unchangeParams = '';
        var changeParams = '&scopeType='+that.scopeType;
        that.popupchuantou(url + unchangeParams,changeParams,0);
    }

    //SalesPhaseTransformationAnalysis 穿透
    this.SalesPhaseTransformationAnalysisChuantou = function(stuffid,params_data){
        that.initParam();
        var unchangeParams = that.unchangeParams;
        var changeParams = that.changeParams;
        var boardstuffid=0;

        if(ld('#stuff_charts_'+stuffid).data('boardstuffid')>0){
            boardstuffid = ld('#stuff_charts_'+stuffid).data('boardstuffid');
        }
        var boardselect_stage_value = ld('#boardselect_stage_value').val();
        boardselect_stage_value = boardselect_stage_value==undefined?'':boardselect_stage_value;
        unchangeParams += "&stuffid="+stuffid+"&boardstuffid="+boardstuffid+"&stufftype=defaultstuff";
        unchangeParams += '&boardselect_stage_value=' + boardselect_stage_value;
        unchangeParams += params_data ;
        that.popupchuantou(that.surl+unchangeParams,changeParams,boardstuffid);
    }
    //首页默认统计图穿透--非漏斗图
    this.HomeChartChuantou = function(stuffid,params_data){
        that.initParam();
        that.fromHome='yes';//wym 231220 BUG0077444 首页穿透要全屏，报表穿透不全屏，所以要用这个参数区分出首页和报表
        var unchangeParams = that.unchangeParams;
        var changeParams = that.changeParams;
        var boardstuffid=0;
        boardstuffid = ld('#stuff_'+stuffid).data('boardstuffid');
        unchangeParams += "&stuffid="+stuffid+"&boardstuffid="+boardstuffid+"&stufftype=defaultstuff";
        unchangeParams += params_data ;
        that.popupchuantou(that.surl+unchangeParams,changeParams,boardstuffid);
    }

    /**
     * @param surl //请求地址 不带参数的
     * @param changeParams url中的可变动参数
     * @param boardstuffid
     */
    this.popupchuantou = function (surl,changeParams,boardstuffid){
        //初始化点开的时候将页码置为1  BUG0070770 zxm kfbcrm，首页“数据简报”，点击数据进入模块 穿透，点击下一页，关闭，点击另一个数据进入同一个模块的数据穿透窗口，分页显示的页数与刚刚关闭的窗口页数相同
        changeParams += '&start=1';
        var url = surl+changeParams;
        //wym XUQIU1001820 拖动列表保存，需要传值popuptype
        url += '&popup_type=chuantou_customview';
        // wym BUG0072025 kfbcrm-首页-数据简报 快速点击会产生多个弹窗
        var Popupobj=CrmPopup.load("","","",'','',"","none","","");
        that.penetratePopupObj = Popupobj;
        Popupobj.isShowFullscreen='yes';
        Popupobj.Fullscreencallback = that.FullscreenCallback;
        Popupobj.pagetype='homestuffchuantou';
        //wym 231220 BUG0077444 首页穿透要全屏，报表穿透不全屏，所以要用这个参数区分出首页和报表
        if(that.fromHome != undefined && that.fromHome=='yes'){
            Popupobj.homestuffchuantou='yes';
        }
        Popupobj.prevshow();
        ldAjax(url,that.params_data,function (data){
            if (data.code === 1) {
                var resData = data.result,
                    total_width = resData.total_width;
                Popupobj.setParams(resData.title, '', "", parseInt(total_width)+25, resData.penetrateModule, '', '', "", '');
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, resData.content);
                //默认全屏
                Popupobj.switchFullscreen();
                //首页数据简报滚动条取消外层的
                //edit: xll 2024/03/07 BUG20240305-45 “目标完成率”-目标值，弹出层中没有滚动条，左侧成员显示不完整
                if(resData.penetrateModule === 'SalesGoal') {
                    AjaxJSPage('SalesGoal_js','include/js/modules/SalesGoal/SalesGoal.js');
                }
                else {
                    ld('#'+Popupobj.divid).find('.dvpopupsroll').css('overflow-y','hidden');
                }
                //将首页的时间条件和审批条件传过去
                getJsScript('include/js/modules/Home/popup_Chuantou.js', function () {
                    var popup_ChuantouObj = new popup_Chuantou(Popupobj, boardstuffid, resData.penetrateModule, resData.scopemodule);
                    that.popup_ChuantouObj = popup_ChuantouObj;
                    //设置弹框内可以用来放列表数据的table父级的div的高度
                    if (that.type == 'workBriefReport'){
                        popup_ChuantouObj.type = 'workBriefReportChuantou';
                        popup_ChuantouObj.advance_demand = resData.advance_demand;
                        popup_ChuantouObj.advance_demand_groups = resData.advance_demand_groups;
                    }
                    popup_ChuantouObj.setChuanTouTableHeight();
                    popup_ChuantouObj.init(that.scopeType, that.selectuserid, that.search_date_custom_value, that.approve_value);
                    popup_ChuantouObj.currentpage = resData.currentpage;//当前页
                    popup_ChuantouObj.maxpagenum = resData.maxpagenum;//最大页
                    popup_ChuantouObj.boardid = that.boardid;
                    popup_ChuantouObj.surl = surl;
                    popup_ChuantouObj.params_data = that.params_data;
                    popup_ChuantouObj.title=resData.title;
                    popup_ChuantouObj.export_data=resData.export_data;//用于导出数据
                    popup_ChuantouObj.setEvent();//设置事件
                    //wym XUQIU1001820 首页穿透添加列表拖动
                    Popupobj.viewid=resData.viewid;
                    Popupobj.pop_type='chuantou_customview';
                    var listresizeobj=new List_ResizeTable(Popupobj);
                    Popupobj.listresizeobj=listresizeobj;
                    listresizeobj.setPopupResizeTable_Init(resData.penetrateModule);

                    // edit: xll 2024/07/22 BUG20240722-11 龙虎榜穿透后查看范围不对，导致切换模块后数据出错
                    if(typeof that.callBack === "function") {
                        that.callBack();
                    }
                });
            }
        })
    }
    /** 全屏回调函数 */
    this.FullscreenCallback = function (switchtotype) {
        var Popupobj = that.penetratePopupObj;
        if(Popupobj.listresizeobj != undefined){
            Popupobj.listresizeobj.setPopupResizeTable_Init(Popupobj.module, 'Ajax');
        }
        var windowHeight = CrmPopup.getClientHeight();
        //弹窗标题固定为50px
        var minusheight=50;
        //销售订单/服务合同标签
        if(CrmPopup.isExistsObj(Popupobj.divid,'LayoutBlocklistTable')){
            minusheight+=CrmPopup.findHtmlobj(Popupobj.divid,'LayoutBlocklistTable').height();
        }
        //查询分类/搜索/查找按钮
        if(ld('#'+Popupobj.divid+' #ListViewBtnAndSeach')){
            minusheight+=ld('#'+Popupobj.divid+' #ListViewBtnAndSeach').height();
        }
        var headerheight = CrmPopup.findHtmlobj(Popupobj.divid,'resize_header_table_divid').height();
        //20240315 zxm BUG20240313-69 页签切换的高度也需要考虑进去 
        var ScrolllObj = CrmPopup.findHtmlobj(Popupobj.divid,'hdScrolllistentries_yy');
        var top = ScrolllObj.length > 0 ? ScrolllObj.offset().top : 0;

        CrmPopup.findHtmlobj(Popupobj.divid,'hdScrolllistentries_yy').css('height',windowHeight-top);
        CrmPopup.findHtmlobj(Popupobj.divid,'resize_content_table_divid').css("height",windowHeight-headerheight-top);
        Popupobj.center();
    }
    /** 设置穿透到子图所需的变量列表
     * @param {object} ParamsOption 变量列表对象
     */
    this.setChildChartParam = function (ParamsOption) {
        var newChartObj = that.newChartObj = ParamsOption.newChartObj;
        that.getChildChartOption = newChartObj.getChildChartOption['ChildChart_'+newChartObj.params.stuffid];
    }
    /** 首页组件穿透到子图 */
    this.HomeStuffToChildChart = function (stuffid,params_data) {
        that.surl = 'index.php?module=Home&action=HomeAjax&file=GetPenetrateModuleList&function_name=getChildChart';    //方法名使用 getChildChart
        that.initParam();
        var surl = that.surl + "&boardid="+that.boardid + "&stuffid="+stuffid+"&boardstuffid="+boardstuffid+"&stufftype=defaultstuff"+"&approve_value="+that.approve_value,
            boardstuffid = 0;
        that.changeParams += "&search_date_custom_value="+that.search_date_custom_value;
        boardstuffid = ld('#stuff_'+stuffid).data('boardstuffid');
        that.params_data = params_data; //请求体参数（不变）
        that.ChuantouToChildChart(surl,that.changeParams,boardstuffid);
    }
    /**
     * 穿透到子图
     */
    this.ChuantouToChildChart = function (surl,changeParams,boardstuffid) {
        //初始化点开的时候将页码置为1  BUG0070770 zxm kfbcrm，首页“数据简报”，点击数据进入模块 穿透，点击下一页，关闭，点击另一个数据进入同一个模块的数据穿透窗口，分页显示的页数与刚刚关闭的窗口页数相同
        changeParams += '&start=1';
        var url = surl+changeParams;
        //wym XUQIU1001820 拖动列表保存，需要传值popuptype
        url += '&popup_type=chuantou_customview';
        // wym BUG0072025 kfbcrm-首页-数据简报 快速点击会产生多个弹窗
        var Popupobj=CrmPopup.load("","","",'','',"","none","","");
        that.penetratePopupObj = Popupobj;
        Popupobj.isShowFullscreen='yes';
        Popupobj.Fullscreencallback = function (switchtotype) {
            
        };
        Popupobj.popuppagetype='homestuffchuantou';
        Popupobj.pagetype='homestuffchuantou';
        Popupobj.prevshow();
        ldAjax(url,that.params_data,function (data){
            if (data.code == 1) {
                var total_width = 1000;
                Popupobj.setParams(data.result.title, '', "", parseInt(total_width)+25, data.result.penetrateModule, '', '', "", '');
                CrmPopup.setPopupobjHtmlContent_scroll_jquery(Popupobj, data.result.content);

                //默认全屏
                Popupobj.switchFullscreen();

                that.newChartObj.setChildChartData(data.result.ChildChartData);

                getJsScript('include/js/modules/Home/popup_Chuantou.js', function () {
                    var PopupChuantouObj = new popup_Chuantou(Popupobj, boardstuffid, data.result.penetrateModule, data.result.scopemodule);
                    PopupChuantouObj.ChildChartInit({
                        surl : surl,
                        params_data : that.params_data,
                        getChildChartOption : that.getChildChartOption,
                        newChartObj : that.newChartObj,
                        scopeType : that.scopeType,
                        selectuserid : that.selectuserid,
                        search_date_custom_value : that.search_date_custom_value,
                    });
                    PopupChuantouObj.ChildChartSetEvent();
                    PopupChuantouObj.setChildChart();
                });
            }
        })
    }

    /**
     * 设置穿透后的回调函数，用于处理特殊组件（如龙虎榜指定查看范围）
     * @param {function()} fun 需要执行的回调函数
     */
    this.setCallBack = function (fun) {
        that.callBack = fun;
    }
}