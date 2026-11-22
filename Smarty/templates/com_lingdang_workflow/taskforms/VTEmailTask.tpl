<!--修改编码格式:统一编码：UTF-8-->
<script src="modules/com_lingdang_workflow/resources/lingdangwebservices.js" type="text/javascript" charset="utf-8"></script>
<script type="text/javascript" charset="utf-8">
var moduleName = '{$entityName}';
</script>
<script src="modules/com_lingdang_workflow/resources/emailtaskscript.js" type="text/javascript" charset="utf-8"></script>

<table border="0" cellpadding="5" cellspacing="0" width="100%" class="small">
	<tr>
		<td class='dvtCellLabel' align="right" width=15% nowrap="nowrap"><b><font color=red>*</font> {'LBL_EMAIL_RECIPIENT'|@getTranslatedString:$MODULE}</b></td>
		<td class='dvtCellInfo'><input type="hidden" name="recepient" value="{$task->recepient}" id="save_recepient" class="form_input" style='width: 250px;'>
        <!--ADD by LD TIFA 20121219-->
        <input type="text" name="recepient2" value="{$str_recepient}" id="save_recepient2" class="form_input" style='width: 250px;'>
			<span id="task-emailfields-busyicon"><b>{$MOD.LBL_LOADING}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
			<select id="task-emailfields" class="small" style="display: none;"><option value=''>{$MOD.LBL_SELECT_OPTION_DOTDOTDOT}</option></select></td>
	</tr>
	<tr>
		<td class='dvtCellLabel' align="right" width=15% nowrap="nowrap"><b> {'LBL_EMAIL_CC'|@getTranslatedString:$MODULE}</b></td>
		<td class='dvtCellInfo'><input type="hidden" name="emailcc" value="{$task->emailcc}" id="save_emailcc" class="form_input" style='width: 250px;'>
        <!--ADD by LD TIFA 20121219-->
        <input type="text" name="emailcc2" value="{$str_emailcc}" id="save_emailcc2" class="form_input" style='width: 250px;'>
			<span id="task-emailfieldscc-busyicon"><b>{$MOD.LBL_LOADING}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
			<select id="task-emailfieldscc" class="small" style="display: none;"><option value=''>{$MOD.LBL_SELECT_OPTION_DOTDOTDOT}</option></select></td>
	</tr>
	<tr>
		<td class='dvtCellLabel' align="right" width=15% nowrap="nowrap"><b> {'LBL_EMAIL_BCC'|@getTranslatedString:$MODULE}</b></td>
		<td class='dvtCellInfo'><input type="hidden" name="emailbcc" value="{$task->emailbcc}" id="save_emailbcc" class="form_input" style='width: 250px;'>
        <!--ADD by LD TIFA 20121219-->
        <input type="text" name="emailbcc2" value="{$str_emailbcc}" id="save_emailbcc2" class="form_input" style='width: 250px;'>
			<span id="task-emailfieldsbcc-busyicon"><b>{$MOD.LBL_LOADING}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
			<select id="task-emailfieldsbcc" class="small" style="display: none;"><option value=''>{$MOD.LBL_SELECT_OPTION_DOTDOTDOT}</option></select></td>
	</tr>
	<tr>
		<td class='dvtCellLabel' align="right" width=15% nowrap="nowrap"><b><font color=red>*</font> {'LBL_EMAIL_SUBJECT'|@getTranslatedString:$MODULE}</b></td>
		<td class='dvtCellInfo'><input type="hidden" name="subject" value="{$task->subject}" id="save_subject" class="form_input" style='width: 350px;'>
        <!--ADD by LD TIFA 20121219-->
        <input type="text" name="subject2" value="{$str_subject}" id="save_subject2" class="form_input" style='width: 350px;'>
			<span id="task-subjectfields-busyicon"><b>{$MOD.LBL_LOADING}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
			<select id="task-subjectfields" class="small" style="display: none;"><option value=''>{$MOD.LBL_SELECT_OPTION_DOTDOTDOT}</option></select></td>
	</tr>
</table>

<table border="0" cellpadding="0" cellspacing="0" width="100%" class="small">
	<tr>
		<td style='padding-top: 10px;'>
			<span id="task-fieldnames-busyicon"><b>{$MOD.LBL_LOADING}</b><img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
			<select id='task-fieldnames' class="small" style="display: none;"><option value=''>{$MOD.LBL_SELECT_OPTION_DOTDOTDOT}</option></select>
		</td>
			
		<td>&nbsp</td>
		<td style='padding-top: 10px;'>
			<b>{$MOD.LBL_SELECT}&nbsp</b>	
		</td>
		<td style='padding-top: 10px;'>
			<select class="small" id="task_timefields">
					<option value="">{$MOD.LBL_SELECT_OPTION_DOTDOTDOT}</option>
					{foreach key=META_LABEL item=META_VALUE from=$META_VARIABLES}
					<option value="{$META_VALUE}">{$META_LABEL|@getTranslatedString:$MODULE_NAME}</option>
					{/foreach}
			</select>	
		</td>
		<td align="right" style='padding-top: 10px;'>
			<span class="helpmessagebox" style="font-style: italic;">{$MOD.LBL_WORKFLOW_NOTE_CRON_CONFIG}</span>
		</td> 
	</tr>
</table>	
<table>
	<tr>
		<td>&nbsp</td>
	</tr>	
	<tr>
		<td><b>{$MOD.LBL_MESSAGE}:</b></td>	
	</tr>
</table>
<script type="text/javascript" src="include/ckeditor/ckeditor.js"></script>
<p  style="border:1px solid black;">
	<textarea  style="width:90%;height:200px;" name="content" rows="55" cols="40" id="save_content" class="detailedViewTextBox"> {$task->content} </textarea>
</p>
<script type="text/javascript" defer="1">
	var textAreaName = 'save_content';
	CKEDITOR.replace( textAreaName,	{ldelim}
		extraPlugins : 'uicolor',
		uiColor: '#dfdff1'
	{rdelim} ) ;
	var oCKeditor = CKEDITOR.instances[textAreaName];
</script> 