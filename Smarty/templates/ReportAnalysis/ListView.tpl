<!--修改编码格式:统一编码：UTF-8-->
{*报表分析列表页面*}
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link type="text/css" rel="stylesheet" href="themes/softed/CustomTable.css?v={$GLOBALMINVERSION}">
<style>
    .ld-table-container table.fir-center tr th:first-child, .ld-table-container table.fir-center tr td:first-child {
        width: 320px !important;
        text-align: left !important;
    }
</style>
<script type="text/javascript">
    var frommobile = 'no';
    //'Create','EditView','Delete','Allocate','Print','Export'
    var permit_info = {$permit_info};
    var reportanalysis_listtype = '{$listtype}';
</script>
<script type="text/javascript" src="{$JSURL}include/js/modules/ReportAnalysis/ReportAnalysisList.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/ReportAnalysis/ReportAnalysisScreen.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/ScopePopup/ScopePopup_Details.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="include/js/modules/CustomTables/CustomTablesResize.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="include/js/freezecolumns.js?v={$GLOBALMINVERSION}"></script>
<!--中间-->
<div id="reportanalysis_list" class="main_grid lfloat customtable" style="width: 100%;display:none;">
    <input type="hidden" id="LastReviewRecord" value={$LastReviewRecord}>
    {*头部按钮以及搜索框*}
    <div class="main_grid_top padR10 padL10">
        <div class="ld-flex-between padTB10">
            <div class="create-entity-toolbar  search-bar marR12 ld-flex-start">
                <div class="lfloat prelative">
                    <input class="lfloat borderFocus" type="text" id="ld_reportanalysis_search_list" name="keyWords" onkeyup="ReportAnalysisObj.searchSubmit(event);" onkeydown="ReportAnalysisObj.viewClearText()" placeholder="{'SEARCHNEW'|@getFixedLabel}{'ReportName'|@getFixedLabel}"/>
                    <b style="position: absolute;right:35px;top:1px;display: none" class="ld-icon-clearsearch" onclick="ReportAnalysisObj.clearText()"></b>
                    <div class="positionFirst" title="{'SEARCHNEW'|@getFixedLabel}" onclick="ReportAnalysisObj.getSearchList()">
                        <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                    </div>
                </div>
                <div class="ld-flex-start reportanalysis-listtype-btns" style="margin-left:6px;">
                    <div class="reportanalysis-listtype-btn listtype-list-active ld-button textFloatDisplay" tag="list" data-tip="{'LISTVIEW'|@getFixedLabel}" data-direction="top" data-type="position">
                    </div>
                    <div class="reportanalysis-listtype-btn listtype-screen-inactive ld-button textFloatDisplay" style="margin-left:0 !important;" tag="screen" data-tip="{'SCREENVIEW'|@getFixedLabel}" data-direction="top" data-type="position">
                    </div>
                </div>
            </div>
            <div class="create-entity-toolbar lfloat prelative E_pop_tit_Second_Right">
                {if $permit_info_arr['permit_Create']!='no'}
                    <a title="{'CREATE'|@getFixedLabel}" class="ld-button creat-new-table ld-button-primary">
                        <span>{'CREATE'|@getFixedLabel}</span>
                        <b class="ld-button-arrow-down"></b>
                        <b name="Create" class="ListView_ButtonNum"></b>
                    </a>
                    <ol class="D_more_menua report-type-select" style="display:none;">
                        <li onclick="ReportAnalysisObj.createNewDir(0,0,this)">
                            <a title="{'MAILFOLDER'|@getFixedLabel}" style="margin:0;">{'MAILFOLDER'|@getFixedLabel}</a>
                        </li>
                        <li onclick="ReportAnalysisObj.createTemplateReport(0)">
                            <a title="{'TEMPLATE'|@getFixedLabel}{'Table'|@getFixedLabel}" style="margin:0;">{'TEMPLATE'|@getFixedLabel}{'Table'|@getFixedLabel}</a>
                        </li>
                        <li onclick="ReportAnalysisObj.creat_new_table(this,'selectfield')">
                            <a title="{'MODULE'|@getFixedLabel}{'Table'|@getFixedLabel}" style="margin:0;">{'MODULE'|@getFixedLabel}{'Table'|@getFixedLabel}</a>
                        </li>
                        <li onclick="ReportAnalysisObj.creat_new_table(this,'sql')">
                            <a title="SQL{'Table'|@getFixedLabel}" style="margin:0;">SQL{'Table'|@getFixedLabel}</a>
                        </li>
                        <li onclick="ReportAnalysisObj.creat_new_chart(this,'selectfield');">
                            <a title="{'statisticalGraphics'|@getFixedLabel}" style="margin:0;">{'statisticalGraphics'|@getFixedLabel}</a>
                        </li>
                        <li onclick="ReportAnalysisObj.creat_new_chart(this,'sqlchart');">
                            <a title="SQL{'statisticalGraphics'|@getFixedLabel}" style="margin:0;">SQL{'statisticalGraphics'|@getFixedLabel}</a>
                        </li>
                    </ol>
                {/if}
                <a title="{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}" class="ld-button marL12" id="sortDir" onclick="ReportAnalysisObj.sortReport(0)">
                    <span>{'MAILFOLDER'|@getFixedLabel}{'SORT'|@getFixedLabel}</span>
                </a>
            </div>
        </div>
    </div>
    {*列表*}
    {assign var=listtable_ui_type value=484|@getSys_deploy}
    <div>
        <div class="grid-analysis-box">
            <div class="ld-table-container ld-table-container-line ld-table-container-bgcolor" id="reportanalysis_tablecontent" >
                <table class="fir-center {if $listtable_ui_type['deploy_value'] neq 2}ld-list-contnet-line{/if} {if $listtable_ui_type['deploy_value'] eq 1}ld-list-content-reportAnalysis-nocolor{/if} marB20" border="0" cellspacing="0" cellpadding="0">
                    <thead>
                        <tr>
                            <th class="locking-left shadow-left" width="320">{'ReportName'|@getFixedLabel}</th>
                            <th width="200">{'Person_in_charge'|@getFixedLabel}</th>
                            <th width="200">{'reporttype'|@getFixedLabel}</th>
                            <th width="200">{'CAMCARDCAPTION'|@getFixedLabel}</th>
                            <th width="200">{'Createtime1'|@getFixedLabel}</th>
                            <th width="200">{'APPLICABLESCOPE'|@getFixedLabel}</th>
                            <th class="locking-right shadow-right" width="160">{'OPERATING'|@getFixedLabel}</th>
                        </tr>
                    </thead>
                    {*wyt 221129 XUQIU1000911 报表分析，增加“最近浏览”文件夹*}
                    <tbody tag="LastReview" {if $LastReviewRecord eq 0}style="display: none"{/if}>
                        <tr class="lvtColData" data-status="open" tag="RecentView" data-parent="0" >
                            <td class="locking-left shadow-left">
                                <div class="report-name" name="RecentView" onclick="ReportAnalysisObj.showRecentReport(this,'RecentView');">
                                    <div class="report-open">&nbsp;</div>
                                    <div tag="folder-img">
                                        <img class="marL8 marR8" src="themes/softed/images/icon-folder.png">{'RECENTLYVIEWED'|@getFixedLabel}
                                    </div>
                                </div>
                            </td>
                            <td></td>
                            <td>{'MAILFOLDER'|@getFixedLabel}</td>
                            <td><span title="">{'RecentBrowsingReport'|@getFixedLabel}</span></td>
                            <td></td>
                            <td></td>
                            <td class="locking-right shadow-right"><div style="display: flex;justify-content: flex-start;"></div>
                            </td>
                        </tr>
                    </tbody>
                    <tbody tag="reportList_list">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
