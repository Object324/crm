<?php
/*******************************************************
**更新操作
**edit:chj
**date:2013-11-26
**reason:库存台账
*******************************************************/
//require_once('Smarty_setup.php');
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user;
global $list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty;
$productdetail = "";
$category = getParentTab();
//if(isset($tool_buttons)==false) {
	//$tool_buttons = Button_Check($currentModule);
	//$tool_buttons['Create'] = 'no';
	//$tool_buttons['index'] = 'no';
//}
crm_load_function_file('selWareAll','include/Stock','CommonStock');
$result=selWareAll();
$num_rows=$adb->num_rows($result);
if(!$num_rows){
    echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>

		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
		<tbody><tr>
		<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) ."' ></td>
		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span clas
		s='genHeaderSmall'>".getFixedLabel('INSUFFICIENTWAREHOUSE')."</span></td>
		</tr>
		<tr>
		<td class='small' align='right' nowrap='nowrap'>
		<a href='index.php?module=Home&action=index&parenttab=My Home Page'>".getFixedLabel('RETURN')."</a><br>
		</td>
		</tr>
		</tbody></table>
		</div>";
	echo "</td></tr></table>";
	exit;
}
$num_rows=$adb->num_rows($result);
$warehouses=array();
for($i=0;$i<$num_rows;$i++){
    $warehouses[]=array(
    'id'=>$adb->query_result($result,$i,'id'),
    'name'=>$adb->query_result($result,$i,'name')
    );
}
if(count($warehouses)>5){
    $warehousesofeight=array();
    for($i=0;$i<5;$i++){
        $warehousesofeight[]=$warehouses[$i];
    }
    $warehouseslast=array();
    for($i=5;$i<count($warehouses);$i++){
        $warehouseslast[$warehouses[$i]['id']]=$warehouses[$i]['name'];
    }
    $smarty->assign('WAREHOUSES',$warehousesofeight);//仓库信息
    $smarty->assign('MOREWAREHOUSES',$warehouseslast);
    
}
else
{
    $smarty->assign('WAREHOUSES',$warehouses);//仓库信息
}


if(isset($_REQUEST['createdate']) && $_REQUEST['createdate'] != "")
{
    $firstday = $_REQUEST['createdate'];
}
else
{
    $firstday = date('Y-m-01', strtotime(date('Y-m-d H:i:s')));  
}
if(isset($_REQUEST['enddate']) && $_REQUEST['enddate'] != "")
{
    $lastday = $_REQUEST['enddate'];
}
else
{
    $lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
}
if(isset($_REQUEST['unprice']) && $_REQUEST['unprice'] != "")
{
    $unprice = $_REQUEST['unprice'];
}
else
{
    $unprice = 0; //默认0 产品单价  
}
if(isset($_REQUEST['productinfo']) && $_REQUEST['productinfo'] != "")
{
    $productinfo = $_REQUEST['productinfo'];
}
else
{
    $productinfo = 0; // 默认0 产品名称
}
if(isset($_REQUEST['hiddenledger']) && $_REQUEST['hiddenledger'] != "")
{
    $ledger = $_REQUEST['hiddenledger'];
}
else
{
    $ledger = 1; // 默认0 台账包含盘点记录
}

if(isset($_REQUEST['productdetail']) && $_REQUEST['productdetail'] != "")
{
    $productdetail = $_REQUEST['productdetail'];
}



if(isset($_REQUEST['warehouseid']) && $_REQUEST['warehouseid'] > 0)
{
    $warehouseid=$_REQUEST['warehouseid'];   
}
else
{
    $warehouseid = 0;
}

$smarty->assign('WAREHOUSEID',$warehouseid);
//$query='select started from ld_warehouse where id=?';
//$started=$adb->query_result($adb->pquery($query,array($warehouseid)),0,'started');
//$smarty->assign('STARTED',$started);
$query = "select a.warehouseid,a.productid,c.name,b.productname,b.product_no,b.productcode,b.productcategory,b.productsheet 
from ld_warehousecondtions a,ld_products b,ld_warehouse c where    a.warehouseid = c.id  and a.productid = b.productid and  a.type != '审批失败' ";
if($warehouseid > 0)
{
    $query .= "and a.warehouseid = $warehouseid ";
}
$query .= "and a.operationtime <= '$lastday 23:59:59' ";

