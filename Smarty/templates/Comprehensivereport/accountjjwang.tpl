<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSRUL}include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="jscalendar/calendar-win2k-cold-1.css">
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<script language="JavaScript" type="text/javascript" src="jscalendar/DynamicCalendar.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/reminds/reminds.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
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
.Find_Form0 { float:left; width:98%; padding:10px 1% 10px 1%;}
.Find_Form0 h3 { float:left; height:100%; font-size:16px; color:#0070BA; line-height:20px; padding-right:10px;}
.Find_Form0 label.Name,.Find_Form0 span.Name { float:left; font-size:12px; color:3333; line-height:20px; padding:0px 5px;}
.Find_Form0 .Name .date {border:1px solid #ddd;height:22px;line-height:22px;width:142px;float:left;padding-left:5px;}
.Find_Form0 .Name span{display:block;float:left;margin:1px 0;}
.Find_Form0 label.Name span{margin-right:5px;}
.DivBox_Center { width:100%; padding:5px 0px;clear:both;}
.DivBox_Center .DivList0 { float:left; width:100%; padding-bottom:15px;}

tr.yellowBj td{background-color:#FFCC00;}
</style>
{/literal}

<body>
<div class="DivBox">
    <div class="DivBox_top">
        <h1>{$YEAR}{if $YEAR neq ''}{'YEAR'|@getFixedLabel}{/if}{'cheer100'|@getFixedLabel}</h1>
    </div>

     <!--查找条件 end-->
     <div class="DivBox_Center">
    	<div class="DivList0">
            <table class="TableList" width="100%" border="0" cellspacing="1" cellpadding="0">
                <tbody>
                <tr >
                        <th colspan='11' >总表内容</th>
                </tr>
                    <tr class="Hover">
                        <td rowspan='6'>项目立项</td>
                        <td >单据号</td>
                        <td >创建时间</td>
                        <td >创建人员</td>
                        <td >销售部门</td>
                        <td >销售人员</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                    <tr class="Bj Hover">
                        <td >{$listValue.account_no}</td>
                        <td >{$listValue.createdtime}</td>
                        <td >{$listValue.last_name}</td>
                        <td >{$listValue.cf_1699}</td>
                        <td >{$listValue.last_name2}</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >项目名称</td>
                        <td >姓名</td>
                        <td >联系电话</td>
                        <td >小区名称</td>
                        <td >小区地址</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                    <tr class="Bj Hover">
                        <td >{$listValue.companyname}</td>
                        <td >{$listValue.lastname2}</td>
                        <td >{$listValue.pphone}</td>
                        <td >{$listValue.cf_1400}</td>
                        <td >{$listValue.accountname}</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                    <tr class="Hover">
                         <td >具体来源</td>
                        <td >房型</td>
                        <td >面积</td>
                        <td >系统选择</td>
                        <td >厂家立项选择</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                    <tr class="Bj Hover">
                        <td >{$listValue.cf_1713}</td>
                        <td >{$listValue.cf_1408}</td>
                        <td >{$listValue.cf_1402}</td>
                        <td >{$listValue.cf_1721}</td>
                        <td >{$listValue.cf_1746}</td>
                        <td ></td>
                        <td ></td>
                    </tr>
                <tr >
                        <th colspan='11'></th>
                </tr>
                    <tr class="Hover">
                        <td rowspan='5'>销售机会</td>
                        <td >商机类型</td>
                        <td >{$PotentialsValue.potentialtype}</td>
                        <td >竞争对手</td>
                        <td >{$PotentialsValue.Competitors}</td><td ></td><td ></td><td ></td>
                        
                    </tr>
                    <tr class="Bj Hover">
                        <td >成功结案100%</td>
                        <td >成功结案时间</td>
                        <td >成功结案内容</td>
                        <td >无效信息0%</td>
                        <td >无效结案时间</td>
                        <td >无效结案内容</td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$PotentialsValue.cf_1778}</td>
                        <td >{$PotentialsValue.cf_1731}</td>
                        <td >{$PotentialsValue.cf_1732}</td>
                        <td >{$PotentialsValue.cf_1780}</td>
                        <td >{$PotentialsValue.cf_1735}</td>
                        <td >{$PotentialsValue.cf_1736}</td><td ></td>
                    </tr>
                    <tr class="Bj Hover">
                        <td >失败结案0%</td>
                        <td >失败结案时间</td>
                        <td >失败结案内容</td>
                        <td >待定信息0%</td>
                        <td >待定结案时间</td>
                        <td >待定结案内容</td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$PotentialsValue.cf_1779}</td>
                        <td >{$PotentialsValue.cf_1733}</td>
                        <td >{$PotentialsValue.cf_1734}</td>
                        <td >{$PotentialsValue.cf_1781}</td>
                        <td >{$PotentialsValue.cf_1737}</td>
                        <td >{$PotentialsValue.cf_1738}</td><td ></td>
                    </tr>
                    <tr >
                        <th colspan='11'></th>
                     </tr>
                     <tr class="Bj Hover">
                        <td rowspan='2'>报价方案</td>
                        <td >创建时间</td>
                        <td >设计人员</td>
                        <td >系统品牌</td>
                        <td >要求完成时间</td>
                        <td >设计次数</td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$quotesValue.createdtime}</td>
                        <td >{$quotesValue.cf_1513}</td>
                        <td >{$quotesValue.cf_1508}</td>
                        <td >{$quotesValue.cf_1514}</td>
                        <td >{$quotesValue.cf_1720}</td><td ></td><td ></td>
                    </tr>  
                    <tr >
                        <th colspan='11'></th>
                     </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='{$salesorderValue.rowCount+5}'>项目合同</td>
                        <td >合同编号</td>
                        <td >创建时间</td>
                        <td >签约金额</td>
                        <td >工程总造价</td>
                        <td >销售限价</td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$salesorderValue.salesorder_no}</td>
                        <td >{$salesorderValue.createdtime}</td>
                        <td >{$salesorderValue.cf_1535}</td>
                        <td >{$salesorderValue.cf_1532}</td>
                        <td >{$salesorderValue.cf_1534}</td><td ></td><td ></td>
                    </tr>  
                    <tr class="Bj Hover">
                        <td >合同类别</td>
                        <td >信息费</td>
                        <td >合同付款方式</td>
                        <td >合同变更次数</td>
                        <td >最新修改时间</td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$salesorderValue.cf_1694}</td>
                        <td >{$salesorderValue.cf_1536}</td>
                        <td >{$salesorderValue.cf_1540}</td>
                        <td >{$salesorderValue.cf_1762}</td>
                        <td >{$salesorderValue.modifiedtime}</td><td ></td><td ></td>
                    </tr>  
                    <tr class="yellowBj">
                        <td >商品名称</td>
                        <td >规格型号</td>
                        <td >计量单位</td>
                        <td >数量</td>
                        <td >含税单价</td>
                        <td >整单折扣</td>
                        <td >报价</td>                        
                    </tr>
                    {foreach name=countRow from=$salesorderValue.pro key=key item=arr2}
                    <tr class="Hover">
                        {foreach name=countRow from=$arr2 key=key2 item=arr3}
                        <td >{$arr3}</td>
                        {/foreach}
                    </tr>  
                    {/foreach}
                    <tr >
                        <th colspan='11'></th>
                     </tr> 
                     <tr class="Bj Hover">
                        <td rowspan='4'>现场放线</td>
                        <td >系统选择</td>
                        <td >放线需求时间</td>
                        <td >设计人员</td>
                        <td >设计确定时间</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$ProjectValue.cf_1740}</td>
                        <td >{$ProjectValue.cf_1608}</td>
                        <td >{$ProjectValue.cf_1607}</td>
                        <td >{$ProjectValue.cf_1609}</td><td ></td><td ></td><td ></td>
                    </tr>  
                    <tr class="Bj Hover">
                        <td >施工人员</td>
                        <td >项目监理</td>
                        <td >工程确定时间</td>
                        <td >厂家确定时间</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$ProjectValue.cf_1604}</td>
                        <td >{$ProjectValue.cf_1603}</td>
                        <td >{$ProjectValue.cf_1783}</td>
                        <td >{$ProjectValue.cf_1611}</td><td ></td><td ></td><td ></td>
                    </tr>  
                    <tr >
                        <th colspan='11'></th>
                     </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='{$SalesBackValue.rowCount+3}'>变更单</td>
                        <td >创建时间</td>
                        <td >创建人</td>
                        <td >变更类型</td>
                        <td >变更内容</td>
                        <td >修改时间</td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$SalesBackValue.createdtime}</td>
                        <td >{$SalesBackValue.last_name}</td>
                        <td >{$SalesBackValue.cf_1716}</td>
                        <td >{$SalesBackValue.cf_1717}</td>
                        <td >{$SalesBackValue.modifiedtime}</td><td ></td><td ></td>
                    </tr>  
                    <tr class="Bj Hover">
                        <td >商品名称</td>
                        <td >规格型号</td>
                        <td >计量单位</td>
                        <td >数量</td>
                        <td >含税单价</td>
                        <td >整单折扣</td>
                        <td >报价</td>                        
                    </tr>
                    {foreach name=countRow from=$SalesBackValue.pro key=key item=arr2}
                    <tr class="Hover">
                        {foreach name=countRow from=$arr2 key=key2 item=arr3}
                        <td >{$arr3}</td>
                        {/foreach}
                    </tr>  
                    {/foreach}  
                  <tr >
                        <th colspan='11'></th>
                     </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='{$PurchaseOrder.rowCount+3}'>设备需求</td>
                        <td >创建时间</td>
                        <td >主题</td>
                        <td >设备用途</td>
                        <td >要求到货时间</td>
                        <td >需求次数</td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$PurchaseOrder.createdtime}</td>
                        <td >{$PurchaseOrder.subject}</td>
                        <td >{$PurchaseOrder.cf_1378}</td>
                        <td >{$PurchaseOrder.cf_1589}</td>
                        <td >{$PurchaseOrder.cf_1790}</td><td ></td><td ></td>
                    </tr>  
                    <tr class="Bj Hover">
                        <td >商品名称</td>
                        <td >规格型号</td>
                        <td >计量单位</td>
                        <td >数量</td><td ></td><td ></td><td ></td>                    
                    </tr>
                    {foreach name=countRow from=$PurchaseOrder.pro key=key item=arr2}
                    <tr class="Hover">
                        {foreach name=countRow from=$arr2 key=key2 item=arr3}
                        <td >{$arr3}</td>
                        {/foreach}<td ></td><td ></td><td ></td>
                    </tr>  
                    {/foreach}   
                  <tr >
                        <th colspan='11'></th>
                     </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='{$OutboundOrder.rowCount+3}'>设备发货</td>
                        <td >仓库</td>
                        <td >发货时间</td>
                        <td >发货次数</td>
                        <td >接货人员</td>
                        <td >联系电话</td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$OutboundOrder.name}</td>
                        <td >{$OutboundOrder.cf_1430}</td>
                        <td >{$OutboundOrder.cf_1791}</td>
                        <td >{$OutboundOrder.cf_1545}</td>
                        <td >{$OutboundOrder.cf_1546}</td><td ></td><td ></td>
                    </tr>  
                    <tr class="Bj Hover">
                        <td >商品名称</td>
                        <td >规格型号</td>
                        <td >计量单位</td>
                        <td >数量</td> <td ></td><td ></td><td ></td>                   
                    </tr>
                    {foreach name=countRow from=$OutboundOrder.pro key=key item=arr2}
                    <tr class="Hover">
                        {foreach name=countRow from=$arr2 key=key2 item=arr3}
                        <td >{$arr3}</td>
                        {/foreach}<td ></td><td ></td><td ></td>
                    </tr>  
                    {/foreach}       
                    <tr >
                        <th colspan='11'></th>
                    </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='2'>隐蔽验收</td>
                        <td >隐蔽验收时间</td>
                        <td >隐蔽验收结果</td>
                        <td >隐蔽回访结果</td>
                        <td >班组结算金额</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$ProjectValue.cf_1619}</td>
                        <td >{$ProjectValue.cf_1620}</td>
                        <td >{$ProjectValue.cf_1787}</td>
                        <td >{$ProjectValue.cf_1805}</td><td ></td><td ></td><td ></td>
                    </tr>       
                    <tr >
                        <th colspan='11'></th>
                    </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='2'>竣工验收</td>
                        <td >竣工验收时间</td>
                        <td >竣工验收结果</td>
                        <td >竣工回访结果</td>
                        <td >班组结算金额</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$ProjectValue.cf_1622}</td>
                        <td >{$ProjectValue.cf_1623}</td>
                        <td >{$ProjectValue.cf_1788}</td>
                        <td >{$ProjectValue.cf_1806}</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr >
                        <th colspan='11'></th>
                    </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='2'>检查整改</td>
                        <td >检查时间</td>
                        <td >检查内容</td>
                        <td >整改结果</td>
                        <td >整改回访结果</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$ProjectValue.cf_1613}</td>
                        <td >{$ProjectValue.cf_1614}</td>
                        <td >{$ProjectValue.cf_1617}</td>
                        <td >{$ProjectValue.cf_1786}</td><td ></td><td ></td><td ></td>
                    </tr>      
                    <tr >
                        <th colspan='11'></th>
                    </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='4'>售后派工单</td>
                        <td >创建人</td>
                        <td >创建时间</td>
                        <td >报修人员</td>
                        <td >报修人员电话</td>
                        <td >报修品牌</td>
                        <td >型号</td>
                        <td >报修问题</td>
                    </tr>
                    <tr class="Hover">
                        <td >{$HelpDesk.last_name}</td>
                        <td >{$HelpDesk.createdtime}</td>
                        <td >{$HelpDesk.accountname}</td>
                        <td >{$HelpDesk.cf_1667}</td>
                        <td >{$HelpDesk.cf_1669}</td>
                        <td >{$HelpDesk.cf_1670}</td>
                        <td >{$HelpDesk.cf_1668}</td>
                    </tr>       
                    <tr class="Bj Hover">
                        <td >希望处理时间</td>
                        <td >维修人员</td>
                        <td >维修人员电话</td>
                        <td >约定上门时间</td>
                        <td >实际上门时间</td>
                        <td >实际完成时间</td>
                        <td >收费金额</td>
                    </tr>
                    <tr class="Hover">
                        <td >{$HelpDesk.hopetime}</td>
                        <td >{$HelpDesk.cf_1793}</td>
                        <td >{$HelpDesk.cf_1794}</td>
                        <td >{$HelpDesk.cf_1678}</td>
                        <td >{$HelpDesk.realtime}</td>
                        <td >{$HelpDesk.cf_1795}</td>
                        <td >{$HelpDesk.cf_1796}</td>
                    </tr>  
                    <tr >
                        <th colspan='11'></th>
                    </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='2'>收款单</td>
                        <td >付款时间</td>
                        <td >付款方式</td>
                        <td >收款金额</td>
                        <td >收款期次</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$CashBill.cashbilldate}</td>
                        <td >{$CashBill.paymentmethod}</td>
                        <td >{$CashBill.Total}</td>
                        <td >{$CashBill.count}</td><td ></td><td ></td><td ></td>
                    </tr>   
                    <tr >
                        <th colspan='11'></th>
                    </tr> 
                    <tr class="Bj Hover">
                        <td rowspan='2'>佣金单</td>
                        <td >报销人</td>
                        <td >报销日期</td>
                        <td >佣金类别</td>
                        <td >付款金额</td><td ></td><td ></td><td ></td>
                    </tr>
                    <tr class="Hover">
                        <td >{$CashBill.cashbilldate}</td>
                        <td >{$CashBill.paymentmethod}</td>
                        <td >{$CashBill.Total}</td>
                        <td >{$CashBill.count}</td><td ></td><td ></td><td ></td>
                    </tr>                         
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