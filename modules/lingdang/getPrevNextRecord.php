<?php
//获取上一条/下一条的ID
global $adb;
if(!$adb)
{
    ConvertTojsonString("-1",array(),'error');
}
global $list_max_entries_per_page_new;
$recordtag=$_REQUEST['recordtag'];//

$record=$_REQUEST['record'];//
$pagenum=$_REQUEST['pagenum'];
$_REQUEST['start']=$pagenum;

$module=$_REQUEST['module'];
$focus=CRMEntity::getInstance($module);
$table_index=$focus->table_index;
$table_name=$focus->table_name;
$focus->id=$record;
$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);
if($recordtag=='nextrecord')
{
    /*if(!array_key_exists('nextpagestart',$recordNavigationInfo))
    {
        ConvertTojsonString()
    }*/
    
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$recordNavigationInfo,'success');

//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);

?>