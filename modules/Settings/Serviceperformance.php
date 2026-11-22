<?php

require_once 'modules/PickList/PickListUtils.php';
global $adb, $app_strings, $mod_strings, $current_user, $adb, $currentModule;
 global $current_user;

$_SESSION[globalStatic::$root_directory.'prevmenu_modulefile'.$current_user->id]='SettingLeftRight';
$_SESSION[globalStatic::$root_directory.'prevmenu_modilefile_childmenu'.$current_user->id]='Serviceperformance';
$_SESSION[globalStatic::$root_directory.'prevmenu_module'.$current_user->id]='Settings';
$smarty=new lingdangCRM_Smarty();
if ($_REQUEST['selectserverttab']) {
    $selectid = $_REQUEST['selectserverttab'];
} else {
    $selectid = 2;//默认产品_中国上海
    
}
//调用城市连级字段
crm_load_class_file("lingdang_DependencyPicklist", 'modules/PickList', 'DependentPickUtils');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource('Accounts');
$smarty->assign("PICKIST_DEPENDENCY_DATASOURCE", ldcrm_json_encode($picklistDependencyDatasource));

//获取字段名
$product_field_obj = Field::getInstance('Products', $adb);
$arrpaymentLabelProducts = $product_field_obj->getFieldLables();
$account_field_obj = Field::getInstance('Accounts', $adb);
$arrpaymentLabelAccounts = $account_field_obj->getFieldLables();
if (vtlib_isModuleActive('HelpDesk')) {
    $helpdesk_field_obj = Field::getInstance('HelpDesk', $adb);
    $arrpaymentLabelHelpDesk = $helpdesk_field_obj->getFieldLables();
}
if (vtlib_isModuleActive('ProjectTask')) {
    $projecttask_field_obj = Field::getInstance('ProjectTask', $adb);
    $arrpaymentLabelProjectTask = $projecttask_field_obj->getFieldLables();

}
$smarty->assign('SERVICETYPE',$_REQUEST['servicetype']);
if(!empty($arrpaymentLabelProducts['productcategory'])){
	$selecttabs[1] = getTranstab('Products') . '_' . $arrpaymentLabelProducts['productcategory'];
}
$accountmodulefields=$account_field_obj->getModuleFields();
if(array_key_exists("bill_city",$accountmodulefields)&&array_key_exists("bill_area",$accountmodulefields)){
	$selecttabs[2] = getTranstab('Accounts') . '_' . $arrpaymentLabelAccounts['bill_city'].'/'.$arrpaymentLabelAccounts['bill_area'];
}
else if(array_key_exists("bill_city",$accountmodulefields))
{
    $selecttabs[2] = getTranstab('Accounts') . '_' . $arrpaymentLabelAccounts['bill_city'];
    
}
else if(array_key_exists("bill_area",$accountmodulefields))
{
    $selecttabs[2] = getTranstab('Accounts') . '_' . $arrpaymentLabelAccounts['bill_area'];
}
if(!empty($arrpaymentLabelHelpDesk['ticketcategories'])){
	if (vtlib_isModuleActive('HelpDesk')) {
		$selecttabs['3'] = getTranstab('HelpDesk') . '_' . $arrpaymentLabelHelpDesk['ticketcategories'];
	}
}
if(!empty($arrpaymentLabelHelpDesk['servicetype'])){
	if (vtlib_isModuleActive('HelpDesk')) {
		$selecttabs['6'] = getTranstab('HelpDesk') . '_' . $arrpaymentLabelHelpDesk['servicetype'];
	}
}

if (vtlib_isModuleActive('ProjectTask') && !empty($arrpaymentLabelProjectTask['projecttasktype'])) {
    $selecttabs['4'] = getTranstab('ProjectTask') . '_' . $arrpaymentLabelProjectTask['projecttasktype'];
}
$selecttabs['5'] = getFixedLabel('Proportion_of_traffic_expense');
//Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/13 0013 下午 6:08
crm_load_class_file("cls_PickList_ServeicePer", 'modules/PickList');

