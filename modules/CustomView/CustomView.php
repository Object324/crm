<?php
global $calpath;
global $theme;
$theme_path = "themes/" . $theme . "/";
$image_path = $theme_path . "images/";
global $adv_filter_options;
$adv_filter_options = array("e" => "" . $arrFixedLabel['EQ']. "",
    "n" => "" . $arrFixedLabel['NEQ'] . "",
    "s" => "" . $arrFixedLabel['Begins'] . "",
    "ew" => "" . $arrFixedLabel['Ends'] . "",
    "c" => "" . $arrFixedLabel['IN'] . "",
    "k" => "" . $arrFixedLabel['NOT_IN'] . "",
    "l" => "" . $arrFixedLabel['LT'] . "",
    "g" => "" . $arrFixedLabel['GT'] . "",
    "m" => "" . $arrFixedLabel['LE'] . "",
    "h" => "" . $arrFixedLabel['GE'] . "",
    "b" => "" . $arrFixedLabel['Before'] . "",
    "a" => "" . $arrFixedLabel['After'] . "",
    "bw" => "" . $arrFixedLabel['Interval'] . "",
);
class CustomViewInfo{


    private $cvid=0;
    private $viewname='';
    private $cvcolumnslist=[];
    public  function setCvid($cvid)
    {
        $this->cvid=$cvid;
    }
    public function getCvid():int{

        return $this->cvid;

    }
}
class CustomView extends CRMEntity {
    var $module_list = Array();
    var $smownerid;
    var $cvlist_arr;
    public $customviewmodule;
    var $list_fields;
    var $list_fields_name;
    var $setdefaultviewid;
    var $escapemodule;
    var $mandatoryvalues = [];
    var $showvalues = [];
    var $data_type;
    var $pageWidthPercent;//页面宽度百分比
    // Information as defined for this instance in the database table.
    protected $_status = false;
    protected $_userid = false;
    protected $meta;
    protected $moduleMetaInfo;
    public    $cvid;
    public $orderby_tables=array();//排序表
    public $cachemodulelistview;
    public $focus;
    private static $_instance;//单例对象  editor:gyq_27 date:20170410 reason:静态变量名与CRMEntity冲突
    public $advfiltertablename="ld_cvadvfilter";
    public $advfiltergrouptablename="ld_cvadvfilter_grouping";
    public $maintableIndexname="cvid";
    public $related_tableIndexname="cvid";
    public $maintablename="ld_customview";
    public $tab_index=array("ld_customview"=>"cvid","ld_cvadvfilter"=>"cvid","ld_cvadvfilter_grouping"=>"cvid");
    public $cachetype="customview";
    public $advfilter_arr;
    public $relatedfldarray = [];
    public $public_account;
    protected    $viewinfoobj;
    protected    $tablename_arr;
    protected    $advance_search;
    protected    $groupcodition;
    public function __construct($module = "") {
        global $current_user, $adb;
        $this->customviewmodule = $module;
        $this->escapemodule[] = $module . '_';
        $this->escapemodule[] = '_';
        $this->smownerid = $current_user->id;
        $this->moduleMetaInfo = array();
        $this->pageWidthPercent="100";
        $this->viewinfoobj=new CustomViewInfo();
        $this->focus=CRMEntity::getInstance($module);
        if($module == 'Accounts')
        {
            crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
            $cls_PublicAccounts = new cls_PublicAccounts($module);
            $this->public_account = $cls_PublicAccounts->getPublicAccount();
        }
        else if($module == 'Leads')
        {
            crm_load_class_file('cls_PublicLeads', 'modules/Leads');
            $cls_PublicAccounts = new cls_PublicLeads($module);
            $this->public_account = $cls_PublicAccounts->getPublicAccount();
        }

    }
    function getStdFilterByCvid()
    {

    }

    public function setViewInfoObj(  $viewinfoobj)
    {
        $this->viewinfoobj=$viewinfoobj;

    }
    public function getViewInfoObj(){

        return $this->viewinfoobj;

    }
    /**
     * 防止被克隆
     * @author Tujt 2015-05-26
     */
    private function __clone(){}
    /**
     * 单例初始化类对象
     * @author Tujt 2015-05-26
     */
    public static function getInstance($module = ''){
        if(FALSE == (self::$_instance[$module] instanceof self)){
            self::$_instance[$module] = new self($module);

        }
        return self::$_instance[$module];
    }

    /**
     *
     * @param String:ModuleName $module
     * @return EntityMeta
     */
    private function getOtherModuleViewid()
    {
        global $current_user;
        $cvlist=$this->getCvlistByUser();//获取当前用户所能看见的数据分类
        if(!empty($cvlist)){
            foreach($cvlist as $cvrow){
                if($cvrow['defaultuserid']==$current_user->id) {

                    $viewid=$cvrow['cvid'];
                    break;
                }else if($cvrow['setdefault']==1){

                    $viewid=$cvrow['cvid'];
                    break;
                }
            }
            if(empty($viewid)){
                $key_cvid=array_keys($cvlist);//数据分类键值数组
                $viewid=$key_cvid[0];//获取第一个数据分类
            }
        }
        return $viewid;
    }
    /**
     * edit:can
     * reason:获取客户的数据分类
     * */

