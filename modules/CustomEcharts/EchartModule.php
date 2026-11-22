<?php


class EchartModule
{
    public $adb;
    public $language;
    public $current_user;
    //推广大使 会话存档 工作汇报 邮件管理 短信模板 邮件模板 短信记录 费率设定 公告 评论 现金银行流水账 银行账户 常用报表 综合报表
    //报表库 自定义统计图表 回收站 价格表 附件管理 销售目标 清除缓存 客户地图 表单推广
    public $except = UNABLE2STATISTICSMODULE;
    public function __construct(){
        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
    }
    //获取统计主模块下拉框数组
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
        AND ld_tab.isentitytype= 1
        GROUP BY
        	ld_tab.tabid,
        	languagetype,
        	tabid
        ORDER BY
        	ld_tab.tabsequence ASC";
         
        $result = $this->adb->query($query);
        $num_rows=$this->adb->num_rows($result);
        $alltabs = [];
        for($i=0;$i<$num_rows;$i++){
            $name = $this->adb->query_result($result,$i,'name');
            if(isPermitted($name,'index') == 'yes'&&vtlib_isModuleActive($name)){
                $tabid = $this->adb->query_result($result,$i,'tabid');
                $alltabs[$tabid]['presence'] = $this->adb->query_result($result,$i,'presence');
                $alltabs[$tabid]['customized'] = $this->adb->query_result($result,$i,'customized');
                $alltabs[$tabid]['name'] = $this->adb->query_result($result,$i,'newtabname');
                $alltabs[$tabid]['modulename'] = $name;
                $description = $this->adb->query_result($result,$i,'description');
                if(!empty($description)){
                    $alltabs[$tabid]['description'] = getFixedLabel($description) ;
                } else{
                    $alltabs[$tabid]['description']='';
                }
            }
        }
        return $alltabs;
    }
    //获取统计主模块下拉框数组
    public function getModuleArr_TabName()
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
        AND ld_tab.isentitytype= 1
        GROUP BY
        	ld_tab.tabid,
        	languagetype,
        	tabid
        ORDER BY
        	ld_tab.tabsequence ASC";

        $result = $this->adb->query($query);
        $num_rows=$this->adb->num_rows($result);
        $alltabs = [];
        for($i=0;$i<$num_rows;$i++){
            $name = $this->adb->query_result($result,$i,'name');
            if(isPermitted($name,'index') == 'yes'&&vtlib_isModuleActive($name)){
                $tabid = $this->adb->query_result($result,$i,'tabid');
                $alltabs[$name]['presence'] = $this->adb->query_result($result,$i,'presence');
                $alltabs[$name]['customized'] = $this->adb->query_result($result,$i,'customized');
                $alltabs[$name]['name'] = $this->adb->query_result($result,$i,'newtabname');
                $alltabs[$name]['modulename'] = $name;
                $alltabs[$name]['tabid'] = $tabid;
                $description = $this->adb->query_result($result,$i,'description');
                if(!empty($description)){
                    $alltabs[$name]['description'] = getFixedLabel($description) ;
                } else{
                    $alltabs[$name]['description']='';
                }
            }
        }
        return $alltabs;
    }
    /**
     * @param $moduleName
     * @return array
     * @throws Exception
     * 获取主模块的相关模块列表  返回模块名称 tabid  关联字段  模块名字
     */
    public function getRelatedModule($moduleName){
        $tabid = getTabid($moduleName);
        $relatedTableSql = "SELECT
            	a.related_tabid,a.label,a.related_coltable,b.fieldlabel
            FROM
            	ld_relatedlists a
            LEFT JOIN ld_tranlabel b ON a.related_tabid = b.relateid
            LEFT JOIN ld_tab c on c.tabid=a.related_tabid
            WHERE
            	a.tabid = $tabid 
            	AND b.languagetype = '".$this->language."'
                AND b.trantable = 'ld_tab'
            	AND c.presence = 0
                AND c.isentitytype= 1
                AND c.name NOT IN ($this->except)
            	AND a.related_coltable IS NOT NULL 
            	AND a.related_coltable!=''";
        $relatedTableRes = $this->adb->pquery($relatedTableSql);
        $relatedTableNums = $this->adb->num_rows($relatedTableRes);
        $relatedModules[$moduleName] = ['related_tabid'=>$tabid,'label'=>$moduleName,'fieldlabel'=>getTranstab($moduleName),
            'modulename'=>$moduleName,'name'=>getTranstab($moduleName)];//本模块也需要返回
        if($relatedTableNums>0){
            for($i=0;$i<$relatedTableNums;$i++){
                $label = $this->adb->query_result($relatedTableRes, $i, 'label');
                if(isPermitted($label,'index') == 'yes'&&vtlib_isModuleActive($label)&&!isset($relatedModules[$label])) {
                    $relatedModules[$label]['related_tabid'] = $this->adb->query_result($relatedTableRes, $i, 'related_tabid');
                    $relatedModules[$label]['label'] = $label;
                    $relatedModules[$label]['related_coltable'] = $this->adb->query_result($relatedTableRes, $i, 'related_coltable');
                    $fieldlabel = $this->adb->query_result($relatedTableRes, $i, 'fieldlabel');
                    $relatedModules[$label]['fieldlabel'] = $fieldlabel;
                    $relatedModules[$label]['modulename'] = $label;
                    $relatedModules[$label]['name'] = $fieldlabel;
                }
            }
        }
        //$relatedModules = array_values($relatedModules);
        return $relatedModules;
    }

    /**
     * @param $relatedModule,例子Account,Users,Contacts
     * @param $mainModule
     * @return array
     * 获取模块下的字段列表
     * 统计维度groupby  bigtype="reference" 、'users'、'picklist'、'date'、'datetime'、'reference'
     * 求和字段sum  bigtype="currency" or number
     * 计数字段count  bigtype="reference"
     * 时间字段time  bigtype="datetime"、'date'、'time'
     * 原样显示字段 origin
     * 搜索字段 search
     */
    public function getModuleFieldsByModule($relatedModule,$mainModule)
    {
        //$modules = 'Accounts,SalesOrder,ServiceContracts';//测试用
        $modules = empty($relatedModule)?[]:explode(',',$relatedModule);
        $relateModule_arr=$modules;
        $modules[] = $mainModule;
        $groupByFieldRes = '';
        $sumFieldRes = '';
        $countFieldRes = '';
        $timeFieldRes = '';
        $searchFieldRes = '';
        $modules = array_unique($modules);
        foreach($modules as $tmpModule)
        {
            if(empty($tmpModule)){
                continue;
            }
            $focus=CRMEntity::getInstance($tmpModule);
            $moduleName = getTranstab($tmpModule);
            $sumFieldRes .= "<optgroup label='$moduleName' class='select' style='border:none'>";
            $countFieldRes .= "<optgroup label='$moduleName' class='select' style='border:none'>";
            $timeFieldRes .= "<optgroup label='$moduleName' class='select' style='border:none'>";
            $searchFieldRes .= "<optgroup label='$moduleName' class='select' style='border:none'>";
            //统计维度groupby
            if($tmpModule==$mainModule)
            {
                $groupByFieldRes .= "<optgroup label='$moduleName' class='select' style='border:none'>";
                foreach(['text','reference','users','picklist','date','datetime'] as $bigtype)
                {
                    $tempOption = $this->getFieldArrByBigType($focus,$bigtype,$tmpModule,'no');
                    $groupByFieldRes .= $tempOption;
                }
                /*zxm 20230314 'picklist'和text类型的 被引用之后的字段bigtype也是text 'users'被引用之后的字段bigtype是users
                 * foreach(['text','users','picklist'] as $bigtype)
                {
                    //relatedmodulefield---引用字段符合以上几种类型的  也可显示在维度中
                    $relatedmodulefield_tempOption = $this->getFieldArrByParentBigType($focus,$bigtype,$tmpModule);
                    $groupByFieldRes .= $relatedmodulefield_tempOption;
                }*/
                $groupByFieldRes .= '</optgroup>';
            }
            //求和字段
            $isReadDetailField='no';
             if(in_array($tmpModule,$relateModule_arr))
            {
                $isReadDetailField='yes';
            }
            foreach(['currency','number','moduleno'] as $bigtype)
            {
               
                $tempOption = $this->getFieldArrByBigType($focus,$bigtype,$tmpModule,'no');
                $sumFieldRes .= $tempOption;
            }
            $sumFieldRes .= '</optgroup>';
            
            if($isReadDetailField=='yes')
            {
                $sumFieldRes .= "<optgroup label='".$moduleName."明细' class='select' style='border:none'>";
                //2022-6-7 合同订单分录 求和出不来数量字段
                foreach(['currency','number','num','Num','amount'] as $bigtype)
                {
                    $tempOption = $this->getFieldArrByBigType($focus,$bigtype,$tmpModule,'yes');
                   
                    $sumFieldRes .= $tempOption;
                }
                
                $sumFieldRes .= '</optgroup>';
            }
            //计数字段count
            
            foreach(['reference','text','moduleno'] as $bigtype)
            {
                
                $tempOption = $this->getFieldArrByBigType($focus,$bigtype,$tmpModule,'no');
                $countFieldRes .= $tempOption;
            }
            $countFieldRes .= '</optgroup>';
            //时间字段time
            foreach(['date','datetime'] as $bigtype)
            {
                $tempOption = $this->getFieldArrByBigType($focus,$bigtype,$tmpModule,'no');
                $timeFieldRes .= $tempOption;
            }
            $timeFieldRes .= '</optgroup>';
            //搜索字段 search
        
            $searchFieldRes .= $this->getFieldArrByBigType($focus,'',$tmpModule,'no');
            $searchFieldRes .= '</optgroup>';
            
             if($isReadDetailField=='yes')
            {
                $searchFieldRes .= "<optgroup label='".$moduleName."明细' class='select' style='border:none'>";
              
                
                $tempOption = $this->getFieldArrByBigType($focus,'',$tmpModule,'yes');
                $searchFieldRes .= $tempOption;
              
                
                $searchFieldRes .= '</optgroup>';
            }
        }
        
        return [
            'groupByFieldRes'=>$groupByFieldRes,
            'sumFieldRes'=>$sumFieldRes,
            'countFieldRes'=>$countFieldRes,
            'timeFieldRes'=>$timeFieldRes,
            'searchFieldRes'=>$searchFieldRes
        ];
    }
    
    /***
     * @param $focus
     * @param $bigtype ;为空则查询搜索字段
     * @param $tmpModule
     *@param $isReadDetailField:是否获取分录字段
     * @return string
     */
    public function getFieldArrByBigType($focus,$bigtype,$tmpModule,$isReadDetailField)
    {
        if($isReadDetailField=='no')
        {
            if(empty($bigtype)){
                $fieldinfo_arr = $focus->fieldobj->getListSearchFields();
            }else{
                $fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("bigtype",$bigtype);
            }
            $tempOption = '';
            foreach($fieldinfo_arr as $fieldInfo)
            {
                $label = $fieldInfo->getFieldLabel();
                $typeOfData = $fieldInfo->getTypeOfData();
                $typeOfData = explode('~',$typeOfData);
                $bigtype = $fieldInfo->getBigType();
                $savedatabase = $fieldInfo->getSaveDatabase();
                if($savedatabase=='yes'){
                    $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $tmpModule . "_" . $fieldInfo->getFieldLabel() . ":" . $typeOfData[0];
                    $tempOption .= "<option data-type='$bigtype' value='$optionValue'>$label</option>";
                }
            }
        }
        
        
        if($isReadDetailField=='yes'&&$focus->detailfieldobj)
        {
            
            if(empty($bigtype)){
                $fieldinfo_arr = $focus->detailfieldobj->getListSearchFields();
            }else{
                $fieldinfo_arr=$focus->detailfieldobj->getFieldInfoobjBykey_arr("bigtype",$bigtype);
            }
            $tempOption = '';
            
            
            foreach($fieldinfo_arr as $fieldInfo)
            {
                $label = $fieldInfo->getFieldLabel();
                $typeOfData = $fieldInfo->getTypeOfData();
                $typeOfData = explode('~',$typeOfData);
                $bigtype = $fieldInfo->getBigType();
                $savedatabase = $fieldInfo->getSaveDatabase();
                if($fieldInfo->getTableName()==$focus->Detail_table||$fieldInfo->getTableName()==$focus->Detail_table_scf)
                {
                    if($savedatabase=='yes'){
                        $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $tmpModule . "_" . $fieldInfo->getFieldLabel() . ":" . $typeOfData[0];
                        $tempOption .= "<option data-type='$bigtype' value='$optionValue'>$label</option>";
                    }
                }
            }
           
        }
        return $tempOption;
    }
    //zxm 20220823 根据parentbigtype获取字段信息
    public function getFieldArrByParentBigType($focus,$bigtype,$tmpModule)
    {
        $fieldinfo_arr=$focus->fieldobj->getFieldInfoobjBykey_arr("parentbigtype",$bigtype);
        $tempOption = '';
        foreach($fieldinfo_arr as $fieldInfo)
        {
            $label = $fieldInfo->getFieldLabel();
            $typeOfData = $fieldInfo->getTypeOfData();
            $typeOfData = explode('~',$typeOfData);
            $bigtype = $fieldInfo->getBigType();
            $optionValue = $fieldInfo->getTableName() . ":" . $fieldInfo->getColumnName() . ":" . $fieldInfo->getFieldName() . ":" . $tmpModule . "_" . $fieldInfo->getFieldLabel() . ":" . $typeOfData[0];
            $tempOption .= "<option data-type='$bigtype' value='$optionValue'>$label</option>";
        }
        return $tempOption;
    }
}