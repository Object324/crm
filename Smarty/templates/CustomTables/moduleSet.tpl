<table border="0" cellspacing="0" cellpadding="0" class="ld-public-content-paddingright padTB10" style="width: 100%; table-layout: fixed;">
    <tbody>
        <tr><td style="width: 200px"></td><td style="width: calc(100% - 200px)"></td></tr>
        <tr>
            <td class="ld-form-item-label" >
                <font color="red">*</font>{'ReportName'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input type="text" name="report_name" id="report_name" placeholder="{'ReportName'|@getFixedLabel}" value="{$report_info['report_name']}" class="ld-input-inner" autocomplete="off" required>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label" >
                <font color="red">*</font>{'reporttype'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                {'MODULE'|@getFixedLabel}{'Table'|@getFixedLabel}
                <input type="hidden" name="report_type" id="report_type" value="selectfield" class="ld-input-inner" autocomplete="off" required>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label" >
                <font color="red">*</font>{'SELECT'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <select name="analysisfolder_id" id="analysisfolder_id" tag="{'SELECT'|@getFixedLabel}{'MAILFOLDER'|@getFixedLabel}" class="ld-select-inner">
                    {$folderOptions}
                </select>
            </td>
        </tr>
        <tr tag="changeModuleNamesTr" style="height:200px;">
            <td class="ld-form-item-label">
                <font color="red">*</font>{'StatisticsModule'|@getFixedLabel}
            </td>
			<!-- 模块信息 jS生成 -->
            <td class="ld-form-item-content" id="changeModuleNamesTd">
            </td>
        </tr>
    </tbody>
</table>
