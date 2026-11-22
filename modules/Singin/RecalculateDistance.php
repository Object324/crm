<?php
global $adb,$currentModule;
if(empty($_REQUEST['selectid'])) ConvertTojsonString(-1,array(),'error');

$query = getListAllQuery($currentModule, 1);//获取query，不需要任何附加条件
$search_query = $query['query'];

$selectid = $_REQUEST['selectid'];
if ($selectid != 'all') {
    $selectarr = explode(',', trim($selectid,','));
    $record_str = implode(',',$selectarr);
} else {
    $record_str = $search_query;
}

if(strpos($search_query,'order by') > -1){
	$orderbyarr = explode('order by',$search_query);//取出limit分页
	$order_by = str_replace('ld_singin','a',$orderbyarr[1]);
    $order_by = str_replace('ld_singinscf','b',$order_by);
}

//获取最大批量处理数
$deployarray = getSys_deploy(67);
$btach_num = $deployarray['deploy_value'];

$interval = 10; //每次操作10条
$start = $_REQUEST['start'];
$selectlen = $_REQUEST['selectlen'];

if(empty($btach_num)){
    $btach_num = 500;
}

if($btach_num > $start+$interval){
    $code = 1;
}else{
    $interval = $btach_num-$start;
    $code = 2;
}

$sql = "SELECT
        	a.longtitude,
        	a.latitude,
        	a.accountid,
        	a.address AS signaddress,
        	a.record,
            a.tabid,
            a.entitytype,
            a.entityaddress,
            a.signid,
            a.signout_id,
            ld_signout.signout_longtitude,
            ld_signout.signout_latitude,
            ld_signout.signout_address
        FROM
        	ld_singin AS a
         left join ld_singinscf b on a.signid = b.signid
         left join ld_signout on a.signid = ld_signout.signin_id
         left join ld_users on ld_users.id = a.smownerid
        WHERE a.signid in ($record_str) order by $order_by limit $start,$interval";
$result = $adb->pquery($sql,array());

$result_str = '';
$distance = false;
$distance_arr = array();
$arr = array();

