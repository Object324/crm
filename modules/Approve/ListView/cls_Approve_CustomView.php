<?php
/***
首页组件视图-》销售漏斗点击弹出层查询
***/
class cls_Approve_CustomView extends CustomView
{
     public  function __construct($module='')
     {
        parent::__construct($module);
     }
	  /**
      * 重写数据分类
      * */
	 function getCustomViewCombo2($approvestatus='' ,$thismodulename='', $markselected = true, $popup=''){
		$viewtype1 = 'divView';$viewtype = 'divView';
		if($approvestatus == 1){
			$viewtype1 = 'currdataClass';
		}else{
			$viewtype = 'currdataClass';
		}
		$option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=".$viewtype."  onclick=\"approve_showDefaultCustomView(this,'". $thismodulename ."','".$category."',0);\">
					<a href='javascript:void(0);'>" . getFixedLabel('Pending') . "</a>
					</li>";
		$option .= "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=".$viewtype1."  onclick=\"approve_showDefaultCustomView(this,'". $thismodulename ."','".$category."',1);\">
					<a href='javascript:void(0);'>" . getFixedLabel('Processed') . "</a>
					</li>";
		return $option;	
	 }
     /**
      * 重写父类方法(分类排序)
      * */
    public function getCustomViewOrderBy($viewid)
    {
		global $approvestatus;
        $tablename=$this->focus->table_name;
      // ld_outboundorder.approvesubmittedtime
		if(empty($approvestatus)){
		//	$customorder = ' tmp_approve.approveby_datetime asc ';
            $customorder=" (case when $tablename.approveexpediting='yes' then 0 when $tablename.approveurgent='yes' then 1 else 2 end)".","."$tablename.approvesubmittedtime asc ";//ls 2021-08-11  【ID1001881】航港：加急（优先）审批(组装审批中心的排序)
		}else{
		//	$customorder = ' tmp_approve.approveby_datetime desc ';
        $customorder=" (case when $tablename.approveexpediting='yes' then 0 when $tablename.approveurgent='yes' then 1 else 2 end)".","."$tablename.approvesubmittedtime desc ";
		}
        return $customorder;
    }
    /**
     * 重写父类获取列头
     * */
    public function getColumnsListByCvid($viewid)
    {
		global $approvestatus;
		$columnviewlist=parent::getColumnsListByCvid($viewid);

//        @edit:liushuai @date:2020-07-13 @reason: 审批中心查询优化：发起人（提交人）、发起时间（提交时间）、审批步骤（当前审批步骤）， 放在单据表里面（审批中心列头）
        $module_name = $this->customviewmodule;
        $focus=CRMEntity::getInstance($module_name);
        $table_name = $focus->table_name;
		$approvecolumnlist = array();
        if(empty($approvestatus)){//待处理

            $approvecolumnlist = array(
                'approvesubmitter' => $table_name.':approvesubmitter:approvesubmitter:'.$this->customviewmodule.'_fieldlabel:V',
            );
        }else if($approvestatus == 1){//已处理

            $approvecolumnlist = array(
                'approvesubmitter' => $table_name.':approvesubmitter:approvesubmitter:'.$this->customviewmodule.'_fieldlabel:V',
            );
        }else if($approvestatus == 3){//我提交的
            
            $approvecolumnlist = array(
                'approveby_result' => 'tmp_approve:approveby_result:approveby_result:'.$this->customviewmodule.'_fieldlabel:V',
            );
		}else if($approvestatus == 4){//被驳回的
			$approvecolumnlist = array(
                'approvesubmitter' => $table_name.':approvesubmitter:approvesubmitter:'.$this->customviewmodule.'_fieldlabel:V',
            );
        }
		$common_approvecolumnlist = array(
			'approvesubmittedtime' => $table_name.':approvesubmittedtime:approvesubmittedtime:'.$this->customviewmodule.'_fieldlabel:DT',
			'currentapprovestepid' => $table_name.':currentapprovestepid:currentapprovestepid:'.$this->customviewmodule.'_fieldlabel:N',
		);
		$approvecolumnlist = array_merge($approvecolumnlist,$common_approvecolumnlist);

		foreach($approvecolumnlist as $columnname => $column){
			if($this->existscolumn($columnname,$columnviewlist)=='no'){
				$column_list[]=$column;
			}
		}
		$i = 0;
		$keys=array_keys($column_list);
		foreach($columnviewlist as $column){
			$column_list[sizeOf($keys) + $i] = $column;
			$i++;
		}
  
        return $column_list;
    }
	/**
	* 重写父类基本查询方法
	* */
	function getStdFilterByCvid() {
		return array();

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

	/**
	* 获取高级查询条件
	* */
	function getAdvFilterByautoid() {
		return array();
	}

   function getViewId($module='',$popup='')
   {
      global $adb;
	  //日程管理
	  if($module == 'Calendar'){
		  $module = 'Events';
	  }
      $sql='select  cvid ,pagewidthpercent from ld_customview where  entitytype=? and viewname=?';
      $result=$adb->pquery($sql,array($module,'All'));
      $viewid=$adb->query_result($result,0,0);
      $this->pageWidthPercent=$adb->query_result($result,0,1);
      return $viewid;
   }

	private function existscolumn($columnname,$columnlist)
    {
        foreach($columnlist as $columninfo)
        {
            $columns=explode(":",(string)$columninfo);
            if($columnname==$columns[1])
            {
                return 'yes';
            }
        }
        return 'no';
        
    }

	public function getListWidth($cvid)
    {
        global $adb,$current_user,$approvestatus;
		if(empty($approvestatus)){
			$cvid = 0;
		}else{
			$cvid = $approvestatus;		
		}
        $sql='select * from ld_list_headerwidth  where module=? and type=? and userid=? and relateid=?';
        $result=$adb->pquery($sql,array($this->customviewmodule,'Approve',$current_user->id,$cvid));
        $num_rows=$adb->num_rows($result);
        
        $column_width=array();
        for($i=0;$i<$num_rows;$i++)
        {
            $columninfo=$adb->query_result($result,$i,'columns');
            $header_width=$adb->query_result($result,$i,'header_width');
            
            $column_width[$columninfo]=$header_width;
        }
        return $column_width;
    }
}




?>