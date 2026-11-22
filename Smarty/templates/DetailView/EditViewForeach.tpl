<!-- included to handle the edit fields based on ui types -->
{* 客户和联系人关联字段信息*}
{if $BESTATUS eq 'yes' && $DISPLAY_POSITION eq 0}
<tr id="showAccountsContactsInfoTr"><td colspan="4">
    <div id="showAccountsContactsInfo" name="showAccountsContactsInfo"></div>
</td></tr>
{/if}
<tr>
    <td colspan="4">
        <div name='displayfields'>
            {include file='DetailView/EditBlockFields.tpl'}
        </div>
    </td>
</tr>

{if $MODULE eq 'HelpDesk'&& $HELPDESKLOG eq 1}
<tr name='HelpDeskHistorytr' style='display:none;'>
    <td colspan="4" class="ld-from-headblock">
        <!-- <div class="DivCName DivCNamehover" onclick="showHideStatus('HelpDeskHistory','HelpDeskHistorycol');"> -->
        <div class="ld-from-headblock-title">
            <span name="HelpDeskHistorycol"></span>{'SERVICE_HISTORY'|@getFixedLabel}
        </div>
    </td>
</tr>
<tr>
    <td class="entryContentPad" name="HelpDeskHistory" style='display:block;'colspan="4"></td>
</tr>
{/if}
{* 客户和联系人关联字段信息*}
{if $BESTATUS eq 'yes' && $DISPLAY_POSITION eq 1}
<tr id="showAccountsContactsInfoTr" ><td colspan="4">
    <div id="showAccountsContactsInfo" name="showAccountsContactsInfo"></div>
</td></tr>
{/if}

{if $MODULE|@get_file_address:'ShowServiceContractsDetail' eq true && $MODULE !='Accounts'}
    <tr>
        <td colspan="4" class="entryContentPad">
		    <div name="showServiceContactsInfo"></div>
        </td>
    </tr>
{/if}