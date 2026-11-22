<?php
global $adb,$currentModule,$current_user;

function setHeaderSettingParam(&$scope_arr,&$arr,$contentScope,$contentAll,$content,$current_user,&$display){
    // 选择生效范围
    $scope_arr[$contentScope]['selected'] = 'selected';
    // 选择参数设置
    if($contentScope=='all'){
        // 参数范围设置全员生效值
        $arr[$contentAll]['selected'] = 'selected';
    }else{
        // 参数范围设置个人生效值
        $arr[$content]['selected'] = 'selected';
    }
    // 如果为普通用户且是全员生效
    if (!is_admin($current_user) && $contentScope=='all'){
        // 普通用户,参数设置选项置不可选.
        $display = 'disabled';
    }
}


$smarty = new lingdangCRM_Smarty;
$_REQUEST['diony']='diony';
//$record=$_REQUEST['record'];
//if ($record != $current_user->id){
//    ConvertTojsonString(-1,'','error');
//}
$option=$_REQUEST['option'];
if ($option == 'gethtml'){
    // 全局查找显示方式
    // 控制范围
    $display = '';
    $display_quickfindsetting = '';
    $display_quickcreatesetting = '';
    $display_approvalremindsetting = '';
    $display_helpsetting = '';
    $display_userinfosetting = '';

    // 全局查找显示字段
    $quickfindsetting_arr=[
        'all'=>array('label'=>getFixedLabel('VISIBLED'),'selected'=>''),
        'hide'=>array('label'=>getFixedLabel('HIDDEN'),'selected'=>'')];
    $quickfindsetting_scope_arr=[
        'single'=>array('label'=>getFixedLabel('INDIVIDUAL_EFFECT'),'selected'=>''),
        'all'=>array('label'=>getFixedLabel('ALL_EFFECT'),'selected'=>'')];
    // 快速创建显示方式
    $quickcreatesetting_arr=[
        'all'=>array('label'=>getFixedLabel('DISPLAYTHEALL'),'selected'=>''),
        'icon'=>array('label'=>getFixedLabel('SHOWICON'),'selected'=>''),
        'text'=>array('label'=>getFixedLabel('SHOWTEXT'),'selected'=>''),
        'hide'=>array('label'=>getFixedLabel('HIDDEN'),'selected'=>'')];
    $quickcreatesetting_scope_arr=[
        'single'=>array('label'=>getFixedLabel('INDIVIDUAL_EFFECT'),'selected'=>''),
        'all'=>array('label'=>getFixedLabel('ALL_EFFECT'),'selected'=>'')];
    // 审批与消息显示方式
    $approvalremindsetting_arr=[
        'all'=>array('label'=>getFixedLabel('DISPLAYTHEALL'),'selected'=>''),
        'icon'=>array('label'=>getFixedLabel('SHOWICON'),'selected'=>''),
        'text'=>array('label'=>getFixedLabel('SHOWTEXT'),'selected'=>'')];
    $approvalremindsetting_scope_arr=[
        'single'=>array('label'=>getFixedLabel('INDIVIDUAL_EFFECT'),'selected'=>''),
        'all'=>array('label'=>getFixedLabel('ALL_EFFECT'),'selected'=>'')];
    // 帮助中心显示方式
    $helpsetting_arr=['all'=>array('label'=>getFixedLabel('DISPLAYTHEALL'),'selected'=>''),
        'icon'=>array('label'=>getFixedLabel('SHOWICON'),'selected'=>''),
        'text'=>array('label'=>getFixedLabel('SHOWTEXT'),'selected'=>''),
        'hide'=>array('label'=>getFixedLabel('HIDDEN'),'selected'=>'')];
    $helpsetting_scope_arr=[
        'single'=>array('label'=>getFixedLabel('INDIVIDUAL_EFFECT'),'selected'=>''),
        'all'=>array('label'=>getFixedLabel('ALL_EFFECT'),'selected'=>'')];
    // 个人信息显示方式
    $userinfosetting_arr=['all'=>array('label'=>getFixedLabel('DISPLAYTHEALL'),'selected'=>''),
        'icon'=>array('label'=>getFixedLabel('SHOWAVATAR'),'selected'=>''),
        'text'=>array('label'=>getFixedLabel('SHOWTEXT'),'selected'=>'')];
    $userinfosetting_scope_arr=[
        'single'=>array('label'=>getFixedLabel('INDIVIDUAL_EFFECT'),'selected'=>''),
        'all'=>array('label'=>getFixedLabel('ALL_EFFECT'),'selected'=>'')];
    // 汇总上述数据操作前端tpl操作
    $headersetting_arr=[
        'QucikFindSetting' => array(&$quickfindsetting_scope_arr,&$quickfindsetting_arr,&$display_quickfindsetting),
        'QucikCreateSetting' => array(&$quickcreatesetting_scope_arr,&$quickcreatesetting_arr,&$display_quickcreatesetting),
        'ApproveRemindSetting' => array(&$approvalremindsetting_scope_arr,&$approvalremindsetting_arr,&$display_approvalremindsetting),
        'HelpManualSetting' => array(&$helpsetting_scope_arr,&$helpsetting_arr,&$display_helpsetting),
        'UserInfoSetting' => array(&$userinfosetting_scope_arr,&$userinfosetting_arr,&$display_userinfosetting),
    ];
    // 设置左侧列select
    if($current_user->is_admin=='off'){
        $display = 'disabled';
    }
    foreach ($headersetting_arr as $key => &$value){
        $keyScope = $key.'Scope';
        // 查询生效范围,userid为-1时查询生效范围
        $contentScope=getUsersettingByLabel('Header','-1',$keyScope);
        // 查询全员生效设置参数,userid为-1时查询全员生效设置参数
        $contentAll = getUsersettingByLabel('Header','-1',$key);
        // 查询个人生效设置参数
        $content = getUsersettingByLabel('Header',$current_user->id,$key);
        if (empty($contentScope) || $contentScope=='undefined'){
            $contentScope='single';
        }
        if (empty($contentAll) || $contentAll=='undefined'){
            $contentAll='all';
        }
        if (empty($content) || $content=='undefined'){
            $content='all';
        }
        setHeaderSettingParam($value[0],$value[1],$contentScope,$contentAll,$content,$current_user,$value[2]);
    }
//    dump( $dsiplay_quickfindsetting.$dsiplay_quickcreatesetting.$dsiplay_approvalremindsetting.$dsiplay_helpsetting.$dsiplay_userinfosetting );
    $smarty->assign('quickfindsetting_arr',$headersetting_arr['QucikFindSetting'][1]);
    $smarty->assign('quickfindsetting_scope_arr',$headersetting_arr['QucikFindSetting'][0]);
    $smarty->assign('quickcreatesetting_arr',$headersetting_arr['QucikCreateSetting'][1]);
    $smarty->assign('quickcreatesetting_scope_arr',$headersetting_arr['QucikCreateSetting'][0]);
    $smarty->assign('approvalremindsetting_arr',$headersetting_arr['ApproveRemindSetting'][1]);
    $smarty->assign('approvalremindsetting_scope_arr',$headersetting_arr['ApproveRemindSetting'][0]);
    $smarty->assign('userinfosetting_arr',$headersetting_arr['UserInfoSetting'][1]);
    $smarty->assign('userinfosetting_scope_arr',$headersetting_arr['UserInfoSetting'][0]);
    $smarty->assign('helpsetting_arr',$headersetting_arr['HelpManualSetting'][1]);
    $smarty->assign('helpsetting_scope_arr',$headersetting_arr['HelpManualSetting'][0]);
    // select是否可选设置
    $smarty->assign('display',$display);
    $smarty->assign('display_quickfindsetting',$headersetting_arr['QucikFindSetting'][2]);
    $smarty->assign('display_quickcreatesetting',$headersetting_arr['QucikCreateSetting'][2]);
    $smarty->assign('display_approvalremindsetting',$headersetting_arr['ApproveRemindSetting'][2]);
    $smarty->assign('display_helpsetting',$headersetting_arr['HelpManualSetting'][2]);
    $smarty->assign('display_userinfosetting',$headersetting_arr['UserInfoSetting'][2]);
//    dump(array($quickfindsetting_arr,$quickcreatesetting_arr,$approvalremindsetting_arr,$userinfosetting_arr));
    $content = $smarty->fetch('HeaderSettings.tpl');

    $arr['title']=getFixedLabel("HEADERSETTINGS");
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['content']=$content;
    ConvertTojsonString(1,$arr,'success');
}else if ($option == 'save'){
    $qucikfindsetting=$_REQUEST['qucikfindsetting'];
    $quickcreatesetting=$_REQUEST['quickcreatesetting'];
    $approvalremindsetting=$_REQUEST['approvalremindsetting'];
    $userinfosetting=$_REQUEST['userinfosetting'];
    $helpmanualsetting=$_REQUEST['helpmanualsetting'];
    // 获取url中的参数生效范围字段
    $quickfindsetting_scope=$_REQUEST['quickfindsetting_scope'];
    $quickcreatesetting_scope=$_REQUEST['quickcreatesetting_scope'];
    $approvalremindsetting_scope=$_REQUEST['approvalremindsetting_scope'];
    $helpsetting_scope=$_REQUEST['helpsetting_scope'];
    $userinfosetting_scope=$_REQUEST['userinfosetting_scope'];
    $headersetting_arr=array(
        'QucikFindSetting'=>$qucikfindsetting,
        'QucikCreateSetting'=>$quickcreatesetting,
        'ApproveRemindSetting'=>$approvalremindsetting,
        'UserInfoSetting'=>$userinfosetting,
        'HelpManualSetting'=>$helpmanualsetting
    );
    $headersetting_scope_arr=array(
        'QucikFindSettingScope'=>$quickfindsetting_scope,
        'QucikCreateSettingScope'=>$quickcreatesetting_scope,
        'ApproveRemindSettingScope'=>$approvalremindsetting_scope,
        'UserInfoSettingScope'=>$userinfosetting_scope,
        'HelpManualSettingScope'=>$helpsetting_scope
    );
    foreach ($headersetting_arr as $key => $value){
        $keyScope = $key.'Scope';

        if ($current_user->is_admin=='on'){
            // 如果是管理员设置生效范围
            setUsersettingByLabel('Header','-1',$keyScope,$headersetting_scope_arr[$keyScope]);
            // 如果是全员生效设置全员设置参数
            setUsersettingByLabel('Header','-1',$key,$value);
            if($headersetting_scope_arr[$keyScope] == 'single'){
                setUsersettingByLabel('Header',$current_user->id,$key,$value);
            }
        }else{
            // 如果是普通用户
            if($headersetting_scope_arr[$keyScope] == 'single'){
                setUsersettingByLabel('Header',$current_user->id,$key,$value);
            }
        }
    }
    ConvertTojsonString(1,'','success');
}
?>