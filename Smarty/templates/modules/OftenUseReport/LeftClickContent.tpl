<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListViewButton.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/DataCategoryPopup.js"></script>
<div class="main_grid_top" {if $listtype=='screen'}style="display: none;"{/if}>
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {if $REPORTNAMES neq 'Customers participating in the training schedule' && $REPORTNAMES <> '客户参训明细表'}
                {$reportlabel}
            {/if}
            <span id="report_time_titme"></span>
        </span>
    </div>
    <div class="grid_tool">
        <div class="create-entity-toolbar lfloat prelative">
            {if $USEREPORTSNAME eq 'checkin_monthly'}
                <a href="javascript:;" class="ld-button ld-button-primary"
                   onclick="getLinksUrl('{$TABID}','OftenUseReport','checkin_monthly');"
                   title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
            {/if}
            {if 'oem_crm'|@getCommonVersion eq 'no'}
                {if $USEREPORTSNAME eq 'SIGNINSTATISTICS'}
                    <a href="javascript:;" class="ld-button ld-button-primary"
                       onclick="getLinksUrl('{$TABID}','OftenUseReport','SIGNINSTATISTICS');"
                       title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
                {elseif $USEREPORTSNAME eq 'Serviceperformanceappraisal'}
                    <a href="javascript:;" class="ld-button ld-button-primary"
                       onclick="getLinksUrl('{$TABID}','OftenUseReport','Serviceperformanceappraisal');"
                       title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
                {/if}
            {/if}
        </div>
    </div>
