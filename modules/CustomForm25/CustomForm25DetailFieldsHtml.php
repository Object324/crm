<?php
	/**
	 * 修改编码格式:统一编码：UTF-8
	 * @author Chj
	 */
	crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
	Class CustomForm25DetailFieldsHtml extends cls_TabDetailFieldsHtml {
		
		function __construct($focus,$module){
			 parent::__construct($focus,$module);
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
				$table .='<th colspan="'.$productToolMore.'"><div class="DivCName DivCNamehover" onclick="showHideStatus(\'productsStaus\',\'projuctscol\')"><span name="projuctscol" class=""></span>' . getTranstab('CustomForm25') . '</div></th>';
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
            if($this->focus->mode != 'Details'){
                $table .='<div class="editrelhead">';
                $table .='<span><b>' . getTranstab('CustomForm25') . '</b></span>';
                $table .='<span name="kindlyremind" class="ld-entry-tip"></span>';
                $table .='</div>';
            }
			$table .='<div name="productDiv" style="overflow: auto;max-height: 500px;min-height:0%;">';
			$table .='<table class="ProductTab DetailContentTable" id="proTab" name="proTab" style="width:'.$this->table_width.'mm;'.$table_fixed_style.'" border="0" align="center" cellpadding="0" cellspacing="0">';
			$table .='<input type="hidden"  name="table_width" value="'.$this->table_width.'">';
            $table .='<input type="hidden"  name="rowcnt" value="'.$this->tabDetailFieldData->productrows.'">';
            if($this->focus->mode != 'Details'){
                $table .='<tr></tr>';
            }
			$table .=$this->getTabDetailHtmlHeader();
			$table .=$this->getTabDetailHtmlContent();
			$table .=$this->getTabDetailHtmlSubTotalTr();
           
			$table .='</table>';
			$table .='</div>';
			if($this->tabDetailFieldData->focus->mode != 'Details'){

			    if(getVersionInfo()['account'] == 'langjie'){
                    //朗捷 空运订单回传单据分录不允许修改，不显示新增按钮
                    $table .='';
                }else{
					$table .= $this->getEntryBtn($this->tabDetailFieldData->module);
                    /*$table .='<table class="ProductTabTotal" width="100%"  border="0" align="center" cellpadding="0" cellspacing="0">';
                    $table .='<tr><td><input type="button" style="border:none;" name="Button" class="createauto" value="'.getFixedLabel('NEW') .'" onclick="fnAddTabDetailRow(\''.$this->tabDetailFieldData->module.'\');" /></td></tr>';
                    $table .='</table>';*/
                }

			}
			$table .=$this->getTabDetailHtmlTotalTr();
        
			if($this->focus->mode == 'Details'){
				$table .='</td></tr>';
				$table .='</tbody></table>';
			}
			return $table;
		}
		
		//佣金单明细最后一�?合计
		public function getProductHtmlLastContent(){
			
		}



        public function getTabDetailHtmlContent($jsAddRowid="")
        {
            $versioninfo=getVersionInfo();

            if($versioninfo['account']=='baxter' && $_REQUEST["frommodule"] == 'Accounts' && $this->tabDetailFieldData->row_mode=='related_create')
            {

                //1 获取病人管理模块的产品规格
                $frommodule_focus = CRMEntity::getInstance($_REQUEST['frommodule']);
                $frommodule_focus->retrieve_entity_info($_REQUEST['fromid'], $_REQUEST['frommodule']);
                $productcategory = $frommodule_focus->column_fields['productcategory'];//腹透液类型
                $product_size = $frommodule_focus->column_fields['cf_6105'];//产品规格
                //ls 20230407 BUG0064266 不良事件（customform25）分录带出时，增加用药频率（sf444）根据病人模块(account)的每天用水量（cf_5820）带出，如每日用水量为2，则每行分录用药频率都是2
                $sf444 = $frommodule_focus->column_fields['cf_5820'];//每天用水量

                /*
                 * ls 20230322 需求:【百特】不良事件模块（CustomForm25），从病人模块（Account）关联创建时，分录自动生成（普通分录）。
                 *      病人模块有个产品规格字段 cf_6105（多选框），根据选择的产品规格，自动带出分录（有映射关系）。
                 * sf439 产品名称; sf440 怀疑药物适应症; sf441 给药途径; sf443 国家药品编码;
                 *  映射关系:
                 *      cf_6105 sf439               sf440           sf441                   sf443
                 *  0		    Dianeal            	ESRD			腹腔内注射				DIANEAL (WORLD MKT DR)
                    1	6AB5193	Baxter PD2 1.5% 5L  ESRD			腹腔内注射				国药准字H20133278
                    2	6AB5194	Baxter PD2 2.5% 5L	ESRD			腹腔内注射				国药准字H20133283
                    3	6AB9710	Baxter PD2 1.5% 6L	ESRD			腹腔内注射				国药准字H20133279
                    4	6AB9711	Baxter PD2 2.5% 6L	ESRD			腹腔内注射				国药准字H20133284
                    5	6AB9766	Baxter PD4 1.5% 2L	ESRD			腹腔内注射				国药准字H20023569
                    6	6AB9776	Baxter PD4 2.5% 2L	ESRD			腹腔内注射				国药准字H20023567
                    7	6AB9796	Baxter PD4 4.25% 2L	ESRD			腹腔内注射				国药准字H20023568
                    8	6AB9866	Baxter PD2 1.5% 2L	ESRD			腹腔内注射				国药准字H20133276
                    9	6AB9868	Baxter PD2 1.5% 2.5L	ESRD		腹腔内注射				国药准字H20133277
                    10	6AB9876	Baxter PD2 2.5% 2L	ESRD			腹腔内注射				国药准字H20133281
                    11	6AB9878	Baxter PD2 2.5% 2.5L	ESRD		腹腔内注射				国药准字H20133282
                    12	6AB9896	Baxter PD2 4.25% 2L	ESRD			腹腔内注射				国药准字H20133286
                    13	6AB9898	Baxter PD2 4.25% 2.5L	ESRD		腹腔内注射				国药准字H20133287
                    14	6AB4984	Baxter Extraneal	ESRD			腹腔内注射				国药准字H20213666
                 * */
                $entry_relationship['default']=array('sf439'=>"Dianeal","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"DIANEAL (WORLD MKT DR)","sf444"=>$sf444);
                $entry_relationship['6AB5193']=array('sf439'=>"Baxter PD2 1.5% 5L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133278","sf444"=>$sf444);
                $entry_relationship['6AB5194']=array('sf439'=>"Baxter PD2 2.5% 5L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133283","sf444"=>$sf444);
                $entry_relationship['6AB9710']=array('sf439'=>"Baxter PD2 1.5% 6L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133279","sf444"=>$sf444);
                $entry_relationship['6AB9711']=array('sf439'=>"Baxter PD2 2.5% 6L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133284","sf444"=>$sf444);
                $entry_relationship['6AB9766']=array('sf439'=>"Baxter PD4 1.5% 2L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20023569","sf444"=>$sf444);
                $entry_relationship['6AB9776']=array('sf439'=>"Baxter PD4 2.5% 2L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20023567","sf444"=>$sf444);
                $entry_relationship['6AB9796']=array('sf439'=>"Baxter PD4 4.25% 2L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20023568","sf444"=>$sf444);
                $entry_relationship['6AB9866']=array('sf439'=>"Baxter PD2 1.5% 2L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133276","sf444"=>$sf444);
                $entry_relationship['6AB9868']=array('sf439'=>"Baxter PD2 1.5% 2.5L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133277","sf444"=>$sf444);
                $entry_relationship['6AB9876']=array('sf439'=>"Baxter PD2 2.5% 2L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133281","sf444"=>$sf444);
                $entry_relationship['6AB9878']=array('sf439'=>"Baxter PD2 2.5% 2.5L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133282","sf444"=>$sf444);
                $entry_relationship['6AB9896']=array('sf439'=>"Baxter PD2 4.25% 2L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133286","sf444"=>$sf444);
                $entry_relationship['6AB9898']=array('sf439'=>"Baxter PD2 4.25% 2.5L","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20133287","sf444"=>$sf444);
                $entry_relationship['6AB4984']=array('sf439'=>"Baxter Extraneal","sf440"=>"ESRD","sf441"=>"腹腔内注射","sf443"=>"国药准字H20213666","sf444"=>$sf444);

                $this->tabDetailFieldData->setEntityTypeId($this->entitytypeid);
                $columnvalue = $this->tabDetailFieldData->getTabDetailHtmlContentData($jsAddRowid);

                //ls 240410 XUQIU20240409-02 【百特】不良事件带出分录规则变更（邹晓宇）
                if ($productcategory == '百特葡萄糖和艾考') {
                    if (empty($product_size)) {
                        // 关联新建时赋默认值 分录仅有一行
                        $columnvalue[0] = array_merge($columnvalue[0],$entry_relationship['default']);

                    }else{
                        $product_size = explode(' |##| ',$product_size);

                        //2 根据产品规格给分录字段赋值
                        $tmp_columnvalue = [];
                        foreach ($product_size as $size) {
                            if (isset($entry_relationship[$size])) {
                                $tmp_columnvalue[] = array_replace($columnvalue[0],$entry_relationship[$size]); //这里关联索引,故也可以使用 array_merge
                            }
                        }

                        if (count($product_size) == '1' && in_array("6AB4984", $product_size)) {
                            $tmp_columnvalue[] = array_replace($columnvalue[0],$entry_relationship['default']);
                        }

                        $columnvalue = $tmp_columnvalue;
                    }
                } elseif ($productcategory == '百特葡萄糖') {
                    if (empty($product_size)) {
                        $columnvalue[0] = array_merge($columnvalue[0],$entry_relationship['default']);
                    }else{
                        $product_size = explode(' |##| ',$product_size);

                        //2、只有艾考品规 6AB4984,  只带出 default
                        if (count($product_size) == 1 && in_array("6AB4984", $product_size)) {
                            $product_size = ["default"];
//                        } elseif (count($product_size) >=2 && in_array("6AB4984", $product_size)) {
                        } else {
                            //3、包含艾考品规 6AB4984+百特葡萄糖品规  ,只带出 对应百特葡萄糖规格（即去掉艾考）
                            unset($product_size[array_flip($product_size)['6AB4984']]);
                        }
                        //4、其他情况都属于 只有百特葡萄糖品规（3、4可以合并,去掉艾考）


                        // 根据产品规格给分录字段赋值
                        $tmp_columnvalue = [];
                        foreach ($product_size as $size) {
                            if (isset($entry_relationship[$size])) {
                                $tmp_columnvalue[] = array_replace($columnvalue[0],$entry_relationship[$size]); //这里关联索引,故也可以使用 array_merge
                            }
                        }

                        $columnvalue = $tmp_columnvalue;
                    }
                } elseif ($productcategory == '其他品牌葡萄糖和艾考') {
                    if (empty($product_size)) {
                    }else{
                        $columnvalue[0] = array_merge($columnvalue[0],$entry_relationship['6AB4984']);
                    }
                }

                $this->tabDetailFieldData->productrows = count($columnvalue);//分录行数  实际上就是产品规格的个数


                for($i = 0; $i<$this->tabDetailFieldData->productrows; $i++){
                    if(!empty($jsAddRowid)){//增加行
                        $rowid = $jsAddRowid;
                    }else{
                        $rowid = $i+1;
                    }
                    if($rowid%2 ==0) {
                        $tableContent .='<tr valign="top" detaildeleted="no" rowindex="'.$rowid.'" class="lvtColDataBj dragtrrow" onmouseout="detailListOnMouseOut(ld(this),\'On\');" onmouseover="detailListOnMouseOver(ld(this));" name="row'.$rowid.'">';
                    }
                    else{
                        $tableContent .='<tr valign="top"  detaildeleted="no" rowindex="'.$rowid.'" class="lvtColData dragtrrow" onmouseout="detailListOnMouseOut(ld(this),\'on\');" onmouseover="detailListOnMouseOver(ld(this));" name="row'.$rowid.'">';
                    }

                    $tableContent .= '<input type="hidden"  name="hidden_rowid_'.$rowid.'" value = "0" />';//产品明细中间行内容
                    if($this->focus->mode != 'create' && empty($jsAddRowid) && vtlib_purify($_REQUEST['isDuplicate']) !='true'){
                        $tableContent .='<input type="hidden"  name="'.$this->focus->Detail_table_id.'" value="'.$columnvalue[$i][$this->focus->Detail_table_id].'" />';
                    }
                    $tableContent .= '<input type="hidden"  name="parent_lineitem_id" value = "'.$columnvalue[$i]['parent_lineitem_id'].'" />';//产品明细中间行内容
//			if($this->focus->mode !='Details' && $this->operation_row === 0){//查看界面没有“删除”或者上下移动的按钮
                    $tableContent .='<td style="display:none;width:0mm"></td>';//隐藏操作列
//			}
                    $tableContent .='<td seqno="yes" style="text-align:center;width:25mm">'.$rowid.'</td>';
                    //获取字段自动带出值信息


                    $relatedData = $this->tabDetailFieldData->getFieldsRelatedData($columnvalue[$i],$this->entitytypeid);

                    foreach($this->tabDetailFieldData->tabPresenceDetailFields as $columnanme => $field){
                        $column_value = $columnvalue[$i][$columnanme];
                        if($field->getNewLine() == 0){
                            //获取自定义字段对应的文本类型

                            $tableContent .= $this->TabDetailFieldsHtmlTd->getTabDetailsHtmlTd($this->tabDetailFieldData->module,$field,$column_value,$rowid,$jsAddRowid,$relatedData,$columnvalue[$i]);
                        }

                    }
                    $tableContent .= '</tr>';
                }
                return $tableContent;

            }
            elseif($versioninfo['account']=='huacanguangdian'){
                $this->tabDetailFieldData->setEntityTypeId($this->entitytypeid);
                //dump($this->tabDetailFieldData->getTabDetailHtmlContentData($jsAddRowid));
                $columnvalue = $this->tabDetailFieldData->getTabDetailHtmlContentData($jsAddRowid);

                //新增,关联创建
                if(empty($this->tabDetailFieldData->focus->id)){
				
                    if(count($columnvalue) == 1 || empty($columnvalue)){
                        $columnvalue_new = [];
                        for($k=0;$k<6;$k++){


                            if(date('m') + $k > 12){
                                $columnvalue[0]['sf693'] = (date('Y')+1) . '年' . (date('m') + $k - 12) . '月';
                            }else{
                                $columnvalue[0]['sf693'] = date('Y') . '年' . (date('m') + $k) . '月';
                            }
                            $columnvalue_new[] = $columnvalue[0];
						
                        }
                        $columnvalue = $columnvalue_new;
                    }else{
                        if($columnvalue[0]['sf693'] != date('Y') . '年' . (date('m') + $k) . '月'){
                            $newline_columnvalue = $columnvalue[0];
                            unset($columnvalue[0]);
                            $columnvalue = array_values($columnvalue);
                            foreach($newline_columnvalue as $column => &$value){
                                if($column == 'sf693'){
                               
                                    if(date('m') + 5 > 12){
                                        $value = (date('Y')+1) . '年' . (date('m') + count($columnvalue) - 11) . '月';
                                    }else{
										$value = date('Y') . '年' . (date('m') + count($columnvalue) + 1) . '月';
									}
                                }else{
                                    $value = '';
                                }
                            }
                            $columnvalue[] = $newline_columnvalue;
                        }
                    }

                }
                for($i = 0; $i<count($columnvalue); $i++){
                    if(!empty($jsAddRowid)){//增加行
                        $rowid = $jsAddRowid;
                    }else{
                        $rowid = $i+1;
                    }
                    if($rowid%2 ==0) {
                        $tableContent .='<tr valign="top" detaildeleted="no" rowindex="'.$rowid.'" class="dragtrrow" onmouseout="detailListOnMouseOut(ld(this),\'On\');" onmouseover="detailListOnMouseOver(ld(this));" name="row'.$rowid.'">';
                    }
                    else{
                        $tableContent .='<tr valign="top"  detaildeleted="no" rowindex="'.$rowid.'" class="dragtrrow" onmouseout="detailListOnMouseOut(ld(this),\'on\');" onmouseover="detailListOnMouseOver(ld(this));" name="row'.$rowid.'">';
                    }

                    $tableContent .= '<input type="hidden"  name="hidden_rowid_'.$rowid.'" value = "0" />';//产品明细中间行内容
                    if($this->focus->mode != 'create' && empty($jsAddRowid) && vtlib_purify($_REQUEST['isDuplicate']) !='true'){
                        $tableContent .='<input type="hidden"  name="'.$this->focus->Detail_table_id.'" value="'.$columnvalue[$i][$this->focus->Detail_table_id].'" />';
                    }
                    $tableContent .= '<input type="hidden"  name="parent_lineitem_id" value = "'.$columnvalue[$i]['parent_lineitem_id'].'" />';
                    $tableContent .='<td style="display:none;width:0mm"></td>';//隐藏操作列
                    $tableContent .='<td seqno="yes" style="text-align:center;width:25mm">'.$rowid.'</td>';
                    //获取字段自动带出值信息


                    $relatedData = $this->tabDetailFieldData->getFieldsRelatedData($columnvalue[$i],$this->entitytypeid);

                    foreach($this->tabDetailFieldData->tabPresenceDetailFields as $columnanme => $field){
                        $column_value = $columnvalue[$i][$columnanme];

                        if($field->getNewLine() == 0){
                            //获取自定义字段对应的文本类型

                            $tableContent .= $this->TabDetailFieldsHtmlTd->getTabDetailsHtmlTd($this->tabDetailFieldData->module,$field,$column_value,$rowid,$jsAddRowid,$relatedData,$columnvalue[$i]);
                        }

                    }
                    $tableContent .= '</tr>';
                }
                return $tableContent;
            }
            else{
                return  parent::getTabDetailHtmlContent($jsAddRowid);
            }
        }

	}

?>