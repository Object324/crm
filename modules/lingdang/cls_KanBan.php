<?php
class cls_KanBan{
    public $detailInfo = array();
    public $module;
    public $focus;
    public $showfieldvalueobj;
    public $customView;
    public $cls_PickList;
    public $cls_module_advance;
    public $pickInfo;
    public $defaultcurrency;
    public $modulefields;

    public function __construct($module){
        global $current_user;
        $this->module=$module;
        $this->getCurrencyModule();
        //布局规则
        $this->focus = CRMEntity::getInstance($this->module);
        $this->showfieldvalueobj=new ShowFieldValue($this->focus->fieldobj,$this->focus->module_name,SHOW_POPUP);
        $this->customView = new CustomView($this->module);
        $this->queryGenerator = QueryGenerator::getInstance($this->module, $current_user,$this->customView);
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $this->cls_PickList = new cls_PickList();
        //获取当前的的推进字段(自动化设置)
        crm_load_class_file('cls_module_advance','modules/Settings');
        $this->cls_module_advance = cls_module_advance::getInstance($this->module);
    }

    public static function getInstance($module){
        static $static_module_kanbanobj_arr;
        if(is_array($static_module_kanbanobj_arr)&&array_key_exists($module,$static_module_kanbanobj_arr))
        {
            return $static_module_kanbanobj_arr[$module];
        }
        if(!is_array($static_module_kanbanobj_arr))
        {
            $static_module_kanbanobj_arr=[];
        }
        if ($module == 'Potentials'){
            crm_load_class_file('PotentialKanban', 'modules/Potentials');
            $static_module_kanbanobj_arr[$module] = new PotentialKanban();
        }else{
            $static_module_kanbanobj_arr[$module]= new cls_KanBan($module);

        }
        return $static_module_kanbanobj_arr[$module];

    }

    //获取基本信息
    public function getKanBanViewBasicInfo(){
        $this->defaultcurrency = getDefaultCurrecySymbol();//默认的币种符号
        $this->ModuleAdvanceinfo=$this->cls_module_advance->getModuleAdvance();//推进阶段设置信息
        //跟踪字段内容
        $this->pick_fieldname=$this->ModuleAdvanceinfo['module_field'];
        $this->pickInfo = $this->cls_PickList->getPickListValues($this->pick_fieldname,'',array(),'kanban');
        //获取所有字段信息
        $this->fieldobj = $this->queryGenerator->getMeta($this->module);
        $this->modulefields = $this->fieldobj->getModuleFields();
    }

    public function getKanBanViewQuery(){
        global $adb;
        $list_query = "SELECT ";

        $selectColumn = $this->getSelectColumn();
        if ($this->ishasCurrency == 'yes'){
            $currency_id_field = $this->focus->table_name.'.currency_id as currency_id'; //币种ID
            $currency_symbol_field = ','.$this->focus->table_name.'.currency_symbol as currency_symbol'; //币种符号
            $list_query .= $currency_id_field . $currency_symbol_field . ',' ;
        }
        $SQLColumnFrom=$this->queryGenerator->getFromClause();//字段来源的表
        $tablecf = $this->focus->customFieldTable[0];
        if (!stristr($SQLColumnFrom,$tablecf) && !array_key_exists($tablecf,$this->leftjointable)){
            $tablecfid = $this->focus->customFieldTable[1];
            $SQLColumnFrom .= ' left join '.$tablecf.' on '.$tablecf.'.'.$tablecfid.' = '. $this->focus->table_name.'.'.$this->focus->table_index.' ';
        }
        $list_query.=$selectColumn.$SQLColumnFrom;

        $page_list_query = $this->queryGenerator->getQuery('',1);
        $table_id_index=$this->focus->table_index;
        $list_query.=' inner join ( '.$page_list_query. " ) as tmp on tmp.".$table_id_index."=".$this->focus->table_name.'.'.$table_id_index;
        $this->query = $list_query;
        $this->result = $adb->pquery($list_query, array());
        if ($adb->num_rows($this->result)>0)
            $this->listInfo = $adb->query_result_all($this->result);
        else
            $this->listInfo = [];

        return $this->query;
    }

    public function getSelectColumn(){
        $field = $this->modulefields[$this->pick_fieldname];
        $columnname = $field->getColumnName();
        $tablename = $field->getTableName();
        $this->advance_columnname = $columnname;
        $advance_field =$tablename.'.'.$columnname;
        $SQLColumn=$this->getSelectColumnSQLbyMobileSettings();//获取移动端模块列表定制中启用的字段
        if (!in_array($advance_field, $SQLColumn)) {//如果移动端模块列表定制中启用的字段不包括自动化设置中选择的跟踪字段,则添加上
            $SQLColumn[]=$advance_field;
        }
        $table_index = ','.$this->focus->table_name.'.'.$this->focus->table_index.' as crmid'; //单据id
        $this->selectColumn =  implode(',',$SQLColumn).$table_index;
        return $this->selectColumn ;
    }

