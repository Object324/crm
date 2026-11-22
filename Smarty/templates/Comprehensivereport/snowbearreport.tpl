<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
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
<title>{'SNOWBEARREPORTS'|@getFixedLabel}</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:8px;}
.DivBox_top { width:100%; height:45px;}
.DivBox_top h1 { float:left; font-size:20px; color:#666; line-height:30px;}
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:8px;}
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%; background:url(themes/softed/images/layerPopupBg.gif) repeat left 0px;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:25px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:2px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:130px;float:left;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 input.Checkbox { float:left; margin:4px 0px 0px 10px; *margin-top:0px;}
.Find_Form0 .Div0 { float:left;position:relative; z-index:1;}
.export{float:right;border-radius:3px;margin-left:10px;text-decoration:none;}
/*---查找 end----*/
.Button_find { margin-left:10px; float:left; color:#fff;font-weight:bold; overflow:hidden; line-height:21px;border:none;padding: 0 15px; border-radius:3px; cursor:pointer; font-size:12px; background-image: url(themes/softed/images/toolbar-bg.png);}


.DivBox_Center { width:100%;  padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; }
.DivBox_Center .DivList0 table { background:#ccc;}
.DivBox_Center .DivList0 table th,.DivBox_Center .DivList0 table td { background:#fff; font-size:13px; color:#666; line-height:24px; padding:3px 10px;}
.DivBox_Center .DivList0 table th { background:#C7D9EE url(themes/softed/images/thbj.png) repeat-x left 0px; color:#2A66C5; padding:5px 10px;/* font-weight:lighter;*/}
.DivBox_Center .DivList0 table tr.bj td{background-color:#EEF7FF;}
</style>
{/literal}

<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$YEAR}{if $YEAR neq ''}{'YEAR'|@getFixedLabel}{/if}{$reportname|@getFixedLabel}</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                    {if $reportname eq 'Customercomplaintanalysisreport2'}
                        <input type="hidden" value="snowbearreportsflash" name="action"/>
                    {elseif $reportname eq 'Productcustomerservicenumberfailurestatistics2'}
                        <input type="hidden" value="snowbearreportsflash2" name="action"/>
                    {elseif $reportname eq 'Summary400hotlinesinglestatistics'}
                        <input type="hidden" value="snowbearreportsflash400" name="action"/>
                    {elseif $reportname eq 'Productcustomerservicenumberfailurestatistics3'}
                        <input type="hidden" value="snowbearreportsflash3" name="action"/>
                    {else}
                        <input type="hidden" value="snowbearreports" name="action"/>
                    {/if}

                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    <!--input type="hidden" value="" name="ajaxExport" id="ajaxExport"/-->
                    {if $reportname eq 'Customercomplaintanalysisreport2'||$reportname eq 'Productcustomerservicenumberfailurestatistics2'||$reportname eq 'Summary400hotlinesinglestatistics'}
                	<label class="Name">
                        <span>年份一:</span>
                            <input  class="date" name="year2" value="{$year2}"/>
                        </span>
                    </label>
                	<label class="Name">
                        <span>年份二:</span>
                            <input  class="date" name="year" value="{$year}"/>
                        </span>
                    </label>
                    {if $reportname eq 'Productcustomerservicenumberfailurestatistics2'}                    
                   	<label class="Name">
                        <span>{'admissibilitytype'|@getFixedLabel}:</span>
                        <select id="admissibilitytype" class="date" name="admissibilitytype">  
                        <option value=''>--全部--</option>
                            {foreach item=userid from=$cf_1475list}
                             <option value ="{$userid}" {if $admissibilitytype eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                        </select> 
                    </span>
                    </label> 
                    {/if}                                        
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}                     
                    {if $reportname eq 'SNOWBEARRPISP'}
                	<label class="Name">
                        <span>{'SNOWBEARYear'|@getFixedLabel}:</span>
                            <input id="begin_date" class="date" name="year" value="{$YEAR}"/>
                        </span>
                    </label>

                    <label class="Name">
                            <span>{'SNOWBEARProductName'|@getFixedLabel}:</span>
                                <input type="text" class="date" name="ProductName" value="{$ProductName}" style="width:230px" />
                            </span>
                    </label>
                    <label class="Name">
                            <span>{'SNOWBEARApplicableModel'|@getFixedLabel}:</span>
                                <input type="text" class="date" name="ApplicableModel" value="{$ApplicableModel}" style="width:230px" />
                            </span>
                    </label>                    
                    <label class="Name">
                            <span>产品类别:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$receiverid}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',18);BodyClick2(this,'div_select_user');" readonly/>
                            <span id="assign_user_id">
                                <div id="div_select_user" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=count_num value=0}
                                        {assign var=colum_num value=1}
                                        
                							{foreach key=username item=userid from=$productcategorylist}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_user" {$cheack} onclick="ngetSelected('receiverid','cb_select_user')"/>
                                                        {assign var=cheack value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_user_{$count_num}">{$userid}</span>
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
                            <span>{'ProductCategories'|@getFixedLabel}:</span>
                            <select id="ProductCategories" class="date" name="ProductCategories">  
                        <option value=''>--全部--</option>
                            {foreach item=userid key=key2 from=$procatlist}
                             <option value ="{$key2}" {if $ProductCategories eq $key2} selected="selected" {/if}>{$key2}</option>  
                            {/foreach}  
                        </select>   </span>
                    </label> 
                    <label class="Name">
                            <span>{'Containsapprovaldocument'|@getFixedLabel}:</span>                    
                                <input name="approvalSales" id="approvalSales" class="Checkbox" type="checkbox" value="1" {if $approvalSales eq 1}checked=""{/if}  /> 
                            </span>
                    </label>   
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    <a  href="index.php?module=Comprehensivereport&action=snowbearreports&ajaxExport=yes&ProductCategories={$ProductCategories}&approvalSales={$approvalSales}&ProductName={$ProductName}&ApplicableModel={$ApplicableModel}&name={$reportname}&ReportHeader=DHeader&year={$YEAR} " class="saveauto export">{'EXPORT'|@getFixedLabel}</a>
                    </label>
                    {/if}                    
                    {if $reportname eq 'SNOWBEARRPSL'}
               	    <label class="Name"><span>{'TIMESLOT'|@getFixedLabel}:</span>
                                
                        <input id="begin_date" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
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
                        <span>{'SRPN'|@getFixedLabel}:</span>
                            <input id="SRPN" class="date" name="SRPN" value="{$SRPN}"/>
                        </span>
                    </label>
                   	<label class="Name">
                        <span>{'CONTRACTNO'|@getFixedLabel}:</span>
                            <input id="CONTRACTNO" class="date" name="CONTRACTNO" value="{$CONTRACTNO}"/>
                        </span>
                    </label>
                   	<label class="Name">
                        <span>{'SNOWBEARProductName'|@getFixedLabel}:</span>
                            <input id="ProductName" class="date" name="ProductName" value="{$ProductName}"/>
                        </span>
                    </label>
                    <label class="Name">
                        <span>{'SNOWBEARApplicableModel'|@getFixedLabel}:</span>
                            <input type="text" class="date" name="ApplicableModel" value="{$ApplicableModel}" style="width:230px" />
                        </span>
                    </label>
                    </br>
                    <label class="Name">
                            <span>产品类别:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$receiverid}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',28);BodyClick2(this,'div_select_user');" readonly/>
                            <span id="assign_user_id">
                                <div id="div_select_user" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=count_num value=0}
                                        {assign var=colum_num value=1}
                                        
                							{foreach key=username item=userid from=$productcategorylist}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_user" {$cheack} onclick="ngetSelected('receiverid','cb_select_user')"/>
                                                        {assign var=cheack value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_user_{$count_num}">{$userid}</span>
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
                            <span>{'ProductCategories'|@getFixedLabel}:</span>
                            <select id="ProductCategories" class="date" name="ProductCategories">  
                        <option value=''>--全部--</option>
                            {foreach item=userid key=key2 from=$procatlist}
                             <option value ="{$key2}" {if $ProductCategories eq $key2} selected="selected" {/if}>{$key2}</option>  
                            {/foreach}  
                        </select>   </span>
                    </label> 
                    <label class="Name">
                        <span>{'EXPLAIN'|@getFixedLabel}:</span>
                            <input type="text" class="date" name="EXPLAIN" value="{$EXPLAIN}" style="width:230px" />
                        </span>
                    </label>
                    <label class="Name">
                        <span>{'Containsapprovaldocument'|@getFixedLabel}:</span>                    
                            <input name="approvalSales" id="approvalSales" class="Checkbox" type="checkbox" value="1" {if $approvalSales eq 1}checked=""{/if}  /> 
                        </span>
                    </label>    
                              
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    <a  href="index.php?module=Comprehensivereport&action=snowbearreports&ajaxExport=yes&ProductCategories={$ProductCategories}&SRPN={$SRPN}&CONTRACTNO={$CONTRACTNO}&EXPLAIN={$EXPLAIN}&approvalSales={$approvalSales}&ProductName={$ProductName}&ApplicableModel={$ApplicableModel}&name={$reportname}&ReportHeader=DHeader&begin_date={$begin_end_date}&Report_form_query={$Report_form_query}&year={$year}" class="saveauto export">{'EXPORT'|@getFixedLabel}</a>
                    </label>
                    {/if} 
                    {if $reportname eq 'Returnamountregionaldatasummaryreport'}
                   	<label class="Name">
                       <span> 客户类别:</span>    
                        <select id="Customercategory" class="date" name="Customercategory">  
                        <option value=''>--全部--</option>
                            {foreach item=userid from=$accounttype}
                             <option value ="{$userid}" {if $Customercategory eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                        </select>  
                        </span>                      
                    </label> 
                   	<label class="Name">
                        <span>{'admissibilitytype'|@getFixedLabel}:</span>
                        <select id="admissibilitytype" class="date" name="admissibilitytype">  
                        <option value=''>--全部--</option>
                            {foreach item=userid from=$cf_1475}
                             <option value ="{$userid}" {if $admissibilitytype eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                        </select> 
                    </span>
                    </label> 
                    	<label class="Name">
                        <span>{'AccountName'|@getFixedLabel}:</span>
                            <input id="AccountName" class="date" name="AccountName" value="{$AccountName}"/>
                        </span>
                    </label> 
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}
                    {if $reportname eq 'SNOWBEARHNSRSR'}
                    	<label class="Name">
                        <span>{'SNOWBEARYear'|@getFixedLabel}:</span>
                            <input id="begin_date" class="date" name="year" value="{$YEAR}"/>
                        </span>
                    </label> 
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}
                     {if $reportname eq 'Customerservicenumberofsummarytableoffaultarea'}
                    	<label class="Name">
                        <span>{'SNOWBEARYear'|@getFixedLabel}:</span>
                            <input id="begin_date" class="date" name="year" value="{$YEAR}"/>
                        </span>
                    </label> 
                   	<label class="Name">
                        <span>{'admissibilitytype'|@getFixedLabel}:</span>
                        <select id="admissibilitytype" class="date" name="admissibilitytype">  
                        <option value=''>--全部--</option>
                            {foreach item=userid from=$cf_1475}
                             <option value ="{$userid}" {if $admissibilitytype eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}
                    {if $reportname eq 'Productcustomerservicenumberfailurestatistics3'}
                   	<label class="Name">
                       <span>产品:</span>
                        <select id="Customercategory" class="date" name="Customercategory">  
                        <option value=''>--全部--</option>
                            {foreach item=userid key=keyas from=$proList}
                             <option value ="{$keyas}" {if $proname eq $keyas} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                        </select>  
                        </span>                      
                    </label>  
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}
                    {if $reportname eq 'Returnnumberregionaldatasummaryreport'}
                   	<label class="Name">
                       <span>{'Customercategory'|@getFixedLabel}:</span>
                        <select id="Customercategory" class="date" name="Customercategory">  
                        <option value=''>--全部--</option>
                            {foreach item=userid from=$accounttype}
                             <option value ="{$userid}" {if $Customercategory eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                        </select>  
                        </span>                      
                    </label>
                   	<label class="Name">
                        <span>{'admissibilitytype'|@getFixedLabel}:</span>
                        <select id="admissibilitytype" class="date" name="admissibilitytype">  
                        <option value=''>--全部--</option>
                            {foreach item=userid from=$cf_1475}
                             <option value ="{$userid}" {if $admissibilitytype eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                   	<label class="Name">
                        <span>产品类别:</span>
                        <select id="cf_1424" class="date" name="cf_1424">  
                        <option value=''>--全部--</option>
                            {foreach key=keyas item=userid from=$ProductCategories}
                             <option value ="{$keyas}" {if $cf_1424 eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </span>
                    </label>  
                   	<label class="Name">
                        <span>{'Productseries'|@getFixedLabel}:</span>
                        <select id="cf_1406" class="date" name="cf_1406">  
                        <option value=''>--全部--</option>
                            {foreach key=keyas item=userid from=$Productseries}
                             <option value ="{$keyas}" {if $cf_1406 eq $keyas} selected="selected" {/if}>{$keyas}</option>  
                            {/foreach}  
                    </select> 
                    </span>
                    </label>  
                    <label class="Name">
                        <span>{'Model'|@getFixedLabel}:</span>                    
                            <input type="text" class="date" name="Containsapprovaldocument" value="{$Containsapprovaldocument}" style="width:230px" />
                    </span>
                    </label>    
                    <label class="Name">
                        <span>客户名称:</span>                    
                            <input type="text" class="date" name="Accountname" value="{$Accountname}" style="width:230px" />
                    </span>
                    </label>    
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}
                    {if $reportname eq 'Customercomplaintanalysisreport'}
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
                            <span>产品类别:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$uPRODUCTS}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',18);BodyClick2(this,'div_select_user');" readonly/>
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
                                                        {foreach key=key item=receiverids from=$receiverid_array }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_user" {$cheack} onclick="ngetSelected('receiverid','cb_select_user')"/>
                                                        {assign var=cheack value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_user_{$count_num}">{$userid}</span>
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
                            <span>{'Productseries'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text2" id="search_text2" value="{$uCustomer}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_account',18);BodyClick2(this,'div_select_account');" readonly/>
                            <span id="assign_user_id2">
                                <div id="div_select_account" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Acount_num value=0}
                                        {assign var=Acolum_num2 value=1}
                                        
                							{foreach key=username item=userid from=$serieslist}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array2 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack2 value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_account" {$cheack2} onclick="ngetSelected('receiverid','cb_select_account')" />
                                                        {assign var=cheack2 value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_account_{$Acount_num}">{$username}</span>
                                                        <input id="search_text2_{$Acount_num++}" type="hidden" value="{$username}"/>  
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
                            <span>{'Model'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text3" id="search_text3" value="{$receiverid3}" style="width:230px" />
           
                            </span>
                        </label>
                        <label class="Name">      
                            <span>{'AOTABR'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text4" id="search_text4" value="{$uSalesman}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Salesman',18);BodyClick2(this,'div_select_Salesman');"/>
                            <span id="assign_user_id4">
                                <div id="div_select_Salesman" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num3 value=2}
                                        
                							{foreach key=username item=userid from=$AOTABRlist}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array4 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack4 value=checked}
                                                         {/if}
                                                        {/foreach}   
                                                        <input type="checkbox" name="cb_select_Salesman" {$cheack4} onclick="ngetSelected('receiverid','cb_select_Salesman')"/>
                                                        {assign var=cheack4 value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_Salesman_{$Salesman_num}">{$username}</span>
                                                        <input id="search_text4_{$Salesman_num++}" type="hidden" value="{$username}"/>
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
                    {/if}
                    {if $reportname eq 'Productcustomerservicenumberfailurestatistics'}
                    <label class="Name">
                            <span>产品类别:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$uPRODUCTS}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',18);BodyClick2(this,'div_select_user');" readonly/>
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
                                                        {foreach key=key item=receiverids from=$receiverid_array }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_user" {$cheack} onclick="ngetSelected('receiverid','cb_select_user')"/>
                                                        {assign var=cheack value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_user_{$count_num}">{$userid}</span>
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
                            <span>{'Productseries'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text2" id="search_text2" value="{$uCustomer}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_account',18);BodyClick2(this,'div_select_account');" readonly/>
                            <span id="assign_user_id2">
                                <div id="div_select_account" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Acount_num value=0}
                                        {assign var=Acolum_num2 value=1}
                                        
                							{foreach key=username item=userid from=$serieslist}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array2 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack2 value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_account" {$cheack2} onclick="ngetSelected('receiverid','cb_select_account')" />
                                                        {assign var=cheack2 value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_account_{$Acount_num}">{$username}</span>
                                                        <input id="search_text2_{$Acount_num++}" type="hidden" value="{$username}"/>  
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
                            <span>{'Model'|@getFixedLabel}:</span>                 
                            <input type="text" class="date" name="search_text3" value="{$receiverid3}" style="width:230px" />
                            </span>
                        </label>
                        <label class="Name">      
                            <span>{'causefault'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text4" id="search_text4" value="{$uSalesman}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Salesman',18);BodyClick2(this,'div_select_Salesman');"/>
                            <span id="assign_user_id4">
                                <div id="div_select_Salesman" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num3 value=2}
                                        
                							{foreach key=username item=userid from=$AOTABRlist}
                                               {if $Salesman_num eq 0}
                                               <tr>
                                               {elseif $Salesman_num%$Salesman_num3 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        {foreach key=key item=receiverids from=$receiverid_array4 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack4 value=checked}
                                                         {/if}
                                                        {/foreach}   
                                                        <input type="checkbox" name="cb_select_Salesman" {$cheack4} onclick="ngetSelected('receiverid','cb_select_Salesman')"/>
                                                        {assign var=cheack4 value=''}
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
                            <span>{'admissibilitytype'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text5" id="search_text5" value="{$uSalesmans}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Salesmans',18);BodyClick2(this,'div_select_Salesmans');"/>
                            <span id="assign_user_id5">
                                <div id="div_select_Salesmans" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num4 value=2}
                                        
                							{foreach key=username item=userid from=$cf_1475}
                                               {if $Salesman_num eq 0}
                                               <tr>
                                               {elseif $Salesman_num%$Salesman_num4 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        {foreach key=key item=receiverids from=$receiverid_array5 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack5 value=checked}
                                                         {/if}
                                                        {/foreach}   
                                                        <input type="checkbox" name="cb_select_Salesmans" {$cheack5} onclick="ngetSelected('receiverid','cb_select_Salesmans')"/>
                                                        {assign var=cheack5 value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_Salesmans_{$Salesman_num}">{$userid}</span>
                                                        <input id="search_text5_{$Salesman_num++}" type="hidden" value="{$userid}"/>
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
                    {/if} 
                    {if $reportname eq 'Analysisofthetablecustomerservicefailure'}
                    <label class="Name">
                            <span>产品类别:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$uPRODUCTS}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',18);BodyClick2(this,'div_select_user');" readonly/>
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
                                                        {foreach key=key item=receiverids from=$receiverid_array }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_user" {$cheack} onclick="ngetSelected('receiverid','cb_select_user')"/>
                                                        {assign var=cheack value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_user_{$count_num}">{$userid}</span>
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
                            <span>{'Productseries'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text2" id="search_text2" value="{$uCustomer}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_account',18);BodyClick2(this,'div_select_account');" readonly/>
                            <span id="assign_user_id2">
                                <div id="div_select_account" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Acount_num value=0}
                                        {assign var=Acolum_num2 value=1}
                                        
                							{foreach key=username item=userid from=$serieslist}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array2 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack2 value=checked}
                                                         {/if}
                                                        {/foreach}
                                                        <input type="checkbox" name="cb_select_account" {$cheack2} onclick="ngetSelected('receiverid','cb_select_account')" />
                                                        {assign var=cheack2 value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_account_{$Acount_num}">{$username}</span>
                                                        <input id="search_text2_{$Acount_num++}" type="hidden" value="{$username}"/>  
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
                            <span>{'Model'|@getFixedLabel}:</span>
                                <input type="text" class="date" name="search_text6" value="{$receiverid6}" style="width:230px" />
                            </span>
                        </label>
                    <label class="Name">              
                            <span>受理类型:</span>
                            <input type="text"   class="date" name="search_text3" id="search_text3" value="{$uSector}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Sector',18);BodyClick2(this,'div_select_Sector');" readonly/>
                            <span id="assign_user_id3">
                                <div id="div_select_Sector" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Sector_num value=0}
                                        {assign var=Sector_num2 value=1}
                                        
                							{foreach key=username item=userid from=$cf_1410list}
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
                                                        {foreach key=key item=receiverids from=$receiverid_array3 }
                                                        {if $receiverids eq $userid}
                                                        {assign var=cheack3 value=checked}
                                                         {/if}
                                                        {/foreach}                                                        
                                                        <input type="checkbox" name="cb_select_Sector" {$cheack3} onclick="ngetSelected('receiverid','cb_select_Sector')"/>
                                                        {assign var=cheack3 value=''}
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
                            <span>{'RANGESTAFF'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text4" id="search_text4" value="{$uSalesman}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Salesman',18);BodyClick2(this,'div_select_Salesman');"/>
                            <span id="assign_user_id4">
                                <div id="div_select_Salesman" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num3 value=2}
                                        
                							{foreach key=username item=userid from=$AOTABRlist}
                                               {if $Salesman_num eq 0}
                                               <tr>
                                               {elseif $Salesman_num%$Salesman_num3 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        {foreach key=key item=receiverids from=$receiverid_array4 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack4 value=checked}
                                                         {/if}
                                                        {/foreach}   
                                                        <input type="checkbox" name="cb_select_Salesman" {$cheack4} onclick="ngetSelected('receiverid','cb_select_Salesman')"/>
                                                        {assign var=cheack4 value=''}
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
                        <!--label class="Name">      
                            <span>{'admissibilitytype'|@getFixedLabel}:</span>
                            <input type="text"   class="date" name="search_text5" id="search_text5" value="{$uSalesmans}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_Salesmans',18);BodyClick2(this,'div_select_Salesmans');"/>
                            <span id="assign_user_id5">
                                <div id="div_select_Salesmans" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:55px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=Salesman_num value=0}
                                        {assign var=Salesman_num4 value=2}
                                        
                							{foreach key=username item=userid from=$cf_1475}
                                               {if $Salesman_num eq 0}
                                               <tr>
                                               {elseif $Salesman_num%$Salesman_num4 eq 0}
                                               </tr><tr>
                                               {/if}
                                               <td>
                                                    <table border="0" cellspacing="0" cellpadding="0" style="margin-left:5px;">
                                                    <tbody>
                                                        <tr>
                                                        <td align="left">
                                                        {foreach key=key item=receiverids from=$receiverid_array5 }
                                                        {if $receiverids eq $username}
                                                        {assign var=cheack5 value=checked}
                                                         {/if}
                                                        {/foreach}   
                                                        <input type="checkbox" name="cb_select_Salesmans" {$cheack5} onclick="ngetSelected('receiverid','cb_select_Salesmans')"/>
                                                        {assign var=cheack5 value=''}
                                                        </td>
                                                        <td align="left">
                                                        <span id="sp_Salesmans_{$Salesman_num}">{$userid}</span>
                                                        <input id="search_text5_{$Salesman_num++}" type="hidden" value="{$userid}"/>
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
                    </label-->
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>
                    {/if}                                       
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
                {if $reportname eq 'SNOWBEARRPISP'}
                    <tr>
                        <th >{'SNOWBEARProductName'|@getFixedLabel}</th>
                        <th >产品类别</th>
                        <th style="background:red;">{'COSTPRICE'|@getFixedLabel}</th>
                        <th >{'EXPLAIN'|@getFixedLabel}</th>
                        <th >{'SNOWBEARApplicableModel'|@getFixedLabel}</th>
                        <th >1 {'nMonth'|@getFixedLabel}</th>
                        <th >2 {'nMonth'|@getFixedLabel}</th>
                        <th >3 {'nMonth'|@getFixedLabel}</th>
                        <th >4 {'nMonth'|@getFixedLabel}</th>
                        <th >5 {'nMonth'|@getFixedLabel}</th>
                        <th >6 {'nMonth'|@getFixedLabel}</th>
                        <th >7 {'nMonth'|@getFixedLabel}</th>
                        <th >8 {'nMonth'|@getFixedLabel}</th>
                        <th >9 {'nMonth'|@getFixedLabel}</th>
                        <th >10 {'nMonth'|@getFixedLabel}</th>
                        <th >11 {'nMonth'|@getFixedLabel}</th>
                        <th >12 {'nMonth'|@getFixedLabel}</th>
                        <th >{'SUM'|@getFixedLabel}</th>
                        <th >{'AMOUNT'|@getFixedLabel}</th>
                    </tr>
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.productname}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.costprice}</td>
                    <td>{$arr.cf_1425}</td>
                    <td>{$arr.productsheet}</td>
                    <td align="right">{$arr.T1}</td>                    
                    <td align="right">{$arr.T2}</td>
                    <td align="right">{$arr.T3}</td>
                    <td align="right">{$arr.T4}</td>
                    <td align="right">{$arr.T5}</td>
                    <td align="right">{$arr.T6}</td>
                    <td align="right">{$arr.T7}</td>
                    <td align="right">{$arr.T8}</td>
                    <td align="right">{$arr.T9}</td>
                    <td align="right">{$arr.T10}</td>
                    <td align="right">{$arr.T11}</td>
                    <td align="right">{$arr.T12}</td>
                    <td>{$arr.totalcount}</td>
                    <td>{$arr.amount}</td>                    
                    </tr>
                    {/foreach}
                {/if}
                {if $reportname eq 'SNOWBEARRPSL' }
                    <tr>
                        <th >{'TDOA'|@getFixedLabel}</th>
                        <th >{'SRPN'|@getFixedLabel}</th>
                        <th >{'EXPLAIN'|@getFixedLabel}</th>
                        <th >配件名称</th>
                        <th >产品类别</th>
                        <th >适用型号</th>
                        <th >{'TUOM'|@getFixedLabel}</th>
                        <th >{'QTY'|@getFixedLabel}</th>
                        <th >{'Theprice'|@getFixedLabel}</th>
                        <th >{'AMOUNT'|@getFixedLabel}</th>
                    </tr>
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.signed_data}</td>
                    <td>{$arr.subject}</td>
                    <td>{$arr.cf_1425}</td>
                    <td>{$arr.productsheet}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.usageunit}</td>
                    <td align="right">{$arr.quantity}</td>
                    <td align="right">{$arr.costprice}</td>
                    <td align="right">{$arr.amount}</td>                 
                    </tr>
                    {/foreach}
                {/if}
                {if $reportname eq 'SNOWBEARHNSRSR'}
                    <tr>
                        <th >{'area'|@getFixedLabel}</th>
                        <th >{'COMPANYPROVINCE'|@getFixedLabel}</th>
                        <th >{'COMPANYCITY'|@getFixedLabel}</th>
                        <th >{'AreaGravity'|@getFixedLabel}</th>
                        <th >1 {'nMonth'|@getFixedLabel}</th>
                        <th >2 {'nMonth'|@getFixedLabel}</th>
                        <th >3 {'nMonth'|@getFixedLabel}</th>
                        <th >4 {'nMonth'|@getFixedLabel}</th>
                        <th >5 {'nMonth'|@getFixedLabel}</th>
                        <th >6 {'nMonth'|@getFixedLabel}</th>
                        <th >7 {'nMonth'|@getFixedLabel}</th>
                        <th >8 {'nMonth'|@getFixedLabel}</th>
                        <th >9 {'nMonth'|@getFixedLabel}</th>
                        <th >10 {'nMonth'|@getFixedLabel}</th>
                        <th >11 {'nMonth'|@getFixedLabel}</th>
                        <th >12 {'nMonth'|@getFixedLabel}</th>
                        <th >{'SUM'|@getFixedLabel}</th>
                    </tr>
                    {*
                    {foreach from=$cticty key=keye item=arr}
                    {assign var="rowscount" value=1}
                        {foreach from=$arr key=key2 item=arr2}
                        {assign var="rowscount2" value=1}
                            {foreach from=$arr2 key=key3 item=arr3}
                                {if $key2 neq 'ROWcounts' && $key3 neq 'counts'}
                                    <tr>
                                        {if $rowscount eq 1}
                                            <td rowspan='{$arr.ROWcounts}'>{$keye}</td>
                                        {/if}
                                        {if $rowscount2 eq 1}
                                            <td rowspan='{$arr2.counts}' >{$key2}</td>
                                        {/if}
                                        <td >{$arr3}</td>
                                        
                                        {foreach from=$listValue key=key4 item=arr4 }
                                            {if $arr4.bill_city eq $arr3}
                                                <td> {$arr4.bili}</td> 
                                               <td> {$arr4.T1}</td> 
                                               <td> {$arr4.T2}</td> 
                                               <td> {$arr4.T3}</td> 
                                               <td> {$arr4.T4}</td>
                                               <td> {$arr4.T5}</td> 
                                               <td> {$arr4.T6}</td> 
                                               <td> {$arr4.T7}</td> 
                                               <td> {$arr4.T8}</td> 
                                               <td> {$arr4.T9}</td> 
                                               <td> {$arr4.T10}</td> 
                                               <td> {$arr4.T11}</td>
                                               <td> {$arr4.T12}</td> 
                                               <td> {$arr4.totalcount}</td> 
                                            {/if}
                                        {/foreach}
                                    </tr>
                                {assign var="rowscount" value=2}    
                                {assign var="rowscount2" value=2}                                    
                                {/if}
                            {/foreach}
                        {/foreach}
                    {/foreach}*}
                  {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                       <td> {$arr.bill_country}</td> 
                       <td> {$arr.bill_state}</td> 
                       <td> {$arr.bill_city}</td>
                       <td> {$arr.bili}</td> 
                       <td> {$arr.T1}</td> 
                       <td> {$arr.T2}</td> 
                       <td> {$arr.T3}</td> 
                       <td> {$arr.T4}</td>
                       <td> {$arr.T5}</td> 
                       <td> {$arr.T6}</td> 
                       <td> {$arr.T7}</td> 
                       <td> {$arr.T8}</td> 
                       <td> {$arr.T9}</td> 
                       <td> {$arr.T10}</td> 
                       <td> {$arr.T11}</td>
                       <td> {$arr.T12}</td> 
                       <td> {$arr.totalcount}</td> 
                    </tr>
                    {/foreach}  
                {/if} 
                {if $reportname eq 'Customerservicenumberofsummarytableoffaultarea'}
                    <tr>
                        <th>{'area'|@getFixedLabel}</th>
                        <th>{'COMPANYPROVINCE'|@getFixedLabel}</th>
                        <th>{'COMPANYCITY'|@getFixedLabel}</th>
                        <th>{'AreaGravity'|@getFixedLabel}</th>
                        <th>1 {'nMonth'|@getFixedLabel}</th>
                        <th>2 {'nMonth'|@getFixedLabel}</th>
                        <th>3 {'nMonth'|@getFixedLabel}</th>
                        <th>4 {'nMonth'|@getFixedLabel}</th>
                        <th>5 {'nMonth'|@getFixedLabel}</th>
                        <th>6 {'nMonth'|@getFixedLabel}</th>
                        <th>7 {'nMonth'|@getFixedLabel}</th>
                        <th>8 {'nMonth'|@getFixedLabel}</th>
                        <th>9 {'nMonth'|@getFixedLabel}</th>
                        <th>10 {'nMonth'|@getFixedLabel}</th>
                        <th>11 {'nMonth'|@getFixedLabel}</th>
                        <th>12 {'nMonth'|@getFixedLabel}</th>
                        <th>{'SUM'|@getFixedLabel}</th>
                    </tr>
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                       <td> {$arr.bill_country}</td> 
                       <td> {$arr.bill_state}</td> 
                       <td> {$arr.bill_city}</td>
                       <td> {$arr.bili}</td> 
                       <td> {$arr.T1}</td> 
                       <td> {$arr.T2}</td> 
                       <td> {$arr.T3}</td> 
                       <td> {$arr.T4}</td>
                       <td> {$arr.T5}</td> 
                       <td> {$arr.T6}</td> 
                       <td> {$arr.T7}</td> 
                       <td> {$arr.T8}</td> 
                       <td> {$arr.T9}</td> 
                       <td> {$arr.T10}</td> 
                       <td> {$arr.T11}</td>
                       <td> {$arr.T12}</td> 
                       <td> {$arr.totalcount}
                    </tr>
                    {/foreach} 
                    {*{foreach from=$cticty key=keye item=arr}
                    {assign var="rowscount" value=1}
                        {foreach from=$arr key=key2 item=arr2}
                        {assign var="rowscount2" value=1}
                            {foreach from=$arr2 key=key3 item=arr3}
                                {if $key2 neq 'ROWcounts' && $key3 neq 'counts'}
                                    <tr>
                                        {if $rowscount eq 1}
                                            <td rowspan='{$arr.ROWcounts}'>{$keye}</td>
                                        {/if}
                                        {if $rowscount2 eq 1}
                                            <td rowspan='{$arr2.counts}' >{$key2}</td>
                                        {/if}
                                        <td >{$arr3}</td>
                                        
                                        {foreach from=$listValue key=key4 item=arr4 }
                                            {if $arr4.bill_city eq $arr3}
                                                <td> {$arr4.bili}</td> 
                                               <td> {$arr4.T1}</td> 
                                               <td> {$arr4.T2}</td> 
                                               <td> {$arr4.T3}</td> 
                                               <td> {$arr4.T4}</td>
                                               <td> {$arr4.T5}</td> 
                                               <td> {$arr4.T6}</td> 
                                               <td> {$arr4.T7}</td> 
                                               <td> {$arr4.T8}</td> 
                                               <td> {$arr4.T9}</td> 
                                               <td> {$arr4.T10}</td> 
                                               <td> {$arr4.T11}</td>
                                               <td> {$arr4.T12}</td> 
                                               <td> {$arr4.totalcount}
                                               </td> 
                                            {/if}
                                        {/foreach}
                                    </tr>
                                {assign var="rowscount" value=2}    
                                {assign var="rowscount2" value=2}                                    
                                {/if}
                            {/foreach}
                        {/foreach}
                    {/foreach}*}
                    
                    
                {/if} 
                {if $reportname eq 'Customercomplaintanalysisreport' }
                    <tr>
                        <th >产品类别</th>
                        <th >{'Productseries'|@getFixedLabel}</th>
                        <th >{'Model'|@getFixedLabel}</th>
                        <th >{'PRODUCTNAME'|@getFixedLabel}</th>
                        <th >不良原因描述</th>
                        <th >{'CCN'|@getFixedLabel}</th>
                        <th >{'CCR'|@getFixedLabel}</th>
                        <th >{'POTS'|@getFixedLabel}</th>
                    </tr>
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.cf_1424}</td>
                    <td>{$arr.cf_1406}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.productsheet}</td>
                    <td>{$arr.cf_1419}</td>
                    <td>{$arr.counts}</td>
                    <td align="right">{$arr.bili}</td>
                    <td align="right"></td>
                    </tr>
                    {/foreach}
                {/if}        
                
                {if $reportname eq 'Customercomplaintanalysisreport2' ||$reportname eq 'Productcustomerservicenumberfailurestatistics2'||$reportname eq 'Summary400hotlinesinglestatistics'}
                    <tr>
                        <th >{'YEAR'|@getFixedLabel}</th>
                        <th >1{'nMonth'|@getFixedLabel}</th>
                        <th >2{'nMonth'|@getFixedLabel}</th>
                        <th >3{'nMonth'|@getFixedLabel}</th>
                        <th >4{'nMonth'|@getFixedLabel}</th>
                        <th >5{'nMonth'|@getFixedLabel}</th>
                        <th >6{'nMonth'|@getFixedLabel}</th>
                        <th >7{'nMonth'|@getFixedLabel}</th>
                        <th >8{'nMonth'|@getFixedLabel}</th>
                        <th >9{'nMonth'|@getFixedLabel}</th>
                        <th >10{'nMonth'|@getFixedLabel}</th>
                        <th >11{'nMonth'|@getFixedLabel}</th>
                        <th >12{'nMonth'|@getFixedLabel}</th>
                        <th >{'TOTAL'|@getFixedLabel}</th>
                    </tr>
                     <tr><td>{$year2}</td>
                    {foreach name=countRow from=$WinRate_values key=key item=arr}
                        <td style="background-color:#EEF7FF;">{$arr|@setNumberFormat}</td>
                        {/foreach}
                        <td>{$total2|@setNumberFormat}</td>
                    </tr>
                    <tr>
                        <td>{$year}</td>
                        {foreach name=countRow from=$WinRate_Potentials_values key=key item=arr}
                        <td style="background-color:#EEF7FF;">{$arr|@setNumberFormat}</td>
                        {/foreach}
                        <td>{$total|@setNumberFormat}</td>
                    </tr>
                   
                   <tr><td>同比增长</td>
                        {foreach name=countRow from=$values key=key item=arr}
                        <td style="background-color:#EEF7FF;">{$arr}</td>
                        {/foreach}
                        <td></td>
                    </tr>
                {/if} 
                {if $reportname eq 'Returnamountregionaldatasummaryreport'}
                    <tr>
                        <th width="60">{'area'|@getFixedLabel}</th>
                        <th width="60">{'COMPANYPROVINCE'|@getFixedLabel}</th>
                        <th width="60">{'COMPANYCITY'|@getFixedLabel}</th>
                        <!--th >{'admissibilitytype'|@getFixedLabel}</th-->
                        <th width="100">{'Customercategory'|@getFixedLabel}</th>
                        <th width="160">{'AccountName'|@getFixedLabel}</th>
                        <th >1 {'nMonth'|@getFixedLabel}</th>
                        <th >2 {'nMonth'|@getFixedLabel}</th>
                        <th >3 {'nMonth'|@getFixedLabel}</th>
                        <th >4 {'nMonth'|@getFixedLabel}</th>
                        <th >5 {'nMonth'|@getFixedLabel}</th>
                        <th >6 {'nMonth'|@getFixedLabel}</th>
                        <th >7 {'nMonth'|@getFixedLabel}</th>
                        <th >8 {'nMonth'|@getFixedLabel}</th>
                        <th >9 {'nMonth'|@getFixedLabel}</th>
                        <th >10 {'nMonth'|@getFixedLabel}</th>
                        <th >11 {'nMonth'|@getFixedLabel}</th>
                        <th >12 {'nMonth'|@getFixedLabel}</th>
                        <th >{'SUM'|@getFixedLabel}</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.bill_country}</td>
                    <td>{$arr.bill_state}</td>
                    <td>{$arr.bill_city}</td>
                    <!--td>{$arr.cf_1475}</td-->
                    <td>{$arr.account_type}</td>
                    <td>{$arr.accountname}</td>
                    <td align="right">{$arr.T1}</td>
                    <td align="right">{$arr.T2}</td>
                    <td align="right">{$arr.T3}</td>
                    <td align="right">{$arr.T4}</td>
                    <td align="right">{$arr.T5}</td>
                    <td align="right">{$arr.T6}</td>
                    <td align="right">{$arr.T7}</td>
                    <td align="right">{$arr.T8}</td>
                    <td align="right">{$arr.T9}</td>
                    <td align="right">{$arr.T10}</td>
                    <td align="right">{$arr.T11}</td>
                    <td align="right">{$arr.T12}</td>
                    <td align="right">{$arr.total}</td>
                    </tr>
                    {/foreach}
                {/if}       
                {if $reportname eq 'Returnnumberregionaldatasummaryreport'}
                    <tr>
                        <th >{'area'|@getFixedLabel}</th>
                        <th >{'COMPANYPROVINCE'|@getFixedLabel}</th>
                        <th >{'COMPANYCITY'|@getFixedLabel}</th>
                        <th >{'admissibilitytype'|@getFixedLabel}</th>
                        <th >{'Customercategory'|@getFixedLabel}</th>
                        <th >{'AccountName'|@getFixedLabel}</th>
                        <th >产品类型</th>
                        <th >{'Productseries'|@getFixedLabel}</th>
                        <th >{'Model'|@getFixedLabel}</th>
                        <th >{'PRODUCTNAME'|@getFixedLabel}</th>
                        <th >1 {'nMonth'|@getFixedLabel}</th>
                        <th >2 {'nMonth'|@getFixedLabel}</th>
                        <th >3 {'nMonth'|@getFixedLabel}</th>
                        <th >4 {'nMonth'|@getFixedLabel}</th>
                        <th >5 {'nMonth'|@getFixedLabel}</th>
                        <th >6 {'nMonth'|@getFixedLabel}</th>
                        <th >7 {'nMonth'|@getFixedLabel}</th>
                        <th >8 {'nMonth'|@getFixedLabel}</th>
                        <th >9 {'nMonth'|@getFixedLabel}</th>
                        <th >10 {'nMonth'|@getFixedLabel}</th>
                        <th >11 {'nMonth'|@getFixedLabel}</th>
                        <th >12 {'nMonth'|@getFixedLabel}</th>
                        <th >{'SUM'|@getFixedLabel}</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.bill_country}</td>
                    <td>{$arr.bill_state}</td>
                    <td>{$arr.bill_city}</td>
                    <td>{$arr.cf_1475}</td>
                    <td>{$arr.account_type}</td>
                    <td>{$arr.accountname}</td>
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.cf_1406}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.productsheet}</td>
                    <td align="right">{$arr.T1}</td>
                    <td align="right">{$arr.T2}</td>
                    <td align="right">{$arr.T3}</td>
                    <td align="right">{$arr.T4}</td>
                    <td align="right">{$arr.T5}</td>
                    <td align="right">{$arr.T6}</td>
                    <td align="right">{$arr.T7}</td>
                    <td align="right">{$arr.T8}</td>
                    <td align="right">{$arr.T9}</td>
                    <td align="right">{$arr.T10}</td>
                    <td align="right">{$arr.T11}</td>
                    <td align="right">{$arr.T12}</td>
                    <td align="right">{$arr.total}</td>
                    </tr>
                    {/foreach}
                {/if}
                {if $reportname eq 'Productcustomerservicenumberfailurestatistics'}
                    <tr>
                        <th width="100">产品类别</th>
                        <th width="100">产品系列</th>
                        <th width="100">产品名称</th>
                        <th width="100">{'Model'|@getFixedLabel}</th>
                        <th width="250">{'causefault'|@getFixedLabel}</th>
                        <th >1 {'nMonth'|@getFixedLabel}</th>
                        <th >2 {'nMonth'|@getFixedLabel}</th>
                        <th >3 {'nMonth'|@getFixedLabel}</th>
                        <th >4 {'nMonth'|@getFixedLabel}</th>
                        <th >5 {'nMonth'|@getFixedLabel}</th>
                        <th >6 {'nMonth'|@getFixedLabel}</th>
                        <th >7 {'nMonth'|@getFixedLabel}</th>
                        <th >8 {'nMonth'|@getFixedLabel}</th>
                        <th >9 {'nMonth'|@getFixedLabel}</th>
                        <th >10 {'nMonth'|@getFixedLabel}</th>
                        <th >11 {'nMonth'|@getFixedLabel}</th>
                        <th >12 {'nMonth'|@getFixedLabel}</th>
                        <th >{'Cumulative'|@getFixedLabel}</th>
                        <th >{'faultratio'|@getFixedLabel}%</th>
                        <th >{'Seriesproportion'|@getFixedLabel}%</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.cf_1406}</td>
                    <td>{$arr.productsheet}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.cf_1476}</td>
                    <td align="right">{$arr.T1}</td>
                    <td align="right">{$arr.T2}</td>
                    <td align="right">{$arr.T3}</td>
                    <td align="right">{$arr.T4}</td>
                    <td align="right">{$arr.T5}</td>
                    <td align="right">{$arr.T6}</td>
                    <td align="right">{$arr.T7}</td>
                    <td align="right">{$arr.T8}</td>
                    <td align="right">{$arr.T9}</td>
                    <td align="right">{$arr.T10}</td>
                    <td align="right">{$arr.T11}</td>
                    <td align="right">{$arr.T12}</td>
                    <td align="right">{$arr.total}</td>
                    <td align="right">{$arr.total2}</td>
                    <td align="right">{$arr.total3}</td>                    
                    </tr>
                    {/foreach}
                {/if}                      
                  {if $reportname eq 'Analysisofthetablecustomerservicefailure'}
                    <tr>
                        <th width="100">产品类别</th>
                        <th width="100">产品系列</th>
                        <th width="100">产品名称</th>
                        <th width="100">{'Model'|@getFixedLabel}</th>
                        <th width="250">受理类型</th>
                        <th >1 {'nMonth'|@getFixedLabel}</th>
                        <th >2 {'nMonth'|@getFixedLabel}</th>
                        <th >3 {'nMonth'|@getFixedLabel}</th>
                        <th >4 {'nMonth'|@getFixedLabel}</th>
                        <th >5 {'nMonth'|@getFixedLabel}</th>
                        <th >6 {'nMonth'|@getFixedLabel}</th>
                        <th >7 {'nMonth'|@getFixedLabel}</th>
                        <th >8 {'nMonth'|@getFixedLabel}</th>
                        <th >9 {'nMonth'|@getFixedLabel}</th>
                        <th >10 {'nMonth'|@getFixedLabel}</th>
                        <th >11 {'nMonth'|@getFixedLabel}</th>
                        <th >12 {'nMonth'|@getFixedLabel}</th>
                        <th >{'Cumulative'|@getFixedLabel}</th>
                        <th >{'faultratio'|@getFixedLabel}%</th>
                        <th >{'Seriesproportion'|@getFixedLabel}%</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                    <tr>
                    {else}
                    <tr class="bj">
                    {/if}
                    <td>{$arr.productcategory}</td>
                    <td>{$arr.cf_1406}</td>
                    <td>{$arr.productsheet}</td>
                    <td>{$arr.productname}</td>
                    <td>{$arr.cf_1410}</td>
                    <td align="right">{$arr.T1}</td>
                    <td align="right">{$arr.T2}</td>
                    <td align="right">{$arr.T3}</td>
                    <td align="right">{$arr.T4}</td>
                    <td align="right">{$arr.T5}</td>
                    <td align="right">{$arr.T6}</td>
                    <td align="right">{$arr.T7}</td>
                    <td align="right">{$arr.T8}</td>
                    <td align="right">{$arr.T9}</td>
                    <td align="right">{$arr.T10}</td>
                    <td align="right">{$arr.T11}</td>
                    <td align="right">{$arr.T12}</td>
                    <td align="right">{$arr.total}</td>
                    <td align="right">{$arr.total2}</td>
                    <td align="right">{$arr.total3}</td>                    
                    </tr>
                    {/foreach}
                {/if}                                                        
                </tbody>
            </table>
            
        </div>
    </div>
    
    {if $reportname eq 'Productcustomerservicenumberfailurestatistics3'||$reportname eq 'Customercomplaintanalysisreport2'||$reportname eq 'Productcustomerservicenumberfailurestatistics2'||$reportname eq 'Summary400hotlinesinglestatistics'}
    <script type='text/javascript' src='modules/GraphicalReports/GraphicalReports.js' language="javascript"></script>
