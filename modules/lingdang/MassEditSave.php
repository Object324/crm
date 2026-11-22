<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb,$current_user;
$mass_edit_totalrows=$_REQUEST['mass_edit_totalrows'];

$focus = CRMEntity::getInstance($currentModule);
//$approve=new Approve();
$approve = Approve::getInstance($currentModule);
$startapprove=$approve->startBlocksApprove();
if('ServiceCharge' == $currentModule && isset($startapprove['Accounts'])){
    $startapprove['ServiceCharge'] = 1;   
}
$idlist= vtlib_purify($_REQUEST['massedit_recordids']);
$viewid = vtlib_purify($_REQUEST['viewname']);
$return_module = vtlib_purify($_REQUEST['massedit_module']);
$return_action = 'index';

$entityarray = getEntitynameInfo(getTabid($currentModule));

$tabname = $focus->table_name;//模块主表
$moduleid = $tabname.'.'.$focus->table_index;//模块主表ID
$tabfieldname = $entityarray['fieldname'];//模块链接字段
if(empty($tabname)) $tabname = 'ld_'.strtolower($currentModule);
if(empty($moduleid)) $moduleid = strtolower($currentModule).'id';
//BUG20240125-53 ls  240126  kfbcrm-报价单-勾选单据批量编辑，编辑成功的弹出层中单据超链接字段显示为空（模块超链接字段是自定义字段）
$leftjoin = "";
if (in_array($entityarray['tablename'], $focus->customFieldTable)) { //超链接为副表字段时
    $leftjoin = ' left join '.$focus->customFieldTable[0].' on '.$focus->table_name.'.'.$focus->table_index."=".$focus->customFieldTable[0].'.'.$focus->tab_name_index[$focus->customFieldTable[0]];
}

$correct = 0;	//正确记录数
$error = 0;	//错误记录数
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
//客户资料审批完成后是否允许进行编辑 1:否，0:是
//$accountDeployArray = getSys_deploy(16);//客户资料审批完成后是否允许进行编辑 1:否，0:是
$accountDeploy = $accountDeployArray['deploy_value'];
$batchlog = getFixedLabel('DOCUMENTNOSUCCESS');//没有操作权限
$batchotherlog = getFixedLabel('DOCUMENTNOOTHERSUCCESS');//你没有操作其他用户的单据
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//成功
$batchtype = getFixedLabel('EDIT');
$module = $currentModule;

//@edit:liushuai,2021-03-04,reason:【ID1001390】批量编辑增加显示进度条
$startrow = $_REQUEST['startrow'];
$endrow = $_REQUEST['endrow'];
if(!isset($_REQUEST['endrow']))
{
    $endrow = 99999999;
}
if($startrow ==0 || !isset($_REQUEST['startrow']))
{
    $startrow = 0;
    unset($_SESSION[$current_user->id.'_'.$module.'massedit']);  //批量编辑
}

if($_SESSION[$current_user->id . '_' . $module . 'massedit']['crmid'])
{
    //$recordids
    $recordids=$_SESSION[$current_user->id.'_'.$module.'massedit']['crmid'];
}
else
{
    $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
    if ($idlist == 'all') {
        $recordids = getSelectedRecords($_REQUEST, $currentModule, rtrim($idlist, ';'), $excludedRecords);
    } else
        $recordids = array_unique(explode(';', rtrim($idlist, ';')));
    $recordids = array_values($recordids);

    $_SESSION[$current_user->id . '_' . $module . 'massedit']['allcrmid']=$recordids;
    if(sizeof($recordids)>$btach_num)
    {

        $recordids=array_slice($recordids,0,$btach_num);
    }

    $_SESSION[$current_user->id . '_' . $module . 'massedit']['crmid']=$recordids;
}

$totalrecords=sizeof($_SESSION[$current_user->id . '_' . $module . 'massedit']['allcrmid']);
$field_obj=Field::getInstance($currentModule,$adb);
$moduleFields = $field_obj->getModuleFields();
if(!empty($mass_edit_totalrows))
{
    $totalrecords=$mass_edit_totalrows;
}