$objpinklist = new cls_PickList_ServeicePer();

switch ($selectid) {
    case 1:
        //$tabvalue = getProductCategory();//$产品$_$产品类别$
        $tabvalue = $objpinklist->getPickListValues('productcategory','', array(), 'scores');//$产品$_$产品类别$
        $tabheard = Array(
            '1' => $arrpaymentLabelProducts['productcategory'],
            '2' => getFixedLabel('Performance_scores'));
        break;
    case 2:
        //$客户$_$城市$
        $modulefields=$account_field_obj->getModuleFields();
        $servicetypes=array();
        
        if(array_key_exists('bill_city',$modulefields)&&array_key_exists('bill_area',$modulefields))
        {
           
            $tabheard = Array(
            '1' => $arrpaymentLabelAccounts['bill_city'].'/'.$arrpaymentLabelAccounts['bill_area'],
            '2' => getFixedLabel('Performance_scores'));
            $servicetypes[]=array(getFixedLabel("ByCity"),getFixedLabel("ByCity"),"");
            $servicetypes[]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),"");
            if(!isset($_REQUEST['servicetype']))
            {
                //select * from ld_picklist_set where listname='bill_area';
                //select * from ld_picklist_values
                //判断选择的服务考核方法
               $sql=" select ld_picklist_values.* from ld_picklist_values 
                        inner join ld_picklist_set on ld_picklist_values.listid= ld_picklist_set.listid
                        where listname=? and ifnull(scores,'')>=0 limit 1 ";
               $result=$adb->pquery($sql,array('bill_area'));
               $sys_deploy= getSys_deploy(207);
               if($sys_deploy['deploy_value']=='bill_area')
               {
                    $_REQUEST['servicetype']=getFixedLabel("ByBillArea");
                    $servicetypes[1]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),'selected');
               }
               else
               {
                    $_REQUEST['servicetype']=getFixedLabel("ByCity");
                     $servicetypes[0]=array(getFixedLabel("ByCity"),getFixedLabel("ByCity"),'selected');
                }
               
                        

            }
        }
        else if(array_key_exists('bill_city',$modulefields))
        {
             $tabheard = Array(
            '1' => $arrpaymentLabelAccounts['bill_city'],
            '2' => getFixedLabel('Performance_scores'));
            $servicetypes[]=array(getFixedLabel("ByCity"),getFixedLabel("ByCity"),'selected');
            $_REQUEST['servicetype']=getFixedLabel("ByCity");
        }
        else if(array_key_exists('bill_area',$modulefields))
        {
             $tabheard = Array(
            '1' => $arrpaymentLabelAccounts['bill_area'],
            '2' => getFixedLabel('Performance_scores'));
            $servicetypes[]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),'selected');
            $_REQUEST['servicetype']='billarea';
        }
       
        
       
      
        crm_load_function_file('getAssignedPicklistValues', 'modules/PickList', 'PickListUtils');
        /*获取国家
        $picklistValues = getAssignedPicklistValues('bill_country', '', $adb,array(),"");
        if (!empty($picklistValues)) {
            foreach ($picklistValues as $order => $pickListValue) {
                $options[] = array($pickListValue, $pickListValue, $chk_val);
            }
        }*/

        //记录国家已选择值
        /*if ($_REQUEST['bill_country'] && $_REQUEST['bill_country'] != '') {
            foreach ($options as $key => $arr) {
                if (html_entity_decode($arr[0]) == $_REQUEST['bill_country']) {
                    $options[$key][2] = 'selected';
                }
            }
        }
        $fieldvalue ['bill_country'][] = $options;
        $fieldvalue ['bill_country'][] = $arrpaymentLabelAccounts['bill_country'];*/
       if($_REQUEST['servicetype']==getFixedLabel("ByCity"))
       {
        $smarty->assign('servicetype','bill_city');
         $servicetypes[0]=array(getFixedLabel("ByCity"),getFixedLabel("ByCity"),'selected');
       }
       else
       {
           $smarty->assign('servicetype','bill_area');
             if(sizeof($servicetypes)>1)
            {
                $servicetypes[1]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),'selected');
            }
            else
            {
                $servicetypes[0]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),'selected');
            }
       }
         $fieldvalue ['servicetype'][] = $servicetypes;
        $fieldvalue ['servicetype'][] = getFixedLabel('AssessmentMethod');
        
        //$smarty->assign("ServiceTypes",$servicetypes);//服务考核方法
        
       // if($_REQUEST['servicetype']==getFixedLabel("ByCity"))//考核方法城市
        //{
             //设置选择城市默认值
            $selectedvalue = defaultvalueArea();
            if ($_REQUEST['selecttype'] != 'selected') {
                
                   
                $_REQUEST['bill_state'] = $selectedvalue['bill_state'];
                $_REQUEST['bill_city'] = $selectedvalue['bill_city'];
            }
           
             //获取省份
                $picklistValues = getAssignedPicklistValues('bill_state', '', $adb,array(),"");
                $options = Array();
                if (!empty($picklistValues)) {
                    foreach ($picklistValues as $order => $pickListValue) {
                        $options[] = array($pickListValue, $pickListValue, $chk_val);
        
                    }
                }
        
                //记录省份已选值
                if ($_REQUEST['bill_state'] && $_REQUEST['bill_state'] != '') {
                    foreach ($options as $key => $arr) {
                        if (html_entity_decode($arr[0]) == $_REQUEST['bill_state']) {
                            $options[$key][2] = 'selected';
                        }
                    }
                }
                
                $fieldvalue['bill_state'][] = $options;
                $fieldvalue['bill_state'][] = $arrpaymentLabelAccounts['bill_state'];
        
                $picklistValues = getAssignedPicklistValues('bill_city', '', $adb,array(),"");
                $options = Array();
                if (!empty($picklistValues)) {
                    foreach ($picklistValues as $order => $pickListValue) {
                        $options[] = array($pickListValue, $pickListValue, $chk_val);
        
                    }
                }
                //$fieldvalue ['bill_city'][] = $options;
                //$fieldvalue['bill_city'][]='城市';
                $smarty->assign('DEPENCYFIELDVALUE', $fieldvalue);
        
                //获取城市数据显示到table中
                if ($_REQUEST['bill_state'] && $_REQUEST['bill_state'] != '') {
                    $tabvalue = getcity($_REQUEST['bill_state'], $objpinklist);//$客户$_$城市$
                    $tabheard = Array(
                        '1' => $arrpaymentLabelAccounts['bill_city'],
                        '2' => getFixedLabel('Performance_scores'));
                }
       // }
       if($_REQUEST['servicetype']==getFixedLabel("ByBillArea"))////考核方法区域
        {
           
            if($_REQUEST['bill_city']=='')
            {
                //获取默认值
                 $_REQUEST['bill_city'] = $selectedvalue['bill_city'];
            }
            if(sizeof($servicetypes)>1)
            {
                $servicetypes[1]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),'selected');
            }
            else
            {
                $servicetypes[0]=array(getFixedLabel("ByBillArea"),getFixedLabel("ByBillArea"),'selected');
            }
             //获取城市
            if($_REQUEST['bill_state']=='')//如果选择的省份为空
            {
                $picklistValues = getAssignedPicklistValues('bill_city', '', $adb,array(),"");
                $options = Array();
                if (!empty($picklistValues)) {
                    foreach ($picklistValues as $order => $pickListValue) {
                        $options[] = array($pickListValue, $pickListValue, $chk_val);
        
                    }
                }
            }
            else
            {
                $tmp_cur_depencycity='no';
                $picklistValues=getcity($_REQUEST['bill_state'], $objpinklist);
                $options = Array();
                   if (!empty($picklistValues)) {
                    foreach ($picklistValues as $order => $pickListValue) {
                        $options[] = array($pickListValue['name'], $pickListValue['name'], $chk_val);
                        if($_REQUEST['bill_city']==$pickListValue['name'])
                        {
                            //判断选择的城市是选择的省份级联字段
                            $tmp_cur_depencycity='yes';
                        }
        
                    }
                }
                if($tmp_cur_depencycity=='no')
                {
                    $_REQUEST['bill_city']='';
                }
            }
        
                //记录城市已选值
                if ($_REQUEST['bill_city'] && $_REQUEST['bill_city'] != '') {
                    foreach ($options as $key => $arr) {
                        if (html_entity_decode($arr[0]) == $_REQUEST['bill_city']) {
                            $options[$key][2] = 'selected';
                        }
                    }
                }
                
                $fieldvalue['bill_city'][] = $options;
                $fieldvalue['bill_city'][] = $arrpaymentLabelAccounts['bill_city'];
        
                $picklistValues = getAssignedPicklistValues('bill_area', '', $adb,array(),"");
                $options = Array();
                if (!empty($picklistValues)) {
                    foreach ($picklistValues as $order => $pickListValue) {
                        $options[] = array($pickListValue, $pickListValue, $chk_val);
        
                    }
                }
                //$fieldvalue ['bill_city'][] = $options;
                //$fieldvalue['bill_city'][]='城市';
                $smarty->assign('DEPENCYFIELDVALUE', $fieldvalue);
                $tabvalue=array();
                //获取城市数据显示到table中
                if ($_REQUEST['bill_city'] && $_REQUEST['bill_city'] != '') {
                    $tabvalue = getbillarea($_REQUEST['bill_city'], $objpinklist);//$客户$_$城市$
                    $tabheard = Array(
                        '1' => $arrpaymentLabelAccounts['bill_area'],
                        '2' => getFixedLabel('Performance_scores'));
                }
        }
       
        break;
    case 3:

        //$tabvalue = getTicketCategories();//$服务单$_$故障类别$
        $tabvalue = $objpinklist->getPickListValues('ticketcategories', '',array(), 'weight');//$服务单$_$故障类别$
        $tabheard = Array(
            '1' => $arrpaymentLabelHelpDesk['ticketcategories'],
            '2' => getFixedLabel('Performance_weight') . '(%)');
        break;
    case 4:
        //$tabvalue = getProjectTaskType();//$项目任务$_$类型$
        $tabvalue = $objpinklist->getPickListValues('projecttasktype', '',array(), 'weight');//$项目任务$_$类型$
        $tabheard = Array(
            '1' => $arrpaymentLabelProjectTask['projecttasktype'],
            '2' => getFixedLabel('Performance_weight') . '(%)');
        break;

    case 5:
        $tabvalue = getProportionTrafficExpense();//交通补贴
        $tabheard = Array(
            '1' => getFixedLabel('BillType'),
            '2' => getFixedLabel('Proportion_traffic_expense'));
        break;
    case 6:
        //$tabvalue = getServiceType();//交通补贴
        $tabvalue = $objpinklist->getPickListValues('servicetype', '',array(), 'weight');//交通补贴
        $tabheard = Array(
            '1' => $arrpaymentLabelHelpDesk['servicetype'],
            '2' => getFixedLabel('Performance_weight') . '(%)');
        break;
}

