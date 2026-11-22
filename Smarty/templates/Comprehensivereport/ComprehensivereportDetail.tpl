<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PageRecordPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>
<script type='text/javascript' src='{$JSURL}include/js/crypto-js.min.js?v={$GLOBALMINVERSION}'></script>
<script type='text/javascript' src='{$JSURL}include/js/cls_encryptyurl.js?v={$GLOBALMINVERSION}'></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/{$LANUGAGETYPE}.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js"></script>
<script type="text/javascript" language="javascript" src="{$JSURL}include/js/cls_wxOpenData.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script><!--公共-->    
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/style.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/common.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/leftmenu.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/common-23.css"/>
<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/Comprehensivereport.css"/>
<script type="text/javascript" src="crmcommon/js/jquery/jquery.min.js"></script>

<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<script type="text/javascript" src="include/js/SystemPopup/PopupLayer.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
    var global_js_url='{$JSURL}';
    var CURRENT_USER_ID ='{$CURRENT_USER_ID}';
</script>
    <div id="status" style="position:absolute;display:none;left:850px;top:95px;height:27px;white-space:nowrap;"></div>
{if $name eq 'account_cashbill'}
<title>{'CUSTOMERCOLLECTIONLIST'|@getFixedLabel}</title>
{elseif $name eq 'user_cashbill'}
<title>{'PERSONNELCOLLECTIONLIST'|@getFixedLabel}</title>
{elseif $name eq 'user_salesorder'}
<title>{'PERSONNELSIGNINGLIST'|@getFixedLabel}</title>
{elseif $name eq 'costprice_salesorder'}
<title>{'SIGNGROSSMARGIN'|@getFixedLabel}</title>
{elseif $name eq 'grossprofitdetial'}
<title>{'SIGNGROSSMARGINDETAILED'|@getFixedLabel}</title>
{elseif $name eq 'product_grossprofit'}
<title>{'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}</title>
{elseif $name eq 'SalesOrder_Testingdetial'}
<title>{'DETECTIONTASKSTATISTICS'|@getFixedLabel}</title>
{else}
<title>{'CUSTOMERGROSSMARGINSTATISTICS'|@getFixedLabel}</title>
<meta http-equiv="X-UA-Compatible" content="IE=7" />
{/if}
</head>
<body class="small">
<div class="DivBox">

{if $name eq 'year_situation'}
    <!--年度企业销售状况总表-->
    <div class="DivBox_top">
        <h1>{$year}{'ANNUALSALESENTERPRISE'|@getFixedLabel}</h1>
    </div>
{elseif $name eq 'account_cashbill' }
    <!--销售明细表-->
    <!--客户回款明细表-->
    <div class="DivBox_top">
        <h1>   
        {if $begin_date}   
            {'SALESDETAIL'|@getFixedLabel}-{'Customer'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
        {else} 
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'SALESDETAIL'|@getFixedLabel}-{'Customer'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'SALESDETAIL'|@getFixedLabel}-{'Customer'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'SALESDETAIL'|@getFixedLabel}-{'Customer'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'SALESDETAIL'|@getFixedLabel}-{'Customer'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        {/if}
        </h1>

        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
           	<span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong >{'NOTE'|@getFixedLabel}：</strong><br />
                1、{'CUSTOMERSTATISTICALCONTRACTORDERS'|@getFixedLabel}<br />
                2、{'CUSTOMERSTATISTICALRECEIPTS'|@getFixedLabel}<br />
                3、{'CUSTOMERSTATISTICALINVOICE'|@getFixedLabel}<br />
                4、{'NOSTATISTICSREMOVEDRECYCLE'|@getFixedLabel}
            </div>
         </div>
     </div>
     <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module" id="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="clear"></div>
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th style="text-align:center;" width="40">#</th>
                        <th>{'AccountName'|@getFixedLabel}</th>
                        <th>{'SALESORDERTOTAL'|@getFixedLabel}</th>
                        <th>{'RECEIVABLESAMOUNT'|@getFixedLabel}</th>
                        <th>{'INVOICEVALUE'|@getFixedLabel}</th>           
                    </tr>
                    {if $result_account_cashbill|@count >0}
                    {foreach name=countRow key =key item =result from =$result_account_cashbill}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                        <tr class="Hover">
                            <td align="center">{$smarty.foreach.countRow.index+1}</td>
                            <td><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$result.accountid}">{$result.accountname}</a></td>
                            <td align="right">{$result.salesordertotal}</td>
                            <td align="right">{$result.cashbilltotal}</td>
                            <td align="right">{$result.invoicetotal}</td>
                        </tr>
                    {else}
                        <tr class="Bj Hover">
                            <td align="center">{$smarty.foreach.countRow.index+1}</td>
                            <td><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$result.accountid}">{$result.accountname}</a></td>
                            <td align="right">{$result.salesordertotal}</td>
                            <td align="right">{$result.cashbilltotal}</td>
                            <td align="right">{$result.invoicetotal}</td>
                        </tr>
                    {/if}
                    
                    {/foreach}
                    <tr class="ALLTotal">
                        <td align="center">{'TOTAL'|@getFixedLabel}</td>
                        <td></td>
                        <td align="right">{$salesorderall}</td>
                        <td align="right">{$cashbillall}</td>
                        <td align="right">{$invoiceall}</td>
                    </tr>
                    {else}
                    <tr>
                        <td colspan="5" style="background-color:#FFF;height:0px;padding: 0;" align="center">
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>

