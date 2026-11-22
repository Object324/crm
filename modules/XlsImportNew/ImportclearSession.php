<?php

global $currentModule;
global $current_user;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel']=array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"]=array();
$_SESSION['productfield_'.$currentModule.'_'.$current_user->id]=array();
$_SESSION['detailfield_'.$currentModule.'_'.$current_user->id]=array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows']=0;
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow']=$highestRow;  
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']=0;    
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=0;  
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=0; 
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=0; 
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=0; 
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=0;//实际导入的单据数量，按主表计算
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']=0;//导入成功的明细条数
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=0;//失败导入的明细条数
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]='';
$_SESSION['import_'.$currentModule.'_'.$current_user->id."_picklist"]=array();//检查下拉框的下拉框值
?>