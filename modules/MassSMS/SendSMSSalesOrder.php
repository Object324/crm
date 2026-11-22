<?php
/*
edit:diony
time:2015-01-06
reason:合同订单发送短信
*/

global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;

//保存接收人手机字段设置信息
$phonetype = $_REQUEST['phonetype'];
if($phonetype!='')
{
    if($phonetype=='smsFirst')
    {  
        $type = 1;
    }
    else if($phonetype=='smsSecond')
    {
        $type = 2;
    }
    else if($phonetype=='smsThird')
    {
        $type = 3;
    }
    $checkfieldids = $_REQUEST['checkfieldids'];
    
    $checkSql = "select count(1) as count from ld_sendphoneset where type = ? ";
    $checkResult = $adb->pquery($checkSql,array($type));
    
    if($adb->query_result($checkResult,0,"count") == 0)
    {
        $sqlinsert = "insert into ld_sendphoneset(fieldids,type) values(?,?) ";
        $insertresult = $adb->pquery($sqlinsert,array($checkfieldids,$type));
    }
    else
    {
        $sqlupdate = "update ld_sendphoneset set fieldids = ? where type = ? ";
        $updateresult = $adb->pquery($sqlupdate,array($checkfieldids,$type));
    }
    header("Location: index.php?action=DetailView&module=SalesOrder&parenttab=Sales&record=".$_REQUEST['salesorderid']."&sendtype=yes");
}

//保存定时时间设置信息
$timetype = $_REQUEST['timetype'];
if($timetype!='')
{
    if($timetype=='smsSecond')
    {
        $type = 2;
    }
    else if($timetype=='smsThird')
    {
        $type = 3;
    }
    $dateFieldid = $_REQUEST['selectDate'];
    $timeFieldid = $_REQUEST['selectTime'];
    $day = $_REQUEST['textDay'];
    $hours = $_REQUEST['textHours'];
    $minutes = $_REQUEST['textMinutes'];
    
    $checkSql = "select count(1) as count from ld_sendtimeset where type = ? ";
    $checkResult = $adb->pquery($checkSql,array($type));
    
    if($adb->query_result($checkResult,0,"count") == 0)
    {
        $sqlinsert = "insert into ld_sendtimeset(fieldid1,fieldid2,day,hours,minutes,type) values(?,?,?,?,?,?)";
        $insertresult = $adb->pquery($sqlinsert,array($dateFieldid,$timeFieldid,$day,$hours,$minutes,$type));
    }
    else
    {
        $sqlupdate = "update ld_sendtimeset set fieldid1 = ?,fieldid2 = ?,day = ?,hours = ?,minutes = ? where type = ? ";
        $updateresult = $adb->pquery($sqlupdate,array($dateFieldid,$timeFieldid,$day,$hours,$minutes,$type));
    }
    header("Location: index.php?action=DetailView&module=SalesOrder&parenttab=Sales&record=".$_REQUEST['salesorderid']."&sendtype=yes");
}

//保存内容模板信息
$contenttype = $_REQUEST['contenttype'];
if($contenttype!='')
{
    //这里的type和上面两个不一样的原因是不同的表
    if($contenttype=='smsFirst')
    {
        $type = 2;
    }
    else if($contenttype=='smsSecond')
    {
        $type = 3;
    }
    else if($contenttype=='smsThird')
    {
        $type = 4;
    }
    $CKcontent = $_REQUEST['CKcontent'];
    
    $checkSql = "select count(1) as count from ld_sendinformcontent where type = ? ";
    $checkResult = $adb->pquery($checkSql,array($type));
    
    if($adb->query_result($checkResult,0,"count") == 0)
    {
        $sqlinsert = "insert into ld_sendinformcontent(content,type,description) values(?,?,?)";
        $insertresult = $adb->pquery($sqlinsert,array($CKcontent,$type,'合同订单发送短信'));
    }
    else
    {
        $sqlupdate = "update ld_sendinformcontent set content = ? where type = ? ";
        $updateresult = $adb->pquery($sqlupdate,array($CKcontent,$type));
    }
    header("Location: index.php?action=DetailView&module=SalesOrder&parenttab=Sales&record=".$_REQUEST['salesorderid']."&sendtype=yes");
}


