<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class ProjectTaskLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		$module = self::$module;
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
		$btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','projecttaskstatus');
        //duan 20240223 BUG0077576:如果派工单启用了推进，且追踪字段是状态字段，则不显示更改状态按钮
        $advancefield = 'no';
        crm_load_class_file('cls_module_advance','modules/Settings');
        $cls_module_advance = cls_module_advance::getInstance($module);
        $moduleadvance = $cls_module_advance->moduleadvance;
        if($moduleadvance['enable'] == 'yes' && $moduleadvance['method'] == 'field' && $moduleadvance['module_field'] == 'projecttaskstatus'){
            $advancefield = 'yes';
        }

        //zkt 20220331 0050667: （https://81mis.com/kfbcrm [^]）角色权限->派工单，取消“更改状态”操作权限后，界面没有生效，更多中仍显示更改状态操作按钮
        if($advancefield == 'no' && $field && isPermitted($module, 'Updatestate','') == 'yes')//更改状态
        {    
    		$btn['Updatestate']['label'] = getFixedLabel('UPDATEPROJECTASKSTATUS');
    		$btn['Updatestate']['permit'] = 'yes'; 
    		$this->list_buttons['More']['permit']='yes';
    		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,3);
        }
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-04
	 */
	public function getDetailMoreBtn() {
	    parent::getDetailBasicBtn();
        parent::getDetailMoreBtn();
                        
		$approve_focus = $this->controller->getInstance('Approve');
		$startapprovemodule = $approve_focus->startBlocksApprove();
        $btn = array();
        $fieldobj=$this->controller->fieldobj;
        $field=$fieldobj->getFieldInfoobjBykey('columnname','projecttaskstatus');
        if($field)
        {
            $btn['Updatestate']['label'] = getFixedLabel('UPDATEPROJECTASKSTATUS');
    		$btn['Updatestate']['permit'] = isPermitted("ProjectTask",'Updatestate','');
    		$btn['Updatestate']['icon'] = 'icon-check';
        }		
        $btn2['Close'] = $this->detail_buttons['Close'];
	    unset($this->detail_buttons['Close']);
        
        $keys=array_keys($this->detail_buttons['More']['list']);
        $index=sizeof($keys);
        if(in_array('ChangeCreator',$keys))
        {
            
           $index=array_search('ChangeCreator',$keys);
        }

        $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn,$index);        
        $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'],$btn2,$index);	                
	}
    public function getallListViewLink() {
        $btn =array();
        if(vtlib_isModuleActive('ProjectProgress')){
            $btn['progress']['label'] = getFixedLabel('PROGRESS');//跟进
        }
        $focus = CRMEntity::getInstance('ProjectTask');
        $projecttaskstatusfieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname', 'projecttaskstatus');
        if($projecttaskstatusfieldinfo&&$projecttaskstatusfieldinfo->getFieldName()!='' &&isPermitted('ProjectTask', 'Updatestate','') == 'yes')
        {
            $btn['close']['label'] = getFixedLabel('CLOSE');//关闭
        }
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
   	/**
	 * @author cyb
     * @date 2016-03-10
     * @reason 初始化列表按钮结果集
	 */
    public function setListViewLink($result,$record,$start,$idx) {
		parent::setListViewLink($result,$record,$start,$idx);
		global $current_user;
		$btn = array();
		unset($this->listview_link['progress']);	
		$btn['progress']['label'] = getFixedLabel('PROGRESS');//跟进
		$btn['progress']['permit'] = isPermitted('ProjectProgress','Create');//是否有项目进度的创建权限
		global $related_left_record;
		if(empty($related_left_record)) $related_left_record = 0;
		$btn['progress']['click'] = 'CreateProjectProgressByProjectTask(this,\''.$related_left_record.'\',\'%d\',\'ProjectTask\',\'index\')';
		$this->listview_link = f_array_insert($this->listview_link,$btn,1);
        if(!vtlib_isModuleActive('ProjectProgress')){
            unset($this->listview_link['progress']);
        }          
        $btn=array(); 
        $permit = 'yes';
        $focus = CRMEntity::getInstance('ProjectTask');
        $projecttaskstatusfieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname', 'projecttaskstatus');
        if($projecttaskstatusfieldinfo&&$projecttaskstatusfieldinfo->getFieldName()!='' &&isPermitted('ProjectTask', 'Updatestate','') == 'yes')
        {
             $focus->retrieve_entity_info($record,'ProjectTask');
            if($focus->column_fields['projecttaskstatus']=='已完成'){
            	$permit = 'no';
            }        
            $btn['close']['label'] = getFixedLabel('CLOSE');//关闭
            $btn['close']['permit'] = $permit;
            $btn['close']['click'] = 'closeclick_update(this,\''.self::$module.'\',\'%d\',\'ListView\')'; $focus->retrieve_entity_info($record,'ProjectTask');
        }
        $this->listview_link = f_array_insert($this->listview_link,$btn,-1);        
	}
	public function getActionUserd() {
		parent::getActionUserd();
		$module_tabid = getTabid('ContactRecords');
		$focus = CRMEntity::getInstance('ProjectTask');
        $focus->retrieve_entity_info($this->controller->id,'ProjectTask');
		$projectid = $focus->column_fields['projectid'];
		foreach($this->quickactionLink as $tabid => $quickInfo){
			if($module_tabid == $tabid || $tabid==getTabid('ProjectProgress')){
				$tag = $quickInfo['tag'];
				$this->quickactionLink[$tabid]['tag'] = $tag . '&projectid='.$projectid;
			}
		}
        
       	$tabid2 = getTabid('ServiceReturn');
         
		if(isset($this->quickactionLink[$tabid2])){
            $tag = $this->quickactionLink[$tabid2]['tag'];
            

            $this->quickactionLink[$tabid2]['tag'] = $tag;
            $this->quickactionLink[$tabid2]['click'] = 'check()'; 
		}	
		return $this->quickactionLink;
	}
    
   
}
?>