{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/modules/Settings/ButtonsCustomization.js?v={$GLOBALMINVERSION}"></script>
<form action="index.php" method="post" name="new" id="form" onsubmit="puyoungJS_DialogBox.block();">
	<div class="main_grid_top">
		<div class="grid-view-title lfloat overflow-hidden">
			<span class="grid-view-name dinline-block lfloat">
				{'ButtonsCustomization'|@getFixedLabel}
				{* {if $HelpHtml.WorkflowCustomizationList neq '' }{$HelpHtml.WorkflowCustomizationList}{/if} *}
			</span>
			<span class="grid-view-choose dinline-block lfloat">{'SELECTMODULE'|@getFixedLabel}</span>
			<select fieldtype="select" id="optionmodule" name="optionmodule" class="btn-radius-system width150">
				{foreach item=moduleinfo from=$optionmodule_arr}
					<option value="{$moduleinfo.tabid}">{$moduleinfo.label}</option>              
				{/foreach}
			</select>
		</div>
		<div class="grid_tool">
			<div class="displayflex">
				<a href="javascript:;" class="ld-button ld-button-primary" name="createbtn" data-btnid="0" title="{'CREATE'|@getFixedLabel}">{'CREATE'|@getFixedLabel}</a>
			</div>
		</div>
	</div>
	<div class="main_grid_box">
		<div class="grid-analysis-box">
			<div class="grid-analysis-header">
			</div>
			<div id="cfList" class="cont_wrap clear_float" name="listcontent">
				{include file='ButtonsCustomization/ButtonsCustomizationList.tpl'}
			</div>
		</div>
	</div>
</form>
{* <div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div> *}
{* <script>
	if(empty(CrmPopup.getlastPopupObjByType("ButtonsCustomization"))){
		var popupobj = new Object();
		popupobj.divid = "SettingRightContent";
		popupobj.type = "ButtonsCustomization";
		CrmPopup.global_listPopupObj.push(popupobj);
		console.log('CrmPopup.global_listPopupObj: ', CrmPopup.global_listPopupObj);
		popupobj.CancelEvent=function(){
			return false;
		}
		popupobj.buttoncustomizationObj = new ButtonsCustomization();
		popupobj.buttoncustomizationObj.setPopupobj(popupobj);
		popupobj.buttoncustomizationObj.setListEvent();
		popupobj.listdata_arr 
		var listdata_arr_json = '{$listdata_arr_json}';
		popupobj.listdata_arr = eval('(' + listdata_arr_json + ')') ? eval('(' + listdata_arr_json + ')') : JSON.parse(listdata_arr_json);
	}
</script> *}