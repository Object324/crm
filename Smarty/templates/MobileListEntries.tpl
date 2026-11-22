<table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
    {* BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
  <tr style="position: sticky; top:0px;z-index:1;">
  	<th>#</th>
    <th align="left" width="120" title="{'ZHPARENTMENUNMAE'|@getFixedLabel}">{'ZHPARENTMENUNMAE'|@getFixedLabel}</th>
    <th align="left" width="120" title="{'ENPARENTMENUNMAE'|@getFixedLabel}">{'ENPARENTMENUNMAE'|@getFixedLabel}</th>
    <th align="left" title="{'SHOWINGRECORDS'|@getFixedLabel}{'MODULE'|@getFixedLabel}">{'SHOWINGRECORDS'|@getFixedLabel}{'MODULE'|@getFixedLabel}</th>
    <th align="left" width="70" title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
  {if $DELBTN eq 'no'}
  	{if $LANGUAGETYPE eq 'en'}
  	<th width="100">{'OPERATING'|@getFixedLabel}</th>
  	{else}
  	<th width="80">{'OPERATING'|@getFixedLabel}</th>
  	{/if}
  {else}
  	{if $LANGUAGETYPE eq 'en'}
  	<th width="130">{'OPERATING'|@getFixedLabel}</th>
  	{else}
  	<th width="125">{'OPERATING'|@getFixedLabel}</th>
  	{/if}
  {/if}
  </tr>
  {$MOBILEMODULEHTML}		
</table>

<script>
    {literal}

    tooltip('.sort-tip-items', {transition: true, time: 200});
    MobileListDragSort();

    {/literal}
</script>