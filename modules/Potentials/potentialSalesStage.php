<?php
/**
 * 销售机会推进
 * @project PROT195 审批管理改进
 * @author Tujt 2015-04-09
 */
global $adb;
$setype = $_REQUEST['setype'];
if('opts' == $setype){//获取销售阶段
        crm_load_function_file('getPicklistValesForNORole','modules/PickList','PickListUtils');
	$picklist = getPicklistValesForNORole('sales_stage',$adb,"","");
	$sales_stage = '';
	if(!empty($_REQUEST['select_id'])){
		$select_id = $_REQUEST['select_id'];
		$select_id = rtrim($select_id,';');
		$ids = explode(';',$select_id);
		if(count($ids) == 1){
			global $adb;
			$query = 'select sales_stage from ld_potential where potentialid = ?';
			$result = $adb->pquery($query,array($select_id));
			$sales_stage = $adb->query_result($result,0,0);
		}
	}
	$data = array(
		'sales_stage' => $sales_stage,
		'picklist' => $picklist,
	);
    if(!empty($picklist)){
		$json = new Zend_Json();
		$jsonentity = $json->encode($data);
		echo $jsonentity;die;
	}
}else if('save' == $setype){//销售机会推进
	//选中记录ID
	$select_id = $_REQUEST['select_id'];
	//选中销售阶段类型
	$salesstage = $_REQUEST['salesstage'];
    crm_load_class_file('cls_SalesStage','modules/Potentials');
    $SalesStage = new cls_SalesStage();
    $finalresult = $SalesStage->save_salesStage_multi($select_id,$salesstage);
    //获取销售机会模块的当前页数
    if(isset($_SESSION['lvs']['Potentials']['viewname'])){
        $viewid = $_SESSION['lvs']['Potentials']['viewname'];
        $start = $_SESSION['lvs']['Potentials'][$viewid]['start'];
    }
    $error = $finalresult['noofrows']  - $finalresult['correct'];
    $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
    $submitlog = sprintf($submitlog,$finalresult['noofrows'],$finalresult['correct'],$error);
    $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
    if(!$start) $start = 1;
    $mode=$_REQUEST['mode'];
    if($mode=='detail')
    {
        global $reset_retrieve_entity_info;
        //$focus->retrieve_entity_info：不需要重新获取
        $reset_retrieve_entity_info='no';
        
        $focus=CRMEntity::getInstance('Potentials');
        $entity['log']['value'] ='';
        if($SalesStage->errorcolumn!="")
        {
            
            $fieldLabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$SalesStage->errorcolumn,'fieldlabel');
            $entity['log']['value'] = $fieldLabel.getFixedLabel('FieldCANNOTEMPTY');//批量处理信息
          
        }
          else
        {
            
             //$focus->retrieve_entity_info($select_id,"Potential");
              $sales_stage_fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'sales_stage','fieldname');
              $salesstagefieldvalue=$_REQUEST['salesstage'];
                
              $last_sales_stage_fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'lastsales_stage','fieldname');
                
              $last_sales_stagefieldvalue=$focus->column_fields[$last_sales_stage_fieldname];
            $entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$finalresult['edit_err']."</div>";
            $entity['log']['result']['datainfo'][$sales_stage_fieldname]=array('value'=>$salesstagefieldvalue);
            $entity['log']['result']['datainfo'][$last_sales_stage_fieldname]=array('value'=>$last_sales_stagefieldvalue);
        }
    }
   else
        $entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$finalresult['edit_err']."</div>";//批量处理信
    
    $entity['start']['value'] = $start;//当前页数
    $entity['errorcount']=$error;
    $entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
    $entity['title']['value'] = getFixedLabel('ADVANCE');// 确认

    require_once('include/Zend/Json.php');
    $json = new Zend_Json();
    $jsonentity = $json->encode($entity);
    echo $jsonentity;die;
    exit;

    //旧代码
