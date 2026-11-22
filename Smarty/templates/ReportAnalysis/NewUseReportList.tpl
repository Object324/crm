{*报表分析-常用报表页面*}
<link type="text/css" href="themes/softed/coordination.css" rel="stylesheet"/>
<style type="text/css">
    {literal}
    .DivCNotice-list {
        display: block;
        width: auto;
        font-size: 12px;
        color: #666;
        line-height: 20px;
        border-bottom: 1px #fff solid;
        position: relative;
        z-index: 0;
    }
    .main_grid_box {
        overflow-x: auto !important;
    }
    .select2-container {
        z-index: 1 !important;
    }
    {/literal}
</style>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/OftenUseReport/OftenUseReport.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript">
    var rel_fields = '{$REL_FIELDS}';
    var ProductRankingLabel = '{$ProductRankingLabel}';
    if(!empty(ProductRankingLabel)){
        ProductRankingLabel = JSON.parse(ProductRankingLabel);
    }
</script>
<div>
    <div class="main_grid_reportanalysis" id="leftclickcontent">
        {include file="modules/OftenUseReport/LeftClickContent.tpl"}
    </div>
</div>

<!--中间 end-->
<div id="DivPopupReport" class="E_pop_box LdPopWidth650px" style="display:none;">
</div>
<div id="UseReportSet" class="E_pop_box LdPopWidth600px" style="display:none;">
    <div id="columnset_form_div"></div>

</div>
<div id="EditUseReportColum" class="E_pop_box LdPopWidth600px" style="display:none;">
    <div id="Edit_Column_div"></div>
</div>

<script type="text/javascript">
    Header_Top_Load();
    window.onresize = function () {ldelim}
        //zxm 20230228 报表分析--常用报表，重设报表高度
        ld('.main_grid_reportanalysis .main_grid_box').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) +'px');
        if (document.getElementById('div_select_user') != undefined && document.getElementById('div_select_user').style.display != 'none') {ldelim}
            fnDropDownUsers(getObj('search_text'), 'div_select_user', 18);
            BodyClick(getObj('search_text'), 'div_select_user');
            {rdelim}
        {rdelim};

    function change_table(relatedid) {ldelim}
        document.getElementById('change_table_' + relatedid).className = 'Title';
        document.getElementById('change_table_div_' + relatedid).style.display = "block";
        for (i = 1; i <= 6; i++) {ldelim}
            if (i != relatedid) {ldelim}
                if (document.getElementById('change_table_' + i) != undefined) {ldelim}
                    document.getElementById('change_table_' + i).className = 'Title';
                    {rdelim}
                if (document.getElementById('change_table_div_' + i) != undefined) {ldelim}
                    document.getElementById('change_table_div_' + i).style.display = "none";
                    {rdelim}
                {rdelim}
            {rdelim}
        {rdelim};
    function timelistsearch(obj){ldelim}
        var time_value = ld(obj).val();
        ld('.home-header-filter-select .select-box').show();
        ld('#date_list li').each(function() {
            var livalue = ld(this).text();
            if(livalue.indexOf(time_value)==-1){
                ld(this).hide();
            }else{
                ld(this).show();
            }
        });
        {rdelim}
    function Header_Top_Load(){ldelim}
        //隐藏查询下拉选项
        ld('#searchAcc').unbind('click').on('click',function(e){
            ld('.home-header-filter-select .select-box').hide();
        })
        //时间输入框点击
        ld('.home-header-filter-select .header_value').unbind('click').on('click',function(e){
            ld('.home-header-filter-select .select-box').hide();
            e.stopPropagation();
            var id = ld(this).parent().parent().attr('id');
            var data_value =  ld(this).attr('data-value');
            var _display = ld('#'+id+' .home-header-filter-select .select-box').css('display');
            if(_display == 'none'){
                ld('#'+id+' .home-header-filter-select .select-box').show();
            }else{
                ld('#'+id+' .home-header-filter-select .select-box').hide();
            }
            ld('#'+id+' .home-header-filter-select .select-box .select-list li').each(function(){
                if(ld(this).attr('data-value') == data_value){
                    ld(this).addClass("selected");
                }else{
                    ld(this).removeClass();
                }
            })
            if(data_value != 'custom'){
                ld('#'+id+' .home-header-filter-select .select-box .select-list li[tag=custom_set]').hide();
            }
            ld('#'+id+' .home-header-filter-select .select-box .select-list li').on('click',function(){
                var select_data_value =  ld(this).attr('data-value');//thismonth
                var select_li_value = trim(ld(this).html());//本月
                if(select_data_value == 'custom_start' || select_data_value == 'custom_end')return;
                ld('.home-header-filter-select .select-box .select-list li').each(function(){
                    ld(this).removeClass();
                })
                //自定义时间
                if(select_data_value == 'custom' || 'custom_btn' == select_data_value){
                    if(select_data_value == 'custom'){	//选择自定义时间
                        ld('#'+id+' .home-header-filter-select .select-box .select-list li[tag=custom_set]').show();
                        ld('#'+id+' .home-header-filter-select .select-box .select-list li[data-value=custom]').addClass("selected");
                        return false;
                    }else{	//确认
                        var begin_date = ld('#'+id+' .home-header-filter-select .select-box .select-list input[id=begin_date]').val();
                        var end_date = ld('#'+id+' .home-header-filter-select .select-box .select-list input[id=end_date]').val();
                        var custom_label = ld('#'+id+' .home-header-filter-select .select-box .select-list li[data-value=custom]').html();
                        if(empty(end_date) || empty(begin_date)){
                            alert(custom_label+arrJsPopLabel['CANOTEMPTY']);
                            return false;
                        }
                        var date = begin_date +'~'+end_date;
                        select_li_value = custom_label;
                        select_data_value = 'custom';
                        ld('#'+id+' input[name='+id+'input]').val(date);
                    }
                }else{
                    ld('#'+id+' .home-header-filter-select .select-box .select-list li[tag=custom_set]').hide();
                    ld('#'+id+' input[name='+id+'input]').val(select_data_value);
                }
                // 【首页界面，“时间”下拉框修改为带搜索功能的下拉框显示样式（可参考单据新建界面下拉框显示样式）】https://www.tapd.cn/63637123/prong/stories/view/1163637123001000023
                ld('#'+id+' input[name='+id+'text]').val(select_li_value);
                ld('#'+id+' .home-header-filter-select .header_value').attr('data-value',select_data_value);
                ld('#'+id+' .home-header-filter-select .select-box').hide();
            })
        })
        {rdelim}
