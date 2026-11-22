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
<title>运营报表</title>
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
        <h1>运营报表</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                    <input type="hidden" value="OperationsReport" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    
                    <input type="hidden" value="" name="export"  id="export"/>    
                     {$basicfilterHtml}
                <label class="Name" style="margin:4px 0px 0px 10px;display:inline-block;">
                	<span>充值到账户日期:</span>&nbsp;
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>                
           </label>
           </br></br></br>
                {$basicfilterHtml2}
                	<label class="Name" style="margin:4px 0px 0px 10px;display:inline-block;">
                    <span>债权匹配日期:</span>&nbsp;
                        <input id="begin_date2" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date2}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>                 
                    </label>
        
           </br></br></br>
                   	<label class="Name">
                        <span>姓名:</span>
                        <input id="accountname" class="date" name="accountname" value="{$accountname}"/>
                    </label>  
                    
                   	<label class="Name">
                        <span>身份证号:</span>
                            <input id="cf_1484" class="date" name="cf_1484" value="{$cf_1484}"/>
                    </label>  
                    
                   	<label class="Name">
                        <span>计划名称:</span>
                            <input id="productname" class="date" name="productname" value="{$productname}"/>
                    </label>  
                    
                   	<label class="Name">
                        <span>债权匹配状态:</span>               
                    <select id="cf_1498" class="Select" name="cf_1498">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1522}
                             <option value ="{$userid}" {if $cf_1522 eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label> 
                   	<label class="Name">
                        <span>还款方式:</span>
                         <select id="cf_1494" class="Select" name="cf_1494">  
                        <option value=''>-</option>
                            {foreach item=userid from=$cf_1532}
                             <option value ="{$userid}" {if $cf_1532 eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                    </select> 
                    </label> 
                    </br></br></br>
                   	<label class="Name">    
                    <span>  审批状态:</span>
                        <label><input name="approvestatus" type="checkbox" value="审批中" />审批中 </label> 
                        <label><input name="approvestatus" type="checkbox" value="已批准" />已批准 </label> 
                        <label><input name="approvestatus" type="checkbox" value="未提交" />未提交 </label> 
                        <label><input name="approvestatus" type="checkbox" value="已驳回" />已驳回 </label> 
                        <label><input name="approvestatus" type="checkbox" value="已拒绝" />已拒绝 </label> 
                    </label>   </br></br></br>       
                   	<label class="Name">    
                    <span>  查看范围:</span>
                    <span>
                        <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    </span>   
                     </label>       
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="search_Operations('view');"/>
                    &nbsp;&nbsp;
                    <input class="createauto b_radius3" id="btnOK_E" onclick="search_Operations('export');" type="button" value="{'EXPORT'|@getFixedLabel}" />
                    </label>                           
                </form>
                 
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center"  id="checksms">
    {include file="Comprehensivereport/OperationsReportcontent.tpl"}
    </div>
    

</div>


</body>
<script type="text/javascript">
{literal}
   ld(document).ready(function() {
      ld('#begin_date2').daterangepicker(null, function(start, end, label) {
      });
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
      });
   });
 var tolabel = "{'TO'|@getFixedLabel}";
    ld(document).ready(function() {
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
        
      });
		setReportTime(ld('#begin_date').val());
   });
    ld(document).ready(function() {
      ld('#begin_date2').daterangepicker(null, function(start, end, label) {
        
      });
		setReportTime(ld('#begin_date2').val());
   });
   function daterangeBackEvent(idstr){
		setReportTime(ld('#'+idstr).val());
   }
   function setReportTime(datetime){
	   var dt = datetime.split(' ');
	   var dtv = "( "+dt[0]+' '+tolabel+' '+dt[2]+" )";
	   ld('#report_time_titme').html(dtv);
   }
{/literal}
</script>
</html>