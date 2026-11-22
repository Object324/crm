/*
edit:can
date:20131015
reason:5082: 易用性建议：在单据更多信息中关联添加单据或在单据操作中关联创建单据时，希望在新窗口中打开。
*/
function MoreCreateCashBillFromAccount(obj,form)
{
    var module="CashBill";
     var accountid=form.account_id.value;
    window.open("index.php?module="+module+"&convertmode=update_so_val&action=EditView&return_module="+module+"&return_action=DetailView&Create=yes&account_id="+accountid);
}

function MoreCreateHelpDeskFromAccount(obj,form)
{
     var accountid=form.account_id.value;
    
    window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&parent_id="+accountid);
     
}
function MoreCreateModuleFromAccount(obj,form)
{    
    /**
    * 更新操作 
    *by  andy
    * reason 0007447: 联系人查看界面：更多信息“项目”中点击创建项目按钮，打开的新窗口中联系人姓名字段没有带出信息
    *date 20140317
    */
    if(form.return_module.value == 'Contacts')
    {
      var contact_id=form.contact_id.value;  
    }
    var accountid=form.account_id.value;
    if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
     {
      window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&parent_id="+accountid);
     }
     else
     {
        if(form.return_module.value == 'Contacts')
        {
            window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&contact_id="+contact_id);    
        }else{
            window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid); 
        }
        
     }
}
/*
*新增操作
*edit:by andy 
*date:20140311
*reason:客户更多信息新增 创建出库单，按钮指定跳转传值
*/
/*
function MoreCreateOutboundOrderFromAccounts(obj,form)
{
     var account_id=form.account_id.value;
     if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
     {
      //window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&record_id="+record_id);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+account_id);
     }
}
*/
/*
*新增操作
*edit:by andy 
*date:20140111
*reason:合同订单 更多信息页增加联系记录，按钮指定跳转传值
*/
function MoreCreateContactrecordsFromSalesOrder(obj,form)
{
     var salesorder_id=form.salesorder_id.value;
     var account_id=form.account_id.value;
     if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
     {
      //window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&record_id="+record_id);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+account_id+"&salesorder_id="+salesorder_id);
     }
}
/*
*新增操作
*edit:by andy 
*date:20140110
*reason:项目 更多信息页增加联系记录，按钮指定跳转传值
*/
function MoreCreateContactrecordsFromProject(obj,form)
{
     var accountid=form.account_id.value;
     var projectid=form.contact_id.value;
     if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
     {
      //window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&record_id="+record_id);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&projectid="+projectid);
     }
}

/*
*新增操作
*edit:by andy 
*date:20140110
*reason:项目任务 更多信息页增加联系记录，按钮指定跳转传值
*/
function MoreCreateContactrecordsFromProjecttask(obj,form)
{
     var projectid=form.projectid.value;
     var projecttaskid=form.projecttask_id.value;
     if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
     {
      //window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&record_id="+record_id);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&projecttaskid="+projecttaskid+"&projectid="+projectid);
     }
}
/*
*新增操作
*edit:by andy 
*date:20140110
*reason:服务单 更多信息页增加联系记录，按钮指定跳转传值
*/
function MoreCreateContactrecordsFromHelpDesk(obj,form)
{
     var account_id=form.account_id.value;
     var troubleticketid=form.ticket_id.value;
     if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
     {
      //window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&record_id="+record_id);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&troubleticketid="+troubleticketid+"&account_id="+account_id);
     }
}


/******************/
function MoreCreateHelpDeskFromContacts(obj,form)
{
     var contactid=form.contact_id.value;
  
  window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&parent_id="+contactid);
    
}
function MoreCreateModuleFromContacts(obj,form)
{
    var contactid=form.contact_id.value;
    var accountid=form.account_id.value;
    if(form.activity_mode!=undefined && form.activity_mode.value=="Events")
    {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+"&parent_id="+contactid);
    }
    else
    {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid);
    }
}

function MoreCreatePotentialFromContacts(obj,form)
{
    var contactid=form.contact_id.value;
     //var accountid=form.account_id.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid);
}


