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
	
	public function __construct($module,$sourcemodulename){
	   $this->sourcemodulename=$sourcemodulename;
     
        $this->sourcemodule_arr=getSourceModule($module);
        parent::__construct($module);
	
	}
    
    function setproducttoolfieldwhere ($sourceModuletype)
    {
           $this->productToolFields->sourceModulesql = " ld_producttoolfield.sourcemodule='$sourceModuletype' ";
    }
    
     /**
     * 获取源单剩余未收金额
     * */
    public function getSourceModuleBalanceValue($frommoduleFocus,$autobalancecolumnname)
    {
        global $adb ;
        $source_detailtabname = $frommoduleFocus->Detail_table;
        $system_351 = getSys_deploy(351);
        if(is_numeric($system_351['deploy_value'])){
            $typeofdata_decimal = $system_351['deploy_value'];    
        }
        else {
            $typeofdata_decimal = 2;
        }
        $sql="select lineitem_id,$autobalancecolumnname from $source_detailtabname where id=?";
        if($autobalancecolumnname == 'balancereceivedamount'){
            $sql = "select lineitem_id, IFNULL(balancereceivedamount,IFNULL(tax_amount,0)-IFNULL(havereceivedamount,0)) as $autobalancecolumnname from $source_detailtabname where id=? ";
        }
        $result=$adb->pquery($sql,array($frommoduleFocus->id));
       $rows=$adb->num_rows($result);
       for($i=0;$i<$rows;$i++)
        {
            
             $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
             $value=$adb->query_result($result,$i,$autobalancecolumnname);
          
            $balancevalue=setNumberFormatEmptySeperator($value,$typeofdata_decimal);
            
            $tmp_arr[$lineitem_id]=$balancevalue;
            
        }
       
        return $tmp_arr;
    }
    
    public function getAutoBlanceColumn($frommodule,$fieldinfo)
    {
           foreach($this->sourcemodule_arr as $sourcemoduleinfo)
           {
                if($frommodule==$sourcemoduleinfo['entitytype'])
                {
                    if($fieldinfo->getColumnName()=='amount')
                        $autobalancevalue='balancereceivedamount';
                    break;
                }
           }
           return $autobalancevalue;
    }
}
?>