<div id="reportanalysis_screen" class="main_grid lfloat customtable ld-flex-start" style="width: 100%;display:none;">
    <input type="hidden" id="LastReviewRecord" value={$LastReviewRecord}>
    <table class="ld-reportanalysis-screentable" border="0" cellspacing="0" cellpadding="0" width="100%" align="center">
        <tbody>
        <tr>
            <td valign="top" class="user-left-td">
                <div>
                    <span id="listviewtreeopen" class="tip-items-list listviewtreeopen bindtip closetree" data-tip="{'COLLAPSE'|@getFixedLabel}" data-direction="right" data-type="position"></span>
                    <div id="structuretree" style="width:320px;">
                        <div class="screen-left-reportname ld-flex-between">
                            <div style="line-height: 32px;font-size: 14px;font-weight: bold;">
                                {'ReportName'|@getFixedLabel}
                            </div>
                            <div class="ld-flex-start reportanalysis-listtype-btns" style="margin-left:6px;">
                                <div class="reportanalysis-listtype-btn listtype-list-inactive ld-button textFloatDisplay" tag="list"  data-tip="{'LISTVIEW'|@getFixedLabel}" data-direction="top" data-type="position">
                                </div>
                                <div class="reportanalysis-listtype-btn listtype-screen-active ld-button textFloatDisplay" tag="screen" style="margin-left:0 !important;" tag="screen" data-tip="{'SCREENVIEW'|@getFixedLabel}" data-direction="top" data-type="position">
                                </div>
                            </div>
                        </div>
                        <div class="create-entity-toolbar search-bar screen-left-reportname ld-flex-start">
                            <div class="lfloat prelative">
                                <input class="lfloat borderFocus" id="ld_reportanalysis_search_screen" type="text" name="keyWords" onkeyup="ReportAnalysisObj.searchSubmit(event);" onkeydown="ReportAnalysisObj.viewClearText()" placeholder="{'SEARCHNEW'|@getFixedLabel}{'ReportName'|@getFixedLabel}"/>
                                <b style="position: absolute;right:35px;top:1px;display: none" class="ld-icon-clearsearch" onclick="ReportAnalysisObj.clearText()"></b>
                                <div class="positionFirst" title="{'SEARCHNEW'|@getFixedLabel}" onclick="ReportAnalysisObj.getSearchList()">
                                    <i class="ld-fonticon ld-fonticon-search hlineheight30"></i>
                                </div>
                            </div>
                        </div>
                        <div class="grid-analysis-box">
                    <div class="cont_wrap clear_float" id="reportanalysis_tablecontent">
                        <table class="listEntries marB20" border="0" cellspacing="1" cellpadding="0" style="width: 100%;">
                            {*wyt 221129 XUQIU1000911 报表分析，增加“最近浏览”文件夹*}
                            <tbody tag="LastReview" {if $LastReviewRecord eq 0}style="display: none"{/if}>
                            <tr class="lvtColData" data-status="open" tag="RecentView" data-parent="0" >
                                <td style="width:320px;">
                                    <div class="report-name" name="RecentView" onclick="ReportAnalysisObj.showRecentReport(this,'RecentView');">
                                        <div class="report-open">&nbsp;</div>
                                        <div tag="folder-img">
                                            <img class="marL8 marR8" src="themes/softed/images/icon-folder.png">{'RECENTLYVIEWED'|@getFixedLabel}
                                        </div>
                                    </div>
                                </td>
                            </tr>
                            </tbody>
                            <tbody tag="reportList_screen">
                            </tbody>
                        </table>
                    </div>
                </div>
                    </div>
                </div>
            </td>

            <td valign="top">
                <div class="screen-detail-header ld-flex-between">
                    <div class="screen-reportname" id="screen_reportname"></div>
                    <div class="listview_toprightbox">
                        <div tag="reportanalysis_detail_btnlist" class="E_pop_tit_Second_Right ld-listview-btnscontent" style="margin: 16px 0;">
                        </div>
                    </div>
                </div>
                <div id="reportanalysis_reportcontent" style="overflow: auto;">
                    {if $LastReviewRecord<=0 }
                    <div style="position: relative;height:100%;">
                        <div class="warningTableContent" style="z-index:600;padding-top:30px;text-align: center;">
                            <div class="wtc_img" style="margin: 0 auto;"><img  style="width: 50%;height: 50%;" src="themes/softed/images/icon-nofile.png"></div>
                            <div class="wtc_content">{'SCREENVIEWTIP'|@getFixedLabel}</div>
                        </div>
                    </div>
                    {/if}
                </div>
            </td>
        </tr>
        </tbody>
    </table>
