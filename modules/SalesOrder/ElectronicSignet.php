<?php
////ls 2021-09-16 【ID1001956】增加“电子签章”功能(跳转到客户的腾讯电子签后台，首次为激活页面)
//global $adb,$current_user,$currentModule;
//$smarty = new lingdangCRM_Smarty;
//$_REQUEST['diony'] = 'yes';
//$focus = CRMEntity::getInstance($currentModule);
//$electronicSignatureInfo = $focus->getElectronicSignatureInfo();
////dump(getuserInfoByPrivileges($current_user));
//
//$operation = $_REQUEST["operation"];
//if ($operation == 'CreateConsoleLoginUrl') {
//    $post_data["ProxyOrganizationName"] = $electronicSignatureInfo['ProxyOrganizationName'];
//
//    $post_data["Agent"]["ProxyOrganizationOpenId"] = $electronicSignatureInfo['ProxyOrganizationOpenId'];
//    $post_data["Agent"]["ProxyOperator"]["OpenId"] = $electronicSignatureInfo['ProxyOperatorOpenId'];
////    $post_data["Agent"]["ProxyOperator"]["OpenId"] = 'us-liushuai';   //新同步的经办人，认证后需要超管授权
//
//    if ($_REQUEST['type'] == 'PreviewContract') {//预览合同
////        $FlowStatus_Arr = array("INIT"=>"创建","PART"=>"签署中","REJECT"=>"拒签","CANCEL"=>"撤回","DEADLINE"=>"流签","ALL"=>"签署完成","WILLEXPIRE"=>"即将过期","EXCEPTION"=>"异常");//WILLEXPIRE和EXCEPTION是后来新加的
//        $query = "select flowid from ld_salesorder_electronicsignet where salesorderid = ? and flowstatus = '签署完成' ORDER BY id DESC LIMIT 1";//由于有测试数据，故需limit，正常一条单据只有一个签署完成的电子合同
//        $result = $adb->pquery($query,array($_REQUEST['record']));
//        if ($adb->num_rows($result) > 0 ) {//合同状态回调数据
//            $flowid = $adb->query_result($result,0,'flowid');
//
//            $post_data["Module"] = 'document';//要跳转到的模块，目前支持 document:文件/合同管理,template:模版管理,seal:印章管理,operator:组织架构/人员
//            $post_data["ModuleId"] = $flowid;//合同id/预览模版id  注意： 此参数必须和Module一起搭配使用， 否则无效
//        }
//
//    }else{//默认login页面为企业信息，可不传
//        $post_data["Module"] = '';
//    }
//
//
//    crm_load_class_file("ElectronicSignature", 'electronicsignature');
//    $ElectronicSignatureObj = new ElectronicSignature();
//    $data = $ElectronicSignatureObj->CreateConsoleLoginUrl($post_data);
//
//    if (!empty($data['Error'])) {
//        ConvertToJsonString(-1, $data,$data['Error']['Message']);
//    }
//
////    $ConsoleUrl = $data['ConsoleUrl'];//电子签控制台跳转url
//    $IsActivated = $data['IsActivated'];//渠道合作企业是否认证开通腾讯电子签 true
//    $IsActivated = $IsActivated === true ? 'yes' : 'no';
//
//    $query = "update ld_wx_config set para_one = ? where name = ? and ifnull(para_one,'') <> 'yes'";//首次激活时
//    $adb->pquery($query, array($IsActivated,'electronic_signature'));
//    ConvertToJsonString(1, $data,'success');
//} elseif ($operation == 'DescribeTemplates') {
//    if ($electronicSignatureInfo["remain_count"] < 1) {//如果是购买使用份数，需判断；如果是出月度使用账单，则不用计算使用份数。
//        ConvertTojsonString(-1, array(), "合同套餐包已用尽");
//    }
//    //如果启用审批，判断单据是否审批成功
//    $focus = CRMEntity::getInstance($currentModule);
//    $focus->retrieve_entity_info($_REQUEST['record'], $currentModule);
//    if ($focus->column_fields['approvestatus'] != '已批准') {
//        ConvertTojsonString(-1, array(), getFixedLabel('NotApprovedNotSigned'));
//    }
//
//    //第一步：查询模板信息列表
//    $post_data["Agent"]["ProxyAppId"] = $electronicSignatureInfo['ProxyAppId'];
//    $post_data["Agent"]["ProxyOrganizationOpenId"] = $electronicSignatureInfo['ProxyOrganizationOpenId'];
//    $post_data["Agent"]["ProxyOperator"]["OpenId"] = $electronicSignatureInfo['ProxyOperatorOpenId'];
//
//    crm_load_class_file("ElectronicSignature", 'electronicsignature');
//    $ElectronicSignatureObj = new ElectronicSignature();
//    $data = $ElectronicSignatureObj->DescribeTemplates($post_data);
//
//    if (!empty($data['Error'])) {
//        ConvertToJsonString(-1, $data,$data['Error']['Message']);
//    }
//    if (isset($_SESSION['ElectronicSignature']['DescribeTemplates'])) {
//        unset($_SESSION['ElectronicSignature']['DescribeTemplates']);
//    }
//    //将模板列表信息存入session
//    $Templates = $data['Templates'];
//    foreach ($Templates as $template) {
//        $TemplateId = $template['TemplateId'];
//        $TemplateName = $template['TemplateName'];
//        $Description = $template['Description'];//模板描述信息
//        $TemplateType = $template['TemplateType'];//模板类型：1-静默签；2-静默签授权；3-普通模版
//        $Recipients = $template['Recipients'];//模板中的流程参与人信息  可以为空
//
//        //控件相关
//        $_SESSION['ElectronicSignature']['DescribeTemplates'][$TemplateId] = $template;
//
//        $templateList[] = [
//            "TemplateId"=>$TemplateId,
//            "TemplateName"=>$TemplateName,
//            "TemplateJsonData"=>ldcrm_json_encode($template),//模板相关数据
//        ];
//        $smarty->assign("TemplateList",$templateList);
//    }
//
//    $smarty->assign("RECORD",$_REQUEST['record']);
//    $arr['title'] = '选择合同模板';
//    $arr['oktext'] = getFixedLabel("SAVE");
//    $arr['canceltext'] = getFixedLabel("CANCEL");
//    $str = $smarty->fetch("modules/SalesOrder/DescribeTemplates.tpl");
//    $arr['content'] = $str;
//
//    $arr['data'] = $data;
//    $arr['templateList'] = $templateList;
//    ConvertTojsonString(1, $arr, "success");
//
//} elseif ($operation == 'FlowTemplateHtml') {
//    //第二步其一：分两步，先生成页面，填写控件数值，再创建合同
//    $TemplateId = $_REQUEST['templateid'];
//    $record = $_REQUEST['record'];
//    $modulename = getSalesEntityType($record);
//    $template = $_SESSION['ElectronicSignature']['DescribeTemplates'][$TemplateId];
////    TemplateType  模板类型：1-静默签；2-静默签授权；3-普通模版
////    Recipients     SignType签署类型：0 需要签署 1 不需要签署（为静默签时，个人需要签署，企业不需要签署；  为普通模板时，个人和企业都需要签署）
////                   RecipientType签署方类型：ENTERPRISE-企业INDIVIDUAL-自然人     对应  ApproverType  签署人类型，ORGANIZATION和PERSON
//
//    if (empty($TemplateId) || empty($template)) {
//        ConvertToJsonString(-1, array(),'异常情况，请检查session设置后重试');//服务器session开启了就没事
//    }
////    dump($_SESSION['ElectronicSignature']['DescribeTemplates'][$TemplateId]);
//
//    //组装控件表单
//    $Components = $template["Components"];
//    //获取控件name及系统控件的值
//    crm_load_class_file('AutoRemindContent', 'include/VarGeneralBol');
//    require_once(globalStatic::$root_directory.'electronicsignature/middleware.php');
//    foreach ($Components as &$value){
//        $ComponentName = $value["ComponentName"];//控件简称（英文名称），电子签返回值
//        $ComponentDescription = $value["ComponentDescription"];//控件中文名称
//        if (!empty($parse_arr[$ComponentName])) {
//            $parse_content = $parse_arr[$ComponentName];
//
//            $parse_obj = new AutoRemindContent($modulename, $record);
//            $content = $parse_obj->getContent($parse_content);//解析，将[var.salesorder_account_id_SalesOrder]解析成对应的值（主表字段）
//            if (strpos($content, ']') > 0) {//解析不了的
//                //参考ApproveRemind.php的sendMessageByDingDing()方法，再解析一遍,后面可以优化后删除if循环体的代码
//                include_once(globalStatic::$root_directory . 'include/VarGeneralBol/CommonVarSql.php');
//                $templateprintsql = new CommonVarSql($modulename, $record);
//                $content_sql = $templateprintsql->CreateSql($parse_content);//解析模板内容后最终生成的sql
//                $content_sql_result = $adb->pquery($content_sql, array());
//                if ($adb->num_rows($content_sql_result) > 0) {
//                    if (strpos(strtolower($content), 'total_big_table') > 0) {
//                        $content = $adb->Query_result($content_sql_result, 0, 'total_table');//获取打印列值
//                        $content = ConvertTotalToUpper($content);
//                    }
//                }
//
//                if (strpos($content, ']') > 0) {//解析不了的
//                    $value["ComponentNameLabel"] = $ComponentDescription;
//                    $value["ComponentNameValue"] = '';
//                    continue;
//                }
//            }
//
//            //开始处理[var.salesorder_account_id_SalesOrder]，取值
//            $printcols = preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/", $parse_content);
//            $printcols = explode('[var.', $parse_content);
//
//            $fieldname = $fieldlabel = "";
//            if (strpos($printcols[1], ']') > 0)//找到需要打印的列
//            {
//                $endcol = strpos($printcols[1], ']');
//                $colsinfo = substr($printcols[1], 0, $endcol);
//                $tabcols = explode('_', $colsinfo);
//                for ($fi = 1; $fi < count($tabcols) - 1; $fi++) {
//                    if ($fi != (count($tabcols) - 2))
//                        $fieldname .= $tabcols[$fi] . '_';
//                    else
//                        $fieldname .= $tabcols[$fi];
//                }
////                $curtabname = $tabcols[count($tabcols) - 1];//当前打印字段所在模块
//
//                $query = "select tabid from ld_field where ld_field.fieldname=? and ld_field.tablename=? limit 1";
//                $result = $adb->pquery($query, array($fieldname, 'ld_' . $tabcols[0]));
//                $tabid = $adb->query_result($result, 0, 'tabid');
//
//                $fieldsql = 'select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_field.fieldid = ld_tranlabel.Relateid where ld_field.fieldname=? and ld_field.tablename=? and ld_tranlabel.tabid=? and ld_tranlabel.languagetype=? ';
//                $result = $adb->pquery($fieldsql, array($fieldname, 'ld_' . $tabcols[0], $tabid, getLanguageType($current_user)));
//                if ($adb->num_rows($result) > 0) {
//                    $fieldlabel = $adb->query_result($result, 0, 'fieldlabel');
//                }
//
//            }
//
//            $value["ComponentNameLabel"] = empty($fieldlabel)?$ComponentDescription:$fieldlabel;//自定义参数 表单label（控件中文名称）
//            $value["ComponentNameValue"] = $content;//自定义参数 表单值（从CRM系统取值）
//        }else{//为了代码健壮性而写
//            $value["ComponentNameLabel"] = $ComponentName;
//            $value["ComponentNameValue"] = '';
//        }
//
//    }
//
//    $smarty->assign("Components",$Components);
//
//    $smarty->assign("RECORD",$record);
//    $smarty->assign("TemplateId",$TemplateId);
////    $smarty->display("modules/SalesOrder/CreateFlowsByTemplates.tpl");
////    exit;
//
//    $arr['title'] = '创建合同';
//    $arr['oktext'] = getFixedLabel("SAVE");
//    $arr['canceltext'] = getFixedLabel("CANCEL");
//    $str = $smarty->fetch("modules/SalesOrder/CreateFlowsByTemplates.tpl");
//    $arr['content'] = $str;
//
//    $arr['templateDetail'] = $_SESSION['ElectronicSignature']['DescribeTemplates'][$TemplateId];//返回值仅供查看
//    $arr['Components'] = $Components;//返回值仅供查看 解析后的控件取值
//    ConvertTojsonString(1, $arr, "success");
//
//} elseif ($operation == 'CreateFlowsByTemplates') {
//    //第二步其二：分两步，先生成页面，填写控件数值，再创建合同
////    var_dump($_REQUEST);
////    dump($_REQUEST['Components']);
//    $record = $_REQUEST['record'];
//
//    //创建合同
//    $post_data["Agent"]["ProxyAppId"] = $electronicSignatureInfo['ProxyAppId'];
//    $post_data["Agent"]["ProxyOrganizationOpenId"] = $electronicSignatureInfo['ProxyOrganizationOpenId'];
//    $post_data["Agent"]["ProxyOperator"]["OpenId"] = $electronicSignatureInfo['ProxyOperatorOpenId'];
//    $post_data["NeedPreview"] = false;//新增参数：是否为预览模式；默认为false，即非预览模式，此时发起合同并返回FlowIds；若为预览模式，则返回PreviewUrls；
//
//    $FlowName = trim($_REQUEST['FlowName']);
//    $TemplateId = $_REQUEST['TemplateId'];
//    $FlowDescription = trim($_REQUEST['FlowDescription']);
//    $FlowType = $_REQUEST['FlowType']?$_REQUEST['FlowType']:'其他';
//    $Deadline = strtotime($_REQUEST['Deadline']);
//    $CallbackUrl = getServerRootAddress().'electronicsignature/crmcallback.php';//腾讯电子签合同状态回调地址  http://localhost:85/ldcrm/electronicsignature/crmcallback.php
//
//    //合同基本信息    //第三步需要用到这些变量(不含CallbackUrl)
//    $FlowInfo = [
//        "FlowName"=>$FlowName,
//        "TemplateId"=>$TemplateId,
//        "FlowDescription"=>$FlowDescription,
//        "FlowType"=>$FlowType,
//        "Deadline"=>$Deadline,
//        "CallbackUrl"=>$CallbackUrl,
//        "CustomerData"=>ldcrm_json_encode(["record"=>$record]),
//    ];
//
//    /*if (!empty($_REQUEST['FlowDescription'])) {
//        $FlowInfo = array_merge($FlowInfo,array("FlowDescription"=>$FlowDescription));
//    }
//    if (!empty($FlowType)) {
//        $FlowInfo = array_merge($FlowInfo,array("FlowType"=>$FlowType));
//    }*/
//
//    //控件表单域的值
//    $FormFields = [];
//    if (isset($_REQUEST['Components']) && !empty($_REQUEST['Components'])) {
//        foreach ($_REQUEST['Components'] as $key=>$val) {
//            if(empty($val)) continue;//非必填控件跳过
//            $FormFields[] = [
//                "ComponentName"=>$key,
//                "ComponentValue"=>$val,
//            ];
//        }
//    }
//
//
//    //合同签署人的信息  为静默签时，个人需要签署，企业不需要签署，只需要填写个人信息；  为普通模板时，个人和企业都需要签署，企业信息暂且默认为当前企业经办人的信息
//    //Recipient.SignType 为 0 时，需要签署；Recipient.RecipientType == 'INDIVIDUAL' 个人签署，== 'ENTERPRISE' 企业签署
//    //RecipientId：流程签署人在模板中对应的签署人Id；在非单方签署、以及非B2C签署的场景下必传，用于指定当前签署方在流程中的位置；
//    //NotChannelOrganization：指定签署人非渠道企业下员工，在ApproverType为ORGANIZATION时指定。默认为false，即签署人位于同一个渠道应用号下；
//    $template = $_SESSION['ElectronicSignature']['DescribeTemplates'][$TemplateId];
//    $Recipients = $template["Recipients"];
//    foreach ($Recipients as $tmp_recipient){
//        $FlowApprover = [];
//        if ($tmp_recipient['SignType'] == 1){ //静默签 企业方不用经办人签署
//            continue;
//        }else{
//            if ($tmp_recipient['RecipientType'] == 'INDIVIDUAL') {//个人签署方
//                $FlowApprover['RecipientId'] = $tmp_recipient['RecipientId'];
//                $FlowApprover['ApproverType'] = 'PERSON';
//                $FlowApprover['Name'] = $_REQUEST['FlowApprovers']['Name'];
//                $FlowApprover['Mobile'] = $_REQUEST['FlowApprovers']['Mobile'];
//                if (!empty($_REQUEST['FlowApprovers']['Deadline'])) {
//                    $FlowApprover['Deadline'] = strtotime($_REQUEST['FlowApprovers']['Deadline']);//该截止时间，实际上（截止2021/09/30）腾讯电子签未作处理
//                }
//
//            } elseif ($tmp_recipient['RecipientType'] == 'ENTERPRISE') {//企业签署方
//                $query = "select last_name,real_name,phone_mobile,proxyoperatoropenid from ld_users where id = ?";
//                $result = $adb->pquery($query,array($current_user->id));//当前登录用户为企业经办人
//                require_once globalStatic::$root_directory.'appCommon/appCommon.php';
//                if (isKehu001ServerPc() == 'yes') {
//                    $last_name = $adb->query_result($result,0,'real_name');
//                }else{
//                    $last_name = $adb->query_result($result,0,'last_name');//负责人姓名
//                }
//
//                $FlowApprover['RecipientId'] = $tmp_recipient['RecipientId'];
//                $FlowApprover['ApproverType'] = 'ORGANIZATION';
//                $FlowApprover['NotChannelOrganization'] = false;//TODO...B2B
//                $FlowApprover['Name'] = $last_name;
//                $FlowApprover['Mobile'] = $adb->query_result($result,0,'phone_mobile');
//                $FlowApprover['OpenId'] = $adb->query_result($result,0,'proxyoperatoropenid');
////                $FlowApprover['Name'] = "刘帅";
////                $FlowApprover['Mobile'] = '18037456408';
////                $FlowApprover['OpenId'] = 'us-liushuai';
//
//                $FlowApprover['Deadline'] = $Deadline;//取合同截止时间算了
//
//            }
//        }
//
//        $FlowApprovers[] = $FlowApprover;
//
//    }
//
//
//    /*$FlowApprover = [
//        "Name"=>$_REQUEST['FlowApprovers']['Name'],
//        "Mobile"=>$_REQUEST['FlowApprovers']['Mobile'],
//    ];
//    if (!empty($_REQUEST['FlowApprovers']['Deadline'])) {
//        $FlowApprover = array_merge($FlowApprover,array("Deadline"=>strtotime($_REQUEST['FlowApprovers']['Deadline'])));
//    }
//    $FlowApprovers[] = $FlowApprover;*/
//
//    $FlowInfo["FormFields"] = $FormFields;
//    $FlowInfo["FlowApprovers"] = $FlowApprovers;
//
//    //合同信息
//    $post_data["FlowInfos"][] = $FlowInfo;
//
//    // TODO 说明：如果要直接发起，使用CreateflowbyTemplates得到flowids，然后使用flowids去创建签署链接；prepareFlows批量发起是需要手动确认的，目前该接口只支持B2C。两者是独立的。
//   /* //第三步：准备待发起文件
//    $post_data['JumpUrl'] = getServerRootAddress().'index.php?pageto_module=SalesOrder&pageto_action=index';//确认合同后跳转地址
//    crm_load_class_file("ElectronicSignature", 'electronicsignature');
//    $ElectronicSignatureObj = new ElectronicSignature();
//    $data = $ElectronicSignatureObj->PrepareFlows($post_data);//走到这儿，说明合同已经创建成功，如果第三步确认文件出错，应该给与错误提示原因，根据原因处理之后再重新创建*/
//
//    //B2C接口升级，兼容B2B
//    crm_load_class_file("ElectronicSignature", 'electronicsignature');
//    $ElectronicSignatureObj = new ElectronicSignature();
//    $data = $ElectronicSignatureObj->CreateFlowsByTemplates($post_data);
//
//    if (!empty($data['ErrorMessages'][0])) {
//        ConvertToJsonString(-1, $data,$data['ErrorMessages'][0]);
//    }
//
//    //合同发起人
//    $sql = 'update ld_salesorder set sponsorid = ? where salesorderid = ?';
//    $adb->pquery($sql, array($current_user->id, $record));
//
////    $arr['ConfirmUrl'] = $data['ConfirmUrl'];
//    ConvertTojsonString(1, $data, "success");
//}
//
//
////@return  根目录地址  http://localhost:85/ldcrm/
//function getServerRootAddress(){
////    获取当前网址协议(HTTP/HTTPS)
//    if(isset($_SERVER["HTTP_X_CLIENT_SCHEME"])){
//        $scheme = $_SERVER["HTTP_X_CLIENT_SCHEME"] . "://";
//    }elseif(isset($_SERVER["REQUEST_SCHEME"])){
//        $scheme = $_SERVER["REQUEST_SCHEME"] . "://";
//    }else{
//        $scheme = "http://";
//    }
//
//    $host = isset($_SERVER['HTTP_X_FORWARDED_HOST']) ? $_SERVER['HTTP_X_FORWARDED_HOST'] : (isset($_SERVER['HTTP_HOST']) ? $_SERVER['HTTP_HOST'] : '');
//    $suffix = dirname($_SERVER['PHP_SELF']); //  /ldcrm/index.php     /ldcrm
//    return $scheme.$host.$suffix.'/';
//}
//
//function getPrintColumnInfo($str)
//{
//    $result = array();
//    preg_match_all("/(?:\[)(.*)(?:\])/i",$str, $result);
//    return $result;
//}
//
///**
// * edit:can
// * date:20130821
// * reason:金额转换为大写
// * */
//function ConvertTotalToUpper($data)
//{
//    global $adb;
//
//    //crm_load_class_file('cls_Money_Upper','include/TemplatePrint');
//    crm_load_class_file('cls_Money_ToUpper','include/TemplatePrint');
//    // $obj=new cls_Money_ToUpper();
//    if(empty($data)){
//        $data=0.00;
//    }
//    if($data<0)
//    {
//        $data=0-$data;
//        $sql='select func_changeToCapitalRMB('.$data.') as uppermoney ';
//        $result=$adb->pquery($sql,array());
//
//        return "负".$adb->query_result($result,0,'uppermoney');
//    }
//    else
//    {
//        $sql='select func_changeToCapitalRMB('.$data.') as uppermoney ';
//
//        $result=$adb->pquery($sql,array());
//
//        return $adb->query_result($result,0,'uppermoney');
//
//    }
//}