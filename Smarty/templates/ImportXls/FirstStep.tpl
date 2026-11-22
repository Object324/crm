<script type="text/javascript">
{literal}
    function ImportXlsFirstStep(obj)
    {
        
        if(document.getElementById('ImportXlsFile').value=='')
        {
            var confirm_str = arrJsPopLabel['IMPORTFILECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        }
        
         var filenames=document.getElementById('ImportXlsFile').value.toLowerCase();
         var imports=filenames.split('.xls');
         var imports2=filenames.split('.xlsx');
        // if(imports.length<=1||imports2.length>1)
        if(imports.length<=1)
         {
            var confirm_str = arrJsPopLabel['PLEASESELECTEXCEL2003FILE'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
         }
       // document.forms['frmimport'].submit();
        return true;
    }
function ExportFieldsTemp(module,parenttab)
{
    window.location='index.php?module='+module+"&action=ExportTemplateFields&parenttab="+parenttab;
}
{/literal}
</script>
<form method="POST" enctype="multipart/form-data" action="index.php" name="frmimport">
<input  type="hidden" value="{$MODULE}" name="module"/>
{if $importxbx eq 'xbx'}
<input  type="hidden" value="XBXImportXls" name="action"/>
{else}
<input  type="hidden" value="ImportXls" name="action"/>
{/if}
<input  type="hidden" value="{$CATEGORY}" name="parenttab"/>
<input   type="hidden" value="Second" name="xlsStep"/>
<div style="padding:0px 2px;">
<table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0">
<tbody>
    <tr bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" align="left" colspan="2">
			<table border="0" width="100%" cellspacing="0" cellpadding="0">
				<tr>
					<td>{$MODULELABEL} >> {'IMPORT'|@getFixedLabel}<span style="font-size: 12px;font-weight:normal;color:#939393">{'IMPORTPROMPT'|@getFixedLabel}</span></td>
					<td align ="right"></td>
				</tr>
			</table>
		</td>
    </tr>
    <tr align="center" bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" rowspan="3" width="10%">
        {'Stage'|@getFixedLabel} 1
        </td>
    </tr>
    <tr><td class="borderALL">{'EXPORTTEMPLATEANDEDITTHEDATA'|@getFixedLabel}</td></tr>
    <tr><td class="borderALL"><a name='export_link' title="{'EXPORTTEMPLATES'|@getFixedLabel}" 
						 href="javascript:void(0)" onclick="return ExportFieldsTemp('{$MODULE}','{$CATEGORY}')" class="Anu3_a">{'EXPORT'|@getFixedLabel}</a></td></tr>
    
    <tr align="center" bgcolor="#f5f5f5">
        <td class="fontStyle borderALL" rowspan="4" width="10%">
        {'Stage'|@getFixedLabel} 2
        </td>
    </tr>
    <tr><td class="borderALL">{'Select_file'|@getFixedLabel}<span style="color:#F00;">（{'PLEASEUSETHEEXPORTTEMPLATETABLE'|@getFixedLabel}{'manualcreationoftablesisnotsupported'|@getFixedLabel}）</span></td></tr>
    <tr><td class="borderALL"><input  type="file" name="ImportXlsFile" id="ImportXlsFile" style="font-size: 12px;border:none; " /></td></tr>
    <tr><td class="borderALL">{'SUPPORTFILETYPE'|@getFixedLabel}：{'commasymbols'|@getFixedLabel}<span style="color: red;">{'wpsformatisnotsupported'|@getFixedLabel}</span>{'HOWEVERINPORTWPS'|@getFixedLabel}</td></tr>
    <tr>
        <td align="right" colspan="2" class="borderALL">
            <input class="editauto" type="submit" value="{'NEXT'|@getFixedLabel}" onclick="return ImportXlsFirstStep(this)"/>
            <input class="cancelauto" type="button" onclick="location.href='index.php?module={$MODULE}&action=ListView'" value="{'CANCEL'|@getFixedLabel}" name="cancel">
        </td>
    </tr>
</tbody>
</table>
</div>
</form>