{*<!--修改编码格式:统一编码：UTF-8-->*}
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/modules/Approve/Approve.js?v={$GLOBALMINVERSION}"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/AutomaticReminds.js?v={$GLOBALMINVERSION}"></script>

<script>
    var fLabels = new Array();
    fLabels['e'] = '{'EQ'|@getFixedLabel}';
    fLabels['n'] = '{'NEQ'|@getFixedLabel}';
    fLabels['c'] = '{'IN'|@getFixedLabel}';
    fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
    fLabels['l'] = '{'LT'|@getFixedLabel}';
    fLabels['g'] = '{'GT'|@getFixedLabel}';
    fLabels['m'] = '{'LE'|@getFixedLabel}';;
    fLabels['h'] = '{'GE'|@getFixedLabel}';
    fLabels['bw'] = '{'Interval'|@getFixedLabel}';
    fLabels['b'] = '{'Before'|@getFixedLabel}';
    fLabels['a'] = '{'After'|@getFixedLabel}';
    fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
    fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
    var tmpstr='{$DATETIMESTR}';
    var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
</script>

<form action="index.php" method="post" name="CustomView" id="CustomView" class="ajax_form">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="action" value="SaveRemindsRule"/>
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
            <td class="ld-form-item-label"><font color="red">*</font>{'RULENAME'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><input id="remindRuleName" name="remindRuleName" type="text" value="{$remindRuleName}" class="ld-input-inner"></td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDTIME'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="reminds_time" name="reminds_time" class="ld-select-inner" onchange="getdatashow(this);">
                    {foreach item=stdfilter from=$STDFILTERCOLUMNS}
                        <option {if $columnname eq  $stdfilter.value}selected{/if} value={$stdfilter.value}>{$stdfilter.text}</option>
                    {/foreach}
                    <option value="dothis" {if $columnname eq 'dothis'} selected {/if}>{'custom'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <tr style="display:none">
            <td class="ld-form-item-label">{'ANNUALREMIND'|@getFixedLabel} </td>
            <td class="ld-form-item-content">
                <input type="checkbox" name="annualremind"{if $annualremind eq 'yes'} checked=""{/if} />
            </td>
        </tr>
        <tr {if $columnname eq 'dothis'} {else} style="display:none;" {/if} id="showcanlender">
            <td class="ld-form-item-label">
                {'SETTHESTARTTIME'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <input type="text" name="startdata" id="jscal_field_date_starts" class="Wdate" value="{$startdate}" onClick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})" >
                <input id="FieldType"  name="FieldType" type="hidden" value="">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDMODEL'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="reminds_method" name="reminds_method" onchange="RemindsMethod(this);" class="ld-select-inner">
                    <option value="1" {if $remindway eq '1'}selected{/if}>{'FIXEDCYCLE'|@getFixedLabel}</option>
                    <option value="2" {if $remindway eq '2'}selected{/if}>{'APPOINTCYCLE'|@getFixedLabel}</option>
                    <option value="3" {if $remindway eq '3'}selected{/if}>{'ANNUALREMIND'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDTIMES'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                {if $remindway eq '1'}<!--固定周期-->
                {assign var='remindnums_disp' value=''}
                {else if $remindway eq '3'}<!--每年提醒-->
                {assign var='remindnums_disp' value='none'}
                {else}
                {assign var='remindnums_disp' value='none'}
                {/if}
                <span id="remindnums" style="display:{$remindnums_disp}">
                    {'EACH'|@getFixedLabel}
                    <input  name="remindnums1" id="remindnums1" type="text" {if $remindway eq '1' }value="{$remindday}"{/if} class="ld-input-inner width50">
                    {'Days'|@getFixedLabel}{'commasymbols'|@getFixedLabel}{'TIXING'|@getFixedLabel}
                </span>
                <select id="remindsNums" name="remindsNums" class="ld-select-inner width60" {if $remindway eq '1' || $remindway eq '2'}{else} style="display:none"{/if}  onchange="getRemindsnums(this);">
                    <option value="1" {if $remindnum eq '1'}selected{/if}>1</option>
                    <option value="2" {if $remindnum eq "2"}selected{/if}>2</option>
                    <option value="3" {if $remindnum eq "3"}selected{/if}>3</option>
                    <option value="4" {if $remindnum eq "4"}selected{/if}>4</option>
                    <option value="5" {if $remindnum eq "5"}selected{/if}>5</option>
                    <option value="6" {if $remindnum eq "6"}selected{/if}>6</option>
                    <option value="7" {if $remindnum eq "7"}selected{/if}>7</option>
                    <option value="8" {if $remindnum eq "8"}selected{/if}>8</option>
                    <option value="9" {if $remindnum eq "9"}selected{/if}>9</option>
                    <option value="10" {if $remindnum eq "10"}selected{/if} >10</option>
                    <option value="11" {if $remindnum eq "11"}selected{/if}>11</option>
                    <option value="12" {if $remindnum eq "12"}selected{/if}>12</option>
                </select>
                <input name="method2Nums" id="method2Nums" value="" type="hidden">
                <span id="autoremindtimes" {if $remindway eq 3}style="display:none;"{/if}>{'TIME1'|@getFixedLabel}</span>
                {if $remindway neq 3}
                    <span id="remindhtml3" style="display:none">{$remindday3}</span>
                {else}
                    <span id="remindhtml3" style="">{$remindday3}</span>
                {/if}
                <span class="greyFont9" id="remindrule1">({'FIXEDCYCLEREMINDRULES'|@getFixedLabel})</span>
                <span class="greyFont9" id="remindrule2" style="display:none;">({'REMINDRULESPECIFIEDPERIOD'|@getFixedLabel})</span>
                <span class="greyFont9" id="remindrule3" style="display:none;">({'ANNUALREMINDEXPLAIN'|@getFixedLabel})</span>
                <div style="padding-top: 10px;"><span id="remindhtml1">{$remindday1}</span></div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'REMINDERPEOPLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select id="reminds_to" name="reminds_to" onchange="AutomaticReminds.reminderChange(this)" class="ld-select-inner">
                    {foreach item=remindinfo  from=$REMINDER_USER_ARRAY.dialog}
                        <option value="{$remindinfo.value}" {if $remindinfo.value eq $reminder}selected{/if}>{$remindinfo.text}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
        <tr id="tr_specify_reminder" {if $reminder neq 'specifyuser'}style="display:none"{/if} >
            <td class="ld-form-item-label"><font color="red">*</font>{'USERS'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <div  id="dv_specify_reminder">
                    <div class="ld-input-inner-div ld-input-inner-add" id="userid_name" name="userid_name"></div>
                    <a class="icon-range" href="javascript:;" title="选择" onclick="getSpecifyUserIds();" style="top: 20px;"></a>
                    <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#userid').val('');ld('#userid_name').text('');return false;">+</a>
                    <input name="userid" id="userid" value="{if $SPECIFYUSERIDS neq ''}{$SPECIFYUSERIDS}{/if}" type="hidden">
                </div>
            </td>
        </tr>
        <tr id="tr_role_name" {if $reminder neq 4}style="display:none"{/if}>
            <td class="ld-form-item-label"><font color="red">*</font>{'ROLES'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="text" name="role_name" id="role_name" readonly="true" class="ld-input-inner" value="{$role_name}" onclick="selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}')"/>
                <input type="hidden" name="user_role" id="user_role" value="{$role_id}"/>
                <a class="ld-text-select" href="javascript:selectPopupProfile('user_role','{'ROLES'|@getFixedLabel}');">+</a>
                <a class="ld-text-clear" href="javascript:;" title="{'CLEAR'|@getFixedLabel}" onclick="ld('#user_role').val('');ld('#role_name').val('');return false;">+</a>
            </td>
        </tr>
        <tr id="tr_position" {if $reminder neq 5}style="display:none"{/if}>
            <td class="ld-form-item-label"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="position" class="ld-select-inner">
                    {foreach key=key item=item from=$USERLEVELARR}
                        <option value="{$key}" {if $REMINDERVALUE == $key} selected{/if}
                        >{$item}</option>
                    {/foreach}
                </select>
                <span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
            </td>
        </tr>
        <tr id="tr_positionlevel" {if $reminder neq 6}style="display:none"{/if}>
            <td class="ld-form-item-label"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="positionlevel" class="ld-select-inner">
                    {foreach key=key item=item from=$USERLEVELARR}
                        <option value="{$key}" {if $REMINDERVALUE == $key} selected{/if}
                        >{$item}</option>
                    {/foreach}
                </select>
                <span class="greyFont9">{'MANAGEMENTPOSITIONLEVEL'|@getFixedLabel}</span>
            </td>
        </tr>
        <tr id="tr_positiondepartment" {if $reminder neq 6}style="display:none"{/if}>
            <td class="ld-form-item-label"><font color="red">*</font>{'Sector'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input  type="hidden" name="positiondepartment1" value="{$REMINDERVALUEARRAY[0]}"/>
            </td>
        </tr>
        <tr id="tr_positiondepartment_position" style="display:none">
            <td class="ld-form-item-label"><font color="red">*</font>{'POSITIONLEVEL'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="positiondepartment2" class="ld-select-inner">
                    {foreach key=key item=item from=$USERLEVELARR}
                        {if $REMINDERVALUEARRAY[1] neq '' && $REMINDERVALUEARRAY[1]|@html_entity_decode eq $key|@html_entity_decode}
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
                <select id="remind_method" name="remind_method" onchange="AutomaticReminds.auotRemindmethodChange(this)" class="ld-select-inner">
                </select>
            </td>
        </tr>
        <tr id="SMSVoicearray" style="display:none;">
            <td class="ld-form-item-label"><font color="red">*</font>语音模板</td>
            <td class="ld-form-item-content">
                <select id="SMSVoice_template" name="SMSVoice_template" class="ld-select-inner">
                    {*                    //zxm 2021-0909 阳光创信 语音提醒*}
                    {foreach key=templateId item=templateName from=$SMSVoicearray}
                        <option value="{$templateId}" {if $remindcontent eq $templateId}selected{/if}>{$templateName}</option>
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
    <table class="ld-public-content-small padT8" id="reminds_content_table" border="0" cellpadding="0" cellspacing="0" width="100%">
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
            <td class="ld-form-item-content padL" style="overflow: inherit;white-space: inherit;">
                <textarea  id="reminds_content_text" name="reminds_content_text" type="text" class="ld-textarea-inner">{if $remindmethod eq 0|| $remindmethod eq 2}{$remindcontent}{/if}</textarea>
                <textarea id="reminds_content" name="reminds_content" type="text/plain" style="width:100%;height:100px;">{if $remindmethod neq 0&&$remindmethod neq 2}{$remindcontent}{/if}</textarea>
            </td>
        </tr>
    </table>

    <table class="ld-public-content-small padT8" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td colspan="2">
                <div class="ld-pop-contnet-title-items">
                    <div class="ld-pop-contnet-title-item">
                        {'DATARANGE'|@getFixedLabel}{'DataRangeDescription'|@getFixedLabel}
                    </div>
                </div>
            </td>
        </tr>
    </table>

    {assign var=stddiv value="style=display:none"}
    {assign var=advdiv value="style=display:block"}
    <div id="dv_autoreminds_stdfilter" class="ld-public-content-paddingleft">
    </div>
    <div class="advanceFilterGroupDiv" name="adv_filter_div" style="padding: 0 24px 10px;">

    </div>
</form>


{*遮罩层div*}
<div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
    <div id="divSendInform_content_div"></div>
</div>


<script language="javascript" type="text/javascript">

    var reminderlabel='{'REMINDERPEOPLE'|@getFixedLabel}';

    var reminder_user_array_json='{$REMINDER_USER_ARRAY_JSON}';
    //auotRemindmethodChange(document.getElementById('remind_method'));
    document.getElementById('userid').value='{$SPECIFYUSERIDS}';
    document.getElementById('userid_name').value='{$SPECIFYUSERNAMES}';
    //

    var reminder='{$reminder}';

    {literal}


    //reminderChange(document.getElementById('reminds_to'));
    {/literal}
    function goto_CustomAction(module)
    {ldelim}
        document.location.href = "index.php?module="+module+"&action=CustomAction&record={$CUSTOMVIEWID}";
        {rdelim}
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