function MoreCreateAttachment(obj,form,tabindex)
{ 
    var contactid="0";
    if(tabindex!=undefined)
         contactid=tabindex.value;
     else
        contactid=form.return_id.value;
      var parentid="&parent_id=";
     if(contactid!="0")
     {
        parentid+=contactid;
     }
     else
     {
         parentid+=accountid;
     }
     /**
     *新增操作 by andy
     *date 20140317
     * reason 0007450: 产品查看界面：更多信息“合同订单”点击创建合同订单，在打开的新窗口中产品信息没有带入
     * 0007451: 产品查看界面：更多信息“服务单”点击创建服务单，在打开的新窗口中产品名称没有带入
     */
     if(form.return_module.value == 'Products'){
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes"+parentid+'&product_id='+tabindex.value);
     }else{
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes"+parentid);
     }
     
}

function MoreCreateRelatedList(obj,form)
{
     var contactid="0";
     var accountid="0";
     if(form.contact_id!=undefined)
        contactid=form.contact_id.value;
     if(form.account_id!=undefined)
        accountid=form.account_id.value;
     var parentid="&parent_id=";
     if(accountid!="0")
     {
        parentid+=accountid;
     }
     else if(contactid!="0")
     {
         parentid+=contactid;
     }
    var return_id="0";
    /**
    *新增操作 by andy
    *reason 0007446: 服务合同查看界面：更多信息“服务单”中点击创建服务单按钮，打开的新窗口新增服务单中没有带出服务合同信息
    *date 20140317
    */
    if(form.return_module.value == 'ServiceContracts')
    {
        servicecontractsid=form.return_id.value;
        if(form.return_id!=undefined)
        return_id=form.return_id.value;
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.return_module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+parentid+"&return_id="+return_id+'&servicecontractsid='+servicecontractsid);
    }else{
       if(form.return_id!=undefined)
      return_id=form.return_id.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.return_module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+parentid+"&return_id="+return_id);
 
    }
        
}

function MoreCreateModuleFromCampaigns(obj,form)
{
    var campaignid=form.campaignid.value;
    if(form.activity_mode!=undefined&&form.activity_mode.value=="Events")
     {
         window.open("index.php?module="+form.module.value+"&action=EditView&return_action=DetailView&Create=yes&parent_id="+campaignid+"&return_module=Campaigns");
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_action=DetailView&Create=yes&return_id="+campaignid+"&return_module=Campaigns");
     }
}
function MoreCreateCalendarFromCampaigns(obj,form)
{
    var campaignid=form.campaignid.value;
    
     window.open("index.php?module="+form.module.value+"&action=EditView&return_action=DetailView&Create=yes&parent_id="+campaignid+"&return_module=Calendar&activity_mode=Events");
}
function MoreCreatePotentialFromCampaigns(obj,form)
{
     var campaignid=form.campaignid.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&campaignid="+campaignid);
}

function MoreCreateModuleFromPotential(obj,form)
{
      var contactid=form.contact_id.value;
     var accountid=form.account_id.value;
     var potentialid=form.potential_id.value;
     if(form.activity_mode!=undefined&&form.activity_mode.value=="Events")
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&activity_mode=Events&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&parent_id="+potentialid);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid);
        
     }
}

function MoreCreateModuleFromSalesOrder(obj,form)
{
     if(form.contact_id!=undefined)
     {
        var contactid=form.contact_id.value;
     }
     if(form.account_id!=undefined)
     {
        var accountid=form.account_id.value;
     }
     if(form.potential_id!=undefined)
     {
        var potentialid=form.potential_id.value;
     }
     if(form.salesorder_id!=undefined)
     {
        var salesorderid=form.salesorder_id.value;
     }
     
     if(form.activity_mode!=undefined&&form.activity_mode.value=="Events")
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&activity_mode=Events&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&parent_id="+salesorderid);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&salesorder_id="+salesorderid);
     }
}

function MoreCreateInvoiceFromSalesOrder(obj,form)
{
    var contactid=form.contact_id.value;
    var accountid=form.account_id.value;
    var potentialid=form.potential_id.value;
    var salesorderid=form.salesorder_id.value
    window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&record="+salesorderid+"&convertmode=sotoinvoice");
}

function MoreCreateCashBillFromSalesOrder(obj,form)
{      
      if(form.salesorder_id!=undefined)
      {
        var salesorderid=form.salesorder_id.value;  
      }
      if(form.account_id!=undefined)
      {
        var accountid=form.account_id.value;  
      }
      window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&convertmode=update_so_val&salesorder_id="+salesorderid+"&parent_id="+salesorderid+"&account_id="+accountid);
}

