<?php
/**
 * edit:can 20200805
 * 应付费用运输单获取供应商报价单信息
 * */
$_REQUEST['diony']='yes';
global $adb,$current_user;
/**
 * 派车计划 CustomForm02
 * 车型：carriage_type
 * 订单1：yunshudanid_01(运输订单)，startplace_01(提货点1),endplace_01:送货点
 * 订单2：yunshudanid_02(运输订单)startplace_02(提货点2),endplace_02:送货点
 * 订单3：yunshudanid_03(运输订单)startplace_03(提货点3),endplace_03:送货点
 * 订单4：yunshudanid_04(运输订单)startplace_04(提货点4),endplace_04:送货点
 * */
/**
* 供应商报价单PurchaseOrder
* 起运地：sf5099，目的地：sf5235，车型：sf5371
* */
/**
* 运输订单 CustomForm23
* 车型：carriage_type
* sf158:启运地，sf161:目的地
* 毛重：sf204
* */
 $deploy_value=getSys_deploy(49);//单据明细中数量小数位数
 $decimallen=$deploy_value['deploy_value'];
 $customform02table='ld_customform02';
 $customform02tablescf='ld_customform02scf';
 $customform02tableindex='customform02id';
 
 //运输订单
 $customform23detailtable='ld_customform23detail';
 $customform23detailtablescf='ld_customform23detailscf';
 $customform23tablename='ld_customform23';
 $customform23tableindex="customform23id";
 $customform23tablenamescf='ld_customform23scf';
 $start_address='startplace';
 $end_address='endplace';
 $selectid=$_REQUEST['selectid'];
 
// @edit:luyx @date:2020-08-19 @reason: 运输的应收、应付费用单“数量（计费数值）”计算
//原算法:
    //1、“数量”是带出运输订单分录的毛重“合计”。增加判断：如果	运输订单“零担”为“是”，则取单据头的“计费重量”，不是才取单据分录毛重合计
    //2、 CustomForm23 零担 ：cf_3052,计费重量：cf_3076
//新算法:
    //1、不管是不是零担，都从派车计划头抓取（不取运输订单）
    //2、如果费用项目是“客户端装/卸货费”取字段“计费数值” （4个字段相加）；其他费用项目取字段“计费重量”（4个字段相加）

