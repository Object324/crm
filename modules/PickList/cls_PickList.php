<?php

/**
 * Created by PhpStorm.
 * User: gyq_64
 * Date: 2018/3/7 0007
 * Time: 下午 1:36
 */
crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
class cls_PickList extends cls_PickList_Ori
{
    //原内容被移至Functions目录下
    public static function getInstance($rFieldName,$rObjField)
    {
        //参考：getPickListValues函数
        static $static_picklistobj;
        $class_name = get_class($rObjField);
         if(is_array($static_picklistobj)&&array_key_exists($rFieldName,$static_picklistobj)&&array_key_exists($class_name,$static_picklistobj[$rFieldName]))
         {
            return $static_picklistobj[$rFieldName][$class_name];
         }
        
        $objPickList=new cls_PickList();
        $static_picklistobj=array();
        $static_picklistobj[$rFieldName][$class_name]=$objPickList;
        return $objPickList;
        
    }
}