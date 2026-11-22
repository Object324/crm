<script language="JavaScript" type="text/javascript" src="include/js/webuploader.js"></script>

<div class="E_pop_tit">
	<strong class="E_ptita">{'IMPORT'|@getFixedLabel}</strong>
    <button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}" onclick="fninvshnew('actiondiv');"></button>
</div>
<form method="POST" enctype="multipart/form-data" action="index.php" name="frmimport" id="frmimport">
    <input  type="hidden" value="{$MODULE}" name="module"/>
    <input  type="hidden" value="ImportXls" name="action"/>
    <input  type="hidden" value="{$CATEGORY}" name="parenttab"/>
    <input  type="hidden" id="current_userid" value="{$UserID}" name="current_userid"/>
    <input  type="hidden" value="Second" name="xlsStep"/>
    <input type="hidden" id="filetext" name="filetext" value="888">
    <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tbody>
            <tr>
                <th align="left" colspan="2">
        			{$MODULELABEL} >> {'IMPORT'|@getFixedLabel} >> {'Stage'|@getFixedLabel} 1
        		</th>
            </tr>
            <tr>
                <td>{'Select_file'|@getFixedLabel}</td>
            </tr>
            <tr>
                <td>
                    <div id="queue"></div>
                	<span id="files"></span>
                    <div id="uploader_popup" class="wu-example">
                    </div>
                </td>
            </tr>
            <tr>
                <td>{'SUPPORTFILETYPE'|@getFixedLabel}(s): .xls.xlsx</td>
            </tr>
        </tbody>
    </table>
    <div class="E_pbtn">
        <input class="E_pbtnok" type="button" value="{'NEXT'|@getFixedLabel}" onclick="return showDivImportSecond(this,'{$IMPORTMODULE}')"/><span>&nbsp;</span><input class="E_pbtncancel" type="button" onclick="fninvshnew('actiondiv');" value="{'CANCEL'|@getFixedLabel}" name="cancel">
    </div>
</form>