<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include(globalStatic::$root_directory.'modules/Settings/CommonAutoReminds.php');
global $theme,$mod_strings,$app_strings,$default_charset,$adv_filter_options;

if(isset($_REQUEST['blockid']) && $_REQUEST['blockid']!='')
    $blockid=$_REQUEST['blockid'];
if(isset($_REQUEST['fld_module']) && $_REQUEST['fld_module']!='')
    $blockname=$_REQUEST['fld_module'];
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
    $record=$_REQUEST['record'];
    
$smarty=new lingdangCRM_Smarty;
$tabname=getTabname($blockid);
$focus=CRMEntity::getInstance($tabname);

$query="select * from ld_automaticreminds where id=?";
$result=$adb->pquery($query,array($record));
$automaticreminds=array();
$tabid=0;
if($adb->num_rows($result)){
    $columnname=$adb->query_result($result,0,'columnname');
    $specifyuserids=$adb->query_result($result,0,'specifyuserids');
    $annualremind=$adb->query_result($result,0,'annualremind');//每年提醒
    $remindmethod=$adb->query_result($result,0,'remindmethod');

    $tabid=$adb->query_result($result,0,'tabid');
    if($columnname == 'dothis')
    {
        $columnname=$columnname;
    }
    else
    {
        $arr=explode(':',$columnname);
        if($arr[0] == $focus->Detail_table){
            //zkt 20220411  0050918  （https://81mis.com/kfbcrm/index.php）系统设置》自动提醒设置，“费用报销单”模块，以分录字段设置的提醒，查看设置的提醒，弹窗中没显示字段名称（附图）
            if(get_file_address($tabname,$tabname.'DetailFieldsHtml')){
    			crm_load_class_file('TabDetailFields','include/TabDetailFields');
    			$TabDetailFields = new TabDetailFields(getTabid($tabname));
    			$tmpfieldinfo  = $TabDetailFields->getFieldInfoobjBykey('columnname',$arr[1]);
                $tmpfieldlabel  =  $tmpfieldinfo->getfieldLabel();
    		}else{
    			crm_load_class_file('ProductDetails','include/ProductDetails');
    			$productDetails=ProductDetails::getInstance($tabname);
                $tmpfieldinfo = $productDetails->producttoolfields[$arr[1]];
    			$tmpfieldlabel = $tmpfieldinfo->getfieldLabel();
    		}
            $columnname = getTranstab($tabname).getFixedLabel('DETAIL')." - ".$tmpfieldlabel;
        }        
        else{
            $columnname=gettranslabelfields($tabname,$arr[1]);
        }
    }
    //制定周期处理
    if($adb->query_result($result,0,'remindway') == 2)//指定周期
    {
        $sqls="SELECT * from ld_remindway where wayid=?";
        $results=$adb->pquery($sqls,array($record));
        $num_row=$adb->num_rows($results);
        //echo $num_row;
        $remindday1="<br>";
        if($num_row == $adb->query_result($result,0,'remindnum'))
        {
            for($i=1;$i<=$num_row;$i++)
                {   
                    $remindsday=$adb->query_result($results,$i-1,'remindsday');
                    $remindday1.= '第'.$i.'次&nbsp;--><span>'.$remindsday.'</span>&nbsp;天后&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
                    if($i%5 == 0)
                    {
                        $remindday1.="<br>";
                    }
                }
        }
    }
    else if($remindway==3)//每年提醒
    {
        
    }
    else{
        $remindday1='';
    }
    $remindcontent = decode_html($adb->query_result($result,0,'remindcontent'));
    $remindcontent =  str_replace("\n", '<br>', $remindcontent);

    if ($remindmethod == 2) {
        crm_load_class_file('cls_Send_MassSms','include/utils');
        $cls_Send_MassSms = cls_Send_MassSms::getInstance();
        if ($cls_Send_MassSms->platform == 'aliyun') {
            $smsrelated_arr = $cls_Send_MassSms->getSmsRelated('ld_automaticreminds',$record);
            $remindcontent = $smsrelated_arr['templatecontent']??'';
        }
    }


    $automaticreminds[]=array(
    'annualremind'=>$annualremind,
    'tabid'=>$adb->query_result($result,0,'tabid'), 
    'name'=>$adb->query_result($result,0,'name'),    
    'columnname'=>$columnname,    
    'startdate'=>$adb->query_result($result,0,'startdate'),
    'remindnum'=>$adb->query_result($result,0,'remindnum'),
    'remindway'=>$adb->query_result($result,0,'remindway'),
    'remindday'=>$adb->query_result($result,0,'remindday'),
    'reminder'=>$adb->query_result($result,0,'reminder'),
    'remindcontent'=>$remindcontent,
    'remindmethod'=>$remindmethod
    );    
}




