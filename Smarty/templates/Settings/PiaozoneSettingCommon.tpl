{if $mode eq 'view' || $mode eq 'saveSetting' || (($mode eq 'saveTax' || $mode eq 'deleteTax' || $mode eq 'saveTaxScope') && $refreshtype eq 'view')}
    <table class="settingTable" width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <th colspan="4">{'InvoiceHeader'|@getFixedLabel}</th>
        </tr>
        <tr>
            <td width="30%">{'COMPANYNAME'|@getFixedLabel}</td>
            <td width="30%">{'CompanyTaxID'|@getFixedLabel}</td>
            <td width="30%">{'APPLICABLESCOPE'|@getFixedLabel}</td>
            <td width="150px">{'OPERATING'|@getFixedLabel}</td>
        </tr>
        {foreach key=key item=info from=$companyInfo}
            <tr id="taxNo_{$info['taxNo']}" tag="companyPiaozone" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                <td><span class="text-ellipsis">{$info['name']}</span></td>
                <td><span class="text-ellipsis">{$info['taxNo']}</span></td>
                <td><span class="text-ellipsis">{$info['scope_label']}</span></td>
                <td>
                    <a href="javascript:void(0);" tag="view" onclick="PiaozoneSetting.getInstance().createTax(this,'{$info['taxNo']}')" data-tip="{'EDIT'|@getFixedLabel}" data-direction="top" data-type="position" style="padding-left: 5px">
                        <i tag="delete" class="ld-fonticon ld-fonticon-edit" href="javascript:;"></i>
                    </a>
                    <a href="javascript:void(0);" tag="view"  onclick="PiaozoneSetting.getInstance().setTaxScope(this,'{$info['taxNo']}')" data-tip="{'ALLOCATE'|@getFixedLabel}" data-direction="top" data-type="position" style="padding-left: 5px">
                        <i tag="delete" class="ld-fonticon ld-fonticon-allocate" href="javascript:;"></i>
                    </a>
                    {if $companyLength > 1}
                        <a href="javascript:void(0);" tag="view" name="deleteBtn" onclick="PiaozoneSetting.getInstance().deleteTax(this,'{$info['taxNo']}')" data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position" style="padding-left: 5px">
                            <i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;"></i>
                        </a>
                    {/if}
                </td>
            </tr>
        {/foreach}
        <td colspan="4" class="marB20">
            <div class="ld-btn-icontext-items flexstart">
                <a class="ld-btn-icontext-item" href="javascript:void(0);" tag="view" onclick="PiaozoneSetting.getInstance().createTax(this,'')">
                    <i class="ld-fonticon ld-fonticon-addhover"></i><span>{'AddInvoiceHeader'|@getFixedLabel}</span>
                </a>
            </div>
        </td>
    </table>

{elseif $mode eq 'editSetting' || (($mode eq 'saveTax' || $mode eq 'deleteTax' || $mode eq 'saveTaxScope') && $refreshtype eq 'edit')}
    <table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
        <thead>
        <tr>
            <th width="30%">{'COMPANYNAME'|@getFixedLabel}</th>
            <th width="30%">{'CompanyTaxID'|@getFixedLabel}</th>
            <th width="30%">{'APPLICABLESCOPE'|@getFixedLabel}</th>
            <th align="center" width="150px">{'OPERATING'|@getFixedLabel}</th>
        </tr>
        </thead>
        <tbody>
        {foreach key=key item=info from=$companyInfo}
            <tr id="taxNo_{$info['taxNo']}" tag="companyPiaozone" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
                <td><span class="text-ellipsis">{$info['name']}</span></td>
                <td><span class="text-ellipsis">{$info['taxNo']}</span></td>
                <td><span class="text-ellipsis">{$info['scope_label']}</span></td>
                <td align="center" >
                    <a href="javascript:void(0);" tag="edit" onclick="PiaozoneSetting.getInstance().createTax(this,'{$info['taxNo']}')" data-tip="{'EDIT'|@getFixedLabel}" data-direction="top" data-type="position" style="padding-left: 5px">
                        <i tag="delete" class="ld-fonticon ld-fonticon-edit" href="javascript:;"></i>
                    </a>
                    <a href="javascript:void(0);" tag="edit" onclick="PiaozoneSetting.getInstance().setTaxScope(this,'{$info['taxNo']}')" data-tip="{'ALLOCATE'|@getFixedLabel}" data-direction="top" data-type="position" style="padding-left: 5px">
                        <i tag="delete" class="ld-fonticon ld-fonticon-allocate" href="javascript:;"></i>
                    </a>
                    {if $companyLength > 1}
                        <a href="javascript:void(0);" tag="edit" name="deleteBtn" onclick="PiaozoneSetting.getInstance().deleteTax(this,'{$info['taxNo']}')" data-tip="{'DELETE'|@getFixedLabel}" data-direction="top" data-type="position" style="padding-left: 5px">
                            <i tag="delete" class="ld-fonticon ld-fonticon-del" href="javascript:;"></i>
                        </a>
                    {/if}
                </td>
            </tr>
        {/foreach}
        <td colspan="4" class="marB20">
            <div class="ld-btn-icontext-items flexstart">
                <a class="ld-btn-icontext-item" href="javascript:void(0);" tag="edit" onclick="PiaozoneSetting.getInstance().createTax(this,'')">
                    <i class="ld-fonticon ld-fonticon-addhover"></i><span>{'AddInvoiceHeader'|@getFixedLabel}</span>
                </a>
            </div>
        </td>
        </tbody>
    </table>

{/if}