    private function getAccoutViewid($popup='')
    {
        global $current_user;
        if(!empty($_SESSION['lvsAccount'][$this->customviewmodule]['pagepublicaccounttype'])){
            $publicaccounttype = $_SESSION['lvsAccount'][$this->customviewmodule]['pagepublicaccounttype'];
        }elseif(!empty($_REQUEST['accounttype'])){
            $publicaccounttype=$_REQUEST['accounttype'];
        }

        if(empty($publicaccounttype)){
            if($this->customviewmodule=='Accounts')
            {
                crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
                $cls_PublicAccounts = new cls_PublicAccounts($this->customviewmodule);
            }
            else if($this->customviewmodule=='Leads') {
                crm_load_class_file('cls_Public'.$this->customviewmodule, 'modules/'.$this->customviewmodule);
                $str="cls_Public".$this->customviewmodule;
                $cls_PublicAccounts = new $str($this->customviewmodule);
            }
            $public_account = $cls_PublicAccounts->getPublicAccount();
            if($public_account['status'] == 'yes' && $public_account['show_publicaccount_tab'] == 'yes' && $public_account['default_publicaccount_tab'] == 'yes'){

                $publicaccounttype='ALLACCOUNT';//显示并且默认 “全部（含所有公海）”页签

            }else{

                $publicaccounttype='DEFAULTALLACCOUNT';//全部（含指定公海）
            }
        }
        if($publicaccounttype == 'COMMONACCOUNT'){
            $publicaccounttype = 'ALLACCOUNT';
        }
        $cvlist=$this->getCvlistByUser($popup);//获取当前用户所能看见的数据分类
        $viewid=0;
        if(!empty($cvlist)){
            foreach($cvlist as $cvrow)
            {
                if($cvrow['customcategory']==$publicaccounttype)
                {
                    if($cvrow['defaultuserid']==$current_user->id)
                    {
                        $viewid=$cvrow['cvid'];
                        break;
                    }
                    else if($cvrow['setdefault']==1)
                    {
                        $viewid=$cvrow['cvid'];

                    }
                }
            }
        }
        if(empty($viewid) && !empty($cvlist))
        {
            $key_cvid=array_keys($cvlist);//数据分类键值数组
            $viewid=$key_cvid[0];//获取第一个数据分类

        }
        return $viewid;
    }
    function getCustomViewSessionName($module,$popup='')
    {
        $sessionkeys=array('lvs',$module,'viewname');
        $viewname=getSession($sessionkeys);
        //edit:duan reason:销售线索未启用公海时，数据分类错误
        if($this->public_account['status'] == 'yes'&&($module=='Accounts'||$module=='Leads'))
        {
            $sessionkeys=array('lvsAccount',$module,'pagepublicaccounttype');
            $pagepublicaccounttype=getSession($sessionkeys);

            if($viewname!="")
                $SessionViewname=$viewname;
            if(!empty($pagepublicaccounttype))
            {
                $publicaccounttype  = $pagepublicaccounttype;
            }
            if($popup!='')
            {

                $publicaccounttype='ALLACCOUNT';//客户弹出框窗口的数据分类为全部也签
            }
            //chj 2021/6/22 46490: （http://xiaoshou360.com/KH/kingsole [^]）客户问题（宜昌市金石），“全部（不含公海）”页签，数据分类选“60天在谈”的有121条单据导出时显示2291行导出，数据分类选择“90天已成交”的有959条单据导出时也显示2291行。
            if($publicaccounttype == 'COMMONACCOUNT'){
                $publicaccounttype = 'ALLACCOUNT';
            }

            $sessionkeys=array('lvs',$module ,$publicaccounttype,"viewname");
            $viewname=getSession($sessionkeys);
        }
        return $viewname;
    }
    /** To get the customViewId of the specified module
     * @param $module -- The module Name:: Type String
     * @returns  customViewId :: Type Integer
     */
    function getViewId($module,$popup='') {

        static $module_viewid_popup;
        $statickey = 'module_viewid_popup_'.$module.$popup;
        if(!empty($module_viewid_popup) && isset($module_viewid_popup[$statickey]))
            return $module_viewid_popup[$statickey];
        global $adb, $current_user;
        $now_action = vtlib_purify($_REQUEST['action']);
        global $related_left_type;
        if(!empty($related_left_type)){
            $now_action = $this->customviewmodule.'Ajax';
        }
        if($module == 'Calendar')
            $module = 'Events';

        $cvlist=$this->getCvlistByUser($popup);//获取当前用户所能看见的数据分类

        if (empty($_REQUEST['viewname'])) {
            //edit:can reason:11921: 提醒序时簿：在【已读】、【发件箱】查看范围中选择“我的”，结果页签被切换到【未读】
            $viewname=$this->getCustomViewSessionName($module,$popup);
            if(($module=='Accounts'||$module=='Leads')&&$viewname!="")
            {
                $SessionViewname=$viewname;

            }
            //ls 2021-11-30 客户模块的链接模块，批量共享时弹框错误（getSelectedRecords()结果集不对-》因为数据分类的条件没有加上-》因为viewid没值导致最后使用的是数据分类第一个“全部”）
            if (($module=='Accounts'||$module=='Leads')&&$viewname=="" && $this->public_account['status'] != 'yes') {
                $sessionkeys=array('lvs',$module ,'ALLACCOUNT',"viewname");
                $viewname = getSession($sessionkeys);
            }
            if (isset($viewname) &&$viewname != '') {
                $viewid = $viewname;

                if($module == 'Accounts'||$module=='Leads')
                {

                    $publicaccounttype  = $pagepublicaccounttype;

                    //获取上次一的分类ID
                    if(isset($publicaccounttype))
                    {
                        //启用公海
                        if($this->public_account['status'] == 'yes')
                            $viewid = $viewname;
                        else
                        {

                            $sessionkeys=array('lvs',$module ,'ALLACCOUNT',"viewname");

                            $viewid = getSession($sessionkeys);
                        }

                    }
                    if(!isset($cvlist[$viewid]) && $module!='Reminds')//如果获取的viewid不在当前用户所能看见的数据分类列表中
                    {
                        $viewid=$this->getAccoutViewid($popup);

                    }
                }
                else if(!isset($cvlist[$viewid]) && $module!='Reminds')
                {


                    //15077: 日程管理-叙事簿：删除数据分类后，没有选中默认分类“全部”-如图,edit:can
                    $viewid=$this->getOtherModuleViewid();

                }
            }
            else if ($this->setdefaultviewid != "") {
                //36679: （http://kehu001.com/KH/kh32777 [^]）客户列表界面>分类选择“成交客户”>导出>选择导出搜索结果：把所有的单据都导出来了，而不是到出该分类中的单据。（1.6也存在该问题）
                //产生的步骤，1：设置全部为默认的数据分类（一定要是全部为默认的数据分类),2:选择一个其他数据分类，3：导出
                $viewid = $this->setdefaultviewid;

            }
            else {

                if ($module!='Accounts'&&$module!='Leads')
                {

                    $viewid=$this->getOtherModuleViewid();

                }
                else
                {
                    $viewid=$this->getAccoutViewid($popup);

                }

            }

            if(empty($viewid))
            {
                $viewid = $this->getViewIdByName('All', $module);
            }
        } else {
            $viewname = vtlib_purify($_REQUEST['viewname']);
            $viewid = $viewname;

            if($module == 'Accounts'&&$_REQUEST['keyviewname'])//关键视图
            {
                $viewname=$_REQUEST['keyviewname'];
                $sessionkeys=array('lvsAccount',$module,'pagepublicaccounttype');
                $publicaccounttype  = getSession($sessionkeys);
                if($publicaccounttype!="")
                {
                    $sessionkeys=array('lvsAccount',$module,$publicaccounttype,'viewname');

                    setSession($sessionkeys,$viewname);

                }
            }

            if (!is_numeric($viewname)) {
                if (strtolower($viewname) == 'all' || $viewname == 0)
                {

                    $viewid = $this->getViewIdByName('All', $module);
                }
                else
                {

                    $viewid = $this->getViewIdByName($viewname, $module);
                }
            } else {
                global $current_user;
                //edit:can  reason:11804: 客户查看界面，编辑相关信息中的单据保存后，点击返回列表，结果客户序时簿界面数据分类没有选中全部
                // $sql='select entitytype from ld_customview where cvid=? and entitytype=?';
                // $viewresult=$adb->pquery($sql,array($viewid,$module));

                if(!isset($cvlist[$viewid]))
                {
                    if($module=="Accounts")
                    {
                        //edit chj date 2020/11/30 43329: （61mis.com/kfbcrm）客户管理-客户-数据分类（需要补丁）；以客户模块为例，选择分类“有跟进”进行筛选，然后在管理分类中删除该分类并保存；页面会因为没有“有跟进”分类而排版错乱
                        /* $publicaccounttype='ALLACCOUNT';
                        if(isset($_SESSION['lvsAccount'][$module]['pagepublicaccounttype']))
                        {
                          $publicaccounttype  = $_SESSION['lvsAccount'][$module]['pagepublicaccounttype'];
                        }
                       if(!empty($_SESSION['lvs'][$module .'_'.$publicaccounttype]["viewname"]))
                              $viewid=$_SESSION['lvs'][$module .'_'.$publicaccounttype]["viewname"];*/
                        $viewid=$this->getAccoutViewid($popup);
                    }
                    else if(isset($_SESSION['lvs'][$module]['viewname']))
                    {
                        $viewid=$_SESSION['lvs'][$module]['viewname'];
                    }

                }



            }

        }

        if($module == 'Accounts' || $module == 'Leads')
        {
            $publicaccounttype='ALLACCOUNT';
            if(isset($_SESSION['lvsAccount'][$module]['pagepublicaccounttype']))
            {
                $publicaccounttype  = $_SESSION['lvsAccount'][$module]['pagepublicaccounttype'];
            }
            if($publicaccounttype == 'COMMONACCOUNT'){
                $publicaccounttype = 'ALLACCOUNT';
            }
            //chj 2021/2/20 先进入数据分类创建的链接模块中，再返回对应模块的界面，数据分类没有发生改变（详情见附件）
            if('ld_linkmodulecustom' != $_REQUEST['ajaxtype'])
                $_SESSION['lvs'][$module][$publicaccounttype]["viewname"]= $viewid;

        }
        else{
            if('ld_linkmodulecustom' != $_REQUEST['ajaxtype'])
                $_SESSION['lvs'][$module]["viewname"] = $viewid;
        }
        $this->cvid=$viewid;

        return $module_viewid_popup[$statickey] = $viewid;
    }

    public function getOrderWhere($query,$setype='',$queryGenerator=''){
        crm_load_class_file('CustomView_Sort','modules/CustomView');

        $sortobj=CustomView_Sort::getInstance($this,$this->customviewmodule);
        return $sortobj->getOrderWhere($this->focus,$query,$setype,$queryGenerator);


    }
    function getViewIdByName($viewname, $module) {
        global $adb;
        if (isset($viewname)) {
            $query = "select cvid from ld_customview where viewname=? and entitytype=?";
            $cvresult = $adb->pquery($query, array($viewname, $module));

            $viewid = $adb->query_result($cvresult, 0, 'cvid');
            return $viewid;
        } else {
            return 0;
        }
    }

