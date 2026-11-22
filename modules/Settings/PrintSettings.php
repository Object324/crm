<?php

//lmq 230627 显示打印设置弹出层

$printset=$_REQUEST['printset'];
if($printset=='showpage'){
    $frommodule = $_REQUEST['frommodule'];
    $PrintSettingCategories=getUsersettingByLabel($frommodule,1,'PrintSettingCategories');
    $PrintSettingCategoriesArr = explode(',',$PrintSettingCategories);
    $smarty=new lingdangCRM_Smarty;

    $smarty->assign('PrintSettingCategoriesArr',$PrintSettingCategoriesArr);
    $prevToEmailDoc = $_REQUEST['prevToEmailDoc'];
    $prevToEmailPdf = $_REQUEST['prevToEmailPdf'];
    $_REQUEST['diony']='diony';
    $arr['title']='打印设置';
    $smarty->assign('email_status',vtlib_isModuleActive('Emails'));
    $arr['content']=$smarty->fetch('Settings/PrintSettings.tpl');
    $email_status = $_REQUEST['email_status'];
    ConvertTojsonString(1,$arr,"");
}
else{
    //lmq 230627 保存打印操作选项类别
    $unselected_tags = $_REQUEST['unselected_tags'];
    $frommodule = $_REQUEST['frommodule'];
    setUsersettingByLabel($frommodule, 1, 'PrintSettingCategories',$unselected_tags);
    ConvertTojsonString(1,array(),"");
}




?>