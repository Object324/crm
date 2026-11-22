{*<script type="text/javascript" src="{$JSURL}include/js/select2.min.js"></script><!--多选框-->*}
<form action="index.php" method="post" name="SelectDescribeTemplates" >
    <input type="hidden" name="record" value="{$RECORD}"/>
    <div class="DivCR" id="div_template_select">
        <div id='subappcontent'>
            <table class="settingPopTable lasttdbordernon" border="0" cellpadding="0" cellspacing="0" width="100%">
                <tr>
                    <td width="100" align="right">合同模板</td>
                    <td style="overflow: inherit;">
                        {assign var=fldname value='flowtemplate'}
                        {*这个select好像没用啊，为啥都这么写*}
                        <select id="flowtemplate" name="flowtemplate" style="display: none;">
                            {foreach item=template from=$TemplateList}
                                <option value="{$template.TemplateId}" >{$template.TemplateName}</option>
                            {/foreach}
                        </select>

                        <div name="dv_chzn_{$fldname}" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'{$fldname}','div_template_select')">
                            <a style="width:208px;" class="chzn-single" onclick="com_img_change(event,'{$fldname}','div_template_select')" href="javascript:void(0)" tabindex="-1"
                               name="cmb_a_{$fldname}">
                                <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_{$fldname}' onclick="cmb_picklist_end_foucs(event,'{$fldname}','div_template_select')" onKeyUp="com_chosen(event,'{$fldname}','div_template_select')" value="{$TemplateList.0.TemplateName}">
                                <div>
                                    <b></b>
                                </div>
                            </a>
                            <div style=" left:-9000px;width: 208px; top: 25px;" class="chzn-drop" name='dv_drop_{$fldname}' >
                                <ul class="chzn-results" name="cmb_ul_{$fldname}">
                                    {assign var="i" value=0}
                                    {foreach item=template from=$TemplateList}
                                        <li  class="active-result" name="dv_chzn_{$i }_{$fldname}" onclick="cmb_liclick('{$template.TemplateId}','{$fldname}','div_template_select')" onmouseover="cmb_limouseover(event,'{$fldname}','div_template_select')">{$template.TemplateName}</li>
                                        {assign var="i" value=$i+1}
                                    {/foreach}
                                    <li class="" name="li_chzn_{$fldname}" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                                </ul>
                            </div>
                        </div>
                    </td>
                </tr>

            </table>
        </div>
    </div>
</form>

<script type="text/javascript">
    ld(document).ready(function() {ldelim}
        ld("#{$fldname}").select2({ldelim}closeOnSelect: false{rdelim});
        {rdelim});
</script>