if(isset($productdetail) && $productdetail != "")
{
    switch($productinfo)
    {
        case 0:
            $query .= "and b.productname like '%$productdetail%'";
            break;
        case 1:
            $query .= "and b.product_no like '%$productdetail%'";
            break;
        case 2:
            $query .= "and b.productsheet like '%$productdetail%'";//23261: 库存台账：查找 > 单价基准选择“参考价”，“规格型号”，输入“企业版”，期初选择“2010-01-01”点击【生成库存台账】，显示“没有找到任何记录！”
            break;
        case 3:
            $query .= "and b.productcategory like '%$productdetail%'";
            break;
    }
}
//echo $query;echo '<br><br>';
  $squery = $query . " group by a.warehouseid,a.productid asc";
  
$result = $adb->pquery($squery, array());
$num_rows=$adb->num_rows($result);
$WareAllId = getWareProductIdAll($current_user->id);
	/**
	 * @project PROT75 数量小数位数
	 * @author Tujt 2014-08-14 CRMV5.6
	 */
	$sysdeploy = getSys_deploy(49);
	if(isset($sysdeploy['deploy_value']))
		$lengthdecimaldigits = $sysdeploy['deploy_value'];
	else
		$lengthdecimaldigits  = 2;
 
  
for($k = 0; $k<count($WareAllId); $k++)
{
    if($_REQUEST['warehouseid'])
    {
        if($_REQUEST['warehouseid']!=$WareAllId[$k])
        {
            continue;
        }
    }
  
    $initalnumCount = 0;
    $initalpriceCount = 0;
    $beginingnumCount = 0;
    $beginingpriceCount = 0;
    $outputnumCount = 0;
    $outputpriceCount = 0;
    $endnumCount = 0;
    $endpriceCount = 0;
    $tmpk=0;
    $warehouseid = $WareAllId[$k];
  for($tmpk;$tmpk<$num_rows;$tmpk++){
    $databasewarehouseid=$adb->query_result($result,$tmpk,'warehouseid');
        if($databasewarehouseid==$warehouseid)
        {
            break;
        }
    }
    
    switch($unprice)
    {
        case 0:
            $pricetype = 'unit_price';//参考价
            break;
        case 1:
            $pricetype = 'costprice';//成本价
            break;
    }

  
  $initalArray = selInitial($pricetype,$firstday,$productid,$warehouseid);
   $beginingArray = selBegining($pricetype,$firstday,$lastday,$productid,$warehouseid,$ledger);
   $outputArray = selOutput($pricetype,$firstday,$lastday,$productid,$warehouseid,$ledger);
   $tmpi=0;
    for($i=$tmpk;$i<$num_rows;$i++){
        $productid = $adb->query_result($result,$i,'productid');
        $databasewarehouseid=$adb->query_result($result,$i,'warehouseid');
        if($databasewarehouseid!=$warehouseid)
        {
            $tmpk=$i;
            break;
        }
       $tmpi++;
        //echo $adb->query_result($result,$i,'productid') . '--' . $adb->query_result($result,$i,'warehouseid') . '<br>';
        $InventoryArray[$k][]=array(
            'id'=>$tmpi,
            'name'=>$adb->query_result($result,$i,'name'),
            'warehouseid'=>$warehouseid,
            'productid'=>$productid,
            //'productname'=>mb_substr($adb->query_result($result,$i,'productname'),0,10,'utf-8'),
            'productname'=>$adb->query_result($result,$i,'productname'),
            'product_no'=>$adb->query_result($result,$i,'product_no'),
            'productcode'=>$adb->query_result($result,$i,'productsheet'),
            'productcategory'=>$adb->query_result($result,$i,'productcategory'),
            'initalnum'=> setNumberFormat($initalArray[$productid][0],$lengthdecimaldigits),
            'initalprice'=> setNumberFormat($initalArray[$productid][1]),
            'beginingnum'=>setNumberFormat($beginingArray[$productid][0],$lengthdecimaldigits),
            //'beginingnum'=>"<a href=\"javascript:;\" onclick=\"getInitalNum(this,'$pricetype','$firstday','$lastday',$productid,$warehouseid,$ledger,1);\">".setNumberFormat($beginingArray[0])."</a>",
            'beginingprice'=> setNumberFormat($beginingArray[$productid][1]),
            'outputnum'=> setNumberFormat($outputArray[$productid][0],$lengthdecimaldigits),
            //'outputnum'=> "<a href=\"javascript:;\" onclick=\"getInitalNum(this,'$pricetype','$firstday','$lastday',$productid,$warehouseid,$ledger,2);\">" . setNumberFormat($outputArray[0]) . "</a>",
            'outputprice'=> setNumberFormat($outputArray[$productid][1]),
            'endnum'=> setNumberFormat($initalArray[$productid][0] + $beginingArray[$productid][0] - $outputArray[$productid][0],$lengthdecimaldigits),
            'endprice'=> setNumberFormat(($initalArray[$productid][0] + $beginingArray[$productid][0] - $outputArray[$productid][0])* $initalArray[$productid][2]),
        );
        $initalnumCount += $initalArray[$productid][0];
        $initalpriceCount += $initalArray[$productid][1];
        $beginingnumCount += $beginingArray[$productid][0];
        $beginingpriceCount += $beginingArray[$productid][1];
        $outputnumCount += $outputArray[$productid][0];
        $outputpriceCount += $outputArray[$productid][1];
        $endnumCount += $initalArray[$productid][0] + $beginingArray[$productid][0] - $outputArray[$productid][0];
        $endpriceCount += ($initalArray[$productid][0] + $beginingArray[$productid][0] - $outputArray[$productid][0])* $initalArray[$productid][2];
    }
    $CountArray[$k] = array(
        'initalnumCount' =>  setNumberFormat($initalnumCount,$lengthdecimaldigits),
        'initalpriceCount' =>  setNumberFormat($initalpriceCount),
        'beginingnumCount' => setNumberFormat($beginingnumCount,$lengthdecimaldigits),
        'beginingpriceCount' =>  setNumberFormat($beginingpriceCount),
        'outputnumCount' =>  setNumberFormat($outputnumCount,$lengthdecimaldigits),
        'outputpriceCount' =>  setNumberFormat($outputpriceCount),
        'endnumCount' =>  setNumberFormat($endnumCount,$lengthdecimaldigits),
        'endpriceCount' =>  setNumberFormat($endpriceCount),
    );
	$Sum[0] += $initalnumCount;
	$Sum[1] += $initalpriceCount;
	$Sum[2] += $beginingnumCount;
	$Sum[3] += $beginingpriceCount;
	$Sum[4] += $outputnumCount;
	$Sum[5] += $outputpriceCount;
	$Sum[6] += $endnumCount;
	$Sum[7] += $endpriceCount;
   
}



