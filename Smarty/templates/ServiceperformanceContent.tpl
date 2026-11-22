<div>
    <table border=0 cellspacing=0 cellpadding=0 width=100% class="settingTable fir-center">
        <tr style="position: sticky; top:0px;z-index:1;">
            <th>#</th>
            {foreach item=value name=first key=id from=$TABHEARD}
            {if $smarty.foreach.first.iteration eq '1'}
            <th align="left" width="400" title="{$value}">{$value}</th>
            {else}
            <th align="left" title="{$value}">{$value}</th>
            {/if}
            {/foreach}
            <th width="50">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        {if $LIST_ENTRIES|@is_array && $LIST_ENTRIES|@count gte 1}
            {assign var="i" value=0}
            {foreach name=serverlist item=servervalues key=id from=$LIST_ENTRIES}
            {assign var="serverlistNum" value=$smarty.foreach.serverlist.iteration }
            {assign var="j" value=$i++}
            {if $j mod 2 eq '0'}
                <tr id="setting_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
                <tr id="setting_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}   
                <td>{$serverlistNum}</td>
                <td><span title="{$servervalues.name}">{$servervalues.name}</span>
                </td>
                <td>
                    <div id='seetxtbox_{$servervalues.id}' style="display:block;"><span title="{$servervalues.scores|@setNumberFormat}">{$servervalues.scores|@setNumberFormat}</span></div>
                    <div id="editarea_{$servervalues.id}" style="display:none;" class="modulecontrolldiv">
                        <input id="txtbox_{$servervalues.id}" class="detailedViewTextBox" style="width:150px;float:left;" type="text" value="{$servervalues.scores}" maxlength="100" name="modulename"/>
                        <div>
                            <a class="Anu3_a" style="margin-left:3px;margin-top: 3px;" href="javascript:void(0);" onclick="vtlib_saveServercount({$servervalues.scores},{$servervalues.id})">{'SAVE'|@getFixedLabel}</a>
                            <a class="Anu3_a" style="margin-top: 3px;" href="javascript:void(0);" onclick="vtlib_showeditinput_Server(2,{$servervalues.id},{$servervalues.scores});" >{'CANCEL'|@getFixedLabel}</a>
                        </div>
                    </div>
                </td>
                <td>
                  <a onclick="vtlib_showeditinput_Server(1,{$servervalues.id},'{$servervalues.scores}');" href="javascript:void(0);" class="Anu3_a">{'EDIT'|@getFixedLabel}</a>
                </td>
            </tr>
            {/foreach}
        {else}
            <tr class="lvtColData">
                <td colspan="4" align="center">{'NOTFOUNDANYRECORD'|@getFixedLabel}</td>
            </tr>
        {/if}
    </table>
</div>