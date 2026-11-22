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
<title>{'HBRREPORT'|@getFixedLabel}</title>
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
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 input.Input_time { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 input.Bjffd { background:#ffd;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 input.Input_Text { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 .Select { float:left; width:150px; height:22px; line-height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px;}
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

.Forms-Forms { width:100%;font-family:Arial, Helvetica, sans-serif;}
.Forms-Forms .tableName{ color: #999999;font-family: 黑体;font-size: 15pt;margin-bottom:10px;}
.Forms-Forms  table { width:100%; border-top:1px solid #dedede; border-left:1px solid #dedede; border-collapse: collapse;}
.Forms-Forms  table tr td{ padding:0 5px; border-bottom:1px solid #dedede; border-right:1px solid #dedede; margin:0; font-size:12px; line-height:30px; }
.T-Color{ background:#7B95C7;text-align:center;font-weight:bold;color:#fff;}
.Forms-Forms  table tr td.Bgimg { background:url(thead_bg.png) repeat-x; font-size:14px; font-weight:bold; color:#555;}
.Forms-Forms  table tr td.Alone { background:#c0d3df;}
.listTableRowBlank2{text-indent:24px;}
.listTableRowBlank4{text-indent:60px;}
.listTableRowRight{text-align:right;}
.DivList0 table td.Roleno{white-space: nowrap;}
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
                    <input type="hidden" value="HBRreports" name="action">
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
                      <span>{'ROLES'|@getFixedLabel}: &nbsp;</span>
                        <select style="width:100px;" name="rolename" class="Select">
                            <option value="all">{'ALL'|@getFixedLabel}</option>
                        {foreach from=$rolename key=key item=arr}
                            <option value="{$key}" {if $rolenames eq $key}selected="selected"{/if}>{$arr}</option>
                        {/foreach}
                        </select>
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
                        <th >{'ROLES'|@getFixedLabel}</th>
                        <th >{'amountofcustomervisits'|@getFixedLabel}</th>
                        <th >{'amountofnewcustomers'|@getFixedLabel}</th>
                        <th >{'numberofnewcustomersdeal'|@getFixedLabel}</th>
                        <th >{'NewCustomerTurnover'|@getFixedLabel}</th>
                        <th >{'Newcustomerturnoveraccountedfor'|@getFixedLabel}</th>
                        <th >{'Oldcustomerturnover'|@getFixedLabel}</th>
                        <th >{'Oldcustomerturnovernumber'|@getFixedLabel}</th>
                        <th >{'totalnumberoftransactions'|@getFixedLabel}</th>
                        <th >{'totalturnover'|@getFixedLabel}</th>       
                    </tr>
                    {foreach name=countRow from=$roleList key=key item=arr}
                        {foreach name=countRow2 from=$arr.arrs key=key2 item=arr2}
                            <tr>
                                 
                                {if $arr.1 eq 2}
                                    <td class="listTableRow Roleno" {if (($arr2.gcount)%2 == 1) || (($arr2.fg)%2 == 1)}style="background-color:#EEF7FF;"{/if}><span style="padding-left:15px;">{$arr2.rolename}</span></td>
                                {elseif $arr.1 eq 3}
                                    <td class="listTableRow Roleno" {if (($arr2.gcount)%2 == 1) || (($arr2.fg)%2 == 1)}style="background-color:#EEF7FF;"{/if}><span style="padding-left:30px;">{$arr2.rolename}</span></td>
                                {elseif $arr.1 eq 4}
                                    <td class="listTableRow Roleno" {if (($arr2.gcount)%2 == 1) || (($arr2.fg)%2 == 1)}style="background-color:#EEF7FF;"{/if}><span style="padding-left:40px;">{$arr2.rolename}</span></td>
                                {elseif $arr.1 eq 5}
                                    <td class="listTableRow Roleno" {if (($arr2.gcount)%2 == 1) || (($arr2.fg)%2 == 1)}style="background-color:#EEF7FF;"{/if}><span style="padding-left:50px;">{$arr2.rolename}</span></td>
                                {else}
                                    <td class="listTableRow Roleno" {if (($arr2.gcount)%2 == 1) || (($arr2.fg)%2 == 1)}style="background-color:#EEF7FF;"{/if}>{$arr2.rolename}</td>
                                {/if}
                                
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.KeHuBaiFangLiang}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.XinZengKeHuLiang}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.XinKeHuChengJiaoLiang}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.XinKeHuChengJiaoEn}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.XinKeHuCengJiaoEnZhanBi}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.LaoKeHuChengJiaoEn}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.LaoKeHuChengJiaoLiang}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.ZongChengJiaoLiang}</td>
                                <td class="listTableRowRight"{if ($arr2.gcount)%2 == 1}style="background-color:#EEF7FF;"{/if}>{$arr2.ZongChengJiaoEn}</td>
                            </tr>
                        {/foreach}
                    {/foreach}
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>