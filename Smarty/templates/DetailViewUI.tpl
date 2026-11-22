<!--修改编码格式:统一编码：UTF-8-->
{if $keyid eq '1'||$keyid eq '11' || $keyid eq 2 || $keyid eq '7' || $keyid eq '9' || $keyid eq '55' || $keyid eq '71' || $keyid eq '72' || $keyid eq '255' ||$keyid eq "400" || $keyid eq '161'} <!--TextBox-->
	{if $keyfldname eq "approveby" }<!--  称谓字段不可编辑 -->
    	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
        	<input type="hidden" name="{$keyfldname}_name" module="{$MODULE}" value='{$last_name[0].last_name}' record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="color:{$fieldvaluecolor}"/>
    {elseif $KEHU001DEFAULT eq 'yes'&& ($keyfldname eq 'wx_userid'|| $keyfldname eq 'last_name')}
        <input type="hidden" name="{$keyfldname}_name" value="{$value_name}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="color:{$fieldvaluecolor}"/>
        <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
	{elseif $keyfldname eq 'supportname' }
		<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
        	<input type="hidden" name="{$keyfldname}_name"  record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}"  value="{$value_name}" style="color:{$fieldvaluecolor}"/>
    {else}
    	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}"  onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        <input style="color:{$fieldvaluecolor}" placeholder="{$fieldplaceholder}"  type="hidden" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" value="{$value_name}"/>
    {/if}
	{assign var="iskeyvalueselt" value="0"}
	{if $keyid eq '55' || $keyid eq '255'}<!--SalutationSymbol-->
    	{assign var=notaccess value='NOTACCESS'|@getFixedLabel}
		{if $keyaccess eq $notaccess}
			<font color='red'>{'NOTACCESS'|@getFixedLabel}</font>
		{else}
			<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{if is_string($keyval)}{$keyval|@htmlentities}{/if}</span>
			{if $keyval != ''}
				{assign var="iskeyvalueselt" value="1"}
			{/if}
		{/if}
	{/if}
    {if $keyid eq 11 && $USE_ASTERISK eq 'true'}
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}"><a href='javascript:;' record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" onclick='startCall("{$keyval}", "{$ID}")'>{$keyval}</a></span>
	{else}
        {if $keyfldname eq "approveby"}
		{*@edit:liushuai,2020-12-23,reason:43786: （61mis.com/kfbcrm）系统设置-成员管理-详情；打开成员详情编辑，启用审批委托，选择委托人确认后，显示空白；保存再次打开成员详情才正常显示(标签没有fieldname导致页面数据没有更新完)*}
        {* zkt 20230317 BUG0063133 成员管理，设置审批委托人保存后，查看界面“审批人委托人”显示乱码 *}
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" >{$keyval}</span>
        <input type="hidden" name="approveby" id="approveby" value="{$rawvalue}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" />
        {elseif $iskeyvalueselt == '0'}
            {if $keyfldname eq "phone" }
            <span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}"  record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" name="dtlview_{$keyfldname}">{$keyval}</span>
            {elseif ($keyid eq '71' || $keyid eq '72') && $keyfldname !='unit_price'&& $keyfldname != 'procostprice'}
				<span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" >{$keyval}&nbsp;</span>
			{elseif $keyid eq '2'}
				<span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}"  name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}</span>
            {else}
				{if $keyfldname eq 'recovery_endremarks'}
					<span id="dtlview_{$keyfldname}"  name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}</span>
				{else}
					<span style="color:{$fieldvaluecolor}" id="dtlview_{$keyfldname}"  name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{if is_string($keyval)}{$keyval|@htmlentities}{/if}</span>
				{/if}
            {/if}
        {/if}
	{/if}
    {if $keyfldname eq 'express_no'}
        {*合同订单、出库单物流单号显示查询按钮*}{*ls 2022-05-11 【1002809】页面设置，增加“快递查询组件”字段类型*}
        <i id="logistics_query" onclick="express_no_query(this)" title="{'QUERYTO'|@getFixedLabel}" class="ld-fonticon ld-fonticon-wuliu" {if $keyval eq ''}style="display:none;"{/if}></i>
    {/if}
	{if $keyid eq 11 && $keyval != '' && $keyfldname != 'approveby'}
		<i class='callcenterImg ld-fonticon ld-fonticon-phone' style='display:none;' key_recordid='{$ID}' key_module='{$MODULE}' keyval='{$keyval}' tag='{$keycolname}' key_tablename= '{$keytblname}' key_detailrecordid=''> </i>
	{/if}
    {* zkt 20221124 BUG0059141客户信息，点击编辑客户信息，原有信息的字段变成空白（王肖丽：测试应该是由于“”引号引起的）*}
    {if $keyid eq 1}
		{if !empty($rawvalue)}
			{$rawvalue = $rawvalue|replace:"\"":"&quot;"}
		{else}
			{$rawvalue = ""}
		{/if}
    {/if}
	{*zkt 20241202 BUG20241129-35 仓库管理-产品清单：产品详情页面点击产品描述字段编辑时，录入长文本会进行截断（见图二），但是其他大编辑、小编辑都是正常的（见图一） *}
    <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
        <input placeholder="{$fieldplaceholder}" class="ld-input-inner" fieldname="{$keyfldname}" module="{$MODULE}"
          record="{$ID}" type="text" id="txtbox_{$keyfldname}" name="{$keyfldname}"
          value="{$rawvalue}" style="margin-top: 5px;color:{$fieldvaluecolor};"/>
        <div style="line-height: 36px;">
			<a href="javascript:;" id="butt_{$keyfldname}" name="button_{$keyfldname}" onclick=" dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
			{'OR'|@getFixedLabel}
			<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
		</div>
    </div>
    {if $keyid eq '71' && $keyfldname eq 'unit_price'}
    	{if $PRICE_DETAILS|@count > 0}
			<span id="multiple_currencies" name="multiple_currencies" width="38%" style="align:right;">
				<a href="javascript:void(0);" onclick="toggleShowHide('currency_class','multiple_currencies');">{$APP.LBL_MORE_CURRENCIES} &raquo;</a>
			</span>
    		<div id="currency_class" class="multiCurrencyDetailUI">
				<table width="100%" height="100%" class="small" cellpadding="5">
				<tr>
					<th colspan="2">
						<b>{'PRODUCT_PRICES'|@getFixedLabel}</b>&nbsp;
					</th>
					<th align="right">
						<a class="icon-homeimg icon-close" href="javascript:;" onclick="toggleShowHide('multiple_currencies','currency_class');"></a>
					</th>
				</tr>
				<tr class="detailedViewHeader">
					<th>{'Currency'|@getFixedLabel}&nbsp;</th>
					<th colspan="2">{'Price'|@getFixedLabel}&nbsp;</th>
				</tr>
				{foreach item=price key=count from=$PRICE_DETAILS}
					<tr>
						{*if $price.check_value eq 1*}
						<td class="ld-form-item-label">
							{$price.currencylabel|@getTranslatedCurrencyString} ({$price.currencysymbol})&nbsp;
						</td>
						<td class="ld-form-item-content">
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
{elseif $keyid eq 14}
	{* editor:gyqX160815 reason:新增uitype=14时间类型的处理 Bug:0023800: 页面设置>付款计划>页面设置：新增一个【时间】类型的字段，编辑单据明细界面的时间字段保存后没有值，点击字段后的小【编辑】按钮，没有显示时间控件 *}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="" >
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="color:{$fieldvaluecolor}">
            {$keyval}
        </span>
	    <input type="hidden" name="{$keyfldname}_name" value="{$rawvalue}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}"/>
	    <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
	        <input type="text" tabindex="{$vt_tab}" size='20' fieldonly='{$fieldonly}' name="{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' value="{$rawvalue}" class="Wdate ld-input-inner" onClick="WdatePicker({ldelim}dateFmt:'HH:mm:ss'{rdelim});" style="width:170px;color:{$fieldvaluecolor}">
	        <div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
				{'OR'|@getFixedLabel}
				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>
	    </div>
    </td>
{elseif $keyid eq 1108}
    <td class="ld-form-item-content lineheight20" id="mouseArea_{$keyfldname}" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' tag="detailview_image">
        {include file="DetailView/AttachmentField.tpl"}
    </td>
	{*// @edit:dong @date:2020/07/22 @reason: 附件管理模块明细界面，附件字段，点击查看图片附件，增加图片预览插件；*}
	<script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
{elseif $keyid eq '13' || $keyid eq '104'} <!--Email-->
    <td class="ld-form-item-content lineheight20" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        {*20230510 zkt BUG0065676  	kfbcrm 成员管理---查看界面小编辑email---点保存/取消----都显示空值，需要刷新页面才显示 *}
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">
	      <input type="hidden" name="{$keyfldname}_name" value="{$value_name}" fieldname="{$keyfldname}" module="{$MODULE}"/>
    	{if 'Emails'|@vtlib_isModuleActive eq 1}
			{if $smarty.session.internal_mailer eq 1}
				<a href="javascript:;" onclick="send_EMail_popup(this,'{$keyfldname}')" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="float: left;">{$keyval}</a>
			{else}
				<a href="mailto:{$keyval}" target="_blank" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}</a>
			{/if}
		{else}
			{$keyval}
		{/if}
        {if $keyid eq 13 && $keyval neq '' && 'Emails'|@vtlib_isModuleActive eq 1}
        	<i id="emailimg" style="display:;" class="ld-fonticon ld-fonticon-mail padL5" onclick="send_EMail_popup(this,'{$keyfldname}')"></i>
        {elseif $keyid eq 13 && $keyval eq ''&& 'Emails'|@vtlib_isModuleActive eq 1}
        	<i id="emailimg" style="display:none" class="ld-fonticon ld-fonticon-mail padL5" onclick="send_EMail_popup(this,'{$keyfldname}')"></i>
        {/if}
		</span>                
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
        	<input class="ld-input-inner" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" type="text" id="txtbox_{$keyfldname}" name="{$keyfldname}" maxlength='100' value="{$keyval}" style="margin-top: 5px;"></input>
        	<div style="line-height: 36px;">
			<a href="javascript:;" name="button_{$keyfldname}" onclick=" dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
			{'OR'|@getFixedLabel}
        	<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			<div>
        </div>              
       <div id="internal_mailer_{$keyfldname}" style="display: none;">{$keyfldid}####{$smarty.session.internal_mailer}</div>
	</td>
{elseif $keyid eq '15'} 
    {assign var=notaccess value='NOTACCESS'|@getFixedLabel}
	{foreach item=arr from=$keyoptions}
		{if $arr[0] eq $notaccess && $arr[2] eq 'selected'}
			{assign var=keyval value=$notaccess}
			{assign var=fontval value='red'}
		{else}
            {assign var=fontval value=''}
		{/if}
	{/foreach}
    {assign var=editHref value=0}
	{*wym BUG0074447 后台设置--角色权限--未设置“职位级别”权限，但是账号可以在单据详情界面对“职位级别”字段进行小编辑，并保存*}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" {if $editHref eq 1 ||($JOBLEVEL_PERMIT eq 'no' && $keyfldname=='userlevel') } {else} onmouseover="hndMouseOver({$keyid},'{$keyfldname}');"{/if} onmouseout="">
        <span style="color:{$pick_color}" id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">
            <font color="{$fontval}">
                {if $keyfldname eq 'approvestatus'}
                    {$keyval}
                    {if $keyval eq 'INACTIVATE'|@getFixedLabel}
						<input type="hidden" id="approvestatus_show" name="approvestatus_show" value="1"/>
					{else}
						<input type="hidden" id="approvestatus_show" name="approvestatus_show" value="0"/>
					{/if}
                {else}
					{if !empty($keyval)}
						{$keyval|@html_entity_decode}
					{/if}
                {/if}
            </font>
        </span>
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
		    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" style='margin:0px;'>
            	<tr>
            		<td style='border-style: none;'>
            			{assign var='fldname' value=$keyfldname}
                    	<div class="row-fluid"  id="dv_cmb_{$fldname}"   >
                    		<span class="span10">
                    			<input name="{$fldname}" type="hidden" tabindex="{$vt_tab}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" fieldonly='{$fieldonly}'  value="{$keyval}"  style="display:none">
                    		   	<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="width: 285px;" onMouseLeave="cmb_mouseleave(event,'{$fldname}','editarea_{$keyfldname}')">
                    				<a class="chzn-single" onclick="CrmPopup.getPopupObj('last').picklist_arrow_click(event,'{$fldname}')" href="javascript:void(0)" tabindex="-1" name="cmb_a_{$fldname}">
                    					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" fieldname="{$keyfldname}" module="{$MODULE}" style="color:{$pick_color};width: 280px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$fldname}')" onKeyUp="CrmPopup.getPopupObj('last').picklistobjarray['{$fldname}'].com_chosen(event)" value="{$keyval}">
                    						{if $keyfldname eq 'approvestatus'}
												{if $keyval eq 'INACTIVATE'|@getFixedLabel}
													<input type="hidden" id="approvestatus_show" name="approvestatus_show" value="1"/>
												{else}
													<input type="hidden" id="approvestatus_show" name="approvestatus_show" value="0"/>
												{/if}
                    						{/if}
                    					<div>
                    						<b></b>
                    					</div>
                    				</a>
                    				<div style=" left:-9000px;width: 280px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                    				 	<ul class="chzn-results" name="cmb_ul_{$fldname}">
                                            {* 个人信息详细 审批委托 下拉框没有值，原因是PHP中判断清空值*}
                                            {if $fldname == 'approvestatus'}
                                                <li style="" class="active-result" name="dv_chzn_1_{$fldname}" onclick="cmb_liclick('0','{$fldname}','editarea_{$keyfldname}');" onmouseover="cmb_limouseover(event,'{$fldname}','editarea_{$keyfldname}')">{'ACTIVATE'|@getFixedLabel}</li>
                                                <li style="" class="active-result" name="dv_chzn_2_{$fldname}" onclick="cmb_liclick('1','{$fldname}','editarea_{$keyfldname}');" onmouseover="cmb_limouseover(event,'{$fldname}','editarea_{$keyfldname}')">{'INACTIVATE'|@getFixedLabel}</li>
                                            {else}
												{if $keyid eq '153'}
													{foreach item=arr from=$keyoptions name=foo}
														<li style="" class="active-result" name="dv_chzn_{$smarty.foreach.foo.iteration}_{$fldname}" onclick="cmb_liclick('{$arr[1]}','{$fldname}','');" onmouseover="cmb_limouseover(event,'{$fldname}','editarea_{$keyfldname}')">{$arr[0]}</li>
													{/foreach}
												{else}
												{/if}
                                            {/if}
                    				 	</ul>
                    				</div>
                    			</div>
                    		</span>
                    	 </div>
            		</td>
            	</tr>
            	<tr>
            		<td style='border-style: none;' class="bgnone">
            			<a href="javascript:;" name="button_{$keyfldname}" onclick=" dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
            			{'OR'|@getFixedLabel}
            			<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
            		</td>
            	</tr>
            </table>
        </div>
	</td>
{elseif $keyid eq '153'} 
    {assign var=notaccess value='NOTACCESS'|@getFixedLabel}
	{foreach item=arr from=$keyoptions}
		{if $arr[0] eq $notaccess && $arr[2] eq 'selected'}
			{assign var=keyval value=$notaccess}
			{assign var=fontval value='red'}
		{else}
            {assign var=fontval value=''}
		{/if}
	{/foreach}
    {assign var=editHref value=0}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" {if $editHref eq 1 } {else} onmouseover="hndMouseOver({$keyid},'{$keyfldname}');"{/if} onmouseout="">
     	<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}">
        	<font color="{$fontval}">{$keyval}</font>
        </span>
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
		    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" style='margin:0px;'>
            	<tr>
            		<td style='border-style: none;'>
            			{assign var='fldname' value=$keyfldname}
                    	<div class="row-fluid"  id="dv_cmb_{$fldname}"  >
                    		<span class="span10">
                    			<select name='{$fldname}' id='{$fldname}' style='display:none;'>
                					{foreach item=arr from=$keyoptions name=keyoptionsloop}
                						{if $smarty.foreach.keyoptionsloop.first}
                							{assign var="keyoptsvalue" value=$arr[0]}
                						{/if}
                					    {if $arr[0] eq $notaccess}
          						            <option value="{$arr[0]}" {$arr[2]}>{$arr[0]}</option>
                					    {else}
                    						<option value="{$arr[1]}" {$arr[2]}>{$arr[0]}</option>
                					    {/if}
                					{/foreach}
                    			</select>
                    		   	<div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" style="width: 285px;"  onMouseLeave="cmb_mouseleave(event,'{$fldname}','editarea_{$keyfldname}')">
                    				<a class="chzn-single" onclick="com_img_change(event,'{$fldname}','editarea_{$keyfldname}')" href="javascript:void(0)" tabindex="-1"
                    				 name="cmb_a_{$fldname}">
                    					<input class="commonDetailedTextBox bgwhite" type="text" 
                                        style="width:280px;margin-left: -10px;border-style:none;" 
                                        name="cmb_span_optiontext_{$fldname}" fieldname="{$keyfldname}"  
                                        onclick="CrmPopup.getPopupObj('last').picklist_end_foucs(event,'{$keyfldname}')" onKeyUp="com_chosen(event,'{$fldname}','editarea_{$keyfldname}')" value="{$keyval}" module="{$MODULE}">
                    					<div>
                    						<b></b>
                    					</div>
                    				</a>
									{*wym BUG20240523-41 单选用户小编辑的时候，下拉框挡了一小部分输入框了*}
                    				<div style=" left:-9000px;/*width: 280px; top: 20px;*/" class="chzn-drop" name='dv_drop_{$fldname}'>
                    				 	<ul class="chzn-results" name="cmb_ul_{$fldname}">
								            {assign var='i' value=0}
											{foreach item=arr from=$keyoptions name=foo}
												<li style="" class="active-result" name="dv_chzn_{$i}_{$fldname}" onclick="cmb_liclick('{$arr[1]}','{$fldname}','');" onmouseover="cmb_limouseover(event,'{$fldname}','editarea_{$keyfldname}')">{$arr[0]}</li>
											   	{assign var='i' value=$i+1}
                                            {/foreach}
                    						<li style="" class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                    				 	</ul>
                    				</div>
                    			 </div>
                    		 </span>
                    	</div>
            		</td>
            	</tr>
            	<tr>
            		<td style='border-style: none;' class="bgnone">
            			   <a href="javascript:;" name="button_{$keyfldname}" onclick=" dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
            			   {'OR'|@getFixedLabel}
            			   <a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
            		</td>
            	</tr>
            </table>
        </div>
		</td>
{elseif $keyid eq '16' || $keyid eq '31' || $keyid eq '32'} 
    {assign var=notaccess value='NOTACCESS'|@getFixedLabel}
	{foreach item=arr from=$keyoptions}
		{if $arr[0] eq $notaccess && $arr[2] eq 'selected'}
			{assign var=keyval value=$notaccess}
			{assign var=fontval value='red'}
		{else}
            {assign var=fontval value=''}
		{/if}
	{/foreach}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" fieldname="{$keyfldname}" module="{$MODULE}">
            <font color="{$fontval}">
                {if $keyfldname eq 'level'}
                    {if $keyval eq '0'}
                       {'ORDINARYUSER'|@getFixedLabel}  
                    {elseif $keyval eq '1'}
                        {'MANAGER'|@getFixedLabel}
                    {elseif $keyval eq '2'}
                        {'DEPUTYMANAGER'|@getFixedLabel}
                    {/if}
                    <input type="hidden" id="level_value" name="level_value" value="{$keyval}"/>
                {elseif $keyfldname eq 'approvestatus'}
                    {if $keyval eq '1'}
                        {'INACTIVATE'|@getFixedLabel}
                    {else $keyval eq '0'}
						{'ACTIVATE'|@getFixedLabel}
                    {/if}
                    <input type="hidden" id="approvestatus_show" name="approvestatus_show" value="{$keyval}"/>
                {else}
                    {$keyval}
                {/if}
            </font>
        </span>
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
		    <table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" style='margin:0px;'>
            	<tr>
            		<td style='border-style: none;'>
            			{assign var='fldname' value=$keyfldname}
            			<div class="row-fluid" id="dv_cmb_{$fldname}"  >
                    		<span class="span10">
                    			<select name='{$fldname}' id='{$fldname}' fieldname="{$keyfldname}" module="{$MODULE}" class="detailedViewSelect bgwhite" >
                    				{if $label eq 'Level'}                                   
                    						{foreach key=key item=value from=$level} 
                    						   <option value="{$key}">{$value}</option>
                    						{/foreach}
                    				{elseif $keyfldname eq 'approvestatus'}
                    						{foreach key=key item=value from=$approvestatus}
                    						   <option value="{$key}">{$value}</option>
                    						{/foreach}
                    				{else}
                    					{foreach item=arr from=$keyoptions name=keyoptionsloop}
                    						{if $smarty.foreach.keyoptionsloop.first}
                    							{assign var="keyoptsvalue" value=$arr[0]}
                    						{/if}
                        					{if $arr[0] eq $notaccess}
                        						<option value="{$arr[0]}" {$arr[2]}>{$arr[0]}</option>
                        					{else}
                        						<option value="{$arr[1]}" {$arr[2]}>{$arr[0]}</option>
                        					{/if}
                    					{/foreach}
                    				{/if}
                    			</select>
                    		</span>
                    	</div>
                    </td>
            	</tr>
            	<tr>
            		<td style='border-style: none;' class="bgnone">
            			<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
            			{'OR'|@getFixedLabel}
            			<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
            		</td>
            	</tr>
            </table>
		</div>
	</td>
{elseif $keyid eq '33'}<!--Multi Select Combo box-->
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">
			{$keyval}
        </span>
        <!--code given by Neil End-->
      	<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
            <div style="height: 5px;"></div>
            <select MULTIPLE id="txtbox_{$keyfldname}" name="{$keyfldname}" class="select2 inputElement form-control   select2-offscreen"  size="4" style="width:201px;">    
                {foreach item=arr from=$keyoptions}
                    {if $arr[1] neq ''}
                        <option value="{$arr[1]}" {$arr[2]}>{$arr[0]}</option>
                    {/if}
                {/foreach}
			</select>
            <script type="text/javascript">
                ld(function () {ldelim}
                    ld("#txtbox_{$keyfldname}").select2({ldelim}closeOnSelect: false{rdelim});
                {rdelim}); 
            </script>
            <div style="padding: 10px 0;">
               	<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
               	{'OR'|@getFixedLabel}
              	<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>
        </div>
	</td>
{elseif $keyid eq '34'}<!--Multi Select Combo box-->
	{assign var='fldname' value=$keyfldname}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
		<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">
			{$keyval}
		</span>
		<!--code given by Neil End-->
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
			<div class="ld-input-inner-div"  onclick="show_related_picklist('{$fldname}')" name="cmb_a_{$fldname}" draggable="false" style="overflow: hidden;cursor: pointer;padding-right: 10px;" >
				<ul id="cmb_ul_{$fldname}" name="cmb_ul_{$fldname}" class="ld-input-inner-div-items">
					{foreach key=tmp_index item=tmp_arr  from=$keyoptions}
						<li class="ld-input-inner-div-item userlevel-fontstyle" style="color: #666;" >
							<span class="item-name">{$tmp_arr.name}</span>
							<span class="item-name">:{$tmp_arr.value}</span>
							<span class="remove-h" onclick="cancel_related_picklist('{$fldname}','{$tmp_arr.id}')">×</span>
						</li>
					{/foreach}
				</ul>
			</div>
			<div class="userlevel-showstyle" id="dv_{$fldname}" name="dv_{$fldname}" style="display: none;width: calc(100% - 20px);" onclick="event.stopPropagation();" ></div>
			<div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
				{'OR'|@getFixedLabel}
				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>

			<input type="hidden" from_fieldname="groupid" id="{$fldname}" name="{$fldname}" value="{$rawvalue}">
			<input type="hidden" from_fieldname="groupid" id="jsonvalue_{$fldname}" name="jsonvalue_{$fldname}" value="{$json_value}">
		</div>
	</td>
{elseif $keyid eq '115'} <!--ComboBox Status edit only for admin Users-->
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" fieldname="{$keyfldname}" module="{$MODULE}" value="{$value_name}"/>
        {$keyval}
    </td>
	<!--0013815: 付款单/收款单--明细,关于小编辑编辑币种的问题-->
{elseif $keyid eq '116' || ($keyid eq '117' && ($MODULE neq 'CashBill'&&$MODULE neq 'SendCashBill' && $MODULE neq 'Commission' && $MODULE neq 'CashDeposit' && $MODULE neq 'PutCash' && $MODULE neq 'PriceBooks'))} <!--ComboBox currency id edit only for admin Users-->
	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
    {if $keyadmin eq 1 || $keyid eq '117'}
        <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout=""><span id="dtlview_{$keyfldname}">{$keyval}</span>
			<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
               	<select id="txtbox_{$keyfldname}" name="{$keyfldname}" class="small" style="margin-top: 5px;">
					{foreach item=arr key=uivalueid from=$keyoptions}
						{foreach key=sel_value item=value from=$arr}
							<option value="{$uivalueid}" {$value}>{$sel_value|@getTranslatedCurrencyString}</option>
						{/foreach}
					{/foreach}
	           	</select>
			   	<div style="line-height: 36px;">
					<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
					{'OR'|@getFixedLabel}
          		   	<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
				</div>
			</div>
		</td>
	{else}
		<td class="ld-form-item-content">{$keyval}&nbsp;</td>
	{/if}
{elseif $keyid eq '17'} <!--WebSite-->
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
      	<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}"><a href="{$keyval}" target="_blank">{$keyval}</a></span>
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
  			<input class="ld-input-inner" onkeyup="validateUrl('{$keyfldname}');" type="text" id="txtbox_{$keyfldname}" name="{$keyfldname}" placeholder="{$fieldplaceholder}" maxlength='100' value="{$keyval}" style="margin-top: 5px;"></input>
  			<div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
				{'OR'|@getFixedLabel}
  				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
		  	</div>
        </div>
    </td>
{elseif $keyid eq '85'}<!--Skype-->
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">{$keyval}</span>
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
          	<input class="ld-input-inner" type="text" id="txtbox_{$keyfldname}" name="{$keyfldname}" maxlength='100' value="{$keyval}" style="margin-top: 5px;"></input>
          	<div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a> {'OR'|@getFixedLabel}
				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
		  	</div>
       </div>
    &nbsp;</td>
{elseif $keyid eq '19' || $keyid eq '20'|| $keyid eq '230'|| $keyid eq '231'} <!--TextArea/Description-->
	<!-- we will empty the value of ticket and faq comment -->
	{if $label eq $MOD.LBL_ADD_COMMENT}
		{assign var=keyval value=''}
	{/if}						
	{if $MODULE eq 'Documents'||$MODULE eq 'Reminds'}<!--To give hyperlink to URL-->
        <td colspan="3" {if $keyid eq '230'|| $keyid eq '231'} class="ld-form-item-content lineheight25 uitype230" {else} class="ld-form-item-content lineheight25" {/if} >{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
        &nbsp;</td>
	{else}
        <td colspan="3" {if $keyid eq '230'|| $keyid eq '231'} class="ld-form-item-content lineheight25 uitype230" {else} class="ld-form-item-content lineheight25" {/if} name="mouseArea_{$keyfldname}" id="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        	<span style="color:{$fieldvaluecolor};" name="dtlview_{$keyfldname}"  record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}'>
             	{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":"<br>"}
            </span>
            <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
				<textarea placeholder="{$fieldplaceholder}" id="txtbox_{$keyfldname}" name="{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' class="ld-textarea-inner" rows="8" style="margin-top: 5px;color:{$fieldvaluecolor};">{$keyval|replace:"<br>":"\n"}</textarea>
                <input type="hidden" id="txtbox_{$keyfldname}" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}'  value='{$keyval|replace:"<br>":"\n"}'>
				<div style="line-height: 36px;">
					<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
					{'OR'|@getFixedLabel}
					<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
				</div>
            </div>
        </td>
	{/if}
{elseif $keyid eq '21' || $keyid eq '24' || $keyid eq '22'} <!--TextArea/Street-->
	<td class="ld-form-item-content lineheight25" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        <input type="hidden" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' value="{$value_name}"/>
		<span style="color:{$fieldvaluecolor};" id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}'>{$keyval|regex_replace:"/(^|[\n ])([\w]+?:\/\/.*?[^ \"\n\r\t<]*)/":"\\1<a href=\"\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])((www|ftp)\.[\w\-]+\.[\w\-.\~]+(?:\/[^ \"\t\n\r<]*)?)/":"\\1<a href=\"http://\\2\" target=\"_blank\">\\2</a>"|regex_replace:"/(^|[\n ])([a-z0-9&\-_.]+?)@([\w\-]+\.([\w\-\.]+\.)*[\w]+)/i":"\\1<a href=\"mailto:\\2@\\3\">\\2@\\3</a>"|regex_replace:"/,\"|\.\"|\)\"|\)\.\"|\.\)\"/":"\""|replace:"\n":""}</span>
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
            <textarea placeholder="{$fieldplaceholder}" id="txtbox_{$keyfldname}" name="{$keyfldname}" class="ld-textarea-inner" rows=2 style="margin-top: 5px;color:{$fieldvaluecolor};">{$keyval|regex_replace:"/<br\s*\/>/":""}</textarea>
			<div style="line-height: 36px;">
  				<a href="javascript:;" name="button_{$keyfldname}" fieldonly="{$fieldonly}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
  				{'OR'|@getFixedLabel}
  				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>
		</div>
	</td>
{elseif $keyid eq '50' || $keyid eq '73' || $keyid eq '173' || $keyid eq '51' || $keyid eq '57'|| $keyid eq '96' || $keyid eq '75' || $keyid eq '81' || $keyid eq '76' || $keyid eq '78' || $keyid eq '800' || $keyid eq '801' || $keyid eq '240' || $keyid eq '241' || $keyid eq '243' || $keyid eq '150' ||$keyid eq '58'||$keyid eq '97' || (is_array($ReferenceUitypes) && $keyid|@in_array:$ReferenceUitypes)}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
        <input type="hidden" name="{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule="{$UITYPEMODULES[$keyid]}" referencerecord="{$rawvalue}" value="{$keysecid}"/>
        <input type="hidden" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule="{$UITYPEMODULES[$keyid]}" referencerecord="{$rawvalue}" value="{$value_name}"/>
        {if $keysecid>0}
            {$keyval}
      	{else}
        	<span record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule="{$UITYPEMODULES[$keyid]}" referencerecord="{$rawvalue}">{$keyval}</span>
      	{/if}
    </td>
{elseif $keyid eq '80'}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
       	<input type="hidden" name="{$keyfldname}" record="{$rawvalue}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule="{$UITYPEMODULES[$keyid]}" referencerecord="{$rawvalue}" value="{$keysecid}"/>
        <input type="hidden" name="{$keyfldname}_name" record="{$rawvalue}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule="{$UITYPEMODULES[$keyid]}" referencerecord="{$rawvalue}" value="{$value_name}"/>
        {if $keysecid>0}
            {$keyval}
      	{else}
        	<span record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule="{$UITYPEMODULES[$keyid]}" referencerecord="{$rawvalue}">{$keyval}</span>
      	{/if}
  &nbsp;</td>
{elseif $keyid eq '59'} <!--ProductPopup-->
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" >
		<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">
			{* edit: xll 2023/06/08 XUQIU1001203 增加显示超链接属性 *}
			{if $ShowHyperlinks eq 'no' or $keysecid eq 0}
		  		{$keyval}
			{else}
		  		<a record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' referencemodule='Products' referencerecord="{$keysecid}" href="{$keyseclink}">{$keyval}</a>
		  	{/if}
		</span>
	&nbsp;</td>
{elseif $keyid eq '137'} <!--ProductPopup-->
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" >
		<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
		<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">
          	{* edit: xll 2023/06/08 XUQIU1001203 增加显示超链接属性 *}
          	{if $ShowHyperlinks eq 'no' or $keysecid eq 0}
            	{$keyval}
          	{else}
            	<a record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' href="{$keyseclink}">{$keyval}</a>
      	  	{/if}
		</span>
	&nbsp;</td>
{elseif $keyid eq '52' || $keyid eq '77' ||$keyid eq '103'}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="editarea_{$keyfldname}">
		<span style="display:none" name="{$keyfldname}_name" >{$value_name}</span>
		<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">{$keyval}</span>
	&nbsp;</td>
{elseif $keyid eq '251' || $keyid eq '252'}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onMouseOver="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="" >
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" >
			{$keyval}
		</span>
        <input type="hidden" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" value="{$value_name}"/>
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
            <table width="100%" border="0" cellspacing="0" cellpadding="0" align="left" style='margin:0px;'>
              	<tr>
                    <td style='border-style: none;'>
                        <span id="assign_user" >
                            <select name="{$keyfldname}" id="{$keyfldname}" class="small">
                                {foreach item=arr key=id from=$keyoptions}
                                    <option text="{$arr.1}" value="{$arr.0}" {$arr.2}>{$arr.1}</option>
                                {/foreach}
                            </select>
                        </span>
                    </td>
              	</tr>
              	<tr>
                    <td style='border-style: none;' class="bgnone">
                      	<a href="javascript:;" name="button_{$keyfldname}" fieldonly="{$fieldonly}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
                      	{'OR'|@getFixedLabel}
                      	<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
                    </td>
              	</tr>
            </table>      
        </div>
	</td>
{elseif $keyid eq '53'} <!--Assigned To-->
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}">
		<span style="display:none" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}">{$keyval}</span>
        	<input type="hidden" name="{$keyfldname}" value="{$keysecid}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}"/>
            {if $keyadmin eq 1}
				<a fieldname='{$keyfldname}' module='{$MODULE}' record='{$ID}' referencemodule='Users' referencerecord='{$keysecid}' href="index.php?pageto_module=Users&action=index&pageto_record={$keysecid}" onclick="ListReferenceLinkClick(ld(this),event)">{$keyval}</a>
            {else}
                <span id="dtlview_{$keyfldname}_{$MODULE}" fieldname='{$keyfldname}' referencemodule='Users'  referencerecord='{$keysecid}' module='{$MODULE}' record='{$ID}'>
				    {$keyval}
                    </span>
			{/if}
			<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}">
				<input type="hidden" id="hdtxt_{$keyfldname}" name="hdtxt_{$keyfldname}" value="{$keyval}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" referencemodule='Users' referencerecord="{$keysecid}"/>
				<input name="assigntype" id="assigntype" value="U" onclick="toggleAssignType(this.value),setSelectValue('{$keyfldname}');" type="radio" style="display:none" checked="true"/>
                    <span id="assign_user">
                    </span>
			        <br/>
                    <a href="javascript:;" name="button_{$keyfldname}" fieldonly="{$fieldonly}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
                    {'OR'|@getFixedLabel}
                   	<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
            </div>
    </td>
{elseif $keyid eq '100'} <!--Assigned To-->
    {if $MODULE neq 'Reminds'}
		<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout=""><span id="dtlview_{$keyfldname}">
	{else}
        <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}"><span id="dtlview_{$keyfldname}">
    {/if}
	    {if $keyadmin eq 1}
			<a href="{$keyseclink.0}">{$keyval}</a>
		{else}
			{$keyval}
		{/if}
		</span>
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
			<input type="hidden" id="hdtxt_{$keyfldname}" name="hdtxt_{$keyfldname}" value="{$keyval}"></input>
			{if $keyoptions.0 eq 'User'}
				<span id="assign_user" style="display: block;">
			{else}
				<span id="assign_user" style="display: none;">
			{/if}
       				<select id="txtbox_U{$keyfldname}" onchange="setSelectValue('{$keyfldname}')" name="txtbox_U{$keyfldname}" class="small">
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
					<select style="margin-top: 5px;" id="txtbox_G{$keyfldname}" onchange="setSelectValue('{$keyfldname}')" name="assigned_group_id" class="groupname small">
						{foreach item=arr key=id from=$keyoptions.2}
							{foreach key=sel_value item=value from=$arr}
								<option value="{$id}" {$value}>{$sel_value}</option>
							{/foreach}
						{/foreach}
					</select>
				</span>
				<div style="line-height: 36px;">
					<a href="javascript:;" name="button_{$keyfldname}" fieldonly="{$fieldonly}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
					{'OR'|@getFixedLabel}
					<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
				</div>
    	</div>
    </td>
{elseif $keyid eq '99'}<!-- Password Field-->
    <td class="ld-form-item-content">{$CHANGE_PW_BUTTON}&nbsp;</td>	
{elseif $keyid eq '56'} <!--CheckBox-->
    {if $MODULE eq 'Users'}
        {if ($keyfldname == 'select_servicedetail' || $keyfldname == 'select_due_date' || strstr($keyfldname,'cf')) && $IS_ADMIN eq true}
            <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onMouseOver="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
            	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
				<span name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" >{$keyval}&nbsp;</span>
        {else}
          	<!--bug0012256 -->
            <td class="ld-form-item-content" fld="{$keyfldname}">
             	<input type="hidden" name="{$keyfldname}_name" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' value="{$value_name}"/>
                {if $keyfldname eq 'scopeauthority'}
                  <a href="javascript:;" onclick="ShowSetUeryScop({$ID});">{'DATASCOPESETTINGS'|@getFixedLabel}</a>
                {else}
                <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module='{$MODULE}' >{$keyval}
				{/if}
                {if $keyfldname eq 'select_servicedetail'}
                <font class="greyFont9">
                {if 'Accounts'|@vtlib_isModuleActive eq 0 && 'HelpDesk'|@vtlib_isModuleActive eq 1}{'SERVICEINFOREMIND2'|@getFixedLabel}{/if}
                {if 'Accounts'|@vtlib_isModuleActive eq 1 && 'HelpDesk'|@vtlib_isModuleActive eq 0}{'SERVICEINFOREMIND3'|@getFixedLabel}{/if}
                {if 'Accounts'|@vtlib_isModuleActive eq 1 && 'HelpDesk'|@vtlib_isModuleActive eq 1}{'SERVICEINFOREMIND'|@getFixedLabel}{/if}
                </font>
                {/if}
				<!--{*
				    注释是允许查看用户全景的，其余的多选框不需要显示
				    @project PROT180 角色权限改进
				    @author tujt 2015-03-23
				*}-->
                {if $keyfldname eq 'login_sms'}
                    <font class="greyFont9">{'NEEDBUYACCOUNT'|@getFixedLabel}</font>
                {/if}
                </span>
        {/if}
        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
         	{if $keyval eq ('YES'|@getFixedLabel)}
            	<input id="txtbox_{$keyfldname}" name="{$keyfldname}" type="checkbox" record="{$ID}"
					   fieldname="{$keyfldname}" module='{$MODULE}' style="border:1px solid #bababa; margin-top: 5px;" checked value="0" class="second_switch {$keyval}">
        	{else}
          		<input id="txtbox_{$keyfldname}" type="checkbox" name="{$keyfldname}" record="{$ID}"
					   fieldname="{$keyfldname}" module='{$MODULE}' style="border:1px solid #bababa; margin-top: 5px;" value="1" class="second_switch {$keyval}">
       		{/if}
			<div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
				{'OR'|@getFixedLabel}
				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>
        </div>
        </td>
    {else}
        <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onMouseOver="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
        	<span name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}</span>
	        <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
		    	{if $MODULE neq 'Documents'}
		        	{if $keyval eq ('YES'|@getFixedLabel)}
		            	<input id="txtbox_{$keyfldname}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa; margin-top: 5px;" checked value="1" class="second_switch">
		        	{else}
		          		<input id="txtbox_{$keyfldname}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa; margin-top: 5px;" value="0" class="second_switch">
		       		{/if}
		       	{else}
		         	{if $keyval eq ('YES'|@getFixedLabel)}
		            	<input id="txtbox_{$keyfldname}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa; margin-top: 5px;" checked value="0" class="second_switch">
		        	{else}
		          		<input id="txtbox_{$keyfldname}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa; margin-top: 5px;" value="1" class="second_switch">
		       		{/if}
		       	{/if}
		        <div style="line-height: 36px;">
					<a href="javascript:;" name="button_{$keyfldname}" onclick=" dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
					{'OR'|@getFixedLabel}
					<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
				</div>
	        </div>
        </td>
    {/if}
{elseif $keyid eq '156'} <!--CheckBox for is admin-->
	{if $smarty.request.record neq $CURRENT_USERID && $CURRENT_USERID eq 1}
        <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onMouseOver="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
            <span name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}</span>
            <div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
                {if ($keyval|@is_admin) || $keyval eq 'YES'|@getFixedLabel}
                    <input id="txtbox_{$keyfldname}" name="{$keyfldname}" type="checkbox" style="border:1px solid #bababa; margin-top: 5px;" checked value="1" class="second_switch">
                {else}
                	<input id="txtbox_{$keyfldname}" type="checkbox" name="{$keyfldname}" style="border:1px solid #bababa; margin-top: 5px;" value="0" class="second_switch">
               	{/if}
				<div style="line-height: 36px;">
					<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
					{'OR'|@getFixedLabel}
					<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
				</div>
            </div>
	{else}<!--by lingdang-->
		{if $keyval eq 'on'}
			<td class="ld-form-item-content">&nbsp;{$APP.on}
		{elseif $keyval eq 'off'}
	 		<td class="ld-form-item-content">&nbsp;{$APP.off}
	 	{else}
	 		<td class="ld-form-item-content">&nbsp;{$keyval}
	 	{/if}
	{/if}
    &nbsp;</td>
{elseif $keyid eq 83}<!-- Handle the Tax in Inventory -->
	{foreach item=tax key=count from=$TAX_DETAILS}
		<td class="ld-form-item-label">
			{$tax.taxlabel}(%)&nbsp;
		</td>
		<td class="ld-form-item-content" colspan="3">
			{$tax.percentage}&nbsp;
		</td>
	</tr>
	{/foreach}
{elseif $keyid eq 5}
	{if empty($dateFormat)}
		{assign var="dateFormat" value='(yyyy-mm-dd)'|@parse_calendardate}
	{/if}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="" >
		<span record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" name="dtlview_{$keyfldname}" style="color:{$fieldvaluecolor}">
			{$keyval}
		</span>
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
			<!--chj:autocomplete="off" 时间控件内 鼠标放入不下拉显示历史信息-->
			<input class="Wdate ld-input-inner" size="15" maxlength="10" type="text" 
            id="txtbox_{$keyfldname}" autocomplete="off"
            record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}"
             name="{$keyfldname}" maxlength='100' 
             value="{$rawvalue|regex_replace:'/[^-]*(--)[^-]*$/':''}"
             onClick="WdatePicker({ldelim}onpicked:function(){ldelim}datePickerChanged('{$keyfldname}'){rdelim}{rdelim})" style="width:113px;color:{$fieldvaluecolor}" />
			<div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
				{'OR'|@getFixedLabel}
				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>
		</div>
	</td>
{elseif $keyid eq 69}<!-- for Image Reflection -->
	<td class="ld-form-item-content lineheight20" colspan="3" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" tag="detailview_image">
	    {include file="DetailView/AttachmentField.tpl"}
       	</td>
   	<script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
{elseif $keyid eq 79}<!-- 服务单选择常见问题 -->
	<td class="ld-form-item-content" colspan="3">
    	<input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
    	{$keyval}
    </td>
{elseif $keyid eq 201 || $keyid eq 200 || $keyid eq 202 || $keyid eq 204}<!-- for Image Reflection -->
    <input type="hidden" name="{$keyfldname}_name" value="{$value_name}"/>
    <input type="hidden" name="selectlistval_label" value="{$value_name}"/>
	<td class="ld-form-item-content">{$keyval}&nbsp;
	    {if $LASTVALINFO neq ''}
	        <input type="hidden" name="salesorder_id" value="10"/>
	    {/if}
     </td>
{elseif $keyid eq 208}<!-- for Image Reflection -->
	<td class="ld-form-item-content">{$LASTVALINFO}&nbsp;</td>
{elseif $keyid eq '230'}          
    <td class="ld-form-item-content">{$keyval}&nbsp;</td>
{elseif $keyid eq 1101 || $keyid eq 1102 || $keyid eq 1103}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}"  onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
		<input tag="{$_readonly}" type="hidden" name="{$keyfldname}_name" value="{$value_name}" style="color:{$fieldvaluecolor}"/>
	    {if ''|@getSMSAutographStatus eq 'true' && 'MassSMS'|vtlib_isModuleActive eq 'true'}
			<input type="hidden" value="1" name="{$keyfldname}_ismobile" />
		{else}
			<input type="hidden" value="2" name="{$keyfldname}_ismobile" />
		{/if}
    	<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">
        <span tag="zkt" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="color:{$fieldvaluecolor}">{$keyval}</span>
        {if $keyid eq 1101 && $keyval neq ''}  
            {if ''|@getSMSAutographStatus eq 'true' && 'MassSMS'|vtlib_isModuleActive eq 'true'}
				<i class="ld-fonticon ld-fonticon-phone" id="{$MODULE}_img_{$keyfldname}" onclick="getMassSmsPopup('{$keyval}')"></i>
			{/if}
             <!--{*
				 给电话、手机字段增加外呼标签
				 @project 天润呼叫中心集成
				 @author tujt 2014-05-15
			  *}-->
				<i class='callcenterImg ld-fonticon ld-fonticon-phone' style='display:none;' key_recordid='{$ID}' key_module='{$MODULE}' keyval='{$keyval}' tag='{$keycolname}' key_tablename= '{$keytblname}' key_detailrecordid= ''></i>
		    {* editor:gyqX160602 *}
        {elseif $keyid eq 1102 && $keyval neq ''}
           	<i class='callcenterImg ld-fonticon ld-fonticon-phone' style='display:none;' key_recordid='{$ID}' key_module='{$MODULE}' keyval='{$keyval}' tag='{$keycolname}' key_tablename= '{$keytblname}' key_detailrecordid=''></i>
        {elseif $keyid eq 1101 && $keyval eq '' && 'MassSMS'|vtlib_isModuleActive eq 'true'}
            <i id="{$MODULE}_img_{$keyfldname}" class="ld-fonticon ld-fonticon-phone" style="display:none" onclick="getMassSmsPopup('{$keyval}')"></i>
        {/if}
        {if $keyid eq 1103 && $keyval neq ''}
            <a style="display:block;float:left;" href="tencent://message/?uin={$keyval}&Menu=yes"  target="blank">
                <img border="0" src='./themes/icon/qqenable.jpg' width="20" height="20" style="margin-left:5px;"/>
            </a>
        {/if}
    </span>
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
	 	{if $keyid eq 1101}
        	<input class="ld-input-inner" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" onkeyup="validateUrl('{$keyfldname}');" type="text" id="{$MODULE}_txtbox_{$keyfldname}" name="{$keyfldname}" maxlength='100' value="{$rawvalue}" style="margin-top: 5px;color:{$fieldvaluecolor}"/>
     	{else}
        	<input class="ld-input-inner" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" onkeyup="validateUrl('{$keyfldname}');" type="text" id="txtbox_{$keyfldname}" name="{$keyfldname}" maxlength='100' value="{$keyval}" style="margin-top: 5px;color:{$fieldvaluecolor}"/>
     	{/if}
      	<input class="ld-input-inner" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" type="hidden" id="hdd_txtbox_{$keyfldname}" name="hdd_{$keyfldname}" value="{$rawvalue}"/>                          
		<div style="line-height: 36px;">
			<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
			{'OR'|@getFixedLabel}
			<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}','{$keyid}')" >{'CANCEL'|@getFixedLabel}</a>
		</div>
    </div>
{elseif $keyid eq 28||$keyid eq 1109}
 	<td class="ld-form-item-content lineheight20" colspan="3" module='{$MODULE}' record='{$ID}' fieldname='{$keyfldname}' id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" tag="detailview_image">
	    {include file="DetailView/AttachmentField.tpl"}
    </td>
	{*// @edit:dong @date:2020/07/22 @reason: 模块明细界面，附件字段，点击查看图片附件，增加图片预览插件；*}
	<script language="JavaScript" type="text/javascript">previewImage(document.getElementById('mouseArea_{$keyfldname}'))</script>
{elseif $keyid eq 86}
    {if empty($dateFormat)}
		{assign var="dateFormat" value='(yyyy-mm-dd)'|@parse_calendardate}
	{/if}
	<td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}"  onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="" >
		{* edit: xll 2024/10/10 时间字段的准确值取 rawvalue  *}
		<input  type="hidden" name="{$keyfldname}_name" value="{$rawvalue}" style="color:{$fieldvaluecolor}"/>
        <span id="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" name="dtlview_{$keyfldname}" style="color:{$fieldvaluecolor}">
			{$keyval}
		</span>
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
			<input name="{$keyfldname}" id="txtbox_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}" style="width:170px;color:{$fieldvaluecolor}" size="15" maxlength="25" value="{$rawvalue}" onClick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})" class="Wdate ld-input-inner">
            <div class="clear"></div>
			<div style="line-height: 36px;">
				<a href="javascript:;" name="button_{$keyfldname}" onclick="dtlViewAjaxSave('{$keyfldname}','{$MODULE}',{$keyid},'{$keytblname}','{$keyfldname}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
				{'OR'|@getFixedLabel}
				<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
			</div>
		</div>
	</td>
{elseif $MODULE eq 'Users' && $label eq '附件'}
{elseif $keyid eq 105}
    <td class="ld-form-item-content" id="mouseArea_{$keyfldname}" name="mouseArea_{$keyfldname}" onmouseover="hndMouseOver({$keyid},'{$keyfldname}');" onmouseout="">
		{*//@edit:liushuai,2020-09-10,reason:【ID1000998】/成员管理上传个人头像后应该立即更新已上传的图片（编辑保存后刷新详情界面的个人头像，updatesamemodule里面对象是根据fieldname获取的）*}
		{*<span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">{$keyval}</span>&nbsp;*}
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" record="{$ID}" fieldname="{$keyfldname}" module="{$MODULE}">{$keyval}</span>&nbsp;
		{*<div style="display:none" class="UploadhiddenInput" >
			<input type="hidden" value="1"  name="{$keyfldname}-file_num">
			<input type="text" name="{$keyfldname}-file_size_1" class="hiddenInput" value="">
			<input type="text" name="{$keyfldname}-file_name_1" class="hiddenInput" value="">
			<input type="text" name="{$keyfldname}-file_path_1" class="hiddenInput" value="">
			<input type="text" name="{$keyfldname}-file_type_1" class="hiddenInput" value="">
			<input type="text" name="{$keyfldname}-newfile_name_1" class="hiddenInput" value="">
			<input type="text" name="{$keyfldname}-storage_location_1" class="hiddenInput" value="">
			<input type="text" name="{$keyfldname}-cloud_path_1" class="hiddenInput" value="">
		</div>*}
		<div id="editarea_{$keyfldname}" name="editarea_{$keyfldname}" style="display:none;">
				<input name="{$keyfldname}" id="{$keyfldname}"  type="file" value="{$maindata[3].0.name}" tabindex="{$vt_tab}" onchange="validateFilename(this);" />
				<input name="{$keyfldname}_hidden"  type="hidden" value="{$maindata[3].0.name}" />
				<input type="hidden" name="id" value=""/>
				{$maindata[3].0.name}
				<div class="clear"></div>
				<div style="line-height: 36px;">
					<a href="javascript:;" name="button_{$keyfldname}" onclick="upload_image('{$keyfldname}','{$MODULE}','{$ID}');">{'SAVE'|@getFixedLabel}</a>
					{'OR'|@getFixedLabel}
					<a href="javascript:;" onclick="hndCancel('dtlview_{$keyfldname}','editarea_{$keyfldname}','{$keyfldname}')">{'CANCEL'|@getFixedLabel}</a>
				</div>
		</div>
	</td>
{elseif $keyid eq 601}
    <td class="ld-form-item-content">
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">{$keyval}</span>
    &nbsp;</td>
{elseif $keyid eq 1051}
	<td class="ld-form-item-content">
	   <img src="{$keyval}" alt="" title="" LANGUAGE=javascript align="absmiddle" width="100" height="100" ></img><br />
	</td>
{elseif $keyid eq 154 || $keyid eq 242}
    <td class="ld-form-item-content">
       <span name="{$keyfldname}_name" style="display:none"> {$value_name}</span>
        <span fieldname="{$keyfldname}" name="dtlview_{$keyfldname}" module='{$MODULE}' record='{$ID}' class="lineheight25">{$keyval}</span>
    </td>
{elseif $keyid eq 125}
    <td class="ld-form-item-content lineheight20">
        <input  type="hidden" name="{$keyfldname}_name" value=""/>
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}">{$keyval}</span>
    &nbsp;</td>  
{elseif $keyid eq 65}{*地图字段*}
    <td class="ld-form-item-content lineheight20" colspan="3">
		{if $keyval neq ''}
		{*// @edit:dong @date:2020/08/04 @reason: javascript::void(0) 去除一个冒号*}
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}"><a href="javascript:void(0)" title="{$keyval}" onclick="enlarge_map('{$keyval}')">{$keyval}</a></span>&nbsp;
		{/if}
    </td>
{elseif $keyid eq 152 ||$keyid eq 180}
    <td class="ld-form-item-content">
        <span style='display:none'  name="{$keyfldname}_name" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}">{$value_name}bb</span>
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}">{$keyval}</span>
    &nbsp;</td>
{elseif $keyid eq 112}
	<td class="ld-form-item-content">
        <input  type="hidden" name="{$keyfldname}_name" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}" value="{$ID}"/>
        <input  type="hidden" name="{$keyfldname}" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}" value="{$ID}"/>
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}">{$keyval}</span>
    &nbsp;</td>
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
{else}
	<td class="ld-form-item-content">
        <input type="hidden" name="{$keyfldname}_name" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}" value="{$value_name}"/>
        <input type="hidden" name="{$keyfldname}" module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}" value="{$value_name}"/>
        <span id="dtlview_{$keyfldname}" name="dtlview_{$keyfldname}" aa module="{$MODULE}" record="{$ID}" fieldname="{$keyfldname}">{$keyval}</span>
    &nbsp;</td>
{/if}