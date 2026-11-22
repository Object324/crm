<?php
/**
* 产品明细HTML
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
/**
* 修改编码格式:统一编码：UTF-8
* @author Chj
*/
crm_load_class_file('Parent_ProductDetailsHtml','include/ProductDetailsHtml');
class cls_productDetailsHtml extends Parent_ProductDetailsHtml{
	
    public $producttype;
    public $record;
    public $allCurrencies;
    public $notpart_columnname_arr = [];
    public $related_columnname_arr = [];
    public $entityProductdata;
    public $pagetype_actionarray = [];
    
	public function __construct($module){
		parent::__construct($module);
        $this->module = $module;
        if($this->producttype=='product'){
            
        }else{
            $this->allCurrencies = $this->currencyobj->getAllCurrencies();
        }
        
        $this->notpart_columnname_arr = array('servicecontracts_start_date','servicecontracts_end_date','entitytype','entitytypeid');
        $this->related_columnname_arr = array('productname','product_no');
        $this->entityProductdata = crm_load_class_obj('cls_productDetailsData',"modules/$module/ProductDetails",array($module));
        $this->pagetype_actionarray = array('CreateView' => 'create', 'DetailView' => 'details', 'EditView' => 'edit');

	}
    
    public function getDetailobjbyEntitytype($module){
        
        $classname = "cls_Common_DetailsHtml";
        $sourcemodule_obj = crm_load_class_obj($classname,"modules/WorkSheet/ProductDetails",array($module));
        $sourcemodule_obj->productdetail_mode = 'sourcemodule_create';
        $sourcemodule_obj->getPageType();
        return $sourcemodule_obj;
    }
    //移动端
    public function getDetailobjbyEntitytypeMobile($module){
        
        $classname = "cls_MobileCommon_DetailsHtml";
        $sourcemodule_obj = crm_load_class_obj($classname,"modules/WorkSheet/ProductDetails",array($module));
       // $sourcemodule_obj->productdetail_mode = 'module_create';
        $sourcemodule_obj->getPageType();
        return $sourcemodule_obj;
    }

    //获取不同分录的内容
    public function getspecialDetailsHtml($frommdoulefocus,$productdetail_mode='',$producttype=''){
        $this->producttype = $producttype;
        /*
        if($productdetail_mode=='sourcemodule_create'){
            if($frommdoulefocus->module_name =='SalesOrder'){
                $this->product_columnname_arr = array('productname','product_no','productsheet','entitytype','entitytypeid');
            }else if($frommdoulefocus->module_name =='ServiceContracts'){
                $this->product_columnname_arr = array('productname','product_no','productsheet','entitytype','entitytypeid','servicecontracts_start_date','servicecontracts_end_date');
            }
        }*/
        
        return $this->getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
    }

	//获取明细内容
	public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$this->frommdouleFocus = $frommdoulefocus;
        $this->productdetail_mode = $productdetail_mode;
        $this->getPageType();
        $withproductdetail='yes';
        $display = $this->checkdisplay();
        $this->resetwidth();
        if($productdetail_mode=='sourcemodule_create')
        {
            //edit:can 20210319 原单是否带出产品分录
            $sourcemodule_arr=getSourceModule($this->module);
            foreach($sourcemodule_arr as $sourcemoduleinfo)
            {
                if($sourcemoduleinfo['entitytype']==$frommdoulefocus->module_name)
                {
                    $withproductdetail=$sourcemoduleinfo['withdetail'];
                    if($withproductdetail=='no')
                    {
                        $productdetail_mode='sourcemodule_create_nodetail';
                    }
                    break;
                }

            }
        }
        
		//详情页列宽减去操作列宽度
		if($this->productdetail_mode == 'details'){
			$this->width -= 15;
		}
		
        if($this->productdetail_mode == 'details'){
			//获取明细数据
			$db_value = $this->getProductHtmlContentDbValue();
            
			if(empty($db_value)){
				return '';
			}
		}
		if(!empty($this->frommdouleFocus->lineitemIds)){

  
			//如果是源单，则取源单中第一条产品的lineitem_id对应的单据id和模块
			//$linemiten_infos = $this->ProductDetailsData->getLineitemByInfos($this->frommdouleFocus->lineitemIds);
		//	if(!empty($linemiten_infos['recordid'])){
				$this->recordid = $this->frommdouleFocus->id;
				$this->frommdouleFocus->module = $this->frommdouleFocus->moduleName;;
		//	}
		}
        //获取明细表头名称信息
      
		$this->productToolTr =$this->ProductDetailsData->getProductToolTrData($this->frommdouleFocus,$this->productdetail_mode);
                        
