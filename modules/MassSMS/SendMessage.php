<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*客户服务单分配后是否发送短信通知*/

global $adb;
global $current_user;
global $languageType;

$smarty = new lingdangCRM_Smarty;

//获取短信账户名称
$SMSarray = GetSMSAutograph();
$account_name_sms = $SMSarray['account_name'];

if(!empty($account_name_sms))
{
    $smarty->assign('SENDACCOUNTTYPE',"yes");
}
$contenttype = $_REQUEST['contenttype'];

//保存短信模板
if($contenttype == 'yes')
{
    $acccontent = $_REQUEST['acc_content'];
    $sercontent = $_REQUEST['ser_content'];
    $accupdatesql = "update ld_sendinformcontent set content = ? where type = 11";
    $serupdatesql = "update ld_sendinformcontent set content = ? where type = 12";
    $adb->pquery($accupdatesql,array($acccontent));
    $adb->pquery($serupdatesql,array($sercontent));
    if($_REQUEST['fromview'] == 'detail'){
        header("Location: index.php?action=DetailView&module=".$_REQUEST['frommodule']."&record=".$_REQUEST['ticketid']."&sendtype=yes");
    }else{
        header("Location: index.php?module=HelpDesk&action=index&parenttab=Service");
    }
    exit;
}

//详情页
if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    $pconarr = getPhoneContent(array($_REQUEST['record']));
    $smarty->assign('FROMVIEW',"detail");
}

//列表页
if(isset($_REQUEST['fromview']) && $_REQUEST['fromview']=='list'){
    
    $storearray=getSelectedRecords($_REQUEST,'HelpDesk',$_REQUEST['idstring'],$_REQUEST['excludedRecords']);
    
    if($_REQUEST['idstring'] != 'all'){
        unset($storearray[count($storearray)-1]);
    }
    
    //获取批量处理数
    $deployarray=getSys_deploy(67);
    $btach_num =  $deployarray['deploy_value'];
    $storearray = array_slice($storearray,0,$btach_num);
    sort($storearray);
    $pconarr = getPhoneContent($storearray);

    $smarty->assign('FROMVIEW',"listview");
    $smarty->assign('LISTURL','&idstring='.$_REQUEST['idstring'].'&viewname='.$_REQUEST['viewid'].'&SearchScope='.$_REQUEST['searchScope'].'&excludedRecords='.$_REQUEST['excludedRecords']);
}


//更改接收人范围
if(isset($_REQUEST['rangetype']) && !empty($_REQUEST['rangetype'])){
    $rangetype = $_REQUEST['rangetype'];
    //记住最近一次的设置,由于是小的优化,所以没放在ld_users表里面,存在session里
    $_SESSION['lvs']['HelpDesk']['rangetype'] = $rangetype;
}elseif(!empty($_SESSION['lvs']['HelpDesk']['rangetype'])){//上次操作的值
    $rangetype = $_SESSION['lvs']['HelpDesk']['rangetype'];
}else{//默认为联系人和服务人员手机
    $rangetype = 'cas';
}

if($rangetype == 'all'){//客户和联系人所有手机及服务人员手机
    $content_arr = getRangeTypeContent($pconarr,array('other','contact','servicer'));
}elseif($rangetype == 'cas'){//联系人和服务人员手机
    $content_arr = getRangeTypeContent($pconarr,array('contact','servicer'));
}elseif($rangetype == 'con'){//联系人手机
    $content_arr = getRangeTypeContent($pconarr,array('contact'));
}elseif($rangetype == 'ser'){//服务人员手机
    $content_arr = getRangeTypeContent($pconarr,array('servicer'));
}

//接收人下拉框翻译
$tab_sql = "select fieldlabel from ld_tab tab
        inner join ld_tranlabel tran on tab.tabid = tran.tabid
        where tab.name in('Accounts','Contacts') and tran.trantable = 'ld_tab' and languagetype='zh'";
$field_sql = "select tran.fieldlabel from ld_tab tab
        inner join ld_tranlabel tran on tab.tabid = tran.tabid
        inner join ld_field field on field.fieldid = tran.Relateid
        where field.columnname = 'smownerid' and tab.name = 'HelpDesk' and tran.trantable = 'ld_field' and languagetype='zh'";
