<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-05-28
 */
class BaseLogic extends Logic {//基础逻辑层
	private static $_instance;//单例
	public static $module;//当前模块
	public $list_buttons;//列表按钮
	public $detail_buttons;//详情页 操作按钮
	public $detail_settings = [];//详情页 设置按钮zxm 20221123  设置按钮 比如页面设置、单据分录设置、相关信息设置
	public static $approvebtnarr;//审批权限判断数组
	public $approvebtn;//当前单据审批权限
	public $quickactionLink = array();//快速创建链接
	public $listview_link;//列表操作列按钮
    public $settinglistbuttons_arr = array();//数据库中操作列按钮顺序
    public $settinglistlinks_arr = array();//数据库中操作列按钮顺序
    //public $sortedlistlink=array();//根据settinglistlinks_arr重排后的$listview_link
    public $settingshownum;
    public $list_buttom_name = array();
    public $edit_errorreason;//没有编辑权限的原因
    //public $delete_error;//没有删除权限的原因
    //public $listviewbtntype;
    public $list_button_html;
    public $settingbtns_arr = [];// 数据库中保存的按钮顺序
    public $all_detailbtn_arr = [];// 数据库中保存的按钮顺序
    protected $buttoncustomizationObj;// 自定义按钮类对象
    public $custom_activebuttons_arr = [];// 启用的自定义按钮信息
    public $btn_from = 'pc';// 是网页端还是移动端请求获取按钮
    public $setlistbutton;
    public $effectcolumn_arr = [];
    public $effectfieldid_arr = [];
    public $publicmoduletype;
    /**
     * 构造函数
     * @author Tujt 2015-05-28
     */
    public function __construct() {
    	parent::__construct();
    }
	/**
     * 单例初始化类对象
     * @author Tujt 2015-05-28
     */
	public static function getInstance($module) {//单例
		if(!(self::$_instance[$module] instanceof self)){//是否为当前类的实例
			$cls = $module.'Logic';
            //editor:gyq data:20170512 reason:地址增加$root_directory前缀，否则移动端无法判断
			if(!file_exists(globalStatic::$root_directory.'modules/'.$module.'/'.$cls.'.class.php')){//模块中没有相关文件
                self::$_instance[$module] = new self();//初始化当前类
			}else{//否则，初始化模块对应Logic类
				//require_once('modules/'.$module.'/'.$cls.'.class.php');
                import('modules.'.$module.'.'.$cls,'class');
				self::$_instance[$module] = new $cls();
			}
		}
		self::$module = $module;
		return self::$_instance[$module];
	}
	/**
     * 防止被克隆
     * @author Tujt 2015-05-28
     */
    private function __clone(){}
	/**
	 * 获取列表的按钮
	 * @author Tujt 2015-05-28
	 */
	public function getListViewButtons() {
		$this->list_buttons = Array();
		$this->getListBasicBtn();//初始化模块基础按钮
		$this->getListMoreBtn();//初始化更多按钮关联下拉列表
		return $this->list_buttons;//返回列表按钮结果集
	}

    //设置模块
    public function setModule($module)
    {
        self::$module = $module;
    }

    //
    public function setController($controller)
    {
        $this->controller = $controller;
    }

   //XUQIU1000536 230706 zl 获取列表操作按钮
    public function resetListViewButtons($getlistbuttons)
    {
        global $adb;
        $modulename = self::$module;
        $tabid=getTabid($modulename);
        if(empty($modulename) || empty($getlistbuttons)){
            return [];
        }

        $selist = [];//传入数组中更多里面的按钮数组
        foreach ($getlistbuttons as $key => $arr) {
            if ($key == 'More') {
                $selist = $arr['list'];
                unset($getlistbuttons['More']);
            }
        }

        $getlistbuttons = array_merge($getlistbuttons, $selist);//传入列表数组,没有更多 -- 代码生成的原列表数组,组装后
      // dump($getlistbuttons);

        $listbtnarr = [];
        $alllistbtnarr = $this->getsettinglistbuttons($tabid);//数据库保存的列表按钮数组

        if(empty($alllistbtnarr)){
            $shownum = 2;
            $listbtnarr = $getlistbuttons;
        }else{
            $shownum = $this->getsettingshownum($tabid);//massallocate
            if($shownum > 4){
                $shownum = 4;
            }
            $getlistbuttonkey_arr = array_keys($getlistbuttons);
            $alllistbuttonkey_arr = array_keys($alllistbtnarr);

            $otherbuttonkeys_arr = array_diff($getlistbuttonkey_arr,array_keys($alllistbtnarr));//因某些原因没有在数组内的按钮 eg:客户-公海未分配-massallocate
            foreach($otherbuttonkeys_arr as $tmpkey){
                if(in_array($tmpkey,$getlistbuttonkey_arr)){
                    $tmptoindex =array_keys($getlistbuttonkey_arr,$tmpkey);
                    array_splice($alllistbuttonkey_arr,$tmptoindex[0],0,$tmpkey);
                }
            }
            //筛选出当前模块已排序的有权限的按钮

            foreach ($alllistbuttonkey_arr as $key){
                $listbtnarr[$key] = $getlistbuttons[$key];
                $listbtnarr[$key]['sequence'] = $alllistbtnarr[$key]['sequence'];
                if(!isset($listbtnarr[$key]['label']) || $listbtnarr[$key]['permit'] == 'no' || $listbtnarr[$key]['permit'] == ''){
                    unset($listbtnarr[$key]);
                }
            }
        }

        //hzx 列表页面优化
        $listviewbtntype = $this->getListViewBtnType();
        $listbtn_self_arr = [];
        $listbtn_rely_arr = [];//dump($listbtnarr);

        if(count($listviewbtntype) > 0){
            foreach ($listbtnarr as $btnname => $btninfo){
                if($listviewbtntype['rely'][$btnname] || $listviewbtntype['self'][$btnname]){
                    if($listviewbtntype['rely'][$btnname]){
                        if(!empty($listviewbtntype['rely'][$btnname]['iconname'])){
                            $btninfo['iconname'] = $listviewbtntype['rely'][$btnname]['iconname'];
                        }
                        $listbtn_rely_arr[$btnname] = $btninfo;
                    }
                    if($listviewbtntype['self'][$btnname]){
                        $listbtn_self_arr[$btnname] = $btninfo;
                    }
                }else{
                    $listbtn_self_arr[$btnname] = $btninfo;
                }
            }
        }else{
            $listbtn_self_arr = $listbtnarr;
        }


        //通用按钮
        $return_listbtnarr = [];

        if(is_array($listbtn_self_arr) &&count($listbtn_self_arr) >0){
            //$morebtnarr为显示在"更多"中的按钮
            $morebtnarr=array_slice($listbtn_self_arr,(int)$shownum);

            //带二级分录的按钮,在"更多"中时显示为多个按钮
            $morebtnarr2 = [];
            foreach ($morebtnarr as $key2 => $morebtn){
                if (isset($morebtn['list'])){
                    $resetmore = $morebtn['list'];
                    foreach($resetmore as $tmpkey=>$moreinfo){
                        if ($tmpkey == 'btnkey') {
                            continue;
                        }
                        $morebtnarr2[$tmpkey]=$moreinfo;
                    }
                }
                else{
                    $morebtnarr2[$key2]=$morebtn;
                }
            }
            //最终按钮数组为$return_listbtnarr
            $return_listbtnarr=array_slice($listbtn_self_arr,0,$shownum); //先取不在"更多"中的按钮
            $return_listbtnarr['More']['list']=$morebtnarr2;  //拼接在更多中的按钮
            $return_listbtnarr['More']['permit']='yes';
            //BUG0069330 230710 更多中没有按钮则不显示,部分按钮失效
            if($morebtnarr == Array()){
                unset($return_listbtnarr['More']);
            }
            foreach ($return_listbtnarr as $index => $specibtn){
                if(!isset($specibtn['btnkey']) && $index != 'More'){
                    $return_listbtnarr[$index]['btnkey'] = $index;
                }
            }
        }

        //批量操作按钮
        $return_listbtnrelyarr = [];
        if(count($listbtn_rely_arr) > 0){
            //$morebtnarr为显示在"更多"中的按钮
            if(count($listbtn_rely_arr) > 8) {

                $morebtnrelyarr = array_slice($listbtn_rely_arr, 7);
                //带二级分录的按钮,在"更多"中时显示为多个按钮
                $morebtnrelyarr2 = [];
                foreach ($morebtnrelyarr as $key2 => $morebtn) {
                    if (isset($morebtn['list'])) {
                        $resetmore = $morebtn['list'];
                        foreach ($resetmore as $tmpkey => $moreinfo) {
                            if ($tmpkey == 'btnkey') {
                                continue;
                            }
                            $morebtnrelyarr2[$tmpkey] = $moreinfo;
                        }
                    } else {
                        $morebtnrelyarr2[$key2] = $morebtn;
                    }
                }
                //最终按钮数组为$return_listbtnarr
                $return_listbtnrelyarr = array_slice($listbtn_rely_arr, 0, 7); //先取不在"更多"中的按钮
                $return_listbtnrelyarr['More']['list'] = $morebtnrelyarr2;  //拼接在更多中的按钮
                $return_listbtnrelyarr['More']['permit'] = 'yes';
                //BUG0069330 230710 更多中没有按钮则不显示,部分按钮失效
                if ($morebtnrelyarr2 == array()) {
                    unset($return_listbtnrelyarr['More']);
                }
                foreach ($return_listbtnrelyarr as $index => $specibtn) {
                    if (!isset($specibtn['btnkey']) && $index != 'More') {
                        $return_listbtnrelyarr[$index]['btnkey'] = $index;
                    }
                }
            }
            else{
                $return_listbtnrelyarr = $listbtn_rely_arr;
                foreach ($return_listbtnrelyarr as $index => $specibtn) {
                    if (!isset($specibtn['btnkey']) && $index != 'More') {
                        $return_listbtnrelyarr[$index]['btnkey'] = $index;
                    }
                }
            }
        }
        //return $return_listbtnarr;
        return array('listbtnself'=>$return_listbtnarr,'listbtnrely'=>$return_listbtnrelyarr);
    }

