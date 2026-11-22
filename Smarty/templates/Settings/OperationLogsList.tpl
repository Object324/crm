<!--修改编码格式:统一编码：UTF-8-->
<div class="ld-operationlog-list" id="ld-operationlog-list">
        {* <div>{$hyperlinks}</div> *}
    <div class="ld-operationlog-list-header" name="operationlogs_header">
        <table class="settingTable fir-center ld-operationlog-list-table" width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                {foreach key=index item=value from=$TableHeader}
                    <th class="tip-items-list" data-tip="{$value}" data-direction="top" data-type="position" style="{$HeaderWidth[$index]}">{$value}</th>
                {/foreach}
            </tr>
        </table> 
    </div>
    <div class="ld-operationlog-list-content main_grid_box" name="operationlogs_content" style="overflow: hidden auto;">
        <div class="grid-analysis-box">
            <div class="grid-analysis-header">
            </div>
            <div class="cont_wrap clear_float" id="ld-operationlog-list-table">
                {include file='Settings/OperationLogsListTable.tpl'}
            </div>
        </div>
    </div>
</div>
<div name="listviewpagination" id="listviewpagination" style="display: flex;align-items: center;height: 50px;position: fixed;bottom: 0px;right: 20px;">
</div>

<style>
    .ld-operationlog-list-table{
        table-layout: fixed;
    }
    .ld-operationlog-list-table tr th{
        padding: 0px 15px;
    }
    .ld-operationlog-list-table tr td{
        padding: 0px 15px;
        white-space: initial;
        word-wrap: break-word;
    }
</style>

<script>
    ld(document).ready(function() {
        //var widthbox = ld('#ld-operationlog-list').width();
        //ld('div[name=operationlogs_header] table').css('width', widthbox);
        //ld('div[name=operationlogs_content] table').css('width', widthbox);

        var topheight=55;//快速查找所在div的高度55
        var con_mt_height=8;//头部和内容中间margin距离10
        var uitabsheight=50;//导航高度
        var main_grid_top=60;//main_grid_top高度
        var NavBarHeight = ld('div.D_Tab_div').length > 0?ld('div.D_Tab_div').height()+5:0;// 页签高度

        ld('[name=operationlogs_content]').css('height', parseInt(ld(window).height()) - parseInt(topheight) - parseInt(con_mt_height) - parseInt(main_grid_top) - ld('#setLogsConditions').height() - NavBarHeight - 100 +'px');
        
    });
    CrmPopup.global_listPopupObj=[];
    var popupobj=new Object();
    popupobj.divid="SettingRightContent";
    CrmPopup.global_listPopupObj.push(popupobj);
    popupobj.CancelEvent=function(){
        return false;
    }
    {literal}
        tooltip('.tip-items-list', {transition: true, time: 200});
    {/literal}
    //分页
    var FunctionObj;
    if({$FunctionObj} && {$FunctionObj} != ''){
        var functionobj = {$FunctionObj};
        FunctionObj = new functionobj();
    }else{
        FunctionObj = new OperationLogs();
    }
    var module = '{$MODULE}';
    var tabname = '{$TABNAME}';
    var tmp_pagedata = {
        'currentpage': {$STARTPAGE},
        'count': {$LISTVIEWRECORDCOUNT},
        'pagecount': {$LISTVIEWPAGECOUNT},
        'language': language,
        'changepage': function (pagenum){
            FunctionObj.changePage(pagenum);
        },
        'pagepernumarr': {$LISTVIEWPERPAGENUM},
        'changepagecount': function (evt){
            var pagecount=evt.NavBarItem.value;
            FunctionObj.setMaxEntriesPerPage(pagecount);
        }
    }

    AjaxJSPage('ld_Pagination','include/js/component/ld_Pagination.js');
    var last_crmpopup = CrmPopup.getPopupObj("last");
    var tmp_divid = '';
    if(last_crmpopup.pagetype == 'advance_stage_chuantou'){
        tmp_divid = last_crmpopup.divid;
    }
    else if(last_crmpopup.pagetype == 'detailview_modulepage'){
        var prevpopup = CrmPopup.getPopupObj("lastprev");
        if(prevpopup.pagetype == 'advance_stage_chuantou' || prevpopup.pagetype == ListPagePopup.type) {
            tmp_divid = prevpopup.divid;
        }
    }
    else{
        tmp_divid = popupobj.divid;
    }
    var listviewpagination = ld('#'+tmp_divid+' #listviewpagination');
    var listviewpaginationobj = ld_Pagination.showPagination(listviewpagination.get(0), tmp_pagedata);
    popupobj.listviewpaginationobj = listviewpaginationobj;


    var pagecount = {$LISTVIEWPAGECOUNT};
    if(pagecount>1){
        ld('.ld_listviewchooseall').show();
    }else{
        ld('.ld_listviewchooseall').hide();
    }
    ld('#selectAllRec span#count').html({$LISTVIEWRECORDCOUNT});
</script>