</script>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css"/>
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<script type="text/javascript">

    var tolabel = "{'TO'|@getFixedLabel}";
    var reportname = "{$USEREPORTSNAME}";
    var worktype = "{$WORKTYPE}";
    var tmpstr = '{$DATETIMESTR}';

    var datetimestr = eval('(' + tmpstr + ')') ? eval('(' + tmpstr + ')') : JSON.parse(tmpstr);
    if (reportname == 'USERTRACKREPORT') {ldelim}
        var map_obj = new Lingdang_Map('lingdang_map');
        var pointjson = '{$REPORTFILTERHTMLTRACK}';

        if (pointjson != '' && pointjson != null && pointjson != undefined && pointjson != 'null' && pointjson.length > 0) {ldelim}
            // map_obj.show_map('{$MAP_CENTER_LNG}', '{$MAP_CENTER_LAT}');
            //var pointobj = eval('(' + pointjson + ')') ? eval('(' + pointjson + ')') : JSON.parse(pointjson);
            //map_obj.setTrackReport(pointobj);
            {rdelim}

        {rdelim}
    if (reportname == 'SIGNINSTATISTICS' && worktype != '') {ldelim}

        var work_startdate = "{$WORKSTARTDATE}";
        var work_enddate = "{$WORKENDDATE}";
        var work_userid = "{$WORKUSERID}";
        if (worktype == 'worktype_2') {ldelim}
            changedaytime('', 'week', work_startdate, work_enddate);
            {rdelim} else if (worktype == 'worktype_3') {ldelim}
            changedaytime('', 'month', work_startdate, work_enddate);
            {rdelim} else {ldelim}
            changedaytime('', 'today', work_startdate, work_enddate);
            {rdelim}
        cmb_liclick(work_userid, 'SmOwnerSearchScope', 'dv_cmb_SmOwnerSearchScope');
        callOftenUseReportSearch(this, 'BasicSearch');
        {rdelim}
    if (reportname == 'Sign_in_track') {ldelim}
        create_signin_track_map();//签到轨迹表生成地图
        ld('#week[name=OftenUseReport_search]').click();
        {rdelim}else if(reportname == 'SignDistribution'){ldelim}
        create_signin_distribution_map();//签到轨迹表生成地图
        ld('#week[name=OftenUseReport_search]').click();
        {rdelim}

    var Listpagepopupobj=new CrmPopup();
    Listpagepopupobj.type=ListPagePopup.type;
    Listpagepopupobj.module='{$MODULE}';
    CrmPopup.global_listPopupObj.push(Listpagepopupobj);
    {literal}

    Listpagepopupobj.divid = "searchAcc";
    if (reportname == 'InventoryQuery' || reportname == 'InventoryLedger' || reportname == 'InventoryAccount') {
        var cls_resetComboxHtmlobj = new cls_resetComboxHtml('basicotherfind3');
        cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(90);
    }
    ld(document).ready(function () {
        ld('#startmonth').daterangepicker(null, function (start, end, label) {

        });

        setReportTime(ld('#startmonth').val());
    });

    /**
     * 控件回传函数，选择事件后点击选择，执行该回传事件
     * @reason 0012444 常用报表中，点击日期控件后，希望在报表名称后面增加显示日期的事件。
     * @author Tujt 2014-11-12
     */
    function daterangeBackEvent(idstr) {
        setReportTime(ld('#' + idstr).val());
    }

    function setReportTime(datetime) {
        if (datetime == undefined) {
            return;
        }
        var dt = datetime.split(' ');
        var dtv = "( " + dt[0] + ' ' + tolabel + ' ' + dt[2] + " )";
        ld('#report_time_titme').html(dtv);
    }

    function setListButtonColor(liid) {
        // ld("#" + liid).parent().find("div").css("background-color", "");

        ld("#" + liid).parent().find('li[tag=firstnode]').each(function () {
            if (!empty(ld(this).attr('id'))) {
                ld("#" + ld(this).attr('id')).find("b").css({'background-position': ''});
                ld("#" + ld(this).attr('id')).find("a").css("color", "");
            }
        });


        setTimeout(function () {
            ld('#dv_listbasiscsearch ').find('.txtBox').focus()
        }, 100)
    }

    function hidedv_listhighersearch() {
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.CancelEvent();
    }

    function UseReportMenuClick(action,reportname,reportid)
    {
        ld.ajax({
            url:"index.php?module=OftenUseReport&action=OftenUseReportAjax&file="+action+"&report_name="+reportname+"&UseReport="+reportid+"&leftmenuclick=yes",
            type:"post",
            timeout:20000,
            success:function(data)
            {
                document.getElementById('status').style.display="none";
                var results=data.split("###SUCCESS###");
                ld("#leftclickcontent").html(results[1]);
                if(ld('#startmonth') != undefined){
                    ld('#startmonth').daterangepicker(null, function(start, end, label) {});
                }
                var stateObject = {};
                var page_addurl=encodeURIComponent("&report_name="+reportname+"&refreshUseReport="+reportid+"&refreshleftmenuclick=yes");
                var newUrl="index.php?pageto_module=OftenUseReport&pageto_action="+action+"&page_addurl="+page_addurl;
                history.pushState(stateObject,"",newUrl);
                EmptyProgressObjs();
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                {
                    //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
                }
                //zxm 2021-1105 销售机会预测表 时间下拉框重新渲染
                if(reportname=="Salesforecastandanalysistable"||reportname=="VideoRentalIncomeStatement"){
                    Header_Top_Load();
                }
                if(reportname=="Sign_in_track"){
                    create_signin_track_map();
                    ld('#week[name=OftenUseReport_search]').click();
                }else if(reportname=="SignDistribution"){
                    create_signin_distribution_map();
                    ld('#week[name=OftenUseReport_search]').click();
                }
            }
        })
    }
    ld(function(){
        //加载内容中点击事件
        initContentLeftMenuClick();
    });



    //0044733: （61mis.com/kfbcrm）常用报表-产品销售排行榜；报表中的“ 产品签约数量”和“签约_产品名称”会根据排行维度的选项变化，但高级查找中的字段是固定的，导致查找功能异常
    function product_ranking_type_change(obj){
        var ranking_type = ld(obj).val();
        var option_name = ld('[value="ld_products:productname:productname:Products_签约_产品名称:V"]');
        var option_total = ld('[value="ld_products:product_count:product_count:Products_产品签约数量:V"]');
        //0045155常用报表->产品销售排行榜，切换排行维度后，“只统计审批通过的合同订单和服务合同”查询条件中的模块名称没有根据排行维度中的模块名称改变
        switch (ranking_type){
            case 'productSignCount':
                option_total.text("产品签约数量");
                option_name.text("签约_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.qianyue);
                break;
            case 'productSignAmount':
                option_total.text("产品签约金额");
                option_name.text("签约_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.qianyue);
                break;
            case 'productOrderCount':
                option_total.text("产品订单数量");
                option_name.text("订单_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.order);
                break;
            case 'productOrderAmount':
                option_total.text("产品订单金额");
                option_name.text("订单_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.order);
                break;
            case 'productInvoiceAmount':
                option_total.text("产品开票金额");
                option_name.text("开票_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.invoice);
                break;
            case 'productOutboundCount':
                option_total.text("产品出库数量");
                option_name.text("出库_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.outbound);
                break;
            case 'productOutboundAmount':
                option_total.text("产品出库金额");
                option_name.text("出库_产品名称");
                ld('#onlyshowapprovecontactandservice').next().empty().text(ProductRankingLabel.outbound);
                break;
        }
    }
    {/literal}

</script>