        if(!empty($this->productToolTr)){
			$currencyid = 1;//默认币种


			//产品明细选择币种 noCurrency 为空显示
			if(empty($_REQUEST['noCurrency']) && $this->isrmbproduct==0){
			  crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
          
				if($this->recordid){
					$currency_info = getInventoryCurrencyInfo($this->frommdouleFocus->module,$this->recordid);
				}else if($this->focus->id){
					$currency_info = getInventoryCurrencyInfo($this->module,$this->focus->id);
				}
			}

			if($this->productdetail_mode == 'details'){
				$table .="<tr><td><div class='DivCName DivCNamehover' style='".$display."' ";
                if($this->producttype=='product'){
                    $table .= " onclick=showHideStatus('newproductsStaus','newprojuctscol')><span class='' name='newprojuctscol' id='newprojuctscol'></span>";
                    $table .=getFixedLabel('REPAIRPRODUCTS');
                }else{
                    $table .= " onclick=showHideStatus('productsStaus','projuctscol')><span class='' id='projuctscol'></span>";
                    $table .=getFixedLabel('ACCESSORYINFORMATION');
                    $table .= '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.getFixedLabel('Currency') .' : <font style="font-weight:normal;">'
    	                		 . getTranslatedCurrencyString($currency_info['currency_name']) 
    	                		 . '('.$currency_info['currency_symbol'].')' ;
                }
                
                
                
                         global $adb;
                        $sql='select * from ld_field where tabid=? 
                                and presence in(0,2) and allowedit="yes" and displaytype=3 order by block asc,sequence asc';
                        $result=$adb->pquery($sql,array(getTabid($this->module)));
                        $rows=$adb->num_rows($result);
                      
                       for($i=0;$i<$rows;$i++)
                       {
                            $columnname=$adb->query_result($result,$i,'columnname');
                            $fieldname=$adb->query_result($result,$i,'fieldname');
                            $tablename=$adb->query_result($result,$i,'tablename');
                            if($columnname!='currency_id')
                            { 
                                $bigtype=$adb->query_result($result,$i,'bigtype');
                                if($bigtype=='reference')
                                {
                                    $uitype=$adb->query_result($result,$i,'uitype');
                                    crm_load_class_file("cls_module_uitype",'include/fields');
                                    $uitypemodules=cls_module_uitype::getUitypeModules();
                                    $referencemodule=$uitypemodules[$uitype];
                                    $referencefocus=CRMEntity::getInstance($referencemodule);
                                    $referencelinkfield=$referencefocus->list_link_field;
                                    $fieldlabel=$adb->query_result($result,$i,'fieldlabel');
                                    $tmpvalue= getModuleHref($referencemodule,$this->focus->column_fields[$fieldname]);
                                    
                                    
                                    $table.='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'.$fieldlabel."：".'<font style="font-weight:normal;">'.$tmpvalue;
                                    
                                }
                                
                            }
                            
                       }
                if($this->producttype=='product'){
                    $table .="";
				    $table .="	</div></td></tr><tr><td name='newproductsStaus' id='newproductsStaus' style='".$display."' >";
                }else{
                    $table .="";
				    $table .="	</div></td></tr><tr><td id='productsStaus' style='".$display."' >";
                }
                
			}
  
			$table .='<input type="hidden" name="module_nullfield" value="'.implode('##',$this->ProductDetailsData->module_productnullfield).'">';
			$table .='<input type="hidden" name="addproductrow" value="'.$this->systemMethod['addproductrow'].'">';//设置产品分录中最后一行选择产品后是否自动新增一个空行
			$table .='<input type="hidden" name="productToolField" value="'.$this->ProductDetailsData->alltypeofdata.'">';//当前模块的所有自定义字段信息
			$table .='<input type="hidden" name="lengthdecimaldigits" value="'.$this->systemMethod['lengthdecimaldigits'].'">';//系统参数数量小数位控制
            $table .='<input type="hidden" name="lengthprice" value="'.$this->systemMethod['lengthprice'].'">';//系统参数单价小数位控制            
			$table .='<input type="hidden" name="isrmbproduct" value="'.$this->systemMethod['isrmbproduct'].'">';//行业
			if($this->producttype=='part'){
                $table .='<div name="productDiv" id="productDiv" class="popDetailTable" style="overflow-x: auto; overflow-y: hidden;min-height:0%;'.$display.'">';//横向拖动div
                $table .='<table  class="" id="proTab" name="proTab" style="width:'.$this->width.'mm;" border="0" align="center" cellpadding="0" cellspacing="0">';
                $table .='<input type="hidden"  name="table_width" value="'.$this->width.'">';
            }else{
                $table .='<div name="newproductDiv" id="newproductDiv" class="popDetailTable" style="overflow-x: auto; overflow-y: hidden;min-height:0%;'.$display.'">';//横向拖动div
                $table .='<table class="" name="newproTab" style="width:'.$this->width.'mm;" border="0" align="center" cellpadding="0" cellspacing="0">';
            }
            
            
			////没有产品模块权限，请联系管理员
			if(isPermitted('Products','index') == 'no' || !vtlib_isModuleActive('Products')){
				$table .='<input type="hidden"  name="vtlibproducts" value="no">';
			}else{
				$table .='<input type="hidden"  name="vtlibproducts" value="yes">';
			}
			
            
			
			if($this->productdetail_mode == 'details'){
				//$table .='<th colspan="2">' . getTranstab('Products') . getFixedLabel('INFORMATION') . '</th>';
			}
			else{
                if($this->producttype=='part'){
                    $productToolMore = count($this->productToolTr)+2;
                    $table .='<tr class="ld-from-headblock-entry">';
    				$table .='<th colspan="3" class="ld-from-headblock-title">' .getFixedLabel('ACCESSORYINFORMATION') . '</th>';
    				$table .='<th colspan="'.$productToolMore.'" class="ld-from-headblock-title">';
                }else{
                    $productToolMore = count($this->product_columnname_arr)+2;
                    $table .='<tr class="ld-from-headblock-entry">';
    				$table .='<th colspan="3" class="ld-from-headblock-title">' .getFixedLabel('REPAIRPRODUCTS') . '</th>';
    				$table .='<th colspan="'.$productToolMore.'" class="ld-from-headblock-title">';
                }
			}
            
            if(empty($_REQUEST['noCurrency']) && $this->isrmbproduct==0&&$this->producttype=='part'){
			    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
				if($this->recordid){
					$currency_info = getInventoryCurrencyInfo($this->frommdouleFocus->module,$this->recordid);
				}else if($this->focus->id){
					$currency_info = getInventoryCurrencyInfo($this->module,$this->focus->id);
				}
                
				$currencyid = $currency_info['currency_id'];
                if(empty($currencyid))
                {
                    $currencyid=1;
                }
				$table .='<input type="hidden" value="'.$currencyid.'" name="prev_selected_currency_id" />';
				if($this->productdetail_mode == 'details'){
					//$table .=  getFixedLabel('Currency') .' : <font style="font-weight:normal;">' . getTranslatedCurrencyString($currency_info['currency_name']) . '('.$currency_info['currency_symbol'].')';
				}else{
					$table .= $this->getCurrencySelect($currencyid,$this->allCurrencies);
					
                    if(getCommonVersion('oem_crm') == 'no'){
						$table .= '<a class="icon-mediumimg_1" href="javascript:;" style="position:absolute;right:0.7%;margin: 5px 5px 0 0;" onclick="getLinksUrl(\'\',\'ProductDetails\',\'selectproduct\');"></a>';
					}
				}
			}
            
            //编辑页：输入折扣后按快捷键提示信息
            if($this->productdetail_mode != 'details' && $this->producttype == 'part'){
			    //editor:gyq_161 reason:带分录模块弹出层,id改为name   2019/11/22 15:15
                $table .= '<span name="kindlyremind" style="color:red;font-weight:normal;display:none;position:relative;left:15px;"></span>';
                $table .= '<span name="detailCtrlEnterComBox" style="color:red;font-weight:normal;display:none;">&nbsp;&nbsp;'.getFixedLabel('CtrlEnterComBox').'</span>';
                $table .='</th></tr>';
			}      
          
            
			$table .= $this->getProductHtmlHeader();//列头

            if($this->productdetail_mode!='create' || $this->producttype == 'product'){
                $table .= $this->getProductHtmlContent();//中间行
            }

			$table .='<input type="hidden"  name="rowcnt" value="'.$this->productrows.'">';
            $table .='<input type="hidden"  name="SYstemArg" value="'.$this->systemMethod['SystemArgument'].'">';
            $table .='<input type="hidden"  name="hddlistprice" value="0">';
			//row_subtotal 等于1 始终显示
            
			if($this->subtotalTr == 'yes' || $_REQUEST['row_subtotal'] == 1){
			     
				$table .=$this->getProductHtmlSubTotalTr();//小计行
			}
			$table .='</table>';
			$table .='</div>';
            if($this->producttype == 'part'){
                $table .='<div id ="LastContent" name ="LastContent" style="'.$display.'">';
                $table .= $this->getProductHtmlLastContent();//最后行
                $table .='</div>';
            }
            
		}
        