    //hzx 获取按钮类型
    public function getListViewBtnType(){
	    global $adb;
	    $listviewbtnarr = [];
	    $sql = 'select `name`,btntype,iconname from ld_listview_btn;';
	    $result = $adb->pquery($sql,array());
	    $num = $adb->num_rows($result);
	    $self_arr = [];
        $rely_arr = [];
	    if($num){
	        for($i= 0;$i<$num;$i++){
                if($adb->query_result($result,$i,'btntype') == 'self'){
                    $self_arr[$adb->query_result($result,$i,'name')] = array(
                        'type'=>$adb->query_result($result,$i,'btntype'),
                        'iconname'=>$adb->query_result($result,$i,'iconname')
                    );
                }
                else if($adb->query_result($result,$i,'btntype') == 'rely'){
                    $rely_arr[$adb->query_result($result,$i,'name')] = array(
                        'type'=>$adb->query_result($result,$i,'btntype'),
                        'iconname'=>$adb->query_result($result,$i,'iconname')
                    );
                }
            }
        }
        $listviewbtnarr = array('self'=>$self_arr,'rely'=>$rely_arr);
	    return $listviewbtnarr;
    }
    //按照数据库保存的操作列按钮顺序，重排当前按钮
    public function resetListViewLink()
    {
        $getlistlinks = $this->listview_link;
        $modulename = self::$module;
        if(empty($modulename)){
            return [];
        }
        $alllistlinkarr = $this->getsettinglistlinks();//数据库保存的
		$sortedlistlink = array();
        if(empty($alllistlinkarr)){
            $sortedlistlink = $getlistlinks;
            $this->listview_link = $sortedlistlink;
        }else {
            $getlistlinkkey_arr = array_keys($getlistlinks);//btnkey>label,permit,onclick; keyarr: seq>btnkey
            $alllistlinkkey_arr = array_flip(array_keys($alllistlinkarr));//btnkey>label,is_active; keyarrflip:btnkey>seq
            $diffbtnkey_arr = array();
            $sortedbtnkey_arr = array();
            foreach ($getlistlinkkey_arr as $getlistlinkkey) {
                if(array_key_exists($getlistlinkkey, $alllistlinkkey_arr)){
                    $newseq = $alllistlinkkey_arr[$getlistlinkkey] ;
                    $sortedbtnkey_arr[$newseq] = $getlistlinkkey; //newseq>btnkey
                    //当该按钮有权限但是在数据库中不启用时，该按钮被禁用
                    if ($getlistlinks[$getlistlinkkey]['permit'] == 'yes' && $alllistlinkarr[$getlistlinkkey]['is_active'] == "no") {
                        $getlistlinks[$getlistlinkkey]['permit'] = 'no';
                    }
                }else{
                    $diffbtnkey_arr[] = $getlistlinkkey;
                }
            }
            ksort($sortedbtnkey_arr);//基于newseq进行重排,newseq>btnkey
            foreach ($sortedbtnkey_arr as $sortedbtnkey) {
                $sortedlistlink[$sortedbtnkey] = $getlistlinks[$sortedbtnkey];
            }
            foreach($diffbtnkey_arr as $diffbtnkey){
                $sortedlistlink[$diffbtnkey] = $getlistlinks[$diffbtnkey];
            }
            $this->listview_link = $sortedlistlink;
        }
    }
    /**
     * 重排序详情页按钮
     */
    public function resetDetailViewButtons()
    {
        $detailbtns_arr = $this->detail_buttons;
        $module = self::$module;
        if (empty($module)) {
            return [];
        }
        // 将More中的按钮取出来放在数组同一级，便于处理
        $new_detailbtns_arr = [];
        foreach ($detailbtns_arr as $key => $value) {
            if(empty($value)){
                continue;
            }
            if ($key == 'More') {
                $new_detailbtns_arr = array_merge($new_detailbtns_arr, $value['list']);
            } else if($key == 'Settings' || $key == 'RelevantSettings'){
                continue;
            } else {
                $new_detailbtns_arr[$key] = $value;
            }
        }
        
        $settingbtns_arr = $this->getSettingButtonsByType('detailbtn');//数据库保存的
        $sorted_detailbtns_arr = array();
        if(!empty($settingbtns_arr)){

            $detailbtnkey_arr = array_keys($new_detailbtns_arr);// seq => btnkey
            $allsettingbtnkey_arr = array_flip(array_keys($settingbtns_arr));// btnkey => seq
            $diffbtnkey_arr = array();
            $sortedbtnkey_arr = array();

            foreach ($detailbtnkey_arr as $detailbtnkey) {
                if (array_key_exists($detailbtnkey, $allsettingbtnkey_arr)) {
                    $newseq = $allsettingbtnkey_arr[$detailbtnkey];
                    $sortedbtnkey_arr[$newseq] = $detailbtnkey; // newseq => btnkey

                    //当该按钮有权限但是在数据库中不启用时，该按钮被禁用
                    if ($new_detailbtns_arr[$detailbtnkey]['permit'] == 'yes' && $settingbtns_arr[$detailbtnkey]['is_active'] == "no") {
                        $new_detailbtns_arr[$detailbtnkey]['permit'] = 'no';
                    }
                } else {
                    $diffbtnkey_arr[] = $detailbtnkey;
                }
            }

            ksort($sortedbtnkey_arr);// 基于newseq进行重排，newseq => btnkey
            
            foreach ($sortedbtnkey_arr as $sortedbtnkey) {
                $sorted_detailbtns_arr[$sortedbtnkey] = $new_detailbtns_arr[$sortedbtnkey];
            }
            // 没保存到数据库中的按钮，默认放最后
            foreach ($diffbtnkey_arr as $diffbtnkey) {
                $sorted_detailbtns_arr[$diffbtnkey] = $new_detailbtns_arr[$diffbtnkey];
            }
            
            // $this->setAllDetailButtons($sorted_detailbtns_arr);
            // // 重组detail_buttons
            // $new_morebtns_arr = array_slice($sorted_detailbtns_arr, 5);
            // $this->detail_buttons = [];
            // $this->detail_buttons = array_slice($sorted_detailbtns_arr, 0, 5);
            // $this->detail_buttons['More']['list'] = $new_morebtns_arr;
            // $this->detail_buttons['More']['label'] = '···';
            // $this->detail_buttons['More']['permit'] = 'yes';
            // $this->detail_buttons['More']['icon'] = 'icon-more';

        }else{
            $sorted_detailbtns_arr = $new_detailbtns_arr;
        }
        // 记录所有按钮的数组
        $this->setAllDetailButtons($sorted_detailbtns_arr);

        // 重组detail_buttons
        foreach ($sorted_detailbtns_arr as $btnkey => &$btninfo) {
            if ($btninfo['permit'] != 'yes'){
                // unset($sorted_detailbtns_arr[$btnkey]);
            }
        }
        // dump($sorted_detailbtns_arr);
        $new_morebtns_arr = array_slice($sorted_detailbtns_arr, 5);
        $this->detail_buttons = [];
        $this->detail_buttons = array_slice($sorted_detailbtns_arr, 0, 5);
        $this->detail_buttons['More']['list'] = $new_morebtns_arr;
        $this->detail_buttons['More']['label'] = '···';
        $this->detail_buttons['More']['permit'] = 'yes';
        $this->detail_buttons['More']['icon'] = 'icon-more';
        // dump($this->detail_buttons);

    }
    public function getsettinglistbuttons($tabid){
        global $adb;
        if(empty($tabid)){
            return [];
        }
        if(!empty($this->settinglistbuttons_arr)){
            return $this->settinglistbuttons_arr;
        }
        $tmpresult = $adb->pquery("select buttonlabel,btnkey,sequence,shownum from ld_btnset where tabid=? and btn_type = 'listbasicbtn' order by sequence ",array($tabid));
        $noofrows=$adb->num_rows($tmpresult);
        if($noofrows>0){
            for($i=0;$i<$noofrows;$i++)
            {
                $buttonlabel=$adb->query_result($tmpresult,$i,'buttonlabel');
                $btnkey=$adb->query_result($tmpresult,$i,'btnkey');
                $sequence =$adb->query_result($tmpresult,$i,'sequence');
                $alllistbtnarr[$btnkey]['label']=$buttonlabel;
                $alllistbtnarr[$btnkey]['sequence']=$sequence;
            }
        }
        $shownum = $adb->query_result($tmpresult,0,'shownum');
        $this->settinglistbuttons_arr=$alllistbtnarr;
        $this->settingshownum = $shownum;
        return $alllistbtnarr;
    }
    public function getsettingshownum($tabid){
        global $adb;
        if(empty($tabid)){
            return 0;
        }
        if(!empty($this->settingshownum)){
            return $this->settingshownum;
        }
        $tmpresult = $adb->pquery("select shownum from ld_btnset where tabid=? and btn_type = 'listbasicbtn' and shownum > 0 limit 1",array($tabid));
        $noofrows=$adb->num_rows($tmpresult);
        if($noofrows>0){
            $shownum = $adb->query_result($tmpresult,0,'shownum');
        }
        if(is_null($shownum)){
            $shownum = 2;
        }
        $this->settingshownum = $shownum;
        return $shownum;
    }
    public function getsettinglistlinks(){
        global $adb;
        $modulename = self::$module;
        $tabid=getTabid($modulename);
        if(empty($tabid)){
            return array();
        }
        if(!empty($this->settinglistlinks_arr)){
            return $this->settinglistlinks_arr;
        }
        $alllistlinkarr = array();
        $tmpresult = $adb->pquery("select buttonlabel,btnkey,is_active from ld_btnset where tabid=? and btn_type = 'actionlink' order by sequence ",array($tabid));
        $noofrows=$adb->num_rows($tmpresult);
        if($noofrows>0){
            for($i=0;$i<$noofrows;$i++)
            {
                $buttonlabel=$adb->query_result($tmpresult,$i,'buttonlabel');
                $btnkey=$adb->query_result($tmpresult,$i,'btnkey');
                $is_active =$adb->query_result($tmpresult,$i,'is_active');
                $alllistlinkarr[$btnkey]['label']=$buttonlabel;
                $alllistlinkarr[$btnkey]['is_active']=$is_active;
            }
        }
        $this->settinglistlinks_arr=$alllistlinkarr;
        return $alllistlinkarr;
    }
    /**
     * 根据type获取数据库中保存的按钮
     */
    public function getSettingButtonsByType($type){
        global $adb;
        $modulename = self::$module;
        $tabid = getTabid($modulename);
        if(empty($tabid)){
            return array();
        }
        if(!empty($this->settingbtns_arr) && !empty($this->settingbtns_arr[$type])){
            return $this->settingbtns_arr[$type];
        }
        $settingbtns_arr = array();
        $select_sql = "SELECT buttonlabel,btnkey,`sequence`,shownum,is_active from ld_btnset where tabid=? and btn_type = ? order by `sequence` ";
        $tmpresult = $adb->pquery($select_sql,array($tabid,$type));
        $num_rows = $adb->num_rows($tmpresult);
        if($num_rows > 0){
            for($i=0;$i<$num_rows;$i++)
            {
                $buttonlabel = $adb->query_result($tmpresult,$i,'buttonlabel');
                $btnkey = $adb->query_result($tmpresult,$i,'btnkey');
                $sequence = $adb->query_result($tmpresult,$i,'sequence');
                $is_active = $adb->query_result($tmpresult,$i,'is_active');
                $settingbtns_arr[$btnkey]['label'] = $buttonlabel;
                $settingbtns_arr[$btnkey]['is_active'] = $is_active;
                $settingbtns_arr[$btnkey]['sequence']=$sequence;
            }
        }
        $shownum = $adb->query_result($tmpresult,0,'shownum');
        if($type == 'listbasicbtn'){
            $this->settingshownum = $shownum;
        }
        $this->settingbtns_arr[$type] = $settingbtns_arr;
        return $settingbtns_arr;
    }
	/**
	 * 初始化模块基础按钮
	 * @author Tujt 2015-05-28
	 */
	public function getListBasicBtn() {
		global $current_user,$adb;
		$module = self::$module;
        
       	$fieldObj = Field::getInstance($module,$adb);
	    $moduleFields = $fieldObj->getModuleFields();
        $field_creator = $moduleFields['smcreatorid'];
        //editor:gyq_161* reason:带产品分录模块弹出层   2019/11/21 17:34
        //f($module!="ServiceCharge"&&(get_file_address($module,"ProductDetails")||$module=="LessionPlan"||get_file_address($module,$module."DetailFieldsHtml")))
        //新增
        if($module=="LessionPlan")
       {
           $this->list_buttons['Create']['label'] = getFixedLabel('CREATE');
           $this->list_buttons['Create']['permit'] = isPermitted($module, 'Create', '');
           $this->list_buttons['Create']['icon'] = 'icon-plus';
           $this->list_buttons['Create']['btnkey'] = 'Create';
         /*if($module!='PurchaseBack'&&$module!='SalesBack'&&$module!="CashBack"&&$module!="PurchaseCashBack")
            {
                $this->list_buttons['ModuleDetailCreate']['label'] = getFixedLabel('CREATE');
        		$this->list_buttons['ModuleDetailCreate']['permit'] = isPermitted($module, 'Create', '');
        		$this->list_buttons['ModuleDetailCreate']['icon'] = 'icon-plus';
                $this->list_buttons['ModuleDetailCreate']['btnkey'] = 'ModuleDetailCreate';
            }*/
       }
		else
        {
            $this->list_buttons['Create']['label'] = getFixedLabel('CREATE');
    		$this->list_buttons['Create']['permit'] = isPermitted($module, 'Create', '');
    		$this->list_buttons['Create']['icon'] = 'icon-plus';
            $this->list_buttons['Create']['btnkey'] = 'Create';
        }
		//搜索
        // if($module=='Reminds')
		// {
        //     $this->list_buttons['Search']['label'] = getFixedLabel('SEARCH');
        //     $this->list_buttons['Search']['permit'] = 'yes';
        //     $this->list_buttons['Search']['icon'] = 'icon-search';
        //     $this->list_buttons['Search']['btnkey'] = 'Search';
		// }
		//分配
		$Allocate = 'Allocate';
		$Allocatelabel = getFixedLabel('ALLOCATE');
		$Allocatepermit = isPermitted($module, 'Allocate', '');
		$this->list_buttons[$Allocate]['label'] = $Allocatelabel;
		$this->list_buttons[$Allocate]['permit'] = $Allocatepermit;
		$this->list_buttons[$Allocate]['icon'] = 'icon-user';
        $this->list_buttons[$Allocate]['btnkey'] = $Allocate;
        /*
		//共享
		$this->list_buttons['Share']['label'] = getFixedLabel('SHARE');
		$this->list_buttons['Share']['permit'] = isPermitted($module, 'Share', '');
		$this->list_buttons['Share']['icon'] = 'icon-user';
        */
		//删除
		$this->list_buttons['Delete']['label'] = getFixedLabel('DELETE');
		$this->list_buttons['Delete']['permit'] = isPermitted($module, 'Delete', '');
		$this->list_buttons['Delete']['icon'] = 'icon-del';
        $this->list_buttons['Delete']['btnkey'] = 'Delete';
		//批量提交
		$approve_focus = Approve::getInstance(self::$module);
		$startapprovemodule = $approve_focus->startBlocksApprove();
		$issubmit = 'no';
		if(isset($startapprovemodule[$module])) $issubmit = 'yes';
		$this->list_buttons['submitapprove']['label'] = getFixedLabel('SUBMITAPPROVAL');
		$this->list_buttons['submitapprove']['permit'] = $issubmit;
		$this->list_buttons['submitapprove']['icon'] = 'icon-check';
        $this->list_buttons['submitapprove']['btnkey'] = 'submitapprove';
		$is_set = 'no';
		if(is_admin($current_user)){//只有管理员才会显示页面设置
			$is_set = 'yes';
		}
		//页面设置

        if('yes' == isPermitted($module, 'Import', '')){//判断导入权限
			$is_import = 'yes';$more_idx = 1;
        }
        $this->list_buttons['Import']['label'] = getFixedLabel('IMPORT');
		$this->list_buttons['Import']['permit'] = $is_import;
        $this->list_buttons['Import']['icon'] = 'icon-ResetListWidth';
        $this->list_buttons['Import']['btnkey'] = 'Import';
		//更多按钮
		$this->list_buttons['More']['label'] = '···';
		$this->list_buttons['More']['permit'] = 'yes';
		$this->list_buttons['More']['icon'] = 'icon-more';
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-05-28
	 */
	public function getListMoreBtn() {
		global $current_user,$adb;
		$module = self::$module;$is_edit = 'no';$is_import = 'no';
		$is_report = 'no';$is_set = 'no';$more_idx = 0;$is_share = 'no';
        $is_downloadSelected='no';
		if('yes' == isPermitted($module, 'EditView', '')){//判断编辑权限
			$is_edit = 'yes';$more_idx = 1;
		}
  
		/*if('yes' == isPermitted($module, 'Import', '')){//判断导入权限
			$is_import = 'yes';$more_idx = 1;
		}*/

		if('yes' == isPermitted($module, 'Export', '')){//判断导出权限
			$is_report = 'yes';$more_idx = 1;
		}
        if('yes' == isPermitted($module, 'Share', '')){//判断共享权限
			$is_share = 'yes';$more_idx = 1;
		}
        // @edit:dong @date:2020/09/15 @reason: 附件批量下载
        $versioninfo=getVersionInfo();
        //edit:duan 放开批量下载权限
        //if($versioninfo['trade']=='zhongfu'){
        if('yes' == isPermitted($module, 'DownloadSelected', '')){
            $is_downloadSelected = 'yes';$more_idx = 1;
        }
        //}

        
        //共享    
        /*
		//共享
		$this->list_buttons['Share']['label'] = getFixedLabel('SHARE');
		$this->list_buttons['Share']['permit'] = isPermitted($module, 'Share', '');
		$this->list_buttons['Share']['icon'] = 'icon-user';
        */     
        $this->list_buttons['More']['list']['Share']['label'] = getFixedLabel('SHARE');
       	$this->list_buttons['More']['list']['Share']['permit'] = $is_share;
        
		//批量编辑              
        $this->list_buttons['More']['list']['mass_edit']['label'] = getFixedLabel('MASSEDIT');
       	$this->list_buttons['More']['list']['mass_edit']['permit'] = $is_edit;

        //@edit:liushuai,2021-07-05,reason:【ID1001745】灵当语音盒，增加“自动拨号”功能
        $deployarray = getSys_deploy(55);//获取系统参数设定
        if (($module == 'Accounts' || $module == 'Contacts') && is_string($deployarray['deploy_value'])&&$deployarray['deploy_value'] == '灵当语音盒') {
            $this->list_buttons['More']['list']['ContinuousDialing']['label'] = getFixedLabel('AutoDial');
            $this->list_buttons['More']['list']['ContinuousDialing']['permit'] = 'yes';
        }
        
		//导入
		//$this->list_buttons['More']['list']['Import']['label'] = getFixedLabel('IMPORT');
		//$this->list_buttons['More']['list']['Import']['permit'] = $is_import;
        
		//导出
		$this->list_buttons['More']['list']['Export']['label'] = getFixedLabel('EXPORT');
		$this->list_buttons['More']['list']['Export']['permit'] = $is_report;
        
        //下载全部附件
        $this->list_buttons['More']['list']['DownloadSelected']['label'] = getFixedLabel('DOWNLOADSELECTED');
        $this->list_buttons['More']['list']['DownloadSelected']['permit'] = $is_downloadSelected;
        
        	//变更创建人
         if($module=='ServiceContracts')
            $field_creator_name = $moduleFields['ServiceContractscreator'];
        else
            $field_creator_name = $moduleFields['creator'];
        
        $tmpfieldobj=$this->controller->fieldobj;
        $createor_field=$tmpfieldobj->getFieldInfoobjBykey('columnname','smcreatorid');
        if(!$createor_field)
        {
            $createor_field=$tmpfieldobj->getFieldInfoobjBykey('columnname','creator');
        }
        
        //18576: 销售退货单>列表/明细：隐藏创建人字段后，更改创建人按钮显示错误，并且更改创建人弹出层报错。
        if($createor_field)
        {
             
			if(get_object_vars($createor_field)!=''){
				$ChangeCreatorlabel = getFixedLabel('CHANGE').$createor_field->getfieldLabel();
			}
            
       	    $ChangeCreatorpermit = isPermitted($module, 'ChangeCreator', '');
			if($ChangeCreatorpermit == 'yes'){
				$more_idx = 1;
			}
    		$this->list_buttons['More']['list']['ChangeCreator']['label'] = $ChangeCreatorlabel;
    		$this->list_buttons['More']['list']['ChangeCreator']['permit'] = $ChangeCreatorpermit;
    		$this->list_buttons['More']['list']['ChangeCreator']['icon'] = 'icon-user';
        }

        //ls 2021-09-16 【ID1001956】增加“电子签章”功能（更多-登录电子签后台）
        if (($module == 'SalesOrder' || $module == 'ServiceContracts'||$module == 'Quotes') && is_admin($current_user)) {//wyt 230207 XUQIU1001050 报价单和服务合同增加电子签章功能（张德广）
            //检查企业是否认证激活腾讯电子签
            $focus = CRMEntity::getInstance($module);
            $electronicSignatureInfo = $focus->getElectronicSignatureInfo();
            if ($electronicSignatureInfo['isauthorize']) {
                if($electronicSignatureInfo["bought_count"] > 0){//目前没有做授权接口，暂时使用总份数判断
                    $ElectronicSignaturepermit = 'yes';
                    $ElectronicSignaturelabel = getFixedLabel('EnterpriseAuthentication');//企业实名认证
                    if ($electronicSignatureInfo["IsActivated"] == 'yes') {
                        $ElectronicSignaturelabel = getFixedLabel('ElectronicSignatureAdmin');//电子签后台
                    }
                } else {
                    $ElectronicSignaturelabel = getFixedLabel('ElectronicSignatureAdmin');
                    $ElectronicSignaturepermit = 'yes';
                }
                $this->list_buttons['More']['list']['ElectronicSignature']['label'] = $ElectronicSignaturelabel;
                $this->list_buttons['More']['list']['ElectronicSignature']['permit'] = $ElectronicSignaturepermit;
                $this->list_buttons['More']['list']['ElectronicSignature']['icon'] = 'icon-user';
            }
        }

        //产品管理更多按钮添加禁用
        if($module == 'Products')
        {
            // $discontinuedlabel = getFixedLabel('INACTIVATING');
            // $sql='select presence from ld_field where fieldlabel=?';
            // $result = $adb->pquery($sql,array($discontinuedlabel));
            // $presence = $adb->query_result($result,'0','presence');
            $fieldinfo= $tmpfieldobj->getFieldInfoobjBykey("columnname",'discontinued');
            $discontinuedpermit='no';
            //zkt   0046612: （81mis.com/kfbcrm）产品管理-产品，成员只有产品“禁用”字段的只读权限，列表处选择单据可以禁用产品；只读权限不能禁用产品
            //readonly为0时为该字段的读写权限
            if($fieldinfo&&$fieldinfo->getPresence()<>1&&(is_admin($current_user)||$fieldinfo->getReadOnly()=='0'))
            {
                $discontinuedpermit = 'yes';
            }
            if($discontinuedpermit=='yes')
            {
                $this->list_buttons['More']['list']['discontinued']['label'] = $fieldinfo->getfieldLabel();
                $this->list_buttons['More']['list']['discontinued']['permit'] = $discontinuedpermit;
                $this->list_buttons['More']['list']['discontinued']['icon'] = 'icon-user';
            }
        }
        //工商信息设置
        if($module == 'Accounts' || $module == 'ServiceCharge' || $module == 'Vendors')
        {
            if($current_user->getHaveSetProfile("Settings")=='yes')
            {
                $this->list_buttons['More']['list']['Businessquerysettings']['label'] = getFixedLabel('BUSINESSQUERYSETTINGS');
                $this->list_buttons['More']['list']['Businessquerysettings']['permit'] = 'yes';
            }
        }
        //树结构设置
		if(is_admin($current_user)){
			$this->list_buttons['More']['list']['ModuleTreeSettings']['label'] = getFixedLabel('treestruturesettings');
			$this->list_buttons['More']['list']['ModuleTreeSettings']['permit'] = 'yes';
		}
        //审批设置
        $approve_focus = Approve::getInstance(self::$module);
        $startapprovemodule = $approve_focus->getAllModuleInfo();
		$issubmit = 'no';
		if(isset($startapprovemodule[$module])&&$current_user->getHaveSetProfile("Settings")=='yes') $issubmit = 'yes'; //判断当前模块是否启用审批流程

		$this->list_buttons['More']['list']['Approvalsettings']['label'] = getFixedLabel('APPROVALSETTINGS');
		$this->list_buttons['More']['list']['Approvalsettings']['permit'] = $issubmit;
        
		//恢复列宽默认设置
		$this->list_buttons['More']['list']['ResetListWidth']['label'] = getFixedLabel('ResetListWidth');
		$this->list_buttons['More']['list']['ResetListWidth']['permit'] = 'yes';
		//chj 2020/12/25 43940: （https://61mis.com/kfbcrm [^]）（远方咨询）模块权限只有查看的时候，看不到恢复预设列宽这个功能
		//if(0 == $more_idx) $this->list_buttons['More']['permit'] = 'no';

        //批量回填
        $backfill_permit = 'no';
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($module);
        if($businessinformationobj->IsEnableBatchbackfill() && isPermitted($module, 'BatchBackFilling','')=='yes'){
            $backfill_permit = 'yes';
        }
        $btn = array();
        $btn['BatchBackFilling']['label'] = getFixedLabel('BatchBackFilling');
        $btn['BatchBackFilling']['permit'] = $backfill_permit;
        $count = count($this->list_buttons['More']['list']);
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,$count-1);
       
	}
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailViewButton() {
        $this->detail_buttons = Array();
        $this->getDetailBasicBtn();// 初始化模块基础按钮

        $this->getDetailMoreBtn();// 初始化更多按钮关联下拉列表

        $this->getCustomBtn('detail');// 获取自定义按钮

        $this->resetDetailViewButtons();// 按钮重排序
        // dump($this->detail_buttons);
        
        return $this->detail_buttons;// 返回列表按钮结果集
	}

