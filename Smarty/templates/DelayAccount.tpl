<form name="DelayAccount" action="index.php" method="post" class="delayaccount_form">
 <input type="hidden" value="{$VIEWID}" name="viewname"/>
    <input type="hidden" value="{$RECORD}" name="record"/>
    <input  type="hidden" name="pagepublicaccounttype" value="{$ACCOUNTTYPE}" />
    <input type="hidden" value="Accounts" name="module"/>
    <input type="hidden" value="{$SEARCHSCOPE}" name="SearchScope"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td class="ld-form-item-label">{'ACCOUNTDELAY'|@getFixedLabel}{$MODULENAME}</td>
        <td class="ld-form-item-content"><span class="ld-text-inner">{$ACCOUNTNAME}</span></td>
      </tr>
	  <tr>
        <td class="ld-form-item-label">{'Protectionenddate'|@getFixedLabel}</td>
        <td class="ld-form-item-content"><span class="ld-text-inner">{$PROTECTDATE}</span></td>
      </tr>
      <tr> 
        <td class="ld-form-item-label">
            <span style="color: red;">*</span>{'ACCOUNTDELAY'|@getFixedLabel}{'NUMBERDAYS'|@getFixedLabel}
        </td>
        <td class="ld-form-item-content">
            <input class="ld-input-inner" name="txtdelay" type="text" autofocus="" />
        </td>
      </tr>
    </table>
    <div class="E_pbtn">
    	<input type="submit" class="E_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="this.form.action.value='DelayAccount';return funDelayAccount('{$RECORD}');"/><span>&nbsp;</span>
        <input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="CrmPopup.getPopupObj('last').CancelEvent();"/> 
    </div>
</form>