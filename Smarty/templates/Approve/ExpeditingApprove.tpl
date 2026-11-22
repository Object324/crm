<form action="index.php" method="post" name="frmexpeditingapprove" >
<input type="hidden" name="module" value="Approve"/>
<input type="hidden" name="action" value="ExpeditingApprove"/>
<input type="hidden" name="returnmodule" value="{$RETURNMODULE}"/>
<input type="hidden" name="remindlogids" value="{$REMINDLOGIDS}"/>
<input type="hidden" name="expeditingreocrd" value="{$RECORD}"/>

<div id='expeditingappcontent'>
<table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
        <td width="50" align="right">{'APPROVALSTEP'|@getFixedLabel}</td>
        <td>
            <input type="hidden" name="expeditingstepids" value="{$REMINDSTEPIDS}"/>
            <span>{$REMINDSTEPNAMES}</span>
        </td>
    </tr>
    <tr>
        <td width="50" align="right">{'Recipient'|@getFixedLabel}</td>
        <td>
            <input type="hidden" name="expeditingreminder" value="{$REMINDUSERS}"/>
            <span style="white-space: initial;line-height: 18px;">{$REMINDNAMES}</span>
        </td>
    </tr>
    
</table>
<table class="settingPopTable lasttdbordernon" style="display:" name="showexpeditingremark" width="100%">
        <tbody>
            <tr>
                <td class="padTB5">
                    <font color="red">*</font>
                    <input name="requiretext" style="border:none;" value="{'REMINDSCONTENT'|@getFixedLabel}">
                    <br />
                    <textarea id="reminds_description" name="description" rows="4" style="resize:none;padding: 8px;margin-top: 6px;">{$REMINDSCONTEN}</textarea>
                </td>
            </tr>
        </tbody>
</table>
</div>
</form>



