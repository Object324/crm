<?php
global $currentModule,$current_user;
$requestcorpids = $_REQUEST['cropidarr'];
$cropidtonamearr = $_REQUEST['cropidtonamearr'];
$totalrows = $_REQUEST['totalrows'];
$logid = $_REQUEST['logid'];
crm_load_class_file("cls_soukebao","modules/ldsoukebao/lib");
$soukebaoobj = cls_soukebao::getInstance();
$importtype = 'skip';
if(false&&$_REQUEST['importsearchdata'] == 'yes'){

    $soukebaoobj->setoperationtype("searchcondition");
    $currentpage = $_REQUEST['currentPage'];
    $pagesize = $_REQUEST['pagesize'];
    $searchcolumn = $_REQUEST['searchcolumn'];
    $searchtext = $_REQUEST['searchtext'];
    $jsonsearchadvance = '{}';
    $jsonmapinfo = '';
    $soukebaoobj->setsearchtext($searchtext);
    $soukebaoobj->setsearchcolumn($searchcolumn);
    $soukebaoobj->setcurrentpage($currentpage);
    $soukebaoobj->setpagesize($pagesize);
    $search_advance_arr = [];
    if(isset($_REQUEST['BaseData'])&&!empty($_REQUEST['BaseData']))
    {
        $BaseData = $_REQUEST['BaseData'];
        foreach ($BaseData['filtergroup'] as $tmpindex=>$tmpcolumninfo)
        {
            $tmpcolumnname = $tmpcolumninfo['value'];
            $tmppicklistarr = $tmpcolumninfo['checklist'];
            $tmpdependencyfield = $tmpcolumninfo['dependencyfield'];
            if($tmpdependencyfield == 'yes'){
                //如果椒级联字段,获取级联对应搜索条件
                $tmpdependencycondendition = $soukebaoobj->getDependencySearchCondition($tmpcolumnname,$tmppicklistarr);
                if(!empty($tmpdependencycondendition)){
                    $search_advance_arr['dependency'] = [$tmpcolumnname=>$tmpdependencycondendition];
                }
            }
            else{
                foreach ($tmppicklistarr as $tmppicklistindex=>$tmppicklistinfo)
                {
                    $tmpselected = $tmppicklistinfo['selected'];
                    $tmppicklistid = $tmppicklistinfo['value'];
                    if($tmpselected == true)
                    {
                        if(!array_key_exists($tmpcolumnname,$search_advance_arr))
                        {
                            $search_advance_arr[$tmpcolumnname] = [];
                        }
                        $search_advance_arr[$tmpcolumnname][] = $tmppicklistid;
                    }
                }
            }
        }
    }
    if(isset($_REQUEST['AdvanceData'])&&!empty($_REQUEST['AdvanceData']))
    {
        $AdvanceData = $_REQUEST['AdvanceData'];
        foreach ($AdvanceData['filtergroup'] as $tmpindex=>$tmpcolumninfo)
        {
            $tmpcolumnname = $tmpcolumninfo['value'];
            $tmppicklistarr = $tmpcolumninfo['checklist'];
            foreach ($tmppicklistarr as $tmppicklistindex=>$tmppicklistinfo)
            {
                $tmpselected = $tmppicklistinfo['selected'];
                $tmppicklistid = $tmppicklistinfo['value'];
                if($tmpselected == true)
                {
                    if(!array_key_exists($tmpcolumnname,$search_advance_arr))
                    {
                        $search_advance_arr[$tmpcolumnname] = [];
                    }
                    if(!in_array($tmppicklistid,$search_advance_arr[$tmpcolumnname])){
                        $search_advance_arr[$tmpcolumnname][] = $tmppicklistid;
                    }

                }
            }
        }
    }

    if(!empty($search_advance_arr)){
        $jsonsearchadvance = json_encode($search_advance_arr);
        $soukebaoobj->setsearchadvance($jsonsearchadvance);
    }
    //地图获客条件
    if($currentModule == 'ldsoukebaomap' && isset($_REQUEST['mapCenter'])&&!empty($_REQUEST['mapCenter'])){
        $mapCenter = $_REQUEST['mapCenter'];
        $mapRadius = $_REQUEST['mapRadius'];
        $lat = $mapCenter['lat'];
        $lng = $mapCenter['lng'];
        $mapRadius = $mapRadius/1000;//单位为1000;
        $mapinfoarr = array('jingdu'=>$lng,'weidu'=>$lat,'radius'=>$mapRadius);
        $jsonmapinfo = json_encode($mapinfoarr);
        $soukebaoobj->setmapinfo($jsonmapinfo);
    }
    if($currentModule == 'ldsoukebao'){
        setUsersettingByLabel($currentModule,$current_user->id,'soukebaocondition', $jsonsearchadvance);
    }
    $data = $soukebaoobj->getlistByoperationtype();
    $cropidarr = [];
    foreach($data['list'] as $tmpindex=>$tmpinfo){
        $cropidarr[] = $tmpinfo['cropid'];
    }
    $requestcorpids = implode(',',$cropidarr);
}
$log = [];
//对corpid的处理，已经导入的corpid不再重新导入
$requestcorpid_arr = explode(',',$requestcorpids);
$importrows = count($requestcorpid_arr);
$corpid_arr = $soukebaoobj->getNoImportedcorpidarr($requestcorpid_arr);
$corpids = implode(',',$corpid_arr);


