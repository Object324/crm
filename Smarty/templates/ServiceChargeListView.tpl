{if $smarty.request.ajax neq ''}
&#&#&#{$ERROR}&#&#&#
{/if}
{*修改编码格式:统一编码：UTF-8*}
<div class="ServiceCharge_div">
<input type="hidden" name="isadmin" id="isadmin" value="{$ISADMIN}" />
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top">
        <div id="servicechargeleft">
        {include file="servicechargeleft.tpl"}
        </div>
    </td>
    <td class="Tdcenter" valign="top">
    	<div class="DivC" style="border-top:none;border-bottom:1px solid #ddd;width:{$PAGEWIDTHPERCENT}%">
        	{include file="ListView.tpl"}
             <div class="clear"></div>              
        </div>
    </td>
  </tr>
</table>
</div>
<div id="groupedit" class="D_pop_box LdPopWidth400px" style="display:none;">
<div id="groupedit_div"></div>
</div>

<form name="SendMail" style="float:left;"><div id="sendmail_cont" style="z-Index:9999999999999;position:absolute;"></div></form>