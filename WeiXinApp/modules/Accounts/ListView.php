<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb,$current_user;
$mobj = cls_Instance::get_moduleAction_Instance('Accounts','ListView');
//公海客户页签显示
$noalloacteshow = 'yes';
$publicalloacteshow = 'yes';
if($_REQUEST['publicaccounts']=='yes'){
    $public_buttons = array();
    crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
    $cls_PublicAccounts = new cls_PublicAccounts('Accounts');
    $public_account = $cls_PublicAccounts->getPublicAccountConfig();
    if($public_account['status'] == 'yes' && !empty($public_account['public_account_pool'])){
        $tmppool_id = array_keys($public_account['public_account_pool'])[0];
        foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
            if(!empty($_REQUEST['pool_id'])){
                if($pool_id == $_REQUEST['pool_id']){
                    $tmppool_id =  $pool_id;
					break;
                }
            }
            else if($pool_info['default_pool'] == 'yes'){
                $tmppool_id =  $pool_id;
                break;
            }
        }
        if(!empty($tmppool_id)){
            $administrators_arr = explode(',',$public_account['public_account_pool'][$tmppool_id]['administrators']);
            $userids_arr = explode(',',$public_account['public_account_pool'][$tmppool_id]['userids']);
            if($public_account['public_account_pool'][$tmppool_id]['allowget'] == 'yes' && !in_array($current_user->id,$administrators_arr)){
                //zkt 20240116 XUQIU1002449 （PC+移动端）当成员为公海成员，应能可以看到公海未分配客户，没有领取按钮，仅跟进；只能由公司管理员或者助理分配
                if( $public_account['public_account_pool'][$tmppool_id]['poolmember_show_noallocate'] != 'yes'){
                    $noalloacteshow = 'no';
                    if($_REQUEST['filter']['accounttype'] =='NOALLOCATE'){
                        $_REQUEST['filter']['accounttype'] = 'PUBLICALLOCATE';
                    }
                }
            }
        }
    }
}
//AJAX:公海类型切换
if(!empty($_REQUEST['switch_accounttype'])){
    $_REQUEST['pagepublicaccounttype'] = $_REQUEST['switch_accounttype'];
    $customview_html = $mobj->init_custom();
    $output = json_encode($customview_html);
    echo $output;
    exit;
}
// @edit:dong @date:2020/12/08 @reason: 数据分类保存为自定义链链接模块 访问列表 公海
if($_REQUEST['filter']['viewname'] !='' && $_REQUEST['filter']['accounttype'] ==''){
    $cvid =  $_REQUEST['filter']['viewname'];
    $sql = 'select customcategory from ld_customview where cvid=?';
    $result = $adb->pquery($sql,array($cvid));
    $_REQUEST['filter']['accounttype'] =$adb->query_result($result,0,0);
}
$details = $mobj->get_listdetail(null,null);
//	0026601: （微信端）客户测试模块:pc端设置个人用户没有客户的新增权限，微信端个人用户登录后进入客户列表，还是显示了新增按钮
if(isPermitted($currentModule,'Create','') == 'yes'){
    if(strpos($mobj->relatedModuleActions,'add')!==false ||empty($mobj->relatedModuleActions)){
        /*$buttontype = getAccount_Set('buttontype');//yyx 2015-4-21 获取公海参数值
        $status = getAccount_Set('status');
        if($status!='1'&&empty($_REQUEST['related_id'])) {
            $list_buttons = explode(',',$buttontype);
            $list_buttons = array_map('intval',$list_buttons);
            //非公海用户只有新增普通客户的权限
            if(!cls_StaticCommonFun::isPublicAccountUser()) $list_buttons= array(1);        
        }else{
            $list_buttons= array(1);
        }*/
		$buttontype = getAccount_Set('buttontype');//yyx 2015-4-21 获取公海参数值
         crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
        $cls_PublicAccounts = new cls_PublicAccounts('Accounts');
        $data = $cls_PublicAccounts->getPublicAccount();
        $create_buttons='no';
        //edit:can 20210409 45411: （kfbcrm，企业微信移动端）客户问题（戚涛），客户模块不启用公海，客户没有显示【新建】操作按钮（需要补丁）
        if($data['status']=='yes')
        {
            if($data['is_commonaccount_create']=='yes')
		     $list_buttons= array(1);
        }
       else
            $list_buttons= array(1);
    }else{
        $list_buttons = array();
    }
    
}else{
    $list_buttons = array();
}

