<?php
crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');

class cls_gzYinheSalesGoalReport extends SalesGoalNew{
    public $adb,$language;
    public $smarty;
    public $current_user;
    public $params;
    public function __construct()
    {
        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->smarty = new lingdangCRM_Smarty();
    }
    public function setParams($params){
        $this->params = $params;
    }

    //页面
    public function index(){
        $smarty =  $this->smarty;
        global $global_css_url,$global_js_url,$theme,$global_commonurl;
        $smarty->assign("language",$this->language);
        $smarty->assign("JSURL","");
        $smarty->assign("CSSURL","");
        $smarty->assign("THEME",$theme);
        $smarty->assign("CRMCOMMONURL","");

        //部门默认值--默认选中所有部门--20241125修改:默认选中销售部
        $bumenInfo = $this->getBumenInfo();
        $smarty->assign("bumenids",$bumenInfo['bumenids']);
        $smarty->assign("bumennames",$bumenInfo['bumennames']);
        //成员默认值  -- 按合同订单的数据范围
        $this->params['sqlvar_selectbumen'] = $bumenInfo['bumenids'];
        $userarr = $this->getUsersInfo();

        $usernames=implode(',',array_values($userarr));
        $userids=implode(',',array_keys($userarr));
        $smarty->assign("userids",$userids);
        $smarty->assign("usernames",$usernames);
        //目标年度 下拉框值
        $targetYearList = $this->getMubiaoYearList();
        $smarty->assign("targetYearList",$targetYearList);

        //日期的默认值
        $startdate = date('Y-01-01');
        $enddate = date('Y-m-d');
        $pinpai_arr = [];
        if(is_array($targetYearList)&&isset($targetYearList[0])){
            $startdate = $targetYearList[0]['startdate'];
            $enddate = $targetYearList[0]['enddate'];
            $pinpai = $targetYearList[0]['pinpai'];
            $pinpai = trim($pinpai,',');
            $pinpai_arr = explode(',',$pinpai);
        }
        $smarty->assign("startdate",$startdate);
        $smarty->assign("enddate",$enddate);
        //品牌下拉框值
        //$columnname = 'cf_7872';
        //crm_load_class_file("cls_PickList", 'modules/PickList');
        //$objpinklist = new cls_PickList();
        //$valuearr = $objpinklist->getPickListValues($columnname,"",array(),"id");
        $smarty->assign("cf_7872",$pinpai_arr);

        $smarty->display("ReportAnalysis/gzYinheSalesGoalReport.tpl");
    }

    /**
     * @return array
     * @throws Exception
     */
    public function getMubiaoYearList(){
        global $adb;
        $sqlstr = " select cf_7929 as targetyear,cf_7927 as startdate,cf_7928 as enddate,group_concat(cf_7872,',') as pinpai from ld_minusjobbill 
left join ld_minusjobbillscf on ld_minusjobbill.minusjobbillid=ld_minusjobbillscf.minusjobbillid 
where deleted=0 and ifnull(cf_7929,'')<>'' group by cf_7929 order by ld_minusjobbill.minusjobbillid desc  ;";
        $res = $adb->pquery($sqlstr);
        $arr = [];
        $rows = $adb->num_rows($res);
        if($rows>0){
            for ($i=0;$i<$rows;$i++){
                $pinpai = $adb->query_result($res,$i,'pinpai');
                if(!empty($pinpai))
                    $pinpai = trim($pinpai,',');

                $arr[$i] = [
                    'targetyear'=>$adb->query_result($res,$i,'targetyear'),
                    'startdate'=>$adb->query_result($res,$i,'startdate'),
                    'enddate'=>$adb->query_result($res,$i,'enddate'),
                    'pinpai'=>$pinpai,
                ];
            }
        }
        return $arr;
    }
    public function setModuleSearchNew(){
        $advft_criteria = array();
        $params = $this->params;
        $record_str = $params['record_str'];
        $pinpai = $params['pinpai'];
        //判断是否有该模块权限，若无权限则不跳转对应模块
        $search_date_value =$params['search_date_value'];
        $date = explode('~',$search_date_value);
        $comparator='bw';
        if(sizeof($date) < 2){
            $data_start= $search_date_value.'-01';
            $data_end =$search_date_value.'-'.DateOperation::getMonthDays($search_date_value.'-01');
            $date_value=$data_start.','.$data_end;
        }else{
            $date_value=$date[0].','.$date[1];
        }
        $advft_criteria_groups = '[null,{"groupcondition":""}]';
        if(!empty($pinpai)){
            $advft_criteria[] = ['groupid'=>1,
                'columnname'=>'ld_productcf:cf_7752:cf_7752:products_fieldlabel:V',
                'comparator'=>'e',
                'value'=>$pinpai,
                'columncondition'=>'and'
            ];
        }
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>'ld_salesorder:smownerid:assigned_user_id:SalesOrder_fieldlabel:V',
            'comparator'=>'findinset',
            'value'=>$record_str,
            'columncondition'=>'and'
        ];
        $advft_criteria[] = ['groupid'=>1,
            'columnname'=>'ld_salesorder:signed_data:signed_data:SalesOrder_fieldlabel:D',
            'comparator'=>'between',
            'value'=>$date_value,
            'columncondition'=>''
        ];

