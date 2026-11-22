<?php
//选择单据带出信息
/**
 * User: xiaoguang
 * Date: 2017/01/12
 */
//zkt 20231024 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
 //edit:can 20211018 48301: （kfbcrm）（客户问题）自定义表单15，新建单据，选择合同订单源单后界面一直转圈
 crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
global $adb, $current_user, $recurve_effect_value_ids;
$frommodule = $_REQUEST['frommodule'];
$selectmodule = $_REQUEST['selectmodule'];//Accounts、Vendor
$id = $_REQUEST['id'];
$curcolumn = $_REQUEST['curcolumn'];
//editor:gyq_146 reason:选择单据、关联创建带出信息改进  2019/9/24 15:06
//editor:gyq_20191021 reason:选择单据后，要将当前选中的值赋作$otherlist的初值  2019/10/21 11:04
//0038299: 手机端新建服务合同,选择客户"安康味自在酒店管理有限公司",自动带出联系人"夏照梅",选择该客户的其他联系人,还是带出的"夏照梅".
$otherlist = array();
if(!empty($id)&&!empty($selectmodule)){
    $selectfocus = CRMEntity::getInstance($selectmodule);
    $selectfocus->id = $id;
    $selectfocus->retrieve_entity_info($id, $selectmodule);
    $selectfocus_name = $selectfocus->column_fields[$selectfocus->list_link_field];
    $ids=explode(',',$id);
    $hrefs=array();
    //edit:can 2020-09-04 华夏国酒有个问题，手机端创建销售发票 选择同一个客户下面的2个订单同时开票 下面明细是对的 关联源单只显示一个呢。电脑端没问题 手机端有问题
    foreach($ids as $tmpid)
    {
        if(empty($tmpid))
        {
            continue;
        }
       $hrefs[]= getModuleHref($selectmodule,$tmpid);
    }
    $otherlist = array($curcolumn=>array('id'=>$id,'type'=>0,'value'=>implode(",",$hrefs)));
}
crm_load_class_file('cls_ParentRelatedField_Data', 'include/RelatedField');
$fieldobj = Field::getInstance($frommodule, $adb);
//选择源单暂不走该方法
if ($curcolumn != 'selectlistval') {
    
    recurve_effect_values($otherlist, $frommodule, $id, $fieldobj);
}
//**************旧代码******************
if ($frommodule == 'HelpDesk' && $selectmodule == 'Faq') {
    if (!empty($id)) {
        $query = 'select question,answer,faq_no from ld_faq where id in (' . $id . ')';
        $result = $adb->pquery($query, array());
        $num_rows = $adb->num_rows($result);
        $x = 1;
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $question = $adb->query_result($result, $i, 'question');
                $answer = $adb->query_result($result, $i, 'answer');
                $faq_no[] = $adb->query_result($result, $i, 'faq_no');
                $question_arr[$i] = $x . '. ' . $question;
                $answer_arr[$i] = $x . '. ' . $answer;
                $x++;
            }
            $content['base']['question'] = implode("\r\n", $question_arr);
            $content['base']['answer'] = implode("\r\n", $answer_arr);
            $content['base']['faqno'] = implode(",", $faq_no);
        }
    }
    ConvertTojsonString(1, $content, '');
}


$In_Modules = array('PurchaseOrder', 'SendCashBill', 'VendorContactRecords', 'PurchaseBack', 'PurchaseInvoice', 'PurchaseCashBack', 'Stock');

$productvalues = array();

//产品分录  合同订单，销售机会X，报价单,服务合同，出库单，采购订单*
//源单分录  费用报销单，佣金单，收款单
//editor:gyq170616 reason:微信端含产品分录的模块，暂未发现需要带出源单分录的情况
//editor:gyq_20190923
//0038140: 企业微信，合同订单新增界面，选择销售机会，没有带出分录
$productEntry = array('SalesOrder', 'Quotes', 'ServiceContracts', 'OutboundOrder', 'PurchaseOrder',
    'Invoice', 'Stock', 'PurchaseInvoice', 'PurchaseInquiryOrder');
