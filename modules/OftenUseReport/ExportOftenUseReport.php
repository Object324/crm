<?php
/**
 * 更新操作
 * edit:can
 * date:20131104
 * reason:常用报表和自定义报表分开需求(V3.1)
 * */

if($_REQUEST['type']&&$_REQUEST['type']=='exportguiji')
{
    include(globalStatic::$root_directory."modules/OftenUseReport/ExportGuiji.php");
    exit();
}
 require_once('Smarty_setup.php');
 require_once('include/QueryGenerator/QueryGenerator.php');
 include('modules/OftenUseReport/OftenUseReport.php');
global $adb,$app_strings,$current_language,$mod_strings,$theme;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
if(isPermitted("OftenUseReport",'ExportExcel')=='no')
{
    exit('没有权限');
}
if(isset($_REQUEST['submode'])&&$_REQUEST['submode']=='SaveColumnSet')
{
   UpdateColumnSet();
}
else if(isset($_REQUEST['submode'])&&$_REQUEST['submode']=='editColumnName')
{
   UpdateColumnLabel();
}
$smarty=new lingdangCRM_Smarty();
$smarty->assign("REPORTMOD",$mod_strings);
$mod=$mod_strings;
$sql='select * from ld_version';
$result=$adb->pquery($sql,array());
$trade=$adb->query_result($result,0,'trade');
//SalesOrderImplementation:德卡报表：合同执行情况明细表
//CourseEnquiryReport:培训行业报表
if($trade=='training'){
    $parentwhere = "";
    $where = " and name not in ('SalesOrderImplementation') ";
}
else if($trade=='德卡'){
    $parentwhere = " and name not in ('CourseEnquiryReport')";
    $where = "";
}
else
{
    $parentwhere = " and name not in ('CourseEnquiryReport')";
    $where = " and name not in ('SalesOrderImplementation') ";
}
$sql='select usereportid,name from ld_usereport where parent_id=0 '.$parentwhere.' order by sequence';//获取父节点报表
$parentresult=$adb->pquery($sql,array());
$reportHeader=array();
#获取父节点下子节点报表

for($i=0;$i<$adb->num_rows($parentresult);$i++)
{
    $sqlchild='select usereportid,name from ld_usereport where parent_id=? '.$where.' order by sequence';
    $parentid=$adb->query_result($parentresult,$i,'usereportid');
    $parentlabel=getFixedLabel($adb->query_result($parentresult,$i,'name'));
    
    $childresult=$adb->pquery($sqlchild,array($parentid));
    
    for($j=0;$j<$adb->num_rows($childresult);$j++)
    {
       
        $childlabel=getFixedLabel($adb->query_result($childresult,$j,'name'));
        $childusereportid=$adb->query_result($childresult,$j,'usereportid');
        
        if($i==0&&$j==0)
        {
            //$usereportid=7;
            $usereportid=$childusereportid;//页面第一次进入获取默认查询的报表
            
        }

        
        $reportHeader[$parentlabel][]=array($childlabel=>$childusereportid);
        
    }
}

$smarty->assign("USEREPORTS",$reportHeader);
if(isset($_REQUEST['UseReport']))
{
    $usereportid=$_REQUEST['UseReport'];
}
$sql="select name from ld_usereport where usereportid=$usereportid";
$result=$adb->pquery($sql,array());
$reportnames=$adb->query_result($result,0,0);
//echo $usereportid;
#获取当前查询的报表类型
$sql='select reporttype,tabids ,basicfilter,advfilter,setcolumns,name ,pagewidthpercent from ld_usereport where usereportid=?';
$result=$adb->pquery($sql,array($usereportid));
$reporttype=$adb->query_result($result,0,0);
$reportabid=$adb->query_result($result,0,1);
$reportname=$adb->query_result($result,0,'name');
$basicfilter=$adb->query_result($result,0,'basicfilter');
$advfilter=$adb->query_result($result,0,'advfilter');
$setcolumns=$adb->query_result($result,0,'setcolumns');
$pagewidthpercent=$adb->query_result($result,0,'pagewidthpercent');
$smarty->assign('BASICFILTER',$basicfilter);
$smarty->assign('ADVFILTER',$advfilter);
$smarty->assign('SETCOLUMNS',$setcolumns);
$smarty->assign('PAGEWIDTHPERCENT',$pagewidthpercent);
$reportModule=getTabname($reportabid);

global $current_user;

