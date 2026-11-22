<?php
header("Content-type: text/html; charset=utf-8");
require 'modules/Home/WorkReportController.php';
$focus = new WorkReportController();
$method = $_REQUEST['method'];
$worktype = $_REQUEST['worktype'];

if(method_exists($focus,$method)){
    $focus->model->setWorktype($worktype);
	$entity = $focus->$method();
	if(!empty($entity)){
		// require_once('./include/Zend/Json.php');
		$json = new Zend_Json();
        if($_REQUEST['roleid']!=''){
                foreach($entity['report'] as $key=>$arr){
                    if($arr['Accounts']!=''||$arr['Contacts']!=''){
                        if((!deep_in_array($_REQUEST['roleid'],$arr['Accounts']))
                        &&(!deep_in_array($_REQUEST['roleid'],$arr['Contacts']))){
                            unset($entity['report'][$key]);
                        }
                    }else{
                        unset($entity['report'][$key]);
                    }
                }        
        }

		$jsonentity = $json->encode($entity);
		echo $jsonentity;die;
	}
}
    function deep_in_array($value, $array) { 
            foreach($array as $item) { 
                if(!is_array($item)) { 
                    if ($item == $value) {
                        return true;
                    } else {
                        continue; 
                    }
                } 
                if(in_array($value, $item)) {
                    return true; 
                } else if(deep_in_array($value, $item)) {
                    return true; 
                }
            } 
            return false; 
    }
echo '';die;
?>