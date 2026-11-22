<?php
/*
 * edit:duan
 * reason:通用方法,用于推进流程图显示
 * date:20230717
 * */
class cls_advance_process
{
    public $record;
    public $module;
    public $db;
    public $user;
    public $moduleadvance;
    public $allprocess_arr;
    public $allstagevalue_arr;
    public $circulate_count;
    public $DependencyPicklist;
    public $limit_circulate_count;
    public $nodeid_to_nodeinfo;
    public $permit_condition_arr = [];
    public $parent_nodeid_arr = [];
    public $noshow_nodeid_arr = [];
    public $new_arr = [];
    public $new_nodeid;
    public $old_to_new_nodeidarr = [];
    public $limitcount;
    public function __construct($module)
    {
        global $adb,$current_user;
        $this->db = $adb;
        $this->module=$module;
        $this->user = $current_user;
        $this->moduleadvance = [];
        $this->allprocess_arr = [];
        $this->allstagevalue_arr = [];
        $this->circulate_count= 0;
        $this->limit_circulate_count = 10000;
        $this->DependencyPicklist = [];
    }
    //duan 20240712 自动推进后重设阶段信息缓存
    public function resetprocess(){
        $this->allprocess_arr = [];
        $this->allstagevalue_arr = [];
    }

    public static function getInstance($module)
    {
        static $static_common_processobj_arr;
        if(is_array($static_common_processobj_arr)&&array_key_exists($module,$static_common_processobj_arr))
        {
            return $static_common_processobj_arr[$module];
        }
        if(!is_array($static_common_processobj_arr))
        {
            $static_common_processobj_arr=[];
        }
        $static_common_processobj_arr[$module]=new cls_advance_process($module);
        return $static_common_processobj_arr[$module];
    }
    //获取流程所有的节点信息
    public function getAllAdvanceNode($fieldname){
        $module  = $this->module;
        if(empty($fieldname)){
            $cls_module_advance_obj =  cls_module_advance::getInstance($module);
            $module_advance = $cls_module_advance_obj->getModuleAdvance();
            $fieldname = $module_advance['module_field'];
            $this->moduleadvance = $module_advance;
        }

        $adb = $this->db;
        $all_column_info = [];

        $sql = "SELECT * from ld_advanceprocess where frommodule = ? and fieldname = ?";
        $result = $adb->pquery($sql,[$module,$fieldname]);
        if($adb->num_rows($result)>0){
            $all_column_info = $adb->query_result_all($result);
        }

        return $all_column_info;
    }
    //读取信息转化设置界面显示的格式
    public function getNodeSetting($fieldname){
        $all_nodeinfo = $this->getAllAdvanceNode($fieldname);

        crm_load_class_file('cls_AdvftOperate','include');
        $AdvftOperateobj = cls_AdvftOperate::getInstance($this->module);
        foreach ($all_nodeinfo  as $tmp_key => &$tmp_item) {
            $node_type = $tmp_item['nodetype'];
            $tmp_item['nodeinfo'] = [];
            if($node_type == 'condition'){
                $content = $tmp_item['content'];
                $adv_info = json_decode(html_entity_decode($content),true);
                $tmp_item['nodeinfo']['advancesearch'] = $adv_info['advancesearch'];
                $tmp_item['nodeinfo']['groupcondition'] = $adv_info['groupcondition'];
                $tmp_item['nodeinfo']['advftlabel'] = $AdvftOperateobj->TransAdvftTostring($adv_info['advancesearch'],$adv_info['groupcondition']);
                $tmp_item['nodeinfo']['edit'] = 'no';
            }else if($node_type == 'approver'){
                $stagevalue =  html_entity_decode($tmp_item['stagename']);
                $tmp_item['nodeinfo']['stagevalue'] = $stagevalue;
                $tmp_item['nodeinfo']['showlabel'] = $stagevalue;
            }
        }
        return $all_nodeinfo;
    }
    //获取流程图的可用下拉框选项，用于显示推进时间，不包含当前阶段前的其他分支
    public function  getProcessStageValue($record,$stagenamenow){
        if(is_array($this->allstagevalue_arr[$record]) && count($this->allstagevalue_arr[$record])>0){
            return  $this->allstagevalue_arr[$record];
        }
        $premit_node_info = $this->getPermitNodeinfo($record,$stagenamenow);
        $stagevalue_arr = [];

        foreach ($premit_node_info as $tmp_info){
            if(!empty($tmp_info['stagename'])){
                $stagevalue_arr[] = $tmp_info['stagename'];
            }
        }
        $this->allstagevalue_arr[$record] = $stagevalue_arr;
        return $stagevalue_arr;
    }

