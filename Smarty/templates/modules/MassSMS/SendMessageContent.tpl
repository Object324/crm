<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfoContent" method="post" action="index.php">
<input type="hidden" name="module" value="MassSMS"/>
<input type="hidden" name="action" value="SendMessage"/>
<input type="hidden" name="parenttab" value="Marketing"/>
<input type="hidden" name="contenttype" id="contenttype" value="yes"/>
<input type="hidden" id="ticketid" name="ticketid" value="{$TICKETID}"/>
<input type="hidden" id="frommodule" name="frommodule" value="{$FROMMODULE}"/>
<input type="hidden" id="fromview" name="fromview" value="{$FROMVIEW}"/>
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SMS_content'|@getFixedLabel}</strong>
        <a href="javascript:CloseDivSendInformContent('divSendInform_content','divSendInform')" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0" style="table-layout: fixed;">
    	<tr>
    		<td width="20%" align="center" valign="middle" >{'VARIABLEINFORMATION'|@getFixedLabel}</td>
    		<td width="80%">
                {'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
            	<table border="0" cellspacing=0 cellpadding=0 class="small" width="100%" style="table-layout: fixed;">
                    <tr>
                        <td style="border: 0px solid #EAEAEA;" class="center_pull">
                            <select class="ld-select-inner" onchange="OutboundOrdermoduleSel(this.value)">
                                <!--<option value="0">请选择相关模块</option>-->
                                {foreach item=tablabel key=tabid from=$PRINTTABS}
                                    <option value="{$tabid}"{if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
                                {/foreach}
                            </select>
                        </td>
                        <td style="border: 0px solid #EAEAEA;">
                            <div id="tabField" class="center_pull">
                                <select class="ld-select-inner" onchange="fieldSel(this)"><option>{'PLEASESELECTFIELD'|@getFixedLabel}</option></select>
                            </div>
                        </td>
                        <td style="border: 0px solid #EAEAEA;">
                            <input class="ld-input-inner" type="text" name="selField" id="selField" />
                        </td>
                        <td style="border: 0px solid #EAEAEA;">
                            <input type="button" class="ld-button ld-button-primary" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" onclick="InsertTwoTemplate(this)"/>
                        </td>
                    </tr>
                </table>
            </td>
    	</tr>
    	<tr>
    		<td align="center" valign="middle" >{'TEMPLATEFORACCOUNTS'|@getFixedLabel}</td>
    		<td>
                <textarea class="ld-textarea-inner" cols="90" rows="5"  id="acc_content" name="acc_content" onfocus="setFocusId('acc_content')">{$CONTENTS.accounts}</textarea><br>
            </td>
    	</tr>
        <tr>
    		<td align="center" valign="middle" >{'TEMPLATEFORSERVICER'|@getFixedLabel}</td>
    		<td><textarea cols="90" rows="5"  id="ser_content" name="ser_content" onfocus="setFocusId('ser_content')">{$CONTENTS.servicer}</textarea><br>
            </td>
    	</tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="ld-button ld-button-primary D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="SaveSendInfoContent(this)"/><span>&nbsp;</span>
        <input type="button" class="ld-button D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="CloseDivSendInformContent('divSendInform_content','divSendInform');"/>
    </div>
</form>