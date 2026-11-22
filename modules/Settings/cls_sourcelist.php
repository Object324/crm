<?php
class cls_sourcelist
{
    public $frommodule;
    public $sourcefieldid;//原单在ld_field表的id
    public function __construct($frommodule)
    {
        $this->frommodule=$frommodule;
       
    }
    public function getListHead()
    {
        return array(getFixedLabel('RelateChoiceModule'),getFixedLabel('WHETHERTOENABLE'),getFixedLabel('WHETHERDEFAULT'),getFixedLabel('ALLOWDataRange'),getFixedLabel('APPROVEDEMAND'));
        
    }
    public function getListContentData()
    {
        global $adb;
        $fld_module=$this->frommodule;
        $query='SELECT ld_option_module.*,ld_tab.`name` from ld_option_module inner join ld_tab 
            on ld_tab.tabid= ld_option_module.option_tabid where ld_option_module.tabid=? 
            order by ld_option_module.sequence asc';
        $tabid=getTabid($fld_module);
        $result = $adb->pquery($query,array($tabid));
        
        $num_rows=$adb->num_rows($result);
        
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $option_tabid = $adb->query_result($result,$i,'option_tabid');
                $module = $adb->query_result($result,$i,'name');
                $presence=$adb->query_result($result,$i,'presence');
                $default=$adb->query_result($result,$i,'default');
                $datarang=$adb->query_result($result,$i,'datarang');
                $approve_demand=$adb->query_result($result,$i,'approve_demand');
                $optionmodule=getTabname($option_tabid);

                //销售机会如果没有开启分录则不应该显示 zxm 20230526 BUG0066664   kfbcrm-合同订单-新建单据-选择源单（销售机会），勾选单据后点击选择 页面没反应，同时源单选择框内出现乱码
                if($module=='Potentials'&&get_file_address($fld_module,"ProductDetails")){
                    $sysdeploy = getSys_deploy(205);
                    if($sysdeploy['deploy_value']==1 && $fld_module != 'Singin'){
                        continue;
                    }
                }
                //edit:can 20230418  BUG0064906  页面设置，选择源单字段，关闭模块后，源单类型中的模块应该不显示 
                if(!vtlib_isModuleActive($optionmodule))
                        continue;
                $LIST_ENTRIES[] = array(
                            'tabid' => $option_tabid,
                            'modulelabel'=>getTranstab($module),
                            'module'=>$module,
                            'presence'=>$presence,
                            'default'=>$default,
                            'datarang'=>$datarang,
                            'fieldid'=>$this->sourcefieldid,
                            'approve_demand'=>$approve_demand
                        );
            }
        	
        }
        return $LIST_ENTRIES;
    }
}


?>