<!--修改编码格式:统一编码：UTF-8-->
{if $keyid eq '1' ||$keyid eq '1103'  || $keyid eq 2 || $keyid eq '11' || $keyid eq '7' || $keyid eq '9' || $keyid eq '55' || $keyid eq '71' || $keyid eq '72' || $keyid eq '103' || $keyid eq '255' || $keyid eq '14'|| $keyid eq '1101'} <!--TextBox-->
	<td class="ld-form-item-content" id="mouseArea_{$label}">
        <input type="hidden" fieldname="{$keyfldname}" module="{$MODULE}" record="{$CONTACTID}" name="{$keyfldname}_name" value='{$keyval}' style="color:{$fieldvaluecolor}"/>
		{if $keyid eq '55' || $keyid eq '255'}<!--SalutationSymbol-->
			{if $keyaccess eq 'NOTACCESS'|@getFixedLabel}
				<font color='red'>{'NOTACCESS'|@getFixedLabel}</font>
			{else}
				{$keysalut}
			{/if}
		{/if}
		{if $keyid eq 11 && $USE_ASTERISK eq 'true'}
            <span name="dtlview_{$keyfldname}"><a href='javascript:;' fieldname="{$keyfldname}" module="{$MODULE}" datavalue="{$keyval}" record="{$ID}" onclick='startCall(ld(this))'>{$keyval}&nbsp;</a></span>
		{else}
            {if $keyid eq 1101}
                <span style="float:left;color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}&nbsp;</span>
                {if $keyval neq ''}
                    {if ''|@getSMSAutographStatus eq 'true' && 'MassSMS'|@vtlib_isModuleActive && 'MassSMS'|@isPermitted eq 'yes'}
                    <i class="ld-fonticon ld-fonticon-phone" style="margin-top:0;" id="img_{$label}" onclick="getMassSmsPopup('{$keyval}')"></i>
					{/if}
                {/if}
            {elseif $keyid eq 1103 && $keyval neq ''}
                <a style="display:block;float:left;" href="tencent://message/?uin={$keyval}&Menu=yes"  target="blank">
                    <img border="0" src='./themes/icon/qqenable.jpg' width="20" height="20" style="margin-left:5px;"/>
                </a>
                <span style="float:left;" id="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}&nbsp;</span>
            {elseif $keyid eq '71' || $keyid eq '72'}
				<span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}" record="{$ID}">{$keyval}&nbsp;</span>
                {*editor:gyq_101 reason:产品单据明细界面,查看产品所在仓库数量分布情况  2019/1/28 15:53*}
            {elseif $keyid eq '7' && $keyfldname eq 'qtyinstock'&& $keyval neq 0 && $keyval neq ''}
                <span style="color:{$fieldvaluecolor}" name="dtlview_{$keyfldname}">{$keyval}</span>
                {if $STOCKVIEW eq 'CRM+ERP'}
                    <span class="icon-homeimg icon-stock cursorPointer marR5 operatetool_more" title="{'SEARCHINVENTORY'|@getFixedLabel}"><ol class="operatetool_more_content"><li onclick="search_pro_stock(this,{$ID})" tag="CRM">CRM{'INVENTORY'|@getFixedLabel}</li><li onclick="search_pro_stock(this,{$ID})" tag="ERP" view="{$ERPVIEW}">ERP{'INVENTORY'|@getFixedLabel}</li></ol></span>
                {else}
                    <span class="icon-homeimg icon-stock cursorPointer marR5 operatetool_more" title="{'SEARCHINVENTORY'|@getFixedLabel}" tag="{$STOCKVIEW}" onclick="search_pro_stock(this,{$ID})"></span>
                {/if}
			{elseif $keyid eq 255}
                {* edit: xll 2023/06/09 XUQIU1001203 联系人姓名字段增加显示超链接属性控制 *}
                {if $ShowHyperlinks eq 'no'}
                    <span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}" record="{$ID}">{$keyval}</span>
                {else}
				    <a fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}' referencemodule='Contacts' referencerecord='{$CONTACTID}' href="index.php?pageto_module=Contacts&action=index&pageto_record={$CONTACTID}" onclick="ListReferenceLinkClick(ld(this),event)">{$keyval}</a>
                {/if}
            {else}
                <span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}" record="{$ID}">{$keyval}</span>
            {/if}
		{/if}
		<!--{*
			给电话、手机字段增加外呼标签
			@project 天润呼叫中心集成
			@author tujt 2014-05-15
		*}-->
		{if ($keyid eq 11 || $keyid eq 1101) && $keyval != ''}
			<i class='callcenterImg ld-fonticon ld-fonticon-phone' style='display:none;' key_recordid='{$ID}' key_module='{$MODULE}' keyval='{$keyval}' tag='{$keycolname}' key_tablename= '{$keytblname}' key_detailrecordid=''></i>
		{/if}
        <div id="editarea_{$label}" style="display:none;">
        	<input class="ld-input-inner" type="text" fieldname="{$keyfldname}"
             module="{$MODULE}" name="{$keyfldname}" maxlength='100' value="{$rawvalue}"/>              
        </div>
        {if $keyfldname eq 'express_no'}
            {*合同订单、出库单物流单号显示查询按钮*}{*ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型*}
            <i id="logistics_query" onclick="express_no_query(this)" title="{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-wuliu" {if $keyval eq ''}style="display:none;"{/if}></i>
        {/if}
        {if $keyid eq '71' && $keyfldname eq 'unit_price'}
        	{if $PRICE_DETAILS|@count > 0}
				<span id="multiple_currencies" width="38%" style="align:right;">
					<a href="javascript:void(0);" onclick="toggleShowHide('currency_class','multiple_currencies');">{$APP.LBL_MORE_CURRENCIES} &raquo;</a>
				</span>
				<div id="currency_class" class="multiCurrencyDetailUI">
					<table width="100%" height="100%" class="small" cellpadding="5">
					<tr>
						<th colspan="2">
							<b>{$MOD.LBL_PRODUCT_PRICES}</b>
						</th>
						<th align="right">
							<a class="icon-homeimg icon-close" href="javascript:;" onclick="toggleShowHide('multiple_currencies','currency_class');" src="{'close.gif'|@lingdang_imageurl:$THEME}"/>
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
								{$price.currencylabel|@getTranslatedCurrencyString} ({$price.currencysymbol})&nbsp;
							</td>
							<td class="ld-form-item-content" colspan="2">
								{$price.curvalue}&nbsp;
							</td>
						</tr>
					{/foreach}
					</table>
				</div>
			{/if}
        {/if}
        {* 工商查询 *}
        {if $ENABLEBUSINESS eq 'yes' && $BUSINESSQUERY eq 'yes'}
            <i id="business_{$keyfldname}" title="{'business'|@getFixedLabel}{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-gongshang2" onclick="getTianyanByKeyWordForInfo('{$keyfldname}','dtlview');"></i>
        {/if}
    </td>
{elseif $keyid eq '13' || $keyid eq '104'} <!--Email-->
    <td class="ld-form-item-content" id="mouseArea_{$label}" >
        <input type="hidden" name="{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}" value="{$value_name}"/>
        <span id="dtlview_{$label}">
			{if $smarty.session.internal_mailer eq 1}
				<!-- <a href="javascript:InternalMailer({$ID},{$keyfldid},'{$keyfldname}','{$MODULE}','record_id');">{$keyval}&nbsp;</a> -->
				<a href="javascript:;" style="float:left;" onclick="send_EMail_popup(this,'{$keyfldname}')">{$keyval}</a>
			{else}
				<a style="float:left;" href="mailto:{$keyval}" target="_blank" >{$keyval}&nbsp;</a>
			{/if}
            {if $keyid eq 13 && $keyval neq ''}
                <i id="emailimg" style="display:;margin-top:0;" class="ld-fonticon ld-fonticon-mail padL5" onclick="send_EMail_popup(this,'{$keyfldname}')"></i>
            {elseif $keyid eq 13 && $keyval eq ''}
                <i id="emailimg" style="display:none;margin-top:9px;" class="ld-fonticon ld-fonticon-mail padL5" onclick="send_EMail_popup(this,'{$keyfldname}')"></i>
            {/if}
		</span>
        <div id="editarea_{$label}" style="display:none;">
        	<input class="ld-input-inner" style="width:58px;height:21px;" type="text" id="txtbox_{$label}" name="{$keyfldname}" maxlength='100' value="{$keyval}"></input>
        	<br/><a href="javascript:;" name="button_{$label}" onclick=" {if $fieldonly eq 1 } if( dtlViewDuplicate('{$label}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}')){/if} {ldelim} dtlViewAjaxSave('{$label}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');fnhide('crmspanid');{rdelim}">{$APP.LBL_SAVE_LABEL}</a> {$APP.LBL_OR}
        	<a href="javascript:;" onclick="hndCancel('dtlview_{$label}','editarea_{$label}','{$label}')">{$APP.LBL_CANCEL_BUTTON_LABEL}</a>
        </div>                               
		<div id="internal_mailer_{$keyfldname}" style="display: none;">{$keyfldid}####{$smarty.session.internal_mailer}</div>               
    </td>
{elseif $keyid eq '15' || $keyid eq '16' || $keyid eq '31' || $keyid eq '32'} <!--ComboBox-->
    {foreach item=arr from=$keyoptions}
		{if $arr[0] eq 'NOTACCESS'|@getFixedLabel && $arr[2] eq 'selected'}
			{assign var=keyval value='NOTACCESS'|@getFixedLabel}
			{assign var=fontval value='red'}
		{else}
            {assign var=fontval value=''}
		{/if}
	{/foreach}
	<td class="ld-form-item-content" id="mouseArea_{$label}" >
        <input type="hidden" value="{$keyval}" name="{$keyfldname}_name" fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}'/>
        <input type="hidden" value="{$keyval}" name="{$keyfldname}" fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}'/>
        <span style="color:{$pick_color}" name="dtlview_{$keyfldname}" fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}'>{$keyval}</span>
        <div name="editarea_{$keyfldname}" style="display:none;">
			  <!--<select fieldname="{$keyfldname}" module="{$MODULE}" name="{$keyfldname}" class="small">
				{foreach item=arr from=$keyoptions}
		            {if $arr[0] eq 'NOTACCESS'|@getFixedLabel}
					<option value="{$arr[0]}" {$arr[2]}>{$arr[0]}</option>
		            {else}
                        <option value="{$arr[1]}" {$arr[2]}>
                        {$arr[0]}
                    </option>
                    {/if}

                {/foreach}
			</select>-->
		</div>
	</td>
{elseif $keyid eq 1108}
    <td class="ld-form-item-content" width="80%" {if $alloweditpage eq 'yes' && ( $ISADMIN || $ISSELF || $ISENABLED eq 1 || $ISLAST )} onmouseover="hndMouseOver_show({$NOTESID},'{$NOTESID}');" onmouseout="hndMouseOver_showno({$NOTESID},'{$NOTESID}');" {/if}>
        {if $ID|@IsDownLoadProfile:$MODULE eq 'yes'}
            <a  title="{'DOWNLOADFILE'|@getFixedLabel}" href="javascript:DownLoad({$ATTACHMENTSID})">{$FILENAME}</a>
        {else}
            {if $MODULE  eq 'Attachment'}{$FILENAME}{else}{$keyval}{/if}
        {/if}
        <span id="dtlview_{$NOTESID}_show" style="display:none;float:right;">
            <span style="float:left">
                {if $ID|@IsPreviewProfile:$MODULE}
                    <a href="javascript:void(0);" onclick="open_Attachment({$NOTESID},{$NOTESID},'{$MODULE}','{$FILENAME}')">{'PREVIEW'|@getFixedLabel}</a>
                {else}
                {/if}
            </span>
        </span>
    </td>
{elseif $keyid eq '33'}<!--Multi Select Combo box-->
	<!--code given by Neil start Ref:http://forums.lingdang.com/viewtopic.php?p=31096#31096-->
	<!--{assign var="MULTISELECT_COMBO_BOX_ITEM_SEPARATOR_STRING" value=", "}  {* Separates Multi-Select Combo Box items *}
	{assign var="DETAILVIEW_WORDWRAP_WIDTH" value="70"} {* No. of chars for word wrapping long lines of Multi-Select Combo Box items *}-->
    <td class="ld-form-item-content" id="mouseArea_{$label}">
        <span id="dtlview_{$label}">{$keyval}</span>
		<!--code given by Neil End-->
        <div id="editarea_{$label}" style="display:none;">
            <select id="txtbox_{$label}" name="{$keyfldname}" class="select2 inputElement form-control select2-offscreen"  size="4" style="width:201px;" MULTIPLE>
                {foreach item=arr from=$keyoptions}
                    {if $arr[1] neq ''}
                        <option value="{$arr[1]}" {$arr[2]}>{$arr[0]}</option>
                    {/if}
                {/foreach}
			</select>
        </div>
	</td>
{elseif $keyid eq '115'} <!--ComboBox Status edit only for admin Users-->
	<td class="ld-form-item-content">{$keyval}</td>
{elseif $keyid eq '116' || $keyid eq '117'} <!--ComboBox currency id edit only for admin Users-->
    {if $keyadmin eq 1 || $keyid eq '117'}
        <td class="ld-form-item-content" id="mouseArea_{$label}" >
            <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
            <span id="dtlview_{$label}">{$keyval}</span>
		    <div id="editarea_{$label}" style="display:none;">
		        <select id="txtbox_{$label}" name="{$keyfldname}" class="small">
					{foreach item=arr key=uivalueid from=$keyoptions}
						{foreach key=sel_value item=value from=$arr}
							<option value="{$uivalueid}" {$value}>{$sel_value|@getTranslatedCurrencyString}</option>
						{/foreach}
					{/foreach}
				</select>
            </div>
        </td>
    {else}
        <td class="ld-form-item-content">{$keyval}</td>
    {/if}
{elseif $keyid eq '17'} <!--WebSite-->
    <td class="ld-form-item-content" id="mouseArea_{$label}">
        <span id="dtlview_{$label}"><a fieldname="{$keyfldname}" module="{$MODULE}" href="{$keyval}" target="_blank">{$keyval}</a></span>
        <div id="editarea_{$label}" style="display:none;">
            <input class="ld-input-inner" fieldname="{$keyfldname}" module="{$MODULE}" onkeyup="validateUrl('{$keyfldname}');" type="text" id="txtbox_{$label}" name="{$keyfldname}" maxlength='100' value="{$keyval}"></input>
        </div>
    &nbsp;</td>
{elseif $keyid eq '85'}<!--Skype-->
    <td class="ld-form-item-content" id="mouseArea_{$label}" ><img src="{'skype.gif'|@lingdang_imageurl:$THEME}" alt="{$APP.LBL_SKYPE}" title="{$APP.LBL_SKYPE}" LANGUAGE=javascript align="absmiddle"></img><span id="dtlview_{$label}"><a href="skype:{$keyval}?call">{$keyval}</a></span>
        <div id="editarea_{$label}" style="display:none;">
            <input class="ld-input-inner" fieldname="{$keyfldname}" module="{$MODULE}" type="text" id="txtbox_{$label}" name="{$keyfldname}" maxlength='100' value="{$keyval}"></input>
        </div>
    &nbsp;</td>
{elseif $keyid eq '230' || $keyid eq '231'}{*zkt 20240119 BUG20240119-14 61-order-bug管理-富文本框字段，压缩后的代码粘贴过来，代码中的“ ， ”保存后会消失 *}
    <td colspan="3" class="wangcan ld-form-item-content lineheight25 uitype230" id="mouseArea_{$label}">{$keyval}</td>
{elseif $keyid eq '19' || $keyid eq '20'  ||$keyid eq '231'} <!--TextArea/Description-->
	<!-- we will empty the value of ticket and faq comment -->
	{if $label eq $MOD.LBL_ADD_COMMENT}
		{assign var=keyval value=''}
	{/if}
    <!--{assign var="DESCRIPTION_SEPARATOR_STRING" value=" "}  {* Separates Description *}-->
	<!--{assign var="DESCRIPTION_WORDWRAP_WIDTH" value="70"} {* No. of chars for word wrapping long lines of Description *}-->
	{if $MODULE eq 'Documents'||$MODULE eq 'Reminds'}
	    <!--To give hyperlink to URL-->
        <td colspan="3" {if $keyid eq '231'} class="ld-form-item-content lineheight25 uitype230" {else} class="ld-form-item-content lineheight25" {/if}>{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>&nbsp;"}&nbsp;
            </td>
    {else}
        <td colspan="3" {if $keyid eq '231'} class="ld-form-item-content lineheight25 uitype230" {else} class="ld-form-item-content lineheight25" {/if} id="mouseArea_{$label}" >
            <span style="color:{$fieldvaluecolor};" id="dtlview_{$label}" name="editarea_{$label}" record='{$ID}' module='{$MODULE}' fieldname='{$keyfldname}' >
                     	{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
            </span>
            <div id="editarea_{$label}"  style="display:none;">
                <textarea placeholder="{$fieldplaceholder}" style="color:{$fieldvaluecolor};" id="txtbox_{$label}" name="{$keyfldname}" class="ld-textarea-inner" rows="4">{$keyval|replace:"<br>":"\n"}</textarea>
            </div>
        </td>
    {/if}
{elseif $keyid eq '21'  || $keyid eq '24' || $keyid eq '22'} <!--TextArea/Street-->
    <td class="ld-form-item-content lineheight25" id="mouseArea_{$label}">
        <span style="color:{$fieldvaluecolor};" id="dtlview_{$label}">{$keyval}</span>
  		<div id="editarea_{$label}" style="display:none;">
  		    <textarea placeholder="{$fieldplaceholder}" style="color:{$fieldvaluecolor};" id="txtbox_{$label}" name="{$keyfldname}" class="ld-textarea-inner" rows=2>{$keyval|regex_replace:"/<br\s*\/>/":""}</textarea>
  		</div>
    &nbsp;</td>
{elseif $keyid eq '59'} <!--ProductPopup-->
    <td class="ld-form-item-content" id="mouseArea_{$label}" >
        <span id="dtlview_{$label}">
            <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
            {* edit: xll 2023/06/08 XUQIU1001203 增加显示超链接属性 *}
            {if $ShowHyperlinks eq 'no' or $keysecid eq 0}
                {$keyval}
            {else}
                <a href="{$keyseclink}">{$keyval}</a>
      	     {/if}
        </span>
  		<div id="editarea_{$label}" style="display:none;">
            <input id="popuptxt_{$label}" name="product_name" readonly type="text" value="{$keyval}"><input id="txtbox_{$label}" name="{$keyfldname}" type="hidden" value="{$keysecid}"><a class="icon-homeimg icon-select" href="javascript:;"  title="{$APP.LBL_SELECT}" onclick='return window.open("index.php?module=Products&action=Popup&html=Popup_picker&form=HelpDeskEditView&popuptype=specific","test","width=600,height=602,resizable=1,scrollbars=1,top=150,left=200");'></a>&nbsp;<input class="icon-homeimg icon-clear inpb-reset" type="button" title="{$APP.LBL_CLEAR}" onclick="this.form.product_id.value=''; this.form.product_name.value=''; return false;"/>
        </div>
      &nbsp;</td>
{elseif $keyid eq '50' || $keyid eq '73' || $keyid eq '51' || $keyid eq '57'|| $keyid eq '96' || $keyid eq '75' || $keyid eq '81' || $keyid eq '76' || $keyid eq '78' || $keyid eq '800' || ($ReferenceUitypes|@is_array && $keyid|@in_array:$ReferenceUitypes)}
    <td class="ld-form-item-content" id="mouseArea_{$label}">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        <input type="hidden" name="{$keyfldname}" value="{$rawvalue}"/>
        {* edit: xll 2023/06/08 XUQIU1001203 增加显示超链接属性 *}
        {if $ShowHyperlinks eq 'no' or $keysecid eq 0}
            {$keyval}
        {else}
            <a href="{$keyseclink}">{$keyval}</a>
	    {/if}
    &nbsp;</td>
{elseif $keyid eq '52' || $keyid eq '77'}
    <td class="ld-form-item-content" id="mouseArea_{$label}" >
        <span style='display:none' name="{$keyfldname}_name" >{$value_name}</span>
        <input type="hidden" name="{$keyfldname}" value="{$keysecid}"/>
        <span id="dtlview_{$label}" fieldname="{$keyfldname}" record="{$ID}" module="{$MODULE}">{$keyval}</span>
        <div id="editarea_{$keyfldname}" style="display:none;">
           <select id="txtbox_{$label}" name="{$keyfldname}" class="small">
                {foreach item=arr key=uid from=$keyoptions}
                    {foreach key=sel_value item=value from=$arr}
                        <option value="{$uid}" {$value}>{if $APP.$sel_value}{$APP.$sel_value}{else}{$sel_value}{/if}</option>
                    {/foreach}
                {/foreach}
           </select>
        </div>
    </td>
{elseif $keyid eq '53'} <!--Assigned To-->
    {*zkt 050028: （https://81mis.com/kfbtest/index.php [^]）服务收费管理》详情，点击销售负责人，界面404*}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
		<span style="display:none" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}">{$keyval}</span>
        <input type="hidden" name="{$keyfldname}" value="{$keysecid}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}"/>
        {if $keyadmin eq 1}
			<a fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}' referencemodule='Users' referencerecord='{$keysecid}' href="index.php?pageto_module=Users&action=index&pageto_record={$keysecid}" onclick="ListReferenceLinkClick(ld(this),event)">{$keyval}</a>
        {else}
            <span id="dtlview_{$keyfldname}_{$MODULE}" fieldname='{$keyfldname}' referencemodule='Users'  referencerecord='{$keysecid}' module='{$MODULE}' record='{$ID}'>{$keyval}</span>
		{/if}              
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}">
			<input type="hidden" id="hdtxt_{$keyfldname}" name="hdtxt_{$keyfldname}" value="{$keyval}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}"/>
			<input name="assigntype" id="assigntype" value="U" onclick="toggleAssignType(this.value),setSelectValue('{$keyfldname}');" type="radio" style="display:none" checked="true"/>
            <span id="assign_user"></span><br/>
            <a href="javascript:;" name="button_{$keyfldname}" fieldonly="{$fieldonly}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
            {'OR'|@getFixedLabel}
            <a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
        </div>
   	</td>
{elseif $keyid eq '100'} <!--Assigned To-->
    {if $MODULE neq 'Reminds'}
		<td class="ld-form-item-content" id="mouseArea_{$label}">
        <span id="dtlview_{$label}">
	{else}
        <td class="ld-form-item-content" id="mouseArea_{$label}">
        <span id="dtlview_{$label}">
    {/if}
            {if $keyadmin eq 1}
				<a href="{$keyseclink.0}">{$keyval}</a>
			{else}
				{$keyval}
			{/if}
		</span>
		<div id="editarea_{$label}" style="display:none;">
			<input type="hidden" id="hdtxt_{$label}" value="{$keyval}"></input>
			{if $keyoptions.0 eq 'User'}
				<span id="assign_user" style="display: block;">
			{else}
				<span id="assign_user" style="display: none;">
			{/if}
       				<select id="txtbox_U{$label}" onchange="setSelectValue('{$label}')" name="{$keyfldname}" class="small">
	                    {foreach item=arr key=id from=$keyoptions.1}
	                    	{foreach key=sel_value item=value from=$arr}
           						 <option value="{$id}" {$value}>{$sel_value}</option>
	                        {/foreach}
	                    {/foreach}
                	</select>
				</span>
			{if $keyoptions.0 eq 'Group'}
				<span id="assign_team" style="display: block;">
			{else}
				<span id="assign_team" style="display: none;">
			{/if}
                   	<select id="txtbox_G{$label}" onchange="setSelectValue('{$label}')" name="assigned_group_id" class="groupname small">
                    {foreach item=arr key=id from=$keyoptions.2}
                    	{foreach key=sel_value item=value from=$arr}
                       		 <option value="{$id}" {$value}>{$sel_value}</option>
                        {/foreach}
                    {/foreach}
                    </select>
        		</span>
        </div>
    </td>
{elseif $keyid eq '99'}<!-- Password Field-->
	<td class="ld-form-item-content">{$CHANGE_PW_BUTTON}</td>	
{elseif $keyid eq '56'} <!--CheckBox-->
    {if $MODULE eq 'Users'}
        {if ($keyfldname == 'select_servicedetail' || $keyfldname == 'select_due_date') && $IS_ADMIN eq true}
            <td class="ld-form-item-content" id="mouseArea_{$label}" {*onMouseOver="hndMouseOver({$keyid},'{$label}');" onmouseout="fnhide('crmspanid');"*}>
                {if $keyfldname eq 'select_servicedetail'}
                    <span id="dtlview_{$label}">{$keyval}&nbsp;
                        <font class="greyFont9">
                            {if 'Accounts'|@vtlib_isModuleActive eq 0 && 'HelpDesk'|@vtlib_isModuleActive eq 1}{'SERVICEINFOREMIND2'|@getFixedLabel}{/if}
                            {if 'Accounts'|@vtlib_isModuleActive eq 1 && 'HelpDesk'|@vtlib_isModuleActive eq 0}{'SERVICEINFOREMIND3'|@getFixedLabel}{/if}
                            {if 'Accounts'|@vtlib_isModuleActive eq 1 && 'HelpDesk'|@vtlib_isModuleActive eq 1}{'SERVICEINFOREMIND'|@getFixedLabel}{/if}
                        </font>
                    </span>
                {else}
                    <span id="dtlview_{$label}">{$keyval}</span>
                {/if}
        {else}
            <td class="ld-form-item-content" {*onMouseOver="hndMouseOver({$keyid},'{$label}');" onmouseout="fnhide('crmspanid');"*}>
            {if $keyfldname eq 'scopeauthority'}
                <a href="javascript:;" onclick="ShowSetUeryScop({$ID});">{'DATASCOPESETTINGS'|@getFixedLabel}</a>
            {else}
                <span id="dtlview_{$label}">{$keyval}&nbsp;
                    {if $keyval neq '否' &&  $keyval neq 'No' && ($keyfldname eq 'accountallview' || $keyfldname eq 'campaignsview')}
                        <font class="greyFont9">( {'UsersALLOWQUERY'|@getFixedLabel} )</font>
                    {/if}
                    {if $keyfldname eq 'login_sms'}
                        <font class="greyFont9">{'NEEDBUYACCOUNT'|@getFixedLabel}</font>
                    {/if}
                </span>
            {/if}
        {/if}
            <div id="editarea_{$label}" style="display:none;">
            	{if $MODULE neq 'Documents'}
                	{if $keyval eq ('YES'|@getFixedLabel)}
                    	<input id="txtbox_{$label}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa;" checked value="1">
                	{else}
                  		<input id="txtbox_{$label}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa;" value="0">
               		{/if}
               	{else}
                 	{if $keyval eq ('YES'|@getFixedLabel)}
                    	<input id="txtbox_{$label}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa;" checked value="0">
                	{else}
                  		<input id="txtbox_{$label}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa;" value="1">
               		{/if}
               	{/if}
                <br>
                <a href="javascript:;" name="button_{$label}" onclick="{if $fieldonly eq 1 } if( dtlViewDuplicate('{$label}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}')){/if} dtlViewAjaxSave('{$label}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
                {'OR'|@getFixedLabel}
                <a href="javascript:;" onclick="hndCancel('dtlview_{$label}','editarea_{$label}','{$label}')">{'CANCEL'|@getFixedLabel}</a>
            </div>
        &nbsp;</td>
    {else}                
        <td class="ld-form-item-content" id="mouseArea_{$label}">
            <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
            <span id="dtlview_{$label}">{$keyval}&nbsp;</span>                      	
        	<div id="editarea_{$label}" style="display:none;">
                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
            	{if $MODULE neq 'Documents'}
                	{if $keyval eq $APP.yes}
                    	<input id="txtbox_{$label}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa;" checked value="1">
                	{else}
                  		<input id="txtbox_{$label}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa;" value="0">
               		{/if}
               	{else}
                 	{if $keyval eq $APP.yes}
                    	<input id="txtbox_{$label}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa;" checked value="0">
                	{else}
                  		<input id="txtbox_{$label}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa;" value="1">
               		{/if}
               	{/if}
            </div>
        </td>
    {/if}
{elseif $keyid eq 201 || $keyid eq 200|| $keyid eq 202|| $keyid eq 204}<!-- for Image Reflection -->
    <td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        {$keyval}&nbsp;
    </td>
{elseif $keyid eq 208}<!-- for Image Reflection -->
    <td class="ld-form-item-content">{$LASTVALINFO}&nbsp;</td>
{elseif $keyid eq 28||$keyid eq 1109}
	<td class="ld-form-item-content lineheight20" colspan="3" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" tag="detailview_image" >
		{include file="DetailView/AttachmentField.tpl"}
        <script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
    </td>
{elseif $keyid eq '156'} <!--CheckBox for is admin-->
    {if $smarty.request.record neq $CURRENT_USERID && $keyadmin eq 1}
        <td class="ld-form-item-content" id="mouseArea_{$label}" ><span id="dtlview_{$label}">{if $APP.$keyval!=''}{$APP.$keyval}{elseif $MOD.$keyval!=''}{$MOD.$keyval}{else}{$keyval}{/if}</span>
            <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
            <div id="editarea_{$label}" style="display:none;">
                {if $keyval eq 'on'}
                    <input id="txtbox_{$label}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa;" checked value="1">
                {else}
                    <input id="txtbox_{$label}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa;" value="0">
               	{/if}
            </div>
	{else}<!--by lingdang-->
		{if $keyval eq 'on'}
            <!-- on和off翻译 by lD Can -->
			<td class="ld-form-item-content">{$APP.on}
        {elseif $keyval eq 'off'}
		 	<td class="ld-form-item-content">{$APP.off}		
        {else}
		 	<td class="ld-form-item-content">
                <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
            {$keyval}
	 	{/if}
	{/if}
    &nbsp;</td>
{elseif $keyid eq 83}<!-- Handle the Tax in Inventory -->
	{foreach item=tax key=count from=$TAX_DETAILS}
    		<td class="ld-form-item-label">{$tax.taxlabel} {$APP.COVERED_PERCENTAGE}&nbsp;</td>
    		<td class="ld-form-item-content" colspan="3">{$tax.percentage}&nbsp;</td>
    	</tr>
	{/foreach}
{elseif $keyid eq 5}
	{* Initialize the date format if not present *}
	{if empty($dateFormat)}
		{assign var="dateFormat" value=$APP.NTC_DATE_FORMAT|@parse_calendardate}
	{/if}
	<td class="ld-form-item-content" id="mouseArea_{$label}" >
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		<span id="dtlview_{$label}" style="color:{$fieldvaluecolor}">{$keyval}&nbsp;</span>
		<div id="editarea_{$label}" style="display:none;">
			<input style="width:113px;color:{$fieldvaluecolor}" size="15" maxlength="10" type="text" id="txtbox_{$label}" name="{$keyfldname}" maxlength='100' value="{$keyval|regex_replace:'/[^-]*(--)[^-]*$/':''}" onClick="WdatePicker()" class="Wdate ld-input-inner"></input>
			<!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_{$keyfldname}">
			<script type="text/javascript">
				Calendar.setup ({ldelim}
					inputField : "txtbox_{$label}", ifFormat : '{$dateFormat}', showsTime : false, button : "jscal_trigger_{$keyfldname}", singleClick : true, step : 1
				{rdelim})
			</script>-->
		</div>
	</td>
{elseif $keyid eq 65}
    <td class="ld-form-item-content lineheight20 a" colspan="3">
        {if $keyval neq ''}
        {*// @edit:dong @date:2020/08/04 @reason: javascript::void(0) 去除一个冒号*}
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}"><a href="javascript:void(0)" title="{$keyval}" onclick="enlarge_map('{$keyval}')">{$keyval}</a></span>&nbsp;
        {/if}
    </td>
    </tr>
{elseif $keyid eq 69}<!-- for Image Reflection -->
	<td class="ld-form-item-content lineheight20" colspan="3" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" tag="detailview_image" >
		{include file="DetailView/AttachmentField.tpl"}
        <script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
    </td>
{elseif $keyid eq 1051}
	<td class="ld-form-item-content">
        <img src="{$keyval}" alt="" title="" LANGUAGE=javascript align="absmiddle" width="100" height="100" ></img><br />
	</td>
{elseif $keyid eq 79}
    <td class="ld-form-item-content" colspan="3">
        <input type="hidden" name="{$keyfldname}" value="{$rawvalue}"/>
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        {$keyval}
    </td>
{elseif $keyid eq 303}
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_advft_criteria" id="{$keyfldname}_advft_criteria" value='{$keyval}'>
		<input type="hidden" name="{$keyfldname}_advft_criteria_groups" id="{$keyfldname}_advft_criteria_groups" value='{$keysecid}'>
		<a class="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setModuleScope('Accounts','{$keyfldname}','{$label}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
		&nbsp;
	</td>
{elseif $keyid eq 304}
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}" id="{$keyfldname}" value='{$keyval}'>
		<a class="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setModuleMinus('{$keyfldname}','{$label}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
		&nbsp;
	</td>
{elseif $keyid eq 305}
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}" id="{$keyfldname}" value='{$keyval}'>
		<a class="" href="javascript:;" title="{'SELECT'|@getFixedLabel}" onclick="setDurationSetting('{$keyfldname}','{$label}','{$MODULE}')">{'SETTINGS'|@getFixedLabel}{'CONDITION'|@getFixedLabel}</a>
		&nbsp;
	</td>
{elseif $keyid eq 131 || $keyid eq 132 || $keyid eq 153 || $keyid eq 180 || $keyid eq 199}
    <td class="ld-form-item-content">
        <!-- <input  type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        <input  type="hidden" name="{$keyfldname}" value="{$value_name}"/> -->
        <span record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}&nbsp;</span>
    </td>
{elseif $keyid eq '222'}
	<td class="ld-form-item-content">
		{if $keyval neq '' && $keysecid neq ''}
			<img src="{$keyval}" alt="" title="" LANGUAGE=javascript align="absmiddle" width="50" height="80" style="transform:rotate(-90deg);"></img><br />
			{'handwritingdatetime'|@getFixedLabel}：{$keysecid}
		{/if}
	</td>
{elseif $keyid eq 1600}
    <td class="ld-form-item-content">
        <span record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}&nbsp;</span>
    </td>
{elseif $keyid eq 1503}
    {*duan 2022-0210 二维码字段增加表单码类型*}
	<td class="ld-form-item-content">
		<a  href="javascript:;" id="dtlview_{$keyfldname}" style="float:left;" onclick="viewFormQrCode('{$MODULE}',{$keyfldid},{$keyid},{$ID})">{'VIEW'|@getFixedLabel}{'SOCIALPROMOTIONQRCODE'|@getFixedLabel}</a>
        {if $keyval >0}
        {*提交日志数量为空时不显示*}
        <a  href="javascript:;"  id="dtlview_{$keyfldname}" style="float:left;margin-left:10px;" onclick="FormQrCode_Viewlog(0,'{$MODULE}',{$keyfldid},{$keyid},{$ID})">{'VIEW'|@getFixedLabel}{'View History'|@getFixedLabel}</a>
        {/if}
    </td>
{else}
	<td class="ld-form-item-content">
        <input record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
        <input record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}"  type="hidden" name="{$keyfldname}" value="{$value_name}"/>
        <span record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="color:{$fieldvaluecolor}">{$keyval}&nbsp;</span>
    </td>
{/if}