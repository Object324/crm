<script language="javascript" type="text/javascript" src="modules/SalesOrder/SalesOrder.js"></script>
<div>
	<input type="hidden" name="salesorderid" value="{$SALESORDERID}" />
	<input type="hidden" name="relationid" value="{$RELATIONID}" />
	<input type="hidden" name="redemotionid" value="{$REDEMPTIONID}" />
        <table class="settingPopTable lasttdbordernon" width="100%"  border="0" cellspacing="1" cellpadding="0">
            <tr>
                <td align="right"><font color="red">*</font><label id="rdpt_label">{'REDEMPTIONTIME'|@getFixedLabel}</label></td>
                <td><input id="redemptiontime" class="Wdate"  type="text" value="{$REDEMPTIONTIME}" style="border:1px solid #bababa;width:150px;" size="15" maxlength="25" onclick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})"/></td> 
                <td align="right"><font color="red">*</font><label id="rdpq_label">{'REDEMPTIONQUANTITY'|@getFixedLabel}</label></td>
                <td><input type="text" class="commonTextBoxPop" size="15" maxlength="25"  id="redemptionquantity" value="{$REDEMPTIONQUANTITY}" /></td>
            </tr>
            <tr>
                <td align="right"><label id="rdpf_label">{'REDEMPTIONISFREE'|@getFixedLabel}</label></td>
                <td><input id="redemptionisfree"   type="checkbox" value="" {if $REDEMPTIONISFREE eq 1} checked="true" {/if}/></td> 
                <td align="right"><label id="rdpc_label">{'REDEMPTIONCOST'|@getFixedLabel}</label></td>
                <td><input type="text" class="commonTextBoxPop" size="15" maxlength="25"  id="redemptioncost" value="{$REDEMPTIONCOST}" /></td>
            </tr>
       </table>
</div>