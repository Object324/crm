<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/
 global $adb, $currentModule, $current_user;
 $smarty=new lingdangCRM_Smarty();
 require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
 $accountid=$_REQUEST['accountid'];
 $contactid=$_REQUEST['contactid'];
 if(empty($contactid)&&empty($accountid))
 {
     echo '###SUCCESS###';
     exit();
 }
// require_once('include/utils/CommonUtils.php');
 $frommodule = $_REQUEST['frommodule'];
 if($frommodule=='Accounts'||$frommodule=='Contacts')
 {
    echo '###ERROR###';
    exit;
 }
$focus=CRMEntity::getInstance($frommodule);
 //判断当前模块的客户名称和联系人姓名字段是否启用

// if(array_key_exists('account_id',$focus->column_fields))
 if(array_key_exists('account_id',$focus->column_fields))
	$accountPresence = 0;
 else
	$accountPresence = 1;
 if(array_key_exists('contact_id',$focus->column_fields))
	$contactPresence = 0;
 else
	$contactPresence = 1;
 $BeFieldPresence = array('Accounts'=>$accountPresence,'Contacts'=>$contactPresence,);

 //区块信息
 $block_info = getBlockDisplayInfo('AccountContacts');

 if(($accountPresence == 1 && $contactPresence == 1) || $block_info['is_display'] == 1)
 {
    echo '###ERROR###';
    exit;
 }
 if($accountPresence == 0){
	$BeModuleInfo['accountid'] = $_REQUEST['accountid'];
 }
  if($contactPresence == 0){
	$BeModuleInfo['contactid'] = $_REQUEST['contactid'];
 }
 //获取关联的客户、联系人字段信息
 foreach($BeModuleInfo as $key => $beRecordid)
 {
	
    $innerSql = '';
    switch($key)
    {
        case 'accountid':
            $beTabid = getTabid('Accounts');
            break;
        case 'contactid':
            $beTabid = getTabid('Contacts');
            break;
        default;
    }
    $beModule = getTabname($beTabid); //关联模块名称
    if($beModule == 'Accounts')
        $col_fields[$beModule]['record_id'] = $_REQUEST['accountid'];
    else if($beModule == 'Contacts')
        $col_fields[$beModule]['record_id'] = $_REQUEST['contactid'];
        
    if(!empty($beTabid) && $BeFieldPresence[$beModule] != 1)
    {
        /*获取模块对应设定的关联字段
        $query_fields = "select fieldname,columnname,tablename,uitype from ld_field where presence in (0,2) 
        and associatedfields = 0 and tabid = ? order by ld_field.associatedsequence asc";
        $result_fields = $adb->pquery($query_fields,array($beTabid));
        $num_rows = $adb->num_rows($result_fields); */
        
        $focus = CRMEntity::getInstance($beModule);
        $fieldobj=$focus->fieldobj;
        //主表table
        $tablename = $focus->table_name;
        $tableindex = $focus->table_index;
        $i=0;
        foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
        {
          
             if($fieldinfo->getAssociatedfields()==0 && $fieldinfo->getAssociatedfields() != null && $fieldinfo->getAssociatedfields() != '')
             {
                //关联表table
                    $tname = $fieldinfo->getTableName();
                    //关联字段
                    $columnname = $fieldinfo->getColumnName();
                    $uitype = $fieldinfo->getUIType();
                    
                    $moduleColumn[$beModule][$i] = $beModule . '_' .  $columnname;
                    //关联查询字段SQL
                    $columnsql[$beModule][$i] = $tname . '.' . $columnname;
                    $columnArr[$beModule][$i] = $columnname;
                    $fieldnameArr[$beModule][$i] = $fieldname;                       
                    //获取除主表以外的其他表
                    if($tablename != $tname)
                    {
                        $beAllTable[$beModule][$i] = $tname;
                    }
                    $i++;
             }
            
        }
        //关联表连接
		if(!empty($beAllTable) && isset($beAllTable[$beModule])){
			//清除数组中相同的值
			$beAllTable = array_unique($beAllTable[$beModule]);
			if(!empty($beAllTable)){
				foreach($beAllTable as $innertable)
				{
					if($innertable != 'ld_attachments'){
						$innerSql .= " left join $innertable on $tablename.$tableindex = $innertable.$tableindex";
					}else{
						$innerSql .= "
							left join (select ld_seattachmentsrel.crmid,GROUP_CONCAT(ld_attachments.`name`,'<br>') as filename from ld_attachments
								LEFT JOIN ld_seattachmentsrel on ld_seattachmentsrel.attachmentsid = ld_attachments.attachmentsid
								) as ld_attachments on ld_attachments.crmid =  $tablename.$tableindex
						";
					}
				}
			}
		}
        $query = "SELECT ";
        $query .= implode(',',$columnsql[$beModule]);  //查询字段
        $query .= " FROM $tablename " . $innerSql . " WHERE $tablename.$tableindex = ?";
        if($beRecordid > 0) //关联客户、联系人的recordid
        {
            $result = $adb->pquery($query,array($beRecordid));
            $num_rows = $adb->num_rows($result);
            for($i = 0; $i<count($columnArr[$beModule]);$i++)
            {
                //echo $columnArr[$beModule][$i] .'==';
                $col_fields[$beModule][$fieldnameArr[$beModule][$i]] = $adb->query_result($result,0,$columnArr[$beModule][$i]);
            }
        }
        else    //没有ID则为空  和清除操作一致
        {
            for($i = 0; $i<count($columnArr[$beModule]);$i++)
            {
                $col_fields[$beModule][$fieldnameArr[$beModule][$i]] = '';
            }
        }
        $beTableidArr[] = $beTabid;
    }
 }
 $AllTableid = implode(',',$beTableidArr);
 $getBlocksSql = getBlocksSql($AllTableid);


 $result = $adb->pquery($getBlocksSql);
 //print_r(getAccountsContractsBlockInformation($result, $col_fields));
 if(isset($_REQUEST['mode']))
 {
    if($_REQUEST['mode'] == 'EditView')
    {
        $smarty->assign('BLOCKSTYLE',1); //编辑页 默认为打开
        $smarty->assign('HIDDENSTYLE',1); //隐藏区块上下箭头图标
    }
    else
    {
        $smarty->assign('BLOCKSTYLE',1);//详情页页 默认为打开
        $smarty->assign('HIDDENSTYLE',0);//详情页页 不隐藏区块上下箭头 可以点击
    }
 }
