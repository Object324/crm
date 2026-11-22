<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
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
<title>{'Drilldownreports'|@getFixedLabel}</title>
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
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:130px;float:left;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 input.Button_find { margin-left:10px;}
/*---查找 end----*/
/*---蓝色保存-小按钮---*/
.Button_find { float:left; color:#fff;font-weight:bold; overflow:hidden; line-height:21px;border:none;padding: 0 15px; border-radius:3px; cursor:pointer; font-size:12px; background-image: url(themes/softed/images/toolbar-bg.png);}

/*---绿色保存-大按钮---*/
.DivBox_Center { width:100%; overflow:hidden; padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; overflow:hidden;}
.DivBox_Center .DivList0 table { background:#ccc;}
.DivBox_Center .DivList0 table th,.DivBox_Center .DivList0 table td { background:#fff; font-size:13px; color:#666; line-height:24px; padding:3px 10px;}
.DivBox_Center .DivList0 table th { background:#C7D9EE url(themes/softed/images/thbj.png) repeat-x left 0px; color:#2A66C5; padding:5px 10px;/* font-weight:lighter;*/}
.DivBox_Center .DivList0 table tr.Bj td { background:#EEF7FF;}
.DivBox_Center .DivList0 table tr.ZBj td { background:#FFFFC1;}
.DivBox_Center .DivList0 table tr td.Blackbj { background:#f6f6f6; vertical-align:top; font-weight:bold;}
.DivBox_Center .DivList0 table tr.Hover:hover td { background:#FFFFE8;}
.DivBox_Center .DivList0 table tr.Hover:hover td.Blackbj { background:#f6f6f6;}

.aligh-r{text-align:right;}
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{'Drilldownreports'|@getFixedLabel}:  {$begin_date} 00:00:00 {'TO'|@getFixedLabel} {$end_date} 23:59:59 </h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module">
                    <input type="hidden" value="Drilldownreports" name="action">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader">
                    
                	<label class="Name">
                        <span>{'INFANCY'|@getFixedLabel}:</span>
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
                        <span>{'CLOSING'|@getFixedLabel}:</span>
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
                            <span>{'PRODUCTS'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$uPRODUCTS}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',18);BodyClick2(this,'div_select_user');"/>
                            <span id="assign_user_id">
                                <div id="div_select_user" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=count_num value=0}
                                        {assign var=colum_num value=1}
                                        
                							{foreach key=username item=userid from=$productlist}
                                               {if $count_num eq 0}
                                               <tr>
                                               {elseif $count_num%$colum_num eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td align="left">
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        <input type="checkbox" name="cb_select_user" onclick="ngetSelected('receiverid','cb_select_user')"/>
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_user_{$count_num}">{$username}</span>
                                                        <input id="search_text_{$count_num++}" type="hidden" value="{$userid}"/>  
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
                    <label class="Name">  
                            <span>{'Customer'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text2" id="search_text2" value="{$uCustomer}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_account',18);BodyClick2(this,'div_select_account');"/>
                            <span id="assign_user_id2">
                                <div id="div_select_account" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Acount_num value=0}
                                        {assign var=Acolum_num2 value=1}
                                        
                							{foreach key=username item=userid from=$accountlist}
                                               {if $Acount_num eq 0}
                                               <tr>
                                               {elseif $Acount_num%$Acolum_num2 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        <input type="checkbox" name="cb_select_account" onclick="ngetSelected('receiverid','cb_select_account')"/>
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_account_{$Acount_num}">{$username}</span>
                                                        <input id="search_text2_{$Acount_num++}" type="hidden" value="{$userid}"/>  
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
                    <label class="Name">              
                            <span>{'Sector'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text3" id="search_text3" value="{$uSector}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Sector',18);BodyClick2(this,'div_select_Sector');"/>
                            <span id="assign_user_id3">
                                <div id="div_select_Sector" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Sector_num value=0}
                                        {assign var=Sector_num2 value=1}
                                        
                							{foreach key=username item=userid from=$Sectorlist}
                                               {if $Sector_num eq 0}
                                               <tr>
                                               {elseif $Sector_num%$Sector_num2 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        <input type="checkbox" name="cb_select_Sector" onclick="ngetSelected('receiverid','cb_select_Sector')"/>
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_Sector_{$Sector_num}">{$userid}</span>
                                                        <input id="search_text3_{$Sector_num++}" type="hidden" value="{$userid}"/> 
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
                        <label class="Name">      
                            <span>{'Salesman'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text4" id="search_text4" value="{$uSalesman}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Salesman',18);BodyClick2(this,'div_select_Salesman');"/>
                            <span id="assign_user_id4">
                                <div id="div_select_Salesman" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num2 value=2}
                                        
                							{foreach key=username item=userid from=$Salesmanlist}
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
                                                        <input type="checkbox" name="cb_select_Salesman" onclick="ngetSelected('receiverid','cb_select_Salesman')"/>
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_Salesman_{$Salesman_num}">{$userid}</span>
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
                        <th >{'DATE'|@getFixedLabel}</th>
                        <th >{'OrderNO'|@getFixedLabel}</th>
                        <th >{'Customer'|@getFixedLabel}</th>
                        <th >{'PRODUCTS'|@getFixedLabel}</th>
                        <th >{'Sector'|@getFixedLabel}</th>
                        <th >{'Salesman'|@getFixedLabel}</th>
                        <th >{'QUANTITY'|@getFixedLabel}</th>
                        <th >{'SALESAMOUNT'|@getFixedLabel}</th>
                        <th >{'Costp'|@getFixedLabel}</th>
                        <th >{'Rebates'|@getFixedLabel}</th>
                        <th >{'Supportcosts'|@getFixedLabel}</th>          
                    </tr>
                    {foreach name=countRow from=$salesList key=key item=arr}
                    <tr>
                    {if $arr.rowspan!==0}
                    <td class="listTableRow" {if $arr.rowspan gt 0}rowspan='{$arr.rowspan}'{/if}>{$arr.signed_data}</td>
                    <td class="listTableRow" {if $arr.rowspan gt 0}rowspan='{$arr.rowspan}'{/if}style="background-color:#EEF7FF;">{$arr.salesorder_no}</td>
                    <td class="listTableRow" {if $arr.rowspan gt 0}rowspan='{$arr.rowspan}'{/if}>{$arr.accountname}</td>
                    {/if}
                    <td class="listTableRow" {if ($smarty.foreach.countRow.index+1)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr.productname}</td>
                    {if $arr.rowspan!==0}
                    <td class="listTableRow" {if $arr.rowspan gt 0}rowspan='{$arr.rowspan}'{/if}>{$arr.cf_1158}</td>
                    <td class="listTableRow" {if $arr.rowspan gt 0}rowspan='{$arr.rowspan}'{/if}style="background-color:#EEF7FF;">{$arr.cf_1159}</td>
                    {/if}
                    <td class="aligh-r" {if ($smarty.foreach.countRow.index+1)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr.quantity}</td>
                    <td class="aligh-r" {if ($smarty.foreach.countRow.index+1)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr.total}</td>
                    <td class="aligh-r" {if ($smarty.foreach.countRow.index+1)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr.productcost}</td>
                    <td class="aligh-r" {if ($smarty.foreach.countRow.index+1)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr.listprice}</td>
                    <td class="aligh-r" {if ($smarty.foreach.countRow.index+1)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr.zhichifeiyong}</td>                    
                    </tr>
                    {/foreach}
                    <tr class="ZBj Hover">
                        <td class="listTableRow">{'TOTAL'|@getFixedLabel}</td>
                        <td class="listTableRow"></td>
                        <td class="listTableRow"></td>
                        <td class="listTableRow"></td>
                        <td class="listTableRow"></td>    
                        <td class="listTableRow"></td>
                        <td class="listTableRow"></td>                     
                        <td class="listTableRow" style="text-align:right;">{$r_total.total_all}</td>
                        <td class="listTableRow" style="text-align:right;">{$r_total.productcost_all}</td> 
                        <td class="listTableRow" style="text-align:right;">{$r_total.listprice_all}</td>    
                        <td class="listTableRow" style="text-align:right;">{$r_total.zhichifeiyong_all}</td>                        
                    </tr>
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>
<script type="text/javascript">
    window.onresize = function(){ldelim}
        if(document.getElementById('div_select_user')!=undefined&&document.getElementById('div_select_user').style.display!='none'){ldelim}
                            CfnDropDownUsers(getObj('search_text'),'div_select_user',18);BodyClick2(getObj('search_text'),'div_select_user');
                        {rdelim}
                    {rdelim}
                    
    window.onresize = function(){ldelim}
        if(document.getElementById('div_select_account')!=undefined&&document.getElementById('div_select_account').style.display!='none'){ldelim}
                            CfnDropDownUsers(getObj('search_text2'),'div_select_account',18);BodyClick2(getObj('search_text2'),'div_select_account');
                        {rdelim}
                    {rdelim}        
                    
    window.onresize = function(){ldelim}
        if(document.getElementById('div_select_Sector')!=undefined&&document.getElementById('div_select_Sector').style.display!='none'){ldelim}
                            CfnDropDownUsers(getObj('search_text3'),'div_select_Sector',18);BodyClick2(getObj('search_text3'),'div_select_Sector');
                        {rdelim}
                    {rdelim}      
    window.onresize = function(){ldelim}
        if(document.getElementById('div_select_Salesman')!=undefined&&document.getElementById('div_select_Salesman').style.display!='none'){ldelim}
                            CfnDropDownUsers(getObj('search_text4'),'div_select_Salesman',18);BodyClick2(getObj('search_text4'),'div_select_Salesman');
                        {rdelim}
                    {rdelim} 
 </script>
 
 