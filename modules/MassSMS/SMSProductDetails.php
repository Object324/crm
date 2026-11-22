<?php

 crm_load_class_file("ProductDetails",'include/ProductDetails');
class SMSProductDetails extends ProductDetails
{
      private $module;
     private $focus;
     private $tabid;
     
    public function ____construct($module,$languagetran="")
    {
        $this->module=$module;
        $this->tabid=getTabid($module);
        $this->focus=CRMEntity::getInstance($module) ;
    }
    public function getSelectColumn($tabid)
    {
      
        $fieldname=trim(trim($_REQUEST['fieldname'],","));
         $fieldnames=explode(",",$fieldname);
         $index=1;
        $column_list[$index]=" ld_account.accountname ";
        $this->fields_property[]="Accounts";
         $index++;
       $isContacttable='no';
     
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
                $fieldinfo=$otherfocus->fieldobj->getFieldInfoobjBykey("fieldname",$realfieldname);
                $column_list[$index]=$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();
                if($fieldinfo->getTableName()=='ld_contactdetails'||$fieldinfo->getTableName()=='ld_contactscf')
                {
                    $isContacttable='yes';
                }
                $this->fields_property[]=$othermodule;
             }
            else
            {
               
                $fieldobj=$this->focus->fieldobj;
                $fieldinfo=$fieldobj->getFieldInfoobjBykey("fieldname",$realfieldname);
                $this->fields_property[]=$this->module;
                $column_list[$index]=$fieldinfo->getTableName().'.'.$fieldinfo->getColumnName();
            }
            $this->list_fields[]=$realfieldname;
            $index++;
        }
        if($isContacttable=='yes')
        {
            $column_list[$index]=" ld_contactdetails.lastname ";
            $this->fields_property[]="Contacts";
        }
        
        $columnlist=array_filter($column_list);
       $this->HeaderColumns=$column_list;
    
        return implode(',', $column_list);
    }
}

?>