$module = getUsersettingByLabel('ldsoukebao','1','soukebaoimportmodule')?:'Accounts';//指明模块名，从数据库获取
crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');//系统导入日志
$cls_operationLogs = cls_OperationLogs::getInstance($module,'Import');
//开始导入
if(empty($logid)){
    $logid = $cls_operationLogs->saveImportStartLogs('Insert','accountname','','','');//导入开始
    $_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_successrows'] = 0;
    $_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_importrows'] = 0;
    $_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_log'] = [];
}
$_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_importrows'] += $importrows;

$haveimportidarr = array_diff($requestcorpid_arr,$corpid_arr);
if(is_array($haveimportidarr)&&count($haveimportidarr)>0){
    foreach ($haveimportidarr as $tmpcoportid){
        $log[] = $cropidtonamearr[$tmpcoportid].getTranstab($module).'已导入过,跳过!';
    }
}
crm_load_class_file("cls_BusinessInformation","modules/Users");
$focus=CRMEntity::getInstance($module);
$tabid = getTabid($module);
$custom_tabname = $focus->customFieldTable[0];//自定义字段表
$modulefields=$focus->fieldobj->getModuleFields();
$businessinformationobj = cls_BusinessInformation::getInstance($module);
$backfillfields_arr = $businessinformationobj->getBackFillfields();
$backfillarr = array();
$havecompanyname = 'no';
foreach($backfillfields_arr as $key => $backfillinfo)
{
    $tianyanchaname = $backfillinfo['tianyanchaname'];
    $trancolumnname = $backfillinfo['trancolumnname'];
    $type = $backfillinfo['type'];
    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname",$trancolumnname);
    if($trancolumnname == 'null'|| empty($fieldinfo))continue;
    $backfillarr[$trancolumnname] = array('tianyanchaname'=>$tianyanchaname,'bigtype'=>$type);
    if($tianyanchaname == 'name'){
        $havecompanyname == 'yes';
    }
}
if($havecompanyname == 'yes')
{
    ConvertTojsonString(-1,array(),'没有设置公司名称映射字段,请先设置回填字段!');
}
$data = [];
if(!empty($corpids)){
    //查数据
    $soukebaoobj->setoperationtype("getdatalistbycorpids");
    $soukebaoobj->setcorpids($corpids);
    $data = $soukebaoobj->getlistByoperationtype();
}
global $adb,$current_user;
$poiaddress_arr = array('address','state','city','district','point','country');
$poiaddrestodatakey_arr = array('address'=>'regLocation','state'=>'province','city'=>'city','district'=>'district','point'=>'point','country'=>'country');
$objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
global $global_picklist_colors;
$pickbyfieldnamearr = [];
foreach ($data as $tmpindex=>$datainfo)
{
    $updatemapflag = 'no';//更新地图对应经纬度点信息标志
    $companyname = $datainfo['name'];//公司名
    $importcorpid = $datainfo['corpid'];//corpid
    //导入时再次判断数据是否导入过
    $tmpcorpid_arr = $soukebaoobj->getNoImportedcorpidarr([$importcorpid]);
    //数据已导入过crm，则跳过本次循环
    if(empty($tmpcorpid_arr)){
        $log[] = $companyname.getTranstab($module).'已导入过crm,跳过!';
        continue;
    }

    $selectsql = "select * from ".$focus->table_name." where accountname =? and deleted=0;";
    $selectresult = $adb->pquery($selectsql,array($companyname));
    if($adb->num_rows($selectresult)>0)
    {
        $focus->id = $adb->query_result($selectresult,0,'accountid');
        if($importtype == 'skip'){
            //客户已存在,跳过
            $log[] = $companyname.getTranstab($module).'已存在,跳过!';
            $soukebaoobj->setImportdatalog($tabid,$focus->id,$importcorpid);
            continue;
        }
        $focus->mode = 'edit';
        $focus->retrieve_entity_info($focus->id,$module);
    }
    else{
        $focus->mode = 'create';
        $focus->id = '';
        $focus->column_fields = [];
    }
    //$focus->saveentityNoJudge = 'yes';    //保存时不判断
    $focus->setsavebyerrormsg('yes');
    $focus->is_check_business = 'no';
    $setcontactid = 0;
    foreach($backfillarr as $tmpcolumnname=>$backfillinfo)
    {
        $tianyanname = $backfillinfo['tianyanchaname'];
        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname",$tmpcolumnname);
        $fieldname = $fieldinfo->getfieldname();
        //回填详细地址时需更新经纬度
        if($fieldname == 'locationaddress'){
            $updatemapflag = 'yes';
        }
        if(in_array($tianyanname,$poiaddress_arr)){
            $tmpbusinesskey = $poiaddrestodatakey_arr[$tianyanname];
            $fieldvalue = $datainfo[$tmpbusinesskey];
            if($tmpbusinesskey == 'point'){
                $fieldvalue = trim($datainfo['jingdu'].','.$datainfo['weidu'],',');
            }
            elseif($tmpbusinesskey == 'country'){
                $fieldvalue = '中国';
            }
        }
        else{
            $fieldvalue = $datainfo[$tianyanname];
            if($backfillinfo['type']=='picklist'&&!empty($fieldvalue))
            {
                //获取编辑下拉框内容
                if(array_key_exists($fieldname,$pickbyfieldnamearr)){
                    $pickarr=$pickbyfieldnamearr[$fieldname];
                }
                else{
                    $pickarr = array();
                    $pickarr = $objPickList->getPickListValues($fieldname,$fieldinfo,array(),'id');
                    $pickbyfieldnamearr[$fieldname]=$pickarr;
                }
                $values= array_values($pickarr);
                if(!in_array($fieldvalue,$values))
                {
                    $objPickList->addPickValue($fieldname,$fieldvalue);
                    unset($pickbyfieldnamearr[$fieldname]);
                }
            }
        }
        //zkt 20240313 BUG20240313-22 PC端--工商回填/批量回填，如果工商查询结果为空，不覆盖字段原有的值
        if(empty($fieldvalue)&&$fieldvalue!='0'&&$fieldvalue!=0){
            continue;
        }
        $field_tabname = $fieldinfo->tableName;
        if(in_array($field_tabname,$focus->tab_name)){
            $focus->column_fields[$fieldname] = $fieldvalue;
        }
        else if($field_tabname == 'ld_contactdetails'){
            $contact_fieldarr[$fieldname] = $fieldvalue;
        }
    }
    $smownercolumnname = $focus->getSmownerColumName();
    $smownerfieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname",$smownercolumnname);
    $smownerfieldname = $smownerfieldinfo->getfieldname();
    $focus->column_fields[$smownerfieldname] = $current_user->id;
    $focus->column_fields['sourcefrom'] = 'lingdanghuoke';//单据来源,灵当获客
    //设置$_REQUEST
    foreach($focus->column_fields as $tmpfieldname=>$value)
    {
        //zkt 20230428 BUG0065762 合同订单列表界面任意一条单据，使用小编辑编辑“客户类型”保存提示合同 不允许大于合计（实际上单据是满足验证规则条件的）
        $reqfieldname = $tmpfieldname;
        if($tmpfieldname=='hdnGrandTotal'){
            if($module=='CashBill')
            {
                $reqfieldname='cashbill_total';
            }
            else if($module=="SendCashBill")
            {
                if(is_numeric($_REQUEST['sendcashbill_total']))
                {
                    $reqfieldname='sendcashbill_total';
                }
                else{
                    $reqfieldname='total';
                }
            }
            else
                $reqfieldname='total';
        }
        $_REQUEST[$reqfieldname]=$value;
    }
    //保存回填内容,不包括首要联系人区块信息
    $focus->save($module);
    if(!empty($focus->saveerrormsg)){
        $log[] = $companyname.getTranstab($module).'导入失败，原因：'.$focus->saveerrormsg;
        continue;
    }

    //客户修改日志
    if($focus->mode=='edit'){
        $focus->modstatic->triggerEvent($module);
    }
    $id = $focus->id;
    //更新经纬度信息
    $point=trim($datainfo['jingdu'].','.$datainfo['weidu'],',');
    $pointarr = explode(',',$point);
    $latitude = $pointarr[0];
    $longtitude = $pointarr[1];
    if(($module == 'Accounts') && $updatemapflag = 'yes'){
        $query = "select CONCAT_WS('',bill_state,bill_city,bill_street) as address,accountid from ld_account where accountid = ?";
        $addrresult = $adb->pquery($query,array($id));
        $address = $adb->query_result($addrresult,0,0);
        $adb->pquery('update ld_account set location_address =?, longtitude = ?, latitude = ? where accountid = ?',array($address,$longtitude,$latitude,$id));
    }
    //回填信息设置联系人时:联系人存在且与回填联系人相同或原联系人信息不存在，则更新联系人信息；联系人存在与回填联系人不同，新增联系人；
    if($module == 'Accounts' && !empty($contact_fieldarr))
    {
        $contactsql = "select contactid,lastname from ld_contactdetails where accountid = ? and lastname = ? and deleted=0 order by createdtime asc";
        $contactresult = $adb->pquery($contactsql,array($id,$contact_fieldarr['lastname']));
        $contact_num_rows = $adb->num_rows($contactresult);

        if(empty($smownerid)||$smownerid<0){
            $smownerid = $current_user->id;
        }
        //联系人默认值
        $contact_fieldarr['assigned_user_id'] = $smownerid;
        $contact_fieldarr['account_id'] = $id;
        $lastname_arr = array();
        $contactfocus=CRMEntity::getInstance('Contacts');
        $contactfocus->id = 0;
        $contactfocus->column_fields = [];
        //联系人信息不存在
        if($contact_num_rows<=0)
        {
            $contactfocus->mode="create";
            foreach($contact_fieldarr as $contact_fieldname=>$value)
            {
                $contactfocus->column_fields[$contact_fieldname]=$value;
            }
            //首要联系人为空创建首要联系人
            if($setcontactid==0){
                $contactfocus->column_fields['reference']=1;
            }

        }
        //联系人信息存在
        else if($contact_num_rows>0)
        {
            //回填信息设置了联系人电话则判断联系人信息存在同时判断联系人电话
            $sql = "select contactid,lastname,reference from ld_contactdetails where deleted=0 and accountid = $id and lastname =? ";
            if(isset($contact_fieldarr['mobile'])){
                $sql .= " and (mobile = ? or mobile is null)";
                $result = $adb->pquery($sql." order by mobile desc, createdtime asc limit 1",array($contact_fieldarr['lastname'],$contact_fieldarr['mobile']));
            }
            else{
                $result = $adb->pquery($sql." order by createdtime asc limit 1",array($contact_fieldarr['lastname']));
            }
            $sevecontactid = 0;
            if($adb->num_rows($result)>0){
                $sevecontactid = $adb->query_result($result,0,'contactid');
            }
            if($sevecontactid>0){
                $contactfocus->id=$sevecontactid;
                $contactfocus->retrieve_entity_info($sevecontactid,'Contacts');
                $contactfocus->mode="edit";
            }
            else{
                $contactfocus->mode="create";
                //首要联系人为空创建首要联系人
                if($setcontactid=0){
                    $contactfocus->column_fields['reference']=1;
                }
            }

            foreach($contact_fieldarr as $contact_fieldname=>$value)
            {
                $contactfocus->column_fields[$contact_fieldname]=$value;
            }
        }
        $contactfocus->saveentityNoJudge = 'yes';
        $contactfocus->save("Contacts");
        //联系人修改日志
        if($contactfocus->mode=='edit'){
            $contactfocus->modstatic->triggerEvent("Contacts");
        }
    }
    $log[] = $companyname.getTranstab($module).'导入成功!';
    //记录导入的数据
    $soukebaoobj->setImportdatalog($tabid,$focus->id,$importcorpid);
    $successrows ++;
}
$_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_successrows'] += $successrows;
$_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_log'] =array_merge($_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_log'],$log);
$importrows = $_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_importrows'];
$tmplog = ["共选择了 <span  style=' color: #ff7d1d;'>".$totalrows."</span>条记录，正在操作第 <span  style=' color: #ff7d1d;'>".($importrows+1)."</span>条记录，请稍后....."];
//导入完成更新导入日志
if($_REQUEST['maxtimes']==$_REQUEST['currenttimes']){
    $successrows = $_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_successrows'];
    $cls_operationLogs->saveFinishLogs($logid,'',$importrows,$importrows-$successrows,'ImportFailed');
    $tmplog = [];
    if($_REQUEST['maxtimes'] > 1){
        $tmplog = ["共选择了 ".$totalrows."条记录，成功 ".$successrows."，失败 ".($importrows-$successrows)."条"];
    }
    $tmplog = array_merge($tmplog,$_SESSION[$currentModule][$current_user->id]['importlog'][$logid.'_log']);
    unset($_SESSION[$currentModule][$current_user->id]['importlog']);
}
ConvertTojsonString(1,array('log'=>$tmplog,'logid'=>$logid),'sussess');
?>