</div>

<script>
    //zxm 20220926 新建报表-- 类型下拉选择
    ld(".creat-new-table").hover(function (){
        ld(this).next().show();
    },function (){
        ld(this).next().hide();
    });
    ld(".report-type-select").hover(function (){
        ld(this).show();
    },function (){
        ld(this).hide();
    });
    var ReportAnalysisObj;

    setTimeout(function() {
        ReportAnalysis.reportanalysis_setListtype(reportanalysis_listtype);
        ReportAnalysis.setMutationObserver();
    },300);

    ld('.reportanalysis-listtype-btn').unbind('click').bind('click',function(){
        var tag=ld(this).attr('tag');
        reportanalysis_listtype = tag;
        if(ld('#reportanalysis_'+tag).css('display')=='none'){
            /*if(tag=='screen'){
                localStorage.setItem('ldcrm_ding_status', 'Close');
                hideMenu();//菜单隐藏
                closeMenu();//收起
            }*/
            /*if(reportanalysis_listtype!='screen') {
                //分屏模式点击会引起界面宽度监听  这个方法会调2次  所以判断一下
                setTimeout(function () {
                    ReportAnalysis.reportanalysis_setListtype(tag);
                }, 300);
            }*/
            //
            ReportAnalysis.reportanalysis_setListtype(reportanalysis_listtype);
        }
    });
</script>