$tab_result = $adb->pquery($tab_sql);
$field_reuslt = $adb->pquery($field_sql);
$account_tran = $adb->query_result($tab_result,0,'fieldlabel');
$contact_tran = $adb->query_result($tab_result,1,'fieldlabel');
$servicer_tran = $adb->query_result($field_reuslt,0,0);
if($languageType == 'zh'){
    $all_tran = $account_tran.'和'.$contact_tran.'所有手机及'.$servicer_tran.'手机';
    $cas_tran = $contact_tran.'和'.$servicer_tran.'手机';
    $con_tran = $contact_tran.'手机';
    $ser_tran = $servicer_tran.'手机';
}else{
    $all_tran = 'ALL related mobile phone';
    $cas_tran = 'Contacts and servicer mobile phone';
    $con_tran = 'Contacts mobile phone';
    $ser_tran = 'Servicer mobile phone';
}

$smarty->assign('CONTENTARR',$content_arr);
$smarty->assign('RANGETYPE',$rangetype);
$smarty->assign("TICKETID",$_REQUEST['record']);
$smarty->assign("ACCOUNTNAME",$accountname);
$smarty->assign("TABID",getTabid($_REQUEST['frommodule']));
$smarty->assign('FROMMODULE',$_REQUEST['frommodule']);
$smarty->assign('LANGUAGETYPE',$languageType);
$smarty->assign('ALLTRAN',$all_tran);
$smarty->assign('CASTRAN',$cas_tran);
$smarty->assign('CONTRAN',$con_tran);
$smarty->assign('SERTRAN',$ser_tran);

$str=$smarty->fetch("modules/MassSMS/SendMessage.tpl");
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('SENDTEXTMESSAGESTOINFORM');
$arr['oktext']=getFixedLabel('Send_SMS');
$arr['canceltext']=getFixedLabel('CANCEL');
$arr['createnewtext']=getFixedLabel('NEW');
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");


//去除$pconarr中type不在$typearray部分
function getRangeTypeContent($pconarr,$typearray){
     
    foreach($pconarr as $record=>$valarr){
       
        foreach($valarr as $key=>$val){

            if(!in_array($val['type'],$typearray)){

                unset($pconarr[$record][$key]);
            }
        }
        if(count($pconarr[$record])==0){
            unset($pconarr[$record]);
        }
        
    }
    return $pconarr;
}

//获取全部人员手机号码,内容等信息
function getPhoneContent($recordarr){
    global $adb;

    for($count=0;$count<count($recordarr);$count++){

        $recordid = $recordarr[$count];
        $from_focus=CRMEntity::getInstance('HelpDesk');
        $user_focus=CRMEntity::getInstance('Users');
    	$from_focus->retrieve_entity_info($recordid,'HelpDesk');
    	$contactid=$from_focus->column_fields['contact_id'];
        $serviver=$from_focus->column_fields['assigned_user_id'];
        $user_fieldobj = $user_focus->fieldobj;
        

        //获取客户和联系人信息
        $sqlContent="select * from ld_sendinformcontent where type = 11";
        $sqlContentResult=$adb->query($sqlContent);
        $Content = $adb->query_result($sqlContentResult,0,'content');
        $Content = getResult($Content,$recordid);
        
        $phonegroups=getsms_module_Accounts($recordid);
        
        $j = 0;
        for($i = 0; $i<count($phonegroups); $i++)
        {
            $phonegroups[$i]['phone'] = array_unique($phonegroups[$i]['phone']);
            foreach($phonegroups[$i]['phone'] as $key=>$phone)
            {
                if(preg_match(globalStatic::$reg_mobile_digit,$phone)){
                    if(!empty($contactid) && $phonegroups[$i]['contactid'] == $contactid){//联系人
                        
                        $phoneConArr[$recordid][$j]['type'] = 'contact';                        
                    }else{
                        
                        $phoneConArr[$recordid][$j]['type'] = 'other';
                    }
                    $phoneConArr[$recordid][$j]['phone'] = $phone;
                    $phoneConArr[$recordid][$j]['content'] = $Content;
                    $phoneConArr[$recordid][$j]['username'] = $phonegroups[$i]['accountname'];
                    
                    $j++;
                }
            }    
        }
        
        
        //获取服务人员信息
    	foreach($user_fieldobj->getModuleFields() as $fieldname=>$fieldinfo){
            if($fieldinfo->getFieldDataType()=='mobile'&& in_array($fieldinfo->getTableName(),$user_focus->tab_name)){
    			$select_columns[]=$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();
    			$columns[]=$fieldinfo->getColumnName();
    			$tables[$fieldinfo->getTableName()]=$fieldinfo->getTableName();
    		}
    	}
    
    	$user_sql=createSqlByFocusObj($tables,$select_columns,$user_focus);
        $user_sql.=' where  '.$user_focus->table_name.'.'.$user_focus->table_index.'=?';

    	$user_result=$adb->pquery($user_sql,array($serviver));
    
        $sqlContent="select * from ld_sendinformcontent where type = 12";
        $sqlContentResult=$adb->query($sqlContent);
        $ser_Content = $adb->query_result($sqlContentResult,0,'content');
        $ser_Content = getResult($ser_Content,$recordid);
        
        if($adb->num_rows($user_result)>0){
    		for($i = 0;$i<$adb->num_rows($user_result); $i++){		
    			foreach($columns as $columnname){
    			    $phonenum = $adb->query_result($user_result,$i,$columnname);
                    if(preg_match(globalStatic::$reg_mobile_digit,$phonenum)){
                        $phone_arr[] = $phonenum;
                    }
                }
    		}
    	}
        $phone_arr = array_unique($phone_arr);
        foreach($phone_arr as $val){
            $phoneConArr[$recordid][] = array(
                'phone' => $val,
                'content' => $ser_Content,
                'type' => 'servicer',
                'username' => getUserFullName($serviver)
            );
        }
        
        
    }
    return $phoneConArr;

}



