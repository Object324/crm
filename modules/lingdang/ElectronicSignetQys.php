<?php
//ls 2024-03-20 XUQIU20240315-05 契约锁接口
global $adb,$current_user,$currentModule;
$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony'] = 'yes';
$frommodule=$_REQUEST['frommodule'];

$focus = CRMEntity::getInstance($frommodule);
$electronicSignatureInfo = $focus->getQysElectronicSignatureInfo();

$operation = $_REQUEST["operation"];
if ($operation == 'showHtmlByFile') {
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


    $smarty->assign("RECORD",$_REQUEST['record']);
    $arr['title'] = '上传本地文件创建签署文档';
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $str = $smarty->fetch("modules/lingdang/CreateDocument.tpl");//创建签署文档

    $arr['content'] = $str;

    ConvertTojsonString(1, $arr, "success");

}
elseif($operation == 'createbyfile'){
//    dump($_FILES);
    $key = key($_FILES);
    if ($_FILES[$key]['error'] != UPLOAD_ERR_OK) {
        ConvertTojsonString(-1, [], "上传文件失败");
    }

    $post_data['file'] = new CURLFile($_FILES[$key]['tmp_name']);
//    $post_data['file'] = file_get_contents($_FILES[$key]['tmp_name']);//都可以获取到文件流
    $post_data['title'] = $_REQUEST['flowtitle'];
    $post_data['fileType'] = pathinfo($_FILES[$key]['name'], PATHINFO_EXTENSION);

    crm_load_class_file("ElectronicSignatureQys", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureQys($frommodule);
    $resp = $ElectronicSignatureObj->createbyfile($post_data);
    $smarty->assign("RECORD",$_REQUEST['record']);
    $smarty->assign("documentId",$resp['documentId']);
    //预填发起方信息
    $company_sql = "select organizationname from ld_organizationdetails";
    $company_res = $adb->pquery($company_sql);
    $tenantName = $adb->query_result($company_res,0,0);
    $smarty->assign("tenantName",$tenantName);
    $smarty->assign("creatorName",$current_user->last_name);
    $smarty->assign("creatorMobile",$current_user->phone_mobile);

    $arr['title'] = '创建电子签约';
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $str = $smarty->fetch("modules/lingdang/CreateFlowsByFile.tpl");
    $arr['content'] = $str;

    $msg = isset($resp['message'])?$resp['message']:"创建签署文档失败";
    if ($resp['code'] == '0') {
        $arr['documentId'] = $resp['documentId'];
        $arr['resp'] = $resp;
        ConvertTojsonString(1, $arr, $msg);
    }else{
        ConvertTojsonString(-1, $resp, $msg);
    }

}
elseif($operation == 'CreateFlowsByDocumentId'){

//    dump($_REQUEST);
    $record = $_REQUEST['record'];

    $post_data['documents'] = array($_REQUEST['documentId']);
    $post_data['subject'] = trim($_REQUEST['subject']);
    $post_data['send'] = true;//直接发起电子签约
    $post_data['businessData'] = ldcrm_json_encode([
        "record"=>$record,
        "sponsorid"=>$current_user->id,
        "subject"=>$post_data['subject'],
        "createon"=>date("Y-m-d H:i:s"),//发起时间
        "deadline"=>!empty($_REQUEST['expireTime'])?date("Y-m-d 23:59:59",strtotime($_REQUEST['expireTime'])):"",//截止时间
        "module"=>$frommodule
    ]);//业务数据，可以多个

    //发起方信息
    $post_data['tenantName'] = trim($_REQUEST['tenantName']);//发起主体名称
    $post_data['creatorName'] = trim($_REQUEST['creatorName']);//发起人姓名
    $creator_mobile = trim($_REQUEST['creatorInfo']['mobile']);
    $post_data['creatorInfo'] = array("mobile"=>$creator_mobile);//里面参数是手机号

    //被签署方信息
    $tenantType = trim($_REQUEST['signatories']['tenantType']);
    if ($tenantType == 'COMPANY') {
        $signatory = array(
            "tenantType"=>$tenantType,
            "tenantName"=>trim($_REQUEST['signatories']['tenantName']),
            "receiverName"=>trim($_REQUEST['signatories']['receiverName']),
            "contact"=>trim($_REQUEST['signatories']['contact']),
            "serialNo"=>'2',
            "actions"=>array(["type"=>$_REQUEST['signatories_actions_type'],"serialNo"=>'1']),//企业签署方必传action
        );
    }else{
        $signatory = array(
            "tenantType"=>$tenantType,
            "tenantName"=>trim($_REQUEST['signatories']['tenantName']),
            "contact"=>trim($_REQUEST['signatories']['contact']),
            "serialNo"=>'2',
        );
    }

    //两个签署方信息
    $signatories = array(
        array(
            "tenantType"=>"COMPANY",
            "tenantName"=>$post_data['tenantName'],
            "receiverName"=>$post_data['creatorName'],
            "contact"=>$creator_mobile,
            "serialNo"=>'1',
            "actions"=>array(["type"=>$_REQUEST['creator_actions_type'],"serialNo"=>'1']),//企业签署方必传action
        ),
        $signatory
    );

//dump($post_data);
    $post_data['signatories'] = $signatories;//签署方信息
    if (!empty($_REQUEST['expireTime']))
        $post_data['expireTime'] = $_REQUEST['expireTime'];//签署截止日期
    if (!empty($_REQUEST['endTime']))
        $post_data['endTime'] = $_REQUEST['endTime'];//文件到期日期

//    dump($post_data);
    crm_load_class_file("ElectronicSignatureQys", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureQys($frommodule);
    $resp = $ElectronicSignatureObj->createbycategory($post_data);//1.3.1 创建或发起电子签约

    if ($resp['code'] == '0') {
        //合同发起人  此时可能还没有回调信息，也就没有数据
//        $sql = 'INSERT INTO ld_salesorder_electronicsignet (sponsorid, salesorderid) VALUES (?, ?) ON DUPLICATE KEY UPDATE sponsorid =?;';
//        $adb->pquery($sql, array($current_user->id, $record, $current_user->id));
        $sql = "update $focus->table_name set sponsorid where $focus->table_index = ?";
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
        $post_data['pageType'] = 'CONTENT';//页面预览类型  取值范围：DETAIL（详情页），CONTENT（电子签约正文）；默认为：DETAIL（详情页）
        $post_data['allowDownload'] = 'true';//是否展示下载按钮
        $post_data['allowPrint'] = 'true';//是否展示下载按钮
        $post_data['canViewDetail'] = 'true';//是否展示签署详情按钮

        crm_load_class_file("ElectronicSignatureQys", 'electronicsignature');
        $ElectronicSignatureObj = new ElectronicSignatureQys($frommodule);
        $resp = $ElectronicSignatureObj->contractviewurl($post_data);


        if ($resp['code'] == '0') {
            ConvertTojsonString(1, $resp, $resp['message']);
        }else{
            ConvertTojsonString(-1, $resp, $resp['message']);
        }
    }else{
        ConvertTojsonString(-1, [], "系统无此合同，无法预览");
    }

}


