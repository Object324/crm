<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$mod_strings;
$smarty=new lingdangCRM_Smarty();
if(function_exists('crm_load_class_file'))
    crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
if(isset($_REQUEST['year']))
{
    if(is_int(intval($_REQUEST['year']))==false)
    {
        echo '报表年份错误！';
        exit();
    }
    if($_REQUEST['year']!=''){
        $year = $_REQUEST['year'];
    }else{
        $year = date('Y',time());
    }

}

$reportname=$_REQUEST['name'];
$Report_form_query=$_REQUEST['Report_form_query'];
if($Report_form_query == 'true')
{
    $begin_end_date_arr=explode(' ',$_REQUEST['begin_date']);            
    $begin_date=trim($begin_end_date_arr[0]);
    $begin_dates=explode('-',$_REQUEST['begin_date']);
    $begin_month=$begin_dates[1];
    $end_date=trim($begin_end_date_arr[2]);
    $end_dates=explode('-',$end_date);
    $end_month=$end_dates[1];
    $_REQUEST['month']=$end_month;
    $_REQUEST['year']=$end_dates[0];
}
else
{ 
    $begin_month=1;$end_month=12;
    if($reportname=='SNOWBEARRPSL')
        $begin_month=date('m');$end_month=date('m');
    $begin_date = "";
    $begin_date = "".$year."-".formatMonth($begin_month)."-01"; 
    if($reportname=='SNOWBEARRPSL')
        $begin_date = "".$year."-".$begin_month."-01"; 
    $end_date = "";
    $lastday=getthemonth($year."-".$end_month.'-1');
    $arrlastday=explode('-',$lastday);
    $lastday=$arrlastday[2];
    $end_date = "".$year."-".formatMonth($end_month)."-".$lastday;
    if($reportname=='SNOWBEARRPSL')
        $end_date = "".$year."-".$end_month."-".$lastday;
}
$smarty->assign("begin_date",$begin_date);
$smarty->assign("end_date",$end_date);
$begin_end_date='';
$begin_end_date.=$begin_date.' '.'-'.' '.$end_date;
$smarty->assign("begin_end_date",$begin_end_date);
$smarty->assign("Report_form_query",$Report_form_query);
$smarty->assign("year",$year);
/*
$dependentPicklists = lingdang_DependencyPicklist::getPickListDependency('Accounts','bill_country','bill_state');
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource('Accounts');
*/

