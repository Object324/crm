<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfoContent" method="post" action="index.php">
<input type="hidden" name="module" value="MassSMS"/>
<input type="hidden" name="action" value="SendInform"/>
<input type="hidden" name="parenttab" value="Marketing">
<input type="hidden" name="contenttype" id="contenttype" value="{$CONTENTTYPE}">
<input type="hidden" id="out_id" name="out_id" value="{$OUT_ID}">
<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}">
	<table class="ld-public-content-small" width="100%" cellspacing="0" cellpadding="0" border="0">
    	<tr>
    		<td class="ld-form-item-label">{'VARIABLEINFORMATION'|@getFixedLabel}</td>
    		<td class="ld-form-item-content">
                {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
            	<table border="0" cellspacing=0 cellpadding=0 class="small" >
                    <tr>
                        <td class="padR8">
                            <select class="ld-select-inner" onchange="moduleSel(this)" disabled>
                                <!--<option value="0">请选择相关模块</option>-->
                                {foreach item=tablabel key=tabid from=$PRINTTABS}
                                    <option value="{$tabid}"{if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
                                {/foreach}
                            </select>
                        </td>
                        <td class="padR8">
                            <div id="tabField">
                                <select class="ld-select-inner" onchange="fieldSel(this)"><option>{'PLEASESELECTFIELD'|@getFixedLabel}</option></select>
                            </div>
                        </td>
                        <td class="padR8">
                            <input class="ld-input-inner" type="text" name="selField" id="selField" />
                        </td>
                        <td>
                            <input type="button" class="ld-button ld-button-primary" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertTemplate(this)"/>
                        </td>
                    </tr>
                </table>
            </td>
    	</tr>
    	<tr>
    		<td class="ld-form-item-label">{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
    		<td class="ld-form-item-content">
                <textarea class="ld-textarea-inner" cols="90" rows="5" id="CKcontent" name="CKcontent">{$CONTENT}</textarea><br>
                <span class="greyFont9">{$WILDCARD}</span>
            </td>
    	</tr>
    </table>
</form>