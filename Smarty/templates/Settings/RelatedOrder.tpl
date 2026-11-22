{*<!--/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
* ("License"); You may not use this file except in compliance with the License
* The Original Code is:  lingdang CRM Open Source
* The Initial Developer of the Original Code is lingdang.
* Portions created by lingdang are Copyright (C) lingdang.
* All Rights Reserved.
*
********************************************************************************/ -->*}	
		<!--修改编码格式:统一编码：UTF-8-->
        <form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="fld_module" value="{$MODULE}">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="parenttab" value="Settings">
		{assign var=entries value=$CFENTRIES}
		<div style="display:block; position:relative;" class="LdPop_box LdPopWidth300px">
        
        
        <div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
        <span class="Name">{'DISPLAYORDER'|@getFixedLabel}</span>
    		<a href="javascript:fninvshnew('relatedlistdiv');">
    			<img src="themes/softed/tier/icon_close.png" class="Close" />
    		</a>
    	</div>		
        <div class="Content_div">
        	<table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td class="Note">
            		<table width="100%" border="0" cellpadding="3" cellspacing="0" style="font-size: 13px;line-height: 27px;" >
    					{foreach item=related from=$RELATEDLIST name=relinfo}
    					<tr>
                            <td>{$related.label|@getTranslatedString:$related.label}</td>
                            {if $smarty.foreach.relinfo.iteration == 1}
                            <td align="right" valign="middle" >
                                <span class="place"></span>
                            </td>
                            <td align="right" valign="middle">
                                <a class="icon-homearr icon-downfield" href="javascript:;"  onclick="changeRelatedListorder('move_down','{$related.tabid}',0,'{$related.id}','{$MODULE}'); " title="{'MOVEDOWN'|@getFixedLabel}"></a>
                            </td>
                            {elseif  $smarty.foreach.relinfo.last}
                            <td align="right" valign="middle">
                                <a class="icon-homearr icon-upfield" href="javascript:;"  onclick="changeRelatedListorder('move_up','{$related.tabid}',0,'{$related.id}','{$MODULE}');" title="{'MOVEUP'|@getFixedLabel}"></a>
                            </td>
                            <td align="right" valign="middle" >
                                <span class="place"></span>
                            </td>
                            {else }
                            <td align="right" valign="middle">
                                <a class="icon-homearr icon-upfield" href="javascript:;"  onclick="changeRelatedListorder('move_up','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}') " title="{'MOVEUP'|@getFixedLabel}"></a>
                            </td>
                            <td align="right" valign="middle">
                                <a class="icon-homearr icon-downfield" href="javascript:;"  onclick="changeRelatedListorder('move_down','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}')" title="{'MOVEDOWN'|@getFixedLabel}"></a>
                            </td>
                            {/if}
                        </tr>
        				{/foreach}		
        			</table>
                </td>
              </tr>
            </table>
        </div>
     		
		</div>
	</form>	
	      