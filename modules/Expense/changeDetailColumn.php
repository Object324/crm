<?php
//联合技术MER特殊控制
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
global $mod_strings;
if(!empty($_REQUEST['expensetype'])){
	$focus = CRMEntity::getInstance('Expense');
	$expensetype = strtolower($_REQUEST['expensetype']);
	$expensetypeinfo = $focus->getExpenseTypeInfo();
	$column = getNoneDetailColumn($expensetype);
	$expensetype_json['hidden_column'] = $column;
	$expensetype_json['select_column'] = $expensetypeinfo;
	$json = json_encode($expensetype_json);
	echo $json;
	exit();
}
function getNoneDetailColumn($expensetype){
	switch($expensetype){
		case 'transportation':
		   $column = 'restaurantname,mileage,reimburserate';
		   break;
		case 'businessmeals':
		   $column = 'from,to,mileage,reimburserate';
		   break;
		case 'mileagereimbursement':
		   $column = 'restaurantname,currency_id,conversion_rate,money';
		   break;
		case 'materialsandothers':
		   $column = 'from,to,restaurantname,mileage,reimburserate';
		   break;
	}
	return $column;
}
?>