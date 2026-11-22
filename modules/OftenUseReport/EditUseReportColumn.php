<?php
//zkt 20231010 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
include('modules/OftenUseReport/language/zh_cn.lang.php');
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$usereportid=$_REQUEST['UseReport'];
$sql='select `name` from ld_usereport where usereportid=?';
$result=$adb->pquery($sql,array($usereportid));
$reportname=$adb->query_result($result,0,'name');

$sql='select * from ld_usereportcolumns where usereportid=?  and columnshow=1 order by sequence asc ';

$result=$adb->pquery($sql,array($usereportid));
//print_r($result);
$roof_rows=$adb->num_rows($result);

$allcolumns=array();
$columnsid='';
$smarty=new lingdangCRM_Smarty();
for($i=0;$i<$roof_rows;$i++)
{
    $colid=$adb->query_result($result,$i,'id');
    $realcolumns=$adb->query_result($result,$i,'realcolumns');
    $realencolumns=$adb->query_result($result,$i,'realencolumns');
    $columns=$adb->query_result($result,$i,'columns');
    $columnshow=$adb->query_result($result,$i,'columnshow');
    $fieldlabels=explode(':',$columns);
    if($fieldlabels[0]=='ld_account'&&!vtlib_isModuleActive("Accounts"))
    {
        continue;
    }
     if($fieldlabels[0]=='ld_contactdetails'&&!vtlib_isModuleActive("Contacts"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_potentials'&&!vtlib_isModuleActive("Potentials"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_activies'&&!vtlib_isModuleActive("Calendar"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_contactrecords'&&!vtlib_isModuleActive("ContactRecords"))
    {
        continue;
    }
     if($fieldlabels[0]=='ld_troubletickets'&&!vtlib_isModuleActive("HelpDesk"))
    {
        continue;
    }
     if($fieldlabels[0]=='ld_cashbill'&&!vtlib_isModuleActive("CashBill"))
    {
        continue;
    }
    if($fieldlabels[0]=='ld_expense'&&!vtlib_isModuleActive("Expense"))
    {
        continue;
    }
    //合同跟踪表---	BUG20240130-47 zxm 001服务增强版，合同跟踪表，缺少成本、毛利和毛利率显示字段（服务合同也有“产品成本”字段）
    if($reportname=='SalesOrderTrack'){

    }else{
        if(($fieldlabels[0]=='ld_salesorder'&&!vtlib_isModuleActive("SalesOrder")) )
        {
            continue;
        }
        if($fieldlabels[0]=='ld_servicecontracts'&&!vtlib_isModuleActive("ServiceContracts"))
        {
            continue;
        }
    }

    $modules=explode('_',$fieldlabels[3]);
    $module=$modules[0];
    $columnsid.=$colid.',';
    $sql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
     where languagetype=? and trantable=? and   columnname=? and ld_tranlabel.tabid =(select tabid from ld_tab where name=?)';

   
    $fieldResult=$adb->pquery($sql,array($languageType,'ld_field',$fieldlabels[1],$module));

    if($adb->num_rows($fieldResult)>0)
    {
        $defaultfieldlabel=$adb->query_result($fieldResult,0,'fieldlabel');
        $defaultfieldlabel=getTranstab($module).'_'.($defaultfieldlabel);
    }
    else
    {
         if(array_key_exists($modules[1],$mod_strings))
         {
                $defaultfieldlabel=$mod_strings[$modules[1]];
         }
         else
            $defaultfieldlabel=$modules[1];
        $defaultfieldlabel=$defaultfieldlabel;
    }
    if($realcolumns==$columns)
    {
        $realfieldlabel=$defaultfieldlabel;
    }
    else
    {
        $fieldlabels=explode(':',$realcolumns);
        $modules=explode('_',$fieldlabels[3]);
        $module=$modules[0]; 
        $fieldlabel=substr($fieldlabels[3],strpos($fieldlabels[3],'_')+1); 
        $realfieldlabel=$fieldlabel;  
    }
    
    /**
    @andrew
    20140619
    使用修改名称时候英文名称时候不会自动转换成原有中文        
    */
   // if($realencolumns==$columns)
    //{
    //    $realenfieldlabel=$defaultfieldlabel;
   // }
   // else
   // {
        $enfieldlabels=explode(':',$realencolumns);
        $enmodules=explode('_',$enfieldlabels[3]);
        $enmodule=$enmodules[0]; 
        $enfieldlabel=substr($enfieldlabels[3],strpos($enfieldlabels[3],'_')+1); 

        $realenfieldlabel=getTranslatedString($enmodule,$enfieldlabel);  
   // }    
    //zxm  2021-1101 销售机会预测表  只有前10个字段可以调换顺序
    if($reportname=='Salesforecastandanalysistable'){
        $temp_columns = explode(':',$columns) ;
        if(!in_array($temp_columns[1],['last_name','groupname','accountname','account_type','Potentials_smcreatorid','potentialname','potential_no','productcategory','sales_stage','lastsales_stage'])){
            continue;
        }
    }
     $allcolumns[]=array('colid'=>$colid,
    'defaultname'=>$defaultfieldlabel,
    'realname'=>$realfieldlabel,
    'realenname'=>$realenfieldlabel
    );
    
}

$smarty->assign('COLUMNSID',$columnsid);
$smarty->assign('ALLCOLUMNS',$allcolumns);
$content = $smarty->fetch('modules/OftenUseReport/EditUseReportColumn.tpl');;
$_REQUEST['diony']='diony';
$res['content'] = $content;
$res['title'] = getFixedLabel('DISPLAYCOLSET');
ConvertTojsonString(1,$res,'success');
unset($adb);
unset($mod_strings);
unset($app_strings);
exit();

?>