{literal}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
{/literal}           
<form action="index.php" method="post" name="tabform" id="tabform" onsubmit="puyoungJS_DialogBox.block();">
<input value="Settings" name="module" type="hidden"/>
<input value="SaveChildMenu" name="action" type="hidden"/>
        
<div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" /><span class="Name">{'MODIFYMODULENAME'|@getFixedLabel}</span>
		<a href="javascript:fninvshnew('menu');puyoungJS_DialogBox.unblock();">
			<img src="themes/softed/tier/icon_close.png" class="Close" />
		</a>
	</div>		
    <div class="Content_div" id='Content_div'>
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="Note">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
    				<tr>
                		<td width="40px" class="LdPop_ul4head">#</td>            
                		<td width="200px" class="LdPop_ul4head">{'ENMODULENAME'|@getFixedLabel}</td>
					
    					<td class="LdPop_ul4head">{'ZHMODULENAME'|@getFixedLabel}</td>
                	</tr>
                </table>
                <div class="Logscroll">	
					<table width="100%" border="0" cellspacing="0" cellpadding="0">							
    					{foreach name=tabindex item=value from=$ALLTABS}
    					<tr>
    						<td width="40px" class="LdPop_ul4body">{$smarty.foreach.tabindex.iteration}</td>
    						
    						<td  width="200px" class="LdPop_ul4body">
    							{if $value.tablabel eq 'ReportLog'}
    								<input disabled="true" id="entab{$value.tabid}" type="text" name="entab{$value.tabid}" value="{$value.enlabel}"/>
    							{elseif $value.tablabel eq 'Often_UseReport'}
    								<input disabled="true" id="entab{$value.tabid}" type="text" name="entab{$value.tabid}" value="{$value.enlabel}"/>
    							{else}                               
    								<input class="LdPop_ul4input" id="entab{$value.tabid}" type="text" name="entab{$value.tabid}" value="{$value.enlabel}"/>
    							{/if}
							</td>
      	                     <td class="LdPop_ul4body">
    							{if $value.tablabel eq 'ReportLog'}
    								<input disabled="true" id="zhtab{$value.tabid}" type="text" name="zhtab{$value.tabid}" value="{$value.zhlabel}"/>
    							{elseif $value.tablabel eq 'Often_UseReport'}
    								<input disabled="true" id="zhtab{$value.tabid}" type="text" name="zhtab{$value.tabid}" value="{$value.zhlabel}"/>
    							{else}                               
    								<input class="LdPop_ul4input" id="zhtab{$value.tabid}" type="text" name="zhtab{$value.tabid}" value="{$value.zhlabel}"/>
    							{/if}
							</td>
    					</tr>
    					{/foreach}
					</table>
                </div>
            </td>
          </tr>
        </table>
    </div>
    <div class="Bottom">
        <div class="Bottom_div width145">
            <input type="submit" value="{'SAVE'|@getFixedLabel}" class="Button_saveGreen width60" onclick="return validata();"/><span>&nbsp;</span>
			<a onclick="fninvshnew('menu');puyoungJS_DialogBox.unblock();" class="Button_backOrg width60">{'CANCEL'|@getFixedLabel}</a>
        </div>
    </div>  

</form>