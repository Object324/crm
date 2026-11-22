<?php
/**
 * 客户和供应商资质相关控制
 */
 class CheckMaturitydate
 {
    private $relate_module,$related_id;
    private $error;
    public function __construct($relate_module,$related_id)
    {
        $this->relate_module=$relate_module;
        $this->related_id=$related_id;
    }
    public function ret_Check()
    {
        $this->check();
        if(!empty($this->error))
        {
            echo  $this->error;
        }
        else
        {
            echo '#&#Success#&#';
        }
    }
    private function check()
    {
        global $adb;
        $relate_id=$this->related_id;
        $relate_module=$this->relate_module;
        if(!empty($relate_id)){
                    $focus = CRMEntity::getInstance($relate_module);
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname",'qualifymaturitydate');
                    
                    if($fieldinfo){
                        $focus->retrieve_entity_info($relate_id,$relate_module);
                        $qualifymaturitydate = $focus->column_fields['qualifymaturitydate'];
                        
                        //客户或供应商的资质到期日有值，并且小于当前日期
                        if(!empty($qualifymaturitydate) && strtotime("-1 day")>strtotime($qualifymaturitydate)){
                            $this->error= sprintf(getFixedLabel('QUALIFYMATURITYDATEEXPIRED'),getTranstab($relate_module),$fieldinfo->getFieldLabelKey());
                            return ;
                        }
                    }
        }
        
        //客户或供应商资质到期日有效，继续判断产品的注册证到期日
        $productids = trim($_REQUEST['productid'],',');
        if($productids != ''){
            $pro_focus = CRMEntity::getInstance('Products');
            $fieldinfo=$pro_focus->fieldobj->getFieldInfoobjBykey("fieldname",'regmaturitydate');
            if($fieldinfo){
                $sql = "select productid,productname,regmaturitydate from ld_products where productid in($productids)";
        
                $result = $adb->pquery($sql,array());
                $num_rows = $adb->num_rows($result);
                if($num_rows > 0){
                    for($i=0;$i<$num_rows;$i++){
                        $productid = $adb->query_result($result,$i,'productid');
                        $regmaturitydate = $adb->query_result($result,$i,'regmaturitydate');
                        $productname = $adb->query_result($result,$i,'productname');
                        $pro_reg[$productid]['regmaturitydate'] = $regmaturitydate;
                        $pro_reg[$productid]['productname'] = $productname;
                    }
                }
            }
        }
        
        if(!empty($pro_reg)){
            foreach($pro_reg as $val){
                //产品的注册证到期日有值，并且小于当前日期
                if(!empty($val['regmaturitydate']) && strtotime("-1 day")>strtotime($val['regmaturitydate'])){
                    $this->error= sprintf(getFixedLabel('REGMATURITYDATEEXPIRED'),$val['productname']);
                   return ;
                }
            }
        }
        
        
        

    }
 }



?>