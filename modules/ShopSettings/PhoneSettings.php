<?php
global $adb;
$_REQUEST['diony']='yes';
$smarty = new lingdangCRM_Smarty;
crm_load_class_file('cls_PhoneSettings',"modules/ShopSettings");
$phoneobj = new cls_PhoneSettings();
//获取所有ld_shop_phones的行
$allphones=$phoneobj->getAllPhoneinfos();
foreach($allphones as $key=>$phoneinfo)
{
    $phoneid=$phoneinfo['phoneid'];
    $name= $phoneinfo['name'];
    $status= $phoneinfo['status'];
    $phone= $phoneinfo['phone'];
    $phoneseq= $phoneinfo['phoneseq'];

    $list[]=array('phoneid'=>$phoneid,'name'=>$name,'status'=>$status,'phone'=>$phone,'phoneseq'=>$phoneseq);
}
$smarty->assign("List",$list);
if($_REQUEST['ajax']=='yes')
{
    $arr["content"] = $smarty->fetch("modules/ShopSettings/PhoneSettingsListContent.tpl");
    ConvertTojsonString(1,$arr,'success');
}else{
    $arr["content"] = $smarty->fetch("modules/ShopSettings/PhoneSettings.tpl");
    ConvertTojsonString(1,$arr,'success');
}


?>