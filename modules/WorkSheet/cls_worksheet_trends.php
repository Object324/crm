<?php
/*
edit:duan
date:2021-11-18
reason:工单动态信息
*/

class cls_worksheet_trends
{
	public $record;
	public $module;
	public $focus;
	public $tabid;
	public $fields;
	public $data;
	public $datetime_array = [];
    
    public function __construct($record,$module)
    {
		global $adb;
		$this->record = $record;
		$this->module = $module;
        $this->focus = CRMEntity::getInstance($module);
		$this->tabid = getTabid($module);
		$fieldobj = $this->focus->fieldobj;
		$this->fields = $fieldobj->getModuleFields();
        $this->data = array();
    }

	public function getList(){
        global $current_user;
        $languageType= getLanguageType($current_user);
        //分配负责人历史
        $this->getSmowneridLog();
        //工单日志
        $this->getWorkSheetlog();
        //解决方案变更记录
        $this->getWorkSheetSolution();
        $data = array();  
		if(!empty($this->datetime_array)){
			rsort($this->datetime_array);
			foreach($this->datetime_array as $dates){
				$s_date = $dates['datetime'];
				$new_data[$s_date] = $this->data[$s_date];
			}
			$weekarray_zh=array("日","一","二","三","四","五","六");
            $weekarray_en=array("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday");
			foreach($new_data as $date => $arr){
                $num = sizeof($arr);
                for($tmp_i=0;$tmp_i<$num;$tmp_i++){//按时间重新排序
                    $tmp_maxindex = 0;
                    for($tmp_j=0;$tmp_j<$num-$tmp_i;$tmp_j++){
                        if(strtotime($arr[$tmp_j]['datetime'])-strtotime($arr[$tmp_maxindex]['datetime'])<0){
                            $tmp_maxindex =$tmp_j; 
                        }
                    }
                    $tmp_arr = $arr[$num-$tmp_i-1];
                    $arr[$num-$tmp_i-1] = $arr[$tmp_maxindex];
                    $arr[$tmp_maxindex] = $tmp_arr;
                }
                if($languageType=='zh')
				    $week_num = "星期".$weekarray_zh[date("w",strtotime($date))];
                else
                    $week_num = $weekarray_en[date("w",strtotime($date))];
				$data[] = array(
					'title' => $date . '　　　' . $week_num,
					'list' => $arr
				);
			}
		}
		return $data;
	}

