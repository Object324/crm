<?php
//ls 240805 XUQIU20240626-13 法大大电子签接口对接
global $adb,$current_user,$currentModule;
//BUG20240823-52  actors[actorType]=corp  这种传值，不支持解析，故先去掉验证
//BUG20240823-34 ls  240823 发起签署，上传了一个.doc文档，页面一直转圈(前端加密参数里有formdata的文件相关参与,但是后端$_REQUEST是获取不到值的)
$operation = $_REQUEST["operation"];
if (!in_array($operation,['UploadFile','CreateSignTask'])) {
    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
}


$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony'] = 'yes';
$frommodule=$_REQUEST['frommodule'];

$focus = CRMEntity::getInstance($frommodule);


if ($operation == 'CreateUploadFileHtml') {
    $record = $_REQUEST['record'];
    //防止多页面签署
    $query = 'select 1 from ld_salesorder_electronicsignet where salesorderid = ? and platform =? limit 1';
    $result = $adb->pquery($query,array($record,'fdd'));
    if ($adb->num_rows($result) > 0) {
        ConvertTojsonString(-1, array(), "单据已发起签署，请刷新查看");
    }
    //如果启用审批，判断单据是否审批成功
    $approveobj = Approve::getInstance($frommodule);
    $approveModules = $approveobj->getApproveModuleInfo(); //获取所有审批的模块
    if (isset($approveModules[$frommodule])) {
        $focus = CRMEntity::getInstance($frommodule);
//        $focus->retrieve_entity_info($_REQUEST['record'], $frommodule);//审批状态不启用则取不到值
        $query = 'select approvestatus from ' . $focus->table_name . ' where ' . $focus->table_index . ' = ? limit 1';
        $result = $adb->pquery($query,array($record));
        $approvestatus = $adb->query_result($result,0,0);
        if ($approvestatus != constant('D_A_S_APPROVED')) {
            ConvertTojsonString(-1, array(), getFixedLabel('NotApprovedNotSignedByForm'));
        }
    }


    $smarty->assign("RECORD",$record);
    $arr['title'] = '上传本地文件';
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext'] = getFixedLabel("CANCEL");
    $str = $smarty->fetch("modules/lingdang/fdd/CreateUploadFileHtml.tpl");//上传签署文档 页面
    $arr['content'] = $str;
    ConvertTojsonString(1, $arr, "success");
}
elseif($operation == 'UploadFile'){
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
    $size_limit = 50 * 1024 * 1024; // 50MB = 50 * 1024 * 1024 字节
    if ($file_size > $size_limit) {
        ConvertTojsonString(-1, [], "上传文件大小不能超过50MB");
    }

    //0、获取法大大企业成员列表
    crm_load_class_file("ElectronicSignatureClassFdd", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureClassFdd($frommodule);

    $resp = $ElectronicSignatureObj->getCorpList();// corp/entity/get-list
    if ($resp['code'] == '100000') {
        $corplists = $resp['data'];
        $smarty->assign("corplists",$corplists);
    }else{
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." getCorpList: resp：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, $resp, "创建签署任务失败：获取企业主体列表失败");
    }

    $memberlist = [];
    $post_data['openCorpId'] = $ElectronicSignatureObj->openCorpId;
    $post_data['listPageNo'] = 1;//此处指定第几页
    $post_data['listPageSize'] = 100;
    $memberlists = $ElectronicSignatureObj->getMemberList($post_data,$memberlist);//corp/member/get-list
    if (count($memberlists)>0) {
        $smarty->assign("memberlists",$memberlists);
    }else{
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." getMemberList: request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, [], "创建签署任务失败：获取企业成员列表失败");
    }



    //1、获取文件上传地址   /file/get-upload-url  生成两个上传地址：一个是“上传本地文件”用到的地址uploadUrl，另一个发起合同使用的文件地址fddFileUrl
    $post_data = [];
    $post_data["fileType"] = "doc";
    $resp = $ElectronicSignatureObj->getUploadUrl($post_data);

    if ($resp['code'] != '100000' || empty($resp['data']['uploadUrl'])) {
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." getUploadUrl: request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." getUploadUrl: req：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, $resp, "创建签署任务失败：获取上传地址失败");
    }
    $fddFileUrl = $resp['data']['fddFileUrl'];
    $uploadUrl = $resp['data']['uploadUrl'];


    //2、上传文件
    $post_data = [];
    //$post_data['file'] = new \CURLFile($file_path);
    $post_data['filepath'] = $file_path;
    $post_data['uploadurl'] = $uploadUrl;
    $resp = $ElectronicSignatureObj->uploadFile($post_data);
    if ($resp === false) {
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." uploadFile: request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." uploadFile: req：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, $resp, "创建签署任务失败：上传失败");
    }


    //3、文件处理 /file/process
    $post_data = [];
    /*$title = pathinfo($_FILES[$key]['name'], PATHINFO_FILENAME);
    if(empty($title)){
        $last_dot_position = strrpos($_FILES[$key]['name'], '.');
        if ($last_dot_position !== false) {
            $title = substr($_FILES[$key]['name'], 0, $last_dot_position);
        } else {
            $title = $_FILES[$key]['name'];//名称  可以随便传，默认传文件名吧  不带后缀的
        }

    }*/

    $post_data['fddFileUrlList'] = array(
        "fileType" => 'doc',//固定 表示用文件生成合同
        "fileName" => $_FILES[$key]['name'],
        "fddFileUrl" => $fddFileUrl,
    );

    $resp = $ElectronicSignatureObj->fileProcess($post_data);

    if ($resp['code'] == '100000') {
        $fileIdList = $resp['data']['fileIdList'];
        $fileId = $fileIdList[0]['fileId'];

        $arr['fddFileUrl'] = $fddFileUrl;
        $arr['uploadUrl'] = $uploadUrl;
        $arr['fileId'] = $fileId;
        $arr['resp'] = $resp;

        //预填发起方信息
        /*$company_sql = "select organizationname from ld_organizationdetails";
        $company_res = $adb->pquery($company_sql);
        $actorName = $adb->query_result($company_res,0,0);*/
//        $smarty->assign("actorName",$actorName);//发起方具体名称
//        $smarty->assign("creatorName",$current_user->last_name);
//        $smarty->assign("notifyAddress",$current_user->phone_mobile);//接收签署链接的手机号


        $arr['title'] = '创建签署任务';
        $arr['oktext'] = getFixedLabel("SAVE");
        $arr['canceltext'] = getFixedLabel("CANCEL");
        $str = $smarty->fetch("modules/lingdang/fdd/CreateSignTaskHtml.tpl");//创建签署任务(基于文档)
        $arr['content'] = $str;
        ConvertTojsonString(1, $arr, "success");
    }else{
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." fileProcess: request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." fileProcess: req：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, $resp, "创建签署任务失败：文件处理失败");
    }

}
elseif ($operation == 'CreateSignTask') {
    $record = $_REQUEST['record'];
    $fileId = $_REQUEST['fileId'];

    crm_load_class_file("ElectronicSignatureClassFdd", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureClassFdd($frommodule);
    $post_data['initiator'] = array(
        "idType"=>"corp",
        "openId"=>$ElectronicSignatureObj->openCorpId,
    );
    $post_data['signTaskSubject'] = trim($_REQUEST['signTaskSubject']);
    $post_data['autoStart'] = true;//是否自动提交签署任务
    $post_data['autoFinish'] = true;//所有签署方签署完成后，签署任务是否自动结束
//    $post_data['signInOrder'] = true;//签署流程是否有序，默认false无序
    $post_data['transReferenceId'] = ldcrm_json_encode([
        "record"=>$record,
        "module"=>$frommodule
    ]);//业务数据，可以多个，但有长度限制，不超过100字符

    $post_data['docs'] = array(
        array(
            "docId"=>"docId".mt_rand(1, 100000),
            "docName"=>trim($_REQUEST['signTaskSubject']),
            "docFileId"=>$fileId,
        )
    );


    //被签署方信息
    $actorType = trim($_REQUEST['actors']['actorType']);
    if ($actorType == 'corp') {
        $actor = array(
            "actorId"=>"参与方-".trim($_REQUEST['actors']['actorName']),
            "actorType"=>'corp',
            "actorName"=>trim($_REQUEST['actors']['actorName']),
            "permissions"=>["sign"],
            "sendNotification"=>true,
            "notifyType"=>["start"],
            "notifyAddress"=>trim($_REQUEST['signatories']['contact']),
            "serialNo"=>'2',
        );
    }else{
        $actor = array(
            "actorId"=>"参与方-".trim($_REQUEST['actors']['actorName']),//标识而已，不重复即可
            "actorType"=>'person',
            "actorName"=>trim($_REQUEST['actors']['actorName']),//姓名
            "permissions"=>["sign"],
            "sendNotification"=>true,
            "notifyType"=>["start"],
            "notifyAddress"=>trim($_REQUEST['actors']['notifyAddress']),//手机号
            "serialNo"=>'2',
        );
    }

    //两个签署方信息
    $actors = array(
        array(
            "actor"=>array( //发起方信息
                "actorId"=>"参与方-".trim($_REQUEST['actorName']),
                "actorType"=>"corp",
                "actorName"=>trim($_REQUEST['actorName']),
                "permissions"=>["sign"],
                "sendNotification"=>true,
                "notifyType"=>["start","finish"],
                "notifyAddress"=>trim($_REQUEST['notifyAddress']),
                "serialNo"=>'1',
            )
        ),
        array(
            "actor"=>$actor
        ),
    );


    $post_data['actors'] = $actors;//签署方信息
    if (!empty($_REQUEST['expiresTime']))
        $post_data['expiresTime'] = strtotime(date("Y-m-d 23:59:59",strtotime($_REQUEST['expiresTime']))) * 1000;//签署截止日期
    if (!empty($_REQUEST['dueDate']))
        $post_data['dueDate'] = strtotime(date("Y-m-d 23:59:59",strtotime($_REQUEST['dueDate']))) * 1000;//文件到期日期

//   dump($post_data);
    crm_load_class_file("ElectronicSignatureClassFdd", 'electronicsignature');
    $ElectronicSignatureObj = new ElectronicSignatureClassFdd($frommodule);
    $resp = $ElectronicSignatureObj->createSignTask($post_data);//创建签署任务即创建合同

    if ($resp['code'] == '100000') {
        $sql = "update $focus->table_name set sponsorid=? where $focus->table_index = ?";
        $adb->pquery($sql, array($current_user->id, $record));

        $query = 'insert into ld_salesorder_electronicsignet(salesorderid,platform) select ?,? from dual 
        where not exists(select 1 from ld_salesorder_electronicsignet where salesorderid=? and platform=?);';
        $adb->pquery($query,array($record,'fdd',$record,'fdd'));

        ConvertTojsonString(1, $resp, "success");
    }else{
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." createSignTask: request：".json_encode($post_data,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." createSignTask: req：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, $resp, "合同创建失败");
    }

}
elseif($operation == 'ContractViewurl'){
    $query = "select flowid from ld_salesorder_electronicsignet where salesorderid = ? and platform =? ORDER BY id DESC LIMIT 1";
    $result = $adb->pquery($query,array($_REQUEST['record'],'fdd'));
    if ($adb->num_rows($result) > 0) {
        $flowid = $adb->query_result($result,0,'flowid');

        $post_data['signTaskId'] = $flowid;//合同id

        crm_load_class_file("ElectronicSignatureClassFdd", 'electronicsignature');
        $ElectronicSignatureObj = new ElectronicSignatureClassFdd($frommodule);
        $resp = $ElectronicSignatureObj->getPreviewUrl($post_data);


        if ($resp['code'] == '100000') {
            $arr['signTaskPreviewUrl'] = $resp['data']['signTaskPreviewUrl'];
            $arr['resp'] = $resp;
            ConvertTojsonString(1, $arr, $resp['msg']);
        }else{
            ConvertTojsonString(-1, $resp, $resp['msg']);
        }
    }else{
        file_put_contents(globalStatic::$root_directory.'storage/ElectronicSignature/'.date("Ym").'fddapierror.txt',date("Y-m-d H:i:s")." getPreviewUrl: req：".json_encode($resp,JSON_UNESCAPED_UNICODE)."\r\n",FILE_APPEND);
        ConvertTojsonString(-1, [], "系统无此合同，无法预览");
    }

}


