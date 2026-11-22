<?php
//global $adb,$current_user;
//require('user_privileges/user_language_'.$current_user->id.'.php');



      
    $module=$_REQUEST['module'];
    //require_once('modules/'.$module.'/'.$module.'.php');
   
    $fieldname=$_REQUEST['fieldname'];
    $fieldid=$_REQUEST['fieldid'];//记录id  record  单据id 不是字段id
    if($fieldid=="")
    {
        $fieldid=0;
    }
   

    //$sql="select tabid from ld_tab where name=?";
   // $result=$adb->pquery($sql,array($module));
    //$tabid=getTabid($module);
    $fieldvalue=$_REQUEST['fieldvalue'];
	//将判断整理到lingdang类中
	include './modules/lingdang/staticlingdang.class.php';
	$ldcls = new staticlingdang();
	$rest = $ldcls->getFieldDuplicateInfo($module,$fieldname,$fieldvalue,$fieldid);
	echo $rest;die;
   


 exit();

?>