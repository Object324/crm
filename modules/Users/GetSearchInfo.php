<?php
/**
 * edit:chj
 * date:2014-9-1
 * reason:获取模块模糊查询信息
 **/
if($_REQUEST['sensitiverequestfield']){
    crm_load_class_file("cls_fieldSensitiverule", "include/fields");
    cls_fieldSensitiverule::changeRequestvalueByfieldarr();
}
global $adb;
if(isset($_REQUEST['selectmodule']) && isset($_REQUEST['frommodule']))
{
	$module = $_REQUEST['selectmodule'];	//窗口选择模块
	$frommodule = $_REQUEST['frommodule'];	//当前打开的模块
	
    crm_load_class_file($module,"modules/$module");
	$focus=new $module();
	//关键字
	if(isset($_REQUEST['keywords']))
		$keywords = trim($_REQUEST['keywords']);
	else
		$keywords = '';
    $tmp_field_obj=Field::getInstance($module,$adb);
	//获取模糊查询的显示列头
	$searchInfo['header'] = $tmp_field_obj->getSearchHeader();
   
	//获取模糊查询的可见字段、拼接字段
    //$searchFieldArr = $focus->getSearchKeyField($module);
    
    $searchFieldArr=$tmp_field_obj->getSearchKeyField();
   
	//获取模块链接字段
	$entityfieldname = getEntityFieldNames($module);
	$entityname = $entityfieldname['fieldname'];
	$fieldnameCnt = count($searchFieldArr);
	for($i = 0; $i<$fieldnameCnt; $i++)
	{
		$columnname[$i] = $searchFieldArr[$i]['columnname'];
	}
	if(!in_array($entityname,$columnname))
	{
		$searchFieldArr[$fieldnameCnt] = array(
			'columnname' => $entityname,
			'tablename' => $focus->table_name
		);
	}
	//$searchInfo['entries'] = getSearchEntries($focus,$searchFieldArr,$module,$keywords,$entityname,$frommodule);
}
$res = getSearchEntries($focus,$searchFieldArr,$module,$keywords,$entityname,$frommodule);
$searchInfo['entries'] = $res['entries'];
$searchInfo['ids'] = $res['ids'];

//判断模糊查询内容是否为空
if(isset($searchInfo['entries']))
    $searchInfo['columnname'] = $columnname;
else
    $searchInfo['columnname'] = '';

 $_REQUEST['diony']='diony';
ConvertTojsonString(1,$searchInfo,"success");
//$jsonentity = Zend_Json::encode($searchInfo);
//$jsonentity=json_encode($searchInfo);

//echo $jsonentity;exit();

/**
 * edit:chj
 * date:2014-9-11
 * reason:获取模块的模糊查询关联内容信息
 * */
