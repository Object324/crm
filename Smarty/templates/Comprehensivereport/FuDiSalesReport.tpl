<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css">
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript">
	var ld = $;
	ld.noConflict();
</script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/reminds/reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售报表</title>
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
a {
color: #0070ba;
}

</style>
{/literal}

<body>
 <div id="status" style="position:absolute;display:none;left:850px;top:95px;height:27px;white-space:nowrap;"></div>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>销售报表</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                        <input type="hidden" value="FuDiSalesReport" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    
                    <input type="hidden" value="" name="export"  id="export"/>    
                   	<label class="Name">
                        <span>城市:</span>
                        <select id="cf_1471value" class="Select" name="cf_1471value">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1471}
                             <option value ="{$userid}" {if $cf_1471value eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                    
                   	<label class="Name">
                        <span>项目名称:</span>
                        <span>
                        <input class="input_text" id="cf_1472value" name="cf_1472value" value="{$cf_1472value}" type="text" />
                        </span> 
                    </label>  
                    </br></br>
                   	<label class="Name">
                        <span>资产类型:</span>
                        <select id="productcategoryvalue" class="Select" name="productcategoryvalue">  
                        <option value=''>-</option>
                            {foreach item=userid from=$productcategory}
                             <option value ="{$userid}" {if $productcategoryvalue eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label>  
                   	<label class="Name">    
                    <span>  查看范围:</span>
                    <span>
                        <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    </span>   
                     </label>       
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="set_noexport();Report_form_queryValidate();"/>
                    &nbsp;&nbsp;
                    <input class="createauto b_radius3" id="btnOK_E" onclick="set_export();Report_form_queryValidate();" type="button" value="{'EXPORT'|@getFixedLabel}" />
           
                    </label>                           
                </form>
                 
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                        <tr>
                        <td >合计</td>
                        <td ></td>
                        <td ></td>
                        <td ></td>
                        <td  align="right">{$allValue.quantity}</td>
                        <td  align="right">{$allValue.cf_1470|@setNumberFormat:4}</td>
                        <td  align="right">{$allValue.taxprice|@setNumberFormat:4}</td>
                        <td  align="right">{$allValue.cf_1577}</td>
                        <td align="right">{$allValue.cf_1568}</td>
                        <td align="right">{$allValue.cf_1576}</td>
                        <td  align="right">{$allValue.cf_1575}</td>
                    </tr>
                    <tr>
                        <th >序号</th>
                        <th >城市</th>
                        <th >项目名称</th>
                        <th >资产类型</th>
                        <th >已售数量</th>
                        <th >已售面积/平米</th>
                        <th >已售金额（万元）</th>
                        <th >合同已签数量</th>
                        <th >全款已付数量</th>
                        <th >已交付数量</th>
                        <th >已交易数量</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    {if $smarty.foreach.countRow.iteration % 2 == 1}
                    <tr class="Hover">
                    {else}
                    <tr class="Bj Hover">
                    {/if}
                    <td>{$smarty.foreach.countRow.index+1}</td>
                    <td>{$arr.cf_1471}</td>
                    <td>{$arr.cf_1472}</td>
                    <td>{$arr.productcategory}</td>
                    <td align="right">{$arr.quantity}</td>
                    <td align="right">{$arr.cf_1470}</td>
                    <td align="right">{$arr.taxprice}</td>
                    <td align="right">{$arr.cf_1577}</td>   
                    <td align="right">{$arr.cf_1568}</td>  
                    <td align="right">{$arr.cf_1576}</td>  
                    <td align="right">{$arr.cf_1575}</td>          
                    </tr>
                    {/foreach}
               </tbody>
            </table>
            
        </div>
    </div>
    

</div>


</body>
</html>