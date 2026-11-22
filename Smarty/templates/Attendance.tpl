<div id="oashowAttendance_div">
    <table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td>
                <input type="checkbox" checked="" onclick="objoa.showAttencePop(this)" id='oachkAttendance'/>{'OASTATISTICSAPPROVE'|@getFixedLabel}
            </td>
        </tr>
    </table>
    <table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td style="width:60%;">{'OATOTALOVERTIME'|@getFixedLabel}</td>
            <td style="width:40%;" align="center" id='oatotalovertimetd'> {$oatotalovertimetd} </td>
        </tr>
        <tr>
            <td>{'OATOTALDAYSOFF'|@getFixedLabel}</td>
            <td align="center" id='oatotaldaysofftd'> {$oatotaldaysofftd} </td>
        </tr>
        <tr>
            <td>{'OAREMAININGOVERTIME'|@getFixedLabel}</td>
            <td align="center" id='oaremainingovertimetd'> {$oaremainingovertimetd} </td>
        </tr>
        <tr>
            <td>{'OATOTALANNUALLEAVE'|@getFixedLabel}</td>
            <td align="center" id="oatotalannualleavetd"> {$oatotalannualleavetd} </td>
        </tr>
        <tr>
            <td>{'OAUSEDANNUALLEAVE'|@getFixedLabel}</td>
            <td align="center" id="oausedannualleavetd"> {$oausedannualleavetd} </td>
        </tr>
        <tr>
            <td>{'OAREMAININGANNUALLEAVE'|@getFixedLabel}</td>
            <td align="center" id='oaremainingannualleavetd'> {$oaremainingannualleavetd} </td>
        </tr>
    </table>
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td>
                <a id='oaviewdetailattendance' target="_blank" href="CustomReport/JsReport/index.php?crm_report_key=oa_attendance_statistics.mrt&default_report=1">{'VIEWATTENDANCEDETAILINFO'|@getFixedlabel}</a>
            </td>
        </tr>
    </table>
</div>
