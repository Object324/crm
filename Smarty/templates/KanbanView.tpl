<div class="main_grid lfloat main_grid_list">
    {*wym 240110 BUG20240109-62 销售机会->看板视图列表界面，新增等操作按钮界面显示错误*}
    <div class="main_grid_top">
        <div class="ListViewNavBarAndBtn" id="ListViewNavBarAndBtn">
            {include file='SelectCustomView_Group.tpl'}
            <!--按钮、查看范围-->
            {assign var="buttonsPosition" value='up'}
            {*{include file="ProductListViewButtons.tpl"}*}
            {include file='SearchScope_New.tpl'}

            <div class="listview_toprightbox">
                <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
                    <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
                        <div class="ld-button" tag="" onclick="listviewbutton_click(this,'{$MODULE}','Create',event);return false;">{'CREATE'|@getFixedLabel}</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="ld-flex-between gwidth100 ld-flex-wrap" id="ListViewBtnAndSeach" >
            {*BUG0068916 txy 20230719 kfbcrm-销售机会-看板视图-放大缩小屏幕组件应跟着适应屏幕*}
            <div class="ld-flex-start ld-flex-wrap" style="height:auto;padding: 7px 0;width: 100%">

                <div class="marL15 marR10 ld-flex-start ld-flex-wrap" id="basicSearchNewDiv">
                    {*基本查找组件 zxm 20221212*}
                    {include file='ListViewBasicSearch.tpl'}
                </div>
                <div class="ld-flex-end ld-flex-wrap" style="margin-left: auto;">
                    <div class="list-item listviewsecond" style="padding: 0;display: flex;justify-content: flex-start;">
                        <div class="tip-items-list" data-tip="{'LISTVIEW'|@getFixedLabel}" data-direction="top" data-type="position" onclick="getKanbanView('{$MODULE}','ListView')">
                            <span class=""><i class="list-item-btn list-btn"></i></span>
                        </div>
                        {*gxj 230711 BUG0069245 销售机会的看板视图加上报表按钮*}
                        {if $DashboardPermitt eq 'yes'||$MODULEADVANCESTAGESTATUS eq 'yes'}
                            <div style="position: relative;" class="ld-listview-chartlist tip-items-list" data-tip="{'SocialPromotionReport'|@getFixedLabel}" data-direction="top" data-type="position">{*gxj 230710 BUG0069243 【界面优化】客户和销售机会列表页面的鼠标悬浮后，内容提示由【进度漏斗】修改为【统计报表】*}
                                <span {if $MODULEADVANCESTAGESTATUS eq 'yes'} onclick="AdvanceStageHighcharts('{$MODULE}')"{/if}><i class="list-item-btn funnel-btn"></i></span>
                                {if $DashboardPermitt eq 'yes'}
                                    {include file="ListChart_1020.tpl"}
                                {/if}
                            </div>
                        {/if}
                    </div>
                </div>
            </div>
        </div>
    </div>


        <div class="main_grid_box">
            <div class="grid-analysis-box">
                <input type="hidden" id="iskanbanshow" value="yes">
                <div class="cont_wrap clear_float" id="ListViewContents">
                       {$TMPKANBAN}
                </div>
            </div>
        </div>
</div>


<style>
    .ld-kanban{
        width: 276px;
        margin: 10px;
    }

    .ld-stageItem{
        display: flex;
        margin-right: 12px;
        width: 250px;
        height: 100%;
        min-width: 250px;
        overflow-x: scroll;
        overflow-y: hidden;
    }

    .ld-stagelist{
        margin-top: 12px;
        overflow-y: auto;
        overflow-x: hidden;
        height: 600px;
    }

    .ld-stageInfo{
        margin-top: 12px;
        width: 240px;
        font-size: 12px;
        font-family: PingFangSC-Regular,PingFang SC;
        font-weight: 400;
        color: #292e33;
        line-height: 20px;
        height: 20px;
        overflow: hidden;
        cursor: pointer;
    }

    .ld-potential-item{
        width: 240px;
        background: #fff;
        border-radius: 8px;
        /*margin-bottom: 12px;*/
        position: relative;
    }

    .ld-potential-itemName{
        height: 40px;
        padding: 10px 12px;
        border-bottom: 1px solid #d4d8db;
        font-size: 14px;
        font-weight: 500;
        color: #292e33;
    }

    .ld-potential-itemInfo{
        padding: 12px;
        font-size: 12px;
        font-family: PingFangSC-Regular,PingFang SC;
        font-weight: 400;
        color: #575f66;
        line-height: 24px;
    }

    .ld-kanban-footer{
        display: flex;
        font-size: 14px;
        color: #333;
        line-height: 40px;
        padding: 0 10px;
        height: 40px;
        background-color: #fff;
        border-bottom: 1px solid #f2f2f2;
    }

    .ld-t-FBV{
        flex-direction: column;

    }

    .ld-main{
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
    }

    .ld-potential-itembtns{
        width: 240px;
        height: 48px;
        line-height: 48px;
        border-top: 1px solid #d4d8db;
        position: absolute;
        z-index: 3;
        /*bottom: -48px;*/
        background: #fff;
        border-bottom-left-radius: 8px;
        border-bottom-right-radius: 8px;
        box-shadow: 0 10px 20px 0 rgb(0 131 255 / 10%);
        text-align: center;
    }

    .ld-potential-itembtn{
        font-size: 12px;
        font-family: PingFangSC-Regular,PingFang SC;
        font-weight: 400;
        color: #0083ff;
        text-align: center;
        cursor: pointer;
    }

    .ld-stageName{
        width: 240px;
        height: 48px;
        background: #0083ff;
        border-radius: 8px;
        border: 1px solid rgba(25,31,37,0.12);
        color: #fff;
        text-align: center;
        line-height: 48px;
        font-size: 14px;
    }

    .float-edit{
        display: none;
        z-index: 1;
        position: relative;
    }

    .ld-potential-item:hover + .float-edit,
    .float-edit:hover {
        display: block;
    }