    /**
     * 获取当前用户所能看见的视图（数据分类)
     * */
    private function getCvlistByUser($popup='')
    {
        global $adb, $current_user;
        global $app_strings;
        $pagepublicaccounttype='';
        $pool_id = 0;	//公海池
        /*static $static_cvlist_arr;
        if(is_array($static_cvlist_arr)&&isset($static_cvlist_arr[$this->customviewmodule]))
        {
            return $static_cvlist_arr[$this->customviewmodule];
        }
        else if(!is_array($static_cvlist_arr))
        {
            $static_cvlist_arr=[];
        }*/
        if(is_array($this->cvlist_arr)&&!empty($this->cvlist_arr))
        {
            return $this->cvlist_arr;
        }
        if(($this->customviewmodule == 'Accounts'||$this->customviewmodule == 'Leads')&&$popup!='')//如果是客户弹出框则读取全部页签的数据分类
        {
            $pagepublicaccounttype='ALLACCOUNT';
        }

        else if(isset($_REQUEST['accounttype'])){
            $pagepublicaccounttype = $_REQUEST['accounttype'];
        }
        else  if(  $_SESSION['lvsAccount'][$this->customviewmodule]['pagepublicaccounttype'])
        {
            //公司合并列表空白
            $accounttype_arr=['ALLACCOUNT','DEFAULTALLACCOUNT','COMMONACCOUNT','PUBLICALLOCATE','NOALLOCATE','ALLPUBLICACCOUNT'];
            $pagepublicaccounttype=$_SESSION['lvsAccount'][$this->customviewmodule]['pagepublicaccounttype'];
            if(!in_array($pagepublicaccounttype,$accounttype_arr))
            {
                if(isset($_REQUEST['accounttype'])){
                    $pagepublicaccounttype = $_REQUEST['accounttype'];
                }
            }
        }
        elseif ($this->customviewmodule == 'WorkReportList') {
            if (!isset($_SESSION['lvs'][$this->customviewmodule]['workreport_logtype'])) {
                $_SESSION['lvs'][$this->customviewmodule]['workreport_logtype'] = '0';//初始默认分类
            }
        }

        if($pagepublicaccounttype == 'COMMONACCOUNT'){
            $pagepublicaccounttype = 'ALLACCOUNT';
        }
        //chj 2021/5/31 切换公海池，回到全部公海页签时，数据分类为空
        if(in_array($pagepublicaccounttype,array('NOALLOCATE','PUBLICALLOCATE','ALLPUBLICACCOUNT'))){
            if(!empty($_REQUEST['pool_id'])){
                $pool_id = $_REQUEST['pool_id'];
            }else if(!empty($_SESSION['lvsAccount'][$this->customviewmodule]['pool_id'])){
                $pool_id = $_SESSION['lvsAccount'][$this->customviewmodule]['pool_id'];
            }
        }
        $cachekey = 'getCustomViewCombo2_'.$this->customviewmodule.'getCustomViewCombo2_'.$current_user->id.'_'.$pagepublicaccounttype.'_'.$pool_id ;
        $cachemodulelistview = CacheDirectory($cachekey,'customview');
        // if($cachemodulelistview) return $cachemodulelistview;
        if(!is_array($cachemodulelistview))
        {
            //edit:can 2020-10-23 42998: （8.2.7PHP7+Redis安装包）客户单据查看详情界面，相关信息->联系人/跟进记录/合同订单等列表界面，没有显示“数据分类”和“高级查找”功能
            $cachemodulelistview=array();
        }

        $tabid = getTabid($this->customviewmodule);
        $user_info= getuserInfoByPrivileges($current_user);

        $is_admin=is_admin($current_user);

        $selected = 'selected';
        if ($markselected == false)
            $selected = '';
//@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
        $ssql = "select ld_user_module_preferences.userid as defaultuserid,ld_customview.userid,ld_customview.cvid
                        ,ld_customview.viewname,ld_customview.status, ld_customview.setdefault,ld_customview.setmetrics
                        ,ld_customview.customcategory,ld_customview.icon_path
                        ,ld_users.last_name,ld_user_module_preferences.default_cvid
                        ,ld_customview.pool_id,ld_user_module_preferences.pool_id as user_pool_id,ld_user_module_preferences.customcategory
                        as user_customcategory,ld_user_module_preferences.userid as user_preferencesid,ld_customview.groupid from ld_customview inner join ld_tab
                         on ld_tab.name = ld_customview.entitytype
					left join ld_users on ld_customview.userid = ld_users.id 
                    left join (select default_cvid,userid,pool_id, customcategory from ld_user_module_preferences  where tabid=? and userid=?) as ld_user_module_preferences
                    on ld_user_module_preferences.default_cvid=ld_customview.cvid";
        $ssql .= " where ld_tab.tabid=?";


        $sparams = array($tabid,$current_user->id,$tabid );


        //【全部客户】、【公海已分配】、【公海未分配】页签的数据分类分开
        //$_REQUEST['fromModule'] 判断客户弹出层，如果不为空，则只显示全部(含公海)页签下的所有分类
        if($this->customviewmodule == 'Accounts'||$this->customviewmodule == 'Leads')
        {
            if($this->public_account['status'] == 'yes' && !isset($_REQUEST['fromModule']) && !empty($pool_id))
            {
                if($pagepublicaccounttype == 'DEFAULTALLACCOUNT' || $pagepublicaccounttype == 'COMMONACCOUNT'){
                    $pagepublicaccounttype = 'ALLACCOUNT';
                }

                if(!empty($pagepublicaccounttype)){
                    $ssql .= " and ld_customview.customcategory = '".$pagepublicaccounttype."'";
                    // $ssql.=" and ld_user_module_preferences.customcategory = '".$pagepublicaccounttype."'";
                }
                if(!empty($pool_id)){
                    $ssql .= " and ld_customview.pool_id = '".$pool_id."'";
                    //  $ssql .= " and ld_user_module_preferences.pool_id = '".$pool_id."'";
                }

            }
            else
            {

                //不启用公海分类用，默认显示全部(含公海)分类

                $ssql .= " and ld_customview.customcategory ='ALLACCOUNT'";

            }

        } elseif ($this->customviewmodule == 'WorkReportList') {
            //ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(页签视图处理)
            $ssql .= " and ld_customview.customcategory = '".$_SESSION['lvs'][$this->customviewmodule]['workreport_logtype']."'";
        }
        //or ld_customview.userid in(select ld_user2role.userid from ld_user2role inner join ld_users on ld_users.id=ld_user2role.userid inner join ld_role on ld_role.roleid=ld_user2role.roleid where ld_role.parentrole like '" . $current_user_parent_role_seq . "::%')
//		if ($is_admin == false) {
        $ssql .= " and (ld_customview.status=0 or ld_customview.userid = ? or ld_customview.status = 3 )";//非管理员用户将数据分类没有设为公开的默认分类管理员也不应该显示
        array_push($sparams, $current_user->id);
//		}
        $ssql .= " ORDER BY sequence";
        $module_user_default_cvid=0;
        $result = $adb->pquery($ssql, $sparams);

        while ($cvrow = $adb->fetch_array($result))
        {
            if($cvrow['default_cvid'] > 0)
            {
                $module_user_default_cvid = $cvrow['cvid'];
                break;
            }
        }
        if(!$cachemodulelistview)
        {

            $result = $adb->pquery($ssql, $sparams);
            while ($cvrow = $adb->fetch_array($result))
            {

                if($cvrow['setdefault']==1)
                {
                    $this->setdefaultviewid=$cvrow['cvid'];
                }
                //duan 2022-5-9 数据分录名称增加特殊字符转义
                $cvrow['viewname'] = html_entity_decode($cvrow['viewname']);
                $cachemodulelistview[$cvrow['cvid']]=$cvrow;
            }
        }
        else
        {
            foreach($cachemodulelistview as $index=>$content)
            {
                if($content['cvid']==$module_user_default_cvid)
                {
                    $cachemodulelistview[$content['cvid']]['defaultuserid'] = 1;
                    $cachemodulelistview[$content['cvid']]['setdefault'] = 1;
                    $this->setdefaultviewid=$content['cvid'];
                }else{

                    $cachemodulelistview[$content['cvid']]['defaultuserid'] = 0;
                    $cachemodulelistview[$content['cvid']]['setdefault'] = 0;
                }
            }
        }

        if(!empty($module_user_default_cvid))
        {
            //edit:can  20220808  54439：查询分类：每个用户登陆系统时显示自己设置“自定义显示默认分类”
            $this->setdefaultviewid=$module_user_default_cvid;
        }
        $this->cvlist_arr=$cachemodulelistview;
        //	CacheDirectory($cachekey,'customview',$cachemodulelistview);
        // $static_cvlist_arr[$this->customviewmodule]=$this->cvlist_arr;
        return $cachemodulelistview;
    }