{elseif $name eq 'user_cashbill'}
    <!--人员回款明细表-->
    <div class="DivBox_top">
        <h1> 
        {if $begin_date}   
            {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
        {else}
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'PAYMENTSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        {/if}
        </h1>
        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
           	<span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong>{'NOTE'|@getFixedLabel}：</strong><br />
                1、{'BILLITSELFRESPONSIBLE'|@getFixedLabel}<br />
                2、{'STATISTICSBASERECEIPTS'|@getFixedLabel}<br />
                3、{'STATISTICSBASERECEIPTSBILL'|@getFixedLabel}<br />
            </div>
         </div>
     </div>
     <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
    <div class="clear"></div>
    <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th>{'Staff'|@getFixedLabel}</th>
                        <th>{'BILLNUMBER'|@getFixedLabel}</th>
                        <th>{'DECEIPTDATE'|@getFixedLabel}</th>
                        <th>{'RECEIVABLESAMOUNT'|@getFixedLabel}</th>
                        <th>{'AccountName'|@getFixedLabel}</th>
                    </tr>
                    {if $result_users_cashbill|@count >0}
                    {foreach key = key item = result from = $result_users_cashbill}
                    {foreach item=row from=$result.2}        
                    <tr>
                    {/foreach}
                    {foreach item=user from=$result.0}
                        <td class="BgcolorF6" align="left" valign="top" rowspan="{$result.2}">{$user}</td>
                    {/foreach}
                    {foreach name=countRow item=value from=$result.1}
                    {if $value.cashbilldate eq '小计'}                        
                        <td class="Subtotal">{$value.cashbilldate}</td>
                        <td class="Subtotal"></td>
                        <td class="Subtotal" align="right">{$value.subtotal}</td>
                        <td class="Subtotal">{$value.accountname}</td>
                    {else}
                        {if $value.rowspan!==0}
                        <td {if $value.rowspan gt 0}rowspan='{$value.rowspan}'align="left" valign="top" class=" {else}class="Hover{/if} {if ($smarty.foreach.countRow.index+1)%2 == 0} BgcolorF8 {/if}">{$value.cashbill_no}</td>                                               
                        <td {if $value.rowspan gt 0}rowspan='{$value.rowspan}'align="left" valign="top" class=" {else}class="Hover{/if} {if ($smarty.foreach.countRow.index+1)%2 == 0} BgcolorF8 {/if}">{$value.cashbilldate}</td>
                        <td {if $value.rowspan gt 0}rowspan='{$value.rowspan}'align="right" valign="top" class=" {else}class="Hover{/if} {if ($smarty.foreach.countRow.index+1)%2 == 0} BgcolorF8 {/if}" align="right">{$value.subtotal}</td>
                        <td {if $value.rowspan gt 0}rowspan='{$value.rowspan}'align="left" valign="top" class=" {else}class="Hover{/if} {if ($smarty.foreach.countRow.index+1)%2 == 0} BgcolorF8 {/if}"><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$value.accountid}">{$value.accountname}</a></td>
                        {/if}

                    </tr>
                    {/if}
                    {/foreach} 
                    {/foreach}
                    <tr class="ALLTotal">
                        <td style="background-color: #f6f6f6;"></td>
                        <td>{'TOTAL'|@getFixedLabel}</td>
                        <td ></td>
                        <td align="right">{$sumsubtotal_all}</td>

                   </tr>
                   {else}
                   <tr>
                        <td colspan="5" style="background-color:#FFF;height:0px;padding: 0;" align="center">

                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                   {/if}
                </tbody>
            </table>
            
        </div>
    </div>
<!--检测任务完成情况统计表 start-->
{elseif $name eq 'SalesOrder_Testingdetial'} 
    <div class="DivBox_top">
        <h1>  
        {if $begin_date}   
            {'DETECTIONTASKSTATISTICS'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
        {else}  
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'DETECTIONTASKSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'DETECTIONTASKSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'DETECTIONTASKSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'DETECTIONTASKSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        </h1>  
     {/if}      
     </div>
     <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="clear"></div>
    <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>                        
                        <th>{'DELEGATENUMBERS'|@getFixedLabel}</th>
                        <th>{'COMMISSIONEDUNITS'|@getFixedLabel}</th>
                        <th>{'ECPECTEDSAMPLDATE'|@getFixedLabel}</th>
                        <th>{'ECPECTEDISSUEREPORT'|@getFixedLabel}</th>
                        <th>{'TASKNUMBER'|@getFixedLabel}</th> 
                        <th>{'TASKLISTTOPICS'|@getFixedLabel}</th>
                        {foreach item=value from=$HELPDESK_ARR}
                            <th>{$value.HelpDeskStepName}</th>
                        {/foreach} 
                        {foreach item=value from=$SALESORDER_ARR}
                            <th>{$value.SalesOrderStepName}</th>
                        {/foreach}                  
                    </tr>
                    {foreach name=countRow key =key item =result from =$result_account_cashbill}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                        <tr class="Hover">
                            <td>{$value.subject}</td>    
                            <td>{$value.accountname}</td>
                            <td>{$value.cf_955}</td>
                            <td>{$value.duedate}</td>
                            <td>{$value.ticket_no}</td>
                            <td>{$value.title}</td>
                            {assign var=help_itemlist value=$value.helpdeskapp_step_arr}
                            {assign var=saleoderitemlist value=$value.arr_SalesOrderApproveStep}
                            {foreach item=value from=$help_itemlist}
                                <td>
                                    {if $value.HelpDeskStepPastStatus eq '1'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">
                                    {elseif $value.HelpDeskStepPastStatus eq '4'}    
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/disabled.gif">  
                                    {elseif $value.HelpDeskStepPastStatus eq '2'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">  
                                    {else}    
                                    {/if}
                                </td>
                            {/foreach}
                            {foreach item=value from=$saleoderitemlist}
                                <td>
                                    {if $value.SalesOrderStepPastStatus eq '1'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">
                                    {elseif $value.SalesOrderStepPastStatus eq '4'}    
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/disabled.gif">  
                                    {elseif $value.SalesOrderStepPastStatus eq '2'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">  
                                    {else}    
                                    {/if}
                                </td>
                            {/foreach}
                        </tr>
                    {else}
                        <tr class="Bj Hover">
                            <td>{$value.subject}</td>    
                            <td>{$value.accountname}</td>
                            <td>{$value.cf_955}</td>
                            <td>{$value.duedate}</td>
                            <td>{$value.ticket_no}</td>
                            <td>{$value.title}</td>
                            {assign var=help_itemlist value=$value.helpdeskapp_step_arr}
                            {assign var=saleoderitemlist value=$value.arr_SalesOrderApproveStep}
                            {foreach item=value from=$help_itemlist}
                                <td>
                                    {if $value.HelpDeskStepPastStatus eq '1'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">
                                    {elseif $value.HelpDeskStepPastStatus eq '4'}    
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/disabled.gif">  
                                    {elseif $value.HelpDeskStepPastStatus eq '2'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">  
                                    {else}    
                                    {/if}
                                </td>
                            {/foreach}
                            {foreach item=value from=$saleoderitemlist}
                                <td>
                                    {if $value.SalesOrderStepPastStatus eq '1'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">
                                    {elseif $value.SalesOrderStepPastStatus eq '4'}    
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/disabled.gif">  
                                    {elseif $value.SalesOrderStepPastStatus eq '2'}
                                        <img border="0" align="absmiddle" title="" alt="" src="themes/images/enabled.gif">  
                                    {else}    
                                    {/if}
                                </td>
                            {/foreach}
                        </tr>
                    {/if}
                    
                    {/foreach}
                </tbody>
            </table>
            
        </div>
    </div>
<!--检测任务完成情况统计表end-->
{elseif $name eq 'user_salesorder'}
<!--人员签单明细表-->
    <div class="DivBox_top">
        <h1>    
        {if $begin_date}   
            {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'LISTDETAILSSUMMARY'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
        {else}
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'LISTDETAILSSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'LISTDETAILSSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'LISTDETAILSSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'SALESDETAIL'|@getFixedLabel}-{'Staff'|@getFixedLabel}-{'LISTDETAILSSUMMARY'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        {/if}
        </h1>
        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
           	<span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong>{'NOTE'|@getFixedLabel}：</strong><br />
                1、{'GATHERINGSTATISTICS'|@getFixedLabel}<br />
                2、{'CONTRACTITSELFRESPONSIBLE'|@getFixedLabel}<br />
                3、{'ACCORDINGCONTRACTSIGNETIME'|@getFixedLabel}<br />
                4、{'NOSTATISTICALOBSOLETEORDER'|@getFixedLabel}<br />  
            </div>
         </div>
     </div>
      <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>        
                        <input type="text" readonly="readonly" id="begin_date" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>

                    <label class="Name"><span>{'Staff'|@getFixedLabel}:</span></label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="clear"></div>
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th>{'Staff'|@getFixedLabel}</th>
                        <th>{'SUBJECTMAIL'|@getFixedLabel}</th>
                        <th>{'Numbers'|@getFixedLabel}</th>
                        <th>{'AccountName'|@getFixedLabel}</th>
                        <th>{'DATEOFCONTRACT'|@getFixedLabel}</th>
                        <th>{'SALESORDERTOTAL'|@getFixedLabel}</th>
                        <th>{'CASHBILLTOTAl'|@getFixedLabel}</th>
                        <th>{'UNRECEIVEDPAYMENT'|@getFixedLabel}</th>
                        <th>{'INVOICEAMOUNT'|@getFixedLabel}</th>
                        <th>{'EXPENSE'|@getFixedLabel}</th>
                        <th>{'COMMISSION'|@getFixedLabel}{'AMOUNT'|@getFixedLabel}</th>   
                        <th>{'CASHBILLNETGROSS'|@getFixedLabel}</th>              
                    </tr>
                    {if $result_users_salesorder|@count >0}
                    {foreach key = key item = result from = $result_users_salesorder}
                    <tr>
                    
                    {foreach item=user from=$result.0}
                        <td class="BgcolorF6" align="left" valign="top" rowspan="{$result.2}">{$user}</td>
                    {/foreach}                  
                    {foreach name=countRow item=value from=$result.1}
                        {if $value.subject eq '小计'}
                        <td class="Subtotal">{$value.subject}</td>
                        <td class="Subtotal">{$value.salesorder_no}</td>
                        <td class="Subtotal">{$value.accountname}</td>
                        <td class="Subtotal">{$value.createdtime}</td>
                        <td class="Subtotal" align="right">{$value.salesordertotal}</td>
                        <td class="Subtotal" align="right">{$value.subtotal}</td>
                        <td class="Subtotal" align="right">{$value.notget}</td>
                        <td class="Subtotal" align="right">{$value.invoicetotal}</td>
                        <td class="Subtotal" align="right">{$value.expensetotal}</td>
                        <td class="Subtotal" align="right">{$value.commissiontotal}</td>      
                        <td class="Subtotal" align="right">{$value.cashbillgrosstotal}</td>                   
                        {else}
                            {if ($smarty.foreach.countRow.index+1)%2 == 0}
                                <td class="BgcolorF8 Hover">{$value.subject}</td>
                                <td class="BgcolorF8 Hover">{$value.salesorder_no}</td>
                                <td class="BgcolorF8 Hover"><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$value.accountid}">{$value.accountname}</a></td>
                                <td class="BgcolorF8 Hover">{$value.createdtime}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.salesordertotal}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.subtotal}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.notget}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.invoicetotal}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.expensetotal}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.commissiontotal}</td>  
                                <td class="BgcolorF8 Hover" align="right">{$value.cashbillgrosstotal}</td>                                        
                            {else}
                                <td class="Hover">{$value.subject}</td>
                                <td class="Hover">{$value.salesorder_no}</td>
                                <td class="Hover"><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$value.accountid}">{$value.accountname}</a></td>
                                <td class="Hover">{$value.createdtime}</td>
                                <td class="Hover" align="right">{$value.salesordertotal}</td>
                                <td class="Hover" align="right">{$value.subtotal}</td>
                                <td class="Hover" align="right">{$value.notget}</td>
                                <td class="Hover" align="right">{$value.invoicetotal}</td>
                                <td class="Hover" align="right">{$value.expensetotal}</td>
                                <td class="Hover" align="right">{$value.commissiontotal}</td>   
                                 <td class="Hover" align="right">{$value.cashbillgrosstotal}</td>                                
                            {/if}
                        {/if}
                    </tr>
                    {/foreach}
                    {/foreach}
                    <tr class="ALLTotal">
                        <td style="background-color: #f6f6f6;"></td>
                        <td>{'TOTAL'|@getFixedLabel}</td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td align="right">{$sumsalesorderall}</td>
                        <td align="right">{$sumsuball}</td>
                        <td align="right">{$sumnotgetall}</td>
                        <td align="right">{$suminvoiceall}</td>
                        <td align="right">{$sumexpenseall}</td>
                        <td align="right">{$sumcommissionall}</td>  
                        <td align="right">{$sumcashbillgrossall}</td>                         
                    </tr>
                    {else}
                    <tr>
                        <td colspan="12" style="background-color:#FFF;height:0px;padding: 0;" align="center">
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>

{elseif $name eq 'costprice_salesorder'}
<!--毛利统计表-->
<!--交付毛利汇总表-->
    <div class="DivBox_top">
        <h1> 
        {if $begin_date}   
            {'SIGNGROSSMARGIN'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
         {else}    
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'SIGNGROSSMARGIN'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'SIGNGROSSMARGIN'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'SIGNGROSSMARGIN'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'SIGNGROSSMARGIN'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        {/if}
        </h1>
        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
           	<span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong>{'NOTE'|@getFixedLabel}：</strong><br />
                1、{'CONTRACTSIGNINGDATE'|@getFixedLabel}<br />
                2、{'FILLINDATECONTRACTORDER'|@getFixedLabel}<br />
                3、{'IFNOTSETCOSTPRICE'|@getFixedLabel}<br />
                4、{'NOTSTATISTICALOBSOLETECONTRACT'|@getFixedLabel}<br />
            </div>
         </div>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>

                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
					<label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="clear"></div>
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th style="text-align:center;" width="40">#</td>
                        <th>{'PRODUCTS'|@getFixedLabel}</th>
                        <th>{'SALESVOLUME'|@getFixedLabel}</th>
                        <th>{'SALESAMOUNT'|@getFixedLabel}</th>
                        <th>{'GROSSPROFIT'|@getFixedLabel}</th>
                        <th>{'GROSSMARGIN'|@getFixedLabel}</th>            
                    </tr>
                    {if $result_costprice_salesorder|@count>0}
                    {foreach key=key name=countRow item=result from=$result_costprice_salesorder}
                        {if ($smarty.foreach.countRow.index+1)%2 == 0}
                        <tr  class="Bj Hover">
                            <td align="center">{$result.0}</td>
                            <td>{$result.productname}</td>
                            <td align="right">{$result.quantity}</td>
                            <td align="right">{$result.subtotal}</td>
                            <td align="right">{$result.grossprofit}</td>
                            {if $result.grossprofitrate eq 0}
                            <td align="right">0%</td>
                            {else}
                            <td align="right">{$result.grossprofitrate}%</td>
                            {/if}
                        </tr>
                        {else}
                        <tr  class="Hover">
                            <td align="center">{$result.0}</td>
                            <td>{$result.productname}</td>
                            <td align="right">{$result.quantity}</td>
                            <td align="right">{$result.subtotal}</td>
                            <td align="right">{$result.grossprofit}</td>
                            {if $result.grossprofitrate eq 0}
                            <td align="right">0%</td>
                            {else}
                            <td align="right">{$result.grossprofitrate}%</td>
                            {/if}
                        </tr>
                        {/if}
                        {/foreach}
                    <tr class="ALLTotal">
                        <td>{'TOTAL'|@getFixedLabel}</td>
                        <td></td>
                        <td align="right">{$quantityall}</td>
                        <td align="right">{$subtotalall}</td>
                        <td align="right">{$grossprofitall}</td>
                        <td align="right"></td>
                    </tr>
                    {else}
                    <tr>
                        <td colspan="6" style="background-color:#FFF;height:0px;padding: 0;" align="center">
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>
{elseif $name eq 'grossprofitdetial'}
<!--交付毛利明细表-->
     <div class="DivBox_top">
        <h1>  
         {if $begin_date}   
            {'SIGNGROSSMARGINDETAILED'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
         {else}  
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'SIGNGROSSMARGINDETAILED'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'SIGNGROSSMARGINDETAILED'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'SIGNGROSSMARGINDETAILED'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'SIGNGROSSMARGINDETAILED'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        {/if}            
        </h1>
        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
           	<span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong>{'NOTE'|@getFixedLabel}：</strong><br/>
                1、{'CONTRACTSIGNINGDATE'|@getFixedLabel}<br/>
                2、{'FILLINDATECONTRACTORDER'|@getFixedLabel}<br/>
                3、{'MROSSMARGINNETPRODUCT'|@getFixedLabel}{'PRODUCTCOSTSFROMCONTRACTDETEILS'|@getFixedLabel}<br/>
                4、{'NOTSTATISTICALOBSOLETECONTRACT'|@getFixedLabel}
            </div>
         </div>
    </div>
      <!--查找条件-->
    <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
 <!--查找条件 end-->
    <div class="clear"></div>
    <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th style="text-align:center;" width="40">#</th>
                        <th>{'DATEOFCONTRACT'|@getFixedLabel}</th>
                        <th>{'PRODUCTS'|@getFixedLabel}</th>
                        <th>{'SUBJECTMAIL'|@getFixedLabel}</th>
                        <th>{'Numbers'|@getFixedLabel}</th>
                        <th>{'AccountName'|@getFixedLabel}</th>
                        <th>{'QUANTITY'|@getFixedLabel}</th>
                        <th>{'NETPRICE'|@getFixedLabel}</th>
                        <th>{'GROSSPROFIT'|@getFixedLabel}</th>
                        <th>{'GROSSMARGIN'|@getFixedLabel}</th>            
                    </tr>
                    {if $arr_grossprofitdetial|@count >0}
                    {foreach key=key name=countRow item=result from=$arr_grossprofitdetial}
                    {if ($smarty.foreach.countRow.index+1)%2 == 0}
                    <tr class="Bj Hover">
                        <td align="center">{$result.0}</td>
                        <td>{$result.duedate}</td>
                        <td>{$result.productname}</td>
                        <td>{$result.subject}</td>
                        <td>{$result.salesorder_no}</td>
                        <td> <a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$result.accountid}">{$result.accountname}</a></td>
                        <td align="right">{$result.quantity}</td>
                        <td align="right">{$result.listprice}</td>
                        <td align="right">{$result.grossprofit}</td>
                        {if $result.grossprofitrate eq 0}
                        <td align="right">0%</td> 
                        {else}
                        <td align="right">{$result.grossprofitrate}%</td> 
                        {/if}            
                    </tr>
                    {else}
                    <tr class="Hover">
                        <td align="center">{$result.0}</td>
                        <td>{$result.duedate}</td>
                        <td>{$result.productname}</td>
                        <td>{$result.subject}</td>
                        <td>{$result.salesorder_no}</td>
                        <td> <a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$result.accountid}">{$result.accountname}</a></td>
                        <td align="right">{$result.quantity}</td>
                        <td align="right">{$result.listprice}</td>
                        <td align="right">{$result.grossprofit}</td>
                        {if $result.grossprofitrate eq 0}
                        <td align="right">0%</td> 
                        {else}
                        <td align="right">{$result.grossprofitrate}%</td> 
                        {/if}            
                    </tr>
                    {/if}
                    {/foreach}
                    <tr class="ALLTotal">
                        <td>{'TOTAL'|@getFixedLabel}</td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td align="right">{$quantitydetialall}</td>
                        <td align="right">{$listpricedetialall}</td>
                        <td align="right">{$grossprofitdetialall}</td>
                        <td></td>
                    </tr>
                    {else}
                    <tr>
                        <td colspan="10" style="background-color:#FFF;height:0px;padding: 0;" align="center">
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>
{elseif $name eq 'product_grossprofit'}
<!--产品毛利统计表-->
    <div class="DivBox_top">
        <h1>  
        {if $begin_date}   
            {'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
         {else}  
            {if $end_month eq 1 || $end_month eq 3 || $end_month eq 5 || $end_month eq 7 || $end_month eq 8 || $end_month eq 10 || $end_month eq 12}
                {'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-31 23:59:59
            {elseif $end_month eq 4 || $end_month eq 6 || $end_month eq 9 || $end_month eq 11}
                {'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-30 23:59:59
            {else}
                {if $monthday eq 1}
                    {'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-29 23:59:59
                {else}
                    {'PRODUCTGROSSMARGINSTATISTICS'|@getFixedLabel}: {$year}-{$begin_month}-01 00:00:00 {'TO'|@getFixedLabel} {$year}-{$end_month}-28 23:59:59
                {/if}
            {/if}
        {/if}
        </h1>
        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
           	<span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong>{'NOTE'|@getFixedLabel}：</strong><br/>
                1、{'CONTRACTSIGNINGDATE'|@getFixedLabel}<br/>
                2、{'FILLINDATECONTRACTORDER'|@getFixedLabel}<br/>
                3、{'MROSSMARGINNETPRODUCT'|@getFixedLabel}<br/>
                4、{'NOTSTATISTICALOBSOLETECONTRACT'|@getFixedLabel}<br/>
            </div>
         </div>
         </div>
        <!--查找条件-->
       <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="clear"></div>
    <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th>{'PRODUCTS'|@getFixedLabel}</th>
                        <th>{'AccountName'|@getFixedLabel}</th>
                        <th>{'Numbers'|@getFixedLabel}</th>
                        <th>{'DATEOFCONTRACT'|@getFixedLabel}</th>
                        <th>{'PRICEING'|@getFixedLabel}</th>
                        <th>{'QUANTITY'|@getFixedLabel}</th>
                        <th>{'NETPRICE'|@getFixedLabel}</th>
                        <th>{'COSTPRICE'|@getFixedLabel}</th>
                        <th>{'GROSSPROFIT'|@getFixedLabel}</th>
                        <th>{'GROSSMARGIN'|@getFixedLabel}</th>           
                    </tr>
                    {if $arr_product_grossprofit|@count > 0}
                    {foreach key=key item=result from=$arr_product_grossprofit}
                        {foreach item=row from=$result.2}        
                        <tr>
                        {/foreach}
                        {foreach name=countRow item=productname from=$result.0}
                            <td class="BgcolorF6" align="left" valign="top" rowspan="{$result.2}">{$productname}</td>
                        {/foreach}
                        {foreach name=countRow item=value from=$result.1}
                        {if $value.accountname eq '小计'}
                            <td class="Subtotal">{$value.accountname}</td>
                            <td class="Subtotal">{$value.subject}</td>
                            <td class="Subtotal">{$value.duedate}</td>
                            <td class="Subtotal" align="right">{$value.listprice}</td>
                            <td class="Subtotal" align="right">{$value.quantity}</td>
                            <td class="Subtotal" align="right">{$value.subtotal}</td>
                            <td class="Subtotal" align="right">{$value.costprice}</td>
                            <td class="Subtotal" align="right">{$value.grossprofit}</td>
                            <td class="Subtotal">{$value.grossprofitrate}</td>
                        {else}
                            {if ($smarty.foreach.countRow.index+1)%2 == 0}
                                <td class="BgcolorF8 Hover"><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$value.accountid}">{$value.accountname}</a></td>
                                <td class="BgcolorF8 Hover">{$value.subject}</td>
                                <td class="BgcolorF8 Hover">{$value.duedate}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.listprice}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.quantity}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.subtotal}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.costprice}</td>
                                <td class="BgcolorF8 Hover" align="right">{$value.grossprofit}</td>
                                {if $value.grossprofitrate eq 0}
                                <td class="BgcolorF8 Hover" align="right">0%</td>
                                {else}
                                <td class="BgcolorF8 Hover" align="right">{$value.grossprofitrate}%</td>
                                {/if}
                            {else}
                                <td class="Hover"><a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$value.accountid}">{$value.accountname}</a></td>
                                <td class="Hover">{$value.subject}</td>
                                <td class="Hover">{$value.duedate}</td>
                                <td class="Hover" align="right">{$value.listprice}</td>
                                <td class="Hover" align="right">{$value.quantity}</td>
                                <td class="Hover" align="right">{$value.subtotal}</td>
                                <td class="Hover" align="right">{$value.costprice}</td>
                                <td class="Hover" align="right">{$value.grossprofit}</td>
                                {if $value.grossprofitrate eq 0}
                                <td class="Hover" align="right">0%</td>
                                {else}
                                <td class="Hover" align="right">{$value.grossprofitrate}%</td>
                                {/if}
                            {/if}
                        {/if}
                        </tr>
                        {/foreach} 
                        {/foreach}
                    <tr class="ALLTotal">
                        <td style="background-color: #f6f6f6;"></td>
                        <td>{'TOTAL'|@getFixedLabel}</td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td align="right">{$sumquantity_all}</td>
                        <td align="right">{$sumsubtotal_all}</td>
                        <td></td>
                        <td align="right">{$sumgrossprofit_all}</td>
                        <td></td>
                    </tr>
                    {else}
                    <tr>
                        <td colspan="10" style="background-color:#FFF;height:0px;padding: 0;" align="center">
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>
{else}
<!--客户毛利统计表-->
    <div class="DivBox_top">
        <h1>  
        {if $begin_date}   
            {'CUSTOMERGROSSMARGINSTATISTICS'|@getFixedLabel}: {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 
        {else}  
            
        {/if}
        </h1>
        <div class="What" id="a5">
            <a class="icon-mediumimg icon-what" id="img1" href="javascript:;" onclick="display_table(event);"></a>
            <span class="icon-mediumimg icon-whatp cursorPointer imgpoti" id="a1"></span>
            <div id="a2" onmouseout="display_table(event);">
                <strong>{'NOTE'|@getFixedLabel}：</strong><br/>
                1、{'CONTRACTSIGNINGDATE'|@getFixedLabel}<br/>
                2、{'FILLINDATECONTRACTORDER'|@getFixedLabel}<br/>
                3、{'MROSSMARGINNETPRODUCT'|@getFixedLabel}<br/>
                4、{'NOTSTATISTICALOBSOLETECONTRACT'|@getFixedLabel}
            </div>
         </div>
         </div>
        <!--查找条件-->
         <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="{$curmodule}" name="module">
                    <input type="hidden" value="ComprehensivereportDetail" name="action">
                    <input type="hidden" value="{$name}" name="name">
                    <input type="hidden" value="{$formodule}" name="formodule">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                    </label>
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="clear"></div>
    <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th>{'AccountName'|@getFixedLabel}</th>
                        <th>{'PRODUCTS'|@getFixedLabel}</th>
                        <th>{'SUBJECTMAIL'|@getFixedLabel}</th>
                        <th>{'Numbers'|@getFixedLabel}</th>
                        <th>{'DATEOFCONTRACT'|@getFixedLabel}</th>
                        <th>{'PRICEING'|@getFixedLabel}</th>
                        <th>{'QUANTITY'|@getFixedLabel}</th>
                        <th>{'NETPRICE'|@getFixedLabel}</th>
                        <th>{'GROSSPROFIT'|@getFixedLabel}</th>
                        <th>{'GROSSMARGIN'|@getFixedLabel}</th>           
                    </tr>
                    {if $arr_account_grossprofit|@count >0}
                    {foreach key=key item=result from=$arr_account_grossprofit}
                    {foreach item=row from=$result.2}        
                    <tr>
                    {/foreach}
                    {foreach key=key  item=accountname from=$result.0}
                        <td class="BgcolorF6" align="left" valign="top" rowspan="{$result.2}">
                        <a target="_blank" href="index.php?pageto_module=Accounts&pageto_action=index&pageto_record={$key}">{$accountname}</a>
                        </td>
                    {/foreach}
                    {foreach name=countRow item=value from=$result.1}
                    {if $value.productname eq '小计'}
                        <td class="Subtotal">{$value.productname}</td>
                        <td class="Subtotal">{$value.subject}</td>
                        <td class="Subtotal">{$value.salesorder_no}</td>
                        <td class="Subtotal">{$value.duedate}</td>
                        <td class="Subtotal" align="right">{$value.listprice}</td>
                        <td class="Subtotal" align="right">{$value.quantity}</td>
                        <td class="Subtotal" align="right">{$value.subtotal}</td>
                        <td class="Subtotal" align="right">{$value.grossprofit}</td>
                        <td class="Subtotal">{$value.grossprofitrate}</td>
                    </tr>
                    {else}
                        {if ($smarty.foreach.countRow.index+1)%2 == 0}
                            <td class="BgcolorF8 Hover">{$value.productname}</td>
                            <td class="BgcolorF8 Hover">{$value.subject}</td>
                            <td class="BgcolorF8 Hover">{$value.salesorder_no}</td>
                            <td class="BgcolorF8 Hover">{$value.duedate}</td>
                            <td class="BgcolorF8 Hover" align="right">{$value.listprice}</td>
                            <td class="BgcolorF8 Hover" align="right">{$value.quantity}</td>
                            <td class="BgcolorF8 Hover" align="right">{$value.subtotal}</td>
                            <td class="BgcolorF8 Hover" align="right">{$value.grossprofit}</td>
                            {if $value.grossprofitrate eq 0}
                            <td class="BgcolorF8 Hover" align="right">0%</td>
                            {else}
                            <td class="BgcolorF8 Hover" align="right">{$value.grossprofitrate}%</td>
                            {/if}
                        {else}
                            <td class="Hover">{$value.productname}</td>
                            <td class="Hover">{$value.subject}</td>
                            <td class="Hover">{$value.salesorder_no}</td>
                            <td class="Hover">{$value.duedate}</td>
                            <td class="Hover" align="right">{$value.listprice}</td>
                            <td class="Hover" align="right">{$value.quantity}</td>
                            <td class="Hover" align="right">{$value.subtotal}</td>
                            <td class="Hover" align="right">{$value.grossprofit}</td>
                            {if $value.grossprofitrate eq 0}
                            <td class="Hover" align="right">0%</td>
                            {else}
                            <td class="Hover" align="right">{$value.grossprofitrate}%</td>
                            {/if}
                        {/if}
                    </tr>
                    {/if}
                    {/foreach} 
                    {/foreach}
                    <tr class="ALLTotal">
                        <td style="background-color: #f6f6f6;"></td>
                        <td>{'TOTAL'|@getFixedLabel}</td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td></td>
                        <td align="right">{$sumquantity_account_all}</td>
                        <td align="right">{$sumsubtotal_account_all}</td>
                        <td align="right">{$sumgrossprofit_account_all}</td>
                        <td></td>
                    </tr>
                    {else}
                    <tr>
                        <td colspan="10" style="background-color:#FFF;height:0px;padding: 0;" align="center">
                            {include file="NoRecords.tpl"}
                        </td>
                    </tr>
                    {/if}
                </tbody>
            </table>
            
        </div>
    </div>
{/if}
<script type="text/javascript">
var wx_timestamp='{$timestamp}';
var wx_corpid='{$wx_corpid}';//'wxa246741d62d718f0';
var wx_agentid='{$wx_agentid}';//'1000345';
var wx_nonceStr='{$nonceStr}';
var wx_agent_signature='{$agentsignature}';
var wx_signature='{$signature}';
var iskehu001='{$iskehu001}';
if(iskehu001=='yes')
{
    var cls_wxOpenDataobj;
    cls_wxOpenDataobj=new cls_wxOpenData();
           
    cls_wxOpenDataobj.init();
}

{literal}
   ld(document).ready(function() {
  
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
      });
   });
{/literal}

var popupobj=new CrmPopup();
CrmPopup.global_listPopupObj.push(popupobj);
</script>
</div>
</body>
</html>