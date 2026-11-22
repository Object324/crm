<?php
class cls_ModuleInfo
{
    public $CustomTablesActionsObj;
    public $echartModuleObj;
    public $moduleName;
    public $languageType;
    public $current_user;
    public $params;
    public $except = UNABLE2STATISTICSMODULE;
    public $selectedModuleArr=[];//已选中的模块 用来判断下游可选模块不出现已选模块
    public function __construct($params)
    {
        global $languageType,$current_user;
        $this->languageType = $languageType;
        $this->current_user = $current_user;
        $this->params = $params;
        $this->moduleName = $params['modulename'];
        include_once globalStatic::$root_directory . 'modules/CustomTables/CustomTablesActions.php';
        $this->CustomTablesActionsObj = new CustomTablesActions();
    }
    //根据选中的上下游模块 递归获取上下游模块下拉框的option值
    public function getRecursionModuleArr(){
        $params = $this->params;
        $report_id = $params['report_id'];
        return $this->getRecursionModuleArrData($report_id);
    }
    public function getRecursionModuleArrData($report_id){
        global $adb;
        $prevArr = [];
        $nextArr = [];
        $mainmoduleArr = [];

        $prevSelectedArr = [];
        $nextSelectedArr = [];
        $mainmoduleSelected = '';
        if($report_id>0) {
            $selectmodulesql = 'select child.*,parent.tabid as ptabid,parent.modulename as pmodulename,parent.pathtype as ppathtype 
from ld_customtable_module child 
left join ld_customtable_module parent on parent.id=child.parent_id
where  child.report_id=? order by pathtype,parent_id asc';
            $module_res = $adb->pquery($selectmodulesql, array($report_id));
            $module_nums = $adb->num_rows($module_res);
            if ($module_nums > 0) {
                $theLastOnePrevModule = '';//最后一个上游模块
                $theLastOneNextModule = '';//最后一个下游模块
                for ($i = 0; $i < $module_nums; $i++) {
                    $modulename = $adb->query_result($module_res, $i, 'modulename');
                    $tabid = $adb->query_result($module_res, $i, 'tabid');
                    $pathtype = $adb->query_result($module_res, $i, 'pathtype');
                    $parent_id = $adb->query_result($module_res, $i, 'parent_id');
                    $pmodulename = $adb->query_result($module_res, $i, 'pmodulename');
                    $ptabid = $adb->query_result($module_res, $i, 'ptabid');
                    $ppathtype = $adb->query_result($module_res, $i, 'ppathtype');
                    if ($pathtype == 'mainmodule') {
                        //获取模块数组
                        $mainmoduleArr = $this->getMainModuleArr($modulename);
                        //选中的模块值
                        $mainmoduleSelected = $modulename;
                    }
                    if ($pathtype == 'next') {
                        //根据pmodulename获取同级别的模块数组
                        $nextArr[] = $this->getNextModules($pmodulename,$modulename);
                        $nextSelectedArr[] = ['selectmodule'=>$modulename ];
                        $theLastOneNextModule = $modulename;
                    }
                    if ($pathtype == 'prev') {
                        //根据pmodulename获取同级别的模块数组
                        $prevArr[] = $this->getPrevModules($pmodulename,$modulename);
                        $prevSelectedArr[] = ['selectmodule'=>$modulename];
                        $theLastOnePrevModule = $modulename;
                    }
                }
                if(!empty($theLastOneNextModule)){
                    $tmparr = $this->getNextModules($theLastOneNextModule,'');
                    if(!empty($tmparr)){
                        $nextArr[] = $tmparr;
                        $nextSelectedArr[] = ['selectmodule'=>'' ];
                    }
                }
                if(!empty($theLastOnePrevModule)) {
                    $tmparr = $this->getPrevModules($theLastOnePrevModule, '');
                    if(!empty($tmparr)){
                        $prevArr[] = $tmparr;
                        $prevSelectedArr[] = ['selectmodule'=>''];
                    }
                }
            }
        }else{
            $mainmoduleArr = $this->getMainModuleArr('');
            //BUG20240925-52 报表分析，新建模块报表，默认显示了“销售线索”;没有显示销售线索右边的下一级选项;直接下拉选择销售线索后，也不出现下一级选项;
            $mainmoduleSelected = $mainmoduleArr[0]['modulename'];//选中的主模块是第一个
            $tmparr = $this->getNextModules($mainmoduleSelected,'');
            if(!empty($tmparr)){
                $nextArr[] = $tmparr;
                $nextSelectedArr[] = ['selectmodule'=>'' ];
            }
            $tmparr = $this->getPrevModules($mainmoduleSelected, '');
            if(!empty($tmparr)){
                $prevArr[] = $tmparr;
                $prevSelectedArr[] = ['selectmodule'=>''];
            }

        }
        return [
            'prevArr'=>$prevArr,
            'nextArr'=>$nextArr,
            'mainmoduleArr'=>$mainmoduleArr,
            'prevSelectedArr'=>$prevSelectedArr,
            'nextSelectedArr'=>$nextSelectedArr,
            'mainmoduleSelected'=>$mainmoduleSelected
        ];
    }
    //ajax获取相关模块--增加一个参数判断是上游还是下游模块
    public function getRelatedModule(){
        $params = $this->params;
        $mainmoduleSelected = $this->params['mainmoduleSelected'];
        $nextSelectedArr = Zend_Json::decode($this->params['nextSelectedArr']);
        $prevSelectedArr = Zend_Json::decode($this->params['prevSelectedArr']);
        $selectedModuleArr = array_column($nextSelectedArr,'selectmodule');
        $selectedModuleArr[] = $mainmoduleSelected;
        $selectedModuleArr = array_merge($selectedModuleArr,array_column($prevSelectedArr,'selectmodule'));
        $this->selectedModuleArr = array_filter($selectedModuleArr);

        $pathtype = empty($params['pathtype'])?'next':$params['pathtype'];
        $pmodule = $params['modulename'];

        $PrevModules = array();
        $NextModules = array();
        if($pathtype=='prev'||$pathtype=='all'){
            $PrevModules = $this->getPrevModules($pmodule,'');
            //BUG0074052 zxm 20231018 报表分析--模块报销--选择空白模板--选择模块无法显示后继模块
            $PrevModules = array_values($PrevModules);
        }
        if($pathtype=='next'||$pathtype=='all'){
            $NextModules = $this->getNextModules($pmodule,'');
            //BUG0074052 zxm 20231018 报表分析--模块报销--选择空白模板--选择模块无法显示后继模块
            $NextModules = array_values($NextModules);
        }
        return [
            'NextModules'=>$NextModules,
            'PrevModules'=>$PrevModules,
        ];

    }
    //获取统计主模块下拉框数组
    public function getMainModuleArr($selectedmodule)
    {
        global $adb;
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
            languagetype = '".$this->languageType."'
        AND trantable = 'ld_tab'
        AND ld_tab. NAME NOT IN (".$this->except.")
        AND ld_tab.presence = 0
        AND ld_tab.isentitytype= 1
        GROUP BY
        	ld_tab.tabid,
        	languagetype,
        	tabid
        ORDER BY
        	ld_tab.tabsequence ASC";
        $result = $adb->query($query,array());
        $num_rows=$adb->num_rows($result);
        $alltabs = [];
        for($i=0;$i<$num_rows;$i++){
            $name = $adb->query_result($result,$i,'name');
            $tabid = $adb->query_result($result,$i,'tabid');
            if(isPermitted($name,'index') == 'yes'&&vtlib_isModuleActive($name)){
                $description = $adb->query_result($result,$i,'description');
                if(!empty($description)){
                    $alltabs[$tabid]['description'] = getFixedLabel($description) ;
                } else{
                    $alltabs[$tabid]['description']='';
                }
                $alltabs[$tabid]["modulelabel"]=  getTranstab($name);
                $alltabs[$tabid]["modulename"]=  $name;
                $alltabs[$tabid]["tabid"]= getTabid($name);
                $alltabs[$tabid]["selected"]= 'no';
                if($name==$selectedmodule){
                    $alltabs[$tabid]["selected"]= 'yes';
                }
                //新建  直接选中第一个模块
                if(empty($selectedmodule)){
                    if($i==0)$alltabs[$tabid]["selected"]= 'yes';
                }
            }
        }
        return array_values($alltabs);
    }
    //获取下游模块列表
    public function getNextModules($parentModule,$selectedmodule){
        global $adb;
        $tabid = getTabid($parentModule);
        $relatedTableSql = "SELECT
            	a.related_tabid,a.label,a.related_coltable,b.fieldlabel
            FROM
            	ld_relatedlists a
            LEFT JOIN ld_tranlabel b ON a.related_tabid = b.relateid
            LEFT JOIN ld_tab c on c.tabid=a.related_tabid
            WHERE
            	a.tabid = ? 
            	AND b.languagetype = ?
                AND b.trantable = 'ld_tab'
            	AND c.presence = 0
                AND c.isentitytype= 1
                AND c.name NOT IN (".$this->except.")
            	AND a.related_coltable IS NOT NULL 
            	AND a.related_coltable!='' ";
        $relatedTableRes = $adb->pquery($relatedTableSql,array($tabid,$this->languageType));
        $relatedTableNums = $adb->num_rows($relatedTableRes);
        $relatedModules = [];
        
        if($relatedTableNums>0){
            for($i=0;$i<$relatedTableNums;$i++){
                $label = $adb->query_result($relatedTableRes, $i, 'label');
                $tabid = $adb->query_result($relatedTableRes, $i, 'related_tabid');
                //当前模块的上下游可选模块  过滤掉当前模块
                if(isPermitted($label,'index') == 'yes'
                    &&vtlib_isModuleActive($label)
                    &&!isset($relatedModules[$label])
                    &&$label!=$parentModule&&!in_array($label,$this->selectedModuleArr)) {
                    $relatedModules[$tabid]["modulelabel"]=  getTranstab($label);
                    $relatedModules[$tabid]["modulename"]=  $label;
                    $relatedModules[$tabid]["tabid"]= $adb->query_result($relatedTableRes, $i, 'related_tabid');
                    $relatedModules[$tabid]["selected"]= 'no';
                    if($label==$selectedmodule){
                        $relatedModules[$tabid]["selected"]= 'yes';
                    }
                }
            }
        }
        return array_values($relatedModules);
    }
    //根据模块名称获取上游模块列表
    public function getPrevModules($parentModule,$selectedmodule){
        $moduleName = $parentModule;
        //获取上游模块列表 zxm 20231116
        $sourceModules = getsourcemodule($moduleName);
        $sourceModules =empty($sourceModules)?[]: _array_column($sourceModules,'entitytype');

        require_once globalStatic::$root_directory.'include/fields/cls_module_uitype.php';
        $referenceModules = cls_module_uitype::getAllReferenceModules($moduleName);

        $referenceModules = empty($referenceModules)?[] : array_keys($referenceModules);

        $modulesAll = array_merge($sourceModules,$referenceModules);
        $modulesArr = [];
        foreach($modulesAll as $tmpmodulename){
            if(empty($tmpmodulename))continue;
            //edit: xll 2024/03/07 BUG20240306-66 销售线索的上游模块中删去客户模块
            if($parentModule === 'Leads' && $tmpmodulename === 'Accounts'){
                continue;
            }
            //当前模块的上下游可选模块  过滤掉当前模块
            if($tmpmodulename==$parentModule){
                continue;
            }

            $tabid = getTabid($tmpmodulename);
            $modulesArr[$tabid] = array(
                "modulelabel"=> getTranstab($tmpmodulename),
                "modulename"=> $tmpmodulename,
                "tabid"=>$tabid,
                "selected"=>'no'
            );
            if($tmpmodulename==$selectedmodule){
                $modulesArr[$tabid]["selected"]= 'yes';
            }
        }
        return array_values($modulesArr);
    }