    function getCvListByModule()
    {
        $this->cachemodulelistview = $this->getCvlistByUser($popup);
        foreach($this->cachemodulelistview as $cvid=>$content)
        {
            $this->cachemodulelistview[$cvid]['edit_permit']= $this->isPermittedCustomView($cvid,"EditView",$this->customviewmodule);
            $this->cachemodulelistview[$cvid]['del_permit']=$this->isPermittedCustomView($cvid,"Delete",$this->customviewmodule);
        }

        return $this->cachemodulelistview;
    }
    //获取所有数据分类
    function getCustomViewAll($viewid='' ,$thismodulename='', $markselected = true, $popup=''){
        global $adb, $current_user,$relationId;
        global $app_strings;
        $tabid = getTabid($this->customviewmodule);
        // getuserInfoByPrivileges($current_user);
        //require(globalStatic::$root_directory.'user_privileges/user_privileges_' . $current_user->id . '.php');
        $this->cachemodulelistview = $this->getCvlistByUser($popup);
        //获取用户常用分组
        $commonCustomViewByUser=getUsersettingByLabel($this->customviewmodule,$current_user->id,'CommonGroupForCategory');
        // 将字符串转换为数组
        $commonCustomViewByUserArray=[];
        if(isset($commonCustomViewByUser))
            $commonCustomViewByUserArray = explode(",", $commonCustomViewByUser);
        if(!empty($this->cachemodulelistview)){
            foreach($this->cachemodulelistview as $cvrow){
                $cvrow['viewnamedata'] = $cvrow['viewname'];
                if($cvrow['viewname'] == 'All'){
                    $viewtype = 'All';
                    $cvrow['viewname'] = getFixedLabel('ALL');
                }
                if($this->customviewmodule=='Reminds')
                {
                    if($cvrow['viewname']=='quickSearchAll')
                        continue;
                    if($cvrow['cvid']==108)
                        $cvrow['viewname'] = getFixedLabel('LBL_UNREADEN');
                    elseif($cvrow['cvid']==114)
                        $cvrow['viewname'] = getFixedLabel('LBL_READEN') ;
                    elseif($cvrow['cvid']==115)
                        $cvrow['viewname']=getFixedLabel('LBL_SENDED');
                }
                $cvrow['module']=$thismodulename;
                $cvrow['popup']=$popup;//用来判断是否弹出窗口中数据分类，如选择源单
                //zsk 2024/3/26 XUQIU20240315-02 查询分类：可直接在弹窗处进行拖动排序和对有权限的单个查询分类进行设置
                $cvrow['edit_permit']=$this->isPermittedCustomView($cvrow['cvid'],"EditView",$this->customviewmodule);
                $cvrow['del_permit']=$this->isPermittedCustomView($cvrow['cvid'],"Delete",$this->customviewmodule);
                // 使用in_array函数判断groupid是否在数组中
                if (in_array($cvrow['cvid'], $commonCustomViewByUserArray)) {
                    $cvrow['isCommon']='yes';
                }
                else{
                    $cvrow['isCommon']='no';
                }
                if($popup == 'relatedleft'){//相关信息数据分类查询，需要相关信息ID
                    $cvrow['relationId']=$relationId;//
                    if($this->customviewmodule=='Reminds' && $cvrow['cvid']==115){
                        continue;
                    }
                }
                $cacherow[]=$cvrow;
            }
        }
        return $this->getCustomViewSequenceByGroupid($cacherow);
    }
    //根据分组获取 正确的分类列表
    //hzx 20240722 XUQIU20240520-04 查询分类优化第二版
    function getCustomViewSequenceByGroupid($customview_html){
        $customview_option = [];
        $groupList = $this->getCustomViewGroupList($customview_html);
        if($groupList['cv_all']){
            $customview_option[] = $groupList['cv_all'];
        }
        if(count($groupList['groupList']) > 0){
            foreach ($groupList['groupList'] as $index => $groupinfo){
                if(count($groupinfo['cvList']) > 0){
                    foreach ($groupinfo['cvList'] as $index_cv => $cvinfo){
                        $customview_option[] = $cvinfo;
                    }
                }
            }
        }
        return $customview_option;
    }
    //@edit zsk 2024/06/11 XUQIU20240516-01 查询分类功能优化
    //获取查询分类分组列表
    function getCustomViewGroupList($customview_html){
        global $adb,$current_user;
        $tabid=getTabid($this->customviewmodule);
        if($this->customviewmodule == 'Calendar') $tabid = 9; //BUG20241025-64 ls 241029 日程管理模块，新建分组，保存提示保存成功了，但是查看并没有这个分组
        $viewid=$this->getViewId($this->customviewmodule);
        $sql="select groupid,group_name,entity_type,sequence from ld_customviewgroup
                inner join ld_tab on ld_tab.name = ld_customviewgroup.entity_type
                where ld_tab.tabid=?
                order by ld_customviewgroup.sequence";
        $result = $adb->pquery($sql, array($tabid));
        $num = $adb->num_rows($result);

        $showgroupnum = 0;
        /*$commonCustomViewByUser=getUsersettingByLabel($this->customviewmodule,$current_user->id,'CommonGroupForCategory');
        if(!empty($commonCustomViewByUser))
            $commonCustomViewByUserArray = explode(',',$commonCustomViewByUser);
        else
            $commonCustomViewByUserArray=[];
        $common_list = [];*/
        if($num>0){
            for($i=0;$i<$num;$i++){
                $cvGroupRow['groupid']=$adb->query_result($result,$i,'groupid');

                $cvGroupRow['group_name']=$adb->query_result($result,$i,'group_name');

                $cvGroupRow['entity_type']=$adb->query_result($result,$i,'entity_type');
                $cvGroupRow['sequence']=$adb->query_result($result,$i,'sequence');
                $cvGroupRow['cvCount']=0;
                $cvGroupRow['cvList']=[];
                $ungroup_list=[];
                $ungroup_cvcount=0;
                //$commongroup_cvcount=0;
                foreach($customview_html as $key => $cv){
                    if($cv['cvid']==$viewid){
                        //获取选中的查询分类的groupid
                        $selectedGroupid=$cv['groupid'];
                        //选中的查询分类为未分组的查询分类
                        if(empty($selectedGroupid)){
                            $selectedGroupid='ungrouped';
                        }
                        //选中的查询分类为全部
                        if($cv['viewnamedata']=='All'){
                            $selectedGroupid='ALL';
                        }
                    }
                    // 使用in_array函数判断groupid是否在数组中
                    /*if (in_array($cv['cvid'], $commonCustomViewByUserArray)) {
                        $cv['isCommon']='yes';
                        $commongroup_cvcount++;
                        $common_list[$cv['cvid']] = $cv;
                    }
                    else{
                        $cv['isCommon']='no';
                    }*/
                    //如果为未分组
                    if(empty($cv['groupid'])){
                        if($cv['viewnamedata']=='All'){
                            $customViewGroupList['cv_all']=$cv;
                        }
                        else{
                            $ungroup_cvcount++;
                            $ungroup_list[] = $cv;
                        }

                    }
                    if($cv['groupid'] == $cvGroupRow['groupid']){
                        if($cv['viewnamedata']=='All'){
                            $customViewGroupList['cv_all']=$cv;
                        }
                        else {
                            $cvGroupRow['cvCount']++;
                            $cvGroupRow['cvList'][] = $cv;
                        }
                    }
                }
                $customViewGroupList['groupList'][]=$cvGroupRow;
                if(count($cvGroupRow['cvList']) > 0){
                    $showgroupnum++;
                }

            }
        }
        //没有查询分类分组
        else{
            $ungroup_list=[];
            $ungroup_cvcount=0;
            //$commongroup_cvcount=0;
            foreach($customview_html as $key => $cv){
                if($cv['cvid']==$viewid){
                    //获取选中的查询分类的groupid
                    $selectedGroupid=$cv['groupid'];
                    //选中的查询分类为未分组的查询分类
                    if(empty($selectedGroupid)){
                        $selectedGroupid='ungrouped';
                    }
                    //选中的查询分类为全部
                    if($cv['viewnamedata']=='All'){
                        $selectedGroupid='ALL';
                    }
                }
                // 使用in_array函数判断groupid是否在数组中
                /*if (in_array($cv['cvid'], $commonCustomViewByUserArray)) {
                    $cv['isCommon']='yes';
                    $commongroup_cvcount++;
                    $common_list[$cv['cvid']] = $cv;
                }
                else{
                    $cv['isCommon']='no';
                }*/
                //如果为未分组
                if(empty($cv['groupid'])){
                    if($cv['viewnamedata']=='All'){
                        $customViewGroupList['cv_all']=$cv;
                    }
                    else {
                        $ungroup_cvcount++;
                        $ungroup_list[] = $cv;
                    }
                }
            }
        }
        /*$common_list_new= [];
        //将常用分组按照常用分组表的分类id顺序排序
        foreach ($commonCustomViewByUserArray as $index => $cvid) {
            if (isset($common_list[$cvid])) {
                $common_list_new[] = $common_list[$cvid];
            }
        }
        $commonGroup = array(
            'groupid'=>'commonCustomView',
            'group_name'=>getFixedLabel('commongroup'),
            'entity_type'=>$this->customviewmodule,
            'cvCount'=>$commongroup_cvcount,
            'cvList'=>$common_list_new
        );*/
        $ungroup= array(
            'groupid'=>'ungrouped',
            'group_name'=>getFixedLabel('ungrouped'),
            'entity_type'=>$this->customviewmodule,
            'cvCount'=>$ungroup_cvcount,
            'cvList'=>$ungroup_list
        );
        if(count($ungroup_list) > 0){
            $showgroupnum++;
        }
        //$newKeyValuePair=['key1' => $commonGroup];
        $newKeyValuePair2=['key2' => $ungroup];
        if(!empty($customViewGroupList['groupList'])){
            // 使用 array_merge 将新键值对插入到首位
            //$customViewGroupList['groupList'] = array_merge($newKeyValuePair, $customViewGroupList['groupList']);
            $customViewGroupList['groupList'] = array_merge($customViewGroupList['groupList'], $newKeyValuePair2);
            // 使用 array_values 重新索引数组
            $customViewGroupList['groupList'] = array_values($customViewGroupList['groupList']);
            $customViewGroupList['selectedGroupid']=$selectedGroupid;
        }
        //没有自定义分组
        else{
            $customViewGroupList['groupList'] = $newKeyValuePair2;
            // 使用 array_values 重新索引数组
            $customViewGroupList['groupList'] = array_values($customViewGroupList['groupList']);
            $customViewGroupList['selectedGroupid']=$selectedGroupid;
        }
        $customViewGroupList['showgroupnum'] = $showgroupnum;
        return $customViewGroupList;
    }

