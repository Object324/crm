<?php
//editor:gyq_162 reason:海格产品分录导入   2019/12/5 15:18
global $adb;
global $currentModule;
global $current_user;
$_REQUEST['diony'] = true;

$frommodule = $_REQUEST['frommodule'];
$focus = CRMEntity::getInstance($frommodule);
$arr['modulelabel'] = gettranstab($frommodule);
$arr['dupfieldlabel'] = getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel'] = getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel'] = getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel'] = getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel'] = getFixedLabel('TEMPLATECOMPLETE');//完成
$arr['accordingimportdatalabel'] = getFixedLabel('ACCORDINGTEMPLATEIMPORTDATA');//请按照数据模板的格式准备要导入的数据。
$arr['downloadtemplatedatalabel'] = getFixedLabel('DOWNTEMPLATEDATA');//下载模板数据
$arr['viewcareitemlabel'] = getFixedLabel('VIEWCAREITEM');//查看注意事项
$arr['notelabel'] = getFixedLabel('NOTE');//注意事项
$arr['notencontent_firstlabel'] = getFixedLabel('STOPDELETEIMPORTTEMPLATEHEAD'); //模板中的表头名称不可更改，表头行不能删除
$arr['notencontent_secondlabel'] = getFixedLabel('MAYADJUSTORDERIMPORT');//项目顺序可以调整，不需要的项目可以删减
$arr['notencontent_thirdlabel'] = getFixedLabel('REDREPRESENTNOTEMPTY'); //红色*表示为必录项，必须保留并且不能为空

$arr['dup_setdupfields_label'] = getFixedLabel("IMPORT_PLEASESETDUMPLICATEFIELDS") . $arr['modulelabel'] . getFixedLabel('CHECKIMPORTFIELD');//请设置模块查重字段
$arr['dup_importmethod_label'] = getFixedLabel("IMPORT_PLEASESETIMPORTMODE") . $arr['modulelabel'] . getFixedLabel('REPEAT_IMPORT_MODE');//请设置重复导入方式


$smarty = new lingdangCRM_Smarty();
$fields = $focus->fieldobj->getModuleFields();
$blocks = $focus->fieldobj->getBlockVisibleInfos();
//$tmpblocks=$blocks;
$tmpblockids = array();
$fileblockdel = 'yes';


