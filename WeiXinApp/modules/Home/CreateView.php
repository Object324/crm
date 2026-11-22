<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
include globalStatic::$root_directory.'modules/Home/ExpressionList.php';//获取表情列表
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$HomeTransfor = array('ItemLogday'=>'dayreport','ItemLogweek'=>'weekreport','ItemLogmonth'=>'monthreport',
    'ItemWeibo'=>'weibo','ItemCocmd'=>'cocmd');
$reportid = $_REQUEST['reportid'];//-1为新增，否则为编辑
if (empty($reportid)){
    $reportid = -1;
}
$type = $_REQUEST['type'] ; //weibo  cocmd   logday  logweek logmonth
$entitytype = $_REQUEST['entitytype'] ; //weibo  cocmd   workreport(   logday  logweek logmonth)
/*crm_load_class_file('AppWorkReportModel','WeiXinApp/modules/Home');
$workObj = new AppWorkReportModel();*/
crm_load_class_file('WorkReportModelWX','WeiXinApp/modules/Home');
$workObj = new WorkReportModelWX();

if($reportid != -1){
    $prevReport = $workObj->getPreviousReport($reportid);
    $report = $prevReport['report'][0];
    $approved = $report['approved'];
    $menu['approved']=$approved;
    $r_workdate = $prevReport['report'][0]['sendlog_workdate'];
    if (isset($_REQUEST['second_action']) && $_REQUEST['second_action'] == 'sales_kit'){
        $r_workdate = $_REQUEST['workdate'];
    }
} else{
    $menu['approved']=0;
    $r_workdate = $_REQUEST['workdate'];
}

$SalesKit_Detail = $workObj->getSendLog_SalesKit_Detail($type,$r_workdate,'',$_REQUEST['datemark']);
if(isset($_REQUEST['second_action'])&&$_REQUEST['second_action']=='sales_kit'){
    ConvertTojsonString(1,array('sales_kit'=>$SalesKit_Detail),'success');
}
$workReportTemplate = $workObj->getallFieldsForTable();
$menu['field'] = $workReportTemplate[$entitytype][$HomeTransfor[$type]];

if($reportid != -1) {
    foreach($menu['field']['fieldinfo'] as &$fieldinfo) {
        if (array_key_exists('defaultvalue', $fieldinfo)) {
            $fieldinfo['defaultvalue'] = $report[$fieldinfo['name']];
            if ($approved > 0) {
                $fieldinfo['edit_permission'] = 'noedit';
            } else {
                $fieldinfo['edit_permission'] = 'edit';
            }
            if ($entitytype == 'workreport' && $fieldinfo['name'] == 'saleskit_'.explode('report',$HomeTransfor[$type])[0]){
                $fieldinfo['saleskit_showtype']=$report['saleskit_showtype'];
                $fieldinfo['saleskit_listinfo']=$report['saleskit_listinfo'];
                $menu['saleskit_showtype'] = $fieldinfo['saleskit_showtype'];
                $menu['saleskit_listinfo'] = $fieldinfo['saleskit_listinfo'];
            }
        }
    }
}else{
    foreach($menu['field']['fieldinfo'] as &$fieldinfo) {
        $fieldinfo['edit_permission'] = 'edit';
    }
}
$workfld = '';
foreach($workReportTemplate[$entitytype][$HomeTransfor[$type]]['fieldinfo'] as $key=>$val){
    $workfld .= $val['name'].',';
}
$menu['field']['workfld'] = $workfld;

if($reportid!=-1){
    $menu['send_range'] = array('ccuser'=>implode(',',$report['ccuser']),'ccusername'=>implode(',',$report['ccusername']),'fieldlabel' => getFixedLabel('SENDINGRANGE'));
    $menu['com_exec'] = array('reader'=>$report['reader'],'readername'=>$report['readername'],'fieldlabel' => getFixedLabel('REVIEWER'));
}else{
    $T1['workreport'] = array('com_exec'=>'reader','com_execname'=>'readername','fieldlable'=>getFixedLabel('REVIEWER'),'resuerdisabled'=>'disabled');
    $T1['cocmd'] = array('com_exec'=>'cmduser','com_execname'=>'cmdusername','fieldlable'=>getFixedLabel('EXECUTORS'));
    $getRangeCommentExecutor = $workObj->getRangeCommentExecutorCommon();
    foreach($getRangeCommentExecutor['list'] as $key=>$val){
        if($key == 'com_exec' || $key == 'com_execname' || $key == 'resuerdisabled'){
            if($entitytype != 'weibo'){
                $menu['com_exec'][$T1[$entitytype][$key]] = $val;
            }
        }else{
            $menu['send_range'][$key] = $val;
        }
    }
    $menu['send_range']['fieldlabel'] = getFixedLabel('SENDINGRANGE');
    if(isset($menu['com_exec'])){
        $menu['com_exec']['fieldlabel'] = $T1[$entitytype]['fieldlable'];
    }
}