// print_r($tabheard);

$smarty->assign("LIST_ENTRIES", $tabvalue);


$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("APP", $app_strings);
$smarty->assign("CMOD", $mod_strings);
//$smarty->assign("MOD", return_module_language($current_language,'Settings'));
$smarty->assign('SELECTTABCNT', $selecttabs);

$smarty->assign("SELECTSERVERTTABID", $selectid);
$smarty->assign("TABHEARD", $tabheard);
$smarty->assign("LANGUAGETYPE", $languageType);

// require_once('SetmenuControl.php');
$_REQUEST['diony']='yes';
if($_REQUEST['ajax']=='yes')
{
    $arr['pickhtml'] = $smarty->fetch('Settings/ServicePerformanceContentPick.tpl');
	$arr['content']= $smarty->fetch('ServiceperformanceContent.tpl');
}
else
    $arr['content']= $smarty->fetch('Serviceperformance.tpl');
ConvertTojsonString(1,$arr,"success");

/*
获取交通补贴绩效权重
*/
function getProportionTrafficExpense()
{
    global $adb, $languageType;
    $SQL = "SELECT ld_tranlabel.tabid,fieldlabel,ifnull(Proportion,0) as Proportion FROM ld_tranlabel LEFT JOIN ld_tab ON ld_tab.tabid =ld_tranlabel.tabid
WHERE relateid IN (SELECT tabid FROM ld_tab WHERE name='HelpDesk' OR name='ProjectTask')
AND ld_tranlabel.tabid=relateid AND trantable='ld_tab' AND languagetype='$languageType';";
    $result = $adb->pquery($SQL, array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $ProportionTrafficExpense[$i]['id'] = $adb->query_result($result, $i, 'tabid');
        $ProportionTrafficExpense[$i]['name'] = $adb->query_result($result, $i, 'fieldlabel');
        $ProportionTrafficExpense[$i]['scores'] = $adb->query_result($result, $i, 'proportion');//绩效权重
    }
    return $ProportionTrafficExpense;
}

