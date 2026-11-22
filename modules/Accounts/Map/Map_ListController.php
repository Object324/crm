<?php
crm_load_class_file('showProductDetailFieldValue','include/fields');
class Map_ListController extends  ListViewController
{
	protected $productModuleFields;
	public $prefix_detail_colum;
	public $list_showtype=SHOW_LISTVIEW;
	public $fields_property;

	public function __construct($db, $user, $generator) {
		
		parent::__construct($db, $user, $generator);
		$this->prefix_detail_colum='products_';
	}

	function getListViewFields($module)
	{
		$module = $module;
		crm_load_class_file("cls_map_field",'modules/Accounts/Map');
		$cls_map_field = new cls_map_field($module);
		$map_field_list = $cls_map_field->getAllMapFields();
		$map_field = array();
		if(!empty($map_field_list)){
			$focus = CRMEntity::getInstance($module);
			$objmoduleFields=$focus->fieldobj->getModuleFields();
			$this->fields_property[]=$module;
			foreach($map_field_list as $map_type => $map_fields){
				foreach($map_fields as $columns){
					$col_arr = explode(':',$columns);
					$fieldname = $col_arr[2];
					$Objfield=$objmoduleFields[$fieldname];
					if(!isset($Objfield)){
						continue;
					}
					if(isset($map_field[$fieldname])){
						continue;
					}
					$map_field[$fieldname] = $fieldname;
					$field=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                    $fieldlabel=$field->getFieldLabelKey();
					$columnlist[] = $field->getTableName(). '.' . $field->getColumnName();
					$listViewFields[] = $fieldname;
				}
			}
		}
	//	$columnlist=array_filter($columnlist);
    //    $listViewFields = implode(',', $columnlist);

		   return $listViewFields;
		 
	 }

	public function getListViewEntries_FocusModule($module)
	{
		//echo $module;
		if($this->module == 'ServiceCharge')
			$this->focusmodule='Accounts';
		else
			$this->focusmodule = $module;
		return $this->focusmodule;
	}

	public function getProductModuleFields($module)
	{
		if(is_array($this->productModuleFields) && sizeof($this->productModuleFields)>0)
			return $this->productModuleFields;
		// dump($this->queryGenerator);
		if($this->queryGenerator->productDetails == '')
			return '';
		$this->productModuleFields= $this->queryGenerator->productDetails->getModuleFields();

		$this->queryGenerator->productDetails->querygenerator=$this->queryGenerator;

		return $this->productModuleFields;
	  
	}
	public function getColumnName($index,$fieldName)
	{
		static $cols;
		$listPropertyFields=$this->queryGenerator->getPropertyFields();
		$propertyModule=$listPropertyFields[$index];
		$this->productModuleFields=$this->getProductModuleFields($this->queryGenerator->module);
		$this->getListViewEntries_FocusModule($this->queryGenerator->module);
		$this->modulefields=$this->getModuleFields();
		$field = $this->modulefields[$fieldName];
		if(!isset($field)){
		   $cols[$index]="-1";
			return "-1";
		}
		$columnname=strtolower($field->getColumnName());  
		$cols[$index]=$columnname;
		return $columnname;
	}
     
