<?php
global $adb,$current_user,$global_regop,$languageType;
$product_field_obj = Field::getInstance('Products',$adb);
$profieldlabel = $product_field_obj->getFieldLables();

$smarty = new lingdangCRM_Smarty;
$smarty->assign('PRODUCTFIELDLABELS',$profieldlabel);
$sql = "select  tabid,name,tablabel from ld_tab where (name in('accounts','contacts','quotes','salesorder','invoice','products','paymentplan','sendpayment','potentials','helpdesk','expense','contactrecords','vendors','vendorcontact','VendorContactRecords','purchaseorder','Stock','OutboundOrder','Checks','project') or printtab=1) and presence in(0,2)  order by tabsequence";
$result = $adb->pquery($sql,array());
$printtabs = array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $printtabs[$adb->query_result($result,$i,'tabid')]=getTranstab($adb->query_result($result,$i,'name'));
}

if(isset($_REQUEST['fieldid'])||isset($_REQUEST['qrcodetemplateid']))
{
    $fieldid = $_REQUEST['fieldid'];
    $qrcodetemplateid = $_REQUEST['qrcodetemplateid'];
    $sql = "select * from ld_qrcode_template where fieldid=? or qrcodetemplateid=?";
    $result = $adb->pquery($sql,array($fieldid,$qrcodetemplateid));
    //获取域名
//    $domain = $_SERVER['HTTP_REFERER'];
//    $domain = explode('index.php?',$domain);
//    $domain = $domain[0];
    if($adb->num_rows($result)>0)
    {
        $qrcodetemplateid = $adb->query_result($result,0,'qrcodetemplateid');
        $template_content = $adb->query_result($result,0,'template_content');
//        $template_content = str_replace('storage/',$domain.'storage/',$template_content);
        $smarty->assign("qrcodetemplateid",$qrcodetemplateid);
        $smarty->assign("fieldid",$fieldid);
        $smarty->assign('replacespacevalue',$adb->query_result($result,0,'replacespacevalue'));
        $smarty->assign("MODE","edit");
        $smarty->assign("MODECAPTION",getFixedLabel('EDIT'));
        $smarty->assign("CKEDITORHTML",$template_content);
    }
}
else
{
    $smarty->assign("MODE",'create');
    $smarty->assign("ISDEFAULT",0);
    $smarty->assign("TEMPLATENAME",'');
    $smarty->assign("CKEDITORHTML",'');
    $smarty->assign('REPLACESPACEVALUE','');
    $smarty->assign("MODECAPTION",getFixedLabel('NEWTEMPLATE'));
}

$cur_module = $_REQUEST['cur_module'];
$tabid = getTabid($cur_module);
$cur_focus = CRMEntity::getInstance($cur_module);
$smarty->assign("module_name",getTranstab($cur_module));

