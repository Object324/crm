<?php

class cls_module_advance
{
    public $tabid;
    public $module;
    public $focus;
    public $modulefields;
    public $objpinklist;
    public $moduleadvance = [];
    public $advance_type;
    public $stagement_timearr = [];
    public $record;
    public $showtype;
    public $withattachment;
    public $circulate_count;
    public $advancetaskfield_arr = [];
    public $advancefieldname_arr = [];
    public $error;
    public $fieldtask_num;
    public $usefieldrule;
    public $triggerfieldname_arr = [];
    public $triggerfieldvalue_arr = [];
    public $savelogs;
    public $allTasklog;
    public $CommonEditFieldobj;
    public $workflow_apiinfo;
    public $stagename_now_arr;//当前阶段名称
    public $processobj;
    public $requestcolumn;
    public $allRelatedRecordArr;
    public $AdvanceRelation_arr;
    public $picklistvalue;
    public $task_check;
    public $autopush;
    public $AdvanceRelationByuser_arr = [];
    public $advance_trigger_column;
    public $checkdata;
    public $picklist_changelog = [];
    public $advance_track_data = [];
    public static function getInstance($module)
    {
        //static $m
        static $static_module_advanceobj_arr;
        //edit:can 20220701 客户问题（贵州君诺），合同编辑界面打不开，显示空白，时间长了提示“操作系统和环境故障” 
       if(is_array($static_module_advanceobj_arr)&&array_key_exists($module,$static_module_advanceobj_arr))
        {
            
            return $static_module_advanceobj_arr[$module];
            
        }
        if(!is_array($static_module_advanceobj_arr))
        {
            $static_module_advanceobj_arr=[];
        }
        $static_module_advanceobj_arr[$module]=new cls_module_advance($module);
        return $static_module_advanceobj_arr[$module];
    }
    public $errorDescription;//推进保存错误信息
    public $advancefield_arr;
	public function __construct($module)
	{
        if($module == 'Events'){
            $module = 'Calendar';
        }
		$this->tabid = getTabid($module);
		$this->module = $module;
		$this->focus=CRMEntity::getInstance($module);

		$this->modulefields=$this->focus->fieldobj->getModuleFields();
		crm_load_class_file("cls_PickList", 'modules/PickList');
		$this->objpinklist = new cls_PickList();
		$this->moduleadvance = $this->getModuleAdvance();
		$this->advance_type = isset($_REQUEST['sourcefrom'])?strtolower($_REQUEST['sourcefrom']):'';
        $this->stagement_timearr = array();//所有的阶段推进时间
        $this->allTasklog = array();//所有阶段的任务日志
        $this->record = 0;
        $this->showtype = '';
        $this->withattachment = 'no';
        $this->circulate_count= 0; //统计阶段自动推进次数，避免陷入死循环
        $this->advancetaskfield_arr = array();
        $this->advancefieldname_arr = [];
        $this->error = 'no';
        $this->fieldtask_num= 0;
        $this->usefieldrule = 'yes';//判断是否需要调用布局规则
        $this->triggerfieldname_arr = [];//判断布局规则字段
        $this->triggerfieldvalue_arr = [];//布局规则字段值
        $this->savelogs = 'yes';

        crm_load_class_file('cls_advance_process','modules/lingdang');
        $this->processobj = cls_advance_process::getInstance($this->module);

        //调用通用字段编辑类，借用过来调用一下布局规则的方法
        crm_load_class_file('cls_Common_EditField','modules/lingdang');
        $this->CommonEditFieldobj = cls_Common_EditField::getInstance($module);
        //引用验证规则文件
        crm_load_class_file('cls_PageValidataSave','data');
        crm_load_function_file('getRelatedListInfoByTabid', 'include/utils', 'DetailViewUtils');
	}

	public function get($record){
		$this->advance_type = 'pc';
        $this->record = $record;
		$is_enable = $this->is_Enable();
		$data['is_enable'] = 'yes';
		$data['data_error'] = 'no';
        //隐藏推进按钮参数（ //zl XUQIU1001207 ）
        $data['hidebtn'] = 'no';
        if(!$this->moduleadvance) $this->moduleadvance = [];
        $this->moduleadvance['is_enable'] = $is_enable;
		if($is_enable == 'no'){
			$data['is_enable'] = 'no';
			return $data;
		}

        //duan 2021-10-21 不启用进度追踪时，在详情页增加推进按钮，有推进权限的用户显示
		$advancestage = $this->getAdvanceStage($record);
		if($advancestage == false){	//数据错误，进度无法显示
			$data['data_error'] = 'yes';
            $data['fieldlabel_isempty'] = $this->Fieldlabelempty();

		}
		//chj 2021/1/14 进度跟踪设置，进度跟踪图根据跟踪字段设置的级联字段显示
		/*
        $columnForDependencyPicklist = $this->getColumnForDependencyPicklist($record);
		if(!empty($columnForDependencyPicklist)){
			$advancestage_new = [];
			foreach($advancestage as $advcnce_col){
				if(in_array($advcnce_col['value'],$columnForDependencyPicklist)){
					$advancestage_new[] = $advcnce_col;
				}
			}
			$data['advancestage_values'] = $advancestage_new;
		}else{
			$data['advancestage_values'] = $advancestage;
		}*/
        $data['advancestage_values'] = $advancestage;
        $tmp_advancestage = $data['advancestage_values'];
        $with_time = 'no';
        foreach($tmp_advancestage as $key=> $advcnce_col ){
            if($advcnce_col['skip'] == 'yes'){
                continue;
            }
            //判断阶段中是否存在推进时间和推进人，用于控制高度
            if( !empty($advcnce_col['staytimecontent']) && !empty($advcnce_col['changedon'])){
                $with_time = 'yes';
            }
            if($this->moduleadvance['method'] == 'field' && $this->moduleadvance['logshowstyle'] == 'underadvance'){

                $DetailTaskinfo = $this->getAdvanceDetailTaksinfo($record,$advcnce_col['value']);
                $tmp_advancestage[$key]['DetailTaskInfo'] = $DetailTaskinfo;
            }
        }
        //wym 240321 XUQIU1001207 线索升级后详情页隐藏推进按钮
        $stagename_now = $this->getStagenameNow($record);
        global $global_picklist_mapmodule;//销售线索状态下拉框对应映射模块
        $mapmodule_str=$global_picklist_mapmodule[$this->moduleadvance['module_field']][$stagename_now];
        $data['mapmodule'] = $mapmodule_str;
        if($mapmodule_str && $mapmodule_str!='close'){
            $data['hidebtn'] = 'yes';
        }

        $data['advancestage_values'] = $tmp_advancestage;
        $data['with_time'] = $with_time;
		$data['record'] = $record;
		$data['module'] = $this->module;
         //duan 推进功能优化，进度追踪和推进按钮的权限分开
        $data['is_permit'] = isPermitted($this->module,'Advance');
        $data['moduleadvance'] = $this->moduleadvance;
        //wym 240517 BUG20240516-56 进度追踪出增加相应抓取的进度，例如销售阶段-进度追踪
        $data['module_field_label'] = '';
        $fieldname = $this->moduleadvance['module_field'];
        $field = $this->modulefields[$fieldname];
        if(!empty($field)){
            $data['module_field_label'] = $field->getFieldlabel();
        }
		return $data;
	}

	public function getWx($record){
		$this->advance_type = 'pc';
		$is_enable = $this->is_MobileEnable();
		$data['is_enable'] = 'yes';
		$data['data_error'] = 'no';
		if($is_enable == 'no')
			$data['is_enable'] = 'no';
//		}else{
		$advancestage = $this->getAdvanceStage($record);
		if($advancestage == false){	//数据错误，进度无法显示
			$data['data_error'] = 'yes';
		}else{
            //chj 2021/1/14 进度跟踪设置，进度跟踪图根据跟踪字段设置的级联字段显示
    		$columnForDependencyPicklist = $this->getColumnForDependencyPicklist($record);
    		if(!empty($columnForDependencyPicklist)){
    			$advancestage_new = [];
    			foreach($advancestage as $advcnce_col){
    				if(in_array($advcnce_col['value'],$columnForDependencyPicklist)){
    					$advancestage_new[] = $advcnce_col;
    				}
    			}
    			$data['advancestage_values'] = $advancestage_new;
    		}else{
    			$data['advancestage_values'] = $advancestage;
    		}
		}

		$data['record'] = $record;
		$data['module'] = $this->module;
		return $data;
	}

	public function getWeiXin($record){
		global $current_user,$adb;
		$this->advance_type = 'weixin';
		$is_enable = $this->is_MobileEnable();
        //$task_used = $this->AdvanceTaskCheck($record);//自动化任务是否使用
		$data['is_enable'] = 'yes';
		$data['data_error'] = 'no';
        $data['blocklabel'] = getFixedLabel('PROGRESSTRACKING');
        $data['Task_used'] = 'yes';
        $this->record = $record;
        $advance_third = 'no';

		if($is_enable == 'no'){
			$data['is_enable'] = 'no';
		}
		$advancestage = $this->getAdvanceStage($record);//获取下拉框的推进信息
		if($advancestage == false){	//数据错误，进度无法显示
			$data['data_error'] = 'yes';
            $data['fieldlabel_isempty'] = $this->Fieldlabelempty(); 
        }
        //添加自动化任务信息
        if($data['data_error'] != 'yes'){
            $stagename_now = $this->getStagenameNow($record);
            //dump($alltaskinfo_arr);
            foreach($advancestage as $tmp_key =>$tmp_value){
                $tmp_stagename = $tmp_value['value'];
                $effective = 'no';
                //控制侧边进度条类型的参数
                if($tmp_value['cur_flag']=='yes'){
                    $cur_key = $tmp_key+1;
                    if($tmp_value['completed']=='yes'){
                        $advancestage[$tmp_key]['last_completestage'] = 'yes';
                    }else{
                        if(isset($advancestage[$tmp_key-1])){
                            $advancestage[$tmp_key-1]['last_completestage'] = 'yes';
                        }
                    }
                }
                //当前阶段之后不返回任务信息
                if($stagename_now==$tmp_stagename) break;
            }
           
        }
        
        $AdvanceRelations = $this->getAdvanceRelationsByuser($record);
		$data['list'] = $advancestage;
		if(!empty($advancestage)){
			//允许回推
            if($this->moduleadvance['method'] == 'field'){
                foreach($advancestage as $key => $stage){
    			    foreach($AdvanceRelations as $tmp_advanceid=>$tmp_relation ){
        		         if($tmp_relation['stagename_target'] == $stage['value']){
                             $data['option'][] = $tmp_relation['stagename_target'];
        		         }
                     }
    		     }
            }
            $all_taskinfo_arr = $this->getadvancetask();
            //判断可推进的任务里是否存在任务
            foreach($AdvanceRelations as $tmp_advanceid=>$tmp_relation ){
                $taskinfo_arr = $all_taskinfo_arr[$tmp_advanceid];
                if(is_array($taskinfo_arr) && sizeof($taskinfo_arr)>0){
                    $advance_third = 'yes';
                }
            }

            //销售线索每个下拉框值增加特征值
            if($this->module == 'Leads'&&$this->moduleadvance['module_field']=='status'){
                global $global_picklist_mapmodule;//映射模块，销售线索状态字段用到
                $options = array();
                foreach($data['option'] as $key=>$value){
                    $mapmodule=$global_picklist_mapmodule[$this->moduleadvance['module_field']][$value];
                    $mapmodule_arr=explode(':',(string)$mapmodule);
                    $options[$key]['text'] = $value;
                    $options[$key]['type'] = '';
                    if($mapmodule == 'close'){
                        $options[$key]['type'] = 'closed';
                    }else if($mapmodule){
                        $options[$key]['type'] = $mapmodule;
                        $mapmodule_single=explode(':',$mapmodule);
                        if(count($mapmodule_single)==1){
                            $options[$key]['modulename'] = getTranstab($mapmodule);
                        }
                    }
                }
                $data['options'] = $options;
				// zl XUQIU1001207 移动端隐藏推进按钮			
                if( ($stagename_now=='升级到客户' || $stagename_now=='升级到客户和销售机会')&&$cur_key>0){
                    $data['list'][$cur_key-1]['push_button'] = 'no';
                }
            }
            if(((empty($data['option']) || sizeof($data['option']) == 0)&&$cur_key>0) ){
                $data['list'][$cur_key-1]['push_button'] = 'no';
            }
		}

        if($this->error == 'yes'){
            $advance_third = 'no';
        }
        $data['advance_third'] = $advance_third;

		return $data;
	}
	
	//单据保存。 自动生成销售阶段值
	public function createModuleAdvanceStage($record){
		global $adb;
		if($this->moduleadvance['method'] == 'field'){
			$fieldname = $this->moduleadvance['module_field'];
			$field = $this->modulefields[$fieldname];
			if(!empty($field)){
				$tablename = $this->focus->table_name;
				$table_index = $this->focus->table_index;
				$customFieldTable = $this->focus->customFieldTable;
				$field_cur_value = $this->focus->column_fields[$fieldname];
				$columnname = $field->getColumnName();
				//chj 2021/6/7 46238: https://61mis.com/WX/kh40630/ [^]，销售管理-项目推进（执行）表下的进度漏斗数据对不上，以项目推进（执行）情况下是失败关闭的为例
				$query = "update $tablename left join $customFieldTable[0] on $customFieldTable[0].$customFieldTable[1] = $tablename.$table_index set advance_stage = $columnname where $tablename.$table_index = ? and deleted = 0";
				$adb->pquery($query,array($record));
			}
		}
	}
	//获取单据的推进阶段所有信息
	private function getAdvanceStage($record){
		global $current_user;
		$this->focus->retrieve_entity_info($record,$this->module);
		$pushback = 'yes';
		if($this->moduleadvance['pushback'] == 'no' && $current_user->is_admin != 'on'){
			$pushback = 'no';
		}
		if($this->moduleadvance['method'] == 'field'){
			$fieldname = $this->moduleadvance['module_field'];
			$field_cur_value = $this->focus->column_fields[$fieldname];
			if(empty($field_cur_value)){
				//return false;
			}
		}else{
			$start_field_cur_value = $this->focus->column_fields[$this->moduleadvance['module_period_start_field']];
			$end_field_cur_value = $this->focus->column_fields[$this->moduleadvance['module_period_end_field']];
			if(empty($start_field_cur_value) || $start_field_cur_value < '1970-01-01' || empty($end_field_cur_value) || $end_field_cur_value < '1970-01-01' || $start_field_cur_value > $end_field_cur_value){
				return false;	//数据错误，进度无法显示
			}
			$fieldname = 'advance_stage';
			$field_cur_value = $this->focus->column_fields[$fieldname];
			//按指定日期推进，模块的推进阶段字段赋默认值
			if(empty($field_cur_value)){
				$start_field_cur_value = date("Y-m", strtotime($start_field_cur_value));
				$this->updateModuleAdvanceStage($record,$start_field_cur_value);
			}
		}


        //获取该字段的修改日志
        $this->checkdata = 'yes';
		$modtracker_value = $this->getModtrackerData($record,$fieldname);
          
        //判断当前阶段是否为结束阶段
        if($this->moduleadvance['method'] == 'field'){
            //获取推进阶段的所有值
            $picklistvalue = $this->getProcessStageValue($record);
            $stagename_now = $this->getStagenameNow($record);
            $all_advancerelation = $this->getAdvanceRelations($fieldname);
            $tmp_advancerelation = $all_advancerelation[$stagename_now];
            $relation_count = 0;
            foreach($tmp_advancerelation as $tmp_relation){
                if($tmp_relation['presence'] == 'yes'){
                    $relation_count = $relation_count +1;
                }
            }
            if($relation_count == 0){
                $end_stage = 'yes';
            }
        }else{
            $picklistvalue = $this->getAdvanceStageValues();
            $end_stage = 'no';
        }
		if(!empty($picklistvalue)){
			$offset=array_search($field_cur_value,$picklistvalue);
			foreach($picklistvalue as $key => $val){
				$cur_flag = 'no';	//当前值
				$completed = 'no';	//是否已完成
				$finish = 'no';	//是否已全部推进完毕
				if($key == $offset){
					$cur_flag = 'yes';
				}else{
					if($key < $offset){
						$completed = 'yes';
					}
				}
				//Completed
				if($cur_flag == 'yes' && $key == count($picklistvalue) - 1 && $offset > 0){
					$finish = 'yes';
				}
                if($cur_flag == 'yes' && $end_stage == 'yes'){
                    $finish = 'yes';
                    $completed = 'yes';
                }
                
				$data[$key] = array(
					'cur_flag' => $cur_flag,
					'value' => $val,
					'completed' => $completed,
					'finish' => $finish,
					'pushback' => $pushback
				);
                if($completed == 'yes' || $finish == 'yes')
                {   
    				$data[$key]['skip'] = $modtracker_value[$val]['skip'];
                     $data[$key]['staytimecontent'] = $modtracker_value[$val]['showstaytimecontent'];
                    if(isset($modtracker_value[$val]) && ($this->moduleadvance['showadvancelog'] == 'getin' ||$this->moduleadvance['showadvancelog'] == 'getout')){
    					if($finish == 'yes'){
    						if($pushback == 'no' && $this->moduleadvance['method'] == 'period'){
    							$data[$key]['cur_flag'] = 'no';	//41430: （61mis.com/kfbcrm）销售机会模块>选择单据编号为“POT84”进入明细界面：当进度推进完成后，应该还允许往回推进。
    						}
    						$data[$key]['finish'] = 'no';
    						$data[$key]['completed'] = 'yes';
    					}
                        if($this->moduleadvance['showadvancelog'] == 'getin'){
                            $data[$key]['changedon'] = $modtracker_value[$val]['changedon_getin'];
    					    $data[$key]['userfullname'] = $modtracker_value[$val]['userfullname_getin'];
                        }else{
                            $data[$key]['changedon'] = $modtracker_value[$val]['changedon'];
    					    $data[$key]['userfullname'] = $modtracker_value[$val]['userfullname'];
                        }
                       
    					
    				}else//如果没有推进日志
                    {
                      //销售商机：商机阶段推进，要显示所有动作的推进人和推进时间
                      $version_info = getVersionInfo();//判断中孚公司版本号
                      if($version_info['trade']=="zhongfu"){
                        if(empty($previous_data['changedon']))//如果上一阶段的时间不存在
                        {
                            $creator = $this->getcreator($record);//获取商机创建时间
                            if(isset($creator['changedon']))
                            {
                                $data[$key]['changedon'] = $creator['changedon'];
                                $data[$key]['userfullname'] = $creator['userfullname'];
                            }
                        }
                        else{
                            if(isset($previous_data['changedon']))//如果上一阶段的时间存在
                            {
                                $data[$key]['changedon'] = $previous_data['changedon'];//则与上一阶段时间相同
                                $data[$key]['userfullname'] = $previous_data['userfullname'];
                            }
                        }
                        
                      }
                    }
                    $version_info = getVersionInfo();
                    if($version_info['trade']=="zhongfu")//判断中孚版本号
                    {
                        //要求每一个的阶段时间不能小于上一个阶段，若小于则与上阶段相同，避免反复推进、回撤阶段出现时间线混乱
                        if(isset($previous_data)&& $this->comparetime($previous_data['changedon'],$data[$key]['changedon']))
                        {
                            $data[$key]['changedon'] = $previous_data['changedon'];
                            $data[$key]['userfullname'] = $previous_data['userfullname'];
                        }
                        else
                        {
                            $previous_data=array(
                                'changedon'=> $data[$key]['changedon'],
                                'userfullname'=> $data[$key]['userfullname']);
                        }
                    }
                }
                if($cur_flag == 'yes' && $this->moduleadvance['showadvancelog'] == 'getin'){
                    $data[$key]['changedon'] = $modtracker_value[$val]['changedon_getin'];
    				$data[$key]['userfullname'] = $modtracker_value[$val]['userfullname_getin'];
                    $data[$key]['staytimecontent'] = $modtracker_value[$val]['showstaytimecontent'];
                }
                
                //判断当前阶段是结束阶段,结束阶段之后的阶段不再显示
                if($cur_flag == 'yes' && $end_stage == 'yes'){
                    break;
                }
			}
            //duan 20221219 异常处理，如果推进字段值为空，或者不属于当前下拉框内容，则允许推进到第一个选项
            if(empty($field_cur_value)||!in_array($field_cur_value,$picklistvalue)){
                //BUG0076315 hzx 当自动化进度设置的追踪值为空的时候，界面显示异常
                if($this->moduleadvance['method'] == 'field'){
                    return '';
                }
                $data[$key]['completed'] = 'no';
                $data[$key]['finish'] = 'no';
                $data[$key]['skip'] = 'no';
                $data[$key]['cur_flag'] = 'yes';
                $this->error = 'yes';
                $data[$key]['changedon'] = '';
                $data[$key]['userfullname'] = '';
                $data[$key]['staytimecontent'] = '';
			}
		}
		return $data;
	}
	 public function isRequiredFieldRule($columnname)
    {
         crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
         $fieldruleobj=cls_fieldrule::getInstance($this->module);
        $allfieldrule= $fieldruleobj->getAllRules();//布局规则必填项

        //推进要判断所有的布局规则
        $triggeroperatecolumns=$fieldruleobj->getAllTriggerOperate();
        foreach ($triggeroperatecolumns as $tmp_columnname  => $tmp_info){
            foreach($tmp_info as $basicsearchid=>$triggerinfo)
            {
                if($triggerinfo['type']=='required')
                {
                    return 'yes';
                }
            }
        }
        return 'no';

        /*
        if(array_key_exists($columnname,$allfieldrule))
        {
            $triggeroperatecolumns=$fieldruleobj->getAllTriggerOperate();
            //获取触发字段（销售阶段是否设置必填字段）
            foreach($triggeroperatecolumns[$columnname] as $basicsearchid=>$triggerinfo)
            {
                 if($triggerinfo['type']=='required')
                 {
                    return 'yes';
                 }
            }
            //exit();
            //return 'yes';
            return 'no';
        }
        else
        {
            return 'no';
        }
        */
    
    }
	//更新单据相应字段的值
	public function updateModuleAdvanceStage($record,$new_value){
		global $adb,$current_user;
		$tablename = $this->focus->table_name;
		$table_index = $this->focus->table_index;
		$customFieldTable = $this->focus->customFieldTable;
		$this->focus->retrieve_entity_info($record,$this->module);
        $this->focus->id = $record;
		//工作流程获取改变前字段值
        $beforefieldvalue_arr = $this->focus->column_fields;

        $fields=$this->modulefields;
		if($this->moduleadvance['method'] == 'field'){
			$fieldname = $this->moduleadvance['module_field'];
			
		}else{
			$fieldname = 'advance_stage';
		}
		$field = $this->modulefields[$fieldname];
		$columnname = $field->getColumnName();
		$column_tablename = $field->getTableName();
       $isexistsfieldrule= $this->isRequiredFieldRule($columnname);//布局规则判断
       $fieldruleobj=cls_fieldrule::getInstance($this->module);

        //原来的布局规则判断弃用了，统一到cls_Common_EditField 类中判断
        $this->focus->column_fields[$fieldname]=$new_value;
        $error = $this->CommonEditFieldobj->JudgeRequiredFieldRule($this->focus);

        if($error=='yes'){
            $this->errorDescription = getFixedLabel('requiredfieldshavebeen');
            return array('fieldname'=>$fieldname);
        }
        $stagenamenow = $this->getStagenameNow($record);
        //获取所有可流转阶段信息
        $premit_node_info = $this->processobj->getPermitNodeinfo($record,$stagenamenow);
        $branchnodeid = 0;
        foreach ($premit_node_info as $tmp_info){
            if($tmp_info['stagename'] == $new_value){
                $branchnodeid = $tmp_info['branchnodeid'];
                break;
            }
        }


        $this->focus->column_fields[$fieldname] = $stagenamenow;
		$field_cur_value = $this->focus->column_fields[$fieldname];
		//销售机会，更新销售阶段字段值，回写上次销售阶段
		if($this->module == 'Potentials' && $fieldname == 'sales_stage'){
			/*
			*edit:chj
			*date:2020-07-10
			*reason:41822: （http://crmm.mfexcel.com:8500/crm/ [^]）销售机会模块>选择单据编号为“POT11509”单据详情界面：“未推进天数”字段没同步更新，跟推进时间不对应
			*/
			crm_load_class_file('cls_SalesStage','modules/Potentials');
			$SalesStage = new cls_SalesStage();
			 $col_fields= $this->focus->column_fields;
			 $col_fields['db_sales_stage']=$col_fields['sales_stage'];
			 $col_fields['sales_stage']=$new_value;
			$SalesStage->UpdatePotentialSalesStage($col_fields,$record,$new_value,0);
			$update = 'update ld_potential set lastsales_stage="'.$field_cur_value.'",modifiedtime="'.date('Y-m-d H:i:s').'",modifiedby = ? where potentialid = ?  ';
			$adb->pquery($update,array($current_user->id,$record));
		}
        
//        //@edit:liushuai,2020-9-30,reason0042831: （https://61mis.com/WX/kh40630/ [^]）项目推进（执行）（筑美未来客户问题）；页面设置中，根据进度推进状态，设置的进度跟踪，单据中也是有推进的；在漏斗中缺未显示数据。其他模块的漏斗也不显示信息。
        //edit:duan 2021-10-29 reason:进度追踪推进后，修改单据的更新人，更新时间  
        $query = "update $tablename left join $customFieldTable[0] on $customFieldTable[0].$customFieldTable[1] = $tablename.$table_index set $column_tablename.$columnname = ?,advance_stage = ?,modifiedtime = ?,modifiedby = ?,latestpushtime = ? where $tablename.$table_index = ? 
		and deleted = 0";
		$adb->pquery($query,array($new_value,$new_value,date('Y-m-d H:i:s'),$current_user->id,date('Y-m-d H:i:s'),$record));
		//$this->focus->getModuleStatic('ModTracker');
		//$this->focus->modstatic->saveFieldLogOne($this->module,$fieldname,$record,$field_cur_value,$new_value);
		//zkt 20220902 BUG0055845项目状态推进后，收款计划日期不反写
        if($this->focus->moduleName == 'Project'&&$columnname == 'projectstatus'){
		  $this->focus->updateProjectStatus($record);
		}
        //duan 20220906 派工单模块状态推进到已完成后反写项目的任务完成数
        if($this->focus->moduleName == 'ProjectTask'&&$columnname == 'projecttaskstatus'){
            if(array_key_exists("projectid",$this->focus->column_fields))
            {
                $projectids=array($this->focus->column_fields["projectid"]);
                $this->focus->updateRelated_Project($projectids);
           }
        }


        $time = date('Y-m-d H:i:s',time());$status = 0;
        $id = $adb->getUniqueID('ld_modtracker_basic');
        $query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
                        values(?,?,?,?,?,?);';
        $adb->pquery($query,array($id,$record,$this->module,$current_user->id,$time,$status));
        $query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue,advancerelatedid) values(?,?,?,?,?);';
        $adb->pquery($query,array($id,$fieldname,$field_cur_value,$new_value,$branchnodeid));

