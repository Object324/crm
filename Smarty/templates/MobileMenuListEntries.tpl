<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
    {* BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
	<tr style="position: sticky; top:0px;z-index:1;">
		<th>#</th>
		<th align="left" title="{'linenumber'|@getFixedLabel}">{'linenumber'|@getFixedLabel}</th>
		<th align="left" title="{'rownumber'|@getFixedLabel}">{'rownumber'|@getFixedLabel}</th>
		<th align="left" title="{'LBL_FIELDNAME'|@getFixedLabel}">{'LBL_FIELDNAME'|@getFixedLabel}</th>
		<th align="left" title="{'WHETHERTOENABLE'|@getFixedLabel}" width="15%">{'WHETHERTOENABLE'|@getFixedLabel}</th>
		<th align="left" title="{'MOBILELISTSHOWFIELDNAME'|@getFixedLabel}" width="15%">{'MOBILELISTSHOWFIELDNAME'|@getFixedLabel}</th>
		<th align="left" title="{'WhetherQueryBasedOnField'|@getFixedLabel}" width="15%">{'WhetherQueryBasedOnField'|@getFixedLabel}</th>
		{if $LANGUAGETYPE eq 'en'}
			<th width="110">{'OPERATING'|@getFixedLabel}</th>
		{else}
			<th width="100">{'OPERATING'|@getFixedLabel}</th>
		{/if}
	</tr>
  {$MOBILEMODULEHTML}		
</table>