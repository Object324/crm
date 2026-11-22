<?php

class cls_StaticCommonFun
{
    //判断单据是否有反审批按钮权限
    static function jsongetCancelApprove($module, $focus)
    {
        global $currentModule;
        $currentModule = $module;
        $approve_focus = Approve::getInstance($module);
        $approveinfo = $approve_focus->approveStatus($focus->id);
        $iscancel = 0;
        //不等于未审批
        $blockbuttons = $approve_focus->blocksButton($focus->column_fields['assigned_user_id'], $focus->id);
        $iscancel = $approve_focus->getCancelApprovedBtn($module, $focus->id, $focus->column_fields, $blockbuttons);
        //}
        return $iscancel;
    }
    //20171127
    static function initUserPrivileges($userid){
        global $current_user;
        $current_user = new Users();
        //$current_user->retrieve_entity_info($userid, 'Users');//默认当前登录用户为管理员；
        //登录微信自动生成相应登录文件
        $afile = fopen(globalStatic::$root_directory . "user_privileges/user_language_" . $userid . ".php", "w");
        $txt = "<?php \$languageType='zh'; ?>";
        fwrite($afile, $txt);
        fclose($afile);
        //self::cacheCorpDetail();
        if(!file_exists(globalStatic::$root_directory.'user_privileges/user_privileges_'.$userid.'.php'))
        {
            require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
            createUserPrivilegesfile($userid);
        }
        //require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
        //createUserPrivilegesfile($userid);
        //初始化用户权限
        $current_user->retrieveCurrentUserInfoFromFile($userid);
        if(empty($current_user->id)){
            require_once(globalStatic::$root_directory . 'modules/Users/CreateUserPrivilegeFile.php');
            createUserPrivilegesfile($userid);
            $current_user->retrieveCurrentUserInfoFromFile($userid);
        }
    }

    // 微信主入口文件index.php初始化$current_user并自动生成登入文件
    static function indexView($userid, $module)
    {
        global  $currentModule, $app_currency_strings,$current_user;
        self::initUserPrivileges($userid);
        /*if($module!='Home' || ($module=='Home'&&isset($_REQUEST['method'])&&$_REQUEST['method']=='getWorkHome')){
        }elseif($module=='Home'){
            $modulepermit = 'yes';
        }*/
        // @edit:dong @date:2020/07/28 @reason: 表单推广 相关信息 添加到这否则验证不通过
        if($module=='Home'&&$_REQUEST['method']!='getWorkHome'||$module=='Upload'||$module == 'Singin' || $module == 'Users' || $module == 'SharedUsers' || $module == 'Dashboard' || $module=='SocialPromotionForm'){
            $modulepermit = 'yes';
        }else{
            if (vtlib_isModuleActive($module)) {
                $modulepermit = isPermitted($module,'index',"");
                if($modulepermit == 'no'){
                    //duan 20230221 用户在没有模块权限的情况下可以有单据的查看详情权限（作为审批人）
                    if($_REQUEST['action']=='DetailView' && $_REQUEST['record']!=''){
                        $modulepermit = isPermitted($module,'DetailView',$_REQUEST['record']);
                    }
                }
                
                if ($modulepermit != 'yes') {
                    $msg = '您绑定的CRM用户没有该模块权限';
                }
            } else {
                $msg = '您绑定的CRM系统没有开启该模块';
                if($module=='Home') $msg = '您绑定的CRM系统没有开启首页模块';
            }
        }
     
        if ($modulepermit == 'yes') {
            //editor:gyq_20190822 reason:企业微信端不再触发提醒
            //self::SendWXNews();
            $app_currency_strings = self::return_apps_currency_strings_language('zh');
            //include(globalStatic::$root_directory . 'include/utils/UserInfoUtil.php');/*gyq_23*/
            //editor:gyqX170619 	0028713: 需求讨论：建议手机端或者微信端登录的时候可以触发公海自动回收、自动提醒、自动任务等功能
          
            include(globalStatic::$root_directory . 'WeiXinApp/modules/' . $module . '/index.php');

        } else {
            ConvertTojsonString(-1, null, $msg);
        }
    }
    //20171129 触发微信提醒
    static function SendWXNews(){
        //进入首页界面不发送提醒，尽量减少首页的请求操作 2017-12-12 xxs
        if($_REQUEST['module']=='Home'&&$_REQUEST['method']=='getCRMModules') return false;
        //gyq_23 提醒优化
        /* $userid = 10;
        f_sockopen('WeiXinApp.modules.Reminds.SendRemindsWX','userid='.$userid);//gyq_50 异步发送消息提醒*/
        // execDaysQuery();
        $install_app = judgeCorpInfo('install_app');
        if($install_app){
            crm_load_class_file('cls_remindsWX', 'WeiXinApp/modules/Reminds');
            $remind = new cls_remindsWX();
            $remindarr = $remind->time_interval();
            if(!empty($remindarr)){
                $data['news'] = json_encode($remindarr,JSON_UNESCAPED_UNICODE);
                $remind->newsport->push_news(StaticConst::$server_remindapi,$data);
            }
        }
    }

