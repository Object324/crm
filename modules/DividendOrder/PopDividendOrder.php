<?php
global $adb;
global $current_user;
$newfolder='';
require('user_privileges/user_language_'.$current_user->id.'.php');
require('modules/DividendOrder'.$newfolder.'/DividendParent.php');

require_once('modules/DividendOrder/DividendOrder.php');
$frommodule = 'SalesOrder';
$focus = CRMEntity::getInstance($frommodule);

$smarty = new lingdangCRM_Smarty;
$header=array('startdate'=>getFixedLabel('STARTDATE'),'enddate'=>getFixedLabel('ENDDATE'),'days'=>getFixedLabel('INTERESTSDAYS'),
                'rate_senddate'=>getFixedLabel('INTERESTPAYMENTDATE'),'capital'=>getFixedLabel('PRINCIPAL'),'rate'=>getFixedLabel('INTEREST'),
                  'float_income'=>getFixedLabel('FLOATINCOME'),'dividendmoney'=>getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT'),'have_float'=>'no'  );
if(!empty($_REQUEST['salesorderid'])){
	$focus->id = $_REQUEST['salesorderid'];
    $smarty->assign("SALESORDERID",$focus->id);
    $account_field_obj=$focus->fieldobj->getFieldInfoobjBykey('columnname','accountid');
    if(!$account_field_obj)
    {
        exit() ;
    }
	$focus->retrieve_entity_info($_REQUEST['salesorderid'],$frommodule);
    if(!array_key_exists('start_date',$focus->column_fields))
    {
      
        echo getFixedLabel('STARTDATENOTCREATEDIVIDENDORDER').'##NORULES##no##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
        exit();
    }
    if($focus->column_fields['start_date']==''||$focus->column_fields['start_date']<='1600-01-01')
    {
       
         echo getFixedLabel('STARTDATEEMPTYNOTCREATEDIVIDENDORDER').'##NORULES##no##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
         exit();
    }
  
    
    if(!array_key_exists('end_date',$focus->column_fields))
    {
       
        echo getFixedLabel('ENDDATENOTCREATEDIVIDENDORDER').'##NORULES##no##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
        exit();
    }
    if($focus->column_fields['end_date']==''||$focus->column_fields['end_date']<='1600-01-01')
    {
        
         echo getFixedLabel('ENDDATEEMPTYNOTCREATEDIVIDENDORDER').'##NORULES##no##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
         exit();
    }
    
   
    if(!array_key_exists('fixed_rate',$focus->column_fields))
    {
       
        echo getFixedLabel('FIXEDRATENOTCREATEDIVIDENDORDER').'##NORULES##no##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
        exit();
    }
    if($focus->column_fields['fixed_rate']==''||$focus->column_fields['fixed_rate']<=0)
    {
      
         echo getFixedLabel('FIXEDRATEEMPTYNOTCREATEDIVIDENDORDER').'##NORULES##no##NORULES##'.getFixedLabel('LBL_Creates').getTranstab('DividendOrder');
         exit();
    }
     /* gyq_09 派息规则赋值数组 */
    require_once('modules/DividendOrder/cls_Dividend_rules.php');
    $detailtable=$focus->Detail_table;
    $sql='select productid from '. $detailtable.' where id='.$focus->id;
    $result=$adb->pquery($sql,array());
  
    $productid=$adb->query_result($result,0,0);
    $Dividend_rules = DividendRules::getInstance($productid);

    $smarty->assign('DIVIDENDRULES',$Dividend_rules->Salesorder_DividendRules());
   

  
    $smarty->assign("ACCOUNTID",$focus->column_fields[$account_field_obj->getFieldName()]);
	$salesorderid = $_REQUEST['salesorderid'];
	//获取所有币种
	$currencyobj=Currency::getInstance($adb);
	$allCurrencies = $currencyobj->getAllCurrencies();
    $rate_type_focus=DividendParent::getInstance($focus);
     
     if($_REQUEST['type']=='detail')//明细界面重算
     {
        $json_array=$rate_type_focus->Recalculate();//该函数DividendParent.php中
        $json_array['hide_objs']=$rate_type_focus->hide_dividendObjs;
        if($rate_type_focus->float_income=='all')
        {
             $header['have_float']='yes';
        }
        $json_array['header']=$header;
        echo json_encode($json_array);
        exit();
     }
   
    $productid = $rate_type_focus->salesorder_productdetail_obj[0]['productid']->getColumn_Value();

   

    $smarty->assign('RATETYPE',$rate_type_focus->rate_type);//计息方式

   
    $smarty->assign("PRODUCTID",$rate_type_focus->salesorder_productdetail_obj[0]['productid']->getColumn_Value());
    $smarty->assign('START_RATE_DATE',$rate_type_focus->getStart_Rate_date());//开始计息日期
   //获取派息单负责人
	$assigned_user_id = $rate_type_focus->getSmownerid();
    
    $smarty->assign("SMOWNERID",$assigned_user_id);
	$user_arr=get_user_array(FALSE, "Active", $assigned_user_id);
	$users_combo = get_select_options_array($user_arr, $assigned_user_id);
	if(!array_key_exists($assigned_user_id,$users_combo)){
	 $users_combo[$assigned_user_id]=array(getOwnerName($assigned_user_id)=>'selected');
	}
	//获取投资金额
   	$salestotal = $rate_type_focus->getInvestment_Amount();
    $smarty->assign("INVENSTAMOUNT",$salestotal);
   	$smarty->assign('SALESTOTAL',setNumberFormat($salestotal,2));
	$smarty->assign('HTML',$rate_type_focus->getDividendDetail());//派息单明细
 
   
    $smarty->assign("HIDE_DIVIDENDOBJS", json_encode($rate_type_focus->hide_dividendObjs));
    if($rate_type_focus->float_income=='all')
    {
         $header['have_float']='yes';
    }

    $smarty->assign("DETAIL_TABLE_HEADER", json_encode($header));
    $smarty->assign("HIDE_HTML",$rate_type_focus->hide_htmltable);
	$smarty->assign('ISADMIN',$current_user->is_admin);
	$smarty->assign('currencyid',$rate_type_focus->getCurrencyId());//订单币种
	$smarty->assign('USERS',$users_combo);
	
	$smarty->assign('CURRENCY',$allCurrencies);
    //投资到期日
    $smarty->assign('INVESTMENT_ENDDATE',$rate_type_focus->getInvestment_Enddate());
    $fixed_rate_obj=$focus->fieldobj->getFieldInfoobjBykey('columnname','fixed_rate');
    
    if($fixed_rate_obj)
    {
        $fieldLabel=$fixed_rate_obj->getFieldLabelKey();
        $smarty->assign('FIXED_RATE_LABEL',$fieldLabel);
    }
    //$smarty->assign('DIVIDENDORDERCHANGEDMUSTSAVE',getFixedLabel('DIVIDENDORDERCHANGEDMUSTSAVE'));
    $smarty->display("PopDividendOrder.tpl");
}









?>