switch($reportname)
        {
            case 'SNOWBEARRPISP':   //维修点配件发放汇总表
                $ProductName=$_REQUEST['ProductName'];
                $ApplicableModel=$_REQUEST['ApplicableModel'];
                $ProductCategories=$_REQUEST['ProductCategories'];
                $procatlist=getProductCategories();
                $productcategorylist=getproductcategory2();
                $smarty->assign("count_num",count($productcategorylist));
                $smarty->assign("productcategorylist",$productcategorylist);
                $smarty->assign("procatlist",$procatlist);
                if($ProductName!=''){
                    $whereProductNameSQL = " AND ld_products.productsheet like '%$ProductName%' ";
                    $smarty->assign("ProductName",$ProductName);
                }
                if($ApplicableModel!=''){
                    $whereModelSQL = " AND ld_products.productname like '%$ApplicableModel%' ";
                    $smarty->assign("ApplicableModel",$ApplicableModel);
                }
                if($ProductCategories!=''){
                    $whereProductCategoriesSQL = " AND ld_productcf.cf_1424 = '$ProductCategories' ";
                    $smarty->assign("ProductCategories",$ProductCategories);
                }
               
                $approvalSales=1;
                if($_REQUEST['approvalSales']!=1&&$_REQUEST['opentype']!='yes'){
                   $whereAppSQL = " AND ld_salesorder.approvestatus='".constant('D_A_S_APPROVED')."' ";
                   $approvalSales = '';
                }
                $search_text=$_REQUEST['search_text'];
                if($search_text!=''){
                    $prolisgs = explode(',',$search_text);
                    $prolisg = implode("','",$prolisgs);
                    $whereProductCategoriesSQL2 = " AND ld_products.productcategory in ('$prolisg') ";
                    $smarty->assign("receiverid",$search_text);
                    $smarty->assign("receiverid_array",$prolisgs);
                }
                $smarty->assign("approvalSales",$approvalSales);
                $listValue = getSnowBearRPOSP($year,$whereProductNameSQL,$whereModelSQL,$whereAppSQL,$whereProductCategoriesSQL,$whereProductCategoriesSQL2);
                $listValue_header=array(
                '配件名称','产品类别','成本价','说明','适用型号',
                '1月','2月','3月','4月','5月','6月','7月','8月','9月','10月','11月','12月',
                '合计','金额'
                );
              break;  
              
              case 'SNOWBEARRPSL':       //修点配件申请明细表   
              $SRPN=$_REQUEST['SRPN'];
              $ProductName=$_REQUEST['ProductName'];
              $ProductCategories=$_REQUEST['ProductCategories'];
              $EXPLAIN=$_REQUEST['EXPLAIN'];
              $CONTRACTNO=$_REQUEST['CONTRACTNO'];
              $ApplicableModel=$_REQUEST['ApplicableModel'];
              $procatlist=getProductCategories();
              $smarty->assign("procatlist",$procatlist);
              $productcategorylist=getproductcategory2();
                $smarty->assign("count_num",count($productcategorylist));
                $smarty->assign("productcategorylist",$productcategorylist);
              if($SRPN!=''){
                $whereSRPNNameSQL = " AND ld_account.accountname like '%$SRPN%' ";
                $smarty->assign("SRPN",$SRPN);
              }
              if($CONTRACTNO!=''){
                $whereCONTRACTNOameSQL = " AND ld_salesorder.salesorder_no like '%$CONTRACTNO%' ";
                $smarty->assign("CONTRACTNO",$CONTRACTNO);
              }
              if($ProductCategories!=''){
                $whereProductCategoriesSQL = " AND ld_productcf.cf_1424 = '$ProductCategories' ";
                $smarty->assign("ProductCategories",$ProductCategories);
              }
              if($ProductName!=''){
                $whereProductNameSQL = " AND ld_products.productsheet like '%$ProductName%' ";
                $smarty->assign("ProductName",$ProductName);
              }
              if($ApplicableModel!=''){
                $whereModelSQL = " AND ld_products.productname like '%$ApplicableModel%' ";
                $smarty->assign("ApplicableModel",$ApplicableModel);
              }
              if($EXPLAIN!=''){
                $whereEXPLAINSQL = " AND ld_productcf.cf_1425 like '%$EXPLAIN%' ";
                $smarty->assign("EXPLAIN",$EXPLAIN);
              }
              
               $approvalSales=1;
              if($_REQUEST['approvalSales']!=1&&$_REQUEST['opentype']!='yes'){
                   //$whereAppSQL = " AND ld_salesorder.approvestatus='".constant('D_A_S_APPROVED')."' ";
                   $approvalSales = '';
              }
              $search_text=$_REQUEST['search_text'];
              if($search_text!=''){
                    $prolisgs = explode(',',$search_text);
                    $prolisg = implode("','",$prolisgs);
                    $whereProductCategoriesSQL2 = " AND ld_products.productcategory in ('$prolisg') ";
                    $smarty->assign("receiverid",$search_text);
                    $smarty->assign("receiverid_array",$prolisgs);
                }
              $smarty->assign("approvalSales",$approvalSales);
              $listValue = getSnowBearPeijianminxi($begin_date,$end_date,$whereSRPNNameSQL,$whereCONTRACTNOameSQL,$whereProductNameSQL,$whereModelSQL,$whereEXPLAINSQL,$whereAppSQL,$whereProductCategoriesSQL,$whereProductCategoriesSQL2);
              $listValue_header=array(
                '申请日期','特约维修点名称','说明','配件名称','产品类别','适用型号','计量单位','数量','出货价','金额'
                );
              break;
              
              case 'SNOWBEARHNSRSR':    
                    $dependentPicklists = lingdang_DependencyPicklist::getPickListDependency('Accounts','bill_country','bill_state');
                    $picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource('Accounts');
                    $citty = $dependentPicklists['valuemapping'];
                    array_pop($citty);array_shift($citty);
                    foreach($citty as $key=>$arr){
                        $cticty[$arr['sourcevalue']] = array_flip($arr['targetvalues']);
                    }
                    foreach($cticty as $key=>$arr){
                        foreach($arr as $key2=>$arr2){
                           $cticty[$key][$key2]= $picklistDependencyDatasource->bill_state->$key2->bill_city;
                        }
                    }
                    foreach($cticty as $key=>$arr){
                        $count=0;
                        foreach($arr as $key2=>$arr){
                            //array_shift($cticty[$key][$key2]);
                            $cticty[$key][$key2]['counts']=count($arr)-1;
                            $count+=(count($arr)-1);
                        }
                          $cticty[$key]['ROWcounts']=$count;
                    }
                $cticty['']=array(''=>array(''=>'合计：'));
                $smarty->assign("cticty",$cticty);    
              $listValue = getSnowBearSNOWBEARHNSRSR($year);
              break;
              
            case 'Customercomplaintanalysisreport':         //客诉汇总表
                $procatlist=getproductcategory2();
                $serieslist=getProductseries();
                $productsheetlist=getproductsheet();
                $AOTABRlist=getAOTABR();
                $search_text=$_REQUEST['search_text'];
                $search_text2=$_REQUEST['search_text2'];
                $search_text3=$_REQUEST['search_text3'];
                $search_text4=$_REQUEST['search_text4'];
                if($search_text!=''){
                    $prolisgs = explode(',',$search_text);
                    $prolisg = implode("','",$prolisgs);
                    $whereProductCategoriesSQL = " AND ld_products.productcategory in ('$prolisg') ";
                    $smarty->assign("receiverid",$search_text);
                    $smarty->assign("receiverid_array",$prolisgs);
                }
                if($search_text2!=''){
                    $prolisgs2 = explode(',',$search_text2);
                    $prolisg2 = implode("','",$prolisgs2);
                    $whereProductseriesSQL = " AND ld_productcf.cf_1406 in ('$prolisg2') ";
                    $smarty->assign("receiverid2",$search_text2);
                    $smarty->assign("receiverid_array2",$prolisgs2);
                }
                if($search_text3!=''){
                    $whereproductsheetSQL = " AND ld_products.productname like '%$search_text3%' ";
                    $smarty->assign("receiverid3",$search_text3);
                }
                if($search_text4!=''){
                    $prolisgs4 = explode(',',$search_text4);
                    $prolisg4 = implode("','",$prolisgs4);
                    $whereAOTABRSQL = " AND ld_quotescf.cf_1419 in ('$prolisg4') ";
                    $smarty->assign("receiverid4",$search_text4);;
                    $smarty->assign("receiverid_array4",$prolisgs4);
                }
                $smarty->assign("count_num",count($procatlist));
                $smarty->assign("productlist",$procatlist);
                $smarty->assign("Acolum_num",count($serieslist));
                $smarty->assign("serieslist",$serieslist);
                $smarty->assign("Sector_num",count($productsheetlist));
                $smarty->assign("productsheetlist",$productsheetlist);
                $smarty->assign("Salesman_num",count($AOTABRlist));
                $smarty->assign("AOTABRlist",$AOTABRlist);              
                $smarty->assign("uPRODUCTS",$search_text);
                $smarty->assign("uCustomer",$_REQUEST['search_text2']);
                $smarty->assign("uSector",$_REQUEST['search_text3']);
                $smarty->assign("uSalesman",$_REQUEST['search_text4']);
                $listValue = getSnowBearSNOWBEARCCAR($begin_date,$end_date,$whereProductCategoriesSQL,$whereProductseriesSQL,$whereproductsheetSQL,$whereAOTABRSQL);
            break;
              
            case 'Sbpccs':  
            $listValue = getSnowBearSbpccs($year);
            break;
            
            case 'Returnamountregionaldatasummaryreport':  
            $accounttype=getaccounttype();
            $cf_1475=getcf_1475();
            $smarty->assign("accounttype",$accounttype);
            $smarty->assign("cf_1475",$cf_1475);
                $admissibilitytype=$_REQUEST['admissibilitytype'];
              $Customercategory=$_REQUEST['Customercategory'];
              $AccountName=$_REQUEST['AccountName'];
              if($AccountName!=''){
                $AccountNameSQL = " AND ld_account.accountname like '%$AccountName%' ";
                $smarty->assign("AccountName",$AccountName);
              }
              if($Customercategory!=''){
                $CustomercategorySQL = " AND ld_account.account_type like '%$Customercategory%' ";
                $smarty->assign("Customercategory",$Customercategory);
              }
              if($admissibilitytype!=''){
                $admissibilitytypeSQL = " AND ld_projectcf.cf_1475 like '%$admissibilitytype%' ";
                $smarty->assign("admissibilitytype",$admissibilitytype);
              }
            $listValue = getSnowBearraordsr($year,$CustomercategorySQL,$admissibilitytypeSQL,$AccountNameSQL);
           break;
           
           case 'Returnnumberregionaldatasummaryreport':    //退换货数量区域汇总分析表 
            $accounttype=getaccounttype();
            $cf_1475=getcf_1475();
            $ProductCategories=getproductcategory2();
            $Productseries=getProductseries();
            $smarty->assign("accounttype",$accounttype);
            $smarty->assign("cf_1475",$cf_1475);
            $smarty->assign("ProductCategories",$ProductCategories);
            $smarty->assign("Productseries",$Productseries);
            $admissibilitytype=$_REQUEST['admissibilitytype'];
            $Customercategory=$_REQUEST['Customercategory'];
            $cf_1424=$_REQUEST['cf_1424'];
            $cf_1406=$_REQUEST['cf_1406'];
            $Containsapprovaldocument=$_REQUEST['Containsapprovaldocument'];
            $Accountname=$_REQUEST['Accountname'];
              if($Customercategory!=''){
                $CustomercategorySQL = " AND ld_account.account_type like '%$Customercategory%' ";
                $smarty->assign("Customercategory",$Customercategory);
              }
              if($admissibilitytype!=''){
                $admissibilitytypeSQL = " AND ld_projectcf.cf_1475 like '%$admissibilitytype%' ";
                $smarty->assign("admissibilitytype",$admissibilitytype);
              }
              if($cf_1424!=''){
                $ProductCategoriesSQL = " AND ld_product.productcategory = '$cf_1424' ";
                $smarty->assign("cf_1424",$cf_1424);
              }
              if($cf_1406!=''){
                $ProductseriesSQL = " AND ld_productcf.cf_1406 like '%$cf_1406%' ";
                $smarty->assign("cf_1406",$cf_1406);
              }
              if($Containsapprovaldocument!=''){
                $ContainsapprovaldocumentSQL = " AND ld_products.productname like '%$Containsapprovaldocument%' ";
                $smarty->assign("Containsapprovaldocument",$Containsapprovaldocument);
              }
              if($Accountname!=''){
                $AccountnameSQL = " AND ld_account.accountname like '%$Accountname%' ";
                $smarty->assign("Accountname",$Accountname);
              }
            $listValue = getSnowBearrnordsr($year,$CustomercategorySQL,$admissibilitytypeSQL,$ProductCategoriesSQL,$ProductseriesSQL,$ContainsapprovaldocumentSQL,$AccountnameSQL);
           break;
           
           case 'Productcustomerservicenumberfailurestatistics':    //产品售后故障分析表 
              $procatlist=getproductcategory2();
              $serieslist=getProductseries();
              $productsheetlist=getproductsheet();
              $AOTABRlist=getcf_1476();
              $cf_1475=getcf_1475();
              $search_text=$_REQUEST['search_text'];
              $search_text2=$_REQUEST['search_text2'];
              $search_text3=$_REQUEST['search_text3'];
              $search_text4=$_REQUEST['search_text4'];
              $search_text5=$_REQUEST['search_text5'];
              if($search_text!=''){
                    $prolisgs = explode(',',$search_text);
                    $prolisg = implode("','",$prolisgs);
                    $whereProductCategoriesSQL = " AND ld_products.productcategory in ('$prolisg') ";
                    $smarty->assign("receiverid",$search_text);
                    $smarty->assign("receiverid_array",$prolisgs);
                }
                if($search_text2!=''){
                    $prolisgs2 = explode(',',$search_text2);
                    $prolisg2 = implode("','",$prolisgs2);
                    $whereProductseriesSQL = " AND ld_productcf.cf_1406 in ('$prolisg2') ";
                    $smarty->assign("receiverid2",$search_text2);
                    $smarty->assign("receiverid_array2",$prolisgs2);
                }
                if($search_text3!=''){
                    $whereproductsheetSQL = " AND ld_products.productname like '%$search_text3%' ";
                    $smarty->assign("receiverid3",$search_text3);
                }
                if($search_text4!=''){
                    $prolisgs4 = explode(',',$search_text4);
                    $prolisg4 = implode("','",$prolisgs4);
                    $whereAOTABRSQL = " AND ld_projectcf.cf_1476 in ('$prolisg4') ";
                    $smarty->assign("receiverid4",$search_text4);;
                    $smarty->assign("receiverid_array4",$prolisgs4);
                }
                if($search_text5!=''){
                    $prolisgs5 = explode(',',$search_text5);
                    $prolisg5 = implode("','",$prolisgs5);
                    $whereprolisg5SQL = " AND ld_projectcf.cf_1475 in ('$prolisg5') ";
                    $smarty->assign("receiverid5",$search_text5);;
                    $smarty->assign("receiverid_array5",$prolisgs5);
                }
                $smarty->assign("count_num",count($procatlist));
                $smarty->assign("productlist",$procatlist);
                $smarty->assign("Acolum_num",count($serieslist));
                $smarty->assign("serieslist",$serieslist);
                $smarty->assign("Sector_num",count($productsheetlist));
                $smarty->assign("productsheetlist",$productsheetlist);
                $smarty->assign("Salesman_num",count($AOTABRlist));
                $smarty->assign("AOTABRlist",$AOTABRlist);
                $smarty->assign("Salesman_num",count($cf_1475));
                $smarty->assign("cf_1475",$cf_1475);                 
                $smarty->assign("uPRODUCTS",$search_text);
                $smarty->assign("uCustomer",$_REQUEST['search_text2']);
                $smarty->assign("uSector",$_REQUEST['search_text3']);
                $smarty->assign("uSalesman",$_REQUEST['search_text4']);
                $smarty->assign("uSalesmans",$_REQUEST['search_text5']);
                $listValue = getSnowBearPcsnofs($year,$whereProductCategoriesSQL,$whereProductseriesSQL,$whereproductsheetSQL,$whereAOTABRSQL,$whereprolisg5SQL);
           break;
           
           
            case 'Customerservicenumberofsummarytableoffaultarea':      //售后故障数量区域汇总表
            $cf_1475=getcf_1475();
            $smarty->assign("cf_1475",$cf_1475);
            $admissibilitytype=$_REQUEST['admissibilitytype'];
            if($admissibilitytype!=''){
                $admissibilitytypeSQL = " AND cf_1475 like '%$admissibilitytype%' ";
                $smarty->assign("admissibilitytype",$admissibilitytype);
              }
             $dependentPicklists = lingdang_DependencyPicklist::getPickListDependency('Accounts','bill_country','bill_state');
                    $picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource('Accounts');
                    $citty = $dependentPicklists['valuemapping'];
                    array_pop($citty);array_shift($citty);
                    foreach($citty as $key=>$arr){
                        $cticty[$arr['sourcevalue']] = array_flip($arr['targetvalues']);
                    }
                    foreach($cticty as $key=>$arr){
                        foreach($arr as $key2=>$arr2){
                           $cticty[$key][$key2]= $picklistDependencyDatasource->bill_state->$key2->bill_city;
                        }
                    }
                    foreach($cticty as $key=>$arr){
                        $count=0;
                        foreach($arr as $key2=>$arr){
                            //array_shift($cticty[$key][$key2]);
                            $cticty[$key][$key2]['counts']=count($arr)-1;
                            $count+=(count($arr)-1);
                        }
                          $cticty[$key]['ROWcounts']=$count;
                    }
                $cticty['']=array(''=>array(''=>'合计：'));
                $smarty->assign("cticty",$cticty); 
             $listValue = getsnowbearCsnostofa($year,$admissibilitytypeSQL);
            break;
            
        case 'Analysisofthetablecustomerservicefailure':  
        //print_r($_REQUEST);
              $procatlist=getproductcategory2();
              $serieslist=getProductseries();
              $productsheetlist=getproductsheet();
              $cf_1410list=getcf_1410();
              $users_combo = get_user_array(FALSE, "Active");
            foreach($users_combo as $userid=>$lastname)
            {
  
                $AOTABRlist[$lastname]=$userid;
            }

                
              $cf_1475=getcf_1475();
              $search_text=$_REQUEST['search_text'];
              $search_text2=$_REQUEST['search_text2'];
              $search_text3=$_REQUEST['search_text3'];
              $search_text4=$_REQUEST['search_text4'];
              $search_text5=$_REQUEST['search_text5'];
              $search_text6=$_REQUEST['search_text6'];
              if($search_text!=''){
                    $prolisgs = explode(',',$search_text);
                    $prolisg = implode("','",$prolisgs);
                    $whereProductCategoriesSQL = " AND ld_products.productcategory in ('$prolisg') ";
                    $smarty->assign("receiverid",$search_text);
                    $smarty->assign("receiverid_array",$prolisgs);
                }
                if($search_text2!=''){
                    $prolisgs2 = explode(',',$search_text2);
                    $prolisg2 = implode("','",$prolisgs2);
                    $whereProductseriesSQL = " AND ld_productcf.cf_1406 in ('$prolisg2') ";
                    $smarty->assign("receiverid2",$search_text2);
                    $smarty->assign("receiverid_array2",$prolisgs2);
                }
                if($search_text3!=''){
                    $prolisgs3 = explode(',',$search_text3);
                    $prolisg3 = implode("','",$prolisgs3);
                    $wherecf_1410SQL = " AND ld_contactrecordscf.cf_1410 in ('$prolisg3') ";
                    $smarty->assign("receiverid3",$search_text3);
                    $smarty->assign("receiverid_array3",$prolisgs3);
                }
                if($search_text6!=''){
                    $whereproductsheetSQL = " AND ld_products.productname like '%$search_text6%' ";
                    $smarty->assign("receiverid6",$search_text6);
                }
                if($search_text4!=''){
                    $prolisgs4 = explode(',',$search_text4);
                    $prolisg4 = implode("','",$prolisgs4);
                    $whereAOTABRSQL = " AND ld_contactrecords.smownerid in (SELECT id FROM ld_users WHERE last_name in ('$prolisg4')) ";
                    $smarty->assign("receiverid4",$search_text4);;
                    $smarty->assign("receiverid_array4",$prolisgs4);
                }
                if($search_text5!=''){
                    $prolisgs5 = explode(',',$search_text5);
                    $prolisg5 = implode("','",$prolisgs5);
                    $whereprolisg5SQL = " AND ld_contactrecordscf.cf_1410 in ('$prolisg5') ";
                    $smarty->assign("receiverid5",$search_text5);;
                    $smarty->assign("receiverid_array5",$prolisgs5);
                }
                
                $smarty->assign("cf_1410_num",count($cf_1410list));
              $smarty->assign("cf_1410list",$cf_1410list);
              $smarty->assign("count_num",count($procatlist));
              $smarty->assign("productlist",$procatlist);
              $smarty->assign("Acolum_num",count($serieslist));
              $smarty->assign("serieslist",$serieslist);
              $smarty->assign("Sector_num",count($productsheetlist));
              $smarty->assign("productsheetlist",$productsheetlist);
              $smarty->assign("Salesman_num",count($AOTABRlist));
              $smarty->assign("AOTABRlist",$AOTABRlist);
              $smarty->assign("Salesman_num",count($cf_1475));
              $smarty->assign("cf_1475",$cf_1475);                 
              $smarty->assign("uPRODUCTS",$search_text);
              $smarty->assign("uCustomer",$_REQUEST['search_text2']);
              $smarty->assign("uSector",$_REQUEST['search_text3']);
              $smarty->assign("uSalesman",$_REQUEST['search_text4']);
              $smarty->assign("uSalesmans",$_REQUEST['search_text5']);
            $listValue = getsnowbearAtcsf($year,$whereProductCategoriesSQL,$whereProductseriesSQL,$whereproductsheetSQL,$whereAOTABRSQL,$whereprolisg5SQL,$wherecf_1410SQL);
           break;
            
        }
        


