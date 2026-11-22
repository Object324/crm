<?php
global $adb;
if(isset($_REQUEST['tabid_fieldlabel']))
{
    $contact_fieldlabel = $_REQUEST['tabid_fieldlabel'];
}

if(isset($_REQUEST['allids']))
{
    $contactid = $_REQUEST['allids'];

}
$contact_fieldlabel = explode("_",$contact_fieldlabel);


$num_array = sizeof($contact_fieldlabel);
$fieldlabel_info="";
for($i=1;$i<$num_array;$i++)
{
    $fieldlabel_info.="'".$contact_fieldlabel[$i]."',";
    $i++;
}
$fieldlabel_info = substr($fieldlabel_info,0,strlen($fieldlabel_info)-1);
require('user_privileges/user_language_'.$current_user->id.'.php');
$sql = "select tablename,columnname,fieldid from ld_field
LEFT JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_field.fieldid 
where ld_field.tabid = 4 and ld_tranlabel.tabid = 4 and ld_tranlabel.fieldlabel in (".$fieldlabel_info.") and ld_tranlabel.trantable = 'ld_field' and languagetype = ?";
$result = $adb->pquery($sql,array($languageType));
$num = $adb->num_rows($result);
$info = array();
if($num)
{
        for($i=0;$i<$num;$i++)
        {
            $info[]=array(
            'tablename'=> $adb->query_result($result,$i,'tablename'),
            'columnname'=> $adb->query_result($result,$i,'columnname'),
            'fieldid'=>$adb->query_result($result,$i,'fieldid')
            ); 
        }
}
$value_all ="";
$value_all2 ="";
//根据字段和表查询
if($_REQUEST['tabid_fieldlabel']){
for($i=0;$i<$num;$i++)
{
    if($info[$i]['tablename'] != 'ld_contactdetails')
    {
        $sql_value = "select ".$info[$i]['tablename'].".".$info[$i]['columnname'].",ld_contactdetails.lastname,ld_contactdetails.contactid from ".$info[$i][tablename]." inner join ld_contactdetails on ld_contactdetails.contactid = ".$info[$i][tablename].".contactid where ld_contactdetails.contactid in(".$contactid.")  and ".$info[$i][tablename].".".$info[$i][columnname] . "<> ''";
        $result_value = $adb->pquery($sql_value,array());
        $num_rows = $adb->num_rows($result_value);
        //判断不为空且是邮箱
        //print_r($result_value);
        if($result_value)
        {
            for($j=0;$j<$num_rows;$j++){
                //echo $info[$i][columnname]."|";
           $value_all .= $adb->query_result($result_value,$j,'lastname').";";
           $value_all .= $adb->query_result($result_value,$j,$info[$i]['columnname']).";";
           $emailidslists[]= $adb->query_result($result_value,$j,'contactid').'@'.$info[$i]['fieldid'];
           }
        }
        //print_r($value_all);
    }
    else
    {
        
        $page_list_query=$_SESSION['popup_Contacts_'.$_REQUEST['frommodule']."_pagequery"];
        if($contactid=='all')
        {
             //edit:can 2020-11-09 043164: (61mis.com/kfbcrm/index.php)营销-群发邮件-添加联系人（需要补丁）；在操作群发邮件选择联系人时，左侧勾选权限框后，显示所有单据的条数，但点击选择后只是显示列表中的联系人email；需选择全部联系人email
            $sql_value = "select ".$info[$i]['tablename'].".".$info[$i]['columnname'].",ld_contactdetails.contactid,ld_contactdetails.lastname from ".$info[$i][tablename]." 
             inner join ($page_list_query) as tmp on tmp.contactid=ld_contactdetails.contactid where  ".$info[$i][tablename].".".$info[$i][columnname] . "<> ''"; 
        }
        else
            $sql_value = "select ".$info[$i]['tablename'].".".$info[$i]['columnname'].",ld_contactdetails.contactid,ld_contactdetails.lastname from ".$info[$i][tablename]." where contactid in(".$contactid.") and ".$info[$i][tablename].".".$info[$i][columnname] . "<> ''"; 
        //print_r($sql_value);
        
        $result_value = $adb->pquery($sql_value,array());
        $num_rows = $adb->num_rows($result_value);
        //判断不为空且是邮箱
        //echo $num_rows;
        if($result_value)
        {
            for($j=0;$j<$num_rows;$j++){
                //echo $info[$i][columnname]."|";
           $value_all2 .= $adb->query_result($result_value,$j,'lastname').";";
           $value_all2 .= $adb->query_result($result_value,$j,$info[$i]['columnname']).";";
           $emailidslists[]= $adb->query_result($result_value,$j,'contactid').'@'.$info[$i]['fieldid'];
           }
        }
    }
    
}
}

$information = $value_all.$value_all2;

$information = explode(";",$information);
$num_info = sizeof($information)-1;
$information_all = '';
//print_r($information);
for($i=0;$i<$num_info;$i++)
{
   $j = $i+1;
  // echo $information[$j];
  $cc = '<';
  $cc2 = '>';
  if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'set_return_emails'){
		$information_all .= $information[$i].$cc.$information[$j].">;";
  }else{
		$information_all .= $information[$j].$cc.$information[$i].">\r";
  }
    $i++;
}
 //$information_all=htmlspecialchars_decode($information_all);
$_REQUEST['diony']='diony';
$arr['content']=$information_all;
//."#####SUCCESS#####".implode(',',$emailidslists);
ConvertTojsonString(1,$arr,"success");
?>