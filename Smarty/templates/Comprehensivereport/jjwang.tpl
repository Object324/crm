<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css">
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/reminds/reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<script type="text/javascript">
	var ld = $;
	ld.noConflict();
</script>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>{'cheer100'|@getFixedLabel}</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:5px;}
.DivBox_top { width:100%; height:35px;}
.DivBox_top h1 { float:left; font-size:20px; color:#000; line-height:30px;}
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:0px;}
/*.Find_box table { background:#ccc;}*/
.Find_box table td { background:#fff;}
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:142px;float:left;padding-left:5px;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 label.Name span{margin-right:5px;}
.Find_Form0 .Select { float:left; width:150px; height:22px; line-height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:0px;}
.DivBox_Center { width:100%; padding:5px 0px;clear:both;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}


</style>
{/literal}

<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$YEAR}{if $YEAR neq ''}{'YEAR'|@getFixedLabel}{/if}{'cheer100'|@getFixedLabel}</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                        <input type="hidden" value="jjwangreports" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <!--input type="hidden" value="" name="ajaxExport" id="ajaxExport"/-->     
               	    <label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                                
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                        <!--<img id="b_jscal_trigger_date_start" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />                                                       
                        <script id="massedit_calendar_date_begin" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "begin_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "b_jscal_trigger_date_start", singleClick : true, step : 1
                           	{rdelim})
                        </script>
                        -->                        
                    </label>          
                   	<label class="Name">
                        <span>{'Factoryprojectstatus'|@getFixedLabel}:</span>
                        <select id="Factoryprojectstatus" class="Select" name="Factoryprojectstatus">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1764}
                             <option value ="{$userid}" {if $Factoryprojectstatus eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                   	<label class="Name">
                        <span>{'sales_stage'|@getFixedLabel}:</span>
                        <select id="sales_stagevalue" class="Select" name="sales_stagevalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$sales_stage}
                             <option value ="{$userid}" {if $sales_stagevalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                   	<label class="Name">
                        <span>{'Orderstatus2'|@getFixedLabel}:</span>
                        <select id="postatusvalue" class="Select" name="postatusvalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$postatus}
                             <option value ="{$userid}" {if $postatusvalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                   	<label class="Name" style="clear:both;padding-left:49px;">
                        <span>{'TheSalesDepartment'|@getFixedLabel}:</span>
                        <select id="cf_1699value" class="Select" name="cf_1699value">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1699}
                             <option value ="{$userid}" {if $cf_1699value eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>                  
                   	<label class="Name" style="padding-left:24px;">
                        <span>{'Salespersonnel'|@getFixedLabel}:</span>
                        <select id="useridc" class="Select" name="useridc">  
                        <option value=''>-</option>
                            {foreach item=userids key=key2 from=$users}
                             <option value ="{$key2}" {if $useridc eq $key2} selected="selected" {/if}>{$userids}</option>  
                            {/foreach}  
                    </select> 
                    </label>
                        
                   	<label class="Name">
                        <span>{'Technicalpersonnel'|@getFixedLabel}:</span>
                         <input id="cf_1513" class="date" name="cf_1513" value="{$cf_1513value}"/>
                    </label>
                   	<label class="Name">
                        <span>{'Projectsupervision'|@getFixedLabel}:</span>
                        <input id="cf_1603" class="date" name="cf_1603" value="{$cf_1603value}"/>
                    </label>    
                   	<label class="Name" style="clear:both;padding-left:49px;">
                        <span>{'Constructionteam'|@getFixedLabel}:</span>
                        <input id="cf_1604" class="date" name="cf_1604" value="{$cf_1604value}"/>
                    </label>     
                   	<label class="Name"style="padding-left:24px;">
                        <span>{'Projectaddress'|@getFixedLabel}:</span>
                        <input id="Projectaddress" class="date" name="Projectaddress" value="{$Projectaddressvalue}"/>
                    </label>   
                   	<label class="Name">
                        <span>{'Typehousing'|@getFixedLabel}:</span>
                        <select id="cf_1408value" class="Select" name="cf_1408value">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1408}
                             <option value ="{$userid}" {if $cf_1408value eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>   
                   	<label class="Name">
                        <span>{'Thedevicename'|@getFixedLabel}:</span>
                        <input id="product" class="date" name="product" value="{$product}"/>
                    </label>   
                   	<label class="Name" style="clear:both;padding-left:49px;">
                        <span>{'Constructionstate'|@getFixedLabel}:</span>
                        <select id="projectstatusvalue" class="Select" name="projectstatusvalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$projectstatus}
                             <option value ="{$userid}" {if $projectstatusvalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>       

                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>                           
                </form>
                 
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="140%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th >{'STATUS'|@getFixedLabel}</th>
                        <th >{'SEQUENCE'|@getFixedLabel}</th>
                        <th >立项号</th>
                        <th >合同号</th>
                        <th >{'Thecompanyprojectsdate'|@getFixedLabel}</th>
                        <th >{'Sourceofinformation'|@getFixedLabel}</th>
                        <th >{'TheSalesDepartment'|@getFixedLabel}</th>
                        <th >{'Salespersonnel'|@getFixedLabel}</th>
                        <th >{'Technicalpersonnel'|@getFixedLabel}</th>
                        <th >{'Projectsupervision'|@getFixedLabel}</th>
                        <th >施工人员</th>
                        <th >{'AccountName'|@getFixedLabel}</th>
                        <th >{'COMPANYPHONE'|@getFixedLabel}</th>
                        <th >{'Projectaddress'|@getFixedLabel}</th>
                        <th >房型</th>
                        <th >{'Theprojectbrand'|@getFixedLabel}</th>
                        <th >{'Thedevicename'|@getFixedLabel}</th>
                        <th >{'Specifications'|@getFixedLabel}</th>
                        <th >{'QUANTITY'|@getFixedLabel}</th>
                        <th >合同日期</th>
                        <th >{'Thetotalamountcontract'|@getFixedLabel}</th>
                        <th >{'billamount'|@getFixedLabel}</th><th >变更金额</th>
                        <th >佣金</th>
                        <!--th >{'Orderchange'|@getFixedLabel}</th-->
                        <th >{'CASHBILLTOTAl'|@getFixedLabel}</th>
                        <th >{'UNRECEIVEDPAYMENT'|@getFixedLabel}</th>
                        <!--th >{'Receivables'|@getFixedLabel}</th-->
                        <th >{'INVOICEAMOUNT'|@getFixedLabel}</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$arr.projectstatus}</td>
                    <td>{$smarty.foreach.countRow.index+1}</td>
                    <td><a href="index.php?module=Comprehensivereport&action=accountjjwangreports&ReportHeader=DHeader&accountid={$arr.accountid}&salesorderid={$arr.salesorderid}"  target="_black">{$arr.account_no}</a></td>
                    <td>{$arr.salesorder_no}</td>
                    <td>{$arr.createdtime}</td>
                    <td>{$arr.cf_1713}</td>
                    <td>{$arr.cf_1782}</td>
                    <td>{$arr.last_name}</td>
                    <td>{$arr.cf_1607}</td>
                    <td>{$arr.cf_1603}</td>
                    <td>{$arr.cf_1604}</td>
                    <td>{$arr.lastname}</td>
                    <td>{$arr.phone}</td>
                    <td>{$arr.accountname}</td>
                    <td>{$arr.cf_1408}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.productsheet}</td>
                    <td>{$arr.quantity}</td>
                    <td>{$arr.signed_data}</td>
                    <td align="right">{$arr.total}</td>
                    <td align="right">{$arr.cf_1535}</td><td align="right">{$arr.backtotal}</td>
                    <td align="right">{$arr.cf_1536}</td>
                    <!--td  align="right"></td-->                    
                    <td align="right">{$arr.yishou}</td>
                    <td align="right">{$arr.weishou}</td>                   
                    <td align="right">{$arr.kaipiao}</td>                
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>
    </div>
    

</div>

<script type="text/javascript">
{literal}
   ld(document).ready(function() {
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
      });
   });
{/literal}
</script>
</body>
</html>