	private function setDatetimeArray($date){
		$this->datetime_array[strtotime($date)] = array(
			'datetime' => $date,
			'times' =>strtotime($date),
		);
	}
	//获取工单日志信息
	private function getWorkSheetlog(){
		global $adb;
		$sql = 'select * from ld_worksheetlog where worksheetid = ?';
        $result = $adb->pquery($sql,array($this->record));
        $num_rows = $adb->num_rows($result);

        $worksheet_logarr = array();
        for($i=0;$i<$num_rows;$i++){
            $frommodule = $adb->query_result($result,$i,'modulename');
            $modifiedby = $adb->query_result($result,$i,'modifiedby');
            $modifiedtime = $adb->query_result($result,$i,'modifiedtime');
            $description = $adb->query_result($result,$i,'description');
            $worksheet_logarr[] = array('frommodule'=>$frommodule,
                                        'modifiedby'=>$modifiedby,
                                        'modifiedtime'=>$modifiedtime,
                                        'description'=>$description);
            
        }
        
        foreach($worksheet_logarr as $key=>$loginfo){
            $frommodule = $frommodule;
            $description = $loginfo['description'];
            $modifiedtime = $loginfo['modifiedtime'];
            $modifiedby = $loginfo['modifiedby'];
            $date = date("Y-m-d",strtotime($modifiedtime));
            $this->setDatetimeArray($date);
            switch($description){
                //创建工单
                case 'create':
                $data = $this->getCreateWorkSheetLog();
                //用户操作或客户操作
                $data['lastname'] = $this->focus->getName($frommodule,$modifiedby);
                $data['frommodule'] = $frommodule;
                $data['record'] = $loginfo['modifiedby'];
                $this->data[$date][]=$data;
                break;
                //领取工单
                case 'receive':
                $data = array(
        			'title' => getFixedLabel('RECEIVE') .getFixedLabel('WORKORDER'),
        			'time' => date("H:i",strtotime($modifiedtime)),
                    'lastname' => getUserFullName($modifiedby),
        			'datetime' => $modifiedtime,
        		);
                $this->data[$date][]=$data;
                break;
                //催单
                case 'urged':
                $data = array(
        			'title' => getFixedLabel('URGEREMIND'),
        			'time' => date("H:i",strtotime($modifiedtime)),
                    'frommodule' => $frommodule,
                    'lastname' => $this->focus->getName($frommodule,$modifiedby),
                    //'content' => getFixedLabel('URGEREMIND'),
        			'datetime' => $modifiedtime
        		);
                $this->data[$date][]=$data;
                break;
                //结单
                case 'ended':
                $data = array(
        			'title' => getFixedLabel('CLOSEBILL'),
        			'time' => date("H:i",strtotime($modifiedtime)),
                    'frommodule' => $frommodule,
                    'lastname' => $this->focus->getName($frommodule,$modifiedby),
        			'datetime' => $modifiedtime
        		);
                $this->data[$date][]=$data;
                break;
                //重新打开
                case 'reopen':
                $data = array(
        			'title' => getFixedLabel('REOPENWORKSHEET'),
        			'time' => date("H:i",strtotime($modifiedtime)),
                    'frommodule' => $frommodule,
                    'lastname' => $this->focus->getName($frommodule,$modifiedby),
                    //'content' => getFixedLabel('REOPENWORKSHEET'),
        			'datetime' => $modifiedtime
        		);
                $this->data[$date][]=$data;
                break;
            }
        }
	}
	//新建工单记录
    private function getCreateWorkSheetLog(){
		global $adb;
		$entityarray = getEntitynameInfo(getTabid($this->module));
		$link_tabname = $entityarray['tablename'];
		$link_tabfieldname = $entityarray['fieldname'];
		$tablename = $this->focus->table_name;
		$tableindex = $this->focus->table_index;
		$tablename_cf = $this->focus->customFieldTable[0];
		$tablename_cf_index = $this->focus->customFieldTable[1];
		$query = "select $link_tabname.$link_tabfieldname,$tablename.createdtime,$tablename.smcreatorid from $tablename 
		left join $tablename_cf on $tablename_cf.$tablename_cf_index = $tablename.$tableindex 
		where $tablename.$tableindex = ?";
        //$query .= " and $tablename.createdtime between '".$this->start_date."'and'".$this->end_date."'";
		$result = $adb->pquery($query,array($this->record));
                
		$smcreatorid = $adb->query_result($result,0,'smcreatorid');
		$createdtime = $adb->query_result($result,0,'createdtime');
		$date = date("Y-m-d",strtotime($createdtime));
		$this->setDatetimeArray($date);
		//$seconds  = $this->setDatetimeForSeconds($createdtime);
		$data = array(
			'title' => getFixedLabel('NEW') . getTransTab($this->module),
			'time' => date("H:i",strtotime($createdtime)),
			'link' => $adb->query_result($result,0,$link_tabfieldname),
			'datetime' => $createdtime,
		);
        return $data;
        
	}
    
