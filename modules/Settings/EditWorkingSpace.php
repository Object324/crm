<?php
global $adb;
require('user_privileges/user_privileges_'.$current_user->id.'.php');
$pop_portion = vtlib_purify($_REQUEST['pop_portion']);
$operatetype = vtlib_purify($_REQUEST['operatetype']);
$definedworkingday_zh= array(1=>'星期一',2=>'星期二',3=>'星期三',4=>'星期四',5=>'星期五',6=>'星期六',7=>'星期日');
$definedworkingday_en= array(1=>'Mon',2=>'Tues',3=>'Wed',4=>'Thur',5=>'Fri',6=>'Sat',7=>'Sun'); 
if ($languageType == 'zh')
{
    $definedworkingday=$definedworkingday_zh;
}
else{
    $definedworkingday=$definedworkingday_en;
}
if($operatetype!='edit')//新增工作日历
{
  $workcalender_id=""; 
  $operatetype="";  
  for($j=1;$j<=count($definedworkingday);$j++)
  {  
     if($j>0&&$j<6)
     {
        $checked='checked';
     }
     else{
        $checked='';
     }
     $defworkdaysHtml.='<input type="checkbox" class="input-btn-align" name="defworkday" id="defworkday_'.$j.'" value="'.$j.'"'.$checked.'/>';
     $defworkdaysHtml.='<label>&nbsp;'.$definedworkingday[$j].'&nbsp;&nbsp;</label>';
  }   
}
else
{
  $workcalender_id = vtlib_purify($_REQUEST['workcalender_id']);   
  $query='SELECT workcalender_name,defined_working_day from ld_workcalender where workcalender_id=?';
  $result=$adb->pquery($query,array($workcalender_id));
  $num_rows = $adb->num_rows($result);
  if($num_rows>0)
  {    
    $workcalender_name=$adb->query_result($result,$i,'workcalender_name');
    $defined_working_day=$adb->query_result($result,$i,'defined_working_day');
    $defined_working_days=explode(',',$defined_working_day);
    for($i=1;$i<=count($defined_working_days);$i++)
    {
        if($defined_working_days[$i-1]==1)
        {
           $checked='checked';
        }
        else
        {
           $checked='';  
        }
    $defworkdaysHtml.='<input type="checkbox"  class="input-btn-align" name="defworkday" id="defworkday_'.$i.'" value="'.$i.'"'.$checked.'/>';
    $defworkdaysHtml.='<label>&nbsp;'.$definedworkingday[$i].'&nbsp;&nbsp;</label>';
  } 
 }    
}

if(isset($_REQUEST['start_spec_year']) && $_REQUEST['start_spec_year'] != '')
{//切换年份时刷新事件；
    $start_spec_year = vtlib_purify($_REQUEST['start_spec_year']);    
}
else{
   $start_spec_year=date("Y");        
}
if(isset($_REQUEST['start_hol_year']) && $_REQUEST['start_hol_year'] != '')
{//切换年份时刷新事件；
    $start_hol_year= vtlib_purify($_REQUEST['start_hol_year']);    
}
else{
   $start_hol_year=date("Y");        
}
$special_workingdayHtml='<div id="specialworkingday">';
$special_workingdayHtml.='<table class="D_pop_bod" width="100%"  border="0" cellspacing="1" cellpadding="0">'; 
$special_workingdayHtml.='<tr>'; 
$special_workingdayHtml.='<td colspan="2" style="background-color:#fafafa;">';
$special_workingdayHtml.='<input type="button" class="btn_lt" value="&lt;" onclick="getWorkingdayEntries_js(\'pre\',\'pop_special\')"/>';
$special_workingdayHtml.='<strong class="mar_lr5">'.$start_spec_year.'</strong>';
$special_workingdayHtml.='<input type="button" class="btn_lt" value="&gt;" onclick="getWorkingdayEntries_js(\'next\',\'pop_special\')"/>';
$special_workingdayHtml.='<strong>&nbsp;&nbsp;'.getFixedLabel('SPECIALWORKINGDAYS').'</strong>';
$special_workingdayHtml.='&nbsp;'.getFixedLabel('NOTEDEFAULTHOLIDAYDAYNEEDTOWORK');
$special_workingdayHtml.='</td>';
$special_workingdayHtml.='<td style="background-color:#fafafa;" align="center">';
$special_workingdayHtml.='<a href="javascript:void(0);" onclick="AddWorkingday(\''.$workcalender_id.'\',\''.$operatetype.'\',\''.$languageType.'\',\'special\')">'.getFixedLabel('ADDITIONAL').'</a>';
$special_workingdayHtml.='</td>';
$special_workingdayHtml.='</tr>';
$special_workingdayHtml.='<tr>';
$special_workingdayHtml.='<td colspan="3">';