if($_REQUEST['ajaxExport']=='yes'){
    //print_r($listValue);die;
    include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();


foreach($listValue_header as $key=>$arr){
   // echo $key;
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}

foreach($listValue as $key=>$arr){
    $v=0;
    foreach($arr as $key2=>$arr2){
       $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($v).($key+2),$arr2); 
       $v++;
    }
}


$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk','Report'));
$objPHPExcel->getActiveSheet()->setTitle('Report');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');

$objWriter->save('storage/Report.xls');   

 //下载文件

 $file_name="Report.xls";
 $file_dir="storage/";

$file = fopen($file_dir.$file_name,"r"); 
Header("Content-type: application/octet-stream");
Header("Accept-Ranges: bytes");
Header("Accept-Length: ".filesize($file_dir . $file_name));

Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
ob_clean();   
flush(); 
echo fread($file, filesize($file_dir.$file_name));
fclose($file);
exit();
}

//主搜索方法
function getSnowBearPeijianminxi($begin_date,$end_date,$whereSRPNNameSQL,$whereCONTRACTNOameSQL,$whereProductNameSQL,$whereModelSQL,$whereEXPLAINSQL,$whereAppSQL,$whereProductCategoriesSQL,$whereProductCategoriesSQL2){
    global $adb;
	//'申请日期','特约维修点名称','说明','配件名称','产品类别','适用型号','计量单位','数量','出货价','金额'
    $SQL = "SELECT ld_salesorder.signed_data,ld_account.accountname as subject,ld_productcf.cf_1425,ld_products.productsheet,
            ld_products.description,ld_products.productname,ld_products.productcategory,usageunit,
            ld_salesorderdetail.quantity,
            ld_productcf.cf_1450 as unit_price,(ld_productcf.cf_1450*ld_salesorderdetail.quantity) AS amount
            FROM ld_salesorder 
            LEFT JOIN ld_account ON ld_account.accountid=ld_salesorder.accountid 
            LEFT JOIN ld_salesorderdetail ON ld_salesorderdetail.id=ld_salesorder.salesorderid 
            LEFT JOIN ld_products 
            ON ld_salesorderdetail.productid=ld_products.productid 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            WHERE ld_salesorder.signed_data BETWEEN '$begin_date' AND '$end_date' 
            AND ld_salesorder.deleted=0 $whereSRPNNameSQL $whereCONTRACTNOameSQL $whereProductNameSQL $whereModelSQL $whereEXPLAINSQL $whereAppSQL $whereProductCategoriesSQL $whereProductCategoriesSQL2";
            //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['signed_data'] = $adb->query_result($result, $i, 'signed_data');
        $productList[$i]['subject'] = $adb->query_result($result, $i, 'subject');
        $productList[$i]['cf_1425'] = $adb->query_result($result, $i, 'cf_1425');
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
		$productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['usageunit'] = $adb->query_result($result, $i, 'usageunit');
        $productList[$i]['quantity'] = setNumberFormat($adb->query_result($result, $i, 'quantity'));
        $productList[$i]['costprice'] = setNumberFormat($adb->query_result($result, $i, 'unit_price'));
        $productList[$i]['amount'] = setNumberFormat($adb->query_result($result, $i, 'amount'));

    }
    return $productList;
}