    public function getKanBanViewData(){
        $listInfoByPick = [];
        foreach ($this->listInfo as $index => $listinfo){

            foreach ($listinfo as $columnname =>$value){
                if ($columnname == 'crmid'){
                    continue;
                }
                $fieldname=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",$columnname,"fieldname");
                $fieldinfo=$this->modulefields[$fieldname];
                $showvalue=$this->showfieldvalueobj->getFieldValueByField($fieldinfo,$value,$value);
                $listinfo[$columnname] = $showvalue['value'];
            }
            $listInfoByPick[$listinfo[$this->advance_columnname]]['list'][$listinfo['crmid']]=$listinfo;
            if ($this->ishasCurrency  == 'yes' && $listinfo['amountsum'] != '') {
                $listInfoByPick[$listinfo[$this->advance_columnname]]['billamount'] += $listinfo['amountsum'];
            }
        }
        //dump($listInfoByPick);
        foreach ($this->pickInfo as $index =>$pickinfo){
            $listvalue = $pickinfo['listvalue'];
            $pickinfo['total'] = sizeof($listInfoByPick[$listvalue]['list']);
            $pickinfo['list'] = $listInfoByPick[$listvalue]['list'];
            if ($this->ishasCurrency == 'yes') {
                $pickinfo['billamount'] = $this->defaultcurrency.$listInfoByPick[$listvalue]['billamount'];
            }
            $this->detailInfo[$index] = $pickinfo;
        }

        return $this->detailInfo;

    }

    public function getKanBanViewHtml(){
        $viewid = $this->customView->getViewId($this->module);
        $html = '<input type="hidden" id="viewname" name="viewname" value="'.$viewid.'">';
        $html .= '<input type="hidden" id="viewid" name="viewid" value="'.$viewid.'">';
        $html .='<div class="ld-stageItem" id="hdScrolllistentries_yy" style="position:relative;visibility: visible;overflow-x:scroll;overflow-y: hidden;padding-right:20px;background-color: #F0F2F5;width: '.$this->pagewidth.'">';
        foreach($this->detailInfo as $index=>$info){
            $html .='<div class="ld-kanban" style="height:'.$this->pageheight.'" ><div class="ld-stageName" style="background: '.$info['bgcolor'].'">'.$info['listvalue'].'</div>';
            $total=$info['total'];
//            $html .= '<div class="ld-stageInfo">'.getFixedLabel('TOTAL').' ：';
            $html .= '<div class="ld-stageInfo">';
            if ($this->ishasCurrency == 'yes'){
                $billamount=$info['billamount'];
                $html .= $billamount . ' | ';
            }
            $html .= $total.getFixedLabel('GECOUNT');
            $html .= '</div>';
            $tmp_pageheight = (int)explode('px',$this->pageheight)[0];
            $tmp_pageheight = $tmp_pageheight - 82;
            $html .= '<div class="ld-stagelist" style="height: '.$tmp_pageheight.'px">';

            foreach($info['list'] as $crmid=>$fieldinfo){
                $html.='<div class="ld-potential-item" style="overflow-y:hidden" record="'.$crmid.'" id="cube_'.$crmid.'" module="'.$this->module.'" onmouseover="editshow(this)" onclick="ListLinkClick(ld(this),event)">';
                $isfirst = 'no';
                foreach($fieldinfo as $fieldname => $fieldvalue){
                    if($fieldname != $this->advance_columnname && $fieldname != 'crmid' && $fieldname != 'listvalue'){
                        $label=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",$fieldname,"fieldlabel");
                        if ($isfirst == 'no'){
                            $html .= '<div class="ld-potential-itemName groupuser-treediv-span tip-items-list" data-tip="'.$fieldvalue.'" data-direction="top" data-type="position"><span onclick="editshow()">'.$fieldvalue.'</span></div>';
                            $isfirst = 'yes';
                            if (sizeof($fieldinfo) >=2){
                                $html .= '<div class="ld-potential-itemInfo">';
                            }
                        }else{
                            if($label != ''){
                                $html .= '<div style="display: flex;margin-left: 10px;"><span onclick="editshow()">'.$label.':'.$fieldvalue.'</span></div>';
                            }
                        }
                    }
                }
                if(sizeof($fieldinfo) >= 2){
                    $html .= '</div>';
                }
                $html .= '</div>';
                if (isPermitted($this->module,'EditView','') == 'yes'){
                    $html .= '<div id="float_edit_'.$crmid.'" class="float-edit ld-potential-itembtns" onclick="editdetail(this,\''.$this->module.'\',\'Edit\',\''.$crmid.'\')"><span class="ld-potential-itembtn">'.getFixedLabel('EDIT').'</span></div>';
                }
                $html .= '<div style="height: 7px;"></div>';
            }
            $html .= '</div></div>';
            $html .= '';
        }
        $html .= '</div>';
        $this->KanBanViewHtml = $html;
        return $html;
    }