</div>
<div class="main_grid_box">
    <div class="grid-analysis-box">
        <div class="grid-analysis-header">
            <!--常用报表查找-->
            {if $BASICFILTER eq 1}
                <div id="searchAcc" class="grid-analysis-search" style='width:{$PAGEWIDTHPERCENT}%;'>
                    <form name="basicSearch" method="post" action="index.php">
                        <table border="0" cellspacing="0" cellpadding="0">
                            {*editor:gyq_135 reason:增加BASICFILTERHTML为空判断  2019/8/6 15:10 ID1000568*}
                            {if $USEREPORTSNAME neq 'USERTRACKREPORT' && $USEREPORTSNAME neq 'TimeSheet personal monthly summary'&& $parent_type neq 'kucun' && $BASICFILTERHTML neq ''}
                                <tr id="OftenUseReport_search_date">
                                    {$BASICFILTERHTML}
                                </tr>
                            {/if}
                            <!--TimeSheet双时间插件-->
                            {if $USEREPORTSNAME eq 'TimeSheet personal monthly summary'}
                                <tr>
                                    <td>
                                        <span>&nbsp;{'Start_Date'|@getFixedLabel}:&nbsp;</span>
                                        <span>
                                            <input id="begin_createdate" maxlength="25" name="begin_createdate"
                                                   value="{$begin_createdate}" onClick="WdatePicker()" class="Wdate"/>
                                            <input id="b_begin_createdate" type="hidden" name="b_begin_createdate"/>
                                        </span>
                                    </td>
                                    <td>
                                        <span>{'End_Date'|@getFixedLabel}:&nbsp;</span>
                                        <span>
                                            <input id="end_createdate" maxlength="25" name="end_createdate"
                                                   value="{$end_createdate}" onClick="WdatePicker()" class="Wdate"/>
                                            <input id="bd_end_createdate" type="hidden" name="bd_end_createdate"/>
                                        </span>
                                    </td>
                                </tr>
                            {/if}
                            <!--The end-->
                            <tr>
                                {* 2024-4-3 xxy 签退方式条件 *}
                                {if $USEREPORTSNAME eq 'SIGNINSTATISTICS'}
                                    <td>
                                        <span class="valign-middle prelative">{'SignoutType'|@getFixedLabel}</span>
                                        <select class="ld-select-inner width100 marL10 marR16" name="basicotherfind3" id="basicotherfind3">
                                            <option value="">{'ALL'|@getFixedLabel}</option>
                                            <option value="signout">{'SIGNOUT2'|@getFixedLabel}</option>
                                            <option value="supsign">{'SUPSIGN'|@getFixedLabel}</option>
                                        </select>
                                    </td>
                                {/if}
                                {if $CHECKLABEL neq ''}
                                    <td width="400">
                                        <input type="checkbox" name="check_approve_status"
                                               id="check_approve_status"
                                               style="margin-right:5px;margin-top: -2px;"><span
                                                id="checkbox_label">{$CHECKLABEL}</span>
                                    </td>
                                {/if}
                                {if $USEREPORTSNAME eq 'HighAndNewTechnologyEnterpriseSchedule' || $USEREPORTSNAME eq 'ProjectCompletionStatisticsReport'}
                                    <td><span>{'AccountName'|@getFixedLabel}:&nbsp;</span><input
                                                class="borderALL" type="text"
                                                style="width:150px;height:25px;line-height:25px;box-sizing: border-box;"
                                                value="" name="basicotherfind4"
                                                id="basicotherfind4"></td>
                                {/if}
                                {if $USEREPORTSNAME eq 'SIGNINSTATISTICS'||$USEREPORTSNAME eq 'SignDistribution'}
                                    {*editor:gyq_168 reason:签到统计表功能优化，增加考勤对象类型*}
                                    <td>
                                        <span class="valign-middle prelative">{'BaiFang_DuiXiang'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}</span>
                                        <select class="ld-select-inner width100 marL10 marR16" name="basicotherfind2" id="basicotherfind2" style="margin-right:15px;">
                                            {* @edit:liushuai,2020-08-20,reason:【ID1001018】签到统计表拜访对象类型增加“全部”选项 *}
                                            <option value="">全部</option>
                                            {foreach item=fname key=itemid from = $OPTIONMODULE}
                                                <option value="{$fname.value}">{$fname.label}</option>
                                            {/foreach}
                                        </select>
                                    </td>
                                    <td>
                                        <span class="valign-middle">{'BaiFang_DuiXiang'|@getFixedLabel}</span><input class="ld-input-inner width150 marL10 marR16" type="text" value="" name="basicotherfind" id="basicotherfind"></td>
                                {/if}
                                {if $USEREPORTSNAME eq 'USERTRACKREPORT'}
                                    <td>{"DATESELECTION"|@getFixedLabel}:&nbsp;<input type="text"
                                                                                      onclick="WdatePicker()"
                                                                                      maxlength="10"
                                                                                      size="20"
                                                                                      style="border:1px solid #bababa;box-sizing: border-box;"
                                                                                      id="track_date"
                                                                                      tabindex=""
                                                                                      class="Wdate"
                                                                                      name="track_date"
                                                                                      value="{$NOW_DATE}">
                                    </td>
                                {/if}
                                {*editor:gyq_86 reason:库存报表 2018/11/23 11:37 *}
                                {if $parent_type eq 'kucun' && $BASICFILTERHTML neq ''}
                                    <td>
                                        {$BASICFILTERHTML}
                                    </td>
                                {/if}
                                {if $BASICFILTERHTML2 neq ''}
                                    {if $parent_type eq 'kucun'}
                                        {$BASICFILTERHTML2}
                                    {else}
                                        <td width="400">{$BASICFILTERHTML2}</td>
                                    {/if}
                                {/if}
                                {if $USEREPORTSNAME eq 'Serviceperformanceappraisal'}
                                    {$BASICFILTERHTML5}
                                {/if}
                                {*editor:gyq_86 reason:产品批次 2018/11/14 11:10*}
                                {if $parent_type neq 'kucun'}
                                    <td width="400" class="displayflex">
                                    <!-- TimeSheett报表员工姓名查询 -->
                                    {if $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                                        <label class="Name lfloat" style="margin-bottom: 0 !important;line-height: 52px;">
                                            <span class="fontnormal">{if $USEREPORTSNAME eq 'HighAndNewTechnologyEnterpriseSchedule' || $USEREPORTSNAME eq 'ProjectCompletionStatisticsReport'}{'项目经理'}{else}{'RANGESTAFF'|@getFixedLabel}{/if}</span>
                                        </label>
                                    {else}
                                        <label class="Name" style="padding:0 5px;padding-right: 5px;margin-bottom: 0 !important;line-height: 52px;">
                                            <span class="fontnormal">{'Employee Name'|@getFixedLabel}</span>
                                        </label>
                                    {/if}
                                    <input type="hidden" id="module" name="module" value="{$MODULE}"/>
                                    {include file='Comprehensivereport/SmownerSearchScope.tpl'}
                                    </td>
                                {/if}
                            </tr>
                            <tr>
                                <td align="left"
                                    {if $USEREPORTSNAME eq 'SalesOrderTrack' || $USEREPORTSNAME eq 'SalesOrderTrack' || $USEREPORTSNAME eq 'Thestatisticalreportofprojectperformance' || $USEREPORTSNAME eq 'Serviceperformanceappraisal'}colspan="4"{/if}>
                                    <!--生成报表按钮-->
                                    <input type="hidden" name="searchtype" value="BasicSearch"/>
                                    <input type="hidden" id="receiverid" name="receiverid"/>
                                    <input type="hidden" name="search_cnt"/>
                                    <input type="hidden" name="UseReport" value="{$USEREPORTID}"/>
                                    <input type="hidden" name="datefindcolumn"
                                           value="{$DATEFINDCOLUMN}"/>
                                    <input type="hidden" name="otherfindcolumn"
                                           value="{$OTHERFINDCOLUMN}"/>
                                    {if $USEREPORTSNAME eq 'VideoRentalIncomeStatement'}
                                        {'Accountopeningdate'|@getFixedLabel} ：
                                        <input name="duedate_start" class="Wdate" autocomplete="off" tabindex="c"
                                               type="text" style="border:1px solid #dbdbdb;" fieldlabel="" fieldonly="0"
                                               size="13" maxlength="10" value=""
                                               onclick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd'{rdelim})">
                                        ~
                                        <input name="duedate_end" class="Wdate" autocomplete="off" tabindex="c"
                                               type="text" style="border:1px solid #dbdbdb;" fieldlabel="" fieldonly="0"
                                               size="13" maxlength="10" value=""
                                               onclick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd'{rdelim})">
                                    {/if}
                                    {if $USEREPORTSNAME eq 'USERTRACKREPORT'}
                                        <input name="submit" id='BasicSearchreput' type="button"
                                               onclick="callTrackReport(this,'BasicSearch')"
                                               class="ld-button ld-button-primary" value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                    {elseif $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                                        <input name="submit" id='BasicSearchreput' type="button" tag=""
                                               onclick="callOftenUseReportSearch(this,'BasicSearch')"
                                               class="ld-button ld-button-primary" value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                    {/if}
                                    {if $USEREPORTSNAME eq 'TimeSheet personal monthly summary'}
                                        <input name="submit" id='BasicSearchreput' type="button"
                                               onclick="CallTimeSheet(this,'BasicSearch')"
                                               class="ld-button ld-button-primary" value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                    {/if}
                                    {if $USEREPORTSNAME eq 'VideoRentalIncomeStatement'}
                                        <input name="submit" id='BasicSearchreput' type="button" tag="voucher"
                                               onclick="callOftenUseReportSearch(this,'BasicSearch')"
                                               class="ld-button ld-button-primary" value="{'Synchronizationvoucher'|@getFixedLabel}"/>
                                    {/if}
                                    <!--生成报表按钮end-->
                                </td>
                            </tr>
                        </table>
                    </form>
                </div>
            {/if}
            <!--应收账款汇总表-->
            {if $BASICFILTER eq 2}
                <div id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;'>
                    <form class="Find_Form0" name="basicSearch" method="post" action="index.php">
                        <table width="100%" border="0" cellspacing="0" cellpadding="0">
                            <tr>
                                <td>
                                    <table border="0" cellspacing="0" cellpadding="5" width="100%">
                                        <tr style="height:30px;">
                                            <td width="130">
                                                {'area'|@getFixedLabel}：<select name="address" id="address"
                                                                                style="width:80px;">
                                                    <option value="">------</option>
                                                    {foreach item=fname key=itemid from = $SUBMES}
                                                        <option value="{$itemid}">{$fname}</option>
                                                    {/foreach}
                                                </select>
                                            </td>
                                            <td width="180"> {'ACCOUNTINGPROJECTNAME'|@getFixedLabel}：<input
                                                        id="OrgFName" type="text" value="" style="width:80px;"/>
                                            </td>
                                            <td width="170"> {'BUSINESSPERSONNEL'|@getFixedLabel}：
                                                <select name="FName" id="FName" style="width:80px;">
                                                    <option value="">------</option>
                                                    {foreach item=fname key=itemid from = $EMPINFO}
                                                        <option value="{$itemid}">{$fname}</option>
                                                    {/foreach}
                                                </select>
                                            </td>
                                            <td width="320"> 时间：<input type="text" class="Wdate" id="startdate"
                                                                       onclick="WdatePicker({ldelim}startDate:'%y-%M',dateFmt:'yyyy-MM',alwaysUseStartDate:true{rdelim})"
                                                                       value="{$STARTDATE}"/> ~ <input
                                                        type="text" class="Wdate" id="enddate"
                                                        onclick="WdatePicker({ldelim}startDate:'%y-%M',dateFmt:'yyyy-MM',alwaysUseStartDate:true{rdelim})"
                                                        value="{$ENDDATE}"/></td>
                                            <td align="left">
                                                <!--生成报表按钮-->
                                                <input type="hidden" name="UseReport" value="{$USEREPORTID}"/>
                                                <input name="submit" id='BasicSearchreput' type="button"
                                                       onclick="callReportSearch(this,'BasicSearch')"
                                                       class="createauto b_radius3"
                                                       value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                                <!--生成报表按钮end-->
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </form>
                </div>
            {/if}
            {if $ADVFILTER eq 1}
                <div id="advSearch" style="display:none;" style='width:{$PAGEWIDTHPERCENT}%;'>
                    <form class="frmUseReportSearch" name="advSearch" method="post" action="index.php"
                          onSubmit="return callSearch('Advanced');">
                        <table cellspacing=0 cellpadding=5 width=99% class="" align="center" border=0>
                            <tr class="basicserachtr">
                                <td class="searchUIName small" nowrap align="left" width="90%">
                                    <span class="searctype" style="color:#0070BA">
                                    {'Advanced_Search'|@getFixedLabel}                
                                    </span>
                                    <span class="searctypechangge" style="line-height: 20px;">
                                        <a href="javascript:void(0);"
                                           onClick="showdiv('searchAcc');fnhide('advSearch')">{'Go'|@getFixedLabel}{'LOWER_BASIC_QUERY'|@getFixedLabel}
                                            &gt;&gt;</a>
                                    </span>
                                </td>
                                <td class="small" valign="top" align="right"
                                    onclick="showdiv('searchAcc');fnhide('advSearch')"
                                    onmouseover="this.style.cursor='pointer';">[x]
                                </td>
                            </tr>
                        </table>

                        <table cellspacing="0" cellpadding="5" width="99%" border="0" align="center"
                               style="background:#FBFBFB;">
                            <tr>
                                <td align="center" class="small">
                                    <input type="button" class="createauto"
                                           value="{'CREATEREPORTGENERATION'|@getFixedLabel}"
                                           onClick="generateReport(this);">
                                    <input type="button" class="createauto"
                                           value="{'NEWCOMBINATION'|@getFixedLabel}"
                                           onclick="addNewConditionGroup('adv_filter_div')"/>
                                    <!--input type="button" class="editauto" onclick="saveReportAdvFilter({$USEREPORTID});" value="{'SAVE'|@getFixedLabel}" title="{'SAVE'|@getFixedLabel}" /-->
                                </td>
                            </tr>
                        </table>
                    </form>
                </div>
            {/if}
            {*editor:gyq_86 reason:库存报表  2018/12/5 13:38*}
            {if $USEREPORTSNAME neq 'Sign_in_track' && $USEREPORTSNAME neq 'SignDistribution'}
                {if $BASICFILTER neq 2 && $parent_type neq 'kucun' && $parent_type neq 'checkin'}
                    <div style="clear: both;padding: 5px 15px;">
                        {if $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                            {if $USEREPORTSNAME neq 'USERTRACKREPORT'}
                                {if $PrintPermit eq 'yes'}
                                    <a href="javascript:void(0);" title="{'PRINT'|@getFixedLabel}"
                                       onclick="UseReportPrint(this);"
                                       class="report-newsystem">{'PRINT'|@getFixedLabel}</a>
                                {/if}
                            {/if}
                            {*                        zxm 2021-1101 销售机会预测表 增加列名称设置*}
                            {if $SETCOLUMNS eq 1 && $isADMIN eq 1 && $USEREPORTSNAME neq 'HighAndNewTechnologyEnterpriseSchedule' && $USEREPORTSNAME neq 'ProjectCompletionStatisticsReport'&& $USEREPORTSNAME neq 'ProductRanking'}
                                <a href="javascript:void(0);" title="{'DISPLAYCOLUMNSET'|@getFixedLabel}"
                                   onclick="UseReportColumnSet('{$USEREPORTID}',this,'UseReportSet');" name="submit"
                                   class="report-newsystem"
                                   style="padding-left:5px;">{'DISPLAYCOLUMNSET'|@getFixedLabel}</a>
                                <a href="javascript:void(0);" title="{'COLUMNNAMESET'|@getFixedLabel}"
                                   onclick="EditUseReportColumn('{$USEREPORTID}',this,'EditUseReportColum');"
                                   name="editsubmit" class="report-newsystem"
                                   style="padding-left:5px;">{'COLUMNNAMESET'|@getFixedLabel}</a>
                            {/if}
                            {*                        zxm 2021-0222 产品排行榜 增加高级查询*}
                            {*                        zxm 2022-0627 服务看板 增加高级查询*}
                            {if $USEREPORTSNAME eq 'ProductRanking'||$USEREPORTSNAME eq 'ServiceKanban' }
                                <a href="javascript:void(0);" title="{'CUSTOMIZESEARCH'|@getFixedLabel}"
                                   onclick="oftenusereport_advSearch('{$USEREPORTSNAME}');" name="editsubmit"
                                   class="report-newsystem"
                                   style="padding-left:5px;">{'CUSTOMIZESEARCH'|@getFixedLabel}</a>
                            {/if}
                            {if $USEREPORTSNAME neq 'USERTRACKREPORT'}
                                {if $ExportExcelPermit eq 'yes'}
                                    <a href="javascript:void(0);" title="{'EXPORT'|@getFixedLabel}"
                                       onclick="Exproteoftenusereport({$USEREPORTID});" name="editsubmit"
                                       class="report-newsystem"
                                       style="padding-left:5px;">{'EXPORT'|@getFixedLabel}Excel</a>
                                {/if}
                            {/if}
                            {if $USEREPORTSNAME eq 'checkin_monthly'}
                                <a href="javascript:void(0);" title=""
                                   onclick="checkin_sync_button();" name=""
                                   class="report-newsystem"
                                   style="padding-left:5px;">{if $INTERFACETYPE=='dingtalk'} {'CHECKINSYNCBUTTONDINGTALK'|@getFixedLabel}{else}{'CHECKINSYNCBUTTON'|@getFixedLabel}{/if}</a>
                            {/if}
                            {*ls 2021-12-27 【1002356】公费电话直拨支持数据统计报表（蔡云桥-山水）*}
                            {if $USEREPORTSNAME eq 'dial_record'}
                                <a href="javascript:void(0);" title=""
                                   onclick="dial_record_sync_button();" name=""
                                   class="report-newsystem"
                                   style="padding-left:5px;">{'DialRecordSyncButton'|@getFixedLabel}</a>
                            {/if}
                            {if $isADMIN}
                                {*  zxm 2020-1009 常用报表增加提成统计报表 设置提成规则*}
                                {if $USEREPORTSNAME eq 'SalesCommissionsByOrder' || $USEREPORTSNAME eq 'SalesCommissionsByCash'}
                                    <a href="javascript:;" class="report-newsystem"
                                       style="border-right:none;padding-left:5px;" onclick="setCommissionRule(this)">
                                        {'rewardRule'|@getFixedLabel}
                                    </a>
                                {/if}
                                {*  zxm 2020-1123 常用报表增加服务收费奖金 设置提成规则*}
                                {if $USEREPORTSNAME eq 'ServiceChargeBonusByOrder' || $USEREPORTSNAME eq 'ServiceChargeBonusByCash'}
                                    <a href="javascript:;" class="report-newsystem"
                                       style="border-right:none;padding-left:5px;" onclick="setCommissionRule(this)">
                                        {'rewardServiceRule'|@getFixedLabel}
                                    </a>
                                {/if}
                            {/if}
                        {/if}
                    </div>
                {/if}
            {/if}
        </div>
        <input type="hidden" id="hidden_userreportname" name="hidden_userreportname" value="{$USEREPORTSNAME}"/>
        <input type="hidden" id="index_report_style" name="index_report_style" value="{$INDEX_REPORT}"/>
        <div class="cont_wrap clear_float">
            {if $USEREPORTSNAME eq 'USERTRACKREPORT'}
                <div id="lingdang_map" style="height:500px; width:100%">
                </div>
            {else if $USEREPORTSNAME eq 'Sign_in_track' || $USEREPORTSNAME eq 'SignDistribution'}
                <div id="UseReportList" class="DivCNotice-list" style="margin:0px;">
                    <div class="divMapRight">
                        <div id="map_div_signin" name="map_div_signin" style="width:100%;">

                        </div>
                        <input type='hidden' name='signin_info' value='{$REPORTFILTERHTML}' tag='1'/>
                    </div>
                </div>
            {else}
                <div id="UseReportList" class="DivCNotice-list" style="margin:0px;">
                    {include file="modules/OftenUseReport/UseReportEntries.tpl"}
                </div>
            {/if}

        </div>
    </div>
</div>


<div id="dv_listhighersearch" style="display:none;max-height:450px;" class="LdPopWidth800px">
    {*editor:gyq_132 reason:高级查找标识advanced_filter_mark，用于分页  2019/7/18 14:06*}
    <input type="hidden" id="advanced_filter_mark" value="no">
    <input type="hidden" id="advanced_search_fieldinfo" value='{$ADVANCEFIELDINFO}'/>
    <div class="E_pop_tit" id="dv_listhighersearch_head" style="cursor:move">
        <strong class="E_ptita">{'CUSTOMIZESEARCH'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" id="dv_listhighersearch_imgclose"
                title="{'CLOSE'|@getFixedLabel}"/>
    </div>
    <div>
        {include file='AdvanceFilter.tpl' SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
    </div>
    <div class="E_pbtn">
        <input name="button" onClick="callSearch('Advanced');" class="E_pbtnok" value="{'FINDNOW'|@getFixedLabel}"
               type="button">
        <span>&nbsp;</span>
        <input class="E_pbtncancel" value={"CANCEL"|@getFixedLabel}  type="button" onclick="hidedv_listhighersearch();">
    </div>

</div>

{*zxm 20201009 常用报表增加提成统计报表 按合同与按收款 设置业绩提现规则弹框*}
<style>
    #editContentTable tr:nth-child(3) .category-sup {
        display: none;
    }

    #editContentTable tr:nth-child(3) .icon-sdel {
        display: none;
    }

    #editContentTable tr:nth-last-child(2) .category-sdown {
        display: none;
    }
</style>
<script>
    var max_order = 1;
    var unit = '';
    var unit_value = "";
    var pageto_module = getSearchString('pageto_module', location.href);

    function setCommissionRule() {

        var byType = "{$byType}";
        ld.ajax({
            type: 'POST',
            data: "unit=&byType=" + byType,
            url: 'index.php?module=' + pageto_module + '&file=SalesCommissionAction&action=' + pageto_module + 'Ajax&function=ajaxGetRuleList',
            success: function (res) {
                res = JSON.parse(res);
                unit = res.result.unit;
                let list = res.result.list;
                let select = res.result.select;
                let content = renderRuleTable(list, 'yes', unit, select, byType);
                let crmPopupobj = CrmPopup.load("", "", "", "LdPopWidth900px", 'Settings', "", "", "", "");
                crmPopupobj.prevshow();
                if (byType == "ServiceChargeBonusByOrder" || byType == "ServiceChargeBonusByCash") {
                    crmPopupobj.setParams("{'setRewardServiceRule'|getFixedLabel}", saveCommissionRule, "", "LdPopWidth500px", 'Settings', "", "确定", "", "取消", "");
                } else {
                    crmPopupobj.setParams("{'setCommissionRule'|getFixedLabel}", saveCommissionRule, "", "LdPopWidth500px", 'Settings', "", "确定", "", "取消", "");
                }
                crmPopupobj.show(content);
                ld('.commission-unit').html(res.result.unit);
                ld('.commission-unit-input').val(res.result.unit);

            }
        });

    }

    function renderRuleTable(list, is_pop, unit, select, byType) {
        if (byType == "ServiceChargeBonusByOrder") {
            var $th_str = '<th width="25%">{"Theamountofdepartmentalservicecontractfrom"|@getFixedLabel}（<span class="commission-unit">万元</span>）</th>' +
                '<th width="25%">{"Theamountofdepartmentalservicecontractto"|@getFixedLabel}（<span class="commission-unit">万元</span>）</th>' +
                '<th width="25%">{"Proportionofbonuspool"|@getFixedLabel}（%）</th>';
            var select_str = "<tr></tr>";
        } else if (byType == "ServiceChargeBonusByCash") {
            var $th_str = '<th width="25%">{"Theamountofdepartmentalcashbillfrom"|@getFixedLabel}（<span class="commission-unit">万元</span>）</th>' +
                '<th width="25%">{"Theamountofdepartmentalcashbillto"|@getFixedLabel}（<span class="commission-unit">万元</span>）</th>' +
                '<th width="25%">{"Proportionofbonuspool"|@getFixedLabel}（%）</th>';
            var select_str = "<tr></tr>";
        } else {
            var $th_str = '<th width="25%">{"PRICESTRATEGYFROM"|@getFixedLabel}（<span class="commission-unit">万元</span>）</th>' +
                '<th width="25%">{"PRICESTRATEGYTO"|@getFixedLabel}（<span class="commission-unit">万元</span>）</th>' +
                '<th width="25%">{"CommissionRate"|@getFixedLabel}（%）</th>';
            var select_str = '<tr>' +
                '<td colspan="4">' +
                select +
                '</td>' +
                '</tr>';
        }
        let html = '';
        if (is_pop == "yes") {
            html += '<div class="edit-content" id="editContent" style="max-height: 500px;overflow-y: scroll;">';
            html += '<form class="ajax_form">' +
                '<input type="hidden" class="commission-unit-input" name="unit" value="' + unit + '"/>' +
                '<input type="hidden" name="byType" value="{$byType}"/>' +
                '<table id="editContentTable" class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">' +
                select_str +
                '<tr class="editContentTitle">' +
                $th_str +
                '<th width="25%">{"ACTIVITYOPERATION"|@getFixedLabel}</th>' +
                '</tr>';
        }
        ld.each(list, function (index, item) {
            max_order = item.order;
            html += '<tr class="edit-content-list">\n' +
                '<td align="left"><input type="text" name="commission_start[]" class="detailedViewTextBox btn-radius-system" onblur="focus_tips(this)" value="' + item.start + '"/></td>\n' +
                '<td align="left"><input type="text" onblur="focus2_tips(this)" name="commission_end[]" class="detailedViewTextBox btn-radius-system" value="' + item.end + '"/></td>\n' +
                '<td align="left"><input type="text" name="commission_rate[]" class="detailedViewTextBox btn-radius-system" value="' + item.commission_rate + '"/></td>\n' +
                '<td align="left">\n' +
                '<a class="icon-category category-sup marR8 datacategory_up" style="cursor: pointer;" tag="' + item.order + '_up" onclick="DataCategoryListPopup.moveUp(this,' + item.order + ')" title="上移"></a>\n' +
                '<a class="icon-category category-sdown marR8 datacategory_down" style="cursor: pointer;" tag="' + item.order + '_down" onclick="DataCategoryListPopup.moveDown(this,' + item.order + ')" title="下移"></a>\n' +
                '<a class="icon-homeimg icon-sdel" style="cursor: pointer;" onclick="delRule(this,' + item.order + ');" title="删除"></a>\n' +
                '</td>\n' +
                '</tr>'
        });

        if (is_pop == "yes") {
            html += '<tr>\n' +
                '            <td colspan="4" align="left">\n' +
                '                <div onclick="add_a_rule(this)" style="color:#6166D3;">+{"ADD"|@getFixedLabel}</div>\n' +
                '            </td>\n' +
                '        </tr>\n' +
                '    </table>\n' +
                '    </form>\n';
            html += '</div>'
        }

        return html;
    }

    function add_a_rule(obj) {
        max_order += 1;
        let empty_row = '<tr class="edit-content-list">\n' +
            '            <td align="left"><input type="text" name="commission_start[]" onblur="focus_tips(this)" class="detailedViewTextBox btn-radius-system" value=""/></td>\n' +
            '            <td align="left"><input type="text" name="commission_end[]" onblur="focus2_tips(this)" class="detailedViewTextBox btn-radius-system" value=""/></td>\n' +
            '            <td align="left"><input type="text" name="commission_rate[]" class="detailedViewTextBox btn-radius-system" value=""/></td>\n' +
            '            <td align="left">\n' +
            '                <a class="icon-category category-sup marR8 datacategory_up" style="cursor: pointer;" tag="' + max_order + '_up" onclick="DataCategoryListPopup.moveUp(this,' + max_order + ')" title="上移"></a>\n' +
            '                <a class="icon-category category-sdown marR8 datacategory_down" style="cursor: pointer;" tag="' + max_order + '_down" onclick="DataCategoryListPopup.moveDown(this,' + max_order + ')" title="下移"></a>\n' +
            '                <a class="icon-homeimg icon-sdel" style="cursor: pointer;" onclick="delRule(this,' + max_order + ');" title="删除"></a>\n' +
            '            </td>\n' +
            '        </tr>';
        ld(obj).parent().parent().before(empty_row);
    }

    function commission_type_change(obj) {
        let unit = '';
        let type_value = ld(obj).val();
        let byType = "{$byType}";
        //unit改变
        if (type_value == "amount") {
            unit = "{'Million'|@getFixedLabel}";
        }
        if (type_value == "target_rate") {
            unit = "%";
        }
        ld('.commission-unit').html(unit);
        ld('.commission-unit-input').val(unit);

        // 数据改变
        ld.ajax({
            type: 'POST',
            data: "unit=" + unit + "&byType=" + byType,
            url: 'index.php?module=' + pageto_module + '&file=SalesCommissionAction&action=' + pageto_module + 'Ajax&function=ajaxGetRuleList',
            success: function (res) {
                res = JSON.parse(res);
                let list = res.result.list;
                let select = res.result.select;
                let html = renderRuleTable(list, "no", unit, select);

                ld('.edit-content-list').remove();
                ld('.editContentTitle').after(html);
            }
        });
    }

    function saveCommissionRule() {
        ld('#rptContentLoading').show();
        let data = ld(".ajax_form").serializeArray();

        ld.ajax({
            type: 'POST',
            dataType: 'json',
            data: data,
            url: 'index.php?module=' + pageto_module + '&file=SalesCommissionAction&action=' + pageto_module + 'Ajax&function=saveRule',
            success: function (res) {
                ld('#rptContentLoading').hide();
                if (res.code == 1) {
                    popupobj.CancelEvent();
                    ld("[name=LBL_COMPANY_DETAILS]").click();
                    let type_value = ld('#commission_type').val();
                    //unit改变
                    if (type_value == "amount") {
                        unit = "{'Million'|@getFixedLabel}";
                    }
                    if (type_value == "target_rate") {
                        unit = "%";
                    }
                    ld('.commission-unit').html(unit);
                    ld('.commission-unit-input').val(unit);
                } else {
                    // var confirm_str = res.result.msg;
                    // RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                    ld('#big_tips').remove();
                    var child_index = res.result.index;
                    var tips = "<tr id='big_tips' style=';color:red;text-align: center;width:100%;'><td></td><td>当前金额应该大于前一行的最大金额</td><td></td><td></td></tr>";
                    ld('#editContentTable').find('tr').eq(child_index + 2).after(tips);
                    ld('#editContentTable').find('tr').eq(child_index + 2).find('input').eq(0).css('border-color', "red");
                    ld('#editContentTable').find('tr').eq(child_index + 2).find('input').eq(1).css('border-color', "red");
                    return false;
                }

            },
            error: function (xhr, textStatus, errorThrown) {

            }
        })
    }

    function focus_tips(obj) {
        let this_value = ld(obj).val();
        let last_end_value = ld(obj).parent().parent().prev().find('input').eq(1).val();
        last_end_value = last_end_value == undefined ? 0 : last_end_value;
        ld('#big_tips').remove();
        if (parseFloat(this_value) >= parseFloat(last_end_value)) {
            ld(obj).css('border-color', "#dbdbdb");
        } else {
            ld(obj).focus().css('border-color', "red");
            var focus_obj = ld(obj).parent().parent();
            var tips = "<div id='big_tips' style=';color:red;'>当前金额应该大于前一行的最大金额</div>";
            focus_obj.after(tips);
        }

    }

    function focus2_tips(obj) {
        let this_value = ld(obj).val();
        let last_input = ld(obj).parent().prev().find('input');
        let this_start_value = last_input.val();
        ld('#big_tips').remove();
        if (parseFloat(this_value) > parseFloat(this_start_value)) {
            ld(obj).css('border-color', "#dbdbdb");
        } else {
            ld(obj).focus().css('border-color', "red");
            var focus_obj = ld(obj).parent().parent();
            var tips = "<tr id='big_tips' style=';color:red;text-align: center;width:100%;'><td></td><td>当前金额应该大于前一行的最大金额</td><td></td><td></td></tr>";
            focus_obj.after(tips);
        }
    }

    function delRule(obj) {
        ld(obj).parent().parent().remove();
    }
</script>