<div class="List3Box" style="padding-top:15px;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="Tdcenter" valign="top">
    	<div class="DivC">
            <div style="border:none;" class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG}
                </div>
            </div>
        </div>
    </td>
  </tr>
</table>
</div>
{/if}
</div>
{if $reportname eq 'SNOWBEARRPSL' || $reportname eq 'Customercomplaintanalysisreport'}
<script type="text/javascript">
{literal}
   ld(document).ready(function() {
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
      });
   });
{/literal}
</script>
{/if}
{if  $reportname eq 'Customercomplaintanalysisreport'}
<script type="text/javascript">
    window.onresize = function(){ldelim}
        if(document.getElementById('div_select_user')!=undefined&&document.getElementById('div_select_user').style.display!='none'){ldelim}
                           
                            CfnDropDownUsers(getObj('search_text'),'div_select_user',18);BodyClick2(getObj('search_text'),'div_select_user');
                        {rdelim}

        if(document.getElementById('div_select_account')!=undefined&&document.getElementById('div_select_account').style.display!='none'){ldelim}
                            
                            CfnDropDownUsers(getObj('search_text2'),'div_select_account',18);BodyClick2(getObj('search_text2'),'div_select_account');
                        {rdelim}

        if(document.getElementById('div_select_Sector')!=undefined&&document.getElementById('div_select_Sector').style.display!='none'){ldelim}
                            
                            CfnDropDownUsers(getObj('search_text3'),'div_select_Sector',18);BodyClick2(getObj('search_text3'),'div_select_Sector');
                        {rdelim}

        if(document.getElementById('div_select_Salesman')!=undefined&&document.getElementById('div_select_Salesman').style.display!='none'){ldelim}
                            
                            CfnDropDownUsers(getObj('search_text4'),'div_select_Salesman',18);BodyClick2(getObj('search_text4'),'div_select_Salesman');
                        {rdelim}
                    {rdelim} 
 </script>
 {/if}
</body>
</html>