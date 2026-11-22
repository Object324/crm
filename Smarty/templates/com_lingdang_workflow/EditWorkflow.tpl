<!--修改编码格式:统一编码：UTF-8-->
{include file='com_lingdang_workflow/Header.tpl'}

{include file='com_lingdang_workflow/EditWorkflowIncludes.tpl'}

{include file='com_lingdang_workflow/WorkflowTemplatePopup.tpl'}

{include file='com_lingdang_workflow/NewTaskPopup.tpl'}
<!--Error message box popup-->
{include file='com_lingdang_workflow/ErrorMessageBox.tpl'}
<!--Done popups-->

{include file='SetMenu.tpl'}
<div id="view">
	{include file='com_lingdang_workflow/ModuleTitle.tpl'}
	<form name="edit_workflow_form" action="index.php" id="edit_workflow_form" onsubmit="puyoungJS_DialogBox.block();">
		{include file='com_lingdang_workflow/EditWorkflowMeta.tpl'}

		{include file='com_lingdang_workflow/EditWorkflowBasicInfo.tpl'}
		<br>
		{include file='com_lingdang_workflow/EditWorkflowTriggerTypes.tpl'}
		<br>
		{include file='com_lingdang_workflow/ListConditions.tpl'}
	</form>

	{if $saveType eq "edit"}
		<br>
		{include file='com_lingdang_workflow/ListTasks.tpl'}
	{/if}
</div>
<div id="dump" style="display:None;"></div>
{include file='com_lingdang_workflow/Footer.tpl'}