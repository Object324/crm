{*<div class="E_pop_tit" id="dvProductToolEditField_head">*}
{*	{if $PRODUCTTOOLFIELDID > 0}*}
{*		<strong class="E_ptita">{'EDITPROPERTIES'|@getFixedLabel}</strong>*}
{*	{else}*}
{*		<strong class="E_ptita">{'LBL_ProductTool_field'|@getFixedLabel}</strong>*}
{*	{/if}*}
{*	<button class="E_ptitc" value="{'CLOSE'|@getFixedLabel}" onclick="closeEditFieldPopup();"></button>*}
{*</div>*}
<div name="layout-productfieldmaxheight" style="height:500px; width: 100%; overflow-y: auto;">
	<div id="changemenu" class="ld-ui-tabs">
		<ul class="ld-ui-tabs-nav">
			<li class="ld-ui-tabs-active" onclick="changeProductToolMenu(1)" tag="1"><a href="javascript:;">{'BASICPROPERTIES'|@getFixedLabel}</a></li>
			<li onclick="changeProductToolMenu(2)" tag="2" id="producttool_formula"><a href="javascript:;">{'INPUTMODE'|@getFixedLabel}</a></li>
			<li style="font-size: 13px;{if $reversetabshow neq 'yes'}display:none;{/if}" onclick="changeProductToolMenu(3)" tag="3"><a href="javascript:;">{'Triggercalculation'|@getFixedLabel}</a></li>
			{if $PRODUCTCOLUMN neq 'productname' && $PRODUCTCOLUMN neq 'expenseuse'}
				<li onclick="changeProductToolMenu(4)" tag="4">
					<a href="javascript:;">
						<div class="ld-btn-icontext-item">
							<span>{'LBL_FIELDS_ACCESS'|@getFixedLabel}</span><i tag="attachmentHelp_1109" class="ld-fonticon ld-fonticon-help2 icon-askgrey-help tip-items-list" data-tip="{'ENTRYFIELDSILLUSTRATE'|@getFixedLabel}" data-direction="bottom" data-type="position"></i>
						</div>
					</a>
				</li>
			{/if}
		</ul>
	</div>
	<input type="hidden" id="defaultcolumn" name="defaultcolumn" value="{$PRODUCTTOOLDETAILS.defaultcolumn}" />
	{*基本属性*}
	<div id="basicDiv">
		<input type="hidden" id="uitype" name="uitype" value="{$PRODUCTTOOLDETAILS.setuitype}" />
		<input type="hidden" id="frommodule" name="frommodule" value="{$MODULE}" />
		<input type="hidden" id="columnname" value="{$COLUMNNAME}"/>
		<table class="settingPopTable settingPopTableNoBot" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td align="right">{*字段类型*}
					{'fieldtype'|@getFixedLabel}
				</td>
				<td>
					{*UiType: 1->文本，2->文本区域,24->整数,20->数字,10->数量,50->金额,51~55->日期,163->单价,15->下拉框*}
					{$PRODUCTTOOLDETAILS.uitype}
				</td>
			</tr>
			<tr id="editfield_{$ID}heading" >{*中文标签*}
				<td width="145px" align="right">
					<font color="red">*</font>{'CNTAG'|@getFixedLabel}
				</td>
				<td align="left">
					<input type="text" value="{$PRODUCTTOOLDETAILS.zh_fieldlabel}" alt="{'CNTAG'|@getFixedLabel}" id="zh_fieldlabel" name="zh_fieldlabel" class="ld-input-inner gwidth90">
				</td>
			</tr>
			<tr>
				<td align="right">{*英文标签*}
					<font color="red">*</font>{'ENTAG'|@getFixedLabel}
				</td>
				<td>
					<input type="text" value="{$PRODUCTTOOLDETAILS.en_fieldlabel}" alt="{'ENTAG'|@getFixedLabel}" id="en_fieldlabel" name="en_fieldlabel" class="ld-input-inner gwidth90">
				</td>
			</tr>
			{if $PRODUCTTOOLDETAILS.newline neq '0' && $PRODUCTTOOLDETAILS.newline !=''}
				<input type="hidden" value="{$PRODUCTTOOLDETAILS.width}" alt="{'WIDTHMM'|@getFixedLabel}" id="width" name="width" class="ld-input-inner gwidth90">
			{else}
				<tr>
					<td align="right">{*列宽(MM)*}
						<font color="red">*</font>{'WIDTHMM'|@getFixedLabel}
					</td>
					<td>
						<input type="text" value="{$PRODUCTTOOLDETAILS.width}" alt="{'WIDTHMM'|@getFixedLabel}" id="width" name="width" class="ld-input-inner gwidth90">
					</td>
				</tr>
			{/if}
			{if $PRODUCTTOOLDETAILS.selectCon neq ''}
				{* ls 20230329 BUG0063326 CustomForm23 在该表单的分录设置里，将小数位数写成1然后保存，再打开，位数就变成空值了(输入框html内容selectCon是PHP返回的,前端显示了两套代码,后台取值也错了,就始终沒有保存成功)*}
				{$PRODUCTTOOLDETAILS.selectCon}
			{else}
				{assign var=uitypeoption value=$PRODUCTTOOLDETAILS.uitypeoption}
				<tr id="textlen" {if ($uitypeoption neq '1' && $PRODUCTTOOLDETAILS.inputtype neq 1) || $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' } style="display:none;"{/if}>
					<td align="right">{*字段长度*}
						<font color="red" >*</font>{'FIELDLENGTH'|@getFixedLabel}
					</td>
					<td>
						<input type="text" alt="{'FIELDLENGTH'|@getFixedLabel}" value="{$PRODUCTTOOLDETAILS.length}" id="textlength" name="textlength" class="ld-input-inner gwidth90">
					</td>
				</tr>
				<tr id="precision" {if $uitypeoption neq '20'} style="display:none;"{/if}>
					<td align="right">{*精度*}
						{'PRECISION'|@getFixedLabel}
					</td>
					<td>
						<input type="text" value="{$PRODUCTTOOLDETAILS.length}" id="precisionvalue" name="precisionvalue" class="ld-input-inner gwidth90">
					</td>
				</tr>
				{if $ISPRODUCTDETAILS eq 'yes'}
					<tr id="dateStyle" {if $uitypeoption > 50 && $uitypeoption < 55 && $PRODUCTTOOLDETAILS.input_type neq 1} style="display:;"{else}style="display:none;"{/if}>
						<td align="right">{*格式*}
							{'STYLE'|@getFixedLabel}
						</td>
						<td>
							<select id="selectDateStyle" class="ld-select-inner gwidth50"{if $PRODUCTTOOLFIELDID>0} disabled=""{/if}>
								<option value="51" {if $uitypeoption eq 51} selected {/if} >yyyy-mm-dd</option>
								<option value="52" {if $uitypeoption eq 52} selected {/if}>yyyy-mm-dd hh:mm:ss</option>
								<option value="53" {if $uitypeoption eq 53} selected {/if}>hh:mm</option>
								<option value="54" {if $uitypeoption eq 54} selected {/if}>hh:mm:ss</option>
							</select>
						</td>
					</tr>
				{else}
					<tr id="dateStyle" style="display:none;">
						<td align="right">{*格式*}
							{'STYLE'|@getFixedLabel}
						</td>
						<td>
							<select id="selectDateStyle" class="ld-select-inner gwidth50"{if $PRODUCTTOOLFIELDID>0} disabled=""{/if}>
								<option value="Date_Ymd" {if $uitypeoption eq 'Date_Ymd'} selected {/if} >yyyy-mm-dd</option>
								<option value="Date_YmdHms" {if $uitypeoption eq 'Date_YmdHms'} selected {/if}>yyyy-mm-dd hh:mm:ss</option>
								<option value="Date_Hm" {if $uitypeoption eq 'Date_Hm'} selected {/if}>hh:mm</option>
								<option value="Date_Hms" {if $uitypeoption eq 'Date_Hms'} selected {/if}>hh:mm:ss</option>
							</select>
						</td>
					</tr>
				{/if}
				<tr id="picklist_tr" {if ($uitypeoption eq 60 || $uitypeoption eq 63)&&$COLUMNNAME neq 'wareid'} style="display:;"{else}style="display:none;"{/if}>
					<td align="right">{*下拉框列表值*}
						<font color="red">*</font>{'Dropdownboxlistvalues'|@getFixedLabel}
					</td>
					<td valign="top" class="selectSpan" id="picklist_value" tag="{'Dropdownboxlistvalues'|@getFixedLabel}">
						<select class="js-example-tags form-control" multiple="multiple" id="fldpicklist">
							{foreach item=value from=$PICKLIST_VALUE}
								<option class="ld-picklistfield-tag" value="{$value}" selected>{$value}</option>
							{/foreach}
						</select>
					</td>
				</tr>
				{* edit: xll 2023/06/20 XUQIU1000357 分录增加附件字段（编辑字段不显示默认值行） *}
				<tr id="defaultvalue_tr"{if  $commissionsourcefield eq 'yes' || $expensesourcefield eq 'yes' ||
				in_array($PRODUCTTOOLDETAILS.fieldtype,array('Reference','Image','Attachment')) || $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes'
				||$PRODUCTTOOLDETAILS.tablename eq 'ld_products' || $PRODUCTTOOLDETAILS.tablename eq 'ld_productcf' ||
				in_array($PRODUCTTOOLDETAILS.setuitype,array(69,100,200,201,202,204,1109))}
					style="display:none;" {/if}>
					<td align="right">{*默认值*}
						{'LBL_DEFAULTVALUE'|@getFixedLabel}
					</td>
					<td>
						<input type="text" value="{$PRODUCTTOOLDETAILS.defaultvalue}" id="defaultvalue" name="defaultvalue" {if ($uitypeoption >= '51' && $uitypeoption <'55')||$uitypeoption eq 56 || (($uitypeoption eq 60 || $uitypeoption eq 63)&&$COLUMNNAME neq 'wareid')} style="display:none;" {/if} class="ld-input-inner gwidth90"  {if $PRODUCTTOOLDETAILS.columnname eq 'productname' && $PRODUCTTOOLDETAILS.defaultcolumn eq 2}disabled="" style="cursor: not-allowed;"{/if}>
						<div id="dateDesc" {if $uitypeoption < '51' || $uitypeoption >='55'} style="display:none;" {/if}>
							<select name="dateOption" id="dateOption" class="ld-select-inner gwidth50">
								<option value=""></option>
								<option value="thistoday"{if $PRODUCTTOOLDETAILS.defaultvalue eq 'thistoday'} selected{/if}>{'today'|@getFixedLabel}</option>
								<option value="tomorrow" {if $PRODUCTTOOLDETAILS.defaultvalue eq 'tomorrow'} selected{/if}>{'tomorrow'|@getFixedLabel}</option>
								<option value="nextmonthtoday" {if $PRODUCTTOOLDETAILS.defaultvalue eq 'nextmonthtoday'} selected{/if}>{'NEXTMONTHTODAY'|@getFixedLabel}</option>
								<option value="oneyear" {if $PRODUCTTOOLDETAILS.defaultvalue eq 'oneyear'}selected{/if}>{'OneYearLater'|@getFixedLabel}</option><!--一年后：明年今天的前一天-->
								<option value="beforeoneyear" {if $PRODUCTTOOLDETAILS.defaultvalue eq 'beforeoneyear'}selected{/if}>{'OneYearAgo'|@getFixedLabel}</option><!--一年前：去年今天的后一天-->
								{foreach key=key item=AfterDayitem from=$AfterDayInfo}
									<option value="{$AfterDayitem.value}" {if $PRODUCTTOOLDETAILS.defaultvalue eq $AfterDayitem.value}selected{/if}>{$AfterDayitem.label}</option>
								{/foreach}
								{foreach key=key item=DaysAgoitem from=$DaysAgoInfo}
									<option value="{$DaysAgoitem.value}" {if $PRODUCTTOOLDETAILS.defaultvalue eq $DaysAgoitem.value}selected{/if}>{$DaysAgoitem.label}</option>
								{/foreach}
							</select>
						</div>
						<div id="defaultvalue_picklist_div" {if (!in_array($PRODUCTTOOLDETAILS.setuitype,array(60,63))) || $COLUMNNAME eq 'wareid'}style="display:none;"{/if}>
							<select id="defaultvalue_picklist" name="defaultvalue_picklist" >
								<option class="ld-picklistfield-tag" value="" {if $PRODUCTTOOLDETAILS.defaultvalue eq ''}selected=""{/if}></option>
								{foreach item=value from=$PICKLIST_VALUE}
									<option class="ld-picklistfield-tag" value="{$value}" {if $value eq $PRODUCTTOOLDETAILS.defaultvalue}selected=""{/if}>{$value}</option>
								{/foreach}
							</select>
						</div>
						<div id="checkDiv" {if $uitypeoption !=56}style="display:none;" {/if}>
							<input type="checkbox" class="second_switch" id="checkcolumn" name="checkcolumn" {if $PRODUCTTOOLDETAILS.defaultvalue eq 1}checked{/if} value="">
						</div>
					</td>
				</tr>
			{/if}
			<tr id="tr_helptips">
				<td align="right">
					<div class="ld-btn-icontext-item">
						<span>{'HelpInformation'|@getFixedLabel}</span>
						<i data-tip="{'HoverQuestionMarkDisplay'|@getFixedLabel}" class="ld-fonticon ld-fonticon-help2 tip-items-list"></i>
					</div>
				</td>
				<td align="left" style="overflow: inherit;">
					<textarea type="text" id="helptips" name="helptips" class="ld-textarea-inner gwidth90">{$PRODUCTTOOLDETAILS.helptips}</textarea>
				</td>
			</tr>
			{*		zxm 2021-1230 字段颜色字段说明*}
			{if $PRODUCTTOOLDETAILS.uitypeoption eq 1||$PRODUCTTOOLDETAILS.uitypeoption eq 2||$PRODUCTTOOLDETAILS.fieldtype eq 'Text'||$PRODUCTTOOLDETAILS.fieldtype eq 'TextArea'}
				<tr id="tr_fieldplaceholder">
					<td align="right">{'FieldDescription'|@getFixedLabel}</td>
					<td align="left" style="overflow: inherit;">
						<input type="text" id="fieldplaceholder" name="fieldplaceholder" class="ld-input-inner gwidth90" value="{$PRODUCTTOOLDETAILS.fieldplaceholder}"/>
					</td>
				</tr>
			{/if}
			{if $PRODUCTTOOLDETAILS.uitypeoption eq 1||$PRODUCTTOOLDETAILS.uitypeoption eq 2||$PRODUCTTOOLDETAILS.fieldtype eq 'Text'||$PRODUCTTOOLDETAILS.fieldtype eq 'TextArea'
			||$PRODUCTTOOLDETAILS.uitypeoption eq 24||$PRODUCTTOOLDETAILS.uitypeoption eq 20||$PRODUCTTOOLDETAILS.uitypeoption eq 10||$PRODUCTTOOLDETAILS.uitypeoption eq 163||$PRODUCTTOOLDETAILS.uitypeoption eq 50
			||$PRODUCTTOOLDETAILS.fieldtype eq 'Num'||$PRODUCTTOOLDETAILS.uitypeoption eq 51}
				<tr id="tr_fieldvaluecolor">
					<td align="right">{'FieldColor'|@getFixedLabel}</td>
					<td align="left" style="overflow: inherit;">
						<div title="点击修改颜色" name="color_div" style="width: 21px;
								height: 21px;
								border-radius: 100%;
								cursor: pointer;
								border: 1px solid #dbdbdb;background: {$PRODUCTTOOLDETAILS.fieldvaluecolor};left:0;top:0;" onclick="chooseDetailFieldColor(this);">
						</div>
						<input type="hidden" id="fieldvaluecolor" name="fieldvaluecolor" class="ld-input-inner gwidth90" value="{$PRODUCTTOOLDETAILS.fieldvaluecolor}"/>
					</td>
				</tr>
			{/if}
			{*引用对象*}
			<tr id="tr_relatedmodule" {if $PRODUCTTOOLDETAILS.relatedmodulefield neq 'yes'} style="display:none;"{/if}>
				<td align="right">
					<font color="red">*</font>{'RelatedModule'|@getFixedLabel}
				</td>
				<td style="overflow: inherit;">
					{if $PRODUCTTOOLFIELDID gt 0}
						{$RELATEDMODULE_INFO.modulelabel}
						<input type="hidden" id="select_related_module" value="{$RELATEDMODULE_INFO.frommodule}" />
					{else}
						{if $SELECTED_REFERCENCEMODULE|@count gt 0}
							<select class="btn-radius-system" name="select_related_module" id="select_related_module" onchange="getReferencemoduleField(this)">
								{foreach key=referencemodule item=info from=$SELECTED_REFERCENCEMODULE}
									<option value="{$referencemodule}" column="{$info.columnname}" bigtype="{$info.bigtype}" >{$info.fieldlabel}</option>
								{/foreach}
							</select>
						{/if}
					{/if}
				</td>
			</tr>
			{*引用字段*}
			<tr id="tr_relatedmodulefield" name="tr_relatedmodulefield" {if $PRODUCTTOOLDETAILS.relatedmodulefield neq 'yes' || $RELATEDMODULE_INFO.fromvalue_type eq 'selectsource'} style="display:none;"{/if}>
				<td align="right">
					<font color="red">*</font>{'REFERENCEFIELD'|@getFixedLabel}
				</td>
				<td style="overflow: inherit;">
					{if $PRODUCTTOOLFIELDID gt 0}
						{$RELATEDMODULE_INFO.fieldlabel}
						<input type="hidden" id="relatedmodulefield" value="{$RELATEDMODULE_INFO.frommodule_column}" />
					{else}
						<input type="hidden" value="{$RELATEDMODULE_INFO.frommodule_column}" name="relatedmodule_column" id="relatedmodule_column" >
						<select id="relatedmodulefield" name="relatedmodulefield" onchange="selectedIsHrefFiled(this)">

						</select>
					{/if}
				</td>
			</tr>
			{*引用字段 - 源单*}
			<tr id="tr_optionmodulefield" name="tr_optionmodulefield" {if $RELATEDMODULE_INFO.fromvalue_type eq 'selectsource'}style=""{else}style="display:none;"{/if}>
				<td align="right" colspan="2">
					<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
						<input type="hidden" name="optionmodule_string" id="optionmodule_string" value="{$OPTIONMODULEARRAY}" />
						<input type="hidden" name="fromvalue_type" id="fromvalue_type" value="{$RELATEDMODULE_INFO.fromvalue_type}" />
						{if $SELECTSOURCE_FIELDBIGTYPE neq ''}{*已经设置的引用字段类型*}
							<input type="hidden" name="selectsource_fieldbigtype" id="selectsource_fieldbigtype" value="{$SELECTSOURCE_FIELDBIGTYPE}" />
						{/if}
						{if $SELECTSOURCE_FIELDREFERENCEMODULE neq ''}{*引用关联选择单据字段对应模块*}
							<input type="hidden" name="selectsource_fieldreferencemodule" id="selectsource_fieldreferencemodule" value="{$SELECTSOURCE_FIELDREFERENCEMODULE}" />
						{/if}
						<tr>
							<td align="center">源单类型</td>
							<td align="center"><font color="red">*</font>{'REFERENCEFIELD'|@getFixedLabel}</td>
						</tr>
						{foreach key=modulename item=moduleinfo from=$OPTIONMODULES}
							<tr>
								<td align="center">{$moduleinfo.modulelabel}</td>
								<td align="center">
									{if $moduleinfo.fieldlabel neq ''}
										{$moduleinfo.fieldlabel}
									{else}
										<select class="ld-select-inner gwidth50" id="relatedsourcefield_{$modulename}" name="relatedsourcefield_{$modulename}">
											<option value=""></option>
											{foreach key=blocklabel item=fieldinfos from=$moduleinfo.fields}
												<optgroup label="{$blocklabel}" class="select" style="border:none">
													{foreach item=fieldinfo from=$fieldinfos}
														<option columntype="{$fieldinfo.columntype}" bigtype="{$fieldinfo.bigtype}" referencemdoule="{$fieldinfo.referencemdoule}" value="{$fieldinfo.columnname}">{$fieldinfo.fieldlabel}</option>
													{/foreach}
												</optgroup>
											{/foreach}
										</select>
									{/if}
								</td>
							</tr>
						{/foreach}
					</table>

				</td>
			</tr>

			<tr id="tr_referencemodule" {if $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' ||( $PRODUCTTOOLDETAILS.setuitype neq 100 && $PRODUCTTOOLDETAILS.fieldtype neq 'Reference' )} style="display:none;"{/if}>
				<td align="right">{*关联选择对象*}
					<font color="red">*</font>{'RelateChoiceModule'|@getFixedLabel}
				</td>
				<td style="overflow: inherit;">
					{if $PRODUCTTOOLDETAILS.referencemodule neq ''}
						<input type="hidden" id="referencemodule" value="{$REFRESHMODULE}" />
						{$REFRESHMODULELABEL}
					{else}
						{assign var="optText" value=''}
						<select  id="referencemodule" name="referencemodule" style="display:none">
							{foreach from=$CANSELECTMODULES item=info}
								{if $info.name eq $REFRESHMODULE}
									{assign var="optText" value=$info.label}
								{/if}
								<option value="{$info.name}" {if $info.name eq $REFRESHMODULE}selected{/if}>{$info.label}</option>
							{/foreach}
						</select>
						{assign var=fldname value=referencemodule}
						<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single"   style="width:195px;"  onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
							<a class="chzn-single" style="width:190px;" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
								<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: {if $CALENDARTEMPLATEDETAILS eq ''}185px{else}105px{/if};margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
								<div>
									<b></b>
								</div>
							</a>
							<div style=" left:-9000px;width: 190px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
								<ul class="chzn-results" name="cmb_ul_{$fldname}">
									{assign var="i" value=0}
									{foreach item=info from=$CANSELECTMODULES}

										<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$info.name}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$info.label}</li>

										{assign var="i" value=$i+1}
									{/foreach}
									<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
								</ul>
							</div>
						</div>
					{/if}
				</td>
			</tr>
			<tr id="tr_datarang" {if $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes'|| ( $PRODUCTTOOLDETAILS.setuitype neq 100  && $PRODUCTTOOLDETAILS.fieldtype neq 'Reference' )} style="display:none;"{/if}>{*可选择的数据范围*}
				<td align="right"><font color="red">*</font>{'ALLOWDataRange'|@getFixedLabel}</td>
				<td align="left">
					<select  id="datarange" name="datarange" class="btn-radius-system" style="width: 110px;">
						<option value="all" {if $PRODUCTTOOLDETAILS.datarange eq 'all'}selected{/if} >{'ALL'|@getFixedLabel}</option>
						<option value="permit" {if $PRODUCTTOOLDETAILS.datarange eq 'permit'}selected{/if}>{'ALLOWINQUIRE'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
			<tr id="tr_approvedemand" {if $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' || ($PRODUCTTOOLDETAILS.setuitype neq 100 && $PRODUCTTOOLDETAILS.fieldtype neq 'Reference'  )} style="display:none;"{/if}>{*审批要求*}
				<td align="right"><font color="red">*</font>{'APPROVEDEMAND'|@getFixedLabel}</td>
				<td align="left">
			<span style="float: left;">
			 <select id="approve_demand" name="approve_demand" class="btn-radius-system" style="width: 110px;">
				  <option value="none" {if $PRODUCTTOOLDETAILS.approve_demand eq 'none'}selected{/if}>{'NONE'|@getFixedLabel}</option>
				  <option value="approve" {if $PRODUCTTOOLDETAILS.approve_demand eq 'approve'}selected{/if}>{'Approved'|@getFixedLabel}</option>
			  </select>
			  </span>
					{*@edit:chj,2022/6/20,reason:ID1000927/页面设置，选择源单增加其他条件，可设置选择源单过滤条件*}
					<div style="float: left;margin-left:10px;margin-top: 10px;" name="approve_condition_set" id="approve_condition_set" >
						<a onclick="get_detail_effective_condition('reference')">{'OtherConditions'|getFixedLabel}</a>
						<input id="reference_advft_criteria_groups" name="reference_advft_criteria_groups" type="hidden" value='{$reference_advft_criteria_groups}' />
						<input id="reference_advft_criteria" name="reference_advft_criteria" type="hidden" value='{$reference_advft_criteria}' />
					</div>
				</td>
			</tr>
			<tr id="tr_maxrowsshow" {if  $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' || ($PRODUCTTOOLDETAILS.setuitype neq 100 && $PRODUCTTOOLDETAILS.fieldtype neq 'Reference' ) } style="display:none;"{/if}>{*最多显示数据条数*}
				<td align="right"><font color="red">*</font>{'MaxRowsShow'|@getFixedLabel}</td>
				<td align="left">
					<select  id="maxrowsshow" name="maxrowsshow" class="btn-radius-system" style="width: 110px;">
						<option value="1" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 1}selected{/if}>1</option>
						<option value="5" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 5}selected{/if}>5</option>
						<option value="10" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 10}selected{/if}>10</option>
						<option value="15" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 15}selected{/if}>15</option>
						<option value="20" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 20}selected{/if}>20</option>
						<option value="50" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 50}selected{/if}>50</option>
						<option value="100" {if $PRODUCTTOOLDETAILS.maxrowsshow eq 100}selected{/if}>100</option>
					</select>
				</td>
			</tr>
			<tr>
				<td align="right">	{*是否启用*}
					{'ACTIVATE'|@getFixedLabel}
				</td>
				<td>
					{if $PRODUCTTOOLDETAILS.defaultcolumn eq 2 || $PRODUCTTOOLDETAILS.defaultcolumn eq 6 ||  $PRODUCTTOOLDETAILS.defaultcolumn eq 8  || ($PRODUCTTOOLDETAILS.presence eq 0 && $PRODUCTTOOLDETAILS.typeofdata eq 'M')||($PRODUCTTOOLDETAILS.presence eq 2 && $PRODUCTTOOLDETAILS.typeofdata eq 'M')}
						<input type="checkbox" class="second_switch" checked="true" id="presence_check" {if $PRODUCTTOOLDETAILS.allowhide  eq 'no'}disabled {/if} />
					{elseif  $PRODUCTTOOLDETAILS.presence eq 0 || $PRODUCTTOOLDETAILS.presence eq 3}
						<input type="checkbox" class="second_switch" checked="true" allowhide="{$PRODUCTTOOLDETAILS.allowhide}" id="presence_check" {if $PRODUCTTOOLDETAILS.allowhide  eq 'no'} disabled {/if}>
					{else}
						<input type="checkbox" class="second_switch" id="presence_check" allowhide="{$PRODUCTTOOLDETAILS.allowhide}"    {if $PRODUCTTOOLDETAILS.allowhide  eq 'no'} disabled {/if}>
					{/if}
				</td>
			</tr>
			{*保存到数据库*}
			<tr id="tr_savedatabase" {if $PRODUCTTOOLDETAILS.relatedmodulefield neq 'yes'} style="display:none;"{/if}>
				<td align="right">{'Savetodatabase'|@getFixedLabel}</td>
				<td align="left">
					<input type="checkbox" class="second_switch" id="savedatabase" name="savedatabase" value="{$PRODUCTTOOLDETAILS.savedatabase}" {if $PRODUCTTOOLDETAILS.savedatabase eq 'yes'}checked{/if} onclick="enableSavedatabaseCheckBox(this)" />
				</td>
			</tr>
			<tr id="is_edit_tr" {if $PRODUCTTOOLDETAILS.setuitype eq 100 ||  $PRODUCTTOOLDETAILS.fieldtype eq 'Reference'  || $PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes'} style="display:none;"{/if}>
				<td align="right">{*允许编辑*}
					{'ALLOWEDITING'|@getFixedLabel}
				</td>
				<td>
					{if $PRODUCTTOOLDETAILS.defaultcolumn eq 5}
						{if $PRODUCTTOOLDETAILS.edit_permission eq 0}
							<input type="checkbox" class="second_switch" checked="true" id="is_edit">
						{else}
							<input type="checkbox" class="second_switch" class="second_switch" id="is_edit">
						{/if}
					{else}
						{if $expensesourcefield eq 'yes' || $PRODUCTTOOLDETAILS.defaultcolumn eq 2 || $PRODUCTTOOLDETAILS.defaultcolumn eq 6 || $PRODUCTTOOLDETAILS.defaultcolumn eq 7 || $PRODUCTTOOLDETAILS.defaultcolumn eq 3||$PRODUCTTOOLDETAILS.defaultcolumn eq 4 || $PRODUCTTOOLDETAILS.input_type eq 1}
							{assign var=isedit_true value=true}
						{else}
							{assign var=isedit_true value=false}
						{/if}
						{if $PRODUCTTOOLDETAILS.edit_permission eq 0}
							<input type="checkbox" class="second_switch" checked="true" id="is_edit" {if $isedit_true eq true || ($PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' && $PRODUCTTOOLDETAILS.savedatabase eq 'no')||$PRODUCTTOOLDETAILS.bigtype eq 'multipicklist'} disabled {/if}>
						{else}
							<input type="checkbox" class="second_switch" id="is_edit" {if $isedit_true eq true || ($PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' && $PRODUCTTOOLDETAILS.savedatabase eq 'no')||$PRODUCTTOOLDETAILS.bigtype eq 'multipicklist'} disabled {/if}>
						{/if}
					{/if}
				</td>
			</tr>
			<tr id="tr_selectpricefrombook" {if $PRODUCTTOOLDETAILS.columnname eq 'listprice' && $PRODUCTTOOLDETAILS.edit_permission eq 0 } {else}style="display:none;"{/if}>
				<td align="right">{*仅允许从价格表选择*}
					{'selectPriceFromPriceBook'|@getFixedLabel}
				</td>
				<td>
					<input type="checkbox" class="second_switch" {if $PRODUCTTOOLDETAILS.selectpricefrombook eq 'yes'}checked{/if} id="selectpricefrombook">
				</td>
			</tr>
			<tr>
				<td align="right">{*必填字段*}
					{'Required_fields'|@getFixedLabel}
				</td>
				<td>
					{if $PRODUCTTOOLDETAILS.defaultcolumn eq 5}
						{if $PRODUCTTOOLDETAILS.typeofdata eq 'M'}
							<input type="checkbox" class="second_switch" checked="true"  onclick=" enableDisableCheckBox(this,'presence_check'); " id="mandatory_check" >
						{else}
							<input type="checkbox" class="second_switch"  onclick=" enableDisableCheckBox(this,'presence_check'); " id="mandatory_check"  >
						{/if}
					{else}
						{assign var=disabled_str value= ''}
						{if $PRODUCTTOOLDETAILS.defaultcolumn eq 2 || $PRODUCTTOOLDETAILS.defaultcolumn eq 3||$PRODUCTTOOLDETAILS.defaultcolumn eq 4||$PRODUCTTOOLDETAILS.input_type eq 1  || ($PRODUCTTOOLDETAILS.relatedmodulefield eq 'yes' && $PRODUCTTOOLDETAILS.savedatabase eq 'no')}
							{assign var=disabled_str value= 'disabled'}
						{/if}

						{if $PRODUCTTOOLDETAILS.typeofdata eq 'M'}
							<input type="checkbox" class="second_switch" checked="true" onclick=" enableDisableCheckBox(this,'presence_check'); " id="mandatory_check" {$disabled_str}>
						{else}
							<input type="checkbox" class="second_switch" onclick=" enableDisableCheckBox(this,'presence_check'); " id="mandatory_check" {$disabled_str}>
						{/if}
					{/if}
				</td>
			</tr>
            {* edit: xll 2023/05/22 XUQIU1001203 产品分录-关联选择单据、源单增加显示超链接 *}
            <tr id = "ShowHyperlinks_tr"
            {if $PRODUCTTOOLDETAILS.bigtype neq 'reference' and $PRODUCTTOOLDETAILS.bigtype neq 'selectsource' and
			$PRODUCTTOOLDETAILS.isHrefField neq  'yes' and $PRODUCTTOOLDETAILS.setuitype neq 202}
                style="display:none" 
            {/if}
			{if $PRODUCTTOOLDETAILS.bigtype eq 'selectsource' and ($commissionsourcefield eq 'yes' || $expensesourcefield eq 'yes')}
                style="display:none"
            {/if}
            >
        		<td align="right">
        			{'SHOWHYPERLINKS'|@getFixedLabel}
        		</td>
        		<td>
        			<input type="checkbox" class="second_switch" onclick=" enableDisableCheckBox(this,'presence_check'); " id="ShowHyperlinks_check"
                    {if $PRODUCTTOOLDETAILS.ShowHyperlinks eq 'yes'}
                        checked
                    {/if}
                    >
          		</td>
        	</tr>
			{* edit: hzx 是否小计 *}
			<tr id = "subtotal_attr_tr"
					{if in_array($PRODUCTTOOLDETAILS.setuitype,array('10','7','20','24','28','29','32','50')) || in_array($PRODUCTTOOLDETAILS.fieldtype,array('Num','Number','Int','Amount','RMB_Amount'))}{else}
						style="display:none"
					{/if}>
				<td align="right">
					{'CalculateSubtotal'|@getFixedLabel}
				</td>
				<td>
					<input type="checkbox" class="second_switch" onclick=" enableDisableCheckBox(this,'presence_check'); " id="subtotal_attr_check"
							{if $PRODUCTTOOLDETAILS.subtotal_attr eq 'yes'}
								checked
							{/if}
					>
				</td>
			</tr>
			{* edit: xxy 2023-11-15 内容过多自动换行 *}
			<tr id = "auto_wordwrap_tr"
					{if $PRODUCTTOOLDETAILS.bigtype eq 'image' || $PRODUCTTOOLDETAILS.bigtype eq 'fileattachment'}
						style="display:none"
					{/if}>
				<td align="right">
					{'AutoWordWrap'|@getFixedLabel}
				</td>
				<td>
					<input type="checkbox" class="second_switch" onclick=" enableDisableCheckBox(this,'presence_check'); " id="auto_wordwrap_check"
						{if $PRODUCTTOOLDETAILS.auto_wordwrap eq 'yes'}
							checked
						{/if}
					>
				</td>
			</tr>
			{*	XUQIU1001134 zxm 20230315 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰） 注释该功能
            <tr>
                <td align="right">
                    <span>{'MOBILEDETAILSHOW'|@getFixedLabel}</span><b style="margin-bottom: 4px;" title="{'FIELDDISPLAYINMOBILEDETAIL'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
                </td>
                <td>
                    <input type="checkbox" class="second_switch"  onclick="" id="mobiledetailshow"
                        {if $PRODUCTTOOLDETAILS.mobiledetailshow eq 'yes'}checked{/if} {if $PRODUCTTOOLDETAILS.columnname eq 'productname' || $PRODUCTTOOLDETAILS.columnname eq 'subtotal' || $PRODUCTTOOLDETAILS.newline eq '1' }disabled{/if} >
                  </td>
            </tr>*}
			{* editor:gyq_10 reason:字段类型后的动态内容 date:2016 04 20*}

			
			{*  		{if $PRODUCTCOLUMN neq 'productname' && $PRODUCTCOLUMN neq 'expenseuse'}*}
			{*  			<tr>*}
			{*  				<td align="right">*}{*适用范围*}
			{*  					{'APPLICABLESCOPE'|@getFixedLabel}*}
			{*  				</td>*}
			{*  				<td class="select-input">*}
			{*					<label ><input type="radio" name="profile_field_type" id="profile_field_type" value = "-1" {if $profilefieldtype eq ''} checked {/if} /><span class="padR10">&nbsp;{'ALL'|@getFixedLabel}</span></label>*}
			{*					<label ><input type="radio" name="profile_field_type" id="profile_field_type" value = "2" {if $profilefieldtype eq 'group'} checked {/if} onclick="setProductToolFieldGroup('{$PRODUCTTOOLFIELDID}','{$MODULE}','{$PROFILEFIELDUSERIDS}')" /><span class="padR10">&nbsp;{'SETBYDEPARTMENT'|@getFixedLabel}</span></label>*}
			{*					<label ><input type="radio" name="profile_field_type" id="profile_field_type" value = "1" {if $profilefieldtype eq 'user'} checked {/if} onclick="setProductToolFieldUser('{$PRODUCTTOOLFIELDID}','{$MODULE}','{$PROFILEFIELDUSERIDS}')" /><span class="padR10">&nbsp;{'SETBYUSERS'|@getFixedLabel}</span></label>*}
			{*					<label ><input type="radio" name="profile_field_type" id="profile_field_type" value = "3" {if $profilefieldtype eq 'role'} checked {/if} onclick="setproducttoolfieldprofile_idx('hidden_pro_profile_value')" /><span class="padR10">&nbsp;{'SetByRole'|@getFixedLabel}</span></label>*}
			{*                    <input type="hidden" name="hidden_pro_profile_value" id="hidden_pro_profile_value" value="{$PROFILEFIELDUSERIDS}" />*}
			{*                    <input type="hidden" name="hidden_pro_profilefieldtype" id="hidden_pro_profilefieldtype" value="{$profilefieldtype}" />*}
			{*  				</td>*}
			{*  			</tr>*}
			{*  		{/if}*}
		</table>
		{if $commissionsourcefield eq 'yes' || $expensesourcefield eq 'yes'}
			<div class="editrelhead">
				<b>{'LBL_Optionalmodule_Customization'|@getFixedLabel}</b>
			</div>
			<div name='sourcelist' style="padding: 5px 10px;">
				{include file="Settings/SelectSourceList.tpl"}
			</div>
		{/if}
	</div>
	{*高级属性*}
	<div id="advanceDiv" style="display:none;">
		<table class="settingPopTable settingPopTableNoBot" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td width="120px" align="right">
					{'INPUTMODE'|@getFixedLabel}
				</td>
				<td align="left">
					{*wym 231226 BUG0077413 单据分录定制->销售订单，“数字111”编辑字段属性界面，录入方式无法从手动录入修改为“通过字段公式计算”*}
					{*UiType: 24->整数,20->数字,50->金额,163->单价*}
					<select class="ld-select-inner gwidth50" name="inputModeType" id="inputModeType" onChange='selectInputMode(this)' {if $PRODUCTTOOLFIELDID > 0 && $PRODUCTTOOLDETAILS.changeinputtype eq 'no'}style="cursor: not-allowed;" disabled{/if}>
						<option value="0"{if $PRODUCTTOOLDETAILS.input_type eq 0}selected="true"{/if} >{'MANUALINPUT'|@getFixedLabel}</option>
						{* 2024-8-20 xxy 预置的单据分录字段，不允许修改录入方式为"产品属性" *}
						{if $ISPRODUCTDETAILS eq 'yes' && (!($PRODUCTTOOLFIELDID > 0 && $PRODUCTTOOLDETAILS.defaultcolumn neq 1) || $PRODUCTTOOLDETAILS.input_type eq 1)}
							<option value="1" {if $PRODUCTTOOLDETAILS.input_type eq 1}selected="true"{/if}>{'THEFIELDBASEDONTHEBASICENTRY'|@getFixedLabel}</option>
						{/if}
						<option value="2"{if $PRODUCTTOOLDETAILS.input_type eq 2}selected="true"{/if} >{'USINGTHEFORMULA'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
			<tr id='attributeDiv' {if $PRODUCTTOOLDETAILS.input_type eq 1}style='display:;'{else}style='display:none;'{/if}>
				<td align="right" >
					{'ATTRIBUTEFIELD'|@getFixedLabel}
				</td>
				<td align="left">
					<select name="attributeField" id="attributeField" class="ld-select-inner gwidth50">
						{foreach key=fieldid item=fieldlabel from=$FIELDDETAILS}
							<option value="{$fieldid}" {if $PRODUCTTOOLDETAILS.fieldid eq $fieldid}selected{/if}>{$fieldlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
			{*定义变量*}
			<tr id='definingDiv' style='display:none;'>
				<td align="left" class="editrelhead" colspan='2'>
					<b style="font-size:13px;">{'DEFININGVARUABLE'|@getFixedLabel}</b>
				</td>
			</tr>
			<tr id='definingContentDiv' {if   $PRODUCTTOOLDETAILS.input_type<2} style='display:none;'{/if}>
				<td align="left" colspan='2'>
					<div id="productDiv" style="height:250px;overflow-x: auto;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" id="toolfieldFormula" class="toolfield formual_td">
							{$FORMULAHTML}
							<tr>
								<td colspan="3">
									<a href="javascript:;" style="margin: 0px 5px;" title="{'NewVar'|@getFixedLabel}" onclick="addFormulaTableTr(1)">{'NewVar'|@getFixedLabel}</a>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			{*定义公式*}
			<tr id='mulaDiv' {if $PRODUCTTOOLDETAILS.input_type<2} style='display:none;' {/if}>
				<td align="left" class="editrelhead" colspan='2'>
					<b>{'DEFINITIONFORMULA'|@getFixedLabel}</b>
				</td>
			</tr>
			<!--can 2022-02-22 050045: （https://81mis.com/kfbcrm [^] ）在分录中（不是产品分录）添加单价金额等字段，高级属性选择通过计算公式，保存后不能修改公式-->
			<tr id='mulaContentDiv'{if $PRODUCTTOOLDETAILS.input_type<2 ||$PRODUCTTOOLDETAILS.input_type<2} style='display:none;'{/if}>
				<td align="left" colspan='2'>
					<input style="margin-top: 15px;" type="text" id="definitionformula" name="definitionformula" value="{$PRODUCTTOOLDETAILS.formulastring}" class="ld-input-inner" />
				</td>
			</tr>
		</table>
	</div>
	{*反写*}
	<div id="dvreverse" style="display:none;">
		<table class="settingPopTable settingPopTableNoBot" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td width="120px" align="right">
					{'Triggercalculationcontent'|@getFixedLabel}
				</td>
				<td align="left">
					<select name="reversefieldtype" id="reversefieldtype" onchange="changereverfieldtype(ld(this))" class="ld-select-inner gwidth50">
						<option value="listprice" {if $reversefieldtype eq 'listprice'} selected=""{/if}>{'LISTPRICE'|@getFixedLabel}</option>
						<option value="discount" {if $reversefieldtype eq 'discount'} selected=""{/if}>{'DISCOUNT'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
		</table>
		<div id="reverseformulalist">
			{include file="ReverseFormulaList.tpl"}
		</div>
	</div>
	{*字段权限*}
	{if $PRODUCTCOLUMN neq 'productname' && $PRODUCTCOLUMN neq 'expenseuse'}
		<div id="fields_access_div" style="display: none;">
			<div class="marLR8 marT8" style="overflow: hidden;">
				<span style="float: left;margin-right: 5px;line-height: 25px;">{'SETVISIBLERANGEFIELDS'|@getFixedLabel}</span>
				<select class="ld-select-inner" id="entry_fields_scope" name="entry_fields_scope" style="width:120px;" onchange="Entry_Fields_Accessobj.changescopeselect(this)">
					<option value="all">{'ALL'|@getFixedLabel}</option>
					<option value="group" {if $profilefieldtype == 'group'}selected{/if}>{'SETBYDEPARTMENT'|@getFixedLabel}</option>
					<option value="user" {if $profilefieldtype == 'user'}selected{/if}>{'SETBYUSERS'|@getFixedLabel}</option>
					<option value="role" {if $profilefieldtype == 'role'}selected{/if}>{'SetByRole'|@getFixedLabel}</option>
				</select>
				<input type="hidden" name="hidden_pro_profile_value" id="hidden_pro_profile_value" value="{$PROFILEFIELDUSERIDS}" />
				<input type="hidden" name="hidden_pro_profilefieldtype" id="hidden_pro_profilefieldtype" value="{$profilefieldtype}" />
			</div>
			<div id="entry_field_scope_list_top" style="margin-top: 8px;">
				<table class="settingPopTable" width="100%" cellspacing="0" cellpadding="0" border="0" id="entryfields_scope_tab">
					<tbody>
					<tr style="background-color: #f4f8fe;">
						<td rowspan="3" class="tabtdboard" width="20%" id="entry_scope_label">
							{if $profilefieldtype == 'group'}
								<b>{'SETBYDEPARTMENT'|@getFixedLabel}</b>
							{elseif $profilefieldtype == 'user'}
								<b>{'SETBYUSERS'|@getFixedLabel}</b>
							{elseif $profilefieldtype == 'role'}
								<b>{'SetByRole'|@getFixedLabel}</b>
							{else}
								<b>{'ALL'|@getFixedLabel}</b>
							{/if}
						</td>
					</tr>
					<tr style="background-color: #f4f8fe;">
						<td align="center" class="tabtdboard" width="20%"><b>{'Newinterface'|@getFixedLabel}</b></td>
						<td align="center" class="tabtdboard" width="20%"><b>{'Editinginterface'|@getFixedLabel}</b></td>
						<td align="center" class="tabtdboard" width="15%"><b>{'Viewinterface'|@getFixedLabel}</b></td>
						<td align="center" class="tabtdboard" width="15%" ><b>{'OPERATING'|@getFixedLabel}</b></td>
					</tr>
					<tr style="background-color: #f4f8fe;">
						<td align="center" class="tabtdboard">
							<div class="entrycopetabinput select-input">
								<label><input type="checkbox" name="all_createview_visible" {if $PRODUCTTOOLFIELDID>0}{else}checked{/if} {if $profilefieldtype == 'all' && $PROFILEFIELDDETAILSARRAY|@count > 0 && $PROFILEFIELDDETAILSARRAY[0]['create_profile'] != 'hidden'}checked{/if}/><span>{'VISIBLE'|@getFixedLabel}</span></label>
								<label><input type="checkbox" name="all_createview_edit" {if $PRODUCTTOOLFIELDID>0}{else}checked{/if} {if $profilefieldtype == 'all' && $PROFILEFIELDDETAILSARRAY|@count > 0 && $PROFILEFIELDDETAILSARRAY[0]['create_profile'] == 'write'}checked{/if} style="margin-left: 10px;"/><span>{'EDITABLE'|@getFixedLabel}</span></label>
							</div>
						</td>
						<td align="center" class="tabtdboard">
							<div class="entrycopetabinput select-input">
								<label><input type="checkbox" name="all_editview_visible" {if $PRODUCTTOOLFIELDID>0}{else}checked{/if} {if $profilefieldtype == 'all' && $PROFILEFIELDDETAILSARRAY|@count > 0 && $PROFILEFIELDDETAILSARRAY[0]['edit_profile'] != 'hidden'}checked{/if}/><span>{'VISIBLE'|@getFixedLabel}</span></label>
								<label><input type="checkbox" name="all_editview_edit" style="margin-left: 10px;" {if $PRODUCTTOOLFIELDID>0}{else}checked{/if} {if $profilefieldtype == 'all' && $PROFILEFIELDDETAILSARRAY|@count > 0 && $PROFILEFIELDDETAILSARRAY[0]['edit_profile'] == 'write'}checked{/if}/><span>{'EDITABLE'|@getFixedLabel}</span></label>
							</div>
						</td>
						<td align="center" class="tabtdboard">
							<div class="entrycopetabinput select-input">
								<label><input type="checkbox" name="all_detailsview_visible" {if $PRODUCTTOOLFIELDID>0}{else}checked{/if} {if $profilefieldtype == 'all' && $PROFILEFIELDDETAILSARRAY|@count > 0 && $PROFILEFIELDDETAILSARRAY[0]['details_profile'] != 'hidden'}checked{/if}/><span>{'VISIBLE'|@getFixedLabel}</span></label>
							</div>
						</td>
						<td align="center" class="tabtdboard">
						</td>
					</tr>
					</tbody>
				</table>
			</div>
			<div id="entry_field_scope_list" style="width: 100%;overflow: auto;max-height:248px;overflow-x: hidden;{if $PROFILEFIELDDETAILSARRAY|@count > 0 && $profilefieldtype != 'all'}{else}display: none;{/if}">
				<table class="settingPopTable" width="100%" cellspacing="0" cellpadding="0" border="0" id="entryfields_scope_tab" style="width: 650px;">
					<tbody>
					{if $PROFILEFIELDDETAILSARRAY|@count > 0 && $profilefieldtype != 'all'}
						{foreach key=relatedid item=fieldprofileinfo from=$PROFILEFIELDDETAILSARRAY}
							<tr name="selectid_{$relatedid}" data-relatedid="{$relatedid}">
								<td align="left" width="20%" class="tabtdboard"><label>{$fieldprofileinfo['raleted_label']}</label></td>
								<td align="center" width="20%" class="tabtdboard"><div class="entrycopetabinput select-input">
										<label><input name="createview_visible" data-relatedid="{$relatedid}" type="checkbox" {if $fieldprofileinfo['create_profile'] != 'hidden'}checked{/if}/><span>{'VISIBLE'|@getFixedLabel}</span></label>
										<label><input name="createview_edit" data-relatedid="{$relatedid}" type="checkbox" style="margin-left: 10px;" {if $fieldprofileinfo['create_profile'] == 'write'}checked{/if}/><span>{'EDITABLE'|@getFixedLabel}</span></label>
									</div>
								</td>
								<td align="center" width="20%" class="tabtdboard"><div class="entrycopetabinput select-input">
										<label><input name="editview_visible" data-relatedid="{$relatedid}" type="checkbox" {if $fieldprofileinfo['edit_profile'] != 'hidden'}checked{/if}/><span>{'VISIBLE'|@getFixedLabel}</span></label>
										<label><input name="editview_edit" data-relatedid="{$relatedid}" type="checkbox" style="margin-left: 10px;" {if $fieldprofileinfo['edit_profile'] == 'write'}checked{/if}/><span>{'EDITABLE'|@getFixedLabel}</span></label>
									</div>
								</td>
								<td align="center" width="15%" class="tabtdboard"><div class="entrycopetabinput select-input">
										<label><input name="detailsview_visible" data-relatedid="{$relatedid}" type="checkbox" {if $fieldprofileinfo['details_profile'] != 'hidden'}checked{/if}/><span>{'VISIBLE'|@getFixedLabel}</span></label>
									</div>
								</td>
								<td align="center" width="15%" class="tabtdboard"><a class="Anu3_a redFont" onclick="Entry_Fields_Accessobj.Deleteline_scop('{$relatedid}');">{'DELETE'|@getFixedLabel}</a></td>
							</tr>
						{/foreach}
					{/if}
					</tbody>
				</table>
			</div>
			<div id="entry_field_scope_list_foot" style="{if $PROFILEFIELDDETAILSARRAY|@count > 0 && $profilefieldtype != 'all'}{else}display: none;{/if}">
				<table class="settingPopTable" width="100%" cellspacing="0" cellpadding="0" border="0" id="entryfields_scope_tab">
					<tbody>
					<tr>
						<td class="tabtdboard">
							<a class="Anu3_a" onclick="Entry_Fields_Accessobj.Addline_scope()">{'ADDLINE'|@getFixedLabel}</a>
							<a class="Anu3_a" onclick="Entry_Fields_Accessobj.empty_scop_table()">{'EMPTY'|@getFixedLabel}</a>
						</td>
					</tr>
					</tbody>
				</table>
			</div>
		</div>
	{/if}
</div>
{*<div class="E_pbtn" id="dvProductToolEditField_popupbottom">*}
{*	<input type="button" class="E_pbtnok ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}"  onclick="saveFieldInfo('{$TABID}','{$PRODUCTTOOLFIELDID}');"/>*}
{*	<input type="button" class="E_pbtncancel ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" onclick="closeEditFieldPopup();"/>*}
{*</div>*}
<style>
	.entrycopetabinput{
		line-height: 40px;
	}
	.settingPopTable tr td.tabtdboard{
		border: 1px solid #F1F1F1;
		max-width: 1px;
	}
</style>