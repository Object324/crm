<?php
//ls 240708 XUQIU20240604-05 公有云契约锁对接
global $adb,$current_user,$currentModule;
$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony'] = 'yes';
$frommodule=$_REQUEST['frommodule'];

$focus = CRMEntity::getInstance($frommodule);
$electronicSignatureInfo = $focus->getQysElectronicSignatureInfo();

$operation = $_REQUEST["operation"];

if ($operation == 'createDraftHtml') {
    $record = $_REQUEST['record'];
    //防止多页面签署
    $query = 'select 1 from ld_salesorder_electronicsignet where salesorderid = ? limit 1';
    $result = $adb->pquery($query,array($record));
    if ($adb->num_rows($result) > 0) {
        ConvertTojsonString(-1, array(), "单据已发起签署，请刷新查看");
    }
    //如果启用审批，判断单据是否审批成功
    $approveobj = Approve::getInstance($frommodule);
    $approveModules = $approveobj->getApproveModuleInfo(); //获取所有审批的模块
    if (isset($approveModules[$frommodule])) {
        $focus = CRMEntity::getInstance($frommodule);
//        $focus->retrieve_entity_info($_REQUEST['record'], $frommodule);
        $query = 'select approvestatus from ' . $focus->table_name . ' where ' . $focus->table_index . ' = ? limit 1';
        $result = $adb->pquery($query,array($record));
        $approvestatus = $adb->query_result($result,0,0);
        if ($approvestatus != constant('D_A_S_APPROVED')) {
            ConvertTojsonString(-1, array(), getFixedLabel('NotApprovedNotSignedByForm'));
        }
    }


    //预填发起方信息
    $company_sql = "select organizationname from ld_organizationdetails";
    $company_res = $adb->pquery($company_sql);
    $tenantName = $adb->query_result($company_res,0,0);
    $smarty->assign("tenantName",$tenantName);
    $smarty->assign("creatorName",$current_user->last_name);
    $smarty->assign("creatorMobile",$current_user->phone_mobile);


    $arr['title'] = getFixedLabel('InitiateSigning');
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $str = $smarty->fetch("modules/lingdang/saas/CreateDraft.tpl");//创建草稿
    $arr['content'] = $str;

    ConvertTojsonString(1, $arr, "success");

}
elseif ($operation == 'createDraft') {
    $record = $_REQUEST['record'];

    $post_data['subject'] = trim($_REQUEST['subject']);
    $post_data['send'] = false;//是否发起合同； 发起合同后不能再进行添加文档、 指定签署位置等操作
    $post_data['notifySponsor'] = true;//通知发起方经办人
    $post_data['businessData'] = ldcrm_json_encode([
        "record"=>$record,
        //"sponsorid"=>$current_user->id,
        //"subject"=>$post_data['subject'],
        //"createon"=>date("Y-m-d H:i:s"),//发起时间
        //"deadline"=>!empty($_REQUEST['expireTime'])?date("Y-m-d 23:59:59",strtotime($_REQUEST['expireTime'])):"",//截止时间
        "module"=>$frommodule
    ]);//业务数据，可以多个，但有长度限制，不超过100字符

    //发起方信息
    $creator_tenantName = trim($_REQUEST['tenantName']);//发起主体名称
    $creatoName = trim($_REQUEST['creatorName']);//发起人姓名
    $creator_mobile = trim($_REQUEST['creatorInfo']['mobile']);
//    $post_data['creator'] = array("contact"=>$creator_mobile,"contactType"=>"MOBILE");//可以不传，如果传了且和签署人一样，则不会发送短信

    //被签署方信息
    $tenantType = trim($_REQUEST['signatories']['tenantType']);
    if ($tenantType == 'COMPANY') {
        $signatory = array(
            "tenantType"=>$tenantType,
            "tenantName"=>trim($_REQUEST['signatories']['tenantName']),
            "receiver"=>array("name"=>trim($_REQUEST['signatories']['receiverName']),"contact"=>trim($_REQUEST['signatories']['contact']),"contactType"=>"MOBILE"),
            "serialNo"=>'2',
            "actions"=>array(["type"=>$_REQUEST['signatories_actions_type'],"serialNo"=>'1']),//企业签署方必传action
        );
    }else{
        $signatory = array(
            "tenantType"=>$tenantType,
            "tenantName"=>trim($_REQUEST['signatories']['tenantName']),
            "receiver"=>array("contact"=>trim($_REQUEST['signatories']['contact']),"contactType"=>"MOBILE"),
            "serialNo"=>'2',
        );
    }

    //两个签署方信息
    $signatories = array(
        array(
            "tenantType"=>"COMPANY",
            "tenantName"=>$creator_tenantName,
            "receiver"=>array("name"=>$creatoName,"contact"=>$creator_mobile,"contactType"=>"MOBILE"),
            "serialNo"=>'1',
            "actions"=>array(["type"=>$_REQUEST['creator_actions_type'],"serialNo"=>'1']),//企业签署方必传action
        ),
        $signatory
    );


    $post_data['signatories'] = $signatories;//签署方信息
    if (!empty($_REQUEST['expireTime']))
        $post_data['expireTime'] = date("Y-m-d 23:59:59",strtotime($_REQUEST['expireTime']));//签署截止日期
    if (!empty($_REQUEST['endTime']))
        $post_data['endTime'] = date("Y-m-d 23:59:59",strtotime($_REQUEST['endTime']));//文件到期日期

//    dump($post_data);
    crm_load_class_file("ElectronicSignatureSaasQys", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureSaasQys($frommodule);
    $resp = $ElectronicSignatureObj->createdraft($post_data);//创建合同草稿

    $arr['title'] = '用文件添加合同文档';
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $str = $smarty->fetch("modules/lingdang/saas/addbyfile.tpl");//创建签署文档
    $arr['content'] = $str;

    if ($resp['code'] == '0') {
        $arr['contractId'] = $resp['result']['id'];
        $arr['resp'] = $resp;
        ConvertTojsonString(1, $arr, "success");
    }else{
        ConvertTojsonString(-1, $resp, $resp['message']);
    }

}
elseif($operation == 'addbyfile'){
//    dump($_FILES);
    $record = $_REQUEST['record'];
    $key = key($_FILES);
    if ($_FILES[$key]['error'] != UPLOAD_ERR_OK) {
        ConvertTojsonString(-1, [], "上传文件失败");
    }

    $file_path = $_FILES[$key]['tmp_name'];
    $file_path = iconv("UTF-8", "GBK", realpath($file_path));
    //上传文件不能超过30MB
    $file_size = filesize($file_path);
    $size_limit = 30 * 1024 * 1024; // 30MB = 30 * 1024 * 1024 字节
    if ($file_size > $size_limit) {
        ConvertTojsonString(-1, [], "上传文件大小不能超过30MB");
    }

    $contractId = $_REQUEST['contractId'];
    $post_data['contractId'] = $contractId;
    $post_data['file'] = new \CURLFile($file_path);
//    $post_data['file'] = new CURLFile($_FILES[$key]['tmp_name']);
//    $post_data['file'] = file_get_contents($_FILES[$key]['tmp_name']);//都可以获取到文件流

    $title = pathinfo($_FILES[$key]['name'], PATHINFO_FILENAME);
    if(empty($title)){
        $last_dot_position = strrpos($_FILES[$key]['name'], '.');
        if ($last_dot_position !== false) {
            $title = substr($_FILES[$key]['name'], 0, $last_dot_position);
        } else {
            $title = $_FILES[$key]['name'];//名称  可以随便传，默认传文件名吧
        }

    }
    $post_data['title'] = $title;
    $post_data['fileSuffix'] = pathinfo($_FILES[$key]['name'], PATHINFO_EXTENSION);

    crm_load_class_file("ElectronicSignatureSaasQys", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureSaasQys($frommodule);
    $resp = $ElectronicSignatureObj->addbyfile($post_data);


    if ($resp['code'] == '0') {
        $documentId = $resp['result']['documentId'];
        /*$sql = "INSERT INTO ld_salesorder_electronicsignet (documentid, salesorderid) select ?,? FROM dual WHERE NOT EXISTS (SELECT 1 FROM ld_salesorder_electronicsignet WHERE salesorderid = ?) ON DUPLICATE KEY UPDATE documentid = VALUES(?)";
        $adb->pquery($sql, array($documentId, $record, $record, $documentId));*/

        $arr['contractId'] = $contractId;
        $arr['documentId'] = $documentId;
        $arr['resp'] = $resp;
        ConvertTojsonString(1, $arr, "success");
    }else{
        ConvertTojsonString(-1, $resp, $resp['message']);
    }

}
elseif($operation == 'contractSend'){
    $record = $_REQUEST['record'];

    //发起合同
    $contractId = $_REQUEST['contractId'];
//    $documentId = $_REQUEST['documentId'];
    $post_data['contractId'] = $contractId;


    crm_load_class_file("ElectronicSignatureSaasQys", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureSaasQys($frommodule);
    $resp = $ElectronicSignatureObj->contractSend($post_data);//签署位置 过于灵活，需要根据关键字定位坐标（客户填写关键字和坐标偏移量或者写死关键字），，先不传吧

    if ($resp['code'] == '0') {
        $sql = "update $focus->table_name set sponsorid=? where $focus->table_index = ?";
        $adb->pquery($sql, array($current_user->id, $record));
        ConvertTojsonString(1, $resp, "success");
    }else{
        ConvertTojsonString(-1, $resp, $resp['message']);
    }

}
elseif($operation == 'ContractViewurl'){
    $query = "select flowid from ld_salesorder_electronicsignet where salesorderid = ? ORDER BY id DESC LIMIT 1";//由于有测试数据，故需limit，正常一条单据只有一个签署完成的电子合同
    $result = $adb->pquery($query,array($_REQUEST['record']));
    if ($adb->num_rows($result) > 0) {
        $flowid = $adb->query_result($result,0,'flowid');

        $post_data['contractId'] = $flowid;//合同id

        crm_load_class_file("ElectronicSignatureSaasQys", 'electronicsignature');
        $ElectronicSignatureObj = new ElectronicSignatureSaasQys($frommodule);
        $resp = $ElectronicSignatureObj->contractviewurl($post_data);


        if ($resp['code'] == '0') {
            $arr['pageUrl'] = $resp['result']['pageUrl'];
            $arr['resp'] = $resp;
            ConvertTojsonString(1, $arr, $resp['message']);
        }else{
            ConvertTojsonString(-1, $resp, $resp['message']);
        }
    }else{
        ConvertTojsonString(-1, [], "系统无此合同，无法预览");
    }

}
elseif($operation == 'downloadContract'){
    $query = "select flowid,flowname from ld_salesorder_electronicsignet where salesorderid = ? ORDER BY id DESC LIMIT 1";
    $result = $adb->pquery($query,array($_REQUEST['record']));
    if ($adb->num_rows($result) > 0) {
        $flowid = $adb->query_result($result,0,'flowid');
        $flowname = $adb->query_result($result,0,'flowname');

        $post_data['contractId'] = $flowid;
        $post_data['downloadItems'] = 'CONTRACT';//下载子项目，子项目可选项：CONTRACT（"合同原文"）、SIGNLOG（"签署日志"）、ATTACHMENT（"附件"）、NOTARY（"存证报告"）、ENDSIGN_ATTACHMENT（“强制结束附件”），各子项以逗号（","）相隔，如：CONTRACT,SIGNLOG，默认为合同文件与签署日志
        //$post_data['downloadItems'] = 'CONTRACT,SIGNLOG,ATTACHMENT,NOTARY,ENDSIGN_ATTACHMENT';//全部下载

        crm_load_class_file("ElectronicSignatureSaasQys", 'electronicsignature');
        $ElectronicSignatureObj = new ElectronicSignatureSaasQys($frommodule);
        $resp = $ElectronicSignatureObj->contractDownload($post_data);

        $file_name = $flowname.".zip";
        @ob_clean();
        @ob_start();
        header('Content-Type: application/octet-stream');
        header('Content-Disposition: attachment; filename="' . $file_name . '"');
        echo $resp;
        @ob_end_flush();
        exit;

    }else{
//        ConvertTojsonString(-1, [], "系统无此合同，无法下载");
        exit("系统无此合同，无法下载");
    }

}