//Eidtor:gyq_64 Reason:下面函数全部弃用 Date:2018/3/14 0014 上午 10:34
/*
获取产品类别绩效基数
*/
function getProductCategory()
{
    global $adb;
    $SQL = 'SELECT productcategoryid,productcategory,ifnull(scores,0) as scores FROM ld_productcategory where presence=1 order by productcategoryid asc ';
    $result = $adb->pquery($SQL, array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $ProductCategory[$i]['id'] = $adb->query_result($result, $i, 'productcategoryid');
        $ProductCategory[$i]['name'] = $adb->query_result($result, $i, 'productcategory');
        $ProductCategory[$i]['scores'] = $adb->query_result($result, $i, 'scores');//绩效基数
    }
    return $ProductCategory;
}

/*
获取服务方式绩效权重
*/
function getProjectTaskType()
{
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 1:38
    crm_load_class_file("cls_PickList_ServeicePer", 'modules/PickList');
    $objpinklist = new cls_PickList_ServeicePer();
    $result_pick = $objpinklist->getPickListValues('productcategory','',array(),'weight');
    return $result_pick;
    /*global $adb;
    $SQL = 'SELECT projecttasktypeid,projecttasktype,ifnull(weight,0) as weight FROM ld_projecttasktype where presence=1 order by projecttasktypeid asc ';
    $result = $adb->pquery($SQL, array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $ProjectTaskType[$i]['id'] = $adb->query_result($result, $i, 'projecttasktypeid');
        $ProjectTaskType[$i]['name'] = $adb->query_result($result, $i, 'projecttasktype');
        $ProjectTaskType[$i]['scores'] = $adb->query_result($result, $i, 'weight');//绩效权重
    }
    return $ProjectTaskType;*/
}

