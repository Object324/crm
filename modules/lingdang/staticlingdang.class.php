<?php
/**
 * 锟睫改憋拷锟斤拷锟绞?统一锟斤拷锟诫：UTF-8
 * @author Tujt 2015-04-21
 */
class staticlingdang {
    /**
	 * 锟斤拷取锟斤拷前锟街讹拷锟角凤拷锟截革拷锟斤拷锟斤拷锟叫讹拷锟竭硷拷锟斤拷锟斤拷一锟斤拷锟斤拷锟斤拷锟叫ｏ拷锟斤拷锟姐弹锟斤拷锟斤拷锟斤拷俅锟斤拷锟绞憋拷锟斤拷酶梅锟斤拷锟?
	 * @reason 0014245: 锟酵伙拷->锟酵伙拷锟斤拷锟斤拷唯一锟斤拷锟叫讹拷漏锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷->选锟斤拷锟斤拷锟斤拷锟?>使锟矫匡拷锟劫达拷锟斤拷未锟斤拷锟斤拷锟街讹拷唯一锟斤拷
	 * @author Tujt 2015-04-21
	 */
	public static function getFieldDuplicateInfo($module,$fieldname,$fieldvalue,$fieldid = 0) {
	    $tradeInfo = getVersionTradeInfo();
		global $adb,$current_user;
		$languageType= getLanguageType($current_user);
		$focus = CRMEntity::getInstance($module);
		$tabid = getTabid($module);
		$fieldvalue = trim($fieldvalue);
        $field=$focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);

        if(!$field||$fieldvalue=='') {
            $rest = "##success##";
            return $rest;
        }