    function getCustomViewCombo2($viewid='' ,$thismodulename='', $markselected = true, $popup='') {
        global $adb, $current_user;
        global $app_strings;
        $pagepublicaccounttype='';
        //如果是客户弹出框则读取全部页签的数据分类
        if(($this->customviewmodule == 'Accounts'||$this->customviewmodule == 'Leads')&&$popup!=''){
            $pagepublicaccounttype='ALLACCOUNT';
        }

        else if($_SESSION['lvsAccount'][$this->customviewmodule]['pagepublicaccounttype']){
            $pagepublicaccounttype=$_SESSION['lvsAccount'][$this->customviewmodule]['pagepublicaccounttype'];
        }
        $tabid = getTabid($this->customviewmodule);

        $is_admin=is_admin($current_user);
        $shtml_user = '';
        $shtml_pending = '';
        $shtml_public = '';
        $shtml_default='';
        $shtml_others='';

        $selected = 'selected';
        if ($markselected == false)
            $selected = '';

        $this->cachemodulelistview = $this->getCvlistByUser($popup);



        if(!empty($this->cachemodulelistview)){
            foreach($this->cachemodulelistview as $cvrow){
                $cacherow[]=$cvrow;
                $viewtype = '';
                if($cvrow['viewname'] == 'All'){
                    $viewtype = 'All';
                    $cvrow['viewname'] = getFixedLabel('ALL');
                }

                $option = '';
                $viewname = $cvrow['viewname'];
                if ($cvrow['status'] == CV_STATUS_DEFAULT || $cvrow['userid'] == $current_user->id){
                    $disp_viewname = $viewname;
                }else{
                    //$userName = getFullNameFromArray('Users', $cvrow);
                    $disp_viewname = $viewname;
                }

                if ($cvrow['setdefault'] == 1 && $viewid == ''){
                    if($thismodulename=='Emails' || $thismodulename=='MassSMS'){
                        $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"tablink\" onclick=\"getTableViewForFenzu(this,'". $thismodulename ."','".$cvrow['cvid']."','$disp_viewname')\"><a href='javascript:void(0);'  style='color:red;'>" . $disp_viewname . "</a></li>";
                    }
                    else{
                        if($popup=='popup'){
                            $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showDefaultCustomViewPopup(this,'". $thismodulename ."','".$category."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . $disp_viewname . "</a></li>";
                        }
                        else if($popup == 'relatedleft'){
                            /**
                             * 相关信息左右结构
                             * 修改视图切换事件
                             * Tujt 20140331
                             */

                            global $relationId;
                            if($this->customviewmodule=='Reminds')
                            {
                                if($cvrow['cvid']==108)
                                    $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\">11<a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_UNREADEN') . "</a></li>";
                                elseif($cvrow['cvid']==114)
                                    $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\">11<a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_READEN') . "</a></li>";
                                elseif($cvrow['cvid']==115)
                                    $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\">11<a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_SENDED') . "</a></li>";
                            }
                            else
                            {
                                $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\">11<a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . $disp_viewname . "</a></li>";
                            }
                        }
                        else{
                            $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showDefaultCustomView(this,'". $thismodulename ."','".$category."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;'>" . $disp_viewname . "</a></li>";

                        }
                    }
                    $this->setdefaultviewid = $cvrow['cvid'];
                }
                elseif ($cvrow['cvid'] == $viewid){
                    if($thismodulename=='Emails' || $thismodulename=='MassSMS'){
                        $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"currdataClass\" onclick=\"getTableViewForFenzu(this,'". $thismodulename ."','".$cvrow['cvid']."','".$disp_viewname."')\">
                        <a href='javascript:void(0);'>" . $disp_viewname . "</a>
                        </li>";
                    }
                    else{
                        if($popup=='popup'){
                            $option = "
                            <li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"currdataClass\" onclick=\"showDefaultCustomViewPopup(this,'". $thismodulename."','".$category."','".$cvrow['cvid']."')\">
                            <a href='javascript:void(0);' id='".$cvrow['cvid']."popup'>" . $disp_viewname . "</a>
                            </li>";
                        }
                        else if($popup == 'relatedleft'){
                            /**
                             * 相关信息左右结构
                             * 修改视图切换事件
                             * Tujt 20140331
                             */
                            global $relationId;
                            if($this->customviewmodule=='Reminds')
                            {
                                if($cvrow['cvid']==108)
                                    $option = "<li viewtype='".$viewtype."'  class='currdataClass' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_UNREADEN') . "</a></li>";
                                else if($cvrow['cvid']==114)
                                    $option = "<li viewtype='".$viewtype."' class='currdataClass' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_READEN') . "</a></li>";
                                else if($cvrow['cvid']==115)
                                    $option = "<li viewtype='".$viewtype."' class='currdataClass' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_SENDED') . "</a></li>";
                            }
                            else
                                $option = "
                            <li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"currdataClass\" onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\">
                            <a href='javascript:void(0);' id='".$cvrow['cvid']."popup'>" . $disp_viewname . "</a>
                            </li>";
                        }
                        else{
                            $option = "
                            <li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"currdataClass\" onclick=\"showDefaultCustomView(this,'". $thismodulename."','".$category."','".$cvrow['cvid']."')\">
                             <a href='javascript:void(0);'>" . $disp_viewname . "</a>
                            </li>";

                        }
                    }
                    $this->setdefaultviewid = $cvrow['cvid'];
                }
                else{
                    if($thismodulename=='Emails' || $thismodulename=='MassSMS'){
                        $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"divView\" onclick=\"getTableViewForFenzu(this,'". $thismodulename ."','".$cvrow['cvid']."','".$disp_viewname."')\">
                        <a href='javascript:void(0);'>" . $disp_viewname . "</a>
                        </li>";
                    }
                    else{
                        /**
                         * edit:cdw;
                         * date:20130626
                         * reason:0004209: 建议：对所有页面的视图布局进行调整,将"全部自定义视图"名称的颜色改为灰白色,鼠标放上去显示为"黑色",各个自定义视图之间,加一个"箭头"符号
                         */
                        if($popup=='popup'){
                            $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"divView\"  onclick=\"showDefaultCustomViewPopup(this,'". $thismodulename ."','".$category."','".$cvrow['cvid']."');\">
                            <a href='javascript:void(0);' id='".$cvrow['cvid']."popup'>" . $disp_viewname . "</a>
                            </li>";
                        }
                        else if($popup == 'relatedleft'){
                            /**
                             * 相关信息左右结构
                             * 修改视图切换事件
                             * Tujt 20140331
                             */
                            global $relationId;
                            if($this->customviewmodule=='Reminds')
                            {
                                if($cvrow['cvid']==108)
                                    $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_UNREADEN') . "</a></li>";
                                else if($cvrow['cvid']==114)
                                    $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_READEN') . "</a></li>";
                                else if($cvrow['cvid']==115)
                                    $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."')\"><a href='javascript:void(0);'  style='color:black;' id='".$cvrow['cvid']."popup'>" . getFixedLabel('LBL_SENDED') . "</a></li>";
                            }
                            else
                                $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"divView\"  onclick=\"showRelatedCustomView('".$relationId."','".$cvrow['cvid']."');\">
                            <a href='javascript:void(0);' id='".$cvrow['cvid']."popup'>" . $disp_viewname . "</a>
                            </li>";
                        }
                        else{
                            $option = "<li viewtype='".$viewtype."' viewid='".$cvrow['cvid']."' class=\"divView\"  onclick=\"showDefaultCustomView(this,'". $thismodulename ."','".$category."','".$cvrow['cvid']."');\">
                            <a href='javascript:void(0);'>" . $disp_viewname . "</a>
                            </li>";

                        }
                    }
                }
                // Add the option to combo box at appropriate section
                if($cvrow['viewname'] == 'All'){
                    $shtml_default.=$option;
                }else{
                    $shtml_others.=$option;
                }
            }
        }
        $shtml = $shtml_default;
        if ($is_admin == true)
            $shtml .= $shtml_pending;

        $shtml = $shtml . $shtml_user.$shtml_public. $shtml_others;
        return $shtml;
    }


    /**
     * edit:can
     * date:20140422
     * reason:视图手机开发
     * */
    function jsongetCustomViewCombo2($viewid = '',$thismodulename='', $markselected = true, $popup='') {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        return CustomView_Special::jsongetCustomViewCombo2($viewid ,$thismodulename,$this, $markselected , $popup);
    }


    /** to get the getModuleColumnsList for the given module
     * @param $module :: Type String
     * @returns  $ret_module_list Array in the following format


     */
    function getModuleColumnsList($module) {
        global $adb;
        $Fieldobj=Field::getInstance($module,$adb);
        $modulefields=$Fieldobj->getModuleFields();

        $module_info = $this->getCustomViewModuleInfo($module);
        $modulenoshowfields['Users']=array('activity_view','lead_view','hour_format','end_hour'
        ,'start_hour','title','reports_to_id','phone_other'
        ,'secondaryemail','signature','address_street','address_city','address_state','address_postalcode'
        ,'address_country','accesskey','time_zone','currency_id','currency_grouping_pattern','currency_decimal_separator'
        ,'currency_grouping_separator','currency_symbol_placement','internal_mailer','theme','language'
        ,'reminder_interval','asterisk_extension','use_asterisk','attachmentsid','date_format','email2'
        ,'confirm_password','user_password','viewothers','editothers','imagename'
        ,'delothers','viewselfbills','edit_other_mobile','edit_me_mobile','is_mobile_style'
        ,'select_servicedetail','select_due_date','trackpostion','login_sms','telephone_view'
        ,'push_work_reminds','push_news_reminds','push_wx_reminds','scopeauthority','accountallview');
        if($module=='Users')
        {
            $deployarray=getSys_deploy(55);//呼叫中心类型
            $deploy_value=$deployarray['deploy_value']??'';
            if($deploy_value=='汉天EC2')
            {
                $modulenoshowfields['Users'][]='sopho_exten';
                $modulenoshowfields['Users'][]='sopho_queue';
                $modulenoshowfields['Users'][]='jw_user';

            }
            else  if($deploy_value=='苏州思孚')
            {
                $modulenoshowfields['Users'][]='hantian_exten';
                $modulenoshowfields['Users'][]='jw_user';
            }
            else if($deploy_value=='苏州九维')
            {
                $modulenoshowfields['Users'][]='hantian_exten';
                $modulenoshowfields['Users'][]='sopho_exten';
                $modulenoshowfields['Users'][]='sopho_queue';
            }
            else
            {
                $modulenoshowfields['Users'][]='hantian_exten';
                $modulenoshowfields['Users'][]='sopho_exten';
                $modulenoshowfields['Users'][]='sopho_queue';
                $modulenoshowfields['Users'][]='jw_user';
            }
        }

        foreach($modulefields as $fieldname=>$fieldinfo)
        {
            if($fieldinfo&&($fieldinfo->getUIType()==69 || $fieldinfo->getUIType()==125 || $fieldinfo->getUIType()==222 || $fieldinfo->getUIType()==118))
                continue;
            if(array_key_exists($module,$modulenoshowfields)&&in_array($fieldname,$modulenoshowfields[$module]))
            {
                continue;
            }
            $blockid=$fieldinfo->getBlockId();
            foreach ($this->module_list[$module] as $key => $value) {
                if($value==$blockid)
                {
                    $blocklabel=$key;

                    break;
                }
            }

            if($blocklabel=='')
            {
                //客户首要联系人

                continue;
            }
            if($fieldinfo->getSaveDataBase()=='no')
            {
                continue;
            }
            $tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            $fieldlabel=$fieldinfo->getFieldLabelKey();
            $typeofdata=$fieldinfo->getTypeOfData();
            $typeofdatas=explode('~',$typeofdata);
            //  $columnlist[$tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$typeofdatas[0]]=$fieldlabel;
            if($columnname=='related_to' && $module=='Attachment')continue;//Liver 20170413附件数据分类 高级查找字段去掉 相关对象
            $ret_module_list[$module][$blocklabel][$tablename.':'.$columnname.':'.$fieldname.':'.$module.'_fieldlabel:'.$typeofdatas[0]]=$fieldlabel;
            $blocklabel='';


        }


        return $ret_module_list;
    }
    /*function getColumnsListbyBlock($module, $block) {
	   crm_load_class_file('CustomView_Special','modules/CustomView');
       return CustomView_Special::getColumnsListbyBlock($module, $block,$this);
	}*/
    public function getListWidth($cvid)
    {
        global $adb,$current_user,$related_left_type;
        //相关信息分类列
        if(isset($related_left_type) && $related_left_type > 0){
            $type = "related_customview";
        }else if((!empty($_REQUEST['action']) && $_REQUEST['action'] == 'Popup')
            ||(!empty($_REQUEST['page_popup']) && $_REQUEST['page_popup'] == 'yes') ){
            $type = "popup_customview";
        }else if(!empty($_REQUEST['popup_type']) && $_REQUEST['popup_type'] == 'chuantou_customview'){
            $type = "chuantou_customview";
        }else{
            $type = "customview";
        }
        return getCvColumnListWidth($this->customviewmodule,$type,$cvid);

    }
    public function getColumnsListByCvid($cvid) {
        global $adb;
        if(!$cvid) return '';
        $cachekey = 'cache_modulelist_getcvcolumnlist_'.$this->customviewmodule.'_getcvcolumnlist_'.$cvid ;
        $cachemodulelistview = CacheDirectory($cachekey,'customview');
        if(!$cachemodulelistview)
        {
            $sSQL = "select ld_cvcolumnlist.* from ld_cvcolumnlist";
            $sSQL .= " inner join ld_customview on ld_customview.cvid = ld_cvcolumnlist.cvid";
            $sSQL .= " where ld_customview.cvid =? order by ld_cvcolumnlist.columnindex";
            $result = $adb->pquery($sSQL, array($cvid));
            while ($columnrow = $adb->fetch_array($result)) {
                $columnlist[$columnrow['columnindex']] = $columnrow['columnname'];
            }
            CacheDirectory($cachekey,'customview',$columnlist);
            return $columnlist;
        }
        else
        {

            return  $cachemodulelistview;
        }
    }

    /** to get the standard filter fields or the given module
     * @param $module :: Type String
     * @returns  $stdcriteria_list Array in the following format
     * $stdcriteria_list = Array( $tablename:$columnname:$fieldname:$module_$fieldlabel => $fieldlabel,
     * 			 $tablename1:$columnname1:$fieldname1:$module_$fieldlabel1 => $fieldlabel1,
     * 					|
     * 			 $tablenamen:$columnnamen:$fieldnamen:$module_$fieldlabeln => $fieldlabeln)
     */
    function getStdCriteriaByModule($module) {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        return CustomView_Special::getStdCriteriaByModule($module,$this);

    }

    /** to get the standard filter criteria
     * @param $selcriteria :: Type String (optional)
     * @returns  $filter Array in the following format
     * $filter = Array( 0 => array('value'=>$filterkey,'text'=>$mod_strings[$filterkey],'selected'=>$selected)
     * 		     1 => array('value'=>$filterkey1,'text'=>$mod_strings[$filterkey1],'selected'=>$selected)
     * 		                             		|
     * 		     n => array('value'=>$filterkeyn,'text'=>$mod_strings[$filterkeyn],'selected'=>$selected)
     */
    function getStdFilterCriteria($selcriteria = "") {
        crm_load_class_file("CommonView","modules/CustomView");

        return CommonView::getStdFilterCriteria($selcriteria);


    }

    /** to get the standard filter criteria scripts
     * @returns  $jsStr : Type String
     * This function will return the script to set the start data and end date
     * for the standard selection criteria
     */
    function getCriteriaJS() {
        crm_load_class_file("CommonView","modules/CustomView");

        return CommonView::getCriteriaJs();
    }

    /** to get the Advanced filter for the given customview Id
     * @param $cvid :: Type Integer
     * @returns  $advfilterlist Array
     */
    function getAdvFilterByCvid($cvid) {
        global $adb,  $default_charset;
        $cachekey = 'customview_AdvFilterByCvid_'.$cvid.".".$this->cachetype ;
        $cachemodulelistview = CacheDirectory($cachekey,'customview');
        if(is_array($this->advfilter_arr))
        {
            // return $this->advfilter_arr;
        }
        if($cachemodulelistview==1)
        {

            // return $cachemodulelistview;
        }

        $advft_criteria = array();
        if(!$cvid) return '';
        $sql = 'SELECT * FROM '.$this->advfiltergrouptablename.' WHERE '.$this->tab_index[$this->advfiltergrouptablename].' = ? ORDER BY groupid';
        $groupsresult = $adb->pquery($sql, array($cvid));

        $grouprows = 0;
        $i=1;
        $j = 0;

        $focus = CRMEntity::getInstance($this->customviewmodule);
        $fieldObj=Field::getInstance($this->customviewmodule,$adb);
        //chj 2021/3/18 数据分类设置条件：当普通客户没有该条件字段权限时，sql语句中没有包含此条件，导致数据错误
        $moduleFields = $fieldObj->getModuleAllPreseneceFields();
        if(get_file_address($this->customviewmodule,$this->customviewmodule."DetailFieldsHtml"))
        {
            crm_load_class_file('TabDetails','include/TabDetailFields');
            $productDetails=new TabDetails($this->customviewmodule);
            $productFields = $productDetails->getModuleFields();
        }
        else
        {

            crm_load_class_file('ProductDetails','include/ProductDetails');
            $productDetails=ProductDetails::getInstance($this->customviewmodule);
            $productFields = $productDetails->getModuleAllPresenceFields();
        }
        crm_load_class_file('CommonView',"modules/CustomView");
        $datetimestr=CommonView::stdFilterDateTimeStr("");//获取日期，时间本年，明年等下拉框字符串


        while ($relcriteriagroup = $adb->fetch_array($groupsresult)) {
            $groupId = $relcriteriagroup["groupid"];
            $groupCondition = $relcriteriagroup["group_condition"];

            $ssql = 'select '.$this->advfiltertablename.'.* from '.$this->maintablename.'
						inner join '.$this->advfiltertablename.' on '.$this->advfiltertablename.'.'.$this->related_tableIndexname.' = '.$this->maintablename.'.'.$this->maintableIndexname.'
						left join '.$this->advfiltergrouptablename.' on '. $this->advfiltertablename. '.'.$this->related_tableIndexname.' = '.$this->advfiltergrouptablename.'.'.$this->related_tableIndexname.'
								and '.$this->advfiltertablename.'.groupid = '.$this->advfiltergrouptablename.'.groupid';
            $ssql.= " where ".$this->advfiltertablename. '.'.$this->related_tableIndexname.' = ? AND '.$this->advfiltertablename.'.groupid = ? order by '.$this->advfiltertablename.'.columnindex';

            $result = $adb->pquery($ssql, array($cvid, $groupId));

            $noOfColumns = $adb->num_rows($result);
            if ($noOfColumns <= 0)
                continue;

            while ($relcriteriarow = $adb->fetch_array($result)) {

                $columnIndex = $relcriteriarow["columnindex"];
                $criteria = array();
                $criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
                $criteria['comparator'] = $relcriteriarow["comparator"];
                $advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
                $columninfo = explode(':',$criteria['columnname']);
                if($columninfo[0]=='ld_crmentity')
                {
                    $columninfo[0]=$focus->table_name;
                    $sql='update ld_cvadvfilter set columnname=? where cvid=? and columnindex=? ';
                    $adb->pquery($sql,array($focus->table_name.":".$columninfo[1].":".$columninfo[2].":".$focus->module_name."_fieldlabel",$cvid,$columnIndex));

                }

                //edit:chj,16620: 合同订单-创建数据分类：高级查询设置：合计 大于 10000，保存后再查看，结果变成10
                //附件管理模块不能根据附件明细字段查询  xxs 20180607
                if(!in_array($columninfo[0] ,$focus->tab_name)&&$columninfo[0]!='ld_attachmentsforbillsdetails'){
                    $fieldObj = $productFields[$columninfo[2]];
                }else{
                    $fieldObj = $moduleFields[$columninfo[2]];
                }
                //BUG20240820-78 ls 240821 采购订单模块，新增查询分类，选择未出库数量作为查询条件，保存查询分类后，该条件丢失了
                $fieldlabelArray = array('haveinvoicecount','balanceinvoicecount','havepurchasecount','balancepurchasecount','balanceoutproductcount','haveoutproductcount');
                if(!empty($fieldObj)){
                    if($fieldObj->getFieldDataType() == 'currency'){
                        $advfilterval = str_replace(",","",$advfilterval);
                    }
                }
                elseif(in_array($columninfo[2],$fieldlabelArray)){
                }
                else
                {
                    continue;
                }

                $criteria['value'] = $this->getAdvfilterValue($relcriteriarow,$moduleFields,$productFields);
                $criteria['column_condition'] = $relcriteriarow["column_condition"];

                $advft_criteria[$i]['columns'][$j] = $criteria;
                $advft_criteria[$i]['condition'] = $groupCondition;
                $j++;
            }

            if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
                $advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
            }
            $grouprows++;
            $i++;
        }

        // Clear the condition (and/or) for last group, if any.
        if (!empty($advft_criteria[$i - 1]['condition']))
            $advft_criteria[$i - 1]['condition'] = '';

        CacheDirectory($cachekey,'customview',$advft_criteria);
        /*echo '<pre>';
        print_r($advft_criteria);
         echo '</pre>';*/

        return $advft_criteria;
    }
    public function getAdvfilterValue($relcriteriarow,$moduleFields,$productFields)
    {
        crm_load_class_file('CommonView',"modules/CustomView");
        $datetimestr=CommonView::stdFilterDateTimeStr("");//获取日期，时间本年，明年等下拉框字符串
        global $adb,$default_charset;
        $focus = CRMEntity::getInstance($this->customviewmodule);
        $fieldObj=Field::getInstance($this->customviewmodule,$adb);

        $criteria = array();
        $criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
        $criteria['comparator'] = $relcriteriarow["comparator"];
        $advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
        $columninfo = explode(':',$criteria['columnname']);


        //edit:chj,16620: 合同订单-创建数据分类：高级查询设置：合计 大于 10000，保存后再查看，结果变成10
        //附件管理模块不能根据附件明细字段查询  xxs 20180607
        if(!in_array($columninfo[0] ,$focus->tab_name)&&$columninfo[0]!='ld_attachmentsforbillsdetails'){
            $fieldObj = $productFields[$columninfo[2]];
        }else{
            $fieldObj = $moduleFields[$columninfo[2]];
        }

        $fieldlabelArray = array('haveinvoicecount','balanceinvoicecount','havepurchasecount','balancepurchasecount','balanceoutproductcount','haveoutproductcount');
        if (!empty($fieldObj)) {
            if ($fieldObj->getFieldDataType() == 'currency') {
                $advfilterval = str_replace(",", "", $advfilterval);
            }
        } elseif (in_array($columninfo[2], $fieldlabelArray)) {
        } else {
            return false;
        }
        $col = explode(":", $relcriteriarow["columnname"]);

        if(empty($col[4]))
        {

            //基本查询升级到高级查询
            $typeofdatas= explode("~",$fieldObj->getTypeOfData());

            $relcriteriarow["columnname"]=$relcriteriarow["columnname"].":".$typeofdatas[0];
            $criteria['columnname']=$relcriteriarow["columnname"];
            $col = explode(":", $relcriteriarow["columnname"]);
        }

        if(array_key_exists($criteria['comparator'],$datetimestr))
        {
            //如果是本年明年，n天后等
            $temp_val[0]=$datetimestr[$criteria['comparator']][0].' 00:00:00';
            $temp_val[1]=$datetimestr[$criteria['comparator']][1].' 23:59:59';
        }
        else
            $temp_val = explode(",", $relcriteriarow["value"]);


        if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT'))
        {
            $val = Array();
            for ($x = 0; $x < count($temp_val); $x++)
            {

                if ($col[4] == 'D') {
                    //	$date = new DateTimeField(trim($temp_val[$x]));
                    //	$val[$x] = $date->getDisplayDate();
                    $var_arr=array('current_userid','current_dates--:::');
                    if(in_array($temp_val[$x],$var_arr)){
                        $value=str_replace('-','',$value);
                        $value=str_replace(':','',$value);
                        $value=$$value;
                        $date = new DateTimeField($value);
                        $val[$x] = $date->getDisplayDateTimeValue();
                    }else{
                        $datetime = new DateTime($temp_val[$x]);
                        $val[$x]=$datetime->format('Y-m-d');
                    }
                    if(trim($temp_val[$x])=='')$val[$x]='';//0014221: 所有牵涉到数据分类模块,编辑数据分类高级查询时的问题
                } elseif ($col[4] == 'DT') {
                    //$date = new DateTimeField(trim($temp_val[$x]));
                    //$val[$x] = $date->getDisplayDateTimeValue();
                    $val[$x]=date("Y-m-d H:i:s",strtotime(trim($temp_val[$x])));
                    if(trim($temp_val[$x])=='')$val[$x]='';
                } else {
                    //$date = new DateTimeField(trim($temp_val[$x]));
                    //$val[$x] = $date->getDisplayTime();
                    $val[$x]=date("H:i:s",strtotime(trim($temp_val[$x])));
                    if(trim($temp_val[$x])=='')$val[$x]='';
                }
            }
            $advfilterval = implode(",", $val);
        }
        return $advfilterval;

    }
    /**
     * Cache information to perform re-lookups
     *
     * @var String
     */
    protected $_fieldby_tblcol_cache = array();
    /** to get the comparator value for the given comparator and value
     * @param $comparator :: type string
     * @param $value :: type string
     * @returns  $rtvalue in the format $comparator $value
     */
    function getAdvComparator($comparator, $value, $datatype = '') {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        return  CustomView_Special::getAdvCompator($comparator, $value, $datatype,$this);
    }

    /** to get the date value for the given type
     * @param $type :: type string
     * @returns  $datevalue array in the following format
     *             $datevalue = Array(0=>$startdate,1=>$enddate)
     */
    function getDateforStdFilterBytype($type) {
        crm_load_class_file("CommonView","modules/CustomView");
        return CommonView::getDateforStdFilterBytype($type);
    }
    /* This function sets the block information for the given module to the class variable module_list
     * and return the array
     */
    function getCustomViewModuleInfo($module) {
        crm_load_class_file('CustomView_Special','modules/CustomView');
        return CustomView_Special::getCustomViewModuleInfo($module,$this);
    }

    /**
     * Get the userid, status information of this custom view.
     *
     * @param Integer $viewid
     * @return Array
     */
    function getStatusAndUserid($viewid) {
        global $adb,$current_user;

        //32027: （普通用户）>单据列表界面>新增分类填写数据保存>管理分类弹出层操作列没有显示出：编辑、删除按钮。
        //先把换成注释
        //$cachekey = 'cache_modulelist_getStatusAndUserid_'.$this->customviewmodule.'_getStatusAndUserid_user_'.$viewid ;
        // $cachemodulelistview = CacheDirectory($cachekey,'customview');

        // if($cachemodulelistview)
        // {
        //  $this->_status =$cachemodulelistview['status'];

        //  $this->_userid=$cachemodulelistview['userid'];
        //  return $cachemodulelistview;
        //  }

        //	if ($this->_status === false || $this->_userid === false) {
        $query = 'SELECT status, userid FROM ld_customview WHERE cvid=? limit 1;';

        $result = $adb->pquery($query, array($viewid));
        if ($result && $adb->num_rows($result)) {
            $this->_status = $adb->query_result($result, 0, 'status');
            $this->_userid = $adb->query_result($result, 0, 'userid');
        } else {
            return false;
        }
        //	}

        CacheDirectory($cachekey,'customview',array('status' => $this->_status, 'userid' => $this->_userid));
        return array('status' => $this->_status, 'userid' => $this->_userid);
    }

    //Function to check if the current user is able to see the customView
    function isPermittedCustomView($record_id, $action, $module) {
        global $adb;
        global $current_user;
        require(globalStatic::$root_directory.'user_privileges/user_privileges_' . $current_user->id . '.php');
        $permission = "yes";

        if ($record_id != '') {
            $status_userid_info = $this->getStatusAndUserid($record_id);

            if ($status_userid_info) {
                $status = $status_userid_info['status'];
                $userid = $status_userid_info['userid'];

                //echo $status;
                //导出 获取SQL时，无法获取序时簿列头字段. 原因是没有导出权限，所有就导致cvid为0.
                if ($status == CV_STATUS_DEFAULT) {
                    if ($action == 'ListView' || $action == 'Delete' || $action == 'EditView' || $action == 'Create' || $action == 'CustomView' || $action == $module . "Ajax" || $action == 'index' || $action == 'DetailView'|| $action == 'Edit' || $action == "Export$module") {
                        $permission = "yes";
                    }
                    else
                        $permission = "no";
                }
                elseif ($is_admin) {
                    $permission = 'yes';
                } elseif ($action != 'ChangeStatus') {

                    if ($userid == $current_user->id) {

                        $permission = "yes";
                    } elseif ($status == CV_STATUS_PUBLIC) {

                        if ($action == 'ListView' || $action == $module . "Ajax" || $action == 'index' || $action == 'DetailView'|| $action == "Export$module") {
                            $permission = "yes";
                        }
                        else
                            $permission = "no";
                    }
                    elseif ($status == CV_STATUS_PRIVATE || $status == CV_STATUS_PENDING) {

                        if ($userid == $current_user->id)
                            $permission = "yes";
                        else {
                            if($action == 'ListView' || $action == $module."Ajax" || $action == 'index')
                            {

                                $sql = "select ld_users.id from ld_customview inner join ld_users where ld_customview.cvid = ? and ld_customview.userid in (select ld_user2role.userid from ld_user2role inner join ld_users on ld_users.id=ld_user2role.userid inner join ld_role on ld_role.roleid=ld_user2role.roleid where ld_role.parentrole like '%" . $current_user_parent_role_seq . "::%')";
                                $result = $adb->pquery($sql, array($record_id));
                                while ($row = $adb->fetchByAssoc($result)) {
                                    $temp_result[] = $row['id'];
                                }
                                $user_array = $temp_result;
                                if (sizeof($user_array) > 0) {
                                    if (!in_array($current_user->id, $user_array))
                                        $permission = "no";
                                    else
                                        $permission = "yes";
                                }
                                else
                                    $permission = "no";
                            }
                            else
                            {

                                $permission = "no";
                            }
                        }
                    }
                    else
                        $permission = "yes";
                }
                else {

                    $permission = "no";
                }
            } else {

                $permission = 'no';
            }
        }

        return $permission;
    }


    /**
     * @edit:chj
     * @date:2014-10-29
     * @reason:获取模块下所有的排序设置
     * @description:
     */
    function getModuleSortOrder($module)
    {
        crm_load_class_file('CustomView_Sort','modules/CustomView');
        $sortobj=CustomView_Sort::getInstance($this,$this->customviewmodule);
        return $sortobj->getModuleSortOrder();
    }
    /**
     * @edit:chj
     * @date:2014-10-29
     * @reason:获取当前分类下已设定排序设置字段
     * @description:新建，默认创建时间排序
     */
    function getCvcolumnlistSort($cvid)
    {
        crm_load_class_file('CustomView_Sort','modules/CustomView');
        $sortobj=CustomView_Sort::getInstance($this,$this->customviewmodule);
        return $sortobj->getCvColumnSort($cvid);

    }
    /**
     * @edit:chj
     * @date:2014-11-4
     * @reason:设置分类的默认排序设置
     * @description:
     */
    function setCustonviewSortOrder($module)
    {
        crm_load_class_file('CustomView_Sort','modules/CustomView');
        $sortobj=CustomView_Sort::getInstance($this,$module);
        return $sortobj->save_sort();
    }
    //客户模块，获取分类的custom
    /**
     * @edit:chj
     * @date:2014-11-18
     * @reason:获取分类的类别
     * @description:1、全部含公海，公海已分配，公海未分配
     */
    function getCustomCategory($viewid)
    {
        global $adb;
        $cachekey = 'cache_modulelist_getCustomCategory_'.$this->customviewmodule.'_getCustomCategory_'.$viewid ;
        $cachemodulelistview = CacheDirectory($cachekey,'customview');
        if($cachemodulelistview)
            return $cachemodulelistview;

        $query = 'select customcategory from ld_customview where cvid = ?';
        $result = $adb->pquery($query,array($viewid));
        CacheDirectory($cachekey,'customview',$adb->query_result($result,0,'customcategory'));
        return $adb->query_result($result,0,'customcategory');
    }

    /**
     * @edit:chj
     * @date:2014-11-4
     * @reason:获取分类的排序设置
     * @description:
     */
    function getCustomViewOrderBy($cvid)
    {
        crm_load_class_file('CustomView_Sort','modules/CustomView');
        $sortobj=CustomView_Sort::getInstance($this,$this->customviewmodule);
        return $sortobj->getCustomViewOrderBy($cvid);
    }

    public function getSortOrderArr($cvid)
    {
        crm_load_class_file('CustomView_Sort','modules/CustomView');
        $sortobj=CustomView_Sort::getInstance($this,$this->customviewmodule);
        return $sortobj->getSortOrderArr($cvid);
    }
    public function getViewNameDetail($viewid){
        if(isset($this->cachemodulelistview[$viewid]['viewname'])){
            return $this->cachemodulelistview[$viewid]['viewname'];
        }
        return '';
    }
    /**
     * 获取当前数据分类对象
     * @author Tujt 2015-06-03
     */
    public function getViewDetailInfo($viewid) {
        if(empty($this->cachemodulelistview)){
            $this->cachemodulelistview = $this->getCvlistByUser();
        }
        if(isset($this->cachemodulelistview[$viewid])){
            return $this->cachemodulelistview[$viewid];
        }
        return '';
    }

    public function setrelatedfldarray()
    {

    }

    public function setCvid($cvid)
    {
        $this->cvid = $cvid;
    }
}

?>