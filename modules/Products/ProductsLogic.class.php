<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-06-01
 */
class ProductsLogic extends BaseLogic {

    public function __construct(){
        parent::__construct();
        crm_load_class_file('Shopcart','modules/Products');
    }
    /*
     * editor:gyq_09
     * reason:新增详情页及序时簿派息规则按钮
     * date:2016 3 31
     * */
    public function getDetailBasicBtn() {
        parent::getDetailBasicBtn();
        
        
        /*$btn = array();
        $btn['dividend_rules']['label'] = getFixedLabel('DIVIDENDRULES');
        $btn['dividend_rules']['permit'] = $this->checkDividendRulesPermit();
        $btn['dividend_rules']['icon'] = 'icon-check';
        //21830: （金融账套）进入产品明细界面：【分配】按钮后紧随【派息规则】按钮
        $i=0;
        foreach($this->detail_buttons as  $key=>$btn_content)
        {
             $i++;
             if(strtolower($key)=='allocate')
             {
                
                break;
             }
        }
        $this->detail_buttons = f_array_insert($this->detail_buttons,$btn,$i);
        //editor:gyq_20181026 价格策略按钮位置改动
        $i=0;
        foreach($this->detail_buttons as  $key=>$btn_content)
        {
            $i++;
            if(strtolower($key)=='settings')
                break;
        }
        //editor:gyq_84 reason:产品增加价格策略 2018/10/22 14:39
        $btn['price_strategy']['label'] = getFixedLabel('PRICESTRATEGY');
        $btn['price_strategy']['permit'] = isPermitted($module,'price_strategy','');
        $btn['price_strategy']['icon'] = 'icon_price_strategy';
        $this->detail_buttons= f_array_insert($this->detail_buttons,$btn,$i);
        
        //东贸-隐藏购物车相关按钮
        $versioninfo=getVersionInfo();
        if($versioninfo['account'] != 'dongmao'){
            $btn = array();
			$btn['addtocart']['label'] = getFixedLabel('ADDTOCART');//加入购物车
			$btn['addtocart']['permit'] = 'yes';
			$btn['addtocart']['icon'] = 'icon-cart';
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,$i+1);
        }
        
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0){
            $btn = array();
			$btn['addtocart']['label'] = getFixedLabel('ADDTOCART');//加入购物车
			$btn['addtocart']['permit'] = 'yes';
			$btn['addtocart']['icon'] = 'icon-cart';
			$this->detail_buttons = f_array_insert($this->detail_buttons,$btn,$i+1);
        }*/
    }
    //产品详情页 zxm 20241011 产品属性是非产品分录 但是先不要分录设置按钮
    public function getDetailBasicSet(){
        // global $current_user;
        // $module = self::$module;

        // if($current_user->getHaveSetProfile("Settings")=='yes'){
        //     //页面设置
        //     $this->detail_settings['Settings']['label'] = getFixedLabel('LBL_PAGE_SET');
        //     $this->detail_settings['Settings']['icon'] = 'icon-set';
        //     $this->detail_settings['Settings']['modulename'] = $module;
        //     $this->detail_settings['Settings']['url'] = 'href="index.php?pageto_module=Settings&pageto_action=SettingLeftRight&pageto_menufile=ModuleManager&formodule='.$module.'"';
        //     //相关信息设置

        //     $this->detail_settings['RelevantSettings']['label'] = getFixedLabel('PROJECTSETTINGS');
        //     $this->detail_settings['RelevantSettings']['icon'] = 'icon-set2';
        //     $this->detail_settings['RelevantSettings']['modulename'] = $module;
        //     $this->detail_settings['RelevantSettings']['click'] = 'onclick="SetRelatedlist(ld(this),\''.$module.'\')"';
        // }
        parent::getDetailBasicSet();
        unset($this->detail_settings['DetailsSettings']);
    }