function MoreCreateModuleFromQuotes(obj,form)
{
     var contactid=form.contact_id.value;
     var accountid=form.account_id.value;
     var potentialid=form.potential_id.value;
     var quoteid=form.quoteid.value;
     if(form.activity_mode!=undefined&&form.activity_mode.value=="Events")
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&activity_mode=Events&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&parent_id="+quoteid);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&quote_id="+quoteid);
     }
}


function MoreCreateModuleFromVendors(obj,form)
{
    // var contactid=form.contact_id.value;
    // var accountid=form.account_id.value;
   //  var potentialid=form.potential_id.value;
     var vendorid=form.vendor_id.value;
     if(form.activity_mode!=undefined&&form.activity_mode.value=="Events")
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&activity_mode=Events&parent_id="+vendorid+"&vendor_id="+vendorid);
     }
     else
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&vendor_id="+vendorid);
     }
}

function MoreCreateModuleFromPurchaseOrder(obj,form)
{
    // var contactid=form.contact_id.value;
    // var accountid=form.account_id.value;
   //  var potentialid=form.potential_id.value;
     //var vendorid=form.vendor_id.value;
      window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes");
}

function MoreCreateModuleFromInvoice(obj,form)
{
     if(form.contact_id!=undefined)
     {
        var contactid=form.contact_id.value;   
     }
     if(form.account_id!=undefined)
     {
        var accountid=form.account_id.value;
     }
     if(form.potential_id!=undefined)
     {
        var potentialid=form.potential_id.value;
     }
     if(form.invoice_id!=undefined)
     {
        var invoiceid=form.invoice_id.value;
     }
     if(form.activity_mode!=undefined&&form.activity_mode.value=="Events")
     {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&activity_mode=Events&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&parent_id="+invoiceid);
     }
     else
     {     
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&contact_id="+contactid+"&account_id="+accountid+"&potential_id="+potentialid+"&invoice_id="+invoiceid);
     }
}
function MoreCreateProductFromVendors(obj,form)
{
    var vendorid=form.vendor_id.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module=Products&return_action=DetailView&Create=yes&return_id="+vendorid+"&vendor_id="+vendorid);
}
function MoreCreateSendCashBillFromVendors(obj,form)
{
     var module="SendCashBill";
     var vendorid=form.vendor_id.value;
    window.open("index.php?module="+module+"&convertmode=update_so_val&action=EditView&return_module="+module+"&return_action=DetailView&Create=yes&vendor_id="+vendorid);
}

function MoreCreateModuleFromProject(obj,form)
{
    var projectid=form.return_id.value;
    if(form.parenttab.value == 'Project')
    {
        var account_id=form.account_id.value;
        var contact_id=form.contact_ids.value;
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&projectid="+projectid+"&account_id="+account_id+"&contact_id="+contact_id);  
    }
    else
    {
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&projectid="+projectid);
  
    }
}

function MoreCreateModuleFromSendPayment(obj,form)
{
    var purchaseorder_id=form.return_id.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&purchaseorder_id="+purchaseorder_id);
}

function MoreCreateModuleFromServiceContracts(obj,form)
{
    var salesorderid=form.return_id.value;
     var accountid=form.account_id.value;
     var contactid=form.contact_id.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&salesorder_id="+salesorderid+"&account_id="+accountid+"&contact_id="+contactid);
}

function MoreCreateContactrecordsFromProjects(obj,form)
{
     var accountid=form.account_id.value;
     var salesorderid=form.return_id.value;
    var contactid=form.contact_id.value;
        window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&account_id="+accountid+"&salesorder_id="+salesorderid+"&contact_id="+contactid);
}

/**
 * 供应商联系人创建联系记录方法，传递供应商ID以及联系人ID
 * @reason 0008470
 * @author Tujt 2014-04-17
 */
function MoreCreateVRecordsFromVContact(obj,form)
{
    // var contactid=form.contact_id.value;
    // var accountid=form.account_id.value;
   //  var potentialid=form.potential_id.value;
     var vendorid=form.vendor_id.value;
	  var contactid = form.vendorcontact_id.value;
     window.open("index.php?module="+form.module.value+"&action=EditView&return_module="+form.module.value+"&return_action=DetailView&Create=yes&vendor_id="+vendorid+"&contact_id="+contactid);
}