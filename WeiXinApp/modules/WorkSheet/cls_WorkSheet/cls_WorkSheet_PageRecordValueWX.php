<?php

crm_load_class_file('cls_ProductDetailUitype_PageRecordValueWX','WeiXinApp/include/ProductDetailsHtml');
class cls_WorkSheet_PageRecordValueWX extends cls_ProductDetailUitype_PageRecordValueWX{
    protected $unallowRepeat = 'no';
    public $producttype = 'part'; 
    public function set_entrydetail($action,$outputProductFieldArr,$relatedCreationInfo)
    {
        global $weixin_user,$adb;
        if($weixin_user->environment_weixin){
            $detailshowtype='all';
        }else{
            $detailshowtype='part';
        }
        
        //$outputProductFieldArr 查看界面显示字段  $relatedCreationInfo 关联创建信息
        $productdetail = $this->getValues();
        
        $fieldids_content_orign = file_get_contents(globalStatic::$root_directory.'user_privileges/Config_SalesOrder_ProductShowFields_Mobile.php');
        if(empty($fieldids_content_orign)){
            $fieldids_content_orign = '{quantity}x{taxprice}';
        }
        $product_name_headers = array();
        $product_fieldinfo = $productdetail['headers'];
        $wareid_default = false;
		$columnname_bigtype = array();
        //editor:gyq_20191025 reason:选择源单及相关创建，仓库赋初值
        foreach ($productdetail['headers'] as $key => $fielddetail) {
            $showfieldslabel[$fielddetail['columnname']] = $fielddetail['fieldlabel'];
            $showfieldsuitype[$fielddetail['columnname']] = $fielddetail['uitype'];
            $product_name_headers[$fielddetail['columnname']] = $fielddetail;
			$columnname_bigtype[$fielddetail['columnname']] = $fielddetail['bigtype'];
            if($fielddetail['columnname']=='wareid'){
                $wareid_default = array('hiddenvalue'=>'','value'=>'');
            }
            /*
            if(!$this->check_productcolumn($fielddetail['columnname'])){
                unset($product_fieldinfo[$key]);
            }*/
            
        }
        //editor:gyq_20190116 0036172: （克莱门特微信小程序问题）新增维修内容，选择热线单后，若热线单关联创建的报损单有产品明细时，应该带出报损单的产品明细，
        if(($_REQUEST['module']=='OutboundOrder'||$_REQUEST['climaveneta_OutboundOrder']) &&get_versionaccount()=='climaveneta'&&($action=='EditView'||$action=='CreateView') ){
            foreach ($productdetail['headers'] as $key => $fielddetail) {
                //if($fielddetail['columnname']=='productname'){
                    $productdetail['headers'][$key]['edit_permission']= 1;
               // }
            }
        }

        $MixproductValues = $productdetail['value'];
        
        $productValues = array();
   
        foreach($MixproductValues as $listnum=>$content) {
            $fieldids_content = $fieldids_content_orign;
            foreach ($content as $columnname => $mixed_fieldvalue) {
                //editor:gyq_20190410 reason:0036816: 企业微信-出库单，分录明细中的仓库显示为仓库ID 仓库option
                if($product_name_headers[$columnname]['uitype']=='60'){
                    $wareid_content = array();
                    foreach ($product_name_headers[$columnname]['option'] as $key=>$value){
                        $wareid_content[$value['value']] = $value['text'];
                    }
                    $product_field_value = $wareid_content[$mixed_fieldvalue['value']];
                }else if($product_name_headers[$columnname]['uitype']=='63'){
                    if(is_array($mixed_fieldvalue)){
                        $product_field_value = str_replace(" |##| ",", ",$mixed_fieldvalue['value']);
                    }else{
                        $product_field_value = str_replace(" |##| ",", ",$mixed_fieldvalue);
                    }
                    
                }else{
                    if(is_array($mixed_fieldvalue)){
                        $product_field_value = $mixed_fieldvalue['value'];
                    }else{
                        $product_field_value = $mixed_fieldvalue;
                    }
                }
				//关联选择单据
				if($columnname_bigtype[$columnname] == 'reference' && !empty($product_field_value)){
					$entitytype = getSalesEntityType($product_field_value);
					$product_field_value = getModuleHref($entitytype,$product_field_value);
				}
                $productValues[$listnum][$columnname] = $product_field_value;
            }
        }
        if($detailshowtype=='part'){
            foreach($productValues as $listnum=>$content){
                $fieldids_content = $fieldids_content_orign;
                foreach($content as $columnname=>$fieldvalue){
                    if($columnname=='imagename'){//图片返回值特殊处理
                        $imagearr = array();
                        foreach($fieldvalue['image_id_array'] as $key=>$value){
                            $imagearr[$key]['imgid'] = $value;
                            $imagearr[$key]['value'] = $fieldvalue['imagepath_array'][$key].$fieldvalue['image_array'][$key];
                        }
                        $productValues[$listnum][$columnname]=$imagearr;
                        continue;
                    }
                    if(strpos($fieldids_content,'{'.$columnname.'}') !== false){
                        $fieldids_content = str_replace('{'.$columnname.'}',$fieldvalue,$fieldids_content);
                    }
                }
                $productValues[$listnum]['productshowfieldslabel'] = $fieldids_content;
                $productValues[$listnum]['sequence_no']= $listnum+1;
            }
        }
        
        if($detailshowtype=='part') $outputProductValues['blocklabel'] = '产品清单';
        if($action=='DetailView') {
            $outputFieldArr = $outputProductFieldArr;
            foreach ($productValues as $listnum => $content) {
                $item=0;
                
                $related_productid = $content['related_productid'];
                if($related_productid>0){
                    $valueinfo = array();
                    $sql = 'select productname,product_no from ld_products where productid = ?';
                    $result = $adb->pquery($sql,array($related_productid));
                    $valueinfo['k'] = getFixedLabel('SOURCEPRONAME');
                    $valueinfo['v'] = $adb->query_result($result,0,'productname');
                    $outputProductValues['list'][$listnum]['list'][] = $valueinfo;
                    $valueinfo['k'] = getFixedLabel('SOURCEPRONO');
                    $valueinfo['v'] = $adb->query_result($result,0,'product_no');
                    $outputProductValues['list'][$listnum]['list'][] = $valueinfo;
                }
                
                foreach ($content as $columnname => $fieldvalue) {
                    if(!$this->check_productcolumn($fieldname)){
                        continue;
                    }
                    $fieldinfo=$this->focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
                   
                    if($detailshowtype=='all'){
                        if(array_key_exists($columnname,$showfieldslabel)&&(!empty($fieldvalue)||$fieldvalue===0||$fieldvalue==='0')){
                            $showitem = array('k'=>$showfieldslabel[$columnname],'v'=>$fieldvalue);
                             if($fieldinfo&&$fieldinfo->getUIType()==56)
                            {
                                //edit:can 2021-03-01 044707: （企业微信移动端-kfbcrm）合同订单-分录详情；分录中有名称为“cs”的复选框，在单据详情页显示1和0
                                if($fieldvalue=='1')
                                {
                                  $showitem=array('k'=>$showfieldslabel[$columnname],'v'=> getFixedLabel("YES"));
                                }
                                else{
                                    $showitem=array('k'=>$showfieldslabel[$columnname],'v'=> getFixedLabel("NO"));
                                }
                            }
                            if($columnname=='productname' && $fieldinfo -> get_ShowHyperlinks() == 'yes'){
                                $showitem['p'] = 'yes';
                            }
                            $showuitype = $showfieldsuitype[$columnname];
                            if(in_array($showuitype,array(2,3,69))) $showitem['u'] = $showuitype;
                            $outputProductValues['list'][$listnum]['list'][] = $showitem;
                        }
                    }else{
                       
                        if($columnname=='detailid'){
                            $outputProductValues['list'][$listnum]['entryid'] = $fieldvalue;
                            $outputProductValues['list'][$listnum]['entrytype'] = $this->entrytype;
                        }elseif($columnname=='sequence_no'){
                            $outputProductValues['list'][$listnum]['sequence_no'] = $fieldvalue;
                        }elseif (in_array($columnname, $outputFieldArr)) {
                            if($columnname=='productsheet'&&empty($fieldvalue)) continue;
                            $item++;
                            if($columnname=='productname'||$columnname=='productshowfieldslabel') $showitem=$fieldvalue;
                            else $showitem = $showfieldslabel[$columnname] . '：' . $fieldvalue;
                            $outputProductValues['list'][$listnum]['list'][] = $showitem;
                        }
                    }
                    if($columnname=='productid'){
                        $outputProductValues['list'][$listnum]['id'] = $fieldvalue;
                    }
                    if($columnname=='productname'){
                        $outputProductValues['list'][$listnum]['lable'] = $showfieldslabel[$columnname];
                    }
                }
            }
        }else{
            
            $editProductValues = array();
            
            foreach($MixproductValues as $listnum=>$content){
                foreach($content as $fieldname=>$value){
                    /*if(!$this->check_productcolumn($fieldname)){
                        continue;
                    }*/
                    if(is_array($value)){
                        if(empty($value['hiddenvalue'])) $value['hiddenvalue']=$value['value'];  
						//关联选择单据
						if($columnname_bigtype[$fieldname] == 'reference' && !empty($value['value'])){
							$entitytype = getSalesEntityType($value['value']);
							$product_field_value = getModuleHref($entitytype,$value['value']);
							$value['value'] = $product_field_value;
							$editProductValues[$listnum][$fieldname] = $value;
						}else{
							$editProductValues[$listnum][$fieldname] = $value;
						}
                        
                    }else{
                        $editProductValues[$listnum][$fieldname] = array('value'=>$value,'hiddenvalue'=>$value);
                    }
                }
                if($this->producttype == 'product'){
                    $editProductValues[$listnum]['detailid'] = array('value'=>$content['detailid'],'hiddenvalue'=>$content['detailid']);
                    $editProductValues[$listnum]['productid'] = array('value'=>$content['productid'],'hiddenvalue'=>$content['productid']);
                }
                if($wareid_default && !isset($editProductValues[$listnum]['wareid'])){
                    $editProductValues[$listnum]['wareid'] = $wareid_default;
                }
            }
            //价格策略 editor:gyq_84 reason:产品增加价格策略 2018/10/25 18:36 
            $pricestrategy_arr = array();
            crm_load_class_file("cls_strategy",'modules/Products');
            $clsstrategyobj=new cls_strategy();
            foreach ($MixproductValues as $key=>$value){
                $pricestrategy_arr[$value['productid']]= $clsstrategyobj->getstrategyByProductId($value['productid']);
            }
            if($this->producttype == 'product'){
                $outputProductValues['worksheetlist'] = $editProductValues;
            }else{
                $outputProductValues['list'] = $editProductValues;
                $outputProductValues['pricestrategy'] = $pricestrategy_arr;
            }
            
            
        }
        $subtotalvalue = array();//QQ目前仅记录数量和价税合计的小计

        foreach($productdetail['subtotalvalue'] as $key=>$val){
            if($key=='quantity' || $key=='subtotal'){
                if($key=='quantity'){
                    $subtotalvalue[$key]['label']='数量合计';
                }else{
                    $subtotalvalue[$key]['label']='金额小计';
                }
                $subtotalvalue[$key]['value']=empty($val)?'0.00':$val;
            }
        }
        $lastRowValue = $this->getLastRow_Value();//QQ整单折扣信息不全      \      编辑时最后一行合计空值

        $lastRowValue_orign = array_merge($subtotalvalue,$lastRowValue);

        if($action=='DetailView') {
            if(!isset($lastRowValue_orign['discount_amount'])||$lastRowValue_orign['discount_amount']['value']=='0.00'){
                unset($lastRowValue_orign['subtotal']);
            }
            $item=0;
            $total = '';
            $lastRowValue_out = array();
            foreach($lastRowValue_orign as $fieldname=>$content){
                if($fieldname=='total'){
                    $content['value'] = number_format($content['value'],2);                    
                    $total = $content;                    
                }else{
                    $lastRowValue_out[$item] = $content;
                    $item++;
                }
            }
            $lastRowValue_out[$item] = $total;
            //$outputProductValues['detailshowtype'] = $detailshowtype;
        }else{
            $lastRowValue_out = $lastRowValue_orign;
        }
        $outputProductValues['p_total'] = $lastRowValue_out;
        $cls_DetailView_CommonFun = crm_load_class_obj('cls_DetailView_CommonFun','WeiXinApp/include');
        $jsonArr['currency']['current']=  $cls_DetailView_CommonFun->getCurrencyMC($this->createfromFocus()->module_name, $this->record,null,$relatedCreationInfo);
        //微信端明细只有一种币种时，不显示币种字段
        if($action=='DetailView'&&$weixin_user->environment_weixin){
            global $adb;
            $Currency=Currency::getInstance($adb);
            $allCurrencies = $Currency->getAllCurrencies();
            if(count($allCurrencies)==1) unset($jsonArr['currency']);
        }
        
        if($action=='EditView'||$action=='CreateView'){
            if($this->producttype == 'product'){
                $outputProductValues['list'] = array();
                $outputProductValues['worksheetlistfield'] = array_values($product_fieldinfo);
            }
            $jsonArr['math']=$this->getSystemForPoint();
            $outputProductValues['listfield'] = $productdetail['headers'];//headers中的字段缺少fieldtype
            $outputProductValues['listformulafield'] = $this->getModuleProductFormulaField();
            $outputProductValues['listformula']['basecolumn'] = $this->getModuleProductBaseColumn();
            $sys = getSys_deploy(140);
            $outputProductValues['listformula']['system_deploy']['systems_deploy_140'] = $sys['deploy_value'];
            $outputProductValues['nopresencefield'] = $this->getNoPresenceFieldFormula();
            $jsonArr['currency']['allcurrencies'] = $cls_DetailView_CommonFun->getCurrencyMC(null,null,'all',null);
            $jsonArr['buttonname']['adddetailbutton'] = getFixedLabel('NEWPRODUCTS');
            $jsonArr['buttonname']['allremarks'] = getFixedLabel('TOTAL');
            if($this->module=='QuotesChange'&&$action=='EditView'){
                $outputProductValues['change_type'] = $this->change_type;
            }
        }
        //$productbatchstatuslist;//产品是否开启批次管理列表
        $outputProductValues['productbatchstatuslist']=$productdetail['productbatchstatuslist'];
        
        crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
        $this->detailfieldruleobj=cls_detailfieldrule::getInstance($this->module);
        $fieldrulecolsproperty= $this->detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        
        $outputProductValues['detailfieldruleinfo']=$this->detailfieldruleobj->getFieldRuleProperty();
        $detailfieldrulecolumn=$this->detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
        $outputProductValues['detailfieldrulefieldnames']=$detailfieldrulecolumn;
        $jsonArr['entry'] = $outputProductValues;
        
        $jsonArr =  $this->getSpecialDetail($jsonArr,$action);
        
        return $jsonArr;
    }
    //工单管理增加报修产品分录
    public function getSpecialDetail($entry,$action){
        global $adb;
        if($action=='DetailView') {
            $module = $this->module;
            $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$module/ProductDetails",array($this->module));
            crm_load_class_file("Detail_Edit_View",'include/utils');
            if($this->record >0){
                $entitytype = Detail_Edit_View::getInventoryField('entitytype',$this->record );
                if(!empty($entitytype)){
                    $sourcemodule_ProductDetailsHtml = $ProductDetailsHtml->getDetailobjbyEntitytypeMobile($entitytype);
                    $sourcemodule_ProductDetailsHtml->record = $this->record;
                    $sourcemodule_ProductDetailsHtml->ProductDetailsData->record = $this->record;
                    //$detail_list = $sourcemodule_ProductDetailsHtml->getMobiledetail_detailview();
                    $entry['entry']['worksheetlist'] = $detail_list;
                }
            }
        }else{
            $module = $this->module;
            $ProductDetailsHtml = crm_load_class_obj('cls_productDetailsHtml',"modules/$module/ProductDetails",array($this->module));
            crm_load_class_file("Detail_Edit_View",'include/utils');
            if($this->record >0){
                $entitytype = '';
                if (!empty($this->from_module)){
                    $frommodule_focus = CRMEntity::getInstance($this->from_module);
                    $entitytype = $frommodule_focus->getMainColumnFieldValue($this->record,'entitytype');
                }
                if(!empty($entitytype)){
                    $sourcemodule_ProductDetailsHtml = $ProductDetailsHtml->getDetailobjbyEntitytypeMobile($entitytype);
                    $sourcemodule_ProductDetailsHtml->record = $this->record;
                    $sourcemodule_ProductDetailsHtml->ProductDetailsData->record = $this->record; 
                    $detail_list = $sourcemodule_ProductDetailsHtml->getMobiledetail_editview($action);

                }else{
                    $sourcemodule_ProductDetailsHtml = $ProductDetailsHtml->getDetailobjbyEntitytypeMobile($this->from_module);//新建时用from_module
                    $detail_list = $sourcemodule_ProductDetailsHtml->getMobiledetail_editview($action);
                }
                $entry['entry']['worksheetlist'] = $detail_list['worksheetlist'];           
                $entry['entry']['worksheetlistfield'] = $detail_list['worksheetlistfield'];

            }else{
                $entry['entry']['worksheetlist'] = array();
                $entry['entry']['worksheetlistfield'] = array();
            }
        }
        return $entry;
    }

    //判断该字段是否显示
    public function check_productcolumn($columnname){
        if($this->from_module == 'SalesOrder'){
            $product_columnname_arr = array('productname','product_no','productsheet','entitytype','entitytypeid');
        }else{
            $product_columnname_arr = array('productname','product_no','productsheet','entitytype','entitytypeid','servicecontracts_start_date','servicecontracts_end_date');
        }
        $notpart_columnname_arr = array('servicecontracts_start_date','servicecontracts_end_date','entitytype','entitytypeid');
        
        if($this->producttype == 'part'){
            return true;
            if(!in_array($columnname,$notpart_columnname_arr)){
                return true;
            }
        }else{
            if(in_array($columnname,$product_columnname_arr)){
                return true;
            }
        }
        return false;
    }

    public function setUnallowRepeat($unallowRepeat){
        $this->unallowRepeat = $unallowRepeat;
    }
    public function getUnallowRepeat(){
        return $this->unallowRepeat;
    }
    public function setSelectDetailLineitemid($selectDetailLineitemid){
        $this->selectDetailLineitemid = $selectDetailLineitemid;
    }

    public function getSelectDetailLineitemid(){
        return $this->selectDetailLineitemid;
    }

}
?>