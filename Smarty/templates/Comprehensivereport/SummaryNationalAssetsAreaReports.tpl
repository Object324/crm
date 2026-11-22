<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
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
<title>首页显示</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:8px;}
.DivBox_top { padding-left:2.5%; height:45px;}
.DivBox_top h1 { float:left; font-size:20px; color:#666; line-height:30px;}
/*---查找----*/
.Find_box { float:left; width:100%; padding: 0 2.5% 8px;box-sizing: border-box;}
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
.DivBox_Center .DivList0 { float:left; width:100%; padding:0 2.5% 15px; box-sizing:border-box;}
.DivBox_Center .DivList0 table { background:#bbb;}
.DivBox_Center .DivList0 table th,.DivBox_Center .DivList0 table td { background:#fff; font-size:13px; color:#666; line-height:24px; padding:3px 10px;}
.DivBox_Center .DivList0 table th { background:#C7D9EE; padding:5px 10px;color: #2a66c5;}
.DivBox_Center .DivList0 table .head th { background:#C7D9EE url(themes/softed/images/thbj.png) repeat-x left 0px; color:#2A66C5;/* font-weight:lighter;*/}
.DivBox_Center .DivList0 table tr.bj td{background-color:#EEF7FF;}

.cartogram th{text-align:left;padding:20px 0  20px 7%;}
.Tdcenter{margin-bottom:5px;width:450px;}
.clear{clear:both;overflow:hidden;height: 10px;}
</style>
{/literal}

<body>

<div class="DivBox">
   
    <div class="DivBox_top">
        <h1>{$reportname}</h1>
    </div>

     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr class="head">
                        <th ></th>
                        {foreach  name=countRow from=$cf_1471 key=key item=arr}
                        <th >{$key}</th>
                        {/foreach}<th >总计</th>
                    </tr>
                    {foreach name=countRow from=$WinRate_values key=key item=arr}
                        {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                            <tr>
                        {else}
                            <tr class="bj">
                        {/if}
                        <td>{$key}</td>
                    {foreach from=$arr key=key2 item=arr2}
                        <td>{if $arr2 eq ''||$arr2 eq '0.00'}-{else}{$arr2|@setNumberFormat:4}{/if}</td>
                    {/foreach}
                    </tr>
                    {/foreach}
               

                                                                   
                </tbody>
            </table>
            
        </div>
    </div>

<div class="List3Box" style="padding-top:15px;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="cartogram">
  <tr>
  <th id='zhutus'>
  显示类型：
    <a href="javascript:changeshow('zhutu','bintu')">饼图</a>
    <a href="javascript:changeshow('bintu','zhutu')">柱图</a>
  </th>
  <th id='bintus' style="display:none;">
  显示类型：
    <a href="javascript:changeshow('zhutu','bintu')">饼图</a>
    <a href="javascript:changeshow('bintu','zhutu')">柱图</a>
  </th>
  <th id='zhutu2s'>
  显示类型：
    <a href="javascript:changeshow('zhutu2','bintu2')">饼图</a>
    <a href="javascript:changeshow('bintu2','zhutu2')">柱图</a>
  </th>
  <th id='bintu2s' style="display:none;">
  显示类型：
    <a href="javascript:changeshow('zhutu2','bintu2')">饼图</a>
    <a href="javascript:changeshow('bintu2','zhutu2')">柱图</a>
  </th>
  </tr>
  <tr>
    <td width="48%" align="center" id='bintu'>
    	<div class="Tdcenter">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG}
                </div>
            </div>
        </div>
    </td>
    
    <td width="48%" align="center"  id='zhutu' style="display:none;">
    	<div class="Tdcenter">
            <div style="border:none;" class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG2}
                </div>
            </div>
        </div>
    </td>
    
    <td width="48%" align="center"  id='bintu2' >
    	<div class="Tdcenter">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG3}
                </div>
            </div>
        </div>
    </td>

    <td width="48%" align="center" id='zhutu2' style="display:none;">
    	<div class="Tdcenter">
            <div style="border:none;" class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG4}
                </div>
            </div>
        </div>
    </td>
  </tr>

</table>
</div>

</div>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>全国资产货值汇总表（单位：万元）</h1>
    </div>

     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr class="head">
                        <th ></th>
                        {foreach  name=countRow from=$cf_1471 key=key item=arr}
                        <th >{$key}</th>
                        {/foreach}<th >总计</th>
                    </tr>
                    {foreach name=countRow from=$Wincash_values key=key item=arr}
                        {if $smarty.foreach.countRow.iteration % 2 eq '1'}
                            <tr>
                        {else}
                            <tr class="bj">
                        {/if}
                        <td>{$key}</td>
                    {foreach from=$arr key=key2 item=arr2}
                        <td>{if $arr2 eq ''||$arr2 eq '0.0000'}-{else}{$arr2|@setNumberFormat:4}{/if}</td>
                    {/foreach}
                    </tr>
                    {/foreach}                                          
                </tbody>
            </table>
            
        </div>
    </div>

<div class="List3Box" style="padding-top:15px;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="cartogram">
  <tr>
  <th id='zhutu3s'>
  显示类型：
  <a href="javascript:changeshow('zhutu3','bintu3')">饼图</a>
  <a href="javascript:changeshow('bintu3','zhutu3')">柱图</a>
  </th>
  <th id='bintu3s' style="display:none;">
  显示类型：
    <a href="javascript:changeshow('zhutu3','bintu3')">饼图</a>
    <a href="javascript:changeshow('bintu3','zhutu3')">柱图</a>
  </th>
  <th id='zhutu4s'>
  显示类型：
  <a href="javascript:changeshow('zhutu4','bintu4')">饼图</a>
  <a href="javascript:changeshow('bintu4','zhutu4')">柱图</a>
  </th>
  <th id='bintu4s' style="display:none;">
  显示类型：
  <a href="javascript:changeshow('zhutu4','bintu4')">饼图</a>
  <a href="javascript:changeshow('bintu4','zhutu4')">柱图</a>
  </th>
  </tr>
  <tr>
    <td width="48%" align="center" id='bintu3'>
    	<div class="Tdcenter">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG5}
                </div>
            </div>
        </div>
    </td>
    
    <td width="48%" align="center"  id='zhutu3' style="display:none;">
    	<div class="Tdcenter">
            <div style="border:none;" class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG6}
                </div>
            </div>
        </div>
    </td>
    
    <td width="48%" align="center"  id='bintu4' >
    	<div class="Tdcenter">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG7}
                </div>
            </div>
        </div>
    </td>

    <td width="48%" align="center"  id='zhutu4' style="display:none;">
    	<div class="Tdcenter">
            <div style="border:none;" class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG8}
                </div>
            </div>
        </div>
    </td>
  </tr>

