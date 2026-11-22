<!--修改编码格式:统一编码：UTF-8-->
{if $keyid eq '1' || $keyid eq 2 || $keyid eq '11' || $keyid eq '7' || $keyid eq '9' || $keyid eq '55' || $keyid eq '71' || $keyid eq '72' || $keyid eq '255'} <!--TextBox-->
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}" style="color:{$fieldvaluecolor}"/>
		{if $keyid eq '55' || $keyid eq '255'}<!--SalutationSymbol-->
			{if $keyaccess eq 'NOTACCESS'|@getFixedLabel}
				<font color='red'>{'NOTACCESS'|@getFixedLabel}</font>
			{else}
				{$keysalut}
			{/if}
		{*elseif $keyid eq '71' || $keyid eq '72'}  <!--CurrencySymbol-->
			{$keycursymb*}
		{/if}
		{if $keyid eq 11 && $USE_ASTERISK eq 'true'}
            <span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}"><a href='javascript:;' onclick='startCall("{$keyval}", "{$ID}")'>{$keyval}</a></span>
		{elseif $keyid eq 255}
			{if $ShowHyperlinks eq 'no'}
				<span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}" record="{$ID}">{$keyval}</span>
			{else}
				<a tag="{$ShowHyperlinks}" fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}' referencemodule='Contacts' referencerecord='{$CONTACTID}' href="index.php?pageto_module=Contacts&action=index&pageto_record={$CONTACTID}" onclick="ListReferenceLinkClick(ld(this),event)">{$keyval}</a>
			{/if}
		{else}
			<span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}'>{$keyval}</span>
		{/if}
		<!--{*
			 给电话、手机字段增加外呼标签
			 @project 天润呼叫中心集成
			 @author tujt 2014-05-15
		*}-->
		{if $keyid == 11 && $keyval != ''}
			<i class='callcenterImg ld-fonticon ld-fonticon-phone' style='display:none;' keyval='{$keyval}' key_recordid='{$ID}' key_module='{$MODULE}' tag='{$keycolname}' key_tablename= '{$keytblname}' key_detailrecordid=''></i>
		{/if}
        {if $keyid eq '71' && $keyfldname eq 'unit_price'}
        	{if $PRICE_DETAILS|@count > 0}
				<span id="multiple_currencies" width="38%" style="align:right;">
					<a href="javascript:void(0);" onclick="toggleShowHide('currency_class','multiple_currencies');">{$APP.LBL_MORE_CURRENCIES} &raquo;</a>
				</span>
				<div id="currency_class" class="multiCurrencyDetailUI">
					<table width="100%" height="100%" class="small" cellpadding="5">
					<tr class="detailedViewHeader">
						<th colspan="2">
							<b>{$MOD.LBL_PRODUCT_PRICES}</b>
						</th>
						<th align="right">
							<a class="icon-homeimg icon-close" href="javascript:;" onclick="toggleShowHide('multiple_currencies','currency_class');"></a>
						</th>
					</tr>
					<tr class="detailedViewHeader">
						<th>{$APP.LBL_CURRENCY}</th>
						<th colspan="2">{$APP.LBL_PRICE}</th>
					</tr>
					{foreach item=price key=count from=$PRICE_DETAILS}
						<tr>
							{*if $price.check_value eq 1*}
							<td class="ld-form-item-label">
								{$price.currencylabel} ({$price.currencysymbol})
							</td>
							<td class="ld-form-item-content" colspan="2">
								&nbsp;{$price.curvalue}
							</td>
						</tr>
					{/foreach}
					</table>
				</div>
			{/if}
        {/if}
        {if $keyfldname eq 'express_no'}
            {*合同订单、出库单物流单号显示查询按钮*}{*ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型*}
            <b id="logistics_query" onclick="express_no_query(this)" title="{'QUERYTO'|@getFixedLabel}" class="icon-homeimg icon-logistics"  {if $keyval neq ''}style="cursor:pointer;"{else}style="cursor:pointer;display:none;"{/if}></b>
        {/if}
        {* 工商查询 *}
        {if $ENABLEBUSINESS eq 'yes' && $BUSINESSQUERY eq 'yes'}
            <i id="business_{$keyfldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang2" onclick="getTianyanByKeyWordForInfo('{$keyfldname}','dtlview');"></i>
        {/if}
		&nbsp;
	</td>
{elseif $keyid eq '13'} <!--Email-->
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		{if $smarty.session.internal_mailer eq 1}
			<a href="javascript:InternalMailer({$ID},{$keyfldid},'{$keyfldname}','{$MODULE}','record_id');">{$keyval}</a>
		{else}
			<a href="mailto:{$keyval}" target="_blank" >{$keyval}</a>
		{/if}
		</span>&nbsp;
	</td>
{elseif $keyid eq '99'}<!-- Password Field-->
	<td class="ld-form-item-content">{$CHANGE_PW_BUTTON}&nbsp;</td>
{elseif $keyid eq '15' || $keyid eq '16'} <!--ComboBox-->
	<td class="ld-form-item-content">
       	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		{if $BESTATUS neq 'YES'}
			{foreach item=arr from=$keyoptions}
				{if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
					{assign var=keyval value='NOTACCESS'|@getFixedLabel}
					{assign var=fontval value='red'}
				{else}
					{assign var=fontval value=''}
				{/if}
			{/foreach}
		{/if}
		<font style="color:{$pick_color}" color="{$fontval}">{$keyval}</font>&nbsp;
	</td>
{elseif $keyid eq '33'}
	<td class="ld-form-item-content">
      	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		{$keyval}
	</td>
{elseif $keyid eq '14'}<!--Time-->
	<td class="ld-form-item-content">
    	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}" style="color:{$fieldvaluecolor}"/>
        {$keyval}&nbsp;
	</td>
{elseif $keyid eq 1108}
    <td class="ld-form-item-content">
        {foreach item=item key=kid from=$keyval}
            {foreach item=attval key=fid from=$item}
				{if $attval.name neq ''}
					{if $attval.file_type eq 'img'}
						<span id="dtlview_{$fid}" class="listattachment">
                            {if $ID|@IsPreviewProfile:$MODULE eq 'yes'}
								<img src="{$attval.path}{$attval.newfile_name}" alt=""/>
							{/if}
                            <span class="attachments-padL11">{$attval.name}&nbsp;<span style="color:#798699;padding-left:5px">({$attval.imagefromtype}  {$attval.size})</span>
                                {if $ID|@IsDownLoadProfile:$MODULE  eq 'yes'}
									<span>
									    <a href="javascript:DownLoad({$fid},{$RECORD});" onclick="update_frequency('{$fid}','download');" title="{'DOWNLOADFILE'|@getFixedLabel}"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;</span>
                                        {*zkt 20230607 BUG0067549  	kfbcrm-附件管理-单据ATT110，附件的下载和预览次数不显示 *}
                                        {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                            <span {if {$attval.download_times} eq 0}style = "display: none;{/if}">( <a href="javascript:void(0);"  download="" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                        {/if}
									<span >
                                {/if}
                                {if $ID|@IsPreviewProfile:$MODULE eq 'yes'}
							        <a href="javascript:void(0);" onclick="savePreviewlog({$ID},{$fid},'{$MODULE}','{$values}');update_frequency('{$fid}','preview');open_Attachment({$RECORD},{$fid},'{$MODULE}','{$items}')" title="{'PREVIEW'|@getFixedLabel}{'Attachment'|@getFixedLabel}"><span>{'PREVIEW'|@getFixedLabel}</span></a></span>
                                    {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                        <span {if {$attval.preview_times} eq 0}style = "display: none;{/if}">( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                    {/if}
							    {/if}
                            </span>
                        </span>
					{else}
                       <span id="dtlview_{$fid}" class="listattachment">
                            <span class="attachments-padL11 clearBoth">{$attval.name}&nbsp;{if $DLD_TYPE eq 'I'}<span style="color:#798699;">({$attval.size})</span>{/if}
								<span>
                                	{if $ID|@IsDownLoadProfile:$MODULE eq 'yes'}
										<span >
										    <a  href="javascript:DownLoad({$fid},{$RECORD});" onclick="update_frequency('{$fid}','download');"  title="{'DOWNLOADFILE'|@getFixedLabel}"><span>{'DOWNLOAD'|@getFixedLabel}</span></a>&nbsp;&nbsp;</span>
                                            {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                                <span {if {$attval.download_times} eq 0}style = "display: none;{/if}">(  <a href="javascript:void(0);" name="download_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','download');">{$attval.download_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                            {/if}
										<span >
                                    {/if}
                                    {if $ID|@IsPreviewProfile:$MODULE eq 'yes'}
									    <a href="javascript:void(0);" onclick="update_frequency('{$fid}','preview');open_Attachment({$RECORD},{$fid},'{$MODULE}','{$items}')" title="{'PREVIEW'|@getFixedLabel}{'Attachment'|@getFixedLabel}"><span>{'PREVIEW'|@getFixedLabel}</span></a></span>
                                        {if $ID|@IsFileReadHistoryProfile:$MODULE eq yes}
                                            <span {if {$attval.preview_times} eq 0}style = "display: none;{/if}">( <a href="javascript:void(0);" name="preview_{$fid}" onclick="FileReadHistory({$fid},'{$MODULE}','preview');">{$attval.preview_times}</a> {'Frequency'|@getFixedLabel})</span>&nbsp;&nbsp;
                                        {/if}
			  	                   {/if}
                                </span>
                            </span>
                        </span>
					{/if}
                {/if}
            {/foreach}
	    {/foreach}
    </td>
{elseif $keyid eq '17'} <!--WebSite-->
	<td class="ld-form-item-content"><a href="{$keyval}" target="_blank">{$keyval}</a>&nbsp;</td>
{elseif $keyid eq '222'}
	<td class="ld-form-item-content">
		{if $keyval neq '' && $keysecid neq ''}
			<img src="{$keyval}" alt="" title="" LANGUAGE=javascript align="absmiddle" width="50" height="80" style="transform:rotate(-90deg);"></img><br />
			{'handwritingdatetime'|@getFixedLabel}：{$keysecid}
		{/if}
	</td>
{elseif $keyid eq '85'}<!--Skype-->
	<td class="ld-form-item-content" id="mouseArea_{$label}">
		<img src="{'skype.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SKYPE}" title="{$APP.LBL_SKYPE}" LANGUAGE=javascript align="absmiddle"></img>
		<span id="dtlview_{$label}"><a href="skype:{$keyval}?call">{$keyval}</a></span>
		&nbsp;
	</td>
{elseif $keyid eq '19' || $keyid eq '20' ||$keyid eq '230' ||$keyid eq '231'} <!--TextArea/Description-->
	{if $label eq $MOD.LBL_ADD_COMMENT}
		{assign var=keyval value=''}
	{/if}
    {if $MODULE eq 'Documents'||$MODULE eq 'Reminds'}
		<!--To give hyperlink to URL-->
		{*wym 240513 XUQIU1002193 提醒内容包含超链接,不要把括号处理掉*}
        <td colspan="3" {if $keyid eq '230'|| $keyid eq '231'} class="ld-form-item-content lineheight25 uitype230" {else} class="ld-form-item-content lineheight25" {/if}>{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
            &nbsp;</td>
    {else}
        <td colspan="3" {if $keyid eq '230'|| $keyid eq '231'} class="ld-form-item-content lineheight25 uitype230" {else} class="ld-form-item-content lineheight25" {/if} id="mouseArea_{$label}" >
            <span style="color:{$fieldvaluecolor};" id="dtlview_{$label}" record='{$ID}' module='{$MODULE}' fieldname='{$keyfldname}'>
			{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
        	</span>
        <div id="editarea_{$label}" style="display:none;">
        	<textarea placeholder="{$fieldplaceholder}"  style="color:{$fieldvaluecolor};" id="txtbox_{$label}" name="{$keyfldname}"  class=detailedViewTextBox onFocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'"onBlur="this.className='detailedViewTextBox'" cols="90" rows="8">{$keyval|replace:"<br>":"\n"}</textarea>
        	<br/>
        	<a href="javascript:;" name="button_{$label}" onclick="{if $fieldonly eq 1 } if( dtlViewDuplicate('{$label}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}')){/if} {ldelim}dtlViewAjaxSave('{$label}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');fnhide('crmspanid');{rdelim}">{'SAVE'|@getFixedLabel}</a>
        	{'OR'|@getFixedLabel}
        	<a href="javascript:;" onclick="hndCancel('dtlview_{$label}','editarea_{$label}','{$label}')">{'CANCEL'|@getFixedLabel}</a>
        </div>
        </td>
    {/if}
{elseif $keyid eq '21' || $keyid eq '24' || $keyid eq '22'} <!--TextArea/Street-->
	<td class="ld-form-item-content">
       	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        <span style="color:{$fieldvaluecolor};" id ="dtlview_{$label}">{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":""}</span>&nbsp;
	</td>
{elseif $keyid eq '50' || $keyid eq '73' || $keyid eq '51' || $keyid eq '57'|| $keyid eq '96' || $keyid eq '59' || $keyid eq '75' || $keyid eq '81' || $keyid eq '76' || $keyid eq '78' || $keyid eq '800' || (is_array($ReferenceUitypes) && $keyid|@in_array:$ReferenceUitypes)}
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        <input type="hidden" name="{$keyfldname}" value="{$keysecid}"/>
        {* edit: xll 2023/06/08 XUQIU1001203 增加显示超链接属性 *}
        {if $ShowHyperlinks eq 'no' or $keysecid eq 0}
        	{$keyval}
        {else}
            <a href="{$keyseclink}">{$keyval}</a>
      	{/if}
        &nbsp;
	</td>
{elseif $keyid eq '53'} <!--Assigned To-->
    <td class="ld-form-item-content">
    	<span style='display:none' name="{$keyfldname}_name"  record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}">{$value_name}</span>
    	<input type="hidden" name="{$keyfldname}" value="{$keysecid}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}"/>
        {if $keyadmin eq 1}
			<a fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}' referencemodule='Users' referencerecord='{$keysecid}' href="index.php?pageto_module=Users&action=index&pageto_record={$keysecid}" onclick="ListReferenceLinkClick(ld(this),event)">{$keyval}</a>
        {else}
            <span id="dtlview_{$keyfldname}_{$MODULE}" fieldname='{$keyfldname}' referencemodule='Users'  referencerecord='{$keysecid}' module='{$MODULE}' record='{$ID}'>{$keyval}</span>
      	{/if}
    </td>
{elseif $keyid eq '52' || $keyid eq '77' ||$keyid eq '103'}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="editarea_{$keyfldname}">
		<span style="display:none" name="{$keyfldname}_name" >{$value_name}</span>
		<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">{$keyval}</span>
		&nbsp;
	</td>
{elseif $keyid eq 201 || $keyid eq 200 || $keyid eq 202|| $keyid eq 204}<!-- for Image Reflection -->
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        <input type="hidden" name="selectlistval_label" value="{$value_name}"/>
        {$keyval}&nbsp;
    </td>
{elseif $keyid eq 208}<!-- for Image Reflection -->
	<td class="ld-form-item-content">{$LASTVALINFO}&nbsp;</td>
{elseif $keyid eq '56'} <!--CheckBox-->
	<td class="ld-form-item-content">
    	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
    	{$keyval}&nbsp;
	</td>
{elseif $keyid eq 83}<!-- Handle the Tax in Inventory -->
	{foreach item=tax key=count from=$TAX_DETAILS}
		<td class="ld-form-item-label">{$tax.taxlabel}(%)&nbsp;</td>
		<td class="ld-form-item-content" colspan="3">{$tax.percentage}&nbsp;</td>
		</tr>
		<tr>
	{/foreach}
	{*zkt 20230215 BUG0061685kfbcrm 客户服务单---单据审批通过之后---定位地址区块的字段就会变为居中显示 *}
{elseif $keyid eq 65}
    <td class="ld-form-item-content lineheight20" colspan="3">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		<span id="dtlview_{$keyfldname}"  fieldname="{$keyfldname}" record="{$ID}" module="{$MODULE}" style="float:left;">{$keyval}</span>
    </td> 
{elseif $keyid eq 69}<!-- for Image Reflection -->
	<td class="ld-form-item-content lineheight20" colspan="3" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" tag="detailview_image">
		{include file="DetailView/AttachmentField.tpl"}
		<script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
    </td>
{elseif $keyid eq 79}
	<td class="ld-form-item-content" colspan="3">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
    	{$keyval}&nbsp;
    </td>
{elseif $keyid eq 130}<!-- for Image Reflection -->
    <td class="ld-form-item-content">{$keyval}</td>
{elseif $keyid eq 28||$keyid eq 1109}
	<td class="ld-form-item-content lineheight20" colspan="3" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" tag="detailview_image">
		{include file="DetailView/AttachmentField.tpl"}
		<script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
    </td>
{elseif $keyid eq 5 || $keyid eq 23 || $keyid eq 70}
	<td class="ld-form-item-content">
        <span id="dtlview_{$keyfldname}" style="float:left;color:{$fieldvaluecolor}">{$keyval}</span>
	</td>
{elseif $keyid eq 153 || $keyid eq 154||$keyid eq 132}
	<td class="ld-form-item-content">
        <span id="dtlview_{$keyfldname}" style="float:left;">{$keyval}</span>
	</td>
{elseif $keyid eq 1051}
	<td class="ld-form-item-content">
       <img src="{$keyval}" alt="" title="" LANGUAGE=javascript align="absmiddle" width="100" height="100" ></img><br />
	</td>
{elseif $keyid eq 303}
	<td class="ld-form-item-content">
		<input type="hidden" name="{$keyfldname}_advft_criteria" id="{$keyfldname}_advft_criteria" value='{$keyval}'>
		<input type="hidden" name="{$keyfldname}_advft_criteria_groups" id="{$keyfldname}_advft_criteria_groups" value='{$keysecid}'>
		<a class="javascript:;" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setModuleScope('Accounts','{$keyfldname}','{$label}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
		&nbsp;
	</td>
{elseif $keyid eq 304}
	<td class="ld-form-item-content">
		<input type="hidden" name="{$keyfldname}" id="{$keyfldname}" value='{$keyval}'>
		<a class="javascript:;" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setModuleMinus('{$keyfldname}','{$label}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
		&nbsp;
	</td>
{elseif $keyid eq 305}
	<td class="ld-form-item-content">
		<input type="hidden" name="{$keyfldname}" id="{$keyfldname}" value='{$keyval}'>
		<a class="javascript:;" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setDurationSetting('{$keyfldname}','{$label}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
		&nbsp;
	</td>
{elseif $keyid eq 1500||$keyid eq 1501||$keyid eq 1502}
	{*zxm 2021-0409 二维码字段类型*}
	<td class="ld-form-item-content">
		<a href="javascript:;" id="dtlview_{$keyfldname}" style="float:left;" onclick="viewQrCode('{$MODULE}',{$keyfldid},{$keyid},{$ID})">{'VIEW'|@getFixedLabel}{'SOCIALPROMOTIONQRCODE'|@getFixedLabel}</a>
	</td>
{elseif $keyid eq 1503}
	{*duan 2022-0111 二维码字段增加表单码类型*}
	<td class="ld-form-item-content">
		<a href="javascript:;" id="dtlview_{$keyfldname}" style="float:left;" onclick="viewFormQrCode('{$MODULE}',{$keyfldid},{$keyid},{$ID})">{'VIEW'|@getFixedLabel}{'SOCIALPROMOTIONQRCODE'|@getFixedLabel}</a>
        {if $keyval >0}
        {*提交日志数量为空时不显示*}
        <a href="javascript:;"  id="dtlview_{$keyfldname}" style="float:left;margin-left:10px;" onclick="FormQrCode_Viewlog(0,'{$MODULE}',{$keyfldid},{$keyid},{$ID})">{'VIEW'|@getFixedLabel}{'View History'|@getFixedLabel}</a>
        {/if}
    </td>
{else}
	<td class="ld-form-item-content">
    	{if $keyid eq '100'&&$MODULE eq 'Reminds'}
    	{else}
            <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
    	{/if}
		{*@edit:liushuai,2020-07-130,reason:0042168/自定义表单26-60单据查看详情界面，点击更多中的更改创建人后，创建人字段值没有立即更新*}
		<span id="dtlview_{$keyfldname}"  fieldname="{$keyfldname}" record="{$ID}" module="{$MODULE}" style="float:left;">{$keyval}</span>
		<!--{*
			 给电话、手机字段增加外呼标签
			 @project 天润呼叫中心集成
			 @author tujt 2014-05-15
		 *}-->
		{if $keyid == 1101 && $keyval != ''}
			{if ''|@getSMSAutographStatus eq 'true' && 'MassSMS'|@vtlib_isModuleActive && 'MassSMS'|@isPermitted eq 'yes'}
		 		<i class="ld-fonticon ld-fonticon-phone" id="img_{$label}" onclick="getMassSmsPopup('{$keyval}')"></i>
			{/if}
			<i class='callcenterImg ld-fonticon ld-fonticon-phone' style='display:none;float: left;' key_recordid='{$ID}' key_module='{$MODULE}' keyval='{$keyval}' tag='{$keycolname}' key_tablename= '{$keytblname}' key_detailrecordid=''></i>
		{/if}
		&nbsp;
	</td>
{/if}