$num_rows = $adb->num_rows($result);
//editor:gyq_20181009 0035344: 企业微信-拜访签到-签到误差可正确计算，到PC端签到报表中查看然后点击重新计划，结果计算结果显示为-
if($num_rows>0){
    for($i=0;$i<$num_rows;$i++){
        $signid = $adb->query_result($result,$i,'signid');
        $sign_longtitude = $adb->query_result($result,$i,'longtitude');
        $sign_latitude = $adb->query_result($result,$i,'latitude');
        $sign_address = $adb->query_result($result,$i,'signaddress');
        $record = $adb->query_result($result,$i,'record');
        $tabid = $adb->query_result($result,$i,'tabid');
        $entitytype = $adb->query_result($result,$i,'entitytype');
        $accountid = $adb->query_result($result,$i,'accountid');
        $signout_id = $adb->query_result($result,$i,'signout_id');
        
        $distance = false;
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
            $data_address = $adb->query_result($result,$i,'entityaddress');
        }

        //同时重算签退误差
        if ($signout_id > 0 || !empty($signout_id)){
            $signout_longtitude = $adb->query_result($result,0,'signout_longtitude');
            $signout_latitude = $adb->query_result($result,0,'signout_latitude');
            $signout_address = $adb->query_result($result,0,'signout_address');
            if(!empty($signout_address)){
                $signoutAddressInfos=getCoordinateByTecentApi($signout_address);
                if(is_array($signoutAddressInfos) && array_key_exists('result',$signoutAddressInfos))
                {
                    $signout_latitude2= $signoutAddressInfos['result']['location']['lat'];
                    $signout_longtitude2= $signoutAddressInfos['result']['location']['lng'];
                }
            }
        }

        if(!empty($data_address)&&$data_address!='--无--')
        {
            $accountAddressInfos=getCoordinateByTecentApi($data_address);
            if(is_array($accountAddressInfos) && array_key_exists('result',$accountAddressInfos))
            {
                $account_latitude= $accountAddressInfos['result']['location']['lat'];
                $account_longtitude= $accountAddressInfos['result']['location']['lng'];
            }
        }
        if(!empty($sign_address)){
            $signAddressInfos=getCoordinateByTecentApi($sign_address);
            if(is_array($signAddressInfos) && array_key_exists('result',$signAddressInfos))
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
                $updatesql='update ld_singin set longtitude=?,latitude=? where signid=?';
                $adb->pquery($updatesql,array($sign_longtitude2,$sign_latitude2,$signid));
                $distance = $seconddistance;
            }else{
                $distance = false;
            }

            //签退
            //相关对象拜访地址与签退时经纬度误差
            if(!empty($signout_latitude)&&!empty($signout_longtitude)){
                $signout_firstdistance = getDistance($account_latitude,$account_longtitude,$signout_latitude,$signout_longtitude);
            }
            //相关对象拜访地址与签退地址反算的误差
            if(!empty($signout_latitude2)&&!empty($signout_longtitude2)){
                $signout_seconddistance = getDistance($account_latitude,$account_longtitude,$signout_latitude2,$signout_longtitude2);
            }
            if(isset($signout_firstdistance)&&isset($signout_seconddistance)){
                $signout_distance = min($signout_firstdistance,$signout_seconddistance);
            }elseif(isset($firstdisignout_firstdistancestance)&&!isset($signout_seconddistance)){
                $signout_distance = $signout_firstdistance;
            }elseif(!isset($signout_firstdistance)&&isset($signout_seconddistance)){
                $updatesql='update ld_signout set signout_longtitude=?,signout_latitude=? where signoutid=?';
                $adb->pquery($updatesql,array($signout_longtitude2,$signout_latitude2,$signout_id));
                $signout_distance = $signout_seconddistance;
            }else{
                $signout_distance = false;
            }

            $firstdistance = false;
            $seconddistance = false;
            $account_latitude = false;
            $account_longtitude = false;
            $sign_longtitude2 = false;
            $sign_latitude2 = false;
            
            if(is_numeric($distance) && $distance>=0){
                $distance = $distance>500?($distance-500):$distance;
                $adb->pquery('update ld_singin set distince=? where signid=?',
                    array($distance,$signid));
                //zkt 20220530 52308（https://61mis.com/order/index.php）常用报表》签到统计表，误差值，需显示成千分位格式，方便查看数值
                $tmpdastince=$distance;
                $result_str .= '###DISTANCE###'.$tmpdastince.'###DISTANCE###';
                
                $distance_arr[$signid] = $tmpdastince;
            }
            //签退
            if(is_numeric($signout_distance) && $signout_distance>=0){
                $signout_distance = $signout_distance>500?($signout_distance-500):$signout_distance;
                $adb->pquery('UPDATE ld_signout JOIN ld_singin ON ld_signout.signin_id = ld_singin.signid 
                                set ld_signout.signout_distance=?,ld_singin.signout_distance=? where signoutid=?',
                    array($signout_distance,$signout_distance,$signout_id));
            }
        }
        //editor:gyq_20181026
        if(!empty($data_address)){
            $result_str .= '###ADDRESS###'.$data_address.'###ADDRESS###';
            $adb->pquery('update ld_singin set entityaddress=? where signid=?',
                array($data_address,$signid));
        }
        if($distance===false ){
            $adb->pquery('update ld_singin set distince=? where signid=?',array('无法计算',$signid));
            $distance_arr[$signid] = '无法计算';
        }
        //签退
        if($signout_distance===false ){
            $adb->pquery('UPDATE ld_signout JOIN ld_singin ON ld_signout.signin_id = ld_singin.signid 
                            set ld_signout.signout_distance=?,ld_singin.signout_distance=? where signoutid=?',
                array('无法计算','无法计算',$signout_id));
        }
    }
}else{
    $code = 2; //表示结束
}

$arr['start'] = $start;
$arr['end'] = $start+$interval;
$arr['distancearr'] = $distance_arr;
ConvertTojsonString($code,$arr,'success');

//echo $result_str;
//exit();
?>