{*<!--
/*+*******************************************************************************
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
-->*}

<!--分页-->
<div class="ld-flex-between padTB5 gwidth100 ld-flex-wrap">
    <div class="ld-flex-start ld-flex-wrap">
        <div class="E_pop_tit_Second_Right ld-listview-btnscontent marL15">
            {* zkt 	0048962: （https://81mis.com/kfbcrm [^]）短信记录，“短信清单查询”界面，“清空所有”和“删除”没有受操作权限控制，“短信批次查询”页签，“清空所有”没有受“删除”权限控制*}
            {if $DELETE eq 'yes'}
                <div class="ld-button" title="{'CELARALL'|@getFixedLabel}" tag="" onclick="deleteAll(this,'smslist');return false;">{'CELARALL'|@getFixedLabel}<b name="CelarAll" class="ListView_ButtonNum"></b></div>
            {/if}
            {if $DELETE eq 'yes'}
                <div class="ld-button" id="btnOK" title="{'DELETE'|@getFixedLabel}" tag="" onclick="checkbox_delete('smslist');return false;">{'DELETE'|@getFixedLabel}<b name="Delete" class="ListView_ButtonNum"></b></div>
            {/if}
        </div>
    </div>
    <div class="ld-flex-end ld-flex-wrap">
        <div class="PageDiv0">
            <div class="ld-flex-start">
                <div class="ld-pagenum-div">{$recordListRange}</div>{$NAVIGATION}</div>
            </div>
        </div>
    </div>
</div>
<!--分页  end-->
<div class="clear"></div>
<div id="resize_content_table_divid" style="overflow:auto;">
    <table border="0" cellspacing="1" cellpadding="0" width="100%" class="listEntries fir-center" id="CL_Detial2">
    <tr>
        <th>
            <input id="selectCurrentPageRec" type="checkbox" onclick="chose_all('selected_id[]','selectCurrentPageRec')" name="selectCurrentPageRec"/>
        </th>
        <th>{'Job_number'|@getFixedLabel}</th>
        <!--<td class="lvtCol" width="12%">
            {'Theme'|@getFixedLabel}</td>-->
        <th>{'total_number'|@getFixedLabel}</th>
        <th>{'Completed_copies'|@getFixedLabel}</th>
        <th>{'Cost'|@getFixedLabel}</th>
        <th>{'Sender'|@getFixedLabel}</th>
        <th>{'Createtime1'|@getFixedLabel}</th>
        <th width="60">{'OPERATING'|@getFixedLabel}</th>
        
    </tr>
    {foreach key=results name=resultswork item=work from=$resultwork}
    {if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
    <tr bgcolor="white" class="lvtColDataBj Hover" >
    {else}
    <tr bgcolor="white" class="Hover">
    {/if}
        <td><input type="checkbox" id="selected_id[]" value="{$work.BatchNo}" onclick="ChkSonClick('selected_id[]','selectCurrentPageRec')" name="selected_id[]"/></td>
        <td>{$work.BatchNo}</td>
        <!--<td class="listTableRow small" valign="top">
        {$work.Subject}</td>-->
        <td align="right">{$work.AllCount}</td>
        <td align="right">{$work.SuccessCount}</td>
        <td align="right">{$work.SmsBillingFee}</td>
        <!-- <td><a href="javascript:;" onclick="javascript:to_operator('{$work.Operator}')">{$work.Operator}</a></td> -->
        <td>{$work.Operator}</td>
        <td>{$work.Createtime}</td>
        <td>
            <input type="hidden" value="{$work.SmsContent}"/>
            <input type="hidden" value="{$work.Receive}"/>
{*            <a class="Anu3_a" href="javascript:confirmdelete('module=CommunicationLog&action=Delete&type=smswork&records={$work.BatchNo}','smswork')">{'DELETE'|@getFixedLabel}</font></font></a>                                                                              *}
            <a class="Anu3_a" href="javascript:void(0)" onclick="deleteSingle(this,'smswork','{$work.BatchNo}')">{'DELETE'|@getFixedLabel}</font></font></a>
        </td>
    </tr>
    {/foreach}
    </table>
</div>

<script>
    {literal}
    setSmsContentHeight();
    //计算内容高度
    function setSmsContentHeight(){
        var a = ld(' .header').outerHeight(true),//头部高度
            b = ld(' .ld-ui-tabs').outerHeight(true),//标签高度
            c =  ld('#CL_Detial').outerHeight(true),//标签高度,
            d =  36,
            h_height = 0,
            s_height = ld(window).height();
        if(a==null) a=0;
        if(b==null) b=0;
        if(c==null) c=0;
        h_height = Tools.Number.toInt(a);
        
        h_height = Tools.Number.toInt(h_height)+Tools.Number.toInt(b)+Tools.Number.toInt(c)+Tools.Number.toInt(d);
        ld('#resize_content_table_divid').css('height',s_height-h_height-20);
    }
    {/literal}
</script>