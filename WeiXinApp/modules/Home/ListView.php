<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $MobileLanguageType;
crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
$focus = new WorkReportControllerWX();

$method = $_REQUEST['method'];
if($_REQUEST['return_module']=='Work') $_REQUEST['return_module']='CooperativeWork';
if($method == 'saveSendLog' || $method == 'savereader'){
    $_REQUEST['WXsendNewsAfterSave'] = 1;
}
if(method_exists($focus,$method)){
    if($method == 'getList'){
        $_REQUEST['weixin_mark'] = 1;
    }
    $entity = $focus->$method();
    if(!is_array($entity))
        $entity=[];
    //@edit:liushuai,2020-12-29,reason:【ID1001225】快速创建增加设置按钮，可设置快速创建显示的模块
    if (isset($_REQUEST['mode'])&&$_REQUEST['mode']=='quick') {
        $quickcreatemodules_all = [];
        foreach ($entity['quicklist'] as $info){
            $quickcreatemodules_all[] = $info['module'];  //快速创建默认全部模块
        }
        global $adb,$current_user;
        $quickcreate_sql = "select quickcreatemodules from ld_users where id=?"; //为空显示全部模块（初始化），为none不显示任何模块(清空)
        $quickcreate_result=$adb->pquery($quickcreate_sql,array($current_user->id));
        if ($adb->num_rows($quickcreate_result) > 0) {
            $tmpquickcreatemodules = trim(trim($adb->query_result($quickcreate_result, 0, 0), ','));
            if ($tmpquickcreatemodules == '') {
                $tmpquickcreatemodules_arr = $quickcreatemodules_all;
            } else if ($tmpquickcreatemodules == 'none') {
                $tmpquickcreatemodules_arr = array();
            } else if ($tmpquickcreatemodules != '' && $tmpquickcreatemodules != 'none') {
                $tmpquickcreatemodules_arr = explode(',', $tmpquickcreatemodules);
            }
        }

        foreach($entity['quicklist'] as $key=>$info){
            $quickmodule = $info['module'];
            if (!in_array($quickmodule, $tmpquickcreatemodules_arr)) {  //当前用户权限范围内 去掉未选择快速创建的模块
                unset($entity['quicklist'][$key]);
            }
        }
        $moduleOrder = array_flip($tmpquickcreatemodules_arr);
        usort($entity['quicklist'], function($a, $b) use ($moduleOrder) {
            return $moduleOrder[$a['module']] <=> $moduleOrder[$b['module']];
        });
    }
    if($method == 'getCRMModules'){
        global $adb;
        $sql = 'SELECT 1 FROM ld_dashboard_app WHERE home_presence="yes" and `name` = "commonmodules" order by home_sequence asc ';
        $result = $adb->pquery($sql);
        if($adb->num_rows($result)>0){
            crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
            $reportobj = new cls_ReportDetailInfoWX(null);
            $commonmodules = $reportobj->getcommonmodules();
            if (isset($_REQUEST['usetype'])&&$_REQUEST['usetype']=='yes') {
                foreach($commonmodules['list'] as $key=>$info){
                    if ($key > 4) {
                        unset($commonmodules['list'][$key]);
                    }
                }
            }
            if($MobileLanguageType == 'en' && $_REQUEST['commonlyused'] != 'yes'){
                $commonmodules['label'] = '';
            }else{
                $commonmodules['label'] = getMobileFixedLabel('COMMON');
            }
            $entity['commonmodules'] = $commonmodules;
        }
    }
    //zxm 20221207 成员基本信息 头像 名字 公司 职位等
    global $current_user;
    //include globalStatic::$root_directory."WeiXinApp/cloudpro/CloudUsers.php";
    //$cloud_user_obj = new CloudUsers();
    crm_load_class_file('UsersUtils','modules/Users');
    $UsersUtilsObj = new UsersUtils();

    $entity['setting']['userinfo'] = $UsersUtilsObj->getCrmUserInfo($current_user->id);
    $entity['setting']['userinfo']['profilename'] = $current_user->getUserOfProfileName();

    ConvertTojsonString(1,$entity,'success');
}

?>