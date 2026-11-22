<?php
//zkt 20231121 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//编辑和新增界面布局规则
//$global_allfiledatas:附件
global $currentModule,$global_allfiledatas,$adb,$current_user;
$smarty=new lingdangCRM_Smarty();
//$smarty增加传参
$showpageruledisp_view = $_REQUEST['showpageruledisp_view'];
$smarty->assign("showpageruledisp_view", $_REQUEST['showpageruledisp_view']);//触发布局规则弹出层对应disp_view
$smarty->assign("mode_showpagerule", 'yes');
$focus=CRMEntity::getInstance($currentModule);
setObjectValuesFromRequest($focus);
$modulefields=$focus->fieldobj->getModuleFields();
//用于储存display值为2的信息
$display2_info_arr = array();
foreach($modulefields as $fieldname=>$fieldinfo)
{
    if($fieldinfo->getBigType()=='reference')
    {
        $focus->column_fields[$fieldname.'_name']=$_REQUEST[$fieldname.'_name'];
    }
    else if($fieldinfo->getUIType()==202)
    {
        if($currentModule=='PaymentPlan'||$currentModule=='SendPayment'){
            //edit:can 20210205 044617: （http://www.xiaoshou360.com/xs/zezn [^]）上海智迩智能科技有限公司（张德广）；财务管理-付款计划-编辑，重新选择付款方式之后，源单信息会丢失。付款方式这个字段有一个布局规则
//        $focus->column_fields[$fieldname]=$_REQUEST['salesorder_id'];//BUG0076084 lius 编辑收款计划单据“收款计划类型”字段(有布局规则) “计划收款日期” 切换为 “项目状态”时选择源单被清空,现在用的entitytypeid，salesorder_id不用了
        }else{
            $focus->column_fields['entitytype']=$_REQUEST['selectsource'];
        }
    }
    else if($fieldinfo->getUIType()==33)
    {
        if(isset($_REQUEST[$fieldname]))
            $focus->column_fields[$fieldname]=setsaveMutliPickListValue($_REQUEST[$fieldname]);
        else
        {
            $focus->column_fields[$fieldname]=$fieldinfo->getDefaultvalue();
        }
    }

    else if($fieldinfo->getUIType()==151){
        crm_load_function_file('selWareAll','include/Stock','CommonStock');
        $wareresult = selWareAll();
        for($i = 0; $i<$adb->num_rows($wareresult); $i++)
        {
            $wareArray[$adb->query_result($wareresult, $i, "id")] = $adb->query_result($wareresult, $i, "name");
        }
        $smarty->assign("WAREALL", $wareArray);
    }
    else if ($fieldinfo->getUIType()==72){
        //BUG20241012-04  产品管理——为“产品报价(RMB)”和“参考成本价(RMB)”设置布局规则之后，他们会不显示更多币种按钮
        if ($currentModule == 'Products'){
            if($focus->mode == 'edit'){
                $productid = $focus->id;
            }else{
                $productid = '';
            }
            $unit_price = $focus->column_fields['unit_price'];
            include_once globalStatic::$root_directory.'include/utils/InventoryUtils.php';
            $price_details = getPriceDetailsForProduct($productid, $unit_price, 'available',$currentModule,'unit_price');
            $smarty->assign("PRICE_DETAILS", $price_details);
            $smarty->assign("PRICE_DETAILS_NUM", sizeOf($price_details));
        }
    }
    else if ($fieldinfo->getUIType()==34){
        if (isset($_REQUEST['jsonvalue_'.$fieldname])){
            $focus->column_fields['jsonvalue_'.$fieldname] = $_REQUEST['jsonvalue_'.$fieldname];
        }
    }

    if(isset($_REQUEST[$fieldname]))
    {
    }
    else
    {
        //edit:can 20210604 045978: （https://61mis.com/kfbcrm/ [^]）客户问题（李轩），设置布局规则为“销售阶段等于需求分析，“多选”字段显示”，销售机会新建界面，“多选”字段设置的默认值没有显示（需要补丁
        $focus->column_fields[$fieldname]=$fieldinfo->getDefaultvalue();
        //zkt 20220523 52026（https://81mis.com/kfbtest/index.php）合同订单，SSO305，已审批单据；设置了布局规则，编辑单据时，触发布局规则后，其他“审批通过后”不可编辑的字段都显示可编辑了
        if($fieldinfo->getDisplaytype() == 2)
        {
            $tmpcolumnname = $fieldinfo->getColumnName();
            $tmpfieldname = $fieldinfo->getFieldName();
            $tablename = $focus->table_name;
            $tableindex = $focus->table_index;
            $tmpthistablename = $fieldinfo->getTableName();
            $tmpsavedatabase = $fieldinfo->getSaveDataBase();
            if($tmpsavedatabase == 'no')
            {
                continue;
            }
            if(in_array($tmpthistablename,$focus->tab_name))
            {
                $display2_info_arr['select_column'][] = "$tmpcolumnname";
                $display2_info_arr['select_column_sql'] .= " $tmpthistablename.$tmpcolumnname,";
                $display2_info_arr['select_column_to_field'][$tmpcolumnname] = $tmpfieldname; 
                if(!in_array($tmpthistablename,(array)$display2_info_arr['select_table'])){
                    $display2_info_arr['select_table'][] = $tmpthistablename; 
                    $tmpthistablenameindex = $focus->tab_name_index[$tmpthistablename];
                    if($tmpthistablename != $tablename){
                        $tmpsql = " left join $tmpthistablename on $tmpthistablename.$tmpthistablenameindex = $tablename.$tableindex ";
                        $display2_info_arr['select_leftjoin_sql'] .= $tmpsql;
                    }
                }
            }
        }
    }
}
//zkt 20220523 52026（https://81mis.com/kfbtest/index.php）合同订单，SSO305，已审批单据；设置了布局规则，编辑单据时，触发布局规则后，其他“审批通过后”不可编辑的字段都显示可编辑了
if(!empty($display2_info_arr))
{
    $tablename = $focus->table_name;
    $tableindex = $focus->table_index;
    $select_column_sql = rtrim($display2_info_arr['select_column_sql'],',');
    $select_leftjoin_sql = $display2_info_arr['select_leftjoin_sql'];
    $tmpsql = "select $select_column_sql from $tablename  $select_leftjoin_sql  where $tablename.$tableindex = ?;";
    $tmpresult = $adb->pquery($tmpsql,array($_REQUEST['record']));
    
    if($adb->num_rows($tmpresult)>0)
    {
        foreach($display2_info_arr['select_column'] as $tmpindex=>$tmpcolumnname)
        {
            $tmpvalue = $adb->query_result($tmpresult,0,$tmpcolumnname);
            $tmpfieldname = $display2_info_arr['select_column_to_field'][$tmpcolumnname];
            $focus->column_fields[$tmpfieldname]=$tmpvalue;
        }
        
    }
}

