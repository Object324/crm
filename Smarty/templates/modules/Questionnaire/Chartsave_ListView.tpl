<table class="bgwhite" style="100%" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody><tr>
        <td class="DivCL b" style="width: 70%;">
            <ul class="D_btn_box b">

            </ul>
        </td>
        <td class="DivCR" valign="middle">
            <div class="PageDiv0" style="margin-top: 4px;margin-bottom:4px;">
                <div class="ld-flex-start">
                    <div class="ld-pagenum-div">{$CHARTSAVE_NUM_SHOW}</div>
                    {$QUESCHARTSAVE_PAGHTML}
                </div>
            </div>
        </td>
    </tr></tbody>
</table>
<div id="hdScrolllistentries_yy_QuestionnaireChartsave" name="hdScrolllistentries_yy_QuestionnaireChartsave" style="position: relative;">
    <div style="visibility: visible; width: 100%;" id="resize_header_table_divid_QuestionnaireChartsave">
        <div style="float:left;">
            <table id="resize_header_tableid_QuestionnaireChartsave" name="resize_header_tableid_QuestionnaireChartsave" class="listEntries" cellspacing="1" cellpadding="0" border="0" style="width: fit-content;">
                <tbody><tr>
                    <th style="width:20%;" tag="1">序号</th>
                    <th style="width:30%;" tag="2">提交日期</th>
                    <th style="width:50%;" tag="3">操作</th>
                </tr>
                </tbody></table>
        </div>
    </div>
    <div style="overflow: auto; width: 100%;" id="resize_content_table_divid_QuestionnaireChartsave" name="resize_content_table_divid_QuestionnaireChartsave">

        <div style="float:left;">
            <table id="resize_content_tableid_QuestionnaireChartsave" name="resize_content_tableid_QuestionnaireChartsave" class="listEntries marT-53" cellspacing="1" cellpadding="0" border="0" style="width: fit-content;">
                <tbody>
                    <tr>
                        <th style="width:20%;" tag="1">序号</th>
                        <th style="width:30%;" tag="2">提交日期</th>
                        <th style="width:50%;" tag="3">操作</th>
                    </tr>
                    {if $CHARTSAVE_NUM > 0}
                        {assign var="rowindex" value=1}
                        {foreach key=chartsaveid item=chartsave from=$CHARTSAVE_ARRAY}
                            <tr id="relation_QuestionnaireChartsave_{$rowindex}" class="lvtColData" onmouseout="" onmouseover="">
                                <td align="left">
                                    <span name="td_content">{$rowindex}</span>
                                </td>
                                <td align="left">
                                    <span name="td_content">{$chartsave.seqtime}</span>
                                </td>
                                <td align="left">
                                    <a name="td_content" onclick="get_Chartsave_detail({$chartsave.chartsaveid},{$questionnaireid});">查看填写详情</a>
                                </td>
                            </tr>
                            {assign var="rowindex" value=$rowindex + 1}
                        {/foreach}
                    {else}
                        <tr class="lvtColData">
                            <td colspan="3" style="text-align:center;">{'Noquestions'|@getFixedLabel}</td>
                        </tr>
                    {/if}
                    </tbody>
            </table>
        </div>
    </div>
</div>
<script>
    var popupobj=CrmPopup.getPopupObj('last');
    popupobj.relatelistsizeobj=new List_ResizeTable(popupobj);
    popupobj.relatelistsizeobj.setRelatedResizeTable_Init('QuestionnaireChartsave','');
    popupobj.reSizePosition();//设置相关信息全屏
</script>