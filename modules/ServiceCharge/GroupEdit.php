<?php
require_once('Smarty_setup.php');
require("user_privileges/user_language_".$current_user->id.'.php');
global $adb,$mod_strings,$app_strings,$theme,$currentModule,$singlepane_view,$current_user,$adb;
$smarty=new lingdangCRM_Smarty();
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign('TYPE',$_REQUEST['type']);
$smarty->assign("APP", $app_strings);
$smarty->assign("MODULE",$_REQUEST['module']);
/**
 * edit:chj
 * reason:分组保存
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
if(isset($_REQUEST['type']) && ($_REQUEST['type'] == 'Add' || $_REQUEST['type'] == 'Edit'))
{
    if(isset($_REQUEST['zhgroupname']) || isset($_REQUEST['engroupname']))
    {
        $sql = 'select 1 from ld_servicegroup ';
        if($languageType == 'zh')
            $sql .="where servicegroupname_zh = '".$_REQUEST['zhgroupname']."'";
        else
            $sql .="where servicegroupname_en = '".$_REQUEST['engroupname']."'";
		if($_REQUEST['type'] == 'Edit')
		{
			$sql .= ' and servicegroupid != ' . $_REQUEST['groupid'];
		}
        $query = $adb->pquery($sql,array());
        if($adb->num_rows($query) >= 1)
        {
           echo '###SUCCESS###1';
           exit();
        }
        else
        {
            if($_REQUEST['type'] == 'Add')
            {
                $sql = "select ifnull(max(sequence),0) as sequence from ld_servicegroup";
                $query = $adb->pquery($sql,array());
                $sequence = $adb->query_result($query,0,0);
                $sql = "insert into ld_servicegroup(servicegroupname_zh,servicegroupname_en,sequence) value (?,?,?)";
                $adb->pquery($sql,array($_REQUEST['zhgroupname'],$_REQUEST['engroupname'],$sequence+1));
                echo '###SUCCESS###' . $adb->getLastInsertID();
                exit();
            }
            else
            {
                $sql = "update ld_servicegroup set servicegroupname_zh = ?,servicegroupname_en=? where servicegroupid=?";
                $adb->pquery($sql,array($_REQUEST['zhgroupname'],$_REQUEST['engroupname'],$_REQUEST['groupid']));
                echo '###SUCCESS###' . $_REQUEST['groupid'];
                exit();
            }
        }
    }
    else if($_REQUEST['type'] == 'Edit')
    {
        $sql = "select servicegroupname_zh,servicegroupname_en from ld_servicegroup where servicegroupid = ?";
        $query = $adb->pquery($sql,array($_REQUEST['groupid']));
        $smarty->assign('GROUPZHNAME',$adb->query_result($query,0,'servicegroupname_zh'));
        $smarty->assign('GROUPENNAME',$adb->query_result($query,0,'servicegroupname_en'));
    }
    if($_REQUEST['type'] == 'Edit')
        $smarty->assign('GROUPID',$_REQUEST['groupid']);
    else
        $smarty->assign('GROUPID',0);
}
/**
 * edit:chj
 * reason:分组编辑、删除
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
else if(isset($_REQUEST['type']) && ($_REQUEST['type'] == 'Del'))
{
    if(isset($_REQUEST['groupid']) && $_REQUEST['groupid'] > 0 && !isset($_REQUEST['selectgroupid']))
    {
        if($languageType == 'zh')
            $servicegroupname='servicegroupname_zh';
        else
            $servicegroupname='servicegroupname_en';
        $sql = "select is_edit,$servicegroupname from ld_servicegroup where servicegroupid = ?";
        $query = $adb->pquery($sql,array($_REQUEST['groupid']));
        $is_edit = $adb->query_result($query,0,'is_edit');
        $smarty->assign('GROUPNAME',$adb->query_result($query,0,$servicegroupname));
        if($is_edit == 0)
        {
            echo '###SUCCESS###2';
            exit();
        }
        else
        {
            $sql = "select $servicegroupname,servicegroupid from ld_servicegroup where servicegroupid not in (1,3) and servicegroupid != ? order by sequence asc";
            $result = $adb->pquery($sql,array($_REQUEST['groupid']));
            for($i = 0; $i<$adb->num_rows($result); $i++)
            {
                $Group[$adb->query_result($result,$i,'servicegroupid')] = $adb->query_result($result,$i,$servicegroupname);
            }
            $smarty->assign("GROUP",$Group);
        }
        $smarty->assign('GROUPID',$_REQUEST['groupid']);
    }
    else
    {
        if(isset($_REQUEST['selectgroupid']))
        {
            if($_REQUEST['selectgroupid'] == 2)
                $servicegroup = 0;
            else
                $servicegroup = $_REQUEST['selectgroupid'];
            $query = "update ld_account set servicegroup = $servicegroup where servicegroup = ?";
            $adb->pquery($query,array($_REQUEST['groupid']));
            //删除分组
            if($_REQUEST['type'] == 'Del')
            {
                $sql = 'delete from ld_servicegroup where servicegroupid = ?';
                $adb->pquery($sql,array($_REQUEST['groupid']));   
            }
        }
    }
    
}
/**
 * edit:chj
 * reason:分组排序
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
else if(isset($_REQUEST['type']) && $_REQUEST['type'] == 'Soft')
{
    if(isset($_REQUEST['selectgroupname']) && $_REQUEST['selectgroupname'] != '')
    {
        $sourcename = explode(';',$_REQUEST['selectgroupname']);
        for($i = 0; $i<count($sourcename); $i++)
        {
            $sql = 'update ld_servicegroup set sequence = ? where servicegroupid = ?';
            $adb->pquery($sql,array($i + 1,$sourcename[$i]));;
        }
    }
    else
    {
        if($languageType == 'zh')
            $servicegroupname='servicegroupname_zh';
        else
            $servicegroupname='servicegroupname_en';
        $sql = "select servicegroupid,$servicegroupname from ld_servicegroup order by sequence asc";
        $query = $adb->pquery($sql,array());
        for($i = 0; $i<$adb->num_rows($query); $i++)
        {
            $groupName[$adb->query_result($query,$i,'servicegroupid')] = $adb->query_result($query,$i,$servicegroupname);
        }
        $smarty->assign('GROUPNAME',$groupName);   
    }
}
/**
 * edit:chj
 * reason:客户分配
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
else if(isset($_REQUEST['type']) && $_REQUEST['type'] == 'Dis')
{
   
    if(isset($_REQUEST['assigned_user_id']))
    {
        
      $userId=trim($_REQUEST['selusername'],',');
      $sql = "update ld_account set servicecasher = ? where accountid in ($userId)";
      $adb->pquery($sql,array($_REQUEST['assigned_user_id']));
      if(!isset($_REQUEST['return_action_detail']))//如果不是明细界面的分配，则跳转到序时簿
      {
         header("Location:index.php?module=ServiceCharge&action=ListView");
      }
     
    }
    else
    {
        /**
         * 分配时，应该能够看到所有用户
         * @reason 0015060: 服务收费管理>明细>分配：分配弹出层，没有显示全部用户
         * @author Tujt 2015-05-19
         */
        $assigned_user_id = $current_user->id;
        $userArr = get_user_array(FALSE, "Active", $assigned_user_id);
        $smarty->assign('optText',$userArr[$assigned_user_id]);
        // $MergeSmowner=getCurSmOwnerSearchScope($currentModule);
      
        // $i=0;
        // foreach($MergeSmowner["UserCombo"] as $key => $lastname)
        // {
        //     foreach($lastname as $name => $selected)
        //     {
        //          if($i==0)
        //          {
        //             $smarty->assign('optText',$name);
        //          }
        //         $userArr[$key]=$name;
        //         $i++;
        //     }
            
        // }
        
       if($_REQUEST['return_action'])
       {
         $smarty->assign('return_action',$_REQUEST['return_action']);
       }
       else
         $smarty->assign('return_action','');
       $smarty->assign('USERARR',$userArr);
       $storearray = getSelectedRecords($_REQUEST,'ServiceCharge',$_REQUEST['idstring'],$excludedRecords);
        $_REQUEST['idstring']=implode(',',$storearray);
       
       $smarty->assign('USERINFO',$_REQUEST['idstring']);
    }
}
/**
 * edit:chj
 * reason:客户移动分组
 * description: 服务收费管理(CRMV5.6)
 * date:2014-8-15
 * */
