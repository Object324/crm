<?php
/* creator:gyq_29 date:20170327 reason:工作协同代码优化*/
require globalStatic::$root_directory.'modules/Home/WorkReportController.php';
class WorkReportControllerWX extends WorkReportController {
	public function __construct() {
        crm_load_class_file('WorkReportModelWX','WeiXinApp/modules/Home');
        $this->model = new WorkReportModelWX();
    }
    public function getGroupAndUserList(){//20171204 gyq_52 注册定制化获取用户部门信息
        $group = $this->model->getGroupInfoWX();
        $users = $this->model->getUserArrayWX();
        return array('group'=>$group,'user'=>$users);
    }
      public function savereader() {
        $this->model->savereader();
        ConvertTojsonString(1,array(),'success');
    }
    /**
     * edit:gyq_45
     * reason:获取用户信息数组
     * */
    public function getUserArrayWX($rPort,$rToken)
    {
        $user_arr = $this->model->getUserArrayWX();
        $image_path_exist = array();
        foreach($user_arr as $key=>$value){
            $image_path = $value['userimgpath'];

            if(array_key_exists($image_path,$image_path_exist)){
                $user_arr[$key]['userimgpath'] = $image_path_exist[$image_path];
            }else{
                $media_id = $rPort->getMedia_id($image_path,$rToken);
                $image_path_exist[$image_path] = $media_id;
                $user_arr[$key]['userimgpath'] = $media_id;
            }
        }
        return $user_arr;
    }


