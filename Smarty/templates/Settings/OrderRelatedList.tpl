
		<!--修改编码格式:统一编码：UTF-8-->
        <form action="index.php" method="post" name="form" onsubmit="puyoungJS_DialogBox.block();">
		<input type="hidden" name="fld_module" value="{$MODULE}">
		<input type="hidden" name="module" value="Settings">
		<input type="hidden" name="parenttab" value="Settings">
		{assign var=entries value=$CFENTRIES}
	
		<div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
        <span class="Name">{'RELATEDLIST'|@getFixedLabel}</span>
    		<a href="javascript:fninvshnew('relatedlistdiv');">
    			<img src="themes/softed/tier/icon_close.png" class="Close" />
    		</a>
    	</div>		
        <div class="Content_div">
        	<table width="100%" border="0" cellspacing="0" cellpadding="0">
              <tr>
                <td class="Note">
            		<table width="100%" border="0" cellpadding="3" cellspacing="0" >					
    					{foreach item=related from=$RELATEDLIST name=relinfo}
    					<tr>
    						<td>{$related.label}<!-- {$related.label|@getTranstab} -->
    						</td>
    						{if $smarty.foreach.relinfo.first}
    						<td align="right" >
                                <span class="place"></span>
    		 				</td>
    						<td align="right" valign="middle">
    			 				<a class="icon-homearr icon-downfield" href="javascript:;" onclick="changeRelatedListorder('move_down','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}'); " title="{'MOVEDOWN'|@getFixedLabel}"></a>
                            </td>
    
    					{elseif  $smarty.foreach.relinfo.last}
    					<td align="right" valign="middle">
                            <a class="icon-homearr icon-upfield" href="javascript:;" onclick="changeRelatedListorder('move_up','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}'); " title="{'MOVEUP'|@getFixedLabel}"></a>
    				 	</td>
    					<td align="right" >
                            <span class="place"></span>
    				 	</td>
    					{else }
    					<td align="right" valign="middle">
                            <a class="icon-homearr icon-upfield" href="javascript:;" onclick="changeRelatedListorder('move_up','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}') " title="{'MOVEUP'|@getFixedLabel}"></a>
    				 	</td>
    					<td align="right" valign="middle">
                            <a class="icon-homearr icon-downfield" href="javascript:;" onclick="changeRelatedListorder('move_down','{$related.tabid}','{$related.sequence}','{$related.id}','{$MODULE}') " title="{'MOVEDOWN'|@getFixedLabel}"></a>
    				 	</td>
    					{/if}
    				</tr>
    				{/foreach}		
    			</table>	
                </td>
              </tr>
            </table>
        </div>
 
	</form>	