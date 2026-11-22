<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css">
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/reminds/reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>
<script type="text/javascript">
	jQuery.noConflict();	
</script>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/daterangepicker/jquery-1.8.3.min.js"></script>
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>{'cheer100'|@getFixedLabel}</title>
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

tr.yellowBj td{background-color:#FFCC00;}
</style>
{/literal}

<body>
<div class="DivBox">
<div class="D_pop_tit">
	<strong class="D_ptita">明细表</strong>
    <a class="D_ptitc" href="javascript:fninvshnew('divSendInform');">
        <img title="关闭" alt="关闭" src="themes/icon/pop_close.png" class="D_ptitcimg">
    </a>
</div>
     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0" style="max-height: 400px; overflow: auto;">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
            
                <tbody>
                {if $type eq 1}
                <tr >
                        <th >{$subject}</th>
                        <th colspan='8' >材料成本明细金额</th>
                </tr>
                    <tr >
                        <th >序号</th>
                        <th >产品名称</th>
                        <th >产品编号</th>
                        <th >产品类别</th>
                        <th >规格型号</th>
                        <th >计量单位</th>
                        <th >出库数量</th>
                        <th >出库单价</th>
                        <th >出库金额</th>
                        
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    <tr class="Bj Hover">
                        <td >{$smarty.foreach.countRow.iteration}</td>
                        <td >{$arr.productname}</td>
                        <td >{$arr.product_no}</td>
                        <td >{$arr.productcategory}</td>
                        <td >{$arr.productsheet}</td>
                        <td >{$arr.usageunit}</td>
                        <td align="right">{if $arr.productname eq '合计金额：'}{else}{$arr.quantity|@setNumberFormat}{/if}</td>
                        <td align="right">{if $arr.productname eq '合计金额：'}{else}{$arr.taxprice|@setNumberFormat}{/if}</td>
                        <td align="right">{$arr.total|@setNumberFormat}</td>
                       </tr>
                    {/foreach}
                {/if}
               {if $type eq 2}       
              <tr >
                        <th >{$subject}</th>
                        <th colspan='2' >人工费申请明细金额</th>
                </tr>
                    <tr >
                        <th >序号</th>
                        <th >施工说明</th>
                        <th >人工费金额</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    <tr class="Bj Hover">
                        <td >{$smarty.foreach.countRow.iteration}</td>
                        <td >{$arr.solution}</td>
                        <td >{$arr.fees|@setNumberFormat}</td>
                    {/foreach}    
                {/if}
                {if $type eq 3}   
                               <tr >
                        <th >{$subject}</th>
                        <th colspan='2' >费用报销明细金额</th>
                </tr>
                    <tr >
                        <th >序号</th>
                        <th >报销人</th>
                        <th >报销金额</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    <tr class="Bj Hover">
                        <td >{$smarty.foreach.countRow.iteration}</td>
                        <td >{$arr.last_name}</td>
                        <td >{$arr.total|@setNumberFormat}</td>
                    {/foreach}            
               {/if}   
               {if $type eq 4}   
                <tr >
                        <th >{$subject}</th>
                        <th colspan='2' >其他费用明细金额</th>
                </tr>
                    <tr >
                        <th >序号</th>
                        <th >其他费用类别</th>
                        <th >金额</th>
                    </tr>
                    
                    {foreach name=countRow from=$listValue key=key item=arr}
                    <tr class="Bj Hover">
                        <td >{$smarty.foreach.countRow.iteration}</td>
                        <td >{$arr.commissiontype}</td>
                        <td >{$arr.amount|@setNumberFormat}</td>
                    {/foreach}            
               {/if}   
               
               </tbody>
            </table>
            
        </div>
    </div>
    

</div>

<script type="text/javascript">
{literal}
   $(document).ready(function() {
      $('#begin_date').daterangepicker(null, function(start, end, label) {
      });
   });
{/literal}
</script>
</body>
</html>