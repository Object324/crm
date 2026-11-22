<?php
global $currentModule,$current_user,$adb;
SqlSearchFilter($_REQUEST);
$modulename = $_REQUEST['modulename'];
if($modulename=='ServiceCharge')
$modulename='Accounts';
$record = $_REQUEST['recordid'];
$currentModule = $modulename;
$tabid = getTabid($currentModule);
$setype = $_REQUEST['setype'];
switch($setype){
    case 'ModComments':
        $commentmode = $_REQUEST['commentmode'];
        $modechange = $_REQUEST['modechange'];


		if(!vtlib_isModuleActive('ModComments')){ echo '';exit();}//判断模块是否开启
		if(isPermitted('ModComments','index') == 'no'){ echo '';exit();}//判断是否有评论模块权限
        $customlink_params = Array('MODULE'=>$currentModule, 'RECORD'=>$record, 'ACTION'=>'DetailView');
		//require './vtlib/lingdang/Link.php';
	//	$custom_links = lingdang_Link::getAllByType($tabid, Array('DETAILVIEWBASIC','DETAILVIEW','DETAILVIEWWIDGET'), $customlink_params);

        $focus=CRMEntity::getInstance('ModComments');
        $smarty = new lingdangCRM_Smarty;
	//	$smarty->assign('CUSTOM_LINKS',$custom_links);
		$smarty->assign('ID',$record);
        $smarty->assign('UIKEY',$record);


        $system_358 = getSys_deploy(358);
        $modcommentdisplayright = 'yes';
        if($system_358['deploy_value'] == 1){
            $modcommentdisplayright = 'no';
        }

        if(!isset($modechange)){
            $modechange='no';
        }

        if($modechange == 'yes'&&isset($commentmode) && $commentmode!='') {
            setUsersettingByLabel($modulename, $current_user->id, 'CommentMode', $commentmode);
        }
        if($modechange == 'yes'&&isset($commentmode) && $commentmode!='' && $commentmode=='advanced'){

            //wym 240222 XUQIU20240204-01 评论：默认除@负责人外，创建人也应该@

            $copyusername=$focus->getModCommentsRemindUser($modulename,$record);

            $smarty->assign('copyuser',$copyusername);
        }
        $smarty->assign("MODCOMMENTDISPLAYRIGHT",$modcommentdisplayright);
        $smarty->assign('MODECHANGE', $modechange);
        $smarty->assign('COMMENTMODE',$commentmode);
        $html=$focus->getDetailBlocks($record,'All', $commentmode);
        $smarty->assign('MODCOMMENTOBJ',$html);
        if($modechange == 'yes' &&isset($commentmode) && $commentmode!='') {
            $commentContent = $smarty->fetch("modules/ModComments/modCommentList.tpl");
            ConvertTojsonString(1,array('content' => $commentContent),'success');
        }
        else{
            $smarty->display("modules/ModComments/modCommentList.tpl");
        }
        exit();
        break;
    case 'Recordsofoperation'://公海操作日志
        $focus = CRMEntity::getInstance('Accounts');
		$publicaccount_log = $focus->getPublicAccountLog($record);
		echo $publicaccount_log;exit();
        break;
	case 'Approvelog':
        crm_load_class_file("ApproveCommon","modules/Approve");
        $approvecommonobj = ApproveCommon::getInstance($modulename);
        
		//判断当前模块是否开启审批，未开启的话就不显示审批历史
		$approvemod = $approvecommonobj->getApproveModuleInfo();
		if(!isset($approvemod[$currentModule])){
			echo '';die;
		}
        $sql = "select approveid from ld_approvelog where crmid = ? order by id desc limit 1";
        $result = $adb->pquery($sql,array($record));
        if($adb->num_rows($result)>0){
            $approveid = $adb->query_result($result,0,'approveid');
            $approveobj = $approvecommonobj->getApproveobjByApproveid($approveid);
        }else{
            echo '';die;
        }
        
        $approve_set = array('showcurrentapprove','hideautopassstep');
        foreach($approve_set as $tmp_label){
            if(isset($_REQUEST[$tmp_label]) && $_REQUEST[$tmp_label]!=''){
                $sql = 'select * from ld_module_setting_byuser where modulename = ? and userid = ? and label = ?';
                $result = $adb->pquery($sql,array($modulename,$current_user->id,$tmp_label));
                if($adb->num_rows($result)>0){
                    $id = $adb->query_result($result,0,'id');
                    $query = 'update ld_module_setting_byuser set content=? where id = ? ';
                    $adb->pquery($query,array($_REQUEST[$tmp_label],$id));
                }else{
                    $query = 'insert into ld_module_setting_byuser(modulename,userid,label,type,content) values(?,?,?,?,?);';
                    $adb->pquery($query,array($modulename,$current_user->id,$tmp_label,'approvelog',$_REQUEST[$tmp_label]));
                }
                unsetCache('cache_approvelogset');
            }
        }
        //审批日志，保存展开收起状态
        if(isset($_REQUEST['showtype']) || isset($_REQUEST['showvalue'])){
            setUsersettingByLabel($modulename, $current_user->id, $_REQUEST['showtype'], $_REQUEST['showvalue']);
            ConvertTojsonString(1,array(),'success');
        }
        //审批日志，获取展开收起状态
        $pre_hidden_showtype = getUsersettingByLabel($modulename, $current_user->id, 'pre_hidden')=='show'?'no':'yes';
        $next_hidden_showtype = getUsersettingByLabel($modulename, $current_user->id, 'next_hidden')=='show'?'no':'yes';

        $ApprovelogSetInfo = $approveobj->getApprovelogSet($record);
        $WholeApproveLog = $approveobj->getWholeApproveLog($record,$ApprovelogSetInfo);
        //dump($approvelog);
		if(!empty($WholeApproveLog)){
			$smarty = new lingdangCRM_Smarty;
			$smarty->assign('WholeApproveLog',$WholeApproveLog);
            $smarty->assign('APPROVE',$WholeApproveLog);
            $smarty->assign('RECORD',$record);
            $smarty->assign('MODULENAME',$modulename);
            $smarty->assign('APPROVELOGSETINFO',$ApprovelogSetInfo);
            $smarty->assign("iskehu001",isKehu001ServerPc());
            //刷新审批日志时，获取页面展开收起的状态
            if(isset($_REQUEST['pre_hidden_btn']) && $_REQUEST['pre_hidden_btn'] == 'no'){
                $smarty->assign("pre_hidden_btn",$_REQUEST['pre_hidden_btn']);
            }else if(!isset($_REQUEST['pre_hidden_btn'])){
                $smarty->assign("pre_hidden_btn",$pre_hidden_showtype);
            }else{
                $smarty->assign("pre_hidden_btn",'yes');
            }
            if(isset($_REQUEST['next_hidden_btn']) && $_REQUEST['next_hidden_btn'] == 'no'){
                $smarty->assign("next_hidden_btn",$_REQUEST['next_hidden_btn']);
            }else if(!isset($_REQUEST['next_hidden_btn'])){
                $smarty->assign("next_hidden_btn",$next_hidden_showtype);
            }else{
                $smarty->assign("next_hidden_btn",'yes');
            }
            
			/*
			*edit:chj
			*date:2020-07-13
			*reason:审批意见增加手写签名功能:判断授权文件中的手写全名权限
			*/
			global $global_regop;
			if(!isset($global_regop))
				$global_regop=RegOp::getInstance();
			$smarty->assign('AUTOGRAPH',$global_regop->gethandleWriteSign_interface());
            
			$smarty->display("Approve/ApproveLogEntriesNew.tpl");exit();
		}else{
			echo '';exit();
		}
	    break;
}
exit();
?>