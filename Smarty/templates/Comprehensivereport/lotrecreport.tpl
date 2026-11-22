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
<title>{'lotrectotalreceivablesalesreport'|@getFixedLabel}</title>
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
.Find_Form0 .Select2 { float:left; width:80px; height:22px; line-height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:0px;}
.DivBox_Center { width:100%; padding:5px 0px;clear:both;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}


</style>
{/literal}

<body>
    <div id="status" style="position:absolute;display:none;left:850px;top:95px;height:27px;white-space:nowrap;"></div>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$YEAR}{if $YEAR neq ''}{'YEAR'|@getFixedLabel}{/if}{'lotrectotalreceivablesalesreport'|@getFixedLabel}</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                        <input type="hidden" value="lotrecreport" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <!--input type="hidden" value="" name="ajaxExport" id="ajaxExport"/-->   
                    <select id="searchtype" class="Select2" name="searchtype">  
                        <option value ="1" {if $searchtype eq 1} selected="selected" {/if}>{'SigningDate'|@getFixedLabel}</option>  
                        <option value ="2" {if $searchtype eq 2} selected="selected" {/if}>{'DeliveryDate'|@getFixedLabel}</option>  
                    </select>   
               	    <label class="Name"><span>{'TIMEPERIOD'|@getFixedLabel}:</span>
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
                   	<label class="Name" style="clear:both;padding-left:49px;">
                        <span>{'AccountName'|@getFixedLabel}:</span>
                         <input id="AccountName" class="date" name="AccountName" value="{$AccountNamevalue}"/>
                    </label>  
 
                   	<label class="Name">
                        <span>{'OrderNO'|@getFixedLabel}:</span>
                         <input id="ORDERNO" class="date" name="ORDERNO" value="{$ORDERNOvalue}"/>
                    </label>  
                   	<label class="Name">
                        <span>{'Packing'|@getFixedLabel}:</span>
                         <input id="Packing" class="date" name="Packing" value="{$Packingvalue}"/>
                    </label>  
                   	<label class="Name" style="clear:both;padding-left:49px;">
                        <span>{'ProductCategories1'|@getFixedLabel}:</span>
                        <select id="productcategoryvalue" class="Select" name="productcategoryvalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$productcategory}
                             <option value ="{$userid}" {if $productcategoryvalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>                  
                   	<label class="Name" style="padding-left:24px;">
                        <span>{'Newandoldcustomers'|@getFixedLabel}:</span>
                        <select id="cf_1602" class="Select" name="cf_1602">  
                        <option value=''>-</option>
                            {foreach item=userids from=$cf_1602}
                             <option value ="{$userids}" {if $cf_1602value eq $userids} selected="selected" {/if}>{$userids}</option>  
                            {/foreach}  
                    </select> 
                    </label>
                   	<label class="Name">
                        <span>{'COMPANYPROVINCE'|@getFixedLabel}:</span>
                        <select id="picklistDependencyDatasource" class="Select" name="picklistDependencyDatasource">  
                        <option value=''>-</option>
                            {foreach item=userid from=$billstate}
                             <option value ="{$userid}" {if $picklistDependencyDatasourcevalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>   
                    {*
                    <label class="Name"><span>{'CLOSING'|@getFixedLabel}:</span>
                        <input id="end_date" class="Wdate" name="end_date" value="{$end_date}" onClick="WdatePicker()"/>
                        <input id="bd_end_date" type="hidden" name="bd_end_date"/>
                        <!--<img id="bd_jscal_trigger_date_end" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />
                        <script id="massedit_calendar_date_end" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "end_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "bd_jscal_trigger_date_end", singleClick : true, step : 1
                           	{rdelim})
                        </script>-->
                    </label>
                    *}
                    <label class="Name">{'Staff'|@getFixedLabel}:</label>
                    <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
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
                        <th >{'OrderNO'|@getFixedLabel}</th>
                        <th >{'SigningDate'|@getFixedLabel}</th>
                        <th >{'DeliveryDate'|@getFixedLabel}</th>
                        <th >{'COMPANYPROVINCE'|@getFixedLabel}</th>
                        <th >{'COMPANYCITY'|@getFixedLabel}</th>
                        <th >{'AccountName'|@getFixedLabel}</th>
                        <th >{'Lotnumber'|@getFixedLabel}</th>
                        <th >{'AssignedTo2'|@getFixedLabel}</th>
                        <th >{'Servicepersonnel'|@getFixedLabel}</th>
                        <th >{'Newandoldcustomers'|@getFixedLabel}</th>
                        <th >{'Todatemodels'|@getFixedLabel}</th>
                        <th >{'ProductCategories1'|@getFixedLabel}</th>
                        <th >{'Brand'|@getFixedLabel}</th>
                        <th >{'Trademark'|@getFixedLabel}</th>
                        <th >{'Packing'|@getFixedLabel}</th>
                        <th >{'QTY'|@getFixedLabel}</th>
                        <th >{'PRODUCTLIST_TAXPRICE'|@getFixedLabel}</th>
                        <th >{'PRODUCTLIST_AMOUNT'|@getFixedLabel}</th>
                        <th >{'TOTAL'|@getFixedLabel}</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$arr.salesorder_no}</td>
                    <td>{$arr.signed_data}</td>
                    <td>{$arr.duedate}</td>
                    <td>{$arr.bill_state}</td>
                    <td>{$arr.bill_city}</td>
                    <td>{$arr.accountname}</td>
                    <td>{$arr.cf_1494}</td>
                    <td>{$arr.last_name}</td>
                    <td>{$arr.HDlast_name}</td>
                    <td>{$arr.cf_1602}</td>
                    <td>{$arr.cf_1495}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.cf_1464}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.sf4}</td>
                    <td align="right">{$arr.quantity}</td>
                    <td align="right">{$arr.taxprice}</td>
                    <td align="right">{$arr.buhansuijine}</td>
                    <td align="right">{$arr.total}</td>                
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