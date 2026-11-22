<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$currentModule,$current_user,$default_charset;
$records = $_REQUEST['records'];
$correct = 0;
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//成功
$batchtype = getFixedLabel('EDIT');
if(!empty($records)){
	$_REQUEST['apiDeleteAttach'] = 'no';
	$records_arr = explode(',',$records);
	foreach($records_arr as $record){
		if(!empty($record)){
			$ids[] = $record;
		}
	}
    
	$totalrecords = sizeOf($ids);
	//获取批量处理数
	$deployarray=getSys_deploy(67);
	$btach_num =  $deployarray['deploy_value'];
	//$btach_num = 2;
	if(sizeof($ids)>$btach_num)
    {
        $ids=array_slice($ids,0,$btach_num);
    }
    
	$entityarray = getEntitynameInfo(getTabid($currentModule));
	$tabname = $entityarray['tablename'];//模块主表
	$moduleid = $entityarray['entityidfield'];//模块主表ID
	$tabfieldname = $entityarray['fieldname'];//模块链接字段
	$query = "select $moduleid as id,$tabfieldname as subject from $tabname where $moduleid in (".implode(',',$ids).")";
	$result = $adb->pquery($query);
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i<$num_rows; $i++){
			$id = $adb->query_result($result,$i,'id');
				
			$subArr[$id] = array(
				'subject' => $adb->query_result($result,$i,'subject')
			);
		}
	}
	$focus = CRMEntity::getInstance($currentModule);
	foreach($ids as $record){
		if(!empty($record)){
			$focus->retrieve_entity_info($record, $currentModule);
			$focus->mode = 'edit';
			$focus->id=$record;
			foreach($focus->column_fields as $fieldname => $val)
			{    	
				if(isset($_REQUEST[$fieldname]))
				{
					$focus->column_fields[$fieldname] = $_REQUEST[$fieldname];
				}

			}
			$focus->save($currentModule);
			$correct++;
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$currentModule.'" referencerecord="'.$record.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subArr[$record]['subject'].'</a>',$batchtype).'<br>';
		}
	}
}
$_REQUEST['diony']='diony';
$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'),$totalrecords,$correct,$totalrecords-$correct).'</div></div>';
$arr['title']=getFixedLabel('EDITAPPROVEORDER');
$arr['log'] = $submitlog."<div class='pop_prc_content'>".$edit_err.'</div>';//批量处理信息$edit_err;

ConvertTojsonString(1,$arr,"success");

?>