    /**
     * @return array
     * 获取删除按钮
     */
    public function getDeleteBtn()
    {
        $approve_focus = Approve::getInstance(self::$module);;
        $startapprovemodule = $approve_focus->startBlocksApprove();
        if(isset($startapprovemodule[self::$module])){//审批模块
            //重复调用该函数，则不会重复调用单据审批权限判断，
            $this->getApproveButton(self::$module,$this->controller,$this->controller->id);
        }
            
        //删除
		$isdelete = 'no';
		if(isset($this->approvebtn['delete']) && 1 == $this->approvebtn['delete']){//审批中，不允许删除
			$isdelete = 'no';//不允许删除
		}else if('yes' == isPermitted(self::$module,'Delete',$this->controller->id)){
			$isdelete = 'yes';//允许删除
		}
		if(!empty($this->approvebtn['info'])){//没有审批历史
			//已批准、审批中、已拒绝状态下，不提交审批
			$statusarray = array(
				constant('D_A_S_APPROVED')=>'1',//已批准
				constant('D_A_S_APPROVALOF')=>'1',//审批中
				constant('D_A_S_REJECTED')=>'1'//已拒绝
			);
			if(isset($this->controller->column_fields['approvestatus']) && 
					!empty($this->controller->column_fields['approvestatus'])){
				$approvestatus = $this->controller->column_fields['approvestatus'];
				if($statusarray[$approvestatus]){
					$isdelete = 'no';
				}
			}
		}
		//删除
		$buttons['label'] = getFixedLabel('DELETE');
		$buttons['permit'] = $isdelete;
		$buttons['icon'] = 'icon-del';
        return $buttons;
    }

    public function getSettingsBtn(){
        global $current_user;
        //zxm 2021-0701 页面设置，只有管理员才会显示页面设置  -- 且以下模块不显示页面设置按钮
        $is_set = 'no';
        //edit: xll 2023/06/05 XUQIU1001203 提醒模块增加页面设置
        $noSetArr = ['BankAccountSet','Tooltip','ModTracker','lingdangBackup','Emails','OftenUseReport','SocialPromotion','PricePolicy'];
        if($current_user->getHaveSetProfile("Settings")=='yes'&&!in_array(self::$module,$noSetArr)){
            $is_set = 'yes';
        }

        $buttons['Settings']['label'] = getFixedLabel('LBL_PAGE_SET');
        $buttons['Settings']['permit'] = $is_set;
        $buttons['Settings']['icon'] = 'icon-set';
        return $buttons;
    }
    //获取编辑按钮
    public function getEditViewBtn()
    {
        $approve_focus = Approve::getInstance(self::$module);;
        $startapprovemodule = $approve_focus->startBlocksApprove();

        if(isset($startapprovemodule[self::$module])){//审批模块
            $this->getApproveButton(self::$module,$this->controller,$this->controller->id);
        }
        $module=self::$module;
        //编辑
        $buttons['label'] = getFixedLabel('EDIT');
        $buttons['permit'] = isPermitted(self::$module,'EditView',$this->controller->id);
        $buttons['icon'] = 'icon-pen';
        if(1 == $this->approvebtn['edit']){//不允许编辑
            $buttons['permit'] = 'no';
            $approvestatus = $this->controller->column_fields['approvestatus'];
            //if(constant('D_A_S_APPROVED')==$approvestatus||$approvestatus==constant('D_A_S_APPROVALOF'))
            $this->edit_errorreason=array('reason'=>'approve','description'=>$approvestatus);
    	}else{
    	   //edit:can 20231030 74546 61order-开发任务-erp任务“XUQIU1002101”，列表界面点击小编辑“优先级”字段，弹出提示信息错误 
            $this->edit_errorreason=array('reason'=>'btn','description'=>getFixedLabel("YOUARENOTALLOWEDTOEDITOTHERUSERSDATE"));
        }
        if($this->approvebtn['approve']==1&&$this->approvebtn['edit']==0)
        {
            //审批中的单据如果审批流程设置审批中的单据可以编辑，那么当前审批人是可以编辑
    		$buttons['permit'] = 'yes';
            $this->edit_errorreason=array();
        }

        if(empty($this->approvebtn['info']) && isset($startapprovemodule[self::$module]))
        {
            //edit:can 20221102 58266 审批状态为已批准的单据，在列表界面可以小编辑 
            //已批准、审批中、已拒绝状态下，不提交审批
            $statusarray = array(
                constant('D_A_S_APPROVED')=>'1',//已批准
                constant('D_A_S_APPROVALOF')=>'1',//审批中
                constant('D_A_S_REJECTED')=>'1'//已拒绝
            );
            if(isset($this->controller->column_fields['approvestatus']) &&
        				!empty($this->controller->column_fields['approvestatus'])){
                $approvestatus = $this->controller->column_fields['approvestatus'];
        	 
                //没有审批历史，但审批状态为已批准，不允许编辑
                switch($approvestatus){
                    case constant('D_A_S_APPROVED'):

                    case constant('D_A_S_REJECTED')://已批准，已拒绝，不允许修改
                        $buttons ['permit'] = 'no';
                          $this->edit_errorreason=array('reason'=>'approve','description'=>$approvestatus);
                        break;
                    case constant('D_A_S_APPROVALOF'):
                        global $current_user;
                        if(!is_admin($current_user)){//审批中，非管理员不允许编辑
                            $buttons ['permit'] = 'no';
                            $this->edit_errorreason=array('reason'=>'approve','description'=>$approvestatus);
                        }
                        break;
                }
            }
        }
        return $buttons;
    }
	/**
	 * 获取详情页按钮对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailBasicBtn() {
		global $adb,$current_user;
        $isshare = 'no';$is_set = 'no';$more_idx = 0;$is_downloadSelected='no';
	    if('yes' == isPermitted(self::$module,'Share')){
			$isshare = 'yes';$more_idx = 1;
		}
		$module = self::$module;
       	//审批
		$approve_focus = Approve::getInstance(self::$module);;
		$startapprovemodule = $approve_focus->startBlocksApprove();
        if(isset($startapprovemodule[self::$module])){//审批模块
            $this->getApproveButton(self::$module,$this->controller,$this->controller->id);
        }
       	$fieldObj = Field::getInstance($module,$adb);
	    $moduleFields = $fieldObj->getModuleFields();      
        $field_creator = $moduleFields['smcreatorid'];

		//编辑
        if($module=='LessionPlan')
        {
            $this->detail_buttons['moduledetailEdit']=$this->getEditViewBtn();
        }
        else
		{
            $this->detail_buttons['Edit']=$this->getEditViewBtn();
		}
       
        //关闭
        if($module=='ProjectTask'){
       	   $permit ='yes';
           $focus = CRMEntity::getInstance($module);           
           $focus->retrieve_entity_info($this->controller->id,$module);
           if($focus->column_fields['projecttaskstatus']=='已完成'){
            	$permit = 'no';
           }          
           $this->detail_buttons['Close']['label'] = getFixedLabel('CLOSE');
           $this->detail_buttons['Close']['permit'] = $permit;
           $this->detail_buttons['Close']['icon'] = 'icon-del';               
        }
	
		//分配
		$Allocate = 'Allocate';
		$Allocatelabel = getFixedLabel('ALLOCATE');
		$Allocatepermit = isPermitted(self::$module,'Allocate');
      
		if(self::$module == 'Accounts'){
			global $static_publicaccount,$current_user;
			if($static_publicaccount == 1&&isSearchCRMVersion()!='yes'){
				crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
				$cls_PublicAccounts = cls_PublicAccounts::getInstance($currentModule);
				$public_account = $cls_PublicAccounts->getPublicAccountConfig();
				$query = "select pool_id,publicaccount from ld_account where accountid = ?";
				$result = $adb->pquery($query,array($this->controller->id));
				$pool_id = $adb->query_result($result,0,0);
				//$status=getAccount_Set('status');
				$accounttype = 'ALLACCOUNT';
				if(isset($_REQUEST['pagepublicaccounttype'])){
					$accounttype = $_REQUEST['pagepublicaccounttype'];
				}elseif(isset($_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'])){
					$accounttype = $_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'];
				}
               
				//$adminaccount=getAccount_Set("adminaccount");
				//$splitadmin=explode(",",$adminaccount);
				//edit:can 20210510 045791: （不提供外网）广州南瀚（王庆）使用admin账号时，进入客户（广州市花都区新华睿达商店（百威啤酒））的详情页面，没有分配按钮
                $administrators_arr = explode(',',(string)$public_account['public_account_pool'][$pool_id]['administrators']);
                $allow_users_arr = explode(',',(string)$public_account['public_account_pool'][$pool_id]['allow_users']);
				if($public_account['status']=='yes'&&(in_array($current_user->id,$administrators_arr) || in_array($current_user->id,$allow_users_arr))){
					$Allocate = 'massallocate';
					$Allocatelabel = getFixedLabel('ALLOCATE');
					$Allocatepermit = 'yes';
				}elseif ($public_account['status']=='yes'){
					$Allocatepermit = 'no';
				}
                //edit:can 74112 企业微信端--公海客户--点击更多--无法领取客户（具体见附件视频） 
                $this->receivebtn = $this->getReceiveBtn($public_account['public_account_pool'],$pool_id) ;
               
                
			}
			
		}

        if(self::$module == 'Leads'){
            global $static_publicleads,$current_user;
            if($static_publicleads == 1&&isSearchCRMVersion()!='yes'){
                crm_load_class_file('cls_PublicLeads', 'modules/Leads');
                $cls_PublicLeads = new cls_PublicLeads($currentModule);
                $public_account = $cls_PublicLeads->getPublicAccountConfig();
                $query = "select pool_id,publicaccount from ld_leads where leadsid = ?";
                $result = $adb->pquery($query,array($this->controller->id));
                $pool_id = $adb->query_result($result,0,0);
                //$status=getAccount_Set('status');
                $accounttype = 'ALLACCOUNT';
                if(isset($_REQUEST['pagepublicaccounttype'])){
                    $accounttype = $_REQUEST['pagepublicaccounttype'];
                }elseif(isset($_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'])){
                    $accounttype = $_SESSION['lvsAccount']['Accounts']['pagepublicaccounttype'];
                }
                //$adminaccount=getAccount_Set("adminaccount");
                //$splitadmin=explode(",",$adminaccount);
                //edit:can 20210510 045791: （不提供外网）广州南瀚（王庆）使用admin账号时，进入客户（广州市花都区新华睿达商店（百威啤酒））的详情页面，没有分配按钮
                if($public_account['status']=='yes'&&(in_array($current_user->id,explode(',',$public_account['public_account_pool'][$pool_id]['administrators'])) || in_array($current_user->id,explode(',',$public_account['public_account_pool'][$pool_id]['allow_users'])))){
                    $Allocate = 'massallocate';
                    $Allocatelabel = getFixedLabel('ALLOCATE');
                    $Allocatepermit = 'yes';
                }elseif ($public_account['status']=='yes'){
                    $Allocatepermit = 'no';
                }
            }

        }
		$this->detail_buttons[$Allocate]['label'] = $Allocatelabel;
		$this->detail_buttons[$Allocate]['permit'] = $Allocatepermit;
		$this->detail_buttons[$Allocate]['icon'] = 'icon-user';

        //dump($this->approvebtn);

        if(isset($startapprovemodule[self::$module])){//审批模块
            //提交审批
            $this->detail_buttons['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
            $this->detail_buttons['submit']['permit'] = 'no';
            //回撤
            $this->detail_buttons['approve_retrace']['label'] = getFixedLabel('RETRACEMENT');
            $this->detail_buttons['approve_retrace']['permit'] = 'no';
            //审批
            $this->detail_buttons['approve']['label'] = getFixedLabel('APPROVAL');
            $this->detail_buttons['approve']['permit'] = 'no';
            //催审
            $this->detail_buttons['expediting']['label'] = getFixedLabel('Expediting');
            $this->detail_buttons['expediting']['permit'] = 'no';
            //反审批
            $this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
            $this->detail_buttons['cancel']['permit'] = 'no';
			if(!empty($this->approvebtn['info'])){
				if(1 == $this->approvebtn['submit']){//提交审批
					$this->detail_buttons['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
					$this->detail_buttons['submit']['permit'] = 'yes';
					$this->detail_buttons['submit']['icon'] = 'icon-check';
				}
                else
                {
                    //判断是否显示回撤按钮
                    $retrace_permit = $approve_focus->get_retrace_permit($this->controller->id,$module);
                    if($retrace_permit == 'yes')
                    {
                        //回撤
                        $this->detail_buttons['approve_retrace']['label'] = getFixedLabel('RETRACEMENT');
    					$this->detail_buttons['approve_retrace']['permit'] = 'yes';
    					$this->detail_buttons['approve_retrace']['icon'] = 'icon-check';
                    }
                }
                
                 if(1!= $this->approvebtn['submit']&&1 == $this->approvebtn['approve']){//审批
                      
                    
					$this->detail_buttons['approve']['label'] = getFixedLabel('APPROVAL');
					$this->detail_buttons['approve']['permit'] = 'yes';
					$this->detail_buttons['approve']['icon'] = 'icon-check';
				    }
                    
                if(1== $this->approvebtn['expediting']){//催审
                  
                
    				$this->detail_buttons['expediting']['label'] = getFixedLabel('Expediting');
    				$this->detail_buttons['expediting']['permit'] = 'yes';
    				$this->detail_buttons['expediting']['icon'] = 'icon-check';
			    }
				if(1 == $this->approvebtn['cancel']){//反审批
					$this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
					$this->detail_buttons['cancel']['permit'] = 'yes';
					$this->detail_buttons['cancel']['icon'] = 'icon-aCheckout';
				}
			}else{//默认有提交审批按钮
				$submit = 1;
				//已批准、审批中、已拒绝状态下，不提交审批
				$statusarray = array(
					constant('D_A_S_APPROVED')=>'1',//已批准
					constant('D_A_S_APPROVALOF')=>'1',//审批中
					constant('D_A_S_REJECTED')=>'1'//已拒绝
				);
                
				if(isset($this->controller->column_fields['approvestatus']) && 
						!empty($this->controller->column_fields['approvestatus'])){
					$approvestatus = $this->controller->column_fields['approvestatus'];
					if($statusarray[$approvestatus]){
						$submit = 0;
					}
					//判断反审批权限
                    crm_load_class_file('cls_ApproveInfo','modules/Approve');
                    $ApproveInfoObj=new cls_ApproveInfo($approve_focus);
                    $havecancelprofile = $ApproveInfoObj->CheckCancelApproveProfile($module,$current_user);

					//没有审批历史，但审批状态为已批准，不允许编辑
					switch($approvestatus){
					    case constant('D_A_S_APPROVED'):
                        
					    case constant('D_A_S_REJECTED')://已批准，已拒绝，不允许修改
					        $this->detail_buttons['Edit']['permit'] = 'no';
							$this->detail_buttons['moduledetailEdit']['permit'] = 'no';
                            if(is_admin($current_user) || $havecancelprofile == 'yes')
                           {
                                 $this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
      					         $this->detail_buttons['cancel']['permit'] = 'yes';
               					$this->detail_buttons['cancel']['icon'] = 'icon-aCheckout';
                           }
					        break;
						case constant('D_A_S_APPROVALOF'):
							global $current_user;
						    if(!is_admin($current_user)){//审批中，非管理员不允许编辑
								$this->detail_buttons['Edit']['permit'] = 'no';
								$this->detail_buttons['moduledetailEdit']['permit'] = 'no';
							}
                            if(is_admin($current_user) || $havecancelprofile == 'yes')
                            {
                                $this->detail_buttons['cancel']['label'] = getFixedLabel('APPROVE_ANTIAPPROVAL');
                                $this->detail_buttons['cancel']['permit'] = 'yes';
                                $this->detail_buttons['cancel']['icon'] = 'icon-aCheckout';
                            }
						    break;
					}
				}
				if($submit == 1){//非已审批、审批中、已拒绝状态，允许提交审批
					$this->detail_buttons['submit']['label'] = getFixedLabel('SUBMITAPPROVAL');
					$this->detail_buttons['submit']['permit'] = 'yes';
					$this->detail_buttons['submit']['icon'] = 'icon-check';
				}
			}
		}

		//复制
		$iscopy = 'no';
		if('yes' == isPermitted(self::$module,'Copy')){
			$iscopy = 'yes';
		}
        //edit:hzx 46364: （81mis.com/kfbcrm）首页-知识管理，管理员登录操作；角色权限中，知识管理有复制权限，但在单据详情页没有复制按钮
		if(self::$module=='PaymentPlan' || self::$module=='SendPayment'){
			$iscopy = 'no';	
		}
		//复制
        if($module!="ServiceCharge"&&( $module=='LessionPlan' ))
		{
		    $this->detail_buttons['moduledetailCopy']['label'] = getFixedLabel('COPY');
    		$this->detail_buttons['moduledetailCopy']['permit'] = $iscopy;
    		$this->detail_buttons['moduledetailCopy']['icon'] = 'icon-copy';
		}
        else
        {
            $this->detail_buttons['Copy']['label'] = getFixedLabel('COPY');
    		$this->detail_buttons['Copy']['permit'] = $iscopy;
    		$this->detail_buttons['Copy']['icon'] = 'icon-copy';
        }
        //续签
		// ljj 20240524 XUQIU1002227 服务合同增加续签按钮，可自动生成单据，续签一年
        if ($module == 'ServiceContracts' && isPermitted($module,'Renew') == 'yes'){
            $this->detail_buttons['Renew']['label'] = getFixedLabel('Renew');
            $this->detail_buttons['Renew']['permit'] = 'yes';
            $this->detail_buttons['Renew']['icon'] = 'icon-reply';
        }
		//删除
		$this->detail_buttons['Delete']=$this->getDeleteBtn();
        if($this->detail_buttons['Delete']['permit']=='yes')
        {
            $more_idx = 1;//允许删除
        }
        //服务小程序码
        if($module=='Accounts'){
            $regop=RegOp::getInstance();
            $servicehelp=$regop->getservicehelp_interface();
            $sql = 'select para_three from ld_wx_config where name=\'wechat_miniprogram_setting\'';
            $result = $adb->pquery($sql,array());
            $nums = $adb->num_rows($result);
            if($nums > 0) {
                $coid = $adb->query_result($result, 0, 'para_three');
            }
            $coid = 1;
            if($servicehelp!=0 && $coid > 0){
                $this->detail_buttons['AccountSelfserviceQRcode']['label'] = getFixedLabel('SELFSERVICEQRCODE');
                $this->detail_buttons['AccountSelfserviceQRcode']['permit'] = 'yes';
                $this->detail_buttons['AccountSelfserviceQRcode']['icon'] = 'icon-selfserviceqrcode';
            }
        }



		//共享
        
		$this->detail_buttons['More']['list']['Share']['label'] = getFixedLabel('SHARE');
		$this->detail_buttons['More']['list']['Share']['permit'] = $isshare;

        $is_set = 'no';
        if($current_user->getHaveSetProfile("Settings")=='yes'){
            $is_set = 'yes';
        }
		//页面设置，只有管理员才会显示页面设置--20221121 zxm 注释 页面设置按钮不在这里显示了
		$this->detail_buttons['Settings']['label'] = getFixedLabel('LBL_PAGE_SET');
		$this->detail_buttons['Settings']['permit'] = $is_set;
		$this->detail_buttons['Settings']['icon'] = 'icon-set';
        $is_set = 'no';
        if(is_admin($current_user))
        {
            $is_set = 'yes';
        }
		//相关信息设置，只有管理员才会显示页面设置
		/** 
        * @edit:diony 
        * @date:2020-08-31 
        * @reason:【单据查看详情界面增加【相关信息设置】按钮】 https://www.tapd.cn/20699121/prong/stories/view/1120699121001001035
        * @description:添加
        */
        //--20221121 zxm 注释 相关信息设置按钮不在这里显示了
		$this->detail_buttons['RelevantSettings']['label'] = getFixedLabel('PROJECTSETTINGS');
		$this->detail_buttons['RelevantSettings']['permit'] = $is_set;
		$this->detail_buttons['RelevantSettings']['icon'] = 'icon-set2';

