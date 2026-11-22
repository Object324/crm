<?php

require('user_privileges/user_privileges_'.$current_user->id.'.php');
global $adb;
$workcalender_id=$_REQUEST['workcalender_id'];
$workingdaytype=$_REQUEST['workingdaytype'];
$selected_date=$_REQUEST['selected_date'];
//$start_year=$_REQUEST['start_year'];
//$hol_year=$_REQUEST['hol_year'];
//$spec_year=$_REQUEST['spec_year'];
//$operatetype = $_REQUEST['operatetype'];
$special=$_REQUEST['special'];
$holiday=$_REQUEST['holiday'];
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
$selectdateArr=explode(',',$selected_date);
$remark=$_REQUEST['remark'];
if($workingdaytype=='special'){
    $workingdaytype=1;
}else{
    $workingdaytype=2;
}
foreach($selectdateArr as $key=>$val){
            $workcalender_year=substr(trim($val),0,4);
            $work_year=$workcalender_year;
            $selected_date=$val;
            $selected_remark=$remark;
            $selected_worktype=$workingdaytype;
            $selectedArr[$work_year][trim($selected_date)]=array(
                'date' => $selected_date,
                'workingdaytype' => $selected_worktype,
                'remark' => $selected_remark
            
            );
}

foreach($def_Arr as $year_k=>$val_k){
     if(array_key_exists($year_k,$selectedArr)){
        foreach($val_k as $k=>$v){
            if(!array_key_exists($k,$selectedArr[$year_k])){
                $selectedArr[$year_k]=array_merge($val_k,$selectedArr[$year_k]);
            }
        }
     }else{
        $selectedArr[$year_k]=$val_k;
     }
}
//echo '<pre>';
//print_r($selectedArr);
//die;
$selectedArr_Json = Zend_Json::encode($selectedArr);

echo  '##&&'.$selectedArr_Json.'##&&';die;
?>