$focus->id=$_REQUEST['record'];
//chj 2021/4/6 45298: （http://124.71.148.255:85/crm/ [^]）系统设置-成员管理（客户问题-陌远）；新增成员，选择职位级别为“普通用户”，因为布局规则导致界面显示异常
if($currentModule == 'Users'){
	if(is_admin($current_user)||isPermitted("Users", 'index','') == 'yes' )
		$smarty->assign("IS_ADMIN", true);
	else
		$smarty->assign("IS_ADMIN", false);

    $focus->column_fields['record_id']=$focus->id;
}

if($currentModule=='Products')
{
    //edit:can 20231115 75477L【通用BUG】【产品管理】中做了布局规则，触发了规则后，产品的【价格信息】模块会出现 税率 设定，但是后台的税率设定都是关闭的。（最新版本演示账套也是）
    crm_load_function_file('getAllTaxes','include/utils','InventoryUtils');
    $tax_details = (array)getAllTaxes('available');
   
    
}

crm_load_function_file("getEditCommonSmarty",'include/utils','EditViewUtils');
//布局规则和新增编辑界面都会用到该函数
getEditCommonSmarty($smarty,'detail_view',$currentModule,$focus,'showpagerule');

$fields=$focus->fieldobj->getFieldListArray();
$fields['module']=$currentModule;
if($currentModule=='Products'){
    
     foreach($tax_details as $taxnameinfo)
    {
        $fields['fields'][]=array('fieldname'=>$taxnameinfo['taxname']."_check","uitype"=>56,
            'fieldlabel'=>$taxnameinfo['taxlabel'],'typeofdata'=>"C~O");
        $fields['fields'][]=array('fieldname'=>$taxnameinfo['taxname'],"uitype"=>1,
            'fieldlabel'=>$taxnameinfo['taxlabel'],'typeofdata'=>"V~O");
       
    } 
    //35084: （1.6登录）产品管理查看明细界面：价格信息区块没有显示关于税的所有字段
  for($i=0;$i<count($tax_details);$i++)
    {
    	$tax_details[$i]['check_name'] = $tax_details[$i]['taxname'].'_check';
    	$tax_details[$i]['check_value'] = 0;
    }
 
    $smarty->assign("TAX_DETAILS", $tax_details);
}
$_REQUEST['diony']='yes';

