<?php
global $currentModule,$adb,$current_user;
SqlSearchFilter($_REQUEST);
$modulename = $_REQUEST['modulename'];
$record = $_REQUEST['recordid'];
if($modulename=='ServiceCharge'){
    $modulename='Accounts';
}
$currentModule = $modulename;
$tabid = getTabid($currentModule);
$setype = $_REQUEST['setype'];
switch($setype){
    //editor:gyq_27 data:20170418 reason:分录请求统一
    //功能说明：含分录明细界面，点击分录查看详细内容
    case 'entrydetail':
        if($_REQUEST['entrytype']=='product'){
            crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
            $tabdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($_REQUEST['modulename'],'edit',$_REQUEST['recordid'],'',$this->actionname);
            $tabdetailContent = $tabdetailObj->getrowDetailValueByDetailId($_REQUEST['entryid'],$_REQUEST['sequence_no']);
            $headers = $tabdetailObj->getDetailHeader();
            $fieldnum=0;
            foreach($tabdetailContent as $columnname=>$content){
                foreach($headers as $key=>$headerscontent){
                    if($headerscontent['columnname']==$columnname){
                        $extrydetail[$fieldnum]['label'] = $headerscontent['fieldlabel'];
                        if(empty($content['value'])&&$content['value']!==0&&$content['value']!=='0'){
                            $content['value']='';
                        }
                        $extrydetail[$fieldnum]['text'] = $content['value'];
                        $extrydetail[$fieldnum]['fieldname'] = $columnname;
                        $extrydetail[$fieldnum]['type'] = $headerscontent['uitype'];
                        $fieldnum++;
                        break;
                    }
                }
            }
            $extrydetailF['list'] = $extrydetail;
            ConvertTojsonString(1,$extrydetailF,'');
        }elseif($_REQUEST['entrytype']=='quoteschange'){
            crm_load_class_file('cls_QuotesChange_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
            $tabdetailObj = new cls_QuotesChange_PageRecordValueWX($_REQUEST['modulename'],'edit',$_REQUEST['recordid'],'',$this->action);
            $tabdetailContent = $tabdetailObj->getrowDetailValueByDetailId($_REQUEST['entryid'],$_REQUEST['sequence_no']);
            $headers = $tabdetailObj->headerInfo;
            $fieldnum=0;
            foreach($tabdetailContent as $columnname=>$content){
                foreach($headers as $key=>$headerscontent){
                    if($headerscontent['columnname']==$columnname){
                        $extrydetail[$fieldnum]['label'] = $headerscontent['fieldlabel'];
                        if(empty($content['value'])&&$content['value']!==0&&$content['value']!=='0'){
                            $content['value']='';
                        }
                        $extrydetail[$fieldnum]['text'] = $content['value'];
                        $extrydetail[$fieldnum]['fieldname'] = $columnname;
                        $extrydetail[$fieldnum]['type'] = $headerscontent['uitype'];
                        $fieldnum++;
                        break;
                    }
                }
            }
            $extrydetailF['list'] = $extrydetail;
            ConvertTojsonString(1,$extrydetailF,'');
        }elseif($_REQUEST['entrytype']=='source'){
            crm_load_class_file('cls_TabDetail_PageRecordValueWX','WeiXinApp/include/TabDetailFields');
            $tabdetailObj = new cls_TabDetail_PageRecordValueWX($_REQUEST['modulename'],'edit',$_REQUEST['recordid'],'',$this->actionname);
            $tabdetailContent = $tabdetailObj->getrowDetailValueByDetailId($_REQUEST['entryid'],$_REQUEST['sequence_no']);
            $headers = $tabdetailObj->getDetailHeader();
            $fieldnum=0;
            foreach($tabdetailContent as $columnname=>$content){
                foreach($headers as $key=>$headerscontent){
                    if($headerscontent['columnname']==$columnname){
                        $extrydetail[$fieldnum]['label'] = $headerscontent['fieldlabel'];
                        $extrydetail[$fieldnum]['text'] = empty($content['value'])?'':$content['value'];
                        $extrydetail[$fieldnum]['fieldname'] = $columnname;
                        $fieldnum++;
                        break;
                    }
                }
            }
            $extrydetailF['list'] = $extrydetail;
            ConvertTojsonString(1,$extrydetailF,'');
        }elseif($_REQUEST['entrytype']=='CashBill'){

            crm_load_class_file('cls_CashBillDetail_PageRecordValueWX', 'WeiXinApp/modules/CashBill/EntityData');
            $tabdetailObj = new cls_CashBillDetail_PageRecordValueWX($_REQUEST['modulename'],'edit',$_REQUEST['recordid'], '');
            $tabdetailObj->getDetailHeader();
            $headers = $tabdetailObj->table_header;
            $tabdetailContent = $tabdetailObj->getrowDetailValueByDetailId($_REQUEST['entryid'],$_REQUEST['sequence_no']);
            $fieldnum=0;
            foreach($tabdetailContent as $columnname=>$content){
                foreach($headers as $key=>$headerscontent){
                    if($headerscontent['columnname']==$columnname){
                        $extrydetail[$fieldnum]['label'] = $headerscontent['fieldlabel'];
                        $extrydetail[$fieldnum]['text'] = empty($content['value'])?'':$content['value'];
                        $extrydetail[$fieldnum]['fieldname'] = $columnname;
                        $fieldnum++;
                        break;
                    }
                }
            }
            $extrydetailF['list'] = $extrydetail;
            ConvertTojsonString(1,$extrydetailF,'');
        }
        break;
    case 'AccountsAddress':
        $sql='select ld_account.bill_street as bill_street,ld_account.traffic,
        bill_state,ld_account.bill_city from ld_account where accountid= ?';
        $address_result=$adb->pquery($sql,array($record));
        $province=$adb->query_result($address_result,0,'bill_state');
        $address=$adb->query_result($address_result,0,'bill_street');
        $city=$adb->query_result($address_result,0,'bill_city');
        $traffic=$adb->query_result($address_result,0,'traffic');
        if(empty($address)) {
            $address = $traffic;
        }
        $detail_address=$address;
        if($detail_address!=''&&$detail_address!=null){
            if(stripos($address,$city)===false&&!empty($city)&&$city!='--无--'){
                $detail_address=trim($city).$address;
            }
            if(stripos($detail_address,$province)===false&&!empty($province)&&$province!='--无--'){
                $detail_address=trim($province).$detail_address;
            }    
        }
        else{
            $detail_address = '';
        }

        $jsonArray['list'] = array('address'=>$detail_address);
        ConvertTojsonString(1,$jsonArray,'');
        break;
    case 'AccountsDistance':
        $selectmodule = $_REQUEST['selectmodule'];
        $signout_type = $_REQUEST['signouttype'];
        if(!empty($signout_type)){//签退模块用
            $signin_id = $record;//此处record实则为对应签到单据的id，而非签到中源单的id
            $select_sql = "SELECT record,entitytype from ld_singin where signid = ?";
            $select_result = $adb->pquery($select_sql, array($signin_id));
            $record = $adb->query_result($select_result, 0, 'record');
            $selectmodule = $adb->query_result($select_result, 0, 'entitytype');
        }
        //对于只有地址没有经纬度的单据先填充经纬度信息（导入情况）
        //editor:gyq_81 reason:签到考勤优化 2018/9/27 16:23

        crm_load_class_file('cls_SigninRelatedField_Data', 'include/RelatedField');
        $cls_SigninRelatedField = new cls_SigninRelatedField_Data($selectmodule, $record);
        $address = $cls_SigninRelatedField->getVisitAddress();

        //file_put_contents(globalStatic::$root_directory.'WeiXinApp/modules/Users/abdddc.txt',json_encode($relatedfielddata,JSON_UNESCAPED_UNICODE));

        //editor:gyq_81 reason:签到考勤优化 2018/9/29 17:25
        $distance = getSignDistanceSelfConfig($address);
        //duan 20230808 拜访签到优化,如果单据上存在经纬度，则使用经纬度直接计算
        if(in_array($selectmodule,['Accounts','Leads','Vendors'])){
            $locate_info = getModuleDistanceAddress('Singin','source_list',$selectmodule,$record);
            if(!empty($locate_info) && !empty($locate_info['longtitude'])){
                $nowlongtitude = $_REQUEST['longtitude'];
                $nowlatitude = $_REQUEST['latitude'];
                $distanceoflocate = getDistance($nowlatitude,$nowlongtitude,$locate_info['latitude'],$locate_info['longtitude']);
                $distance = intval(min($distanceoflocate,$distance));
            }
        }

        if(!empty($distance)||$distance===0||$distance==='0'){
            $modulelist = getSinginOptionModule();
            $tabid = getTabid($_REQUEST['selectmodule']);
            if($distance>500) $distance-=500;
            if(!empty($modulelist[$tabid])){
                if($signout_type != 'supsignout'){
                    if($modulelist[$tabid]['no_signin'] == 'yes' && $distance > $modulelist[$tabid]['allowable_distance']){
                        $jsonArray['list'] = array('distance'=>$distance,'address'=>$address);
                        if($signout_type == 'signout'){
                            $remind_str = str_replace('{metre}',$modulelist[$tabid]['allowable_distance'],getFixedLabel('Theadministratorhassetthatitisnotallowedtosignout'));
                        }else{
                            $remind_str = str_replace('{metre}',$modulelist[$tabid]['allowable_distance'],getFixedLabel('Theadministratorhassetthatitisnotallowedtosign'));
                        }
                        ConvertTojsonString(-1,$jsonArray,$remind_str);
                    }
                }
            }
            
            $jsonArray['list'] = array('distance'=>$distance,'address'=>$address);
            ConvertTojsonString(1,$jsonArray,'');
        }else{
            $jsonArray['list'] = array('distance'=>getFixedLabel('INCALCULABLE'),'address'=>$address);
            $selectmodule = $_REQUEST['selectmodule'];
            $tabid = getTabid($selectmodule);
            //判断当前模块是否存在地址相关的字段
            $sql = 'select 1 from ld_field where tabid =? and columnname = ?';
            $result = $adb->pquery($sql,array($tabid,'bill_city'));
            if($adb->num_rows($result)>0){
                $code = 2;
                $message = getFixedLabel('SETADDRESSASVISIT');
            }else{
                $code = 1;
                $message = '';
            }
            ConvertTojsonString($code,$jsonArray,$message);
        }
    case 'ModComments':
        if(!vtlib_isModuleActive('ModComments')){ echo '';exit();}//判断模块是否开启
        $customlink_params = Array('MODULE'=>$currentModule, 'RECORD'=>$record, 'ACTION'=>'DetailView');
        $html=getCommentsDetails($record,'All');        
        $createpermit = isPermitted('ModComments','Create','');    
        $viewpermit = isPermitted('ModComments','DetailView','');            
        $jsonArray['list'] = $html;
        $jsonArray['list2']=array('createpermit'=>$createpermit,'viewpermit'=>$viewpermit);
        ConvertTojsonString(1,$jsonArray,'');
        break;
    case 'Recordsofoperation':
        $focus = CRMEntity::getInstance('Accounts');
        $publicaccount_log = $focus->getPublicAccountLog($record);
        echo $publicaccount_log;exit();
        break;
    case 'Approvelog':
		crm_load_class_file('Approve','modules/Approve');
        $approve = new Approve();
        //$approveinfo = $approve->approveStatus($record);
        //判断当前模块是否开启审批，未开启的话就不显示审批历史
        $approvemod = $approve->getApproveModuleInfo();
        if(!isset($approvemod[$currentModule])){
            $jsonArray['list'] = '';
            ConvertTojsonString(1,$jsonArray,'');
        }
        $approvelog = $approve->approveLog($record);
        for($i=0;$i<sizeof($approvelog);$i++){
            $stepname = $approvelog[$i]['STEPNAME'];
            if($stepname==''||$stepname==null){
                $approvelog[$i]['STEPNAME'] = '';
            }
            $nextstepbyname = $approvelog[$i]['NEXTSTEPBYNAME'];
            /*
            if($nextstepbyname!=''){
                $approvelog[$i]['NEXTSTEPBYNAME'] = substr($nextstepbyname,0,strlen($nextstepbyname)-1);
            }
            */
        }
        if(!empty($approvelog)){
            $jsonArray['list'] = $approvelog;            
        }
        else{        
            $jsonArray['list'] = '';            
        }
        ConvertTojsonString(1,$jsonArray,'');
        break;
    case 'SaveApprovelogStatus'://审批日志展开收起状态保存
        $showtype = $_REQUEST['showtype']=='top'?'pre_hidden':'next_hidden';
        $showvalue = $_REQUEST['showvalue']=='open'?'show':'hidden';
        setUsersettingByLabel($_REQUEST['from_module'], $current_user->id, $showtype, $showvalue);
        break;
    case 'getAccountToContactInfo':
        $query = 'select bill_country,bill_state,bill_city,bill_code,bill_street 
					from ld_account where accountid = ? ';
		$result = $result = $adb->pquery($query,array($record));
		$rows = $adb->num_rows($result);
		$accountinfo = array();
		if($rows == 1){
			$accountinfo['bill_country'] = $adb->query_result($result,0,'bill_country');
			$accountinfo['bill_state'] = $adb->query_result($result,0,'bill_state');
			$accountinfo['bill_city'] = $adb->query_result($result,0,'bill_city');
			$accountinfo['bill_code'] = $adb->query_result($result,0,'bill_code');
			$accountinfo['bill_street'] = $adb->query_result($result,0,'bill_street');
            $jsonArray['list'] = $accountinfo;
		}
        else{
            $jsonArray['list'] = '';
        }        
        ConvertTojsonString(1,$jsonArray,'');
        break;
    case 'getDistance':
        $distance = getSignDistanceSelfConfig($_REQUEST['visit_address']);
        if(!empty($distance)||$distance===0||$distance==='0'){
            if($distance>500) $distance-=500;
            $jsonArray['list'] = array('distance'=>$distance);
            ConvertTojsonString(1,$jsonArray,'');
        }else{
            $jsonArray['list'] = array('distance'=>getFixedLabel('INCALCULABLE'));
            ConvertTojsonString(-1,$jsonArray,getFixedLabel('VISITADDRESSISINCOMPLETE'));
        }
    case 'getCreateDistance':
        $distance_info = getSignDistance($_REQUEST);
        if(empty($distance_info['address'])){
            $jsonArray['list'] = array('distance'=>getFixedLabel('INCALCULABLE'));
            $remind_str = sprintf(getFixedLabel('COMPLETEADDRESSINFORMATION'),$distance_info['reference_module_label']);
            ConvertTojsonString(1,$jsonArray,$remind_str);
        }else{
            //duan 20220815 如果单据中有经纬度，则不需要重新计算
            $distance_type = '';//判断距离是直接使用经纬度计算，还是通过地址计算
            if($distance_info['longtitude'] != '' && $distance_info['latitude'] != ''){
                $distance_type = 'logtitude';
                $nowlongtitude = $_REQUEST['longtitude'];
                $nowlatitude = $_REQUEST['latitude'];
                $longtitude = $distance_info['longtitude'];
                $latitude = $distance_info['latitude'];
                $distance = intval(getDistance($nowlatitude,$nowlongtitude,$latitude,$longtitude));
            }else{
                $distance_type = 'address';
                $distance = getSignDistanceSelfConfig($distance_info['address']);
            }
            //记录泰康制药的签到记录
            $VersionInfo = getVersionInfo();
            if($VersionInfo['account'] == 'taikang'){
                $sign_loginfo = array('addressinfo'=>$distance_info,'distance_type'=>$distance_type,'quest_longtitude'=>$_REQUEST['longtitude'],
                    'quest_latitude'=>$_REQUEST['latitude'],'distance'=>$distance,'record'=>$_REQUEST['modulevalues']['vendorid']);
                file_put_contents(globalStatic::$root_directory.'storage/sign_log_'.date('ymd').'.txt',date('Y-m-d H:i:s').': '.json_encode($sign_loginfo,JSON_UNESCAPED_UNICODE) . "\r\n",FILE_APPEND);
            }
            if($distance>500) $distance-=500;
            $focus = CRMEntity::getInstance($_REQUEST['frommodule']);
            $signin_field = $focus->fieldobj->getFieldInfoobjBykey('bigtype','signin');
            if(!empty($distance)||$distance===0||$distance==='0'){
                $jsonArray['list'] = array('distance'=>$distance,'address'=>$distance_info['address']);
                $msg = '';
                if(!empty($signin_field) ){
                    $msg = str_replace('{metre}',$signin_field->get_allowable_distance(),getFixedLabel('Theadministratorhassetthatitisnotallowedtosign'));
                }
                ConvertTojsonString(1,$jsonArray,$msg);
            }
            else{
                $jsonArray['list'] = array('distance'=>getFixedLabel('INCALCULABLE'),'address'=>$distance_info['address']);
                $msg = getFixedLabel('Theadministratorhassetthatitisnorange');
                if($distance_info['reference_module_label'] != ''){
                    $msg .= '('.$distance_info['reference_module_label'].')';
                }
                ConvertTojsonString(1,$jsonArray,$msg);
            }
        }
    case 'getInformationError':
        //泰康特殊开发，新建终端时判断当前位置和工商信息地址的误差
        $distance_info = getSignDistance($_REQUEST);
        $VersionInfo = getVersionInfo();
        if(empty($distance_info['address'])){
            $jsonArray['list'] = array('distance'=>getFixedLabel('INCALCULABLE'));
            //$remind_str = sprintf(getFixedLabel('COMPLETEADDRESSINFORMATION',$distance_info['reference_module_label']));
            $remind_str = getFixedLabel('ADMINISTRATORLOCATEADDRESS');
            $code = -1;
        }else{
            $distance_type = '';//判断距离是直接使用经纬度计算，还是通过地址计算
            if($distance_info['longtitude'] != '' && $distance_info['latitude'] != ''){
                $distance_type = 'logtitude';
                $nowlongtitude = $_REQUEST['longtitude'];
                $nowlatitude = $_REQUEST['latitude'];
                $longtitude = $distance_info['longtitude'];
                $latitude = $distance_info['latitude'];
                $distance = intval(getDistance($nowlatitude,$nowlongtitude,$latitude,$longtitude));
            }else{
                $distance_type = 'address';
                $distance = getSignDistanceSelfConfig($distance_info['address']);
            }
            if($distance>500) $distance-=500;
            $focus = CRMEntity::getInstance($_REQUEST['frommodule']);
            $signin_field = $focus->fieldobj->getFieldInfoobjBykey('bigtype','signin');
            if(!empty($distance)||$distance===0||$distance==='0'){
                $jsonArray['list'] = array('distance'=>$distance,'address'=>$distance_info['address']);
                $msg = '';
                $code = 1;
                if(!empty($signin_field) ){
                    $msg = str_replace('{metre}',$signin_field->get_allowable_distance(),getFixedLabel('Theadministratorhassetthatitisnotallowedtosign'));
                }
                if($VersionInfo['account'] == 'taikang'){
                    if($distance >500){
                        $msg = getFixedLabel('ADMINISTRATORLOCATEADDRESS');
                        $code = -1;
                    }
                }
            }else{
                $jsonArray['list'] = array('distance'=>getFixedLabel('INCALCULABLE'),'address'=>$distance_info['address']);
                $msg = '';
                $code = 1;
            }
        }
        ConvertTojsonString($code,$jsonArray,$msg);
        
}
function getCommentsDetails($parentid,$type)
{
    global $adb;
	$sourceRecordId =  $parentid;
    $query='SELECT ld_modcomments.modcommentsid as crmid,
            ld_modcomments.commentcontent,ld_modcomments.createdtime,ld_users.last_name 
            FROM ld_modcomments 
            LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id 
            LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_modcomments.modcommentsid 
            WHERE ld_modcomments.deleted = 0 AND ld_modcomments.related_to=? 
            ORDER BY ld_modcomments.modcommentsid DESC ';
    $result = $adb->pquery($query,array($parentid));
	for($i = 0; $i < $adb->num_rows($result); $i++) {
		 $commentcontent = $adb->query_result($result,$i,"commentcontent");
         $createdtime = $adb->query_result($result,$i,"createdtime");
         $last_name = $adb->query_result($result,$i,"last_name");
         $entity[]=array('commentcontent'=>$commentcontent,'createdtime'=>$createdtime,
         'last_name'=>$last_name);
    }
    return $entity;
}
// @edit chj @date 20220427 单据签到计算误差
function getSignDistance($post){
    global $adb;
    $address = '';
    $reference_module_label = [];
    if(!empty($post) && !empty($post['frommodule']) && !empty($post['modulevalues'])){
        $frommodule = $post['frommodule'];
        $longtitude = 0;
        $latitude = 0;
        //duan 20221117 签到获取地址时判断详细地址中是否包含省市区等信息，如果包含，则不重复组合
        $tmp_fieldname_arr = array();
        if(in_array($frommodule,array('Accounts','Leads'))){
            $tmp_fieldname_arr = array('bill_state','bill_city','bill_area');
            $street_fieldname = 'bill_street';
            //$address = $post['modulevalues']['bill_state  '].$post['modulevalues']['bill_city'].$post['modulevalues']['bill_area'].$post['modulevalues']['bill_street'];
        }else if(in_array($frommodule,array('Contacts'))){
            $tmp_fieldname_arr = array('mailingstate','mailingcity','mailingarea');
            $street_fieldname = 'mailingstreet';
            //$address = $post['modulevalues']['mailingstate  '].$post['modulevalues']['mailingcity'].$post['modulevalues']['mailingarea'].$post['modulevalues']['mailingstreet'];
        }else if(in_array($frommodule,array('Vendors'))){
            $tmp_fieldname_arr = array('bill_state','bill_city','bill_area');
            $street_fieldname = 'street';
            //$address = $post['modulevalues']['bill_state  '].$post['modulevalues']['bill_city'].$post['modulevalues']['bill_area'].$post['modulevalues']['street'];
        }
        if(sizeof($tmp_fieldname_arr)>0){
            $address = '';
            $street = $post['modulevalues'][$street_fieldname];
            foreach($tmp_fieldname_arr as $tmp_fieldname){
                $tmpstr = $post['modulevalues'][$tmp_fieldname];
                if(strpos($street,$tmpstr) === false){
                    $address.= $tmpstr;
                }
            }
            $address .= $street;
        } 
        else{
            $focus = CRMEntity::getInstance($frommodule);
            $fieldobj =Field::getInstance($frommodule,$adb);
            $modulefields = $fieldobj->getModuleFields();
            crm_load_class_file('cls_module_uitype','include/fields');
            $uitypetypemodule_arr= cls_module_uitype::getUitypeModules();
            foreach($modulefields as $field){
                $uitype = $field->getUIType();
                $bigtype = $field->getBigType();
                $columnname = $field->getColumnName();
                if($bigtype == 'reference' && in_array($uitype,array(73,57,75,81))){
                    $reference_module = $uitypetypemodule_arr[$uitype];
                    $module_addressinfo_arr = getModuleDistanceAddress($frommodule,$columnanme,$reference_module,$post['modulevalues'][$columnname]);
                    $module_address = $module_addressinfo_arr['address'];
                    $longtitude = $module_addressinfo_arr['longtitude'];
                    $latitude = $module_addressinfo_arr['latitude'];
                    if(!empty($module_address)){
                        $address = $module_address;
                        break;
                    }else{
                        $reference_module_label[] = getTransTab($reference_module);
                    }
                }
            }
        }
    }
    return array('address'=>$address,'reference_module_label'=>implode('、',$reference_module_label),'longtitude'=>$longtitude,'latitude'=>$latitude);
}
// @edit chj @date 20220427 获取模块单据的地址
function getModuleDistanceAddress($module,$columnanme,$reference_module,$record){
    global $adb;
    $address = '';
    $longtitude = 0;
    $latitude = 0;
    if(!empty($reference_module) && !empty($record)){
        $focus = CRMEntity::getInstance($reference_module);
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        //duan 20221117 签到获取地址时判断详细地址中是否包含省市区等信息，如果包含，则不重复组合
        $tmp_fieldname_arr = array();
        if($reference_module == 'Accounts' || $reference_module == 'Leads'){
            $tmp_fieldname_arr = array('bill_state','bill_city','bill_area');
            $street_fieldname = 'bill_street';
        }else if($reference_module == 'Contacts'){
            $tmp_fieldname_arr = array('mailingstate','mailingcity','mailingarea');
            $street_fieldname = 'mailingstreet';
        }else if($reference_module == 'Vendors'){
            $tmp_fieldname_arr = array('bill_state','bill_city','bill_area');
            $street_fieldname = 'street';
        }
        if(sizeof($tmp_fieldname_arr)>0){
            $tmp_sql = "CONCAT('',";
            foreach($tmp_fieldname_arr as $tmp_fieldname){
                $tmp_sql .= "IF(LOCATE($tmp_fieldname,$street_fieldname)>0,'',IFNULL($tmp_fieldname,'')),";
            }
            $tmp_sql .= "IFNULL($street_fieldname,'')) as address";
            $query = "select $tmp_sql,longtitude,latitude from $table_name where $table_index = ?";

            $result =$adb->pquery($query,array($record));
            if($adb->num_rows($result)>0){
                $address = $adb->query_result($result,0,'address');
                $longtitude = $adb->query_result($result,0,'longtitude');
                $latitude = $adb->query_result($result,0,'latitude');
            }
        }
    }
    //$address = '';
    return array('address'=>$address,'longtitude'=>$longtitude,'latitude'=>$latitude);
}
//editor:gyq_81 reason:签到考勤优化 2018/9/29 17:07
function getSignDistanceSelfConfig($r_address){
    global $adb;
    if(empty($r_address)) return '';

    $nowlongtitude = $_REQUEST['longtitude'];//+$littlelong;
    $nowlatitude = $_REQUEST['latitude'];//+$littlelati;

    //计算客户经纬度和传递经纬度的误差
    $locationinfo = getCoordinateByTecentApi($r_address);
    if(is_array($locationinfo) && array_key_exists('result',$locationinfo)){
        $longtitude = $locationinfo['result']['location']['lng'];
        $latitude = $locationinfo['result']['location']['lat'];
    }
    if(empty($longtitude)||empty($latitude)) return false;
    $distanceofpoint = getDistance($nowlatitude,$nowlongtitude,$latitude,$longtitude);

    //根据传参的实时地址，计算经纬度
    $address = $_REQUEST['address'];
    if(empty($address)) return intval($distanceofpoint);
    $locationinfo = getCoordinateByTecentApi($address);
    if(array_key_exists('result',$locationinfo)){
        $nowlongtitude = $locationinfo['result']['location']['lng'];
        $nowlatitude = $locationinfo['result']['location']['lat'];
    }
    if(empty($nowlongtitude)||empty($nowlatitude)) return intval($distanceofpoint);

    //计算客户经纬度和传递地址转换后经纬度的误差
    $distanceofaddress = getDistance($nowlatitude,$nowlongtitude,$latitude,$longtitude);

    $distance = min($distanceofpoint,$distanceofaddress);
    return intval($distance);
}
exit();
?>