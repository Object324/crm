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
<title>产品线销售业绩报表</title>
</head>
{literal}
<style>
* { margin:0px; padding:0px; border:0px;}
body { background:#fff; line-height:1;}
.DivBox { padding:5px;}
.DivBox_top { width:100%; height:35px;}
.DivBox_top h1 { float:left; font-size:20px; color:#000; line-height:30px;}

.DivBox_Center { width:100%; padding:10px 0px;}
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

</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>产品线销售业绩报表 </h1>
    </div>
    <!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
  	              <h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module"/>
                    <input type="hidden" value="youchuangReports2" name="action"/>
                    <input type="hidden" value="true" name="Report_form_query"/>
                    <input type="hidden" value="dheader" name="ReportHeader"/>
                    <input type="hidden" value="{$reportname}" name="name"/>
                    <input type="hidden" value="{$YEAR}" name="year"/>
                    <input type="hidden" value="{$MONTH}" name="month"/>
                    <!--input type="hidden" value="" name="ajaxExport" id="ajaxExport"/-->
                    <label class="Name">
                        <span>订货单位:</span>
                            <input  class="date" name="ProductDanwei" value="{$ProductDanwei}"/>
                        </span>
                    </label>
                	<label class="Name">
                        <span>产品类别:</span>
                        <select id="Customercategory" class="date" name="ProductCategories"> 
                        <option value ="" >--全部--</option> 
                            {foreach item=userid from=$accounttype}
                            
                             <option value ="{$userid}" {if $ProductCategories eq $userid} selected="selected" {/if}>{$userid}</option>  
                            {/foreach}  
                        </select>  
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
            <table width="{$COUNT*2*8+100}%" class="TableList" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th rowspan='2' width="30" align="center">序号</th>
                        <th rowspan='2'>订货单位</th>
                        <th rowspan='2' width="60">客户经理</th>
                        <th colspan='{$COUNT}'>当月发货数量</th>
                        <th rowspan='2'>当月金额</th>
                        <th colspan='{$COUNT}'>当年累计发货数量</th>
                        <th rowspan='2' width="86">累计金额</th>
                    </tr>
                    <tr>
                    {foreach name=countRow from=$PRODUCTIDLIST key=key item=arr}
                        <th >{$arr}</th>
                    {/foreach}
                    {foreach name=countRow from=$PRODUCTIDLIST key=key item=arr}
                        <th >{$arr}</th>
                    {/foreach}
                    </tr>
                    {foreach name=countRow2 from=$ACCOUNTLIST key=key2 item=arr2}
                        {if $smarty.foreach.countRow2.iteration % 2 eq '1'}
                        <tr class="Hover">
                        {else}
                        <tr class="Bj Hover">
                        {/if}
                            <td align="center">{$smarty.foreach.countRow2.iteration}</td>
                            <td>{$arr2.accountname}</td>
                            <td>{$arr2.cf_1257}</td>
                    {foreach name=countRow3 from=$roleList key=key3 item=arr3}
                        {if $key2 eq $key3}
                            {foreach name=countRow4 from=$arr3.pro key=key4 item=arr4}
                            <td align="right">{$arr4.countorder}</td>
                            {/foreach}
                            <td align="right">{$arr3.total}</td>
                            {foreach name=countRow4 from=$arr3.pro key=key4 item=arr4}
                            <td align="right">{$arr4.ALLcountorder}</td>
                            {/foreach}
                            <td align="right">{$arr3.Alltotal}</td>
                            
                        {/if}
                    {/foreach}
                        </tr>
                    {/foreach}
                        <tr class="ALLTotal">
                        <td align="right"></td>
                        <td align="right">合计</td>
                        <td align="right"></td>
                        {foreach name=countRow3 from=$AccountNumberALL.pro key=key4 item=arr4}
                            <td align="right">{$arr4.quantity}</td>
                        {/foreach}
                        <td align="right">{$AccountNumberALL.total}</td>
                        {foreach name=countRow3 from=$AccountNumberALL.pro key=key4 item=arr4}
                            <td align="right">{$arr4.allcount}</td>
                        {/foreach}
                        <td align="right">{$AccountNumberALL.allcount}</td>
                        </tr>
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>