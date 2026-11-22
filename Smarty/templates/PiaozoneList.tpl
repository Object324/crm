<script type="text/javascript" src="include/js/Piaozone.js"></script>
<script src="https://img.piaozone.com/static/gallery/jquery.min-normal.js"></script>

<tr id="pz_block" {*{if $InvioceHtml eq ''}style="display: none;"{/if}*}>
    <td colspan=4 class="ld-from-headblock-entry entryContentPad">
        <div class="ld-from-headblock-title">
            <b tag="headblock-title"><span></span>{'InvoiceDetailsInfo'|@getFixedLabel}</b>
        </div>
        <div id="div_pz_block" style="overflow: auto; max-height: 300px;">
            <table id="pz_table" class="" border="0" cellpadding="0" cellspacing="0" width="100%">
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
                        <input type="hidden" name="pz_invoicetotal" id="pz_invoicetotal" value="{$InvoiceTotal}"><span id="span_pz_invoicetotal">{$InvoiceTotal}</span>
                    </td>
                </tr>
                {*<tr>
                    <td>
                        <input type="button" name="Button" class="ld-button ld-button-primary" value="导入发票" onclick="PiaozoneObj.ImportInvoice(this,'{$MODULE}','{$ID}');">
                    </td>
                </tr>*}
            </table>
        </div>
    </td>
</tr>
<script type="text/javascript">
    var InvioceDataString = "{$InvioceData|@addslashes}";//编辑单据时
    {*var InvioceCompanyInfo = "{$InvioceCompanyInfo|@addslashes}";*}
    if (typeof PiaozoneObj == "undefined" || PiaozoneObj == undefined){
        var PiaozoneObj=new Piaozone();
    }
    PiaozoneObj.isauthorize = "{$PiaozoneAuth}";
    // PiaozoneObj.companyInfo = eval('('+ InvioceCompanyInfo +')')?eval('('+ InvioceCompanyInfo +')'):JSON.parse(InvioceCompanyInfo);

    if(InvioceDataString!='')
    {
        var InvioceData=eval('('+ InvioceDataString +')')?eval('('+ InvioceDataString +')'):JSON.parse(InvioceDataString);
        if (Object.keys(InvioceData).length > 0){
            PiaozoneObj.invoicedata = InvioceData;
        }

    }
    console.log(PiaozoneObj.invoicedata);
</script>
