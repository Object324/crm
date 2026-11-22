<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/4/26 0026
 * Time: 下午 3:30
 */
crm_load_class_file('cls_OptionModule','include/OptionModule');
class cls_OptionModuleWX extends cls_OptionModule
{
    public static function   getInstance($module,$record=0)
    {

        if(is_array($instance)&&sizeof($instance)>0&&$instanceobj[$module])
        {
            return $instance;
        }
        return $instanceobj[$module]=new cls_OptionModuleWX($module,$record);
    }
    /**
     *
     * 获取模块的源单信息
     * */
    public function getsourceInfoValues()
    {
        $parent = parent::getsourceInfoValues();
        if(!empty($_REQUEST['relatedCreationInfo'])&&empty($parent)){//关联新增
            $creationinfojson = $_REQUEST['relatedCreationInfo'];
            $creationinfo = json_decode($creationinfojson,true);
            $arr[]=array('entitytype'=>$creationinfo['frommodule'],'entitytypeid'=>$creationinfo['fromid'],
                'value'=>getModuleHref($creationinfo['frommodule'],$creationinfo['fromid']));
        }else{//编辑
            $arr = $parent;
        }
        return $arr;
    }

}