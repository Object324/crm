<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
</script>
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
    <div id="status" style="position:absolute;display:none;left:850px;top:95px;height:27px;white-space:nowrap;"></div>
<title>项目利润明细表</title>
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
        <h1>项目利润明细表</h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                        <input type="hidden" value="RentCollectionReport" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$year}" name="year"/>
                    
                    <input type="hidden" value="" name="export"  id="export"/>  
                     {$basicfilterHtml}
                    <label class="Name" >  
                    
                	<span>日期选择:</span>&nbsp;
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
                        <span>名称:</span>
                            <input id="subject" class="date" name="subject" value="{$subject}"/>
                    </label>  
                   	<label class="Name">    
                    <span>  查看范围:</span>
                    <span>
                        <label>{include file='Comprehensivereport/SmownerSearchScope.tpl'}</label>
                    </span>   
                     </label>     
                    <label class="Name">      
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="search_ProjectSchedule('view');"/>
                    &nbsp;&nbsp;
                    <input class="createauto b_radius3" id="btnOK_E" onclick="search_ProjectSchedule('export');" type="button" value="{'EXPORT'|@getFixedLabel}" />
                    </label>    </label>                        
                </form>
                 
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center"  id="checksms">
    {include file="Comprehensivereport/ProjectSchedulecontent.tpl"}
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