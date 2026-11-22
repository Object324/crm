<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/5/11 0011
 * Time: 下午 2:33
 */
class cls_SalesStage
{
    public $module;
    public $errorcolumn;
    
    public function __construct()
    {
        $this->module="Potentials";
    }
    public function isSalesStageRequiredFieldRule()
    {
         crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
         $fieldruleobj=cls_fieldrule::getInstance($this->module);
        $allfieldrule= $fieldruleobj->getAllRules();//布局规则必填项
        if(array_key_exists('sales_stage',$allfieldrule))
        {
            $triggeroperatecolumns=$fieldruleobj->getAllTriggerOperate();
            //获取触发字段（销售阶段是否设置必填字段）
            foreach($triggeroperatecolumns['sales_stage'] as $basicsearchid=>$triggerinfo)
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
    public function save_salesStage_multi($select_id,$salesstage){
        global $adb,$reset_retrieve_entity_info;
        $reset_retrieve_entity_info='yes';
        //成功提示
        $focus=CRMEntity::getInstance($this->module);
        $isexistssalestagerule=$this->isSalesStageRequiredFieldRule();
        $fieldruleobj=cls_fieldrule::getInstance($this->module);
       
     
        $batcherrorlog = getFixedLabel('PROMOTERRORREASON');
        //失败提示
        $batchsuccesslog = getFixedLabel('TOPROMOTETHESUCCESS');
        //操作类型
        $batchtype = getFixedLabel('ADVANCE');
        //获取批量处理数
        $deployarray=getSys_deploy(67);
        $btach_num =  $deployarray['deploy_value'];
        //获取销售机会链接字段
        $entityarray = getEntitynameInfo(getTabid('Potentials'));
        $tabfieldname = $entityarray['fieldname'];
		$focus = CRMEntity::getInstance('Potentials');
         $fields=$focus->fieldobj->getModuleAllPreseneceFields();
         $list_link_field=$focus->list_link_field;
      
        if('all' == $select_id) {//全部
            $records = getSelectedRecords($_REQUEST, 'Potentials', $select_id, null);
           /* $query = "SELECT ld_potential.potentialid as crmid,ld_potential.sales_stage,ld_potential.amount
                        ,ld_potential.probability,ld_potential.closingdate,$tabfieldname as subject
				$sqlrequirecols FROM ld_potential 
				LEFT JOIN ld_potentialscf b ON ld_potential.potentialid=ld_potentialscf.potentialid 
				WHERE ld_potential.potentialid in (" . implode(',', $records) . ")";*/
                
            //$result = $adb->pquery($query, array());
           // $noofrows = $adb->num_rows($result);
          
            $noofrows=sizeof($records);
            
           // $list_link_columnname=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$list_link_field,'columnname');
            for ($i = 0; $i < $noofrows; $i++) {
                $crmid =$records[$i];// $adb->query_result($result, $i, 'crmid');
               
                if (empty($crmid)) continue;
                if ($btach_num <= $i) break;
                  $focus->retrieve_entity_info($crmid,$this->module);
                 $col_fields=$focus->column_fields;
                 $col_fields['db_sales_stage']=$col_fields['sales_stage'];
                 $col_fields['sales_stage']=$_REQUEST['salesstage'];
                 $subject =$col_fields[$list_link_field];// $adb->query_result($result, $i, $list_link_columnname);
                 $error='no';
                 if($isexistssalestagerule=='yes')
                 {
                    // $fieldruleobj=cls_fieldrule::getInstance($this->module);
                      $columnvalues=array();
                      //$fieldruleobj=new cls_fieldrule($this->module);
                     $showfieldvalue=new ShowFieldValue($focus->fieldobj,$this->module,constant('SHOW_POPUP'));
                     $showfieldvalue->col_fields=$col_fields;
    		          $showfieldvalue->setRecorId($crmid);
                      foreach($fields as $tmpfieldinfo)
                      {
                            $tmpfieldname=$tmpfieldinfo->getFieldName();
                            $showvalue=$showfieldvalue->getFieldValueByField($tmpfieldinfo,$col_fields[$tmpfieldname],$col_fields[$tmpfieldname]);
                            $columnvalues[$tmpfieldinfo->getColumnName()]=$showvalue['value'];
                      }
                     $fieldruleobj->setColumnValues($columnvalues);
                     $_REQUEST['mass_edit_recordid']=$crmid;
                     $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty('sales_stage');//布局规则字段的隐藏和必填项
                     $tmprequiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
                     unset($_REQUEST['mass_edit_recordid']);
                     foreach($tmprequiredcolumns as $tmpcolumnname)
                     {
                         $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$tmpcolumnname);
                         if(!$tmpfieldinfo||$tmpfieldinfo->getFieldName()=='')
                                continue;
                        if(trim($columnvalues[$tmpcolumnname])=='')
                        {
                            
                            $edit_err .= sprintf($batcherrorlog, '<a referencemodule="Potentials" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject . '</a>', $focus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,'fieldlabel')) . '<br>';
                            $error='yes';
                            break;
                        }
                     }
                 }
                
                 if($error=='yes'){
                    continue;
                 }
                //$selsalesstage = "select $tabfieldname as subject from ld_potential a LEFT JOIN ld_potentialscf b ON a.potentialid=b.potentialid where a.potentialid = ? limit 1";
                //$resultsales = $adb->pquery($selsalesstage, array($crmid));
                
                $edit_err .= sprintf($batchsuccesslog, '<a referencemodule="Potentials" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject . '</a>', $batchtype) . '<br>';
                $correct++;
            }
            $this->resultExecPotential($col_fields, $salesstage);
        }else{
            $selectarr = explode(';',$select_id);
            $recordid = '';
            if(count($selectarr) == 1){
                $noofrows = 1;
            }else{
                $noofrows = count($selectarr) - 1;
            }
            foreach($selectarr as $key => $id){
                if(empty($id)) continue;
                if($btach_num <= $key)break;
                /*$query = "SELECT ld_potential.potentialid as crmid,ld_potential.sales_stage,ld_potential.amount
                        ,ld_potential.probability,ld_potential.closingdate,$tabfieldname as subject
				$sqlrequirecols FROM ld_potential 
				LEFT JOIN ld_potentialscf b ON ld_potential.potentialid=ld_potentialscf.potentialid 
				WHERE ld_potential.potentialid = ? LIMIT 1;";
                $result = $adb->pquery($query,array($id));*/
                $error='no';
                
                $focus->retrieve_entity_info($id,$this->module);
                $col_fields=$focus->column_fields;
	            
                 $col_fields['db_sales_stage']=$col_fields['sales_stage'];
                 $col_fields['sales_stage']=$_REQUEST['salesstage'];
              
                  $subject=$col_fields[$list_link_field];// $adb->query_result($result,0,'subject');
                 if($isexistssalestagerule=='yes')
                 {
                    //$fieldruleobj=cls_fieldrule::getInstance($this->module);
                      $columnvalues=array();
                      
                     $showfieldvalue=new ShowFieldValue($focus->fieldobj,$this->module,constant('SHOW_POPUP'));
                     $showfieldvalue->col_fields=$col_fields;
    		          $showfieldvalue->setRecorId($crmid);
                      foreach($fields as $tmpfieldinfo)
                      {     
                            $tmpfieldname=$tmpfieldinfo->getFieldName();
                            $showvalue=$showfieldvalue->getFieldValueByField($tmpfieldinfo,$col_fields[$tmpfieldname],$col_fields[$tmpfieldname]);
                            $columnvalues[$tmpfieldinfo->getColumnName()]=$showvalue['value'];
                             
                      }
                      $columnvalues[$list_link_field]=$subject;
                   
                     $fieldruleobj->setColumnValues($columnvalues);
                     $_REQUEST['mass_edit_recordid']=$id;
                     $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty('sales_stage');//布局规则字段的隐藏和必填项
                     $tmprequiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
                     unset($_REQUEST['mass_edit_recordid']);
                     foreach($tmprequiredcolumns as $tmpcolumnname)
                     {
                        if(trim($columnvalues[$tmpcolumnname])=='')
                        {
                            $this->errorcolumn=$tmpcolumnname;
                             $edit_err .= sprintf($batcherrorlog, '<a referencemodule="Potentials" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >' . $subject . '</a>', $focus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,'fieldlabel')) . '<br>';
                            $error='yes';
                          
                            break;
                        }
                     }
                 }
                    
                 if($error=='yes')
                 {
                    continue;
                 }
                $this->UpdatePotentialSalesStage($col_fields,$id,$salesstage);
                $recordid .= $id.',';
                
               
                $lastsales_stage =$col_fields['db_sales_stage'];// $adb->query_result($result,0,'sales_stage');//编辑前的销售阶段
				$db_lastsales_stage=$col_fields['lastsales_stage'];// $adb->query_result($result,0,'lastsales_stage');//编辑前的上一销售阶段
                $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="Potentials" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" >'.$subject.'</a>',$batchtype).'<br>';
                if(!empty($id)){
                    $update = 'update ld_potential set sales_stage = "'.$salesstage.'",lastsales_stage="'.$lastsales_stage.'",modifiedtime="'.date('Y-m-d H:i:s').'" where potentialid = ?  ';
                    $adb->pquery($update,array($id));
					$focus->getModuleStatic('ModTracker');//字段修改日志
					$focus->modstatic->saveFieldLogOne('Potentials','sales_stage',$id,$lastsales_stage, $salesstage);
                }
                $correct++;
            }
        }
        $finalresult =array('noofrows'=>$noofrows,'correct'=>$correct,'edit_err'=>$edit_err);

        return $finalresult;
    }
    /**
     * 因为会多次调用，所以单独提出来
     * @author Tujt 2015-04-08
     */
    public function resultExecPotential($col_fields,$salesstage) {
        global $adb;
        $rows = $adb->num_rows($result);
        if($rows > 0){
			$focus = CRMEntity::getInstance('Potentials');
            for($i=0;$i<$rows;++ $i){
                $crmid = $col_fields['recordid'];
				$lastsales_stage = $col_fields['db_sales_stage'];
                if($crmid > 0){
                    if($btach_num <= $i)break;
                    $this->UpdatePotentialSalesStage($result,$crmid,$salesstage,$i);
                    $update = 'update ld_potential set sales_stage = "'.$salesstage.'",lastsales_stage="'.$lastsales_stage.'",modifiedtime="'.date('Y-m-d H:i:s').'" 
							where potentialid = '.$crmid.';';
                    $adb->pquery($update,array());
					$focus->getModuleStatic('ModTracker');//字段修改日志
					$focus->modstatic->saveFieldLogOne('Potentials','sales_stage',$crmid,$lastsales_stage, $salesstage);
                }
            }
        }
    }
    /**
     * 获取销售机会之前的销售阶段，然后存入销售阶段推进历史表中
     * @param Integer $id 销售机会ID
     * @author Tujt 2015-04-08
     */
    public function UpdatePotentialSalesStage($col_fields,$id,$salesstage,$for_i = 0) {
        global $adb,$current_user;
        //获取销售机会阶段信息
        $time = time();
        $nowdate = date('Y-m-d',$time);
        $nowtime = date('Y-m-d H:i:s',$time);
        //获取记录原有销售阶段
        $old_salesstage =$col_fields['db_sales_stage'];// $adb->query_result($result,$for_i,'sales_stage');
        $amount =$col_fields['amount']; //$adb->query_result($result,$for_i,'amount');
        $probability =$col_fields['probability']; //$adb->query_result($result,$for_i,'probability');
        $closingdate = $col_fields['closingdate']; //$adb->query_result($result,$for_i,'closingdate');
        if(empty($closingdate)) $closingdate = $nowdate;
        $sql = "insert into ld_potstagehistory values(?,?,?,?,?,?,?,?,?,?)";
        $params = array('', $id, $amount,decode_html($old_salesstage), $probability, 0, $adb->formatDate($closingdate, true), $adb->formatDate($nowtime, true),$salesstage,$current_user->id);
        $adb->pquery($sql, $params);

    }
}