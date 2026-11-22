<?php
/**
* edit: chj
* reason: 公海参数设置
* date: 2020/11/27
**/

global $adb,$theme;
global $current_user,$list_max_entries_per_page_new;
$smarty=new lingdangCRM_Smarty();
$normal_id= 1;
if(!empty($_REQUEST['normal_id'])){
	$normal_id = $_REQUEST['normal_id'];
}
$query = "select 1 from ld_account_set_rule_normal where normal_id = ? ORDER BY sequence";
$result=$adb->pquery($query,array($normal_id));
$normal_rows = $adb->num_rows($result);
if(empty($normal_rows)){
	$normal_id = 1;
}
if(!empty($_REQUEST['normal_rule_json'])){
	$query = "select labelbol,singlelabelbol,tabname from ld_account_set_rule_normal where normal_id = ? ORDER BY sequence";
	$result=$adb->pquery($query,array($normal_id));
	for($i=0;$i<$adb->num_rows($result);$i++)
	{
		$tablename = $adb->query_result($result,$i,'tabname');
		$labelbol = $adb->query_result($result,$i,'labelbol');
		$singlelabelbol = $adb->query_result($result,$i,'singlelabelbol');
		$recyclelabelbols = explode('/',$labelbol);
		$singlelablebols = explode('/',$singlelabelbol);
		$label[$tablename] = array(
			'recyclelabelbol1' => $recyclelabelbols[0],
			'recyclelabelbol2' => $recyclelabelbols[1],
			'singlelabelbol1' => $singlelablebols[0],
			'singlelabelbol2' => $singlelablebols[1]
		);
	}
	$normal_rule_json = json_decode($_REQUEST['normal_rule_json']);
	foreach($normal_rule_json as $rule_str){
		$rule_arrs = explode('_',$rule_str);
		$modulename = $rule_arrs[4];
		if(!in_array($modulename,$arr_recovery_modules)){
			 $arr_recovery_modules[]=$modulename;	//参与回收的模块
		}
		$completecondition=$rule_arrs[3];
		$seqno=sizeof($arr_complete_condition)+1;
		$day = $rule_arrs[2];
		$arr_complete_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$rule_arrs[0]
		,'recyclelabelbol1'=>$label[$modulename]['recyclelabelbol1'],'recyclelabelbol2'=>$label[$modulename]['recyclelabelbol2']
		,'singlelabelbol1'=>$label[$modulename]['singlelabelbol1'],'singlelabelbol2'=>$label[$modulename]['singlelabelbol2']
		,'iscycle'=>$rule_arrs[1]);

	}
}else{
	$query = "select normal_id,tabname,`condition`,labelbol,sequence,days,`status`,columnname,otherwhere,iscycle,singlelabelbol from ld_account_set_rule_normal where normal_id = ? ORDER BY sequence";
	$result=$adb->pquery($query,array($normal_id));
	for($i=0;$i<$adb->num_rows($result);$i++)
	{
		$modulename=$adb->query_result($result,$i,'tabname');
		$day=$adb->query_result($result,$i,'days');
		$type=$adb->query_result($result,$i,'type');
		$recyclelabelbols=explode("/",$adb->query_result($result,$i,'labelbol'));
		$singlelablebols=explode("/",$adb->query_result($result,$i,'singlelabelbol'));
		$status=$adb->query_result($result,$i,'status');
		$iscycle=$adb->query_result($result,$i,'iscycle');
		$condition=$adb->query_result($result,$i,'condition');
		$completecondition=$condition;
		$seqno=sizeof($arr_complete_condition)+1;
		if(empty($normal_rows)){
			$day = '';
			$status = 'inactive';
			$iscycle = 'no';
		}
		if(empty($day)){
			switch($modulename){
				case 'ContactRecords':
				   $day = 10;
				break;
				case 'Singin':
					$day = 20;	
				break;
				case 'Potentials':
					$day = 30;	
				break;
				case 'SalesOrder':
					$day = 90;	
				break;
				case 'CashBill':
					$day = 120;	
				break;
				case 'OutboundOrder':
					$day = 120;	
				break;
				case 'ServiceContracts':
					$day = 120;	
				break;
			}
		}

		if(!in_array($modulename,$arr_recovery_modules)){
			 $arr_recovery_modules[]=$modulename;	//参与回收的模块
		}
	   
		$arr_complete_condition[]=array('seqno'=>$seqno, 'tabname'=>$modulename,'days'=>$day,'status'=>$status
			,'recyclelabelbol1'=>$recyclelabelbols[0],'recyclelabelbol2'=>$recyclelabelbols[1]
			,'singlelabelbol1'=>$singlelablebols[0],'singlelabelbol2'=>$singlelablebols[1]
			,'iscycle'=>$iscycle);
	}
}
$smarty->assign("COMPLETECONDITION",$completecondition);
$smarty->assign("ARRCOMPLETECONDITION",$arr_complete_condition);
$smarty->assign('NORMALID',$_REQUEST['normal_id']);
$_REQUEST['diony']='diony';
$content=$smarty->fetch("Accounts/setNormalAccountRule.tpl");
//BUG0054926 wyt 公海参数设置，启用公海回收规则，点击“回收条件”，弹出层标签显示“回收方案”，点击“回收规则”，弹出层标签显示“回收条件”。预期结果：标签应该对应显示，避免造成歧义$arr['title']=getFixedLabel("recyclingrules");
$arr['title']=getFixedLabel("recyclingrules");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
$arr['arr_recovery_modules']=$arr_recovery_modules;
ConvertTojsonString(1,$arr,"success");
?>