<link type="text/css" href="{$CSSURL}themes/softed/coordination.css" rel="stylesheet" />
{literal}
<style type="text/css">
.pad{
	padding-left:10px;
}
.select2-container{
    display:inline;
}
.select2-container .select2-selection--multiple{
    height:36px;
    min-width:150px;
}
.select2-container--default .select2-selection--multiple .select2-selection__choice{
  margin: 3px;
}
.select2-container--open .select2-dropdown--below{
  width: 150px !important;
}
.select2-container {
  position: relative !important;
  top: 0px !important;
  left: 8px !important;
}
</style>

{/literal}

<form action="index.php" method="post" name="save_normal_account_basicsearch" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Accounts"/>
	<input type="hidden" name="action" value="AccountsAjax"/>
	<input type="hidden" name="advft_criteria_groups"/>
	<input type="hidden" name="advft_criteria"/>
	<input type="hidden" value="{$NORMALID}" name="normal_id">
	<!--自动回收规则数据分类设置-->
	<div name="account_rule_advance_div">
		<div>
			{include file="AdvanceFilterCustViewPopup.tpl"}
		</div>
	</div>
</form>