function getSearchEntries($focus,$searchFieldArr,$module,$keywords,$entytyname,$frommodule)
{
    if($module=='Accounts')
    {
                 
                 //edit:can 2020-12-29 44008: 金石软件（http://www.xiaoshou360.com/KH/kingsole/ [^]）服务合同>客户字段>不显示预选下拉框，例如搜索"长机",销售订单模块同理。详情见附件。   
            setSearchAllAccount();//设置查询所有的客户（包括公海客户）
                
    }
    global $adb,$current_user;
       // require_once('modules/CustomView/PopupCustomView.php');
       // require_once('include/ProductDetails/PopupProductDetails.php');
         crm_load_class_file('PopupCustomView','modules/CustomView');
          crm_load_class_file('PopupProductDetails','include/ProductDetails');
        $popupProductDetails=new PopupProductDetails($module);
        $customView=new PopupCustomView($module);
        $viewid=0;
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        $tab_name_index = $focus->tab_name_index;
//        $modulearray=array('Users','ContactRecords','Vendors','VendorContact','VendorContactRecords');
         $frommodule=$_REQUEST['frommodule'];
        $fromfocus=CRMEntity::getInstance($frommodule);
        $fieldname=$_REQUEST['fieldname'];
		$fromtabid = getTabid($frommodule);

		$advft_input = [];
        if($_REQUEST['selectrelationfrom']=='entry')
        {
			if(empty($fieldname))
			{
				$fieldname = 'entitytypeid';
			}
			$fieldinfo = $fromfocus->detailfieldobj->getFieldInfoobjBykey("columnname", $fieldname);
			$bigtype = $fieldinfo->getBigType();

            $effectivecondition = '';
			if($bigtype == 'reference'){
				$maxrowsshow = $fieldinfo->getMaxRowsShow();//获取最大显示行数
                $datarang = $fieldinfo->getDataRang();//数据查看范围all,permit;
				$approve_demand = $fieldinfo->get_approve_demand();
				//duan 20231026 $approve_demand 增加不为空判断，因为 0 == 'approve' 是判断正确的
                //zkt 20240909 BUG20240906-60 费用应付单：分录的出库单号字段设置了只能选择已批准的，但是可以把没审批的出库单复制在字段上也可以搜到（出库单编号：LDXSCKD202409060103 审核中的）
				if(!empty($approve_demand) && ($approve_demand == 'approve' || $approve_demand == 1)){
					$approve_demand = 1;
				}else{
					$approve_demand = 0;
				}


                if(get_file_address($frommodule,'ProductDetails')){
                    $query = "select effectivecondition,bigtype from ld_producttoolfield where tabid = ? and columnname = ?";
                }else{
                    $query = "select effectivecondition,bigtype from ld_tabdetailfield where tabid = ? and columnname = ?";
                }
                $result = $adb->pquery($query,array($fromtabid,$fieldname));
                $rows = $adb->num_rows($result);
                if($rows > 0) {
                    $effectivecondition = $adb->query_result($result, 0, 'effectivecondition');
                }
			}else{
				crm_load_class_file('cls_OptionModule', 'include/OptionModule');
				$optionmoduleobj = cls_OptionModule::getInstance($frommodule);
				$options = $optionmoduleobj->getData();
				$tabid = getTabid($frommodule);
				$option_tabid = getTabid($module);
				$maxrowsshow = $options[$tabid][$option_tabid]['maxrowsshow'];
				$approve_demand = $options[$tabid][$option_tabid]['approve_demand'];//1：已批准
                $effectivecondition = $options[$tabid][$option_tabid]['approve_demand'];//其他条件
			}
			//duan 20240826 BUG20240822-46 分录的关联选择单据进行模糊搜索时，设置的其他条件没有生效
            if(!empty($effectivecondition)){
                $effectivecondition = html_entity_decode($effectivecondition);
                $effectivecondition_arr = json_decode($effectivecondition,true);
                if(!empty($effectivecondition_arr['reference'])){
                    $advft_input['advft_criteria'] = $effectivecondition_arr['reference']['advft_criteria'];
                    $advft_input['advft_criteria_groups'] = $effectivecondition_arr['reference']['advft_criteria_groups'];
                    $advft_input['searchtype'] = 'advance';
                }
            }
        } else {
            //editor:gyq_20191202 reason:原生app新增合同订单选择产品报错
            if (!empty($fieldname)) {
                $fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey("fieldname", $fieldname);
				if(!empty($fieldinfo)){
					$maxrowsshow = $fieldinfo->getMaxRowsShow();//获取最大显示行数
					$datarang = $fieldinfo->getDataRang();//数据查看范围all,permit;
				}
            }
            $approve_demand = $focus->get_approve_demand_byModule($frommodule);
        }
        //project:PROT387 edit：cyb date:2016-08-05 description:获取审批要求字段值；

        /*if($approve_demand==1&&!in_array($module,$modulearray)){
            $ApproveModuleStatus=Approve::getApproveModuleInfo();
            if($ApproveModuleStatus[$module]==$module){
                $tabid = getTabid($module);
                $entityarray = getEntitynameInfo($tabid);
                $wheretable = ' and '.$entityarray['tablename'].".approvestatus='".constant('D_A_S_APPROVED')."' ";
            }
        }*/
        //BUG0068302 lius 20230626 费用报销单新建时输入框直接搜索供应商名称可以搜到，但进入弹窗查询字段却无法搜到
        if ($approve_demand == 1) {
            $wheretable = ' and ifnull( ' . $focus->table_name . ".approvestatus,'')='" . constant('D_A_S_APPROVED') . "' ";
        }

        if($module!='Accounts'&&$_REQUEST['keyids']!=''&&$module!='Vendors'){
             //$sql .= $wheretable .$innertable .' '.$secQuery.' '. $orderby;
             $field=$focus->fieldobj->getFieldInfoobjBykey('uitype',73);
             if($field)
                $keywhere=' and ' .$field->getTableName().'.'.$field->getColumnName().'='.$_REQUEST['keyids'];
             $field=$focus->fieldobj->getFieldInfoobjBykey('uitype',81);
             if($field)
                $keywhere=' and ' .$field->getTableName().'.'.$field->getColumnName().'='.$_REQUEST['keyids'];
             
        }
        if(empty($maxrowsshow))
        {
            $maxrowsshow=10;
        }
        //edit:can 20200710 41707: 单据选择单据输入内容模糊匹配，没有调用 ld_relatecreatecondition 中的设置
             crm_load_class_file('cls_RelateCreateCondition','include');
             $relatecreateconditionobj=cls_RelateCreateCondition::getInstance($_REQUEST['selectmodule'],$_REQUEST['frommodule']);
    		$columnvalues=ldcrm_json_decode($_REQUEST['requestvalues']);
            $relatecreateconditioninfos=  $relatecreateconditionobj->getChooseDataWhere($columnvalues);
        
            $limit_sql = ' limit 0,'.$maxrowsshow;
       
       $orderby = " order by convert($entytyname using gbk) DESC,$table_name.createdtime DESC ";
       $module_order_bys=array('Potentials'=>array('closingdate'),'Project'=>array('startdate'),
       'ServiceContracts'=>array('ld_servicecontracts.due_date'),
       'SalesOrder'=>array('ld_salesorder.signed_data'));
       if(in_array($module,array('Potentials','Project','SalesOrder','ServiceContracts'))){
            $orderby = " order by convert($entytyname using gbk) DESC,";
           foreach($module_order_bys[$module] as $key=>$arr){
                $orderby.=$arr.' DESC,';
           }
           $orderby.=$table_name.'.createdtime DESC';
       }
       
        //$orderby = " order by convert($entytyname using gbk) DESC,$table_name.createdtime DESC ";
        //@edit:luyx @date:2021-05-06 @reason: 恒银、泰开 客户名称前面几个字一模一样的有几百个，搜素显示不出来
        if($_REQUEST['selectmodule'] == 'Accounts' && $_REQUEST['keywords'] != ''){
            $orderby = ' order by FIELD(ld_account.accountname,"'.$_REQUEST['keywords'].'") DESC, ld_account.createdtime DESC';
        }
       
        $queryGenerator = QueryGenerator::getInstance($module, $current_user,$customView,$popupProductDetails);
        $queryGenerator->initForCustomViewById($viewid);

        if(sizeof($advft_input)){
            $queryGenerator->addUserSearchConditions($advft_input);
        }

        foreach($relatecreateconditioninfos['tables'] as $tmptable=>$leftjoin)
        {
            $queryGenerator->whereFieldTables[$tmptable]=$leftjoin;
        }
        $advanceDemandSql_res = advanceDemandSql();
        foreach($advanceDemandSql_res['wherefieldtable'] as $tmptable=>$leftjoin)
        {
            $queryGenerator->whereFieldTables[$tmptable]=$leftjoin;
        }
        $page_list_query = $queryGenerator->getQuery('droppop',1).$keywhere;
       
        $list_query= $queryGenerator->getQuery('droppop',2);
        $relatecreateconditionwhere='';
        if(is_array($relatecreateconditioninfos)&& array_key_exists('where',$relatecreateconditioninfos))
        {
            $relatecreateconditionwhere=$relatecreateconditioninfos['where'];
        }
         if(array_key_exists('wheretable',$advanceDemandSql_res))
            $page_list_query.=''.$advanceDemandSql_res['wheretable'];
        
        $list_query.=' inner join ( '.$page_list_query.$wheretable.$relatecreateconditionwhere. $orderby.$limit_sql.' ) as tmp on tmp.'.$table_index.'='.$table_name.'.'.$table_index.$orderby;
       if($module=='Accounts')
       {
        file_put_contents(globalStatic::$root_directory.'modules/Users/2.txt',$list_query);
        
       }
        //echo $list_query;
        // die();
     
	$result = $adb->pquery($list_query);
	$showfieldvalueobj=new ShowFieldValue($focus->fieldobj,$module,SHOW_POPUP);
	$showfieldvalueobj->setadbResult($result);
    $num_rows = $adb->num_rows($result);    
    $id_arr = [];
    for($i = 0; $i<$num_rows; $i++)
    {
        $id = $adb->query_result($result,$i,$table_index);
		$id_arr[] = $id;
        $showfieldvalueobj->setRecorId($id);
        $showfieldvalueobj->setLine_index($i);
        foreach($searchFieldArr as $key => $val)
        {
            $columnname = $val['columnname'];
            $field=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
            
            $showvalue=$showfieldvalueobj->getFieldValueByField($field,$adb->query_result($result,$i,$columnname),$adb->query_result($result,$i,$columnname));
            $res=$showvalue['value'];
            
            if($res == null)
                $res = '';
            $listviewentity[$id][$columnname] = $res;
            //链接字段
            if($entytyname == $columnname)//edit:can 20210426 45653: （https://61mis.com/kfbcrm [^]）报价单中使用模糊搜索选择客户名称时，如果客户名称是由英文名组成那么名称中就会出现‘+’符号，如果手动选择的话就没有这个‘+’符号。可以搜索‘TT’进行测试
            	$listviewentity[$id]['entityname'] = nl2br(decode_html($res));
        }
        if($module=='Accounts')//选择客户后带出负责人（合同订单，收款单)
            $listviewentity[$id]['column_smownerid']=$adb->query_result($result,$i,$focus->getSmownerColumName());     
    }
    //echo '<pre>';
    //print_r($listviewentity);
    //echo '</pre>';
    //die;    
    return array('ids' => implode(',',$id_arr),'entries'=>$listviewentity);;
}

