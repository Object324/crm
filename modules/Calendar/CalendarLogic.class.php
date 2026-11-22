<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class CalendarLogic extends BaseLogic {
    /**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		parent::getListMoreBtn();
		//日程管理模块没有批量编辑功能
		//unset($this->list_buttons['More']['list']['mass_edit']);
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['close']['label'] = getFixedLabel('CLOSE');;//确认
        $btn = f_array_insert($btn,parent::getallListViewLink(),-1);
        return $btn;
    }
    public function setListViewLink($result,$record,$start,$idx) {
                    global $adb,$related_header,$current_user;
                    $query = 'select eventstatus from ld_activity where activityid = ? limit 1';
					$res = $adb->pquery($query,array($record));
					$status = $adb->query_result($res,0,0);
                    
                 if(!$related_header)//相关信息不需要显示关闭按钮
                    //duan 20230215 BUG0061569:用户在日程管理模块的‘状态’字段为只读权限，但是列表还有关闭的按钮
                    $fieldpermisson = 'yes';
                    $focus = CRMEntity::getInstance(self::$module);
                    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname','eventstatus');
                    if(!empty($fieldinfo)){
                        $fieldid = $fieldinfo->getFieldid();
                        $profileobj = Profile::getInstance();
                        $profilefields = $profileobj->getProfileInfos($current_user->profileid);
                        $profilefields = $profilefields['field'];
                        if($profilefields[$fieldid]['readonly'] == 1 || $profilefields[$fieldid]['editreadonly']){
                            $fieldpermisson = 'no';
                        }
                    }else{
                        $fieldpermisson = 'no';
                    }
                    
                   if ($status!='已执行'&&isPermitted("Calendar", 'EditView', $record) == 'yes' && $fieldpermisson == 'yes')
                   {
                     $this->listview_link['close']['label'] = getFixedLabel('CLOSE');
                    $this->listview_link['close']['permit'] = 'yes';
                    $this->listview_link['close']['click'] = 'calendar_close('.$record.','. $_REQUEST['calendar_viewid'].')';
                    $this->listview_link['close']['type'] = $type;
                   }else{
						$this->listview_link['close']['label'] = getFixedLabel('CLOSE');
                    $this->listview_link['close']['permit'] = 'no';
                    $this->listview_link['close']['click'] = 'calendar_close('.$record.','. $_REQUEST['calendar_viewid'].')';
                    $this->listview_link['close']['type'] = $type;
				   }
               
                
                parent::setListViewLink($result,$record,$start,$idx);
                
        }
  
}
?>