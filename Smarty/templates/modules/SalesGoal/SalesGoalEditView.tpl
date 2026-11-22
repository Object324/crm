<div class="edit-left" >
</div>
<div class="edit-right" style="">
    <form id="frmEditView" name="EditView">
    <table width="100%" cellspacing="0" cellpadding="0" border="0" style="table-layout: fixed;">
        <colgroup><col style="width: 200px"><col style="width: calc(100% - 200px)"><col style="width: 200px"><col style="width: calc(100% - 200px)"></colgroup>
        <tbody>
        <tr>
            <td colspan="4" class="ld-from-headblock e">
                <div class="ld-from-headblock-title" tag="headblock-title">{'BASICINFORMATION'|@getFixedLabel}</div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                <input type="hidden" id="discount_rate" name="discount_rate" value="">
                <font color="red">*</font>{'INDICATORSNAME'|@getFixedLabel}(zh)
            </td>
            <td class="ld-form-item-content">
                <input type="text" name="zhlabel" id="zhlabel" remind_label="{'INDICATORSNAME'|@getFixedLabel}(zh)" value="{$zhlabel}" class="ld-input-inner">
            </td>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'INDICATORSNAME'|@getFixedLabel}(en)
            </td>
            <td class="ld-form-item-content">
                <input type="text" name="enlabel" id="enlabel" remind_label="{'INDICATORSNAME'|@getFixedLabel}(en)" value="{$enlabel}" class="ld-input-inner">
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'INDICATORSOBJECT'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <select name="modulename" id="modulename" remind_label="{'INDICATORSOBJECT'|@getFixedLabel}" class="salesgoaltimeselect btn-radius-system ld-select-inner" style="display:none">
                    {foreach key=tmp_name item=tmp_label from=$modulenamearr }
                        <option value="{$tmp_name}" {if $tmp_name eq $modulename}selected{/if}  >{$tmp_label}</option>
                        {if $tmp_name eq $modulename}
                            {assign var = "modulename_label" value = $tmp_label}
                        {/if}
                    {/foreach}
                </select>
                <div name="dv_chzn_modulename" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'modulename')">
                    <a class="chzn-single" onclick="com_img_change(event,'modulename')" href="javascript:void(0)" tabindex="-1" name="cmb_a_modulename">
                        <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0" name='cmb_span_optiontext_modulename' onclick="cmb_picklist_end_foucs(event,'modulename')" onKeyUp="com_chosen(event,'modulename')" value="{$modulename_label}">
                        <input name="modulename" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_modulename' >
                        <ul class="chzn-results" name="cmb_ul_modulename">
                            {assign var="i" value=0}
                            {foreach key=tmp_name item=tmp_label from=$modulenamearr }
                                <li style="" class="active-result" name="dv_chzn_{$i}_modulename" onclick="cmb_liclick('{$tmp_name}','modulename')" onmouseover="cmb_limouseover(event,'modulename')">{$tmp_label}</li>
                                {assign var="i" value=$i+1}
                            {/foreach}
                            <li style="" class="" name="li_chzn_modulename" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
            </td>

            <td class="ld-form-item-label">
                <span name="groupsettinglabel" id="groupsettinglabel" {if $modulename neq 'Users'}style="display: none;" {/if}>
                    <font color="red">*</font>{'SECTORINDICATORS'|@getFixedLabel}
                </span>
            </td>
            <td class="ld-form-item-content">
                <select name="groupsetting" id="groupsetting" remind_label="{'SECTORINDICATORS'|@getFixedLabel}" class="salesgoaltimeselect btn-radius-system ld-select-inner" style="display: none;">
                    {foreach key=tmp_name item=tmp_label from=$groupsettingarr }
                        <option value="{$tmp_name}" {if $tmp_name eq $groupsetting}selected{/if} >{$tmp_label}</option>
                        {if $tmp_name eq $groupsetting}
                            {assign var = "groupsetting_label" value = $tmp_label}
                        {/if}
                    {/foreach}
                </select>
                <div name="dv_chzn_groupsetting" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'groupsetting')" {if $modulename neq 'Users'}style="display: none;" {/if}>
                    <a class="chzn-single" onclick="com_img_change(event,'groupsetting')" href="javascript:void(0)" tabindex="-1" name="cmb_a_groupsetting">
                        <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_groupsetting' onclick="cmb_picklist_end_foucs(event,'groupsetting')" onKeyUp="com_chosen(event,'groupsetting')" value="{$groupsetting_label}">
                        <input name="groupsetting" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_groupsetting' >
                        <ul class="chzn-results" name="cmb_ul_groupsetting">
                            {assign var="i" value=0}
                            {foreach key=tmp_name item=tmp_label from=$groupsettingarr }
                                <li style="" class="active-result" name="dv_chzn_{$i}_groupsetting" onclick="cmb_liclick('{$tmp_name}','groupsetting')" onmouseover="cmb_limouseover(event,'groupsetting')">{$tmp_label}</li>
                                {assign var="i" value=$i+1}
                            {/foreach}
                            <li style="" class="" name="li_chzn_groupsetting" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'TARGETRANGE'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <div name="scopeid_name"  style="overflow: hidden;text-overflow: ellipsis;vertical-align:middle;display:inline-block;margin:0;" id="scopeid_name" type="text" fieldonly="0" value="" class="ld-input-inner-div ld-input-inner-add" title="{$scopname}" >{$scopname}</div>
                <input name="scope" id="scope" type="hidden" value="{$scope_new}">
                <input name="scopeid" id="scopeid" remind_label="{'TARGETRANGE'|@getFixedLabel}" type="hidden" value="{$scopeid}">
                {*wym BUG0071164 title改为了tip input加上tip无法生效 所以把清除按钮从input改为了a标签 如果有问题 需要再改回来*}
                <a id="choosescope" name="choosescope" class="ld-text-select tip-items-list" href="javascript:;" data-tip="{'SELECT'|@getFixedLabel}" data-type="position" data-direction="top" onclick="">+</a>
                <a id="clearscope" name="clearscope" class="tip-items-list ld-text-clear" href="javascript:;" data-tip="{'CLEAR'|@getFixedLabel}" data-type="position" data-direction="top" onclick="">+</a>
            </td>
{*            XUQIU20240415-03 目标管理，增加“显示离职成员”参数（杨雅媚） wsh 0918*}
            {if $mode neq 'edit'}
                <td class="ld-form-item-label">
                <span id="displayinactiv_label">
                    <font color="red">*</font>{'DisplayResignedMembers'|@getFixedLabel}
                </span>
                </td>
                <td class="ld-form-item-content"><input type="checkbox" class="second_switch" value="" {if $displayinactiv eq 'yes'}checked="checked"{/if} id="displayinactiv"></td>
            {/if}
        </tr>
        {*wym 240408 XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）*}
        <tr>
            <td class="ld-form-item-label">
                <font color="red">*</font>{'ASSIGNEDTO'|@getFixedLabel}
            </td>
            <td class="ld-form-item-content">
                <select name="smownerid" id="smownerid" remind_label="{'ASSIGNEDTO'|@getFixedLabel}" class="salesgoaltimeselect btn-radius-system ld-select-inner" style="display: none;">
                    {foreach key=tmp_name item=tmp_arr from=$useridarr }
                        <option value="{$tmp_arr.id}" {if $tmp_arr.id eq $smownerid}selected{/if} >{$tmp_arr.namelabel}</option>
                        {if $tmp_arr.id eq $smownerid}
                            {assign var = "userid_label" value = $tmp_arr.namelabel}
                        {/if}
                    {/foreach}
                </select>
                <div name="dv_chzn_smownerid" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'smownerid')">
                    <a class="chzn-single" onclick="com_img_change(event,'smownerid')" href="javascript:void(0)" tabindex="-1" name="cmb_a_smownerid">
                        <div class="commonDetailedTextBox outline Bornone" picklisttype="smownerpicklist" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_smownerid' onclick="cmb_picklist_end_foucs(event,'smownerid')" onKeyUp="com_chosen(event,'smownerid')" value="">{$userid_label}</div>
                        <input name="smownerid" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_smownerid' >
                        <ul class="chzn-results" name="cmb_ul_smownerid">
                            {assign var="i" value=0}
                            {foreach key=tmp_name item=tmp_arr from=$useridarr }
                                <li style="" class="active-result" name="dv_chzn_{$i}_smownerid" onclick="cmb_liclick('{$tmp_arr.id}','smownerid')" onmouseover="cmb_limouseover(event,'smownerid')">{$tmp_arr.namelabel}</li>
                                {assign var="i" value=$i+1}
                            {/foreach}
                            <li style="" class="" name="li_chzn_smownerid" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
            </td>
            <td class="ld-form-item-label">{'INDICATORUNIT'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="indicator_unit" id="indicator_unit" remind_label="{'INDICATORUNIT'|@getFixedLabel}" class="salesgoaltimeselect btn-radius-system ld-select-inner" style="display: none;">
                    {foreach key=unit item=unitlabel from=$unit_option_arr }
                        <option value="{$unit}" {if $unit eq $selectedunit}selected{/if} >{$unitlabel}</option>
                        {if $unit eq $selectedunit}
                            {assign var = "unit_label" value = $unitlabel}
                        {/if}
                    {/foreach}
                </select>
                <div name="dv_chzn_indicator_unit" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'indicator_unit')">
                    <a class="chzn-single" onclick="com_img_change(event,'indicator_unit')" href="javascript:void(0)" tabindex="-1" name="cmb_a_indicator_unit">
                        <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_indicator_unit' onclick="cmb_picklist_end_foucs(event,'indicator_unit')" onKeyUp="com_chosen(event,'indicator_unit')" value="{$unit_label}">
                        <input name="indicator_unit" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_indicator_unit' >
                        <ul class="chzn-results" name="cmb_ul_indicator_unit">
                            {assign var="i" value=0}
                            {foreach key=unit item=unitlabel from=$unit_option_arr}
                                <li style="" class="active-result" name="dv_chzn_{$i}_indicator_unit" onclick="cmb_liclick('{$unit}','indicator_unit')" onmouseover="cmb_limouseover(event,'indicator_unit')">{$unitlabel}</li>
                                {assign var="i" value=$i+1}
                            {/foreach}
                            <li style="" class="" name="li_chzn_indicator_unit" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label">{'CONVERSIONRATE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="conversion_rate" id="conversion_rate" remind_label="{'INDICATORRATE'|@getFixedLabel}" class="salesgoaltimeselect btn-radius-system ld-select-inner" style="display: none;">
                    {foreach item=rate from=$rate_option_arr }
                        <option value="{$rate}" {if $rate eq $selectedrate}selected{/if} >×{$rate}</option>
                    {/foreach}
                </select>
                <div name="dv_chzn_conversion_rate" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'conversion_rate')">
                    <a class="chzn-single" onclick="com_img_change(event,'conversion_rate')" href="javascript:void(0)" tabindex="-1" name="cmb_a_conversion_rate">
                        <input class="ld-select-inner-input" type="text" autocomplete="off" tabindex="0"  name='cmb_span_optiontext_conversion_rate' onclick="cmb_picklist_end_foucs(event,'conversion_rate')" onKeyUp="com_chosen(event,'conversion_rate')" value="×{$selectedrate}">
                        <input name="conversion_rate" type="hidden" tabindex="l" fieldonly="0" value="{$optText}" style="display:none">
                        <div>
                            <b></b>
                        </div>
                    </a>
                    <div style=" left:-9000px;top: 32px;" class="chzn-drop" name='dv_drop_conversion_rate' >
                        <ul class="chzn-results" name="cmb_ul_conversion_rate">
                            {assign var="i" value=0}
                            {foreach item=rate from=$rate_option_arr}
                                <li style="" class="active-result" name="dv_chzn_{$i}_conversion_rate" onclick="cmb_liclick('{$rate}','conversion_rate')" onmouseover="cmb_limouseover(event,'conversion_rate')">×{$rate}</li>
                                {assign var="i" value=$i+1}
                            {/foreach}
                            <li style="" class="" name="li_chzn_conversion_rate" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        </ul>
                    </div>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="4" class="ld-from-headblock e">
                <div id="detaititle" class="ld-from-headblock-title" tag="headblock-title">{'TARGETDETAILS'|@getFixedLabel}</div>
            </td>
        </tr>
        </tbody></table>
        <table id="SalesGoalDetail" name="SalesGoalDetail" class="entryContentPad" width="100%" cellspacing="0" cellpadding="0" border="0" style="" >
            <tr id="detaillabel" name="detaillabel" class="Tdhead" rowindex="0" style="height:46px">
                <td name="lineid" class="ld-form-item-content-entrytitle" style="text-align: center;">
                    <span>#</span>
                </td>
                <td name="line_entitytype" class="ld-form-item-content-entrytitle" style="width: 160px;">
                    <font color="red">*</font><span  id="line_entitytype" >{'INDICATORSMODULENAME'|@getFixedLabel}</span>
                </td>
                <td name="line_referencefield" class="ld-form-item-content-entrytitle">
                    <font color="red">*</font><span  id="line_refrencefield" >{'TargetRangeMappingField'|@getFixedLabel}</span>
                </td>
                <td name="line_datefield" class="ld-form-item-content-entrytitle">
                    <font color="red">*</font><span  id="line_datefield" >{'TimeRangeMappingField'|@getFixedLabel}</span>
                </td>
                <td name="line_funname" class="ld-form-item-content-entrytitle">
                    <font color="red">*</font><span  id="line_funname" >{'COMPUTINGMETHOD'|@getFixedLabel}</span>
                </td>
                <td name="line_countfield" class="ld-form-item-content-entrytitle">
                    <font color="red">*</font><span  id="line_countfield" >{'STATISTICALFIELD'|@getFixedLabel}</span>
                </td>
                <td name="line_approvedemand" class="ld-form-item-content-entrytitle">
                    <span>{'APPROVEDEMAND'|@getFixedLabel}</span>
                </td>
                <td name="line_othercondition" class="ld-form-item-content-entrytitle">
                    <span></span>
                </td>
                <td name="line_operation" class="ld-form-item-content-entrytitle">
                    <span>{'OPERATING'|@getFixedLabel}</span>
                </td>
            </tr>
            <tr rowindex="-1" style="height:46px">
                <td colspan="8">
                    <div style="width: 100%;">
                        <a id="addrow" name="addrow" onclick="" style="margin: 0 auto;width: 50px;display: block" >+{'NEW'|@getFixedLabel}</a>
                    </div>
                </td>
            </tr>
        </table>
    </form>
</div>