//editor:gyq_20190923 reason:销售机会增加产品分录受系统参数控制
if ($selectmodule == 'Potentials') {
    $deploy_value = getSys_deploy('205');
    $value = $deploy_value['deploy_value'];
    if ($value == 0) {
        $productEntry[] = 'Potentials';
    }
}
//in_array($selectmodule, $productEntry) &&
//edit:can 2020-09-08 42551: （http://39.99.235.13/crm [^]）（苏州优乐蜂环保科技有限公司客户问题）企业微信>灵当CRM>清运申请模块新建界面>关联选择“月报管理”：选择后产品信息没有自动带出来，PC端是正常的。 
//月报管理:自定义表单17

$actionname = '';
if($_REQUEST['recordid'] && $_REQUEST['recordid'] > 0){
    $actionname = 'EditView';
}else{
    $actionname = 'CreateView';
}

if ((get_file_address($selectmodule,"ProductDetails")&& get_file_address($frommodule,"ProductDetails"))||($frommodule=='CashBill'||$frommodule=='SendCashBill')) {
    crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX', 'WeiXinApp/include/ProductDetailsHtml');
    crm_load_class_file('cls_OptionModuleWX','WeiXinApp/include/OptionModule');
    $optiontobj= cls_OptionModuleWX::getInstance($frommodule,0);
    $moduleoption_arr=$optiontobj->getSourceModule($frommodule);
    
    $withdetail='yes';//是否带出分录，yes:带出分录
    $unallowrepeat = '';
    foreach($moduleoption_arr as $moduleoptioninfo)
    {
        if($moduleoptioninfo['entitytype']==$selectmodule)
        {
            $withdetail=$moduleoptioninfo['withdetail'];
            $unallowrepeat=$moduleoptioninfo['unallowrepeat'];
            break;
        }
    }
  
    if($withdetail=='no')
    {
        if($frommodule == 'CashBill'){
            crm_load_class_file('cls_CashBillDetail_PageRecordValueMC', 'appCommon/modules/CashBill/EntityData');
            $productdetailObj = new cls_CashBillDetail_PageRecordValueMC($frommodule, 'sourcemodule_create_nodetail', $id, $selectmodule);
        }
        else if($frommodule == 'SendCashBill'){
            crm_load_class_file('cls_SendCashBillDetail_PageRecordValueMC', 'appCommon/modules/SendCashBill/EntityData');
            $productdetailObj = new cls_SendCashBillDetail_PageRecordValueMC($frommodule, 'sourcemodule_create_nodetail', $id, $selectmodule);
        }
        else{
            $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX($frommodule, 'sourcemodule_create_nodetail', $id, $selectmodule,$actionname);
        }
    }
    else
    {
        if($frommodule == 'WorkSheet'){
            crm_load_class_file('cls_WorkSheet_PageRecordValueWX', 'WeiXinApp/modules/WorkSheet/cls_WorkSheet');
            $productdetailObj = new cls_WorkSheet_PageRecordValueWX($frommodule, 'module_create', $id, $selectmodule,$actionname);
            $productdetailObj->producttype = 'product';
        }else{
            //zkt 20230925 BUG0073226 贺桃送货单选择源单服务卡，电脑端可以不带出饮水机类别，手机端不可以
            //选择源单时mode应该为sourcemodule_create，先修改看是否有问题。
            $tmppagemode = 'module_create';
            if($curcolumn == 'selectlistval'){
                $tmppagemode = 'sourcemodule_create';
            }
            crm_load_class_file('cls_ChooseEntityDetailhtml', 'WeiXinApp/include/ProductDetailsHtml');
            $productdetailObj = new cls_ChooseEntityDetailhtml($frommodule, $tmppagemode, $id, $selectmodule,$actionname);
        }
        if ($unallowrepeat == 'yes'){
            $productdetailObj->setUnallowRepeat($unallowrepeat);
            $selectDetailLineitemid = $_REQUEST['selectDetailLineitemid'];
            $productdetailObj->setSelectDetailLineitemid($selectDetailLineitemid);
        }
    }
    

    $productvalues = $productdetailObj->set_entrydetail('EditView', null, null);

    if($frommodule == 'CashBill'||$frommodule == 'SendCashBill'){
        $productvalues['entry']['productdetail'] = $withdetail;
    }
    
    //duan 20230201 根据pc端代码逻辑(EditView.php 中有传DEPLOY_VALUE_205参数到tpl中,选择销售机会就会带出分录)
    //目前只有（销售合同、服务合同、销售发票、报价单）这四个模块选择了销售机会单据后可以带出分录，后续根据需要再补充
    if($selectmodule == 'Potentials'){
        $potentials_entrymodule_arr = array('Invoice','Quotes','SalesOrder','ServiceContracts');
        if(!in_array($frommodule,$potentials_entrymodule_arr)){
            $productvalues = array();
        }
    }
    
   $_REQUEST['relatedtype'] = 'trigger';

$selectfocus=CRMEntity::getInstance($selectmodule);

$fromfocus=CRMEntity::getInstance($frommodule);
$sysarr=getSys_deploy(93);

  crm_load_class_file('cls_RelatedEntryField_Data','include/RelatedField');

  foreach($productvalues['entry']['list'] as $tmpindex=> &$tmpinfo )
  {
        $lineitem_id=$tmpinfo['lineitem_id']['hiddenvalue'];
        if(empty($lineitem_id))
            continue;
        
        if(!$selectfocus->detailfieldobj->getFieldInfoobjBykey("columnname",'listprice')&&$fromfocus->detailfieldobj->getFieldInfoobjBykey("columnname",'listprice'))
        {
           //原单listprice  ，当前单据没有隐藏
           // $tmpinfo['listprice']=$tmpinfo['taxprice'];
           if(array_key_exists('taxprice',$tmpinfo))
           {
            $tmpinfo['listprice']=$tmpinfo['taxprice'];
           }
           else{
                $sql='select unit_price from ld_products  where productid=?';
               $tmpresult=$adb->pquery($sql,array($tmpinfo['productname']['hiddenvalue']));
              //  file_put_contents(globalStatic::$root_directory.'WeiXinApp/modules/Users/bb.txt',$lineitem_id);
                $tmpinfo['listprice']['hiddenvalue']=number_format($adb->query_result($tmpresult,0,0),$sysarr['deploy_value'],".","");
                $tmpinfo['listprice']['value']=$tmpinfo['listprice']['hiddenvalue'];
                
           }
            
        }
        $cls_RelatedEntryField_Dataobj = new cls_RelatedEntryField_Data($frommodule,'entitytypeid');
       
         
        $cls_RelatedEntryField_Dataobj->setLinitemID($lineitem_id);
        $cls_RelatedEntryField_Dataobj->param = array('entitytypeid'=>$tmpinfo['entitytypeid']['hiddenvalue']);
        $cls_RelatedEntryField_Dataobj->setEntityType($tmpinfo['entitytype']['hiddenvalue']);
        
        $relatedfielddata= $cls_RelatedEntryField_Dataobj->getData();
        $relatedfielddata_cash = $relatedfielddata;
        $relatedfielddata=$relatedfielddata[0];
        $relatevalue_arr=[];
       if(!empty($relatedfielddata))
       {
           foreach($relatedfielddata as $tmpfieldindex=>$tmpvalueinfo_arr )
           {
               foreach($tmpvalueinfo_arr['value'] as $curmodule_columninfo=> $tmpvalue)
               {
                   $relatevalue_arr[$curmodule_columninfo]=$tmpvalue;
                   if($tmpvalueinfo_arr['bigtype'] == 'image' || $tmpvalueinfo_arr['bigtype'] == 'fileattachment'){
                       $attr_info = [];
                       if(count($tmpvalue) > 0){
                           $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                           for($j=0;$j<count($tmpvalue);$j++){
                               $tmp_info = [];
                               $tmp_info['filename'] = $tmpvalue[$j]['file_name'];
                               $tmp_info['filesize'] = $tmpvalue[$j]['file_size'];
                               $tmp_info['filetype'] = $tmpvalue[$j]['file_type'];
                               $tmp_info['filepath'] = $cls_MyCRMcrypt->decode($tmpvalue[$j]['file_path']);
                               $tmp_info['newfile_name'] = $cls_MyCRMcrypt->decode($tmpvalue[$j]['newfile_name']);
                               $tmp_info['cloud_path'] = $cls_MyCRMcrypt->decode($tmpvalue[$j]['cloud_path']);
                               $tmp_info['id'] = $tmpvalue[$j]['fileid'];
                               $tmp_info['storage_location'] = $tmpvalue[$j]['storage_location'];
                               $tmp_info['upload_from'] = $tmpvalue[$j]['upload_from'];
                               $tmp_info['isEncrypt'] = 'no';
                               $attr_info[] = $tmp_info;
                           }

                       }
                       $tmpinfo[$curmodule_columninfo]['value'] = $attr_info;
                       $tmpinfo[$curmodule_columninfo]['hiddenvalue'] = $attr_info;
                   }else{
                       $tmpinfo[$curmodule_columninfo]['value']=$tmpvalue;
                       $tmpinfo[$curmodule_columninfo]['hiddenvalue']=$tmpvalueinfo_arr['rawvalue'][$curmodule_columninfo];
                   }
               }
           }
           $productvalues['entry']['list'][$tmpindex]=$tmpinfo;
       }
       //zkt 20230217 BUG0061644移动端收款单，选择源单产品为多个时，产品明细的“本次收款金额”字段数值显示的是整个源单的合计收款金额（应该是单据明细这一个产品的金额），实际收款金额计算错误（邱：本次收款金额后台返回值不对）
       if($withdetail == 'yes' &&($frommodule == 'CashBill' || $frommodule == 'SendCashBill'))
       {
            $sourefocus = CRMEntity::getInstance($_REQUEST['selectmodule']);
            $sourefocus->lineitemIds = $lineitem_id;
            
            $productFieldValue = $productvalues['entry']['list'][$tmpindex];
            $tmpproductinfo['entitytypeid'] = $productFieldValue['selectSourceModuleid'];
            $tmpproductinfo['productid'] = $productFieldValue['productid'];
            $tmpproductinfo['parent_lineitem_id'] = $productFieldValue['lineitem_id'];
            $ProductDetailsData = $productdetailObj->ProductDetailsData;
            $presenceToolField = $productdetailObj->ProductDetailsData->presenceToolField;
            $productfieldata = $ProductDetailsData->getProductToolFieldValue($sourefocus, 'popup_selectsource');//获取字段在DB中的值

            foreach ($presenceToolField as $columnname => $field) {
                if (in_array($columnname, array('entitytypeid', 'entitytype','adjustment'))) continue;
                $autobalancevalue='';
                $autobalancevalue = $ProductDetailsData->getAutoBlanceColumn($_REQUEST['selectmodule'],$field);

                if($autobalancevalue!='')
                {
                    $sourefocus->id=$productFieldValue['selectSourceModuleid']['value'];
                    $tmp_lineitembalancevalue_arr= $ProductDetailsData->getSourceModuleBalanceValue($sourefocus,$autobalancevalue);
                    $tmp_value = $tmp_lineitembalancevalue_arr[$tmpproductinfo['parent_lineitem_id']['value']];
                    $productFieldValue[$columnname]['value'] =$tmp_value;
                    $productFieldValue[$columnname]['hiddenvalue'] =$tmp_value;
                    $productfieldata[0][$columnname]=$tmp_value;
                }
                if($field->getBigType() == 'image' || $field->getBigType() == 'fileattachment'){
                    if(!empty($relatedfielddata_cash)){
                        foreach($relatedfielddata_cash as $relatedinfos){
                            foreach($relatedinfos as $infos){
                                if($infos['value']){
                                    foreach($infos['value'] as $columnname_related => $value){
                                        if($columnname_related == $columnname && ($infos['bigtype'] == 'image' || $infos['bigtype'] == 'fileattachment')){
                                            $attr_info = [];
                                            if(count($value) > 0){
                                                $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                                                for($j=0;$j<count($value);$j++){
                                                    $tmp_info = [];
                                                    $tmp_info['filename'] = $value[$j]['file_name'];
                                                    $tmp_info['filesize'] = $value[$j]['file_size'];
                                                    $tmp_info['filetype'] = $value[$j]['file_type'];
                                                    $tmp_info['filepath'] = $cls_MyCRMcrypt->decode($value[$j]['file_path']);
                                                    $tmp_info['newfile_name'] = $cls_MyCRMcrypt->decode($value[$j]['newfile_name']);
                                                    $tmp_info['cloud_path'] = $cls_MyCRMcrypt->decode($value[$j]['cloud_path']);
                                                    $tmp_info['id'] = $value[$j]['fileid'];
                                                    $tmp_info['storage_location'] = $value[$j]['storage_location'];
                                                    $tmp_info['upload_from'] = $value[$j]['upload_from'];
                                                    $tmp_info['isEncrypt'] = 'no';
                                                    $attr_info[] = $tmp_info;
                                                }

                                            }
                                            $productFieldValue[$columnname]['value'] =$attr_info;
                                            $productFieldValue[$columnname]['hiddenvalue'] =$attr_info;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

            }
            $productvalues['entry']['list'][$tmpindex] = $productFieldValue;

       }
       
  }
    
}
//editor:gyq_20190116 0036172: （克莱门特微信小程序问题）新增维修内容，选择热线单后，若热线单关联创建的报损单有产品明细时，应该带出报损单的产品明细，
if ($selectmodule == 'Potentials' && $frommodule == 'OutboundOrder') {
    $account = get_versionaccount();
    if ($account == 'climaveneta') {
        crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX', 'WeiXinApp/include/ProductDetailsHtml');
        $query_climaveneta = 'select quoteid from ld_quotes
		LEFT JOIN ld_quotesdetail on ld_quotesdetail.id = ld_quotes.quoteid 
		where potentialid = ? and deleted <> 1';
        $result_climaveneta = $adb->pquery($query_climaveneta, array($_REQUEST['id']));
        $num_rows_climaveneta = $adb->num_rows($result_climaveneta);
        if ($num_rows_climaveneta > 0) {
            $_REQUEST['climaveneta_OutboundOrder'] = true;
            $quoteid = $adb->query_result($result_climaveneta, 0, 'quoteid');
            $productdetailObj = new cls_ProductDetailUitype_PageRecordValueWX('SalesOrder', 'module_create', $quoteid, 'Quotes','');
            $productvalues = $productdetailObj->set_entrydetail('EditView', null, null);
        }
    }
}

$curcolumn_right = $fieldobj->getFieldInfoBykeyValue('fieldname', $curcolumn, 'columnname');
//editor:gyq_129 reason:选择源单字段改进  2019/7/24 18:12 ID1000529
$field_cell_obj = $fieldobj->getFieldInfoobjBykey('fieldname', $curcolumn);
if ($field_cell_obj && $field_cell_obj->getbigtype() == 'selectsource') {
    $curcolumn_right = '';
}
//选择源单带出字段方法修改 xxs
//$fields = getRelateCreatePostValue($frommodule,$selectmodule,$mobj->focus->column_fields);
$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($frommodule, $id, $curcolumn_right);
$relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
$baselist = array();

foreach ($relatedfielddata as $val) {
    $columnname = $val['columnname'];
    $value = $val['value'];
    $fields[$columnname] = $value;
}
if ($selectmodule == 'Accounts') {
    $baselist['accountid'] = $id;
    $baselist['accountname'] = getModuleHref('Accounts', $id);
}
if ($selectmodule == 'Contacts') {
    $baselist['contactid'] = $id;
    $baselist['lastname'] = getModuleHref('Contacts', $id);
}
if ($selectmodule == 'Vendors') {
    $baselist['vendorid'] = $id;
    $baselist['vendorname'] = getModuleHref('Vendors', $id);
}
if ($selectmodule == 'VendorContact') {
    $baselist['vendorcontactsid'] = $id;
    $baselist['vendorcontacts'] = getModuleHref('VendorContact', $id);
}

foreach ($relatedfielddata as $data) {
    //返回前端值为null报错 date:20180315 xxs
    if (is_null($data['value']['value'])) $data['value']['value'] = '';
    if ($data['rawValue']['input_name'] == 'account_id') {
        $baselist['accountid'] = $data['rawValue']['value'];
        $baselist['accountname'] = $data['value']['value'];
    }
    else if ($data['rawValue']['input_name'] == 'contact_id') {
        if (!in_array($curmodule, $In_Modules)) {
            $baselist['contactid'] = $data['rawValue']['value'];
            $baselist['lastname'] = $data['value']['value'];
        } else {
            $baselist['vendorcontactsid'] = $data['rawValue']['value'];
            $baselist['vendorcontacts'] = $data['value']['value'];
        }
    }
    // else if ($data['rawValue']['input_name'] == 'projectid') {
    //     $baselist['projectid'] = $data['rawValue']['value'];
    //     $baselist['projectname'] = $data['value']['value'];
    // }
    else if ($data['rawValue']['input_name'] == 'assigned_user_id' || $data['rawValue']['input_name'] == 'ServiceContractsassigned_user_id') {
        if (!in_array($curmodule, $In_Modules)) {
            $baselist['smownerid'] = $data['rawValue']['value'];
            $baselist['smowner'] = getUserFullName($data['rawValue']['value']);
        } else {
            $baselist['vsmownerid'] = $data['rawValue']['value'];
            $baselist['vsmowner'] = getUserFullName($data['rawValue']['value']);
        }
    }
    else if ($data['rawValue']['input_name'] == 'vendor_id') {
        $baselist['vendorid'] = $data['rawValue']['value'];
        $baselist['vendorname'] = $data['value']['value'];
    }
    else {
        $columnanme = $data['rawValue']['input_name'];
        $field = $fieldobj->getFieldInfoobjBykey('columnname', $columnanme);
        //editor:gyq_20190115 0036140: （珞落计划企业微信登录）联系人新增界面：选择“客户名称”时，地址信息区块没有覆盖“省份”、“城市”字段
        if (empty($field)) {
            $field = $fieldobj->getFieldInfoobjBykey('fieldname', $columnanme);
        }
        if (!empty($field)) {
            $uitype = $field->getUIType();
            if ($uitype == 53) {// || $uitype == 153 Diony 2020-05-11 153选择后同样更改值
                $otherlist[$data['rawValue']['input_name']] = array(
                    'id' => $data['rawValue']['value'],
                    'value' => $data['value']['value'],
                    'type' => 1,
                );
            } else if($uitype == 56){
                //移动端单选框无法判断汉字，将’否‘改为空
                if (!empty($data['rawValue']['input_name'])) {
                    $value_str = $data['value']['value'];
                    if($data['value']['value'] == '' && $data['rawValue']['value'] != ''){
                        $value_str = $data['rawValue']['value'];
                    }
                    if($value_str == '否' || $value_str == '0'){
                        $value_str = '';
                        $data['rawValue']['value'] = '0';
                    }
                    $otherlist[$data['rawValue']['input_name']] = array(
                        'id' => $data['rawValue']['value'],
                        'value' => $value_str,
                        'type' => 0,
                    );
                }                
            }
            else if ($uitype == 69 || $uitype == 1109){
                if(!empty($data['rawValue']['input_name'])){
                    $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                    $tmp_fileinfoarr = [];
                    $tmp_attaarr = [];
                    if(count($data['rawValue']['value'][$data['rawValue']['input_name']]) > 0){
                        for($i = 0;$i < count($data['rawValue']['value'][$data['rawValue']['input_name']]);$i++){
                            $tmp_fileinfo = $data['rawValue']['value'][$data['rawValue']['input_name']][$i];
                            $new_tmp_fileinfo = [];
                            $new_tmp_fileinfo['path'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['file_path']);
                            $new_tmp_fileinfo['newfile_name'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['newfile_name']);
                            $new_tmp_fileinfo['cloud_path'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['cloud_path']);
                            $new_tmp_fileinfo['id'] = $tmp_fileinfo['fileid'];
                            $new_tmp_fileinfo['storage_location'] = $tmp_fileinfo['storage_location'];
                            $new_tmp_fileinfo['httppath'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['file_path']).$cls_MyCRMcrypt->decode($tmp_fileinfo['newfile_name']);
                            $new_tmp_fileinfo['cloud_path'] = $cls_MyCRMcrypt->decode($tmp_fileinfo['cloud_path']);
                            $new_tmp_fileinfo['name'] = $tmp_fileinfo['file_name'];
                            $new_tmp_fileinfo['type'] = $tmp_fileinfo['file_type'];
                            $new_tmp_fileinfo['size'] = $tmp_fileinfo['file_size'];
                            $new_tmp_fileinfo['imagefromtype'] = $tmp_fileinfo['imagefromtype'];
                            $new_tmp_fileinfo['isEncrypt'] = 'no';
                            $tmp_fileinfoarr[] = $new_tmp_fileinfo;

                            $tmp_attainfo = [];
                            $tmp_attainfo['id'] = $new_tmp_fileinfo['id'];
                            $tmp_attainfo['newfile_name'] = $new_tmp_fileinfo['newfile_name'];
                            $tmp_attainfo['filename'] = $new_tmp_fileinfo['name'];
                            $tmp_attainfo['filetype'] = $new_tmp_fileinfo['type'];
                            $tmp_attainfo['filesize'] = $new_tmp_fileinfo['size'];
                            $tmp_attainfo['filepath'] = $new_tmp_fileinfo['path'];
                            $tmp_attainfo['imagefromtype'] = $new_tmp_fileinfo['imagefromtype'];
                            $tmp_attainfo['storage_location'] = $new_tmp_fileinfo['storage_location'];
                            $tmp_attainfo['cloud_path'] = $new_tmp_fileinfo['cloud_path'];
                            $tmp_attaarr[] = $tmp_attainfo;
                        }
                    }
                    $otherlist[$data['rawValue']['input_name']] = array(
                        'id' => $data['rawValue']['value'],
                        'value' => $tmp_fileinfoarr,
                        'type' => 0,
                        'filedata' => $tmp_attaarr
                    );
                }
            }
            else {
                if (!empty($data['rawValue']['input_name'])) {
                    $value_str = $data['value']['value'];
                    if($data['value']['value'] == '' && $data['rawValue']['value'] != ''){
                        $value_str = $data['rawValue']['value'];
                    }
                    $otherlist[$data['rawValue']['input_name']] = array(
                        'id' => $data['rawValue']['value'],
                        'value' => $value_str,
                        'type' => 0,
                    );
                }
            }

        }
    }
}
if($_REQUEST['selecttype'] != 'special_popupselectfield'){
    $json['base'] = $baselist;
}

$json['other'] = $otherlist;

//2024-4-11 xxy 拜访签到-拜访对象带出拜访地址
if($frommodule == 'Singin' && $field_cell_obj->getColumnName() == 'source_list'){
    crm_load_class_file('cls_SigninRelatedField_Data', 'include/RelatedField');
    $cls_SigninRelatedField = new cls_SigninRelatedField_Data($selectmodule, $id);
    $json['other'] = array_merge($json['other'],$cls_SigninRelatedField->getVisitAddressInfo());
}

// 2021-06-17 diony
// 销售机会产品分录明细不显示时，选择销售机会不带出明细
$get205deploy = getSys_deploy('205');
if($selectmodule == 'Potentials' && $get205deploy['deploy_value']==1){
    $json['multientry'] = [];
}
else{
    $json['multientry'] = $productvalues;
}
//返回结果
ConvertTojsonString(1, $json, '');
//editor:gyq_146 reason:递归获取所有字段的带出信息  2019/9/25 15:50
function recurve_effect_values(&$otherlist, $module, $id, $r_fieldobj)
{
	if($_REQUEST['selecttype'] == 'special_popupselectfield'){	//173  244  245
		$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($module, $id, $_REQUEST['curcolumn']);
	}else if($_REQUEST['selecttype'] == 'popupselectfield' && $_REQUEST['selectmodule'] == 'Users' ){
		$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($module, $id, $_REQUEST['curcolumn']);
	}else{
		$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($module, $id, '');
	}
    $relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');
    //$list_uitype = cls_module_uitype::getUitypeModules();
    $bigtype='';

    foreach ($relatedfielddata as $key => $value) {
        $real_value = $value['rawValue']['value'];
        $fieldname = $value['rawValue']['input_name'];
        if (!array_key_exists($fieldname, $otherlist)) {
            $otherlist[$fieldname] = array(
                'id' => $real_value,
                'type' => 0,
                'value' => $value['value']['value']
            );
            if (is_numeric($real_value) && $real_value > 0 ) {
                $tmpfieldinfo = $r_fieldobj->getFieldInfoobjBykey('fieldname', $fieldname);
                $bitype = $tmpfieldinfo->getBigType();
                if($bigtype == 'selectsource'||$bitype == 'reference'){
                    recurve_effect_values($otherlist, $module, $real_value, $r_fieldobj);
                }
                /*if ($bigtype == 'selectsource') {
                    $sourcemodules = getSourceModule($currentModule);
                } elseif ($bitype == 'reference') {
                    $uitype = $tmpfieldinfo->getUIType();
                    $fieldmodule = $list_uitype[$uitype];
                    if (!empty($fieldmodule)) {
                        recurve_effect_values($otherlist, $fieldmodule, $real_value);
                    }
                }*/
            }

        }
    }
}
?>