/*
$sql="select * from ( select case when  $customform23tablenamescf.cf_3052='是' then $customform23tablenamescf.cf_3076 else sum(ifnull(sf204,0)) end  as totalweight,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address  ,'1' as type 
from $customform23tablename 
 inner join $customform23tablenamescf on  $customform23tablenamescf.$customform23tableindex=$customform23tablename.$customform23tableindex
 inner join $customform23detailtable on $customform23detailtable.id=$customform23tablename.$customform23tableindex and $customform23tablename.deleted=0   
 inner join $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
 inner join $customform02table on  $customform02table.yunshudanid_01=$customform23tablename.$customform23tableindex
     and $customform02table.yunshudanid_01>0 
 and $customform02table.carriage_type=$customform23tablename.carriage_type  and $customform02table.$customform02tableindex=?
 inner join $customform02tablescf on $customform02tablescf.$customform02tableindex=$customform02table.$customform02tableindex

 union all
 select case when  $customform23tablenamescf.cf_3052='是' then $customform23tablenamescf.cf_3076 else sum(ifnull(sf204,0)) end  as totalweight,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address  ,'2' as type
from $customform23tablename 
    inner join $customform23tablenamescf on  $customform23tablenamescf.$customform23tableindex=$customform23tablename.$customform23tableindex
 inner join $customform23detailtable on $customform23detailtable.id=$customform23tablename.$customform23tableindex and $customform23tablename.deleted=0 
 inner join $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
 inner join $customform02table on $customform02table.yunshudanid_02=$customform23tablename.$customform23tableindex
                 and $customform02table.yunshudanid_02>0 
 and $customform02table.carriage_type=$customform23tablename.carriage_type and $customform02table.$customform02tableindex=?
 inner join $customform02tablescf on $customform02tablescf.$customform02tableindex=$customform02table.$customform02tableindex

 union all
 select case when  $customform23tablenamescf.cf_3052='是' then $customform23tablenamescf.cf_3076 else sum(ifnull(sf204,0)) end  as totalweight,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address ,'3' as type
from $customform23tablename 
    inner join $customform23tablenamescf on  $customform23tablenamescf.$customform23tableindex=$customform23tablename.$customform23tableindex
  inner join $customform23detailtable  on $customform23detailtable.id=$customform23tablename.$customform23tableindex and $customform23tablename.deleted=0 
 inner join $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
 inner join $customform02table on  $customform02table.yunshudanid_03=$customform23tablename.$customform23tableindex
     and $customform02table.yunshudanid_03>0 
 and $customform02table.carriage_type=$customform23tablename.carriage_type  and $customform02table.$customform02tableindex=?
 inner join $customform02tablescf on $customform02tablescf.$customform02tableindex=$customform02table.$customform02tableindex

 union all
  select case when  $customform23tablenamescf.cf_3052='是' then $customform23tablenamescf.cf_3076 else sum(ifnull(sf204,0)) end  as totalweight ,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address  ,'4' as type
from $customform23tablename  
inner join $customform23tablenamescf on  $customform23tablenamescf.$customform23tableindex=$customform23tablename.$customform23tableindex
inner join $customform23detailtable on $customform23detailtable.id=$customform23tablename.$customform23tableindex and $customform23tablename.deleted=0 
 inner join $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
 inner join $customform02table on  $customform02table.yunshudanid_04=$customform23tablename.$customform23tableindex 
 and $customform02table.yunshudanid_04>0 
 and $customform02table.carriage_type=$customform23tablename.carriage_type and $customform02table.$customform02tableindex=?
 inner join $customform02tablescf on $customform02tablescf.$customform02tableindex=$customform02table.$customform02tableindex
 ) as tmp group by type, $start_address,$end_address;
";

$result=$adb->pquery($sql,array($selectid,$selectid,$selectid,$selectid));
$totalweight_arr=array();
$all_totalweigth=0;
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $type=$adb->query_result($result,$i,'type');
    //$totalweight=$adb->query_result($result,$i,'totalweight');
    $sf202value=$adb->query_result($result,$i,$start_address);//启运地
    $sf203value=$adb->query_result($result,$i,$end_address);//目的地
	//$all_totalweigth+=$totalweight;
    //$totalweight_arr[$type.$start_address.$end_address]=number_format($totalweight,$decimallen, '.', '');//setNumberFormat($totalweight,$decimallen);
    
}

//计费重量 抓取派车计划
$sql="SELECT cf_3814+cf_3815+cf_3816+cf_3817 FROM ld_customform02scf WHERE customform02id=? LIMIT 1";
$result=$adb->pquery($sql,array($selectid));
$all_totalweigth=$adb->query_result($result,'totalweight');
$all_totalweigth=number_format($all_totalweigth,$decimallen, '.', '');

//获取运输订单的装货地点和送货地点
$tmpsql="select yunshudanid_01,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address ,'1' as yunshuordertype from $customform02table
INNER JOIN $customform23tablename 
on $customform23tablename.$customform23tableindex=$customform02table.yunshudanid_01
INNER JOIN $customform23detailtable on $customform23detailtable.id=$customform23tablename.$customform23tableindex
INNER JOIN $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
and $customform23tablename.deleted=0  and $customform02table.$customform02tableindex=?
union all
select yunshudanid_02,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address ,'2' as yunshuordertype from $customform02table
INNER JOIN $customform23tablename 
on $customform23tablename.customform23id=$customform02table.yunshudanid_02
INNER JOIN $customform23detailtable on $customform23detailtable.id=$customform23tablename.$customform23tableindex
INNER JOIN $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
and $customform23tablename.deleted=0  and $customform02table.$customform02tableindex=?
union all
select yunshudanid_03,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address ,'3' as yunshuordertype from $customform02table
INNER JOIN $customform23tablename 
on $customform23tablename.customform23id=$customform02table.yunshudanid_03
INNER JOIN $customform23detailtable on $customform23detailtable.id=ld_customform23.$customform23tableindex
INNER JOIN $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
and $customform23tablename.deleted=0 and $customform02table.$customform02tableindex=?
union all
select yunshudanid_04,$customform02table.startplace_01 as  $start_address
        ,$customform02table.endplace_01 as $end_address ,'4' as yunshuordertype from $customform02table
INNER JOIN $customform23tablename 
on $customform23tablename.customform23id=$customform02table.yunshudanid_04
INNER JOIN $customform23detailtable on $customform23detailtable.id=$customform23tablename.$customform23tableindex
INNER JOIN $customform23detailtablescf on $customform23detailtablescf.lineitem_id=$customform23detailtable.lineitem_id
and $customform23tablename.deleted=0 and $customform02table.$customform02tableindex=? ";

//获取供应商报价单信息
$sql="
	SELECT
		ld_purchaseorder.purchaseorderid,
		ld_purchaseorder.purchaseorder_no,ld_purchaseorder.currency_id as source_currency_id,
		ld_purchaseorderdetail.*,
		ld_purchaseorderdetailscf.*, ld_products.*, ld_productcf.*, tmpaddress.$start_address,
		tmpaddress.$end_address,
		tmpaddress.yunshudanid_01 AS yunshudanid,
		tmpaddress.yunshuordertype
	FROM
		$customform02table
	INNER JOIN $customform02tablescf ON $customform02table.$customform02tableindex = $customform02tablescf.$customform02tableindex
	INNER JOIN ld_purchaseorder ON ld_purchaseorder.purchaseorderid = $customform02table.purchaseorder_id
	INNER JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.id = ld_purchaseorder.purchaseorderid
	INNER JOIN ld_purchaseorderdetailscf ON ld_purchaseorderdetailscf.lineitem_id = ld_purchaseorderdetail.lineitem_id
	AND $customform02table.carriage_type = ld_purchaseorderdetailscf.sf5371
	INNER JOIN ld_products ON ld_products.productid = ld_purchaseorderdetail.productid
	INNER JOIN ld_productcf ON ld_productcf.productid = ld_products.productid
	INNER JOIN ($tmpsql) AS tmpaddress ON tmpaddress.$start_address = ld_purchaseorderdetailscf.sf5099
	AND tmpaddress.$end_address = ld_purchaseorderdetailscf.sf5235
	WHERE
		$customform02table.$customform02tableindex =?
	GROUP BY
		ld_purchaseorderdetail.lineitem_id
	UNION
	SELECT
		a.purchaseorderid,
		a.purchaseorder_no,
        a.currency_id as source_currency_id,
		c.*,
		d.*, 
		p.*, 
		q.*, 
		NULL,
		NULL,
		NULL,
		NULL
	FROM ld_purchaseorder a
	INNER JOIN ld_customform02 b ON a.purchaseorderid=b.purchaseorder_id
	INNER JOIN ld_purchaseorderdetail c ON c.id=a.purchaseorderid
	INNER JOIN ld_purchaseorderdetailscf d ON d.lineitem_id=c.lineitem_id
	INNER JOIN ld_products p ON p.productid=c.productid
	INNER JOIN ld_productcf q ON q.productid=p.productid
	WHERE b.customform02id=?
		AND IFNULL(d.sf5099,'')='' 
		AND IFNULL(d.sf5235,'')=''
		AND IFNULL(d.sf5371,'')=''
 ";
*/