    static function return_apps_currency_strings_language($language)
    {
        global $app_currency_strings, $default_language, $translation_string_prefix, $current_user;
        $temp_app_currency_strings = $app_currency_strings;
        $language = 'zh_cn';
        @include(globalStatic::$root_directory . "include/language/$language.lang.php");
        if (!isset($app_currency_strings)) {
            require(globalStatic::$root_directory . "include/language/$language.lang.php");
            $language_used = $default_language;
        }
        if (!isset($app_currency_strings)) {
            return null;
        }
        $return_value = $app_currency_strings;
        // Restore the value back
        $app_currency_strings = $temp_app_currency_strings;
        //$log->debug("Exiting return_app_currency_strings_language method ...");
        return $return_value;
    }

    //文件保存用户企业号id信息主键
    static function cacheCorpDetail()
    {
        /*$corpindex = file_get_contents(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/weixinapp_corpindex.php');
        if (!empty($_REQUEST['corpindex']) && $corpindex != -5) {
            file_put_contents(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/weixinapp_corpindex.php', $_REQUEST['corpindex']);
        }*/
        $corpindex = file_get_contents(globalStatic::$root_directory . 'dataCache/weixin/weixinapp_corpindex.php');
        if (!empty($_REQUEST['corpindex']) && $corpindex != -5) {
            $cache_arr['corpindex'] = $_REQUEST['corpindex'];
            $cache_arr['corpurl'] = $_REQUEST['corpurl'];
            $cache_arr['updatetime'] = date('Y-m-d H:i:s',time());
            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/corpinfo.txt', json_encode($cache_arr));
            //暂保留weixinapp_corpindex,下版本删除 gyqTE
            file_put_contents(globalStatic::$root_directory . 'dataCache/weixin/weixinapp_corpindex.php', $_REQUEST['corpindex']);
        }
    }

    static function vtlib_moduleAlwaysActives()
    {
        $modules = Array(
            'Administration', 'CustomView', 'Settings', 'Users', 'Migration',
            'Utilities', 'uploads', 'Import', 'System', 'com_lingdang_workflow', 'PickList',
            'Ondemand', 'Approve', 'XlsImport'
        );
        return $modules;
    }

    //快速创建
    static function jsonQuickCreate($module)
    {
        global $adb, $current_user;
        $fieldobj = Field::getInstance($module, $adb);
        $qcreate_array = $fieldobj->QuickCreate();
        $moduleFields = $fieldobj->getModuleFields();
        $blockinfos['blocklabel'] = "基本信息";
        crm_load_class_file("cls_EditViewOutPutWX", 'WeiXinApp/detail');
        $obj_cls = new cls_EditViewOutPutWX();
        $field_num = 0;
        if(empty($qcreate_array['data'])) return '';
        foreach ($qcreate_array['data'] as $fieldname => $fields_info) {
            $fieldinfo = $moduleFields[$fieldname];
            if (!empty($fieldinfo)) {
                $uitype = $fieldinfo->getUIType();
                $maxlength = $fieldinfo->getMaximumLength();
                $generatedtype = $fieldinfo->getGeneratedtype();
                $typeofdata = $fieldinfo->getTypeOfData();
                $defaultvalue = $fieldinfo->getDefaultValue();
                $fieldonly = $fieldinfo->getfieldOnly();
                foreach ($fields_info as $fieldlabel => $typeofdata) {
                    $custfld = $obj_cls->getEditViewOutputHtml($fieldinfo, $maxlength, $qcreate_array['col_fields'], $generatedtype, $module, '', $typeofdata, $fieldonly, '');
                    if (!empty($_REQUEST['tempSourceField'])) {
                        $blockinfos['fieldinfo'][] = $_REQUEST['tempSourceField'];
                        unset($_REQUEST['tempSourceField']);
                    }
                    $blockinfos['fieldinfo'][] = $custfld;
                }
            }
        }
        return $blockinfos;

    }

