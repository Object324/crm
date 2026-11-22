<?php
//自建应用侧边栏
require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
global $adb;
$_REQUEST['diony'] = 'diony';
crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
$wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();


//二、获取当前外部联系人的客户资料
if (isset($_REQUEST['param']) && $_REQUEST['param'] == 'getRecord') {
    $userid = $_REQUEST['userid']; //WangCan 当前企业微信PC登录用户
    $external_userid = $_REQUEST['external_userid'];
    $result_arr = $wxselfbuilt_obj->get_external_contact($external_userid);

    $contact_list = $result_arr['result']['contact'];
    if (empty($contact_list)) {
        ConvertTojsonString(-2, array(), 'fail'); //异常
    }
    foreach ($contact_list as $value){
        $lastname = $value['name'];//如果外部联系人为微信用户，则返回外部联系人的名称为其微信昵称；如果外部联系人为企业微信用户，则会按照以下优先级顺序返回：此外部联系人或管理员设置的昵称、认证的实名和账号名称。
        $corp_name = $value['corp_name'];
        $corp_full_name = $value['corp_full_name'];
        $type = $value['type'];//外部联系人的类型，1表示该外部联系人是微信用户，2表示该外部联系人是企业微信用户

        $position = isset($value['position'])?$value['position']:"";//职位，为创建联系人的职务字段title  //外部联系人的职位，如果外部企业或用户选择隐藏职位，则不返回，仅当联系人类型是企业微信用户时有此字段
        $mobile = '';
        $remark = '';
        foreach ($value['follow_user'] as $followkey=>$followvalue){
            if($followvalue['userid']==$userid){
                if(!empty($followvalue['remark_mobiles'])){
                    $mobiles = $followvalue['remark_mobiles'];//手机号  可能多个,也可能获取不到（该成员对此客户备注的手机号码，第三方不可获取）
                    $mobile = $mobiles[0];
                }
                $remark = $followvalue['remark'];//备注，为创建联系人的备注字段description

                break;
            }
        }
    }


    //判断外部联系人是否存在
    $result = $adb->pquery("select * from ld_contactdetails where (weixin_external_userid = ? or unionid_external_userid = ?)and deleted = 0 LIMIT 1", array($external_userid,$external_userid));
    $num_rows = $adb->num_rows($result);


    if ($type == '2') {//企业微信用户

        //1、检查是否存在该外部联系人关联的客户   可能存在多个
        $is_exists_account = true;
        if (!empty($corp_full_name)) {
            $external_corp_name = $corp_full_name;
            $account_result = $adb->pquery("select * from ld_account where accountname = ?  order by modifiedtime desc", array($corp_full_name));
            $account_num_rows = $adb->num_rows($account_result);
        }else{
            //如果是未认证企业，则没有企业全称，只有企业简称
            $external_corp_name = $corp_name;
            $account_num_rows = 0;
        }
        if ($account_num_rows <= 0) {
            $account_result = $adb->pquery("select * from ld_account where accountname = ?  order by modifiedtime desc", array($corp_name));
            $account_num_rows = $adb->num_rows($account_result);
            if ($account_num_rows <= 0) {
                $is_exists_account = false;
                $external_corp_name = $corp_name;
            }
        }


        //如果联系人存在,再判断客户是否存在
        if ($num_rows > 0) {
            //需不需要更新联系人名称lastname?
//            $SQL = 'update ld_contactdetails set lastname=? WHERE weixin_external_userid=? and deleted=0';
//            $adb->pquery($SQL, array($lastname, $external_userid));

            //2.1.1、如果客户存在，检查是否存在多个相同的客户名称，如果是多个跳转到客户列表界面，如果是一个检查是否被删除
            if ($is_exists_account) {
                if ($account_num_rows > 1) { //跳转客户列表页面
                    ConvertTojsonString(1, array('external_corp_name'=>$external_corp_name), 'success');
                }else{
                    $deleted = $adb->query_result($account_result, 0, 'deleted');
                    if ($deleted == '0') {
                        $arr['accountid'] = $adb->query_result($result, 0, 'accountid');//联系人关联的客户
                        if (empty($arr['accountid'])) {
                            $arr['accountid'] = $adb->query_result($account_result, 0, 'accountid');
                        }

                        ConvertTojsonString(1, $arr, 'success');
                    }else{//已删除至回收站
                        ConvertTojsonString(-1, array(), '该客户已被删除至回收站中');
                    }
                }


            }else{
                //2.1.2 联系人存在，客户不存在
                $arr['accountid'] = 0;
                $arr['external_corp_name'] = $external_corp_name;
                $arr['contactid'] = $adb->query_result($result, 0, 'contactid');
//                $arr['weixin_external_userid'] = $external_userid;
                $arr['lastname'] = $lastname;

                //跳转到添加客户页面
                ConvertTojsonString(2, $arr, '当前客户不存在CRM系统中，请添加客户到灵当CRM');
            }
        }
        else{

            $arr['contactid'] = 0;
            $arr['weixin_external_userid'] = $external_userid;
            $arr['lastname'] = $lastname;
            $arr['mobile'] = $mobile;
            $arr['title'] = $position;
            $arr['description'] = $remark;

            if (!$is_exists_account) {
                //2.2.1 联系人不存在，客户不存在
                // 不存在CRM系统就新增客户和联系人  (联系人不存在，客户也不存在，就跳转到添加客户界面并携带手机号等，保存之后同时新增客户和首要联系人)
                $arr['accountid'] = 0;
                $arr['external_corp_name'] = $external_corp_name;

                //跳转到添加客户页面
                ConvertTojsonString(2, $arr, '当前客户不存在CRM系统中，请添加客户到灵当CRM');
            }else{
                //2.2.2 联系人不存在，客户存在   //如果存在多个客户，取第一个未被删除的客户id，如果都被删除则新建客户
                $arr['accountid'] = 0;

                for($i = 0; $i < $account_num_rows; $i++) {
                    $deleted = $adb->query_result($account_result, $i, 'deleted');
                    if ($deleted == '0') {
                        $arr['accountid'] = $adb->query_result($account_result, $i, 'accountid');
                        continue;
                    }
                }

                if ($arr['accountid'] == 0) {
                    $arr['external_corp_name'] = $external_corp_name;
                    //跳转到添加客户页面 (存在客户但都被删除)
                    ConvertTojsonString(2, $arr, '当前客户不存在CRM系统中，请添加客户到灵当CRM');
                }else{
                    //跳转添加联系人界面
                    ConvertTojsonString(3, $arr, '当前客户存在CRM系统中，新增联系人');
                }
            }

        }

    }else{
        //微信用户  不存在客户概念，1、联系人存在，跳转到联系人详情页面，2、联系人不存在（提示信息：导入外部联系人）
        if ($num_rows > 0) {
            $arr['contactid'] = $adb->query_result($result, 0, 'contactid');
            ConvertTojsonString(4, $arr, 'success'); //联系人存在
        }else{
            $arr['contactid'] = 0;
            $arr['weixin_external_userid'] = $external_userid;
            $arr['lastname'] = $lastname;
            $arr['mobile'] = $mobile;
            $arr['description'] = $remark;
            ConvertTojsonString(4, $arr, 'success'); //联系人不存在
        }
    }

}


//前端签名相关
$http_html_url = $_REQUEST['url'];//GetCurUrl获取的url为ajax的请求url，和前端发起企业微信接口请求的url(地址栏url)不一致导致签名错误，故从参数传过来
$wxselfbuilt_obj->http_html_url = $http_html_url;

// 调用企业微信接口所需参数
$arr['corpid'] = $wxselfbuilt_obj->corpid;
$arr['signature'] = $wxselfbuilt_obj->getJsApiSignature();//企业签名
$arr['timestamp'] = $wxselfbuilt_obj->timestamp;
$arr['nonceStr'] = $wxselfbuilt_obj->nonceStr;

$arr['agent_signature'] = $wxselfbuilt_obj->getAgentJsApiSignature();//应用签名
$arr['agentid'] = $wxselfbuilt_obj->agentid;

//$arr['url'] = $http_html_url;

//前端版本号
$arr['wx_version'] = $wxselfbuilt_obj->wx_version;
$arr['Accounts'] = getTranstab('Accounts');
$arr['Contacts'] = getTranstab('Contacts');

ConvertTojsonString(1, $arr, 'success');
?>