$sql="
    SELECT
    	ld_purchaseorder.purchaseorderid,
    	ld_purchaseorder.purchaseorder_no,
    	ld_purchaseorder.currency_id AS source_currency_id,
    	ld_purchaseorderdetail.*, 
    	ld_purchaseorderdetailscf.*, 
    	ld_products.*, 
    	ld_productcf.*, 
    	tmpaddress.startplace,
    	tmpaddress.endplace,
    	tmpaddress.yunshudanid_01 AS yunshudanid,
    	tmpaddress.yunshuordertype,
    	CASE
    		WHEN ld_products.productname IN ('客户端装/卸货费','Kitting费') THEN IFNULL(ld_customform02scf.cf_3827,0)+IFNULL(ld_customform02scf.cf_3828,0)+IFNULL(ld_customform02scf.cf_3829,0)+IFNULL(ld_customform02scf.cf_3830,0)
    		ELSE IFNULL(ld_customform02scf.cf_3814,0)+IFNULL(ld_customform02scf.cf_3815,0)+IFNULL(ld_customform02scf.cf_3816,0)+IFNULL(ld_customform02scf.cf_3817,0)
    	END AS totalweight
    FROM ld_customform02
    INNER JOIN ld_customform02scf ON ld_customform02.customform02id = ld_customform02scf.customform02id
    INNER JOIN ld_purchaseorder ON ld_purchaseorder.purchaseorderid = ld_customform02.purchaseorder_id
    INNER JOIN ld_purchaseorderdetail ON ld_purchaseorderdetail.id = ld_purchaseorder.purchaseorderid
    INNER JOIN ld_purchaseorderdetailscf ON ld_purchaseorderdetailscf.lineitem_id = ld_purchaseorderdetail.lineitem_id AND ld_customform02.carriage_type = ld_purchaseorderdetailscf.sf5371
    INNER JOIN ld_products ON ld_products.productid = ld_purchaseorderdetail.productid
    INNER JOIN ld_productcf ON ld_productcf.productid = ld_products.productid
    INNER JOIN (
    	SELECT
    		yunshudanid_01,
    		ld_customform02.startplace_01 AS startplace,
    		ld_customform02.endplace_01 AS endplace,
    		'1' AS yunshuordertype
    	FROM ld_customform02
    	INNER JOIN ld_customform23 ON ld_customform23.customform23id = ld_customform02.yunshudanid_01
    	INNER JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
    	INNER JOIN ld_customform23detailscf ON ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
    		AND ld_customform23.deleted = 0
    		AND ld_customform02.customform02id =?
    	UNION ALL
    	SELECT
    		yunshudanid_02,
    		ld_customform02.startplace_01 AS startplace,
    		ld_customform02.endplace_01 AS endplace,
    		'2' AS yunshuordertype
    	FROM ld_customform02
    	INNER JOIN ld_customform23 ON ld_customform23.customform23id = ld_customform02.yunshudanid_02
    	INNER JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
    	INNER JOIN ld_customform23detailscf ON ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
    	AND ld_customform23.deleted = 0
    	AND ld_customform02.customform02id =?
    	UNION ALL
    	SELECT
    		yunshudanid_03,
    		ld_customform02.startplace_01 AS startplace,
    		ld_customform02.endplace_01 AS endplace,
    		'3' AS yunshuordertype
    	FROM
    		ld_customform02
    	INNER JOIN ld_customform23 ON ld_customform23.customform23id = ld_customform02.yunshudanid_03
    	INNER JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
    	INNER JOIN ld_customform23detailscf ON ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
    		AND ld_customform23.deleted = 0
    		AND ld_customform02.customform02id =?
    	UNION ALL
    	SELECT
    		yunshudanid_04,
    		ld_customform02.startplace_01 AS startplace,
    		ld_customform02.endplace_01 AS endplace,
    		'4' AS yunshuordertype
    	FROM
    		ld_customform02
    	INNER JOIN ld_customform23 ON ld_customform23.customform23id = ld_customform02.yunshudanid_04
    	INNER JOIN ld_customform23detail ON ld_customform23detail.id = ld_customform23.customform23id
    	INNER JOIN ld_customform23detailscf ON ld_customform23detailscf.lineitem_id = ld_customform23detail.lineitem_id
    		AND ld_customform23.deleted = 0
    		AND ld_customform02.customform02id =?
    ) AS tmpaddress ON tmpaddress.startplace = ld_purchaseorderdetailscf.sf5099
    AND tmpaddress.endplace = ld_purchaseorderdetailscf.sf5235
    WHERE ld_customform02.customform02id =?
    GROUP BY ld_purchaseorderdetail.lineitem_id
    UNION
    SELECT
    	a.purchaseorderid,
    	a.purchaseorder_no,
    	a.currency_id AS source_currency_id,
    	c.*, 
    	d.*, 
    	p.*, 
    	q.*, 
    	NULL,
    	NULL,
    	NULL,
    	NULL,
    	CASE
    		WHEN p.productname='客户端装/卸货费' THEN IFNULL(ld_customform02scf.cf_3827,0)+IFNULL(ld_customform02scf.cf_3828,0)+IFNULL(ld_customform02scf.cf_3829,0)+IFNULL(ld_customform02scf.cf_3830,0)
    		ELSE IFNULL(ld_customform02scf.cf_3814,0)+IFNULL(ld_customform02scf.cf_3815,0)+IFNULL(ld_customform02scf.cf_3816,0)+IFNULL(ld_customform02scf.cf_3817,0)
    	END AS totalweight
    FROM ld_purchaseorder a
    INNER JOIN ld_customform02 b ON a.purchaseorderid = b.purchaseorder_id
    INNER JOIN ld_customform02scf ON ld_customform02scf.customform02id=b.customform02id
    INNER JOIN ld_purchaseorderdetail c ON c.id = a.purchaseorderid
    INNER JOIN ld_purchaseorderdetailscf d ON d.lineitem_id = c.lineitem_id
    INNER JOIN ld_products p ON p.productid = c.productid
    INNER JOIN ld_productcf q ON q.productid = p.productid
    WHERE b.customform02id =?
    	AND IFNULL(d.sf5099, '') = ''
    	AND IFNULL(d.sf5235, '') = ''
    	AND IFNULL(d.sf5371, '') = ''