    // 获取下拉框值，如城市联动信息
    static function getSourceTargetValues($module, $sourceField, $targetField, $sourceValue = '')
    {
        global $adb;
      
        if (!empty($module)) {
            crm_load_class_file('lingdang_DependencyPicklist', 'modules/PickList');
            $targetValues = lingdang_DependencyPicklist::getPickListDependency($module, $sourceField, $targetField);
            if (!empty($targetValues)) {
                if (empty($sourceValue)) {
                    $fieldobj = Field::getInstance($module, $adb);
                    $moduleFields = $fieldobj->getModuleFields();
                    $field = $moduleFields[$sourceField];
                    if(empty($field)) return '';
                    $defaultValue = $field->getDefaultvalue();
                } else {
                    $defaultValue = $sourceValue;
                }
               
                //editor:gyq_20191029 reason:将等于改为stripos
                //0038381: 创建客户，PC端级联字段是可以的，但是企业微信端(北京)不可以 北京选择不行其他没发现
                $defaultValue=(string)$defaultValue;

                foreach ($targetValues['valuemapping'] as $targetVal) {
                    //edit:can 2020-12-01 43516: （移动端企业微信-kfbcrm）客户-新建；新建客户时，选择省份为“重庆市”，城市“县”；但在选择区域时出现了“定州市”和“辛集市”，不属于重庆下级区的
                    if (stripos($targetVal['sourcevalue'],$defaultValue) !== false&&$defaultValue==$targetVal['sourcevalue'] ) {
                        $targetvalues = $targetVal['targetvalues'];
                        break;
                    }
                }
                foreach ($targetvalues as $val) {
                    if(($sourceField=='bill_state'||$sourceField=='bill_city')&&$val=='--无--') continue;
                    $tagetVal[$val] = $val;
                }
                return $tagetVal;
            }
            return '';
        }
    }

    //gyq_22
    static function VT_getJsonSimpleNavigationValues($page, $module, $noofrows)
    {
        global $mobile_pagerecordcount;
        $startpagenum = 0;
        $haveprevpage = 'yes';
        $havenextpage = 'yes';
        $totalpagecount = ceil($noofrows / $mobile_pagerecordcount);
        if ($totalpagecount * $mobile_pagerecordcount < $noofrows) {
            $totalpagecount += 1;
        }
        if (!isset($_REQUEST['page'])) {
            $page = $_REQUEST['page'] = 1;
        } else {
            $page = ++$_REQUEST['page'];
        }
        $startpagenum = $page - 1;
        if ($page >= $totalpagecount) {//是否有下一页
            $havenextpage = 'no';
            $startpagenum = $totalpagecount - 1;
        }
        if ($page <= 1) {//是否有上一页
            $haveprevpage = 'no';
            $startpagenum = 0;
        }
        $navigation = array(
            'startpagenum' => $startpagenum,
            'haveprevpage' => $haveprevpage,
            'havenextpage' => $havenextpage,
            'totalpagecount' => $totalpagecount
        );
        return $navigation;
    }

