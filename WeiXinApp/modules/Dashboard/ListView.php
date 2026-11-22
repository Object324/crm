<?php
//zkt 20231023 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb, $current_user;
//editor:gyq_107 reason:企业微信即时库存查询报表  2019/4/3 18:13
$second_action = $_REQUEST['second_action'];
if ($second_action == 'detail') {
    crm_load_class_file('cls_ReportDetailInfoWX', 'WeiXinApp/modules/Dashboard');
    if ($_REQUEST['selectuid'] == 'me') {
        $_REQUEST['selectuid'] = $current_user->id;
    }
    $detailObj = new cls_ReportDetailInfoWX($_REQUEST['record']);
    $detailObj->DashboardDetail();
    exit;
}
//城亚 zxm 2022-5-01 金蝶库存查询
if ($second_action == 'chengya_search_kucun') {
    require_once globalStatic::$root_directory . 'modules/Home/CustomMade/ChengYaUtils.php';
    $chengyaObj = new ChengYaUtils();
    $chengyaObj->DashboardChengYaKucun();
    die;
}
//济凡 wyt XUQIU1000377 220711 金蝶库存查询
if ($second_action == 'jifan_search_kucun') {
    require_once globalStatic::$root_directory . 'modules/Home/CustomMade/JiFanUtils.php';
    $jifanObj = new JiFanUtils();
    $jifanObj->DashboardJiFanKucun();
    die;
}
//列表页面
$label_arr=array(
    'LBL_NOALLOCATE',//公海未分配
    'LBL_PUBLICALLOCATE',//公海已分配
    'ALL',//全部
    'TOBEALLOCATED',//待分配
    'BEURGED',//已催单
    'INPROCESS',//处理中
    'CLOSEDBILL',//已结单
    'zhang',//张
    'EXPANDINVENTORYDETAILS',//展开库存详情
    'nodata',//没有数据
    'NOMOREDATA',//没有更多数据
    'NOTMPDATA',//没有%s数据
    'NOMORETMPDATA',//没有更多%s数据
    'MYSCHEDULE',//我的日程
    'OTHERSCHEDULE',//他人日程
    'CUSTOMIZESEARCH',//高级查找
    'PLEASESELECTSTARTDATE',//请选择开始日期
    'PLEASESELECTENDDATE',//请选择结束日期
    'TO',//至
    'pleaseenter',//请输入
    'NOADVANCEDSEARCHCONDITIONS',//暂无高级查找条件，请%s前往设置
    'RESET',//重置
    'ALLSELECT',//全选
    'LBL_PLEASE_SELECT',//请选择
    'SEARCHNEW',//搜索
    'NEW',//新增
    'TOTALOF',//共
    'RECORDNUMS',//条记录
    'Paymentplan',//收款
    'CHECK',//查重
    'Highseaspool',//公海池
    'CREATEBUSINESSCARD',//拍名片
    'ENTERPRISEWECHATCUSTOMERS',//企业微信客户
    'CreateDebuction',//预收
    'NORMAL',//普通
    'SEARCHFORVISITORS',//搜索拜访对象、地址、人员、签到时间、误差
    'ONEPICTUREBUSINESSCARD',//创建名片时只能上传1张图片
    'UPLOADFAILED',//上传失败
    'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
    'CONFIGURECUSTOMERCONTACTPARAMETERS',//企业微信后台没有配置客户联系参数
    'STOWINVENTORYDETAILS',//收起库存详情
    'VERSIONLOWPLEASEUPGRADE',//版本过低请升级
    'RECORDSINTOTAL',//共%d条记录
    'UPLOADING',//上传中
    'UPLOADSUCCEEDED',//上传成功
    'Quickly_create',//快速创建
    'PLEASESELECTATLEASTONEITEM',//请至少选择一项
    'FORMATERROR',//格式错误
    'MORE',//更多
    'NOOPERATIONPERMISSIONS',//没有更多操作权限
    'ALLOCATE',//分配
    'EDIT',//编辑
    'SHARE',//共享
    'SUBMITAPPROVAL',//提交审批
    'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
    'RETRACEMENT',//回撤
    'RETRACENOTSUBMITTED',//执行后，该单据将被还原到“未提交”状态，确定要撤销吗？
    'RETREATSUCCEEDED',//回撤成功
    'COPY',//复制
    'DELETE',//删除
    'SUREWANTDELETE',//确定要删除吗？
    'DELETESUCCESSFUL',//删除成功
    'RECEIVE',//领取
    'SUREYOUWANTCOLLECT',//确定要领取？
    'SUCCESSFULLYRECEIVED',//领取成功
    'InventoryQuery',//即时库存查询
    'INVENTORYINQUIRY',//库存查询
    'ALLSELECT',//全选
);
$fixedlabel_arr = TransFieldlabel($label_arr);
$fixedlabel_arr = CombineLabelSolution('%s','NOADVANCEDSEARCHCONDITIONS',$fixedlabel_arr);// 没有更多%s数据
$fixedlabel_arr = CombineLabelSolution('%s','NOMORETMPDATA',$fixedlabel_arr);// 没有更多%s数据
$fixedlabel_arr = CombineLabelSolution('%s','NOTMPDATA',$fixedlabel_arr);//没有%s数据
$fixedlabel_arr = CombineLabelSolution('%d','RECORDSINTOTAL',$fixedlabel_arr);
$res['arrFixedLabel']=$fixedlabel_arr;

