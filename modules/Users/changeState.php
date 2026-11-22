<?php
global $adb,$current_user;

if(isset($_REQUEST['save']) && $_REQUEST['save']!=''){
    $save=$_REQUEST['save'];
}
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!=''){
    $fld_module=$_REQUEST['fld_module'];
}

if(isset($_REQUEST['select_id']) && $_REQUEST['select_id']!='')
$select_id=$_REQUEST['select_id'];

if(isset($_REQUEST['statusname']) && $_REQUEST['statusname']!='')
$statusname=$_REQUEST['statusname'];

if(isset($_REQUEST['mode']) && $_REQUEST['mode']!='')
$mode=$_REQUEST['mode'];

if(isset($_REQUEST['idstring']) && $_REQUEST['idstring']!='')
	$select_id=$_REQUEST['idstring'];
$smarty=new lingdangCRM_Smarty;
if($save=='false'){
    $statusname=getstatusname($fld_module);
    if(empty($statusname)){
        ConvertTojsonString(-1,[],"no");
        exit();
    }
    else{
        echo "###SUCCESS###";
        $smarty->assign('STATUSNAMES',$statusname); 
        $smarty->assign('RECORD',$record);
        $smarty->assign('BLOCK',$fld_module);
        
        //$smarty->display('changeState.tpl');
        
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $title = '';
        if($fld_module=='SalesOrder')
        {
            $title = getFixedLabel('UPDATESTATE');
            $smarty->assign('FIXEDLABEL',$title);
        }
        else if($fld_module=='ProjectTask')
        {
            $title = getFixedLabel('UPDATEPROJECTASKSTATUS');
            $smarty->assign('FIXEDLABEL',$title);
        }
        else if($fld_module=='ServiceContracts')
        {
             $fieldobj=Field::getInstance($fld_module,$adb);
             $field=$fieldobj->getFieldInfoobjBykey('columnname','contract_status');
             $title = getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
             $smarty->assign('FIXEDLABEL',$title);
        }
        else if($fld_module=='Invoice')
        {
            $fieldobj=Field::getInstance($fld_module,$adb);
            $field=$fieldobj->getFieldInfoobjBykey('columnname','invoicestatus');
            $title = getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
            $smarty->assign('FIXEDLABEL',$title);
        }
        else if($fld_module=='PurchaseInvoice')
        {
            $fieldobj=Field::getInstance($fld_module,$adb);
            $field=$fieldobj->getFieldInfoobjBykey('columnname','purchaseinvoicestatus');
            $title = getVarFixedLabel('CHANGECREATED',$field->getfieldLabel());
            $smarty->assign('FIXEDLABEL',$title);
        }
        else
        {
            $title = getFixedLabel('UPDATEPURCHASEORDERSTATUS');
            $smarty->assign('FIXEDLABEL',$title);
        }
        $arr['title'] = $title;
        $str=$smarty->fetch("changeState.tpl");
        $arr['content']=$str;
        ConvertTojsonString(1,$arr,"success");
        exit();
    }
}else{
    chagestatus($mode,$fld_module,$statusname,$select_id);
    exit();
}

function getstatusname($fld_module){
    $arr_tranfer = array('SalesOrder'=>'sostatus','ServiceContracts'=>'contract_status',
        'PurchaseOrder'=>'postatus','PurchaseInvoice'=>'purchaseinvoicestatus',
        'Invoice'=>'invoicestatus','ProjectTask'=>'projecttaskstatus');
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues($arr_tranfer[$fld_module],'ld_field');
    $statusname=array();
    foreach($result_pick as $value){
        $statusname[]=array('statusname'=>$value);
    }
    if(!empty($statusname)) return $statusname;
    return '';
    /*旧代码
    global $adb,$current_user;
    switch($fld_module){
        case 'SalesOrder':
            $tabname = 'ld_sostatus';
            $select = 'sostatus';
            $odery = ' ORDER BY sostatusid';
            break;
        case 'ServiceContracts';
            $tabname = 'ld_contract_status';
            $select = 'contract_status';
            $odery = ' ORDER BY contract_statusid';
            break;
        case 'PurchaseOrder';
            $tabname = ' ld_postatus ';
            $select = 'postatus';
            $odery = ' ORDER BY postatusid';
            break;
        case 'PurchaseInvoice';
            $tabname = ' ld_purchaseinvoicestatus ';
            $select = 'purchaseinvoicestatus';
            $odery = ' ORDER BY purchaseinvoicestatusid';
            break;
        case 'Invoice';
            $tabname = ' ld_invoicestatus ';
            $select = 'invoicestatus';
            $odery = ' ORDER BY invoicestatusid';
            break;
        case 'ProjectTask';
            $tabname = ' ld_projecttaskstatus ';
            $select = 'projecttaskstatus';
            $odery = ' ORDER BY projecttaskstatusid';
            break;
    }
    $sql = 'select '.$select.' from '.$tabname.$odery;

    $result = $adb->pquery($sql,array());
    $num_rows = $adb->num_rows($result);
    $statusname=array();
    if($num_rows > 0){
        for($i=0;$i<$num_rows;$i++){
            $statusname[]=array('statusname'=>$adb->query_result($result,$i,$select)
            );
        }
    }

    if(!empty($statusname)) return $statusname;
    return '';*/
}
function isRequiredFieldRule($module,$triggercolumnname)
 {
         crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
         $fieldruleobj=cls_fieldrule::getInstance($module);
        $allfieldrule= $fieldruleobj->getAllRules();//布局规则必填项
        if(array_key_exists($triggercolumnname,$allfieldrule))
        {
            $triggeroperatecolumns=$fieldruleobj->getAllTriggerOperate();
            //获取触发字段（状态是否设置必填字段）
            foreach($triggeroperatecolumns[$triggercolumnname] as $basicsearchid=>$triggerinfo)
            {
                 if($triggerinfo['type']=='required')
                 {
                    return 'yes';
                 }
            }
            //exit();
            //return 'yes';
            return 'no';
        }
        else
        {
            return 'no';
        }
    
 }
