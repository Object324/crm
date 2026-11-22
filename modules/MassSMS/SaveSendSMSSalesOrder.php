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

$salesorderid = $_REQUEST['salesorderid'];
$sqlProductIDs = 'SELECT productid from ld_salesorderdetail where id = '.$salesorderid;
$productIDsResult =$adb->pquery($sqlProductIDs);
crm_load_class_file('cls_Send_MassSms','include/utils');
$cls_Send_MassSms = new cls_Send_MassSms();
//短信1保存
if($_POST['smsFirst'] == 'on')
{
    $textRecipientFirst = $_POST['textRecipientFirst'];
    $textContextFirst = $_POST['textContextFirst'];
    $phoneFirstResult=explode("\r\n",$textRecipientFirst);
    $fields = getTableFields(1);
    
    $now = date("Y-m-d H:i:s");
    $submitTime = $now;
    $createTime = $now;
    $receiveTheme = "合同订单短信1";
    $operator = $current_user->user_name;
    
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
                $SmsContent = getProdutcResult($textContextFirst,$salesorderid,$productids);   
                //性别替换
                if(strstr($SmsContent,'IDFUNCTION('))
                {
                    $SmsContent = getSexResult($SmsContent,$productids);
                }
                //城市天气替换，
                //先将CITYWEATHERFUNCTION('cf_1972','cf_1972')替换成CITYWEATHERFUNCTION('北京')
                //再在准备发送时将CITYWEATHERFUNCTION('北京')替换成对应的天气
                if(strstr($SmsContent,'CITYWEATHERFUNCTION('))
                {
                    $SmsContent = getCityResult($SmsContent,$salesorderid,$productids);
                }
                //天气替换
                /*
                if(strstr($SmsContent,'WEATHERFUNCTION('))
                {
                    $SmsContent = getWeatherResult($SmsContent);
                }
                */
                //其他替换
                $SmsContent = getResult($SmsContent);  
                
                $SmsContent = $SmsContent.'【'.$autograph.'】';
				$cls_Send_MassSms->send($CalledNumber,$SmsContent);
            }
        }
    }
    $updateSql = "update ld_salesorder set smsfirstdate = '$now' where salesorderid = $salesorderid ";
    $updateResult = $adb->query($updateSql);
}

//短信2保存
if($_POST['smsSecond'] == 'on')
{
    $textRecipientSecond = $_POST['textRecipientSecond'];
    $textContextSecond = $_POST['textContextSecond'];
    $phoneSecondResult=explode("\r\n",$textRecipientSecond);
    $fields = getTableFields(2);
    $now = date("Y-m-d H:i:s");
    
    //确定是否已经设置过了定时规则
    $type = 2;
    $timeSql = "select id,fieldid1,fieldid2,day,hours,minutes,type from ld_sendtimeset where type = ? ";
    $timeResult = $adb->pquery($timeSql,array($type));
    $countResult = $adb->num_rows($timeResult);
    
    $createTime = $now;
    $receiveTheme = "合同订单短信2";
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
                $SmsContent = getProdutcResult($textContextSecond,$salesorderid,$productids);   
                //性别替换
                if(strstr($SmsContent,'IDFUNCTION('))
                {
                    $SmsContent = getSexResult($SmsContent,$productids);
                }
                //城市天气替换，
                //先将CITYWEATHERFUNCTION('cf_1972','cf_1972')替换成CITYWEATHERFUNCTION('北京')
                //再在准备发送时将CITYWEATHERFUNCTION('北京')替换成对应的天气
                if(strstr($SmsContent,'CITYWEATHERFUNCTION('))
                {
                    $SmsContent = getCityResult($SmsContent,$salesorderid,$productids);
                }
                //天气替换
                /*
                if(strstr($SmsContent,'WEATHERFUNCTION('))
                {
                    $SmsContent = getWeatherResult($SmsContent);
                }
                */
                //其他替换
                $SmsContent = getResult($SmsContent);  
                //时间提前
                if($countResult > 0)
                {
                    $fieldid1 = $adb->query_result($timeResult,0,'fieldid1');
                    $fieldid2 = $adb->query_result($timeResult,0,'fieldid2');
                    $day = $adb->query_result($timeResult,0,'day');
                    $hours = $adb->query_result($timeResult,0,'hours');
                    $minutes = $adb->query_result($timeResult,0,'minutes');
                    
                    $strDateSql = "select columnname from ld_producttoolfield where producttoolfieldid = $fieldid1 ";
                    $resultDateSql =$adb->pquery($strDateSql);
                    if($adb->num_rows($resultDateSql)>0)
                    {
                        $dateColumnname = $adb->query_result($resultDateSql,0,'columnname');
                        $strDateSql = "select T2.$dateColumnname as value from 
                        ld_salesorderdetail as T1 
                        left join ld_salesorderdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids";
                        $resultDateSql =$adb->pquery($strDateSql);
                        if($adb->num_rows($resultDateSql)>0)
                        {
                            $dateValue = $adb->query_result($resultDateSql,0,'value');
                        }
                        else
                        {
                            $dateValue = date("Y-m-d");
                        }
                    }
                    $strTimeSql = "select columnname from ld_producttoolfield where producttoolfieldid = $fieldid2 ";
                    $resultTimeSql =$adb->pquery($strTimeSql);
                    if($adb->num_rows($resultTimeSql)>0)
                    {
                        $timeColumnname = $adb->query_result($resultTimeSql,0,'columnname');
                        $strTimeSql = "select T2.$timeColumnname as value from 
                        ld_salesorderdetail as T1 
                        left join ld_salesorderdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids";
                        $resultTimeSql =$adb->pquery($strTimeSql);
                        if($adb->num_rows($resultTimeSql)>0)
                        {
                            $timeValue = $adb->query_result($resultTimeSql,0,'value');
                        }
                        else
                        {
                            $timeValue = date("H:i:s");
                        }
                    }
                    $dateTimeValue = $dateValue.' '.$timeValue;
                    if($day!=0)
                    {
                        $dateTimeValue = date('Y-m-d H:i:s',strtotime("$dateTimeValue-$day day"));
                    }
                    if($hours!=0)
                    {
                        $dateTimeValue = date('Y-m-d H:i:s',strtotime("$dateTimeValue-$hours hour"));
                    }
                    if($minutes!=0)
                    {
                        $dateTimeValue = date('Y-m-d H:i:s',strtotime("$dateTimeValue-$minutes minute"));
                    }     
                    $submitTime = $dateTimeValue;              
                }
                else
                {
                    $submitTime = $now;
                }
                
                $SmsContent = $SmsContent.'【'.$autograph.'】';
				$cls_Send_MassSms->send($CalledNumber,$SmsContent);
            }
        }
    }
    $updateSql = "update ld_salesorder set smsseconddate = '$now' where salesorderid = $salesorderid ";
    $updateResult = $adb->query($updateSql);
}

