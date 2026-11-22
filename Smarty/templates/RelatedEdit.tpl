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
<script type="text/javascript">
{literal}
    function change()
    {
        if(confirm(arrJsPopLabel['DETERMINCHANGES']))
        {
            form.submit();
        }
        else
        {
            return false;
        }
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
									<td valign="bottom" class="heading2" align="left"><b><a href="index.php?module=Settings&amp;action=index&amp;parenttab=Settings">{'CONTROLPANEL'|@getFixedLabel}</a> &gt; {'LBL_RELATED_RELATEDLIST'|@getFixedLabel} </b></td>
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
                                    <td class="big"><strong></strong></td>
                                    <td class="small" align=right>
                                        <input name="Edit" type="button" onclick="change()" class="editauto" value="{'SAVE'|@getFixedLabel}" >
                                        <input name="{'CANCEL'|@getFixedLabel}" value="{'CANCEL'|@getFixedLabel}" class="cancelauto" type="button" onClick="window.location.href='index.php?module=Settings&action=RelatedList&parenttab=Settings'">									
                                    </td>
                                </tr>
                            </table>
                            <div id="Products_fields" >	
                                <table cellspacing=0 cellpadding=5 border="0" width=100% class="listTable small">
                                    <tr>
                                        <td valign=top width="25%" >
                                            <table border=0 cellspacing=0 cellpadding=5 width=100% class=small>
                                            <input type="hidden" id="selected_id" name="selected_id" value="{$tabid}" />
                                            <tr>
                                                <td>&nbsp;</td>
                                                <td id="8_1_1">&nbsp;</td>
                                                <td id="8_1_1" align="left">{'FIELDNAME'|@getFixedLabel}</td>
                                                <td id="8_1_1" align="left">{'FIELDWIDTH'|@getFixedLabel}</td>
                                            </tr>
                                            <tr>
                                            {foreach from=$FIELDARRAY key=cnt item=arr}
                                                <td width="10px">&nbsp;</td>
                                                <td id="8_1_1">
                                                {if $arr.relatedstatus == 1}
                                                <input type="checkbox" name="fstatus[]" id="fstatus[]" value="{$arr.fieldid}" checked="checked" {if $arr.relatededit == 1}disabled{/if}>
                                                {else}
                                                <input type="checkbox" name="fstatus[]" id="fstatus[]" value="{$arr.fieldid}" >
                                                {/if}
                                                </td>
                                                <td align="left" onMouseOver="this.className='prvPrfHoverOn',$('8_1_1').className='prvPrfHoverOn'" onMouseOut="this.className='prvPrfHoverOff',$('8_1_1').className='prvPrfHoverOff'">
                                                {$arr.relatedlable}
                                                </td>
                                                <td>
                                                    <input onkeyup="this.value=this.value.replace(/\D/g,'')" onafterpaste="this.value=this.value.replace(/\D/g,'')" type="text" id="width[]" name="width[]" size="3" value="{$arr.relatedwidth}" maxlength="2" />%
                                                    <input type="hidden" value="{$arr.fieldid}" name="fieldid[]" id="fieldid[]" />
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
</div>
</td>
<td valign="top"><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
</tr>
</tbody>
</table>
</body>