<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script type="text/javascript" src="jscalendar/calendar.js"></script>
<script type="text/javascript" src="jscalendar/calendar-setup.js"></script>
<script type="text/javascript" src="jscalendar/lang/calendar-zh.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
</script>
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售统计表报表</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:5px;}
.DivBox_top { width:100%; height:35px;}
.DivBox_top h1 { float:left; font-size:20px; color:#000; line-height:30px;}

.DivBox_Center { width:120%; padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}

.TableList{ font-size:12px; color:#666; background-color:#ddd;}
.TableList tr th{/*white-space: nowrap;*/padding: 0 3px; height:30px; line-height:30px; background-color:#efefef}
.TableList tr td{ height:30px; line-height:30px; padding:0px 3px; background:#FFF;}/* 默认背景白色 */

.TableList tr.Bj td{ background:#f8f8f8;}/* 默认隔行背景颜色 */
.TableList td.BgcolorF6{ background:#f6f6f6;}/*合并行背景颜色*/
.TableList tr.Hover:hover td{background:#FAFFD1;}/* 鼠标经过时候背景颜色 */
.TableList tr.ALLTotal td{ background: #EEEEEE;}/*合计背景颜色*/

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
#page{font:12px/16px arial}

#page span{float:left;margin:0px 3px;}
#page a{margin:0 3px;border:1px solid ddd;padding:3px 7px; text-decoration:none;color:#666}

#page a.now_page,#page a:hover{color:#fff;background:#05c}
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>销售统计表报表 </h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                    <input type="hidden" value="dingjiereports" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <!--input type="hidden" value="" name="ajaxExport" id="ajaxExport"/-->
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
                    {*
                    <label class="Name"><span>{'CLOSING'|@getFixedLabel}:</span>
                        <input id="end_date" class="date" name="end_date" value="{$end_date}"/>
                        <input id="bd_end_date" type="hidden" name="bd_end_date"/>
                        <img id="bd_jscal_trigger_date_end" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />
                        <script id="massedit_calendar_date_end" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "end_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "bd_jscal_trigger_date_end", singleClick : true, step : 1
                           	{rdelim})
                        </script>
                    </label>
                    *}
                    <label class="Name">
                        <span>客户名称:</span>
                            <input  class="date" name="accountname" value="{$accountname}"/>
                        </span>
                    </label>
                    <label class="Name">
                        <span>订单号码:</span>
                            <input  class="date" name="salesno" value="{$salesno}"/>
                        </span>
                    </label>
                    <label class="Name">
                            <span>业务员:</span>
                            <input type="text"   class="date" name="search_text" id="search_text" value="{$receiverid}" style="width:230px" onclick="CfnDropDownUsers(this,'div_select_user',18);BodyClick2(this,'div_select_user');" readonly/>
                            <span id="assign_user_id">
                                <div id="div_select_user" style="overflow-y:auto;overflow-x: hidden;height:100px;background:white;border: 1px solid #ccc; padding:5px;display:none;position:absolute;z-index:9999;width:230px;margin-top:29px;">
                                    <table width="100%" cellpadding="0" border="0" cellspacing="0" style="background:white;">
                                        {assign var=count_num value=0}
                                        {assign var=colum_num value=1}
                                        
                							{foreach key=username item=userid from=$ulist}
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
                                                        {if $receiverids eq $userid}
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
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_form_queryValidate();"/>
                    <a  href="index.php?module=Comprehensivereport&action=dingjiereports&ajaxExport=yes&accountname={$accountname}&search_text={$receiverid}&salesno={$salesno}&begin_date={$begin_dateget} " class="saveauto export">{'EXPORT'|@getFixedLabel}</a>
                    </label>                                    
                </form>
                 
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0" >
        <div id="page" align="right"> {$page_arr}</div></br></br>
        <span style="font-size:14px;">总金额:</span><span style="font-size:14px;">{$listvalueall.amount|@setNumberFormat}</span>
        &nbsp;&nbsp;&nbsp;<span style="font-size:14px;">毛利率:</span><span style="font-size:14px;">{$listvalueall.price*100|@setNumberFormat}%</span>
        &nbsp;&nbsp;&nbsp;<span style="font-size:14px;">杂费合计:</span><span style="font-size:14px;">{$listvalueall.com|@setNumberFormat}</span>
        &nbsp;&nbsp;&nbsp;<span style="font-size:14px;">总成本:</span><span style="font-size:14px;">{$listvalueall.subtotal|setNumberFormat}</span>
        &nbsp;&nbsp;&nbsp;<span style="font-size:14px;">总税率折价:</span><span style="font-size:14px;">{$listvalueall.discount|setNumberFormat}</span>
        </br></br>
            <table width="{$COUNT*2*8+100}%" class="TableList" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                       <th align="center">序号</th>
                       <th align="center">业务员</th>
                       <th align="center">订单日期</th>
                       <th align="center">客户</th>
                       <th align="center">订单号码</th>
                       <th align="center">品名</th>
                       <th align="center">品号</th>
                       <th align="center">数量</th>
                       <th align="center">币种</th>
                       <th align="center">汇率</th>
                       <th align="center">单价</th>
                       <th align="center">杂费/佣金</th>
                       <th align="center">金额</th>
                       <th align="center">销售金额</th>
                       <th align="center">税率</th>
                       <th align="center">成本单价</th>
                       <th align="center">成本合计</th>
                       <th align="center">税率折价</th>
                       <th align="center">包装方式</th>
                       <th align="center">序列号</th>
                       <th align="center">客户LOGO</th>
                       <th align="center">打标方式</th>
                    </tr>
                    {foreach name=countRow2 from=$roleList.list key=key2 item=arr2}
                        {if $smarty.foreach.countRow2.iteration % 2 eq '1'}
                        <tr class="Hover">
                        {else}
                        <tr class="Bj Hover">
                        {/if}
                            <td align="center">{$smarty.foreach.countRow2.iteration}</td>
                            <td>{$arr2.username}</td>
                            <td>{$arr2.salesdate}</td>
                            <td>{$arr2.accountname}</td>
                            <td>{$arr2.salesno}</td>
                            <td>{$arr2.productname}</td>
                            <td>{$arr2.productsheet}</td>
                            <td align="right">{$arr2.num|@setNumberFormat}</td>
                            <td>{$arr2.currency}</td>
                            <td align="right">{$arr2.conversion_rate|@setNumberFormat:5}</td>
                            <td align="right">{$arr2.price|@setNumberFormat:5}</td>
                            <td align="right">{$arr2.com|@setNumberFormat}</td>
                            <td align="right">{$arr2.amount|@setNumberFormat}</td>
                            <td align="right">{$arr2.total|@setNumberFormat}</td>
                            <td align="right">{$arr2.tax*100|@setNumberFormat}%</td>
                            <td align="right">{$arr2.unit_price|@setNumberFormat}</td>
                            <td align="right">{$arr2.subtotal|@setNumberFormat}</td>
                            <td align="right">{$arr2.discount|@setNumberFormat}</td>
                            <td>{$arr2.packing}</td>
                            <td>{$arr2.snumber}</td>
                            <td>{$arr2.logo}</td>
                            <td>{$arr2.mmode}</td>
                        </tr>
                    {/foreach}
            </table>
           <div id="page" align="right"> {$page_arr}</div>
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
<script type="text/javascript">
    window.onresize = function(){ldelim}
        if(document.getElementById('div_select_user')!=undefined&&document.getElementById('div_select_user').style.display!='none'){ldelim}
                           
                            CfnDropDownUsers(getObj('search_text'),'div_select_user',18);BodyClick2(getObj('search_text'),'div_select_user');
                        {rdelim}
                    {rdelim} 
 </script>
</div>
</body>
</html>