<?php
require('modules/DividendOrder/DividendParent.php');
require_once(globalStatic::$root_directory."modules/DividendOrder/DividendOrder.php");
if(isset($root_directory))//防止站点攻击
{
  
    if($_REQUEST['type']&&$_REQUEST['type']=='list')//列表重新计算利息
    {
        
        global $adb;
        $deployarray=getSys_deploy(67);
        $max_select_rows=$deployarray['deploy_value'];//系统参数批量操作最大记录数据
        $_REQUEST['mass_batch_num_all']=$max_select_rows;
         $data_scope=$_REQUEST['data_scope'];
         if($data_scope=="1")
         {
            //重算搜索结果
           $salesorderids= getSelectedRecords($_REQUEST,'SalesOrder','all',$excludedRecords);
            
            $_REQUEST['dividendorderids']=implode(';',$salesorderids);
            
            
         }
       
       
        $have_rate_total=array();//已认购金额（同一客户和产品）
        $ids=explode(";",$_REQUEST['dividendorderids']);
        $ids=array_filter($ids);//删除空格
        $ids=implode(";",$ids);
        $ids=explode(";",$ids);
     
        foreach($ids as $id)
        {
            $focus=CRMEntity::getInstance('SalesOrder');
            $focus->id=$id;
            $focus->retrieve_entity_info($id,"SalesOrder");
            if((array_key_exists('start_date',$focus->column_fields)&&array_key_exists('end_date',$focus->column_fields)&&array_key_exists('fixed_rate',$focus->column_fields))&&
            ($focus->column_fields['start_date']!=''&&$focus->column_fields['end_date']!=''&&$focus->column_fields['fixed_rate']>0))
            {
            
                    $rate_type_focus=DividendParent::getInstance($focus);
                    if(empty($rate_type_focus))
                        continue;
                    
                    $rate_type_focus->get_account_product_id();
                    $accountid=$rate_type_focus->accountid;
                    $productid=$rate_type_focus->productid;
                    if($rate_type_focus->dividend_rules['formulacaptial']=='totalsubscription')//已认购金额
                    {
                        
                        if(array_key_exists($accountid.'_'.$productid,$have_rate_total))
                        {
                            //已认购金额相同的客户和产品只计算一次就可以了
                            continue;
                        }
                        
                        $have_rate_total[$accountid.'_'.$productid]=0;
                    }
                    $rate_type_focus->Recalculate();//该函数DividendParent.php中
                    $i=1;
                    $_REQUEST['dividend_accountid']=$accountid;
                    $_REQUEST['dividend_productid']=$productid;
                    $_REQUEST['dividend_salesorderid']=$focus->id;
                    $_REQUEST['sel_smownerid']=$rate_type_focus->getSmownerid();
                
                    foreach($rate_type_focus->show_dividendObjs as $dividendorderobj)
                    {
                        $_REQUEST[$rate_type_focus->startdate_bol.$i]=$dividendorderobj->getStartDate();
                       
                        $_REQUEST[$rate_type_focus->enddate_bol.$i]=$dividendorderobj->getEndDate();
                        $_REQUEST[$rate_type_focus->rate_days_bol.$i]=$rate_type_focus->formula_obj->getDiffDays($dividendorderobj->getStartDate(),$dividendorderobj->getEndDate());
                        $_REQUEST[$rate_type_focus->rate_sendday_bol.$i]=$dividendorderobj->getRate_senddate();
                        $_REQUEST[$rate_type_focus->investment_amount_bol.$i]=$dividendorderobj->getPrincipal();
                        $_REQUEST[$rate_type_focus->rate_hidden_money_bol.$i]=$dividendorderobj->getRate_money();
                        $_REQUEST[$rate_type_focus->txt_row_bol.$i]=0;
                        $_REQUEST[$rate_type_focus->dividend_money_bol.$i]=$dividendorderobj->getDividend_money();
                        $_REQUEST[$rate_type_focus->float_income_bol.$i]=$dividendorderobj->getFloat_income();
                        $_REQUEST[$rate_type_focus->hidden_dividend_status.$i]=$dividendorderobj->getStatus();
                        $i++;
                    }
                     $show_request_count=$i;
                    $i=1;
                    foreach($rate_type_focus->hide_dividendObjs as $dividendorderobj)
                    {
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->startdate_bol.$i]=$dividendorderobj->getStartDate();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->enddate_bol.$i]=$dividendorderobj->getEndDate();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->rate_days_bol.$i]=$rate_type_focus->formula_obj->getDiffDays($dividendorderobj->getStartDate(),$dividendorderobj->getEndDate());
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->rate_sendday_bol.$i]=$dividendorderobj->getRate_senddate();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->investment_amount_bol.$i]=$dividendorderobj->getPrincipal();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->rate_hidden_money_bol.$i]=$dividendorderobj->getRate_money();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->txt_row_bol.$i]=0;
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->dividend_money_bol.$i]=$dividendorderobj->getDividend_money();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->float_income_bol.$i]=$dividendorderobj->getFloat_income();
                        $_REQUEST[$rate_type_focus->hide_detail.$rate_type_focus->hidden_dividend_status.$i]=$dividendorderobj->getStatus();
                        $i++;
                    }
                     $hide_request_count=$i;
                   $rate_type_focus->save();
                   $_REQUEST=array();//重新初始化
           }
        }
        
        
       header("Location:index.php?module=SalesOrder&action=index");
    }
    $days_method=$_REQUEST['days_method'];//天数计算方法
    $rate_senddatetype=$_REQUEST['rate_senddatetype'];//利息发放日
    $float_income=$_REQUEST['float_income'];
    if(empty($ratetype))
    {
        $ratetype="rate_havetotal";
    }
    

    $focus=CRMEntity::getInstance('SalesOrder');
   
    $focus->id=$_REQUEST['dividend_salesorderid'];
    $focus->retrieve_entity_info($focus->id,"SalesOrder");
    $rate_type_focus=DividendParent::getInstance($focus);

    $rate_type_focus->save();
    
    if($_REQUEST['pagetype']=='detail')
    {
		$_REQUEST['diony']='yes';
		ConvertTojsonString(1,array(),"success");
       // header("Location:index.php?module=SalesOrder&action=DetailView&record=".$focus->id);
    }
    else//批量编辑
    {
        
    }
}
else
{
    exit('www');
}




?>