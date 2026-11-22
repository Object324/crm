{*<!--修改编码格式:统一编码：UTF-8-->*}
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.config.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/ueditor/ueditor.all.js?v={$GLOBALMINVERSION}"></script>

<form action="index.php" method="post" name="CustomView" id="CustomView" class="ajax_form">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SaveRemindsRule"/>
    <input type="hidden" name="RelatedModuleName" value="{$RelatedModuleName}"/>
    <input type="hidden" name="record" value="{$RECORD}"/>
    <input type="hidden" name="blockid" value="{$BLOCKID}"/>
    <input type="hidden" name="mode" value="{$MODE}"/>
    <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
    <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">{'BASICINFO'|@getFixedLabel}</div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font> {'RULENAME'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input id="remindRuleName" name="remindRuleName" type="text" value="{$ENPARENTTABLELABEL}" class="ld-input-inner"></td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDTIME'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="reminds_time" name="reminds_time" onchange="getdatashow(this);" class="ld-select-inner">
                    {foreach item=stdfilter from=$STDFILTERCOLUMNS}
                        <option {$stdfilter.selected} value={$stdfilter.value}>{$stdfilter.text}</option>   
                    {/foreach}
                    <option value="dothis">{'custom'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
         <tr style="display:none">
            <td class="ld-form-item-label">{'ANNUALREMIND'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
               <input type="checkbox" name="annualremind"/>
            </td>
        </tr>
        <tr style="display:none;" id="showcanlender">
            <td class="ld-form-item-label">
                <font color="red">*</font>{'SETTHESTARTTIME'|@getFixedLabel} 
            </td>
            <td class="ld-form-item-content">
                {* ls 2022-02-07 0049835: 系统设置》自动提醒设置》设置选择提醒参考自定义时间时，选不到具体几时几分*}
                <input type="text" name="startdata" id="jscal_field_date_starts" class="Wdate ld-input-inner" value="" onClick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})" >
                <input id="FieldType"  name="FieldType" type="hidden" value="">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDMODEL'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="reminds_method" name="reminds_method" onchange="RemindsMethod(this);" class="ld-select-inner">
                    <option value="1" >{'FIXEDCYCLE'|@getFixedLabel}</option>
                    <option value="2">{'APPOINTCYCLE'|@getFixedLabel}</option>
                    <option value="3">{'ANNUALREMIND'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <tr class="small">
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDTIMES'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <span id="remindnums">
                    {'EACH'|@getFixedLabel}
                    <input name="remindnums1" id="remindnums1" type="text" value="{$ENPARENTTABLELABEL}" class="ld-input-inner width50">
                    {'Days'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'TIXING'|@getFixedLabel}
                </span>
                <select id="remindsNums" name="remindsNums" onchange="getRemindsnums(this);" class="ld-select-inner width60">
                    <option value="1">1</option>
                    <option value="2">2</option>
                    <option value="3" selected>3</option>
                    <option value="4">4</option>
                    <option value="5">5</option>
                    <option value="6">6</option>
                    <option value="7">7</option>
                    <option value="8">8</option>
                    <option value="9">9</option>
                    <option value="10">10</option>
                    <option value="11">11</option>
                    <option value="12">12</option>
                </select>
                <span id="remindsNums_label">{'TIME1'|@getFixedLabel}</span>
                <input name="method2Nums" id="method2Nums" value="" type="hidden">
                <span id="remindhtml3" style="display:none" >{$remindday3}</span>
                <span class="greyFont9" id="remindrule1">({'FIXEDCYCLEREMINDRULES'|@getFixedLabel})</span>
                <span class="greyFont9" id="remindrule2" style="display:none;">({'REMINDRULESPECIFIEDPERIOD'|@getFixedLabel})</span>
                <span class="greyFont9" id="remindrule3" style="display:none;">({'ANNUALREMINDEXPLAIN'|@getFixedLabel})</span>
                </div>
                <div style="padding-top: 10px;"><span id="remindhtml1"></span></div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDERPEOPLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="reminds_to" name="reminds_to" onchange="AutomaticReminds.reminderChange(this)" class="ld-select-inner">
                    {foreach item=remindinfo  from=$REMINDER_USER_ARRAY.dialog}
                        <option value="{$remindinfo.value}">{$remindinfo.text}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr id="tr_specify_reminder" style="display:none">
            <td class="ld-form-item-label"><font color="red">*</font>{'USERS'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div  id="dv_specify_reminder">
                    <div class="ld-input-inner-div ld-input-inner-add" id="userid_name" name="userid_name"></div>
                    <a class="icon-range" href="javascript:;" title="选择" onclick="getSpecifyUserIds();" style="top: 20px;"></a>
                    <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#userid').val('');ld('#userid_name').text('');return false;">+</a>
                    <input name="userid" id="userid" value="" type="hidden">
                </div>
            </td>
        </tr>
        <tr id="tr_role_name" style="display:none">
			<td class="ld-form-item-label"><font color="red">*</font>{'ROLES'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<input type="text" name="role_name" id="role_name" readonly="true" class="ld-input-inner" value="" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}')"/>
				<input type="hidden" name="user_role" id="user_role" value=""/>
				<a class="icon-range" href="javascript:;" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}');" style="top: 15px;right: 12px;"></a>
                <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#user_role').val('');ld('#role_name').val('');return false;">+</a>
			</td>
		</tr>
        <tr id="tr_position" style="display:none">
			<td class="ld-form-item-label"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<select name="position" class="ld-select-inner">
					{foreach key=key item=item from=$USERLEVELARR}
						<option value="{$key}" {if $APPROVEVALUE == $key} selected{/if}
						>{$item}</option>
					{/foreach}
				</select>
				<span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
			</td>
		</tr>
        <tr id="tr_positionlevel" style="display:none">
			<td class="ld-form-item-label"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<select name="positionlevel" class="ld-select-inner">
					{foreach key=key item=item from=$USERLEVELARR}
						<option value="{$key}" {if $APPROVEVALUE == $key} selected{/if}
						>{$item}</option>
					{/foreach}
				</select>
				<span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
			</td>
		</tr>
        <tr id="tr_positiondepartment" style="display:none">
			<td class="ld-form-item-label"><font color="red">*</font>{'Sector'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
                <input type="hidden" name="positiondepartment1" value=""/>
			</td>
		</tr>
		<tr id="tr_positiondepartment_position" style="display:none">
			<td class="ld-form-item-label"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
			<td class="ld-form-item-content">
				<select name="positiondepartment2" class="ld-select-inner">
					{foreach key=key item=item from=$USERLEVELARR}
                        {if $APPROVEARRAY[1] neq '' && $APPROVEARRAY[1]|@html_entity_decode eq $key|@html_entity_decode}
							<option value="{$key}" selected="">{$item}</option>
                        {else}
                            <option value="{$key}">{$item}</option>
                        {/if}
					{/foreach}
				</select>
				<span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
			</td>
		</tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDMETHOD'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="remind_method" name="remind_method" onchange="AutomaticReminds.auotRemindmethodChange(this)" class="ld-select-inner"></select>
            </td>
        </tr>
        <tr id="SMSVoicearray" style="display:none;">
            <td class="ld-form-item-label"><font color="red">*</font>语音模板</td>
            <td class="ld-form-item-content">
                <select id="SMSVoice_template" name="SMSVoice_template" class="ld-select-inner">
                    {*zxm 2021-0909 阳光创信 语音提醒*}
                    {foreach key=templateId item=templateName from=$SMSVoicearray}
                        <option value="{$templateId}">{$templateName}</option>
                    {/foreach}
                </select>
                <span class="greyFont9">若没有语音模板，请先去接口设置->语音账户设置添加！</span>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'Related_modules'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                {$mokuai_name}
            </td>
        </tr>                   
    </table>

    {if $PlatForm eq 'aliyun'}
        {include file="SmsRemindContent.tpl"}
    {/if}

    <table class="ld-public-content-small" id="reminds_content_table" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">
                        {'REMINDSCONTENT'|@getFixedLabel}
                        <a href="javascript:;" onclick="AutomaticReminds.SetcontentFormat(this,'divSendInform_content')">{'SETTHECONTENTFORMAT'|@getFixedLabel}</a>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-content padL0" style="overflow: inherit;white-space: inherit;">
                <textarea id="reminds_content_text" name="reminds_content_text" class="ld-textarea-inner" type="text"></textarea>
                <script id="reminds_content" name="reminds_content" type="text/plain" style="width:100%;height:100px;"></script>
            </td>
        </tr>
    </table>

    <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td >
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">
                        {'DATARANGE'|@getFixedLabel}{'DataRangeDescription'|@getFixedLabel}
                    </div>
                </div>
            </td>
        </tr>
    </table>

    {assign var=stddiv value="style=display:none"}
    {assign var=advdiv value="style='display:block;padding: 0 24px 10px;'"}
    <div id="dv_autoreminds_stdfilter" class="ld-public-content-small" {$stddiv}>
        <table width="100%" border="0" cellpadding="0" cellspacing="0" align="center" style="display:none">
            <tr><td colspan="2" class="ld-from-headblock"><div class="ld-from-headblock-title">{'EASYTIMEFILTER'|@getFixedLabel}</div></td></tr>
            <tr>
                <td class="ld-form-item-label">{'Select_field'|@getFixedLabel} </td>
                <td class="ld-form-item-content">
                    <select id="stdDateFilterField" name="stdDateFilterField" class="select" onchange="standardFilterDisplay();" style="display:none;">
                        {foreach item=stdfilter name=stdfil from=$STDFILTERCOLUMNS}
                            {if $stdfilter.selected eq 'selected'}
                                {assign var='opttext' value=$stdfilter.text}
                            {/if}
                            {if $smarty.foreach.stdfil.first}
                                {assign var='optDefault' value=$stdfilter.text}
                            {/if}
                            <option {$stdfilter.selected} value={$stdfilter.value}>{$stdfilter.text}</option>   
                        {/foreach}
                    </select>
                    <div name="dv_chzn_stdDateFilterField" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'stdDateFilterField','dv_autoreminds_stdfilter')" style="z-index:999;">
                        <a class="chzn-single" onclick="com_img_change(event,'stdDateFilterField','dv_autoreminds_stdfilter')" href="javascript:void(0)" tabindex="-1"
                         name="cmb_a_stdDateFilterField" style="width:190px;">
                            <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 190px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_stdDateFilterField' onclick="cmb_picklist_end_foucs(event,'stdDateFilterField','dv_autoreminds_stdfilter')" onKeyUp="com_chosen(event,'stdDateFilterField','dv_autoreminds_stdfilter')" value="{if $opttext neq ''}{$opttext}{else}{$optDefault}{/if}">
                            <div><b></b></div>
                        </a>
                        <div style="left:-9000px; top: 25px;width:198px;" class="chzn-drop" name='dv_drop_stdDateFilterField' >
                             <ul class="chzn-results" name="cmb_ul_stdDateFilterField">
                                {assign var="i" value=0}
                               {foreach item=stdfilter from=$STDFILTERCOLUMNS }
                                   <li class="active-result" name="dv_chzn_{$i}_stdDateFilterField" onclick="cmb_liclick('{$stdfilter.value}','stdDateFilterField','dv_autoreminds_stdfilter')" onmouseover="cmb_limouseover(event,'stdDateFilterField','dv_autoreminds_stdfilter')">{$stdfilter.text}</li>
                                   {assign var="i" value=$i+1}
                                {/foreach}
                                   <li name="li_chzn_stdDateFilterField" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                             </ul>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'SELECT_TIME'|@getFixedLabel} </td>
                <td class="ld-form-item-content">
                    <select name="stdDateFilter" id="stdDateFilter" class="select" onchange='showDateRange(this.options[this.selectedIndex].value )' style="display:none;">
                        {assign var=special value='/\d+/'}
                        {assign var=normal_last value='/last/'}
                        {assign var=normal_before value='/before/'}
                        {assign var=normal_next value='/next/'} 
                        {assign var=day value='Days'|@getFixedLabel}
                        {assign var=last value='LAST'|@getFixedLabel}
                        {assign var=before value='DAYSAGO'|@getFixedLabel }
                        {assign var=future value='FUTURE'|@getFixedLabel }
                        {assign var=after value='AFTERDAY'|@getFixedLabel }       
                        {foreach item=duration from=$STDFILTERCRITERIA}
                                {if isset($special) &&isset($duration.text) && isset($matches) && $special|preg_match:$duration.text:$matches eq 1}
                                   {assign var=normal_number value=$matches[0]}
                                   {if $normal_last|preg_match:$duration.text eq 1}                                   
                                       {if $duration.selected eq 'selected'}
                                         {assign var=optText value=$last|cat:$normal_number|cat:$day}
                                       {/if}
                                       <option {$duration.selected} value="{$duration.value}">{$last}{$normal_number}{$day}</option>
                                   {elseif $normal_before|preg_match:$duration.text eq 1} 
                                       {if $duration.selected eq 'selected'}
                                         {assign var=optText value=$normal_number|cat:$before}
                                       {/if}                                  
                                      <option {$duration.selected} value="{$duration.value}">{$normal_number}{$before}</option>
                                   {elseif $normal_next|preg_match:$duration.text eq 1} 
                                       {if $duration.selected eq 'selected'}
                                         {assign var=optText value=$future|cat:$normal_number|cat:$day}
                                       {/if}                                   
                                       <option {$duration.selected} value="{$duration.value}">{$future}{$normal_number}{$day}</option>
                                   {else} 
                                        {if $duration.selected eq 'selected'}
                                          {assign var=optText value=$normal_number|cat:$after}
                                        {/if}                                       
                                       <option {$duration.selected} value="{$duration.value}">{$normal_number}{$after}</option>
                                   {/if}  
                                {else}
                                       {if $duration.selected eq 'selected'}
                                          {assign var=optText value=$duration.text|@getFixedLabel}
                                        {/if} 
                                        <option {$duration.selected} value="{$duration.value}">{$duration.text|@getFixedLabel}</option>
                                {/if}                                            
                        {/foreach}
                    </select>
                    <div name="dv_chzn_stdDateFilter" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'stdDateFilter','dv_autoreminds_stdfilter')" style="z-index:990;">
                        <a style="width:110px;" class="chzn-single" onclick="com_img_change(event,'stdDateFilter','dv_autoreminds_stdfilter')" href="javascript:void(0)" tabindex="-1"
                         name="cmb_a_stdDateFilter">
                            <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_stdDateFilter' onclick="cmb_picklist_end_foucs(event,'stdDateFilter','dv_autoreminds_stdfilter')" onKeyUp="com_chosen(event,'stdDateFilter','dv_autoreminds_stdfilter')" value="666">
                            <div><b></b></div>
                        </a>
                        <div style=" left:-9000px;width: 118px; top: 25px;" class="chzn-drop" name='dv_drop_stdDateFilter' >
                            <ul class="chzn-results" id="cmb_ul_stdDateFilter">                                      
                                {assign var=special value='/\d+/'}
                                {assign var=normal_last value='/last/'}
                                {assign var=normal_before value='/before/'}
                                {assign var=normal_next value='/next/'}
                                {assign var="j" value=0}
                                {foreach key=User_Key item=duration from=$STDFILTERCRITERIA }                                                          
                                     {if isset($special) &&isset($duration.text) && isset($matches) && $special|preg_match:$duration.text:$matches eq 1}
                                       {assign var=normal_number value=$matches[0]}
                                       {if $normal_last|preg_match:$duration.text eq 1} 
                                            <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_autoreminds_stdfilter')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_autoreminds_stdfilter')">{'LAST'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</li>
                                       {elseif $normal_before|preg_match:$duration.text eq 1}                                     
                                           <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_autoreminds_stdfilter')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_autoreminds_stdfilter')">{$normal_number}{'DAYSAGO'|@getFixedLabel}</li>
                                       {elseif $normal_next|preg_match:$duration.text eq 1}                                   
                                            <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_autoreminds_stdfilter')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_autoreminds_stdfilter')">{'FUTURE'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</li>
                                       {else}                                      
                                            <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_autoreminds_stdfilter')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_autoreminds_stdfilter')">{$normal_number}{'AFTERDAY'|@getFixedLabel}</li>
                                       {/if}  
                                    {else}
                                        <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','dv_autoreminds_stdfilter')" onmouseover="cmb_limouseover(event,'stdDateFilter','dv_autoreminds_stdfilter')">{$duration.text|@getFixedLabel}</li>
                                    {/if}   
                                    {assign var="j" value=$j+1}
                                {/foreach}
                                <li style="" class="" name="li_chzn_stdDateFil    ter" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                            </ul>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'Start_Date'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    {if $STDFILTERCRITERIA.0.selected eq "selected" || $CUSTOMVIEWID eq ""}
                        {assign var=img_style value="visibility:visible"}
                        {assign var=msg_style value=""}
                    {else}
                        {assign var=img_style value="visibility:hidden"}
                        {assign var=msg_style value="readonly"}
                    {/if}
                    <input name="startdate" id="jscal_field_date_start" type="text" size="15" readonly="readonly" class="Wdate ld-input-inner" value="{$STARTDATE}" {$msg_style} onClick="WdatePicker()">
                    <font size=1><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'End_Date'|@getFixedLabel} </td> 
                <td class="ld-form-item-content">
                    <input name="enddate" {$msg_style} id="jscal_field_date_end" type="text" size="15" readonly="readonly" class="Wdate ld-input-inner" value="{$ENDDATE}" onClick="WdatePicker()">
                    <font size=1><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
                </td>
            </tr>
        </table>
    </div>
    <div id="mnuTab2" class="ld-public-content-big" {$advdiv}>
        <div style="overflow:auto;" name="adv_filter_div">
            
        </div>
    </div>
