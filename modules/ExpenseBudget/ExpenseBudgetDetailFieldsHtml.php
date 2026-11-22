<?php
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
	crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
	Class ExpenseBudgetDetailFieldsHtml extends cls_TabDetailFieldsHtml {
        public $calculationData;
        public $isCalculation;
		function __construct($focus,$module,$calculationData=[],$isCalculation='no'){
		    parent::__construct($focus,$module);
		    $this->calculationData = $calculationData;
            $this->isCalculation = $isCalculation;
		}
		/**
		 * 获取佣金单明�?
		 * @param $entitytypeid 源单id,相关信息、创建创建会用到
		 * @return
		 * @author Chj
		 */
		public function getTabDetailFieldsHtml($entitytypeid=''){
            $table_fixed_style = '';
			if($this->focus->mode == 'Details'){
				$table = '<table border="0" width="100%" cellspacing="0" cellpadding="0"><tbody>';
				$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span name="projuctscol" class=""></span>' . getTranstab('ExpenseBudget') . '</div></th>';
                $table .="<tr>
                		<td name='productsStaus' style='display:block;'>";
                $table_fixed_style = 'table-layout:fixed;word-break: break-all; word-wrap: break-word;';//xxy 2023-11-16 表格固定    		
			}
			$this->entitytypeid = $entitytypeid;
            
			$table .='<input  type="hidden" name="nullfield" value="'.implode('##',$this->tabDetailFieldData->module_nullfield).'">';//当前模块空行基准字段
			$table .='<input  type="hidden" name="addproductrow" value="'.$this->TabDetailFieldsHtmlTd->addproductrow.'">';//设置产品分录中最后一行选择产品后是否自动新增一个空�?
			$table .='<input  type="hidden" name="alltypeofdata" value="'.$this->alltypeofdata.'">';//当前模块的所有自定义字段信息
			$table .='<input  type="hidden" name="lengthdecimaldigits" value="'.$this->TabDetailFieldsHtmlTd->lengthdecimaldigits.'">';//系统参数数量小数位控�?
			$table .='<input  type="hidden" name="lengthprice" value="'.$this->TabDetailFieldsHtmlTd->lengthprice.'">';//系统参数单价小数位控�?
            //ls 2022-07-22 带分录的表单，单据新建/编辑/复制界面，单据表体增加众向列头固定
            if($this->focus->mode != 'Details'){
                $table .='<div class="ld-from-headblock-title">';
                $alinkhtml = '';
                if($this->focus->budgetType!='basicBudget'){
                    $alinkhtml = '<a style="margin-left:20px;font-size:12px;" href="javascript:void(0);" onclick="ExpenseBudgetObj.calculationBudget()">'.getFixedLabel('CalculateBudgetData').'</a>';
                }
                $table .='<span><b>' . getTranstab('ExpenseBudget') .$alinkhtml . '</b></span>';
                $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
                $table .='</div>';
            }
			$table .='<div name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
			$table .='<table id="expenseBudgetDetails" class="" id="proTab" name="proTab" style="width:'.$this->table_width.'mm;'.$table_fixed_style.'" border="0" align="center" cellpadding="0" cellspacing="0">';
			$table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
            $table .='<input type="hidden"  name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
			/*if($this->focus->mode != 'Details'){
			    $alinkhtml = '';
			    if($this->focus->budgetType!='basicBudget'){
                    $alinkhtml = '<a style="margin-left:20px;font-size:12px;" href="javascript:void(0);" onclick="ExpenseBudgetObj.calculationBudget()">'.getFixedLabel('CalculateBudgetData').'</a>';
                }
				$table .='<tr align="left">';
				$productToolMore = count($this->tabDetailFieldData->tabPresenceDetailFields) + 2 + $this->tabDetailFieldData->sourcmodule_td;//列头合并�?+2 表示操作列、序号列 + 源单�?每一个源单占2�?
				$table .='<th colspan="'.$productToolMore.'"><div class="editrelhead" style="padding-left: 0px;">' . getTranstab('ExpenseBudget') .$alinkhtml. '</div></th>';
				$table .='</tr>';
			}*/
            if($this->focus->mode != 'Details'){
                $table .='<tr></tr>';
            }
            $table .=$this->getTabDetailHtmlHeader();
			$table .=$this->getTabDetailHtmlContent();
			$table .=$this->getTabDetailHtmlSubTotalTr();
           
			$table .='</table>';
			$table .='</div>';
			$table .=$this->getTabDetailHtmlTotalTr();
			if($this->focus->mode == 'Details'){
				$table .='</td></tr>';
				$table .='</tbody></table>';
			}
			return $table;
		}

        public function getTabDetailHtmlHeader(){
            global $current_user;
            $table = '';
            $table .='<tr class="Tdhead" tag="trhead">';
            if($this->focus->mode !='Details' && $this->operation_row === 0){//查看界面没有工具列
                $table .='<td class="ld-form-item-content-entrytitle" head_tool="yes" head_width="0"  style="width:0mm;display:none" align="center"></td>';
            }
            $table .='<td class="ld-form-item-content-entrytitle" style="width:25mm;text-align:center;" text-align="center">#</td>';
            foreach($this->tabDetailFieldData->tabPresenceDetailFields as $columnanme => $field){
                $display='';
                if(is_array($this->fieldruleHideColumn_arr)&&in_array($columnanme,$this->fieldruleHideColumn_arr))
                {

                    $display=' display:none;';
                }

                if($field->getNewLine() == 1)continue;
                $typeofdata = explode('~',$field->getTypeOfData());
                $width = $field->getWidth();
                if($field->getFieldType() == 'Select' && $current_user->is_admin == 'on'){
                    $width += 20;
                }
                if($typeofdata[1] == 'M'&&$field->getinput_type()!='1'){
                    $table .='<td class="ld-form-item-content-entrytitle" head_width="'.$width.'" head_detailfieldname="'.$columnanme.'" name="detail_'.$field->getColumnName().'" style="width:'.$width.'mm;'.$display.'" ><font color="red">*</font>'.$field->getfieldLabel().'</td>';
                }else{
                    $table .='<td class="ld-form-item-content-entrytitle" head_width="'.$width.'" head_detailfieldname="'.$columnanme.'" name="detail_'.$field->getColumnName().'" style="width:'.$width.'mm ;'.$display.'" >'.$field->getfieldLabel().'</td>';
                }

            }
            $table .='</tr>';
            return $table;
        }

        //$calculation 计算预算数据
        public function getTabDetailHtmlContent($jsAddRowid=''){
            $columnvalue = $this->tabDetailFieldData->getTabDetailHtmlContentData($jsAddRowid);
            $rows = $this->tabDetailFieldData->productrows;
            if($this->isCalculation=='yes'){
                $rows = count($this->calculationData);
                $columnvalue = $this->calculationData;
            }
            $tableContent = '';
            for($i = 0; $i<$rows; $i++){
                if(!empty($jsAddRowid)){//增加行
                    $rowid = $jsAddRowid;
                }else{
                    $rowid = $i+1;
                }
                if($rowid%2 ==0) {
                    $tableContent .='<tr valign="top" detaildeleted="no" rowindex="'.$rowid.'" class="lvtColDataBj dragtrrow" name="row'.$rowid.'">';
                }
                else{
                    $tableContent .='<tr valign="top" detaildeleted="no" rowindex="'.$rowid.'" class="lvtColData dragtrrow" name="row'.$rowid.'">';
                }

                $tableContent .= '<input type="hidden"  name="hidden_rowid_'.$rowid.'" value = "0" />';//产品明细中间行内容
                if($this->focus->mode != 'create' && empty($jsAddRowid) && vtlib_purify($_REQUEST['isDuplicate']) !='true'){
                    $tableContent .='<input type="hidden"  name="'.$this->focus->Detail_table_id.'" value="'.$columnvalue[$i][$this->focus->Detail_table_id].'" />';
                }
                $tableContent .= '<input type="hidden"  name="parent_lineitem_id" value = "'.$columnvalue[$i]['parent_lineitem_id'].'" />';//产品明细中间行内容
                $tableContent .='<td seqno="yes" style="text-align:center;width:25mm">'.$rowid.'</td>';
                //获取字段自动带出值信息


                $relatedData = $this->tabDetailFieldData->getFieldsRelatedData($columnvalue[$i],$this->entitytypeid);
               
                foreach($this->tabDetailFieldData->tabPresenceDetailFields as $columnanme => $field) {
                    //if (isset($columnvalue[$i][$columnanme])){
                        $column_value = $columnvalue[$i][$columnanme];
                        if ($field->getNewLine() == 0) {
                            //获取自定义字段对应的文本类型
                            $tableContent .= $this->TabDetailFieldsHtmlTd->getTabDetailsHtmlTd($this->tabDetailFieldData->module, $field, $column_value, $rowid, $jsAddRowid, $relatedData,$columnvalue[$i]);
                        }
                   // }
                }
                $tableContent .= '</tr>';
            }
            return $tableContent;
        }

        public function getTabDetailHtmlSubTotalTr(){
            $key = 0;
            // dump($this->tabPresenceDetailFields);

            $subtotalTrKey = array_keys($this->tabDetailFieldData->haveSubtotalField);
            //  dump($this->tabDetailFieldData->haveSubtotalFieldValue);
            if(count($this->tabDetailFieldData->haveSubtotalFieldValue) >= 1){
                $tableContent ='<tr name="detail_subtotal_row" class="detail_subtotal_row">';
                $tableContent .= '<td></td>';
                //if($this->focus->mode !='Details' ){//查看界面没有工具列
                //$tableContent .='<td></td>';
                //	}
                crm_load_class_file('cls_OptionModule','include/OptionModule');
                $cls_OptionModule = cls_OptionModule::getInstance($this->module,"");
                $optionmodule_data = $cls_OptionModule->getData();
                $tabid = getTabid($this->module);
                //  dump($this->tabDetailFieldData->tabPresenceDetailFields);

                foreach($this->tabDetailFieldData->tabPresenceDetailFields as $columnname => $field){
                    $display='';
                    if(is_array($this->fieldruleHideColumn_arr)&&in_array($columnname,$this->fieldruleHideColumn_arr)){
                        //布局规则

                        $display=' display:none;';
                    }
                    if($field->getNewLine() == 0){//0 表示第一行列
                        $key++;
                        if(array_key_exists($columnname,$this->tabDetailFieldData->haveSubtotalFieldValue)){
                            $len_decimal = 2;//金额 Amount
                            if($field->getFieldType() == 'Number'){	//数量
                                $len_decimal = $this->TabDetailFieldsHtmlTd->lengthdecimaldigits;
                            }/*else if($field->getFieldType() == 'Price'){	//单价
							$len_decimal = $this->TabDetailFieldsHtmlTd->lengthprice;
						}*/else if($field->getFieldType() == 'Int'){	//整数
                                $len_decimal = 0;
                            }else if($field->getFieldType() == 'Num'){	//数字
                                $typeofdata = explode('~',$field->getTypeOfData());
                                $type = explode(',',$typeofdata[2]);
                                $len_decimal = $type[1];
                            }
                            $tableContent .= '<td class="ld-form-item-content-entrytotal" style="'.$display.'" detailfieldname="'.$field->getColumnName().'"  name="subtotal_'.$columnname.'" align="right">'. setNumberFormat($this->tabDetailFieldData->haveSubtotalFieldValue[$columnname],$len_decimal).'</td>';
                        }else{
                            if($field->getFieldType() == 'SelectSource'){
                                if(empty($optionmodule_data[$tabid])){
                                    continue;
                                }
                                if($this->module == 'TimeSheet')
                                    $key++;
                            }
                            if($subtotalTrKey[0]-1== $key){

                                if($field->getFieldType() == 'SelectSource'){
                                    $tableContent .= '<td class="ld-form-item-content-entrytotal" style="'.$display.'" detailfieldname="'.$field->getColumnName().'"  name="subtotal_'.$field->getColumnName().'"></td><td style='.$display.' detailfieldname="'.$field->getColumnName().'" name="subtotal_'.$field->getColumnName().'">'.getFixedLabel('SUBTOTAL').'</td>';
                                    //$tableContent .= '<td style='.$display.' detailfieldname="'.$field->getColumnName().'"  name="subtotal_'.$field->getColumnName().'"></td><td align="center"></td>';
                                }else{
                                    $tableContent .= '<td class="ld-form-item-content-entrytotal" style="'.$display.'" detailfieldname="'.$field->getColumnName().'"  name="subtotal_'.$field->getColumnName().'" >'.getFixedLabel('SUBTOTAL').'</td>';
                                }
                            }else{
                                if($field->getFieldType() == 'SelectSource'){
                                    $tableContent .= '<td class="ld-form-item-content-entrytotal" style="'.$display.'" detailfieldname="'.$field->getColumnName().'" name="subtotal_'.$field->getColumnName().'"></td><td style='.$display.' detailfieldname="'.$field->getColumnName().'" name="subtotal_'.$field->getColumnName().'"></td>';
                                    //$tableContent .= '<td  style='.$display.' detailfieldname="'.$field->getColumnName().'" name="subtotal_'.$field->getColumnName().'"></td><td></td>';
                                }else{
                                    $tableContent .= '<td class="ld-form-item-content-entrytotal" style="'.$display.'" detailfieldname="'.$field->getColumnName().'"  name="subtotal_'.$field->getColumnName().'"></td>';
                                }
                            }
                        }
                    }
                }
            }


            $tableContent.='</tr>';

            return $tableContent;
        }

        public function getTabDetailHtmlTotalTr(){
            $tableContent = '<table class="ProductTab DetailContentTable" width="100%" cellspacing="0" cellpadding="0" border="0" align="center"> ';
            $totalfieldinfo=$this->focus->detailfieldobj->getFieldInfoobjBykey('columnname','total');
            $total_detail_columnname='budget_amount';//合计需要用到明细表字段
            if($totalfieldinfo)
            {
                $columnstring=$totalfieldinfo->getColumnString();
                if(!empty($columnstring)){
                    $columnstring=str_replace('&#039;','"',$columnstring);
                    $columnstring=str_replace('formulavar','"formulavar"',$columnstring);

                    $total_arr=json_decode($columnstring,true);//获取合计的字段公式
                    if(sizeof($total_arr)>0){
                        $total_detail_columnname=$total_arr['formulavar'][0]['column'];
                    }
                }
                else{
                    $columnstring = '';
                }
            }

            if(!empty($this->tabDetailFieldData->haveTotalFieldValue)){
                $typeofdatas = [];
                foreach($this->tabDetailFieldData->haveTotalFieldValue as $columnname => $value){
                    $field = $this->tabDetailFieldData->tabPresenceDetailFields[$columnname];
                    $tableContent .='<tr valign="top">';
                    //调整
                    if( $field->getFieldType() == 'Adjustment'){
                        $selectDeduct='';$selectAdd='';
                        $tableContent .='<td detailfieldname="'.$columnname.'"  align="right" width="90%"><b>'.$this->tabDetailFieldData->tabPresenceDetailFields[$columnname]->getfieldLabel().'</b>';
                        if($this->focus->mode != 'Details'){
                            if($value<0){
                                $selectDeduct = 'selected';
                            }else{
                                $selectAdd = 'selected';
                            }
                            $tableContent .='<select name="adjustmentType" class="ld-select-inner width100 marL8" onchange="caltotal_Detail()">';
                            $tableContent .='<option value="+" '.$selectAdd.'>'.getFixedLabel('ADD').'</option>';
                            $tableContent .='<option value="-" '.$selectDeduct.'>'.getFixedLabel('DEDUCT').'</option>';
                            $tableContent .='</select>';
                            $tableContent .='</td>';
                            $value = abs($value);
                        }
                        if($this->focus->mode == 'Details'){
                            $tableContent .= '<td detailfieldname="'.$columnname.'" align="right">'.$value.'</td>';
                        }else{
                            $tableContent .= '<td  detailfieldname="'.$columnname.'" align="right"><input onchange="caltotal_Detail()" class="ld-input-inner" type="text" value="'.$value.'" name="'.$columnname.'"  tag="'.$columnname.'"></td>';
                        }
                    }else{
                        $tableContent .='<td detailfieldname="'.$columnname.'" align="right" width="90%"><b>'.$this->tabDetailFieldData->tabPresenceDetailFields[$columnname]->getfieldLabel().'</b></td>';
                        if($this->tabDetailFieldData->module == 'Expense'||$this->tabDetailFieldData->module=='Commission'){
                            $tableContent .= '<td  detailfieldname="'.$columnname.'" align="right"><input type="hidden" value="'.$value.'" name="'.$columnname.'"  tag="'.$columnname.'"><span type="hidden" value="'.$value.'" name="sum_rmb_total"  tag="'.$columnname.'">'.setNumberFormat($value,2).'</td>';

                        }else{
                            $lengthdecimal = '';
                            if(!empty($typeofdatas)){
                                $lengthdecimal=$typeofdatas[sizeof($typeofdatas)-1];
                            }
                            if($lengthdecimal=='')
                            {
                                $lengthdecimal=2;
                            }
                            //出差申请单明细没有合计字段
                            $formulafield=$this->focus->detailfieldobj->getFieldInfoobjBykey('columnname',$total_detail_columnname);
                            if($formulafield&&$field&&$field->getNewLine()==1)
                            {
                                //加班单，请假单的合计小数位数为1位
                                $typeofdata= $this->focus->detailfieldobj->getFieldInfoobjBykey('columnname',$total_detail_columnname)->getTypeOfData();
                                $typeofdatas= explode(',',$typeofdata);
                                $tableContent .= '<td detailfieldname="'.$columnname.'" align="right"><input type="hidden" value="'.$value.'" name="'.$columnname.'"  tag="'.$columnname.'"><span style="padding-right: 10px;font-weight: bold;" type="hidden" value="'.$value.'" name="sum_'.$columnname.'"  tag="'.$columnname.'">'.setNumberFormat($value,$lengthdecimal).'</span></td>';
                            }
                            else
                                $tableContent .= '<td detailfieldname="'.$columnname.'" align="right"><input type="hidden" value="'.$value.'" name="'.$columnname.'"  tag="'.$columnname.'"><span style="padding-right: 10px;font-weight: bold;" type="hidden" value="'.$value.'" name="sum_'.$columnname.'"  tag="'.$columnname.'">'.setNumberFormat($value,2).'</span></td>';
                        }
                    }
                    $tableContent .='</tr>';
                }
            }
            $tableContent .='</table>';
            return $tableContent;
        }
	}