if($_REQUEST['types']=='selectchange'){
   $selectid = $_REQUEST['selectid'];
   $sql="SELECT DISTINCT(ld_products.productname)   
from ld_inventoryproductrel 
INNER JOIN ld_products on ld_inventoryproductrel.productid=ld_products.productid 
where productcategory='$selectid'";
                $selectvalue=$adb->pquery($sql,array());
                $rowCounts = $adb->num_rows($selectvalue);
                for ($c = 0; $c < $rowCounts; $c++) {
                $productname[$c] = $adb->query_result($selectvalue, $c, 'productname');
                }
                //$productname=implode(",",$productname); 
                echo '###SUCCESS###'. json_encode($productname);
                exit();
                
}
#基本查询
$sql="select * from ld_usereportbasic  where usereportid=? order by sequence";
$result=$adb->pquery($sql,array($usereportid));
$basicfilterHtml="";
$month=date("m");
$datemonth=date("Y-m");
                $sqls="SELECT DISTINCT(ld_products.productcategory)   
                        from ld_inventoryproductrel 
                        INNER JOIN ld_products on ld_inventoryproductrel.productid=ld_products.productid;";
                $selectvalue=$adb->pquery($sqls,array());
                $rowCounts = $adb->num_rows($selectvalue);
                for ($c = 0; $c < $rowCounts; $c++) {
                $productcategory[$c] = $adb->query_result($selectvalue, $c, 'productcategory');
                }
                //print_r($productcategory);
                $sqls="SELECT DISTINCT(ld_products.productname)   
                        from ld_inventoryproductrel 
                        INNER JOIN ld_products on ld_inventoryproductrel.productid=ld_products.productid 
                        where ld_products.productcategory='$productcategory[0]'
                        ;";
                $selectvalue=$adb->pquery($sqls,array());
                $rowCountz = $adb->num_rows($selectvalue);
                for ($c = 0; $c < $rowCountz; $c++) {
                $productname[$c] = $adb->query_result($selectvalue, $c, 'productname');
                }
                $sqls="SELECT DISTINCT(cf_1082) FROM ld_salesordercf where cf_1082 not in ('--无--','');";
                $selectvalue=$adb->pquery($sqls,array());
                $rowCountz = $adb->num_rows($selectvalue);
                for ($c = 0; $c <$rowCountz; $c++) {
                $cf_1082[$c] = $adb->query_result($selectvalue, $c, 'cf_1082');
                }
               
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $basicInfos=explode(":",$adb->query_result($result,$i,'columns'));
    $basicdefaultvalue=$adb->query_result($result,$i,'defaultvalue');
    $fieldmodules=explode('_',$basicInfos[3]);
    $fieldModule=$fieldmodules[0];
   // echo strtolower($basicInfos[count($basicInfos)-1]);
    if(strtolower($basicInfos[count($basicInfos)-1])=="d")
    {
        $datefindcolumn=$basicInfos[0].'.'.$basicInfos[1];
        $smarty->assign("DATEFINDCOLUMN",$datefindcolumn);
      
        $basicfilterHtml.="<td>". getFixedLabel('STATISTTIME').':';
        $basicvalues[0]=$basicdefaultvalue;
        if(strpos($basicdefaultvalue,'~')>0)
        {
            $basicvalues=explode('~',$basicdefaultvalue);
           
        }
       
        foreach($basicvalues as $keyvalue=>$valuecontent)
        {
            switch($valuecontent)
            {
                case "thisstartmonth":
                    $startdatemonth=$datemonth.'-01';
                    $basicfilterHtml .="<input type='text' size=15 readonly=true value=$startdatemonth id='startmonth' name='startmonth' findcolumn= '".$adb->query_result($result,$i,'columns')."' onClick='WdatePicker()' class='Wdate'/>";
                    //$basicfilterHtml .="<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img1' onclick='showCalendar(\"startmonth\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
                    $basicfilterHtml.='</td>';
                    break;
                case "thisendmonth":
                    $enddatemonth=$datemonth.'-'.date(t,strtotime($datemonth));
                    $basicfilterHtml .="&nbsp;<td>~&nbsp;<input type='text' size=15  readonly=true value=$enddatemonth id='endmonth' name='endmonth' findcolumn= '".$adb->query_result($result,$i,'columns')."' onClick='WdatePicker()' class='Wdate'/>";
                    //$basicfilterHtml .="<img  class='popimg' src='themes/softed/images/btnL3Calendar.gif' id='img1' onclick='showCalendar(\"endmonth\",\"%Y-%m-%d\",\"true\",\"12\",this)'/>";
                    $basicfilterHtml.='</td>';
                    break;
            }
        }
        
    }
    else
    {
        if($reportnames=='CommencementSchedule'||$reportnames=='OverallCommencementSchedule'||$reportnames=='PartnerCommencementSchedule'||$reportnames=='LecturerCommencementSchedule'
        ||$reportnames=='Studentsparticipatinginthetrainingschedule'||$reportnames=='Customersparticipatinginthetrainingschedule'
        ||$reportnames=='KPCCommencementDetails'||$reportnames=='CourseparticipantsKPClist'){
            $smarty->assign("OTHERFINDCOLUMN",$basicInfos[0].'.'.$basicInfos[1]);
            $fieldsql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
             where languagetype=? and trantable=? and  fieldname=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=?)';
           // echo $basicInfos[2]."-".$fieldModule."<br>";
            //echo $fieldsql."<br>"."-";
            //echo $languageType."-".$basicInfos[2].$fieldModule;
            $fieldResult=$adb->pquery($fieldsql,array($languageType,'ld_field', $basicInfos[2],$fieldModule));
          // print_r($fieldResult);
           // echo $basicInfos[2];
            if($adb->num_rows($fieldResult)>0)
            {
                $fieldlabel=$adb->query_result($fieldResult,0,0);
            }
            else
            {
                $fieldlabel=$fieldModule[1];
            }
            $fieldlabel=$fieldlabel;
            
           if($fieldlabel=='合作伙伴'&&$reportnames=='Studentsparticipatinginthetrainingschedule'){$fieldlabel='所在公司';}
           
            if(($fieldlabel=='产品类别'||$fieldlabel=='课程类别')&&$trade=='training'){
                                                
                $basicfilterHtml.='<td>业务类别：<select name="basicotherfinds" id="basicotherfinds" onchange="DoOnchange()" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($productcategory as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
            }elseif(($fieldlabel=='课程名称'||$fieldlabel=='Product Name')&&$trade=='training'){
                $basicfilterHtml.='<td>'.$fieldlabel.'：<select name="basicotherfindz" id="basicotherfindz" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($productname as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
          }elseif($fieldlabel=='开课地点'||$fieldlabel=='cf_1084'){
                $basicfilterHtml.='<td>'.$fieldlabel.'：<input type="text"  width="120px" value="'.$basicdefaultvalue.'" name="basicotherfind2" id="basicotherfind2" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>'; 
          }elseif($fieldlabel=='讲师'||$fieldlabel=='cf_1082'){
                $basicfilterHtml.='<td>'.$fieldlabel.'：<select name="basicotherfind3" id="basicotherfind3" findcolumn=" '.$adb->query_result($result,$i,'columns').'">';
                foreach($cf_1082 as $arr){
                $basicfilterHtml.='<option value ="'.$arr.'">'.$arr.'</option>';
                }
                $basicfilterHtml.='</select></td>'; 
          }elseif($fieldlabel=='姓名'){
                $basicfilterHtml.='<td> 学员：<input type="text"  width="120px" value="'.$basicdefaultvalue.'" name="basicotherfind4" id="basicotherfind4" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>'; 
          }else{
                $basicfilterHtml.='<td>'.$fieldlabel.'：<input type="text"  width="120px" value="'.$basicdefaultvalue.'" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>'; 
            }
            
        }else{
            $smarty->assign("OTHERFINDCOLUMN",$basicInfos[0].'.'.$basicInfos[1]);
            $fieldsql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
             where languagetype=? and trantable=? and  fieldname=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=?)';
            $fieldResult=$adb->pquery($fieldsql,array($languageType,'ld_field', $basicInfos[2],$fieldModule));
            if($adb->num_rows($fieldResult)>0)
            {
                $fieldlabel=$adb->query_result($fieldResult,0,0);
            }
            else
            {
                $fieldlabel=$fieldModule[1];
            }

            $fieldlabel=($fieldlabel);
            $basicfilterHtml.='<td>'.$fieldlabel.'：<input type="text"  width="120px" value="'.$basicdefaultvalue.'" name="basicotherfind" id="basicotherfind" findcolumn=" '.$adb->query_result($result,$i,'columns').'"></td>';
        }
}
}
#常用报表首次进入默认查询
if(!isset($_REQUEST['searchtype'])&&$reportnames!='CommencementSchedule'&&$reportnames!='OverallCommencementSchedule'
        &&$reportnames!='PartnerCommencementSchedule'&&$reportnames!='LecturerCommencementSchedule'
        &&$reportnames!='Studentsparticipatinginthetrainingschedule'&&$reportnames!='Customersparticipatinginthetrainingschedule'
        &&$reportnames!='KPCCommencementDetails'&&$reportnames!='CourseparticipantsKPClist')
{
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']=$enddatemonth.' 23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
}elseif(!isset($_REQUEST['searchtype'])&&($reportnames=='CommencementSchedule'||$reportnames=='OverallCommencementSchedule'||$reportnames=='PartnerCommencementSchedule'||$reportnames=='LecturerCommencementSchedule'
        ||$reportnames=='Studentsparticipatinginthetrainingschedule'||$reportnames=='Customersparticipatinginthetrainingschedule'
        ||$reportnames=='KPCCommencementDetails'||$reportnames=='CourseparticipantsKPClist')){
    //echo $startdatemonth;
    $_REQUEST['searchtype']='BasicSearch';
    $_REQUEST['startmonth']=$startdatemonth.' 00:00:00';
    $_REQUEST['endmonth']='1200-03-01  23:59:59';
    $_REQUEST['datefindcolumn']=$datefindcolumn;
    $smarty->assign('SEARCHTYPE','BasicSearch');
}
else
{
    $smarty->assign('SEARCHTYPE',$_REQUEST['searchtype']);
    
}
$smarty->assign("BASICFILTERHTML",$basicfilterHtml);
$smarty->assign("APP",$app_strings);
#获取人员范围
$sql='select last_name ,id  from ld_users where status=\'active\' order by user_name asc';
$result=$adb->pquery($sql,array());
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $lastname=$adb->query_result($result,$i,'last_name');
    $userid=$adb->query_result($result,$i,'id');
    $arruser[$lastname]=$userid;
}
$smarty->assign("ARRUSER",$arruser);
#列头查询设置
$sql='select * from ld_UseReportcolumns where usereportid=?  order by sequence';
$result=$adb->pquery($sql,array($usereportid));
$reportFindHeader="";
$showcolLists=array();
$AllReportHeaders=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    
    $columns=$adb->query_result($result,$i,'columns');
    $realcolumns=$adb->query_result($result,$i,'realcolumns');
    $columshow=$adb->query_result($result,$i,'columnshow');
    $AllReportHeaders[]=$columns;
    //columns:表名：字段名称：fieldname:模块名称_fieldlabel:typeofdate
    $fieldlabels=explode(':',$realcolumns);
    $typeofdata=$fieldlabels[4];
    
    if($columshow!=1)
    {
        continue;
    }
    $fieldmodules=explode('_',$fieldlabels[3]);
    $fieldModule=$fieldmodules[0];
    $showcolkey=$fieldModule.'_'.$fieldlabels[1];
   
    if($columns!=$realcolumns)
    {
        $fieldlabel=substr($fieldlabels[3],strpos($fieldlabels[3],'_')+1);
        $fieldlabels=explode('_',$fieldlabels[3]);
      
        
    }
    else
    {
         
         $sql='select ld_tranlabel.fieldlabel,typeofdata from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
          where columnname=\''.$fieldlabels[1].'\' and ld_tranlabel.languagetype=\'zh\' and ld_tranlabel.tabid =(select tabid from ld_tab where name=\''.$fieldModule.'\')';
         
          $fieldResult=$adb->pquery($sql,array());
         if($adb->num_rows($fieldResult)>0)
         {
            $fieldlabel=$adb->query_result($fieldResult,0,0);
            $fieldlabel=($fieldlabel);
            $fieldlabel=getTranstab($fieldModule).'_'.$fieldlabel;
            
            $typeofdata=$adb->query_result($fieldResult,0,'typeofdata');
           
            $typeofdata=explode('~',$typeofdata);
            $typeofdata=$typeofdata[0];
         }
         else
         {
            $fieldlabel=$fieldmodules[1];
            
            if(array_key_exists($fieldlabel,$mod))//获取在页面设置中没有标签的报表字段label
            {
                $fieldlabel=$mod[$fieldlabel];
            }
         }
    }
  
         $reportFindHeader.='<td class="rptCellLabel">'.$fieldlabel.'</td>';
  $exportheader[] = $fieldlabel;
     $showcolLists[ $showcolkey.':'.$typeofdata]=array($columshow=>$fieldlabels[0]);
     
    //$reportFindHeader.='<td class="lvtCol"><a onclick="getListViewEntries_js(&quot;Vendors&quot;,&quot;parenttab=Purchase&amp;foldername=Default&amp;order_by=vendor_no&amp;start=&amp;sorder=ASC&quot;);" href="javascript:;">'.$fieldlabel.'</a></td>';
}
/**
 * 更新操作
 * edit:can
 * date:20131223
 * reason:06420: 常用报表后面缺少“查看数据”列，需求上有要求，希望加上，点击之后，应该能够打开对应单据的查看明细界面。
 * */
