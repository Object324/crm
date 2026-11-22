<?php
/*******************************************************
**更新操作
**edit:kevin
**date:2013-11-14
**reason:库存初始化
*******************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings,$mod_strings,$theme,$currentModule,$adb,$current_user,$default_language;
global $list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty;
/**
 * 更新操作
 * edit:chj
 * date:2013-11-27
 * reason:0005863: 仓库初始化界面：非管理员用户具有全局权限时并没有显示所有仓库的页签
 */ 
$is_admin=is_admin($current_user);
if($is_admin==true){
    $query='select DISTINCT ld_warehouse.name,ld_warehouse.id from ld_warehouse2user left join ld_warehouse on ld_warehouse2user.warehouseid=ld_warehouse.id
where status=0 order by ld_warehouse.id';
$result=$adb->pquery($query,array());
}else{
    $query="
		select id,name from (
			SELECT 
				ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'all' 
			where `status` = 0 
			GROUP BY 
				ld_warehouse.id
			UNION ALL
			SELECT 
				ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'user'
			INNER JOIN ld_users ON ld_warehouse2user.userid = ld_users.id 
			where ld_warehouse2user.userid = ? and ld_warehouse.`status` = 0 
			GROUP BY 
				ld_warehouse.id
			UNION ALL
			SELECT 
				ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'group'
			INNER JOIN ld_groups ON ld_warehouse2user.userid = ld_groups.groupid 
			LEFT JOIN ld_users2group on ld_users2group.groupid = ld_groups.groupid
			where ld_users2group.userid = ? and ld_warehouse.`status` = 0 
			GROUP BY 
				ld_warehouse.id
			UNION ALL
			SELECT 
				 ld_warehouse.id, 
				ld_warehouse.`name`
			FROM 
			ld_warehouse 
			INNER JOIN ld_warehouse2user ON ld_warehouse.id = ld_warehouse2user.warehouseid and ld_warehouse.allocatetype = 'role'
			INNER JOIN ld_profile ON ld_warehouse2user.userid = ld_profile.profileid 
			LEFT JOIN ld_users on ld_users.profileid = ld_profile.profileid 
			where ld_users.id = ? and ld_warehouse.`status` = 0 
			GROUP BY 
				ld_warehouse.id
		) as temp ORDER BY id
	";
		$result=$adb->pquery($query,array($current_user->id,$current_user->id,$current_user->id));
}
$smarty->assign('MAX_RECORDS', $list_max_entries_per_page_new);
$num_rows=$adb->num_rows($result);
if(!$num_rows){
    //echo "<table border='0' cellpadding='5' cellspacing='0' width='100%' height='450px'><tr><td align='center'>";
//	echo "<div style='border: 3px solid rgb(153, 153, 153); background-color: rgb(255, 255, 255); width: 55%; position: relative; z-index: 10000000;'>
//
//		<table border='0' cellpadding='5' cellspacing='0' width='98%'>
//		<tbody><tr>
//		<td rowspan='2' width='11%'><img src='". lingdang_imageurl('denied.gif', $theme) ."' ></td>
//		<td style='border-bottom: 1px solid rgb(204, 204, 204);' nowrap='nowrap' width='70%'><span clas
//		s='genHeaderSmall'>".getFixedLabel('INSUFFICIENTWAREHOUSE')."</span></td>
//		</tr>
//		<tr>
//		<td class='small' align='right' nowrap='nowrap'>
//		<a href='index.php?module=Home&action=index&parenttab=My Home Page'>".getFixedLabel('RETURN')."</a><br>
//		</td>
//		</tr>
//		</tbody></table>
//		</div>";
//	echo "</td></tr></table>";
    include(globalStatic::$root_directory."modules/lingdang/ExitWithoutPermission.php");
	exit;
}
$warehouses=array();
for($i=0;$i<$num_rows;$i++){
    $warehouses[]=array('id'=>$adb->query_result($result,$i,'id'),
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
$smarty->assign('WAREHOUSES',$warehouses);//仓库信息


if(isset($_REQUEST['warehouseid']) && $_REQUEST['warehouseid'])
{
    $warehouseid=$_REQUEST['warehouseid'];
}
else
{
    //$warehouseid = getFirstWareHouse();//默认第一个仓库
	$warehouseid = $warehouses[0]['id'];//直接去能看到的第一个仓库ID
}

$smarty->assign('WAREHOUSEID',$warehouseid);
$query='select started from ld_warehouse where id=?';
$started=$adb->query_result($adb->pquery($query,array($warehouseid)),0,'started');
$smarty->assign('STARTED',$started);
if($started){//是否初始化,1:暂存，0：初始化
    $query='select ld_products.productid,ld_products.productname,ld_products.productsheet,
ld_products.product_no,
case when t1.qty is null then 0.000 else t1.qty
end as qty,case when t1.qty is null then 1 else 0 end as selected from ld_products 
 left join (select * from  ld_warehouse2startedproducts 
where ld_warehouse2startedproducts.warehouseid=?) as t1
on ld_products.productid=t1.productid where ld_products.deleted=0';
}else{
	$query = "SELECT
            		a.warehouseid AS wareid,
            		a.productid,c.productname,c.productsheet,
            		a.batchtext,
            		a.lastqty AS inventory_qty,
            		0 AS dairu_qty,
            		0 AS daichu_qty,
					c.productdate,
					c.protectqualitydate,
					w.name as warehousename,
					a.inputqty as qty,
					case when a.inputqty is null then 0.000 else a.inputqty end as qty,case when a.inputqty is null then 1 else 1 end as selected
            	FROM ld_warehousecondtions a
				INNER JOIN ld_warehouse w on w.id = a.warehouseid
            	inner JOIN ld_products c ON c.productid=a.productid
            	WHERE a.modulename='库存初始化'
            		AND a.type='确认初始库存' and a.warehouseid=? AND c.deleted=0";
}
$noofrows =$adb->num_rows($adb->pquery($query,array($warehouseid)));
$smarty->assign('NUMOFROWS',$noofrows);
$queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
$start = ListViewSession::getRequestCurrentPage($currentModule, $noofrows,0, $queryMode);
$smarty->assign('START',$start);
 crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
   
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//echo $list_query;
//echo $query;
if($noofrows)
{
    /**
     * 更新操作
     * edit:can
     * date:20140103
     * reason:6671: 库存初始化：当一个仓库序列表有多页产品时，翻到最后一页勾选一个新增的产品并输入数量后点击确认按钮后，结果该仓库序列表为空了，产品无法初始化
     * */
     if($limit_start_rec > 0)
		$pagecount=$noofrows/$limit_start_rec;
	 else
		$pagecount = 0;
    
    if($limit_start_rec>$pagecount*$limit_start_rec)
    {
        $limit_start_rec=0;
    }
}

$result = $adb->pquery($query. " LIMIT $limit_start_rec, $list_max_entries_per_page_new", array($warehouseid));

$recordListRangeMsg = getRecordRangeMessage($result, $limit_start_rec,$noofrows);

$smarty->assign('RECORDLISTRANGMSG',$recordListRangeMsg);
// Navigation
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, '', $currentModule, 'index', 0);

$smarty->assign("NAVIGATION", $navigationOutput);

$product_field_obj=Field::getInstance('Products',$adb);
$productFieldlabels =$product_field_obj->getFieldLables();
$smarty->assign('PRODUCTFIELDLABELS',$productFieldlabels);
$num_rows=$adb->num_rows($result);
$products=array();
/**
 * @project PROT75 数量小数位数
 * @author Tujt 2014-08-14 CRMV5.6
 */
$sysdeploy = getSys_deploy(49);
if(isset($sysdeploy['deploy_value']))
	$lengthdecimaldigits = $sysdeploy['deploy_value'];
else
	$lengthdecimaldigits  = 2;
for($i=0;$i<$num_rows;$i++){
    $products[]=array('productid'=>$adb->query_result($result,$i,'productid'),
    'productname'=>$adb->query_result($result,$i,'productname'),
    'productsheet'=>$adb->query_result($result,$i,'productsheet'),
    'product_no'=>$adb->query_result($result,$i,'product_no'),
    'qty'=>sprintf('%.'.$lengthdecimaldigits.'f',$adb->query_result($result,$i,'qty')),
    'selected'=>$adb->query_result($result,$i,'selected')
    );
}
$smarty->assign('PRODUCTS',$products);
$smarty->assign("CURRENT_PAGE_BOXES", implode(array_keys($products),";"));
$smarty->assign('APP',$app_strings);
$smarty->assign('MOD',$mod_strings);
$smarty->assign('THEME',$theme);
$smarty->assign('IMAGE_PATH', "themes/$theme/images/");
$smarty->assign('MODULE',$currentModule);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']=='true')
$smarty->display('Prdtnums/ListViewEntries.tpl');
else
$smarty->display('Prdtnums/ListView.tpl');
/*
function getFirstWareHouse()
{
    global $adb;
    $sql = "select id from ld_warehouse order by id asc limit 1";
    $result = $adb->pquery($sql);
    return $adb->query_result($result,0,0);        
}
?>