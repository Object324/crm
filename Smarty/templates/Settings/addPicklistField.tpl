<input type="hidden" name="mode" id="cfedit_mode" value="add"/>
<div id="addpicklistfield_div" style="max-height: 500px !important;overflow: auto;width: 100%;">
	{*ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签*}
	<div id="changemenu_{$blockid}" class="ld-ui-tabs">
		<ul class="ld-ui-tabs-nav">
			<li class="ld-ui-tabs-active" onclick="PageSetup.changePageSetupMenu(1,{$blockid})" tag="1"><a href="javascript:;">{'BASICPROPERTIES'|@getFixedLabel}</a></li>
			<li onclick="PageSetup.changePageSetupMenu(2,{$blockid})" tag="2" id="producttool_formula"><a href="javascript:;">{'INPUTMODE'|@getFixedLabel}</a></li>
			<li onclick="PageSetup.changePageSetupMenu(3,{$blockid})" tag="3" id="sensitive_rule_{$blockid}"><a href="javascript:;">{'SensitiveRules'|@getFixedLabel}</a></li>
		</ul>
	</div>
	<div id="basicDiv_{$blockid}">
	<table class="settingPopTable settingPopTableNoBot DetailContentTable"border="0" cellpadding="0" cellspacing="0" width="100%">
		<tr><!--230707 BUG0069167 页面设置，“关联选择单据（单选）”字段编辑属性界面，“可选择的数据范围”和“审批要求”下拉选项值顶格了-->
			<td align="right" style="width: 145px;">{"fieldtype"|@getFixedLabel}</td>
			<td align="left">
				<select name="selectfieldtype" class="selectfieldtype" onchange="makeFieldSelected(this,0,{$blockid})">
					<option value="0">{'Text'|@getFixedLabel}</option>
					<option value="10">{'TEXT_AREA'|@getFixedLabel}</option>
					<option value="18">{'WholeTextArea'|@getFixedLabel}</option>
                    {*zkt 20220511 50942	（81miscom/kfbcrm）系统设置》页面设置》客户，新增字段，“富文本框”字段的顺序调整到整行文本区域的下面*}
                    <option value="27">{'RichTextBox'|@getFixedLabel}</option>
					<option value="7">{'PickList'|@getFixedLabel}</option>
					<option value="11">{'SELECT_COMBO'|@getFixedLabel}</option>
					<option value="9">{'CHECK_BOX'|@getFixedLabel}</option>
					<option value="1">{'Numberc'|@getFixedLabel}</option>
					<option value="6">{'Phone'|@getFixedLabel}</option>
					<option value="15">{'Mobil'|@getFixedLabel}</option>
					<option value="4">{'DATE'|@getFixedLabel}</option>
					<option value="13">{'TIMES'|@getFixedLabel}</option>
					<option value="14">{'DateTime'|@getFixedLabel}</option>
					<option value="17">QQ</option>
					<option value="5">Email</option>
					<option value="12">Skype</option>
					<option value="2">{'Percents'|@getFixedLabel}</option>
					<option value="3"> {'Currencyc'|@getFixedLabel}</option>
					<option value="8">{'Website'|@getFixedLabel}</option>
					<option value="16">{'FAX'|@getFixedLabel}</option>
                    <!--40558: （http://51mis.com/demo/panlulu008演示账套 [^]）首页->附件管理：页面设置中新增附件字段，单据新建界面添加附件保存后，查看详情界面没有显示已上传成功的附件-->
                    {if $MODULE neq 'Attachment'&&$MODULE neq 'Documents'}
				       	<option value="22">{'Attachment'|@getFixedLabel}</option>
                    {/if}
					{if $HandlWRITESIGNPROFILE eq 1 }
						   <option value="19">{'handwriting'|@getFixedLabel}</option>
					{/if}
					{if $RELATEMODULESCOUNT >0}
						<option value="20">{'REFERENCEFIELD'|@getFixedLabel}</option>
					{/if}
					<option value="21">{'SelectBill'|@getFixedLabel}</option>
					<option value="31">{'SelectMultiBill'|@getFixedLabel}</option>
					{*wym XUQIU1000290 去掉原先新增成员所属部门字段*}
                    {*<option value="26">{'MemberDepartment'|@getFixedLabel}</option>*}
                    <option value="23">{'SelectOneUser'|@getFixedLabel}</option>
                    <option value="24">{'SelectMultiUser'|@getFixedLabel}</option>
                    <option value="25">{'SOCIALPROMOTIONQRCODE'|@getFixedLabel}</option>
					<option value="28">{'SIGNIN'|@getFixedLabel}</option>
					{if $MODULE neq 'Attachment'&&$MODULE neq 'Documents'}
					<option value="29">{'PICTURE'|@getFixedLabel}</option>
					{/if}
					{if $isExistExpress eq 'no'}
					<option value="30">{'ExpressQueryComponent'|@getFixedLabel}</option>
					{/if}
				</select>
			</td>
		</tr>
		<tr id="tr_fieldtype_{$blockid}">
			<td align="right"><font color="red">*</font>{'fieldtype'|@getFixedLabel}</td>
			<td align="left" >
				<input id="fieldtype_{$blockid}" name="fldLabel_{$blockid}" class="ld-input-inner gwidth85" value="" type="text"/>
			</td>
		</tr>
		<tr>
			<td align="right"><font color="red">*</font>{'CNTAG'|@getFixedLabel}</td>
			<td align="left" >
				<input id="fldLabel_{$blockid}" name="fldLabel_{$blockid}" class="ld-input-inner gwidth85" value="" type="text"/>
			</td>
		</tr>
		<tr>
			<td align="right"><font color="red">*</font>{'ENTAG'|@getFixedLabel}</td>
			<td align="left">
				<input id="fldLabels_{$blockid}" class="ld-input-inner gwidth85" value="" type="text"/>
			</td>
		</tr>

		<tr id="tr_value_format_{$blockid}" style="display: none">
			<td align="right">{'STYLE'|@getFixedLabel}</td>
			<td align="left">
				<div style="display: flex;align-items: center;">
					<div style="width: 200px;height: 100%;display: inline-block;">
						<select id="value_format_{$blockid}" name="value_format_{$blockid}" class="ld-select-inner gwidth50" >

						</select>
					</div>
					<b id="value_format_{$blockid}_tip" class="ld-fonticon ld-fonticon-help" data-tip="" style="margin: 0 5px 0 5px;"></b>
					<span id="value_format_{$blockid}_example" class="" >
						{'SuchAs'|@getFixedLabel}
						<span></span>
					</span>
				</div>
			</td>
		</tr>

		{*wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据*}
		<tr id="tr_memberrangetype_{$blockid}" >
			<td align="right" valign="center">{'SETMEMBERRANGE'|@getFixedLabel}</td>
			<td align="left">
				<select class="ld-select-inner gwidth50 selectfieldtype" id="memberrangetype_{$blockid}" name="memberrangetype_{$blockid}" onchange="make_memberrange_selected(this,0,{$blockid});">
					{*<option style="display: none"></option>*}
					<option value="All">全部</option>
					<option value="Module">根据模块数据范围权限控制</option>
					<option value="Person">按成员</option>
					<option value="Departments">按部门</option>
					<option value="Roles">按角色权限</option>
					<option value="Position">按职位级别</option>
				</select>
				<input type="hidden" id="memberrange_type{$blockid}" name="memberrange_type{$blockid}" value=""/>
				<input type="hidden" id="memberrange_other_condition{$blockid}" name="memberrange_other_condition{$blockid}" value=""/>
				<input type="hidden" id="memberrange_other_condition_groups{$blockid}" name="memberrange_other_condition_groups{$blockid}" value=""/>
				<a href="javascript:;" tmprange="memberrange" onclick="fun_other_conditions(this,'{$blockid}');">{'OtherConditions'|@getFixedLabel}</a>
			</td>
		</tr>
		<tr id="memberrangedetails_All_{$blockid}" >
			<td align="right" valign="center"><font color="red">*</font>{'ALL'|@getFixedLabel}</td>
		</tr>
		<tr id="memberrangedetails_Person_{$blockid}" >
			<td align="right" valign="center"><font color="red">*</font>{'MEMBER'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Person_{$blockid}" name="advance_demand_Person_{$blockid}" class="ld-input-inner-div lfloat"  style="line-height:23px;padding-left:8px;width: 378px;height: 25px;overflow: hidden">{$uservalue}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$blockid}','Person','Person_{$blockid}');"></a>
				<input type="hidden" value="" id="Person_{$blockid}" name="Person_{$blockid}" />
			</td>
		</tr>
		<tr id="memberrangedetails_Departments_{$blockid}" >
			<td align="right" valign="center"><font color="red">*</font>{'DEPARTMENT'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Departments_{$blockid}" name="advance_demand_Departments_{$blockid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;width: 378px;height: 25px;overflow: hidden">{$uservalue}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$blockid}','Departments','Departments_{$blockid}');"></a>
				<input type="hidden" value="" id="Departments_{$blockid}" name="Departments_{$blockid}" />
			</td>
		</tr>
		<tr id="memberrangedetails_Roles_{$blockid}" >
			<td align="right" valign="center"><font color="red">*</font>{'PROFILES'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Roles_{$blockid}" name="advance_demand_Roles_{$blockid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;height: 25px;width: 378px;overflow: hidden">{$uservalue}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$blockid}','Roles','Roles_{$blockid}');"></a>
				<input type="hidden" value="" id="Roles_{$blockid}" name="Roles_{$blockid}" />
			</td>
		</tr>
		<tr id="memberrangedetails_Position_{$blockid}" >
			<td align="right" valign="center"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Position_{$blockid}" name="advance_demand_Position_{$blockid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;height: 25px;width: 378px;overflow: hidden">{$uservalue}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$blockid}','Position','Position_{$blockid}');"></a>
				<input type="hidden" value="" id="Position_{$blockid}" name="Position_{$blockid}" />
			</td>
		</tr>
		<tr id="tr_showallgroupstructure_edit{$blockid}">
			<td align="right">
				<label for="showallgroupstructure_check_{$blockid}">{'Displayallgroupstructure'|@getFixedLabel}</label>
			</td>
			<td align="left">
				<input id="showallgroupstructure_check_{$blockid}" class="second_switch inputBornone" type="checkbox"/>
			</td>
		</tr>
		<tr id="codetype_{$blockid}">
			<td align="right"><font color="red">*</font>{'qrcodetype'|@getFixedLabel}</td>
			<td align="left">
				<select class="ld-select-inner gwidth40" onchange="qrcodeTypeChange(this,'{$blockid}')" id="fdcodetype_{$blockid}" name="fdcodetype_{$blockid}">
					<option value="1501">{'linkcode'|@getFixedLabel}</option>
					<option value="1500">{'contentcode'|@getFixedLabel}</option>
                    <option value="1503">{'FORMCODE'|@getFixedLabel}</option>
					<option value="1502">{'mobileDetailCode'|@getFixedLabel}</option>
				</select>
				<span style="display:none;">({'useCrmScan'|@getFixedLabel})</span>
			</td>
		</tr>
		<tr id="contentset_{$blockid}">
			<td align="right"><font color="red">*</font>{'Contentcustomization'|@getFixedLabel}</td>
			<td align="left">
				<a href="javascript:;" data-templateid="{$qrcodetemplateid||0}" id="qrcodeTemplateCreate" onclick="qrcodeTemplate.create(0,this,'{$MODULE}')">{'SETTINGS'|@getFixedLabel}</a>
			</td>
		</tr>
        <tr style="display:none" id="fieldset_{$blockid}">
			<td align="right"><font color="red">*</font>{'ACTIVITYFIELDSETTINGS'|@getFixedLabel}</td>
			<td align="left">
				<a href="javascript:;" data-templateid="{$qrcodetemplateid||0}" id="formqrcodeTemplateCreate" onclick="qrcodeTemplate.Formcreate(0,this,'{$MODULE}')">{'SETTINGS'|@getFixedLabel}</a>
			    <span style="margin-left:10px;">({'PERSONALCODESCAN'|@getFixedLabel})</span>
            </td>
		</tr>
		<tr id="lengthdetails_{$blockid}">
			<td align="right"><font color="red">*</font>{'CHARACTER'|@getFixedLabel}{'Length'|@getFixedLabel}</td>
			<td align="left">
				<input type="text" id="fldLength_{$blockid}" name="fldLength_{$blockid}" class="ld-input-inner gwidth85" value="100"/>
			</td>
		</tr>
		<tr id="decimaldetails_{$blockid}" style="display:none;">
			<td align="right"><font color="red">*</font>{'Decimal'|@getFixedLabel}</td>
			<td align="left">
                <input type="text" id="fldDecimal_{$blockid}" name="fldDecimal_{$blockid}" class="ld-input-inner gwidth85" value="2"/>
			</td>
		</tr>
		<tr style="display:none" id="tr_relatedmodule_{$blockid}">
			<td align="right"><font color="red">*</font>{'RelatedModule'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
			<select  id="relatedmodule_{$blockid}" data-curmodule="{$MODULE}" name="relatedmodule_{$blockid}" onchange="getReferencemoduleField(this,'{$blockid}','{$MODULE}')" class="hlineheight29">
			{$RELATEDMODULE}
			</select>
			</td>
		</tr>
		<tr style="display:none" id="tr_referencemodule_{$blockid}">
			<td align="right"><font color="red">*</font>{'RelateChoiceModule'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				{*wym 230804 BUG0070650 kfbcrm-新增关联选择单据（单选）时切换关联选择对象时应清空当前默认值，否则保存时默认值与关联对象不匹配*}
				<select id="referencemodule_{$blockid}" name="referencemodule_{$blockid}" onchange="clear_ChooseDefaultvalue('{$blockid}')">
					{foreach from=$CANSELECTMODULES item=info}
						<option value="{$info.name}">{$info.label}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		<tr style="display:none" id="tr_multireferencemodule_{$blockid}">
			<td align="right"><font color="red">*</font>{'RelateChoiceModule'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				{*wym 230804 BUG0070650 kfbcrm-新增关联选择单据（单选）时切换关联选择对象时应清空当前默认值，否则保存时默认值与关联对象不匹配*}
				<select id="multireferencemodule_{$blockid}" name="multireferencemodule_{$blockid}" onchange="clear_ChooseDefaultvalue('{$blockid}')">
					{foreach from=$CANSELECTMODULESMULTI item=info}
						<option value="{$info.name}">{$info.label}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		<tr style="display:none" id="tr_datarang_{$blockid}">
			<td align="right"><font color="red">*</font>{'ALLOWDataRange'|@getFixedLabel}</td>
			<td align="left">
			<select  id="datarange_{$blockid}" name="datarange_{$blockid}">
				<option value="all">{'ALL'|@getFixedLabel}</option>
				<option value="permit" selected>{'ALLOWINQUIRE'|@getFixedLabel}</option>
			</select>
			</td>
		</tr>
		<tr id="tr_approvedemand_{$blockid}" style="display:none">
			<td align="right"><font color="red">*</font>{'APPROVEDEMAND'|@getFixedLabel}</td>
			<td align="left">
			 	<select id="approve_demand_{$blockid}" name="approve_demand_{$blockid}">
					<option value="0">{'NONE'|@getFixedLabel}</option>
					<option value="1">{'Approved'|@getFixedLabel}</option>
			  	</select>
				{*@edit:liushuai,2020-08-24,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮*}
				<input type="hidden" id="advance_demand_{$blockid}" name="advance_demand_{$blockid}" value=""/>
				<input type="hidden" id="advance_demand_groups_{$blockid}" name="advance_demand_groups_{$blockid}" value=""/>
				<input type="hidden" id="advance_demand_referencemodule_{$blockid}" name="advance_demand_referencemodule_{$blockid}" value=""/>
				<a href="javascript:;"  onclick="fun_other_conditions(this,'{$blockid}');">{'OtherConditions'|@getFixedLabel}</a>
			</td>
		</tr>
		<tr id="tr_maxrowsshow_{$blockid}" style="display:none">
			<td align="right"><font color="red">*</font>{'MaxRowsShow'|@getFixedLabel}</td>
			<td align="left">
				<select id="maxrowsshow_{$blockid}" name="maxrowsshow_{$blockid}">
					<option value="5">5</option>
					<option value="10">10</option>
					<option value="15">15</option>
					<option value="20">20</option>
					<option value="50">50</option>
					<option value="100">100</option>
				</select>
			</td>
		</tr>
		<tr id="picklistdetails_{$blockid}" style="display:none;">
			<td align="right" valign="center"><font color="red">*</font>{'Dropdownboxlistvalues'|@getFixedLabel}</td>
			<td valign="top" class="selectSpan">
				<select class="js-example-tags form-control" multiple="multiple" id="fldpicklist_{$blockid}">
				</select>
			</td>
		</tr>
		<tr id="tr_defaultvalue_{$blockid}" style="display:none">
			<td align="right">{'LBL_DEFAULTVALUE'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<input type="text" class="ld-input-inner gwidth85" id="defaultvalue_{$blockid}_name" name="defaultvalue_{$blockid}_name">
				<input type="hidden" id="defaultvalue_{$blockid}" name="defaultvalue_{$blockid}">
				<a class="icon-homeimg icon-select" href="javascript:;" style="float:inherit" id="defaultchoose_btn_{$blockid}" title="{'SELECT'|@getFixedLabel}" onclick='setChooseDefaultvalue("{$MODULE}","{$blockid}");'></a>
				<a class="icon-homeimg icon-select" href="javascript:;" style="float:inherit" id="defaultchoose_btn_{$blockid}_multiple" title="{'SELECT'|@getFixedLabel}" onclick='setChooseDefaultvalueMutiple("{$MODULE}","{$blockid}");' style="display:none"></a>
				<input class="icon-homeimg icon-clear inpb-reset" type="button"  id="defaultclear_btn_{$blockid}" title="{'CLEAR'|@getFixedLabel}" onclick="clear_ChooseDefaultvalue('{$blockid}');return false;"/>
				<input  type="checkbox" class="second_switch" id="defaultvalue_{$blockid}_chkbox" name="defaultvalue_{$blockid}_chkbox" style="display:none"/>
				{*zkt 20220922 BUG0056891页面设置-新增文本区域字段的默认值无法换行*}
                <textarea class="ld-textarea-inner gwidth85" id="defaultvalue_{$blockid}_textarea" name="defaultvalue_{$blockid}_textarea" style="display:none;margin: 5px 0px;height: 50px;resize: vertical !important;" ></textarea>
                <select id="defaultvalue_{$blockid}_picklist" name="defaultvalue_{$blockid}_picklist" style="display:none">
				</select>
			    <select id="defaultvalue_{$blockid}_multipicklist" multiple="" name="defaultvalue_{$blockid}_multipicklist"
				 style="display:none;">
				 </select>
				 <select class="small" id="defaultvalue_{$blockid}_date" name="defaultvalue_{$blockid}_date" style='max-width:160px;'>
					{*0040518: 设置>系统设置>选择 界面设置 中的页面设置>列表右边页面设置>新增字段>字段类型为日期>选择默认值时存在问题*}
					<option value="" {if $value.defaultvalue.value eq ''}selected{/if}></option><!--空值-->
					<option value="thistoday" {if $value.defaultvalue.value eq 'thistoday'}selected{/if}>{'now'|@getFixedLabel}</option><!--今天-->
					<option value="oneyear" {if $value.defaultvalue.value eq 'oneyear'}selected{/if}>{'OneYearLater'|@getFixedLabel}</option><!--一年后：明年今天的前一天-->
					<option value="beforeoneyear" {if $value.defaultvalue.value eq 'beforeoneyear'}selected{/if}>{'OneYearAgo'|@getFixedLabel}</option><!--一年前：明年今天的后一天-->
					{foreach key=key item=AfterDayitem from=$AfterDayInfo}
						<option value="{$AfterDayitem.value}" {if $value.defaultvalue.value eq $AfterDayitem.value}selected{/if}>{$AfterDayitem.label}</option>
					{/foreach}
					{foreach key=key item=DaysAgoitem from=$DaysAgoInfo}
						<option value="{$DaysAgoitem.value}" {if $value.defaultvalue.value eq $DaysAgoitem.value}selected{/if}>{$DaysAgoitem.label}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		{*ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）*}
		<tr id="tr_selectmemberfield_{$blockid}" style="display:none">
			<td align="right"><font color="red">*</font>{'SELECTUSER'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<select id="selectmemberfield_{$blockid}" name="selectmemberfield_{$blockid}">
					{foreach key=user_id item=user_name from=$SELECTMEMBERS}
						<option value="{$user_id}">{$user_name}</option>
					{/foreach}
				</select>
			</td>
		</tr>
		<tr id="tr_relatedmodulefield_{$blockid}" style="display:none">
			<td align="right"><font color="red">*</font>{'REFERENCEFIELD'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<select id="relatedmodulefield_{$blockid}" name="relatedmodulefield_{$blockid}" onchange="selectedIsHrefFiled(this,{$blockid})">
				</select>
			</td>
		</tr>
		{*2024-06-05 xxy XUQIU20240603-02 页面设置/单据分录定制，字段类型增加“帮助信息”字段属性（朱俊）*}
		<tr id="tr_helptips_{$blockid}" style="display:none">
			<td align="right">
				<div class="ld-btn-icontext-item">
					<span>{'HelpInformation'|@getFixedLabel}</span>
					<i data-tip="{'HoverQuestionMarkDisplay'|@getFixedLabel}" class="ld-fonticon ld-fonticon-help2 tip-items-list"></i>
				</div>
			</td>
			<td align="left" style="overflow: inherit;">
				<textarea class="ld-textarea-inner gwidth85" id="helptips_{$blockid}" name="helptips_{$blockid}" style="margin: 5px 0px;height: 50px;resize: vertical !important;"></textarea>
			</td>
		</tr>
		{*zxm20211228 字段说明，即placeholder*}
		<tr id="tr_fieldplaceholder_{$blockid}" style="display:none">
			<td align="right">{'FieldDescription'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<input type="text" id="fieldplaceholder_{$blockid}" name="fieldplaceholder_{$blockid}" class="ld-input-inner gwidth85" value=""/>
			</td>
		</tr>
		<tr id="tr_labelvaluecolor_{$blockid}">
			<td align="right">{'LABELCOLOR'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<div title="点击修改颜色" name="color_div" style="width: 21px;
						height: 21px;
						border-radius: 100%;
						cursor: pointer;
						border: 1px solid #dbdbdb;background: #999;left:0;top:0;" onclick="chooseLabelColor(this,'{$blockid}');">
				</div>
				<input type="hidden" id="labelvaluecolor_{$blockid}" name="labelvaluecolor" class="ld-input-inner gwidth90" value=""/>
			</td>
		</tr>
		{*zxm20211228 字段颜色，默认显示系统字体颜色*}
		<tr id="tr_fieldvaluecolor_{$blockid}" style="display:none">
			<td align="right">{'FieldColor'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<div title="点击修改颜色" name="color_div" style="width: 21px;
					 height: 21px;
					 border-radius: 100%;
					 cursor: pointer;
					 border: 1px solid #dbdbdb;background: #333333;left:0;top:0;" onclick="chooseFieldColor(this,'{$blockid}');">
				</div>
				<input type="hidden" id="fieldvaluecolor_{$blockid}" name="fieldvaluecolor_{$blockid}" value="#333333"/>
			</td>
		</tr>
		{*电话，手机字段颜色 2023-5-5 xxy XUQIU1001310 页面设置，“手机”和“电话”字段文字颜色增加默认色*}
		<tr id="tr_phone_fieldvaluecolor_{$blockid}" style="display:none">
			<td align="right">{'FieldColor'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<div title="点击修改颜色" name="color_div" style="width: 21px;
					 height: 21px;
					 border-radius: 100%;
					 cursor: pointer;
					 border: 1px solid #dbdbdb;background: #3B7CFF;left:0;top:0;" onclick="phone_chooseFieldColor(this,'{$blockid}');">
				</div>
				<input type="hidden" id="phone_fieldvaluecolor_{$blockid}" name="phone_fieldvaluecolor_{$blockid}" value="#3B7CFF"/>
			</td>
		</tr>
		{*手写签名-允许重签*}
		<tr id="allow_rewriting_{$blockid}" style="display:none;">
			<td align="right"><label for="fldallow_rewriting_{$blockid}">{'allowrewriting'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="fldallow_rewriting_{$blockid}" name="fldallow_rewriting_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_activate_field_{$blockid}">
			<td align="right"><label for="activate_field_{$blockid}">{'ACTIVATE'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox"  checked="" id="activate_field_{$blockid}" name="activate_field_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_savedatabase_{$blockid}" style="display:none;">
			<td align="right"><label for="savedatabase_{$blockid}">{'Savetodatabase'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="savedatabase_{$blockid}" name="savedatabase_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_allowedit_{$blockid}" style="display:none;">
			<td align="right"><label for="allowedit_{$blockid}">{'ALLOWEDITING'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="allowedit_{$blockid}" name="allowedit_{$blockid}" class="second_switch" checked/>
			</td>
		</tr>
        {* @edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）、引用字段增加“显示超链接”字段属性*}
        <tr id="tr_ShowHyperlinks_{$blockid}" style="display:none;">
			<td align="right"><label for="ShowHyperlinks_{$blockid}">{'SHOWHYPERLINKS'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="ShowHyperlinks_{$blockid}" name="ShowHyperlinks_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
        <tr id="tr_requiredfield_{$blockid}">
			<td align="right"><label for="requiredfield_{$blockid}">{'Required_fields'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="requiredfield_{$blockid}" name="requiredfield_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_notallowduplicate_{$blockid}">
			<td align="right"><label for="notallowduplicate_{$blockid}">{'Allowed_to_repeat'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="notallowduplicate_{$blockid}" name="notallowduplicate_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		{*// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）*}
		<tr id="tr_disallowed_copy_{$blockid}">
			<td align="right"><label for="disallowed_copy_{$blockid}">{'ContentNotAllowCopying'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="disallowed_copy_{$blockid}" name="disallowed_copy_{$blockid}" class="second_switch"/>
			</td>
		</tr>
		{*// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）*}
		<tr id="tr_word_watermark_{$blockid}" style="display: none;">
			<td align="right"><label for="word_watermark_{$blockid}">{'WORDWATERMARK'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="word_watermark_{$blockid}" name="word_watermark_{$blockid}" onchange="showWatermarkSetting(this,'word')" class="second_switch"/>
				<a href="javascript:;" id="word_watermark_setting_{$blockid}" name="word_watermark_setting" style="padding-left: 10px;display: none;" settingid="" module="{$MODULE}"  onclick="setWatermark(this,'word')">{'SETWATERMARK'|@getFixedLabel}</a>
			</td>
		</tr>
		<tr id="tr_excel_watermark_{$blockid}" style="display: none;">
			<td align="right"><label for="excel_watermark_{$blockid}">{'EXCELWATERMARK'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="excel_watermark_{$blockid}" name="excel_watermark_{$blockid}" onchange="showWatermarkSetting(this,'excel')" class="second_switch"/>
				<a href="javascript:;" id="excel_watermark_setting_{$blockid}" name="excel_watermark_setting" style="padding-left: 10px;display: none;" settingid=""  module="{$MODULE}" onclick="setWatermark(this,'excel')">{'SETWATERMARK'|@getFixedLabel}</a>
			</td>
		</tr>
		{*@edit:liushuai,2020-12-28,reason: 页面设置，字段属性界面去掉【快速创建】一行【style="display: none;"】*}
		<tr id="tr_quickcreate_{$blockid}" style="display: none;">
			<td align="right"><label for="quickcreate_{$blockid}">{'Quickly_create'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="quickcreate_{$blockid}" name="quickcreate_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_massedit_{$blockid}" style="display:none;">
			<td align="right"><label for="massedit_{$blockid}">{'MASSEDIT'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="massedit_{$blockid}" name="massedit_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		{* @edit: xxy 2023/11/14 XUQIU1001176 页面设置/单据分录定制，增加“内容过多自动换行”字段属性，当前只控制PC端*}
		<tr id="tr_auto_wordwrap_{$blockid}" style="display:none;">
			<td align="right"><label for="auto_wordwrap_{$blockid}">{'AutoWordWrap'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="auto_wordwrap_{$blockid}" name="auto_wordwrap_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
        <tr id="tr_regexp_{$blockid}" style="display:none;">
			<td align="right"><label for="regexp_{$blockid}">{'EnableRegExp'|@getFixedLabel}</label></td>
        	<td align="left">
				<input type="checkbox" id="regexp_{$blockid}" name="regexp_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_take_photo_only_check_{$blockid}" style="display:none;">
			<td align="right"><label for="take_photo_only_check_{$blockid}"> {'takephotopnly'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="take_photo_only_check_{$blockid}" name="take_photo_only_check_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		{*@edit:liushuai,2021-06-04,reason:【ID1001652】页面设置，“附件”和“图片”字段增加字段属性，控制签到水印是否显示（第二版）*}
		<tr id="tr_uploadwatermark_check_{$blockid}" style="display:none;">
			<input type="hidden" name="isOpenSignIn" id="isOpenSignIn" value="{$isOpenSignIn}">
			<td align="right"><label for="uploadwatermark_check_{$blockid}">{'MobileUploadWatermark'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="uploadwatermark_check_{$blockid}" name="uploadwatermark_check_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_auto_signin_{$blockid}" style="display:none;">
			<td align="right"><label for="auto_signin_{$blockid}">{'AUTOMATICCHECKIN'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="auto_signin_{$blockid}" name="auto_signin_{$blockid}" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_editview_signin_{$blockid}" style="display:none;">
			<td align="right"><label for="editview_signin_{$blockid}">{'EDITVIEWSIGNIN'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="editview_signin_{$blockid}" name="editview_signin_{$blockid}" onclick="enableDisableCheckBox_ressing(this,editview_resignin_{$blockid})" class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_editview_resignin_{$blockid}" style="display:none;">
			<td align="right"><label for="editview_resignin_{$blockid}">{'EDITVIEWRESIGNIN'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="editview_resignin_{$blockid}" name="editview_resignin_{$blockid}"
				    {if $value.editview_signin neq 'yes'} disabled="disabled"{/if}
					 class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_subtotalattr_{$blockid}">
			<td align="right"><label for="subtotalattr_{$blockid}">{'CalculateSubtotal'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="subtotalattr_{$blockid}" name="subtotalattr_{$blockid}" checked class="second_switch" value=""/>
			</td>
		</tr>
		<tr id="tr_allowable_distance_{$blockid}" style="display:none;">
			<td align="right"><label for="no_signin_{$blockid}">{'Ifitexceedstheerrorrange'|@getFixedLabel}</label>
				
			</td>
			<td align="left">
				<input type="checkbox" id="no_signin_{$blockid}" name="no_signin_{$blockid}" class="second_switch" value=""/>
				<select class="btn-radius-system marL10" name="allowable_distance_{$blockid}" id="allowable_distance_{$blockid}" style="width: 70px;" onchange="allowable_distance_click(this,{$blockid})">
					<option value="100">100{'metre'|@getFixedLabel}</option>
					<option value="200" selected="selected">200{'metre'|@getFixedLabel}</option>
					<option value="300">300{'metre'|@getFixedLabel}</option>
					<option value="500">500{'metre'|@getFixedLabel}</option>
					<option value="800">800{'metre'|@getFixedLabel}</option>
					<option value="1000">1000{'metre'|@getFixedLabel}</option>
					<option value="2000">2000{'metre'|@getFixedLabel}</option>
					<option value="3000">3000{'metre'|@getFixedLabel}</option>
					<option value="5000">5000{'metre'|@getFixedLabel}</option>
					<option value="custom">{'custom'|@getFixedLabel}</option>
				</select>
				<input class="ld-input-inner" type="text" name="custom_allowable_distance_{$blockid}" id="custom_allowable_distance_{$blockid}" value="" style="width: 60px;display:none;height: 30px;">
			</td>
		</tr>
		<tr id="tr_FileAllowed_{$blockid}" style="display:none;">
			<td align="right"><label for="FileAllowed_{$blockid}">{'FileAllowed'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="FileAllowed_{$blockid}" name="FileAllowed_{$blockid}" class="second_switch" value="" onchange="ld(this).siblings('a').css('display',ld(this).prop('checked') ? '' : 'none')"/>
				<a href="javascript:;" onclick="SetConditions('DownloadAllowed','{$MODULE}');">{'SetConditions'|@getFixedLabel}</a>
			</td>
		</tr>
		<!--
		<tr id="tr_PreviewAllowed_{$blockid}" style="display:none;">
			<td align="right"><label for="PreviewAllowed_{$blockid}">{'PreviewAllowed'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" id="PreviewAllowed_{$blockid}" name="PreviewAllowed_{$blockid}" class="second_switch" value="" />
				<a href="javascript:;"  onclick="SetConditions('PreviewAllowed','{$MODULE}');">{'SetConditions'|@getFixedLabel}</a>
			</td>
		</tr>
		-->
	</table>
	<table border="0" cellspacing="0" cellpadding="5" width="100%" class="layerPopupTransport">
		<tr>
			<input type="hidden" name="fieldType_{$blockid}" id="fieldType_{$blockid}" value="Text">
			<input type="hidden" name="selectedfieldtype_{$blockid}" id="selectedfieldtype_{$blockid}" value="Text">
		</tr>
	</table>
	</div>
	<!--高级属性-->
	<div id="advanceDiv_{$blockid}" style="display:none;">
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td class="ld-form-item-label" style="line-height: initial;">
					{'INPUTMODE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" style="line-height: initial;">
					<select class="ld-select-inner gwidth50" name="inputModeType_{$blockid}" id="inputModeType_{$blockid}" onchange="PageSetup.selectInputMode(this,{$blockid})" {if $PRODUCTTOOLFIELDID > 0 }disabled{/if}>
						<option value="0">{'MANUALINPUT'|@getFixedLabel}</option>
						{if $isEntryModule eq 'yes'}
							<option value="1">{'EntryFunction'|@getFixedLabel}</option>
						{/if}
						<option value="2">{'USINGTHEFORMULA'|@getFixedLabel}</option>
						<option value="3">{'QUERYBYSQL'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
			{*函数功能*}
			<tr id='functionDiv_{$blockid}'>
				<td class="ld-form-item-label" style="line-height: initial;">
					{'TheFunctionality'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" style="line-height: initial;">
					<select name="functionType_{$blockid}" id="functionType_{$blockid}" class="ld-select-inner gwidth50" onchange="PageSetup.selectFunction(this,{$blockid})">
						{foreach key=functiontype item=functionlabel from=$EntryFunction}
							<option value="{$functiontype}">{$functionlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
			{*参数字段（分录字段）*}
			<tr id='attributeDiv_{$blockid}'>
				<td class="ld-form-item-label" style="line-height: initial;">
					{'ParameterField'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" style="line-height: initial;">
					{*选择“日期类型字段时”字段时，只显示“取最大值”、“取最小值”*}
					<select name="attributeField_{$blockid}" id="attributeField_{$blockid}" class="ld-select-inner gwidth50" onchange="PageSetup.selectFunctionField(this,{$blockid})">
						{foreach key=functype item=fieldarr from=$EntryFuncfieldarr}
							{foreach key=columnname item=fieldlabel from=$fieldarr}
								<option
										{if $functype eq 'numamount'}style='display:;'{else}style='display:none;'{/if}
										value="{$columnname}" functype="{$functype}">{$fieldlabel}
								</option>
							{/foreach}
						{/foreach}
					</select>
				</td>
			</tr>
			{*定义变量*}
			<tr id='definingDiv_{$blockid}' style='display:none;'>
				<td class="padT16 padB16" colspan='2' style="line-height: initial;">
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'DEFININGVARUABLE'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr id='definingContentDiv_{$blockid}'>
				<td align="left" colspan='2' style="line-height: initial;">
					<div id="productDiv" style="max-height:150px;overflow-x: auto;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" id="toolfieldFormula_{$blockid}" class="toolfield formual_td">
							{*{$FORMULAHTML}*}
							<tr>
								<td colspan="3">
									<a href="javascript:;" title="{'NewVar'|@getFixedLabel}" onclick="PageSetup.addFormulaTableTr(1,{$blockid})">{'NewVar'|@getFixedLabel}</a>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			{*定义公式*}
			<tr id='mulaDiv_{$blockid}'>
				<td class="padT16 padB16" colspan='2' style="line-height: initial;">
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'DEFINITIONFORMULA'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr id='mulaContentDiv_{$blockid}'>
				<td align="left" colspan='2' style="line-height: initial;">
					<input type="text" id="definitionformula_{$blockid}" name="definitionformula_{$blockid}" value="" class="ld-input-inner" /><br />
					<span style="line-height:45px;height:45px;display:block;">1.{'AllNumericAndCurrencyFieldsCanCalculate'|@getFixedLabel}</span>
					<span style="margin-bottom:20px;display:block;">2.{'CANHAVEATMOST10VARIABLES'|@getFixedLabel}</span>
				</td>
			</tr>
			<tr id='sqlDiv_{$blockid}'>
				<td class="padT16 padB16" colspan='2' style="line-height: initial;">
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'SQLQUERY'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr id='sqlContentDiv_{$blockid}'>
				<td align="left" colspan='2' style="line-height: initial;">
					<textarea id="definitionsqlformula_{$blockid}" name="definitionsqlformula_{$blockid}" class="ld-textarea-inner"></textarea><br />
					<span id="definitionsqlformula_spantext" style="line-height:45px;height:45px;display:block;">1.{'SQLFormulaTips1'|@getFixedLabel}</span>
					<span id="definitionsqlformula_spanoneuser" style="line-height:45px;height:45px;display:none;">1.{'SQLFormulaTips1_1'|@getFixedLabel}</span>
					<span style="display:block;">2.{'SQLFormulaTips2'|@getFixedLabel}</span>
				</td>
			</tr>
		</table>
	</div>
	{*字段敏感规则,文本、文本区域、数字、电话、手机、QQ、Email、货币字段*}
	<div id="SensitiveRules_{$blockid}" style="display:none;margin-bottom: 55px;min-height: 300px;">
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td class="ld-form-item-label">
					{'ACTIVATE'|@getFixedLabel}{'SensitiveRules'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" style="overflow: inherit;">
					<input name="sensitivepresence" type="checkbox" class="second_switch lfloat">
					<div class="create-entity-toolbar rfloat prelative">
						<a href="javascript:;" onclick="SensitiveRules.getInstance().create(0,0,'create','{$MODULE}',{$blockid})" class="ld-button ld-button-primary" title="{'ADDLESSIONPLAN'|@getFixedLabel}{'LBL_PROFILES'|@getFixedLabel}">{'ADDLESSIONPLAN'|@getFixedLabel}{'RULE'|@getFixedLabel}</a>
					</div>
				</td>
			</tr>
		</table>
		<div class="SensitiveDiv">
			{include file="Settings/SensitiveRulesList.tpl"
				FIELDID=0
				MODULE=$MODULE
				LANGUAGETYPE=$LANGUAGETYPE
			}
		</div>
	</div>

</div>
{*// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）  新增字段添加提示"移动端内容无法复制"*}
<div class="greyFont9 padL10 font12" style="margin-top: -20px" name="mobilecontextnotcopy">
	<span style="color:red">*</span>{'MobileContentCanNotCopy'|@getFixedLabel}
</div>


<div class="E_pbtn E_pbtn_special" {if $buttonhide eq 'yes'}style='display:none;'{/if}>
	<input type="button" class="E_pbtnok ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}" onclick="find_custom_fieldlabel_exists('{$MODULE}','{$blockid}','add');"/><input type="button" class="E_pbtncancel ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" onclick="addFieldCancel('{$blockid}');"/>
</div>
<div class="E_pbtn E_pbtn_special" {if $buttonhide neq 'yes'}style='display:none;'{/if}>
	<input type="button" class="E_pbtnok ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}" onclick="find_custom_fieldlabel_exists('{$MODULE}','{$blockid}','add');"/><input type="button" class="E_pbtncancel ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" onclick="cancelwindow();"/>
</div>
<style>
.row-fluid {
	position: inherit !important;
}
</style>
<script>
{literal}
var selectfieldtypeImages={'0':'text.gif','10':'text.gif'
                    ,'7':'cfpicklist.gif','11':"cfpicklist.gif",'9':'checkbox.gif'
                    ,'1':'number.gif','6':'phone.gif','15':'sendmsg.png','4':'date.gif'
                    ,'14':'datetime.gif','17':'QQ.gif','5':'email.gif','12':'skype.gif','13':'time.PNG'
                    ,'2':'percent.gif','3':'cfcurrency.gif','8':'url.gif','16':'rfax.gif','19':'autograph.png'
                    ,'20':'referencefield.png','21':'referencefield.png','18':'text.gif'};

var blk = '';
function selectfieldtypeImage(state) {

  if (!state.id) {
    return state.text;
  }

  var $state = ld(
    // '<span><img src="themes/images/'+selectfieldtypeImages[state.id]+'" class="img-flag" /> ' + state.text + '</span>'
    '<span>' + state.text + '</span>'
  );
  return $state;
}

//拖动
$(function PopDrag(){
	if(blk != ''){
		ld(blk).mousedown(function(e) {
			var isMove = true;
			ld(blk).mousemove(function(e){
				if(isMove){
					ld(blk).css({
						'left': e.pageX,
						'top': e.pageY+330
					})
				}
			}).mouseup((e) => isMove = false);
		})
	}
	//console.log('ssss');
})

//hjz 需要改颜色的字段fieldid数组  0->文本 10->文本区域 18->整行文本区域 1->数字 3->货币 6->电话 15->手机 4->日期 13->时间 14->日期时间 2->百分比
var colorarr = ['0','10','18','1','3','6','15','4','13','14','2'];
var ColorTypeArr = ["text","textarea","longtextarea","number","currency","date","time","datetime","percent","phone","mobile"];
function makeFieldSelected(obj,fieldid,blockid)
{
    fieldid=obj.options[obj.selectedIndex].value;
	selFieldType(fieldid,'','',blockid);
	document.getElementById('selectedfieldtype_'+blockid).value = fieldid;
	//zxm 20211228 字段颜色、字段说明 仅文本、文本域、多文本域需要设置这俩个参数
	if(colorarr.indexOf(fieldid)!='-1'){
		if(fieldid=='6'||fieldid=='15'){
			ld('#tr_phone_fieldvaluecolor_'+blockid).show();
			ld('#tr_fieldvaluecolor_'+blockid).hide();
		}else{
			ld('#tr_fieldvaluecolor_'+blockid).show();
			ld('#tr_phone_fieldvaluecolor_'+blockid).hide();
		}
        if(fieldid=='0'||fieldid=='10'||fieldid=='18'){
            ld('#tr_fieldplaceholder_'+blockid).show();
        }else{
            ld('#tr_fieldplaceholder_'+blockid).hide();
        }
	}else if(fieldid=='8'){
		ld('#tr_fieldvaluecolor_'+blockid).hide();
		ld('#tr_fieldplaceholder_'+blockid).show();
	}else{
 	  ld('#tr_fieldvaluecolor_'+blockid).hide();
 	  ld('#tr_fieldplaceholder_'+blockid).hide();
	}
	
	if(fieldid=='23'||fieldid=='24'){
		ld('#tr_memberrangetype_'+blockid).show();
	}
	ld('#memberrangetype_'+blockid).val('');
}
function make_memberrange_selected(obj,fieldid,blockid)
{
	var type=obj.options[obj.selectedIndex].value;
	//ld('#tr_showallgroupstructure_edit'+blockid).show();
	if(type=='All'){
		ld('#tr_showallgroupstructure_edit'+blockid).hide();
		ld('#memberrangedetails_Person_'+blockid).hide();
		ld('#memberrangedetails_Departments_'+blockid).hide();
		ld('#memberrangedetails_Roles_'+blockid).hide();
		ld('#memberrangedetails_Position_'+blockid).hide();
	}else if(type=='Module'){
		ld('#memberrangedetails_Person_'+blockid).hide();
		ld('#memberrangedetails_Departments_'+blockid).hide();
		ld('#memberrangedetails_Roles_'+blockid).hide();
		ld('#memberrangedetails_Position_'+blockid).hide();
	}else if(type=='Person'){
		ld('#memberrangedetails_Person_'+blockid).show();
		ld('#memberrangedetails_Departments_'+blockid).hide();
		ld('#memberrangedetails_Roles_'+blockid).hide();
		ld('#memberrangedetails_Position_'+blockid).hide();
		ld('#advance_demand_Person_'+blockid).html("");
		ld('#Person_'+blockid).val("");
	}else if(type=='Departments'){
		ld('#memberrangedetails_Person_'+blockid).hide();
		ld('#memberrangedetails_Departments_'+blockid).show();
		ld('#memberrangedetails_Roles_'+blockid).hide();
		ld('#memberrangedetails_Position_'+blockid).hide();
		ld('#advance_demand_Departments_'+blockid).html("");
		ld('#Departments_'+blockid).val("");
	}else if(type=='Roles'){
		ld('#memberrangedetails_Person_'+blockid).hide();
		ld('#memberrangedetails_Departments_'+blockid).hide();
		ld('#memberrangedetails_Roles_'+blockid).show();
		ld('#memberrangedetails_Position_'+blockid).hide();
		ld('#advance_demand_Roles_'+blockid).html("");
		ld('#Roles_'+blockid).val("");
	}else if(type=='Position'){
		ld('#memberrangedetails_Person_'+blockid).hide();
		ld('#memberrangedetails_Departments_'+blockid).hide();
		ld('#memberrangedetails_Roles_'+blockid).hide();
		ld('#memberrangedetails_Position_'+blockid).show();
		ld('#advance_demand_Position_'+blockid).html("");
		ld('#Position_'+blockid).val("");
	}
}

//17172: 新增自定义字段时，基本信息里面没有传真 但添加传真总是提示字段名称重复
var issave='yes';
function find_custom_fieldlabel_exists(modulename,blockid,mode)
{
    if(issave=='no'){
        return ;
    }
    issave='no';

    var check = validate(blockid);
    if(check == false){
        issave='yes';
        return false;
    }
    var jquery_obj;
    if(ld){
        jquery_obj=ld;
    }
    else{
        jquery_obj=$;
    }
   	var label = trim(document.getElementById("fldLabel_"+blockid).value);
   	var labels = trim(document.getElementById("fldLabels_"+blockid).value);
    var type = document.getElementById("fieldType_"+blockid).value;
    var fdcodetype = document.getElementById("fdcodetype_"+blockid).value;
	var qrcodetemplateid = '';
	if ( fdcodetype == '1501' || fdcodetype =='1500'){//内容码，链接码
		qrcodetemplateid = ld("#qrcodeTemplateCreate").attr('data-templateid');
	}else if ( fdcodetype == '1503'){//表单码
		qrcodetemplateid = ld("#fieldset_"+blockid).find("#formqrcodeTemplateCreate").attr('data-templateid');
	}
	
    if(type.toLocaleLowerCase()=='text'||type.toLocaleLowerCase()=='number'){
		if(type.toLocaleLowerCase()=='text'){
			var fldLength = trim(document.getElementById("fldLength_"+blockid).value);
			if(fldLength==''){
				issave='yes';
				RemindsMsg("","LdPopWidth400px","","yes","yes",charlenglabel+arrJsPopLabel['LENGTH']+arrJsPopLabel['CANOTEMPTY']);
				return false;
			}
			if(isNaN(fldLength)){
				issave='yes';
				RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['CHARACTERLENGTH']);
				return false;
			}
		}
        if(type.toLocaleLowerCase()=='number'){
            var fldDecimal = trim(document.getElementById("fldDecimal_"+blockid).value);
            if(trim(fldDecimal)==''){
                issave='yes';
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Decimal']+arrJsPopLabel['CANOTEMPTY']);
                return false;
            }
            if(fldDecimal>53){
                RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Decimal']+arrJsPopLabel['CANNOTTHAN']+"53");
                return false;
            }
        }
    }
   	var str_json={"fld_module":modulename,"ajax":true,"sub_mode":'findLabels_Exists',"fldLabel":labels,"label":label,"type":type};
	if(type.toLocaleLowerCase()=='qrcode'){
		//231205 wym BUG0076730 页面设置-二维码字段类型，当选择链接码、内容码、表单码，但没有设置内容时，保存时弹出弹框,点击“确定”返回字段编辑界面.
		//231228 wym BUG0077654 fdcodetype：1502-二维码字段-移动单据详情码 不需要内容定制
		if ( fdcodetype!='1502' && (qrcodetemplateid==''||qrcodetemplateid==0||qrcodetemplateid==undefined)){
			MessagePopup.TipOne_warning(arrJsPopLabel['SETQRCODECONTENT']);
			issave='yes'
			return false;
		}
		str_json.fdcodetype_value = fdcodetype;
		str_json.qrcodetemplateid = qrcodetemplateid;
	}
   	var languages=new Array('zh','en');
    jquery_obj.ajax
    ({
        url: 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&languagetype=',
        type: 'POST',
        data:str_json,
        dataType: 'json',
        async: false,//同步
        timeout: 5000,
        error: function(XMLHttpRequest, textStatus, errorThrown){
            issave='yes';
            return false;
        },
        success: function(data){
            issave='yes';
           	if(data.code=='-1'){
			   	RemindsMsg("","LdPopWidth400px","","yes","yes",data.label);
			   	//确定事件
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					getCreateCustomFieldForm(modulename,blockid,mode);
					// CrmPopup.global_listPopupObj.pop();
				});
           }else if(data.code=='-2'){
			   	RemindsMsg("","LdPopWidth400px","","yes","yes",data.label);
			   	return false;
			}else{
				getCreateCustomFieldForm(modulename,blockid,mode);
				/// CrmPopup.global_listPopupObj.pop();
		   }
        }
    });
}

function getCreateCustomFieldForm(modulename,blockid,mode)
{
    var popupObj=CrmPopup.getPopupObj('last'),
		popupJqObj = ld(`#${popupObj.divid}`);
	var formulacontent='';
	var formulavar="";
	var formulacolumn="";

    var type = document.getElementById("fieldType_"+blockid).value;
   	var label = trim(document.getElementById("fldLabel_"+blockid).value);
   	var labels = trim(document.getElementById("fldLabels_"+blockid).value);
   	var fldLength = trim(document.getElementById("fldLength_"+blockid).value);
   	var fldDecimal = trim(document.getElementById("fldDecimal_"+blockid).value);
   	var fldallow_rewriting_value = 0;
   	var fldallow_rewriting = document.getElementById("fldallow_rewriting_"+blockid).checked;
   	var approvedemand=0;
	// @edit:liushuai,2020-08-24,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮,高级查找条件
   	var advancedemand = '';
   	var advancedemandgroups = '';
	var showallgroupstructure='yes';

   	if(fldallow_rewriting){
		fldallow_rewriting_value = 1;
   	}

    //zkt 【页面设置，字段显示并支持修改字符长度】--新增时设置默认值
    //非文本类型fldLength值应为空
    if(type.toLocaleLowerCase()!='text')
    {
        fldLength = '';
    }
    //非数字类型fldDecimal值应为空
    else if(type.toLocaleLowerCase()!='number'){
        fldDecimal = '';
    }
	//chj 2021/6/7 46241: 页面设置->新增字段->数字，长度输入256，小数位数2，保存后 ld_field 表 typeofdata='NN~O~256,2'
	if(type == 'number'){
		fldLength = 25;
	}
   	if(type.toLocaleLowerCase()=='picklist'||type.toLocaleLowerCase()=='multipicklist'){
      	var picklistvalue=ld("#fldpicklist_"+blockid).select2('data');
       	if(picklistvalue!=undefined){
            var fldPickListvalues=[];
            ld.each(ld("#fldpicklist_"+blockid).select2('data'),function(index,info){
                var text=info.text;
                fldPickListvalues.push(text);
            });
            var fldPickList = encodeURIComponent(fldPickListvalues.join("##,,##"));
        }
       	else
            var fldPickList="";
       	if(fldPickList==''){
            RemindsMsg("","LdPopWidth400px","",'yes','yes','下拉框列表值不能为空！');
            return false;
       	}
   	}
   	else{
        var fldPickList="";
   	}
   	if(label =='' || labels ==''){
    	return false;
   	}
   	var activatefield='2';
   	var savedatabase='yes';
   	var allowedit='yes';
   	var requiredfield='m';
   	var quickcreate='0';
    var relatemodulefield="";
    var relatemodule="";
    var referencemodule="";
    var maxrowsshow=5;
    var massedit=2;
    var fieldonly=0;
	var disallowed_copy='no';
    var datarang='all';
    var defaultvalue='';
	var take_photo_only_check = 0;
	var uploadwatermark = 'no';
	var auto_signin = 'no';
	var no_signin = 'no';
	var editview_signin = 'no';
	var editview_resignin = 'no';
	var allowable_distance = 0;
	var subtotal_attr = 'no';
	var auto_wordwrap = 'no';
	// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
	var word_watermark = 'no';
	var excel_watermark = 'no';
	var word_watermark_settingid = '';
	var excel_watermark_settingid = '';
	var helptips = '';

    //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选），引用字段增加“显示超链接”字段属性
    var ShowHyperlinks = 'no';
	//edit: xll 2023/09/02 BUG0071780 页面设置-客户管理，新增“关联选择单据（多选）”字段，设置“显示超链接”，无法保存该设置，第二次编辑设置才能保存。
    var HrefType_Array = new Array('1','reference','relatedmodulefield','multireference');
    if(HrefType_Array.includes(type))
        ShowHyperlinks = (ld("#ShowHyperlinks_"+blockid).prop("checked")) ? 'yes' : ShowHyperlinks;

	//@edit:liushuai,2021-06-04,reason:【ID1001652】页面设置，“附件”和“图片”字段增加字段属性，控制签到水印是否显示（第二版）
	var selectmemberfield = '';

	// edit: xll 2024/09/26 XUQIU20240813-12 日期、日期时间、时间字段格式化
	var valueFormat = '',
		formatTypeArr = ['date', 'datetime', 'time'];
	if(formatTypeArr.includes(type)) {
		valueFormat = popupJqObj.find(`#value_format_${blockid}`).val();
	}

    if(ld("#notallowduplicate_"+blockid).prop("checked")){
        fieldonly=1;
    }
	if(ld("#disallowed_copy_"+blockid).prop("checked")){
		disallowed_copy='yes';
	}
	if(ld("#subtotalattr_"+blockid+":visible").length > 0 && ld("#subtotalattr_"+blockid+":visible").prop("checked")){
		subtotal_attr = 'yes';
	}
	if(ld("#auto_wordwrap_"+blockid).prop("checked")){
		auto_wordwrap = 'yes';
	}

	if(ld("#take_photo_only_check_"+blockid).prop("checked")){
        take_photo_only_check=1;
    }
	if(ld("#uploadwatermark_check_"+blockid).prop("checked")){
		uploadwatermark='yes';
	}
    if(!ld("#requiredfield_"+blockid).prop("checked")){
        requiredfield='o';
    }
	if(!ld("#allowedit_"+blockid).prop("checked")){
		allowedit='no';
	}
   	if(type=='relatedmodulefield'){
        if(!ld("#activate_field_"+blockid).prop("checked")){
            activatefield='1';
        }
        if(!ld("#savedatabase_"+blockid).prop("checked")){
            savedatabase='no';
        }
        if(!ld("#quickcreate_"+blockid).prop("checked")){
            quickcreate='1';
        }
        if(!ld("#allowedit_"+blockid).prop("checked")){
            allowedit='no';
        }
		var relatemodule=ld("#relatedmodule_"+blockid).val();
		if(relatemodule=='Users'){
			var selectmemberfield = ld("#selectmemberfield_"+blockid).val();
		}
        var relatemodulefield=ld("#relatedmodulefield_"+blockid).val();
   	}
   	else if(type=='reference'||type=='multireference'){
        referencemodule=ld("#"+type+"module_"+blockid).val();
        datarang=ld("#datarange_"+blockid).val();
        maxrowsshow=ld("#maxrowsshow_"+blockid).val();
        if(!ld("#activate_field_"+blockid).prop("checked")){
            activatefield='1';
        }
        if(!ld("#requiredfield_"+blockid).prop("checked")){
            requiredfield='o';
        }
        if(!ld("#quickcreate_"+blockid).prop("checked")){
            quickcreate='1';
        }
        approvedemand=ld("#approve_demand_"+blockid).val();
        defaultvalue=ld("#defaultvalue_"+blockid).val();
		advancedemand=ld('#advance_demand_'+blockid).val();
		advancedemandgroups=ld('#advance_demand_groups_'+blockid).val();
	}
	else if(type=='multipicklist'){
        //多选下拉框
        defaultvalue=getMultiPickListSelectValue("defaultvalue_"+blockid+"_multipicklist");
   	}
   	else if(type=='checkbox'){
        fieldonly=0;
        if(ld("#defaultvalue_"+blockid+"_chkbox").prop("checked"))
            defaultvalue=1;
   	}
   	else if(type=='picklist'){
        //下拉框单选
        defaultvalue=ld("#defaultvalue_"+blockid+"_picklist").val();
   	}
   	else if(type == 'fileattachment' || type == 'picture'){//ls 2022-04-06 【1002543】页面设置，增加“图片”字段类型
		if(!ld("#quickcreate_"+blockid).prop("checked")){
            quickcreate='1';
        }
		// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
		if(type == 'fileattachment'){
			word_watermark = (ld('#word_watermark_'+blockid).prop('checked'))?'yes':'no';
			word_watermark_settingid =ld('#word_watermark_setting_'+blockid).attr('settingid');
			excel_watermark = (ld('#excel_watermark'+blockid).prop('checked'))?'yes':'no';
			excel_watermark_settingid =ld('#excel_watermark_setting_'+blockid).attr('settingid');

		}
   	}
	else if(type == 'memberdepartment'){
		selectmemberfield = ld("#selectmemberfield_"+blockid).val();
		quickcreate='1';
		allowedit = 'no';
	}
	else if(type == 'signin'){	//签到
		if(ld("#auto_signin_"+blockid).prop("checked")){
            auto_signin='yes';
        }
        if(ld("#no_signin_"+blockid).prop("checked")){
            no_signin='yes';
            allowable_distance = ld('#allowable_distance_'+blockid).val();
            if(allowable_distance == 'custom'){
            	if(ld('#custom_allowable_distance_'+blockid).val() == ''){
            		RemindsMsg("","LdPopWidth400px","",'yes','yes',arrJsPopLabel['Checkinerrorvaluecannotbeempty']);
            		return false;
            	}else{
            		allowable_distance = ld('#custom_allowable_distance_'+blockid).val();
            	}
            }
        }
		if(ld("#editview_signin_"+blockid).prop("checked")){
			editview_signin='yes';
		}
		if(ld("#editview_resignin_"+blockid).prop("checked")){
			editview_resignin='yes';
		}
	}
	else if(type == 'selectoneuser'||type == 'selectmultiuser'){
		var memberrange_type=ld('#memberrangetype_'+blockid).val();
		var showallgroupstructure_check=ld('#showallgroupstructure_check_'+blockid);
		if(showallgroupstructure_check != null){
			showallgroupstructure=showallgroupstructure_check.prop("checked") ?'yes':'no';
			if(memberrange_type=='All'){
				showallgroupstructure = 'yes';
			}
		}
		if(memberrange_type == 'All' || memberrange_type=='Modules'){
			advancedemand='null####'+ld("#memberrange_other_condition"+blockid).val();
			advancedemandgroups=memberrange_type+'####'+ld("#memberrange_other_condition_groups"+blockid).val();
		}else if(memberrange_type == 'Person' || memberrange_type == 'Departments' || memberrange_type == 'Roles' || memberrange_type == 'Position'){
			advancedemand=ld("#advance_demand_"+memberrange_type+'_'+blockid).val()+'####'+ld("#memberrange_other_condition"+blockid).val();
			advancedemandgroups=memberrange_type+'####'+ld("#memberrange_other_condition_groups"+blockid).val();
			if(empty(ld('#advance_demand_'+memberrange_type+'_'+blockid).val())){
				var confirm_str='';
				if(memberrange_type == 'Person')
					confirm_str = arrJsPopLabel['Pleaseselectatleastoneperson'];
				else if(memberrange_type == 'Departments')
					confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
				else if(memberrange_type == 'Roles')
					confirm_str = arrJsPopLabel['Pleaseselectatleaprofile'];
				else if(memberrange_type == 'Position')
					confirm_str = arrJsPopLabel['Pleaseselectatleaposition'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}
		}else if(memberrange_type==''){
			var confirm_str=arrJsPopLabel['PlEASEINPUTSETMEMBERRANGE'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}

	}
    else if(type == 'textarea' || type == 'longtextarea'){
        defaultvalue=ld("#defaultvalue_"+blockid+"_textarea").val();
   	}
	else if (type == 'date' || type == 'datetime'){
		defaultvalue=ld("#defaultvalue_"+blockid+"_date").val();
	}
   	else{
        defaultvalue=ld("#defaultvalue_"+blockid+"_name").val();
   	}
   	//手机正则表达式
   	if(ld("#regexp_"+blockid).prop("checked")){
    	var regexp=1;
   	}
   	else{
        var regexp=0;
   	}
	//chj 2021/5/18 45760: （61mis.com/kfbcrm）系统设置-页面设置-客户；新增文本类型字段，没有新增时没有勾选批量编辑，保存后编辑该字段，发现默认勾选上了“批量编辑”的设置
	if(ld("#massedit_"+blockid).prop("checked")){
		massedit=1;
	}
	// zxm 2021-0408 二维码类型
	var fdcodetype_value = '';
	var qrcodetemplateid = '';
	if(type=='qrcode'){
		fdcodetype_value = ld("#fdcodetype_"+blockid).val();
        if(fdcodetype_value ==1503){
            qrcodetemplateid = ld("#"+popupObj.divid+" [id=formqrcodeTemplateCreate]").attr('data-templateid');
        }else{
            qrcodetemplateid = ld("#qrcodeTemplateCreate").attr('data-templateid');
        }

	}
	//zxm 2021-1228 字段颜色设置字段说明设置  //hjz 货币 数字 日期 时间 日期时间 百分比 电话 手机增加字段颜色设置
	if(ColorTypeArr.indexOf(type)!='-1'){
		// fieldvaluecolor
		// fieldplaceholder
		if(type=='phone'||type=='mobile'){
			var fieldvaluecolor = ld("#phone_fieldvaluecolor_"+blockid).val();
		}
		else{
		    var fieldvaluecolor = ld("#fieldvaluecolor_"+blockid).val();
		}
		var fieldplaceholder = ld("#fieldplaceholder_"+blockid).val();
	}else if(type == 'url'){
		var fieldplaceholder = ld("#fieldplaceholder_"+blockid).val();
	}
	//edit:duan date:2024/12/5 reason:字段标签颜色
	var labelvaluecolor = ld('#labelvaluecolor_' + blockid).val();

	// 帮助信息
	if(type != 'signin'){
		helptips = ld("#helptips_"+blockid).val();
		helptips = encodeURIComponent(helptips);
	}

   	var otherurl="&activatefield="+activatefield+"&savedatabase="+savedatabase+"&requiredfield="+requiredfield+"&quickcreate="+quickcreate;
   	otherurl+="&relatemodule="+relatemodule+"&relatemodulefield="+relatemodulefield+"&allowedit="+allowedit+"&presence="+activatefield;
   	otherurl+="&fieldonly="+fieldonly+"&massedit="+massedit+"&datarang="+datarang+"&maxrowsshow="+maxrowsshow+"&referencemodule="+referencemodule;
   	otherurl+="&defaultvalue="+defaultvalue+"&approvedemand="+approvedemand+"&advancedemand="+advancedemand+"&advancedemandgroups="+advancedemandgroups+"&memberrange_type="+memberrange_type;
   	otherurl+="&regexp="+regexp+'&take_photo_only_check='+take_photo_only_check+'&uploadwatermark='+uploadwatermark+'&selectmemberfield='+selectmemberfield;

	otherurl+="&fieldvaluecolor="+fieldvaluecolor+"&fieldplaceholder="+fieldplaceholder+'&labelvaluecolor='+labelvaluecolor;
	otherurl+="&auto_signin="+auto_signin+"&no_signin="+no_signin+"&allowable_distance="+allowable_distance;
	otherurl+="&editview_resignin="+editview_resignin+"&editview_signin="+editview_signin;

    //edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）增加“显示超链接”字段属性
    otherurl += "&ShowHyperlinks="+ShowHyperlinks+"&disallowed_copy="+disallowed_copy;// ljj 2023-08-17 BUG0070653 kfbtest-销售机会-单据详情页，销售阶段推进任务中的附件设置浮显
	//edit: hzx 是否小计
	otherurl += "&subtotal_attr="+subtotal_attr;
	otherurl += "&showallgroupstructure="+showallgroupstructure;
	//edit: xxy 内容过多自动换行属性
	otherurl += "&auto_wordwrap="+auto_wordwrap;
	otherurl += "&helptips="+helptips;// 帮助信息

  	// alert('module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=addCustomField&fld_module='+modulename+'&ajax=true&blockid='+blockid+'&fieldType='+type+'&fldLabels='+labels+'&fldLabel='+label+'&fldLength='+fldLength+'&fldDecimal='+fldDecimal+'&fldPickList='+fldPickList+'&fldallow_rewriting='+fldallow_rewriting_value+otherurl);
  	// return false;

	// ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
	//录入方式
	var inputModeType = ld('#inputModeType_'+blockid).val();
	otherurl += '&inputModeType='+inputModeType;
	// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）
	otherurl += '&word_watermark='+word_watermark;
	otherurl += '&excel_watermark='+excel_watermark;
	excel_watermark_settingid = empty(excel_watermark_settingid)?'empty':excel_watermark_settingid;
	word_watermark_settingid = empty(word_watermark_settingid)?'empty':word_watermark_settingid;
	otherurl += '&excel_watermark_settingid='+excel_watermark_settingid;
	otherurl += '&word_watermark_settingid='+word_watermark_settingid;

	//edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
	var keyArr = ['DownloadAllowed','PreviewAllowed'];
	popupObj['PreviewAllowed'] = popupObj['DownloadAllowed'];
	var checkObj = popupJqObj.find(`#FileAllowed_${blockid}`);
	ld.each(keyArr,function (i,v) {
		if(typeof popupObj[v] !== "undefined" && checkObj.length > 0 && checkObj.prop("checked")) {
			otherurl += `&${v}=yes`;
			ld.each(popupObj[v], function (set_key, set_val) {
				otherurl += `&${v}_${set_key}=${set_val}`;
			})
		}
	})

	// edit: xll 2024/09/26
	otherurl += `&value_format=${valueFormat}`;

	if(inputModeType == 2)
	{
		//通过公式计算
		formulacontent=ld('#definitionformula_'+blockid).val().trim();
		if(formulacontent==''){
			ld('#rptContentLoading').hide();
			var confirm_str = arrJsPopLabel['Formulacontentcannotbeempty'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var tableobj=document.getElementById('toolfieldFormula_'+blockid);
		for(i=0;i<tableobj.rows.length-1;i++)
		{
			var tmpcol=document.getElementById('formualcombox_'+blockid+"_"+i).options[document.getElementById('formualcombox_'+blockid+"_"+i).selectedIndex].value;
			var tmpletter=document.getElementById('formualtext_'+blockid+"_"+i).value;
			if(tmpcol=='none'||ld.trim(tmpletter)=='')
			{
				continue;
			}
			formulavar+=document.getElementById('formualtext_'+blockid+"_"+i).value;
			formulacolumn+=document.getElementById('formualcombox_'+blockid+"_"+i).options[document.getElementById('formualcombox_'+blockid+"_"+i).selectedIndex].value;
			if(i!=tableobj.rows.length-2){
				formulavar+=",";
				formulacolumn+=",";
			}
			tableobj[document.getElementById('formualtext_'+blockid+"_"+i).value]=document.getElementById('formualcombox_'+blockid+"_"+i).options[document.getElementById('formualcombox_'+blockid+"_"+i).selectedIndex].value;
		}

		var formulacontent=document.getElementById('definitionformula_'+blockid).value;
		formulacontent=formulacontent.replace(/(^\s*)|(\s*$)/g, "");
		var formualValidata_msg = formualValidata(formulacontent,tableobj);

		if(formualValidata_msg != ''){
			ld('#rptContentLoading').hide();
			RemindsMsg("","LdPopWidth400px","","yes","yes",formualValidata_msg);
			ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
				ld('#rptContentLoading').show();
			})
		}

		otherurl += '&formulacontent='+encodeURIComponent(formulacontent)+'&formulavar='+encodeURIComponent(formulavar)+'&formulacolumn='+encodeURIComponent(formulacolumn);
		/*if(!formualValidata(formulacontent,tableobj)){
            return false;
        }*/
	}
	else if(inputModeType == 1){//分录函数
		var functioncolumn = ld('#attributeField_'+blockid).val();
		var functiontype = ld('#functionType_'+blockid).val();
		otherurl += '&functiontype='+functiontype+'&functioncolumn='+functioncolumn;
	}
	else if(inputModeType == 3){ //通过SQL查询
		formulacontent=ld('#definitionsqlformula_'+blockid).val().trim();
		if(formulacontent==''){
			ld('#rptContentLoading').hide();
			var confirm_str = arrJsPopLabel['SQLFormulaCannotEmpty'];
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			return false;
		}
		var tableobj=document.getElementById('toolfieldFormula_'+blockid);
		for(i=0;i<tableobj.rows.length-1;i++)
		{
			var tmpcol=document.getElementById('formualcombox_'+blockid+"_"+i).options[document.getElementById('formualcombox_'+blockid+"_"+i).selectedIndex].value;
			var tmpletter=document.getElementById('formualtext_'+blockid+"_"+i).value;
			if(tmpcol=='none'||ld.trim(tmpletter)=='')
			{
				continue;
			}
			formulavar+=document.getElementById('formualtext_'+blockid+"_"+i).value;
			formulacolumn+=document.getElementById('formualcombox_'+blockid+"_"+i).options[document.getElementById('formualcombox_'+blockid+"_"+i).selectedIndex].value;
			if(i!=tableobj.rows.length-2){
				formulavar+=",";
				formulacolumn+=",";
			}
			tableobj[document.getElementById('formualtext_'+blockid+"_"+i).value]=document.getElementById('formualcombox_'+blockid+"_"+i).options[document.getElementById('formualcombox_'+blockid+"_"+i).selectedIndex].value;
		}

		otherurl += '&formulacontent='+encodeURIComponent(formulacontent)+'&formulavar='+encodeURIComponent(formulavar)+'&formulacolumn='+encodeURIComponent(formulacolumn);
	}
	
	//敏感规则保存
	var sensitive_info = '';
	if(type == 'text' || type == 'textarea' || type == 'number' || type == 'qq'|| type == 'phone'|| type == 'mobile' || type == 'email' || type == 'currency'){
		if(ld("#"+popupObj.divid+' table.SensitiveTable').length > 0){
			var ruletrobj = ld("#"+popupObj.divid+' table.SensitiveTable').find('tr[id^=setting_]');
			var sensitive_ruleid_arr = [];
			ruletrobj.each(function() {//获取已存在的规则
				var exist_ruleid = ld(this).attr('ruleid');
				exist_ruleid = parseInt(exist_ruleid, 10);
				if (exist_ruleid != undefined) {
					sensitive_ruleid_arr.push(exist_ruleid);
				}
			});
			var sensitive_ruleid_str = sensitive_ruleid_arr.join(',');
			var sensitivepresence = ld("#"+popupObj.divid+" [name=sensitivepresence]").is(':checked'); //敏感规则开启状态
			if(sensitivepresence == true){
				sensitivepresence = 'yes';
			}
			else{
				sensitivepresence = 'no'
			}
			sensitive_info = "&sensitive_ruleid_arr="+sensitive_ruleid_str+"&sensitivepresence="+sensitivepresence;
		}
	}

	var popupobj=CrmPopup.getPopupObj("last");
	puyoungJS_DialogBox.block();
	ldAjaxHtmlNoProgress('index.php?','module=Settings&action=SettingsAjax&file=LayoutBlockList&sub_mode=addCustomField&fld_module='+modulename+'&ajax=true&blockid='+blockid+'&fieldType='+type+'&fldLabels='+labels+'&fldLabel='+label+'&fldLength='+fldLength+'&fldDecimal='+fldDecimal+'&fldPickList='+fldPickList+'&fldallow_rewriting='+fldallow_rewriting_value+otherurl+"&fdcodetype_value="+fdcodetype_value+"&qrcodetemplateid="+qrcodetemplateid+"&ColorTypeArr="+ColorTypeArr+"&advancedemandgroups="+advancedemandgroups+"&advancedemand="+advancedemand+"&memberrange_type="+memberrange_type+sensitive_info,function(ajaxhtml) {
		var str = trim(ajaxhtml);
		if(str == "CHECKSQLERROR")
		{
			MessagePopup.TipOne_warning(arrJsPopLabel['QuerySqlError']);
			return false;
		}

		puyoungJS_DialogBox.unblock();
		if(popupobj.type!='ismoduletree'){
			var addid = "addfield_"+blockid;
			fninvshnew(addid);
		}else{
			popupobj.CancelEvent();
			Refresh_group_values(modulename);
			return false;
		}


		if(str == 'ERROR'){
			var confirm_str = arrJsPopLabel['LABELALREADYEXISTS'];
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}else{
			CrmPopup.global_listPopupObj.pop();
			sethtml(document.getElementById('cfList'),str);

			var worker = new Worker("include/js/CacheWork.js");
			var url_arr=window.location.href.split("?");

			worker.postMessage({'module':"Settings","url":url_arr[0],'fieldmodule':modulename});
			worker.onmessage = function(event) {

				worker.terminate();

			}

		}
		layoutblockEventClick();
		gselected_fieldtype = '';
	});
}

function cancelwindow(){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
}

function addField(blockid,tabid)
{
    if(tabid == ''){//hjz 页面设置不需要tabid 树结构设置里需要tabid参数
        fnvshobj(this,'addfield_'+blockid);
    	ld('#addfield_'+blockid).css('zIndex',1003);
		ld('#addfield_'+blockid).css('width','650px');
        ld('#layer').css('zIndex',1002);
        var popupobj=new Object();
        popupobj.divid='addfield_'+blockid;
        popupobj.fieldid=0;
        CrmPopup.global_listPopupObj.push(popupobj);
        ld("#"+popupobj.divid+" [name=selectfieldtype]").val(0);//选中文本
    	// @edit:dong @date:2020/09/22 @reason:  bug 0042564 页面设置：点击【新增字段】，选择字段类型后点击【×】按钮，再次点击【新增字段】时，字段类型后面显示异常
    	//多次执行select2 出现多个select2创建的div
    	ld("#"+popupobj.divid + " .selectfieldtype").next().remove();

    	ld("#"+popupobj.divid + " .selectfieldtype").select2({
    		templateResult: selectfieldtypeImage,
    		width:'85%'
    	});
		//BUG0063179 zxm 20230505 “页面设置”，新增字段，选择字段类型：关联选择单据（单选），“字段类型下拉框”和“关联选择对象下拉框”，点击下拉框，再将鼠标移动到新建窗口中下拉框以外的区域上下滑动鼠标滚轮，下拉框值显示区域不跟随变化
		ld("#"+popupobj.divid+" #addpicklistfield_div").scroll(function(){
			ld("#"+popupobj.divid + " .selectfieldtype").select2('close');
		});

		ld('#qrcodeTemplateCreate').attr('data-templateid',0);

        //var cls_resetComboxHtmlobj=new cls_resetComboxHtml('selectfieldtype');
        //cls_resetComboxHtmlobj.setComboxObjHtml();
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_"+blockid+"_picklist");
        cls_resetComboxHtmlobj.setComboxObjHtml();

        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("relatedmodule_"+blockid);
        cls_resetComboxHtmlobj.setComboxObjHtml();
		//CrmPopup.global_listPopupObj.push(popupobj);

     }else{
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml("defaultvalue_"+blockid+"_picklist");
        cls_resetComboxHtmlobj.setComboxObjHtml();
   		var popupobj=CrmPopup.getPopupObj("last");
		   //CrmPopup.global_listPopupObj.push(popupobj);
     }
    makeFieldSelected(ld("#"+popupobj.divid+" [name=selectfieldtype]").get(0),0,blockid);
    //ld("#defaultvalue_"+blockid+"_picklist").select2({closeOnSelect: false});
	// ls 2022-04-15 【1000118】页面设置，字段属性中增加【字段公式】页签
	PageSetup.changePageSetupMenu(1,blockid);//新增字段默认【基本属性】页签
	PageSetup.selectInputMode('',blockid);//默认录入方式为手动录入（当新增字段弹窗关闭未保存则清空）
	PageSetup.selectFunction('',blockid);//选择函数功能时初始化下拉框字段
	//获取公式计算的下拉框字段列表(连续新增删除字段时需要及时更新)
	PageSetup.getFormualFields();
	PageSetup.getFormualFieldsSql();
	//console.log(CrmPopup.global_listPopupObj);
	blk = '#addfield_'+blockid;
	// var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
	// crmPopupobj.prevshow();
	// let savefun = () => {
	// 	return find_custom_fieldlabel_exists(MODULE,blockid,'add');
	// };

	// var content = ld('#addfield_'+blockid).get(0).innerHTML;
	// console.log(content);
	// crmPopupobj.setParams("xxx",savefun,"","LdPopWidth800px",'Settings',[MODULE,blockid,'add'],arrJsPopLabel['SAVE'],"",arrJsPopLabel['CANCEL']);
	// crmPopupobj.show(content);

	// 帮助信息悬浮提示
	ld("#tr_helptips_"+blockid).find('b').removeClass('bindtip');
	tooltip(ld("#tr_helptips_"+blockid).find('.tip-items-list'), {transition: true, time: 200});
}

function Refresh_group_values(module){
    var popupobj=CrmPopup.getPopupObj("last");
    ld("#"+popupobj.divid+" [name=tree_fieldname]").empty();
    var urlstring = 'index.php?module='+module+'&action='+module+'Ajax&file=ModuleTree&RefreshGroupValues=yes';
    ldAjax(urlstring,{},function(data){
        if(data.code == 1){
            var table_html = '';
            ld.each(data.result['FIELDTREE'], function(index, value){
                if(data.result['FIELDNAME']==value){
                    table_html += '<option value='+index+'selected>'+value+'</option>';
                }else{
                    table_html += '<option value='+index+'>'+value+'</option>';
                }
            });
			if (data.result.field_length > 0){
				ld('#'+popupobj.divid+' #addNewDependencyPicklist').css('display','');
			}
            DelProgressObjs();
            ld("#"+popupobj.divid+" [name=tree_fieldname]").append(table_html);
        }
    });
}
//duan 20230209 客户模块添加联系人字段
function ContactsfieldSet(blockid,frommodule){
    var url = 'index.php?module=Settings&action=SettingsAjax&file=ContactsFieldSet&mode=edit';
    url += '&blockid='+blockid+'&frommodule='+frommodule;
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth650px",'Settings',"","","","");
	crmPopupobj.prevshow();
    ldAjax(url,'',function(data){
        crmPopupobj.setParams(data.result.title,ContactsfieldSave,"","LdPopWidth650px",'Settings',"",data.result.oktext,"",data.result.canceltext);
        crmPopupobj.quickcreatehtml=data.result.content;
		crmPopupobj.show(data.result.content);

		var tableobj = ld('#'+popupobj.divid).find(" table.ContactsFieldSetting");
		var LeftObj = tableobj.find(" .commonMultipleSelect:first");
		var RightObj = tableobj.find(" .commonMultipleSelect:last");
		var Drag_Transfer = new DragTransfer();
		Drag_Transfer.SetDragTransfer(tableobj,LeftObj,RightObj,'reset','250');
        crmPopupobj.center();
        crmPopupobj.blockid = blockid;
        crmPopupobj.frommodule = frommodule;
    })
}

function ContactsfieldSave(){
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
	var selectedColumnsObj=getObj("selectedAssmablyColumns");
    var selectedColStr = "";
    for (i=0;i<selectedColumnsObj.options.length;i++)
    {
        selectedColStr += selectedColumnsObj.options[i].value + "##";
    }
	var noselectedColumnsObj=getObj("AssmablyList");
	var noselectedColStr = "";
	for (i=0;i<noselectedColumnsObj.options.length;i++)
	{
		noselectedColStr += noselectedColumnsObj.options[i].value + "##";
	}
    var blockid = popupobj.blockid;
    var frommodule = popupobj.frommodule;
    popupobj.CancelEvent();
    var param = {'selectedfieldname':selectedColStr,'noselectedfieldname':noselectedColStr};
    var url = "index.php?module=Settings&action=SettingsAjax&file=ContactsFieldSet&mode=save";
    url += '&blockid='+blockid+'&frommodule='+frommodule;
    ldAjax(url,param,function(data){
        if(data.code == 1){
            //刷新字段界面
            ld.ajax({
                url: 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockList&fld_module='+frommodule+'&ajax=true',
                type: 'POST',
                data: '',
                dataType:'html',
                async: true,//
                timeout: 5000,
                success: function(rest)
                {
                    sethtml(document.getElementById('cfList'),rest);
                    layoutblockEventClick();

                }
            });
        }
        DelProgressObjs();
    });
}

{/literal}
</script>