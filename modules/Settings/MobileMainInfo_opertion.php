<?php
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['maininfo_id'])){
    $query = 'select fieldname,showtag,presence,sequence from ld_fieldwxmaininfo where id = ?';
    $result = $adb->pquery($query,array($_REQUEST['maininfo_id']));
    $presence = $adb->query_result($result,0,'presence');
    $sequence = $adb->query_result($result,0,'sequence');
    $showtag = $adb->query_result($result,0,'showtag');
    $mainfieldname = $adb->query_result($result,0,'fieldname');
}
//头部字段不支持的uitype
$nonsupport = array('69','1109','1108','28','202','200','222','306','230');
if(!empty($_REQUEST['frommodule'])){
    $tabid = getTabid($_REQUEST['frommodule']);
    $query = 'select fieldname from ld_fieldwxmaininfo where tabid = ?';
    if(!empty($_REQUEST['maininfo_id'])){
        $query .= ' and id != ' . $_REQUEST['maininfo_id'];
    }
    $result = $adb->pquery($query,array($tabid));
    $num_rows = $adb->num_rows($result);
    for($i = 0;$i < $num_rows;$i++){
        $col = $adb->query_result($result,$i,'fieldname');
        $haveFields[] = $col;
    }
    $fieldobj=Field::getInstance($_REQUEST['frommodule'],$adb);
    $moduleFields=$fieldobj->getModuleFields();

    foreach($moduleFields as $fieldname => $fieldinfo){
        $uitype = $fieldinfo->getUIType();
        if(in_array($uitype,$nonsupport)) continue;
        if(!in_array($fieldname,$haveFields)){
            $allFields[$fieldname] = array(
                'fieldlabel' => $fieldinfo->getFieldLabel(),
                'fieldname' => $fieldname,
            );
        }
    }
}
$smarty->assign('MAININFOID',$_REQUEST['maininfo_id']);
$smarty->assign('FIELDNAME',$mainfieldname);
$smarty->assign('PRESENCE',$presence);
$smarty->assign('SHOWTAG',$showtag);
$smarty->assign('LINENUMBER',$sequence);
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
$smarty->assign('ALLFIELDS',$allFields);
$smarty->display('MobileMainInfo_create.tpl');

$arr['title'] = getFixedLabel("MobileAppMainInfoCustomization");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("MobileMainInfo_create.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>