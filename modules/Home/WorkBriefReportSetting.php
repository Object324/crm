<?php
crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
class WorkBriefReportSetting extends SalesKitEditSetting{
    public $table = 'ld_workreport_briefreport_detail';
    public $name;
    public $selected_list=[];
    public $custom_list=[];
    public $selected_count= 0;
    public $custom_count= 0;
    public $unselect_custom_list=[];
    public $select_custom_list=[];
    public $select_default_list=[];
    public $unselect_default_list=[];
    public function __construct(){
        global $adb, $languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->setReportLabelList();
        //edit: xll 2024/05/31 BUG20240531-02 工作汇报模块：日报预置的的日程管理 默认模块是销售线索 而且根本选不到日程管理模块
        $this->except = str_replace("'Calendar',",'',UNABLE2STATISTICSMODULE);
    }
    public function setReportLabelList(){
        $this->ReportLabelList = [
            'default' => [
                'label' => getFixedLabel('DefaultSaleskit'),
                'list' => [],
            ],
            'custom' => [
                'label' => getFixedLabel('CustomSaleskit'),
                'list' => [],
            ],
        ];
    }
    public function getAllList(){
        return $this->all_list;
    }
    public function getCustomList(){
        return $this->custom_list;
    }
    public function getDefaultList(){
        return $this->default_list;
    }
    public function getSelectedList(){
        return $this->selected_list;
    }
    public function getReportLabelList(){
        return $this->ReportLabelList;
    }
    public function getModuleArr(){
        parent::getModuleArr();
        return $this->newalltabs;
    }
    public function getCustomCount(){
        return $this->custom_count;
    }
    public function getListArr(){
        $adb=$this->adb;
        $sql= "select 
        name,sequence,presence,is_default,label_zh,label_en,count_module,count_type,count_columnname,count_datarange,count_timerange,advft_criteria,advft_criteria_groups,content_value 
        from ".$this->table." 
        where `delete`=0 
        order by sequence asc;";
        $result=$adb->pquery($sql,array());
        $num_row=$adb->num_rows($result);
        if ($num_row>0){
            $this->getDetailList($result);
        }
    }
    public function getDetailList($result){
        $languageType=$this->language;
        $adb=$this->adb;
        $num_row=$adb->num_rows($result);
        if ($num_row>0){
            $tepsequence = 0;
            for ($i=0;$i<$num_row;$i++){
                $name=$adb->query_result($result,$i,'name');
                $sequence=$adb->query_result($result,$i,'sequence');
                $presence=$adb->query_result($result,$i,'presence');
                $is_default=$adb->query_result($result,$i,'is_default');
                $label_zh=$adb->query_result($result,$i,'label_zh');
                $label_en=$adb->query_result($result,$i,'label_en');
                $count_module=$adb->query_result($result,$i,'count_module');
                $count_type=$adb->query_result($result,$i,'count_type');
                $count_columnname=$adb->query_result($result,$i,'count_columnname');
                $count_datarange=$adb->query_result($result,$i,'count_datarange');
                $count_timerange=$adb->query_result($result,$i,'count_timerange');
                $content_value=$adb->query_result($result,$i,'content_value');
                $advft_criteria=$adb->query_result($result,$i,'advft_criteria');
                $advft_criteria_groups=$adb->query_result($result,$i,'advft_criteria_groups');
                $moduleactive = vtlib_isModuleActive($count_module)==true?'yes':'no';
                $labelbylanguage=$languageType=='zh'?$label_zh:$label_en;
                if ($moduleactive == 'no' && $count_module != 'Singin') {
                    continue;
                }else{
                    $info = array(
                        'name' => $name,
                        'sequence' => $sequence,
                        'presence'=> $presence,
                        'delete' => 0,
                        'is_default' => $is_default,
                        'label_zh' => $label_zh,
                        'label_en' => $label_en,
                        'count_module' => $count_module,
                        'count_type' => $count_type,
                        'count_columnname' => $count_columnname,
                        'count_datarange' => $count_datarange,
                        'count_timerange' => $count_timerange,
                        'advft_criteria' => decode_html($advft_criteria),
                        'advft_criteria_groups' => decode_html($advft_criteria_groups),
                        'content_value' => $content_value,
                        'label' =>$labelbylanguage
                    );
                }
                if ($presence == 'yes'){
                    $tepsequence++;
                    $this->selectedlabel_list[]=$labelbylanguage;
                    $this->selected_count += 1;
                    $info['sequence'] =$tepsequence;
                    $this->selected_list[$name]=$info;
                }
                if ($is_default == 'yes'){
                    if ($presence == 'yes'){
                        $this->select_default_list[$name]=$info;
                    }else{
                        $this->unselect_default_list[$name]=$info;
                    }
                }else{
                    $this->custom_count += 1;
                    if ($presence == 'yes'){
                        $this->select_custom_list[$name]=$info;
                    }else{
                        $this->unselect_custom_list[$name]=$info;
                    }

                }
                $this->all_list[$name]=$info;
            }
            $this->ReportLabelList['default']['list']=$this->select_default_list + $this->unselect_default_list;
            $this->ReportLabelList['custom']['list']=$this->select_custom_list + $this->unselect_custom_list;
        }
    }
    public function getMaxIDFromMainTab(){
        $abd=$this->adb;
        $sql='select max(id) as id from '.$this->table;
        $result=$abd->pquery($sql,array());
        $id=$abd->query_result($result,0,'id');
        return $id;
    }
    public function getBriefReportLayout(){
        $colcount = 4;
        $count = $this->selected_count;
        $blockwidth = (100 / $colcount);
        $briefreport_layout['count'] = $count;//简报个数
        $briefreport_layout['colcount'] = 4;//每行简报个数
        $briefreport_layout['height'] = 120;//每行简报高度
        $briefreport_layout['rowcount'] = ceil($count / $colcount);//有多少行简报
        $briefreport_layout['blockwidth'] = $blockwidth;//每个简报的宽度
        return $briefreport_layout;
    }

}
?>