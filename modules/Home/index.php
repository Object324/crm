<?php
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//旧版本首页-默认看板的入口文件
require_once(globalStatic::$root_directory.'include/home.php');
global $app_strings, $app_list_strings, $mod_strings,$currentModule;
global $adb, $current_user;

global $theme;
global $languageType;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$homeObj=new Homestuff;
$smarty=new lingdangCRM_Smarty;

//新看板列表
crm_load_class_file("Homeboard", 'modules/Home');
$Homeboardobj = Homeboard::getInstance(0,$currentModule);
$homeboard_list = $Homeboardobj->get_homeboard_list_scope();

$smarty->assign('HOMEBOARDLISTNEW',$homeboard_list);
$smarty->assign('iskehu001',isKehu001ServerPc());
//判断是否有默认看板
$isHaveDefaultKanban =  $Homeboardobj->isHaveDefaultKanban();//判断是否有老看板  yes是有 no是没有
$smarty->assign('isHaveDefaultKanban',$isHaveDefaultKanban);
if($current_user->user_type == 'prm'){
    include_once globalStatic::$root_directory . 'modules/Home/Homeboard_index.php';
}
else{
    if($_REQUEST['newboard'] == 'yes'&&$isHaveDefaultKanban=='yes') {//如果是从新看版点击到默认看板
        $Homeboardobj->save_history_homeboard(0);
    }else{
        $boardid = $Homeboardobj->get_history_homeboard();
        if ($boardid > 0 && $homeboard_list[$boardid] != '') {
            $_REQUEST['boardid'] = $boardid;
        }else if($isHaveDefaultKanban!='yes'){
            //zxm 20231124 BUG0076090 首页看板--当旧看板全部删除，但默认看板依旧为旧看板时，不显示空看板，会显示两到三个老组件
            $boardidarr = array_keys($homeboard_list);
            $_REQUEST['boardid'] =  $boardidarr[0];
        }
        if($_REQUEST['boardid']>0){
            include_once globalStatic::$root_directory . 'modules/Home/Homeboard_index.php';
        }
    }
}


$smarty->assign("current_language",$languageType);
$smarty->assign("IsAdmin",is_admin($current_user));
$smarty->assign("IMAGE_PATH",$image_path);
require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
$checkVersionIs001 = cls_StaticCommonFun::checkVersionIs001();
//获取显示的首页组建

$homedetails = $homeObj->getHomePageFrame($current_user->profileid);
$homedetails = $homeObj->getHomePageFrameMoreUrl($homedetails);