// 产品 0 产品单价 1 产品成本价
function selEntityName($id)
{
    global $adb;
    $sql = "select entityid,modulename from ld_warehousecondtions where id = ?";
    $result=$adb->pquery($sql,array($id));
    $recordid = $adb->query_result($result,0,'entityid');
    if($adb->query_result($result,0,'modulename') == '入库单')
    {
        return "<a href = \"index.php?module=Stock&parenttab=Stock&action=DetailView&record=$recordid\">" . selStockInfo($recordid,4) . "</a>";
    }
    else if($adb->query_result($result,0,'modulename') == '出库单')
    {
        $outinfos=selOutInfo($recordid);
        return "<a href = \"index.php?module=Stock&parenttab=Stock&action=DetailView&record=$recordid\">" . $outinfos['out_no']. "</a>";
    }
}
/*
期初数量 期初金额
*/
function selInitial($pricetype,$date,$productid,$warehouseid)
{
    global $adb;
	$date =date('Y-m-d', strtotime ("-1 day", strtotime($date)))  . ' 23:59:59';
    $sql = "select a.lastqty,(a.lastqty*b.$pricetype) as unit_price,a.productid,b.$pricetype as pricetype from ld_warehousecondtions a,ld_products b  
    where a.productid = b.productid and a.operationtime < '$date' and a.type != '审批失败' 
    and warehouseid = $warehouseid group by warehouseid,a.productid , a.operationtime asc ";
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    $prev_productid="";
    
    for($i=0;$i<$rows;$i++)
    {
        $productid=$adb->query_result($result,$i,'productid');
        $initialInfo[$productid][0] = $adb->query_result($result,$i,'lastqty');
        $initialInfo[$productid][1] = $adb->query_result($result,$i,'unit_price');
        $initialInfo[$productid][2] = $adb->query_result($result,$i,'pricetype');
    }
    return $initialInfo;
}
/*
期间入库 期间金额
*/
function selBegining($pricetype,$firstdate,$lastdate,$productid,$warehouseid,$ledger)
{
    global $adb;
	$firstdate = $firstdate . ' 00:00:00';
	$lastdate = $lastdate . ' 23:59:59';
    /**
     * 更新操作
     * edit:can
     * date:20140103
     * reason:6524: 库存台账：当台账包含盘点记录复选框为勾选时，盘点确认、撤销盘点操作后，期间入库、期间出库数量计算不正确，没有把盈亏数量计算进去
     * */
    $sql = "select (sum(ifnull(a.inputqty,0) )-sum(ifnull(a.outputqty,0))) as  inputqty,
        (sum(ifnull(a.inputqty,0) *ifnull( b.$pricetype,0))-sum(ifnull(a.outputqty,0) *ifnull( b.$pricetype,0))) as unit_price,a.productid 
        from ld_warehousecondtions a, ld_products b where    a.warehouseid = $warehouseid and a.productid = b.productid 
    
   and a.operationtime >= '$firstdate' and a.operationtime <= '$lastdate'  ";
	//入库单是否启用审批流程
	$deployarray_approve=getSys_deploy(136);
	if($deployarray_approve['deploy_value']==0){
		$query = "select GROUP_CONCAT(stock_id) from ld_stock where approvestatus = '已拒绝'";
		$result = $adb->pquery($query,array());
		$out_id_str = $adb->query_result($result,0,0);
		if(!empty($out_id_str)){
			if(!empty($out_id_str)){
				$sql .= " and a.entityid not in (".$out_id_str.")";
			}
		}
	}
    $sql.=  " and (type='确认初始库存' or type='确认入库' or type='撤销入库' or type ='退货入库' or type ='新增入库单' or type ='编辑入库单' or type ='删除入库单' or type ='调入仓库' or type ='撤销调出仓库' ";
    if($ledger == 1)
    {
        $sql .= " or (`type` = '确认盘点' and a.inputqty>0) or (type = '撤销盘点' and a.outputqty>0) ";
    }
    $sql.=' ) group by  a.warehouseid,a.productid   ';
  
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++)
    {
        $productid=$adb->query_result($result,$i,'productid');
        $inputqty= $adb->query_result($result,$i,'inputqty');
		$beginingArray[$productid][0] = $inputqty;
		$beginingArray[$productid][1] =  $adb->query_result($result,$i,1);
    }
   
    
    
    return $beginingArray;
}

