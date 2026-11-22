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
<title>优创生物销售报表</title>
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

.TableList tr td.BgcolorF8 { background:#f8f8f8;}/* 默认隔行背景颜色 */
.TableList td.BgcolorF6{ background:#f6f6f6;}/*合并行背景颜色*/
.TableList tr:hover td.Hover{background:var(--ld-bg-list-td-hover-color);}/* 鼠标经过时候背景颜色 */
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>优创生物销售报表 </h1>
    </div>
    <!--查找条件-->
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="{$COUNT*3+100}%" class="TableList" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th rowspan='2' width="50">{'Name'|@getFixedLabel}</th>
                        <th rowspan='2' width="80">{'Project'|@getFixedLabel}</th>
                        <th colspan='{$COUNT}'>销 售 业 绩（鼓/支/片）</th>
                    </tr>
                    <tr>
                    {foreach name=countRow from=$PRODUCTIDLIST key=key item=arr}
                        <th >{$arr}</th>
                    {/foreach}
                        <th width="75">新增客户</th>
                        <th width="75">累计客户</th>
                    </tr>
                    {foreach name=countRow2 from=$ACCOUNTLIST key=key2 item=arr2}
                        <tr>
                            <td rowspan='2' class="BgcolorF6">{$arr2}</td>
                            <td align="right" class="Hover">合计（数量）</td>
                    {foreach name=countRow3 from=$roleList key=key3 item=arr3}
                        {if $key2 eq $key3}
                            {foreach name=countRow4 from=$arr3.pro key=key4 item=arr4}
                            <td align="right" class="Hover">{$arr4.quantity}</td>
                            {/foreach}
                            <td align="right" class="Hover" rowspan='2' >{$arr3.newcount}</td>
                            <td align="right" class="Hover" rowspan='2' >{$arr3.allcount}</td>
                        {/if}
                    {/foreach}
                        </tr>
                        <tr align="right">
                            <td class="Hover BgcolorF8 ">合计（金额）</td>
                    {foreach name=countRow3 from=$roleList key=key3 item=arr3}
                        {if $key2 eq $key3}
                            {foreach name=countRow4 from=$arr3.pro key=key4 item=arr4}
                            <td class="Hover BgcolorF8 ">{$arr4.total}</td>
                            {/foreach}
                        {/if}
                    {/foreach}
                        </tr>
                    {/foreach}
                        <tr align="right">
                            <td rowspan='2' class="BgcolorF6">总计</td>
                            <td class="Hover">合计（数量）</td>
                            {foreach name=countRow3 from=$AccountNumberALL.pro key=key4 item=arr4}
                                <td class="Hover">{$arr4.quantity}</td>
                            {/foreach}
                            <td class="Hover">{$AccountNumberALL.newcount}</td>
                            <td class="Hover">{$AccountNumberALL.allcount}</td>
                        </tr>
                        <tr align="right">
                            <td class="Hover">合计（金额）</td>
                            {foreach name=countRow3 from=$AccountNumberALL.pro key=key4 item=arr4}
                                <td class="Hover">{$arr4.total}</td>
                            {/foreach}
                            <td class="Hover">{$AccountNumberALL.newcount}</td>
                            <td class="Hover">{$AccountNumberALL.allcount}</td>
                        </tr>
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>