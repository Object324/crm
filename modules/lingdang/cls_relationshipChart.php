<?php
class cls_relationshipChart{

    public $chartmodule;//图谱模块
    public $chartfocus;//图谱模块的focus
    public $frommodule;//单据模块
    public $fromrecord;//单据id
    public $showtype;//显示界面、编辑界面
    public $platform='PC';//PC：PC端   mobile:移动端
    public $relationid;//相关信息id
    public $chartTable = 'ld_relationshipChart';//图谱数据表
    public $listDataTable = 'ld_relationshipChartListData';//图谱数据表
    public $lockTable = 'ld_relationshipChartLockStatus';//图谱锁定数据表
    public $leftListDataArr;//左侧列表数据
    public $relatedRecordsArr;//图谱当前的所有相关单据
    public $relationshipChartDataArr;//右侧图谱结构
    public $showFieldInfoArr;//显示字段信息 包括label和内容的字体颜色
    public $chartRecord_nodeidArr;//单据-节点关系
    public $chartRecord_parentnodeidArr;//单据-上级单据的节点关系
    public $maxnodeid = 0;//最大节点nodeid
    public $haveChartData = '';//是否有图谱数据
    public $showTipStatus = 'no';//相关信息显示界面显图谱提示状态
    public $showTipContent = '';//相关信息显示界面显图谱提示内容
    public $lockstatus;//锁定状态
    public $relatedListInfo;//相关信息数据
    public $hrefFieldInfoArr;//超链接内容
    public $arrFixedLabelArr;//翻译
    public $haveTagField = 'no';//是否显示标签字段
    public $tagDataByRecordArr;//是否显示标签字段
    public $haveParentid;//是否启用上级单位字段
    public $haveRecordNodeArr;

    /**
     * 这是一个函数的说明。
     *
     * @see clearSelfRelatedObj 清除对象的相关引用变量;若有其他引用,unset没有用，只是变量引用解除,对象并没有释放
     *
     * @see getRelationshipChartHtml 获取图谱显示的数据和html
     *
     * @see getRelationshipChartData 获取图谱数据的中介函数
     *
     * @see getRelationshipChartDataInfo 获取图谱数据节点内容
     *
     * @see getAccountsChartDataByParentid 获取客户图谱 按照"上级单位"字段获取上下级数据
     *
     * @see transformIntoChartData 按照"上级单位"字段获取上下级数据处理为图谱所需数据
     *
     * @see getDefaultChartData 获取默认数据
     *
     * @see getLeftListData 获取左侧列表的单据数据 或设置空数据的初始值
     *
     * @see updateLockStatus 更新图谱锁定状态
     *
     * @see getShowFieldSetHtml 获取显示字段设置弹窗内容
     * ...
     * @see getRelatedRecordData 获取相关单据显示字段的数据内容
     * ...
     * @see getRelatedListInfo 获取相关信息的内容
     * ...
     * @see saveChart 保存图谱
     */

    public function __construct($frommodule,$fromrecord,$chartmodule){
        $this->chartmodule = $chartmodule;
        $this->frommodule = $frommodule;
        $this->fromrecord = $fromrecord;
        $this->chartfocus = CRMEntity::getInstance($chartmodule);
    }

    //释放对象前执行的最后一个函数
    public function __destruct()
    {
        //dump('The object named "cls_relationshipChart" has been cleared !');
    }

    //清除对象的相关引用变量;若有其他引用,unset没有用，只是变量引用解除,对象并没有释放
    public function clearSelfRelatedObj(){
        global $global_cls_relationshipChartobjs;
        $key = $this->frommodule.'_'.$this->fromrecord.'_'.$this->chartmodule;
        if (isset($global_cls_relationshipChartobjs[$key])){
            unset($global_cls_relationshipChartobjs[$key]);//全局变量中清除对象引用
            unset($GLOBALS['global_cls_relationshipChartobjs'][$key]);//超全局变量中清除对象引用
        }
        if (isset($global_cls_relationshipChartobjs) && sizeof($global_cls_relationshipChartobjs) == 0){//全局变量内无数据，清除全局变量
            unset($global_cls_relationshipChartobjs);
            unset($GLOBALS['global_cls_relationshipChartobjs']);
        }
        unset($key);
    }

    public static function getInstance($frommodule,$fromrecord,$chartmodule){
        global $global_cls_relationshipChartobjs;//暂用全局变量，禁用静态变量
        $key = $frommodule.'_'.$fromrecord.'_'.$chartmodule;
        if($global_cls_relationshipChartobjs[$key]) {
            return $global_cls_relationshipChartobjs[$key];
        }else{
            $global_cls_relationshipChartobjs[$key]=new cls_relationshipChart($frommodule,$fromrecord,$chartmodule);
            return $global_cls_relationshipChartobjs[$key];
        }
    }

    //获取部分翻译
    public function getArrFixedLabel(){
        if ($this->platform == 'mobile'){
            if ($this->chartmodule == 'Accounts'){
                $moduleLabel = getFixedLabel('Customer');
            }
            $arrFixedLabelArr = array(
                'ADDMODULEMAPINPC'=>getVarFixedLabel('ADDMODULEMAPINPCTIP',$moduleLabel),
                'RETURN'=>getFixedLabel('RETURN'),
                'TOBEADD'=>getFixedLabel('TOBEADD'),
            );
        }else{
            $arrFixedLabelArr = array(
                'noPermittedToViewTip'=>getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE'),
                'haveParenidDataMessageTip'=>getFixedLabel('getrelationshipChartByParenidMessageTip'),
                'haveNoParenidDataMessageTip'=>getFixedLabel('getrelationshipChartByParenidMessageNoTip'),
                'empty'=>getFixedLabel('VALUENONE'),
                'saveTag'=>getFixedLabel('SaveTag'),
                'takeChildrenNode'=>getFixedLabel('WhetherToTakeNode'),
                'BroughtOutRelatedRecords'=>getFixedLabel('BroughtOutRelatedRecords'),
                'RepeatCustomersSaveTip'=>getFixedLabel('RepeatCustomersSaveTip'),
                'unlockSaveTips'=>getFixedLabel('UNLOCKSAVETIPS'),
            );
        }
        $this->arrFixedLabelArr = $arrFixedLabelArr;
        unset($arrFixedLabelArr);
        return $this->arrFixedLabelArr;
    }

    public function setSpecialData(){
        if (empty($this->haveParentid) && $this->frommodule == 'Accounts' && $this->chartmodule == 'Accounts'){
            $fieldinfo = $this->chartfocus->fieldobj->getFieldInfoobjBykey('columnname','parentid');//上级单位
            if (!empty($fieldinfo)){
                $this->haveParentid = 'yes';
                $this->arrFixedLabelArr['parentid'] = $fieldinfo->getFieldLabel();
                $this->showTipContent = getVarFixedLabel('getrelationshipChartByParenidTip',$this->arrFixedLabelArr['parentid']);
            }else{
                $this->haveParentid = 'no';
            }
            unset($fieldinfo);
        }
    }

    //设置界面类型
    public function setShowType($showtype){
        $this->showtype = $showtype;
        unset($showtype);
    }

    //设置是PC端还是移动端
    public function setPlatForm($platform){
        $this->platform = $platform;
        unset($platform);
    }

