<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 
/*客户服务单分配后是否发送短信通知*/

global $adb,$current_user,$languageType;
$smarty = new lingdangCRM_Smarty;
$deployarray=getSys_deploy(167);
if($deployarray['deploy_value'] != 1 && $deployarray['deploy_value'] != 2){
	exit();
}
$smarty->assign('IS_SEND',$deployarray['deploy_value']);
//获取联系人的所有手机字段或者所有email字段
$focus=CRMEntity::getInstance('Contacts');
$fieldobj=$focus->fieldobj;
foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
{
	if($deployarray['deploy_value'] == 1){
		if($fieldinfo->getFieldDataType()!='mobile'){
			continue;
		}
	}else{
		if($fieldinfo->getUIType()!=13){
			continue;
		}
	}
	$contact_SMS[]= $fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();
	$sms_columns[] = $fieldinfo->getColumnName();
}
//选择其他联系人
if(!empty($_REQUEST['getAccountOtherContacts']) && $_REQUEST['getAccountOtherContacts'] == 'yes'){
	$res_send = array();
	if(!empty($_REQUEST['contactid']) && !empty($_REQUEST['accountid'])){
		$query = 'select ld_contactdetails.lastname,'.implode(',',$contact_SMS).' from ld_contactdetails
		LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid
		where ld_contactdetails.accountid = ? and ld_contactdetails.contactid != ?';
		$result = $adb->pquery($query,array($_REQUEST['accountid'],$_REQUEST['contactid']));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$lastname = $adb->query_result($result,$i,'lastname');
				$contactid = $adb->query_result($result,$i,'contactid');
				$accountid = $adb->query_result($result,$i,'accountid');
				foreach($sms_columns as $column){
					$val = $adb->query_result($result,$i,$column);
					if(!empty($val)){
						$list_value = $adb->query_result($result,$i,$column);
						if($deployarray['deploy_value'] == 1){
							$list_value .= '<'.$lastname.'>';
						}
						$res_send[] = array(
							'lastname' => $lastname,
							'mobile' => $adb->query_result($result,$i,$column),
							'value' => $list_value,
						);
					}
				}
			}
		}
		$smarty->assign('RESSENDCOUNT',sizeOf($res_send));
		$smarty->assign('RESSEND',$res_send);
		$smarty->assign('TITLE',getTransTab('Contacts'));
	}
	$str=$smarty->fetch("modules/MassSMS/SelectOtherContacts.tpl");
	$_REQUEST['diony']='diony';
	$arr['title']=getTransTab('Contacts');
	$arr['oktext']=getFixedLabel('CONFIRME');
	$arr['canceltext']=getFixedLabel("CANCEL");
	$arr['content']=$str;
	$arr['allcontent']=$str;
	if(sizeOf($res_send) >= 1)
		ConvertTojsonString(1,$arr,"success");
	else
		ConvertTojsonString(-1,$arr,"success");
	exit();
}
//获取短信账户名称
//$SMSarray = GetSMSAutograph();
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = cls_Send_MassSms::getInstance();
$platform = $cls_Send_MassSms->platform;
$SMSarray = $cls_Send_MassSms->smsarray;
$smarty->assign("PlatForm",$platform);

//分配短信信息
$sqlContent="select * from ld_sendinformcontent where type = 13";
$sqlContentResult=$adb->query($sqlContent,array());
$Content = $adb->query_result($sqlContentResult,0,'content');
$relatedid = $adb->query_result($sqlContentResult,0,'id');
$smarty->assign('CONTENT',$Content);
$wildcard = getFixedLabel('WILDCARD').':　'.getFixedLabel('CONTACTNAME').'{name}　　　　'.getFixedLabel('CONTACTAPPELLATION') .'{app}';
$smarty->assign('WILDCARD',$wildcard);

