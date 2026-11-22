<!--修改编码格式:统一编码：UTF-8-->
<form name="KIS">
<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
    {if $SETTING_MODE eq 2}
    <tr>
    	<td class="DetailedTd1Label" width="30%" align='right'>
    	{'CONNECTINGMODE'|@getFixedLabel}
    	</td>
    	<td class="DetailedTd2Info" width="70%">
    	   <select id="connectmode" name="connectmode" onchange="ConnectMode(this)">
                <option value="SQLSRV" {if $CONNECT_MODE eq 'SQLSRV'}selected{/if}>{'DIRECTCONNECTION'|@getFixedLabel}</option>
				<option value="DIRODBC" {if $CONNECT_MODE eq 'DIRODBC'}selected{/if}>{'DIRECTCONNECTIONODBC'|@getFixedLabel}</option>
                <option value="ODBC" {if $CONNECT_MODE eq 'ODBC'}selected{/if}>{'DATASOURCEODBC'|@getFixedLabel}</option>
           </select>
    	</td>
	</tr>
    {/if}
	<tr id="select_database" {if $SETTING_MODE eq 2 && $CONNECT_MODE eq 'ODBC'} style="display:none;"{/if}>
    	<td class="DetailedTd1Label" width="30%" align='right'>
    	   {'SERVICE'|@getFixedLabel}
    	</td>
    	<td class="DetailedTd2Info" width="70%">
    	<input type="text" class="detailedViewTextBox" name="KIShostname" value="{$HOSTNAME}"/>
    	</td>
	</tr>
    <tr>
        <td class="DetailedTd1Label" width="30%" align='right'>
            {'LOGINNAME'|@getFixedLabel}
        </td>
        <td class="DetailedTd2Info" width="70%">
            <input type="text" class="detailedViewTextBox" name="KISsa" value="{$SA}"/>
        </td>
    </tr>
    <tr>
        <td class="DetailedTd1Label" width="30%" align='right'>
            {'PASWD'|@getFixedLabel}
        </td>
        <td class="DetailedTd2Info" width="70%">
            <input type="password" name="KISpwd"  class="detailedViewTextBox" value="{$PWD}" />&nbsp;&nbsp;         
        </td>
    </tr>
    {if $SETTING_MODE eq 2}
    <tr>
        <td class="DetailedTd1Label" width="30%" align='right'>
            {if $CONNECT_MODE eq 'ODBC'}
                <span id="database_entity">{'DATASOURCEODBC'|@getFixedLabel}</span>
            {else}
                <span id="database_entity">{'DATABASEENTITY'|@getFixedLabel}</span>
            {/if}
        </td>
        <td class="DetailedTd2Info" width="70%">
         <input type="text" name="Database_entity"  class="detailedViewTextBox" value="{$DATABASENAME}" />&nbsp;&nbsp;         
        </td>
    </tr>
    {/if}
</table>
<input id="SETTING_MODE" type="hidden" value="{$SETTING_MODE}"/>
    <div class="D_pbtn">
    {if $SETTING_MODE eq 1}   
        <input type="button" class="D_pbtnok" value="{'CONCAT'|@getFixedLabel}" onclick="ServerCon(this,'KThree')"/>
    {else}
        <input type="button" class="D_pbtnok" value="{'TESTCONNECTION'|@getFixedLabel}" onclick="ServerCon(this,'KThree')"/><span>&nbsp;</span>
        <input type="button" id="btn_submit"  class="D_pbtncancel" value="{'CONFIRMED'|@getFixedLabel}" onclick="returnEdit(this)" disabled/>
    {/if}
    </div>
<div id="Demo_List">

</div>
</form>