{*+**********************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ***********************************************************************************+*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="modules/{$MODULE}/{$MODULE}.js"></script>
<script language="JavaScript">
{literal}
function changeSel(obj)
{
    window.location.href = "index.php?module=Settings&action=RelatedList&parenttab=Settings&tabid=" + obj;
}
function changeRelatedListorder(what_to_do,tabid,sequence,id,module)	
{
	$('vtbusy_info').style.display = "block";   
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=changeRelatedPersence&sequence='+sequence+'&fld_module='+module+'&parenttab=Settings&what_to_do='+what_to_do+'&tabid='+tabid+'&id='+id+'&ajax=true',
			onComplete: function(response) {
			$("relatedlistdiv").innerHTML=response.responseText;
			$('vtbusy_info').style.display = "none";
			}
		}
		
	);	
}	
function callRelatedList(obj,module,tabid){
	$('vtbusy_info').style.display = "block";
    
	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=getRelaInfoOrder&parenttab=Settings&tabid='+tabid+'&formodule='+module+'&ajax=true',
			onComplete: function(response) {
		    //puyoungJS_DialogBox.block();
            $("relatedlistdiv").innerHTML=response.responseText;            
			fnvshobj(obj,'relatedlistdiv');
            $('vtbusy_info').style.display = "none";  
            //Drag.init(document.getElementById("relatedlistdivheading"), document.getElementById("relatedlistdiv"));           
			}
		}
	);
}
{/literal}
</script>
<body>
<table align="center" border="0" cellpadding="0" cellspacing="0" width="98%">
<tbody>
<tr>
<td valign="top"><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
<td class="showPanelBg" style="padding: 10px;" valign="top" width="100%">
<br>
<div align=center>
{include file='SetMenu.tpl'}
<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
	<tr>
		<td>
			&nbsp;
		</td>
	</tr>
	<tr>
		<td valign=top align=right width=8><img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}"></td>
		<td class="showPanelBg" valign="top" width="100%" >
			<div style="padding: 20px;">
				<form action="index.php?module=Settings&action=RelatedEdit&parenttab=Settings" method="POST" name="form" id="form">
					<div align="center">
						<table cellspacing="0" cellpadding="5" border="0" width="100%" class="settingsSelUITopLine">
							<tbody>
								<tr>
									<td width="50" valign="top" rowspan="2" align="left"><img height="48" border="0" width="48" src="{'productfield.png'|@lingdang_imageurl:$THEME}"/></td>
									<td valign="bottom" class="heading2" align="left"><b><a href="index.php?module=Settings&amp;action=index&amp;parenttab=Settings">{'CONTROLPANEL'|@getFixedLabel}</a> > {'LBL_RELATED_RELATEDLIST'|@getFixedLabel} </b></td>
								</tr>
								<tr>
									<td valign="top"class="small" align="left">{'LBL_RELATED_RELATEDLIST_DESCRIPTION'|@getFixedLabel}</td>
								</tr>
							</tbody>
						</table>
						<br>
						<br>
						<table width="95%" cellspacing="0" cellpadding="0" border="0" class="small" align="center">
                        <tr>
                            <td>
                            <table border=0 cellspacing=0 cellpadding=5 width=100% class="tableHeading">
                                <tr>
                                    <td class="big" align="left">
                                        <select style="width:120px;" onchange="changeSel(this.value)">
                                            {foreach from=$List key=cnt item=arr}
                                                <option value="{$arr.rela_tabid}"  {if $SelectId == $arr.rela_tabid} selected="selected" {/if} >{$arr.rela_label}</option>
                                            {/foreach}
                                        </select>
                                    </td>
                                    <td class="small" align=right>
                                        <input name="Edit" type="submit" class="editauto" value="{'EDIT'|@getFixedLabel}" >
                                        <input type="button" class="createauto" onclick="callRelatedList(this,'{$CFENTRIES.0.module}','{$SelectId}');" alt="{'ARRANGEFIELDSDISPLAYORDER'|@getFixedLabel}" title="{'ARRANGEFIELDSDISPLAYORDER'|@getFixedLabel}" value="{'ARRANGEFIELDSDISPLAYORDER'|@getFixedLabel}"/>									
                                    </td>
                                </tr>
                            </table>
                            <div id="Products_fields" >	
                                <table cellspacing=0 cellpadding=5 width=100% class="listTable small">
                                    <tr>
                                        <td valign=top >
                                            <table border=0 cellspacing=0 cellpadding=5 width=100% class=small>
                                           <input type="hidden" name="selected_id" id="selected_id" value="{$SelectId}" />
                                            <tr>
                                                <td width="10px">&nbsp;</td>
                                                <td id="8_1_1">&nbsp;</td>
                                                <td id="8_1_1" align="left">{'FIELDNAME'|@getFixedLabel}</td>
                                                <td id="8_1_1" align="left">{'FIELDWIDTH'|@getFixedLabel}</td>                                              
                                            </tr>
                                            <tr>
                                            {foreach from=$FIELDARRAY key=cnt item=arr}
                                                <td>&nbsp;</td>
                                                <td id="8_1_1">
                                                {if $arr.relatedstatus == 1}
                                                <img src='themes/images/prvPrfSelectedTick.gif'>
                                                {else}
                                                <img src='themes/images/no.gif'>
                                                {/if}
                                                </td>
                                                <td align="left" onMouseOver="this.className='prvPrfHoverOn',$('8_1_1').className='prvPrfHoverOn'" onMouseOut="this.className='prvPrfHoverOff',$('8_1_1').className='prvPrfHoverOff'">
                                                {$arr.relatedlable}
                                                </td>
                                                <td align="left" onMouseOver="this.className='prvPrfHoverOn',$('8_1_1').className='prvPrfHoverOn'" onMouseOut="this.className='prvPrfHoverOff',$('8_1_1').className='prvPrfHoverOff'">
                                                {$arr.relatedwidth}%
                                                </td>
                                                {if ($cnt + 1) is div by 1}
                                                 </tr>
                                                 <tr>
                                                {/if} 
                                            {/foreach}
                                            </tr>
                                            </table>
                                        </td>
                                    </tr>
                                </table>
                                </div>
								</td>
							</tr>
						</table>
                        </td>
                        </tr>
                        </table>
					</div>
				</form>
			</div>
		</td>
		<td valign=top align=right><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
	</tr>
</table>
<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" id="vtbusy_info" style="display:none;position:absolute;top:180px;right:100px;" border="0" />
<div id="relatedlistdiv" style="display:none; position: absolute; width: 200px; left: 500px;"></div>
</div>
</td>
<td valign="top"><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
</tr>
</tbody>
</table>
</body>