foreach($homedetails as $info){
	$info['Stufftype'] = strtolower($info['Stufftype']);
	//（客户001标准版）系统设置>首页组件模板定制>编辑>所有模块选择框中：应该删除“交易” “现金银行流水账” “应收/应付款汇总”三个模块。
	if($checkVersionIs001 > 0 && $checkVersionIs001 == 55){
		if(in_array($info['Stuffid'],array(6,31,34))){
			continue;
		}
	}
	if($info['presence'] == 0&&$info['source']!='customechart'){
		if($info['Stuffid'] == 35){
			if(vtlib_isModuleActive('Accounts') || vtlib_isModuleActive('Contacts') || vtlib_isModuleActive('Potentials') || vtlib_isModuleActive('ContactRecords') || vtlib_isModuleActive('SalesOrder') || vtlib_isModuleActive('ServiceContracts')){
				$homedata[-1] = $info;
			}
		}else if($info['Stuffid'] == 36){
			$homedata[-2] = $info;
		}else if($info['Stuffid'] == 39){
            crm_load_class_file('HomeBoardNew_39','modules/Home/HomeBoardNew');
            $HomeBoardNew_39_Obj = new HomeBoardNew_39;
            $HomeBoardNew_39_Obj->viewStyle = 'oldboard';
            $info['stuffid'] = $info['Stuffid']; //大小写
            $info['html'] = $HomeBoardNew_39_Obj -> get_stuff_content_html($info);
            $info['stufflisttype'] = 'defaultstuff';
			$homedata[-3] = $info;
		}else if($info['Stuffid'] == 37){
			$homedata[-4] = $info;
		}else if($info['Stuffid'] == 38){
			$homedata[-5] = $info;
		}else if($info['Stuffid'] == 66){

            global $adb;
            $select_kanban_sql = "select usereportid from ld_usereport where `name` ='ServiceKanban'";
            $select_kanban_res = $adb->pquery($select_kanban_sql);
            $usereportid = $adb->query_result($select_kanban_res,0,0);
            $info['usereportid'] = $usereportid;
            $homedata[-10] = $info;//2021-1213 zxm 服务看板 做全横的
        }else if($info['Stuffid'] == 47){
            $homedata[-6] = $info;//2020-1127 zxm 誉帆 项目报表做全横得
        }else if($info['Stuffid'] == 51){
            $homedata[-7] = $info;//2020-1127 zxm 易冲 新销售简报做全横的
        }else if($info['Stuffid'] == 64){
            //zxm  2021-00712 工程行业增加两个首页组件
            $homedata[-8] = $info;
        }else if($info['Stuffid'] == 65){
            $homedata[-9] = $info;
        }else if($info['Stuffid'] == 40){
            //edit: xll 2023/08/14 XUQIU1001400 旧看板中近六个月目标完成情况的页签改为动态读取目标管理中的指标
            crm_load_class_file('HomeBoardNew_40','modules/Home/HomeBoardNew');
            $HomeBoardNew_40_Obj = new HomeBoardNew_40;
            $HomeBoardNew_40_Obj->viewStyle = 'oldboard';
            $info['stuffid'] = $info['Stuffid']; //大小写
            $info['html'] = $HomeBoardNew_40_Obj -> get_stuff_content_html($info);
            $info['stufflisttype'] = 'defaultstuff';
            $end_homedata[] = $info;
        }
		else{
            $end_homedata[] = $info;

		}
	}else if($info['source']=='customechart'){
        $end_homedata[] = $info;
    }
}
if(sizeof($end_homedata) >= 1){
	foreach($end_homedata as $info){
		$homedata[] = $info;
	}
}
//查看范围默认选中用户
$MergeSmowner=getCurSmOwnerSearchScope('Home');

foreach($MergeSmowner['UserCombo'] as $userid => $userinfo){

	$user_arr = array_keys($userinfo);
    $userObj=new Users();
    $userObj->id=$userid;
    $userObj->last_name=$userinfo;
	$users[$userid] =  getUserlastName($userObj);
}

$users[$current_user->id] = getUserFullName($current_user->id);
$userids = implode(',',array_keys($users));
$smarty->assign('ALL_USER_ID',$userids);

//wyt 221118 XUQIU1000853 首页查询组件优化
$Merge_SmOwner=$MergeSmowner;
unset($Merge_SmOwner["OtherInfo"]['SmOwner_Search_Me']);//去除我负责的
unset($Merge_SmOwner["OtherInfo"]['SmOwner_Search_Create']);//去除我创建的
$smarty->assign('Merge_SmOwner',$Merge_SmOwner);

//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(count($Merge_SmOwner) > 0 ){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($Merge_SmOwner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL').getFixedLabel('MEMBER'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));

//增加根据用户查看范围设置,获取记忆值功能
//if (empty($userid)) $userid=$current_user->id;
$boardid = $Homeboardobj->get_history_homeboard();
$adb_select_board = "select content from ld_module_setting_byuser where type = ? and userid = ? and label='lastChangeSearchScopeByUser'";
$result_select_board = $adb->pquery($adb_select_board,array($boardid,$current_user->id));
//如果用户记忆值是高级查看范围或者全部查看范围,读取具体查看范围,并将$selectedSearchScope更新为相应类型
$selectedSearchScope='';
$customSearchScopeValue='';
if($adb->num_rows($result_select_board)>0){
    $selectedSearchScope = $adb->query_result($result_select_board, 0, 'content');
    if (strpos($selectedSearchScope, 'smowner_search_senior') !== false) {
        // 如果包含smowner_search_senior
        list($prefix, $seletedSearchScope) = explode(':', $selectedSearchScope, 2);
        $selectedSearchScope=$prefix;
        $customSearchScopeValue=$seletedSearchScope;
    }
    else if (strpos($selectedSearchScope, 'SmOwner_Search_All') !== false) {
        // 如果包含smowner_search_senior
        list($prefix, $seletedSearchScope) = explode(':', $selectedSearchScope, 2);
        $selectedSearchScope=$prefix;
        $customSearchScopeValue=$seletedSearchScope;
    }
    else{
        $customSearchScopeValue=$adb->query_result($result_select_board, 0, 'content');
    }
}
$smarty->assign('selected_searchscope_value', $customSearchScopeValue);
$smarty->assign('SelectedOwner2',$selectedSearchScope);

