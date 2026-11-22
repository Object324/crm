<!--修改编码格式:统一编码：UTF-8-->
<form name="KIS">
<input type="hidden" name="KISdatabasename" value="{$DATABASENAME}"/>
<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
<tr>
	<td class="DetailedTd1Label" width="20%" align='right'>
		{'SERVICE'|@getFixedLabel}
	</td>
	<td class="DetailedTd2Info" width="30%">
		<input type="text" class="detailedViewTextBox" name="KIShostname" value="{$HOSTNAME}"/>
	</td>
</tr>
<tr>
	<td class="DetailedTd1Label" width="20%" align='right'>
		{'LOGINNAME'|@getFixedLabel}
	</td>
	<td class="DetailedTd2Info" width="30%">
		<input type="text" class="detailedViewTextBox" name="KISsa" value="{$SA}"/>
	</td>
</tr>
<tr>
	<td class="DetailedTd1Label" width="20%" align='right'>
		{'PASWD'|@getFixedLabel}
	</td>
	<td class="DetailedTd2Info" width="30%">
		<input type="password" name="KISpwd"  class="detailedViewTextBox" value="{$PWD}" /><!-- <input  type="button"  class="ztxz_btn" value="连接" onclick="ServerCon(this,'{$FACETYPE}')"/> -->
	</td>
</tr>

{if $SETTING_MODE eq 2}
    <tr>
        <td class="DetailedTd1Label" width="20%" align='right'>
        {'DATABASEENTITY'|@getFixedLabel}
        </td>
        <td class="DetailedTd2Info" width="30%">
         <input type="text" name="Database_entity"  class="detailedViewTextBox" value="{$DATABASENAME}" />&nbsp;&nbsp;         
        </td>
    </tr>
{/if}
</table>
    <div> 
    {if $SETTING_MODE eq 1}   
        <div class="ControlDiv2">    
            <input type="button"  class="D_pbtnok" value="{'CONCAT'|@getFixedLabel}" onclick="ServerCon(this,'{$FACETYPE}')"/>
        </div>
    {else}
        <div  class="ControlDiv2">
            <input type="button"  class="D_pbtnok" value="{'TESTCONNECTION'|@getFixedLabel}" onclick="ServerCon(this,'{$FACETYPE}')"/>
            <input type="button"  class="D_pbtncancel" id="btn_submit" value="{'CONFIRMED'|@getFixedLabel}" onclick="returnEdit(this)" disabled />
        </div>
    {/if}
    </div>
<div id="Demo_List" >

</div>
</form>