/*
获取任务类别绩效权重
*/
function getServiceType()
{
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 2:26
    crm_load_class_file("cls_PickList_ServeicePer", 'modules/PickList');
    $objpinklist = new cls_PickList_ServeicePer();
    $ServiceType = $objpinklist->getPickListValues('servicetype','',array(),'weight');
    return $ServiceType;
    /*global $adb;
    $SQL = 'SELECT servicetypeid,servicetype,ifnull(weight,0) as weight FROM ld_servicetype where presence=1 order by servicetypeid asc;';
    $result = $adb->pquery($SQL, array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $ServiceType[$i]['id'] = $adb->query_result($result, $i, 'servicetypeid');
        $ServiceType[$i]['name'] = $adb->query_result($result, $i, 'servicetype');
        $ServiceType[$i]['scores'] = $adb->query_result($result, $i, 'weight');//绩效权重
    }
    return $ServiceType;*/
}

/*
获取故障类别绩效权重
*/
function getTicketCategories()
{
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 2:53
    crm_load_class_file("cls_PickList_ServeicePer", 'modules/PickList');
    $objpinklist = new cls_PickList_ServeicePer();
    $TicketCategories = $objpinklist->getPickListValues('ticketcategories','',array(),'weight');
    return $TicketCategories;
  
}


