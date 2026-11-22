<?php


class Homeboard
{
    public $DatarangeSetList = [];
    public $boardid ;
    public $frommodule = 'Home' ;//来源模块  目前看板首页和可视化分析都会调用这个类 要区分
    public $all_relatd_scope_list ;//看板分配列表
    public $BoardListSQL; //看板列表的SQL
    public $DatarangeSetListDefault; //组件设置的配置信息

    public $boardAllStuffNameList = [];//看板所有的组件名称  一个数组 不区分组件类型 仅用于经销商的设置界面显示

    public static $instance_Homeboard_arr;//单例子
    public static function getInstance($boardid,$frommodule){
        if(isset(self::$instance_Homeboard_arr[$frommodule.$boardid])){
            return self::$instance_Homeboard_arr[$frommodule.$boardid];
        }
        self::$instance_Homeboard_arr[$frommodule.$boardid]=new Homeboard($boardid,$frommodule);
        return self::$instance_Homeboard_arr[$frommodule.$boardid];
    }
    public function __construct($boardid,$frommodule){
        $this->boardid = $boardid;
        $this->frommodule = $frommodule;
    }
    public function getAllStuffInfo(){
        global $adb;
        $stuffsql = "select * from ld_stuff";
        $stuffres = $adb->pquery($stuffsql);
        $stuffnums = $adb->num_rows($stuffres);
        $stuffArr = [];
        if($stuffnums>0){
            for($i=0;$i<$stuffnums;$i++){
                $stuffid = $adb->query_result($stuffres,$i,'stuffid');
                $stuffArr[$stuffid] = $adb->query_result_rowdata($stuffres,$i);
            }
        }
        return $stuffArr;
    }
    public function getHomeBoardPlateStuff(){
        global $adb;
        $platestuffsql = 'select boardstuffid,stuffid,stufftype,height,stufftitle_zh,stufftitle_en,ld_homeboard_plate_stuff.plateid from ld_homeboard_plate_stuff
             left join ld_homeboard_plate on ld_homeboard_plate.plateid=ld_homeboard_plate_stuff.plateid
             where ld_homeboard_plate_stuff.boardid = ? order by ld_homeboard_plate.sequence asc ,ld_homeboard_plate_stuff.sequence asc;';
        $stuffres = $adb->pquery($platestuffsql,array($this->boardid));
        $stuffnums = $adb->num_rows($stuffres);
        $stuffArr = [];
        if($stuffnums>0){
            for($i=0;$i<$stuffnums;$i++){
                $plateid = $adb->query_result($stuffres,$i,'plateid');
                $stuffArr[$plateid][] = $adb->query_result_rowdata($stuffres,$i);
            }
        }
        return $stuffArr;
    }

