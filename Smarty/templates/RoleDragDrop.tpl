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
<script language="JavaScript" type="text/javascript">
function openPopup(del_roleid){ldelim}
                window.open("index.php?module=Users&action=UsersAjax&file=RolePopup&drag=drag&maskid="+del_roleid+"&parenttab=Settings","roles_popup_window","height=425,width=640,toolbar=no,menubar=no,dependent=yes,resizable =no");
        {rdelim}
</script>


<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    {literal}
    <form name="newProfileForm" action="index.php" onsubmit="if(roleDeleteValidate()) { puyoungJS_DialogBox.block();} else { return false; }">
    {/literal}
    <input type="hidden" name="module" value="Users">
    <input type="hidden" name="action" value="RoleDragDrop">
    <input type="hidden" name="childId" value="{$ROLEID}">
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
      <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
                {'CONTROLPANEL'|@getFixedLabel} &gt; 
                <a href="index.php?module=Settings&action=listroles&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{'LBL_ROLES'|@getFixedLabel}</a> &gt; 
               {'MOVEROLE'|@getFixedLabel} &quot;{$ROLENAME}&quot;
            </span>
        </div>
        
        <div class="pad10" >
    		<table border=0 cellspacing=0 cellpadding=5 width=100% class="tableHeading">
        	<tr>
        		<td class="big"><strong>{'LBL_ROLES'|@getFixedLabel} &quot;{$ROLENAME}&quot; </strong></td>
        		<td><div align="right">
                    <input type="submit" name="Delete" value="{'SAVE'|@getFixedLabel}" class="saveauto b_radius3"/>
                    <input type="button" name="Cancel" value="{'CANCEL'|@getFixedLabel}" class="cancelauto b_radius3" onclick="location.href='javascript:history.back(-1);'"/>
        		</div></td>
        	  </tr>
        	</table>
        	<table width="100%"  border="0" cellspacing="0" cellpadding="5">
              <tr class="small">
                <td width="15%" class="small cellLabel"><strong>{'NEEDMOVEROLE'|@getFixedLabel}</strong></td>
                <td width="85%" class="cellText" >{$ROLENAME}</td>
              </tr>
              <tr class="small">
                <td class="small cellLabel"><strong>{'MOVEDSUPERROLE'|@getFixedLabel}</strong></td>
                <td class="cellText">
                    <input style="width:150px;" type="text" name="role_name"  id="role_name" value="" class="txtBox" readonly="readonly">&nbsp;
         	          {$ROLEPOPUPBUTTON}
                    <input type="hidden" name="user_role" id="user_role" value=""/>	
                </td>
              </tr>
              
            </table>
        </div>       
           
                 
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->


<script>
{literal}
function roleDeleteValidate()
{
	if(document.getElementById('role_name').value == '')
	{
		{/literal}
                var confirm_str = arrJsPopLabel['SPECIFYROLEAFTERMOVING'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
                {literal}
	}
	return true;
}
{/literal}
</script>