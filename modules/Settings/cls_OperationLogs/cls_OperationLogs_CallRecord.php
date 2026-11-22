<?php

class cls_OperationLogs_CallRecord extends cls_OperationLogs
{
    public $selectcalltype;
    public $startdate;
    public $enddate;
    public $basicsearchoption;
    public $basicsearchvalue;
    // public $table_index_arr = [
    //     "Leads" => 'leadsid',
    //     "Accounts" => 'accountid',
    //     "Contacts" => 'contactid',
    //     "Potentials" => 'potentialid',
    //     "Vendors" => 'vendorid',
    //     "VendorContact" => 'vendorcontactid',
    // ];
    public $waveform_arr = [
        'themes/icon2024/callrecord-waveform1.png',
        'themes/icon2024/callrecord-waveform2.png',
        'themes/icon2024/callrecord-waveform3.png',
    ];
    public function __construct($selectmodule,$actiontype,$userids,$operationtime=''){
		parent::__construct($selectmodule,$actiontype,$userids,$operationtime);
	}

    //获取可选模块
    public function getselectModules()
    {
        global $adb;
        $sql = "SELECT tabid,name from ld_tab where isentitytype = 1 and presence in (0,2) and tabid not IN
                (SELECT tabid from ld_tab where name in ('CooperativeWork','WorkReportList','Webmails','Emails','ReportAnalysis','VisualAnalysis')) or name = 'Users' order by tabsequence";
        $result = $adb->query($sql);
        while($moduleinfo=$adb->fetch_array($result))
        {
            $modulelist[$moduleinfo['name']] = getTranstab($moduleinfo['name']);
        }
        $modulelist = [
            "Leads" => getTranstab("Leads"),
            "Accounts" => getTranstab("Accounts"),
            "Contacts" => getTranstab("Contacts"),
            "Potentials" => getTranstab("Potentials"),
            "Vendors" => getTranstab("Vendors"),
            "VendorContact" => getTranstab("VendorContact"),
        ];
        return $modulelist;
    }
    //获取表头
    public function getTableHeader()
    {
        $header = [
            '#',
            getFixedLabel('MODULE'),
            getFixedLabel('CallRecordDate'),
            getFixedLabel('Calltype'),
            getFixedLabel('Caller'),
            getFixedLabel('Listener'),
            getFixedLabel('CallRecording'),
        ];
        return $header;
    }
    //获取表头宽度
    public function getHeaderWidth()
    {
        $width = ["width:5%;text-align: left;","width:12%;","width:15%;","", "width:15%;", "width:15%;", "width:28%;"];
        return $width;
    }
    //获取通话类型
    public function getCallType()
    {
        $calltypes = [
            "All" => getFixedLabel('ALL'),
            '来电' => "来电",
            '去电' => "去电",
        ];
        return $calltypes;
    }
    //获取基础搜索选项
    public function getBasicSearchOptions()
    {
        $basicsearch_options = [
            "caller" => getFixedLabel('Caller'),
            'listener' => getFixedLabel('Listener'),
        ];
        return $basicsearch_options;
    }
    //获取查询sql
    public function getQuery(){

        $basicsearchvalue = $this->basicsearchvalue;
        // $table_index = $this->table_index_arr[$this->selectmodule];
        if($this->basicsearchvalue == ''){
            $sql = 'SELECT * FROM ' .$this->maintable;
            $sql .= $this->getWhere();
        }else{
            $focus = CRMEntity::getInstance($this->selectmodule);
            $tablename = $focus->table_name;
            $rtable_index = $focus->table_index;
            $entitynames = getEntitynameByModulename($this->selectmodule);
            $herf_columnname = $entitynames['fieldname'];
            
            if($this->basicsearchoption == 'caller'){
                $user_sql = "SELECT ld_callbutler.*,u.last_name as label,ld_callbutler.userid as `caller`,ld_callbutler.$rtable_index as `listener` 
                            FROM ld_callbutler INNER JOIN ld_users u ON u.id = ld_callbutler.userid 
                            where u.last_name like '%$basicsearchvalue%'";
                $module_sql = "SELECT ld_callbutler.*,t.$herf_columnname as label,ld_callbutler.$rtable_index as `caller`,ld_callbutler.userid as `listener`  
                            FROM ld_callbutler INNER JOIN $tablename t ON t.$rtable_index = ld_callbutler.$rtable_index 
                            where t.$herf_columnname like '%$basicsearchvalue%'";
                if($this->selectcalltype == '去电'){
                    $sql = $user_sql;
                    $sql .= $this->getWhere();
                }else if($this->selectcalltype == '来电'){
                    $sql = $module_sql;
                    $sql .= $this->getWhere();
                }else{
                    $sql = $user_sql;
                    $sql .= " AND calltype = '去电' ";
                    $sql .= $this->getWhere();
                    $sql .= " UNION ALL ";
                    $sql .= $module_sql;
                    $sql .= " AND calltype = '来电' ";
                    $sql .= $this->getWhere();
                }
                    
            }else if($this->basicsearchoption == 'listener'){
                $user_sql = "SELECT ld_callbutler.*,u.last_name as label,ld_callbutler.userid as `listener`,ld_callbutler.$rtable_index as `caller` 
                            FROM ld_callbutler INNER JOIN ld_users u ON u.id = ld_callbutler.userid 
                            where u.last_name like '%$basicsearchvalue%'";
                $module_sql = "SELECT ld_callbutler.*,t.$herf_columnname as label,ld_callbutler.$rtable_index as `listener`,ld_callbutler.userid as `caller`  
                            FROM ld_callbutler INNER JOIN $tablename t ON t.$rtable_index = ld_callbutler.$rtable_index 
                            where t.$herf_columnname like '%$basicsearchvalue%'";
                if($this->selectcalltype == '去电'){
                    $sql = $module_sql;
                    $sql .= $this->getWhere();
                }else if($this->selectcalltype == '来电'){
                    $sql = $user_sql;
                    $sql .= $this->getWhere();
                }else{
                    $sql = $module_sql;
                    $sql .= " AND calltype = '去电' ";
                    $sql .= $this->getWhere();
                    $sql .= " UNION ALL ";
                    $sql .= $user_sql;
                    $sql .= " AND calltype = '来电' ";
                    $sql .= $this->getWhere();
                }
            }
        }
        $sql .= ' ORDER BY begintime desc';
        return $sql;
    }
    //获取查询条件
    public function getWhere(){

        $tablename = $this->maintable;
        $focus = CRMEntity::getInstance($this->selectmodule);
        $table_index = $focus->table_index;
        // $table_index = $this->table_index_arr[$this->selectmodule];

        if($this->basicsearchvalue == '')
            $where = " WHERE";
        else
            $where = " AND";

        $where .= " $tablename.$table_index != 0 and $tablename.$table_index is not NULL";

        $where .= ' and begintime between "'.$this->startdate.'" and "'.$this->enddate.'"';

        if($this->selectcalltype != 'All'){
            $where .= ' and calltype = "'.$this->selectcalltype.'" ';
        }
        
        return $where;
    }
    //获取总条数
    public function getTotalRows(){
        global $adb;

        $sql .= $this->getQuery();
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
        return $num_rows;
    }
    public function getLogData($pagenum){
    	global $adb,$current_user;
        
        $sql .= $this->getQuery();
        $sql .= $this->setPageInfo($pagenum);
        $result = $adb->query($sql);
        $num_rows = $adb->num_rows($result);
    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $listdata[$i] = $this->getRowData($result,$i);
            }
    	}

        return $listdata;
    }
    public function getRowData($result,$i=0){
    	global $adb,$current_user;

        $listdata['num'] = $i+1;
        $module = $this->selectmodule;
        $listdata['module'] = getTranstab($module);
        $listdata['begintime'] = $adb->query_result($result, $i, "begintime");
        $calltype = $adb->query_result($result, $i, "calltype");
        $listdata['calltype'] = $calltype;
        
        $focus = CRMEntity::getInstance($module);
        $table_index = $focus->table_index;

        if($this->basicsearchvalue == ''){
            // $table_index = $this->table_index_arr[$this->selectmodule];
            $userid = $adb->query_result($result, $i, "userid");
            $crmid = $adb->query_result($result, $i, $table_index);

            if($calltype == '去电'){
                $listdata['caller'] = getUserFullName($userid);
                $listdata['listener'] = getModuleHref($module,$crmid);
            }else{
                $listdata['caller'] = getModuleHref($module,$crmid);
                $listdata['listener'] = getUserFullName($userid);
            }
        }else{
            $caller = $adb->query_result($result, $i, "caller");
            $listener = $adb->query_result($result, $i, "listener");
            if($calltype == '去电'){
                $listdata['caller'] = getUserFullName($caller);
                $listdata['listener'] = getModuleHref($module,$listener);
            }else{
                $listdata['caller'] = getModuleHref($module,$caller);
                $listdata['listener'] = getUserFullName($listener);
            }
        }
        
        $time = $adb->query_result($result, $i, "time");
        $filepath = $adb->query_result($result, $i, "soundrecordingfile");
        // $randomIndex = array_rand($this->waveform_arr);
        // $waveform = $this->waveform_arr[$randomIndex];
        // $listdata['soundrecording']['filepath'] = str_replace("\\", "/", $filepath);
        // $listdata['soundrecording']['talktime'] = $talk_timeFormatted;
        // $listdata['soundrecording']['waveform'] = $waveform;
        // dump($this->getRecordingFileHtml($filepath,$time));
        $listdata['soundrecordingfile'] = $this->getRecordingFileHtml($filepath,$time);
        return $listdata;
    }
    private function getRecordingFileHtml($filepath,$time){
        if(!empty($filepath)){
            $filepath = str_replace("\\", "/", $filepath);
            // 通话时长格式转换
            $talk_minutes = floor($time / 60);
            $talk_seconds = $time % 60;
            $talk_timeFormatted = sprintf("%02d:%02d", $talk_minutes, $talk_seconds);
            // 随机波形图
            $randomIndex = array_rand($this->waveform_arr);
            $waveform = $this->waveform_arr[$randomIndex];
            $filehtml = '<div class="callrecord-player_box">
                            <div class="callrecord-player_waveform" style="background: url('.$waveform.') 0px 0 no-repeat;"></div>
                            <div class="callrecord-player_time">'.$talk_timeFormatted.'</div>
                            <div class="callrecord-player_play tip-items-list" onclick="CallRecordSetting.getInstance().playClick(this,\''.$filepath.'\')" data-tip="'.getFixedLabel('PLAYER').'" data-direction="top" data-type="position"></div>
                            <a class="callrecord-player_download tip-items-list" href ="'.$filepath.'" download="" target = "_blank" data-tip="'.getFixedLabel('DOWNLOAD').'" data-direction="top" data-type="position"></a>
                        </div>';
        }else{
            $filehtml = '<div class="callrecord-player_box">
                            <div class="callrecord-player_waveform empty"></div>
                            <div class="callrecord-player_time">00:00</div>
                            <div class="callrecord-player_play empty tip-items-list" data-tip="录音为空" data-direction="top" data-type="position"></div>
                            <a class="callrecord-player_download empty tip-items-list" download="" target = "_blank" data-tip="录音为空" data-direction="top" data-type="position"></a>
                        </div>';
        }
        return $filehtml;
    }
}

?>