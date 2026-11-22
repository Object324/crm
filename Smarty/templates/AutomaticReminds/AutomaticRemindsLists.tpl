<table class="settingTable fir-center" width="100%" border="0" cellspacing="0" cellpadding="0" name="autoRemindSetTable">
    <tr>
        <th>#</th>
        <th title="{'RULENAME'|@getFixedLabel}">{'RULENAME'|@getFixedLabel}</th>
        <th title="{'REMINDTIME'|@getFixedLabel}">{'REMINDTIME'|@getFixedLabel}</th>
        <th title="{'REPEATTIME'|@getFixedLabel}">{'REPEATTIME'|@getFixedLabel}</th>
        <th title="{'REMINDMODEL'|@getFixedLabel}">{'REMINDMODEL'|@getFixedLabel}</th>
        <th title="{'REMINDERPEOPLE'|@getFixedLabel}" style="width:30%">{'REMINDERPEOPLE'|@getFixedLabel}</th>
        <th title="{'WHETHERTOENABLE'|@getFixedLabel}" style="width:10%">{'WHETHERTOENABLE'|@getFixedLabel}</th>
        {if $LANGUAGETYPE eq 'en'}
        <th width="140">{'OPERATING'|@getFixedLabel}</th>
        {else}
        <th width="120">{'OPERATING'|@getFixedLabel}</th>
        {/if}
    </tr>
    {if $AUTOMATICREMINDS|@count gte 1}
        {assign var="i" value=0}
        {foreach key=value item=reminds name=automatic from=$AUTOMATICREMINDS}
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData ld-category-draggable" tagid="{$reminds.id}" tabid="{$reminds.tabid}" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj ld-category-draggable" tagid="{$reminds.id}" tabid="{$reminds.tabid}" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if} 
            <td>{$value+1}</td>
            <td><a href="javascript:;" onclick="AutomaticReminds.viewRemindsRule({$reminds.id},{$reminds.tabid})"><span title="{$reminds.name}">{$reminds.name}</span></a></td>
            <td><span title="{$reminds.columnname}">{$reminds.columnname}</span></td>
            {if $reminds.remindway eq '3'}
                <td><span title="1">1</span></td>
            {else}
                <td><span title="{$reminds.remindnum}">{$reminds.remindnum}</span></td>
            {/if}
            <td>
                {if $reminds.remindway eq 1}
                <font><span title="{'FIXEDCYCLE'|@getFixedLabel}">{'FIXEDCYCLE'|@getFixedLabel}</span></font>
                {else if $reminds.remindway eq '3'}
                    <font><span title="{'ANNUALREMIND'|@getFixedLabel}">{'ANNUALREMIND'|@getFixedLabel}</span></font>
                {else}
                <font><span title="{'APPOINTCYCLE'|@getFixedLabel}">{'APPOINTCYCLE'|@getFixedLabel}</span></font>
                {/if}
            </td>
            <td>
                <font>{$reminds.reminder}</font>       
            </td>
            <td>
                {if $reminds.status eq 1}
                    <input type="checkbox" onclick="change_tablefield_presence(this,{$reminds.id},'automaticreminds_status')" class="second_switch"  checked="" />
                {else}
                    <input type="checkbox" onclick="change_tablefield_presence(this,{$reminds.id},'automaticreminds_status')" class="second_switch"  />
                {/if}
            </td>
            <td>
                <a class="Anu3_a" href="javascript:void(0);" onclick="AutomaticReminds.editRemindsRule({$reminds.id},{$reminds.tabid});">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a redFont" href="javascript:void(0);" onclick="AutomaticReminds.ControllReminds({$reminds.id},{$reminds.tabid},3)">{'DELETE'|@getFixedLabel}</a>
                <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}" data-direction="left" data-type="position" style="display: none; cursor:move;margin-top:2px"></a>
            </td>
          </tr>
        {/foreach}
    {else}
        <tr class="lvtColData">
            <td colspan="8" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
        </tr>
    {/if}
</table>

