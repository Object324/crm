<div style="height: 400px;overflow: auto;clear:both;">	
	<form name="basicSearch" action="index.php">
	    <input type="hidden" name="searchtype" value="BasicSearch">
		<input type="hidden" name="module" value="Users">
		<input type="hidden" name="action" value="UsersAjax">
		<input type="hidden" name="ajax" value="true">
		<input type="hidden" name="selectmodule" id="selectmodule" value="{$SELECTMODULE}">
        <input type="hidden" name="frommodule" id="frommodule" value="{$FROMMODULE}">
        <input type="hidden" name="faqid_string" id="faqid_string" value = "" />
		<input type="hidden" name="faqno_string" id="faqno_string" value = "" />
		<input type="hidden" name="picklisttype" id="picklisttype" value="{$PICKLISTTYPE}" />
        <table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0">
		<!--{if $PICKLISTTYPE eq 0} style="display:none;" {/if}-->
			{if $TICKETARR neq ''}
				<tr>
					<td class="DetailedTd1Label" width="10%" align="right">{$TICKETARR.faqcategory_label}</td>
					<td width="90%" align="left">
						<table class="qs-tab" width="100%" border="0" cellspacing="0" cellpadding="0" align="left" border="0" style="border:none;">
						{foreach item=tick_row_value key=row from=$TICKETARR.faqcategory}
							<tr>
							{foreach item=tickvalue from=$tick_row_value}
								<td width="109">
								{if $tickvalue neq ''}
								<input type="checkbox" onclick="getFaqTypeValue(this,'{$FROMMODULE}','{$SELECTMODULE}')" id="select_faqcategory" name="select_faqcategory" value="{$tickvalue}"  />&nbsp;{$tickvalue} &nbsp;&nbsp;
								{else}
								&nbsp;
								{/if}
								</td>
							{/foreach}
							</tr>
						{/foreach}
						</table>
					</td>
				</tr>
			{/if}
			{if $FAQTYPE neq ''}
				<tr id="faqtype_Style" {if $FAQTYPE.faqtype eq ''}style="display:none;"{else}style="display:;"{/if}>
					<td class="DetailedTd1Label" width="10%" align="right">{$FAQTYPE.faqtype_label}</td>
					<td width="90%" align="left">
						<div name="ListViewFaqtype">
						{include file="SelectRelatedFaqType.tpl"}
						</div>
					</td> 
				</tr>
			{/if}
			{if $QUESTIONLABEL neq ''}
				<tr id="contents_Style" style="display:none;height:225px;">
					<td class="DetailedTd1Label" width="10%" align="right">{$QUESTIONLABEL}</td>
					<td width="90%" align="left"valign="top">
						
						<div name="ListViewContents" style="max-width:662px;overflow-x: auto;">
								{include file="SelectRelSpecialPopupContents.tpl"}
						</div>
					</td>
				</tr>
			{/if}
			{if $DESCRIPTIONLABEL neq ''}
				<tr id="description_Style" style="display:none">
					<td class="DetailedTd1Label" width="10%" align="right">{$DESCRIPTIONLABEL}</td>
					<td width="90%" align="left">
						<textarea id="question_description" disabled="disabled" class="detailedViewTextBox" style="width:100%; height: 80px; overflow-y: auto; word-wrap: break-word;" cols="90" name="question_description" fieldonly="0" tabindex=""></textarea>
					</td>
				</tr>
			{/if}
			{if $SOLUTIONLABEL neq ''}
				<tr id="answer_Style" style="display:none">
					<td class="DetailedTd1Label" width="10%" align="right">{$SOLUTIONLABEL}</td>
					<td width="90%" align="left">
						<textarea id="answer" disabled="disabled" class="detailedViewTextBox" style="width:100%; height: 80px; overflow-y: auto; word-wrap: break-word;" cols="90" name="answer" fieldonly="0" tabindex=""></textarea>
					</td>
				</tr>
			{/if}
		</table>
   	</form>
</div>