function getSnowBearRPOSP($year,$whereProductNameSQL,$whereModelSQL,$whereAppSQL,$whereProductCategoriesSQL,$whereProductCategoriesSQL2){
    global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT ld_products.productid,ld_products.productsheet as productname,ld_products.productname as productsheet,ld_products.productcategory,ld_products.costprice,ld_productcf.cf_1425,ld_products.description,
            IFNULL(F2.T1,0) AS T1,IFNULL(F2.T2,0) AS T2,IFNULL(F2.T3,0) AS T3,IFNULL(F2.T4,0) AS T4,IFNULL(F2.T5,0) AS T5,IFNULL(F2.T6,0) AS T6,
            IFNULL(F2.T7,0) AS T7,IFNULL(F2.T8,0) AS T8,IFNULL(F2.T9,0) AS T9,IFNULL(F2.T10,0) AS T10,IFNULL(F2.T11,0) AS T11,IFNULL(F2.T12,0) AS T12,
            (IFNULL(F2.T1,0)+IFNULL(F2.T2,0)+IFNULL(F2.T3,0)+IFNULL(F2.T4,0)+IFNULL(F2.T5,0)+IFNULL(F2.T6,0)+
            IFNULL(F2.T7,0)+IFNULL(F2.T8,0)+IFNULL(F2.T9,0)+IFNULL(F2.T10,0)+IFNULL(F2.T11,0)+IFNULL(F2.T12,0)) AS totalcount,
            (IFNULL(F2.T1,0)+IFNULL(F2.T2,0)+IFNULL(F2.T3,0)+IFNULL(F2.T4,0)+IFNULL(F2.T5,0)+IFNULL(F2.T6,0)+
            IFNULL(F2.T7,0)+IFNULL(F2.T8,0)+IFNULL(F2.T9,0)+IFNULL(F2.T10,0)+IFNULL(F2.T11,0)+IFNULL(F2.T12,0))*ld_products.costprice AS amount
            FROM 
            ld_products 
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid
            LEFT JOIN 
            (
            SELECT  F1.productid,
            SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,SUM(T6) AS T6,SUM(T7) AS T7,
            SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12
            FROM(
            SELECT ld_salesorderdetail.productid,
            case WHEN MONTH(ld_salesorder.signed_data)=1 THEN ld_salesorderdetail.quantity ELSE 0 END as T1,
            case WHEN MONTH(ld_salesorder.signed_data)=2 THEN ld_salesorderdetail.quantity ELSE 0 END as T2,
            case WHEN MONTH(ld_salesorder.signed_data)=3 THEN ld_salesorderdetail.quantity ELSE 0 END as T3,
            case WHEN MONTH(ld_salesorder.signed_data)=4 THEN ld_salesorderdetail.quantity ELSE 0 END as T4,
            case WHEN MONTH(ld_salesorder.signed_data)=5 THEN ld_salesorderdetail.quantity ELSE 0 END as T5,
            case WHEN MONTH(ld_salesorder.signed_data)=6 THEN ld_salesorderdetail.quantity ELSE 0 END as T6,
            case WHEN MONTH(ld_salesorder.signed_data)=7 THEN ld_salesorderdetail.quantity ELSE 0 END as T7,
            case WHEN MONTH(ld_salesorder.signed_data)=8 THEN ld_salesorderdetail.quantity ELSE 0 END as T8,
            case WHEN MONTH(ld_salesorder.signed_data)=9 THEN ld_salesorderdetail.quantity ELSE 0 END as T9,
            case WHEN MONTH(ld_salesorder.signed_data)=10 THEN ld_salesorderdetail.quantity ELSE 0 END as T10,
            case WHEN MONTH(ld_salesorder.signed_data)=11 THEN ld_salesorderdetail.quantity ELSE 0 END as T11,
            case WHEN MONTH(ld_salesorder.signed_data)=12 THEN ld_salesorderdetail.quantity ELSE 0 END as T12,
            ld_products.unit_price
            FROM ld_salesorder 
            LEFT JOIN ld_salesorderdetail 
            ON ld_salesorderdetail.id=ld_salesorder.salesorderid 
            LEFT JOIN ld_products 
            ON ld_salesorderdetail.productid=ld_products.productid 
            WHERE YEAR(ld_salesorder.signed_data)=$year AND ld_salesorder.deleted=0 $whereAppSQL
            ) AS F1 GROUP BY F1.productid) AS F2 
            ON ld_products.productid = F2.productid where 1 
            AND IFNULL(F2.T1, 0) + IFNULL(F2.T2, 0) + IFNULL(F2.T3, 0) + IFNULL(F2.T4, 0) 
            + IFNULL(F2.T5, 0) + IFNULL(F2.T6, 0) + IFNULL(F2.T7, 0) + IFNULL(F2.T8, 0) 
            + IFNULL(F2.T9, 0) + IFNULL(F2.T10, 0) + IFNULL(F2.T11, 0) + IFNULL(F2.T12, 0)>0
            $whereProductNameSQL $whereModelSQL $whereProductCategoriesSQL $whereProductCategoriesSQL2
            ); ";
//echo $SQL;
    $adb->pquery($SQL,array());
    
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT '' AS productid,'汇总个数：' AS productname,'' as productsheet,'' AS productcategory,'' AS costprice,'' AS cf_1425,'' AS description,
            SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,SUM(T6) AS T6,SUM(T7) AS T7,
            SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12,
            SUM(totalcount) totalcount,'' as amount 
            FROM TempTable);";
    $adb->pquery($SQL,array());

    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable3 ignore(
            SELECT '' AS productid,'汇总金额：' AS productname,'' as productsheet,'' as productcategory,'' AS costprice,'' AS cf_1425,'' AS description,
            SUM(T1*costprice) AS T1,SUM(T2*costprice) AS T2,SUM(T3*costprice) AS T3,SUM(T4*costprice) AS T4,SUM(T5*costprice) AS T5,
            SUM(T6*costprice) AS T6,SUM(T7*costprice) AS T7,SUM(T8*costprice) AS T8,SUM(T9*costprice) AS T9
            ,SUM(T10*costprice) AS T10,SUM(T11*costprice) AS T11,SUM(T12*costprice) AS T12,''AS totalcount,
             SUM(T1*costprice)+SUM(T2*costprice)+SUM(T3*costprice)+SUM(T4*costprice)+SUM(T5*costprice)+
            SUM(T6*costprice)+SUM(T7*costprice)+SUM(T8*costprice)+SUM(T9*costprice)+SUM(T10*costprice)+SUM(T11*costprice)+SUM(T12*costprice) 
             AS amount
             FROM TempTable);";
    $adb->pquery($SQL,array()); 

    $SQL = "SELECT * FROM TempTable UNION 
            SELECT * FROM TempTable2 UNION 
            SELECT * FROM TempTable3";   
    $result=$adb->pquery($SQL,array());
   
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
		$productList[$i]['costprice'] = setNumberFormat($adb->query_result($result, $i, 'costprice'));
		 $productList[$i]['cf_1425'] = $adb->query_result($result, $i, 'cf_1425');
         $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
        }
        $productList[$i]['totalcount'] = setNumberFormat($adb->query_result($result, $i, 'totalcount'));
        $productList[$i]['amount'] = setNumberFormat($adb->query_result($result, $i, 'amount'));
    }
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable3;";
        $result1 = $adb->query($sSQL5); 
        
    return $productList;
}

function getSnowBearSNOWBEARHNSRSR($year){
    global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT F2.bill_city,F2.bill_country,F2.bill_state,	
            SUM(IFNULL(F2.T1, 0)) AS T1,
            SUM(IFNULL(F2.T2, 0)) AS T2,
	        SUM(IFNULL(F2.T3, 0)) AS T3,
	        SUM(IFNULL(F2.T4, 0)) AS T4,
        	SUM(IFNULL(F2.T5, 0)) AS T5,
        	SUM(IFNULL(F2.T6, 0)) AS T6,
        	SUM(IFNULL(F2.T7, 0)) AS T7,
        	SUM(IFNULL(F2.T8, 0)) AS T8,
        	SUM(IFNULL(F2.T9, 0)) AS T9,
        	SUM(IFNULL(F2.T10, 0)) AS T10,
        	SUM(IFNULL(F2.T11, 0)) AS T11,
        	SUM(IFNULL(F2.T12, 0)) AS T12,
	(
		SUM(IFNULL(F2.T1, 0)) + SUM(IFNULL(F2.T2, 0)) + SUM(IFNULL(F2.T3, 0)) + SUM(IFNULL(F2.T4, 0)) + SUM(IFNULL(F2.T5, 0)) + 
SUM(IFNULL(F2.T6, 0)) + SUM(IFNULL(F2.T7, 0)) + SUM(IFNULL(F2.T8, 0)) + SUM(IFNULL(F2.T9, 0)) + SUM(IFNULL(F2.T10, 0)) + 
SUM(IFNULL(F2.T11, 0)) + SUM(IFNULL(F2.T12, 0))) AS totalcount
            FROM  
						(
            SELECT 
            ld_account.bill_city,ld_account.bill_country,ld_account.bill_state,
            case WHEN MONTH(ld_ContactRecords.createdtime)=1 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T1,
            case WHEN MONTH(ld_ContactRecords.createdtime)=2 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T2,
            case WHEN MONTH(ld_ContactRecords.createdtime)=3 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T3,
            case WHEN MONTH(ld_ContactRecords.createdtime)=4 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T4,
            case WHEN MONTH(ld_ContactRecords.createdtime)=5 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T5,
            case WHEN MONTH(ld_ContactRecords.createdtime)=6 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T6,
            case WHEN MONTH(ld_ContactRecords.createdtime)=7 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T7,
            case WHEN MONTH(ld_ContactRecords.createdtime)=8 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T8,
            case WHEN MONTH(ld_ContactRecords.createdtime)=9 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T9,
            case WHEN MONTH(ld_ContactRecords.createdtime)=10 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T10,
            case WHEN MONTH(ld_ContactRecords.createdtime)=11 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T11,
            case WHEN MONTH(ld_ContactRecords.createdtime)=12 THEN COUNT(ld_ContactRecords.contactrecordID) ELSE 0 END as T12
            FROM ld_ContactRecords 
            LEFT JOIN ld_account  
            ON ld_ContactRecords.accountid=ld_account.accountid 
            WHERE YEAR(ld_ContactRecords.createdtime)=$year AND ld_ContactRecords.deleted=0 
            GROUP BY MONTH (
		ld_ContactRecords.createdtime
	),ld_account.bill_city) AS F2  GROUP BY F2.bill_city order by bill_country,bill_state,bill_city );";  
            $adb->pquery($SQL,array());
           // echo $SQL."<br>";
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT '合计：' AS bill_city,'' bill_country,''bill_state,
            SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,SUM(T6) AS T6,SUM(T7) AS T7,
            SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12,
            SUM(totalcount) as totalcount,'' as bili
            FROM TempTable);";
            //echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
    $SQL1 = "SELECT
            SUM(totalcount) as totalcount2
            FROM TempTable;";  
            //echo $SQL."<br>";
        $tempresult=$adb->pquery($SQL1,array());    
        $rowCount2 = $adb->num_rows($tempresult);
        for ($i = 0; $i < $rowCount2; $i++) {  
            $coouunttotal = $adb->query_result($tempresult,$i,'totalcount2');
       }
       //echo $coouunttotal;die;   
    $SQL = "SELECT *,totalcount/$coouunttotal*100 as bili FROM TempTable UNION 
            SELECT * FROM TempTable2";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
        $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['bill_city'] = $adb->query_result($result, $i, 'bill_city');
        $productList[$i]['bill_country'] = $adb->query_result($result, $i, 'bill_country');
        $productList[$i]['bill_state'] = $adb->query_result($result, $i, 'bill_state');
        $productList[$i]['bili'] = setNumberFormat($adb->query_result($result, $i, 'bili'));
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
        }
        $productList[$i]['totalcount'] = setNumberFormat($adb->query_result($result, $i, 'totalcount'));
    }
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
      //print_r($productList);  
    return $productList;
}

