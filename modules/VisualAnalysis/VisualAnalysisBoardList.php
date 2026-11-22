<?php

class VisualAnalysisBoardList
{
    public $module = 'VisualAnalysis' ;     //来源模块  目前看板首页和可视化分析都会调用这个类 要区分
    public $ShowType ;                      //列表展示类型
    public $BoardType ;                     //看板类型，即选择页签的值
    public $BoardTypeList ;                 //看板类型列表，包括看板类型标签和看板数量，其中看板数量为数组（键值为看板id，值为yes）
    public $BoardList ;                     //看板列表
    public $BoardListSQL ;                  //看板列表的SQL
    public $all_relatd_scope_list ;         //看板分配列表
    public $UserBoardList ;                 //当前用户收藏和最近浏览的看板列表
    public $cur_userid ;                    //当前用户id
    public $SearchBoardList ;               //搜索结果看板列表
    public function __construct($module,$BoardType){
        global $current_user;
        $this->cur_userid = $current_user->id;
        $this->module = $module;
        $this->BoardType = $BoardType;
        $this->BoardTypeList = $this->get_BoardTypeList();
        crm_load_class_file("cls_related_scope",'include/utils');
        $this -> all_relatd_scope_list = cls_related_scope::get_all_related_scope($module,'Homeboard_scope');
    }



    //根据类型获取看板列表
    public function getBoardListByType($BoardType = ''){
        global $adb;
        $cur_userid = $this->cur_userid;
        $module = $this->module;
        if($BoardType == '')
            $BoardType =  $this->BoardType;
        $BoardList = [];
        //zxm 20231018 移动端看板 显示默认看板
        if($module=='MobileReport'){
            $deploy_arr = getSys_deploy(487,'yes');
            //移动端老看板删除  只有移动端老看板的id是-100 更改ld_systems_deploy表type是487的value为no
            if($deploy_arr['deploy_value']!='no'){
                $BoardList[-100] = array(
                    'boardid'=>-100,
                    'boardname'=>'默认看板',
                    'description'=>'默认看板',
                    'modifiedby'=>'',
                    'modifiedtime'=>'',
                    'scope'=>'',
                    'icon_path'=>'',
                    'smcreatorid'=>0
                );
            }
        }
        $BoardTypeList = $this->BoardTypeList;
        $sql_select = $this -> getBoardListSQLByType($BoardType);
        $result_select = $adb->pquery($sql_select,array($module));

        if($adb->num_rows($result_select) > 0){
            $UserBoardList = $this->get_UserAllBoard();

            for($i =0;$i<$adb->num_rows($result_select);$i++){
                $boardid = $adb->query_result($result_select,$i,'boardid');
                $scope = $adb->query_result($result_select,$i,'scope');
                $smcreatorid= $adb->query_result($result_select,$i,'smcreatorid');

                //全部类型中都需去掉 非当前用户创建的 和 未分配给当前用户的
                if(!$this->is_userScopeBoard($scope,$boardid) && $smcreatorid != $cur_userid)
                    continue;
                if($UserBoardList['view'][$boardid] == 'yes'){
                    $BoardTypeList['Recently']['num'][$boardid] = 'yes';
                }
                if($smcreatorid == $this->cur_userid){
                    $BoardTypeList['Created']['num'][$boardid] = 'yes';
                }
                if($UserBoardList['collect'][$boardid] == 'yes'){
                    $BoardTypeList['Collection']['num'][$boardid] = 'yes';
                }

                if($this->is_userScopeBoard($scope,$boardid) && $smcreatorid != $cur_userid){
                    $BoardTypeList['Scope']['num'][$boardid] = 'yes';
                }
                $BoardTypeList['All']['num'][$boardid] = 'yes';
                if($BoardTypeList[$BoardType]['num'][$boardid] == 'yes'){
                    //zxm 20230905 可视化分析看板没有封面则显示默认封面
                    $icon_path = $adb->query_result($result_select,$i,'icon_path');
                    //如果属于选中的类型则将看板信息放入$BoardList
                    $BoardList[$boardid] = array(
                        'boardid'=>$boardid,
                        'boardname'=>$adb->query_result($result_select,$i,'boardname'),
                        'boardtype'=>$adb->query_result($result_select,$i,'boardtype'),
                        'description'=>$adb->query_result($result_select,$i,'description'),
                        'modifiedby'=>getUserFullName($adb->query_result($result_select,$i,'userid')),
                        'modifiedtime'=>$adb->query_result($result_select,$i,'modifiedtime'),
                        'scope'=>$scope,
                        'icon_path'=>empty($icon_path)?'themes/images/visualanalysisdefault.png':$icon_path,
                        'smcreatorid'=>$adb->query_result($result_select,$i,'smcreatorid')
                    );
                    $scope_list_str = '';
                    if($scope != 'all'){
                        $scope_list = $this -> all_relatd_scope_list[$boardid];
                        if(!empty($scope_list)&&is_array($scope_list))
                            $scope_list_str = implode(',',$scope_list);
                    }
                    $BoardList[$boardid]['scopeid'] = $scope_list_str;
                    $isCollect = ($UserBoardList['collect'][$boardid] == 'yes') ? 'yes' : 'no';
                    $BoardList[$boardid]['isCollect'] = $isCollect;
                }
            }
        }


        if($BoardType == $this->BoardType){
            $this->BoardList = $BoardList;
            $this->BoardTypeList =$BoardTypeList;
        }
        return $BoardList;
    }

