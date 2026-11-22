<?php
global $adb;
if(isset($_REQUEST['fieldname']))
{
    $fieldname_all = explode(',',$_REQUEST['fieldname']);
	foreach($fieldname_all as $val){
		if(!empty($val)){
			$colname[] = 'fieldname = "'.$val.'"';
		}
	}
}

if(isset($_REQUEST['allids']))
{
    $contactid = $_REQUEST['allids'];

}

$sql = "select tablename,columnname from ld_field where tabid = 4 and presence<>1 and (".implode(' or ',$colname).")";
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
if($num_rows)
{
        for($i=0;$i<$num_rows;$i++)
        {
            $info[]=array(
            'tablename'=> $adb->query_result($result,$i,'tablename'),
            'columnname'=> $adb->query_result($result,$i,'columnname')
            ); 
        }
}

$value_all ="";

//根据字段和表查询
$num_rows_info = count($info);
/**
 * 列表页面弹出字段选择后，点击保存，把所选字段相应的字段名放到session中
 * @reason 0012563 客户联系人列表群发邮件、短信，无法发送
 * @author Tujt 2014-11-18
 */
$session_keys = 'Contacts_sendsms_field';
$_SESSION[$session_keys] = '';
$mobilevalue = [];
for($i=0;$i<$num_rows_info;$i++)
{      
    $infodetail=$info[$i];
    $tablename = $infodetail['tablename'];
    $columnname = $infodetail['columnname'];
	$_SESSION[$session_keys] .= $tablename.'.'.$columnname.',';
    if($tablename != 'ld_contactdetails')
    {
		if($contactid =='all')
		{
			 $sql_value = "select ld_contactdetails.lastname,ld_contactscf.".$columnname." 
			from ld_contactscf inner join ld_contactdetails on ld_contactscf.contactid = ld_contactdetails.contactid ";
			$tm_where=getSelectQuery($_REQUEST,'Contacts','where');
          
            $sql_value .=  "  ".$tm_where;
		}
		else{
			 $sql_value = "select ld_contactdetails.lastname,ld_contactscf.".$columnname." 
			from ld_contactscf inner join ld_contactdetails on ld_contactscf.contactid = ld_contactdetails.contactid
			where ld_contactdetails.contactid in (".$contactid.")";
		}
        $result_info_select = $adb->pquery($sql_value,array());
        $num_rows_infomation = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info1 = "";
        if($num_rows_infomation)
        {
            for($j=0;$j<$num_rows_infomation;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$infodetail['columnname'])
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {
                      $hddMobileValue=base64_encode($infoall['1']); 
                      $contactid=explode(',',$contactid);
                      for($i=0;$i<count($contactid);$i++){                                           
						$infoall['1']=fieldValueUitype::SetMobileStyle($contactid[$i],$infoall['1'],'Contacts');//显示手机样式。                                        
                      } 
					$info1 .= $infoall['1'].",".$infoall['0'].",".$hddMobileValue.";";
					$mobilearray['0'] = $infoall['0'];
					$mobilearray['1'] = $infoall['1'];
					$mobilearray['2']=$hddMobileValue;
					$mobilevalue[]= $mobilearray; 
                }  
            }        
        }

    }
    else
    {
		if($contactid =='all')
		{
			$sql_value = "select ".$infodetail['tablename'].".".$infodetail['columnname'].",ld_contactdetails.lastname from "
					.$infodetail['tablename'];
				$tm_where=getSelectQuery($_REQUEST,'Contacts','where');
          
            $sql_value .=  "  ".$tm_where;
		}
		else
					$sql_value = "select ".$infodetail['tablename'].".".$infodetail['columnname'].",ld_contactdetails.lastname from ".$infodetail['tablename']." where contactid in(".$contactid.") ";
        $result_info_select = $adb->pquery($sql_value,array());
        $num_rows_infomation = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info2 = "";
        if($num_rows_infomation)
        {
            for($j=0;$j<$num_rows_infomation;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$infodetail['columnname'])
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {                      
                      //$info1 .= $infoall['1'].",".$infoall['0'].";";                      
                      $hddMobileValue=base64_encode($infoall['1']);                      
                      $contactid=explode(',',$contactid);                                      
                      for($i=0;$i<count($contactid);$i++){                      
                      $infoall['1']=fieldValueUitype::SetMobileStyle($contactid[$i],$infoall['1'],'Contacts');//显示手机样式。                                            
                      } 
                      $info2 .= $infoall['1'].",".$infoall['0'].",".$hddMobileValue.";";
                    $mobilearray['0'] = $infoall['0'];
					$mobilearray['1'] = $infoall['1'];
					$mobilearray['2']=$hddMobileValue;
					$mobilevalue[]= $mobilearray; 
                }  
            }                           
        }
    }
      
}
$_SESSION[$session_keys] = trim($_SESSION[$session_keys],',');
$value_all.= $info1;
$value_all.= $info2;
// print_r($info_select_detial);
// exit();
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($mobilevalue);
echo $jsonentity;
exit();
?>