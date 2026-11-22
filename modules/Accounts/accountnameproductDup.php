<?php
/**
 * 信淼传媒的客户保护查重要求如下，请安排开发，尽早交付给客户。该功能是使用的第一步，其他功能都已实施好了。（xiaoshou360.com/xinmiao)

采用固定的文件或脚本方式即可，

重复客户不能保存。需“客户名称”+“保护产品”两个字段都重复时，方不能保存。保护产品是下拉框，内容已设好。
**/

global $adb;
if(globalStatic::$root_directory)
{
     $fieldobj=Field::getInstance('Accounts',$adb);
    $accountnamelabel=$fieldobj->getFieldInfoBykeyValue('columnname','accountname','fieldlabel');
    $cf_1743_label=$fieldobj->getFieldInfoBykeyValue('columnname','cf_1743','fieldlabel');
    if(empty($cf_1743_label))
    {
        echo 'aa###error###字段cf_1743不存在';
    }
    else
    {
       
        $sql='select 1 from ld_account INNER JOIN ld_accountscf
                on ld_account.accountid=ld_accountscf.accountid
                where ld_account.accountname=? and ld_accountscf.cf_1743=? and ld_account.accountid<>? limit 1';
        $accountname=$_REQUEST['accoutname'];
        $cf_1743=$_REQUEST['productname'];//保护产品
        $record=$_REQUEST['id'];
        if(empty($record))
        {
            $record=0;
        }
       
        $result=$adb->pquery($sql,array($accountname,$cf_1743,$record));
        if($adb->num_rows($result)>0)
        {
            
            echo 'aa###error###'.$accountnamelabel.'和'.$cf_1743_label.'的值已存在';
        }
        else
        {
            echo "##dupNOTHING##";
        }
    }
     
    exit();
    
}

?>