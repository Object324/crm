<div class="ControlDiv2">
    <div class="F_l">
    	<span>{'SELECTMODULE'|@getFixedLabel}</span>
        <select id="reminds_module" onchange="autotaskModule_change(this);">
        {foreach item=tab from=$TABLEARR}
			{if $tab.tabid eq $FLD_TABID}
				{assign var="tabselected" value="selected"}
			{else}
				{assign var="tabselected" value=""}
			{/if}
			<option value="{$tab.tabid}" {$tabselected}>{$tab.tabname}</option>
        {/foreach}
        </select>
    </div>
	<!-- <span class="F_l">{'LBL_AUTOMATIC_TASK'|@getFixedLabel}( {'TOTAL'|@getFixedLabel}:{$COUNT} ) </span> -->
	
    <div class="F_r">
        <input class="createauto" onclick="createauto_click();" type="button" name="New" value="{'ADDLESSIONPLAN'|@getFixedLabel}"/>
    </div>
</div>
<div class="pad10" >

<table class="ControlTable1 listEntries fir-center" width="100%" border="0" cellspacing="1" cellpadding="0">
  <tr>
  	<th>#</th>
	{foreach key=key item=item from=$HEADER}
        {if $key neq 'operating'}
		<th align="left"  title="{$item}">{$item}</th>
        {else}
            {if $LANGUAGETYPE eq 'en'}
            <th align="left" width="220">{$item}</th>
            {else}
            <th align="left" width="180">{$item}</th>
            {/if}
        {/if}
	{/foreach}
  </tr>
  {$ENTITYLIST}
</table>
</div>