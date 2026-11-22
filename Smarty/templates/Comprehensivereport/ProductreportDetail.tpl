<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>

<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/Reminds/Reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<script type="text/javascript">
	var ld = $;
	ld.noConflict();
</script>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>销售统计表——按产品</title>
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
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 input.Input_time { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 input.Bjffd { background:#ffd;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 input.Input_Text { float:left; width:100px; height:20px; border:1px #ddd solid; background:#fff; padding:0px 3px; line-height:20px; color:#333;}
.Find_Form0 .Select { float:left; width:150px; height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px; line-height:20px;}
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
.Button_find { margin-top:0px;float:left; color:#fff;font-weight:bold; overflow:hidden; line-height:21px;border:none;padding: 0 15px; border-radius:3px; cursor:pointer; font-size:12px; background-image: url(themes/softed/images/toolbar-bg.png);}
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
/*---查找----*/
.Find_box { float:left; width:100%; padding-bottom:0px;}
/*.Find_box table { background:#ccc;}*/
.Find_box table td { background:#fff;}
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:130px;float:left;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 .Name img{margin:1px 0px 0px 5px;}
.Find_Form0 label.Name span{margin-right:5px;}
.Find_Form0 img.Icon { float:left; margin:1px 5px; cursor:pointer}
.Find_Form0 .Select { float:left; width:150px; height:22px; line-height:22px; padding:1px; border:1px #ddd solid; background:#fff; margin-right:10px;}

.DivBox_Center { width:100%; padding:5px 0px;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px; }
</style>
{/literal}
<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$YEAR}年{$MONTH}月销售统计表——按产品:</h1>
    </div>
    <!--查找条件-->
	<!--查找条件-->
     <div class="Find_box">
    	<table width="100%" border="0" cellspacing="1" cellpadding="0" style="display:">
          <tr>
            <td>
            	<form class="Find_Form0" name="Report_form_query" id="Report_form_query" onsubmit="puyoungJS_DialogBox.block();" action="index.php">
                	<h3>{'SEARCH'|@getFixedLabel}</h3>
                    <input type="hidden" value="Comprehensivereport" name="module">
                    <input type="hidden" value="ProductreportDetail" name="action">
                    <input type="hidden" value="true" name="Report_form_query">
                    <input type="hidden" value="dheader" name="ReportHeader" id="ReportHeader">
					<input type="hidden" value="{$formodule}" id="formodule" name="formodule">
					<input type="hidden" value="{$YEAR}" name="year" id="year">
					<input type="hidden" value="{$name}" name="name" id="name">
					<input type="hidden" value="{$MONTH}" name="month" id="month">
					<input type="hidden" value="{$parenttab}" name="parenttab" id="parenttab">
                     <label class="Name">
                            <span>货&nbsp;&nbsp;号:</span>
                            <input type="text" class="date" name="product_no" id="product_no" value="{$product_no}" style="width:180px"/>
                    </label>            
                    <input type="button" value="{'QUERYTO'|@getFixedLabel}" class="ld-button Button_find" onclick="Report_Validate(this);"/>
					&nbsp;&nbsp;
					<input type="button" value="导出" class="ld-button Button_find" onclick="Export_Validate(this);"/>
                </form>
            </td>
          </tr>
        </table>
     </div>
     <!--查找条件 end-->
     <div class="Find_box">
    	<!--table width="100%" border="0" cellspacing="1" cellpadding="0">
          <tr>
            <td>
            	<form class="Find_Form0">
                	<h3>查找</h3>
                	<label class="Name">初期：</label>
                    
                    <label class="Name">期末：</label>
                    
                    <label class="Name">人员名：</label>
                    <select class="Select">
                    	<option>人员名</option>
                        <option>人员名</option>
                    </select>
                    <input type="button" value="查询" class="Button_find" />
                </form>
            </td>
          </tr>
        </table-->
     </div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                    <tr>
						<th >#</th>
                        <th >货号</th>
                        <th >类型</th>
                        <th >年累计销售数量</th>
                        <th >年累计销售金额</th>
                        <th >本月销售数量</th>
                        <th >本月销售金额</th>
                        <th >数量累计占比</th>
                        <th >金额累计占比</th>
						<th >产品年均价</th>
                        <th >月均价</th>
                    </tr>

                    {foreach name=countRow from=$PRODUCT_LIST key=key item=arr}
                    {if ($smarty.foreach.countRow.index+1)%2 == 1}
                    <tr>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.no}</td>
                       <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.productname}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.productcategory}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.descimal_quantity}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.descimal_tax_amount}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.descimal_month_quantity}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.descimal_month_tax_amount}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.qty_zhanbi}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.amount_zhanbi}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.year_junjia}</td>
					   <td class="listTableRow" style="background-color:#EEF7FF;">{$arr.junjia}</td>
                    </tr>
                    {else}
                    <tr>
					   <td class="listTableRow">{$arr.no}</td>
                       <td class="listTableRow">{$arr.productname}</td>
					   <td class="listTableRow">{$arr.productcategory}</td>
					   <td class="listTableRow">{$arr.descimal_quantity}</td>
					   <td class="listTableRow">{$arr.descimal_tax_amount}</td>
					   <td class="listTableRow">{$arr.descimal_month_quantity}</td>
					   <td class="listTableRow">{$arr.descimal_month_tax_amount}</td>
					   <td class="listTableRow">{$arr.qty_zhanbi}</td>
					   <td class="listTableRow">{$arr.amount_zhanbi}</td>
					   <td class="listTableRow">{$arr.year_junjia}</td>
					   <td class="listTableRow">{$arr.junjia}</td>
                    </tr>
                    {/if}
                    {/foreach}
					<tr>
                        <td ></td><td ></td>
                        <td ><b>合计</b></td>
                        <td ><b>{$year_sun_quantity|@getDecimalTwoVal}</b></td>
                        <td ><b>{$year_sum_tax_amount|@getDecimalTwoVal}</b></td>
                        <td ><b>{$month_sun_quantity|@getDecimalTwoVal}</b></td>
                        <td ><b>{$month_sum_tax_amount|@getDecimalTwoVal}</b></td>
                        <td ></td>
                        <td ></td>
						<td ></td>
                        <td ></td>
                    </tr>
                </tbody>
            </table>
            
        </div>
    </div>
</div>
<script type="text/javascript">
{literal}
	function Report_Validate(obj){
		var product_no = ld('#product_no').val();
		if(product_no == ''){
			alert("请输入货号！");
			return false;
		}else{
			document.Report_form_query.submit();
		}
	}
	function Export_Validate(obj){
		var ReportHeader = ld('#ReportHeader').val();
		var formodule = ld('#formodule').val();
		var year = ld('#year').val();
		var sname = ld('#name').val();
		var month = ld('#month').val();
		var parenttab = ld('#parenttab').val();
		var product_no = ld('#product_no').val();
		var url = "index.php?module=Comprehensivereport&action=ProductreportDetail&ReportHeader="+ReportHeader+"&formodule="+formodule+"&year="+year+"&name="+sname+"&month="+month+"&parenttab="+parenttab+"&Export=true&product_no="+product_no+"&Report_form_query=true";
		//alert(url);
		location.href=url;
	}
{/literal}
</script>
</body>
</html>