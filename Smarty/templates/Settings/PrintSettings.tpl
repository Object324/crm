<div class="ld-pop-container ld-table-container ld-table-container-lines" style="max-height:415px;width: 100%;overflow-y:auto;">
    <table class="" cellspacing="0" cellpadding="0" border="0" width="100%">
        <thead>
            <tr>
                <th>{'Operationcategory'|@getFixedLabel}</th>
                <th width="180px">{'WHETHERTOENABLE'|@getFixedLabel}</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>{'PRINT'|@getFixedLabel}</td>
                <td>
                    <input id="toPrint"  type="checkbox" class="second_switch" {if !in_array('toPrint',$PrintSettingCategoriesArr) }checked=""{/if} >
                </td>
            </tr>
            <tr >
                <td>
                    {'ExporttoPDF'|@getFixedLabel}
                </td>
                <td>
                    <input id="toDOC" type="checkbox" class="second_switch" {if !in_array('toDOC',$PrintSettingCategoriesArr) }checked=""{/if}>
                </td>
            </tr>
            <tr>
                <td>
                    {'exporttopdf1'|@getFixedLabel}
                </td>
                <td>
                    <input id="toPDF" type="checkbox" class="second_switch" {if !in_array('toPDF',$PrintSettingCategoriesArr) }checked=""{/if}>
                </td>
            </tr>
            <tr>
                <td>
                    {'ExportToXLSFormat'|@getFixedLabel}
                </td>
                <td>
                    <input id="toExcel" type="checkbox" class="second_switch" {if !in_array('toExcel',$PrintSettingCategoriesArr) }checked=""{/if}>
                </td>
            </tr>
            {if $email_status eq true}
            <tr>
                <td>
                    {'Send_Email_Add_DOC'|@getFixedLabel}
                </td>
                <td>
                    <input id="toEmailDoc" type="checkbox" class="second_switch" {if !in_array('toEmailDoc',$PrintSettingCategoriesArr) }checked=""{/if}>
                </td>
            </tr>
            <tr>
                <td>
                    {'Send_Email_Add_PDF'|@getFixedLabel}
                </td>
                <td>
                    <input id="toEmailPdf" type="checkbox" class="second_switch" {if !in_array('toEmailPdf',$PrintSettingCategoriesArr) }checked=""{/if}>
                </td>
            </tr>
            <tr>
                <td>
                    {'SendEmailAddXLS'|@getFixedLabel}
                </td>
                <td>
                    <input id="toEmailExcel" type="checkbox" class="second_switch" {if !in_array('toEmailExcel',$PrintSettingCategoriesArr) }checked=""{/if}>
                </td>
            </tr>
        {/if}
        </tbody>
    </table>
</div>