    //根据模块名称获取字段  数组
    public function getModuleFields()
    {
        $params = $this->params;
        $report_id = $params['report_id'];
        if($report_id>0){
            $res = $this->getRecursionModuleArr();
            $mainmodule = $res['mainmoduleSelected'];
            $nextSelectedArr = _array_column($res['nextSelectedArr'],'selectmodule');
            $prevSelectedArr = _array_column($res['prevSelectedArr'],'selectmodule');
        }else{
            $mainmodule = $params['mainmoduleSelected'];
            $nextSelectedArr = $params['nextSelectedArr'];
            $nextSelectedArr = empty($nextSelectedArr)?[]:_array_column(Zend_Json::decode($nextSelectedArr),'selectmodule');
            $prevSelectedArr = $params['prevSelectedArr'];
            $prevSelectedArr = empty($prevSelectedArr)?[]:_array_column(Zend_Json::decode($prevSelectedArr),'selectmodule');
            $res = [
                'mainmoduleSelected' => $mainmodule,
                'nextSelectedArr' => json_decode($params['nextSelectedArr'],true),
                'prevSelectedArr' => json_decode($params['prevSelectedArr'],true),
            ];
        }
        $prevSelectedArr = array_reverse($prevSelectedArr);//上游模块如果要拼接到所有模块的数组上 反转一下
        if(empty($prevSelectedArr[0]))
            unset($prevSelectedArr[0]);

        $modules[] = $mainmodule;

        if(!empty($prevSelectedArr))$modules =array_merge($prevSelectedArr,$modules);
        if(!empty($nextSelectedArr)) $modules =array_merge($modules,$nextSelectedArr);

        $modules = array_unique($modules);
        $res['searchFieldRes'] = $this->CustomTablesActionsObj->getModuleFields($modules,$mainmodule,$nextSelectedArr);//选中模块的所有字段


        $res['columns'] = [];
        $res['columns_value'] = [];
        $res['columns_alias'] = [];
        $res['columns_formula'] = [];
        if($report_id>0){
            //编辑时候 需要返回选中的字段值
            $reportColumns = $this->CustomTablesActionsObj->getReportColumns($report_id);
            $res['columns'] = $reportColumns["columns"];
            $res['columns_value'] = $reportColumns["columns_value"];
            $res['columns_alias'] = $reportColumns["columns_alias"];
            $res['columns_formula'] = $reportColumns["columns_formula"];
            //编辑时候条件数据
            $res['reportConditions'] = $this->CustomTablesActionsObj->getReportCondition($report_id);
        }
        //币种
        $db = PearDatabase::getInstance();
        $currencyobj = Currency::getInstance($db);//系统币种
        $res['allCurrencies'] = $currencyobj->getAllCurrencies();
        $res['modulelength'] = count($modules);
        return $res;
    }
}