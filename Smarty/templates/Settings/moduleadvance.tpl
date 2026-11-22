<!-- 自动任务设置栏 -->
{if sizeof($ALLADVANCE)>0 && $MODULEADVANCE['method'] neq 'period'&&true}
<table border="0" cellspacing="0" cellpadding="0" width="100%" class="DetailContentTable linefeed">
	<tbody><tr>
		<td colspan="4" class="editrelhead">
            <b>{"PROCESSSETTINGS"|@getFixedLabel}</b>
		</td>
        
	</tr>
    <tr>
        <td colspan="4" >
			<span>{"SETADVANCERELATION"|@getFixedLabel}</span>
		</td>
    </tr>
    </tbody>
</table>
<div style="overflow-x:auto;" id="wheeldiv">
<table class="settingadvaceTable" border="0" cellpadding="0" cellspacing="0" id="wheeldivtable">
    <tbody>
    {assign var=clsname  value='lvtColData'}
    <tr class="{$clsname}" onmouseover="this.className = 'lvtColDataHover';" onmouseout="this.className = '{$clsname}';" >
        <td style="min-width:200px;white-space:normal;position: sticky;left: 0px;background-color: #f4f4f4;" align="left" class="lefttd"></td><td class="lefttdnext"></td>
        {foreach item =stagename key=stagenum  from = $ALLADVANCE}
            <td style="min-width:120px;white-space:normal;" align="left">{$stagename}</td>
        {/foreach}
    </tr>
    {foreach item =stagename_start key=stagenum_start  from = $ALLADVANCE}
        {assign var=tmp_str value="FROMPUSHTO"|@getFixedLabel}
        {if $stagenum_start mod 2 eq 0 }
            {assign var=clsname  value='lvtColData'}
        {else}
            {assign var=clsname  value='lvtColDataBj'}
        {/if}
        <tr  class="{$clsname}" onmouseover="this.className = 'lvtColDataHover'" onmouseover="this.className = 'lvtColDataHover';" onmouseout="this.className = '{$clsname}';" >
            <td  align="left" style="white-space:nowrap;position: sticky;left: 0px;background-color: #f4f4f4;" class="lefttd" border-right="1px">
            
            <span>{$tmp_str|@sprintf:$stagename_start}</span>
            <input type="hidden" name="stagename" stagenum="{$stagenum_start}" value="{$stagename_start}"></td><td class="lefttdnext"></td>
            {foreach item =stagename key=stagenum  from = $ALLADVANCE}
                {if isset($ADVANCERELATION.$stagename_start.$stagename.presence)}
                    {assign var= presence value = $ADVANCERELATION.$stagename_start.$stagename.presence}
                    {assign var= advanceid  value = $ADVANCERELATION.$stagename_start.$stagename.advanceid}
                    {assign var= bclass  value = $ADVANCERELATION.$stagename_start.$stagename.classname}
                {else}
                    {assign var= presence value = 1}
                    {assign var= advanceid  value = 0}
                    {assign var= bclass  value = 'icon-emptywrenchhand'}
                {/if}
                {if $stagename_start eq $stagename}
                    <td><div style="width:13px;height:13px;background-color: #c6c0c0;border-radius: 15%;"></div></td>
                {else}
                    <td>
                    <input onclick="AdvanceRelation.save(this)" type="checkbox" stagenum_start="{$stagenum_start}" stagenum_target="{$stagenum}" {if $presence eq 'yes'}checked{/if} >
                    <b onclick="AdvanceRelation.EditInfo(this)" class="{$bclass}" style="cursor:pointer;position:inherit;margin-left: 6px;{if $presence neq 'yes'}display:none;{/if}" advanceid="{$advanceid}" ></b>
                    </td>
                {/if}
                
            {/foreach}
        </tr>
    {/foreach}
    </tbody>
</table>
</div>
{/if}
