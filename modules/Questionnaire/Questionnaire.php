<?php


class Questionnaire extends CRMEntity
{

    static function require_file($requiremodules = '')
    {
        globalStatic::$arr_module_require['Questionnaire'] = 'Questionnaire';


        if (!empty($requiremodules) && empty(globalStatic::$arr_module_require[$requiremodules])) {
            globalStatic::$arr_module_require[$requiremodules] = $requiremodules;
            include(globalStatic::$root_directory . "modules/$requiremodules/$requiremodules.php");

        }

    }

    var $log;
    var $db;
    var $module_name = 'Questionnaire';
    var $table_name = "ld_questionnaire";
    var $table_index = 'questionnaireid';
    //'ld_contactaddress','ld_contactsubdetails','ld_customerdetails'
    //'ld_contactaddress'=>'contactaddressid','ld_contactsubdetails'=>'contactsubscriptionid',
    //'ld_customerdetails'=>'customerid'
    var $tab_name = array('ld_crmentity', 'ld_questionnaire', 'ld_questionnairescf');
    var $tab_name_index = array('ld_crmentity' => 'crmid', 'ld_questionnaire' => 'questionnaireid', 'ld_questionnairescf' => 'questionnaireid',);
    /**
     * Mandatory table for supporting custom fields.
     */
    var $customFieldTable = array('ld_questionnairescf', 'questionnaireid');

    var $column_fields = array();

    var $sortby_fields = array();

    var $list_link_field = 'questionnaire_no';
    var $relatedtab = array('');


    var $table_code = 'questionnaire_no';
    var $search_fields = array();

    var $search_fields_name = array();

    // This is the list of lingdang_fields that are required
    var $required_fields = array("name" => 1);

    // Used when enabling/disabling the mandatory fields for the module.
    // Refers to ld_field.fieldname values.
    var $mandatory_fields = array('assigned_user_id', 'createdtime', 'modifiedtime');

    //Default Fields for Email Templates -- Pavani
    var $emailTemplate_defaultFields = array();

    //Added these variables which are used as default order by and sortorder in ListView
    var $default_order_by = 'name';
    var $default_sort_order = 'ASC';

    // For Alphabetical search
    var $def_basicsearch_col = 'name';

    function __construct()
    {

        $this->db = PearDatabase::getInstance();
        $this->fieldobj = Field::getInstance('Questionnaire', $this->db);
        $this->column_fields = $this->fieldobj->getFieldArray('fieldname', $this);
        $entityname = getEntitynameByModulename('Questionnaire');
        $this->list_link_field = $entityname['fieldname'];
    }
    function get_QuestionnaireReport($smarty,$record,$startime = '',$endtime ='',$search_topic_type = '',$search_topic_name =''){
        global $current_user,$currentmodule;
        //获取筛选日期html
//        $smarty->assign("NOW_DATE",date('Y-m-d'));
        $basicfilterHtml = $this->createTimeHtml();
        $smarty->assign('BASICFILTERHTML',$basicfilterHtml);

        //人员范围
//        $MergeSmowner=getCurSmOwnerSearchScope($currentmodule);
//        $smarty->assign('Merge_SmOwner',$MergeSmowner);
//20240305 hzx XUQIU20240112-01 查询分类显示优化（仿腾讯云），一行显示4个，点击出现弹出层注：注意区分普通、悬浮、选中状态
if(is_array($MergeSmowner) && count($MergeSmowner) > 0 && $currentModule != 'InventoryAccount' && $currentModule != 'InventoryQuery' && $currentModule != 'BankAccountSet' && $currentModule != 'Reminds'){
    $SmOwner_option_arr = [];
    $showviewrange = false;
    foreach($MergeSmowner as $User_Key => $User_value){
        foreach($User_value as $User_id => $User_name){
            foreach($User_name as $User_name_key => $User_name_value){
                $SmOwner_option_arr[] = array('label'=>$User_name_key,'value'=>$User_id);
                if($User_id == 'smowner_search_senior'){
                    $showviewrange = true;
                }
            }
        }
    }
    if($showviewrange == true){
        $smarty->assign('showviewrange',$showviewrange);
    }
}else{
    $SmOwner_option_arr = [];
    $SmOwner_option_arr[] = array('label'=>getFixedLabel('ALL'),'value'=>'SmOwner_Search_All','selected'=>true);
}
$smarty->assign('Merge_SmOwner_arr',json_encode($SmOwner_option_arr));

        //获取表单数据的内容
        $questionnaireInfo = $this->getQuestionnaireInfo($record);
        $reportArr = $this->getReportData($record,$startime,$endtime,$search_topic_type,$search_topic_name);

//        $reportArr = array_merge($reportArr, $questionnaireInfo);
        $smarty->assign('reportArr',$reportArr);
        $smarty->assign('name',$questionnaireInfo['name']);
        $smarty->assign('description',$questionnaireInfo['description']);
        $smarty->assign('recoverys',$questionnaireInfo['recoverys']);
        $smarty->assign('views',$questionnaireInfo['views']);
        $content = $smarty->fetch('modules/Questionnaire/Report.tpl');
//        return $content;

        return compact('reportArr','content');

    }
    function getQuestionnaireInfo($record){
        global $adb;
        $sql = 'SELECT * FROM ld_questionnaire WHERE questionnaireid = ? ';
        $result = $adb->pquery($sql,array($record));
        if ($adb->num_rows($result) > 0) {
            $name = $adb->query_result($result,0,'name');
            $description = $adb->query_result($result,0,'description');
            $recoverys = $adb->query_result($result,0,'recoverys');//回收数
            $views = $adb->query_result($result,0,'views');//浏览数
        }
        return compact('name','description','recoverys', 'views');
    }
    
