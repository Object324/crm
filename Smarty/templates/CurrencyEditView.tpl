<div class="divPopOverflow">
<form action="index.php" method="post" name="index" id="form" onsubmit="puyoungJS_DialogBox.block();">
    <input type="hidden" name="module" value="Settings"/>
    <input type="hidden" name="detailview" value="{$detailview}"/>
    <input type="hidden" name="action" value="index"/>
    <input type="hidden" name="record" value="{$ID}"/>
    <div id="CurrencyEditLay" class="layerPopup" style="display:none;width:25%;">
        <table class="ld-public-content-small" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="ld-form-item-label">{'TRANSFERCURRENCY'|@getFixedLabel}</td>
                <td class="ld-form-item-content"><a class="icon-homeimg icon-close" href="javascript:;" title="{$APP.LBL_CLOSE}" onclick="document.getElementById('CurrencyEditLay').style.display='none';"></a></td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'CURCURRENCY'|@getFixedLabel}</td>
                <td class="ld-form-item-content">{$CURRENCY_NAME|@getTranslatedCurrencyString}</td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'TRANCURRENCYTO'|@getFixedLabel}</td>
                <td class="ld-form-item-content">
                    <select class="commonSelectPop" name="transfer_currency_id" id="transfer_currency_id">';
                     {foreach key=cur_id item=cur_name from=$OTHER_CURRENCIES}
                         <option value="{$cur_id}">{$cur_name|@getTranslatedCurrencyString}</option>
                     {/foreach}
                     </select>
                </td>
            </tr>
            <tr>
                <td class="ld-form-item-content" colspan="2"><input type="button" onclick="form.submit();" name="Update" value="{'SAVE'|@getFixedLabel}" class="saveauto">
                </td>
            </tr>
        </table>
    </div>
    <table class="ld-public-content-small padB10" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">{'WHETHERTOENABLE'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <input type="hidden" value="{$CURRENCY_STATUS}" id="old_currency_status" />
                <input name="currency_status" {$STATUS_DISABLE} {if $ACTSELECT=='selected'}checked{/if} class="second_switch" type="checkbox"/>
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'CURRENCYNAME'|@getFixedLabel}</td>
            <td class="ld-form-item-content" style="overflow: inherit;">
                {if $MODE eq 'EDIT'}
                    <span name="span_currency_name" >{$CURRENCY_NAME|@getTranslatedCurrencyString}</span>
                    <input type="hidden" readonly value="{$CURRENCY_NAME}" name="currency_name" id="currency_name">
                {else}
                    <select name="currency_name" id="currency_name" class="commonSelectPop" onChange='updateSymbolAndCode();'>
                        {foreach key=header item=currency from=$CURRENCIES}
                            {if $header eq $CURRENCY_NAME}
                                <option value="{$header}" selected>{$header|@getTranslatedCurrencyString}({$currency.1})</option>
                            {else}
                                <option value="{$header}" >{$header|@getTranslatedCurrencyString}({$currency.1})</option>
                            {/if}
                        {/foreach}
                    </select>
                {/if}
            </td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'CURRENCYCODE'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><span id="span_currency_code">{$CURRENCY_CODE}</span><input type="hidden" readonly value="{$CURRENCY_CODE}" name="currency_code" id="currency_code" class="ld-select-inner"></td>
        </tr>
        <tr>
            <td class="ld-form-item-label"><font color="red">*</font>{'CURRENCYSYMBOL'|@getFixedLabel}</td>
            <td class="ld-form-item-content"><span id="span_currency_symbol">{$CURRENCY_SYMBOL}</span><input type="hidden" readonly value="{$CURRENCY_SYMBOL}" name="currency_symbol" id="currency_symbol" class="ld-select-inner"></td>
        </tr>
        <tr>
            <td class="ld-form-item-label" style="height:40px;"><font color="red">*</font>{'CONVERSIONRATE'|@getFixedLabel}<br>({'BASECURRENCY'|@getFixedlabel}{$MASTER_CURRENCY|@getTranslatedCurrencyString})</td>
            <td class="ld-form-item-content"><input type="text" value="{$CONVERSION_RATE}" name="conversion_rate" class="ld-select-inner"></td>
        </tr>
        <tr>
            <td class="ld-form-item-label"></td>
            <td class="ld-form-item-content" style="height:36px;line-height: 36px;padding: 0;"><span style="color:red;margin-left: 15px;" id="conversion_rate_formula"></span></td>
        </tr>
    </table>
</form>
</div>