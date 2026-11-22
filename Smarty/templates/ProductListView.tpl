<link href="themes/softed/selfstyle.css" rel="stylesheet" type="text/css">
<table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%" style="margin-left: 10px;">
    <tr>
		<td width="40%" class="padTB10">
			<b>{'Available_fields'|@getFixedLabel}</b><br><br>
			<input class="ld-input-inner" style="width:100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup_input(this,'AssmablyList',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" name="allmember" /><br>
			<div class="selectAll" align="left">
				<input type="checkbox" id="selectAll_left" onclick="selectallcheckboxCustomviewModule(this)"/>
				<label value="" for="selectAll_left">{'ALLSELECT'|@getFixedLabel}</label>
			</div>
			<div style="height: 270px;width:100%;margin-top: 0px;border: 1px solid #f0f3f7;background-color: #F9FAFC;overflow: hidden auto;" class="commonMultipleSelect" name="AssmablyList" id="AssmablyList" ondblclick="addColumnCheckBoxCustomview('AssmablyList','selectedAssmablyColumns',event)" multiple="">
				{foreach key = number item = assmablys from =$PRODUCTLISTVIEWALL name=pname}
				{assign var="assmablylabel" value=$assmablys}
					<div class="ld-category-draggable commonSelect">
						<input id="{$number}" type="checkbox">
						<label value="{$number}"  for="{$number}">{$assmablys}</label>
						<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="{'MoveRightToDisplay'|@getFixedLabel}"  data-direction="right" data-type="position" style="float: right;margin-top: -26px;cursor: move;display: none;"></a></div>
					</div>
				{/foreach}
			</div>
		</td>
		<td width="8%" style="text-align: center;">
			<a class="ld-icon-newhomearr-mright ld-icon-movetoright" href="javascript:;" onclick="copySelectedCheckboxCustomviewModule('AssmablyList','selectedAssmablyColumns','moveright');" title="{'MOVERIGHT'|@getFIxedLabel}"></a><br>
			<a class="ld-icon-newhomearr-mleft ld-icon-movetoleft" style="margin-top:15px;" href="javascript:;" onclick="copySelectedCheckboxCustomviewModule('selectedAssmablyColumns','AssmablyList','moveleft');" title="{'MOVELEFT'|@getFIxedLabel}"></a>
		</td>
		<td width="40%" class="padTB10">
			<b>{'Selected_Fields'|@getFixedLabel}</b><br><br>
			<input class="ld-input-inner" style="width:100%;margin-top: 5px;" type="text" onkeyup="cls_input_select.getInstance('field')._onkeyup_input(this,'selectedAssmablyColumns',event)" tag="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" placeholder="{'pleaseenterthecategoryyouarelookingforfield'|@getFixedLabel}" name="allmember" /><br>
			<div class="selectAll" align="left">
				<input type="checkbox" id="selectAll_right" onclick="selectallcheckboxCustomviewModule(this)"/>
				<label value=""  for="selectAll_right">{'ALLSELECT'|@getFixedLabel}</label>
			</div>
			<div size="11" style="height: 270px;width:100%;margin-top: 0px;border: 1px solid #f0f3f7;background-color: #F9FAFC;overflow: hidden auto;" class="commonMultipleSelect" name="selectedAssmablyColumns" id="selectedAssmablyColumns" ondblclick="addColumnCheckBoxCustomview('selectedAssmablyColumns','AssmablyList',event)" multiple="">
				{if $HAVEPRODUCTLISTVIEWALL != null}
                {foreach key = number item = assmablys from =$HAVEPRODUCTLISTVIEWALL name=pname}
                    {assign var="assmablylabel" value=$assmablys}
			        <div class="ld-category-draggable commonSelect">
						<input id="{$number}" type="checkbox">
						<label value="{$number}" for="{$number}">{$assmablys}</label>
						<div><a align="right" class="ld-dragicon drag-handle sort-tip-items" data-tip="{'DRAGTOSORT'|@getFixedLabel}"  data-direction="right" data-type="position" style="float: right;margin-top: -26px;cursor: move;display: none;"></a></div>
					</div>
                {/foreach}
                {/if}
				<span id="movetips" style="display:none;font-size: 14px;line-height: 260px;">{'MoveLeftFieldshere'|@getFixedLabel}</span>
			</div>
		</td>
		<td width="8%" style="text-align: center">
			<a class="ld-icon-newhomearr-mup ld-icon-moveup" href="javascript:;" onclick="ProductDetailCheckBoxmoveUp();" title="{'MOVEUP'|@getFIxedLabel}"></a><br>
			<a class="ld-icon-newhomearr-mdown ld-icon-movedown" style="margin-top:15px;" href="javascript:;" onclick="ProductDetailCheckBoxmoveDown();" title="{'MOVEDOWN'|@getFIxedLabel}"></a>
		</td>
    </tr>
</table>
<style>
	.commonSelect{
		border: none;
	}
	.commonSelect:hover{
		background-color: #F0F3F7;
		border: none;
	}
	.commonSelect{
		padding: 0px 20px 0px 20px;
		width: 100%;
		line-height: 30px;
	}
	.commonSelect input{
		vertical-align:middle;
		margin-top:-2px;
		width: 14px;
		height: 14px;
	}
	.commonSelect label{
		margin-left: 5px;
		display: inline-block;
		line-height: inherit;
		width: 80%;
	}
	.selectAll{
		margin: 15px 0px 0px 0px;
		background-color: #EFF6FF;
		line-height: 30px;
		width: 100%;
		border-radius: 5px 5px 0px 0px;
	}
	.selectAll input{
		vertical-align:middle; margin-top:-3px;margin-left: 24px;width: 14px;height: 14px;
	}
	.selectAll label{
		display: inline-block;margin-left: 4px;width: 100%;
	}
</style>