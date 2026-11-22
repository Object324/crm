<!--修改编码格式:统一编码：UTF-8-->
<form name="frmsendInfo" method="post" action="index.php">
<input type="hidden" id="tabid" name="tabid" value="{$TABID}">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SMS'|@getFixedLabel}{'SETTINGS'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('smssettings');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<div id="DividendOrder_smssetting">
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">
      <tr>
        <td class="Note">
    		<div>
				<input type="checkbox" id="is_dividend" name="is_dividend" {if $is_dividend eq 0}checked{/if} />{'DIVIDENDBTN'|@getFixedLabel}{'WHETHERSENDSMSIMMEDIATELYAFTERT'|@getFixedLabel}
            </div>
			<div>
				{'DIVIDENDBTN'|@getFixedLabel}{'SMS'|@getFixedLabel}{'Content'|@getFixedLabel}
				<a href="###" id="is_dividend_settings" tag=1>
                    {'SETHEMESSAGEFORMAT'|@getFixedLabel}
                </a>
            </div>
            <div class="divTextRecipient">
                <textarea id="textDividendContent" name="textDividendContent">{$dividend_content}</textarea>
            </div>
            <div>
                <input type="checkbox" id="is_anti_dividend" name="is_anti_dividend" {if $is_anti_dividend eq 0}checked{/if} />{'ANTIDIVIDENDBTN'|@getFixedLabel}{'WHETHERSENDSMSIMMEDIATELYAFTERT'|@getFixedLabel}
            </div>
			<div>
                {'DIVIDENDBTN'|@getFixedLabel}{'SMS'|@getFixedLabel}{'Content'|@getFixedLabel}
				{if $settype neq 'no'}
                <a href="###" id="is_anti_dividend_settings" tag=2>
                    {'SETHEMESSAGEFORMAT'|@getFixedLabel}
                </a>{/if}
            </div>
            <div class="divTextRecipient">
                <textarea id="textAntiDividendContent" name="textAntiDividendContent">{$anti_dividend_content}</textarea>
            </div>
            <div>
                 {'CHOOSEWHICHPHONETOSENDTEXTMASSEAGE'|@getFixedLabel}
            </div>
			<div>
				{foreach key=fieldname item=fieldinfo from=$MOBILEINFO}
					
					<input type="checkbox" {$fieldinfo.chk} id="fieldname_{$fieldname}" name="mobile_fieldname" value="{$fieldname}" />{$MODULE_NAME}:{$fieldinfo.columnname}&nbsp;&nbsp;
				{/foreach}
			</div>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'SAVE'|@getFixedLabel}" id="sms_save"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('smssettings');"/>   
    </div>
	</div>
</form>