    public function attachmentPreview(){
        global $PlatformMC;
       //gyq_41
        if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
        {//获取系统类型，如果是非windows系统则不用修改编码格式
            $fileurl = globalStatic::$root_directory.urldecode($_REQUEST['attachment_path']);
        }else{
            $fileurl = globalStatic::$root_directory.$_REQUEST['attachment_path'];
            $fileurl = iconv('utf-8','gbk',$fileurl);
        }
        $filename = preg_replace('/^.+[\\\\\\/]/', '', $fileurl);
        $content = file_get_contents($fileurl);

        file_put_contents('./'.$filename,$content);

        crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
        $portObj = new cls_WeixinPort();//gyq_41 //gyq_33
        /*editor:gyq_63 date:20180228 reason:接口支持多应用
        $portObj->getAgentId();
        $access_token = $portObj->getAccessToken($portObj->sAppnameColl['crm']);*/
        $access_token = $portObj->getCorpToken();

        $url = 'https://qyapi.weixin.qq.com/cgi-bin/media/upload?access_token='.$access_token.'&type=file';
        $post_data = array(
          //  "file"=>'@'.$fileurl, //这里要注意@符串
            "file"=>'@'.'./'.$filename, //这里要注意@符串
        );

        $info = $portObj->curlUploadFile($post_data,$url);
        $infoArr=json_decode($info,true);
        $media_id = $infoArr['media_id'];
        unlink('./'.$filename);
        if(!empty($media_id)){
            $newArr['touser'] = $PlatformMC['userid'];
            $newArr['toparty'] = '';
            $newArr['totag'] = '';
            $newArr['msgtype'] = 'file';
            $newArr['agentid'] = $portObj->agentid['ldcrm'];
            $newArr['file']['media_id'] = $media_id;
            $newArr['safe']=0;
            $post_data = json_encode($newArr, JSON_UNESCAPED_UNICODE);
            $url = StaticConst::$send_news_url;
            $post['access_token'] = $portObj->access_token;
            $post['news'] = $post_data;
            $returnArr = $portObj->curlPost($url,$post);
            $msg_return_arr = json_decode($returnArr,true);
            $errcode = $msg_return_arr['errcode'];
            $errmsg = $msg_return_arr['errmsg'];
            if($errcode=='0'&& $errmsg=='ok'){
                ConvertTojsonString(1,null,'success');
            }else{
                ConvertTojsonString(-1,null,$errmsg);
            }
        }
    }
    /**
     * 保存日志,微博，任务
     * edit:gyq
     */
    public function saveSendLog() {
        $uploadimgList = $_REQUEST['uploadimgList'];
        $workreportid = $_REQUEST['reportid'];
        if($workreportid == -1 || !isset($workreportid) || is_null($workreportid)){
            unset($_REQUEST['uploadimgList']);
            $this->model->save();//保存日志或回复
            $workreportid = $_REQUEST['home_lastinsert']['id'];
            $this->model->saveFileFromWeiXinApi($workreportid,'Home',$uploadimgList);
            return true;
        }else{
           $this->model->editReport($_REQUEST);//保存日志
           return true;
        }
    }
    public function getList()
    {
        //$smallcategory = array('all'=>'全部','weibo'=>'微博','cocmd'=>'任务','logday'=>'日志','ogweek'=>'周计划','logmonth'=>'月计划');
        $list = parent::getList();
     
        if($_REQUEST['viewuserid']){//个人主页基础信息
            $list['userbaseinfo'] = $this->getReportUserList_signal($_REQUEST['viewuserid']);
        }
        //duan 20221222 移动端增加翻译字符串返回
        $list['arrFixedLabel'] = $this->getWorkListFixedlabel();
        $list['global_setting'] = $this->getCRMSetting('index');
        return $list;
    }
    //个人主页基础信息
    protected function getReportUserList_signal($userid){
        global $adb;
        $SQL = 'select DISTINCT ld_salesmanattachmentsrel.attachmentsid ,ld_users.last_name ,ld_users.userlevel,ld_users.wx_userid,
                path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_users.id,ld_profile.profilename
                from ld_users left join ld_profile on ld_profile.profileid = ld_users.profileid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
               where  ld_users.id = ?';
        $result=$adb->pquery($SQL,array($userid));
        $i= 0;
        $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
        $path=$adb->query_result($result,$i,'path');
        $userimagename=$adb->query_result($result,$i,'userimagename');
        $storage_location=$adb->query_result($result,$i,'storage_location');
        $userid=$adb->query_result($result,$i,'id');
        if($storage_location == 'cos'){
          $userfilepath=$adb->query_result($result,$i,'cloud_path');
        }
        else{
          $userfilepath=$this->model->getUserImage($path,$userimagename,$attachmentsid,$userid);
        }
        $profilename = $adb->query_result($result,$i,'profilename');
		$wx_userid = $adb->query_result($result,$i,'wx_userid');
		$last_name = $adb->query_result($result,$i,'last_name');
		$userobj=new Users();
		$userobj->wx_userid=$wx_userid;
		$userobj->last_name=$last_name;
		$username=getUserlastName($userobj);
        if($profilename==null){
            $profilename = '';
        }
        $userlevel = $adb->query_result($result,$i,'userlevel');
        if($userlevel==null){
            $userlevel = '';
        }
        $entityContent=array('userimage'=>$userfilepath,'curid'=>$adb->query_result($result,$i,'id'),'username'=>$username,'profilename'=>$profilename,'userlevel'=>$userlevel);
        return $entityContent;

    }
    /**
     * edit:gyq_38
     * reason:获取CRM模块
     * */
    public function getCRMModules()
    {
        global $current_user, $global_regop,$weixin_user,$MobileLanguageType;
        $usermodules = $this->model->getCRMModules();
        $mix_return = $usermodules;
        //editor:gyq_92 reason:系统设置登录日志查询增加分类功能  2018/12/18 15:45
        //edit: hzx  47051: （81mis.com/kfbcrm）系统设置-其他设置-登录日志；钉钉移动端，首次绑定账号登录crm，日志中没有记录 首次关联时$_REQUEST['login_mark']=='logged_in'，
        if(($_REQUEST['login_mark']=='log_in' || $_REQUEST['login_mark']=='logged_in') && $_REQUEST['loginsession']==""){
            $tmp_login_type = $weixin_user->getMobiletype();

            //dump($tmp_login_type);
            global $tmp_login_check;
            $tmp_login_check =$tmp_login_type."|". time().rand(100000,999999);
            require_once(globalStatic::$root_directory.'modules/Users/LoginHistory.php');
            $loghistory=new LoginHistory();
            $usip='';$intime='';
            $languagetype = getMobileLanguageType($current_user->id);
            $Signin = $loghistory->user_login($current_user->user_name,$usip,$intime,'','','',0,$tmp_login_type,$tmp_login_check,$languagetype);
            //zkt 20240802 BUG20240801-35 在PC端修改kys密码为123456后，在移动端“微信小程序”上用更改后的密码“123456”登录kys账号，提示两次“您绑定的CRM用户密码错误，请重新登陆！”并且登录不成功
            LoginHistory::DeletepasswordChange_bymobiletype($current_user->id,$weixin_user->getMobiletype());
            //如果绑定了用户，则需要重新生成语言缓存文件
            if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
                CreateMobileLanguageCache('yes');
                getMobileLanguageType($current_user->id);
            }
        }
        if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='quick'){
            
        }
        else{
            $mix_return['setting'] = $this->getCRMSetting('index');//设置
        }

        //duan 20221010 添加翻译字符串返回
        $mix_return['arrFixedLabel'] = $this->getSettingArrFixedlabel();
        
        return $mix_return;
    }
    // 移动端工作台
    public function getCRMSetting($from_page){
        global $current_user,$MobileLanguageType,$global_remindsstoragecode;
        global $adb;
        $mix_return['setting'] =  $this->model->getHomeSetting();//设置
        if(!empty($global_remindsstoragecode)){
            $mix_return['setting']['remindsstoragecode'] = $global_remindsstoragecode;
        }
        //$mix_return['setting']['num'] =  $approvenum;//待办数量
        //显示样式
        if($from_page == 'home'){
            $mix_return['setting']['showtype'] =  '1'; 
        }
        else{
            $showtype_sql = 'select userid,deploy_value from ld_appsystem where userid= ? and deploy_type = 3';
            $showtype_result=$adb->pquery($showtype_sql,array($current_user->id));
            if($adb->num_rows($showtype_result)>0){
                $showtype = $adb->query_result($showtype_result,0,'deploy_value');
            }
            else{
                $showtype = '1';
            }
            $mix_return['setting']['showtype'] = $showtype;
        }

        //减少前端渲染的代码，这里做数组供前端循环 xxs 20180411
        $setlist[] = array('a'=>'MenuSet','b'=>getMobileFixedLabel('MENUDISPLAYMODE'),'c'=>getMobileFixedLabel('MENUDISPLAYMODE'),'d'=>$mix_return['setting']['showtype']==1?getMobileFixedLabel('BLOCKDISPLAY'):getMobileFixedLabel('LISTDISPLAY'));
        $setlist[] = array('a'=>'ModuleSet','b'=>getMobileFixedLabel('FUNCTIONMODULEDISPLAYSETTINGS'),'c'=>getMobileFixedLabel('FUNCTIONMODULEDISPLAYSETTINGS'),'d'=>'');
        //editor:gyq_159 reason:系统设置增加移动端报表菜单定制   2019/11/13 18:09 ID1000638
        $setlist[] = array('a'=>'ReportSet','b'=>getMobileFixedLabel('REPORTFORMMODULEDISPLAYSETTINGS'),'c'=>getMobileFixedLabel('REPORTFORMMODULEDISPLAYSETTINGS'),'d'=>'');
        $setlist[] = array('a'=>'JurisdictionSet','b'=>getMobileFixedLabel('CURRENCY2'),'c'=>getMobileFixedLabel('CURRENCY2'),'d'=>'');
        $mix_return['setting']['list'] = $setlist;

        $version = getVersionInfo();
        $mix_return['setting']['account'] = $version['account'];
        $mix_return['setting']['trade'] = $version['trade'];
        $mix_return['setting']['have_home_page'] = 'yes';
        $mix_return['setting']['have_upgrade_1017'] = 'yes';//字段公式升级，没有这个参数的不允许新增单据
        //editor:gyq_167 reason:小程序图片上传及文件预览，基于腾讯COS的优化   2020/1/16 14:55
        $mix_return['setting']['have_cos_upload_file'] = 'yes';//附件上传升级，没有这个参数的采用旧式51CN上传
        $mix_return['setting']['have_upload_type'] = 'yes';//20210129 增加上次COS
        $mix_return['setting']['havecashbilltype'] = 'yes';//20200615 收款单增加预收判断
        $mix_return['setting']['haveapprovefield'] = 'yes';//20201215 增加审批必填判断
        $mix_return['setting']['have_entry_relatedfields'] = 'yes';//20210329 单据分录定制，字段类型增加“引用字段”字段类型
        if(!isset($global_regop)){
            $global_regop=RegOp::getInstance();
        }

        //20200813 获取是否授权手写签名

        $have_writesign = 'no';
        if($global_regop->gethandleWriteSign_interface() == 1){
            $have_writesign = 'yes';
        }
        $mix_return['setting']['have_writesign'] = $have_writesign;
		$mix_return['setting']['system']['callrecordlog']='no';//通话录音权限
        if($global_regop->getCall_Record()=='1'){
            $mix_return['setting']['system']['callrecordlog']='yes';
        }
        //20201204 是否授权会话存档
        $have_wechatsession = 'no';
        if($global_regop->getwechatprofile() == 1){
            $have_wechatsession = 'yes';
        }
        $mix_return['setting']['have_wechatsession'] = $have_wechatsession;

        //zxm 2020-1216 ld_appsystems获取 设置移动端待办菜单界面是否显示销售助手 的值  deploy_type=4开启并且至少一个标签开启/如果只开启了联系人模块并且要求生日字段显示 才显示销售助手
        $mix_return['setting']['isOpenSalesAssistant'] = "no";
        $set_sql = "select is_open from ld_appsystem where (deploy_type=4 or deploy_type=6) and is_open='yes'";
        $set_res = $adb->pquery($set_sql);
        $set_nums = $adb->num_rows($set_res);
        if($set_nums>0){
            $mix_return['setting']['isOpenSalesAssistant'] = "yes";
        }
        
        $coid_sql = 'select para_three from ld_wx_config where name=\'wechat_miniprogram_setting\'';
        $coid_result = $adb->pquery($coid_sql,array());
        $coid = $adb->query_result($coid_result,0,'para_three');
        $mix_return['setting']['coid'] = $coid>0?$coid:0;

        //diony 20210118 获取系统参数
        $mix_return['setting']['system']=$this->getSystemDeploy();

        //通用设置 zxm 2021-0407
        $sql_common = 'select userid,is_open,deploy_value,deploy_type from ld_appsystem where userid= ? and deploy_type in(7,10,12,13,14) and is_open="yes"';
        $result_common = $adb->pquery($sql_common,array($current_user->id));
        $nums = $adb->num_rows($result_common);
        $showListBtn = 'no';
        $multiLineShowBtn = 'no';
        $haveReturnHome = 'no';
        $isSimpletype = 'no';
        $distanceVisible = '5';
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $deploy_type = $adb->query_result($result_common,$i,'deploy_type');
                if($deploy_type==7){
                    $showListBtn = 'yes';
                }
                if($deploy_type==10){
                    $multiLineShowBtn = 'yes';
                }
                if($deploy_type==12){
                    $haveReturnHome = 'yes';
                }
                if($deploy_type==13){
                    $isSimpletype = 'yes';
                }
                if($deploy_type==14){
                    $distanceVisible = $adb->query_result($result_common,$i,'deploy_value');
                }
            }
        }
        $mix_return['setting']['system']['showListBtn']=$showListBtn;//diony 20210407 单据列表是否显示快速操作按钮
        $mix_return['setting']['system']['multiLineShowBtn']=$multiLineShowBtn;//diony 20210407 单据列表是否显示快速操作按钮
        $mix_return['setting']['system']['haveReturnHome']=$haveReturnHome;//diony 20221222 是否启用快捷返回页签首页按钮
        $mix_return['setting']['system']['isSimpletype']=$isSimpletype;//edit: xll 2023/02/08 XUQIU1000984 
        $mix_return['setting']['system']['distanceVisible']=$distanceVisible;//edit: diony 2023/10/09 附近客户地图默认可见范围

        unset($mix_return['showListBtn']);
        unset($mix_return['multiLineShowBtn']);
        unset($mix_return['haveReturnHome']);
        unset($mix_return['isSimpletype']);
        unset($mix_return['distanceVisible']);

        $mix_return['setting']['system']['showUserLevel']='yes';//diony 20211105 选人控件组织架构
        $mix_return['setting']['system']['showHomeTimeRange']='yes';//diony 20211123 首页时间默认值
        $mix_return['setting']['system']['attachmentprofile']='yes';//diony 20220830 图片、附件权限控制
        $mix_return['setting']['system']['have_rejected_tab'] = 'yes';//20240407 审批列表增加被驳回的
        $mix_return['setting']['system']['have_mobile_language'] = 'yes';//20240325 是否有多语言
        $mix_return['setting']['system']['enorzh']=$global_regop->isEnorZh();//duan 20221008 移动端判断中英文是否授权
        $mix_return['setting']['system']['languagetype']=$MobileLanguageType;//duan 20221008 用户当前语言类型
        $mix_return['setting']['system']['approvesearch']='yes';//duan 20221026 移动端首页审批条件查询
        $mix_return['setting']['system']['signmodule']='yes';//duan 20221208 移动端拜访签到改模块
        $mix_return['setting']['system']['AddContactField']='yes';//duan 20230215 移动端去掉输入联系人信息后，联系人姓名必填的判断
        $mix_return['setting']['system']['detailviewCopy']='yes';//diony 20230222 移动端明细界面复制功能
        if($_REQUEST['action']=='home_page' && ($_REQUEST['login_mark']=='log_in'|| $_REQUEST['login_mark']=='logged_in') && $_REQUEST['loginsession']==""){
            global $current_user,$weixin_user;
            //企业微信端登录
            if($weixin_user->environment == 'weixinh5'){
                $tmp_login_type = 'qiyeweixin';
            }
            //钉钉端登录
            if($weixin_user->environment == 'dingtalk'){
                $tmp_login_type = 'dingtalk';
            }
            //云之家登录
            if($weixin_user->environment == 'yunzhijia'){
                $tmp_login_type = 'yunzhijia';
            }
            //企业微信小程序登录
            if($weixin_user->environment == 'wxwork'){
                $tmp_login_type = 'mini_wxwork';
            }
            //微信小程序登录
            if($weixin_user->environment == 'weixin'){
                $tmp_login_type = 'mini_weixin';
            }
            //源生app登录
            if($weixin_user->environment == 'app'){
                $tmp_login_type = 'app';
            }
            //泛微OA
            if($weixin_user->environment == 'fanwei'){
                $tmp_login_type = 'fanwei';
            }
            //dump($tmp_login_type);
            global $tmp_login_check;
            $tmp_login_check =$tmp_login_type."|". time().rand(100000,999999);
            require_once(globalStatic::$root_directory.'modules/Users/LoginHistory.php');
            $loghistory=new LoginHistory();
            $usip='';$intime='';
            //获取用户登录的语言类型
            $languagetype = getMobileLanguageType($current_user->id);
            $Signin = $loghistory->user_login($current_user->user_name,$usip,$intime,'','','',0,$tmp_login_type,$tmp_login_check,$languagetype);
            
            //如果绑定了用户，则需要重新生成语言缓存文件
            if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
                CreateMobileLanguageCache('yes');
                getMobileLanguageType($current_user->id);
            }
        }
        global $tmp_login_check;
        if(empty($_REQUEST['loginsession'])){
            $mix_return['setting']['system']['loginsession']=$tmp_login_check;
        }
        else{
            $mix_return['setting']['system']['loginsession']=$_REQUEST['loginsession'];
        }
        $mix_return['setting']['system']['currentuserid']=$current_user->id;

        //zkt 20231026 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
        require_once(globalStatic::$root_directory."/include/cls_UrlEncryptyJudge.php");
        $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
        $mix_return['setting']['system']['lingdangencryptykey']=$cls_UrlEncryptyJudgeobj->getlingdangencryptykey();

        //zxm 20230221 小程序CRM首页增加默认时间选项的返回值
        $deploy_345 = getSys_deploy(345);
        $mix_return['setting']['defaultTime'] = $deploy_345['deploy_value'];

        $mix_return['setting']['system']['callrecordlog']='no';//通话录音权限
        if($global_regop->getCall_Record()=='1'){
            $mix_return['setting']['system']['callrecordlog']='yes';
        }

        $mix_return['setting']['system']['save_submitapprove_separate'] = 'yes';//20240510 保存并提交审核和保存是否分开

        if($from_page == 'home'){
            return $mix_return;
        }
        else{
            return $mix_return['setting'];
        }
    }
    /**
    * 获取微信首页底部数量等
    */
    public function getBottomNumInfo(){
        crm_load_class_file('cls_Approve_CountListViewWX','WeiXinApp/modules/Approve/cls_Approve');
        $cls_Approve_CountListView = new cls_Approve_CountListViewWX(0);
        $approvenum = $cls_Approve_CountListView->getapprovenum();
        $entity['num'] = $approvenum;
        ConvertTojsonString(1,$entity,'success');
    }
    //获取首页时间筛选下拉框数据
    public function getHomeTimeRange(){
        $deploy = getSys_deploy(345);
        $defaultTime = $deploy['deploy_value'];
        //缺一个上季度
        $time_range = array(
            array('time_key'=>'today','label'=>'今日','key'=>'thistoday'),
            array('time_key'=>'syesterday','label'=>'昨日','key'=>'yestoday'),
            array('time_key'=>'thisweek','label'=>'本周','key'=>'thisweek'),
            array('time_key'=>'thismonth','label'=>'本月','key'=>'thismonth'),
            array('time_key'=>'lastmonth','label'=>'上月','key'=>'lastmonth'),
            array('time_key'=>'thisfq','label'=>'本季度','key'=>'thisquarter'),
            array('time_key'=>'prevfq','label'=>'上季度','key'=>'lastquarter'),
            array('time_key'=>'thisfy','label'=>'本年度','key'=>'thisyear'),
            array('time_key'=>'prevfy','label'=>'上年度','key'=>'lastyear'),
            array('time_key'=>'all','label'=>'全部','key'=>''),
            array('time_key'=>'custom','label'=>'自定义时间')
        );
        $output['list']['time_key'] = '本月';
        $output['list']['label'] = 'thismonth';
        foreach ($time_range as $key=>$content){
            //默认值 系统设置的默认时间 zxm20211112 【首页，销售简报时间增加可设置默认值（王楠）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002217
            if($content['key']==$defaultTime){
                $output['list']['time_key'] = $content['time_key'];
                $output['list']['label'] = $content['label'];
                $output['list']['time_index'] = $key;
                break;
            }
        }
        ConvertTojsonString(1,$output,'success');
    }
    /**
     * edit:diony
     * reason:获取"我"模块设置
     * */
    public function getMeModules()
    {        
        return $this->model->getMeModules();
    }
    /**
     * 获取“我”报表设置
     */
    //editor:gyq_141 reason:移动端增加首页标签，报表设置功能已删除，故删除后台相关代码  2019/9/9 10:54 ID1000602
    /*public function getMeReports(){
        return $this->model->getMeReports();
    }*/
    /**
     * edit:diony
     * reason:获取单条信息
     * */
    public function getDetailView()
    {
        $list=$this->model->getDetailView();
        //duan 20221222 移动端增加翻译字符串返回
        $list['arrFixedLabel'] = $this->getWorkDetailFixedabel();
        //文本控件的翻译
        $label_arr = array('CANCEL','PLEASEFILLINTHECONTENT','SUBMIT','FILLINCOMMENTS','COMMENT1','NOTFILLEDINTHECONTENT',
            'ENTERAPOSITIVEINTEGER','FAILLEDTOCOLSE','RELEASENEW','EDIT','Reply','COMMENTAPP');
        $list['arrFixedLabel_remark']=TransFieldlabel($label_arr,'no');
        $list['labelSwitching'] = [['label'=>'回复','type'=>'reply','class'=>'ldnavbar-item-active'],['label'=>'修改日志','type'=>'changelog','class'=>'']];
        $list['global_setting'] = $this->getCRMSetting('index');
        return $list;
    }
    public function getWorkRemindsAppList()
    {        
        return $this->model->getWorkRemindsAppList();
    }
    /**
     * edit:can
     * reason:提醒列表
     * */
    public function getRemindsList()
    {
        return $this->model->getRemindsList();
    }
    /**
     * 获取个人信息
     * */
    public function  getMeInfo()
    {
        return $this->model->getMeInfo();
    }
    /**
     * 保存个人信息
     * */
    public function saveMe()
    {
        return $this->model->saveMe();
    }
    //快速查找
    public function unifiedSearch()
    {
        return $this->model->unifiedSearch();
    }
    //快速查找
    public function unifiedSearchModules()
    {
        return $this->model->unifiedSearchModules();
    }
    /**
     * 修改密码
     * */
    public function changeMePwd()
    {
        return $this->model->changeMePwd();
    }
     /**
     * 保存用户（我)图片
     * */
    public function saveMePhoto()
    {
        return $this->model->saveMePhoto();
    }
    /**
     * edit:can
     * reason:动态获取界面字段
     * */
    public function getallFieldsForTable()
    {
        return $this->getallFieldsForTable();
    }

    /**
     * edit:diony
     * reason:获取签到字段
     * */
    public function getSignAddress()
    {
        return $this->getSignAddress();
    }
    
    /**
     * edit:diony
     * reason:保存CRM设置
     * */
	public function savemoduleset() {
	    $modulename = $_REQUEST['modulename'];
	    return $this->model->saveappuiset($modulename,'module');
	}
    //editor:gyq_141 reason:移动端增加首页标签，报表设置功能已删除，故删除后台相关代码  2019/9/9 10:51 ID1000602
    /*public function savereportset() {
        $reportname = $_REQUEST['reportname'];
	    return $this->model->saveappuiset($reportname,'report');
	}*/
    /**
     * edit:diony
     * reason:保存CRM显示设置
     * */
	public function savemoduleshowset() {
	    return $this->model->savemoduleshowset();
	}

    /**
     * edit:diony
     * reason:单据列表是否显示快速操作按钮
     * */
    public function savelistbtnshowset() {
        return $this->model->savelistbtnshowset();
    }
    public function getChangeLog()
    {
        $workreportid= $_REQUEST['workreportid'];
        $changelog['list'] = $this->model->getChangeLog($workreportid);
        return $changelog;
    }

    /**
	 * 获得回复列表
	 * @author Tujt 2015-02-06
	 */
	public function getReplyList() {
	    $replylist['list'] = $this->model->getReplyList();
        return $replylist;
	}    
    /**
	 * 获得点赞列表
	 * @author diony 2016-04-19
	 */
	public function getPraiseList() {
	    $praiselist['list'] = $this->model->getPraiseList();
        return $praiselist;
	}
    
    //获取通讯录信息
	public function getAdressbook(){
        global $adb,$current_user;
        $users_combo = $this->model->getUserInfo();
        $Group_Special = crm_load_class_obj('Group_Special','modules/Users');
        $groupuser = $Group_Special->getGrouplistForApp();
        return array('Department'=>$groupuser,'Colleague'=>$users_combo);
	}
    public function getGroupUsers(){        
       // $_REQUEST['popup_type'] = 'Allocate';
        global $adb;
        if(isset($_REQUEST['specialuser_search_value'])&&$_REQUEST['specialuser_search_value']!=''){
            //山水推荐设计师逻辑
            $this->get_recommon_designer();
        }
        crm_load_class_file('cls_GroupUser','WeiXinApp/WeiXin_common/SearchScope');
        if(isset($_REQUEST['return_module'])&&$_REQUEST['return_module'] == 'SharedUsers'){
            $_REQUEST['checkprivilege'] = 'no';
        }
        $whereuserid_arr=[];
        if(isset($_REQUEST['whereusermodule'])&&!empty($_REQUEST['whereusermodule'])){
            $whereusermodule=$_REQUEST['whereusermodule'];
            if($whereusermodule=="TrackLocationMap"){
                $sql='select  * from ld_users where ifnull(trackgroupid,0)>0 and trackgroupid in (SELECT ld_trackpostion.trackpostion_id from ld_trackpostion)';
                $result=$adb->pquery($sql,array());

                for($i=0;$i<$adb->num_rows($result);$i++){
                   $tmpuserid=$adb->query_result($result,$i,'id');
                   $whereuserid_arr[]= $tmpuserid;
                }
            }
        }
        $searchscope = array(
            'module'=>$_REQUEST['return_module'],
            'searchtype'=>$_REQUEST['searchtype'],
            'filterown'=>$_REQUEST['filterown'],
            'scopetype'=>$_REQUEST['scopetype'], 
            'common'=>$_REQUEST['common'], 
            'isactive'=>$_REQUEST['isactive'] ,
            'whereuserid_arr'=>$whereuserid_arr
        );
        
        $cls_GroupUser = new cls_GroupUser($searchscope);
        $orignalTree = $cls_GroupUser->getGroupUser();

        //duan 20221012 移动端增加翻译文件返回
        $orignalTree['arrFixedLabel'] = $this->getChooseUserFiexedlabel();

        return $orignalTree;
    }
    
    //配置微信推送提醒参数
	public function saveRemindSet() {
	    return $this->model->saveRemindSet();
	}
    //获取微信推送提醒参数
	public function getRemindSet() {
	    return $this->model->getRemindSet();
	}
    //获取微信端首页设置页签参数
    public function getHomeSetting(){
        return $this->model->getHomeSetting();
    }
    //获取公告列表
    public function getNoticeList()
    {
        return $this->model->getNoticeList();
    }
    //获取字段修改日志结果集
    public function getFieldUpdateLog()
    {
        return $this->model->getFieldUpdateLog();
    }
    
    //获取当前时间
    public function getCurentTime()
    {
        return $this->model->getCurentTime();
    }
    
    //获取发送范围、点评人或执行人
    public function getRangeCommentExecutor(){
        return $this->model->getRangeCommentExecutor();
    }

    /**
     * edit:diony
     * reason:获取Work
     * */
    public function getWorkHome()
    {
        global $current_user,$global_remindsstoragecode;
        //微博 =>weibo  任务=>cocmd  日志=>logday  周计划=>ogweek  月计划=>logmonth
        crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
        $workreportshowobj=new cls_workreportshow();
        $allshowtype=$workreportshowobj->getWorkReportShow();
//        ls 2021-10-20 【1002089】工作汇报，工作类别增加编辑功能(移动端)
        $workhome=
            array(
                  'weibo'=>array('title'=>getFixedLabel('BLOG'),'imagename'=>'weibo.png','type'=>'ItemWeibo','mode'=>'create'),
                  'dayreport'=>array('title'=>getFixedLabel('JOURNAL'),'imagename'=>'day.png','type'=>'ItemLogday','mode'=>'create'),
                  'weekreport'=>array('title'=>getFixedLabel('WEEKPLAN'),'imagename'=>'week.png','type'=>'ItemLogweek','mode'=>'create'),
                  'monthreport'=>array('title'=>getFixedLabel('MONTHPLAN'),'imagename'=>'month.png','type'=>'ItemLogmonth','mode'=>'create'),
                  'cocmd'=>array('title'=>getFixedLabel('TASK'),'imagename'=>'jihua.png','type'=>'ItemCocmd','mode'=>'create')
            );
        $category = array('weibo'=>getFixedLabel('BLOG'),'dayreport'=>getFixedLabel('JOURNAL'),'weekreport'=>getFixedLabel('WEEKPLAN'),'monthreport'=>getFixedLabel('MONTHPLAN'),'cocmd'=>getFixedLabel('TASK'));
        $smallcategory['all'] = getFixedLabel('ALL');
        foreach($allshowtype as $showval){
            $type = $showval['type'];
            $smallcategory[$type] = $category[$type];
            $workhomearr[] = $workhome[$type];
        }
        $entity['list'] = $workhomearr;
        $entity['smallcategory'] = $smallcategory;
        //筛选条件格式化给前端，前端进行统一...
        $datecategoryarr['fieldlabel'] = getFixedLabel('RELEASETIME');
        $datecategoryarr['fieldname'] = 'datecategory';
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('UNLIMITED'),'value'=>'','select'=>'yes');
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('syesterday'),'value'=>'yesterday','select'=>'no');
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('today'),'value'=>'today','select'=>'no');
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('thisweek'),'value'=>'thisweek','select'=>'no');
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('thismonth'),'value'=>'thismonth','select'=>'no');
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('lastmonth'),'value'=>'lastmonth','select'=>'no');
        $datecategoryarr['option'][] = array('text'=>getFixedLabel('thisfy'),'value'=>'thisyear','select'=>'no');
        $sponsorarr['fieldlabel'] = getFixedLabel('PUBLISHER');
        $sponsorarr['fieldname'] = 'sponsor';
        $sponsorarr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'','select'=>'yes');
        $sponsorarr['option'][] = array('text'=>getFixedLabel('My'),'value'=>$current_user->id,'select'=>'no');
        $sponsorarr['option'][] = array('text'=>getFixedLabel('LBL_SENIOR'),'value'=>'smowner_search_senior','select'=>'no');
        $datetypearr['fieldlabel'] = getFixedLabel('DATATYPE');
        $datetypearr['fieldname'] = 'bigcategory';
        $datetypearr['option'][] = array('text'=>getFixedLabel('ALL'),'value'=>'1','select'=>'yes');
        $datetypearr['option'][] = array('text'=>getFixedLabel('Pending'),'value'=>'2','select'=>'no');
        $datetypearr['option'][] = array('text'=>getFixedLabel('Processed'),'value'=>'3','select'=>'no');
        $datetypearr['option'][] = array('text'=>getFixedLabel('IINITIATED'),'value'=>'4','select'=>'no');
        $datetypearr['option'][] = array('text'=>getFixedLabel('COPYFORME'),'value'=>'5','select'=>'no');
        $datetypearr['option'][] = array('text'=>getFixedLabel('ATME'),'value'=>'6','select'=>'no');
        $entity['list2'] = array($datetypearr,$datecategoryarr,$sponsorarr);
        //获取工作汇报页面内容
        $entity['arrFixedLabel'] = $this->getWorkhomeFixedlabel();
        //文本控件的翻译
        $label_arr = array('CANCEL','PLEASEFILLINTHECONTENT','SUBMIT','FILLINCOMMENTS','COMMENT1','NOTFILLEDINTHECONTENT',
            'ENTERAPOSITIVEINTEGER','FAILLEDTOCOLSE','RELEASENEW','Reply','COMMENTAPP');
        $entity['arrFixedLabel_remark']=TransFieldlabel($label_arr,'no');
        if(!empty($global_remindsstoragecode)){
            $entity['remindsstoragecode'] = $global_remindsstoragecode;
        }
        
        ConvertTojsonString(1,$entity,"");
    }
    //editor:gyq_138 reason:迅达别墅梯首页  2019/8/23 10:30
    //editor:gyq_159 reason:系统设置增加移动端报表菜单定制   2019/11/13 16:53 ID1000638
    public function getReportSettingData()
    {
        $list = $this->model->getReportSettingData();
        ConvertTojsonString(1,array('list'=>$list),"");
    }
    //变更报表显示状态
    public function changePersonalReportSet(){
        $list = $this->model->changePersonalReportSet($_REQUEST['hidden_value']);
    }
    //获取个人的报表列表
    public function HomeReport(){
        $list = $this->model->getPersonalReportList();
        $entity['blocklist'] = array_values($list);
        //duan 20221011 获取移动端报表页面的翻译
        $entity['arrFixedLabel'] = $this->getReportFiexedlabel();
        //diony 20240514 获取设置
        $entity['setting'] = $this->getCRMSetting('index');
        //zxm 20221207 成员基本信息 头像 名字 公司 职位等
        global $current_user;
        crm_load_class_file('UsersUtils','modules/Users');
        $UsersUtilsObj = new UsersUtils();
        $entity['setting']['userinfo'] = $UsersUtilsObj->getCrmUserInfo($current_user->id);
        $entity['setting']['userinfo']['profilename'] = $current_user->getUserOfProfileName();
        //首次绑定增加
        ConvertTojsonString(1, $entity,'success');
    }
    //获取电子名片信息
    //zxm
    //2020-1214
    public function getElectricCard()
    {
        $userid = $_REQUEST['userid'];
        global $adb;
        // 没有设置 提示去设置
        $sql = 'select para_one,para_three from ld_wx_config where name=\'wechat_miniprogram_setting\'';
        $result = $adb->pquery($sql,array());
        $nums = $adb->num_rows($result);
        if($nums>=1){
            $coid = $adb->query_result($result,0,'para_three');
            $para_one = $adb->query_result($result, 0, 'para_one');
        }
        if((empty($coid)||empty($para_one))){
            //$msg = '请前往电脑web端中【'.getTranstab("Settings").'】→【小程序设置】→【企业号设置】，输入"正确的企业号"与"CRM外网访问地址"！';
            $msg = sprintf(getFixedLabel('FINISHAPPLETSETTINGS'),getTranstab("Settings"));
            ConvertTojsonString(-1,[],$msg);
        }
        //查询ld_users表的id
        global $current_user;
        $crm_id = $current_user->id;
        global $adb;
        $root_dir = dirname(dirname(dirname(dirname(__FILE__))));//获取根目录
        //include globalStatic::$root_directory."WeiXinApp/cloudpro/CloudUsers.php";
        //$cloud_user_obj = new CloudUsers();
        crm_load_class_file('UsersUtils','modules/Users');
        $UsersUtilsObj = new UsersUtils();
        $info = $UsersUtilsObj->getCrmUserInfo($crm_id);
        $info['phone_mobile'] = empty($info['phone_mobile'])?'无':$info['phone_mobile'];
        $info['email'] = empty($info['email'])?'无':$info['email'];
        $info['address'] = empty($info['address'])?'无':$info['address'];
        if($info['storage_location'] == 'cos'){
            $info['image_str'] = self::imgToBase64ForCos($info['image_str']);
        }
        else{
            $info['image_str'] = self::imgToBase64(globalStatic::$root_directory.$info['image_str']);
        }
        //名片小程序码
        include globalStatic::$root_directory."WeiXinApp/marketing/controller/WxUsers.php";
        $userObj = new WxUsers($adb,$root_dir);
        $info['card'] = $userObj->getMyCardQrCode($crm_id);
        $info['card'] = self::imgToBase64(globalStatic::$root_directory.$info['card']);

        $info['phone_png'] = self::imgToBase64(globalStatic::$root_directory.'themes/icon2021/card/phone.png');
        $info['email_png'] = self::imgToBase64(globalStatic::$root_directory.'themes/icon2021/card/email.png');
        $info['address_png'] = self::imgToBase64(globalStatic::$root_directory.'themes/icon2021/card/address.png');
        $data = array('userinfo'=>$info);
        //duan 20221013 移动端获取字符串翻译
        $label_arr=array(
            'LONGPRESSTOFORWARD',//长按转发或识别小程序码
            'GENERATEBUSINESSCARD',//生成名片
            'EDITBUSINESSCARD',//编辑名片
            'CLOSE',//关闭
            'WARMPROMPT',//温馨提示
            'LOADING',//加载中
        );
        $fixedlabel_arr = TransFieldlabel($label_arr);
        $data['arrFixedLabel'] = $fixedlabel_arr;
        ConvertTojsonString(1, $data,'success');
    }

    /**
     * @param $img_file
     * @return string
     * 图片转base64 因为生成名片的图片无法处理跨域访问 故返回base64格式的图片 仅头像与小程序码需要
     */
    public static function imgToBase64($img_file) {
        $img_base64 = '';
        if (file_exists($img_file)) {
            $app_img_file = $img_file; // 图片路径
            $img_info = getimagesize($app_img_file); // 取得图片的大小，类型等
            $fp = fopen($app_img_file, "r"); // 图片是否可读权限

            if ($fp) {
                $filesize = filesize($app_img_file);
                $content = fread($fp, $filesize);
                $file_content = chunk_split(base64_encode($content)); // base64编码
                switch ($img_info[2]) {           //判读图片类型
                    case 1: $img_type = "gif";
                        break;
                    case 2: $img_type = "jpg";
                        break;
                    case 3: $img_type = "png";
                        break;
                }
                $img_base64 = 'data:image/' . $img_type . ';base64,' . $file_content;//合成图片的base64编码
            }
            fclose($fp);
        }
        return $img_base64; //返回图片的base64
    }
    public static function imgToBase64ForCos($img_file) {
        $imageInfo = getimagesize($img_file);
        $base64 = "" . chunk_split(base64_encode(file_get_contents($img_file)));
        return 'data:' . $imageInfo['mime'] . ';base64,' . $base64;
    }

    //获取系统参数
    public function getSystemDeploy()
    {
        $deploy_211 = getSys_deploy(211);
        $systemPoint = array('sys_211'=> $deploy_211['deploy_value']);
        // dump($systemPoint);
        //ls 2021-07-23 【ID1001808】钉钉可控制直接预览附件和保存到钉盘预览
        $deploy_328 = getSys_deploy(328);
        $systemPoint["sys_328"] = $deploy_328['deploy_value'];

        return $systemPoint;
    }
    
    //组织架构
    public function getGroupUsersLevel(){
        global $adb;
        $orignalTree = $this->getGroupUsers();

        $request_groupid = $_REQUEST['groupid'];
        //获取部门结构信息
        $sql = 'select groupid,depth,parentid from ld_groups';
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $groupinfo_arr = array();
        for($i=0;$i<$num_rows;$i++){
            $groupid = $adb->query_result($result,$i,'groupid');
            $groupinfo_arr[$groupid]['depth']=$adb->query_result($result,$i,'depth');
            $groupinfo_arr[$groupid]['parentid']=$adb->query_result($result,$i,'parentid');
        }
        //默认输出一级部门的信息
        if(empty($request_groupid)||$request_groupid<=0){
            $group_arr = $orignalTree['list1'];
            $depth = 1;
            foreach($group_arr as $key=>$tmp_arr){
                $tmp_groupid = $tmp_arr['groupid'];
                if($groupinfo_arr[$tmp_groupid]['depth']!=$depth){
                    unset($orignalTree['list1'][$key]);
                }
            }
        }else{
            $group_arr = $orignalTree['list1'];
            $all_user_arr = $orignalTree['list_new'];
            $user_arr = array();
            foreach($group_arr as $key=>$tmp_arr){
                $tmp_groupid = $tmp_arr['groupid'];
                if($groupinfo_arr[$tmp_groupid]['parentid']!=$request_groupid&&$tmp_groupid!=$request_groupid){
                    unset($orignalTree['list1'][$key]);
                }else{
                    if($tmp_groupid==$request_groupid){
                        unset($orignalTree['list1'][$key]);
                    }
                    if($tmp_arr['usernum']>1){
                        $tmp_userid_arr = explode(',',$tmp_arr['userids']);
                        foreach($tmp_userid_arr as $key=>$tmp_userid){
                            if(!in_array($tmp_userid,$user_arr)){
                                $user_arr[]=$tmp_userid;
                            }
                        }
                    }else{
                        if(!in_array($tmp_arr['userids'],$user_arr)){
                            $user_arr[]=$tmp_arr['userids'];
                        }
                    }
                }
            }
            
            foreach($all_user_arr as $key=>$users_info){
                if(!in_array($users_info['id'],$user_arr)){
                    unset($orignalTree['list_new'][$key]);
                }
            }
        }
        //json_encode 会将索引数组转化为数组形式，而将关联数组转化为对象形式，所以将数组重新排序
        foreach($orignalTree as $index => $arr){
            $i =0;
            if(sizeof($arr)>0 && $index != 'arrFixedLabel'){
                foreach($arr as $key => $value){
                    unset($orignalTree[$index][$key]);
                    $orignalTree[$index][$i] = $value;
                    $i++;
                }
            }
        }
        
        return $orignalTree;
    }
    // 山水推荐设计师规则，调用pc端方法,获取推荐设计师
    public function get_recommon_designer(){
        global $adb;
        $_REQUEST['frommodule'] = 'Accounts';
        $_REQUEST['selectmodule'] = 'Users';
        $_REQUEST['file'] = 'select_related_popu';
        $_REQUEST['requestvalues'] = $_REQUEST['specialuser_search_value'];
        $fromfocus = CRMEntity::getInstance($_REQUEST['frommodule']);
        $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("bigtype", 'choosemultiuser');
        $_REQUEST['fieldname'] = $fieldinfo->getFieldName();
        $_REQUEST['maxrowsshow'] = $fieldinfo->getMaxRowsShow();
        crm_load_class_file("SelectRelatedPopu",'include/SelectRelatedPopu');
		$SelectRelatedPopu = new SelectRelatedPopu($_REQUEST['selectmodule'],$adb);
        $sql = $SelectRelatedPopu->setRelatedPopopSql();
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        $userid_arr = array();
        for($i=0;$i<$num_rows;$i++){
            $userid = $adb->query_result($result,$i,'id');            
            $userid_arr[] = $userid;
        }
        $_REQUEST['recommon_designer'] = $userid_arr;
    }

    //保存常用模块
    public function save_Commonmodules(){
        global $adb,$current_user;
        if(!empty($_REQUEST['commonmodules'])){
            $modules = explode(',',$_REQUEST['commonmodules']);
            if(sizeOf($modules) > 7){
                ConvertTojsonString(-1,array(),'error');
            }
            $moduleids = explode(',',$_REQUEST['commonmoduleids']);
            $tabnames = explode(',',$_REQUEST['commonmoduletablenames']);
            $delete = "delete from ld_appuiset where userid = ? and settype = 'module' and apptype = 'commonmodules'";
            $adb->pquery($delete,array($current_user->id));
            foreach($modules as $key => $mod){
                $tabname = $tabnames[$key];
                $insert = "insert into ld_appuiset(userid,settype,apptype,setname,tabid,tab_tablename) values(?,?,?,?,?,?)";
                $adb->pquery($insert,array($current_user->id,'module','commonmodules',$mod,$moduleids[$key],$tabname));
            }
        }
        else{
            $delete = "delete from ld_appuiset where userid = ? and settype = 'module' and apptype = 'commonmodules'";
            $adb->pquery($delete,array($current_user->id));
        }
        ConvertTojsonString(1,array(),'success');
    }
    //移动端切换语言类型
    public function ChangeLanguageType(){
        global $current_user,$weixin_user,$adb,$MobileLanguageType;
        $environment = $weixin_user->environment;
        switch($environment){
            case 'weixinh5':$login_type = 'qiyeweixin';break; //企业微信
            case 'weixin':$login_type = 'mini_weixin';break; //微信小程序
            case 'wxwork':$login_type = 'mini_wxwork';break; //企业微信小程序
            case 'dingtalk':$login_type = 'dingtalk';break; //钉钉
            case 'yunzhijia':$login_type = 'yunzhijia';break; //云之家
            case 'app':$login_type = 'app';break;//源生app
            case 'fanwei':$login_type = 'fanwei';break;//泛微OA
            default:$login_type = 'other';break; //其他登陆方式，例如oem小程序，表单码等
        }
        if(isset($_REQUEST['mobile_language_type']) && !empty($_REQUEST['mobile_language_type'])){
            $languagetype = $_REQUEST['mobile_language_type'];
        }else{
            $languagetype = 'zh';
        }
        $username = $current_user->user_name;
        //获取当前用户最新一条的登陆日志
        $sql = "SELECT max(login_id) as lastid from ld_loginhistory where user_name =? AND login_type = ?;";
        $result = $adb->pquery($sql,array($username,$login_type));
        if($adb->num_rows($result)>0){
            $lastid = $adb->query_result($result,0,'lastid');
            $query = "update ld_loginhistory set languagetype = ? where login_id = ?";
            $adb->pquery($query,array($languagetype,$lastid));
            //切换语言类型后重新生成缓存
            CreateMobileLanguageCache('yes');
            getMobileLanguageType($current_user->id);
        }
        //重新返回设置信息
        $entity = $this->getCRMModules();
        crm_load_class_file('cls_ReportDetailInfoWX','WeiXinApp/modules/Dashboard');
        $reportobj = new cls_ReportDetailInfoWX(null);
        $commonmodules = $reportobj->getcommonmodules();
        foreach($commonmodules['list'] as $key=>$info){
            if ($key > 4) {
                unset($commonmodules['list'][$key]);
            }
        }
        
        if($MobileLanguageType == 'en' && $_REQUEST['commonlyused'] != 'yes'){
            $commonmodules['label'] = '';
        }else{
            $commonmodules['label'] = getMobileFixedLabel('COMMON');
        }
        
        $entity['commonmodules'] = $commonmodules;
        
        return $entity;
    }
    //duan 20221010 获取移动端‘设置’页面的翻译
    public function getSettingArrFixedlabel(){
        if($_REQUEST['commonlyused'] == 'yes'){ //常用模块设置
            $setting_label_arr=array(
                'MORE',//更多
                'SAVE',//保存
                'COMMONMODULESETTINGS',//常用模块设置
                'COMMONMODULESBESET',//常用模块最多只能设置7个
                'SUCCESSFULLYSAVED',//保存成功
                );
        }else{
            $setting_label_arr = array(
                'SEARCHMODULENAME',//搜索模块名称
                'CANCEL',//取消
                'APPSETTINGS',//设置
                'FUNCTIONMODULEDISPLAYSETTINGS',//功能模块显示设置
                'DISPLAYSETTINGS',//显示设置
                'NOMODULEPERMISSION',//暂无模块查看权限
                'PUSHMESSAGEREMINDER',//推送消息提醒
                'PUSHMESSAGETOWECHAT',//推送的通知和消息到个人的企业微信中
                'PERSONALDATA',//个人资料
                'CHANGELOGINPASSWORD',//修改密码
                'MAILLIST',//通讯录
                'ENTERPRISEWECHATCUSTOMERS',//企业微信客户
                'LANGUAGE',//语言
                'VERSIONSWITCHING',//版本切换
                'CURRENTVERSION',//当前版本
                'TELEPHONECUSTOMERSERVICE',//电话客服
                'APPWORKBENCH',//工作台
                'APPFUNCTION',//功能
                'staydo',//待办
                'OFTENUSEREPORTWORD',//报表
                'Quickly_create',//快速创建
                'NO',//否
                'YES',//是
                'CODEINFORMATIONINVALID',//当前扫码信息无效
                'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
                'WECHATVERSIONLOWPLEASEUPGRADE',//企业微信版本过低，请升级
                'DISCUSSIONGROUP',//讨论组
                'FAILEDTOGETURL',//获取URL失败
                'CANNOTOPENINMOBILE',//当前模块移动端无法打开
                'SEARCHNEW',//搜索
                'BLOCKDISPLAY',//区块显示
                'LISTDISPLAY',//列表显示
                'MYSCHEDULE',//我的日程
                'OTHERSCHEDULE',//他人日程
                'LOGOUT',//退出登录
                'RECORDINGPERMISSIONMANAGEMENT',//录音权限管理
                'CallRecording',//通话录音
                'ABOUT',//关于
                'PRIVACYPOLICY',//隐私政策
                'ENTERPRISEACCOUNT',//企业号
                'SET',//设置
                'SUREWANTEXIT',//确定退出?
            );
        }
        //获取翻译字符串
        $setting_fieldlabel_arr = TransFieldlabel($setting_label_arr);
        //根据不用的移动端类型返回不同的翻译
        global $weixin_user;
        if(!empty($weixin_user)){
            $environment = $weixin_user->environment;
            if($environment == 'dingtalk'){
                $setting_fieldlabel_arr['PUSHMESSAGETOWECHAT'] = getFixedLabel('PUSHMESSAGETODING');
                $setting_fieldlabel_arr['PUSHMESSAGEREMINDER'] = getFixedLabel('DINGTALKRECEVIEREMINDS');
            }else if($environment == 'yunzhijia'){
                $setting_fieldlabel_arr['PUSHMESSAGETOWECHAT'] = getFixedLabel('PUSHMESSAGETOCLOUDHUB');
                $setting_fieldlabel_arr['PUSHMESSAGEREMINDER'] = getFixedLabel('CLOUDHUBRECEVIEREMINDS');
            }else{
                $setting_fieldlabel_arr['PUSHMESSAGEREMINDER'] = getFixedLabel('WECHATRECEVIEREMINDS');
            }
        }
        return $setting_fieldlabel_arr;
    }
    //移动端报表页面的翻译字符串
    public function getReportFiexedlabel(){
        $report_label_arr=array(
            'SEARCHREPORTNAME',//搜索报表名称
            'REPORTFORMMODULEDISPLAYSETTINGS',//报表模块显示设置
            'DISPLAYSETTINGS',//显示设置
            'NOREPORTVIEWING',//暂无报表查看权限
            'APPWORKBENCH',//工作台
            'APPFUNCTION',//功能
            'staydo',//待办
            'OFTENUSEREPORTWORD',//报表
            'APPSETTINGS',//设置
            );
        //获取翻译字符串
        $report_fieldlabel_arr = TransFieldlabel($report_label_arr);
        return $report_fieldlabel_arr;
    }
    //移动端选人控件翻译字符串
    public function getChooseUserFiexedlabel(){
        $user_label_arr=array(
            'LBL_DISTRIBUT_HIGHSEAS',//公海分配
            'APPROVER',//审批人
            'ALLOCATE',//分配
            'SHARE',//共享
            'SELECTUSER1',//选择用户
            'EXECUTORS',//执行人
            'CCRANGE',//抄送范围
            'REVIEWER',//点评人

            'COLLEAGUE',//同事
            'Sector',//部门
            'VIEWBYORGANIZATION',//按组织架构查看
            'NOCOLLEAGUEDATA',//没有同事数据
            'Quit',//离职
            'NODEPARTMENTDATA',//没有部门数据
            'SELECTONECOLLEAGUE',//请至少选择一个同事
            'AREYOUSURETOASSIGN',//确定将
            'ASSIGNTO1',//分配给
            'ASSIGNSUCCEEDED',//分配成功
            'HIGHSEASASSIGNSUCCEEDED',//公海分配成功
            'SHARINGSUCCEEDED',//共享成功
            'COLLEAGUES',//个同事
            'COMPANYWIDE',//全公司
            'RESET',//重置
            'SEARCHFORCOLLEAGUES',//搜索同事
            'SEARCHFORDEPARTMENT',//搜索部门
            'DEPARTMENTMEMBERS',//部门成员
            'choose',
            'nodata',//没有数据
            'APPROVALSUCCEEDED',//审批成功
            'PleaseSelectOneRelatedModule',//请至少选择一个相关信息模块
            );
        //获取翻译字符串
        $user_fieldlabel_arr = TransFieldlabel($user_label_arr);
        return $user_fieldlabel_arr;
    }
    //移动端修改密码界面翻译字符串
    public function getPasswordFixedlabel(){
        $pwd_label_arr = array(
            'OLDPASSWORD',//旧密码
            'NEWPASSWORD',//新密码
            'pleaseenter',//请输入
            'Password_confirmation',//确认密码
            'SAVE',//保存
            'CHANGEPASSWORD',//修改密码
            'WARMPROMPT',//温馨提示
            'OLDPASSWORDCANOTEMPTY',//旧密码不能为空
            'ENTERNEWPASSWORD',//新密码不能为空
            'ENTERNEWPASSWORDAGAIN',//确认密码不能为空
            'PMINCONSISTENTPASSWORD',//新密码和确认密码不一致
            'LOADING',//加载中...
            'SUCCESSFULLYMODIFIED',//修改成功
        );
        //获取翻译字符串
        $pwd_fieldlabel_arr = TransFieldlabel($pwd_label_arr,'no');
        $data['arrFixedLabel'] = $pwd_fieldlabel_arr;
        return $data;
    }
    
    //获取全局查找翻译字符串
    public function getGlobalSearchFixedlabel(){
        $search_label_arr = array(
            'nodata',//没有数据
            'NOMOREDATA',//没有更多数据
            'QUICKFIND',//全局查找
            'SETGLOBALDISCOVERYMODULE',//设置全局查找模块(仅显示已选模块前20条数据)
            'RECORDSINTOTAL',//共%d条记录
            'NONUMBERTODIAL',//没有可拨打号码
        );
        //获取翻译字符串
        $search_fieldlabel_arr = TransFieldlabel($search_label_arr);
        $search_fieldlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$search_fieldlabel_arr);
        $data['arrFixedLabel'] = $search_fieldlabel_arr;
        return $data;
    }
    //获取工作汇报翻译字符串
    public function getWorkhomeFixedlabel(){
        $label_arr=array(
            'CANCEL',//取消
            'ALL',//全部
            'nodata',//没有数据
            'NOMOREDATA',//没有更多数据
            'NOTMPDATA',//没有%s数据
            'NOMORETMPDATA',//没有更多%s数据
            'RETURN',//返回
            'CONFIRMED',//确定
            'COOPERATIVEWORKTITLE',//一天的工作开始于前一天晚上，创建工作汇报吧！
            'COOPERATIVEWORKTITLEMOB',//一天的工作开始于前一天晚上
            'SEARCHNEW',//搜索
            'BLOG',//微博
            'LOG',//日志
            'LBL_WEEKLYSCHEMES',//周计划
            'LBL_MONTHLYSCHEMES',//月计划
            'TASK',//任务
            'RECORDSINTOTAL',//共%d条记录
            'LBL_COOPERATIVEWORK',//工作汇报
            'COMMENTNOW',//现在点评
            'ReportResults',//汇报结果
            'Reply',//回复
            'FORWARDING',//转发
            'DELETE',//删除
            'SUREWANTDELETE',//确定要删除吗？
            'DELETESUCCESSFUL',//删除成功
            'EDIT',//编辑
        );
        //获取翻译字符串
        $fixedlabel_arr = TransFieldlabel($label_arr);
        $fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
        $fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
        $fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);//共%d条记录
        
        return $fixedlabel_arr;
    }
    //获取工作汇报列表翻译字符串
    public function getWorkListFixedlabel(){
        $label_arr=array(
            'COMMENTNOW',//现在点评
            'ReportResults',//汇报结果
            'CCRANGEAPP',//抄送范围：
            'zhang',//张
            'Attachment',//附件
            'SIGNIN',//签到
            'ASSOCIATEDCUSTOMERS',//关联客户
            'ASSOCIATECONTACT',//关联联系人
            'ASSOCIATEDPRODUCTS',//关联产品
            'Reply',//回复
            'FORWARDING',//转发
            'DELETE',//删除
            'EDIT',//编辑
            'SUREWANTDELETE',//确定要删除吗？
            'UNDERIMPLEMENTATION',//执行中
            'TIMEDOUT',//已超时
            'COMPLETED',//已完成
            'CANCELED',//已取消
            'NOCOMMENTS',//未点评
            'PREVIEW',//预览
            'DOWNLOAD',//下载
            'CANCEL',//取消
        );
        //获取翻译字符串
        $fixedlabel_arr = TransFieldlabel($label_arr);
        return $fixedlabel_arr;
    }
    
    //获取工作汇报详情页的翻译
    public function getWorkDetailFixedabel(){
        $label_arr=array(
            'NOCOMMENTS',//未点评
            'UNDERIMPLEMENTATION',//执行中
            'TIMEDOUT',//已超时
            'COMMENTNOW',//现在点评
            'ReportResults',//汇报结果
            'CCRANGEAPP',//抄送范围：
            'DATE',//日期
            'zhang',//张
            'COMMENTSIMMEDIATE',//以下为直属领导的点评
            'KEYTIMEREPLIES',//以下为关键时间点的回复
            'Attachment',//附件
            'SIGNIN',//签到
            'ASSOCIATEDCUSTOMERS',//关联客户
            'ASSOCIATECONTACT',//关联联系人
            'ASSOCIATEDPRODUCTS',//关联产品
            'Reply',//回复
            'FORWARDING',//转发
            'DELETE',//删除
            'DETAILINTERFACE',//明细界面
            'COLLEAGUES',//个同事
            'NEW',//新增
            'EDIT',//编辑
            'SUREWANTDELETE',//确定要删除吗？
            'REQUESTABORTED',//请求失败
            'SINGINADDRESS',//签到地址
            'DELETESUCCESSFUL',//删除成功
            'FILETYPENOTSUPPORTED',
            'NOTTOEXIST',//没有
        );
        //获取翻译字符串
        $fixedlabel_arr = TransFieldlabel($label_arr);
        return $fixedlabel_arr;
    }

    public function getReportUserList(){
        $list=$this->model->getReportUserList();
        
        $setting_label_arr=array(
            'CCRANGE',//抄送范围
        );
        //获取翻译字符串
        $setting_fieldlabel_arr = TransFieldlabel($setting_label_arr);
        $list['arrFixedLabel'] = $setting_fieldlabel_arr;
        return $list;
    }
}
