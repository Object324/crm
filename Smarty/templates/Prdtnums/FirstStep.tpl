<script language="JavaScript" type="text/javascript" src="modules/Prdtnums/Prdtnums.js"></script>
<form  name="importPrdtnums" method="POST" enctype="multipart/form-data" action="index.php" onsubmit="puyoungJS_DialogBox.block();">
<input type="hidden" value="Prdtnums" name="module"/>
<input type="hidden" value="ImportSave" name="action"/>
<table class="searchUIBasic" cellspacing="12" cellpadding="5" style="width:80%;margin-left:auto;margin-right:auto;margin-top:10px;">
    <tbody>
        <tr>
            <td class="heading2" align="left" colspan="2"> *导入 库存初始化&nbsp;&nbsp;&gt;&gt;&nbsp;&nbsp;{$WAREHOUSENAME} </td>
        </tr>
        <tr>
            <td class="leftFormBorder1" width="60%" valign="top">
                <table width="100%" cellspacing="0" cellpadding="5">
                    <tbody>
                        <tr>
                            <td class="big">选择文件</td>
                        </tr>
                        <tr>
                            <td>
                            <input id="import_file" class="small" type="file" onchange="checkFileType()" size="60" name="import_file">
                            </td>
                        </tr>
                        <tr>
                            <td class="small">支持文件类型(s):.XLS,.XLSX</td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
        <tr>
            <td align="right" >
            <input class="big edit" type="submit" onclick="return uploadAndParse();" value="导入" name="next">
            <input class="big cancel" type="button" onclick="location.href='index.php?module=Prdtnums&action=index'" value="取消" name="cancel">
            </td>
        </tr>
    </tbody>
</table>
</form>