    public function getHomeStuffList($from_module){
        global $adb;
        $default_stufflist = [];
        $homeboard_stufflist = $this->get_stuff_list();
        $wherestr = " where pc_show='yes' ";
        if($from_module=='MobileReport'||$from_module=='prmMobileHome'){
            $wherestr = " where mobile_show='yes'";
        }
        if ($from_module=='MobileReport'){
            $wherestr = " where mobile_show='yes' order by mobile_sequence";
        }
        if ($from_module=='Home'){
            $wherestr = " where pc_show='yes' order by pc_sequence";
        }
        $sql = 'select stuffid,stufftitle,stufftype,relatedmodule,datarangmodule from ld_stuff  '.$wherestr;
        $result = $adb->pquery($sql,array());

        if($adb->num_rows($result)>0){
            for($i = 0;$i<$adb->num_rows($result);$i++){
                $stuffid = $adb->query_result($result,$i,'stuffid');
                $relatedmodule = $adb->query_result($result,$i,'relatedmodule');

                if (file_exists(globalStatic::$root_directory.'modules/Home/HomeBoardNew/HomeBoardNew_'.$stuffid.'.php')) {
                    crm_load_class_file("HomeBoardNew_" . $stuffid, 'modules/Home/HomeBoardNew');
                    $classname = "HomeBoardNew_" . $stuffid;
                    $HomeBaordNewparentobj = new $classname();
                }else {
                    crm_load_class_file("HomeBoardNewParent",'modules/Home/HomeBoardNew');
                    $HomeBaordNewparentobj=new HomeBoardNewparent();
                }

                $isActive = true;
                if($relatedmodule != '') {
                    $tabs=explode(',',$relatedmodule);
                    $isActive = $HomeBaordNewparentobj->isActive($tabs);
                }
                if($isActive == true){
                    $stufftitle = $adb->query_result($result,$i,'stufftitle');
                    $datarangmodule = $adb->query_result($result,$i,'datarangmodule');
                    $default_stufflist[$stuffid] = array(
                        'stuffid'=>$stuffid,
                        'stufftitle'=>$stufftitle,
                        'stufftype'=>$adb->query_result($result,$i,'stufftype'),
                        'chart_type'=>'',
                        'stufftitle_label'=>$HomeBaordNewparentobj->get_stufftitle_lable($stufftitle),
                        'chose'=>'no'
                    );
                    if(is_array($homeboard_stufflist['defaultstuff']) && in_array($stuffid,$homeboard_stufflist['defaultstuff'])){
                        $default_stufflist[$stuffid]['chose'] = 'yes';
                    }
                    $this->DatarangeSetListDefault['defaultstuff_'.$stuffid] = $this->getDatarangeSetArr($datarangmodule,'defaultstuff',$stuffid,0,$stufftitle);
                }
            }
        }
        return $default_stufflist;
    }
    /**
     * @return void
     * 获取可以放首页的自定义统计图组件信息
     */
    public function getCustomEchartList(){
        global $adb;
        $homeboard_stufflist = $this->get_stuff_list();

        $custormreport_stufflist = [];
        //zxm 20230512 XUQIU1001246	统计表	报表分析->SQL统计图：增加设置，允许添加到首页组件中显示
        $sql = "select ld_customreport.report_id,ld_customreport.report_name,ld_customreport.report_type,ld_customreport_chartset.chart_type,ld_customreport.mainmodule  
from ld_customreport left join ld_customreport_chartset on 
    ld_customreport.report_id=ld_customreport_chartset.report_id where ld_customreport.deleted=0 and ld_customreport.show_athome='yes' order by ld_customreport.sequence asc";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        if($nums > 0){
            for($i=0;$i<$nums;$i++){
                $report_id = $adb->query_result($res,$i,'report_id');
                $report_type = $adb->query_result($res,$i,'report_type');
                $custormreport_stufflist['customEchart_'.$report_id] = array(
                    'stuffid'=>'customEchart_'.$report_id,
                    'stufftitle'=>$adb->query_result($res,$i,'report_name'),//getTranstab('CustomEcharts')
                    //zxm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type
                    'stufftype'=>$report_type,
                    'chart_type'=>$adb->query_result($res,$i,'chart_type'),
                    'stufftitle_label'=>$adb->query_result($res,$i,'report_name'),
                    'chose'=>'no'
                );
                if(is_array($homeboard_stufflist['customreport']) && in_array($report_id,$homeboard_stufflist['customreport'])){
                    $custormreport_stufflist['customEchart_'.$report_id]['chose'] = 'yes';
                }
                $mainmodule = $adb->query_result($res,$i,'mainmodule');
                if($report_type!='sqlchart'&&!vtlib_isModuleActive($mainmodule))continue;//主模块未激活 不显示
                $this->DatarangeSetListDefault['customEchart_'.$report_id] = $this->getDatarangeSetArr($mainmodule,$report_type,$report_id,0,'');
            }
        }
        return $custormreport_stufflist;
    }
    /**
     * @return void
     * 获取可以放首页的自定义统计图组件信息
     */
    public function getCustomTableList(){
        global $adb;
        $homeboard_stufflist = $this->get_stuff_list();

        $custormtable_stufflist = [];
        //zxm 20230512 XUQIU1001246	统计表	报表分析->SQL统计图：增加设置，允许添加到首页组件中显示
        $sql = "select ld_customtable.report_id,ld_customtable.report_name,ld_customtable.report_type,m.modulename as mainmodule  
from ld_customtable 
left join (select  * from ld_customtable_module where pathtype='mainmodule' group by report_id) m on m.report_id=ld_customtable.report_id
where ld_customtable.deleted=0 and ld_customtable.show_athome='yes' order by ld_customtable.sequence asc;
";
        $res = $adb->pquery($sql);
        $nums = $adb->num_rows($res);
        if($nums > 0){
            for($i=0;$i<$nums;$i++){
                $report_id = $adb->query_result($res,$i,'report_id');
                $report_type = $adb->query_result($res,$i,'report_type');//自定义统计表 还是 SQL统计表
                $custormtable_stufflist['customtable_'.$report_id] = array(
                    'stuffid'=>'customtable_'.$report_id,
                    'stufftitle'=>$adb->query_result($res,$i,'report_name'),//getTranstab('CustomEcharts')
                    //zxm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type
                    'stufftype'=>$report_type,
                    'chart_type'=>'',
                    'stufftitle_label'=>$adb->query_result($res,$i,'report_name'),
                    'chose'=>'no'
                );
                if(is_array($homeboard_stufflist['customtable']) && in_array($report_id,$homeboard_stufflist['customtable'])){
                    $custormtable_stufflist['customtable_'.$report_id]['chose'] = 'yes';
                }
                $mainmodule = $adb->query_result($res,$i,'mainmodule');
                if($report_type!='sql'&&!vtlib_isModuleActive($mainmodule))continue;//主模块未激活 不显示
                $this->DatarangeSetListDefault['customtable_'.$report_id] = $this->getDatarangeSetArr($mainmodule,$report_type,$report_id,0,'');
            }
        }
        return $custormtable_stufflist;
    }
    public function get_Homeboard_info($boardid){
        global $adb,$languageType,$current_user;
        //默认看板数组--一次性查出来 省的查很多次数据库
        $defaultStuffInfo = $this->getAllStuffInfo();
        $plateStuffInfo = $this->getHomeBoardPlateStuff();

        $Homeboard_content = [];
        $adb_select_board = 'select boardname,description,boardlayout,scope,timesearchdefault,approve_value,icon_path,boardtype from ld_homeboard where boardid = ? and deleted = 0';
        $result_select_board = $adb->pquery($adb_select_board,array($boardid));

        if($adb->num_rows($result_select_board)>0) {
            $Homeboard_content['boardname'] = $adb->query_result($result_select_board, 0, 'boardname');
            $Homeboard_content['boardtype'] = $adb->query_result($result_select_board, 0, 'boardtype');
            $Homeboard_content['description'] = $adb->query_result($result_select_board, 0, 'description');
            $Homeboard_content['boardlayout'] = $adb->query_result($result_select_board, 0, 'boardlayout');
            $Homeboard_content['scope'] = $adb->query_result($result_select_board, 0, 'scope');
            $Homeboard_content['timesearchdefault'] = $adb->query_result($result_select_board, 0, 'timesearchdefault');
            $Homeboard_content['approve_value'] = $adb->query_result($result_select_board, 0, 'approve_value');
            //edit: xll 2023/07/13 XUQIU1001446 增加“可视化分析”模块（增加看板图标）
            $Homeboard_content['icon_path'] = $adb->query_result($result_select_board, 0, 'icon_path');
            if($Homeboard_content['scope'] == 'all'){
                $Homeboard_content['scope_list'] = '';
            }else{
                crm_load_class_file("cls_related_scope",'include/utils');
                $Homeboard_content['scope_list'] = cls_related_scope::get_related_scope($this->frommodule,'Homeboard_scope',$boardid);
                $scope_list_str = '';
                if(count($Homeboard_content['scope_list']) >0){
                    $scope_list_str = implode(',',$Homeboard_content['scope_list']);
                }
                $Homeboard_content['scope_list_str'] = $scope_list_str;
            }

            $sql_select_plate = 'select plateid,platetype,platewidth from ld_homeboard_plate where boardid = ? order by sequence asc';
            $result_select_plate = $adb->pquery($sql_select_plate, array($boardid));

            $homeboard_plate = [];
            if ($adb->num_rows($result_select_plate) > 0) {
                for ($i = 0; $i < $adb->num_rows($result_select_plate); $i++) {
                    $plateid = $adb->query_result($result_select_plate, $i, 'plateid');
                    $homeboard_plate_stuff = [];
                    foreach($plateStuffInfo[$plateid] as $tmpplatestuff){
                            $tmpstufftype = $tmpplatestuff['stufftype'];
                            $stuffid = $tmpplatestuff['stuffid'];
                            $boardstuffid = $tmpplatestuff['boardstuffid'];//ld_homeboard_plate_stuff表的自增主键ID
                            $tmpdatarange_set = [];
                            if($tmpstufftype == 'defaultstuff'){
                                $tmpstuffinfo = $defaultStuffInfo[$stuffid];
                                $stufftitle = $tmpstuffinfo['stufftitle'];
                                $stufftype = $tmpstuffinfo['stufftype'];
                                $chart_type = '';
                                $stufftitle_label = getFixedLabel($stufftitle);//gxj 230706 BUG0069188 首页数据看板“日程管理”没有翻译
                                //英文翻译--没填写英文名称读取英文翻译 BUG20240802-38问题：组件设置的时候没有带名称过去，不知道在编辑哪一块内容（若有英文翻译，根据翻译带出；若无英文翻译时，中英文默认一致）
                                if(empty($tmpplatestuff['stufftitle_en'])&&file_exists(globalStatic::$root_directory . 'include/language/en.php')) {
                                    require_once(globalStatic::$root_directory . 'include/language/en.php');
                                    $cachelangfixedlabelinfo = $arrFixedLabel;
                                    if (isset($cachelangfixedlabelinfo[$stufftitle])) {
                                        $tmpplatestuff['stufftitle_en'] = $cachelangfixedlabelinfo[$stufftitle];
                                    }
                                }
                                //edit: xll 2024/03/14 BUG20240307-25 修改组件名称保存后进入编辑界面，预览界面组件名称没有更新
                                if (!empty($tmpplatestuff['stufftitle_' . $languageType])) {
                                    $stufftitle_label = $tmpplatestuff['stufftitle_' . $languageType];
                                }
                                //组件配置信息
                                $datarangmodule = $tmpstuffinfo['datarangmodule'];

                                $tmpmodunenum = 0;
                                if(empty($datarangmodule)){
                                    $tmpmodunenum = 1;
                                }else{
                                    $datarangmodule_arr = explode(',',$datarangmodule);
                                    foreach($datarangmodule_arr as $tmpmodule){
                                        if(vtlib_isModuleActive($tmpmodule)){
                                            $tmpmodunenum++;
                                        }
                                    }
                                }

                                if($tmpmodunenum==0)continue;//主模块未激活 不显示
                                $tmpdatarange_set = $this->getDatarangeSetArr($datarangmodule,$tmpstufftype,$stuffid,$boardstuffid,$stufftitle);
                            }elseif ($tmpstufftype == 'customreport'){
                                $sql = "select ld_customreport.report_name,ld_customreport.report_type,ld_customreport_chartset.chart_type,ld_customreport.mainmodule from ld_customreport left join ld_customreport_chartset on 
    ld_customreport.report_id=ld_customreport_chartset.report_id where ld_customreport.deleted=0 and ld_customreport.report_id = ? and ld_customreport.show_athome='yes'  ";
                                $result = $adb->pquery($sql,array($stuffid));

                                if($adb->num_rows($result)>0){
                                    $stufftitle = $adb->query_result($result,0,'report_name');
                                    //zxm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type
                                    $stufftype = $adb->query_result($result,0,'report_type');
                                    $chart_type = $adb->query_result($result,0,'chart_type');
                                    $stufftitle_label = $adb->query_result($result,0,'report_name');
                                    $report_type = $adb->query_result($result,0,'report_type');
                                    $mainmodule = $adb->query_result($result,0,'mainmodule');
                                    if($report_type!='sqlchart'&&!vtlib_isModuleActive($mainmodule))continue;//主模块未激活 不显示
                                    $tmpdatarange_set = $this->getDatarangeSetArr($mainmodule,$report_type,$stuffid,$boardstuffid,'');
                                }else{
                                    continue;
                                }
                            }elseif ($tmpstufftype == 'customtable'){
                                $sql = "select ld_customtable.report_id,ld_customtable.report_name,ld_customtable.report_type,m.modulename as mainmodule  from ld_customtable left join (select  * from ld_customtable_module where pathtype='mainmodule' group by report_id) m on m.report_id=ld_customtable.report_id where ld_customtable.deleted=0 and ld_customtable.report_id = ? and ld_customtable.show_athome='yes' order by ld_customtable.sequence asc";

                                $result = $adb->pquery($sql,array($stuffid));

                                if($adb->num_rows($result)>0){
                                    $stufftitle = $adb->query_result($result,0,'report_name');
                                    //zxm 20230510 自定义统计表放首页 首页请求需要report_type
                                    $stufftype = $adb->query_result($result,0,'report_type');
                                    $chart_type = '';
                                    $stufftitle_label = $adb->query_result($result,0,'report_name');
                                    $report_type = $adb->query_result($result,0,'report_type');
                                    $mainmodule = $adb->query_result($result,0,'mainmodule');
                                    if($report_type!='sql'&&!vtlib_isModuleActive($mainmodule))continue;//主模块未激活 不显示
                                    $tmpdatarange_set = $this->getDatarangeSetArr($mainmodule,$report_type,$stuffid,$boardstuffid,'');
                                }else{
                                    continue;
                                }
                            }
                            $tmpplatestuff['stufftitle_zh'] = empty($tmpplatestuff['stufftitle_zh'])?$stufftitle_label:$tmpplatestuff['stufftitle_zh'];
                            $tmpplatestuff['stufftitle_en'] = empty($tmpplatestuff['stufftitle_en'])?$stufftitle_label:$tmpplatestuff['stufftitle_en'];
                            $homeboard_plate_stuff[] = array(
                                'boardid'=>$boardid,
                                'boardstuffid'=>$boardstuffid,
                                'stuffid' => $stuffid,
                                'stufflisttype' => $tmpplatestuff['stufftype'],
                                //'height' => $Homeboard_content['boardtype']=='MobileReport'?'370':$tmpplatestuff['height'],//移动端看板不显示高度信息
                                'height' => $tmpplatestuff['height'],//XUQIU20240613-05 移动端工作台定制--增加组件高度设置，可以自由设置组件高度
                                'stufftitle_zh' => $tmpplatestuff['stufftitle_zh'],
                                'stufftitle_en' => $tmpplatestuff['stufftitle_en'],
                                'stufftitle' =>$stufftitle,
                                'stufftype'=>$stufftype,
                                'chart_type'=>$chart_type,//zxm 20230510 SQL统计图放首页 首页请求需要report_type和chart_type
                                'stufftitle_label'=>$stufftitle_label
                            );

                            $this->boardAllStuffNameList[] = $tmpplatestuff['stufftitle_'.$languageType];//看板所有的组件名称  一个数组 不区分组件类型 仅用于经销商的设置界面显示
                        //zxm 20230612 用键值方便索引到想要的组件数据
                        $key = 'defaultstuff_'.$stuffid;
                        if($tmpstufftype=='customreport'){
                            $key = 'customEchart_'.$stuffid;
                        }
                        if($tmpstufftype=='customtable'){
                            $key = 'customtable_'.$stuffid;
                        }

                            $this->DatarangeSetList['plate_'.$plateid][$key] = $tmpdatarange_set;
                        }

                    $homeboard_plate[] = array(
                        'plateid' => $plateid,
                        'platetype' => $adb->query_result($result_select_plate, $i, 'platetype'),
                        'platewidth' => $adb->query_result($result_select_plate, $i, 'platewidth'),
                        'platewidth_stylewidth' => $this->get_plate_stylewidth($adb->query_result($result_select_plate, $i, 'platewidth')),
                        'homeboard_plate_stuff' => $homeboard_plate_stuff
                    );
                }
            }
            $Homeboard_content['homeboard_plate'] = $homeboard_plate;
        }

        //增加根据用户审批状态设置,获取记忆值功能
        if (empty($userid)) $userid=$current_user->id;
        $adb_select_board2 = 'select content from ld_module_setting_byuser where type = ? and userid = ? and label="lastChangeApproveByUser"';
        $result_select_board2 = $adb->pquery($adb_select_board2,array($boardid,$userid));
        if($adb->num_rows($result_select_board2)>0){
            $Homeboard_content['approve_value'] = $adb->query_result($result_select_board2, 0, 'content');
        }

        //增加根据用户时间范围设置,获取记忆值功能
        $adb_select_board2 = 'select content from ld_module_setting_byuser where type = ? and userid = ? and label="lastChangeTimeByUser"';
        $result_select_board2 = $adb->pquery($adb_select_board2,array($boardid,$userid));
        //如果用户记忆值是自定义时间范围,读取具体时间范围,并将$Homeboard_content['timesearchdefault']更新为custom
        $Homeboard_content['customDateValue']='';
        if($adb->num_rows($result_select_board2)>0){
            $Homeboard_content['timesearchdefault'] = $adb->query_result($result_select_board2, 0, 'content');
            if (strpos($Homeboard_content['timesearchdefault'], 'custom') !== false) {
                // 如果包含custom
                list($prefix, $dates) = explode(':', $Homeboard_content['timesearchdefault'], 2);
                $Homeboard_content['timesearchdefault']=$prefix;
                $Homeboard_content['customDateValue']=$dates;
            }
        }
        //增加根据用户查看范围设置,获取记忆值功能
        $adb_select_board2 = 'select content from ld_module_setting_byuser where type = ? and userid = ? and label="lastChangeSearchScopeByUser"';
        $result_select_board2 = $adb->pquery($adb_select_board2,array($boardid,$userid));
        //如果用户记忆值是高级查看范围或者全部查看范围,读取具体查看范围,并将$Homeboard_content['selectedSearchScope']更新为相应类型
        $Homeboard_content['selectedSearchScope']='';
        $Homeboard_content['customSearchScopeValue']='';
        if($adb->num_rows($result_select_board2)>0){
            $Homeboard_content['selectedSearchScope'] = $adb->query_result($result_select_board2, 0, 'content');
            if (strpos($Homeboard_content['selectedSearchScope'], 'smowner_search_senior') !== false) {
                // 如果包含smowner_search_senior
                list($prefix, $seletedSearchScope) = explode(':', $Homeboard_content['selectedSearchScope'], 2);
                $Homeboard_content['selectedSearchScope']=$prefix;
                $Homeboard_content['customSearchScopeValue']=$seletedSearchScope;
            }
            else if (strpos($Homeboard_content['selectedSearchScope'], 'SmOwner_Search_All') !== false) {
                // 如果包含smowner_search_senior
                list($prefix, $seletedSearchScope) = explode(':', $Homeboard_content['selectedSearchScope'], 2);
                $Homeboard_content['selectedSearchScope']=$prefix;
                $Homeboard_content['customSearchScopeValue']=$seletedSearchScope;
            }
            else{
                $Homeboard_content['customSearchScopeValue']=$adb->query_result($result_select_board2, 0, 'content');
            }
        }

        return $Homeboard_content;
   }
    //看板所有的组件名称  一个数组 不区分组件类型 仅用于经销商的设置界面显示
   public function getHomeBoardAllStuffNameList(){
        return $this->boardAllStuffNameList;
   }
    /**
     * @param $datarangmodule //模块 多个模块逗号隔开
     * @param $type //组件类型 defaultstuff首页默认组件
     * @param $report_id //ld_homeboard_plate_stuff表的stuffid
     * @param $boardstuffid //ld_homeboard_plate_stuff表的自增主键ID
     * @param $stufflabel //默认组件的组件名称 自定义统计图则传空字符串
     * @return array
     * zxm 20230607 获取组件数据范围配置信息数组
     */
    public function getDatarangeSetArr($datarangmodule,$type,$report_id,$boardstuffid,$stufflabel)
    {
        global $adb;
        include_once globalStatic::$root_directory . 'modules/Home/DataRangeHomeboard.php';
        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance($this->boardid);
        $tmpdatarange_set = [];
        switch ($type) {
            case 'defaultstuff':
            case 'selectfield':
            case 'chart':
                $filterArr = [];
                if ($boardstuffid > 0) {
                    //获取设置好的条件
                    $filterArr = $DataRangeHomeboardObj->boardfilterArr[$boardstuffid];
                }
                $fieldsmownerid = '';
                if (!empty($datarangmodule)) {
                    $tmpdatarangmodule_arr = explode(',', $datarangmodule);
                    foreach ($tmpdatarangmodule_arr as $tmpmodulename) {
                        //模块未开启
                        if(!vtlib_isModuleActive($tmpmodulename)){
                            continue;
                        }
                        $modulelabel = getTranstab($tmpmodulename);
                        $tmpfocus = CRMEntity::getInstance($tmpmodulename);

                        if ($tmpfocus->fieldobj||$tmpfocus->detailfieldobj) {
                            $fieldinfo_date_arr = [];
                            $fieldinfo_datetime_arr = [];
                            if($tmpfocus->fieldobj){
                                //主表的时间字段
                                $fieldinfo_date_arr_main = $tmpfocus->fieldobj->getFieldInfoobjBykey_arr("bigtype", "date");//获取所有的日期类型字段
                                $fieldinfo_datetime_arr_main = $tmpfocus->fieldobj->getFieldInfoobjBykey_arr("bigtype", "datetime");//获取所有的日期时间类型字段
                                $fieldinfo_date_arr = array_merge($fieldinfo_date_arr,$fieldinfo_date_arr_main);
                                $fieldinfo_date_arr = array_merge($fieldinfo_date_arr,$fieldinfo_datetime_arr_main);
                            }
                            //zxm 20240626 XUQIU20240624-03 首页-数据简报/统计图组件筛选器（查看范围和时间范围）设置增加分录对应字段
                            if($tmpfocus->detailfieldobj){
                                //分录表的时间字段
                                $fieldinfo_date_arr_detail = $tmpfocus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", "date");//获取所有的日期类型字段
                                $fieldinfo_datetime_arr_detail = $tmpfocus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype", "datetime");//获取所有的日期时间类型字段
                                $fieldinfo_date_arr = array_merge($fieldinfo_date_arr,$fieldinfo_date_arr_detail);
                                $fieldinfo_date_arr = array_merge($fieldinfo_date_arr,$fieldinfo_datetime_arr_detail);
                            }


                            $fieldinfo_smownerid_arr = $tmpfocus->fieldobj->getFieldInfoobjBykey_arr("uitype", "53");

                            $datefields_option = '';
                            //获取所有的时间字段
                            if(!empty($fieldinfo_datetime_arr)) {
                                foreach ($fieldinfo_datetime_arr as $tmpfieldinfo2) {
                                    $typeOfData = $tmpfieldinfo2->getTypeOfData();
                                    $typeOfData = explode('~', $typeOfData);
                                    $datefields_option .= '<option value="' . $tmpfieldinfo2->getTableName() . ':' . $tmpfieldinfo2->getColumnName() . ':' . $tmpfieldinfo2->getFieldName() . ':' . $tmpmodulename . '_fieldlabel:' . $typeOfData[0] . '">' . $tmpfieldinfo2->getFieldLabel() . '</option>';
                                }
                            }
                            if(!empty($fieldinfo_date_arr)){
                                foreach ($fieldinfo_date_arr as $tmpfieldinfo1) {
                                    $typeOfData = $tmpfieldinfo1->getTypeOfData();
                                    $typeOfData = explode('~', $typeOfData);
                                    $datefields_option .= '<option value="' . $tmpfieldinfo1->getTableName() . ':' . $tmpfieldinfo1->getColumnName() . ':' . $tmpfieldinfo1->getFieldName() . ':' . $tmpmodulename . '_fieldlabel:' . $typeOfData[0] . '">' . $tmpfieldinfo1->getFieldLabel() . '</option>';
                                }
                            }
                            //获取负责人字段的信息
                            if(!empty($fieldinfo_smownerid_arr)){
                                $fieldinfo_smownerid = $fieldinfo_smownerid_arr[0];
                                $typeOfData_smownerid = $fieldinfo_smownerid->getTypeOfData();
                                $typeOfData_smownerid = explode('~', $typeOfData_smownerid);
                                $fieldsmownerid = $tmpfocus->table_name . ':' . $fieldinfo_smownerid->getColumnName() . ':' . $fieldinfo_smownerid->getFieldName() . ':' . $tmpmodulename . '_fieldlabel:' . $typeOfData_smownerid[0];//负责人字段信息
                            }
                        }
                        //获取负责人字段 时间字段  审批状态字段
                        $commonscopemodule = $this->frommodule;
                        $usercomponent_filtermodule = $this->frommodule;//数据范围默认值
                        $optionModuleArr = array();
                        //zxm 20240612 需求XUQIU1002239  移动端报表增加可选择首页数据范围的下拉项  新加组件默认值是首页  已保存的组件读取保存至值
                        if($this->frommodule=='MobileReport'){
                            $optionModuleArr['Home'] = getTranstab('Home');
                            $usercomponent_filtermodule = 'Home';
                        }
                        $optionModuleArr[$commonscopemodule] = getTranstab($commonscopemodule);
                        $optionModuleArr[$tmpmodulename] = $modulelabel;

                        $moduleoption = '';
                        //数据范围下拉框option
                        foreach($optionModuleArr as $tmpm=>$tmplabel){
                            $moduleoption .= '<option value="'.$tmpm.'">' . $tmplabel . '</option>';
                        }
                        $tmpdatarange_set_line = [
                            'modulelabel' => $modulelabel,//模块中文名字
                            'modulename' => $tmpmodulename,//模块标识符 如Accounts

                            'usercomponent_modulesoption' => $moduleoption,//默认组件 成员范围后面是选择模块

                            'usercomponent_fieldsoption' => '',//自定义统计图 成员范围后面是选择字段
                            'usercomponent_isrelated' => true,//保存数据库需要转换成yes/no//新增一个组件的时候  默认将数据范围/时间/审批状态三个开关打开
                            'usercomponent_filtermodule' =>$usercomponent_filtermodule,//Home/Accounts//数据范围依赖模块
                            'usercomponent_filters' => $fieldsmownerid,//负责人字段的值
                            'usercomponent_stuffmodule' => $tmpmodulename,//组件模块 根据ld_stuff表的datarangmodule取值的
                            'usercomponent_filterid' => 0,//自增id,编辑的时候这个值>0  新增的时候这个值为0

                            'timecomponent_fieldsoption' => $datefields_option,//所有的时间数组
                            'timecomponent_isrelated' => true,//保存数据库需要转换成yes/no
                            'timecomponent_filtermodule' => $tmpmodulename,//Home/SalesOrder
                            'timecomponent_filters' => '',
                            'timecomponent_stuffmodule' => $tmpmodulename,
                            'timecomponent_filterid' => 0,

    //                            'approvestatuscomponent_fieldsoption' => '',
    //                            'approvestatuscomponent_isrelated' => false,//保存数据库需要转换成yes/no
    //                            'approvestatuscomponent_filtermodule' => $tmpmodulename,
    //                            'approvestatuscomponent_filters' => $tmpfocus->table_name . ':approvestatus:approvestatus:' . $tmpmodulename . '_fieldlabel:V',
    //                            'approvestatuscomponent_stuffmodule' => $tmpmodulename,
    //                            'approvestatuscomponent_filterid' => 0,
                            'highsearch_filtermodule' => $tmpmodulename,
                            'highsearch_stuffmodule' => $tmpmodulename,
                            'advance_demand' => '[]',//高级查找
                            'advance_demand_filterid' => 0,
                            'advance_demand_groups' => '[]'//高级查找分组信息
                        ];
                        $Approvedeploy = getSys_Approvedeploy($tmpmodulename);//deploy_value=0是开启 =1是关闭
                        if(is_array($Approvedeploy)&&$Approvedeploy['deploy_value']==0){
                            //如果模块开启了审批  才返回审批的设置信息
                            $tmpdatarange_set_line['approvestatuscomponent_fieldsoption'] =  '';
                            $tmpdatarange_set_line['approvestatuscomponent_isrelated'] =   true;//保存数据库需要转换成yes/no
                            $tmpdatarange_set_line['approvestatuscomponent_filtermodule'] = $tmpmodulename;
                            $tmpdatarange_set_line['approvestatuscomponent_filters'] =  $tmpfocus->table_name . ':approvestatus:approvestatus:' . $tmpmodulename . '_fieldlabel:V';
                            $tmpdatarange_set_line['approvestatuscomponent_stuffmodule'] =  $tmpmodulename;
                            $tmpdatarange_set_line['approvestatuscomponent_filterid'] =  0;
                        }
                        //如果是默认组件:过去7天日程/未来7天日程/已过期日程   日程管理  不显示成员范围设置 //库存资料,'INVENTORYDATA'
                        //if(in_array($stufflabel,['OVERSERVENDAYSSCHEDULE','FUTURESEVENDAYSSCHEDULE','EXPIREDAGENDA'])&&$type=='defaultstuff'){
                        if(in_array($stufflabel,['new_reminds',''])&&$type=='defaultstuff'){
                            unset($tmpdatarange_set_line['usercomponent_modulesoption']);
                            unset($tmpdatarange_set_line['usercomponent_fieldsoption']);
                            unset($tmpdatarange_set_line['usercomponent_isrelated']);
                            unset($tmpdatarange_set_line['usercomponent_filtermodule']);
                            unset($tmpdatarange_set_line['usercomponent_filters']);
                            unset($tmpdatarange_set_line['usercomponent_stuffmodule']);
                            unset($tmpdatarange_set_line['usercomponent_filterid']);
                        }
                        //如果是默认组件 :公告 PUBLICANNOUNCEMENT 过去7天日程/未来7天日程/已过期日程 不显示时间字段选择框 不显示成员范围选择
                        if(in_array($stufflabel,['PUBLICANNOUNCEMENT','OVERSERVENDAYSSCHEDULE','FUTURESEVENDAYSSCHEDULE','EXPIREDAGENDA','new_reminds'])&&$type=='defaultstuff'){
                            unset($tmpdatarange_set_line['timecomponent_fieldsoption']);
                            unset($tmpdatarange_set_line['timecomponent_isrelated']);
                            unset($tmpdatarange_set_line['timecomponent_filtermodule']);
                            unset($tmpdatarange_set_line['timecomponent_filters']);
                            unset($tmpdatarange_set_line['timecomponent_stuffmodule']);
                            unset($tmpdatarange_set_line['timecomponent_filterid']);
                        }
                        //数据范围组件--赋存储的值
                        if(isset($filterArr['usercomponent_'.$tmpmodulename])){
                            //数据范围依赖模块 如果数据库存了对应的值 则更新数组默认值
                            $tmpdatarange_set_line['usercomponent_filtermodule'] = $filterArr['usercomponent_'.$tmpmodulename]['filtermodule'];
                            if($type=='chart'){
                                //自定义统计图
                                $tmpdatarange_set_line['timecomponent_filters'] = $filterArr['usercomponent_'.$tmpmodulename]['filters'];
                            }
                            $tmpdatarange_set_line['usercomponent_isrelated'] = $filterArr['usercomponent_'.$tmpmodulename]['isrelated']=='yes'?true:false;
                            $tmpdatarange_set_line['usercomponent_filterid'] = $filterArr['usercomponent_'.$tmpmodulename]['filterid'];
                        }
                        //时间条件组件--赋存储的值
                        if(isset($filterArr['timecomponent_'.$tmpmodulename])){
                            $tmpdatarange_set_line['timecomponent_filtermodule'] = $filterArr['timecomponent_'.$tmpmodulename]['filtermodule'];
                            $tmpdatarange_set_line['timecomponent_filters'] = $filterArr['timecomponent_'.$tmpmodulename]['filters'];
                            $tmpdatarange_set_line['timecomponent_isrelated'] = $filterArr['timecomponent_'.$tmpmodulename]['isrelated']=='yes'?true:false;
                            $tmpdatarange_set_line['timecomponent_filterid'] = $filterArr['timecomponent_'.$tmpmodulename]['filterid'];
                        }else{
                            $TimeDefaultField = $DataRangeHomeboardObj->getTimeDefaultField($tmpfocus->table_name,$type,$report_id);
                            $TimeDefaultField_arr = explode('.',$TimeDefaultField);
                            $tmptimefieldinfo = $tmpfocus->fieldobj->getFieldInfoobjBykey("columnname",$TimeDefaultField_arr[1]);

                            if(!empty($tmptimefieldinfo)) {
                                $tmptimefield_typeofdata = $tmptimefieldinfo->getTypeOfData();
                                $tmptimefield_typeofdata_arr = explode('~', $tmptimefield_typeofdata);
                                //没有存储的值的话(新拖动组件到看板中的时候)  给默认值
                                $tmpdatarange_set_line['timecomponent_filtermodule'] = $tmpmodulename;
                                $tmpdatarange_set_line['timecomponent_filters'] = $tmpfocus->table_name . ":" . $TimeDefaultField_arr[1] . ":" . $TimeDefaultField_arr[1] . ":" . $tmpmodulename . "_fieldlabel:" . $tmptimefield_typeofdata_arr[0];
                                $tmpdatarange_set_line['timecomponent_isrelated'] = true;
                            }
                        }


                        //审批组件--赋存储的值
                        if(is_array($Approvedeploy)&&$Approvedeploy['deploy_value']==0&&isset($filterArr['approvestatuscomponent_'.$tmpmodulename])){
                            $tmpdatarange_set_line['approvestatuscomponent_filters'] = $filterArr['approvestatuscomponent_'.$tmpmodulename]['filters'];
                            $tmpdatarange_set_line['approvestatuscomponent_isrelated'] = $filterArr['approvestatuscomponent_'.$tmpmodulename]['isrelated']=='yes'?true:false;
                            $tmpdatarange_set_line['approvestatuscomponent_filterid'] = $filterArr['approvestatuscomponent_'.$tmpmodulename]['filterid'];
                        }
                        //高级查找条件 --赋存储的值
                        if(isset($filterArr['highsearch_'.$tmpmodulename])){
                            $tmpdatarange_set_line['advance_demand'] = $filterArr['highsearch_'.$tmpmodulename]['advance_demand'];
                            $tmpdatarange_set_line['advance_demand_groups'] = $filterArr['highsearch_'.$tmpmodulename]['advance_demand_groups'];
                            $tmpdatarange_set_line['advance_demand_filterid'] = $filterArr['highsearch_'.$tmpmodulename]['filterid'];
                        }
                        $tmpdatarange_set[] = $tmpdatarange_set_line;
                    }
                }
                break;
            case 'sql'://SQL统计表
            case 'sqlchart':
                $filterArr = [];
                if ($boardstuffid > 0) {
                    //获取设置好的条件
                    $filterArr = $DataRangeHomeboardObj->boardfilterArr[$boardstuffid];
                }
                if($type=='sql'){
                    //SQL统计表
                    include_once globalStatic::$root_directory . 'modules/CustomTables/CustomTablesActions.php';
                    $CustomTablesActionsObj = new CustomTablesActions();
                    $filterinfo = $CustomTablesActionsObj->getSqlFilter($report_id);
                }else{
                    //SQL统计图
                    include_once globalStatic::$root_directory . 'modules/CustomEcharts/CustomEchartsActions.php';
                    $CustomEchartsActionsObj = new CustomEchartsActions($_REQUEST);
                    $CustomEchartsActionsObj->setHomeParams($_REQUEST);
                    $filterinfo = $CustomEchartsActionsObj->getSqlFilter($report_id);
                }

                $smownerid_arr = [];
                $time_arr = [];
                $approvestatus_arr = [];

                $smownerid_options = '';
                $time_options = '';
                $approvestatus_options = '';
                foreach($filterinfo as $filter){
                    if($filter['var_type']=='multiuser'){
                        $smownerid_arr[$filter['id']] = $filter['display_name'];
                        $smownerid_options .= '<option value="'.$filter['id'].'">'.$filter['display_name'].'</option>';
                    }
                    if(($filter['var_type']=='date'||$filter['var_type']=='datetime')){
                        $time_arr[$filter['id']] = $filter['display_name'];
                        $time_options .= '<option value="'.$filter['id'].'">'.$filter['display_name'].'</option>';
                    }
                    if($filter['var_type']=='approvestatus'){
                        $approvestatus_arr[$filter['id']] = $filter['display_name'];
                        $approvestatus_options .= '<option value="'.$filter['id'].'">'.$filter['display_name'].'</option>';
                    }
                }
                //edit: xll 2021/02/26 BUG20240223-37  	kfbcrm-新增加的同比环比sql统计图，放到首页看板显示时，筛选器没有默认值，应默认下拉框的第一个
                //获取负责人字段 时间字段  审批状态字段
                $tmpdatarange_set_line = [
                    'modulelabel' => '',
                    //'usercomponent_modulesoption'=>'',//sql统计图没有这个模块的选择
                    'usercomponent_fieldsoption' => $smownerid_options,//自定义统计图 成员范围后面是选择字段
                    'usercomponent_isrelated'=>false,//yes/no --
                    'usercomponent_filtermodule'=>'',//sql图表这个字段为空
                    'usercomponent_filters'=>'',//负责人字段的值 --
                    'usercomponent_stuffmodule'=>'',//sql图表这个字段为空
                    'usercomponent_filterid' => '',//--

                    'timecomponent1_fieldsoption'=>$time_options,//所有的时间数组
                    'timecomponent1_isrelated'=>false,//yes/no
                    'timecomponent1_filtermodule'=>'',//sql图表这个字段为空
                    'timecomponent1_filters'=>'',
                    'timecomponent1_stuffmodule'=>'',//sql图表这个字段为空
                    'timecomponent1_filterid' => '',

                    'timecomponent2_fieldsoption'=>$time_options,//所有的时间数组
                    'timecomponent2_isrelated'=>false,//yes/no
                    'timecomponent2_filtermodule'=>'',//sql图表这个字段为空
                    'timecomponent2_filters'=>'',
                    'timecomponent2_stuffmodule'=>'',//sql图表这个字段为空
                    'timecomponent2_filterid' => '',

                    'approvestatuscomponent_fieldsoption'=>$approvestatus_options,
                    'approvestatuscomponent_isrelated'=>false,//yes/no
                    'approvestatuscomponent_filtermodule'=>'',//sql图表这个字段为空
                    'approvestatuscomponent_filters'=>'',
                    'approvestatuscomponent_stuffmodule'=>'',//sql图表这个字段为空
                    'approvestatuscomponent_filterid' => '',
                ];
                if(isset($filterArr['usercomponent'])){
                    $tmpdatarange_set_line['usercomponent_filters'] = $filterArr['usercomponent']['filters'];
                    $tmpdatarange_set_line['usercomponent_isrelated'] = $filterArr['usercomponent']['isrelated']=='yes'?true:false;
                    $tmpdatarange_set_line['usercomponent_filterid'] = $filterArr['usercomponent']['filterid'];
                }
                if(isset($filterArr['timecomponent1'])){
                    $tmpdatarange_set_line['timecomponent1_filters'] = $filterArr['timecomponent1']['filters'];
                    $tmpdatarange_set_line['timecomponent1_isrelated'] = $filterArr['timecomponent1']['isrelated']=='yes'?true:false;
                    $tmpdatarange_set_line['timecomponent1_filterid'] = $filterArr['timecomponent1']['filterid'];
                }
                if(isset($filterArr['timecomponent2'])){
                    $tmpdatarange_set_line['timecomponent2_filters'] = $filterArr['timecomponent2']['filters'];
                    $tmpdatarange_set_line['timecomponent2_isrelated'] = $filterArr['timecomponent2']['isrelated']=='yes'?true:false;
                    $tmpdatarange_set_line['timecomponent2_filterid'] = $filterArr['timecomponent2']['filterid'];
                }
                if(isset($filterArr['approvestatuscomponent'])){
                    $tmpdatarange_set_line['approvestatuscomponent_filters'] = $filterArr['approvestatuscomponent']['filters'];
                    $tmpdatarange_set_line['approvestatuscomponent_isrelated'] = $filterArr['approvestatuscomponent']['isrelated']=='yes'?true:false;
                    $tmpdatarange_set_line['approvestatuscomponent_filterid'] = $filterArr['approvestatuscomponent']['filterid'];
                }


                $tmpdatarange_set[] = $tmpdatarange_set_line;
                break;
        }
        return $tmpdatarange_set;
    }

    public function get_plate_stylewidth($platewidth){
        $stylewidth = '';
        switch ($platewidth){
            case '1-1':
                $stylewidth = '100%';
                break;
            case '1-3':
                $stylewidth = '34%';
                break;
            case '2-3':
                $stylewidth = '66%';
                break;
            case '1-2':
                $stylewidth = '50%';
                break;
            default:
                break;
        }
        return $stylewidth;
   }

    public function get_stuff_list(){
        global $adb;
        $boardid = $this->boardid;
        $stuff_list = [];
        $sql_select = 'select stuffid,stufftype from ld_homeboard_plate_stuff where boardid = ?';
        $result = $adb->pquery($sql_select,array($boardid));
        if($adb->num_rows($result) > 0){
           for($i = 0;$i<$adb->num_rows($result);$i++){
               $stuff_list[$adb->query_result($result,$i,'stufftype')][] = $adb->query_result($result,$i,'stuffid');
           }
        }

       return $stuff_list;
   }
    //保存看板选中历史
    public function save_history_homeboard($boardid){
        global $adb,$current_user;
        $sql_select = 'select 1 from ld_module_setting_byuser where `modulename`=? and `userid`=? and `label`=? and `type`=?;';
        $result = $adb->pquery($sql_select,array($this->frommodule,$current_user->id,'LastChoseBoard','Homeboard'));
        if($adb->num_rows($result) > 0){
            $sql_update = 'update ld_module_setting_byuser set `content`=? where `modulename`=? and `userid`=? and `label`=? and `type`=?;';
            $adb->pquery($sql_update,array($boardid,$this->frommodule,$current_user->id,'LastChoseBoard','Homeboard'));
        }else {
            $sql_insert = 'INSERT into ld_module_setting_byuser(`modulename`,`userid`,`label`,`type`,`content`) VALUES (?,?,?,?,?);';
            $adb->pquery($sql_insert, array($this->frommodule, $current_user->id, 'LastChoseBoard', 'Homeboard', $boardid));
        }
    }
    //看板区块和组件信息的保存
    public function savePlateAndStuff(&$homeboard_info,$datarange_set){
        global $adb;
        $boardid = $this->boardid;
        //--删除已经在页面删除的组件start--

        $homeboardstuffid_arr = [];
        for($i = 0;$i < count($homeboard_info['homeboard_plate']);$i++) {
            $plate_info = $homeboard_info['homeboard_plate'][$i];
            for ($j = 0; $j < count($plate_info['homeboard_plate_stuff']); $j++) {
                $stuff_info = $plate_info['homeboard_plate_stuff'][$j];
                $boardstuffid = $stuff_info['boardstuffid'];
                $homeboardstuffid_arr[] = $boardstuffid;
            }
        }
        if(!empty($homeboardstuffid_arr)){
            $homeboardstuffid_str = implode(',',$homeboardstuffid_arr);
            $deletesql = "delete from ld_homeboard_plate_stuff where boardstuffid not in ($homeboardstuffid_str) and boardid=?";
            $adb->pquery($deletesql,array($boardid));
        }else{
            //BUG20240409-63 zxm 20240410 首页面板，更改时，把所有面板都删除。点击保存后，面板刷新后还是原来的样子
            $deletesql = "delete from ld_homeboard_plate_stuff where boardid=?";
            $adb->pquery($deletesql,array($boardid));
        }
        //--删除已经在页面删除的组件end--

        for($i = 0;$i < count($homeboard_info['homeboard_plate']);$i++){
            $plate_info = $homeboard_info['homeboard_plate'][$i];
            $plateid = $plate_info['plateid'];
            $platetype = $plate_info['platetype'];
            $platewidth = $plate_info['platewidth'];

            if((int)$plateid > 0){

                $update_sql_plate = 'update ld_homeboard_plate set `platetype`=?,`platewidth`=?,`sequence`=? where `plateid` = ?';
                $adb->pquery($update_sql_plate,array($platetype,$platewidth,$i,$plateid));
            }else{
                $insert_sql_plate = 'INSERT INTO ld_homeboard_plate(`boardid`,`platetype`,`platewidth`,`sequence`) VALUES (?,?,?,?);';
                $adb->pquery($insert_sql_plate,array($boardid,$platetype,$platewidth,$i));
                $plateid = $adb->getLastInsertID();
                $plateid_datarange = $platetype;//新建的时候 页面的数组区块还没有值
            }
            for($j = 0;$j < count($plate_info['homeboard_plate_stuff']);$j++){
                $stuff_info = $plate_info['homeboard_plate_stuff'][$j];

                $stuffid = $stuff_info['stuffid'];
                $boardstuffid = $stuff_info['boardstuffid'];//zxm 20230613 ld_homeboard_plate_stuff主键ID
                if(count(explode('_',$stuffid)) > 1){
                    $stuffid = explode('_',$stuffid)[1];
                }

                $stufftype = $stuff_info['stufftype'];
                $height = $stuff_info['height'];
                $stufftitle_zh = $stuff_info['stufftitle_zh'];
                $stufftitle_en = $stuff_info['stufftitle_en'];
                if($boardstuffid>0){
                    //zxm 20230613 有数据则更新 无数据则insert
                    $sql_update_stuff = 'update ld_homeboard_plate_stuff set `plateid`=?,`stufftype`=?,`sequence`=?,`height`=?,`stufftitle_zh`=?,`stufftitle_en`=? where boardstuffid=? ';
                    $adb->pquery($sql_update_stuff,array($plateid,$stufftype,$j,$height,$stufftitle_zh,$stufftitle_en,$boardstuffid));
                }else{
                    $sql_inset_stuff = 'INSERT INTO ld_homeboard_plate_stuff(`stuffid`,`boardid`,`plateid`,`stufftype`,`sequence`,`height`,`stufftitle_zh`,`stufftitle_en`) VALUES (?,?,?,?,?,?,?,?);';
                    $insertres = $adb->pquery($sql_inset_stuff,array($stuffid,$boardid,$plateid,$stufftype,$j,$height,$stufftitle_zh,$stufftitle_en));
                    $boardstuffid = $adb->getLastInsertID();

                    //edit: xll 更新数组中的boardstuffid
                    $homeboard_info['homeboard_plate'][$i]['homeboard_plate_stuff'][$j]['boardstuffid'] = $boardstuffid;
                }


                //数据范围设置信息的保存
                $tmpstuffkey = $stufftype=='customreport'?'customEchart_'.$stuffid:$stufftype.'_'.$stuffid;
                $tmp_datarange_set = $datarange_set['plate_'.$plate_info['plateid']][$tmpstuffkey];
                foreach($tmp_datarange_set as $dataset){
                    $componenttype_arr = ['usercomponent','timecomponent','timecomponent1','timecomponent2','approvestatuscomponent'];

                    foreach($componenttype_arr as $componenttype){
                        if(isset($dataset[$componenttype.'_isrelated'])) {
                            //组件设置
                            $tmp_isrelated = $dataset[$componenttype . '_isrelated'] ? 'yes' : 'no';
                            if ($dataset[$componenttype . '_filterid'] > 0) {
                                $update_user_sql = "update ld_homeboard_plate_filter set isrelated=?,filters=?,filtermodule=?,stuffmodule=? where filterid=? ";
                                $adb->pquery($update_user_sql, array($tmp_isrelated, $dataset[$componenttype . '_filters'], $dataset[$componenttype . '_filtermodule'], $dataset[$componenttype . '_stuffmodule'], $dataset[$componenttype . '_filterid']));
                            } else {
                                $insert_user_sql = "insert into ld_homeboard_plate_filter(boardstuffid,conditionkey,isrelated,filters,filtermodule,stuffmodule)values(
                 ?,?,?,?,?,?)";
                                $adb->pquery($insert_user_sql, array($boardstuffid, $componenttype, $tmp_isrelated, $dataset[$componenttype . '_filters'], $dataset[$componenttype . '_filtermodule'], $dataset[$componenttype . '_stuffmodule']));
                            }
                        }
                    }

                    //高级查找条件
                    if(isset($dataset['advance_demand'])){
                        if ($dataset['advance_demand_filterid'] > 0) {
                            $update_user_sql = "update ld_homeboard_plate_filter set isrelated=?,filtermodule=?,stuffmodule=?,advance_demand=?,advance_demand_groups=? where filterid=? ";
                            $adb->pquery($update_user_sql, array('yes',$dataset['highsearch_filtermodule'], $dataset['highsearch_stuffmodule'], $dataset['advance_demand'], $dataset['advance_demand_groups'],$dataset['advance_demand_filterid']));
                        }else{
                            $insert_user_sql = "insert into ld_homeboard_plate_filter(boardstuffid,conditionkey,isrelated,filtermodule,stuffmodule,advance_demand,advance_demand_groups)values(
                 ?,?,?,?,?,?,?)";
                            $adb->pquery($insert_user_sql, array($boardstuffid, 'highsearch', 'yes',$dataset['highsearch_filtermodule'], $dataset['highsearch_stuffmodule'], html_entity_decode($dataset['advance_demand']), $dataset['advance_demand_groups']));
                        }
                    }
                }
            }
        }
    }
    public function get_history_homeboard(){
       global $adb,$current_user;
       //ZXM 20231121 获取看板历史选中的时候  连一下ld_homeboard表 用来判断是否被删除
       $sql = 'select ld_homeboard.boardid from ld_module_setting_byuser inner join ld_homeboard 
                 on ld_homeboard.boardid=ld_module_setting_byuser.content
                 where ld_homeboard.deleted=0 and `modulename`=? and `userid`=? and `label`=? and `type`=?;';
       $result = $adb->pquery($sql,array($this->frommodule, $current_user->id, 'LastChoseBoard', 'Homeboard'));
       $boardid = 0;
       if($adb->num_rows($result) > 0){
           $boardid = $adb->query_result($result,0,'boardid');
       }
       return $boardid;
   }

    public function get_homeboard_list_scope(){
        global $current_user,$adb;
        $module = $this->frommodule;
        //看板名称为空的不显示  zxm 20230830
        $sql = "select boardid,boardname,scope,smcreatorid from ld_homeboard where deleted = 0 and ifnull(boardname,'')<>'' and `boardtype` = ? order by ld_homeboard.sequence ASC";
        $result = $adb->pquery($sql,array($module));
        crm_load_class_file("cls_related_scope",'include/utils');
        $homeoard_list = [];
        if($adb->num_rows($result) > 0){
            for($i =0;$i<$adb->num_rows($result);$i++){
                $boardid = $adb->query_result($result,$i,'boardid');
                $boardname = $adb->query_result($result,$i,'boardname');
                $scope = $adb->query_result($result,$i,'scope');
                $smcreatorid = $adb->query_result($result,$i,'smcreatorid');
                //edit: xll BUG0069756 kfbcrm-可视化分析-数据看板-适用范围是“按部门”“按成员”“按角色”时，点击看板跳转到报表界面，看板名称不显示了（用户创建的也需要显示）
                if($scope == 'all' || $smcreatorid == $current_user->id){
                    $homeoard_list[$boardid] = $boardname;
                }else{
                    $relatd_scope_list = cls_related_scope::get_related_scope($this->frommodule,'Homeboard_scope',$adb->query_result($result,$i,'boardid'));
                    $isscope = false;
                    if($scope == 'group'){
                        if(is_array($relatd_scope_list) && in_array($current_user->groupid,$relatd_scope_list)){
                            $isscope = true;
                        }
                    }elseif($scope == 'user'){
                        if(is_array($relatd_scope_list) && in_array($current_user->id,$relatd_scope_list)){
                            $isscope = true;
                        }
                    }elseif($scope == 'role'){
                        if(is_array($relatd_scope_list) && in_array($current_user->profileid,$relatd_scope_list)){
                            $isscope = true;
                        }
                    }
                    if($isscope == true){
                        $homeoard_list[$boardid] = $boardname;
                    }
                }
            }
        }
        return $homeoard_list;
   }
    //这个方法用来判断是否有默认看板  --判断ld_templates是否有数据
    public function isHaveDefaultKanban(){
        global $adb;
        $selectsql = "select 1 from ld_templates where deleted=0 ";
        $selectres = $adb->pquery($selectsql);
        $nums = $adb->num_rows($selectres);
        if($nums>0){
            return 'yes';
        }
        return 'no';
    }
    //获取移动端工作台组件-自定义报表组件的信息
    public function getCustomreportBlockinfo(){
        global $adb;
        $CustomreportBlockinfo = [];
        $custom_result = $adb->pquery("select block_name,block_id from ld_mobile_report_parent_tab where presence =2 and parenttab_label = 'customreportblock'",array());
        $custom_rows = $adb->num_rows($custom_result);
        if($custom_rows>0){
            $block_name = $adb->query_result($custom_result,0,'block_name');
            $block_id = $adb->query_result($custom_result,0,'block_id');
            $CustomreportBlockinfo['blocklabel'] = $block_name;
            $CustomreportBlockinfo['blockid'] = $block_id;
        }
        return $CustomreportBlockinfo;
    }

    public function savePlateSetting($homeboard_info,$StuffOtherSet){
        foreach ($homeboard_info['homeboard_plate'] as $plateid => $plateInfo){
            foreach ($plateInfo['homeboard_plate_stuff'] as $index => $stuffInfo) {
                $boardstuffid = $stuffInfo['boardstuffid'];
                $stuffid = $stuffInfo['stuffid'];
                $tmpKey = $stuffid;
                if($stuffInfo['stufftype'] === 'defaultstuff')
                    $tmpKey = 'defaultstuff_'.$stuffid;
                if(isset($StuffOtherSet[$tmpKey])) {
                    $this->saveStuffOtherSet($boardstuffid,$stuffInfo,$StuffOtherSet[$tmpKey]);
                }
            }
        }
    }
    
    public function saveStuffOtherSet($boardstuffid,$stuffInfo,$StuffOtherSet){
        global $adb;
        $boardid = $this->boardid;
        $stuffid = $stuffInfo['stuffid'];
        foreach ($StuffOtherSet as $type => $setvalue) {
            //zxm 20240606 销售排行榜、跟进频次排行榜、产品销售排行榜、数据龙虎榜 增加是否穿透的参数
            if($type=='can_penetrate'){
                $setvalue = ($setvalue === true || $setvalue === 'yes')?'yes':'no';
            }
            if(is_array($setvalue)){
                $setvalue = json_encode($setvalue);
            }
            $tmpselectsql = "select 1 from ld_homeboard_plate_setting where boardid=? and stuffid=? and boardstuffid=? and type=?";
            $tmpselectres = $adb->pquery($tmpselectsql,array($boardid,$stuffid,$boardstuffid,$type));
            $tmpselectnums = $adb->num_rows($tmpselectres);
            if($tmpselectnums>0){
                $updatesql = "update ld_homeboard_plate_setting set setvalue=? where boardid=? and stuffid=? and boardstuffid=? and type=?";
                $adb->pquery($updatesql,array($setvalue,$boardid,$stuffid,$boardstuffid,$type));
            }else if($boardstuffid>0){
                $insertsql = "insert into ld_homeboard_plate_setting (setvalue,boardid,stuffid,boardstuffid,type) values (?,?,?,?,?)";
                $adb->pquery($insertsql,array($setvalue,$boardid,$stuffid,$boardstuffid,$type));
            }
        }

    }

    static function getPlateSetting($boardid,$stuffid){
        global $adb;
        $sql = "select * from ld_homeboard_plate_setting where boardid=? and stuffid=? order by id";
        $res = $adb->pquery($sql,array($boardid,$stuffid));
        $nums = $adb->num_rows($res);
        $setArr = [];
        if($nums > 0) {
            for ($i = 0; $i < $nums; $i ++) {
                $type = $adb->query_result($res,$i,'type');
                $setvlaue = html_entity_decode($adb->query_result($res,$i,'setvalue'));
                $setArr[$type] = $setvlaue;
            }
        }
        return $setArr;
    }
    //根据统计图类别不一样 数据标签下拉框值不一样
    public function getDataLabelSelect($charttype,$plate_setting){
        switch ($charttype){
            case 'funnel':
                //销售漏斗
                return [
                    'inside' => [
                        //没设置过  那就是居中显示--默认
                        'selected' => !isset($plate_setting['datalabel'])||isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='inside'?'yes':'no',
                        'value' => 'inside',
                        'label' => getFixedLabel('INTERNAL'),
                    ],
                    'left' => [
                        'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='left'?'yes':'no',
                        'value' => 'left',
                        'label' => getFixedLabel('theleftside'),
                    ],
                    'right' => [
                        'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='right'?'yes':'no',
                        'value' => 'right',
                        'label' => getFixedLabel('therightside'),
                    ],
                    'none' => [
                        'selected' => (isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='none')?'yes':'no',
                        'value' => 'none',
                        'label' => getFixedLabel('HIDE'),
                    ],
                ];
            case 'strip':
                //条形图 如数据龙虎榜
                return [
                    'inside' => [
                        //没设置过  那就是居中显示--默认
                        'selected' => !isset($plate_setting['datalabel'])||isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='inside'?'yes':'no',
                        'value' => 'inside',
                        'label' => getFixedLabel('INTERNAL'),
                    ],
                    'insideLeft' => [
                        'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='insideLeft'?'yes':'no',
                        'value' => 'insideLeft',
                        'label' => getFixedLabel('Internalbacking'),
                    ],
                    'right' => [
                        'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='right'?'yes':'no',
                        'value' => 'right',
                        'label' => getFixedLabel('therightside'),
                    ],
                    'none' => [
                        'selected' => (isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='none')?'yes':'no',
                        'value' => 'none',
                        'label' => getFixedLabel('HIDE'),
                    ],
                ];
            case 'pie':
                // 饼图
                return [
                    'outside'=>[
                        // 默认外部显示
                        'selected' => !isset($plate_setting['datalabel'])||(isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='outside')?'yes':'no',
                        'value'=>'outside',
                        'label'=>getFixedLabel("EXTERNAL"),
                    ],
                    'inside'=>[
                        // 内部
                        'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='inside'?'yes':'no',
                        'value'=>'inside',
                        'label'=>getFixedLabel("INTERNAL"),
                    ],
                    'inside_radial'=>[
                        // 内部冲圆心
                        'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='inside_radial'?'yes':'no',
                        'value'=>'inside_radial',
                        'label'=>getFixedLabel("inside_radial"),
                    ],
                    'none'=>[
                        // 不显示
                        'selected' => (isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='none')?'yes':'no',
                        'value'=>'none',
                        'label'=>getFixedLabel("HIDE"),
                    ]
                ];
            case 'bar':
            case 'linebar':
                //柱状图
            return [
                'none' => [
                    //没设置过  那就是居中显示--默认
                    'selected' => !isset($plate_setting['datalabel'])||isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='none'?'yes':'no',
                    'value' => 'none',
                    'label' => getFixedLabel('HIDE'),
                ],
                'top' => [
                    'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='top'?'yes':'no',
                    'value' => 'top',
                    'label' => getFixedLabel('EXTERNAL'),
                ],
                'insideBottom' => [
                    'selected' => isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='insideBottom'?'yes':'no',
                    'value' => 'insideBottom',
                    'label' => getFixedLabel('Internalbacking'),
                ],
                'inside' => [
                    'selected' => (isset($plate_setting['datalabel'])&&$plate_setting['datalabel']=='inside')?'yes':'no',
                    'value' => 'inside',
                    'label' => getFixedLabel('InternalCenter'),
                ],
            ];
        }
    }
    //是否穿透的配置
    public function getCanPenetrate($stuffid){
        //默认可穿透
        $can_penetrate = true;
        $plate_setting = self::getPlateSetting($this->boardid,$stuffid);

        if(isset($plate_setting['can_penetrate']))
            $can_penetrate = $plate_setting['can_penetrate']=='yes'?true:false;

        return $can_penetrate;
    }
    //获取其他设置信息
    public function getStuffOtherSet () {
        $allStuffinfo = $this->getAllStuffInfo();
        $OtherSetInfo = [];
        //zxm 20240606 销售排行榜、产品销售排行榜、数据龙虎榜 增加是否穿透的设置
        $StuffIdArr = ['33','60','100','117'];
        foreach ($StuffIdArr as $stuffid) {
            $fun_name = 'getOtherSetInfo_' . $stuffid;
            $OtherSetInfo['defaultstuff_'.$stuffid] = $this->$fun_name($stuffid);
        }
        //charttype有值的 跟进频次排行榜、 '57','102','103','104'
        foreach($allStuffinfo as $tmpstuffid=>$tmpstuffinfo){
            $tmpstufftype = $tmpstuffinfo['stufftype'];
            $tmpcharttype = $tmpstuffinfo['charttype'];
            if($tmpstufftype=='chart'&&!empty($tmpcharttype)){
                $OtherSetInfo['defaultstuff_'.$tmpstuffid] = $this->getOtherSetInfo_chart($tmpstuffid,$tmpcharttype);
            }
            //获取组件显示字段设置  如组件最新销售机会 最新合同订单  这一类组件有这个设置--消息中心不要字段设置
            if($tmpstufftype=='customsheet'&&$tmpstuffid!=118){
                $OtherSetInfo['defaultstuff_'.$tmpstuffid] = $this->getOtherSetInfo_customsheet($tmpstuffid);
            }
        }

        return $OtherSetInfo;
    }
    public function getOtherSetInfo_chart($stuffid,$tmpcharttype){
        $tmpkey = 'defaultstuff_'.$stuffid;

        if(!isset($this->DatarangeSetListDefault[$tmpkey]))
            return [];

        $OtherSetInfo = [];
        //默认不显示数据标签
        $plate_setting = self::getPlateSetting($this->boardid,$stuffid);
        if($stuffid==113){//113有另外两个配置
            $OtherSetInfo = $this->getOtherSetInfo_113($stuffid);
        }
        //是否穿透的配置
        $OtherSetInfo['can_penetrate'] = $this->getCanPenetrate($stuffid);

        //数据标签的配置
        $OtherSetInfo['datalabel'] = $this->getDataLabelSelect($tmpcharttype,$plate_setting);
        return $OtherSetInfo;
    }
    //获取组件显示字段设置  如组件最新销售机会 最新合同订单  这一类组件有这个设置
    public function getOtherSetInfo_customsheet($stuffid){
        $tmpkey = 'defaultstuff_'.$stuffid;

        if(!isset($this->DatarangeSetListDefault[$tmpkey]))
            return [];

        $OtherSetInfo = [];
        //显示字段的配置---只显示一个按钮 点击的时候去后台请求可选字段和已选字段
        $OtherSetInfo['showfields'] = getFixedLabel('DISPLAYCOLUMNSET');
        return $OtherSetInfo;
    }
    //zxm 20240606 销售排行榜、产品销售排行榜 增加是否穿透的设置
    public function getOtherSetInfo_33($stuffid){
        $tmpkey = 'defaultstuff_'.$stuffid;
        if(!isset($this->DatarangeSetListDefault[$tmpkey]))
            return [];

        $OtherSetInfo['can_penetrate'] = $this->getCanPenetrate($stuffid);

        return $OtherSetInfo;
    }
    //zxm 20240606 销售排行榜、产品销售排行榜 增加是否穿透的设置
    public function getOtherSetInfo_60($stuffid){
        return $this->getOtherSetInfo_33($stuffid);
    }
    //zxm 20240710 数据标签显示--数据龙虎榜 按看板的只有是否显示数据标签
    public function getOtherSetInfo_100($stuffid){
        $tmpkey = 'defaultstuff_'.$stuffid;

        if(!isset($this->DatarangeSetListDefault[$tmpkey]))
            return [];
        //默认不显示数据标签
        $plate_setting = self::getPlateSetting($this->boardid,$stuffid);

        $OtherSetInfo['datalabel'] = $this->getDataLabelSelect('strip',$plate_setting);
        return $OtherSetInfo;
    }
    public function getOtherSetInfo_113($stuffid){
        $tmpkey = 'defaultstuff_'.$stuffid;
        if(!isset($this->DatarangeSetListDefault[$tmpkey]))
            return [];
        $pathInfo = $this->DatarangeSetListDefault[$tmpkey];
        $startModule = $pathInfo[0]['modulename'];
        $focus = CRMEntity::getInstance($startModule);
        $picklistFields = $focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'picklist');
        $FieldsArr = [];
        $plate_setting = self::getPlateSetting($this->boardid,$stuffid);
        $classifyField = $plate_setting['classifyField'];
        foreach ($picklistFields as $index => $fieldInfo) {
            $fieldName = $fieldInfo->getFieldName();
            $tablename = $fieldInfo->getTableName();
            $columname = $fieldInfo->getColumnName();
            $fieldlabel = $fieldInfo->getfieldLabel();
            $typeofdata_arr = explode('~',$fieldInfo->getTypeOfData());
            $combine_column = $tablename.":".$columname.":".$fieldName.":".$startModule."_fieldlabel:".$typeofdata_arr[0];
            $selected = 'no';
            if($combine_column === $classifyField)
                $selected = 'yes';
            $FieldsArr[$fieldName] = [
                'value'=>$combine_column,
                'label'=>$fieldlabel,
                'selected'=>$selected,
            ];
        }
        $OtherSetInfo['classifyField'] = $FieldsArr;
        $OtherSetInfo['countType'] = [
            'count' => [
                'value' => 'count',
                'label' => getFixedLabel('COUNT'),
            ],
            'distinct_count' => [
                'value' => 'distinct_count',
                'label' => getFixedLabel('UCOUNT'),
            ],
        ];
        $countType = $plate_setting['countType'];
        if($countType !== null && $countType !== '')
            $OtherSetInfo['countType'][$countType]['selected'] = 'yes';

        //是否穿透的配置
        $OtherSetInfo['can_penetrate'] = $this->getCanPenetrate($stuffid);
        return $OtherSetInfo;
    }

    public function getOtherSetInfo_117($stuffid){
        global $adb;
        $plate_setting = self::getPlateSetting($this->boardid,$stuffid);
        $defaultCarousel = [ "path" =>  getGlobalImageUrl()."themes/images/carouselDefault.png", "link" => "", "title" => getFixedLabel("SamplePicture")];
        $CarouselTimer = isset($plate_setting['CarouselTimer']) ? $plate_setting['CarouselTimer'] : 4;
        $CarouselImgs = isset($plate_setting['CarouselImgs']) ? json_decode($plate_setting['CarouselImgs'],true) : [ $defaultCarousel ];

        return [
            'CarouselTimer' => $CarouselTimer,
            'CarouselImgs' => $CarouselImgs,
            'addCarouselImg' => [
                "defaultCarousel" => $defaultCarousel
            ],
        ];
    }

    //20240726 hzx XUQIU1001729 经销商用PRM成员管理设置
    public function getPrmHomeboardId(){
        global $adb;
        $boardid = '';
        $sql = 'select boardid from ld_homeboard where boardtype = "prmHome";';
        $result = $adb->pquery($sql,array());
        if($adb->num_rows($result) > 0){
            $boardid = $adb->query_result($result,0,'boardid');
        }
        return $boardid;
    }

}

?>