</style>
<script>
    {*  ljj 20240329 XUQIU1001538 项目立项列表增加“看板视图”功能（李鑫华） 记住用户最新一次界面操作 *}
    {*  popupobj.listresizeobj 未定义  代码来源：ListView.tpl *}
    {*  start  *}
    var firstVisit = '{$FIRSTVISIT}';
    //BUG0068295  关联创建打开新页签 获取到的为最后一个CrmPopup为新增界面  应该改为列表界面
    //var popupobj=CrmPopup.getPopupObj('last');
    var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);

    popupobj.listresizeobj=new List_ResizeTable(popupobj);
    setContentHeight(popupobj.module);//计算内容高度
    var linkmodulecustom = '{$LINKMODULECUSTOM}';
    var modulebillduptip='{$MODULEBILLNOTIP}';
    var version_account = '{$VERSION_ACCOUNT}';
    var FieldWidthSetting='{$FieldWidthSetting}';
    var FieldWidthSettingobj;
    var ReleanAccountReason='{"RELEASEACCOUNTTREASON"|@getFixedLabel}';
    var createpopdividendorder='{$CREATEPOPDIVIDENDORDER}';
    var recordid='{$RECORDID}';
    var module = '{$MODULE}';
    var searchtype = '{$SEATCH_INPUT.searchtype}';
    if(searchtype == 'advance'){
        setListButtonColor("categoryAdvsear");
    }
    var haigersavetip='{$HaigeSaveTip}';
    var listeditpageobj=new ListEditPagePopup(popupobj);
    listeditpageobj.setListEditEvent();
    var tree_enable='{$MODULElISTTREE.enable}';
    if(tree_enable == 'yes' || module == 'Users'){
        var structureTreeobj=new structureTree();
        structureTreeobj.setEvent();
        structureTreeobj.treeWidth = '{$MODULElISTTREE.tree_width}';
    }
    //lmq 230614 表格行高设置
    popupobj.TableLineHightSet = '{$TableLineHightSet}';

    if(FieldWidthSetting!='')
    {

        var FieldWidthSettingobj=eval('('+ FieldWidthSetting +')')?eval('('+ FieldWidthSetting +')'):JSON.parse(FieldWidthSetting);

    }
    //设置div宽度
    popupobj.listresizeobj.setReiszeTable_Init(module,'');

    //
    ld('#'+popupobj.divid+' #resize_content_table_divid').scroll(function (){
        if(ld(this).scrollTop() > 0){
            if(ld('#'+popupobj.divid+' #resize_header_table_divid div:first-child').hasClass('ld-setting-tabtop-shadow')){
            }else{
                ld('#'+popupobj.divid+' #resize_header_table_divid div:first-child').addClass('ld-setting-tabtop-shadow');
            }
        }else{
            ld('#'+popupobj.divid+' #resize_header_table_divid div:first-child').removeClass('ld-setting-tabtop-shadow');
        }
    });

    {*  end  *}

    // var popupobj = CrmPopup.getlastPopupObjByType(ListPagePopup.type);
    // popupobj.listresizeobj.setReiszeTable_Init(module,'');

    // 首次进入没有x轴滚动条
    setKanBanListHeight();
    /*ld(window).resize(function () {
        setKanBanListHeight();
    });*/
    function setKanBanListHeight() {
        var browserheight=window.innerHeight;
        var pagetopheight=ld("#pagehead").css('height');
        var main_grid_topheight=0;
        if(ld("#ListViewNavBarAndBtn").length>0){
            main_grid_topheight+=parseFloat(ld("#ListViewNavBarAndBtn").css('height'));
        }
        if(ld("#ListViewBtnAndSeach").length>0){
            main_grid_topheight+=parseFloat(ld("#ListViewBtnAndSeach").css('height'));
        }
        pagetopheight=browserheight-parseFloat(pagetopheight)-main_grid_topheight-50+'px';//10：头部间隔。50看板列头
        ld('.ld-kanban').css('height',pagetopheight);
    }


    function editshow(obj){
        var crmid=ld(obj).attr('record');
        ld("#cube_"+crmid).mouseover(function(){
            ld('#float_edit_'+crmid).show();
        });
    }

    function edithide(obj){
        var crmid=ld(obj).attr('record');
        ld('#float_edit_'+crmid).hide();
    }

    function editdetail(obj, module, setype, record) {
        getJsScript('include/js/DetailButtons.js', function () {
            detailbuttons_click(obj, module, setype, record);
        });
    }

    var isstructuretree=ld("#structuretree");
    if (isstructuretree.length>0){
        // ljj 2023-08-29 XUQIU1001610 树结构设置和成员管理，左侧分类名称增加计数功能
        popupobj.list_TreeWhere = '{$Encrypt_TreeWhere}';
        console.log(popupobj.list_TreeWhere);
        if (typeof structureTreeobj == "undefined" || structureTreeobj == undefined){
            var structureTreeobj=new structureTree();
        }
        structureTreeobj.getModuleTreeCount(popupobj);
    }
</script>


