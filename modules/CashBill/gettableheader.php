<?php
crm_load_class_file('cls_CashBill_EntityHtml','modules/CashBill/EntityData');
ob_clean();
global $currentModule;
$obj_entity=new cls_CashBill_EntityHtml('0',"",$_REQUEST['sourcemodule']);
$withProductdetail  = $obj_entity->getSourceWithDetail($obj_entity->sourceModule);
if($withProductdetail  == 'yes'){
    $obj_entity->Detailobj->frommdouleFocus = CRMEntity::getInstance($_REQUEST['sourcemodule']);
   
    $obj_entity->Detailobj->productdetail_mode = 'sourcemodule_create';
    $arr['detailfieldmodule']='Products';
    $ProductDetailsHtml = $obj_entity->Detailobj->DetailsHtmlobj;
    $ProductDetailsData = $obj_entity->Detailobj->DetailsDataobj;
    
    $productFields['fields']=$ProductDetailsData->moduleProductToolField;
    $productFields['system_deploy']=$ProductDetailsData->system_deploy_formulas;	//单据分录明细中录入价税合计重算的字段
    $versiontrade=getVersionTradeInfo();
    $productFields['trade']=$versiontrade['trade'];
    $systemmethod = $ProductDetailsData->getSystemMethod();
    $productFields['lengthdecimaldigits'] = $systemmethod['lengthdecimaldigits'];
    $productFields['lengthprice'] = $systemmethod['lengthprice'];
    $productFields['SystemArgument'] = $systemmethod['SystemArgument'];
    $productFields['addproductrow'] = $systemmethod['addproductrow'];
    $arr['productfieldinfo']=$productFields;
   
    $arr['detailfields']=$ProductDetailsHtml->ProductDetailsData->productToolFields->getFieldListArray();
    $arr['detailfieldmodudle']='Products';
    $deploys=getSys_deploy(124);
    $base_column = $deploys['deploy_value'];
    //ls 2022-03-30 设置单据分录明细中产品管理的价格和金额计算时的基准字段  选择的基准字段分录不能隐藏，如果系统参数是不含税单价且不含税单价隐藏，则基准字段改为含税单价
    if ($base_column == 'listprice' && !empty($ProductDetailsHtml->ProductDetailsData->presenceToolField['listprice'])) {
        $base_column = 'listprice';
    }else{
        $base_column = 'taxprice';
    }
    ////edit:can 2020-10-12 产品分录明细：系统参数“价格和金额计算时的基准字段”设置为“不含税单价”，录入“税率”应反算“含税单价”
    $arr['baseColumn']=$base_column;
    crm_load_class_file("cls_strategy",'modules/Products');
    //价格策略
    $cls_strategy=new cls_strategy();
    $arr["productstrategyobj"]=$cls_strategy->getstrategyByProductId($ProductDetailsHtml->ProductDetailsData->strategyproductids);
    
    ////没有价税合计的字段权限
    $ProductToolFields = ProductToolFields::getInstance($currentModule);   
    $user_noprofile_fields = $ProductToolFields->user_noprofile_fields;
    $arr['noprofilefields']=$user_noprofile_fields;
    
    $arr['detailfieldruleinfo']=$ProductDetailsHtml->detailfieldruleobj->getFieldRuleProperty();
    $arr["relatedproducttoolfield"]=getRelatedProducttoolfield($currentModule);
}
else{
    $TabDetailFieldsobj = TabDetailFields::getInstance($currentModule);
    $arr['detailfieldmodule']=$currentModule.'detailhtml';
    $arr['detailfields']=$TabDetailFieldsobj->getFieldListArray();
}
$arr['content']=$obj_entity->createHtml();//收款信息明细html
$focus = CRMEntity::getInstance($currentModule);
$arr['mainfieldformula']=$focus->fieldobj->getFormula();
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("bigtype",'selectsource');
if($fieldinfo&&$fieldinfo->getFieldName()!='')
{
    $arr['sourcemodule']=getSourceModule($currentModule);
}
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,"success");
exit();
?>