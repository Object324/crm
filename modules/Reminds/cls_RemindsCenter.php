<?php
 crm_load_class_file('RemindsQueryGenerator','include/QueryGenerator');
class cls_RemindsCenter
{
    public $module = 'Reminds';
    public $customView;
    public $queryGenerator;
    public $focus;
    public $controller_arr;
    protected $pagenum = 1; // 当前页数
    public $list_max_entries_per_page_new = 1; // 最大条数
    public $noofrows_arr = []; // 总条数数组，一维为分类id，二维为"未读""已读"
    public $searchinfos = []; // 基础查找,高级查找信息条件等
    public function __construct(){
        global $current_user;

        crm_load_class_file("RemindsCustomView",'modules/Reminds');
        $this->customView = new RemindsCustomView();
        $this->focus = CRMEntity::getInstance($this->module);
        //wym 231221 XUQIU1002380 列表显示条数可按成员设置不同的条数
        $this->list_max_entries_per_page_new=getUsersettingByLabel($this->module,$current_user->id,'MaxEntriesPerPageByuser')??getUsersettingByLabel($this->module,1,'MaxEntriesPerPage');
        $this->list_max_entries_per_page_new=empty($list_max_entries_per_page_new)?'20':$list_max_entries_per_page_new;
	}
    public function __destruct(){

    }
    /**
     * 获取分类
     */
    public function getDataCategory(){
        global $adb,$current_user;
        $customView = $this->customView;
        $customView_arr = $customView->getCustomView_RemindsCategory();
        $remindscategory_arr = [];
        foreach ($customView_arr as $index => $viewinfo) {
            if($viewinfo['customcategory'] == 'RemindsCategory'){
                $remindscategory_arr[$index]['remindscategoryid'] = $viewinfo['cvid'];
                $remindscategory_arr[$index]['viewname'] = $viewinfo['viewname'];
                $remindscategory_arr[$index]['icon_path'] = empty($viewinfo['icon_path'])?'themes/icon2024/remindscategory-default.png':$viewinfo['icon_path'];
                $unread_cvid = getRemindsCvid('unread');// '未读'的cvid
                $this->getEntireListSql($viewinfo['cvid'],$unread_cvid);
                $remindscategory_arr[$index]['newreminds_num'] = $this->noofrows_arr[$viewinfo['cvid']][$unread_cvid];// 获取每个分类中的未读条数
            }
        }
        // dump($customView_arr);
        return $remindscategory_arr;
    }
    /**
     * 增加分类的高级条件到queryGenerator中
     */
    public function addDataCategoryConditions($categoryid){
        $input = $this->getDataCategoryConditions($categoryid);
        $this->queryGenerator->addUserSearchConditions($input);
    }

