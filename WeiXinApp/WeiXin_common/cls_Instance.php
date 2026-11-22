<?php
/**
 * 更新操作
 * 操作人: Yan
 * 日期: 2016/8/19
 * 时间: 11:13
 * 说明:
 */
class cls_Instance
{
    public static function get_module_Instance($r_module)
    {
        $crmmodules = CRMEntity::getStaticVar_Instance();//editor:gyq data:20170607
        //editor:gyq_109 reason:日程管理模块  2019/4/29 15:15
        $modarray = array('Calendar'=>'1','Events'=>'1');
        if (isset($modarray[$r_module])) {
            $file_module = 'Calendar';
            $modName = 'Activity';
        }else{
            $file_module = $modName = $r_module;
        }
        if($crmmodules[$modName] instanceof CRMEntity){
            return $crmmodules[$modName];
        }else{
            static $module_Instance;
            if ($module_Instance[$modName]){
                return $module_Instance[$modName];
            }
			//chj 2021/7/21 47048: （81mis.com/kfbcrm）系统设置-页面设置-日程管理，编辑字段打不开，弹窗界面一直加载
		//	require_once (globalStatic::$root_directory . 'WeiXinApp/WeiXin_common/StaticConst.php');
            
        
            $module_path = globalStatic::$root_directory.'WeiXinApp/modules/' . $file_module.'/'.StaticConst::$module_class_Prev_Name . $modName.'.php';
            if(is_file($module_path)){//editor:gyq data:20170608
                crm_load_class_file(StaticConst::$module_class_Prev_Name . $modName, 'WeiXinApp/modules/' . $file_module);
                $str_class_name = StaticConst::$module_class_Prev_Name . $modName;
                $module_Instance[$modName] = new $str_class_name();
                $module_Instance[$modName]->moduleName = $modName;
                $tmp_instance=&CRMEntity::getStaticVar_Instance();//gyqNote 20170607
                $tmp_instance[$modName]=$module_Instance[$modName];
                return $module_Instance[$modName];
            }else{
                $crmmodule = CRMEntity::getInstance($modName);
                return $crmmodule;
            }

        }
    }

    public static function get_moduleAction_Instance($module, $action)
    {
        $classname = 'cls_' . $module . '_' . $action . 'WX';
        crm_load_class_file($classname, 'WeiXinApp/modules/' . $module . '/cls_' . $module);
        return new $classname($module);
    }
    public static function get_commonAction_Instance($module, $action)
    {
        $classname = 'cls_' . $action . 'WX';
        crm_load_class_file($classname, 'WeiXinApp/modules/' . $module . '/cls_' . $module);
        return new $classname();
    }
}

?>