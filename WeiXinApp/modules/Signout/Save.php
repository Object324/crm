<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $current_user,$adb,$PlatformMC,$weixin_user;
//小程序兼容，小程序暂时还没做新的拜访签到模块
$mobj = cls_Instance::get_moduleAction_Instance('Signout','Save');
$mobj->setFieldInfoFromPost();//从wx_fieldinfo初始化字段信息
$mobj->common_save();
$mobj->ConvertTojsonStringInSave();
die;

//由于腾讯接口传来的经纬度跟百度稍有误差，这里处理掉
//$littlelong = 0.00611432945;//经度误差
//$littlelati = 0.006273667615;//纬度误差
$addressinfo=$_REQUEST['addressinfo'];
$content=$addressinfo['content'];
$address=$addressinfo['address'];
$longtitude=$addressinfo['longtitude'];//+$littlelong;
$longtitude=is_numeric($longtitude)?$longtitude:null;
$latitude=$addressinfo['latitude'];//+$littlelati;
$latitude=is_numeric($latitude)?$latitude:null;
$uuid=$addressinfo['uuid'];
$signway=$addressinfo['signway'];
$record=trim($addressinfo['relationId']);
$module = $addressinfo['relationModule'];
$distance=$addressinfo['distance'];
$tabid = getTabid($module);
if($record=='-1')
{
    $msg = sprintf(getFixedLabel('TMPNAMECANNOTBEEMPTY'),getTranstab($module));
    ConvertTojsonString('-1','',$msg);
}

$modulelist = getSinginOptionModule();
if(!empty($modulelist[$tabid])){
    if($modulelist[$tabid]['no_signin'] == 'yes' && $distance > $modulelist[$tabid]['allowable_distance']){
         $jsonArray['list'] = array('distance'=>$distance,'address'=>$address);
        $msg = str_replace('{metre}',$modulelist[$tabid]['allowable_distance'],getFixedLabel('Theadministratorhassetthatitisnotallowedtosign'));
        ConvertTojsonString(-1,$jsonArray,$msg);
    }
}

$userid=$current_user->id;
$createdtime=date('Y-m-d H:i:s',time());
$accounts_lng = null;
$accounts_lat = null;
//editor:gyq_20190517 reason:增加判断reocord  2019/5/17 14:13  0037098: （落落计划）企业微信、微信小程序>灵当CRM>拜访签到：
//在拜访对象为非必录项的情况下，不选择拜访对象点击签到，界面加载一不出来一直转圈，小程序提示访问报错。（需要补丁）
if(!empty($record)) {
    if ($module == 'Accounts') {
        $sql = "select longtitude,latitude from ld_account where accountid=?";
        $result = $adb->pquery($sql, array($record));
        $accounts_lng = $adb->query_result($result, 0, 'longtitude');
        $accounts_lat = $adb->query_result($result, 0, 'latitude');
        $accounts_lng = is_numeric($accounts_lng) ? $accounts_lng : null;
        $accounts_lat = is_numeric($accounts_lat) ? $accounts_lat : null;
    }
    //editor:gyq_81 reason:签到考勤优化 2018/10/09 16:23
    crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
    $cls_ParentRelatedFields = new cls_ParentRelatedField_Data('Singin', $record, 'source_list');
    $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
    $data_address = $relatedfielddata[0]['rawValue']['value'];
    $entityarray = getEntitynameInfo(getTabid($module));
    $tabname = $entityarray['tablename'];
    $tabindex = $entityarray['entityidfield'];
    $tabfieldname = $entityarray['fieldname'];
    $query = 'select ' . $tabindex . ',' . $tabfieldname . ' as subject from ' . $tabname . ' where ' . $tabindex . ' in (' . $record . ') limit 1';
    $result = $adb->pquery($query);
    $subject = $adb->query_result($result, 0, 'subject');
}
//editor:gyq_20190412 0036579: CRM小程序：拜访签到保存后，【signway】字段跟企业微信保存后值是一样，建议区分开来。
if($PlatformMC['type_mini']){
    //editor:gyq_20190412 0036567: 小程序-考勤签到-常用报表-签到考勤表不显示手机设备号。
    $sql = 'select wx_openid from ld_users where id=?';
    $result = $adb->pquery($sql,array($current_user->id));
    $uuid = $adb->query_result($result,0,'wx_openid');
}

