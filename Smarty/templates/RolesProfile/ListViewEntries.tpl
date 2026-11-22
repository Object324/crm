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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="javascript" src='include/js/ajax.js'></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Roles.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/component/ld_NavBar.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="include/js/multipingyin.js?v={$GLOBALMINVERSION}"></script>

<div class="ld-rolesprofile-listviewleft-container" id="RolesProfile">
    <div class="ld-listview-left-categorytree" id="ListViewLeft" style="width: 10%;min-width: 200px;">
        <div class="categorytree-title" id="categorytree_title">
            {'RoleName2'|@getFixedLabel}
        </div>
        <div class="ld-rolesprofile-search" id="rolesprofile_earch" style="margin: 0px 8px 16px 8px;">
            <span class="leftmenu-fonticon">&#xe623;</span>
            <input class="ld-input-inner" id="search_roles" type="text" placeholder="{'SearchRolename'|@getFixedLabel}" autocomplete="off">
            <b class="ld-icon-clearsearch" id="clear_search_roles" style="position: absolute; right: 0px; top: 0px; cursor: pointer; visibility: visible;display: none;"></b>
        </div>
        <div id="categorytree" class="categorytree-list">

            {foreach key=profileid item=roleinfo from=$allRolesBaseInfo_arr}
                <div class="ld-listview-left-categorytree-block 
                    {if $roleinfo.profileid eq $selected_profileid}
                        ld-listview-left-categorytree-block-active 
                    {/if}"
                    name="roleblock_div" data-profileid="{$roleinfo.profileid}">
                    <span class="category-name 
                        {if $roleinfo.profileid eq $selected_profileid}
                            category-name-active 
                        {/if}" data-tip="{$roleinfo.profilename}" onmouseenter="tooltip.bind(this)">
                        {$roleinfo.profilename}
                    </span>
                    <div>
                        <div class="groupuser-treediv-btn" name="operate_group">
                            <a class="gutree-btn_moveup" name="movebtn" tag="moveup" title="{'MOVEUP'|@getFixedLabel}" style="margin-top: 0px;"></a>
                            <a class="gutree-btn_movedowm" name="movebtn" tag="movedown" title="{'MOVEDOWN'|@getFixedLabel}" style="margin-top: 0px;"></a>
                            <a class="gutree-btn_more btn-more" name="btn_more" data-profileid="{$roleinfo.profileid}" title="{'MORE'|@getFixedLabel}"></a>
                        </div>
                    </div>
                </div>
            {/foreach}
            <div id="role-libutton-box" class="user-libutton-box" style="display: ;overflow: hidden;height: auto;">
                <div class="user-libutton-body">
                    <ul class="user-libutton-list">
                        <li><a href="javascript:;" name="editrole"><span>{'EditRolename'|@getFixedLabel}</span></a></li>
                        <li><a href="javascript:;" name="deleterole" class="redFont"><span>{'DELETE'|@getFixedLabel}</span></a></li>
                    </ul>
                </div>
            </div>
        </div>
        <div id="btnarea" class="ld-rolesprofile-listviewleft-btnarea">
            <input name="createrole" class="ld-button ld-button-primary" id="" value="{'AddRole'|@getFixedLabel}" tagclick="" type="button">
            <input name="copyrole" class="ld-button" id="" value="{'COPY'|@getFixedLabel}" type="button" style="margin-left: 8px !important;">
        </div>
    </div>
    <div style="width: 90%;" id="ListViewRight">
        {include file="RolesProfile/ListViewRight.tpl"}
    </div>
</div>
<script>
    CrmPopup.global_listPopupObj = [];
    var popupobj = new Object();
    popupobj.divid = "RolesProfile";
    CrmPopup.global_listPopupObj.push(popupobj);
    popupobj.CancelEvent=function(){
        return false;
    }
    var oftenusereporttabid='{$OFTENUSEREPORTTABID}';
	var reportnames='{$OFTENREPORTNAMES}';
	var mobilereportnames='{$MOBILEREPORTNAMES}';
	var setmember_title = '{$setmember}'
</script>