<!--修改编码格式:统一编码：UTF-8-->
    <div class="E_pop_tit">
    	<strong class="E_ptita">
            {if $MASSALLOCATE eq 'yes'}
    			{'LBL_DISTRIBUT_HIGHSEAS'|@getFixedLabel}
    		{else}
    			{'ALLOCATE'|@getFixedLabel}
    		{/if}
        </strong>
        {if $MASSALLOCATE eq 'yes' || $DETAILSVIEW eq 1}
			<a href="javascript:fninvshnew('massallocate');" class="E_ptitc">
		{else}
			<a href="javascript:fninvshnew('signleallocate');" class="E_ptitc">
		{/if}
            <img class="E_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>	
<form onsubmit="puyoungJS_DialogBox.block();" action="index.php" id="massedit_form" name="EditView">
	<table width="100%" cellspacing="0" cellpadding="0" border="0" bgcolor="white" align="center">
		<tbody>
		<tr>
			<td valign="top" colspan="4">
				<input type="hidden" value="{$VIEWID}" name="viewname"/>
				<input type="hidden" value="{$RECORD}" name="record"/>
				<input type="hidden" name="allocatetype" value="2"/>
				<input type="hidden" name="idstring" id="idstring" value="{$IDSTRING}">
				<input  type="hidden" name="pagepublicaccounttype" value="{$ACCOUNTTYPE}" />
				<input type="hidden" value="Accounts" name="module">
				<input type="hidden" value="AllocateAccount" name="action">
				<input type="hidden" value="{$SEARCHSCOPE}" name="SearchScope"/>
				<input type="hidden" value="{$assign_user_id}" name="assign_name" id="assign_name"/>
                <input  type="hidden" value="{$TOTALSELECTROWS}" id="mass_allocatusers_rows" name="mass_allocatusers_rows"/>
			</td>
		</tr>
		</tbody>
	</table>
	<table class="D_pop_bod" width="100%" align="center" cellspacing="1" cellpadding="2" border="0">
      <tr>
        {assign var=usefldlabel value='DARCC'|@getFixedLabel}
       	{assign var=fldvalue value=$ALLOCATEUSERS}
	   {include file='DetailView/PublicAllocateSmowner.tpl'}
       
      </tr>
    </table>
    <div class="E_pbtn">
		{if $DETAILSVIEW eq 1}
			<input type="button" class="E_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="AllocatetaccountDetails('{$RECORD}',2)"/><span>&nbsp;</span>
			<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('massallocate');puyoungJS_DialogBox.unblock();"/>
		{else}
			{if $MASSALLOCATE eq 'yes'}
				<input type="button" class="E_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="massAllocate(2)"/><span>&nbsp;</span>
				<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('massallocate');puyoungJS_DialogBox.unblock();"/>
			{else}
				<input type="button" class="E_pbtnok" value="{'CONFIRMED'|@getFixedLabel}" onclick="Allocatetaccount('{$START}','{$RECORD}',2)"/><span>&nbsp;</span>
				<input type="button" class="E_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('signleallocate');puyoungJS_DialogBox.unblock();"/>
			{/if}
		{/if}
    </div>
	</form>