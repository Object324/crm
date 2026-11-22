<?php

//链接模块定制新增或编辑
global $adb;
global $current_user;
$id=$_REQUEST['id'];
$zh_label='';
$en_label='';
$url='';
$scope='all';
$smarty=new lingdangCRM_Smarty();
$smarty->assign("AuthCheck",'no');
$paramvalue_arr=[];
if(!empty($id))
{
    $sql='select * from ld_linkmodulecustom where id=?';
    $result=$adb->pquery($sql,array($id));
    $zh_label=$adb->query_result($result,0,'zh_label');
    $en_label=$adb->query_result($result,0,'en_label');
    $active_icon=$adb->query_result($result,0,'active_icon');
    $url=$adb->query_result($result,0,'url');
    $scope=$adb->query_result($result,0,'scope');
    $entitytype=$adb->query_result($result,0,'entitytype');
    $linkmodule=$adb->query_result($result,0,'linkmodule');
    $linkcvid=$adb->query_result($result,0,'linkcvid');
    $active_icon_arr=explode('/',$active_icon);
    $active_icon_name = $active_icon_arr[sizeof($active_icon_arr)-1];
    if($scope=='user')
    {
        $sql='select group_concat(ld_users.last_name) as names,group_concat(ld_users.id) as ids from ld_linkmodulecustom2user
                inner join ld_users on ld_users.id=ld_linkmodulecustom2user.userid where linkmodulecustomid=?  ';
        $result=$adb->pquery($sql,array($id));
        if($adb->num_rows($result)>0)
        {
             $allocatename=$adb->query_result($result,0,'names');
            $allocateid=$adb->query_result($result,0,'ids');
        }
    }
   else  if($scope=='group')
    {
        $sql='select group_concat(ld_groups.groupname) as names,group_concat(ld_groups.groupid) as ids from 
                    ld_linkmodulecustom2user
                inner join ld_groups on ld_groups.groupid=ld_linkmodulecustom2user.userid where linkmodulecustomid=?  ';
        $result=$adb->pquery($sql,array($id));
        
        if($adb->num_rows($result)>0)
        {
             $allocatename=$adb->query_result($result,0,'names');
            $allocateid=$adb->query_result($result,0,'ids');
        }
    }
	 else  if($scope=='role')
    {
        $sql='select group_concat(ld_profile.profilename) as names,group_concat(ld_profile.profileid) as ids from ld_linkmodulecustom2user
		inner join ld_profile on ld_profile.profileid=ld_linkmodulecustom2user.userid where linkmodulecustomid=?    ';
        $result=$adb->pquery($sql,array($id));
        
        if($adb->num_rows($result)>0)
        {
             $allocatename=$adb->query_result($result,0,'names');
            $allocateid=$adb->query_result($result,0,'ids');
        }
    }
    $title=getFixedLabel("EDIT");

   // @edit:dong @date:2020/10/28 @reason: 数据分类设置为模块
    $smarty->assign('ENTITYTYPE',$entitytype);
    $smarty->assign('LINKMODULE',getTranstab($linkmodule));
    $smarty->assign("AuthCheck",$adb->query_result($result,0,'authcheck'));
    $paramvalue_arr=json_decode(html_entity_decode($adb->query_result($result,0,'paramvalue')),true);
   
    //下面的方法无法获取客户模块的全部视图  公海已分配未分配的视图
  //  $oCustomView =CustomView::getInstance($linkmodule);
    //获取全部数据分类
//    $customviewlist = $oCustomView->getCvListByModule();

    $sql ='select viewname from ld_customview WHERE cvid =?';
    $result = $adb->pquery($sql,array($linkcvid));
    $linkCvidName = $adb->query_result($result,0,0);
    $linkCvidName = $linkCvidName =='All' ?getFixedLabel('ALL') :$linkCvidName;
    $smarty->assign('LINKCVIDNAME',$linkCvidName);


}
else 
{
    $title=getFixedLabel("LBL_HREFMODULE_Custom");
   
}

$_REQUEST['diony']='yes';
$smarty->assign('zh_label',$zh_label);
$smarty->assign("en_label",$en_label);
$smarty->assign("url",$url);
$smarty->assign("allocateid",$allocateid);
$smarty->assign("scope",$scope);
$smarty->assign("active_icon",$active_icon);
$smarty->assign("active_icon_name",$active_icon_name);
$arr=array();
$arr['content']=$smarty->fetch("Settings/LinkModuleCustomPagePopup.tpl");
$arr['title']=$title;
$arr['urlparam_arr']=$paramvalue_arr;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,'success');
?>