    /* 呼出手动录入号码规范匹配 */
    public static function checkPhone($tel)
    {
        $isMob = "/^1[3-5,8]{1}[0-9]{9}$/";
        $isTel = "/^([0-9]{3,4})?[0-9]{7,8}$/";

        if (preg_match($isMob, $tel) || preg_match($isTel, $tel)) {
            return $tel;
        }else{
            return '';
        }
    }
    //微信端可见模块列表
    public static function validmodule($output_type='weixin'){
        global $adb;
        $mobilemodule = array();
        //editor:gyq_20190725 reason:清除$this->output_type  2019/7/25 10:03
        if($output_type=='app'){
            $type = 'mobile';
        }else{
            $type = 'weixin';
        }
        $query = 'SELECT DISTINCT(name) from ld_tab WHERE mobilepresence LIKE \'%'.$type.'%\' and presence = 0 ';
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        for($i = 0; $i < $num_rows; $i++){
            $modulename = $adb->query_result($result,$i,'name');
            if(isPermitted($modulename)=='yes'&&vtlib_isModuleActive($modulename)){
                $mobilemodule[] =$modulename;
            }
        }
        return $mobilemodule;
    }
    //判断请求平台
    public static function check_source(){
        $useragent  = strtolower($_SERVER["HTTP_USER_AGENT"]);
        // iphone
        // 微信
        $is_weixin  = strripos($useragent,'micromessenger');
        if($is_weixin){
            return 'weixin';
        }
        // pc电脑
        $is_pc = strripos($useragent,'windows nt');
        if($is_pc){
            return 'pc';
        }
        $is_iphone  = strripos($useragent,'iphone');
        if($is_iphone){
            return 'iphone';
        }
        // android
        $is_android    = strripos($useragent,'android');
        if($is_android){
            return 'android';
        }
        // ipad
        $is_ipad    = strripos($useragent,'ipad');
        if($is_ipad){
            return 'ipad';
        }
        // ipod
        $is_ipod    = strripos($useragent,'ipod');
        if($is_ipod){
            return 'ipod';
        }
        return 'other';
    }
    //微信多版本
    public static function websaas_multi_version($return_type=""){
        global $adb;
        //editor:gyq_201901080036027: 企业微信-设置-当前版本，其中的版本号信息应该读取lingdangversion.php
        //editor:gyq_20190606 reason:企业微信消息提醒，版本号错误读取了PC端的版本号 0037264
        //include globalStatic::$root_directory.'lingdangversion.php';
        /*if(!empty($lingdang_current_version)){
            $wx_version_url = $lingdang_current_version.'/';
        }else{*/
        //include/utils/CacheInfo.php中，
        crm_load_class_file('cls_WeixinPort','WeiXinApp/WeiXin_common');
        $sql = 'SELECT wx_version from ld_version LIMIT 1';
        $result = $adb->pquery($sql, array());
        $rows = $adb->num_rows($result);
        //默认版本为V2
        if($rows==1){
            $wx_version = $adb->query_result($result,0,'wx_version');
        }else{
            $wx_version = 'V2';
        }
        if($wx_version)
            $wx_version_url = $wx_version.'/';
        else{
            //editor:gyq170807 gyq_41
            //$wx_version = 'V2';
            $wx_version_url = 'V2/';
        }
      //  }
        if($return_type=='data'){
            return $wx_version_url;
        }else{
            $json_obj = array(
                'code' => 1,
                'result' => array($wx_version_url),
                'msg' => 'redirect'
            );
            $str = json_encode($json_obj);
            @ob_clean();
            @ob_start();
            @header('Content-type: text/html;charset=utf-8');
            echo $str;
            exit();
        }
        /*$userid = $versionArr[3];
       $corpurl = urldecode($versionArr[2]);
       $corpindex = $versionArr[4];
       $location = urldecode($versionArr[1]);
       $modulename = $versionArr[5];

       $OArray = array('NormalApprove','AddJobBill','MinusJobBill','BusinessApply','LoanApply','CardApply');
       if(in_array($modulename,$OArray)){
           $location = 'crm/index.html#!/home';
       }
       $true_url = "http://" . $saas_server . "/websaas/weixinsaas/" .
           $location . "?userid=$userid&corpurl=$corpurl&corpindex=$corpindex&module_index=$modulename";*/

        /*$OASql = 'SELECT ld_tab.name
                FROM ld_tab
                  LEFT JOIN ld_appparenttabrel REL ON ld_tab.tabid = REL.tabid
                  LEFT JOIN ld_appparenttab ON REL.blockid = ld_appparenttab.blockid
                WHERE ld_appparenttab.parenttab_label = \'OAForms\'';
        $OAresult = $adb->pquery($OASql, array());
        $OArows = $adb->num_rows($OAresult);
        if($OArows>0){
            for($i = 0; $i < $num_rows; $i++){
                $OArray[$i] = $adb->query_result($result,$i,'name');
            }
        }*/
    }
    //获取明细头部字段信息
    static public function getMainInfoField($module){
        global $adb;
        $tabid = getTabid($module);
        $sql = 'select fieldname,showtag from ld_fieldwxmaininfo where tabid=? and presence=0 order by sequence';
        $result = $adb->pquery($sql,array($tabid));
        $num_rows = $adb->num_rows($result);
        $fieldsinfo = array();
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $fieldsinfo[$i]['fieldname'] = $adb->query_result($result,$i,'fieldname');
                $fieldsinfo[$i]['showtag'] = $adb->query_result($result,$i,'showtag');
            }
        }
        return $fieldsinfo;
    }
    //获取用户头像等信息
    static public function getUserDetailInfo($userid){
        global $adb;
        $userid = trim($userid,',');
        $userlist = array();
        if(!empty($userid)){
            $sql='SELECT
                    ld_users.id,
                	ld_users.last_name AS lastname,
                    ld_users.wx_userid,
                	ld_attachments.`path` AS userimgpath,
                    ld_attachments.newfile_name as userimgname,ld_attachments.cloud_path,ld_attachments.storage_location,
                	ld_attachments.attachmentsid,
                    ld_profile.profilename,
                    GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid desc SEPARATOR  \';\' ) as groupname,
                    GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid desc SEPARATOR  \';\'  ) as groupids
                FROM
                	ld_users 
                LEFT JOIN ld_salesmanattachmentsrel ON ld_users.id = ld_salesmanattachmentsrel.smid
                LEFT JOIN ld_attachments ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid
                LEFT JOIN ld_users2group on ld_users2group.userid=ld_users.id
                LEFT JOIN ld_groups on ld_groups.groupid=ld_users2group.groupid
                LEFT JOIN ld_profile ON ld_users.profileid = ld_profile.profileid
                WHERE
                	ld_users.id in ('.$userid.') group by ld_users.id';
            //echo $sql;exit;
            $result = $adb->pquery($sql,array());
        
            $num_rows = $adb->num_rows($result);
        
            for ($i = 0; $i < $num_rows; $i++) {
                $id = $adb->query_result($result,$i,'id');
                $lastname = $adb->query_result($result,$i,'lastname');
                $wx_userid=$adb->query_result($result,$i,'wx_userid');
                $userobj=new Users();
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$lastname;
                $lastname=getUserlastName($userobj);
              
                $userimgpath = $adb->query_result($result,$i,'userimgpath');
                $userimgname = $adb->query_result($result,$i,'userimgname');
                $attachmentsid = $adb->query_result($result,$i,'attachmentsid');
                $storage_location = $adb->query_result($result, $i, 'storage_location');
                if($storage_location == 'cos'){
                    $userfilepath = $adb->query_result($result, $i, 'cloud_path');
                }
                else{
                    $userfilepath = self::getUserImageInfo($userimgpath,$userimgname,$attachmentsid,$id);
                }
                $groupname = $adb->query_result($result,$i,'groupname');
                $groupids=$adb->query_result($result,$i,'groupids');
                $groupname_arr=explode(";",$groupname);
                $groupids_arr=explode(";",$groupids);
                $tmpgroupname_arr=array();
                foreach($groupids_arr as $tmpgroupindex=>$tmpgroupid)
                {
                    $groupobj=new Users();
                    $groupobj->groupid=$tmpgroupid;
                    $groupobj->groupname=$groupname_arr[$tmpgroupindex];
                    $tmpgroupname_arr[]=getWx_GroupName($groupobj);
                    
                } 
                $groupname=implode(",",$tmpgroupname_arr);  
                $profilename = $adb->query_result($result,$i,'profilename');
                if(!empty($groupname)&&!empty($profilename)){
                    $description = $profilename.'-'.$groupname;
                }else{
                    $description = $profilename.$groupname;
                }
                $userlist[] = array(
                                    'id'=>$id,
                                    'lastname'=>$lastname,
                                    'wx_userid'=>$wx_userid,
                                    'userimg'=>$userfilepath,
                                    'description'=>empty($description)?'':$description
                                  );
            }
        }
        return $userlist;
    }
    //获取头像图片路径
    static public function getUserImageInfo($path,$userimagename,$attachmentsid,$userid){
        if(!empty($attachmentsid)&&!empty($path)){
          $userfilepath=$path.$userimagename;
        }
        else{
            // ljj 20231201 XUQIU1000927 更换默认头像
            $userfilepath=getDefaultAvatar($userid);
        }
        $userfilepath_True = globalStatic::$root_directory.$userfilepath;//gyq date:20170324
        if(!file_exists($userfilepath_True))
        {
            $userfilepath='themes/images/defaultuser.png';
        }
        return $userfilepath;
    }
    //判断是否是客户001账套
    static public function checkVersionIs001(){
        $regop=RegOp::getInstance();
        $crmversion=$regop->GetVersionNo();
        //55-58 是客户001 ,65-68是助华账套
        if(($crmversion>=55&&$crmversion<=58) or ($crmversion>=65&&$crmversion<=68)){
            return $crmversion;
        }
        return 0;
    }
    //判断是否是客户001预置账套
    static public function checkIsPreset001(){
        $userfocus = CRMEntity::getInstance('Users');
        $authtype = $userfocus->getAuthType();
        if(self::checkVersionIs001()&&$authtype=='yes'){
            return 'yes';
        }
        return 'no';
    }
    //editor:gyq_144 gyq_20190924 reason:钉钉  2019/9/24 13:38
    static public function dingtalk_present(){
        $regop=RegOp::getInstance();
        $crmversion=$regop->GetVersionNo();
        $present = array(7=>'灵当CRM基础版',10=>'灵当CRM标准版',1=>'灵当CRM企业版',
            70=>'灵当进销存',41=>'灵当CRM金融行业版');
        if(array_key_exists($crmversion,$present))
            //显示钉钉
            return 1;
        else
            //不显示钉钉
            return 0;
    }
    //转换文件大小     
    static public function sizeShow2Raw($size){
        $maxFileSize = 0;
        $numpart = substr($size,0, strlen($size) -2);
        $suffix  = strtoupper(substr($size, -2));

        switch ($suffix) {
            case 'KB': $maxFileSize = (int)((int)$numpart * 1024); break;
            case 'MB': $maxFileSize = (int)((int)$numpart * 1024 * 1024); break;
            case 'GB': $maxFileSize = (int)((int)$numpart * 1024 * 1024 * 1024); break;
            default:
                if (is_numeric($value)) {
                    $maxFileSize = (int)$value;
                }
        }
        return $maxFileSize;
    }
    //根据wx_userid获取userid
    static public function getIdFromWxUserid($wx_userid){
        global $adb;
        if(empty($wx_userid)) return '';
        //字符串，拆分为数组进行拼接
        if(!is_array($wx_userid)){
            $wxuseridarr = explode(',',$wx_userid);
        }else{
            $wxuseridarr = $wx_userid;
        }
        $wxuseridarr = '\''.implode('\',\'',$wxuseridarr).'\'';
        $sql = "select id,wx_userid from ld_users where wx_userid in($wxuseridarr)";
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $useridarr = array();
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $id = $adb->query_result($result,$i,'id');
                $wxid = $adb->query_result($result,$i,'wx_userid');
                $useridarr[$wxid] = $id;
            }
        }
        return $useridarr;
    }
    //客户001自动分配账套是否到期  gyq_54 20171214
    static public function isExpired($rExpiredTime,$rRenewTime){
        //$expiredtime = strtotime($rExpiredTime);
        $currenttime = time();
        $end_time = strtotime("+75 days",$rExpiredTime);
        if($currenttime > $rExpiredTime && $currenttime<$end_time){
            if(empty($rRenewTime)){
                ConvertTojsonString(11,array(),'5days_continue');
            }else{
                ConvertTojsonString(12,array(),'20corp_overtime');
            }
        }elseif($currenttime>$end_time){
            ConvertTojsonString(13,array(),'15corp_overtime');
        }
    }
    //判断当前用户是否是公海用户
    static public function isPublicAccountUser(){
        global $current_user;
        $adminaccount = getAccount_Set("adminaccount");
        $usersaccount = getAccount_Set('usersaccount');
        $status = getAccount_Set('status');
        $splitadmin = explode(",", $adminaccount);
        $splituser = explode(',', $usersaccount);
        if ($status == 0 && ($current_user->is_admin == "on" || in_array($current_user->id, $splitadmin) || in_array($current_user->id, $splituser))) {
            return true;
        }
        return false;
    }
    //判断当前用户是否是外部联系人用户
    static public function isExternalContactUser(){
        global $current_user,$adb;
        //ls 2022-07-04 导入外部联系人考虑自建应用
        crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
        $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
        if (!$wxselfbuilt_obj->installWXSelfBuilt) {
            $regop=RegOp::getInstance();
            $qywxht_interface=$regop->getqywxht_interface();
            $tmparr=explode(",",$qywxht_interface);

            if(!in_array('externalcontact',$tmparr))
            {
                return  '';
            }
        }

        $sql = "select switch,usertype,userid from ld_wx_config where name=?";
        $result = $adb->pquery($sql,array('external_contact'));
        if($adb->num_rows($result)){
            $switch = $adb->query_result($result,0,'switch');
            $userid = $adb->query_result($result,0,'userid');
            $usertype = $adb->query_result($result,0,'usertype');
            if($switch!='open') return '';
            if($usertype == 'user'){
				$ec_users = $userid;
			}else if($usersaccount_type == 'group'){
				$usersaccount = $adb->query_result($result,0,'usersaccount');
				require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
				$group = new Group();
				$groupids = explode(',',$userid);
				for($i = 0; $i<sizeOf($groupids); $i++){
					$userid_array[$i] = $group->getGroupOfusers($groupids[$i]);
				}
				foreach($userid_array as $user_info){
					foreach($user_info as $userid_key => $last_name){
						$userid_arr[$userid_key] = $userid_key;
					}
				}
				$ec_users = implode(',',$userid_arr);
			}else if($usersaccount_type == 'role'){
				$ec_users = getProfileForUsers($userid);
			}else{
				$userscope = get_user_array(FALSE, "", '');
				$userscopeid = array_keys($userscope);
				$ec_users = implode(',',$userscopeid);
			}
			//editor:gyq_94 reason:企业微信外部联系人批量导入  2019/1/4 9:47
            if(isset($_REQUEST['second_action'])&&$_REQUEST['second_action']=='import_contact'){
                return $ec_users;
            }else{
                if(in_array($current_user->id,explode(',',$ec_users))) return 1;
            }
        }
        return '';
    }
    //将时间范围标识转换为开始结束日期数组
    static public function rangeTime2DateArr($timemark){
        $time=strtotime(date('Y-m-d'));
        switch($timemark){
            case 'today':
            case 'thistoday':
                $startdate = date('Y-m-d',time());;
                $enddate = date('Y-m-d',time());;
                break;
            case 'yestoday':
            case 'yesterday':
            case 'syesterday':
                $startdate = date("Y-m-d",time()-24*60*60);
                $enddate = date("Y-m-d",time()-24*60*60);
                break;
            case 'thisweek':
            case 'week':
                $date = date("Y-m-d",time());  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d", strtotime("$date -".$d." days"));
                $startdate  = date("Y-m-d", strtotime("$nowdate +0 days")); //上周开始时间
                $enddate    = date("Y-m-d", strtotime("$startdate +6 days"));  //上周结束时间
                break;
                //editor:gyq_147 reason:扬锻销售报表  2019/9/29 15:39 
            case 'lastweek':
                $date = date("Y-m-d",time());  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d", strtotime("$date -".$d." days"));
                $startdate  = date("Y-m-d", strtotime("$nowdate - 7 days")); //上周开始时间
                $enddate    = date("Y-m-d", strtotime("$startdate +6 days"));  //上周结束时间
                break;
            case 'lastmonth':
                $startdate = date('Y-m-01',strtotime(date('Y',$time).'-'.(date('m',$time)-1).'-01'));
                $enddate = date('Y-m-d',strtotime("$startdate +1 month -1 day"));
                break;
            case 'thismonth':
            case 'month':
                $startdate = date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));
                $enddate = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
                break;
            case 'thisquarter':
            case 'thisfq':
                $season = ceil((date('n'))/3);
                $startdate = date('Y-m-d', mktime(0, 0, 0,$season*3-3+1,1,date('Y')));
                $enddate = date('Y-m-d', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                break;
            case 'lastquarter':
            case 'prevfq':
                $season = ceil((date('n'))/3)-1;
                $startdate = date('Y-m-d', mktime(0, 0, 0,$season*3-3+1,1,date('Y')));
                $enddate = date('Y-m-d', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                break;
            case 'lastyear':
            case 'prevfy':
                $startdate = date('Y-01-01',strtotime("-1 year"));
                $enddate = date('Y-12-31',strtotime("-1 year"));
                break;
            case 'thisyear':
            case 'year':
            case 'thisfy':
                $startdate = date('Y-01-01');
                $enddate = date('Y-12-31');
                break;
            case 'all':
                //zxm 20230421 如果时间条件是全部  那时间值为空的也应当查询出来--20240828 BUG20240827-66 不能返回空字符串,常用报表里面全部都是写的between and 为空不行
                $startdate = '2000-01-01';
                $enddate = date('2050-12-31');
                break;
            default:
                $time = explode('~',$timemark);
                $startdate = $time[0];
                $enddate = $time[1];
                break;
                
        }
        return array($startdate,$enddate);
    }

    static public function getExtName($name){
        $img = 'other';
        $att_name_arr = explode('.',$name);
        $ext = strtolower($att_name_arr[count($att_name_arr) - 1]);
        if($ext == 'txt'){
            $img = 'txt';
        } else if($ext == 'doc' || $ext == 'docx'){
            $img = 'doc';
        } else if($ext == 'xls' || $ext == 'xlsx' || $ext == 'mpp'){
            $img = 'excle';
        } else if($ext == 'html'){
            $img = 'html';
        } else if($ext == 'mp3' || $ext == 'mp4' || $ext == 'avi' || $ext == 'rm' || $ext == 'rmvb' || 
                  $ext == 'mov' || $ext == 'wmv' || $ext == 'asf' || $ext == 'asf' || $ext == 'dat'){
            $img = 'video';
        } else if($ext == 'jpg' || $ext == 'jpeg' || $ext == 'png' || $ext == 'bmp' || 
                  $ext == 'gif' || $ext == 'tiff' ){
            $img = 'img';
        }else if($ext == 'ofd'){
            $img = 'ofd';
        }
        return $img;
    }
    //editor:gyq_151 reason:字节数格式转换  2019/10/15 19:39 ID1000623
    public static function  trans_byte($byte)
    {
        $KB = 1024;

        $MB = 1024 * $KB;

        $GB = 1024 * $MB;

        $TB = 1024 * $GB;

        if ($byte < $KB) {

            return $byte . "B";

        } elseif ($byte < $MB) {

            return round($byte / $KB, 2) . "KB";

        } elseif ($byte < $GB) {

            return round($byte / $MB, 2) . "MB";

        } elseif ($byte < $TB) {

            return round($byte / $GB, 2) . "GB";

        } else {
            return round($byte / $TB, 2) . "TB";

        }
    }
    //editor:gyq_152 reason:签到考情图片上传  2019/10/17 17:01 
    public static function upload_save_file( $file_details)
    {
        global $adb, $current_user;
        global $upload_badext;
        $date_var = date("Y-m-d H:i:s");
        //editor:gyq_156 reason:钉钉签到拍照压缩上传,文件重命名  2019/11/1 10:39
        $file_name_ori = $file_details['name'];
        $file_name_ori= FileFileterString($file_name_ori);
        $file_type = strrchr($file_name_ori,'.');
        $time = time();
        $rand = mt_rand(1, 100000);
        $file_name = pathinfo($file_details['name'])['filename'] . '_' . $time . $rand . $file_type;
        $file_name=str_replace(" ","_",$file_name);
        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
        {
        }else{
            $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
            $encode=mb_detect_encoding($file_name, $arr);
            if($encode!='UTF-8'){
//                $file_name=iconv('UTF-8','gbk',$file_name);
                //BUG20240914-50 ls 240918 云之家移动端在审批节点上传的附件不能预览和下载(文本名含中文时)
                $file_name = mb_convert_encoding($file_name ,'utf-8' , $encode);
            }
        }
        $filetype = $file_details['type'];
        $filesize = $file_details['size'];
        $filetmp_name = $file_details['tmp_name'];
        //get the file path inwhich folder we want to upload the file
        $root_path = decideFilePath();
        $upload_file_path = $root_path;
        if ($file_details['noteid'] > 0) {//复制
            copy($upload_file_path . $file_details[attachmentsid] . '_' . $file_details['original_name'], $upload_file_path . $file_name);
            $upload_status = 'true';
        } else {
            //$upload_status = move_uploaded_file($filetmp_name, globalStatic::$root_directory.'storage/3_Contacts.xlsx');
            if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
                //获取系统类型，如果是非windows系统则不用修改编码格式
                $upload_status = @move_uploaded_file($filetmp_name, $upload_file_path . $file_name);
            } else
                $upload_status = @move_uploaded_file($filetmp_name, mb_convert_encoding($upload_file_path . $file_name, 'gb2312', 'UTF-8'));
        }