if($reporttype==10)
{
    $showcolLists[ 'lbl_action'.':V']=array(1=>'操作');
     $reportFindHeader.='<td class="rptCellLabel">操作</td>';
}
//print_r($showcolLists);
$smarty->assign('REPORTFINDHEADER',$reportFindHeader);
//editor:gyq_122 reason:删除__construct复杂参数，抽成新方法init_params 2019/6/13 17:28
$OftenUseReport=new OftenUseReport();
$OftenUseReport->init_params($reporttype,$reportname,$usereportid,$adb,$showcolLists,$AllReportHeaders,$reportabid);
$smarty->assign('REPORTFILTERHTML',$OftenUseReport->getReportListView());

$smarty->assign("USEREPORTID",$usereportid);

#高级查询下拉框
$columns_block=getadvDropHtml($reportabid);
$smarty->assign("COLUMNS_BLOCK",$columns_block[0]);
$smarty->assign("FOPTION",getAdvCriteriaHTML());

$smarty->assign("REL_FIELDS",Zend_Json::encode($columns_block[1]));

if($_REQUEST['searchtype']=='advSearch')
{
    require_once 'include/Zend/Json.php';
    $json = new Zend_Json();
    
    $advft_criteria = $_REQUEST['advft_criteria'];
    if(!empty($advft_criteria)) $advft_criteria = $json->decode($advft_criteria);
    $advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
    if(!empty($advft_criteria_groups)) $advft_criteria_groups = $json->decode($advft_criteria_groups);
       
}


