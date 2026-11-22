<form action="index.php" method="post" name="createdocument" >
{*    <input type="hidden" name="record" value="{$RECORD}"/>*}
    <div class="DivCR" id="div_template_select">
        <div id='subappcontent'>
            <table class="ld-public-content-paddingright padTB10" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td class="ld-form-item-label" width="100"><font color='red'>*</font>合同文件</td>
                    <td class="ld-form-item-content">
                        <input name='flowfile' type='file' accept='.pdf, .doc, .docx' class='fileinput-input'>
                    </td>
                </tr>
                {*<tr>
                    <td class="ld-form-item-label"><font color='red'>*</font>合同文档名称</td>
                    <td class="ld-form-item-content">
                        <input name='flowtitle' type='text' class="ld-input-inner">
                    </td>
                </tr>*}

            </table>
        </div>
    </div>
</form>