require('user_privileges/user_language_'.$current_user->id.'.php');
$main_tablename = $cur_focus->table_name;
if(get_file_address($cur_module,'ProductDetails'))
{
    $profldsql = 'select distinct defaultvalue,uitype,typeofdata,columnname,ld_tranlabel.fieldlabel from ld_producttoolfield inner join ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
          where languagetype=? and trantable=? and ld_producttoolfield.tabid=?
            and presence=0  and tablename not in(\''.$main_tablename.'\') order by sequence';
    $profldresult = $adb->pquery($profldsql,array($languageType,'ld_producttoolfield',$tabid));
    $rows = $adb->num_rows($profldresult);
    $prodtoolhtml = '';
    if($rows > 0){
        $prodtoolhtml = '<div id="divPrint5" class="TitleHeading BorTnone BorLnone BorRnone" style="display: none;">产品分录字段</div>
                            <table id="divPrint5_1" class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0" style="display: none;">
                                  <tbody>
                                      <tr>';
        for($i=0;$i<$rows;++ $i){
            $columnname = $adb->query_result($profldresult,$i,'columnname');
            $fieldlabel = $adb->query_result($profldresult,$i,'fieldlabel');
            //兼容V6.1版本之前的打印
            if($cur_module=='ServiceContracts'&&(strtolower($columnname)=='servicecontracts_end_date'||strtolower($columnname)=='servicecontracts_start_date'))
            {
                if(strtolower($columnname)=='servicecontracts_end_date')
                {
                    $columnname='end_date';
                }
                else
                {
                    $columnname='start_date';
                }
            }
            $prodtoolhtml .= '<td width="8%" align="right" class="DetailedTd1Label">'.$fieldlabel.'</td>
                              <td width="25%" align="left" class="DetailedTd2Info">[var.productdetails_'.$columnname.'_products]</td>';
            if(($i+1)%3 == 0){
                $prodtoolhtml .= '</tr><tr>';
            }
        }
        if($i%3 != 0){
            $k = 3-($i%3);
            for($j=0;$j<$k;++ $j){
                $prodtoolhtml .= '<td width="8%" align="right" class="DetailedTd1Label">&nbsp;</td>
                                 <td width="25%" align="left" class="DetailedTd2Info">&nbsp;</td>';
            }
        }
        $prodtoolhtml .= '</tr></tbody></table>';
    }
}
else if(get_file_address($cur_module,$cur_module.'DetailFieldsHtml'))
{
    $tabname_detail=$cur_focus->Detail_table;
    $tabname_detailscf=$cur_focus->Detail_table_scf;
    $detail_table_index=$cur_focus->Detail_table_id;
    $sql="select tablename,columnname,ld_tranlabel.fieldlabel from ld_tabdetailfield
            inner join ld_tranlabel on ld_tranlabel.Relateid=ld_tabdetailfield.tabdetailfieldid
            where ld_tabdetailfield.tabid=$tabid and ld_tranlabel.languagetype='$languageType' and ld_tranlabel.trantable='ld_tabdetailfield'
             and ld_tranlabel.tabid=$tabid  and presence in(0,2) and  ld_tabdetailfield.tablename in('$tabname_detail','$tabname_detailscf') ORDER BY sequence";
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    $prodtoolhtml='<div class=" VariableDivTitle marT10">'.getTranstab($cur_module).getFixedLabel('DETAIL').'</div>
            <table class=" VariableTable  borderL" width="100%" cellspacing="0" cellpadding="5" border="0">
              <tbody>
                <tr>';
    $prodtoolhtml .= '<td width="8%">'.getFixedLabel('SEQUENCE').'</td><td width="25%">[var.'.strtolower($cur_module).'details_#_'.strtolower($cur_module).']</td>';

    for($i=0;$i<$rows;$i++)
    {
        //收款单有在ld_tabdetailfield表中有entitytype字段
        $columnname = $adb->query_result($result,$i,'columnname');
        $tabdetailcolumns[$columnname]=$columnname;
    }
    $ik=0;
    for($i=0;$i<$rows;++ $i){
        $columnname = $adb->query_result($result,$i,'columnname');
        $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
        if($columnname=='entitytypeid'&&!array_key_exists($columnname,$tabdetailcolumns))
        {
            $prodtoolhtml .= '<td width="8%">'.getFixedLabel('SOURCETYPE').'</td><td width="25%">[var.'.strtolower($cur_module).'details_entitytype_'.strtolower($cur_module).']</td>';
            $ik++;
        }
        $prodtoolhtml .= '<td width="8%">'.$fieldlabel.'</td>
                                    <td width="25%">[var.'.strtolower($cur_module).'details_'.$columnname.'_'.strtolower($cur_module).']</td>';
        $ik++;
        if(($ik+1)%3 == 0){
            $prodtoolhtml .= '</tr><tr>';
        }
    }
    $i++;
    $ik++;
    if($ik%3 != 0){
        $k = 3-($ik%3);
        for($j=0;$j<$k;++ $j){
            $prodtoolhtml .= '<td width="8%">&nbsp;</td>
                                    <td width="26%">&nbsp;</td>';
        }
    }
    $prodtoolhtml .= '</tr></tbody></table>';
}

//获取客户首要联系人信息
$query = 'select fieldlabel from ld_tranlabel 
where tabid = 6 and ld_tranlabel.languagetype = ?
and Relateid = (select blockid from ld_blocks where blocklabel = \'LBL_ACCOUNT_PRIMARYCONTACT\' and tabid = 6)';
$result = $adb->pquery($query,array($languageType));
$block_fieldlabel = $adb->query_result($result,0,0);
require( globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$sqlcontact = 'select ld_field.columnname,ld_field.tablename,ld_field.fieldname, ld_tranlabel.fieldlabel as tranlabel  
FROM ld_field 
inner join ld_tranlabel 
on ld_tranlabel.relateid=ld_field.fieldid 
where  ld_tranlabel.trantable=\'ld_field\' 
and  ld_tranlabel.tabid=6 
and ld_field.tablename in(?,?,?) 
and ld_field.presence in(0,2) 
and ld_field.tabid=6 
and languagetype = ? 
order by ld_field.sequence asc,ld_field.fieldid asc,ld_tranlabel.languagetype desc';

$resultcontact=$adb->pquery($sqlcontact,array('ld_contactdetails','ld_contactscf','ld_contactaddress',$languageType));
$sqlcontactrows = $adb->num_rows($resultcontact);
if($sqlcontactrows > 0){
    for($i=0;$i<$sqlcontactrows;++ $i){
        $cacheacctcontfld[$i]['fieldlabel'] = $adb->query_result($resultcontact,$i,'tranlabel');
        $cacheacctcontfld[$i]['print'] = '[var.contactdetails_' . $adb->query_result($resultcontact,$i,'columnname') . '_Accounts]';
    }
}
$smarty->assign('BLOCKFIELDLABEL',$block_fieldlabel);
$smarty->assign('ACCTCONTFLD',$cacheacctcontfld);
$smarty->assign('PRODTOOLHTML',$prodtoolhtml);
$smarty->assign("PRINTTABS",$printtabs);
$smarty->assign("PRINTTABID",$tabid);
$smarty->assign('CURRENT_USERID',$current_user->id);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);
$smarty->assign('selectedModuleId',getTabid($_REQUEST['selectedModule']));
//@edit:liushuai,2020-8-6,reason:1000994/打印模板定制审批历史中增加“手写签名”变量
//判断手写签名是否开启
if(!isset($global_regop))
    $global_regop=RegOp::getInstance();
$smarty->assign('AUTOGRAPH',$global_regop->gethandleWriteSign_interface());

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('SOCIALPROMOTIONQRCODE').getFixedLabel('Contentcustomization');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");

$str=$smarty->fetch("createQrCodeTemplate.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>