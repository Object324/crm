<?php
global $adb;
global $currentModule;
global $current_user;
$_REQUEST['diony']=true;

$frommodule=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($frommodule);
$arr['modulelabel']=gettranstab($frommodule);
$arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
$arr['accordingimportdatalabel']=getFixedLabel('ACCORDINGTEMPLATEIMPORTDATA');//请按照数据模板的格式准备要导入的数据。
$arr['downloadtemplatedatalabel']=getFixedLabel('DOWNTEMPLATEDATA');//下载模板数据
$arr['viewcareitemlabel']=getFixedLabel('VIEWCAREITEM');//查看注意事项
$arr['notelabel']=getFixedLabel('NOTE');//注意事项
$arr['notencontent_firstlabel']=getFixedLabel('STOPDELETEIMPORTTEMPLATEHEAD'); //模板中的表头名称不可更改，表头行不能删除
$arr['notencontent_secondlabel']=getFixedLabel('MAYADJUSTORDERIMPORT');//项目顺序可以调整，不需要的项目可以删减
$arr['notencontent_thirdlabel']=getFixedLabel('REDREPRESENTNOTEMPTY'); //红色*表示为必录项，必须保留并且不能为空

$arr['dup_setdupfields_label']=getFixedLabel("IMPORT_PLEASESETDUMPLICATEFIELDS").$arr['modulelabel'].getFixedLabel('CHECKIMPORTFIELD');//请设置模块查重字段
$arr['dup_importmethod_label']=getFixedLabel("IMPORT_PLEASESETIMPORTMODE").$arr['modulelabel'].getFixedLabel('REPEAT_IMPORT_MODE');//请设置重复导入方式


$smarty=new lingdangCRM_Smarty();
$fields=$focus->fieldobj->getModuleFields();
$blocks=$focus->fieldobj->getBlockVisibleInfos();
//$tmpblocks=$blocks;
$tmpblockids=array();
$fileblockdel='yes';
$modulenoshowfields['Users']=array('activity_view','lead_view','hour_format','end_hour'
                        ,'start_hour','title','reports_to_id','phone_other'
                        ,'secondaryemail','signature','address_street','address_city','address_state','address_postalcode'
                        ,'address_country','accesskey','time_zone','currency_id','currency_grouping_pattern','currency_decimal_separator'
                        ,'currency_grouping_separator','currency_symbol_placement','internal_mailer','theme','language'
                        ,'reminder_interval','asterisk_extension','use_asterisk','attachmentsid','date_format','email2'
                        ,'imagename','viewothers','editothers'
                        ,'delothers','viewselfbills','edit_other_mobile','edit_me_mobile','is_mobile_style'
                        ,'select_servicedetail','select_due_date','trackpostion','login_sms','telephone_view'
                        ,'push_work_reminds','push_news_reminds','push_wx_reminds','scopeauthority'
                        ,'accountallview','groupid','profileid','approvestatus','approveby');
    if($currentModule=='Users')
    {
        $deployarray=getSys_deploy(55);//呼叫中心类型
        $deploy_value=$deployarray['deploy_value']??'';
        if($deploy_value=='汉天EC2')
        {
            $modulenoshowfields['Users'][]='sopho_exten';
            $modulenoshowfields['Users'][]='sopho_queue';
            $modulenoshowfields['Users'][]='jw_user';
                        
        }
        else  if($deploy_value=='苏州思孚')
        {
            $modulenoshowfields['Users'][]='hantian_exten';
            $modulenoshowfields['Users'][]='jw_user';
        }
        else if($deploy_value=='苏州九维')
        {
            $modulenoshowfields['Users'][]='hantian_exten';
            $modulenoshowfields['Users'][]='sopho_exten';
            $modulenoshowfields['Users'][]='sopho_queue';
        }
        else 
        {
            $modulenoshowfields['Users'][]='hantian_exten';
            $modulenoshowfields['Users'][]='sopho_exten';
            $modulenoshowfields['Users'][]='sopho_queue';
            $modulenoshowfields['Users'][]='jw_user';
        }
    }
foreach($fields as $fieldname=>$fieldinfo)
{
      if(in_array($fieldname,$modulenoshowfields['Users'])&&$currentModule=='Users')
         {
            continue;
         }
         if($fieldinfo->getUIType()==64 ||$fieldinfo->getUIType()==65||$fieldinfo->getUIType()==301)
         {
            continue;
         }
         $tablename=$fieldinfo->getTableName();
         
         if($currentModule=="ServiceCharge"&&($tablename=='ld_contactdetails'||$tablename=='ld_contactscf'))
                continue;
            $tmpfields[]=$fieldinfo;
}

