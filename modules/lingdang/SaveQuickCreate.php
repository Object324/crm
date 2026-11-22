<?php
global $current_user,$adb;
$saveAccountbyContacts = 0;//快速创建客户时，是否创建了联系人信息
$module= $_REQUEST['module'];
/**
 * 将唯一判断的字段通过保存方法传递过来，循环做判断，如果有重复的，就停止保存，将结果传递回去
 * @reason 0014245: 客户->客户名称唯一性判断漏洞：创建其他单据->选择该资料->使用快速创建未控制字段唯一性
 * @author Tujt 2015-04-21
 */
if(isset($_REQUEST['fieldonlyfld']) && !empty($_REQUEST['fieldonlyfld'])){
	$fieldonlyfld = trim($_REQUEST['fieldonlyfld'],',');
	$fieldonlyarr = explode(',',$fieldonlyfld);
	include globalStatic::$root_directory.'modules/lingdang/staticlingdang.class.php';
	$ldcls = new staticlingdang();
	$rest = '';
	foreach($fieldonlyarr as $fld){
		if(isset($_REQUEST[$fld]) && !empty($_REQUEST[$fld])){
			$rest = $ldcls->getFieldDuplicateInfo($module,$fld,$_REQUEST[$fld]);
			if('##success##' != $rest) break;
			else $rest = '';
		}
	}
	if(!empty($rest)){
		echo $rest;die;
	}
}//end
$focus = CRMEntity::getInstance($module);
$focus->mode='create';
$field=new Field($module,$adb);
$qcreate_array =$field->QuickCreate();
$qcreate_array=$qcreate_array['data'];
$fieldobj=$focus->fieldobj;
$fieldModules=$fieldobj->getModuleFields();
foreach($qcreate_array as $key=>$value)
{
	if($module == 'Accounts' && $fieldModules[$key]->getTableName() == 'ld_contactdetails' && $saveAccountbyContacts == 0){
		$_REQUEST['contactid'] = '';
		$saveAccountbyContacts = 1;
	}
    $focus->column_fields[$key]=$_REQUEST[$key];
}
if(array_key_exists('currency_id',$focus->column_fields))
{
    //18635: 销售机会>序列表界面： 快速创建的销售机会单据在列表中没有显示币种符号
    $focus->column_fields['currency_id'] = $_REQUEST['currency_id'];
	$currencyobj=Currency::getInstance($adb,$_REQUEST['currency_id']);
	$focus->column_fields['currency_symbol'] = decode_html($currencyobj->getCurrencySymbol());
	$focus->column_fields['conversion_rate'] = $currencyobj->getCurrencyRate();
    $focus->currency_status = true;
}
/**
 * 默认快速创建供应商的负责人为当前用户
 * @reason 0008952 采购订单快速创建供应商，列表中无法查看
 * @author Tujt 2014-05-26
 */
if(!isset($focus->column_fields['assigned_user_id']) || empty($focus->column_fields['assigned_user_id'])){
	$focus->column_fields['assigned_user_id'] = $current_user->id;
}



