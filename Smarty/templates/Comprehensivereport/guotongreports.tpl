<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css">
<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/reminds/reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<script type="text/javascript">
	jQuery.noConflict();	
</script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>{if $chengben neq 'chengben'}{'GUOTONGREPORT'|@getFixedLabel}{else}{'CostStatistics'|@getFixedLabel}{/if}</title>
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
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:2px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px; line-height:22px;width:130px;float:left;}
.Find_Form0 .Name select {border:1px solid #ddd;height:22px; line-height:22px;width:60px;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}

.Find_Form0 .Select { float:left; width:150px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px; line-height:20px;}

.Find_Form0 input.Button_find { margin-left:10px;}
/*---查找 end----*/
/*---蓝色保存-小按钮---*/
.Button_find { float:left; color:#fff;font-weight:bold; overflow:hidden; line-height:21px;border:none;padding: 0 15px; border-radius:3px; cursor:pointer; font-size:12px; background-image: url(themes/softed/images/toolbar-bg.png);}

/*---绿色保存-大按钮---*/
.DivBox_Center { width:100%; overflow:hidden; padding:10px 0px;}
.DivList0 { float:left; width:100%; padding-bottom:15px; overflow:hidden;}
.DivList0 table { background:#ccc;}
.DivList0 table th,.DivBox_Center .DivList0 table td { background:#fff; font-size:13px; color:#666; line-height:24px; padding:3px 10px;}
.DivList0 table th { background:#C7D9EE url(themes/softed/images/thbj.png) repeat-x left 0px; color:#2A66C5; padding:5px 10px;/* font-weight:lighter;*/}
.DivList0 table tr.Bj td { background:#EEF7FF;}
.DivList0 table tr.ZBj td { background:#FFFFC1;}
.DivList0 table tr td.Blackbj { background:#f6f6f6; vertical-align:top; font-weight:bold;}
.DivList0 table tr.Hover:hover td { background:#FFFFE8;}
.DivList0 table tr.Hover:hover td.Blackbj { background:#f6f6f6;}

.DivList0 table td.Roleno{white-space: nowrap;}
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{if $chengben neq 'chengben'}{'GUOTONGREPORT'|@getFixedLabel}{else}{'CostStatistics'|@getFixedLabel}{/if}:  {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 </h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module">
                    <input type="hidden" value="GuoTongReports" name="action">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name">
                        <span>{'INFANCY'|@getFixedLabel}: &nbsp;</span>
                        <input id="begin_date" class="Wdate" name="begin_date" value="{$begin_date}" onClick="WdatePicker()"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                        <!--<img id="b_jscal_trigger_date_start" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />                                                       
                        <script id="massedit_calendar_date_begin" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "begin_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "b_jscal_trigger_date_start", singleClick : true, step : 1
                           	{rdelim})
                        </script>-->
                    </label>
                    
                    <label class="Name">
                        <span>{'CLOSING'|@getFixedLabel}: &nbsp;</span>
                        <input id="end_date" class="Wdate" name="end_date" value="{$end_date}" onClick="WdatePicker()"/>
                        <input id="bd_end_date" type="hidden" name="bd_end_date"/>
                        <!--<img id="bd_jscal_trigger_date_end" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />
                        <script id="massedit_calendar_date_end" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "end_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "bd_jscal_trigger_date_end", singleClick : true, step : 1
                           	{rdelim})
                        </script>-->
                    </label>
                    <label class="Name">
                    {'Customerclassification'|@getFixedLabel} :&nbsp;
                    <select name="proxy">
                            <option value="ALL" {if $proxy eq 'ALL'}selected="selected"{/if}>{'ALL'|@getFixedLabel}</option>
                            <option value="直营" {if $proxy eq '直营'}selected="selected"{/if}>{'Direct'|@getFixedLabel}</option>
                            <option value="代理" {if $proxy eq '代理'}selected="selected"{/if}>{'Proxy'|@getFixedLabel}</option>
                    </select> 
                    </label>
                    <label class="Name">
                    {'Whetherthebilling'|@getFixedLabel} :&nbsp;
                    <select name="bill">
                            <option value="ALL" {if $bill eq 'ALL'}selected="selected"{/if}>{'ALL'|@getFixedLabel}</option>
                            <option value="是" {if $bill eq '是'}selected="selected"{/if}>{'YES'|@getFixedLabel}</option>
                            <option value="否" {if $bill eq '否'}selected="selected"{/if}>{'NO'|@getFixedLabel}</option>
                    </select> 
                    </label>
                    <label class="Name">
                     <span>{'AccountName'|@getFixedLabel} :&nbsp;</span>
                        <input type="text" name="accountname" value='{$accountname}' class="Select"/>
                     </label>
                     
                     <label class="Name">
                     <span>{'Doctor'|@getFixedLabel} :&nbsp;</span>
                        <input type="text" name="Doctor" value='{$Doctor}' class="Select"/>
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
                        <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th >{'Customerclassification'|@getFixedLabel}</th>
                        <th >{'Unit'|@getFixedLabel}</th>
                        <th >{'DoctorsName'|@getFixedLabel}</th>
                        <th >{'Model'|@getFixedLabel}</th>
                        <th >{'LISTPRICE'|@getFixedLabel}</th>
                        <th >{'QUANTITY'|@getFixedLabel}</th>
                        <th >{'AMOUNT'|@getFixedLabel}</th>
                        {if $chengben eq 'chengben'}<th >{'Costp'|@getFixedLabel}</th>{/if}
                    </tr>
                    {foreach name=countRow from=$roleList key=key item=arr2}
                        <tr>
                        {if $arr2.danjia neq '小计'&&$arr2.danjia neq '合计'}  
                        {if $arr2.rowspan!==0}   
                                <td {if $arr2.rowspan gt 0}rowspan='{$arr2.rowspan}'{/if}class="listTableRow small">{$arr2.accounttype}</td>
                                <td {if $arr2.rowspan gt 0}rowspan='{$arr2.rowspan}'{/if}class="listTableRow small">{$arr2.accountname}</td>
                        {/if}
                        {if $arr2.rowspans!==0}  
                                <td {if $arr2.rowspans gt 0}rowspan='{$arr2.rowspans}'{/if}class="listTableRow small">{$arr2.yisheng}</td>
                        {/if}
                                <td class="listTableRow small">{$arr2.guige}</td>
                                <td class="listTableRow small"style="text-align:right;">{$arr2.danjia|@getDecimalTwoVal}</td>
                                <td class="listTableRow small"style="text-align:right;">{$arr2.qty}</td>
                                <td class="listTableRow small"style="text-align:right;">{$arr2.amount}</td>
                                {if $chengben eq 'chengben'}<td class="listTableRow small"style="text-align:right;">{$arr2.cost}</td>{/if}
                        {elseif $arr2.danjia eq '小计'}
                                <td class="listTableRow small"style="background-color:#EEF7FF;"></td>
                                <td class="listTableRow small"style="background-color:#EEF7FF;"></td>
                                <td class="listTableRow small"style="background-color:#EEF7FF;">{$arr2.danjia}</td>
                                <td class="listTableRow small"style="background-color:#EEF7FF;text-align:right;">{$arr2.qty}</td>
                                <td class="listTableRow small"style="background-color:#EEF7FF;text-align:right;">{$arr2.amount}</td>
                                {if $chengben eq 'chengben'}<td class="listTableRow small"style="background-color:#EEF7FF;"></td>{/if}  
                        {else $arr2.danjia eq '合计'}
                                <td class="listTableRow small"style="background-color:#FFFFC1;"></td>
                                <td class="listTableRow small"style="background-color:#FFFFC1;"></td>
                                <td class="listTableRow small"style="background-color:#FFFFC1;"></td>
                                <td class="listTableRow small"style="background-color:#FFFFC1;"></td>
                                <td class="listTableRow small"style="background-color:#FFFFC1;">{$arr2.danjia}</td>
                                <td class="listTableRow small"style="background-color:#FFFFC1;text-align:right;">{$arr2.qty}</td>
                                <td class="listTableRow small"style="background-color:#FFFFC1;text-align:right;">{$arr2.amount}</td>
                                {if $chengben eq 'chengben'}<td class="listTableRow small"style="background-color:#FFFFC1;"></td>{/if}  
                        {/if}     
                        </tr>
                    {/foreach}
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>