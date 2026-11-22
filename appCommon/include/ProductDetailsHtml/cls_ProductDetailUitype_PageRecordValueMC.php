<?php

/**
 * Created by PhpStorm.
 * User: gyq_27
 * Date: 2017/4/6 0006
 * Time: 下午 1:56
 */
crm_load_class_file('cls_ProductDetailUitype_PageRecordValue','include/ProductDetailsHtml');
class cls_ProductDetailUitype_PageRecordValueMC extends cls_ProductDetailUitype_PageRecordValue
{
    public $entrytype='product';
    public $column_fields;
    public $detailfieldruleobj;
    public function setFocusColumn_fields($column_fields)
    {
        $this->column_fields=$column_fields;
    }
    //初始化分录返回值 20170411
    public function set_entrydetail($action,$outputProductFieldArr,$relatedCreationInfo)
    {
        global $weixin_user,$adb,$current_user,$PlatformMC;
        //$this->qrcodefield补充条件为当前是表单码功能
        if($weixin_user->environment_weixin||$this->qrcodefield=='yes'){
            $detailshowtype='all';
        }else{
            $detailshowtype='part';
        }
        //$outputProductFieldArr 查看界面显示字段  $relatedCreationInfo 关联创建信息
        $productdetail = $this->getValues();
        $productdetail['headers'] = is_array($productdetail['headers'])?$productdetail['headers']:[];
        //新建、编辑页特殊处理
        foreach ($productdetail['headers'] as $key => $fielddetail) {
            //duan 移动端字段颜色特殊判断
            if($fielddetail['bigtype'] == 'picklist') {
                $productdetail['headers'][$key]['withcolor'] = 'yes';
                //下拉框根据默认值给颜色
                global $global_picklist_colors_byvalue;
                $color_arr =  $global_picklist_colors_byvalue[$fielddetail['columnname']];
                $defaultvalue = $productdetail['headers'][$key]['defaultvalue'];
                $tmp_color_arr=(array)$color_arr;
                $productdetail['headers'][$key]['fieldvaluecolor'] = isset($color_arr[$defaultvalue])?$color_arr[$defaultvalue]:reset( $tmp_color_arr);
            }
            //duan 移动端要求把空改成null
            $fieldvaluecolor = $productdetail['headers'][$key]['fieldvaluecolor'];
            $productdetail['headers'][$key]['fieldvaluecolor'] = empty($fieldvaluecolor)?'':$fieldvaluecolor;
            $fieldplaceholder = $productdetail['headers'][$key]['fieldplaceholder'];
            $productdetail['headers'][$key]['fieldplaceholder'] = empty($fieldplaceholder)?'':$fieldplaceholder;
            //zkt 20230220 BUG0061764kfbcrm微信小程序体验版，报价单新增，单据分录最下方多了一个输入
            //edit: xll 2023/08/01 BUG0070231（移动端暂时去掉附件字段）XUQIU1000357 单据分录定制，增加“附件”字段类型（李发林）
            if ($fielddetail['bigtype'] == 'image' || $fielddetail['bigtype']=='fileattachment') {
                // unset($productdetail['headers'][$key]);
                $productdetail['headers'][$key]['local_count'] = 0;
                $productdetail['headers'][$key]['localId']=[];
                $productdetail['headers'][$key]['serverId'] = [];
                $productdetail['headers'][$key]['deletedId'] = [];
            }
        }
        $productdetail['headers'] = array_values($productdetail['headers']);

        $deploy_value_arr= getSys_Approvedeploy($this->module);
        if($_REQUEST['record']>0&&$_REQUEST['isDuplicate'])
        {
            $col_fields['approvestatus']='';
              
        }
        //zkt 20220602 52400kfbcrm移动端--采购退货单--单据页面详情打不开测试账号：wxl 密码：123
        //$deploy_value_arr为空时对应模块没有审批
        if(isset($deploy_value_arr)&&!empty($deploy_value_arr) && $deploy_value_arr['deploy_value']==0&&$_REQUEST['record']>0)//开启审批
        {
            if(is_array($this->column_fields) && !array_key_exists('approvestatus',$this->column_fields) && $this->module != 'WareHouseTransfer')
            {
               $sql='select approvestatus from '.$this->focus->table_name.' where '.$this->focus->table_index.'=?';
               $result=$adb->pquery($sql,array($_REQUEST['record']));
               
               $this->column_fields['approvestatus']=$adb->query_result($result,0,'approvestatus');
            }
        }
        $fieldids_content_orign = file_get_contents(globalStatic::$root_directory.'user_privileges/Config_SalesOrder_ProductShowFields_Mobile.php');
        if(empty($fieldids_content_orign)){
            $fieldids_content_orign = '{quantity}x{taxprice}';
        }
        $product_name_headers = array();
        $wareid_default = false;
		$columnname_bigtype = array();
            
        //editor:gyq_20191025 reason:选择源单及相关创建，仓库赋初值
        foreach ($productdetail['headers'] as $key => &$fielddetail) {
            $showfieldslabel[$fielddetail['columnname']] = $fielddetail['fieldlabel'];
            $showfieldsuitype[$fielddetail['columnname']] = $fielddetail['uitype'];
            $product_name_headers[$fielddetail['columnname']] = $fielddetail;
			$columnname_bigtype[$fielddetail['columnname']] = $fielddetail['bigtype'];
            $columnname_parentbigtype[$fielddetail['columnname']] = $fielddetail['parentbigtype'];
            $columnname_relatedmodulefield[$fielddetail['columnname']] = $fielddetail['relatedmodulefield'];
            if($fielddetail['columnname']=='wareid'){
                $wareid_default = array('hiddenvalue'=>'','value'=>'');
            }
            if($action=='EditView'&& $_REQUEST['isDuplicate']!='yes' && is_array($this->column_fields) &&array_key_exists('approvestatus',$this->column_fields)){
         
                if($this->column_fields['approvestatus']==D_A_S_APPROVED)
                {
                    
                    //审批结束设置允许编辑的字段
                    crm_load_class_file('ApproveFinished','modules/Approve');
                    $approvefinishedobj=ApproveFinished::getInstance($this->module,$_REQUEST['record']);
                    
                    $alloweditfield_arr= $approvefinishedobj->getAllowEditField();
                    $tablename=$fielddetail['tablename'];
                    
                    $columnname=$fielddetail['columnname'];
                   
                    if(!array_key_exists("$tablename:$columnname:$this->module",$alloweditfield_arr))
                    {
                        $fielddetail['edit_permission']=3;
                        
                    }
                }
            }
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
        //关联选择单据信息
        $related_record_arr = array();
        
        //duan 通用设置 单据分录明细是否折叠显示
        //$sql_11 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type=11 and is_open="yes"';
        //$result_11 = $adb->pquery($sql_11,array($current_user->id));
        //$is_open11 = $adb->num_rows($result_11)>0?'yes':'no';
        //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
        crm_load_class_file('ModuleUtils','modules/lingdang');
        $ModuleUtilsObj = new ModuleUtils();
        $mobiledetailinfoshowtype = $ModuleUtilsObj->getTabDetailShowType(gettabid($this->module));
        $SelectedDetailFields = $ModuleUtilsObj->getSelectedDetailFields($this->module,$mobiledetailinfoshowtype);//获取显示的字段列表
        //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
        $outputProductValues['mobiledetailinfoshowtype'] = $mobiledetailinfoshowtype;
        if($mobiledetailinfoshowtype=='table'){
            //小程序 --返回字段信息
            if (!empty($PlatformMC['type_mini'])) {
                $outputProductValues['mobiledetailcolumns'] = array_values($SelectedDetailFields);
            }else{
                //其他移动端
                $outputProductValues['mobiledetailcolumns'] = _array_column($SelectedDetailFields,'fieldlabel');
            }
        }

        foreach($MixproductValues as $listnum=>$content) {
            $fieldids_content = $fieldids_content_orign;
            foreach ($content as $columnname => $mixed_fieldvalue) {
                //editor:gyq_20190410 reason:0036816: 企业微信-出库单，分录明细中的仓库显示为仓库ID 仓库option
                if($product_name_headers[$columnname]['uitype']=='60'){
                    $wareid_content = array();
                    foreach ($product_name_headers[$columnname]['option'] as $key=>$value){
                        $wareid_content[$value['value']] = $value['text'];
                    }
                    //ld_related_producttoolfield 详情获取值没有返回表中关联数据,显示为空
                    if($wareid_content[$mixed_fieldvalue['value']]){
                        $product_field_value = $wareid_content[$mixed_fieldvalue['value']];
                    }else{
                        $product_field_value = $mixed_fieldvalue['value'];
                    }
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
                    //存放模块和单据id
                    $related_record_arr[$listnum][$columnname]['module'] = $entitytype;
                    $related_record_arr[$listnum][$columnname]['record'] = $product_field_value;
                    
					$product_field_value = getModuleHref($entitytype,$product_field_value);
				}
                //选择源单
                if($columnname_bigtype[$columnname] == 'selectsource'&& !empty($product_field_value)){
                    $hidden_field_value = $mixed_fieldvalue['hidden_value'];
                    $entitytype = getSalesEntityType($hidden_field_value);
                    //存放模块和单据id
                    $related_record_arr[$listnum][$columnname]['module'] = $entitytype;
                    $related_record_arr[$listnum][$columnname]['record'] = $hidden_field_value;
                }
                //引用关联选择单据
                if($columnname_relatedmodulefield[$columnname] == 'yes' && $columnname_parentbigtype[$columnname]=='reference'){
					$entitytype = getSalesEntityType($product_field_value);
                    //存放模块和单据id
                    $related_record_arr[$listnum][$columnname]['module'] = $entitytype;
                    $related_record_arr[$listnum][$columnname]['record'] = $product_field_value;
                    
					$product_field_value = getModuleHref($entitytype,$product_field_value);
				}
                //引用源单
                if($columnname_relatedmodulefield[$columnname] == 'yes' && $columnname_parentbigtype[$columnname]=='selectsource'){
					$entitytype = getSalesEntityType($product_field_value);
                    //存放模块和单据id
                    $related_record_arr[$listnum][$columnname]['module'] = $entitytype;
                    $related_record_arr[$listnum][$columnname]['record'] = $product_field_value;
                    
					$product_field_value = getModuleHref($entitytype,$product_field_value);
				}
                //引用源单类型
                if($columnname_relatedmodulefield[$columnname] == 'yes' && $columnname_parentbigtype[$columnname]=='entitytype'){
					$product_field_value = getTranstab($product_field_value);
				}
                if($columnname == 'productid'){
                    //存放模块和单据id
                    $related_record_arr[$listnum]['productname']['module'] = 'Products';
                    $related_record_arr[$listnum]['productname']['record'] = $product_field_value;
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
		crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
		$this->detailfieldruleobj=cls_detailfieldrule::getInstance($this->module);
		$fieldrulecolsproperty= $this->detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

		$outputProductValues['detailfieldruleinfo']=$this->detailfieldruleobj->getFieldRuleProperty();
		$detailfieldrulecolumn=$this->detailfieldruleobj->getAllFieldNameSetChangeEvent();//获取所有的触发明细字段;
		$outputProductValues['detailfieldrulefieldnames']=$detailfieldrulecolumn;

        if($action=='DetailView') {
            $outputFieldArr = $outputProductFieldArr;
            foreach ($productValues as $listnum => $content) {
                $item=0;
                $SelectedDetailFieldsValue = [];
                $tmpSelectedDetailFields = $SelectedDetailFields;
                // 产品套餐, 产品套餐信息放在最前面
                if(!empty($this->ProductDetailsData->rowColumnInfo[$listnum])){
                    if(isset($this->ProductDetailsData->rowColumnInfo[$listnum]['productbomid']) && !empty($this->ProductDetailsData->rowColumnInfo[$listnum]['productbomid'])){
                        $productbomid = $this->ProductDetailsData->rowColumnInfo[$listnum]['productbomid'];
                        $productbomquantity = $this->ProductDetailsData->rowColumnInfo[$listnum]['productbomquantity'];
                        $outputProductValues['list'][$listnum]['list'][] = ['v' => getModuleHref('Productbom',$productbomid),'k' => getTranstab("Productbom"),'i' => $productbomid];
                        $outputProductValues['list'][$listnum]['list'][] = ['v' => $productbomquantity,'k' => getFixedLabel("NumberOfProductsBom")];
                    }
                }
                foreach ($content as $columnname => $fieldvalue) {
					if(!empty($outputProductValues['detailfieldruleinfo']['hidecolumns']) && in_array($columnname,$outputProductValues['detailfieldruleinfo']['hidecolumns'])){
						continue;
					}
                    $fieldinfo=$this->focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
                    //edit: xll 2023/08/01 BUG0070231（移动端暂时去掉附件字段）XUQIU1000357 单据分录定制，增加“附件”字段类型（李发林）
                    // if ($fieldinfo&&($fieldinfo->getBigType()=='image' || $fieldinfo->getBigType()=='fileattachment')) {//详情页特殊处理
                    //     //dump($detailfilejsondata);
                    //     continue;
                    // }
                    
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
                            if($fieldinfo&&($fieldinfo->getUIType()==69 || $fieldinfo->getUIType()==1109)){
                                $showitem['u'] = 1109;
                                if(IsPreviewProfile($this->record,$this->module) == 'yes'){
                                    $showitem['previewprofile'] = 'yes';
                                }else{
                                    $showitem['previewprofile'] = 'no';
                                }
                                if(IsDownLoadProfile($this->record,$this->module) == 'yes'){
                                    $showitem['downloadprofile'] = 'yes';
                                }else{
                                    $showitem['downloadprofile'] = 'no';
                                }
                            }
                            if($columnname=='productname' && $fieldinfo -> get_ShowHyperlinks() == 'yes'){
                                $showitem['p'] = 'yes';
                            }
                            //移动端，关联选择单据字段可跳转
                            if(isset($related_record_arr[$listnum][$columnname])){
                                $relatedinfo = $related_record_arr[$listnum][$columnname];
                                //edit: xll 2023/07/26 BUG0070182 单据分录超链接字段显示超链接控制无效
                                if( $fieldinfo -> get_ShowHyperlinks() == 'yes')
                                    $showitem['p'] = 'yes';
                                $showitem['m'] = $relatedinfo['module'];
                                $showitem['i'] = $relatedinfo['record'];
                                $showitem['l'] = getTranstab($relatedinfo['module']);
                            }
                            if(!empty($fieldinfo)){
                                $fieldvaluecolor = $fieldinfo->getFieldValueColor();
                                if($fieldinfo->getUIType() == 60){
                                    global $global_picklist_colors_byvalue;
                                    $all_pick_colors = $global_picklist_colors_byvalue[$columnname];
                                    $fieldvaluecolor = isset($all_pick_colors[$fieldvalue])&&!empty($all_pick_colors[$fieldvalue])?$all_pick_colors[$fieldvalue]:'#666';
                                }
                                
                                if(!empty($fieldvaluecolor)){
                                    $showitem['c'] = $fieldvaluecolor;
                                }
                            }
                            // 帮助信息
                            if(!empty($fieldinfo)){
                                $helptips = $fieldinfo->getHelptips();
                                if(!empty($helptips)){
                                    $showitem['h'] = $helptips;
                                }
                            }
                            $showuitype = $showfieldsuitype[$columnname];
                            if(in_array($showuitype,array(2,3,69))) $showitem['u'] = $showuitype;
                            $outputProductValues['list'][$listnum]['list'][] = $showitem;
                            //duan 20221129 移动端明细页签增加折叠显示字段
                            $tmpcolumnname = $fieldinfo->getColumnname();
                            if(!empty($fieldinfo) &&array_key_exists($tmpcolumnname,$tmpSelectedDetailFields)&&in_array($mobiledetailinfoshowtype,['fold','table'])){
                                //$outputProductValues['list'][$listnum]['list2'][] = $showitem;
                                //zxm  20230316  XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）
                                $showitem['columnname'] = $columnname;
                                $SelectedDetailFieldsValue[$tmpSelectedDetailFields[$tmpcolumnname]['ordernum']] = $showitem;
                                unset($tmpSelectedDetailFields[$tmpcolumnname]);
                            }
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
                    $outputProductValues['list'][$listnum]['lineitem_id'] = $content['detailid'];
                }

                //zxm 20230317 字段排序 XUQIU1001134 移动端详情界面定制，增加“分录明细显示样式”参数（郭良峰）--处理字段值为空的情况
                if(!empty($SelectedDetailFields)&&$mobiledetailinfoshowtype=='table'){
                    foreach($SelectedDetailFields as $tmpk=>$tmpv){
                        if(!key_exists($tmpv['ordernum'],$SelectedDetailFieldsValue)){
                            $SelectedDetailFieldsValue[$tmpv['ordernum']] = ['v'=>'--','columnname'=>$columnname];
                        }
                    }
                }
                if($mobiledetailinfoshowtype=='fold'||$mobiledetailinfoshowtype=='table') {
                    $key = array_keys($SelectedDetailFieldsValue);
                    array_multisort($key, SORT_ASC, $SelectedDetailFieldsValue);
                    if (!empty($PlatformMC['type_mini'])&&$mobiledetailinfoshowtype=='table') {
                        //小程序返回值
                        $SelectedDetailFieldsValue_minipro = ['id'=>$content['productid']];
                        foreach($SelectedDetailFieldsValue as $tmpminikey=>$tmpminivalue){
                            $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname']] = $tmpminivalue['v'];
                            if(!empty($tmpminivalue['c'])){
                                $SelectedDetailFieldsValue_minipro[$tmpminivalue['columnname'].'Color'] = $tmpminivalue['c'];
                            }
                        }
                        $outputProductValues['minipro_tablelist'][] = $SelectedDetailFieldsValue_minipro;
                    }else{
                        //其他移动端的返回值
                        $outputProductValues['list'][$listnum]['list2'] = $SelectedDetailFieldsValue;
                    }
                }

            }
        }
        else{

            $editProductValues = array();
            foreach($MixproductValues as $listnum=>$content){
                // 产品套餐,产品套餐信息放在最前面
                if(!empty($this->ProductDetailsData->rowColumnInfo[$listnum])){
                    if(isset($this->ProductDetailsData->rowColumnInfo[$listnum]['productbomid']) && !empty($this->ProductDetailsData->rowColumnInfo[$listnum]['productbomid'])){
                        $productbomid = $this->ProductDetailsData->rowColumnInfo[$listnum]['productbomid'];
                        $productbomquantity = $this->ProductDetailsData->rowColumnInfo[$listnum]['productbomquantity'];
                        $editProductValues[$listnum]['productbomid'] = ['value' => getModuleHref('Productbom',$productbomid),'hiddenvalue' => $productbomid];
                        $editProductValues[$listnum]['productbomquantity'] = ['value' => $productbomquantity,'hiddenvalue' => $productbomquantity];
                    }
                }
                foreach($content as $fieldname=>$value){
                    if(is_array($value)){
                        if(empty($value['hiddenvalue'])) $value['hiddenvalue']=$value['value'];  
						//关联选择单据
						if($columnname_bigtype[$fieldname] == 'reference' && !empty($value['value'])){
							$entitytype = getSalesEntityType($value['value']);
							$product_field_value = getModuleHref($entitytype,$value['value']);
							$value['value'] = $product_field_value;
							$editProductValues[$listnum][$fieldname] = $value;
						}else if($columnname_relatedmodulefield[$fieldname] == 'yes' && $columnname_parentbigtype[$fieldname]=='reference'){
        					$entitytype = getSalesEntityType($value['value']);
        					$product_field_value = getModuleHref($entitytype,$value['value']);
                            $value['value'] = $product_field_value;
							$editProductValues[$listnum][$fieldname] = $value;
        				}else if($columnname_relatedmodulefield[$fieldname] == 'yes' && $columnname_parentbigtype[$fieldname]=='selectsource'){
        					$entitytype = getSalesEntityType($value['value']);
        					$product_field_value = getModuleHref($entitytype,$value['value']);
                            $value['value'] = $product_field_value;
							$editProductValues[$listnum][$fieldname] = $value;
        				}else if($columnname_relatedmodulefield[$fieldname] == 'yes' && $columnname_parentbigtype[$fieldname]=='entitytype'){
        					$product_field_value = getTranstab($value['value']);
                            $value['value'] = $product_field_value;
							$editProductValues[$listnum][$fieldname] = $value;
        				}
                        else{
							$editProductValues[$listnum][$fieldname] = $value;
						}
                        
                    }else{
                        $editProductValues[$listnum][$fieldname] = array('value'=>$value,'hiddenvalue'=>$value);
                    }
                    $fieldinfo=$this->ProductDetailsData->productToolFields->getFieldInfoobjBykey("columnname",$fieldname);
                    // 帮助信息
                    if(!empty($fieldinfo)){
                        $helptips = $fieldinfo->getHelptips();
                        if(!empty($helptips)){
                            $editProductValues[$listnum][$fieldname]['helptips'] = $helptips;
                        }
                    }
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
            $outputProductValues['list'] = $editProductValues;
            $outputProductValues['pricestrategy'] = $pricestrategy_arr;
        }
        $subtotalvalue = array();//QQ目前仅记录数量和价税合计的小计

        foreach($productdetail['subtotalvalue'] as $key=>$val){
           
            if($key=='quantity' || $key=='subtotal'){
                if($key=='quantity'){
                    if(array_key_exists($key,$showfieldslabel))
                         $subtotalvalue[$key]['label']='数量合计';
                    else{
                        //不显示数量字段时应不显示数量合计 --- 收付款单没有合计字段
                        continue;
                    }
                }else{
                    $subtotalvalue[$key]['label']='金额小计';
                }
                $subtotalvalue[$key]['value']=empty($val)?'0.00':$val;
                $fieldinfo = $this->ProductDetailsData->productToolFields->getFieldInfoobjBykey('columnname',$key);
                if(!empty($fieldinfo)){
                    if($fieldinfo->isAmountorCurrencyField()){
                        $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                        $subtotalvalue[$key]['value'] = setNumberFormatEmptySeperator($subtotalvalue[$key]['value'],$typeofdata_decmail);
                    }
                }
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
                    $typeofdata_decmail = 2;
                    $fieldinfo = $this->ProductDetailsData->productToolFields->getFieldInfoobjBykey('fieldname',$fieldname);
                    if(!empty($fieldinfo)){
                        $typeofdata_decmail = $fieldinfo->gettypeofdata_decmail();
                    }
                    $content['value'] = number_format($content['value'],$typeofdata_decmail);                    
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
        $outputProductValues['productdetail'] = 'no';//默认为no，收付款单另做判断
        $jsonArr['entry'] = $outputProductValues;
        return $jsonArr;
    }

    public function getSubTotal_Value(){
        $subtotals = parent::getSubTotal_Value();
        //BUG0071489 hzx 20230822 小计字段显示移动端依然显示
        $subtotal_obj = $this->ProductDetailsData->productToolFields->getModuleProductToolField()['subtotal'];
        if(empty($subtotal_obj)){
            return  '';
        }
        if($subtotal_obj->getDetailsFieldsProfile($this->actionname) == 'hidden'){
            return  '';
        }

        $tax_amount = $subtotals['tax_amount'];
        if(!isset($subtotals['subtotal'])){
            $subtotals['subtotal'] = $tax_amount;
        }
        unset($subtotals['tax_amount']);
        if(!isset($subtotals['quantity'])){
            $subtotals['quantity'] = '';
        }
        return $subtotals;
    }
    public function getDetailHeader()
    {
        $headerInfo = parent::getDetailHeader(); // TODO: Change the autogenerated stub
        foreach($headerInfo as $key => $producttoolfield){
            $this->headerInfo[$key]['producttoolfieldid'] = $producttoolfield->getProductToolFieldid();
            $this->headerInfo[$key]['columnname'] = $producttoolfield->getColumnName();
            $this->headerInfo[$key]['typedata'] = $producttoolfield->getTypeOfData();
            $this->headerInfo[$key]['width'] = $producttoolfield->getWidth();
            $this->headerInfo[$key]['edit_permission'] = $producttoolfield->getEdit_permission();
            $this->headerInfo[$key]['defaultvalue'] = $producttoolfield->getDefaultvalue();
            $this->headerInfo[$key]['uitype'] = $producttoolfield->getUIType();
            $this->headerInfo[$key]['fieldlabel'] = $producttoolfield->getFieldLabel();
            $this->headerInfo[$key]['tablename'] = $producttoolfield->getTableName();
            $this->headerInfo[$key]['input_type'] = $producttoolfield->getinput_type();
            $this->headerInfo[$key]['newline'] = $producttoolfield->getNewLine();
            $this->headerInfo[$key]['defaultcolumn'] = $producttoolfield->getDefaultColumn();
            $this->headerInfo[$key]['columnstring']=$producttoolfield->getColumnString();
            $this->headerInfo[$key]['formulastring']=$producttoolfield->getFormulaString();
            $this->headerInfo[$key]['reverseinfo']=$producttoolfield->getreverseinfo();
            
            $this->headerInfo[$key]['fieldid']=$producttoolfield->getFieldid();
            $this->headerInfo[$key]['nullfield']=$producttoolfield->getNullField();
            $this->headerInfo[$key]['allowhide']=$producttoolfield->getAllowHide();
			$this->headerInfo[$key]['bigtype']=$producttoolfield->getBigType();
            $this->headerInfo[$key]['relatedmodulefield']=$producttoolfield->getRelatedModuleField();
			$this->headerInfo[$key]['savedatabase']=$producttoolfield->getSaveDataBase();
			$this->headerInfo[$key]['referencemodule']=$producttoolfield->getReferenceModule();
            $this->headerInfo[$key]['parentbigtype']=$producttoolfield->getParentBigType();
            $this->headerInfo[$key]['fieldvaluecolor']=$producttoolfield->getFieldValueColor();
            $this->headerInfo[$key]['fieldplaceholder']=$producttoolfield->getFieldPlaceholder();
            $this->headerInfo[$key]['helptips']=$producttoolfield->getHelptips();
            $this->headerInfo[$key]['selectpricefrombook']=$producttoolfield->getSelectpricefrombook();
        }
        return $this->headerInfo;
    }

    public function getValues()
    {
        global $adb;
        //$orignValues=  parent::getValues(); // TODO: Change the autogenerated stub
      /*  foreach($orignValues['headers'] as $key=>$value){
            $typedataArr = explode('~',$value['typedata']) ;
            $orignValues['headers'][$key]['fieldtype']= $typedataArr[1];
        }
        foreach($orignValues['value'][0] as $columnname=>$content){
            if(!empty($content['option'])){
                foreach($orignValues['headers'] as $key=>$fieldcontent){
                    if($fieldcontent['columnname']==$columnname){
                        $orignValues['headers'][$key]['option'] = $content['option'];
                        break;
                    }
                }
            }
            for($i=0;$i<count($orignValues['value']);$i++){
                if(isset($orignValues['value'][$i][$columnname]['option'])){
                    unset($orignValues['value'][$i][$columnname]['option']);
                }
            }
        }*/

        $currencyobj=Currency::getInstance($adb);
        $allCurrencies = $currencyobj->getAllCurrencies();
        $orignValues = parent::getValues();
        $headers_detail_fieldname = array();
        foreach($orignValues['headers'] as $key=>$fieldcontent){
            $orignValues['headers'][$key]['defaultvalue'] = $fieldcontent['defaultInfo']['value'];
            $orignValues['headers'][$key]['defaulthiddenvalue'] = $fieldcontent['defaultInfo']['hiddenvalue'];
            //editor:gyq_20190507 reason:0037012: （落落计划）企业微信>灵当CRM>合同订单新增界面>添加明细：
            //合同订单表体分录增加的自定义下拉框字段，在PC端可以下拉选择，在手机端点了没反应（需要补丁）
            if(isset($fieldcontent['defaultInfo']['option']))
                $option = $fieldcontent['defaultInfo']['option'];
            else
                $option = $fieldcontent['defaultInfo']['optionvalue'];

            if($fieldcontent['columnname']=='currency_id'){//分录币种字段额外增加汇率
                foreach($option as $okey=>$oval){
                    foreach($allCurrencies as $ckey=>$cval){
                        if($cval['curid']==$oval['value']){
                            $option[$okey]['conversionrate'] = $cval['conversionrate'];
                            break;
                        }
                    }
                }
                $orignValues['headers'][$key]['option'] = $option;
            }
            elseif($fieldcontent['uitype']==60&&$fieldcontent['columnname']=='wareid'){


                //editor:gyq_20190410 reason:0036816: 企业微信-出库单，分录明细中的仓库无法选择
                crm_load_function_file('selWareAll','include/Stock','CommonStock');
                $wareresult = selWareAll();
                $wareArray = array();
                for($i = 0; $i<$adb->num_rows($wareresult); $i++)
                {
                    $wareArray[$i]['text'] = $adb->query_result($wareresult, $i, "name");
                    $wareArray[$i]['value'] =$adb->query_result($wareresult, $i, "id");
                }
                /* if($fieldcontent['defaultInfo']['option']){
                    unset($fieldcontent['defaultInfo']['option'][0]);    
                }*/
                //$fieldcontent['defaultInfo']['option'] = array_values($fieldcontent['defaultInfo']['option']);
                $orignValues['headers'][$key]['option'] = $wareArray;
            }
            elseif($fieldcontent['bigtype']=='reference'){
                if(!empty($orignValues['headers'][$key]['defaultvalue'])){
                    $tmp_value = $orignValues['headers'][$key]['defaultvalue'];
                    $contract = getSalesEntityType($tmp_value);//获取对应模块
                    $contractname = getModuleHref($contract,$tmp_value);//获取对应超链接字段值
                    $orignValues['headers'][$key]['defaultvalue'] = $contractname;
                }
            }
            else{

                $TF1 = array(51=>'Date_Ymd',52=>'Date_YmdHms',53=>'Date_Hm',54=>'Date_Hms',"210"=>"Date_Hm");
                if(!empty($TF1[$fieldcontent['uitype']])){
                    $orignValues['headers'][$key]['fieldtype_orign_mc'] =$TF1[$fieldcontent['uitype']];
                }
                if(!empty($option)){
                    $orignValues['headers'][$key]['option'] = $option;
                }
            }
            $type_data = explode('~',$fieldcontent['typedata']) ;
            $orignValues['headers'][$key]['fieldtype'] = $type_data[1];
            $orignValues['headers'][$key]['text'] = '';
            unset($orignValues['headers'][$key]['defaultInfo']);
            $headers_detail_fieldname[$fieldcontent['columnname']] = $orignValues['headers'][$key];
        }
        foreach($orignValues['value'] as $linenum=>$lineval){
            foreach($lineval as $columnname=>$content){
                //editor:gyq_20191023 reason:选择源单带出分录，源单的批次不予录入当前分录
                //0038326: （珞落计划）企业微信端，出库单新建界面选择“入库单”源单，编辑产品明细界面，批次应该不显示默认值
                if($columnname=='batchtext'&&$_REQUEST['action']=='getChooseModuleInfo') {
                    if($headers_detail_fieldname[$columnname]['defaultvalue']){
                        $orignValues['value'][$linenum][$columnname]['value'] =
                        $orignValues['value'][$linenum][$columnname]['hiddenvalue'] = $headers_detail_fieldname[$columnname]['defaultvalue'];
                    }else{
                        $orignValues['value'][$linenum][$columnname]['value'] =
                            $orignValues['value'][$linenum][$columnname]['hiddenvalue'] = '';
                    }
                }
                if(isset($orignValues['value'][$linenum][$columnname]['option'])){
                    unset($orignValues['value'][$linenum][$columnname]['option']);
                }
            }
        }
       //productbatchstatuslist
      // $orignValues['productbatchstatuslist']=$productbatchstatuslist;//产品是否开启批次管理列表

        return $orignValues;
    }
    // copy with appCommon\include\TabDetailFields\cls_TabDetail_PageRecordValueMC.php
    public function getLastRow_Value()
    {
        $lastrowvalues = parent::getLastRow_Value(); // TODO: Change the autogenerated stub
        $orign_lastRowValue =$lastrowvalues;
        $lastRowValue = array();
        if($_REQUEST['action']=='DetailView') {

            foreach ($orign_lastRowValue as $key => $value) {
                $lastRowField = array();
                $columnname = $value['columnname'];
                if ($columnname == 'adjustment') {
                    $lastRowField['label'] = getFixedLabel('Adjustment');
                } elseif ($columnname == 'total') {
                    $lastRowField['label'] = getFixedLabel('SUM');
                } elseif ($columnname == 'discount_amount') {
                    if ($orign_lastRowValue['discount_type'] == 'amount') {
                        $lastRowField['label'] =  getFixedLabel('ALLSINGLEDISCOUNT').':'.getFixedLabel('DIRECTPRICE');
                    } elseif ($orign_lastRowValue['discount_type'] == 'percent') {
                        $lastRowField['label'] = getFixedLabel('ALLSINGLEDISCOUNT').':'.getFixedLabel('PERCENTAGEPRICE');
                    }
                } else {
                    continue;
                }
                $lastRowField['value'] = $value['value'];
                if(isset($value['fieldvaluecolor'])){
                    $lastRowField['fieldvaluecolor'] = $value['fieldvaluecolor'];
                }
                if(isset($value['dispaly'])){
                    $lastRowField['dispaly'] = $value['dispaly'];
                }
                $lastRowValue[$columnname] = $lastRowField;
            }
        }else {
            /*  $_REQUEST['allSingledDiscount'] = '%';
           $_REQUEST['discount_amount'] = '8';
           $_REQUEST['adjustmentType'] = '-';
           $_REQUEST['adjustment'] = '11';
           $_REQUEST['total'] = '100';
           $_REQUEST['subtotal'] = '110';*/
            foreach ($orign_lastRowValue as $key => $value) {
                $lastRowField = array();
                $columnname = $value['columnname'];
                if(isset($value['fieldvaluecolor'])){
                    $lastRowField['fieldvaluecolor'] = $value['fieldvaluecolor'];
                }
                if(isset($value['dispaly'])){
                    $lastRowField['dispaly'] = $value['dispaly'];
                }
                if ($columnname == 'adjustment') {
                    if (substr($value['value'], 0, 1) == '-') {
                        $lastRowField['text'] = getFixedLabel('DEDUCT');
                        $adjustment_type = '-';
                    } else {
                        $lastRowField['text'] = getFixedLabel('ADD');
                        $adjustment_type = '+';
                    }
                    $label = getFixedLabel('Adjustment');
                    $lastRowField['adjustmentType'] = $adjustment_type;
                    $lastRowField['option'] = array(0 => array('text' => getFixedLabel('ADD'), 'value' => '+'), 1 => array('text' => getFixedLabel('DEDUCT'), 'value' => '-'));
                    $lastRowField['value'] = abs($value['value']);
                    $lastRowField['label'] = $label;
                    $lastRowValue[$columnname] = $lastRowField;
                } elseif ($columnname == 'total') {
                    $label = getFixedLabel('SUM');
                    $lastRowField['value'] = $value['value'];
                    $lastRowField['label'] = $label;
                    $lastRowValue[$columnname] = $lastRowField;
                }elseif($columnname == 'deductionreceived_amount') {
                    $label = '';
                    $tmpfieldinfo = $this->focus->detailfieldobj->getFieldInfoobjBykey('columnname','deductionreceived_amount');
                    if(!empty($tmpfieldinfo))
                    {
                        $label = $tmpfieldinfo->getFieldLabel();
                    }
                    $lastRowField['value'] = $value['value'];
                    $lastRowField['label'] = $label;
                    $lastRowValue[$columnname] = $lastRowField;
                }elseif ($columnname == 'discount_amount') {
                    if ($orign_lastRowValue['discount_type'] == 'percent') {
                        $label = getFixedLabel('ALLSINGLEDISCOUNT');
                        $discount_type = getFixedLabel('PERCENTAGEPRICE');
                        $discount_type_value = '%';
                    } else {
                        $label = getFixedLabel('ALLSINGLEDISCOUNT');
                        $discount_type= getFixedLabel('DIRECTPRICE');
                        $discount_type_value = '-';
                    }
                    $lastRowField['text'] = $discount_type ;
                    $lastRowField['allSingledDiscount']= $discount_type_value ;
                    $lastRowField['option'] = array(0 => array('text' => getFixedLabel('DIRECTPRICE'), 'value' => '-'), 1 => array('text' => getFixedLabel('PERCENTAGEPRICE'), 'value' => '%'));
                    $lastRowField['value'] = $value['value'];
                    $lastRowField['label'] = $label;
                    $lastRowValue[$columnname] = $lastRowField;
                }
                else {
                    continue;
                }
            }
        }
        return $lastRowValue;
    }
    public function getModuleProductBaseColumn(){
        $basecolumn = $this->ProductDetailsData->productToolFields->getModuleProductBaseColumn();
        return $basecolumn;
    }
    //字段公式
    public function getModuleProductFormulaField()
    {
        $ProductToolField = $this->ProductDetailsData->moduleProductToolField;
        foreach($ProductToolField as $key=>$content){
            foreach($content as $field=>$value){
                if(empty($value)){
                    $ProductToolField[$key][$field] = '';
                }
            }
        }
        return $ProductToolField;
    }
    //获取不显示并且有公式的自定义字段
    public function getNoPresenceFieldFormula()
    {

        $noPresenceField = $this->ProductDetailsData->noPresenceField;


        if (!$this->ProductDetailsData) {
            $this->createProductDetailsDataobj();
        }
        //获取明细表头信息
        $headerInfo = $this->ProductDetailsData->getProductToolTrData($this->fromFocus, $this->pagemode);

        //$entry_value = parent::getValues()['value'];

        if(!empty($this->actionname)) {
            //hzx 产品分录字段权限过滤
            foreach ($headerInfo as $index => $field) {
                if ($field->getDetailsFieldsProfile($this->pagetype_actionarray[$this->actionname]) == 'hidden') {
                    $noPresenceField[] = array('producttoolfieldid'=>$field->getProductToolFieldid(),'columnname'=>$field->getColumnName(),'defaultvalue'=>$field->getDefaultvalue());
                }
            }
        }
        return $noPresenceField;
    }
    //数量和单价字段系统参数
    public function getSystemForPoint()
    {
        $deploysystem = $this->ProductDetailsData->getSystemMethod();
        $deploy_10 = getSys_deploy(10);
        $deploy_124 = getSys_deploy(124);
        $deploy_140 = getSys_deploy(140);
        $deploy_141 = getSys_deploy(141);
        $deploy_211 = getSys_deploy(211);
        $deploy_212 = getSys_deploy(212);
        $deploy_351 = getSys_deploy(351);
        //lengthdecimaldigits(单据明细中数量小数位数) lengthprice(设置单据分录明细中单价字段小数位数)
        $systemPoint = array('sys_10' => $deploy_10['deploy_value'],
                             'sys_49' => $deploysystem['lengthdecimaldigits'], 
                             'sys_93' => $deploysystem['lengthprice'],
                             'sys_124'=> $deploy_124['deploy_value'],
                             'sys_140'=> $deploy_140['deploy_value'],
                             'sys_141'=> $deploy_141['deploy_value'],
                             'sys_211'=> $deploy_211['deploy_value'],
                             'sys_212'=> $deploy_212['deploy_value'],
                             'sys_351'=> $deploy_351['deploy_value']);
        return $systemPoint;
    }
}