    //获取流程中，当前单据可流转的节点
    public function getPermitNodeinfo($record,$stagenamenow){
        if(is_array($this->allprocess_arr[$record]) && count($this->allprocess_arr[$record])>0){
            return $this->allprocess_arr[$record];
        }
		$this->record = $record;
        $all_node_info = $this->getAllAdvanceNode('');
        //获取最新的修改日志,判断当前阶段的上级节点
        $fieldname = $this->moduleadvance['module_field'];
        $all_advancetime = $this->getAllModtrackerData($record,$fieldname);
        $cur_branchnodeid = 0;
        if(count($all_advancetime)>0){
            $firstinfo = reset($all_advancetime);
            if($firstinfo['postvalue'] == $stagenamenow){
                $cur_branchnodeid = $firstinfo['branchnodeid'];
            }
        }

        // 用节点id生成索引数组，避免多次循环
        $nodeid_to_nodeinfo = array();
        $cur_nodeid_arr = [];
        $cur_nodeid = 0;
        $choose_count = 0;
        foreach($all_node_info as $tmp_info){
            $tmp_nodeid = $tmp_info['nodeid'];
            if($tmp_info['stagename'] == $stagenamenow && $tmp_info['nodetype'] == 'approver'){
                
                //根据当前所在分支id确定需要找的节点，同一分支的阶段不能重复
                if($cur_branchnodeid >0){
                    if($cur_branchnodeid == $tmp_info['branchnodeid']){
                        $cur_nodeid = $tmp_nodeid;
                    }
                }else{
                    $cur_nodeid = $tmp_nodeid;
                    $choose_count ++;
                }
            }
            $tmp_info['childid_arr'] = explode(',',$tmp_info['childid']);
            $tmp_info['stagename'] = html_entity_decode($tmp_info['stagename']??'');
            $tmp_info['nodeinfo']['stagevalue'] = $tmp_info['stagename'];
            $nodeid_to_nodeinfo[$tmp_nodeid] = $tmp_info;
        }
        if($choose_count > 1){
            $cur_nodeid = 0;
        }
        //选择更适合的节点
		$this->nodeid_to_nodeinfo = $nodeid_to_nodeinfo;
        $this->permit_condition_arr = [];
		$this->parent_nodeid_arr = [];
		$this->noshow_nodeid_arr = [];
        //先获取一次所有满足条件的节点
        $this->getPermitAdvanceNode();
        if($cur_nodeid == 0){
			//优先从符合条件的分支中选择节点
			foreach($this->new_arr as $tmp_info){
				if($tmp_info['stagename'] == $stagenamenow && $tmp_info['nodetype'] == 'approver'){
					$tmp_nodeid = $tmp_info['old_nodeid'];
					$cur_nodeid_arr[] = $tmp_nodeid;
				}
			}
			if(count($cur_nodeid_arr) >0){
				$cur_nodeid = $this->ChooseParentid($nodeid_to_nodeinfo,$cur_nodeid_arr,$all_advancetime);
			}
        }

        //递归获取所有的节点，获取到当前单据所在节点的上级节点
        $index = 0;
        $parent_nodeid_arr = []; //必须显示的父节点id
        $noshow_nodeid_arr = []; //不显示的其他分支id
        $this->circulate_count = 0;
        if($cur_nodeid >0 ){
            $tmp_nodeid = $cur_nodeid;
            do{
                //获取当前节点的上级节点
                $tmp_nodeid = $this->getParentNodeid($nodeid_to_nodeinfo,$tmp_nodeid,$all_advancetime);

                //记录当前节点的上级节点，避免因为字段修改后，条件不符合时，流程图显示错误的问题
                $parent_nodeid_arr[] = $tmp_nodeid;
                //记录当前节点之前未走的分支节点，如果已走过这个分支，则不显示该分支
                $tmp_childid_arr = $nodeid_to_nodeinfo[$tmp_nodeid]['childid_arr'];
                if($tmp_childid_arr>1){
                    //存在多个子节点，则子节点为分支条件，将其他分支条件节点记录为不显示
                    foreach ($tmp_childid_arr as $tmp_id){
                        if(!in_array($tmp_id,$parent_nodeid_arr)){
                            $noshow_nodeid_arr[] = $tmp_id;
                        }
                    }
                }

                $index++;
                if($index>100)break; //避免死循环
            }while($tmp_nodeid>0);
        }

		
        
        $this->parent_nodeid_arr = $parent_nodeid_arr;
        $this->noshow_nodeid_arr = $noshow_nodeid_arr;
        // 为了解决节点条件判断，节点值不对，当前阶段前的分支隐藏，等一系列问题，将所有的节点id和子节点id全部重新生成临时的id
		$this->getPermitAdvanceNode();
        $this->allprocess_arr[$record] = $this->new_arr;
		
        return $this->new_arr;
    }
    //获取父节点id
    public function getParentNodeid($all_nodeinfo_arr,$cur_nodeid,$all_advancetime){
        $this->circulate_count++;

        $parent_nodeid_arr = [];
        $parent_nodeid = -1;
        foreach ($all_nodeinfo_arr as $tmp_arr){
            $childid_arr = $tmp_arr['childid_arr'];
            if(is_array($childid_arr) && in_array($cur_nodeid,$childid_arr)){
                $parent_nodeid_arr[] = $tmp_arr['nodeid'];
            }
        }
        if($this->circulate_count > $this->limit_circulate_count){ //因为存在递归调用避免死循环
            return $parent_nodeid;
        }

        if(sizeof($parent_nodeid_arr) > 1){
            $index_time_all_arr = [];
            $index_time_arr = [];
            $parent_id_arr = [];
            if(is_array($all_advancetime) && sizeof($all_advancetime)>0){
                foreach ($parent_nodeid_arr as $tmp_id){
                    $tmp_info = $all_nodeinfo_arr[$tmp_id];
                    $find_index = 'no';
                    if($tmp_info['nodetype'] == 'approver'){
                        //寻找当前阶段的修改日志
                        if(isset($all_advancetime[$tmp_info['stagename']])){
                            $index_time_all_arr[] = ['nowid'=>$tmp_info['nodeid'] ,'index'=>$all_advancetime[$tmp_info['stagename']]['index'] ,'tmpid'=> $tmp_id];
                            $index_time_arr[$tmp_info['nodeid']] = $all_advancetime[$tmp_info['stagename']]['index'];
                            $parent_id_arr[$tmp_info['nodeid']] = $tmp_id;
                            $find_index = 'yes';
                        }
                    }
                    if($find_index == 'no'){
                        $max_index = 100;
                        $tmp_index = 0;
                        $tmp_parentid = $tmp_id;
                        $find_index = 'no';
                        //递归查找所有的上级节点
                        do{
                            $tmp_parentid = $this->getParentNodeid($all_nodeinfo_arr,$tmp_parentid,$all_advancetime);
                            if($tmp_parentid == -1)break;
                            $tmp_info = $all_nodeinfo_arr[$tmp_parentid];
                            if($tmp_info['nodetype'] == 'approver'){
                                //寻找最近一个阶段的修改日志
                                if(isset($all_advancetime[$tmp_info['stagename']])){
                                    $index_time_all_arr[] = ['nowid'=>$tmp_info['nodeid'] ,'index'=>$all_advancetime[$tmp_info['stagename']]['index'] ,'tmpid'=> $tmp_id];
                                    $index_time_arr[$tmp_info['nodeid']] = $all_advancetime[$tmp_info['stagename']]['index'];
                                    $parent_id_arr[$tmp_info['nodeid']] = $tmp_id;
                                    $find_index = 'yes';
                                }
                                if($find_index == 'yes'){
                                    break;
                                }
                            }
                            $tmp_index ++;
                            if($tmp_index>$max_index){
                                break;
                            }
                        }while(true);
                    }
                }
            }

            //如果多个节点指向同一个父节点,则视为判断失败
            if(count($index_time_all_arr)>1 && count($parent_id_arr)==1 ){
                $index_time_all_arr = [];
            }

            if(count($index_time_all_arr)==0){
                //如果用修改日志无法比较，则使用条件进行比较
                $new_id_arr = [];
                foreach ($parent_nodeid_arr as $tmp_id){
                    $tmp_info = $all_nodeinfo_arr[$tmp_id];
                    //找到当前所属分支的条件节点
                    $tmp_conditionid = 0;
                    if($tmp_info['nodetype'] == 'approver') {
                        $tmp_conditionid = $tmp_info['branchnodeid'];
                    }else if($tmp_info['nodetype'] == 'conditionvirtual'){
                        $tmp_conditionid = $tmp_info['branchnodeid'];
                        $tmp_i = 0;
                        do{
                            $tmp_condition_info = $all_nodeinfo_arr[$tmp_conditionid];
                            if(empty($tmp_condition_info['nodetype']) || $tmp_condition_info['nodetype'] == 'condition'){
                                break;
                            }else{
                                $tmp_conditionid = $tmp_condition_info['branchnodeid'];
                            }
                            $tmp_i ++;
                        }while($tmp_conditionid>0 && $tmp_i <100);
                    }else if($tmp_info['nodetype'] == 'condition'){
                        $tmp_conditionid = $tmp_id;
                    }
                    if(in_array($tmp_conditionid,$this->permit_condition_arr)){
                        $new_id_arr[] = $tmp_id;
                    }
                }
                if(count($new_id_arr) >=1){
                    $parent_nodeid = $new_id_arr[0];
                }else{
                    $parent_nodeid = $parent_nodeid_arr[0];
                }
            }elseif(count($index_time_all_arr)==1){
                //$node_id_arr = array_keys($index_time_arr);
                //$parent_nodeid = $parent_id_arr[$node_id_arr[0]];
                $parent_nodeid =  $index_time_all_arr[0]['tmpid'];
            }elseif(count($index_time_all_arr)>1){
                $min_index = min($index_time_arr);
                $new_id_arr = [];
                foreach ($index_time_all_arr as $tmp_arr){
                    if($tmp_arr['index'] == $min_index){
                        $new_id_arr[] = $tmp_arr['nowid'];
                    }
                }
                if($new_id_arr > 1){
                    $new_parent_id = $this->ChooseParentid($all_nodeinfo_arr,$new_id_arr,$all_advancetime);
                }else{
                    $new_parent_id = $new_id_arr[0];
                }
                $parent_nodeid = $parent_id_arr[$new_parent_id];
            }
        }else if(sizeof($parent_nodeid_arr) == 1){
            $parent_nodeid = $parent_nodeid_arr[0];

        }
        return $parent_nodeid;
    }
    //根据修改日志判断应该选择的节点
    public function ChooseParentid($all_nodeinfo_arr,$cur_nodeid_arr,$all_advancetime){
        $this->circulate_count++;
        //避免死循环
        if(sizeof($cur_nodeid_arr) <= 1 || $this->circulate_count >$this->limit_circulate_count){
            $cur_nodeid = $cur_nodeid_arr[0];
            return $cur_nodeid;
        }
        $cur_nodeid = -1;
        $index_time_arr = [];
        $parent_id_arr = [];
        $parent_conditionid_arr = [];
        $index_time_all_arr = [];
        if(sizeof($all_advancetime)>0){
            foreach ($cur_nodeid_arr as $tmp_id){
                //分别循环向上查找，直到找到符合条件的节点
                $max_index = 100;
                $tmp_index = 0;
                $tmp_parentid = $tmp_id;
                $find_index = 'no';
                do{
                    $tmp_parentid = $this->getParentNodeid($all_nodeinfo_arr,$tmp_parentid,$all_advancetime);
                    if($tmp_parentid == -1)break;
                    $tmp_info = $all_nodeinfo_arr[$tmp_parentid];
                    $tmp_nodeid = $tmp_info['nodeid'];
                    if($tmp_info['nodetype'] == 'approver'){
                        if(isset($all_advancetime[$tmp_info['stagename']])){
                            $index_time_all_arr[] = ['nowid'=>$tmp_info['nodeid'] ,'index'=>$all_advancetime[$tmp_info['stagename']]['index'] ,'tmpid'=> $tmp_id];
                            $index_time_arr[$tmp_nodeid] = $all_advancetime[$tmp_info['stagename']]['index'];
                            $parent_id_arr[$tmp_nodeid] = $tmp_id;
                            $find_index = 'yes';
                        }
                        if($find_index == 'yes'){
                            break;
                        }
                    }
                    $tmp_index ++;
                    if($tmp_index>$max_index){
                        break;
                    }
                }while(true);
            }
        }

        //如果多个节点指向同一个父节点,则视为判断失败
        if(count($index_time_all_arr)>1 && count($parent_id_arr)==1 ){
            $index_time_all_arr = [];
        }

        if(count($index_time_all_arr)==0){
            //如果用修改日志无法比较，则使用条件进行比较
            $new_id_arr = [];
            foreach ($cur_nodeid_arr as $tmp_id){
                $tmp_info = $all_nodeinfo_arr[$tmp_id];
                //找到当前所属分支的条件节点
                $tmp_conditionid = 0;
                if($tmp_info['nodetype'] == 'approver') {
                    $tmp_conditionid = $tmp_info['branchnodeid'];
                }else if($tmp_info['nodetype'] == 'conditionvirtual'){
                    $tmp_conditionid = $tmp_info['branchnodeid'];
                    $tmp_i = 0;
                    do{
                        $tmp_condition_info = $all_nodeinfo_arr[$tmp_conditionid];
                        if(empty($tmp_condition_info['nodetype']) || $tmp_condition_info['nodetype'] == 'condition'){
                            break;
                        }else{
                            $tmp_conditionid = $tmp_condition_info['branchnodeid'];
                        }
                        $tmp_i ++;
                    }while($tmp_conditionid>0 && $tmp_i <100);
                }else if($tmp_info['nodetype'] == 'condition'){
                    $tmp_conditionid = $tmp_id;
                }
                if(in_array($tmp_conditionid,$this->permit_condition_arr)){
                    $new_id_arr[] = $tmp_id;
                }
            }
            if(count($new_id_arr) >=1){
                $cur_nodeid = $new_id_arr[0];
            }else{
                $cur_nodeid = $cur_nodeid_arr[0];
            }
        }elseif(count($index_time_all_arr)==1){
            //$node_id_arr = array_keys($index_time_arr);
            //$cur_nodeid = $parent_id_arr[$node_id_arr[0]];
            $cur_nodeid =  $index_time_all_arr[0]['tmpid'];
        }elseif(count($index_time_all_arr)>1){
            $min_index = min($index_time_arr);
            $new_id_arr = [];
            foreach ($index_time_all_arr as $tmp_arr){
                if($tmp_arr['index'] == $min_index){
                    $new_id_arr[] = $tmp_arr['nowid'];
                }
            }
            if($new_id_arr > 1){
                $new_parent_id = $this->ChooseParentid($all_nodeinfo_arr,$new_id_arr,$all_advancetime);
            }else{
                $new_parent_id = $new_id_arr[0];
            }
            $cur_nodeid = $parent_id_arr[$new_parent_id];

        }

        return $cur_nodeid;
    }

