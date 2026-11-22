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
crm_load_class_file('Parent_ProductDetailsData','include/ProductDetailsHtml');
class cls_productDetailsData extends Parent_ProductDetailsData{
	
	public function __construct($module){
		parent::__construct($module);
	}

	//重写获取明细sql
	function getProductToolFieldSql($frommdouleFocus){
		$sql=$this->getInventorySql($frommdouleFocus);
		if($this->focus->id > 0 && empty($frommdouleFocus->lineitemIds)){//单据编辑、详情条件
             $detailtable=$this->focus->Detail_table;
			$sql .= " where $detailtable.id in ( " . $this->focus->id . ')';	
		}elseif(!is_null($frommdouleFocus->lineitemIds)&&trim($frommdouleFocus->lineitemIds)!="") {	//选择源单条件
            $detailtable=$frommdouleFocus->Detail_table;
			$sql .= " where $detailtable.lineitem_id in ( " . $frommdouleFocus->lineitemIds. ')';

			// @edit:liushuai,2021-06-05,reason:【ID1001679】带产品分录的表单，选择源单字段->源单类型定制中增加字段属性参数“剩余数量为0时自动带出“
            $sql .= $this->getWhereNotWithBalanceqty($frommdouleFocus);
		}
        else{
            return '';

        }
		//出库或入库时必须严格参照源单（每种产品累计数量不允许超出源单或者出现源单外的产品）。0:是，1:否
		/*if($_REQUEST['isDuplicate'] != 'true' && $this->productdetail_mode != 'edit' && $this->productdetail_mode != 'details'){
			$sysdeploy3= getSys_deploy(10);
			if($sysdeploy3['deploy_value'] == 0){
				$sql .=" and $detailtable.balancepurchasecount > 0";
			}
		}*/
		//设置源单分录明细范围
        $sql .= $this->getOtherSourceModuleSqlWhere();
		$sql .= " order by $detailtable.sequence_no asc";
        
		return $sql;
	}