$records = array_slice($recordids, $startrow, $endrow-$startrow);
$idlist = implode(';', $records);

//$Approve = new Approve();
//$approve = Approve::getInstance();
$approveModule = $approve->getApproveModuleInfo();//获取有审批模块的字段
if(  $currentModule=='Checks'){
	$query = "select $moduleid as id,$tabfieldname as subject,presence as status,smownerid from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}else if($currentModule =='WareHouseTransfer'){
	$query = "select $moduleid as id,$tabfieldname as subject,transferstatus as status,smownerid from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}else if($currentModule =='PaymentPlan'){
	$query = "select $moduleid as id,$tabfieldname as subject,paymentstatus as status,smownerid from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}
else if($currentModule =='SendPayment'){
	$query = "select $moduleid as id,$tabfieldname as subject,CPStatus as status,smownerid from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}
else if($currentModule =='Leads'){
    $query = "select $moduleid as id,$tabfieldname as subject,status,smownerid from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}
else if($currentModule=='ModComments'||$currentModule=='BankAccountSet'||$currentModule=='Rate')
{
    //edit:can 2020-11016 43288: (61mis.com/kfbcrm/index.php)工具-评论；选择评论单据，进行批量编辑，保存后的成功弹窗，没有显示评论单据名称
    $query = "select $moduleid as id,$tabfieldname as subject,'' as status,smownerid,'0' as approveby from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";

}
else if($currentModule=='VendorContactRecords')
{   //@edit:liushuai,2020-11-24,reason:0043409: 供应商联系记录-批量编辑；选择单据后进行批量编辑，保存后提示的编辑成功没有显示单据编号
    $query = "select $moduleid as id,$tabfieldname as subject,'' as status,smownerid,'0' as approveby from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";

}
else if($currentModule=='WorkReportList')
{   
    $query = "select $moduleid as id,$tabfieldname as subject,'' as status,smcreatorid as smownerid,'0' as approveby from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}
else if($currentModule=='Users')
{
    $query = "select $moduleid as id,$tabfieldname as subject,'' as status,smcreatorid as smownerid,'0' as approveby from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";
}
else{

		$query = "select $moduleid as id,$tabfieldname as subject,approvestatus as status,smownerid,approveby from $tabname $leftjoin where $moduleid in (".implode(',',$records).")";

}
$result = $adb->pquery($query);

$num_rwos = $adb->num_rows($result);

sort($records);

for($i = 0; $i<$num_rwos; $i++){
	$id = $adb->query_result($result,$i,'id');
    //0024686: 已经提交审批的单据，提示信息改进。
  /* if(!empty($startapprove[$currentModule])){
        $approve_status = $approve->approveStatus($records[$i]);//获取下一步审批人
         $approvebyid_array = explode(',',$approve_status['nextstepapproveby']);  
        $approvebyname_array = array_map('getUserFullName',$approvebyid_array);
            
        if(count($approvebyname_array)>2){
            $approvebyname_array = array_slice($approvebyname_array,0,2);
            $dot_end = ' ...';
        }
        
        $approveby_ing = implode(',',$approvebyname_array).$dot_end;
    }*/
        
	$tabArr[$id] = array(
		'subject' => $adb->query_result($result,$i,'subject'),
		'status' => $adb->query_result($result,$i,'status'),
		'smownerid' => $adb->query_result($result,$i,'smownerid'),
	);
	if(!empty($startapprove[$currentModule])){
		$tabArr[$id]['approveby'] = $adb->query_result($result,$i,'approveby');
        $tabArr[$id]['nextstepapproveby'] = $approveby_ing;
	}
}

if($currentModule == 'Project'){
	global $projectstatus_old;
}
global $rstart;
//Added to fix 4600
$url = getBasic_Advance_SearchURL();

if(isset($_REQUEST['start']) && $_REQUEST['start']!=''){
    $rstart="&start".vtlib_purify($_REQUEST['start']);
    //print_r($startapprove);
}
$assign_name = [];
$realids = [];
if(isset($idlist)) {
	$recordids = array_unique(explode(';', $idlist));
	
    import('data.Logic','class');
	import('data.BaseLogic','class');
    if(!file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php'))
    {
          
           
    }
    else
    {
            $cls=$currentModule.'Logic';;
           	import('modules.'.$currentModule.'.'.$cls,'class');
    }
    BaseLogic::$module=$currentModule;
   crm_load_class_file("ApproveFinished",'modules/Approve');
   crm_load_class_file("cls_mainfieldformula","include/fields");//字段公式
    
    //duan 20230224 批量编辑时判断验证规则
    crm_load_class_file('cls_PageValidataSave','data');
    $PageValidataSaveobj=new cls_PageValidataSave($currentModule,0,0);
    $PageValidataSaveobj->setApplication('edit');
    $PageValidataSaveobj->batchoprate = 'yes';
    
    
	for($index = 0; $index < count($recordids); ++$index) {
		$recordid = $recordids[$index];
		if($index >= $btach_num)break;
		if($recordid == '') continue;
        
        if(!file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php'))
        {
            
             $btnlogic=new BaseLogic();
        }
        else
        {
            $cls=$currentModule.'Logic';
           	$btnlogic=new $cls();
        }
        $focus->id=$recordid;
        $focus->column_fields['approvestatus']=$tabArr[$recordid]['status'];
        $focus->column_fields['paymentstatus']=$tabArr[$id]['status'];
        $focus->column_fields['cpstatus']=$tabArr[$id]['status'];
        $focus->column_fields['presence']=$tabArr[$id]['status'];
        $btnlogic->controller=$focus;
        //duan 20230224 不判断crmentity中原有的验证规则
        $focus->CheckValidata = 'no';
        
        $permits=$btnlogic->getEditViewBtn();

		if($permits['permit']=='no') 
        {
			/**
			 * 如果有单据的编辑权限，则审批中的单据也可以编辑
			 * @reason 0014673: 关于批量编辑的问题
			 * @author Tujt 2015-05-08
			 */
            if ($currentModule == 'Checks'){
                require_once globalStatic::$root_directory."include/Stock/CommonStock.php";
            }
           
			if((!empty($startapprove[$currentModule])) &&
                ( $tabArr[$recordid]['status'] == constant('D_A_S_APPROVED') ||
                 $tabArr[$recordid]['status'] == constant('D_A_S_REJECTED')) )
            {
                
                
              
				    if($tabArr[$recordid]['status'] == constant('D_A_S_APPROVED') ){//已审批
                     
				    $edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERING'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,getUserFullName($tabArr[$recordid]['approveby'])).'<br>';
    				}else{//已拒绝
    				    $edit_err .= sprintf(getFixedLabel('FAILEDFORORDERISREJECTED'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)"style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,getUserFullName($tabArr[$recordid]['approveby'])).'<br>';
    				}
    				
    				$error++;
                    continue;
				
			}
		    else if((!empty($startapprove[$currentModule])) && $tabArr[$recordid]['status']==constant('D_A_S_APPROVALOF'))
            {
               
                        $edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERING'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,getUserFullName($tabArr[$recordid]['approveby'])).'<br>';
                        $error++;
                         continue;
                    
            }
			else if(($currentModule == 'WareHouseTransfer')
                         && $tabArr[$recordid]['status'] == '已审核' ){
    			$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECK'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).'<br>';
    			$error++;
                 continue;
			}else if(($currentModule == 'Checks'&& $tabArr[$recordid]['status'] ==CHECKEND))
            {
               
                	$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVER'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).'<br>';
				   $error++;
                    continue;
            }
            else if(($currentModule =='OutboundOrder' || $currentModule =='Stock') && $tabArr[$recordid]['status'] == D_A_S_APPROVED){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECK'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).'<br>';
				$error++;
                 continue;
			}else if($currentModule == 'PaymentPlan' && $tabArr[$recordid]['status'] != '未收'){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERSHOUKUAN'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).'<br>';
				$error++;
                 continue;
			}else if($currentModule == 'SendPayment' && $tabArr[$recordid]['status'] != '未付'){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERFUKUAN'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).'<br>';
				$error++;
                 continue;
			}
			else if($currentModule == 'BankAccountSet' && in_array($recordid,$id_list)){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIAN'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).'<br>';
				$error++;
                 continue;
			}
            else if($currentModule == 'Leads' ){
                $upgratede = $tabArr[$recordid]['status'] ;
                //BUG20240125-14 ls 240125 优化成员无其他单据编辑权限时的提示信息
                $edit_err .= sprintf(getFixedLabel('UPGRATEDLEADS'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,$upgratede).getFixedLabel('OR').getFixedLabel('YOUDONOTHAVETHECONTRACTPORDER').'！<br>';
                $error++;
                continue;
            }
			else {

				$edit_err .= sprintf($batchotherlog,'<a referencemodule="'.$mdolue.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,$batchtype).'<br>';
			     $error++;
                 continue;
            }
		
			
		}
		else
		{
		        
                $_REQUEST['mode'] = 'edit';//确保批量编辑后，能够触发CRMEntity.php中triggerEvent()方法的执行，保存修改日志
			     $iscontinue=false;
                if($tabArr[$recordid]['status'] == constant('D_A_S_APPROVED'))
                {
                    //审批结束后 设置允许编辑的字段
                     $ApproveFinishedobj=new ApproveFinished($currentModule,$recordid);
                     $alleditfield_arr= $ApproveFinishedobj->getAllowEditField();

                    foreach($focus->column_fields as $fieldname => $val)
			     	{    	
    					if(isset($_REQUEST[$fieldname."_mass_edit_check"]))
    					{
    					   $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                           $tmp_tableName=$tmpfieldinfo->getTableName();
                           $tmp_columnname=$tmpfieldinfo->getColumnName();
                           
                           $columns="$tmp_tableName:$tmp_columnname:$currentModule";
                           if(!array_key_exists($columns,$alleditfield_arr))
                           {
                                $edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERING'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,getUserFullName($tabArr[$recordid]['approveby'])).'<br>';
   		                       $iscontinue=true;
                                break;
                                
                                
                           }
                        }
                        if($iscontinue)
                        {
                            break;
                        }
                    }
                     
                }
                if($iscontinue)
                {
                    continue;
                }

                
                $focus->retrieve_entity_info($recordid, $currentModule);
				$focus->mode = 'edit';
				$focus->id = $recordid;
                $focus->massEdit_save_before($currentModule,array($focus->id));
				if(!empty($focus->column_fields['currency_id'])){
					$before_currency_id = $focus->column_fields['currency_id'];//修改前币种ID
				}
                if($currentModule == 'Project'){
					
					$projectstatus_old=$focus->column_fields['projectstatus'];
				}
				if($currentModule == 'Accounts' || $currentModule == 'Potentials')
				{
					$assign_name[$index] = $focus->column_fields['assigned_user_id'];//获取编辑前的负责人ID
				}
                $tmpArr=[];
                //230726 wym XUQIU1000102 更多币种保存 需要货币信息
                $currencyobj = Currency::getInstance($adb);
                $currency_details = $currencyobj->getAllCurrencies('all');
                //230726 wym XUQIU1000102 更多币种保存只需要调用一次，赋flag初值为false
                $flag_insertPrice = false;
                
				foreach($focus->column_fields as $fieldname => $val)
				{
					if(isset($_REQUEST[$fieldname."_mass_edit_check"]))
					{

						if($fieldname == 'assigned_user_id'){
							if($_REQUEST['assigntype'] == 'U')  {
								$value = $_REQUEST['assigned_user_id_mass_edit_check'];
							} elseif($_REQUEST['assigntype'] == 'T') {
								$value = $_REQUEST['assigned_group_id_mass_edit_check'];
							}
						} else {
							if(is_array($_REQUEST[$fieldname."_mass_edit_check"]))
								$value = $_REQUEST[$fieldname."_mass_edit_check"];
							else
								$value = trim($_REQUEST[$fieldname."_mass_edit_check"]);
						}
						//	0020205: 批量编辑【多选框】字段，多选情况下被保存后，单据详细页该字段显示为“无法访问”
                        $field = $moduleFields[$fieldname];
                        $tmpArr[$fieldname]=$value;
						if(!empty($field)){
							if($field->getUIType() == 33){
								$value = str_replace(",", " |##| ", $value);
							}
						}
						$focus->column_fields[$fieldname] = $value;
                        //230726 wym XUQIU1000102 更多币种保存只需要调用一次，赋flag初值为false
                        if(($fieldname=='unit_price' || $fieldname=='procostprice') && !$flag_insertPrice){
                            $focus->mass_edit_cur = true;
                            $flag_insertPrice = true;
                        }
					}else{
						$focus->column_fields[$fieldname] = decode_html($focus->column_fields[$fieldname]);
					}


				}

                //duan 20230224 批量保存前判断验证规则
                //先判断不允许保存的验证规则
                $PageValidataSaveobj->focus = $focus;
                $PageValidataSaveobj->resetobj($currentModule,$recordid);//重置验证规则对象
                $PageValidataSaveobj->setAllowSave('no');
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $edit_err .= sprintf(getFixedLabel('documenterrorinfo'),'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" target="_black" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',getFixedLabel('EDIT'),$PageValidataSaveobj->errortip). '<br>';
                    $error++;
                    continue;
                }





				$realids[]=$focus->id;
				$focus->save($currentModule);
                //lius 20231117 BUG0075661 成员管理--批量编辑--编辑部门后,保存后没有显示部门名称(groupid已经更新成功，还需要更新成员关联的部门信息)
                if($focus->module_name == 'Users' && $focus->column_fields['groupid'] !=''){
                    //更新部门信息ld_users2group
                    $focus->insertUsersGroup($focus->column_fields['groupid'],$focus->id);
                }
                if($flag_insertPrice){
                    $focus->insertPriceInformation('ld_productcurrencyrel', 'Products');
                }

				//ls 20220714 BUG0053853 客户管理->客户，通过高级查找后，批量编辑1113条数据的“客户状态”字段，更改为“已成交客户”，保存后返回工商信息不存在，无法继续执行(启用工商查询后，程序exit了)
				if (!empty($focus->saveerrormsg)) {
                    $edit_err .= sprintf("单据[%s]%s失败！原因：".$focus->saveerrormsg,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype,getUserFullName($tabArr[$recordid]['approveby'])).'<br>';
                    $error++;
                    continue;
                }

                $mainfieldformula=new cls_mainfieldformula($currentModule);
               
                //设置哪些字段 在界面上保存
                $mainfieldformula->setMainFieldHadRequest($tmpArr);
                $mainfieldformula->setRecord($focus->id);
                //设置数据库字段的值
                $mainfieldformula->setColumn_fieldsValue($focus->column_fields);
              
                 foreach($tmpArr as $tmpfieldname =>$tmpvalue)
                 {
                        
                        $mainfieldformula->changedfieldNameEvent($tmpfieldname);
                 }
                 $mainfieldformula->updateAllDbValue($focus->id);
                 
                if(is_array($mainfieldformula->updatecolumn_arr)&&sizeof($mainfieldformula->updatecolumn_arr)>0)
                {
                     global $reset_retrieve_entity_info;//修改日志需要重新获取数据
                     $reset_retrieve_entity_info='yes';
                     $focus->retrieve_entity_info($focus->id,$currentModule);
                     
                }
                crm_load_class_file("cls_savereverse",'include/SaveReverse');
        
                $workflowreverseobj=cls_savereverse::getInstance($currentModule);
                $workflowreverseobj->setRecord($focus->id);
                $beforefieldvalue_arr=[];
                $afterfieldvalue_arr=[];
              
                foreach($focus->before_field_info as $fieldinfo)
                {
                    $beforefieldvalue_arr[$fieldinfo->getFieldName()]=$fieldinfo->getColumn_Value();
                }
                 
               
                $pagemode='updated';
                $workflowreverseobj->setPageMode($pagemode);
                $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$focus->column_fields,$pagemode);
                $callapimsg_arr = $workflowreverseobj->getExecResultData();

				$correct++;
                
                //判断允许保存的验证规则
                $PageValidataSaveobj->setAllowSave('yes');
                $PageValidataSaveobj->resetinfo = 'yes';
                $PageValidataSaveobj->getValidDataInfoPhp();
                if(!empty($PageValidataSaveobj->errortip)){
                    $validata_errortip = getFixedLabel('TIPS').':'.$PageValidataSaveobj->errortip;
                }else{
                    $validata_errortip = '';
                }
                
				$edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$currentModule.'" referencerecord="'.$recordid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$tabArr[$recordid]['subject'].'</a>',$batchtype).$validata_errortip.'<br>';
                if (is_array($callapimsg_arr) && count($callapimsg_arr)>0) {
                    $callapimsg = implode('<br/>',$callapimsg_arr);
                    $edit_err .= $callapimsg.'<br/>';
                }
		}
	}
}

if($currentModule == 'Accounts'|| $currentModule == 'Potentials'){
	/**
	 * 更新操作
	 *edit:can
	 * date:20131228
	 * reason:发送短信
	 * other:6535: 客户序时簿界面，选择多个客户信息，点击“修改负责人”，弹出层点击保存，出错，如图：
	 * */
	$idlistarray=explode(';',$idlist);
	$idlist_n=implode(',',$idlistarray);
	$idlist_n_d = substr($idlist_n,0,strlen($idlist_n)-1); 
	$_REQUEST['id']=$idlist_n_d;
	$_REQUEST['sendSms']=implode(',',$assign_name);
	//if($currentModule == 'Accounts')
	//	require_once("modules/Accounts/Accountalertmsg.php");
//	else
	//	require_once("modules/Potentials/Potentialsalertmsg.php");
}

$focus->massEdit_save_after($currentModule,$realids);

//@edit:liushuai,2021-03-04,reason:【ID1001390】批量编辑增加显示进度条
if (!isset($_SESSION[$current_user->id . '_' . $module . 'massedit']['correct'])) {
    $_SESSION[$current_user->id . '_' . $module . 'massedit']['correct'] = 0;
}
$_SESSION[$current_user->id . '_' . $module . 'massedit']['correct'] += $correct;
$_SESSION[$current_user->id . '_' . $module . 'massedit']['edit_err'] .= $edit_err;
//$_SESSION[$current_user->id . '_' . $module . 'massedit']['error'] += $error;

$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'),$totalrecords,$_SESSION[$current_user->id . '_' . $module . 'massedit']['correct'],$totalrecords-$_SESSION[$current_user->id . '_' . $module . 'massedit']['correct']).'</div></div>';

$entity['maxrows'] = sizeof($_SESSION[$current_user->id . '_' . $module . 'massedit']['crmid']);
$entity['selectrows'] = $totalrecords;

$entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$_SESSION[$current_user->id . '_' . $module . 'massedit']['edit_err'].'</div>';//批量处理信息
//$entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$edit_err.'</div>';//批量处理信息
$entity['title']['value'] = getFixedLabel('MASSEDIT');//批量处理信息
$entity['start']['value'] = $rstart;
$entity['actionname']['value'] = 'ListView';

if($endrow>=sizeof($_SESSION[$current_user->id . '_' . $module . 'massedit']['crmid']))
{
    unset($_SESSION[$current_user->id.'_'.$module.'massedit']);
}


$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
//$parenttab = getParentTab();
//header("Location: index.php?module=$return_module&action=$return_action&parenttab=$parenttab$rstart&query_session=1");
?>