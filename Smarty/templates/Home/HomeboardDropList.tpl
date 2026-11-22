<ul id="sortable-list" style="max-height: 240px;overflow: hidden auto;">
    {if $isHaveDefaultKanban=='yes'}
        <li>
            {*								//@edit:ljj,2023-08-04,reason:BUG0070614  kfbcrm-首页-默认看板没有icon图标*}
            {if $Home_boardid eq ''}
                <div style="background: url('themes/icon/homeboard.png');background-size: 100% 100%;" class="home_icon"></div>
            {/if}
            <div onclick="Homeboard_changing_over(0)" class="homeboard_label" style="margin-left: 31px;">{'Default_Kanban'|@getFixedLabel}</div>
            {if $ISADMIN eq 1}
                <div class="ld_homeboard_head_select_edit home-header-top-setting"><a>{'OldKanban'|@getFixedLabel}</a></div>
            {/if}
        </li>
    {/if}
    {foreach item=boardname key=boardid from=$HOMEBOARDLISTNEW}
        <li class="ld-category-draggable" data-boardid="{$boardid}">
            <div onclick="Homeboard_changing_over({$boardid})" {if $Home_boardid != $boardid}style="margin-left:31px;"{/if} class="homeboard_label" title="{$boardname}">
                {if $Home_boardid == $boardid}
                    <div style="background: url('themes/icon/homeboard.png');background-size: 100% 100%;" class="home_icon"></div>
                {/if}
                {$boardname}
            </div>
            {if $ISADMIN eq 1}
                <div class="ld_homeboard_head_select_edit">
                    <i onclick="editHomeboard({$boardid},'Home')" class="ld-fonticon ld-fonticon-edit valign-middle"></i>
                    <b class="ld-category-icon ld-category-drag drag-handle" style="cursor: move;" ></b>
                </div>
            {/if}
        </li>
    {/foreach}
</ul>
{if $ISADMIN eq 1}
    <div style="margin: 0 8px;background: #cecece;height: 1px;"></div>
    <ul>
        <li onclick="editHomeboard(0,'Home')">
            <div style="background: url('themes/icon/homeboard_new.png');background-size: 100% 100%;" class="home_icon"></div>
            {'New_Data_Kanban'|@getFixedLabel}
        </li>
        <li onclick="HomeboardListview('Home')">
            <div style="background: url('themes/icon/homeboard_list.png');background-size: 100% 100%;" class="home_icon"></div>
            {'Management_Data_Kanban'|@getFixedLabel}
        </li>
    </ul>
{/if}
<div class="ld_homeboard_select_icon" style="left: 150px;"></div>