    //查询数据
    function getReportData($record,$startime,$endtime,$search_topic_type,$search_topic_name){
        global $adb;
        $reportArr = array();
        $blocks = $this->getLayoutBlock($record);
        $topicid_index_arr=array();
        foreach($blocks as $blockid=>$blockinfo){
            foreach($blockinfo['topic_array'] as $topicid=>$topicinfo)
            {
                $topicid_index_arr[$topicinfo['topicid']]=$topicid;
            }
        }
        //获取总提交次数
        $sql="select ld_questionnaire.recoverys from ld_questionnaire where questionnaireid=? ";
        $chart_result = $adb->pquery($sql,array($record));
        $writecount = $adb->query_result($chart_result,0,'recoverys');

        foreach($blocks as $blockid => $blockinfo) {
            foreach ($blockinfo['topic_array'] as $topicid => $topic_info) {
                if ($topic_info['topic_type'] == 'SelectBill') {
                    unset($blocks[$blockid]['topic_array'][$topicid]);
                    continue;
                }
                if ($search_topic_type != '' && $topic_info['topic_type'] != $search_topic_type) {//BUG20240229-29 xxy 2024-3-1 调查问卷，相关信息栏点击统计报表，题目名称搜索框内输入题目名称，点击查询没反应 
                    unset($blocks[$blockid]['topic_array'][$topicid]);
                    continue;
                }
                if ($search_topic_name != '' && strpos($topic_info['topic_name'] , $search_topic_name) === false) {
                    unset($blocks[$blockid]['topic_array'][$topicid]);
                    continue;
                }
                unset($blocks[$blockid]['topic_array'][$topicid]['topic_json']);//统计报表不需要topic_json
                //获取填写的内容
                $sql = "SELECT * FROM ld_questionnaire_chart AS q LEFT JOIN ld_questionnaire_topic_option AS
                 t ON q.optionid = t.optionid AND t.deleted = 0 WHERE q.topicid = ? ";

                if (empty($startime)) {  //默認  本月
                    $month_begin = date("Y-m-d", mktime(0, 0, 0, date("m"), 1, date("Y")));
                    $month_end = date("Y-m-d", mktime(23, 59, 59, date("m"), date("t"), date("Y")));
                    $sql .= " AND createdtime BETWEEN '" . $month_begin . " 00:00:00' and '" . $month_end . " 23:59:59'";
                } else {
                    $sql .= $this->makeWhereTimeSql('createdtime', $startime, $endtime);

                }
                $sql .= " ORDER BY id DESC";
                $chart_result = $adb->pquery($sql, array($topicid));

                //统计单个题目总提交数
                //$count = $adb->num_rows($chart_result);
                $blocks[$blockid]['topic_array'][$topicid]['count'] = $writecount;
                $chair_count = $adb->num_rows($chart_result);
                $sql = "select count(topicid) as rows from ld_questionnaire_chart where topicid=? GROUP BY topicid,seqtime ";
                $topiccountresult = $adb->pquery($sql, array($topicid));

                $chair_count = $adb->num_rows($topiccountresult);//题目的填写次数

                $blocks[$blockid]['topic_array'][$topicid]['chair_count'] = $chair_count;

                if ($adb->num_rows($chart_result) > 0) {
                    if ($topic_info['topic_type'] == 'text' || $topic_info['topic_type'] == 'Singleline' || $topic_info['topic_type'] == 'Multiline' || $topic_info['topic_type'] == 'tel') {
                        for ($i = 0; $i < $adb->num_rows($chart_result); $i++) {
                            $blocks[$blockid]['topic_array'][$topicid]['option_info'][] = $adb->query_result($chart_result, $i, 'option_value');
                        }

                    } else {
                        //统计选项个数
                        $sql = 'SELECT q.optionid,t.topicoption,count(1) AS counts FROM ld_questionnaire_chart AS q LEFT JOIN ld_questionnaire_topic_option AS t ON q.optionid = t.optionid WHERE q.topicid = ? and t.deleted = 0 ';
                        if (empty($startime)) {  //默認  本月
                            $month_begin = date("Y-m-d", mktime(0, 0, 0, date("m"), 1, date("Y")));
                            $month_end = date("Y-m-d", mktime(23, 59, 59, date("m"), date("t"), date("Y")));
                            $sql .= " AND createdtime BETWEEN '" . $month_begin . " 00:00:00' and '" . $month_end . " 23:59:59'";
                        } else {
                            $sql .= $this->makeWhereTimeSql('createdtime', $startime, $endtime);
                        }
                        $sql .= ' GROUP BY optionid';
                        $option_count_result = $adb->pquery($sql, array($topicid));
                        for ($i = 0; $i < $adb->num_rows($option_count_result); $i++) {
                            $optionid = $adb->query_result($option_count_result, $i, 'optionid');
                            $option_value = $adb->query_result($option_count_result, $i, 'topicoption');
                            $option_count = $adb->query_result($option_count_result, $i, 'counts');
                            $percentage = round(($option_count / $chair_count) * 100);

                            $blocks[$blockid]['topic_array'][$topicid]['option_info'][] = array($optionid, $option_value, $option_count, $percentage);
                        }
                    }
                } else {
                    //没有回收数据

                }

            }
        }

        $reportArr = $blocks;
        //dump($reportArr);
        return $reportArr;
    }

