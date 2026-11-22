<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

require_once(globalStatic::$root_directory.'include/home.php');
include  globalStatic::$root_directory.'modules/Home/HomeUtils.php';
global $app_strings, $app_list_strings, $mod_strings;
global $adb, $current_user;
global $theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$regop=RegOp::getInstance();
$crmversion=$regop->GetVersionNo();
$homeObj=new Homestuff;


$smarty=new lingdangCRM_Smarty;

//设置工作汇报是否允许选择日期  0是  1否
//$sys = getSys_deploy(198);
//$smarty->assign('DEPLOY',$sys['deploy_value']);


$workreportid = $_REQUEST['workreportid'];
$smarty->assign("workreportid",$workreportid);
$sql = 'select smcreatorid, entitytype,type,approved,sendlog_workdate,startdate from ld_workreport where workreportid = ?';
$result = $adb->pquery($sql, array($workreportid));
if($adb->query_result($result, 0, 'smcreatorid')!=$current_user->id)
{
    ConvertTojsonString(-2,array(),'not allowed to edit');
}
$approved = $adb->query_result($result, 0, 'approved');
$sendlog_workdate = $adb->query_result($result, 0, 'sendlog_workdate');
$edit_permission = array();

//目前根据点评状态判断各字段是否允许编辑
if($approved == 1 ){
    $edit_permission = array('fields'=>'noedit','toUsers'=>'noedit','workachment'=>'onlyadd','related'=>'noedit');
} else{
    $edit_permission = array('fields'=>'edit','toUsers'=>'noedit','workachment'=>'edit','related'=>'edit');
}
$smarty->assign("EDIT_PERMIT",$edit_permission);

$smarty->assign("approved",$approved);
$startdate = $adb->query_result($result, 0, 'startdate');
$entitytype = $adb->query_result($result, 0, 'entitytype');
$type = $adb->query_result($result, 0, 'type');
require globalStatic::$root_directory . 'modules/Home/WorkReportController.php';
$work_focus = new WorkReportController();
$prevcontent = $work_focus ->model->getPreviousReport($workreportid);
$prevreport = $prevcontent['report'][0];
$saleskit_showtype = $prevreport['saleskit_showtype'];
$saleskit_listinfo = $prevreport['saleskit_listinfo'];
$workfieldarray = $work_focus->getWorkPrevFld($entitytype,$type,$prevreport);
$smarty->assign('WORKFIELDARRAY', $workfieldarray);
$startdate = date_create($startdate);
$smarty->assign('startdate1',date_format($startdate,"Y年m月d日"));
$smarty->assign('startdate2',date_format($startdate,"H:i"));
$smarty->assign('entitytype',$entitytype);
$smarty->assign('type',$type);
if($entitytype=='weibo'){
    $entitytypename = getFixedLabel('BLOG');
    $reporttype = 'weibo';
}
else if($entitytype=='cocmd'){
    $entitytypename = getFixedLabel('TASK');
    $reporttype = 'cocmd';
}
else if($entitytype=='workreport'){
    if($type==1){
        $entitytypename = getFixedLabel('JOURNAL');
        $reporttype = 'day';
    }
    else if($type==2){
        $entitytypename = getFixedLabel('WEEKPLAN');
        $reporttype = 'week';
    }
    else if($type==3){
        $entitytypename = getFixedLabel('MONTHPLAN');
        $reporttype = 'month';
    }
}
//storage/2024/July/19/CooperativeWork_logo_big_light_0721_201326f1.png
$img = isset($prevreport['workachment']['image'])?$prevreport['workachment']['image']:[];
$imgarr = array();
foreach($img as $key=>$value){
    $achmentid = $key;
    $name =  $value['file_name']['value'];
    if($value['storage_location']['value']=='local'){
        $src = $value['path']['value'].$value['newfile_name']['value'];
    }else{
        $src = urldecode($value['cloud_path']['value']);
    }
    $size = $value['size']['value'];
    $imgarr[]=array('id'=>$achmentid,'name'=>$name,'src'=>$src,'size'=>$size );
}
$att = isset($prevreport['workachment']['att'])?$prevreport['workachment']['att']:'';
$attarr = array();
foreach($att as $key=>$value){
    $achmentid = $key;
    $name =  $value['file_name']['value'];
    $size = $value['size']['value'];
    $attarr[]=array('id'=>$achmentid,'name'=>$name,'size'=>$size );
}
$smarty->assign("IMAGESARR",$imgarr);
$smarty->assign("ATTARR",$attarr);
$smarty->assign("ACCOUNTSARR",$prevreport['Accounts']);
$smarty->assign("CONTACTSARR",$prevreport['Contacts']);
$smarty->assign("PRODUCTSARR",$prevreport['Products']);
$smarty->assign("sendlog_workdate",$sendlog_workdate);
//获取已显示的简报组件的相关信息
$sql= "select name,sequence,presence,label_zh,label_en,count_module,count_type,count_columnname from ld_workreport_briefreport_detail  where `delete`=0 and presence = 'yes' order by sequence asc;";
$result = $adb->pquery($sql,array());
$num_rows = $adb->num_rows($result);
if($num_rows>0) {
    $component_arr=array();
    for($i = 0; $i < $num_rows; $i++){
        $count_module = $adb->query_result($result,$i,'count_module');
        if (!vtlib_isModuleActive($count_module) || isPermitted($count_module,'index') == 'no'){
            continue;
        }
        $name = $adb->query_result($result,$i,'name');
        $label_str = $languageType == 'zh'?'label_zh':'label_en';
        $label = $adb->query_result($result,$i,$label_str);
        $sequence = $adb->query_result($result,$i,'sequence');
        $array_bfcomponent=array();
        $array_bfcomponent['sequence']=$sequence;
        $array_bfcomponent['component_strtolower']=strtolower($name);
        $array_bfcomponent['component_name']=$name;
        //各个模块对应的组件名
        $array_bfcomponent['componentlabel']=$label;
        //收款金额、签到报表的计量单位不一样；
        $component_arr[$name]=$array_bfcomponent;
    }
}
$smarty->assign("BFCOMPONENT",$component_arr);
$smarty->assign('current_language',$languageType);