#高级查询保存
if(isset($_REQUEST['submode'])&& $_REQUEST['submode']=='saveCriteria')
{
    	
        updateUseReportCriteria($usereportid,$advft_criteria,$advft_criteria_groups);
}
#读取高级查询
$advft_criteria=getAdvancedFilterList($usereportid);

$csc = explode("</tr>",$OftenUseReport->getReportListView());

//foreach($csc as $arr){
   //$cscs[] = explode("</td>",$arr); 
//}

//foreach($cscs as $key=>$arr){
    //foreach($arr as $key2=>$arr2){
        //$listview_entrie[$key+2][$key2]=strip_tags($arr2);
    //}
//}
//$upid=array(6,7,8,19,20,21,22,23,24,25,26);

//foreach($listview_entrie as $key=>$arr){
    //array_pop($listview_entrie[$key]);
    //if(in_array($_REQUEST['UseReport'],$upid) ){
    //}else{
         //array_pop($listview_entrie[$key]);
    //}
    
//}
////print_r($listview_entrie);die();
//foreach($listview_entrie as $key=>$arr){
    //foreach($arr as $key2=>$arr2){
        //if($arr2=='&nbsp;'){
            //$listview_entrie[$key][$key2]='';
        //}
    //}
//}
//print_r($exportheader);die();
include('PHPExcel/PHPExcel.php');
$objPHPExcel = new PHPExcel();
$objPHPExcel->setActiveSheetIndex(0);
$activesheet=$objPHPExcel->getActiveSheet();
foreach($exportheader as $key=>$arr){
    $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key).'1',$arr);
}
/*
andrwe
20140729
嘉博联系人报表参训人数为空列，将$upid改成$reporttype来判断不为10的不会添加更多信息
*/
//20,21,22,
//$upid=array(6,7,8,19,23,24,25,26);
$j = 2;
foreach($csc as $arr){
	$cscs = explode("</td>",$arr);
	//array_pop($cscs);
    $for_i = 0;
//	if(!in_array($_REQUEST['UseReport'],$upid)){
    if($reporttype==10){
	   array_pop($cscs);
       array_pop($cscs);
	}
		
	foreach($cscs as $value){
		$value = strip_tags(trim($value));
		if($value == '&nbsp;'){
			$value = '';
		}
		$value = decode_html($value);
		$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($for_i).$j,$value);
		++ $for_i;
	}
	++ $j;
}
//foreach($listview_entrie as $key=>$arr){
    //foreach($arr as $key2=>$arr2){
       //$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($key2).$key,$arr2); 
    //}