$focus->save($module);
if(!empty($_REQUEST['detail_quickcreate']) && $_REQUEST['detail_quickcreate'] >= 0){
	$entityarray = getEntitynameInfo(getTabid($module));
	$fieldname = $entityarray['fieldname'];
	$fieldobj=Field::getInstance($module,$adb);
	$columnname=$fieldobj->getFieldInfoBykeyValue('fieldname',$fieldname,'columnname');
	echo '####SUCCESS#####'.$focus->id.'####SUCCESS#####'.$focus->column_fields[$columnname].'####SUCCESS#####'.$_REQUEST['detail_quickcreate'];
    exit();
}
if($module!='Products')
{
  if ($module=='Contacts')
  {
		/**
		 * 判断当前创建客户、联系人，是否为群发邮件、短信界面
		 * @reason 0011795 群发短信界面：联系人、客户选择窗口中快速创建联系人和客户后，没有带出手机、公司电话
		 * @author Tujt 2014-09-28
		 */
	  $uitype = 13;
      $sql='select fieldname,tablename,fieldid from ld_field where tabid=4 and uitype = '.$uitype.' and presence in(0,2) ';
	  if(isset($_REQUEST['qctype']) && $_REQUEST['qctype'] == 'sendSMS'){
		$uitype = 1101;
        $sql='select fieldname,tablename,fieldid from ld_field where tabid=4 and uitype in(11,1101) and presence in(0,2) ';
	  }
    
    $resultfield=$adb->pquery($sql);
    $query_firstname = "select firstname,lastname from ld_contactdetails where contactid=?";
    $result_firstname = $adb->pquery($query_firstname,array($focus->id));
    $lastname = $adb->query_result($result_firstname,0,'lastname');
    for($i=0;$i<$adb->num_rows($resultfield);$i++)
    {
        $fieldname=$adb->query_result($resultfield,$i,'fieldname');
        if(isset($_REQUEST[$fieldname])&&trim($_REQUEST[$fieldname])!='')
        {
            $emails[]=$_REQUEST[$fieldname];
            $emailfieldis[]=$adb->query_result($resultfield,$i,'fieldid');
        }
    }
     echo '####SUCCESS#####'.$focus->id.'####SUCCESS#####'.$lastname.'####SUCCESS#####'.implode(',',$emails).'####SUCCESS#####'.implode(',',$emailfieldis);
  } else if($module == 'Accounts'){
	  	/**
		 * 判断当前创建客户、联系人，是否为群发邮件、短信界面
		 * @reason 0011795 群发短信界面：联系人、客户选择窗口中快速创建联系人和客户后，没有带出手机、公司电话
		 * @author Tujt 2014-09-28
		 */
	  $uitype = 13;
      $sql='select fieldname,tablename,fieldid from ld_field where tabid=6 and uitype='.$uitype.' ';
	  if(isset($_REQUEST['qctype']) && $_REQUEST['qctype'] == 'sendSMS'){
	
        $sql='select fieldname,tablename,fieldid from ld_field where tabid=6 and uitype in(11,1101)  and presence in(0,2)';
	  }
		 
		$resultfield=$adb->pquery($sql);
		 $lastname=getModuleHref('Accounts',$focus->id);
		for($i=0;$i<$adb->num_rows($resultfield);$i++)
		{
			$fieldname=$adb->query_result($resultfield,$i,'fieldname');
			if(isset($_REQUEST[$fieldname])&&trim($_REQUEST[$fieldname])!='')
			{
				$emails[]=$_REQUEST[$fieldname];
				$emailfieldis[]=$adb->query_result($resultfield,$i,'fieldid');
			}
		}
		//获取客户的联系人id和姓名
		$query = 'select contactid,lastname from ld_contactdetails where accountid = ? limit 1';
		$result = $adb->pquery($query,array($focus->id));
		if($adb->num_rows($result) >= 1){
			$contactid = $adb->query_result($result,0,'contactid');
			$contact_lastname =  $adb->query_result($result,0,'lastname');
		}
		 echo '####SUCCESS#####'.$focus->id.'####SUCCESS#####'.$lastname.'####SUCCESS#####'.implode(',',$emails).'####SUCCESS#####'.implode(',',$emailfieldis).'####SUCCESS#####'.$contactid.'####SUCCESS#####'.$contact_lastname;
		 exit();
  }
  else if($module=='Vendors')
  {
    
     $sql='select vendorname from ld_vendor where vendorid=?';
      $result=$adb->pquery($sql,array($focus->id));
      echo '####SUCCESS#####'.$focus->id."####SUCCESS#####".$adb->query_result($result,0,0);
      exit();
  }else if($module == 'Potentials'){
	//0024134: 日程管理：新建界面“销售机会”快速创建时，选择客户后关联带出联系人，保存后客户和联系人字段值没有显示出来
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$focus->list_link_field);
    $tablename=$fieldinfo->getTableName();
    $columnname=$fieldinfo->getColumnName();
   $sql="select $columnname from $tablename  where potentialid=  ".$focus->id;
   $result=$adb->pquery($sql,array());
   $str=$adb->query_result($result,0,0);
	echo '####SUCCESS#####'.$focus->id.'####SUCCESS#####'.$str.'####SUCCESS#####'.$focus->column_fields['contact_id'];
	exit();
  }
  else if($module=='VendorContact')
  {
     $sql='select lastname from ld_vendorcontacts where vendorcontactsid=?';
      $result=$adb->pquery($sql,array($focus->id));
      echo '####SUCCESS#####'.$focus->id.'####SUCCESS#####'.$adb->query_result($result,0,0);
      exit();
  }
  else  
    echo '####SUCCESS#####'.$focus->id;
}
else
{
    /**
     * 更新操作
     * edit:can
     * date:20131228
     * reason:6512: IE8浏览器兼容模式下：采购订单新增界面点击产品产品调用图标，弹出的产品调用窗口中快速创建产品无法保存，点击保存按钮无效
     * */
    global $adb;
	$languageType= getLanguageType($current_user);
	require_once('include/ProductDetails/ProductToolFields.php');
    $fieldobj=Field::getInstance('Products',$adb);
    
   	$tabid = getTabid($_REQUEST['frommodule']);
 
	$producttoolfields =  new ProductToolFields($_REQUEST['frommodule']);
	$producttoolfieldInfo = $producttoolfields->getModuleProductToolField($tabid,$languageType);
	//获取明细界面显示的产品字段信息
    $pro_tmp=0;
	foreach($producttoolfieldInfo as $key => $productfield){
	   //17085: 入库单新增界面：快速创建保存产品后，并没有把产品名称给带过来
		if(($productfield->getTableName() == 'ld_products'||$productfield->getTableName() == 'ld_productcf') ){
			$product_Fields=$fieldobj->getFieldInfoBykeyValue('fieldname',$productfield->getColumnName(),'columnname');
            
            if(!empty($product_Fields))
            {
                $proField[] = $product_Fields;
              
            }
                
            
		}
	}
   
    $entity_id=$focus->id;
					//To get all the tax types and values and pass it to product details
    $tax_str = '';
    $tax_details = getAllTaxes();
    
    for ($tax_count = 0; $tax_count < count($tax_details); $tax_count++) 
    {
        $tax_str .= $tax_details[$tax_count]['taxname'] . '=' . $tax_details[$tax_count]['percentage'] . ',';
    }
    $tax_str = trim($tax_str, ',');
   
    $sql='select ld_products.* ,ld_productcf.*, ld_crmentity.*,ld_users.last_name as smownername from ld_products inner join  ld_crmentity on ld_crmentity.crmid=ld_products.productid
         left join ld_productcf on ld_productcf.productid=ld_products.productid
         inner join ld_users on ld_users.id=ld_products.smownerid
         where ld_products.productid=?';
    
    $proresult=$adb->pquery($sql,array($focus->id));//获取快速创建后的产品信息
    $product_id=$focus->id;
    $product_name='';
    $unitprice='0.00';
    $desc='$$@';
    $subprod_id='::';
    $pro_all='';
    if($adb->num_rows($proresult)>0)
    {   $product_name=$adb->query_result($proresult,0,'productname');
        $unitprice=$adb->query_result($proresult,0,'unit_price');
		$costprice=$adb->query_result($proresult,0,'costprice');
        $desc=$adb->query_result($proresult,0,'description');
        if($desc=='')
        {
            $desc='$$@';
        }
        
        for($j=0;$j<sizeof($proField);$j++)
        {
            if(strtolower($proField[$j])=='prosmownerid')
            {
                $pro_all[]=$proField[$j].":'".$adb->query_result($proresult,0,'smownername')."'";
                continue;
            }
            if(strtolower($proField[$j])=='promodifiedby')
            {
                $pro_all[]=$proField[$j].":'".$current_user->last_name."'";
                continue;
            }
            if(strtolower($proField[$j])=='smcreatorid')
            {
                $pro_all[]=$proField[$j].":'".$current_user->last_name."'";
                continue;
            }
            //由于字段是可以自定义的，我这样做是有问题，
            //目前没有时间，应该通过uitype=56判断
            if(strtolower($proField[$j])=='discontinued')
            {
                if($adb->query_result($proresult,0,$proField[$j])==1)
                {
                    $pro_all[]=$proField[$j].':\'是\'';
                }
                else
                {
                     $pro_all[]=$proField[$j].':\'否\'';
                }
                continue;
            }
           
            $pro_all[]=$proField[$j].":'".$adb->query_result($proresult,0,$proField[$j])."'";
           
        }
        $pro_all[]="hdnProductId:'".$product_id."'";
    }
    //15734: 服务合同-新增：产品名称-选择产品窗口快速创建产品后没有带出产品名称
	//0022431: 采购订单新增界面：快速创建产品名称，结果“不含税单价”字段值没有取【参考成本价】字段值
	if($costprice > 0 && ($_REQUEST['frommodule'] == 'Stock'||$_REQUEST['frommodule']=='PurchaseOrder'||$_REQUEST['frommodule']=='PurchaseBack'||$_REQUEST['frommodule']=='PurchaseInvoice')){
		$pro_all[]="listprice:'".$costprice."'";
		$pro_all[]="taxprice:'".$costprice."'";
	}else{
		$pro_all[]="listprice:'".$unitprice."'";
		$pro_all[]="taxprice:'".$unitprice."'";
	}
    //bug:22135 edit:cyb date 2016-06-06
    $quantity=1;
    $quantity=setNumberFormat($quantity,2);
    $pro_all[]="quantity:'".$quantity."'";
	$pro_all[] = "productname:'".$product_name."'";
    $pro_all='{'.implode(',',$pro_all).'}';
    if(trim($pro_all,',')=='')
    {
        $pro_all='$$@';
    }
    $retstr=$product_id.'###'.$product_name.'###'.$unitprice.'###'.$tax_str.'###'.$desc.'###'.$pro_all;
      echo '####SUCCESS#####'.$retstr;
    unset($adb);
}

exit();
?>