<?php

class cls_CallRecord
{
    public $module;
    public $record;
    public $waveform_arr = [
        'themes/icon2024/callrecord-waveform1.png',
        'themes/icon2024/callrecord-waveform2.png',
        'themes/icon2024/callrecord-waveform3.png',
    ];
    public function __construct($module='',$record='')
    {
		global $adb;
		$this->record = $record;
		$this->module = $module;
    }
    // 获取通话记录启用状态
    public function getCallRecordStatus() {
    	global $adb;

    	$select_sql = "SELECT `status` from ld_callrecordfields WHERE `status` = 'yes'";
        $result = $adb->pquery($select_sql, array());
    	$num_rows = $adb->num_rows($result);
    	if($num_rows > 0){
            return 'yes';
        }
        return 'no';
    }

    // 获取模块启用手机字段
    public function getEnabledPhoneFields($type='') {
        global $adb;


        $select_sql = "SELECT * from ld_callrecordfields";
        $result = $adb->pquery($select_sql, array());
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++){
                $tmp_arr = [];
                $module = $adb->query_result($result,$i,'module');
                $focus=CRMEntity::getInstance($module);
                $columnnames = $adb->query_result($result,$i,'columnnames');
                $columnname_arr = explode(',',$columnnames);
                foreach ($columnname_arr as $index => $columnname) {
                    if($columnname == 'mobile' && $module == 'Accounts')// BUG20240514-65 功能定制--通话录音设置：客户这边不应该可以选到首要联系人的手机字段
                        continue;
                    $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
                    if($fieldinfo){
                        if($type == 'label'){
                            $tmp_arr[] = $fieldinfo->getFieldLabelKey();
                        }else{
                            $tmp_arr[] = $fieldinfo->getColumnName();
                        }
                    }else{
                        $field_infos[$module] = [];
                    }
                }
                if($type == 'label'){
                    $tmp_arr = implode(' , ',$tmp_arr);
                }
                $field_infos[$module] = $tmp_arr;
            }
        }
        return $field_infos;
    }
    // 获取可设置的模块
    public function getModules() {
        global $adb;

        $select_sql = "SELECT * from ld_callrecordfields";
        $result = $adb->pquery($select_sql, array());
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++){
                $module =  $adb->query_result($result,$i,'module');
                $modulelist[$i]['value'] = $module;
                $modulelist[$i]['label'] = getTranstab($module);
            }
        }
        return $modulelist;
    }
    // 获取所有模块通话录音启用状态
    public function getAllModuleCallRecordStatus() {
        global $adb;

        $select_sql = "SELECT * from ld_callrecordfields";
        $result = $adb->pquery($select_sql, array());
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++){
                $module = $adb->query_result($result,$i,'module');
                $modulestatus[$module] = $adb->query_result($result,$i,'status');
            }
        }
        return $modulestatus;
    }
    // 获取指定模块通话录音启用状态
    public function getModuleCallRecordStatus() {
        global $adb;

        $select_sql = "SELECT * from ld_callrecordfields WHERE module = ?";
        $result = $adb->pquery($select_sql, array($this->module));
        $modulestatus = 'no';
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++){
                $modulestatus = $adb->query_result($result,$i,'status');
            }
        }
        return $modulestatus;
    }
    // 获取模块可用手机字段
    public function getPhoneFields() {
        global $adb;

        $modulelist = $this->getModules();
        $enabled_phonefields = $this->getEnabledPhoneFields();
        $modulestatus = $this->getAllModuleCallRecordStatus();
        foreach ($modulelist as $index => $moduleinfo) {
            $module = $moduleinfo['value'];
            $focus = CRMEntity::getInstance($module);
            $fieldinfos = $focus->fieldobj->getModuleFields();
            $i = 0;
            $phone_fields[$module]['label'] = getTranstab($module);
            $phone_fields[$module]['checked'] = $modulestatus[$module]=='yes'?'checked':'';
            foreach ($fieldinfos as $fieldname => $fieldinfo){
                if($fieldinfo->getBigType() == 'mobile' && $fieldinfo->getSaveDataBase() == 'yes'){
                    $columnname = $fieldinfo->getColumnName();
                    if($columnname == 'mobile' && $module == 'Accounts')// BUG20240514-65 功能定制--通话录音设置：客户这边不应该可以选到首要联系人的手机字段
                        continue;
                    $phone_fields[$module]['field'][$i]['columnname'] = $columnname;
                    $phone_fields[$module]['field'][$i]['fieldlabel'] = $fieldinfo->getFieldLabelKey();
                    if(in_array($columnname,$enabled_phonefields[$module])){
                        $phone_fields[$module]['field'][$i]['checked'] = 'checked';
                    }else{
                        $phone_fields[$module]['field'][$i]['checked'] = '';
                    }
                    $i++;
                }
            }
        }
        // dump($phone_fields);

        return $phone_fields;
    }
    // 保存设置的模块启用状态和字段启用状态
    public function setModuleAndFieldStatus($enabledmodule,$enabledphonefields) {
        global $adb;

        $update_sql1 = "UPDATE ld_callrecordfields SET `status` = 'no'";
        $adb->pquery($update_sql1, array());

        $valueLength = implode(',', array_fill(0, count($enabledmodule), '?'));
        $update_sql2 = "UPDATE ld_callrecordfields SET `status` = 'yes' WHERE module in ($valueLength)";
        $adb->pquery($update_sql2, array($enabledmodule));

        foreach ($enabledphonefields as $module => $columnnames) {
            $update_sql3 = "UPDATE ld_callrecordfields SET `columnnames` = ? WHERE module = ?";
            $adb->pquery($update_sql3, array($columnnames,$module));
        }

    }
    // 保存设置的模块启用状态和字段启用状态
    public function getList() {
        global $adb,$current_user,$languageType;
        global $theme;
        $languageType= getLanguageType($current_user);
        $module = $this->module;
        $record = $this->record;
        $weekarray_zh=array("日","一","二","三","四","五","六");
        $weekarray_en=array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");

        $Smownerids = getCurSmOwnerSearchScope('CallRecord');// 数据范围
        $userids = $current_user->id;
		foreach($Smownerids['UserCombo'] as $userid => $userinfo)
		{
			if(!empty($userid))
				$userids .=",".$userid; 
		}

        $focus = CRMEntity::getInstance($module);
        $table_index = $focus->table_index;
        if($module=='ContactRecords')
        {
            $table_index='contactrecordsid';

        }
        $select_sql = "SELECT * from ld_callbutler WHERE $table_index = ? AND userid in ( $userids ) ORDER BY begintime DESC";
        $result = $adb->pquery($select_sql, array($record));

        $list_data = [];
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            $k = 0;
            $date_index = -1;
            for($i = 0; $i<$num_rows; $i++){
                $calltype = $adb->query_result($result,$i,'calltype');
                $phone = $adb->query_result($result,$i,'phone');
                $status = $adb->query_result($result,$i,'status');
                $begintime = $adb->query_result($result,$i,'begintime');
                $talktime = $adb->query_result($result,$i,'time');
                $userid = $adb->query_result($result,$i,'userid');
                // $crmid = $adb->query_result($result,$i,$table_index);
                $filepath = $adb->query_result($result,$i,'soundrecordingfile');
                // 通话时长格式转换
                $talk_minutes = floor($talktime / 60);
                $talk_seconds = $talktime % 60;
                $talk_timeFormatted = sprintf("%02d:%02d", $talk_minutes, $talk_seconds);
                // 随机波形图
                $randomIndex = array_rand($this->waveform_arr);
                $waveform = !empty($filepath) ? $this->waveform_arr[$randomIndex]:'';

                $date = new DateTime($begintime);
                $now_date = $date->format('Y-m-d');// 获取日期部分
                $time = $date->format('H:i');// 获取时间部分
                if($now_date != $prev_date){
                    $k = 0;
                    $date_index++;
                }
                // 日期 加星期几
                if($languageType=='zh')
				    $week_num = "星期".$weekarray_zh[date("w",strtotime($now_date))];
                else
                    $week_num = $weekarray_en[date("w",strtotime($now_date))];
                $list_data[$date_index]['title'] = $now_date. '　　　' . $week_num;
                $list_data[$date_index]['list'][$k]['calltype'] = $calltype;
                $list_data[$date_index]['list'][$k]['phone'] = $phone;
                $list_data[$date_index]['list'][$k]['status'] = $status;
                $list_data[$date_index]['list'][$k]['begintime'] = $begintime;
                $list_data[$date_index]['list'][$k]['time'] = $time;
                $list_data[$date_index]['list'][$k]['talktime'] = $talk_timeFormatted;// 通话时长
                $list_data[$date_index]['list'][$k]['username'] = getUserFullName($userid);
                $list_data[$date_index]['list'][$k]['recordlabel'] = getModuleHref($module,$record);
                $list_data[$date_index]['list'][$k]['filepath'] = str_replace("\\", "/", $filepath);
                $list_data[$date_index]['list'][$k]['waveform'] = $waveform;
                // 关联创建 跟进记录
                $list_data[$date_index]['list'][$k]['relatedcreate'] = [];
                crm_load_class_file('cls_getRelatedInfoHtml','include/ListView/RelatedListView');
                $cls_getRelatedInfoobj=new cls_getRelatedInfoHtml($module,'',$record);
                $related_module = 'ContactRecords';
                if(isPermitted($related_module,'Create') == 'yes'){
                    $list_data[$date_index]['list'][$k]['relatedcreate']['url'] = "index.php?module=$related_module&action=EditView&return_module=$related_module&return_action=DetailView&relatedcreate=yes&Create=true&frommodule=$module&fromid=$record&parent_id=$record".$cls_getRelatedInfoobj->RelatedCreateParams();
                    $list_data[$date_index]['list'][$k]['relatedcreate']['frommodule'] = $module;
                    $list_data[$date_index]['list'][$k]['relatedcreate']['module'] = $related_module;
                    $list_data[$date_index]['list'][$k]['relatedcreate']['record'] = $record;
                }

                $prev_date = $date->format('Y-m-d');// 获取日期部分
                $k++;
            }
            // // 格式转换
            // $weekarray_zh=array("日","一","二","三","四","五","六");
            // $weekarray_en=array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
			// foreach($list_data as $date => $arr){
            //     $num = sizeof($arr);
            //     for($tmp_i=0;$tmp_i<$num;$tmp_i++){//按时间重新排序
            //         $tmp_maxindex = 0;
            //         for($tmp_j=0;$tmp_j<$num-$tmp_i;$tmp_j++){
            //             if(strtotime($arr[$tmp_j]['begintime'])-strtotime($arr[$tmp_maxindex]['begintime'])<0){
            //                 $tmp_maxindex =$tmp_j; 
            //             }
            //         }
            //         $tmp_arr = $arr[$num-$tmp_i-1];
            //         $arr[$num-$tmp_i-1] = $arr[$tmp_maxindex];
            //         $arr[$tmp_maxindex] = $tmp_arr;
            //     }
            //     if($languageType=='zh')
			// 	    $week_num = "星期".$weekarray_zh[date("w",strtotime($date))];
            //     else
            //         $week_num = $weekarray_en[date("w",strtotime($date))];
			// 	$data[] = array(
			// 		'title' => $date . '　　　' . $week_num,
			// 		'list' => $arr
			// 	);
			// }
        }
        // dump($list_data);
        return $list_data;
    }




























































































































































































































































































































































































































































































































































































































































































































































































































































































    public function getPhoneActiveField()
    {
        global $adb;
        $sql='select * from ld_callrecordfields where status=? and ifnull(columnnames,"")<>""';
        $result=$adb->pquery($sql,array('yes'));
        $arr=[];
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $module=$adb->query_result($result,$i,'module');
            $fieldobj=Field::getInstance($module,$adb);

            $columnnames=$adb->query_result($result,$i,'columnnames');
            $column_arr=explode(",",$columnnames);
            $allField_arr= $fieldobj->getModuleAllPreseneceFields() ;
            $table_arr=[];
            foreach($column_arr as $tmpindex=> $tmpcolumnname)
            {
                $columnname='';
                if(array_key_exists($tmpcolumnname,$allField_arr))
                {
                         $table_arr[]=$allField_arr[$tmpcolumnname]->getTableName();

                }

                foreach(  $allField_arr as $tmpfieldname=>$tmpfieldinfo)
                {
                    if($tmpfieldinfo->getColumnName()==$tmpcolumnname)
                    {
                        $columnname=$tmpcolumnname;
                        $table_arr[]=$tmpfieldinfo->getTableName();
                        break;
                    }
                }
                $column_arr[$tmpindex]=$columnname;
            }

            $column_arr=array_filter($column_arr);
            $arr[]=['module'=>$module,'column_arr'=>$column_arr,'tables'=>$table_arr];

        }
        return $arr;

    }


    public function getCrmIdByPhone($phonenumber)
    {
        global $adb;
       $fieldinfo_arr= $this->getPhoneActiveField();
       $modulecallrecordfield_arr=['Leads'=>'leadsid','Accounts'=>'accountid','Contacts'=>'contactid'
           ,'Potentials'=>'potentialid','Vendors'=>'vendorid','VendorContact'=>'vendorcontactid'];

       $crmid_arr=[];
       foreach($fieldinfo_arr as $tmpinfo)
       {
           $module=$tmpinfo['module'];
           $focus=CRMEntity::getInstance($tmpinfo['module']);
           $allpresencefield= $focus->fieldobj->getModuleAllPreseneceFields() ;
           $listlinkfieldinfo= $allpresencefield[$focus->list_link_field];
           $listlinkcol=$listlinkfieldinfo->getColumnName();
           $tmpinfo['tables'][]=$listlinkfieldinfo->getTableName();
           $tableindex=$focus->table_index;
           $tablename=$focus->table_name;
            $calllogcolumnname=$modulecallrecordfield_arr[$module];

           $sql="select distinct  $tablename.$tableindex as crmid, '$module' as modulename,'$calllogcolumnname' as calllogcolumn,$listlinkcol as hrefvalue  from $tablename   ";
           $tmpinfo['tables']=array_unique($tmpinfo['tables']);
           foreach($tmpinfo['tables'] as $tmptablename)
           {
               if($tmptablename!=$tablename)
               {
                   $tmptableindex=$focus->tab_name_index[$tmptablename];

                   $sql.="  left join $tmptablename on $tmptablename.$tmptableindex= $tablename.$tableindex ";
               }
           }
           $where_arr=[];
           if(sizeof($tmpinfo['column_arr'])>0)
           {

               foreach ($tmpinfo['column_arr']  as $columnname)
               {
                   $where_arr[]=  " $columnname ='".$phonenumber."'  ";
               }
               $sql.=' where deleted=0 and ('.implode(" or  ",$where_arr)." )";
           }
         //file_put_contents(globalStatic::$root_directory."modules/Settings/aaa.txt", $sql.';'."\n\n",FILE_APPEND);
           $result=$adb->pquery($sql,array());
           for($i=0;$i<$adb->num_rows($result);$i++)
           {
               $crmid_arr[]=['crmid'=>$adb->query_result($result,$i,'crmid'),'calllogcolumn'=>$adb->query_result($result,$i,'calllogcolumn')
                   ,'hrefvalue'=>$adb->query_result($result,$i,'hrefvalue')];

           }



       }
       return $crmid_arr;
    }

    /**
     * @param $callednumber:拨打的电话号码
     * @param $uploadfilename：录音文件名称
     * @param $calltype：来电，去电
     * @param $calltime：通话开始时间
     * @param $duration：通话时长
     * @return string
     */
    public function  isExistsLog($callednumber,$uploadfilename,$calltype, $calltime,$duration)
    {
        global $adb;
        $uploadfilename= ChangeUploadFilename($uploadfilename);
        $uploadfilename= FileFileterString($uploadfilename);
        $sql='select * from ld_callbutler where phone=? and recordingfilename=? and calltype=? and begintime=? and time=? limit 1';
        $result=$adb->pquery($sql,array($callednumber,$uploadfilename,$calltype,$calltime,$duration));


        $arr=[];
        if($adb->num_rows($result)>0)
        {
            return 'yes';
        }
        return 'no';

     /*   for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $soundrecordingfile=$adb->query_result($result,$i,'soundrecordingfile');



        }*/



    }




//获取通话记录在手机端的路径
    public function getMobileRecordPath()
    {

        global $adb,$current_user;
        $sql='select * from ld_module_setting_byuser where userid=? and type=?';
        $result=$adb->pquery($sql,array($current_user->id,"mobilerecordpath"));
        if($adb->num_rows($result)>0)
            return $adb->query_result($result,0,'content');
        return '';

    }

    public function getlastprevlogbyphone($userid,$uuid)
    {
        global $adb;
        $sql='select * from ld_module_setting_byuser  where modulename=? and userid=? and label=?';
        $result=$adb->pquery($sql,array('CallLog',$userid,$uuid));
        $arr=[];
        $arr['begintime']='';
        if($adb->num_rows($result)>0)
        {
            $begintime=$adb->query_result($result,0,'content');
            $arr['begintime']=$begintime;
        }
        return $arr;

    }












    
}

?>