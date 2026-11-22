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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="javascript">
/*
角色保存函数
*/
function dup_validation()
{ldelim}
	var rolename = $('rolename').value;
	var mode = getObj('mode').value;
	var roleid = getObj('roleid').value;
	if(mode == 'edit')
		var urlstring ="&mode="+mode+"&roleName="+rolename+"&roleid="+roleid;
	else
		var urlstring ="&roleName="+rolename;
	//var status = CharValidation(rolename,'namespace');
	//if(status)
	//{ldelim}
	new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: 'module=Settings&action=SettingsAjax&file=SaveRole&ajax=true&dup_check=true'+urlstring,
                                onComplete: function(response) {ldelim}
					if(response.responseText.indexOf('SUCCESS') > -1)
						document.newRoleForm.submit();
					else
            RemindsMsg("","LdPopWidth400px","","yes","",response.responseText);
                                {rdelim}
                        {rdelim}
                );
	//{rdelim}
	//else
	//	alert(alert_arr.NO_SPECIAL+alert_arr.IN_ROLENAME)

{rdelim}
function validate()
{ldelim}
	formSelectColumnString();
    /*
    edit by LD Can
    Date:20130327
    reason:用户授权及控制面板改进
    */
	//if( !emptyCheck("roleName", "Role Name", "text" ) )
	//	return false;

	/*if(document.newRoleForm.selectedColumnsString.value.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
	{ldelim}

		alert('{$APP.ROLE_SHOULDHAVE_INFO}');
		return false;
	{rdelim}*/
	dup_validation();return false
{rdelim}
</script>
<br>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="98%">
<tbody><tr>
        <td valign="top"><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
        <td class="showPanelBg" style="padding: 10px;" valign="top" width="100%">
        <br>

	<div align=center>
			{include file='SetMenu.tpl'}
				<!-- DISPLAY -->
				<table border=0 cellspacing=0 cellpadding=5 width=100% class="settingsSelUITopLine">
				{literal}
				<form name="newRoleForm" action="index.php" method="post" >
				{/literal}
				<input type="hidden" name="module" value="Settings">
				<!--<input type="hidden" name="action" value="SaveRole">-->
                 <input type="hidden" name="action" value="profilePrivileges">
				<input type="hidden" name="parenttab" value="Settings">
				<input type="hidden" name="returnaction" value="{$RETURN_ACTION}">
				<input type="hidden" name="roleid" id="roleid" value="{$ROLEID}">
				<input type="hidden" name="mode"  id="mode" value="{$MODE}">
				<input type="hidden" name="parent" value="{$PARENT}">
                <input type='hidden' name="copyRole" value="{$copyRole}"/>
                <!-- By Can reason:用户授权及控制面板改进 other:获取角色所对应得权限ID-->
                <input type="hidden" name="profileid" id="profileid" value="{$PROFILEID}"/>
                 <!--<input type="hidden" name="profilename" id="profilename" value="{$PROFILENAME}"/>-->
				<tr>
					<td width=50 rowspan=2 valign=top><img src="{'ico-roles.png'|@lingdang_imageurl:$THEME}" width="48" height="48" border=0 ></td>
					{if $MODE eq 'edit'}
					<td class=heading2 valign=bottom><b><a href="index.php?module=Settings&action=index&parenttab=Settings">{$MOD.LBL_SETTINGS}</a> > <a href="index.php?module=Settings&action=listroles&parenttab=Settings">{$CMOD.LBL_ROLES}</a> &gt; {$MOD.LBL_EDIT} &quot;{$ROLENAME}&quot; </b></td>
					{else}	
					<td class=heading2 valign=bottom><b><a href="index.php?module=Settings&action=index&parenttab=Settings">{$MOD.LBL_SETTINGS}</a> > <a href="index.php?module=Settings&action=listroles&parenttab=Settings">{$CMOD.LBL_ROLES}</a> &gt; {$CMOD.LBL_CREATE_NEW_ROLE}</b></td>
					{/if}
				</tr>
				<tr>
					{if $MODE eq 'edit'}
					<td valign=top class="small">{$MOD.LBL_EDIT} {$CMOD.LBL_PROPERTIES} &quot;{$ROLENAME}&quot; {$MOD.LBL_LIST_CONTACT_ROLE}</td>
					{else}
					<td valign=top class="small">{$CMOD.LBL_NEW_ROLE}</td>
					{/if}
				</tr>
				</table>
				
				<br>
				<table border=0 cellspacing=0 cellpadding=10 width=100% >
				<tr>
				<td valign=top>
					
					<table border=0 cellspacing=0 cellpadding=5 width=100% class="tableHeading">
					<tr>
						{if $MODE eq 'edit'}
						<td class="big"><strong>{$CMOD.LBL_PROPERTIES} &quot;{$ROLENAME}&quot; </strong></td>
						{else}
						<td class="big"><strong>{$CMOD.LBL_NEW_ROLE}</strong></td>
						{/if}
						<td><div align="right">
							<!--<input type="button" class="save" name="add" value="  {$APP.LBL_SAVE_BUTTON_LABEL}  " onClick="return validate()">-->
                            
						<input type="button" class="save" name="add" value="  {$APP.LNK_STEP_NEXT}  " onClick="return rolevalidate()">
                        
						<input type="button" class="cancel" name="cancel" value="{$APP.LBL_CANCEL_BUTTON_LABEL}" onClick="window.history.back()">
						</div></td>
					  </tr>
					</table>
					<table width="100%"  border="0" cellspacing="0" cellpadding="5">
                      <tr>
                        <td width="15%" class="cellLabel"><font color="red">*</font><strong>{$CMOD.LBL_ROLE_NAME}</strong></td>
                        <td width="85%" class="cellText" ><input id="rolename" name="roleName" type="text" value="{$ROLENAME}" class="detailedViewTextBox"></td>
                      </tr>
                      <tr>
                        <td class="cellLabel"><strong>{$CMOD.LBL_REPORTS_TO}</strong></td>
                        <td class="cellText">{$PARENTNAME}</td>
                      </tr>
                      <tr>
                        <td  valign=top class="cellLabel" style="height:90pxa;"><strong>{$CMOD.LBL_DESCRIPTION}</strong>	
                       </td>
                       <!--
                       edit:cdw
                       date:20130627
                       reason:0003990: 建议：角色编辑中 表格中最下面的灰色横线延长与其上面的对齐
                       -->
                       <td style="border-bottom-color: #DADADA;border-bottom-style: solid;border-bottom-width: 1px;">
                       <textarea name="description" >{$DESCRIPTION}</textarea> 
                       	</td>
                      </tr>
                    </table>
					<br>
					
					
				</td>
				</tr>
				<tr>
				  <td valign=top>&nbsp;</td>
				  </tr>
				</table>
			
			
			
			</td>
			</tr>
			</table>
		</td>
	</tr>
	</form>
	</table>
		
	</div>