";


$result=$adb->pquery($sql,array($selectid,$selectid,$selectid,$selectid,$selectid,$selectid));

$rows=$adb->num_rows($result);
$purchaseorderfocus=CRMEntity::getInstance("PurchaseOrder");
$modulefields=$purchaseorderfocus->detailfieldobj->getModuleFields();

crm_load_class_file('showProductDetailFieldValue','include/fields');
         
 $arr=array();
 for($i=0;$i<$rows;$i++)
 {
    $purchaseorderid=$adb->query_result($result,$i,'purchaseorderid');
    $purchaseorder_no=$adb->query_result($result,$i,'purchaseorder_no');//运输单供应商报价单编号
    $currency_id=$adb->query_result($result,$i,'source_currency_id');//币种
    $yunshudanid=$adb->query_result($result,$i,'yunshudanid');
    $yunshuordertype=$adb->query_result($result,$i,'yunshuordertype');
    $sf202value=$adb->query_result($result,$i,$start_address);//启运地
    $sf203value=$adb->query_result($result,$i,$end_address);//目的地
    $totalweight=$adb->query_result($result,$i,'totalweight');
   //if(array_key_exists($yunshuordertype.$start_address.$end_address,$totalweight_arr)&&$yunshudanid>0)
      //  $totalweight=$totalweight_arr[$yunshuordertype.$start_address.$end_address];
   
    $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
    $productid=$adb->query_result($result,$i,'productid');
    $totalweight=number_format($totalweight,$decimallen, '.', '');//setNumberFormat($totalweight,$decimallen);
    
    foreach($modulefields as $tmpcolumnname=>$purchaseorderdetailfieldinfo)
    {
      
            
        $value=$adb->query_result($result,$i,$tmpcolumnname);
              

        $rawValue=$value;
        $tablename=$purchaseorderdetailfieldinfo->getTableName();
        $isdetailfield='no';
        if($tablename=='ld_products'||$tablename=='ld_productcf')
        {
              $showfieldvalueobj=new ShowFieldValue($purchaseorderfocus->fieldobj,"PurchaseOrder",SHOW_POPUP);
        }
        else
        {
            $isdetailfield='yes';
            $showfieldvalueobj=new showProductDetailFieldValue($purchaseorderfocus->fieldobj,"PurchaseOrder",SHOW_DETAILVIEW);
            $showfieldvalueobj->setLine_index($i);
            $showfieldvalueobj->setModuleFields($modulefields);
        }
        $showfieldvalueobj->setRecorId($purchaseorderid);
        $showfieldvalueobj->setadbResult($result);
        $showvalue=$showfieldvalueobj->getFieldValueByField($purchaseorderdetailfieldinfo,$rawValue,$value);
        if($isdetailfield=='yes'&&$purchaseorderdetailfieldinfo->getUIType()==20)
        {
            $typeofdatas=explode(',',$purchaseorderdetailfieldinfo->getTypeOfData());
              if(sizeof($typeofdatas)>1)
              {
                $lengthdecimal=$typeofdatas[1];
              }
			   $showvalue['value'] =  sprintf('%.'.$lengthdecimal.'f',$rawValue);
        }
        $arr['detailfieldvalue'][$i][$tmpcolumnname]=$showvalue['value'];
        
        
    }
  
  
    $arr['detailfieldvalue'][$i]['quantity']=$totalweight;
    //$arr['detailfieldvalue'][$lineitem_id]['productid']=$productid;
    $arr['detailfieldvalue'][$i]['hdnProductId']=$productid;
   
    $arr['detailfieldvalue'][$i]['lineitem_id']=$lineitem_id;
    $arr['detailfieldvalue'][$i]['batchmanagement']=0;
    $arr['detailfieldvalue'][$i]['pricestrategyobj']=array();
    
 }


if($rows<=0)
{
    $sql="select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,ld_purchaseorder.currency_id as source_currency_id from $customform02table 
                  inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$customform02table.purchaseorder_id
                   where  $customform02table.$customform02tableindex=? ";
             
    $result=$adb->pquery($sql,array($selectid));
    $purchaseorderid=$adb->query_result($result,0,'purchaseorderid');
    $purchaseorder_no=$adb->query_result($result,0,'purchaseorder_no');
    $currency_id=$adb->query_result($result,0,'source_currency_id');//币种
}
$arr['purchaseorderid']=$purchaseorderid;
$arr['purchaseorder_no']=$purchaseorder_no;
$arr['currency_id']=$currency_id;
ConvertTojsonString(1,$arr,'success');    
?>