</table>
</div>

</div>
 <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" id="Report_form_query" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                        <input type="hidden" value="SummaryNationalAssetsAreaReports" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$year}" name="year"/>
					{if $RETURN_MODULE eq 'home'}
						<input type="hidden" value="{$RETURN_MODULE}" id="return_mypage" name="return_mypage"/>
					{/if}
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
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    </label>                           
                </form>
                 
            </td>
          </tr>
        </table>
     </div>
     <div class="clear"></div>
     <!--查找条件 end-->
<div class="DivBox">
    <div class="DivBox_top">
        <h1>全国各城市存量年去化率(按所有可售资产计算）</h1>
    </div>

     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr class="head"><th ></th>
                        {foreach  name=countRow from=$qucunhua key=key item=arr}
                        <th >{$key}</th>
                        {/foreach}
                    </tr>
                     <tr><th >当年存量<br />(单位：平米)</th>
                        {foreach name=countRow from=$qucunhua key=key item=arr}
                            <td>{$arr.cunliang|@setNumberFormat:4}</td>
                        {/foreach}
                    </tr>
                     <tr><th >当年去化<br />(单位：平米)</th>
                        {foreach name=countRow from=$qucunhua key=key item=arr}
                            <td>{$arr.quhua|@setNumberFormat:4}</td>
                        {/foreach}
                    </tr>
                    <tr><th >去化比例</th>
                        {foreach name=countRow from=$qucunhua key=key item=arr}
                            <td>{$arr.quhuabili*100|@setNumberFormat}%</td>
                        {/foreach}
                    </tr>                                               
                </tbody>
            </table>
            
        </div>
    </div>

<div class="List3Box" style="padding-top:15px;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="Tdcenter" id='bintu3'>
    	<div class="DivC">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG9}
                </div>
            </div>
        </div>
    </td>
  </tr>

