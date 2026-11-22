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

<div name="account_rule_advance_div">
	<input type="hidden" name="fieldname" value="{$FIELDNAME}" />
	<input type="hidden" name="record" value="{$RECORD}" />
	<input type="hidden" name="frommodule" value="{$FROMMODULE}" />
	
	<div>
		{include file="newAdvanceFilter.tpl"}
	</div>
</div>