//列表内容
$label_arr=array(
    'RELATIONAL',//关联
    'TOBEALLOCATED',//待分配
    'BEURGED',//已催单
    'INPROCESS',//处理中
    'CLOSEDBILL',//已结单
    'MORE',//更多
    'WECHATVERSIONLOWPLEASEUPGRADE',//当前企业微信版本过低，请升级
    'DISCUSSIONGROUP',//讨论组
    'ALLOCATE',//分配
    'NOOPERATIONPERMISSIONS',//没有更多操作权限
    'EDIT',//编辑
    'SHARE',//共享
    'RECEIVE',//领取
    'SUREYOUWANTCOLLECT',//确定要领取？
    'URGE',//催单
    'CLOSEBILL',//结单
    'REOPEN',//重新打开
    'SUBMITAPPROVAL',//提交审批
    'RETRACEMENT',//回撤
    'RETRACENOTSUBMITTED',//执行后，该单据将被还原到“未提交”状态，确定要撤销吗？
    'COPY',//复制
    'DELETE',//删除
    'SuccessDeleted',//删除成功！
    'SUREWANTDELETE',//确定要删除吗？
    'SUCCESSFULLYRECEIVED',//领取成功
    'SUCCESSFULLYSUBMITTEDAPPROVAL',//提交审批成功
    'RETREATSUCCEEDED',//回撤成功
    'SURETOASSOCIATE',//确定要关联吗？
    'NONUMBERTODIAL',//没有可拨打号码
    'CREATETMPQUICKLY',//是否快速创建%s？
    'QTY',
    'MAOHAO'
);
$fixedlabel_content_arr = TransFieldlabel($label_arr);
$fixedlabel_content_arr = CombineLabelSolution('%s','CREATETMPQUICKLY',$fixedlabel_content_arr);
$res['arrFixedLabel_content']=$fixedlabel_content_arr;

