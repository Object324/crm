<?php
//更新地址信息
global  $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;
$smarty = new lingdangCRM_Smarty();
$currentModule = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($currentModule);
$focus->getModuleLogic($currentModule);//->getListViewButtons();
$moduleFields=$focus->fieldobj->getModuleFields();

$main_table = $focus->table_name;//模块主表
$custom_table = $focus->customFieldTable[0];//自定义字段表
$detail_table = $focus->Detail_table;
$tableindex = $focus->table_index;//模块表主键

$select_ids = $_REQUEST['select_ids'];
if($select_ids != 'all'){
	$select_ids = explode(';',$select_ids);
}
$address_fields = [//地址字段，不同模块修改为不同即可
	"location_address" => 'cf_7816',
	"state" => 'cf_7829',
	"city" => 'cf_7830',
	"area" => 'cf_7832' 
];

$sql = 'SELECT ld_account.bill_street,ld_account.bill_state,ld_account.bill_city,ld_account.bill_area FROM ld_account ';
$sql .=  " LEFT JOIN ".$main_table." ON ld_account.accountid = ".$main_table.".accountid";
$sql .=  " WHERE ".$main_table.".".$tableindex." = ?";
foreach($select_ids as $key => $selectid){
	$result = $adb->pquery($sql,array($selectid));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$location_address = $adb->query_result($result,$i,'bill_street');
			$state = $adb->query_result($result,$i,'bill_state');
			$city = $adb->query_result($result,$i,'bill_city');
			$area = $adb->query_result($result,$i,'bill_area');
		}
	}
	// dump($location_address);

	$updatesql = "UPDATE ".$custom_table." LEFT JOIN ".$main_table." ON ".$custom_table.".".$tableindex." = ".$main_table.".".$tableindex." SET " ;
	$updatesql .= $custom_table.".".$address_fields["location_address"]." =? , ".$custom_table.".".$address_fields["state"]." =? , ".$custom_table.".".$address_fields["city"]." =? , ".$custom_table.".".$address_fields["area"]." =?";
	$updatesql .= " WHERE ".$main_table.".".$tableindex." = ?";
	$adb->pquery($updatesql,array($location_address,$state,$city,$area,$selectid));
}
// dump($select_ids);

$_REQUEST['diony'] = 'yes';
ConvertTojsonString(1,$arr,'success');	
?>