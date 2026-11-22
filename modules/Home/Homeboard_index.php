<?php
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $app_list_strings, $mod_strings,$currentModule;
global $adb, $current_user;

global $theme;
global $languageType;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";

$smarty=new lingdangCRM_Smarty;

crm_load_class_file("Homeboard",'modules/Home');
//$Homeboardobj=new Homeboard($_REQUEST['boardid'],$currentModule);
$Homeboardobj= Homeboard::getInstance($_REQUEST['boardid'],$currentModule);
$smarty->assign("current_language",$languageType);
$smarty->assign("IsAdmin",is_admin($current_user));
if($current_user->is_admin=="on"){
    $smarty->assign('ISADMIN',1);
}
if($current_user->user_type == 'prm'){
    $prm_boardid = $Homeboardobj->getPrmHomeboardId();
    $Homeboardobj->boardid = $prm_boardid;
    $smarty->assign('isHaveDefaultKanban','no');
    $smarty->assign('Home_boardid',$prm_boardid);
    $smarty->assign('PRMHOMEBOARD','yes');
    if(!empty($prm_boardid)){
        $Homeboard_content = $Homeboardobj->get_Homeboard_info($prm_boardid);
    }
    else{
        $Homeboard_content = '';
    }
}else{
    //判断是否有默认看板
    $isHaveDefaultKanban =  $Homeboardobj->isHaveDefaultKanban();
    $smarty->assign('isHaveDefaultKanban',$isHaveDefaultKanban);
    if(isset($_REQUEST['boardid']) && $_REQUEST['boardid']>0){
        $Homeboard_content = $Homeboardobj->get_Homeboard_info($_REQUEST['boardid']);
        $Homeboardobj->save_history_homeboard($_REQUEST['boardid']);
        $smarty->assign('Home_boardid',$_REQUEST['boardid']);
    }else{
        include globalStatic::$root_directory.'modules/Home/index.php';
    }
}

if($Homeboard_content){
    $Homeboard_content['approve_value_array'] = explode(',',$Homeboard_content['approve_value']);
    for($i = 0;$i<count($Homeboard_content['homeboard_plate']);$i++){
        $plate_info = $Homeboard_content['homeboard_plate'][$i];
        for($j=0;$j<count($plate_info['homeboard_plate_stuff']);$j++){
            $stuff_info = $plate_info['homeboard_plate_stuff'][$j];
            if($stuff_info['stufflisttype'] == 'defaultstuff'){
                if(file_exists(globalStatic::$root_directory.'modules/Home/HomeBoardNew/HomeBoardNew_'.$stuff_info['stuffid'].'.php')){
                    crm_load_class_file("HomeBoardNew_" . $stuff_info['stuffid'], 'modules/Home/HomeBoardNew');
                    $stuff_sssclassname = "HomeBoardNew_" . $stuff_info['stuffid'];
                    $HomeBaord_stuffobj = new $stuff_sssclassname();
                }else{
                    crm_load_class_file("HomeBoardNewParent", 'modules/Home/HomeBoardNew');
                    $HomeBaord_stuffobj = new HomeBoardNewParent();
                }
            }else{
                if (file_exists(globalStatic::$root_directory.'modules/Home/HomeBoardNew/HomeBoardNew_'.$stuff_info['stufflisttype'].'.php')){
                    crm_load_class_file("HomeBoardNew_" . $stuff_info['stufflisttype'], 'modules/Home/HomeBoardNew');
                    $stuff_sssclassname = "HomeBoardNew_" . $stuff_info['stufflisttype'];
                    $HomeBaord_stuffobj = new $stuff_sssclassname();
                }
            }

            $Homeboard_content['homeboard_plate'][$i]['homeboard_plate_stuff'][$j]['stuff_url'] = $HomeBaord_stuffobj->get_stuff_url($stuff_info);
            $Homeboard_content['homeboard_plate'][$i]['homeboard_plate_stuff'][$j]['stuff_html'] = $HomeBaord_stuffobj->get_stuff_content_html($Homeboard_content['homeboard_plate'][$i]['homeboard_plate_stuff'][$j]);
        }
    }
}

//新看板列表
$homeboard_list = [];
$homeboard_list = $Homeboardobj->get_homeboard_list_scope();
$smarty->assign('HOMEBOARDLISTNEW',$homeboard_list);
$smarty->assign('iskehu001',isKehu001ServerPc());

crm_load_class_file('DateOperation','include');
$data_select = DateOperation::getHomeDateSearchSelect();
$smarty->assign('DATASELECT',$data_select);
//当天日期
$smarty->assign('NOWDATE',date('Y-m-d'));

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
if(empty($Homeboard_content['selectedSearchScope'])){
    $Homeboard_content['selectedSearchScope'] = $SmOwner_option_arr[0]['value'];
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));

//wym 231030 XUQIU1002054 查看范围下拉框显示优化（普阳） 首页查询组件优化
$displayinactiv=getUsersettingByLabel($currentModule,'','Scope_DisplayInactiveuser')??'yes';
$smarty->assign("displayinactiv",$displayinactiv);
$inactive_userinfo=get_user_array(FALSE, "Inactive", "");
$inactive_userid=array_keys($inactive_userinfo);
$smarty->assign("inactiveuser",$inactive_userid);
$smarty->assign('selected_searchscope_value',$Homeboard_content['customSearchScopeValue']);
$smarty->assign('SelectedOwner2',$Homeboard_content['selectedSearchScope']);
$smarty->assign('Merge_SmOwner',$Merge_SmOwner);
$smarty->assign("MODULE",$currentModule);
$smarty->assign('HOMEBOARD_CONTENT',$Homeboard_content);
//edit:duan date:2024/11/16 reason:将审批状态更改为翻译字段，并增加颜色显示
$approve_list = getHomeApproveList();
for($i = 0;$i<count($approve_list);$i++){
    if(in_array($approve_list[$i]['value'],$Homeboard_content['approve_value_array'])){
        $approve_list[$i]['selected'] = true;
    }else{
        $approve_list[$i]['selected'] = false;
    }
}
$smarty->assign('APPROVE_LIST',json_encode($approve_list));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
$smarty->display("Home/Homeboard.tpl");
exit();
?>