    public function getDataCategoryConditions($categoryid){
        // 新消息分类，组成sql条件
        $input = [];
        $advft_criteria = [];
        $advft_criteria_groups = [null];
        $advfilter = $this->customView->getAdvFilterByCvid($categoryid);
        
        // 将高级查询条件转换为Json格式
        foreach ($advfilter as $groupid => &$adv) {
            foreach ($adv['columns'] as $index => &$tmpinfo) {
                $tmpinfo = array_merge(['groupid' => $groupid],$tmpinfo);
                $tmpinfo['columncondition'] = $tmpinfo['column_condition'];
                unset($tmpinfo['column_condition']);
                $advft_criteria[] = $tmpinfo;
            }
            $advft_criteria_groups[] = ["groupcondition" => $adv['condition']];
        }
        $input['searchtype'] = 'advance';
        $input['advft_criteria'] = ldcrm_json_encode($advft_criteria);
        $input['advft_criteria_groups'] = ldcrm_json_encode($advft_criteria_groups);
        
        return $input;
    }
    /**
     * 根据分类id,页签id,获取到总条数sql
     */
    public function getEntireListSql($categoryid,$viewid){
        global $adb,$current_user;
        // $customView = $this->customView;
        $customviewinfoobj=new CustomViewInfo();
        $customviewinfoobj->setCvid($viewid);
        $this->customView->setViewInfoObj($customviewinfoobj);
        $queryGenerator = new RemindsQueryGenerator($this->module, $current_user,$this->customView);


        $input = $this->getDataCategoryConditions($categoryid);

        $queryGenerator->addUserSearchConditions($input);

        // 添加基础查找,高级查找条件
        if(!empty($this->searchinfos)){
            $queryGenerator->addUserSearchConditions($this->searchinfos);
        }
        // dump($this->searchinfos);

        // 通过成员变量传入"未读""已读"
        $queryGenerator->reminds_viewname = $viewid;

        // 得到对应视图的查询字段
        if ($viewid != "0") {
            $queryGenerator->initForCustomViewById($viewid);
        } else {
            $queryGenerator->initForDefaultCustomView();
        }
        $page_list_query=$queryGenerator->getQuery();

        $count_result = $adb->query($page_list_query);

        if(!empty($count_result))
            $noofrows = $adb->num_rows($count_result);
        else 
            $noofrows = null;

        $this->noofrows_arr[$categoryid][$viewid] = $noofrows;// 记录指定分类下指定页签下的总条数
        // $this->page_list_query_arr[$categoryid][$viewid] = $page_list_query;

        $list_query = $queryGenerator->getQuery('',2);

        $list_query = $list_query." inner join ($page_list_query ) as tmp on tmp.remindsid=ld_reminds.remindsid";
        $where = $queryGenerator->getConditionalWhere();
        // list($list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($list_query);
        $list_query .= ' ORDER BY ld_reminds.date_time desc, '.$this->focus->table_name.'.'.$this->focus->table_index." desc ";

        $this->controller_arr[$categoryid][$viewid] = new ListViewController($adb, $current_user, $queryGenerator);

        // dump($list_query);
        return $list_query;
    }
    /**
     * 设置页数
     */
    public function setPagenum($pagenum){
        $this->pagenum = $pagenum;
    }
    /**
     * 根据分页获取列表
     */
    public function getListByPagenum($categoryid,$viewid){
        global $adb,$current_user;
        $list_query = $this->getEntireListSql($categoryid,$viewid);

        $start = $this->pagenum;

        $limit_start_rec = ($start-1) * $this->list_max_entries_per_page_new;

        $list_result = $adb->pquery($list_query. " LIMIT $limit_start_rec, $this->list_max_entries_per_page_new", array());
        $num_rows = $adb->num_rows($list_result);
        $list_arr = [];
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $list = [];
                $remindsid = $adb->query_result($list_result,$i,'remindsid');
                $list['content'] = $adb->query_result($list_result,$i,'content');
                $reltab = $adb->query_result($list_result,$i,'reltab');
                $list['reltab'] = $reltab;
                $related_to = $adb->query_result($list_result,$i,'related_to');
                $list['related_to'] = $this->getHyperlinkHtml($reltab,$related_to,$remindsid);
                $list['date_time'] = $adb->query_result($list_result,$i,'date_time');
                $smcreatorid = $adb->query_result($list_result,$i,'smcreatorid');// 发送人
                if (!empty($smcreatorid) && $smcreatorid > 0) {
                    $list['creator'] = getUserFullName($smcreatorid);
                }else{
                    $list['creator'] = 'System';
                }
                $list['remindsid'] = $adb->query_result($list_result,$i,'remindsid');
                $status_rmd = $adb->query_result($list_result,$i,'status_rmd');
                if($status_rmd == '未读' && $viewid != 115){
                    $list['status'] = 'unread';
                }else{
                    $list['status'] = 'readen';
                }
                $list_arr[] = $list;
            }
        }
        // dump($list_result);
        return $list_arr;
    }
    //根据crmid获取超链接
    protected function getHyperlinkHtml($module,$crmid,$remindsid){
    	global $adb,$current_user;

        if(empty($crmid)){
            return '';
        }
        $fieldinfo = $this->focus->fieldobj->getFieldInfoobjBykey("fieldname",'related_to');
        if($fieldinfo && !empty($fieldinfo)){
            $tmp_label = $fieldinfo->getfieldLabel();
        }

        if($module == 'Users'){
            $hyperlink_value = getUserFullName($crmid);
            $hyperlink_value_title = '';
        }
        else if($module == 'WorkReportList' || $module == 'CooperativeWork'){
            $hyperlink_html = $tmp_label.'：'.getRelatedtoValue($remindsid,$module,$crmid,'link');
            return $hyperlink_html;
        }
        else{
            $hyperlink_value = getModuleHref($module,$crmid);
            $hyperlink_value_title = $hyperlink_value;
        }

        if(!empty($hyperlink_value)){
            $hyperlink_html = $tmp_label.'：<a fieldname="related_to" module="'.$module.'" record="'.$crmid.'" href="javascript:;"  onclick="ListLinkClick(ld(this),event)" title="'.$hyperlink_value_title.'">'.$hyperlink_value.'</a>';
        }else{
            $hyperlink_html = $hyperlink_value;
        }

        return $hyperlink_html;
    }
    /**
     * 增加基本查找, 高级查找的条件
     */
    public function setSearchConditions($inputs){
        $searchinfos = [];
        if(!empty($inputs)){
            if($inputs['searchtype'] == 'BasicSearch'){
                $inputs['search_text'] = trim($inputs['search_text']);
                $searcharr = explode(':',$inputs['search_field']);
                //18399: 回款计划、付款计划、收款单、付款单、费用报销单、佣金单、提现单、存现单-序列表界面：基本查找，按照金额等于0查找，结果基本查找区块会自动收起
                if($inputs['search_text']!='' || (empty($inputs['search_text']) && 'D' == $searcharr[count($searcharr)-1])){
                    $searchinfos['search_field'] = trim($inputs['search_field']);
                    $searchinfos['search_text'] = trim($inputs['search_text']);
                    $searchinfos['SearchScope'] = trim($inputs['SearchScope']);
                    $searchinfos['searchtype'] = trim($inputs['searchtype']);
                }else{
                    // unset($_SESSION['LiveViewSearch'][$currentModule]);
                }
                if($inputs['search_field'] == 'all'){
                    $searchinfos['search_field_arr'] = $inputs['search_field_arr'];
                }
            }else if($inputs['searchtype'] == 'advance'){
                $inputs['advft_criteria'] = trim($inputs['advft_criteria']);
                if(!empty($inputs['advft_criteria']) && $inputs['advft_criteria'] != '[]'){
                    $searchinfos['advft_criteria'] = $inputs['advft_criteria'];
                    $searchinfos['advft_criteria_groups'] = trim($inputs['advft_criteria_groups']);
                    $searchinfos['SearchScope'] = trim($inputs['SearchScope']);
                    $searchinfos['searchtype'] = trim($inputs['searchtype']);
                }else{
                    // unset($_SESSION['LiveViewSearch'][$currentModule]);
                }
            }
            $searchinfos['searchfrom'] = $inputs['searchfrom'];
        }
        $this->searchinfos = $searchinfos;
    }

    // 全部设为"已读"/"未读"
    public function setAllReadStatus($remindscategoryid, $status){
        global $adb,$current_user;

        $this->queryGenerator = new RemindsQueryGenerator($this->module, $current_user,$this->customView);
        if($status == 'setunread'){
            $this->queryGenerator->reminds_viewname = getRemindsCvid('readen');
            $status_rmd = '未读';
        }else{
            $this->queryGenerator->reminds_viewname = getRemindsCvid('unread');
            $status_rmd = '已读';
        }
        $this->addDataCategoryConditions($remindscategoryid);// 增加分类条件
        $this->queryGenerator->addUserSearchConditions($this->searchinfos);
        $select_sql = $this->queryGenerator->getQuery();
        // dump($select_sql);
        $update_sql1="UPDATE ld_reminds INNER JOIN( $select_sql ) as tmp on tmp.remindsid = ld_reminds.remindsid set status_rmd = ? ";
        $update_sql2="UPDATE ld_reminds_accepted INNER JOIN( $select_sql ) as tmp on tmp.remindsid = ld_reminds_accepted.remindsid set status_rmd = ? ";
        $adb->pquery($update_sql1,array($status_rmd));
        $adb->pquery($update_sql2,array($status_rmd));
    }
}