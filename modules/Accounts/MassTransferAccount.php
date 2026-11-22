<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/
//zkt 20231009 XUQIU1001341 登录记住密码优化+SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$currentModule;
$smarty=new lingdangCRM_Smarty();
crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
$cls_PublicAccounts = new cls_PublicAccounts($currentModule);
$public_account = $cls_PublicAccounts->getPublicAccountConfig();
if(!empty($_REQUEST['select_ids'])){
	$select_ids = [];
	$record_str = '';	//需要处理的单据id
	if($_REQUEST['select_ids'] == 'all'){
		$customView = CustomView::getInstance($currentModule);
		$queryGenerator =QueryGenerator::getInstance($currentModule, $current_user,$customView);
		$viewid = $customView->getViewId($currentModule);
		if ($viewid != "0") {
		   $queryGenerator->initForCustomViewById($viewid);
		} else {
			$queryGenerator->initForDefaultCustomView();
		}
		if($_REQUEST['query'] == 'true') {
			$_REQUEST['searchtype'] = trim($_REQUEST['searchtype']);
			$queryGenerator->addUserSearchConditions($_REQUEST);
		}
		$page_list_query=$queryGenerator->getQuery('',1);
		list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
		$result = $adb->pquery($page_list_query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$select_ids[] = $adb->query_result($result,$i,'accountid');
			}
		}
		$record_str = implode(',',$select_ids);
	}else{
		$select_ids = explode(';',rtrim($_REQUEST['select_ids'],';'));
		$record_str = implode(',',$select_ids);
	}
    crm_load_class_file('cls_publicpool_profile','include/utils');
    $pool_profileobj = new cls_publicpool_profile($currentModule,$current_user->id,0);


    //@edit:liushuai,2021-07-09,reason:【ID1001735】公海成员，普通销售线索和普通客户增加“转公海”功能(转换公海弹出层)
    $focus = CRMEntity::getInstance($currentModule);
    if (isset($_REQUEST['popupobj_type']) && in_array($_REQUEST['popupobj_type'], array('listpage','detailviewpage'))) {
        //序时簿列表单据,详情页转换公海，公海池pool_id从数据库获取
        $commonaccount = 'yes';
        $focus->retrieve_entity_info($record_str,$currentModule);
        $_REQUEST['pool_id'] = $focus->column_fields['pool_id'];//重新赋值
        //zkt 20220707 BUG0053654新建账套只有默认公海，普通用户->客户列表->转公海，界面异常 
        if(!isset($focus->column_fields['publicaccount'])){
            //是否公海字段未启用
            $tablename = $focus->table_name;
            $tableindex = $focus->table_index;
            $tmpsql = "select publicaccount from $tablename where $tableindex=?";
            $tmpresult = $adb->pquery($tmpsql,array($record_str));
            if($adb->num_rows($tmpresult)>0){
                $focus->column_fields['publicaccount'] = $adb->query_result($tmpresult,0,'publicaccount');
            }
        }
        if ($focus->column_fields['publicaccount'] >= 1) {//公海客户
            //zkt 20220708 BUG0053736http://116.63.172.133:85/crm （蝶金）公海已分配--转换公海 不显示页签 （从列表操作转换公海）
            $admin_arr =  explode(',',$public_account['public_account_pool'][$_REQUEST['pool_id']]['administrators']);
            $user_arr = explode(',',$public_account['public_account_pool'][$_REQUEST['pool_id']]['userids']);

            if (!in_array($current_user->id,$admin_arr ) && in_array($current_user->id,$user_arr )) {
                $commonaccount = 'no';
            }
            $permit = $pool_profileobj->check_poolbtn_permit_poolid('transfercustomer',$_REQUEST['pool_id']);

            if(in_array($current_user->id,$admin_arr) && $permit != 'yes'){
                $commonaccount = 'no';//公海成员只显示选项“转移到公海”
            }
        }else{//普通客户
            $commonaccount = 'no';
        }

    }else{//批量转移公海
        $commonaccount = 'yes';
        if(!empty($record_str)){
            $query = "select 1 from ld_account where publicaccount >= 1 and accountid in ($record_str) and deleted = 0";
            //echo $query;echo '<br><br>';
            $result = $adb->pquery($query,array());
            $num_rows = $adb->num_rows($result);
            if($num_rows >= 1){ //全部是公海客户
                //批量 转换公海功能弹窗选项按最小权限显示(其中一条单据不是公海管理员，则按照公海成员的权限显示)
                $record_arr = explode(',',$record_str);
                foreach ($record_arr as $record) {
                    $focus->retrieve_entity_info($record,$currentModule);
                    $tmp_pool_id = $focus->column_fields['pool_id'];
					$tablename = $focus->table_name;
                    $tableindex = $focus->table_index;
					$tmpsql = "select publicaccount,pool_id from $tablename where $tableindex=?";
                    $tmpresult = $adb->pquery($tmpsql,array($record));
                    //是否公海字段未启用
                    if(!isset($focus->column_fields['publicaccount'])){
                        if($adb->num_rows($tmpresult)>0){
                            $focus->column_fields['publicaccount'] = $adb->query_result($tmpresult,0,'publicaccount');
                        }
                    }
					//公海池字段未启用
                    if(!isset($focus->column_fields['pool_id'])){
                        if($adb->num_rows($tmpresult)>0){
                            $tmp_pool_id = $adb->query_result($tmpresult,0,'pool_id');
                        }
                    }
                    $tmp_publicaccount = $focus->column_fields['publicaccount'];
                    if ($tmp_publicaccount >= 1) { //公海客户 //edit:can 20221109 【通用问题】客户模块，转公海功能在特定标签页下不受公海权限限制。请提供下修复的补丁包。
                        $admin_arr =  explode(',',$public_account['public_account_pool'][$tmp_pool_id]['administrators']);
                        $user_arr = explode(',',$public_account['public_account_pool'][$tmp_pool_id]['userids']);

                        if (!in_array($current_user->id,$admin_arr) && in_array($current_user->id,$user_arr)) {
                            $commonaccount = 'no';//公海成员只显示选项“转移到公海”
                            break;
                        }
                        $permit = $pool_profileobj->check_poolbtn_permit_poolid('transfercustomer',$tmp_pool_id);
                        if(in_array($current_user->id,$admin_arr) && $permit != 'yes'){
                            $commonaccount = 'no';//公海成员只显示选项“转移到公海”
                            break;
                        }


                    }else{//含有普通客户
//                    $commonaccount = 'no';
//                    break;
                    }

                }
            }else{//全部是普通客户，则只显示选项“转移到公海”
                $commonaccount = 'no';
            }
        }else{
            $commonaccount = 'no';
        }

    }


	//获取当前用户有权限看到的公海池
	$public_account_pool = [];
	if(!empty($public_account['public_account_pool'])){
		foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
			if(!empty($pool_info['administrators'])){
				$admins = explode(',',$pool_info['administrators']);
				$permit = $pool_profileobj->check_poolbtn_permit_poolid('turnhighseas',$pool_id);
				if(in_array($current_user->id,$admins) && $permit == 'yes'){
					$public_account_pool[$pool_id] = $pool_info['pool_name'];
				}
				/*
				//公海客户“公海已分配”页签：可选公海仅显示当前用户是“公海管理员”或“公海成员”的公海池
//				if(!empty($_REQUEST['publicaccounttype']) && $_REQUEST['publicaccounttype'] == 'PUBLICALLOCATE'){
					$userids = explode(',',$pool_info['userids']);
					if(in_array($current_user->id,$userids)){
						$public_account_pool[$pool_id] = $pool_info['pool_name'];
					}
//				}
				*/
                //XUQIU20241219-01 允许公海成员成员对公海客户做变更功能
                $allow_trasnfer_others = $pool_info['allow_trasnfer_others'];
                if($allow_trasnfer_others == 'yes'){
                    $userids = explode(',',$pool_info['userids']);
                    if(in_array($current_user->id,$userids)){
                        $public_account_pool[$pool_id] = $pool_info['pool_name'];
                    }
                }
			}
		}
	}

	//非批量操作时也过滤当前公海池
    if (isset($_REQUEST['popupobj_type']) && in_array($_REQUEST['popupobj_type'], array('listpage','detailviewpage'))) {
        unset($public_account_pool[$_REQUEST['pool_id']]);
    }

	//公海未分配、公海已分配 。 过滤当前公海池
	if(!empty($_REQUEST['publicaccounttype']) && in_array($_REQUEST['publicaccounttype'],array('NOALLOCATE','PUBLICALLOCATE')) && !empty($_REQUEST['pool_id'])){
		//公海客户“公海已分配”页签：如果当前用户不是“公海管理员”，只是“公海成员”，则不显示选项“转移出公海（转为普通客户）”
		if(!empty($_REQUEST['publicaccounttype']) && $_REQUEST['publicaccounttype'] == 'PUBLICALLOCATE'){
			$admins = explode(',',$public_account['public_account_pool'][$_REQUEST['pool_id']]['administrators']);
			if(sizeOf($admins) >= 1 && !in_array($current_user->id,$admins)){
				$commonaccount = 'no';
			}
		}
		unset($public_account_pool[$_REQUEST['pool_id']]);
	}

}
// 无可选公海，也不能转为普通客户返回提示
if(empty($public_account_pool) && $commonaccount == 'no'){
    ConvertTojsonString(-1,$arr,getFixedLabel('CurrentlyNoApplicableHighSeasOptionsForChanging'));
}
$smarty->assign('COMMONACCOUNT',$commonaccount);
$smarty->assign('RECORD_STRING',$record_str);
$smarty->assign('PUBLIC_ACCOUNT_POOL',$public_account_pool);
$smarty->assign('DATA',$data);
$_REQUEST['diony']='diony';
$content=$smarty->fetch("Accounts/MassTransferAccount.tpl");
$arr['title']=getFixedLabel("Transfer");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");
?>