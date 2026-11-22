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
    /*BUG0053369	已分派	严重	周晓梅*/
    /*（V8.4.6.6.5 http://153.37.192.54:20085/crm/） 常用报表-合同追踪表，界面的显示样式问题【报表筛选条件中由用户输入的文本栏会遮挡覆盖其他内容】*/
    .select2-container {
        z-index: 1 !important;
    }
    {/literal}
</style>
<script language="JavaScript" type="text/javascript"
        src="{$JSURL}include/js/modules/OftenUseReport/OftenUseReport.js"></script>

<script language="JavaScript" type="text/javascript"
        src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js"></script>

<script type="text/javascript">

    var rel_fields = {$REL_FIELDS};
</script>
<script language="JavaScript" type="text/JavaScript">
    var fLabels = new Array();
    fLabels['e'] = '{'EQ'|@getFixedLabel}';
    fLabels['n'] = '{'NEQ'|@getFixedLabel}';
    fLabels['c'] = '{'IN'|@getFixedLabel}';
    fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
    fLabels['l'] = '{'LT'|@getFixedLabel}';
    fLabels['g'] = '{'GT'|@getFixedLabel}';
    fLabels['m'] = '{'LE'|@getFixedLabel}';
    ;
    fLabels['h'] = '{'GE'|@getFixedLabel}';
    fLabels['bw'] = '{'Interval'|@getFixedLabel}';
    fLabels['b'] = '{'Before'|@getFixedLabel}';
    fLabels['a'] = '{'After'|@getFixedLabel}';
    fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
    fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
</script>
<div id="dv_listhighersearch" style="display:none;max-height:400px;" class="LdPopWidth800px">
    {*editor:gyq_132 reason:高级查找标识advanced_filter_mark，用于分页  2019/7/18 14:06*}
    <input type="hidden" id="advanced_filter_mark" value="no">
    <div class="E_pop_tit" id="dv_listhighersearch_head" style="cursor:move">
        <strong class="E_ptita">{'CUSTOMIZESEARCH'|@getFixedLabel}</strong>
        <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" id="dv_listhighersearch_imgclose" title="{'CLOSE'|@getFixedLabel}"/>
    </div>
    <table cellpadding="2" cellspacing="0" width="100%" align="center" border=0 style="background:#F4F4F4;">
        <tr>
            <td align="center" class="small" width=90% style="vertial-align:bottom">
                {include file='AdvanceFilter.tpl' SOURCE='customview' COLUMNS_BLOCK=$FIELDNAMES}
            </td>
        </tr>
    </table>
    <div class="E_pbtn">
        <input name="button" onClick="callSearch('Advanced');" class="E_pbtnok" value="{'FINDNOW'|@getFixedLabel}"
               type="button">
        <span>&nbsp;</span>
        <input class="E_pbtncancel" value={"CANCEL"|@getFixedLabel}  type="button" onclick="hidedv_listhighersearch();">
    </div>

