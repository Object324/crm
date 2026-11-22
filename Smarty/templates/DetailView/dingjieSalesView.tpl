<style type="text/css">
{literal}
.ui-hide{display:none}
.sales_edit{
	/*position: absolute;float:right;*/
	width:200px;/*margin-top:-24px;*/
}
.sales_edit input[type=text]{
	border: 1px solid #bababa;background-color: #ffffff;box-shadow: inset 0 1px 3px #DDD;border-radius: 3px;padding-left: 3px;margin:0px;width:90px;
}
.sales_edit input[type=text]:focus{
	border-color: #66afe9;outline: 0;
-webkit-box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);
box-shadow: inset 0 1px 1px rgba(0, 0, 0, 0.075), 0 0 8px rgba(102, 175, 233, 0.6);
}
.sales_link a{position: relative;z-index:10;}
.btn{
    /*width: 15px;*/
    cursor: pointer;
    line-height: 15px;
    padding: 0 10px;
	cursor: pointer;
}
.submitbtn{
	background-color: #6b5;
	color: #fff;
	border: 1px solid #6b5;
}
.cancelbtn{
	color: #000;
	background-color: #fff;
    border: 1px solid #e2e2e2;
}
.salesLabel{width:85px;}
.salesinfo{width:155px;}
{/literal}
</style>
<div class="D_pop_tit">
	<input type="hidden" id="dingjie_urlfilter" value="{$URLFILTER}"/>
	<strong class="D_ptita">{'DingjieSales'|@getFixedLabel}: {$FLDVAL}</strong>
    <a href="javascript:fninvshnew('dingjieSalesdiv');" class="D_ptitc">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
    </a>
</div>
<div id='subappcontent'>
<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
	<tr>
	{foreach key=key item=item from=$DETAILARRAY name=dingjieforeach}
		<td nowrap="nowrap" align="right" class="DetailedTd1Label salesLabel">{$item}</td>
        <td class='salesinfo'>{$SALESOBJ.$key|@setItemCode}</td>
		{if $smarty.foreach.dingjieforeach.iteration%$COLUMN==0}
			</tr><tr>
		{/if}
	{/foreach}
    </tr>
</table>
<div class="Tab_div Tab_divBjtop" style='margin-left:17px;'>
	<table width="100%" cellspacing="0" cellpadding="0" border="0">
		<tbody>
			<tr>
				<td class="L" valign="top">
					<ul id='salesdingjieTab'>
						{foreach key=key item=item from=$TRANSACTIONKEYS name=transactionkeys}
							{if $display_index && $display_index > 0}
								{if $display_index == $smarty.foreach.transactionkeys.iteration}
									{assign var="labelOn" value="On"}
								{else}
									{assign var="labelOn" value=""}
								{/if}
							{else}
								{if $smarty.foreach.transactionkeys.first}
									{assign var="labelOn" value="On"}
								{else}
									{assign var="labelOn" value=""}
								{/if}
							{/if}
							<li class='{$labelOn}'>
								<a class='{$labelOn}' href="javascript:void(0);" name="dingjielabel" index="{$smarty.foreach.transactionkeys.iteration}">{$item}</a>
							</li>
						{/foreach}
					</ul>
				</td>
			</tr>
		</tbody>
	</table>