$smarty->assign('download_permit',isPermitted('CooperativeWork','DownLoad',''));
$smarty->assign('preview_permit',isPermitted('CooperativeWork','Preview',''));

//XUQIU20240725-04 工作汇报增加汇报日期和编辑时限控制（重庆正川） 编辑界面控制汇报日期
if($entitytype=='workreport'){
    $reporttype_arr = array('1'=>'day','2'=>'week','3'=>'month');
    $reporttype = $reporttype_arr[$type];
    crm_load_class_file('WorkTemplateRule','modules/Settings');
    $workTemplateRuleobj = new WorkTemplateRule();
    $workTemplateRuleobj->setWorkReportType($reporttype);
    $reportDate = $workTemplateRuleobj->getReportDateData();
    $editDate = $reportDate['editDate'];
    $smarty->assign('editDate',$editDate);
    if ($type == 1){
        $minDate = $reportDate['minDate'];
        $maxDate = $reportDate['maxDate'];
        //获取有效日期
        if (strtotime($sendlog_workdate)<strtotime($minDate)){
            $disabledDates[]=$sendlog_workdate;
        }
        if (!empty($minDate) && !empty($maxDate)){
            $start = new DateTime($minDate);
            $end = new DateTime($maxDate);
            $end = $end->modify('+1 day'); // 包含结束日期
            $interval = new DateInterval('P1D'); // 每日间隔
            $dateRange = new DatePeriod($start, $interval, $end);
            foreach ($dateRange as $date) {
                $disabledDates[] = $date->format('Y-m-d');
            }
            $smarty->assign('disabledDates',"'".implode("','",$disabledDates)."'");
        }

    }

}
$arr['entitytypename'] = $entitytypename;
$arr['saleskit_showtype'] = $saleskit_showtype;
$arr['saleskit_listinfo'] = $saleskit_listinfo;
$arr['reporttype'] = $reporttype;
$arr['content'] = $smarty->fetch("Home/CoordinationEdit.tpl");
ConvertTojsonString(1,$arr,'success');
?>