foreach ($fields as $fieldname => $fieldinfo) {
    if ($fieldinfo->getUIType() == 64 || $fieldinfo->getUIType() == 65) {
        continue;
    }
    $tablename = $fieldinfo->getTableName();

    if ($currentModule == "ServiceCharge" && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf'))
        continue;
    $tmpfields[] = $fieldinfo;
}

$fields = $tmpfields;

foreach ($fields as $fieldname => $fieldinfo) {

    if ($fieldinfo->getUIType() == 69 || $fieldinfo->getUIType() == 1109 || $fieldinfo->getUIType() == 28) {
        $fileattachblockid = $fieldinfo->getBlockId();
    } else {
        $tmpblockids[] = $fieldinfo->getBlockId();
        if (in_array($fileattachblockid, $tmpblockids)) {
            $fileblockdel = 'no';

            break;
        }
    }
}
foreach ($blocks as $blockid => $blockinfo) {
    if ($fileblockdel == 'yes' && $blockid == $fileattachblockid) {
        continue;
    }
    if (array_key_exists($blockid, $focus->fieldobj->presencefield_blockids)) {
        $tmpblocks[$blockid] = $blockinfo;
    }
}
if ($currentModule == 'Accounts' || $currentModule == "ServiceCharge") {

    foreach ($tmpblocks as $blockid => $blockinfo) {
        if ($blockinfo['label'] == 'LBL_ACCOUNT_PRIMARYCONTACT' || $blockinfo['label'] == 'LBL_PUBLICACCOUNT_LOG') {
            continue;
        }
        $tmpblocks[$blockid] = $blockinfo;
    }
}

$blocks = $tmpblocks;

$smarty->assign("FIELDS", $fields);
$smarty->assign("BLOCKS", $blocks);
$detailmodule = '';

if (get_file_address($frommodule, "ProductDetails") && $frommodule != 'ServiceCharge') {
    $detailmodule = 'Products';
    $detailfocus = CRMEntity::getInstance($detailmodule);
    //$secondaction='ImportSecondDetail';
    $detailfields = $detailfocus->fieldobj->getModuleFields();
	foreach($detailfields as $fieldname => $fieldinfo){
		if ($fieldinfo->getUIType() == 301) {
			unset($detailfields[$fieldname]);
		}
	}
    $detailblocks = $detailfocus->fieldobj->getBlockVisibleInfos();
	foreach($detailblocks as $blockid => $blockinfo){
		if($blockinfo['label'] == 'LBL_LABEL'){
			unset($detailblocks[$blockid]);
		}
	}
    $smarty->assign("DETAILFIELDS", $detailfields);
    $smarty->assign("DETAILBLOCKS", $detailblocks);
}
//wym 240424 BUG20240402-67 收款单选择带产品分录的源单类型“销售订单”，导入明细界面第二步和第三步骤显示异常
$arr['detaildupcheckmethod'] = getFixedLabel("IMPORT_PLEASESETDUMPLICATEFIELDS") . getTranstab("Products") . getFixedLabel('CHECKIMPORTFIELD');//设置产品管理查重字段
$arr['productnotexistsmethod_label'] = getFixedLabel('howtodowhentheproductsisnotexists');//设置产品管理不存在时导入方式
if ($detailmodule != '') {
    $fileblockdel = 'yes';

    $tmpdetailblocks = array();
    foreach ($detailfields as $fieldname => $fieldinfo) {
        if ($fieldinfo->getUIType() == 69 || $fieldinfo->getUIType() == 1109 || $fieldinfo->getUIType() == 28) {
            $fileattachblockid = $fieldinfo->getBlockId();
        } else {
            $tmpdetailblocks[] = $fieldinfo->getBlockId();
            if (in_array($fileattachblockid, $tmpdetailblocks)) {
                $fileblockdel = 'no';

                break;
            }
        }
    }
    $tmpdetailblocks = array();
    foreach ($detailblocks as $blockid => $blockinfo) {
        if ($fileblockdel == 'yes' && $blockid == $fileattachblockid) {
            continue;
        }
        if (array_key_exists($blockid, $detailfocus->fieldobj->presencefield_blockids)) {
            $tmpdetailblocks[$blockid] = $blockinfo;
        }
    }
    $detailblocks = $tmpdetailblocks;
    $smarty->assign("DETAILBLOCKS", $detailblocks);
}
$mutli_detail_importcheckdupfields[0] = array('columns' => 'productcode', 'condition' => 'or');

$smarty->assign('NOIMPORTLABEL', getFixedLabel("NOIMPORT"));
$smarty->assign("DETAILIMPORTCHECKDUPFIELDS", $mutli_detail_importcheckdupfields);
$smarty->assign("MODULE", $frommodule);
$versiontrade = getVersionTradeInfo();//上海晴明  shqingming
$smarty->assign("VersionTrade", $versiontrade['account']);
$smarty->assign("STEPINDEX", 1);
$smarty->assign("ARRLABEL", $arr);
$smarty->assign("DETAILMODULE", $detailmodule);
$smarty->assign('IS_ADMIN',is_admin($current_user));


$checkPicklist=getUsersettingByLabel($frommodule, $current_user->id,'ImportDetailCheckPicklist');
if(empty($checkPicklist)){
    $checkPicklist='no';
}
$smarty->assign('checkPicklist',$checkPicklist);
$tmp['content'] = $smarty->fetch("ImportXlsNew/documentEntry/FirstImport.tpl");
$tmp['title'] = getFixedLabel("IMPORTENTRY");
$tmp['oktext'] = getFixedLabel("NEXT");
$tmp['blocks'] = $blocks;
$tmp['fields'] = $fields;
$tmp['detailfields'] = $detailfields;
$tmp['detailblocks'] = $detailblocks;
$tmp['detailmodule'] = $detailmodule;

$tmp['nonelabel'] = getFixedLabel('CAMCARDNONE');
$tmp['andlabel'] = getFixedLabel("SEARCHAND");
$tmp['orlabel'] = getFixedLabel('OR');
$tmp['deletelabel'] = getFixedLabel("DELETE");
$tmp['noimport'] = getFixedLabel('NOIMPORT');

$_REQUEST['diony'] = 'yes';
$maxrows = $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_maxrows'];

if ($maxrows > 0) {
    ConvertTojsonString("2", $tmp, '正在导入该模块数据，你确定要重新导入吗？');
} else
    ConvertTojsonString(1, $tmp, "success");

?>