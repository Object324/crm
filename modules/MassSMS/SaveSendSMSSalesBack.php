<?php
/*
保存合同订单发送短信
*/ 

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;

//获取短信签名
$SMSarray = GetSMSAutograph();
$autograph = $SMSarray['autograph'];

$salesbackid = $_REQUEST['salesbackid'];
$sqlProductIDs = 'SELECT productid from ld_salesbackdetail where id = '.$salesbackid;
$productIDsResult =$adb->pquery($sqlProductIDs);
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
//短信1保存
if($_POST['smsFirst'] == 'on')
{
    $textRecipientFirst = $_POST['textRecipientFirst'];
    $textContextFirst = $_POST['textContextFirst'];
    $fields = getTableFields(4);
    $now = date("Y-m-d H:i:s");
    $submitTime = $now;
    $createTime = $now;
    $receiveTheme = "销售退货单短信1";
    $operator = $current_user->user_name;
    
    $phoneFirstResult=explode("\r\n",$textRecipientFirst);
    
    $i = 0;
    foreach ($phoneFirstResult as $firstResult)
    {    
        if(isset($firstResult[10]))
        {   
            #获取电话号码
            $CalledNumber = substr($firstResult, 0, 11);
            if($CalledNumber!='' && preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$CalledNumber))
            {
                $BatchNo=GetSMSBatchNo();
                $CalledNumber = $CalledNumber;
                
                if($adb->num_rows($productIDsResult)>0)
                {
                    for($i=0;$i<$adb->num_rows($productIDsResult);$i++)
                    {
                        $productids = $adb->query_result($productIDsResult,$i,'productid');
                        $sqlPhone = "select $fields from ld_productcf where productid=$productids and $fields = '$CalledNumber'" ;
                        $sqlPhoneResult =$adb->pquery($sqlPhone);
                        if($adb->num_rows($sqlPhoneResult)>0)
                        {
                            break;
                        }
                    }
                }
                //产品字段替换
                $SmsContent = getProdutcResult($textContextFirst,$salesbackid,$productids);
                //性别替换
                if(strstr($SmsContent,'IDFUNCTION('))
                {
                    $SmsContent = getSexResult($SmsContent,$productids);
                }
                //其他替换
                $SmsContent = getResult($SmsContent);  
                $SmsContent = $SmsContent.'【'.$autograph.'】';
                $cls_Send_MassSms->send($CalledNumber,$SmsContent);
            }
        }
    }
}

//短信2保存
if($_POST['smsSecond'] == 'on')
{
    $textRecipientSecond = $_POST['textRecipientSecond'];
    $textContextSecond = $_POST['textContextSecond'];
    $phoneSecondResult=explode("\r\n",$textRecipientSecond);
    $fields = getTableFields(5);
    $now = date("Y-m-d H:i:s");
    $submitTime = $now;
    $createTime = $now;
    $receiveTheme = "销售退货单短信2";
    $operator = $current_user->user_name;
    
    $i = 0;
    foreach ($phoneSecondResult as $secondResult)
    {    
        if(isset($secondResult[10]))
        {   
            #获取电话号码
            $CalledNumber = substr($secondResult, 0, 11);
            if($CalledNumber!='' && preg_match("/^((\(\d{3}\))|(\d{3}\-))?1\d{10}$/",$CalledNumber))
            {
                $BatchNo=GetSMSBatchNo();
                $CalledNumber = $CalledNumber;                
                if($adb->num_rows($productIDsResult)>0)
                {
                    for($i=0;$i<$adb->num_rows($productIDsResult);$i++)
                    {
                        $productids = $adb->query_result($productIDsResult,$i,'productid');
                        $sqlPhone = "select $fields from ld_productcf where productid=$productids and $fields = '$CalledNumber'" ;
                        $sqlPhoneResult =$adb->pquery($sqlPhone);
                        if($adb->num_rows($sqlPhoneResult)>0)
                        {
                            break;
                        }
                    }
                }
                //产品字段替换
                $SmsContent = getProdutcResult($textContextSecond,$salesbackid,$productids);   
                //性别替换
                if(strstr($SmsContent,'IDFUNCTION('))
                {
                    $SmsContent = getSexResult($SmsContent,$productids);
                }
                //其他替换
                $SmsContent = getResult($SmsContent);  
                
                $SmsContent = $SmsContent.'【'.$autograph.'】';
				$cls_Send_MassSms->send($CalledNumber,$SmsContent);
            }
        }
    }
}


//判断合同订单对应的短信是否有尚未发出，如果有删除该短信
$salesOrderSql = "select salesorderid from ld_salesback where salesbackid = $salesbackid " ;
$salesOrderResult =$adb->pquery($salesOrderSql);
if($adb->num_rows($salesOrderResult)>0)
{
    $salesorderid = $adb->query_result($salesOrderResult,0,'salesorderid');
    $now = date("Y-m-d H:i:s");
    //$smsUnSql = "select * from ld_smssend where relatieid = $salesorderid and UNIX_TIMESTAMP('$now')<UNIX_TIMESTAMP(SubmitTime)" ;
    $smsUnDelSql = "delete from ld_smssend where relatieid = $salesorderid and UNIX_TIMESTAMP('$now')<UNIX_TIMESTAMP(SubmitTime)" ;
    $smsUnDelResult =$adb->pquery($smsUnDelSql);
}