    public function getDetailMoreBtn()
    {
        parent::getDetailMoreBtn();
        $this->detail_buttons['More']['list']['dividend_rules']['label'] = getFixedLabel('DIVIDENDRULES');
        $this->detail_buttons['More']['list']['dividend_rules']['permit'] = $this->checkDividendRulesPermit();
        $this->detail_buttons['More']['list']['dividend_rules']['icon'] = 'icon-check';

        //editor:gyq_84 reason:产品增加价格策略 2018/10/22 14:39
        $this->detail_buttons['More']['list']['price_strategy']['label'] = getFixedLabel('PRICESTRATEGY');
        $this->detail_buttons['More']['list']['price_strategy']['permit'] = isPermitted('Products','price_strategy','');
        $this->detail_buttons['More']['list']['price_strategy']['icon'] = 'icon_price_strategy';
        
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0){
            $this->detail_buttons['More']['list']['addtocart']['label'] = getFixedLabel('ADDTOCART');//加入购物车
            $this->detail_buttons['More']['list']['addtocart']['permit'] = 'yes';
            $this->detail_buttons['More']['list']['addtocart']['icon'] = 'icon-cart';
        }
    }
	public function getListBasicBtn()
	{
		parent::getListBasicBtn();//调用父类方法
        global $adb,$current_user;
        //editor:gyq_20181026 价格策略按钮位置改动
        $i=0;
        foreach($this->list_buttons as  $key=>$btn_content)
        {
            $i++;
            if(strtolower($key)=='more')
                break;
        }
        $module = self::$module;
        $btn = array();
        $btn['price_strategy']['label'] = getFixedLabel('PRICESTRATEGY');
        $btn['price_strategy']['permit'] =isPermitted($module,'price_strategy','');
        $btn['price_strategy']['icon'] = 'icon_price_strategy';
        $btn['price_strategy']['btnkey'] = 'price_strategy';
        $this->list_buttons = f_array_insert($this->list_buttons,$btn,$i-1);
        
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0){
            $shopcartobj->check_nums();
            $btn = array();
            $btn['opencart']['label'] = getFixedLabel('SHOPCART');
            $btn['opencart']['permit'] ='yes';
            $btn['opencart']['icon'] = 'icon-cart';
            $btn['opencart']['btnkey'] = 'opencart';
            //列表页购物车上显示购物车记录数目
            $btn['opencart']['num'] = $shopcartobj->cartdetail_num;
            $this->list_buttons = f_array_insert($this->list_buttons,$btn,$i);
        }
        
		$btn = array();
        if($this->checkDividendRulesPermit() == 'yes'){ //BUG0069774 xxy 2023-7-20 先判断版本和权限判断 产品管理-列表操作按钮设置-多了一个派息规则
            $btn['dividend_rules']['label'] = getFixedLabel('DIVIDENDRULES');
            $btn['dividend_rules']['permit'] = $this->checkDividendRulesPermit();
            $btn['dividend_rules']['icon'] = 'icon-check';
            $btn['dividend_rules']['btnkey'] = 'dividend_rules';
            $this->list_buttons = f_array_insert($this->list_buttons,$btn,6);
        }
        $tmp_list_buttons=array();
        foreach($this->list_buttons as $btnname=>$content)//在删除按钮后面插入查重按钮
        {
            $tmp_list_buttons[$btnname]=$content;
            if($btnname=='Delete')
            {
         	    $tmp_list_buttons['Datadupcheck']['label'] = getFixedLabel('ACCOUNTDUPLICATECHECK');
		        $tmp_list_buttons['Datadupcheck']['permit'] = isPermitted($module,'accountdatadup');
 	            $tmp_list_buttons['Datadupcheck']['icon'] = 'icon-search';
                $tmp_list_buttons['Datadupcheck']['btnkey'] = 'Datadupcheck';
            }
        }

        if (isset($tmp_list_buttons['Import'])){
            $fieldobj = Field::getInstance($module,$adb);
            $fieldinfos = $fieldobj->getModuleFields();
            if (!is_admin($current_user)) {
                $focus = CRMEntity::getInstance(self::$module);
                $profilefields = $focus->getProfileFields($current_user->profileid);
            }

            // ljj 2024-11-6 XUQIU20241023-04 产品可以导入图片（郭良峰）根据图片字段显示"导入产品图片"下拉框按钮
            $hasImageField = false;
            foreach ($fieldinfos as $fieldname => $fieldinfo){
                $uitype = $fieldinfo->getUIType();
                $savedatabase = $fieldinfo->getSaveDataBase();
                if($uitype == 69){//图片
                    if ($savedatabase == 'no') {//不保存数据库
                        continue;
                    }
                    $fieldid = $fieldinfo->getFieldid();
                    if (!empty($profilefields) && ($fieldinfo->getReadOnly() == 1 || $profilefields[$fieldid]['editreadonly'] == 1 ) ) {//字段权限只读
                        continue;
                    }
                    $hasImageField = true;
                    break;
                }
            }
            if ($hasImageField){
                $tmp_list_buttons['Import']['list'] = array(
                    'Import'=>array(
                        'label'=>getFixedLabel('ImportProduct'),
                        'permit'=>'yes'
                    ),
                    'ImportImage'=>array(
                        'label'=>getFixedLabel('ImportProductImage'),
                        'permit'=>'yes'
                    )
                );
            }
            unset($focus,$fieldinfos,$profilefields,$hasImageField,$uitype,$savedatabase,$fieldid);
        }

        $this->list_buttons=$tmp_list_buttons;

	}

    /*
     * editor:gyq_09
     * reason:新增派息规则权限检测，满足金融版本、产品模块开启、有新增权限方有派息规则
     * date:2016 4 5
     * */
	private function checkDividendRulesPermit(){
		$vesion = get_versiontrade();
		//$moduleopen1 = vtlib_isModuleActive('Products');
		$moduleopen2 = vtlib_isModuleActive('DividendOrder');
		$isper = isPermitted(self::$module,'Create');
        
        $focus=CRMEntity::getInstance("Products");
        $approvestatus=$focus->column_fields['approvestatus'];
       
        if($vesion == 'finance'&& ($isper == 'yes') && $moduleopen2){
            return 'yes';
        }else{
            return 'no';
        }
	}
	/**
	 * 初始化更多按钮关联下拉列表
	 * @author Tujt 2015-06-01
	 */

	public function getListMoreBtn() {
		parent::getListMoreBtn();
        
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0){
            $this->list_buttons['More']['list']['addtocart']['label'] = getFixedLabel('ADDTOCART');//加入购物车
            $this->list_buttons['More']['list']['addtocart']['permit'] = 'yes';
        }
        
        
        //判断商品状态字段是否启用，控制“批量上架”与“批量下架”按钮的显示
        /*
        $productstatuspremit = 'no';
        $tmpfieldobj=$this->controller->fieldobj;
        $productstatus_fieldinfo=$tmpfieldobj->getFieldInfoobjBykey('columnname','productstatus');
        if(!empty($productstatus_fieldinfo)&&isPermitted(self::$module, 'EditView', '')=='yes'){
            $productstatuspremit = 'yes';
        }
        */
        //edit: xll 2023/02/21 XUQIU1001109 批量上下架根据字段权限判断是否开启
        $BatchOnShelves_permmit = 'no';
        if('yes' == isPermitted(self::$module, 'BatchOnShelves', '')){
            $BatchOnShelves_permmit = 'yes';
        }
        $BatchOffShelves_permmit = 'no';
        if('yes' == isPermitted(self::$module, 'BatchOffShelves', '')){
            $BatchOffShelves_permmit = 'yes';
        }
        
        $btn = array();
		$btn['Batchonshelves']['label'] = getFixedLabel('Batchonshelves');
		$btn['Batchonshelves']['permit'] = $BatchOnShelves_permmit;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,4);
        $btn = array();
		$btn['Batchoffshelves']['label'] = getFixedLabel('Batchoffshelves');
		$btn['Batchoffshelves']['permit'] = $BatchOffShelves_permmit;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,5);

        //自动查重合并
        $dup_and_merge_permit = 'no';
        $module = self::$module;
		if('yes' == isPermitted($module, 'dup_and_merge','')){
			$dup_and_merge_permit = 'yes';$more_idx = 1;
		}
		$btn = array();
		$btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
		$btn['Findduplicates']['permit'] = $dup_and_merge_permit;
		$this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,6);
        //合并
        $merge_permit = 'no';
        if('yes' == isPermitted($module, 'Merge','')){
            $merge_permit = 'yes';$more_idx = 1;
        }
        $btn = array();
        $btn['RecordMerge']['label'] = getFixedLabel('Merge');
        $btn['RecordMerge']['permit'] = $merge_permit;
        $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,8);
        
        //"商城设置"按钮
        $shoppremit = 'no';
        if(isPermitted('ShopSettings', 'ShopSettings', '')=='yes'){ //BUG0069729 xxy 2023-7-21 判断是否有"商城设置"的模块权限 (非管理员账号“产品管理”模块，点击“商城设置”打开为空白界面)
            //判断"商城设置"模块是否启用
            if(vtlib_isModuleActive('ShopSettings')){
                $shoppremit = 'yes';
            }
            $btn = array();
            $btn['Shopsettings']['label'] = getTranstab('ShopSettings');
            $btn['Shopsettings']['permit'] = $shoppremit;
            $this->list_buttons['More']['list'] = f_array_insert($this->list_buttons['More']['list'],$btn,6);
        }
        //	0028896: 产品查重合并功能注释掉
	//	$btn = array();$module = self::$module;
		//$btn['Findduplicates']['label'] = getFixedLabel('CHECKMERGE');
		//$btn['Findduplicates']['permit'] = isPermitted($module,'DuplicatesHandling','');
        //editor:gyq_84TE reason:产品增加价格策略 2018/10/22 15:22
	}
    public function getallListViewLink() {
        $btn =array();
        $btn['copy']['label'] = getFixedLabel('COPY');
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0) {
            $btn['addtocart']['label'] = getFixedLabel('ADDTOCART');//加入购物车
        }
        //获取云星空erp接口参数
        $stock_view = getErpStockView();
        if($stock_view != 'no') {
            $btn['stock_view']['label'] = getFixedLabel('INVENTORY');//查询库存
        }
        $btn = f_array_insert($btn,parent::getallListViewLink());
        return $btn;
    }
	/**
	 * 初始化列表按钮结果集
	 * @author Tujt 2015-06-26
	 */
	public function setListViewLink($result,$record,$start,$idx) {
	   global $related_header,$adb,$related_left_mod,$related_left_record;

       if(!empty($related_header))
       {
 
             static $pricebookProductids;
			 $type = 'redirect';
            if(!is_array($pricebookProductids)||$pricebookProductids[0]<=0.00001)
            {
               
                  $sql='select listprice,productid from  ld_pricebookproductrel where  pricebookid=? ';
                $result=$adb->pquery($sql,array($_REQUEST['record']));
                for($i=0;$i<$adb->num_rows($result);$i++)
                {
                    $productid=$adb->query_result($result,$i,'productid');
                    $listprice=$adb->query_result($result,$i,'listprice');
                    $pricebookProductids[$productid]=$listprice;
                }
            }
			 // print_r($_REQUEST['record']);
			if(isPermitted(self::$module,'Edit') == 'yes'){
				$btn['edit']['label'] = getFixedLabel('EDIT');
				$btn['edit']['permit'] = 'yes';
				$btn['edit']['click']='check_edit_click(this,\''.self::$module.'\',\'%d\')';
				$btn['edit']['type'] = $type;
			}
            
            if(isPermitted(self::$module,'Delete') == 'yes'){
                $btn['delete']['label'] = getFixedLabel('CANCELTHEASSOCIATED');
                $btn['delete']['permit'] = 'yes';
                $btn['delete']['click']='check_delassociated_click(this,\''.self::$module.'\',\'%d\')';
                
                
                $approve_focus = Approve::getInstance(self::$module);
                $startapprovemodule = $approve_focus->startBlocksApprove();
                
                if(isset($startapprovemodule[$frommodule])){//审批模块
                    $type = 'approve';
                }
                $btn['delete']['type']=$type;

            }
            $this->listview_link =$btn;

            $this->listview_link['delete']['result']['module'] = $related_left_mod;
            $this->listview_link['delete']['result']['action'] = 'DetailView';
            $this->listview_link['delete']['result']['record'] = $related_left_record;
            $this->listview_link['delete']['related'] = 1;  
			 $this->listview_link['edit']['result']['module'] = $related_left_mod;
            $this->listview_link['edit']['result']['action'] = 'DetailView';
            $this->listview_link['edit']['result']['record'] = $related_left_record;
            $this->listview_link['edit']['related'] = 1;            
            //print_r( $this->listview_link );
            return '';;
       }
       
		parent::setListViewLink($result,$record,$start,$idx);
		unset($this->listview_link['copy']);
		if(isPermitted(self::$module,'Create') == 'yes'){
			$btn = array();
			$btn['copy']['label'] = getFixedLabel('COPY');
			$btn['copy']['permit'] = 'yes';
			$btn['copy']['click'] = 'ProductListCopy('.$record.')';
			$this->listview_link = f_array_insert($this->listview_link,$btn);

		}
        
        $shopcartobj = new Shopcart();
        $result = $shopcartobj->shopcart_button();
        if(sizeof($result)>0){
            $btn = array();
			$btn['addtocart']['label'] = getFixedLabel('ADDTOCART');//加入购物车
			$btn['addtocart']['permit'] = 'yes';
			$btn['addtocart']['click'] = 'addtocart('.$record.')';
			$this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        }

        //获取云星空erp接口参数
        $stock_view = getErpStockView();
        if($stock_view != 'no'){
            $btn = array();
            $btn['stock_view']['label'] = getFixedLabel('INVENTORY');//查询库存
            $btn['stock_view']['permit'] = 'yes';
            $btn['stock_view']['click'] = $stock_view;
            $this->listview_link = f_array_insert($this->listview_link,$btn,-1);
        }
        
	}
    
}
?>