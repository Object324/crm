<?php
global $weixin_user;
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($_REQUEST['from_module']);

if(!empty($_REQUEST['mode'])){
    $stagename_target = $_REQUEST['advance_stage_value'];
    $TaskcheckResult_arr = $cls_module_advance->TaskCompleteCheck($_REQUEST['recordid'],$stagename_target);
    $allow_push = $TaskcheckResult_arr['allow_push'][$stagename_target];
    $return_msg='';

    if($weixin_user->environment == 'weixin'){
        if(is_array($TaskcheckResult_arr)&&is_array($TaskcheckResult_arr['errormsg_arr'][$stagename_target])) {
            $return_msg = implode("\r\n", $TaskcheckResult_arr['errormsg_arr'][$stagename_target]);
        }
        else{
            $return_msg=$TaskcheckResult_arr['errormsg_arr'][$stagename_target];
        }
    }else{
        if(is_array($TaskcheckResult_arr)&&is_array($TaskcheckResult_arr['errormsg_arr'][$stagename_target])){
            $return_msg = implode("<br>",$TaskcheckResult_arr['errormsg_arr'][$stagename_target]);
        }
        else{
            $return_msg=$TaskcheckResult_arr['errormsg_arr'][$stagename_target];
        }
    }


    if($allow_push == 'no'){
        ConvertTojsonString(-1,array(),$return_msg);
    }
    if($_REQUEST['confirm_save'] !='yes' && $allow_push == 'yes' && $return_msg != ''){
        ConvertTojsonString('confirm_save',array(),$return_msg);
    }
    
	if($_REQUEST['mode'] == 'complete'){
		$result = $cls_module_advance->completeModuleAdvanceStage($_REQUEST['recordid']);
	}else{
		$result = $cls_module_advance->updateModuleAdvanceStage($_REQUEST['recordid'],$_REQUEST['advance_stage_value']);
		if($cls_module_advance->errorDescription != ''){
			ConvertTojsonString(-2,$result,$cls_module_advance->errorDescription);
		}
	}

    crm_load_class_file("cls_savereverse", 'include/SaveReverse');
    $workflowreverseobj = cls_savereverse::getInstance($_REQUEST['from_module']);
    $workflowreverseobj->setPageMode('Advanced');
    $receive_msg = $workflowreverseobj->checkCallApiPop();
    $result['workflow']['receive_msg'] = $receive_msg;
    if ($receive_msg == 'yes') {
        $result['workflow']['record'] = $_REQUEST['recordid'];
        $result['workflow']['module'] = $_REQUEST['from_module'];
        $result['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
    }
}

ConvertTojsonString(1,$result,'success');
?>