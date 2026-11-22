<?php

crm_load_class_file('cls_ChangeCreatorInfo','modules/Users');
class cls_ChangeCreatorInfoWX extends cls_ChangeCreatorInfo
{
    protected function setReturnStyleInDetail(){
        if ($_REQUEST['mode'] == 'detail') {
            $edit_err = '被分配人'.getUserFullName($_REQUEST['caterorid']).'公海客户数量已达上限!';
            $entity['code'] = -1;
            $entity['msg'] = $edit_err;
            $json = new Zend_Json();
            $jsonentity = $json->encode($entity);
            echo $jsonentity;
            exit;
        };
    }
    //根据app需求修改返回值格式
    protected function setsaveReturn($entity)
    {

        ob_clean();
        ob_flush();
        $json = new Zend_Json();
        $new_entity = array();
        if($entity['errorcount']>0)
        {
            $new_entity['code'] = 0;
        }
        else
                $new_entity['code'] = 1;
        $versionInfo = getVersionInfo();
        //zxm 1228 陌远特殊开发 销售机会保存查重以及判断有效销售机会数量
        if($versionInfo['account'] == "moyuan"){
            echo $json->encode($entity['moyuan_msg']);
            die;
        }
        $new_entity['msg'] = $entity['log']['value'];

        crm_load_class_file("cls_savereverse", 'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($_REQUEST['from_module']);
        $workflowreverseobj->setPageMode('Allocated');
        $receive_msg = $workflowreverseobj->checkCallApiPop();
        $new_entity['result']['workflow']['receive_msg'] = $receive_msg;
        if ($receive_msg == 'yes') {
            $new_entity['result']['workflow']['record'] = $_REQUEST['select_id'];
            $new_entity['result']['workflow']['module'] = $_REQUEST['from_module'];
            $new_entity['result']['workflow']['pagemode'] = $workflowreverseobj->getPageMode();
        }

        $jsonentity = $json->encode($new_entity);
        echo $jsonentity;
        die;
    }
    public function getUserId()
    {
        $caterorid = $_REQUEST['caterorid'];
        if(isset($_REQUEST['wx_suite'])&&$_REQUEST['wx_suite']=='yes'){
            $useridarr = cls_StaticCommonFun::getIdFromWxUserid($caterorid);
            $_REQUEST['caterorid'] = $userid = implode(',',array_values($useridarr));
            return $userid;
        }
        return  $caterorid;
    }
    
}


?>