//获取手机字段
function getTableFields($type)
{
    global $adb;
    global $current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    //确定需要发送的手机字段查找出来
    $SqlFieldCheck = "select id,fieldids,type from ld_sendphoneset where type = ?";
    $resultCheck = $adb->pquery($SqlFieldCheck,array($type));
    if($adb->num_rows($resultCheck)>0)
    {
        $checkfields = $adb->query_result($resultCheck,0,'fieldids');
        $checkfields = str_replace(",","','",$checkfields);
        $checkfields = substr($checkfields, 0, strlen($checkfields)-2);
        $checkfields = "'".$checkfields;
    }
    
    //所有手机字段查找出来
    $SqlField = "select ld_field.fieldid,ld_field.tablename,ld_field.fieldname,ld_tranlabel.fieldlabel  
                from ld_field 
                left join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                where ld_field.tabid = 14 and ld_field.uitype = 1101
                and ld_field.presence in(0,2) and fieldid in ($checkfields)
                and ld_tranlabel.languagetype = ? and ld_tranlabel.trantable = ?
                order by ld_field.fieldid";
    $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
    $fields='';
    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $fieldid = $adb->query_result($result,$i,'fieldid');
        $tablename = $adb->query_result($result,$i,'tablename');
        $fieldname = $adb->query_result($result,$i,'fieldname');
        $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
        $fields .= $tablename.'.'.$fieldname.',';
    }
    
    $fields = substr($fields, 0, strlen($fields)-1);
    return $fields;    
}

//其他
function getResult($Content)
{        
    global $adb;
    $printcols=preg_split("/(\[Var.|\[var.|\[VAR.|\[vAR.|\[VAr.|\[VaR.|\[vaR.|\[vAr.)/",$Content);
  
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
            require_once('modules/'.$curtabname.'/'.$curtabname.'.php');
            $focus=new $curtabname;
            $maintablename=$focus->table_name;
            $table_index=$focus->table_index;
            
            for($fi=1 ;$fi<count($tabcols)-1;$fi++)
            {
                 if($fi!=(count($tabcols)-2))
                     $fieldname.=$tabcols[$fi].'_';
                else
                    $fieldname.=$tabcols[$fi];
            }
            //print_r($fieldname);
            if(count($tabcols)>0&&strlen($tabcols[1])>0&&strlen($tabcols[0])>0)
            {
                 if(strtolower($tabcols[0])!='crmentity')
                 {
                     $fieldsql='select fieldname,columnname,tablename,uitype,tabid  from ld_field where  fieldname=? and tablename=?';
                     $result=$adb->pquery($fieldsql,array($fieldname,'ld_'.$tabcols[0]));
                 } 
                 else
                 {
                    $fieldsql='select fieldname,columnname,tablename,uitype,ld_field.tabid  from ld_field inner join ld_tab on ld_tab.tabid=ld_field.tabid where  ld_tab.name=? and fieldname=? and tablename=?';
                    $result=$adb->pquery($fieldsql,array($curtabname,$fieldname,'ld_'.$tabcols[0]));
                 }
                 if($adb->num_rows($result)>0)
                 {
                    $columnname=$adb->query_result($result,0,'columnname');
                    $fieldname=$adb->query_result($result,0,'fieldname');
                    $tablename=$adb->query_result($result,0,'tablename');
                    $uitype=$adb->query_result($result,0,'uitype');
                    $curtabid=$adb->query_result($result,0,'tabid');
                 }
                 
                 $sql = "";                 
                 switch($uitype)
                 {
                        case 73://客户
                            $sql = "select ld_account.accountname as value from $tablename inner join ld_account on 
                                    $tablename.$columnname = ld_account.accountid 
                                    where $tablename.$table_index = ".$_REQUEST['salesbackid'];
                           
                            break;
                        case 80://合同订单
                            $sql = "select ld_salesorder.subject as value from $tablename inner join ld_salesorder on 
                                    $tablename.$columnname = ld_salesorder.salesbackid 
                                    where $tablename.$table_index = ".$_REQUEST['salesbackid'];
                            break;
                        case 76://销售机会
                            $sql = "select ld_potential.potentialname as value from $tablename inner join ld_potential on 
                                    $tablename.$columnname = ld_potential.potentialid 
                                    where $tablename.$table_index = ".$_REQUEST['salesbackid'];
                            break;
                        case 53://负责人
                            $sql = "select ld_users.last_name as value from ld_users where id in 
                                    (select smownerid from ld_crmentity where crmid = ".$_REQUEST['salesbackid'].")";
                            break;
                        case 70://创建时间，修改时间
                            $sql = "select $tablename.$columnname as value from ld_crmentity where crmid = ".$_REQUEST['salesbackid'];
                            break;
                        default:                            
                              $sql = "select $tablename.$columnname as value from $tablename 
                                    where $tablename.$table_index = ".$_REQUEST['salesbackid'];
                              break;
                 }
               
                 if(strlen($sql))
                 {
                     $result=$adb->query($sql);
                     if($adb->num_rows($result)>0)
                     {
                        $value=$adb->query_result($result,0,'value');
                     }
                 }
                 $printcols[$i] = $value.$colsinfovalue; 
            }
        }
    }
    return implode('',$printcols);
}