else if(isset($_REQUEST['type']) && $_REQUEST['type'] == 'Move')
{
    if(isset($_REQUEST['servicegroup']))
    {
       $userId=trim($_REQUEST['selusername'],',');
        $sql = "update ld_account set servicegroup = ? where accountid in ($userId)";
        if($_REQUEST['servicegroup'] == 2)  //2未分组
            $adb->pquery($sql,array(0));
        else
            $adb->pquery($sql,array($_REQUEST['servicegroup']));
        header("Location:index.php?module=ServiceCharge&action=ListView&groupid=".$_REQUEST['servicegroup']);
        
    }
    else
    {
        if($languageType == 'zh')
            $servicegroupname='servicegroupname_zh';
        else
            $servicegroupname='servicegroupname_en';
        $sql = "select $servicegroupname,servicegroupid from ld_servicegroup where servicegroupid not in (1,3) and servicegroupid != ? order by sequence asc";
        $result = $adb->pquery($sql,array($_REQUEST['groupid']));
        for($i = 0; $i<$adb->num_rows($result); $i++)
        {
            $Group[$adb->query_result($result,$i,'servicegroupid')] = $adb->query_result($result,$i,$servicegroupname);
        }
        $smarty->assign("GROUP",$Group);
          $storearray = getSelectedRecords($_REQUEST,'ServiceCharge',$_REQUEST['idstring'],$excludedRecords);
        $_REQUEST['idstring']=implode(',',$storearray);
        $smarty->assign('USERINFO',$_REQUEST['idstring']);
    }
}
echo '###SUCCESS###';
$smarty->display("ServiceChargeGroup.tpl");
exit();
?>