<?php

global $adb,$app_strings,$mod_strings,$current_user,$adb;

if($_REQUEST['ajax']=='true'){
    $seltab =$_REQUEST['seltab'];
    switch ($seltab)
    {
        case 5:
            $seltable = 'ld_tab';//交通补贴报销比例
            $setvalue = 'Proportion';
            $wherevalue = 'tabid';
            break;
        case 1:
            $seltable = 'productcategory';//$产品$_$产品类别$
            $setvalue = 'scores';
            break;
        case 2:
            if($_REQUEST['servicetype']==getFixedLabel('ByCity'))
            {
                $seltable = 'bill_city';//$客户$_$城市$
                $SQL="update ld_picklist_values
                inner join ld_picklist_set
                on ld_picklist_set.listid=ld_picklist_values.listid
                 set scores=''
                where ld_picklist_set.listname='bill_area'";
            }
            else
            {
                $seltable = 'bill_area';//$客户$_$区域$
                 $SQL="update ld_picklist_values
                inner join ld_picklist_set
                on ld_picklist_set.listid=ld_picklist_values.listid
                 set scores=''
                where ld_picklist_set.listname='bill_city'";
            }
            $adb->pquery($SQL,array());
            $SQL='update ld_systems_deploy set deploy_value=? where deploy_type=?';
            $adb->pquery($SQL,array($seltable,207));
            getSys_deploy('assssssssssss');
            $setvalue = 'scores';
            break;
        case 3:
            $seltable = 'ticketcategories';//$服务单$_$故障类别$
            $setvalue = 'weight';
            break;
        case 4:
            $seltable = 'projecttasktype';//$项目任务$_$类型$
            $setvalue = 'weight';
            break;
        case 6:
            $seltable = 'servicetype';//服务方式绩效权重
            $setvalue = 'weight';
            break;
        /*case 1:
            $seltable = 'ld_productcategory';//$产品$_$产品类别$
            $setvalue = 'scores';
            $wherevalue = 'productcategoryid';
            break;
        case 2:
            $seltable = 'ld_bill_city';//$客户$_$城市$
            $setvalue = 'scores';
            $wherevalue = 'bill_cityid';
            break;
        case 3:
            $seltable = 'ld_ticketcategories';//$服务单$_$故障类别$
            $setvalue = 'weight';
            $wherevalue = 'ticketcategories_id';
            break;
        case 4:
            $seltable = 'ld_projecttasktype';//$项目任务$_$类型$
            $setvalue = 'weight';
            $wherevalue = 'projecttasktypeid';
            break;
        case 6:
            $seltable = 'ld_servicetype';//服务方式绩效权重
            $setvalue = 'weight';
            $wherevalue = 'servicetypeid';
            break;    */
    }

    $count = $_REQUEST['count'];
    $roleid = $_REQUEST['roleid'];
    if($count!==''||$roleid!==''){
        //Eidtor:gyq_64 Reason:下拉框改进 Date:2018/3/13 0013 下午 6:08
        if($seltable=='ld_tab'){
            $SQL = "update $seltable set $setvalue = $count where $wherevalue = $roleid";
            $result=$adb->pquery($SQL,array());
        }else{
            crm_load_class_file("cls_PickList_ServeicePer", 'modules/PickList');
            $objpinklist = new cls_PickList_ServeicePer();
            $objpinklist->savePickFieldEdit_Ser($setvalue,$count,$roleid);
        }
        echo '###SUCCESS###';
    }else{
        echo '###USEDEN###';
    }
}
?>