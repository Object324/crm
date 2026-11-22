<?php


global $adb;

global $currentModule;
$modObj = CRMEntity::getInstance($currentModule);

$ajaxaction = $_REQUEST["ajxaction"];
if($ajaxaction == "DETAILVIEW")
{
    crm_load_class_file("DetailViewAjaxSave",'data');
     $crmid = $_REQUEST["recordid"];
     $tablename = $_REQUEST["tableName"];
     $fieldname = $_REQUEST["fldName"];
     $fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($currentModule,$crmid,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $DetailViewAjaxSaveobj->setEcho();
     //
//	$crmid = $_REQUEST["recordid"];
//	$tablename = $_REQUEST["tableName"];
//	$fieldname = $_REQUEST["fldName"];
//	$fieldvalue = utf8RawUrlDecode($_REQUEST["fieldValue"]); 
//	if($crmid != "")
//	{
//	    if($fieldname=='sostatus')
//        {
//            $_REQUEST["sostatus_mass_edit_check"]=$fieldvalue;
//            $modObj->massEdit_save_before('CustomForm11',array($crmid));
//        }
//		$modObj->retrieve_entity_info($crmid,"CustomForm11");
//		$modObj->column_fields[$fieldname] = $fieldvalue;
//		$modObj->id = $crmid;
//		$modObj->mode = "edit";
//		$modObj->save("CustomForm11");
//        /**
//         * edit:cyb
//         * date:2016-06-20
//         * reason:基金行业，合同订单新增或者编辑保存时，生成产品份额交易历
//        **/
//         $trades=getVersionTradeInfo();//获取数据库版本（了解属于什么行业）
//         $tradename=ucwords($trades['trade']);//将字符串首字母转化成大写
//         if(!empty($tradename)&&file_exists('include/trade/'.$tradename.'/'.$tradename.'_CustomForm11.php'))
//         {                   
//            require_once('include/trade/'.$tradename.'/'.$tradename.'_CustomForm11.php');
//            $trade_class_name=$tradename.'_CustomForm11';   
//            if(class_exists($trade_class_name))     
//            {
//               
//               $trade_focus=new $trade_class_name($modObj); 
//               if(method_exists($trade_focus,"Redemption_save"))
//               {         
//                  $trade_focus->Redemption_save($modObj->id);
//               }
//            } 
//         }
//		if($modObj->id != "")
//		{
//		  if($_SESSION[globalStatic::$session_prevfix_bol."popup_finance_dividendorder"]=='yes' && vtlib_isModuleActive('DividendOrder'))
//          {
//            unset($_SESSION[globalStatic::$session_prevfix_bol."popup_finance_dividendorder"]);
//            echo ":#:SUCCESS##POPCREATEDIVIDENDORDER";
//          }
//		  else
//          {
//            echo ":#:SUCCESS";
//          }	
//		}else
//		{
//			echo ":#:FAILURE";
//		}   
//	}else
//	{
//		echo ":#:FAILURE";
//	}
}elseif($ajaxaction == "LOADRELATEDLIST" || $ajaxaction == "DISABLEMODULE") {
	require_once 'include/ListView/RelatedListViewContents.php';
}
?>