        //更多按钮 zxm 20221121 更多 文字改成...
        $this->detail_buttons['More']['label'] = '···';
        $this->detail_buttons['More']['permit'] = 'yes';
        $this->detail_buttons['More']['icon'] = 'icon-more';

        $versioninfo=getVersionInfo();
		if($module=="Products"){
            if($versioninfo['account']!='dongmao'){
                //zxm 2021-0120【微信端：产品编码、选择产品、产品列表搜索增加扫码功能】 https://www.tapd.cn/63637123/prong/stories/view/1163637123001000730
                $this->detail_buttons['More']['list']['ProductQrCode']['label'] = getFixedLabel('PRODUCTQRCODE');
                $this->detail_buttons['More']['list']['ProductQrCode']['permit'] = 'yes';
                $this->detail_buttons['More']['list']['ProductQrCode']['icon'] = 'icon-selfserviceqrcode';
            }
        }

        if($versioninfo['account'] == 'anfubao' && in_array($module,['Accounts','Contacts','SalesOrder'])){
            $this->detail_buttons['DecryptColumn']['label'] = getFixedLabel('Decrypt');
            $this->detail_buttons['DecryptColumn']['permit'] = 'yes';
        }
	}

    /**
     * @return void
     * 获取单据详情页 设置按钮 比如页面设置、单据分录设置、相关信息设置
     * zxm 20221123
     */
    public function getDetailBasicSet(){
        global $current_user;
        $module = self::$module;

        if($current_user->getHaveSetProfile("Settings")=='yes'){
            //页面设置
            $this->detail_settings['Settings']['label'] = getFixedLabel('LBL_PAGE_SET');
            $this->detail_settings['Settings']['icon'] = 'icon-set';
            $this->detail_settings['Settings']['modulename'] = $module;
            $this->detail_settings['Settings']['url'] = 'href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleManager&formodule='.$module.'"';

            $tmpfocus = CRMEntity::getInstance($module);
            if((get_file_address($module,"ProductDetails") or !empty($tmpfocus->detailfieldobj) )&&$module!='ServiceCharge'){
                $this->detail_settings['DetailsSettings']['label'] = getFixedLabel('LBL_ProductTool_field');
                $this->detail_settings['DetailsSettings']['icon'] = 'icon-set';
                $this->detail_settings['DetailsSettings']['modulename'] = $module;
                $this->detail_settings['DetailsSettings']['url'] = 'href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ProductToolField&formodule='.$module.'"';
            }
            //相关信息设置
            // if(is_admin($current_user))
            // {
                $this->detail_settings['RelevantSettings']['label'] = getFixedLabel('PROJECTSETTINGS');
                $this->detail_settings['RelevantSettings']['icon'] = 'icon-set2';
                $this->detail_settings['RelevantSettings']['modulename'] = $module;
                $this->detail_settings['RelevantSettings']['click'] = 'onclick="SetRelatedlist(ld(this),\''.$module.'\')"';
            // }
            // 通用按钮排序
            $this->detail_settings['SortButtonSettings']['label'] = getFixedLabel('Generalbuttonsorting');
            $this->detail_settings['SortButtonSettings']['icon'] = 'icon-set';
            $this->detail_settings['SortButtonSettings']['modulename'] = $module;
            $this->detail_settings['SortButtonSettings']['click'] = 'onclick="setSortDetailButtons(ld(this),\''.$module.'\','.$tmpfocus->id.')"';
        }
    }
	/**
	 * 获取详情页更多按钮下拉列表对象
	 * @author Tujt 2015-06-03
	 */
	public function getDetailMoreBtn() {
		global $current_user,$adb;


        if($current_user->getHaveSetProfile("Settings")=='yes'){
			$is_set = 'yes';$more_idx = 1;
		}
        // @edit:dong @date:2020/09/15 @reason: 附件批量下载
        $versioninfo=getVersionInfo();
        if($versioninfo['trade']=='zhongfu'){
            if('yes' == isPermitted(self::$module, 'DownloadSelected', '') ){
                 $is_downloadSelected = 'yes';$more_idx = 1;
            }
        }
		//lmq 230621 勾选打印操作按钮，角色对应的成员，单据列表和单据查看详情界面更多中都显示“打印”操作按钮，不勾选则不显示
		$printbtn_permit = isPermitted(self::$module,'Print');
        if($printbtn_permit == 'yes'){
            //ls 2022-08-09  打印模板定制，增加参数“是否审批通过后才允许打印（打印工具显示在页面设置的前面）
            $query  = 'select printtab from ld_tab where `name` = ?';
            $result = $adb->pquery($query,array(self::$module));
            $printtab = $adb->query_result($result,0,0);
            if($printtab == 1){
                $print_permit = 'yes';
            }else{
                $print_permit = 'no';
            }
            $this->detail_buttons['More']['list']['Print']['label'] = getFixedLabel('PRINTTOOL');
            $this->detail_buttons['More']['list']['Print']['permit'] = $print_permit;
            $this->detail_buttons['More']['list']['Print']['icon'] = 'icon-print';
        }
        //变更创建人
    
        $tmpfieldobj=$this->controller->fieldobj;
        $createor_field=$tmpfieldobj->getFieldInfoobjBykey('columnname','smcreatorid');
        if(!$createor_field)
        {
            $createor_field=$tmpfieldobj->getFieldInfoobjBykey('columnname','creator');
        }
        if($createor_field)
        {
              
            if(get_object_vars($createor_field)!=''){
                $ChangeCreatorlabel = getFixedLabel('CHANGE').$createor_field->getfieldLabel();
            }
       	    $ChangeCreatorpermit = isPermitted(self::$module,'ChangeCreator');
    		$this->detail_buttons['More']['list']['ChangeCreator']['label'] = $ChangeCreatorlabel;
    		$this->detail_buttons['More']['list']['ChangeCreator']['permit'] = $ChangeCreatorpermit;
    		$this->detail_buttons['More']['list']['ChangeCreator']['icon'] = 'icon-user';
        }

        //32385: 普通用户：进入单据明细界面，没有更多时，就没有“打印工具”按钮
		//if(0 == $more_idx) $this->detail_buttons['More']['permit'] = 'no';

        $this->detail_buttons['More']['list']['DownloadSelected']['label'] = getFixedLabel('DOWNLOADSELECTED');
        $this->detail_buttons['More']['list']['DownloadSelected']['permit'] = $is_downloadSelected;


        //wyt 230209 XUQIU1001050 报价单和服务合同增加电子签章功能（张德广） BUG0065227（电子章）“发起签署“这个按钮显示在页面设置前（未显示）
        $electronicsign_permit = 'no';
        if((self::$module=='SalesOrder'||self::$module=='Quotes'||self::$module=='ServiceContracts') && is_admin($current_user)) {
            //是否为企业经办人
            $query = "select proxyoperatoropenid from ld_users where id = ? and `status` = 'Active'";
            $result = $adb->pquery($query, array($current_user->id));
            $proxyoperatoropenid = $adb->query_result($result, 0, 'proxyoperatoropenid');

            //企业是否认证开通腾讯电子签 、 剩余份数remain_count是否大于0
            // $module = self::$module;
            $focus = CRMEntity::getInstance(self::$module);
            $electronicSignatureInfo = $focus->getElectronicSignatureInfo();
            //230417 wyt BUG0064881 XUQIU1001050增加电子章需求“-操作按钮没有使用人员限制，实际与需求不符
            if ($electronicSignatureInfo["isauthorize"] && $electronicSignatureInfo["IsActivated"] == 'yes' && !empty($proxyoperatoropenid) && $electronicSignatureInfo["remain_count"] > 0) {

                $electronicsign_permit = 'yes';//企业开通  且  登录用户为经办人时

                $query = 'select flowstatus from ld_salesorder_electronicsignet where salesorderid = ?';
                $result = $adb->pquery($query, array($this->controller->id));
                $flowstatus = $adb->query_result($result, 0, 0);//获取合同状态

                $btn = array();
                //$FlowStatus_Arr = array("INIT"=>"创建","PART"=>"签署中","REJECT"=>"拒签","CANCEL"=>"撤回","DEADLINE"=>"流签","ALL"=>"签署完成");
                if ($flowstatus == '签署完成') {//record = $this->controller->id
                    $btn['PreviewContract']['label'] = getFixedLabel('PreviewContract');//预览合同
                    $btn['PreviewContract']['permit'] = $electronicsign_permit;
                    $btn['PreviewContract']['icon'] = 'icon-return';
                } else {
                    $btn['InitiateSigning']['label'] = getFixedLabel('InitiateSigning');
                    $btn['InitiateSigning']['permit'] = $electronicsign_permit;
                    $btn['InitiateSigning']['icon'] = 'icon-return';//icon-view
                }
            }

            if (!empty($btn)) {
                $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'], $btn, -1);//页面设置按钮之前
                $this->detail_buttons['More']['list'][] = $btn;
            }
        }

        //ls 2024-03-20 XUQIU20240315-05 契约锁接口
        if(is_admin($current_user)) {
            $focus = CRMEntity::getInstance(self::$module);
            $electronicSignatureInfo = $focus->getQysElectronicSignatureInfo();
            if (in_array(self::$module,$electronicSignatureInfo['modulename']) && $electronicSignatureInfo["isauthorize"]) {

                $electronicsign_permit = 'yes';

                $query = 'select flowstatus from ld_salesorder_electronicsignet where salesorderid = ?';
                $result = $adb->pquery($query, array($this->controller->id));
                $flowstatus = $adb->query_result($result, 0, "flowstatus");//获取合同状态

                $btn = array();
                if ($electronicSignatureInfo['type'] == 'saas') {
                    if (!empty($flowstatus)) {
                        $btn['PreviewContractSaasQys']['label'] = getFixedLabel('PreviewContract');//预览合同
                        $btn['PreviewContractSaasQys']['permit'] = $electronicsign_permit;
                        $btn['PreviewContractSaasQys']['icon'] = 'icon-return';


                        if ($flowstatus == '已完成') {
                            $btn['DownloadContractSaasQys']['label'] = getFixedLabel('DownloadContract');//下载合同
                            $btn['DownloadContractSaasQys']['permit'] = $electronicsign_permit;
                            $btn['DownloadContractSaasQys']['icon'] = 'icon-return';
                        }
                    } else {
                        $btn['InitiateSigningSaasQys']['label'] = getFixedLabel('InitiateSigning');
                        $btn['InitiateSigningSaasQys']['permit'] = $electronicsign_permit;
                        $btn['InitiateSigningSaasQys']['icon'] = 'icon-return';
                    }
                }else{
                    //合同状态：DRAFT：草稿，FILLING：拟定中，SIGNING：签署中，COMPLETE：已完成，REJECTED：已退回，RECALLED：已撤回，EXPIRED：已过期，TERMINATING：作废中，TERMINATED：已作废，DELETE：已删除，FINISHED：强制完成
                    if (in_array($flowstatus,array('签署中','已完成','已退回','已撤回','已过期','作废中','已作废','已删除','强制完成'))) {
                        $btn['PreviewContractQys']['label'] = getFixedLabel('PreviewContract');//预览合同
                        $btn['PreviewContractQys']['permit'] = $electronicsign_permit;
                        $btn['PreviewContractQys']['icon'] = 'icon-return';
                    } else {
                        $btn['InitiateSigningQys']['label'] = getFixedLabel('InitiateSigning');
                        $btn['InitiateSigningQys']['permit'] = $electronicsign_permit;
                        $btn['InitiateSigningQys']['icon'] = 'icon-return';//icon-view
                    }
                }
            }

            if (!empty($btn)) {
                $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'], $btn, -1);//页面设置按钮之前
                $this->detail_buttons['More']['list'][] = $btn;
            }
        }

        //ls 240805 XUQIU20240626-13 法大大电子签接口对接
        if(is_admin($current_user)) {
            $focus = CRMEntity::getInstance(self::$module);
            $electronicSignatureInfo = $focus->getFddElectronicSignatureInfo();
            if (in_array(self::$module,$electronicSignatureInfo['modulename']) && $electronicSignatureInfo["isauthorize"]) {

                $electronicsign_permit = 'yes';

                $query = 'select flowstatus from ld_salesorder_electronicsignet where salesorderid = ? and platform = ?';
                $result = $adb->pquery($query, array($this->controller->id,'fdd'));
                $flowstatus = $adb->query_result($result, 0, "flowstatus");//获取合同状态

                $btn = array();
                if (!empty($flowstatus)) {
                    $btn['PreviewContractFdd']['label'] = getFixedLabel('PreviewContract');//预览合同
                    $btn['PreviewContractFdd']['permit'] = $electronicsign_permit;
                    $btn['PreviewContractFdd']['icon'] = 'icon-return';
                } else {
                    $btn['InitiateSigningFdd']['label'] = getFixedLabel('InitiateSigning');//发起签署
                    $btn['InitiateSigningFdd']['permit'] = $electronicsign_permit;
                    $btn['InitiateSigningFdd']['icon'] = 'icon-return';
                }

            }

            if (!empty($btn)) {
                $this->detail_buttons['More']['list'] = f_array_insert($this->detail_buttons['More']['list'], $btn, -1);//页面设置按钮之前
                $this->detail_buttons['More']['list'][] = $btn;
            }
        }
	}
	/**
	 * 获取单据审批按钮权限
	 * @param String $module 模块名
	 * @param Object $focus 当前模块对象结果集
	 * @param Integer $record 当前单据ID
	 * @return Array 审批按钮权限
	 * @author Tujt 2015-06-03
	 */
	public function getApproveButton($module,$focus,$record) {
	    global $current_user;
      
		if(!isset(self::$approvebtnarr[$record])){
		
			$approve_focus = Approve::getInstance(self::$module);
			$approveinfo = $approve_focus->approveStatus($record);
            
          
			$blockbuttons = $approve_focus->blocksButton($focus->column_fields['assigned_user_id'],$record,self::$module);
			//编辑、审批提交等按钮是否显示
     
			self::$approvebtnarr[$record]['edit'] = $blockbuttons[0];
			self::$approvebtnarr[$record]['submit'] = $blockbuttons[1];
			self::$approvebtnarr[$record]['approve'] = $blockbuttons[2];
			self::$approvebtnarr[$record]['delete'] = $blockbuttons[3];
			$iscancel = $approve_focus->getCancelApprovedBtn($module,$record,$focus->column_fields,$blockbuttons);
          
            if(!is_admin($current_user)&&($approveinfo['logconcurrentid']>0||$approveinfo['billlogconcurrentid']>0)&&$focus->column_fields['approvestatus']!=constant('D_A_S_APPROVED'))
            {
                self::$approvebtnarr[$record]['cancel'] = $iscancel;//XUQIU1000254 xxy 2023-12-27 审批流程定制，若是设置允许反审批参数，并发审批的“前一步骤审批人”和“并发审批人”增加反审批功能（徐东）
            }
            else
			 self::$approvebtnarr[$record]['cancel'] = $iscancel;
            //催审按钮
            $crmapprovestatus = $this->controller->column_fields['approvestatus'];
            $isexpediting = $approve_focus->getExpeditingBtn($module,$record,$crmapprovestatus);
            self::$approvebtnarr[$record]['expediting'] = $isexpediting;
			self::$approvebtnarr[$record]['info'] = $approveinfo;
		}
		return $this->approvebtn = self::$approvebtnarr[$record];
	}
	/**
	 * 获取审批状态对应的图片
	 * @author Tujt 2015-06-13
	 */
	public function getApproveImage(){
	   global $adb;
		if(!isset($this->approvebtn['info'])) return '';
		$approveimg = '';$approvestatus = 0;
		//if(!empty($this->approvebtn['info'])){//有审批历史
		//	$approvestatus = $this->approvebtn['info']['approvestatus'];
		//}else{//没有审批历史，有可能是导入的数据，审批状态不一定就是未提交
        if(!array_key_exists('approvestatus',$this->controller->column_fields)&&empty($this->controller->column_fields['approvestatus']))
        {
            //审批状态字段隐藏
            $sql= "select approvestatus from "  .$this->controller->table_name." where "  .$this->controller->table_index."=?";
            $result=$adb->pquery($sql,array($this->controller->id));
            $this->controller->column_fields['approvestatus']=$adb->query_result($result,0,0);
            
        }
        
			$approvestatus = Approve::getInstance(self::$module)->getApproveStatus(
								$this->controller->column_fields['approvestatus']);
		//}
      
		if(empty($approvestatus)) $approvestatus = 0;
		if('en' == $this->language){
			$approveimg = 'themes/images/approveresult'.$approvestatus.'_en.png';
		}else{
			$approveimg = 'themes/images/approveresult'.$approvestatus.'.png';
		}
		return $approveimg;
	}
    //lqt 20230531 获取审批状态标签
    public function getApproveTag(){
       global $adb;
        if(!isset($this->approvebtn['info'])) return '';
        $approvetag = '';$approvestatus = 0;
        
        if(!array_key_exists('approvestatus',$this->controller->column_fields)&&empty($this->controller->column_fields['approvestatus']))
        {
            //审批状态字段隐藏
            $sql= "select approvestatus from "  .$this->controller->table_name." where "  .$this->controller->table_index."=?";
            $result=$adb->pquery($sql,array($this->controller->id));
            $this->controller->column_fields['approvestatus']=$adb->query_result($result,0,0);
            
        }
        $rawvalur_approvestatus = $this->controller->column_fields['approvestatus'];
        $approvestatus = Approve::getInstance(self::$module)->getApproveStatus($rawvalur_approvestatus);
        $value_style = '';
        //读取颜色设置
        $translate_dbvalues= getTranslateDbValueNew(self::$module,'approvestatus');
        if(!empty($translate_dbvalues[$rawvalur_approvestatus])){
            $fieldvaluecolor = $translate_dbvalues[$rawvalur_approvestatus]['value_color'];
            $show_label = getFixedLabel($translate_dbvalues[$rawvalur_approvestatus]['labelbol']);
            //将颜色转为rgb
            $value_style = 'style="max-width: 200px;';
            if(!empty($fieldvaluecolor) && strpos($fieldvaluecolor, '#') !== false){
                $hexColor = ltrim($fieldvaluecolor, '#');
                $color_arr = [];
                // 正则表达式匹配十六进制颜色代码
                if (preg_match('/^([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i', $hexColor, $matches)) {
                    // 转换为RGB并返回数组
                    $color_arr = array(
                        'red'   => hexdec($matches[1]),
                        'green' => hexdec($matches[2]),
                        'blue'  => hexdec($matches[3])
                    );
                }
                $value_style .= 'color:rgb('.implode(',',$color_arr).');border-color:rgb('.implode(',',$color_arr).');background-color:rgba('.implode(',',$color_arr).',0.1);';
            }
            $value_style .= '"';
        }else{
            $show_label = getFixedLabel('approveresult'.$approvestatus);
        }
        if(empty($approvestatus)) $approvestatus = 0;
        $approvetag = '<span class="ld-tags tag-'.$approvestatus.' overflow-space"  '.$value_style.' >'.$show_label.'</span>';
        return $approvetag;
    }
	/**
	 * 获取对应的关联创建
	 * @author Tujt 2015-06-17
	 */
	public function getActionUserd() {
	/*	if(empty($this->quickactionLink)){
			$tabid = getTabid(self::$module);
			$quickactionarr = $this->getQuickActionsInfo($tabid);
			if(empty($quickactionarr)) return '';
			//销售退货、销售退款、采购退货、采购退款 是没有新增权限的，所有在这里只判断模块权限
			$moduleaction = array(
				'SalesBack'=>1,'PurchaseBack'=>1,
				'PurchaseCashBack'=>1,'CashBack'=>1,
				'PaymentPlan'=>1,'SendPayment'=>1,
                'Rate'=>1
			);
			//点击事件
			$moduleclick = array(
				'56'=>getFixedLabel('Send_SMS'),//短信
				'10'=>getFixedLabel('Send_mail'),//邮件
			);
			$lbl_creates = getFixedLabel('LBL_Creates');
			//模块对应主键
			$modidx = array('SalesOrder'=>'salesorder_id','Potentials'=>'potential_id','Rate'=>'rate_id',
							'HelpDesk'=>'troubleticketid','PurchaseOrder'=>'purchaseorder_id',
							'PurchaseBack'=>'purchaseback_id','Accounts'=>'account_id','ServiceCharge'=>'account_id');
			foreach($quickactionarr as $key=>$mod){
				$this->quickactionLink[$key]['module'] = $mod;
				$this->quickactionLink[$key]['record'] = $this->controller->id;//携带的
				if($key > 0){//关联模块
					if(isset($moduleclick[$key])){
						$this->quickactionLink[$key]['label'] = $moduleclick[$key];//标签
						$this->quickactionLink[$key]['click'] = '1';//指定点击事件
					}else{
						$permit = 'no';
						if(isset($moduleaction[$mod])){
							$permit = isPermitted($mod,'index');
						}elseif(vtlib_isModuleActive($mod)){
							//Liver2016/06/22 因为服务回访单没有创建权限，所以改为根据编辑权限判断。
							if($mod == 'ServiceReturn'){

                               $permit = isPermitted($mod,'EditView');
							}else{
								$permit = isPermitted($mod,'Create');
							}
							
						}
						if('no' == $permit) continue;
						$this->quickactionLink[$key]['label'] = $lbl_creates.' '.getTranstab($mod);//标签
						$this->quickactionLink[$key]['return_module'] = $mod;//保存后返回的模块
						$this->quickactionLink[$key]['return_action'] = 'DetailView';//保存后返回的页面
						$this->quickactionLink[$key]['return_id'] = $this->controller->id;//返回的单据ID
						//$this->quickactionLink[$key]['tag'] = '';//url，附加在创建链接后面
						$this->quickactionLink[$key]['click'] = '';//指定点击事件
						$tag = '';
						if(isset($this->controller->column_fields['account_id']) && $this->controller->column_fields['account_id'] > 0){
							$tag = '&account_id='.$this->controller->column_fields['account_id'];
						}
						if(isset($this->controller->column_fields['contact_id']) && $this->controller->column_fields['contact_id'] > 0){
							$tag .= '&contact_id='.$this->controller->column_fields['contact_id'];
						}
						if(isset($this->controller->column_fields['vendor_id']) && $this->controller->column_fields['vendor_id'] > 0){
							$tag = '&vendor_id='.$this->controller->column_fields['vendor_id'];
						}
						if(isset($modidx[self::$module])){
							$tabidx = $modidx[self::$module];
						}else{
							$tabidx = $this->controller->table_index;
						}
						$tag .= '&'.$tabidx.'='.$this->controller->id;
                        //$tag.="&frommodule=".self::$module."&quickcreate=yes&relatedcreate=yes&fromid=".$this->controller->id;
                        //Liver 2016-11-30,增加entityname、entityid，原因是出库单关联生成销售发票，需要获取这2个参数
                        $tag.="&frommodule=".self::$module."&quickcreate=yes&relatedcreate=yes&fromid=".$this->controller->id;
						$this->quickactionLink[$key]['tag'] = $tag;//指定点击事件
					}
				}else{//特别链接
                    if($key=='-10'){
                         global $current_user,$adb;
                           
                            $columname= $this->controller->getSmownerColumName();
                        // include('user_privileges/user_language_'.$current_user->id.'.php');
                        $languageType=getLanguageType($current_user);
                        
                         $getlanguageUserchange = "SELECT ld_tranlabel.fieldlabel as languageheader FROM ld_field 
                            LEFT JOIN ld_tranlabel ON ld_tranlabel.tabid=ld_field.tabid AND ld_field.fieldid=Relateid
                            where  columnname='$columname' AND ld_field.tabid=$tabid  AND trantable = 'ld_field' 
                            AND languagetype='$languageType';";
                        
           	            $headerresult = $adb->pquery($getlanguageUserchange,array());
                        $languageheader=$adb->query_result($headerresult,0,'languageheader');
                        $this->quickactionLink[$key]['label'] = $languageheader.getFixedLabel('ChangeView');
                    }else{
                        $this->quickactionLink[$key]['label'] = getFixedLabel($mod);
                    }
					$this->quickactionLink[$key]['tag'] = '';
					$this->quickactionLink[$key]['click'] = '';//指定点击事件
					$permit = 'yes';
					if('-5' == $key){
						$entityarray = getEntitynameInfo($tabid);
						if('0' == $entityarray['printtab']) $permit = 'no';//判断打印模板是否开启
					}
					if('-2' == $key){//创建 下级联系人 
						$permit =  isPermitted(self::$module,'Create');
					}
                    if('-8' == $key){//Liver 2017-04-19,bug0027874: 知识管理查看明细界面：当普通用户没有邮件管理模块权限时，关联创建中不要显示【把附件作为邮件附件发送】
                        $permit =  isPermitted('Emails','Create');
                    }
					if('no' == $permit) continue;
				}
				$this->quickactionLink[$key]['permit'] = $permit;
			}
		}
       
		return $this->quickactionLink;*/
	}
	/**
	 * 获取是否显示关联创建
	 * @author Tujt 2015-06-17
	 */
	public function getIsShowAction() {
	    if(!empty($this->quickactionLink)) return 'yes';
		return 'no';
	}
	/**
	 * 关联创建，根据传递的参数初始化模块字段值
	 * @author Tujt 2015-06-18
	 */
	public function setQuickCreateColumn($parent_module,$parent_id){
		if('Accounts' == $parent_module||'ServiceCharge'==$parent_module){
			$this->controller->column_fields['account_id'] = $_REQUEST['account_id'] = $parent_id;
			if(array_key_exists('contact_id',$this->controller->column_fields)){
				$contactid = getreferencecontactid($parent_id);
			    if($contactid >0){
			        $this->controller->column_fields['contact_id'] = $_REQUEST['contact_id'] = $contactid;
			    }
			}
		}elseif('Contacts' == $parent_module){
			$this->controller->column_fields['contact_id'] = $_REQUEST['contact_id'] = $parent_id;
			if(array_key_exists('account_id',$this->controller->column_fields)){
				$parent_focus = CRMEntity::getInstance($parent_module);
				$parent_focus->id = $parent_id;
				$parent_focus->retrieve_entity_info($parent_id,$parent_module);
			    if($parent_focus->column_fields['account_id'] >0){
			        $this->controller->column_fields['account_id'] = $_REQUEST['account_id'] = $parent_focus->column_fields['account_id'];
			    }
			}
		}else{
			$entityarray = getEntitynameInfo(getTabid($parent_module));
			if(isset($this->controller->column_fields[$entityarray['entityidcolumn']])){
				$this->controller->column_fields[$entityarray['entityidcolumn']] = $parent_id;
			}
		}
		//关联创建 - formmodule
		if(!empty($_REQUEST['fromid'])){
			global $adb;
			$frommodule = getSalesEntityType($_REQUEST['fromid']);
			$fieldobj=Field::getInstance(self::$module,$adb);
			crm_load_class_file('cls_module_uitype','include/fields');
			$uitypes=cls_module_uitype::getModuleAllUtitype($frommodule);
			$multi_uitypes=cls_module_uitype::getModuleAllUtitype_multi($frommodule);
            foreach($uitypes as $tmpuitype)
			{
    			 $fieldname=$fieldobj->getFieldInfoBykeyValue('uitype',$tmpuitype,'fieldname');
    			if(!empty($fieldname)){
    				$this->controller->column_fields[$fieldname] = $_REQUEST['fromid'];
    			}
            }
            foreach($multi_uitypes as $tmpuitype)
            {
                $fieldname=$fieldobj->getFieldInfoBykeyValue('uitype',$tmpuitype,'fieldname');
                if(!empty($fieldname)){
                    $this->controller->column_fields[$fieldname] = $_REQUEST['fromid'];
                }
            }
		}
	}
   
    public function setEffectValue($curmodule,$recordid,$curcolumn)
    {
        //if($this->ii>=3)
          //  return ;
    
        $cls_ParentRelatedFields = new cls_ParentRelatedField_Data($curmodule,$recordid,$curcolumn);
        $cls_ParentRelatedFields->isRelateCreate='yes';
        
		$relatedfielddata = $cls_ParentRelatedFields->getEffectValues();

        
        $effectfieldid_arr = [];
        $this->effectfieldid_arr = [];
        foreach($cls_ParentRelatedFields->cls_RelatedField_Data->allRelatedField as $tmpindex=>$effectfieldinfo_arr)
        {
            foreach($effectfieldinfo_arr as $tmptype=>$effectfieldinfo)
            $effectfieldid_arr[] = $this->effectfieldid_arr[] = $effectfieldinfo['effect_fieldid'];
        }
        
        $referencefield_arr=[];
       /* echo '<pre>';
        print_r($cls_ParentRelatedFields->cls_RelatedField_Data->allRelatedField);
        echo '</pre>';*/
        

       if(!empty($relatedfielddata)){
        //跟进记录引用联系人字段 ，客户创建跟进记录

           foreach($relatedfielddata as $data_infos){

               $tmpfieldinfo=$this->controller->fieldobj->getFieldInfoobjBykey("fieldname",$data_infos['columnname']);
               //duan 2022-6-1如果对应的引用字段为空或未启用,则不继续赋值
               if(empty($tmpfieldinfo) || empty($data_infos['value'])){
                   continue;
               }
               $uitype=$tmpfieldinfo->getUIType();
               if(array_key_exists($data_infos['columnname'],$this->effectcolumn_arr))
                   continue;
               if($tmpfieldinfo->getBigType()==REFERENCE_FIELD)
                   $referencefield_arr[]=['fieldinfo'=>$tmpfieldinfo,'value'=>$data_infos['value']];
                 
               $this->effectcolumn_arr[$data_infos['columnname']]='';
                  
               if($tmpfieldinfo&&($tmpfieldinfo->getFieldType()==REFERENCE_FIELD)) {
                   if($fromfocus) {
                       //29420: 报价单选择好客户联系人，下推生成合同订单，联系人自动变更成客户的首要联系人
                       $fromfieldname=$fromfocus->fieldobj->getFieldInfoBykeyValue("uitype",$uitype,"fieldname");
                       if($fromfocus->column_fields[$fromfieldname]!='')
                       {
                           $this->controller->column_fields[$data_infos['columnname']] = $fromfocus->column_fields[$fromfieldname];
                       }
                       else {
                            $this->controller->column_fields[$data_infos['columnname']] = $data_infos['value'];
                       }
                   }
               }
               else{
                   $this->controller->column_fields[$data_infos['columnname']] = $data_infos['value'];
                   //wym BUG0074511 如果有附件或图片类型的引用字段，需要在focus对象上添加fieldjsondata
                   if($uitype==1109||$uitype==69){
                       $this->controller->fieldjsondata[$data_infos['columnname']]=$data_infos['value'][$data_infos['columnname']];
                   }
               }
           }
       }
        foreach($referencefield_arr as $tmpinfo)
        {
            
            
            $this->setEffectValue($curmodule,$tmpinfo['value'],$tmpinfo['fieldinfo']->getFieldName());
        }
    }
	//关联创建带出值
	public function setQuickCreateColumnValues($curmodule,$recordid,$curcolumn=''){
	  
        global $adb;
        $this->effectcolumn_arr=[];
        $version=getVersionTradeInfo();
		crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
       if($_REQUEST['frommodule']=='ServiceCharge')
       {
            $sql='select ld_contactdetails.contactid from ld_account INNER JOIN ld_contactdetails
                on ld_contactdetails.accountid=ld_account.accountid
                and ld_contactdetails.reference=1 and ld_contactdetails.deleted=0 where ld_account.accountid=?';
            
            //edit:can 20210204 44596: （本地8.3.7.2）服务收费管理-相关信息创建跟进记录，销售机会等单据；只带入了客户名，联系人姓名没有带入
            $result=$adb->pquery($sql,array($recordid));
            if($adb->num_rows($result)>0)
                $this->controller->column_fields['contact_id']=$adb->query_result($result,0,'contactid');
            
       }


        $this->setEffectValue($curmodule,$recordid,$curcolumn);
        $this->effectcolumn_arr=[];
        if($_REQUEST['relatedcreate']=='yes')
        {//服务收费管理管理创建联系人和跟进记录带不出客户名称
			//chj 2021/1/18 44313: （http://51mis.com.cn/XS/hzxmz/ [^]）正式加盟商（服务收费管理）相关信息创建，带不出单据编号和名称（杭州小拇指）；
           /* if($_REQUEST['frommodule']=="ServiceCharge")
            {
                $_REQUEST['frommodule']='Accounts';
            }*/
            $frommodule=$_REQUEST['frommodule'];
          
                $curfocus=CRMEntity::getInstance($curmodule);
            if($frommodule==$curmodule)
            {
                //管理创建子合同
                $fromfocus=new $frommodule();
            }
            else
             $fromfocus=CRMEntity::getInstance($_REQUEST['frommodule']);
             
            $fromfocus->retrieve_entity_info($_REQUEST['fromid'],$_REQUEST['frommodule']);
          
            $tmpfieldinfo=$curfocus->fieldobj->getFieldInfoobjBykey('uitype',102);//项目立项选择原单
            $tmpfieldinfo_112=$curfocus->fieldobj->getFieldInfoobjBykey('uitype',112);//项目立项选择原单
            $fromuitypes=array();
            $frommodule_fieldname='';
            if($tmpfieldinfo&&($frommodule=='SalesOrder'||$frommodule=='ServiceContracts'))
            {
                $tmpfieldname=$tmpfieldinfo->getFieldName();
                $this->controller->column_fields[$tmpfieldname]=$_REQUEST['fromid'];
                $frommodule_fieldname=$tmpfieldname;
            }else if($tmpfieldinfo_112 && in_array($curmodule,['Reminds','Attachment','ModComments'])){
                $tmpfieldinfo=$tmpfieldinfo_112;//相关对象  关联创建需要带出
                $tmpfieldname=$tmpfieldinfo->getFieldName();
                $this->controller->column_fields[$tmpfieldname]=$_REQUEST['fromid'];
                $frommodule_fieldname=$tmpfieldname;
            }
           else
            {
			   //edit chj 2021/9/13 服务收费关联创建模块，无法带出服务收费人
                //edit duan 2021/12/24 取消注释 服务收费管理关联创建单据，无法带出客户名称
                if($_REQUEST['frommodule']=='ServiceCharge' && $version['trade'] != 'yongdingcheng')
                {
                    //edit:can 2021 
                    $uitypes= cls_module_uitype::getModuleAllUtitype('Accounts');
                    //zkt 20240918 BUG20240913-27 （http://58.56.130.134:85/crm）8643版本，任意商机Potentials，通过详情上方的相关信息，新建销售合同时，销售合同的“商机”字段为空值。
                    $multi_uitypes=cls_module_uitype::getModuleAllUtitype_multi('Accounts');
                    if(!empty($multi_uitypes)){
                        $uitypes = array_merge($uitypes,$multi_uitypes);
                    }
                }
                else{
                    $uitypes= cls_module_uitype::getModuleAllUtitype($_REQUEST['frommodule']);
                    //zkt 20240918 BUG20240913-27 （http://58.56.130.134:85/crm）8643版本，任意商机Potentials，通过详情上方的相关信息，新建销售合同时，销售合同的“商机”字段为空值。
                    $multi_uitypes=cls_module_uitype::getModuleAllUtitype_multi($_REQUEST['frommodule']);
                    if(!empty($multi_uitypes)){
                        $uitypes = array_merge($uitypes,$multi_uitypes);
                    }
                }
                $uitype_modules=cls_module_uitype::getUitypeModules();
             
                 foreach($uitypes as $uitype)
                 {
                    //edit:can 2022 049736: （http://8.129.209.255:85/CRM/ [^]）（铨盛）1、在客户详情界面的相关信息列创建合同订单，合同订单的“销售组织”默认了为“客户名称”，该字段不需要默认。 2、合同订单的“销售组织”的设置有其他条件（如附件），在新建界面时在该字段输入不
                    if($uitype==173)
                    {
                        continue;
                    }
                    $tmpfieldinfo=$this->controller->fieldobj->getFieldInfoobjBykey("uitype",$uitype);
                    if(!empty($tmpfieldinfo))
                    {
                        $tmpfieldname = $tmpfieldinfo->getFieldName();
                        //zkt 20221219 关联创建选择源单字段，下拉框没有对应模块时不应赋值
                        if($tmpfieldinfo->getBigType() == 'selectsource'){
                            $tmpfrommodule = $_REQUEST['frommodule'];
                            if(empty($tmpfrommodule)){
                                $tmpfrommodule = getSalesEntityType($_REQUEST['fromid']);
                            }
                            $sourcemodules=getSourceModule($curmodule);
                            $havemodule= 'no';
                            foreach($sourcemodules as $tmpval){
                                if($tmpval['entitytype'] == $tmpfrommodule){
                                    $havemodule = 'yes';
                                    break;
                                }
                            }
                            if($havemodule == 'no'){
                                continue;
                            }
                        }
                        if(!empty($tmpfieldname)){
                            $fromuitypes[]=$uitype;
                            //zkt 20230922 BUG0073089 客户模块下推收入合同，自动带入合作单位出错
                            //字段为引用字段 - 且上级字段是 frommodule模块字段
                            if($tmpfieldinfo->isRelatedModuleField()){
                                continue;
                            }
                             $this->controller->column_fields[$tmpfieldname]=$_REQUEST['fromid'];
                            $frommodule_fieldname=$tmpfieldname;
                        }
                    }
                    
                 }
                  
            }
       
                
                if($_REQUEST['fromid']>0&&$_REQUEST['frommodule']!="")
                {
                
                    
                    //关联创建，引用字段值得获取
                        // $fromfocus=CRMEntity::getInstance($_REQUEST['frommodule']);
                        // $fromfocus->retrieve_entity_info($_REQUEST['fromid'],$_REQUEST['frommodule']);
                         
                         foreach($fromfocus->column_fields as $fieldname=>$value)
                         {
                             if(array_key_exists($fieldname,$this->controller->column_fields))
                             {
                                $fromfieldinfo=$fromfocus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                                if($fromfieldinfo&&$fromfieldinfo->getDisplaytype()==2)
                                {
                                    //客户最新销售机会不要关联创建
                                    continue;
                                }
                                $tmpfieldinfo=$this->controller->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
                                $bitype='';
                                $uitype='';
                                if(!$tmpfieldinfo)
                                    continue;
                                $tmpfieldid=$tmpfieldinfo->getFieldid();
                                
                                if(in_array($tmpfieldid,$this->effectfieldid_arr))
                                {
                                    continue;
                                }
                                if($tmpfieldinfo)
                                {
                                    $bitype=$tmpfieldinfo->getBigType();
                                    $uitype=$tmpfieldinfo->getUIType();
                                  
                                }
                             
                                //038019: （51mis.com/kfbcrm）客户新增界面>填写数据点击保存（需要填写备注字段值）>相关创建【服务合同】：客户单据中备注字段值自动带到服务合同中的备注字段上面。（需要补丁）
                                //038482: （51mis.com/kfbcrm）采购订单明细界面>相关创建采购发票、付款单：没有将选择源单模块带出来。（需要补丁）
                                if($bitype=='reference'&&$fieldname!=$frommodule_fieldname)//联系人相关信息创建，首要联系人
                                {
                                     //if($uitype==51)
                                      if(in_array($uitype,$fromuitypes))
                                      {
                                        continue;//合同关联创建子合同
                                      }
                                      if($bitype=='reference'&&$fromfieldinfo&&$fromfieldinfo->getUIType()!=$uitype)
                                      {
                                        //客户的上级客户
                                        //客户管理创建
                                        
                                        continue;
                                      }
                                      //客户界面添加一个选择联系人字段 值为空, 然后客户创建跟进记录,则无法带出客户的首要联系人
                                      if($this->controller->column_fields[$fieldname]=='')
                                    $this->controller->column_fields[$fieldname]=$value;
                                }
                             }
                         }
                         //东贸特殊开发-优惠券发放记录关联创建核销记录时带出客户名称
                         if($version['account'] == 'dongmao'&&$_REQUEST['frommodule']=='CustomForm96'&&$_REQUEST['module']=='CustomForm95'){
                            $this->controller->column_fields['servicecharge_id'] = $fromfocus->column_fields['account_id'];
                            $this->controller->column_fields['account_id'] = '';
                         }
                }
               
             crm_load_class_file('cls_RelateModuleField','include/fields');
            //关联创建带出引用字段（发票引用客户字段，合同订单关联创建发票）
            $clsReferencefieldobj=cls_RelateModuleField::getInstance($curmodule,$_REQUEST['fromid'],'edit');
            $column_fields=$clsReferencefieldobj->getAllFieldValueRelateCreate();

            foreach($column_fields as $fieldname=>$value)
            {
                if($fieldname!=$frommodule_fieldname&&($this->controller->column_fields[$fieldname]==''|| $this->controller->column_fields[$fieldname]==0))//联系人相关信息创建，首要联系人
                        $this->controller->column_fields[$fieldname]=$value;
            }

             
            
        }



	}
    public function getallListViewLink() {
        global $adb,$current_user;
        $module = self::$module;
        $focus = CRMEntity::getInstance($module);
        $btn = array();
        $btn['edit']['label'] = getFixedLabel('EDIT');
        if($module=='SalesOrder'||$module=='Quotes'||$module=='ServiceContracts') {
            $electronicSignatureInfo = $focus->getElectronicSignatureInfo();
            //230417 wyt BUG0064874 XUQIU1001050增加电子章需求-显示“只有经办人才有“发起签署”操作按钮”，实际测试没有限制
            if ($electronicSignatureInfo["isauthorize"] && $electronicSignatureInfo["IsActivated"] == 'yes' && !empty($proxyoperatoropenid) && $electronicSignatureInfo["remain_count"] > 0) {
                $btn['PreviewContract']['label'] = getFixedLabel('PreviewContract');//预览合同
                $btn['InitiateSigning']['label'] = getFixedLabel('InitiateSigning');//发起签署
            }
        }

        /*契约锁电子签章*/
        if (is_admin($current_user)) {
            $electronicSignatureInfo = $focus->getQysElectronicSignatureInfo();
            if (in_array(self::$module,$electronicSignatureInfo['modulename']) && $electronicSignatureInfo["isauthorize"]) {

                if ($electronicSignatureInfo['type'] == 'saas') {

                        $btn['PreviewContractSaasQys']['label'] = getFixedLabel('PreviewContract');//预览合同

                            $btn['DownloadContractSaasQys']['label'] = getFixedLabel('DownloadContract');//下载合同

                        $btn['InitiateSigningSaasQys']['label'] = getFixedLabel('InitiateSigning');//发起签署

                }else{
                    //合同状态：DRAFT：草稿，FILLING：拟定中，SIGNING：签署中，COMPLETE：已完成，REJECTED：已退回，RECALLED：已撤回，EXPIRED：已过期，TERMINATING：作废中，TERMINATED：已作废，DELETE：已删除，FINISHED：强制完成

                        $btn['PreviewContractQys']['label'] = getFixedLabel('PreviewContract');//预览合同

                        $btn['InitiateSigningQys']['label'] = getFixedLabel('InitiateSigning');//发起签署

                }



            }
            $electronicSignatureInfo = $focus->getFddElectronicSignatureInfo();
            if (in_array(self::$module,$electronicSignatureInfo['modulename']) && $electronicSignatureInfo["isauthorize"]) {

                    $btn['PreviewContractFdd']['label'] = getFixedLabel('PreviewContract');//预览合同

                    $btn['InitiateSigningFdd']['label'] = getFixedLabel('InitiateSigning');//发起签署

            }

        }
        // 列表操作列，加入自定义按钮排序
        crm_load_class_file('cls_ButtonsCustomization','modules/Settings');
        $buttoncustomizationObj = new cls_ButtonsCustomization(self::$module);
        $custom_activebuttons_arr = $buttoncustomizationObj->getActiveButtons();
        foreach ($custom_activebuttons_arr as $index => $btninfo) {
            $btn[$btninfo['btnkey']]['label'] = $btninfo['label'];
        }
        // dump($btn);

        return $btn;
    }

	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
        global $adb,$current_user;
		//if(!empty($this->listview_link)) return true;
		$approve_focus = Approve::getInstance(self::$module);
		$startapprovemodule = $approve_focus->startBlocksApprove();
		$version=getVersionTradeInfo();
		//编辑
		$this->listview_link['edit']['label'] = getFixedLabel('EDIT');
		$this->listview_link['edit']['permit'] =isPermitted(self::$module,'EditView',$record);
		$type = 'redirect';
        if(self::$module=='ServiceCharge')
            $frommodule = 'Accounts';
        else
            $frommodule = self::$module;

		if(isset($startapprovemodule[$frommodule])){//审批模块
			$type = 'approve';
		}
		$this->listview_link['edit']['click'] = 'check_edit_click(this,\''.self::$module.'\',\'%d\')';
		$r_m = self::$module;$r_a = 'ListView';$r_r = 0;$related = 0;
		//删除
		global $related_left_type;//相关信息下才显示删除按钮
		if(isset($related_left_type) && $related_left_type > 0){
			$related=1;//19984: 销售机会>相关信息>客户：操作栏有多余“转公海”按钮，点击无效
			$permit = isPermitted(self::$module,'Delete',$record);
			if($frommodule == 'Stock' || $frommodule == 'OutboundOrder'){
                require_once globalStatic::$root_directory."include/Stock/CommonStock.php";
				$focus = CRMEntity::getInstance($frommodule);
				$focus->retrieve_entity_info($record,$frommodule);
				if($focus->column_fields['presence'] == ALLOUTBOUND || $focus->column_fields['presence'] == ALLINSTOCK){//已入库和已出库不显示删除按钮
					$permit = 'no';
				}
			}
            global $related_left_mod,$related_left_record,$related_left_id;
            $RelatedListInfoAction=getRelatedListInfoById($related_left_id);
            $str=explode(",",strtolower($RelatedListInfoAction['actions']));
			$selected = 'yes';
			//东贸特殊特殊开发：活动配置相关信息，选择活动参与记录时，隐藏取消关联
			if($version['account'] == 'dongmao' && $frommodule == 'CustomForm98' && $_REQUEST['header'] == 'CustomForm99'){
				$selected = 'no';
			}
            if(in_array('select',$str) && $selected == 'yes'){//判断相关信息是否包含有选择按钮
                $this->listview_link['delete']['label'] = getFixedLabel('CANCELTHEASSOCIATED');
                $this->listview_link['delete']['permit'] = 'yes';
                $this->listview_link['delete']['click'] = 'check_delassociated_click(this,\''.self::$module.'\',\'%d\')';
                $this->listview_link['delete']['type'] = $type;
            }else{
                $this->listview_link['delete']['label'] = getFixedLabel('DELETE');
                $this->listview_link['delete']['permit'] = $permit;
                $this->listview_link['delete']['click'] = 'check_del_click(this,\''.self::$module.'\',\'%d\')';
                $this->listview_link['delete']['type'] = $type;
            }

			
			$r_m = $related_left_mod;$r_a = 'DetailView';$r_r = $related_left_record;
			$this->listview_link['delete']['result']['module'] = $r_m;
			$this->listview_link['delete']['result']['action'] = $r_a;
			$this->listview_link['delete']['result']['record'] = $r_r;
			$this->listview_link['delete']['related'] = $related;
		}
        $module=self::$module;
        // ls 2021-08-04  0047254: （https://81mis.com/kfbtest [^]）开发部测试账套-OA表单-费用报销单-审批结束后不可编辑的单据不可进入编辑页面(type为approve);
        /*if((get_file_address($module,"ProductDetails")||get_file_address($module,$module."DetailFieldsHtml"))&&$module!='ServiceCharge')
        {
            if($type=='redirect')
            {
                $type='';
            }
            $this->listview_link['edit']['type'] = "moduledetail".$type;
        }
        else*/
		  $this->listview_link['edit']['type'] = $type;
		$this->listview_link['edit']['result']['module'] = $r_m;
		$this->listview_link['edit']['result']['action'] = $r_a;
		$this->listview_link['edit']['result']['record'] = $r_r;
		$this->listview_link['edit']['related'] = $related;

        //模块是否开启电子签  目前还没做，下个需求做了再把注释放开
        //wyt 230209 XUQIU1001050 报价单和服务合同增加电子签章功能（张德广）
        // $tabid = getTabid($module);
        // $query = "select is_electronic_on from ld_tab where tabid = ? ";
        // $result = $adb->pquery($query,array($tabid));
        // $is_electronic_on = $adb->query_result($result,0,'is_electronic_on');
        // if($is_electronic_on=='yes'){
        if($module=='SalesOrder'||$module=='Quotes'||$module=='ServiceContracts') {
            global $current_user;
            $permit = 'no';
            $btn = array();
            unset($this->listview_link['InitiateSigning']);
            unset($this->listview_link['PreviewContract']);

            //是否为企业经办人
            $query = "select proxyoperatoropenid from ld_users where id = ? and `status` = 'Active'";
            $result = $adb->pquery($query, array($current_user->id));
            $proxyoperatoropenid = $adb->query_result($result, 0, 'proxyoperatoropenid');

            //企业是否认证开通腾讯电子签 、 剩余份数remain_count是否大于0
            // $module = self::$module;
            $focus = CRMEntity::getInstance($module);
            $electronicSignatureInfo = $focus->getElectronicSignatureInfo();
            //230417 wyt BUG0064874 XUQIU1001050增加电子章需求-显示“只有经办人才有“发起签署”操作按钮”，实际测试没有限制
            if ($electronicSignatureInfo["isauthorize"] && $electronicSignatureInfo["IsActivated"] == 'yes' && !empty($proxyoperatoropenid) && $electronicSignatureInfo["remain_count"] > 0) {
                $permit = 'yes';//电子签授权  且  企业开通  且  登录用户为经办人时

                $query = 'select flowstatus from ld_salesorder_electronicsignet where salesorderid = ?';
                // $query = 'select flowstatus from ld_salesorder where salesorderid = ?';
                $result = $adb->pquery($query, array($record));
                $flowstatus = $adb->query_result($result, 0, 0);//获取合同状态
                // $flowstatus = $focus->column_fields['flowstatus'];

                //$FlowStatus_Arr = array("INIT"=>"创建","PART"=>"签署中","REJECT"=>"拒签","CANCEL"=>"撤回","DEADLINE"=>"流签","ALL"=>"签署完成");
                if ($flowstatus == '签署完成' || $flowstatus=='创建'|| $flowstatus=='签署中') {//232508 wyt BUG0065595 腾讯电子签 报价单、合同订单----单据审批完成后----点击发起签署按钮，选择好模板，录入合同信息保存后----按钮没有更新为“预览合同”
                    $btn['PreviewContract']['label'] = getFixedLabel('PreviewContract');//预览合同
                    $btn['PreviewContract']['permit'] = $permit;
                    $btn['PreviewContract']['click'] = 'PreviewContract(this,\'%d\',\''.$module.'\')';
                } else {
                    $btn['InitiateSigning']['label'] = getFixedLabel('InitiateSigning');//发起签署
                    $btn['InitiateSigning']['permit'] = $permit;
                    $btn['InitiateSigning']['click'] = 'commonInitiateSigning(this,\'%d\',\''.$module.'\')';
                }

                $this->listview_link = f_array_insert($this->listview_link, $btn, -1);
            }

        // }

        }

        /*契约锁电子签章*/
        if (is_admin($current_user)) {
            $focus = CRMEntity::getInstance(self::$module);
            $electronicSignatureInfo = $focus->getQysElectronicSignatureInfo();
            if (in_array(self::$module,$electronicSignatureInfo['modulename']) && $electronicSignatureInfo["isauthorize"]) {
                $btn = array();
                unset($this->listview_link['InitiateSigningSaasQys']);
                unset($this->listview_link['PreviewContractSaasQys']);
                unset($this->listview_link['DownloadContractSaasQys']);

                $permit = 'yes';//电子签授权
                $query = 'select flowstatus from ld_salesorder_electronicsignet where salesorderid = ? order by id desc limit 1';
                $result = $adb->pquery($query, array($record));
                $flowstatus = $adb->query_result($result, 0, "flowstatus");//获取合同状态

                if ($electronicSignatureInfo['type'] == 'saas') {
                    //array("DRAFT"=>"草稿","RECALLED"=>"已撤回","SIGNING"=>"签署中","REJECTED"=>"已退回","COMPLETE"=>"已完成","EXPIRED"=>"已过期","FILLING"=>"拟定中","FAILED"=>"签署失败","INVALIDING"=>"作废中","INVALIDED"=>"已作废","DELETE"=>"已删除","END"=>"强制结束");
                    if (!empty($flowstatus)) {
                        $btn['PreviewContractSaasQys']['label'] = getFixedLabel('PreviewContract');//预览合同
                        $btn['PreviewContractSaasQys']['permit'] = $permit;
                        $btn['PreviewContractSaasQys']['click'] = 'CreateFlowSaasQysObj.PreviewContract(this,\'%d\',\''.$module.'\')';


                        if ($flowstatus == '已完成') {
                            $btn['DownloadContractSaasQys']['label'] = getFixedLabel('DownloadContract');//下载合同
                            $btn['DownloadContractSaasQys']['permit'] = $permit;
                            $btn['DownloadContractSaasQys']['click'] = 'CreateFlowSaasQysObj.DownloadContract(this,\'%d\',\''.$module.'\')';
                        }

                    } else {
                        $btn['InitiateSigningSaasQys']['label'] = getFixedLabel('InitiateSigning');//发起签署
                        $btn['InitiateSigningSaasQys']['permit'] = $permit;
                        $btn['InitiateSigningSaasQys']['click'] = 'CreateFlowSaasQysObj.CreateDraftHtml(this,\'%d\',\''.$module.'\')';
                    }
                }else{
                    //合同状态：DRAFT：草稿，FILLING：拟定中，SIGNING：签署中，COMPLETE：已完成，REJECTED：已退回，RECALLED：已撤回，EXPIRED：已过期，TERMINATING：作废中，TERMINATED：已作废，DELETE：已删除，FINISHED：强制完成
                    if (in_array($flowstatus,array('签署中','已完成','已退回','已撤回','已过期','作废中','已作废','已删除','强制完成'))) {
                        $btn['PreviewContractQys']['label'] = getFixedLabel('PreviewContract');//预览合同
                        $btn['PreviewContractQys']['permit'] = $permit;
                        $btn['PreviewContractQys']['click'] = 'PreviewContractQys(this,\'%d\',\''.$module.'\')';
                    } else {
                        $btn['InitiateSigningQys']['label'] = getFixedLabel('InitiateSigning');//发起签署
                        $btn['InitiateSigningQys']['permit'] = $permit;
                        $btn['InitiateSigningQys']['click'] = 'commonInitiateSigningQys(this,\'%d\',\''.$module.'\')';
                    }
                }


                $this->listview_link = f_array_insert($this->listview_link, $btn);
            }
        }

        if (is_admin($current_user)) {
            $focus = CRMEntity::getInstance(self::$module);
            $electronicSignatureInfo = $focus->getFddElectronicSignatureInfo();
            if (in_array(self::$module,$electronicSignatureInfo['modulename']) && $electronicSignatureInfo["isauthorize"]) {
                $btn = array();
                unset($this->listview_link['InitiateSigningFdd']);
                unset($this->listview_link['PreviewContractFdd']);
                // unset($this->listview_link['DownloadContractFdd']);

                $permit = 'yes';//电子签授权
                $query = 'select flowstatus from ld_salesorder_electronicsignet where salesorderid = ? and platform = ? order by id desc limit 1';
                $result = $adb->pquery($query, array($record,'fdd'));
                $flowstatus = $adb->query_result($result, 0, "flowstatus");//获取合同状态


                //array("DRAFT"=>"草稿","RECALLED"=>"已撤回","SIGNING"=>"签署中","REJECTED"=>"已退回","COMPLETE"=>"已完成","EXPIRED"=>"已过期","FILLING"=>"拟定中","FAILED"=>"签署失败","INVALIDING"=>"作废中","INVALIDED"=>"已作废","DELETE"=>"已删除","END"=>"强制结束");
                if (!empty($flowstatus)) {
                    $btn['PreviewContractFdd']['label'] = getFixedLabel('PreviewContract');//预览合同
                    $btn['PreviewContractFdd']['permit'] = $permit;
                    $btn['PreviewContractFdd']['click'] = 'CreateFlowFddObj.PreviewContract(this,\'%d\',\''.$module.'\')';

                    /*if ($flowstatus == '已完成') {
                        $btn['DownloadContractFdd']['label'] = getFixedLabel('DownloadContract');//下载合同
                        $btn['DownloadContractFdd']['permit'] = $permit;
                        $btn['DownloadContractFdd']['click'] = 'CreateFlowFddObj.DownloadContract(this,\'%d\',\''.$module.'\')';
                    }*/

                } else {
                    $btn['InitiateSigningFdd']['label'] = getFixedLabel('InitiateSigning');//发起签署
                    $btn['InitiateSigningFdd']['permit'] = $permit;
                    $btn['InitiateSigningFdd']['click'] = 'CreateFlowFddObj.CreateUploadFileHtml(this,\'%d\',\''.$module.'\')';
                }



                $this->listview_link = f_array_insert($this->listview_link, $btn);
            }
        }
	}
    public function getListRelateCreateButtons($record)
    {
        static $static_relatelist;
        global $adb;
        $module=self::$module;
        
        if(is_array($static_relatelist)&&sizeof($static_relatelist)>0)
        {
               
                
        }
        else
        {
            /*if(is_array($this->list_buttom_name))
            {
                    
            }
            else
            
            {*/
                $sql='select ld_relatedlists.related_tabid from ld_relatedlists
                    inner join ld_tab on ld_tab.tabid=ld_relatedlists.tabid 
                    where ld_tab.presence in(0,2) and ld_tab.name=?
                    and ld_relatedlists.islistbutton="yes" order by ld_relatedlists.sequence asc ';
                
                $result=$adb->pquery($sql,array($module));
                $rows=$adb->num_rows($result);
                if($rows>0)
                {
                    for($i=0;$i<$rows;$i++)
                    {
                        $tabname=getTabname($adb->query_result($result,$i,'related_tabid'));
                        $static_relatelist[]=array('tabname'=>getTabname($adb->query_result($result,$i,'related_tabid')),'label'=>getTranstab($tabname));
                        $this->list_buttom_name[$record][]= trim(getTranstab($tabname));
                    }
                }
                else
                {
                    $static_relatelist[]=array("label"=>'');
                }
            //  }
                
           }
            ///dump($static_relatelist);
            foreach($static_relatelist as $index=>$info)
            {
            
                if($info['label']=='')
                {
                    continue;
                }
                $relatedmodule=$info['tabname'];
                
                $html.='<a class="Anu3_a" href="javascript:void(0);" onclick="list_createRelated(\''.$module.'\',\''.$relatedmodule.'\','.$record.');" relatedid="" tag="" type="" r_m="" r_a="" r_r="" attach_id="" style="white-space:nowrap;">
							'.$info['label'].'</a> ';
            }
            return $html;
    }
	/**
	 * 获取列表操作列按钮
	 * @author Tujt 2015-06-26
	 */
	public function getListViewLink($result,$recordId,$start,$idx) {
        global $current_user;
		$record = $this->getRecordInfo($recordId);
		$this->setListViewLink($result,$record,$start,$idx);
        $this->getCustomBtn('listlink',['result' => $result,'record' => $record,'i' => $idx]);
        // dump($this->listview_link);
        $this->resetListViewLink();
		$actionLinkInfo = '&nbsp;';
		if(!empty($this->listview_link)){
			foreach($this->listview_link as $key=>$link){
				if('yes' != $link['permit']) continue;
                //相关信息relatedid                
                $relatedid = (isset($_REQUEST['relatedid'])?$_REQUEST['relatedid']:'');
				$tag = (isset($link['tag'])?$link['tag']:'');
				$type = (isset($link['type'])?$link['type']:'');
				$r_m = (isset($link['result']['module'])?$link['result']['module']:'');
				$r_a = (isset($link['result']['action'])?$link['result']['action']:'');
				$r_r = (isset($link['result']['record'])?$link['result']['record']:'');
				$attach_id = (isset($link['result']['detail_id'])?$link['result']['detail_id']:'');
                //chj 20220510 库存查询
                if($key == 'stock_view'){
                    //wym 240506 XUQIU1002419 设置产品管理的“总库存数量”字段不可见后，带产品分录的表单也应该不显示“库存查询”图标按钮（利物盛）
                    $qtyinstock_fieldinfo = $this->controller->fieldobj->getFieldInfoobjBykey('fieldname','qtyinstock');
                    if(!empty($qtyinstock_fieldinfo)){//不存在说明该字段未启用或者角色权限不可见
                        if($link['click'] == 'CRM+ERP'){
                            $strhtml= sprintf('<a title="'.getFixedLabel('SEARCHINVENTORY').'" class="Anu3_a operatetool_more" href="javascript:void(0);" 
                            onclick="'.$link['click'].';"relatedid="'.$relatedid.'" tag="'.$tag.'" data-type="'.$link['click'].'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" attach_id="'.$attach_id.'" style="white-space:nowrap;">
                            '.$link['label'].'<span><ol class="operatetool_more_content"><li onclick="search_pro_stock(this,'.$recordId.')" tag="CRM">CRM'.getFixedLabel('INVENTORY').'</li><li onclick="search_pro_stock(this,'.$recordId.')" tag="ERP">ERP'.getFixedLabel('INVENTORY').'</li></ol></span></a>',$record);
                        }else{
                            $strhtml= sprintf('<a title="'.getFixedLabel('SEARCHINVENTORY').'" class="Anu3_a operatetool_more" href="javascript:void(0);" 
                            onclick="search_pro_stock(this,'.$recordId.')" relatedid="'.$relatedid.'" tag="'.$link['click'].'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" attach_id="'.$attach_id.'" style="white-space:nowrap;">
                            '.$link['label'].'</a>',$record);
                        }
                    }else{
                        $strhtml= sprintf('<a class="Anu3_a" href="javascript:void(0);" 
                            onclick="'.$link['click'].';"relatedid="'.$relatedid.'" tag="'.$tag.'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" attach_id="'.$attach_id.'" style="white-space:nowrap;">
                            </a>',$record);
                    }
                }
                else{
                    $strhtml= sprintf('<a class="Anu3_a" href="javascript:void(0);" 
                            onclick="'.$link['click'].';"relatedid="'.$relatedid.'" tag="'.$tag.'" type="'.$type.'" r_m="'.$r_m.'" r_a="'.$r_a.'" r_r="'.$r_r.'" attach_id="'.$attach_id.'" style="white-space:nowrap;">
                            '.$link['label'].'</a>',$record);
                }
				
                            
                $actionLinkInfo.=$strhtml;
                $this->list_buttom_name[$record][]= trim($link['label']);
                $this->list_button_html[$record][$key]=$strhtml;
			}
            $actionLinkInfo.=$this->getListRelateCreateButtons($record);
		}
        
        
        $record_html_btn[$record]=$actionLinkInfo;
        
	    return $actionLinkInfo;
	}
	/**
	 * 处理ID
	 * @author Tujt 2015-06-26
	 */
	public function getRecordInfo($recordId) {
        if(empty($recordId)) 
            return '';
		$recordarr = explode(',',$recordId);
		return $recordarr[0];
	}
    /**
	 * 获取列表操作列按钮名称总汇，并返回宽度
	 * @author Tujt 2015-06-26
	 */
    public function getListButtomName(){
        global $current_user;
        //中英文包
        // require("user_privileges/user_language_".$current_user->id.'.php');
        $languageType=getLanguageType($current_user);
        
        foreach($this->list_buttom_name as $record => $button){
            if(!empty($button)){
                //array_unique，一对多时，按钮会重复显示
                $buttonnames[$record] = implode(',',array_unique($button));
            }else{
                $buttonnames[$record] = '';
            }
        }
        
        $listButtonNamesStr = '';
        foreach($buttonnames as $buttonsName){
            if(empty($listButtonNamesStr)){
                $listButtonNamesStr = $buttonsName;
            }
            if(mb_strlen($buttonsName,'utf-8')>mb_strlen($listButtonNamesStr,'utf-8')){
                $listButtonNamesStr = $buttonsName;
            }
			$len = mb_strlen($listButtonNamesStr,'utf-8');
        }
        $fuhaoLen = substr_count($listButtonNamesStr,',');
        $fontCountsLen = mb_strlen($listButtonNamesStr,'utf-8');
        if($languageType=='en')
        {
            $operationWidth = ($fontCountsLen-$fuhaoLen)*9+($fuhaoLen+1)*14;    
        }
        else if($languageType=='zh')
        {
            $operationWidth = ($fontCountsLen-$fuhaoLen)*16+($fuhaoLen+1)*14;
        }
        $operationWidth = $operationWidth - ($len - 2)*2+8;
		
        if($operationWidth<44){
            $operationWidth = 44;
        }
        return $operationWidth;
    }
	/**
	 * 判断是否允许编辑
	 * @author Tujt 2015-06-26
	 */
	public function checkEditInfo($module,$record) {
		global $adb;
        	$is_check = 'SUCCESS';
        if(empty($record))
        {
            return $is_check;
        }
		$approve_focus = Approve::getInstance(self::$module);
		$startapprovemodule = $approve_focus->startBlocksApprove();
	
        if($module=='ServiceCharge')
            $module='Accounts';
		if(isset($startapprovemodule[$module])){
			$focus = CRMEntity::getInstance($module);
			$focus->retrieve_entity_info($record,$module);
			$this->getApproveButton($module,$focus,$record);
			$approvestatus = '';

			if(!empty($this->approvebtn['info'])){//审批历史不为空
				if(1 == $this->approvebtn['edit']){//不允许编辑
					$query = 'select approvestatus from ' . $focus->table_name . ' where ' . $focus->table_index . ' = ? limit 1';
					$result = $adb->pquery($query,array($record));
					$approvestatus = $adb->query_result($result,0,0);
					//$approvestatus = $focus->column_fields['approvestatus'];
					$approvestatus = $approve_focus->getApproveStatus($approvestatus);
                    
                    $approveby_ed = getUserFullName($focus->column_fields['approveby']);
                    
					switch($approvestatus){
					    //0024686: 已经提交审批的单据，提示信息改进。					   
					    case 1://该记录正在审批中，不允许编辑！
                            $approvebyid_array = explode(',',$this->approvebtn['info']['nextstepapproveby']);
                            $approvebyname_array = array_map('getUserFullName',$approvebyid_array);
        
                            if(count($approvebyname_array)>2){
                                $approvebyname_array = array_slice($approvebyname_array,0,2);
                                $dot_end = ' ...';
                            }
                            
                            $approveby_ing = implode(',',$approvebyname_array).$dot_end;
					        $is_check = getFixedLabel('THERECORDPROCESSEDING').getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ing;
					        break;
					    case 2://该记录已被审批通过，不允许编辑！
					        $is_check = getFixedLabel('THERECORDAPPROVED');//.getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ed;
					        break;
						case 3://该记录已被审批拒绝，不允许编辑！
						    $is_check = getFixedLabel('THERECORDEDITING').getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ed;
						    break;
						default://该记录已被审批通过，不允许编辑！
							$is_check = getFixedLabel('THERECORDAPPROVED');//.getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ed;
					}
				}
			}else{
				if(isset($focus->column_fields['approvestatus']) && 
						!empty($focus->column_fields['approvestatus'])){
					$approvestatus = $focus->column_fields['approvestatus'];
					if(constant('D_A_S_APPROVED') == $approvestatus){
						$is_check = getFixedLabel('THERECORDAPPROVED');//该记录已被审批通过，不允许编辑！
					}
				}
			}
		}//预留其他编辑判断
		//客户资料审批完成后是否允许进行编辑 
		if($approvestatus == 2 && $module == 'Accounts'){
			$deployarray=getSys_deploy(16);
			if($deployarray['deploy_value'] == 0){
				return 'SUCCESS';
			}
		}
	    return $is_check;
	}

	/**
	 * 判断单据是否允许删除
	 * @author Tujt 2015-06-26
	 */
	public function checkDelInfo($module,$record) {
	   
        $approve_focus = Approve::getInstance($module);
		$startapprovemodule = $approve_focus->startBlocksApprove();
        $startapprovemodule['CashBill']='';
        $startapprovemodule['SendCashBill']='';
        $is_check='SUCCESS';
       
       
      
	    
	
		if(isset($startapprovemodule[$module])){
			$focus = $this->controller;
            $this->controller->retrieve_entity_info($record,$module);
            //关联删除，隐藏审批状态有问题
            $this->controller->id=$record;
         
            $buttons=$this->getDeleteBtn();
          
            if($buttons['permit']=='no')
            {
                //edit:can 2020-11-24 43393: （61mis.com/kfbcrm）销售管理-销售机会-详情；在详情界面先将单据操作分配，然后选择删除单据；提示false；然后单据在序时簿列表就消失了
                $is_check=getFixedLabel('YOUARENOTALLOWEDTOOTHEROTHERUSERSDATE');
            }
            else
            {
                return  $is_check;
            }
            if($module=='CashBill'||$module=='SendCashBill')
            {
                //16868: 客户>明细>收款单：已经审核的收款单，可以删除。
                $approvestatus = $focus->column_fields['checkoutstatus'];
                
                if(constant('D_A_S_CHECKED') == $approvestatus){//该记录已被审批通过，不允许删除！
                    $is_check = getFixedLabel('THISRECORDHASBEENAPPROVEDNOTALL');
                            
                    return $is_check;
                }
            }
			$this->getApproveButton($module,$this->controller,$record);
           
            
			$approvestatus = '';
			if(!empty($this->approvebtn['info'])){//审批历史不为空
				if($buttons['permit']=='no'){//不允许删除
					$approvestatus = $this->controller->column_fields['approvestatus'];
					$approvestatus = $approve_focus->getApproveStatus($approvestatus);
					switch($approvestatus){
					    case 1://该单据正在审批中，不允许删除！
					        $is_check = getFixedLabel('THISDOCUMENTISUNDEREXAMINATIONAND');
					        break;
					    case 2://该记录已被审批通过，不允许删除！
					        $is_check = getFixedLabel('THISRECORDHASBEENAPPROVEDNOTALL');
					        break;
						default://您选择的有已审批或者正在审批的记录，不允许执行批量删除！
							$is_check = getFixedLabel('EXPENCEDELETEERROR');
					}
				}
			}else{
				if(isset($this->controller->column_fields['approvestatus']) && 
						!empty($this->controller->column_fields['approvestatus'])){
					$approvestatus = $this->controller->column_fields['approvestatus'];
					if(constant('D_A_S_APPROVED') == $approvestatus){//该记录已被审批通过，不允许删除！
						$is_check = getFixedLabel('THISRECORDHASBEENAPPROVEDNOTALL');
					}
				}
			}
		}//预留其他禁删判断
        
	    return $is_check;
	}
	/**
	 * 析构函数
	 * @author Tujt 2015-05-28
	 */
	public function __destruct() {
	    
	}

	public function set_publicmoduletype($publicmoduletype){
	    $this->publicmoduletype = $publicmoduletype;
    }

    public function get_publicmoduletype(){
        return $this->publicmoduletype;
    }
    /**
	 * 获取自定义按钮
	 */
    public function getCustomBtn($position,$values=[]){
        global $adb;
        if(empty($this->buttoncustomizationObj)){
            crm_load_class_file('cls_ButtonsCustomization','modules/Settings');
            $this->buttoncustomizationObj = new cls_ButtonsCustomization(self::$module);
        }
        $values['position'] = $position;
        $values['btn_from'] = $this->btn_from;
        if(empty($this->custom_activebuttons_arr)){
            $focus = CRMEntity::getInstance(self::$module);    
            $values['record'] = $this->getRecordInfo($focus->id);
            $this->custom_activebuttons_arr = $this->buttoncustomizationObj->getActiveButtons();
        }
        // dump($this->custom_activebuttons_arr);
        $custom_buttons_arr = $this->buttoncustomizationObj->getAllowButtons($this->custom_activebuttons_arr,$values);

        foreach ($custom_buttons_arr as $index => $btninfo) {
            $custom_btnkey = $btninfo['btnkey'];
            if($position == 'listlink'){
                $this->listview_link[$custom_btnkey]['label'] = $btninfo['label'];
                $this->listview_link[$custom_btnkey]['permit'] = $btninfo['permit'];
                $this->listview_link[$custom_btnkey]['click'] = 'customButtonClick(\''.$position.'\',\''.self::$module.'\',\'%d\','.$btninfo['btnid'].')';
                $this->listview_link[$custom_btnkey]['custombtn'] = 'yes';
                $this->listview_link[$custom_btnkey]['customtype'] = $btninfo['type'];
            }else{
                // $this->detail_buttons['More']['list'][$custom_btnkey]['label'] = $btninfo['label'];
                // $this->detail_buttons['More']['list'][$custom_btnkey]['permit'] = $btninfo['permit'];
                // $this->detail_buttons['More']['list'][$custom_btnkey]['btnid'] = $btninfo['btnid'];
                // $this->detail_buttons['More']['list'][$custom_btnkey]['custombtn'] = 'yes';
                $this->detail_buttons[$custom_btnkey]['label'] = $btninfo['label'];
                $this->detail_buttons[$custom_btnkey]['permit'] = $btninfo['permit'];
                $this->detail_buttons[$custom_btnkey]['btnid'] = $btninfo['btnid'];
                $this->detail_buttons[$custom_btnkey]['custombtn'] = 'yes';
                $this->detail_buttons[$custom_btnkey]['customtype'] = $btninfo['type'];
            }
        }
    }
    /**
	 * 记录所有详情页按钮
	 */
	public function setAllDetailButtons($detailbtn_arr) {
        $this->all_detailbtn_arr = $detailbtn_arr;
	}
    /**
	 * 获取所有详情页按钮
	 */
	public function getAllDetailButtons() {
        return $this->all_detailbtn_arr;
	}
}
?>