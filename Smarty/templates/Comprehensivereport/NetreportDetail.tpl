<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>

<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/Reminds/Reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<script type="text/javascript">
	var ld = $;
	ld.noConflict();
</script>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售统计表——按网点</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:20px;}
.DivBox_top { width:100%; height:45px;}
.DivBox_top h1 { float:left; font-size:20px; color:#666; line-height:30px;}
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:8px;}
.Find_box table { background:#ccc;}
.Find_box table td { background:#fff;}
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%; background:url(themes/softed/images/layerPopupBg.gif) repeat left 0px;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 input.Input_time { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 input.Bjffd { background:#ffd;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 input.Input_Text { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 .Select { float:left; width:150px; height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px; line-height:20px;}
.Find_Form0 input.Checkbox { float:left; margin:4px 0px 0px 10px; *margin-top:0px;}
.Find_Form0 .Div0 { float:left;position:relative; z-index:1;}
.Find_Form0 .Div0:hover .Input_Text { background:#ffd;}
.Find_Form0 ul.Change { display:none; float:left; position:absolute; width:200px; left:0px; top:21px; z-index:2; border:1px #ddd solid; background:#fff; padding:10px;}
.Find_Form0 ul.Change li { float:left; width:50%; padding:2px 0px; border-bottom:1px #ddd solid;}
.Find_Form0 ul.Change li input { float:left; margin-top:3px; *margin-top:0px;}
.Find_Form0 ul.Change li label { float:left; font-size:12px; color:#666; line-height:20px; padding-left:5px;}
.Find_Form0 .Div0:hover ul.Change { display:block;}
.Find_Form0 input.Button_find { margin-left:10px;}
/*---查找 end----*/
/*---蓝色保存-小按钮---*/
.Button_find { float:left; color:#fff;font-weight:bold; overflow:hidden; line-height:21px;border:none;padding: 0 15px; border-radius:3px; cursor:pointer; font-size:12px; background-image: url(themes/softed/images/toolbar-bg.png);}

.DivBox_Center { width:100%;padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}
.DivBox_Center .DivList0 table { background:#ccc;}
.DivBox_Center .DivList0 table th,.DivBox_Center .DivList0 table td {font-size:13px; color:#666; line-height:24px; padding:3px 10px;}
.DivBox_Center .DivList0 table th { background:#C7D9EE url(themes/softed/images/thbj.png) repeat-x left 0px; color:#2A66C5; padding:5px 10px;/* font-weight:lighter;*/}
.DivBox_Center .DivList0 table tr.Bj td { background:#EEF7FF;}
.DivBox_Center .DivList0 table tr.ZBj td { background:#FFFFC1;}
.DivBox_Center .DivList0 table tr td.Blackbj { background:#f6f6f6; vertical-align:top; font-weight:bold;}
.DivBox_Center .DivList0 table tr.Hover:hover td { background:#FFFFE8;}
.DivBox_Center .DivList0 table tr.Hover:hover td.Blackbj { background:#f6f6f6;}
.listTabBj{background-color:#EEF7FF;}
.listTabBjNo{ background-color:#fff;}
.listTableRowRight{/*text-align:right;*/}
</style>
{/literal}
{literal}
<style>

* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:5px;}
.DivBox_top { width:100%; height:35px;}
.DivBox_top h1 { float:left; font-size:20px; color:#000; line-height:30px;}
.DivBox_top .What { float:left; padding:0px 10px 0px 0px; position:relative; z-index:2;}
.DivBox_top .What img { float:left; cursor:pointer;}
.DivBox_top .What{float:right;}
.DivBox_top .What img.Icon_tcImg { display:none; position:absolute; position:absolute; right:35px; top:28px; z-index:4;}
.DivBox_top .What div { display:none; float:left; width:500px; position:absolute; right:44px; top:42px; overflow:hidden; background:#FBF9E6; border:1px #DDDDDD solid; padding:15px; font-size:12px; color:#666; line-height:24px; border-radius:5px; z-index:3;}
.DivBox_top .What div td { vertical-align:top;}
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:0px;}
/*.Find_box table { background:#ccc;}*/
.Find_box table td { background:#fff;}
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:130px;float:left;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 label.Name span{margin-right:5px;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 .Select { float:left; width:150px; height:22px; line-height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px;}

.DivBox_Center { width:100%; padding:5px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; }
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        {if $MONTH != 0}
            <h1>{if $Report_form_query neq 'true'}{$YEAR}{'nYear'|@getFixedLabel}{$MONTH}{'nMonth'|@getFixedLabel}{/if}{'SALESREPORTLIST'|@getFixedLabel}--{'BYNETWORK'|@getFixedLabel}</h1>
        {else}
            <h1>{if $Report_form_query neq 'true'}{$YEAR}{'nYear'|@getFixedLabel}{/if}{'SALESREPORTLIST'|@getFixedLabel}--{'BYNETWORK'|@getFixedLabel}: </h1>
        {/if}
        
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module">
                    <input type="hidden" value="latticepointdetial" name="action">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                                
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
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
                            <span>{'Customer'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="Account_search_text" id="Account_search_text" value="{$searchAccount}" style="width:230px"/>
                    </label>
                    <label class="Name">
                            <span>{'RANGESTAFF'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text4" id="search_text4" value="{$search_text4}" style="width:230px" onclick="CfnDropDownUserslongwei(this,'div_select_Salesman',0);BodyClick2(this,'div_select_Salesman');" readonly/>
                            <input type="hidden" id="receiverid" name="receiverid" value="{$receiverid}"/>
                            <span id="assign_user_id4">
                                <div id="div_select_Salesman" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num2 value=2}
                                        
                							{foreach key=username item=userid from=$ARRUSER}
                                            {assign var=cheack value=''}
                                               {if $Salesman_num eq 0}
                                               <tr>
                                               {elseif $Salesman_num%$Salesman_num2 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        {foreach key=key item=receiverids from=$receiverid_array }
                                                        {if $receiverids eq $userid}
                                                        {assign var=cheack value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_Salesman" {$cheack} onclick="ngetSelected('receiverid','cb_select_Salesman')"/>
                                                        {assign var=cheack value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_Salesman_{$Salesman_num}">{$username}</span>
                                                        <input id="search_text4_{$Salesman_num++}" type="hidden" value="{$userid}"/>
                                                        </td>
                                                        </tr>
                                                    </tbody>
                                                    </table>                                  
                                               </td>                         
                							{/foreach}
                                             </tr>
                                    </table>
                                </div>
                            </span>
                    </label>                    
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th >{$ARRACCOUNTLABEL.account_no}</th>
                        <th >{$ARRACCOUNTLABEL.siccode}</th>
                        <th >{$ARRACCOUNTLABEL.accountname}</th>
                        <th >{$ARRACCOUNTLABEL.accounttype}</th>
                        <th >{$ARRACCOUNTLABEL.bill_state}</th>
                        <th >{$ARRACCOUNTLABEL.bill_city}</th>
                        <th >{'openingbalance'|getFixedLabel}</th>
                        {if $TYPE_DATA neq 0}
                        {if $Report_form_query eq 'true' }
                        <th >{'Thisduringdeliveryamount'|getFixedLabel}</th>
                        <th >{'deliverytimetherefundamount'|getFixedLabel}</th>
                        <th >{'deliverytimetheamountofreceivables'|getFixedLabel}</th>
                        {else}
                        <th >{'Thismonthdeliveryamount'|getFixedLabel}</th>
                        <th >{'Thismonththerefundamount'|getFixedLabel}</th>
                        <th >{'Thismonththeamountofreceivables'|getFixedLabel}</th>
                        {/if}
                        {/if}
                        <th >{'Cumulativesalesthisyear'|getFixedLabel}</th>
                        <th >{'Cumulativesalesthisyear2'|getFixedLabel}</th>
                        <th >{'Thisyearaccumulativetotalrefundamount'|getFixedLabel}</th>
                        <th >{'Thereturnrate'|getFixedLabel}</th>
                        <th >{'Theyearsofaccumulatedfundswithdrawalfromcirculation'|getFixedLabel}</th>   
                        <th >{'Returnratio'|getFixedLabel}</th>
                        <th >{'Accountsreceivablebalance'|getFixedLabel}</th>     
                    </tr>
                    {foreach name=countRow from=$Netreport_list key=key item=arr}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                    <tr align="right" bgcolor="white" class="listTabBj">
                    {else}
                    <tr align="right" bgcolor="white" class="listTabBjNo">
                    {/if}
                       <td>{$arr.account_no}</td>
                       <td>{$arr.siccode}</td>
                       <td>{$arr.accountname}</td>
                       <td>{$arr.account_type}</td>
                       <td>{$arr.bill_state}</td>
                       <td>{$arr.bill_city}</td>
                       <td>{$arr.cashbillsubtotal_Balance_oldmonth}</td>
                       {if $TYPE_DATA neq 0}
                       <td>{$arr.outOutboundOrder_num_month}</td>
                       <td>{$arr.cashback_month_total}</td>
                       <td>{$arr.cashbill_month_subtotal}</td>
                       {/if}
                       <td>{$arr.salesorder_total}</td>
                       <td>{$arr.outOutboundOrder_num}</td>
                       <td>{$arr.cashback_total}</td>
                       <td>{$arr.cashback_percent}%</td>
                       <td>{$arr.cashbillsubtotal}</td>
                       <td>{$arr.cashbillsubtotal_percent}%</td>
                       <td>{$arr.cashbillsubtotal_Balance}</td>
                    </tr>
                    
                    {/foreach}
                    <tr align="right" class="listTabBj">
                       <td>{'TOTAL'|getFixedLabel}</td>
                       <td></td>
                       <td></td>
                       <td></td>
                       <td></td>
                       <td></td>
                       
                       <td>{$ALL.cashbillsubtotal_Balance_oldmonth|@getDecimalTwoVal}</td>
                       {if $TYPE_DATA neq 0}
                       <td>{$ALL.outOutboundOrder_num_month|@getDecimalTwoVal}</td>
                       <td>{$ALL.cashback_month_total|@getDecimalTwoVal}</td>
                       <td>{$ALL.cashbill_month_subtotal|@getDecimalTwoVal}</td>
                       {/if}
                       <td>{$ALL.salesorder_total|@getDecimalTwoVal}</td>
                       <td>{$ALL.outOutboundOrder_num}</td>
                       <td>{$ALL.cashback_total|@getDecimalTwoVal}</td>
                       <td></td>
                       <td>{$ALL.cashbillsubtotal|@getDecimalTwoVal}</td>
                       <td></td>
                       <td>{$ALL.cashbillsubtotal_Balance|@getDecimalTwoVal}</td>
                    </tr>
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