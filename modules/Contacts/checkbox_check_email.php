<?php
global $adb;
if(isset($_REQUEST['tabid_fieldlabel']) && isset($_REQUEST['allids']))
{
    $contact_fieldlabel = $_REQUEST['tabid_fieldlabel'];
    $contactid = $_REQUEST['allids'];
}

$contact_fieldlabel = explode("_",$contact_fieldlabel);


$num = sizeof($contact_fieldlabel);
$fieldlabel_info = "";


for($i=1;$i<$num;$i++)
{
    $fieldlabel_info.="'".$contact_fieldlabel[$i]."',";
    $i++;
}
$fieldlabel_info = substr($fieldlabel_info,0,strlen($fieldlabel_info)-1); 

//根据传的值知道是什么字段和表
$sql = "select tablename,columnname from ld_field where tabid = 4 and fieldlabel in (".$fieldlabel_info.")";
$result = $adb->pquery($sql,array());
$num = $adb->num_rows($result);
$info = array();
if($num)
{
        for($i=0;$i<$num;$i++)
        {
            $info[]=array(
            'tablename'=> $adb->query_result($result,$i,'tablename'),
            'columnname'=> $adb->query_result($result,$i,'columnname')
            ); 
        }
}
$value_all ="";
$allinfo= "";
/**
 * 列表页面弹出字段选择后，点击保存，把所选字段相应的字段名放到session中
 * @reason 0012563 客户联系人列表群发邮件、短信，无法发送
 * @author Tujt 2014-11-18
 */
$session_keys = 'Contacts_sendmail_field';
$_SESSION[$session_keys] = '';

$mobilearray = array();
for($i=0;$i<$num;$i++)
{
    $columnname=$info[$i]['columnname'];
    $tablename=$info[$i]['tablename'];
	$_SESSION[$session_keys] .= $tablename.'.'.$columnname.',';
    if($info[$i]['tablename'] != 'ld_contactdetails')
    {
        $sql_value = "select ".$tablename.".".$columnname.",ld_contactdetails.lastname from ".$tablename." inner join ld_contactdetails on ld_contactdetails.contactid = ".$tablename.".contactid where ld_contactdetails.contactid in(".$contactid.") ";
        $result_value = $adb->pquery($sql_value,array());
        $num_rows = $adb->num_rows($result_value);
        $info_select_detial = array();
        $infomation = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_value,$j,'lastname'),
                '1'=>$adb->query_result($result_value,$j,"$columnname")
                );
    
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$info_select_detial[$j][1])!=0)
                {
                    //$infomation .= $info_select_detial[$j][1].";;".$info_select_detial[$j][0].";;";
					$mobilearray[$info_select_detial[$j][1]] = $info_select_detial[$j][0];
                }  
            }       
        }
    }
    else
    {
        $sql_value = "select ".$tablename.".".$columnname.",ld_contactdetails.lastname from ".$tablename." where contactid in(".$contactid.") ";
        $result_value = $adb->pquery($sql_value,array());
        $num_rows = $adb->num_rows($result_value);
        $info_select_detial = array();
        $infomation2 = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_value,$j,'lastname'),
                '1'=>$adb->query_result($result_value,$j,"$columnname")
                );
    
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$info_select_detial[$j][1])!=0)
                {
                    //$infomation2 .= $info_select_detial[$j][1].";;".$info_select_detial[$j][0].";;";
					$mobilearray[$info_select_detial[$j][1]] = $info_select_detial[$j][0];
                }
  
            } 
                  
        }
    }

}
$_SESSION[$session_keys] = trim($_SESSION[$session_keys],',');
//$allinfo .= $infomation;
//$allinfo .= $infomation2;

/**
 * 把对应的邮箱放到数组中，解析成接送json格式传递
 * @reason 0012733 客户叙事簿界面：群发短信-无法把联系人手机号码带出来
 * @author Tujt 2014-12-02
 */
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($mobilearray);

echo "#####SUCCESS#####".$jsonentity."#####SUCCESS#####";
?>