</td>
        <td valign="top"><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
   </tr>
</tbody>
</table>
	
<script language="JavaScript" type="text/JavaScript">    
        var moveupLinkObj,moveupDisabledObj,movedownLinkObj,movedownDisabledObj;
        function setObjects() 
        {ldelim}
            availListObj=getObj("availList")
            selectedColumnsObj=getObj("selectedColumns")

        {rdelim}

        function addColumn() 
        {ldelim}
            for (i=0;i<selectedColumnsObj.length;i++) 
            {ldelim}
                selectedColumnsObj.options[i].selected=false
            {rdelim}

            for (i=0;i<availListObj.length;i++) 
            {ldelim}
                if (availListObj.options[i].selected==true) 
                {ldelim}            	
                	var rowFound=false;
                	var existingObj=null;
                    for (j=0;j<selectedColumnsObj.length;j++) 
                    {ldelim}
                        if (selectedColumnsObj.options[j].value==availListObj.options[i].value) 
                        {ldelim}
                            rowFound=true
                            existingObj=selectedColumnsObj.options[j]
                            break
                        {rdelim}
                    {rdelim}

                    if (rowFound!=true) 
                    {ldelim}
                        var newColObj=document.createElement("OPTION")
                        newColObj.value=availListObj.options[i].value
                        if (browser_ie) newColObj.innerText=availListObj.options[i].innerText
                        else if (browser_nn4 || browser_nn6) newColObj.text=availListObj.options[i].text
                        selectedColumnsObj.appendChild(newColObj)
                        availListObj.options[i].selected=false
                        newColObj.selected=true
                        rowFound=false
                    {rdelim} 
                    else 
                    {ldelim}
                        if(existingObj != null) existingObj.selected=true
                    {rdelim}
                {rdelim}
            {rdelim}
        {rdelim}

        function delColumn() 
        {ldelim}
            for (i=selectedColumnsObj.options.length;i>0;i--) 
            {ldelim}
                if (selectedColumnsObj.options.selectedIndex>=0)
                selectedColumnsObj.remove(selectedColumnsObj.options.selectedIndex)
            {rdelim}
        {rdelim}
                        
        function formSelectColumnString()
        {ldelim}
            var selectedColStr = "";
            for (i=0;i<selectedColumnsObj.options.length;i++) 
            {ldelim}
                selectedColStr += selectedColumnsObj.options[i].value + ";";
            {rdelim}
            document.newRoleForm.selectedColumnsString.value = selectedColStr;
        {rdelim}
	setObjects();			
    
    
    
   /*
   edit by LD Can
   reason:用户授权及控制面板改进
   other:本页面”下一步“按钮调用的函数
   */
