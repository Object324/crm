<?php
global $current_user,$default_charset;
global $current_user;
$languageType= getLanguageType($current_user);
//zkt 20240906 BUG20240905-46 工作流找不到附件管理
 $sql="select DISTINCT ld_tab.tabid,name ,tablabel,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab
inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.relateid                  
INNER JOIN ld_field on ld_field.tabid = ld_tab.tabid and columnname='smownerid'
 where  languagetype=? and trantable=?  and ld_tab.presence in(0,2) 
 and name NOT IN ('CustomEcharts','SocialPromotion','ChannelCode','CustomTables','WechatSession') 
OR name IN ('Singin') GROUP BY tabid order by tabsequence ";
$result=$adb->pquery($sql,array($languageType,'ld_tab'));
$num_rows=$adb->num_rows($result);
$tab[]=array('tabid'=>-1,'tabname'=>getFixedLabel('ALL'));
if($num_rows){
    $count=0;
    for($i=0;$i<$num_rows;$i++){
        $tabid=$adb->query_result($result,$i,'tabid');
        $module=$adb->query_result($result,$i,'name');
		if(vtlib_isModuleActive($module)){
			$tab[]=array(
				'tabid'=>$tabid,
				'tabname'=>getTranstab($module)
			);
		}
        
    }
}
$smarty=new lingdangCRM_Smarty;
$smarty->assign('TAB',$tab);
if(!empty($_REQUEST['mode'])){
	if($_REQUEST['mode'] == 'delete'){
		$query = 'update ld_workflow set deleted = 1 where id = ?';
		$adb->pquery($query,array($_REQUEST['workflow_id']));
	}else if($_REQUEST['mode'] == 'status'){
		$status = $_REQUEST['status'];
		$query = 'update ld_workflow set status = ? where id = ?';
		if($status == 'Active'){
			$adb->pquery($query,array('Inactive',$_REQUEST['workflow_id']));
		}else{
			$adb->pquery($query,array('Active',$_REQUEST['workflow_id']));
		}
	}
}
//云星辰账套  $jdyisv = 'yes';
$jdyisv = 'no';
/*if(strpos($_SERVER['HTTP_HOST'].$_SERVER['PHP_SELF'],'81mis.com/kh') !== false){
	$jdyisv = 'yes'; 
}*/
$smarty->assign('JDYISV',$jdyisv);
//$limit = 4;
//$page = $_REQUEST['page'];
//$page = empty($page)?1:$page;
$sel_tabid = $tab[0]['tabid'];
if(!empty($_REQUEST['tabid'])){
	$sel_tabid = $_REQUEST['tabid'];
}
if ($sel_tabid == 9) {
    $sel_tabid = 16;
}
$query = "select id,`name`,`status`,description,triggertime,repeatmode,approvalnode,createdtime,tabid from ld_workflow where deleted = 0  and triggertime <> 'ButtonsCustomization'";
if($sel_tabid > 0 ){
	$query .= " and tabid = $sel_tabid ";
}
$query .= "order by id asc";
$result = $adb->pquery($query,array());
$total_nums = $adb->num_rows($result);
//$total_pages = ceil($total_nums/$limit);
//if($total_pages<=$page){
//	$page = $total_pages;
//}
//$page_start = ($page-1)*$limit;
//$query .= " limit $page_start,$limit ";

$result = $adb->pquery($query,array());

$num_rows = $adb->num_rows($result);
$data = [];
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$id = $adb->query_result($result,$i,'id');
		$tabid = $adb->query_result($result,$i,'tabid');
		$repeatmode = $adb->query_result($result,$i,'repeatmode');
		$triggertime = $adb->query_result($result,$i,'triggertime');
		if($triggertime == 'Creation' || $triggertime == 'Approval'){
			$repeatmode = ''; 
		}
		$module=getTabModuleName($tabid);
        $triggertime_label = '';
		switch ($triggertime){
            case 'Creation':
                $triggertime_label = getFixedLabel('NEW');
                break;
            case 'Updated':
                $triggertime_label = getFixedLabel('UpdatedIncludesCreation');
                break;
            case 'Approval':
                $triggertime_label = getFixedLabel('APPROVAL');
                break;
            case 'Advanced':
                $triggertime_label = getFixedLabel('ADVANCE');
                break;
            case 'Allocated':
                $triggertime_label = getFixedLabel('ALLOCATE');
                break;
            case 'Shared':
                $triggertime_label = getFixedLabel('SHARE');
                break;
            default:
                $triggertime_label = getFixedLabel('DELETE');
                break;
        }
		$data[$id] = array(
			'name' => $adb->query_result($result,$i,'name'),
			'status' => $adb->query_result($result,$i,'status'),
			'description' => $adb->query_result($result,$i,'description'),
			'triggertime' => $triggertime,
            'triggertime_label' => $triggertime_label,
			'repeatmode' => $repeatmode,
			'approvalnode' => $adb->query_result($result,$i,'approvalnode'),
			'modulename' => getTranstab($module),
		);
	}
}
//$prevpage = 'no';
//$nextpage = 'no';
//if($page == 1 && $total_pages > $page){
//	$nextpage = 'yes';
//}
//echo $page;echo '<br><br>';
//if($page > 1){
//	if($page < $total_pages){
//		$prevpage = 'yes';
//		$nextpage = 'yes';
//	}
//	if($page == $total_pages){
//		$prevpage = 'yes';
//	}
//}
//$smarty->assign('PREVPAGE',$prevpage);
//$smarty->assign('NEXTPAGE',$nextpage);
//$smarty->assign('total_nums',$total_nums);
//$smarty->assign('total_pages',$total_pages);
//$smarty->assign('PAGE',$page);
$smarty->assign('DATA',$data);
$smarty->assign('DATALENGTH',sizeOf($data));
$_REQUEST['diony']='yes';

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//工作流帮助
$labels = array('WorkflowCustomizationList');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
$smarty->assign("HelpHtml", $helpHtmlArr);

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
	$arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationEntries.tpl');
    ConvertTojsonString(1,$arr,"success");  
}
else
{
    $arr['content']= $smarty->fetch('WorkflowCustomization/WorkflowCustomizationList.tpl');
    ConvertTojsonString(1,$arr,"success");
}
?>