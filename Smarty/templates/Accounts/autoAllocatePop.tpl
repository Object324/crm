{*lius 20230613 XUQIU1001607 圣拉维CRM项目：客户自动分配功能*}
<form enctype="multipart/form-data" method="POST" id="my_form" action="index.php" class="ajax_form">
<div name="displayfields">
	<table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">

		<tr>
			<td class="DetailedTd1Label" width="20%" align="right">
				<font color="red">*</font>
				分配标准
			</td>
			<td class="DetailedTd2Info" width="80%" align="left">
				<input readonly="" name="{$fldname}_name" type="text" fieldonly="0" value="{$SERVICECHAR_NAME}" class="commonDetailedTextBox gwidth70 bgwhite" onblur="this.className='commonDetailedTextBox gwidth70 bgwhite'" onfocus="this.className='detailedViewTextBoxSelectOn'">
				<input name="{$fldname}" type="hidden" value="{$SERVICECHAR_ID}">
				<a class="icon-homeimg icon-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showrelatedlist('Accounts','CustomForm24','select','','{$fldname}');"></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata_special('CustomForm24','{$fldname}','{$fldname}_name','CustomForm24','popupselectfield');return false;">
			</td>
		</tr>

	</table>


</div>
</form>


