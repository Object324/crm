<script type="text/javascript" src="include/js/Piaozone.js"></script>
{*<script src="https://img.piaozone.com/static/gallery/jquery.min-normal.js"></script>*}

<tr id="pz_block" {*{if $InvioceHtml eq ''}style="display: none;"{/if}*}>
    <td style="padding:0px;width:100%;">
        <div class="DivCName DivCNamehover tip-items-list bindtip" data-direction="left" data-type="position" data-tip="{'COLLAPSE'|@getFixedLabel}" onclick="showHideStatus('tblInvoiceDetailsInfo','aidInvoiceDetailsInfo');">
            <span class="" name="aidInvoiceDetailsInfo"></span>{'InvoiceDetailsInfo'|@getFixedLabel}
        </div>
        <div class="divSocallProduct" id="tblInvoiceDetailsInfo" name="tblInvoiceDetailsInfo">
            <table id="pz_table" border="0" cellspacing="0" cellpadding="0" width="100%" class="" style="table-layout: fixed;word-break: break-all; word-wrap: break-word;">
                <thead>
                <tr>
                    <td class="ld-form-item-content-entrytitle" style="width:65px;text-align: center;">#</td>
                    <td class="ld-form-item-content-entrytitle">{'InvoiceType'|@getFixedLabel}</td>
                    <td class="ld-form-item-content-entrytitle">{'InvoiceCode'|@getFixedLabel}</td>
                    <td class="ld-form-item-content-entrytitle">{'InvoiceNumber'|@getFixedLabel}</td>
                    <td class="ld-form-item-content-entrytitle">{'InvoiceDate'|@getFixedLabel}</td>
                    <td class="ld-form-item-content-entrytitle">{'InvoiceTotalAmount'|@getFixedLabel}</td>
                    <td class="ld-form-item-content-entrytitle">{'InvoiceBuyername'|@getFixedLabel}</td>
                    <td class="ld-form-item-content-entrytitle"></td>
                </tr>
                </thead>
                <tbody>
                {$InvioceHtml}
                </tbody>
            </table>

            <table class="" width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
                <tr>
                    <td class="ld-form-item-content-entrytotal" width="90%" style="" align="right"><b>{'InvoiceTotal'|@getFixedLabel}</b></td>
                    <td class="ld-form-item-content-entrytotal" width="10%" style="" align="left">
                        <span id="span_pz_invoicetotal">{$InvoiceTotal}</span>
                    </td>
                </tr>

            </table>

        </div>
    </td>
</tr>
