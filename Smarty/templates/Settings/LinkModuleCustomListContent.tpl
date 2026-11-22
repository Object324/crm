<div class="">	
    <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
{*         BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
        <tr style="position: sticky; top:0px;z-index:1;">
          	<th>#</th>
            <th align="left" title="{'CNTAG'|@getFixedLabel}">{'CNTAG'|@getFixedLabel}</th>
            <th title="{'ENTAG'|@getFixedLabel}">{'ENTAG'|@getFixedLabel}</th>
            <th title="{'ModuleIcon'|@getFixedLabel}" width="200px">{'ModuleIcon'|@getFixedLabel}</th>
            <th title="{'APPLICABLESCOPE'|@getFixedLabel}">{'APPLICABLESCOPE'|@getFixedLabel}</th>
            {if $LANGUAGETYPE eq 'en'}
            <th width="170">{'OPERATING'|@getFixedLabel}</th>
            {else}
            <th width="150">{'OPERATING'|@getFixedLabel}</th>
            {/if}
        </tr>
        {assign var="i" value=0}
		{foreach name=printlist item=listinfo from=$List}
            {assign var="printlistNum" value=$smarty.foreach.printlist.iteration }
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}   
    		<td>{$printlistNum}</td>
    	 	<td>
                {$listinfo.zh_label}
    		</td>
    		<td>
                {$listinfo.en_label}
    		</td>
            <td>
                {if $listinfo.active_icon!=''}
                <img style="width:30px;" src="{$listinfo.active_icon}">
                {/if}
            </td>
            <td>
                {$listinfo.allocatename}
            </td>
            <td>
			  	<a class="Anu3_a" href="javascript:;" tag="{$listinfo.id}" name="edit">{'EDIT'|@getFixedLabel}</a>	
		        <a class="Anu3_a" href="javascript:;" tag="{$listinfo.id}" name="allocate" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,'0','{$listinfo.id}','{$listinfo.allocateids}','{$listinfo.scopetype}','LinkModuleCustom');">{'ALLOCATE'|@getFixedLabel}</a>
                <a class="Anu3_a redFont" href="javascript:;" tag="{$listinfo.id}" name="delete">{'DELETE'|@getFixedLabel}</a>
		    </td>
	    </tr>
	    {/foreach}
	</table>
</div>