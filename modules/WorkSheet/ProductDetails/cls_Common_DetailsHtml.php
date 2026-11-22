<?php
crm_load_class_file('Parent_ProductDetailsHtml','include/ProductDetailsHtml');
class cls_Common_DetailsHtml extends Parent_ProductDetailsHtml{
    
    public function __construct($module){
        parent::__construct($module);
        $this->module = $module;
        $this->frommdouleFocus = CRMEntity::getInstance($module); 
        $this->ProductDetailsData = crm_load_class_obj('cls_Common_DetailsData',"modules/WorkSheet/ProductDetails",array($module));  
        $this->producttype = 'product';
    }
    
    public function create_html($productdetail_mode=''){
        $frommdoulefocus = $this->frommdouleFocus;
        $this->ProductDetailsData->record = $this->record;
        $frommdoulefocus->mode = $productdetail_mode;
        $frommdoulefocus->id = $this->record;
        $table = $this->getProductDetailsHtml($frommdoulefocus,$productdetail_mode);
        return $table;
    }
    
    public function checkdisplay(){
        return 'display:block';
    }
    //获取明细列头
    public function getProductHtmlHeader()
    {
        $detail_issticky = getTabdetail_issticky($this->module);//zxm 20230808 通过查表获得冻结列数,放在表头trhead上告诉js我冻结到第几列-- todo--
        $table = '<tr class="Tdhead" tag="trhead" data-stickyindex="'.$detail_issticky.'" style="position: sticky; top: 0px; background-color: rgba(0, 0, 0, 0); z-index: 100000;">';
        $table .= $this->getProductHtmlHeaderNotr();

        $table .= '</tr>';
        return $table;
    }
    
    public function getRowNo_header(){
        if($this->productdetail_mode == 'details'){
            $header = '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">#</td>';
            if($this->producttype!='part'){
                //$header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">'.getFixedLabel('WHETHERTOREPAIR').'</td>';
            }
        }else{
            if($this->producttype == 'part'){
                $header = '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:25mm" text-align="center">'.getFixedLabel('OPERATING').'</td>';
                $header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">#</td>';
            }else{
                $header = '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:30mm" text-align="center">'.getFixedLabel('OPERATING').'</td>';
                $header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:10mm" text-align="center">#</td>';
                //$header .= '<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="25" style="width:15mm" text-align="center">'.getFixedLabel('WHETHERTOREPAIR').'</td>';
            }
        }
		return $header;
	}

    public function getRowNo_content($rowid)
    {
        if ($this->productdetail_mode == 'details') {
            if ($this->producttype == 'part') {
                $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm" >' . $rowid . '</td>';
            } else {
                $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm" >' . $rowid . '</td>';
            }
        } else {
            if ($this->producttype == 'part') {
                $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm" ><a name="deletepart" id="deletepart" onclick="deletepart(' . $rowid . ')" class="ld-text-inner ld-text-inner-first" style="cursor:pointer;">' . getFixedLabel('DELETE') . '</a></td>';
                $content .= '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm" ><span class="ld-text-inner ld-text-inner-first">' . $rowid . '</span></td>';
            } else {
                if ($repaired == 'yes') {
                    $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><a name="changepart" id="changepart" onclick="changepart(' . $rowid . ')" class="ld-text-inner ld-text-inner-first" style="cursor:pointer;">' . getFixedLabel('REPLACEACCESSORIES') . '</a></td>';
                    $content .= '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><span class="ld-text-inner ld-text-inner-first">' . $rowid . '</span></td>';
                } else {
                    $content = '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><a name="changepart" id="changepart" onclick="changepart(' . $rowid . ')" class="ld-text-inner ld-text-inner-first" style="cursor:pointer;">' . getFixedLabel('REPLACEACCESSORIES') . '</a></td>';
                    $content .= '<td class="ld-form-item-content-entry" style="text-align:center;width:15mm;" ><span class="ld-text-inner ld-text-inner-first">' . $rowid . '</span></td>';
                }
            }
        }

        return $content;
    }
    public function getProductHtmlSubTotalTr(){
        return '';
    }
    public function getAddProductDetailBtn(){
        return '';
    }
    public function getProductHtmlLastContent(){
        return '';
    }

