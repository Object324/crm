<input type="hidden" id="dividend_type" name="dividend_type" value="{$DIVIDENDTYPE}" />
<div class="D_pop_tit">
	<strong class="D_ptita">{'SMS_content'|@getFixedLabel}</strong>
	<a href="###" id="colose_sms_content" class="D_ptitc">
		<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
	</a>
</div>
<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
	<tr>
		<td width="30%" align="center" valign="middle" >{'VARIABLEINFORMATION'|@getFixedLabel}</td>
		<td width="70%">
			{'PLEASEPASSTHEFOLLOWINGOPTIONS'|@getFixedLabel}
			<table border="0" cellspacing=0 cellpadding=0 class="small" >
				<tr>
					<td style="border: 0px solid #EAEAEA;">
						<select  onchange="moduleSel(this)" disabled>
							<!--<option value="0">请选择相关模块</option>-->
							{foreach item=tablabel key=tabid from=$PRINTTABS}
								<option value="{$tabid}"{if $TABID eq $tabid}selected{/if}>{$tablabel}</option>
							{/foreach}
						</select>
					</td>
					<td style="border: 0px solid #EAEAEA;">
						<div id="tabField">
							<select onchange="fieldSel(this)"><option>{'PLEASESELECTFIELD'|@getFixedLabel}</option></select>
						</div>
						
					</td>
					<td style="border: 0px solid #EAEAEA;">
						<input  type="text" name="selField" id="selField" />
					</td>
					<td style="border: 0px solid #EAEAEA;">
						<input  type="button"  class="createauto" value="{'INSERTEDINTOTHECONTENTTEMPLATE'|@getFixedLabel}" id="InsertTemplate"/>
					</td>
				</tr>
			</table>
		</td>
	</tr>
	<tr>
		<td align="center" valign="middle" >{'ACONTENTTEMPLATE'|@getFixedLabel}</td>
		<td><textarea cols="90" rows="5"  id="CKcontent" name="CKcontent">{$sms_contents}</textarea></td>
	</tr>
</table>
<div class="D_pbtn">
	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" id="save_sms_content"/><span>&nbsp;</span>
	<input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" id="D_pbtncancel"/> 
</div>

