{*<!--修改编码格式:统一编码：UTF-8-->*}
{if $DISPLAY eq true}
{assign var=display value=''}
{else}
{assign var=display value='style="display:none"'}
{/if}
<div class="Title" >
    <span class="Name" id="aid日程管理" onclick="showHideStatus('CalendarMag','aid日程管理');">{'Calendar'|@getTranstab}</span>
    {if $judge_Calendar eq 'yes' && $judge_Calendar_e eq 'yes'}
    <a href="#" onclick="listviewbutton_click(this,'Calendar','Create',event);">{'CREATE'|@getFixedLabel}</a>
    {/if}
</div>
<div class="TextBox" id="CalendarMag" style="display:block;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      {if count($CALENDAR) eq 0}
       <tr>
       <td  class="EditBox">
        &nbsp;
       </td>
       </tr>
     {/if}                     
      <tr>
        <td class="EditBox">
            <ul>
            {foreach item=data from=$CALENDAR}                            
            	<li><a href="index.php?module=Calendar&action=DetailView&record={$data.activityid}">{$data.subject}</a>
                    <a href="index.php?module=Accounts&action=DetailView&record={$data.accountid}">{$data.accountname}</a>
                    <span>{$data.activitytype}</span><span>{$data.eventstatus}</span><span>{$data.date_start}</span>
                </li>
             {/foreach}                                                         
            </ul>
        </td>
      </tr>                      
    </table>
</div>
<div class="Title" >
    <span class="Name" id="aid联系记录" onclick="showHideStatus('ContactRecords','aid联系记录');">{'ContactRecords'|getTranstab:'ContactRecords'}</span>
    {if $judge_ContactRecords eq 'yes' && $judge_ContactRecords_e eq 'yes'}<a href="#" onclick="listviewbutton_click(this,'ContactRecords','Create');">{'CREATE'|@getFixedLabel}</a>
    {/if}
</div>
<div class="TextBox" id="ContactRecords" style="display:block;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      {if count($CONTACTRECORDS) eq 0}
       <tr>
       <td  class="EditBox">
        &nbsp;
       </td>
       </tr>
     {/if}                     
      <tr>
        <td class="EditBox">
            <ul> 
            {foreach item=data from=$CONTACTRECORDS}                           
            	<li><a href="index.php?module=ContactRecords&action=DetailView&record={$data.contactrecordID}">{$data.subject}</a>
                    <a href="index.php?module=Accounts&action=DetailView&record={$data.accountid}">{$data.accountname}</a>
                    <span>{$data.contactrecordtype}</span><span>{$data.contactDate}</span>
                </li> 
            {/foreach}                                                        
            </ul>
        </td>
      </tr>                      
    </table>
</div>             
                
<div class="Title"  >
    <span class="Name" id="aid新建客户" onclick="showHideStatus('Accounts','aid新建客户');">{'CREATE'|@getFixedLabel}{'Accounts'|getTranstab:'Accounts'}</span>
    {if $judge_Accounts eq 'yes' && $judge_Accounts_e eq 'yes'}
    <a href="#" onclick="listviewbutton_click(this,'Accounts','Create',event);" >{'CREATE'|@getFixedLabel}</a>
{/if}</div>
<div class="TextBox" id="Accounts" style="display:block;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
      {if count($ACCOUNT) eq 0}
       <tr>
       <td  class="EditBox">
        &nbsp;
       </td>
       </tr>
     {/if}                      
      <tr>
        <td class="EditBox">
            <ul>    
            {foreach item=data from=$ACCOUNT}                        
            	<li><a href="index.php?module=Accounts&action=DetailView&record={$data.accountid}">{$data.accountname}</a>                                                  
                    <span>{$data.rating}</span><span>{$data.createdtime}</span>
                </li>   
            {/foreach}                                                       
            </ul>
        </td>
      </tr>
     
    </table>
</div>                

<div class="Title" onclick="showHideStatus('SalesOrder','aid合同订单');" >
    <span id="aid合同订单" class="Name">{'SalesOrder'|getTranstab}-{'SUM'|getVarFixedLabel}： {$SALESORDERTOTAL}</span>
    {if $judge_SalesOrder eq 'yes' && $judge_SalesOrder_e eq 'yes'}<a href="#" onclick="window.open('index.php?module=SalesOrder&action=EditView'),showHideStatus('SalesOrder','aid合同订单');">{'CREATE'|@getFixedLabel}</a>
{/if}</div>
<div class="TextBox" id="SalesOrder" style="display:block;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
     {if count($SALESORDER) eq 0}
       <tr>
       <td  class="EditBox">
        &nbsp;
       </td>
       </tr>
     {/if}                      
      <tr>
        <td class="EditBox">
            <ul>
            {foreach key=svalue item=data from=$SALESORDER}                            
            	<li><a href="index.php?module=SalesOrder&action=DetailView&record={$data.salesorderid}">{$data.subject}</a>                                                
                    <a href="index.php?module=Accounts&action=DetailView&record={$data.accountid}">{$data.accountname}</a>
                    <span>{$data.sostatus}</span><span>{$data.total}</span>
                </li>
             {/foreach}                                                         
            </ul>
        </td>
      </tr>                      
    </table>
</div>

<div class="Title" onclick="showHideStatus('CashBill','aid收款单');" >
    <span class="Name" id="aid收款单">{'CashBill'|getTranstab}-{'SUM'|getVarFixedLabel}：{$CASHBILLTOTAL}</span>
    {if $judge_CashBill eq 'yes' && $judge_CashBill_e eq 'yes'}
    <a href="#"  onclick="window.open('index.php?module=CashBill&action=EditView'),showHideStatus('CashBill','aid收款单');">{'CREATE'|@getFixedLabel}</a>
    {/if}
</div>
<div class="TextBox" id="CashBill" style="display:block;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
     {if count($CASHBILL) eq 0}
       <tr>
       <td  class="EditBox">
        &nbsp;
       </td>
       </tr>
     {/if}                      
      <tr>
        <td class="EditBox">
            <ul> 
            {foreach key=svalue item=data from=$CASHBILL}                            
            	<li><a href="index.php?module=CashBill&action=DetailView&record={$data.cashbillid}">{$data.cashbill_no}</a>                                                  
                    <a href="index.php?module=Accounts&action=DetailView&record={$data.accountid}">{$data.accountname}</a>
                    <span>{$data.paymentmethod}</span><span>{$data.total}</span><span>{$data.cashbilldate}</span>
                </li>
            {/foreach}                                                         
            </ul>
        </td>
      </tr>
      
    </table>
</div>