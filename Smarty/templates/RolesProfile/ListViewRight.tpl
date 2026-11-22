{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
{literal}
<style>
    .showTable{
        display:inline-table;
    }
    .hideTable{
        display:none;
    }
</style>
{/literal}

<div id="moduleoption">
	<form action="index.php" method="post" name="profileform" id="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Users">		
		<input type="hidden" name="parenttab" value="Settings">
		<input type="hidden" name="action" value="{$ACTION}">		
		<input type="hidden" name="mode" value="{$MODE}">	
		<input type="hidden" name="profileid" id="profileid" value="{$PROFILEID}">
		<input type="hidden" name="profile_name" value="{$PROFILE_NAME}">
		<input type="hidden" name="profile_description" value="{$PROFILE_DESCRIPTION}">
		<input type="hidden" name="parent_profile" value="{$PARENTPROFILEID}">
		<input type="hidden" name="radio_button" value="{$RADIOBUTTON}">	
		<input type="hidden" name="return_action" value="{$RETURN_ACTION}">	
		<input type="hidden" name="return_module" value="{$RETURN_MODULE}"/>
	  
		<input type="hidden" name="description" value="{$PROFILE_DESCRIPTION}"/>
		<input type="hidden" name="parentrole" value="{$PARENTROLE}"/>
		<input type="hidden" name="copyRoleId" value="{$COPYPROFILEID}" />
		<input type='hidden' name="copyRole" value="{$copyRole}"/>
		<input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
		<input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
        <input type="hidden" name="maxActionId" value="{$MAXACTIONID}"/>
		{* 头部区域 *}
        <div class="ld-rolesprofile-listviewright-head" id="RolesProfile_RightHead">
            <div class="ld-rolesprofile-listviewright-headtitle">
                <span>{'ROLEINFORMATION'|@getFixedLabel}</span>
            </div>
            <div class="ld-rolesprofile-listviewright-roleinfo">
                <div>
                    <span class="roleinfo-label">{'RoleName2'|@getFixedLabel}：</span>
                    <span class="roleinfo-value">{$PROFILE_NAME}</span>
                </div>
                <div style="margin-left: 32px;">
                    <span class="roleinfo-label">{'DESCRIPTION'|@getFixedLabel}：</span>
                    <span class="roleinfo-value">{$PROFILE_DESCRIPTION}</span>
                </div>
            </div>
        </div>
        {* 页签，搜索区域 *}
        <div class="ld-rolesprofile-listviewright-navbararea" id="RolesProfile_RightNavbar">
            <div class="ld-rolesprofile-listviewright-navbar" id="navbar_area">

            </div>
            <div class="ld-rolesprofile-search" style="float: right;width: 20%;margin: 8px 16px 8px 0px;">
                <span class="leftmenu-fonticon">&#xe623;</span>
                <input class="ld-input-inner" id="search_content" type="text" placeholder="{'SEARCHMODULENAME'|@getFixedLabel}" autocomplete="off" style="">
                <b class="ld-icon-clearsearch" id="clear_search_content" style="position: absolute; right: 0px; top: 0px; cursor: pointer; visibility: visible;display: none;"></b>
            </div>
        </div>

        <div id="RolesProfile_MainContent">
            {include file="RolesProfile/ListViewMainContent.tpl"}
        </div>
	</form>
</div>

<script language="javascript" type="text/javascript">
    var oftenusereporttabid='{$OFTENUSEREPORTTABID}';
    var reportnames='{$OFTENREPORTNAMES}';
    var mobilereportnames='{$MOBILEREPORTNAMES}';
    var all_tabid = '{$ALLTABLEID}';
    {literal}
    //initialiseprofile();
    //edit:can 20200724 42095: (61mis.com/kfbcrm)成员管理>序时簿界面：角色权限列点击“销售人员”，点击“编辑”按钮，“销售线索”点击全选没反应
    if(typeof checkMember=='undefined')
        AjaxJSPage( "Role_js", 'include/js/Settings/Roles.js');
    function btnCancel(obj,event)
    {
        window.location.href="index.php?module=Settings&action=listroles&parenttab=Settings";
    }
    window.onload = function(){
        $('profilename').focus();
        $('tab_chk_com_75').checked = true;  //zyh 20150515 0014981
    }
    {/literal}
</script>