/*
期间出库  期间出库金额
*/
function selOutput($pricetype,$firstdate,$lastdate,$productid,$warehouseid,$ledger)
{
    global $adb;
	$firstdate = $firstdate . ' 00:00:00';
	$lastdate = $lastdate . ' 23:59:59';
     /**
     * 更新操作
     * edit:can
     * date:20140103
     * reason:6524: 库存台账：当台账包含盘点记录复选框为勾选时，盘点确认、撤销盘点操作后，期间入库、期间出库数量计算不正确，没有把盈亏数量计算进去
     * */
    $sql = "select (sum(ifnull(a.outputqty,0) ) - sum(ifnull(a.inputqty,0))) as outputqty, 
(sum(ifnull(a.outputqty,0) * ifnull(b.$pricetype,0) ) - sum(ifnull(a.inputqty,0) * ifnull(b.$pricetype,0) ))as inunit_price ,a.productid
from ld_warehousecondtions a, ld_products b,ld_warehouse c 
where a.warehouseid = c.id
        and   a.productid = b.productid and a.warehouseid = $warehouseid
    and a.operationtime >= '$firstdate' and a.operationtime <= '$lastdate' 
    ";
	//出库单是否启用审批流程
	$deployarray_approve=getSys_deploy(135);
	if($deployarray_approve['deploy_value']==0){
		$query = "select GROUP_CONCAT(out_id) from ld_outboundorder where approvestatus = '已拒绝'";
		$result = $adb->pquery($query,array());
		$out_id_str = $adb->query_result($result,0,0);
		if(!empty($out_id_str)){
			$sql .= " and a.entityid not in (".$out_id_str.")";
		}
	}
	$sql .= " and ( type='退货出库' or type='确认出库' or type='撤销出库'or type='新增出库单' or type='编辑出库单' or type='删除出库单' or type='撤销调入仓库' or type='调出仓库' or type='撤销退货'";
    if($ledger == 1)
    { 
        $sql.=" or (type='撤销盘点' and a.inputqty>0) or (type='确认盘点' and a.outputqty>0) ";
    }
    $sql.=' ) group by a.warehouseid,a.productid';
    $result=$adb->pquery($sql,array());
   
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++)
    {
        $productid=$adb->query_result($result,$i,'productid');
        $outputqty= $adb->query_result($result,$i,'outputqty');
        $outputArray[$productid][0] = $outputqty;
        $outputArray[$productid][1] = $adb->query_result($result,$i,1);
    }
    return $outputArray;
}
/*
查询产品单价
*/
function selProduct($productid,$pricetype)
{
    global $adb;
    $sql = "select $pricetype from ld_products where productid = ?";
    return $adb->query_result($adb->pquery($sql,array($productid)),0,0);
}
function getWareProductIdAll($userid)
{
    global $adb,$current_user;
    
    require('user_privileges/user_privileges_'.$current_user->id.'.php');
    $result = selWareAll();
    $num_rows=$adb->num_rows($result);
    for($i=0;$i<$num_rows;$i++){
        $Array[$i] = $adb->query_result($result,$i,'id');
    }
    return $Array;
}
function  formatPrice($value, $decimal=2)
{
	$currencyField = new CurrencyField($value);
	return $currencyField->getDisplayValue(null, true);
}
/*echo '<pre>';
print_r($InventoryArray);
echo '</pre>';
die;*/
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
$contacts_field_obj=Field::getInstance('Products',$adb);
$productFieldlabels=$contacts_field_obj->getFieldLables();
$header = array(getFixedlabel('SEQUENCE'),getFixedlabel('WAREHOUSE'),$productFieldlabels['productname'],$productFieldlabels['product_no'],$productFieldlabels['productsheet'],$productFieldlabels['productcategory'],getFixedlabel('OPENNUMBER'),getFixedlabel('OPENAMOUNT'),getFixedlabel('DURINGSTORAGE'),getFixedlabel('AMOUNTSTORAGE'),getFixedlabel('DURINGLIBRARY'),getFixedlabel('AMOUNTLIBRARY'),getFixedlabel('ENDNUMBER'),getFixedlabel('ENDAMOUNT'));