//}

$modulelabel = getTranstab('OftenUseReport');
$modulelabel = str_replace(' ','_',iconv('UTF-8','gbk',$modulelabel));
$file_name = 'OftenUseReport.xls';
$file_dir = './storage/';

$objPHPExcel->getActiveSheet()->setTitle('OftenUseReport');
$objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');
$objWriter->save($file_dir.$file_name);

header('Location: index.php?module=ReportAnalysis&action=ExportReport&ReportHeader=dheader&modulelabel='.$reportname.'');
exit();

function getAdvCriteriaHTML($selected="") {
    $adv_filter_options = array("e" => "" . getFixedLabel('EQ') . "",
	"n" => "" . getFixedLabel('NEQ')  . "",
	"s" => "" . getFixedLabel('Begins') . "",
	"ew" => "" .getFixedLabel('Ends') . "",
	"c" => "" . getFixedLabel('IN')  . "",
	"k" => getFixedLabel('NOT_IN'),
	"l" => getFixedLabel('LT'),
	"g" => getFixedLabel('GT'),
	"m" => getFixedLabel('LE'),
	"h" =>getFixedLabel('GE'),
	"b" => getFixedLabel('Before'),
	"a" => getFixedLabel('After'),
	"bw" => getFixedLabel('Interval'),
);
        
		foreach($adv_filter_options as $key=>$value) {
			if($selected == $key) {
				$shtml .= "<option selected value=\"".$key."\">".$value."</option>";
			} else {
				$shtml .= "<option value=\"".$key."\">".$value."</option>";
			}
		}
		return $shtml;
	}
