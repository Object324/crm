<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfoContent" method="post" action="index.php">
<input type="hidden"  name="module"  value="MassSMS"/>
<input type="hidden" name="action" value="SendInform"/>
<input type="hidden" name="parenttab" value="Marketing">
<input type="hidden" name="contenttype" id="contenttype" value="1">
<input type="hidden" id="record" name="record" value="{$record}">
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
    	<tr>
    		<td width="15%" align="right">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
    		<td width="85%" style="padding-top:10px;padding-bottom: 5px;">
                {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
            	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
                    <tr>
                        <td width="25%" style="padding-left: 0;">
                            <select name="moduleselect" onchange="moduleSel(this)" class="commonSelectPop">
                                <!--<option value="0">请选择相关模块</option>-->
                                {foreach item=tablabel key=tabid from=$PRINTTABS}
                                    <option value="{$tabid}" {if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
                                {/foreach}
                            </select>
                        </td>
                        <td width="25%">
                            <div id="tabField">
                                <select onchange="fieldSel(this)" class="commonSelectPop" style="width: 100%;">
{*                                    <option>{'PLEASESELECTFIELD'|@getFixedLabel}</option>*}
                                </select>
                            </div>
                        </td>
                        <td width="25%">
                            <input type="text" name="selField" id="selField" class="commonTextBoxPop" />
                        </td>
                        <td width="25%">
                            <input type="button"  class="createauto" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertTemplate(this)"/>
                        </td>
                    </tr>
                </table>
            </td>
    	</tr>
    	<tr>
    		<td align="right">{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
    		<td style="padding-top:10px;padding-bottom: 10px;"><textarea style="height: 140px;padding:8px;" cols="90" rows="10" id="CKcontent" name="CKcontent" class="commonTextBoxPop" style="resize:vertical;">{$CONTENT}</textarea></td>
    	</tr>
    </table>
</form>