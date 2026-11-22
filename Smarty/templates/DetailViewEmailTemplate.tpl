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
<link href="{$CSSURL}themes/softed/Control.css" rel="stylesheet" type="text/css" />
<!--中间-->
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <!--td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td-->
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
    <form method="post" action="index.php" name="etemplatedetailview" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="action" value="editemailtemplate">
		<input type="hidden" name="module" value="EmailListtmp">
		<input type="hidden" name="templatename" value="{$TEMPLATENAME}">
		<input type="hidden" name="templateid" value="{$TEMPLATEID}">
		<input type="hidden" name="foldername" value="{$FOLDERNAME}">
		<input type="hidden" name="parenttab" value="{$PARENTTAB}">
        <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
        <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/> 
        
      <div class="DivCR">       
        <div>
      		<table class="singleList" border="0" cellspacing="0" cellpadding="5" width="100%" >
				<tr>
					<td width="20%" class="borderB borderR"> {'MAILNAME'|@getFixedLabel} </td>
					<td width="80%" class="borderB"> {$TEMPLATENAME} </td>
				  </tr>
				<tr>
					<td class="borderB borderR"> {'DESCRIPTION'|@getFixedLabel} </td>
					<td class="borderB">{$DESCRIPTION}</td>
				  </tr>
				<tr>
					<td class="borderB borderR"> {'MAILFOLDER'|@getFixedLabel} </td>
					<td class="borderB" >{if $FOLDERNAME eq 'Personal'}{'Private'|@getFixedLabel}{else}{$FOLDERNAME|@getFixedLabel}{/if}
          </td>
				</tr>
                <tr>
                    <td width="20%" class="borderR"> {'Content'|@getFixedLabel} </td>
                    <td>{$BODY}</td>
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