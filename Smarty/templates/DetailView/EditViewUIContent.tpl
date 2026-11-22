{* END *}
		{* vtlib customization *}
        {*//uitype10uitype*}
		{if ($allowedit eq 'no' )||$allowprofileeditfield eq 'no'}
			{*wsh 标签颜色*}
			<td class="ld-form-item-label" style="{$label_style}">
                {if $uitype eq 102 ||$uitype eq 112}
					<font color="red">{$mandatory_field}</font>{$fldlabel.displaylabel}
				{else}
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
				{/if}
				{include file='Helptips.tpl'}
			</td>
            {if $uitype eq 230 || $uitype eq 231||$uitype eq '19' ||$uitype eq '20'}
			    <td class="ld-form-item-content" colspan="3">
            {else}
                <td class="ld-form-item-content">
            {/if}
				{if $uitype eq 5}
					{foreach key=date_value item=time_value from=$fldvalue}
						{assign var=date_val value="$date_value"}
						{assign var=time_val value="$time_value"}
					{/foreach}
					<input name="{$fldname}" type="hidden" value="{$date_value}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$date_value}</span>
                {elseif $uitype eq 33}
                    <input name="{$fldname}" type="hidden" value="{$value_name}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$value_name_show}</span>
				{elseif $uitype eq 34}
					<input name="{$fldname}" type="hidden" value="{$value_name}"/>
					<input type="hidden" from_fieldname="groupid" id="jsonvalue_{$fldname}" name="jsonvalue_{$fldname}" value="{$thirdvalue}">
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$value_name_show}</span>
                {elseif $uitype eq 15||$uitype eq 115}
                	<input name="{$fldname}" type="hidden" value="{if $uitype eq 115}{$thirdvalue}{else}{$value_name}{/if}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$value_name}</span>
				{elseif $uitype eq 56||$uitype eq 156}
					<input name="{$fldname}" type="hidden" value="{$fldvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$value_name}</span>
				{elseif $uitype eq 81 || $uitype eq 75 || $uitype eq 173 || $uitype eq 73 || $uitype eq 57 || $uitype eq 59 || $uitype eq 76 || $uitype eq 78}
					<input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                {elseif $uitype eq 82}
                    <input id="{$fldname}" name="{$fldname}" type="hidden" value="{$fldvalue.entityid}" id="{$fldname}">
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue.displayvalue}</span>
				{elseif $uitype eq 153 || $uitype eq 53}
					{assign var=selectvalue value="no"}
					{foreach key=key_one item=arr from=$fldvalue}
						{foreach key=sel_value item=value from=$arr}
							 {if $value eq 'selected'}
								<input name="{$fldname}" type="hidden" value="{$key_one}"/>
								<span name="span_{$fldname}" class="ld-text-inner">{$sel_value}</span>
								{assign var=selectvalue value="yes"}
							 {/if}
						{/foreach}
					{/foreach}
					{if $selectvalue eq 'no'}
						<input name="{$fldname}" type="hidden" value=""/>
						<span name="span_{$fldname}" class="ld-text-inner"></span>
					{/if}
				{elseif $uitype eq 202}
					<input type="hidden" id="selectsource" name="selectsource" value="{$SELECTSOURCENAME}" />
					<input type="hidden" id="selectsourcename" name="selectsourcename" value="{$SELECTSOURCENAME}" />
					<input type="hidden" id="listvalall" name="listvalall" value="{$LISTVAL}" />
					<input type="hidden" id="listvalallname" name="listvalallname" value="{$LISTVAL_PURCHASEORDER_NO}" />
					{if $MODULE eq 'Expense' || $MODULE eq 'Project' ||  $MODULE eq 'PaymentPlan' ||  $MODULE eq 'SendPayment'}
						<span name="span_salesorder_name" class="ld-text-inner">{$LISTVAL}</span>
						<input type="hidden" id="entitytypeid" name="entitytypeid" value="{$ENTITYTYPEID}" />
					{elseif $MODULE eq 'OutboundOrder'}
                    	<!--edit:can 50161: （http://81.68.122.46:85/crm [^]）（哈维森(苏州)环境科技有限公司 ）出库单设置了审批后允许编辑个别字段，但是在编辑的时候提示选择源单不能为空，该字段是有数据的。错误截图-->
						<input type="hidden" name="selectlistval" id="selectlistval" value="{$secondvalue}" />
						<span name="span_salesorder_id" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                    {else if !empty($secondvalue) && !empty($fldvalue)}
                        {*edit:duan 2022-6-13 审批结束后编辑单据时，选择源单字段不可编辑时值为空，导致保存后源单丢失 *}
                        <input type="hidden" name="selectlistval" id="selectlistval" value="{$secondvalue}" />
						<span name="span_salesorder_id" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                    {else}
                        <input type="hidden" name="selectlistval" id="selectlistval" value="{$FROMID}" />
						<span name="span_salesorder_id" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$LISTVAL_PURCHASEORDER_NO}</span>
					{/if}
				{elseif $uitype eq 208}
					<input type="hidden" id="selectsource" name="selectsource" value="{$SELECTSOURCENAME}" />
					<input type="hidden" id="selectsourcename" name="selectsourcename" value="{$SELECTSOURCENAME}" />
					<input type="hidden" id="selectlistval_label" name="selectlistval_label" value="{$LISTVAL_PURCHASEORDER_NO}" />
					{if !empty($secondvalue)}
					<input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					{else}
					<input name="{$fldname}" type="hidden" value="{$LISTVAL_RECORD}"/>
					{/if}
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$LISTVAL_PURCHASEORDER_NO}</span>
                {else if $uitype eq 251 ||$uitype eq 252}
					{assign var=selected_type value=""}
					{foreach item=arr from=$fldvalue}
						{if $arr[2]=='selected'}
							{assign var=selected_type value="selected"}
							<span name="span_{$fldname}">{$arr[1]}</span>
							<input  type="hidden" value="{$arr[0]}" name="{$fldname}"/>
						{/if}
					{/foreach}
					{if $selected_type eq ''}
						<input name="{$fldname}" type="hidden" value="{$value_name}"/>
						<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$value_name}</span>
					{/if}
				{elseif $uitype eq 80}
					{if $MODULE eq 'OutboundOrder' && $SALESORDERID > 0}
						<span name="span_salesorder_name" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$SALESORDERNAME}</span>
						<input name="{$fldname}" type="hidden" value="{$SALESORDERID}">
					{elseif $MODULE eq 'HelpDesk'||$MODULE eq 'ContactRecords'}
						<span name="span_salesorder_name" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{elseif $MODULE eq 'ServiceContracts'||$MODULE eq 'SalesOrder'}
						<span name="span_salesorder_name" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{else}
						<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{/if}
				{elseif $uitype eq 86}
					{foreach key=date_format item=date_str from=$secondvalue}
						{assign var=dateFormat value="$date_format"}
						{assign var=dateStr value="$date_str"}
						{assign var=timeformat value="%H:%M:%S"}
					{/foreach}
					{foreach key=date_value item=time_value from=$fldvalue}
						{assign var=date_val value="$date_value"}
						{assign var=time_val value="$time_value"}
					{/foreach}
					<span name="span_{$fldname}" class="ld-text-inner">{$date_val}</span>
					<input name="{$fldname}" type="hidden" value="{$date_val}">
					<input type="hidden" name="time_reminds" id="time_reminds">
					</td>
				{elseif $uitype eq 70}
					<input name="{$fldname}" type="hidden" value="{$fldvalue.0}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue.0}</span>
				{elseif $uitype eq 230 || $uitype eq 231}
					<input name="{$fldname}" type="hidden" value='{$fldvalue}'/>
					<span name="span_{$fldname}" class="ld-text-inner" class="noteditrichtext" style="height:auto;">{$fldvalue}</span>
                {elseif $bigtype eq 'translatefield'}
                    <input name="{$fldname}" type="hidden" value='{$secondvalue}'/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                {elseif $uitype eq 255}
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$secondvalue}</span>
                {elseif $uitype eq 154}
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                {elseif $uitype eq '19'||$uitype eq '20'}
                    <input name="{$fldname}" type="hidden" value="{$fldvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="white-space:pre-line;height:auto;color:{$fieldvaluecolor};">{$fldvalue|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}</span>
				{elseif $uitype eq '21'}
					<input name="{$fldname}" type="hidden" value="{if !empty($fldvalue)}{$fldvalue|@htmlentities}{/if}"/>
					<span  name="span_{$fldname}" class="ld-text-inner" style="white-space:pre-line;height:auto;color:{$fieldvaluecolor};">{$fldvalue}</span>
                {elseif $uitype eq 1600}
					{*ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）*}
					<input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                {elseif $uitype eq '151'}
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
				{elseif $ReferenceUitypes|@is_array && $uitype|in_array:$ReferenceUitypes}
                    {*zkt 0048293: （东贸）商服管理-场内商户档案，编辑单据‘邱小光测试’，更改商户类型选项信息，会触发页面规则，导致所属类型字段变空*}
                    <input name="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$fldvalue}</span>
                {elseif $uitype eq '1108'}
                    {include file='File_Uploader.tpl'}
                {elseif $uitype eq '1109'||$uitype eq '69'}
                    	<input type="hidden" name="I_file_filename" id="I_file_filename" value="{$fldvalue}" />
							{assign var=FINALDETAIL value=$MODULE|cat:'DetailFieldsHtml'}
								{if  $MODULE|@get_file_address:'ProductDetails' eq 'true' || $MODULE|get_file_address:$FINALDETAIL eq 'true' || $MODULE eq 'Users'}
								     	{if $PAGEMODE eq 'showpagerule'}
                                            {assign var=JSONDATA value=$ALLFILEJSONDATA[$uitype]}
                                        {else}
                                            {assign var=JSONDATA value=$ID|getAttachmentsTableInfo:$MODULE:$fldname}
                                        {/if}
									{include file='File_Uploader.tpl'}
								{else}
									<div name="{$fldname}" class="wu-example">
									</div>
								{/if}
				{elseif $relatedmodulefield eq 'yes'}
					{if $secondvalue|string_format:"%s" eq '' }
						{assign var="secondvalue" value=$fldvalue}
					{/if}
					<input name="{$fldname}" type="hidden" value="{if !empty($secondvalue)}{$secondvalue|@htmlentities}{/if}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor};">{$value_name}</span>
				{elseif $uitype eq 117}
					{*ls 2022-07-07 BUG0053697客户问题（麦兹弗），收款单（GR48和GR53）编辑界面，“币种”字段显示Array*}
					{assign var=selectvalue value="no"}
					{foreach key=key_one item=arr from=$fldvalue}
						{foreach key=sel_value item=value from=$arr}
							{if $value eq 'selected'}
								<input name="{$fldname}" type="hidden" value="{$key_one}"/>
								<span name="span_{$fldname}" class="ld-text-inner">{$sel_value|@getTranslatedCurrencyString}</span>
								{assign var=selectvalue value="yes"}
							{/if}
						{/foreach}
					{/foreach}
					{if $selectvalue eq 'no'}
						<input name="{$fldname}" type="hidden" value=""/>
						<span name="span_{$fldname}" class="ld-text-inner"></span>
					{/if}
                {else}
            		<input name="{$fldname}" type="hidden" value="{$fldvalue}"/>
					<span name="span_{$fldname}" class="ld-text-inner" style="color:{$fieldvaluecolor}">{$fldvalue}</span>
				{/if}
			</td>
		{else}


			{if $uitype eq '10'}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$fldlabel.displaylabel}
					{if count($fldlabel.options) eq 1}
						{assign var="use_parentmodule" value=$fldlabel.options.0}
						<input type='hidden' name="{$fldname}_type" value="{$use_parentmodule}"/>
					{else}
						{if $fromlink eq 'qcreate'}
							<select class="ld-select-inner" style="width:50%;" id="{$fldname}_type" fieldonly='{$fieldonly}' name="{$fldname}_type" onChange='document.QcEditView.{$fldname}_name.value=""; document.QcEditView.{$fldname}.value="";'>
							{else}
							<select class="ld-select-inner" style="width:50%;" id="{$fldname}_type"  fieldonly='{$fieldonly}' name="{$fldname}_type" onChange='document.EditView.{$fldname}_name.value=""; document.EditView.{$fldname}.value="";ld("#qcform").innerHTML=""'>
						 {/if}
							{foreach item=option from=$fldlabel.options}
							<!--
							更新操作
							date:20140218
							reason:联系记录增加创建提醒功能
							by andy
							-->
								{if $MODULE eq 'Reminds'&&($option eq 'Calendar')}
								{else}
								<option value="{$option}"
								{if $fldlabel.selected == $option}selected{/if}>
								{$option|@getTranstab}
								</option>
								{/if}
							{/foreach}
					   </select>
					{/if}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{$fldhelplink}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input id="{$fldname}" name="{$fldname}" type="hidden" value="{$fldvalue.entityid}" id="{$fldname}">
					<input id="{$fldname}_name" name="{$fldname}_name" id="edit_{$fldname}_name" readonly type="text" value="{$fldvalue.displayvalue}" class="ld-input-inner" >
					{if $fromlink eq 'qcreate'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Project","qc","{$fldname}");' draggable="false">+</a>
					{elseif $fromlink eq 'batchcreate'}
					{else}
						{if $MODULE eq 'Reminds'}
							<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" tabindex="{$vt_tab}" onclick="selectRelatedTo('{$fldname}_type' ,'{$fldname}','{$MODULE}','{$ID}')" draggable="false">+</a>
						{else}
						   	<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectRelatedTo('{$fldname}_type' ,'{$fldname}','{$MODULE}','{$ID}')" draggable="false">+</a>
						{/if}
					{/if}
					{if $fromlink eq 'batchcreate'}
					{else}
                        {*zkt 20230111 BUG0060761评论界面新建界面相关评论、回复界面相关回复后方清除组件无效*}
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Users','{$fldname}','{$fldname}_name','{$fldname}','{$MODULE}','popupselectfield');return false;">+</a>
					{/if}
				</td>
			{elseif $uitype eq '82'}
				<td class="ld-form-item-label" style="{$label_style}">
					<input type="hidden" id="discount_rate" name="discount_rate" value="{$secondvalue|@getAccountDiscountRate}" />
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input id="{$fldname}" name="{$fldname}" type="hidden" value="{$fldvalue.entityid}" id="{$fldname}">
					<input id="{$fldname}_name" name="{$fldname}_name" id="edit_{$fldname}" readonly type="text" value="{$fldvalue.displayvalue}" class="ld-input-inner" >
					{if $fromlink eq 'qcreate'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Project","qc");' draggable="false">+</a>
					{elseif $fromlink eq 'batchcreate'}
					{else}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Project","qc","","{$fldname}");' draggable="false">+</a>
					{/if}
					{if $fromlink eq 'batchcreate'}
					{else}
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Project','{$fldname}','{$fldname}_name','projectname','{$MODULE}','popupselectfield'); return false;" draggable="false">+</a>
					{/if}
				</td>
			{elseif $uitype eq 102||$uitype eq 112}
				{*andrew服务合同，合同订单关联回款计划相关对象*}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$fldlabel.displaylabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{$fldhelplink}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if count($fldlabel.options) eq 1}
						{assign var="use_parentmodule" value=$fldlabel.options.0}
						<input type='hidden' name="{$fldname}_type" value="{$use_parentmodule}"/>
					{else}
						{if $fromlink eq 'qcreate'}
							<select class="ld-select-inner ld-select-inner-source" id="{$fldname}_type" fieldonly='{$fieldonly}' name="{$fldname}_type" onChange='document.QcEditView.{$fldname}_name.value=""; document.QcEditView.{$fldname}.value="";'>
						{else}
							<select class="ld-select-inner ld-select-inner-source" id="{$fldname}_type" fieldonly='{$fieldonly}' name="{$fldname}_type" onChange='document.EditView.{$fldname}_name.value=""; document.EditView.{$fldname}.value="";ld("#qcform").innerHTML=""'>
						{/if}
								{foreach item=option from=$fldlabel.options}
									<option value="{$option}"
									{if $fldlabel.selected == $option}selected{/if}>
									{$option|@getTranstab}
									</option>
								{/foreach}
							</select>
					{/if}
					<input id="{$fldname}" name="{$fldname}" type="hidden" value="{$fldvalue.entityid}" id="{$fldname}">
					<input id="{$fldname}_name" name="{$fldname}_name" id="edit_{$fldname}_name" readonly type="text" value="{$fldvalue.displayvalue}" class="ld-input-inner ld-input-inner-source">
					{if $fromlink eq 'qcreate'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" tabindex="{$vt_tab}" onclick="selectRelatedTo('{$fldname}_type','{$fldname}','{$MODULE}','{$ID}')" draggable="false">+</a>
					{else}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" tabindex="{$vt_tab}" onclick="selectRelatedTo('{$fldname}_type','{$fldname}','{$MODULE}','{$ID}')" draggable="false">+</a>
					{/if}
					{if $uitype eq 102}
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('SalesOrder','{$fldname}','{$fldname}_name','salesorder_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{else}
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{/if}
				</td>
			{elseif $uitype eq 2}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
                {*zkt 20221031 BUG0058168kfbcrm客户页面，模糊查询时，模糊查询出的客户名称的框，显示位置应挨着客户名称字段*}
				<td class="ld-form-item-content">
					{if $fldname eq 'accountname' && $MODULE neq 'BankAccountSet'}
						{if $MODULE eq 'Accounts' || $MODULE eq 'ServiceCharge'}
							<input placeholder="{$fieldplaceholder}" type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{if !empty($fldvalue)}{$fldvalue|htmlspecialchars}{/if}" tabindex="{$vt_tab}" class="ld-input-inner ld-input-inner-add" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'}onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if} style="color:{$fieldvaluecolor};" id="account_name_check" autocomplete="off"/>
						{else}
							<input placeholder="{$fieldplaceholder}" type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner ld-input-inner-add" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'}onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if} style="color:{$fieldvaluecolor};" id="account_name_check" />
							{*zkt 应该不显示吧，否则销售线索显示时有问题*}
							{*<div>{$fldvalue}</div>*}
	                    {/if}
						{*客户查重*}
						<div id="check_repeat" class="D_pop_box LdPopWidth600px" style="display:none;"></div>
						{if $BANGWO8 eq ''&& $MODULE|@isPermitted:'accountdatadup' eq 'yes'}
							{if $VERSIONACCOUNT eq 'saic'}
								<b title="{'CHECK'|@getFixedLabel}" class="ld-icon-search" labelname="{$fldname}"  name="datadup_icon" onclick="saic_accountinfo(this,'{$MODULE}');"></b>
							{else}
								<b title="{'CHECK'|@getFixedLabel}" class="ld-icon-search" labelname="{$fldname}"  name="datadup_icon" onclick="look_check_repeat(this,'{$MODULE}');"></b>
							{/if}
						{/if}
					{elseif $fldname eq 'vendorname' && $uitype eq 2 && $VENDORBUSINESS eq 0 && $MODULE eq 'Vendors'}
						<input placeholder="{$fieldplaceholder}"  type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner ld-input-inner-add" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'} onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if} style="color:{$fieldvaluecolor};" id="account_name_check" autocomplete="off"/>
						{*查重*}
						{if $MODULE|@isPermitted:'accountdatadup' eq 'yes'}
							<b title="{'CHECK'|@getFixedLabel}" labelname="{$fldname}" name="datadup_icon" class="ld-icon-search" onclick="look_check_repeat(this,'{$MODULE}');"></b>
						{/if}
					{elseif $fldname eq 'potentialname'}
	                    <input placeholder="{$fieldplaceholder}"  type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner ld-input-inner-add" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'}onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if} style="color:{$fieldvaluecolor};" id="account_name_check" autocomplete="off"/>
	                    {if $MODULE|@isPermitted:'accountdatadup' eq 'yes'}
	                        <b title="{'CHECK'|@getFixedLabel}" labelname="{$fldname}" name="datadup_icon" class="ld-icon-search" onclick="look_check_repeat(this,'{$MODULE}');"></b>
	                 	{/if}
					{else}
						{if $MODULE eq 'Products' && $fldname eq 'productname' && $fieldonly neq 1}
							<input style="float: left;color:{$fieldvaluecolor}" placeholder="{$fieldplaceholder}"  type="text" fieldonly='{$fieldonly}' duplicate="yes" name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'}onkeyup="getTianyanByKeyWord(this,1,'Accounts',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'Accounts',event],event)"{/if}>
	                        {if $MODULE|@isPermitted:'accountdatadup' eq 'yes'}
	                            <b title="{'CHECK'|@getFixedLabel}" labelname="{$fldname}" name="datadup_icon" class="ld-icon-search" onclick="look_check_repeat(this,'{$MODULE}');"></b>
	                        {/if}
	                    {else}
							{if $MODULE eq 'Users' && ($fldname eq 'last_name' || $fldname eq 'wx_userid') && $MODE eq 'edit' && $AUTHTYPE eq 'yes'}<!--企业微信功能变动-->
								<span style="display:none"><input type="hidden" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" /></span>{$fldvalue}
							{else}
								<input style="color:{$fieldvaluecolor}" placeholder="{$fieldplaceholder}"  type="text" fieldonly='{$fieldonly}' name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'}onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if}>
							{/if}
						{/if}
	                {/if}
					{* 工商查询 *}
					{if $ENABLEBUSINESS eq 'yes' && $BUSINESSQUERY eq 'yes'}
						<i id="business_{$fldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang" onclick="getTianyanByKeyWordForInfo('{$fldname}','edit');"></i>
					{/if}
					{if $BUSINESSFUZZYQUERY eq 'yes'}
						<div name="check_kewords" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
					{/if}
			  	</td>
			{elseif $uitype eq 111}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input id="{$fldname}" name="{$fldname}" readonly type="text" value="{$fldvalue}" class="ld-input-inner" >
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showProfileUsers("{$MODULE}","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="this.form.{$fldname}.value=''; this.form.selectType.value='';this.form.selectValue.value='';return false;" draggable="false">+</a>
					<input type="hidden" value="{$SELECTTYPE}" id="selectType" name="selectType" />
					<input type="hidden" value="{$SELECTVALUE}" id="selectValue" name="selectValue" />
				</td>
			{elseif $uitype eq 152 || $uitype eq 180}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $uitype eq 152}
						<input id="{$fldname}_name" name="{$fldname}_name" readonly type="text" value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","{$fldname}","Group","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","")' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="this.form.{$fldname}.value=''; this.form.{$fldname}_name.value='';return false;" draggable="false">+</a>
						<input type="hidden" value="{$secondvalue}" id="{$fldname}" name="{$fldname}" />
					{else}
						{if $MODULE eq 'Users' && $fldname eq 'groupid' && $MODE eq 'edit' && $AUTHTYPE eq 'yes'}<!--企业微信功能变动-->
							<span style='display:none' id="{$fldname}_name" name="{$fldname}_name">{$fldvalue}</span> {$fldvalue}
						{else}
							<div id="{$fldname}_name" class="ld-input-inner-div ld-input-inner-add" name="{$fldname}_name" readonly style="text-overflow: ellipsis;overflow: hidden;">{$fldvalue}</div>
							{if $USEREDIT == 'useredit' && $IS_ADMIN eq false}
							{else}
								<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","{$fldname}","Group","sel_checkbox","search_yes","{$MODULE}","{$usefldlabel}","")' draggable="false">+</a>
								<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
								<input type="hidden" value="{$secondvalue}" id="{$fldname}" name="{$fldname}" />
							{/if}
						{/if}
					{/if}
				</td>
			{elseif $uitype eq 70}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="hidden" value="{$fldvalue.0}">
					<input name="date_only" class="Wdate ld-input-inner" autocomplete="off" type="text"  style="color:{$fieldvaluecolor}" size="15" maxlength="10" value="{$fldvalue.0}" onClick="WdatePicker()">
					<input type="hidden" name="time_reminds" id="time_reminds">
					{$fldvalue.1}
					{foreach key=date_format item=date_str from=$secondvalue}
						{assign var=dateFormat value="$date_format"}
						{assign var=dateStr value="$date_str"}
					{/foreach}
				</td>
			{elseif $uitype eq 86}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{foreach key=date_format item=date_str from=$secondvalue}
						{assign var=dateFormat value="$date_format"}
						{assign var=dateStr value="$date_str"}
						{assign var=timeformat value="%H:%M:%S"}
					{/foreach}
					{foreach key=date_value item=time_value from=$fldvalue}
						{assign var=date_val value="$date_value"}
						{assign var=time_val value="$time_value"}
					{/foreach}
					<input name="{$fldname}" class="Wdate ld-input-inner" type="text" style="box-sizing: border-box;color:{$fieldvaluecolor}" size="15" maxlength="25" value="{$date_val}" autocomplete="off" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim});ld('.SearchResult').css('display','none')">
					<input type="hidden" name="time_reminds" id="time_reminds">
				</td>
			{elseif $uitype eq 3 || $uitype eq 4}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}
					<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<!-- {if $MODE neq 'edit' && $fldvalue eq ''}
						{assign var="fldvalue" value=$MOD_SEQ_ID}
					{/if} -->
					<!--  andy 系统编号改进-->
					{if  $ISALLOW eq '1'}
					   <input type="text" fieldonly='1' tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner">
					{else}
						<input type="hidden" fieldonly='1' tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner">{$fldvalue}
					{/if}
					<input type="hidden" id="hiddenprefix" value="{$fldname}"/>
				</td>
			{elseif $uitype eq 11}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}
					<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" style="color:{$fieldvaluecolor}">{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $fldname eq 'tickersymbol' && $MODULE eq 'Accounts'}
					<td class="ld-form-item-content">
						<input fieldonly='{$fieldonly}' type="text" name="{$fldname}" style="color:{$fieldvaluecolor}" tabindex="{$vt_tab}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner">
						<span id="vtbusy_info" style="display:none;">
						<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
					</td>
				{else}
					{if $CALLPHONE neq ""}
						<td class="ld-form-item-content"><input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" style="color:{$fieldvaluecolor}" id ="{$fldname}" value="{$CALLPHONE}" class="ld-input-inner"></td>
					{else}
						<td class="ld-form-item-content"><input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" style="color:{$fieldvaluecolor}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner"></td>
					{/if}
				{/if}
			{elseif $uitype eq '161'}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}
						<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" style="color:{$fieldvaluecolor}">{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input fieldonly='{$fieldonly}' old_approver="{$last_name[0].id}" resetapprover="no" type="hidden" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$last_name[0].id}" style="color:{$fieldvaluecolor}"/>
					<div readonly=true id="approveby_name" name="approveby_name" class="ld-input-inner-div ld-input-inner-add">{$last_name[0].last_name}</div>
					<a class="ld-text-select" id="approveby_img" href="javascript:void(0);" title="{'SELECT'|@getFixedLabel}" style="{if $approvestatus_show_user eq 1} display:none;{/if}" onclick="getApproveUser()" draggable="false">+</a>
				</td>
			{elseif $uitype eq 1 || $uitype eq 13 || $uitype eq 7}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}
					<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $fldname eq 'tickersymbol' && $MODULE eq 'Accounts'}
					<td class="ld-form-item-content">
						<input fieldonly='{$fieldonly}' type="text" name="{$fldname}" tabindex="{$vt_tab}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner" onBlur="{if $fldname eq 'tickersymbol' && $MODULE eq 'Accounts'}sensex_info(){/if}">
						<span id="vtbusy_info" style="display:none;">
						<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
					</td>
				{else}
					{if $fldname eq "approveby"}
						<td class="ld-form-item-content">
							<input fieldonly='{$fieldonly}' type="hidden" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$last_name[0].id}" />
							<input type="text" id="approveby_name" name="approveby_name" value="{$last_name[0].last_name}" class="ld-input-inner ld-input-inner-add" />
							<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="window.open('index.php?module=Users&action=Popup','test','width=840,height=602,resizable=1,scrollbars=1,top=150,left=200');" draggable="false">+</a>
						</td>
					{else}
						{if $VERSION_ACCOUNT eq 'dongmao' && $VERSION_TRADE eq 'yongdingcheng' && ($fldname eq 'totaluser_qty' || $fldname eq 'newuser_qty' || $fldname eq 'car_amount'|| $fldname eq 'newuser_amount'|| $fldname eq 'user_amount') }<!--{*dongmao*}-->
							<td class="ld-form-item-content">
								<input name="{$fldname}" id='txtbox_{$fldname}' tabindex="{$vt_tab}" type="text" fieldonly='{$fieldonly}' class="ld-input-inner" onBlur="sum_commission('{$fldname}')" value="{$fldvalue}">
							</td>
						{elseif $VERSION_ACCOUNT eq 'baxter' && $fldname eq 'cf_6314'}
							<td class="ld-form-item-content">
								<input style="color:{$fieldvaluecolor}" placeholder="{$fieldplaceholder}" fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner" >
								<button class="btn btn-primary" onclick="sendsmsBaxter(this); return false;" title="发送">发送</button>
							</td>
						{else}
							<td class="ld-form-item-content">
                                {* zkt 20230803 BUG0070480 该问题在苏州本地系统和演示账套都存在，应该属于通用问题	文本字段加上英文格式的 " 后，再次点击编辑， " 之后的内容自动消失 *}
								<input style="color:{$fieldvaluecolor}" placeholder="{$fieldplaceholder}" fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{if !$fldvalue|@is_null && $fldvalue neq '' }{$fldvalue|htmlspecialchars}{/if}" class="ld-input-inner" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'} onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if}>
								{* 工商查询 *}
								{if $uitype eq 1}
									{if $ENABLEBUSINESS eq 'yes' && $BUSINESSQUERY eq 'yes'}
										<i id="business_{$fldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang" onclick="getTianyanByKeyWordForInfo('{$fldname}','edit');"></i>
									{/if}
									{if $BUSINESSFUZZYQUERY eq 'yes'}
										<div name="check_kewords" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
									{/if}
								{/if}
							</td>
						{/if}
					{/if}
				{/if}
			{elseif $uitype eq 9}
				{*BUG0053783 % 全部放开（潘）*}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}(%) {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="text" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner" style="color:{$fieldvaluecolor}">
				</td>
			{elseif $uitype eq 19 || $uitype eq 20}
				<tr>
				{*edit:can date:20130912; reason:常见问答中有两个textarea,所以要加<tr>*}
				{if $fldlabel eq 'ADDCOMMENT'|@getFixedLabel}
					{assign var=fldvalue value=""}
				{/if}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
				   	{if $MODULE eq 'Documents' && $USE_RTE eq true}
						 <script id="{$fldname}" name="{$fldname}" type="text/plain" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' style="width:800px;height:150px;">{$fldvalue}</script>
						 <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js"></script>
						 <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js"></script>
						 <script type="text/javascript">
							var ue = UE.getEditor('{$fldname}');
						</script>
				   	{else}
					   	{*wym BUG0074061 bug管理-新建-问题来源选择“测试遍历”后，摘要框就会变得很窄*}
						<textarea class="ld-textarea-inner" placeholder="{$fieldplaceholder}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' name="{$fldname}" id="{$fldname}" style="resize: vertical !important;color:{$fieldvaluecolor}; height: 52px;">{$fldvalue}</textarea>
				   	{/if}
					{if $fldlabel eq $MOD.Solution}
						<input type = "hidden" name="helpdesk_solution" value ='{$fldvalue}'>
					{/if}
				</td>
				</tr>
			{elseif $uitype eq 21 || $uitype eq 24 }
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				{if ($uitype eq 21) && $td2_uitype eq ''}
					<td class="ld-form-item-content" colspan="3">
				{else}
					<td class="ld-form-item-content">
				{/if}
					<textarea class="ld-textarea-inner" placeholder="{$fieldplaceholder}" value="{$fldvalue}" name="{$fldname}" id="{$fldname}" tabindex="{$vt_tab}" style="resize: vertical !important;color:{$fieldvaluecolor};" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'} onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if}>{$fldvalue}</textarea>
					{* 工商查询 *}
					{if $ENABLEBUSINESS eq 'yes' && $BUSINESSQUERY eq 'yes'}
						<i id="business_{$fldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang" onclick="getTianyanByKeyWordForInfo('{$fldname}','edit');"></i>
					{/if}
					{if $BUSINESSFUZZYQUERY eq 'yes'}
						<div name="check_kewords" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
					{/if}
				</td>
				{if ($uitype eq 21) && $td2_uitype eq ''}
					</tr>
				{/if}
			{elseif $uitype eq 65}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
					<input type="text" value="{$fldvalue}" placeholder="{'PleaseEnterBuildingStreetCompanyAddress'|@getTranstab}" name="{$fldname}" onkeyup="getLocationAddress('{$fldname}','create')" id="{$fldname}" tabindex="{$vt_tab}" class="ld-input-inner" autocomplete="off" />
					<div class="f-item f-no-required" style="display:none">
						<div class="f-item-tit">
							<div class="f-comp-wrap j-comp-wrap" data-type="location" data-apiname="location">
								<div class="crm-c-searchmap">
									<ul class="map-result" name="search_location_address" id="search_location_address" style="display: block;">
									</ul>
								</div>
							</div>
						</div>
					</div>
				</td>
				</tr>
			{elseif $uitype eq 64}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
					<!-- <div class="m-view j-full-map" title="放大地图" onclick="enlarge_map();"></div>-->
					<div name="container" id="container" style="height:100px;"></div>
				</td>
				</tr>
			{elseif $uitype eq 230 }
				<tr>
				<td class="ld-form-item-label" style="{$label_style}">
					{if $MODULE eq 'PublicAnnouncement'}
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{else}
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
						{*ls 2022-02-07 0049704: （81mis.com/kfbcrm/index.php）产品管理》产品详情字段是富文本框，页面设置中有勾选批量编辑选项，但批量编辑保存不生效*}
						{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
						<br/>
						{*// @edit:dong @date:2020/07/21 @reason: 语言文本 调用模板给为调用文档模板*}
						<a title="{'CALLDOCUMENTTEMPLATE'|@getFixedLabel}" id="Rich{$fldname}" name="Rich{$fldname}" href="javascript:;" style="line-height: 32px;" onclick="OpenRichTextTemplate('{$fldname}')">{'CALLDOCUMENTTEMPLATE'|@getFixedLabel}</a>
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
					<textarea id="{$fldname}" name="{$fldname}" type="text/plain" style="height:100px;width:100%;">{$fldvalue}</textarea>
				</td>
				</tr>
			{elseif $uitype eq 231 }
				<td class="ld-form-item-label" style="{$label_style}">
					{if $MODULE eq 'PublicAnnouncement'}
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{else}
					<font color="red">{$mandatory_field}</font>{$usefldlabel}<br />
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
					<textarea id="{$fldname}" name="{$fldname}" type="text/plain" style="height:100px;width:100%;">{$fldvalue}</textarea>
				</td>
				</tr>
            {*新建、编辑：出库状态、入库状态显示下拉框*}
            {else if $uitype eq 130 &&($MODULE =='OutboundOrder'||$MODULE=='Stock')}
                <td class="ld-form-item-label" style="{$label_style}">
                    {*zkt 20230110 BUG0060575批量编辑更改入库状态无效(kfbcrm也有问题 已提BUG0060572  ) *}
                    <font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
                </td>
                <td class="ld-form-item-content">
                    <select id="{$fldname}" class="ld-select-inner" name="{$fldname}" fieldonly="0">
                        {if $MODULE=='OutboundOrder'}
                            <option value="未出库">未出库</option>
                            <option value="已出库" {if $fldvalue eq '已出库'}selected=""{/if}>已出库</option>
                        {else if $MODULE=='Stock'}
                            <option value="未入库">未入库</option>
                            <option value="已入库" {if $fldvalue eq '已入库'}selected=""{/if}>已入库</option>
                        {/if}
                    </select>
                </td>
			{elseif $uitype eq 15 || $uitype eq 601}
				{*个人信息 如果不是管理员无法编辑审批委托、职位级别*}
				{if ($fldname == 'approvestatus' || $fldname == 'userlevel') &&  $IS_ADMIN eq false}
					<td class="ld-form-item-label" style="{$label_style}">
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content" id="td_cmb_{$fldname}">
						{if $fldname == 'userlevel'}
							{foreach item=value key=key from=$level_show_user}
								{if $level_show == $key  && $level_show neq '' || $level_show_user == $key  && $level_show_user neq ''}
									{$value}
								{/if}
							{/foreach}
						{else}
							{foreach item=value key=key from=$approvestatus}
								{if $MODE eq 'edit'|| $mode_showpagerule eq 'yes'}
									{if $approvestatus_show == $key  && $approvestatus_show neq '' || $approvestatus_show_user == $key  && $approvestatus_show_user neq ''}
									   {$value}
									   <input type="hidden" id="approvestatus" value="{$key}" />
									{/if}
								{else}
									{if $key eq '1'}
										{$value}
										<input type="hidden" id="approvestatus" value="{$key}" />
									{/if}
								{/if}
							{/foreach}
						{/if}
					</td>
				{else}
					{if $fldname eq 'approvestatus' || $fldname eq 'social_activitytype'}
						{include file='DetailView/PickList.tpl'}
					{else}
						{include file='DetailView/PickClickList.tpl'}
					{/if}
				{/if}
			{elseif  $uitype eq 16  || $uitype eq '31' || $uitype eq '32'}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODULE eq 'Calendar'}
						<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' class="ld-select-inner">
					{elseif ( $fldname eq 'accountallview')&&$IS_ADMIN eq false}
					 	<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' id="{$fldname}" disabled="true" class="ld-select-inner">
					{else}
						<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' id="{$fldname}" class="ld-select-inner">
					{/if}
					{foreach item=arr from=$fldvalue}
						{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
						<option value="{$arr[0]}" {$arr[2]}>
							{$arr[0]}
						</option>
						{else}
						<option value="{$arr[0]}" {$arr[2]}>
							{$arr[0]}
						</option>
						{/if}
					{/foreach}
				  </select>
				</td>
			{elseif $uitype eq 251 || $uitype eq 252 }
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' class="ld-select-inner">
					{foreach item=arr from=$fldvalue}
						<option value="{$arr[0]}" {$arr[2]} bank_curid="{$arr[3]}">{$arr[1]}</option>
					{/foreach}
			        </select>
					{if checkCurrentUserIsAdmin() eq 'on'}
						<i onclick="getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="ld-fonticon ld-fonticon-set"></i>
					{/if}
				</td>
			{elseif $uitype eq 1021 || $uitype eq 1022 ||$uitype eq 1023}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODULE eq 'Calendar'}
						<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' class="ld-select-inner" style="width:160px;">
					{else}
						<select name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' class="ld-select-inner">
					{/if}
					{foreach item=arr from=$fldvalue}
						{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
						<option value="{$arr[0]}" {$arr[2]}>
							{$arr[0]}
						</option>
						{else}
						<option value="{$arr[0]}" {$arr[2]}>
							{$arr[0]}
						</option>
						{/if}
					{foreachelse}
						<option value=""></option>
						<option value="" style='color: #777777' disabled>--{'NONE'|@getFixedLabel}--</option>
					{/foreach}
				   </select>
				</td>
			{elseif $uitype eq 33}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<div>
						{* 多选框name应该带有[]*}
						<select MULTIPLE id="{$fldname}" name="{$fldname}[]" class="ld-input-inner select2 select2-offscreen" tabindex="{$vt_tab}" style="width:100%;">
							{foreach item=arr from=$fldvalue}
								{if $arr[1] neq ''}
									<option value="{$arr[1]}" {$arr[2]}>
										{$arr[0]}
									</option>
								{/if}
							{/foreach}
						</select>
						{if checkCurrentUserIsAdmin() eq 'on' and $fldname neq 'role_module'}
							<i onclick="getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="ld-fonticon ld-fonticon-set"></i>
						{/if}
						<script type="text/javascript">
							ld(document).ready(function() {ldelim}
								ld("#{$fldname}").select2({ldelim}closeOnSelect: false{rdelim});
							{rdelim});
						</script>
					</div>
				</td>
			{elseif $uitype eq 34}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" style="position: relative;">
					<div class="ld-input-inner-div"  onclick="show_related_picklist('{$fldname}')" id="cmb_a_{$fldname}" name="cmb_a_{$fldname}" draggable="false" style="overflow: hidden;cursor: pointer;" >
						<ul id="cmb_ul_{$fldname}" name="cmb_ul_{$fldname}" class="ld-input-inner-div-items">
							{foreach key=tmp_index item=tmp_arr  from=$secondvalue}
								<li class="ld-input-inner-div-item userlevel-fontstyle" >
									<span class="item-name">{$tmp_arr.name}</span>
									<span class="item-name">:{$tmp_arr.value}</span>
									<span class="remove-h" onclick="cancel_related_picklist('{$fldname}','{$tmp_arr.id}')">×</span>
								</li>
							{/foreach}
						</ul>
						{if checkCurrentUserIsAdmin() eq 'on' }
							<i onclick="getCombox('{$MODULE}','{$fldname}')" title="{'SETTINGS'|@getFixedLabel}" class="ld-fonticon ld-fonticon-set"></i>
						{/if}
					</div>
					<div class="userlevel-showstyle" id="dv_{$fldname}" name="dv_{$fldname}" style="display: none;width: calc(100% - 20px);" onclick="event.stopPropagation();" ></div>
					<input type="hidden" from_fieldname="groupid" id="{$fldname}" name="{$fldname}" value="{$fldvalue}">
					<input type="hidden" from_fieldname="groupid" id="jsonvalue_{$fldname}" name="jsonvalue_{$fldname}" value="{$thirdvalue}">
				</td>
			{elseif $uitype eq 53}
				<!--V6.0角色权限改进 - 负责人不能直接编辑,只能通过分配编辑-->
				{if $ID > 0}
					<td class="ld-form-item-label" style="{$label_style}">
						{$usefldlabel}
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content">
						{foreach key=key_one item=arr from=$fldvalue}
							{foreach key=sel_value item=value from=$arr}
								 {if $value eq 'selected'}
									 <!--<input id="dv_chzn_1_assigned_user_id" class="ld-input-inner" type="text" value="{$sel_value}" name="dv_chzn_1_assigned_user_id" tabindex="" fieldonly="1" readonly="">-->
									<input type="hidden" id="{$fldname}" name="{$fldname}" value="{$key_one}"><div class="ld-text-inner">{$sel_value}</div>
								 {/if}
							{/foreach}
						{/foreach}
					</td>
				{else}
					{include file='DetailView/Smowner.tpl'}
				{/if}
			{elseif $uitype eq 153}
				{if $fldname eq 'servicecasher' && $ID > 0}
					<td class="ld-form-item-label" style="{$label_style}">
						{$usefldlabel}
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content">
						{foreach key=key_one item=arr from=$fldvalue}
							{foreach key=sel_value item=value from=$arr}
								{if $value eq 'selected'}
									<input type="hidden" id="{$fldname}" name="{$fldname}" value="{$key_one}">{$sel_value}
								{/if}
							{/foreach}
						{/foreach}
					</td>
				{else}
					{include file='DetailView/Smowner.tpl'}
				{/if}
			{elseif $uitype eq 154}
			 	<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<div class="ld-input-inner-div ld-input-inner-add" id="{$fldname}_name" name="{$fldname}_name" style="overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0" value="{$fldvalue}">{$fldvalue}</div>
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","{$fldname}","User","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","")' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');" draggable="false">+</a>
					<input type="hidden" value="{$secondvalue}" id="{$fldname}" name="{$fldname}" />
				</td>
			 {elseif $uitype eq 100}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
				</td>
				{*andy 0012783: 客户需求：提醒新增界面，提醒人文本框-勾选用户不方便，当用户数量很多时需要一个一个的勾选，希望更改为-像公告新增界面中接收人一样*}
				<td class="ld-form-item-content">
					{foreach key=key_one item=arr from=$fldvalue}
						{foreach key=sel_value item=value from=$arr}
							{if $value eq 'selected'}
								<input name="txt_select_user" readonly type="text" fieldonly='{$fieldonly}' value="{$sel_value}" class="ld-input-inner ld-input-inner-add" onclick="select_reciever();" />
								<input name="{$fldname}" type="hidden" value="{$key_one}"/>
							{/if}
						{/foreach}
					{/foreach}
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="select_reciever();" draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','txt_select_user','','{$MODULE}','popupselectfield'); return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 52 || $uitype eq 77}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $uitype eq 52}
						<select name="{$fldname}" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
					{elseif $uitype eq 77}
						<select name="{$fldname}" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
					{else}
						<select name="{$fldname}" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
					{/if}
					{foreach key=key_one item=arr from=$fldvalue}
						{foreach key=sel_value item=value from=$arr}
							<option value="{$key_one}" {$value}>{$sel_value}</option>
						{/foreach}
					{/foreach}
					</select>
				</td>
			{elseif $uitype eq 51}
				{if $MODULE eq 'Accounts'}
					{assign var='popuptype' value = 'specific_account_address'}
				{else}
					{assign var='popuptype' value = 'specific_contact_account_address'}
				{/if}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input readonly name="{$fldname}_name" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Accounts","","","{{$fldname}}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','accountname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 50}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input readonly name="accounts_name" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module=Accounts&action=Popup&popuptype=specific&form=TasksEditView&form_submit=false&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','{$fldname}','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 73}
				<td class="ld-form-item-label" style="{$label_style}">
					<input type="hidden" id="discount_rate" name="discount_rate" value="{$secondvalue|@getAccountDiscountRate}" />
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $MODULE eq 'OutboundOrder' && $ACCOUNTID > 0}
					<td class="ld-form-item-content">
						<input readonly name="{$fldname}_name" id="single_accountid" type="text" fieldonly='{$fieldonly}' value="{$ACCOUNTNAME}" {if $ACCOUNTNAME neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Accounts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Accounts',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$ACCOUNTID}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Accounts","select","{$POPUPBUTTON}","{$fldname}");'>+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','accountname','{$MODULE}','popupselectfield');clearAccountsContactsInfo('{$MODULE}','Accounts','EditView');return false;">+</a>
					</td>
				{elseif ($MODULE eq 'HelpDesk' || $MODULE eq 'ContactRecords') && $CALLTYPE eq 'true'}
					<td class="ld-form-item-content">
						<input readonly name="{$fldname}_name" id = "single_accountid" type="text" fieldonly='{$fieldonly}' value="{$ACCOUNTNAME}"{if $ACCOUNTNAME neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Accounts',event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$ACCOUNTID}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Accounts","select","{$POPUPBUTTON}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','accountname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					</td>
				{else}
					<td class="ld-form-item-content">
						<input name="{$fldname}_name" fieldname="{$fldname}" id = "single_accountid" type="text" fieldonly='{$fieldonly}'  value="{$fldvalue}"{if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Accounts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Accounts',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}" >
						{if $fromlink neq 'batchcreate'}
							<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Accounts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
							<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','accountname','{$MODULE}','popupselectfield');clearAccountsContactsInfo('{$MODULE}','Accounts','EditView');return false;" draggable="false">+</a>
						{/if}
						<div class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
					</td>
				{/if}
    		{elseif $uitype eq 540}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","PurchaseOrder","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('PurchaseOrder','{$fldname}','{$fldname}_name','purchaseorder_name','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 173}
				<td class="ld-form-item-label" style="{$label_style}">
					<input type="hidden" id="discount_rate" name="discount_rate" value="{$secondvalue|@getAccountDiscountRate}" />
					<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" id="single_accountid" type="text" fieldonly='{$fieldonly}' fieldname="{$fldname}" value="{$fldvalue}"{if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Accounts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Accounts',event],event)" autocomplete="off" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}" >
					{if $fromlink neq 'batchcreate'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist_special("{$MODULE}","Accounts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','realaccountid','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{/if}
					<div class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
				</td>
			{elseif $uitype eq 244}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input readonly name="{$fldname}_name" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist_special("{$MODULE}","Accounts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Accounts','{$fldname}','{$fldname}_name','{$fldname}','{$MODULE}','');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 125}
				<tr>
					<td class="ld-form-item-label" style="{$label_style}">
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content ld-form-item-content-second" colspan="3">
						<input name="{$fldname}" id="{$fldname}" type="hidden" value="{if $fldvalue neq ''}1{/if}">
						<a href="javascript:;" onclick='return showAllocation("{$MODULE}","{$MODE}","{$ID}","{$fldname}");' id="{$fldname}_select_shareequally_label" tag="{'ADDITION'|@getFixedLabel}" >{if $fldvalue neq ''}{'CONTINUEADDING'|@getFixedLabel}{else}{'ADDITION'|@getFixedLabel}{/if}{$usefldlabel}</a>
						{if $ISADMIN eq 'on'}
							<a href="javascript:;" onclick="setShareSourceModule('{$MODULE}','{$fldname}')">{'SETTINGS'|@getFixedLabel}{'SOURCETYPE'|@getFixedLabel}</a>
						{/if}
						<div name="{$fldname}_shareequally_div" id="{$fldname}_shareequally_div">
							{$fldvalue}
						</div>
					</td>
				</tr>
			{elseif $uitype eq 75 || $uitype eq 81}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $uitype eq 81}
						{assign var="pop_type" value="specific_vendor_address"}
						{else}{assign var="pop_type" value="specific"}
					{/if}
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $PURCHASEORDERID >0 && $MODULE == 'Stock'}
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$VENDORNAME}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" id="{$fldname}" type="hidden" value="{$VENDORID}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Vendors","select","","{$fldname}");' draggable="false">+</a>
					{elseif $MODULE eq 'VendorContactRecords' && $CALLTYPE eq 'true'}
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$VENDORNAME}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" id="{$fldname}" type="hidden" value="{$VENDORID}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Vendors","select","{$fldname}");' draggable="false">+</a>
					{else}
						<input name="{$fldname}_name" fldname="{$fldname}" colname="{$colname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" fieldname="{$fldname}" onkeyup="getKeyWords(this,1,'Vendors',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Vendors',event],event)" autocomplete="off" >
						<input name="{$fldname}" id="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Vendors","select","","{$fldname}");' draggable="false">+</a>
					{/if}
					<div id="search_vendors_name" name="search_vendors_name" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Vendors','{$fldname}','{$fldname}_name','vendorname','{$MODULE}','popupselectfield');return clearVendors(this,'{$MODULE}')" draggable="false">+</a>
				</td>
			{elseif $uitype eq 74}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" fldname="{$fldname}" colname="{$colname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" fieldname="{$fldname}" onkeyup="getKeyWords(this,1,'Contacts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Contacts',event],event)" autocomplete="off" >
					<input name="{$fldname}" id="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Contacts","select","","{$fldname}");' draggable="false">+</a>
					<div id="search_vendors_name" name="search_contacts_name" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Contacts','{$fldname}','{$fldname}_name','vendorname','{$MODULE}','popupselectfield');return clearVendors(this,'{$MODULE}')" draggable="false">+</a>
				</td>
			{elseif $uitype eq 57}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODULE == 'Contacts'}
						<input type="hidden" id = "single_accountid" fieldonly='{$fieldonly}'  value="{$ACCOUNTNAME}">
					{/if}
					{if $fromlink eq 'qcreate'}
						<input name="{$fldname}_name" type="text" fieldonly='0' fieldname="{$fldname}" value="{$fldvalue}" {if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Contacts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Contacts',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Contacts","qc","{$POPUPBUTTON}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Contacts','{$fldname}','{$fldname}_name','lastname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{elseif $fromlink eq 'batchcreate'}
						<input name="{$fldname}_name" fieldname="{$fldname}" type="text" fieldonly='0' value="{$fldvalue}" {if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner" onkeyup="getKeyWords(this,1,'Contacts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Contacts',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{elseif ($MODULE eq 'HelpDesk' || $MODULE eq 'ContactRecords') && $CALLTYPE eq 'true'}
						<input name="{$fldname}_name" type="text" fieldonly='{$fieldonly}' value="{$LASTNAME}" {if $LASTNAME neq ''} style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Contacts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Contacts',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$CONTACTID}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Contacts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Contacts','{$fldname}','{$fldname}_name','lastname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{else}
						<input name="{$fldname}_name" type="text" fieldonly='{$fieldonly}' fieldname="{$fldname}" value="{$fldvalue}" {if $fldvalue neq ''} style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'Contacts',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'Contacts',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						{*// @edit:ls @date:2020-7-6 @reason: 义文机电一键检测需求*}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Contacts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Contacts','{$fldname}','{$fldname}_name','lastname','{$MODULE}','popupselectfield');clearAccountsContactsInfo('{$MODULE}','Contacts','EditView');return false;" draggable="false">+</a>
					{/if}
					<div id="search_contact_name" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
				</td>
				{elseif $uitype eq 600}
					<td class="ld-form-item-label" style="{$label_style}">
						<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					</td>
					<td class="ld-form-item-content">
					{if $fromlink eq 'qcreate'}
						<input name="{$fldname}_name" type="text" fieldonly='0' value="{$fldvalue}" {if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","BankBranch","qc","{$POPUPBUTTON}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{elseif $fromlink eq 'batchcreate'}
						<input name="{$fldname}_name" type="text" fieldonly='0' value="{$fldvalue}" {if $fldvalue neq ''}style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{else}
						<input name="{$fldname}_name" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" {if $fldvalue neq ''} style="cursor: not-allowed;" disabled="disabled" {/if} class="ld-input-inner ld-input-inner-add" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","BankBranch","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{/if}
				</td>
			{elseif $uitype eq 245} {*销售机会-相关联系人*}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $fromlink eq 'qcreate'}
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Contacts","select","{$POPUPBUTTON}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Contacts','{$fldname}','{$fldname}_name','related_contactid','{$MODULE}','');return false;" draggable="false">+</a>
					{else}
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist_special("{$MODULE}","Contacts","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Contacts','{$fldname}','{$fldname}_name','related_contactid','{$MODULE}','');return false;" draggable="false">+</a>
					{/if}
				</td>
			{elseif $uitype eq 96}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $fromlink eq 'qcreate'}
						<input name="{$fldname}_name" fldname="{$fldname}" colname="{$colname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" fieldname="{$fldname}" class="ld-input-inner" onkeyup="getKeyWords(this,1,'VendorContact',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'VendorContact',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","VendorContact","qc","","{$fldname}");' draggable="false">+</a>
					{elseif $MODULE eq 'VendorContactRecords' && $CALLTYPE eq 'true'}
						<input name="{$fldname}_name" fldname="{$fldname}" colname="{$colname}" type="text" fieldonly='{$fieldonly}' value="{$LASTNAME}" fieldname="{$fldname}" class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'VendorContact',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'VendorContact',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$VENDORCONTACTID}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","VendorContact","select","","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('VendorContact','{$fldname}','{$fldname}_name','lastname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{else}
						{*ls 20221123 BUG0059026 付款单中供应商联系人字段 填写 张 模糊搜索选中任意带出信息 供应商收款人姓名并未关联上 保存仍提示供应商收款人姓名为空（js里赋值字段名称取得是属性fieldname的值）*}
						<input name="{$fldname}_name" fldname="{$fldname}" colname="{$colname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" fieldname="{$fldname}" class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'VendorContact',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'VendorContact',event],event)" autocomplete="off" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","VendorContact","select","","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('VendorContact','{$fldname}','{$fldname}_name','lastname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{/if}
					<div id="search_contacts_name" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
				</td>
			{elseif $uitype eq 97}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","VendorContact","select","","{$fldname}");'  draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('VendorContact','{$fldname}','{$fldname}_name','lastname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 58}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
				   	<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Campaigns","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
				   	<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Campaigns','{$fldname}','{$fldname}_name','campaignname','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 80}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $MODULE eq 'OutboundOrder' && $SALESORDERID > 0}
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$SALESORDERNAME}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$SALESORDERID}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectSalesOrder('{$MODULE}');" draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('SalesOrder','{$fldname}','{$fldname}_name','salesorder_no','{$MODULE}','popupselectfield');{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" draggable="false">+</a>
				</td>
				{elseif $MODULE eq 'HelpDesk'||$MODULE eq 'ContactRecords'}
					<td class="ld-form-item-content">
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","SalesOrder","select","","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="clear_relatedfielddata('SalesOrder','{$fldname}','{$fldname}_name','salesorder_no','{$MODULE}','popupselectfield');{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" draggable="false">+</a>
					</td>
				{elseif $MODULE eq 'ServiceContracts' }
					<td class="ld-form-item-content">
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="originBill_select('{$MODULE}');" draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleProduct(this,'{$MODULE}','{$PRODUCTCONTENT}'); return false;" draggable="false">+</a>
					</td>
				{else}
					<td class="ld-form-item-content">
						<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" type="hidden" value="{$secondvalue}">
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","SalesOrder","select","","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('SalesOrder','{$fldname}','{$fldname}_name','salesorder_no','{$MODULE}','popupselectfield');{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" draggable="false">+</a>
					</td>
				{/if}
			<!--联系记录新增服务单字段-->
			{elseif $uitype eq 240}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{if  $VERSION_ACCOUNT neq '' && $VERSION_ACCOUNT eq 'climaveneta' && ($MODULE eq 'Quotes' || $MODULE eq 'ContactRecords')}
					{else}
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","HelpDesk","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('HelpDesk','{$fldname}','{$fldname}_name','ticket_no','{$MODULE}','popupselectfield');{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" draggable="false">+</a>
					{/if}
				</td>
			 <!--联系记录新增项目任务字段-->
			{elseif $uitype eq 241}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","ProjectTask","select","no","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('ProjectTask','{$fldname}','{$fldname}_name','projecttaskname','{$MODULE}','popupselectfield');{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" draggable="false">+</a>
				</td>
			 <!--服务单新增服务合同字段-->
			{elseif $uitype eq 243}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","ServiceContracts","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('ServiceContracts','{$fldname}','{$fldname}_name','contract_no','{$MODULE}','popupselectfield');{if $MODULE eq 'CashBill'}ClearPaymentList('{$MODULE}');{/if}return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 76}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{if  $VERSION_ACCOUNT neq '' && $VERSION_ACCOUNT eq 'climaveneta_20220926' && $MODULE eq 'HelpDesk'}
					{else}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" name="{$fldname}_showmodule" onclick='showrelatedlist("{$MODULE}","Potentials","select","","{$fldname}");' draggable="false">+</a>
                        {*海格编辑、复制时不允许销售重新选择报价单号,清除按钮不显示*}
                        {if $VERSION_ACCOUNT neq '' && $VERSION_ACCOUNT eq 'haige' && $MODULE eq 'Quotes'&&$fldname eq 'potential_id' && $showpotentialid neq undefined && $showpotentialid eq 'no'}
                        {else}
                        	<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" name="{$fldname}_clear" onclick="clear_relatedfielddata('Potentials','{$fldname}','{$fldname}_name','potential_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					   	{/if}
                    {/if}
				</td>
        	{elseif $uitype eq 501}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm01","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm01','{$fldname}','{$fldname}_name','customform01_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
            {elseif $uitype eq 502}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
				  	{if $MODULE eq 'Products' && $account eq 'yiwen'}
				  		<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="showproductlist('{$MODULE}', 'inventory_prod')" draggable="false">+</a>
					{else}
					    <a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm02","select","","{$fldname}");' draggable="false">+</a>
				    {/if}
				    <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm02','{$fldname}','{$fldname}_name','customform02_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
            {elseif $uitype eq 503}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm03","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm03','{$fldname}','{$fldname}_name','customform03_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
            {elseif $uitype eq 504}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" name="{$fldname}_showmodule" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm04","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" name="{$fldname}_clear" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm04','{$fldname}','{$fldname}_name','customform04_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
            {elseif $uitype eq 505}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm05","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm05','{$fldname}','{$fldname}_name','customform05_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
         	{elseif $uitype eq 506}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm06","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm06','{$fldname}','{$fldname}_name','customform06_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
       		{elseif $uitype eq 507}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm07","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm07','{$fldname}','{$fldname}_name','customform07_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
       		{elseif $uitype eq 508}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm08","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm08','{$fldname}','{$fldname}_name','customform08_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
    		{elseif $uitype eq 509}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm09","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm09','{$fldname}','{$fldname}_name','customform08_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
    		{elseif $uitype eq 510}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","CustomForm10","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('CustomForm10','{$fldname}','{$fldname}_name','customform10_no','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 602}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","VendorContactRecords","select","","{$fldname}");' draggable="false">+</a>
					{*wym 240407 BUG20240221-26 供应商字段无法清除 fidname写错*}
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="this.form.{$fldname}_name.value=''; this.form.{$fldname}.value='';return false;" draggable="false">+</a>
				</td>
            {elseif $uitype eq 603}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Users","select","","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="this.form.{$fldname}_name.value='';this.form.{$fldname}.value='';return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 17}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input class='ld-input-inner' type="text" placeholder="{$fieldplaceholder}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" name="{$fldname}" size="27" onkeyup="validateUrl('{$fldname}');" value="{$fldvalue}">
				</td>
			{elseif $uitype eq 85}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}
						<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<!--
					更新操作
					edit：cdw
					date：20131212
					reason：0006196: 查看明细界面当传真、手机、QQ、邮件字段内容为空时，后面的图标按钮应该不显示，另外，网络电话不需要加图标，去掉文字上面的链接
					-->
					<input type="text" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" name="{$fldname}" class="ld-input-inner" size="27" value="{$fldvalue}">
				</td>
			{elseif $uitype eq 71 || $uitype eq 72}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if ($fldname eq "unit_price" || $fldname eq "procostprice") && $fromlink neq 'qcreate'}
						{if $fldname eq 'unit_price'}
							{assign var=base_currency value=$BASE_CURRENCY}
							{assign var=price_detail value=$PRICE_DETAILS}
							{assign var=price_detail_num value=$PRICE_DETAILS_NUM}
						{else}
							{assign var=base_currency value=$PROCOSTBASE_CURRENCY}
							{assign var=price_detail value=$PROCOSTPRICE_DETAILS}
							{assign var=price_detail_num value=$PROCOSTPRICE_DETAILS_NUM}
						{/if}
						<span id="multiple_currencies">
							<input name="{$fldname}" id="{$fldname}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" type="text" class="ld-input-inner ld-input-inner-add" onBlur="updateUnitPrice('{$fldname}', '{$base_currency}');"  value="{$fldvalue}" onkeyup="value=value.replace(/[^\d.]/g,'')">
							{*230726 wym XUQIU1000102 更多币种/参考成本价可以勾选是否批量编辑*}
							{if ($MASS_EDIT neq 1 && $price_detail_num gt 1 )|| ($MASS_EDIT eq 1 && $maindata['allowedit'] eq 'yes'&& $price_detail_num gt 1)}
                            {*zkt 20221010 BUG0057451产品，新建单据，图中的更多币种，不要最后一个箭头*}
							<a class="ld-text-select ld-text-select-text" href="javascript:void(0);" onclick="MoreCurrencySetPopup('{$base_currency}','{$fldname}');" {if
							$price_detail|count eq 1}style="display:none"{/if}  draggable="false">{'More_Currency'|@getFixedLabel}</a>
						{/if}
						</span>
						{if $MASS_EDIT neq 1 || ($MASS_EDIT eq 1 && $maindata['allowedit'] eq 'yes'&& $price_detail_num gt 1)}
						<div id="{$fldname}_currency_class" class="D_pop_box LdPopWidth650px" style="position:absolute; display:none;z-index:1000;width:50%">
							<input type="hidden" name="base_currency" id="base_currency" value="{$base_currency}" />
							<input type="hidden" name="base_conversion_rate" id="base_currency" value="{$base_currency}" />
							<input type="hidden" name="price_decimal" id="price_decimal" value="{$price_decimal}" />
							<div class="D_pop_tit">
								<strong class="D_ptita">{'PRODUCT_PRICES'|@getFixedLabel}</strong>
								<a href="javascript:MoreCurrencytoggleShowHide('multiple_currencies','{$fldname}_currency_class','{$fldname}');" class="D_ptitc">
									<img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
								</a>
							</div>
							<table class="D_pop_bod listEntries" border="0" cellpadding="0" cellspacing="1"  style="border-collapse:separate !important;">
								<tr>
									<th>{'Currency'|@getFixedLabel}{$MASS_EDIT}</th>
									<th>{'Price'|@getFixedLabel}</th>
									<th>{'CONVERSIONRATE'|@getFixedLabel}</th>
									<th>{'RPrice'|@getFixedLabel}</th>
									<th style="display:none">{'Base_Currency'|@getFixedLabel}</th>
								</tr>
									{foreach item=price key=count from=$price_detail}
										<tr>
											{if $price.check_value eq 1 || $price.is_basecurrency eq 1}
												{assign var=check_value value="checked"}
												{assign var=disable_value value=""}
											{else}
												{assign var=check_value value=""}
												{assign var=disable_value value="disabled=true"}
											{/if}

											{if $price.is_basecurrency eq 1}
												{assign var=base_cur_check value="checked"}
											{else}
												{assign var=base_cur_check value=""}
											{/if}

											{if $price.curname eq $base_currency}
												{assign var=call_js_update_func value="updateUnitPrice('$base_currency', '$fldname');"}
											{else}
												{assign var=call_js_update_func value=""}
											{/if}
										<td>
											{if $price.curid eq 1}
												<input type="checkbox" disabled="true" name="{$fldname}_cur_{$price.curid}_check" id="{$fldname}_cur_{$price.curid}_check" data-mass-edit-type="cur_display" onclick="fnenableDisable(this,'{$price.curid}','{$fldname}'); updateCurrencyValue(this,'{$price.curname}','{$fldname}','{$price.conversionrate}');" {$check_value}/>
												{$price.currencylabel|@getTranslatedCurrencyString} ({$price.currencysymbol})
											{else}
												<input type="checkbox" name="{$fldname}_cur_{$price.curid}_check" id="{$fldname}_cur_{$price.curid}_check" data-mass-edit-type="cur_display" onclick="fnenableDisable(this,'{$price.curid}','{$fldname}'); updateCurrencyValue(this,'{$price.curname}','{$fldname}','{$price.conversionrate}');" {$check_value}/>
												{$price.currencylabel|@getTranslatedCurrencyString} ({$price.currencysymbol})
											{/if}
											</td>
											<td>
												<input {$disable_value} type="text" fieldonly='{$fieldonly}' size="10" class="ld-input-inner" name="{$price.curname}" id="{$price.curname}" value="{$price.curvalue}" onBlur="{$call_js_update_func} fnpriceValidation('{$price.curname}');"/>
											</td>
											<td>
												<input disabled=true type="text" fieldonly='{$fieldonly}' size="10" class="ld-input-inner" name="{$fldname}_cur_conv_rate{$price.curid}" id="{$fldname}_cur_conv_rate{$price.curid}" value="{$price.conversionrate}"/>
											</td>
											<td>
												<input type="button" class="Anu3_a" id="cur_reset{$price.curid}" onclick="resetCurrencyValue(this,'{$price.curname}','{$fldname}','{$price.conversionrate}');" value="{'RePrice'|@getFixedLabel}"/>
											</td>
											<td style="display:none">
												<input {$disable_value} type="radio" class="ld-input-inner" id="base_currency{$price.curid}" name="base_currency_input" value="{$price.curname}" {$base_cur_check} onchange="updateBaseCurrencyValue()" />
											</td>
										</tr>
									{/foreach}
							</table>
							<div class="D_pbtn">
								<input class="D_pbtnok" type="button" onclick="MoreCurrencytoggleShowHide('multiple_currencies','{$fldname}_currency_class','{$fldname}')" value="{'SAVE'|@getFixedLabel}">
								<input class="D_pbtncancel" type="button" onclick="MoreCurrencytoggleShowHide('multiple_currencies','{$fldname}_currency_class','{$fldname}')" value="{'CANCEL'|@getFixedLabel}">
							</div>
						</div>
						{/if}
					{else}
						{if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '1'}
							<input name="{$fldname}" tabindex="{$vt_tab}" type="hidden" fieldonly='{$fieldonly}' class="ld-input-inner" value="{$fldvalue}">
							{$fldvalue}
						{else}
							<input {if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '1'} name="{$fldname}s" {else} name="{$fldname}" id='txtbox_{$fldname}'  {/if}tabindex="{$vt_tab}" type="text" fieldonly='{$fieldonly}' class="ld-input-inner" value="{$fldvalue}" style="color:{$fieldvaluecolor}">
						{/if}

					{/if}
				</td>
			{elseif $uitype eq 56}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $fldname eq 'edit_other_mobile' || $fldname eq 'setmenuprofileid' || $fldname eq 'edit_me_mobile' || $fldname eq 'is_mobile_style' || $fldname eq 'select_servicedetail' || $fldname eq 'select_due_date' || $fldname eq 'accountallview' || $fldname eq 'helpdesk_log'}
						<span>
							<!--BUG0068514 txy 2023.06.21 kfbcrm-成员管理-新建-角色与权限区块下字段前边的说明符号，鼠标放置上去没有浮显 -->
							{* <b class="icon-homeimg icon-askgrey-help tip-items-list" data-tip="{$fldname|@getFixedLabel}" data-direction="top" data-type="position"></b> *}
							<font color="red">{$mandatory_field}</font>{$usefldlabel}
						</span>
					{elseif $fldname eq 'view_quantity'}
						<span>
							{if 'Quotes'|@vtlib_isModuleActive eq 'true' && 'SalesOrder'|@vtlib_isModuleActive eq 'true'}
								<b title="{'Quotes'|@getTranstab}{'AND'|@getTranstab}{'SalesOrder'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
							{elseif 'Quotes'|@vtlib_isModuleActive eq 'true' && 'SalesOrder'|@vtlib_isModuleActive eq 'false'}
								<b title="{'Quotes'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
							{elseif 'Quotes'|@vtlib_isModuleActive eq 'false' && 'SalesOrder'|@vtlib_isModuleActive eq 'true'}
								<b title="{'SalesOrder'|@getTranstab}{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
							{else}
								<b title="{'showthetotalinventory'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
							{/if}
							<font color="red">{$mandatory_field}</font>{$usefldlabel}
						</span>
					{else}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{/if}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $fldname eq 'notime' && $ACTIVITY_MODE eq 'Events'}
					{if $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" onclick="toggleTime('{$fldname}')" checked>
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" tabindex="{$vt_tab}" type="checkbox" onclick="toggleTime('{$fldname}')" >
						</td>
					{/if}
				{elseif $fldname eq 'select_servicedetail'}
					{if $USEREDIT eq 'useredit' && $ALLSETROLEDATAPROFILE eq 'no'}
					<input type="hidden" name="select_servicedetail" value="{$fldvalue}"><font class="greyFont9" style="line-height: 150%;">
					{/if}
					{if $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled="true" {/if} checked class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')">&nbsp;
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" tabindex="{$vt_tab}" type="checkbox" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled="true" {/if} class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" >&nbsp;
						</td>
					{/if}
					</tr>
				{elseif $fldname eq 'select_due_date'}
					{if $USEREDIT eq 'useredit'&& $ALLSETROLEDATAPROFILE eq 'no'}
					<input type="hidden" name="select_due_date" value="{$fldvalue}">
					{/if}
					{if $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}"  {if $ALLSETROLEDATAPROFILE eq 'no'} disabled="true" {/if} class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" checked>&nbsp;
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" tabindex="{$vt_tab}" type="checkbox" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled="true" {/if} class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" >&nbsp;
						</td>
					{/if}
				{elseif ($fldname eq 'accountallview' ||$fldname eq 'level')&&$ALLSETROLEDATAPROFILE eq 'no'}
					 {if $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" disabled="true" checked class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')">&nbsp;<font class="greyFont9" style="line-height: 150%;">{'UsersALLOWQUERY'|@getFixedLabel}</font>
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" tabindex="{$vt_tab}" type="checkbox" disabled="true" class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" >
						</td>
					{/if}
				{elseif $fldname eq 'accountallview'}
					{if $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" class="Bornone input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" type="checkbox" tabindex="{$vt_tab}" checked>&nbsp;
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" class="Bornone input-btn-align second_switch" tabindex="{$vt_tab}" onclick="setFromCheckBox('{$fldname}')" type="checkbox" {if ( $PROD_MODE eq 'create' &&  $fldname|substr:0:3 neq 'cf_') ||( $fldname|substr:0:3 neq 'cf_' && $PRICE_BOOK_MODE eq 'create' ) }checked {else} value="0"{/if}>&nbsp;
						</td>
					{/if}
				{elseif $fldname eq 'campaignsview'}
				 {if $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" class="Bornone input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled=""{/if} type="checkbox" tabindex="{$vt_tab}" checked>&nbsp;
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" class="Bornone input-btn-align second_switch" tabindex="{$vt_tab}" onclick="setFromCheckBox('{$fldname}')" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled=""{/if} type="checkbox" {if ( $PROD_MODE eq 'create' &&  $fldname|substr:0:3 neq 'cf_') ||( $fldname|substr:0:3 neq 'cf_' && $PRICE_BOOK_MODE eq 'create' ) }checked {else} value="0"{/if}>&nbsp;
						</td>
					{/if}
                {elseif $fldname eq 'edit_other_mobile'}
					{if $USEREDIT eq  'useredit'&& $ALLSETROLEDATAPROFILE eq 'no'}
    					<input type="hidden" name="select_servicedetail" value="{$fldvalue}"><font class="greyFont9" style="line-height: 150%;">
    					{/if}

    					{if $fldvalue eq 1}
    						<td class="ld-form-item-content">
    							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled="true" {/if} checked class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')">&nbsp;
    						</td>
    					{else}
    						<td class="ld-form-item-content">
    							<input name="sel_{$fldname}" tabindex="{$vt_tab}" type="checkbox" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled="true" {/if} class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')" >&nbsp;
    						</td>
    					{/if}
				{elseif $fldname eq 'edit_me_mobile'}
					{if $fldvalue eq 1}
						<td class="ld-form-item-content">
							{if $USEREDIT == 'useredit' && $ALLSETROLEDATAPROFILE eq 'no'}
								{if $fldvalue eq "1"}
									<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" checked disabled="true" class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')">
								 {else}
									<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" disabled="true" class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')">
								 {/if}
								<input type="hidden" name="{$fldname}" value="{$fldvalue}"/>
							{else}
							  <input name="sel_{$fldname}" class="Bornone input-btn-align second_switch" type="checkbox" onclick="setFromCheckBox('{$fldname}')" tabindex="{$vt_tab}"  checked value="1">&nbsp;</span>
						   {/if}
						</td>
					{else}
						<td class="ld-form-item-content">
						  	{if $USEREDIT == 'useredit' && $ALLSETROLEDATAPROFILE eq 'no'}
								<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}"  disabled="true">
								<input type="hidden" name="{$fldname}" value="{$fldvalue}" class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')"/>
							{else}
								<input name="sel_{$fldname}" class="Bornone input-btn-align second_switch" tabindex="{$vt_tab}" onclick="setFromCheckBox('{$fldname}')" value="1" type="checkbox" {if  $PROD_MODE eq 'create' }checked{/if} onclick="setFromCheckBox('{$fldname}')">&nbsp;</span>
							    <input type="hidden" name="{$fldname}" value="{$fldvalue}"/>
                            {/if}
						</td>
					{/if}
					</tr>
				{else}
					{if $fldname eq 'scopeauthority'}
						<td class="ld-form-item-content">
							{if $ALLSETROLEDATAPROFILE eq 'no'}
								<input type="button" value="{'Configure'|@getFixedLabel}" name="password"  class="Anu3_a" title="{'Configure'|@getFixedLabel}">
							{else}
								<a href="javascript:;" onclick="ShowSetUeryScop({$ID});">{'DATASCOPESETTINGS'|@getFixedLabel}</a>
								<input type="hidden" name="ODuplicateID" id="ODuplicateID" value="{$ODuplicateID}"/>
								<input type="hidden" name="selectmode" id="selectmode" value=""/>
								<input type="hidden" name="selectRecord" id="selectRecord" value=""/>
								<input type="hidden" name="moduleRecord" id="moduleRecord" value=""/>
								<input type="hidden" name="modueltype" id="modueltype" value=""/>
                                <input type="hidden" name="viewothers" id="viewothers" value=""/>
                                <input type="hidden" name="viewcreateme" id="viewcreateme" value=""/>
                                <input type="hidden" name="editothers" id="editothers" value=""/>
                                <input type="hidden" name="editcreateme" id="editcreateme" value=""/>
                                <input type="hidden" name="delothers" id="delothers" value=""/>
                                <input type="hidden" name="viewselfbills" id="viewselfbills" value=""/>
							{/if}
						</td>
					{elseif $fldvalue eq 1}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" checked class="input-btn-align second_switch" onclick="setFromCheckBox('{$fldname}')">
						</td>
					{elseif $fldname eq 'filestatus'&& $MODE eq 'create'}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" type="checkbox" tabindex="{$vt_tab}" checked onclick="setFromCheckBox('{$fldname}')" class="input-btn-align second_switch">
							{assign var=fldvalue value="1"}
						</td>
					{else}
						<td class="ld-form-item-content">
							<input name="sel_{$fldname}" {if $fldvalue eq 1}checked{/if} class="second_switch" tabindex="{$vt_tab}" type="checkbox" value="0" onclick="setFromCheckBox('{$fldname}')">
							{if $fldname eq 'login_sms'}
						   		<font class="greyFont9" style="line-height: 150%;">{'NEEDBUYACCOUNT'|@getFixedLabel}</font>
						   	{/if}
						   	{if $fldname eq 'viewothers'}
								<font class="greyFont9" style="line-height: 150%;">{'VIEWTHEDETAILS'|@getFixedLabel}</font>
							{/if}
						</td>
					{/if}
				{/if}
				<input name="{$fldname}" id="{$fldname}" type="hidden" tabindex="{$vt_tab}" value="{$fldvalue}">
			{elseif $uitype eq 23 || $uitype eq 5 || $uitype eq 6}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small">{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{foreach key=date_value item=time_value from=$fldvalue}
						{assign var=date_val value="$date_value"}
						{assign var=time_val value="$time_value"}
					{/foreach}
				    {if $MODULE eq 'Accounts'}
						 {if $MODE eq 'edit'}
							{if $date_val neq ''}
								<input name="{$fldname}" class="Wdate ld-input-inner" autocomplete="off" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' type="text" style="color:{$fieldvaluecolor}" size="20" maxlength="10" value="{$date_val}" onClick="WdatePicker()">
							{else }
								<input name="{$fldname}" class="Wdate ld-input-inner" autocomplete="off" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' type="text" style="color:{$fieldvaluecolor}" size="20" maxlength="10" value="" onClick="WdatePicker()">
							{/if}
						 {else}
							<input name="{$fldname}" class="Wdate ld-input-inner" autocomplete="off" tabindex="{$vt_tab}" type="text" fieldonly='{$fieldonly}' style="color:{$fieldvaluecolor}" size="20" maxlength="10" value="{$date_val}" onClick="WdatePicker()">
						 {/if}
					{else}
						{if $VERSION_ACCOUNT eq 'hetao' && $fldname eq 'cf_4682'}
							<input onchange="hetao_date('{$fldname}',this.value)" name="{$fldname}" class="Wdate ld-input-inner" autocomplete="off" tabindex="{$vt_tab}" type="text" style="color:{$fieldvaluecolor}" fieldlabel="{$usefldlabel}"  fieldonly='{$fieldonly}' size="20" maxlength="10" value="{$date_val}" onClick="WdatePicker({ldelim}onpicked:function(){ldelim}datePickerChanged('{$fldname}'){rdelim}{rdelim});ld('.SearchResult').css('display','none')">
						{else}
							<input name="{$fldname}" class="Wdate ld-input-inner" autocomplete="off" tabindex="{$vt_tab}" type="text" style="color:{$fieldvaluecolor}" fieldlabel="{$usefldlabel}" fieldonly='{$fieldonly}' size="20" maxlength="10" value="{$date_val}" onClick="WdatePicker({ldelim}onpicked:function(){ldelim}datePickerChanged('{$fldname}'){rdelim}{rdelim});ld('.SearchResult').css('display','none')">
						{/if}
					{/if}
					{if $uitype eq 6}
						{if $MODULE eq 'Reminds'}
						{$STARTHOUR}
						{else}
						<input name="time_start" tabindex="{$vt_tab}" style="border:1px solid #dbdbdb;" size="5" maxlength="5" type="text" fieldonly='{$fieldonly}' value="{$time_val}">
						{/if}
					{/if}
					{if $uitype eq 6 && $QCMODULE eq 'Event'}
						<input name="dateFormat" type="hidden" value="{$dateFormat}">
					{/if}
					{if $uitype eq 23 && $QCMODULE eq 'Event'}
						<input name="time_end" style="border:1px solid #dbdbdb;" size="15" maxlength="5" type="text"  fieldonly='{$fieldonly}'  value="{$time_val}">
					{/if}
					{foreach key=date_format item=date_str from=$secondvalue}
						{assign var=dateFormat value="$date_format"}
						{assign var=dateStr value="$date_str"}
					{/foreach}
				</td>
			{elseif $uitype eq 63}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="text"  fieldonly='{$fieldonly}' size="2" value="{$fldvalue}" tabindex="{$vt_tab}" >
					<select name="duration_minutes" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
						{foreach key=labelval item=selectval from=$secondvalue}
							<option value="{$labelval}" {$selectval}>{$labelval}</option>
						{/foreach}
					</select>
			{elseif $uitype eq 68 || $uitype eq 66 || $uitype eq 62}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $uitype eq 68}
						<font color="red">{$mandatory_field}</font>{$fldlabel.displaylabel}
					{/if}
					{if $fromlink eq 'qcreate'}
						<select class="ld-select-inner" name="parent_type" onChange='document.QcEditView.parent_name.value=""; document.QcEditView.parent_id.value=""' fieldonly='{$fieldonly}'>
					{else}
						<select class="ld-select-inner" fieldonly='{$fieldonly}' name="parent_type" onChange='document.EditView.parent_name.value=""; document.EditView.parent_id.value=""'>
					{/if}
						{section name=combo loop=$fldlabel}
							{if $fldlabel_combo[combo] neq ""}
								<option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]}>{$fldlabel[combo]} </option>
							{/if}
						{/section}
					</select>
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="parent_id_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<input name="parent_name" readonly id = "parentid" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					{if $fromlink eq 'qcreate'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module="+ document.QcEditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");' draggable="false">+</a>
					{else}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module="+ document.EditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");' draggable="false">+</a>
					{/if}
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','parent_id','parent_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 357}
				<td class="ld-form-item-label" style="{$label_style}">To:&nbsp;</td>
				<td class="ld-form-item-content" colspan="3">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<textarea class="ld-textarea-inner" readonly name="parent_name" style="height:50px">{$fldvalue}</textarea>&nbsp;
					<select name="parent_type" class="ld-select-inner" fieldonly='{$fieldonly}'>
						{foreach key=labelval item=selectval from=$fldlabel}
							<option value="{$labelval}" {$selectval}>{$labelval}</option>
						{/foreach}
					</select>
					&nbsp;
					{if $fromlink eq 'qcreate'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module="+ document.QcEditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");' draggable="false">+</a>
					{else}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='return window.open("index.php?module="+ document.EditView.parent_type.value +"&action=Popup&html=Popup_picker&form=HelpDeskEditView&fromlink={$fromlink}","test","width=840,height=602,resizable=1,scrollbars=1,top=150,left=200");' draggable="false">+</a>
					{/if}
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','parent_id','parent_name','','{$MODULE}','popupselectfield'); return false;" draggable="false">+</a>
				</td>
				</tr>
				<tr style="height:25px">
					<td class="ld-form-item-label" style="{$label_style}">CC:&nbsp;</td>
					<td class="ld-form-item-content">
						<input name="ccmail" type="text" fieldonly='{$fieldonly}' class="ld-input-inner" value="">
					</td>
					<td class="ld-form-item-label" style="{$label_style}">BCC:&nbsp;</td>
					<td class="ld-form-item-content">
						<input name="bccmail" type="text" fieldonly='{$fieldonly}' class="ld-input-inner" value="">
					</td>
				</tr>
			{elseif $uitype eq 59}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<input name="{$fldname}_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","Products","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('Products','{$fldname}','{$fldname}_name','productname','{$MODULE}','popupselectfield'); return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 55 || $uitype eq 255}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $uitype eq 55 }
						{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{elseif $uitype eq 255 && $fldvalue eq ''}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $fldname == 'salutationtype'}
						<select name="salutationtype" class="ld-select-inner" fieldonly='{$fieldonly}'>
							{foreach item=arr from=$fldvalue}
							<option value="{$arr[1]}" {$arr[2]}>
							{$arr[0]}
							</option>
							{/foreach}
						</select>
					{else}
						<input type="text" name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' class="ld-input-inner" value="{$secondvalue}" {if $BUSINESSFUZZYQUERY eq 'yes' && $BUSINESSQUERY eq 'yes'}onkeyup="getTianyanByKeyWord(this,1,'{$MODULE}',event)" onfocus="getTianyanSearchInfo(this,1,'{$MODULE}',event)" onkeypress="userEnterKey(getTianyanByKeyWord,[this,1,'{$MODULE}',event],event)"{/if}>
					{/if}
					{* 工商查询 *}
					{if $ENABLEBUSINESS eq 'yes' && $BUSINESSQUERY eq 'yes'}
						<i id="business_{$fldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang" onclick="getTianyanByKeyWordForInfo('{$fldname}','edit');"></i>
					{/if}
					{if $BUSINESSFUZZYQUERY eq 'yes'}
						<div name="check_kewords" class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
					{/if}
				</td>
			{elseif $uitype eq 22}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<textarea class="ld-textarea-inner" name="{$fldname}" tabindex="{$vt_tab}" fieldonly='{$fieldonly}' style="height:50px">{$fldvalue}</textarea>
				</td>
			{elseif $uitype eq 14}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="text" tabindex="{$vt_tab}" size='13' fieldonly='{$fieldonly}' name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="Wdate ld-input-inner" onClick="WdatePicker({ldelim}dateFmt:'HH:mm:ss'{rdelim});" style="color:{$fieldvaluecolor}">
				</td>
			{elseif $uitype eq 61}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}
						<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small"  disabled >
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="file" value="{$secondvalue}" tabindex="{$vt_tab}" onchange="validateFilename(this)"/>
					<input type="hidden" name="{$fldname}_hidden" value="{$secondvalue}"/>
					<input type="hidden" name="id" value=""/>{$fldvalue}
				</td>
			{elseif $uitype eq 156}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" {if in_array("1",";"|explode:$IDS) || $CURRENT_USERID  neq 1}disabled{/if}>{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $fldvalue eq 'on'||$fldvalue eq 1}
					<td class="ld-form-item-content">
						{*$smarty.request.record 为1  是超级管理员，任何权限都不能编辑*}
						{if $CURRENT_USERID  eq 1 && ($CURRENT_USERID != $smarty.request.record)}
							<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" checked class="second_switch">
						{else}
							<input name="{$fldname}" type="hidden" value="on">
							<input name="{$fldname}" disabled tabindex="{$vt_tab}" type="checkbox" checked class="second_switch">
						{/if}
					</td>
				{else}
					<td class="ld-form-item-content">
						{if $MASS_EDIT eq '1'}
							<input name="{$fldname}" {if in_array("1",";"|explode:$IDS) || $CURRENT_USERID  neq 1}disabled{/if} tabindex="{$vt_tab}" type="checkbox" class="second_switch">
						{else}
							{if $CURRENT_USERID  eq 1}
								<input name="{$fldname}" tabindex="{$vt_tab}" type="checkbox" class="second_switch">
							{else}
								<input name="{$fldname}" disabled tabindex="{$vt_tab}" type="checkbox" class="second_switch">
							{/if}
						{/if}
					</td>
				{/if}
			{elseif $uitype eq 98}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $thirdvalue eq 1}
						<select id="{$fldname}" {if $ALLSETROLEDATAPROFILE eq 'no'} disabled {/if} name="{$fldname}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="ld-select-inner" style="display: none;">
						{foreach item=arr key=uivalueid from=$secondvalue}
							{foreach key=sel_value item=value from=$arr}
								<option value="{$uivalueid}" {$value}>{$sel_value}</option>
							{/foreach}
						{/foreach}
					   </select>
					{else}
						<input name="role_name" id="role_name" tabindex="{$vt_tab}"  fieldonly='{$fieldonly}' class="txtBox" readonly value="{$secondvalue}" type="text">&nbsp;
					{/if}
					<input name="user_role" id="user_role" value="{$fldvalue}" type="hidden">
					{*wyt 221216 BUG0059261 kfbcrm 成员管理页面---角色权限字段---下拉框样式做成与审批委托字段一致*}
					{foreach item=arr from=$secondvalue}
					{foreach key=sel_value item=value from=$arr}
						{if $value eq 'selected'}
							{assign var="optText" value=$sel_value}
						{/if}
					{/foreach}
					{/foreach}
					<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
						{if  $ISADMIN eq 'off' && $ALLSETROLEDATAPROFILE eq 'no'}
							<a class="chzn-single" onclick="" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
						{else}
							<a class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
						{/if}
								<input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
								<input name="{$fldname}" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
								<div>
									<b></b>
								</div>
							</a>
							<div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_{$fldname}' >
								<ul class="chzn-results" name="cmb_ul_{$fldname}">
									{assign var="i" value=0}
									{foreach item=arr key=uivalueid from=$secondvalue}
										{foreach key=sel_value item=value from=$arr}
											<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$uivalueid}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$sel_value}</li>
											{assign var="i" value=$i+1}
										{/foreach}
									{/foreach}
									<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
								</ul>
							</div>
					</div>
				</td>
			{elseif $uitype eq 104}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
				 	<input type="text" fieldonly='{$fieldonly}' name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" tabindex="{$vt_tab}" class="ld-input-inner">
				</td>
			{elseif $uitype eq 115}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODULE eq 'Users' && $fldname eq 'status' && $MODE eq 'edit' && $AUTHTYPE eq 'yes'}<!--企业微信功能变动-->
						{foreach item=arr from=$fldvalue}
							{if $arr[2] == 'selected'}
								{assign var="user_status" value="{$arr[0]}"}
								<input type="hidden" name="{$fldname}" id="user_status"  value="{$arr[1]}"/>
							{/if}
						{/foreach}
						{$user_status}
					{else}
					   	{if $CURRENT_USERID != $smarty.request.record}
							<select id="user_status" name="{$fldname}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="ld-select-inner" style="display: none;">
					   	{else}
							<select id="user_status" disabled name="{$fldname}" class="ld-select-inner" fieldonly='{$fieldonly}' style="display:none;">
					   	{/if}
						{foreach item=arr from=$fldvalue}
							<option value="{$arr[1]}" {$arr[2]} >
								{$arr[0]}
							</option>
						{/foreach}
					   </select>

						{*wyt 221216 BUG0059259 kfbcrm 成员管理界面---状态字段---下拉框样式做成和审批委托字段一致*}
						{foreach item=arr from=$fldvalue}
							{if $arr[2] eq 'selected'}
								{assign var="optText" value=$arr[0]}
							{/if}
						{/foreach}
						<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}')">
							{if  $ISADMIN eq 'off'}
							<a class="chzn-single" onclick="" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
								{elseif $smarty.request.record neq 1}
								<a class="chzn-single" onclick="com_img_change(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
									{else }
									<a class="chzn-single" onclick="" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}" draggable="false" >
										{/if}
										<input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0" name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}')" onKeyUp="com_chosen(event,'{$fldname}')" value="{$optText}">
										<input name="{$fldname}" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
										<div>
											<b></b>
										</div>
									</a>
									<div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_{$fldname}' >
										<ul class="chzn-results" name="cmb_ul_{$fldname}">
											{assign var="i" value=0}
											{foreach item=arr from=$fldvalue name=foo}
												<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[1]}','{$fldname}')" onmouseover="cmb_limouseover(event,'{$fldname}')">{$arr[0]}</li>
												{assign var="i" value=$i+1}
											{/foreach}
											<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
										</ul>
									</div>
						</div>
					{/if}

				</td>
			{elseif $uitype eq 111105}
				<td class="ld-form-item-label" style="{$label_style}">
					<b title="{'ONLYJPGGIFIMG'|@getFixedLabel}" class="icon-homeimg icon-askgrey-help"></b>
					<font color="red">{$mandatory_field}</font>{$usefldlabel}{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" style="height: 50px">
					{if $MODE eq 'edit' && $IMAGENAME neq ''}
						<input name="{$fldname}" type="file" value="{$maindata[3].0.name}" tabindex="{$vt_tab}" onchange="validateFilename(this);" />
						<div id="replaceimage">[{$IMAGENAME}]&nbsp;<a href="javascript:;" onClick="delUserImage({$ID})">{'DELETE'|@getFixedLabel:$MODULE}</a></div>
						<input name="{$fldname}_hidden" type="hidden" value="{$maindata[3].0.name}" />
					{else}
						<input name="{$fldname}" type="file" value="{$maindata[3].0.name}" tabindex="{$vt_tab}" onchange="validateFilename(this);" />
							<input name="{$fldname}_hidden" type="hidden" value="{$maindata[3].0.name}" />
					{/if}
					<input type="hidden" name="id" value=""/>
					{$maindata[3].0.name}
				</td>
			{elseif $uitype eq 103}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="text" name="{$fldname}" value="{$fldvalue}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="ld-input-inner">
				</td>
			{elseif $uitype eq 101}
				<td class="ld-form-item-label" style="{$label_style}">
				  	<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input id="{$fldname}_name" name="{$fldname}_name" fieldonly='{$fieldonly}' readonly type="text" class="ld-input-inner ld-input-inner-add" value="{$fldvalue}" />
					<input id="{$fldname}" name="{$fldname}" type="hidden" value="{$secondvalue}" id="{$fldname}" />
					<a class="ld-text-select" href="javascript:;" title="{$APP.LBL_CHANGE_TITLE}" onclick='return window.open("index.php?module=Users&action=Popup&html=Popup_picker&form=vtlibPopupView&form_submit=false&fromlink={$fromlink}&recordid={$ID}&forfield={$fldname}","test","width=840,height=603,resizable=1,scrollbars=1");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield'); return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 116 || $uitype eq 117}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '1'}
						<input type="hidden" value="{$CURRENCYID}" name="currency_id" id="currency_id" />
						{foreach item=arr key=uivalueid from=$fldvalue}
							{foreach key=sel_value item=value from=$arr}
								{if $uivalueid eq $CURRENCYID}
									{$sel_value|@getTranslatedCurrencyString}
								{/if}
							{/foreach}
						{/foreach}
					{else}
						{if $secondvalue eq 1 || $uitype eq 117}
							{*chj:币种字段，添加隐藏属性，标示当前的币种ID。 当前模块如果是银行账户，则初始化后，不能修改*}
							{if $fldname eq 'currency_id'}
								<input type="hidden" value="{if $CYID eq ''}{$CURRENCYID}{/if}{$CYID}" name="hidden_currency_id" id="hidden_currency_id" />
								{if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '1'}
									<input type="hidden" value="{$CURRENCYID}" name="currency_id" id="currency_id" />
								{/if}
								<input type="hidden" value="{$CONVERSIONRATE}" name="hidden_currency_rate" id="hidden_currency_rate" />
                                <input type="hidden" value="no" name="currency_id_from_related" id="currency_id_from_related" />
								<select {if $MODULE eq 'BankAccountSet' && $CONFIRMEDST eq '1'} disabled {/if} name="{$fldname}" tabindex="{$vt_tab}" onchange="getCurrencyRateAmount(this,'{$MODULE}',0,'{$formname}');" class="ld-select-inner" fieldonly='{$fieldonly}'>
							{else}
								<select name="{$fldname}" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
							{/if}
						{else}
							<select disabled name="{$fldname}" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
						{/if}
								{foreach item=arr key=uivalueid from=$fldvalue}
									{foreach key=sel_value item=value from=$arr}
										{*bug 0015368 服务合同>明细：关联创建佣金单、费用报销，币种默认值不是服务合同的币种 zyh 20150610*}
										<option value="{$uivalueid}" {$value} {if $uivalueid eq $CYID} selected {/if}>{$sel_value|@getTranslatedCurrencyString}</option>
										{if $value eq 'selected' && $secondvalue neq 1}
											{assign var="curr_stat" value="$uivalueid"}
										{/if}
									{/foreach}
								{/foreach}
						    </select>
						{if $curr_stat neq '' && $uitype neq 117}
							<input name="{$fldname}" type="hidden" value="{$curr_stat}">
						{/if}
					{/if}
				</td>
			{elseif $uitype eq 106}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODE eq 'edit'}
					<input type="hidden" name="{$fldname}" value="{$fldvalue}" >{$fldvalue}
					{else}
						{if $VERSION_ACCOUNT eq 'baxter' && $MODULE eq 'Users'}
							<input type="text" name="{$fldname}" value="{$fldvalue}" onkeyup="getRelatedOktaUser(this,event)" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="ld-input-inner">
						{else}
							<input type="text" name="{$fldname}" value="{$fldvalue}" fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="ld-input-inner">
						{/if}
					{/if}
				</td>
			{elseif $uitype eq 99}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				{if $MODE eq 'create'|| $showpageruledisp_view eq 'create_view'}
					<td class="ld-form-item-content">
						<input type="password" name="{$fldname}" tabindex="{$vt_tab}" value="{$fldvalue}" class="ld-input-inner">
					</td>
				{else}
					<td class="ld-form-item-content">{$CHANGE_PW_BUTTON}</td>
				{/if}
			{elseif $uitype eq 79}<!--服务单 - 选择常见问题 -->
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					<input name="{$fldname}_name" readonly type="text" size="20" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" tabindex="{$vt_tab}" onclick='showrelatedspeciallists("{$MODULE}","Faq","select","{$POPUPBUTTON}","{$fldname}");' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','{$fldname}_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
				</tr>
			{elseif $uitype eq 30}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content" colspan="3">
					{assign var=check value=$secondvalue[0]}
					{assign var=yes_val value=$secondvalue[1]}
					{assign var=no_val value=$secondvalue[2]}
					<input type="radio" name="set_reminder" tabindex="{$vt_tab}" value="Yes" {$check}>&nbsp;{$yes_val}&nbsp;
					<input type="radio" name="set_reminder" value="No">&nbsp;{$no_val}&nbsp;
					{foreach item=val_arr from=$fldvalue}
						{assign var=start value="$val_arr[0]"}
						{assign var=end value="$val_arr[1]"}
						{assign var=sendname value="$val_arr[2]"}
						{assign var=disp_text value="$val_arr[3]"}
						{assign var=sel_val value="$val_arr[4]"}
						<select name="{$sendname}" class="ld-select-inner" fieldonly='{$fieldonly}'>
							{section name=reminder start=$start max=$end loop=$end step=1 }
								{if $smarty.section.reminder.index eq $sel_val}
									{assign var=sel_value value="SELECTED"}
								{else}
									{assign var=sel_value value=""}
								{/if}
								<OPTION VALUE="{$smarty.section.reminder.index}" "{$sel_value}">{$smarty.section.reminder.index}</OPTION>
							{/section}
						</select>
						&nbsp;{$disp_text}
					{/foreach}
				</td>
				</tr>
			{elseif $uitype eq 26}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$fldlabel} {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<select name="{$fldname}" tabindex="{$vt_tab}" class="ld-select-inner" fieldonly='{$fieldonly}'>
						{foreach item=v key=k from=$fldvalue}
						<option value="{$k}">{$v}</option>
						{/foreach}
					</select>
					<!--18/04/26 bug0033781 Liver知识管理 文件夹 字段不需要编辑下拉框按钮-->
					{if $fldname neq 'folderid' && $MODULE neq 'Documents'}
						<b onclick="getFolderCombox()" title="{'SETTINGS'|@getFixedLabel}" class="icon-homeimg icon-setgrey marT6 marL5" style="cursor:pointer;"></b>
					{/if}
				</td>
			{elseif $uitype eq 400}{*edit:can; reason:费用报销-》票据张数 other:正整数*}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$fldlabel}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
			  		<input type='text' name="{$fldname}" value="{$fldvalue}" positive ='1' fieldonly='{$fieldonly}' tabindex="{$vt_tab}" class="ld-input-inner">
				</td>
			{elseif $uitype eq 27}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$fldlabel_other}
					{if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}" id="{$fldname}_mass_edit_check" class="ld-input-inner" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="text" id="hidetext" name="hidetext" value="{$maindata[3][1]}" style="display:none;"/>
					<select class="ld-select-inner" fieldonly='{$fieldonly}' name="{$fldname}" id="{$fldname}" onchange="changeDldType((this.value=='I')? 'file': 'text');">
						{section name=combo loop=$fldlabel}
						{if $fldlabel[combo] eq '内部'}
						<option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]} >{'Attachment'|@getFixedLabel}</option>
						{elseif $fldlabel[combo] eq '外部'}
						 <option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]} >{'LINK'|@getFixedLabel}</option>
						{else}
						<option value="{$fldlabel_combo[combo]}" {$fldlabel_sel[combo]} >{$fldlabel[combo]|@getFixedLabel}</option>
						{/if}
						{/section}
					</select>
					<script>
						function lingdang_{$fldname}Init(){ldelim}
							var d = document.getElementsByName('{$fldname}')[0];

							var type = (d.value=='I')? 'file': 'text';

							changeDldType(type, true);
						{rdelim}
						if(typeof window.onload =='function'){ldelim}
							var oldOnLoad = window.onload;
							document.body.onload = function(){ldelim}
								lingdang_{$fldname}Init();
								oldOnLoad();
							{rdelim}
						{rdelim}else{ldelim}
							window.onload = function(){ldelim}
								lingdang_{$fldname}Init();
							{rdelim}
						{rdelim}

					</script>
				</td>
			{elseif $uitype eq 28 ||$uitype eq 1109 ||
				($uitype eq 69&&$MODULE|@get_file_address:'ProductDetails' neq 'true'&& $MODULE|get_file_address:$MODULE|cat:'DetailFieldsHtml' neq 'true' )}
			  	<tr>
					<td class="ld-form-item-label" style="{$label_style}">
						{* <b tag="attachmentHelp_{$uitype}" class="icon-homeimg icon-askgrey-help"></b> *}
						<font color="red">{$mandatory_field}</font>{$fldlabel}
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content ld-form-item-content-second" colspan="3">
						<div name="{$fldname}_I__" style="display:">
							<input type="hidden" name="I_file_filename" id="I_file_filename" value="{$fldvalue}" />
							{assign var=FINALDETAIL value=$MODULE|cat:'DetailFieldsHtml'}
							{if  $MODULE|@get_file_address:'ProductDetails' eq 'true' || $MODULE|get_file_address:$FINALDETAIL eq 'true' || $MODULE eq 'Users'}
						     	{if $PAGEMODE eq 'showpagerule'}
                                    {assign var=JSONDATA value=$ALLFILEJSONDATA[$uitype]}
                                {else}
                                    {assign var=JSONDATA value=$ID|getAttachmentsTableInfo:$MODULE:$fldname}
                                {/if}
								{include file='File_Uploader.tpl'}
							{else}
								<div name="{$fldname}" class="wu-example">
								</div>
							{/if}
						</div>
					  	{if $uitype eq 28}
							<input type="text" name="{$fldname}_E__" class="ld-input-inner" value="{$maindata[3][1][0]}" style="display:none"/>
						{/if}
					</td>
				</tr>
		  	{elseif $uitype eq 69 || $uitype eq 105}
		  		<tr>
					<td class="ld-form-item-label" style="{$label_style}">
						{*wyt 220906 BUG0056019 在合同订单，编辑so106，图片字段没有提示信息，希望能有一个类似附件添加的提示*}
						{* {if $uitype eq 69}<b tag="attachmentHelp_{$uitype}"  class="icon-homeimg icon-askgrey-help"></b>{/if} *}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						{if $MASS_EDIT eq '1'}
							<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small"  >
						{/if}
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content table_img_display" colspan="3">
						<input name="del_file_list" type="hidden" value="">
						<div id="files_list">
							{if $PAGEMODE eq 'showpagerule'}
	                            {assign var=JSONDATA value=$ALLFILEJSONDATA[$uitype]}
	                        {else}
	                            {assign var=JSONDATA value=$ID|getImageFileInfo:$MODULE}
	                        {/if}

							{include file='File_Uploader.tpl'}
						</div>
					</td>
				</tr>
		   	{elseif $uitype eq 1108}
				<tr style="height:25px">
					<td class="ld-form-item-label" style="{$label_style}">
						{* <div><b tag="attachmentHelp_{$uitype}" class="icon-homeimg icon-askgrey-help"></b> *}
						<font color="red">{$mandatory_field}</font>{$fldlabel}</div>
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content" colspan="3">
						{include file='File_Uploader.tpl'}
					</td>
				</tr>
			{elseif $uitype eq 83} <!-- Handle the Tax in Inventory -->
				{foreach item=tax key=count from=$TAX_DETAILS}
					{if $tax.check_value eq 1}
						{assign var=check_value value="checked"}
						{assign var=show_value value="visible"}
					{else}
						{assign var=check_value value=""}
						{assign var=show_value value="hidden"}
					{/if}
					<td class="ld-form-item-label" style="{$label_style}">
						{$tax.taxlabel} ({'PERCENT'|@getFixedLabel})
						{include file='Helptips.tpl'}
					</td>
					<td class="ld-form-item-content">
						<input type="checkbox" name="{$tax.check_name}" id="{$tax.check_name}" class="small" onclick="fnshowHide(this,'{$tax.taxname}')" {$check_value}>
						<input type="text" class="ld-input-inner" fieldonly='{$fieldonly}'  name="{$tax.taxname}" id="{$tax.taxname}" value="{$tax.percentage}" style="visibility:{$show_value};width:50%;" onBlur="fntaxValidation('{$tax.taxname}')">
					</td>
				   </tr>
				{/foreach}
			{elseif $uitype eq 150}{*date:2013-10-31  edit:chj  reson:采购订单表单信息*}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $PURCHASEORDERID >0 && ($MODULE == 'Stock' || $MODULE == 'PurchaseBack')}
						<input name="{$fldname}_name" id="purchaseorder_name" readonly type="text" fieldonly='{$fieldonly}' value="{$PURCHASEORDERNAME}" class="ld-input-inner ld-input-inner-add" >
						<input name="{$fldname}" id="{$fldname}" type="hidden" value="{$PURCHASEORDERID}">
					{else}
						<input name="purchaseorder_name" id="purchaseorder_name" readonly type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add" >
						<input name="purchaseorder_id" id="purchaseorder_id" type="hidden" value="{$secondvalue}">
					{/if}
					{if $MODULE neq 'PurchaseBack'}
						{if $fromlink eq 'qcreate'}
							<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}"
							 onclick='return window.open("index.php?module=PurchaseOrder&action=Popup&html=Popup_picker&form=vtlibPopupView&form_submit=false&fromlink={$fromlink}&frommodule=","test","width=840,height=603,resizable=1,scrollbars=1");' draggable="false">+</a>
						{else}
							<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectPurchaseOrder('{$MODULE}')" draggable="false">+</a>
						{/if}
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="this.form.purchaseorder_id.value='';this.form.purchaseorder_name.value='';clear_relatedfielddata('','purchaseorder_id','purchaseorder_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{/if}
				</td>
				<script type="text/javascript">
				function open_form_specific(module,pop_type, fromlink)
				{ldelim}
						var vendor = document.getElementById('vendor_id').value;
						return window.open("index.php?module=PurchaseOrder&action=Popup&html=Popup_picker&select=enable&popuptype="+pop_type+"&form=EditView&fromlink="+fromlink+"&vendorid="+vendor+"&frommodule="+module,"test","width=840,height=602,resizable=1,scrollbars=1");
				{rdelim}
				</script>
			{elseif $uitype eq 151}{*date:2013-10-31  edit:chj  reson:仓库信息*}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{if $MASS_EDIT eq '1'}
						<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small"  >
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $MODULE neq 'Checks'}
						{if $VERSIONINFO.account eq 'zhongneng' && ($MODULE eq 'Quotes' || $MODULE eq 'Invoice' || $MODULE eq 'OutboundOrder' || $MODULE eq 'SalesOrder' || $MODULE eq 'QuotesChange')}
							<select name="{$fldname}" id="{$fldname}" onchange="getWareProductQty(this)" class="ld-select-inner" style="display:none;">
						{else}
							<select name="{$fldname}" id="{$fldname}" class="ld-select-inner" style="display:none;">
						{/if}
					{else}
						<select name="{$fldname}" id="{$fldname}" onchange="setProductQtyInstock(this)" class="ld-select-inner" style="display:none;">
					{/if}
					{foreach item=value key=key from=$WAREALL}
						<option value="{$key}" {if $value == $fldvalue}selected{/if}>{$value}</option>
					{/foreach}
					</select>
                    {*zkt 0046722: （81mis.com/kfbcrm）库存管理-入库单，新建入库单，没有选择仓库，保存没有提示仓库必填；保存后显示了当前成员可用的第一个仓库*}
                    {*未设置仓库默认值时，默认显示第一个仓库*}
                    {*zkt 20230106 BUG0060479入库批量编辑仓库无法选择*}
                    {assign var="tmp_151_parentdivid" value="div_pagerecord"}
                    {if $MASS_EDIT eq '1' || $MINI_EDIT eq '1'}
                        {assign var="tmp_151_parentdivid" value=""}
                    {/if}
                    <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','{$tmp_151_parentdivid}')">
                 	      	<a class="chzn-single" onclick="com_img_change(event,'{$fldname}','{$tmp_151_parentdivid}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
    					       <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0" name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','{$tmp_151_parentdivid}')" onKeyUp="com_chosen(event,'{$fldname}','{$tmp_151_parentdivid}')" value="{if $fldvalue eq ''}{reset($WAREALL)}{else}{$fldvalue}{/if}">
                               <div>
                                    <b></b>
                               </div>
    	                  	</a>
	            	       <div style="left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_{$fldname}' >
	            			 <ul class="chzn-results" name="cmb_ul_{$fldname}">
	                            {assign var="i" value=0}
	        	                {foreach item=value key=key from=$WAREALL}
	         	                    <li class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$key}','{$fldname}','{$tmp_151_parentdivid}')" onmouseover="cmb_limouseover(event,'{$fldname}','{$tmp_151_parentdivid}')">{$value}</li>
	           	                    {assign var="i" value=$i+1}
	                            {/foreach}
	                            <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
	            			 </ul>
	            	       </div>
	                </div>
					<input type="hidden" name="old{$fldname}" value="{$fldvalue}"/>
					{if $MODULE eq 'Checks'}
						<a href="javascript:void(0);" style="margin-left: 15px;line-height: 28px;" onclick="InstantInventory('{$MODULE}')" id="input_check_products">{'intheinstankinventory'|@getFixedLabel}</a>
					{/if}
				</td>
			{elseif $uitype eq 1101}
				<!--
				更新操作
				edit:cdw
				date:20131119
				reason:0005674: 新增单据自定义字段((手机、传真或QQ)，设置新增字段为“必填字段”，保存后，新增单据，结果必填字段没有显示红色*。
				-->
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
					   <font color="red">{$mandatory_field}</font>{$usefldlabel}
					   {if $MASS_EDIT eq '1'}
					   <input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" style="color:{$fieldvaluecolor}"/>
					   {/if}
					{else}
					   {$usefldlabel}
					   {if $MASS_EDIT eq '1'}
					   <input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" style="color:{$fieldvaluecolor}"/>
					   {/if}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
				  	{if $CALLPHONE neq ""}
				   		<input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$CALLPHONE}" class="ld-input-inner" style="color:{$fieldvaluecolor}"/>
				   		<input fieldonly='{$fieldonly}' type="hidden" tabindex="{$vt_tab}" name="hdd_{$fldname}" id ="hdd_{$fldname}" value="{$secondvalue}" class="ld-input-inner" style="color:{$fieldvaluecolor}"/>
				  	{else}
				   		<input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner" style="color:{$fieldvaluecolor}"/>
				   		<input fieldonly='{$fieldonly}' type="hidden" tabindex="{$vt_tab}" name="hdd_{$fldname}" id ="hdd_{$fldname}" value="{$secondvalue}" class="ld-input-inner" style="color:{$fieldvaluecolor}"/>
				  	{/if}
				</td>
			{elseif $uitype eq 1102 || $uitype eq 1103}
				<!--
				更新操作
				edit:cdw
				date:20131119
				reason:0005674: 新增单据自定义字段((手机、传真或QQ)，设置新增字段为“必填字段”，保存后，新增单据，结果必填字段没有显示红色*。
				-->
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
					   	<font color="red">{$mandatory_field}</font>{$usefldlabel}
					   	{if $MASS_EDIT eq '1'}
					   		<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" />
					   	{/if}
					{else}
					   	{$usefldlabel}
					   	{if $MASS_EDIT eq '1'}
					   		<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" class="small" />
					   	{/if}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
				  	<input fieldonly='{$fieldonly}' type="text" tabindex="{$vt_tab}" name="{$fldname}" id ="{$fldname}" value="{$fldvalue}" class="ld-input-inner"/>
				</td>
			{elseif $uitype eq 200 && $MODULE_ACTIVATE == true}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						<input type="hidden" name="salesordertypeofdata" id="salesordertypeofdata" value="{$typeofdata}" />
					{else}
						{$usefldlabel}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="hidden" name="selectlistval" id="selectlistval" value="{$LISTALLVAL}" />
					<input readonly type="text" id="salesorder_id" name="salesorder_id" class="ld-input-inner ld-input-inner-add" value="{$LISTVAL_PURCHASEORDER_NO}" />
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="originBill_select('{$MODULE}');" draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleProduct(this,'{$MODULE}','{$PRODUCTCONTENT}'); return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 204 && $MODULE_ACTIVATE == true}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						<input type="hidden" name="salesordertypeofdata" id="salesordertypeofdata" value="{$typeofdata}" />
					{else}
						{$usefldlabel}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="hidden" name="selectlistval" id="selectlistval" value="{$LISTALLVAL}" />
					<input readonly type="text" id="salesorder_id" name="salesorder_id" class="ld-input-inner ld-input-inner-add" value="{$LISTVAL_PURCHASEORDER_NO}" />
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="originBill_select('{$MODULE}');" draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleProduct(this,'{$MODULE}','{$PRODUCTCONTENT}'); return false;"
					   draggable="false">+</a>
				</td>
			{elseif $uitype eq 202 }{*合同订单多个源单选择*}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						<input type="hidden" name="salesordertypeofdata" id="salesordertypeofdata" value="{$typeofdata}" />
					{else}
						{$usefldlabel}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<select id="selectsource" name="selectsource" onchange="SelectSource('{$MODULE}',this,'')" class="ld-select-inner ld-select-inner-source">
						<option value="" {if $thirdvalue eq ''} selected {/if}></option>
						{foreach item=issourcemodule key=count from=$SOURCEMODULE}
							<option value="{$issourcemodule.entitytype}" {if $thirdvalue == $issourcemodule.entitytype} selected {/if}>{$issourcemodule.entitytype|@getTranstab}</option>
						{/foreach}
					</select>
					<input type="hidden" id="selectsourcename" name="selectsourcename" value="{$thirdvalue}" />
					<input type="hidden" id="listvalall" name="listvalall" value="{$LISTVAL}" />
					<input type="hidden" id="listvalallname" name="listvalallname" value="{$LISTVAL_PURCHASEORDER_NO}" />
					{if $MODULE eq 'Expense' || $MODULE eq 'Project' ||  $MODULE eq 'PaymentPlan' ||  $MODULE eq 'SendPayment'}
						<input type="hidden" id="entitytypeid" name="entitytypeid" value="{$ENTITYTYPEID}" />
						<input readonly name="salesorder_name" readonly type="text" fieldonly='{$fieldonly}' value="{$LISTVAL}" class="ld-input-inner ld-input-inner-source">
					{else}
						<input type="hidden" name="selectlistval" id="selectlistval" value="{$secondvalue}" />
						<input readonly type="text" id="selectlistval_label" name="selectlistval_label" class="ld-input-inner ld-input-inner-add ld-input-inner-source" value="{$fldvalue}"/>
					{/if}
					<a class="ld-text-select" name="selectlistval_icon_select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectSalesOrder('{$MODULE}');" draggable="false">+</a>
					<a class="ld-text-clear" name="selectlistval_icon_clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleProduct(this,'{$MODULE}','{$PRODUCTCONTENT}'); return false;"
					   draggable="false">+</a>
				</td>
			{elseif $uitype eq 174 }{*多选客户*}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						<input type="hidden" name="salesordertypeofdata" id="salesordertypeofdata" value="{$typeofdata}" />
					{else}
						{$usefldlabel}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="hidden" name="{$fldname}" id="{$fldname}" value="{$secondvalue}" />
					<input readonly type="text" id="{$fldname}_label" name="{$fldname}_label" class="ld-input-inner ld-input-inner-add" value="{$fldvalue}" />
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectModuleForMore('{$MODULE}','Accounts','{$fldname}');" draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleMore('{$MODULE}','{$fldname}'); return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 208 }{*合同模块选择源单：只能选择一个单据中的产品*}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
						<font color="red">{$mandatory_field}</font>{$usefldlabel}
						<input type="hidden" name="salesordertypeofdata" id="salesordertypeofdata" value="{$typeofdata}" />
					{else}
						{$usefldlabel}
					{/if}
					{include file='Helptips.tpl'}
					<input type="hidden" id="selectsourcename" name="selectsourcename" value="{$SELECTSOURCENAME}" />
					<input type="hidden" id="listvalall" name="listvalall" value="{$LISTVAL}" />
					<input type="hidden" id="listvalallname" name="listvalallname" value="{$LISTVAL_PURCHASEORDER_NO}" />
				</td>
				<td class="ld-form-item-content">
					<select id="selectsource" name="selectsource" onchange="SelectSource('{$MODULE}',this,'')" class="ld-select-inner ld-select-inner-source">
						<option value="" {if $SELECTSOURCENAME eq ''} selected {/if}></option>
						{foreach item=issourcemodule key=count from=$SOURCEMODULE}
							<option value="{$issourcemodule.entitytype}" {if $SELECTSOURCENAME == $issourcemodule.entitytype} selected {/if}>{$issourcemodule.entitytype|@getTranstab}</option>
						{/foreach}
					</select>
					<input type="hidden" name="{$fldname}" id="{$fldname}" value="{$LISTVAL_RECORD}" />
					<input readonly type="text" id="selectlistval_label" name="selectlistval_label" class="ld-input-inner ld-input-inner-add ld-input-inner-source" value="{$LISTVAL_PURCHASEORDER_NO}" />
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectSalesOrder('{$MODULE}');">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleProduct(this,'{$MODULE}','{$PRODUCTCONTENT}'); return false;">+</a>
				</td>
			{elseif $uitype eq 201 && $MODULE_ACTIVATE == true}
				<td class="ld-form-item-label" style="{$label_style}">
					{if $typeofdata eq 'M'}
						<font color="red">{$mandatory_field}</font>{'PurchaseOrder'|@getTranstab}
						<input type="hidden" name="salesordertypeofdata" id="salesordertypeofdata" value="{$typeofdata}" />
					{else}
						{'PurchaseOrder'|@getTranstab}
					{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input type="hidden" name="selectlistval" id="selectlistval" value="{$LISTALLVAL}" />
					<input readonly type="text" id="purchaseorder_id" name="purchaseorder_id" value="{$LISTVAL_PURCHASEORDER_NO}" class="ld-input-inner ld-input-inner-add" />
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="selectPurchaseOrder('{$MODULE}');" draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clearModuleProduct(this,'{$MODULE}','{$PRODUCTCONTENT}'); return false;"
					   draggable="false">+</a>
				</td>
			{elseif $uitype eq 242}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
                    {* zkt 20230423 kh001乱码 BUG0063271 公告模块新增选择接收人后出现乱码 *}
                    <div readonly=true id="recipient_name" name="recipient_name"
                    class="ld-input-inner ld-input-inner-add" style="text-overflow:ellipsis;overflow:hidden;">{$fldvalue}</div>
                    <input name="{$fldname}" id="{$fldname}" type="hidden" value="{$secondvalue}"/>
					<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='select_purview("{$fldname}_name","{$fldname}","User","sel_radio","search_yes","{$MODULE}","{$usefldlabel}","")' draggable="false">+</a>
					<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('','{$fldname}','recipient_name','','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
				</td>
			{elseif $uitype eq 123}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner" />
				</td>
			{elseif $uitype eq 303}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content ld-form-item-content-second">
					<input type="hidden" name="{$fldname}_advft_criteria" id="{$fldname}_advft_criteria" value='{$fldvalue}'>
					<input type="hidden" name="{$fldname}_advft_criteria_groups" id="{$fldname}_advft_criteria_groups" value='{$secondvalue}'>
					<a class="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setModuleScope('Accounts','{$fldname}','{$usefldlabel}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
				</td>
			{elseif $uitype eq 304}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content ld-form-item-content-second">
					<input type="hidden" name="{$fldname}" id="{$fldname}" value='{$fldvalue}'>
					<a class="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setModuleMinus('{$fldname}','{$usefldlabel}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
				</td>
			{elseif $uitype eq 305}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content ld-form-item-content-second">
					<input type="hidden" name="{$fldname}" id="{$fldname}" value='{$fldvalue}'>
					<a class="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setDurationSetting('{$fldname}','{$usefldlabel}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
				</td>
			{elseif $uitype eq 4001}
				<td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					<input name="{$fldname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner" />
					<a class="ld-text-search" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="get_saic_api();">+</a>
				</td>
            {elseif $ReferenceUitypes|@is_array && $uitype|in_array:$ReferenceUitypes}
                <td class="ld-form-item-label" style="{$label_style}">
					<font color="red">{$mandatory_field}</font>{$usefldlabel}
                    {if $MASS_EDIT eq '1'}<input type="checkbox" name="{$fldname}_mass_edit_check" id="{$fldname}_mass_edit_check" >{/if}
					{include file='Helptips.tpl'}
				</td>
				<td class="ld-form-item-content">
					{if $VERSION_ACCOUNT eq 'baxter' && {$MODULE} eq 'CustomForm72' && $UITYPEMODULES[$uitype] eq 'CustomForm63'}
					<input name="{$fldname}_name" fldname="{$fldname}" colname="{$colname}" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" fieldname="{$fldname}" class="ld-input-inner ld-input-inner-add" onkeyup="getKeyWords(this,1,'{$UITYPEMODULES[$uitype]}',event)" onkeypress="userEnterKey(getKeyWords,[this,1,'{$UITYPEMODULES[$uitype]}',event],event)" autocomplete="off" >
					{else}
					<input readonly name="{$fldname}_name" type="text" fieldonly='{$fieldonly}' value="{$fldvalue}" class="ld-input-inner ld-input-inner-add">
					{/if}
					<input name="{$fldname}" type="hidden" value="{$secondvalue}">
					{if $bigtype == 'reference'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist("{$MODULE}","{$UITYPEMODULES[$uitype]}","select","","{$fldname}");' draggable="false">+</a>
						<a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_relatedfielddata('{$UITYPEMODULES[$uitype]}','{$fldname}','{$fldname}_name','{$fldname}','{$MODULE}','popupselectfield');return false;" draggable="false">+</a>
					{elseif $bigtype == 'multireference'}
						<a class="ld-text-select" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick='showrelatedlist_multi("{$MODULE}","{$UITYPEMODULES[$uitype]}","{$fldname}");' draggable="false">+</a>
						<a id="clearscope" name="clearscope" class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="clear_multiinput('{$fldname}','{$fldname}_name')" draggable="false">+</a>
					{/if}
					<div class="SearchResult" style="z-index:1100;max-height:220px;overflow:auto;"></div>
				</td>
			{/if}

			{if $uitype eq '' && $td1_uitype neq '28' && $td1_uitype neq '1109'
			&& $td1_uitype neq '1108' && $td1_uitype neq '19'&& $td1_uitype neq '21' && $td1_uitype neq '65' && $td1_uitype neq '20'&&$td1_uitype neq '230'&&$td1_uitype neq '357' && $td1_uitype neq '125'
			&&$td1_uitype neq '69'&&$td1_uitype neq '103'&&$td1_uitype neq '79'&&$td1_uitype neq '30'&&$td1_uitype neq '83'}
				<td colspan="2"></td>
			{/if}
		{/if}