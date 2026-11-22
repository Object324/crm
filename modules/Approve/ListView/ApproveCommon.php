<?php
function ApproveCommonFieldSql($conditionInfo)
{
    if($conditionInfo['tablename']=='tmp_approve')
    {
            if($conditionInfo['name']=='approveby_user')
            {
                $fieldSql="  approveby_user_user.last_name like '%".$conditionInfo['value']."%'";
                
            }
            else if($conditionInfo['name']=='approveby_datetime')
            {
                $fieldSql="  tmp_approve.approveby_datetime  like '%".$conditionInfo['value']."%'";
            }
            // $this->whereMainTable['tmp_approve']= "  ld_users   as approveby_user_user on approveby_user_user.id=tmp_approve.approveby_user ";
            return $fieldSql;
    }
    return '';
    
}


?>