$fields=$tmpfields;

foreach($fields as $fieldname=>$fieldinfo)
{
  
    if($fieldinfo->getUIType()==69 ||$fieldinfo->getUIType()==1109 ||$fieldinfo->getUIType()==28)
    {
        $fileattachblockid=$fieldinfo->getBlockId();
    }
    else 
    {
        $tmpblockids[]=$fieldinfo->getBlockId();
        if(in_array($fileattachblockid,$tmpblockids))
        {
            $fileblockdel='no';
            
           break;
        }
    }
}
foreach($blocks as $blockid=>$blockinfo)
{
    if($fileblockdel=='yes'&&$blockid==$fileattachblockid)
    {
        continue;
    }
    if($blockinfo['label']=='LBL_LABEL')
    {
        //edit:can 2020-12-01 43430: （61mis.com/kfbcrm）客户管理-客户-导入；在操作客户导入时，设置客户查重字段中不应存在“标签”；它不是一个字段属性的，且业务上允许是重复的；
        continue;
    }
    if(array_key_exists($blockid,$focus->fieldobj->presencefield_blockids))
    {
        $tmpblocks[$blockid]=$blockinfo;
    }
}
if($currentModule=='Accounts'||$currentModule=="ServiceCharge")
{
   
    foreach($tmpblocks as $blockid=> $blockinfo)
    {
        if($blockinfo['label']=='LBL_ACCOUNT_PRIMARYCONTACT'||$blockinfo['label']=='LBL_PUBLICACCOUNT_LOG')
        {
             unset($tmpblocks[$blockid]);
            continue;
        }
        $tmpblocks[$blockid]=$blockinfo;
    }
}

$blocks=$tmpblocks;

$smarty->assign("FIELDS",$fields);
$smarty->assign("BLOCKS",$blocks);
//zkt 获取源单类型，用于收付款单判断源单类型，若含有源单类型使用产品分录即withdetail=yes，则显示设置产品管理不存在时导入方式
$sourcemodule_arr = getSourceModule($frommodule);
$billhave_productdetail = 'no';
foreach($sourcemodule_arr as $sourcemoduleinfo)
{
    if($sourcemoduleinfo['withdetail'] == 'yes'){
        $billhave_productdetail = 'yes';
    }
}
$sql='select * from ld_importcheckdupfields where entitytype=? order by sequence asc ';
$result=$adb->pquery($sql,array($frommodule))  ;
$detailmodule='';

if((get_file_address($frommodule,"ProductDetails")&&$frommodule!='ServiceCharge')
    ||(($frommodule == 'CashBill'||$frommodule == 'SendCashBill')&&$billhave_productdetail=='yes'))
{
    $arr['detaildupcheckmethod']=getFixedLabel("IMPORT_PLEASESETDUMPLICATEFIELDS").getTranstab("Products").getFixedLabel('CHECKIMPORTFIELD');//设置产品管理查重字段
    $arr['productnotexistsmethod_label']=getFixedLabel('howtodowhentheproductsisnotexists');//设置产品管理不存在时导入方式
    $detailmodule='Products';
    $detailfocus=CRMEntity::getInstance($detailmodule);
    //$secondaction='ImportSecondDetail';
    $detailfields=$detailfocus->fieldobj->getModuleFields();
    $detailblocks=$detailfocus->fieldobj->getBlockVisibleInfos();
    $smarty->assign("DETAILFIELDS",$detailfields);
    $smarty->assign("DETAILBLOCKS",$detailblocks);
    
}
else if($frommodule=='Accounts'&&$frommodule!='ServiceCharge'){
    
    $arr['detaildupcheckmethod']=getFixedLabel('NOTNEEDTOIMPORTCONTACTS'); //设置联系人查重字段
    $detailmodule='Contacts';
    $detailfocus=CRMEntity::getInstance($detailmodule);
    $detailfields=$detailfocus->fieldobj->getModuleFields();
    $detailblocks=$detailfocus->fieldobj->getBlockInfos();
    $smarty->assign("DETAILFIELDS",$detailfields);
    
}
if($detailmodule!='')
{
    $fileblockdel='yes';
    
    $tmpdetailblocks=array();
    foreach($detailfields as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getUIType()==69 ||$fieldinfo->getUIType()==1109 ||$fieldinfo->getUIType()==28)
        {
            $fileattachblockid=$fieldinfo->getBlockId();
        }
        else 
        {
            $tmpdetailblocks[]=$fieldinfo->getBlockId();
            if(in_array($fileattachblockid,$tmpdetailblocks))
            {
                $fileblockdel='no';
                
               break;
            }
        }
    }
    $tmpdetailblocks=array();
    foreach($detailblocks as $blockid=>$blockinfo)
    {
        if($fileblockdel=='yes'&&$blockid==$fileattachblockid)
        {
            continue;
        }
        if($blockinfo['label']=='LBL_LABEL')
        {
            continue;
        }
        if(array_key_exists($blockid,$detailfocus->fieldobj->presencefield_blockids))
        {
            $tmpdetailblocks[$blockid]=$blockinfo;
        }

    }
    $detailblocks=$tmpdetailblocks;
    $smarty->assign("DETAILBLOCKS",$detailblocks);
}

