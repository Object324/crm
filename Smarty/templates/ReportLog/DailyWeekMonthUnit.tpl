<!--修改编码格式:统一编码：UTF-8-->
<table border=0 cellspacing=1 cellpadding=1 width=100% height=50% class="E_stripe">
    <thead>
        <tr>
            <th class='etit_ch'>{'DAILYWEEKMONTH'|@getFixedLabel}</th>
            <th class='etit_ch'>{'DAILYREPORT'|@getFixedLabel}</th>
            <th class='etit_ch'>{'WEEKREPORT'|@getFixedLabel}</th>
            <th class='etit_ch'>{'MONTHREPORT'|@getFixedLabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr id="setting_dwm_1" class="lvtColData" onmouseout="settingListOnMouseOut('dwm_1','on');" onmouseover="settingListOnMouseOver('dwm_1');">
            <td >{'WRITE'|@getFixedLabel}</td>
            <td>{$REMINDREPORT.daily}</td>
            <td>{$REMINDREPORT.week}</td>
            <td>{$REMINDREPORT.month}</td>
        </tr>
        <tr id="setting_dwm_2" class="lvtColDataBj" onmouseout="settingListOnMouseOut('dwm_2','on');" onmouseover="settingListOnMouseOver('dwm_2');">
            <td >{'RSubordinate'|@getFixedLabel}</td>
            <td><a href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLog&look=look&parenttab=My Home Page" target="_blank">{'VIEW'|@getFixedLabel}</a></td>
            <td><a href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLog&Look=look&parenttab=My Home Page" target="_blank">{'VIEW'|@getFixedLabel}</a></td>
            <td><a href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLog&Look=look&parenttab=My Home Page" target="_blank">{'VIEW'|@getFixedLabel}</a></td>
        </tr>
        <tr id="setting_dwm_3" class="lvtColData" onmouseout="settingListOnMouseOut('dwm_3','on');" onmouseover="settingListOnMouseOver('dwm_3');">
            <td>{'SUBMITSSION'|@getFixedLabel}</td>
            <td><a class="icon-homeview icon-looksub" title="{'VIEW'|@getFixedLabel}{'DAILYREPORT'|@getFixedLabel}{'SITUATION'|@getFixedLabel}" href="index.php?pageto_module=ReportLog&pageto_action=DailyReportLogSubmit&parenttab=My Home Page" target="_blank"></a></td>
            <td><a class="icon-homeview icon-looksub" title="{'VIEW'|@getFixedLabel}{'WEEKREPORT'|@getFixedLabel}{'SITUATION'|@getFixedLabel}" href="index.php?pageto_module=ReportLog&pageto_action=WeekReportLogSubmit&parenttab=My Home Page" target="_blank"></a></td>
            <td><a class="icon-homeview icon-looksub" title="{'VIEW'|@getFixedLabel}{'MONTHREPORT'|@getFixedLabel}{'SITUATION'|@getFixedLabel}" href="index.php?pageto_module=ReportLog&pageto_action=MonthReportLogSubmit&parenttab=My Home Page" target="_blank"></a></td>
        </tr>
        <tr id="setting_dwm_4" class="lvtColDataBj" onmouseout="settingListOnMouseOut('dwm_4','on');" onmouseover="settingListOnMouseOver('dwm_4');">
            <td>{'SUMMARY'|@getFixedLabel}</td>
            <td><a class="icon-homeview icon-rptsum" title="{'VIEW'|@getFixedLabel}{'DAILYREPORT'|@getFixedLabel}{'SUMMARY'|@getFixedLabel}" href="index.php?pageto_module=ReportLog&pageto_action=DailySummary&parenttab=My Home Page" target="_blank"></a></td>
            <td><a class="icon-homeview icon-rptsum" title="{'VIEW'|@getFixedLabel}{'WEEKREPORT'|@getFixedLabel}{'SUMMARY'|@getFixedLabel}" href="index.php?pageto_module=ReportLog&pageto_action=WeekAndMonthSummary&type=1&parenttab=My Home Page" target="_blank"></a></td>
            <td><a class="icon-homeview icon-rptsum" title="{'VIEW'|@getFixedLabel}{'MONTHREPORT'|@getFixedLabel}{'SUMMARY'|@getFixedLabel}" href="index.php?pageto_module=ReportLog&pageto_action=WeekAndMonthSummary&type=2&parenttab=My Home Page" target="_blank"></a></td>
        </tr>
    </tbody>
</table>