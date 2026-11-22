<div class="D_pop_tit">
	<strong class="D_ptita">{'IMPORT'|@getFixedLabel}</strong>
    <a href="javascript:fninvshnew('actiondiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
<div style="padding:0px 2px;">
<table class="ImportFirst" width="100%" cellspacing="0" cellpadding="0">
<tbody>
    <tr>
        <td class="fontStyle borderALL" bgcolor="#f5f5f5" align="left" colspan="2">{'IMPORT'|@getFixedLabel} {'LBL_RESULT'|@getFixedLabel}{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="icon-homeimg icon-wenhao rfloat" href="javascript:;" onclick="getLinksUrl('{$MODULE}','Import','module_import_step1');"></a>{/if}</td>
    </tr>
    <tr>
        <td valign="top" class="borderALL">
            <table cellspacing="0" cellpadding="10" align="center" bgcolor="#eeeeee">
            <tbody>
                <tr>
                    <td style="padding:10px 40px;font-weight:bold;">导入的记录总数:{$TOTALROWS}/{$TOTALROWS}</td>
                </tr>
                <tr>
                    <td style="padding:0px 40px;">
                        <div class="tdExportResult" style="background-color:#fff;padding:5px;">
                         {$IMPORTINFO}
                        </div>
                    </td>
                </tr>
                <tr>
                    <td style="padding:10px 40px;font-weight:bold;">失败记录总数:{$ERRORROWS} / {$TOTALROWS}。</td>
                </tr>
            </tbody>
            </table>
        </td>
    </tr>
    <tr>
        <td class="borderALL" align="center" colspan="2">
        <input class="cancelauto" type="button" onclick="fninvshnew('actiondiv');resetRelated({$CURRRELID});" value="{'TEMPLATECOMPLETE'|@getFixedLabel}" name="cancel">    
        </td>
    </tr>
</tbody>
</table>
</div>