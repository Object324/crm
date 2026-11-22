<?php


class CustomTablesActions
{
    public $adb,$language;
    public $smarty;
    public $current_user;
    public $report_info_arr;
    public $except = UNABLE2STATISTICSMODULE;
    
    public function __construct() {
        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->smarty = new lingdangCRM_Smarty();
        $this->report_info_arr=[];
    }
    //创建/删除链接模块
    public function createLinkModule($report_name,$report_id,$linkmodulecheck,$report_type){
        global $currentModule, $current_user;
        $filename='CustomTablesDetailView';
        if($report_type=='sql'){
            $filename='SqlTableDetailView';
        }

        $url = 'index.php?module='.$currentModule.'&action='.$currentModule.'Ajax&file='.$filename.'&function_name=index&isAjax=no&report_id='.$report_id.'&report_type='.$report_type;
        $oldurl = 'index.php?module='.$currentModule.'&action='.$currentModule.'Ajax&file=DetailView&function_name=index&isAjax=no&report_id='.$report_id;//老版本的url
        if($linkmodulecheck=='yes'){
            $sql ='select * from ld_linkmodulecustom where url =? or url=?';
            $result = $this->adb->pquery($sql,array($url,$oldurl));
            $nums = $this->adb->num_rows($result);
            if($nums>0){  //设置里面自己添加的自定义模块
                $sql='update ld_linkmodulecustom set zh_label=? ,en_label=? ,`scope`=? where url=?';
                $this->adb->pquery($sql,array($report_name,$report_name,'all',$url));
            }else{
                $sql='insert into ld_linkmodulecustom(zh_label,en_label,url,`scope`,entitytype,linkmodule)value(?,?,?,?,?,?) ';
                $this->adb->pquery($sql,array($report_name,$report_name,$url,'all','category','CustomTables'));
                $id = $this->adb->getLastInsertID();
                $this->adb->pquery("update ld_linkmodulecustom set name=? where id=?",array("CRMLinkModuleCustom".$id,$id));
            }
        }else{
            //删除菜单设置
            $selectSql = "select * from ld_linkmodulecustom where url =? or url=?";
            $selectRes = $this->adb->pquery($selectSql,array($url,$oldurl));
            $selectNums = $this->adb->num_rows($selectRes);
            if($selectNums>0){
                $linkmoduleId = $this->adb->query_result($selectRes,0,'id');
                //ld_parenttabrel
                $sql ='delete from ld_linkmodulecustom where url =? or url=?';
                $this->adb->pquery($sql,array($url,$oldurl));
                $sql2 ='delete from ld_parenttabrel where tabid =? and tab_tablename="ld_linkmodulecustom"';
                $this->adb->pquery($sql2,array($linkmoduleId));
                //移动端菜单
                $sqlMobile = "delete from ld_mobile_report_tab_rel where tabid =? and tab_tablename='ld_linkmodulecustom'";
                $this->adb->pquery($sqlMobile,array($linkmoduleId));

            }
        }
        //zxm 20230901 修改模块名称需要把拼音模糊搜索的缓存清除掉
        unsetCache('pinyinAlllabel_zh');
        unsetCache('pinyinAlllabel_en');
    }
    //设置列宽
    public function saveResizeData(){
        //select header_width,userid,type,module,columns,relateid from  ld_list_headerwidth
        //columns 存的ld_customtable_columns的ID
        $report_id = $_REQUEST['report_id'];
        $str_width = $_REQUEST['str_width'];
        $str_width = trim($str_width,',');
        $list_width = explode(',',$str_width);
        //按顺序查出来columns数据
        $select_sql = "select * from ld_customtable_columns where report_id=? and visibile<>'no' order by sequence asc";
        $select_res = $this->adb->pquery($select_sql,array($report_id));
        $select_nums = $this->adb->num_rows($select_res);
        $userid = $this->current_user->id;
        $type = 'CustomTables';
        $module = 'CustomTables';
        $insert_arr = [];
        if($select_nums>0){
            for($i=0;$i<$select_nums;$i++){
                $insert_arr[$i] = [];
                $insert_arr[$i]['header_width'] = $list_width[$i];
                $insert_arr[$i]['userid'] = $userid;
                $insert_arr[$i]['type'] = $type;
                $insert_arr[$i]['module'] = $module;
                $insert_arr[$i]['columns'] = $this->adb->query_result($select_res,$i,'id');
                $insert_arr[$i]['relateid'] = $report_id;
                $insert_arr[$i] = implode('","',$insert_arr[$i]);
                $insert_arr[$i] = '("'.$insert_arr[$i].'")';
            }
            $insert_arr = implode(',',$insert_arr);
            $delete_sql = "delete from ld_list_headerwidth where module=? and relateid=? and userid=?";
            $this->adb->pquery($delete_sql,array($module,$report_id,$userid));
            $insert_sql = "insert into ld_list_headerwidth (header_width,userid,type,module,columns,relateid) values $insert_arr";
            $this->adb->pquery($insert_sql);
            // file_put_contents(globalStatic::$root_directory."modules/CustomTales/aa.txt",$insert_sql.date("Y-m-d  H:i:s"));

        }
    }
    public function getTemplate(){
        $parent_sql = "select ld_customtable.report_name,ld_customtable.report_id 
from ld_customtable left join ld_customtable_module m on  ld_customtable.report_id=m.report_id 
left join ld_customtable p on p.report_id=ld_customtable.parent_id 
where ld_customtable.deleted=0 
and ld_customtable.istemplate='yes'
and p.report_name='模板报表' 
order by ld_customtable.`sequence` asc,ld_customtable.createdtime desc;";
        $res = $this->adb->pquery($parent_sql);
        $nums = $this->adb->num_rows($res);
        $list[0] = [
            "label"=>'自定义','list'=>[
                '-1'=>['label'=>'空白模板','name'=>'-1','modules'=>['无']]
            ]
        ];
        if($nums>0) {
            for ($i = 0; $i < $nums; $i++) {
                $parent_id = $this->adb->query_result($res, $i, 'report_id');
                $report_name = $this->adb->query_result($res, $i, 'report_name');
                //文件夹
                $list[$parent_id] = ["label"=>$report_name,'list'=>[]];
                $child_sql = "select ld_customtable.*,m.modulename
from ld_customtable left join ld_customtable_module m on  ld_customtable.report_id=m.report_id 
where ld_customtable.deleted=0 and istemplate='yes' and ld_customtable.parent_id=?
order by parent_id asc,ld_customtable.`sequence` asc,m.parent_id asc ";
                $child_res = $this->adb->pquery($child_sql,array($parent_id));
                $child_nums = $this->adb->num_rows($child_res);
                if($child_nums>0) {
                    for ($j = 0; $j < $child_nums; $j++) {
                        $modulename = $this->adb->query_result($child_res,$j,'modulename');
                        //模块未开启未激活 这个模板应该不显示
                        if(!vtlib_isModuleActive($modulename)){
                            continue;
                        }
                        $report_id = $this->adb->query_result($child_res,$j,'report_id');
                        $report_name2 = $this->adb->query_result($child_res,$j,'report_name');
                        $tabname = getTranstab($modulename);
                        $list[$parent_id]['list'][$report_id]['label'] = $report_name2;
                        $list[$parent_id]['list'][$report_id]['name'] = $report_id;
                        $list[$parent_id]['list'][$report_id]['modules'][] = $tabname;
                    }
                }
            }
        }
        return $list;
    }
    /**
     * @param $modules
     * @param $nextSelectedArr//下游模块数组
     * @return array
     * 获取选中模块的字段
     */
    public function getModuleFields($modules,$mainmodule,$nextSelectedArr){
        $i=0;
        $searchFieldRes = [];
        $moduleCount = count($modules);
        $isReadDetailField='no';
        foreach($modules as $k=>$tmpModule)
        {
            if(empty($tmpModule)){
                continue;
            }
//            if($tmpModule==$mainModule)
//            {
//                $isReadDetailField='yes';//仅主模块需要读取分录字段
//            }
            $focus = CRMEntity::getInstance($tmpModule);
            $moduleName = getTranstab($tmpModule);
            $tempOption = $this->getFieldArrByBigType($focus,'',$tmpModule,'no');
            $searchFieldRes[$i] = ['modulename'=>$tmpModule,'label'=>$moduleName,'child'=>$tempOption];
            //搜索字段 search
            ++$i;
            //zxm 2022-4-21费用报销单的分录字段没有显示
            //BUG0056088  自定义报表选择服务收费管理和服务合同，没有显示分录明细
            
            if($isReadDetailField=='no'
                &&(get_file_address($tmpModule,"ProductDetails") or !empty($focus->detailfieldobj) )
                &&$tmpModule!='ServiceCharge'
                &&$tmpModule!='Products'
                &&($tmpModule==$mainmodule||in_array($tmpModule,$nextSelectedArr))
            )
            {
                //第一个有分录的模块显示分录字段 其他模块不显示分录字段
                $isReadDetailField='yes';
                $tempOption = $this->getFieldArrByBigType($focus,'',$tmpModule,'yes');
                if(!empty($tempOption)){
                    $searchFieldRes[$i] =  ['modulename'=>$tmpModule,'label'=>$moduleName.'_'.getFixedLabel('DETAIL'),'child'=>$tempOption];
                    ++$i;
                }

            }
        }
        return $searchFieldRes;
    }
    //根据字段类型和模块名获取模块下的所有字段
    public function getFieldArrByBigType($focus,$bigtype,$tmpModule,$isReadDetailField)
    {

        if($isReadDetailField=='no')
        {
            if(empty($bigtype)){
                $fieldinfo_arr = $focus->fieldobj->getListSearchFields();
            }else{
                $fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",$bigtype);
            }
            $tempOption = [];
            foreach($fieldinfo_arr as $fieldInfo)
            {
            
                if($focus->module_name=='Accounts'&&($fieldInfo->getTableName()=='ld_contactdetails'||$fieldInfo->getTableName()=='ld_contactscf'))
                    continue;
                $label = $fieldInfo->getFieldLabel();
                $typeOfData = $fieldInfo->getTypeOfData();
                $typeOfData = explode('~',$typeOfData);
                $bigtype = $fieldInfo->getBigType();
                //2022-02-07 0049866: 自定义报表》新建》选择合同订单，“表单码”这种二维码字段不应该显示在报表可选字段中
                if ($bigtype == 'qrcode') continue;

                $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $tmpModule . "_fieldlabel:" . $typeOfData[0];
                $tempOption[] = ['bigtype'=>$bigtype,'value'=>$optionValue,'label'=>$label,'columnmodule'=>$tmpModule,'typeofdata'=>$typeOfData[0],'detailField'=>"no"];
            }
        }
        if($isReadDetailField=='yes'&&$focus->detailfieldobj)
        {

            $fieldinfo_arr = [];
            //zxm 20231130 首付款单分录是根据源单类型不同变动的 需要循环获取分录字段
            if($focus->module_name=='CashBill'||$focus->module_name=='SendCashBill'){
                $sourceModuleArr = getsourcemodule($focus->module_name);
                $sourceModuleArr =empty($sourceModuleArr)?[]: _array_column($sourceModuleArr,'entitytype');
                foreach($sourceModuleArr as $tmpsourcemodule){
                    $focus->Resetdetailfieldobj($tmpsourcemodule);
                    if(empty($bigtype)){
                        $tmpfieldinfo_arr = $focus->detailfieldobj->getListSearchFields();
                    }else{
                        $tmpfieldinfo_arr=$focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype",$bigtype);
                    }
                    foreach($tmpfieldinfo_arr as $tmpk=>$tmpfieldinfo){
                        if(!isset($fieldinfo_arr[$tmpk]))$fieldinfo_arr[$tmpk] = $tmpfieldinfo;
                    }
                }
                $focus->Resetdetailfieldobj();

            }
            else{
                if(empty($bigtype)){
                    $fieldinfo_arr = $focus->detailfieldobj->getListSearchFields();
                }else{
                    $fieldinfo_arr=$focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype",$bigtype);
                }
            }
            $tempOption = [];


            foreach($fieldinfo_arr as $fieldInfo)
            {
                $label = $fieldInfo->getFieldLabel();
                $typeOfData = $fieldInfo->getTypeOfData();
                $typeOfData = explode('~',$typeOfData);
                $bigtype = $fieldInfo->getBigType();
              //  if($fieldInfo->getTableName()==$focus->Detail_table||$fieldInfo->getTableName()==$focus->Detail_table_scf)
                //如果要显示产品编号字段  则判断模块分录是产品分录，且这个字段是ld_products表或者ld_productscf表 zxm20220729
                $isHaveProductDetails = get_file_address($tmpModule,'ProductDetails');//判断是否有产品分录
                $tmp_tablename = $fieldInfo->getTableName();//判断表名称

                if(($fieldInfo->getSaveDataBase()=='yes'||($isHaveProductDetails && in_array($tmp_tablename,['ld_products','ld_productcf'])))
                    &&$fieldInfo->getColumnName()!='total'
                    &&$fieldInfo->getColumnName()!='subtotal')
                {
                    //分录字段去掉小计合计  因为在主表已经有显示了
                    $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $tmpModule . "_fieldlabel:" . $typeOfData[0];
                    $tempOption[] = ['bigtype'=>$bigtype,'value'=>$optionValue,'label'=>$label,'columnmodule'=>$tmpModule,'typeofdata'=>$typeOfData[0],'detailField'=>"yes"];
                }
            }

        }
        return $tempOption;
    }
    //获取报表字段信息
    public function getReportColumns($report_id){
        $userid = $this->current_user->id;
        $widthresult= $this->adb->pquery("select `columns`,header_width from ld_list_headerwidth where userid=? and relateid=? and module='CustomTables' ",array($userid,$report_id));
        $widthinfo_arr=[];
        for($j=0;$j<$this->adb->num_rows($widthresult);$j++)
        {
            $widthinfo_arr[$this->adb->query_result($widthresult,$j,'columns')]=$this->adb->query_result($widthresult,$j,'header_width');
        }
        //zxm 20231123 查询字段的时候 只有选中的模块的字段被查出来 其他的不查 等保存的时候会自动删掉
        $columns_sql = "select * from ld_customtable_columns where report_id=? and (FIND_IN_SET(columnmodule,(select GROUP_CONCAT(modulename) from ld_customtable_module where report_id=?)) or total_type='formula') ";
        $columns_res = $this->adb->pquery($columns_sql,array($report_id,$report_id));
        $columns_nums = $this->adb->num_rows($columns_res);
        $columns = [];
        $columns_value = [];
        $columns_formula = [];//计算公式字段
        $columns_alias = [];//取过别名的  且可以用来计算的字段
        if($columns_nums>0){
            $tmprowindex=0;
            for($i=0;$i<$columns_nums;$i++){
                $total_type = $this->adb->query_result($columns_res,$i,'total_type');
                $tmp_focus = CRMEntity::getInstance( $this->adb->query_result($columns_res,$i,'columnmodule'));//字段所属模块
                if($total_type!='formula'){
                    
                    $temp_columns = explode(':',$this->adb->query_result($columns_res,$i,'columns'));
                    if(array_key_exists($temp_columns[0],$tmp_focus->tab_name_index))
                    {
                        $fieldinfo = $tmp_focus->fieldobj->getFieldInfoobjBykey('columnname',$temp_columns[1]);
                    }
                    else{
                        $fieldinfo=  $tmp_focus->detailfieldobj->getFieldInfoobjBykey('columnname',$temp_columns[1]);
                    }
                    if(!$fieldinfo)
                        continue;
                }

                $temp_columnid = $this->adb->query_result($columns_res,$i,'id'); 
                $tdheader_label = $this->adb->query_result($columns_res,$i,'tdheader_label');
                $columns[$tmprowindex]['columnid'] = $temp_columnid;
                $columns[$tmprowindex]['tdheader_label'] = $tdheader_label;
                $tdheader_label_en = $this->adb->query_result($columns_res,$i,'tdheader_label_en');
                $columns[$tmprowindex]['tdheader_label_en'] = $tdheader_label_en?$tdheader_label_en:$tdheader_label;//英文未设置则默认为中文的
                $columns[$tmprowindex]['columns']  = $this->adb->query_result($columns_res,$i,'columns');

                $columns_value[$tmprowindex] = $columns[$tmprowindex]['columns'];
                $columns[$tmprowindex]['columnmodule']  = $this->adb->query_result($columns_res,$i,'columnmodule');
                $columns[$tmprowindex]['modulelabel']  = getTranstab($columns[$tmprowindex]['columnmodule']);
                $tmp_focus = CRMEntity::getInstance( $columns[$tmprowindex]['columnmodule']);
                if($total_type!='formula'){
                    $temp_columns = explode(':',$columns[$tmprowindex]['columns']);
                   //edit:can 20220420  	http://crm.zonergy.com:85/crm（四川中兴）-客户；销售销售人员业绩统计表；产品商机物料销售统计表 两个自定义报表的导出数据有问题 
                    $columns[$tmprowindex]['fieldlabel'] = $tdheader_label;//$fieldinfo->getFieldLabel();//字段名
                    $columns[$tmprowindex]['bigtype'] = $fieldinfo->getBigType();
                    $columns[$tmprowindex]['typeofdata'] =  $fieldinfo->getTypeOfData();
                    $tmp_typeofdata = $fieldinfo->getTypeOfData();
                    $tmp_typeofdata_array = explode('~',$tmp_typeofdata);
                    $columns[$tmprowindex]['typeofdata_prefix'] =  $tmp_typeofdata_array[0];
                }else{
                    $columns[$tmprowindex]['fieldlabel'] = $tdheader_label;//字段名
                    $columns[$tmprowindex]['bigtype'] = '';
                    $columns[$tmprowindex]['typeofdata'] =  "NN";
                    $columns[$tmprowindex]['typeofdata_prefix'] =  "NN";
                }

                $columns[$tmprowindex]['is_group']  = $this->adb->query_result($columns_res,$i,'is_group');
                $columns[$tmprowindex]['order_by']  = $this->adb->query_result($columns_res,$i,'order_by');
                $columns[$tmprowindex]['is_merge']  = $this->adb->query_result($columns_res,$i,'is_merge');
                $columns[$tmprowindex]['header_width']  = 200;
                if(isset($widthinfo_arr[$temp_columnid])){
                    $columns[$tmprowindex]['header_width']  = $widthinfo_arr[$temp_columnid];
                }

                $columns[$tmprowindex]['issticky']  = $this->adb->query_result($columns_res,$i,'issticky');
                $columns[$tmprowindex]['styleset_header']  = $this->adb->query_result($columns_res,$i,'styleset_header');//样式设置
                $columns[$tmprowindex]['styleset_body']  = $this->adb->query_result($columns_res,$i,'styleset_body');//样式设置
                $columns[$tmprowindex]['total_type']  = $total_type;
                $columns[$tmprowindex]['align']  = $this->adb->query_result($columns_res,$i,'align');
                $columns[$tmprowindex]['sequence']  = $this->adb->query_result($columns_res,$i,'sequence');
                $alias = $this->adb->query_result($columns_res,$i,'alias');
                $columns[$tmprowindex]['alias']  = $alias;
                $columns[$tmprowindex]['decimal_places']  = $this->adb->query_result($columns_res,$i,'decimal_places');
                $columns[$tmprowindex]['suffix']  = $this->adb->query_result($columns_res,$i,'suffix');
                $columns[$tmprowindex]['prefix']  = $this->adb->query_result($columns_res,$i,'prefix');
                if($total_type=='formula'){
                    $columns_formula[] = $columns[$tmprowindex];//计算公式字段
                }
                if(!empty($alias)&&$total_type!='formula'&&(!empty($total_type)||$columns[$tmprowindex]['typeofdata_prefix']=="N"||$columns[$tmprowindex]['typeofdata_prefix']=="NN")){
                    $columns_alias[] = $columns[$tmprowindex];//取过别名的字段
                }
                $tmprowindex++;
            }
        }
        return [
            "columns"=>$columns,
            "columns_value"=>$columns_value,
            "columns_alias"=>$columns_alias,
            'columns_formula'=>$columns_formula
        ];
    }
    //获取模块名称数组  用来获取字段的
    public function getReportModules($report_id){
        $module_sql = "select * from ld_customtable_module where report_id=? order by pathtype,parent_id asc";
        $module_res = $this->adb->pquery($module_sql,array($report_id));
        $module_nums = $this->adb->num_rows($module_res);
        $mainmoduleSelected = '';
        $nextSelectedArr = [];
        $prevSelectedArr = [];
        if($module_nums>0){
            for($i=0;$i<$module_nums;$i++) {
                $modulename = $this->adb->query_result($module_res, $i, 'modulename');
                $pathtype = $this->adb->query_result($module_res, $i, 'pathtype');
                if ($pathtype == 'mainmodule') {
                    //选中的模块值
                    $mainmoduleSelected = $modulename;
                }
                if ($pathtype == 'next'||$pathtype == 'mainmodule') {
                    $nextSelectedArr[] = $modulename;
                }
                if ($pathtype == 'prev') {
                    $prevSelectedArr[] = $modulename;
                }

            }
        }
        return [
            'mainmoduleSelected'=>$mainmoduleSelected,
            'nextSelectedArr'=>$nextSelectedArr,
            'prevSelectedArr'=>$prevSelectedArr
        ];
    }
    //获取报表主表信息
    public function getReportInfo($report_id){
        if(sizeof($this->report_info_arr)>0)
        {
            return $this->report_info_arr;
            
        }
        $report_sql = "select * from ld_customtable where report_id=?";
        $report_res = $this->adb->pquery($report_sql,array($report_id));
        $report_nums = $this->adb->num_rows($report_res);
        $report_info = [];
        if($report_nums>0){
            $report_info = $this->adb->query_result_rowdata($report_res,0);
        }
        //sql类型报表 需要把字段查询出来
        if($report_info['report_type']=='sql'){
            //字段
            $columnsArr = $this->getCustomtableColumns($report_id);
            //$report_info['columnsArr'] = array_chunk($columnsArr,3);
            $report_info['columnsArr'] = $columnsArr;
            $report_info['columnsCount'] = count($columnsArr);
            //变量
            $report_info['sqlFilterArr'] = $this->getSqlFilter($report_id);
            $report_info['sqlFilterArrCount'] = count($report_info['sqlFilterArr']);
            $report_info['sqlstr'] = htmlspecialchars($report_info['sqlstr']);
        }else{
            $columnsArr = $this->getReportColumns($report_id);
            $report_info['columnsArr'] = $columnsArr['columns'];
            $report_info['columnsCount'] = count($columnsArr['columns']);
        }
        $this->report_info_arr=$report_info;
        return $report_info;
    }
    public function getSqlFilter($report_id){
        $sqlFilterArr = [];
        $sqlFilter_sql = "select * from ld_customtablesql_filter where report_id=? order by sequence asc;";
        $sqlFilter_res = $this->adb->pquery($sqlFilter_sql,array($report_id));
        $sqlFilter_nums = $this->adb->num_rows($sqlFilter_res);
        if($sqlFilter_nums>0){
            $sqlFilterArr = $this->adb->query_result_all($sqlFilter_res);
            foreach($sqlFilterArr as $k=>$filter){
                if($filter['var_type']=='multiuser'){
                    $modulename = $filter['modulename'];
                    $scopeobj = new ScopOfAuthority($this->adb,$modulename);
                    $userids = $scopeobj->getCurUserScopeIds();
                    $sqlFilterArr[$k]['default_value'] = $userids;//用户默认值
                }
            }
        }
        return $sqlFilterArr;
    }
    public function getCustomtableColumns($report_id){
        $columnsArr = [];
        $columns_sql = "select * from ld_customtable_columns where report_id=? order by sequence asc;";
        $columns_res = $this->adb->pquery($columns_sql,array($report_id));
        $columns_nums = $this->adb->num_rows($columns_res);
        if($columns_nums>0){
            $columnsArr = $this->adb->query_result_all($columns_res);
        }
        return $columnsArr;
    }
    //获取条件数据-新的的
    public function getReportCondition($report_id){
        $condition_sql = "select * from (
            select report_id,columns,comparator,value,groupid,columncondition,'columns'as type,'2'as typenum,''as group_condition from ld_customtable_condition where report_id=$report_id 
            union all 
            select report_id,'' as columns,'' as comparator,'' as value,groupid,'' as columncodition,'groups'as type,'1'as typenum,group_condition from ld_customtable_condition_grouping  where report_id=$report_id 
        )a order by groupid,typenum asc";
        $condition_res = $this->adb->pquery($condition_sql);
        $condition_nums = $this->adb->num_rows($condition_res);
        $conditions = [];
        if($condition_nums>0){
            for($i=0;$i<$condition_nums;$i++){
                $conditions[$i] = $this->adb->query_result_rowdata($condition_res,$i);
            }
        }
        return $conditions;
    }
    public function getReportConditionadv($report_id){
        $condition_sql = " 
            select report_id,columns,comparator,value,groupid,columncondition from ld_customtable_condition where report_id=? 
            order by groupid  asc";
        $condition_res = $this->adb->pquery($condition_sql,array($report_id));
        $condition_nums = $this->adb->num_rows($condition_res);
        $conditions = [];
        if($condition_nums>0){
            for($i=0;$i<$condition_nums;$i++){
                $temp_comparator = $this->adb->query_result($condition_res,$i,'comparator');
                $temp_value = $this->adb->query_result($condition_res,$i,'value');
                $temp_value_arr = explode(',',$temp_value);
                if(($temp_comparator!='isnull'&&$temp_comparator!='isnotnull')&&trim($temp_value_arr[0])=='')continue;

                $conditions[$i] = $this->adb->query_result_rowdata($condition_res,$i);
            }
        }
        return $conditions;
    }
    public function getReportConditionGrouping($report_id){
        $condition_sql = "
            select report_id,groupid, group_condition from ld_customtable_condition_grouping  where report_id=? 
            order by groupid ";
        $condition_res = $this->adb->pquery($condition_sql,array($report_id));
        $condition_nums = $this->adb->num_rows($condition_res);
        $conditionsGrouping = [];
        if($condition_nums>0){
            for($i=0;$i<$condition_nums;$i++){
                $conditionsGrouping[$i] = $this->adb->query_result_rowdata($condition_res,$i);
            }
        }
        return $conditionsGrouping;
    }
    //获取条件值
    public function getComparatorValue(){
        //D:\ldcrm\www\crm\modules\ReportAnalysis\ReportAnalysisUtils.php
        crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
        $ReportAnalysisUtilsObj = new ReportAnalysisUtils();
        return $ReportAnalysisUtilsObj->getComparatorValue();
    }
    //获取模块的下拉框字段
    public function getPickListsByModule($modulename){
        $focus = CRMEntity::getInstance($modulename);
        $fieldinfo_arr = [];
        if($focus->fieldobj)
            $fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",'picklist');
        //分录的下拉框字段也要显示出来
        if((get_file_address($modulename,"ProductDetails") or !empty($focus->detailfieldobj) )&&$modulename!='ServiceCharge'){
            $detailfieldinfo_arr = $focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype",'picklist');
            $fieldinfo_arr = array_merge($fieldinfo_arr,$detailfieldinfo_arr);
        }
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();

        $tempOption = [];
        crm_load_class_file('PickListUtils','modules/PickList');
        foreach($fieldinfo_arr as $fieldInfo)
        {
            if($focus->module_name=='Accounts'&&($fieldInfo->getTableName()=='ld_contactdetails'||$fieldInfo->getTableName()=='ld_contactscf'))
                continue;
            $label = $fieldInfo->getFieldLabel();
            $typeOfData = $fieldInfo->getTypeOfData();
            $typeOfData = explode('~',$typeOfData);
            $bigtype = $fieldInfo->getBigType();
            if ($bigtype == 'qrcode') continue;
            $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $modulename . "_fieldlabel:" . $typeOfData[0];
            //$picklists = getAllPickListValues($fieldInfo->getFieldName());
            $picklists = $objpinklist->getPickListValues($fieldInfo->getFieldName(),$fieldInfo,array(),'');
            $tempOption[] = [
                'bigtype'=>$bigtype,
                'value'=>$optionValue,
                'label'=>$label,
                'columnmodule'=>$modulename,
                'columnname'=>$fieldInfo->getColumnName(),
                'picklists'=>$picklists,
                'picklist_str'=>implode(',',$picklists),
                'typeofdata'=>$typeOfData[0],
                'detailField'=>"no"];
        }

        return $tempOption;
    }
    public function getFilterDefaultValue($timename){
        crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
        return ReportAnalysisUtils::getFilterDefaultValue($timename);
    }
    public function getModuleArr()
    {
        $query="SELECT
        	ld_tab.tabid,
        	ld_tranlabel.fieldlabel AS newtabname,
        	ld_tab.presence,
        	ld_tab.customized,
        	languagetype,
        	ld_tab.description,
        	ld_tab.name
        FROM
        	ld_tab
        INNER JOIN ld_tranlabel ON ld_tab.tabid = ld_tranlabel.relateid
        WHERE
            languagetype = '".$this->language."'
        AND trantable = 'ld_tab'
        AND ld_tab. NAME NOT IN ($this->except)
        AND ld_tab.presence = 0
        GROUP BY
        	ld_tab.tabid,
        	languagetype,
        	tabid
        ORDER BY
        	ld_tab.tabsequence ASC";

        $result = $this->adb->query($query);
        $num_rows=$this->adb->num_rows($result);
        $alltabs = [];
        for($i=0;$i<$num_rows;$i++) {
            $name = $this->adb->query_result($result, $i, 'name');
            if (isPermitted($name, 'index') == 'yes' && vtlib_isModuleActive($name)) {
                $focus = CRMEntity::getInstance($name);
                //zxm 20231220 用户数据范围依赖模块下拉框值的时候 加这个判断导致没有下拉框字段的模块不显示了  先去掉这个判断
                //$fieldinfo_arr = $focus->fieldobj->getFieldInfoobjBykey_arr("bigtype", 'picklist');
                //if (!empty($fieldinfo_arr)) {
                    $tabid = $this->adb->query_result($result, $i, 'tabid');
                    $alltabs[$tabid]['presence'] = $this->adb->query_result($result, $i, 'presence');
                    $alltabs[$tabid]['customized'] = $this->adb->query_result($result, $i, 'customized');
                    $alltabs[$tabid]['name'] = $this->adb->query_result($result, $i, 'newtabname');
                    $alltabs[$tabid]['modulename'] = $name;
                    $description = $this->adb->query_result($result, $i, 'description');
                    if (!empty($description)) {
                        $alltabs[$tabid]['description'] = getFixedLabel($description);
                    } else {
                        $alltabs[$tabid]['description'] = '';
                    }
                //}
            }
        }
        $emptyline = [
            'presence'=>'-1',
            'customized'=>'0',
            'name'=>'',
            'modulename'=>'',
            'description'=>''
        ];
        array_unshift($alltabs,$emptyline);
        return $alltabs;
    }

}