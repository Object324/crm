<div id="windows_content" class="ld-pop-container" style="max-height:400px;overflow-y:auto;">
    <input type="hidden" id="hidden_record" value="{$RECORD}"/>
    <input type="hidden" id="hidden_numrows" value="{$NUMROW}"/>
    <input type="hidden" id="hidden_type" value="{$PRICESTYPE}"/>
    <table class="ld-public-content-small pad0" border="0" cellpadding="0" cellspacing="0" width="100%">
        <tr>
            <td class="ld-form-item-label">{'PRICESTRATEGY'|@getFixedLabel}</td>
            <td class="ld-form-item-content">
                <select name="ps_type" id="ps_type" class="ld-select-inner" onchange="price_strategy.getInstance().type_onchange(this)">
                    <option value=0>{'NONE'|@getFixedLabel}</option>
                    <option value=1>{'PRICESTRATEGYTYPE1'|@getFixedLabel}</option>
                    <option value=2>{'PRICESTRATEGYTYPE1'|@getFixedLabel}+{'PRICESTRATEGYTYPE2'|@getFixedLabel}</option>
                    <option value=3>{'PRICESTRATEGYTYPE1'|@getFixedLabel}+{'PRICESTRATEGYTYPE3'|@getFixedLabel}</option>
                </select>
            </td>
        </tr>
    </table>
    <div id="ps_type1" class="ld-table-container ld-table-container-lines padT16" style="display: none">
        <div class="ld-pop-contnet-title-items padB16">
            <div class="ld-pop-contnet-title-item">{'PRICESTRATEGYTYPE1'|@getFixedLabel}</div>
        </div>
        <table class="ld-table-container-table-lasttr" border="0" cellpadding="0" cellspacing="0" width="100%">
            <thead>
            <tr>
                <th>{'QUANTITY'|@getFixedLabel}（{'PRICESTRATEGYFROM'|@getFixedLabel}）</th>
                <th>{'QUANTITY'|@getFixedLabel}（{'PRICESTRATEGYTO'|@getFixedLabel}）</th>
                <th>{'AMOUNT'|@getFixedLabel}</th>
                <th class="thcenter" width="65px">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            </thead>
            <tbody>
            {if $NUMROW1 gt 0}
                {foreach item=content from=$PSTYPE1}
                    <tr class="lvtColData" tag="row_content">
                        <td><input type="text" value="{$content.0}" class="ld-input-inner"/></td>
                        <td><input type="text" value="{$content.1}" class="ld-input-inner"/></td>
                        <td><input tag="price_input" type="text" value="{$content.2}" class="ld-input-inner"/></td>
                        <td class="tdcenter">
                            <i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;"
                               title="{'DELETE'|@getFixedLabel}" border="0" onclick="price_strategy.getInstance().delete_row(this,1)"></i>
                        </td>
                    </tr>
                {/foreach}
            {else}
                <tr class="lvtColData" tag="row_content">
                    <td><input type="text" class="ld-input-inner"/></td>
                    <td><input type="text" class="ld-input-inner"/></td>
                    <td><input tag="price_input" type="text" class="ld-input-inner"/></td>
                    <td class="tdcenter">
                        <i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;"
                           title="{'DELETE'|@getFixedLabel}" border="0" onclick="price_strategy.getInstance().delete_row(this,1)"></i>
                    </td>
                </tr>
            {/if}
            <tr>
                <td colspan="4">
                    <div class="ld-btn-icontext-items flexstart">
                        <a class="ld-btn-icontext-item" onclick="price_strategy.getInstance().add_row(this,1);">
                            <i class="ld-fonticon ld-fonticon-addhover"></i><span>{'PRICESTRATEGYADDFIX'|@getFixedLabel}</span>
                        </a>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
    <div id="ps_type2" class="padT28" style="display: none">
        <div class="ld-pop-contnet-title-items padB16">
            <div class="ld-pop-contnet-title-item">{'PRICESTRATEGYTYPE2'|@getFixedLabel}</div>
        </div>
        <table class="ld-public-content-small pad0" border="0" cellpadding="0" cellspacing="0" width="100%">
            <tr>
                <td class="ld-form-item-label">{'PRICESTRATEGYTYPE2'|@getFixedLabel}{'QUANTITY'|@getFixedLabel}</td>
                <td class="ld-form-item-content"><input type="text" value="1" disabled class="ld-input-inner"/></td>
            </tr>
            <tr>
                <td class="ld-form-item-label">{'LISTPRICE'|@getFixedLabel}</td>
                <td class="ld-form-item-content"><input type="text" value="{$PSTYPE2.0.2}" class="ld-input-inner"/></td>
            </tr>
        </table>
    </div>
    <div id="ps_type3" class="ld-table-container ld-table-container-lines padT16" style="display: none">
        <div class="ld-pop-contnet-title-items padB16">
            <div class="ld-pop-contnet-title-item">{'PRICESTRATEGYTYPE3'|@getFixedLabel}</div>
        </div>
        <table class="ld-table-container-table-lasttr" border="0" cellpadding="0" cellspacing="0" width="100%">
            <thead>
            <tr>
                <th>{'QUANTITY'|@getFixedLabel}（{'PRICESTRATEGYFROM'|@getFixedLabel}）</th>
                <th>{'QUANTITY'|@getFixedLabel}（{'PRICESTRATEGYTO'|@getFixedLabel}）</th>
                <th>{'LISTPRICE'|@getFixedLabel}</th>
                <th class="thcenter" width="65px">{'OPERATING'|@getFixedLabel}</th>
            </tr>
            </thead>
            <tbody>
            {if $NUMROW3 gt 0}
                {foreach item=content from=$PSTYPE3}
                    <tr class="lvtColData" tag="row_content">
                        <td><input type="text" value="{$content.0}" class="ld-input-inner"/></td>
                        <td><input type="text" value="{$content.1}" class="ld-input-inner"/></td>
                        <td><input tag="price_input" type="text" value="{$content.2}" class="ld-input-inner"/></td>
                        <td class="tdcenter">
                            <i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;"
                               title="{'DELETE'|@getFixedLabel}" border="0" onclick="price_strategy.getInstance().delete_row(this,3)"></i>
                        </td>
                    </tr>
                {/foreach}
            {else}
                <tr class="lvtColData" tag="row_content">
                    <td><input type="text" class="ld-input-inner"/></td>
                    <td><input type="text" class="ld-input-inner"/></td>
                    <td><input tag="price_input" type="text" class="ld-input-inner"/></td>
                    <td class="tdcenter">
                        <i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;"
                           title="{'DELETE'|@getFixedLabel}" border="0" onclick="price_strategy.getInstance().delete_row(this,3)"></i>
                    </td>
                </tr>
            {/if}
            <tr>
                <td colspan="4">
                    <div class="ld-btn-icontext-items flexstart">
                        <a class="ld-btn-icontext-item" onclick="price_strategy.getInstance().add_row(this,3);">
                            <i class="ld-fonticon ld-fonticon-addhover"></i><span>{'PRICESTRATEGYADDINCREMENT'|@getFixedLabel}</span>
                        </a>
                    </div>
                </td>
            </tr>
            </tbody>
        </table>
    </div>
</div>