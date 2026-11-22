<?php
/***
首页组件视图-》销售漏斗点击弹出层查询
***/
class PotentialsSalesStateView extends CustomView
{
     private $module;
     public  $focus;
     private $tabid;
     public  function __construct($module='')
     {
       
        $this->module=$module;
		$this->customviewmodule = $module;
        $this->tabid=getTabid($module);
        $this->focus=CRMEntity::getInstance($module) ;
        
     }
     /**
      * 重写父类方法(排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
        $customorder=parent::getCustomViewOrderBy($viewid);
        return $customorder;
        //return $this->focus->table_index.' desc';
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
      
       $column_list=parent::getColumnsListByCvid($viewid);
       
     
        return $column_list;
    }
    /**
     * 重写父类基本查询方法
     * */
	function getStdFilterByCvid($cvid) {
	  return $this->getStdFilterByautoid();
      
	}
    /**
     * 重写父类高级查询方法
     * */
     public function  getAdvFilterByCvid($cvid) {
         return $this->getAdvFilterByautoid();
        }
     /**
      * 获取基本查询条件
      * */
    function getStdFilterByautoid() {
	  return array();
	}
    
   function getViewId($module='',$popup='')
   {
      global $adb;
      $sql='select  cvid ,pagewidthpercent from ld_customview where  entitytype=? and viewname=?';
      $result=$adb->pquery($sql,array('Potentials','All'));
      $viewid=$adb->query_result($result,0,0);
      $this->pageWidthPercent=$adb->query_result($result,0,1);
      return $viewid;
   }
    /**
     * 获取高级查询条件
     * */
	function getAdvFilterByautoid() {
         global $adb;
    	  $keywords=$_REQUEST['sales_stage'];
          
          if(!empty($keywords))
          {
             
                $advft_criteria[0]['columns'][]=array('columnname'=>'ld_potential:sales_stage:sales_stage:Potentials_fieldlabel:V',
                                                        'comparator'=>'e','value'=>$keywords,'column_condition'=>'');
               $advft_criteria[0]['condition']='';
          }
         else
         {
            $advft_criteria=array();
         }
      
		return $advft_criteria;
	}
}




?>