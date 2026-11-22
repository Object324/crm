{*<!--
/*+********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div>
    <div class="categorytree-title">{'RemindsType'|@getFixedLabel}</div>
    <div id="categorytree" class="categorytree-list">
        <input type="hidden" id="isshowModuleListTree" value="yes" />
        {foreach key=index item=viewinfo from=$Category_arr}
            <div class="ld-listview-left-categorytree-block 
                {if $viewinfo.remindscategoryid eq $selected_remindscategoryid}
                    ld-listview-left-categorytree-block-active 
                {/if}"
                data-remindscategoryid="{$viewinfo.remindscategoryid}" onclick="CrmPopup.getlastPopupObjByType(ListPagePopup.type).clsremindsobj.changeListCategory(this);">
                <span class="category-name 
                    {if $viewinfo.remindscategoryid eq $selected_remindscategoryid}
                        category-name-active 
                    {/if}" data-tip="{$viewinfo.viewname}" onmouseenter="tooltip.bind(this)">
                    {$viewinfo.viewname} {if $show_customview_num eq 'yes'}({$viewinfo.newreminds_num}){/if}
                </span>
            </div>
        {/foreach}
        
    </div>
</div>