        $advft['advft_criteria'] = json_encode($advft_criteria);
        $advft['advft_criteria_groups'] = $advft_criteria_groups;
        $advft['searchtype'] = 'advance';
        $entitytype = 'SalesOrder';

        $_SESSION['LiveViewSearch'][$entitytype]['input'] = $advft;
        //清空当前模块的搜索条件
        $_SESSION['lvs'][$entitytype] = array();
        $_SESSION['lvs'][$entitytype]['SearchScope'] = 'SmOwner_Search_All';
        ConvertTojsonString(1,array(),'success');
    }
    //数据
    public function getData(){
        $smarty =  $this->smarty;

        //根据设置的目标范围筛选用户
        $userarr = $this->getUsersInfo();//人员数组 数组格式是[id=>lastname,id=>lastname]
        $usersGroup = $this->getUserGroupNew($userarr);

        $targetDataInfo = $this->getTargetDataInfoNew();

        $overDataInfo = $this->getSalesGoalOverInfoNew();

        $arr = $this->getTargetAndOverArr($userarr,$usersGroup,$targetDataInfo,$overDataInfo);
        $treeValue = $this->getGetSalesGoalTreeNew($userarr,$usersGroup,$arr);
        if(empty($treeValue)){
            $treeValue = '{}';
        }
        $smarty->assign("treeValue",$treeValue);
        $smarty->assign("INCOMPLETEVALUE","INCOMPLETEVALUE");
        $treeHtml = $smarty->fetch('modules/SalesGoal/SalesGoalListViewAjax_tree_new.tpl');
        ConvertTojsonString(1, ['content' => $treeHtml], '');
    }

    public function getGetSalesGoalTreeNew($userarr,$userGroup,$arr){
        $demcial = self::getAmountDecimal();
        $datatype = 'amount';
        $mode = 'tree';
        $user_total_by_month_arr = $arr['user_total_by_month_arr'];
        $group_total_by_month_arr = $arr['group_total_by_month_arr'];
        $sqlvar_selectbumen = $this->params['sqlvar_selectbumen'];

        $groups = self::getGroupNew($sqlvar_selectbumen);
        $newUserGroup=$userGroup;

        $sort_groups = array_reverse($groups);
        $maxdepth = $sort_groups[0]['depth'];
        //将子部门中的目标添加到上一级部门中
        $orgin_group_total_by_month_arr = $group_total_by_month_arr;//保存原始数据 暂时无用

        $this->resetGroupData($sort_groups,$maxdepth,$group_total_by_month_arr);

        foreach($groups as $k => $group){
            $parentGroup = explode('::',$group['parentgroup']);
            $topParentid =$parentGroup[0];

            if($group['depth'] == 0){
                $data['record_str'] = implode(',',array_keys($userarr));
                $usersInfoArr = $this->getUserStatus($data['record_str']);
                $groupid = $group['groupid'];
                $groupobj=new Group();
                $groupobj->groupid=$group['groupid'];
                $groupobj->groupname=$group['groupname'];
                $tmp_groupname=getWx_GroupName($groupobj);
                $data['name']=$tmp_groupname;
                $data['pinpai']='';
                $data['targetid']='';
                $data['search_date']='';
                $target_value = $group_total_by_month_arr[$groupid]['target'];
                $finish_value = $group_total_by_month_arr[$groupid]['finish'];
                $percent = self::calPercent($finish_value,$target_value);
                $data['tolook']= $this->getShowValue(($target_value-$finish_value),$demcial,$datatype,$mode,0);
                $data['complete']= $this->getShowValue($finish_value,$demcial,$datatype,$mode,0);
                //wyt 2209010 1000179销售目标，树状图表的目标、完成值、完成率增加高度或颜色区分（戚涛）
                $height_info = $this->getTargetHegiht($percent);
                $data['tolookheight'] = $height_info['tolook'];
                $data['completeheight'] = $height_info['complete'];
                $data['colorpercent'] = $height_info['color'];

                $data['percent'] = number_format($percent,2);
                $childUser=array();

                foreach ($userGroup[0] as $userid =>$user){  //所有无部门的人员
                    $tmp_userid = $user['userid'];
                    $extra_name = $usersInfoArr[$tmp_userid] == 'Inactive' ? '<span style="color: red;">('.getFixedLabel('Quit').')</span>':'';
                    $target_value = $user_total_by_month_arr[$tmp_userid]['target'];
                    $finish_value = $user_total_by_month_arr[$tmp_userid]['finish'];
                    if($target_value !=0 || $finish_value !=0){
                        $percent = self::calPercent($finish_value,$target_value);
                        $height_info = $this->getTargetHegiht($percent);
                        $tolookheight = $height_info['tolook'];
                        $completeheight = $height_info['complete'];
                        $colorpercent = $height_info['color'];

                        $tempuser = array(
                            'type'=>'1',
                            'name'=>$userarr[$user['userid']],
                            'extra_name'=>$extra_name,
                            'targetid'=>'',
                            'pinpai'=>"",
                            'search_date'=>'',
                            'record_str'=>$user['userid'],
                            'tolookheight'=> $tolookheight,
                            'completeheight'=> $completeheight,
                            'colorpercent'=> $colorpercent,
                            'tolook'=>$this->getShowValue(($target_value-$finish_value),$demcial,$datatype,$mode,$targetid),
                            'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                            'percent'=>number_format($percent,2),
                        );
                        $childUser['user'.$tmp_userid] =$tempuser;
                    }
                }
                foreach ($userGroup[1] as $userid =>$user){
                    $tmp_userid = $user['userid'];
                    $extra_name = $user['status'] == 'Inactive' ? '<span style="color: red;">('.getFixedLabel('Quit').')</span>':'';
                    $target_value = $user_total_by_month_arr[$tmp_userid]['target'];
                    $finish_value = $user_total_by_month_arr[$tmp_userid]['finish'];
                    if($target_value !=0 || $finish_value !=0){
                        $percent = self::calPercent($finish_value,$target_value);
                        //获取
                        $height_info = $this->getTargetHegiht($percent);
                        $tolookheight = $height_info['tolook'];
                        $completeheight = $height_info['complete'];
                        $colorpercent = $height_info['color'];

                        $tempuser = array(
                            'type'=>'1',
                            'name'=>$userarr[$user['userid']],
                            'extra_name'=>$extra_name,
                            'pinpai'=>"",
                            'targetid'=>'',
                            'search_date'=>'',
                            'record_str'=>$user['userid'],
                            'tolookheight'=> $tolookheight,
                            'completeheight'=> $completeheight,
                            'colorpercent'=> $colorpercent,
                            'tolook'=>$this->getShowValue(($target_value-$finish_value),$demcial,$datatype,$mode,$targetid),
                            'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                            'percent'=>number_format($percent,2),
                        );
                        $childUser['user'.$user['userid']] =$tempuser;

                    }
                }

                self::treeChildrenValue($data,$parentGroup,$childUser,$topParentid,$this->groupseq_arr);
            }
            else{
                $tmp_groupid = $group['groupid'];
                //edit: xll 2024/01/02 BUG0078098 目标管理树状图顺序seq导致数据错乱
                if(!isset($this->groupseq_arr[$tmp_groupid])){
                    $this->groupseq_arr[$tmp_groupid] = $group['groupseq'];
                }
                $target_value = $group_total_by_month_arr[$tmp_groupid]['target'];
                $finish_value = $group_total_by_month_arr[$tmp_groupid]['finish'];
                //duan truec 的解释，部门本身设置目标为0 时，可能下级部门或用户目标不是0.先不隐藏部门
                if(($target_value != 0 || $finish_value != 0 || true) && isset($group_total_by_month_arr[$tmp_groupid])){
                    $percent = self::calPercent($finish_value,$target_value);
                    $userStr ='';
                    foreach ($newUserGroup[$tmp_groupid] as $k =>$user){
                        if($k+1 == count($newUserGroup[$tmp_groupid])){
                            $userStr.= $user['userid'];
                        }else{
                            $userStr.= $user['userid'].',';
                        }
                    }
                    $groupobj=new Group();
                    $groupobj->groupid=$tmp_groupid;
                    $groupobj->groupname=$group['groupname'];
                    $groupname=getWx_GroupName($groupobj);

                    $height_info = $this->getTargetHegiht($percent);
                    $tolookheight = $height_info['tolook'];
                    $completeheight = $height_info['complete'];
                    $colorpercent = $height_info['color'];
                    $tempGroup = array(
                        'name' => $groupname,
                        'targetid'=>'',
                        'pinpai'=>"",
                        'search_date'=>'',
                        'record_str'=>$userStr,
                        'tolookheight'=> $tolookheight,
                        'completeheight'=> $completeheight,
                        'colorpercent'=> $colorpercent,
                        'tolook'=>$this->getShowValue(($target_value-$finish_value),$demcial,$datatype,$mode,$targetid),
                        'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                        'percent'=>number_format($percent,2),
                    );

                    self::treeChildrenValue2($data, $parentGroup, $tempGroup,$topParentid,$this->groupseq_arr);

                    $childUser = array();
                    foreach ($userGroup[$group['groupid']] as $userid => $user) {
                        $tmp_userid = $user['userid'];
                        $extra_name = $user['status'] == 'Inactive' ? '<span style="color: red;">('.getFixedLabel('Quit').')</span>':'';
                        $target_value = $user_total_by_month_arr[$tmp_userid]['target'];
                        $finish_value = $user_total_by_month_arr[$tmp_userid]['finish'];
                        if($target_value !=0 || $finish_value !=0){
                            $percent = self::calPercent($finish_value,$target_value);

                            $height_info = $this->getTargetHegiht($percent);
                            $tolookheight = $height_info['tolook'];
                            $completeheight = $height_info['complete'];
                            $colorpercent = $height_info['color'];
                            $tempuser = array(
                                'type'=>'1',
                                'name' => $userarr[$user['userid']],
                                'extra_name'=>$extra_name,
                                'pinpai'=>"",
                                'targetid'=>'',
                                'search_date'=>'',
                                'record_str'=>$user['userid'],
                                'tolookheight'=> $tolookheight,
                                'completeheight'=> $completeheight,
                                'colorpercent'=> $colorpercent,
                                'tolook'=>$this->getShowValue(($target_value-$finish_value),$demcial,$datatype,$mode,$targetid),
                                'complete'=>$this->getShowValue($finish_value,$demcial,$datatype,$mode,$targetid),
                                'percent'=>number_format($percent,2),
                            );
                            $childUser['user' . $user['userid']] = $tempuser;
                            //品牌
                            $pinpaiData = $user_total_by_month_arr[$tmp_userid]['children'];
                            if(!empty($pinpaiData)){
                                $childPinpai=array();
                                foreach ($pinpaiData as $ppname => $onePinpai) {
                                    $pp_target_value = $onePinpai['target'];
                                    $pp_finish_value = $onePinpai['finish'];

                                    $pp_percent = self::calPercent($pp_finish_value,$pp_target_value);

                                    $height_info = $this->getTargetHegiht($pp_percent);
                                    $tolookheight = $height_info['tolook'];
                                    $completeheight = $height_info['complete'];
                                    $colorpercent = $height_info['color'];
                                    $temppinpai = array(
                                        'type'=>'1',
                                        'name' => $ppname,
                                        'extra_name'=>'',
                                        'pinpai'=>$ppname,
                                        'targetid'=>'',
                                        'search_date'=>'',
                                        'record_str'=>$user['userid'],
                                        'tolookheight'=> $tolookheight,
                                        'completeheight'=> $completeheight,
                                        'colorpercent'=> $colorpercent,
                                        'tolook'=>$this->getShowValue(($pp_target_value-$pp_finish_value),$demcial,$datatype,$mode,$targetid),
                                        'complete'=>$this->getShowValue($pp_finish_value,$demcial,$datatype,$mode,$targetid),
                                        'percent'=>number_format($pp_percent,2),
                                    );
                                    $childUser['user' . $user['userid']]['children'][] = $temppinpai;
                                }

                            }
                        }
                    }
                    self::treeChildrenValue($data, $parentGroup, $childUser,$topParentid,$this->groupseq_arr);
                }
            }
        }
        self::formateArray($data);
        return ldcrm_json_encode($data);
    }

    //通过targetid返回转换后的值
    public function getConversionValue($value,$targetid){
        $conversion_rate=1;
        $conversion_value = $value*$conversion_rate;
        return $conversion_value;
    }
    //将子部门中的目标添加到上一级部门中
    public function resetGroupData($sort_groups,$maxdepth,&$group_total_by_month_arr){
        //记录已经统计过的用户ID,避免一个用户在多个部门中被多次计算--//先不考虑多部门 有bug再改把 --todo--
        foreach ($sort_groups as $k=>$tmp_arr){
            $tmpdepth = $tmp_arr['depth'];
            if($tmpdepth==$maxdepth){
                $tmppid = $tmp_arr['parentid'];
                if($tmppid==-1){
                    return $group_total_by_month_arr;
                }
                $tmpgroupid = $tmp_arr['groupid'];
                if(isset($group_total_by_month_arr[$tmpgroupid])){
                    $tmpchildinfo = $group_total_by_month_arr[$tmpgroupid];
                    $group_total_by_month_arr[$tmppid]['target'] += 0;
                    if($tmpchildinfo['target']>0){
                        $group_total_by_month_arr[$tmppid]['target'] += $tmpchildinfo['target'];
                    }
                    $group_total_by_month_arr[$tmppid]['finish'] += 0;
                    if($tmpchildinfo['finish']>0){
                        $group_total_by_month_arr[$tmppid]['finish'] += $tmpchildinfo['finish'];
                    }
                }
                unset($sort_groups[$k]);
            }
        }
        $sort_groups = array_values($sort_groups);
        $new_maxdepth = $sort_groups[0]['depth'];

        $this->resetGroupData($sort_groups,$new_maxdepth,$group_total_by_month_arr);
    }
    public static function getGroupNew($sqlvar_selectbumen){
        global $adb;
        //获取最大的groupseq 值
        $tmp_sql = "SELECT MAX(groupseq) as maxseq from ld_groups";
        $tmp_result = $adb->pquery($tmp_sql);
        if($adb->num_rows($tmp_result)>0){
            $maxseq = $adb->query_result($tmp_result,0,'maxseq');
        }

        $query ='SELECT
        groupid,groupname,parentgroup,parentid,depth,groupseq
FROM
		ld_groups where find_in_set(groupid,?)
ORDER BY 
		depth,groupseq,groupid';
//        $query = 'SELECT groupid,userid FROM ld_users2group WHERE userid IN ('.$usersId .')  ORDER BY groupid';
        $result = $adb->pquery($query,array($sqlvar_selectbumen));
        $groups=array();
        //edit: xll 2024/01/02 BUG0078098 目标管理树状图顺序seq导致数据错乱
        for ($i = 0; $i < $adb->num_rows($result); $i ++){
            $row = $adb->fetch_array($result);
            $groups[$i] = $row;
            //树状图显示是从下往上，所以获取顺序的时候要逆序
            $groups[$i]['groupseq'] = $maxseq - $row['groupseq'] + 1;
        }
        return $groups;
    }
    public function getTargetAndOverArr($userarr,$usersGroup,$targetDataInfo,$overDataInfo){
        $user_total_by_month_arr = []; //每个用户在所有月份的合计
        $group_total_by_month_arr = []; //每个部门在所有月份的合计

        foreach($userarr as $uid=>$uname){
            $user_total_by_month_arr[$uid] = [
                'uid'=>$uid,
                'uname'=>$uname,
                'target'=>0,
                'finish'=>0,
                'children'=>[
                    //'品牌1'=>[
                    //'target'=>0,
                    //'finish'=>0,
                    // ]
                ]
            ];
            //目标
            if(isset($targetDataInfo[$uid])){
                $oneuser_target = $targetDataInfo[$uid];
                $tmpuser_target = 0;
                foreach($oneuser_target as $tmppinpai=>$lineTarget){
                    $tmpuser_target += $lineTarget;

                    $user_total_by_month_arr[$uid]['children'][$tmppinpai]['target'] = $lineTarget;
                    if(!isset($user_total_by_month_arr[$uid]['children'][$tmppinpai]['finish'])){
                        $user_total_by_month_arr[$uid]['children'][$tmppinpai]['finish'] = 0;
                    }
                }
                $user_total_by_month_arr[$uid]['target'] = $tmpuser_target;
            }
            //完成值
            if(isset($overDataInfo[$uid])){
                $oneuser_over = $overDataInfo[$uid];
                $tmpuser_over = 0;
                foreach($oneuser_over as $tmppinpai=>$lineOver){
                    $tmpuser_over += $lineOver;

                    $user_total_by_month_arr[$uid]['children'][$tmppinpai]['finish'] = $lineOver;
                    if(!isset($user_total_by_month_arr[$uid]['children'][$tmppinpai]['target'])){
                        $user_total_by_month_arr[$uid]['children'][$tmppinpai]['target'] = 0;
                    }
                }
                $user_total_by_month_arr[$uid]['finish'] = $tmpuser_over;
            }
        }

        foreach($usersGroup as $groupid =>$tmpuserarr){
            $tmpgroup_target = 0;
            $tmpgroup_over = 0;
            foreach($tmpuserarr as $index =>$tmpuser){
                $tmpuid = $tmpuser['userid'];
                if(isset($user_total_by_month_arr[$tmpuid])){
                    $tmpusertarget = $user_total_by_month_arr[$tmpuid];
                    if(isset($tmpusertarget['target'])){
                        $tmpgroup_target += $tmpusertarget['target'];//部门的目标值
                    }
                    if(isset($tmpusertarget['finish'])) {
                        $tmpgroup_over += $tmpusertarget['finish'];//部门的完成值
                    }
                }

            }
            $group_total_by_month_arr[$groupid] = [
                'target'=>$tmpgroup_target,
                'finish'=>$tmpgroup_over,
            ];
        }
        return [
            'group_total_by_month_arr'=>$group_total_by_month_arr,
            'user_total_by_month_arr'=>$user_total_by_month_arr,
        ];
    }
    //获取完成值信息 按人 按品牌 2层数组 人是第一层 品牌第二层  不按月了,算的是时间内的综合
    public function getSalesGoalOverInfoNew(){
        $uids = $this->params['sqlvar_selectuser'];
        $pinpai_arr = $this->params['sqlvar_pinpai'];

        $startdate = $this->params['sqlvar_startdate'];
        $enddate = $this->params['sqlvar_enddate'];

        $params = array($uids,$startdate,$enddate);
        $pinpaisql = '';
        if(!empty($pinpai_arr)){
            $pinpai = implode(',',$pinpai_arr);
            $params[] = $pinpai;
            //$pinpaisql = " and ifnull(pscf.cf_7752,'')=? ";
            $pinpaisql = " and find_in_set(ifnull(pscf.cf_7752,''),?) ";
        }


        $overSql = "SELECT
	sum(
		ifnull(sdetail.tax_amount, 0)) AS tax_amount,s.smownerid,pscf.cf_7752 as pinpai
		FROM
			ld_salesorder s
		LEFT JOIN ld_salesorderdetail sdetail ON sdetail.id = s.salesorderid
		left join ld_productcf pscf on pscf.productid=sdetail.productid
		WHERE
			s.deleted = 0
        AND find_in_set(s.smownerid,?) 
		AND s.signed_data BETWEEN ?
		AND ?
		$pinpaisql
group by s.smownerid,pscf.cf_7752;";

        $overRes = $this->adb->pquery($overSql,$params);
        $overNums = $this->adb->num_rows($overRes);
        $overArr = [];
        if($overNums>0){
            for($i=0;$i<$overNums;$i++){
                $uid = $this->adb->query_result($overRes,$i,'smownerid');
                $pinpai = $this->adb->query_result($overRes,$i,'pinpai');
                $tax_amount = $this->adb->query_result($overRes,$i,'tax_amount');
                if(!isset($overArr[$uid])){
                    $overArr[$uid] = [];
                }
                if(!isset($overArr[$uid][$pinpai])){
                    $overArr[$uid][$pinpai] = $tax_amount;
                }
            }
        }
        return $overArr;

    }
    //获取目标值信息  按人 按品牌 2层数组 人是第一层 品牌第二层  不按月了,算的是时间内的综合
    public function getTargetDataInfoNew(){
        $uids = $this->params['sqlvar_selectuser'];
        $pinpai_arr = $this->params['sqlvar_pinpai'];

        $sqlvar_targetyear = urldecode($this->params['sqlvar_targetyear']);//目标年度

        $startdate = $this->params['sqlvar_startdate'];
        $enddate = $this->params['sqlvar_enddate'];
        $params = array($sqlvar_targetyear,$uids);
        $pinpaisql = '';
        if(!empty($pinpai_arr)){
            $pinpai = implode(',',$pinpai_arr);
            $params[] = $pinpai;
            //$pinpaisql = " and ifnull(billscf.cf_7872,'')=? ";
            $pinpaisql = " and find_in_set(ifnull(billscf.cf_7872,''),?) ";
        }

        //求目标值 条件是:目标年度 品牌 人员等条件 不需要显示时间
        $targetSql = "select sum(ifnull(detailscf.sf718,0))as targetsum,u.id as uid,billscf.cf_7872 as pinpai from ld_users  u 
left join ld_minusjobbilldetailscf detailscf on u.id=detailscf.sf716
left join ld_minusjobbilldetail detail on detail.lineitem_id=detailscf.lineitem_id
left join ld_minusjobbillscf billscf on billscf.minusjobbillid=detail.id
left join ld_minusjobbill bill on bill.minusjobbillid=billscf.minusjobbillid

where u.deleted=0 
and bill.deleted=0 
and billscf.cf_7929=?
and find_in_set(detailscf.sf716,?) 

$pinpaisql
group by u.id,billscf.cf_7872";

        $targetRes = $this->adb->pquery($targetSql,$params);
        $targetNums = $this->adb->num_rows($targetRes);

        $targetArr = [];
        if($targetNums>0){
            for($i=0;$i<$targetNums;$i++){
                $uid = $this->adb->query_result($targetRes,$i,'uid');
                $pinpai = $this->adb->query_result($targetRes,$i,'pinpai');
                $targetsum = $this->adb->query_result($targetRes,$i,'targetsum');
                if(!isset($targetArr[$uid])){
                    $targetArr[$uid] = [];
                }
                if(!isset($targetArr[$uid][$pinpai])){
                    $targetArr[$uid][$pinpai] = $targetsum;
                }
            }
        }

        return $targetArr;
    }
    public function getTagetMonthArr(){
        $startdate = $this->params['sqlvar_startdate'];
        $enddate = $this->params['sqlvar_enddate'];
        require_once ('include/DateOperation.php');
        $datearr = DateOperation::get_months($startdate,$enddate);//这个是包含每个月的开始时间和结束时间的  我这边只需要 年月
        $montharr = [];
        foreach($datearr as $tmpdatearr){
            $montharr[] = date('Y-m',strtotime($tmpdatearr['month_start_day']));
        }
        return $montharr;
    }

    public function getBumenInfo(){
        $bumenSql = " select  groupid,groupname from ld_groups where parentgroup like '1::44%' or groupid=1 ";
        $bumenRes = $this->adb->pquery($bumenSql);
        $bumenRows = $this->adb->num_rows($bumenRes);
        $bumenids = '';
        $bumennames = '';

        if($bumenRows>0){
            $bumenids_arr = [];
            $bumennames_arr = [];
            for($i=0;$i<$bumenRows;$i++) {
                $bumenids_arr[] = $this->adb->query_result($bumenRes, $i, 'groupid');
                $bumennames_arr[] = $this->adb->query_result($bumenRes, $i, 'groupname');
            }
            $bumenids = implode(',',$bumenids_arr);
            $bumennames = implode(',',$bumennames_arr);
        }
        return ['bumenids'=>$bumenids,'bumennames'=>$bumennames];
    }
    //获取成员信息  数据格式是一维数组 键是userid 值last_name //20241125 人员默认显示销售部所有人
    public function getUsersInfo(){
        $selectuser = $this->params['sqlvar_selectuser'];//选择的用户ID 界面传过来的
        $selectbumen = $this->params['sqlvar_selectbumen'];
        //如果没传这个参数 按合同订单的数据范围
        if(empty($selectuser)){
            crm_load_class_file('ScopOfAuthority','include/ScopOfAuthority');
            $ModuleScopeObj = new ScopOfAuthority($this->adb, 'SalesOrder');
            $selectuser = $ModuleScopeObj->getCurUserScopeIds();
        }
        $user_sql = "select u.last_name,u.id from ld_users u left join ld_users2group u2g on u.id=u2g.userid where u.id  in (".$selectuser.") and u2g.groupid in (".$selectbumen.") ";

        $user_res = $this->adb->pquery($user_sql,array());
        $user_nums = $this->adb->num_rows($user_res);
        $user_arr = [];
        if($user_nums>0) {
            for($i=0;$i<$user_nums;$i++){
                $tmpuid = $this->adb->query_result($user_res, $i, 'id');
                $tmpuname = $this->adb->query_result($user_res, $i, 'last_name');
                $user_arr[$tmpuid] = $tmpuname;
            }
        }
        return $user_arr;

    }

    ///获取部门的树结构数组
    public  function getUserGroupNew($users){
        if(empty($users)) return '';
        if(isset($users['undefind'])) return '';

        global $adb;
        require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
        $userGroup=array();
        $this->groupseq_arr = [];
        $usersId = implode(',',array_keys($users));
        $query ='SELECT
		IFNULL(ld_groups.groupid,0) groupid,
		ld_users.id userid,
		ld_users.status,
		ld_groups.groupname,
		ld_groups.parentgroup,
		ld_groups.parentid,
		ld_groups.depth,
        ld_groups.groupseq 
FROM
		ld_users
		LEFT JOIN ld_users2group on ld_users.id = ld_users2group.userid
		LEFT JOIN ld_groups  ON ld_users2group.groupid = ld_groups.groupid
WHERE
		ld_users.id IN ('.$usersId.')
ORDER BY 
		ld_groups.depth asc,ld_groups.groupseq asc,ld_groups.groupid,ld_users.id';
        $result = $adb->pquery($query,array());
        //获取最大的groupseq 值
        $tmp_sql = "SELECT MAX(groupseq) as maxseq from ld_groups";
        $tmp_result = $adb->pquery($tmp_sql);
        if($adb->num_rows($tmp_result)>0){
            $maxseq = $adb->query_result($tmp_result,0,'maxseq');
        }
        $tmp_seq = 0;
        $before_depth = 0;
        while($row = $adb->fetch_array($result)){
            if($before_depth != $row['depth']){
                $tmp_seq = 0;
            }
            $tmp_seq ++;

            $groupobj=new Group();
            if($row['groupname'] == '' && $row['groupid'] == 0){
                continue;
            }
            $groupobj->groupid=$row['groupid'];
            $groupobj->groupname=$row['groupname'];
            $row['groupname']=getWx_GroupName($groupobj);
            $userGroup[$row['groupid']][] =$row;
            //edit:duan date:2024/10/23 reason:特殊处理客户001中groupseq为0的情况
            if($row['groupseq'] == 0){
                $cur_seq = $tmp_seq;
            }else{
                $cur_seq = $row['groupseq'];
            }
            //树状图显示是从下往上，所以获取顺序的时候要逆序
            $this->groupseq_arr[$row['groupid']] = $maxseq - $cur_seq +1;

            $before_depth = $row['depth'];
        }
        return $userGroup;
    }


}