{*<!--/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
* ("License"); You may not use this file except in compliance with the License
* The Original Code is:  lingdang CRM Open Source
* The Initial Developer of the Original Code is lingdang.
* Portions created by lingdang are Copyright (C) lingdang.
* All Rights Reserved.
<!--修改编码格式:统一编码：UTF-8-->
*
********************************************************************************/ -->*}	
		
        <form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block();"  style="padding: 0; margin: 0;">
		<input type="hidden" name="fld_module" value="{$MODULE}"/>
		<input type="hidden" name="module" value="Settings"/>
		<input type="hidden" name="parenttab" value="Settings"/>
		{assign var=entries value=$CFENTRIES}	
        <div class="D_pop_box LdPopWidth300px">
            <div class="D_pop_tit">
            	<strong class="D_ptita">{'DISPLAYORDER'|@getFixedLabel}</strong>
                <a href="javascript:fninvshnew('relatedlistdiv');" class="D_ptitc">
                    <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
                </a>
            </div>
            <div style="max-height: 400px; width: 100%; overflow-y: auto;">
                <table class="D_pop_bod D_pop_bod_line" cellspacing="0" cellpadding="1" border="0">
    				{foreach item=related from=$RELATEDLIST name=relinfo}
    				<tr>
                        <td width="50%" style="padding-left:10px;">
                            {$related.label}
                        </td>
                        {if $smarty.foreach.relinfo.first}
                        <td colspan="2"></td>
                        {elseif $smarty.foreach.relinfo.iteration == 2}
                        <td width="25%">
                            <span class="place"></span>
                        </td>
                        <td width="25%">
                            <a class="icon-homearr icon-downfield" href="javascript:;"  onclick="changeRelatedListorder('move_down','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}'); " title="{'DOWN'|@getFixedLabel}"></a>
                        </td>
                        {elseif  $smarty.foreach.relinfo.last}
                        <td width="25%">
                            <a class="icon-homearr icon-upfield" href="javascript:;"  onclick="changeRelatedListorder('move_up','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}');" title="{'UP'|@getFixedLabel}"></a>
                        </td>
                        <td width="25%">
                             <span class="place"></span>
                        </td>
                        {else }
                        <td width="25%">
                            <a class="icon-homearr icon-upfield" href="javascript:;"  onclick="changeRelatedListorder('move_up','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}')" title="{'UP'|@getFixedLabel}"></a>
                        </td>
                        <td width="25%">
                            <a class="icon-homearr icon-downfield" href="javascript:;"  onclick="changeRelatedListorder('move_down','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}')" title="{'DOWN'|@getFixedLabel}"></a>
                        </td>
                        {/if}
                    </tr>
    			{/foreach}		
    		  </table>
            </div>
            
        </div>
        
	</form>