<?php
global $adb;
global $current_user;
$smarty = new lingdangCRM_Smarty;

//保存接收人手机字段设置信息
$phonetype = $_REQUEST['phonetype'];
if($phonetype!='')
{
    if($phonetype=='smsFirst')
    {  
        $type = 4;
    }
    else if($phonetype=='smsSecond')
    {
        $type = 5;
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
    header("Location: index.php?action=DetailView&module=SalesBack&parenttab=Sales&record=".$_REQUEST['salesbackid']."&sendtype=yes");
}

//保存内容模板信息
$contenttype = $_REQUEST['contenttype'];
if($contenttype!='')
{
    //这里的type和上面两个不一样的原因是不同的表
    if($contenttype=='smsFirst')
    {
        $type = 5;
        $description = '销售退货单退货短信内容1';
    }
    else if($contenttype=='smsSecond')
    {
        $type = 6;
        $description = '销售退货单退货短信内容2';
    }
    $CKcontent = $_REQUEST['CKcontent'];
    
    $checkSql = "select count(1) as count from ld_sendinformcontent where type = ? ";
    $checkResult = $adb->pquery($checkSql,array($type));
    
    if($adb->query_result($checkResult,0,"count") == 0)
    {
        $sqlinsert = "insert into ld_sendinformcontent(content,type,description) values(?,?,?)";
        $insertresult = $adb->pquery($sqlinsert,array($CKcontent,$type,$description));
    }
    else
    {
        $sqlupdate = "update ld_sendinformcontent set content = ? where type = ? ";
        $updateresult = $adb->pquery($sqlupdate,array($CKcontent,$type));
    }
    header("Location: index.php?action=DetailView&module=SalesBack&parenttab=Sales&record=".$_REQUEST['salesbackid']."&sendtype=yes");
}


if(isset($_REQUEST['record']) && $_REQUEST['record'] != '')
{
    //产品ID
    $productsid = $_REQUEST['productsid']; 
    $productsid = str_replace(",","','",$productsid);
    $productsid = substr($productsid, 0, strlen($productsid)-2);
    $productsid = "'".$productsid;
    //客户ID
    $accountid = $_REQUEST['accountid'];
    //确定需要发送的手机字段查找出来
    $phoneSetSql = "select id,fieldids,type from ld_sendphoneset where type in(4,5)";
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
                    $strFields = substr($columnname, 0, 3);
                    $needFieldSql .= $tablename.'.'.$columnname.",',',";
                }
                
                $needFieldSql = substr($needFieldSql, 0, strlen($needFieldSql)-5);
                $needFieldSql .= ')';
                if($type == '4'){                
                    $phoneSql = "select $needFieldSql as phone from ld_productcf where productid in ($productsid)";
                }else if($type == '5'){
                    $phoneSql = "select $needFieldSql as phone from ld_accountscf 
                    left join ld_contactdetails on ld_accountscf.accountid=ld_contactdetails.accountid 
                    left join ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid
                    left join ld_account on ld_account.accountid = ld_contactdetails.accountid
                    where ld_accountscf.accountid in ($accountid)";
                }  
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
                    if($type == '4')
                    {                
                        $smarty->assign("PHONEFIRST",$phonesNew);
                    }
                    else if($type == '5')
                    {
                        $smarty->assign("PHONESECOND",$phonesNew);
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
            if($type == '5')
            {                
                $smarty->assign("CONTENTFIRST",$content);
            }
            else if($type == '6')
            {
                $smarty->assign("CONTENTSECOND",$content);
            } 
        }
    }
}


$smarty->assign("SALESBACKID",$_REQUEST['record']);

echo "####:###";
$smarty->display("modules/MassSMS/SendSMSSalesBack.tpl");
exit();
?>