$holvalHtml='<div id="holiday_valcation">';
$holvalHtml.='<table class="D_pop_bod" width="100%"  border="0" cellspacing="1" cellpadding="0">'; 
$holvalHtml.='<tr>'; 
$holvalHtml.='<td colspan="2" style="background-color:#fafafa">';
$holvalHtml.='<input type="button" class="btn_lt" value="&lt;" onclick="getWorkingdayEntries_js(\'pre\',\'holval_pop\')"/>';
$holvalHtml.='<strong class="mar_lr5">'.$start_hol_year.'</strong>';
$holvalHtml.='<input type="button" class="btn_lt" value="&gt;" onclick="getWorkingdayEntries_js(\'next\',\'holval_pop\')"/>';
$holvalHtml.='<strong>&nbsp;&nbsp;'.getFixedLabel('HOLIDAYANDVACATIONS').'</strong>';
$holvalHtml.='&nbsp;'.getFixedLabel('NOTEDEFAULTWORKDAYSETHOLIDAY');
$holvalHtml.='</td>';
$holvalHtml.='<td style="background-color:#fafafa" align="center">';
$holvalHtml.='<a href="javascript:void(0);" onclick="AddWorkingday(\''.$workcalender_id.'\',\''.$operatetype.'\',\''.$languageType.'\',\'vacation\')">'.getFixedLabel('ADDITIONAL').'</a>';
$holvalHtml.='</td>';
$holvalHtml.='</tr >';
$holvalHtml.='<tr>';
$holvalHtml.='<td colspan="3">';
$workingday_query='
                    SELECT workingdays_id,date,workingdaytype,remark ,workcalender_year
                    FROM	ld_workingdays 
                    WHERE workcalender_id=? '; 
$workingday_result=$adb->pquery($workingday_query,array($workcalender_id));
$workingday_numrows=$adb->num_rows($workingday_result);
if($workingday_numrows>0)
{
   for($j=0;$j<$workingday_numrows;$j++)
   {
     $workcalender_year=$adb->query_result($workingday_result,$j,'workcalender_year');
     $workingdays_id=$adb->query_result($workingday_result,$j,'workingdays_id');
     $date=$adb->query_result($workingday_result,$j,'date');
     $workingdaytype=$adb->query_result($workingday_result,$j,'workingdaytype');
     $remark=$adb->query_result($workingday_result,$j,'remark');
     
     $selectdateArr[$workcalender_year][$date]=array(
        'date' => $date,
        'workingdaytype' => $workingdaytype,
        'remark' => $remark
     ); 
   }    
}
$def_workday=Zend_Json::encode($selectdateArr);
if(isset($_REQUEST['attr_selectdate'])&&$_REQUEST['attr_selectdate']!=''){
    $attr_selectdate=$_REQUEST['attr_selectdate'];
    $selectdateArr=Zend_Json::decode($attr_selectdate);
}
foreach($selectdateArr as $year=>$workingdayInfo){    
     $special_workingdayHtml.='<div id=\'special_'.$year.'\'  class="holidaydate"  style=" display:none "><ul>';
     $holvalHtml.='<div id=\'hol_'.$year.'\'  class="holidaydate"  style=" display:none "><ul>';
     foreach($workingdayInfo as $date=> $workingday){
        if($workingday['workingdaytype']==1){
            $special_workingdayHtml.='<li  id="specialworkingdays_'.$date.'"> ';
            $special_workingdayHtml.='<span><strong>'.$workingday['date'].'</strong>（'.$workingday['remark'].'）</span>';
            $special_workingdayHtml.='<a href="javascript:void(0);" onclick="DeleteWorkingday(\''.$date.'\',\'special\')">×</a>';  
            $special_workingdayHtml.='</li>';
         }
         else{
            $holvalHtml.='<li id="holiday_valcation_'.$date.'">';
            $holvalHtml.='<span><strong>'.$workingday['date'].'</strong>（'.$workingday['remark'].'）</span>';
            $holvalHtml.='<a href="javascript:void(0);" onclick="DeleteWorkingday(\''.$date.'\',\'holiday_valcation\')">×</a>';  
            $holvalHtml.='</li>';        
         }
     }
     $special_workingdayHtml.='</ul></div>'; 
     $holvalHtml.='</ul></div>'; 
} 
$special_workingdayHtml.='</td>';
$special_workingdayHtml.='</tr>';    
$special_workingdayHtml.='</table>';
$special_workingdayHtml.='</div>';
$holvalHtml.='</td>';
$holvalHtml.='</tr>';    
$holvalHtml.='</table>';
$holvalHtml.='</div>';
$def_workingdayHtml='<input type="hidden" id="def_workingday" value=\''.$def_workday.'\'>';
if($pop_portion !='all_poptable')
{
   echo '&#&#&#'.$special_workingdayHtml.$holvalHtml.$def_workingdayHtml; 
   exit();
}
else{    
    $smarty=new lingdangCRM_Smarty;
    $smarty->assign('DEFWORKDAYSHTML',$defworkdaysHtml);
    $smarty->assign('WORKINGDAY',$special_workingdayHtml.$holvalHtml.$def_workingdayHtml);
    $smarty->assign('WORKCALENDERID', $workcalender_id);
    $smarty->assign('WORKCALENDER_NAME',$workcalender_name);
    $smarty->assign('OPERATETYPE',$operatetype);
    echo '&#&#&#';
    $smarty->display("EditWorkingSpace.tpl");
    exit();    
}
?>