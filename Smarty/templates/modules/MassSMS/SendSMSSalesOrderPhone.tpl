<!--修改编码格式:统一编码：UTF-8-->
<form name="sendInfoPhoneForm" method="post" action="index.php">
    <input type="hidden" name="module" value="MassSMS"/>
    <input type="hidden" name="action" value="SendSMSSalesOrder"/>
    <input type="hidden" name="parenttab" value="Marketing">
    <input type="hidden" name="phonetype" id="phonetype" value="{$SMSTYPE}">
    <input type="hidden" name="checkfieldids" id="checkfieldids" value="">
    <input type="hidden" name="salesorderid" id="salesorderid" value="{$SALESORDERID}">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SETRECEIVERMOBILE'|@getFixedLabel}</strong>
        <a href="javascript:closeAndOpenDiv('divSendSMSSalesOrder_Phone','divSendSMSSalesOrder')" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td>
        {'PCWYWTSTMTMP'|@getFixedLabel}                   
        </td>
      </tr>
       {$HTMLPHONE}
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveSalesOrderSMSPhone(this)"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeAndOpenDiv('divSendSMSSalesOrder_Phone','divSendSMSSalesOrder');"/> 
    </div>
</form>