//获取短信模板完整信息
function getResult($Content,$recordid)
{   
    global $adb;
    $printcols=preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/",$Content);
    $frommodule=$_REQUEST['frommodule'];

    $from_focus=CRMEntity::getInstance($frommodule);
    $from_focus->retrieve_entity_info($recordid,'HelpDesk');

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
          
            $focus=CRMEntity::getInstance($curtabname);
            for($fi=1 ;$fi<count($tabcols)-1;$fi++)
            {
                 if($fi!=(count($tabcols)-2))
                     $fieldname.=$tabcols[$fi].'_';
                else
                    $fieldname.=$tabcols[$fi];
            }

            if(count($tabcols)>0&&strlen($tabcols[1])>0&&strlen($tabcols[0])>0)
            {
                 if($curtabname == 'Users'){

                    $focusid = $from_focus->column_fields['assigned_user_id'];
                 }elseif($curtabname == 'Accounts'){
                    
                    $focusid = $from_focus->column_fields['account_id'];
                 }elseif($curtabname == 'Contacts'){
                    
                    $focusid = $from_focus->column_fields['contact_id'];
                 }else{
                    $focusid = $recordid;
                 }
                 
                 $showvalueobj=new ShowFieldValue($focus->fieldobj,$curtabname,SHOW_EDITVIEW);
               
                 $showvalueobj->setRecorId($focusid);
                 $showvalueobj->setLine_index(1);
                 $field=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                 
                 $deleted = null;
                 if(!empty($focusid)){
                    $deletesql = 'select deleted from '.$focus->table_name.' where '.$focus->table_index.' ='.$focusid.' LIMIT 1 ';
                    $deleteresult = $adb->pquery($deletesql);
                    $deleted = $adb->query_result($deleteresult,0,0);
                 }

                 if($deleted === 0 || $deleted === '0'){
                    $focus->retrieve_entity_info($focusid,$curtabname);
                 }
 
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




/**
 * 获取发送短信模块的客户和联系人信息
 * */
function getsms_module_Accounts($recordid)
{
    global $adb;
	$account_focus=CRMEntity::getInstance('Accounts');
	$contact_focus=CRMEntity::getInstance('Contacts');
	$account_fieldobj=$account_focus->fieldobj;
	$contact_fieldobj=$contact_focus->fieldobj;

	$from_focus=CRMEntity::getInstance($_REQUEST['frommodule']);
	$from_focus->retrieve_entity_info($recordid,$_REQUEST['from_module']);
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
					$accountinfo[$i+1]['contactid']=$contact_id[$i];
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