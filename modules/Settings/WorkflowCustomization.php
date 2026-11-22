<?php
$smarty=new lingdangCRM_Smarty;
global $adb,$theme,$mod_strings,$app_strings;
$data = [];
$advft_criteria_groups = [];
$advft_criteria = [];
if(!empty($_REQUEST['workflow_id'])){
	$query = "select id,`name`,`status`,description,triggertime,repeatmode,approvalnode,createdtime,advft_criteria,advft_criteria_groups,tabid from ld_workflow where id = ? and deleted = 0 ";
	$result = $adb->pquery($query,array($_REQUEST['workflow_id']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$triggertime = $adb->query_result($result,0,'triggertime');
		$tabid = $adb->query_result($result,0,'tabid');
        $_REQUEST['tabid']=$tabid;
		$advft_criteria = $adb->query_result($result,0,'advft_criteria');
		$advft_criteria_groups = $adb->query_result($result,0,'advft_criteria_groups');
		$module=getTabModuleName($tabid);
		if($triggertime == 'Approval'){
			$approvalnode = explode(',',$adb->query_result($result,0,'approvalnode'));
			$approvalnode_array = array(
				'Submit' => 'no',	
				'Approved' => 'no',
				'Rejected' => 'no',
				'Dismissed' => 'no',
                'RetractApprove'=>'no'
			);
			foreach($approvalnode_array as $approvetype => $type){
				if(in_array($approvetype,$approvalnode)){
					$approvalnode_array[$approvetype] = 'yes';
				}
			}
		}
		$data = array(
			'name' => $adb->query_result($result,0,'name'),
			'status' => $adb->query_result($result,0,'status'),
			'description' => $adb->query_result($result,0,'description'),
			'triggertime' => $adb->query_result($result,0,'triggertime'),
			'repeatmode' => $adb->query_result($result,0,'repeatmode'),
			'approvalnode' => $adb->query_result($result,0,'approvalnode'),
			'modulename' => getTranstab($module),
		);
	}
	$query = "select id,action_title,action_type,status from ld_workflow_actions where workflow_id = ? and deleted = 0 order by sequence asc ";
	$result = $adb->pquery($query,array($_REQUEST['workflow_id']));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$id = $adb->query_result($result,$i,'id');
			$workflow_actions[$id] = array(
				'action_title' => $adb->query_result($result,$i,'action_title'),
				'action_type' => $adb->query_result($result,$i,'action_type'),
				'status' => $adb->query_result($result,$i,'status')
			);
		}
		$smarty->assign('WORKFLOW_ACTIONS',$workflow_actions);
	}
}else{
	$tabid = $_REQUEST['frommodule_tabid'];
    
    if($tabid>0)
	{
	       $_REQUEST['tabid']=$tabid;
    	   $module = getTabname($tabid);
           $modulename=getTranstab($module);
           
    }
	$data = array(
	 
		'status' =>'Active',
	 
	);
	
}
$arr['columns_block']=[];
 $smarty->assign("TabList",[]);
crm_load_class_file('CommonView',"modules/CustomView");

if(!empty($_REQUEST['workflow_id']))
{
    
   
    
   include(globalStatic::$root_directory.'modules/Settings/WorkflowAdvSearch.php');
   
    
}
else{
    global $current_user,$default_charset;
   
    $languageType= getLanguageType($current_user);
     $sql="SELECT DISTINCT ld_tab.tabid,name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
		inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid
		where  languagetype=? and trantable=?  and presence in(0,2) 
    		AND printtab=1 and name NOT IN ('CustomEcharts','SocialPromotion','ChannelCode','CustomTables','WechatSession') 
			OR name IN ('Singin')
		GROUP BY tabid  order by tabsequence ";
    $result=$adb->pquery($sql,array($languageType,'ld_tab'));
    $num_rows=$adb->num_rows($result);
    //$tab[]=array('tabid'=>-1,'tabname'=>getFixedLabel('ALL'));
    if($num_rows){
        $count=0;
        for($i=0;$i<$num_rows;$i++){
            $tmptabid=$adb->query_result($result,$i,'tabid');
            $tmpmodule=$adb->query_result($result,$i,'name');
    		if(vtlib_isModuleActive($tmpmodule)){
    			$tab[]=array(
    				'tabid'=>$tmptabid,
    				'tabname'=>getTranstab($tmpmodule)
    			);
    		}
            
        }
        if( $_REQUEST['frommodule_tabid']<0)
                $_REQUEST['tabid']=$adb->query_result($result,0,'tabid');
         include(globalStatic::$root_directory.'modules/Settings/WorkflowAdvSearch.php');
    }
    $smarty->assign("TabList",$tab);
}

$fLabels = CommonView::getComparatorLabel();
unset($fLabels['curuser']);
$fLabels['has_changed']=getFixedLabel('haschanged');	//有改变
$fLabels['has_changed_to'] =getFixedLabel('haschangedto');	//有改变-变更后
$fLabels['has_changed_from']= getFixedLabel('haschangedfrom');	//有改变-变更前
$arr['flabels']=$fLabels;
$arr['btn_addnewcombinationtext']=getFixedLabel('NEWCOMBINATION');//高级查询”新组合“
$arr['btn_addnewcondtiontext']=getFixedLabel('NEWCONDITIONS');//按钮”新条件"
$arr['arr_recovery_modules'] = $arr_recovery_modules;	//回收模块
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
$arr['foption']=$advfilterhtml;
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($module);
$arr['advanceFields'] = $controller->getAdvanceFields();
if(!empty($advfilterlist))
    $arr['criteria_groups']=$advfilterlist;	
else
    $arr['criteria_groups']="";
if($_REQUEST['mode'] == 'create' && $_REQUEST['jdyisv'] == 'yes'){
	$query = "select 1 from ld_workflow_api where api_name = 'jdyisv' and dbname != '' ";
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows < 1){
		$_REQUEST['diony']='yes';
		ConvertTojsonString(-1,array('msg'=>getFixedLabel('Interfaceparameter')),"error");
	}
}
$smarty->assign("tabid",$tabid);
$smarty->assign("frommodule_tabid",$_REQUEST['frommodule_tabid']);
$smarty->assign('MODULENAME',$modulename);
$smarty->assign('JDYISV',$_REQUEST['jdyisv']);
$smarty->assign('MODE',$_REQUEST['mode']);
$smarty->assign('APPROVENODE_ARRAY',$approvalnode_array);
 
$smarty->assign('WORKFLOW_ID',$_REQUEST['workflow_id']);
$smarty->assign('DATA',$data);
$smarty->assign('FROMMODULE_TABLE',$tabid);

crm_load_class_file('cls_ApproveCache','modules/Approve');
$approvemodules = cls_ApproveCache::getAllModuleInfo();
$haveApproval = 'no';
if(array_key_exists($module,$approvemodules)){
	$haveApproval = 'yes';
}

$profile_focus = CRMEntity::getProfileClass();
$haveAdvance = $profile_focus->isModuleExistsProfile($module,'Advance');
$haveAllocate = $profile_focus->isModuleExistsProfile($module,'Allocate');

$smarty->assign("haveApproval",$haveApproval);// 审批
$smarty->assign("haveAdvance",$haveAdvance);// 推进
$smarty->assign("haveAllocate",$haveAllocate);// 分配

$_REQUEST['diony']='yes';
$arr['title'] = getFixedLabel('LBL_WORKFLOWCUSTOMIZATION_SET');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomization.tpl');
ConvertTojsonString(1,$arr,"success");

?>

