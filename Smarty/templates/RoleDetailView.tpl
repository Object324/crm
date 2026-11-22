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


<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form id="form" name="roleView" action="index.php" method="post" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="action" value="createrole">
		<input type="hidden" name="parenttab" value="Settings">
		<input type="hidden" name="returnaction" value="RoleDetailView">
		<input type="hidden" name="roleid" value="{$ROLEID}">
		<input type="hidden" name="mode" value="edit">

      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
                {'CONTROLPANEL'|@getFixedLabel} &gt; 
                <a href="index.php?module=Settings&action=listroles&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{'LBL_ROLES'|@getFixedLabel}</a> &gt; 
                {'VIEWMEMBER'|@getFixedLabel} &quot;{$ROLE_NAME}&quot;
            </span>
        </div>
        <div class="ControlDiv2">
            <span class="F_l"><font><strong>{'LBL_ROLES'|@getFixedLabel} &quot;{$ROLE_NAME}&quot;</strong></font></span>
            <input value="{'BACKTOLIST'|@getFixedLabel}" title="{'BACKTOLIST'|@getFixedLabel}" class="editauto" type="button" name="Edit" onclick="javascript:window.location.href='index.php?module=Settings&action=listroles&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}'"/>
		</div>
        <div class="pad10" >
    		<table width="100%"  border="0" cellspacing="0" cellpadding="5">
              <tr>
                <td width="15%" class="cellLabel borderT"><strong>{'ROLENAME'|@getFixedLabel}</strong></td>
                <td width="85%" class="borderBR borderT" >{$ROLE_NAME}</td>
              </tr>
              <tr>
                <td class="cellLabel"><strong>{'SUPERROLE'|@getFixedLabel}</strong></td>
                <td class="borderBR">{$PARENTNAME}</td>
              </tr>
              <tr>
                <td valign=top class="cellLabel"><strong>{'MEMBER'|@getFixedLabel}</strong></td>
                <td class="borderBR">
				<table width="70%"  border="0" cellspacing="0" cellpadding="5">
                  <tr>
  		            <td colspan="2"></td>
			     </tr>
	
                <tr>
              		<td colspan="2">
					<div align="left"><strong>{'ASSOCIATEDUSERS'|@getFixedLabel}</strong></div>
				    </td>
                </tr>
				{if $ROLEINFO.userinfo.0 neq ''}
			     {foreach item=elements from=$ROLEINFO.userinfo}
                  <tr>

                    <td width="16"><div align="center"></div></td>
                    <td>
				        <a href="index.php?module=Users&action=DetailView&parenttab=Settings&record={$elements.0}&blockidsetting={$BLOCKIDSPECIAL}&fieldidsetting={$FIELDIDSPECIAL}">{$elements.1}</a><br>
			         </td>  	 
                    </tr>
    			{/foreach}	
    			{/if}
                </table></td>
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
var Profileid='{$PROFILEID}';
var roleName='{$ROLE_NAME}';
var roleid='{$ROLEID}';
function ProDetail(obj)
{ldelim}
    puyoungJS_DialogBox.block();
    window.location.href='index.php?module=Settings&action=profilePrivileges&mode=view&parenttab=Settings&profileid='+Profileid+"&roleName="+encodeURIComponent(roleName)+"&roleid="+roleid;
{rdelim}

</script>