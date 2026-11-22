<div class="PrompLeft">
    <input type="hidden" name="alluserid" id="alluserid" value="{$ALLUSERID}" />
    <input type="hidden" name="allmouth" id="allmouth" value="{$ALLYEARMOUTH}" />
	<input type="hidden" name="module_look" value="{$MODULELOOK}">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
          <tr>
            <th>{'MONTH'|@getFixedLabel}</th>
          </tr>
          <tr>
            <td>{'LBL_USERS'|@getFixedLabel}</td>
          </tr>
          {foreach key=user_id item=users from=$USERS}
            <tr>
                <td class="tip-items-goal" data-tip='{$users}' data-direction="top" data-type="position">
                  <!--<input type="checkbox" name="bechosed" id="bechosed{$user_id}" value="{$user_id}" checked />-->
                  {$users}
                </td>
            </tr>
          {/foreach}
        </table>
    </div>
    <div id="listcenter" style="display:block;" class="PrompCenter">
		<table width="100%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
          <tr>
            {foreach key = menu_mouth_id item=mouth_id from=$YEARMOUTH}
                <th wdith="8&">
                {$mouth_id}
                </th>
            {/foreach}
          </tr>
          <tr class="TrBj">
            {foreach key = menu_mouth_id item=mouth_id from=$MOUTH}
				{if $MODULELOOK eq 'contractamount'}
					<td>{'CONTRACTAMOUNTS'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'paymentamount'}
					<td>{'THEAMOUNTOFBACK'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'accountsnumber'}
					<td>{'THECUSTOMERNUMER'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'invoiceamount'}
					<td>{'Invoiceamount1'|@getFixedLabel}</td>
				{elseif $MODULELOOK eq 'outboundorderamount'}
					<td>{'outamount'|@getFixedLabel}</td>
                {elseif $MODULELOOK eq 'receivableamount'}
                    <td>{'receivableamount'|@getFixedLabel}</td>
				{/if}
            {/foreach}
          </tr>
          {$SALESGOALINFO}
        </table>
    </div>
    <div class="PrompRight">
		<table width="{$TABLEWIDTHAFTER}%" border="0" cellspacing="1" cellpadding="0" style="background:#ddd">
          <tr>
            <th>{'SUM'|@getFixedLabel}</th>
          </tr>
          <tr class="TrBj">
			{if $MODULELOOK eq 'contractamount'}
				<td>{'CONTRACTAMOUNTS'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'paymentamount'}
				<td>{'THEAMOUNTOFBACK'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'accountsnumber'}
				<td>{'THECUSTOMERNUMER'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'invoiceamount'}
				<td>{'Invoiceamount1'|@getFixedLabel}</td>
			{elseif $MODULELOOK eq 'outboundorderamount'}
				<td>{'outamount'|@getFixedLabel}</td>
            {elseif $MODULELOOK eq 'receivableamount'}
                <td>{'receivableamount'|@getFixedLabel}</td>
			{/if}
          </tr>
            {$SALESGOALSUM}
        </table>
    </div>