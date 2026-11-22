<?php
global $adb;
if(isset($_REQUEST['accountid']) && isset($_REQUEST['tabid_fieldlabel']))
{
    $accountid = $_REQUEST['accountid']; 

    $tabid_fieldlabel = $_REQUEST['tabid_fieldlabel'];
}
$array_fieldlabel = explode("_",$tabid_fieldlabel);
if($array_fieldlabel[sizeof($array_fieldlabel)]=="")
{
    array_pop($array_fieldlabel);
}

$array_tabid = "";
$array_fieldlabel_name = "";
$num = count($array_fieldlabel);

for($i=0;$i<$num;$i++)
{
    $array_tabid .= $array_fieldlabel[$i].",";
    $array_fieldlabel_name .= "'".$array_fieldlabel[$i+1]."',";
   $i++;
}

$array_tabid = substr($array_tabid,0,strlen($array_tabid)-1);
$array_fieldlabel_name = substr($array_fieldlabel_name,0,strlen($array_fieldlabel_name)-1);
require('user_privileges/user_language_'.$current_user->id.'.php');
$sql = "select tablename,columnname,fieldid from ld_field 
LEFT JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_field.fieldid  
where ld_field.tabid in (".$array_tabid.") and ld_tranlabel.tabid in (".$array_tabid.") and ld_tranlabel.fieldlabel in (".$array_fieldlabel_name.") and ld_tranlabel.trantable = 'ld_field' and languagetype = ?";
//print_r($sql);
$result = $adb->pquery($sql,array($languageType));
$num_rows = $adb->num_rows($result);
$info_select = array();

if($num_rows)
{
    for($i=0;$i<$num_rows;$i++)
    {
        $info_select[] = array(
            'tablename'=>$adb->query_result($result,$i,'tablename'),
            'columnname'=>$adb->query_result($result,$i,'columnname'),
            'fieldid'=>$adb->query_result($result,$i,'fieldid')
        ); 
    }  
}

$num_info_select = sizeof($info_select);
$info_all = "";
$infoall = "";
$info = "";
$info2 = "";
$info4 = "";
$info3 = "";
for($i=0;$i<$num_info_select;$i++)
{
    $infodetail = $info_select[$i];
    $columnname=$infodetail['columnname'];
    $tablename=$infodetail['tablename'];
    $fieldid=$infodetail['fieldid'];
    if($tablename=='ld_accountscf')
    {
        $sql_info_select = "select ld_account.accountname,".$tablename.".".$columnname.",ld_account.accountid from ".$tablename." left join ld_account on ld_account.accountid = ".$tablename.".accountid where ".$tablename.".accountid in (".$accountid.") and ".$tablename.".".$columnname."<> ''";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($sql_info_select);
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname),
                
                );
                $emailidslists[]= $adb->query_result($result_info_select,$j,'accountid').'@'.$fieldid;
                $infoall = $info_select_detial[$j];
				if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'set_return_emails'){
					$info .= $infoall['0']."<".$infoall['1'].">;";
				}else{
					$info .= $infoall['1']."<".$infoall['0'].">\r";
				}
                
            } 
        }
        
    }
    elseif($tablename=='ld_contactdetails')
    {
        $sql_info_select = "select ld_contactdetails.lastname,ld_contactdetails.".$columnname.",ld_contactdetails.contactid from ".$tablename." inner join ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.accountid in(".$accountid.") and ld_contactdetails.".$columnname."<> ''";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $emailidslists[]= $adb->query_result($result_info_select,$j,'contactid').'@'.$fieldid;
                $infoall = $info_select_detial[$j];
				if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'set_return_emails'){
					$info2 .= $infoall['0']."<".$infoall['1'].">;";
				}else{
					$info2 .= $infoall['1']."<".$infoall['0'].">\r";
				}   
                
            } 
        }
    }
    elseif($tablename=='ld_account')
    {
        $sql_info_select = "select accountname,".$columnname.",accountid from ".$tablename." where accountid in(".$accountid.") and ".$columnname."<> ''";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($sql_info_select);
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $emailidslists[]= $adb->query_result($result_info_select,$j,'accountid').'@'.$fieldid;
                $infoall = $info_select_detial[$j];
				if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'set_return_emails'){
					$info4 .= $infoall['0']."<".$infoall['1'].">;";
				}else{
					$info4 .= $infoall['1']."<".$infoall['0'].">\r";
				}    
                
            } 
        }
    }  
    else
    {
        $sql_info_select = "select ld_contactdetails.lastname,".$tablename.".".$columnname .",ld_contactdetails.contactid from ".$tablename."  inner join ld_contactdetails on ".$tablename.".contactid = ld_contactdetails.contactid inner join ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.accountid in (".$accountid.") and ".$tablename.".".$columnname ."<> ''";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //print_r($sql_info_select);
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $emailidslists[]= $adb->query_result($result_info_select,$j,'contactid').'@'.$fieldid;
                $infoall = $info_select_detial[$j];
				if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'set_return_emails'){
					$info3 .= $infoall['0']."<".$infoall['1'].">;";
				}else{
					$info3 .= $infoall['1']."<".$infoall['0'].">\r";
				}    
                
            } 
        }
    } 
    
}
$info_all.=$info;
$info_all.=$info2;
$info_all.=$info3;
$info_all.=$info4;

$_REQUEST['diony']='diony';
$arr['content']=$info_all;
//."#####SUCCESS#####".implode(',',$emailidslists);
ConvertTojsonString(1,$arr,"success");
?>