		$sql = 'select tablename ,ld_tranlabel.fieldlabel,columnname,uitype,fieldname 
					from ld_field 
						inner join ld_tranlabel 
							on ld_tranlabel.relateid=ld_field.fieldid 
					where languagetype = ? and trantable = ? and 
						ld_tranlabel.tabid = ? and fieldname = ? ';
		//$result = $adb->pquery($sql,array($languageType,'ld_field',$tabid,$fieldname));
		$tablename = $field->getTableName();
		$fieldlabel = $field->getFieldLabel();
		$columnname = $field->getColumnName();
		$uitype = $field->getUIType();
		$bigtype = $field->getBigType();
	    //	$fieldname = $adb->query_result($result,0,'fieldname');
        //21600: 锟斤拷锟斤拷锟斤拷锟斤拷:锟斤拷某锟街讹拷锟斤拷锟斤拷为锟斤拷锟斤拷锟斤拷锟截革拷锟斤拷锟斤拷锟铰斤拷锟斤拷锟斤拷锟斤拷时锟斤拷锟街讹拷锟斤拷锟斤拷锟斤拷同锟斤拷锟斤拷息没锟斤拷锟斤拷示锟斤拷锟斤拷锟斤拷锟截革拷
		$tableid = $focus->tab_name_index[$tablename];
        if(($module=='Accounts'||$module=='ServiceCharge'))
        {
            $contact_focus=CRMEntity::getInstance('Contacts');
            if(in_array($tablename,$contact_focus->tab_name))
            {
                $tableid=$contact_focus->tab_name_index[$tablename];
                $tableid=$contact_focus->tab_name_index[$tablename];
                $contactid=0;
				if(!empty($fieldid)){
					$sql='select contactid from ld_contactdetails where accountid=? and reference=1 and deleted=0 ';
					$contact_result=$adb->pquery($sql,array($fieldid));
					if($adb->num_rows($contact_result)>0)
					{
						$contactid=$adb->query_result($contact_result,0,0);
					}
				}
                if(!empty($contactid)){
					$sql = 'select 1 from ld_contactdetails ';
					$sql .= " LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid ";
					$sql .= ' where  deleted=0 and ld_contactdetails.' .$tableid.'<>? and '.$columnname.'=?  and  ld_contactdetails.'.$tableid.'>0 limit 1 ';
					$result = $adb->pquery($sql,array($contactid,$fieldvalue));
				}else{
					$sql = 'select 1 from ld_contactdetails ';
					$sql .= " LEFT JOIN ld_contactscf on ld_contactscf.contactid = ld_contactdetails.contactid ";
					$sql .= ' where  deleted=0 and '.$columnname.'=? limit 1 ';
					$result = $adb->pquery($sql,array($fieldvalue));
				}

                if($adb->num_rows($result) > 0) {
                    if(!empty($_REQUEST['is_duplicate']) && $_REQUEST['is_duplicate'] == 'yes'){
                        $rest = '##confirm##'. str_replace("#fieldlabel#",$fieldlabel,getFixedLabel('fieldlabelthesame'));
                    }else{
                        $rest = '##error##'. $fieldlabel.getFixedLabel('CANNOTREPEAT');
                    }
                }else {
                    $rest = "##success##";
                }
                return $rest;
            }
        }
        if($uitype==4) {
            return "##success##";
        }
        $sql = 'select 1 from '.$focus->table_name;
        if($tablename!==$focus->table_name)
        {
           $scf_index=$focus->tab_name_index[$tablename];
           $sql .=   ' left join  '.$tablename." on  $focus->table_name.$focus->table_index=$tablename.$scf_index ";
        }
        //wym 240412 1000195 销售线索和客户增加一起查重功能，包括新增、导入（邹晓宇）
        $joincheckdup=false;
        if($columnname=='accountname'){
            $joinmodule=getUsersettingByLabel($module,'1','JointCheckDuplicate');
            if(!empty($joinmodule) && $joinmodule!='no'){
                crm_load_class_file('cls_rule_validata','include/utils');
                $joincheckdup = cls_rule_validata::checkDuplicate($fieldvalue,$joinmodule,$module,$fieldid);
            }
        }
        //BUG0071999 ls 20230901 跟进记录-编辑-保存，提示【现场签到记录不能重复！】-实际上 这个字段是空的
        if ($bigtype == 'reference') {//关联选择单据  不选时为0,数据库类型默认保存也是0,导致存在
            $sql.=' where   deleted=0 and ('.$tablename.'.'.$tableid.' <> ?)  and  '.$tablename.'.'.$columnname.' > 0 and  '.$tablename.'.'.$columnname.' = ?  and '.$tablename.'.'.$tableid.' >0  limit 1;';
        }else{
            $sql.=' where   deleted=0 and ('.$tablename.'.'.$tableid.' <> ?) and  '.$tablename.'.'.$columnname.' = ?  and '.$tablename.'.'.$tableid.' >0  limit 1;';
        }
		$result = $adb->pquery($sql,array($fieldid,$fieldvalue));
		$rest = '';
		if($adb->num_rows($result) > 0 || $joincheckdup==true){//联合查重返回true 即为查重结果大于0
			 if($uitype == 4){

             }else{
				//0024318: 新建产品时，若产品名称相同，给出提示信息。（包括快速创建产品）
				if(!empty($_REQUEST['is_duplicate']) && $_REQUEST['is_duplicate'] == 'yes'){
					$rest = '##confirm##'. str_replace("#fieldlabel#",$fieldlabel,getFixedLabel('fieldlabelthesame'));
				}else{
                    //zxm 20210110 【奥德客户报备个性化开发需求（施明程）】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001002406 客户报备重复，【保存】时自动共享客户信息给当前报备人
//                    if($tradeInfo['account']=='aode'&&$module=='Accounts'&&$fieldname=='accountname'){
//                        include_once globalStatic::$root_directory.'modules/Home/CustomMade/AodeUtils.php';
//                        $aodeObj = new AodeUtils();
//                        $aodeObj->to_share($fieldvalue);
//                    }
					$rest = '##error##'. $fieldlabel.getFixedLabel('CANNOTREPEAT');
                    if($joincheckdup==true){//wym BUG20240419-39 销售线索开启联合查重后，线索录入客户名称重复时的报错提示信息建议修改为：客户名称在销售线索或客户模块不能重复！
                        $rest = '##error##'. $fieldlabel.getFixedLabel('CHECKDUPTIP');
                    }
				}
			}

		}else{
			$rest = "##success##";
		}
		return $rest;
	}
	/**
	 * 锟叫讹拷锟角凤拷锟斤拷锟斤拷嗉?
	 * @author Tujt 2015-06-26
	 */
	public function checkEditInfo($input) {
		$module = $input['fld_module'];
		$record = $input['record'];
		$focus = CRMEntity::getInstance($module)->getModuleLogic($module);
		return array('check'=>$focus->checkEditInfo($module,$record));//锟斤拷锟斤拷锟斤拷嗉?
	}
	/**
	 * 锟叫讹拷锟角凤拷锟斤拷锟斤拷嗉?
	 * @author Tujt 2015-06-26
	 */
	public function checkDelInfo($input) {
		$module = $input['fld_module'];
		$record = $input['record'];
		$focus = CRMEntity::getInstance($module)->getModuleLogic($module);
        $retinfo=$focus->checkDelInfo($module,$record);

		return array('check'=>$retinfo);//
	}
	/**
	 * 锟叫断碉拷锟斤拷状态锟角凤拷锟斤拷锟斤拷嗉?
	 * @author Tujt 2015-06-26
	 */
	public function checkStatusInfo($input) {
		$module = $input['fld_module'];
		$record = $input['record'];
		$focus = CRMEntity::getInstance($module)->getModuleLogic($module);
		return array('check'=>$focus->checkStatusInfo($module,$record));//锟斤拷锟斤拷锟斤拷嗉?
	}
}
?>