if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    //产品ID
    $productsid = $_REQUEST['productsid']; 
    $productsid = str_replace(",","','",$productsid);
    $productsid = substr($productsid, 0, strlen($productsid)-2);
    $productsid = "'".$productsid;
    
    //确定需要发送的手机字段查找出来
    $phoneSetSql = "select id,fieldids,type from ld_sendphoneset  where type in(1,2,3)";
    $phoneSetResult = $adb->pquery($phoneSetSql,array());
    if($adb->num_rows($phoneSetResult))
    {
        for($i=0;$i<$adb->num_rows($phoneSetResult);$i++)
        {
            $type = $adb->query_result($phoneSetResult,$i,'type');
            $fieldids = $adb->query_result($phoneSetResult,$i,'fieldids');
            $fieldids = str_replace(",","','",$fieldids);
            $fieldids = substr($fieldids, 0, strlen($fieldids)-2);
            $fieldids = "'".$fieldids;
            
            //根据获取的字段ID，将表名和字段名获取出来
            $sqlField="select tablename,columnname from ld_field where fieldid in ($fieldids)";
            $sqlFieldResult=$adb->query($sqlField);
            $num_rows = $adb->num_rows($sqlFieldResult);
            $fieldArray = array();
            if($adb->num_rows($sqlFieldResult))
            {
                //获取到需要查找的字段组合
                $needFieldSql = 'concat(';
                for($j=0;$j<$adb->num_rows($sqlFieldResult);$j++)
                {
                    $tablename = $adb->query_result($sqlFieldResult,$j,'tablename');
                    $columnname = $adb->query_result($sqlFieldResult,$j,'columnname');
                    $needFieldSql .= $tablename.'.'.$columnname.",',',";
                }
                $needFieldSql = substr($needFieldSql, 0, strlen($needFieldSql)-5);
                $needFieldSql .= ')';
                if($type == '1' || $type == '2')
                {
                    $phoneSql = "select $needFieldSql as phone from ld_productcf where productid in ($productsid)";
                    $phoneResult = $adb->pquery($phoneSql,array());
                    if($adb->num_rows($phoneResult))
                    {
                        $phones = '';
                        for($k=0;$k<$adb->num_rows($phoneResult);$k++)
                        {
                            $phone = $adb->query_result($phoneResult,$k,'phone');
                            $phones .= $phone.',';
                        }                    
                        //将字符串改转换成数组，去掉重复的号码，然后再转换成字符串
                        $arrOld=explode(",",$phones);
                        $phonesNew=implode(",",array_unique($arrOld));
                        //将”，“改成换行符
                        $phonesNew=str_replace(",","\r",$phonesNew);
                        if($type == '1')
                        {                
                            $smarty->assign("PHONEFIRST",$phonesNew);
                        }
                        else if($type == '2')
                        {
                            $smarty->assign("PHONESECOND",$phonesNew);
                        }       
                    }  
                }
                else if($type == '3')
                {
                    $phoneSql = "select $needFieldSql as phone 
                        from ld_account 
                        left join ld_accountscf on ld_account.accountid = ld_accountscf.accountid
                        left join ld_contactdetails on ld_contactdetails.accountid = ld_account.accountid
                        left join ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid 
                        where ld_account.accountid = 
                        (select accountid from ld_salesorder where salesorderid = ?)";
                    $phoneResult = $adb->pquery($phoneSql,array($_REQUEST['record']));
                    if($adb->num_rows($phoneResult))
                    {
                        $phones = '';
                        for($k=0;$k<$adb->num_rows($phoneResult);$k++)
                        {
                            $phone = $adb->query_result($phoneResult,$k,'phone');
                            $phones .= $phone.',';
                        }                    
                        //将字符串改转换成数组，去掉重复的号码，然后再转换成字符串
                        $arrOld=explode(",",$phones);
                        $phonesNew=implode(",",array_unique($arrOld));
                        //将”，“改成换行符
                        $phonesNew=str_replace(",","\r",$phonesNew);
                        
                        $smarty->assign("PHONETHIRD",$phonesNew);
                               
                    }
                }
                
            }                 
        }
    }
    
    //短信内容
    $contentSql = "select id,content,type,description from ld_sendinformcontent ";
    $contentResult = $adb->pquery($contentSql,array());
    if($adb->num_rows($contentResult))
    {
        for($i=0;$i<$adb->num_rows($contentResult);$i++)
        {
            $content = $adb->query_result($contentResult,$i,'content');
            $type = $adb->query_result($contentResult,$i,'type');
            //这里的type和上面两个不一样的原因是不同的表
            if($type == '2')
            {                
                $smarty->assign("CONTENTFIRST",$content);
            }
            else if($type == '3')
            {
                $smarty->assign("CONTENTSECOND",$content);
            }            
            else if($type == '4')
            {
                $smarty->assign("CONTENTTHIRD",$content);
            }
        }
    }
}


$smarty->assign("SALESORDERID",$_REQUEST['record']);

echo "####:###";
$smarty->display("modules/MassSMS/SendSMSSalesOrder.tpl");
exit();
?>