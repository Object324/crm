<?php
global $adb,$currentModule,$current_user;;
$frommodule=$_REQUEST['frommodule']??$currentModule;
$displayinactiv=getUsersettingByLabel($frommodule,'','Scope_DisplayInactiveuser');
if(!$displayinactiv||$displayinactiv=='undefined'){
    if($frommodule=='Home'){
        $displayinactiv='yes';
    }else{
        $displayinactiv='no';
    }
}

if(isset($_REQUEST['value'])&&!empty($_REQUEST['value'])){
    if($_REQUEST['value']=='true'){
        $displayinactiv='yes';
    }else{
        $displayinactiv='no';
    }
    setUsersettingByLabel($frommodule,'','Scope_DisplayInactiveuser',$displayinactiv);
}
$data['displayinactiv']=$displayinactiv;
//主页需要刷新查看范围下拉框
//穿透也需要刷新查看范围下拉框
//wym 231115 BUG0075530 首页-数据简报穿透-取消勾选“显示离职成员” 与首页保持一致 关联需求:XUQIU1002054
if($frommodule=='Home'&&($_REQUEST['refresh']=='chuantou'||$_REQUEST['refresh']=='home')){
    $smarty=new lingdangCRM_Smarty;
    //查看范围默认选中用户
    $Merge_SmOwner=getCurSmOwnerSearchScope('Home');
    unset($Merge_SmOwner["OtherInfo"]['SmOwner_Search_Me']);//去除我负责的
    unset($Merge_SmOwner["OtherInfo"]['SmOwner_Search_Create']);//去除我创建的

    //wym 231030 XUQIU1002054 查看范围下拉框显示优化（普阳） 首页查询组件优化
    $displayinactiv=getUsersettingByLabel($frommodule,'','Scope_DisplayInactiveuser')??'yes';
    $smarty->assign("displayinactiv",$displayinactiv);
    $inactive_userinfo=get_user_array(FALSE, "Inactive", "");
    $inactive_userid=array_keys($inactive_userinfo);
    $smarty->assign("inactiveuser",$inactive_userid);

    $smarty->assign('Merge_SmOwner',$Merge_SmOwner);
    if(count($Merge_SmOwner) > 0){
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
    $smarty->assign('MODULE','Home');

    if($_REQUEST['refresh']=='chuantou'){
        $data['homecontent']=$smarty->fetch('SearchScopeChuantou.tpl');
    }elseif($_REQUEST['refresh']=='home'){
        $data['homecontent']=$smarty->fetch('SearchScope_New.tpl');
    }

}

ConvertTojsonString(1,$data,'success');

?>