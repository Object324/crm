<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*确认出库时是否发送短信通知客户*/

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;

//获取短信名称
$SMSarray = GetSMSAutograph();
$account_name_sms = $SMSarray['account_name'];

if(!empty($account_name_sms))
{   
    $smarty->assign('SENDACCOUNTTYPE',"yes");
}
$contenttype = $_REQUEST['contenttype'];
if($contenttype > 0)
{
    $CKcontent = $_REQUEST['CKcontent'];
    $sqlinsert = "update ld_sendinformcontent set content = ? where type = ? ";
    $insertresult = $adb->pquery($sqlinsert,array($CKcontent,$contenttype));
	if($_REQUEST['frommodule'] == 'SalesOrder'){
		header("Location: index.php?action=DetailView&module=".$_REQUEST['frommodule']."&record=".$_REQUEST['out_id']."&frommodule=".$_REQUEST['frommodule']."&sendtype=yes");	
	}else{
		header("Location: index.php?action=DetailView&module=".$_REQUEST['frommodule']."&record=".$_REQUEST['out_id']."&salestype=yes&sendtype=yes");
	}
}



//start 
if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    
   $phonegroups=getsms_module_Accounts();
  
    for($i = 0; $i<count($phonegroups); $i++)
    {
        foreach($phonegroups[$i]['phone'] as $phone)
        {
            if(preg_match(globalStatic::$reg_mobile_digit,$phone))
             $AccInfo .= $phone . "<".$phonegroups[$i]['accountname'].">\r"; 
        }
        
    }
    $smarty->assign('ACCINFO',$AccInfo);
}




if(strlen($info_all)>0)
{
    $info_all = mb_substr($info_all, 0, strlen($info_all)-3);
}

if(isset($_REQUEST['frommodule'])){
	if($_REQUEST['frommodule'] == 'SalesOrder'){
		$type = 7;
	}
    else if($_REQUEST['frommodule'] == 'SalesBack')
    {
        $type = 8;
    }
    else{
		$type = 1;
	}
}
$sqlContent="select * from ld_sendinformcontent where type = " . $type;
$sqlContentResult=$adb->query($sqlContent);
$Content = $adb->query_result($sqlContentResult,0,'content');

$Content = getResult($Content);

function getResult($Content)
{        
    global $adb;
    $printcols=preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/",$Content);
    $frommodule=$_REQUEST['frommodule'];
      
    $focus=CRMEntity::getInstance($frommodule);
   // $focus->retrieve_entity_info($_REQUEST['record']);//函数getsms_module_accounts()中已获取
   
    $showvalueobj=new ShowFieldValue($focus->fieldobj,$frommodule,SHOW_EDITVIEW);
    $showvalueobj->setRecorId($_REQUEST['record']);
    $showvalueobj->setLine_index(1);
    for($i=0;$i<count($printcols);$i++)
    {
        $fieldname='';
        if(strpos($printcols[$i],']')>0)
        {
            $endcol=strpos($printcols[$i],']');
            $colsinfo=substr($printcols[$i],0,$endcol);
            $colsinfovalue=substr($printcols[$i],$endcol+1,strlen($printcols[$i]));
            $tabcols=explode('_',$colsinfo);
            $curtabname=$tabcols[count($tabcols)-1];//当前打印字段所在模块
          
            
            for($fi=1 ;$fi<count($tabcols)-1;$fi++)
            {
                 if($fi!=(count($tabcols)-2))
                     $fieldname.=$tabcols[$fi].'_';
                else
                    $fieldname.=$tabcols[$fi];
            }
        
            if(count($tabcols)>0&&strlen($tabcols[1])>0&&strlen($tabcols[0])>0)
            {
                 
                 $field=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                  if($field)
                  {
                    $showvalue=$showvalueobj->getFieldValueByField($field,$focus->column_fields[$fieldname],$focus->column_fields[$fieldname]);
                    $value=$showvalue['value'];
                    if($field->getUIType()==151)
                    {
                        $sql = "select name from ld_warehouse where id = ?";
                        $wareresult=$adb->pquery($sql,array($value));
                        $value = $adb->query_result($wareresult,0,'name');
                    }
                  }
                  else
                  {
                    
                  }
                 
                 $printcols[$i] = $value.$colsinfovalue; 
            }
        }
    }
    return implode('',$printcols);
}

