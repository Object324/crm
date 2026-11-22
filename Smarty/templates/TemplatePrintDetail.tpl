<link rel="stylesheet" type="text/css" href="themes/softed/TemplatePrint.css" />
<link href="themes/softed/Control.css" rel="stylesheet" type="text/css" />
<form action="index.php" method="post" name="TemplatePrintform">
    <input type="hidden" name="printtabid" value="{$PRINTTABID}" />
    <input type="hidden" name="module" value="Settings" />
    <input type="hidden" name="action" value="TemplatePrintSave" />
    <input type="hidden" name="printid" value="{$PRINTID}" />

    <div class="ControlDiv2" style="height: 42px;">
        <div class="F_r" style="margin: 5px;">
            <input type="button" value="{'COPY'|@getFixedLabel}" class="ld-button ld-button-primary createauto b_radius3"
                onclick="TemplateprintList.copy({$PRINTID})" />
            <input type="button" class="ld-button ld-button-primary saveauto b_radius3" value="{'EDIT'|@getFixedLabel}"
                onclick="TemplateprintList.edit({$PRINTID})" />
            {if 'oem_crm'|@getCommonVersion eq 'no' && $TYPE eq ''}
                <a class="ld-button" href="http://51mis.com.cn/forum.php?mod=viewthread&tid=535&fromuid=1" target="_blank" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>
            {/if}
        </div>
    </div>
    <div>
        <div class="TitleHeading BorTnone BorLnone BorRnone">
            <b>{'BASICINFO'|@getFixedLabel}</b>
        </div>
        <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
            <tr>
                <td width="20%" class="DetailedTd1Label" align="right">
                    <font color="red">*</font>{'TEMPLATENAME'|@getFixedLabel}
                </td>
                <td width="80%" align="left" class="DetailedTd2Info" style="border-right: none;">
                    {$TEMPLATENAME}
                </td>
            </tr>
            <tr>
                <td width="20%" class="DetailedTd1Label" align="right">
                    {'WHETHERDEFAULT'|@getFixedLabel}
                </td>
                <td width="80%" align="left" class="DetailedTd2Info" style="border-right: none;">
                    {if $ISDEFAULT eq 0}
                        <input type="checkbox" value="0" name="isDefault" disabled="true"
                            onclick="setTemplateDefault(this)">
                    {else}
                        <input type="checkbox" value="1" name="isDefault" checked="true" disabled="true"
                            onclick="setTemplateDefault(this)">
                    {/if}
                </td>
            </tr>
        </table>
    </div>
    <div>
        <div class="TitleHeading BorTnone BorLnone BorRnone">
            <b>{'TEMPLATEINFORMATION'|@getFixedLabel}</b>
        </div>
        <table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
            <tr>
                <td width="20%" class="DetailedTd1Label" align="right">
                    {'REPLACEVARIABLEEMPTY'|@getFixedLabel}
                </td>
                <td width="80%" align="left" class="DetailedTd2Info" style="border-right: none;">
                    {$REPLACESPACEVALUE}
                </td>
            </tr>
            <tr>
                <td width="20%" class="DetailedTd1Label" align="right">
                    {'PRINTTEMPLAATE'|@getFixedLabel}
                </td>
                {if $TYPE eq 'Word' || $TYPE eq 'Excel'}
                    <td align="left" style="padding: 5px 10px 5px 5px;" colspan="3">
                        <div class="fileinput-box">
                            <input type="hidden" name="I_file_filename" id="I_file_filename" value="" />
                            <div name="UploadFile" class="wu-example" style="display: flex;">
                            </div>
                        </div>
                    </td>
                {else}
                    <td width="80%" align="left" class="DetailedTd2Info" style="border-right: none;">
                        {$CKEDITORHTML}
                    </td>
                {/if}
            </tr>
        </table>
    </div>
</form>