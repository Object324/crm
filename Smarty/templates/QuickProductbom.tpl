<div class="">
	<script type="text/javascript">   
	    var fieldinfojson='{$PRODUCTFIELDSINFOJSON}';
	    var module='Productbom';
	    document.getElementById('rowcnt').value=1;
	</script>
	<script type="text/javascript" src="include/js/producttool/toolField.js"></script>
	<script type="text/javascript" src="include/js/producttool/fieldFormula.js"></script>
	<form name="QcbomEditView" method="POST" action="index.php">
		<input name="action" value="QcBomSave" id="QcBomSave" type="hidden">
		<input name="module" value="Productbom" type="hidden">
		<input name="qcreatetype" value="popup" type="hidden">
		<input name="mode" value="{$MODE}" type="hidden">
		<input name="record" id="record" value="{$BOMID}" type="hidden">
		<input name="productbom_no" id = "productbom_no" value="{$ENTITY.productbom_no}" type="hidden" >
		<input name="curr_row" id="curr_row" value="{$CURR_ROW}" type="hidden">
		<input name="frommodule" id="frommodule" value="{$FROMMODULE}" type="hidden">
		<table class="settingPopTable" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td class="" width="20%" align="right">
					<font color="red">*</font><span fldname='subject'>{$SUBJECT}</span></td>
				<td class="" width="30%" align="left">
					<input fieldonly="0" name="subject" id="subject" tabindex="" value="{$ENTITY.subject}" type="text" autocomplete ='off' class="detailedViewTextBox">
				</td>
				<td class="" width="20%" align="right" fldname='smownerid'>
					<font color="red">*</font>{$SMOWNER}</td>
				<td class="" width="30%" align="left">
					<select name="assigned_user_id" id="assigned_user_id" class="small">
						{foreach key=userid item=userinfo from = $USERCOMBO}
							{foreach key=username item=selected from = $userinfo}
								<option value="{$userid}" {$selected}>{$username}</option>
							{/foreach}
						{/foreach}
					</select>
				</td>
			</tr>
			<tr>
				<td colspan="4">
					<!-- product 产品信息 -->
					
				</td>
			</tr>
		</table>
		<div style='max-height:280px; overflow-y:auto;margin-top: -1px;border-right: 1px solid #ddd;border-left: 1px solid #ddd;'>
			{$ASSOCIATED_PRODUCTS}
		</div>
		<div class="D_pbtn">
			<!-- <input name="bomselectbtn" class="D_pbtnok" value="{'SAVEANDSELECT'|@getFixedLabel}" onclick="bom_save(this,'SaveAndSelect');" type="button" style='background-color: #a4d343; border: 1px solid #CCCCCC;'> -->
			<input name="bomconfirmbtn" class="D_pbtnok" value="{'CONFIRMANDSELECT'|@getFixedLabel}" onclick="bom.confirmAndSelect();" type="button" style='background-color: #a4d343; border: 1px solid #CCCCCC;display:none;'>
			{if $MODE neq 'update'}
			<span>&nbsp;</span>
			<input name="bomsavebtn" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" onclick="bom_save(this,'Save');" type="button">
			{/if}
			<span>&nbsp;</span>
			<input name="bomconcalbtn" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="cancelCrmPopup()" type="button">
			<input type="hidden" name="bomproduct" id="bomproduct" value='1'/>
			<input type="hidden" id="popupBom" value='1'/>
		</div>
	</form>
	<script>
		fieldformulaobj.setAllRowEvent();
	</script>
</div>