	function getListViewEntries($focus, $module,$result,$navigationInfo,$skipActions=false,$MoreAction=false,$export='') {
		global $listview_max_textlength, $theme,$current_user, $currentModule;
		global $adb;
		$InventoryArray = array('InventoryAccount','InventoryQuery');
		global $related_header, $related_left_record;
		$this->result=$result;
		$this->module=$module;
        
		$this->focusmodule = $this->getListViewEntries_FocusModule($module);
		global $related_left_type;
           
		if(isset($related_left_type) && $related_left_type > 0){
			global $related_left_mod,$related_left_record;
			global $related_left_id,$related_left_start,$related_left_viewid;
			$related_tabid=getTabid($related_left_mod);

			$this->setrelatedfldarray();

			$related_left_block = "related_left_block(\"&header=".$related_left_mod."&record=".$related_left_record."&relatedid=".$related_left_id."&order_by=%s&sorder=%s&related_left_type=".$related_left_type."&start=".$related_left_start."&viewid=".$related_left_viewid."\",\"".$related_left_id."\");";
		}
  		$this->listViewFields =$this->getListViewFields($module);
        $this->productModuleFields=$this->getProductModuleFields($module);
		$this->setListFieldValueObj($focus,$module);

		$rowCount = $adb->num_rows($result);		
		// dump($result);
		
		//单据明细中数量小数位数 tujt 2014-08-14
		if('InventoryQuery' == $currentModule || 'InventoryAccount' == $currentModule){
			$inventacctarr = array('firstqty'=>'1','inputqty'=>'1','outputqty'=>'1','lastqty'=>'1');
		}
		$remindreltab = array('reltab'=>'1','related_to'=>'1');
		$modcommentrelated = array('reltab'=>'1','related_to'=>'1','parent_comments'=>'1');

		$data = array();
		$baseTable =$focus->table_name;
		$moduleTableIndexList = $focus->tab_name_index;
		$baseTableIndex = $moduleTableIndexList[$baseTable];

		$fieldvalueobjs=$this->setshowfieldValueObj($module);
		$record_html_btn=array();
		for ($i = 0; $i < $rowCount; ++$i) {
			$recordId=$this->getListViewRecordID($module,$result,$i,$baseTableIndex);
			$baserecordid=$recordId;
			$detailid = '';
			$idvalue=$adb->query_result($result,$i,$baseTableIndex);
			if(empty($detailid))$detailid = $recordId;
			$row=$this->getRowValue($i,$detailid,$fieldvalueobjs);

			if($row == ''){
            	$row[$baseTableIndex] = $adb->query_result($this->result,$i,$baseTableIndex);
			}
			$row['local_address'] = $adb->query_result($this->result,$i,'local_address');
            $row['longtitude'] = $adb->query_result($this->result,$i,'longtitude');
            $row['latitude'] = $adb->query_result($this->result,$i,'latitude');
			if($skipActions && $module!='ModComments' && $currentModule!='Home' && $currentModule !='Management'){   
				$row[sizeof($row)] = '';
			}
            /*
            edit:chj
            date:2013-11-21
            reson:确保数组健值的唯一
            */
            $rowindex=$this->getSetListRowIndex($module,$result,$i,$baseTableIndex);
            
            if(in_array("$module",$InventoryArray))
            {
                $rowindex = $i;
            }
            $data[$rowindex] = $row; 
            
		}
		return $data;
	}
	public function getValue($key, $fieldName, $showfieldvalueobj, $i)
    {
        global $default_charset,$adb;
        $columnname = $this->getColumnName($key, $fieldName);
        if ($columnname == "-1")
            return '$$##';
        if (is_array($this->relatedfldarray) && array_key_exists($fieldName, $this->relatedfldarray)) {
            return '$$##';
        }
        $field = $this->getListViewFieldobj($key, $fieldName);
        $uitype = $field->getUIType();
        $rawValue = $this->db->query_result($this->result, $i, $columnname);


        if ($uitype != 8) {
            $value = html_entity_decode($rawValue, ENT_QUOTES, $default_charset);
        } else {
            $value = $rawValue;
        }
        foreach ($this->urlparams as $urltype => $urlparam) {
            $this->listviewFieldValue->AddUrlParams($urltype, $urlparam);
        }

		$showvalue=$showfieldvalueobj->getFieldValueByField($field,$rawValue,$value);
		$value = $showvalue['value'];
		if('assigned_user_id' == $columnname){
			$query = 'select last_name,wx_userid form ld_users where id = ? limit 1';
			$result = $adb->pquery($query,array($showvalue['rawvalue']));
			$num_rows = $adb->num_rows($result);
			$userobj=new Users();
			$userobj->wx_userid=$adb->query_result($result,0,'wx_userid');
			$userobj->last_name=$adb->query_result($result,0,'last_name');
			$entityContent['username']=getUserlastName($userobj);
		}
		
        //$value = $this->listviewFieldValue->getListViewFieldValue($field, $showfieldvalueobj, $rawValue, $value);

        return $value;
    }

	public function setListRowValue($field, $value, $row)
    {
		$row[$field->getFieldName()] = $value;
		return $row;
    }

    public function getHeaderName()
    {
        return $this->queryGenerator->productDetails->getListViewHeaderInfo();
    } 

}


?>