    //根据类型获取看板列表的SQL
    public function getBoardListSQLByType($type = ''){
        if(isset($this -> BoardListSQL))
            return $this -> BoardListSQL;
        $cur_userid = $this->cur_userid;
        if($type == '')
            $type =  $this->BoardType;
        $sql_select_head = "select h.boardtype,h.boardid,h.boardname,h.description,u.last_name,u.id as userid,h.modifiedtime,h.scope,h.icon_path,h.smcreatorid from ld_homeboard h LEFT JOIN ld_users u on h.modifiedby = u.id ";
        $where = "where h.deleted = 0 and ifnull(h.boardname,'')<>'' and h.boardtype = ? order by h.sequence ASC";
        /*
        if($type == 'Recently'){
            $sql_select_head .= ' INNER JOIN ld_operation_log  g on h.boardid = g.crmid and g.action = \'view\'';
            $where .= ';';
        }else if($type == 'Created'){
            $where .= 'and h.smcreatorid = ' . $cur_userid . ';';
        }else if($type == 'Collection'){
            $sql_select_head .= ' INNER JOIN ld_operation_log  g on h.boardid = g.crmid and g.operator = ' . $cur_userid . ' and g.action = \'collect\'';
            $where .= ';';
        }else if($type == 'Scope'){
            $where .= 'and h.smcreatorid <> ' . $cur_userid . ';';
        }else{
            //默认全部类型（包括我创建的、分配给我的，即去掉未分配给我的
        }
        */
        $where .= ';';
        $sql_select = $sql_select_head.$where;

        if($type == $this->BoardType)
            $this -> BoardListSQL = $sql_select;

        return $sql_select;
    }

    //判断是否是分配给用户的看板
    public function is_userScopeBoard($scope,$boardid){
        global $current_user;

        if($scope == 'all'){
            $isscope = true;
        }else{
            $isscope = false;
            $relatd_scope_list = $this -> all_relatd_scope_list[$boardid];

            if($scope == 'group'){
                /*if(in_array($current_user->groupid,$relatd_scope_list)){
                    $isscope = true;
                }*/
                //按部门
                $usergroupids_arr = explode(',',$current_user->groupid);
                if(!empty($relatd_scope_list)&&is_array($relatd_scope_list)){
                    $usergroupids_arr_intersect = array_intersect($usergroupids_arr,$relatd_scope_list);
                }else{
                    $usergroupids_arr_intersect = $usergroupids_arr;
                }

                
                if(!empty($usergroupids_arr_intersect)){
                    $isscope = true;
                }else{
                    $isscope = false;
                }
            }elseif($scope == 'user'){
                if(is_array($relatd_scope_list)&&in_array($current_user->id,$relatd_scope_list)){
                    $isscope = true;
                }
            }elseif($scope == 'role'){
                if(is_array($relatd_scope_list)&&in_array($current_user->profileid,$relatd_scope_list)){
                    $isscope = true;
                }
            }
        }
        return $isscope;
    }

