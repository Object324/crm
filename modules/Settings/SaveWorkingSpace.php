<?php
$adb;
$workcalender_id=$_REQUEST['workcalender_id'];
$operatetype=$_REQUEST['operatetype'];
$workcalender_name=$_REQUEST['workcalender_name'];
$defworkday=$_REQUEST['defworkday'];
$special=$_REQUEST['special'];//获取界面特殊工作日
$holiday=$_REQUEST['holiday'];//获取界面节假日
$def_working=$_REQUEST['def_workingday'];
$def_workingday=Zend_Json::decode($def_working);
if(!empty($special)){
  $def_specialday=explode('）',$special);  
}
$def_spec_type=1;
$def_hol_type=2;
$def_spec_Arr=array();
$def_hol_Arr=array();
foreach($def_specialday as $spec_key=>$spec_val){
    $def_spec_year=substr(trim($spec_val),0,4);
    $def_spec_date=substr(trim($spec_val),0,10);
    $def_spec_remark=substr(trim($spec_val),13);
    $def_spec_Arr[$def_spec_year][$def_spec_date]=array(
            'date' => $def_spec_date,
            'workingdaytype' => $def_spec_type,
            'remark' => $def_spec_remark
    );
}

if(count($def_spec_Arr)>1){//去除切割导致的数组最后一个元素
    unset($def_spec_Arr[0]);
}
if(!empty($holiday)){
  $def_holiday=explode('）',$holiday);  
}
foreach($def_holiday as $hol_key=>$hol_val){
    $def_hol_year=substr(trim($hol_val),0,4);
    $def_hol_date=substr(trim($hol_val),0,10);
    $def_hol_remark=substr(trim($hol_val),13);
    $def_hol_Arr[$def_hol_year][$def_hol_date]=array(
            'date' => $def_hol_date,
            'workingdaytype' => $def_hol_type,
            'remark' => $def_hol_remark
    );
}
if(count($def_hol_Arr)>1){
    unset($def_hol_Arr[0]);
}
$def_Arr=$def_spec_Arr;
foreach($def_hol_Arr as $hol_year=>$hol_info){
      if(array_key_exists($hol_year,$def_Arr)){
        $def_Arr[$hol_year]=array_merge($hol_info,$def_Arr[$hol_year]);
      }else{
        $def_Arr[$hol_year]=$hol_info;
      }  
}
$checkquery='SELECT workcalender_name from ld_workcalender';
if($operatetype=='edit')
{
$checkquery.=' where workcalender_id not IN ('.$workcalender_id.')';
}
$checkresult=$adb->pquery($checkquery);
$num_rows=$adb->num_rows($checkresult);
if($num_rows>0)
{
    for($i=0;$i<$num_rows;$i++){
    $check_workcal_name[]=$adb->query_result($checkresult,$i,'workcalender_name');   
    }
}  
if(in_array($workcalender_name,$check_workcal_name)){ //判断工作日历名称是否已存在；       
    echo 'Duplicate';
}
else{
    if($operatetype=='edit')
    {
        $update_query="UPDATE ld_workcalender SET workcalender_name=\"$workcalender_name\",defined_working_day=\"$defworkday\"
                       WHERE workcalender_id=$workcalender_id";
        $adb->pquery($update_query);
    }
    else{
        $insertquery="INSERT INTO ld_workcalender(workcalender_name,defined_working_day) 
                       VALUES('$workcalender_name','$defworkday')";
        $adb->pquery($insertquery);
        $selSql='select max(workcalender_id) as workcalender_id from ld_workcalender';
        $sel_result=$adb->pquery($selSql); 
        $workcalender_id=$adb->query_result($sel_result,0,'workcalender_id');           
    }
}
//插入工作日;
$insertSQL='INSERT INTO ld_workingdays(workcalender_year,date,workingdaytype,remark,workcalender_id)
             VALUES(?,?,?,?,?)';
foreach($def_Arr as $year=>$valInfo){
    foreach($valInfo as $date_k=>$val){
        $workcalender_year=$year;
        $date=$val['date'];
        $workingdaytype=$val['workingdaytype'];
        $remark=$val['remark'];
        $checkedSql="SELECT 1 from ld_workingdays where workcalender_year=\"$workcalender_year\"  AND date=\"$date\"  and workcalender_id=$workcalender_id";
        $checkedResult=$adb->pquery($checkedSql);
        $num=$adb->num_rows($checkedResult);
        if($num>0){//如果已经存在工作日,则先删除，再插入数据；
            $delSql="DELETE from ld_workingdays where workcalender_year=\"$workcalender_year\"  AND date=\"$date\"  and workcalender_id=$workcalender_id";
            $adb->pquery($delSql);
        } 
        //echo '<pre>';
        //print_r(array($workcalender_year,$date,$workingdaytype,$remark,$workcalender_id));
        $adb->pquery($insertSQL,array($workcalender_year,$date,$workingdaytype,$remark,$workcalender_id));
        }
}
//删除工作日
if(count($def_workingday)>0){
    foreach($def_workingday as $year_ke=>$val_ke){
        foreach($val_ke as $date_ke=>$valinfo_ke){
            if(!array_key_exists($date_ke,$def_Arr[$year_ke])){
                $date=$valinfo_ke['date'];
                $del_Sql="DELETE from ld_workingdays where workcalender_year=\"$year_ke\"  AND date=\"$date\"  and workcalender_id=$workcalender_id";
                $adb->pquery($del_Sql);        
            }
        }
   }
}

?>