//关联单据 其他条件的过滤设置sql
 function advanceDemandSql()
{
    //edit:can 20210809 47341: （http://47.119.141.34:6091/crm/ [^]）客户问题（深圳慧远），销售管理->合同订单->新建，“客户名称”字段设置了“公海状态不等于公海未分配”的条件，但打字输入客户名称可以选到该公海未分配的客户，但点字段后的“+”查找是找不到的。
    global $adb,$current_user,$currentModule;
    $page_list_query = '';
    $wheretable = '';
    $frommodule = $_REQUEST['frommodule'];
    
    $fieldname = $_REQUEST['fieldname'];
    $selectmodule=$_REQUEST['selectmodule'];
    
    $tabid = getTabid($frommodule);
    if ($tabid > 0) {
         crm_load_class_file('PopupCustomView','modules/CustomView');
          crm_load_class_file('PopupProductDetails','include/ProductDetails');
        $popupProductDetails=new PopupProductDetails($selectmodule);
        $customView=new PopupCustomView($selectmodule);
        $query = "SELECT * FROM ld_field WHERE tabid=? AND fieldname=? AND displaytype=1 LIMIT 1";//displaytype 1 新增编辑界面显示   2 不显示
        $result = $adb->pquery($query,array($tabid, $fieldname));
        $rows = $adb->num_rows($result);
     
        if($rows > 0){
            $advance_demand = $adb->query_result($result,0,'advance_demand');
            $advance_demand_groups = $adb->query_result($result,0,'advance_demand_groups');
            if ($advance_demand && $advance_demand != '[]') {
    //                    $advft_criteria_groups = '[null,{"groupcondition":"and"},{"groupcondition":""}]';
                $customView = new CustomView($selectmodule);
                $queryGenerator =QueryGenerator::getInstance($selectmodule, $current_user,$customView,$popupProductDetails);
    
                $_REQUEST['advft_criteria'] = $advance_demand;
                $_REQUEST['advft_criteria_groups'] = $advance_demand_groups; //  ''
                $_REQUEST['searchtype'] = 'advance';
               // $_REQUEST['search_type'] = 'false';
    
                $queryGenerator->addUserSearchConditions($_REQUEST);
                $page_list_query = $queryGenerator->getQuery();
                $where = $queryGenerator->getConditionalWhere();
                  
                if ($where)
                    $wheretable = ' and '.$where;
            }
        }
    
    }
    
    //edit:can 2022-118 49701: （http://8.129.209.255:85/CRM/ [^]）（铨盛），销售管理->合同订单->新建，“销售组织”和“客户名称”字段在新建界面进行模糊查找都是显示“未找到任何记录”。
    return array('wheretable'=>$wheretable,'page_list_query'=>$page_list_query,'wherefieldtable'=>$queryGenerator->whereFieldTables);
}
?>