$account_name_sms = $SMSarray['account_name'];
if(!empty($_REQUEST['textRecipient'])){//发送逻辑
	if($deployarray['deploy_value'] == 1){
		if(empty($account_name_sms)){
			echo -1;
			exit();
		}
		$textRecipient = trim($_REQUEST['textRecipient']);
        $textRecipient = explode(",", $textRecipient);
        if ($platform == 'aliyun') {
            if (isset($_REQUEST['smstemplateid']) && $_REQUEST['smstemplateid']>0) {
                $templateid = $_REQUEST['smstemplateid'];
                $templateparamconf = $_REQUEST['smstemplateparamconf'];

                $sql = "select 1 from ld_smsrelated where relatedtable=? and relatedid=?";//关联的主键id  不需要scene条件
                $result = $adb->pquery($sql,array("ld_sendinformcontent",$relatedid));
                if ($adb->num_rows($result) > 0) {
                    $cls_Send_MassSms->updateSmsRelated("ld_sendinformcontent", $relatedid, 'HelpDesk', $templateid, $templateparamconf, 'helpdesk_allocation_sms');
                }else{
                    $cls_Send_MassSms->insertSmsRelated("ld_sendinformcontent", $relatedid, 'HelpDesk', $templateid, $templateparamconf,'helpdesk_allocation_sms');
                }

                $templateParam = getTextContext($templateparamconf);
                foreach($textRecipient as $CalledNumber){
                    $cls_Send_MassSms->send($CalledNumber,'','','',$templateid,$templateParam);
                }
            }
        }
        else{
            $textContext = $_REQUEST['textContext'];
            $textContext = getTextContext($textContext);
            foreach($textRecipient as $CalledNumber){
                $cls_Send_MassSms->send($CalledNumber,$textContext);
            }
        }

		echo 1;
		exit();
	}else{
		require_once(globalStatic::$root_directory.'modules/Emails/mail.php');

		$sql="select server_username from ld_systems where server_type = 'email'";
		$result = $adb->pquery($sql);
		$server_username = $adb->query_result($result, 0, 'server_username');
		if(empty($server_username))
		{
			echo -2;exit();
		}
		$from_email = $server_username;
		$textRecipient = trim($_REQUEST['textRecipient']);
		$textRecipient = explode(",", $textRecipient);
		$content = $_REQUEST['textContext'];
		$content = getTextContext($content);
		$subject = getFixedLabel('ALLOCATEREMINDS');	//分配提醒
		foreach($textRecipient as $toemail){
			send_mail('Emails', $toemail, '', $from_email, $subject, $content, "", "", 'all', "", '', $server_username);
		}
		echo 1;
		exit();
	}
	//
}
if(sizeOf($contact_SMS) > 0 && !empty($_REQUEST['ids'])){//显示弹窗页面
	if($_REQUEST['ids'] != 'all'){
		$ids = explode(';', rtrim($_REQUEST['ids'], ';'));
	}else{
		$ids = getSelectedRecords($_REQUEST,'HelpDesk',rtrim($_REQUEST['ids'], ';'), "");
	}
	$res_id = $ids[0];
	$record = implode(',',$ids);
	$query = 'select ld_contactdetails.lastname,'.implode(',',$contact_SMS).',ld_contactdetails.contactid,ld_troubletickets.accountid from ld_troubletickets
	INNER JOIN ld_contactdetails on ld_contactdetails.contactid = ld_troubletickets.contactid
	LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid 
	where ld_contactdetails.deleted <> 1 and ld_troubletickets.ticketid in ('.$record.')';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$lastname = $adb->query_result($result,$i,'lastname');
			$contactid = $adb->query_result($result,$i,'contactid');
			$accountid = $adb->query_result($result,$i,'accountid');
			foreach($sms_columns as $column){
				$val = $adb->query_result($result,$i,$column);
				if(!empty($val)){
					if($deployarray['deploy_value'] == 1){
						$res_send[] = $adb->query_result($result,$i,$column).'<'.$lastname.'>';
					}else{
						$res_send[] = $adb->query_result($result,$i,$column);
					}
				}
			}
		}
	}
	$smarty->assign('RESID',$res_id);
	$res_send = array_unique($res_send);
	$smarty->assign('ACCINFOVALUES',implode("#,#",$res_send));
	$smarty->assign('ACCINFO',implode("\r\n",$res_send));
}

if ($platform == 'aliyun') {
    $smstemplatelist = $cls_Send_MassSms->getSmsTemplatePresenceInform($platform);
    $smarty->assign("SmsTemplateList",$smstemplatelist);//启用的短信模板列表
    $smarty->assign("PRINTTABS",getPresenceModuleList());

    //获取设置的短信类型的参数信息
    $smsrelated_arr = $cls_Send_MassSms->getSmsRelated('ld_sendinformcontent',$relatedid);
}


if($deployarray['deploy_value'] == 1){
	$title = getFixedLabel('SENDTEXTMESSAGESTOINFORM');
	$oktext = getFixedLabel('Send_SMS');
}else{
	$title = getFixedLabel('SENDEMAILREMINDER');
	$oktext = getFixedLabel('Send_mail');
}
$smarty->assign('TABID',getTabid('HelpDesk'));
$smarty->assign('CONTACTID',$contactid);
$smarty->assign('ACCOUNTID',$accountid);
$smarty->assign('settype','no');
$str=$smarty->fetch("modules/MassSMS/SendInformHelpDesk.tpl");
$_REQUEST['diony']='diony';
$arr['title']=$title;
$arr['oktext']=$oktext;
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$str;
$arr['allcontent']=$str;
$arr['isadmin']=$current_user->is_admin;
$arr['platform'] = $platform;
$arr['smsrelated_arr']=$smsrelated_arr;
ConvertTojsonString(1,$arr,"success");
exit();

//获取短信内容
function getTextContext($Content)
{        
    global $adb;
    $printcols=preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/",$Content);
    $frommodule='HelpDesk';
      
    $focus=CRMEntity::getInstance($frommodule);
   // $focus->retrieve_entity_info($_REQUEST['record']);//函数getsms_module_accounts()中已获取
   
    $showvalueobj=new ShowFieldValue($focus->fieldobj,$frommodule,constant(SHOW_EDITVIEW));
    $showvalueobj->setRecorId($_REQUEST['record']);
	$focus->retrieve_entity_info($_REQUEST['record'], $frommodule);
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
					if($field->getUIType()==73)
					{
						$sql = "select accountname from ld_account where accountid = ?";
						$accountresult=$adb->pquery($sql,array($value));
						$value = $adb->query_result($accountresult,0,'accountname');
					}
				}else{
					if($fieldname == 'phone_mobile' && $tabcols[0] == 'users'){
						$sql = "select phone_mobile from ld_users where id = ?";
						$userresult=$adb->pquery($sql,array($focus->column_fields['assigned_user_id']));
						$value = $adb->query_result($userresult,0,'phone_mobile');
					}
				}
				$printcols[$i] = $value.$colsinfovalue; 
            }
        }
    }
	$string = implode('',$printcols);
	if(strpos($string,'{name}') !== false || strpos($string,'{app}') !== false){
		if(!empty($focus->column_fields['contact_id'])){
			$query = 'select lastname,salutation from ld_contactdetails where contactid = ? and deleted <> 1';
			$result = $adb->pquery($query,array($focus->column_fields['contact_id']));
			$lastname = $adb->query_result($result,0,0);
			$salutation = $adb->query_result($result,0,1);
		}
		if(strpos($string,'{name}') !== false){
			$string = str_replace("{name}",$lastname,$string);
		}
		if(strpos($string,'{app}') !== false){
			$string = str_replace("{app}",$salutation,$string);
		}
	}
	return $string;
}
?>