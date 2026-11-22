<?php
global $currentModule,$adb;
$focus = CRMEntity::getInstance($currentModule);
$recordid = vtlib_purify($_REQUEST['recordid']);//获取选中的项目计划ID。
$ids=array();
$projectid=array();//项目计划相关联的项目ID。
if(is_array($recordid))//列表界面--（删除按钮）时。
{
   $ids=explode(";",$recordid);
   if($ids[sizeof($ids)]=="")
      {
        array_pop($ids);
      }  
}
else   
{
   if($recordid=='all')//如何删除列表全部单据时。
      {
       $all_query='select projecttaskid from ld_projecttask where deleted=0';
       $all_result = $adb->pquery($all_query);
       $ids[]=$adb->query_result($all_result,'projecttaskid');
      }
   else
      {
        $ids[]=$recordid;   
      }  
}
for($i=0;$i<count($ids);$i++)
{
    $sql1='';
    $sql1 .='select projectid from ld_projecttask';     
    $sql1 .=' where projecttaskid='.$ids[$i];
    $result = $adb->pquery($sql1);
    $projectid[]=$adb->query_result($result,'projectid');
}
if(count($projectid))
{                    //判断项目计划是否有关联项目。
   for($i=0;$i<count($projectid);$i++)
   {
        $sql2='select count(*) from ld_projecttask where projectid='.$projectid[$i].' and deleted=0';
        $sql3='select count(*) from ld_projecttask where projectid='.$projectid[$i].' and deleted=0 and projecttaskstatus=\'已完成\'';
        $result2 = $adb->pquery($sql2);
        $result3 = $adb->pquery($sql3);        
        $sql4='';
        $sql4 .='update ld_project SET completetask=\''.$adb->query_result($result3).'/'.$adb->query_result($result2).'\'';
        $sql4 .=' where projectid='.$projectid[$i];       
        $adb->pquery($sql4);
   } 
}
?>