//获取批量处理数
    $deployarray=getSys_deploy(67);
    $btach_num =  $deployarray['deploy_value'];
    //获取销售机会链接字段
    $entityarray = getEntitynameInfo(getTabid('Potentials'));
    $tabname = $entityarray['tablename'];
    $tabindex = $entityarray['entityidfield'];
    $tabfieldname = $entityarray['fieldname'];
    //成功提示
    $batchlog = getFixedLabel('TOPROMOTEFAILURE');
    //失败提示
    $batchsuccesslog = getFixedLabel('TOPROMOTETHESUCCESS');
    //操作类型
    $batchtype = getFixedLabel('ADVANCE');
       
	if('all' == $select_id){//全部

        $records=getSelectedRecords($_REQUEST,'Potentials',$select_id,$excludedRecords);
      
       
		$query = "SELECT potentialid as crmid,sales_stage,amount,probability,closingdate,$tabfieldname as subject 
				FROM ld_potential WHERE potentialid in (".implode(',',$records).")";
		$result = $adb->pquery($query,array());
        $noofrows=$adb->num_rows($result);
		for($i = 0; $i<$noofrows; $i++){
			$crmid = $adb->query_result($result,$i,'crmid');
			if(empty($crmid))continue;
			if($btach_num <= $i)break;
			$selsalesstage = "select $tabfieldname as subject from ld_potential where potentialid = ? limit 1";
			$resultsales = $adb->pquery($selsalesstage,array($crmid));
			$subject = $adb->query_result($result,0,'subject');
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Potentials" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject.'</a>',$batchtype).'<br>';
			$correct++;
		}
		resultExecPotential($result,$salesstage);
	}else{//选中ID
		$selectarr = explode(';',$select_id);
		$recordid = '';
		$noofrows = count($selectarr) - 1;
		foreach($selectarr as $key => $id){
			if(empty($id)) continue;
			if($btach_num <= $key)break;
			$query = "SELECT sales_stage,amount,probability,closingdate,$tabfieldname as subject 
				FROM ld_potential WHERE potentialid = ? LIMIT 1;";
			$result = $adb->pquery($query,array($id));
			UpdatePotentialSalesStage($result,$id,$salesstage);
			$recordid .= $id.',';
			$subject = $adb->query_result($result,0,'subject');
            $lastsales_stage = $adb->query_result($result,0,'sales_stage');//编辑前的销售阶段
           // $update = 'update ld_potential set sales_stage = "'.$salesstage.'",lastsales_stage="'.$lastsales_stage.'" where potentialid ="'.$id.'" ';
			//$adb->pquery($update,array());
			$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Potentials" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject.'</a>',$batchtype).'<br>';
			if(!empty($id)){
				$update = 'update ld_potential set sales_stage = "'.$salesstage.'",lastsales_stage="'.$lastsales_stage.'" where potentialid = ?  ';
				$adb->pquery($update,array($id));
			}
			$correct++;
		}

		/*if(!empty($recordid)){
			$recordid = trim($recordid,',');
			$update = 'update ld_potential set sales_stage = "'.$salesstage.'",lastsales_stage="'.$lastsales_stage.'" where potentialid in ('.$recordid.') ';
			$adb->pquery($update,array());
		}*/

	}
	//获取销售机会模块的当前页数
	if(isset($_SESSION['lvs']['Potentials']['viewname'])){
		$viewid = $_SESSION['lvs']['Potentials']['viewname'];
		$start = $_SESSION['lvs']['Potentials'][$viewid]['start'];
	}
	$error = $noofrows  - $correct;
	$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
	$submitlog = sprintf($submitlog,$noofrows,$correct,$error);
	$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
	$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";
	if(!$start) $start = 1;
	$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
	$entity['start']['value'] = $start;//当前页数
	$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
	$entity['title']['value'] = getFixedLabel('ADVANCE');// 确认

    require_once('include/Zend/Json.php');
	$json = new Zend_Json();
	$jsonentity = $json->encode($entity);
	echo $jsonentity;die;
}

/**
 * 因为会多次调用，所以单独提出来
 * @author Tujt 2015-04-08
 */
function resultExecPotential($result,$salesstage) {
    global $adb;
	$rows = $adb->num_rows($result);
	if($rows > 0){
		for($i=0;$i<$rows;++ $i){
			$crmid = $adb->query_result($result,$i,'crmid');
			if($crmid > 0){
				if($btach_num <= $i)break;
				UpdatePotentialSalesStage($result,$crmid,$salesstage,$i);
				$update = 'update ld_potential set sales_stage = "'.$salesstage.'" 
							where potentialid = '.$crmid.';';
				$adb->pquery($update,array());
			}
		}
	}
}
/**
 * 获取销售机会之前的销售阶段，然后存入销售阶段推进历史表中
 * @param Integer $id 销售机会ID
 * @author Tujt 2015-04-08
 */
function UpdatePotentialSalesStage($result,$id,$salesstage,$for_i = 0) {
    global $adb,$current_user;
	//获取销售机会阶段信息
	$time = time();
	$nowdate = date('Y-m-d',$time);
	$nowtime = date('Y-m-d H:i:s',$time);
	//获取记录原有销售阶段
	$old_salesstage = $adb->query_result($result,$for_i,'sales_stage');
	$amount = $adb->query_result($result,$for_i,'amount');
	$probability = $adb->query_result($result,$for_i,'probability');
	$closingdate = $adb->query_result($result,$for_i,'closingdate');
	if(empty($closingdate)) $closingdate = $nowdate;
	$sql = "insert into ld_potstagehistory values(?,?,?,?,?,?,?,?,?,?)";
	$params = array('', $id, $amount,decode_html($old_salesstage), $probability, 0, $adb->formatDate($closingdate, true), $adb->formatDate($nowtime, true),$salesstage,$current_user->id);
	$adb->pquery($sql, $params);
}
?>