$sql='insert into ld_singin(content,address,longtitude,latitude,userid,createdtime,record,tabid,uuid,
accounts_lng,accounts_lat,distince,signway,entityname,entityaddress) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
$adb->pquery($sql,array($content,$address,$longtitude,$latitude,$userid,$createdtime,$record,$tabid,$uuid,$accounts_lng,$accounts_lat,$distance,$signway,$subject,$data_address));
$lastinsertid=$adb->getLastInsertID();

//duan 20221210 模块的签到字段保存后，在ld_crmentity 中增加关联关系,并更新需要显示的字段值
$Singin_focus = CRMEntity::getInstance('Singin');
$Singin_focus->insertIntoCrmEntity('Singin');
$singid = $Singin_focus->id;
$updatesql = "update ld_singin set signid=?,entitytype=?,source_list=?,smcreatorid=?,smownerid=?,deleted=? where id =?";
$adb->pquery($updatesql,array($singid,$module,$record,$current_user->id,$current_user->id,0,$lastinsertid));
$insertsql = "insert into ld_singinscf(signid) values(?)";
$adb->pquery($insertsql,array($singid));

//editor:gyq_20190124 0036089: 企业微信端/微信小程序：签到时，也应该更新客户经纬度
if($module == 'Accounts' && !empty($record)){
    $update_sql = 'update ld_account set longtitude=?,latitude=?,location_address=? where accountid=?';
    $result = $adb->pquery($update_sql,array($longtitude,$latitude,$data_address,$record));
    $update_sql2 = 'update ld_singin set accountid=? where id=?';
    $result2 = $adb->pquery($update_sql2,array($record,$lastinsertid));
   crm_load_class_file('Accounts','modules/Accounts');
   $account=new Accounts();
      //反写保护结束日期
  $account->updateAccountInfo($module,$record);
        
}

$mobj = cls_Instance::get_moduleAction_Instance('Singin','Save');
$savefileinfo_arr = $mobj->saveFileFromWeiXinApi($lastinsertid,'Singin',$addressinfo['image']);

$mobj->saveFileasCommonFile($singid,'Singin',$addressinfo['image']);
//@edit:liushuai,2021-06-02,reason:【ID1001653】签到源单类型定制，增加参数“拜访签到上传图片添加水印”（第一版）
//判断拜访签到模块是否开启水印
$mobj->setWatermark($singid,$tabid,$address);

//如果客户地址为空，签到后将地址信息反写到单据字段中
if(isset($_REQUEST['saveaddress'])&&$_REQUEST['saveaddress'] == 'yes'){
    $bill_country = $_REQUEST['current_nation'];//国家
    $bill_state = $_REQUEST['current_province'];//省份
    $bill_city = $_REQUEST['current_city'];//城市
    $bill_area = $_REQUEST['current_district'];//区域
    $bill_street = $address;//详细地址
    $tmp_focus = CRMEntity::getInstance($module);
    $_REQUEST['mode'] = 'edit';
    $tmp_focus->mode = 'edit';
    $tmp_focus->id = $record;
    $tmp_focus->retrieve_entity_info($record,$module);
    $fieldname_arr = array('bill_country'=>$bill_country,
                            'bill_state'=>$bill_state,
                            'bill_city'=>$bill_city,
                            'bill_area'=>$bill_area,
                            'bill_street'=>$bill_street);
    //联系人模块详细地址字段不同
    if($module == 'Contacts'){
        unset($fieldname_arr['bill_street']);
        $fieldname_arr['mailingstreet'] = $bill_street;
    }
    foreach($fieldname_arr as $fieldname=>$fieldvalue){
        if(isset($tmp_focus->column_fields[$fieldname])&&!empty($fieldvalue)){
            $tmp_focus->column_fields[$fieldname] = $fieldvalue;
        }
    }
    $tmp_focus->is_check_business = 'no';
    $tmp_focus->save($module);
}

if($lastinsertid > 0){
    ConvertTojsonString('1',array('success'=>getFixedLabel('SIGNINSUCCEEDED')),'');
}else{
    ConvertTojsonString('-1',array('failed'=>getFixedLabel('SIGNINFAILED')),'');
}

?>