//        $filename = iconv('gb2312','UTF-8',$file_name);
        $filename = $file_name;
        $pathInfo = pathinfo($filename);
        $root_path_arr = explode('storage',$root_path) ;
        $response =array (
            'filename'=>$file_details['name'],
            'filepath'=>'storage'.$root_path_arr[1],//$uploadDir
            'filesize'=>$file_details['size'],
            'filetype'=>$file_details['type'],
            'filesuffixes'=>$pathInfo['extension'],
            'newfile_name'=>$filename,
            'upload_status'=>$upload_status
        );
        ConvertTojsonString(1,array('list'=>$response),'success');
    }
    //editor:gyq_160 reason:梳理移动端报表的时间区间获取方法  2019/11/13 13:21 ID1000640
    public static function getTimeRange($rTimemark,$rType='arr'){
        $time_list = self::rangeTime2DateArr($rTimemark);
        //zxm 20230421 如果时间条件是全部  那时间值为空的也应当查询出来
        if(empty($time_list)){
            return $time_list;
        }
        $time_start = $time_list[0].' 00:00:00';
        $time_end = $time_list[1].' 23:59:59';
        $timeBetweenSql = 'between  \'' . $time_start . '\' and \'' . $time_end . '\' ';
        if($rType=='arr'){
            $final = array($time_start,$time_end);
        }elseif($rType=='string'){
            $final = $timeBetweenSql;
        }
        return $final;
    }
    //editor:gyq_168 reason:签到统计表功能优化，增加考勤对象类型   2020/1/20 15:14
    public static function getOptionModule($rModule){
        global $adb;
        $tabid = getTabid($rModule);
        $list_query = 'select op.option_tabid,ld_tab.name as modulename,op.default
                from ld_option_module as op
				left join ld_tab on ld_tab.tabid = op.option_tabid
                where op.tabid=? and ld_tab.presence <> 1 and op.presence<>1 order by sequence';
        $list_result = $adb->pquery($list_query,array($tabid));
        $num_rows =  $adb->num_rows($list_result);
        $modulelist=  array();
        if($num_rows){
            $select_arr = array(0=>'',1=>'selected');
            for($i=0;$i<$num_rows;$i++){
                $modulename = $adb->query_result($list_result,$i,'modulename');
                // @edit:dong @date:2020/08/24 @reason: bug0042482 模块管理中关闭模块后，签到源单类型定制中应该不显示该模块，且签到统计表中也应该不显示该模块
                if($modulename !=''){
                    if(!vtlib_isModuleActive($modulename)) continue;
                    if(isPermitted($modulename) == 'no') continue;
                }

                $default = $adb->query_result($list_result,$i,'default');
                $modulename_label = getTranstab($modulename);
                $modulelist[$i]['label']  = $modulename_label;
                $modulelist[$i]['value']  = $modulename;
                $modulelist[$i]['select']  = $select_arr[$default];
            }
        }
        return $modulelist;
    }
}