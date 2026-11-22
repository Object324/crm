<?php
/* creator:gyq_13 */
class TemplateCalendar{

    private $record;                            //模板id
    private $billsrecord;                       //单据id
    public $blockid;                           //模板所选模块id
    private $module;                            //模板列表当前所选模块名
    private $templatename;                      //模板名
    private $mode;                                 //模式
    public $detailinfo;                         //模板详情
    private $setting_module = 'Calendar';
    public $detailheader = 'subject,activitytype,date_start,due_date,assigned_user_id,description';
    public $detailheader_multiarr = array();    //模板明细列头头信息详情
    public $urldate;                           //当前单据字段信息
    public $allocatetype;
    public function __construct(){
        $this->record = $_REQUEST['record'];
        $this->blockid = $_REQUEST['blockid'];
        $this->templatename = $_REQUEST['templatename'];
        $this->mode = $_REQUEST['mode'];
        $this->allocatetype= $_REQUEST['radiotype'];
        include globalStatic::$root_directory.'user_privileges/templateCalendarShowColumns.php';
        if(!empty($templateCalendarShowColumns)){
            $this->detailheader = $templateCalendarShowColumns;
        }
        if(!empty($_REQUEST['blockid'])){
            $this->module = getTabname($this->blockid);
        }
        
    }
    /* 获取模板列表 A1 */
    public function getListview($tabid){
        global $adb;
        $query="select * from ld_template_calendar where tabid=? ORDER BY sequence,templateid DESC";
        $result=$adb->pquery($query,array($tabid));
        $num_rows=$adb->num_rows($result);
        $templateList=array();
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $allocatetype=$adb->query_result($result,$i,'allocatetype');
                $allocatetypeInfo=$this->getAllocateUser($adb->query_result($result,$i,'templateid'),$allocatetype);

                $templateList[$adb->query_result($result,$i,'templateid')]=array(
                    'templateid'=>$adb->query_result($result,$i,'templateid'),
                    'tabid'=>$adb->query_result($result,$i,'tabid'),
                    'templatename'=>$adb->query_result($result,$i,'templatename'),
                    'status'=>$adb->query_result($result,$i,'status'),
                    'description'=>$adb->query_result($result,$i,'description'),
                    'allocatetypeidLink' =>$allocatetypeInfo[0]['allocatetypeidLink'],
                    'allocatetypenameLink' =>$allocatetypeInfo[0]['allocatetypenameLink'],
                    'allocatetype'=>$adb->query_result($result,$i,'allocatetype'),
                    'autoexec'=>$adb->query_result($result,$i,'autoexec')
                );
            }

        }

        return $templateList;
    }
    /* 获取分配人 A2*/
    public function getAllocateUser($approceid,$approveallocatetype)
    {
        global $adb;
        if($approveallocatetype==0)
        {

            $allocatename = getFixedLabel('ALLTHEUSERS');
            $allocatetypeInfo[]=array
            (
                'allocatetypeidLink'=>'-1',
                'allocatetypenameLink'=>$allocatename
            );
            return $allocatetypeInfo;
        }
        if($approveallocatetype==1)//部门
        {
            $query1 = "SELECT allocateid,allocatename,templateid FROM(

                    	SELECT
                    		 ld_groups.groupid    as allocateid,
                    		 ld_groups.groupname AS allocatename,
                    		 q2.templateid AS templateid
                    	FROM
                    		ld_template_calendar_user q1
                    	INNER JOIN ld_template_calendar q2 ON q2.`templateid`=q1.templateid
                    	INNER JOIN ld_groups  ON ld_groups.groupid = q1.`userid`
                    	WHERE q2.allocatetype=1

                    )AS alldata
                    WHERE alldata.templateid=? order by templateid desc;";
        }
        else if($approveallocatetype==2)
        {
            $query1 = "SELECT allocateid,allocatename,templateid FROM (

                    	SELECT
                    		 ld_users.id as allocateid,
                    		 ld_users.`last_name` AS allocatename ,
                    		 ld_template_calendar_user.templateid
                    	FROM
                    		ld_template_calendar_user
                    	INNER JOIN ld_template_calendar ON ld_template_calendar.`templateid`=ld_template_calendar_user.templateid
                    	INNER JOIN ld_users ON ld_users.`id` = ld_template_calendar_user.`userid`
                    	WHERE ld_template_calendar.allocatetype=2
                    )AS alldata
                    WHERE alldata.templateid=? order by templateid desc;";
        }
		else if($approveallocatetype==3)
        {
            $query1 = "SELECT allocateid,allocatename,templateid FROM (
						SELECT
							 ld_profile.profileid as allocateid,
							 ld_profile.profilename AS allocatename ,
							 ld_template_calendar_user.templateid
						FROM
							ld_template_calendar_user
						INNER JOIN ld_template_calendar ON ld_template_calendar.`templateid`=ld_template_calendar_user.templateid
						INNER JOIN ld_profile ON ld_profile.profileid = ld_template_calendar_user.`userid`
						WHERE ld_template_calendar.allocatetype=3
					)AS alldata
					WHERE alldata.templateid=? order by templateid desc;";
        }
        $result1=$adb->pquery($query1,array($approceid));
        $num_rows1=$adb->num_rows($result1);
        if($num_rows1 > 0){
            $userLink = '';
            for($i=0;$i<$num_rows1;$i++){
                $allocateid = $adb->query_result($result1,$i,'allocateid');
                $allocatename = $adb->query_result($result1,$i,'allocatename');
                if($allocatename=='AllUser')//所有用户。
                {
                    $allocatename = getFixedLabel('ALLTHEUSERS');
                }
                $allocatetypeidLink .= $allocateid.',';
                $allocatetypenameLink .= $allocatename.',';
            }
            $allocatetypeidLink = trim($allocatetypeidLink,',');
            $allocatetypenameLink = trim($allocatetypenameLink,',');
            $allocatetypeInfo[]=array
            (
                'allocatetypeidLink'=>$allocatetypeidLink,
                'allocatetypenameLink'=>$allocatetypenameLink
            );
        }

        return  $allocatetypeInfo;
    }
    /*获取所有可创建日程的模块 A1_1*/
    public function getAvailableModule(){
        global $current_user,$adb;
        require('user_privileges/user_language_'.$current_user->id.'.php');
        //根据是否可以关联创建日程获取下拉框可选模块
        //非管理员 有后台设置 权限
        if(vtlib_isModuleActive('Calendar'))
        {
            
        
            $sql = "SELECT
					NAME,
					tablabel,
					Q1.tabid,
					ld_tranlabel.fieldlabel
				FROM
					ld_tab Q1
				INNER JOIN ld_tranlabel ON Q1.tabid = ld_tranlabel.relateid
				INNER JOIN (
					select ld_relatedlists.tabid from ld_relatedlists
					INNER JOIN ld_tab on ld_tab.tabid = ld_relatedlists.tabid
					where ld_relatedlists.name= 'get_schedule' and ld_tab.presence <> 1
				) Q4 ON Q4.tabid = Q1.tabid
				WHERE
					languagetype = ?
				AND trantable = ?
				ORDER BY
					tabsequence;";
            $result=$adb->pquery($sql,array($languageType,'ld_tab'));
            $printtabs=array();
            for($i=0;$i<$adb->num_rows($result);$i++)
            {
                $tablabel=$adb->query_result($result,$i,'tablabel');
                $name=$adb->query_result($result,$i,'name');
                $printtabid=$adb->query_result($result,$i,'tabid');
                if($printtabid==9)
                {
                    $printtabid=16;
                }
                $printtabs[$printtabid]=array(
                    'tabid'=>$printtabid,
                    'tabname'=>$adb->query_result($result,$i,'fieldlabel')
                );
            }

        }
        return $printtabs;
    }
    /* 获取当前日程模板基础信息 B1*/
    public function getTemplateBaseInfo(){
        global $adb;
        $record=$this->record;
        $query="select * from ld_template_calendar where templateid=?";
        $result=$adb->pquery($query,array($record));
        $num_rows=$adb->num_rows($result);
        $template=array();
        if($num_rows > 0) {
            $i = 0;
            $detailinfo = array('templateid' => $adb->query_result($result, $i, 'templateid'),
                'tabid' => $adb->query_result($result, $i, 'tabid'),
                'templatename' => $adb->query_result($result, $i, 'templatename'),
                'status' => $adb->query_result($result, $i, 'status'),
                'description' => $adb->query_result($result, $i, 'description'),
                'allocatetype' => $adb->query_result($result, $i, 'allocatetype'),
                'judgeinfo' => $adb->query_result($result, $i, 'judgeinfo'),
                'judgeinfo_groups' => $adb->query_result($result, $i, 'judgeinfo_groups'),
                'calendardetail' => $adb->query_result($result, $i, 'calendardetail'),
                'autoexec' => $adb->query_result($result, $i, 'autoexec')
            );
            $this->detailinfo = $detailinfo;
            $template[] = $detailinfo;
        }else{
            /*reason:新建审批流程，初始化值,-5仅表示新建时各值为空*/
            $template[0]['tabid'] = '-5';
            $template[0]['templateid'] = '-5';
            $template[0]['allocatetype'] = '0';
        }
        return $template;

    }

    /* 获取分配信息 B1_1*/
    public function getAllocateInfo(){
        global $adb;
        if (empty($this->record)) {
            return '';
        }
        $query = 'SELECT
  alldata3.allocateid	,alldata3.allocatename
FROM
	(
		SELECT
			- 1 AS allocateid,
			"AllUser" AS allocatename
		FROM
			ld_template_calendar_user
		INNER JOIN ld_template_calendar ON ld_template_calendar.templateid = ld_template_calendar_user.templateid

		WHERE
			ld_template_calendar.allocatetype = 0
	    AND  ld_template_calendar.templateid = ?
		UNION
		SELECT
			ld_users.id AS allocateid,
			ld_users.`last_name` AS allocatename
		FROM
			ld_template_calendar_user
		INNER JOIN ld_template_calendar ON ld_template_calendar.templateid = ld_template_calendar_user.templateid
		INNER JOIN ld_users ON ld_users.`id` = ld_template_calendar_user.`userid`
		WHERE
			ld_template_calendar.allocatetype = 2
	    AND  ld_template_calendar.templateid = ?
		UNION
		SELECT
			ld_profile.profileid AS allocateid,
			ld_profile.profilename AS allocatename
		FROM
			ld_template_calendar_user
		INNER JOIN ld_template_calendar ON ld_template_calendar.templateid = ld_template_calendar_user.templateid
		INNER JOIN ld_profile ON ld_profile.profileid = ld_template_calendar_user.`userid`
		WHERE
			ld_template_calendar.allocatetype = 3
			AND  ld_template_calendar.templateid = ?
		UNION
		SELECT
			ld_groups.groupid AS allocateid,
			ld_groups.groupname AS allocatename
		FROM
			ld_template_calendar_user
		INNER JOIN ld_template_calendar ON ld_template_calendar.templateid = ld_template_calendar_user.templateid
		INNER JOIN ld_groups ON ld_groups.groupid = ld_template_calendar_user.`userid`
		WHERE
			ld_template_calendar.allocatetype = 1
		AND ld_template_calendar.templateid = ?
	) AS alldata3;';
        $result=$adb->pquery($query,array($this->record,$this->record,$this->record,$this->record));
        $num_rows=$adb->num_rows($result);
        $userLink='';
        if($num_rows > 0){
            for($i=0;$i<$num_rows;$i++){
                $userid = $adb->query_result($result,$i,'allocateid');
                $allocatename = $adb->query_result($result,$i,'allocatename');
                if($allocatename=='AllUser')//所有用户。
                {
                    $allocatename = getFixedLabel('ALLTHEUSERS');
                    $userLink .= $allocatename.'、' ;
                }
                else{
                    $userLink.= $allocatename.'、';
                }
            }
            $userLink = trim($userLink,'、');
        }
        return $userLink;
    }

    /* 获取当前模板分配对象 B1_2 */
    public function getAllocateUsers(){
        global $adb;
        $record=$this->record;
        $query="select * from ld_template_calendar_user where templateid=?";
        $result=$adb->pquery($query,array($record));
        $num_rows=$adb->num_rows($result);
        $userlist='';
        if($num_rows){
            for($i=0;$i<$num_rows;$i++){
                $userId=$adb->query_result($result,$i,'userid');
                $userlist .= $userId.',';
            }
            $userlist = rtrim($userlist,',');
        }else{
            $userlist = '-1';
        }
        return $userlist;
    }

    /* 模板保存 B3*/
    public function saveTemplateBaseInfo(){
        global $adb,$current_user;;
        
        $_REQUEST['autoexec'] = isset($_REQUEST['autoexec'])?1:0;
        $_REQUEST['status'] = isset($_REQUEST['status'])?'open':'close';
        
        if($this->mode=='edit'){
            $query="update ld_template_calendar set templatename=?,description=?,status=?,allocatetype=?,judgeinfo=?,judgeinfo_groups=?,calendardetail=?,autoexec=? where templateid=?";
            $adb->pquery($query,array($this->templatename,$_REQUEST['base_description'],$_REQUEST['status'],$_REQUEST['radiotype'],
                $_REQUEST['template_judgeinfo'],$_REQUEST['template_judgeinfo_groups'],$_REQUEST['template_calendardetail'],$_REQUEST['autoexec'],$this->record));
        }
        else{
            $templateid=$adb->getUniqueID('ld_template_calendar');
            $query="insert into ld_template_calendar(templateid,tabid,templatename,description,status,allocatetype,judgeinfo,judgeinfo_groups,calendardetail,autoexec)";
            $query .="value(?,?,?,?,?,?,?,?,?,?)";

            $adb->pquery($query,array($templateid,$this->blockid,$this->templatename,$_REQUEST['base_description'],$_REQUEST['status'],$_REQUEST['radiotype'],
                $_REQUEST['template_judgeinfo'],$_REQUEST['template_judgeinfo_groups'],$_REQUEST['template_calendardetail'],$_REQUEST['autoexec']));
            $this->record=$templateid;
        }
    }
    /* 分配保存 B3_1 explain: $_REQUEST['selectallocateid'] => 选中的具体内容,$_REQUEST['radiotype']=>单选框选中的类型*/
    public function saveTemplateAllocateUser(){

        global $adb;
        $updatesql = "update ld_template_calendar SET allocatetype=? where templateid=?";
        $adb->pquery($updatesql, array($_REQUEST['radiotype'], $this->record));

        if($_REQUEST['radiotype']=='0'){
            if($this->mode=='edit'){
                $query="delete from ld_template_calendar_user where templateid=?";
                $adb->pquery($query,array($this->record));
            }
            $sql='insert into ld_template_calendar_user(templateid,userid)values(?,?)';
            $adb->pquery($sql,array($this->record,'-1'));

        }elseif($_REQUEST['radiotype']=='1'||$_REQUEST['radiotype']=='2'||$_REQUEST['radiotype']=='3'){
            if($this->mode=='edit'){
                $query="delete from ld_template_calendar_user where templateid=?";
                $adb->pquery($query,array($this->record));

            }
            $owners = explode(",",$_REQUEST['selectallocateid']);
            foreach($owners as $key=>$arr){
                $sql="insert into ld_template_calendar_user(templateid,userid) values(?,?)";
                $adb->pquery($sql,array($this->record,$arr));
            }
        }
    }
    /* 获取条件判断选中模块对应字段 B4 */
    public function getMoudleFieldNames(){
        global $adb,$current_user,$oCustomView;
        $fieldnames = '';
        if(!empty($this->blockid)){
            require_once(globalStatic::$root_directory.'modules/CustomView/CustomView_Columnlist.php');
            $oCustomView = CustomView::getInstance($this->module);
            $modulecollist = $oCustomView->getModuleColumnsList($this->module);
            CustomView_Columnlist::$sti_module = $this->setting_module;
            $modulecolumnshtml = CustomView_Columnlist::getByModule_ColumnsHTML($this->module,$modulecollist);
        }

        return $modulecolumnshtml;
    }

    /* 获取条件判断详情  B4_1*/
    public function getAdvancedSearchCriteriaList($advft_criteria,$advft_criteria_groups){
        $advft_criteria_arr = Zend_Json::decode($advft_criteria);
        $advft_criteria_groups_arr = Zend_Json::decode($advft_criteria_groups);

        $advft_criteria_real = array();
        $advft_criteria_groups_real = array();
        $i = 0;
        $k = 0;
        foreach($advft_criteria_arr as $key => $val){
            if(!empty($val)){
                $gval = $val['groupid'];
                if($gval > $k){
                    $val['groupid'] = $k+1;
                    $advft_criteria_real[$i] = $val;
                }elseif($gval == $k){
                    $advft_criteria_real[$i] = $advft_criteria_real[$i-1];
                }
                $k = $gval;
                $i++;
            }
        }
        //0023955: 控制面板>日程模板 选择模板：联系人 点击【新增】按钮，条件判断录入保存后，录入的信息和保存后的信息不同
        $advft_criteria_real = $advft_criteria_arr;
        foreach($advft_criteria_groups_arr as $key => $val){
            if(is_array($val)|| $key==0){
                $advft_criteria_groups_real[] = $val;
            }
        }
        $advfilterlist = getAdvancedSearchCriteriaList($advft_criteria_real,$advft_criteria_groups_real,$this->module,null);

        return $advfilterlist;
    }
    /* 获取条件判断大于小于等 B4_2*/
    public function getAdvCriteriaHTML($selected = ""){
        global $adv_filter_options;
        $shtml = '';
        foreach($adv_filter_options as $key=>$value)
        {

            if($selected == $key)
            {
                $shtml .= "<option selected value=\"".$key."\">".$value."</option>";
            }else
            {
                $shtml .= "<option value=\"".$key."\">".$value."</option>";
            }
        }
        return $shtml;
    }
    /* 删除模板 A2_1*/
    public function deleteTemplate(){
        global $adb;
        $query="delete from ld_template_calendar where templateid=?";
        $adb->pquery($query,array($this->record));
       $query="delete from ld_template_calendar_user where templateid=?";
        $adb->pquery($query,array($this->record));
      //  header("Location: index.php?module=Calendar&parenttab=Calendar&action=CalendarTemplate&template_showtype=listview");
    }
    /* 获取模板明细 C1*/
    public function getCalendarDetailContent($multi_templates_details,$rownumber_ajax){

        global $adb;
        $detailheader_multiarr = array();
        $calendardetail_arr = array();
        $calendardetail_content_inline = array();
        $calendardetail_content_header = array();
        if(!empty($multi_templates_details)){
            $calendardetail_arr = $multi_templates_details;
        }else{
            $detailinfo = $this->detailinfo;
            $calendardetail = $detailinfo['calendardetail'];
            if(!empty($calendardetail)){
                $calendardetail_arr = Zend_Json::decode($calendardetail);
            }else{
                $header_arr = explode(',',$this->detailheader);
                foreach($header_arr as $key=>$val){
                    $calendardetail_arr[0][$val] = '';
                }
                $this->mode = 'create';
            }
        }

        $focus = CRMEntity::getInstance($this->setting_module);
        $fieldobj=Field::getInstance($this->setting_module,$adb);

        $cachemoduleblock=$fieldobj->getBlockInfos();
        foreach($cachemoduleblock as $key_blockid=>$moduleblockinfo){
            $block_label[$key_blockid] =$moduleblockinfo['blocklabel'];
        }
        crm_load_function_file("getBlockInformation","include/utils",'EditViewUtils');
        $calendardetail_content = getBlockInformation($this->setting_module, '', $focus->column_fields, 9, $block_label, 'create');

        $header_config = ','.$this->detailheader;
        $header_config_arr = explode(',',$this->detailheader);
        foreach($calendardetail_arr as $rowkey => $rowvalue) {
            foreach ($calendardetail_content as $key => $value) {
                foreach ($value as $key1 => $val) {
                    foreach ($val as $key2 => $val2) {

                        $key_con = array_search($val2[2][0],$header_config_arr);
                        if (is_bool($key_con)) {
                            unset($calendardetail_content[$key1][$key2]);
                        } else {
                            $columnheader = $val2[2][0];

                            $val2[2][1] =  $columnheader;
                            $uitype = $val2[0][0][0];
                            if($uitype == 53 || $uitype==153){

                                if($this->mode != 'create'){

                                    foreach($val2[3][0] as $key3=>$val3){
                                        if($key3 == $rowvalue[$val2[2][0]]){
                                            foreach($val3 as $key4=>$val4){
                                                $val2[3][0][$key3][$key4] = 'selected';
                                            }
                                        }else{
                                            foreach($val3 as $key4=>$val4){
                                                $val2[3][0][$key3][$key4] = '';
                                            }
                                        }
                                    }
                                }

                                if(!empty($rownumber_ajax)){
                                    $val2[2][0] = $val2[2][0].'_'.$rownumber_ajax;
                                }else{
                                    $val2[2][0] = $val2[2][0].'_'.$rowkey;
                                }
                            }elseif($val2[2][0] == 'activitytype'){
                                if($this->mode != 'create') {
                                    foreach ($val2[3][0] as $key3 => $val3) {
                                        if ($val3[0] == $rowvalue[$val2[2][0]]) {
                                            $val2[3][0][$key3][2] = 'selected';
                                        } else {
                                            foreach ($val3 as $key4 => $val4) {
                                                $val2[3][0][$key3][2] = '';
                                            }
                                        }
                                    }
                                }
                                if(!empty($rownumber_ajax)){
                                    $val2[2][0] = $val2[2][0].'_'.$rownumber_ajax;
                                }else{
                                    $val2[2][0] = $val2[2][0].'_'.$rowkey;
                                }
                            }else{
                                $val2[3][0] = $rowvalue[$val2[2][0]];
                                if($val2[2][0] == 'date_start'){
                                    $val2[1][0] = getFixedLabel('STARTDATE');
                                }elseif($val2[2][0] == 'due_date'){
                                    $val2[1][0] = getFixedLabel('ENDDATE');
                                }
                            }
                            $detailheader_multiarr[$rowkey][$key_con]['fldname'] =  $columnheader;
                            $detailheader_multiarr[$rowkey][$key_con]['uitype'] =  $val2[0][0][0];
                            $detailheader_multiarr[$rowkey][$key_con]['typeofdata'] =  $val2[4];
                            $detailheader_multiarr[$rowkey][$key_con]['fldlabel'] =  $val2[1][0];
                            $calendardetail_content_inline[$rowkey]['基本信息'][0][$key_con] = $val2;
                        }
                    }
                }
            }
            ksort($calendardetail_content_inline[$rowkey]['基本信息'][0]);
        }
        ksort($detailheader_multiarr[0]);
        $this->detailheader_multiarr = $detailheader_multiarr[0];

        return $calendardetail_content_inline;

    }

    /* 获取模板明细列头 C1_1 */
    public function getCalendarDetailContent_header(){
        $header_str = '';
        // dump($this->detailheader_multiarr);
        foreach($this->detailheader_multiarr as $key=>$val){
            if($val['typeofdata'] == 'M'){
                $red = '*';
            }else{
                $red = '';
            }
            if($val['fldname'] == 'assigned_user_id'){
                $width = '150';
            }
            $header_str .= '<th width='.$width.'><font color="red">'.$red.'</font>'.$val['fldlabel'].'</th>';
        }
        $header_str.='<th style=" text-align:center">'.getFixedLabel('OPERATING').'</th>';
        return $header_str;
    }
    public function getUrl($str){
        $data = array();
        $date_arr = explode('?',$str);
        $date_arr_2 = end($date_arr);
        $parameter = explode('&',$date_arr_2);
        foreach($parameter as $val){
            $tmp = explode('=',$val);
            $data[$tmp[0]] = $tmp[1];
        }
        return $data;
    }
    /* 关联创建日程 G1 */
    public function createCalendars(){

        $urldata = $this->getUrl($_REQUEST['quicktag']);
        $this->urldate = $urldata;
        $this->sequence = 0;
        $this->module = $urldata['frommodule'];
        $this->blockid = getTabid($this->module);
        if(!empty($urldata['parent_id'])){
            $this->billsrecord = $urldata['parent_id'];
        }else{
            $this->billsrecord = $urldata['fromid'];
        }
        $lists = $this->getListview($this->blockid);
        require_once(globalStatic::$root_directory.'modules/Calendar/Activity.php');
        require_once(globalStatic::$root_directory.'modules/Calendar/CalendarCommon.php');
        include (globalStatic::$root_directory."include/Calendar/Mass_New_Calendar_View.php");
        include (globalStatic::$root_directory."include/Calendar/Mass_New_Calendar_Generator.php");


        global $adb;
        $templateidArr = $this->createCalendar_CheckAllocatetype();

        $templateids = '';
        $multi_templates_details = array();

        if(!empty($templateidArr)) {
            foreach ($templateidArr as $val) {
                if ($this->createCalendar_CheckJudgeInfo($val)) {
                    //自动执行创建日程管理时，判断“自动执行”是否开启。
                    if(!isset($urldata['autoexec']) || $lists[$val]['autoexec']){

                         $templateids .= $val.',';
                    }
                }
            }
            if(strlen($templateids) > 1) {
                $templateids = rtrim($templateids, ',');
                $query = "select allocatetype,calendardetail,judgeinfo from ld_template_calendar WHERE templateid in($templateids) ORDER BY sequence,templateid DESC ";
                $result = $adb->query($query);
                $num_rows = $adb->num_rows($result);
                if ($num_rows) {
                    for ($i = 0; $i < $num_rows; $i++) {
                        $calendardetail = Zend_Json::decode($adb->query_result($result, $i, 'calendardetail'));
                        $judgeinfo = Zend_Json::decode($adb->query_result($result, $i, 'judgeinfo'));
                        //小编辑 自动执行创建日程管理时，判断编辑的字段是否在日程模板判断条件中。
                        if(isset($urldata['fldName']) && $urldata['fldName']!=''){
                            foreach($judgeinfo as $val){
                                $val_array = explode(':',$val['columnname']);
                                $fld_array[] = $val_array[1];
                            }
                            if(!in_array($urldata['fldName'],$fld_array)) return false;
                        }
                                                
                        foreach($calendardetail as $rowkey => $rowvalue) {
                            foreach($rowvalue as $key => $val){
                                if($key=='date_start' || $key=='due_date'){
                                    $origndate = date("Y-m-d H:i:s",time()+24*60*60*$val);
                                    $date = new DateTimeField($origndate);
                                    $rowvalue[$key] = array($date->getDBInsertDateTimeValue()=>'');
                                }
                            }

                            $multi_templates_details[] = $rowvalue;
                        }
                    }
                    $multi_templates_details_export = $this->getCalendarDetailContent($multi_templates_details,null);
                }
                return $multi_templates_details_export;
            }
        }
    }
    /* 批量保存关联创建的日程 G1_5 */
    public function saveRelatedTemplates(){
        require_once(globalStatic::$root_directory.'modules/Calendar/Activity.php');
        require_once(globalStatic::$root_directory.'modules/Calendar/CalendarCommon.php');
        require_once(globalStatic::$root_directory.'modules/Reminds/Reminds.php');

        $urldate = $_REQUEST['currenturldate'];
        $urldate_arr = Zend_Json::decode($urldate);
        $multi_details = json_decode($_REQUEST['multi_details'],true);
        foreach($multi_details as $val){
            $this->createCalendarDetails($val,$urldate_arr);
        }
    }

    /* 创建日程明细 G1_1 */
    public function createCalendarDetails($calendardetail,$urldate_arr){
        global $adb;
        $focus = new Activity();
        $this->module = $urldate_arr['frommodule'];
        $tabId = getTabid($this->module);
        if($this->module=='Accounts' || $this->module=='ServiceCharge')
        {
            $urldate_arr['account_id']=$urldate_arr['fromid'];
        }
        else if($this->module=='Contacts')
        {
            $urldate_arr['contact_id']=$urldate_arr['fromid'];
        }else if($this->module=='Potentials')
        {
            $urldate_arr['potential_id']=$urldate_arr['fromid'];
        }
        foreach($focus->column_fields as $fieldname => $val)
        {
            //bug:23973 edit:cyb date:2016-08-12联系人查看界面>关联创建日程管理，保存后的日程管理单据中【联系人姓名】字段为空的
            if($fieldname=='contact_id'){
                $focus->column_fields[$fieldname] = $urldate_arr['contact_id']; 
            }else{
               $focus->column_fields[$fieldname] = $urldate_arr[$fieldname]; 
             }
            $fieldInfo = $this->getFieldRelatedInfo($tabId, $fieldname);
            $uitype = $fieldInfo['uitype'];
            $typeofdata = $fieldInfo['typeofdata'];
            if(isset($calendardetail[$fieldname]))
            {
                if(is_array($calendardetail[$fieldname]))
                    $value = $calendardetail[$fieldname];
                else
                    $value = trim($calendardetail[$fieldname]);
                if((($typeofdata == 'T~M') || ($typeofdata == 'T~O')) && ($uitype == 2 || $uitype == 70 )) {
                    /*if(!in_array($fieldname, $timeFields)) {
                        $date = DateTimeField::convertToDBTimeZone($value);
                        $value = $date->format('H:i');
                    }*/
                    $focus->column_fields[$fieldname] = $value;
                }else{
                    $focus->column_fields[$fieldname] = $value;
                }
                if(($fieldname == 'notime') && ($focus->column_fields[$fieldname]))
                {
                    $focus->column_fields['duration_hours'] = '';
                    $focus->column_fields['duration_minutes'] = '';
                }
                if(($fieldname == 'recurringtype') && ! isset($calendardetail['recurringcheck']))
                    $focus->column_fields['recurringtype'] = '--None--';
            }
        }
        if(isset($calendardetail['visibility']) && $calendardetail['visibility']!= '')
            $focus->column_fields['visibility'] = $calendardetail['visibility'];
        else
            $focus->column_fields['visibility'] = '私有';
        if(isset($calendardetail['eventstatus']) && $calendardetail['eventstatus']!= '')
            $focus->column_fields['eventstatus'] = $calendardetail['eventstatus'];
        else
            $focus->column_fields['eventstatus'] = '计划中';
        if($_REQUEST['assigntype'] == 'U') {
            $focus->column_fields['assigned_user_id'] = $calendardetail['assigned_user_id'];
        }
        
                
        $focus->save($this->setting_module);
        
        if(isset($urldate_arr['product_id'])){
            $sql = "update ld_activity set product_id =? where activityid = ?";
            $adb->pquery($sql,array($urldate_arr['product_id'],$focus->id));
        }
        
        $focus_rel = new Reminds();//添加提醒
        $focus_rel->saveRemindsInfo($this->setting_module,$focus->id);

    }

    /* 条件判断  G1_3 */
    public function createCalendar_CheckJudgeInfo($templateid)
    {
        global $current_user,$adb;
        $focus=CRMEntity::getInstance($this->module);

        $productdetail_obj=new Mass_New_Calendar_View($this->module,$templateid);
        $querygenerator=new Mass_New_Calendar_Generator($this->module,$current_user,$productdetail_obj,$productdetail_obj);
        $querygenerator->initForCustomViewById(1);
        $page_list_query = $querygenerator->getQuery('',1);
        $list_query= $querygenerator->getQuery('',2);
        $table_index = $focus->table_name.'.'.$focus->table_index;
        $page_list_query .= ' AND '.$table_index.' ='.$this->billsrecord;


        $result=$adb->pquery($page_list_query);
        $num_rows=$adb->num_rows($result);

        if($num_rows > 0){
            return true;
        }
    }
    /* 分配信息 G1_4 */
    public function createCalendar_CheckAllocatetype(){

        /**
         * parameter：approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配。
         */
        $tabid = $this->blockid;
        global $adb,$current_user;
        $checksql='SELECT groupid FROM ld_users2group  WHERE userid=?';
        $checkresult=$adb->pquery($checksql,array($current_user->id));
        $groupid=array();
        for($i=0;$i<$adb->num_rows($checkresult);$i++)
        {
            $groupid[]=$adb->query_result($checkresult,$i,'groupid');
        }
        if($tabid == 16) $tabid= 9;
        $groupids=implode(",",$groupid); //求出当前用户所在的部门ID。

        $sql ="SELECT  distinct templateid,`templatename`
        FROM
        (
        select
            ld_template_calendar.tabid,
            ld_template_calendar.templateid,
            ld_template_calendar.`templatename`
        from ld_template_calendar where allocatetype=0 AND ld_template_calendar.status='open'

        UNION
        select
          ld_template_calendar.tabid,
          ld_template_calendar.templateid,
          ld_template_calendar.`templatename`
        from ld_template_calendar_user
        inner JOIN ld_users on ld_users.id=ld_template_calendar_user.userid

        inner JOIN ld_template_calendar
            on ld_template_calendar.templateid=ld_template_calendar_user.templateid
        where allocatetype=2  and ld_template_calendar_user.userid=$current_user->id AND ld_template_calendar.status='open'
        GROUP BY  ld_template_calendar_user.templateid 
		UNION
		select
			ld_template_calendar.tabid,
			ld_template_calendar.templateid,
			ld_template_calendar.`templatename`
		from ld_template_calendar_user
		inner JOIN ld_profile on ld_profile.profileid=ld_template_calendar_user.userid
		inner JOIN ld_template_calendar
				on ld_template_calendar.templateid=ld_template_calendar_user.templateid
		where allocatetype=3  and ld_template_calendar_user.userid=$current_user->profileid AND ld_template_calendar.status='open'
		GROUP BY  ld_template_calendar_user.templateid 
		";
        if(sizeof($groupid)>0)
        {
            $sql.="UNION
                   select
                      ld_template_calendar.tabid,
                      ld_template_calendar.templateid,
                        ld_template_calendar.`templatename`
                   from ld_template_calendar_user
                   inner JOIN ld_groups on ld_groups.groupid=ld_template_calendar_user.userid inner JOIN ld_template_calendar
                   on ld_template_calendar.templateid=ld_template_calendar_user.templateid
                   where allocatetype=1 and ld_groups.groupid in($groupids)  AND ld_template_calendar.status='open'
                   GROUP BY  ld_template_calendar_user.templateid
                )  AS alldata where tabid=?
                order by alldata.templateid desc ";
        }
        else
        {
            $sql.=" ) as alldata  where tabid=? order by  alldata.templateid desc  ";
        }
        $result=$adb->pquery($sql,array($tabid));
        $num_rows = $adb->num_rows($result);
        $templateids = array();
        $approve=array();
        if($num_rows > 0){
            for($i=0;$i<$num_rows;$i++){
                $templateids[] = $adb->query_result($result,$i,'templateid');
            }
        }
        return $templateids;
    }

    /* 获取字段信息 G1_1_1 */
    private function getFieldRelatedInfo($tabId, $fieldName){
        global $adb;
        $fieldobj=Field::getInstance(getTabname($tabId),$adb);
        $fieldInfo=$fieldobj->getFieldInfoList();;

        return $fieldInfo;
    }

    /* 列表页 激活,禁用模板 */
    public function changeStatus(){
        global $adb;
        
        $templateid = $_REQUEST['record'];
        $status = $_REQUEST['status'];
        
        $sql = 'update ld_template_calendar set status = ? where templateid = ?';
        $adb->pquery($sql,array($status,$templateid));
    }

}