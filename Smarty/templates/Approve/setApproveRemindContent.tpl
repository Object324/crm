<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfoContent" method="post" action="index.php">
<input type="hidden"  name="module"  value="MassSMS"/>
<input type="hidden" name="action" value="SendInform"/>
<input type="hidden" name="parenttab" value="Marketing">
<input type="hidden" name="contenttype" id="contenttype" value="{$CONTENTTYPE}">
<input type="hidden" id="out_id" name="out_id" value="{$OUT_ID}">
<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}">
	<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td width="15%" align="right">{'REMINDERPEOPLE'|@getFixedLabel}</td>
    		<td width="85%" align="left">
                <select name="selectapprovereminduser" class="btn-radius-system">
                </select>
            </td>
        </tr>
        <tr style="display:none;" name="approveRemindtitle_tr">
            <td align="right">
                <font color="red">*</font>{'ReminderTitle'|@getFixedLabel}
            </td>
            <td align="left" class="padTB5">
                <input  type="text" name="approveRemindtitle" class="detailedViewTextBox gwidth40" value=""/>{'MobileReminderContenttitle'|@getFixedLabel}
            </td>
        </tr>
    	<tr>
    		<td align="right">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
    		<td align="left" class="padT5">
                {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
            	<table border="0" cellspacing=0 cellpadding=0 class="small" >
                    <tr>
                        <td style="padding:2px 8px 2px 0;">
                            <select onchange="moduleSel(this)" class="btn-radius-system" disabled>
                                <!--<option value="0">请选择相关模块</option>-->
                                {foreach item=tablabel key=tabid from=$PRINTTABS}
                                    <option value="{$tabid}"{if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
                                {/foreach}
                            </select>
                        </td>
                        <td>
                            <div id="tabField">
                                <select onchange="fieldSel(this)" class="btn-radius-system">
                                    <option>{'PLEASESELECTFIELD'|@getFixedLabel}</option>
                                </select>
                            </div>
                        </td>
                        <td>
                            <input type="text" name="selField" id="selField" class="detailedViewTextBox" />
                        </td>
                        <td>
                            <input type="button" class="createauto" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertRemindField(this)"/>
                        </td>
                    </tr>
                </table>
            </td>
    	</tr>
    	<tr>
    		<td align="right">{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
    		<td align="left" class="padTB5">
                <textarea cols="90" rows="5" name="CKcontent" style="resize:vertical;">{$CONTENT}</textarea><br>
                <span class="greyFont9" style="display: inline-block;white-space: pre-wrap;">{$WILDCARD}</span>
            </td>
    	</tr>
    </table>
</form>