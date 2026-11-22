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
    <form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="action" value="createnewgroup">
		<input type="hidden" name="groupId" value="{$GROUPID}">
		<input type="hidden" name="mode" value="edit">
		<input type="hidden" name="parenttab" value="Settings">
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
                {'CONTROLPANEL'|@getFixedLabel} &gt; 
                <a href="index.php?module=Settings&action=listgroups&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{'USERGROUPLIST'|@getFixedLabel}</a> &gt; 
                {'VIEW'|@getFixedLabel} &quot;{$GROUPINFO.0.groupname}&quot;
            </span>
        </div>
        <div class="ControlDiv2">
        	<span class="F_l"><font><strong>{'USERGROUPLIST'|@getFixedLabel} &quot;{$GROUPINFO.0.groupname}&quot; </strong></font></span>
            <input value="{'EDIT'|@getFixedLabel}" title="{'EDIT'|@getFixedLabel}" class="editauto" type="submit" name="Edit" >
	       <input type="button" value="{'BACKTOLIST'|@getFixedLabel}" title="{'BACKTOLIST'|@getFixedLabel}" class="editauto" onClick = "window.location.href='index.php?module=Settings&action=listgroups&parenttab=Settings&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}';"/>&nbsp;
       </div>
        <div class="pad10" >
            <table width="100%"  border="0" cellspacing="0" cellpadding="5">
              <tr>
                <td width="15%" class="cellLabel borderT"><strong>{'GROUPNAME'|@getFixedLabel}</strong></td>
                <td width="85%" class="borderBR borderT" >{$GROUPINFO.0.groupname}</td>
              </tr>
              <tr>
                <td class="cellLabel"><strong>{'DESCRIPTION'|@getFixedLabel}</strong></td>
                <td class="borderBR">&nbsp;{$GROUPINFO.0.description}</td>
              </tr>
              <tr>
                <td valign="top" class="cellLabel"><strong>{'MEMBER'|@getFixedLabel}</strong></td>
                <td class="borderBR">
				<table width="70%"  border="0" cellspacing="0" cellpadding="5">
                <tr>
              		{foreach key=type item=details from=$GROUPINFO.1} 
                    {if $details.0 neq ''}		
        			{if $type == "User"}
         		       <td colspan="2">
    				       <div align="left"><strong>{'LBL_USERS'|@getFixedLabel}</strong></div>
                       </td>
    			    {/if}	
    			    {if $type == "Role"}
         		        <td colspan="2">
    				      <div align="left"><strong>{'LBL_ROLES'|@getFixedLabel}</strong></div>
    			        </td>
    	            {/if}	
    			     {if $type == "Role and Subordinates"}
                        <td colspan="2">
    				        <div align="left"><strong>{'ROLEANDSUBORDINATE'|@getFixedLabel}</strong></div>
    			        </td>
    			     {/if}	
    			     {if $type == "Group"}
                        <td colspan="2">
    				        <div align="left"><strong>{'USERGROUPLIST'|@getFixedLabel}</strong></div>
    			       </td>
    			     {/if}	
                 </tr>
                 <tr>
                    <td width="16"><div align="center"></div></td>
                    <td>
            			{foreach item=element from=$details}
            				{if $element.memberaction == "GroupDetailView"}
            				<a href="index.php?module=Settings&action={$element.memberaction}&{$element.actionparameter}={$element.memberid}&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}">{$element.membername}</a><br />
            				{/if}
            				{if $element.memberaction == "RoleDetailView"}	
            				<a href="index.php?module=Settings&action={$element.memberaction}&{$element.actionparameter}={$element.memberid}&blockidsetting={$BLOCKIDSPECIAL}&fieldidsetting={$FIELDIDSPECIAL}">{$element.membername}</a><br />
            				{/if}
            				{if $element.memberaction == "DetailView"}	
            				<a href="index.php?module=Users&action={$element.memberaction}&{$element.actionparameter}={$element.memberid}">{$element.membername}</a><br />
            				{/if}
            			{/foreach}
            	    </td>  	 
                </tr>
            {/if}
            {/foreach}
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