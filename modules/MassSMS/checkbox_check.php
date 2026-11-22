<?php
include(globalStatic::$root_directory."modules/MassSMS/SMSCustomView.php");
include(globalStatic::$root_directory."modules/MassSMS/SMSProductDetails.php");
global $adb;
$focus=CRMEntity::getInstance('Accounts');
$fieldobj=$focus->fieldobj;
if( isset($_REQUEST['fieldname']))
{
    
    $tabid_fieldname = $_REQUEST['fieldname'];
}
$array_fieldname = explode(",",$tabid_fieldname);
if($array_fieldname[sizeof($array_fieldlabel)]=="")
{
    array_pop($array_fieldname);
}

foreach($array_fieldname as $fieldname)
{
    if(empty($fieldname))
            continue;
     $modules=explode("#",$fieldname);
     $othermodule=$modules[0];
     $realfieldname=$modules[1];
     $otherfocus=CRMEntity::getInstance($othermodule);
     $fieldinfo=$otherfocus->fieldobj->getFieldInfoobjBykey("fieldname",$realfieldname);
 
    $columns[]=$fieldinfo->getColumnName();
    $tables[$fieldinfo->getTableName()]=$fieldinfo->getTableName();
}  
$viewid=$_REQUEST['viewid'];
$customView=new SMSCustomView("Accounts");
$productdetails=new SMSProductDetails("Accounts");
$queryGenerator = QueryGenerator::getInstance("Accounts", $current_user,$customView,$productdetails);
if ($viewid != "0") {
   $queryGenerator->initForCustomViewById($viewid);
} else {
	$queryGenerator->initForDefaultCustomView();
}
$_REQUEST['pagepublicaccounttype']="ALLACCOUNT";
$list_query = $queryGenerator->getQuery('',2);
$page_list_query=$queryGenerator->getQuery('',1);
$list_query=$list_query." inner join ( $page_list_query  ) as temp on temp.$focus->table_index=$focus->table_name.$focus->table_index";
$list_query=$list_query.$queryGenerator->getWhereClause().' order by accountid desc ';
//echo $list_query;
$result=$adb->pquery($list_query,array());
$num_rows=$adb->num_rows($result);

$showfieldvalueobj=new ShowFieldValue($focus->fieldobj,'Accounts',SHOW_LISTVIEW);

for($i=0;$i<$num_rows;$i++)
{
    $record=$adb->query_result($result,$i,'accountid');
    $showfieldvalueobj->setRecorId($record);
    foreach($columns as $columnname)
    {
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                if(!empty($fieldinfo)){
                    if($fieldinfo->getTableName()=='ld_contactscf'||$fieldinfo->getTableName()=='ld_contactdetails'){
                        $mobile= $adb->query_result($result,$i,'products_'.$columnname);
                        $subject=$adb->query_result($result,$i,'products_lastname');
                    }else{
                        $subject=$adb->query_result($result,$i,'accountname');
                        $mobile= $adb->query_result($result,$i,$columnname);
                    }
                    $showvalue=$showfieldvalueobj->getFieldValueByField($fieldinfo,$mobile,$mobile);
                     if($mobile!=''&&!array_key_exists($mobile,$mobiles))
                     {
                       
                         if(preg_match(globalStatic::$reg_mobile_digit,$mobile))
                         {
                            $mobiles[$mobile]=$showvalue['value'];
                             $accepter .=$mobiles[$mobile].'<'.$subject.'>'."\r\n";  
                             $hiddenaccepter .=base64_encode($mobile)."\r\n";
                         }
                         
                     }                                        
                   
                 }     
    }
}


echo "#####SUCCESS#####".$accepter."#####SUCCESS#####".$hiddenaccepter;
exit();

?>