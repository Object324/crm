<?php
global $adb;
include_once (globalStatic::$root_directory.'appCommon/appCommon.php');
if(!empty($_REQUEST['fieldname'])){
	$fieldname_all = explode(',',$_REQUEST['fieldname']);
	foreach($fieldname_all as $val){
		if(!empty($val)){
			$colname[] = 'fieldname = "'.$val.'"';
		}
	}
	if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'Accounts'){
		$tabid = '4,6,'.getTabid("Users");
	}else{
		$tabid = 4;
	}
	$sql = "select tablename,columnname from ld_field where tabid in (".$tabid.") and presence<>1 and (".implode(' or ',$colname).") group by tablename,columnname";
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
}
$version = getVersionTradeInfo();
$accountid = $_REQUEST['allids'];
$accountid_arr = explode(',',$accountid);
$num_info_select = sizeof($info_select);
$info_all = "";
$infoall = "";
$info = "";
/**
 * 列表页面弹出字段选择后，点击保存，把所选字段相应的字段名放到session中
 * @reason 0012563 客户联系人列表群发邮件、短信，无法发送
 * @author Tujt 2014-11-18
 */
$session_keys = 'Accounts_sendsms_field';
$_SESSION[$session_keys] = '';

$mobilearray = array();
$mobilevalue=array();