</div>
<!--中间-->
<input type="hidden" id="hidden_userreportname" name="hidden_userreportname" value="{$USEREPORTSNAME}"/>
{*editor:gyq_135 reason:标识新请求路径  2019/8/6 15:10 ID1000568*}
<input type="hidden" id="index_report_style" name="index_report_style" value="{$INDEX_REPORT}"/>
<div class="List3Box">
    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
        <tr>
            <td class="TdLeft" valign="top" width="200">
                <div class="DivL" style="width:200px;">
                    <h2><a href="index.php?module=OftenUseReport&action=index&parenttab=Parent Reports"><span
                                    style="font-size:16px;">{$MODULE|@getTranstab}</span></a></h2>

                    {assign var='i' value=1}
                    {foreach item=childReport key=parentname from=$USEREPORTS}
                        <div class="Title Title_patch" id="change_table_{$i}" onclick="change_table({$i});"><span
                                    class="On" style="padding-left: 0px;">&nbsp;&nbsp;{$parentname}</span></div>
                        <ul id="change_table_div_{$i}" style="display:block;width: 100%;">
                            {foreach item=reportchildid key=childname from=$childReport }
                                {assign var='areportid' value=$reportchildid.id}
                                {assign var='areportlabel' value=$reportchildid.label}
                                {assign var='areportname' value=$reportchildid.name}
                                {assign var='areporttype' value=$reportchildid.type}
                                {if $areportid eq $GUIJIREPORTID}
                                    {if $areportid eq $USEREPORTID }
                                        <li><a class="On"
                                               href="guiji/manager.php?guijiurl={$GUIJIURL}&guijitoken={$GUIJITOKEN}"
                                               target="_blank">
                                                <span class="Text report-text-ellipsis gwidth100"
                                                      title="{$areportlabel}">{$areportlabel}</span></a>
                                        </li>
                                    {else}
                                        <li><a href="guiji/manager.php?guijiurl={$GUIJIURL}&guijitoken={$GUIJITOKEN}"
                                               target="_blank">
                                                <span class="Text report-text-ellipsis gwidth100"
                                                      title="{$areportlabel}">{$areportlabel}</span></a>
                                        </li>
                                    {/if}
                                {elseif $areportid eq $GUIJIROUTEID}
                                    <li><a class="On" href="index.php?module=OftenUseReport&action=ReportGuiJi"
                                           target="_blank">
                                            <span class="Text report-text-ellipsis gwidth100"
                                                  title="{$areportlabel}">{$areportlabel}</span></a>
                                    </li>
                                    {*当前选中的报表名*}
                                {elseif $areportid eq $USEREPORTID}
                                    <li>
                                        {*新报表路径*}
                                        {if $areporttype eq '51'}
                                            <a class="On" href="index.php?module=OftenUseReport&action=index_report&report_name={$areportname}&UseReport={$areportid}">
                                            <span class="Text report-text-ellipsis gwidth100"
                                                  title="{$areportlabel}">{$areportlabel}</span></a>
                                        {else}
                                            <a class="On"
                                               href="index.php?module=OftenUseReport&action=ListView&UseReport={$areportid}">
                                            <span class="Text report-text-ellipsis gwidth100"
                                                  title="{$areportlabel}">{$areportlabel}</span></a>
                                        {/if}
                                    </li>
                                {elseif $areporttype eq '51'}
                                    {*新报表路径*}
                                    <li>
                                        <a href="index.php?module=OftenUseReport&action=index_report&report_name={$areportname}&UseReport={$areportid}">
                                            <span class="Text report-text-ellipsis gwidth100"
                                                  title="{$areportlabel}">{$areportlabel}</span></a>
                                    </li>
                                {else}
                                    <li>
                                        <a href="index.php?module=OftenUseReport&action=ListView&UseReport={$areportid}">
                                            <span class="Text report-text-ellipsis gwidth100"
                                                  title="{$areportlabel}">{$areportlabel}</span></a>
                                    </li>
                                {/if}
                            {/foreach}
                        </ul>
                        {assign var="i" value=$i+1}
                    {/foreach}
                </div>
            </td>
            <td class="Tdcenter" valign="top" style="padding: 0 15px;">
                <div class="DivC" style="border:0px;">
                    <h3 style="font-size:16px;padding:0;margin:0; height:45px; line-height:45px">
                        {if $REPORTNAMES neq 'Customers participating in the training schedule' && $REPORTNAMES <> '客户参训明细表'}
                            {$reportlabel}
                        {/if}
                        <span id="report_time_titme"></span>
                        {*editor:gyq_139 reason:月度考勤增加显示补卡  2019/8/28 11:02*}
                        {*editor:gyq_155 reason:钉钉考勤同步  2019/10/30 16:56 ID1000624 *}
                        {*0038423: （kfbcrm）常用报表->月度考勤统计表：右上角缺少【帮助】按钮*}
                        {if $USEREPORTSNAME eq 'checkin_monthly'}
                            <a class="rfloat" href="javascript:;" style="margin-right: 0px;font-size: 13px;"
                                onclick="getLinksUrl('{$TABID}','OftenUseReport','checkin_monthly');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
                        {/if}
                        {if 'oem_crm'|@getCommonVersion eq 'no'}
                            {if $USEREPORTSNAME eq 'SIGNINSTATISTICS'}
                                <a class="rfloat" href="javascript:;" style="margin-right: 0px;font-size: 13px;"
                                   onclick="getLinksUrl('{$TABID}','OftenUseReport','SIGNINSTATISTICS');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
                            {elseif $USEREPORTSNAME eq 'Serviceperformanceappraisal'}
                                <a class="rfloat" href="javascript:;" style="margin-right: 0px;font-size: 13px;"
                                   onclick="getLinksUrl('{$TABID}','OftenUseReport','Serviceperformanceappraisal');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
                            {/if}
                        {/if}
                    </h3>
                    <!--常用报表查找-->
                    {if $BASICFILTER eq 1}
                        <div id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;padding-bottom:5px;'>
                            <form class="Find_Form0" name="basicSearch" method="post" action="index.php">
                                <table width="100%" border="0" cellspacing="0" cellpadding="0">
                                    <tr>
                                        <td>
                                            <table border="0" cellspacing="0" cellpadding="5">
                                                {*editor:gyq_135 reason:增加BASICFILTERHTML为空判断  2019/8/6 15:10 ID1000568*}
                                                {if $USEREPORTSNAME neq 'USERTRACKREPORT' && $USEREPORTSNAME neq 'TimeSheet personal monthly summary'&& $parent_type neq 'kucun' && $BASICFILTERHTML neq ''}
                                                    <tr style="height:35px;" id="OftenUseReport_search_date">
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
                                                <tr style="height:35px;">
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
                                                    {if $USEREPORTSNAME eq 'SIGNINSTATISTICS' }
                                                        {*editor:gyq_168 reason:签到统计表功能优化，增加考勤对象类型*}
                                                        <td>
                                                            <span style="vertical-align: middle;">{'BaiFang_DuiXiang'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}:&nbsp;</span>
                                                            <select class="borderALL btn-radius-system width100" name="basicotherfind2" id="basicotherfind2" style="margin-right:15px;">
                                                                {foreach item=fname key=itemid from = $OPTIONMODULE}
                                                                    <option value="{$fname.value}">{$fname.label}</option>
                                                                {/foreach}
                                                            </select>
                                                        </td>
                                                        <td><span style="vertical-align: middle;">{'BaiFang_DuiXiang'|@getFixedLabel}:&nbsp;</span><input class="detailedViewTextBox" type="text"
                                                                                           style="width:150px;"
                                                                                           value=""
                                                                                           name="basicotherfind"
                                                                                           id="basicotherfind"></td>
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
                                                            <td>{$BASICFILTERHTML2}</td>
                                                        {/if}
                                                    {/if}
                                                    {if $USEREPORTSNAME eq 'Serviceperformanceappraisal'}
                                                        {$BASICFILTERHTML5}
                                                    {/if}
                                                    {*editor:gyq_86 reason:产品批次 2018/11/14 11:10*}
                                                    {if $parent_type neq 'kucun'}
                                                        <td width="400">
                                                            <!-- TimeSheett报表员工姓名查询 -->
                                                            {if $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                                                                <label class="Name" style="padding:0;padding-right: 5px;margin-bottom: 0 !important;line-height: 52px;">
                                                                    <span style="font-weight:normal;">{if $USEREPORTSNAME eq 'HighAndNewTechnologyEnterpriseSchedule' || $USEREPORTSNAME eq 'ProjectCompletionStatisticsReport'}{'项目经理'}{else}{'RANGESTAFF'|@getFixedLabel}{/if}</span>
                                                                </label>
                                                            {else}
                                                                <label class="Name" style="padding:0;padding-right: 5px;margin-bottom: 0 !important;line-height: 52px;">
                                                                    <span style="font-weight:normal;">{'Employee Name'|@getFixedLabel}</span>
                                                                </label>
                                                            {/if}
                                                            <input type="hidden" id="module" name="module" value="{$MODULE}"/>
                                                            {include file='Comprehensivereport/SmownerSearchScope.tpl'}
                                                        </td>
                                                    {/if}

                                                </tr>
                                                <tr>
                                                    <td colspan="2" align="left"
                                                        {if $USEREPORTSNAME eq 'SalesOrderTrack' || $USEREPORTSNAME eq 'Thestatisticalreportofprojectperformance' || $USEREPORTSNAME eq 'Serviceperformanceappraisal'}colspan="4"{/if}>
                                                        <!--生成报表按钮-->
                                                        <input type="hidden" name="searchtype" value="BasicSearch"/>
                                                        <input type="hidden" id="receiverid" name="receiverid"/>
                                                        <input type="hidden" name="search_cnt"/>
                                                        <input type="hidden" name="UseReport" value="{$USEREPORTID}"/>
                                                        <input type="hidden" name="datefindcolumn"
                                                               value="{$DATEFINDCOLUMN}"/>
                                                        <input type="hidden" name="otherfindcolumn"
                                                               value="{$OTHERFINDCOLUMN}"/>
                                                        {if $USEREPORTSNAME eq 'USERTRACKREPORT'}
                                                            <input name="submit" id='BasicSearchreput' type="button"
                                                                   onclick="callTrackReport(this,'BasicSearch')"
                                                                   class="createauto b_radius3 a" style="height: 25px;margin-left:0;"
                                                                   value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                                        {elseif $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                                                            <input name="submit" id='BasicSearchreput' type="button"
                                                                   onclick="callOftenUseReportSearch(this,'BasicSearch')"
                                                                   class="createauto b_radius3 b" style="height: 25px;margin-left:0;"
                                                                   value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                                        {/if}
                                                        {if $ADVFILTER eq 1 && $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                                                            <!--转向高级查询
                                        <span style="margin-left:12px;line-height: 25px;"><a href="#" onClick="fnhide('searchAcc');showdiv('advSearch');document.basicSearch.searchtype.value='advance';">{'Advanced_Search2'|@getFixedLabel}&gt;&gt;</a></span>-->
                                                        {/if}
                                                        {if $USEREPORTSNAME eq 'TimeSheet personal monthly summary'}
                                                            <input name="submit" id='BasicSearchreput' type="button"
                                                                   onclick="CallTimeSheet(this,'BasicSearch')"
                                                                   class="createauto b_radius3 c" style="height: 25px;margin-left:0;"
                                                                   value="{'CREATEREPORTGENERATION'|@getFixedLabel}"/>
                                                        {/if}
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
                                <table cellspacing="0" cellpadding="2" width="99%" border="0" align="center"
                                       style="background:#F4F4F4;">
                                    <tr>
                                        <td align="center" class="small" width=90% style="vertial-align:bottom">
                                            {include file='AdvanceFilter.tpl' SOURCE='usereports'}
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
                    {if $BASICFILTER neq 2 && $parent_type neq 'kucun' && $parent_type neq 'checkin'}
                        <!--常用报表查找 end-->
                        <div style="clear:both;padding-bottom: 5px;">
                            {if $USEREPORTSNAME neq 'TimeSheet personal monthly summary'}
                                {if $USEREPORTSNAME neq 'USERTRACKREPORT'}
                                    <a href="javascript:void(0);" title="{'PRINT'|@getFixedLabel}"
                                       onclick="UseReportPrint(this);" class="report-newsystem">
                                        <!--<b class="icon-newprint"></b>-->{'PRINT'|@getFixedLabel}</a>
                                {/if}
                                {if $SETCOLUMNS eq 1 && $isADMIN eq 1 && $USEREPORTSNAME neq 'Salesforecastandanalysistable' && $USEREPORTSNAME neq 'HighAndNewTechnologyEnterpriseSchedule' && $USEREPORTSNAME neq 'ProjectCompletionStatisticsReport'}
                                    <a href="javascript:void(0);" title="{'DISPLAYCOLUMNSET'|@getFixedLabel}"
                                       onclick="UseReportColumnSet('{$USEREPORTID}',this,'UseReportSet');" name="submit"
                                       class="report-newsystem" style="padding-left:5px;">
                                        <!--<b class="icon-newset"></b>-->{'DISPLAYCOLUMNSET'|@getFixedLabel}</a>
                                    <a href="javascript:void(0);" title="{'COLUMNNAMESET'|@getFixedLabel}"
                                       onclick="EditUseReportColumn('{$USEREPORTID}',this,'EditUseReportColum');"
                                       name="editsubmit" class="report-newsystem" style="padding-left:5px;">
                                        <!--<b class="icon-newset"></b>-->{'COLUMNNAMESET'|@getFixedLabel}</a>
                                {/if}
                                <!--{if $USEREPORTSNAME neq 'USERTRACKREPORT'}
                                    <a href="javascript:void(0);" title="{'EXPORT'|@getFixedLabel}" onclick="Exproteoftenusereport({$USEREPORTID});" name="editsubmit" class="report-newsystem" {if $USEREPORTSNAME neq 'SIGNINSTATISTICS'} style="border-right:none;padding-left:5px;"{/if} >{'EXPORT'|@getFixedLabel}Excel</a>
                                {/if}
                                {if $USEREPORTSNAME eq 'SIGNINSTATISTICS'}
                                    <a id="recalculated_distance" href="#" title="{'RECALCULATED'|@getFixedLabel}" onclick="recalculated_distance(this,{$USEREPORTID});" name="editsubmit" href="javascript:void(0);"  class="report-newsystem" style="border-right:none;padding-left:5px;">{'RECALCULATED'|@getFixedLabel}</a>
                                {/if}-->
                                {if $USEREPORTSNAME neq 'USERTRACKREPORT'}
                                <a href="javascript:void(0);" title="{'EXPORT'|@getFixedLabel}"
                                   onclick="Exproteoftenusereport({$USEREPORTID});" name="editsubmit"
                                   class="report-newsystem"
                                   style="border-right:none;padding-left:5px;">{'EXPORT'|@getFixedLabel}Excel</a>
                                {/if}
                                {if $USEREPORTSNAME eq 'checkin_monthly'}
                                   <a href="javascript:void(0);" title=""
                                       onclick="checkin_sync_button();" name=""
                                       class="report-newsystem"
                                       style="border-right:none;padding-left:5px;">{if $INTERFACETYPE=='dingtalk'} {'CHECKINSYNCBUTTONDINGTALK'|@getFixedLabel}{else}{'CHECKINSYNCBUTTON'|@getFixedLabel}{/if}</a>
                                {/if}
                                    {*{if $INTERFACETYPE==''||$INTERFACETYPE=='weixin'}*}
                            {/if}

                        </div>
                    {/if}

                    {if $USEREPORTSNAME eq 'USERTRACKREPORT'}
                        <div id="lingdang_map" style="height:500px; width:100%">
                        </div>
                    {else}
                        <div class="clear"></div>
                        <div id="UseReportList" class="DivCNotice-list" style="margin:0px; ">
                            {include file="modules/OftenUseReport/UseReportEntries.tpl"}
                        </div>
                    {/if}

                </div>
            </td>
        </tr>
    </table>
</div>
<!--中间 end-->
<div id="DivPopupReport" class="D_pop_box LdPopWidth650px" style="display:none;">
</div>
<div id="UseReportSet" class="D_pop_box LdPopWidth500px" style="display:none;">
    <div id="columnset_form_div"></div>

</div>
<div id="EditUseReportColum" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="Edit_Column_div"></div>

</div>

<script type="text/javascript">
    window.onresize = function () {ldelim}
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

</script>


<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css"/>
<!-- <script type="text/javascript" src="include/daterangepicker/jquery-1.8.3.min.js"></script> -->
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=Hgvb6X18khZw223dBW1hFHuT"></script>
<script type="text/javascript" src="include/js/map.js"></script>


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
            map_obj.show_map('{$MAP_CENTER_LNG}', '{$MAP_CENTER_LAT}');
            var pointobj = eval('(' + pointjson + ')') ? eval('(' + pointjson + ')') : JSON.parse(pointjson);
            map_obj.setTrackReport(pointobj);
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
    {literal}
    var PageRecordPopupobj = PageRecordPopup.load('{$MODULE}');
    PageRecordPopupobj.divid = "searchAcc";
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

        // ld("#" + liid).find("div").css("background-color", "#6166D3");
        // ld("#" + liid).find("a").css("color", "#fff");
        // switch (liid) {
        //     case 'createCategory':
        //         ld("#" + liid).find("b").css({'background-position': '-1px -17px'});
        //         break;
        //     case 'categorymanager':
        //         ld("#" + liid).find("b").css({'background-position': '-19px -17px'});
        //         break;
        //     case 'categorysear':
        //         ld("#" + liid).find("b").css({'background-position': '-35px -17px'});
        //         break;
        //     case 'categoryAdvsear':
        //         ld("#" + liid).find("b").css({'background-position': '-50px -17px'});
        //         break;
        // }
        setTimeout(function () {
            ld('#dv_listbasiscsearch ').find('.txtBox').focus()
        }, 100)
    }

    function hidedv_listhighersearch() {
        //  ld('#dv_listhighersearch').css("display",'none');
        var popupobj = CrmPopup.getPopupObj("last");
        popupobj.CancelEvent();
    }

    {/literal}
</script>
 