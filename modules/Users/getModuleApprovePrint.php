<?php

global $adb;
if(!empty($_REQUEST['print_module']) && !empty($_REQUEST['record']) && !empty($_REQUEST['printid'])){
	$print_module = $_REQUEST['print_module'];
    //ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印（打印模块开启了审批且设置了审批通过后才允许打印时才去判断单据是否已批准）
    $approve_focus = Approve::getInstance($print_module);
    $approveModules = $approve_focus->getApproveModuleInfo();//获取当前的打印模块是否开启审批
	if(in_array($print_module, $approveModules)){
        $approvedallowprint = 'no';//是否审批通过后才允许打印
        $sql = 'select approvedallowprint from ld_templateprint where tabid = ? and templateprintid = ?';
        $result = $adb->pquery($sql,array(getTabid($print_module), $_REQUEST['printid']));
        $approvedallowprint = $adb->query_result($result,0,0);
        if ($approvedallowprint == 'yes') {
            $focus = CRMEntity::getInstance($print_module);
            $query = 'select approvestatus from ' . $focus->table_name . ' where ' . $focus->table_index . ' = ' . $_REQUEST['record'] . ' limit 1 ';
            $result = $adb->pquery($query,array());
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 1){
                $approvestatus = $adb->query_result($result,0,0);
            }
            if($approvestatus != constant('D_A_S_APPROVED')){
                echo 'error';die;
            }
        }

	}
    $focus = CRMEntity::getInstance($print_module);
    $query = 'update ' . $focus->table_name . ' set print_times = print_times + 1 where ' . $focus->table_index . ' = ' . $_REQUEST['record'] ;
    $adb->pquery($query,array());

	echo 'success';die;
}

?>