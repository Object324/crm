<?php
global $adb;
if(isset($_REQUEST['frommodule']) && isset($_REQUEST['sourcefield'])){
	$module = $_REQUEST['frommodule'];
	$tabid = getTabid($module);
	$sourcefield = $_REQUEST['sourcefield'];
    if($module == 'Accounts' && ($sourcefield == 'bill_country_mapping' || $sourcefield == 'bill_state_mapping' || $sourcefield == 'bill_city_mapping')){
        $module = 'Contacts';
        $sourcefield = str_replace('_mapping', '', $sourcefield);
    }
	$sourcevalue = $_REQUEST['sourcevalue'];
	crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
	$targetFieldArray = lingdang_DependencyPicklist::getTargetFields($tabid,$sourcefield);
	if(!empty($targetFieldArray)){
		foreach($targetFieldArray as $targetfield){
            if($_REQUEST['frommodule'] == 'Accounts' && ($_REQUEST['sourcefield'] == 'bill_country_mapping' || $_REQUEST['sourcefield'] == 'bill_state_mapping' || $_REQUEST['sourcefield'] == 'bill_city_mapping')){
                $targetValues['list'][$targetfield.'_mapping'] = cls_StaticCommonFun::getSourceTargetValues($module,$sourcefield,$targetfield,$sourcevalue);
            }
            else{
                $targetValues['list'][$targetfield] = cls_StaticCommonFun::getSourceTargetValues($module,$sourcefield,$targetfield,$sourcevalue);
            }

		}
		ConvertTojsonString('1',$targetValues,'');
	}
	ConvertTojsonString('2','','');
}
exit();

?>