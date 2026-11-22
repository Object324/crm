<!--修改编码格式:统一编码：UTF-8-->
<form name="sendInfoTimeForm" method="post" action="index.php">
    <input type="hidden" name="module" value="MassSMS"/>
    <input type="hidden" name="action" value="SendSMSSalesOrder"/>
    <input type="hidden" name="parenttab" value="Marketing">
    <input type="hidden" name="timetype" id="timetype" value="{$SMSTYPE}">
    <input type="hidden" name="salesorderid" id="salesorderid" value="{$SALESORDERID}">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SETTIMINGRULES'|@getFixedLabel}</strong>
        <a href="javascript:closeAndOpenDiv('divSendSMSSalesOrder_Time','divSendSMSSalesOrder')" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        <td colspan="4">{'ONLYENTERPOSITIVEINTEGER'|@getFixedLabel}</td>
      </tr>
      <tr>
        <td colspan="4"><font color='red'>{'DTPGTTPDCFS'|@getFixedLabel}</span></td>
      </tr>
      <tr>
		<td align="center">{'DATE'|@getFixedLabel}</td>
        <td>
            <select id="selectDate" name="selectDate">
                {foreach item=fieldlabel key=producttoolfieldid from=$SELECTDATE}
                    {if $producttoolfieldid == $FIELDIDDATE}
                    <option value="{$producttoolfieldid}" selected="true">{$fieldlabel}</option>
                    {else}
                    <option value="{$producttoolfieldid}">{$fieldlabel}</option>
                    {/if}
                {/foreach}
            </select>
        </td>
        <td style="border: 0px solid #EAEAEA;">
            {'NUMBERDAYS'|@getFixedLabel}：<input type="text" id="textDay" name="textDay" style="width:30px;"  value="{$DAY}" />
        </td>
		<td>
           
        </td>
 	  </tr>
      <tr>
		<td align="center">{'TIMES'|@getFixedLabel}</td>
        <td>
            <select id="selectTime" name="selectTime">
                {foreach item=fieldlabel key=producttoolfieldid from=$SELECTTIME}
                    {if $producttoolfieldid == $FIELDIDTIME}
                    <option value="{$producttoolfieldid}" selected="true">{$fieldlabel}</option>
                    {else}
                    <option value="{$producttoolfieldid}">{$fieldlabel}</option>
                    {/if}
                {/foreach}
            </select>
        </td>
        <td style="border: 0px solid #EAEAEA;">
            {'HOUR'|@getFixedLabel}：<input type="text" id="textHours" name="textHours" style="width:30px;" value="{$HOURS}" />
        </td>
        <td style="border: 0px solid #EAEAEA;">
            {'MINUTE'|@getFixedLabel}：<input type="text" id="textMinutes" name="textMinutes" style="width:30px;" value="{$MINUTES}" />
        </td>
 	  </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveSalesOrderSMSTime(this)"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeAndOpenDiv('divSendSMSSalesOrder_Time','divSendSMSSalesOrder');"/> 
    </div>
</form>

