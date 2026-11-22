<form id="editVariable">
<div class="ld-public-content-small">
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <font color="red">*</font>{'VAR'|@getFixedLabel}{'MAILNAME'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <input class="ld-input-inner" type="hidden" name="report_id" id="report_id" value="{$filterInfo['report_id']}">
            <input class="ld-input-inner" type="hidden" name="filterid" id="filterid" value="{$filterInfo['id']}">
            <input class="ld-input-inner" type="text" name="var_name" id="var_name" value="{$filterInfo['var_name']}">
        </div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <font color="red">*</font>{'DISPLAYNAME'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content">
            <input class="ld-input-inner" type="text" name="display_name" id="display_name" value="{$filterInfo['display_name']}">
        </div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            <font color="red">*</font>{'VAR'|@getFixedLabel}{'SERVICECONTRACTSTYPE'|@getFixedLabel}
            {*<b title="1.模糊查找，建议语法：(case when '&#x007b;变量名称&#x007d;'='' then 1=1 else 字段名称 like '%&#x007b;变量名称&#x007d;%' end );&#10;*}
            {*2.下拉框,建议语法：字段名称='&#x007b;变量名称&#x007d;';&#10;*}
            {*3.多选框、多选用户 建议语法：(case when '&#x007b;变量名称&#x007d;'='' then 1=1 else FIND_IN_SET(字段名称,'&#x007b;变量名称&#x007d;') end );&#10;*}
            {*4.日期、日期时间、数字 建议语法：>=或者<='&#x007b;变量名称&#x007d;'; &#10;*}
            {*5.复选框,建议语法：(case when '&#x007b;变量名称&#x007d;'='on' then 你的判断语句1 else 你的判断语句2 end);&#10;*}
            {*" class="icon-homeimg icon-askgrey-help" tag="var_type_explain"></b>*}
        </div>
        <div class="ld-form-item-content ">
            {*输入框 下拉框 多选框 多选用户 单选用户 日期 日期时间 数字*}
            <select name="var_type" id="var_type" class="ld-select-inner" tag="var_type">
                <option {if $filterInfo['var_type']=='string'}selected{/if}  value="string">{'Inputbox'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='select'}selected{/if}  value="select">{'PickList'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='multiselect'}selected{/if}  value="multiselect">{'SELECT_COMBO'|@getFixedLabel}</option>
                {*<option {if $filterInfo['var_type']=='selectuser'}selected{/if}  value="selectuser">单选用户</option> 多选用户也能实现 单选不好引入先去掉*}
                <option {if $filterInfo['var_type']=='multiuser'}selected{/if}  value="multiuser">{'Usercomponent'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='date'}selected{/if}  value="date">{'DATE'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='datetime'}selected{/if}  value="datetime">{'DateTime'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='number'}selected{/if}  value="number">{'Numberc'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='checkbox'}selected{/if}  value="checkbox">{'CHECK_BOX'|@getFixedLabel}</option>
                <option {if $filterInfo['var_type']=='approvestatus'}selected{/if}  value="approvestatus">{'ApprovalStatusComponent'|@getFixedLabel}</option>
                {if $show_department=='yes'}
                    {*部门组件 20240624 XUQIU20240530-03 sql报表增加变量：部门、当前用户*}
                    <option {if $filterInfo['var_type']=='department'}selected{/if}  value="department">{'DepartmentComponents'|@getFixedLabel}</option>
                    {*当前操作员 20240624 XUQIU20240530-03 sql报表增加变量：部门、当前用户*}
                    <option {if $filterInfo['var_type']=='curroperator'}selected{/if}  value="curroperator">{'CURROPERATOR'|@getFixedLabel}</option>
                {/if}
            </select>
        </div>
    </div>
    <div tag="department_allselect_tr" class="ld-form-item-div" style="{if $filterInfo['var_type']!='department'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'Displayallgroupstructure'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content">
            <input class="second_switch" {if $filterInfo['default_value'] eq 'on' ||$filterInfo['default_value'] eq true}checked{/if} type="checkbox" id="department_allselect_checkbox" name="department_allselect_checkbox">
        </div>
    </div>
    <div fieldinfoitem tag="select_source_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='select'&&$filterInfo['var_type']!='multiselect' }display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'Dropdownboxlistvalues'|@getFixedLabel}{'source'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            {*选项自定义 下拉框字段*}
            <select name="select_source" id="select_source" class="ld-select-inner" tag="select_source">
                <option {if $filterInfo['select_source']=='picklist'}selected{/if}  value="picklist">{'PickList'|@getFixedLabel}{'FIELDS'|@getFixedLabel}</option>
                <option {if $filterInfo['select_source']=='selfdefined'}selected{/if}  value="selfdefined">{'Customoptions'|@getFixedLabel}</option>
            </select>
        </div>
    </div>

    <div fieldinfoitem tag="modulename_tr" class="ld-form-item-div" style="display: flex;
            justify-content: center;{if (($filterInfo['var_type']=='select'||$filterInfo['var_type']=='multiselect')&&$filterInfo['select_source']=='picklist')||$filterInfo['var_type']=='multiuser'||($filterInfo['var_type']=='department'&&$filterInfo['default_value'] neq 'on' &&$filterInfo['default_value'] neq true)}display:flex;{else}display:none;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'Dropdownboxsource'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <select name="modulename" id="modulename" class="ld-select-inner" tag="modulename">
                {foreach $module_arr as $module}
                <option {if $filterInfo&&$filterInfo['modulename']==$module.modulename}selected{/if}  value="{$module.modulename}">{$module.name}</option>
                {/foreach}
            </select>
        </div>
    </div>


    <div fieldinfoitem tag="fieldname_tr" class="ld-form-item-div" style="{if
    ($filterInfo['var_type']=='select'||$filterInfo['var_type']=='multiselect')&&$filterInfo['select_source']=='picklist'}display:flex;{else}display:none;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'Dropdownboxsource1'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <select name="fieldname" id="fieldname" class="ld-select-inner" >
                {foreach $picklists as $pickvalue}
                    <option {if $filterInfo['fieldname']==$pickvalue.columnname}selected{/if}  pickvalues="{$pickvalue.picklist_str}" value="{$pickvalue.columnname}">{$pickvalue.label}</option>
                {/foreach}
            </select>
        </div>
    </div>
    <div fieldinfoitem tag="selectvalues_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='select'&&$filterInfo['var_type']!='multiselect'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'Dropdownboxlistvalues'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <input class="ld-input-inner" type="text" name="selectvalues" id="selectvalues" value="{$filterInfo['selectvalues']}">
        </div>
    </div>
{*    数字 的默认值*}
    <div fieldinfoitem tag="default_value_tr" class="ld-form-item-div"  style="{if
    $filterInfo['var_type']!='number'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'LBL_DEFAULTVALUE'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <input class="ld-input-inner" type="number" name="default_value" id="default_value" value="{$filterInfo['default_value']}">
        </div>
    </div>
{*    单选的默认值*}
    <div fieldinfoitem tag="default_value_select_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='select'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'LBL_DEFAULTVALUE'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <select name="default_value_select" id="default_value_select" class="ld-select-inner" >
                <option value=""></option>
                {foreach item=selectvalue key=i from=$filterInfo['selectvalues_arr']}
                    <option {if $selectvalue==$filterInfo['default_value']}selected{/if} value="{$selectvalue}">{$selectvalue}</option>
                {/foreach}
            </select>
        </div>
    </div>
{*    checkbox的默认值设置*}
    <div fieldinfoitem tag="default_value_checkbox_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='checkbox'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'LBL_DEFAULTVALUE'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <input class="second_switch" {if $filterInfo['default_value'] eq 'on' ||$filterInfo['default_value'] eq true}checked{/if} type="checkbox" id="default_value_checkbox" name="default_value_checkbox">
        </div>
    </div>
    {*时间下拉框默认值设置 今天、明天、昨天、本月开始日期、本月结束日期、上月开始日期、上月结束日期、下月开始日期、下月结束日期、
    本季度开始日期、本季度结束日期、上季度开始日期、上季度结束日期、下季度开始日期、下季度结束日期、本年开始日期、本年结束日期 去年开始日期 去年结束日期 明年开始日期 明年结束日期*}
    <div fieldinfoitem tag="default_value_selectdate_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='date'&&$filterInfo['var_type']!='datetime'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'LBL_DEFAULTVALUE'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <select name="default_value_selectdate" id="default_value_selectdate" class="ld-select-inner" >
                <option {if $filterInfo['default_value']=='todaystart'}selected{/if}  value="todaystart">{'today'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='todayend'}selected{/if}  value="todayend">{'today'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='tomorrowstart'}selected{/if}  value="tomorrowstart">{'tomorrow'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='tomorrowend'}selected{/if}  value="tomorrowend">{'tomorrow'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='yesterdaystart'}selected{/if}  value="yesterdaystart">{'syesterday'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='yesterdayend'}selected{/if}  value="yesterdayend">{'syesterday'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='thismonthstart'}selected{/if} value="thismonthstart">{'thismonth'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='thismonthend'}selected{/if} value="thismonthend">{'thismonth'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='lastmonthstart'}selected{/if} value="lastmonthstart">{'lastmonth'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='lastmonthend'}selected{/if} value="lastmonthend">{'lastmonth'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='nextmonthstart'}selected{/if} value="nextmonthstart">{'nextmonth'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='nextmonthend'}selected{/if} value="nextmonthend">{'nextmonth'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='thisquarterstart'}selected{/if} value="thisquarterstart">{'thisfq'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='thisquarterend'}selected{/if} value="thisquarterend">{'thisfq'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='lastquarterstart'}selected{/if} value="lastquarterstart">{'prevfq'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='lastquarterend'}selected{/if} value="lastquarterend">{'prevfq'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='nextquarterstart'}selected{/if} value="nextquarterstart">{'nextfq'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='nextquarterend'}selected{/if} value="nextquarterend">{'nextfq'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='thisyearstart'}selected{/if} value="thisyearstart">{'thisfy'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='thisyearend'}selected{/if} value="thisyearend">{'thisfy'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='lastyearstart'}selected{/if} value="lastyearstart">{'prevfy'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='lastyearend'}selected{/if} value="lastyearend">{'prevfy'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='nextyearstart'}selected{/if} value="nextyearstart">{'nextfy'|@getFixedLabel}{'CallStartTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='nextyearend'}selected{/if} value="nextyearend">{'nextfy'|@getFixedLabel}{'EndTime'|@getFixedLabel}</option>
                <option {if $filterInfo['default_value']=='selfdefined'}selected{/if} value="selfdefined">{'custom'|@getFixedLabel}</option>
            </select>
        </div>
    </div>
    {*用户组件的默认值*}
    <div fieldinfoitem tag="default_value_multiselect_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='multiselect'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'LBL_DEFAULTVALUE'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <select name="default_multivalue_select[]" id="default_multivalue_select" multiple class="ld-select-inner" >
                {foreach item=selectvalue1 key=j from=$filterInfo['selectvalues_arr']}
                    <option {if is_array($filterInfo['default_value_arr']) && in_array($selectvalue1,$filterInfo['default_value_arr'])}selected{/if} value="{$selectvalue1}">{$selectvalue1}</option>
                {/foreach}
            </select>
        </div>
    </div>
    <div fieldinfoitem tag="default_value_approvestatus_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='approvestatus'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'LBL_DEFAULTVALUE'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <div class="home-header-approve-select approve-select select-input" style="margin-top:4px;">
                {foreach item=approvearr key=j from=$ApproveList}
                    <label for="default_value_approvestatus_{$approvearr.value}" class="padL0 padR5 overflow-space" style="max-width: 100px;display: inline-block;"><input type="checkbox" id="default_value_approvestatus_{$approvearr.value}" name="default_value_approvestatus_value[]" value="{$approvearr.rawvalue}" {if is_array($filterInfo['approvestatus_default_value_arr']) && $approvearr.rawvalue|@in_array:$filterInfo['approvestatus_default_value_arr']}checked{/if}>{$approvearr.label}</label>
                {/foreach}

            </div>
        </div>
    </div>
    <div fieldinfoitem tag="datevalue_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='date'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'TIMES'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <input {if $filterInfo['default_value']!='selfdefined'}readonly{/if} type="text" class="ld-input-inner" name="datevalue" id="datevalue" autocomplete="off" value="{$filterInfo['datevalue']}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d',dateFmt:'yyyy-MM-dd',alwaysUseStartDate:true{rdelim})">
        </div>
    </div>
    <div fieldinfoitem tag="datetimevalue_tr" class="ld-form-item-div" style="{if
    $filterInfo['var_type']!='datetime'}display:none;{else}display:flex;{/if}">
        <div class="ld-form-item-label">
            <font color="red"></font>{'TIMES'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <input {if $filterInfo['default_value']!='selfdefined'}readonly{/if} type="text" class="ld-input-inner" name="datetimevalue" id="datetimevalue" autocomplete="off" value="{$filterInfo['datetimevalue']}" onclick="WdatePicker({ldelim}startDate:'%y-%M-%d %H:%M:%S',dateFmt:'yyyy-MM-dd HH:mm:ss',alwaysUseStartDate:true{rdelim})">
        </div>
    </div>
    <div class="ld-form-item-div">
        <div class="ld-form-item-label">
            {'EXPLAIN'|@getFixedLabel}
        </div>
        <div class="ld-form-item-content ">
            <div style="height:28px;display:block">1.{'SQLREPORTINSTRUCTIONS_1'|@getFixedLabel}</div>
            <div style="height:28px;display:block">2.{'SQLREPORTINSTRUCTIONS_2'|@getFixedLabel}</div>
            <div style="height:28px;display:block">3.{'SQLREPORTINSTRUCTIONS_3'|@getFixedLabel}</div>
        </div>
    </div>
</div>
</form>