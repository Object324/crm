<div class="">	
    <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
        <tr>
          	<th>#</th>
            <th title="{'Name'|@getFixedLabel}">{'Name'|@getFixedLabel}</th>
            <th title="{'Mobile'|@getFixedLabel}">{'Mobile'|@getFixedLabel}</th>
            <th title="{'WHETHERTODISPLAY'|@getFixedLabel}">{'WHETHERTODISPLAY'|@getFixedLabel}</th>
            <th width="230px">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        
        {assign var="i" value=0}
        {assign var="maxcount" value = $List|@count}
        {if count($List) eq 0 && count($custelno) eq 0}
        <tr>
            <td align="center" colspan="5">
                {'NORECORDSAREFOUND'|@getFixedLabel}
            </td>
        </tr>
        {/if}
		{foreach name=printlist item=listinfo from=$List}
            {assign var="printlistNum" value=$smarty.foreach.printlist.iteration }
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));" >
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));" >
            {/if}   
    		<td>{$printlistNum}</td>
            <td align="left" >
                {$listinfo.name|@getFixedLabel}
    		</td>
    	 	<td>
                {$listinfo.phone|@getFixedLabel}
    		</td>
    		<td>      
                {if $listinfo.status eq 'yes'}
                <input type="checkbox" tag="{$listinfo.phoneid}" name="inactivate" onclick="PhoneSettingsOperate(this,'inactivate',{$listinfo.phoneid})" class="second_switch" checked='' />
                {elseif $listinfo.status neq 'yes'}
                <input type="checkbox" tag="{$listinfo.phonelid}" name="activate" onclick="PhoneSettingsOperate(this,'activate',{$listinfo.phoneid})" class="second_switch"/>
                {/if}
    		</td>
            <td>
			  	<a class="Anu3_a" href="#" tag="{$listinfo.phoneid}" onclick="PhoneSettings_edit(this,'edit',{$listinfo.phoneid})" name="edit">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a redFont" tag="{$listinfo.phoneid}" name="delete" onclick="PhoneSettingsOperate(this,'delete',{$listinfo.phoneid})">{'DELETE'|@getFixedLabel}</a>
                <a class="Anu3_a" tag="{$listinfo.phoneid}" {if $printlistNum eq 1} style="display:none;" {/if} name="moveup" onclick="PhoneSettingsOperate(this,'moveup',{$listinfo.phoneid})">{'MOVEUP'|@getFixedLabel}</a>
                <a class="Anu3_a" tag="{$listinfo.phoneid}" {if $printlistNum eq $maxcount} style="display:none;" {/if} name="movedown" onclick="PhoneSettingsOperate(this,'movedown',{$listinfo.phoneid})">{'MOVEDOWN'|@getFixedLabel}</a>
		    </td>
	    </tr>
	    {/foreach}
	</table>
</div>
<div class="dvpopupsroll" style="display: none;" ></div>