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
<!--修改编码格式:统一编码：UTF-8-->
				
<!--分页-->
<!-- wym 2023/1/10 为改变按钮样式，改写框架类名-->
<div class="ld-flex-between padTB5 gwidth100 ld-flex-wrap">
    <div class="ld-flex-start ld-flex-wrap">
        <div class="E_pop_tit_Second_Right ld-listview-btnscontent marL15">
            {* zkt 	0048962: （https://81mis.com/kfbcrm [^]）短信记录，“短信清单查询”界面，“清空所有”和“删除”没有受操作权限控制，“短信批次查询”页签，“清空所有”没有受“删除”权限控制*}
            {if $DELETE eq 'yes'}
                <div class="ld-button" title="{'CELARALL'|@getFixedLabel}" tag="" onclick="deleteAll(this,'smslist');return false;">{'CELARALL'|@getFixedLabel}<b name="CelarAll" class="ListView_ButtonNum"></b></div>
            {/if}
            <div class="ld-button" title="{'EXPORT'|@getFixedLabel}" tag="" onclick="exportCommunicationLog('smslist');return false;">{'EXPORT'|@getFixedLabel}
                <b name="Export" class="ListView_ButtonNum"></b></div>
            {if $DELETE eq 'yes'}
                <div class="ld-button" id="btnOK" title="{'DELETE'|@getFixedLabel}" tag="" onclick="checkbox_delete('smslist');return false;">{'DELETE'|@getFixedLabel}
                <b name="Delete" class="ListView_ButtonNum"></b></div>
            {/if}
            <div class="ld-button" id="btnOK" title="{'Resend'|@getFixedLabel}" tag="" onclick="checkbox_resend('smslist');return false;">{'Resend'|@getFixedLabel}
                <b name="Resend" class="ListView_ButtonNum"></b></div>
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
    <table class="listEntries fir-center" id="CL_Detial2" border="0" cellspacing="1" cellpadding="0" width="100%">
    <tr>
        <th>
            <input id="selectCurrentPageRec" type="checkbox" onclick="chose_all('selected_id[]','selectCurrentPageRec')" name="selectCurrentPageRec"/>
        </th>
    	<th>{'Numbers'|@getFixedLabel}</th>
        <th>{'Recipient'|@getFixedLabel}</th>
        <th>{'Mobile'|@getFixedLabel}</th>
        <th>{'Createtime1'|@getFixedLabel}</th>
        <th >{'Delivery_time'|@getFixedLabel}</th>   
        <!--<td class="headTableRow small" width="22%">
            {'Theme'|@getFixedLabel}</td>-->
        <th>{'Content'|@getFixedLabel}</th>
        <th>{'CONTENTLENGTH'|@getFixedLabel}</th>
        <th>{'Sender'|@getFixedLabel}</th>
        <th>{'SERVICECONTRACTSTYPE'|@getFixedLabel}</th>
        <th>{'STATUS'|@getFixedLabel}</th>
        <!--<td class="colHeader small" width="10%">
            操作</td>-->
    </tr>
    {foreach key=results name=resultswork item=list from=$resultlist}
    {if $smarty.foreach.resultswork.iteration mod 2 eq '0'}
    <tr bgcolor="white" class="lvtColDataBj Hover" >
    {else}
    <tr bgcolor="white" class="Hover">
    {/if}
        <td>
        <input type="checkbox" id="{$list.TaskID}" value="{$list.TaskID}" onclick="ChkSonClick('selected_id[]','selectCurrentPageRec')" name="selected_id[]"></td>
        <td>{$list.TaskID}</td>
        <td>{$list.ReceiveContacts}</td>
        <td>{$list.CalledNumber}</td>    
        <td>{$list.Createtime}</td>
        <td>{$list.SubmitTime}</td>
        <!--<td  class="listTableRow small" valign="top">
        {$list.Subject}</td>-->
        <td><span title="{$list.SmsContent}">{$list.SmsContent}</span></td>
        <td>{$list.SmsContentLength}</td>
        <!-- <td><a href="javascript:;" onclick="javascript:to_operator('{$list.Operator}')">{$list.Operator}</a></td> -->
        <td>{$list.Operator}</td>
        <td>{$list.type}</td>
{*        //wsh BUG20240726-36 2024-08-05*}
        <td>{if $list.SmsResultName eq 'Failed_to_send'|@getFixedLabel}<font color="red" title="">失败</font> <a class="icon-tipsimg icon-tips" name="failed_tips" href="javascript:void(0);" data-tip="{$list.Lossreason}" data-direction='left' data-type='position'></a>{else}{$list.SmsResultName}{/if}</td>
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