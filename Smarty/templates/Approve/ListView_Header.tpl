<div class="ld-breadcrumb">
	<span><a href="index.php?pageto_module=Approve&pageto_action=ApproveListViewCount">{'MYAPPROVALCENTER'|@getFixedLabel}</a></span>
	{if $APPROVESTATUS eq 1}
		<span class="greyFont9 marLR5">></span>
		{*@edit:liushuai,2020-07-28,reason:0042057/审批中心>>已处理>>查看明细界面，“已处理”增加超链接，点击后进入审批中心“已处理”页签界面*}
		<span><a onclick="ApproveCenterClick(1,event)" href="javascript:;">{'Processed'|@getFixedLabel}</a></span>
	{elseif $APPROVESTATUS eq 0}
		<span class="greyFont9 marLR5">></span>
		<span><a onclick="ApproveCenterClick(0,event)" href="javascript:;">{'Pending'|@getFixedLabel}</a></span>
	
	{elseif $APPROVESTATUS eq 3}
		<span class="greyFont9 marLR5">></span>
		<span><a onclick="ApproveCenterClick(3,event)" href="javascript:;">{'isubmitted'|@getFixedLabel}</a></span>
		
	{elseif $APPROVESTATUS eq 4}
		<span class="greyFont9 marLR5">></span>
		<span><a onclick="ApproveCenterClick(4,event)" href="javascript:;">{'ApproveRejected'|@getFixedLabel}</a></span>
	
	{/if}
	{if $FROMAPPROVEMODULE neq ''}
		<span class="greyFont9 marLR5">></span>
		<span>{$FROMAPPROVEMODULE|@getTransTab}</span>
	{/if}
{*	<a class="rfloat" href="javascript:;" onclick="getLinksUrl('','Approve','module_list_help');" title="{'ONLINEHELP'|@getFixedLabel}">{'ONLINEHELP'|@getFixedLabel}</a>*}
</div>