//工商查询
$deployarray=getSys_deploy(152);
$smarty->assign('ACCOUNTBUSINESS',$deployarray['deploy_value']);
 //是否显示
if($block_info['is_display'] == 0)
    $smarty->assign('BESTATUS','YES');
else
    $smarty->assign('BESTATUS','NO');
 $smarty->assign("RETURNMODULE",$frommodule);
 $smarty->assign("ACCOUNTSCONTACTS",'yes');
 crm_load_function_file('getAccountsContractsBlockInformation','include/utils','DetailViewUtils');
 $smarty->assign("BLOCKS", getAccountsContractsBlockInformation($result, $col_fields));
 echo '###SUCCESS###';
 $smarty->display("DetailView/MainDetailFields.tpl");
 exit();

 function getBlocksSql($AllTableid)
 {
    global $adb,$current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $sql = "SELECT '0' as readonly,ld_field.fieldid,ld_field.tabid,ld_field.columnname,ld_field.tablename,ld_field.uitype,ld_field.defaultvalue,
                ld_field.fieldname,ld_field.block,ld_field.typeofdata,ld_field.masseditable,ld_field.displaytype,ld_field.fieldonly
                ,case when ifnull(ld_tranlabel.fieldlabel,'')='' then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 FROM ld_field inner join  ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
        WHERE ld_field.tabid in ($AllTableid) and ld_tranlabel.tabid in ($AllTableid) AND ld_field.displaytype IN (1,2,4) and ld_field.presence in (0,2)
         and ld_tranlabel.languagetype='$languageType' and ld_tranlabel.trantable='ld_field' and ld_field.associatedfields = 0";
    $sql .=" ORDER BY ld_field.associatedsequence asc ";

    return $sql;
 }
 
?>