//时间下拉选项
crm_load_class_file('DateOperation','include');
$data_select = DateOperation::getHomeDateSearchSelect();
$smarty->assign('DATASELECT',$data_select);

if($current_user->is_admin=="on"){
    $smarty->assign('ISADMIN',1);
}
//删除日志按钮是否显示
$isdelete = 'no';
if($current_user->user_name == 'admin' && empty($_REQUEST['massdelete'])){
	$isdelete = 'yes';
}
//当天日期
$smarty->assign('NOWDATE',date('Y-m-d'));
//系统设置的默认时间 zxm20211112 【首页，销售简报时间增加可设置默认值（王楠）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002217
$deploy_arr = getSys_deploy('345');
$deploy_value = $deploy_arr['deploy_value'];
$customDateValue='';
//增加根据用户时间范围设置,获取记忆值功能
$adb_select_board = "select content from ld_module_setting_byuser where type = ? and userid = ? and label='lastChangeTimeByUser'";
$result_select_board = $adb->pquery($adb_select_board,array($boardid,$current_user->id));
if($adb->num_rows($result_select_board)>0) {
    $deploy_value = $adb->query_result($result_select_board, 0, 'content');
    if (strpos($deploy_value, 'custom') !== false) {
        // 如果包含custom
        list($prefix, $dates) = explode(':', $deploy_value, 2);
        $deploy_value=$prefix;
        $customDateValue=$dates;
        $smarty->assign('customDateValue',$customDateValue);
    }
}

$smarty->assign('timeDefault',$deploy_value);

//增加根据用户审批状态设置,获取记忆值功能
$adb_select_board = "select content from ld_module_setting_byuser where type = ? and userid = ? and label='lastChangeApproveByUser'";
$result_select_board = $adb->pquery($adb_select_board,array($boardid,$current_user->id));
if($adb->num_rows($result_select_board)>0){
    $ApproveStatusHistory = $adb->query_result($result_select_board, 0, 'content');
    if(!empty($ApproveStatusHistory)) {
        $ApproveStatusHistory = explode(",", $ApproveStatusHistory);
    }
}

$approvestatus_arr=['unapproved','approving','approved','rejected','dismissed'];

if(empty($ApproveStatusHistory))
{
     $ApproveStatusHistory=$approvestatus_arr;
}
$smarty->assign('APPROVESTATUSHISTORY',array_values($ApproveStatusHistory));


//edit:duan date:2024/11/16 reason:将审批状态更改为翻译字段，并增加颜色显示
$approve_list = getHomeApproveList();
  
for($i = 0;$i<count($approve_list);$i++){
    if($ApproveStatusHistory){
        if(in_array($approve_list[$i]['value'],$ApproveStatusHistory))
        {
            $approve_list[$i]['selected'] = true;
        }
        
    }else{
        $approve_list[$i]['selected'] = true;
    }
}
$smarty->assign('APPROVE_LIST',json_encode($approve_list));


$curr_year=date('Y').' '.getFixedLabel('YEAR');//年份
$smarty->assign('CURRYEAR',$curr_year);
$smarty->assign('INFO',$_REQUEST['info']);
$smarty->assign('ISDELETE',$isdelete);
$smarty->assign("MODULE",'Home');

$smarty->assign("HOMEFRAME",$homedata);
$smarty->assign("LAYOUT", 2);
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->display("Home/Homestuff.tpl");
exit();
?>