<?php
/**
 * User: diony
 * Date: 2019/03/01
 */
crm_load_class_file('cls_SaveWX','WeiXinApp/detail');
class cls_SalesBack_SaveWX extends cls_SaveWX{
    //gyqTE 熟悉这段代码
    public function setFieldInfoFromPost(){
        parent::setFieldInfoFromPost();
        $wx_productFieldInfo = $_REQUEST['wx_productFieldInfo'];
        if(!empty($wx_productFieldInfo)){
            foreach($wx_productFieldInfo as $key=>$value){
                $_REQUEST[$key] = $value;
            }
        }
        for($i=1;$i<=$_REQUEST['rowcnt'];$i++){
            $_REQUEST['before_lineitem_id'.$i] = $_REQUEST['detailid'.$i];
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
}