//$smarty->assign('REMINDERTEXT',getReminderText($tabname,$automaticreminds[0]['remindmethod'],$automaticreminds[0]['reminder'],$specifyuserids));
//基本查询开始
$sql="SELECT * from ld_remindcvstdfilter where cvid=? ";
$result=$adb->pquery($sql,array($record));
$general=array();
crm_load_class_file("CommonView","modules/CustomView");

	
if($adb->num_rows($result)>0){
    $columnname=explode(":",$adb->query_result($result,0,'columnname'));
    $general['columnname']=gettranslabelfields($tabname,$columnname[1]);
    $general['stdfilter']=$adb->query_result($result,0,'stdfilter');
    $general['startdate']=$adb->query_result($result,0,'startdate');
    $general['enddate']=$adb->query_result($result,0,'enddate');
}

$smarty->assign('general',$general);
//高级查询开始
$sql="SELECT * from ld_remindcvadvfilter where cvid=?";

$result=$adb->pquery($sql,array($record));
$nums=$adb->num_rows($result);

$AdvancedSearch=array();
for($i=0;$i<$nums;$i++)
{
    $columnname=explode(":",$adb->query_result($result,$i,'columnname'));
    $tablename=$columnname[0];//
    $columnname=$columnname[1];
    
   
    
    if(get_file_address($tabname,"ProductDetails")&&$focus->module_name!='ServiceCharge')
    {
         if(isProductTable($tablename,$tabname))
         {
            $fieldlabel=  $focus->detailfieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel');
         }
         else
         {
            $fieldlabel=  $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel');
         }
      
    }
    else if(get_file_address($tabname,$tabname.'DetailFieldsHtml'))
    {
        if($tablename==$focus->Detail_table||$tablename==$focus->Detail_table_scf)
         {
            $fieldlabel=  $focus->detailfieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel');
         }
         else
         {
            $fieldlabel=  $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel');
         }
    }
    else
    {
       $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldlabel'); 
    }

    $AdvancedSearch[]=array(
        'columnindex'=>$i+1,
        'columnname'=>$fieldlabel,
        'comparator'=>getAdvCriteriaValue($adb->query_result($result,$i,'comparator')),
        'value'=>$adb->query_result($result,$i,'value'),
        'column_condition'=>$adb->query_result($result,$i,'column_condition'),
    );
}

$smarty->assign('TABID',$tabid);
$smarty->assign('remindday1',$remindday1);
$smarty->assign('AdvancedSearch',$AdvancedSearch);
//print_r($automaticreminds);
$smarty->assign('AUTOMATICREMINDS',$automaticreminds);
$smarty->assign('STEP',$step);
$smarty->assign('THEME',$theme);
$smarty->assign('MOD','edit');
$smarty->assign('APP',$app_strings);
$smarty->assign('BLOCKID',$blockid);
$smarty->assign('RECORD',$record);
$smarty->assign("mokuai_name",getTranstab(getTabname($blockid)));

 $_REQUEST['diony']='diony';
$arr_smarty['title'] = getFixedLabel('VIEW');
$arr_smarty['oktext']=getFixedLabel("CONFIRMED");
$arr_smarty['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("AutomaticReminds/RemindsDetailView.tpl");
$arr_smarty['content']=$str;
ConvertTojsonString(1,$arr_smarty,"success");


function getAdvCriteriaValue($comparator='')
{
    if($comparator=='e')
    {
        $value = getFixedLabel('EQ');
    }else if($comparator=='n')
    {
        $value = getFixedLabel('NEQ');
    }	else if($comparator=='s')
    {
        $value = getFixedLabel('Begins');
    }else if($comparator=='ew')
    {
        $value = getFixedLabel('Ends');
    }else if($comparator=='c')
    {
        $value = getFixedLabel('IN');
    }else if($comparator=='k')
    {
        $value = getFixedLabel('NOT_IN');
    }
    else if($comparator=='isnull')
    {
        $value=getFixedLabel('ISNULL');
    }
    else if($comparator=='isnotnull')
    {
        $value=getFixedLabel('ISNOTNULL');
    }
    else
    {
         $tmps= CommonView::stdFilterDateTimeStr();
      
         
         if(array_key_exists($comparator,$tmps))
         {
          
            $value=$tmps[$comparator][2];
            
         }
         else
         {
             $value = getFixedLabel('NONE');
         }
    } 
   

    return $value;
}

?>