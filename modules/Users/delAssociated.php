<?php
global $adb;
$return_module=$_REQUEST['return_module'];
$record=$_REQUEST['record'];

$delmodules=$_REQUEST['delmodule'];//删除的相关信息的模块
$delrecord=$_REQUEST['delrecord'];//删除的相关信息的模块单据的id
$focus=CRMEntity::getInstance($return_module);
$VersionInfo=getVersionInfo();

if($delmodules=='Products'){//删除与产品关联
    if($return_module=='PriceBooks'){//删除产品与价格表之间的关联
        $sql = 'delete from ld_pricebookproductrel where pricebookid=? and productid=?';
        $adb->pquery($sql,array($record,$delrecord));
    }else{
        $sql = 'delete from ld_seproductsrel where crmid=? and productid=? and setype=?';
        $adb->pquery($sql,array($record,$delrecord,$return_module));
    }
}
elseif($delmodules=='HelpDesk' || $delmodules=='SalesOrder')
{
    if($return_module=='Project')
    {
        $sql='delete from ld_crmentityrel  where  ( ld_crmentityrel.crmid = ? and  ld_crmentityrel.relcrmid = ? ) ';
        $adb->pquery($sql,array($record,$delrecord));
    }
}
elseif($delmodules=='Vendors')
{
    if($return_module=='Products')
    {
        $sql='delete from ld_crmentityrel  where  ( ld_crmentityrel.crmid = ? and  ld_crmentityrel.relcrmid = ? ) ';
        $adb->pquery($sql,array($record,$delrecord));
    }
}
elseif($delmodules=='Campaigns'){//删除与市场活动关联

    if($return_module=='Accounts' || $return_module=='ServiceCharge'){
        $sql ='delete from ld_campaignaccountrel where accountid=? and campaignid=?';
        $adb->pquery($sql,array($record,$delrecord));
    }else{
        $sql ='delete from ld_campaigncontrel where '.$focus->table_index.'=? and campaignid=?';
        $adb->pquery($sql,array($record,$delrecord));   
    }

}elseif($delmodules=='Documents'){//删除与知识管理关联
    $sql = 'delete from ld_senotesrel where crmid=? and notesid=?;';
    $adb->pquery($sql,array($record,$delrecord));
}elseif($delmodules=='Accounts'){
    if($return_module=='Products'){
        $sql = 'delete from ld_seproductsrel where crmid=? and productid=? and setype in(?,\'ServiceCharge\')';
        $adb->pquery($sql,array($delrecord,$record,$delmodules));
    }else if($return_module=='Campaigns')
    {
          $sql ='delete from ld_campaignaccountrel where campaignid=?  and accountid=?';
        $adb->pquery($sql,array($record,$delrecord));
    }
    else if($return_module=='Project')
    {
            if($VersionInfo['trade']=='edu'){
                $sql='delete from ld_lessionplanorg where accountid=? and otherid=?';
                $adb->pquery($sql,array($delrecord,$record));
            }
            else
            {
                $sql ='delete from ld_crmentityrel where relcrmid=?  and crmid=?';
                $adb->pquery($sql,array($delrecord,$record));
            }
    }
    else if($return_module=='Potentials'){
        $sql = 'delete from ld_accountpotentialrel where accountid=? and '.$focus->table_index.'=?;';
        $adb->pquery($sql,array($delrecord,$record));
    }else{
        //BUG0066702 zxm 20230522 政策、价格表模块，相关信息的客户关联，取消关联不生效。如图
        $sql ='delete from ld_crmentityrel where relcrmid=?  and crmid=?';
        $adb->pquery($sql,array($delrecord,$record));
    }
}elseif($delmodules=='Contacts'){
        if($return_module=='Products'){
            $sql = 'delete from ld_seproductsrel where crmid=? and productid=? and setype=?';
            $adb->pquery($sql,array($delrecord,$record,$delmodules));
        }elseif($return_module=='Campaigns'){
            $sql = 'delete from ld_campaigncontrel where contactid=? and campaignid=?;';
            $adb->pquery($sql,array($delrecord,$record));
        }
        else if($return_module=='Project' || $return_module=='ServiceContracts' || $return_module== 'SalesOrder'){
             $sql = 'delete from ld_crmentityrel where relcrmid=? and relmodule=?;';
            $adb->pquery($sql,array($delrecord,$delmodules));
        }
        else if($return_module == 'Potentials'){
            $sql = 'delete from ld_contpotentialrel where '.$focus->table_index.'=? and contactid=?';
            $adb->pquery($sql,array($record,$delrecord));
        }else{
            $sql='delete from ld_crmentityrel  where  ( ld_crmentityrel.crmid = ? and  ld_crmentityrel.relcrmid = ? ) ';
            $adb->pquery($sql,array($record,$delrecord));
        }
}elseif($delmodules=='Potentials'){
        $sql = 'delete from ld_seproductsrel where crmid=? and productid=? and setype=?';
        $adb->pquery($sql,array($delrecord,$record,$delmodules));
}
else{
    $sql='delete from ld_crmentityrel  where  ( ld_crmentityrel.crmid = ? and  ld_crmentityrel.relcrmid = ? ) ';
    $adb->pquery($sql,array($record,$delrecord));
}
?>

