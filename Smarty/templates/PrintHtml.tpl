<!-- 通用信息-->
<div id="divPrint1" class="ld-pop-container padT28 padB0">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'GENERALINFO'|@getFixedLabel}</div>
    </div>
</div>
<div id="divPrint1_1" class="ld-pop-container ld-table-container ld-table-container-lines">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>        
            <td><span>{'CURRENTDATE'|@getFixedLabel}</span></td>
            <td><span>[var.table_today_table]</span></td>
            <td><span>{'CURRENTMONTH'|@getFixedLabel}</span></td>
            <td><span>[var.table_month_table]</span></td>
            <td><span>{'CURRENTYEAR'|@getFixedLabel}</span></td>
            <td><span>[var.table_year_table]</span></td>
        </tr>
        <tr>
            <td><span>{'SUM'|@getFixedLabel}</span></td>
            <td><span>[var.table_total_table]</span></td>
            <td><span>{'SUMCAPITAL'|@getFixedLabel}</span></td>
            <td><span>[var.table_total_big_table]</span></td>
            <td><span>{'REMARK'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_remark_products]</span></td>
        </tr>
        <tr>
            <td><span>{'BOOKQUANTITY'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_paperquantity_products]</span></td>
            <td><span>{'ANUMBEROF'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_firmoffer_products]</span></td>
            <td><span>{'PROFITLOSSQUANTITY'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_profitloss_products]</span></td>
        </tr>
		<tr>
            <td><span>{'ORIGNALBILL'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_entitytypeid_products]</span></td>
            <td><span>{'BARCODE'|@getFixedLabel}</span></td>
            <td><span>[var.(Function)_salesorder:dianshang_orderno:salesorder]</span></td>
            <td><span>{'ACCOUNTGETBILL'|@getFixedLabel}</span></td>
            <td><span>[var.Accounts_getbillamount_Accounts]</span></td>
        </tr>   
       	<tr>
            <td><span>{'ORDERGETBILL'|@getFixedLabel}</span></td>
            <td><span>[var.Order_getbillamount_Order]</span></td>
            <td><span>{'HASRECEIVABLES'|@getFixedLabel}</span></td>
            <td><span>[var.Order_havereceivables_Order]</span></td>
            <td><span>{'APPROVALHISTORY'|@getFixedLabel}</span></td>
            <td><span>[var.approvehistory_module_approve]</span></td>
        </tr>         
    </tbody>
</table>
</div>
<!-- 本公司信息 -->
<div id="divPrint2" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'COMPANYINFOMATION'|@getFixedLabel}</div>
    </div>
</div>
<div id="divPrint2_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'COMPANYNAME'|@getFixedLabel}</span></td>
            <td><span>[var.company_organizationname_company]</span></td>
			<td><span>{'COMPANYADDRESS'|@getFixedLabel}</span></td>
            <td><span>[var.company_address_company]</span></td>
			<td><span>{'COMPANYLOGOPATH'|@getFixedLabel}</span></td>
            <td><span>[var.company_logoname_company]</span></td>
        </tr>
        <tr>
            <td><span>{'COMPANYPHONE'|@getFixedLabel}</span></td>
            <td><span>[var.company_phone_company]</span></td>
            <td><span>{'COMPANYFAX'|@getFixedLabel}</span></td>
            <td><span>[var.company_fax_company]</span></td>
            <td><span>{'COMPANYWEBSITE'|@getFixedLabel}</span></td>
            <td><span>[var.company_website_company]</span></td>
        </tr>
	    <tr>
            <td><span>{'COMPANYCITY'|@getFixedLabel}</span></td>
            <td><span>[var.company_city_company]</span></td>
			<td><span>{'COMPANYPROVINCE'|@getFixedLabel}</span></td>
            <td><span>[var.company_state_company]</span></td>
			<td><span>{'COMPANYCOUNTRY'|@getFixedLabel}</span></td>
            <td><span>[var.company_country_company]</span></td>
		</tr>
        <tr>
			<td><span>{'COMPANYZIPCODE'|@getFixedLabel}</span></td>
            <td><span>[var.company_code_company]</span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>
    </tbody>
</table>
</div>
<!-- 负责人信息  -->
<div id="divPrint3" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'PERSONCHARGEINFOMATION'|@getFixedLabel}</div>
    </div>
</div>
<div id="divPrint3_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
			<td><span>{'PERSONCHARGENAME'|@getFixedLabel}</span></td>
			<td><span>[var.users_last_name_users]</span></td>
            <td><span>{'PERSONCHARGEREALNAME'|@getFixedLabel}</span></td>
			<td><span>[var.users_real_name_users]</span></td>
			<td><span>{'PERSONCHARGEPHONE'|@getFixedLabel}</span></td>
            <td><span>[var.users_phone_mobile_users]</span></td>
        </tr>
        <tr>
            <td><span>{'PERSONCHARGEEMAIL'|@getFixedLabel}</span></td>
            <td><span>[var.users_email1_users]</span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>
    </tbody>
