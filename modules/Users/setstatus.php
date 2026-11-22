<?php
global $current_user,$adb;
$reg=RegOp::getInstance();
if(isset($_REQUEST['ajax']) && isset($_REQUEST['status']) && isset($_REQUEST['userid'])){
    
    $user_type = 'crm';
    $sql_select = 'select crm_user_type from ld_users where id = ?';
    $result_select = $adb->pquery($sql_select,array($_REQUEST['userid']));

    if($adb->num_rows($result_select) > 0){
        $user_type = $adb->query_result($result_select,0,'crm_user_type');
    }
    if($user_type == 'crm'){
        $user_query="select 1 from ld_users where status='active' and crm_user_type = 'crm'";
        if(isset($_REQUEST['userid'])&& $_REQUEST['userid']>0)
        {
            $user_query .=' and id!='.$_REQUEST['userid'];
        }
        $result=$adb->pquery($user_query);
        $strUsingCount=$adb->num_rows($result);

        if($_REQUEST['status']=='ACTIVATE'||!isset($_REQUEST['userid'])||$_REQUEST['userid']<=0)
        {
            $strUsingCount=$strUsingCount+1;
        }
        $regCount=$reg->GetUserCount();
    }
    else{
        $user_query="select 1 from ld_users where status='active' and crm_user_type = 'prm'";
        if(isset($_REQUEST['userid'])&& $_REQUEST['userid']>0)
        {
            $user_query .=' and id!='.$_REQUEST['userid'];
        }
        $result=$adb->pquery($user_query);
        $strUsingCount=$adb->num_rows($result);

        if($_REQUEST['status']=='ACTIVATE'||!isset($_REQUEST['userid'])||$_REQUEST['userid']<=0)
        {
            $strUsingCount=$strUsingCount+1;
        }
        $regCount=$reg->getPrmUserCount();
    }

     
     if($_REQUEST['status']!='Active'&&$reg->compareCount($regCount,$strUsingCount)<=0)
     {
         echo '###ERROR###'. getFixedLabel('USERSAVEREGISTER').$regCount;
        die;
     }
    $userObj=new Users();
    if($_REQUEST['status']=='Active'){
         if(isPermitted("Users","UserStop")=='no')
         {
            exit("没有权限");
         }
    //点击离职按钮，员工状态变为离职，删除员工相关通讯录
        $sql='update ld_users set status="Inactive",modifiedtime=NOW() ,wx_userid = "" ,wx_openid = "",dingtalk_userid = "",dingtalk_unionid = "",yunzhijia_openid = "",yunzhijia_wbuserid ="",fanwei_userid ="",zhiyuan_userid =""
        where id='.$_REQUEST['userid'];
        $adb->pquery($sql);
        //zxm 20210122【成员管理，点击操作列的“停用”和“启用”增加修改日志】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001253

        $userObj->insertUserLog('Users',$_REQUEST['userid'],$current_user->id,'Active',"Inactive",'status');
    }else{
        $sql='update ld_users set status="Active",modifiedtime=NOW() where id='.$_REQUEST['userid'];
        $adb->pquery($sql);
        //zxm 20210122【成员管理，点击操作列的“停用”和“启用”增加修改日志】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001001253
        $userObj->insertUserLog('Users',$_REQUEST['userid'],$current_user->id,'Inactive',"Active",'status');
    }

	$cachekey = 'cache_getusercachenameinfo';
	unsetCache($cachekey);
}
