<?php
//@edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”（弹屏功能和保存通话记录）
global $adb,$current_user;

$callid = $_REQUEST['callid'];//电话号码

$talkid = $_REQUEST['talkid'];//通话id
$calltype = $_REQUEST['calltype'];//通话类型，0来电；1去电
$frommodule = $_REQUEST['frommodule'];
$fromid = $_REQUEST['fromid'];
//保存通话记录  （挂断电话时无论是否接通，都会上传通话记录）  亿维电话语音盒websocket通讯协议
if (isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'savecallyiwei') {

    if($calltype == "1") {
        $callTypeName = "去电";
    }
    else {
        $callTypeName = "来电";
    }

    $status = $_REQUEST['status'];
    $begintime = $_REQUEST['begintime'];//开始时间
    $endtime = $_REQUEST['endtime'];//结束时间

    if(empty($begintime))
    {
        $begintime = $endtime;//结束时间
    }

    $seconds = strtotime($endtime) - strtotime($begintime);//通话时长（秒）

//    $userid = $_SESSION['authenticated_user_id'];
    $userid = $current_user->id;
    $sql = "select id from ld_callbutler where  talkid = ? and userid = ?";
    $result = $adb->pquery($sql,array($talkid, $userid));

    $arr = [];
    if ($calltype == 1 && !empty($frommodule) && !empty($fromid) && $frommodule != 'undefined' && $fromid != 'undefined') { //仅当列表或详情页去电时
        if($adb->num_rows($result))
        {
            //存在    可能弹屏关联保存的时候已经生成了一条通话记录（当时只保存了$talkid和$userid）
            $callButlerID = $adb->query_result($result,0,'id');

            updateCallRecords($callTypeName,$callid,$status,$begintime,$endtime,$seconds,$callButlerID,$frommodule,$fromid);
            $arr = array('calltype'=>'去电,存在更新(列表或详情页拨号)');
        }
        else
        {
            //不存在
            insertCallRecords($talkid,$callTypeName,$callid,$status,$begintime,$endtime,$seconds,$userid,$frommodule,$fromid);
            $arr = array('calltype'=>'去电,不存在新增(列表或详情页拨号)');
        }
    }else{ //来电或者头部拨号去电
        if($adb->num_rows($result))
        {
            //存在    可能弹屏关联保存的时候已经生成了一条通话记录（当时只保存了$talkid和$userid）
            $callButlerID = $adb->query_result($result,0,'id');

            $sqlUpdate = "update ld_callbutler set calltype = ?,phone = ?,status = ?,
    begintime = ?,endtime = ?,time = ?
    where id = ? ";

            $updateResult=$adb->pquery($sqlUpdate,array($callTypeName,$callid,$status,
                $begintime,$endtime,$seconds,$callButlerID));
            if ($calltype == 1)
                $arr = array('calltype'=>'去电,存在更新(头部拨号或者自动拨号)');
            else
                $arr = array('calltype'=>'来电,存在更新');
        }
        else
        {
            //不存在
            $sqlInsert = "insert into ld_callbutler 
    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ";

            $insertresult = $adb->pquery($sqlInsert,array($talkid,$callTypeName,$callid,$status,$begintime,$endtime,$seconds,'',$userid,
                0,0,0,0,0,0,0,0,""));
            if ($calltype == 1)
                $arr = array('calltype'=>'去电,不存在新增(头部拨号或者自动拨号)');
            else
                $arr = array('calltype'=>'来电,不存在新增');
        }
    }


    $_REQUEST['diony'] = 'yes';
    ConvertTojsonString(1, $arr, 'success');

}

//列表及详情页面  去电弹屏  直接跳转到跟进记录,挂断电话时保存通话记录
if ($calltype == 1 && !empty($frommodule) && !empty($fromid) && $frommodule != 'undefined' && $fromid != 'undefined') {//yiwei.js  如果没有初始化赋空值，就会传undefined
    $contentArr['href'] = outlocation($frommodule, $fromid, $talkid);

    $contentArr['title'] = getFixedLabel('OUTCALLCENTERPOP');
    $contentArr['calltype'] = $calltype;
    $contentArr['num_rows'] = 1;
    $contentArr['html'] = '';

}else{
    require_once("CallCenter/lib/cls_callcenter.php");
    //require_once("CRMSecurity.php");
    $bombsql = new cls_calllcenter();


    $CALL_SQL = $bombsql->bombsql($callid);
    $CALL_SQL = substr($CALL_SQL, 0, strlen($CALL_SQL)-10);
    //dump($CALL_SQL);
    $result = $adb->query($CALL_SQL);
    $num_rows = $adb->num_rows($result);
    $contentArr = $bombsql->output_html_json($num_rows,$result);
}

$_REQUEST['diony']='yes';
ConvertTojsonString(1,$contentArr,'success');