</table>
</div>
<!-- 产品 明细   -->
<div id="divPrint4" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'Carousel_Productdetails'|@getTranstab}</div>
    </div>
</div>
<div id="divPrint4_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'SEQUENCE'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_#_products]</span></td>
            <td><span>{$PRODUCTFIELDLABELS.productname}</span></td>
            <td><span>[var.productdetails_productname_products]</span></td>
            <td><span>{'PRODUCTBOMNAME'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_productbomid_products]</span></td>
        </tr>
        <tr>
            <td><span>{'NumberOfProductsBom'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_productbomquantity_products]</span></td>
            <td><span>{$PRODUCTFIELDLABELS.productsheet}</span></td>
            <td><span>[var.productdetails_productsheet_products]</span></td>
            <td><span>{$PRODUCTFIELDLABELS.product_no}</span></td>
            <td><span>[var.productdetails_product_no_products]</span></td>
        </tr>
         {if $PRODUCTFIELDLABELS.usageunit|trim neq ''}
            <tr>
                <td><span>{$PRODUCTFIELDLABELS.usageunit}</span></td>
                <td><span>[var.productdetails_usageunit_products]</span></td>
                <td><span>{'NETTOTAL'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_total_products]</span></td>
                <td><span>{'NETTOTAL'|@getFixedLabel}{'CAPITAL'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_total_big_products]</span></td>
            </tr>
            <tr>
                <td><span>{'TOTALNUMOF'|@getFixedLabel}</span></td>
                <td><span>[var.table_totalquantity_table]</span></td>
                <td><span>{'REMARK'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_comment_products]</span></td>
                <td><span>{'PRODUCTFIELDNULLCOLS'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_NULL_products]</span></td>
            </tr>
        {else}
            <tr>
                <td><span>{'TOTALNUMOF'|@getFixedLabel}</span></td>
                <td><span>[var.table_totalquantity_table]</span></td>
                <td><span>{'REMARK'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_comment_products]</span></td>
                <td><span>{'PRODUCTFIELDNULLCOLS'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_NULL_products]</span></td>
            </tr>
            <tr>
                <td><span>{'NETTOTAL'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_total_products]</span></td>
                <td><span>{'NETTOTAL'|@getFixedLabel}{'CAPITAL'|@getFixedLabel}</span></td>
                <td><span>[var.productdetails_total_big_products]</span></td>
                <td><span></span></td>
                <td><span></span></td>
            </tr>
        {/if}
        <tr>
            {if $PRODUCTFIELDLABELS.imagename|trim neq ''}
                <td><span>{$PRODUCTFIELDLABELS.imagename}</span></td>
                <td><span>[var.productdetails_imagename_products]</span></td>
            {else}
                <td><span>{$PRODUCTFIELDLABELS.productcategory}</span></td>
                <td><span>[var.productdetails_productcategory_products]</span></td>
            {/if}
            <td><span>{'PRONUMUNIT'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_mergerqty_unit_products]</span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>
    </tbody>
</table>
</div>
<!--产品自定义字段 -->
{$PRODTOOLHTML}
<!--{*
    打印模板中，添加RMB产品相关打印字段
    @project PROT99 奥特林：产品明细录入改进
    @author tujt 2014-10-21
*}-->
<div id="divPrint6" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'PRODUCTSDETAILSFOREIGNTRAD'|@getTranstab} {'Products'|@getTranstab} {'DETAIL'|@getFixedLabel}</div>
    </div>
</div>
<div id="divPrint6_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'RMB_TAXPRICE_LABEL'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_rmb_taxprice_products]</span></td>
            <td><span>{'RMB_AMOUNT_LABEL'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_rmb_taxamount_products]</span></td>
            <td><span>{'RMB_EUR_STANDARDPRICE'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_rmbprice_products]</span></td>
        </tr> 
        <tr>
            <td><span>{'RMB_DISCOUNT_RATE'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_discount_percent_products]</span></td>
            <td><span>{'RMB_EUR_PRICE'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_eur_price_products]</span></td>
            <td><span>{'RMB_DISCOUNT_AMOUNT'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_discount_amount_products]</span></td>
        </tr>
        <tr>
            <td><span>{'Exchange Rate'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_tax_rate_products]</span></td>
            <td><span>{'RMB_TARIFF_RATE'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_tax_customs_products]</span></td>
            <td><span>{'RMB_VAT_RATE'|@getFixedLabel}</span></td>
            <td><span>[var.productdetails_tax_added_products]</span></td>
        </tr>
        <tr>
            <td><span>{'RMB_FREIGHT_COEFFICIENT'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_tax_freight_products]</span></td>
            <td><span>{'RMB_PROFIT_RATE'|@getFixedlabel}</span></td>
            <td><span>[var.productdetails_tax_profit_products]</span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>
    </tbody>