	public function getHiddenQuantity($isDuplicate,$productdetail_mode,$productinfo,$frommoduleFocus,$quantity){
		global $adb;
		$hiddenquantity = 0;
		if($isDuplicate == true || $productdetail_mode == 'edit'){
		   $isRelatedModuleCreate=$this->isRelatedModuleCreate($frommoduleFocus);
         
          if($isRelatedModuleCreate=='yes')
          {
            //选择原单会调用该函数
            $detailtable=$frommoduleFocus->Detail_table;
            $customformmodules=array('CustomForm11','CustomForm12','CustomForm13','CustomForm14','CustomForm15','CustomForm16','CustomForm17','CustomForm18','CustomForm19','CustomForm20');
            if(in_array($frommoduleFocus->moduleName,$customformmodules))
            {
                return $quantity;
            }
          }
          else
		      $detailtable=$this->focus->Detail_table;
		  
			$query = " SELECT
					balancepurchasecount
				FROM
					$detailtable
				WHERE
					$detailtable.id = ?
				AND $detailtable.productid = ?
				AND $detailtable.lineitem_id = ? ";
			$result = $adb->pquery($query,array($productinfo['entitytypeid'],$productinfo['productid'],$productinfo['parent_lineitem_id']));
		
        	$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$hiddenquantity = $adb->query_result($result,0,0);
			}
		}
		if($productdetail_mode == 'edit' && $isDuplicate != 'true'){
			$hiddenquantity += $productinfo['column_value'];
		}
		return $hiddenquantity;
	}

	//重写获取明细行自定义字段和属性
	public function getProductToolTrData($frommdouleFocus='',$productdetail_mode=''){
		global $adb;
		$productToolTr = parent::getProductToolTrData($frommdouleFocus);
		if(!empty($productToolTr)){
			if($productdetail_mode == 'edit' || $productdetail_mode == 'details'){
			      $detailtable=$this->focus->Detail_table;
				$query = " select entitytype from $detailtable where id = ? and entitytype is not NULL limit 1";
				$result = $adb->pquery($query,array($this->focus->id));
                if($adb->num_rows($result)>0)
				    $entitytype = $adb->query_result($result,0,0);
			}else if($productdetail_mode == 'create' || $productdetail_mode == 'addrow_create'){
				$tabid = getTabid($this->module);
				crm_load_class_file('cls_OptionModule','include/OptionModule');
				$cls_OptionModule =cls_OptionModule::getInstance($this->module,'');
				$optionmodule_data = $cls_OptionModule->getData();
				if(!empty($optionmodule_data[$tabid]) && is_array($optionmodule_data[$tabid])){
					$optionmodule = array_keys($optionmodule_data[$tabid]);
				}else{
					$optionmodule = [];
				}
				if(!empty($optionmodule[0])){
					$entitytype = getTabModuleName($optionmodule[0]);
				}
			}else{
				$entitytype = $frommdouleFocus->module;
			}
			//edit:can 202312122 77617 入库单的第二行的采购含税单价错位 
		/*	foreach($productToolTr as $key => $producttoolinfo){
				if((strtolower($entitytype) == 'purchaseorder' || $_REQUEST['contract_display'] == 'none') && $producttoolinfo->getUIType() == 205){
					unset($productToolTr[$key]);
				}
			}*/
            
			$productToolTr = array_values($productToolTr);
		}
		return $productToolTr;
	}

    public function getSourceModuleBalanceValue($frommoduleFocus,$autobalancecolumnname)
    {
        static $static_sourcebalancevalue_arr;
        if(is_array($static_sourcebalancevalue_arr)&&array_key_exists($frommoduleFocus->id,$static_sourcebalancevalue_arr))
        {
            return $static_sourcebalancevalue_arr[$frommoduleFocus->id];
        }
        global $adb;
        $columnname=$autobalancecolumnname;

        $sourcefieldinfo=$frommoduleFocus->detailfieldobj->getFieldInfoobjBykey("columnname",$autobalancecolumnname);
        //duan 2022-6-8 源单字段未启用或缺少字段权限时无法带出源单数量和价格
        if(empty($sourcefieldinfo)){
            return array();
        }
        $fieldinfo=$this->focus->detailfieldobj->getFieldInfoobjBykey("columnname",$autobalancecolumnname);
        //duan 2022-6-8 当前单据单据字段未启用或缺少字段权限时无法带出源单数量和价格
        if(empty($fieldinfo)){
            return array();
        }
        $system_49 = getSys_deploy(49);
        if(is_numeric($system_49['deploy_value'])){
            $typeofdata_decimal = $system_49['deploy_value'];
        }
        else {
            $typeofdata_decimal = 2;
        }
        if($autobalancecolumnname != 'quantity' || $frommoduleFocus->moduleName != 'PurchaseOrder'){
            return parent::getSourceModuleBalanceValue($frommoduleFocus,$autobalancecolumnname);
        }
        //zkt 20240507 BUG20240506-67  采购订单（产生过退货）有未入库数量但是下推入库单后不能自动带出相应数量
        $source_detailtabname = $frommoduleFocus->Detail_table;
        $sql = "select lineitem_id, IFNULL(balancepurchasecount,IFNULL(quantity,0)-IFNULL(havepurchasecount,0)) as $autobalancecolumnname from $source_detailtabname where id=? ";
        $result=$adb->pquery($sql,array($frommoduleFocus->id));
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {

            $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
            $value=$adb->query_result($result,$i,$autobalancecolumnname);
            $balancevalue=setNumberFormatEmptySeperator($value,$typeofdata_decimal);
            $tmp_arr[$lineitem_id]=$balancevalue;

        }
        $static_sourcebalancevalue_arr=[];
        $static_sourcebalancevalue_arr[$frommoduleFocus->id]=$tmp_arr;

        return $tmp_arr;
    }
}
?>