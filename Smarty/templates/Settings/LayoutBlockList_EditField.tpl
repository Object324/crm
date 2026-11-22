<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/js/modules/Settings/SensitiveRules.js?v={$GLOBALMINVERSION}"></script>
<div id="editfield_{$value.fieldid}">
	<!--页签-->
	<div id="changemenu_{$value.fieldid}" class="ld-ui-tabs" {*{if $isShowAdvanced eq 'no'}style="display: none{/if};"*}>
		<ul class="ld-ui-tabs-nav">
			<li class="ld-ui-tabs-active" onclick="PageSetup.changePageSetupMenu(1,{$value.fieldid})" tag="1"><a href="javascript:;">{'BASICPROPERTIES'|@getFixedLabel}</a></li>
			<li onclick="PageSetup.changePageSetupMenu(2,{$value.fieldid})" tag="2" id="producttool_formula"><a href="javascript:;">{'INPUTMODE'|@getFixedLabel}</a></li>
			{if $value.bigtype eq 'number' ||$value.bigtype eq 'qq'||$value.bigtype eq 'phone'|| $value.bigtype eq 'mobile' || $value.bigtype eq 'email' || $value.bigtype eq 'currency' || $value.bigtype eq 'text' || $value.bigtype eq 'textarea'|| $value.bigtype eq 'longtextarea'
			|| ($value.bigtype == 'relatedmodulefield' &&($value.parentbigtype eq 'number' ||$value.parentbigtype eq 'qq'||$value.parentbigtype eq 'phone'|| $value.parentbigtype eq 'mobile' || $value.parentbigtype eq 'email' || $value.parentbigtype eq 'currency' || $value.parentbigtype eq 'text' || $value.parentbigtype eq 'textarea' || $value.parentbigtype eq 'longtextarea'))}
				<li onclick="PageSetup.changePageSetupMenu(3,{$value.fieldid})" tag="3" id="sensitive_rule"><a href="javascript:;">{'SensitiveRules'|@getFixedLabel}</a></li>
			{/if}
		</ul>
	</div>
	<!--基本属性-->
	<div id="basicDiv_{$value.fieldid}" style="">
	<table class="settingPopTable settingPopTableNoBot DetailContentTable" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr id="editfield_{$value.fieldid}heading" {if $value.bigtypelabel eq ''} style="display:none"{/if}>
			<td width="145" align="right" >
				{'fieldtype'|@getFixedLabel}
			</td>
			<td align="left">
                {*//zkt 0050019: 页面设置和单据分录定制，编辑字段界面优化，将“字段类型”改成文本显示，不要显示文本框不可编辑状态（不要影响保存）*}
				{$value.bigtypelabel}<input type="text" style="display:none" class="ld-input-inner gwidth90" disabled readonly=""  value="{$value.bigtypelabel}" /> 
			</td>
		</tr>
		<tr id="editfield_{$value.fieldid}heading">
			<td width="145" align="right" >
				{'CNTAG'|@getFixedLabel}
			</td>
			<td align="left">
				<input type="text" class="ld-input-inner gwidth90" name="fieldlabel" id="fieldlabel_{$value.fieldid}" value="{$value.fieldlabel_zh}" /> 
			</td>
		</tr>
		<tr id="editfield_{$value.fieldid}heading">
			<td width="145" align="right" >
				{'ENTAG'|@getFixedLabel}
			</td>
			<td align="left">
				<input type="text" class="ld-input-inner gwidth90" name="fieldlabels" id="fieldlabels_{$value.fieldid}" value="{$value.fieldlabel_en}" />
			</td>
		</tr>
		{if $valueFormatShow}
			<tr id="tr_value_format_{$value.fieldid}" >
				<td align="right">{'STYLE'|@getFixedLabel}</td>
				<td align="left">
					<div style="display: flex;align-items: center;">
						<div style="width: 200px;height: 100%;display: inline-block;">
							<select id="value_format_{$value.fieldid}" name="value_format_{$value.fieldid}" class="ld-select-inner gwidth50" >

							</select>
						</div>
						<b id="value_format_{$value.fieldid}_tip" class="ld-fonticon ld-fonticon-help" data-tip="" style="margin: 0 5px 0 5px;"></b>
						<span id="value_format_{$value.fieldid}_example" class="" >
							{'SuchAs'|@getFixedLabel}
							<span></span>
						</span>
					</div>
				</td>
			</tr>
		{/if}
		{*//wyt 220920 1000061 选用户（负责人、单选用户、多选用户、团队成员）字段控制只允许选择满足一定条件的数据*}
		{if $value.bigtype eq 'selectoneuser' ||$value.bigtype eq 'selectmultiuser'||$value.bigtype eq 'users'||($value.bigtype eq 'text' && $value.uitype eq '154')}
			<tr id="tr_memberrangetype_edit{$value.fieldid}" >
				<td align="right" valign="center">{'SETMEMBERRANGE'|@getFixedLabel}</td>
				<td align="left">
					<select id="memberrangetype_{$value.fieldid}" name="memberrangetype_{$value.fieldid}" onchange="edit_memberrange_selected(this,{$value.fieldid},{$value.uitype},'{$value.columnname}');" class="ld-select-inner gwidth50">
						<option value="All" {if $value.advance_demandgroups eq 'All'}selected{/if}>{'ALL'|@getFixedLabel}</option>
						<option value="Module" {if $value.advance_demandgroups eq 'Module'}selected{/if}>{'MODUELDATARANGE'|@getFixedLabel}</option>
						<option value="Person" {if $value.advance_demandgroups eq 'Person'}selected{/if}>{'SETBYUSERS'|@getFixedLabel}</option>
						<option value="Departments" {if $value.advance_demandgroups eq 'Departments'}selected{/if}>{'SETBYDEPARTMENT'|@getFixedLabel}</option>
						<option value="Roles" {if $value.advance_demandgroups eq 'Roles'}selected{/if}>{'SETBYROLEPROFILE'|@getFixedLabel}</option>
						<option value="Position" {if $value.advance_demandgroups eq 'Position'}selected{/if}>{'SETBYPOSITION'|@getFixedLabel}</option>
					</select>
					<a href="javascript:;" tmprange="memberrange" onclick="fun_other_conditions(this,'{$value.fieldid}');">{'OtherConditions'|@getFixedLabel}</a>
					<input type="hidden" id="memberrange_type{$value.fieldid}" name="memberrange_type{$value.fieldid}" value="{$value.advance_demandgroups}"/>
					<input type="hidden" id="memberrange_other_condition{$value.fieldid}" name="memberrange_other_condition{$value.fieldid}" value="{$value.member_range}"/>
					<input type="hidden" id="memberrange_other_condition_groups{$value.fieldid}" name="memberrange_other_condition_groups{$value.fieldid}" value="{$value.memberrange_type}"/>
				</td>
			</tr>
		{/if}
		<tr id="memberrangedetails_Person_{$value.fieldid}" {if $value.advance_demandgroups neq 'Person'}style="display: none" {/if}>
			<td align="right" valign="center"><font color="red">*</font>{'MEMBER'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Person_{$value.fieldid}" name="advance_demand_Person_{$value.fieldid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;width: 435PX;height: 25px;overflow: hidden">{$value.memberrange}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$value.fieldid}','Person','Person_{$value.fieldid}','{$MODULE}');"></a>
				<input type="hidden" value="{$value.advance_demandid}" id="Person_{$value.fieldid}" name="Person_{$value.fieldid}" />
			</td>
		</tr>
		<tr id="memberrangedetails_Departments_{$value.fieldid}" {if $value.advance_demandgroups neq 'Departments'}style="display: none" {/if}>
			<td align="right" valign="center"><font color="red">*</font>{'DEPARTMENT'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Departments_{$value.fieldid}" name="advance_demand_Departments_{$value.fieldid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;width: 435PX;height: 25px;overflow: hidden">{$value.memberrange}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$value.fieldid}','Departments','Departments_{$value.fieldid}','{$MODULE}');"></a>
				<input type="hidden" value="{$value.advance_demandid}" id="Departments_{$value.fieldid}" name="Departments_{$value.fieldid}" />
			</td>
		</tr>
		<tr id="memberrangedetails_Roles_{$value.fieldid}" {if $value.advance_demandgroups neq 'Roles'}style="display: none" {/if}>
			<td align="right" valign="center"><font color="red">*</font>{'PROFILES'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Roles_{$value.fieldid}" name="advance_demand_Roles_{$value.fieldid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;width: 435PX;height: 25px;overflow: hidden">{$value.memberrange}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$value.fieldid}','Roles','Roles_{$value.fieldid}','{$MODULE}');"></a>
				<input type="hidden" value="{$value.advance_demandid}" id="Roles_{$value.fieldid}" name="Roles_{$value.fieldid}" />
			</td>
		</tr>
		<tr id="memberrangedetails_Position_{$value.fieldid}" {if $value.advance_demandgroups neq 'Position'}style="display: none" {/if}>
			<td align="right" valign="center"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
			<td>
				<div id="advance_demand_Position_{$value.fieldid}" name="advance_demand_Position_{$value.fieldid}" class="ld-input-inner-div lfloat" style="line-height:23px;padding-left:8px;width: 435px;height: 25px;overflow: hidden">{$value.memberrange}</div>
				<a class="icon-homeimg icon-select lfloat" style="margin-top: 7px;" href="javascript:;"  title="{'SELECT'|@getFixedLabel}" onclick="get_member_bytype('{$value.fieldid}','Position','Position_{$value.fieldid}','{$MODULE}');"></a>
				<input type="hidden" value="{$value.advance_demandid}" id="Position_{$value.fieldid}" name="Position_{$value.fieldid}" />
			</td>
		</tr>
		<tr id="tr_showallgroupstructure_edit{$value.fieldid}" style="{if ($value.bigtype eq 'selectoneuser' || $value.bigtype eq 'selectmultiuser') && $value.advance_demandgroups neq 'All' && $value.advance_demandgroups neq '' && $value.uitype != 153 && ($value.uitype != 154 || $value.columnname == 'team_memberid')}{else}display:none;{/if}" >
			<td align="right">
				<label for="showallgroupstructure_check_{$value.fieldid}">{'Displayallgroupstructure'|@getFixedLabel}</label>
			</td>
			<td align="left"><input id="showallgroupstructure_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"{if $value.showallgroupstructure eq 'yes'}checked{/if}/></td>
		</tr>
        {*字符长度*}
        {if $value.customfieldflag neq 0 && $value.fldLength neq '' && $value.bigtype eq 'text' &&$value.uitype neq 4 &&$value.uitype neq 64 &&$value.uitype neq 65 &&$value.uitype neq 230 }
            <tr id="editfield_{$value.fieldid}heading">
    			<td width="145" align="right" >
    				{'CHARACTER'|@getFixedLabel}{'Length'|@getFixedLabel}
    			</td>
    			<td align="left">
                    <input type="hidden" id="fldlength_old_{$value.fieldid}" name="fldlength_old_{$value.fieldid}" value="{$value.fldLength}" />
    				<input type="text" class="ld-input-inner gwidth90" name="fldlength_{$value.fieldid}" id="fldlength_{$value.fieldid}" value="{$value.fldLength}" />
    			</td>
    		</tr>
        {/if}
        {*小数位数*}
        {if $value.customfieldflag neq 0 && $value.fldDecimal neq '' && $value.bigtype eq 'number' }
            <tr id="editfield_{$value.fieldid}heading">
    			<td width="145" align="right" >
    				{'Decimal'|@getFixedLabel}
    			</td>
    			<td align="left">
                    <input type="hidden" id="fldDecimal_old_{$value.fieldid}" name="fldDecimal_old_{$value.fieldid}" value="{$value.fldDecimal}" />
    				<input type="text" class="ld-input-inner gwidth90" id="fldDecimal_{$value.fieldid}" name="fldDecimal_{$value.fieldid}" value="{$value.fldDecimal}" />
                    
    			</td>
    		</tr>
        {/if}
		{if $value.bigtype eq 'reference'||$value.bigtype eq 'multireference'}
			<tr id="editfield_{$value.fieldid}heading">
				<td width="145" align="right" >
					<font color="red">*</font>{'RelateChoiceModule'|@getFixedLabel}
				</td>
				<td align="left">
					{$value.relatechoicemodule}<input type="text" style="display:none" class="ld-input-inner gwidth90" disabled readonly=""  value="{$value.relatechoicemodule}" />
				</td>
			</tr>
			{*BUG0068687 xxy 2023-7-20 提醒->页面设置，“提醒人”字段去掉“可选择的数据范围”、“审批要求”和“最多显示数据条数”参数*}
			{if $value.uitype neq 100}
				<tr style="height:30px;">
					<td width="60" align="right">
						<font color="red">*</font>{'ALLOWDataRange'|@getFixedLabel}
					</td>
					<td align="left">
						<select  id="datarang_{$value.fieldid}" name="datarang_{$value.fieldid}">
							<option value="all" {if $value.datarang eq 'all'} selected=""{/if} >{'ALL'|@getFixedLabel}</option>
							<option value="permit" {if $value.datarang eq 'permit'} selected=""{/if}>{'ALLOWINQUIRE'|@getFixedLabel}</option>
						</select>
					</td>
				</tr>
		  	{/if}
        {/if}
		{if ($value.bigtype eq 'reference' || $value.bigtype eq 'multireference') && $value.uitype neq 100}
			<tr>
				<td width="145" align="right" >
					{'APPROVEDEMAND'|@getFixedLabel}
				</td>
				<td>
					<select id="approve_demand_{$value.fieldid}" style="font-family: tahoma,arial,宋体;">
						<option value="0" {if $value.approve_demand eq 0}selected="yes"{/if}>{'NONE'|@getFixedLabel}</option>
						<option value="1" {if $value.approve_demand eq 1}selected="yes"{/if}>{'Approved'|@getFixedLabel}</option>
					</select>
					{*@edit:liushuai,2020-08-24,reason:ID1000927/页面设置，关联选择单据（单选）字段类型的字段编辑属性中增加“其他条件”文字按钮*}
					<input type="hidden" id="advance_demand_{$value.fieldid}" name="advance_demand_{$value.fieldid}" value="{$value.advance_demand}"/>
					<input type="hidden" id="advance_demand_groups_{$value.fieldid}" name="advance_demand_groups_{$value.fieldid}" value="{$value.advance_demand_groups}"/>
					{*231220 wym BUG0077541 kfbcrm-页面设置-不显示默认值的字段，审批要求点击其他条件，弹窗一直转圈*}
					{if $value.bigtype eq 'reference'}
						<input type="hidden" id="advance_referencemodule_{$value.fieldid}" value="{$UITYPEMODULES[$value.uitype]}" name="advance_referencemodule_{$value.fieldid}">
					{/if}
					{if $value.bigtype eq 'multireference'}
						<input type="hidden" id="advance_multireferencemodule_{$value.fieldid}" value="{$UITYPEMODULES[$value.uitype]}" name="advance_multireferencemodule_{$value.fieldid}">
					{/if}
					<a href="javascript:;"  onclick="fun_other_conditions(this,'{$value.fieldid}');">{'OtherConditions'|@getFixedLabel}</a>
				</td>
			</tr>
		{/if}
        {if ($value.bigtype eq 'reference' || $value.uitype eq 603 || $value.bigtype eq 'multireference') && $value.uitype neq 100}
            <tr style="height:30px;" id="tr_maxrowsshow_{$value.fieldid}" style="display:none">
				<td align="right">
                	<font color="red">*</font>{'MaxRowsShow'|@getFixedLabel}
				</td>
				<td align="left">
					<select id="maxrowsshow_{$value.fieldid}" name="maxrowsshow_{$value.fieldid}">
                         <option value="1" {if $value.maxrowsshow eq 1}selected=""{/if}>1</option>
                         <option value="5" {if $value.maxrowsshow eq 5}selected=""{/if}>5</option>
                         <option value="10" {if $value.maxrowsshow eq 10}selected=""{/if}>10</option>
                         <option value="15" {if $value.maxrowsshow eq 15}selected=""{/if}>15</option>
                         <option value="20" {if $value.maxrowsshow eq 20}selected=""{/if}>20</option>
                         <option value="50" {if $value.maxrowsshow eq 50}selected=""{/if}>50</option>
                         <option value="100" {if $value.maxrowsshow eq 100}selected=""{/if}>100</option>
                    </select>
				</td>
			</tr>
        {/if}
		{*默认值*}
		{assign var="defaultsetting" value=$value.defaultvalue}
		{if $defaultsetting.permitted eq true}
			{if $value.bigtype neq 'selectsource' && $value.columnname neq 'smcreatorid' && $value.uitype neq 64 && $value.uitype neq 65 && $value.uitype neq 69 && $value.uitype neq 1108 && $value.uitype neq 1109 && $value.uitype neq 4 && $value.uitype neq 1600 && $value.uitype neq 603 && $value.uitype neq 112 && $value.uitype neq 222 && $value.bigtype neq 'qrcode'}
				{*		ZXM 预算单 指标类型  不加默认值*}
				{*wym BUG0073272 收款计划选项目只显示当前当前源单关联的项目 编辑字段界面获取不到源单信息 所以隐藏默认值选项*}
				{*zkt 20231219 BUG0077419 财务管理--收款计划：开票计划字段，审批要求-其他设置，点击一直转圈圈无法设置*}
				{*wym 240110 BUG20240108-46 销售订单/服务合同-“数量合计”字段取得是分录的数量合计，不能设置默认值 应不显示设置默认值*}
				{if ($MODULE!='ExpenseBudget' && $value.fieldname!='budget_indicators'&& $value.bigtype!='signin'&& $value.bigtype neq 'relatedmodulefield' && !($MODULE=='PaymentPlan'&&$value.uitype==82) && $value.columnname!='totalquantity' )  }
					<tr>
						<td align="right" class="select-input">
							
							{* <input id="defaultvalue_check_{$value.fieldid}" class="inputBornone" onclick="cmb_defaultvalue_check(this,'{$value.fieldid}','{$value.columnname}');" type="checkbox"
							{if $defaultsetting.permitted eq false ||$value.uitype eq 202||($value.bigtype eq 'relatedmodulefield'&&$value.allowedit eq 'no')||$value.uitype eq 53}
								disabled 
							{/if}
							{if $defaultsetting.value neq ''}
								checked
							{/if}
							> *}
							<label for="defaultvalue_check_{$value.fieldid}" style="margin-top: 2px !important;display: block;float: right;">{'LBL_DEFAULTVALUE'|@getFixedLabel}</label>
						</td>
						<td align="left" style="overflow: inherit;">
							{assign var="fieldElementId" value='defaultvalue_'|cat:$value.fieldid:"_name"}
								{include file="Settings/FieldUI.tpl"
									_FIELD_UI_TYPE=$value.uitype
									_FIELD_SELECTED_VALUE=$defaultsetting.value
									_FIELD_COLUMNNAME = $value.columnname
									_FIELD_ELEMENT_ID=$fieldElementId
									_ALL_AVAILABLE_VALUES=$defaultsetting._allvalues
									_allvaluecolors=$defaultsetting._allvaluecolors
									_big_type=$value.bigtype
									_FIELD_ID=$value.fieldid
								}
								{if $value.bigtype eq 'reference'}
									<input type="hidden" id="defaultvalue_{$value.fieldid}" value="{$defaultsetting.defaultvalueid}" name="defaultvalue_{$value.fieldid}">
									<input type="hidden" id="referencemodule_{$value.fieldid}" value="{$UITYPEMODULES[$value.uitype]}" name="referencemodule_{$value.fieldid}">
									<a class="icon-homeimg icon-select"  href="javascript:;" style="float:inherit" title="{'SELECT'|@getFixedLabel}" onclick='setChooseDefaultvalue("{$MODULE}","{$value.fieldid}");'></a>
									<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_ChooseDefaultvalue('{$value.fieldid}');return false;"/>
								{/if}
								{if $value.bigtype eq 'multireference'}
									<input type="hidden" id="defaultvalue_{$value.fieldid}" value="{$defaultsetting.defaultvalueid}" name="defaultvalue_{$value.fieldid}">
									<input type="hidden" id="multireferencemodule_{$value.fieldid}" value="{$UITYPEMODULES[$value.uitype]}" name="multireferencemodule_{$value.fieldid}">
									<a class="icon-homeimg icon-select"  href="javascript:;" style="float:inherit" title="{'SELECT'|@getFixedLabel}" onclick='setChooseDefaultvalueMutiple("{$MODULE}","{$value.fieldid}");'></a>
									<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{'CLEAR'|@getFixedLabel}" onclick="clear_ChooseDefaultvalue('{$value.fieldid}');return false;"/>
								{/if}
						</td>
					</tr>
				{/if}
			{/if}
		{/if}
		{if $value.bigtype eq 'relatedmodulefield'}
			<tr style="height:30px;">
				<td width="60" align="right">
					<font color="red">*</font>{'RelatedModule'|@getFixedLabel}
				</td>
				<td align="left">
					{$value.relatemodulefield_relatemodule_label}
				</td>
			</tr>
			{*wym XUQIU1000290 页面设置，“引用字段”增加可自定义引用成员管理字段（苏宁）*}
			{if $value.relatemodule eq 'Users'}
				<tr style="height:30px;">
					<td width="60" align="right">
						<font color="red">*</font>{'SELECTUSER'|@getFixedLabel}
					</td>
					<td align="left">
						{$value.selectmemberfield}
					</td>
				</tr>
			{/if}
			<tr style="height:30px;">
				<td width="60" align="right">
					<font color="red">*</font>{'REFERENCEFIELD'|@getFixedLabel}
				</td>
				<td align="left">
					{$value.relatemodulefield_relatefield_label}
				</td>
			</tr>
		{/if}
		{*2024-06-05 xxy XUQIU20240603-02 页面设置/单据分录定制，字段类型增加“帮助信息”字段属性（朱俊）*}
		{if $value.bigtype neq 'signin'}
			<tr>
				<td align="right">
					<div class="ld-btn-icontext-item">
						<span>{'HelpInformation'|@getFixedLabel}</span>
						<i data-tip="{'HoverQuestionMarkDisplay'|@getFixedLabel}" class="ld-fonticon ld-fonticon-help2 tip-items-list"></i>
					</div>
				</td>
				<td align="left" style="overflow: inherit;">
					<textarea class="ld-textarea-inner gwidth90" id="helptips_{$value.fieldid}" name="helptips" style="margin: 5px 0px;height: 50px;resize: vertical !important;">{$value.helptips}</textarea>
				</td>
			</tr>
		{/if}
		{*zxm20211228 字段说明，即placeholder*}
		{*Text、textarea、longtextarea三个类型读取字段颜色*}
		{if $value.bigtype eq 'text'||$value.bigtype eq 'textarea'||$value.bigtype eq 'longtextarea'||$value.bigtype eq 'url'}
			<tr id="tr_fieldplaceholder_{$value.fieldid}">
				<td align="right">{'FieldDescription'|@getFixedLabel}</td>
				<td align="left" style="overflow: inherit;">
					<input type="text" id="fieldplaceholder_{$value.fieldid}" name="fieldplaceholder" class="ld-input-inner gwidth90" value="{$value.fieldplaceholder}"/>
				</td>
			</tr>
		{/if}
		{*wsh 标签颜色*}
		<tr id="tr_labelvaluecolor_{$value.fieldid}">
			<td align="right">{'LABELCOLOR'|@getFixedLabel}</td>
			<td align="left" style="overflow: inherit;">
				<div title="点击修改颜色" name="color_div" style="width: 21px;
						height: 21px;
						border-radius: 100%;
						cursor: pointer;
						border: 1px solid #dbdbdb;background: {$value.show_label_color};left:0;top:0;" onclick="chooseLabelColor(this,'{$value.fieldid}');">
				</div>
				<input type="hidden" id="labelvaluecolor_{$value.fieldid}" name="labelvaluecolor" class="ld-input-inner gwidth90" value="{$value.label_color}"/>
			</td>
		</tr>
		{*zxm20211228 字段颜色，默认显示系统字体颜色*}
        {if $value.bigtype eq 'text'||$value.bigtype eq 'textarea'||$value.bigtype eq 'longtextarea'||$value.bigtype eq 'number'||$value.bigtype eq 'currency'
		||$value.bigtype eq 'date'||$value.bigtype eq 'time'||$value.bigtype eq 'datetime'||$value.bigtype eq 'percent'||$value.bigtype eq 'phone'||$value.bigtype eq 'mobile'}
			<tr id="tr_fieldvaluecolor_{$value.fieldid}">
				<td align="right">{'FieldColor'|@getFixedLabel}</td>
				<td align="left" style="overflow: inherit;">
					<div title="点击修改颜色" name="color_div" style="width: 21px;
											height: 21px;
											border-radius: 100%;
											cursor: pointer;
											border: 1px solid #dbdbdb;background: {$value.fieldvaluecolor};left:0;top:0;" onclick="chooseFieldColor(this,'{$value.fieldid}');">
					</div>
					<input type="hidden" id="fieldvaluecolor_{$value.fieldid}" name="fieldvaluecolor" class="ld-input-inner gwidth90" value="{$value.fieldvaluecolor}"/>
				</td>
			</tr>
        {/if}
		{*ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）*}
		{if $value.uitype eq 1600 && $value.bigtype neq 'relatedmodulefield'}
			<tr style="height:30px;">
				<td width="60" align="right">
					<font color="red">*</font>{'SelectMemberField'|@getFixedLabel}
				</td>
				<td align="left">
					{$value.selectmemberfield}
				</td>
			</tr>
		{/if}
		{*zxm 2021-0408 二维码字段类型显示内容定制和选择二维码类型*}
		{if $value.bigtype eq 'qrcode'}
			<tr>
				<td width="145" align="right">{'qrcodetype'|@getFixedLabel}</td>
				<td align="left">
					<select onchange="qrcodeTypeChange(this,0)" class="ld-select-inner gwidth40" id="fdcodetype_{$value.fieldid}" name="fdcodetype_{$value.fieldid}">
						<option {if $value.uitype eq 1501}selected{/if} value="1501">{'linkcode'|@getFixedLabel}</option>
						<option {if $value.uitype eq 1500}selected{/if} value="1500">{'contentcode'|@getFixedLabel}</option>
						<option {if $value.uitype eq 1503}selected{/if} value="1503">{'FORMCODE'|@getFixedLabel}</option>
						<option {if $value.uitype eq 1502}selected{/if} value="1502">{'mobileDetailCode'|@getFixedLabel}</option>
					</select>
					<span {if $value.uitype neq 1502}style="display:none;"{/if}>({'useCrmScan'|@getFixedLabel})</span>
				</td>
			</tr>
			<tr {if $value.uitype eq 1502 ||$value.uitype eq 1503}style="display:none;"{/if} id="qrcodeTemplateEditTr">
				<td width="145" align="right" >
					{'Contentcustomization'|@getFixedLabel}
				</td>
				<td align="left">
					<a data-templateid="{$qrcodetemplateid}" id="qrcodeTemplateEdit" onclick="qrcodeTemplate.create({$value.fieldid},this,'{$MODULE}')">{'Setup'|@getFixedLabel}</a>
				</td>
			</tr>
			<tr {if $value.uitype neq 1503}style="display:none;"{/if} id="formqrcodeTemplateEditTr">
				<td width="145" align="right" >
					{'ACTIVITYFIELDSETTINGS'|@getFixedLabel}
				</td>
				<td align="left">
					<a data-templateid="{$qrcodetemplateid}" id="formqrcodeTemplateEdit" onclick="qrcodeTemplate.Formcreate({$value.fieldid},this,'{$MODULE}')">{'Setup'|@getFixedLabel}</a>
					<span style="margin-left:10px;">({'PERSONALCODESCAN'|@getFixedLabel})</span>
				</td>
			</tr>
		{/if}

		{*启用*}
		<tr>
			<td align="right">
				<label for="presence_check_{$value.fieldid}">{'ACTIVATE'|@getFixedLabel}</label>	
			</td>
			<td align="left" >
			 <!--16663-->
				<input id="presence_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" allowhide="{$value.allowhide}"
				{if $value.allowhide eq 'no'}
					checked  disabled 
				{else}
					{if $value.displaytype eq '2'}
						checked 
					{else}
						{if $value.presence eq '0' || $value.mandatory eq '0'  || $value.mandatory eq '2'} 
							checked    
						{/if}
						{if $value.presence eq '2'} 
							checked
						{/if}
						{if $value.presence eq '3'}
							
						{/if}
					{/if}
					
				{/if}
				>
			</td>
		</tr>
		{*必填字段*}
        {if $value.uitype neq 222}
			<tr>
				<td align="right">
					<label for="mandatory_check_{$value.fieldid}">{'MANDATORYFIELDS'|@getFixedLabel}</label>
				</td>
				<td align="left" >
					<input id="mandatory_check_{$value.fieldid}" class="second_switch inputBornone"  type="checkbox"
					{if ($value.fieldtype neq 'M' && $value.mandatory eq '0') ||($value.bigtype eq 'relatedmodulefield'&&$value.allowedit eq 'no')}
				        disabled
					{elseif (($value.mandatory eq '0' || $value.mandatory eq '4') && $value.fieldtype eq 'M')} 
						checked  disabled 
					{elseif $value.mandatory eq '3'||   $value.uitype eq '56' || $value.uitype eq 1600}
					  disabled
					{elseif $value.mandatory eq '2'}
						checked
					{elseif $value.uitype eq 200 || $value.uitype eq 201}
					
					{/if}
                    
					{*<!--edit:kevin date:2013-10-15 reason:5291 
                    36492: （1.6）客户模块页面设置>联系人手机字段：勾选上必填字段后不会勾选快速创建
					 onclick = "{if $value.presence neq '0'} enableDisableCheckBox(this,presence_check_{$value.fieldid}); {/if}-->*}
					onclick=" enableDisableCheckBox(this,quickcreate_check_{$value.fieldid},{$value.uitype});
					 {if $value.presence neq '0'} enableDisableCheckBox(this,presence_check_{$value.fieldid},{$value.uitype}); {/if}">
				</td>
			</tr>
		{/if}
		
        {if $value.bigtype|@strtolower eq 'relatedmodulefield' || ($value.input_type eq 'formula' && $value.functiontype neq '')}
         	<tr>
			 	<td align="right">{'Savetodatabase'|@getFixedLabel}</td>
         		<td align="left">
         			<input type="checkbox" disabled class="second_switch" value="" {if $value.savedatabase eq 'yes'} checked=""{/if} />
		        </td>
	       	</tr>
         {/if}
		{*路总让放开选项“允许编辑”*}
		<tr {if $value.savedatabase eq 'yes'} {else} style="display:none"{/if} >
			<td align="right"><label for="allowdit_{$value.fieldid}">{'ALLOWEDITING'|@getFixedLabel}</label></td>
			<td align="left">
				<input type="checkbox" class="second_switch" id="allowdit_{$value.fieldid}" onclick="fieldAllowEditClick(ld(this),'{$value.fieldid}')" value="" {if $value.allowedit eq 'yes'} checked=""{/if} {if $value.relatemodule eq 'Users'} disabled{/if} />
			</td>
		</tr>
        {* edit: xll 2023/05/06 XUQIU1001203 关联选择单据（单选）、引用字段增加“显示超链接”字段属性 *}
        {if $isHrefField eq 'yes'}
			<tr>
				<td width="145" align="right">
                    <label for="ShowHyperlinks_{$value.fieldid}">
                    {'SHOWHYPERLINKS'|@getFixedLabel}
                    </label>
				</td>
				<td align="left" >
                    <input id="ShowHyperlinks_{$value.fieldid}" class="inputBornone second_switch" type="checkbox" 
                    {if $value.ShowHyperlinks eq 'yes'}
                        checked
                    {else}
                        
                    {/if}
                    />
				</td>
			</tr>
		{/if}
		{* edit: hzx 是否小计 *}
		{if $value.bigtype eq 'number' || $value.bigtype eq 'currency'}
			<tr>
				<td width="145" align="right" >
					<label for="subtotalattr_{$value.fieldid}">
						{'CalculateSubtotal'|@getFixedLabel}
					</label>
				</td>
				<td align="left" >
					<input id="subtotalattr_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
							{if $value.subtotal_attr eq 'yes'}
								checked
							{else}

							{/if}
					/>
				</td>
			</tr>
		{/if}
		{if $value.uitype neq 222 && $value.bigtype neq 'selectsource' && $value.uitype neq 112}
			{*		ZXM 预算单 指标类型  不加批量编辑*}
			{if $MODULE!='ExpenseBudget' && $value.fieldname!='budget_indicators' && $value.bigtype!='signin'
				&& $value.uitype neq 1109 && $value.uitype neq 1108 && $value.uitype neq 69}
				<tr>
					<td align="right">
						<label for="fieldonly_check_{$value.fieldid}">{'Allowed_to_repeat'|@getFixedLabel}</label>
					</td>
					<td align="left" >
						<input id="fieldonly_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" onclick="fieldonlyCheck(this,massedit_check_{$value.fieldid})"
						
								
								{if $value.fieldonly eq '1'&&$value.bigtype neq 'boolean'} 
									checked
								{/if}
								{if $value.uitype eq '4'||$value.uitype eq '106'||$value.uitype eq '117'|| $value.uitype eq '69'||$value.bigtype eq 'boolean'||$value.fieldname eq 'paymenttype' ||($value.bigtype eq 'relatedmodulefield'&&$value.allowedit eq 'no')}
									disabled
								{/if}
						
							{if ($value.displaytype eq '2' ||$value.uitype eq 53 ||$value.uitype eq 99 || $value.mandatory eq 4 || $value.uitype eq 1600)}
								disabled
							{/if}
						>
					</td>
				</tr>
			{/if}
			{*// ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）*}
			{if  $value.displaytype neq 2 && $value.displaytype neq 3 && $value.bigtype neq 'moduleno' && $value.relatedmodulefield neq 'yes' && $value.bigtype neq 'memberdepartment'}
				<tr>
					<td align="right">
						<label for="disallowed_copy_check_{$value.fieldid}">{'ContentNotAllowCopying'|@getFixedLabel}</label>
					</td>
					<td align="left" >
						<input id="disallowed_copy_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
								{if $value.disallowed_copy eq 'yes'}checked{/if}  {if $value.disabled_copy eq 'yes'}disabled{/if} >
					</td>
				</tr>
			{/if}

			{*// ljj 20240423 XUQIU20240408-04 附件增加“上传Word文件添加水印”和“上传Excel文件添加水印”字段属性（王庆）*}
			{if ($value.uitype eq 1109 || $value.uitype eq 1108 || $value.uitype eq 28) && $value.bigtype neq 'relatedmodulefield'}
				<tr name="tr_word_watermark_{$value.fieldid}">
					<td align="right">
						<label for="word_watermark_check_{$value.fieldid}">{'WORDWATERMARK'|@getFixedLabel}</label>
					</td>
					<td align="left" >
						<input id="word_watermark_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" onchange="showWatermarkSetting(this,'word')"
							   {if $value.word_watermark eq 'yes'}checked{/if}>
						<a href="javascript:;" id="word_watermark_setting_{$value.fieldid}" name="word_watermark_setting" onclick="setWatermark(this,'word')" module="{$MODULE}" fieldid="{$value.fieldid}" fieldname="{$value.fieldname}" settingid="{$value.word_watermark_settingid}"
						   style="padding-left: 10px;{if $value.word_watermark neq 'yes'}display: none;{/if}">{'SETWATERMARK'|@getFixedLabel}</a>
					</td>
				</tr>
				<tr name="tr_excel_watermark_{$value.fieldid}">
					<td align="right">
						<label for="excel_watermark_check_{$value.fieldid}">{'EXCELWATERMARK'|@getFixedLabel}</label>
					</td>
					<td align="left" >
						<input id="excel_watermark_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" onchange="showWatermarkSetting(this,'excel')"
							   {if $value.excel_watermark eq 'yes'}checked{/if}>
						<a href="javascript:;" id="excel_watermark_setting_{$value.fieldid}" name="excel_watermark_setting" onclick="setWatermark(this,'excel')" module="{$MODULE}" fieldid="{$value.fieldid}" fieldname="{$value.fieldname}" settingid="{$value.excel_watermark_settingid}"
						   style="padding-left: 10px;{if $value.excel_watermark neq 'yes'}display: none;{/if}">{'SETWATERMARK'|@getFixedLabel}</a>
					</td>
				</tr>
			{/if}

			{if $value.quickcreate neq '3' && $MODULE neq 'Users'}
				{*@edit:liushuai,2020-12-28,reason: 页面设置，字段属性界面去掉【快速创建】一行【style="display: none;"】*}
				<tr style="display: none;">
					<td align="right">{'Quickly_create'|@getFixedLabel}</td>
					<td align="left" >
						<input id="quickcreate_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" 
						
						{if $value.quickcreate eq '0' && ($value.mandatory eq '0' || $value.mandatory eq '2')} 
							checked  {if $value.uitype neq '53' && $value.uitype neq '2' && $value.uitype neq '4'&& $value.fieldname neq 'paymenttype'}disabled{/if}
						{/if}
						{if $value.quickcreate eq '1' && ($value.mandatory eq '0' || $value.mandatory eq '2')} 
							{if $value.uitype neq '53' && $value.uitype neq '2' && $value.uitype neq '4'}disabled{/if}   
						{/if}
						{if $value.displaytype eq '2' || $value.uitype eq '83'}
							disabled
						{/if}
						{if $value.quickcreate eq '0'}
							checked
						{/if}
					
							>
					</td>
				</tr>
			{/if}
			<!--end-->
			{*ZXM 预算单 指标类型  不加批量编辑*}
			{*wym BUG0072002 附件管理 没有批量编辑*}
			{if ($MODULE!='Attachment' && $MODULE!='ExpenseBudget' && $value.fieldname!='budget_indicators'&& $value.bigtype!='signin' )}
				<tr>
					<td align="right">
						<label for="massedit_check_{$value.fieldid}">{'MASSEDIT'|@getFixedLabel}</label>
					</td>
					<td align="left">
						<input id="massedit_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" 
						{if $value.uitype eq '53' ||$value.uitype eq 112 || $value.uitype eq 603 || $value.uitype eq 34
						|| $value.uitype  eq '1101' || $value.uitype  eq '1109' || $value.uitype eq 1600
						||($value.bigtype eq 'relatedmodulefield'&&$value.allowedit eq 'no')
						||($value.columnname eq 'cashtype'&&$value.module eq 'CashBill')
						||($value.columnname eq 'status'&&$value.module eq 'Leads')}
							disabled
						{else}
							{if $value.masseditable eq '0'}
								disabled  orignaldisabled=true
							{/if}
							{if $value.fieldonly eq '1'|| $value.uitype eq 69}
								disabled  orignaldisabled=true
							{elseif $value.masseditable eq '1'} 
								checked orignaldisabled=false
							{/if}
							
							{if $value.displaytype neq '1' || $value.masseditable eq '3'}
								disabled  orignaldisabled=true
							{else}
								orignaldisabled=false
							{/if}
						{/if}
							onclick="fieldonlyCheck(this,fieldonly_check_{$value.fieldid})"
						>
						
					</td>
				</tr>
			{/if}
			{* xxy 2023-11-15 XUQIU1001176 页面设置/单据分录定制，增加“内容过多自动换行”字段属性 *}
			{if $value.bigtype neq 'signin' && $value.bigtype neq 'qrcode' && $value.bigtype neq 'picture' && $value.bigtype neq 'fileattachment'}
				<tr>
					<td align="right">
						<label for="auto_wordwrap_check_{$value.fieldid}">{'AutoWordWrap'|@getFixedLabel}</label>
					</td>
					<td align="left" >
						<input id="auto_wordwrap_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
								{if $value.auto_wordwrap eq 'yes'}checked{/if}>
					</td>
				</tr>
			{/if}
            <tr {if $value.bigtype neq 'mobile'} style="display:none"{/if}>
				<td align="right">{'EnableRegExp'|@getFixedLabel}</td>
				<td align="left">
					<input id="regexp_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" {if $value.regexp eq '1'} checked {/if}>
				</td>
			</tr>
			{if $value.uitype eq 1108 || $value.uitype eq 1109 || $value.uitype eq 69}
				<td align="right">{'takephotopnly'|@getFixedLabel}</td>
				<td align="left">
					<input id="take_photo_only_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" 
						{if $value.take_photo_only eq '1'}
							checked 
						{/if}
					>
					
				</td>
			{/if}


			{*@edit:liushuai,2021-06-04,reason:【ID1001652】页面设置，“附件”和“图片”字段增加字段属性，控制签到水印是否显示（第二版）*}
            {if $isKehu001 neq 'yes' && $isOpenSignIn eq 'yes' && $value.bigtype eq 'fileattachment' && $SINGINWATERMARK neq 'no'}
				<tr>
					<td align="right">{'MobileUploadWatermark'|@getFixedLabel}</td>
					<td align="left">
						<input id="uploadwatermark_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
								{if $value.uploadwatermark eq 'yes'} checked {/if}>

					</td>
				</tr>
			{/if}
			{if $value.bigtype=='signin'}
				<tr>
					<td align="right">{'AUTOMATICCHECKIN'|@getFixedLabel}</td>
					<td align="left">
						<input id="auto_signin_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
								{if $value.auto_signin eq 'yes'}checked{/if} >
					</td>
				</tr>
				{if $MODULE neq 'Singin' && $MODULE neq 'Signout'}
					<tr >
						<td align="right"><label for="editview_signin_{$value.fieldid}">{'EDITVIEWSIGNIN'|@getFixedLabel}</label></td>
						<td align="left">
							<input type="checkbox" id="editview_signin_{$value.fieldid}" name="editview_signin_{$value.fieldid}"
								   {if $value.editview_signin eq 'yes'}checked{/if} 
								   class="second_switch" value="{$value.fieldid}" 
								   onclick="enableDisableCheckBox_ressing(this,editview_resignin_{$value.fieldid})"/>
						</td>
					</tr>
					<tr >
						<td align="right"><label for="editview_resignin_{$value.fieldid}">{'EDITVIEWRESIGNIN'|@getFixedLabel}</label></td>
						<td align="left">
							<input type="checkbox" id="editview_resignin_{$value.fieldid}" name="editview_resignin_{$value.fieldid}"
								   {if $value.editview_resignin eq 'yes'  }checked{/if} 
								   class="second_switch" value=""/>
						</td>
					</tr>
					<tr >
						<td align="right">
							{'Ifitexceedstheerrorrange'|@getFixedLabel}
						</td>
						<td align="left">
							<input id="no_signin_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
									{if $value.no_signin eq 'yes'}checked{/if} >
							<select class="btn-radius-system marL10" name="allowable_distance_{$value.fieldid}" id="allowable_distance_{$value.fieldid}" style="width: 70px;" onchange="allowable_distance_click(this,{$value.fieldid})">
								<option value="100" {if $value.allowable_distance eq 100}selected{/if}>100{'metre'|@getFixedLabel}</option>
								<option value="200" {if $value.allowable_distance eq 200 || $value.no_signin eq 'no'}selected{/if}>200{'metre'|@getFixedLabel}</option>
								<option value="300" {if $value.allowable_distance eq 300}selected{/if}>300{'metre'|@getFixedLabel}</option>
								<option value="500" {if $value.allowable_distance eq 500}selected{/if}>500{'metre'|@getFixedLabel}</option>
								<option value="800" {if $value.allowable_distance eq 800}selected{/if}>800{'metre'|@getFixedLabel}</option>
								<option value="1000" {if $value.allowable_distance eq 1000}selected{/if}>1000{'metre'|@getFixedLabel}</option>
								<option value="2000" {if $value.allowable_distance eq 2000}selected{/if}>2000{'metre'|@getFixedLabel}</option>
								<option value="3000" {if $value.allowable_distance eq 3000}selected{/if}>3000{'metre'|@getFixedLabel}</option>
								<option value="5000" {if $value.allowable_distance eq 5000}selected{/if}>5000{'metre'|@getFixedLabel}</option>
								<option value="custom" {if $value.no_signin eq 'yes' && $value.allowable_distance neq '100' && $value.allowable_distance neq '200' && $value.allowable_distance neq '300' && $value.allowable_distance neq '500' && $value.allowable_distance neq '800' && $value.allowable_distance neq '1000' && $value.allowable_distance neq '2000' && $value.allowable_distance neq '3000' && $value.allowable_distance neq '5000'}selected{/if}>{'custom'|@getFixedLabel}</option>
							</select>
	
							<input {if $value.no_signin eq 'yes' && $value.allowable_distance neq '100' && $value.allowable_distance neq '200' && $value.allowable_distance neq '300' && $value.allowable_distance neq '500' && $value.allowable_distance neq '800' && $value.allowable_distance neq '1000' && $value.allowable_distance neq '2000' && $value.allowable_distance neq '3000' && $value.allowable_distance neq '5000'} style="width: 50px;height: 30px;"{else}style="width: 50px;display:none;height: 30px;"{/if} type="text" name="custom_allowable_distance_{$value.fieldid}" id="custom_allowable_distance_{$value.fieldid}" value="{$value.allowable_distance}" class="ld-input-inner">
						</td>
					</tr>
				{/if}
			{/if}
		{else}
			{*xxy 2023-12-11 BUG0077053 页面设置->选择源单字段，缺少“内容过多自动换行”字段属性*}
			{if $value.uitype neq 222}
				<tr>
					<td align="right">
						<label for="auto_wordwrap_check_{$value.fieldid}">{'AutoWordWrap'|@getFixedLabel}</label>
					</td>
					<td align="left" >
						<input id="auto_wordwrap_check_{$value.fieldid}" class="second_switch inputBornone" type="checkbox"
								{if $value.auto_wordwrap eq 'yes'}checked{/if}>
					</td>
				</tr>
			{/if}
		{/if}
		{if $value.uitype eq 222}
			<tr>
				<td align="right">{'allowrewriting'|@getFixedLabel}</td>
				<td align="left" >
					<input id="fldallow_rewriting_{$value.fieldid}" class="second_switch inputBornone" type="checkbox" onclick="fieldonlyCheck(this,massedit_check_{$value.fieldid})" {if $value.fldallow_rewriting eq '1'} checked {/if} >
				</td>
			</tr>
		{/if}
		{if  $value.bigtype eq 'fileattachment'}
			<tr >
				<td align="right"><label for="FileAllowed_{$value.fieldid}">{'FileAllowed'|@getFixedLabel}</label></td>
				<td align="left">
					<input type="checkbox" id="FileAllowed_{$value.fieldid}" name="FileAllowed_{$value.fieldid}" class="second_switch"
							{if $value.DownloadAllowed eq 'yes' or $value.PreviewAllowed eq 'yes'} checked {/if}
						   onchange="ld(this).siblings('a').css('display',ld(this).prop('checked') ? '' : 'none')"/>
					<a href="javascript:;" onclick="SetConditions('DownloadAllowed','{$MODULE}');"
						{if $value.DownloadAllowed neq 'yes' and $value.PreviewAllowed neq 'yes'} style="display: none" {/if} >{'SetConditions'|@getFixedLabel}</a>
				</td>
			</tr>
			<!--
			<tr >
				<td align="right"><label for="PreviewAllowed_{$value.fieldid}">{'PreviewAllowed'|@getFixedLabel}</label></td>
				<td align="left">
					<input type="checkbox" id="PreviewAllowed_{$value.fieldid}" name="PreviewAllowed_{$value.fieldid}" class="second_switch"
							{if $value.PreviewAllowed eq 'yes'} checked {/if} />
					<a href="javascript:;"  onclick="SetConditions('PreviewAllowed','{$MODULE}');">{'SetConditions'|@getFixedLabel}</a>
				</td>
			</tr>
			-->
		{/if}
	</table>
	{*	// ljj 2023-08-23 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）*}
	{if $value.bigtype eq 'fileattachment'}
		<div class="greyFont9 font12" style="padding:10px 10px 20px 10px">
			<span style="color:red">*</span>{'MobileContentCanNotCopy'|@getFixedLabel}
		</div>
	{/if}
    {if $value.bigtype eq 'selectsource'}{* $MODULE eq 'CashBill'||$MODULE eq 'SendCashBill'|| *}
      	<div class="editrelhead" >
    			<b style="display: inline-block; ">{'LBL_Optionalmodule_Customization'|@getFixedLabel}</b>
                {* zkt 20230817 BUG0069236  kfbcrm-收款计划-选择源单字段应控制不能新增（邱：是否要确定增加需求） *}
                <input  type="button"  class="createauto" onclick="NewSourceModulePopup('{{$MODULE}}')" style="{if $MODULE eq 'WorkSheet' || $MODULE eq 'PaymentPlan'}display:none;{/if}float:right;margin-top:8px;margin-right:10px" value="{'NEW'|@getFixedLabel}"/>

       	</div>
      	<div name='sourcelist' style="max-height: 300px;overflow: auto;">
        	{include file="Settings/SelectSourceList.tpl"}
       	</div>
    {/if}
    {* edit: xll XUQIU1001203 评论、附件管理、提醒模块相关对象改为选择源单样式*}
    {if $value.uitype eq '112'}
       <div name='sourcelist' style="max-height: 300px;overflow: auto;">
        {include file="Settings/SelectSourceList.tpl"}
       </div>
    {/if}
	</div>

	<!--高级属性-->
	<div id="advanceDiv_{$value.fieldid}" style="display:none;">
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td class="ld-form-item-label">
					{'INPUTMODE'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select class="ld-select-inner gwidth50" name="inputModeType_{$value.fieldid}" id="inputModeType_{$value.fieldid}" onchange="PageSetup.selectInputMode(this,{$value.fieldid})"
							{if $value.bigtype|@strtolower eq 'relatedmodulefield'}disabled{/if} {*引用字段不显示高级属性不可编辑*}
							{*{if $value.fieldid > 0 }disabled{/if}*}>{*编辑字段是否允许更改录入方式*}
						<option value="0"{if $value.input_type eq ''}selected="true"{/if} >{'MANUALINPUT'|@getFixedLabel}</option>
						{if $isShowAdvanced eq 'yes'}
							{if $isEntryModule eq 'yes'}
								<option value="1" {if $value.input_type eq 'formula' && $value.functiontype neq 'sql' && $value.functiontype neq ''}selected="true"{/if}>{'EntryFunction'|@getFixedLabel}</option>
							{/if}
							<option value="2"{if $value.input_type eq 'formula' && $value.functiontype eq ''}selected="true"{/if} >{'USINGTHEFORMULA'|@getFixedLabel}</option>
						{/if}
						<option value="3"{if $value.input_type eq 'formula' && $value.functiontype eq 'sql'}selected="true"{/if} >{'QUERYBYSQL'|@getFixedLabel}</option>
					</select>
				</td>
			</tr>
			{*函数功能*}
			<tr id='functionDiv_{$value.fieldid}' {if $value.input_type eq 'formula' && $value.functiontype neq '' && $value.functiontype neq 'sql'}style='display:;'{else}style='display:none;'{/if}>
				<td class="ld-form-item-label">
					{'TheFunctionality'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select name="functionType_{$value.fieldid}" id="functionType_{$value.fieldid}" class="ld-select-inner gwidth50" onchange="PageSetup.selectFunction(this,{$value.fieldid})">
						{foreach key=functiontype item=functionlabel from=$EntryFunction}
							<option value="{$functiontype}" {if $value.functiontype eq $functiontype}selected{/if}>{$functionlabel}</option>
						{/foreach}
					</select>
				</td>
			</tr>
			{*函数功能-参数字段（分录字段）*}
			<tr id='attributeDiv_{$value.fieldid}' {if $value.input_type eq 'formula' && $value.functiontype neq '' && $value.functiontype neq 'sql'}style='display:;'{else}style='display:none;'{/if}>
				<td class="ld-form-item-label">
					{'ParameterField'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content">
					<select name="attributeField_{$value.fieldid}" id="attributeField_{$value.fieldid}" class="ld-select-inner gwidth50" onchange="PageSetup.selectFunctionField(this,{$value.fieldid})">
						{foreach key=functype item=fieldarr from=$EntryFuncfieldarr}
							{foreach key=columnname item=fieldlabel from=$fieldarr}
								<option value="{$columnname}" functype="{$functype}"
										{if $value.functioncolumn eq $columnname}selected{/if}
								>{$fieldlabel}
								</option>
							{/foreach}
						{/foreach}
					</select>
				</td>
			</tr>
			{*定义变量*}
			<tr id='definingDiv_{$value.fieldid}' {if $value.input_type eq 'formula' && ($value.functiontype eq '' || $value.functiontype eq 'sql') }style='display:;'{else}style='display:none;'{/if}>
				<td class="padT16 padB16" colspan='2'>
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'DEFININGVARUABLE'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr id='definingContentDiv_{$value.fieldid}' {if $value.input_type eq 'formula' && ($value.functiontype eq '' || $value.functiontype eq 'sql') }style='display:;'{else}style='display:none;'{/if}>
				<td align="left" colspan='2'>
					<div id="productDiv" style="max-height:150px;overflow-x: auto;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" id="toolfieldFormula_{$value.fieldid}" class="toolfield formual_td">
							{$FORMULAHTML}
							<tr>
								<td colspan="3">
									<a href="javascript:;" title="{'NewVar'|@getFixedLabel}" onclick="PageSetup.addFormulaTableTr(1,{$value.fieldid})">{'NewVar'|@getFixedLabel}</a>
								</td>
							</tr>
						</table>
					</div>
				</td>
			</tr>
			{*定义公式*}
			<tr id='mulaDiv_{$value.fieldid}' {if $value.input_type eq 'formula' && $value.functiontype eq ''}style='display:;'{else}style='display:none;'{/if}>
				<td class="padT16 padB16" colspan='2'>
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'DEFINITIONFORMULA'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr id='mulaContentDiv_{$value.fieldid}'{if $value.input_type eq 'formula' && $value.functiontype eq ''}style='display:;'{else}style='display:none;'{/if}>
				<td align="left" colspan='2'>
					<input type="text" id="definitionformula_{$value.fieldid}" name="definitionformula_{$value.fieldid}" value="{if $value.functiontype eq ''}{$value.formulastring}{/if}" class="ld-input-inner" /><br />
					<span style="line-height:45px;height:45px;display:block;">1.{'AllNumericAndCurrencyFieldsCanCalculate'|@getFixedLabel}</span>
					<span style="margin-bottom:20px;display:block;">2.{'CANHAVEATMOST10VARIABLES'|@getFixedLabel}</span>
				</td>
			</tr>
			{*SQL查询*}
			<tr id='sqlDiv_{$value.fieldid}' {if $value.input_type eq 'formula' && $value.functiontype eq 'sql'}style='display:;'{else}style='display:none;'{/if}>
				<td class="padT16 padB16" colspan='2'>
					<div class="ld-pop-contnet-title-items">
						<div class="ld-pop-contnet-title-item">{'SQLQUERY'|@getFixedLabel}</div>
					</div>
				</td>
			</tr>
			<tr id='sqlContentDiv_{$value.fieldid}'{if $value.input_type eq 'formula' && $value.functiontype eq 'sql'}style='display:;'{else}style='display:none;'{/if}>
				<td align="left" colspan='2'>
					<textarea contenteditable="true" id="definitionsqlformula_{$value.fieldid}" name="definitionsqlformula_{$value.fieldid}" class="ld-textarea-inner">{if $value.functiontype eq 'sql'}{$value.formulastring}{/if}</textarea><br />
					{if $value.bigtype eq 'selectoneuser'}
						<span style="line-height:45px;height:45px;display:block">1.{'SQLFormulaTips1_1'|@getFixedLabel}</span>
					{else}
						<span style="line-height:45px;height:45px;display:block">1.{'SQLFormulaTips1'|@getFixedLabel}</span>
					{/if}
					<span style="display:block;">2.{'SQLFormulaTips2'|@getFixedLabel}</span>
				</td>
			</tr>
		</table>
	</div>
	{*字段敏感规则,文本、文本区域、数字、电话、手机、QQ、Email、货币字段*}
	<div id="SensitiveRules_{$value.fieldid}" style="display:none;min-height: 300px;">
		<table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" style="width: 100%;">
			<tr>
				<td class="ld-form-item-label">
					{'ACTIVATE'|@getFixedLabel}{'SensitiveRules'|@getFixedLabel}
				</td>
				<td class="ld-form-item-content" style="overflow: inherit;">
					<input name="sensitivepresence" {if $sensitivepresence eq 'yes'}checked="" {/if} type="checkbox" class="second_switch lfloat">
					<div class="create-entity-toolbar rfloat prelative">
						<a href="javascript:;" onclick="SensitiveRules.getInstance().create({$value.fieldid},0,'create','{$MODULE}')" class="ld-button ld-button-primary" title="{'ADDLESSIONPLAN'|@getFixedLabel}{'LBL_PROFILES'|@getFixedLabel}">{'ADDLESSIONPLAN'|@getFixedLabel}{'RULE'|@getFixedLabel}</a>
					</div>
				</td>
			</tr>
		</table>
		<div class="SensitiveDiv">
			{include file="Settings/SensitiveRulesList.tpl"
				FIELDID=$value.fieldid
				MODULE=$MODULE
				LANGUAGETYPE=$LANGUAGETYPE
			}
		</div>
	</div>
	{* <div class="E_pbtn" style="width: 100%;"> *}
		{*saveFieldInfo方法调用LayoutBlockListNew.tpl*}
		{* <input type="button" name="save" class="E_pbtnok ld-button ld-button-primary" value="{'SAVE'|@getFixedLabel}" onclick="saveFieldInfo('{$value.fieldid}','{$MODULE}','updateFieldProperties','{$value.typeofdata}','{$value.uitype}');"/><span>&nbsp;</span>
		{if $value.allowdelete eq 'yes'}
			<input type="button" name="delete" value="{'DELETE'|@getFixedLabel}" class="E_pbtncancel ld-button ld-button-cancel" onclick="deleteCustomField('{$value.fieldid}','{$MODULE}','{$value.columnname}','{$value.uitype}')" /><span>&nbsp;</span>
		{/if}
		<input type="button" name="cancel" class="E_pbtncancel ld-button ld-button-cancel" value="{'CANCEL'|@getFixedLabel}" onclick="CrmPopup.getPopupObj('last').CancelEvent()"/>  
	</div> *}
</div>
<script>
	var popupobj = CrmPopup.getPopupObj('last');
{literal}
	tooltip(ld("#"+popupobj.divid).find('.tip-items-list'), {transition: true, time: 200});
{/literal}
</script>