function getadvDropHtml($reporttabid)
{
    global $adb,$current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $reporttab=getTabname($reporttabid);
  
    $sql='select distinct blockid,ld_tranlabel.fieldlabel as blocklabel  from ld_blocks 
        inner join ld_field  on ld_field.block=ld_blocks.blockid 
        inner join ld_tranlabel on ld_tranlabel.relateid=ld_blocks.blockid
        where languagetype=? and trantable=? and  ld_tranlabel.tabid=? and displaytype != 3 and ld_field.presence in (0,2)  order by ld_blocks.sequence asc';
    
    $resulttt=$adb->pquery($sql,array($languageType,'ld_Blocks', $reporttabid));
    $advFilterHtml="";
    $roofrows=$adb->num_rows($resulttt);
    for($i=0;$i<$roofrows;$i++)
    {
         $blocklabel=$adb->query_result($resulttt,$i,'blocklabel');
         $blockid=$adb->query_result($resulttt,$i,'blockid');
         $sql='select tablename,columnname,fieldname,ld_tranlabel.fieldlabel,typeofdata from ld_field  
         inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
          where languagetype=? and trantable=? and  ld_tranlabel.tabid=?  and block=? and ld_field.presence in(0,2) order by sequence asc  ';
         $fieldresult=$adb->pquery($sql,array($languageType,'ld_field',$reporttabid,$blockid));
         $modulelabel=($blocklabel);
         $advFilterHtml.="<optgroup label=\"$modulelabel\" > ";
         
         for($j=0;$j<$adb->num_rows($fieldresult);$j++)
         {
            $tablename=$adb->query_result($fieldresult,$j,'tablename');
            $columnname=$adb->query_result($fieldresult,$j,'columnname');
            $fieldname=$adb->query_result($fieldresult,$j,'fieldname');
            $fieldlabel=$adb->query_result($fieldresult,$j,'fieldlabel');
           // $fieldlabel=getTranslatedString($fieldlabel,$reporttab);
            $typeofdate=$adb->query_result($fieldresult,$j,'typeofdata');
            $typeofdate=explode('~',$typeofdate);
            $typeofdate=$typeofdate[0];
            if($typeofdate!='DT'&&$typeofdate!='D')
            {
                $typeofdate='V';
            }
            $value=$tablename.':'.$columnname.':'.$reporttab.'_'.str_replace(' ','_',$fieldlabel).':'.$fieldname.':'.$typeofdate;
           	$adv_rel_fields[$typeofdate][] = '$'.$reporttab.'#'.$fieldname.'$'."::".getTranstab($reporttab)." ".($fieldlabel);
            $advFilterHtml.="<option value=\"".$value."\"> ".($fieldlabel)." </option>";
            
         }
         $advFilterHtml.=" </optgroup>";
    }
  $advfilter[0]=$advFilterHtml;
  $advfilter[1]=$adv_rel_fields;
    return $advfilter;
   
}
function opChildLabel($childlabel)
{
   // global $app_strings;
    $prevfix=substr($childlabel,0,strpos($childlabel,'{'));
   if(!isset($prevfix))
   {
    $prevfix="";
   }
    $module=substr($childlabel,strpos($childlabel,'{')+2,strpos($childlabel,'}')-strpos($childlabel,'{')-2);
    $lastfix=substr($childlabel,strpos($childlabel,'}')+1);
    
    $modulelabel=getTranstab($module);
   
    $childlabel=$prevfix.$modulelabel.$lastfix;
   
    return $childlabel;
}