    public function getProductDetailsHtml($frommdoulefocus,$productdetail_mode=''){
		$this->frommdouleFocus = $frommdoulefocus;
        $this->productdetail_mode = $productdetail_mode;
        $this->getPageType();
        $withproductdetail='yes';
        $display = $this->checkdisplay();
        // $this->resetwidth();
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
			$this->width -= 30;
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
                    $table .= " onclick=showHideStatus('newproductsStaus','newprojuctscol')><span class='' id='newprojuctscol'></span>";
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
				    $table .="	</div></td></tr><tr><td id='newproductsStaus' name='newproductsStaus' style='".$display."' >";
                }else{
                    $table .="";
				    $table .="	</div></td></tr><tr><td id='productsStaus' style='".$display."' >";
                }
                
			}

			//外贸行业
			if($this->systemMethod['isrmbproduct'] == 1){
				$table .='<input  type="hidden" name="rmbproduct" value="">';
			}
			//产品套餐
			if($this->module == 'Productbom'){
				$table .='<input  type="hidden" name="bomproduct" value="">';
			}
            
			$table .= '<input  type="hidden" name="module_nullfield" value="'.implode('##',$this->ProductDetailsData->module_productnullfield).'">';
			$table .='<input  type="hidden" name="addproductrow" value="'.$this->systemMethod['addproductrow'].'">';//设置产品分录中最后一行选择产品后是否自动新增一个空行
			$table .='<input  type="hidden" name="productToolField" value="'.$this->ProductDetailsData->alltypeofdata.'">';//当前模块的所有自定义字段信息
			$table .='<input type="hidden" name="lengthdecimaldigits" value="'.$this->systemMethod['lengthdecimaldigits'].'">';//系统参数数量小数位控制
            $table .='<input type="hidden" name="lengthprice" value="'.$this->systemMethod['lengthprice'].'">';//系统参数单价小数位控制            
			$table .='<input  type="hidden" name="isrmbproduct" value="'.$this->systemMethod['isrmbproduct'].'">';//行业
			if($this->producttype=='part'){
                $table .='<div name="productDiv" id="productDiv" class="popDetailTable"  style="overflow-x: auto; overflow-y: hidden;min-height:0%;'.$display.'">';//横向拖动div
                $table .='<table  class="" id="proTab" name="proTab" style="width:'.$this->width.'mm;" border="0" align="center" cellpadding="0" cellspacing="0">';
                $table .='<input type="hidden"  name="table_width" value="'.$this->width.'">';
            }else{  
                $tmp_width = 0;
                foreach($this->productToolTr as $key => $productToolFieldinfo){
                    $tmp_width += $productToolFieldinfo->getWidth();
                }
                $table .='<div name="newproductDiv" id="newproductDiv" class="popDetailTable" style="overflow-x: auto; overflow-y: auto;max-height: 400px;min-height:0%;'.$display.'">';//横向拖动div
                $table .='<table class="" id="newproTab" name="newproTab" style="width:'.$tmp_width.'mm;" border="0" align="center" cellpadding="0" cellspacing="0">';
                $table .='<input type="hidden"  name="table_width" value="'.$tmp_width.'">';
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
    				$table .='<th colspan="3" class="ld-from-headblock-title" style="position: sticky;left: 0px;">' .getFixedLabel('ACCESSORYINFORMATION') . '</th>';
    				$table .='<th colspan="'.$productToolMore.'" class="ld-from-headblock-title">';
                }else{
                    $productToolMore = count($this->productToolTr)+2;
                    $table .='<tr class="ld-from-headblock-entry" style="position: sticky; top: 0px;z-index: 100000;">';
    				$table .='<th colspan="3" class="ld-from-headblock-title" style="position: sticky;left: 0px;">' .getFixedLabel('REPAIRPRODUCTS') . '</th>';
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
			$table .='</table>';
			$table .='</div>';
		}
        
		if($this->productdetail_mode == 'details'){
			$table .='</td></tr>';
		}
        
		return $table;
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
        if(!empty($productinfo['parent_lineitem_id']) && empty($productinfo['lineitem_id'])){
            $productinfo['lineitem_id'] = $productinfo['parent_lineitem_id'];
        }

        $table = parent::getProductToolFieldEditTd($productinfo,$fieldinfo,$showvalue);
        return $table;
    }
}
?>