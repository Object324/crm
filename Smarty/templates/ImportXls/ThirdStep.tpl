
<script language="JavaScript" type="text/javascript" src="modules/MailManager/Mask.js"></script>
<script type="text/javascript">
 
closeNewDiv();
</script>
<div id="layer" style="height: 100%; width: 100%; position: fixed; left: 0px; top: 0px; background-color: rgb(128, 128, 128); z-index: 9998; opacity: 0.6;"></div>
<div id="selectpopup_1" class="D_pop_box LdPopWidth600px ui-popup" style="position: fixed; z-index: 9999; top: 30%; left: 50%; display: block; background-color: rgb(255, 255, 255); margin-top: -94.5px; margin-left: -302px;">
    <div class="D_pop_tit"><strong class="D_ptita" id="titlename">{'IMPORT'|@getFixedLabel} {'LBL_RESULT'|@getFixedLabel}</strong>
    <a href="javascript:;" class="D_ptitc" onclick="location.href='index.php?module={$IMPORTMODULE}&action=ListView'"><img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="关闭" title="关闭"/></a>
    </div><div class="D_pop_content" style="padding:0px;">
    
    <div style="text-align:left;padding-left:8px;padding-top:8px;">
    
    <table class="D_pop_bod ImportFirst" width="100%" cellspacing="0" cellpadding="0">
<tbody>
    <tr>
        <td valign="top">
            <div style="padding: 10px 0 10px 10px;">
                <p style="font-weight:bold;">
				{if $TOTALROWS neq '' || $SUCCESSROWS > -1 || $ERRORROWS > -1}{'IMPORTRECORDTIP'|@getFixedLabel|@sprintf:$TOTALROWS:$HANGSHU:$UPDATEROWS:$ADDIMPORTROWS:$ERRORROWS}{if $PRODUCTIMPORTYPE eq 'NoImportRow' }{'IMPORTRECORDDETAILTIP'|@getFixedLabel|@sprintf:$SUCCESSDETAILSCOUNT:$FAILUREDETAILSCOUNT}{/if}<br/>{/if}
                    {if $ERRORROWS>0 || $FALSE == true}
                        失败的原因如下：
                    {/if}
                </p>
                <div class="tdExportResult" style="background-color:#f8f8f8; padding: 5px; max-height: 200px; width: 90%; overflow: auto;">
                 {if $ERRORROWS>0 || $FALSE == true || $DETAILERROR>0}{$IMPORTINFO}{/if}
                </div>
            </div>
        </td>
    </tr>
</tbody>
</table> 
            </div>             
        </td> 
    </tr>


</table>
<div class="D_pbtn">
    <input class="editauto" type="button" value="{'BACKPREVLEVEL'|@getFixedLabel}" onclick="location.href='index.php?module={$IMPORTMODULE}&action=ImportXls&xlsStep=First'"/>
    <input class="editauto" type="button" value="{'EXPORT_LOG'|@getFixedLabel}" onclick="location.href='index.php?module={$IMPORTMODULE}&file=ImportLog&action={$IMPORTMODULE}Ajax'"/>
   <input class="editauto" type="button" value="{'LBL_FINISH_BUTTON_LABEL'|@getFixedLabel}" onclick="location.href='index.php?module={$IMPORTMODULE}&action=ListView'"/>
</div>    

<script type="text/javascript">
document.getElementById('dvImport').style.display="none";
</script>