    //进行分支条件判断
    public function getCheckStepadvFilterList($content,$record,$nodeid)
    {
        global $current_user,$adb;
        if(!empty($content)){
            $customView = CustomView::getInstance($this->module);
            $queryobj =  QueryGenerator::getInstance($this->module, $current_user,$customView,'','no');
            $adv_info = json_decode(html_entity_decode($content),true);

            if(is_array($adv_info)&&is_array($adv_info['advancesearch']))
            {
                $input = [];
                $input['searchtype']='advance';
                $input['advft_criteria']=json_encode($adv_info['advancesearch']);
                $input['advft_criteria_groups']=json_encode($adv_info['groupcondition']);
                $queryobj->addUserSearchConditions($input);
                //说明该步骤设置了查询条件
                $query=$queryobj->getQuery("",1);
                $query.=" and ".$queryobj->moduleobj->table_name.'.'.$queryobj->moduleobj->table_index.'='.$record;
                $result=$adb->pquery($query,array());
				
                if($adb->num_rows($result)>0){
                    return 'yes';
                }else{

                    return 'no';
                }
            }
        }else{
            return 'yes';
        }

    }
    //获取子节点信息
    public function getchildinfo($childid_arr,$parentid){
        //避免程序死循环
        if($this->limitcount >$this->limit_circulate_count){
            return '';
        }

        $this->limitcount++;
        $nodeid_to_nodeinfo = $this->nodeid_to_nodeinfo;
        if(is_array($childid_arr) && sizeof($childid_arr)>1){
            //子节点数量大于1,表示需要判断分支
            $count = 0; //统计当前单据满足分支的数量
            $permit_nodeid_arr = [];

            foreach($childid_arr as $tmp_key => $tmp_childid){
                $tmp_nodeinfo = $nodeid_to_nodeinfo[$tmp_childid];

                if($tmp_nodeinfo['nodetype'] == 'condition'){
                    if(!in_array($tmp_childid,$this->permit_condition_arr) ){
                        $permit = $this->getCheckStepadvFilterList($tmp_nodeinfo['content'],$this->record,$tmp_childid);
                        if($permit == 'yes'){
                            $this->permit_condition_arr[] = $tmp_childid;
                        }
                    }else{
                        $permit = 'yes';
                    }
                    if(!in_array($tmp_childid,$this->parent_nodeid_arr)){
                        if(in_array($tmp_childid,$this->noshow_nodeid_arr)){
                            continue;
                        }else if($this->record<=0 || $permit =='no'){
                            continue;
                        }
                    }
					
                    $count ++;
                    $permit_nodeid_arr[] = $tmp_childid;
                }else if($tmp_nodeinfo['nodetype'] == 'approver'){
                    //如果是审批人节点直接返回，正常情况下多个分支的第一个不会是审批人节点，控制一下错误情况
                    return '';
                }
            }


            //如果存在多个分支满足条件的情况，则需要将分支节点加入
            if($count >1){
                foreach ($permit_nodeid_arr as $tmp_nodeid){
                    $tmp_nodeinfo = $nodeid_to_nodeinfo[$tmp_nodeid];

                    if(!isset($this->old_to_new_nodeidarr[$tmp_nodeid])){
                        $new_nodeid = $this->new_nodeid;
                        $this->old_to_new_nodeidarr[$tmp_nodeid] = $new_nodeid;
                        $tmp_nodeinfo['old_nodeid'] = $tmp_nodeinfo['nodeid'];
                        $tmp_nodeinfo['nodeid'] = $new_nodeid;
                        $tmp_nodeinfo['new_childid_arr'] = [];
                        $tmp_nodeinfo['childid'] = '';
                        $this->new_arr[$new_nodeid] = $tmp_nodeinfo;
                        $this->new_nodeid ++;
                    }else{
                        $new_nodeid = $this->old_to_new_nodeidarr[$tmp_nodeid];
                    }

                    if(!in_array($new_nodeid,$this->new_arr[$parentid]['new_childid_arr'])){
                        $this->new_arr[$parentid]['new_childid_arr'][] = $new_nodeid;
                        $this->new_arr[$parentid]['childid'] = implode(',',$this->new_arr[$parentid]['new_childid_arr']);
                    }
                    $this->getchildinfo($tmp_nodeinfo['childid_arr'],$new_nodeid);
                }
            }else if($count == 1){
                //如果满足条件的分支只有一个，则不需要添加分支节点
                $tmp_nodeinfo = $nodeid_to_nodeinfo[$permit_nodeid_arr[0]];
                //如果该分支不需要添加，则该分支对应的虚拟节点也不需要添加
                $virtualnodeid = $this->getvirtualnodeid($permit_nodeid_arr[0]);

                $this->noshow_nodeid_arr[] = $virtualnodeid;

                $this->getchildinfo($tmp_nodeinfo['childid_arr'],$parentid);
            }
        }else if(is_array($childid_arr) && sizeof($childid_arr)==1 && !empty($childid_arr[0])){
            //单个子节点一般是步骤和虚拟节点
            $tmp_nodeid = $childid_arr[0];
            $tmp_nodeinfo = $nodeid_to_nodeinfo[$tmp_nodeid];

            if(in_array($tmp_nodeid,$this->noshow_nodeid_arr) && $tmp_nodeinfo['nodetype'] == 'conditionvirtual'){
                $this->getchildinfo($tmp_nodeinfo['childid_arr'],$parentid);
                return '';
            }
            //duan 20240722 允许通过数据库配置级联控制是否生效
            if($tmp_nodeinfo['nodetype'] == 'approver' && sizeof($this->DependencyPicklist)>0 && !in_array($tmp_nodeinfo['stagename'],$this->DependencyPicklist)){
                $this->getchildinfo($tmp_nodeinfo['childid_arr'],$parentid);
                return '';
            }

            if(!isset($this->old_to_new_nodeidarr[$tmp_nodeid])){
                $new_nodeid = $this->new_nodeid;
                $this->old_to_new_nodeidarr[$tmp_nodeid] = $new_nodeid;
				$tmp_nodeinfo['old_nodeid'] = $tmp_nodeinfo['nodeid'];
                $tmp_nodeinfo['nodeid'] = $new_nodeid;
                $tmp_nodeinfo['new_childid_arr'] = [];
                $tmp_nodeinfo['childid'] = '';
                $this->new_arr[$new_nodeid] = $tmp_nodeinfo;
                $this->new_nodeid ++;
            }else{
                $new_nodeid = $this->old_to_new_nodeidarr[$tmp_nodeid];
            }

            if(!in_array($new_nodeid,$this->new_arr[$parentid]['new_childid_arr'])){
                $this->new_arr[$parentid]['new_childid_arr'][] = $new_nodeid;
                $this->new_arr[$parentid]['childid'] = implode(',',$this->new_arr[$parentid]['new_childid_arr']);
            }
            $this->getchildinfo($tmp_nodeinfo['childid_arr'],$new_nodeid);

            /*
            if($tmp_nodeinfo['nodetype'] == 'approver'){
                if(!isset($this->old_to_new_nodeidarr[$tmp_nodeid])){
                    $new_nodeid = $this->new_nodeid;
                    $this->old_to_new_nodeidarr[$tmp_nodeid] = $new_nodeid;
                    $tmp_nodeinfo['nodeid'] = $new_nodeid;
                    $tmp_nodeinfo['new_childid_arr'] = [];
                    $tmp_nodeinfo['childid'] = '';
                    $this->new_arr[$new_nodeid] = $tmp_nodeinfo;
                    $this->new_nodeid ++;
                }else{
                    $new_nodeid = $this->old_to_new_nodeidarr[$tmp_nodeid];
                }
                if(!in_array($new_nodeid,$this->new_arr[$parentid]['new_childid_arr'])){
                    $this->new_arr[$parentid]['new_childid_arr'][] = $new_nodeid;
                    $this->new_arr[$parentid]['childid'] = implode(',',$this->new_arr[$parentid]['new_childid_arr']);
                }
                $this->getchildinfo($tmp_nodeinfo['childid_arr'],$new_nodeid);
            }else{
                //非审批人节点继续获取子节点
                $this->getchildinfo($tmp_nodeinfo['childid_arr'],$parentid);
            }
            */
        }else{     //如果没有子节点，表示为最后一步，可以结束流程
            return '';
        }
    }
    //获取分支下的虚拟节点
    public function  getvirtualnodeid($condition_nodeid){
        $tmp_info = $this->nodeid_to_nodeinfo[$condition_nodeid];

        $virtualnodeid = -1;
        foreach ($this->nodeid_to_nodeinfo as $tmp_arr){
            if($tmp_info['branchnodeid'] == $tmp_arr['branchnodeid'] && $tmp_arr['nodetype'] == 'conditionvirtual'){
                $virtualnodeid = $tmp_arr['nodeid'];
            }
        }
        return $virtualnodeid;
    }