//金蝶云星空库存报表
if ($second_action == 'search_erp_stcok') {
    $_REQUEST['from_mobile'] = 'yes';//来自移动端
    $searchcontent = $_REQUEST['filter']['searchcontent'];

    $search_arr = [];
    if (!empty($searchcontent)) {
        foreach ($_REQUEST['report_high_search'] as $arr) {
            $search_arr_List[] = $arr['fieldname'] . '|@@|' . $searchcontent;
        }
    }

    foreach ($_REQUEST['report_high_search'] as $arr) {
        if ($arr['text'] != getFixedLabel('ALL') && !empty($arr['text'])) {
            $search_arr[] = $arr['fieldname'] . '|@@|' . $arr['text'];
        }
    }
    // @edit:dong @date:2024/12/17 @reason: 两个条件同时存在 则联合查询
    // @edit:dong @date:2024/12/17 @reason: 云星空已支持

    // @edit:dong @date:2024/12/17 @reason: 高级搜索条件  web过来的算高级搜索
    if (!empty($search_arr)) {
        $_REQUEST['search'] = implode('|%%|', $search_arr);
    }
    // @edit:dong @date:2024/12/17 @reason: 列表的模糊搜索条件 根据设置的搜索字段生成
    if (!empty($search_arr_List)) {
        $_REQUEST['search_arr_List'] = implode('|%%|', $search_arr_List);
    }

    require_once globalStatic::$root_directory . 'modules/ReportAnalysis/stock_report.php';
    die;
}
///** 像是以前的老工作台数据  现在不走这里了 先注释  报错再打开吧
// * $nameSwitchArr = array('monthweekreport'=>'weeklystatistics','Salesfunnel'=>'salesfunnel','Contractamount'=>'contractamount','Salessituation'=>'salessituation',
// * 'Returnamount'=>'returnamount','signednumber'=>'signednumber','signedamount'=>'signedamount','cashbillamount'=>'paymentamount',
// * 'expense_commission'=>'coststatistics','daylog'=>'daylog','weeklog'=>'weeklog','monthlog'=>'monthlog');
// * require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
// * $SQL = 'SELECT id,name,graphtype,modulenames,image,ld_desk.fieldlabel desk_fieldlable
// * FROM ld_dashboard_app LEFT JOIN ld_desk on ld_desk.labelbol=ld_dashboard_app.labelbol
// * WHERE presence=2 AND ld_desk.languagetype="'.$languageType.'"ORDER BY sequence ASC ';
// * $RESULT = $adb->pquery($SQL,array());
// * $NUMS = $adb->num_rows($RESULT);
// * $sys_78 = getSys_deploy(78);//设置首页组件中是否显示周月统计
// *
// * $oftenrep = isPermitted('OftenUseReport','index');
// * if($NUMS > 0) {
// * for ($i = 0; $i < $NUMS; $i++) {
// * //0029106: 仪表盘的显示是否根据权限来调整，例如没有使用的模块，是否可以关掉
// * $modulenames = $adb->query_result($RESULT, $i, 'modulenames');
// * $allowshow = 0;
// * $countmodule = 0;
// * if(!empty($modulenames)){
// * $modulenamesArr =  explode(',',$modulenames);
// * $countmodule = count($modulenamesArr);
// * $j = 0;
// * foreach($modulenamesArr as $value){
// * if(!vtlib_isModuleActive($value)||isPermitted($value,'index')=='no'){
// * $j++;
// * }
// * }
// * if($j==$countmodule) $allowshow=1;
// * }else{
// * $allowshow = 0;
// * }
// * if($allowshow==1){
// * continue;
// * }
// * $name = $adb->query_result($RESULT, $i, 'name');
// * //    0027954: 手机端 仪表盘， 签约数量龙虎榜，签约金额龙虎榜，回款金额龙虎榜，应该根据pc端常用报表的权限跟数据范围来控制
// * if($oftenrep=='no'&&in_array($name,array('signednumber','signedamount','cashbillamount'))) continue;
// *
// * //    0029943: 微信端：置首页组件中是否显示周月统计为否时，仪表盘中周月统计应该隐藏
// * if($name=='monthweekreport'&&$sys_78['deploy_value']==1) continue;
// *
// * $resultArr[$i]['record'] = $adb->query_result($RESULT, $i, 'id');
// * $resultArr[$i]['name'] = $nameSwitchArr[$adb->query_result($RESULT, $i, 'name')];
// * $resultArr[$i]['fieldlabel'] = $adb->query_result($RESULT, $i, 'desk_fieldlable');
// * $resultArr[$i]['image'] = $adb->query_result($RESULT, $i, 'image');
// * }
// * $resultArrFinal['list'] = $resultArr;
// * ConvertTojsonString(1,$resultArrFinal,'ListView');
// * }else{
// * ConvertTojsonString(-1,array(),'EmptyDate');
// * }**/