    //获取图谱弹窗的内容
    public function getRelationshipChartHtml(){
        global $current_user;
        $smarty = new lingdangCRM_smarty;
        $smarty->assign('FROMMODULE',$this->frommodule);
        $smarty->assign('CHARTMODULE',$this->chartmodule);
        $smarty->assign('FROMRECORDID',$this->fromrecord);
        $smarty->assign('showtype',$this->showtype);
        if ($this->chartmodule == 'Accounts'){
            $moduleLabel = getFixedLabel('Customer');
            $arr['title'] = getFixedLabel('AccountsRelationshipChart');
        }
        $smarty->assign('MODULELABEL',$moduleLabel);
        unset($moduleLabel);

        $this->getRelationshipChartData();//获取图谱数据
        $arr['relationshipChartDataArr'] = $this->relationshipChartDataArr;

        $smarty->assign('lockstatus',$this->lockstatus);

        if ($this->chartmodule == 'Accounts' && $this->frommodule == 'Accounts'){
            $this->setSpecialData();
            $smarty->assign('haveParentid',$this->haveParentid);
            $smarty->assign('parentidLabel',$this->arrFixedLabelArr['parentid']);
            $smarty->assign('parentidTip2',getFixedLabel('ADDMODULEMAPINPCTIP2'));
        }
        $smarty->assign('showTipStatus',$this->showTipStatus);
        $smarty->assign('showTipContent',$this->showTipContent);

        //编辑根据权限控制
        $editPermit = isPermitted($this->chartmodule,'EditView','');
        $smarty->assign('editPermit',$editPermit);

        $arr['content'] = $smarty->fetch('DetailView/relationshipChart.tpl');
        unset($smarty);

        $this->getLeftListData();//获取左侧列表单据
        $arr['relatedRecordsArr'] = $this->relatedRecordsArr;
        $this->getRelatedRecordData();//获取所有相关单据数据
        $arr['leftListDataArr'] = $this->leftListDataArr;//显示字段label颜色
        $arr['tagDataByRecordArr'] = $this->tagDataByRecordArr;//所有相关单据的标签数据
        $arr['showFieldInfoArr'] = $this->showFieldInfoArr;//所有相关单据的标签数据
        $arr['hrefColumnname'] = $this->hrefFieldInfoArr['columnname'];//超链接字段的columnname
        $arr['haveRecordNodeArr'] = $this->haveRecordNodeArr;//节点和单据的关系
        $arr['showTipStatus'] = $this->showTipStatus;
        $arr['haveTagField'] = $this->haveTagField;

        $this->getArrFixedLabel();
        $arr['arrFixedLabelArr'] = $this->arrFixedLabelArr;
        $arr['lockstatus'] = $this->lockstatus;
        $arr['maxnodeid'] = $this->maxnodeid;
        $arr['frommodule'] = $this->frommodule;
        $arr['chartmodule'] = $this->chartmodule;
        $arr['fromrecord'] = $this->fromrecord;
        $arr['showChart'] = 'yes';
        $arr['is_admin'] = is_admin($current_user);
        $arr['showtype'] = $this->showtype;
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");

        return $arr;
    }

    //获取图谱数据的中介函数
    public function getRelationshipChartData(){
        $relationshipChartDataArr = $this->getRelationshipChartDataInfo();
        //无图谱数据
        if ($this->haveChartData == 'no'){//没有图谱
            if ($this->frommodule == 'Accounts' && $this->chartmodule == 'Accounts'){//客户模块--客户图谱 默认按照上级单位生成图谱
                $relationshipChartDataArr = $this->getAccountsChartDataByParentid();
            }
        }
        if (sizeof($relationshipChartDataArr) == 0){
            $relationshipChartDataArr = $this->getDefaultChartData();
        }
        $this->relationshipChartDataArr = $relationshipChartDataArr;
        unset($relationshipChartDataArr);
        return $this->relationshipChartDataArr;
    }