/**
 * 列表或详情页  去电弹屏 更新关联信息 （防止未挂断电话前，已经创建了跟进记录，所以需要单独新增）
 *
 **/
function updateCallRecords($callTypeName,$callid,$status,$begintime,$endtime,$seconds,$callButlerID,$frommodule,$fromid){
    global $adb;
    if ($frommodule == 'Accounts') {
        $sqlUpdate = "update ld_callbutler set calltype = ?,phone = ?,status = ?,
    begintime = ?,endtime = ?,time = ?,
    accountid = ?,contactid = ? where id = ? ";
        $updateResult = $adb->pquery($sqlUpdate,array($callTypeName,$callid,$status,$begintime,$endtime,$seconds,
            $fromid,$_REQUEST['detailrecordid'],$callButlerID));

    }
    elseif ($frommodule == 'Contacts') {
        $sqlUpdate = "update ld_callbutler set calltype = ?,phone = ?,status = ?,
    begintime = ?,endtime = ?,time = ?,
    contactid = ? where id = ? ";
        $updateResult = $adb->pquery($sqlUpdate,array($callTypeName,$callid,$status,$begintime,$endtime,$seconds,
            $fromid,$callButlerID));
    }

}

/**
 * 列表或详情页  去电弹屏 插入关联信息
 *
 **/
function insertCallRecords($talkid,$callTypeName,$callid,$status,$begintime,$endtime,$seconds,$userid,$frommodule,$fromid){
    global $adb;
    $sqlInsert = "insert into ld_callbutler 
    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
    ";
    if ($frommodule == 'Accounts') {
        $insertresult = $adb->pquery($sqlInsert,array($talkid,$callTypeName,$callid,$status,$begintime,$endtime,$seconds,'',$userid,
            $fromid,$_REQUEST['detailrecordid'],0,0,0,0,0,0,""));
    }
    elseif ($frommodule == 'Contacts') {
        $insertresult = $adb->pquery($sqlInsert,array($talkid,$callTypeName,$callid,$status,$begintime,$endtime,$seconds,'',$userid,
            0,$fromid,0,0,0,0,0,0,""));
    }
}

/**
 * 外拨页面跳转
 *
 * */
function outlocation($frommodule,$fromid,$talkid)
{

    //在crm查看界面网页中直接点击外拨弹屏
    global $adb;
    $page_addurl='&relatedcreate=yes&frommodule='.$frommodule.'&fromid='.$fromid."&calltalkid=$talkid&calltype=1";

    $location='index.php?pageto_action=index';

    if($frommodule=='Accounts')
    {
        $page_addurl.='&account_id='.$fromid;
        $location.='&pageto_module=ContactRecords';
        if(!vtlib_isModuleActive('ContactRecords')){
            $location = 'index.php?pageto_module=Accounts&pageto_action=index&pageto_record=' . $fromid;
        }
    }
    else if($frommodule=='Contacts')
    {
        $sql='select accountid from ld_contactdetails where contactid=?';
        $result=$adb->pquery($sql,array($fromid));
        if($adb->num_rows($result)>0)
        {
            $accountid=$adb->query_result($result,0,0);

        }
        $page_addurl.='&contact_id='.$fromid.'&account_id='.$accountid;
        $location.='&pageto_module=ContactRecords';
        if(!vtlib_isModuleActive('ContactRecords')){
            $location = 'index.php?pageto_module=Accounts&pageto_action=index&&pageto_record=' . $accountid;
        }
    }
    else if($frommodule=='Vendors')
    {
        $page_addurl.='&vendor_id='.$fromid.'&vendorcontactid='.$fromid;
        $location.='&pageto_module=VendorContactRecords';
        if(!vtlib_isModuleActive('VendorContactRecords')){
            $location = 'index.php?pageto_module=Vendors&pageto_action=index&pageto_record=' . $fromid;
        }
    }
    else if($frommodule=='VendorContact')
    {
        $sql='select vendorid from ld_vendorcontacts where vendorcontactsid=?';
        $result=$adb->pquery($sql,array($fromid));
        if($adb->num_rows($result)>0)
        {
            $vendorid=$adb->query_result($result,0,0);

        }

        $page_addurl.='&contact_id='.$fromid.'&vendor_id='.$vendorid;
        $location.='&pageto_module=VendorContactRecords';
        if(!vtlib_isModuleActive('VendorContactRecords')){
            $location = 'index.php?pageto_module=Vendors&pageto_action=index&pageto_record=' . $vendorid;
        }
    }
    //$page_addurl.='&Create=true';
    $encodeurl=urlencode($page_addurl);
    //在crm查看界面网页中直接点击外拨弹屏

    return $location."&pageto_create=yes&&page_addurl=".$encodeurl;
//    header("Location:".$location."&pageto_create=yes&&page_addurl=".$encodeurl);
//    exit();
}