function rolevalidate()
{ldelim}
    var profilename = $('rolename').value;
    profilename = trim(profilename);

    if(profilename != '')
	return Privilege_validation(profilename);
    else
    {ldelim}
    /*
    edit:Can
    date:20130418
    reason:0003803: 角色>新增角色：“角色名称”为空时点击“下一步”后，系统显示异常；
    */
       var confirm_str = arrJsPopLabel['ROLECANOTEMPTY'];
       RemindsMsg("","LdPopWidth400px","","yes","",confirm_str); 
       //puyoungJS_DialogBox.unblock();
       document.forms['newRoleForm'].roleName.focus();
	     return false
    {rdelim}
    return false
{rdelim}


function Privilege_validation(profilename)
{ldelim}
	//var status = CharValidation(profilename,'namespace');
    //新增角色时点击下一步新增权限
    var ModeType='module=Users&action=UsersAjax&file=CreateProfile&ajax=true&dup_check=true&profile_name='+profilename+'&roleid='+document.getElementById("roleid").value+"&profileid="+document.getElementById("profileid").value;
    if(document.getElementById("mode").value=="edit")//修改角色下一步修改权限
    {ldelim}
        //index.php?module=Settings&action=profilePrivileges&return_action=ListProfiles&parenttab=Settings&mode=edit&profileid=6
        
        ModeType="module=Users&action=CreateProfile&dup_check=true&parenttab=Settings&mode=edit&profileid="+document.getElementById("profileid").value+'&profile_name='+profilename+'&roleid='+document.getElementById("roleid").value;
    {rdelim}
   
	//if(status)
	//{ldelim}
    
    
	new Ajax.Request(
		'index.php',
		{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
			method: 'post',
			postBody: ModeType,
			onComplete: function(response) {ldelim}
           
					if(response.responseText.indexOf('SUCCESS') > -1)
                    {ldelim}
						document.newRoleForm.submit();
                    {rdelim}
					else
                    {ldelim}
                        puyoungJS_DialogBox.unblock();
                     
            RemindsMsg("","LdPopWidth400px","","yes","",response.responseText); 
                    {rdelim}
				{rdelim}
		{rdelim}
	);
	//{rdelim}
	//else
	//	alert(alert_arr.NO_SPECIAL+alert_arr.IN_PROFILENAME)
{rdelim}
</script>	