    function get_QuestionnaireChartsave($smarty,$record,$pagenum=1){
        global $adb,$currentmodule;
        $numpage = 20;//每页显示 数量
        $pagenum_limit = ($pagenum-1) * $numpage;

        $sql_sum = 'select * from ld_questionnaire_chartsave where questionnaireid = ?';
        $result_sum = $adb->pquery($sql_sum,array($record));
        $chartsave_sum = $adb->num_rows($result_sum);
        $chartsave_sum_show = getFixedLabel('TOTALOF').' '.$chartsave_sum.' '.getFixedLabel('RECORDNUMS');
        $pagesum = ceil($chartsave_sum/$numpage);

        $sql_select = 'select * from ld_questionnaire_chartsave where questionnaireid = ? limit '.$pagenum_limit.','.$numpage.';';
        $result_select = $adb->pquery($sql_select,array($record));
        $chartsave_num = $adb->num_rows($result_select);
        $chartsave_array = [];
        if($chartsave_num>0){
            for($i = 0;$i<$chartsave_num;$i++){
                $chartsaveid = $adb->query_result($result_select,$i,'chartsaveid');
                $chartsave_array[$chartsaveid ] = array(
                    'chartsaveid'=>$chartsaveid,
                    'seqtime'=>$adb->query_result($result_select,$i,'seqtime')
                );
            }
        }
        $page_html = '<div class="ld-pagenum-value outline bgwhite" style="position: relative;"><div id="pagenum_show">'.$pagenum.'/'.$pagesum.'&nbsp;&nbsp;<b class="down"></b><b style="visibility: hidden">'.$pagenum.'</b></div>';
        $page_html .= '<input start="0" relatetag="'.$_REQUEST['QuestionnaireChartsave'].'" relatedid="'.$_REQUEST['relatedid'].'" type="hidden" id="pagenum" onchange="DetailViewRelation.setRelatedListPageByGo(event,ld(this));" name="pagenum" value="'.$pagenum.'" autocomplete="off">';
        $page_html .= '<div class="ld-pagenum-list"><ol class="D_more_menua">';
        for($i = 1;$i<$pagesum+1;$i++){
            $page_html .= '<li class="selected" onclick="ldSelectPageNum(this,'.$i.','.$pagesum.')"><a>'.$i.'/'.$pagesum.'</a></li>';
        }
        $page_html .= '</ol></div></div>';
        if($pagenum == 1){
            $page_html .= '<div class="ld-pagenum-div icon-left-inactive cursorNotAllowed"><b class="icon-pre-next"></b></div>';
        }else{
            $prev_pagenum = $pagenum - 1;
            $page_html .= '<div class="ld-pagenum-div tip-items-list icon-left-active" relatetag="'.$_REQUEST['QuestionnaireChartsave'].'" relatedid="'.$_REQUEST['relatedid'].'" start="'. $prev_pagenum .'" onclick="DetailViewRelation.setRelatedListPage(event,ld(this));" data-tip="' .getFixedLabel('PREVPAGE'). '" data-direction="top" data-type="position"><b class="icon-pre-next"></b></div>';
        }
        if($pagenum == $pagesum){
            $page_html .= '<div class="ld-pagenum-div icon-right-inactive cursorNotAllowed"><b class="icon-pre-next"></b></div>';
        }else{
            $next_pagenum = $pagenum + 1;
            $page_html .= '<div class="ld-pagenum-div tip-items-list icon-right-active" data-tip="'. getFixedLabel('NEXTPAGE'). '" data-direction="top" data-type="position" relatetag="'.$_REQUEST['QuestionnaireChartsave'].'" relatedid="'.$_REQUEST['relatedid'].'" start="'. $next_pagenum .'" onclick="DetailViewRelation.setRelatedListPage(event,ld(this));"><b class="icon-pre-next"></b></div>';
        }
        //dump($page_html);
        $smarty->assign('questionnaireid',$record);
        $smarty->assign('CHARTSAVE_NUM',$chartsave_sum);
        $smarty->assign('CHARTSAVE_NUM_SHOW',$chartsave_sum_show);
        $smarty->assign('QUESCHARTSAVE_PAGHTML',$page_html);
        $smarty->assign('CHARTSAVE_ARRAY',$chartsave_array);
        $content = $smarty->fetch('modules/Questionnaire/Chartsave_ListView.tpl');

        return compact('chartsave_array','content');
    }


    //获取详细填写数据
    function getChartsaveDetail($chartsaveid,$bloackarray){
        global $adb,$languageType;
        if(!empty($bloackarray)){
            foreach ($bloackarray as $blockid => $blockinfo){
                if(!empty($blockinfo['topic_array'])){
                    foreach ($blockinfo['topic_array'] as $topicid => $topicinfo){
                        if($topicinfo['topic_type'] == 'more' || $topicinfo['topic_type'] == 'one'){
                            $sql_select = 'select optionid from ld_questionnaire_chart where chartsaveid = ? and topicid = ?;';
                            $result_select = $adb->pquery($sql_select,array($chartsaveid,$topicid));
                            if($adb->num_rows($result_select)>0){
                                if($topicinfo['topic_type'] == 'more'){
                                    for($i = 0;$i<$adb->num_rows($result_select);$i++){
                                        $bloackarray[$blockid]['topic_array'][$topicid]['chart_value'][] = $adb->query_result($result_select,$i,'optionid');
                                    }
                                }else{
                                    $bloackarray[$blockid]['topic_array'][$topicid]['chart_value'] = $adb->query_result($result_select,0,'optionid');
                                }
                            }
                        }else{
                            $sql_select = 'select option_value from ld_questionnaire_chart where chartsaveid = ? and topicid = ?;';
                            $result_select = $adb->pquery($sql_select,array($chartsaveid,$topicid));
                            if($adb->num_rows($result_select)>0){
                                if($topicinfo['topic_type'] == 'SelectBill') {
                                    $sql_module = 'select ld_tab.`name`,ld_tranlabel.fieldlabel,ld_tab.tabid,ld_tab.primary_key from ld_tab inner join ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid 
                                            where ld_tab.presence in(0,2) and ld_tranlabel.trantable="ld_tab" and languagetype=?  and ld_tab.`name`= ?';
                                    $result_module=$adb->pquery($sql_module,array($languageType,$topicinfo['topic_other_info']['referencemodule']));
                                    if($adb->num_rows($result_module)>0){
                                        $module_tableid = $adb->query_result($result_module,0,'tabid');
                                        $bloackarray[$blockid]['topic_array'][$topicid]['chart_value']['module_label'] = $adb->query_result($result_module,0,'fieldlabel');
                                        $bloackarray[$blockid]['topic_array'][$topicid]['chart_value']['module_id'] = $adb->query_result($result_select,0,'option_value');
                                        $sql = 'select ld_entityname.modulename,ld_field.columnname,ld_field.fieldname,ld_field.tablename,ld_field.fieldlabel 
                                            from ld_field LEFT JOIN ld_entityname on ld_field.fieldname = ld_entityname.fieldname and ld_field.tabid = ld_entityname.tabid 
                                            where ld_entityname.tabid = ? ';
                                        $result=$adb->pquery($sql,array($module_tableid));
                                        $rows=$adb->num_rows($result);
                                        if($rows>0){
                                            $select_sql = "select ".$adb->query_result($result,0,'columnname')." from ".$adb->query_result($result,0,'tablename')." where ".$adb->query_result($result_module,0,'primary_key')." = ".$adb->query_result($result_select,0,'option_value');
                                            $select_result = $adb->pquery($select_sql,array());
                                            if($adb->num_rows($select_result) > 0){
                                                $bloackarray[$blockid]['topic_array'][$topicid]['chart_value']['module_value'] = $adb->query_result($select_result,0,0);
                                            }
                                        }
                                    }
                                }else{
                                    $bloackarray[$blockid]['topic_array'][$topicid]['chart_value'] = $adb->query_result($result_select,0,'option_value');
                                }
                            }
                        }
                    }
                }
            }
        }

        return $bloackarray;
    }