</table>
</div>

</div>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>各城市存量租赁比例表（按租赁）</h1>
    </div>

     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr class="head"><th ></th>
                        {foreach  name=countRow from=$zupinbili key=key item=arr}
                        <th >{$key}</th>
                        {/foreach}
                    </tr>
                     <tr><th >存量资产<br />(单位：平米)</th>
                        {foreach name=countRow from=$zupinbili key=key item=arr}
                            <td>{$arr.cunliang|@setNumberFormat:4}</td>
                        {/foreach}
                    </tr>
                     <tr><th >已租<br />(单位：平米)</th>
                        {foreach name=countRow from=$zupinbili key=key item=arr}
                            <td>{$arr.quhua|@setNumberFormat:4}</td>
                        {/foreach}
                    </tr>
                    <tr><th >租赁比例</th>
                        {foreach name=countRow from=$zupinbili key=key item=arr}
                            <td>{$arr.quhuabili*100|@setNumberFormat}%</td>
                        {/foreach}
                    </tr>                                               
                </tbody>
            </table>
            
        </div>
    </div>

<div class="List3Box" style="padding-top:15px;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="Tdcenter" id='bintu3'>
    	<div class="DivC">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG10}
                </div>
            </div>
        </div>
    </td>
  </tr>

</table>
</div>

</div>

<div class="DivBox">
    <div class="Find_box">
        <h1>项目去化率表</h1>
</br>
                	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                    <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                    <input type="hidden" value="SummaryNationalAssetsAreaReports" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$year}" name="year"/>  
                    <input id="begin_date" readonly="readonly" type="hidden" class="date" name="begin_date" value="{$begin_end_date}" style="width:150px;"/>
                        
                    
                    <input type="hidden" value="true" name="Report_form_query"/>
                   	<label class="Name">
                        <span>资产类型:</span>
                        <select id="productcategoryvalue" class="Select" name="productcategoryvalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$productcategory2}
                             <option value ="{$userid}" {if $productcategoryvalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="submit_productcategory()"/>
                    </label> 
                    </form>
    </div>
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr class="head">
                        <th ></th>
                        {foreach  name=countRow from=$xiangmuquhua key=key item=arr}
                        <th >{$key}</th>
                        {/foreach}
                    </tr>
                     <tr>
                        <th >原有存量(单位：平米)</th>
                        {foreach name=countRow from=$xiangmuquhua key=key item=arr}
                            <td>{$arr.cunliang|@setNumberFormat:4}</td>
                        {/foreach}
                    </tr>
                     <tr>
                        <th >已去化存量(单位：平米)</th>
                        {foreach name=countRow from=$xiangmuquhua key=key item=arr}
                            <td>{$arr.quhua|@setNumberFormat:4}</td>
                        {/foreach}
                    </tr>
                    <tr>
                        <th >去化比例</th>
                        {foreach name=countRow from=$xiangmuquhua key=key item=arr}
                            <td>{$arr.quhuabili*100|@setNumberFormat}%</td>
                        {/foreach}
                    </tr>                                               
                </tbody>
            </table>
            
        </div>
    </div>

<div class="List3Box" style="padding-top:15px;">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="Tdcenter" id='bintu3'>
    	<div class="DivC">
            <div style="border:none;"  class="PromptDiv1">
                <div id="GraphicalReports">
                    {$IMG11}
                </div>
            </div>
        </div>
    </td>
  </tr>

</table>
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