$menu['atusers'] = array('atuser'=>'','atgroup'=>'','fieldlable'=>getFixedLabel('ATUSER'));
$crmid_arr = array('Accounts'=>[],'Contacts'=>[],'Products'=>[]);
//duan 20230307 从移动端详情页的相关信息进入工作汇报时，带出当前的单据
if($_REQUEST['relateinfo'] == 'yes' && !empty($_REQUEST['roleid'])){
    $crmid = $_REQUEST['roleid'];
    $frommodule = getSalesEntityType($crmid);
    $crmid_arr[$frommodule] = array('value'=>getModuleHref($frommodule,$crmid),'hiddenvalue'=>$crmid);
}
//crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
//$portObj = new cls_WeixinPort();//gyq_41
//$portObj->getAgentId();
//if(array_key_exists('ldcrm',$portObj->agentid)){
    if((isPermitted('Accounts')=='yes'&&vtlib_isModuleActive('Accounts'))||(isPermitted('ServiceCharge')=='yes'&&vtlib_isModuleActive('ServiceCharge'))){
        $menu['related_accounts']= array('accountlist'=>$crmid_arr['Accounts'],'fieldlable'=>getFixedLabel('RELATIONAL').' '.getTranstab('Accounts'));
        $menu['related_accounts']['edit_permission']='edit';
        if($reportid!=-1){
            if($report['Accounts']!=null){
                foreach($report['Accounts'] as &$account){
                    $accountid[]=$account['curid'];
                    $accountname[]=$account['name'];
                }
                $menu['related_accounts']['accountlist']['hiddenvalue']=implode(',',$accountid);
                $menu['related_accounts']['accountlist']['value']=$accountname;
            }
            if($approved>0){
                $menu['related_accounts']['edit_permission']='noedit';
            }
        }
    }
    if(isPermitted('Contacts')=='yes'&&vtlib_isModuleActive('Contacts')){
        $menu['related_contacts']= array('contactlist'=>$crmid_arr['Contacts'],'fieldlable'=>getFixedLabel('RELATIONAL').' '.getTranstab('Contacts'));
        $menu['related_contacts']['edit_permission']='edit';
        if($reportid!=-1){
            if($report['Contacts']!=null){
                foreach($report['Contacts'] as &$contact){
                    $contactid[]=$contact['curid'];
                    $contactname[]=$contact['name'];
                }
                $menu['related_contacts']['contactlist']['hiddenvalue']=implode(',',$contactid);
                $menu['related_contacts']['contactlist']['value']=$contactname;
            }
            if($approved>0){
                $menu['related_contacts']['edit_permission']='noedit';
            }
        }
    }
    if(isPermitted('Products')=='yes'&&vtlib_isModuleActive('Products')){
        $menu['related_products']= array('productslist'=>$crmid_arr['Products'],'fieldlable'=>getFixedLabel('RELATIONAL').' '.getTranstab('Products'));
        $menu['related_products']['edit_permission']='edit';
        if($reportid!=-1){
            if($report['Products']!=null){
                foreach($report['Products'] as &$product){
                    $productid[]=$product['curid'];
                    $productname[]=$product['name'];
                }
                $menu['related_products']['productslist']['hiddenvalue']=implode(',',$productid);
                $menu['related_products']['productslist']['value']=$productname;
            }
            if($approved>0){
                $menu['related_products']['edit_permission']='noedit';
            }
        }
    }

