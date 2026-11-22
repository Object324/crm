<?php
/**
 * edit:can
 * reason:显示和隐藏列
 * */
include('modules/OftenUseReport/language/zh_cn.lang.php');
global $adb,$currentModule;
$usereportid=$_REQUEST['UseReport'];
$sql='select `name` from ld_usereport where usereportid=?';
$result=$adb->pquery($sql,array($usereportid));
$reportname=$adb->query_result($result,0,'name');
$sql='select * from ld_usereportcolumns where usereportid=? order by sequence asc ';

$result=$adb->pquery($sql,array($usereportid));
$roof_rows=$adb->num_rows($result);

$allcolumns="";
$showcolumns="";
$showcolumnsdisplayno = "";
$smarty=new lingdangCRM_Smarty();
for($i=0;$i<$roof_rows;$i++)
{
    $colid=$adb->query_result($result,$i,'id');
    $realcolumns=$adb->query_result($result,$i,'realcolumns');
    $realencolumns=$adb->query_result($result,$i,'realencolumns');
    $columns=$adb->query_result($result,$i,'columns');
    $columnshow=$adb->query_result($result,$i,'columnshow');
    $fieldlabels=explode(':',$realcolumns);
    $fieldenlabels=explode(':',$realencolumns);
    if($languageType=='zh'){//Liver 2016/11/11，原因是英文版签到表显示列设置显示为中文
        $modules=explode('_',$fieldlabels[3]);
    }else{
        $modules=explode('_',$fieldenlabels[3]);
    }
	$columnname = $fieldlabels[1];
    $module=$modules[0];
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

    }else {
        if ($fieldlabels[0] == 'ld_salesorder' && !vtlib_isModuleActive("SalesOrder")) {
            continue;
        }
        if ($fieldlabels[0] == 'ld_servicecontracts' && !vtlib_isModuleActive("ServiceContracts")) {
            continue;
        }
    }
	 if($fieldlabels[0]=='ld_invoice'&&!vtlib_isModuleActive("Invoice"))
    {
        continue;
    }
	 if($fieldlabels[0]=='ld_outboundorder'&&!vtlib_isModuleActive("OutboundOrder"))
    {
        continue;
    }
    if($realcolumns==$columns)
    {
        $sql='select ld_tranlabel.fieldlabel from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
         where columnname=\''.$fieldlabels[1].'\' and languagetype=?  and  trantable=\'ld_field\' and ld_tranlabel.tabid =(select tabid from ld_tab where name=\''.$module.'\')';
        $fieldResult=$adb->pquery($sql,array($languageType));
      
        if($adb->num_rows($fieldResult)>0)
        {
            $fieldlabel=$adb->query_result($fieldResult,0,'fieldlabel');
            $fieldlabel=getTranstab($module).'_'.$fieldlabel;
        }
        else
        {
             if(array_key_exists($modules[1],$mod_strings))
             {
                $fieldlabel=$mod_strings[$modules[1]];
             }
             else
                 $fieldlabel=$modules[1];
        }
    }
    
    else
    {
        //Liver 2016-11-10 bug：0024660: 英文版：常用报表：以下报表中显示列设置弹出层中，可用字段和已选字段框中的字段名称没有英译
        if($languageType=='zh'){
            $fieldlabel=substr($fieldlabels[3],strpos($fieldlabels[3],'_')+1);
        }else{
            $fieldlabel=substr($fieldenlabels[3],strpos($fieldenlabels[3],'_')+1);
        }
        
    }
	if($reportname == 'SalesSumSequence'){
		if('invoicetotal' == $columnname){
			$fieldlabel = getTransTab('Invoice') . getFixedLabel('AMOUNT');
		}
		if('outboundordertotal' == $columnname){
			$fieldlabel = getTransTab('OutboundOrder') . getFixedLabel('AMOUNT');
		}
	}
	//zxm  2021-1101 销售机会预测表  只有前10个字段可以调换顺序
    $display = "";
	if($reportname=='Salesforecastandanalysistable'){
        $temp_columns = explode(':',$columns) ;
        if(!in_array($temp_columns[1],['last_name','groupname','accountname','account_type','Potentials_smcreatorid','potentialname','potential_no','productcategory','sales_stage','lastsales_stage']))
        {
            //zkt 20220602 52427常用报表里的销售预测分析表导出Excel数据后，有一部分的表头没有显示，详情见附件。
            $showcolumnsdisplayno .=$colid.',';
            continue;
        }
    }
    $allcolumns.='<option '.$display.' value="'.$colid.'">'.$fieldlabel.' </option>';
    if($columnshow==1)
    {
        $showcolumns.='<option '.$display.' value="'.$colid.'">'.$fieldlabel.' </option>';
    }   
}

/**
*@author:andy
*@data:20142030
*@reason:bug12185建议优化合同订单跟踪表中显示列设置字段的显示方式
*@version:v5.8
*/
$allcolumnsArr=explode('</option>',$allcolumns);
$showcolumnsArr=explode('</option>',$showcolumns);
$allcolumnsArr=array_diff($allcolumnsArr,$showcolumnsArr);
$leftcolumns=array();


foreach($allcolumnsArr as $key => $val)
{
    $leftcolumns[$key]=$val.'</option>';
}
$leftcolumns=implode('</option>',$leftcolumns);

$smarty->assign('ALLCOLUMNS',$leftcolumns);
$smarty->assign('modulename',$currentModule);
$smarty->assign('SHOWCOLUMNS',$showcolumns);
$smarty->assign('SHOWCOLUMNSDISPLAYNONE',$showcolumnsdisplayno);
$sql='select pagewidthpercent from ld_usereport where usereportid=?';
$result=$adb->pquery($sql,array($usereportid));
$smarty->assign('PAGEWIDTHPERCENT',$adb->query_result($result,0,0));

$content = $smarty->fetch('modules/OftenUseReport/UseReportSetColumn.tpl');;
$_REQUEST['diony']='diony';
$res['content'] = $content;
$res['title'] = getFixedLabel('SHOWHIDDENCOLS');
ConvertTojsonString(1,$res,'success');

unset($adb);


exit();
?>