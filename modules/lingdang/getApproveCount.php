<?php
global $currentModule;
//chj 2021/6/21 46471: （https://81mis.com/kfbcrm [^]）客户问题（陈修宏），审批中心->待处理->开始处理，列表界面，处理完成后，右上角消息提醒数量没有立即更新（需要补丁）

$tabtype = isset($_REQUEST['tabtype'])?$_REQUEST['tabtype']:0;

//审批数量
$approve = new Approve();
$approvenum = $approve->getApproveCount($tabtype);



/**
*edit:diony
*date:2021-03-05
*reason:审批
**/
crm_load_class_file('cls_Approve_countListView','modules/Approve');
$approve_obj = new cls_Approve_countListView($tabtype);
$approveinfo = $approve_obj->getapprovelist();
if(!empty($approveinfo)){
	foreach($approveinfo as $key => $info_arr){
		$approveinfo[$key]['modulelabel'] = getTranstab($info_arr['module']);
	}
}

$_REQUEST['diony']='diony';
$arr['approvenum']=$approvenum;
$arr['arpproveinfo']=json_encode($approveinfo);
$arr['billtype'] = getFixedLabel('BillType');
$arr['billnum'] = getFixedLabel('BILLNUM');

ConvertTojsonString(1,$arr,"success");
?>