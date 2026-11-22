<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/reminds/reminds.js"></script>
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
<title>励登报表</title>
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
.DivBox_Center { width:120%; padding:5px 0px;clear:both;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}


</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$YEAR}{if $YEAR neq ''}{'YEAR'|@getFixedLabel}{/if}励登报表</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                        <input type="hidden" value="lidengreports" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    
                    <input type="hidden" value="true" name="Report_form_query"/>   
               	    <label class="Name"><span>合同日期:</span>
                                
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
                        <span>月:</span>
                        <input id="invoicedate" class="date" name="invoicedate" value="{$invoicedatevalue}"/>
                    </label>          
                   	<label class="Name" style="padding-left:24px;">
                        <span>销售员:</span>
                        <select id="useridc" class="Select" name="useridc">  
                        <option value=''>-</option>
                            {foreach item=userids key=key2 from=$users}
                             <option value ="{$key2}" {if $useridc eq $key2} selected="selected" {/if}>{$userids}</option>  
                            {/foreach}  
                    </select> 
                    </label>
                   	<label class="Name">
                        <span>地区:</span>
                        <input id="cf_1450" class="date" name="cf_1450" value="{$cf_1450value}"/>
                    </label>  
                     

                    
                   	<label class="Name" style="clear:both;padding-left:49px;">
                        <span>品牌:</span>
                        <select id="cf_1447value" class="Select" name="cf_1447value">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1447}
                             <option value ="{$userid}" {if $cf_1447value eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>                  
                   	<label class="Name">
                        <span>客户:</span>
                        <input id="accountname" class="date" name="accountname" value="{$accountnamevalue}"/>
                    </label> 
                   	<label class="Name">
                        <span>种类:</span>
                        <select id="productcategoryvalue" class="Select" name="productcategoryvalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$productcategory}
                             <option value ="{$userid}" {if $productcategoryvalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                    
                   	<label class="Name">
                        <span>产品:</span>
                        <input id="productname" class="date" name="productname" value="{$productnamevalue}"/>
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
                        <th >月</th>
                        <th >合同日期</th>
                        <th >销售员</th>
                        <th >地区</th>
                        <th >客户</th>
                        <th >Customer</th>
                        <th >品牌</th>
                        <th >种类</th>
                        <th >产品</th>
                        <th >规格</th>
                        <th >总数量</th>
                        <th >单价（含税）</th>
                        <th >总价（含税）</th>
                        <th >总价（不含税）</th>
                        <th >供货商</th>
                        <th >进价（含税）</th>
                        <th >总进价（含税）</th>
                        <th >发货</th>
                        <th >收款日期</th>
                        <th >已收款金额</th>
                        <th >未收款金额</th>
                        <th >毛利</th>
                        <th >GM %</th>
                        <th >联系人</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$arr.invoicedate}</td>
                    <td>{$arr.signed_data}</td>
                    <td>{$arr.last_name}</td>
                    <td>{$arr.cf_1450}</td>
                    <td>{$arr.accountname}</td>
                    <td>{$arr.cf_1448}</td>
                    <td>{$arr.cf_1447}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.productsheet}</td>
                    <td align="right">{$arr.quantity}</td>
                    <td align="right">{$arr.taxprice}</td>
                    <td align="right">{$arr.taxpricetotal}</td>
                    <td align="right">{$arr.notaxpricetotal}</td>
                    <td>{$arr.vendorname}</td>
                    <td align="right">{$arr.taxpricejingjia}</td>
                    <td align="right">{$arr.amountjinghuo}</td>
                    <td>{$arr.createdate}</td>
                    <td>{$arr.cashbilldate}</td>
                    <td align="right">{$arr.cashbillamount}</td>
                    <td align="right">{$arr.weishouamount}</td>                
                    <td align="right">{$arr.maoli}</td>
                    <td align="right">{$arr.GM}</td>                   
                    <td>{$arr.lastname}</td>                
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