</table>
</div>
<!--审批历史 -->         
<div id="divPrint7" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'APPROVALHISTORY'|@getTranstab}</div>
    </div>
</div>
<div id="divPrint7_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'SEQUENCE'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_#_approve]</span></td>
            <td><span>{'OPERATING'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_operate_approve]</span></td>
            <td><span>{'APPROVALSTEP'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_stepname_approve]</span></td>
        </tr>
        <tr>
            <td><span>{'OPERATOR'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_operator_approve]</span></td>
            <td><span>{'APPROVALRESULT'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_approveresult_approve]</span></td>
            <td><span>{'NEXTOPERATOR'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_nextstepbyname_approve]</span></td>
        </tr>
        <tr>
            <td><span>{'APPROVALSUGGESTION'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_description_approve]</span></td>
            {if $AUTOGRAPH eq 1}
                <td><span>{'handwriting'|@getFixedLabel}</span></td>
                <td><span>[var.approvedetails_approveautographpath_approve]</span></td>
            {else}
                <td><span></span></td>
                <td><span></span></td>
            {/if}
            <td><span>{'OPERATTIME'|@getFixedLabel}</span></td>
            <td><span>[var.approvedetails_createdtime_approve]</span></td>
        </tr>
    </tbody>
</table>
</div>
<!--应收信息 -->          
<div id="divPrint8" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'RECEIVEINFO'|@getTranstab}</div>
    </div>
</div>
<div id="divPrint8_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'RECEIVEINFO'|@getFixedLabel}</span></td>
            <td><span>[var.PaymentPlan_NoCashBill_PaymentPlan]</span></td>
            <td><span>{'RECEIVENOTICE'|@getFixedLabel}</span></td>
            <td><span>[var.PaymentPlan_DebitNote_PaymentPlan]</span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>
    </tbody>
</table>
</div>
<!--回款计划日期信息 -->
<div id="divPrint9" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'PLANNEDDATEPAYMENTINFO'|@getTranstab}</div>
    </div>
</div>
<div id="divPrint9_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'DATE'|@getFixedLabel}</span></td>
            <td><span>[var.PaymentPlan_Today_PaymentPlan]</span></td>
            <td><span>{'MONTH'|@getFixedLabel}</span></td>
            <td><span>[var.PaymentPlan_Month_PaymentPlan]</span></td>
            <td><span>{'YEAR'|@getFixedLabel}</span></td>
            <td><span>[var.PaymentPlan_Year_PaymentPlan]</span></td>
        </tr>       
    </tbody>
</table>
</div>
{if $BLOCKFIELDLABEL neq ''}
    <div id="divPrint10" class="ld-pop-container padT28 padB0" style="display: none;">
        <div class="ld-pop-contnet-title-items">
            <div class="ld-pop-contnet-title-item">{'Accounts'|@getTranstab} {$BLOCKFIELDLABEL}</div>
        </div>
    </div>
    <div id="divPrint10_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
    <table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
        <thead>
            <tr>
                <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
                <th width="23%">{'Value'|@getFixedlabel}</th>
                <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
                <th width="23%">{'Value'|@getFixedlabel}</th>
                <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
                <th width="23%">{'Value'|@getFixedlabel}</th>
            </tr>
        </thead>
        <tbody>
            {foreach item=info from=$ACCTCONTFLD}
                <tr>
                    <td><span>{$info.fieldlabel}</span></td>
                    <td><span>{$info.print}</span></td>
                    <td><span></span></td>
                    <td><span></span></td>
                    <td><span></span></td>
                    <td><span></span></td>
                </tr>
            {/foreach}
        </tbody>
    </table>
    </div>
{/if}
<!--相关信息 -->
<div id="divPrint11" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'MOREINFORMATION'|@getTranstab}</div>
    </div>
</div>
<div id="divPrint11_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{'PRODUCTS'|@getFixedLabel}</span></td>
            <td><span>[var.More_get_Products]</span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>       
    </tbody>
</table>
</div>
<!--非表格格式的产品信息 -->
<div id="divPrint12" class="ld-pop-container padT28 padB0" style="display: none;">
    <div class="ld-pop-contnet-title-items">
        <div class="ld-pop-contnet-title-item">{'Productinformationintabularformat'|@getTranstab}</div>
    </div>
</div>
<div id="divPrint12_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
<table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
    <thead>
        <tr>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
            <th width="10%">{'NORMALNAME'|@getFixedlabel}</th>
            <th width="23%">{'Value'|@getFixedlabel}</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><span>{$PRODUCTFIELDLABELS.productname}</span></td>
            <td><span>[var.productdetails_productname_productrow]</span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
            <td><span></span></td>
        </tr>       
    </tbody>
</table>
</div>