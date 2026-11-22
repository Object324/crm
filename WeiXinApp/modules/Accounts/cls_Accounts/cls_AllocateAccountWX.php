<?php

/**
 * Created by PhpStorm.
 * User: gyq_19
 * Date: 2016/11/15 0015
 * Time: 下午 1:46
 */
crm_load_class_file('cls_AllocateAccount','modules/Accounts');
class cls_AllocateAccountWX extends cls_AllocateAccount{
      public function __construct()
      {
        parent::__construct();
        if($_REQUEST['allocate_userid']>0)
        {
            $this->allocatetype=2;
        }
        else
        {
            //客户被自动回收后     天内不允许被当前负责人再次领取（为0或空表示不控制）
            $this->allocatetype=3;
        }
      }
    //根据不同端重写输出不同返回格式
    protected function exportReminds($msg,$type){
        
        $msg = '';
        $mark = -1;
        switch ($type){
            case 'R1':
                $msg = '该客户已分配';
                $mark = -1;
                break;
            case 'R2':
                $msg = '被分配人公海客户数量已达上限';
                $mark = -1;
                break;
            case 'R3':
                $msg = 'can be distributed';
                $mark = 1;
                break;
            case 'R4':
                $msg = 'can be distributed';
                $mark = 1;
                break;
            case 'R5':
                $msg = getFixedLabel('accounthasnotallocated');
                $mark = -1;
                break;
            case 'R21':
                $msg = '您拥有的公海客户数量已达上限，创建失败';
                $mark = -1;
                break;
            case 'obtainaccountmsg':
                 $msg = getFixedLabel('ObtainAccountError');
                $mark = -1;
                break;
            case 'RS':
                $msg = '确定要领取吗？';
                $mark = 1;
        }
        ConvertTojsonString($mark,null,$msg);
    }
}
?>