	//分配负责人变更历史
	private function getSmowneridLog(){
		global $adb,$current_user;
		$languageType= getLanguageType($current_user);

		$query = "select ld_modtracker_basic.changedon,prevalue,postvalue,whodid,ld_tranlabel.fieldlabel from ld_modtracker_basic 
			LEFT JOIN ld_modtracker_detail on ld_modtracker_detail.id = ld_modtracker_basic.id
			LEFT JOIN ld_tab on ld_tab.`name` = ld_modtracker_basic.module
			INNER JOIN ld_field on ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ld_tab.tabid and ld_field.tabid = ?
			LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_field.fieldid 
			and ld_tranlabel.trantable = 'ld_field' and ld_tranlabel.languagetype = ?
			where (ld_modtracker_detail.fieldname = 'assigned_user_id' or ld_modtracker_detail.fieldname = 'servicecasher') and crmid = ? and prevalue <> '' ";

        if(empty($languageType))$languageType = 'zh';
		$result = $adb->pquery($query,array($this->tabid,$languageType,$this->record));
        $num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$whodid = $adb->query_result($result,$i,'whodid');
				$postvalue = $adb->query_result($result,$i,'postvalue');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				$datetime = $adb->query_result($result,$i,'changedon');
				$date = date("Y-m-d",strtotime($datetime));
				$this->setDatetimeArray($date);
				//$seconds  = $this->setDatetimeForSeconds($datetime);
				$this->data[$date][] = array(
					'title'=> getFixedLabel('ALLOCATE') .getFixedLabel('WORKORDER') . getFixedLabel('to1') .getUserFullName($postvalue),
					'lastname' => getUserFullName($whodid),
					'time' =>date("H:i",strtotime($datetime)),
					'datetime' => $datetime,
				);
			}
		}
	}

	//单据共享记录
	private function getModuleTabshareLog(){
		global $adb;
		$query = 'select viewuserid,Shareuserid,createdtime from ld_tabshare where crmid = ?';
        //$query .= " and createdtime between '".$this->start_date."'and'".$this->end_date."'";
		$result = $adb->pquery($query,array($this->record));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$viewuserid = $adb->query_result($result,$i,'viewuserid');
				$viewusername[] = getUserFullName($viewuserid);
				$shareuserid = $adb->query_result($result,$i,'shareuserid');
				$createdtime = $adb->query_result($result,$i,'createdtime');
				
			}
			$date = date("Y-m-d",strtotime($createdtime));
			$this->setDatetimeArray($date);
			//$seconds  = $this->setDatetimeForSeconds($createdtime);
			$this->data[$date][] = array(
				'title'=> getFixedLabel('SHARE') .getFixedLabel('to1') .implode('、',$viewusername),
				'lastname' => getUserFullName($shareuserid),
				'time' => date("H:i",strtotime($createdtime)),
				'datetime' => $createdtime,
			);
		}
	}
    
    //解决方案变更记录
    public function getWorkSheetSolution(){
        global $adb,$current_user;
		$languageType= getLanguageType($current_user);
        
        $query = "select ld_modtracker_basic.changedon,prevalue,postvalue,whodid,ld_tranlabel.fieldlabel from ld_modtracker_basic 
			LEFT JOIN ld_modtracker_detail on ld_modtracker_detail.id = ld_modtracker_basic.id
			LEFT JOIN ld_tab on ld_tab.`name` = ld_modtracker_basic.module
			INNER JOIN ld_field on ld_field.fieldname = ld_modtracker_detail.fieldname and ld_field.tabid = ld_tab.tabid and ld_field.tabid = ?
			LEFT JOIN ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_field.fieldid 
			and ld_tranlabel.trantable = 'ld_field' and ld_tranlabel.languagetype = ?
			where ld_modtracker_detail.fieldname = 'solution' and crmid = ? ";

        if(empty($languageType))$languageType = 'zh';
		$result = $adb->pquery($query,array($this->tabid,$languageType,$this->record));

        $num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			for($i = 0; $i < $num_rows; $i++){
				$whodid = $adb->query_result($result,$i,'whodid');
                $prevalue = $adb->query_result($result,$i,'prevalue');
				$postvalue = $adb->query_result($result,$i,'postvalue');
				$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
				$datetime = $adb->query_result($result,$i,'changedon');
				$date = date("Y-m-d",strtotime($datetime));
				$this->setDatetimeArray($date);
                if(empty($prevalue)){
                    $title = getFixedLabel('Generate') .getFixedLabel('SOLUTION').':';
                }else{
                    $title = getFixedLabel('UPDATES') .getFixedLabel('SOLUTION').':';
                }
				//$seconds  = $this->setDatetimeForSeconds($datetime);
				$this->data[$date][] = array(
					'title'=> $title,
					'lastname' => getUserFullName($whodid),
					'time' =>date("H:i",strtotime($datetime)),
                    'content'=>$postvalue,
					'datetime' => $datetime,
				);
			}
		}
    }
}

?>