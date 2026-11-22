
{literal}
<style type="text/css">
.pad{
	padding-left:10px;
}
.tagger_span{vertical-align: middle;float: left;}
.tagger_span a{display: inline-block; padding:0 20px 0 8px; position: relative; margin:0 4px; text-decoration:none ;height: 28px;line-height: 26px;}
.tagger_span a.personal{
	border: 1px solid #68DA94;
    color: #68DA94;
    background: rgba(104, 218, 148, 0.2);
}
.tagger_span a.company{
	border: 1px solid #EB8473;
    color: #EB8473;
    background: rgba(235, 132, 115, 0.2);
}
.tagger_span a em{ width: 16px; height: 100%; position: absolute;right: 0;top: -2px;}
.tagger_span a em:after{ content: "x";font: bold 12px 'Microsoft Yahei';}
.tagger_span a.personal em:after{color: #68DA94;}
.tagger_span a.company em:after{color: #EB8473;}
.tagger_span a:hover em{ display: block; }
a.tagger_span-add{display: inline-block;font: bold 20px 'Microsoft Yahei'; color: #2cac93}

.fm-button {
	display: inline-block;
	text-align: center;
	color: #fff;
	height: 28px;
	line-height: 28px;
	font-size: 14px;
	padding: 0 1em;
	border-radius: 3px;
	opacity: .9;
	filter: alpha(opacity=90);
	background:#fff;
	border-radius: 20px;
	border: 1px solid #555;
}
a{text-decoration:none;}
	h3{color: aliceblue}
</style>
{/literal}

<input type="hidden" name="moduledata_module" value="{$MODULE}">
<input type="hidden" name="moduledata_record" value="{$RECORD}">
<div class="DetailContentTable modulemaptag" name="setTagDiv" id="setTagDiv" {if $ismodulemapedit eq 'false'}style="padding: 20px;overflow-y: auto;overflow-x: hidden" {/if}>
	<div class="modulemaptagtop">
		<div class="modulemaptagtop-text">{'Currenttag'|@getFixedLabel}</div>
		<div class="modulemaptagtop10">
			<input type="hidden" name="input_tagger" value="{$MODULE_LIST_TAG}" tag_id="{$MODULE_LIST_TAG_ID}" tag_type="{$MODULE_LIST_TAG_TYPE}" id="input_tagger" />
		</div>
	</div>
	<div class="modulemaptagmiddle" >
		<div class="modulemaptagmiddle-text">{'SelectavailableTags'|@getFixedLabel}</div>
		<div class="modulemaptagtop10 ld-form-item-content padL0 padR0">
					<div class="row-fluid" name="dv_cmb_accountrelationship">
						<span class="span10">
						{assign var=fldname value='select_input_tagger'}
						<input type="hidden" name="input_tagger_option" value="{$OPTION_LABEL_ID}" tag_id="{$OPTION_LABEL_ID}" id="input_tagger_option" />
						<select id="select_input_tagger"  name="select_input_tagger" style="display:none">
							{foreach item=tag_info key=id from=$MODULELABEL}
								{if is_array($tag_info)}
									<option value="{$tag_info.tag_id}">{$tag_info.tag}</option>
								{/if}
							{/foreach}
						</select>

						  <div name="dv_chzn_{$fldname}" id="{$fldname}_div" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','')">
							<a class="chzn-single" onclick="moduledata_tag.com_img_change(event,'{$fldname}','')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">

							  <input class="ld-select-inner-input" type="text" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}','')" value="">
							  <div>
								<b></b>
							  </div>
							</a>
							<div style=" left:-9000px;top: 25px;display: none" class="chzn-drop" name='dv_drop_{$fldname}' >
							 <ul class="chzn-results" name="cmb_ul_{$fldname}">
								{assign var="i" value=0}
								{foreach item=tag_info key=id from=$MODULELABEL}
									{if is_array($tag_info)}
										<li  class="active-result" style="padding: 6px 7px;" tag_id="{$tag_info.tag_id}" tag_type="{$tag_info.tag_type}" name="dv_chzn_{$i}_select_input_tagger" onclick="moduledata_tag.cmb_liclick(event,'select_input_tagger',ld(this))" onmouseover="cmb_limouseover(event,'select_input_tagger','')">{$tag_info.tag}</li>
										{assign var="i" value=$i+1}
									{/if}
								{/foreach}
								<!--<li class="" name="li_chzn_{$fldname}" style="padding: 6px 7px;">{'NOMATCHINGITEMS'|@getFixedLabel}</li>-->
{*				                     edit: xll 2023/05/12 BUG0065788 kfbcrm-客户-单据详情-添加标签，若无可用标签时，应在下拉框内出现提示信息*}
								{if $OPTION_LABEL_ID == ''}
									<li class="" id="NoOptionLabel" name="NoOptionLabel" style="padding: 6px 7px;">{'NOOPTIONALLABEL'|@getFixedLabel}</li>
								{else}
									<li class="" id="NoOptionLabel" name="NoOptionLabel" style="padding: 6px 7px;display:none;">{'NOOPTIONALLABEL'|@getFixedLabel}</li>
								{/if}
							 </ul>
							</div>
						  </div>
						  </span>
					</div>
					<b onclick="moduledata_tag.getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="ld-icon-set"></b>
		</div>
	</div>
	<div class="modulemaptaglast" >
		<div class="modulemaptaglast-text">{'Createanewtag'|@getFixedLabel}</div>
		<div class="modulemaptaglast-div">
			{if $IS_ADMIN eq 1}
				<input id="corp_tag_input" type="checkbox" name="corp_tag" />
				<label for="corp_tag_input" >{'corptag'|@getFixedLabel}</label>
			{/if}
		</div>
		<div class="modulemaptagtop10">
			<input class="ld-input-inner" style="float: left;" type="text" fieldonly="0" tabindex="w" name="new_moduledata_tag" size="27" value="">
		</div>
	</div>
</div>
