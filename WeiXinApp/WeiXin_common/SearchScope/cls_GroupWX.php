<?php
require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
class cls_GroupWX extends Group{
    //editor:gyq_28 date:20170323  reason:移动端增加额外限制
    protected function getGroupListUser_expansion($filterown)
    {
        $sql='';
        if($filterown == 'yes'){//过滤自己
            global $current_user;
            $sql= ' and ld_users.id != '.$current_user->id.' ';
        }
        //默认不显示停用用户
        // $sql .= ' and ld_users.status = \'Active\' ';
        /** 
        * @edit:diony 
        * @date:2020-07-17
        * @reason:获取所有用户
        * @reason:设置移动端通讯录中是否显示离职人员。1:否，0:是
        * @description:$this->cls_methodObj->isactive 前端传值，目前没参考前端传值，直接读取后台参数
        */
        $deploy_values_213=getSys_deploy(213);
        if($deploy_values_213['deploy_value'] == 1){
            $sql .= ' and ld_users.status = \'Active\' ';
        }
        return $sql;
    }
    // editor:gyq date:20170323
    public function getGroupListUser($fld_module='',$view='',$filterown='',$selecttyp='',$ishighseaallocate='no',$filterrecordid='',$fld_fieldname='')
    {
        parent::getGroupListUser($fld_module, $view, $filterown, $selecttyp, $ishighseaallocate, $filterrecordid,$fld_fieldname);
        return $this->grouparrayMC;
    }
}