//gyq_20
$camcard = -5;
if(!empty($list_buttons)) {
    require_once(globalStatic::$root_directory . 'expansion/camcard/cls_camcard.php');
    $camobj = new cls_camcard();
    $camcard = $camobj->judgeForCreate( $currentModule);
    if($camcard > 0){
        $list_buttons[] = 4;
    }
}
//客户查重//editor:gyq_80 reason:微信客户查重改进 2018/9/6 18:10
if (isPermitted($currentModule,'accountdatadup')=='yes'){
    $list_buttons[] = 'Datadupcheck';
}

//0033435: 公海客户这个新增按钮如果根据选定的页签控制是不是更容易理解。
if($_REQUEST['publicaccounts']=='yes'){
    $public_buttons = array();
	crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
	$cls_PublicAccounts = new cls_PublicAccounts('Accounts');
	$public_account = $cls_PublicAccounts->getPublicAccountConfig();
	if($public_account['status'] == 'yes' && !empty($public_account['public_account_pool'])){
		foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
			if(!empty($_REQUEST['pool_id'])){
				if($pool_id != $_REQUEST['pool_id']){
					continue;
				}
			}
			$administrators_arr = explode(',',$public_account['public_account_pool'][$pool_id]['administrators']);
			$userids_arr = explode(',',$public_account['public_account_pool'][$pool_id]['userids']);
			if($public_account['administrator'] == 'yes' || in_array($current_user->id,$administrators_arr) || in_array($current_user->id,$userids_arr)){
				$buttontype_array = empty($public_account['public_account_pool'][$pool_id]['create_buttons'])?[]:explode(',',$public_account['public_account_pool'][$pool_id]['create_buttons']);
				if(!empty($buttontype_array)){
					foreach($buttontype_array as $btntype){
						//chj 2021/6/29 46595: （http://jiangxikerui.gnway.vip:8000/CRM [^]）客户问题（李发林），客户档案，“景德镇”公海池公海已分配客户上限设置的是10000条客户，手机端创建时提示“公海客户已上限”
						if($btntype == 'NOALLOCATE' && $_REQUEST['filter']['accounttype']=='NOALLOCATE'){	//公海未分配
							$public_buttons=array(2);
						}else if($btntype == 'PUBLICALLOCATE' && $_REQUEST['filter']['accounttype']=='PUBLICALLOCATE'){	//公海已分配
							//chj 2021/3/10 44818: （kfbcrm，企业微信移动端）设置公海池参数“公海成员客户序时簿“新建”功能下拉选项为“公海未分配””，移动端公海客户模块“公海已分配”页签应该不显示【新建】按钮
							$public_buttons=array(3);
						}
					}
				}

			}
			break;
		}
	}
    //if($_REQUEST['accounttype']=='PUBLICALLOCATE'&&in_array(3,$list_buttons)) $public_buttons=array(3);
    //if($_REQUEST['accounttype']=='NOALLOCATE'&&in_array(2,$list_buttons)) $public_buttons=array(2);
    $list_buttons = $public_buttons;
}
//未分配1 已分配2
$details['list2']=array(
    'viewname'=>$_REQUEST['viewid'],
    //'moduletitle'=>getTranstab('Accounts'),
    'publicstatus'=>$status,
    'camcard'=>$camcard,
    'noalloacteshow'=>$noalloacteshow,
    'publicalloacteshow'=>$publicalloacteshow,
    'create_html'=>$list_buttons
 );

ConvertTojsonString(1,$details,'success');




?>
