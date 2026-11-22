<?php


class cls_DetailViewWX
{
    protected $module;
    protected $action;
    public $focus;
    public $jsonArr;
    protected $record;
    protected $disp_view = array('CreateView' => 'create_view', 'DetailView' => 'detail_view', 'EditView' => 'edit_view');
    protected $disp_mode = array('CreateView' => 'create', 'DetailView' => 'detail', 'EditView' => 'edit');
    protected $relatedCreationInfo = '';//产品分录标示当前新增界面属于关联新增，并将关联信息暂存20170406
    public $orginmodule;

    public $actionname;
    private $effectcolumn_arr;


    public function __construct($module)
    {
        //editor:gyq_123 reason:允许module传空值  2019/6/18 15:57 ID1000512
        if (!empty($module)) {
            $this->module = $module;
            $this->orginmodule = $module;//记录初始模块名
            $this->action = $_REQUEST['action'];  //CreateView EditView DetailView
            $this->actionname = $_REQUEST['action'];
            $this->focus = cls_Instance::get_module_Instance($module);
        }
        global $display_mode_WX;
        $this->disp_mode = $display_mode_WX;
    }

    public function common_getInfo()
    {
        global $weixin_user,$adb,$PlatformMC,$current_user,$adb;
        $getQrcode = $_REQUEST['getQrcode'];
        //zxm 2021-0413 详情页点二维码字段 击生成二维码的操作
        if($getQrcode=='yes'){
            $_REQUEST['recordid'] = $_REQUEST['record'];
            require_once (globalStatic::$root_directory.'modules/lingdang/getFieldQrCode.php');
        }
        //zxm 2021-0406 列表页的【更多】操作
        $fromList = $_REQUEST['fromList'];
        //zxm 2021-0406 列表页的【更多】操作
        if($fromList=='yes'){
            $this->record=$_REQUEST['record'];
            $this->focus->id=$_REQUEST['record'];

            if ($this->module == 'Accounts'||$this->module == 'Leads') {
                global $static_publicaccount;
                if($this->module == 'Accounts')
                    $sql='select publicaccount from ld_account where accountid=? ';
                else
                    $sql='select publicaccount from ld_leads where leadsid=? ';

                $tmpresult=$adb->pquery($sql,array($_REQUEST['record']));

                $static_publicaccount=$adb->query_result($tmpresult,0,'publicaccount');

                $fromListRes['publicaccount']= $static_publicaccount;

            }

            $focus = $this->focus;
            $focus->retrieve_entity_info($focus->id,$focus->module_name);

            $this->init_detailButton();
            $fromListRes['list2'] = $this->jsonArr['list2'];
            //2024-10-10 按钮list，目前先只放自定义按钮的信息
            $init_btnlist = [];
            $all_detailbtn_arr = $this->focus->logic->getAllDetailButtons();
            foreach ($all_detailbtn_arr as $btnkey => $btninfo) {
                if($btninfo['custombtn'] == 'yes' && $btninfo['permit'] == 'yes'){
                    if(in_array(strtolower($btnkey),$this->jsonArr['list2']) || in_array($btnkey,$this->jsonArr['list2'])){
                        $init_btnlist[strtolower($btnkey)] = $btninfo;
                    }
                }
            }

            $fromListRes['btnList'] = $this->jsonArr['btnList'] = $init_btnlist;

            if(!empty($focus->fieldobj)){
                $smownerfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
                if(!empty($smownerfieldinfo)){
                    $smownerfieldname = $smownerfieldinfo->getFieldName();
                }
            }

            $fromListRes['assigned_user_id']=$focus->column_fields[$smownerfieldname];
            if ($this->module == 'CashBill') {
                $fromListRes['columnfields_value']=$this->focus->column_fields;
            }

            //更多-是否提示产品被禁用
            $tmpwithdetail = 'no';
            if ($this->module == 'CashBill'||$this->module == 'SendCashBill'){
                $sourcemodules = getSourceModule($this->module);
                $isSourceModule = $this->focus->getSourceField('entitytype',$this->focus->id);
                foreach($sourcemodules as $sourcemoduleinfo){
                    if($sourcemoduleinfo['entitytype']==$isSourceModule&&$sourcemoduleinfo['withdetail']=='yes'){
                        $tmpwithdetail='yes';
                        break;
                    }
                }
            }
            else if(get_file_address($this->module,"ProductDetails")){
                $tmpwithdetail = 'yes';
                if($this->module=='ServiceCharge')
                {
                    $deployarray_325=getSys_deploy(325);
                    if(strtolower($deployarray_325['deploy_value']) == 'contacts'){
                        $tmpwithdetail = 'no';
                    }
                }
            }
            //zkt 20221122 BUG0058645kfbcrm企业微信---单据列表查看页面，点击更多中的复制，没有提示产品禁用----点金单据详情，点更多下的复制，才有提示（详情见附件）
            $noshowdiscontinuedproduct = 'no';
            if($tmpwithdetail == 'yes'){
                $deployarray_82=getSys_deploy(82);//单据分录中调用产品资料时是否显示无效的产品。0:否，1:是
                if($deployarray_82['deploy_value']=='0'){
                    $noshowdiscontinuedproduct = 'yes';
                }
            }
            $fromListRes['sys']["isCheckDuplicate"]=$noshowdiscontinuedproduct;
            ConvertTojsonString(1, $fromListRes, 'success');
        }
        $record = $_REQUEST['record'];
        if (isset($_REQUEST['CheckPermitted']) && $_REQUEST['CheckPermitted'] == 'yes') {
            $this->focus->retrieve_entity_info($_REQUEST['record'], $this->module);
            //duan 20230221 移动端查看权限
            if($this->module=='PublicAnnouncement')
            {
                $sql='select userid from ld_receipts where id=? and userid=?';
                $announceresult=$adb->pquery($sql,array($_REQUEST['record'],$current_user->id));
                if($adb->num_rows($announceresult)>0)
                {
                    $display='yes';
                }
            }
            if($display!='yes'){
                $display = isPermitted($this->module, 'DetailView', $_REQUEST['record']);
            }
            //chj 2021/1/20 44383: （企业微信移动端-kfbcrm）成员yhc没有查看其它成员单据详情权限，点击公告单据时，页面一直转圈，没有出现“您没有权限查看其他成员的单据”的提示；（点击时就应该有提示信息）
            //if ($this->module == 'PublicAnnouncement') $display = 'yes';
            if ($display == 'no') {
                ConvertTojsonString('-1', array(), getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE'));
            } else {
                ConvertTojsonString('1', array(), 'success');
            }
        }

        $functionName = 'get_' . $this->action;
        if (isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'yes') {
            $weixin_user->action = 'is_duplicate';
            $functionName = 'get_EditView';
            $this->action = 'EditView';
        }
        //duan 20221018 获取移动端翻译字符串
        if($this->action == 'EditView'|| $this->action == 'CreateView'){
            $this->getCreateviewFixedlabel();
        }else{
            $this->getDetailviewFixedlabel();
        }
        //获取不同请求的不同内容
        $outputinfo = $this->$functionName();
        //小程序商城 获取字段信息
        if(isset($_REQUEST['fromldmall'])&&$_REQUEST['fromldmall']=='yes'&&$this->module=='SalesOrder'){
            return $outputinfo['list'];
        }
        $outputinfo['version'] = getVersionInfo();
        //editor:gyq_75 reason:为了方便小程序读取模块名 2018/7/30 13:43
        $action_transfer = array('EditView' => getFixedLabel('EDIT'), 'CreateView' => getFixedLabel('NEW'), 'DetailView' => getFixedLabel('details1'));
        //editor:gyq_104 reason:方便其他方法更改page_title  2019/3/13 13:46
        if (empty($outputinfo['page_title'])){
            // 手机端微信小程序链接模块中新增单据的时候左上角显示的是源单名称
            require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
            $action_label = $action_transfer[$this->action];
            if (isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'yes') {
                $action_label = getFixedLabel('COPY');
            }
            $outputinfo['page_title'] = cls_LinkModuleCustom::getLinkModuleCustomTitle($this->module) . '-' . $action_label;
            // $outputinfo['page_title'] = getTranstab($this->module) . '-' . $action_transfer[$this->action];
        }

        // 2020 1221 zxm 0043299: （https://61mis.com/kfbcrm [^]）服务小程序，扫码登陆后，客户服务自助平台中“客户服务单-新增”标签应该修改为“我要报修”标签。预期结果：新增界面标签应该根据模块设置中的客户服务自助平台标签设置显示
        if($_REQUEST['miniprogram']=='zizhufuwu'&&$this->module=="HelpDesk" && $this->action=="CreateView"){
            global $MobileLanguageType;
            $query = 'select id,modulename,type,mplabel,mplabel_en,presence from ld_weixinmp_module where modulename=? AND type="create" order by sequence';
            $result = $adb->pquery($query,[$_REQUEST['module']]);
            $outputinfo['page_title'] = $MobileLanguageType=='en'?$adb->query_result($result, 0, 'mplabel_en'):$adb->query_result($result, 0, 'mplabel');
        }
        $outputinfo['module_title'] = getTranstab($this->module);
        if($this->module == 'Leads'){
            $outputinfo['acc_modulename'] = getTranstab('Accounts');
            $outputinfo['pot_modulename'] = getTranstab('Potentials');
        }
        //判断条件
        $validatasave = getValidataSave($this->module);
        if ($validatasave == null) $validatasave = '';
        $outputinfo['validatasave'] = $validatasave;
        //单据推进管理
        if($_REQUEST['record']>0&&$this->action=='DetailView'){
            crm_load_class_file('cls_module_advance','modules/Settings');
            $cls_module_advance = new cls_module_advance($this->module);
            $outputinfo['advancestage'] = $cls_module_advance->getWeiXin($_REQUEST['record']);

        }
        //布局规则
        crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
        $fieldruleobj = cls_fieldrule::getInstance($this->module);
        $outputinfo['fieldrulelist'] = $fieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发字段

        //客户001判断
        if(isKehu001ServerPc() == 'yes'){
            // require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
            $wx_authinfo=doCorpInfo("get_auth_info",array());
            $wx_agentid="";
            $wx_corpid="";
            if($wx_authinfo!=''){
                $wx_auth_arr=  json_decode($wx_authinfo,true);
                $wx_agentid=$wx_auth_arr['crm']['auth_info']['agent'][0]['agentid'];
                $wx_corpid=$wx_auth_arr['crm']['auth_corp_info']['corpid'];
            }
            $outputinfo['app']["agentid"]=$wx_agentid;
            $outputinfo['app']['iskehu001']=isKehu001ServerPc();
        }
        //基础信息
        $outputinfo['basicsinfo']['hiddentime'] = time();//服务器时间
        //共享 zxm 2021-0708  增加tab共享  判断共享tab是否显示  是否有相关模块 是否开启字段
        $fieldinfo= $this->focus->fieldobj->getFieldInfoobjBykey("columnname",'team_memberid');
        $rel_list = isPresentRelatedLists($this->module);
        $outputinfo['defaultSetting']['SharedUsers']='no';
        if(in_array('SharedUsers',$rel_list)&&$fieldinfo){
            $outputinfo['defaultSetting']['SharedUsers'] = "yes";
            $rel_list_flip = array_flip($rel_list);
            $outputinfo['defaultSetting']['SharedUsersRelatedId'] = $rel_list_flip['SharedUsers'];
        }
        if($this->action == 'EditView'){
            //ls 2021-12-22 移动端已批准已拒绝的单据，编辑后重新保存时，如果没有选择审批流程，则给予提示信息
            $approveobj=Approve::getInstance($this->module);
            $status = $approveobj->getApproveStatus($this->focus->column_fields['approvestatus']);
            if (($status == 2 || $status == 3) && $approveobj->recordAgainSubmit($this->module)) {
                $outputinfo['defaultSetting']['ResetApprovestatus']='yes';
            }
        }
        // XUQIU20240930-02 duan 20241008 增加模块自定义设置参数获取
        if($this->action == 'EditView'|| $this->action == 'CreateView'){
            $module_setting = getModuleSettingBytype($this->module,'editview');
            $outputinfo['module_setting'] = $module_setting;
        }

        //zxm 2022-02-25【客户明细界面，增加联系人展示信息】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002527
        //客户模块、供应商模块、服务收费管理模块  获取客户关联的联系人列表  获取ID 名字lastname 头像imagename
        //BUG0054663 zxm 20220804企业微信移动端，客户单据查看详情界面，若当前成员没有联系人模块查看权限时，联系人区块应该不显示
        if(in_array($this->orginmodule,['Accounts','ServiceCharge','Vendors'])&&vtlib_isModuleActive('Contacts')){
            $outputinfo['relatedInfo'] = $this->getContactsByRecord($this->orginmodule,$_REQUEST['record']);
        }

        // diony 20220719 设置移动端单据详情界面相关模块是否横向显示
        $getdeploy_350 = getSys_deploy('350');
        $deployvalue_350 = $getdeploy_350['deploy_value'];
        if($this->action == 'DetailView' && $deployvalue_350==0){
            //wyt 220714 【1000013 移动端：明细界面，标签优化，横向滚动，相关信息直接放开，放在日志之后（特殊模块除外）】
            //判断是否有明细
            $labelSwitching = [];
            if(get_file_address($this->module,'ProductDetails') || get_file_address($this->module,$this->module."DetailFieldsHtml")){
                $labelSwitching['Entry'] = ['key'=>'detailmx','name'=>'Entry','label'=>getFixedLabel('DETAILAPP'),'class'=>''];
            }
            if($outputinfo['entry'] && $outputinfo['entry']['worksheetlist']){
                $labelSwitching['Entry'] = ['key'=>'detailmx','name'=>'Entry','label'=>getFixedLabel('ACCESSORY'),'class'=>''];
                $labelSwitching['Entry_product'] = ['key'=>'worksheetdetailmx','name'=>'Entry_product','label'=>getFixedLabel('PRODUCTS'),'class'=>''];
            }
            $labelSwitching['Detail'] =['key'=>'detailxq','name'=>'Detail','label'=>getFixedLabel('DETAIL1APP'),'class'=>'ldnavbar-item-active'];
            if (empty($PlatformMC['type_mini'])) {
                if($outputinfo['defaultSetting'] && $outputinfo['defaultSetting']['wechatsession'] && $outputinfo['defaultSetting']['wechatsession'] == 'yes'){
                    $labelSwitching['WechatSession'] =['key'=>'detailhh','name'=>'WechatSession','label'=>getFixedLabel('SESSION'),'class'=>''];
                }
            }
            //加载相关信息页签内容
            $is_rel_list = isPresentRelatedLists($this->orginmodule);
            $is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
            $relatecustomreports=Detail_Edit_View::getRelatedCustomReport($this->orginmodule);
            // dump($is_rel_list);
            foreach ($is_rel_list['more'] as $item){
                $r_module = $item['related_module'];
                $r_name = $item['related_module'];
                $r_label = $item['related_modulelabel'];
                $r_id = $item['related_id'];
                $r_btn = $item['related_button'];
                if($r_btn != ''){
                    $r_btn = 'yes';
                }
                else{
                    $r_btn = 'no';
                }
                if($r_module == 'SharedUsers'){
                    $r_module = 'detailtd';
                    $r_name = 'Teammember';
                    $r_label = getFixedLabel('TEAM');
                }
                if($r_module == 'trends'){
                    $r_module = 'detaildt';
                    $r_name = 'Trends';
                    $r_label = getFixedLabel('trends');
                }
                if($r_module == 'ViewHistory'){
                    $r_module = 'detailrz';
                    $r_name = 'Log';
                    $r_label = getFixedLabel('LOG');
                }
                if(in_array($r_module,array('publicaccount_log', 'AccountHierarchy', 'ChangeView', 'PriceBooks', 'Productbom', 'Emails', 'CommunicationLog', '项目甘特图', 'Redemption','ReadRecord','ProjectAbstract', 'Reminds', 'RECEIVABLESFORECAST', 'ContactsHierarchy', 'Download_Browse_Record'))){
                    continue;
                }
                if(array_key_exists($r_id,$relatecustomreports))
                {
                    //自定义报表
                    $default_report=0;
                    if($relatecustomreports[$r_id]['related_coltable']=='crmlink')
                    {
                        $default_report=1;
                    }
                    if($relatecustomreports[$r_id]['type']=='datacategory_templatelink')
                    {
                        $url='CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key='.$relatecustomreports[$r_id]['name'].'&default_report='.$default_report.'&report_name='.$relatecustomreports[$r_id]['label'];


                    }
                    else
                    {
                        $url='CustomReport/JsReport/index.php?crm_report_key='.$relatecustomreports[$r_id]['name'].'&default_report='.$default_report.'&report_name='.$relatecustomreports[$r_id]['label'];
                    }
                    $labelSwitching[$r_module]=array('key'=>$r_module,'related_id' => $r_id,'label'=>$r_label
                    , 'name' => $relatecustomreports[$r_id]['label'],'type'=>'relatecustomreport'
                    ,'module'=>$url);
                    continue;

                }
                $labelSwitching[$r_module] = ['key'=>$r_module,'name'=>$r_name,'label'=>$r_label,'class'=>'','related_id'=>$r_id,'btn'=>$r_btn];
            }
            $outputinfo['labelSwitching'] = array_values($labelSwitching);

            // BUG0073466 diony 20231007 企业微信移动端，销售线索相关信息列表界面，点击“联系人图谱”界面一直显示加载中
            if(vtlib_isModuleActive('Contacts')){
                $outputinfo['relatedContactsInfo'] = $this->getContactsByRecord($this->orginmodule,$_REQUEST['record']);
            }
        }

        // txy 20230728 设置移动端客户/服务收费管理单据详情页签上方是否显示联系人区块
        //isshow_quick_contacts:"yes"表示显示，“no”表示不显示
        $getdeploy_461 = getSys_deploy('461');
        $deployvalue_461 = $getdeploy_461['deploy_value'];
        $outputinfo['isshow_quick_contacts'] = 'yes';
        if($this->action == 'DetailView' && $deployvalue_461==1){
            $outputinfo['isshow_quick_contacts'] = 'no';
        }

        //ls 20221231  XUQIU1000922：表单码-分录可编辑（表单码返回值字段处理）
        if ($_REQUEST['is_qrcode_expand'] == 'yes' && !empty($_REQUEST['qrcodeid'])) {
            crm_load_class_file('cls_QrcodeField', 'WeiXinApp/qrcodepro');
            $QrcodeField = new cls_QrcodeField();
            $qrcodeid = $_REQUEST['qrcodeid'];
            $outputinfo = $QrcodeField->qrcodeEditReturn($qrcodeid,$outputinfo,$this->focus,$this->module);
            $outputinfo['is_qrcode_expand'] = 'yes';

            //duan 20240911 表单码进入小程序,获取参数
            crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
            $workobj = new WorkReportControllerWX();
            $outputinfo['global_setting'] = $workobj->getCRMSetting('index');
        }

        //duan 20230719 XUQIU1000232 审批必填字段编辑时仅显示部分字段
        if($_REQUEST['isApproveMandatoryField'] == 'yes' && !empty($_REQUEST['approveMandatoryFieldData'])){
            $approveinfo = ldcrm_json_decode($_REQUEST['approveMandatoryFieldData']);
            crm_load_class_file('cls_ApproveMandatoryField','modules/Approve');
            $mandatoryfieldobj = cls_ApproveMandatoryField::getInstance($this->module);
            $outputinfo = $mandatoryfieldobj->getEditviewReturn($record,$approveinfo,$outputinfo);
        }
        //duan 20240827 推进进入大编辑时，增加新返回值
        if(isset($_REQUEST['advance_field']) && !empty($_REQUEST['advance_field_value'])){
            $outputinfo['miniedit_fieldrule'] = 'fromadvance';
        }

        //判断模块分录类别
        crm_load_class_file('cls_ModuleEntryType', 'WeiXinApp/WeiXin_common');
        $outputinfo['entry_type'] = cls_ModuleEntryType::get_module_entry_type($this->module);

        // diony 2023-09-21 水印
        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $watermark_txt = $MenuUtilsObj->getwatermark_setting();
        $outputinfo['watermark_txt'] =$watermark_txt;
        //wsh 2024-06-14 XUQIU20240514-06 企业日志--操作日志：新增操作行为：查看详情
        if ($this->action == 'DetailView'){
            crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
            cls_OperationLogs::saveLogs($this->module,'ViewDetail',$record,'');
        }
        ConvertTojsonString(1, $outputinfo, 'success');
    }
    //获取客户关联的联系人列表  获取ID 名字lastname 头像imagename
    protected function getContactsByRecord($module,$record){
        global $adb;
        //查询联系人ID
        $contactid_key = 'contactid';
        $relatedid_key = 'accountid';
        $relatedmodule = 'Contacts';
        if($module=='Vendors'){
            $contactid_key = 'vendorcontactsid';
            $relatedid_key = 'Vendorid';
            $relatedmodule = 'VendorContact';
        }
        //获取 relation_id
        $relation_sql = "select relation_id from ld_relatedlists where related_tabid=? and tabid=?";
        $relation_res = $adb->pquery($relation_sql,array(getTabid($relatedmodule),getTabid($module)));
        $related_id = $adb->query_result($relation_res,0,0);
        crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
        $mobj = new cls_ListViewWX($relatedmodule);
        $contact_nums = 0;
        if(!empty($record)){
            $contact_sql = $mobj->getRecordContentSql($record,$relatedid_key,$relatedmodule);
            $contact_res = $adb->pquery($contact_sql);
            $contact_nums = $adb->num_rows($contact_res);
        }
        $permit_delete = isPermitted($relatedmodule,'Delete');
        $permit_create = isPermitted($relatedmodule,'Create');
        $contactlist = [];
        $url = curPageURL();
        //$url = str_replace('WeiXinApp/','',$url);//移动端打印模板中图片路径设置  zxm2022-0126
        $site_url = explode('WeiXinApp',$url);
        $corpurl = $site_url[0];
        if($contact_nums>0){
            for($i=0;$i<$contact_nums;$i++){
                $temp_contactid = $adb->query_result($contact_res,$i,$contactid_key);
                $contactlist[$i]['id'] = $temp_contactid;
                $contactlist[$i]['permit_delete'] = $permit_delete;//是否有删除权限
                $contactlist[$i]['imagename'] = $corpurl.'themes/images/defaultuser.png';
                $contactlist[$i]['lastname'] = $adb->query_result($contact_res,$i,'lastname');
                //查询所有附件
                $attachment_sql = "select a.attachmentcolumnname,b.storage_location,b.path,b.newfile_name,b.cloud_path from ld_seattachmentsrel a left join ld_attachments b on a.attachmentsid=b.attachmentsid where a.crmid=".$temp_contactid ." and a.attachmentcolumnname='imagename' limit 1 ";
                $attachment_res = $adb->pquery($attachment_sql);
                $attachment_nums = $adb->num_rows($attachment_res);
                if($attachment_nums>0){
                    $temp_storage_location = $adb->query_result($attachment_res,0,'storage_location');
                    $temp_path = $adb->query_result($attachment_res,0,'path');
                    $temp_newfile_name = $adb->query_result($attachment_res,0,'newfile_name');
                    $temp_cloud_path = $adb->query_result($attachment_res,0,'cloud_path');
                    if($temp_storage_location == "cos"){
                        $contactlist[$i]['imagename'] = $temp_cloud_path;
                    }
                    if($temp_storage_location == "local"){
                        $contactlist[$i]['imagename'] = $corpurl . $temp_path.$temp_newfile_name;
                    }
                }
            }
        }
        return [[
            'list'=>$contactlist,
            'pagecount'=>$contact_nums,
            'modulename'=>$relatedmodule,
            'tabname'=>getTranstab($relatedmodule),
            'permit_create'=>$permit_create,
            'related_id'=>$related_id,
        ]];
    }

    protected function get_CreateView()
    {
        $this->set_CreateView();
        return $this->jsonArr;
    }

    //输出
    protected function get_DetailView()
    {
        $this->record = $_REQUEST['record'];
        if($this->record>0){
            //duan 20230221 移动端公告模块需要特殊判断
            if($this->module=='PublicAnnouncement')
            {
                global $adb,$current_user;
                $sql='select userid from ld_receipts where id=? and userid=?';
                $announceresult=$adb->pquery($sql,array($this->record,$current_user->id));
                if($adb->num_rows($announceresult)>0)
                {
                    $display='yes';
                }
            }
            if($display!='yes'){
                $display = isPermitted($this->module, 'DetailView',$this->record);
            }
            //40787: （http://kehu001.com/weixin/kh38567/ [^]）系统设置>参数设置>自动提醒设置：提醒人为“普通用户”，普通用户企业微信手机端点击“消息提醒”可以查看其他成员单据
            if($display !='yes'){
                ConvertTojsonString('-1',array(),getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE'));
            }
        }


        $this->set_DetailView();

        $this->DetailLastExtra();
        return $this->jsonArr;
    }

    protected function set_CreateView()
    {
        if (!empty($_REQUEST['relatedCreationInfo'])) {
            $creationinfo = json_decode($_REQUEST['relatedCreationInfo'], true);
            $fromid = $creationinfo['fromid'];
            $frommodule = $creationinfo['frommodule'];
            crm_load_class_file('cls_RelateCreateCondition', 'include');
            $tmpobj = cls_RelateCreateCondition::getInstance($frommodule, $this->module);
            $tmp = $tmpobj->IsRelateCreate($fromid);
            if ($tmp != 'yes') {
                ConvertTojsonString('error_back', '', $tmpobj->errorreason);
            }

        }
        if (!empty($_REQUEST['externalcontacts'])) {
            $this->get_externalcontacts();
        }
        setObjectValuesFromRequest($this->focus);
        //chj 2021/6/30 46648: 公司自动账套：order ，设置了合同订单自动根据负责人带出渠道，移动端新增时默认没有带出来
        if($this->focus->mode != 'edit'){
            global $current_user;
            crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
            $field = $this->focus->fieldobj->getFieldInfoobjBykey('columnname','smownerid');
            if(!empty($field)){
                $fieldname = $field->getFieldName();
                $_REQUEST['selecttype'] = 'select';
                $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($this->module,$current_user->id, $fieldname);
                $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
                $effectfieldname_arr=[];
                if(!empty($relatedfielddata)){
                    foreach($relatedfielddata as $key => $vals){
                        $this->focus->column_fields[$vals['rawValue']['input_name']] = $vals['rawValue']['value'];
                        $effectfieldname_arr[$vals['rawValue']['input_name']]= $vals['rawValue']['value'];
                    }
                    global $adb;

                    $sql='select ld_field.fieldname from ld_related_field 

                        inner join ld_field 
                        on ld_field.fieldid=ld_related_field.trigger_fieldid
                        where ld_field.tabid=?  group by fieldname';
                    $tmpresult=$adb->pquery($sql,array(getTabid($this->module)));
                    $rows =$adb->num_rows($tmpresult);
                    $effectfieldname1_arr=[];
                    for($i=0;$i<$rows;$i++)
                    {
                        $tmp_effectname=$adb->query_result($tmpresult,$i,'fieldname');

                        if(array_key_exists($tmp_effectname,$effectfieldname_arr))
                        {
                            $tmpvalue=$effectfieldname_arr[$tmp_effectname];

                            $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($this->module,$tmpvalue, $tmp_effectname);
                            $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
                            if(!empty($relatedfielddata)){
                                foreach($relatedfielddata as $key => $vals){
                                    $effectfieldname1_arr[$vals['rawValue']['input_name']]=$vals['rawValue']['value'];
                                    $this->focus->column_fields[$vals['rawValue']['input_name']] = $vals['rawValue']['value'];
                                }
                            }
                        }
                    }

                    for($i=0;$i<$rows;$i++)
                    {
                        $tmp_effectname=$adb->query_result($tmpresult,$i,'fieldname');
                        if(array_key_exists($tmp_effectname,$effectfieldname1_arr))
                        {
                            $tmpvalue=$effectfieldname1_arr[$tmp_effectname];
                            $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($this->module,$tmpvalue, $tmp_effectname);
                            $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
                            if(!empty($relatedfielddata)){
                                foreach($relatedfielddata as $key => $vals){
                                    $effectfieldname1_arr[$vals['rawValue']['input_name']]=$vals['rawValue']['value'];
                                    $this->focus->column_fields[$vals['rawValue']['input_name']] = $vals['rawValue']['value'];
                                }
                            }
                        }
                    }
                }
            }
        }
        //获取编号
        global $adb;
        require_once(globalStatic::$root_directory . '/include/SystemCode/SystemCode.php');
        $value = $this->focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
        if (!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
        $fieldobj = Field::getInstance($this->module, $adb);
        $number_no = $fieldobj->getFieldInfoBykeyValue('uitype', '4', 'columnname');
        $this->focus->column_fields[$number_no] = $value;
        $this->setDefaultValue($this->focus);
        if (!empty($_REQUEST['relatedCreationInfo'])) {

            $this->get_relatedCreationInfo($this->focus, $_REQUEST['relatedCreationInfo']);
        }
        $disp_view = $this->disp_view[$this->action];
        $disp_mode = $this->disp_mode[$this->action];

//        @edit:liushuai,2021-06-24,reason:【ID1000293】企业微信PC端，进入外部联系人聊天窗口界面后，聊天工具栏增加默认显示“当前客户查看详情界面”(不存在新增,这里是给新增页面赋值)
        if (isset($_REQUEST['WXPCCreationInfo']) && $_REQUEST['WXPCCreationInfo'] != '') {
            $WXPCCreationInfo = ldcrm_json_decode(urldecode($_REQUEST['WXPCCreationInfo']));//经地址栏encodeURIComponent传递之后需要urldecode
            if (!empty($WXPCCreationInfo)) {
                foreach ($this->focus->column_fields as $fieldname => $val) {
                    if ($this->module == 'Accounts' && $fieldname == 'description') {//值description是联系人的备注，不是客户的备注
                        continue;
                    }

                    if (isset($WXPCCreationInfo[$fieldname])) {
                        $this->focus->column_fields[$fieldname] = trim($WXPCCreationInfo[$fieldname]);
                    }
                }
                //1、新增客户和首要联系人  2、新增客户  3、新增联系人
            }
        }

        $act_data = $this->getBlockFields($this->module, $disp_view, $disp_mode, $this->focus->column_fields);
        // wyt_220707_1000133_微信小程序附件增加字段显示文件格式信息
        // diony 20220919 优化
        $acceptData = $this->getAccept($this->module);
        foreach($act_data as $act_dataIndex=>$tmpvalueinfo){
            $tmpfieldinfo=$tmpvalueinfo['fieldinfo'];
            foreach($tmpfieldinfo as $tmpfieldinfo_Index=>$tmpvalueinfo){
                if($tmpvalueinfo['bigtype']=='fileattachment'){
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['file_type'] = $acceptData[0];
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['accept'] = $acceptData[1];
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['accept2'] = $acceptData[2];
                }
            }
        }

        if (!empty($_REQUEST['relatedCreationInfo'])) {
            $creationinfo = json_decode($_REQUEST['relatedCreationInfo'], true);
            $frommodule = $creationinfo['frommodule'];
            if($frommodule == 'PurchaseOrder' && $this->module == 'PurchaseBack'){
                foreach($act_data as $act_dataIndex=>$tmpvalueinfo){
                    $tmpfieldinfo=$tmpvalueinfo['fieldinfo'];
                    foreach($tmpfieldinfo as $tmpfieldinfo_Index=>$tmpvalueinfo)
                    {
                        if($tmpvalueinfo['fieldname']=='vendor_id'){
                            $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['readonly'] = 'yes';
                            break;
                        }
                    }
                }
            }
        }
        //XUQIU20240730-07 移动端（微信小程序）日程创建已在日历中点选时间范围，需根据选择的日期定位当前时间。
        //如果如果存在默认值，自动填充默认值
        if($this->module == 'Calendar' && !empty($_REQUEST['calendarChooseDate'])){
            foreach($act_data as $act_dataIndex=>$tmpvalueinfo){
                $tmpfieldinfo=$tmpvalueinfo['fieldinfo'];
                foreach($tmpfieldinfo as $tmpfieldinfo_Index=>$tmpvalueinfo){
                    if($tmpvalueinfo['fieldname']=='date_start'){
                        if($tmpvalueinfo['text'] == ''){
                            $chooseDate = date("Y-m-d",strtotime($_REQUEST['calendarChooseDate'])).' '.date("H:i:s");
                            $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['text'] = $chooseDate;
                            $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['value_name'] = $chooseDate;
                        }
                        break;
                    }
                }
            }
        }
        $this->jsonArr['mainfieldformula']=$this->focus->fieldobj->getFormula();
        $this->jsonArr['list'] = $act_data;
        global $createPage_smownerid;
        $createPage_smownerid=0;//新增界面获取审批流程的审批人

        foreach($act_data as  $act_dataIndex=>$tmpvalueinfo){
            $tmpfieldinfo=$tmpvalueinfo['fieldinfo'];
            foreach($tmpfieldinfo as $tmpvalueinfo)
            {
                if($tmpvalueinfo['uitype']==53){
                    $createPage_smownerid=$tmpvalueinfo['value'];
                    break;
                }
            }
            if($createPage_smownerid>0){
                break;
            }

        }
        //快速创建字段  当所有字段都是快速创建字段时，havequickfields返回no
        $quickcreatelist = cls_StaticCommonFun::jsonQuickCreate($this->module);
        $this->jsonArr['havequickfields'] = (empty($quickcreatelist) || !isset($_REQUEST['wxnoquickcreate'])) ? 'no' : 'yes';//是否包含快速创建字段
        //判断打开快速创建字段或者全部字段
        $this->jsonArr['haveopenallfields'] = 'no';
        if (getTabDuplicate($this->module) == 'yes') {
            $this->jsonArr['haveopenallfields'] = 'yes';
        }
        // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化 tapd:ID1000705
        $this->isOpenSignIn($this->module);
        //end
        $this->DetailLastExtra();
        $this->getApproveStep();
        return $this->jsonArr;
    }

    //初始化详情页信息
    protected function set_DetailView()
    {
        global $current_user, $weixin_user,$adb;
        $this->record = $_REQUEST['record'];
        crm_load_class_file('cls_staticDetailViewWX', 'WeiXinApp/WeiXin_common');
        $focus = $this->focus;
        $disp_view = $this->disp_view[$this->action];
        $disp_mode = $this->disp_mode[$this->action];
        if (!empty($_REQUEST['record'])) {
            $focus->retrieve_entity_info($this->record, $this->module);
            $focus->id = $_REQUEST['record'];
        }
        if ($weixin_user->action == 'is_duplicate') {
            require_once(globalStatic::$root_directory . '/include/SystemCode/SystemCode.php');
            $value = $this->focus->Library('SystemCode')->getModuleSeqNumRecord($_REQUEST['module']);
            if (!$value) $value = getFixedLabel('MSG_AUTO_GEN_ON_SAVE');
            $fieldobj = Field::getInstance($this->module, $adb);
            $number_no = $fieldobj->getFieldInfoBykeyValue('uitype', '4', 'columnname');
            $focus->column_fields[$number_no] = $value;
            //editor:gyq_20190620 reason:单据复制，默认值修改  2019/6/20 11:43 【ID1000517】
            //$smownerfield = $fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
            //$focus->column_fields[$smownerfield->getFieldName()] = $current_user->id;
        }
        $this->get_DetailView_Extra($focus);
        // @edit:dong @date:2020/07/24 @reason: 判断是否开始了定位源单 获取定位的值
        if($this->action == 'EditView'){
            $signintype = 'none';
        }else{
            $signintype = 'boolean';
        }

        if (isset($focus->column_fields['lastname'])) { //转义特殊字符
            $focus->column_fields['lastname'] = htmlspecialchars_decode(htmlspecialchars_decode($focus->column_fields['lastname']));
        }
        $this->jsonArr['mainfieldformula']=$this->focus->fieldobj->getFormula();

        $act_data = $this->getBlockFields($this->module, $disp_view, $disp_mode, $focus->column_fields);
        // wyt_220707_1000133_微信小程序附件增加字段显示文件格式信息
        // diony 20220919 优化
        $acceptData = $this->getAccept($this->module);
        foreach($act_data as $act_dataIndex=>$tmpvalueinfo){
            $tmpfieldinfo=$tmpvalueinfo['fieldinfo'];
            foreach($tmpfieldinfo as $tmpfieldinfo_Index=>$tmpvalueinfo){
                if($tmpvalueinfo['bigtype']=='fileattachment'){
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['file_type'] = $acceptData[0];
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['accept'] = $acceptData[1];
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['accept2'] = $acceptData[2];
                }
                if($tmpvalueinfo['uitype']=='9'){
                    $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['fieldlabel'] = $act_data[$act_dataIndex]['fieldinfo'][$tmpfieldinfo_Index]['fieldlabel'] . '(%)';
                }
            }
        }
        $this->jsonArr['list'] = $act_data;
        //敏感规则
        $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($this->module);
        $needtriggerfield = $cls_fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();
        $needtriggerfield_array = [];
        if(count($needtriggerfield) > 0){
            foreach($needtriggerfield as $tmp_fieldname => $tmpfieldarr){
                for($index = 0;$index<count($tmpfieldarr);$index++){
                    $needtriggerfield_array[] = $tmpfieldarr[$index];
                }
            }
        }
        $needtriggerfield_array = array_values(array_unique($needtriggerfield_array));
        $this->jsonArr['fieldSensitiverule'] = $needtriggerfield_array;
        //$this->jsonArr['list'] = $this->getBlocks($this->module, $disp_view, $disp_mode, $focus->column_fields);

        if($this->isOpenSignIn($this->module,$signintype)){
            $this->get_SignData($focus);
        }

        //2020-07-31 diony 快速创建字段  当所有字段都是快速创建字段时，havequickfields返回no
        $quickcreatelist = cls_StaticCommonFun::jsonQuickCreate($this->module);
        $this->jsonArr['havequickfields'] = (empty($quickcreatelist) || !isset($_REQUEST['wxnoquickcreate'])) ? 'no' : 'yes';//是否包含快速创建字段
        //判断打开快速创建字段或者全部字段
        $this->jsonArr['haveopenallfields'] = 'no';
        if (getTabDuplicate($this->module) == 'yes') {
            $this->jsonArr['haveopenallfields'] = 'yes';
        }

        if ($this->action == 'DetailView') {
            $_REQUEST['weixin_mark'] = 2;//0027105: 微信端项目任务详细信息中项目名称显示有误，
            $this->getMainInfo($focus->column_fields);//获取头部字段
            $this->init_detailButton();
            //2024-10-10 按钮list，目前先只放自定义按钮的信息
            $init_btnlist = [];
            $all_detailbtn_arr = $this->focus->logic->getAllDetailButtons();
            foreach ($all_detailbtn_arr as $btnkey => $btninfo) {
                if($btninfo['custombtn'] == 'yes' && $btninfo['permit'] == 'yes'){
                    if(in_array(strtolower($btnkey),$this->jsonArr['list2']) || in_array($btnkey,$this->jsonArr['list2'])){
                        $init_btnlist[strtolower($btnkey)] = $btninfo;
                    }
                }
            }

            $this->jsonArr['btnList'] = $init_btnlist;

            //$this->init_detailTabInfo();
            //从审批进入明细

            if ($_REQUEST['fromtype'] == 'approve') {
                $this->getApproveInfo();
                if (vtlib_isModuleActive('ModComments') && isPermitted('ModComments', 'Create', '') == 'yes' && $this->module != 'ModComments') {
                    $this->jsonArr['commentpermit'] = 'yes';
                }
            } else {
                $this->getApproveInfo();
                if (vtlib_isModuleActive('ModComments') && isPermitted('ModComments', 'Create', '') == 'yes' && $this->module != 'ModComments') {
                    $this->jsonArr['commentpermit'] = 'yes';
                }
            }
			//列表页返回设置信息,避免从消息提醒进入小程序时错误
            crm_load_class_file('WorkReportControllerWX','WeiXinApp/modules/Home');
            $workobj = new WorkReportControllerWX();
            $this->jsonArr['setting'] = $workobj->getCRMSetting('index');

        } else {

            $this->getApproveStep();
        }
    }

    //获取明细基础字段信息正确方法
    public function getBlocks($module, $disp_view, $mode, $col_fields = '', $info_type = '')
    {
        $block_detail = Array();
        $fieldobj = Field::getInstance($module, $adb);
        $cachemoduleblock = $fieldobj->getBlockInfos();
        $act_data = getBlocks($module, $disp_view, $mode, $col_fields);
        $newData = array();
        $i = 0;
        foreach ($act_data as $blockname => $content) {
            $blockData = array();
            foreach ($content as $linenum => $fieldcontent) {
                $blockData = array_merge($blockData, $fieldcontent);
            }
            array_pop($blockData);
            $newData[$i]['blocklabel'] = $blockname;
            $display_status = 0;
            foreach ($cachemoduleblock as $blockid => $bcontent) {
                if ($bcontent['blocklabel'] == $blockname) {
                    $newData[$i]['display_status'] = $bcontent['display_status'];
                    $display_status = 1;
                    break;
                }
            }
            if ($display_status == 0) {
                $newData[$i]['display_status'] = 1;
            }
            $newData[$i]['fieldinfo'] = $blockData;
            $i++;
        }
        return $newData;
    }


    //给关联单据某些字段赋初值//gyq_26 关系信息新增
    /*public function set_relatedCreationInfo($record,$createmodule){
        $this->focus->retrieve_entity_info($record, $this->module);
        $this->focus->id = $record;
        $this->get_DetailView_Extra($this->focus);
        if (isset($this->focus->column_fields['lastname'])) { //转义特殊字符
            $this->focus->column_fields['lastname'] = htmlspecialchars_decode(htmlspecialchars_decode($this->focus->column_fields['lastname']));
        }
        $RelatedList = getRelateCreatePostValue($createmodule,$this->module,$this->focus->column_fields);
        return json_encode($RelatedList);
    }*/
    //获取关联单据某些字段初值//gyq_26 关系信息新增
    public function get_relatedCreationInfo($focus, $creationinfojson)
    {

        crm_load_class_file('cls_module_uitype', 'include/fields');
        crm_load_class_file('cls_RelateModuleField', 'include/fields');
        crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
        $creationinfo = json_decode($creationinfojson, true);
        $this->relatedCreationInfo = $creationinfo;
        //获取关联单据主键信息
        $frommodule = $creationinfo['frommodule'];
        $fromid = $creationinfo['fromid'];
        //由于getModuleUitype中，没有ServiceCharge和uitype=73的判断，故为了带出客户ID,将$frommodule赋值为客户 editor:gyq_20190617
        if ($frommodule == 'ServiceCharge') $frommodule = 'Accounts';
        //editor:gyq_146 reason:关联创建带出信息改进,参考自data\BaseLogic.class.php setQuickCreateColumnValues方法 2019/9/24 10:29
        $fromfocus = CRMEntity::getInstance($frommodule);
        $fromfocus->retrieve_entity_info($fromid, $frommodule);
        $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey('uitype', 102);//项目立项选择原单
        $referencefieldinfo=$tmpfieldinfo;

        if ($tmpfieldinfo && ($frommodule == 'SalesOrder' || $frommodule == 'ServiceContracts')) {
            $tmpfieldname = $tmpfieldinfo->getFieldName();

            $focus->column_fields[$tmpfieldname] = $fromid;
        } else {
            $uitypes = cls_module_uitype::getModuleAllUtitype($frommodule);

            if($focus->moduleName == 'ModComments'){
                $uitypes[] = 112;
            }


            foreach ($uitypes as $uitype) {

                $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey("uitype", $uitype);
                if (!empty($tmpfieldinfo)){
                    $tmpfieldname =$tmpfieldinfo->getFieldName();
                    $referencefieldinfo=$tmpfieldinfo;

                    $tmpbigtype =$tmpfieldinfo->getBigType();
                    $focus->column_fields[$tmpfieldname] = $fromid;
                    //zkt 20230417 BUG0064909 收款单选择原单只有，按回款计划收款。移动端根据销售合同下推创建收款单，会把收款单原单信息全部带出来，还可以选择其他，参考视频
                    if($tmpbigtype == 'selectsource'){
                        //选择源单，获取多个源单模块
                        $sourcemodules=getSourceModule($focus->moduleName);
                        if(sizeof($sourcemodules)>0)
                        {
                            if((isset($fromid) && $fromid >0) )
                            {
                                $isfromsourcemodule = 'no';
                                foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
                                {
                                    if($frommodule==$sourcemoduleinfo['entitytype'])
                                    {
                                        $isfromsourcemodule='yes';
                                        break;
                                    }
                                }
                                if($isfromsourcemodule!='yes')
                                {
                                    $focus->column_fields[$tmpfieldname] = '';
                                }
                            }
                        }
                    }
                }
            }
        }
        $referencefield_arr=[];//frommodule 选择字段
        if ($fromid > 0 && $frommodule != "") {
            //关联创建，引用字段值得获取
            foreach ($fromfocus->column_fields as $fieldname => $value) {
                if (array_key_exists($fieldname, $focus->column_fields)) {
                    $tmpfieldinfo1 = $focus->fieldobj->getFieldInfoobjBykey('fieldname', $fieldname);
                    $bigtype = '';
                    if ($tmpfieldinfo1) {
                        $bigtype = $tmpfieldinfo1->getBigType();

                    }

                    $tmpfieldinfo= $fromfocus->fieldobj->getFieldInfoobjBykey('fieldname',$tmpfieldname);
                    if($tmpfieldinfo&&$tmpfieldinfo->getBigType()==REFERENCE_FIELD)
                    {
                        $this->effectcolumn_arr[$tmpfieldname]='';
                    }
                    if ($bigtype == 'reference' || $bigtype == 'selectsource'){
                        $focus->column_fields[$fieldname] = $value;
                        $referencefield_arr[]=['fieldinfo'=>$tmpfieldinfo1,'value'=>$value];

                    }
                }
            }
        }


        if(isset($referencefieldinfo))
        {
            $this->effectcolumn_arr[$referencefieldinfo->getFieldName()]='';

            //根据关联创建，获取当前模块字段值
            $this->setEffectValues($focus,$fromid,"",$referencefield_arr);


            $this->effectcolumn_arr=[];
        }




        //关联创建带出引用字段（发票引用客户字段，合同订单关联创建发票）
       /* $clsReferencefieldobj = cls_RelateModuleField::getInstance($this->module, $fromid, 'edit');
        $column_fields = $clsReferencefieldobj->getAllFieldValueRelateCreate();
        foreach ($column_fields as $fieldname => $value) {
            $focus->column_fields[$fieldname] = $value;
        }*/

        //源单ID
        $uitypes = cls_module_uitype::getModuleUitype($this->module, $frommodule);
        if (!empty($uitypes)) {
            //供应商字段有两种uitype 75,81 这里暂时特殊判断 gyqTE
            if ($frommodule == 'Vendors')
                $fieldname = 'vendor_id';
            else
                $fieldname = $focus->fieldobj->getFieldInfoBykeyValue('uitype', $uitypes['uitype'], 'fieldname');
            $focus->column_fields[$fieldname] = $fromid;
            if ($uitypes['uitype'] == 58) $focus->column_fields['leadsource'] = '市场活动';
        }
        //edit:can 2021-03-22 0045092: （http://51mis.com.cn/XS/hzxmz [^] ）（杭州小拇指）企业微信端-潜在加盟商（客户模块）关联创建跟进记录，‘客户手机号’字段中没有带出数据。这是一个引用字段，对象是潜在加盟商（客户模块）

      /*  crm_load_class_file('cls_RelateModuleField','include/fields');
        //关联创建带出引用字段（发票引用客户字段，合同订单关联创建发票）
        $clsReferencefieldobj=cls_RelateModuleField::getInstance($this->module,$fromid,'edit');
        $column_fields=$clsReferencefieldobj->getAllFieldValueRelateCreate();

        foreach($column_fields as $fieldname=>$value)
        {
            if( $focus->column_fields[$fieldname]=='')//联系人相关信息创建，首要联系人
                $focus->column_fields[$fieldname]=$value;
        }*/


    }

    public function setEffectValues($focus,$fromid,$relatefieldname,$tmpreferencefield_arr):void{




        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($this->module, $fromid,$relatefieldname);
        $cls_ParentRelatedFields->isRelateCreate='yes';
        $relatedfielddata = $cls_ParentRelatedFields->getEffectValues();

        if (!empty($relatedfielddata)) {
            $referencefield_arr=[];
            foreach ($relatedfielddata as $data_infos) {
                $tmpfieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname", $data_infos['columnname']);


                if ($tmpfieldinfo && $tmpfieldinfo->getBigType() == REFERENCE_FIELD) {

                    if(array_key_exists($data_infos['columnname'],$this->effectcolumn_arr))
                        continue;


                    $referencefield_arr[]=['fieldinfo'=>$tmpfieldinfo,'value'=>$data_infos['value']];

                    $this->effectcolumn_arr[$data_infos['columnname']]='';
                    $focus->column_fields[$data_infos['columnname']] = $data_infos['value'];


                } else
                    $focus->column_fields[$data_infos['columnname']] = $data_infos['value'];
            }


            $referencefield_arr=array_merge($tmpreferencefield_arr,$referencefield_arr);
            $referencefield_arr=array_filter(array_unique($referencefield_arr));



        }

        if(is_array($referencefield_arr)&&sizeof($referencefield_arr))
            foreach($referencefield_arr as $tmpinfo)
            {



                $this->setEffectValues($focus,$tmpinfo['value'],$tmpinfo['fieldinfo']->getFieldName(),[]);


            }
    }

    //外部联系人带入信息新建带出值
    public function get_externalcontacts()
    {
        $exter_crm = array('corpname' => 'accountname', 'name' => 'lastname', 'mobile' => 'mobile', 'email' => 'email', 'position' => 'title');
        foreach ($exter_crm as $key => $val) {
            if (isset($_REQUEST[$key])) {
                $_REQUEST[$val] = urldecode($_REQUEST[$key]);
                if ($key != $val) unset($_REQUEST[$key]);
            }
        }
    }

    protected function DetailLastExtra()
    {
        $this->get_accountscontactsinfo();
        $this->getModuleRelatedList();
        $this->getModuleComents();
        $this->getModuleApprove();
        //editor:gyq_20191231 reason:移动端参数设置增加“设置移动端单据详情界面默认值显示”参数控制 ID1000697
        $this->getSystemsDeploy();
    }

    //明细头部信息
    protected function getMainInfo($column_fields)
    {
        global $adb, $PlatformMC;
        crm_load_class_file('cls_Uitype_table', 'include/fields');
        $module = $this->module;

        $fieldsinfo = cls_StaticCommonFun::getMainInfoField($module);
        $fieldobj = Field::getInstance($module, $adb);
        $list = array();

        //获取头部title链接字段 取第一行字段
        $showtag = 'yes';
        if (empty($fieldsinfo)) {
            $entityinfo = getEntitynameInfo(getTabid($module));
            $titlefield = $entityinfo['fieldname'];
        } else {
            $titlefield = $fieldsinfo[0]['fieldname'];
            $showtag = $fieldsinfo[0]['showtag'];
        }

        $titlefieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname', $titlefield);
        $titleinfo = '';
        if (!empty($titlefieldinfo) && $titlefieldinfo->getFieldName() != '') {
            $showobjvalue = new ShowFieldValue($fieldobj, $module, SHOW_POPUP);
            // BUG20240813-31 出差申请单--企业微信移动端，申请人显示为无，单据上是有申请人的
            if(Field::user_fields($titlefieldinfo->getUIType())){
                $detailvalue['value'] = getUserRealName($column_fields[$titlefield]);
            }
            else{
                $detailvalue = $showobjvalue->getFieldValueByField($titlefieldinfo, $column_fields[$titlefield], $column_fields[$titlefield]);
                //wym 240513 XUQIU1002193 销售线索、客户，即将回收和回收消息提醒内容单据查看详情界面，客户名称增加显示超链接，移动端不显示该超链接
                $detailvalue['value']=strip_tags($detailvalue['value'],'<br>');
            }
            if (empty($detailvalue['value']) && $detailvalue['value'] !== '0' && $detailvalue['value'] !== 0) $detailvalue['value'] = '无';
            if ($showtag == 'no') {
                $titleinfo = $detailvalue['value'];
            } else {
                $titleinfo = $titlefieldinfo->getFieldLabel() . '：' . $detailvalue['value'];
            }
        }
        // 20200610 0041489: （珞落计划）收款单查看详情界面，页签上方应该不显示“已核销金额”和“余额”字段
        if($module=='CashBill' && ($column_fields['cashtype']=='cashbill'||$column_fields['cashtype']=='')){
            foreach($fieldsinfo as $key => $fieldval){
                if(in_array($fieldval['fieldname'], array('debuctionamount','debuctionbalanceamount'))){
                    unset($fieldsinfo[$key]);
                }
            }
        }
        //获取其他字段
        foreach ($fieldsinfo as $fieldkey => $fieldinfo) {
            if ($fieldkey == 0) continue;
            $header = array();
            $field = $fieldinfo['fieldname'];
            $showtag = $fieldinfo['showtag'];
            $fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname', $field);
            if (empty($fieldinfo) || $fieldinfo->getFieldName() == '') continue;
            $fieldvaluecolor = $fieldinfo->getFieldValueColor();
            $label_style = $fieldinfo->getLabelStyle();

            $showobjvalue = new ShowFieldValue($fieldobj, $module, SHOW_POPUP);
            $showobjvalue->setRecorId($this->record);
            $detailvalue = $showobjvalue->getFieldValueByField($fieldinfo, $column_fields[$field], $column_fields[$field]);
            $header['fieldlabel'] = $fieldinfo->getFieldLabel();
            if ($showtag == 'no') $header['fieldlabel'] = '';
            $header['value'] = $detailvalue['value'];
            $header['rawvalue'] = $detailvalue['rawvalue'];
            $header['fieldname'] = $field;
            $header['phone'] = 'no';


            $bigtype = $fieldinfo->getBigType();
            $header['bigtype'] = $bigtype;
            $header['fieldlabelstyle'] = $label_style;
            //下拉框字段显示的颜色根据内容变化
            if($fieldinfo->getUIType() == '15'){
                global $global_picklist_colors_byvalue;
                $all_pick_colors = $global_picklist_colors_byvalue[$fieldinfo->getFieldName()];
                $fieldvaluecolor = isset($all_pick_colors[$detailvalue['value']])&&!empty($all_pick_colors[$detailvalue['value']])?$all_pick_colors[$detailvalue['value']]:'';
            }
            if(!empty($fieldvaluecolor)){
                $header['fieldvaluecolor'] = $fieldvaluecolor;
            }
            if ($fieldinfo->getUIType() == '1101') {
                $header['phone'] = 'yes';
            }
            if ($fieldinfo->getUIType() == '1501'||$fieldinfo->getUIType() == '1500') {
                $header['value'] = getFixedLabel('VIEW').''.getFixedLabel('SOCIALPROMOTIONQRCODE');//查看二维码
                $header['fieldid'] = $fieldinfo->getFieldId();
                $header['uitype'] = $fieldinfo->getUIType();
            }
            if ($fieldinfo->getUIType() == '19'||$fieldinfo->getUIType() == '20') {
                $header['value'] = nl2br($header['value']);
            }
            /*
            if($displaytype=='link'){
                if(empty($header['value'])) continue;
                $uitype = $fieldinfo->getUIType();
                $relatemoduleinfo = cls_Uitype_table::getTableJoinByUitype($uitype,'','');
                $relatemodule = $relatemoduleinfo['module'];
                $header['module'] = $relatemodule;
                $relation[] = $header;
            }else{
                if(empty($header['value'])&&$header['value']!=='0'&&$header['value']!==0) $header['value']='无';
                unset($header['rawvalue']);
                $list[]=$header;
            }*/
            /*
            if (empty($PlatformMC['type_mini'])) {
                if ($fieldinfo->getUIType() == '1101' && !empty($header['value']) && is_numeric($header['value'])) {
                    $fieldcolor = empty($fieldvaluecolor)?'':$fieldvaluecolor;
                    $header['value'] = '<a style="color:'.$fieldcolor.'" href="tel:' . $header['value'] . '">' . $header['value'] . '</a>';
                }
            }
            */

            if (empty($header['value']) && $header['value'] !== '0' && $header['value'] !== 0) $header['value'] = '无';
            unset($header['rawvalue']);
            $list[] = $header;
        }

        if ($module == 'Contacts' && cls_StaticCommonFun::isExternalContactUser()) {
            $result = $adb->pquery('select IFNULL(weixin_external_userid,\'\') from ld_contactdetails where contactid=?', array($this->record));
            $this->jsonArr['maininfo']['ec_userid'] = $adb->query_result($result, 0, 0);
        }

        $this->jsonArr['maininfo']['title'] = $titleinfo;
        $this->jsonArr['maininfo']['list'] = $list;
        //$this->jsonArr['maininfo']['relation'] = $relation;
    }

    public function getApproveInfo()
    {
        crm_load_class_file("cls_Approve_StepWX", 'WeiXinApp/modules/Approve/cls_Approve');
        $approveobj = new cls_Approve_StepWX($this->record, $this->module, $this->jsonArr['list2']);
        $approveinfo = $approveobj->getApproveInfo();

        $this->jsonArr['approveinfo'] = $approveinfo;
    }

    //获取审批步骤（新增、编辑界面）
    public function getApproveStep()
    {
        global $weixin_user;
        global $current_user,$adb;
        global $createPage_smownerid;
        $module = $this->module;
        $record = $this->record;

        // 2020-07-31 diony 0042199: （曙光计划）复制审批中的单据时，复制界面没有显示“选择审批流程”字段（客户模块测试）
        if($_REQUEST['isDuplicate'] == 'yes'){
            $record = '';
            //edit:can 2020-11-04 复制时默认的审批流程没有显示
            $weixin_user->action = 'default_on_new';
        }

        $approve_module = getSys_Approvedeploy($module);
        if (empty($approve_module) || $approve_module['deploy_value'] == 1) return;
        crm_load_class_file("Approve", 'modules/Approve');
        $approve = new Approve($this->module);
        if (!empty($record)) {
            $approveinfo = $approve->approveStatus($record);
            if(!array_key_exists('approvestatus',$this->focus->column_fields)||empty($this->focus->column_fields['approvestatus']))
            {
                //审批状态字段隐藏
                $sql= "select approvestatus from "  .$this->focus->table_name." where "  .$this->focus->table_index."=?";
                $result=$adb->pquery($sql,array($record));
                if($adb->num_rows($result)>0){
                    $this->focus->column_fields['approvestatus']=$adb->query_result($result,0,0);
                }
            }
            $status=$approve->getApproveStatus($this->focus->column_fields['approvestatus']);
            if($status == 1 || $approveinfo['approvestatus'] == 1){
                return '';
            }
        }
        if(!$approve->Blocksquicksubmit($module)){//如果不启用快速提交则返回空数组
            return '';
        }
        if ($approveinfo['approvestatus'] == 2){
            //判断审批结束后是否允许编辑所有字段
            crm_load_class_file('ApproveFinished', 'modules/Approve');
            $approvefinishedobj = ApproveFinished::getInstance($module, $record);
            //如果允许编辑所有字段，则允许新增删除产品
            if($approvefinishedobj->isEditAllFiled() == 'yes'){
                $allowedtoedit = 'yes';
            }else{
                $allowedtoedit = 'no';
            }
        }else{
            $allowedtoedit = 'yes';
        }
        $this->jsonArr['allowedtoedit'] = $allowedtoedit;

        //editor:gyq_132 reason:专用于Approve的submitApprove中  2019/7/22 18:53 ID1000479
        if ($this->action == 'CreateView') {
            $weixin_user->action = 'default_on_new';
        }else if ($this->action == 'EditView') {
            $weixin_user->action = 'default_on_submit';
        }

        //$approveinfos = $approve->submitApprove(getTabid($this->module));
        crm_load_class_file("cls_approvestep_change","modules/Approve");
        $approvestep_change_obj = new cls_approvestep_change($module);
        $approvestep_change_obj->set_focus($this->focus);
        $approvestep_change_obj->set_approveobj($approve);
        $approveinfos = $approvestep_change_obj->getApplicableApproveInfo();
        $approve_fieldname_arr = $approvestep_change_obj->get_approve_fieldname();
        //要提前放到数组里，可能新建的时候没有符合条件的流程，修改字段后就符合条件了
        $this->jsonArr['approve_fieldname_arr'] = $approve_fieldname_arr;

        if(empty($createPage_smownerid))
        {
            //43081: （移动端）费用管理-出差申请单（苏宁客户问题需要补丁）；单据CC20201030-682，提交审批，选择审批流“出差申请审批流程_1”；PC端审批人正常显示，但手机端审批人显示还是单据负责人自己。
            //负责人设置为只读字段
            $createPage_smownerid=$current_user->id;
        }

        foreach($approveinfos as $approveindex=>$tmp_approveinfo){
            $approveobj = Approve::getInstance($this->module,$tmp_approveinfo['isnewapprove']);
            if(empty($record)){
                $nextStepInfo = $approveobj->getApproveStepInfo($tmp_approveinfo['approveid'],$record,$createPage_smownerid);
            }
            else
                $nextStepInfo = $approveobj->getApproveStepInfo($tmp_approveinfo['approveid'],$record);


            if(trim($nextStepInfo[0]['stepuserids'],',')=='' && $nextStepInfo[0]['allow_emptyapprover'] == 'no'){
                $nextStepInfo[0]['stepuserids']=$current_user->id;
                $nextStepInfo[0]['newstepapprover']=$current_user->last_name;
            }
            foreach($nextStepInfo as &$tmpstepinfo)
            {
                $stepuserids=$tmpstepinfo['stepuserids'];
                $userdata= cls_StaticCommonFun::getUserDetailInfo($stepuserids);
                $tmpstepinfo['userdata']=$userdata;
            }
            $approveinfos[$approveindex]['steplist']=$nextStepInfo;
            /*  $approveinfos[$approveindex]['userids']=$nextStepInfo[3];
                $approveinfos[$approveindex]['usernames']=$nextStepInfo[1];

                $approveinfos[$approveindex]['specifyuser']=$nextStepInfo[2];
                $approveinfos[$approveindex]['countersigner']=$nextStepInfo[4];*/


        }

        //editor:gyq_20200113 reason:下方对$approve[0]['selected']的重现赋值，应是追加，而不是完全覆盖 2020/1/13 10:54
        //0039154: （http://k171c19364.iask.in:18088/crm/ [^]）企业微信>灵当CRM>合同订单模块新增界面：审批流程定制中设置了“是否移动端新建时默认流程”，在使用企业微信创建单据时没有自动选择设置的默认流程。（已测试落落计划没有该问题）
        //editor:gyq_20190820 reason:新增参数“移动端新建单据时，将审批流程定制中用户可见的唯一审批工作流设置为默认值”
        //editor:gyq_20190924 reason:使用count判断时，一定要判断元素是否是数据
        //0038142: （51mis.com/kfbcrm）企业微信>灵当CRM>销售线索新增界面：该模块没有审批功能，底部的选择审批流程应该不显示。
        // dump($this->action);
        if(!empty($approveinfos)){
            $approveinfos = $approveobj->NoDefaultAddEmptyApproval($approveinfos);//xxy 2023-12-14 增加参数：无默认审批流时显示为空
        }

        if ($this->action == 'EditView' && $record >0) {
            //ls 2021-11-17 【1002212】审批流程定制增加允许重复提交审批（徐昱轩）
            $status = $approve->getApproveStatus($this->focus->column_fields['approvestatus']);
            if ($status == 2 || $status == 3) {
                if ($approve->recordAgainSubmit($module)) {
                    foreach ($approveinfos as &$tmpapprove) {
                        if($tmpapprove['finishedallowedit']=='yes' && $tmpapprove['allowagainsubmit']=='yes') {
                            $tmpapprove['selected'] = 'selected';
                            break;
                        }
                    }
                }else{
                    //ls 2012-11-25 0048961: （企业微信移动端）审批流程设置不允许再次提交审批，审批结束允许编辑，则报价单（QUO144）审批成功后，编辑界面应该不显示“选择审批流程”区块
                    return;//不返回审批流程
                }

            }
        }
        // dump($approveinfos);
        if (empty($approveinfos) || $approveinfos == ''){
            return;
        }else{
            /*
            $haveselected = 'no';//同步pc端选审批流程逻辑
            foreach ($approveinfos as $tmpapprove) {
                if($tmpapprove['selected'] == 'selected') {
                    $haveselected = 'yes';
                    break;
                }
            }
            if($haveselected == 'no'){
                $approveinfos[0]['selected'] = 'selected';
            }
            */
        }
        if ((($this->action == 'CreateView' || $_REQUEST['isDuplicate'] == 'yes') || $this->action == 'EditView') && is_array($approveinfos) && count($approveinfos) == 1) {
            // 自动选中唯一可选审批流程
            $approveinfos[0]['selected'] = 'selected';

        }
        $this->jsonArr['approvestep'] = $approveinfos;

    }

    //客户及联系人关联字段之显示模块
    protected function get_accountscontactsinfo()
    {
        global $adb;
        if ($this->module != 'Contacts') {
            $tabid = getTabid($this->module);
            //模块含客户字段即显示该区块
            $sql = "select 1 from ld_field where uitype=73 and tabid=? limit 1";
            $result = $adb->pquery($sql, array($tabid));
            if ($adb->num_rows($result)) {
                $this->jsonArr['accountscontactsinfo'] = $this->getAccountsContactsInfo($this->focus);
            }
        }
    }

    //相关信息
    protected function getModuleRelatedList()
    {

        if ($this->action == 'DetailView') {
            $showmodules = array();
            $showcreatemodules = array();
            $showcreatemodules_Switching = array();
            $detailComFun = crm_load_class_obj('cls_DetailView_CommonFun', 'WeiXinApp/include');
            //判断存在相关信息的模块有值，则返回模块数组给后台，让后台留相关页签位置，不去读相关信息的具体内容。
            $wxshowmodules = $detailComFun->wx_presenceModules($this->module);
            $pcshowmodules = isPresentRelatedLists($this->module);
            $relatecustomreports=Detail_Edit_View::getRelatedCustomReport($this->module);
            //$wxpcmodules = array_intersect($wxshowmodules,$pcshowmodules);
            require_once(globalStatic::$root_directory . 'include/utils/DetailViewUtils.php');

            foreach ($pcshowmodules as $relatedid => $showmodule) {
                if (in_array($showmodule, array('ViewHistory', 'ChangeView', 'AccountHierarchy', 'Print'))) continue;
                if(array_key_exists($relatedid,$relatecustomreports))
                {
                    //自定义报表
                    $default_report=0;
                    if($relatecustomreports[$relatedid]['related_coltable']=='crmlink')
                    {
                        $default_report=1;
                    }
                    if($relatecustomreports[$relatedid]['type']=='datacategory_templatelink')
                    {
                        $url='CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key='.$relatecustomreports[$relatedid]['name'].'&default_report='.$default_report.'&report_name='.$relatecustomreports[$relatedid]['label'];


                    }
                    else
                    {
                        $url='CustomReport/JsReport/index.php?crm_report_key='.$relatecustomreports[$relatedid]['name'].'&default_report='.$default_report.'&report_name='.$relatecustomreports[$relatedid]['label'];
                    }
                    $showcreatemodules[]=array('id' => $relatedid
                    , 'name' => $relatecustomreports[$relatedid]['label'],'type'=>'relatecustomreport'
                    ,'module'=>$url);
                    continue;

                }

                if (in_array($showmodule, $wxshowmodules)) {
                    $relationInfo = getRelatedListInfoById($relatedid, $this->module);
                    $showmodules[] = $showmodule;
                    if ($showmodule == 'QuotesChange' || $showmodule == 'WorkSheet') continue;
                    if (isPermitted($showmodule, 'Create', '') == 'yes' && stripos($relationInfo['actions'], 'add') !== false) {
                        $cancreate = $this->specialDisplayCreatebutton($showmodule);
                        if ($cancreate == 0) continue;
                        $transname = getTransTab($showmodule);
                        if ($this->module == 'SalesOrder' && $showmodule == 'SalesOrder') $transname = getFixedLabel('CHANGEORDER');
                        //0045335: （企业微信移动端-kfbcrm）管理员登录操作，客户管理-跟进记录-详情，相关信息创建显示2个“签到”，移动端不应该显示该选项
                        if($showmodule!='Singin'){
                            $showcreatemodules[] = array('id' => $relatedid, 'module' => $showmodule, 'name' => $transname,'type'=>'');
                        }
                    }
                    // BUG0055038  企业微信移动端，客户相关模块横向显示，若成员没有联系人模块“新建”操作权限时，“联系人”相关模块页签也应该显示
                    $transname_Switching = getTransTab($showmodule);
                    if ($this->module == 'SalesOrder' && $showmodule == 'SalesOrder') $transname = getFixedLabel('CHANGEORDER');
                    if($showmodule!='Singin' && $showmodule!='BalanceOfAccount'){
                        $showcreatemodules_Switching[] = array('id' => $relatedid, 'module' => $showmodule, 'name' => $transname_Switching,'type'=>'');
                    }
                }
            }
            if (!empty($showmodules)) {
                $this->jsonArr['relatedList'] = reset($showmodules);
                $this->jsonArr['relatedCreateList'] = empty($showcreatemodules) ? '' : $showcreatemodules;

                //dion 20200527 增加两个快速创建
                if(!empty($showcreatemodules)){
                    $relate_count = 2;
                    if(sizeof($showcreatemodules) < 2){
                        $relate_count = sizeof($showcreatemodules);
                    }
                    for ($i = 0; $i < $relate_count; $i++) {
                        $relate_quick[] = $showcreatemodules[$i];
                    }
                    $this->jsonArr['relatedCreateListQuick'] = $relate_quick;
                }
            }

            //diony 20240507 表单推广增加转发到会话、转发到微信
            global $weixin_user;
            if ($this->module == 'SocialPromotion' && $weixin_user->environment=='weixinh5') {
                $arr['id'] = 1;
                $arr['module'] = 'shareAppMessage';
                $arr['name'] = '转发到会话';
                $arr['type'] = '';
                $arr1['id'] = 2;
                $arr1['module'] = 'shareWechatMessage';
                $arr1['name'] = '转发到微信';
                $arr1['type'] = '';
                $relate_quick[0] = $arr;
                $relate_quick[1] = $arr1;
                $this->jsonArr['relatedCreateListQuick'] = $relate_quick;
            }
        }
    }

    //评论日志
    protected function getModuleComents()
    {
        global $adb;
        $comentslog = array();
        if (vtlib_isModuleActive('ModComments') && $this->action == 'DetailView') {
            if (isPermitted('ModComments', 'DetailView', '') == 'yes') {
                $query = 'SELECT ld_modcomments.modcommentsid as crmid,
                        ld_modcomments.commentcontent,ld_modcomments.createdtime,ld_users.last_name,ld_users.real_name,ld_modcomments.remindusers 
                        FROM ld_modcomments 
                        LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id 
                        LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_modcomments.modcommentsid 
                        WHERE ld_modcomments.deleted = 0 AND ld_modcomments.related_to=? 
                        ORDER BY ld_modcomments.modcommentsid DESC ';
                $result = $adb->pquery($query, array($_REQUEST['record']));
                for ($i = 0; $i < $adb->num_rows($result); $i++) {
                    $crmid = $adb->query_result($result, $i, "crmid");
                    $commentcontent = nl2br($adb->query_result($result, $i, "commentcontent"));
                    $commentcontent_arr = array('k' => '评论内容', 'v' => $commentcontent);
                    $createdtime = $adb->query_result($result, $i, "createdtime");
                    $createdtime_arr = array('k' => '评论时间', 'v' => $createdtime);
                    $last_name = $adb->query_result($result, $i, "last_name");
                    $real_name = $adb->query_result($result, $i, "real_name");
                    if(isKehu001ServerPc()=="yes"){
                        $last_name_arr = array('k' => '评论人', 'v' => $real_name);
                    }else{
                        $last_name_arr = array('k' => '评论人', 'v' => $last_name);
                    }
                    $remindusers = $adb->query_result($result, $i, "remindusers");
                    $remindsuser_array = explode(',',$remindusers);
                    if(empty($remindusers)||sizeof($remindsuser_array)<=0){
                        $remindusersStr = '';
                    }
                    else{
                        $remindusersStr = sizeof($remindsuser_array).getFixedLabel('COLLEAGUES');
                    }
                    $remindusers_arr = array('i' => $remindusers, 'k' => '抄送范围', 'v' => $remindusersStr);

                    $tmp_fileImg_arr = getModCommentsFileImgInfo($crmid);
                    $fileImg_arr = empty($tmp_fileImg_arr)?'':$tmp_fileImg_arr;
                    if(!is_array($fileImg_arr))
                        $fileImg_arr=[];

                    $reply_query='SELECT ld_modcomments.modcommentsid AS crmid,ld_modcomments.*,ld_attachments.newfile_name as name,ld_attachments.path,ld_attachments.storage_location,ld_attachments.cloud_path,ld_modcomments.createdtime,ld_users.last_name,ld_users.real_name
                            FROM ld_modcomments
                            LEFT JOIN ld_users ON ld_modcomments.smownerid = ld_users.id
                            left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                            left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
                            LEFT JOIN ld_tabshare ON ld_tabshare.crmid = ld_modcomments.modcommentsid
                            WHERE ld_modcomments.deleted = 0 AND ld_modcomments.parent_comments = ? 
                            ORDER BY ld_modcomments.createdtime DESC ';
                    $reply_result = $adb->pquery($reply_query, array($crmid));
                    if($adb->num_rows($reply_result) > 0){
                        for ($j = 0; $j < $adb->num_rows($reply_result); $j++) {
                            $reply_crmid = $adb->query_result($reply_result, $j, "crmid");
                            $reply_commentcontent = nl2br($adb->query_result($reply_result, $j, "commentcontent"));
                            $reply_commentcontent_arr = array('k' => '回复内容', 'v' => $reply_commentcontent);
                            $reply_createdtime = $adb->query_result($reply_result, $j, "createdtime");
                            $reply_createdtime_arr = array('k' => '回复时间', 'v' => $reply_createdtime);
                            $reply_last_name = $adb->query_result($reply_result, $j, "last_name");
                            $reply_real_name = $adb->query_result($reply_result, $j, "real_name");
                            if(isKehu001ServerPc()=="yes"){
                                $reply_last_name_arr = array('k' => '回复人', 'v' => $reply_real_name);
                            }else{
                                $reply_last_name_arr = array('k' => '回复人', 'v' => $reply_last_name);
                            }
                            $reply_remindusers = $adb->query_result($reply_result, $j, "remindusers");
                            $reply_remindsuser_array = explode(',',$reply_remindusers);
                            if(empty($reply_remindusers)||sizeof($reply_remindsuser_array)<=0){
                                $reply_remindusersStr = '';
                            }
                            else{
                                $reply_remindusersStr = sizeof($reply_remindsuser_array).getFixedLabel('COLLEAGUES');
                            }
                            $reply_remindusers_arr = array('i' => $reply_remindusers, 'k' => '抄送范围', 'v' => $reply_remindusersStr);
                            $tmp_reply_fileImg_arr = getModCommentsFileImgInfo($reply_crmid);
                            $reply_fileImg_arr = empty($tmp_reply_fileImg_arr)?'':$tmp_reply_fileImg_arr;
                            if(!is_array($reply_fileImg_arr))
                                $reply_fileImg_arr=[];

                            $reply_list[] = array('id' => $reply_crmid, 'parentid' => $crmid, 'commentcontent' => $reply_commentcontent_arr, 'createdtime' => $reply_createdtime_arr,
                                'last_name' => $reply_last_name_arr, 'remindusers' => $reply_remindusers_arr,'image'=>$reply_fileImg_arr['image'],'filename'=>$reply_fileImg_arr['filename']);
                        }
                    }
                    else{
                        $reply_list = array();
                    }

                    $comentslog[] = array('id' => $crmid, 'commentcontent' => $commentcontent_arr, 'createdtime' => $createdtime_arr, 'last_name' => $last_name_arr,
                        'remindusers' => $remindusers_arr, 'replylist' => $reply_list,'image'=>$fileImg_arr['image'],'filename'=>$fileImg_arr['filename']);
                }
                $this->jsonArr['commentslog'] = $comentslog;
            }

            //editor:gyq_20190815 reason:0037779: （落落计划）企业微信>灵当CRM>模块明细界面：在某个用户没有评论模块删除权限的情况下，手机端还是能删除评论。（pc端是正常的）
            if (vtlib_isModuleActive('ModComments') && isPermitted('ModComments', 'Delete', '') == 'yes') {
                $this->jsonArr['commentsInfo']['comment_delete_permit'] = 'yes';
            } else {
                $this->jsonArr['commentsInfo']['comment_delete_permit'] = 'no';
            }
            if (vtlib_isModuleActive('ModComments') && isPermitted('ModComments', 'Reply', $_REQUEST['record']) == 'yes') {
                $this->jsonArr['commentsInfo']['comment_reply_permit'] = 'yes';
            } else {
                $this->jsonArr['commentsInfo']['comment_reply_permit'] = 'no';
            }
            $ModComment_focus = CRMEntity::getInstance('ModComments');
            $ModComment_list = $this->getBlockFields('ModComments', 'CreateView', 'Create', $ModComment_focus->column_fields);
            foreach ($ModComment_list as $tmpindex => $blockinfo){
                foreach ($blockinfo['fieldinfo'] as $index => $info){
                    if($info['columnname'] == 'image'){
                        $comment_image_fieldobj = $info;
                    }else if ($info['columnname'] == 'filename'){
                        $comment_filename_fieldobj = $info;
                    }
                }
            }
//            dump($ModComment_focus->column_fields);
            if (key_exists('image',$ModComment_focus->column_fields)){
                $this->jsonArr['commentsInfo']['image_permit'] = 'yes';
                $this->jsonArr['commentsInfo']['image_fieldobj'] = $comment_image_fieldobj;;
            }
            if (key_exists('filename',$ModComment_focus->column_fields)){
                $this->jsonArr['commentsInfo']['filename_permit'] = 'yes';
                $this->jsonArr['commentsInfo']['filename_fieldobj'] = $comment_filename_fieldobj;
            }

            $comments_focus=CRMEntity::getInstance($this->module);
            $comments_focus->id = $_REQUEST['record'];
            $comments_focus->retrieve_entity_info($_REQUEST['record'], $this->module);
            // dump($comments_focus->column_fields);
            $copyuserid=array();
            $copyuserid[]=$comments_focus->column_fields['assigned_user_id'];
            if($comments_focus->column_fields['assigned_user_id'] != $comments_focus->column_fields['creator']){
                $copyuserid[]=$comments_focus->column_fields['creator'];
            }
            foreach ($copyuserid as $id){
                $userobj=new Users();
                $usersql="select id,last_name,wx_userid from ld_users where id=? ";
                $userresult=$adb->pquery($usersql,array($id));
                if($adb->num_rows($userresult)>0) {
                    $userobj->id = $adb->query_result($userresult, 0, 'id');
                    $userobj->wx_userid = $adb->query_result($userresult, 0, 'wx_userid');
                    $userobj->last_name = $adb->query_result($userresult, 0, 'last_name');
                    $copyuserlastname = getUserlastName($userobj);
                    $copyusername[]=array('id'=>$id,'name'=>$copyuserlastname);
                }
            }
            $this->jsonArr['commentsInfo']['scope'] = $copyusername;
        }
    }

    //审批日志
    protected function getModuleApprove()
    {
        global $adb,$current_user;
        //加载审批历史
        $approvelog = array();
        //列头key对应翻译数组
        $approvefield = array('OPERATE' => 'OPERATING', 'STEPNAME' => 'APPROVALSTEP', 'OPERATOR' => 'operatoroer', 'APPROVERESULT' => 'APPROVALRESULT',
            'NEXTSTEPBYNAME' => 'NEXTOPERATOR', 'DESCRIPTION' => 'APPROVALSUGGESTION', 'CREATEDTIME' => 'operatoroertime','APPROVEAUTOGRAPHPATH' => 'handwriting');
        if ($this->module == 'ServiceCharge') $this->module = 'Accounts';
        crm_load_class_file("ApproveCommon","modules/Approve");
        $approvecommonobj = ApproveCommon::getInstance($this->module);
        $sql = "select approveid from ld_approvelog where crmid = ? order by id desc limit 1";
        $result = $adb->pquery($sql,array($this->record));
        if($adb->num_rows($result)>0){
            $approveid = $adb->query_result($result,0,'approveid');
            $approve = $approvecommonobj->getApproveobjByApproveid($approveid);
        }else{
            return $approvelog;
        }
        //判断当前模块是否开启审批，未开启的话就不显示审批历史
        $approvemod = $approve->getApproveModuleInfo();
        require_once(globalStatic::$root_directory.'Register/RegOp.php');//gyqCom0309 reason:软件过期不可用 date:20170309
        $regop=RegOp::getInstance();
        if (isset($approvemod[$this->module])) {
            $approvelog = $approve->approveLog($this->record);
            $j = sizeof($approvelog);
            for ($i = 0; $i < sizeof($approvelog); $i++) {
                $operatename = $approvelog[$i]['operatename'];
                unset($approvelog[$i]['curlogconcurrentid']);
                unset($approvelog[$i]['nextlogconcurrentid']);
                unset($approvelog[$i]['operatecol_rowspan']);
                unset($approvelog[$i]['seqno']);
                $stepinfo = $approvelog[$i]['stepinfo'];
                for ($k = 0; $k < sizeof($stepinfo); $k++) {
                    $stepname = $stepinfo[$i]['STEPNAME'];
                    if ($stepname == '' || $stepname == null) {
                        $stepinfo[$k]['STEPNAME'] = '';
                    } else {
                        $stepinfo[$k]['STEPNAME'] = $stepinfo[$k]['STEPNAME'];
                    }
                    if (!empty($stepinfo[$k]['OPERATE'])) {
                        $stepinfo[$k]['OPERATOR'] .= '（' . $stepinfo[$k]['OPERATE'] . '）';
                    }
                    unset($stepinfo[$k]['OPERATE']);
                    foreach ($stepinfo[$k] as $key => $val) {
                        if (!empty($val) && $key != 'BACKUP') {
                            if ($key == 'DESCRIPTION') {
                                $val=str_replace("\r\n","<br>",$val);
                                $val=str_replace("\n","<br>",$val);
                                $stepinfo[$k][$key] = array('k' => getFixedLabel($approvefield[$key]), 'v' => $val, 't' => $approvelog[$k]['BACKUP'] == 'YES' ? 'f' : 'z');
                            }else if($key == 'APPROVEAUTOGRAPHPATH'){
                                if($regop->gethandleWriteSign_interface() == 1){
                                    $stepinfo[$k][$key] = array('k' => getFixedLabel($approvefield[$key]), 'v' => $val);
                                }
                            } else {
                                $stepinfo[$k][$key] = array('k' => getFixedLabel($approvefield[$key]), 'v' => $val);
                            }
                        }
                    }
                    unset($stepinfo[$k]['BACKUP']);
                }
                $approvelog[$i]['stepinfo'] = $stepinfo;
                $j--;
            }
            $ApprovelogSetInfo = $approve->getApprovelogSet($this->record);
            $WholeApproveLog = $approve->getWholeApproveLog($this->record,$ApprovelogSetInfo);
            //xxy 2023-12-6 获取当前用户在当前模块下审批日志展开收起状态
            $pre_hidden_showvalue = getUsersettingByLabel($this->module, $current_user->id, 'pre_hidden')?:'hidden';
            $next_hidden_showvalue = getUsersettingByLabel($this->module, $current_user->id, 'next_hidden')?:'hidden';
            if($pre_hidden_showvalue == 'show'){
                foreach($WholeApproveLog as $i => $approve){
                    if($approve['showtype'] == 'pre_hidden'){
                        $WholeApproveLog[$i]['display'] = 'yes';
                    }
                }
            }
            if($next_hidden_showvalue == 'show'){
                foreach($WholeApproveLog as $i => $approve){
                    if($approve['showtype'] == 'next_hidden'){
                        $WholeApproveLog[$i]['display'] = 'yes';
                    }
                }
            }
            $this->jsonArr['wholeapprovelog'] = $WholeApproveLog;
        }
    }

    protected function specialDisplayCreatebutton($showmodule)
    {
        $is_display = 1;
        if ($this->module == 'PaymentPlan' && $showmodule == 'CashBill') {

            if ($this->focus->column_fields['paymentstatus'] == '已收') {
                $is_display = 0;
            }
        }
        //付款计划如果已付则隐藏新建按钮
        if ($this->module == 'SendPayment' && $showmodule == 'SendCashBill') {
            if ($this->focus->column_fields['cpstatus'] == '已付') {
                $is_display = 0;
            }
        }
        return $is_display;
    }

    //新增时给字段添加默认值
    protected function setDefaultValue($focus)
    {
    }

    //获取签到模块 信息
    public function get_SignData($focus){
        // @edit:dong @date:2020/07/24 @reason: 签到源单类型定制功能优化
        global $adb;
        $tableName = $focus->table_name;
        $tableIndex =$focus->table_index;
        $sql = 'SELECT longtitude,latitude,address,createdtime from ld_singin where record = ? and from_module = ?';

        $result = $adb->pquery($sql,array($this->record,$this->orginmodule));

        $nums = $adb->num_rows($result);
//        @edit:liushuai,2021-03-31,reason:0045182: 企业微信->kfbtest：自定义表单一无法打开详情界面(系统定制-》源单类型定制-》拜访签到启用后报错)
        if ($nums > 0) {
            $latitude = $adb->query_result($result,0,'latitude');
            if(!empty($latitude)){
                $sign_in = [];
                $sign_in = $this->jsonArr['signData'];
                $sign_in['latitude'] = $latitude;
                $sign_in['longitude'] = $adb->query_result($result,0,'longtitude');
                $sign_in['address'] = $adb->query_result($result,0,'address');
                $sign_in['signtime'] = $adb->query_result($result,0,'createdtime');
                if($sign_in['editviewresign'] != 'yes'){
                    $sign_in['allowsign'] = 'no';
                }
                $this->jsonArr['signData'] = $sign_in;
            }else{
                //chj 2021/5/19 45959: （企业微信移动端-kfbcrm）客户区块-联系人，复制联系人单据时，若原单据有签到地址信息，复制新增时就会显示签到按钮；原单据没有签到地址信息，复制新增时没有签到按钮了
                if($_REQUEST['isDuplicate'] == 'yes'){
                    $this->isOpenSignIn($this->module);
                }
            }
        }
    }
    //待重载方法
    public function get_DetailView_Extra($focus)
    {

    }

    private function get_EditView()
    {
        //zkt 20230511 BUG0066200 移动端-客户-编辑单据-销售负责人显示为空
        if($this->action == 'EditView'&&!(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'yes')){
            $this->focus->mode = 'edit';
        }
        return $this->get_DetailView();//gyqCom0306
    }

    //初始化详情页是否有编辑、分配、删除等按钮
    protected function init_detailButton()
    {
        global $current_user, $adb,$static_publicaccount;
        /* 详情页按钮 begin */
        $this->focus->getModuleLogic($this->module);
        $this->focus->logic->btn_from = 'mobile';
        $this->focus->logic->getDetailViewButton();
        $buttonArr = $this->focus->logic->detail_buttons;
        /*
        if($this->module=='Accounts'){
            if($this->focus->logic->receivebtn['receive']['permit']=='yes'){
                //edit:can 74112 企业微信端--公海客户--点击更多--无法领取客户（具体见附件视频）
                $buttonArr['receive']=$this->focus->logic->receivebtn['receive'] ;
            }
        }
        */
        $buttonTransferArr = array(
            'edit' => 'edit',
            'moduledetailedit' => 'edit',
            'massallocate' => 'allocateaccount',
            'allocate' => 'distribute',
            'delete' => 'delete',
            'cancel' => 'cancelapprove',
            'submit' => 'submitapprove',
            'approve' => 'approvepermit',
            'advance' => 'advance',
            'advancecomplete' => 'advancecomplete',
            'share' => 'share',
            'copy' => 'copy',
            'moduledetailcopy' => 'copy',
            'approve_retrace' => 'retracement',
            'expediting'=>'expediting',
            'print'=>'print',//zxm 2020-1105 增加另存为pdf按钮
            //工单管理新增功能按钮
            'receive'=>'receive',
            'urged'=>'urged',
            'solution'=>'solution',
            'ended'=>'ended',
            'reopen'=>'reopen',
            'submit_warehousetransfer'=>'submit_warehousetransfer',
            'generatepaymentcode'=>'generatepaymentcode',
            'renew'=>'renew',
            'seniorallocate'=>'seniorAllocate',
            'seniorshare'=>'seniorShare',
            'seniorhigndistribution'=>'seniorHigndistribution',
            'recalculationbudget'=>'reCalculationBudget',
            'decryptcolumn'=>'decryptcolumn',
        );

        //【系统参数设置，增加【设置移动端单据详情界面是否启用另存为PDF格式功能】】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001300
        // $print_sql = "select deploy_value from ld_systems_deploy where deploy_type=268";
        // $print_res = $adb->pquery($print_sql);
        // $isHavePrint = $adb->query_result($print_res,0,'deploy_value');
        $Sys_268 = getSys_deploy(268);
        $isHavePrint = $Sys_268['deploy_value'];
        if($isHavePrint == 1){
            unset($buttonTransferArr['print']);
        }
        //设置是否仅允许系统管理员用户和负责人共享单据。1:否，0:是
        $Sys_33 = getSys_deploy(33);
        if($Sys_33['deploy_value'] == 0){
            if (strtolower($current_user->is_admin) == 'on') {
                
            }else{
                $userid_str = $this->focus->column_fields['assigned_user_id'];
                $userid_arr = explode(',',$userid_str);
                if(!in_array($current_user->id,$userid_arr)){
                    unset($buttonTransferArr['share']);
                    unset($buttonTransferArr['seniorshare']);
                }
            }
        }
        //zxm 20230703 PC端设置  pdf未开启则不显示该按钮
        $PrintSettingCategories = getUsersettingByLabel($this->module, 1, 'PrintSettingCategories');
        $PrintSettingCategoriesArr = explode(',', $PrintSettingCategories);
        if (in_array('toPDF', $PrintSettingCategoriesArr)) {
            unset($buttonTransferArr['print']);
        }
        
        //$buttonTransferArr = $this->checkEditPerimssion($buttonTransferArr);
        $init_button_new = [];
        foreach ($buttonArr as $buttonname => $detail) {
            $buttonname = strtolower($buttonname);
            $wxbuttonname = $buttonTransferArr[$buttonname];

            if (!empty($wxbuttonname) && $detail['permit'] == 'yes') {
                $init_button_new[] = $wxbuttonname;
            }
            else if($detail['custombtn'] == 'yes' && $detail['permit'] == 'yes'){
                $init_button_new[] = $buttonname;
            }

            if ($buttonname == 'more') {
                foreach ($detail['list'] as $morebutton => $moredetail) {
                    $morebutton = strtolower($morebutton);
                    $wxmorebutton = $buttonTransferArr[$morebutton];
                    if (!empty($wxmorebutton) && $moredetail['permit'] == 'yes') {
                        // //设置是否仅允许系统管理员用户和负责人共享单据。1:否，0:是
                        // if($wxmorebutton == 'share' || $wxmorebutton == 'seniorshare'){
                        //     $deployarray=getSys_deploy(33);
                        //     if($deployarray['deploy_value'] == 0){
                        //         if (strtolower($current_user->is_admin) == 'on') {
                        //             $init_button_new[] = $wxmorebutton;
                        //         }else{
                        //             $userid_str = $this->focus->column_fields['assigned_user_id'];
                        //             $userid_arr = explode(',',$userid_str);
                        //             if(in_array($current_user->id,$userid_arr)){
                        //                 $init_button_new[] = $wxmorebutton;
                        //             }
                        //         }
                        //     }else{
                        //         $init_button_new[] = $wxmorebutton;
                        //     }
                        // }
                        // else if($wxmorebutton == 'print'){
                        //     //zxm 20230703 PC端设置  pdf未开启则不显示该按钮
                        //     $PrintSettingCategories=getUsersettingByLabel($this->module,1,'PrintSettingCategories');
                        //     $PrintSettingCategoriesArr = explode(',',$PrintSettingCategories);
                        //     if(in_array('toPDF',$PrintSettingCategoriesArr)){
                        //         continue;
                        //     }
                        //     else{
                        //         $init_button_new[] = $wxmorebutton;
                        //     }

                        // }
                        // else{
                            $init_button_new[] = $wxmorebutton;
                        // }
                    }else if($moredetail['custombtn'] == 'yes' && $moredetail['permit'] == 'yes'){
                        $init_button_new[] = $morebutton;
                    }
                }
            }
        }
        // if (0 == $deploy_value) {
            // $this->jsonArr['listapprove'] = $this->getApproveList();
        // }

        $this->jsonArr['list2'] = $init_button_new;

        return false;
    }

    public function getBlockFields($module, $disp_view, $mode, $col_fields = '', $info_type = '')
    {

        global $adb, $current_user;
        global $mod_strings;
        $tabid = getTabid($module);
        //require(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
        $languageType= getLanguageType($current_user);

        if ($module == 'Events') $tabid = 16;
        $block_detail = Array();
        $getBlockinfo = "";
        //and $disp_view=0:pc端没有用
        $query = "select blockid,case when ifnull(ld_tranlabel.fieldlabel,'')='' then blocklabel else ld_tranlabel.fieldlabel end as blocklabel
                 ,show_title,display_status from ld_blocks inner join ld_tranlabel
             on ld_blocks.blockid=ld_tranlabel.relateid where ld_blocks.tabid=? and ld_tranlabel.tabid = ?  and visible = 0 and ld_tranlabel.languagetype='$languageType' and trantable='ld_blocks'  order by sequence";

        $result = $adb->pquery($query, array($tabid, $tabid));

        $noofrows = $adb->num_rows($result);

        $prev_header = "";
        $blockid_list = array();
        for ($i = 0; $i < $noofrows; $i++) {
            //0034116: （珞落计划企业微信登录）附件管理模块：“允许查看或下载”字段值为“否”时，附件可以查看
            //editor:gyq_143 reason:附件管理：增加操作权限【下载】和【预览】,移动端只管预览权限  2019/9/10 11:48 ID1000603
            $blocklabel = $adb->query_result($result, $i, "blocklabel");
            $blockid = $adb->query_result($result, $i, "blockid");
            array_push($blockid_list, $blockid);
            $block_label[$blockid] = $blocklabel . '|##|' . $adb->query_result($result, $i, "display_status");
        }
        require(globalStatic::$root_directory . 'user_privileges/user_privileges_' . $current_user->id . '.php');

        if ($disp_view == "detail_view") {

            $getBlockInfo = $this->getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode);

        } else {
            $getBlockInfo = $this->getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode);
            //处理级联带出下拉值问题 xxs 2017-09-29
            if (!empty($_REQUEST['optionarr'])) {
                $optionarr = $_REQUEST['optionarr'];
                foreach ($getBlockInfo as $key => $val) {
                    foreach ($val['fieldinfo'] as $okey => $oval) {
                        if (array_key_exists($oval['fieldname'], $optionarr)) {
                            $getBlockInfo[$key]['fieldinfo'][$okey]['option'] = $optionarr[$oval['fieldname']];
                            //duan 20230301 修复移动端编辑时区域字段没有值的问题
                            if($oval['uitype'] == 15){
                                $tmp_origin_value = $oval['picklist_origin_value'];
                                $tmp_arr = $optionarr[$oval['fieldname']];
                                if(is_array($tmp_arr) && sizeof($tmp_arr)>0){
                                    foreach($tmp_arr as $tmp_valueinfo){
                                        if($tmp_valueinfo['value'] == $tmp_origin_value){
                                            $getBlockInfo[$key]['fieldinfo'][$okey]['text'] = $tmp_origin_value;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                unset($_REQUEST['optionarr']);
            }
        }

        if (count($getBlockInfo) > 0) {
            foreach ($getBlockInfo as $label => $contents) {

                if (empty($getBlockInfo[$label]) && $label != getFixedLabel('RECORDSOFOPERATION')) {
                    unset($getBlockInfo[$label]);
                }
            }
        }
        return $getBlockInfo;
    }

    public function getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode)
    {
        global $adb;
        global $current_user, $weixin_user;
        $label_data = Array();
        $prevblock = 0;
        if($module == 'Users'){
            //duan 20221012 因为登陆时生成了用户模块field对象的缓存，所以重新获取一次更新语言类型
            $fieldobj = new Field($module, $adb);
        }else{
            $fieldobj = Field::getInstance($module, $adb);
        }

        $moduleFields = $fieldobj->getModuleFields();
        $focus=CRMEntity::getInstance($module);

        //editor:gyq170825
        //$noofrows = $adb->num_rows($result);
        $i = 0;
        //非管理员  控制只读字段不在模块的新增和编辑时显示
        if ($current_user->is_admin == 'off') {
            $profileobj = Profile::getInstance();
            $profilefields = $profileobj->getProfileInfos($current_user->profileid);
            $profilefields = $profilefields['field'];
        }

        //editor:gyq_113 reason:新增知识管理模块,不再每个循环都实例化类  2019/5/23 11:40
        if ($mode == 'detail') {
            crm_load_class_file("cls_DetailViewOutPutWX", 'WeiXinApp/detail');
            $detailView_htmlobj = new cls_DetailViewOutPutWX();

            //editor:gyq_143 reason:附件管理：增加操作权限【下载】和【预览】,移动端只管预览权限  2019/9/10 11:48 ID1000603
            //duan 20220830 附件预览按照预览和下载权限控制
            //$permit_file = IsPreviewProfile($this->record, $this->module);
        } else {
            crm_load_class_file("cls_EditViewOutPutWX", 'WeiXinApp/detail');
            $detailView_htmlobj = new cls_EditViewOutPutWX();

            //链接模块新增、编辑设置高级查询条件数组
            if(isset($_REQUEST['linkemodule_viewname']))
            {
                crm_load_class_file('CommonView',"modules/CustomView");
                $customviewobj=CustomView::getInstance($module);
                $advfilter_arr = array();
                $linkmodule_cvid = $_REQUEST['linkemodule_viewname'];
                $advfilter_arr=$customviewobj->getAdvFilterByCvid($linkmodule_cvid);
                $detailView_htmlobj->setAdvFilter($advfilter_arr);
            }
        }
        //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
        crm_load_class_file('cls_fieldsearchcondition','include/utils/');
        $cls_fieldsearchconditionobj = cls_fieldsearchcondition::getInstance($module);
        $cls_fieldsearchconditionobj->setColumnValuesbyfieldnamearr($col_fields);
        $cls_fieldsearchconditionobj->setRecord($focus->id);

        //敏感规则
        crm_load_class_file("cls_fieldSensitiverule", "include/fields");
        $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
        $cls_fieldSensitiveruleobj->setColumnValuesbyfieldnamearr($col_fields);
        $cls_fieldSensitiveruleobj->setRecord($focus->id);
        //XUQIU20240703-03 敏感规则，增加“禁用场景”参数，支持自定义设置模块列表或相关信息列表加密方式生效范围（安康金源）
        $cls_fieldSensitiveruleobj->setApplicationScene('DetailView');
        $sensitiveresultinfo = $cls_fieldSensitiveruleobj->getSensitiveResultInfobyColumnname();
        $needtriggerfield = $cls_fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();
        $needtriggerfield_array = [];
        if(count($needtriggerfield) > 0){
            foreach($needtriggerfield as $tmp_fieldname => $tmpfieldarr){
                for($index = 0;$index<count($tmpfieldarr);$index++){
                    $needtriggerfield_array[] = $tmpfieldarr[$index];
                }
            }
        }
        $needtriggerfield_array = array_unique($needtriggerfield_array);

        //duan 20240125 小编辑触发布局规则进入大编辑界面，根据
        if(!empty($_REQUEST['miniedit_fieldrule']) && !empty($_REQUEST['fieldvaluejson'])){
            $fieldvaluejson = $_REQUEST['fieldvaluejson'];
            $fieldvalue_arr = ldcrm_json_decode($fieldvaluejson);
            foreach ($fieldvalue_arr as $tmp_key => $tmp_value){
                $col_fields[$tmp_key]=urldecode($tmp_value);
            }
        }

        //跟踪方式设置为指定期间，当有推进记录产生后没有控制期间字段不可编辑
        /*
        edit:huangjian_chen
        date:2020-07-10
        reposon: 字段推进时，可以在编辑页显示，因为考虑到布局规则。所以这里去除原先的判断
        */
        //if(!empty($_REQUEST['record']) && $_REQUEST['record'] > 0 && empty($_REQUEST['isDuplicate']) && $mode =='edit'){
        //crm_load_class_file('cls_module_advance','modules/Settings');
        //$cls_module_advance = new cls_module_advance($module);
        // $advance_fieldnames = $cls_module_advance->is_AdvanceRecord($_REQUEST['record']);
        //}

        foreach ($moduleFields as $fieldname => $fieldinfo) {
            $maxlength = $fieldinfo->getMaximumLength();
            $generatedtype = $fieldinfo->getGeneratedtype();
            $typeofdata = $fieldinfo->getTypeOfData();
            $fieldonly = $fieldinfo->getfieldOnly();
            $block = $fieldinfo->getBlockId();
            $displaytype = $fieldinfo->getDisplayType();
            $uitype = $fieldinfo->getUIType();
            $columnname = $fieldinfo->getColumnName();
            $label_style = $fieldinfo->getLabelStyle();
            // ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
            $disallowed_copy = $fieldinfo->getDisAllowedCopy();
            //editor:gyq_20191011 参考自include\utils\EditViewUtils.php 133
            //0038246: （http://47.102.85.179:85/crm [^] ）企业微信>灵当CRM>客户模块>选择单据编号为【DX114728】进入编辑界面：修改任意字段值保存，保存后【联系电话】字段值中间四位自动隐藏了，使用pc端编辑没有该问题。

            //ls 2022-03-31  呼博士 为’国内营销代理商‘的角色用户 页面 隐藏负责人，新增编辑详情都不显示
            $versiontrade = getVersionTradeInfo();
            $account = $versiontrade['account'];

            if ($account == 'huboshi' && in_array($module,array('Accounts','Contacts','CustomForm12','SalesOrder','OutboundOrder'))) {
                $smownercolumnname=$focus->getSmownerColumName();
                if ($columnname == $smownercolumnname){
                    $tmp_sql = "select p.profilename from ld_profile p LEFT JOIN ld_users u ON p.profileid = u.profileid where u.id = ?";
                    $tmp_result = $adb->pquery($tmp_sql, array($current_user->id));////获取当前用户的角色id
                    if ($adb->num_rows($tmp_result)>0) {
                        $profilename = $adb->query_result($tmp_result,0,'profilename');
                        if ($profilename == '国内营销代理商') {
                            continue;
                        }
                    }
                }
            }
            //移动端暂时不显示图片类型的字段
            /*if ($uitype == 69 && !in_array($fieldname,array('imagename','sharepicture','cover_url'))) {
                continue;
            }*/
            if ($mode == 'edit' ) {
                if($fieldinfo->getFieldDataType() == 'mobile' && fieldValueUitype::IsShowMobileTextBox($this->record, $this->module) == 'no'){
                    continue;
                }elseif ($uitype==230){
                    //editor:gyq_151 reason:编辑界面不显示插件型备注内容  2019/10/15 19:39 ID1000623
                    continue;
                }
                /*
                edit:huangjian_chen
                date:2020-07-10
                reposon: 字段推进时，可以在编辑页显示，因为考虑到布局规则。所以这里去除原先的判断
                */
                // if(!empty($advance_fieldnames) && in_array($fieldname,$advance_fieldnames)){
                // 	$fieldonly = 'yes';
                // }
            }
            if( $module=='CashBill'&&$col_fields['cashtype']=='debuction'){

                //预收款单隐藏原单
                if($uitype==202)
                {
                    continue;
                }
            }
            //附件
            //if ($permit_file == 'no' && ($uitype == 28 || $uitype == 1109 || $uitype == 1108)) {
//                continue;
//            }
            if ($i == 0) {
                $prevblock = $block;
            }

            if (($mode == '' || strtolower($mode) == 'create')) {
                $defaultvalue = $fieldinfo->getDefaultValue();
                if(empty($col_fields[$fieldname])){
                    $col_fields[$fieldname] = $defaultvalue;
                }
                //duan 20240301 修复移动端用户字段的默认值失效的问题
                if(($uitype==154 || $uitype==153) && !empty($defaultvalue))
                {
                    $tmp_arr=explode(',',$defaultvalue);
                    $tmpuserid_arr=[];
                    foreach($tmp_arr as $tmplastname)
                    {
                        $sql='select id from ld_users where (last_name=? or real_name=?) and deleted=0 and `status`="active" ';
                        $tmpresult=$adb->pquery($sql,array($tmplastname,$tmplastname));
                        if($adb->num_rows($tmpresult)>0)
                        {
                            $tmpuserid_arr[]=$adb->query_result($tmpresult,0,'id');
                        }
                    }
                    $defaultvalue=implode(',',$tmpuserid_arr);
                    $col_fields[$fieldname] = $defaultvalue;
                }
            }
            //0029954:客户新增查看编辑界面，当“首要联系人区块”设为不显示时，地址信息、备注信息、附件信息区块都没有显示出来
            if (!array_key_exists($block, $block_label)) continue;

            //duan 2022-1-14 表单码获取可见字段信息时，去除不可见字段
            if(isset($_REQUEST['qrcode_viewfield']) && sizeof($_REQUEST['qrcode_viewfield'])>0){
                $qrcode_viewfield_arr = $_REQUEST['qrcode_viewfield'];
                if(!in_array($columnname,$qrcode_viewfield_arr)){
                    continue;
                }
            }

            if ($mode == 'detail') {
                if ($displaytype == 3) continue;//display=3 都是属于产品明细区块的信息值，所以在基本里不需要显示
                //if($module == 'Products' && $uitype == 83)continue;	//产品详情页，价格信息区块的税不需要显示。
                $detailView_htmlobj->record = $this->record;

                $custfld = $detailView_htmlobj->getDetailViewOutputHtml($fieldinfo, $col_fields, $generatedtype, $tabid, $module);

                if (!empty($_REQUEST['tempSourceField'])) {
                    foreach ($_REQUEST['tempSourceField'] as $tempSourceContent) {
                        $label_data[] = $tempSourceContent;
                    }
                    unset($_REQUEST['tempSourceField']);
                }
                //XUQIU1001840 ls 20230905 特瑞普功能定制开发(移动端详情页)
                if ($account == 'teruipu' && $module == 'Potentials' && ($current_user->profileid == 54 || $current_user->profileid == 48) && $fieldinfo->getColumnname() == 'cf_7530'){
                    $approvestatus_po = $adb->query_result($adb->pquery("select approvestatus from ld_potential where potentialid=?",array($this->record)),0);
                    if ($approvestatus_po != '已批准') continue;
                }
                if(!is_array($custfld))
                {
                    //字段没有值，手机端查看界面不显示
                   continue;
                }
            }
            else {
                // ljj 2023-08-16 XUQIU1001425 页面设置，字段增加“不允许复制”字段属性（邬丹华、东方报警）
                if ($weixin_user->action == 'is_duplicate') {
                    if($disallowed_copy=='yes') {
                        $col_fields[$fieldname] = $fieldinfo->getDefaultValue();
                    }
                }
                $fieldid = $fieldinfo->getFieldid();
                //编辑时只读的字段在详情界面时，显示但不可编辑，
                if( !empty($profilefields) && $profilefields[$fieldid]['editreadonly']==1 && (isset($_REQUEST['record'])&&($_REQUEST['action']=='EditView'||$_REQUEST['action']=='getAdvanceRelationInfo'||$_REQUEST['action']=='showpagerule'))){
                    $fieldinfo->set_allowedit('no');
                }
                //duan 20221115泰康特殊开发，移动端终端用户（供应商）模块新建编辑时，地址字段不可编辑
                if($account == 'taikang' && $fieldname == 'street' && $module == 'Vendors'){
                    $fieldinfo->set_allowedit('no');
                }
                //工单管理解决方案显示部分字段
                if($module=='WorkSheet'&&$_REQUEST['get_solution']!=''&&$_REQUEST['get_solution']=='yes'){
                    //问题描述不允许编辑
                    if($columnname == 'description'){
                        $fieldinfo->set_allowedit('no');
                        $typeofdata = str_replace('M','O',$typeofdata);
                        $fieldinfo->settypeOfData($typeofdata);
                    }
                    //解决方案界面只显示固定的字段
                    if(in_array($columnname,$this->focus->solution_columnname)){
                        $fieldinfo->setDisplaytype(1);
                        $fieldinfo->set_allowedit('yes');
                        $displaytype = 1;
                        if (!empty($profilefields)){
                            $profilefields[$fieldid]['readonly'] = 0;
                        }
                    }else{
                        $fieldinfo->setDisplaytype(2);
                        $displaytype = 2;
                    }
                }
                //editor:gyq_20181129 0035628: 企业微信>珞落计划>普通用户登录>客户模块新增编辑界面：当一个字段设置了只允许查看权限的时候，在企业微信中还能看到这个字段，PC端是看不到这个字段的
                if (!empty($profilefields) && $profilefields[$fieldinfo->fieldid]['readonly'] == 1) continue;

                if ($displaytype != 1 && $displaytype != 4) continue;
                //editor:gyq_20180906	0035154: （珞落计划企业微信登录）新建界面：地址信息区块“地图”字段应不显示（客户模块测试）
                //edit:chj 2020/11/27 43310: （企业微信-kfbcrm）客户管理-客户-新增；在移动端客户新增的界面，标签是可输入的形式；在客户新增时应当不显示
                if ($uitype == '64' || $uitype == '301') continue;
                $detailView_htmlobj->record = $this->record;
                $curapproveformodulefield = array();
                if(!empty($this->record)&&$weixin_user->action != 'is_duplicate'){
                    //编辑且不是复制
                    $approve=new Approve();
                    $curapproveformodulefield = $approve->getCurApproveForModulefield($this->record);
                }else if($mode == 'showpagerule' && $_REQUEST['record']>0){
                    $approve=new Approve();
                    $curapproveformodulefield = $approve->getCurApproveForModulefield($_REQUEST['record']);
                }
                if ($weixin_user->action == 'is_duplicate') {

                    //edit:can 20220601 复制已批准的单据有问题
                    unset($_REQUEST['record']);
                }

                $custfld = $detailView_htmlobj->getEditViewOutputHtml($fieldinfo, $maxlength, $col_fields, $generatedtype, $module, $mode, $typeofdata, $fieldonly, $curapproveformodulefield);


                if($custfld['uitype'] && ($custfld['uitype'] == 1109 || $custfld['uitype'] == 69)){
                    $tmp_attaarr = [];
                    if(!empty($custfld['text']) && count($custfld['text']) > 0) {

                    }
                    else {
                        if($custfld['value_name'] && count($custfld['value_name']) > 0){
                            unset($custfld['value_name'][$custfld['fieldname'].'-file_num']);
                            $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                            $tmp_fileinfoarr = [];
                            $tmp_attaarr = [];
                            for($i = 0;$i < count($custfld['value_name']);$i++){
                                $tmp_fileinfo = $custfld['value_name'][$i];
                                $new_tmp_fileinfo = [];
                                $new_tmp_fileinfo['path'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['file_path']);
                                $new_tmp_fileinfo['newfile_name'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['newfile_name']);
                                $new_tmp_fileinfo['cloud_path'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['cloud_path']);
                                $new_tmp_fileinfo['id'] = $tmp_fileinfo['fileid'];
                                $new_tmp_fileinfo['storage_location'] = $tmp_fileinfo['storage_location'];
                                $new_tmp_fileinfo['httppath'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['file_path']).$cls_MyCRMcrypt->decode($tmp_fileinfo['newfile_name']);
                                $new_tmp_fileinfo['name'] = $tmp_fileinfo['file_name'];
                                $new_tmp_fileinfo['type'] = $tmp_fileinfo['file_type'];
                                $new_tmp_fileinfo['size'] = $tmp_fileinfo['file_size'];
                                $new_tmp_fileinfo['imagefromtype'] = $tmp_fileinfo['imagefromtype'];
                                $new_tmp_fileinfo['isEncrypt'] = 'no';
                                $tmp_fileinfoarr[] = $new_tmp_fileinfo;
                            }
                            $custfld['text'] = $tmp_fileinfoarr;

                        }
                    }
                    if(!empty($custfld['text']) && count($custfld['text']) > 0){
                        for($i=0;$i <count($custfld['text']);$i++){
                            if($custfld['text'][$i]['httppath'] && !empty($custfld['text'][$i]['httppath'])){

                            }else{
                                $custfld['text'][$i]['httppath'] = $custfld['text'][$i]['path'].$custfld['text'][$i]['newfile_name'];
                            }
                            $fileinfo =$custfld['text'][$i];
                            $tmp_attainfo = [];
                            //edit: xll 2024/07/16 XUQIU20240628-14 附件字段增加下载预览权限的单据条件控制
                            foreach ($fileinfo as $key => $val) {
                                $tmp_attainfo[$key] = $val;
                            }
                            $tmp_attainfo['cloud_path'] = $fileinfo['path'].$fileinfo['newfile_name'];
                            $tmp_attaarr[] = $tmp_attainfo;
                        }
                    }
                    if($custfld['uitype'] == 1109){
                        $custfld['uploadAttList'] = $tmp_attaarr;
                    }elseif ($custfld['uitype'] == 69){
                        $custfld['uploadImgList'] = $tmp_attaarr;
                    }
                }
                //编辑时只读权限，下拉框字段小程序编辑界面显示并可以保存，
                $custfld['bigtype']=$fieldinfo->getBigType();
                $custfld['savedatabase']=$fieldinfo->getSaveDataBase();
                if( $uitype=='15'&&!empty($profilefields) && $profilefields[$fieldid]['editreadonly']==1 && (isset($_REQUEST['record'])&&($_REQUEST['action']=='EditView'||$_REQUEST['action']=='getAdvanceRelationInfo'))){
                    $custfld['type']=1;
                }
                //下拉框字段readonly为yes时，应可以保存
                else if($uitype=='15'&& $custfld['readonly']=='yes') {
                    $custfld['type']=1;
                }
                $custfld['savedatabase']=$fieldinfo->getSaveDataBase();
                $custfld['bigtype']=$fieldinfo->getBigType();
                $custfld['relatedmodulefield']=$fieldinfo->getRelatedModuleField();
                $fieldid = $fieldinfo->getFieldid();
                $custfld['columnname'] = $columnname;
                if ($this->getRelatedForFieldid($fieldid) == 'yes')
                    $custfld['is_relatedfield'] = $this->getRelatedForFieldid($fieldid);
                if (!empty($_REQUEST['tempSourceField'])) {
                    $label_data[] = $_REQUEST['tempSourceField'];
                    unset($_REQUEST['tempSourceField']);
                }

            }
            //敏感规则
            $custfld['sensitivepresence'] = 'no';
            $custfld['havesensitivevalue'] = 'no';
            if(!empty($sensitiveresultinfo)){
                if($fieldinfo->gethavesensitivevalue() == 'yes'){
                    $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
                    $tmpcolumn_value = $custfld['text'];
                    $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($fieldinfo,$tmpcolumn_value);
                    $custfld['sensitivepresence'] = 'yes';
                    $custfld['havesensitivevalue'] = 'no';
                    $custfld['sensitiveencryptvalue'] = '';
                    if(!empty($tmpcolumn_value_arr)){
                        $custfld['text'] = $tmpcolumn_value_arr['secretvalue'];
                        $custfld['havesensitivevalue'] = 'yes';
                        $custfld['sensitiveencryptvalue'] = $tmpcolumn_value_arr['encryptvalue'];
                    }
                }
            }
            if(count($needtriggerfield_array) > 0){
                if(in_array($columnname,$needtriggerfield_array)){
                    $custfld['needtriggersensitive'] = 'yes';
                }
            }
            //工商查询
            $custfld['businessquery'] = $fieldinfo->getbusinessquery();
            $custfld['isenablebusiness'] = $fieldinfo->getenablebusiness();
            $custfld['isenablebusinessfuzzyquery'] = $fieldinfo->getenablebusinessfuzzyquery();
            // 帮助信息
            $custfld['helptips'] = $fieldinfo->getHelptips();
            $custfld['fieldlabelstyle'] = $label_style;

            if (!is_array($custfld)) {
                continue;
            }

            //移动端将前端class返回
            if ($mode == 'detail') {

            }
            else{//新增编辑界面
                $custfld['cellclass'] = '';
                if($custfld['fieldname']){
                    if($custfld['fieldname'] == 'accountname' && ($module == 'Accounts' || $module == 'ServiceCharge')){
                        $custfld['cellclass'] = ' weui-cell_vcode';
                    }
                    if($custfld['fieldname'] == 'vendorname' && $module == 'Vendors'){
                        $custfld['cellclass'] = ' weui-cell_vcode';
                    }
                    if($custfld['fieldname'] == 'potentialname' && $module == 'Potentials'){
                        $custfld['cellclass'] = ' weui-cell_vcode';
                    }
                    if($custfld['fieldname'] == 'productname' && $module == 'Products'){
                        $custfld['cellclass'] = ' weui-cell_vcode';
                    }
                    if($custfld['fieldname'] == 'express_no'){
                        $custfld['cellclass'] = ' weui-cell_vcode';
                    }
                }
                if($custfld['isenablebusiness'] && $custfld['isenablebusiness'] == 'yes'){
                    $custfld['cellclass'] = ' weui-cell_vcode';
                }
                if($custfld['type'] && $custfld['type'] == 2){
                    $custfld['cellclass'] = ' weui-cell_switch';
                }
            }
            if ($prevblock != $block) {
                $block_labelArr = explode("|##|", $block_label[$prevblock]);
                if ($block_labelArr[0] != '' && $block_labelArr[0] != null) {
                    $labelfield['blocklabel'] = $block_labelArr[0];
                    $labelfield['display_status'] = $block_labelArr[1];

                    $labelfield['fieldinfo'] = $label_data;
                    $blockinfos[] = $labelfield;
                    $label_data = array();
                    $labelfield = array();
                    $prevblock = $block;
                    $label_data[] = $custfld;
                }
            } else {
                $label_data[] = $custfld;
            }
            $columnvalues[$columnname] = $custfld['value_name'];


            $i++;
        }

        //区块显隐
        $block_labelArr = explode("|##|", $block_label[$prevblock]);
        if ($block_labelArr[0] != '' && $block_labelArr[0] != null) {
            $labelfield['blocklabel'] = $block_labelArr[0];
            $labelfield['display_status'] = $block_labelArr[1];
            $labelfield['fieldinfo'] = $label_data;
            $blockinfos[] = $labelfield;
        }
        if ($mode == 'detail'){
            $pagemode = 'detail';
        }else{
            $pagemode = 'edit';
        }

        crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
        crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
        $detailfieldruleobj=cls_detailfieldrule::getInstance($module);
        $detailfieldruleobj->set_pagemode($pagemode);
        $detailfieldruleobj->setColumnValues($columnvalues);
        $fieldrulecolsproperty= $detailfieldruleobj->getFieldRuleProperty();//明细布局规则字段的隐藏和必填项

        //布局规则

        $fieldruleobj = cls_fieldrule::getInstance($module);
        $fieldruleobj->set_pagemode($pagemode);
        $fieldruleobj->setColumnValues($columnvalues);
        $fieldrulecolsproperty = $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项





        //布局规则重新设置界面显示
        $hidecolumns = $fieldrulecolsproperty['hidecolumns'];//隐藏的字段


        $requiredcolumns = $fieldrulecolsproperty['requiredcolumns'];//必填字段

        $tmpblockinfos = $blockinfos;

        $tmpblockindex = 0;
        $selectsourcename_del = 'no';
        foreach ($tmpblockinfos as $blockindex => $blockfieldinfo) {
            $tmpfieldindex = 0;
            $isdeleteblock = 'no';

            foreach ($blockfieldinfo['fieldinfo'] as $fieldindex => $tmpfieldinfo) {
                $fieldinfo = $moduleFields[$tmpfieldinfo['fieldname']];
                //editor:gyq_20190820  reason:选择源单字段前，特殊插入的源单类型字段，增加特殊标识tempfield=1
                if (isset($tmpfieldinfo['tempfield'])) {
                    $tmpfieldindex++;
                    continue;
                }
                if (!$fieldinfo) {
                    $tmpfieldindex++;
                    continue;
                }
                $tmpcolumnname = $fieldinfo->getColumnName();
                if($tmpcolumnname == 'servicecharge_id' && $mode == 'detail'){
                    if($fieldinfo -> get_ShowHyperlinks() == 'yes')
                        $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['relatemodule'] = 'ServiceCharge';
                }

                if (in_array($tmpcolumnname, $hidecolumns) || ($tmpfieldinfo['fieldname'] == 'selectsourcename' && in_array('source_list', $hidecolumns))) {
                    //隐藏字段
                    if($tmpcolumnname == 'source_list'){
                        $selectsourcename_del = 'yes';
                    }
                    array_splice($blockinfos[$tmpblockindex]['fieldinfo'], $tmpfieldindex, 1);
                    if (sizeof($blockinfos[$tmpblockindex]['fieldinfo']) <= 0) {

                        array_splice($blockinfos, $tmpblockindex, 1);
                        $isdeleteblock = 'yes';
                    }
                    continue;
                } else if (in_array($tmpcolumnname, $requiredcolumns)) {

                    $blockinfos[$tmpblockindex]['fieldinfo'][$tmpfieldindex]['fieldtype'] = "M";
                }
                $tmpfieldindex++;
//                if($tmpfieldinfo['columnname']=='filename'){
//                    dump($tmpfieldinfo);
//                }


            }
            if ($isdeleteblock == 'no')//区块是0,1,2,3排序的，所以有次判断
                $tmpblockindex++;
        }

        if($selectsourcename_del == 'yes'){
            foreach ($blockinfos as $key1 => $value1) {
                foreach ($value1['fieldinfo'] as $key2 => $value2) {
                    if($value2['fieldname'] == 'selectsourcename') {
                        array_splice($blockinfos[$key1]['fieldinfo'], $key2, 1);
                        break;
                    }
                }
            }
        }
        //editor:gyq_151 reason:移动端，知识管理详情界面插件型备注无法查看PC端上传的附件及图片  2019/10/15 19:33 ID1000623
        if (!empty($detailView_htmlobj->uitype230)) {
            foreach ($blockinfos as $key1 => $value1) {
                foreach ($value1['fieldinfo'] as $key2 => $value2) {
                    if ($value2['uitype'] == 230) {
                        $blockinfos[$key1]['fieldinfo'] = array_values(array_merge($blockinfos[$key1]['fieldinfo'], $detailView_htmlobj->uitype230));
                        break;
                    }
                }
            }
        }
        return $blockinfos;
    }

    public function getRelatedForFieldid($fieldid)
    {
        global $adb;
        $query = 'select * from ld_related_field where trigger_fieldid = ?';
        $result = $adb->pquery($query, array($fieldid));
        if ($adb->num_rows($result)>= 1) {
            return 'yes';
        } else {
            return 'no';
        }
    }

    //xiaoguang 2017-01-12
    public function getApproveList()
    {
        $approvelog = array();
        $record = $_REQUEST['record'];
        $module = $_REQUEST['module'];
        if ($module == 'ServiceCharge') $module = 'Accounts';
        //echo $currentModule;echo '<br>';die;
        crm_load_class_file('Approve', 'modules/Approve');
        $approve = new Approve();
        //判断当前模块是否开启审批，未开启的话就不显示审批历史
        $approvemod = $approve->getApproveModuleInfo();
        if (!isset($approvemod[$module])) {
            return $approvelog;
        }
        $approvelog = $approve->approveLog($record);
        $j = sizeof($approvelog);
        for ($i = 0; $i < sizeof($approvelog); $i++) {
            $stepname = $approvelog[$i]['STEPNAME'];
            if ($stepname == '' || $stepname == null) {
                $approvelog[$i]['STEPNAME'] = '';
            } else {
                $approvelog[$i]['STEPNAME'] = $j . '.' . $approvelog[$i]['STEPNAME'];
            }
            $nextstepbyname = $approvelog[$i]['NEXTSTEPBYNAME'];
            $j--;
        }
        if (!empty($approvelog)) {
            return $approvelog;
        } else {
            return $approvelog;
        }
    }

    /**
     * 数量和单价字段系统参数
     * @param 2016-09-22
     * @return
     * @author Chj
     */
    public function getSystemForPoint()
    {
        //单据明细中数量小数位数
        $deployarray_49 = getSys_deploy(49);
        $sys_49 = $deployarray_49['deploy_value'];
        //设置单据分录明细中单价字段小数位数
        $deployarray_93 = getSys_deploy(93);
        $sys_93 = $deployarray_93['deploy_value'];
        //单据头和单据分录“金额/货币”类型
        $deployarray_351 = getSys_deploy(351);
        $sys_351 = $deployarray_351['deploy_value'];
        $systemPoint = array('sys_49' => $sys_49, 'sys_93' => $sys_93,'sys_351'=>$sys_351);
        return $systemPoint;
    }

    /**
     * 获取客户联系人相关信息
     * @param 2016-09-22
     * @return
     * @author Chj
     */
    public function getAccountsContactsInfo($focus, $popup = '')
    {
        //gyq161216 新增包含文件
        require_once(globalStatic::$root_directory . 'include/utils/DetailViewUtils.php');
        global $adb, $current_user;
        //获取客户和联系人区块信息
        $block_info = getBlockDisplayInfo('AccountContacts');
        $is_display = $block_info['is_display'];//是否显示,0显示；1不显示
        $display_position = $block_info['display_position'];//显示位置，0第一个区块；1最后一个区块
        //关联客户及其联系人信息
        if (array_key_exists('account_id', $focus->column_fields))
            $accountPresence = 0;
        else
            $accountPresence = 1;
        if (array_key_exists('contact_id', $focus->column_fields))
            $contactPresence = 0;
        else
            $contactPresence = 1;

        $BeFieldPresence = array('Accounts' => $accountPresence, 'Contacts' => $contactPresence);
        if ($accountPresence == 0) {
            if (empty($popup)) {
                $BeModuleInfo['accountid'] = $focus->column_fields['account_id'];
            } else {
                $BeModuleInfo['accountid'] = $_REQUEST['accountid'];
            }
        }

        if ($contactPresence == 0) {
            if (empty($popup)) {
                $BeModuleInfo['contactid'] = $focus->column_fields['contact_id'];
            } else {
                $BeModuleInfo['contactid'] = $_REQUEST['contactid'];
            }
        }


        foreach ($BeModuleInfo as $key => $beRecordid) {
            $innerSql = '';
            switch ($key) {
                case 'accountid':
                    $beTabid = getTabid('Accounts');
                    break;
                case 'contactid':
                    $beTabid = getTabid('Contacts');
                    break;
                default;
            }
            $beModule = getTabname($beTabid); //关联模块名称
            if ($beModule == 'Accounts')
                $col_fields_module[$beModule]['record_id'] = $_REQUEST['accountid'];
            else if ($beModule == 'Contacts')
                $col_fields_module[$beModule]['record_id'] = $_REQUEST['contactid'];

            if (!empty($beTabid) && $BeFieldPresence[$beModule] != 1) {
                $focusModule = CRMEntity::getInstance($beModule);
                $fieldobj = $focusModule->fieldobj;
                //主表table
                $tablename = $focusModule->table_name;
                $tableindex = $focusModule->table_index;
                $i = 0;
                foreach ($fieldobj->getModuleFields() as $fieldname => $fieldinfo) {
                    if ($fieldinfo->getAssociatedfields() == 0 && $fieldinfo->getAssociatedfields() !== null) {
                        //关联表table
                        $tname = $fieldinfo->getTableName();
                        //关联字段
                        $columnname = $fieldinfo->getColumnName();
                        $uitype = $fieldinfo->getUIType();

                        $moduleColumn[$beModule][$i] = $beModule . '_' . $columnname;
                        //关联查询字段SQL
                        $columnsql[$beModule][$i] = $tname . '.' . $columnname;
                        $columnArr[$beModule][$i] = $columnname;
                        $fieldnameArr[$beModule][$i] = $fieldname;
                        //获取除主表以外的其他表
                        if ($tablename != $tname) {
                            $beAllTable[$beModule][$i] = $tname;
                        }
                        $i++;
                    }
                }
                //关联表连接
                if (!empty($beAllTable) && isset($beAllTable[$beModule])) {
                    //清除数组中相同的值
                    $beAllTable = array_unique($beAllTable[$beModule]);
                    if (!empty($beAllTable)) {
                        foreach ($beAllTable as $innertable) {
                            $innerSql .= " left join $innertable on $tablename.$tableindex = $innertable.$tableindex";
                        }
                    }
                }
                if(is_array($columnsql[$beModule]) && sizeof($columnsql[$beModule])>0){
                    if ($beRecordid > 0) {     //关联客户、联系人的recordid

                        $query = "SELECT ";
                        $query .= implode(',', $columnsql[$beModule]);  //查询字段
                        $query .= " FROM $tablename " . $innerSql . " WHERE $tablename.$tableindex = ?";
                        $result = $adb->pquery($query, array($beRecordid));
                        $num_rows = $adb->num_rows($result);
                        if ($num_rows > 0) {
                            for ($i = 0; $i < count($columnArr[$beModule]); $i++) {
                                $col_fields_module[$beModule][$fieldnameArr[$beModule][$i]] = $adb->query_result($result, 0, $columnArr[$beModule][$i]);
                            }
                        }
                    } else {
                        for ($i = 0; $i < count($columnArr[$beModule]); $i++) {
                            $col_fields_module[$beModule][$fieldnameArr[$beModule][$i]] = '';
                        }
                    }
                }
                $beTableidArr[] = $beTabid;
            }
        }
        if(is_array($beTableidArr))
        {
            $AllTableid = implode(',', (array)$beTableidArr);
            $getBlocksSql = $this->getBlocksSql($AllTableid);
            $result = $adb->pquery($getBlocksSql);
            $accountsContractsArray = getAccountsContractsBlockInformation($result, $col_fields_module);
            $i = 0;
            foreach ($accountsContractsArray as $accountsContractsKey => $accountsContractsLists) {
                $field['blocklabel'] = $accountsContractsKey;
                $field['display_position'] = $display_position;
                foreach ($accountsContractsLists as $lists => $list) {
                    foreach ($list as $fieldnames => $fieldname) {
                        foreach ($fieldname as $key => $value) {
                            if ($key == 'value') {
                                $field['fieldinfo'][$i]['fieldlabel'] = $fieldnames;
                                if ($value == '' || $value == null) {
                                    $value = '';
                                }
                                $field['fieldinfo'][$i]['text'] = $value;
                                $i++;
                            }
                        }
                    }
                }
            }
        }
        if (($accountPresence == 1 && $contactPresence == 1) || $is_display == 1) {
            $field = '';
        }
        return $field;
    }

    //获取客户联系人信息SQL语句
    public function getBlocksSql($AllTableid)
    {
        global $adb, $current_user;
        require(globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php');
        $sql = "SELECT '0' as readonly,ld_field.fieldid,ld_field.tabid,ld_field.columnname,ld_field.tablename,ld_field.uitype,ld_field.defaultvalue,
                ld_field.fieldname,ld_field.block,ld_field.typeofdata,ld_field.masseditable,ld_field.displaytype,ld_field.fieldonly
                ,case when ifnull(ld_tranlabel.fieldlabel,'')='' then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 FROM ld_field inner join  ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
        WHERE ld_field.tabid in ($AllTableid) and ld_tranlabel.tabid in ($AllTableid) AND ld_field.displaytype IN (1,2,4) and ld_field.presence in (0,2)
         and ld_tranlabel.languagetype='$languageType' and ld_tranlabel.trantable='ld_field' and ld_field.associatedfields = 0";
        $sql .= " ORDER BY ld_field.associatedsequence asc ";

        return $sql;
    }

    //收款单出库单：源单模块在微信端不存在的单据，隐藏编辑
    public function checkEditPerimssion($buttonTransferArr)
    {
        if (!in_array($this->module, array('Stock'))) return $buttonTransferArr;

        crm_load_class_file("Detail_Edit_View", 'include/utils');
        $isSourceModule = Detail_Edit_View::getInventoryField('entitytype', $this->record);

        if ($isSourceModule == 'PurchaseInvoice') {
            unset($buttonTransferArr['Edit']);
        }
        return $buttonTransferArr;
    }

    //前端明细界面头部页签写活
    public function init_detailTabInfo()
    {
        $showapprove = 'no';
        $showcomments = 'no';
        $module = $this->module == 'ServiceCharge' ? 'Accounts' : $this->module;
        $deployarray = getSys_Approvedeploy($module);
        if ($deployarray['deploy_value'] === '0' && $module != 'PublicAnnouncement') {
            $showapprove = 'yes';
        }
        if (vtlib_isModuleActive('ModComments') && $module != 'PublicAnnouncement' && $module != 'ModComments') {
            $showcomments = 'yes';
        }
        $tabinfo['approve'] = $showapprove;
        $tabinfo['comments'] = $showcomments;

        $this->jsonArr['tabinfo'] = $tabinfo;
    }

//    //获取源单类型定制信息         //editor:gyq_20190207 0036555: 企业微信：客户服务单、销售机会、联系记录、项目等模块签到功能，没有根据源单类型定制-签到是否启用控制
//    public function   getOptionModule($r_selectmodule)
//    {
//        global $adb;
//        $tabid = getTabid($r_selectmodule);
//        $list_query = 'select op.*,tr.fieldlabel,tr.languagetype
//                from ld_option_module as op
//                left join ld_tranlabel as tr on op.option_tabid = tr.tabid and trantable = ?
//				left join ld_tab on ld_tab.tabid = op.option_tabid
//                where op.tabid=? and ld_tab.presence <> 1 order by sequence';
//        $list_result = $adb->pquery($list_query, array('ld_tab', $tabid));
//        $num_rows = $adb->num_rows($list_result);
//        if ($num_rows) {
//            for ($i = 0; $i < $num_rows; $i++) {
//                $languagetype = $adb->query_result($list_result, $i, 'languagetype');
//                $option_tabid = $adb->query_result($list_result, $i, 'option_tabid');
//                $option_module = getTabModuleName($option_tabid);
//                $focus = CRMEntity::getInstance($option_module);
//                $alltabs[$option_tabid]['label'][$languagetype] = $adb->query_result($list_result, $i, 'fieldlabel');
//                $alltabs[$option_tabid]['presence'] = $adb->query_result($list_result, $i, 'presence');
//                $alltabs[$option_tabid]['isdefault'] = $adb->query_result($list_result, $i, 'default');
//                $alltabs[$option_tabid]['approve_demand'] = $adb->query_result($list_result, $i, 'approve_demand');
//                // @edit:dong @date:2020/07/23 @reason: 签到源单类型定制功能优化  tapd:ID1000705
//                $alltabs[$option_tabid]['required'] = $adb->query_result($list_result, $i, 'required') ==1 ?'yes':'no';
//                $alltabs[$option_tabid]['automaticallysign'] = $adb->query_result($list_result, $i, 'automaticallysign') ==1 ?'yes':'no';
//                $alltabs[$option_tabid]['enablewhenadding'] = $adb->query_result($list_result, $i, 'enablewhenadding');
//                //end tapd:ID1000705
//                $alltabs[$option_tabid]['approve_status'] = $focus->getApproveStatus_label();
//            }
//        }
//        return $alltabs;
//    }
    //editor:gyq_20191231 reason:移动端参数设置增加“设置移动端单据详情界面默认值显示”参数控制 ID1000697
    public function getSystemsDeploy(){
        $content = getSys_deploy(210);
        if($content['deploy_value']==0 && (get_file_address($this->module,'ProductDetails') || get_file_address($this->module,$this->module."DetailFieldsHtml"))){
            $type = 'entry';
        }else{
            $type = 'detail';
        }
        $this->jsonArr['default_show_tab']=$type;

        // 新增界面增加参数
        if ($this->action == 'CreateView') {
            // 收款计划
            if (vtlib_isModuleActive('PaymentPlan') && isPermitted('PaymentPlan', 'Create', '') == 'yes') {
                if($this->module == 'SalesOrder' || $this->module == 'ServiceContracts' || $this->module == 'Invoice'){
                    $this->jsonArr['systems']['auto_create_tip']='no';
                    if($this->module == 'SalesOrder'){
                        $deploy_12 = getSys_deploy(12);
                        if($deploy_12['deploy_value'] == 0){
                            $this->jsonArr['systems']['auto_create_tip']='yes';
                            $this->jsonArr['systems']['auto_create_tip_str']=getFixedLabel('AUTOCREATEPAYMENTPLANTIP');
                        }
                    }
                    if($this->module == 'ServiceContracts'){
                        $deploy_53 = getSys_deploy(53);
                        if(is_array($deploy_53) && $deploy_53['deploy_value'] == 0){
                            $this->jsonArr['systems']['auto_create_tip']='yes';
                            $this->jsonArr['systems']['auto_create_tip_str']=getFixedLabel('AUTOCREATEPAYMENTPLANTIP');
                        }
                    }
                    if($this->module == 'Invoice'){
                        $deploy_137 = getSys_deploy(137);
                        if(is_array($deploy_137) && $deploy_137['deploy_value'] == 1){
                            $this->jsonArr['systems']['auto_create_tip']='yes';
                            $this->jsonArr['systems']['auto_create_tip_str']=getFixedLabel('AUTOCREATEPAYMENTPLANTIP');
                        }
                    }
                }
            }

            // 付款计划
            if (vtlib_isModuleActive('SendPayment') && isPermitted('SendPayment', 'Create', '') == 'yes') {
                if($this->module == 'PurchaseOrder' || $this->module == 'PurchaseInvoice'){
                    $this->jsonArr['systems']['auto_create_tip']='no';
                    if($this->module == 'PurchaseOrder'){
                        $deploy_15 = getSys_deploy(15);
                        if($deploy_15['deploy_value'] == 0){
                            $this->jsonArr['systems']['auto_create_tip']='yes';
                            $this->jsonArr['systems']['auto_create_tip_str']=getFixedLabel('AUTOCREATESENDPAYMENTTIP');
                        }
                    }
                    if($this->module == 'PurchaseInvoice'){
                        $deploy_139 = getSys_deploy(139);
                        if($deploy_139['deploy_value'] == 1){
                            $this->jsonArr['systems']['auto_create_tip']='yes';
                            $this->jsonArr['systems']['auto_create_tip_str']=getFixedLabel('AUTOCREATESENDPAYMENTTIP');
                        }
                    }
                }
            }

            // 新增界面,增加参数
            $deploy_357 = getSys_deploy(357);//设置单据新建界面是否启用暂存功能;1否,0是
            $deploy_357_value = 'no';
            if(is_array($deploy_357)&&$deploy_357['deploy_value'] == 0){
                $deploy_357_value = 'yes';
            }
            $this->jsonArr['systems']['deploy_357_value']=$deploy_357_value;
        }
        if(vtlib_isModuleActive('Productbom') && isPermitted('Productbom') == 'yes'){
            $this->jsonArr['systems']['showProductbom'] = 'yes';
        }
    }


    /**
     * Name: 判断当前模块是否开启了签到原单 并赋值
     * User: Dong
     * Date: 2020/7/23 16:16
     * @param $module
     * @param string $type
     * @return bool
     */
    public function isOpenSignIn($module,$type='none'){
        // @edit:dong @date:2020/08/14 @reason: 使用公共方法
        //$modulelist = getSinginOptionModule();
        // @edit:chj @date:20220427 签到类型字段
        $signin_field = $this->focus->fieldobj->getFieldInfoobjBykey('bigtype','signin');

        crm_load_class_file('cls_fieldrule', 'include/fields/fieldrule');
        $fieldruleobj = cls_fieldrule::getInstance($module);
        $fieldrulecolsproperty = $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        //布局规则重新设置界面显示
        $hidecolumns = $fieldrulecolsproperty['hidecolumns'];//隐藏的字段
        $requiredcolumns = $fieldrulecolsproperty['requiredcolumns'];//必填字段

        $tabid =getTabid($module);
        if(!empty($signin_field)){
            $columnname = $signin_field->getColumnName();
            if($type != 'none'){
                return true;
            }else{
                $typeofdata = $signin_field->getTypeOfData();
                $typedata = explode('~',$typeofdata);
                $required = 'no';
                if($typedata[1] == 'M'){
                    $required = 'yes';
                }
                if(count($requiredcolumns)>0 && in_array($columnname,$requiredcolumns)){
                    $required = 'yes';
                }
                $sign_in = array();
                if(count($hidecolumns)>0 && in_array($columnname,$hidecolumns)){
                    $sign_in['signShow'] = 'no';
                }else{
                    $sign_in['signShow'] = 'yes';
                }
                $sign_in['uuid'] = '';
                $sign_in['latitude'] = '';
                $sign_in['longitude'] = '';
                $sign_in['address'] = getFixedLabel('CLICKTOSIGNIN');
                $sign_in['isdefault'] = ''; //$modulelist[$tabid]['isdefault']
                $sign_in['required'] = $required;
                $sign_in['automaticallysign'] = $signin_field->get_auto_signin();
                if(empty($sign_in['automaticallysign'])){
                    $sign_in['automaticallysign'] = '';
                }
                $sign_in['allowable_distance'] = $signin_field->get_allowable_distance();
                if(empty($sign_in['allowable_distance'])){
                    $sign_in['allowable_distance'] = '';
                }
                $sign_in['allowable_type'] = $signin_field->get_no_signin();
                if(empty($sign_in['allowable_type'])){
                    $sign_in['allowable_type'] = '';
                }
                $sign_in['editviewsign'] = $signin_field->geteditview_signin();
                if(empty($sign_in['editviewsign'])){
                    $sign_in['editviewsign'] = '';
                }
                $sign_in['allowsign'] = 'yes';
                if($this->action == 'EditView' && $signin_field->geteditview_signin() != 'yes'){
                    $sign_in['allowsign'] = 'no';
                }
                $sign_in['editviewresign'] = $signin_field->geteditview_resignin();
                if(empty($sign_in['editviewresign'])){
                    $sign_in['editviewresign'] = '';
                }
                $sign_in['sysaddress'] = '';
                $this->jsonArr['signData'] = $sign_in;
                if($sign_in['allowsign'] == 'yes'){
                    return true;
                }
            }
        }

        if($type != 'none'){
            return false;
        }
    }

    //wyt_220707_1000133_微信小程序附件增加字段显示文件格式信息
    // diony 20220919 优化
    public function getAccept($module){
        global $adb;
        $file_type=[];
        $query='select file_type from ld_attachmentstype where module_name=?';
        $result = $adb->pquery($query,array($module));
        $num_rows = $adb->num_rows($result);
        $accept = array();
        if($num_rows > 0){
            for($i=0; $i<$num_rows; $i++){
                $file_types = $adb->query_result($result,$i,'file_type');
                $file_type[] = $file_types;
                $img_arr = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'ico'];
                if(in_array($file_types, $img_arr) && !in_array('image/*', $accept)){
                    $accept[] = 'image/*';
                    $accept2[] = 'image';
                }
                $doc_arr = ['doc'];
                if(in_array($file_types, $doc_arr) && !in_array('application/msword', $accept)){
                    $accept[] = 'application/msword';
                    $accept2[] = 'file';
                }
                $docx_arr = ['docx'];
                if(in_array($file_types, $docx_arr) && !in_array('application/vnd.openxmlformats-officedocument.wordprocessingml.document', $accept)){
                    $accept[] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                    $accept2[] = 'file';
                }
                $xls_arr = ['xls'];
                if(in_array($file_types, $xls_arr) && !in_array('application/vnd.ms-excel', $accept)){
                    $accept[] = 'application/vnd.ms-excel';
                    $accept2[] = 'file';
                }
                $xslx_arr = ['xslx'];
                if(in_array($file_types, $xslx_arr) && !in_array('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', $accept)){
                    $accept[] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                    $accept2[] = 'file';
                }
                $csv_arr = ['csv'];
                if(in_array($file_types, $csv_arr) && !in_array('.csv', $accept)){
                    $accept[] = '.csv';
                    $accept2[] = 'file';
                }
                $txt_arr = ['txt'];
                if(in_array($file_types, $txt_arr) && !in_array('text/plain', $accept)){
                    $accept[] = 'text/plain';
                    $accept2[] = 'file';
                }
                $html_arr = ['htm', 'html'];
                if(in_array($file_types, $html_arr) && !in_array('text/html', $accept)){
                    $accept[] = 'text/html';
                    $accept2[] = 'file';
                }
                $video_arr = ['avi', 'mpg', 'mpeg', 'mp4'];
                if(in_array($file_types, $video_arr) && !in_array('video/*', $accept)){
                    $accept[] = 'video/*';
                    $accept2[] = 'video';
                }
                $audio_arr = ['mp3', 'wav'];
                if(in_array($file_types, $audio_arr) && !in_array('audio/*', $accept)){
                    $accept[] = 'audio/*';
                    $accept2[] = 'file';
                }
                $pdf_arr = ['pdf'];
                if(in_array($file_types, $pdf_arr) && !in_array('.pdf', $accept)){
                    $accept[] = '.pdf';
                    $accept2[] = 'file';
                }
                $rar_arr = ['rar'];
                if(in_array($file_types, $rar_arr) && !in_array('.rar', $accept)){
                    $accept[] = '.rar';
                    $accept2[] = 'file';
                }
                $zip_arr = ['zip'];
                if(in_array($file_types, $zip_arr) && !in_array('.zip', $accept)){
                    $accept[] = '.zip';
                    $accept2[] = 'file';
                }
            }
        }
        else{
            $query1="select file_type from ld_attachmentstype where module_name='' or module_name is null ";
            $result1 = $adb->pquery($query1,array());
            $num_rows1 = $adb->num_rows($result1);
            if($num_rows1 > 0){
                for($i=0; $i<$num_rows1; $i++){
                    $file_types = $adb->query_result($result,$i,'file_type');
                    $file_type[] = $file_types;
                    $img_arr = ['png', 'jpg', 'jpeg', 'gif', 'bmp', 'ico'];
                    if(in_array($file_types, $img_arr) && !in_array('image/*', $accept)){
                        $accept[] = 'image/*';
                        $accept2[] = 'image';
                    }
                    $doc_arr = ['doc'];
                    if(in_array($file_types, $doc_arr) && !in_array('application/msword', $accept)){
                        $accept[] = 'application/msword';
                        $accept2[] = 'file';
                    }
                    $docx_arr = ['docx'];
                    if(in_array($file_types, $docx_arr) && !in_array('application/vnd.openxmlformats-officedocument.wordprocessingml.document', $accept)){
                        $accept[] = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
                        $accept2[] = 'file';
                    }
                    $xls_arr = ['xls'];
                    if(in_array($file_types, $xls_arr) && !in_array('application/vnd.ms-excel', $accept)){
                        $accept[] = 'application/vnd.ms-excel';
                        $accept2[] = 'file';
                    }
                    $xslx_arr = ['xslx'];
                    if(in_array($file_types, $xslx_arr) && !in_array('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', $accept)){
                        $accept[] = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
                        $accept2[] = 'file';
                    }
                    $csv_arr = ['csv'];
                    if(in_array($file_types, $csv_arr) && !in_array('.csv', $accept)){
                        $accept[] = '.csv';
                        $accept2[] = 'file';
                    }
                    $txt_arr = ['txt'];
                    if(in_array($file_types, $txt_arr) && !in_array('text/plain', $accept)){
                        $accept[] = 'text/plain';
                        $accept2[] = 'file';
                    }
                    $html_arr = ['htm', 'html'];
                    if(in_array($file_types, $html_arr) && !in_array('text/html', $accept)){
                        $accept[] = 'text/html';
                        $accept2[] = 'file';
                    }
                    $video_arr = ['avi', 'mpg', 'mpeg', 'mp4'];
                    if(in_array($file_types, $video_arr) && !in_array('video/*', $accept)){
                        $accept[] = 'video/*';
                        $accept2[] = 'video';
                    }
                    $audio_arr = ['mp3', 'wav'];
                    if(in_array($file_types, $audio_arr) && !in_array('audio/*', $accept)){
                        $accept[] = 'audio/*';
                        $accept2[] = 'file';
                    }
                    $pdf_arr = ['pdf'];
                    if(in_array($file_types, $pdf_arr) && !in_array('.pdf', $accept)){
                        $accept[] = '.pdf';
                        $accept2[] = 'file';
                    }
                    $rar_arr = ['rar'];
                    if(in_array($file_types, $rar_arr) && !in_array('.rar', $accept)){
                        $accept[] = '.rar';
                        $accept2[] = 'file';
                    }
                    $zip_arr = ['zip'];
                    if(in_array($file_types, $zip_arr) && !in_array('.zip', $accept)){
                        $accept[] = '.zip';
                        $accept2[] = 'file';
                    }
                }
            }
        }
        $file_type=implode(',',$file_type);

        $accept=implode(',',(array)$accept);
        if(is_array($accept2)&& count($accept2) == 1){
            $accept2 = $accept2[0];
        }
        if(is_array($accept2)&&count($accept2) == 2){
            $accept2=implode(',',$accept2);
        }
        if(is_array($accept2)&&count($accept2) == 3){
            $accept2 = 'all';
        }
        return array($file_type, $accept, $accept2);
    }
    //获取详情页翻译字符串
    public function getDetailviewFixedlabel(){
        global $MobileLanguageType;
        //列表页面
        $label_arr=array(
            'Unapproved',//未提交
            'EDIT',//编辑
            'MORE',//更多
            'Dataerrorprogresscannotbedisplayed',//数据错误，进度无法显示
            'details1',//详情
            'MODULERELSEVANT',//相关
            'trends',//动态
            'LOG',//日志
            'TEAM',//团队
            'DETAIL',//明细
            'SESSION',//会话
            'Currency',//币种
            'CHANGESTATUS',//更改状态
            'ADVANCE',//推进
            'TASK',//任务
            'LBL_FINISH_BUTTON_LABEL',//完成
            'LBL_Creates',//创建
            'INCOMPLETE',//未完成
            'LBL_PLEASE_SELECT',//请选择
            'SIGNIN',//签到
            'YES',//是
            'NO',//否
            'MAP',//地图
            'AUTOGRAPH',//签名
            'REWRITING',//重签
            'COMPLETED',//已完成
            'Tagging',//添加标签
            'DOWNLOAD',//下载
            'COMPANYADDRESS',//地址
            'TIMES',//时间
            'COMMENT1',//评论
            'FILLINCOMMENTS',//请填写评论内容
            'CCRANGE',//抄送范围
            'COMMENTLOG',//评论日志
            'Reply',//回复
            'DELETE',//删除
            'NOCOMMENTLOG',//没有评论日志
            'approvelog',//审批日志
            'COLLAPSE',//收起
            'APPROVALSTEP',//审批步骤
            'LOADMORENODES',//加载更多节点
            'noapprovelog',//没有审批日志
            'RECORDSINTOTAL',//共%d条记录
            'NORELEVANTINFORMATION',//没有相关信息
            'NODYNAMIC',//没有动态
            'NOTEAMMEMBERS',//没有团队成员
            'NOSESSION',//没有会话
            'HIGHSEASOPERATIONLOG',//公海操作日志
            'NOHIGHSEASOPERATIONLOG',//没有公海操作日志
            'View History',//修改日志
            'NOVIEWHISTORY',//没有修改日志
            'signlog',//签到日志
            'NOSIGNLOG',//没有签到日志
            'NONE',//无
            'NOTMPDATA',//没有%s数据
            'INITIATEASESSION',//发起会话
            'NEW',//新增
            'RELATEDCREATION',//相关创建
            'MODULE',//模块
            'ACCOUNTDELAY',//延期
            'AccountName',//客户名称
            'Protectionenddate',//保护结束日期
            'DELAYEDDAYS',//延期天数
            'ENTERDELAYEDDAYS',//请输入延期天数
            'RELEASE',//释放
            'ENTERRELEASEREASON',//请输入释放原因
            'APPROVALSUGGESTION',//审批意见
            'ENTERSUBMITOPINIONS',//请输入审批意见
            'handwriting',//手写签名
            'resubmit',//重新提交
            'APPAGREE',//同意
            'REFERRAL',//转审
            'PROGRESSTRACKING',//进度追踪
            'CURRENTSTAGE',//当前阶段
            'WRITEOFF',//核销
            'ACCESSORY',//配件
            'ACCESSORYINFORMATION',//配件信息
            'PRODUCTS',//产品
            'CONFIRMINVENTORY',//确认盘点
            'REVOCATIONINVENTORY',//撤销盘点
            'LBL_DISTRIBUT_HIGHSEAS',//公海分配
            'Transfer',//转公海
            'CONVERTTOHIGHSEASCLIENT',//确定要转换为公海客户吗？
            'TURNORDINARY',//转普通
            'CONVERTTONORMALCLIENT',//确定要转换为普通客户吗？
            'RECEIVE',//领取
            'SUREYOUWANTCOLLECT',//确定要领取？
            'URGE',//催单
            'CLOSEBILL',//结单
            'REOPEN',//重新打开
            'ADVANCECOMPLETED',//推进完成
            'Checkout',//审核
            'ACheckout',//反审核
            'SUBMITAPPROVAL',//提交审批
            'APPROVAL',//审批
            'RETRACEMENT',//回撤
            'RETRACENOTSUBMITTED',//执行后，该单据将被还原到“未提交”状态，确定要撤销吗？
            'APPROVE_ANTIAPPROVAL',//反审批
            'Expediting',//催审
            'COPY',//复制
            'SUREWANTDELETE',//确定要删除吗？
            'SuccessDeleted',//删除成功！
            'SUCCESSFULLYRECEIVED',//领取成功
            'SAVEASPDF',//另存为pdf
            'APPPOSTPONEDFEWDAYSCANOTEMPTY',//延期天数不能为空
            'APPPOSTPONEDFEWDAYPOSITIVEINT',//延期天数只能录入正整数
            'DELAYSUCCEEDED',//延期成功
            'RELEASEREASONCANNOTBEEMPTY',//释放原因不能为空
            'APPRELEASESUCCESS',//释放成功
            'afteroperationthisrecord',//升级后将转入"客户2"模块，是否继续？
            'APPTRANSFERTOPOTENTIALS',//升级后将转入"客户2"和"销售机会"模块，是否继续？
            'FAILLEDTOCOLSE',//失败关闭
            'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
            'TRANSFERTOADVANCEORDER',//转预订单
            'RETREATSUCCEEDED',//回撤成功
            'APPROVEREMARKREQUIRE',//审批意见不能为空
            'SIGNATURECANNOTBEEMPTY',//手写签名不能为空
            'APPROVALSTEPISEMPTY',//审批步骤为空，无法提交
            'APPROVERISEMPTY',//审批人为空，无法提交
            'APPROVALSUCCEEDED',//审批成功
            'APPDETERMINEINVENTORY',//确定盘点吗？
            'APPREADYCANCELINVENTORY',//执行后，该盘点单将被还原到“盘点中”状态，库存数量还原到盘点前。确定要撤销盘点吗？
            'COUNTINGSUCCEEDED',//盘点成功
            'COMMENTSUCCEEDED',//评论成功
            'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
            'SINGINADDRESS',//签到地址
            'BUSINESSINFORMATION',//工商信息
            'EXPRESSINQUIRY',//快递查询
            'REJECT',//驳回
            'ALLOCATE',//分配
            'SHARE',//共享
            'TRANSFERSUCCESSED',//TRANSFERSUCCESSED
            'FOLLOWUPSUCCESS',//跟进成功
            'REVOKE',//撤销
            'CONTACTMAP',//联系人图谱
            'SEARCHNEW',//搜索
            'CANNOTVIEWMULTIPLEDOC',//多条单据无法查看明细
            'ADVANCESUCCESSED',//推进成功
            'RICHTEXTHIDE',//隐藏富文本框
            'GeneratePaymentCode',//生成收款码
            'HOMEPAGE',//首页
            'REPAIRPRODUCTS',//报修产品
            'CONCURRENTSTEPS',//并发步骤
            'CCRANGE',//抄送范围
            'Reply',//回复
            'RICHTEXTHIDE',//隐藏富文本框的修改日志
            'MAPED',//图谱
            'SOLUTION',//解决方案
            'UPGRADINGAFTER1',//升级后将转入
            'UPGRADINGAFTER2',//，是否继续？
            'AND',//和
            'FILETYPENOTSUPPORTED',//当前文件类型不支持
            'DELETESUCCESSFUL',//删除成功
            'PLEASECONFIRMSOFTWAREFORFILE',//请确定是否有对应文件的打开软件
            'OPENING',//打开中
            'COPYSUCCESSFUL',//复制成功
            'Image',//图片
            'Attachment',//附件
            'NOTPICTUREFILETYPE',//不是图片文件类型
            'PLEASESELECTPICTURES',//请选择M以内的图片
            'UPLOADING',//上传中...
            'UPLOADFAILED',//上传失败
            'IMAGEUPLOADING',//图片上传中...
            'UPLOADSUCCEEDED',//上传成功
            'ATTACHMENTUPLOADING',//附件上传中...
            'UNABLEVIEWDETAILS',//无法查看明细
            'Called',// 打电话给
            'Answered',// 接听
            'sPhoneCall',// (谁)的电话
            'Phone',// 电话
            'NoCallRecording',// 没有通话记录
            'Renew',//复制
            'OperationLogs',// 操作日志
            'ModifyingLogDetailstr',//修改日志详情
            'NODOWNLOADPREVIEWPREMISSION',//没有下载预览权限
            'reCalculationBudget',//重算预算金额
            'NumberOfProductsBom',//套餐数量
            'Decrypt',//解密
        );
        $fixedlabel_arr = TransFieldlabel($label_arr);
        $fixedlabel_arr['COMMENTLOG'] = getFixedLabel('COMMENT');
        // 联系人图谱，模块名称动态显示
        $fixedlabel_arr['CONTACTMAP'] = getFixedLabel('ContactsMap');


        if($MobileLanguageType == 'en'){
            $fixedlabel_arr['DETAIL'] = getFixedLabel('DETAILAPP');
            $fixedlabel_arr['DETAIL_1'] = '-'.$fixedlabel_arr['DETAIL'];
            $fixedlabel_arr['DETAIL_2'] = ' '.$fixedlabel_arr['DETAIL'].' ';
            $fixedlabel_arr['details1'] = getFixedLabel('DETAIL1APP');
        }else{
            $fixedlabel_arr['DETAIL_1'] = '-'.$fixedlabel_arr['DETAIL'];
            $fixedlabel_arr['DETAIL_2'] = $fixedlabel_arr['DETAIL'];
        }
        $fixedlabel_arr['details2'] = '-'.$fixedlabel_arr['details1'];
        $fixedlabel_arr['ViewHistory'] = $fixedlabel_arr['View History'];
        $fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);//共$d条数据
        $fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
        $fixedlabel_arr = CombineLabelSolution('%d','PLEASESELECTPICTURES',$fixedlabel_arr);//请选择M以内的图片

        $fixedlabel_arr['ProductsBOM'] = getTranstab('Productbom');

        $this->jsonArr['arrFixedLabel']=$fixedlabel_arr;
        //签名界面的翻译
        $label_arr = array('APPREWRITING','APPFINISH','CANVASSKETCHPAD','AUTOGRAPH');
        $this->jsonArr['arrFixedLabel_autograph']=TransFieldlabel($label_arr,'no');
        //文本控件的翻译
        $label_arr = array('CANCEL','PLEASEFILLINTHECONTENT','SUBMIT','FILLINCOMMENTS','COMMENT1','NOTFILLEDINTHECONTENT',
            'ENTERAPOSITIVEINTEGER','FAILLEDTOCOLSE','RELEASENEW','Reply','COMMENTAPP');
        $this->jsonArr['arrFixedLabel_remark']=TransFieldlabel($label_arr,'no');
    }
    //duan 20221021 移动端新建编辑页面翻译
    public function getCreateviewFixedlabel(){
        global $MobileLanguageType;
        $label_arr=array(
            'BASICINFO',//基本信息
            'EMPTY',//清空
            'pleaseenter',//请输入
            'LBL_PLEASE_SELECT',//请选择
            'PLEASEENTERTHESCALE',//请输入比例
            'Currency',//币种
            'DETAIL',//明细
            'DELETE',//删除
            'EDIT',//编辑
            'ADDDETAILS',//添加明细
            'SCANTOADDPRODUCTS',//扫一扫添加产品
            'SCANBARCODEWITHPDA',//请使用PDA扫入条码
            'BATCHSELECTISSUEWAREHOUSE',//批量选择出库仓库
            'DEDUCTED',//已抵扣
            'DEDUCTIBLE',//可抵扣
            'SUBTOTALOFQUANTITY',//数量小计
            'APPSUBTOTAL',//金额小计
            'ALLSINGLEDISCOUNT',//整单折扣
            'Adjustment',//调整
            'CALCULATE',//计算
            'ERRORMETRA',//误差(米)：
            'INACCURATEPOSITIONING',//定位不准？点我
            'VOICEMESSAGE',//语音信息
            'SUBMITAPPROVAL',//提交审批
            'SELECTAPPROVALPROC',//选择审批流程
            'UrgentApproval',//需要加急审批
            'SUBMITCOMMENTS',//提交意见
            'PLEASEFILLINYOURCOMMENTS',//请填写意见
            'DISPLAYMOREITEM',//展开更多栏目
            'COLLAPSE',//收起
            'SAVE',//保存
            'DISCARDTHEMODIFICATION',//确定要放弃当前页面的修改？
            'UPLOADING',//上传中...
            'FINDDUPLICATES',//查重
            'BUSINESSINFORMATION',//工商信息
            'PLEASEENTERINFORMATION',//请输入信息
            'LBL_Creates',//创建
            'SELECTTHESOURCEDOCUMENTTYPE',//请选择源单类型后，再选择源单
            'SELECTMODULEBEFORESELECTING',//请选择模块后，再选择
            'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
            'SCANCODECONTINUOUSLY',//是否连续扫码
            'SELECTPRODUCTLINEITEMAPP',//不能选择源单以外的产品
            'ADD',//增加
            'DIRECTPRICE',//直接降价
            'APPCANNOTBEEMPTY',//不能为空
            'FORMATERROR',//格式错误
            'CONTACTNAMECANOTEMPTYAPP',//首要联系人姓名不能为空
            'PLEASEENTERTHECORRECTAPP',//请输入正确的
            'CANNOTBESAME',//%s和%s不能相同
            'CANNOTTHAN',//不能大于
            'CANNOTBELESSTHANONE',//不能小于
            'SHOULDGREATEROREQUALAPP',//应大于或等于
            'LINECOUNT',//第%d行
            'AMOUNTCANNOTBEBLANK',//报销金额不能为空或0
            'COMMISSIONCANNOTBEBLANK',//佣金不能为空或0
            'WAREHOUSINGQUANTITYAPP',//可入库数量：
            'QUANTITYCANISSUEDAPP',//可出库数量：
            'PRODUCTQUANTITYAPP',//产品数量：
            'chuku',//出库
            'WAREHOUSING',//入库
            'QUANTITYEXCEEDS',//产品累积%s数量超过可%s数量，保存失败
            'APPROVERISEMPTY',//审批人为空，无法提交
            'APPROVEREMARKREQUIRE',//审批意见不能为空
            'SIGNINISREQUIRED',//签到必填，请点击签到后保存
            'INCALCULABLE',//无法计算
            'CLICKTOREPOSITION',//您当前页面停留超过5分钟，点击【确定】按钮后将重新定位
            'IFTHESTATEHASEBEENSELECTEDASPARTOFTHEAPP',//若是选择状态为部分已收或已收，保存之后则不可再编辑该单据。是否需要保存？
            'SUCCESSFULLYSAVED',//保存成功
            'ApprovedEditAgainSubmitMsgapp',//编辑已审批的单据将重置其审批状态，稍后您需要重新提交审批！
            'PLEASESELECTFIRST',//请先选择%s,再选择%s
            'SELECTAPP',//选择
            'ConcurrentApproval',//并发审批
            'APPROVER',//审批人
            'Countersigner',//会签审批人
            'AddApprover',//添加审批人
            'DOYOUUSELOCATIONADDRESSAPP',//是否用定位地址覆盖国家、省份、城市及地址？
            'POSITIONING',//定位中...
            'NOADDRESSISOBTAINED',//未获取地址，请确定是否开启GPS
            'DELETELOCATIONINFORMATION',//确定要删除定位信息吗？
            'CLICKTOSIGNIN',//点击签到
            'UPTOUPLOAD',//最多可上传
            'ALSOUPLOAD',//您还可以上传
            'NOTPICTUREFILETYPE',//不是图片文件类型
            'PLEASESELECTPICTURES',//请选择%dM以内的图片
            'UPLOADFAILED',//上传失败
            'IMAGEUPLOADING',//图片上传中...
            'UPLOADSUCCEEDED',//上传成功
            'ATTACHMENTUPLOADING',//附件上传中...
            'FAILEDTOINITIALIZEPAGE',//初始化页面失败
            'TOTALOFAPP',//总
            'REQUIREDAPP',//要求
            'THANAPP',//比
            'MONTHSAPP',//个月
            'TOTAL',//合计
            'MANUALLYSELECTANDENTERPRODUCTS',//手动选择录入产品、单选产品
            'MULTIPLEPRODUCTSELECTION',//多选产品
            // 'ProductsBOM',//产品套餐
            'PROPORTIONTOTALMUSTBE',//%s比例合计必须等于100
            'PRODUCTCANNOTBEEMPTY',//产品名称（变更后）不能为空！
            'CREATECUSTOMER',//创建客户
            'ADVANCESUCCESSED',//推进成功
            'HAVENOTADDEDDETAILS',//您还没有添加明细
            'ADMINISTRATORCREATEVENDORS',//请联系系统管理员创建{$Vendors.Vendors}
            'ADMINISTRATORLOCATEADDRESS',//请联系系统管理员定位地址
            'HOMEPAGEAPP',//首页
            'SUBMIT',//提交
            'THEACTUALAMOUNT',//实际收款金额
            'APPROVER',//审批人
            'Countersigner',//会签审批人
            'ConcurrentApproval',//并发审批
            'PERCENTAGEPRICE',//百分比降价
            'DEDUCT',//减少
            'SUCCESS',//成功
            'ADVANCESUCCESSED',//推进成功
            'ACCESSORYINFORMATION',//配件信息
            'PHOTOGRAPH',//拍照
            'PhotoAlbum',//相册
            'WECHATCLIENTCHOOSEFILE',//微信客户端会话选择文件
            'Pending1',//待审批
            'SaveSubmitApprove',//保存并提交审批
            'APPROVALNOTEMPTY',//审批流程不能为空
            'GetStaging',//获取暂存信息
            'NotStaging',//没有暂存信息
            'LoadLocalStorage',//确定后，将会覆盖现有信息，是否继续？
            'NumberOfProductsBom',//套餐数量
            'PRODUCTSDUPLICATEDCONTINUE',//以下产品重复,是否继续保存？
            'PRODUCTSDUPLICATEDNOTSAVE',//以下产品重复,不允许保存
        );
        $fixedlabel_arr = TransFieldlabel($label_arr);
        $fixedlabel_arr['QUANTITYEXCEEDS_out']= sprintf($fixedlabel_arr['QUANTITYEXCEEDS'],$fixedlabel_arr['chuku'],$fixedlabel_arr['chuku']);
        $fixedlabel_arr['QUANTITYEXCEEDS_in']= sprintf($fixedlabel_arr['QUANTITYEXCEEDS'],$fixedlabel_arr['WAREHOUSING'],$fixedlabel_arr['WAREHOUSING']);

        if($MobileLanguageType == 'en'){
            $fixedlabel_arr['DETAIL'] = ' '.$fixedlabel_arr['DETAIL'].' ';
            $fixedlabel_arr['DETAIL1'] = ' '.$fixedlabel_arr['DETAIL'].':';
            $fixedlabel_arr['LBL_Creates'] = $fixedlabel_arr['LBL_Creates'].' ';
            $fixedlabel_arr['EDIT'] = $fixedlabel_arr['EDIT'].' ';
        }else{
            $fixedlabel_arr['DETAIL1'] = $fixedlabel_arr['DETAIL'].'：';
        }

        $fixedlabel_arr = CombineLabelSolution('%d','PLEASESELECTPICTURES',$fixedlabel_arr);//请选择%dM以内的图片
        $fixedlabel_arr = CombineLabelSolution('%s','CANNOTBESAME',$fixedlabel_arr);//%s和%s不能相同
        $fixedlabel_arr = CombineLabelSolution('%d','LINECOUNT',$fixedlabel_arr);//第%d行
        $fixedlabel_arr = CombineLabelSolution('%s','QUANTITYEXCEEDS',$fixedlabel_arr);//产品累积%s数量超过可%s数量，保存失败
        $fixedlabel_arr = CombineLabelSolution('%s','PLEASESELECTFIRST',$fixedlabel_arr);//请先选择%s,再选择%s
        $fixedlabel_arr = CombineLabelSolution('%s','PROPORTIONTOTALMUSTBE',$fixedlabel_arr);//%比例合计必须等于100

        $fixedlabel_arr['ProductsBOM'] = getTranstab('Productbom');

        $this->jsonArr['arrFixedLabel']=$fixedlabel_arr;
        //多选框控件
        $option_label_arr = array('CANCEL','CONFIRMED','SEARCHNEW','PLEASESELECTATLEASTONE');
        $fixedlabel_arr_option = TransFieldlabel($option_label_arr,'no');
        $this->jsonArr['arrFixedLabel_option']=$fixedlabel_arr_option;
    }

}