$headerlang = count($header);
for($i=0;$i<$headerlang;$i++) {
	$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($i).'1',trim($header[$i]));
}

$j = 2;
foreach($InventoryArray as $arr){
	foreach($arr as $a){
		$for_i = 0;
		foreach($a as $fld=>$value){
			if(in_array($fld,array('warehouseid','productid'))) continue;
			if($value == '&&'){
				$value = '';
			}else if($value == '&nbsp;'){
				$value = '';
			}else{
				$value = str_replace('&yen;','¥',strip_tags($value));
			}
			//$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i).$j,trim($value));
            $activesheet->setCellValueExplicit(PHPExcel_Cell::stringFromColumnIndex($for_i).$j, trim($value),PHPExcel_Cell_DataType::TYPE_STRING);
       
			++ $for_i;
		}
		++ $j;
	}
}

$moduleName = $currentModule;
$modulelabel = getTranstab($moduleName);

$modulelabel = str_replace(' ','_',$modulelabel);

$objPHPExcel->getActiveSheet()->setTitle($moduleName);
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save('storage/'.$moduleName.'.xls');
//下载文件
$file_name = ''.$moduleName.'.xls';
$file_dir = 'storage/';
$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir.$file_name));
Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
Header("pragma: no-cache");
ob_clean();
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();
?>