    public function getKanBanViewList($pagewidth,$pageheight){
        $this->pagewidth = $pagewidth;
        $this->pageheight = $pageheight;
        $this->getKanBanViewBasicInfo();
        $this->getKanBanViewQuery();
        $this->getKanBanViewData();
        $this->getKanBanViewHtml();
        return $this->KanBanViewHtml;
    }

    //获取移动端模块列表定制中的字段 用于sql查询
    public function getSelectColumnSQLbyMobileSettings(){
        global $adb;
        $this->leftjointable=[];
        //ld_cvcolumnlist_wx 通过modulename确定模块，presence确定是否启用。Showtag是否显示字段名
        $sql="select columnname,presence from ld_cvcolumnlist_wx where modulename='".$this->module."' and presence=0 order by rownumber asc ";
        $result=$adb->query($sql,array());
        $nums=$adb->num_rows($result);
        $SQLColumn=[];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $columnname=explode(':',$adb->query_result($result,$i,'columnname'));
                if (!array_key_exists($columnname[0],$this->leftjointable)){
                    $this->leftjointable[$columnname[0]]=$columnname[0];
                }
                $presence=$adb->query_result($result,$i,'presence');//该字段是否启用
                $fieldinfoobj = $this->fieldobj->getFieldInfoobjBykey('fieldname',$columnname[2]);
                if($presence==0 && !empty($fieldinfoobj)){
                    $SQLColumn[]=$fieldinfoobj->getTableName().'.'.$columnname[1];
                }
            }
        }
        $this->SelectColumnSQLbyMobileSettings = $SQLColumn;
        return $SQLColumn;
    }
    //获取含有金额字段的模块名
    public function getCurrencyModule(){
        global $adb;
        $sql = 'select ld_tab.`name` as module from ld_field left join ld_tab on ld_tab.tabid = ld_field.tabid where fieldname = ?';
        $result = $adb->pquery($sql,array('currency_id'));
        $this->hasCurrencyModuleArr = $adb->query_result_all($result);
        $this->ishasCurrency = 'no';
        if (isset($this->hasCurrencyModuleArr[$this->module])){
            $this->ishasCurrency = 'yes';
        }
        return $this->hasCurrencyModuleArr;
    }

    //移动端获取跟踪字段内容和数量
    public function getKanBanPickAmounts(){
        global $adb;
        $this->getKanBanViewBasicInfo();
        $list_query = "SELECT ";
        $advance_field=$this->queryGenerator->getSQLColumn($this->pick_fieldname);
        $SQLColumnFrom=$this->queryGenerator->getFromClause();//字段来源的表
        $SQLWhere=$this->queryGenerator->getWhereClause();//字段来源的表
        $list_query.='count('.$advance_field.') as amount,'.$advance_field.' as listvalue'.$SQLColumnFrom;
        $page_list_query = $this->queryGenerator->getQuery('',1);
        $table_id_index=$this->focus->table_index;
        if (!empty($page_list_query)){
            $list_query.=' inner join ( '.$page_list_query. " ) as tmp on tmp.".$table_id_index."=".$this->focus->table_name.'.'.$table_id_index;
        }
        $list_query.=' '.$SQLWhere.' group by '.$advance_field;
        $result = $adb->pquery($list_query, array());
        if ($adb->num_rows($result)>0){
            $result_pick=$this->pickInfo;
            foreach($result_pick as $key => $pick_info){
                $result_pick[$key]['selected'] = 'no';
                if($result_pick[$key]['bgcolor'] == ''){
                    $result_pick[$key]['bgcolor'] = '#0083ff';
                }
                if ($this->module != 'Potentials'){
                    unset($result_pick[$key]['winrate']);
                }
            }
            if ($this->module != 'Potentials'){
                for ($i=0;$i<$adb->num_rows($result);$i++){
                    $listvalue = $adb->query_result($result,$i,'listvalue');
                    $amount = $adb->query_result($result,$i,'amount');
                    foreach($result_pick as $key => $pick_info){
                        if ($pick_info['listvalue'] == $listvalue){
                            $result_pick[$key]['amount'] = $amount;
                            break;
                        }
                    }
                }
            }
        }
        return $result_pick;
    }


}
?>