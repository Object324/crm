<?php
class cls_Uitype_125_WX
{
    static function get_uitype_125_wx($fieldinfo,$col_fields)
    {
        global $adb;
        $fieldname = $fieldinfo->getFieldName();
		if(!empty($fieldname) && !empty($col_fields['record_id']) && !empty($col_fields['record_module'])){
			$query = 'select entitytype,entitytypeid,percent,sequence from ld_shareequally_value where recordid = ? and fieldname = ? and module = ? order by sequence';
			$result = $adb->pquery($query,array($col_fields['record_id'],$fieldname,$col_fields['record_module']));
			$num_rows = $adb->num_rows($result);
			if($num_rows > 0){
				$shareequally_type = 1;
				for($i = 0; $i < $num_rows; $i++){
					$percent = $adb->query_result($result,$i,'percent');
					if($percent > 0){
						$shareequally_type = 2;
						break;
					}
				}
				for($i = 0; $i < $num_rows; $i++){
					$entitytype = $adb->query_result($result,$i,'entitytype');
					$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
					$percent = $adb->query_result($result,$i,'percent');
					$sequence = $adb->query_result($result,$i,'sequence');
					$shareseqully_value = $entitytype .','.$entitytypeid.','.$percent;
					$sourcemodule_focus = CRMEntity::getInstance($entitytype);
					$sourcemodule_focus->retrieve_entity_info($entitytypeid, $entitytype);
					$entityarray = getEntitynameInfo(getTabid($entitytype));
					if(!vtlib_isModuleActive($entitytype)){
						continue;
					}
					if($entitytype == 'Users'){
						$shareseqully_span = $sourcemodule_focus->column_fields['last_name'];
					}else{
						$shareseqully_span = $sourcemodule_focus->column_fields[$entityarray['fieldname']];
					}
                    $shareequally_one['id'] = $entitytypeid;
                    $shareequally_one['module'] = $entitytype;
                    $shareequally_one['modulename'] = getTransTab($entitytype);
                    $shareequally_one['percent'] = $percent;
                    if($shareequally_type==2){
                        //$shareseqully_span .= '('.$percent.'%)';
                    }
                    $shareequally_one['name'] = $shareseqully_span;
                    $shareequally_entity[] = $shareequally_one;
				}
                $_REQUEST['shareequally_type'] = $shareequally_type;
			}
		}
        return $shareequally_entity;
    }
}
?>