		if($this->productdetail_mode == 'details'){
			$table .='</td></tr>';
		}
        
		return $table;
	}
    
    public function getProductHtmlHeader(){
        $detail_issticky = getTabdetail_issticky($this->module);//zxm 20230808 通过查表获得冻结列数,放在表头trhead上告诉js我冻结到第几列-- todo--
		$table = '<tr class="WorkTdhead" tag="trhead" data-stickyindex="'.$detail_issticky.'" style="position: sticky; top: 0px; background-color: rgba(0, 0, 0, 0); z-index: 100000;">';
		//单据在编辑和新增的时候显示工具列宽（删除产品、上下移动按钮）
		if($this->productdetail_mode != 'details'){
			$table .='<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="0"  style="width:0mm;display:none" align="right"></td>';//工具列宽
		}
        $table .= $this->getRowNo_header();
        $table .= $this->getRelatedProductHeader();
        global $global_picklist_colors_byvalue;
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $obj_pink_list = new cls_PickList();
		//中间行自定义字段列头

		foreach($this->productToolTr as $productToolFieldInfo){
            
			if($productToolFieldInfo->getNewLine() == 1)continue;
			$typeofdata = explode('~',$productToolFieldInfo->getTypeOfData());
			$width=$productToolFieldInfo->getWidth();
            $columnname=$productToolFieldInfo->getColumnName();

            if(!$this->check_productcolumn($columnname)){
                continue;
            }
            
            $fieldname=$productToolFieldInfo->getFieldName();
            $obj_pink_list->getPickListValues($fieldname,$productToolFieldInfo);
            if(is_array($this->fieldrulerequirecolumn_arr)&&in_array($columnname,$this->fieldrulerequirecolumn_arr))
            {
                $typeofdata[1]='M';
            }
            $display='';
            if(is_array($this->fieldruleHideColumn_arr)&&in_array($columnname,$this->fieldruleHideColumn_arr)){
                //edit:can 20200721 布局规则
                $display=" display:none;";
            }
            $fieldlabel = $productToolFieldInfo->getFieldLabel();
            $table .='<td class="ld-form-item-content-entrytitle" head_width="'.$width.'" head_detailfieldname="'.$columnname.'" name="productdetails_header_'.$productToolFieldInfo->getColumnName().'" style="width:'.$width.'mm;'.$display.'"><font color="red" style="display:none" class="td_required_'.$productToolFieldInfo->getColumnName().'">*</font>'.$fieldlabel.'</td>';	
            
		}
        if($this->producttype=='product'){
            $table .= $this->addSourseHeader();
        }
		$table .='</tr>';
		return $table;
	}
    public function getRowNo_header(){
        if($this->productdetail_mode == 'details'){
            $header = '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm;text-align:center;" >#</td>';
            if($this->producttype!='part'){
                //$header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">'.getFixedLabel('WHETHERTOREPAIR').'</td>';
            }
        }else{
            if($this->producttype == 'part'){
                $header = '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:25mm" text-align="center">'.getFixedLabel('OPERATING').'</td>';
                $header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm;text-align:center;">#</td>';
            }else{
                $header = '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">'.getFixedLabel('OPERATING').'</td>';
                $header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:10mm;text-align:center;">#</td>';
                //$header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">'.getFixedLabel('WHETHERTOREPAIR').'</td>';
            }
        }
		return $header;
	}
	
    public function getProductHtmlContent($jsAddRowid=''){
	   global $global_picklist_colors_byvalue;
     
		//$jsAddRowid有值时，表示添加行
        $this->tablecontents=array();
        $ld_inventoryproductrel=$this->ProductDetailsData->focus->Detail_table;
        $Detail_table_id=$this->ProductDetailsData->Detail_table_index;//明细表主键
        $Detail_table_scf=$this->ProductDetailsData->Detail_table_scf;//明细自定义表
        $Detail_table_index=$this->ProductDetailsData->Detail_table_index;//明细表和主表关联字段
        //设置单据分录明细中产品管理的价格和金额计算时的基准字段
        $deploy_values=getSys_deploy(124);
        $base_column = 'no';
        if(empty($this->productToolTr))
        	$this->productToolTr =$this->ProductDetailsData->getProductToolTrData($this->frommdouleFocus,$this->productdetail_mode);
     
      
		if(!empty($jsAddRowid)){
			$this->productdetail_mode = 'addrow_create';
		}
    
		if($this->productdetail_mode != 'create' && $this->productdetail_mode != 'addrow_create' && empty($jsAddRowid)){
		  //获取明细数据
          
			$this->productToolFieldsValues = $this->getProductHtmlContentDbValue(); 
			$this->productrows = count($this->productToolFieldsValues);//计算产品明细的行数
            
            if($this->productrows==0 &&$this->producttype=='part'){
                return '';
            }
            
			if($this->productdetail_mode == 'sourcemodule_create'){
				$rows = $this->getModuleProductRow();
				if($this->productrows < $rows){
					$this->productrows = $rows;
				}
			}
			//当明细数据为空时，默认一行明细
			if(empty($this->productrows)){
				$this->productdetail_mode = 'create';
				$this->productrows = 1;
			}
		}else{
			if($this->productdetail_mode == 'addrow_create'){
				$this->productrows = 1;
			}else{
				$this->productrows = $this->getModuleProductRow();
			}
		}
        
        $rowid = 0;
		for($i = 0; $i<$this->productrows; $i++){
			$productinfo = array();
            $tableContent='';
            
            if($this->productrows>=1){
                $rowid++;
            }else{
                $rowid = 1;
            }
            
			if(!empty($jsAddRowid)){
				$rowid = $jsAddRowid;
			}
            //zxm 20231007 悬浮变色去掉
			if($rowid%2 ==0) {
                $tableContent .='<tr detaildeleted="no" rowindex="'.$rowid.'" valign="top" class="lvtColDataBj dragtrrow" name="row'.$rowid.'">';
            }else{
                $tableContent .='<tr detaildeleted="no" rowindex="'.$rowid.'" valign="top" class="lvtColData dragtrrow" name="row'.$rowid.'">';
            }
            $tableContent .='<input type="hidden"  name="hidden_rowid" value = "0" />';      
                 
			//状态为不显示并且有字段公式的自定义字段
            
			if(!empty($this->ProductDetailsData->noPresenceField)){
				foreach($this->ProductDetailsData->noPresenceField as $fieldinfo){
				    
					$tableContent .='<input type="hidden" detailcolumnname="'.$fieldinfo['columnname'].'" name="'.$fieldinfo['columnname'] .'" value="">';
				}
			}
			$isRelatedModuleCreate=$this->ProductDetailsData->isRelatedModuleCreate($this->frommdouleFocus);//是否为关联创建，yes:是

            
			$ProductToolFieldsInfos = $this->ProductDetailsData->getProductToolFieldsInfos($this->productToolFieldsValues[$i],$this->frommdouleFocus,$this->productdetail_mode);
            $producttoolfield_info = $ProductToolFieldsInfos['producttoolfield_info'];
            $productinfo = $ProductToolFieldsInfos['productdetail_value'];
            
            $havelineitem_idhtml='no';
            
            //工单管理模块的保修产品分录需要源单信息
            foreach($this->entityProductdata->moduleProductToolField as $col_info){
				$uitype = $col_info['uitype'];
				$columnname = $col_info['columnname'];
				$controlbol =$columnname;// $columnname.$rowid;//columnname
           		
				if($uitype == 200 || $uitype == 201 || $uitype == 202 || $uitype == 204){	//源单 204为源单类型
					$selectproducthidden = '';
                    $havelineitem_idhtml='yes';
					if(empty($this->frommdouleFocus->lineitemIds) && (($this->focus->mode == 'edit' && $this->focus->id > 0)||$this->isDuplicate == true)){
						//编辑模块的原单选项
						$lineitem_id = $this->productToolFieldsValues[$i]['parent_lineitem_id'];
					}else{
						$lineitem_id = $this->productToolFieldsValues[$i]['lineitem_id'];
					}
                    if($isRelatedModuleCreate=='yes'&&$this->frommdouleFocus->id>0)
                    {
                        $info['entityname']=getModuleHref($this->frommdouleFocus->moduleName,$this->frommdouleFocus->id);
                        $info['id']=$this->frommdouleFocus->id;
                    }
                    else
				    {
				        
				        	 
		                   $info = getLineitemModuleInfo($lineitem_id,$this->productToolFieldsValues[$i]['entitytype']);
				    }
					$value = $info['entityname'];
					if(!empty($info['entityname'])){
						$selectproducthidden = 1;
					}
					if($uitype == '204'){
						$tableContent .= '<input type="hidden" columnname="'.$columnname.'" id="'.$columnname.'"  detailcolumnname="'.$columnname.'" name="'.$columnname.'" value="'.getSalesEntityType($info['id']).'">';
						if(empty($ProductToolFieldsInfos['producttoolfield_info'][$columnname])){
							$tableContent .= '<span style="display:none;"  name="span_'.$columnname.'"  id="span_'.$columnname.'" detailcolumnname="span_'.$columnname.'">'.getTransTab(getSalesEntityType($info['id'])).'</span>';
                        }
					}else{
						/*
						* hidden_lineitem_id:单据自己的lineitem_id
						* selectproducthidden：1为有源单 0 没有
						* selectSourceModuleid：选择的源单ID
						* lineitem_id：选择的源单单据的lineitem_id
						*/
                        
						$tableContent .='<input type="hidden" name="hidden_lineitem_id" detailcolumnname="hidden_lineitem_id" id="hidden_lineitem_id"  value="'.$col_info['lineitem_id'].'" />';
						$tableContent .='<input type="hidden" name="selectproducthidden" detailcolumnname="selectproducthidden"  value="'.$selectproducthidden.'" />';
						$tableContent .='<input  type="hidden" value="'.$info['id'].'" name="selectSourceModuleid" detailcolumnname="selectSourceModuleid">
										<input  type="hidden" value="'.$lineitem_id.'" name="lineitem_id" id="lineitem_id" detailcolumnname="lineitem_id">
										<input type="hidden"  name="'.$columnname.'" id="'.$columnname.'" detailcolumnname="'.$columnname.'" value="'.$info['id'].'">';
						if(empty($ProductToolFieldsInfos['producttoolfield_info'][$columnname])){
							$tableContent .= '<span style="display:none;"  name="span_'.$columnname.'" id="span_'.$columnname.'" detailcolumnname="span_'.$columnname.'">'.$value.'</span>';	
						}
					}
				}

			}
        
         
			
			foreach($ProductToolFieldsInfos['producttoolfield_info'] as $column_value){
				foreach($column_value as $column => $value){
					$productinfo[$column] = $value;
				}
				$uitype = $productinfo['uitype'];
				$columnname = $productinfo['columnname'];
				$controlbol = $columnname;//$columnname.$rowid;//columnname
				
			}
		
			//获取源单的lineitem_id 用户退货、退款，没有源单列的明细模块
			$tableContent .= $this->lineitemid_html($this->productToolFieldsValues[$i],$rowid);
			if($this->productdetail_mode !='details' || $this->module == 'WorkSheet'){//查看界面没有“删除”或者上下移动的按钮
				$tableContent .='<td style="display:none"></td>';//隐藏操作列
			}

            $tableContent .= $this->getRowcommon_content($rowid,$productinfo['repaired']);//序号
            if($this->producttype=='part'){
                if($productinfo['related_productid']>0){
                    $this->related_productid = $productinfo['related_productid'];
                }
                $tableContent .= $this->getRelatedProductContent();
            }
			foreach($ProductToolFieldsInfos['producttoolfield_info'] as $column_value){
                foreach($column_value as $column => $value){
					$productinfo[$column] = $value;
				}
				$productinfo['rowid'] = $rowid;
                $columnname = $column_value['columnname'];
                if(!$this->check_productcolumn($columnname)){
                    continue;
                }
                
                //edit:can 20200730 获取套餐信息
                $productinfo['productbomid']=$this->ProductDetailsData->rowColumnInfo[$rowid-1]['productbomid'];
                $productinfo['productbomquantity']=$this->ProductDetailsData->rowColumnInfo[$rowid-1]['productbomquantity'];
                
                $tablename=$column_value['tablename'];
                if($columnname=='discount_amount'&&$tablename==$ld_inventoryproductrel)
                {
                   
                    //33936: （1.6登录）合同订单模块：单据分录定制合同订单模块启用“折扣额”，合同订单新建界面没有显示“折扣额”字段
                    $productinfo['controlbol'] ='discount_amount';// 'discount_amount' . $rowid;
                    $columnname="productdetail_discount_amount";
                    
                }
                else
				$productinfo['controlbol'] = $columnname . $rowid;
             
                
                if(!empty($this->ProductDetailsData->presenceToolField[$columnname])){
                            if($deploy_values['deploy_value'] == $columnname){
        					$base_column = 'yes';
                            
        				}
                     
                    $fieldinfo = $this->ProductDetailsData->presenceToolField[$columnname];
                    
                    $showvalue = $this->getValueByUitype($fieldinfo, $column_value, $productinfo);

                    //创建单元格
                    $tableContent .= $this->getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);//创建单元格
                    
                }

			}
            
            if($this->producttype=='product'){
                $tableContent .= $this->addSourseinfo($i);
            }
            
		
            //计算公式基准字段隐藏、或者没有权限
			if($base_column == 'no'){
			
			//	$tableContent .='<input type="hidden" name="'.$deploy_values['deploy_value'].$rowid.'"  value="0" />';
                	$tableContent .='<input type="hidden" name="'.$deploy_values['deploy_value'].'"  value="0" />';
			}
            $tableContent .='<input type="hidden" name="before_lineitem_id"  id="before_lineitem_id"  detailcolumnname="before_lineitem_id" value="'.$productinfo['lineitem_id'].'" />';
			$tableContent .='</tr>';
            $this->tablecontents[]=$tableContent;
            
            
		}
 
        $tableContent=implode(' ',$this->tablecontents);

		return $tableContent;
	}
    //分录固定列
   	public function getRowcommon_content($rowid,$repaired){
   	    if($this->productdetail_mode == 'details'){
   	        if($this->producttype == 'part'){
   	            $content = '<td style="text-align:center;width:15mm" >'.$rowid.'</td>';
   	        }else{
   	            $content = '<td style="text-align:center;width:15mm" >'.$rowid.'</td>';
                /*
                if($repaired=='yes'){
                    $content .= '<td style="text-align:center;width:15mm;" ><input disabled="" name="repaired" id="repaired" type="checkbox" onclick="reportrepair('.$rowid.',this)" checked="checked" ></input>'.'</td>';
                }else{
                    $content .= '<td style="text-align:center;width:15mm;" ><input disabled="" name="repaired" id="repaired" type="checkbox" onclick="reportrepair('.$rowid.',this)" ></input>'.'</td>';
                }*/
   	        }
   	        
   	    }else{
   	        if($this->producttype == 'part'){
   	            $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm" ><a name="deletepart" id="deletepart" onclick="deletepart('.$rowid.')" class="ld-text-inner ld-text-inner-first" style="cursor:pointer;">'.getFixedLabel('DELETE').'</a></td>';
           	    $content .= '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm" ><span class="ld-text-inner ld-text-inner-first">'.$rowid.'</span></td>';
            }else{
                if($repaired=='yes'){
                    $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><a name="changepart" id="changepart" onclick="changepart('.$rowid.')" class="ld-text-inner ld-text-inner-first" style="cursor:pointer;">'.getFixedLabel('REPLACEACCESSORIES').'</a></td>';
               	    $content .= '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><span class="ld-text-inner ld-text-inner-first">'.$rowid.'</span></td>';
                }else{
                    $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><a name="changepart" id="changepart" onclick="changepart('.$rowid.')" class="ld-text-inner ld-text-inner-first" style="cursor:pointer;">'.getFixedLabel('REPLACEACCESSORIES').'</a></td>';
               	    $content .= '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><span class="ld-text-inner ld-text-inner-first">'.$rowid.'</span></td>';
                }
            }
        }
		return $content;
	}
    
    public function getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue){
        if($this->producttype=='part'){
            
        }else{
            //报修产品信息不允许编辑
            if($productinfo['columnname']!='productname'){
                $productinfo['edit_perssion']=1;
                $fieldinfo->edit_permission(1);
            }
        }
        
        $table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
        return $table;
    }
    
    //获取配件分录信息 已停用
    public function getProductPartHtml($focus,$type){
        //重新计算宽度
        $this->producttype = 'product';
        $this->resetwidth();

        if($this->productdetail_mode == 'details'){
				$table .="<tr>
				        <td>
	                		<div class='DivCName DivCNamehover' onclick=showHideStatus('partStaus','partjuctscol')><span class='' id='partjuctscol'></span>"."配件信息";
                
				$table .="	</div>
                		</td>
                	</tr>
                	<tr>
                		<td id='partStaus' style='display:block;'>";
        }
        $table .= '<div name="partDiv" class="popDetailTable" style="overflow-x: auto; overflow-y: hidden;width:'.$this->width.'mm;" >';
        $table .=' <table class=""  name="partTab" style="width:100%;" border="0" align="center" cellpadding="0" cellspacing="0"> ';
        $productToolMore = count($this->product_columnname_arr)+2;
        if($this->productdetail_mode != 'details'){
            $table .='<tr align="left">';
    		$table .='<th colspan="2" class="editrelhead">'.getFixedLabel('REPAIRPRODUCTS') .'</th>';
    		$table .='<th align="left" colspan="'.$productToolMore.'" class="editrelhead"></tr>';
        }
        
        $table .= $this->getProductHtmlHeader();//列头
        $table .= $this->getProductHtmlContent();//中间行

        $table .= '</table>';
        $table .= '</div>';
        
        
        if($this->productdetail_mode == 'details'){
            $table .= '</td></tr>';
        }
        
        return $table;
    }
    
    //判断该字段是否显示
    public function check_productcolumn($columnname){
        if($this->producttype == 'part'){
            if(!in_array($columnname,$this->notpart_columnname_arr)){
                return true;
            }
        }else{
            return true;
            if(in_array($columnname,$this->product_columnname_arr)){
                return true;
            }
        }
        return false;
    }
    //获取配件关联产品列头
    public function getRelatedProductHeader(){
        if($this->producttype=='part'){
            $fieldlabel_arr = array('productname'=>'原产品名称','product_no'=>'原产品编号');
            foreach($this->productToolTr as $productToolFieldInfo){
    			if($productToolFieldInfo->getNewLine() == 1)continue;
    			$typeofdata = explode('~',$productToolFieldInfo->getTypeOfData());
    			$width=$productToolFieldInfo->getWidth();
                $columnname=$productToolFieldInfo->getColumnName();
                if(!in_array($columnname,$this->related_columnname_arr)){
                    continue;
                }

                $fieldlabel = $fieldlabel_arr[$columnname];
   				$table .='<td class="ld-form-item-content-entrytitle" head_width="'.$width.'" head_detailfieldname="'.$columnname.'" name="productdetails_header_'.$productToolFieldInfo->getColumnName().'" style="width:'.$width.'mm;'.$display.'"><font color="red" style="display:none" class="td_required_'.$productToolFieldInfo->getColumnName().'">*</font>'.$fieldlabel.'</td>';	
    		}
            return $table;
        }
    }
    
    public function getRelatedProductContent(){
        global $adb;
        $record = $this->related_productid;
        if($record>0){
            $columnname_str = implode(',',$this->related_columnname_arr);
            $sql = "select $columnname_str from ld_products where productid = ? and deleted = 0;";
            $result = $adb->pquery($sql,array($record));
        }

        $table = "";
        foreach($this->productToolTr as $productToolFieldInfo)
        {
            if($productToolFieldInfo->getNewLine() == 1)continue;
            $columnname=$productToolFieldInfo->getColumnName();
            if(!in_array($columnname,$this->related_columnname_arr))continue;
            $new_columnname = 'part_'.$columnname;
            if($record>0){
                $column_value = $adb->query_result($result,0,$columnname);
            }
            $table.='<td class="ld-form-item-content-entry">';
            if($columnname == 'productname'){
                $table .= '<input type="hidden" name="relatedProductId" id="relatedProductId" value='.$record.' />';
            }
            $table .= '<span class="ld-text-inner ld-text-inner-first" type="hidden" detailcolumnname="'.$new_columnname.'" columnname="'.$new_columnname.'"> '.$column_value.'<span/>';
            $table.='</td>';
        }
        /*
        foreach($this->related_columnname_arr as $key=>$columnname){
            if(!in_array($columnname,$this->productToolTr))continue;
            $new_columnname = 'part_'.$columnname;
            if($record>0){
                $column_value = $adb->query_result($result,0,$columnname);
            }
            $table.='<td>';
            if($columnname == 'productname'){
                $table .= '<input type="hidden" name="relatedProductId" id="relatedProductId" value='.$record.' />';
            }
            $table .= '<span type="hidden" detailcolumnname="'.$new_columnname.'" columnname="'.$new_columnname.'"> '.$column_value.'<span/>';
            $table.='</td>';
        }
        */
        return $table;
    }
    
    public function resetwidth(){
        //重新计算宽度
        $this->width = 0;
        foreach($this->ProductDetailsData->presenceToolField as $columnname => &$productToolFieldInfo){         
			if($productToolFieldInfo->getNewLine() == 0 && $this->check_productcolumn($columnname)){
				//计算明细表宽度
				$this->width += $productToolFieldInfo->getWidth();
                if(in_array($columnname,$this->related_columnname_arr) && $this->producttype == 'part'){
                    $this->width += $productToolFieldInfo->getWidth();
                }
			}
		}
        $this->width += 45;//第一列操作行宽度
        if($this->width < 255)$this->width = 255;
    }
    //判断分录明细是否需要显示
    public function checkdisplay(){
        if($this->productdetail_mode =='create'){
            return 'display:none';
        }
        if($this->productdetail_mode =='sourcemodule_create'){
            return 'display:block';
        }
        $num_row = 0;
        $this->productToolFieldsValues = $this->getProductHtmlContentDbValue();
        foreach($this->productToolFieldsValues as $key=>$productinfo){
            if($this->producttype=='product'&&$productinfo['repaired']!=""){
                $num_row ++;
            }
            if($this->producttype=='part'){
                $num_row ++;
            }
        }

        if($num_row>0){
            return 'display:block';
        }else{
            return 'display:none';
        }
    }
    
    //报修产品分录需要另外添加列头
    public function addSourseHeader(){
        if($this->productdetail_mode =='sourcemodule_create'){
            return '';
        }
        $focus = CRMEntity::getInstance('WorkSheet');
        $productToolTr = $this->getDetailobjbyEntitytype($this->module)->ProductDetailsData->getProductToolTrData($focus,$this->productdetail_mode);
        $columnname_arr = array('entitytype','entitytypeid');
        foreach($productToolTr as $productToolFieldInfo){
            
			$typeofdata = explode('~',$productToolFieldInfo->getTypeOfData());
			$width=$productToolFieldInfo->getWidth();
            $columnname=$productToolFieldInfo->getColumnName();

            if(!in_array($columnname,$columnname_arr)){
                continue;
            }
            
            $fieldname=$productToolFieldInfo->getFieldName();
            if(is_array($this->fieldrulerequirecolumn_arr)&&in_array($columnname,$this->fieldrulerequirecolumn_arr))
            {
                $typeofdata[1]='M';
            }
            $display='';
            if(is_array($this->fieldruleHideColumn_arr)&&in_array($columnname,$this->fieldruleHideColumn_arr)){
                //edit:can 20200721 布局规则
                $display=" display:none;";
            }
            $fieldlabel = $productToolFieldInfo->getFieldLabel();
            
            $table .='<td class="ld-form-item-content-entrytitle" head_width="'.$width.'" head_detailfieldname="'.$columnname.'" name="productdetails_header_'.$productToolFieldInfo->getColumnName().'" style="width:'.$width.'mm;'.$display.'"><font color="red" style="display:none" class="td_required_'.$productToolFieldInfo->getColumnName().'">*</font>'.$fieldlabel.'</td>';	
			
		}
        return $table;
    }
    
    //报修产品分录需要添加信息
    public function addSourseinfo($i){
        if($this->productdetail_mode =='sourcemodule_create'){
            return '';
        }
        $ProductToolFieldsInfos = $this->getDetailobjbyEntitytype($this->module)->ProductDetailsData->getProductToolFieldsInfos($this->productToolFieldsValues[$i],$this->frommdouleFocus,$this->productdetail_mode);
        $columnname_arr = array('entitytype','entitytypeid');
        $producttoolfield_info = $ProductToolFieldsInfos['producttoolfield_info'];
        $productinfo = $ProductToolFieldsInfos['productdetail_value'];

        $table = "";        

        foreach($producttoolfield_info as $column_value){   
            foreach($column_value as $column => $value){
                
				$productinfo[$column] = $value;
             
			}
            $columnname = $productinfo['columnname'];

            // if(!in_array($columnname,$columnname_arr)){
            //     continue;
            // }
            
            $fieldinfo = $this->getDetailobjbyEntitytype($this->module)->ProductDetailsData->presenceToolField[$columnname];     

            if($fieldinfo != NULL) 
            {$showvalue = $this->getValueByUitype($fieldinfo,$column_value, $productinfo);
 
            $table .= $this->getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
            }//创建单元格

        }
        
        return $table;
    }
    //移动端报修产品明细-详情页
    public function getMobileSpecialDetail($action){

        $this->producttype = 'product';
        $this->productToolFieldsValues = $this->getProductHtmlContentDbValue(); 
		$this->productrows = count($this->productToolFieldsValues);//计算产品明细的行数
        if($this->productrows==0){
            return '';
        }
        $this->ProductDetailsData = crm_load_class_obj('cls_Common_DetailsData', "modules/WorkSheet/ProductDetails", array($this->module));

        $all_productvalue_arr = array();
        for($i = 0; $i<$this->productrows; $i++){
            $ProductToolFieldsInfos = $this->ProductDetailsData->getProductToolFieldsInfos($this->productToolFieldsValues[$i],$this->frommdouleFocus,$this->productdetail_mode);
            $producttoolfield_info = $ProductToolFieldsInfos['producttoolfield_info'];
            $productinfo = $ProductToolFieldsInfos['productdetail_value'];
            $productvalue_arr = array();
            $productvalue_arr['id'] = $productinfo['productid'];
            $productvalue_arr['repaired'] = $productinfo['repaired'];
            $productvalue_arr['label'] = "产品名称";
            $entitytype = $producttoolfield_info['entitytype']['column_value'];

            foreach($producttoolfield_info as $column_value){
                $fieldvalue_arr =array();
                foreach($column_value as $column => $value){
					$productinfo[$column] = $value;
				}
				$productinfo['rowid'] = $rowid;
                $columnname = $column_value['columnname'];
                // if(!$this->check_productcolumn($columnname)){
                //     continue;
                // }
				$productinfo['controlbol'] = $columnname . $rowid;
                if($columnname == 'discount_amount'){//折扣额需要转换columnname
                    $columnname = 'productdetail_discount_amount';
                }
                $tmp_value = $column_value['column_value'];

                if(!empty($this->ProductDetailsData->presenceToolField[$columnname])){
                    $fieldinfo = $this->ProductDetailsData->presenceToolField[$columnname];
                    
                    // if($column_value == 'listprice')
                    $headerInfo = $fieldinfo;
                    if(!empty($action)) {
                        if($headerInfo->getDetailsFieldsProfile($this->pagetype_actionarray[$action]) != 'hidden'){//保修产品分录根据源单单据字段权限显示
                            $showvalue = $this->getValueByUitype($fieldinfo, $column_value, $productinfo);
                            if($columnname == 'productdetail_discount_amount'){
                                $columnname = 'discount_amount';
                            }
                            $fieldvalue_arr['k'] = $fieldinfo->getFieldLabel();
                            $fieldvalue_arr['v'] = $showvalue['value'];
                            if($columnname == 'entitytypeid'){
                                $fieldvalue_arr['m'] = $entitytype;
                                $fieldvalue_arr['v'] = getModuleHref($entitytype,$tmp_value);
                                if($fieldinfo -> get_ShowHyperlinks() == 'yes')
                                    $fieldvalue_arr['p'] = 'yes';
                                $fieldvalue_arr['i'] = $tmp_value;
                                $fieldvalue_arr['l'] = getTranstab($entitytype);
                            }
                            if($columnname == 'productname' && $fieldinfo -> get_ShowHyperlinks() == 'yes'){
                                $fieldvalue_arr['p'] = 'yes';
                            }
                        }else{
                            continue;
                        }
                    }
                }
                $productvalue_arr['list'][] = $fieldvalue_arr;
			}
            $all_productvalue_arr[] = $productvalue_arr;
		}
        return $all_productvalue_arr;
    }
    
    //移动端报修产品明细-新增编辑
    public function getMobiledetail_editview($action=''){

        $this->producttype = 'product';
        $this->productToolFieldsValues = $this->getProductHtmlContentDbValue();
        
		$this->productrows = count($this->productToolFieldsValues);//计算产品明细的行数
        
        if($this->productrows==0){
            return '';
        }
        $all_productvalue_arr = array();
        for($i = 0; $i<$this->productrows; $i++){
            $ProductToolFieldsInfos = $this->ProductDetailsData->getProductToolFieldsInfos($this->productToolFieldsValues[$i],$this->frommdouleFocus,$this->productdetail_mode);
            $producttoolfield_info = $ProductToolFieldsInfos['producttoolfield_info'];
            
            $productinfo = $ProductToolFieldsInfos['productdetail_value'];
            $fieldvalue_arr =array();
            $fieldinfo_arr = array();
            $fieldvalue_arr['productid'] = array('value'=>$productinfo['productid'],'hiddenvalue'=>$productinfo['productid']);
            $fieldvalue_arr['detailid'] = array('value'=>$productinfo['parent_lineitem_id'],'hiddenvalue'=>$productinfo['parent_lineitem_id']);
            //$productvalue_arr['id'] = $productinfo['productid'];
//            $productvalue_arr['repaired'] = $productinfo['repaired'];
//            $productvalue_arr['label'] = "产品名称";
            $entitytype = $producttoolfield_info['entitytype']['column_value'];
            foreach($producttoolfield_info as $column_value){
                
                foreach($column_value as $column => $value){
    				$productinfo[$column] = $value;
    			}
                $columnname = $productinfo['columnname'];

                // if(!$this->check_productcolumn($columnname)){
                //     continue;
                // }
                if($columnname == 'discount_amount'){
                    $columnname = 'productdetail_discount_amount';
                }
                if(!empty($this->ProductDetailsData->presenceToolField[$columnname])){

                    $fieldinfo = $this->ProductDetailsData->presenceToolField[$columnname];
                    if($fieldinfo->getBigtype() == 'image' || $fieldinfo->getBigtype() == 'fileattachment'){
                        continue;
                    }
                    $showvalue = $this->getValueByUitype($fieldinfo, $column_value, $productinfo);
                    //$fieldvalue_arr['k'] = $fieldinfo->getFieldLabel();
//                    $fieldvalue_arr['v'] = $showvalue['value'];
//                    if($columnname == 'productname'){
//                        $fieldvalue_arr['p'] = 'yes';
//                    }
                    $tmp_value = $column_value['column_value'];
                    $fieldinfo_arr[] = $this->getMobileFieldinfo($fieldinfo);
                    if($columnname == 'productdetail_discount_amount'){
                        $columnname = 'discount_amount';
                    }
                    $headerInfo = $fieldinfo;
                    
                    if(!empty($action)) {
                        if($headerInfo->getDetailsFieldsProfile($this->pagetype_actionarray[$action]) != 'hidden'){
                            $fieldvalue_arr[$columnname] = array('value'=>$showvalue['value'],'hiddenvalue'=>$showvalue['rawvalue']);
                            if($columnname == 'entitytypeid'){
                                $fieldvalue_arr[$columnname]['m'] = $entitytype;
                                $fieldvalue_arr[$columnname]['v'] = getModuleHref($entitytype,$tmp_value);
                                if($fieldinfo -> get_ShowHyperlinks() == 'yes')
                                    $fieldvalue_arr[$columnname]['p'] = 'yes';
                                $fieldvalue_arr['i'] = $tmp_value;
                                $fieldvalue_arr['l'] = getTranstab($entitytype);
                            }
                        }else{
                            continue;
                        }
                    }
                }
			}
            $productvalue_arr[] = $fieldvalue_arr;
		}
        $all_productvalue_arr['worksheetlist'] = $productvalue_arr;
        $all_productvalue_arr['worksheetlistfield'] = $fieldinfo_arr;

        return $all_productvalue_arr;
    }
    public function getMobileFieldinfo($producttoolfield)
    {
        $fieldinfo_arr= array();
        $fieldinfo_arr['producttoolfieldid'] = $producttoolfield->getProductToolFieldid();
        $fieldinfo_arr['columnname'] = $producttoolfield->getColumnName();
        $fieldinfo_arr['typedata'] = $producttoolfield->getTypeOfData();
        $fieldinfo_arr['width'] = $producttoolfield->getWidth();
        $fieldinfo_arr['edit_permission'] = $producttoolfield->getEdit_permission();
        $fieldinfo_arr['defaultvalue'] = $producttoolfield->getDefaultvalue();
        $fieldinfo_arr['uitype'] = $producttoolfield->getUIType();
        $fieldinfo_arr['fieldlabel'] = $producttoolfield->getFieldLabel();
        $fieldinfo_arr['tablename'] = $producttoolfield->getTableName();
        $fieldinfo_arr['input_type'] = $producttoolfield->getinput_type();
        $fieldinfo_arr['newline'] = $producttoolfield->getNewLine();
        $fieldinfo_arr['defaultcolumn'] = $producttoolfield->getDefaultColumn();
        $fieldinfo_arr['columnstring']=$producttoolfield->getColumnString();
        $fieldinfo_arr['formulastring']=$producttoolfield->getFormulaString();
        $fieldinfo_arr['reverseinfo']=$producttoolfield->getreverseinfo();
        
        $fieldinfo_arr['fieldid']=$producttoolfield->getFieldid();
        $fieldinfo_arr['nullfield']=$producttoolfield->getNullField();
        $fieldinfo_arr['allowhide']=$producttoolfield->getAllowHide();
		$fieldinfo_arr['bigtype']=$producttoolfield->getBigType();
        $fieldinfo_arr['relatedmodulefield']=$producttoolfield->getRelatedModuleField();
		$fieldinfo_arr['savedatabase']=$producttoolfield->getSaveDataBase();
		$fieldinfo_arr['referencemodule']=$producttoolfield->getReferenceModule();
        $fieldinfo_arr['parentbigtype']=$producttoolfield->getParentBigType();
        $fieldinfo_arr['fieldvaluecolor']=$producttoolfield->getFieldValueColor();
        $fieldinfo_arr['fieldplaceholder']=$producttoolfield->getFieldPlaceholder();
        return $fieldinfo_arr;
    }
}
?>