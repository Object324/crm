<div class="cont_wrap clear_float">
    <table class="settingTable fir-center" border=0 cellspacing=0 cellpadding=5 width=100%>
        {* BUG0068275 txy 2023.06.18 固定表头加滚动时表头加阴影*}
        <tr style="position: sticky; top:0px;z-index:1;">
            <th>#</th>
            <th title="{'PARENTMENU'|@getFixedLabel}{'CHINESE'|@getFixedLabel}">{'PARENTMENU'|@getFixedLabel}{'CHINESE'|@getFixedLabel}</th>
            <th title="{'PARENTMENU'|@getFixedLabel}{'ENGLISH'|@getFixedLabel}">{'PARENTMENU'|@getFixedLabel}{'ENGLISH'|@getFixedLabel}</th>
            <th title="{'UnselectedIcon'|@getFixedLabel}">{'UnselectedIcon'|@getFixedLabel}</th>
            <th title="{'SelectedIcon'|@getFixedLabel}">{'SelectedIcon'|@getFixedLabel}</th>
            <th style="display: none;" title="{'DISPLAYORDER'|@getFixedLabel}">{'DISPLAYORDER'|@getFixedLabel}</th>
            <th title="{'WHETHERTOENABLE'|@getFixedLabel}">{'WHETHERTOENABLE'|@getFixedLabel}</th>
            {if $LANGUAGETYPE eq 'en'}
              <th width="120">{'OPERATING'|@getFixedLabel}</th>
            {else}
              <th width="100">{'OPERATING'|@getFixedLabel}</th>
            {/if}
        </tr>
        {assign var="menu" value='1'}
        {assign var="i" value=0}
        {foreach name=menu item=value from=$MENU}
        {assign var="j" value=$i++}
        {if $j mod 2 eq '0'}
        <tr id="setting_{$j}" class="lvtColData ld-category-draggable" tag="{$value.parenttabid}" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
        {else}
        <tr id="setting_{$j}" class="lvtColDataBj ld-category-draggable" tag="{$value.parenttabid}" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
        {/if}
        <td>{$menu}</td>
        <td>
            <span id="parentchinese_{$value.parenttabid}" title="{$value.name.zh}">{$value.name.zh}</span>
        </td>
        {*
            /**
             *@edit:andy
             *@date:20140821
             *@reason:0010840: 控制面板>模块管理、页面设置：列头调整“模块（中文)、模块（英文）”
             *@version:version v5.61
             */
        *}
        <td>
            <span id="parentenglish_{$value.parenttabid}" title="{$value.name.en}">{$value.name.en}</span>
        </td>
        <td style="display: none;">
            <span id="parentindex_{$value.parenttabid}" title="{$value.sequence}">{$value.sequence}</span>
        </td>
        <td>
            {if $value.inactive_icon}
            <div style="width:  40px;height:40px;">
                <img src="{$value.inactive_icon}" class="Logo" style="width: 40px;height: 40px;">
            </div>
            {/if}
        </td>
        <td>
            {if $value.active_icon}
            <div style="width:  40px;height:40px;">
                <img src="{$value.active_icon}" class="Logo" style="width: 40px;height: 40px;">
            </div>
            {/if}
        </td>
        {*
            增加显示列： 是否显示
            by andy
            reason:8568 0008568: 控制面板 > 菜单定制界面：序列表中，增加一列：是否显示
        *}
        <td>
            <input type="checkbox" onclick="change_tablefield_presence(this,{$value.parenttabid},'parenttab')" class="second_switch" 
            {if $value.visible eq '0'}checked=""{/if} {if $value.parenttab_label eq 'Settings'}disabled{/if} />
        </td>
        <td width="160px">
            {if $value.parenttab_label eq "Settings"}
            <a class="Anu3_a" href="javascript:void(0)" onclick="editMenuList8({$value.parenttabid})">{'EDIT'|@getFixedLabel}</a>
            {else}
            <a class="Anu3_a" href="javascript:void(0)" onclick="editMenuList({$value.parenttabid})">{'EDIT'|@getFixedLabel}</a>
            {/if}

            {if $value.parenttab_label neq "Settings"}
                <a class="Anu3_a" btn="editBtn" record="{$value.parenttabid}" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,'0','{$value.parenttabid}','{$value.allocateid}','{$value.allocatetype}','MenuList');">{'ALLOCATE'|@getFixedLabel}</a>
            {/if}

            {if $value.allow_delete eq "yes"}
{*                //XUQIU20240823-04 网页端菜单定制增加删除功能 wsh 20240826*}
            <a class="Anu3_a redFont" href="javascript:void(0)" onclick="DeleteMenuList({$value.parenttabid})">{'DELETE'|@getFixedLabel}</a>
            {/if}
            {if $value.allow_sort neq 'no'}
                <a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="left" data-type="position" style="display:none;cursor:move;"></a>
            {/if}
        </td>
        </tr>
        {assign var="menu" value=$menu+1}
        {/foreach}
    </table>
</div>

<script>
    {literal}

    tooltip('.sort-tip-items', {transition: true, time: 200});
    MenuListDragSort();

    {/literal}
</script>