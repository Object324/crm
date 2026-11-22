<?php
global $adb;
if(empty($_REQUEST['signid'])) exit();

$signid = $_REQUEST['signid'];

$sql = "SELECT
        	a.longtitude,
        	a.latitude,
        	a.accountid,
        	a.address AS signaddress,
        	a.record,a.tabid,a.entityaddress,a.entitytype
        FROM
        	ld_singin AS a
        WHERE a.id = ?";
$result = $adb->pquery($sql,array($signid));
$result_str = '';
$distance = false;
//editor:gyq_20181009 0035344: 企业微信-拜访签到-签到误差可正确计算，到PC端签到报表中查看然后点击重新计划，结果计算结果显示为-
if($adb->num_rows($result)){
    $sign_longtitude = $adb->query_result($result,0,'longtitude');
    $sign_latitude = $adb->query_result($result,0,'latitude');
    $sign_address = $adb->query_result($result,0,'signaddress');
    $record = $adb->query_result($result,0,'record');
    $tabid = $adb->query_result($result,0,'tabid');
    $entitytype = $adb->query_result($result,$i,'entitytype');
    $accountid = $adb->query_result($result,0,'accountid');
    //editor:gyq_20181023	0035431: 报表-常用报表-签到统计表，点击重新计算的时候应该根据客户最新的地址跟签到地址显示误差
    if($record > 0){
        //editor:gyq_96 reason:企业微信客户服务单增加签到  2019/1/9 17:47
        $accountid_sql = null;
        if(getTabid('ContactRecords')==$tabid){
            $accountid_sql = 'select accountid from ld_contactrecords where contactrecordID=?';
        }elseif (getTabid('HelpDesk')==$tabid){
            $accountid_sql = 'select accountid from ld_troubletickets where ticketid=?';
        }
        if(!empty($accountid_sql)){
            $accountid_result = $adb->pquery($accountid_sql,array($record));
            if($adb->num_rows($accountid_result) > 0){
                $record = $accountid = $adb->query_result($accountid_result,0,'accountid');
            }
        }

        crm_load_class_file('cls_SigninRelatedField_Data', 'include/RelatedField');
        $cls_SigninRelatedField = new cls_SigninRelatedField_Data($entitytype, $record);
        $data_address = $cls_SigninRelatedField->getVisitAddress();

    }elseif ($accountid > 0){
        //editor:gyq_81 reason:签到考勤优化 2018/9/27 16:23
        $sql = "SELECT CONCAT_WS('',bill_state,bill_city,bill_street) AS accountaddress
                FROM ld_account WHERE accountid = ?";
        $ac_result = $adb->pquery($sql,array($accountid));
        $data_address = $adb->query_result($ac_result,0,'accountaddress');
    }else{
        $data_address = $adb->query_result($result,0,'entityaddress');
    }
    if(!empty($data_address)&&$data_address!='--无--')
    {
        $accountAddressInfos=getCoordinateByTecentApi($data_address);
        if(array_key_exists('result',$accountAddressInfos))
        {
            $account_latitude= $accountAddressInfos['result']['location']['lat'];
            $account_longtitude= $accountAddressInfos['result']['location']['lng'];
        }
    }
    if(!empty($sign_address)){
        $signAddressInfos=getCoordinateByTecentApi($sign_address);
        if(array_key_exists('result',$signAddressInfos))
        {
            $sign_latitude2= $signAddressInfos['result']['location']['lat'];
            $sign_longtitude2= $signAddressInfos['result']['location']['lng'];
        }
    }
    if(!empty($account_latitude)&&!empty($account_longtitude)){
        //相关对象拜访地址与签到时经纬度误差
        if(!empty($sign_latitude)&&!empty($sign_longtitude)){
            $firstdistance = getDistance($account_latitude,$account_longtitude,$sign_latitude,$sign_longtitude);
        }
        //相关对象拜访地址与签到地址反算的误差
        if(!empty($sign_latitude2)&&!empty($sign_longtitude2)){
            $seconddistance = getDistance($account_latitude,$account_longtitude,$sign_latitude2,$sign_longtitude2);
        }
        if(isset($firstdistance)&&isset($seconddistance)){
            $distance = min($firstdistance,$seconddistance);
        }elseif(isset($firstdistance)&&!isset($seconddistance)){
            $distance = $firstdistance;
        }elseif(!isset($firstdistance)&&isset($seconddistance)){
            $updatesql='update ld_singin set longtitude=?,latitude=? where id=?';
            $adb->pquery($updatesql,array($sign_longtitude2,$sign_latitude2,$signid));
            $distance = $seconddistance;
        }
        if($distance!==false){
            $distance = $distance>500?($distance-500):$distance;
            $adb->pquery('update ld_singin set distince=? where id=?',
                array($distance,$signid));
            //zkt 20220530 52308（https://61mis.com/order/index.php）常用报表》签到统计表，误差值，需显示成千分位格式，方便查看数值
            $tmpdastince=number_format($distance,0,'.',',');
            $result_str .= '###DISTANCE###'.$tmpdastince.'###DISTANCE###';
        }
    }
    //editor:gyq_20181026
    if(!empty($data_address)){
        $result_str .= '###ADDRESS###'.$data_address.'###ADDRESS###';
        $adb->pquery('update ld_singin set entityaddress=? where id=?',
            array($data_address,$signid));
    }
}
//editor:gyq_20181217 	0035793: （51mis.com/kfbcrm）常用报表>签到统计表：当签到地址跟拜访地址一样的情况下签到“误差”显示为“无法计算”，当点击重新计算后误差显示为“0”（需要补丁）
if($distance===false ){
    $adb->pquery('update ld_singin set distince=? where id=?',array('无法计算',$signid));
}
echo $result_str;
exit();
?>