for($i=0;$i<$adb->num_rows($result);$i++)
{
        $columns=$adb->query_result($result,$i,'columns');
        $condition=$adb->query_result($result,$i,'conditions');
        $explode_cols=explode(':',$columns);
        if(!empty($detailmodule)&&array_key_exists($explode_cols[0],$detailfocus->tab_name_index))
        {
            $mutli_detail_importcheckdupfields[$columns]=array('columns'=>$explode_cols[1],'condition'=>$condition);
        }
        else
            $mutli_importcheckdupfields[$columns]=array('columns'=>$columns,'condition'=>$condition);
}  


if($adb->num_rows($result)<=0)
{
   
       
        $mutli_importcheckdupfields=array('columns'=>'');
        $mutli_detail_importcheckdupfields=array('columns'=>'');
}
if($frommodule=='Users')
{
    $mutli_importcheckdupfields=array();
    $mutli_importcheckdupfields['user_name']=array('columns'=>'user_name','condition'=>'');
}

$checkPicklist=getUsersettingByLabel($frommodule, $current_user->id,'ImportCheckPicklist');
if(empty($checkPicklist)){
    $checkPicklist='no';
}
$smarty->assign('checkPicklist',$checkPicklist);
$checkWorkflow=getUsersettingByLabel($frommodule, $current_user->id,'ImportCheckWorkflow');
$smarty->assign('checkWorkflow',$checkWorkflow);
$smarty->assign('NOIMPORTLABEL',getFixedLabel("NOIMPORT"));
$smarty->assign("IMPORTCHECKDUPFIELDS",$mutli_importcheckdupfields);
$smarty->assign("DETAILIMPORTCHECKDUPFIELDS",$mutli_detail_importcheckdupfields);
$smarty->assign("MODULE",$frommodule);
$smarty->assign("STEPINDEX",1);
$smarty->assign("ARRLABEL",$arr);
$smarty->assign("DETAILMODULE",$detailmodule);

$tmp['content']=$smarty->fetch("ImportXlsNew/FirstImport.tpl");
$tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
$tmp['oktext']=getFixedLabel("NEXT");
$tmp['blocks']=$blocks;
$tmp['fields']=$fields;
$tmp['detailfields']=$detailfields;
$tmp['detailblocks']=$detailblocks;
$tmp['detailmodule']=$detailmodule;

$tmp['nonelabel']=getFixedLabel('CAMCARDNONE');
$tmp['andlabel']=getFixedLabel("SEARCHAND");
$tmp['orlabel']=getFixedLabel('OR');
$tmp['deletelabel']=getFixedLabel("DELETE");
$tmp['noimport']=getFixedLabel('NOIMPORT');

//获取帮助手册入口链接，为空则不显示
//可能有多个帮助链接需要获取
$helpHtmlArr = array();
//导入帮助
$labels = array('Import');
foreach($labels as $label){
    $helpHtmlArr[$label] = getHelpHtmlByLabel('Settings',1,'HelpUrl_'.$label);
}
if (!empty($helpHtmlArr['Import'])){
    $tmp['helperhtml'] = '<div class="ld-btn-icontext-items lfloat">'.$helpHtmlArr['Import'].'</div>';
}

$_REQUEST['diony']='yes';
$maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];

if($maxrows>0)
{
    ConvertTojsonString("2",$tmp,'正在导入该模块数据，你确定要重新导入吗？');
}
else
ConvertTojsonString(1,$tmp,"success");
    
?>