$menu['signaddress']= array('signaddress'=>'','longtitude'=>'','latitude'=>'','fieldlable'=>getFixedLabel('LOCATION'));
$menu['attachments']['image_save_weixin']['new']= array();
$menu['attachments']['fieldlable']= getFixedLabel('ASSOCIATEPICTURE');
$menu['attachments']['edit_permission']='edit';
if($reportid != -1){
    $imglist=[];
    foreach($report['workachment']['image'] as &$img){
        $imglist[] = array('cloud_path'=>$img['cloud_path'],'filename'=>$img['name'], 'filepath'=>$img['real_path'], 'filesize'=>$img['sizeraw'], 'filesuffixes'=>'', 'filetype'=>'', 'imgfromtype'=>'', 'newfile_name'=>$img['newfile_name'], 'storage_location'=>$img['storage_location'], 'upload_from'=>'', 'upload_status'=>'true', 'achmentid'=>$img['achmentid']);
    }
    $menu['attachments']['image_save_weixin']['new'] =  $imglist;
    if($approved>0){
        $menu['attachments']['edit_permission']='onlyadd';
    }
}
$menu['modulename'] = getFixedLabel('LBL_COOPERATIVEWORK');
//editor:gyq_78 reason:发布工作汇报时显示销售简报 2018/8/28 15:20
//editor:gyq_90 reason:日志日期修改为自定义选择日期 2018/12/6 15:39
$menu['sales_kit'] = $SalesKit_Detail;
if($reportid!=-1){
    $menu['sales_kit']['date']=$report['sendlog_workdate'];
}
if($reportid!=-1){
    $sign_activate='no';
    $sign_mandatory='no';
} else{
    $workReportSignTemplate = $workObj->getSignAddress();
    if($HomeTransfor[$type] == 'dayreport'){
        $is_activate = $workReportSignTemplate[1]['is_activate'];//是否启用，0为启用，1为禁用
        $is_mandatory = $workReportSignTemplate[1]['is_mandatory'];//是否必填，0为必填，1为非必填
    }
    else if($HomeTransfor[$type] == 'weekreport'){
        $is_activate = $workReportSignTemplate[2]['is_activate'];
        $is_mandatory = $workReportSignTemplate[2]['is_mandatory'];
    }
    else if($HomeTransfor[$type] == 'monthreport'){
        $is_activate = $workReportSignTemplate[3]['is_activate'];
        $is_mandatory = $workReportSignTemplate[3]['is_mandatory'];
    }
    $sign_activate = 'yes';
    if($is_activate == '1'){
        $sign_activate = 'no';
    }
    $sign_mandatory = 'yes';
    if($is_mandatory == '1'){
        $sign_mandatory = 'no';
    }
}
$signData['activate']=$sign_activate;
$signData['mandatory']=$sign_mandatory;
$menu['signData'] = $signData;
$menu['servertime'] = time();
//XUQIU20240725-04 工作汇报增加汇报日期和编辑时限控制（重庆正川） 原系统参数控制可选汇报日期 修改为规则汇报日期
if ($entitytype == 'workreport' && $reportid == -1){
    $reporttype_arr = array('ItemLogday'=>'day','ItemLogweek'=>'week','ItemLogmonth'=>'month');
    $reporttype = $reporttype_arr[$type];
    crm_load_class_file('WorkTemplateRule','modules/Settings');
    $workTemplateRuleobj = new WorkTemplateRule();
    $workTemplateRuleobj->setWorkReportType($reporttype);
    $reportDate = $workTemplateRuleobj->getReportDateData();
    if ($reportDate['editDate'] == 'no'){
        $menu['change_time_permit'] = 'no';
    }else{
        $menu['change_time_permit'] = 'yes';
    }
}else if ($reportid != -1){
    $menu['change_time_permit'] = 'yes';
}
// ljj 20231121 XUQIU1002166 工作汇报模板定制增加“自动引用工作内容”（宋清华）
if ($type != 'ItemWeibo' && $type != 'ItemCocmd'){
    $related_content = $workObj->getRelatedModuleField($type);
    $menu['related_content']=$related_content;
}
$menu['startdate'] = '';
if($reportid != -1){
    $menu['send_range']['edit_permission'] = 'noedit';
    $menu['com_exec']['edit_permission'] = 'noedit';
    $menu['atusers']['edit_permission'] = 'noedit';
    $menu['related_content'] = array();
    if($type == 'ItemCocmd'){
        $menu['startdate'] = $report['startdate'];
    }
} else{
    $menu['send_range']['edit_permission'] = 'edit';
    $menu['com_exec']['edit_permission'] = 'edit';
    $menu['atusers']['edit_permission'] = 'edit';
}