if(isset($_REQUEST['frommodule'])&&$_REQUEST['frommodule']!=''){
    $frommodule = $_REQUEST['frommodule'];
}else{
    $frommodule = $currentModule;
}
$result=$adb->pquery($sql,array());
for($ki=0;$ki<$num_info_select;$ki++)
{
    $infodetail = $info_select[$ki];
    $columnname=$infodetail['columnname'];
    $tablename=$infodetail['tablename'];
	$strsms .= $tablename.'.'.$columnname.',';
  
    if($tablename=='ld_accountscf')
    {
        if( $accountid=='all')
        {
             $sql_info_select = "select distinct ld_account.accountname,".$tablename.".".$columnname.
            " from ".$tablename." left join ld_account on ld_account.accountid = ".
            $tablename.".accountid";
            $tm_where=getSelectQuery($_REQUEST,$frommodule,'where');
            if(stripos($tm_where,'ld_contactdetails')!==false)
            {
                $sql_info_select.=' left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid';
            }
            //duan 东贸-区分大巴车和下游客户
            if($version['account']=='dongmao'){
                $sql_info_select.=' left join  ld_customform10 on ld_account.customform10_id=ld_customform10.customform10id ';
                if($frommodule == 'ServiceCharge'){
                    if(stripos($sql_info_select,'ld_contactdetails')!==false){
                        $sql_info_select .= ' left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid ';
                    }
                    if(stripos($sql_info_select,'ld_contactscf')!==false){
                        $sql_info_select .=' left join  ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid ';
                    }
                }
            }
            
            $sql_info_select .=  "  ".$tm_where;
        }
        else
        $sql_info_select = "select ld_account.accountname,".$tablename.".".$columnname.
            " from ".$tablename." left join ld_account on ld_account.accountid = ".
            $tablename.".accountid  where ".$tablename.".accountid in (".$accountid.")";
        
        $result_info_select = $adb->pquery($sql_info_select,array());
        $num_rows = $adb->num_rows($result_info_select);
        $info_select_detial = array();
        //$info = "";
        if($num_rows)
        {
            for($j=0;$j<$num_rows;$j++)
            {
                $info_select_detial[] = array(
                '0'=>$adb->query_result($result_info_select,$j,'accountname'),
                '1'=>$adb->query_result($result_info_select,$j,$columnname)
                );
                $infoall = $info_select_detial[$j];
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {
                    //$info .= $infoall['1']."<".$infoall['0'].">;";
                      $hddMobileValue=base64_encode($infoall['1']);
                      for($i=0;$i<count($accountid_arr);$i++){
                      $infoall['1']=fieldValueUitype::SetMobileStyle($accountid_arr[$i],$infoall['1'],'Accounts');//显示手机样式。
                      } 
					$mobilearray['0'] = $infoall['0'];
                    $mobilearray['1'] = $infoall['1'];
                    $mobilearray['2']=$hddMobileValue;
                    $mobilevalue[]= $mobilearray;
                }
            } 
        }
        
    }
    elseif($tablename=='ld_contactdetails')
    {
        if($accountid=='all')
        {
            $tm_where=getSelectQuery($_REQUEST,$frommodule,'where');
           
            $sql_info_select = "select ld_contactdetails.lastname,ld_contactdetails.".$columnname." 
                    from ld_contactdetails
                 inner join ld_account on ld_account.accountid = ld_contactdetails.accountid ";
            if(stripos($tm_where,'ld_accountscf')!==false)
            {
                $sql_info_select.=' left join ld_accountscf on ld_account.accountid=ld_accountscf.accountid ';
            }
            //duan 东贸-区分大巴车和下游客户
            if($version['account']=='dongmao'){
                $sql_info_select.=' left join  ld_customform10 on ld_account.customform10_id=ld_customform10.customform10id ';
                if($frommodule == 'ServiceCharge'){
                    if(stripos($sql_info_select,'ld_contactdetails')!==false){
                        $sql_info_select .= ' left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid ';
                    }
                    if(stripos($sql_info_select,'ld_contactscf')!==false){
                        $sql_info_select .=' left join  ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid ';
                    }
                }
            }
           
            $sql_info_select.= $tm_where;
        }
        else
            $sql_info_select = "select ld_contactdetails.lastname,ld_contactdetails.".$columnname." from ld_contactdetails
             inner join ld_account on ld_account.accountid = ld_contactdetails.accountid where ld_contactdetails.accountid in(".$accountid.")";
        
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
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {

                    $hddMobileValue=base64_encode($infoall['1']);
                    for($i=0;$i<count($accountid_arr);$i++){
                    $infoall['1']=fieldValueUitype::SetMobileStyle($accountid_arr[$i],$infoall['1'],'Accounts');//显示手机样式。
                     } 
                    
                    //$info3 .= $infoall['1']."<".$infoall['0'].">;";                     
					$mobilearray['0'] = $infoall['0'];
                    $mobilearray['1'] = $infoall['1'];
                    $mobilearray['2']=$hddMobileValue;
                    $mobilevalue[]= $mobilearray;
                }
            }             
        }
    }
    elseif($tablename=='ld_account')
    {
        if($accountid=='all')
        {
            $tm_where=getSelectQuery($_REQUEST,$frommodule,'where');
             $sql_info_select = "select distinct accountname,".$columnname." from ".$tablename;
             if(stripos($tm_where,'ld_accountscf')!==false)
            {
                $sql_info_select.=' left join ld_accountscf on ld_account.accountid=ld_accountscf.accountid ';
            }
            if(stripos($tm_where,'ld_contactdetails')!==false)
            {
                $sql_info_select.=' left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid ';
                
            }
            //duan 东贸-区分大巴车和下游客户
            if($version['account']=='dongmao'){
                $sql_info_select.=' left join  ld_customform10 on ld_account.customform10_id=ld_customform10.customform10id ';
                if($frommodule == 'ServiceCharge'){
                    if(stripos($sql_info_select,'ld_contactdetails')!==false){
                        $sql_info_select .= ' left join ld_contactdetails on ld_account.accountid=ld_contactdetails.accountid ';
                    }
                    if(stripos($sql_info_select,'ld_contactscf')!==false){
                        $sql_info_select .=' left join  ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid ';
                    }
                }
            }
            $sql_info_select.= $tmpwhere;
        }
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
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {
                  
                    $hddMobileValue=base64_encode($infoall['1']);
                    for($i=0;$i<count($accountid_arr);$i++){
                    $infoall['1']=fieldValueUitype::SetMobileStyle($accountid_arr[$i],$infoall['1'],'Accounts');//显示手机样式。
                     } 
                    
                    //$info3 .= $infoall['1']."<".$infoall['0'].">;";                     
					$mobilearray['0'] = $infoall['0'];
                    $mobilearray['1'] = $infoall['1'];
                    $mobilearray['2']=$hddMobileValue;
                    $mobilevalue[]= $mobilearray;                    
                    
                }
            } 
        }
    }
    else if($tablename=='ld_users'){
        //销售负责人
        if($accountid=="all"){
            $sql_user_select = "select distinct ".$tablename.".".$columnname.
                ",".$tablename.".last_name,wx_userid,".
                $tablename.".id,".
                $tablename.".real_name from ".$tablename." inner join ld_account on ld_account.smownerid = ".
                $tablename.".id";
            $tm_where=getSelectQuery($_REQUEST,$frommodule,'where');
            if(stripos($tm_where,'ld_contactdetails')!==false)
            {
                $sql_user_select.=' left join ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid';
            }
            $sql_user_select .=  "  ".$tm_where;
        }else{
            $sql_user_select = "select distinct ".$tablename.".".$columnname.",".$tablename.".last_name,wx_userid,".
                $tablename.".id,".
                $tablename.".real_name from ".$tablename." inner join ld_account on ".$tablename.".id = ld_account.smownerid where ld_account.accountid in (".$accountid.")";
        }
        $result_user_select = $adb->pquery($sql_user_select,array());
        $num_user_rows = $adb->num_rows($result_user_select);
        $user_select_detail = array();
        $info5 = "";
        if($num_user_rows>0)
        {
            for($j=0;$j<$num_user_rows;$j++)
            {
                $last_name=$adb->query_result($result_user_select,$j,'last_name');
                $real_name=$adb->query_result($result_user_select,$j,'real_name');
                $last_name = isKehu001ServerPc()=="yes"?$real_name:$last_name;//客户001真实姓名
                $user_select_detail[] = array(
                    '0'=>$last_name,
                    '1'=>$adb->query_result($result_user_select,$j,$columnname)
                );
                $infoall = $user_select_detail[$j];
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {
                    $hddMobileValue=base64_encode($infoall['1']);
                    for($i=0;$i<count($accountid_arr);$i++){
                        $infoall['1']=fieldValueUitype::SetMobileStyle($accountid_arr[$i],$infoall['1'],'Accounts');//显示手机样式。
                    }
                    //$info4 .= $infoall['1']."<".$infoall['0'].">;";
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
                if(preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$infoall['1'])!=0)
                {
                    $hddMobileValue=base64_encode($infoall['1']);
                    for($i=0;$i<count($accountid_arr);$i++){
                    $infoall['1']=fieldValueUitype::SetMobileStyle($accountid_arr[$i],$infoall['1'],'Accounts');//显示手机样式。
                     } 
                    //$info4 .= $infoall['1']."<".$infoall['0'].">;";
				    $mobilearray['0'] = $infoall['0'];
                    $mobilearray['1'] = $infoall['1'];
                    $mobilearray['2']=$hddMobileValue;
                    $mobilevalue[]= $mobilearray; 
                }
            } 
        }
    } 
    
}
$_SESSION[$session_keys] = trim($strsms,',');
//$info_all.=$info;
//$info_all.=$info2;
//$info_all.=$info3;
//$info_all.=$info4;

/**
 * 把对应的手机号放到数组中，解析成接送json格式传递
 * @reason 0012733 客户叙事簿界面：群发短信-无法把联系人手机号码带出来
 * @author Tujt 2014-12-02
 */
require_once('./include/Zend/Json.php');
$json = new Zend_Json();
$jsonentity = $json->encode($mobilevalue);
echo $jsonentity;
exit();

?>