function getSnowBearSNOWBEARCCAR($begin_date,$end_date,$whereProductCategoriesSQL,$whereProductseriesSQL,$whereproductsheetSQL,$whereAOTABRSQL){
    global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT ld_salesorderdetail.productid,productcategory as cf_1424,cf_1406,productsheet,productname,ld_quotescf.cf_1419,
            COUNT(ld_salesorderdetail.productid) AS counts
            FROM ld_quotes 
            LEFT JOIN ld_quotescf ON ld_quotes.quoteid=ld_quotescf.quoteid
            LEFT JOIN ld_salesorderdetail ON ld_quotes.quoteid=ld_salesorderdetail.id
            LEFT JOIN ld_products ON ld_salesorderdetail.productid=ld_products.productid
            LEFT JOIN ld_productcf ON ld_products.productid=ld_productcf.productid 
            WHERE ld_quotes.createdtime BETWEEN '$begin_date' AND '$end_date' AND ld_quotes.deleted=0 
            $whereProductCategoriesSQL $whereProductseriesSQL $whereproductsheetSQL $whereAOTABRSQL 
            GROUP BY ld_salesorderdetail.productid,ld_quotescf.cf_1419);";
            $adb->pquery($SQL,array());
          // echo $SQL."<br>";
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT productid,SUM(counts) AS counts 
            FROM TempTable GROUP BY productsheet);";
            $adb->pquery($SQL,array());
          //  echo $SQL."<br>";
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable3 ignore(
            SELECT TempTable.*,IFNULL(TempTable.counts,0)/IFNULL(TempTable2.counts,0)*100 AS bili,'' AS zzxsebl 
            FROM TempTable LEFT JOIN TempTable2 ON TempTable.productid=TempTable2.productid);"; 
            $adb->pquery($SQL,array());  
          //   echo $SQL."<br>";  
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable4 ignore(
            SELECT productid,'' AS cf_1424,'' AS cf_1406,'小计:' AS productsheet,'' AS productname,
            '' AS cf_1419,SUM(counts) AS counts,'' AS bili,'' AS zzxsebl 
            FROM TempTable3 GROUP BY productsheet);";
            $adb->pquery($SQL,array());
         //   echo $SQL."<br>";
    $SQL = "SELECT * FROM (SELECT * FROM TempTable3 UNION 
            SELECT * FROM TempTable4 ) AS F2 ORDER BY F2.productid,cf_1424 DESC";   
    $result=$adb->pquery($SQL,array());            
    //echo $SQL."<br>";
    $rowCount = $adb->num_rows($result);    
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['cf_1424'] = $adb->query_result($result, $i, 'cf_1424');
        $productList[$i]['cf_1406'] = $adb->query_result($result, $i, 'cf_1406');
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['cf_1419'] = $adb->query_result($result, $i, 'cf_1419');
        $productList[$i]['counts'] = setNumberFormat($adb->query_result($result, $i, 'counts'));
        $productList[$i]['bili'] = setNumberFormat($adb->query_result($result, $i, 'bili'));
        $productList[$i]['zzxsebl'] = setNumberFormat($adb->query_result($result, $i, 'zzxsebl'));
    }
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable4;";
        $result1 = $adb->query($sSQL5); 
      //print_r($productList);  
    return $productList;    
}
function getSnowBearSbpccs($year){
    global $adb;
    $SQL = "SELECT 
            case WHEN MONTH(ld_quotes.createdtime)=1 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T1,
            case WHEN MONTH(ld_quotes.createdtime)=2 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T2,
            case WHEN MONTH(ld_quotes.createdtime)=3 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T3,
            case WHEN MONTH(ld_quotes.createdtime)=4 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T4,
            case WHEN MONTH(ld_quotes.createdtime)=5 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T5,
            case WHEN MONTH(ld_quotes.createdtime)=6 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T6,
            case WHEN MONTH(ld_quotes.createdtime)=7 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T7,
            case WHEN MONTH(ld_quotes.createdtime)=8 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T8,
            case WHEN MONTH(ld_quotes.createdtime)=9 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T9,
            case WHEN MONTH(ld_quotes.createdtime)=10 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T10,
            case WHEN MONTH(ld_quotes.createdtime)=11 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T11,
            case WHEN MONTH(ld_quotes.createdtime)=12 THEN IFNULL(COUNT(ld_quotes.quoteid),0)  ELSE 0 END as T12
            FROM ld_quotes 
            WHERE YEAR(ld_quotes.createdtime)=$year AND ld_quotes.deleted=0
            GROUP BY MONTH(ld_quotes.createdtime)";
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {      
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
           //$total+=$adb->query_result($result, $i, 't'.$c);
        }
    }
  
    return $productList;
}
function getProductCategories(){
    global $adb;
    $SQL = "SELECT cf_1424id,cf_1424 FROM ld_cf_1424 GROUP BY cf_1424id";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $ProductCategoriesid = $adb->query_result($result, $i, 'cf_1424');
        $proList[$ProductCategoriesid] = $adb->query_result($result, $i, 'cf_1424id');
    }
    
    return $proList;
}
function getProductseries(){
    global $adb;
    $SQL = "SELECT cf_1406id,cf_1406 FROM ld_cf_1406 GROUP BY cf_1406id";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $ProductCategoriesid = $adb->query_result($result, $i, 'cf_1406');
        $proList[$ProductCategoriesid] = $adb->query_result($result, $i, 'cf_1406id');
    }
    
    return $proList;
}
function getAOTABR(){
    global $adb;
    $SQL = "SELECT cf_1419id,cf_1419 FROM ld_cf_1419 GROUP BY cf_1419";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $ProductCategoriesid = $adb->query_result($result, $i, 'cf_1419');
        $proList[$ProductCategoriesid] = $adb->query_result($result, $i, 'cf_1419id');
    }
    
    return $proList;
}

function getaccounttype(){
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 上午 10:51
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('accounttype');
    $proList = array_values($result_pick);
    /*global $adb;
    $SQL = "SELECT accounttype FROM ld_accounttype";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'accounttype');
    }*/
    
    return $proList;
}

function getcf_1475(){
    global $adb;
    $SQL = "SELECT cf_1475 FROM ld_cf_1475";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'cf_1475');
    }
    
    return $proList;
}
function getproductsheet(){
    global $adb;
    $SQL = "SELECT productsheet FROM ld_products GROUP BY productsheet";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'productsheet');
    }
    
    return $proList;
}
function getcf_1410(){
    global $adb;
    $SQL = "SELECT cf_1410 FROM ld_cf_1410 GROUP BY cf_1410";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'cf_1410');
    }
    
    return $proList;
}
function getproductcategory2(){

    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 上午 9:41
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('productcategory');
    $proList = array_values($result_pick);
    return $proList;
    /*global $adb;
    $SQL = "SELECT productcategory FROM ld_productcategory GROUP BY productcategory";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'productcategory');
    }
    
    return $proList;*/
}
function getcf_1476(){
    global $adb;
    $SQL = "SELECT cf_1476 FROM ld_cf_1476 GROUP BY cf_1476";

    $result=$adb->pquery($SQL,array());
    
    $rowCount = $adb->num_rows($result);
    
    for ($i = 0; $i < $rowCount; $i++) {      
        $proList[$i] = $adb->query_result($result, $i, 'cf_1476');
    }
    
    return $proList;
}
function getSnowBearraordsr($year,$admissibilitytypeSQL,$CustomercategorySQL,$AccountNameSQL){
    global $adb;
    $SQL = "SELECT 	bill_country,
            	bill_state,
            	bill_city,
            	cf_1475,
            	account_type,
            	accountname,
            SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,
            SUM(T6) AS T6,SUM(T7) AS T7,SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12,SUM(total) AS total
             FROM (SELECT
            	bill_country,
            	bill_state,
            	ld_account.bill_city,
            	ld_projectcf.cf_1475,
            	ld_account.account_type,
            	ld_account.accountname,ld_account.accountid,
            	CASE
            WHEN MONTH (ld_project.startdate) = 1 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T1,
             CASE
            WHEN MONTH (ld_project.startdate) = 2 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T2,
             CASE
            WHEN MONTH (ld_project.startdate) = 3 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T3,
             CASE
            WHEN MONTH (ld_project.startdate) = 4 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T4,
             CASE
            WHEN MONTH (ld_project.startdate) = 5 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T5,
             CASE
            WHEN MONTH (ld_project.startdate) = 6 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T6,
             CASE
            WHEN MONTH (ld_project.startdate) = 7 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T7,
             CASE
            WHEN MONTH (ld_project.startdate) = 8 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T8,
             CASE
            WHEN MONTH (ld_project.startdate) = 9 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T9,
             CASE
            WHEN MONTH (ld_project.startdate) = 10 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T10,
             CASE
            WHEN MONTH (ld_project.startdate) = 11 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T11,
             CASE
            WHEN MONTH (ld_project.startdate) = 12 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS T12,
             CASE
            WHEN MONTH (ld_project.startdate) = 1 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 2 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 3 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 5 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 6 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 7 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 8 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 9 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 10 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 11 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END + CASE
            WHEN MONTH (ld_project.startdate) = 12 THEN
            	sum(
            		IFNULL(ld_projectcf.cf_1478, 0) * IFNULL(ld_products.unit_price, 0)
            	)
            ELSE
            	0
            END AS total
            FROM
            	ld_project
            LEFT JOIN ld_projectcf ON ld_projectcf.projectid = ld_project.projectid
            LEFT JOIN ld_products ON ld_products.productid = ld_project.product_id
            LEFT JOIN ld_productcf ON ld_productcf.productid = ld_project.product_id
            LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid
            WHERE
            	YEAR (ld_project.startdate) = $year $admissibilitytypeSQL $CustomercategorySQL $AccountNameSQL
            AND ld_project.deleted = 0
            GROUP BY
            	MONTH (ld_project.startdate),accountid,
            	ld_account.bill_city) AS C10 
            GROUP BY accountid
            ORDER BY
            	bill_country,
            	bill_state,
            	bill_city ";
         // echo $SQL;      
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $productList[$i]['bill_country'] = $adb->query_result($result, $i, 'bill_country');
        $productList[$i]['bill_state'] = $adb->query_result($result, $i, 'bill_state');
        $productList[$i]['bill_city'] = $adb->query_result($result, $i, 'bill_city');
        $productList[$i]['cf_1475'] = $adb->query_result($result, $i, 'cf_1475');
        $productList[$i]['account_type'] = $adb->query_result($result, $i, 'account_type');
        $productList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');        
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
           //$total+=$adb->query_result($result, $i, 't'.$c);
        }
        $productList[$i]['total'] = $adb->query_result($result, $i, 'total');   
    }
  
    return $productList;
}

