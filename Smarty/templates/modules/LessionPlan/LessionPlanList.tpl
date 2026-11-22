<div class="skxxbill abc">
<div class="divSocallProduct">
<table width="100%" border="0" cellspacing="1" cellpadding="0" class="ProductTab" id="tab_1">
    <tr>
        <input type="hidden" name="listjsinfo" id="listjsinfo" value="{$LISTJSINFO}" />
        <input type="hidden" id="rowcount" name="rowcount" value="1" />
        <input type="hidden" id="recordid" name="recordid" value="{$RECPRDID}" />
        <td colspan="9" style="font-weight:bold;color:#000000;">
            {'LESSIONPLANDETAILS'|@getFixedLabel}
        </td>
    </tr>
    <tr class="Tdhead">
        <td>
        </td>
        {foreach key=labelid item=label from=$LISTVIEWHEADER name=headerfor}
            {assign var="fieldlabel" value=$label.fieldlabel}
            {assign var="typeofdata" value=$label.typeofdata}
            <td>{if $typeofdata eq 'M'}<span style="color:#FF0000">*</span>{/if} <span style="color:#000000">{$fieldlabel}</span></td>
        {/foreach}
    </tr>
    <tr id="row1" deleted='no' rowindex=1 valign="top">
        <td>
            <input type="hidden" name="deleterow1" id="deleterow1" value="0" />
        </td>
        {foreach key=labelid item=label from=$LISTVIEWHEADER name=headerfor}
            {assign var="uitype" value=$label.uitype}
            {assign var="fieldname" value=$label.fieldname}
            {if $uitype eq 15}
                <td>
                <select name="{$label.fieldname}1" id="{$label.fieldname}1" style="width: 100%;height:25px;line-height:25px;">
                    {$label.fieldname|@getSelectContent:$label.fdvalue}
                </select>
                </td>
            {elseif $uitype eq 2}
                <td>
                    <input name="lessiondate1" id="jscal_field_date_start1" style="min-width:90px;width:100%;height:25px;line-height:25px;" size="15" maxlength="10" value="{$label.fdvalue}" onClick="WdatePicker()" class="Wdate"> 
                    <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" class="marL5" id="jscal_trigger_date_start1">
                    <script type="text/javascript" id='massedit_calendar_date_start1'>
    					Calendar.setup ({ldelim}
    						inputField : "jscal_field_date_start1", ifFormat : "%Y-%m-%d", showsTime : false, button : "jscal_trigger_date_start1", singleClick : true, step : 1
    					{rdelim})
    				</script>-->
                </td>
            {elseif $uitype eq 1}
                <td>
                    <input type="text" name="{$fieldname}1" id="{$fieldname}1" value="{$label.fdvalue}" size="12" />
                </td>
            {elseif $uitype eq 19}
                <td width="20%">
                    <textarea style="width:100%;height: 25px;line-height: 20px;margin-top:5px;margin-bottom:-8px;" id="{$fieldname}1" name="{$fieldname}1">{$label.fdvalue}</textarea>
                </td>
            {/if}
        {/foreach}
    </tr>
</table>
{if $RECPRDID == ''}
<div style=" margin-left:10px; margin-top:10px;">
    <input type="button" class="createauto" value="{'ADDLESSIONPLAN'|@getFixedLabel}" onclick="LessionAddRow()" />
</div>
{/if}
</div>
</div>
<script type="text/javascript">

</script>