function chagestatus($mode,$fld_module,$status,$select_id){
     global $adb,$current_user;
   
    switch($fld_module){
        case 'SalesOrder': 
            $tabname = 'ld_salesorder';
            $select = 'sostatus';
            $id = 'salesorderid';
            break;
        case 'ServiceContracts';
            $tabname = 'ld_servicecontracts';
            $select = 'contract_status';
            $id = 'servicecontractsid';
            break;
        case 'PurchaseOrder';
            $tabname = ' ld_purchaseorder ';
            $select = 'postatus';
            $id = 'purchaseorderid';
            break;
        case 'PurchaseInvoice';
            $tabname = ' ld_purchaseinvoice ';
            $select = 'purchaseinvoicestatus';
            $id = 'purchaseinvoiceid';
            break;
        case 'Invoice';
            $tabname = ' ld_invoice ';
            $select = 'invoicestatus';
            $id = 'invoiceid';
            break;
       case 'ProjectTask';
            $tabname = ' ld_projecttask ';
            $select = 'projecttaskstatus';
            $id = 'projecttaskid';
            break;
    }    
    $isexistrequiredfield=isRequiredFieldRule($fld_module,$select);
   
    $focus=CRMEntity::getInstance($fld_module);
    $fields=$focus->fieldobj->getModuleAllPreseneceFields();
    $list_link_field=$focus->list_link_field;
    $statuslabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$select,'fieldlabel');
    $batcherrorlog=getFixedLabel('ChangemodulestatusError');
    $batchsuccesslog=getFixedLabel('ChangemodulestatusSuccess');
    if($mode=='detail')
    {
		
               
		$focus->massChangeOrder_before($fld_module,array($select_id),$status) ;   
	   $ret=insertHistory($fld_module,$select,$tabname,$id,$select_id,$status,$focus);
       $entity=array();
        if($ret=='success')
        {
            	$focus->massChangeOrder_after($fld_module,array($select_id)) ;   
		      $entity['code']=1;
        }
        else
        {
           $entity['code']=0;
           $entity['msg']=  $focus->fieldobj->getFieldInfoBykeyValue("columnname",$ret,'fieldlabel').getFixedLabel('FieldCANNOTEMPTY');
            
        }
       
		$json = new Zend_Json();
        $jsonentity = $json->encode($entity);
		echo $jsonentity;die;
    }
    else
    {
           
			//$selectid = $_REQUEST['select_id'];//选中的ID
            $selectid = getSelectedRecords($_REQUEST,$fld_module,$_REQUEST['select_id'],$_REQUEST['excludedRecords']);
            $selectid = implode(';',$selectid);
			$entityarray = getEntitynameInfo(getTabid($fld_module));
			$tabname = $entityarray['tablename'];
			$tabindex = $entityarray['entityidfield'];
			$tabfieldname = $entityarray['fieldname'];
			if(empty($tabname)) $tabname = 'ld_'.strtolower($fld_module);
			if(empty($tabindex)) $tabname = strtolower($fld_module).'id';
            
			
				$selectarr = explode(';',$selectid);
				foreach ($selectarr as $crmid) {
					if(empty($crmid)) continue;
                      
                        $focus->massChangeOrder_before($module,array($crmid),$status);                      
					 	$ret= insertHistory($fld_module,$select,$tabname,$id,$crmid,$status,$focus);
                        $focus->retrieve_entity_info($crmid,$fld_module);
                        $subject=$focus->column_fields[$list_link_field];
                        if($ret=='success')
                        {
                              $Allupdate_ids[]=$crmid;
                           $correct++; 
                           
                           $edit_err .= sprintf($batchsuccesslog, '<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject . '</a>', $statuslabel) . '<br>';
                        }
                        else
                        {
                            $tmpfieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$ret,'fieldlabel');
                            $edit_err .= sprintf($batcherrorlog, '<a referencemodule="'.$fld_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject . '</a>', $statuslabel,$tmpfieldlabel) . '<br>';
                        }
			}
			
            $finalresult =array('noofrows'=>sizeof(array_filter($selectarr)),'correct'=>$correct,'edit_err'=>$edit_err);
          
           $focus->massChangeOrder_after($module,$Allupdate_ids) ;        
			//获取修改状态的模块页数
			if(isset($_SESSION['lvs'][$fld_module]['viewname'])){
				$viewid = $_SESSION['lvs'][$fld_module]['viewname'];
				$start = $_SESSION['lvs'][$fld_module][$viewid]['start'];
			}
			if(!$start) $start = 1;
			$entity['start']['value'] = $start;
		
			$json = new Zend_Json();
            $submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
            $submitlog = sprintf($submitlog,$finalresult['noofrows'],$finalresult['correct'],$error);
            $submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
            if(!$start) $start = 1;
            $entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$finalresult['edit_err']."</div>";//批量处理信息
            $entity['start']['value'] = $start;//当前页数
            $entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
            $entity['title']['value'] = getFixedLabel('CHANGE').$statuslabel;
			$jsonentity = $json->encode($entity);
			echo $jsonentity;die;
    }
    
}
//插入日志
function insertHistory($fld_module,$select,$tabname,$id,$select_id,$status,$focus){
	global $adb;
	if(!empty($select_id)){
		$query = 'select '.$select. ' from '.$tabname. ' where '.$id.'='.$select_id;
		$results=$adb->pquery($query);
        $status_before = $adb->query_result($results,0,$select);

        $isexistrequiredfield=isRequiredFieldRule($fld_module,$select);
        $fields=$focus->fieldobj->getModuleAllPreseneceFields();
		if($status_before != $status){
            require_once('modules/ModTracker/ModTracker.php');
            $focus->getModuleStatic('ModTracker');//字段修改日志
           
            $focus->modstatic->saveFieldLogOne($fld_module,$select,$select_id,
						$status_before, $status);
        }
        $focus=CRMEntity::getInstance($fld_module);
        $focus->retrieve_entity_info($select_id,$fld_module);
        $col_fields=$focus->column_fields;
        
        $col_fields['db_'.$select]=$col_fields[$select];
        $col_fields[$select]=$_REQUEST['statusname'];
       
        if($isexistrequiredfield=='yes')
        {
                    
                      $columnvalues=array();
                       $fieldruleobj=cls_fieldrule::getInstance($fld_module);
                     $showfieldvalue=new ShowFieldValue($focus->fieldobj,$fld_module,constant('SHOW_POPUP'));
                     $showfieldvalue->col_fields=$col_fields;
    		          $showfieldvalue->setRecorId($crmid);
                      foreach($fields as $tmpfieldinfo)
                      {     
                            $tmpfieldname=$tmpfieldinfo->getFieldName();
                            $showvalue=$showfieldvalue->getFieldValueByField($tmpfieldinfo,$col_fields[$tmpfieldname],$col_fields[$tmpfieldname]);
                            $columnvalues[$tmpfieldinfo->getColumnName()]=$showvalue['value'];
                             
                      }
                      
                    $_REQUEST['mass_edit_recordid']=$select_id;
                     $fieldruleobj->setColumnValues($columnvalues);
                     $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty($select);//布局规则字段的隐藏和必填项
                     $tmprequiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
                     
                      unset($_REQUEST['mass_edit_recordid']);
                     foreach($tmprequiredcolumns as $tmpcolumnname)
                     {
                         $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$tmpcolumnname);
                            if(!$tmpfieldinfo||$tmpfieldinfo->getFieldName()=='')
                                continue;
                        if(trim($columnvalues[$tmpcolumnname])=='')
                        {
                             //$edit_err .= sprintf($batcherrorlog, '<a href="index.php?module='.$fld_module.'&action=DetailView&record=' . $select_id . '"  target="_black" >' . $subject . '</a>',$statuslabel, $focus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,'fieldlabel')) . '<br>';
                            $error='yes';
                            break;
                        }
                     }
        }
       
        if($error=='yes')
        {
            return $tmpcolumnname;
        }
        else
        {
             $sql = 'update '.$tabname.' set '.$select.'="'.$status.'" where '.$id.'='.$select_id;   
              $adb->pquery($sql,array());
              return 'success';
        }
	}
}
?>