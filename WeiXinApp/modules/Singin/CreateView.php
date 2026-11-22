<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $weixin_user;
//小程序兼容，小程序暂时还没做新的拜访签到模块
$mobj = cls_Instance::get_moduleAction_Instance('Singin','DetailView');
$details = $mobj->common_getInfo();
echo $details;
die;

//editor:gyq_81 reason:签到考勤优化 2018/9/26 10:56
//外勤签到拍照上传是否可以选择相册图片。1:否，0:是
global $languageType,$languages,$adb,$MobileLanguageType;
$php52 = getSys_deploy(114);
$deploy = $php52['deploy_value'];
if($deploy == 0){
    $json['uploadtype'] = array('camera','album');
}else{
    $json['uploadtype'] = array('camera');
}
if($MobileLanguageType == 'en'){
    $time = date('Y-m-d H:i',time());
}else{
    $time = date('Y年m月d日 H时i分',time());
}

$hiddentime = time();
$json['time'] = $time;
$json['hiddentime'] = $hiddentime;
//editor:gyq_20181108 签到模块新增界面，输出模块名  2018/11/8 15:54
$json['page_title'] = getTranstab('Singin');
$sys_143 = getSys_deploy(143);

//授权移动CRM应用&&开启客户或服务收费管理模块
//showmodule  /*1:不显示*/ 2:必填 3:非必填
// if((isPermitted('Accounts')=='yes'&&vtlib_isModuleActive('Accounts'))||(isPermitted('ServiceCharge')=='yes'&&vtlib_isModuleActive('ServiceCharge'))){
//     $json['showmodule'] = $sys_143['deploy_value']+1;
// }else{
//     $json['showmodule'] = 1;
// }
$json['showmodule'] = $sys_143['deploy_value']+1;
//reason:方便前台调试
$json['showmoduleinfo'] = '/*1:不显示*/ 2:必填 3:非必填';

//判断签到图片是否必填，yes:必填 no:非必填
$system_deploy = getSys_deploy(200);
if($system_deploy['deploy_value']=='1'){
    $json['showimg'] = 'no';
}else{
    $json['showimg'] = 'yes';
}

//hjz 判断拜访签到备注是否必填，yes:必填 no:非必填
$system_deploy_348 = getSys_deploy(348);
if($system_deploy_348['deploy_value']=='1'){
    $json['showRemarks'] = 'no';
}else{
    $json['showRemarks'] = 'yes';
}

//选择拜访对象类型
// @edit:dong @date:2020/08/14 @reason: 公共函数
require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php');
$modulelist = cls_StaticCommonFun::getOptionModule('Singin');
//$tabid = getTabid('Singin');
//$list_query = 'select op.option_tabid,ld_tab.name modulename,op.default
//                from ld_option_module as op
//				left join ld_tab on ld_tab.tabid = op.option_tabid
//                where op.tabid=? and ld_tab.presence <> 1 and op.presence<>1 order by sequence';
//$list_result = $adb->pquery($list_query,array($tabid));
//$num_rows =  $adb->num_rows($list_result);
//$modulelist=  array();
//if($num_rows){
//    $select_arr = array(0=>'',1=>'selected');
//    for($i=0;$i<$num_rows;$i++){
//        $option_tabid = $adb->query_result($list_result,$i,'option_tabid');
//        $modulename = $adb->query_result($list_result,$i,'modulename');
//        $default = $adb->query_result($list_result,$i,'default');
//        $modulename_label = getTranstab($modulename);
//        $modulelist[$i]['label']  = $modulename_label;
//        $modulelist[$i]['value']  = $modulename;
//        $modulelist[$i]['select']  = $select_arr[$default];
//    }
//}
//duan 20221013 移动端获取字符串翻译
$label_arr=array(
    'SIGNTIME',//签到时间
    'VISITORTYPE',//拜访对象类型
    'LBL_PLEASE_SELECT',//请选择
    'BaiFang_DuiXiang',//拜访对象
    'VISITINGADDRESS',//拜访地址
    'REMARK',//备注
    'pleaseenter',//请输入
    'PHOTO',//照片
    'ERRORMETRA',//误差(米)：
    'INACCURATEPOSITIONING',//定位不准？点我
    'SIGNIN',//签到
    'HISTORY',//历史
    'NOADDRESSISOBTAINED',//未获取地址，请确定是否开启GPS
    'POSITIONING',//定位中...
    'UPTOUPLOAD',//最多可上传
    'ALSOUPLOAD',//您还可以上传
    'NOTPICTUREFILETYPE',//不是图片文件类型
    'UPLOADFAILED',//上传失败
    'UPLOADING',//上传中...
    'UPLOADSUCCEEDED',//上传成功
    'LOCATINGCURRENTADDRESS2',//正在定位当前地址，请稍后再选择拜访对象
    'LOCATINGCURRENTADDRESS',//正在定位当前地址，请稍后再选择拜访对象类型
    'SELECTVISITORTYPEFIRST',//请选择拜访对象类型后，再选择拜访对象
    'PLEASEWAITLOCATING',//请稍等，正在定位中...
    'VISITORCANNOTBEEMPTY',//拜访对象不能为空
    'PICTURECANNOTEMPTY',//图片不能为空
    'REMARKCANNOTEMPTY',//备注不能为空
    'Theadministratorhassetthatitisnorange',//管理员已设置超出误差范围不允许签到，请完善您的拜访对象地址信息
    'INCALCULABLE',//无法计算
    'CLICKTOREPOSITION',//您当前页面停留超过5分钟，点击【确定】按钮后将重新定位
    'SIGNINSUCCEEDED',//签到成功
    'CLICKTOSIGNIN',//立即签到
    'SIGNINANDOUTTIP',
);
$fixedlabel_arr = TransFieldlabel($label_arr);
//请选择%dM以内的图片
$piclabelstr = getFixedLabel('PLEASESELECTPICTURES');
$piclabelarr = explode('%d',$piclabelstr);
$fixedlabel_arr['PLEASESELECTPICTURES1'] = $piclabelarr[0];
$fixedlabel_arr['PLEASESELECTPICTURES2'] = $piclabelarr[1];
//管理员已设置超出误差范围不允许签到，您的签到误差已超{metre}米，请在规定范围内签到！
$signlabelstr = getFixedLabel('Theadministratorhassetthatitisnotallowedtosign');
$signlabelarr = explode('{metre}',$signlabelstr);
$fixedlabel_arr['allowedtosign1'] = $signlabelarr[0];
$fixedlabel_arr['allowedtosign2'] = $signlabelarr[1];
$json['arrFixedLabel'] = $fixedlabel_arr;

$json['module_list'] = array_values($modulelist);
ConvertTojsonString(1,$json,'success');
?>