// @edit:liushuai,2020-7-8,reason: 义文机电一键检测需求
$VersionInfo = getVersionInfo();
$smarty->assign('MODULE', $currentModule);
$smarty->assign('account', $VersionInfo['account']);
$smarty->assign('VERSIONTRADE',$VersionInfo['trade']);
$smarty->assign('VERSION_ACCOUNT',$VersionInfo['account']);
$arr['content']=$smarty->fetch("DetailView/EditBlockFields.tpl");


$arr['fields'] = $fields['fields'];

$arr['filejsondata'] = $global_allfiledatas;
$arr['isadmin'] = $current_user->is_admin;
$arr['columnfields_value'] = $focus->column_fields;
$arr['filejsondata']=$global_allfiledatas;
if(isset($_REQUEST['detailfieldrule'])&&$_REQUEST['detailfieldrule']=='yes')
{
    //edit:can 20200721 引发明细的布局规则
    $detailfieldinfo_arr= $focus->detailfieldobj->getModuleProductToolField();
    $detailfields_array = $focus->detailfieldobj->getFieldListArray();

    //单据分录字段权限 更新edit_permission
    $pagetype = '';
    switch ($showpageruledisp_view){
        case 'create_view':$pagetype = 'create';break;
        case 'edit_view':$pagetype = 'edit';break;
        case 'detail_view':$pagetype = 'details';break;
    }
    foreach ($detailfields_array as &$tmpdetailfield){
        $columnname = $tmpdetailfield['columnname'];
        $fieldinfo = $detailfieldinfo_arr[$columnname];
        if($fieldinfo){
            if($fieldinfo->getDetailsFieldsProfile($pagetype) != 'write'){
                $edit_perssion = '1';
                $tmpdetailfield['edit_permission'] = $edit_perssion;
            }
        }
    }
    $arr['detailfields']=$detailfields_array;
    crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
      $detailfieldruleobj=cls_detailfieldrule::getInstance($currentModule);
      $fieldrulecolsproperty= $detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
     
      $arr['detailfieldruleinfo']=$fieldrulecolsproperty;
      if(file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'DetailFieldsHtml.php'))
     {
             crm_load_class_file($currentModule.'DetailFieldsHtml','modules/'.$currentModule);
            $str=$currentModule.'DetailFieldsHtml';
          $DetailFieldsHtml = new $str(new $currentModule(),$currentModule);
          $DetailFieldsHtml->getTabDetailFieldsHtml(0);
          $arr['subtotaltr']=$DetailFieldsHtml->getTabDetailHtmlSubTotalTr();
          
     }
     else
     {
      //  $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$currentModule/ProductDetails",array($currentModule));
      //  $ProductDetailsData = crm_load_class_obj('cls_productDetailsData',"modules/$currentModule/ProductDetails",array($currentModule));
      //  $arr['subtotaltr']=$ProductDetailsHtml->getProductHtmlSubTotalTr();
     }
    
}
ConvertTojsonString(1,$arr,'success');


/*$fieldjsondata = array();
    if ($focus->id > 0 && $focus->fieldobj->getFieldInfoBykeyValue("uitype", 1109, 'fieldname') != '')
        $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype", 1109, 'fieldname')] = getAttachmentsTableInfo($focus->id, $currentModule);
    if ($focus->id > 0 && $focus->fieldobj->getFieldInfoBykeyValue("uitype", 69, 'fieldname') != '')
        $fieldjsondata[$focus->fieldobj->getFieldInfoBykeyValue("uitype", 69, 'fieldname')] = getImageFileInfo($focus->id, $currentModule);
*/
?>