//短信3保存
if($_POST['smsThird'] == 'on')
{
    $textRecipientThird = $_POST['textRecipientThird'];
    $textContextThird = $_POST['textContextThird'];
    $phoneThirdResult=explode("\r\n",$textRecipientThird);
    $fields = getTableFields(3);
    $now = date("Y-m-d H:i:s");
    //确定是否已经设置过了定时规则
    
    $type = 3;
    $timeSql = "select id,fieldid1,fieldid2,day,hours,minutes,type from ld_sendtimeset where type = ? ";
    $timeResult = $adb->pquery($timeSql,array($type));
    $countResult = $adb->num_rows($timeResult);
    
    $createTime = $now;
    $receiveTheme = "合同订单短信3";
    $operator = $current_user->user_name;
    
    $i = 0;
    foreach ($phoneThirdResult as $thirdResult)
    {    
        if(isset($thirdResult[10]))
        {   
            #获取电话号码
            $CalledNumber = substr($thirdResult, 0, 11);
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
                $SmsContent = getProdutcResult($textContextThird,$salesorderid,$productids);   
                //性别替换
                if(strstr($SmsContent,'IDFUNCTION('))
                {
                    $SmsContent = getSexResult($SmsContent,$productids);
                }
                //城市天气替换，
                //先将CITYWEATHERFUNCTION('cf_1972','cf_1972')替换成CITYWEATHERFUNCTION('北京')
                //再在准备发送时将CITYWEATHERFUNCTION('北京')替换成对应的天气
                if(strstr($SmsContent,'CITYWEATHERFUNCTION('))
                {
                    $SmsContent = getCityResult($SmsContent,$salesorderid,$productids);
                }
                //天气替换
                /*
                if(strstr($SmsContent,'WEATHERFUNCTION('))
                {
                    $SmsContent = getWeatherResult($SmsContent);
                }
                */
                //其他替换
                $SmsContent = getResult($SmsContent);  
                //时间提前
                if($countResult > 0)
                {
                    $fieldid1 = $adb->query_result($timeResult,0,'fieldid1');
                    $fieldid2 = $adb->query_result($timeResult,0,'fieldid2');
                    $day = $adb->query_result($timeResult,0,'day');
                    $hours = $adb->query_result($timeResult,0,'hours');
                    $minutes = $adb->query_result($timeResult,0,'minutes');
                    
                    $strDateSql = "select columnname from ld_producttoolfield where producttoolfieldid = $fieldid1 ";
                    $resultDateSql =$adb->pquery($strDateSql);
                    if($adb->num_rows($resultDateSql)>0)
                    {
                        $dateColumnname = $adb->query_result($resultDateSql,0,'columnname');
                        $strDateSql = "select T2.$dateColumnname as value from 
                        ld_salesorderdetail as T1 
                        left join ld_salesorderdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids";
                        $resultDateSql =$adb->pquery($strDateSql);
                        if($adb->num_rows($resultDateSql)>0)
                        {
                            $dateValue = $adb->query_result($resultDateSql,0,'value');
                        }
                        else
                        {
                            $dateValue = date("Y-m-d");
                        }
                    }
                    $strTimeSql = "select columnname from ld_producttoolfield where producttoolfieldid = $fieldid2 ";
                    $resultTimeSql =$adb->pquery($strTimeSql);
                    if($adb->num_rows($resultTimeSql)>0)
                    {
                        $timeColumnname = $adb->query_result($resultTimeSql,0,'columnname');
                        $strTimeSql = "select T2.$timeColumnname as value from 
                        ld_salesorderdetail as T1 
                        left join ld_salesorderdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids";
                        $resultTimeSql =$adb->pquery($strTimeSql);
                        if($adb->num_rows($resultTimeSql)>0)
                        {
                            $timeValue = $adb->query_result($resultTimeSql,0,'value');
                        }
                        else
                        {
                            $timeValue = date("H:i:s");
                        }
                    }
                    $dateTimeValue = $dateValue.' '.$timeValue;
                    if($day!=0)
                    {
                        $dateTimeValue = date('Y-m-d H:i:s',strtotime("$dateTimeValue-$day day"));
                    }
                    if($hours!=0)
                    {
                        $dateTimeValue = date('Y-m-d H:i:s',strtotime("$dateTimeValue-$hours hour"));
                    }
                    if($minutes!=0)
                    {
                        $dateTimeValue = date('Y-m-d H:i:s',strtotime("$dateTimeValue-$minutes minute"));
                    }     
                    $submitTime = $dateTimeValue;              
                }
                else
                {
                    $submitTime = $now;
                }
                $SmsContent = $SmsContent.'【'.$autograph.'】';
                $cls_Send_MassSms->send($CalledNumber,$SmsContent);
            }
        }
    }
    $updateSql = "update ld_salesorder set smsthirddate = '$now' where salesorderid = $salesorderid ";
    $updateResult = $adb->query($updateSql);
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
                                    where $tablename.$table_index = ".$_REQUEST['salesorderid'];
                           
                            break;
                        case 80://合同订单
                            $sql = "select ld_salesorder.subject as value from $tablename inner join ld_salesorder on 
                                    $tablename.$columnname = ld_salesorder.salesorderid 
                                    where $tablename.$table_index = ".$_REQUEST['salesorderid'];
                            break;
                        case 76://销售机会
                            $sql = "select ld_potential.potentialname as value from $tablename inner join ld_potential on 
                                    $tablename.$columnname = ld_potential.potentialid 
                                    where $tablename.$table_index = ".$_REQUEST['salesorderid'];
                            break;
                        case 53://负责人
                            $sql = "select ld_users.last_name as value from ld_users where id in 
                                    (select smownerid from ld_crmentity where crmid = ".$_REQUEST['salesorderid'].")";
                            break;
                        /*case 70://创建时间，修改时间
                            $sql = "select $tablename.$columnname as value from ld_crmentity where crmid = ".$_REQUEST['salesorderid'];
                            break;*/
                        default:                            
                              $sql = "select $tablename.$columnname as value from $tablename 
                                    where $tablename.$table_index = ".$_REQUEST['salesorderid'];
                                  
                              break;
                 }
                 //Edit:can reason:14248: 合同订单-明细界面：相关信息-短信记录：发送短信时，时间（时间类型字段）、发票号内容 没有显示
               if($tabcols[0]=='productdetailssf')
               {
                    $productids=0;
                    $salesorderid = $_REQUEST['salesorderid'];
                    $sqlProductIDs = 'SELECT productid from ld_inventoryproductrel where id = '.$salesorderid;
                    $productIDsResult =$adb->pquery($sqlProductIDs);
                    if($adb->num_rows($productIDsResult)>0)
                    {
                        $productids=$adb->query_result($productIDsResult,0,0);
                    }
                  $salesorderid=$_REQUEST['salesorderid'];
                  $sql="select T2.$fieldname as value from 
                        ld_salesorderdetail as T1 
                        left join ld_salesorderdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids ";
                      
                        
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
function getProdutcResult($Content,$salesorderid,$productids)
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
                        ld_inventoryproductrel as T1 
                        left join ld_inventoryproductrelscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids ";
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

//城市替换
function getCityResult($SmsContent,$salesorderid,$productids)
{
    global $adb;
    if(strstr($SmsContent,'CITYWEATHERFUNCTION('))
    {
        $cityWeatherFieldArr=explode('CITYWEATHERFUNCTION(',$SmsContent);
        
        for($i=0;$i<count($cityWeatherFieldArr);$i++)
        {
            if(strpos($cityWeatherFieldArr[$i],')')>0)
            {
                $cityWeatherField=explode(')',$cityWeatherFieldArr[1]);
            }
        }
        $strCityWeatherField = 'T2.'.$cityWeatherField[0].' as value ';
        
        $needReplace = "CITYWEATHERFUNCTION("."$cityWeatherField[0]".")";
                    
        $strSql = "select $strCityWeatherField from 
                        ld_salesorderdetail as T1 
                        left join ld_salesorderdetailscf as T2 on T1.lineitem_id = T2.lineitem_id
                        where id = $salesorderid and T1.productid = $productids ";
        $resultSql =$adb->pquery($strSql);
        if($adb->num_rows($resultSql)>0)
        {
            $value = $adb->query_result($resultSql,'value');//城市
            
            $needReplaceValue = "WEATHERFUNCTION("."$value".")";
            
            $SmsContent=str_replace($needReplace,$needReplaceValue,$SmsContent);
        }
        else
        {
            $SmsContent=str_replace($needReplace,"",$SmsContent);
        }
    }
    return $SmsContent;
}

//城市天气
function getWeatherResult($SmsContent)
{
    global $adb;
    if(strstr($SmsContent,'WEATHERFUNCTION('))
    {
        $cityWeatherFieldArr=explode('WEATHERFUNCTION(',$SmsContent);
        
        for($i=0;$i<count($cityWeatherFieldArr);$i++)
        {
            if(strpos($cityWeatherFieldArr[$i],')')>0)
            {
                $cityWeatherField=explode(')',$cityWeatherFieldArr[1]);
            }
        }
        for($i=0;$i<3;$i++)
        {
            $value .= getWeatherValue($cityWeatherField[0],$i);
        }
        
        $needReplace = "WEATHERFUNCTION("."$cityWeatherField[0]".")";
        
        $SmsContent=str_replace($needReplace,$value,$SmsContent);
        
    }
    return $SmsContent;
} 

function getWeatherValue($city,$day)
{
    $city=iconv("UTF-8", "gb2312", $city);
    $city=urlencode($city);
    $url = "http://php.weather.sina.com.cn/xml.php?city=".$city."&password=DJOYnieT8234jlsK&day=".$day;
    
    $datas = file_get_contents($url);
    
    preg_match_all("/<city>(.*?)<\/city>/is",$datas,$dataCity);
    preg_match_all("/<status1>(.*?)<\/status1>/is",$datas,$dataStatus1);//白天天气
    preg_match_all("/<status2>(.*?)<\/status2>/is",$datas,$dataStatus2);//夜晚天气
    preg_match_all("/<direction1>(.*?)<\/direction1>/is",$datas,$dataDirection1);//白天风向
    preg_match_all("/<direction2>(.*?)<\/direction2>/is",$datas,$dataDirection2);//夜晚风向
    preg_match_all("/<power1>(.*?)<\/power1>/is",$datas,$dataPower1);//白天风级
    preg_match_all("/<power2>(.*?)<\/power2>/is",$datas,$dataPower2);//夜晚风级
    preg_match_all("/<temperature1>(.*?)<\/temperature1>/is",$datas,$dataTemperature1);//白天温度
    preg_match_all("/<temperature2>(.*?)<\/temperature2>/is",$datas,$dataTemperature2);//夜晚温度
    preg_match_all("/<chy_shuoming>(.*?)<\/chy_shuoming>/is",$datas,$dataShuoming);//穿衣说明
    preg_match_all("/<savedate_weather>(.*?)<\/savedate_weather>/is",$datas,$dataDate);//日期
    
    $weekarray=array("日","一","二","三","四","五","六");
    $value = $dataDate[1][0].'，';
    $value .= '星期'.$weekarray[date('w',$dataDate[1][0])].'；';
    $value .= '白天天气'.$dataStatus1[1][0].'，夜晚天气'.$dataStatus1[1][0].'；';
    $value .= '最高气温'.$dataTemperature1[1][0].'℃，最低气温'.$dataTemperature2[1][0].'℃；';
    $value .= '白天风向'.$dataDirection1[1][0].'，风速'.$dataPower1[1][0].'，';
    $value .= '夜晚风向'.$dataDirection2[1][0].'，风速'.$dataPower2[1][0].'。';
    
    return $value;
}                   


header("Location: index.php?action=DetailView&module=SalesOrder&parenttab=Sales&record=".$_REQUEST['salesorderid']);

?>