//Edit by luyx 2016-09-06
//退换货数量区域汇总分析表：按照单据“处理数量”统计、优化SQL查询语句
function getSnowBearrnordsr($year,$admissibilitytypeSQL,$CustomercategorySQL,$ProductCategoriesSQL,$ProductseriesSQL,$ContainsapprovaldocumentSQL,$AccountnameSQL){
    global $adb;
    $SQL="Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT
        		accountid,
        		bill_country,
        		bill_state,
        		F1.bill_city,
        		bill_country AS order1,
        		bill_state AS order2,
        		bill_city AS order3,
        		F1.cf_1475,
        		F1.account_type,
        		F1.accountname,
        		F1.productcategory,
        		F1.cf_1406,
        		productsheet,
        		productname,
        		SUM(T1) AS T1,
        		SUM(T2) AS T2,
        		SUM(T3) AS T3,
        		SUM(T4) AS T4,
        		SUM(T5) AS T5,
        		SUM(T6) AS T6,
        		SUM(T7) AS T7,
        		SUM(T8) AS T8,
        		SUM(T9) AS T9,
        		SUM(T10) AS T10,
        		SUM(T11) AS T11,
        		SUM(T12) AS T12,
        		SUM(total) AS total
            FROM (
                SELECT
				    ld_project.accountid,
    				ld_products.productid,
                    CASE WHEN ld_account.bill_country='--无--' OR ld_account.bill_country='' OR ld_account.bill_country is NULL THEN '--' ELSE ld_account.bill_country END AS bill_country,
    				CASE WHEN ld_account.bill_state='--无--'  OR ld_account.bill_state='' OR ld_account.bill_state is NULL THEN '--' ELSE ld_account.bill_state END AS bill_state,
    				CASE WHEN ld_account.bill_city='--无--' OR ld_account.bill_city='' OR ld_account.bill_city is NULL THEN '--' ELSE ld_account.bill_city END AS bill_city,
    				ld_projectcf.cf_1475,
    				ld_account.account_type,
    				ld_account.accountname,
    				ld_products.productcategory,
    				ld_productcf.cf_1406,
    				ld_products.productsheet,
    				ld_products.productname,
    				CASE WHEN MONTH(ld_project.startdate) = 1 THEN ld_projectcf.cf_1478 END AS T1,
    				CASE WHEN MONTH(ld_project.startdate) = 2 THEN ld_projectcf.cf_1478 END AS T2,
    				CASE WHEN MONTH(ld_project.startdate) = 3 THEN ld_projectcf.cf_1478 END AS T3,
    				CASE WHEN MONTH(ld_project.startdate) = 4 THEN ld_projectcf.cf_1478 END AS T4,
    				CASE WHEN MONTH(ld_project.startdate) = 5 THEN ld_projectcf.cf_1478 END AS T5,
    				CASE WHEN MONTH(ld_project.startdate) = 6 THEN ld_projectcf.cf_1478 END AS T6,
    				CASE WHEN MONTH(ld_project.startdate) = 7 THEN ld_projectcf.cf_1478 END AS T7,
    				CASE WHEN MONTH(ld_project.startdate) = 8 THEN ld_projectcf.cf_1478 END AS T8,
    				CASE WHEN MONTH(ld_project.startdate) = 9 THEN ld_projectcf.cf_1478 END AS T9,
    				CASE WHEN MONTH(ld_project.startdate) = 10 THEN ld_projectcf.cf_1478 END AS T10,
    				CASE WHEN MONTH(ld_project.startdate) = 11 THEN ld_projectcf.cf_1478 END AS T11,
    				CASE WHEN MONTH(ld_project.startdate) = 12 THEN ld_projectcf.cf_1478 END AS T12,
    				ld_projectcf.cf_1478 as total
                FROM ld_project
                LEFT JOIN ld_projectcf ON ld_project.projectid = ld_projectcf.projectid
                LEFT JOIN ld_products ON ld_products.productid = ld_project.product_id
                LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid
                LEFT JOIN ld_productcf ON ld_productcf.productid = ld_products.productid
                WHERE YEAR(ld_project.startdate)=$year
                    and ld_project.deleted=0
                    -- and ld_project.accountid>0
                    $admissibilitytypeSQL 
                    $CustomercategorySQL 
                    $ProductCategoriesSQL 
                    $ProductseriesSQL 
                    $ContainsapprovaldocumentSQL 
                    $AccountnameSQL) AS F1
            GROUP BY
                F1.accountid,
                F1.productid);";  
    // echo $SQL;   
    
    $result=$adb->pquery($SQL,array());    
    $SQL="Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT 			   	
            	accountid,
            	'小计' bill_country,
            	'' bill_state,
            	'' bill_city,
            	bill_country as order1,
            	bill_state as order2,
            	bill_city as order3,
            	'' cf_1475,
           	    '' account_type,
            	'' accountname,
            	'' productcategory,
            	'' cf_1406,
            	'' productsheet,
            	'' productname,
            	SUM(T1) AS T1,
            	SUM(T2) AS T2,
            	SUM(T3) AS T3,
            	SUM(T4) AS T4,
            	SUM(T5) AS T5,
            	SUM(T6) AS T6,
            	SUM(T7) AS T7,
            	SUM(T8) AS T8,
            	SUM(T9) AS T9,
            	SUM(T10) AS T10,
            	SUM(T11) AS T11,
            	SUM(T12) AS T12,
            	SUM(total) AS total
             FROM TempTable 
             GROUP BY accountid);";
    //echo $SQL; 
    $result=$adb->pquery($SQL,array());
    
    $SQL="Create TEMPORARY table IF NOT EXISTS TempTable3 ignore(
            SELECT * FROM (
                    SELECT * FROM TempTable 
                    UNION ALL 
                    SELECT * FROM TempTable2) as F1 
            ORDER BY CONVERT(order1 USING gbk ) COLLATE gbk_chinese_ci,
                CONVERT(order2 USING gbk ) COLLATE gbk_chinese_ci,
                CONVERT(order3 USING gbk ) COLLATE gbk_chinese_ci,
                accountid,
                CONVERT(bill_country USING gbk) COLLATE gbk_chinese_ci);";
    //echo $SQL; 
    $result=$adb->pquery($SQL,array());
    
    $SQL="Create TEMPORARY table IF NOT EXISTS TempTable4(
    SELECT 	
        accountid,
    	'合计'bill_country,
    	'' as bill_state,
    	'' as bill_city,
    	bill_country as order1,
    	bill_state as order2,
    	bill_city as order3,
    	'' as cf_1475,
    	'' as account_type,
    	'' as accountname,
    	'' as productcategory,
    	'' as cf_1406,
    	'' as productsheet,
    	'' as productname,
    	SUM(T1) AS T1,
    	SUM(T2) AS T2,
    	SUM(T3) AS T3,
    	SUM(T4) AS T4,
    	SUM(T5) AS T5,
    	SUM(T6) AS T6,
    	SUM(T7) AS T7,
    	SUM(T8) AS T8,
    	SUM(T9) AS T9,
    	SUM(T10) AS T10,
    	SUM(T11) AS T11,
    	SUM(T12) AS T12,
    	SUM(total) AS total 
    FROM TempTable);";
    $result=$adb->pquery($SQL,array());
    $SQL="SELECT * FROM TempTable3 UNION ALL SELECT * FROM TempTable4";
    
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {
        $productList[$i]['bill_country'] = $adb->query_result($result, $i, 'bill_country');
        $productList[$i]['bill_state'] = $adb->query_result($result, $i, 'bill_state');
        $productList[$i]['bill_city'] = $adb->query_result($result, $i, 'bill_city');
        $productList[$i]['cf_1475'] = $adb->query_result($result, $i, 'cf_1475');
        $productList[$i]['account_type'] = $adb->query_result($result, $i, 'account_type');
        $productList[$i]['accountname'] = $adb->query_result($result, $i, 'accountname');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');        
        $productList[$i]['cf_1406'] = $adb->query_result($result, $i, 'cf_1406');  
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');  
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname'); 
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
           //$total+=$adb->query_result($result, $i, 't'.$c);
        }
        $productList[$i]['total'] = setNumberFormat($adb->query_result($result, $i, 'total'));   
    }
  
    return $productList;
}