    //获取用户的 所有收藏看板 和 所有最近浏览看板
    public function get_UserAllBoard(){
        global $adb;
        if(isset($this -> UserBoardList))
            return $this -> UserBoardList;
        $UserBoardList = [];
        $operator = $this->cur_userid;;
        $module = $this->module;
        $sql = 'select * from `ld_operation_log` where `operator` = ? and `module` = ?;';
        $result = $adb->pquery($sql,array($operator,$module));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i =0;$i<$num_rows;$i++) {
                $boardid = $adb->query_result($result, $i, 'crmid');        //日志表的crmid对应boardid
                $actiontype = $adb->query_result($result, $i, 'action');    //日志表的action对应收藏和浏览类型
                $UserBoardList[$actiontype][$boardid] = 'yes';
            }
        }
        $this -> UserBoardList = $UserBoardList;
        return $UserBoardList;
    }

    //获取看板类型的数组
    public function get_BoardTypeList(){
        $BoardType_array = ['All','Recently','Created','Collection','Scope'];
        $BoardTypeList = [];
        foreach ($BoardType_array as $tmpBoardType){
            $BoardTypeList[$tmpBoardType]['num'] = [];
            if($tmpBoardType == 'All')
                $BoardTypeList[$tmpBoardType]['label'] = getFixedLabel('ALL');
            else if($tmpBoardType == 'Recently')
                $BoardTypeList[$tmpBoardType]['label'] = getFixedLabel('RECENTLYVISITED');
            else if($tmpBoardType == 'Created')
                $BoardTypeList[$tmpBoardType]['label'] = getFixedLabel('Icreated');
            else if($tmpBoardType == 'Collection')
                $BoardTypeList[$tmpBoardType]['label'] = getFixedLabel('MYCOLLECTION');
            else if($tmpBoardType == 'Scope')
                $BoardTypeList[$tmpBoardType]['label'] = getFixedLabel('ASSIGNEDTOME');
            else
                continue;
        }
        /*
        if($this->BoardType == 'All')
            $tmpBoardList = $this->BoardList;
        else
            $tmpBoardList = $this->getBoardListByType('All');
        $UserBoardList = $this -> UserBoardList;
        foreach ($tmpBoardList as $boardid => $boardinfo){
            if($UserBoardList['view'][$boardid] == 'yes'){
                $BoardTypeList['Recently']['num'] += 1;
            }
            else if($UserBoardList['collect'][$boardid] == 'yes'){
                $BoardTypeList['Collection']['num'] += 1;
            }
            else if($this->is_userScopeBoard($boardinfo['scope'],$boardid)){
                $BoardTypeList['Scope']['num'] += 1;
            }else if($boardinfo['smcreatorid'] == $this->cur_userid){
                $BoardTypeList['Created']['num'] += 1;
            }
        }
        */
        //$BoardTypeList['All']['num'] = count($tmpBoardList);
        return $BoardTypeList;
    }

    //获取看板搜索类型的数组
    public function getBoardBySearchTypeList(){
        $SearchTypeArray = ['all','boardname','description','modifiedby'];
        $SearchTypeList = [];
        foreach ($SearchTypeArray as $Type){
            if($Type == 'all')
                $SearchTypeList[$Type] = getFixedLabel('ALL');
            else if($Type == 'boardname')
                $SearchTypeList[$Type] = getFixedLabel('TEMLATENAME');
            else if($Type == 'description')
                $SearchTypeList[$Type] = getFixedLabel('DESCRIPTION');
            else if($Type == 'modifiedby')
                $SearchTypeList[$Type] = getFixedLabel('MODIFIEDBY');
            else if($Type == 'stuffname')
                //暂时不做
                $SearchTypeList[$Type] = getFixedLabel('REPORTCOMPONENTNAME');
            else
                continue;
        }
        return $SearchTypeList;
    }

    //根据搜索值获取看板列表
    public function getBoardListBySearchValue($SearchType=''){
        if($SearchType == '')
            $SearchType = $_REQUEST['SearchType'];
        $SearchValue = $_REQUEST['SearchValue'];
        $tmpBoardList = $this->BoardList;
        if($SearchValue == ''){
            return $tmpBoardList;
        }
        if($SearchType == 'all'){
            //递归修改$this->SearchBoardList
            $this->getBoardListBySearchValue('boardname');
            $this->getBoardListBySearchValue('description');
            $this->getBoardListBySearchValue('modifiedby');
        }
        else if($SearchType == 'boardname' || $SearchType == 'description'|| $SearchType == 'modifiedby'){

            foreach ($tmpBoardList as $tmpboardid => $tmpboardinfo){
                $tmpvalue = $tmpboardinfo[$SearchType];
                if(stripos($tmpvalue,$SearchValue) !== false){
                    $this->SearchBoardList[$tmpboardid] = $tmpboardinfo;
                }
            }
        }
        else if($SearchType == 'stuffname'){
            foreach ($tmpBoardList as $tmpboardid => $tmpboardinfo){
                $tmpboarddescription = $tmpboardinfo['description'];
                if(stripos($tmpboarddescription,$SearchValue)){
                    $this->SearchBoardList[$tmpboardid] = $tmpboardinfo;
                }
            }
        }
        else{

        }
        return $this->SearchBoardList;
    }

    //获取当前用户该模块的权限列表
    public function get_PermitList(){
        $module = $this->module;
        $permitlist = ["Create","EditView","Delete","Allocate"];
        $permit_array =[];
        foreach ($permitlist as $permit){
            $permit_array[$permit] = isPermitted($module,$permit);
        }
        if(in_array('yes',array_slice($permit_array,1)))
            $permit_array["Manage"] = 'yes';
        else
            $permit_array["Manage"] = 'no';

        return $permit_array;
    }

    //获取列表视图中的表格各列宽度
    public function get_ListHeader(){
        $WidthList = ['30%','30%','10%','15%','15%'];
        $LabelList = array(getFixedLabel('TEMLATENAME'),getFixedLabel('DESCRIPTION'),
            getFixedLabel('MODIFIEDBY'),getFixedLabel('MODIFIEDTIME'),getFixedLabel('OPERATING'));
        $HeaderList = [];
        foreach($WidthList as $key=>$Width){
            $HeaderList[$key]['width'] = $Width;
            $HeaderList[$key]['label'] = $LabelList[$key];
        }
        return $HeaderList;
    }
}