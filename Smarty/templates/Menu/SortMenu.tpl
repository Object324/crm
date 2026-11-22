{*@edit:liushuai,2020-8-4,reason:ID1000738/网页端菜单定制优化：增加“菜单排序”功能*}
{*网页端菜单定制-》菜单排序*}
<table class="settingPopTable lasttdbordernon padTB10" width="100%" align="center" cellspacing="0" cellpadding="0" border="0">
    <tr>
        <td width="80%">
            <input type="hidden" name="selectedColumnsString2">
			<input class="detailedViewTextBox" style="width: 100%;" type="text" onkeyup="cls_input_select.getInstance('module')._onkeyup(this,'selectedColumns2',event)" tag="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingformodule'|@getFixedLabel}" name="allmember" /><br>
            <select id="selectedColumns2" multiple="" class="commonMultipleSelect gwidth100 height250" style="margin-top: 5px;" onchange="selectedColumnClick(this);" name="selectedColumns2" size="10" >
                {foreach item=blockinfo key=blockid from=$ALLBLOCKS}
                    <option value="{$blockid}">{$blockinfo.blockname}</option>
                {/foreach}
            </select>
        </td>
        <td align='center' width="50">
            <a class="icon-newhomearr icon-mup" href="javascript:;" title="{'MOVEUP'|@getFIxedLabel}" onclick="ModuleDetailmoveUp('selectedColumns2')"></a><br />
            <a class="icon-newhomearr icon-mdown" style="margin-top: 15px;" href="javascript:;" title="{'MOVEDOWN'|@getFIxedLabel}" onclick="ProductDetailmoveDown('selectedColumns2')"></a>
        </td>
    </tr>
</table>