    function makeWhereTimeSql($field,$startime,$endtime){
        $sql ='';
        if($startime != ''){
            $startime .= ' 0:0:0';
        }
        if($endtime != ''){
            $endtime .=' 23:59:59';
        }
        if($startime!= '' && $endtime ==''){
            $sql .= 'and '.$field.' > \''.$startime.'\'';
        }elseif ($startime == '' && $endtime !=''){
            $sql .= 'and  '.$field.' < \''.$startime.'\'';
        }elseif ($startime != '' && $endtime !=''){
            $sql  .= 'and '.$field.' BETWEEN  \''.$startime.'\' and \''.$endtime.'\'';
        }
        return $sql;
    }

    function createTimeHtml(){
        $basicfilterHtml='';
        $basicfilterHtml.="<td width='100%' colspan='2'>";
        //本日，昨日，本周，本月，时间获取
        $todayselect=  date('Y-m-d',time());
        $yesterdayselect=  date("Y-m-d",time()-24*60*60);
        $week_begin =  date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
        $week_end =  date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
        $lastweeks=DateOperation::getlastweekrange($todayselect);
        $lastweekbegin=$lastweeks[0];
        $lastweekend=$lastweeks[sizeof($lastweeks)-1];

        //上月
        $time=strtotime(date('Y-m-d'));
        $last_month_begin=date('Y-m-01',strtotime(date('Y',$time).'-'.(date('m',$time)-1).'-01'));
        $last_month_end=date('Y-m-d',strtotime("$last_month_begin +1 month -1 day"));
        //本月
        $month_begin=date("Y-m-d",mktime(0, 0, 0,date("m"),1,date("Y")));
        $month_end = date("Y-m-d",mktime(23,59,59,date("m"),date("t"),date("Y")));
        //本年
        $begin_this_year=date('Y-01-01');
        $end_this_year=date('Y-12-31');
        $basicfilterHtml .="<a class='changeday' id='today' name='OftenUseReport_search' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'today','$todayselect','$todayselect')\">".getFixedLabel('checktoday')."</a>
                        <a id='yesterday' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'yesterday','$yesterdayselect','$yesterdayselect')\">".getFixedLabel('checkyesterday')."</a>
                         <a id='lastweek' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'lastweek','$lastweekbegin','$lastweekend')\">".getFixedLabel('lastweek')."</a>
                        <a id='week' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'week','$week_begin','$week_end')\">".getFixedLabel('thisweek')."</a>
						<a id='lastmonth' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'lastmonth','$last_month_begin','$last_month_end')\">".getFixedLabel('lastmonth')."</a>
                        <a id='month' name='OftenUseReport_search' class='onselected_A changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'month','$month_begin','$month_end')\">".getFixedLabel('thismonth')."</a>
                        <a id='year' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'year','$begin_this_year','$end_this_year')\">".getFixedLabel('THISYEAR')."</a>
                        <a id='all' name='OftenUseReport_search' class='changeday' href=\"javascript:void(0);\" onclick=\"questionnairechangedaytime(this,'all','2000-01-01','2050-12-31')\">".getFixedLabel('ALL')."</a>";

        $basicfilterHtml .="<label><span class='changeday colorLink' id='daterangepicker_search'>" .getFixedLabel('DATESELECTION')."&nbsp;</span>";
        $data_system = "width:180px;padding-left:3px;margin-top: -2px;margin-left: 5px;";
        $basicfilterHtml .= "<input class='borderALL btn-radius-system' type='text' readonly=true value='".$month_begin." - ".$month_end."' id='startmonth' name='startmonth' findcolumn= '' style='".$data_system."'/></label>";
        $basicfilterHtml.='</td>';
        return $basicfilterHtml;

    }


    function updateStatus($record,$curstatus){
        global $adb;
        if ($curstatus == '正在回收') { //正在回收
            $status = '暂停';
        }else if($curstatus == '暂停') {
            $status = '正在回收';
        }
        $query = 'SELECT * FROM ld_questionnaire where questionnaireid = ? AND deleted = 0 AND status = ?';
        $result = $adb->pquery($query,array($record,$curstatus));
        if ($adb->num_rows($result) > 0) {
            $query = 'UPDATE ld_questionnaire SET status = ?  WHERE questionnaireid = ? AND deleted = 0';
            $adb->pquery($query,array($status,$record));
            return true;
        }
        return false;
    }
    
    

    //保存题目
    function SaveTopic($blockid,$topic_array)
    {
        global $adb;
        $topicid = $topic_array['topic_id'];//题目id
        $topic_type = $topic_array['topic_type'];//题目类型
        $topic_array['topic_name'] = html_entity_decode($topic_array['topic_name']);
        $topic_name = $topic_array['topic_name'];//题目名
        $description = $topic_array['topic_description'];//题目备注
        $required = $topic_array['required'];//是否必填
        //dump($topic_name);

        if ($topicid > 0) {//编辑
            $query_update = "UPDATE ld_questionnaire_topic SET topic_name=?, description=?, required=?, blockid=? WHERE topicid = ?";
            $params = array($topic_name, $description, $required, $blockid, $topicid);
            $adb->pquery($query_update, $params);
        }else {//新建
            if($blockid>0){
                $sql_blocK = 'select max(sequence) from ld_questionnaire_topic where blockid = ?;';
                $result_sequence = $adb->pquery($sql_blocK,array($blockid));
                if($adb->num_rows($result_sequence)>0){
                    $new_sequence = $adb->query_result($result_sequence,0,0) + 1;
                }else{
                    $new_sequence = 1;
                }
            }
            $query_insert = "INSERT INTO ld_questionnaire_topic(questionnaireid, topic_type, topic_name, description, required, sequence, topic_json_old,blockid) VALUES (?,?,?,?,?,?,?,?)";
            $params = array($this->id, $topic_type, $topic_name, $description, $required, $new_sequence, "no",$blockid);
            $adb->pquery($query_insert, $params);
            $topicid = $adb->getLastInsertID();
            $topic_array['topic_id'] = (string)$topicid;
        }

        if ($topic_type == 'text') {//["text","你的建议？","","no"]
            $query = "UPDATE ld_questionnaire_topic SET topic_json=? WHERE topicid = ?";
            $params = array(ldcrm_json_encode($topic_array), $topicid);
            $adb->pquery($query, $params);
        } elseif($topic_type == 'Singleline' || $topic_type == 'Multiline'){
            $query = "UPDATE ld_questionnaire_topic SET topic_json=? WHERE topicid = ?";
            $params = array(ldcrm_json_encode($topic_array), $topicid);
            $adb->pquery($query, $params);
        }elseif ($topic_type == 'SelectBill'){
            $topic_referencemodule_info = $topic_array['topic_other_info'];
            $topic_referencemodule_info['advance_demand'] = ldcrm_json_encode($topic_array['topic_other_info']['advance_demand']);
            $topic_referencemodule_info['advance_demand_groups'] = ldcrm_json_encode($topic_array['topic_other_info']['advance_demand_groups']);
            $query = "UPDATE ld_questionnaire_topic SET referencemodule = ?,approve_demand = ?,maxrowsshow = ?,fieldonly = ?,advance_demand = ?,advance_demand_groups = ?,topic_json = ? WHERE topicid = ?";
            $topic_referencemodule_info['topic_json'] = ldcrm_json_encode($topic_array);
            $topic_referencemodule_info['topicid'] = $topicid;
            $adb->pquery($query, $topic_referencemodule_info);
            $topic_array_new[]= $topic_array;
        }
        elseif ($topic_type == 'tel'){
            $topic_other_info['fieldonly'] = $topic_array['topic_other_info']['fieldonly'];
            $topic_other_info['telregexp'] = $topic_array['topic_other_info']['telregexp'];
            $query = "UPDATE ld_questionnaire_topic SET fieldonly = ?,telregexp = ?,topic_json = ? WHERE topicid = ?";
            $topic_other_info['topic_json'] = ldcrm_json_encode($topic_array);
            $topic_other_info['topicid'] = $topicid;
            $adb->pquery($query, $topic_other_info);
        }
        elseif ($topic_type == 'one' || $topic_type == 'more') {

            //筛选选项，删除不要的选项
            foreach ($topic_array['topic_option_array'] as $key => $optionarray) {
                $new_optionid_array[] = $optionarray['optionid'];
            }
            $sql_select = 'select optionid from ld_questionnaire_topic_option where topicid = ? and deleted = 0;';
            $result_optionid = $adb->pquery($sql_select,array($topicid));
            if($adb->num_rows($result_optionid) > 0){
                for($ii=0;$ii<$adb->num_rows($result_optionid);$ii++){
                    $optionid = $adb->query_result($result_optionid,$ii,'optionid');
                    if(in_array($optionid,$new_optionid_array)){

                    }else{
                        $sql_delete = 'update ld_questionnaire_topic_option set deleted = 1 where optionid = ?;';
                        $adb->pquery($sql_delete,array($optionid));
                    }
                }
            }

            $j = 1;
            foreach ($topic_array['topic_option_array'] as $key => $optionarray) {
                if($optionarray['optionid'] > 0){
                    $query = "update ld_questionnaire_topic_option set topicoption = ?,sequence = ? where optionid = ?;";
                    $params = array($optionarray['value'],$j,$optionarray['optionid']);
                    $adb->pquery($query, $params);
                }else{
                    $query = "INSERT INTO ld_questionnaire_topic_option(topicid, topicoption, sequence) VALUES (?,?,?)";
                    $params = array($topicid, $optionarray['value'], $j);
                    $adb->pquery($query, $params);
                }
                $j++;
            }

            $sql_options = 'select optionid,topicoption from ld_questionnaire_topic_option where topicid = ? and deleted = 0 ORDER BY sequence ASC;';
            $result_options = $adb->pquery($sql_options,array($topicid));
            $new_options_array = [];
            if($adb->num_rows($result_options) > 0){
                for($iii = 0;$iii<$adb->num_rows($result_options);$iii++){
                    $new_options_array[] = array('optionid'=>$adb->query_result($result_options,$iii,'optionid'),'value'=>$adb->query_result($result_options,$iii,'topicoption'));
                }
            }
            $topic_array['topic_option_array'] = $new_options_array;
            $query = "UPDATE ld_questionnaire_topic SET topic_json = ? WHERE topicid = ?";
            $adb->pquery($query, array(ldcrm_json_encode($topic_array),$topicid));
        }

        return $topic_array;
    }
    
    function ChangeHistoryTopicJson()
    {
        
        global $adb;
        $sql='select * from ld_questionnaire_topic where topic_json_old is null or topic_json_old ="" or topic_json_old="yes" ';
        $result=$adb->pquery($sql,array());
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
             $db_topic_json_arr=[];
             $topic_json=$adb->query_result($result,$i,'topic_json');
             $topicid=$adb->query_result($result,$i,'topicid');
             $topic_type = $adb->query_result($result,$i,'topic_type');
             $topic_json_arr=ldcrm_json_decode($topic_json);
             //dump(sizeof($topic_json_arr));
             if(empty($topic_json_arr['topic_type']))
             {
                 $db_topic_json_arr = array(
                     'topic_id'=>$topic_json_arr[0], //id
                     'topic_type'=>$topic_json_arr[1],//问题类型
                     'topic_name'=>$topic_json_arr[2],//问题名称
                     'topic_description'=>$topic_json_arr[3],//备注
                     'required'=>$topic_json_arr[4],//是否必填
                     'topic_option_array'=>$topic_json_arr[5]//单选或多选 选项列表
                 );
                 if($topic_type == 'SelectBill'){
                     $db_topic_json_arr['topic_other_info']=array(
                         'referencemodule'=>$topic_json_arr[6][0],
                         'approvedemand'=>$topic_json_arr[6][1],
                         'maxrowsshow'=>$topic_json_arr[6][2],
                         'fieldonly'=>$topic_json_arr[6][3],
                         'advance_demand'=>$topic_json_arr[6][4],
                         'advance_demand_groups'=>$topic_json_arr[6][5],
                     );
                 }else{
                     $db_topic_json_arr['topic_other_info']=array();
                 }
                 $sql='update ld_questionnaire_topic set topic_json=?,topic_json_old="no" where topicid=?';
                 $adb->pquery($sql,array(ldcrm_json_encode($db_topic_json_arr),$topicid));
             }
             else
             {
                $sql='update ld_questionnaire_topic set topic_json_old="no" where topicid=?';
                $adb->pquery($sql,array($topicid));
             }
        }
    }
    //获取题目
    function getTopic($record,$search_topic_type = '', $search_topic_name = ''){
        global $adb;
        $this->ChangeHistoryTopicJson();
        $topic = [];      
        $query = "SELECT t.topicid,t.topic_type,t.topic_name,t.required,t.topic_json,t.sequence,o.optionid,o.topicoption,t.topic_json_old FROM ld_questionnaire_topic AS t LEFT JOIN ld_questionnaire_topic_option AS o ON o.topicid=t.topicid and o.deleted = 0 WHERE t.questionnaireid = ? and t.deleted = 0";
        if (!empty($search_topic_type)) { //统计报表 查询
            $query .= " AND t.topic_type = '".$search_topic_type."'";
        }
        if (!empty($search_topic_name)) {
            $query .= " AND t.topic_name like '%".$search_topic_name."%'";
        }
        $query .= " ORDER BY t.sequence ASC";
        $params = array($record);
        $result = $adb->pquery($query, $params);
        //dump($result);
        if ($adb->num_rows($result) >= 1) {
            for($i = 0; $i<$adb->num_rows($result); $i++){
                $topicid = $adb->query_result($result,$i,'topicid');
                $topic_type = $adb->query_result($result,$i,'topic_type');
                $required = $adb->query_result($result,$i,'required');
                $sequence = $adb->query_result($result,$i,'sequence');
                $topic[$sequence]['topicid'] = $adb->query_result($result,$i,'topicid');
                $topic[$sequence]['topic_type'] = $topic_type;
                $topic[$sequence]['topic_name'] = $adb->query_result($result,$i,'topic_name');
                $topic[$sequence]['required'] = $required;
                $topic[$sequence]['topic_json'] = ldcrm_json_decode($adb->query_result($result,$i,'topic_json'));
//                $topic[$topicid]['topic_json'] = $adb->query_result($result,$i,'topic_json');
               // dump(ldcrm_json_decode($adb->query_result($result,$i,'topic_json')));
                $optionid = $adb->query_result($result,$i,'optionid');
                $topicoption = $adb->query_result($result,$i,'topicoption');
                $history = $adb->query_result($result,$i,'topic_json_old');
                if (isset($history) && $history != 'no' && $history == '' && $history == NULL){
                    
                }else{
                    if ($topic_type == 'text') {
                        $topic[$sequence]['option'] = array();
                    } else {
                        $topic[$sequence]['option'][$optionid] = $topicoption;
                    }
                    $required_label = getFixedLabel('NO');
                    if ($required == 'yes') {
                        $required_label = getFixedLabel('YES');
                    }
                    $topic[$sequence]['required_label'] = $required_label;
    
                    $topic_type_label = '';
                    if ($topic_type == 'text'){
                        $topic_type_label = getFixedLabel('Textdescription');//'文本描述';
                    }
                    elseif ($topic_type == 'one'){
                        $topic_type_label = getFixedLabel('Multiplechoicequestions');
                    }
                    elseif ($topic_type == 'more'){
                        $topic_type_label = getFixedLabel('Multipleschoicequestions');
                    }
                    elseif ($topic_type == 'Singleline'){
                        $topic_type_label = getFixedLabel('Singlelinetextquestion');
                    }
                    elseif ($topic_type == 'Multiline'){
                        $topic_type_label = getFixedLabel('Multilinetextquestions');
                    }
                    elseif ($topic_type == 'SelectBill'){
                        $topic_type_label = getFixedLabel('SelectBill');
                    }
                    elseif ($topic_type == 'tel'){
                        $topic_type_label = getFixedLabel('Mobile');
                    }
                    $topic[$sequence]['topic_type_label'] = $topic_type_label;
                }

            }

        }
        //dump($topic);
        return $topic;
    }

    /** Function to handle module specific operations when saving a entity
     */
    function save_module($module)
    {


    }

    function restore($module, $id)
    {

        parent::restore($module, $id);

    }


    // Function to unlink an entity with given Id from another entity
    function unlinkRelationship($id, $return_module, $return_id)
    {


    }
    
    
    //删除题目
    function delect_topic($topicid){
        global $adb;
        $sql_delete = 'update ld_questionnaire_topic set deleted = 1 where topicid = ?';
        $adb->pquery($sql_delete,array($topicid));
    }

    //区块排序
    function Change_Block_Order($blockid,$changeid){
        global $adb;
        $sql_old = 'select sequence from ld_questionnaire_block where blockid = ?;';
        $result_old = $adb->pquery($sql_old,array($changeid));
        if($adb->num_rows($result_old)>0){
            $old_sequence = $adb->query_result($result_old,0,'sequence');
            $sql_update = 'update ld_questionnaire_block
                INNER JOIN (SELECT sequence from ld_questionnaire_block where blockid = ?) as tmp2 
                 set ld_questionnaire_block.sequence = tmp2.sequence where blockid = ?;';
            $adb->pquery($sql_update,array($blockid,$changeid));
            $sql_update_new = 'update ld_questionnaire_block set sequence = ? where blockid = ?';
            $adb->pquery($sql_update_new,array($old_sequence,$blockid));
        }
    }

    //移动修改
    function moveBlockOrder($record,$sequence_array){
        global $adb;
        for($i = 0;$i<count($sequence_array);$i++){
            $sql_update = 'update ld_questionnaire_block set sequence = ? where questionnaireid = ? and blockid = ?';
            $adb->pquery($sql_update,array($i,$record,$sequence_array[$i]));
        }
    }
    
    //查找题目选项
    function select_topic_option($topicid){
        global $adb;
        $query = "select optionid from ld_questionnaire_topic_option where topicid = ? and deleted = 0";
        $result = $adb->pquery($query, array($topicid));
        if ($adb->num_rows($result) >= 1) {
            for($i = 0; $i<$adb->num_rows($result); $i++){
                $option_array[$i] = $adb->query_result($result,$i,'optionid');
            }
        }
        return $option_array;
    }

    //获取区块信息
    function get_BlockInfo($blockid){
        global $adb;
        $sql = 'select questionnaireid,blockname,blocktype,sequence,autonumber,numberstyle,numbersuffix from ld_questionnaire_block where blockid = ? and deleted = 0 ORDER BY sequence asc;';
        $result = $adb->pquery($sql,array($blockid));
        $blockinfo = [];
        if($adb->num_rows($result)>0){
            $blockinfo['blockname'] = $adb->query_result($result,0,'blockname');
            $blockinfo['blocktype'] = $adb->query_result($result,0,'blocktype');
            $blockinfo['sequence'] = $adb->query_result($result,0,'sequence');
            $blockinfo['autonumber'] = $adb->query_result($result,0,'autonumber');
            $blockinfo['numberstyle'] = $adb->query_result($result,0,'numberstyle');
            $blockinfo['numbersuffix'] = $adb->query_result($result,0,'numbersuffix');
            $questionnaireid  = $adb->query_result($result,0,'questionnaireid');
            if($blockinfo['sequence']>0){
                $sql_sequence = 'select blockid,blocktype from ld_questionnaire_block where questionnaireid = ? and sequence < ? and deleted = 0 ORDER BY sequence DESC LIMIT 1;';
                $result_sequence = $adb->pquery($sql_sequence,array($questionnaireid,$blockinfo['sequence']));
                if($adb->num_rows($result_sequence)>0){
                    $blockinfo['afterblockid'] = $adb->query_result($result_sequence,0,'blockid');
                }
            }
        }
        return $blockinfo;
    }

    //获取区块列表
    function get_BlockList($record){
        global $adb;
        $sql = 'select blockid,blockname,sequence from ld_questionnaire_block where questionnaireid = ? and deleted = 0;';
        $result = $adb->pquery($sql, array($record));
        if($adb->num_rows($result) >= 1){
            for($i = 0;$i<$adb->num_rows($result); $i++){
                $blocklist[$adb->query_result($result,$i,'blockid')] = $adb->query_result($result,$i,'blockname');
            }
        }
        return $blocklist;
    }

    //保存区块
    function saveBlock($blockinfo){
        global $adb;

        //区块位置
        if($blockinfo['afterblockid'] > 0){
            $sql_seq="select sequence from ld_questionnaire_block where blockid = ?";
            $res_seq= $adb->pquery($sql_seq, array($blockinfo['afterblockid']));
            $row_seq=$adb->fetch_array($res_seq);
            $block_sequence=$row_seq['sequence'];
            $newblock_sequence=$block_sequence+1;
        }else{
            $newblock_sequence = 0;
        }

        $createdtime = date('Y-m-d H:i:s');

        if($blockinfo['blockid'] > 0){//编辑
            if($blockinfo['afterblockid'] > 0){
                $sql_oldseq="select sequence from ld_questionnaire_block where blockid = ?";
                $res_oldseq= $adb->pquery($sql_oldseq, array($blockinfo['blockid']));
                $row_oldseq=$adb->fetch_array($res_oldseq);
                $block_oldsequence=$row_oldseq['sequence'];
                $sql_up="update ld_questionnaire_block set sequence=sequence+1 where questionnaireid = ? and sequence > ? and sequence < ?";
                $adb->pquery($sql_up, array($blockinfo['questionnaireid'],$block_sequence,$block_oldsequence));
            }

            $sql_update = 'update ld_questionnaire_block set blockname = ?,autonumber = ?,numberstyle = ?,numbersuffix = ?,sequence = ?,modifiedtime = ? where blockid = ?;';
            $updatearray = array(
                $blockinfo['blockname'],
                $blockinfo['automatic_number'],
                $blockinfo['automatic_number_style'],
                $blockinfo['automatic_number_postfix'],
                $newblock_sequence,
                $createdtime,
                $blockinfo['blockid']
            );
            $adb->pquery($sql_update,$updatearray);
        }else{//新建
            $sql_up="update ld_questionnaire_block set sequence=sequence+1 where questionnaireid = ? and sequence > ?";
            $adb->pquery($sql_up, array($blockinfo['questionnaireid'],$block_sequence));

            $sql_insert = 'INSERT INTO ld_questionnaire_block(`questionnaireid`,`blockname`,`autonumber`,`numberstyle`,`numbersuffix`,`blocktype`,`sequence`,`createdtime`,`modifiedtime`) VALUES (?,?,?,?,?,?,?,?,?);';
            $insertarray = array(
                $blockinfo['questionnaireid'],
                $blockinfo['blockname'],
                $blockinfo['automatic_number'],
                $blockinfo['automatic_number_style'],
                $blockinfo['automatic_number_postfix'],
                'block',
                $newblock_sequence,
                $createdtime,
                $createdtime,
            );
            $adb->pquery($sql_insert,$insertarray);
        }
    }

    //删除区块
    function delect_block($blockid){
        global $adb;
        $sql_updatetopic = 'update ld_questionnaire_topic set deleted = 1 where blockid = ?;';
        $adb->pquery($sql_updatetopic,array($blockid));
        $sql_updateblock = 'update ld_questionnaire_block set deleted = 1 where blockid = ?;';
        $adb->pquery($sql_updateblock,array($blockid));
    }

    //获取区块、题目信息
    function getLayoutBlock($record){
        global $adb;
        $sql_selectblock = 'select blockid,blockname,blocktype,sequence,autonumber,numberstyle,numbersuffix from ld_questionnaire_block where questionnaireid = ? and deleted = 0 ORDER BY sequence asc;';
        $result_block = $adb->pquery($sql_selectblock,array($record));
        $block_rows = $adb->num_rows($result_block);
        $layoutblockarray = [];
        if($block_rows >= 1){
            for($i = 0;$i<$block_rows;$i++){
                $blockid = $adb->query_result($result_block,$i,'blockid');

                $topic_array = [];
                if($adb->query_result($result_block,$i,'blocktype') == 'virtual'){
                    $sql_selecttopic = 'select * from ld_questionnaire_topic where blockid in (?,0) and questionnaireid = '.$record.' and deleted = 0 ORDER BY sequence asc;';
                }else{
                    $sql_selecttopic = 'select * from ld_questionnaire_topic where blockid = ? and deleted = 0 ORDER BY sequence asc;';
                }
                $result_topic = $adb->pquery($sql_selecttopic,array($blockid));
                $topic_rows = $adb->num_rows($result_topic);
                if($topic_rows>0){
                    for($ii = 0;$ii<$topic_rows;$ii++){
                        $topicid = $adb->query_result($result_topic,$ii,'topicid');
                        $topic_type = $adb->query_result($result_topic,$ii,'topic_type');
                        $topic_options_array = [];
                        if($topic_type == 'one' || $topic_type == 'more'){
                            $sql_selectoptions = 'select optionid,topicoption from ld_questionnaire_topic_option where topicid = ? and deleted = 0 ORDER BY sequence asc';
                            $result_options = $adb->pquery($sql_selectoptions,array($topicid));
                            if($adb->num_rows($result_options) > 0){
                                for($iii = 0;$iii<$adb->num_rows($result_options);$iii++){
                                    $topic_options_array[$adb->query_result($result_options,$iii,'optionid')] = array(
                                        'optionid'=>$adb->query_result($result_options,$iii,'optionid'),
                                        'topicoption'=>$adb->query_result($result_options,$iii,'topicoption')
                                    );
                                }
                            }
                        }
                        if ($topic_type == 'text'){
                            $topic_type_label = getFixedLabel('Textdescription');//'文本描述';
                        }
                        elseif ($topic_type == 'one'){
                            $topic_type_label = getFixedLabel('Multiplechoicequestions');
                        }
                        elseif ($topic_type == 'more'){
                            $topic_type_label = getFixedLabel('Multipleschoicequestions');
                        }
                        elseif ($topic_type == 'Singleline'){
                            $topic_type_label = getFixedLabel('Singlelinetextquestion');
                        }
                        elseif ($topic_type == 'Multiline'){
                            $topic_type_label = getFixedLabel('Multilinetextquestions');
                        }
                        elseif ($topic_type == 'SelectBill'){
                            $topic_type_label = getFixedLabel('SelectBill');
                        }
                        elseif ($topic_type == 'tel'){
                            $topic_type_label = getFixedLabel('Mobile');
                        }
                        $required_label = getFixedLabel('NO');
                        if($adb->query_result($result_topic,$ii,'required') == 'yes'){
                            $required_label = getFixedLabel('YES');
                        }
                        $topic_array[$topicid] = array(
                            'topicid'=>$topicid,
                            'topic_type'=>$topic_type,
                            'topic_type_label'=>$topic_type_label,
                            'topic_name'=>$adb->query_result($result_topic,$ii,'topic_name'),
                            'required'=>$adb->query_result($result_topic,$ii,'required'),
                            'required_label'=>$required_label,
                            'description'=>$adb->query_result($result_topic,$ii,'description'),
                            'sequence'=>$adb->query_result($result_topic,$ii,'sequence'),
                            'topic_json'=>$adb->query_result($result_topic,$ii,'topic_json'),
                            'topic_option_array'=>$topic_options_array,
                            'topic_other_info'=>array(
                                'approvedemand'=>$adb->query_result($result_topic,$ii,'approve_demand'),
                                'maxrowsshow'=>$adb->query_result($result_topic,$ii,'maxrowsshow'),
                                'advance_demand'=>$adb->query_result($result_topic,$ii,'advance_demand'),
                                'advance_demand_groups'=>$adb->query_result($result_topic,$ii,'advance_demand_groups'),
                                'fieldonly'=>$adb->query_result($result_topic,$ii,'fieldonly'),
                                'referencemodule'=>$adb->query_result($result_topic,$ii,'referencemodule'),
                                'telregexp'=>$adb->query_result($result_topic,$ii,'telregexp')
                            )
                        );
                    }
                }

                $layoutblockarray[$blockid] = array(
                    'blockid'=>$adb->query_result($result_block,$i,'blockid'),
                    'blockname'=>$adb->query_result($result_block,$i,'blockname'),
                    'blocktype'=>$adb->query_result($result_block,$i,'blocktype'),
                    'sequence'=>$adb->query_result($result_block,$i,'sequence'),
                    'autonumber'=>$adb->query_result($result_block,$i,'autonumber'),
                    'numberstyle'=>$adb->query_result($result_block,$i,'numberstyle'),
                    'numbersuffix'=>$adb->query_result($result_block,$i,'numbersuffix'),
                    'topic_array'=>$topic_array
                );

            }
        }else{
            $createdtime = date('Y-m-d H:i:s');
            $sql_insert = "INSERT INTO ld_questionnaire_block(`questionnaireid`,`blockname`,`autonumber`,`numberstyle`,`numbersuffix`,`blocktype`,`sequence`,`createdtime`,`modifiedtime`) VALUES (".$record.",'virtual','no','','','virtual',0,'".$createdtime."','".$createdtime."');";
            $adb->pquery($sql_insert,array());
            $blockid = $adb->getLastInsertID();
            $sql_update = 'update ld_questionnaire_topic set blockid = ? where questionnaireid = ?';
            $adb->pquery($sql_update,array($blockid,$record));
            return $this->getLayoutBlock($record);
        }
        //dump($layoutblockarray);
        return $layoutblockarray;
    }

    //题目排序
    function Change_Topic_Order($topicid,$changeid){
        global $adb;
        $sql_old = 'select sequence from ld_questionnaire_topic where topicid = ?;';
        $result_old = $adb->pquery($sql_old,array($changeid));
        if($adb->num_rows($result_old)>0){
            $old_sequence = $adb->query_result($result_old,0,'sequence');
            $sql_update = 'update ld_questionnaire_topic
                INNER JOIN (SELECT sequence from ld_questionnaire_topic where topicid = ?) as tmp2 
                 set ld_questionnaire_topic.sequence = tmp2.sequence where topicid = ?;';
            //dump($old_sequence);
            $adb->pquery($sql_update,array($topicid,$changeid));
            $sql_update_new = 'update ld_questionnaire_topic set sequence = ? where topicid = ?';
            $adb->pquery($sql_update_new,array($old_sequence,$topicid));
        }
    }
    


}

Questionnaire::require_file();
?>