        //保存完自动推进时不需要增加日志
        if($this->autopush == 'yes'){
            staticModTracker::$entitydata[$this->module][$fieldname]= $new_value;

        }


		$result['result']['datainfo'][$fieldname] = $new_value;

		//工作流程反写
        $pagemode = 'Advanced';
        crm_load_class_file("cls_savereverse", 'include/SaveReverse');
        $workflowreverseobj = cls_savereverse::getInstance($this->module);
        $workflowreverseobj->setPageMode($pagemode);
        $workflowreverseobj->getInfo();

        if ($adb->num_rows($workflowreverseobj->workflowresut) > 0) {
            $this->focus->column_fields[$fieldname] = $new_value;
            $afterfieldvalue_arr = $this->focus->column_fields;

            $workflowreverseobj->setRecord($record);
            $workflowreverseobj->setPageMode($pagemode);
            if($workflowreverseobj->checkCallApiPop() == 'yes')
            $workflowreverseobj->setNotCallActionType(array('API','Link2ERP'));//无需处理的API类型
            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);

            $receive_msg = $workflowreverseobj->checkCallApiPop();
            $this->workflow_apiinfo['receive_msg'] = $receive_msg;
            if ($receive_msg == 'yes') {
                $this->workflow_apiinfo['record'] = $record;
                $this->workflow_apiinfo['module'] = $this->module;
                $this->workflow_apiinfo['pagemode'] = $workflowreverseobj->getPageMode();

                $this->workflow_apiinfo['before_save_infos'] = $beforefieldvalue_arr;
                $this->workflow_apiinfo['after_save_infos'] = $afterfieldvalue_arr;
            }
        }
        $this->resetinfo();

        //$this->stagename_now = $new_value;
        $this->stagename_now_arr[$record] = $new_value;
        $this->circulate_count += 1;

        //避免出现死循环
        if($this->circulate_count<50){
            $tmp_result = $this->TaskCompleteCheck($record);
        }

        //edit: xll 2023/08/03 BUG0070577 推进时需要更新当前模块表的advance_stage字段值,否则所有销售漏斗值都将出错
        $this->createModuleAdvanceStage($record);
		return $result;
	}
	public function resetinfo(){
        //阶段推进后需要再次判断是否触发了自动推进
        unset($this->stagement_timearr);
        unset($this->allTasklog);
        unset($this->AdvanceRelationByuser_arr);
        //duan 20240712 自动推进后重设阶段信息缓存
        $this->processobj->resetprocess();
    }

	
	//完成
	public function completeModuleAdvanceStage($record){
		//获取推进阶段的所有值
		$this->focus->retrieve_entity_info($record,$this->module);
		$picklistvalue = $this->getAdvanceStageValues();
		$value = $picklistvalue[count($picklistvalue) - 1];
		$this->updateModuleAdvanceStage($record,$value);
	}

	//获取字段的下拉框值
	public function getAdvanceStageValues(){
        global $global_picklist_mapmodule;//销售线索状态下拉框对应映射模块
        if(isset($this->picklistvalue)){
            return $this->picklistvalue;
        }

		if($this->moduleadvance['method'] == 'field'){
			$fieldname = $this->moduleadvance['module_field'];
			$field = $this->modulefields[$fieldname];
            if(!$field)
                return [];
			$columnname = $field->getColumnName();//oldcustomer_marketin
            $fieldname = $this->moduleadvance['module_field'];
           global $global_pick_list_depencyfield;
           //重设级联字段的值，避免模块直接互相影响
           crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
           $picklistdepency = lingdang_DependencyPicklist::getPicklistDependencyDatasource($this->module);
           $picklistdepencyfields =json_decode(ldcrm_json_encode($global_pick_list_depencyfield),true) ;
         	$field_cur_value = $this->focus->column_fields[$fieldname];
            $picklistvalue=array();
            /*
            if(array_key_exists($fieldname,$picklistdepencyfields))
            {
                $prev_cur_fieldname=$picklistdepencyfields[$fieldname];
                $fieldinfo=$this->focus->fieldobj->getFieldInfoobjBykey("fieldname",$prev_cur_fieldname);
                $prev_cur_value=$this->focus->column_fields[$prev_cur_fieldname];
                
                if($fieldinfo&&array_key_exists($prev_cur_value,$picklistdepency[$prev_cur_fieldname]))
                {
                    
                    $picklistvalue=$picklistdepency[$prev_cur_fieldname][$prev_cur_value][$fieldname];
                    
                }
            }*/
            if(empty($picklistvalue))    
			     $picklistvalue = $this->objpinklist->getPickListValues($fieldname,'ld_field',array(),"");

            //如果客户模块或销售机会模块未开启，则不显对应的推进选项
            foreach($picklistvalue as $key=>$value){
                $mapmodule_str=$global_picklist_mapmodule[$fieldname][$value];
                if(!empty($mapmodule_str) && $mapmodule_str!='close'){
                    $mapmodule_arr=explode(':',(string)$mapmodule_str);
                    foreach($mapmodule_arr as $key=>$mapmodule){
                        if($mapmodule && !vtlib_isModuleActive($mapmodule)){
                            unset($picklistvalue[$key]);
                        }
                    }
                }
            }
			$picklistvalue = $this->array_sort($picklistvalue);
		}else{
			$start_field_cur_value = $this->focus->column_fields[$this->moduleadvance['module_period_start_field']];
			$end_field_cur_value = $this->focus->column_fields[$this->moduleadvance['module_period_end_field']];
			$picklistvalue = $this->dateMonths(date("Y-m", strtotime($start_field_cur_value)),date("Y-m", strtotime($end_field_cur_value)));
		}
        $this->picklistvalue = $picklistvalue;
		return $picklistvalue;
	}

    //zxm 20230523 kfbcrm BUG0066412   服务收费管理---进度漏斗---点击打开速度很慢
    //根据当前字段名 和 上级字段值 获取当前字段下拉框值
    public function getAdvanceStageValuesBysourcevalue($targetfield,$sourcevalue){
        global $adb;
        $picklistvalue=array();
        if($this->moduleadvance['method'] == 'field'){
            $fieldname = $this->moduleadvance['module_field'];
            $field = $this->modulefields[$fieldname];
            if(!$field)
                return [];
            if(!empty($sourcevalue)){
                $depencylist_sql = "select targetvalues from ld_picklist_dependency where tabid=? and targetfield=? and sourcevalue=? ";
                $depencylist_res = $adb->pquery($depencylist_sql,array($this->tabid,$targetfield,$sourcevalue));
                $depencylist_nums = $adb->num_rows($depencylist_res);
                if($depencylist_nums>0){
                    $tmptarget_values = $adb->query_result($depencylist_res,0,'targetvalues');
                    $picklistvalue = Zend_Json::decode(html_entity_decode($tmptarget_values));
                }
            }else{
                $picklistvalue = $this->objpinklist->getPickListValues($fieldname,'ld_field',array(),"");
            }

            if($this->module == 'Leads'&&$fieldname=='status'){
                //如果客户模块或销售机会模块未开启，则不显对应的推进选项
                foreach($picklistvalue as $key=>$value){
                    if($value == '升级到客户'&&!vtlib_isModuleActive('Accounts')){
                        unset($picklistvalue[$key]);
                    }
                    if($value == '升级到客户和销售机会'&&(!vtlib_isModuleActive('Accounts')||!vtlib_isModuleActive('Potentials'))){
                        unset($picklistvalue[$key]);
                    }
                }
            }
            $picklistvalue = $this->array_sort($picklistvalue);
        }else{
            $start_field_cur_value = $this->focus->column_fields[$this->moduleadvance['module_period_start_field']];
            $end_field_cur_value = $this->focus->column_fields[$this->moduleadvance['module_period_end_field']];
            $picklistvalue = $this->dateMonths(date("Y-m", strtotime($start_field_cur_value)),date("Y-m", strtotime($end_field_cur_value)));
        }
        return $picklistvalue;
    }

    //公共方法调用私用方法
    public function getModtrackerData_public($record,$fieldname){
        return $this->getModtrackerData($record,$fieldname);
    }

    public function getAdvanceTrackData($record,$fieldname){
        if(!isset($this->advance_track_data) || sizeof($this->advance_track_data)<=0){
            $this->getModtrackerData($record,$fieldname);
        }
        return $this->advance_track_data;
    }

	//获取字段的修改字段
	private function getModtrackerData($record,$fieldname){
	   
		global $adb,$current_user;
        //获取单据创建时间
        $main_tablename = $this->focus->table_name;
        $module_index=$this->focus->tab_name_index[$main_tablename];
        $sql_record_createtime = "select smcreatorid,createdtime from $main_tablename where $module_index = $record";
        $result = $adb->pquery($sql_record_createtime,array());
        $createdtime = $adb->query_result($result,0,'createdtime');
        $smcreatorid = $adb->query_result($result,0,'smcreatorid');
        $cur_stage = $this->getStagenameNow($record);

		$languageType= getLanguageType($current_user);
		$query = "
			select ld_modtracker_basic.changedon,prevalue,postvalue,whodid,ld_tranlabel.fieldlabel from ld_modtracker_basic 
			LEFT JOIN ld_modtracker_detail on ld_modtracker_detail.id = ld_modtracker_basic.id
			LEFT JOIN ld_tab on ld_tab.`name` = ld_modtracker_basic.module
			INNER JOIN ld_field on ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ld_tab.tabid and ld_field.tabid = ?
			LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_field.fieldid 
			and ld_tranlabel.trantable = 'ld_field' and ld_tranlabel.languagetype = ?
			where ld_modtracker_detail.fieldname = ? and crmid = ? order by ld_modtracker_basic.id asc";
		$tabid = $this->tabid;
		if($tabid==16)$tabid = 9;
		$result = $adb->pquery($query,array($tabid,$languageType,$fieldname,$record));

		$num_rows = $adb->num_rows($result);
		$start_stage = '';
        $all_stay_time_arr = [];
        $all_changelog_arr = [];
        $data = [];
        $advance_track_data = [];
		if($num_rows >= 1){
            if($this->moduleadvance['method'] == 'field'){
                //edit:duan date:2024/12/16 reason:获取下拉框日志，用于历史选项转换
                list($picklist_changelog_arr,$picklistvalue) = $this->get_picklist_changelog($fieldname);
            }
			for($i = 0; $i < $num_rows; $i++){
				$prevalue = html_entity_decode($adb->query_result($result,$i,'prevalue'));
                $postvalue = html_entity_decode($adb->query_result($result,$i,'postvalue'));
				$whodid = $adb->query_result($result,$i,'whodid');
				$changedon = $adb->query_result($result,$i,'changedon');
				$userfullname = getUserFullName($whodid);
                $show_changedon = $changedon;
                //edit:duan date:2024/12/16 reason:根据下拉框修改日志，转换历史选项的数据
                if($this->moduleadvance['method'] == 'field' && is_array($picklistvalue) && is_array($picklist_changelog_arr) && sizeof($picklist_changelog_arr)>0){
                    if(!in_array($prevalue,$picklistvalue)){
                        foreach ($picklist_changelog_arr as $tmp_valueid => $oldvalue_arr){
                            if(in_array($prevalue,$oldvalue_arr)){
                                $prevalue = $picklistvalue[$tmp_valueid];
                                break;
                            }
                        }
                    }
                    if(!in_array($postvalue,$picklistvalue)){
                        foreach ($picklist_changelog_arr as $tmp_valueid => $oldvalue_arr){
                            if(in_array($postvalue,$oldvalue_arr)){
                                $postvalue = $picklistvalue[$tmp_valueid];
                                break;
                            }
                        }
                    }
                }

				if($this->advance_type == 'pc'){
					$show_changedon = str_replace(" ","<br>",$changedon);
				}
				//获取离开阶段的推进人和推进时间
                if(!empty($prevalue)){
                    $data[$prevalue]['userfullname'] = $userfullname;
                    $data[$prevalue]['changedon'] = $show_changedon;
                }
                //获取进入阶段的推进人和推进时间
                if(!empty($postvalue)){
                    $data[$postvalue]['userfullname_getin'] = $userfullname;
                    $data[$postvalue]['changedon_getin'] = $show_changedon;
                }
                if(!empty($prevalue) && !empty($postvalue)){
                    $advance_track_data[] = ['prevalue'=>$prevalue,'postvalue'=>$postvalue,'changedon'=>$changedon];
                }

                //确定初始阶段
                if($i == 0){
                    if(!empty($prevalue)){
                        //初始阶段将创建时间作为进入时间
                        $start_stage = $prevalue;
                        $tmp_changedon_getin = $createdtime;
                        $tmp_changedon = $changedon;
                        $all_stay_time_arr[$prevalue][] = ['changedon_getin'=>$tmp_changedon_getin,'changedon'=>$tmp_changedon,
                            'userid_getin'=>$smcreatorid,'userid'=>$whodid,
                            'interval'=>strtotime($tmp_changedon)-strtotime($tmp_changedon_getin)];
                    }else{
                        $start_stage = '';
                    }
                }else{
                    //本次的修改前值与上次的修改后值相同,则视为有效,添加停留时间记录
                    //将上次修改时间记录为进入时间,本次修改时间记录为离开时间
                    if(!empty($prevalue) && $prevalue==$all_changelog_arr[$i-1]['postvalue']){
                        $tmp_changedon_getin = $all_changelog_arr[$i-1]['changedon'];
                        $tmp_changedon = $changedon;
                        $all_stay_time_arr[$prevalue][] = ['changedon_getin'=>$tmp_changedon_getin,'changedon'=>$tmp_changedon,
                            'userid_getin'=>$all_changelog_arr[$i-1]['whodid'],'userid'=>$whodid,
                            'interval'=>strtotime($tmp_changedon)-strtotime($tmp_changedon_getin)];
                    }
                }

                $all_changelog_arr[] = ['prevalue'=>$prevalue,'postvalue'=>$postvalue,'changedon'=>$changedon,'whodid'=>$whodid];
			}
            //如果日志结束的最后一个阶段,与当前阶段相同,则视为有效,添加时间记录
            //将最后一次修改时间记录为进入时间,当前时间记录为离开时间
            if(!empty($cur_stage) && $cur_stage == $all_changelog_arr[$num_rows-1]['postvalue']){
                $tmp_changedon_getin = $all_changelog_arr[$num_rows-1]['changedon'];
                $tmp_changedon = date('Y-m-d H:i:s');
                $all_stay_time_arr[$cur_stage][] = ['changedon_getin'=>$tmp_changedon_getin,'changedon'=>$tmp_changedon,'interval'=>strtotime($tmp_changedon)-strtotime($tmp_changedon_getin)];
            }
		}
        $this->advance_track_data = $advance_track_data;
		//计算阶段的总计停留时长
        $stage_total_intervaltime_arr = [];
        foreach ($all_stay_time_arr as $tmp_stage=> $tmp_time_arr){
            $tmp_sum_time = 0;
            foreach ($tmp_time_arr as $tmp_time){
                $tmp_sum_time+= $tmp_time['interval'];
            }
            $stage_total_intervaltime_arr[$tmp_stage] = $tmp_sum_time;
        }
        //duan 2022-5-25 计算阶段滞留时间以及判断哪些阶段被跳过了
        //$allstage = $this->getAdvanceStageValues();
        $allstage = $this->getProcessStageValue($record);

        if(empty($data)){
            //duan 20230804 没有推进记录时,读取单据创建时间作为进入推进时间

            foreach($allstage as $key => $value){
                if($key>=0 && !empty($cur_stage) && $value != $cur_stage){
                    $data[$value]['skip'] = 'yes';
                    continue;
                }
                if($value == $cur_stage){
                    $data[$cur_stage]['userfullname_getin'] = getUserFullName($smcreatorid);
                    if($this->advance_type == 'pc'){
                        $createdtime = str_replace(" ","<br>",$createdtime);
                    }
                    $data[$cur_stage]['changedon_getin'] = $createdtime??'';
                }
            }
            return $data;
        }
        $pre_changedon_getout = '';
        foreach($allstage as $key => $value){
            //如果该阶段有离开时间但没有进入时间，则获取单据的创建时间，作为进入时间
            if(!empty($data[$value]['changedon']) && empty($data[$value]['changedon_getin'])){
                //避免重复读取数据库
                $data[$value]['userfullname_getin'] = getUserFullName($smcreatorid);
                if($this->advance_type == 'pc'){
					$createdtime = str_replace(" ","<br>",$createdtime);
				}
                $data[$value]['changedon_getin'] = $createdtime;
            }
            
            $changedon_getin = str_replace("<br>"," ",$data[$value]['changedon_getin']??'');
            $changedon_getout = str_replace("<br>"," ",$data[$value]['changedon']??'');
            
            //如果某一阶段的进入时间早于前面阶段的离开时间，说明发生了回推或跳过,则该阶段被标记为已跳过阶段
            if($key>=0 && !empty($this->getStagenameNow($record)) && $value != $this->getStagenameNow($record) &&(empty($changedon_getout) || (strtotime($changedon_getin)-strtotime($pre_changedon_getout)) <0) ){
                unset($data[$value]);
                $data[$value]['skip'] = 'yes';
                continue;
            }
            
            //计算当前阶段的滞留时间,使用当前时间代替离开时间
            if($value == $this->getStagenameNow($record)){
                $changedon_getout = date('Y-m-d H:i:s');
                //当前阶段没有离开时间
                unset($data[$value]['changedon']);
                unset($data[$value]['userfullname']);
            }
            //根据阶段进入或离开时间计算滞留时间，
            if(!empty($changedon_getin)&&!empty($changedon_getout)){
                $allsecond = strtotime($changedon_getout)-strtotime($changedon_getin);
                $content = $this->getTimeContent($allsecond);
            }
            if($this->advance_type == 'weixin'){
                $content = getFixedLabel('STAGEDETENTIONDURATION').':'.$content;
            }

            $data[$value]['staytimecontent'] = $content;
            if(isset($stage_total_intervaltime_arr[$value])){
                $all_content = $this->getTimeContent($stage_total_intervaltime_arr[$value]);
                if($this->advance_type == 'weixin'){
                    $all_content = getFixedLabel('STAGEDETENTIONDURATION').':'.$all_content;
                }
                $data[$value]['allstaytimecontent'] = $all_content;
            }else{
                $data[$value]['allstaytimecontent'] = $content;
            }

            if($this->moduleadvance['staytimemethod'] == 'sum'){
                $data[$value]['showstaytimecontent'] = $data[$value]['allstaytimecontent'];
            }else{
                $data[$value]['showstaytimecontent'] = $data[$value]['staytimecontent'];
            }


            //记录之前阶段最晚的离开时间
            if(!empty($changedon_getout)&&strtotime($changedon_getout)-strtotime($pre_changedon_getout)>0){
                $pre_changedon_getout = $changedon_getout;
            }
            
            //循环到当前阶段则停止
            if($value == $this->getStagenameNow($record)){
                break;
            }
        }
        
		return $data;

	}
	public function getTimeContent($allsecond){
        $hours = $allsecond/3600;
        $content = '';
        if($hours >=1 ){
            $hours = intval($hours);
            if($hours > 24){ //时长小于一天
                $days = intval($hours/24);
                $hours = $hours%24;
                $content = $hours.getFixedLabel('HOURS');
                if($days > 30){//时长大于一个月
                    $months = intval($days/30);
                    $days = $days%30;
                    $content = $days.getFixedLabel('Days').$content;
                    if($months >12 ){ //时长大于一年
                        $years = intval($months/12);
                        $months = $months%12;
                        $content = $months.getFixedLabel('nMonth').$content;
                        $content = $years.getFixedLabel('nYear').$content;
                    }else{
                        $content = $months.getFixedLabel('nMonth').$content;
                    }
                }else{
                    $content = $days.getFixedLabel('Days').$content;
                }
            }else{
                $content = $hours.getFixedLabel('HOURS');
            }

        }else{
            //时长小于一小时
            $minute = intval($allsecond/60);
            $second = $allsecond%60;
            if($minute >0)$content = $minute.getFixedLabel('MINUTE');
            $content .= $second.getFixedLabel('Second');
            //$content = getFixedLabel('LT').'1'.getFixedLabel('HOUR'); //小于1小时
        }
        return $content;
    }


	//重新遍历数组键值
	private function array_sort($picklistvalue){
		foreach($picklistvalue as $val){
			$data[] = $val;
		}
		return $data;
	}
	//判断单据是否已经推进
	public function is_AdvanceRecord($record){
		$res = '';
        if(is_array($this->advancefield_arr))
        {
          
            return $this->advancefield_arr;
        }
		if($this->advance_type == 'weixin')
            $is_enable = $this->is_MobileEnable();
		else
            $is_enable = $this->is_Enable();


		if($is_enable == 'no'){
			return '';
		}
		if($this->moduleadvance['method'] == 'field'){
			$fieldname = $this->moduleadvance['module_field'];
			$fields[] = $fieldname;
		}else{
			$fieldname = 'advance_stage';
			$fields[] = $this->moduleadvance['module_period_start_field'];
			$fields[] = $this->moduleadvance['module_period_end_field'];
		}
		//获取该字段的修改日志

		if(empty($record)){
			return $fields;
		}else{
			$modtracker_value = $this->getModtrackerData($record,$fieldname);
			foreach($modtracker_value as $date => $val){
				if(!empty($date) && !empty($val)){
					$res = $fields;
					break;
				}
			}

           $this->advancefield_arr=$res;
          
			return $res;
		}
	}
	//private function getRecordDbValue(){}
	//判断是否启用
	public function is_Enable(){
		//edit:duan date:2021-10-18 reason:没有推进权限的用户也能够看到进度追踪图
        //$isPermitted = isPermitted($this->module, 'Advance', '');
		// if($isPermitted == 'no'){
		// 	return 'no';
		// }

		if(empty($this->moduleadvance) || $this->moduleadvance['enable'] == 'no'){
			return 'no';
		}else{
    		//按指定字段
    		if($this->moduleadvance['method'] == 'field'){
    			$fieldname = $this->moduleadvance['module_field'];
    			$field = $this->modulefields[$fieldname];
    			if(empty($field)){
    				return 'no';
    			}
    		}else if($this->moduleadvance['method'] == 'period'){
    			$period_start_fieldname = $this->moduleadvance['module_period_start_field'];
    			$period_end_fieldname = $this->moduleadvance['module_period_end_field'];
    			$period_start_field = $this->modulefields[$period_start_fieldname];
    			$period_end_field = $this->modulefields[$period_end_fieldname];
    			if(empty($period_start_field) || empty($period_end_field)){
    				return 'no';
    			}
    		}
		}
		return 'yes';
	}

	//判断是否启用 - 手机端
	public function is_MobileEnable(){
	   //edit:duan date:2021-10-18 reason:没有推进权限的用户也能够看到进度追踪图
//		$isPermitted = isPermitted($this->module, 'Advance', '');
//		if($isPermitted == 'no'){
//			return 'no';
//		}
		if(empty($this->moduleadvance) || $this->moduleadvance['showadvancemobile'] == 'no'){
			return 'no';
		}else{
			//按指定字段
			if($this->moduleadvance['method'] == 'field'){
				$fieldname = $this->moduleadvance['module_field'];
				$field = $this->modulefields[$fieldname];
				if(empty($field)){
					return 'no';
				}
			}else if($this->moduleadvance['method'] == 'period'){
				$period_start_fieldname = $this->moduleadvance['module_period_start_field'];
				$period_end_fieldname = $this->moduleadvance['module_period_end_field'];
				$period_start_field = $this->modulefields[$period_start_fieldname];
				$period_end_field = $this->modulefields[$period_end_fieldname];
				if(empty($period_start_field) || empty($period_end_field)){
					return 'no';
				}
			}
		}
		return 'yes';
	}

	//获取当前模块的进度跟踪设置
	public function getModuleAdvance(){
		global $adb;
		$cachekey = 'ld_settigs_module_advance'.$this->tabid;
        $data = Cache($cachekey);
		if(!$data){
			$query = 'select tabid,module,enable,method,module_field,module_period_start_field,module_period_end_field,showadvancelog,showadvancemobile,pushback,operatestyle,logshowstyle,defaultshow,use_dependency,staytimemethod from ld_settings_advance where tabid = ? limit 1';
			$result = $adb->pquery($query,array($this->tabid));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$data = array(
						'module' => $adb->query_result($result,0,'module'),
						'enable' => $adb->query_result($result,0,'enable'),	
						'method' => $adb->query_result($result,0,'method'),	
						'module_field' => $adb->query_result($result,0,'module_field'),	
						'module_period_start_field' => $adb->query_result($result,0,'module_period_start_field'),	
						'module_period_end_field' => $adb->query_result($result,0,'module_period_end_field'),	
						'showadvancelog' => $adb->query_result($result,0,'showadvancelog'),	
						'showadvancemobile' => $adb->query_result($result,0,'showadvancemobile'),	
						'tabid' => $adb->query_result($result,0,'tabid'),
						'pushback' => $adb->query_result($result,0,'pushback'),
                        'operatestyle' => $adb->query_result($result,0,'operatestyle'),
                        'logshowstyle' => $adb->query_result($result,0,'logshowstyle'),
                        'defaultshow' => $adb->query_result($result,0,'defaultshow'),
                        'use_dependency' => $adb->query_result($result,0,'use_dependency'),
                        'staytimemethod' => $adb->query_result($result,0,'staytimemethod')
					);
				}
				Cache($cachekey,$data);
			}
		}
		return $data;
	}
	
	//获取两个日期之间的所有月份
	function dateMonths($start_date,$end_date,$explode='-',$addOne=false)
	{
	    if(empty($start_date) || $start_date <= '1970-01-01' || empty($end_date) || $end_date <= '1970-01-01'){
            return [];
        }

		//判断两个时间是不是需要调换顺序
		$start_int = strtotime($start_date);
		$end_int = strtotime($end_date);
		if($start_int > $end_int){
			$tmp = $start_date;
			$start_date = $end_date;
			$end_date = $tmp;
		}


		//结束时间月份+1，如果是13则为新年的一月份
		$start_arr = explode($explode,$start_date);
		$start_year = intval($start_arr[0]);
		$start_month = intval($start_arr[1]);


		$end_arr = explode($explode,$end_date);
		$end_year = intval($end_arr[0]);
		$end_month = intval($end_arr[1]);


		$data = array();
		$data[] = $start_date;


		$tmp_month = $start_month;
		$tmp_year = $start_year;


		//如果起止不相等，一直循环
		while (!(($tmp_month == $end_month) && ($tmp_year == $end_year))) {
			$tmp_month ++;
			//超过十二月份，到新年的一月份
			if($tmp_month > 12){
				$tmp_month = 1;
				$tmp_year++;
			}
			$data[] = $tmp_year.$explode.str_pad($tmp_month,2,'0',STR_PAD_LEFT);
		}


		if($addOne == true){
			$tmp_month ++;
			//超过十二月份，到新年的一月份
			if($tmp_month > 12){
				$tmp_month = 1;
				$tmp_year++;
			}
			$data[] = $tmp_year.$explode.str_pad($tmp_month,2,'0',STR_PAD_LEFT);
		}


		return $data;
	}

	//获取推进字段是否有设置了级联，并返回级联信息
	public function getColumnForDependencyPicklist($record){
		global $adb;
		$advance_stage = [];
		//@edit:liushuai,2020-12-22,reason:【ID1001157】进度跟踪设置功能优化（进度跟踪设置的字段为级联字段时，推进下拉框根据级联的值显示）
        $module_advance = $this->getModuleAdvance();//获取当前模块的进度跟踪设置 的设置字段
        $cur_advance_columnname = $module_advance['module_field'];  //bill_city  status
		
        global $global_pick_list_depencyfield;
        //重设级联字段的值，避免模块直接互相影响
        crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
        $picklistdepency = lingdang_DependencyPicklist::getPicklistDependencyDatasource($this->module);
        //edit:can 2021-01-08 44134: (61mis.com/kfbcrm)进度跟踪；OA表单-加班单；单据编号JB31， 加班单中设置了进度跟踪，跟踪的字段为级联字段；没有按照设置的级联字段显示
        $picklistdepencyfields =json_decode(ldcrm_json_encode($global_pick_list_depencyfield),true);
        if (isset($picklistdepencyfields[$cur_advance_columnname])) {  //推进字段是否是级联字段
            $focus = CRMEntity::getInstance($this->module);
            $table_name = $focus->table_name;
            $table_index = $focus->table_index;
            $customFieldTable=$focus->customFieldTable;
            $customtable=$customFieldTable[0];//获取自定义表名称
            $customid=$customFieldTable[1];//获取自定义表主键;

            $cur_advance_columnname_value = '';//当前级联字段的值
            $prev_advance_fieldname = $picklistdepencyfields[$cur_advance_columnname];//当前级联字段的父联字段
           
            $fieldobj=$focus->fieldobj->getFieldInfoobjBykey("fieldname",$prev_advance_fieldname);
            if(!$fieldobj)
            {
                
            }
            else{
                $prev_advance_columnname_value = '';

                //查询单据父联字段设置的值
				$columnname = $fieldobj->getColumnName();
                $query = "select $cur_advance_columnname,$columnname from $table_name inner join $customtable on $customtable.$customid = $table_name.$table_index where $table_name.$table_index = $record";
                $tmp_result = $adb->pquery($query,array());
                $num_rows = $adb->num_rows($tmp_result);
                if ($num_rows > 0) {
    
                    $prev_advance_columnname_value = $adb->query_result($tmp_result, 0, $columnname);
                }
               
                if (trim($prev_advance_columnname_value)!="") {
                    //假设推进字段为城市 bill_city    bill_city:$cur_advance_columnname,  上级字段为bill_state:$picklistdepencyfields[$cur_advance_columnname]
                    $advance_stage = $picklistdepency[$prev_advance_fieldname][$prev_advance_columnname_value][$cur_advance_columnname]; //参考省会城市地区的级联数据格式
                }
            }
        }
		return $advance_stage;
	}
    public function getcreator($record=''){//获取商机的创建人，创建时间
        global $adb;
        $sql = "SELECT ld_users.last_name as name ,ld_potential.createdtime as time 
                from ld_potential INNER JOIN ld_users on ld_potential.smcreatorid = ld_users.id 
                where ld_potential.potentialid = '$record'";
        $result = $adb->pquery($sql,array());
        $userfullname = $adb->query_result($result,0,'name');
        $changedon =$adb->query_result($result,0,'time');
        if($this->advance_type == 'pc'){
	       $changedon = str_replace(" ","<br>",$changedon);
				}
        $creator = array(
            'userfullname' => $userfullname,
            'changedon' => $changedon
            
        );
        return $creator;
    }
    
    public function comparetime($time_1='',$time_2='')//比较两个日期的大小，$time_1大则返回true
    {
        if(strpos($time_1,'<br>'))
        {
            $time_1 = str_replace('<br>',' ',$time_1);
        }
        if(strpos($time_2,'<br>'))
        {
            $time_2 = str_replace('<br>',' ',$time_2);
        }
        if(strtotime($time_1)-strtotime($time_2)>0){return true;}
        else{return false;}  
    }
    //模块阶段任务缓存
    public function  getadvancetask()
    {
        global $adb;
        $tabid = getTabid($this->module);
        $key = "cache_alladvancetask";
        $alladvancetask = cache($key);
        if(!$alladvancetask){
            $sql = "SELECT ld_advancepicklist.fieldname,ld_advancepicklist.stagename,ld_advancepicklist.stagename_target,
                            ld_advancepicklist.advanceid,ld_advancepicklist.autopush,ld_advancepicklist.tabid,
                            ld_advancepicklisttask.taskid,ld_advancepicklisttask.type,ld_advancepicklisttask.tasklabel,
                            ld_advancepicklisttask.completerequest,ld_advancepicklisttask.presence,ld_advancepicklisttask.sequence,
                            ld_advancepicklisttask.effect_range,ld_advancepicklisttask.approve_demand
                FROM ld_settings_advance INNER JOIN
            	ld_advancepicklist  on ld_settings_advance.tabid=ld_advancepicklist.tabid 	and ld_settings_advance.module_field=ld_advancepicklist.fieldname
                LEFT JOIN ld_advancepicklisttask ON ld_advancepicklisttask.advanceid = ld_advancepicklist.advanceid
                where ld_advancepicklisttask.presence <> 'no' and  (ld_advancepicklisttask.type <> '' or ld_advancepicklisttask.type is not null)
                ORDER BY ld_advancepicklist.advanceid,ld_advancepicklisttask.task_sequence,field(ld_advancepicklisttask.type,'field','module','select','checkbox'),ld_advancepicklisttask.sequence";
            $result = $adb->pquery($sql,array());
            $num_row = $adb->num_rows($result);
            
            $advancetaskarr = array(); 
            for($i = 0;$i<$num_row;$i++)
            {
                $tmp_tabid = $adb->query_result($result,$i,'tabid');
                $result_stagename = $adb->query_result($result,$i,'stagename')??'';
                $result_stagename_target = $adb->query_result($result,$i,'stagename_target')??'';
                $tmp_stagename = html_entity_decode($result_stagename);
                $tmp_stagename_target = html_entity_decode($result_stagename_target);
                $tmp_advanceid = $adb->query_result($result,$i,'advanceid');
                $tmp_completerequest = $adb->query_result($result,$i,'completerequest');
                $tmp_autopush = $adb->query_result($result,$i,'autopush');
                $tmp_taskid = $adb->query_result($result,$i,'taskid');
                $tmp_type = $adb->query_result($result,$i,'type');
                $tmp_presence = $adb->query_result($result,$i,'presence');
                $tmp_sequence = $adb->query_result($result,$i,'sequence');
                $effect_range = $adb->query_result($result,$i,'effect_range');
                $approve_demand = $adb->query_result($result,$i,'approve_demand');
                $result_tasklabel = $adb->query_result($result,$i,'tasklabel')??'';
                $tmp_tasklabel = html_entity_decode($result_tasklabel);
                $taskvaluearr = array();
                $taskvaluearr['type'] = $tmp_type;
                $taskvaluearr['tasklabel'] = $tmp_tasklabel;
                $taskvaluearr['taskid'] = $tmp_taskid;
                $taskvaluearr['completerequest'] = $tmp_completerequest;
                $taskvaluearr['effect_range'] = $effect_range;
                $taskvaluearr['approve_demand'] = $approve_demand;
                $taskvaluearr['presence'] = $tmp_presence;
                $taskvaluearr['sequence'] = $tmp_sequence;
                if($tmp_type == 'select'){
                    $query = "select selectinfo from ld_advancepicklist_selectinfo where taskid = ?";
                    $result_list = $adb->pquery($query,array($tmp_taskid));
                    $num_row_list = $adb->num_rows($result_list);
                    $listvaluearr = array();
                    for($j=0;$j<$num_row_list;$j++){
                        $tmp_selectinfo = $adb->query_result($result_list,$j,'selectinfo');
                        if(trim($tmp_selectinfo)!=""){
                            $listvaluearr[] = $tmp_selectinfo;
                        }
                    }
                    $taskvaluearr['selectinfo'] = $listvaluearr;
                }
                $advancetaskarr[$tmp_tabid][$tmp_advanceid]['advanceid'] = $tmp_advanceid;
                $advancetaskarr[$tmp_tabid][$tmp_advanceid]['stagename'] = $tmp_stagename;
                $advancetaskarr[$tmp_tabid][$tmp_advanceid]['stagename_target'] = $tmp_stagename_target;
                $advancetaskarr[$tmp_tabid][$tmp_advanceid]['autopush'] = $tmp_autopush;
                if(!empty($taskvaluearr['type'])&&!empty($taskvaluearr['tasklabel'])){
                    $advancetaskarr[$tmp_tabid][$tmp_advanceid]['taskvalue'][] = $taskvaluearr;
                }
            }
            cache($key,$advancetaskarr);
            $alladvancetask = cache($key);
        }
                
        return $alladvancetask[$tabid];
    }
    
    //读取追踪字段对应任务内容
    public function getadvancetaskbyfield($fieldname){
        global $adb;
        if($fieldname){
            $sql = "SELECT ld_advancepicklist.fieldname,ld_advancepicklist.stagename,ld_advancepicklist.stagename_target,
                            ld_advancepicklist.advanceid,ld_advancepicklist.autopush,
                            ld_advancepicklisttask.taskid,ld_advancepicklisttask.type,ld_advancepicklisttask.tasklabel,
                            ld_advancepicklisttask.completerequest,ld_advancepicklisttask.presence,ld_advancepicklisttask.task_sequence
                    FROM  ld_advancepicklist
                    LEFT JOIN ld_advancepicklisttask on ld_advancepicklisttask.advanceid = ld_advancepicklist.advanceid
                    where ld_advancepicklist.fieldname = '$fieldname' and ld_advancepicklist.tabid = ? 
                    order by ld_advancepicklist.advanceid,ld_advancepicklisttask.task_sequence,ld_advancepicklisttask.sequence";
            $result = $adb->pquery($sql,array($this->tabid));
            $num_row = $adb->num_rows($result);

            $advancetaskarr = array(); 
            for($i = 0;$i<$num_row;$i++)
            {
                $tmp_fieldname = $adb->query_result($result,$i,'fieldname');
                $tmp_stagename = html_entity_decode($adb->query_result($result,$i,'stagename'));
                $tmp_stagename_target = html_entity_decode($adb->query_result($result,$i,'stagename_target'));
                $tmp_advanceid = $adb->query_result($result,$i,'advanceid');
                $tmp_completerequest = $adb->query_result($result,$i,'completerequest');
                $tmp_autopush = $adb->query_result($result,$i,'autopush');
                $tmp_taskid = $adb->query_result($result,$i,'taskid');
                $tmp_type = $adb->query_result($result,$i,'type');
                $tmp_presence = $adb->query_result($result,$i,'presence');
                $tmp_task_sequence = $adb->query_result($result,$i,'task_sequence');
                $tmp_tasklabel = html_entity_decode($adb->query_result($result,$i,'tasklabel'));
                $taskvaluearr = array();
                $taskvaluearr['type'] = $tmp_type;
                $taskvaluearr['tasklabel'] = $tmp_tasklabel;
                $taskvaluearr['taskid'] = $tmp_taskid;
                $taskvaluearr['completerequest'] = $tmp_completerequest;
                $taskvaluearr['presence'] = $tmp_presence;
                $taskvaluearr['task_sequence'] = $tmp_task_sequence;
                if($tmp_type == 'select'){
                    $query = "select selectinfo from ld_advancepicklist_selectinfo where taskid = ? order by sequence";
                    $result_list = $adb->pquery($query,array($tmp_taskid));
                    $num_row_list = $adb->num_rows($result_list);
                    $listvaluearr = array();
                    for($j=0;$j<$num_row_list;$j++){
                        $tmp_selectinfo = $adb->query_result($result_list,$j,'selectinfo');
                        if(trim($tmp_selectinfo)!=""){
                            $listvaluearr[] = $tmp_selectinfo;
                        }
                    }
                    $taskvaluearr['selectinfo'] = $listvaluearr;
                }
                $advancetaskarr[$tmp_advanceid]['stagename'] = $tmp_stagename;
                $advancetaskarr[$tmp_advanceid]['stagename_target'] = $tmp_stagename_target;
                $advancetaskarr[$tmp_advanceid]['advanceid'] = $tmp_advanceid;
                $advancetaskarr[$tmp_advanceid]['autopush'] = $tmp_autopush;
                $advancetaskarr[$tmp_advanceid]['taskvalue'][$tmp_type][] = $taskvaluearr;
            }
        }
        return $advancetaskarr;
    }
    //设置跟踪字段，读取阶段信息
    public function getAdvanceStageValuesbyfiled($fieldname){
        if(!is_array($this->moduleadvance)){
            $this->moduleadvance = array();
        }
        $this->moduleadvance['method'] = 'field';
        $this->moduleadvance['module_field'] =$fieldname;
        return $this->getAdvanceStageValues();
    }
    //将阶段推进时间存到对象的属性中，避免多次访问数据库
    public function getPushtimebyrecord($record){
        global $adb;

        if(is_array($this->stagement_timearr) && sizeof($this->stagement_timearr)>0){//如果时间已经读取，就直接返回
            return $this->stagement_timearr;
        }
        $fieldname = $this->moduleadvance['module_field'];//追踪字段名称
        //获取当前阶段名称和任务创建时间
        $fieldinfo=$this->focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
        $main_tablename = $this->focus->table_name;
        $module_index=$this->focus->tab_name_index[$main_tablename];
        $sql_record_createtime = "select createdtime from $main_tablename where $module_index = ?";
        $result = $adb->pquery($sql_record_createtime,array($record));
        $record_createtime = $adb->query_result($result,0,'createdtime');
        $stagename_now = $this->getStagenameNow($record);

        //阶段推进时间，用于判断任务日志是否有效
        $sql_advancetime = "SELECT postvalue,changedon FROM ld_modtracker_basic
            INNER JOIN ld_modtracker_detail ON ld_modtracker_detail.`id` = ld_modtracker_basic.`id`
            INNER JOIN ld_settings_advance on ld_settings_advance.module_field = ld_modtracker_detail.fieldname
            where ld_settings_advance.tabid = ? and ld_modtracker_basic.crmid = ?  order by changedon desc";
        $result = $adb->pquery($sql_advancetime,array($this->tabid,$record));
        $num_row = $adb->num_rows($result);
        if($num_row>0){
            $stagement_timearr = array();
            for($i=0;$i<$num_row;$i++){
                $advance_pushtime = $adb->query_result($result,$i,'changedon');
                $tmp_stagename = html_entity_decode($adb->query_result($result,$i,'postvalue'));
                if(array_key_exists($tmp_stagename,$stagement_timearr)){
                    continue;
                }else{
                    //获取最新的阶段推进时间
                    $stagement_timearr[$tmp_stagename]=$advance_pushtime;
                }
            }
            //为每个阶段设置一个推进时间
            //$allstage_namearr = $this->getAdvanceStageValues();//追踪字段下拉框内容
            $allstage_namearr = $this->getProcessStageValue($record); //根据流程图获取下拉框内容

            $stagepushtime_arr = array();
            foreach($allstage_namearr as $key => $tmp_stagename){
                $tmp_pushtime=$stagement_timearr[$tmp_stagename];//获取阶段推进时间
                if(empty($tmp_pushtime)){//在没有阶段推进时间的情况下
                    if(isset($previous_time)){//如果上一阶段的时间存在则与上一阶段时间相同
                        $stagepushtime_arr[$tmp_stagename]=$previous_time;
                    }else{ //否则与创建时间相同
                        $stagepushtime_arr[$tmp_stagename]=$record_createtime;
                    }
                }else{//如果有推进时间
                    //要求每一个的阶段时间不能小于上一个阶段，若小于则与上阶段相同
                    if(isset($previous_time)&& $this->comparetime($previous_time,$tmp_pushtime)){
                        $stagepushtime_arr[$tmp_stagename] = $previous_time;
                    }else{
                        $stagepushtime_arr[$tmp_stagename] = $tmp_pushtime;
                        $previous_time=$tmp_pushtime;
                    }
                }
                if($tmp_stagename==$stagename_now)break;
            }
        }else{ //没有推进记录时按照单据创建时间
            $stagepushtime_arr[$stagename_now]=$record_createtime;
        }
        //将阶段推进时间存到对象的属性中
        $this->stagement_timearr = $stagepushtime_arr;
        return $this->stagement_timearr;
    }
    
    //一次获取所有阶段的日志信息，避免多次访问数据库
    public function getallTasklogbyrecord($record){
        global $adb;
        if($this->AdvanceTaskCheck($record)!='yes'){
            return array();
        }
        if(is_array($this->allTasklog) && sizeof($this->allTasklog)>0){//任务日志已读取时直接返回
            return $this->allTasklog;
        } 
            
        
        $stagement_timearr = $this->getPushtimebyrecord($record);
        //任务日志,如果任务完成时间比阶段推进时间早，说明有回推操作，则对应任务记录无效
        $sql_log = "select ld_advancepicklist.advanceid,ld_advancepicklistlog.taskid,ld_advancepicklist.stagename,ld_advancepicklisttask.effect_range,ld_advancepicklisttask.approve_demand,
                ld_advancepicklisttask.tasklabel,ld_advancepicklisttask.type,ld_advancepicklistlog.taskresult,ld_advancepicklistlog.createdtime,ld_advancepicklistlog.jourid 
            FROM  ld_advancepicklistlog
            INNER JOIN ld_advancepicklisttask ON ld_advancepicklisttask.taskid = ld_advancepicklistlog.taskid
            INNER JOIN ld_advancepicklist ON ld_advancepicklist.advanceid = ld_advancepicklisttask.advanceid
            where ld_advancepicklistlog.record = ? ORDER BY ld_advancepicklistlog.jourid desc";
        $result = $adb->pquery($sql_log,array($record));
        
        
        $num_row = $adb->num_rows($result);
        $tasklog = array();
        for($i=0;$i<$num_row;$i++){
            $taskid = $adb->query_result($result,$i,'taskid');
            $tmp_stagename = html_entity_decode($adb->query_result($result,$i,'stagename'));
            $tmp_advanceid = $adb->query_result($result,$i,'advanceid');
            $type = $adb->query_result($result,$i,'type');
            $effect_range = $adb->query_result($result,$i,'effect_range');

            if($type != 'module' && is_array($tasklog[$tmp_advanceid]) && array_key_exists($taskid,$tasklog[$tmp_advanceid])){
                continue;
            }
            $createdtime = $adb->query_result($result,$i,'createdtime');
            
            if(!isset($stagement_timearr[$tmp_stagename])){//如果没有推进时间说明在当前阶段之后
                continue;
            }else{
                //参数设为仅统计该阶段下创建的单据时，不需要考虑时间判断
                if($type == 'module' && in_array($effect_range,['getcur','getcurlastone'])){
                }else{
                    $advance_pushtime = $stagement_timearr[$tmp_stagename];
                    if(strtotime($createdtime)-strtotime($advance_pushtime)<0){
                        continue;
                    }
                }
            }

            $taskresult = $adb->query_result($result,$i,'taskresult');

            $tasklabel = $adb->query_result($result,$i,'tasklabel');
            if(empty($taskresult) && $type != 'field'){
                $effective = 'no';
            }else{
                $effective = 'yes';
            }
            if($type=='module' && is_array($tasklog) &&is_array($tasklog[$tmp_advanceid])&&array_key_exists($taskid,$tasklog[$tmp_advanceid])){

                if($effect_range == 'getcurlastone' && $tasklog[$tmp_advanceid][$taskid]['effective'] == 'yes'){
                    continue;
                }
            }else{
                $tasklog[$tmp_advanceid][$taskid] = array(
                    'taskresult'=>$taskresult,
                    'createdtime'=>$createdtime,
                    'effective' =>$effective
                );
            }

            //获取单据编号
            if($type=='module'&&!empty($tasklabel)&&!empty($taskresult)){
                //获取创建的 任务模块超链接字段的值
                $entityarray = getEntitynameInfo(getTabid($tasklabel));
                $entity_focus = CRMEntity::getInstance($tasklabel);
                $link_tabname = $entity_focus->table_name;
                $tablename_cf = $entity_focus->customFieldTable[0];
                $tablename_cf_index = $entity_focus->customFieldTable[1];
                $link_tabfieldname = $entityarray['fieldname'];
                $link_tabindex = $entityarray['entityidfield'];

                $sql_select_no = "select $link_tabfieldname,approvestatus,$link_tabname.$link_tabindex as crmid from $link_tabname left join $tablename_cf 
                    on $link_tabname.$link_tabindex = $tablename_cf.$tablename_cf_index 
                    where $link_tabname.$link_tabindex = $taskresult and $link_tabname.deleted = 0 limit 1";
                $tmp_result = $adb->pquery($sql_select_no,array());

                $tmp_num_row = $adb->num_rows($tmp_result);
                if($tmp_num_row>0){
                    $all_query_result = $adb->query_result_all($tmp_result);
                    if(isset($tasklog[$tmp_advanceid][$taskid]['crmid_arr'])){
                        $record_no_arr = $tasklog[$tmp_advanceid][$taskid]['record_no_arr'];
                        $crmid_arr = $tasklog[$tmp_advanceid][$taskid]['crmid_arr'];
                        $is_all_approved = $tasklog[$tmp_advanceid][$taskid]['is_all_approved'];
                    }else{
                        $record_no_arr = [];
                        $crmid_arr = [];
                        $is_all_approved = 'yes';
                    }

                    foreach ($all_query_result as $tmp_key=> $tmp_result){
                        $record_no = $tmp_result[$link_tabfieldname];
                        $approvestatus = $tmp_result['approvestatus'];
                        if(sizeof($crmid_arr) >0 ){
                            $show_record_no = ','.$record_no;
                        }else{
                            $show_record_no = $record_no;
                        }
                        $tmp_crmid = $tmp_result['crmid'];

                        if(!in_array($tmp_crmid,$crmid_arr)){
                            $record_no_arr[] = ['record_no'=>$record_no,'crmid'=>$tmp_crmid,'approvestatus'=>$approvestatus,'show_record_no'=>$show_record_no];
                            $crmid_arr[] = $tmp_crmid;
                        }

                        if($approvestatus != constant('D_A_S_APPROVED')){
                            $is_all_approved = 'no';
                        }
                    }
                    //二维数组内部按crmid排序
                    usort($record_no_arr, function($a, $b) {
                        return $a['crmid'] - $b['crmid'];
                    });
                    $tasklog[$tmp_advanceid][$taskid]['record_no_arr'] = $record_no_arr;
                    $tasklog[$tmp_advanceid][$taskid]['crmid_arr'] = $crmid_arr;
                    $tasklog[$tmp_advanceid][$taskid]['record_no'] = $record_no;
                    $tasklog[$tmp_advanceid][$taskid]['is_all_approved'] = $is_all_approved;
                }else{
                    if(isset($tasklog[$tmp_advanceid][$taskid]['crmid_arr'])){
                        $crmid_arr = $tasklog[$tmp_advanceid][$taskid]['crmid_arr'];
                        if(sizeof($crmid_arr) == 0)$tasklog[$tmp_advanceid][$taskid]['effective'] = 'no';
                    }else{
                        $tasklog[$tmp_advanceid][$taskid]['effective'] = 'no';
                    }
                }
            }
        }
        $this->allTasklog = $tasklog;
        return $this->allTasklog;
    }
    
    //获取日志信息，用于判断任务是否完成
    public function getTasklogbyrecord($record,$stagename_request){
        global $adb;
        
        $stagement_timearr = $this->getPushtimebyrecord($record);
        if(!isset($stagement_timearr[$stagename_request])){//如果没有推进时间说明在当前阶段之后,返回空
            return array();
        }else{
            $advance_pushtime = $stagement_timearr[$stagename_request];
        }
        //任务日志,如果任务完成时间比阶段推进时间早，说明有回推操作，则对应任务记录无效
        $sql_log = "SELECT ld_advancepicklistlog.taskid,tasklabel,taskresult,type,createdtime FROM  ld_advancepicklistlog
            INNER JOIN ld_advancepicklisttask ON ld_advancepicklisttask.taskid = ld_advancepicklistlog.taskid
            INNER JOIN ld_advancepicklist ON ld_advancepicklist.advanceid = ld_advancepicklisttask.advanceid
            where record = ? and stagename = ? and createdtime >= ? ORDER BY createdtime desc";
        $result = $adb->pquery($sql_log,array($record,$stagename_request,$advance_pushtime));
        $num_row = $adb->num_rows($result);
        $tasklog = array();
        for($i=0;$i<$num_row;$i++){
            $taskid = $adb->query_result($result,$i,'taskid');
            if(array_key_exists($taskid,$tasklog)){
                continue;
            }
            $taskresult = $adb->query_result($result,$i,'taskresult');
            $createdtime = $adb->query_result($result,$i,'createdtime');
            $type = $adb->query_result($result,$i,'type');
            $tmp_stagename = $adb->query_result($result,$i,'stagename');
            $tasklabel = $adb->query_result($result,$i,'tasklabel');
            if(empty($taskresult)){
                $effective = 'no';
            }else{
                $effective = 'yes';
            }
            $tasklog[$taskid] = array(
                'taskresult'=>$taskresult,
                'createdtime'=>$createdtime,
                'effective' =>$effective
            );
            //获取单据编号
            if($type=='module'&&!empty($tasklabel)&&!empty($taskresult)){
                $entityarray = getEntitynameInfo(getTabid($tasklabel));
                $entity_focus = CRMEntity::getInstance($tasklabel);
                $link_tabname = $entityarray['tablename'];
                $tablename_cf = $entity_focus->customFieldTable[0];
                $tablename_cf_index = $entity_focus->customFieldTable[1];
                $link_tabfieldname = $entityarray['fieldname'];
                $link_tabindex = $entityarray['entityidfield'];
                
                $sql_select_no = "select $link_tabfieldname from $link_tabname inner join $tablename_cf 
                        on $link_tabname.$link_tabindex = $tablename_cf.$tablename_cf_index 
                        where $link_tabname.$link_tabindex = $taskresult and deleted = 0 limit 1";
                $result = $adb->pquery($sql_select_no,array());
                if($adb->num_rows($result)>0){
                    $record_no = $adb->query_result($result,0,$link_tabfieldname);
                    $tasklog[$taskid]['record_no'] = $record_no;
                }else{
                    $tasklog[$taskid]['effective'] = 'no';
                }
            }
        }
        return $tasklog;
    }
                
    //判断阶段任务是否全部完成，以及是否触发自动推进
    public function TaskCompleteCheck($record,$check_stagename_target=''){
        global $adb,$current_user;

        if($this->AdvanceTaskCheck($record)!='yes'){
            return array();
        }

        //获取单据当前的阶段名称
        $stagename_now = $this->getStagenameNow($record);
        $get_entity = 'no';

        $all_tasklog_arr = $this->getallTasklogbyrecord($record);

        $all_taskinfo_arr = $this->getadvancetask();//所有的任务信息

        $AdvanceRelations = $this->getAdvanceRelationsByuser($record);//当前阶段与其他阶段的推进关系
        //$picklist_value = $this->getAdvanceStageValues();
        $picklist_value = $this->getProcessStageValue($record);
        //对推进阶段重新排序

        $after_relation = array();
        $before_relation = array();
        $tmp_picklist_value = array_keys($picklist_value);
        
        $curstage_sequence = array_search($stagename_now,$picklist_value);
        foreach($AdvanceRelations as $advanceid=>$tmp_relation){
            $tmp_stagename = $tmp_relation['stagename_target'];
            $tmp_sequence = array_search($tmp_stagename,$picklist_value);
            if($tmp_sequence < $curstage_sequence){
                $tmp_relation['advanceid'] = $advanceid;
                $before_relation[] = $tmp_relation;
            }else{
                $tmp_relation['advanceid'] = $advanceid;
                $after_relation[] = $tmp_relation;
            }
        }
        $new_AdvanceRelations = array_merge($after_relation,$before_relation);
        $errormsg_arr = []; //记录推进的错误提示

        //推进时增加验证规则判断
        $PageValidataSaveobj = '';
        crm_load_class_file('AttachmentUtils','modules/Attachment');
        $AttachmentUtilsObj = new AttachmentUtils();
        //记录需要保存历史的附件日志
        $all_filejsondata_arr = '';
        $attachmentlogsinfo_arr = [];
        foreach($new_AdvanceRelations as $tmp_relation){
            $advanceid = $tmp_relation['advanceid'];
            $taskinfo_arr = $all_taskinfo_arr[$advanceid]['taskvalue'];
            $task_num = 0;
            $task_complete = 'yes';
            $tasklog_arr = $all_tasklog_arr[$advanceid];
            $allow_push = 'yes';
            $tmp_errormsg_arr = [];//错误提示
            $tmp_remind_arr = [];//验证规则允许保存提示
            $stagename_target = $tmp_relation['stagename_target'];
            if($check_stagename_target !='' && $stagename_target != $check_stagename_target){
                continue;
            }

            //根据创建单据任务的设置，判断是否需要额外读取关联单据信息
            $tasklog_arr = $this->addAllModuletasklog($taskinfo_arr,$tasklog_arr,$record);

            foreach($taskinfo_arr as $key=>$tmp_taskinfo_arr){
                $type = $tmp_taskinfo_arr['type'];
                $taskid = $tmp_taskinfo_arr['taskid'];
                if(empty($tmp_taskinfo_arr['tasklabel']))
                    continue;
                if($type=='select'&&sizeof($tmp_taskinfo_arr['selectinfo'])==0)
                    continue;
                if($type == 'field'){
                    //判断不满足条件的任务，continue表示默认完成
                    //避免重复调用retrieve_entity_info方法
                    if($get_entity == 'no'){
                        global $reset_retrieve_entity_info;
                        $orgin_value = $reset_retrieve_entity_info;
                        $reset_retrieve_entity_info = 'yes';
                        $this->focus->retrieve_entity_info($record,$this->module);
                        $this->focus = $this->setColumnValuesFromRequest($this->focus);
                        if(!empty($stagename_target)){
                            $stage_fieldname = $this->moduleadvance['module_field'];//追踪字段名称
                            $this->focus->column_fields[$stage_fieldname] = $stagename_target;
                        }
                        $get_entity = 'yes';
                        $this->focus->id = $record;
                        $reset_retrieve_entity_info = $orgin_value;
                        if($this->module == 'Accounts' ){
                            $this->focus = $this->getContactInfo($this->focus);
                        }
                        if($this->usefieldrule == 'yes'){
                            //审批必填字段增加布局规则判断
                            $fieldrulecolsproperty = $this->getFieldRuleColumn($this->focus,$this->focus->column_fields);
                            $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏字段
                            //$displaycolumns=$fieldrulecolsproperty['displaycolumns'];//不是快速创建的字段，但是符合布局规则的要求
                            $requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
                        }
                    }
                    $focus = $this->focus;
                    $fieldobj = $focus->fieldobj;
                    $tmp_fieldinfoobj = $fieldobj->getFieldInfoobjBykey('fieldname',$tmp_taskinfo_arr['tasklabel']);
                    //todo:是否需要判断没有权限看到的字段是否完成
                    if(empty($tmp_fieldinfoobj)){
                        continue;
                    }
                    $tmp_fieldname = $tmp_fieldinfoobj->getFieldName();
                    $tmp_columnname = $tmp_fieldinfoobj->getColumnName();
                    $bigtype = $tmp_fieldinfoobj->getBigType();
                    //布局规则隐藏的字段不需要判断任务，必填字段在保存的时候判断，不做处理
                    if(is_array($hidecolumns)  && in_array($tmp_columnname,$hidecolumns)){
                        continue;
                    }

                    //除了关联选择单据字段和用户字段，值为0不表示为空
                    $noempty = 'no';
                    if(!in_array($bigtype,['reference','users','selectoneuser','selectmultiuser'])){
                        if(is_numeric($focus->column_fields[$tmp_fieldname]) && ($focus->column_fields[$tmp_fieldname] == 0 || $focus->column_fields[$tmp_fieldname] == '0') ){
                            $noempty = 'yes';
                        }
                    }
                    $fieldvalue = $focus->column_fields[$tmp_fieldname];

                    if(isset($focus->column_fields[$tmp_fieldname])&&(!empty($focus->column_fields[$tmp_fieldname]) || $noempty == 'yes')){
                        $task_num++;
                    }else if($bigtype == 'fileattachment'){
                        $task_num++;
                        if(!is_array($all_filejsondata_arr)){
                            $all_filejsondata_arr = $AttachmentUtilsObj->getAllFile_imageInfo_nocache($record,$this->module);
                        }
                        if(is_array($all_filejsondata_arr) && isset($all_filejsondata_arr[$tmp_columnname])){
                            $filejsondata_arr = $all_filejsondata_arr[$tmp_columnname];
                        }else{
                            $filejsondata_arr = [];
                        }

                        if(empty($filejsondata_arr)){
                            if($tmp_taskinfo_arr['completerequest'] == 'yes'){ //如果该任务未完成且为必做，则不可推进
                                $allow_push = 'no';
                            }
                            $task_complete = 'no';
                        }else{
                            $fieldvalue = '';
                            //记录历史数据并存到附件历史表里ld_attachments_history
                            if(is_array($filejsondata_arr)){
                                foreach($filejsondata_arr as $tmp_index=>$tmp_info){
                                    $tmp_fileid = $tmp_info['fileid'];
                                    if(empty($fieldvalue)){
                                        $fieldvalue = $tmp_fileid;
                                    }else{
                                        $fieldvalue = $fieldvalue.",".$tmp_fileid;
                                    }
                                    $new_info = $AttachmentUtilsObj->getTransColumnValue($tmp_info,'save');
                                    $new_info['crmid'] = $record;
                                    $attachmentlogsinfo_arr[$tmp_fieldname][$tmp_fileid] = $new_info;
                                }
                            }
                        }
                    }else{
                        if($tmp_taskinfo_arr['completerequest'] == 'yes'){ //如果该任务未完成且为必做，则不可推进
                            $allow_push = 'no';
                        }
                    
                        $task_complete = 'no';
                        $task_num++;
                    }
                    //如果存在历史日志则更新信息，不存在则添加日志
                    if(isset($tasklog_arr[$taskid]['effective']) && $tasklog_arr[$taskid]['effective'] == 'yes'){
                        //附件需要删除历史数据
                        if($bigtype == 'fileattachment'){
                            $old_fileid = $tasklog_arr[$taskid]['taskresult'];
                            $AttachmentUtilsObj->deleteUnuseFileHistory($record,$old_fileid,$tmp_fieldname);
                        }
                        $update_sql_tasklog = "update ld_advancepicklistlog set taskresult = ?,smcreatorid=?,createdtime=now() where taskid = ? and record = ? ";
                        $adb->pquery($update_sql_tasklog,array($fieldvalue,$current_user->id,$taskid,$record));
                    }else{
                        $insert_sql_tasklog = "insert into ld_advancepicklistlog(taskid,record,taskresult,smcreatorid,createdtime) values(?,?,?,?,now())";
                        $adb->pquery($insert_sql_tasklog,array($taskid,$record,$fieldvalue,$current_user->id));
                    }
                }else if($type == 'module'){
                    //创建单据任务
                    $effect_range = $tmp_taskinfo_arr['effect_range'];
                    $approve_demand = $tmp_taskinfo_arr['approve_demand'];
                    $related_module = $tmp_taskinfo_arr['tasklabel'];
                    $tmp_complete = 'no';
                    $approve_complete = 'yes';
                    $record_arr = $tasklog_arr[$taskid]['record_no_arr'];
                    $no_approved_record = [];

                    if(is_array($record_arr) && count($record_arr)>0){
                        $tmp_complete = 'yes';
                        foreach ($record_arr as $tmp_info){
                            if($approve_demand == 'yes' && $tmp_info['approvestatus'] != constant('D_A_S_APPROVED')){
                                $tmp_complete = 'no';
                                $approve_complete = 'no';
                                $no_approved_record[] = $tmp_info['record_no'];
                            }
                        }
                    }

                    if($tmp_complete == 'yes'){
                    }else{
                        $task_complete = 'no';
                        //edit:duan date:2024/10/15 reason: 单据未审批时,任务不必做时也不允许推进
                        if($tmp_taskinfo_arr['completerequest'] == 'yes' || $approve_complete == 'no'){//如果该任务未完成且为必做，则不可推进
                            $allow_push = 'no';
                            if($approve_complete == 'no'){
                                $tmp_errormsg_arr[] = getFixedLabel('NOTPUSHWITHOUTAPPROVAL');
                                $tmp_errormsg_arr[] = getTranstab($related_module).':'.implode(',',$no_approved_record);
                            }
                        }
                    }
                    $task_num++;
                }else if($type == 'validata'){
                    //推进任务的验证规则
                    $validataid = $tmp_taskinfo_arr['tasklabel'];
                    if(empty($validataid))
                        continue;
                    if(empty($PageValidataSaveobj)){
                        $application = 'advance_self';
                        $PageValidataSaveobj=new cls_PageValidataSave($this->module,$record,0);
                        $PageValidataSaveobj->ResetCurrencyid();
                        $PageValidataSaveobj->setApplication($application);
                        $PageValidataSaveobj->getDetailRowcnt();
                    }
                    $PageValidataSaveobj->errortip = '';
                    $PageValidataSaveobj->setChooseValidataid($validataid);
                    $PageValidataSaveobj->setAllowSave('no');
                    $PageValidataSaveobj->getValidDataInfoPhp();
                    if(!empty($PageValidataSaveobj->errortip)){
                        $task_complete = 'no';
                        $allow_push = 'no';
                        $tmp_errormsg_arr[] = $PageValidataSaveobj->errortip;
                    }else{
                        $PageValidataSaveobj->setAllowSave('yes');
                        $PageValidataSaveobj->getValidDataInfoPhp();
                        if(!empty($PageValidataSaveobj->errortip)){
                            $tmp_remind_arr[] = $PageValidataSaveobj->errortip;
                        }
                    }
                    $task_num++;
                }else if($tasklog_arr[$taskid]['effective'] =='yes'){
                    $task_num++;
                }else{
                    $task_complete = 'no';
                    $task_num++;
                    if($tmp_taskinfo_arr['completerequest'] == 'yes'){//如果该任务未完成且为必做，则不可推进
                        $allow_push = 'no';
                    }
                }
                if($allow_push == 'no'){
                    break;
                }
            }
            //不允许推进时,添加默认提示
            if($allow_push == 'no' && count($tmp_errormsg_arr) == 0){
                $tmp_errormsg_arr[] = getFixedLabel('CANNOTMOVEBEFORECOMPLETEPC');
            }
            //允许推进时,增加验证规则提示返回值
            if($allow_push == 'yes' && count($tmp_remind_arr) > 0){
                $tmp_errormsg_arr = $tmp_remind_arr;
            }
            
            $task_complete_arr[$stagename_target] = $task_complete;
            $allowpush_arr[$stagename_target] = $allow_push;
            $errormsg_arr[$stagename_target] = $tmp_errormsg_arr;

            if($task_complete!='no'&&$tmp_relation['autopush']=='yes'&&$task_num>0){//执行自动推进
                $this->updateModuleAdvanceStage($record,$stagename_target);
                $push_success = 'yes';
                break;
            }
        }

        if(sizeof($attachmentlogsinfo_arr)>0){
            $AttachmentUtilsObj->saveAttachmentImgLogs($attachmentlogsinfo_arr);
        }

        $result = array('task_complete_result'=>$task_complete_arr,
                        'allow_push'=>$allowpush_arr,
                        'push_success'=>$push_success,
                        'allow_edit'=>'yes',
                        'task_num'=>$task_num,
                        'errormsg_arr'=>$errormsg_arr);

        return $result;
    }
    //edit:duan date:2024/10/15 reason:获取单据的相关信息
    public function getRelatedRecordArr($cur_crmid,$related_module){
	    if(isset($this->allRelatedRecordArr[$cur_crmid]) && isset($this->allRelatedRecordArr[$cur_crmid][$related_module])){
	        return $this->allRelatedRecordArr[$cur_crmid][$related_module];
        }

	    global $adb;
	    $RecordArr = [];
        $record = $cur_crmid;
        $cur_tabid = $this->tabid;
        $related_tabid = getTabid($related_module);
        //获取创建的 任务模块超链接字段的值
        $entityarray = getEntitynameInfo($related_tabid);
        $entity_focus = CRMEntity::getInstance($related_module);
        $link_tabname = $entity_focus->table_name;
        $tablename_cf = $entity_focus->customFieldTable[0];
        $tablename_cf_index = $entity_focus->customFieldTable[1];
        $link_tabfieldname = $entityarray['fieldname'];
        $link_tabindex = $entityarray['entityidfield'];

        //需要统计所有的相关信息
        $relationInfo = getRelatedListInfoByTabid($cur_tabid,$related_tabid);

        //crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
        //$cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($this->module,$relationInfo,$record);
        //$query_obj=$cls_getRelatedInfoobj->getDataCategory_sqlObj();
        //$page_list_query= $query_obj->getQuery('groupby');
        crm_load_class_file('cls_module_uitype', 'include/fields');
        $uitypetypemodule_arr = cls_module_uitype::getUitypeModules();
        $all_presence_field = $entity_focus->fieldobj->getModuleAllPreseneceFields();
        $where_sql_arr = [];

        foreach ($all_presence_field as $fieldname => $fieldinfo) {
            $tablename = $fieldinfo->getTableName();
            $columnname = $fieldinfo->getColumnName();
            if ($fieldinfo->getBigType() == 'reference') {
                $uitype = $fieldinfo->getUIType();

                $modulename = $uitypetypemodule_arr[$uitype];
                if($modulename == $this->module){
                    $where_sql_arr[] = ' '.$tablename.'.'.$columnname.' = '.$cur_crmid;
                }
            } else if ($fieldinfo->getBigType() == 'selectsource' || $fieldinfo->getUIType() == 112) {
                $where_sql_arr[]= ' FIND_IN_SET('.$cur_crmid.','.$tablename.'.'.$columnname.')';
            }
        }
        if(count($where_sql_arr)==0)return [];
        $where_sql = ' and ('.implode(' or ',$where_sql_arr).')';

        $sql_select_no = "select $link_tabfieldname as record_no,approvestatus,$link_tabname.$link_tabindex as crmid from $link_tabname inner join $tablename_cf 
			on $link_tabname.$link_tabindex = $tablename_cf.$tablename_cf_index ";

        //$sql_select_no.=" inner join ( $page_list_query ) as temp on temp.$link_tabindex=$link_tabname.$link_tabindex";

        $sql_select_no .= " where $link_tabname.deleted = 0 ".$where_sql;

        $tmp_result = $adb->pquery($sql_select_no,array());

        $num_row = $adb->num_rows($tmp_result);
        if($num_row>0){
            $all_query_result = $adb->query_result_all($tmp_result);
            foreach ($all_query_result as $tmp_rowvalue){
                $tmp_arr = [];
                $tmp_arr['record_no'] = $tmp_rowvalue['record_no'];
                $tmp_arr['crmid'] = $tmp_rowvalue['crmid'];
                $tmp_arr['approvestatus'] = $tmp_rowvalue['approvestatus'];
                $RecordArr[] = $tmp_arr;
            }
        }
        return $RecordArr;
    }

    //判断模块单据阶段任务是否完成($record_new：新建的单据，$frommodule：新创建单据的模块名，$record：关联的单据id)
    public function ModuleTaskCompleteCheck($record_new,$frommodule,$record){
        global $adb,$current_user;
        $this->record = $record;
        //该模块追踪类型不是字段或没有启用追踪则返回空
        if($this->AdvanceTaskCheck($record)!='yes'){
            return array();
        }

        $all_taskinfo_arr = $this->getadvancetask();//所有的任务信息
        $AdvanceRelations = $this->getAdvanceRelationsByuser($record);//当前阶段与其他阶段的推进关系
        $all_tasklog_arr = $this->getallTasklogbyrecord($record);//任务完成日志
        $alltaskinfo_detailview_arr = array();
        $stagename_now = $this->getStagenameNow($record);          
        foreach($AdvanceRelations as $advanceid=>$tmp_relation){ //循环所有与当前阶段相关的推进关系
            $findtask_success = 'no';//寻找与新单据相关的任务
            $taskinfo_arr = $all_taskinfo_arr[$advanceid];
            $tasklog_arr = $all_tasklog_arr[$advanceid];
            if(is_array($taskinfo_arr['taskvalue']) && sizeof($taskinfo_arr['taskvalue'])>0){
                foreach($taskinfo_arr['taskvalue'] as $key => $taskvalue_arr){
                    //判断是否存在相关任务，以及该任务是否已完成
                    if($taskvalue_arr['type']=='module'&&$taskvalue_arr['tasklabel']==$frommodule){
                        if($tasklog_arr[$taskvalue_arr['taskid']]['effective'] !='yes'){
                            $findtask_success = 'yes';
                            $taskid = $taskvalue_arr['taskid'];
                            break;
                        }else{
                            $findtask_success = 'yes';
                            $taskid = $taskvalue_arr['taskid'];
                            $crmid_arr = $tasklog_arr[$taskid]['crmid_arr'];
                            if(in_array($record_new,$crmid_arr)){
                                $findtask_success = 'no';
                            }
                            if($findtask_success == 'yes'){
                                break;
                            }
                        }

                    }
                }
                
                if($findtask_success=='yes'){//添加任务日志
                    $insert_sql_tasklog = "insert into ld_advancepicklistlog(taskid,record,taskresult,smcreatorid,createdtime) values(?,?,?,?,?)";
                    $adb->pquery($insert_sql_tasklog,array($taskid,$record,$record_new,$current_user->id,date('Y-m-d H:i:s')));
                    unset($this->stagement_timearr);
                    unset($this->allTasklog);
                    unset($this->AdvanceRelationByuser_arr);
                    $TaskcheckResult_arr = $this->TaskCompleteCheck($record,'');//判断该阶段是否完成以及自动推进
                }
            }
        }
    }
    //判断模块是否使用了销售自动化任务
    public function AdvanceTaskCheck($record){
        if(isset($this->task_check)){
            return $this->task_check;
        }

        $this->task_check = 'no';
	    //追踪类型为字段时才能启用自动化任务
        if($this->moduleadvance['enable'] != 'yes'||$this->moduleadvance['method'] != 'field'){
            return 'no';
        }

        //追踪字段未启用则判定未启用任务
        $fieldname = $this->moduleadvance['module_field'];
		$field = $this->modulefields[$fieldname];
        if(!$field)
            return 'no';

        $all_taskinfo_arr = $this->getadvancetask();//所有的任务信息
        $AdvanceRelation = $this->getAdvanceRelations($fieldname);//当前阶段与其他阶段的推进关系
        $task_num = 0;

        foreach($AdvanceRelation as $stagename_start => $tmp_relation){
            foreach($tmp_relation as $stagename_target => $tmp_relation_second){
                if($tmp_relation_second['presence'] != 'yes'){
                    continue;
                }
                $advanceid = $tmp_relation_second['advanceid'];
                $taskinfo_arr = $all_taskinfo_arr[$advanceid];
                
                if(is_array($taskinfo_arr) && sizeof($taskinfo_arr['taskvalue'])>0){
                    foreach($taskinfo_arr['taskvalue'] as $key => $value){
                        if(empty($value['tasklabel']))
                            continue;
                        if($tmp_type=='select'&&sizeof($value['selectinfo'])==0)
                            continue;
                        $task_num++;
                        break;
                    }
                }
            }   
        }

        if($task_num > 0){
            $this->task_check = 'yes';
            return 'yes';
        }
        
        return 'no';
    }
    //获取单据当前的阶段名称
    public function getStagenameNow($record){
        global $adb;
        if(isset($this->stagename_now_arr[$record])){
            return $this->stagename_now_arr[$record];
        }else{
            $fieldname = $this->moduleadvance['module_field'];//追踪字段名称          
            $fieldinfo=$this->focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
            if(!$fieldinfo)
                return '';
            $columnname=$fieldinfo->getColumnName();
            $tablename=$fieldinfo->getTableName();
            $module_index=$this->focus->tab_name_index[$tablename];
            $sql_record_stagename = "select $columnname from $tablename where $module_index = $record";
            $result = $adb->pquery($sql_record_stagename,array());
            if($adb->num_rows($result)>0){
                $stagename_now = $adb->query_result($result,0,$columnname);
                $this->stagename_now_arr[$record] = html_entity_decode($stagename_now);
            }
        }
        return $this->stagename_now_arr[$record];
    }
    
    //获取详情页上所有的任务信息
    public function get_alltaskinfo_detailview($record){

        $this->record = $record;
        //该模块追踪类型不是字段或没有启用追踪则返回空
        if($this->moduleadvance['enable'] != 'yes'||$this->moduleadvance['method'] != 'field'){
            return array();
        }
        $AdvanceRelations = $this->getAdvanceRelationsByuser($record);//当前阶段与其他阶段的推进关系
        
        if($this->moduleadvance['operatestyle'] == 'inpopup'&&$this->showtype != 'inpopup'){
            return $AdvanceRelations;
        }
        
        $all_taskinfo_arr = $this->getadvancetask();//所有的任务信息
        $all_tasklog_arr = $this->getallTasklogbyrecord($record);//任务完成日志
        $alltaskinfo_detailview_arr = array();
        //获取选中的下一阶段id
        if(isset($_REQUEST['advanceid'])&&$_REQUEST['advanceid']>0){
            $next_advanceid = $_REQUEST['advanceid'];
        }else{
            $next_advanceid = $this->getLastUpdateAdvanceid($record);
        }
        $stagename_now = $this->getStagenameNow($record);
        foreach($AdvanceRelations as $advanceid=>$tmp_relation){ //读取任务和日志信息传到详情页
            if(empty($next_advanceid)){ //未指定下一阶段时，默认选中第一项
                $next_advanceid = $advanceid;
            }
            if($advanceid == $next_advanceid){
                $alltaskinfo_detailview_arr[$advanceid]['selected'] = 'yes';
                $taskinfo_arr = $all_taskinfo_arr[$advanceid];
                $tasklog_arr = $all_tasklog_arr[$advanceid];
                //根据创建单据任务的设置，判断是否需要额外读取关联单据信息
                $tasklog_arr = $this->addAllModuletasklog($taskinfo_arr['taskvalue'],$tasklog_arr,$record);

                $this->fieldtask_num = 0;
                //将必填字段任务类型中增加需要显示的html
                if($this->advance_type != 'weixin'){
                    $taskinfo_arr = $this->getEditviewFieldHtml($taskinfo_arr,$record,'yes',$tmp_relation['stagename_target'],$tasklog_arr);
                }
                
                $task_num = is_array($taskinfo_arr)?sizeof($taskinfo_arr['taskvalue']):[];
                
                
                if($task_num>0){
                    $alltaskinfo_detailview_arr[$advanceid]['tasklog'] = $tasklog_arr;
                    $alltaskinfo_detailview_arr[$advanceid]['taskinfo'] = $taskinfo_arr;
                    $alltaskinfo_detailview_arr[$advanceid]['allow_edit'] = 'yes';
                } 
            }else{
                $alltaskinfo_detailview_arr[$advanceid]['selected'] = 'no'; 
            }
            $alltaskinfo_detailview_arr[$advanceid]['tasknum'] = $task_num;
            $alltaskinfo_detailview_arr[$advanceid]['fieldtask_num'] = $this->fieldtask_num;
            $alltaskinfo_detailview_arr[$advanceid]['stagename'] = $stagename_now;
            $alltaskinfo_detailview_arr[$advanceid]['mapmodule'] = $tmp_relation['map_module'];
            $alltaskinfo_detailview_arr[$advanceid]['stagename_target'] = $tmp_relation['stagename_target'];
        }
        return $alltaskinfo_detailview_arr;
    }
    //获取移动端需要显示的推进和任务信息
    public function get_weixin_taskinfo($record){
        global $adb,$current_user;
        //该模块追踪类型不是字段或没有启用追踪则返回空
        if($this->moduleadvance['enable'] != 'yes'||$this->moduleadvance['method'] != 'field'){
            return array();
        }
        //非管理员  控制只读字段不在模块的新增和编辑时显示
    	if($current_user->is_admin=='off'){
    		$profileobj=Profile::getInstance();
    		$profilefields= $profileobj->getProfileInfos($current_user->profileid);
    		$profilefields=$profilefields['field'];
    	}
        $return_result = array();
        //获取当前用户可见的推进关系
        $all_taskinfo_arr = $this->getadvancetask();//所有的任务信息
        $all_tasklog_arr = $this->getallTasklogbyrecord($record);//任务完成日志
        //阶段详情显示
        if($this->showtype == 'detail'){
            /*
            $sql = "SELECT ld_advancepicklist.advanceid,tmp.prevalue,tmp.postvalue from ld_advancepicklist INNER JOIN (
                        SELECT
                        	prevalue,postvalue
                        FROM
                        	ld_modtracker_basic
                        INNER JOIN ld_modtracker_detail ON ld_modtracker_basic.id = ld_modtracker_detail.id
                        WHERE ld_modtracker_basic.crmid = ? and ld_modtracker_detail.fieldname = ? AND prevalue = ?
                        ORDER BY ld_modtracker_basic.changedon desc limit 1) as tmp 
                        on ld_advancepicklist.stagename = tmp.prevalue and ld_advancepicklist.stagename_target = tmp.postvalue;
                        ";
            $result = $adb->pquery($sql,array($record,$this->moduleadvance['module_field'],$_REQUEST['stagename']));

            if($adb->num_rows($result)>0){
                $advanceid = $adb->query_result($result,0,'advanceid');
                $prevalue = $adb->query_result($result,0,'prevalue');
                $postvalue = $adb->query_result($result,0,'postvalue');
            }else{
                return array();
            }
            */
            //edit:duan date:2024/12/16 reason:根据下拉框修改日志，转换历史选项的数据
            $fieldname = $this->moduleadvance['module_field'];

            $track_advance_data = $this->getAdvanceTrackData($record,$fieldname);
            //按修改时间进行降序排列
            usort($track_advance_data, function($a, $b) {
                return strtotime($b['changedon']) - strtotime($a['changedon']);
            });
            foreach ($track_advance_data as $tmp_arr){
                if($tmp_arr['prevalue'] == $_REQUEST['stagename']){
                    $prevalue = $tmp_arr['prevalue'];
                    $postvalue = $tmp_arr['postvalue'];
                    break;
                }
            }
            $AdvanceRelation = $this->getAdvanceRelations($fieldname);
            if(is_array($AdvanceRelation) && isset($AdvanceRelation[$prevalue]) && isset($AdvanceRelation[$prevalue][$postvalue])){
                $advanceid = $AdvanceRelation[$prevalue][$postvalue]['advanceid'];
            }else{
                return array();
            }

            $next_advanceid = $advanceid;
        }else{
            $AdvanceRelation = $this->getAdvanceRelationsByuser($record);//当前阶段与其他阶段的推进关系
            if(!empty($_REQUEST['advanceid'])&&$_REQUEST['advanceid']>0){
                $next_advanceid = $_REQUEST['advanceid'];
            }else{
                $next_advanceid = $this->getLastUpdateAdvanceid($record);
                if(empty($next_advanceid)|| !array_key_exists($next_advanceid,$AdvanceRelation)){
                    reset($AdvanceRelation);
                    $next_advanceid = key($AdvanceRelation);
                }
            }
            
            $AdvanceRelation_mobile = array();
            foreach($AdvanceRelation as $advanceid=>$relation){
                $tmp_relation['advanceid'] = $advanceid;
                $tmp_relation['stagename_target'] = $relation['stagename_target'];
                if($next_advanceid == $advanceid){
                    $tmp_relation['selected'] = 'yes';
                }else{
                    $tmp_relation['selected'] = 'no';
                }
                $tmp_relation['advanceid'] = $advanceid;
                $AdvanceRelation_mobile[] = $tmp_relation;
            }
            $return_result['AdvanceRelation'] = $AdvanceRelation_mobile;
        }
        
        //获取任务和日志信息
        $all_taskinfo_arr = $all_taskinfo_arr[$next_advanceid];
        $tasklog_arr = $all_tasklog_arr[$next_advanceid];
        //根据创建单据任务的设置，判断是否需要额外读取关联单据信息
        $tasklog_arr = $this->addAllModuletasklog($all_taskinfo_arr['taskvalue'],$tasklog_arr,$record);

        //获取必填字段信息
        $fieldname_arr = array();
        $change_column_fields = [];
        foreach($all_taskinfo_arr['taskvalue'] as $key => $tmp_taskinfo_arr){
            $tmp_type = $tmp_taskinfo_arr['type'];
            $fieldname = $tmp_taskinfo_arr['tasklabel'];
            $effect_range = $tmp_taskinfo_arr['effect_range'];
            $taskid = $tmp_taskinfo_arr['taskid'];

            if($tmp_type == 'field'&&!empty($tmp_taskinfo_arr['tasklabel'])){
                $fieldname_arr[] = $tmp_taskinfo_arr['tasklabel'];
                if($this->showtype == 'detail' && $effect_range == 'get_history'){
                    if(isset($tasklog_arr[$taskid])){
                        $change_column_fields[$fieldname] = $tasklog_arr[$taskid]['taskresult'];
                    }
                }
            }
        }
        if(sizeof($fieldname_arr)>0){
            $mobj = cls_Instance::get_moduleAction_Instance($this->module,'DetailView');
            $mobj->focus->retrieve_entity_info($record,$this->module);
            //用新的推进阶段值判断布局规则
            $mobj->focus->column_fields[$this->moduleadvance['module_field']] = $all_taskinfo_arr['stagename_target'];
            $mobj->focus = $this->setColumnValuesFromRequest($mobj->focus);
            //根据历史数据显示字段值
            $col_fields = $mobj->focus->column_fields;
            if(is_array($change_column_fields) && count($change_column_fields)>0){
                foreach ($change_column_fields as $tmp_fieldname=>$tmp_value){
                    $col_fields[$tmp_fieldname] = $tmp_value;
                }
            }

            $act_data = $mobj->getBlockFields($this->module,'edit_view','edit',$col_fields);


            $selected_fieldinfo_arr = array();
            $fieldname_info_arr = array();

            //推进必填字段增加布局规则判断
            if($this->usefieldrule == 'yes'){
                $fieldrulecolsproperty = $this->getFieldRuleColumn($mobj->focus,$col_fields);
                $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏字段
                //$displaycolumns=$fieldrulecolsproperty['displaycolumns'];//不是快速创建的字段，但是符合布局规则的要求
                //$requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
                $alltriggercolumn=$fieldrulecolsproperty['alltriggercolumn'];//获取所有的触发字段
            }
            $withfieldrule = 'no';
            //获取推进字段中设置了布局规则的字段
            $trigger_fieldname_arr = [];
            foreach ($fieldname_arr as $tmp_fieldname){
                if(in_array($tmp_fieldname,$alltriggercolumn)){
                    $withfieldrule = 'yes';
                    if(!in_array($tmp_fieldname,$trigger_fieldname_arr)){
                        $trigger_fieldname_arr[] = $tmp_fieldname;
                    }
                }
            }

            $return_result['fieldrulelist'] = $trigger_fieldname_arr;
            $return_result['columnfields_value'] = $col_fields;
            $return_result['modulelabel'] = getTranstab($this->module);
            $history_filejsondata = '';
            foreach($act_data as $block_key => $blockinfo){
                $tmp_fieldinfo_arr = $blockinfo['fieldinfo'];
                foreach($tmp_fieldinfo_arr as $field_key => $fieldinfo){
                    $tmp_fieldname = $fieldinfo['fieldname'];
                    if(!in_array($tmp_fieldname,$fieldname_arr) || (is_array($hidecolumns) && in_array($tmp_fieldname,$hidecolumns))){
                        continue;
                    }
                    if($this->showtype == 'detail'){
                        $fieldinfo['readonly'] = 'yes';
                        //duan 20241227移动端修改附件返回值
                        if($fieldinfo['bigtype']=='fileattachment' && array_key_exists($tmp_fieldname,$change_column_fields)){
                            if(!is_array($history_filejsondata)){
                                crm_load_class_file('AttachmentUtils','modules/Attachment');
                                $AttachmentUtilsObj = new AttachmentUtils();
                                $history_filejsondata = $AttachmentUtilsObj->getAttachmentImgHistory($record);
                            }
                            $fileid_str = $col_fields[$tmp_fieldname];
                            if(!empty($fileid_str)){
                                $fileid_arr = explode(',',$fileid_str);
                                $tmp_fieldvalue_arr = [];
                                foreach ($fileid_arr as $tmp_fileid){
                                    if(isset($history_filejsondata[$tmp_fileid])){
                                        $tmp_fileinfo = $history_filejsondata[$tmp_fileid];
                                        $tmp_fileinfo['ext'] = cls_StaticCommonFun::getExtName($tmp_fileinfo['name']);
                                        if($tmp_fileinfo['storage_location']=='cos')
                                        {
                                            $httppath=$tmp_fileinfo['cloud_path'];
                                        }
                                        else
                                        {
                                            $httppath=$tmp_fileinfo['path'].$tmp_fileinfo['newfile_name'];
                                        }
                                        $tmp_fileinfo['httppath'] = $httppath;
                                        $tmp_fieldvalue_arr[] = $tmp_fileinfo;
                                    }
                                }
                            }else{
                                $tmp_fieldvalue_arr = '';
                            }

                            $fieldinfo['text'] = $tmp_fieldvalue_arr;
                            $fieldinfo['value'] = $tmp_fieldvalue_arr;
                            $fieldinfo['uploadAttList'] = $tmp_fieldvalue_arr;
                        }
                    }
                    $selected_fieldinfo_arr[] = $fieldinfo;
                    $fieldname_info_arr[$tmp_fieldname] = $fieldinfo;
                }
            }
            if($this->showtype != 'detail'){
                $return_result['fieldinfo'] = $selected_fieldinfo_arr;
            }
        }
        $result_taskinfo_arr = array();
        
        $taskcount = 0;
        foreach($all_taskinfo_arr['taskvalue'] as $key=>$tmp_taskinfo_arr){
            $tmp_taskid = $tmp_taskinfo_arr['taskid'];
            $tmp_type = $tmp_taskinfo_arr['type'];
            $effective = 'yes';
            if(empty($tmp_taskinfo_arr['tasklabel'])){//未设置完整的任务无效
                $effective = 'no';
                break;
            }
            if($tmp_type=='select'&&sizeof($tmp_taskinfo_arr['selectinfo'])==0){//未设置完整的任务无效
                $effective = 'no';
                break;
            }
            $tmp_tasklog_arr = $tasklog_arr[$tmp_taskid];
            $taskinfo = array();
            $taskinfo['type'] = $tmp_type;
            $taskinfo['taskid'] = $tmp_taskid;
            $taskinfo['completerequest'] = $tmp_taskinfo_arr['completerequest'];
            $taskinfo['show'] = 'yes';
            //$taskinfo['showcreate'] = ($tmp_taskinfo_arr['effect_range']=='sum'?'yes':'no');
            $taskinfo['showcreate'] = 'yes';
            if($this->showtype == 'detail'){
                $taskinfo['allow_edit'] = 'no';
            }
            if($tmp_type == 'validata'){
                continue;
            }
            //显示区分任务类型
            $taskinfo['showlabel'] = getFixedLabel('TASK').'->';
            switch($tmp_type){
                case 'module':
                    $taskinfo['showlabel'] .= getFixedLabel('CREATERECORD');
                    break;
                case 'field':
                    $taskinfo['showlabel'] .= getFixedLabel('MANDATORYFIELDS');
                    break;
                case 'select':
                    $taskinfo['showlabel'] .= getFixedLabel('SELECTTYPE');
                    break;
                case 'checkbox':
                    $taskinfo['showlabel'] .= getFixedLabel('CHECKTYPE');
                    break;
                default:
                    break;
            }
            //任务完成和未完成的内容不同
            if($tmp_tasklog_arr['effective'] =='yes'){//任务完成时 
                if($tmp_type=='module'){//单据模块特殊处理
                    $taskinfo['entityname'] = $tmp_tasklog_arr['record_no'];
                    $taskinfo['moduletrans'] = getTranstab($tmp_taskinfo_arr['tasklabel']);
                    $taskinfo['record'] = $tmp_tasklog_arr['taskresult'];
                    $taskinfo['modulename'] = $tmp_taskinfo_arr['tasklabel'];
                    $taskinfo['record_no_arr'] = $tmp_tasklog_arr['record_no_arr'];
                    $related_tabid = getTabid($tmp_taskinfo_arr['tasklabel']);
                    $relation_info = getRelatedListInfoByTabid($this->tabid,$related_tabid);
                    $taskinfo['related_id'] = $relation_info['relationId'];
                }else if($tmp_type=='field'){
                    $fieldname = $tmp_taskinfo_arr['tasklabel'];
                    $taskinfo['fieldname'] = $fieldname;
                    if(empty($fieldname_info_arr[$fieldname])){
                        $taskinfo['show'] = 'no';
                        $taskinfo['showlabel'] = getFixedLabel('NOTENABLEORNOPERMIT');
                    }else{
                        $taskinfo['fieldinfo'] = $fieldname_info_arr[$fieldname];
                    }

                    $taskinfo['answer'] = "";
                }else{
                    $taskinfo['question'] = $tmp_taskinfo_arr['tasklabel'];
                    $taskinfo['answer'] = $tmp_tasklog_arr['taskresult'];
                }
            }else{
                if($tmp_type=='module'){//单据模块特殊处理
                    $taskinfo['moduletrans'] = getTranstab($tmp_taskinfo_arr['tasklabel']);
                    $taskinfo['modulename'] = $tmp_taskinfo_arr['tasklabel'];
                    $related_tabid = getTabid($tmp_taskinfo_arr['tasklabel']);
                    $relation_info = getRelatedListInfoByTabid($this->tabid,$related_tabid);
                    $taskinfo['related_id'] = $relation_info['relationId'];
                    $taskinfo['record'] = "";
                    $taskinfo['showcreate'] = 'yes';
                }else if($tmp_type=='field'){
                    $fieldname = $tmp_taskinfo_arr['tasklabel'];
                    $taskinfo['fieldname'] = $fieldname;
                    if(empty($fieldname_info_arr[$fieldname])){
                        $taskinfo['show'] = 'no';
                        $taskinfo['showlabel'] = getFixedLabel('NOTENABLEORNOPERMIT');
                    }else{
                        $taskinfo['fieldinfo'] = $fieldname_info_arr[$fieldname];
                    }
                    
                    $taskinfo['answer'] = "";
                }else{
                    $taskinfo['question'] = $tmp_taskinfo_arr['tasklabel'];
                    $taskinfo['answer'] = "";
                }
            }
            if($tmp_type=='select'){//下拉框类型增加option
                $taskinfo['option'] = $tmp_taskinfo_arr['selectinfo'];
            }
            if($taskinfo['show'] == 'yes'){
                $result_taskinfo_arr[] = $taskinfo;
            }
        }

        $return_result['taskinfo'] = $result_taskinfo_arr;
        return $return_result;
    }
    
    //duan 20220512 获取各个推进状态之间的关系
    public function getAdvanceRelations($fieldname){
        global $adb;
        if(isset($this->AdvanceRelation_arr)){
            return $this->AdvanceRelation_arr;
        }

        $AdvanceRelation_arr = array();
        $picklistvalue = $this->getAdvanceStageValues();
        $sql = "SELECT ld_advancepicklist.advanceid,stagename,stagename_target,presence,
			( CASE 
    			WHEN profileid != '' && profileid IS NOT NULL then 'yes'
    			WHEN userid != '' && userid IS NOT NULL then 'yes'
    			WHEN userfieldid != '' && userfieldid IS NOT NULL then 'yes'
    			WHEN tmp.advanceid != '' && tmp.advanceid IS NOT NULL then 'yes'
    			ELSE 'no' END )AS hascontent
             from ld_advancepicklist 
             LEFT JOIN (SELECT DISTINCT advanceid from ld_advancepicklisttask where IFNULL(tasklabel,'')!='' ) as tmp 
             on ld_advancepicklist.advanceid = tmp.advanceid 
             where tabid = ? and fieldname = ? order by advanceid desc";
        $result = $adb->pquery($sql,array($this->tabid,$fieldname));

        $stagename_target_arr = array();
        $num_rows = $adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $advanceid = $adb->query_result($result,$i,'advanceid');
            $stagename = $adb->query_result($result,$i,'stagename');
            $stagename = html_entity_decode($stagename);
            $stagename_target = $adb->query_result($result,$i,'stagename_target');
            $stagename_target = $stagename_target ?? '';
            $stagename_target = html_entity_decode($stagename_target);
            $presence = $adb->query_result($result,$i,'presence');
            if(is_array($stagename_target_arr[$stagename]) && in_array($stagename_target,$stagename_target_arr[$stagename])){
                continue;
            }else{
                $stagename_target_arr[$stagename][] = $stagename_target;
            }
            $tmp_arr = array('advanceid'=>$advanceid,'presence'=>$presence);
            //要求根据是否设置过任务或权限来显示不同的图标
            //wym XUQIU1002497 多分支PC端设置界面优化
            $hascontent = $adb->query_result($result,$i,'hascontent');
            if($hascontent == 'yes'){
                $tmp_arr['classname'] = 'icon-wrenchhand';
            }else{
                $tmp_arr['classname'] = 'icon-emptywrenchhand';
            }
            
            if(!empty($stagename)&& in_array($stagename,$picklistvalue) &&!empty($stagename_target)&& in_array($stagename_target,$picklistvalue)){
                $AdvanceRelation_arr[$stagename][$stagename_target] = $tmp_arr;
            }
        }
        $this->AdvanceRelation_arr = $AdvanceRelation_arr;
        return $AdvanceRelation_arr;
    }
    
    //当前阶段与其他阶段的推进关系
    public function getAdvanceRelationsByuser($record){
	    if($this->moduleadvance['method'] != 'field' || empty($this->moduleadvance['module_field'])){
	        return [];
        }
        //追踪字段未启用则判定未启用任务
        $fieldname = $this->moduleadvance['module_field'];
        $field = $this->modulefields[$fieldname];
        if(!$field)
            return [];
        if(is_array($this->AdvanceRelationByuser_arr)&&sizeof($this->AdvanceRelationByuser_arr)>0){
            return $this->AdvanceRelationByuser_arr;
        }
        global $adb,$global_pick_list_depencyfield;
        $stagename_now = $this->getStagenameNow($record);//获取 当前阶段
        //获取级联字段设置
        $columnForDependencyPicklist = $this->getColumnForDependencyPicklist($record);
        //$picklistvalue = $this->getAdvanceStageValues();
        $picklistvalue = $this->getProcessStageValue($record);
        //判断当前阶段是否在已有的阶段中，如果没有，则默认允许推进到第一阶段
        if(empty($stagename_now) || !in_array($stagename_now,$picklistvalue)){
            //BUG0076315 hzx 当自动化进度设置的追踪值为空的时候，界面显示异常
            //BUG20240712-16 duan 当前追踪值不在分支中时，允许流转到多个下级阶段
            $premit_node_info = $this->processobj->getPermitNodeinfo($record,$stagename_now);
            $stage_arr = $this->processobj->getfirststage($premit_node_info);
            if(is_array($stage_arr) && count($stage_arr)>0){
                $tmp_index = -1;
                foreach ($stage_arr as $tmp_stage){
                    $tmp_relation = ['stagename'=>$stagename_now,'stagename_target'=>$tmp_stage];
                    $AdvanceRelationByuser_arr[$tmp_index] = $tmp_relation;
                    $tmp_index --;
                }
            }else{
                $AdvanceRelationByuser_arr[-1]['stagename_target'] = $picklistvalue[0];
                $AdvanceRelationByuser_arr[-1]['stagename'] = $stagename_now;
            }

            return $AdvanceRelationByuser_arr;
        }
        //设置自定义排序
        $new_arr = [];
        $new_arr[] = "''";
        foreach ($picklistvalue as $tmp_value){
            $new_arr[] = "'".$tmp_value."'";
        }
        $sort_str = implode(',',$new_arr);
        // wym XUQIU20240204-09 销售线索可编辑追踪字段
        $sql = "SELECT ld_advancepicklist.advanceid,ld_advancepicklist.profileid,
    			 ld_advancepicklist.userid,ld_advancepicklist.userfieldid,
    			 ld_advancepicklist.stagename_target,
                 ld_advancepicklist.autopush,
                 ld_picklist_values.map_module
                from ld_settings_advance 
                INNER JOIN ld_advancepicklist on ld_advancepicklist.tabid = ld_settings_advance.tabid and ld_advancepicklist.fieldname = ld_settings_advance.module_field
                INNER JOIN ld_picklist_set  on ld_picklist_set.listname = ld_advancepicklist.fieldname
                INNER JOIN ld_picklist_values  on ld_picklist_set.listid = ld_picklist_values.listid 
                		and ld_picklist_values.listvalue = ld_advancepicklist.stagename_target
                where ld_advancepicklist.tabid = ? AND ld_advancepicklist.stagename = ?
                AND ld_advancepicklist.stagename_target is NOT NULL AND ld_advancepicklist.presence = 'yes'
                ORDER BY field(ld_picklist_values.listvalue,$sort_str) asc,advanceid desc ;";
        $result = $adb->pquery($sql,array($this->tabid,$stagename_now));
        $num_rows = $adb->num_rows($result);
        $AdvanceRelationByuser_arr = array();
        $stagename_target_arr = array();
        for($i=0;$i<$num_rows;$i++){
            $advanceid = $adb->query_result($result,$i,'advanceid');
            $profileid = $adb->query_result($result,$i,'profileid');
            $userid = $adb->query_result($result,$i,'userid');
            $userfieldid = $adb->query_result($result,$i,'userfieldid');
            $stagename_target = $adb->query_result($result,$i,'stagename_target');
            $map_module = $adb->query_result($result,$i,'map_module');
            $stagename_target = html_entity_decode($stagename_target);
            //如果目标阶段不在当前的级联范围内，则不可推进
            /*
            if(!empty($columnForDependencyPicklist)&&!in_array($stagename_target,$columnForDependencyPicklist)){
                continue;
            }*/
            if(!empty($picklistvalue)&&!in_array($stagename_target,$picklistvalue)){
                continue;
            }
            if(in_array($stagename_target,$stagename_target_arr)){
                continue;
            }else{
                $stagename_target_arr[] = $stagename_target;
            }
            //判断当前用户是否有推进权限
            
            $permit = $this->getPermissionByuser('',$profileid,$userid,$userfieldid,$record);
            if($permit == 'yes'){
                $AdvanceRelationByuser_arr[$advanceid]['stagename_target'] = $stagename_target;
                $AdvanceRelationByuser_arr[$advanceid]['map_module'] = $map_module;
                if($this->advance_type != 'weixin'){
                    $autopush = $adb->query_result($result,$i,'autopush');
                    $AdvanceRelationByuser_arr[$advanceid]['stagename'] = $stagename_now;
                    $AdvanceRelationByuser_arr[$advanceid]['autopush'] = $autopush;
                }
            }
        }
        $this->AdvanceRelationByuser_arr = $AdvanceRelationByuser_arr;
        
        return $AdvanceRelationByuser_arr;
    }
    
    //判断当前用户是否有推进权限
    public function getPermissionByuser($advacneid,$profileid,$userid,$userfieldid,$record){
        global $adb,$current_user;
        //如果advanceid不为空，则重新获取权限，角色，以及用户字段id
        if(!empty($advacneid)){
            $sql = "SELECT userid,profileid,userfieldid from ld_advancepicklist where advanceid = ?;";
            $result = $adb->pquery($sql,array($advacneid));
            if($adb->num_rows($result)>0){
                $profileid = $adb->query_result($result,0,'profileid');
                $userid = $adb->query_result($result,0,'userid');
                $userfieldid = $adb->query_result($result,0,'userfieldid');
            }else{
                return 'no';
            }
        }
        $tmp_userid_arr = array();
        
         //指定用户
        if(!empty($userid)){
            $tmp_userid_arr = array_merge($tmp_userid_arr,explode(',',$userid));
            $tmp_userid_arr = array_unique($tmp_userid_arr);
            if(sizeof($tmp_userid_arr)>0&&in_array($current_user->id,$tmp_userid_arr))
                return 'yes';
        }
        //指定角色
        if(!empty($profileid)){
            $tmp_userid_arr=[];
            $profile = new Profile();
            $profileid_array=explode(",",$profileid);
            foreach($profileid_array as $tmp_profileid)
            {
                $roleUserArr = $profile->getProfileOfUsers($tmp_profileid);
                if(!empty($roleUserArr))
                    $tmp_userid_arr = array_merge($tmp_userid_arr,array_keys($roleUserArr));
                //先这样优化吧，可以通过currenct_user->profileid判断
                if(sizeof($tmp_userid_arr)>0&&in_array($current_user->id,$tmp_userid_arr))
                        return 'yes';
            }
            $tmp_userid_arr = array_unique($tmp_userid_arr);
        }
        
        //用户字段
        if(!empty($userfieldid)){
            $userfieldid_arr = explode(',',$userfieldid);
			$focus=CRMEntity::getInstance($this->module);
			$fieldobj=Field::getInstance($this->module,$adb);
            $table_arr=[];
            //可以修改为一个sql
            $table_arr = [];
			foreach($userfieldid_arr as $tmp_fieldid){
                $profieldobj=$fieldobj->FieldInfoListByKeyValue('fieldid',$tmp_fieldid);
    			$columnname_arr[] = $profieldobj['columnname'];
                if(!in_array($profieldobj['tablename'],$table_arr)){
                    $table_arr[] = $profieldobj['tablename'];
                }
			}
            if(is_array($columnname_arr) && sizeof($columnname_arr)>0){
                $base_table = $focus->table_name;
                $base_index = $focus->table_index;
                if(sizeof($table_arr)==1){
                    $table_sql = $table_arr[0];
                    $index_name = $base_index;
                }else{
                    $scf_table = $focus->customFieldTable[0];
                    $scf_index = $focus->customFieldTable[1];
                    $table_sql = " $base_table inner join $scf_table on $base_table.$base_index = $scf_table.$scf_index ";
                    $index_name = $base_table.'.'.$base_index;
                }
                
                $sql='select '.implode(',',$columnname_arr). ' from '.$table_sql.' where '.$index_name.'=? limit 1';
    			$result=$adb->pquery($sql,array($record));
                if($adb->num_rows($result)>0){
                    foreach($columnname_arr as $tmp_columnname){
                        $tmp_userid=$adb->query_result($result,0,$tmp_columnname);
                        $tmp_userid_arr = array_merge($tmp_userid_arr,explode(',',(string)$tmp_userid));
                    }
                }
                if(sizeof($tmp_userid_arr)>0&&in_array($current_user->id,$tmp_userid_arr)){
                    return 'yes';
                }
            }
            $tmp_userid_arr = array_unique($tmp_userid_arr);
        }
        //如果当前用户不属于设置的用户，则没有当前阶段的推进权限
        //如果设置的角色权限没有存在的用户或用户字段没有值，当前用户也不应该有推进权限
        if(sizeof($tmp_userid_arr)>0 || !empty($profileid) || !empty($userfieldid)){
            return 'no';
        }else{//如果推进关系中的权限设置为空，则根据‘推进’角色权限获取
            $is_permit = isPermitted($this->module,'Advance');
            return $is_permit;
        }
    }
    //获取必填字段编辑显示html 
    public function getEditviewFieldHtml($taskinfo_arr,$record,$task_allowedit,$stagename_target,$tasklog_arr){
        global $current_user,$adb;
        $smarty=new lingdangCRM_Smarty;
        
        //非管理员  控制只读字段不在模块的新增和编辑时显示
    	if($current_user->is_admin=='off'){
    		$profileobj=Profile::getInstance();
    		$profilefields= $profileobj->getProfileInfos($current_user->profileid);
    		$profilefields=$profilefields['field'];
    	}
        
        $get_entity = 'no';//判断focus是否已经获取过字段值
        $get_contact_entity = 'no';
        $filejsondata = '';
        $history_filejsondata = '';
        //循环找出必填字段类型
        $this->advance_trigger_column = [];
        //显示日志要根据历史值
        $change_column_fields = [];
        if($task_allowedit == 'no'){
            foreach($taskinfo_arr['taskvalue'] as $key => $tmp_taskinfo_arr){
                if($tmp_taskinfo_arr['type'] == 'field'){
                    $fieldname = $tmp_taskinfo_arr['tasklabel'];
                    $effect_range = $tmp_taskinfo_arr['effect_range'];
                    $taskid = $tmp_taskinfo_arr['taskid'];

                    if($effect_range == 'get_history' ){
                        if(isset($tasklog_arr[$taskid])){
                            $change_column_fields[$fieldname] = $tasklog_arr[$taskid]['taskresult'];
                        }
                    }
                }
            }
        }

        foreach($taskinfo_arr['taskvalue'] as $key => $tmp_taskinfo_arr){
            if($tmp_taskinfo_arr['type'] == 'field'){
                //避免重复调用retrieve_entity_info方法
                $this->fieldtask_num++;
                $fieldname = $tmp_taskinfo_arr['tasklabel'];
                $effect_range = $tmp_taskinfo_arr['effect_range'];
                $taskid = $tmp_taskinfo_arr['taskid'];
                if($get_entity == 'no'){
                    
                    $get_entity = 'yes';
                    $focus = $this->focus;
                    $focus->id = $record;
                    $focus->retrieve_entity_info($record,$this->module);
                    $focus = $this->setColumnValuesFromRequest($focus);
                    if(!empty($stagename_target)){
                        $stage_fieldname = $this->moduleadvance['module_field'];//追踪字段名称
                        $focus->column_fields[$stage_fieldname] = $stagename_target;
                    }

                    $col_fields = $focus->column_fields;
                    if(is_array($change_column_fields) && count($change_column_fields)>0){
                        foreach ($change_column_fields as $tmp_fieldname=>$tmp_value){
                            $col_fields[$tmp_fieldname] = $tmp_value;
                        }
                    }

                    $sourcemodules=getSourceModule($this->module);
                    $smarty->assign('SOURCEMODULE',$sourcemodules);
                    $smarty->assign("CURRENT_USERID", $current_user->id);
                    $smarty->assign('ISADMIN',$current_user->is_admin);
                    $smarty->assign('ID', $record);
                    $smarty->assign('MODE','edit');
                    $smarty->assign('MODULE',$this->module);
                    $version_info = getVersionInfo();
                    $smarty->assign('VERSIONTRADE',$version_info['trade']);
                    $smarty->assign('VERSIONACCOUNT',$version_info['account']);
                    $smarty->assign('VERSION_ACCOUNT',$version_info['account']);
                    $smarty->assign("THEME", $theme);
                    //币种
                    $smarty->assign('CURRENCYID',$col_fields['currency_id']);
                    $smarty->assign('CONVERSIONRATE', $col_fields['conversion_rate']);
                    $smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
                    $smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

                    $isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$this->module);
                    $smarty->assign('ISALLOW',$isallow);
                    //推进必填字段增加布局规则判断
                    if($this->usefieldrule == 'yes'){
                        $fieldrulecolsproperty = $this->getFieldRuleColumn($this->focus,$col_fields);
                        $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏字段
                        //$displaycolumns=$fieldrulecolsproperty['displaycolumns'];//不是快速创建的字段，但是符合布局规则的要求
                        $requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
                        $alltriggercolumn=$fieldrulecolsproperty['alltriggercolumn'];//获取所有的触发字段
                    }
                }

                //模块对应的$smarty传值
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);

                //字段未启用或缺少该字段的查看权限
                if(empty($fieldinfo)){
                    $taskinfo_arr['taskvalue'][$key]['content'] = "<td colspan='2'><span>".getFixedLabel('NOTENABLEORNOPERMIT')." </span></td>";
                    continue;
                }
                cls_module_advance::setSmartyassignBymodule($smarty,$this->module,$fieldname);

                $columnname = $fieldinfo->getColumnName();
                $taskinfo_arr['taskvalue'][$key]['show'] = 'yes';
                if(is_array($hidecolumns) && in_array($columnname,$hidecolumns)){
                    $taskinfo_arr['taskvalue'][$key]['show'] = 'no';
                    continue;
                }
                
                $fieldid = $fieldinfo->getFieldid();
                //编辑时只读的字段在编辑时，显示但不可编辑，
        		 if( !empty($profilefields) && ($profilefields[$fieldid]['editreadonly']==1 ||$profilefields[$fieldid]['readonly'] )){
        			$fieldinfo->set_allowedit('no');
        		 }
        		 $tablename = $fieldinfo->getTableName();
                $typeofdata = $fieldinfo->getTypeOfData();
                $fields_arr=array('uitype'=>$fieldinfo->getUIType(),'fieldlabel'=>$fieldinfo->getFieldLabel(),'allowedit'=>$fieldinfo->get_allowedit()
                        ,'fieldname'=>$fieldinfo->getFieldName(),'columnname'=>$fieldinfo->getColumnName(),'fieldonly'=>$fieldinfo->getfieldOnly()
                        ,'displaytype'=>$fieldinfo->getDisplaytype(),'tablename'=>$fieldinfo->getTableName(),'bigtype'=>$fieldinfo->getBigType(),
                        'fieldvaluecolor'=>$fieldinfo->getFieldValueColor(),'fieldplaceholder'=>$fieldinfo->getFieldPlaceholder(),
                        'editpage'=>$fieldinfo->getEditpage(),'savedatabase'=>$fieldinfo->getSaveDataBase(),'typeofdata'=>$typeofdata);
                if(!in_array($fieldname,$this->advancefieldname_arr) &&  $task_allowedit == 'yes'){
                    if(is_array($requiredcolumns) && in_array($columnname,$requiredcolumns)){
                        $typeofdata_arr = explode('~',$typeofdata);
                        $typeofdata_arr[1] = 'M';
                        $fields_arr['typeofdata'] = implode('~',$typeofdata_arr);
                        $taskinfo_arr['taskvalue'][$key]['completerequest'] = 'yes';
                    }

                    $this->advancetaskfield_arr[]=$fields_arr;
                    $this->advancefieldname_arr[] = $fieldname;

                    //获取布局规则的触发字段
                    if(is_array($alltriggercolumn) && in_array($fieldname,$alltriggercolumn)){
                        $this->triggerfieldname_arr[] = $fieldname;
                        $this->triggerfieldvalue_arr[$fieldname] = $col_fields[$fieldname];
                    }
                }
                if($this->module == 'Accounts' && in_array($tablename,['ld_contactdetails','ld_contactscf']) && $get_contact_entity == 'no'){
                    $get_contact_entity = 'yes';
                    $focus = $this->getContactInfo($focus);
                    $smarty->assign("CONTACTID",$col_fields["contactid"]);
                }
                
                $uitype=$fieldinfo->getUIType();
                $fieldonly=$fieldinfo->getfieldOnly();
                $fieldvaluecolor = $fieldinfo->getFieldValueColor();//文字颜色
                $fieldplaceholder = $fieldinfo->getFieldPlaceholder();
                $allowedit = $fieldinfo->allowedit;//是否允许编辑
                $allowedit = 'no';
                
                $columnname=$fieldinfo->getColumnName();
                $maxlength = $fieldinfo->getMaximumLength();
                $generatedtype = $fieldinfo->getGeneratedtype();
                $typeofdata = $fieldinfo->getTypeOfData();
                $defaultvalue =$fieldinfo->getDefaultValue();
                $bigtype=$fieldinfo->getBigType();
                $focusmode = 'edit';

                if($bigtype == 'fileattachment' ){
                    if(!is_array($filejsondata)){
                        $this->withattachment = 'yes';
                        crm_load_class_file('AttachmentUtils','modules/Attachment');
                        $AttachmentUtilsObj = new AttachmentUtils();
                        $filejsondata= $AttachmentUtilsObj->getAllFile_imageInfo($record,$this->module);
                    }
                    if($effect_range == 'get_history' && !is_array($history_filejsondata)){
                        $history_filejsondata = $AttachmentUtilsObj->getAttachmentImgHistory($record);
                    }
                }
                
                if(empty($obj_cls)){
                    crm_load_class_file('cls_EditView_OutPut','include/utils');
                    $obj_cls = new cls_EditView_OutPut();
                    if(isset($advfilter_arr)&&!empty($advfilter_arr)){
                        $obj_cls->setAdvFilter($advfilter_arr);
                    }
                }

                $custfld = $obj_cls->getEditViewOutputHtml($fieldinfo, $maxlength, $col_fields,$generatedtype,$this->module,$focusmode,$typeofdata,$fieldonly,$curapproveformodulefield);
                //查看推进详情界面不允许编辑
                if($task_allowedit == 'no'){
                    $custfld['allowedit'] = 'no';
                    $custfld['allowedit_presence'] = 'no'; 
                }
                
                //原字段必填不需要显示
                //$custfld[4] = 'o';
                //判断布局规则必填
                if(is_array($requiredcolumns) && in_array($columnname,$requiredcolumns)){
                    $custfld[4] = 'm';
                }
                //附件类型的字段只显示文件名称
                if($bigtype == 'fileattachment'&&$task_allowedit == 'no'){
                    $value = '';
                    $fileinfo = [];
                    if($effect_range == 'get_history' ){
                        $fileid_str = $col_fields[$fieldname];
                        if(!empty($fileid_str)){
                            $fileid_arr = explode(',',$fileid_str);
                            foreach ($fileid_arr as $tmp_fileid){
                                if(isset($history_filejsondata[$tmp_fileid])){
                                    $fileinfo[] = $AttachmentUtilsObj->getTransColumnValue($history_filejsondata[$tmp_fileid],'show');
                                }
                            }
                        }
                    }else{
                        $fileinfo = $filejsondata[$columnname];
                    }
                    foreach($fileinfo as $tmp_index=>$tmp_info){
                        if(empty($value)){
                            $value = $tmp_info['file_name'];
                        }else{
                            $value = $value."<br>".$tmp_info['file_name'];
                        }
                    }

                    $custfld[3][0] = $value;
                    $custfld[0][0][0] = 1;
                }
                if($task_allowedit == 'no'){
                    $custfld[5] = '';
                    $custfld[2][0] = '';
                }
                //获取td
                $smarty->assign('maindata',$custfld);
                $str = $smarty->fetch("DetailView/EditViewUI.tpl");
                //删除文本区域的<tr>
                if(strpos($str,'<tr>') !== false){
                    $str = str_replace('<tr>','',$str);
                }
                if(strpos($str,'</tr>') !== false){
                    $str = str_replace('</tr>','',$str);
                }
                $taskinfo_arr['taskvalue'][$key]['content'] = $str;
            }
            
        }
        return $taskinfo_arr;
    }
    
    //获取已通过阶段的任务信息详情（在推进详情界面显示，不可编辑）
    public function getAdvanceDetailTaksinfo($record,$stagename){
        //根据修改日志获取相关的推进关系
        global $adb;
        /*
        $sql = "SELECT ld_advancepicklist.advanceid,tmp.prevalue,tmp.postvalue from ld_advancepicklist INNER JOIN (
                    SELECT
                    	prevalue,postvalue
                    FROM
                    	ld_modtracker_basic
                    INNER JOIN ld_modtracker_detail ON ld_modtracker_basic.id = ld_modtracker_detail.id
                    WHERE ld_modtracker_basic.crmid = ? and ld_modtracker_detail.fieldname = ? AND prevalue = ?
                    ORDER BY ld_modtracker_basic.changedon desc limit 1) as tmp 
                    on ld_advancepicklist.stagename = tmp.prevalue and ld_advancepicklist.stagename_target = tmp.postvalue
                    where  ld_advancepicklist.fieldname = ?
                    order by ld_advancepicklist.advanceid desc limit 1";
        $result = $adb->pquery($sql,array($record,$this->moduleadvance['module_field'],$stagename,$this->moduleadvance['module_field']));

        if($adb->num_rows($result)>0){
            $advanceid = $adb->query_result($result,0,'advanceid');
            $prevalue = $adb->query_result($result,0,'prevalue');
            $postvalue = $adb->query_result($result,0,'postvalue');
        }else{
            return array();
        }

        */
        //edit:duan date:2024/12/16 reason:根据下拉框修改日志，转换历史选项的数据
        $fieldname = $this->moduleadvance['module_field'];
        $track_advance_data = $this->getAdvanceTrackData($record,$fieldname);
        //按修改时间进行降序排列
        usort($track_advance_data, function($a, $b) {
            return strtotime($b['changedon']) - strtotime($a['changedon']);
        });
        foreach ($track_advance_data as $tmp_arr){
            if($tmp_arr['prevalue'] == $stagename){
                $prevalue = $tmp_arr['prevalue'];
                $postvalue = $tmp_arr['postvalue'];
                break;
            }
        }
        $AdvanceRelation = $this->getAdvanceRelations($fieldname);
        if(is_array($AdvanceRelation) && isset($AdvanceRelation[$prevalue]) && isset($AdvanceRelation[$prevalue][$postvalue])){
            $advanceid = $AdvanceRelation[$prevalue][$postvalue]['advanceid'];
        }else{
            return array();
        }

        $all_taskinfo_arr = $this->getadvancetask();//所有的任务信息
        $all_tasklog_arr = $this->getallTasklogbyrecord($record);//任务完成日志
        $taskinfo_stagename = array();
        
        $taskinfo_arr = $all_taskinfo_arr[$advanceid];
        $tasklog_arr = $all_tasklog_arr[$advanceid];
        //根据创建单据任务的设置，判断是否需要额外读取关联单据信息
        $tasklog_arr = $this->addAllModuletasklog($taskinfo_arr['taskvalue'],$tasklog_arr,$record);

        //将必填字段任务类型中增加需要显示的html
        $taskinfo_arr = $this->getEditviewFieldHtml($taskinfo_arr,$record,'no','',$tasklog_arr);
         
        $task_num = sizeof((array)$taskinfo_arr['taskvalue']);
        
        
        $taskinfo_stagename['tasknum'] = $task_num;
        $taskinfo_stagename['stagename'] = $prevalue;
        $taskinfo_stagename['stagename_target'] = $postvalue;
        if($task_num>0){
            $taskinfo_stagename['tasklog'] = $tasklog_arr;
            $taskinfo_stagename['taskinfo'] = $taskinfo_arr;
            $taskinfo_stagename['allow_edit'] = 'no';
        }
        
        return $taskinfo_stagename;
    }
    //获取与当前阶段最近阶段的advanceid
    public function getLastUpdateAdvanceid($record){
        global $current_user,$adb;

        //默认选中当前阶段的下一个目标阶段
        $AdvanceRelation = $this->getAdvanceRelationsByuser($record);
        //$picklistvalue = $this->getAdvanceStageValues();
        $picklistvalue = $this->getProcessStageValue($record);
        $stagename_now = $this->getStagenameNow($record);
        if(is_array($picklistvalue) && sizeof($picklistvalue) >0){
            $sequence_arr = array();
            foreach($picklistvalue as $sequence => $listvalue){
                $sequence = $sequence ;
                $sequence_arr[$listvalue] = $sequence;
            }

            if(is_array($sequence_arr) && sizeof($sequence_arr)>0){
                $base_sequence = $sequence_arr[$stagename_now];   
                //小于当前阶段顺序的最大值
                $less_max_sequence = 0;
                $less_max_advanceid = 0;
                //大于当前阶段顺序的最小值
                $bigger_min_sequence = 0;
                $bigger_min_advanceid = 0;
                foreach($AdvanceRelation as $advanceid=>$tmp_relation ){
                    $sequence = $sequence_arr[$tmp_relation['stagename_target']];
                    if($sequence >$base_sequence){
                        if($bigger_min_sequence ==0 || $sequence<$bigger_min_sequence ){
                            $bigger_min_sequence = $sequence;
                            $bigger_min_advanceid = $advanceid;
                        }
                    }else{
                        if($less_max_sequence ==0 || $sequence>$less_max_sequence ){
                            $less_max_sequence = $sequence;
                            $less_max_advanceid = $advanceid;
                        }
                    }
                }
                if(!empty($bigger_min_advanceid)&&$bigger_min_advanceid>0){
                    return $bigger_min_advanceid;
                }else{
                    return $less_max_advanceid;
                }
            }
        }
        return 0;
    }
    
    public static function setSmartyassignBymodule($smarty,$module,$fieldname)
    {
        global $adb;
        $version_info = getVersionInfo();
        
        $focus = CRMEntity::getInstance($module);
        $fieldobj = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
        
        if($module == 'Users')
        {
            $authtype =  $focus->getAuthType();
            $smarty->assign('AUTHTYPE',$authtype);
            if($fieldname == 'userlevel')
            {
                //职位级别
                $level_show_user="";
                if(isset($_REQUEST['record']))
                {   
                    $sql = "select userlevel from ld_users where id=".$_REQUEST['record']."";
                    $result = $adb->pquery($sql,array());
                    $level_show_user = $adb->query_result($result,0);
                    $smarty->assign("level_show_user",$level_show_user);
                }
                if(is_admin($current_user)||isPermitted("Users", 'index','') == 'yes' ){
                    $smarty->assign("IS_ADMIN", true);
                }
            }
            else if($fieldobj->getUIType() == 15 && $fieldname == 'approvestatus')
            {
                //审批委托
                $approvestatus_show_user="";
                if(isset($_REQUEST['record']))
                {
                    $sql = "select approvestatus from ld_users where id=".$_REQUEST['record']."";
                    $result = $adb->pquery($sql,array());
                    $approvestatus_show_user = $adb->query_result($result,0);
                    $smarty->assign("approvestatus_show_user",$approvestatus_show_user);
                }
            }
            else if($fieldobj -> getUIType()== 11 && $fieldname == 'approveby')
            {
                //审批委托人
                $last_name="";
                $approvestatus_show_user="";
                if(isset($_REQUEST['record']))
                {
                    $sql = "select last_name,id from ld_users where id in (select approveby from ld_users where id=".$_REQUEST['record']." )";
                    $result = $adb->pquery($sql,array());
                    $num_rows = $adb->num_rows($result);
                    $last_name=array();
                    for($i=0;$i<$num_rows;$i++)
                    {
                    $last_name[]=array(
                            'last_name'=> $adb->query_result($result,$i,"last_name"),
                            'id'=>$adb->query_result($result,$i,"id")
                            );
                    }
                    $smarty->assign("last_name",$last_name);
                    $sql = "select approvestatus from ld_users where id=".$_REQUEST['record']."";
                    $result = $adb->pquery($sql,array());
                    $approvestatus_show_user = $adb->query_result($result,0);
                    $smarty->assign("approvestatus_show_user",$approvestatus_show_user);
                }
            }
            else if($fieldobj->getUIType()==56||$fieldobj->getUIType()==98)
            {
                $smarty->assign('USEREDIT','useredit');
                $smarty->assign("ALLSETROLEDATAPROFILE",isPermitted("Users","AllowSetRoleDataProfile"));
            }
            
            
        }
        else if($module == 'Accounts')//CALLPHONE？，
        {
            // if($fieldname == 'accountname')
            // {
            //     //工商查询
            //     crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            //     $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
            //     $smarty->assign('ACCOUNTBUSINESS',1);
            //     if($businessinformationobj->IsEnableBusiness()){
            //         $smarty->assign('ACCOUNTBUSINESS',0);
            //     }
            //     //工商查询列表
            //     $smarty->assign('ACCOUNTLISTBUS',1);
            //     if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            //         $smarty->assign('ACCOUNTLISTBUS',0);
            //     }
            // }
            
            
        }
        else if($module == 'BankAccountSet')
        {
            if($fieldobj->getUIType()==72||$fieldobj->getUIType()==117 )
            {
                if($_REQUEST['record']){
                    $sqlstus="select confirmed from ld_bankaccountset where bankaccountsetid=".$_REQUEST['record']; 
                    $reslutsturs = $adb->pquery($sqlstus);
                    $confirmedst = $adb->query_result($reslutsturs,0,'confirmed');
                }
                $smarty->assign("CONFIRMEDST", $confirmedst);
            }
        }
        else if($module == 'Contacts')
        {
            if($fieldobj->getUIType()==57)
            {
                //未发现传值位置
                
            }
        }
        else if($module == 'Products')
        {
            if($fieldobj->getUIType()== 72||$fieldobj->getUIType()==71)
            {
                if($fieldname == 'unit_price' || $fieldname == 'procostprice')
                {
                    $record = $_REQUEST['record'];
                    $focus->id = $record;
                    $focus->mode = 'edit';
                    $focus->retrieve_entity_info($record, $module);
                    crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
                	$currencyInfo = getInventoryCurrencyInfo($module,$focus->id);
                	$product_base_currency = $currencyInfo['currency_id'];
                    $productid = $focus->id;
                    
                    if($fieldname == 'unit_price')
                    {
                        //参考价 - 价格设定
                        $unit_price = $focus->column_fields['unit_price'];
                        $price_details = getPriceDetailsForProduct($productid, $unit_price, 'available',$module,'unit_price');
                        $smarty->assign("PRICE_DETAILS", $price_details);
                        $smarty->assign("PRICE_DETAILS_NUM", sizeOf($price_details));
                        $base_currency = 'unit_price_curname' . $product_base_currency;
                        $smarty->assign("BASE_CURRENCY", $base_currency);
                    }
                    if($fieldname == 'procostprice')
                    {
                        //参考成本价 - 价格设定
                        $procostprice = $focus->column_fields['procostprice'];
                        $price_details = getPriceDetailsForProduct($productid, $procostprice, 'available',$module,'procostprice');
                        $smarty->assign("PROCOSTPRICE_DETAILS", $price_details);
                        $smarty->assign("PROCOSTPRICE_DETAILS_NUM", sizeOf($price_details));
                        $base_currency = 'procostprice_curname' . $product_base_currency;
                        $smarty->assign("PROCOSTBASE_CURRENCY", $base_currency);
                    }
                    $sysdeploy_93 = getSys_deploy(93);	// 系统参数控制单价小数位
                    $smarty->assign('price_decimal',$sysdeploy_93['deploy_value']);
                    
                }
                
            }
        }
        else if($module == 'PurchaseCashBack')
        {
            if($fieldobj->getUIType()==801)
            {
                if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
                    $sql = "select a.purchasebackid,a.purchaseback_no,b.vendorname,b.vendorid from ld_purchaseback a,ld_vendor b,ld_purchasecashback c 
                    where a.vendorid = b.vendorid and c.purchaseback_id = a.purchasebackid and c.purchasecashbackid = ?";
                    $result=$adb->pquery($sql,array($_REQUEST['record']));
                    $smarty->assign("PURCHASEBACKID", $adb->query_result($result,0,"purchasebackid"));
                    $smarty->assign("PURCHASEBACKNO", $adb->query_result($result,0,"purchaseback_no"));
                }
            }
            else if($fieldobj->getUIType()==75||$fieldobj->getUIType()==81)
            {
                if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
                    $focus->id = $_REQUEST['record'];
                    $purchasebackid = $_REQUEST['record'];
                    $sql = "select purchaseorder_id from ld_purchaseback where purchasebackid = ?";
                    $result=$adb->pquery($sql,array($purchasebackid));
                    $purchaseorder_id = $adb->query_result($result,0,"purchaseorder_id");
                	$entityarray = getEntitynameInfo(getTabid('PurchaseOrder'));
                	$tabname = $entityarray['tablename'];
                	$tabindex = $entityarray['entityidfield'];
                	$tabfieldname = $entityarray['fieldname'];
                	$sql = "
                		select $tabfieldname as subject,ld_vendor.vendorname,ld_vendor.vendorid from ld_purchaseorder 
                		LEFT JOIN ld_vendor on ld_vendor.vendorid = ld_purchaseorder.vendorid 
                		LEFT JOIN ld_purchaseordercf on ld_purchaseordercf.purchaseorderid = ld_purchaseorder.purchaseorderid
                		where ld_purchaseorder.purchaseorderid = $purchaseorder_id";
                    $result=$adb->pquery($sql);
                    $smarty->assign("PURCHASEORDERID", $purchaseorder_id);
                    $smarty->assign("VENDORNAME", $adb->query_result($result,0,"vendorname"));
                    $smarty->assign("VENDORID", $adb->query_result($result,0,"vendorid"));
                }
            }
            
        }
        else if($module == 'PurchaseCashBack')
        {
            if($fieldobj->getUIType()==75||$fieldobj->getUIType()==81)
            {
                $focus->id = $_REQUEST['record'];
                $sql = "select a.purchasebackid,a.purchaseback_no,b.vendorname,b.vendorid from ld_purchaseback a,ld_vendor b,ld_purchasecashback c 
                where a.vendorid = b.vendorid and c.purchaseback_id = a.purchasebackid and c.purchasecashbackid = $focus->id";
                $result=$adb->pquery($sql);
                $smarty->assign("PURCHASEBACKID", $adb->query_result($result,0,"purchasebackid"));
                $smarty->assign("PURCHASEBACKNO", $adb->query_result($result,0,"purchaseback_no"));
                $smarty->assign("VENDORNAME", $adb->query_result($result,0,"vendorname"));
                $smarty->assign("VENDORID", $adb->query_result($result,0,"vendorid"));
            }
            
        }
        else if($module == 'Rate')
        {
            if($fieldobj->getUIType()==111)//小编辑不需要留作后续使用
            {
                $selectinfo = $focus->getRateSelect();
                $smarty->assign('SELECTTYPE',$selectinfo['selecttype']);
                $smarty->assign('SELECTVALUE',$selectinfo['selectvalue']);
            }
        }
        else if($module == 'ServiceCharge')
        {
            // if($fieldname == 'accountname')
            // {
            //     //工商查询
            //     crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            //     $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
            //     $smarty->assign('ACCOUNTBUSINESS',1);
            //     if($businessinformationobj->IsEnableBusiness()){
            //         $smarty->assign('ACCOUNTBUSINESS',0);
            //     }
            //     //工商查询列表
            //     $smarty->assign('ACCOUNTLISTBUS',1);
            //     if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            //         $smarty->assign('ACCOUNTLISTBUS',0);
            //     }
            // }
        }
        else if($module == 'Vendors')
        {
            // if($fieldname == 'vendorname')
            // {
            //     //工商查询
            //     crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            //     $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
            //     $smarty->assign('VENDORBUSINESS',1);
            //     if($businessinformationobj->IsEnableBusiness()){
            //         $smarty->assign('VENDORBUSINESS',0);
            //     }
            //     //工商查询列表
            //     $smarty->assign('VENDORLISTBUS',1);
            //     if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            //         $smarty->assign('VENDORLISTBUS',0);
            //     }
            // }
        }
    }
    
    public function Fieldlabelempty(){
        global $adb,$current_user;
        //确定中英文语言类型
        $languageType= getLanguageType($current_user);
        //查找当前跟踪字段是什么
        $query = "SELECT ld_tranlabel.fieldlabel from ld_field 
               INNER JOIN ld_settings_advance on ld_field.fieldname = ld_settings_advance.module_field and ld_field.tabid = ld_settings_advance.tabid
               INNER JOIN ld_tranlabel on ld_field.tabid = ld_tranlabel.tabid and ld_field.fieldid = ld_tranlabel.Relateid and trantable = 'ld_field'
               where ld_field.tabid =? and ld_tranlabel.languagetype = ? ";
        $result = $adb->pquery($query,array($this->tabid,$languageType));
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
           //提取当前跟踪字段
            $field_label = $adb->query_result($result,0,'fieldlabel');
        }
        if($languageType == 'zh'){
            $fieldlabel_isempty = $field_label.getFixedLabel('AdvanceValueIsEmpty');
        }else{
            $fieldlabel_isempty = $field_label.' '.getFixedLabel('AdvanceValueIsEmpty');
        }
        
        return $fieldlabel_isempty;
    }

    public function getContactInfo($focus){
        global $adb;
        $sqlcontact='select columnname,tablename,fieldname from ld_field where tabid=6 and tablename in(?,?) and presence in(0,2)';
        $resultcontact=$adb->pquery($sqlcontact,array('ld_contactdetails','ld_contactscf'));
        $contactcolumns=Array();
        $contactfieldnames=Array();
        for($i=0;$i<$adb->num_rows($resultcontact);$i++)
        {
            $contactcol=$adb->query_result($resultcontact,$i,'columnname');
            $tablename=$adb->query_result($resultcontact,$i,'tablename');
            $fieldname=$adb->query_result($resultcontact,$i,'fieldname');
            $contactfieldnames[]=$fieldname;
            $contactcolumns[]=$contactcol;

        }
        $columns=implode(',',$contactcolumns);
        $sqlcontact="select $columns,ld_contactdetails.contactid from ld_contactdetails 
              left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
              where accountid=? and reference=1 and ld_contactdetails.deleted=0 order by contact_no asc limit 0,1";
        $resultcontact=$adb->pquery($sqlcontact,array($focus->id));
        $contactfieldjsondata = array();
        if($adb->num_rows($resultcontact)>0)
        {
            for($i=0;$i<sizeof($contactfieldnames);$i++)
            {
                $focus->column_fields[$contactfieldnames[$i]]=$adb->query_result($resultcontact,0,$contactcolumns[$i]);
            }
            $contactid = $adb->query_result($resultcontact,0,'contactid');
            $focus->column_fields["contactid"]=$contactid;
            $contactfieldjsondata=getAllFile_imageInfo($contactid,'Contacts');
            foreach($contactfieldjsondata as $tmp_columname => $fileinfo){
                if($tmp_columname == 'filename'){
                    $new_columnname = $tmp_columname.'_mapping';
                    $contactfieldjsondata[$new_columnname] = $fileinfo;
                    unset($contactfieldjsondata[$tmp_columname]);
                }
            }
        }
        return $focus;
    }
    //获取详情页推进流程图信息
    public function getAdvanceProcessInfo($record,$advancedata,$alltaskinfo){
	    if($this->moduleadvance['method'] != 'field'){
	        return [];
        }
	    $firstinfo = [];
	    $value_type = 'normal';
        $show_btn = 'no';

        $smarty = new lingdangCRM_Smarty();
        $stagenamenow = $this->getStagenameNow($record);
        $premit_node_info = $this->processobj->getPermitNodeinfo($record,$stagenamenow);
        $advanceinfo_arr = $advancedata['advancestage_values'];

        $new_advanceinfo_arr = [];
        $advancetask_arr = [];
        $hiden_btn = $advancedata['hidebtn'];
        $operatestyle = $advancedata['moduleadvance']['operatestyle'];

        foreach ($alltaskinfo as $tmp_key => $tmp_info){
            if($tmp_key == '-1'){
                //-1表示当前阶段不在已选流程范围内，添加的默认推进关系
                $value_type = 'error';
                $firstinfo = $tmp_info;
                if($operatestyle == 'inpopup'){
                    $show_btn = 'yes';
                }
                break;
            }
        }

        $logshowstyle = $advancedata['moduleadvance']['logshowstyle'];
        //将每个阶段的信息以下拉框值作为键生成数组
        foreach ($advanceinfo_arr as $tmp_arr) {
            $tmp_stagevalue = $tmp_arr['value'];
            if(isset($tmp_arr['DetailTaskInfo']) && $logshowstyle == 'underadvance'){
                $tmp_taskinfo = $tmp_arr['DetailTaskInfo'];
                unset($tmp_arr['DetailTaskInfo']);
                $smarty->assign('SHOWTYPE','detail');
                $smarty->assign('TASKLOG',$tmp_taskinfo['tasklog']);
                $smarty->assign('TASKINFO',$tmp_taskinfo['taskinfo']);
                $smarty->assign('ALLOWEDIT',$tmp_taskinfo['allow_edit']);
                $smarty->assign('STAGENAME',$tmp_taskinfo['stagename']);
                $content = $smarty->fetch('Taskprogress.tpl');
                $advancetask_arr[$tmp_stagevalue] = $content;
            }
            //如果推进按钮在节点下方，且有可推进节点，则显示推进按钮，并预留高度
            if($operatestyle == 'inpopup'){
                if($tmp_arr['cur_flag'] == 'yes' && sizeof($alltaskinfo) > 0){
                    $show_btn = 'yes';
                }

            }
            $new_advanceinfo_arr[$tmp_stagevalue] = $tmp_arr;
        }

        //销售线索升级到客户后，需要隐藏推进按钮
        if($hiden_btn == 'yes'){
            $show_btn = 'no';
        }
        $after_cur = 'no';
        $childid_arr = [];
        foreach ($premit_node_info as $tmp_key => $tmp_info){
            $childid = $tmp_info['childid'];
            $childid_arr = explode(',',(string)$childid);
            $stagevalue = $tmp_info['stagename'];

            if($line_class == 'advance-line-current'){
                $line_class = 'advance-line-aftercurrent';
            }else{
                $line_class = '';
            }
            if($tmp_info['nodetype'] == 'approver'){
                $icon_class = 'advance-icon-unfinish';
                $tmp_advanceinfo_arr = $new_advanceinfo_arr[$stagevalue];
                if($tmp_advanceinfo_arr['skip'] == 'yes'){
                    $icon_class = 'advance-icon-skip';
                    $line_class = 'advance-line-finish';
                }elseif ($tmp_advanceinfo_arr['completed'] == 'yes'){
                    if($tmp_advanceinfo_arr['cur_flag'] == 'yes' && !empty($tmp_info['childid'])){
                        $icon_class = 'advance-icon-current';
                        $line_class = 'advance-line-current';
                    }else{
                        $icon_class = 'advance-icon-finish';
                        $line_class = 'advance-line-finish';
                    }
                }elseif ($tmp_advanceinfo_arr['cur_flag'] == 'yes'){
                    $icon_class = 'advance-icon-current';
                    $line_class = 'advance-line-current';
                    $after_cur = 'yes';
                }
                $tmp_advanceinfo_arr['icon_class'] = $icon_class;
                $tmp_advanceinfo_arr['line_class'] = $line_class;
                if(!empty($tmp_advanceinfo_arr['staytimecontent'])){
                    $tmp_advanceinfo_arr['staytimecontent'] = getFixedLabel('STAGEDETENTIONDURATION').'：'.$tmp_advanceinfo_arr['staytimecontent'];
                }
                if(isset($advancetask_arr[$stagevalue]) && $after_cur == 'no'){
                    $tmp_advanceinfo_arr['taskhtml'] = $advancetask_arr[$stagevalue];
                }
                $tmp_advanceinfo_arr['showbtn'] = $show_btn;
                $tmp_advanceinfo_arr['logshowstyle'] = $logshowstyle;
                $premit_node_info[$tmp_key]['advanceinfo'] = $tmp_advanceinfo_arr;
            }else if($tmp_info['nodetype'] == 'start'&&$value_type == 'error'){
                $tmp_advanceinfo_arr['cur_flag'] = 'yes';
                $tmp_advanceinfo_arr['showbtn'] = $show_btn;
                $line_class = 'advance-line-current';
                $tmp_advanceinfo_arr['icon_class'] = 'advance-icon-current';
                $tmp_advanceinfo_arr['line_class'] = $line_class;
                $premit_node_info[$tmp_key]['advanceinfo'] = $tmp_advanceinfo_arr;
                $premit_node_info[$tmp_key]['nodeinfo']['stagevalue'] = getFixedLabel('Start');
            }

            $tmp_class = 'normal_stage';
            if($tmp_key == 0){
                //获取开始节点的信息
                //判断子节点大于1 表示第一个是分支节点，且当前阶段值不在流程中，需要添加一个开始节点
                if(sizeof($childid_arr)>1){
                    $tmp_class = 'start_stage';
                }else{
                    //下拉框值错误时，用开始节点当第一个节点
                    if($value_type == 'error'){
                        $tmp_class = 'start_stage';
                    }else{
                        //其他情况下可用第一个阶段值当开始节点
                        $tmp_class = 'advance-hide';
                    }
                }
            }else{
                //子节点为空表示为结束节点
                if($tmp_key == 1 && $premit_node_info[0]['classname'] == 'advance-hide'){
                    //前一节点为开始节点时，将当前步骤设为开始节点，
                    $tmp_class = 'start_stage';
                    //如果开始节点没有子节点,则表示流程中只有一个节点,不显示前后线条
                    if(empty($childid)){
                        $premit_node_info[$tmp_key]['advanceinfo']['line_class'] = 'advance-line-alone';
                    }
                }else if(empty($childid)){
                    $tmp_class = 'end_stage';
                }else{
                    $tmp_class = 'normal_stage';
                }
                //如果子节点只有一个，追加判断子节点是否为虚拟节点且是结束节点
                /*
                if(sizeof($childid_arr) == 1 && $tmp_info['nodetype'] == 'approver'){
                    $child_info = $premit_node_info[$childid];
                    if($child_info['childid'] == '' && $child_info['nodetype'] == 'conditionvirtual'){
                        //设置当前节点为最后一个显示的节点
                        $tmp_class = 'end_stage';
                    }
                }*/

            }
            $premit_node_info[$tmp_key]['classname'] = $tmp_class;
        }
        return $premit_node_info;
    }
	//获取推进可用阶段值
    public function getProcessStageValue($record){

        if($this->moduleadvance['method'] != 'field'){
            return array();
        }
        //duan 20240722 允许通过数据库配置级联控制是否生效
        if($this->moduleadvance['use_dependency'] == 'yes'){
            $columnForDependencyPicklist = $this->getColumnForDependencyPicklist($record);
            $this->processobj->setdependency($columnForDependencyPicklist);
        }

        $stagenamenow = $this->getStagenameNow($record);
        $process_stage_value = $this->processobj->getProcessStageValue($record,$stagenamenow);

        return $process_stage_value;
    }
    //设置请求的值
    public function setRequestColumn($request_value){
        $request_column = ldcrm_json_decode(urldecode($request_value));


        $this->requestcolumn = $request_column;
    }

    //获取请求中传的字段值
    public function setColumnValuesFromRequest($focus){

        if(is_array($this->requestcolumn) && count($this->requestcolumn) >0){
            $module = $this->module;
            $column_fields = $focus->column_fields;
            $modulefields=$focus->fieldobj->getModuleFields();
            foreach ($this->requestcolumn as $key => $value){
                $fieldname = $key;
                if(isset($modulefields[$fieldname])){
                    $fieldinfo = $modulefields[$fieldname];
                    if ($fieldinfo->getBigType() == 'reference') {
                        $focus->column_fields[$fieldname . '_name'] = $this->requestcolumn[$fieldname . '_name'];
                    } else if ($fieldinfo->getUIType() == 202) {
                        if ($module == 'PaymentPlan' || $module == 'SendPayment') {
                        } else {
                            $focus->column_fields['entitytype'] = $this->requestcolumn['selectsource'];
                        }
                    } else if ($fieldinfo->getUIType() == 33) {
                        if (isset($value))
                            $focus->column_fields[$fieldname] = setsaveMutliPickListValue($value);
                        else {
                            $focus->column_fields[$fieldname] = $fieldinfo->getDefaultvalue();
                        }
                    }else{
                        $focus->column_fields[$fieldname] = $value;
                    }
                }else{
                    $focus->column_fields[$fieldname] = $value;
                }
            }
        }
        return $focus;
    }

    //判断布局规则
    public function getFieldRuleColumn($focus,$col_fields){
	    $record = $focus->id;
        crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
        $fieldruleobj=cls_fieldrule::getInstance($this->module);

        //将fieldname的value值转化为columnname
        $module_field = $focus->fieldobj->getModuleFields();
        $new_value_arr = [];
        foreach ($module_field as $tmp_field){
            $fieldname = $tmp_field->getFieldName();
            $columnname = $tmp_field->getColumnName();
            $new_value_arr[$columnname] = $col_fields[$fieldname];
        }

        $fieldruleobj->setColumnValues($new_value_arr);
        $fieldruleobj->fieldPropertys = '';
        $fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        $fieldrulecolsproperty['alltriggercolumn'] = $fieldruleobj->getAllFieldNameSetChangeEvent();
        return $fieldrulecolsproperty;
    }

    //获取详情页推进返回信息
    public function getReturnAdvanceData(){
        global $adb;
        $focus = $this->focus;
	    $advancedata = [];
        //如果自动化任务中设置了附件字段，则需要读取附件信息
        if($this->withattachment == 'yes'){
            $filejsondata=array();
            if($focus->id>0){
                $filejsondata=getAllFile_imageInfo($focus->id,$this->module);
            }
            $advancedata['filejsondata'] = $filejsondata;
        }
        //涉及自动化任务的字段信息
        if(sizeof($this->advancetaskfield_arr)>0){
            $advancedata['advancefields'] = $this->advancetaskfield_arr;
        }
        $advancedata['module_advacne'] = $this->moduleadvance;
        $advancedata['trigger_fieldname_arr'] = $this->triggerfieldname_arr;
        $advancedata['trigger_fieldvalue_arr'] = $this->triggerfieldvalue_arr;
        if(!empty($focus)){
            $approvedata['mainfieldformula']=$focus->fieldobj->getFormula();
            $approvedata['columnfields_value'] = $focus->column_fields;
        }

        if($this->module == 'Leads' && $this->moduleadvance['module_field'] == 'status'){
            $select_sql = "SELECT failurereason from ld_leads where leadsid = ?";
            $select_result = $adb->pquery($select_sql,array($this->record));
	        $failurereason = $adb->query_result($select_result,0,'failurereason');
            $advancedata['failurereason'] = $failurereason;
        }

        return $advancedata;
    }

    //判断是否存在布局规则控制的必填字段
    public function JudgeRequiredFieldRule($record){
        $focus = CRMEntity::getInstance($this->module);
        $focus->retrieve_entity_info($record,$this->module);

        return $this->CommonEditFieldobj->JudgeRequiredFieldRule($focus);
    }
    //根据创建单据任务的设置，判断是否需要额外读取关联单据信息
    public function addAllModuletasklog($taskinfo_arr,$tasklog_arr,$record)
    {

        foreach ($taskinfo_arr as $key => $tmp_taskinfo_arr) {
            $type = $tmp_taskinfo_arr['type'];
            $taskid = $tmp_taskinfo_arr['taskid'];
            if ($type == 'module') {
                $effect_range = $tmp_taskinfo_arr['effect_range'];
                $approve_demand = $tmp_taskinfo_arr['approve_demand'];
                $related_module = $tmp_taskinfo_arr['tasklabel'];

                if ($effect_range == 'sum') {
                    $tmp_arr = [];
                    $record_arr = $this->getRelatedRecordArr($record, $related_module);

                    if (count($record_arr) > 0) {
                        $tmp_arr['taskresult'] = $record_arr[0]['crmid'];
                        $tmp_arr['record_no'] = $record_arr[0]['record_no'];
                        $tmp_arr['createdtime'] = date('Y-m-d H:i:s');
                        $record_no_arr = [];
                        $crmid_arr = [];
                        $is_all_approved = 'yes';
                        foreach ($record_arr as $tmp_key=>$tmp_info) {
                            if($tmp_key >0 ){
                                $tmp_info['show_record_no'] = ','.$tmp_info['record_no'];
                            }else{
                                $tmp_info['show_record_no'] = $tmp_info['record_no'];
                            }

                            $record_no_arr[] = $tmp_info;
                            $crmid_arr[] = $tmp_info['crmid'];
                            $approvestatus = $tmp_info['approvestatus'];

                            if($approvestatus != constant('D_A_S_APPROVED')){
                                $is_all_approved = 'no';
                            }
                        }
                        $tmp_arr['effective'] = 'yes';
                        $tmp_arr['record_no_arr'] = $record_no_arr;
                        $tmp_arr['is_all_approved'] = $is_all_approved;
                        $tmp_arr['crmid_arr'] = $crmid_arr;
                        $tasklog_arr[$taskid] = $tmp_arr;
                    }else{
                        if(isset($tasklog_arr[$taskid])){
                            unset($tasklog_arr[$taskid]);
                        }
                    }
                }

            }
        }
        return $tasklog_arr;
    }
    //edit:duan date:2024/12/16 reason:获取下拉框日志，用于历史选项转换
    public function get_picklist_changelog($fieldname){
	    $return_arr = $this->picklist_changelog[$fieldname];
	    if(is_array($return_arr) && count($return_arr)>0){
	        return $return_arr;
        }
        $return_arr = [];
        $picklist_changelog_arr = $this->objpinklist->get_picklist_changelog($this->module,$fieldname,'change');
        $picklistvalue = $this->objpinklist->getPickListValues($fieldname,'ld_field',array(),'id');
        $return_arr = array($picklist_changelog_arr,$picklistvalue);
        $this->picklist_changelog[$fieldname] = $return_arr;
        return $return_arr;
    }
}

?>