</form>

<input type="hidden" name="reminder_user_array_json" id="reminder_user_array_json" value="{$REMINDER_USER_ARRAY_JSON}" />
<input type="hidden" name="remindmethod_array_json" id="remindmethod_array_json" value="{$REMINDEMETHOD_ARRAY}" />
{*遮罩层div*}
<div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
    <div id="divSendInform_content_div"></div>
</div>
{$STDFILTER_JAVASCRIPT}

<script language="javascript" type="text/javascript">

function productmandatoryCheck()
{ldelim}
    var mandatorycheck = false;
    var i,j;
    var manCheck = new Array({$MANDATORYCHECK});
    var showvalues = "{$SHOWVALUES}";
    if(manCheck)
    {ldelim}
        var isError = false;
        var errorMessage = "";
        var productinfo = "";
        var PageWidth = document.getElementById('PageWidthPercent').value;
        var selObj=document.getElementById('selectedAssmablyColumns');
        if (trim(document.CustomView.viewName.value) == "")
        {ldelim}
                isError = true;
                errorMessage += "\n{$MOD.LBL_VIEW_NAME}";
        {rdelim}
        // Here we decide whether to submit the form.
        if (isError == true)
        {ldelim}
        /*
        edit:cdw
        date:20130801
        reason:
        */
            var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        {rdelim}
        if(PageWidth == "" || PageWidth == null)
        {ldelim}
            var confirm_str = arrJsPopLabel['PERCENTAGEWIDTHCANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        {rdelim}
        if(isNaN(PageWidth))
        {ldelim}
            var confirm_str = arrJsPopLabel['PERCENTAGEONLYDIGITAL'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        {rdelim}
        if(selObj.options.length == 0)
        {ldelim}
            var confirm_str = arrJsPopLabel['SELECTATLEASTONE'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        {rdelim};
        for (var i=0;i<selObj.options.length;i++)
        {ldelim}
            productinfo+=selObj.options[i].value+",";
        {rdelim}
        document.getElementById('ProductListView').value = productinfo;
		if(document.getElementById('more_listview') != undefined && document.getElementById('more_listview').value == 0)
        {ldelim}
		for(i=1;i<=9;i++)
            {ldelim}
                var columnvalue = document.getElementById("column"+i).value;
                if(columnvalue != null)
                {ldelim}
                    for(j=0;j<manCheck.length;j++)
                    {ldelim}
                            if(columnvalue == manCheck[j])
                            {ldelim}
                                    mandatorycheck = true;
                            {rdelim}
                    {rdelim}
                    if(mandatorycheck == true)
                    {ldelim}
        				if(($("jscal_field_date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0) || ($("jscal_field_date_end").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0))
        					return stdfilterdateValidate();
        				else
        					return true;
                    {rdelim}
                    else
                    {ldelim}
                            mandatorycheck = false;
                    {rdelim}
                {rdelim}
            {rdelim}
        {rdelim}
        else
        {ldelim}
            return true; 
        {rdelim}
  {rdelim}
        if(mandatorycheck == false)
        {ldelim}
                var confirm_str = arrJsPopLabel['ATLEASTCHOOSEREQUIREDFIELD']+'\n'+showvalues;
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        {rdelim}
        
        return false;
{rdelim}
function mandatoryCheck()
{ldelim}
    var mandatorycheck = false;
    var i,j;
    var manCheck = new Array({$MANDATORYCHECK});
    var showvalues = "{$SHOWVALUES}";
    if(manCheck)
    {ldelim}
        var isError = false;
        var errorMessage = "";
        if (trim(document.CustomView.viewName.value) == "")
        {ldelim}
                isError = true;
                errorMessage += "\n{$MOD.LBL_VIEW_NAME}";
        {rdelim}
        // Here we decide whether to submit the form.
        if (isError == true)
        {ldelim}
        /*
        edit:cdw
        date:20130801
        reason:
        */
            var confirm_str = arrJsPopLabel['CATEGORYNAMECANOTEMPTY'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
        {rdelim}
		if(document.getElementById('more_listview') != undefined && document.getElementById('more_listview').value == 0)
        {ldelim}
		for(i=1;i<=9;i++)
            {ldelim}
                var columnvalue = document.getElementById("column"+i).value;
                if(columnvalue != null)
                {ldelim}
                    for(j=0;j<manCheck.length;j++)
                    {ldelim}
                            if(columnvalue == manCheck[j])
                            {ldelim}
                                    mandatorycheck = true;
                            {rdelim}
                    {rdelim}
                    if(mandatorycheck == true)
                    {ldelim}
        				if(($("jscal_field_date_start").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0) || ($("jscal_field_date_end").value.replace(/^\s+/g, '').replace(/\s+$/g, '').length!=0))
        					return stdfilterdateValidate();
        				else
        					return true;
                    {rdelim}
                    else
                    {ldelim}
                            mandatorycheck = false;
                    {rdelim}
                {rdelim}
            {rdelim}
        {rdelim}
        else
        {ldelim}
            return true; 
        {rdelim}
  {rdelim}
        if(mandatorycheck == false)
        {ldelim}
            var confirm_str = arrJsPopLabel['ATLEASTCHOOSEREQUIREDFIELD']+'\n'+showvalues;
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        {rdelim}
        
        return false;
{rdelim}
</script>