</div>
{foreach key=label item=fieldobj from=$TRANSACTION name=transaction}
	{if $display_index && $display_index > 0}
		{if $display_index == $smarty.foreach.transaction.iteration}
			{assign var="isdisp" value=""}
		{else}
			{assign var="isdisp" value="none"}
		{/if}
	{else}
		{if $smarty.foreach.transaction.first}
			{assign var="isdisp" value=""}
		{else}
			{assign var="isdisp" value="none"}
		{/if}
	{/if}
	
	{if $TRANSACTIONCOUNT.$label}
		{assign var="rowcount" value=$TRANSACTIONCOUNT.$label}
	{else}
		{assign var="rowcount" value=$COLUMN}
	{/if}
	<table class="D_pop_bod salesLast" cellspacing="1" cellpadding="1" border="0" id='transaction_{$smarty.foreach.transaction.iteration}' style='display:{$isdisp}'>
		<tr>
			{foreach key=key item=item from=$fieldobj name=transactionitem}
				<td nowrap="nowrap" align="right" class="DetailedTd1Label salesLabel"{if $item.mode == 'edit'}style='color:#0082CB;'{/if}>{$item.label}</td>
				<td class='salesinfo sales_edit_td' key='{$key}' val='{$SALESOBJ.$key|@setItemCode:$item.uitype}' mode='{$item.mode}'>
					<span class='sales_view'>
						{$SALESOBJ.$key|@setItemCode:$item.uitype}
					</span>
					{if 'edit' == $item.mode}
						<div class='sales_edit ui-hide'>
							<input type="text" key='{$key}' tag='sales' value='{$SALESOBJ.$key|@setItemCode:$item.uitype}' autocomplete="off" maxlength='250'/><br>
							<input class="submitbtn btn" type="button" value="{$LBL_SAVE}" />
							<input class="cancelbtn btn" type="button" value="{$LBL_CANCEL}" />
						</div>
						<span class='sales_link'>
							<a href='javascript:void(0);' class='ui-hide'>{$LBL_EDIT}</a>
						</span>
					{/if}
				</td>
				{if $smarty.foreach.transactionitem.iteration%$rowcount==0}
					</tr><tr>
				{/if}
			{/foreach}
		</tr>
	</table>
{/foreach}
<div style='max-height:300px;overflow-y:auto;margin-left:17px;'>
<table class="ProductTab salesLast" cellspacing="1" cellpadding="1" border="0" width="160%">
	<tr class='Tdhead'>
		<!-- <td nowrap="nowrap" class="DetailedTd1Label">{'SEQUENCE'|@getFixedLabel}</td> -->
		{foreach key=key item=item from=$PRODUCTARRAY}
			<td nowrap="nowrap" class="DetailedTd1Label salesLabel" {if $item.mode == 'edit'}style='color:#0082CB;'{/if}>{$item.head}</td>
		{/foreach}
	</tr>
	{foreach key=prodkey item=prodobj from=$PRODUCTOBJ name=productobj}
		<tr>
			<!-- <td>{$smarty.foreach.productobj.iteration}</td> -->
			{foreach key=key item=prod from=$PRODUCTARRAY name=productarray}
				{assign var="fld" value=$prod.fld}
				{assign var="uitype" value=$prod.uitype}
					
				<td class='salesinfo sales_edit_td' key='{$fld}' val='{$prodobj.$fld|@setItemCode:$prod.uitype}' mode='{$prod.mode}'>
					<span class='sales_view'>
						<nobr>{$prodobj.$fld|@setItemCode:$prod.uitype}</nobr>
					</span> 
					{if 'edit' == $prod.mode}
						<div class='sales_edit ui-hide'>
							{if 'tssl' == $fld}
								<input type="text" key='tssl' tag='prod' value='{$prodobj.$fld|@setItemCode:$uitype}' autocomplete="off" maxlength='250'/><br>
								<input class="submitbtn btn" type="button" value="{$LBL_SAVE}" />
								<input class="cancelbtn btn" type="button" value="{$LBL_CANCEL}" />
							{else}
							<input type="text" key='{$key}' tag='prod' value='{$prodobj.$fld|@setItemCode:$uitype}' autocomplete="off" maxlength='250'/><br>
							<input class="submitbtn btn" type="button" value="{$LBL_SAVE}" />
							<input class="cancelbtn btn" type="button" value="{$LBL_CANCEL}" />
							{/if}
						</div>
						<span class='sales_link'>
							<a href='javascript:void(0);' class='ui-hide'>{$LBL_EDIT}</a>
						</span>
					{/if}
				</td>

				<!-- <td>
					{$prodobj.$fld|@setItemCode:$uitype}
				</td> -->
			{/foreach}
		</tr>
	{/foreach}
</table>
<br>
</div>
</div>