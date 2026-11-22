<?php

global $adb,$current_user,$currentModule;
require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
crm_load_class_file('cls_PhoneSettings',"modules/ShopSettings");
$phoneobj = new cls_PhoneSettings();
$smarty = new lingdangCRM_Smarty;
$smarty->assign('MODULE',$currentModule);
$smarty->assign('OperateMode','create');        //当前操作

if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='edit'){
    $smarty->assign('OperateMode','edit');
    $edit_phoneid = $_REQUEST['recordid'];
    $phoneinfo = $phoneobj->getPhoneinfoById($edit_phoneid);
    $smarty->assign('RECORDID',$phoneinfo['phoneid']);
}

$smarty->assign('PHONE_ID',$phoneinfo['phoneid']);
$smarty->assign('CUSTOMER_NAME',$phoneinfo['name']);
if($phoneinfo['status'] == 'yes') $smarty->assign('STATUS',true);
else $smarty->assign('STATUS',false);
$smarty->assign('PHONE_NUMBER',$phoneinfo['phone']);
$smarty->assign('SQUENCE',$phoneinfo['phoneseq']);
$smarty->assign('MODE',$_REQUEST['mode']);

$_REQUEST['diony']='diony';
//为弹出框的title判断是新建还是编辑
$arr['title'] = $_REQUEST['mode'] == 'edit'? getFixedLabel('EDITCUSTOMER'):getFixedLabel('NEWCUSTOMER');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("modules/ShopSettings/PhoneSettings_edit.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();

function getselectProductCategoryList(){
    global $adb;
    $productcategory_arr = array();
    $query = "select * from ld_picklist_values 
            LEFT JOIN ld_picklist_set on ld_picklist_set.listid=ld_picklist_values.listid 
            where listname='productcategory';";
    $result = $adb->pquery($query,array());
    $rows = $adb->num_rows($result);
    for($i = 0;$i<$rows;$i++){
        $id = $adb->query_result($result,$i,'id');
        $listvalue = $adb->query_result($result,$i,'listvalue');
        $productcategory_arr[] = array('value'=>$id,'text'=>$listvalue);
    }
    return $productcategory_arr;
}
?>