//Edit by luyx 2016-09-06
//产品售后故障分析表：次数按单据“处理数量”统计
function getSnowBearPcsnofs($year,$whereProductCategoriesSQL,$whereProductseriesSQL,$whereproductsheetSQL,$whereAOTABRSQL,$whereprolisg5SQL){
    global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
            SELECT 
                productid,
                productname,
                productsheet,
                cf_1406,    -- 产品系列
                productcategory,
                cf_1476,    -- 故障原因
            	SUM(T1) AS T1,
            	SUM(T2) AS T2,
            	SUM(T3) AS T3,
            	SUM(T4) AS T4,
            	SUM(T5) AS T5,
            	SUM(T6) AS T6,
            	SUM(T7) AS T7,
            	SUM(T8) AS T8,
            	SUM(T9) AS T9,
            	SUM(T10) AS T10,
            	SUM(T11) AS T11,
            	SUM(T12) AS T12,
            	SUM(total) AS total
            FROM (
    		SELECT 
                ld_project.startdate,
                ld_products.productid,
                ld_products.productname,
                ld_products.productsheet,
                ld_productcf.cf_1406,   -- 产品系列  
                ld_products.productcategory,
                ld_projectcf.cf_1476,   -- 故障原因
  				CASE WHEN MONTH(ld_project.startdate) = 1 THEN ld_projectcf.cf_1478 END AS T1,
  				CASE WHEN MONTH(ld_project.startdate) = 2 THEN ld_projectcf.cf_1478 END AS T2,
  				CASE WHEN MONTH(ld_project.startdate) = 3 THEN ld_projectcf.cf_1478 END AS T3,
    			CASE WHEN MONTH(ld_project.startdate) = 4 THEN ld_projectcf.cf_1478 END AS T4,
   				CASE WHEN MONTH(ld_project.startdate) = 5 THEN ld_projectcf.cf_1478 END AS T5,
   				CASE WHEN MONTH(ld_project.startdate) = 6 THEN ld_projectcf.cf_1478 END AS T6,
   				CASE WHEN MONTH(ld_project.startdate) = 7 THEN ld_projectcf.cf_1478 END AS T7,
   				CASE WHEN MONTH(ld_project.startdate) = 8 THEN ld_projectcf.cf_1478 END AS T8,
   				CASE WHEN MONTH(ld_project.startdate) = 9 THEN ld_projectcf.cf_1478 END AS T9,
   				CASE WHEN MONTH(ld_project.startdate) = 10 THEN ld_projectcf.cf_1478 END AS T10,
   				CASE WHEN MONTH(ld_project.startdate) = 11 THEN ld_projectcf.cf_1478 END AS T11,
   				CASE WHEN MONTH(ld_project.startdate) = 12 THEN ld_projectcf.cf_1478 END AS T12,
   				ld_projectcf.cf_1478 as total
    		FROM ld_project 
    			LEFT JOIN ld_projectcf ON ld_project.projectid=ld_projectcf.projectid 
    			LEFT JOIN ld_products ON ld_products.productid=ld_project.product_id
    			LEFT JOIN ld_account ON ld_account.accountid = ld_project.accountid
    			LEFT JOIN ld_productcf ON ld_productcf.productid = ld_products.productid
    		WHERE YEAR(ld_project.startdate)=$year 
                and ld_project.deleted=0 
                -- and ld_project.accountid>0
                $whereProductCategoriesSQL 
                $whereProductseriesSQL 
                $whereproductsheetSQL 
                $whereAOTABRSQL 
                $whereprolisg5SQL) as F2 
            GROUP BY 
                F2.productid,
                F2.cf_1476);";
            
    //echo $SQL;
    if(!$subtotal)$subtotal=0;
      $result=$adb->pquery($SQL,array());
         $SQL = "SELECT SUM(total) AS total FROM TempTable;";
     $result2=$adb->pquery($SQL,array());
      $subtotal = $adb->query_result($result2, 0, 'total'); 
      
     $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT productid,'小计：' as productname,'' as productsheet,'' as cf_1406,'' as productcategory,'' AS cf_1476,SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,
            SUM(T6) AS T6,SUM(T7) AS T7,SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,
            SUM(T11) AS T11,SUM(T12) AS T12,SUM(total) AS total,'' as total2,SUM(total)/$subtotal*100 as total3 FROM TempTable GROUP BY productid
            );";
     //echo $SQL;
     $adb->pquery($SQL,array());
          

      $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable3 ignore(
            SELECT TempTable.*,TempTable.total/TempTable2.total*100 as total2,'' as total3 FROM TempTable 
            left JOIN  TempTable2 ON TempTable.productid=TempTable2.productid)
            ";
     // echo $SQL;
      $adb->pquery($SQL,array());
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable4 ignore(
            SELECT '' productid,'合计：' as productname,'' as productsheet,'' as cf_1406,'' as productcategory,'' AS cf_1476,SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,
            SUM(T6) AS T6,SUM(T7) AS T7,SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,
            SUM(T11) AS T11,SUM(T12) AS T12,SUM(total) AS total,'' as total2,SUM(total)/$subtotal*100 as total3 FROM TempTable 
            );";  
    //echo $SQL;        
    $adb->pquery($SQL,array());
    
    $SQL = "SELECT * FROM (SELECT
            	*
            FROM
            	(
            		SELECT
            			*
            		FROM
            			TempTable3
            		UNION ALL
            			SELECT
            				*
            			FROM
            				TempTable2
            	) AS F1
            ORDER BY
            	productid,
            	cf_1476 DESC) as F2
            			UNION ALL
            				SELECT
            					*
            				FROM
            					TempTable4";
    //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['cf_1406'] = $adb->query_result($result, $i, 'cf_1406');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $productList[$i]['cf_1476'] = $adb->query_result($result, $i, 'cf_1476');
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
        }
        $productList[$i]['total'] = setNumberFormat($adb->query_result($result, $i, 'total'));
        $productList[$i]['total2'] = setNumberFormat($adb->query_result($result, $i, 'total2'));
        $productList[$i]['total3'] = setNumberFormat($adb->query_result($result, $i, 'total3'));
    }
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable4;";
        $result1 = $adb->query($sSQL5); 
    return $productList;
}



function getsnowbearAtcsf($year,$whereProductCategoriesSQL,$whereProductseriesSQL,$whereproductsheetSQL,$whereAOTABRSQL,$whereprolisg5SQL,$wherecf_1410SQL){
    global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
    		SELECT 
F1.productid,productname,productsheet,cf_1406,productcategory,cf_1410,
    		      SUM(T1) AS T1,
            	SUM(T2) AS T2,
            	SUM(T3) AS T3,
            	SUM(T4) AS T4,
            	SUM(T5) AS T5,
            	SUM(T6) AS T6,
            	SUM(T7) AS T7,
            	SUM(T8) AS T8,
            	SUM(T9) AS T9,
            	SUM(T10) AS T10,
            	SUM(T11) AS T11,
            	SUM(T12) AS T12,
            	SUM(total) AS total
 FROM (SELECT ld_products.productid,productname,productsheet,cf_1406,ld_products.productcategory,cf_1410,
    		case WHEN MONTH(ld_contactrecords.createdtime)=1 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T1,
    		case WHEN MONTH(ld_contactrecords.createdtime)=2 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T2,
    		case WHEN MONTH(ld_contactrecords.createdtime)=3 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T3,
    		case WHEN MONTH(ld_contactrecords.createdtime)=4 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T4,
    		case WHEN MONTH(ld_contactrecords.createdtime)=5 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T5,
    		case WHEN MONTH(ld_contactrecords.createdtime)=6 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T6,
    		case WHEN MONTH(ld_contactrecords.createdtime)=7 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T7,
    		case WHEN MONTH(ld_contactrecords.createdtime)=8 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T8,
    		case WHEN MONTH(ld_contactrecords.createdtime)=9 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T9,
    		case WHEN MONTH(ld_contactrecords.createdtime)=10 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T10,
    		case WHEN MONTH(ld_contactrecords.createdtime)=11 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T11,
    		case WHEN MONTH(ld_contactrecords.createdtime)=12 THEN IFNULL(COUNT(ld_contactrecords.contactrecordID),0)  ELSE 0 END as T12,
    		IFNULL(COUNT(ld_contactrecords.contactrecordID),0) AS total
    		FROM ld_contactrecords 
    			LEFT JOIN ld_contactrecordscf ON ld_contactrecordscf.contactrecordID=ld_contactrecords.contactrecordID 
    			LEFT JOIN ld_products ON ld_products.productid=ld_contactrecords.product_id
    			LEFT JOIN ld_account ON ld_account.accountid = ld_contactrecords.accountid
    			LEFT JOIN ld_productcf ON ld_productcf.productid = ld_products.productid
    		WHERE YEAR(ld_contactrecords.createdtime)=$year AND ld_contactrecords.deleted=0 
				$whereProductCategoriesSQL $whereProductseriesSQL $whereproductsheetSQL $whereAOTABRSQL $whereprolisg5SQL $wherecf_1410SQL
    		GROUP BY MONTH(ld_contactrecords.createdtime),ld_contactrecords.product_id,cf_1410)as F1 GROUP BY F1 .productid,cf_1410);";
      $result=$adb->pquery($SQL,array());
         $SQL = "SELECT SUM(total) AS total FROM TempTable;";
     $result2=$adb->pquery($SQL,array());
      $subtotal = $adb->query_result($result2, 0, 'total'); 
      
     $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT productid,'小计' productname,'' productsheet,'' cf_1406,'' productcategory,'' AS cf_1410,SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,
            SUM(T6) AS T6,SUM(T7) AS T7,SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,
            SUM(T11) AS T11,SUM(T12) AS T12,SUM(total) AS total,'' as total2,SUM(total)/$subtotal*100 as total3 FROM TempTable GROUP BY productid
            );";
     //echo $SQL;
     $adb->pquery($SQL,array());
          

      $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable3 ignore(
            SELECT TempTable.*,TempTable.total/TempTable2.total*100 as total2,'' as total3 FROM TempTable 
            left JOIN  TempTable2 ON TempTable.productid=TempTable2.productid)
            ";
     // echo $SQL;
      $adb->pquery($SQL,array());
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable4 ignore(
            SELECT '' as productid,'合计：' productname,'' productsheet,'' cf_1406,'' productcategory,'' AS cf_1410,SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,
            SUM(T6) AS T6,SUM(T7) AS T7,SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,
            SUM(T11) AS T11,SUM(T12) AS T12,SUM(total) AS total,'' as total2,SUM(total)/$subtotal*100 as total3 FROM TempTable
            );";  
    //echo $SQL;        
    $adb->pquery($SQL,array());
    
    $SQL = "SELECT * FROM (SELECT
            	*
            FROM
            	(
            		SELECT
            			*
            		FROM
            			TempTable3
            		UNION
            			SELECT
            				*
            			FROM
            				TempTable2
            	) AS F1
            ORDER BY
            	productid,
            	cf_1410 DESC) as F2
            			UNION
            				SELECT
            					*
            				FROM
            					TempTable4";
    //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $rowCount = $adb->num_rows($result);
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['productsheet'] = $adb->query_result($result, $i, 'productsheet');
        $productList[$i]['productname'] = $adb->query_result($result, $i, 'productname');
        $productList[$i]['cf_1406'] = $adb->query_result($result, $i, 'cf_1406');
        $productList[$i]['productcategory'] = $adb->query_result($result, $i, 'productcategory');
        $productList[$i]['cf_1410'] = $adb->query_result($result, $i, 'cf_1410');
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
        }
        $productList[$i]['total'] = setNumberFormat($adb->query_result($result, $i, 'total'));
        $productList[$i]['total2'] = setNumberFormat($adb->query_result($result, $i, 'total2'));
        $productList[$i]['total3'] = setNumberFormat($adb->query_result($result, $i, 'total3'));
    }
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable3;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable4;";
        $result1 = $adb->query($sSQL5); 
    return $productList;
}