$jsonArr = $menu;

//移动端获取翻译
global $MobileLanguageType;
$label_arr=array(
    'PLEASEFILLINTHECONTENT',//请填写内容
    'COMPLETIONTIMEAPP',//完成时间
    'DATE',//日期
    'Generatebrief',//生成简报
    'PHOTO',//照片
    'CCRANGE',//抄送范围
    'REVIEWER',//点评人
    'ATUSERSCOPE',//@用户范围
    'EXECUTORS',//执行人
    'RELEASENEW',//发布
    'WRITE',//写
    'DISCARDTHEMODIFICATION',//确定要放弃当前页面的修改？
    'REPORTBEENTEMPORARILYSAVED',//您的工作汇报已暂存，下次进入可继续编辑工作汇报！
    'CLICKTOSIGNIN',//点击签到
    'UPLOADING',//上传中...
    'NEW',//新增
    'POSITIONING',//定位中...
    'NOADDRESSISOBTAINED',//未获取地址，请确定是否开启GPS
    'DELETELOCATIONINFORMATION',//确定要删除定位信息吗？
    'thisweek',//本周
    'lastweek',//上周
    'beflastweek',//上上周
    'thismonth',//本月
    'lastmonth',//上月
    'beflastmonth',//上上月
    'CCRANGEAPP',//抄送范围：
    'COLLEAGUES',//个同事
    'CUSTOMERSAPP',//个客户
    'CONTACTSAPP',//个联系人
    'UPTOUPLOAD',//最多可上传
    'ALSOUPLOAD',//您还可以上传
    'NOTPICTUREFILETYPE',//不是图片文件类型
    'PLEASESELECTPICTURES',//请选择%dM以内的图片
    'UPLOADFAILED',//上传失败
    'IMAGEUPLOADING',//图片上传中...
    'ATTACHMENTUPLOADING',//附件上传中...
    'UPLOADSUCCEEDED',//上传成功
    'VISIBLERANGSETTINGSAPP',//指定日期范围内没有销售简报数据！
    'CLICKTOREPOSITION',//您当前页面停留超过5分钟，点击【确定】按钮后将重新定位
    'COMPLETIONTIMEEARLIER',//完成时间不能早于当前时间
    'DATEEARLIERTHAN',//日期不能早于当前日期
    'SIGNINISREQUIRED',//签到必填，请点击签到后保存
    'APPCANNOTBEEMPTY',//不能为空
    'NOTFILLEDINTHECONTENT',//您还没有填写内容
    'SELECTREVIEWER',//请选择点评人
    'SELECTCCRANGE',//选择抄送范围
    'SELECTEXECUTOR',//请选择执行人
    'BLOG',//微博
    'LOG',//日志
    'LBL_WEEKLYSCHEMES',//周计划
    'LBL_MONTHLYSCHEMES',//月计划
    'TASK',//任务
    'pleaseenter',//请输入
    'Pictures',//个图片
    'LOCATIONNOTEMPTY',//定位不能为空
    'PLEASESELECTCCRANGE',//请选择抄送范围
    'PUBLISHEDSUCCESSFULLY',//发布成功
    'PREVIEW',//预览
    'DOWNLOAD',//下载
    'CANCEL',//取消
    'DELETE',//删除
);
$fixedlabel_arr = TransFieldlabel($label_arr);
$fixedlabel_arr = CombineLabelSolution('%d','PLEASESELECTPICTURES',$fixedlabel_arr);//请选择%dM以内的图片
if($MobileLanguageType == 'en'){
    $fixedlabel_arr['WRITE'] .= ' ';
}
$jsonArr['arrFixedLabel'] = $fixedlabel_arr;
$jsonArr['permit'] = array('download'=>isPermitted('CooperativeWork','DownLoad',''),'preview'=>isPermitted('CooperativeWork','Preview',''));

ConvertTojsonString(1,$jsonArr,'success');

