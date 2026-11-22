<?php
//editor:gyq_145 reason:销售机会增加产品分录  2019/9/19 17:35
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
class cls_Potentials_SaveWX extends cls_SaveWX{
    //gyqTE 熟悉这段代码
    public function setFieldInfoFromPost(){
        parent::setFieldInfoFromPost();
        $wx_productFieldInfo = $_REQUEST['wx_productFieldInfo'];
        if(!empty($wx_productFieldInfo)){
            foreach($wx_productFieldInfo as $key=>$value){
                $_REQUEST[$key] = $value;
            }
        }
       $entitytype="";
        if(isset($_REQUEST['relatedCreationInfo'])&&$_REQUEST['relatedCreationInfo']!='')
        {
            $relatedCreationInfo=json_decode($_REQUEST['relatedCreationInfo'],true);
            $entitytype=$relatedCreationInfo['frommodule'];
            
        }
        else
        {
            
        }
       
        for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
            $_REQUEST['before_lineitem_id'.$i] = $_REQUEST['detailid'.$i];
            if($entitytype!="")
                $_REQUEST['entitytype'.$i] = $entitytype;
        }
        $p_total = $_REQUEST['p_total'];
        $newp_total = array();
        if(!empty($p_total)){
            foreach($p_total as $fieldname=>$content){
                if($fieldname=='adjustment'){
                    $_REQUEST['adjustmentType'] = $content['adjustmentType'];
                }elseif($fieldname=='discount_amount'){
                    $_REQUEST['allSingledDiscount'] = $content['allSingledDiscount'];
                }
                $_REQUEST[$fieldname] = $content['value'];
            }
        }
    }

    //zxm 销售机会重复判断
    protected function check_before_field_duplicate()
    {
        crm_load_class_file('cls_rule_validata','include/utils');
        $tabid = getTabid($_REQUEST['module']);
        if(!empty($_REQUEST['wx_fieldInfo'])){
            foreach($_REQUEST['wx_fieldInfo'] as $columnanme => $value){
                $_REQUEST[$columnanme] = $value;
            }
        }
        if(empty($_REQUEST['confirm_save'])){
            $cls_interface_yaoji = new cls_rule_validata($tabid);
            $data = $cls_interface_yaoji->get();
            if(!empty($data)){
                if($data['rule_result'] == 'NoSave')
                    ConvertTojsonString(-1, $data['rule_result'], $data['tips']);
                else
                    ConvertTojsonString(2, $data['rule_result'], $data['tips']);
            }
        }
    }
}