/*
获取选择的城市绩效权重
*/
function getcity($sourcevalue, $objpick)
{
    global $adb;
    $SQL = "SELECT targetvalues FROM ld_picklist_dependency where sourcefield='bill_state' and sourcevalue='$sourcevalue' AND tabid=(SELECT tabid FROM ld_tab WHERE name='Accounts') limit 1;";
    $result = $adb->pquery($SQL, array());
    
    $rowCount = $adb->num_rows($result);
    $target = Zend_Json::decode(html_entity_decode($adb->query_result($result, 0, 'targetvalues')));
    if ($rowCount == 0) {
        //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/13 0013 下午 6:53
        //$city=getAllcity();
        $city = $objpick->getPickListValues_City('bill_city');
    } else {
        $targetvalues = "'" . implode("','", $target) . "'";
        $city = $objpick->getPickListValues_City('bill_city', $targetvalues);
    }

    return $city;


}
/*
获取选择区域绩效权重
*/
function getbillarea($sourcevalue, $objpick)
{
    global $adb;
    $tabid=getTabid("Accounts");
    $SQL = "SELECT targetvalues FROM ld_picklist_dependency 
        where tabid=? and sourcefield='bill_city'  and sourcevalue='$sourcevalue'
          limit 1;";
    $result = $adb->pquery($SQL, array($tabid));
    $rowCount = $adb->num_rows($result);
    
    $target = Zend_Json::decode(html_entity_decode($adb->query_result($result, 0, 'targetvalues')));
    if ($rowCount == 0) {
        //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/13 0013 下午 6:53
        //$city=getAllcity();
        $city = $objpick->getPickListValues_City('bill_area');
    } else {
        $targetvalues = "'" . implode("','", $target) . "'";
        $city = $objpick->getPickListValues_City('bill_area', $targetvalues);
    }

    return $city;


}
/*
获取全部城市绩效权重
*/
/*function getAllcity(){
    global $adb;
    $SQLcity = "select bill_cityid,bill_city,ifnull(scores,0) as scores from ld_bill_city where presence=1 order by picklist_valueid asc;";
        $results=$adb->pquery($SQLcity,array());
   $rowCount = $adb->num_rows($results);
    for ($i = 0; $i < $rowCount; $i++) {
        $city[$i]['id'] = $adb->query_result($results, $i, 'bill_cityid');
        $city[$i]['name'] = $adb->query_result($results, $i, 'bill_city');
        $city[$i]['scores'] = $adb->query_result($results, $i, 'scores');//绩效权重
    }

        return $city;
}*/

//获取默认城市
function defaultvalueArea()
{
    global $adb;
    //34855: 系统设置>服务考核设置>选择绩效维度为“客户-城市”：在刚进入选择绩效维度时显示的“客户-城市”字段没有数据，但是切换任意一个下拉选项后在切换回来就有数据。
    $SQL = "select columnname,defaultvalue from ld_field WHERE tabid=6 AND (columnname='bill_state' OR columnname='bill_city' or columnname='bill_area');";
    $results = $adb->pquery($SQL, array());
   $rowCount = $adb->num_rows($results);
   // if($rowCount<=0)
   // {
       // $city["bill_country"] = "中国";
       // $city["bill_state"] = "上海";
       // return $city;
   // }
    for ($i = 0; $i < $rowCount; $i++) {
        $columnname = $adb->query_result($results, $i, 'columnname');
        $city[$columnname] = $adb->query_result($results, $i, 'defaultvalue');
    }
    return $city;
}

?>