    //获取字段的所有修改日志
    private function getAllModtrackerData($record,$fieldname){
        global $adb,$current_user;
        //edit:duan date:2024/12/16 reason:获取下拉框日志，用于历史选项转换
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();
        $picklist_changelog_arr = $objpinklist->get_picklist_changelog($this->module,$fieldname,'change');
        $picklistvalue = $objpinklist->getPickListValues($fieldname,'ld_field',array(),'id');

        $languageType= getLanguageType($current_user);
        $query = "
			select ld_modtracker_basic.changedon,ld_modtracker_detail.prevalue,ld_modtracker_detail.postvalue,whodid,ld_tranlabel.fieldlabel,ld_modtracker_detail.advancerelatedid from ld_modtracker_basic 
			LEFT JOIN ld_modtracker_detail on ld_modtracker_detail.id = ld_modtracker_basic.id
			LEFT JOIN ld_tab on ld_tab.`name` = ld_modtracker_basic.module
			INNER JOIN ld_field on ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ld_tab.tabid and ld_field.tabid = ?
			LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_field.fieldid 
			and ld_tranlabel.trantable = 'ld_field' and ld_tranlabel.languagetype = ?
			where ld_modtracker_detail.fieldname = ? and crmid = ? order by ld_modtracker_basic.changedon desc,ld_modtracker_basic.id desc";
        $tabid = getTabid($this->module);
        if($tabid==16)$tabid = 9;
        $result = $adb->pquery($query,array($tabid,$languageType,$fieldname,$record));

        $num_rows = $adb->num_rows($result);
        $data = [];
        if($num_rows >= 1){
            for($i = 0; $i < $num_rows; $i++){
                $prevalue = $adb->query_result($result,$i,'prevalue');
                $postvalue = $adb->query_result($result,$i,'postvalue');
                $changedon = $adb->query_result($result,$i,'changedon');
                $branchnodeid = $adb->query_result($result,$i,'advancerelatedid');
                $tmp_arr = [];

                //edit:duan date:2024/12/16 reason:根据下拉框修改日志，转换历史选项的数据
                if(is_array($picklistvalue) && is_array($picklist_changelog_arr) && sizeof($picklist_changelog_arr)>0 ){
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

                $tmp_arr['branchnodeid'] = $branchnodeid;
                $tmp_arr['index'] = $i;
                $tmp_arr['postvalue'] = $postvalue;
                if(!isset($data[$postvalue])){
                    $data[$postvalue] = $tmp_arr;
                }
            }
        }

        return $data;
    }
	//获取符合条件流转单节点
	public function getPermitAdvanceNode(){
		$cur_id = -1; //从开始节点遍历
        $this->new_arr = [];
        $cur_stepinfo = $this->nodeid_to_nodeinfo[$cur_id];
        $childid_arr = $cur_stepinfo['childid_arr'];
        $cur_stepinfo['new_childid_arr'] = [];
        $this->new_arr[] = $cur_stepinfo;
        $this->new_nodeid = 1;
        $this->old_to_new_nodeidarr = [];
        $this->limitcount = 0;
        $this->getchildinfo($childid_arr,0);
	}

	//如果当前阶段不属于流程中的阶段，则获取允许流转的第一层节点
    public function getfirststage($premit_node_info){
        $nodeid_to_nodeinfo = [];

        foreach ($premit_node_info as $tmp_info){
            $tmp_nodeid = $tmp_info['nodeid'];
            $nodeid_to_nodeinfo[$tmp_nodeid] = $tmp_info;
        }
        $firststage_arr = $this->getchild_nocheck($nodeid_to_nodeinfo,-1);

        $this->circulate_count = 0;
        $stagename_arr = [];
        foreach ($firststage_arr as $tmp_id){
            $tmp_info = $nodeid_to_nodeinfo[$tmp_id];
            $tmp_stage = $tmp_info['stagename'];
            if(!in_array($tmp_stage,$stagename_arr)){
                $stagename_arr[] = $tmp_stage;
            }
        }
        return $stagename_arr;
    }
    //获取子节点id,不判断条件
    public function getchild_nocheck($nodeid_to_nodeinfo,$cur_nodeid){
        $stageid_arr = [];
        $this->circulate_count++;
        //避免死循环
        if($this->circulate_count > $this->limit_circulate_count){
            return $stageid_arr;
        }

        $cur_info = $nodeid_to_nodeinfo[$cur_nodeid];
        $childid_arr = $cur_info['new_childid_arr'];
        foreach ($childid_arr as $tmp_id){
            $tmp_info = $nodeid_to_nodeinfo[$tmp_id];
            if($tmp_info['nodetype'] == 'approver'){
                $stageid_arr[] = $tmp_id;
            }else{
                $tmp_arr = $this->getchild_nocheck($nodeid_to_nodeinfo,$tmp_id);
                $stageid_arr = array_merge($stageid_arr,$tmp_arr);
            }
        }
        $stageid_arr = array_unique($stageid_arr);
        return $stageid_arr;
    }

    public function setdependency($DependencyPicklist){
        $this->DependencyPicklist = $DependencyPicklist;
    }
}

?>