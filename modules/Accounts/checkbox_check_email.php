<?php
global $adb;
if(isset($_REQUEST['allids']) && isset($_REQUEST['tabid_fieldlabel']))
{
    $accountid = $_REQUEST['allids']; 

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

$sql = "select tablename,columnname from ld_field where tabid in (".$array_tabid.") and fieldlabel in (".$array_fieldlabel_name.")";

$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
$info_select = array();

if($num_rows)
{
    for($i=0;$i<$num_rows;$i++)
    {
        $info_select[] = array(
            'tablename'=>$adb->query_result($result,$i,'tablename'),
            'columnname'=>$adb->query_result($result,$i,'columnname')
        ); 
    }  
}

$num_info_select = sizeof($info_select);
$info_all = "";
$infoall = "";
/**
 * 列表页面弹出字段选择后，点击保存，把所选字段相应的字段名放到session中
 * @reason 0012563 客户联系人列表群发邮件、短信，无法发送
 * @author Tujt 2014-11-18
 */
$session_keys = 'Accounts_sendmail_field';
$_SESSION[$session_keys] = '';

$mobilearray = array();

for($i=0;$i<$num_info_select;$i++)
{
    $infodetail = $info_select[$i];
    $columnname=$infodetail['columnname'];
    $tablename=$infodetail['tablename'];
	$_SESSION[$session_keys] .= $tablename.'.'.$columnname.',';
    if($tablename=='ld_accountscf')
    {
        $sql_info_select = "select ld_account.accountname,".$tablename.".".$columnname." from ".$tablename." left join ld_account on ld_account.accountid = ".$tablename.".accountid where ".$tablename.".accountid in (".$accountid.")";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$infoall['1'])!=0)
                {
                    //$info .= $infoall['1'].";;".$infoall['0'].";;";     
					$mobilearray[$infoall['1']] = $infoall['0'];
                }
            } 
        }
        
    }
    elseif($tablename=='ld_contactdetails')
    {
        $sql_info_select = "select ld_contactdetails.lastname,ld_contactdetails.".$columnname." from ".$tablename." inner join ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.accountid in(".$accountid.")";

        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info2 = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$infoall['1'])!=0)
                {
                    //$info2 .= $infoall['1'].";;".$infoall['0'].";;";     
					$mobilearray[$infoall['1']] = $infoall['0'];
                }
            } 
        }
    } 
    elseif($tablename=='ld_account')
    {
        $sql_info_select = "select accountname,".$columnname." from ".$tablename." where accountid in(".$accountid.")";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info3 = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$infoall['1'])!=0)
                {
                    //$info3 .= $infoall['1'].";;".$infoall['0'].";;";   
					$mobilearray[$infoall['1']] = $infoall['0'];
                }
            } 
        }
    }
    else
    {
        $sql_info_select = "select ld_contactdetails.lastname,".$tablename.".".$columnname." from ".$tablename." inner join ld_contactdetails on ".$tablename.".contactid = ld_contactdetails.contactid inner join ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.accountid in (".$accountid.")";
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        $info4 = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'lastname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^[\w\-\.]+@[\w\-]+(\.\w+)+$/",$infoall['1'])!=0)
                {
                    //$info4 .= $infoall['1'].";;".$infoall['0'].";;";   
					$mobilearray[$infoall['1']] = $infoall['0'];
                }
            } 
        }
    } 
}
$_SESSION[$session_keys] = trim($_SESSION[$session_keys],',');
//$info_all.=$info;
//$info_all.=$info2;
//$info_all.=$info3;
//$info_all.=$info4;
//print_r($info_all);
//exit();

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