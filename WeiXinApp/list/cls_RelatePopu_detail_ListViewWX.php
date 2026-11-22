<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
class cls_RelatePopu_detail_ListViewWX extends cls_ListViewWX
{
    public $SelectRelatedPopu_detail;

    public function get_page_query($showtype,$isSingle){
        $result =$this->get_pagequery($showtype,$isSingle);
        if(!empty($this->focus->list_link_field)){
            $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('fieldname',$this->focus->list_link_field);
            if(!empty($fieldinfo))
                $this->obj_query->popuselectcolumn = ','.$fieldinfo->tableName.'.'.$this->focus->list_link_field;
        }
        return $result;
    }

    public function get_pagequery($showtype,$isSingle)
    {
		
        return  parent::get_page_query($showtype,$isSingle);
    }
	//chj,2022/6/20,reason:ID1000927/页面设置，选择源单增加其他条件，可设置选择源单过滤条件
    public function advanceDemandSql($showtype)
    {
        global $adb,$current_user;
        $tabid = getTabid($_REQUEST['frommodule']);
		$referencemodule_tabid = getTabid($_REQUEST['selectmodule']);
        if ($tabid > 0 && $referencemodule_tabid > 0 && $_REQUEST['selectrelationfrom'] == 'entry' && !empty($_REQUEST['fieldname'])) {
			if(get_file_address($_REQUEST['frommodule'],'ProductDetails')){
				$query = "select effectivecondition,bigtype from ld_producttoolfield where tabid = ? and columnname = ?";
			}else{
				$query = "select effectivecondition,bigtype from ld_tabdetailfield where tabid = ? and columnname = ?";
			}
			
            $result = $adb->pquery($query,array($tabid, $_REQUEST['fieldname']));
            $rows = $adb->num_rows($result);
            if($rows > 0){
                $effectivecondition = $adb->query_result($result,0,'effectivecondition');
				$bigtype = $adb->query_result($result,0,'bigtype');
				if($bigtype == 'selectsource'){
					$query = "SELECT effectivecondition FROM ld_option_module WHERE tabid=? AND option_tabid=? AND presence=0 LIMIT 1";
						$result = $adb->pquery($query,array($tabid, $referencemodule_tabid));
						$rows = $adb->num_rows($result);
						if($rows > 0){
							$effectivecondition = $adb->query_result($result,0,'effectivecondition');
							//自动带出所选源单的分录明细   设置控制生效条件 
							if(!empty($effectivecondition)){
								$effectivecondition = html_entity_decode($effectivecondition);
								$effectivecondition_arr = json_decode($effectivecondition,true);
								if(!empty($effectivecondition_arr['approve'])){
									$_REQUEST['advft_criteria'] = $effectivecondition_arr['approve']['advft_criteria'];
									$_REQUEST['advft_criteria_groups'] = $effectivecondition_arr['approve']['advft_criteria_groups'];
									$_REQUEST['searchtype'] = 'advance';
									$customview_obj = $this->init_custom();
									crm_load_class_file('QueryGeneratorWX', 'WeiXinApp/QueryGenerator');
									$obj_query = $querygenerator = QueryGeneratorWX::getInstance($this->module, $current_user,$customview_obj,'','yes');
									$obj_query->addUserSearchConditions($_REQUEST);
									$tmp_page_list_query = $obj_query->getQuery($showtype, 1);
									return $tmp_page_list_query;
                                    //if(!empty($obj_query->wherecondition)){
//										return ' and ' . $obj_query->wherecondition;
//									}
                                    
								}
							}
						}
				}else{
					//自动带出所选源单的分录明细   设置控制生效条件 
					if(!empty($effectivecondition)){
						$effectivecondition = html_entity_decode($effectivecondition);
						$effectivecondition_arr = json_decode($effectivecondition,true);
						if(!empty($effectivecondition_arr['reference'])){
							$_REQUEST['advft_criteria'] = $effectivecondition_arr['reference']['advft_criteria'];
							$_REQUEST['advft_criteria_groups'] = $effectivecondition_arr['reference']['advft_criteria_groups'];
							$_REQUEST['searchtype'] = 'advance';
							$customview_obj = $this->init_custom();
							crm_load_class_file('QueryGeneratorWX', 'WeiXinApp/QueryGenerator');
							$obj_query = $querygenerator = QueryGeneratorWX::getInstance($this->module, $current_user,$customview_obj,'','no');
							$obj_query->addUserSearchConditions($_REQUEST);
                            $tmp_page_list_query = $obj_query->getQuery($showtype, 1);
							return $tmp_page_list_query;
							//if(!empty($obj_query->wherecondition)){
//								return ' and ' . $obj_query->wherecondition;
//							}
						}
						
					}
				}
            }

        }
		return '';
    }
    public function set_listdetail($showtype,$isSingle='yes')//gyqCom0313 reason:跟进记录新增选择相关客户，再选择联系人等，联系人范围受限制
    {
        global $adb;
        parent::set_listdetail($showtype); 
        crm_load_class_file("SelectRelatedPopu_detail",'include/SelectRelatedPopu');
        $this->SelectRelatedPopu_detail = new SelectRelatedPopu_detail($_REQUEST['selectmodule'],$adb);
        $keywhere = $this->SelectRelatedPopu_detail->related_key_where($_REQUEST['parent_id']);
		if(!empty($keywhere)){
			$this->page_list_query .= $keywhere;
		}
		$advance_keywhere = $this->advanceDemandSql($showtype);
       if(!empty($advance_keywhere)){
            //edit:duan 20220905 修改选择源单增加筛选条件时，选择自定义表的字段无法关联的问题
            $tablename = $this->focus->table_name;
            $tableindex = $this->focus->table_index;
            $scftablename = $this->focus->customFieldTable[0];
            $tmp_sql = "select ".$tablename.".".$tableindex." from ".$tablename." 
                        inner join ".$scftablename." on ".$scftablename.".".$tableindex.'='.$tablename.".".$tableindex.
                        " where ".$tablename.".".$tableindex." in (".$this->page_list_query.")".
                        " and ".$tablename.".".$tableindex." in (".$advance_keywhere.") ";
			$this->page_list_query = $tmp_sql;
		}
    }
    public function get_listdetail($showtype='',$generatorName='')
    {
        global $adb,$mobile_pagerecordcount;//gyqCom0313 reason:未联动更改
        $this->set_listdetail($showtype);

        $page_list_query = $this->page_list_query ;
        $list_query = $this->list_query;
		$page_list_query .= $this->SelectRelatedPopu_detail->getApproveDemandSql();	//审批要求

        //gyq_32 联系人序时簿额外获取手机号码信息
        $list_query = $this->get_phone_sql($this->focus,$list_query);
        //$noofrows = $this->SelectRelatedPopu_detail->getMaxRowShow();	//最多显示数据条数
        //zxm 2021-0705  选择产品 产品数据增加是否禁用的条件
        if(isset($_REQUEST['selectmodule'])&&$_REQUEST['selectmodule']=="Products"){
            $deployarray_82=getSys_deploy(82);
            if($deployarray_82['deploy_value']=='0') 
                $page_list_query .= " AND ld_products.discontinued = 0";
        }
		
        //diony 2021-07-14 根据填写字段增加查找条件
        $relatecreateconditionobj=cls_RelateCreateCondition::getInstance($_REQUEST['selectmodule'],$_REQUEST['frommodule']);
        $columnvalues=ldcrm_json_decode($_REQUEST['requestvalues']);
        if(isset($_REQUEST['detailrequestrowvalues'])){
            $detailrequestrowvalues = json_decode($_REQUEST['detailrequestrowvalues'],true);
            $relatecreateconditionobj->setdetailrowvalue_arr($detailrequestrowvalues);
        }
        $relatecreateconditioninfos=  $relatecreateconditionobj->getChooseDataWhere($columnvalues);
        if(!empty($relatecreateconditioninfos)){
            $page_list_query.=' '.$relatecreateconditioninfos['where'];
        }

        //zxm 2021-0705  总条数为0的bug
        $count_result = $adb->query($page_list_query);
        if (!empty($count_result))
            $noofrows = $adb->num_rows($count_result);
        else
            $noofrows = 0;
        //duan 20230710 移动端分录关联选择单据，读取排序信息时，按照数据分录的条件读取，和pc端保持一致
        if(empty($order_by)){
            list($page_list_query2, $order_by, $sorder) = $this->customview->getOrderWhere($page_list_query);
        }
        $page_list_query .= ' order by ' .$order_by.' '.$sorder;

        //$page_list_query .= ' order by ' . $this->focus->table_name . '.createdtime DESC ';//同pc端分录选择源单setRelatedPopopSql()
        $page_list_query = $this->page_list_query($noofrows, $page_list_query, $order_by);
		$tableindex=$this->focus->table_index;
        $list_query = $list_query . '  inner join   ( ' . $page_list_query
            . '  ) as tmp on tmp.' . $this->focus->table_index . '=' . $this->focus->table_name .
            '.' . $this->focus->table_index	;
        if(!empty($this->focus->list_link_field)){
            
             $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey('fieldname',$this->focus->list_link_field);
            $list_link_tablename=$fieldinfo->getTableName();
            if($list_link_tablename != $this->focus->table_name && !array_key_exists($list_link_tablename,$this->obj_query->getFromTables())){
                $list_query.=" left join $list_link_tablename on $list_link_tablename.$tableindex=".$this->focus->table_name .
            '.' . $this->focus->table_index	;
            
            }
        }
        //避免order by为空时，导致sql报错 editor:gyq_20181228 0035926: （落落计划）企业微信>灵当CRM>拜访签到>选择拜访对象类型为“客户”：选择拜访对象时显示没有数据，实际是有数据的。（邱：参数中有params['related_pop_type'] = 'signin';这个就获取不到数据）
        if(!empty($order_by) || !empty($sorder)){
            $list_query .=  ' order by '.$order_by.' '.$sorder;
        }
        $list_result = $adb->pquery($list_query,array());
        $num_rows = $adb->num_rows($list_result);
        $_REQUEST['weixin_mark'] = 1; //微信端号码原样输出 gyqTE
        $this->jsonArr['search_reminds'] =$this->getSearchReminds();
        $this->jsonArr['list1'] = $this->getListViewEntries($adb,$list_result,null);
        $this->set_outputStyle();
        return $this->jsonArr;
    }
}