    //获取单据保存的图谱数据
    public function getRelationshipChartDataInfo(){
        global $adb;
        $relationshipChartDataArr = [];
        $chartRecord_nodeidArr = [];
        $chartRecord_parentnodeidArr = [];
        $haveRecordNodeArr = [];
        $haveChartData = 'no';
        $maxnodeid = 0;
        $innerjoin_sql =  '( select distinct chartid from '.$this->chartTable.'  where ';
        $innerjoin_sql .= ' frommodule = ? and chartmodule = ? and ( (chartrecord = ? ) or (fromrecord = ? and haverecordchart = "no") )) as tmp on tmp.chartid = '.$this->chartTable.'.chartid ';
        $sql = 'select * from '.$this->chartTable.' inner join '.$innerjoin_sql;
        $result = $adb->pquery($sql,array($this->frommodule,$this->chartmodule,$this->fromrecord,$this->fromrecord));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0){
            for ($i=0;$i<$num_rows;$i++){
                $chartrecord = $adb->query_result($result,$i,'chartrecord');
                $nodeid = $adb->query_result($result,$i,'nodeid');
                $childrennodeid = $adb->query_result($result,$i,'childrennodeid');
                if ($this->platform == 'PC'){
                    $arr['chartrecord'] = $chartrecord;
                    $arr['chartid'] = $adb->query_result($result,$i,'chartid');
                }else{
                    $arr['moduleindexid'] = $chartrecord;
                }
                $arr['nodeid'] = $nodeid;
                $arr['parentnodeid'] = $adb->query_result($result,$i,'parentnodeid');
                $arr['childrennodeid'] = $childrennodeid;
                $relationshipChartDataArr[$nodeid]=$arr;

                if (!empty($chartrecord) && $chartrecord != 0){//单据id与节点的关系
                    $chartRecord_nodeidArr[$chartrecord] = $nodeid;
                    $haveRecordNodeArr[$nodeid] = $chartrecord;
                }
                if (!empty($childrennodeid)){
                    $childrennodeid_arr = explode(',',$childrennodeid);
                    foreach ($childrennodeid_arr as $tmp_key => $child_record){
                        $chartRecord_parentnodeidArr[$child_record] = $nodeid;
                    }
                }
                if ($maxnodeid <= $nodeid){//最大节点id
                    $maxnodeid = $nodeid;
                }
            }
            $haveChartData = 'yes';
            $this->getLockStatus();
            unset($chartrecord,$nodeid,$childrennodeid,$arr);
        }
        $this->maxnodeid = $maxnodeid;
        $this->haveChartData = $haveChartData;
        $this->relationshipChartDataArr = $relationshipChartDataArr;
        $this->chartRecord_nodeidArr = $chartRecord_nodeidArr;
        $this->haveRecordNodeArr = $haveRecordNodeArr;
        $this->chartRecord_parentnodeidArr = $chartRecord_parentnodeidArr;
        unset($sql,$innerjoin_sql,$result,$num_rows,$maxnodeid,$haveChartData,$relationshipChartDataArr,$chartRecord_nodeidArr,$haveRecordNodeArr,$chartRecord_parentnodeidArr);
        return $this->relationshipChartDataArr;

    }

    //获取锁定状态
    public function getLockStatus(){
        global $adb;
        $sql = 'select lockstatus from '.$this->lockTable.' where frommodule = ? and chartmodule = ? and record = ? ';
        $result = $adb->pquery($sql,array($this->frommodule,$this->chartmodule,$this->fromrecord));
        if($adb->num_rows($result) > 0){
            $lockstatus = $adb->query_result($result,0,'lockstatus');
        }else{
            $lockstatus = 'no';
        }
        $this->lockstatus = $lockstatus;
        unset($sql,$result,$lockstatus);
        return $this->lockstatus;

    }

    //按照"上级单位"字段获取上下级，并处理为图谱所需数据
    public function getAccountsChartDataByParentid(){
        $focus = $this->chartfocus;
        $fieldinfo = $this->chartfocus->fieldobj->getFieldInfoobjBykey('columnname','parentid');//上级单位
        if (empty($fieldinfo)){//未启用"上级单位"
            $this->haveParentid = 'no';
            return [];
        }else{
            $this->haveParentid = 'yes';
        }
        $fieldlabel = $fieldinfo->getFieldLabel();
        $relationshipChartDataArr = [];
        $maxnodeid = 0;
        $this->lockstatus = '-1';
        $this->arrFixedLabelArr['parentid'] = $fieldinfo->getFieldLabel();
        //获取上下级关系
        $accountid = $this->fromrecord;
        $accounts_list_arr = [];
        $encountered_accounts = [$accountid];
        $accounts_list_arr = $focus->__getParentAccounts($accountid, $accounts_list_arr, $encountered_accounts);
        //因为需要获取所有下级部门信息，所以去除上级部门为当前部门的数据
        foreach($accounts_list_arr as $tmpid=>$tmpinfo){
            if($tmpinfo['parentid'] == $accountid && $tmpinfo['parentid'] != $tmpid){
                unset($accounts_list_arr[$tmpid]);
            }
        }
        $accounts_list_arr = $focus->__getChildAccounts($accountid, $accounts_list_arr, $accounts_list_arr[$accountid]['depth']);
        unset($focus,$accountid,$fieldinfo,$encountered_accounts);
//        dump($accounts_list_arr);
        //上下级关系数据转换为图谱所需数据
        if (!empty($accounts_list_arr) && is_array($accounts_list_arr) && sizeof($accounts_list_arr) > 1){
            //方法1
            $relationshipChartDataArr = $this->transformIntoChartData($accounts_list_arr);
            if (sizeof($relationshipChartDataArr) > 0){
                $maxnodeid = sizeof($relationshipChartDataArr);
                $this->showTipStatus = 'yes';
                $this->showTipContent = getVarFixedLabel('getrelationshipChartByParenidTip',$fieldlabel);
            }
        }
        $this->maxnodeid = $maxnodeid;
        $this->relationshipChartDataArr = $relationshipChartDataArr;
        unset($fieldlabel,$maxnodeid,$relationshipChartDataArr,$accounts_list_arr);
        return $this->relationshipChartDataArr;
    }

    //将上下级关系数据形式处理为图谱需要的数据形似 以depth为主要逻辑处理
    public function transformIntoChartData($accounts_list_arr){
        foreach ($accounts_list_arr as $record => $info){
            $accounts_list_arr[$record]['parentid'] = 0;
            $depth = $info['depth'];
            break;
        }
        $nodeid = 1;
        $haveRecordNodeArr = [];
        while (empty($break)){
            $break = 1;
            foreach ($accounts_list_arr as $record => $info){
                if ($info['depth'] == $depth){
                    $record_nodeid[$record] = $nodeid;
                    $parentid = $info['parentid'];
                    $relationshipChartDataArr[$nodeid]['parentnodeid'] = empty($record_nodeid[$parentid])?0:$record_nodeid[$parentid];
                    $relationshipChartDataArr[$nodeid]['nodeid'] = $nodeid;
                    if ($this->platform == 'PC'){
                        $relationshipChartDataArr[$nodeid]['chartrecord'] = $record;
                    }else{
                        $relationshipChartDataArr[$nodeid]['moduleindexid'] = $record;
                    }
                    $relationshipChartDataArr[$nodeid]['childrennodeid'] = '';
                    if ($info['parentid'] != $record){
                        $children[$parentid][] = $record;
                    }
                    $haveRecordNodeArr[$nodeid] = $record;
                    $nodeid++;
                    $break = 0;
                }
            }
            $depth++;
        }
        unset($children[0]);
        foreach ($children as $record => $child_arr){
            $childnodeid = [];
            $nodeid = $record_nodeid[$record];
            foreach ($child_arr as $index => $child_record){
                $childnodeid[]=$record_nodeid[$child_record];
            }
            $relationshipChartDataArr[$nodeid]['childrennodeid'] = implode(',',$childnodeid);
        }
        $this->relationshipChartDataArr = $relationshipChartDataArr;
        $this->haveRecordNodeArr = $haveRecordNodeArr;
        unset($relationshipChartDataArr,$haveRecordNodeArr,$nodeid,$depth,$break,$accounts_list_arr,$childnodeid,$record_nodeid);
        return $this->relationshipChartDataArr;
    }

    /*
     * transformIntoChartData的另一种处理方式 以parentid
    public function transformIntoChartData2($accounts_list_arr,&$parentidArr=array(0),&$nodeid=0){
        while(sizeof($parentidArr) > 0) {
            $parentid = array_shift($parentidArr);//队列 先进先出 避免递归的栈溢出
            $children = [];
            foreach ($accounts_list_arr as $record => $info) {//获取下级
                if ($info['parentid'] == $parentid) {
                    if (!empty($this->chartRecord_parentnodeidArr[$record])) {
                        continue;
                    }
                    $nodeid++;
                    $this->haveRecordNodeArr[$nodeid] = $record;

                    $this->chartRecord_nodeidArr[$record] = $nodeid;//单据ID--对应节点
                    $this->chartRecord_parentnodeidArr[$record] = $this->chartRecord_nodeidArr[$parentid];//单据ID--对应单据的上级节点
                    if ($info['parentid'] != $record){
                        $children[] = $nodeid;
                    }
                    $parentidArr[] = $record;
                }
            }
            if ($parentid != 0) {
                $tmp_nodeid = $this->chartRecord_nodeidArr[$parentid];
                $this->relationshipChartDataArr[$tmp_nodeid] = array(
                    'parentnodeid' => $this->chartRecord_parentnodeidArr[$parentid],
                    'childrennodeid' => implode(',', $children),
                    'chartrecord' => $parentid,
                    'nodeid' => $tmp_nodeid
                );
            }
            $this->transformIntoChartData2($accounts_list_arr, $parentidArr, $nodeid);
        }
    }
    */


    //获取默认数据
    public function getDefaultChartData(){
        if ($this->platform == 'PC'){
            $relationshipChartDataArr = array(
                1=>array('nodeid'=>1,'parentnodeid'=>0,'childrennodeid'=>2,'chartrecord'=>''),
                2=>array('nodeid'=>2,'parentnodeid'=>1,'childrennodeid'=>'','chartrecord'=>'')
            );
        }else{
            $relationshipChartDataArr = array(
                1=>array('nodeid'=>1,'parentnodeid'=>0,'childrennodeid'=>2,'moduleindexid'=>''),
                2=>array('nodeid'=>2,'parentnodeid'=>1,'childrennodeid'=>'','moduleindexid'=>'')
            );
        }
        $this->maxnodeid = 2;
        $this->lockstatus = '-1';
        $this->relationshipChartDataArr = $relationshipChartDataArr;
        unset($relationshipChartDataArr);
        return $this->relationshipChartDataArr;
    }

    //获取左侧列表数据
    public function getLeftListData(){
        global $adb;
        if (!empty($this->relatedRecordsArr)){
            return $this->relatedRecordsArr;
        }
        $sql = 'select * from ld_relationshipChartListData where frommodule=? and chartmodule=? and fromrecord = ?';
        $result = $adb->pquery($sql,array($this->frommodule,$this->chartmodule,$this->fromrecord));
        $num_rows = $adb->num_rows($result);
        $relatedRecordsArr = [];
        if ($num_rows > 0){
            $records = $adb->query_result($result,0,'records');
            $relatedRecordsArr = explode(',',$records);
            unset($records);
        }
        if (!empty($this->haveRecordNodeArr) && sizeof($this->haveRecordNodeArr) > 0){//合并图谱中的单据
            $key_arr = array_values($this->haveRecordNodeArr);
            $relatedRecordsArr = array_unique(array_merge($relatedRecordsArr,$key_arr));
            unset($key_arr);
        }
        if (empty($relatedRecordsArr)){//默认值
            if ($this->frommodule == 'Accounts' && $this->chartmodule == 'Accounts'){//客户的客户图谱
                $relatedRecordsArr = array($this->fromrecord);
            }
        }
        $this->relatedRecordsArr = array_values($relatedRecordsArr);
        unset($sql,$result,$num_rows,$relatedRecordsArr);
        return $this->relatedRecordsArr;
    }

    //更新锁定状态
    public function updateLockStatus($lockstatus){
        global $adb;
        //锁定数据
        $select_sql = 'select group_concat(chartrecord) as records from '.$this->chartTable.' inner join ';
        $inner_join_sql = '(select chartid from '.$this->chartTable.' where frommodule = ? and chartmodule = ? and (chartrecord = ? ) or (fromrecord = ? and haverecordchart = "no") ) as tmp on tmp.chartid = '.$this->chartTable.'.chartid ';
        $select_sql .= $inner_join_sql.' where '.$this->chartTable.'.chartrecord <> 0 ';
        $select_result = $adb->pquery($select_sql,array($this->frommodule,$this->chartmodule,$this->fromrecord,$this->fromrecord));
        if ($adb->num_rows($select_result) > 0){
            $records = $adb->query_result_all($select_result)[0]['records'];
        }
        $records_arr = explode(',',$records);
        if (!empty($records_arr) && !in_array($this->fromrecord,$records_arr)){
            $records_arr[] = $this->fromrecord;
        }
        $records_arr = array_unique($records_arr);
        if($lockstatus == 'no'){
            $new_record_nodeid = implode(',',$records_arr);
            $lock_deletesql = 'delete from '.$this->lockTable.' where record in ('.$new_record_nodeid.') and frommodule = ? and chartmodule = ? ';
            $adb->pquery($lock_deletesql,array($this->frommodule,$this->chartmodule));
            unset($new_record_nodeid,$lock_deletesql);
        }else{
            $lock_insertsql = 'insert into '.$this->lockTable.'(frommodule,fromrecord,chartmodule,record,lockstatus) values(?,?,?,?,?)';
            foreach ($records_arr as $tmp_key => $record){
                if ($record != 0 && !empty($record)){
                    $adb->pquery($lock_insertsql,array($this->frommodule,$this->fromrecord,$this->chartmodule,$record,'yes'));
                }
            }
            unset($lock_insertsql);
        }
        unset($select_sql,$inner_join_sql,$select_result,$records,$records_arr);
        return $lockstatus;

    }

    //获取相关信息id
    public function setRelationId($relationid){
        $this->relationid = $relationid;
    }

    //获取相关信息属性数据
    public function getRelatedListInfo(){
        global $adb;
        if (!empty($this->relationid) && !empty($this->relatedListInfo[$this->relationid])){
            return $this->relatedListInfo[$this->relationid];
        }
        if (!empty($this->relationid)){
            $sql = 'select * from ld_relatedlists where relation_id=?';
            $result = $adb->pquery($sql,array($this->relationid));
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0){
                $relatedListInfo[$this->relationid] = $adb->query_result_all($result)[0];
            }
        }else{
            $sql = 'select * from ld_relatedlists where tabid=? and related_tabid=? and label=? and `name`=?';
            $result = $adb->pquery($sql,array(getTabid($this->frommodule),'-20', $this->chartmodule.'_relationshipChart','get_relationshipChart'));
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0){
                $this->relationid = $adb->query_result($result,0,'relation_id');
                $relatedListInfo[$this->relationid] = $adb->query_result_all($result)[0];
            }
        }
        $this->relatedListInfo = $relatedListInfo;
        unset($sql,$result,$num_rows,$relatedListInfo);
        return $this->relatedListInfo;


    }


    //获取显示字段设置的内容
    public function getShowFieldSetHtml(){
        $allShowField = $this->getAllShowField();
        $showFieldsetInfo = $this->getShowFieldSetInfo();

        foreach($showFieldsetInfo as $columnname => $fieldinfo) {
            $moduleInfo = explode(':',$fieldinfo['columns']);
            $moduleName = explode('_',$moduleInfo[3]);
            $columns=$moduleInfo[0].':'.$moduleInfo[1].':'.$moduleInfo[2].':'.$moduleName[0].'_fieldlabel:'.$moduleInfo[4];
            $fieldlabel = $fieldinfo['fieldlabel'];
            $rightlist[$columns] = getTranstab($moduleName[0]) . '_' . $fieldlabel;
            unset($columns,$fieldlabel,$moduleInfo);
        }
        if(!empty($rightlist)) {
            $allShowField = array_diff($allShowField,$rightlist);
            //服务收费时，有可能客户字段的标签名跟服务收费的标签名不一致，所以需要用键值进行查重（键值是一致的）
            if('ServiceCharge' == $this->chartmodule){
                $allShowField = array_diff_key($allShowField,$rightlist);
            }
        }
        $smarty = new lingdangCRM_Smarty;
        $smarty->assign("PRODUCTLISTVIEWALL",$allShowField);//获取所有模块界面字段
        $smarty->assign("HAVEPRODUCTLISTVIEWALL",$rightlist);//获取已选择列头
        setGLobalURLSmarty($smarty);
        $content= $smarty->fetch("ModuleMapfield.tpl");
        $arr['content'] = $content;
        $arr['frommodule'] = $this->frommodule;
        $arr['chartmodule'] = $this->chartmodule;
        $arr['fromrecord'] = $this->fromrecord;
        $arr['title'] = getFixedLabel('SETMAPDISPLAYFIELD');
        $arr['oktext'] = getFixedLabel('SAVE');
        $arr['canceltext'] = getFixedLabel('CANCEL');
        unset($content,$smarty,$allShowField,$showFieldsetInfo,$rightlist);
        return $arr;
    }

    //获取模块图谱可选择字段
    public function getAllShowField(){
        $module = $this->chartmodule;
        $focus = CRMEntity::getInstance($module);
        $main_module_fields=$focus->fieldobj->getModuleFields();
        foreach($main_module_fields as $fieldname=>$fieldinfo)
        {
            $tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            if($fieldinfo && ($fieldinfo->getSaveDataBase()=='no')){
                continue;
            }
            //附件、图片、签到字段不显示
            if($tablename=='ld_attachments'||$fieldinfo->getUIType()==69||$fieldinfo->getUIType()==222){
                continue;
            }
            $typeofdata = $fieldinfo->getTypeOfData();
            $types=explode('~',$typeofdata);
            $typeofname=$types[0];
            $fieldlabel=$fieldinfo->getFieldLabelKey();
            if(!empty($columnname)){
                if($module == 'ServiceCharge'){
                    $module = 'Accounts';
                }
                $arr[$tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$typeofname]=getTranstab($module).'_'.$fieldlabel;
            }
        }
        return $arr;
    }

    //获取显示设置字段内容
    public function getShowFieldSetInfo($isDefault = false){
        global $adb;
        if(!empty($this->showFieldInfoArr)){
            return $this->showFieldInfoArr;
        }
        $showFieldInfoArr = [];
        $focus = $this->chartfocus;
        $frommodule = $this->frommodule;
        if ($isDefault){
            $frommodule = 'Default';
        }
        $sql = 'select * from ld_moduledatashowview where frommodule=? and modulename=? order by sequence;';
        $result = $adb->pquery($sql,array($frommodule,$this->chartmodule));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i=0;$i<$num_rows;$i++)
            {
                $columns = $adb->query_result($result,$i,'columns');
                $columns_arr = explode(':',$columns);
                $columnname = $columns_arr[1];
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                if(!empty($fieldinfo)){
                    $fieldlabel = $fieldinfo->getFieldLabel();
                    $fieldname = $fieldinfo->getFieldName();
                    $tablename = $fieldinfo->getTableName();
                    $column_arr = array();
                    $column_arr['columns'] = $columns;
                    $column_arr['columnname'] = $columnname;
                    $column_arr['fieldname'] = $fieldname;
                    $column_arr['tablename'] = $tablename;
                    $column_arr['fieldlabel'] = $fieldlabel;
                    $column_arr['fieldinfo'] = $fieldinfo;
                    if ($columnname == 'tag' && $fieldname == 'tag'){
                        $blockid = $fieldinfo->getBlockid();
                        $display_status = getBlocksDisplayStatus($blockid);
                        if ($display_status != 2){
                            $this->haveTagField = 'yes';
                            $taginfo=$column_arr;
                        }
                        unset($blockid,$display_status);
                    }else{
                        $showFieldInfoArr[$columnname] = $column_arr;
                    }
                    unset($column_arr,$fieldinfo);
                }
            }
            if (isset($taginfo)){
                $showFieldInfoArr[$taginfo['columnname']]=$taginfo;
                unset($taginfo);
            }
        }
        else if (!$isDefault){
            //未获取到字段信息
            $showFieldInfoArr = $this->getShowFieldSetInfo(true);
        }
        $this->showFieldInfoArr = $showFieldInfoArr;
        unset($showFieldInfoArr,$focus,$frommodule,$sql,$result,$num_rows );
        return $this->showFieldInfoArr;
    }

    //保存显示字段设置
    public function saveShowFieldSet($showFields){
        global $adb;
        //先删除该设置之前的全部数据
        $deletesql = "delete from ld_moduledatashowview where frommodule =? and modulename = ? ";
        $adb->pquery($deletesql,array($this->frommodule,$this->chartmodule));
        //再插入新数据
        $showFieldArr = explode(',',$showFields);
        if (!empty($showFieldArr)){
            $insertsql = 'insert into ld_moduledatashowview(frommodule,modulename,columns,sequence) value (?,?,?,?)';
            foreach ($showFieldArr as $index => $columns){
                $adb->pquery($insertsql,array($this->frommodule,$this->chartmodule,$columns,$index+1));
            }
            unset($insertsql);
        }
        unset($deletesql,$showFieldArr);

    }

    //设置图谱中左侧列表的单据
    public function setRelatedRecords($relatedRecords){
        if (is_array($relatedRecords)){
            $relatedRecordsArr = array_values(array_unique(array_filter($relatedRecords)));
            $this->relatedRecordsArr = $relatedRecordsArr;
        }else{
            $relatedRecordsArr = explode(',',$relatedRecords);
            $relatedRecordsArr = array_values(array_unique(array_filter($relatedRecordsArr)));
            $this->relatedRecordsArr = $relatedRecordsArr;
        }
        unset($relatedRecordsArr);
    }

    //获取数据,刷新图谱和列表
    public function refreshChartAndList($type = ''){
        //获取单据显示字段的数据
        $this->getRelatedRecordData();
        $arr['showFieldInfoArr'] = $this->showFieldInfoArr;
        $arr['leftListDataArr'] = $this->leftListDataArr;
        $arr['tagDataByRecordArr'] = $this->tagDataByRecordArr;
        $arr['relatedRecordsArr'] = $this->relatedRecordsArr;
        if ($type == 'saveShowFieldSet'){
            $arr['haveTagField'] = $this->haveTagField;
        }
        if ($type == 'getParentidChart'){
            $arr['relationshipChartDataArr'] = $this->relationshipChartDataArr;
            $arr['haveRecordNodeArr'] = $this->haveRecordNodeArr;
            $arr['maxnodeid'] = $this->maxnodeid;
        }
        return $arr;
    }

    //根据显示字段，获取单据数据
    public function getRelatedRecordData(){
        global $adb,$current_user;
        $chartfocus = $this->chartfocus;
        $this->leftListDataArr = [];
        $sqlArr = $this->getSelectColumnsAndLeftJoin();
        $relatedRecord = $this->getLeftListData();
        //获取标签数据
        $this->getRecordTagData();
        $chart_table_index=$chartfocus->table_index;
        $chart_table_name=$chartfocus->table_name;
        if (!empty($relatedRecord)){
            $wheresql = ' and '.$chart_table_name.'.'.$chart_table_index.' in ('.implode(',',$relatedRecord).')';
        }else{
            unset($relatedRecord,$sqlArr,$chartfocus);
            return [];
        }
        $selectcolumn = $sqlArr['selectcolumn'];
        $selectField =$sqlArr['selectField'];
        $leftjoin = $sqlArr['leftjoin'];
        $showFieldInfoArr =$this->showFieldInfoArr;

        $relationInfo=$this->getRelatedListInfo();
        if(!empty($relationInfo['related_coltable'])){
            $wheresql .= ' and ld_'.$relationInfo['related_coltable'].'= '.$this->fromrecord.' ';
        }

        $customView = CustomView::getInstance($this->chartmodule);
        $queryGenerator = QueryGenerator::getInstance($this->chartmodule, $current_user, $customView);
        $smownerSearchSql = $queryGenerator->getSmOwnerSearchSql;
        $chart_index = $chart_table_name.'.'.$chart_table_index;
        $record_sql = "select distinct $chart_index from  $chart_table_name  $leftjoin WHERE $chart_table_name.deleted = 0  $wheresql $smownerSearchSql";
        $case_sql = " case when $chart_index in ($record_sql) then 'yes' else 'no' end as havepermittedtoview ";

        $sql = "select $chart_index,".$selectcolumn.','.$case_sql." from $chart_table_name $leftjoin";
        $sql.=" inner join( select distinct $chart_index from $chart_table_name  $leftjoin where $chart_table_name.deleted = 0
           $wheresql) as temp 
                on temp.$chart_table_index=$chart_index where $chart_table_name.deleted = 0
           $wheresql  group by $chart_index order by $chart_index desc";
        $result = $adb->pquery($sql,array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0){
            $leftListData = $adb->query_result_all($result);
            $accountallview = $current_user->accountallview;
            $is_admin = is_admin($current_user);
            $hrefFieldInfo = $this->hrefFieldInfoArr;
            $hrefColumnname = $hrefFieldInfo['columnname'];
            crm_load_class_file('Cls_FieldShowValue', 'modules/Users');
            foreach ($leftListData as $index => $info){
                $record = $info[$chart_table_index];
                $cls_fieldshowvalueobj = new Cls_FieldShowValue($this->chartmodule,$record,$chart_table_index);
                foreach ($info as $tmp_columnname => $value){
                    if ($tmp_columnname == 'havepermittedtoview'){
                        if ($is_admin || $accountallview == 1){//管理员权限 全部相关信息数据权限
                            $info['havepermittedtoview'] = 'yes';
                        }
                        if ($this->platform == 'mobile'){//移动端
                            if ($info['havepermittedtoview'] == 'yes'){
                                $info['permitted_msg'] = '';
                            }else{
                                $info['permitted_msg'] = getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE');
                            }
                            unset($info['havepermittedtoview']);
                        }
                    }else{
                        $fieldname = $selectField[$tmp_columnname]['fieldname'];
                        $tablename = $selectField[$tmp_columnname]['tablename'];
                        if ($this->chartmodule == 'Accounts' && $this->frommodule == 'Accounts' && $tablename == 'ld_contactdetails'){

                        }
                        else if (!empty($fieldname)){
                            $cls_fieldshowvalueobj->resetfieldname($fieldname);
                            $showfieldvalue = $cls_fieldshowvalueobj->getShowfieldValue();
                            $value = $showfieldvalue['value'];
                            if ($this->platform == 'PC'){
                                if ($hrefColumnname == $tmp_columnname){//超链接字段
                                    $value = '<a class="href" style="overflow: hidden;text-overflow: ellipsis;white-space: nowrap;display:inline-block;width:90%;" name="title" lasturl=""';
                                    $value .= ' fieldname="'.$fieldname.'" module="'.$this->chartmodule.'" record="'.$record.'"';
                                    $value .= ' href="index.php?pageto_module='.$this->chartmodule.'&pageto_action=index&pageto_record='.$record.'"';
                                    $value .= ' onclick="ListLinkClick(ld(this),event)" data-tip="'.$showfieldvalue['value'].'" data-direction="top" data-type="position">'.$showfieldvalue['value'].'</a>';
                                }
                            }
                            else{//移动端
                                $value = empty($value) ? getFixedLabel('VALUENONE') : $value;
                                $tmp_fieldinfo = $showFieldInfoArr[$tmp_columnname];
                                $tmp_uitype = $tmp_fieldinfo['uitype'];
                                if ($tmp_uitype == 301){//标签
                                    $tmp_recordTagArr = $this->tagDataByRecordArr[$record];//单据标签内容
                                    $value = '<span tag="label" style="white-space: nowrap;font-size:12px;">'.$tmp_fieldinfo['fieldlabel'].':</span><span class="module_list_tagger_span" name="module_list_tagger_span_' . $indexvalue . '">';
                                    if (!empty($tmp_recordTagArr)){
                                        foreach ($tmp_recordTagArr as $tmp_tagid => $tmp_tagArr){
                                            if ($tmp_tagArr['tag_type'] == 'personal'){
                                                $tag_style = 'color:#68DA94;background: rgba(104, 218, 148, 0.2);margin-right:5px;';
                                            }else{
                                                $tag_style = 'color: #EB8473;background: rgba(235, 132, 115, 0.2);margin-right:5px;';
                                            }
                                            $value .= '<span style="'.$tag_style.'" tag_id="' . $tmp_tagid . '">' . $tmp_tagArr['tag'] . '</span>';
                                        }
                                        unset($tag_style,$tmp_recordTagArr);
                                    }else{
                                        $value .= '<span>'.getFixedLabel('VALUENONE').'</span>';
                                    }
                                    $value .= '</span>';
                                }else{
                                    if ($tmp_uitype == 15){
                                        $tmp_color = $tmp_fieldinfo['textColor'][$value];
                                    }else{
                                        $tmp_color = $tmp_fieldinfo['textColor'];
                                    }
                                    if (!empty($tmp_color)){
                                        $info[$tmp_columnname.'_style'] = 'color:'.$tmp_color.';';
                                    }
                                    unset($tmp_color);
                                }
                                unset($tmp_fieldinfo,$tmp_uitype);
                            }
                        }
                        $info[$tmp_columnname] = $value;
                    }
                }
                $leftListDataArr[$record] = $info;
                unset($cls_fieldshowvalueobj);
            }
            unset($leftListData,$accountallview,$is_admin,$hrefFieldInfo,$hrefColumnname);
        }
        $this->leftListDataArr = $leftListDataArr;
        unset($leftListDataArr,$customView,$queryGenerator,$smownerSearchSql,$record_sql,$case_sql,$sql,$wheresql,$result,$num_rows,$relatedRecord,$showFieldInfoArr,$sqlArr,$selectcolumn,$selectField,$leftjoin,$chartfocus);
        return  $this->leftListDataArr;
    }

    //获取显示字段查询sql的columns和left join
    public function getSelectColumnsAndLeftJoin(){
        $focus = $this->chartfocus;
        $table_name = $focus->table_name;
        $table_index = $focus->table_index;
        //获取字段内容和颜色
        $this->getShowFieldAllColor();

        $leftjointable = [];
        $selectcolumn_arr = [];
        foreach($this->showFieldInfoArr as $key=>$info) {
            $tablename = $info['tablename'];
            if($tablename!=$focus->table_name){
                $leftjointable[$tablename] = " left join ".$tablename." on $tablename.$table_index = $table_name.$table_index ";
                if ($this->chartmodule == 'Accounts' && $tablename == 'ld_contactdetails'){//首要联系人
                    $leftjointable[$tablename] .= ' and '.$tablename.'.reference = 1';
                }
            }
            $columnname = $info['columnname'];
            $fieldname = $info['fieldname'];
            $selectcolumn_arr[$fieldname]=$tablename.'.'.$columnname;
            $selectField[$columnname]=array('fieldname'=>$fieldname,'tablename'=>$tablename);
            unset($tablename,$columnname,$fieldname);
        }

        //超链接字段
        $entityfield = getEntityField($this->chartmodule);
        $hreffieldfieldname = $entityfield['fieldname'];
        $hreffieldinfo = $this->chartfocus->fieldobj->getFieldInfoobjBykey('fieldname',$hreffieldfieldname);
        if(!empty($hreffieldinfo)){
            $hreffieldcolumnname = $hreffieldinfo->getColumnName();
            $hreffieldtablename = $hreffieldinfo->getTableName();
            $this->hrefFieldInfoArr = array('columnname'=>$hreffieldcolumnname,'tablename'=>$hreffieldtablename,'fieldinfo'=>$hreffieldinfo);
            if(!array_key_exists($hreffieldfieldname,$selectcolumn_arr)){
                $selectcolumn_arr[$hreffieldfieldname]= $hreffieldtablename.'.'.$hreffieldcolumnname;
                $selectField[$hreffieldcolumnname]=array('fieldname'=>$hreffieldfieldname,'tablename'=>$hreffieldtablename);
                if(in_array($hreffieldtablename,$focus->tab_name)&&$hreffieldtablename!=$focus->table_name){
                    $leftjointable[$table_name] = " left join ".$table_name." on $table_name.$table_index = $table_name.$table_index ";
                }
            }
            unset($hreffieldcolumnname,$hreffieldtablename);
        }
        unset($entityfield,$hreffieldfieldname,$hreffieldinfo);

        $selectcolumn = implode(',',$selectcolumn_arr);
        $leftjoin = implode(' ',$leftjointable);
        $arr = array('selectcolumn'=>$selectcolumn,'leftjoin'=>$leftjoin,'selectField'=>$selectField);
        unset($focus,$leftjoin,$selectcolumn,$leftjointable);
        return $arr;
    }

    //获取字段颜色
    public function getShowFieldAllColor(){
        global $global_picklist_colors_byvalue;
        $showFieldInfoArr = $this->getShowFieldSetInfo();
        crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
        $picklistobj = new cls_PickList_Ori();
        foreach ($showFieldInfoArr as $key => $info){
            $fieldname = $info['fieldname'];
            $fieldinfo = $info['fieldinfo'];
            $uitype = $fieldinfo->getUIType();
            $showFieldInfoArr[$key]['uitype'] = $uitype;
            $labelColor = $fieldinfo->label_style_arr['color'];
            $showFieldInfoArr[$key]['labelColor'] = empty($labelColor)?'#3B4859':$labelColor;
            if ($uitype == 15){//下拉框
                $textColorArr = $global_picklist_colors_byvalue[$fieldname];
                if (empty($textColorArr)){
                    $picklistobj->getPickListValues($fieldname,$fieldinfo,'','');
                    $textColorArr = $global_picklist_colors_byvalue[$fieldname];
                }
                $showFieldInfoArr[$key]['textColor'] = $textColorArr;
            }elseif ($uitype == 301){//标签
                $showFieldInfoArr[$key]['textColor'] = array(
                    'personal'=>array('color'=>'#68DA94','background'=>'rgba(104, 218, 148, 0.2)'),
                    'company'=>array('color'=>'#EB8473','background'=>'rgba(235, 132, 115, 0.2)')
                );
            }
            else{
                $showFieldInfoArr[$key]['textColor'] = $fieldinfo->getFieldValueColor();
            }
            unset($fieldinfo,$labelColor,$fieldname);
        }
        $this->showFieldInfoArr = $showFieldInfoArr;
        unset($showFieldInfoArr,$picklistobj);
        return $this->showFieldInfoArr;
    }

    //获取标签数据
    public function getRecordTagData(){
        $tagDataByRecordArr = [];
        if ($this->haveTagField == 'yes'){
            crm_load_class_file('cls_moduledata_tag','include/utils');
            foreach ($this->relatedRecordsArr as $index => $record){
                $cls_moduledata_tag = new cls_moduledata_tag($this->chartmodule,$record);
                $moduledata_tag = $cls_moduledata_tag->getModuledataTagForUser();
                if (!empty($moduledata_tag)){
                    $tagDataByRecordArr[$record]=$moduledata_tag;
                }
            }
            unset($cls_moduledata_tag,$moduledata_tag);
        }
        $this->tagDataByRecordArr = $tagDataByRecordArr;
        unset($tagDataByRecordArr);
        return $this->tagDataByRecordArr;
    }


    //获取已选客户的相关客户
    public function getRelatedRecordsBySelect($selectrelatedRecords,$oldrelatedRecords){
        global $adb;
        $inner_join_sql = '(select distinct chartid from '.$this->chartTable.' where frommodule = ? and chartmodule = ? and chartrecord in ('.$selectrelatedRecords.')) as tmp on tmp.chartid = '.$this->chartTable.'.chartid';
        $select_sql = 'select group_concat(chartrecord) as chartrecord from '.$this->chartTable.' inner join '.$inner_join_sql.' where chartrecord <> 0';

        $result = $adb->pquery($select_sql,array($this->frommodule,$this->chartmodule));
        $num_rows = $adb->num_rows($result);
        $haveMsgTip = 'no';
        if ($num_rows > 0){
            $records = $adb->query_result_all($result)[0]['chartrecord'];
            $relatedRecords = $records.','.$oldrelatedRecords;
            if (!empty($records)){
                $haveMsgTip = 'yes';
            }
        }
        $relatedRecords = $relatedRecords.','.$selectrelatedRecords;
        $this->setRelatedRecords($relatedRecords);
        $arr = $this->refreshChartAndList('selectRelatedRecords');
        $arr['haveMsgTip'] = $haveMsgTip;
        unset($haveMsgTip,$selectrelatedRecordsArr,$oldrelatedRecordsArr,$inner_join_sql,$select_sql,$result,$num_rows,$records_arr,$records,$relatedRecord,$selectrelatedRecords,$oldrelatedRecords);//unset
        return $arr;
    }

    //获取单据拖拽后的相关图谱
    public function getRelatedChart($currentnodeid,$relatedRecords,$maxnodeid){
        $relationshipChartDataArr = $this->getRelationshipChartDataInfo();
        //拖拽的单据的数据
        $nodeid = $this->chartRecord_nodeidArr[$this->fromrecord];
        if (empty($relationshipChartDataArr) || empty($nodeid) || empty($relationshipChartDataArr[$nodeid]['childrennodeid']) ){//无数据
            return '';
        }
        $nodeinfo = $relationshipChartDataArr[$nodeid];
        //重新赋值新节点 获取老节点和新节点的关系 $old_new_nodeidarr
        $old_new_nodeidarr[$nodeid] = $currentnodeid;
        $current_childrennodeid = $nodeinfo['childrennodeid'];
        $children_arr = explode(',',$current_childrennodeid);
        $children_arr = array_filter($children_arr);
        while (sizeof($children_arr) > 0){
            $childrennodeid = array_shift($children_arr);//先进先出
            if (empty($old_new_nodeidarr[$childrennodeid])){//没有关系才创建关系
                $old_new_nodeidarr[$childrennodeid] = $maxnodeid + 1;
                $maxnodeid++;
            }
            $child_childrennodeid = $relationshipChartDataArr[$childrennodeid]['childrennodeid'];
            if (!empty($child_childrennodeid)){//有相关单据的数据处理
                $child_childrennodeid_arr = explode(',',$child_childrennodeid);
                $children_arr = sizeof($children_arr) > 0 ? array_merge($children_arr,$child_childrennodeid_arr) : $child_childrennodeid_arr;
                $children_arr = array_unique(array_filter($children_arr));
            }
            unset($child_childrennodeid_arr,$child_childrennodeid);
        }

        //根据$old_new_nodeidarr 新旧节点的图谱数据转换:nodeid,parentnodeid,childrennodeid
        foreach ($old_new_nodeidarr as $old_nodeid => $new_nodeid){
            $old_nodeinfo = $relationshipChartDataArr[$old_nodeid];
            if(!empty($old_nodeinfo['chartrecord'])){
                $tmp_relatedRecordsArr[] = $old_nodeinfo['chartrecord'];
                $tmp_haveRecordNodeArr[$new_nodeid] = $old_nodeinfo['chartrecord'];
            }
            unset($old_nodeinfo['chartid']);
            $new_nodeinfo = $old_nodeinfo;
            //当前节点处理
            $new_nodeinfo['nodeid'] = $new_nodeid;
            //父节点处理
            if ($old_nodeid == $nodeid){
                $new_nodeinfo['parentnodeid'] = 0;
            }else{
                $new_nodeinfo['parentnodeid'] = $old_new_nodeidarr[$old_nodeinfo['parentnodeid']];
            }
            //子节点处理
            $old_childrennodeid = $old_nodeinfo['childrennodeid'];
            $new_childrennodeid_arr = [];
            $new_childrennodeid = '';
            if (!empty($old_childrennodeid)){
                $tmp_new_childrennodeid_arr = array_filter(explode(',',$old_childrennodeid));
                foreach ($tmp_new_childrennodeid_arr as $tmp_key => $childnodeid){
                    $new_childrennodeid_arr[] = $old_new_nodeidarr[$childnodeid];
                }
                $new_childrennodeid = implode(',',$new_childrennodeid_arr);
                unset($new_childrennodeid_arr,$tmp_new_childrennodeid_arr);
            }
            $new_childrennodeid = empty($new_childrennodeid)?'':$new_childrennodeid;
            $new_nodeinfo['childrennodeid'] = $new_childrennodeid;
            $tmp_relationshipChartDataArr[$new_nodeid] = $new_nodeinfo;
            unset($new_nodeinfo,$new_childrennodeid,$old_childrennodeid,$new_nodeinfo);
        }
        if(!empty($tmp_relatedRecordsArr)){
            $relatedRecords = $relatedRecords.','.implode(',',$tmp_relatedRecordsArr);
        }
        $this->setRelatedRecords($relatedRecords);
        $arr = $this->refreshChartAndList('selectRelatedRecords');
        $arr['maxnodeid'] = $maxnodeid;
        $arr['childRelationshipChartDataArr'] = $tmp_relationshipChartDataArr;
        $arr['child_haveRecordNodeArr'] = $tmp_haveRecordNodeArr;
        unset($relationshipChartDataArr,$tmp_haveRecordNodeArr,$relatedRecords,$old_new_nodeidarr,$children_arr,$nodeinfo,$currentnodeid,$maxnodeid,$tmp_relationshipChartDataArr);
        return $arr;
    }


    //保存
    public function saveChart($relatedRecordsArr,$havenoderecords,$relationshipChartDataArr){
        global $adb;
        $newhavenoderecords = empty($havenoderecords)?$this->fromrecord:$havenoderecords.','.$this->fromrecord;

        //判断图谱是否有单据被锁定
        $lockstatus_selectsql = 'select id from '.$this->lockTable.' where record in ('.$newhavenoderecords.') and frommodule = ? and chartmodule = ?';
        $lockstatus_result = $adb->pquery($lockstatus_selectsql,array($this->frommodule,$this->chartmodule));
        $lockstatus_num_rows = $adb->num_rows($lockstatus_result);
        if ($lockstatus_num_rows > 0 ){
            unset($lockstatus_selectsql,$lockstatus_result,$lockstatus_num_rows);
            return false;
        }
        unset($lockstatus_selectsql,$lockstatus_result,$lockstatus_num_rows);

        //左侧列表数据更新
        if (!empty($relatedRecordsArr)){
            $list_deletesql = 'delete from '.$this->listDataTable.' where frommodule = ? and fromrecord = ? and chartmodule = ? ';
            $adb->pquery($list_deletesql,array($this->frommodule,$this->fromrecord,$this->chartmodule));
            $list_insertsql = 'insert into '.$this->listDataTable.'(frommodule,fromrecord,chartmodule,records) values(?,?,?,?)';
            $adb->pquery($list_insertsql,array($this->frommodule,$this->fromrecord,$this->chartmodule,$relatedRecordsArr));
            unset($list_deletesql,$list_insertsql);//unset
        }

        //更新相关客户旧数据
        //新图谱含有的单据的旧数据更新 chartrecord=>0,oldchartrecord=原来的chartrecord
        //当全部节点的chartrecord = 0 和 haverecordchart = yes 的时候 该图谱数据废弃
        $chart_updatesql = 'update '.$this->chartTable.' set oldchartrecord = chartrecord,chartrecord = 0,haverecordchart = "yes" ';
        $chart_updatesql .= ' where ';
        $chart_updatesql .= '(';
        $chart_updatesql .= ' chartrecord in ('.$newhavenoderecords.')';
        $chart_updatesql .= ' or ';
        //无单据的图谱处理
        if (!empty($haverecordchart)){
            $chart_updatesql .= ' (fromrecord in ('.$haverecordchart.','.$this->fromrecord.') and haverecordchart = "no") ';
        }else{
            $chart_updatesql .= ' (fromrecord = '.$this->fromrecord.' and haverecordchart = "no") ';
        }
        $chart_updatesql .= ') and';
        $chart_updatesql .= ' frommodule = ?  and chartmodule= ?';
        $adb->pquery($chart_updatesql,array($this->frommodule,$this->chartmodule));
        unset($chart_updatesql);

        //新图谱数据插入
        $haverecordchart = empty($havenoderecords)?'no':'yes';//无单据图谱的haverecordchart为no
        $chart_insertsql = 'insert into '.$this->chartTable.'(frommodule,fromrecord,chartmodule,nodeid,chartrecord,parentnodeid,childrennodeid,haverecordchart) values(?,?,?,?,?,?,?,?)';
        foreach ($relationshipChartDataArr as $nodeid => $nodeinfo){
            $adb->pquery($chart_insertsql,array($this->frommodule,$this->fromrecord,$this->chartmodule,$nodeid,$nodeinfo['chartrecord'],$nodeinfo['parentnodeid'],$nodeinfo['childrennodeid'],$haverecordchart));
            $lastinsertid = $adb->getLastInsertID();//插入的自增id
            $tmpid_arr[] = $lastinsertid;
        }
        unset($chart_insertsql,$haverecordchart);
        //更新新图谱数据的chartid
        if (!empty($tmpid_arr) && !empty($lastinsertid) && $lastinsertid > 0){
            $chart_updateChartid_sql = 'update '.$this->chartTable.' set chartid = ? where id in ('.implode(',',$tmpid_arr).') ';
            $adb->pquery($chart_updateChartid_sql,array($lastinsertid));
            unset($chart_updateChartid_sql,$tmpid_arr,$lastinsertid);
        }

        //清除冗余five数据 有效数据：图谱中含有单据 chartrecord>0;或无单据图谱 chartrecord=0且haverecordchart=yes
        $chart_clear_selectsql = 'select group_concat(distinct chartid) as chartid from '.$this->chartTable.' where (chartrecord > 0 or (chartrecord = 0 and haverecordchart = "no")) and frommodule = ? and chartmodule = ? ';
        $chart_clear_result = $adb->pquery($chart_clear_selectsql,array($this->frommodule,$this->chartmodule));
        $chart_clear_num_rows = $adb->num_rows($chart_clear_result);
        if ($chart_clear_num_rows > 0){
            $chartid = $adb->query_result($chart_clear_result,0,'chartid');
            if (!empty($chartid)){
                $chart_clearsql = 'delete from '.$this->chartTable.' where chartid not in ('.$chartid.')';
                $adb->pquery($chart_clearsql,array());
                unset($chart_clearsql,$chartid,$chartid_arr);
            }
        }
        unset($chart_clear_selectsql,$chart_clear_result,$chart_clear_num_rows);
        unset($newhavenoderecords);
        unset($relatedRecordsArr,$havenoderecords,$relationshipChartDataArr);
        return true;
    }


    //移动端数据
    public function getRelationshipChartAllDataOnMobile(){
        $this->setPlatForm('mobile');
        $chartDataArr = $this->getRelationshipChartData();
        $relatedRecordsDataArr = $this->getRelatedRecordData();
        
        $modulemapfieldinfo = [];
        foreach ($this->showFieldInfoArr as $columnname => $fieldinfo){
            $modulemapfieldinfo[] = array(
                'columnname'=>$fieldinfo['columnname'],
                'columns'=>$fieldinfo['columns'],
                'fieldlabel'=>$fieldinfo['fieldlabel'],
                'fieldname'=>$fieldinfo['fieldname'],
                'tablename'=>$fieldinfo['columnname'],
            );
        }
        $arr['arrFixedLabel'] = $this->getArrFixedLabel();//翻译
        $arr['hreffieldcolumnname'] = $this->hrefFieldInfoArr['columnname'];//超链接columnname
        $arr['mapdata_arr'] = array_values($chartDataArr);//图谱节点数据
        $arr['moduledataindex_arr'] = array_keys($relatedRecordsDataArr);//单据id
        $arr['moduledatainfo'] = $relatedRecordsDataArr;//单据内容
        $arr['modulemapfieldinfo'] = $modulemapfieldinfo;//字段内容
        $arr['nomapdata'] = $this->haveChartData == 'yes'?'no':'yes';
        $arr['page_title'] = getFixedLabel('AccountsRelationshipChart');
        unset($chartDataArr,$relatedRecordsDataArr,$modulemapfieldinfo);
        return $arr;
    }












}
?>