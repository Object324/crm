<?php
crm_load_class_file('cls_ProductDetailUitype_PageRecordValueMC','appCommon/include/ProductDetailsHtml');
class cls_ChooseEntityDetailhtml extends cls_ProductDetailUitype_PageRecordValueMC
{
    public $unallowRepeat = 'no';
    public $selectDetailLineitemid = '';


     public function getValues()
     {

        $record_arr=explode(",",$this->record);
        $ret_value=[];
        $unallowrepeat = $this->getUnallowRepeat();
        $unallowrepeatwithdetail = 'no';
         $selectDetailLineitemid_arr = [];
        if ($unallowrepeat == 'yes'){
            $selectDetailLineitemid= $this->getSelectDetailLineitemid();
            if (!empty($selectDetailLineitemid)){
                $unallowrepeatwithdetail = 'yes';
                $selectDetailLineitemid_arr = explode(',',$selectDetailLineitemid);
                $selectDetailLineitemid_arr = array_flip($selectDetailLineitemid_arr);
            }
        }
        foreach($record_arr as $tmprecord)
        {
            $lineitems=[];
            $lineitems_str = substrTd($tmprecord . ',', 0,$this->fromFocus->module_name);
            if ($unallowrepeatwithdetail == 'yes' && sizeof($selectDetailLineitemid_arr)>0){
                $newlineitems_arr = [];
                $lineitems_arr = explode(',',$lineitems_str);
                foreach ($lineitems_arr as $tmpkey => $tmp_lineitemid){
                    if (!array_key_exists($tmp_lineitemid,$selectDetailLineitemid_arr)){
                        $newlineitems_arr[]=$tmp_lineitemid;
                    }
                }
                $lineitems_str = implode(',',$newlineitems_arr);
            }
            $lineitems[] = $lineitems_str;//获取明细表id
            $this->fromFocus->lineitemIds = implode(',',$lineitems);
           $tmparr= parent::getValues();
           $ret_value=array_merge($ret_value,is_array($tmparr['value'])?$tmparr['value']:[]);
        }
        $tmparr['value']=$ret_value;

        return $tmparr;

     }
    
    
    public function createfromFocus()
    {
        global $adb;

        if ($this->pagemode == "sourcemodule_create" || $this->pagemode == 'module_create' || $this->frommodule == 'Products') {
            $this->fromFocus = CRMEntity::getInstance($this->from_module);
            $this->fromFocus->retrieve_entity_info($this->record,$this->module);
            $this->fromFocus->module = $this->from_module;
            $this->fromFocus->id=$this->record;
           
        } else {
            $this->fromFocus = $this->createFocus();
        }
        return $this->fromFocus;

    }
    public function setUnallowRepeat($unallowRepeat){
         $this->unallowRepeat = $unallowRepeat;
    }
    public function getUnallowRepeat(){
         return $this->unallowRepeat;
    }
    public function setSelectDetailLineitemid($selectDetailLineitemid){
        $this->selectDetailLineitemid = $selectDetailLineitemid;
    }

    public function getSelectDetailLineitemid(){
        return $this->selectDetailLineitemid;
    }


}

?>