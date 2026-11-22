<?php

class SMSCustomView extends CustomView
{
    
     private $module;
     public  $focus;
     private $tabid;
     public  function ____construct($module='')
     {
       
        $this->module=$module;
        $this->tabid=getTabid($module);
        $this->focus=CRMEntity::getInstance($module) ;
        $tmp_field_obj=$this->focus->fieldobj;
        $this->searchFieldArr=$tmp_field_obj->getSearchKeyField();
       
     }
     /**
      * 重写父类方法(排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
        $maintable_name=$this->focus->table_name;
        return $maintable_name.'.'.$this->focus->table_index.' desc';
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
         $fieldname=trim(trim($_REQUEST['fieldname'],","));
         $fieldnames=explode(",",$fieldname);
         $index=0;
        foreach($fieldnames as $fieldname)
        {
             $realfieldname=$fieldname;
             if(strpos($fieldname,"#")!==false)
             {
                //目前只有客户或服务收费管理模块有该功能
                $modules=explode("#",$fieldname);
                $othermodule=$modules[0];
                $realfieldname=$modules[1];
                $otherfocus=CRMEntity::getInstance($othermodule);
                $fieldinfo=$otherfocus->fieldobj->getFieldInfoobjBykey('fieldname',$realfieldname);
                $column_list[$index]=$fieldinfo->getTableName().':'.$fieldinfo->getColumnName().':'.$realfieldname.':'.$othermodule.'_fieldlabel'.$fieldinfo->getTypeOfData();
                
             }
            else
            {
                $fieldobj=$this->focus->fieldobj;
                $fieldinfo=$fieldobj->getFieldInfoobjBykey('fieldname',$realfieldname);
                $column_list[$index]=$fieldinfo->getTableName().':'.$fieldinfo->getColumnName().':'.$realfieldname.':'.$this->module.'_fieldlabel'.$fieldinfo->getTypeOfData();
            }
            $index++;
        }
       
        return $column_list;
    }
  
    
    
    
}


?>