//Edit by luyx 2016-09-06
//售后故障数量区域汇总表：按照单据“处理数量”统计
function getsnowbearCsnostofa($year,$admissibilitytypeSQL){
    global $adb;
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable ignore(
                SELECT
                    F2.bill_city,
                    F2.bill_state,
                    F2.bill_country,
                    SUM(IFNULL(F2.T1, 0)) AS T1,
                	SUM(IFNULL(F2.T2, 0)) AS T2,
                	SUM(IFNULL(F2.T3, 0)) AS T3,
                	SUM(IFNULL(F2.T4, 0)) AS T4,
                	SUM(IFNULL(F2.T5, 0)) AS T5,
                	SUM(IFNULL(F2.T6, 0)) AS T6,
                	SUM(IFNULL(F2.T7, 0)) AS T7,
                	SUM(IFNULL(F2.T8, 0)) AS T8,
                	SUM(IFNULL(F2.T9, 0)) AS T9,
                	SUM(IFNULL(F2.T10, 0)) AS T10,
                	SUM(IFNULL(F2.T11, 0)) AS T11,
                	SUM(IFNULL(F2.T12, 0)) AS T12,
	               ( SUM(IFNULL(F2.T1, 0)) + SUM(IFNULL(F2.T2, 0)) + SUM(IFNULL(F2.T3, 0)) + SUM(IFNULL(F2.T4, 0)) 
                   + SUM(IFNULL(F2.T5, 0)) + SUM(IFNULL(F2.T6, 0)) + SUM(IFNULL(F2.T7, 0)) + SUM(IFNULL(F2.T8, 0)) 
                   + SUM(IFNULL(F2.T9, 0)) + SUM(IFNULL(F2.T10, 0)) + SUM(IFNULL(F2.T11, 0)) + SUM(IFNULL(F2.T12, 0))) AS totalcount
                FROM (
                    SELECT 
                        ld_project.startdate,
                        ld_account.bill_city,
                        ld_account.bill_state,
                        ld_account.bill_country,
                        CASE WHEN MONTH(ld_project.startdate) = 1 THEN ld_projectcf.cf_1478 END AS T1,
                        CASE WHEN MONTH(ld_project.startdate) = 2 THEN ld_projectcf.cf_1478 END AS T2,
                        CASE WHEN MONTH(ld_project.startdate) = 3 THEN ld_projectcf.cf_1478 END AS T3,
                        CASE WHEN MONTH(ld_project.startdate) = 4 THEN ld_projectcf.cf_1478 END AS T4,
                        CASE WHEN MONTH(ld_project.startdate) = 5 THEN ld_projectcf.cf_1478 END AS T5,
                        CASE WHEN MONTH(ld_project.startdate) = 6 THEN ld_projectcf.cf_1478 END AS T6,
                        CASE WHEN MONTH(ld_project.startdate) = 7 THEN ld_projectcf.cf_1478 END AS T7,
                        CASE WHEN MONTH(ld_project.startdate) = 8 THEN ld_projectcf.cf_1478 END AS T8,
                        CASE WHEN MONTH(ld_project.startdate) = 9 THEN ld_projectcf.cf_1478 END AS T9,
                        CASE WHEN MONTH(ld_project.startdate) = 10 THEN ld_projectcf.cf_1478 END AS T10,
                        CASE WHEN MONTH(ld_project.startdate) = 11 THEN ld_projectcf.cf_1478 END AS T11,
                        CASE WHEN MONTH(ld_project.startdate) = 12 THEN ld_projectcf.cf_1478 END AS T12
                    FROM ld_project 
                    LEFT JOIN ld_projectcf ON ld_projectcf.projectid=ld_project.projectid 
                    LEFT JOIN ld_account ON ld_project.accountid=ld_account.accountid 
                    WHERE YEAR(ld_project.startdate)=$year 
                        AND ld_project.deleted=0 
                        $admissibilitytypeSQL) AS F2 
                    GROUP BY
	                   F2.bill_city 
                    ORDER BY CONVERT(F2.bill_country USING gbk) COLLATE gbk_chinese_ci,
                        CONVERT(F2.bill_state USING gbk ) COLLATE gbk_chinese_ci,
                        CONVERT(F2.bill_city USING gbk ) COLLATE gbk_chinese_ci);";  
    $adb->pquery($SQL,array());
    //echo $SQL."<br>";
    $SQL = "Create TEMPORARY table IF NOT EXISTS TempTable2 ignore(
            SELECT '合计：' AS bill_city,'' bill_state,'' bill_country,
            SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,SUM(T6) AS T6,SUM(T7) AS T7,
            SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12,
            SUM(totalcount) as totalcount,'' as bili
            FROM TempTable)";
            //echo $SQL."<br>";
            $adb->pquery($SQL,array());
            
    $SQL = "SELECT '合计：' AS bill_city,'' bill_state,'' bill_country,
            SUM(T1) AS T1,SUM(T2) AS T2,SUM(T3) AS T3,SUM(T4) AS T4,SUM(T5) AS T5,SUM(T6) AS T6,SUM(T7) AS T7,
            SUM(T8) AS T8,SUM(T9) AS T9,SUM(T10) AS T10,SUM(T11) AS T11,SUM(T12) AS T12,
            SUM(totalcount) as totalcount,'' as bili
            FROM TempTable";  
        $tempresult=$adb->pquery($SQL,array());    
       $coouunttotal = $adb->query_result($tempresult, 0, 'totalcount');     
    $SQL = "SELECT *,totalcount/$coouunttotal*100 as bili FROM TempTable UNION 
            SELECT * FROM TempTable2";
            //echo $SQL."<br>";
            $result=$adb->pquery($SQL,array());
        $rowCount = $adb->num_rows($result);
        
    for ($i = 0; $i < $rowCount; $i++) {    
        $productList[$i]['bill_city'] = $adb->query_result($result, $i, 'bill_city');
        $productList[$i]['bill_state'] = $adb->query_result($result, $i, 'bill_state');
        $productList[$i]['bill_country'] = $adb->query_result($result, $i, 'bill_country');
        $productList[$i]['bili'] = setNumberFormat($adb->query_result($result, $i, 'bili'));
        for($c = 1; $c < 13; $c++){
           $productList[$i]['T'.$c] = setNumberFormat($adb->query_result($result, $i, 't'.$c)); 
        }
        $productList[$i]['totalcount'] = setNumberFormat($adb->query_result($result, $i, 'totalcount'));
    }
        $sSQL5="drop TEMPORARY  table if exists TempTable;";
        $result1 = $adb->query($sSQL5); 
        $sSQL5="drop TEMPORARY  table if exists TempTable2;";
        $result1 = $adb->query($sSQL5); 
      //print_r($productList);  
    return $productList;
}
function formatMonth($month)
{
    if($month<10){
        $month='0'.$month;
    }
    return $month;
}

function getthemonth($date)
{
    $firstday = date('Y-m-01', strtotime($date));
    $lastday = date('Y-m-d', strtotime("$firstday +1 month -1 day"));
    return $lastday;
}
//页面赋值
$smarty->assign("reportname",$reportname);
$smarty->assign("YEAR",$year);//年
$smarty->assign("listValue",$listValue);
$smarty->display('Comprehensivereport/snowbearreport.tpl');
exit();
?>