function updateUseReportCriteria($reportid, $advft_criteria, $advft_criteria_groups) {

	global $adb;

	$idelrelcriteriasql = "delete from ld_usereportadv where reportid=?";
	$idelrelcriteriasqlresult = $adb->pquery($idelrelcriteriasql, array($reportid));

	$idelrelcriteriagroupsql = "delete from ld_usereportadv_grouping where reportid=?";
	$idelrelcriteriagroupsqlresult = $adb->pquery($idelrelcriteriagroupsql, array($reportid));

	if(empty($advft_criteria)) return;

	foreach($advft_criteria as $column_index => $column_condition) {

		if(empty($column_condition)) continue;

		$adv_filter_column = $column_condition["columnname"];
		$adv_filter_comparator = $column_condition["comparator"];
		$adv_filter_value = $column_condition["value"];
		$adv_filter_column_condition = $column_condition["columncondition"];
		$adv_filter_groupid = $column_condition["groupid"];

		$column_info = explode(":",$adv_filter_column);
		$moduleFieldLabel = $column_info[2];
		$fieldName = $column_info[3];

		list($module, $fieldLabel) = explode('_', $moduleFieldLabel, 2);
		$fieldInfo = getFieldByReportLabel($module, $fieldLabel);
		$fieldType = null;
		if(!empty($fieldInfo)) {
			$field = WebserviceField::fromArray($adb, $fieldInfo);
			$fieldType = $field->getFieldDataType();
		}
		if($fieldType == 'currency') {
			// Some of the currency fields like Unit Price, Total, Sub-total etc of Inventory modules, do not need currency conversion
			if($field->getUIType() == '72') {
				$adv_filter_value = CurrencyField::convertToDBFormat($adv_filter_value, null, true);
			} else {
				$adv_filter_value = CurrencyField::convertToDBFormat($adv_filter_value);
			}
		}

		$temp_val = explode(",",$adv_filter_value);
		if(($column_info[4] == 'D' || ($column_info[4] == 'T' && $column_info[1] != 'time_start' && $column_info[1] != 'time_end') || ($column_info[4] == 'DT')) && ($column_info[4] != '' && $adv_filter_value != '' ))
		{
			$val = Array();
			for($x=0;$x<count($temp_val);$x++) {
				if(trim($temp_val[$x]) != '') {
					$date = new DateTimeField(trim($temp_val[$x]));
					if($column_info[4] == 'D') {
						$val[$x] = DateTimeField::convertToUserFormat(
								trim($temp_val[$x]));
					} elseif($column_info[4] == 'DT') {
						$val[$x] = $date->getDBInsertDateTimeValue();
					} else {
						$val[$x] = $date->getDBInsertTimeValue();
					}
				}
			}
			$adv_filter_value = implode(",",$val);
		}

		$irelcriteriasql = "insert into ld_usereportadv (reportid,COLUMNINDEX,COLUMNNAME,COMPARATOR,VALUE,GROUPID,COLUMN_CONDITION) values (?,?,?,?,?,?,?)";
		$irelcriteriaresult = $adb->pquery($irelcriteriasql, array($reportid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));

		// Update the condition expression for the group to which the condition column belongs
		$groupConditionExpression = '';
		if(!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
			$groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
		}
		$groupConditionExpression = $groupConditionExpression .' '. $column_index .' '. $adv_filter_column_condition;
		$advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
	}

	foreach($advft_criteria_groups as $group_index => $group_condition_info) {

		if(empty($group_condition_info)) continue;
		if(empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

		$irelcriteriagroupsql = "insert into ld_usereportadv_grouping(GROUPID,reportid,GROUP_CONDITION,CONDITION_EXPRESSION) values (?,?,?,?)";
		$irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $reportid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
	}
}
function getFieldByReportLabel($module, $label) {

	// this is required so the internal cache is populated or reused.
	
	//lookup all the accessible fields

    global $adb;
    $fieldobj=Field::getInstance($module,$adb);
      $cachedModuleFields=$fieldobj->getFieldInfoList();
	if(empty($cachedModuleFields)) {
		return null;
	}
	foreach ($cachedModuleFields as $fieldInfo) {
		$fieldLabel = str_replace(' ', '_', $fieldInfo['fieldlabel']);
		if($label == $fieldLabel) {
			return $fieldInfo;
		}
	}
	return null;
}
	function getAdvancedFilterList($reportid)
	{
		global $adb;
		global $modules;
		
		global $current_user;

		$advft_criteria = array();
		$sql = 'SELECT * FROM ld_usereportadv_grouping WHERE reportid = ? ORDER BY groupid';
		$groupsresult = $adb->pquery($sql, array($reportid));
		$i = 1;
		
		while($relcriteriagroup = $adb->fetch_array($groupsresult)) {
			$groupId = $relcriteriagroup["groupid"];
			$groupCondition = $relcriteriagroup["group_condition"];

			$ssql = 'select ld_usereportadv.* from ld_usereport
						inner join ld_usereportadv on ld_usereportadv.reportid = ld_usereport.usereportid
						left join ld_usereportadv_grouping on ld_usereportadv.reportid = ld_usereportadv_grouping.reportid
								and ld_usereportadv.groupid = ld_usereportadv_grouping.groupid';
			$ssql.= " where ld_usereport.usereportid = ? AND ld_usereportadv.groupid = ? order by ld_usereportadv.columnindex";
            //echo $ssql;
			$result = $adb->pquery($ssql, array($reportid, $groupId));
			$noOfColumns = $adb->num_rows($result);
            
			if($noOfColumns <= 0) continue;
            $j = 0;
			while($relcriteriarow = $adb->fetch_array($result)) {
				$columnIndex = $relcriteriarow["columnindex"];
				$criteria = array();
               
				$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"]);
			     
                $criteria['comparator'] = $relcriteriarow["comparator"];
				$advfilterval = $relcriteriarow["value"];
				$col = explode(":",$relcriteriarow["columnname"]);
				$moduleFieldLabel = $col[2];
				$fieldName = $col[3];
                $tablename=$col[0];
                $columnname=$col[1];
                $arrLabel=explode("_",$moduleFieldLabel);
                $tabname=$arrLabel[0];
                $tabid=getTabid($tabname);
                $sql="select fieldlabel from ld_Field where tabid=? and columnname=? ";
                $resultfield=$adb->pquery($sql,array($tabid,$columnname));
                
                $tabFieldlable=$adb->query_result($resultfield,0,0);
              if(!empty($tabFieldlable))
              {
              
                     if(count(explode(' ',$tabFieldlable))<=0)
                    {
                        $criteria['columnname']= $tablename.":".$columnname.":".$tabname."_".$tabFieldlable.":".$fieldName.":".$col[4];
                    }
                    else 
                    {
                        $strlabelArr=explode(' ',$tabFieldlable);
                        $strLabel=$strlabelArr[0];
                        
                        for($jk=1;$jk<count($strlabelArr);$jk++)
                        {
                             $strLabel .="_".$strlabelArr[$jk];
                        }
                        $criteria['columnname']= $tablename.":".$columnname.":".$tabname."_".$strLabel.":".$fieldName.":".$col[4];
                    }
              }
               
                //echo    $criteria['columnname'];
				list($module, $fieldLabel) = explode('_', $moduleFieldLabel, 2);
				$fieldInfo = getFieldByReportLabel($module, $fieldLabel);
				$fieldType = null;
				if(!empty($fieldInfo)) {
					$field = WebserviceField::fromArray($adb, $fieldInfo);
					$fieldType = $field->getFieldDataType();
				}
				if($fieldType == 'currency') {
					if($field->getUIType() == '71') {
						$advfilterval = CurrencyField::convertToUserFormat($advfilterval,$current_user);
					} else if($field->getUIType() == '72') {
						$advfilterval = CurrencyField::convertToUserFormat($advfilterval,$current_user,true);
					}
				}

				$temp_val = explode(",",$relcriteriarow["value"]);
				if($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
					$val = Array();
					for($x=0;$x<count($temp_val);$x++) {
                        if($col[4] == 'D') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayDate();
						} elseif($col[4] == 'DT') {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayDateTimeValue();
						} else {
							$date = new DateTimeField(trim($temp_val[$x]));
							$val[$x] = $date->getDisplayTime();
						}
					}
					$advfilterval = implode(",",$val);
				}
				$criteria['value'] = decode_html($advfilterval);
				$criteria['column_condition'] = $relcriteriarow["column_condition"];
				$advft_criteria[$i]['columns'][$j] = $criteria;
				$advft_criteria[$i]['condition'] = $groupCondition;
				$j++;
			}
			$i++;
		}
		// Clear the condition (and/or) for last group, if any.
		if(!empty($advft_criteria[$i-1]['condition'])) $advft_criteria[$i-1]['condition'] = '';
	//	print_r($advft_criteria);
        return $advft_criteria;
       
		$log->info("Reports :: Successfully returned getAdvancedFilterList");
		return true;
	}
	
    /**
     * 更新操作
     * edit:can
     * date:20131129
     * reason:显示列设置保存
     * */
    function UpdateColumnSet()
    {
        global $adb;
        $selectcolumnstring=$_REQUEST['selectedAssmablyColumnsString'];
        $showcolumns=explode(',',$selectcolumnstring);
        $showcolumns=array_filter($showcolumns);
        $usereportid=$_REQUEST['UseReport'];
        $sql='select * from ld_usereportcolumns where Usereportid=? order by sequence asc';
        $result=$adb->pquery($sql,array($usereportid));
        $countshowcolumns=count($showcolumns)+4;
        $j=3;
       
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $id=$adb->query_result($result,$i,'id');
            
            if(in_array($id,$showcolumns))
            {
                //echo array_search($id,$showcolumns).'<br>';
                $sqlcolumns='update ld_usereportcolumns set sequence=?,columnshow=1 where  id=?';
                $adb->pquery($sqlcolumns,array(array_search($id,$showcolumns)+3,$id));
               
            }
            else
            {
                $sqlcolumns='update ld_usereportcolumns set sequence=?,columnshow=0 where id=?';
                $adb->pquery($sqlcolumns,array($countshowcolumns,$id));
                $countshowcolumns+=3;
            }
        }
         $sql="update ld_usereport set pagewidthpercent=? where usereportid=?";
         $adb->pquery($sql,array($_REQUEST['pagewidth'],$usereportid));
    }
    /**
     * 更新操作
     * edit:can
     * date:20131129
     * reason:常用报表列名称修改（V3.1)
     * */
    function UpdateColumnLabel()
    {
        global $adb;
        $columnsid=$_REQUEST['columnid'];
        $columnsid=explode(',',$columnsid);
        $columnsid=array_filter($columnsid);
        for($i=0;$i<count($columnsid);$i++)
        {
            $j=$i+1;
            $fieldlabel=$_REQUEST['txt'.$j];
           
            $sql='select realcolumns from ld_usereportcolumns where id=?';
            $result=$adb->pquery($sql,array($columnsid[$i]));
            if($adb->num_rows($result)>0)
            {
                $realcolumns=$adb->query_result($result,0,0);
                $columnlabels=explode(':',$realcolumns);
                $fieldlabels=explode('_',$columnlabels[3]);
                $fieldlabel=$fieldlabels[0].'_'.$fieldlabel;
                $realcolumns=$columnlabels[0].':'.$columnlabels[1].':'.$columnlabels[2].':'.$fieldlabel.':'.$columnlabels[4];
               
                $sql='update  ld_usereportcolumns set realcolumns=? where id=?';
                $adb->pquery($sql,array($realcolumns,$columnsid[$i]));
                
            }
            
        }
    }
?>