//exit();

//print_r($phonegroups);
$smarty->assign("CONTENT",$Content);
//$smarty->assign("MOBILEINFOS",$phonegroups);
$smarty->assign("OUTID",$_REQUEST['record']);
$smarty->assign("ACCOUNTNAME",$accountname);
$smarty->assign("TABID",getTabid($_REQUEST['frommodule']));
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);

echo "####:###";
exit();
$smarty->display("modules/MassSMS/SendInform.tpl");

exit();

/**
 * 获取发送短信模块的客户和联系人信息
 * */
function getsms_module_Accounts()
{
    global $adb;
	$account_focus=CRMEntity::getInstance('Accounts');
	$contact_focus=CRMEntity::getInstance('Contacts');
	$account_fieldobj=$account_focus->fieldobj;
	$contact_fieldobj=$contact_focus->fieldobj;

	$from_focus=CRMEntity::getInstance($_REQUEST['frommodule']);
	$from_focus->retrieve_entity_info($_REQUEST['record'],$_REQUEST['from_module']);
	$table_index=$from_focus->table_index;
	$maintablename=$from_focus->table_name;
	$accountid=$from_focus->column_fields['account_id'];
	$contactid=$from_focus->column_fields['contact_id'];
	$accountname=getModuleHref('Accounts',$accountid);
     
	foreach($account_fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
	{
		if($fieldinfo->getFieldDataType()=='mobile'&& in_array($fieldinfo->getTableName(),$account_focus->tab_name))
		{
			$select_columns[]=$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();
			$columns[]=$fieldinfo->getColumnName();
			$tables[$fieldinfo->getTableName()]=$fieldinfo->getTableName();
		}
	}
	$account_sql=createSqlByFocusObj($tables,$select_columns,$account_focus);
	$account_sql.=' where  '.$account_focus->table_name.'.'.$account_focus->table_index.'=?';

	$account_result=$adb->pquery($account_sql,array($accountid));
	if($adb->num_rows($account_result)>0)
	{
		$accountinfo[0]['accountid']=$accountid;
		$accountinfo[0]['accountname']=$accountname;
		$accountinfo[0]['salutation']='';
		foreach($columns as $columnname)
		{
			$accountinfo[0]['phone'][]=$adb->query_result($account_result,0,$columnname);
		}
	}
	$select_columns=array();
	$tables=array();
	$columns = array();
	if(!empty($accountid)){
		$query = 'select contactid from ld_contactdetails where accountid = ?';
		$result = $adb->pquery($query,array($accountid));
		if($adb->num_rows($result) >= 1){
			for($i = 0; $i<$adb->num_rows($result); $i++){
				$contact_id[] = $adb->query_result($result,$i,'contactid');
			}
		}
		if(count($contact_id) >= 1){
			foreach($contact_fieldobj->getModuleFields() as $fieldname=>$fieldinfo){
				if($fieldinfo->getFieldDataType()=='mobile'&& in_array($fieldinfo->getTableName(),$contact_focus->tab_name)){
					$select_columns[]=$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();
					$columns[]=$fieldinfo->getColumnName();
					$tables[$fieldinfo->getTableName()]=$fieldinfo->getTableName();
				}
			}
			$contact_sql=createSqlByFocusObj($tables,$select_columns,$contact_focus);
			$contact_sql.=' where  '.$contact_focus->table_name.'.'.$contact_focus->table_index.' in ('.implode(',',$contact_id).')';
			$contact_result=$adb->pquery($contact_sql,array());
			$k=1;
			if($adb->num_rows($contact_result)>0){
				for($i = 0;$i<$adb->num_rows($contact_result); $i++){
					$contactname=getModuleHref('Contacts',$contact_id[$i]);
					$accountinfo[$i+1]['accountid']=0;
					$accountinfo[$i+1]['accountname']=$contactname;
					$accountinfo[$i+1]['salutation']='';
					foreach($columns as $columnname){
						$accountinfo[$i+1]['phone'][]=$adb->query_result($contact_result,$i,$columnname);
					}
				}
				
				
			}
		}
	}
     $arr= $accountinfo;
     return $arr;
 }
?>