//产品
function getProdutcResult($Content,$salesbackid,$productids)
{        
    global $adb;
    $printcols=preg_split("/(\[PVar.|\[Pvar.|\[PVAR.|\[PvAR.|\[PVAr.|\[PVaR.|\[PvaR.|\[PvAr.\[pVar.|\[pvar.|\[pVAR.|\[pvAR.|\[pVAr.|\[pVaR.|\[pvaR.|\[pvAr.)/",$Content);
    
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
            if($curtabname == 'products')
            {
                $curtabname = 'Products';
            }
            require_once('modules/'.$curtabname.'/'.$curtabname.'.php');
            $focus=new $curtabname;
            $maintablename=$focus->table_name;
            $table_index=$focus->table_index;
            
            for($fi=1 ;$fi<count($tabcols)-1;$fi++)
            {
                 if($fi!=(count($tabcols)-2))
                     $fieldname.=$tabcols[$fi].'_';
                else
                    $fieldname.=$tabcols[$fi];
            }
            
            if(count($tabcols)>0&&strlen($tabcols[1])>0&&strlen($tabcols[0])>0)
            {
                 if(strtolower($tabcols[0])!='crmentity')
                 {
                     $fieldsql='select fieldname,columnname,tablename,uitype,tabid  from ld_field where  fieldname=? and tablename=? ';
                     if($tabcols[0]=='productdetails')
                     {
                        $strFields = substr($fieldname, 0, 3);
                        if($strFields=='cf_')
                        {
                            $result=$adb->pquery($fieldsql,array($fieldname,'ld_productcf'));
                        }
                        else
                        {
                            $result=$adb->pquery($fieldsql,array($fieldname,'ld_products'));
                        }
                        if($adb->num_rows($result)>0)
                        {
                            $columnname=$adb->query_result($result,0,'columnname');
                            $fieldname=$adb->query_result($result,0,'fieldname');
                            $tablename=$adb->query_result($result,0,'tablename');
                            $uitype=$adb->query_result($result,0,'uitype');
                            $curtabid=$adb->query_result($result,0,'tabid');
                        }
                         
                        $sql = "";                 
                        switch($uitype)
                        {
                            case 73://客户
                                $sql = "select ld_account.accountname as value from $tablename inner join ld_account on 
                                        $tablename.$columnname = ld_account.accountid 
                                        where $tablename.$table_index = ".$_REQUEST['record'];
                                break;
                            default:
                                  $sql = "select $tablename.$columnname as value from $tablename 
                                        where $tablename.$table_index = ".$productids;
                                  break;
                        }
                        
                        if(strlen($sql))
                        {
                             $result=$adb->query($sql);
                             if($adb->num_rows($result)>0)
                             {
                                $value=$adb->query_result($result,0,'value');
                             }
                        }
                        $printcols[$i] = $value.$colsinfovalue; 
                     }
                     else if($tabcols[0]=='productdetailssf')
                     {
                        $sql="select T2.$fieldname as value from 
                        ld_salesbackdetail as T1 
                        left join ld_salessbackdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesbackid and T1.productid = $productids ";
                        $result=$adb->pquery($sql,array());
                        if($adb->num_rows($result)>0)
                        {
                            $value=$adb->query_result($result,0,'value');
                        }
                        $printcols[$i] = $value.$colsinfovalue; 
                     }
                 }
            }
            
        }
    }
    return implode('',$printcols);
}

//性别
function getSexResult($SmsContent,$productids)
{
    global $adb;
    $productFieldArr=explode('IDFUNCTION(',$SmsContent);
                    
    for($i=0;$i<count($productFieldArr);$i++)
    {
        if(strpos($productFieldArr[$i],')')>0)
        {
            $productField=explode(')',$productFieldArr[1]);
        }
    }
    $needReplace = "IDFUNCTION("."$productField[0]".")";
                        
    $strSql = "select $productField[0] as value from ld_products 
    left join ld_productcf on ld_products.productid = ld_productcf.productid where ld_products.productid = $productids ";
    $resultSql =$adb->pquery($strSql);
    if($adb->num_rows($resultSql)>0)
    {
        $value = $adb->query_result($resultSql,'value');//批次号  
        $sex = substr($value, -2, 1) % 2 ? '男' : '女';
        if($sex=='男')
        {
            $SmsContent=str_replace($needReplace,"先生",$SmsContent);
        }
        else
        {
            $SmsContent=str_replace($needReplace,"女士",$SmsContent);
        }
    }
    else
    {
        $SmsContent=str_replace($needReplace,"",$SmsContent);
    }
    return $SmsContent;
}



header("Location: index.php?action=DetailView&module=SalesBack&parenttab=Sales&record=".$_REQUEST['salesbackid']);

?>