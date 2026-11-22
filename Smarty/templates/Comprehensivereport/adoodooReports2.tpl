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
.Find_Form0 label.Name select {border:1px solid #ddd;height:22px; line-height:22px;width:60px;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 input.Input_time { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 input.Bjffd { background:#ffd;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 input.Input_Text { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 .Select { float:left; width:150px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px; line-height:20px;}
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
.DivBox_Center { width:100%; padding:10px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}
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
        <h1>产品线销售业绩报表 </h1>
    </div>
    <!--查找条件-->
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            {assign }
            <table width="{$COUNT*2*6+100}%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
                        <th rowspan='2'>序号</th>
                        <th rowspan='2'>订货单位</th>
                        <th rowspan='2'>客户经理</th>
                        <th colspan='{$COUNT}'>当月发货数量</th>
                        <th rowspan='2'>当月金额</th>
                        <th colspan='{$COUNT}'>当年累计发货数量</th>
                        <th rowspan='2'>累计金额</th>
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
                        <tr>
                            <td class="listTableRow small">{$smarty.foreach.countRow2.index+1}</td>
                            <td class="listTableRow small">{$arr2.accountname}</td>
                            <td class="listTableRow small">{$arr2.cf_1257}</td>
                    {foreach name=countRow3 from=$roleList key=key3 item=arr3}
                        {if $key2 eq $key3}
                            {foreach name=countRow4 from=$arr3.pro key=key4 item=arr4}
                            <td class="listTableRow small"style="text-align:right;">{$arr4.countorder}</td>
                            {/foreach}
                            <td class="listTableRow small"style="text-align:right;">{$arr3.total}</td>
                            {foreach name=countRow4 from=$arr3.pro key=key4 item=arr4}
                            <td class="listTableRow small"style="text-align:right;">{$arr4.ALLcountorder}</td>
                            {/foreach}
                            <td class="listTableRow small"style="text-align:right;">{$arr3.Alltotal}</td>
                            
                        {/if}
                    {/foreach}
                        </tr>
                    {/foreach}
                        <tr>
                        <td class="listTableRow small"style="text-align:right;" ></td>
                        <td class="listTableRow small"style="text-align:right;">合计</td>
                        <td class="listTableRow small"style="text-align:right;"></td>
                        {foreach name=countRow3 from=$AccountNumberALL.pro key=key4 item=arr4}
                            <td class="listTableRow small"style="text-align:right;">{$arr4.quantity}</td>
                        {/foreach}
                        <td class="listTableRow small"style="text-align:right;">{$AccountNumberALL.total}</td>
                        {foreach name=countRow3 from=$AccountNumberALL.pro key=key4 item=arr4}
                            <td class="listTableRow small"style="text-align:right;">{$arr4.allcount}</td>
                        {/foreach}
                        <td class="listTableRow small"style="text-align:right;">{$AccountNumberALL.allcount}</td>
                        </tr>
                </tbody>
            </table>
            
        </div>
    </div>
</div>
</body>
</html>