<?php
/**
 * @version:6.0 角色权限改进
 * 修改编码格式:统一编码：UTF-8
 * @author CHJ 2015-03-17
 */
class  Profile{

     private $adb,$languageType;
     private $profilePermission=array();
     public function __construct()
     {
        global $current_user,$adb;
        $this->adb=$adb;
        //权限为什么要翻译，我不懂，
       /* if(isset($_REQUEST['languageType']) && !empty($_REQUEST['languageType'])){
			$this->languageType = $_REQUEST['languageType'];
		}else{
			//gyq_22 20170118
			require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
			$this->languageType = $languageType;
		}*/
        
     }

	private static $_instance;//单例返回类实例

	/**
     * 防止被克隆
     * @author Tujt 2015-05-26
     */
    private function __clone(){}
    /**
     * 单例初始化权限类
     * @author Tujt 2015-05-26
     */
    public static function getInstance(){
        if(FALSE == (self::$_instance instanceof self)){
            self::$_instance = new self();
        }
        return self::$_instance;
    }
    /**
     * 获取移动端报表权限
     * */
    public function getMobileReportNames()
    {
        global $adb;
        static $global_mobilereportnames;
        if(is_array($global_mobilereportnames)&&sizeof($global_mobilereportnames)>0)
        {
            return $global_mobilereportnames;
        }
        //editor:gyq_20200227 reason:报表序时簿有这个判断，功能标签页里也要加客户001的判断。
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
        $sql_where = '';
        if (cls_StaticCommonFun::checkVersionIs001()) {
            $sql_where = ' and kehu001_presence=1 ';
        }
        $sql="SELECT id,NAME,graphtype,modulenames,image,labelbol, 
                if(exists(select 1 from ld_appuiset where userid=1 and setname=ld_dashboard_app.`name`),'','1') display 
                FROM ld_dashboard_app 
                LEFT JOIN ld_appuiset on ld_dashboard_app.name=ld_appuiset.setname and ld_appuiset.apptype='weixin' and ld_appuiset.userid=1 
                WHERE wx_presence = 1 ".$sql_where." order by wx_sequence ASC";
        $result=$adb->pquery($sql,array());
        $rows=$adb->num_rows($result);
        for($i=0;$i<$rows;$i++)
        {
            $labelbol = $adb->query_result($result,$i,'labelbol');
            $name=$adb->query_result($result,$i,'name');
            $id=$adb->query_result($result,$i,'id');
            $isactive = 0;
            $modulenames = $adb->query_result($result,$i,'modulenames');
            if(empty($modulenames)){
                $isactive = 1;
            }else{
                $modulenames = explode(',',$modulenames);
                foreach($modulenames as $m){
                    if(vtlib_isModuleActive($m)){
                        $isactive = 1;
                    }
                }
            }
            //BUG0071507 zxm 20240407 仅授权“库存查询报表”时，才显示金蝶库存查询报表_移动端
            if($name=='search_erp_stcok'){
                $isactive = 0;
                $regopobj=RegOp::getInstance();
                if(method_exists($regopobj,"geterpstocksearch")) {
                    $stock_view = $regopobj->geterpstocksearch();
                    if($stock_view == 1){
                        $isactive = 1;
                    }
                }
            }
            if($isactive == 1){
                $temp_FixedLabel = '';
                //zxm 2021-1223 0049362: （https://81mis.com/kfbcrm/index.php [^]）系统设置》佣金单模块关闭后，移动端报表》费用佣金统计表名称没有变化
                if($name=='expense_commission'){
                    //Expense,Commission
                    if(vtlib_isModuleActive('Expense')){
                        $temp_FixedLabel.=getFixedLabel('Cost');
                    }
                    if(vtlib_isModuleActive('Commission')){
                        $temp_FixedLabel.=getFixedLabel('COMMISSION');
                    }
                    $temp_FixedLabel.=getFixedLabel('STATISTICALE');
                }else{
                    $temp_FixedLabel = getFixedLabel($labelbol);
                }
                $global_mobilereportnames[$i]['fieldlabel']=$temp_FixedLabel;
                $global_mobilereportnames[$i]['name']=strtolower($name);
                $global_mobilereportnames[$i]['id']=$id;
            }
        }
          
        return $global_mobilereportnames;
        
    }
    /**
     * 获取可以使用的常用报表
     * */
    public function getOfenUseReportNames()
    {
        global $adb;
        $tradeinfo= getVersionTradeInfo();
        $trade=$tradeinfo['trade'];
        
        if($trade=='training'){
            $parentwhere = "";
            $where = " and name not in ('SalesOrderImplementation') ";
        }
        else if($trade=='德卡'){
            $parentwhere = " and name not in ('CourseEnquiryReport')";
            $where = "";
        }
        else
        {
            $parentwhere = " and name not in ('CourseEnquiryReport')";
            $where = " and name not in ('SalesOrderImplementation') ";
        }
        if(!vtlib_isModuleActive('ServiceContracts')&&!vtlib_isModuleActive('SalesOrder')){
            $where .= " and name not in ('SalesOrderTrack','Contractnumber','Contractamount') ";
        }
        if($trade!='jierun'){
            $parentwhere .= " and name not in ('JIERUNREPORTS') ";
        }
        if($trade!='lueyang'){
            $where .= " and name not in ('Reportingpaymentschedulestatistics') ";
        }
        if($trade!='xycp'){
            $parentwhere .= " and name not in ('XuanYuanLawn')";
        }
        if($trade!='zhongyuan'){
            $parentwhere .= " and name not in ('ZHONGYUANREPORTS')";
        }
        if($trade!='futai'){
            $where .= " and name not in ('hoursqueryreport')";
        }
        if($trade!='ruiai'){
            $where .= " and name not in ('librarytrackreport')";
        }
        if($trade!='yuanzhou'){
            $where .= " and name not in ('yuanzhoureport')";
        }
        
        if(!vtlib_isModuleActive('Potentials')){
            $where .= " and name not in ('Salesforecastandanalysistable') ";
        }
        if(!vtlib_isModuleActive('CashBill')){
            $where .= " and name not in ('THESINGNINGAMOUNTOFBILLBOARD','CashBillSum_Paymentplan','CashBillSum_SalesOrder','Performancestatisticscollection') ";
        }
        if(!vtlib_isModuleActive('PurchaseOrder')){
            $where .= " and name not in ('PurchaseOrderTrack') ";
        }
        if(!vtlib_isModuleActive('Project')){
            $where .= " and name not in ('Thestatisticalreportofprojectperformance') ";
        }
        if(!vtlib_isModuleActive('SendCashBill')){
            $where .= " and name not in ('SendCashBillSum_PurchaseOrder','SendCashBillSum_SendPayment') ";
        }
        if(!vtlib_isModuleActive('OutboundOrder')){
            $where .= " and name not in ('CashBillSum_Outboundorder') ";
        }
         $sql='select usereportid,name from ld_usereport where parent_id=0 '.$parentwhere.' order by sequence';//获取父节点报表
        //var_dump($parentwhere);
        $parentresult=$adb->pquery($sql,array());
        $reportHeader=array();
     
        $PurchaseOrdertype=vtlib_isModuleActive('PurchaseOrder');
        
        $SalesOrdertype=vtlib_isModuleActive('SalesOrder');
        //print_r($PurchaseOrdertype);
        $HelpDesktype=vtlib_isModuleActive('HelpDesk');
        $ProjectTasktype=vtlib_isModuleActive('ProjectTask');
        $CashBilltype=vtlib_isModuleActive('CashBill');

        
        for($i=0;$i<$adb->num_rows($parentresult);$i++)
        {
        
            $sqlchild='select usereportid,name from ld_usereport where parent_id=? and presence=0 '.$where.' order by sequence';
            $parentid=$adb->query_result($parentresult,$i,'usereportid');
            $parant_name = $adb->query_result($parentresult,$i,'name');
            $parentlabel=getFixedLabel($parant_name);
            if($parant_name=='InventoryReport'){
                //editor:20181229 0035903: 库存报表，当库存模块一个都不启用时，报表应该不显示
                //出库单、入库单、盘点单、库间调拨、销售退货单、采购退货单、库存初始化
                $stock_modules = array('OutboundOrder','Stock','WareHouseTransfer','Checks','Prdtnums','SalesBack','PurchaseBack');
                $atleast_onemodule_active = 0;
                foreach ($stock_modules as $key=>$value){
                    if(vtlib_isModuleActive($value)){
                        $atleast_onemodule_active = 1;
                    }
                }
                if($atleast_onemodule_active===0){
                    continue;
                }
            }
            //var_dump($parentid);
            //var_dump($parentlabel);
            $childresult=$adb->pquery($sqlchild,array($parentid));
            //print_r($childresult);
            for($j=0;$j<$adb->num_rows($childresult);$j++)
            {
                $childname = $adb->query_result($childresult,$j,'name');
         
        		/**
        		 * @reason 0012334 常用报表>>服务绩效统计表：希望【客户服务单】、【项目任务】模块都没有开启的情况下，该报表不显示
        		 * @author Tujt 2014-11-10
        		 */
        		if($childname == 'Serviceperformanceappraisal'){//服务绩效统计表
        			if(1 != $HelpDesktype && 1 != $ProjectTasktype){
        				continue;
        			}
        		}
                if($childname == 'The billboard of Receivables'){//回款金额龙虎榜
        			if(1 != $CashBilltype){
        				continue;
        			}
        		}
        		if($childname == 'TimeSheet personal monthly summary'){//判断工时模块是否开启
        			if(vtlib_isModuleActive('TimeSheet') == ''){
        				continue;
        			}
        		}
        		//chj:应收账款汇总表：如果数据接口没有连接金蝶旗舰版则不显示当前报表
        		if($childname == 'AccountsReceivableSummary' && getDatainterface('soft_version') != 5){
        			continue;
        		}
        		if('CashBillSum_Paymentplan' == $childname && !vtlib_isModuleActive('PaymentPlan')){
        			continue;
        		}
        		if('SendCashBillSum_SendPayment' == $childname && !vtlib_isModuleActive('SendPayment')){
        			continue;
        		}
                $childusereportid=$adb->query_result($childresult,$j,'usereportid');
                
                
                $names[]=$childname;
            }
        }
        
        return $names;
    }
	/**
	 * @version:6.0 角色权限改进
	 * @reason 获取用户角色信息
	 * @author Chj 
	 */
	public function getProfileinfo($profileid,$mode=''){
		global $adb;
		$profileinfo = array();
		if(!empty($profileid)){
			$query = 'select description,profilename from ld_profile where profileid = ?';
			$result = $adb->pquery($query,array($profileid));
			$num_rows = $adb->num_rows($result);
			if($num_rows > 0)
			{
			     $profilename=$adb->query_result($result,0,'profilename');
                 $profiledescription=$adb->query_result($result,0,'description');

                 /* duan 20230717:角色权限名称较长时,导出会显示省略号,先去掉这个处理
				 if(empty($mode)){
					 if(mb_strlen($profilename,'utf8')>globalStatic::$sub_strlen)
					{
						//18553: 控制面板>用户管理 ：当权限管理的权限名称很长时，点击【角色权限】按钮，弹出层显示错误。
						$profilename=mb_substr($profilename,0,globalStatic::$sub_strlen,'utf-8').'....';
									   
					}
					if(mb_strlen($profiledescription,'utf8')>globalStatic::$sub_strlen)
					{
						//18553: 控制面板>用户管理 ：当权限管理的权限名称很长时，点击【角色权限】按钮，弹出层显示错误。
						$profiledescription=mb_substr($profiledescription,0,globalStatic::$sub_strlen,'utf-8').'....';
									   
					}
				 }*/
				$profileinfo['profilename'] = $profilename;
				$profileinfo['description'] = $profiledescription;
			}
		}
		return $profileinfo;
	}
	/**
	 * 获取角色权限所有信息
	 * @author Tujt 2015-04-20
	 */
	public function getProfileArray(){
		global $adb;
		$profileinfo = array();
		$query = 'SELECT profileid,profilename FROM ld_profile ORDER BY profileid;';
		$result = $adb->pquery($query,array());
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			for ($i=0; $i < $num_rows; $i++) { 
				$profileid = $adb->query_result($result,$i,'profileid');
				$profilename = $adb->query_result($result,$i,'profilename');
				/* duan 20230717:角色权限名称较长时,导出会显示省略号,先去掉这个处理
                if(mb_strlen($profilename,'utf8')>globalStatic::$sub_strlen && empty($_REQUEST['listview']))
                {
                    //18553: 控制面板>用户管理 ：当权限管理的权限名称很长时，点击【角色权限】按钮，弹出层显示错误。
                    $profilename=mb_substr($profilename,0,globalStatic::$sub_strlen,'utf-8').'....';
                                   
                }*/
              
				$profileinfo[$profileid] = $profilename;
			}
		}
		return $profileinfo;
	}
	/**
	 * @version:6.0 角色权限改进
	 * @reason 获取操作权限按钮信息
	 * @author Chj 
	 */
	public function getActionMappingNum()
	{
		global $adb;
		$result = $adb->pquery('select actionid,actionname from ld_actionmapping');
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0)
		{
			for($i = 0; $i<$num_rows; $i++)
			{
				$actionid = $adb->query_result($result,$i,'actionid');
				$actionArray[$actionid] = $adb->query_result($result,$i,'actionname');
			}
		}
		return $actionArray;
	}
	/**
	 * @version:6.0 角色权限改进
	 * @reason 判断权限ID是否存在
	 * @author Chj 
	 */

	/**
	 * @version:6.0 角色权限改进
	 * @reason 获取模块所有的按钮
	 * @author Chj 
	 */
	public function getAllActionsFortab(){
		global $adb;
		$cachekey = 'cachegetAllActionsFortab';
	 	$check = Cache($cachekey);
		if(!is_array($check)){
			$check = Array();
            
            //查询所有模块
			$query = "
                 SELECT
                	ld_profileallpermission.tabid,
                	ld_profileallpermission.operation
                FROM
                ld_profileallpermission
								LEFT JOIN ld_actionmapping on ld_actionmapping.actionid = ld_profileallpermission.operation
                LEFT JOIN ld_tab ON ld_tab.tabid=ld_profileallpermission.tabid
                

                order by ld_tab.tabsequence,ld_profileallpermission.sequence asc,
                FIND_IN_SET(ld_actionmapping.actionname,'index,DetailView,QuotesChange_Add,QuotesChange_Replace,QuotesChange_Edit,Create,EditView,Delete,accountdatadup
							,Copy,Allocate,Share,Import,Export,DuplicatesHandling,Merge,WarehouseConfirmed,EndreturnGood,Reteacement,Checkout,ACheckout,Confirminventory,
						RevocationInventory,Advance,Updatestate,ChangeCreator,Devidend,AbtiDevidend')";

			$result = $adb->pquery($query);
			$num_rows = $adb->num_rows($result);
			for($i=0; $i<$num_rows; $i++){
				$tab_id = $adb->query_result($result,$i,'tabid');
				$action_id = $adb->query_result($result,$i,'operation');
                //ls 2021-12-17 0049286: （https://81mis.com/kfbcrm [^]）角色权限->银行账户：隐藏“推进”、“下载”、“预览”和“下载和预览次数”操作按钮
                 /*duan 2022-1-24 银行账户有附件字段，显示下载相关的权限
                 if($tab_id == 86 && in_array($action_id,array(22)))//,42,43,49,50
                 {
                        continue;
                 }*/

				if($tab_id==9) $tab_id=16;
				$check[$tab_id][$action_id] = 1;//默认不勾选
			}
			Cache($cachekey,$check);
		}
        $all_tabid_arr = [];
        //判断模块是否关闭
        foreach($check as $tabid=>$content)
        {
            $all_tabid_arr[] = $tabid;
        }
        $all_tabid_str = implode(',',$all_tabid_arr);
        // 改为统一从表里获取启用状态，循环调用vtlib_isModuleActive太慢了
        if(!empty($all_tabid_str)){
            $select_sql = "SELECT presence,tabid FROM ld_tab WHERE tabid in ( $all_tabid_str )";
            $result = $adb->pquery($select_sql, array());
            $num_rows = $adb->num_rows($result);
            if ($num_rows > 0) {
                for ($i = 0; $i < $num_rows; $i++) {
                    $presence = (int)$adb->query_result($result,$i,'presence');
                    $tabid = $adb->query_result($result,$i,'tabid');
                    if(in_array($presence,[0,2])){
                        $modules[$tabid] = $check[$tabid];
                    }
                }
            }
        }
        $check = $modules;
          
		return $check;

	}
    /**
     * edit:can
     * reason:获取指定权限的信息，包括模块按钮权限，字段权限
     *  */
    public function getProfileInfos($profileid)
    {
          global $adb;
          if(is_array($this->profilePermission)&&is_array($this->profilePermission[$profileid])&&sizeof($this->profilePermission[$profileid])>0)
          {
            return $this->profilePermission[$profileid];
          }
       
          $cachekey = 'cache_modulelist_profile_getProfileInfos_'.$profileid;
          $cachefieldinfos = CacheDirectory($cachekey,'profile');
          $this->profilePermission[$profileid]=$cachefieldinfos;
          if(is_array($cachefieldinfos)&&!empty($cachefieldinfos))
          {
            return $cachefieldinfos;
          }
          
          //判断该权限是否有移动端报表设置
          $sql='select ld_tab.tabid,operation,permissions,relatednames from ld_profile2standardpermissions inner join 
                    ld_tab on ld_tab.tabid=ld_profile2standardpermissions.tabid where profileid=? and ld_tab.tabid=-2';
           $mobilereportresult=$adb->pquery($sql,array($profileid));
          
        	$query = " select ld_tab.tabid,operation,permissions,relatednames from ld_profile2standardpermissions inner join 
                    ld_tab on ld_tab.tabid=ld_profile2standardpermissions.tabid where profileid=?
                     and ld_profile2standardpermissions.tabid not in(9,33,44) 
                      order by(ld_tab.tabsequence),ld_profile2standardpermissions.sequence asc";
		   	$result = $adb->pquery($query,array($profileid));
                
            $num_rows1 = $adb->num_rows($result);
   			for($i=0; $i<$num_rows1; $i++)
            {           $tmp_tabname='';
                        $per_id = $adb->query_result($result,$i,'permissions');
                        if($per_id==1)
                             continue;
                        $action_id = $adb->query_result($result,$i,'operation');
        				$tab_id = $adb->query_result($result,$i,'tabid');
                        $relatednames=$adb->query_result($result,$i,'relatednames');
                        $tmp_tabname=getTabname($tab_id);
                       
        				if(!isset($temp_tabid[$tab_id])){
        					$temp_tabid[$tab_id] = 1;
        					$access = Array();
        				}
        				
        				
        				$access[$action_id] = $per_id;
        				if($tab_id==9){
        					$tab_id = 16;
        				}
        				$check[$tab_id] = $access;
                         if($tmp_tabname=='OftenUseReport')
                        {
                            
                           $check[$tab_id]['relatednames']=$relatednames;
                           if($adb->num_rows($mobilereportresult)<=0)
                            {
                                //历史数据，移动端报表
                                $mobilereportname=$this->getMobileReportNames();
                                $relatednames=array();
                                foreach($mobilereportname as $mobilenames)
                                {
                                    $relatednames[]=$mobilenames['name'];
                                }
                                $check[-2][3]=0;
                                $check[-2]['relatednames']=implode(',',$relatednames);
                            }
                        }
                        if($tmp_tabname=='MobileReport')
                        {
                         
                            
                            //移动端报表
                            $check[$tab_id]['relatednames']=$relatednames;
                        }
                        
   			}
           
            
            
             $sql="select * from ld_profile2field where profileid=?";
             $result=$adb->pquery($sql,array($profileid));
             $noofrows=$adb->num_rows($result);
             for($i=0;$i<$noofrows;$i++)
             {
                $fieldid=$adb->query_result($result,$i,'fieldid');
                $visible=$adb->query_result($result,$i,'visible');
                $readonly=$adb->query_result($result,$i,'readonly');
                $editreadonly=$adb->query_result($result,$i,'editreadonly');
                $profilefield[$fieldid]=array('fieldid'=>$fieldid,'visible'=>$visible,'readonly'=>$readonly,'editreadonly'=>$editreadonly);
                
             }
             
             $ret_data['button']=$check;
             $ret_data['field']=$profilefield;
             $this->profilePermission[$profileid]=$ret_data;
             CacheDirectory($cachekey,'profile',$ret_data); 
            return $ret_data;
    }
  
	/**
	 * @version:6.0 角色权限改进
	 * @reason 获取模块的已有的操作权限
	 * @author Chj 
	 */
	public function getProfileAction_Used($profileid){
	   
            $ret_data=$this->getProfileInfos($profileid);
            return $ret_data['button'];
        	
        
	}

	/**
	 * 获取模块权限控制信息
	 * @param String $module 模块名
	 * @param Integer $profileid 权限ID
	 * @return 权限控制结果集 Array
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-27
	 */
	public function getModuleProfile($module,$profileid = '') {
		if(empty($profileid)){//权限ID为空，则取当前用户的权限ID
			global $current_user;
			$profileid = $current_user->profileid;
		}
		$tabid = getTabid($module);
		$check = $this->getProfileAction_Used($profileid);
		if(isset($check[$tabid])){
			return $check[$tabid];
		}
		return '';
	}
	



    /**
     * edit:can
     * reason:获取权限列表、
     * */
    public function getAllProfileList()
    {
        global $adb;
        $sql='select * from ld_profile  order by profileid asc';
      
        $result=$adb->pquery($sql,array());
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $profileid=$adb->query_result($result,$i,'profileid');
            $description=$adb->query_result($result,$i,'description');
            $profilename=$adb->query_result($result,$i,'profilename');
            $profilelist[$profileid]=array('profileid'=>$profileid,'description'=>$description,'profilename'=>$profilename);
            
        }
        
        return $profilelist;
    }
	/**
	 * @version:6.0 角色权限改进
	 * @reason 获取角色下的全部用户
	 * @author Chj 
	 */
	public function getProfileOfUsers($profileid)
	{
		global $adb;
		$query='select id,last_name,wx_userid from ld_users where profileid = ? order by CONVERT(last_name USING gbk)  ASC ';
		$result = $adb->pquery($query,array($profileid));
		$num_rows = $adb->num_rows($result);
		if($num_rows > 0){
			for($i = 0; $i<$num_rows; $i++)
			{
				$userid = $adb->query_result($result,$i,'id');
                $wx_userid=$adb->query_result($result,$i,'wx_userid');
                
				$last_name = $adb->query_result($result,$i,'last_name');
                $userobj=new Users();
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$last_name;
                
				$userArr[$userid] = getUserlastName($userobj);
			}
		}
		return $userArr;
	}

    /**
     * @reason 获取角色下的全部启用用户
     * @author ljj
     */
    public function getProfileOfActiveUsers($profileid)
    {
        global $adb;
        $query='select id,last_name,wx_userid from ld_users where profileid = ? and status=? order by CONVERT(last_name USING gbk)  ASC ';
        $result = $adb->pquery($query,array($profileid,'Active'));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++)
            {
                $userid = $adb->query_result($result,$i,'id');
                $wx_userid=$adb->query_result($result,$i,'wx_userid');

                $last_name = $adb->query_result($result,$i,'last_name');
                $userobj=new Users();
                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$last_name;

                $userArr[$userid] = getUserlastName($userobj);
            }
        }
        return $userArr;
    }
	/**
	 * @version:6.0 角色权限改进
	 * @reason 所有用户角色的操作权限
	 * @author Chj 
	 */
	public function CheckPermitted($module,$actionname,$record_id=''){
		global $current_user,$adb;
        
		global $errProfile;
		$errProfile = '';
    
        
       
        if(strtolower($actionname)=='massdelete')
        {
            //edit:can 14728: 控制面板>共享规则：共享规则相关问题。
            $actionname='Delete';
        }

		if($module == 'QuotesChange' && $actionname == 'Create'){
			if(!empty($_REQUEST['change_type'])){
				if($_REQUEST['change_type'] == 'add')$actionname = 'QuotesChange_Add';
				if($_REQUEST['change_type'] == 'replace')$actionname = 'QuotesChange_Replace';
				if($_REQUEST['change_type'] == 'edit')$actionname = 'QuotesChange_Edit';
			}else{
				$actionname = 'QuotesChange_Add';
			}
		}

        if(strtolower($actionname)=='massedit') $action='EditView';
        if(empty($actionname)) $actionname = 'index';
		if('MailManager' == $module) $module = 'Emails';//判断邮件管理设置权限，直接判断Emails模块权限
		if($module == 'Emails') $actionname = 'index';
        //33496: 角色权限：增加“工作汇报”和“客户地图”，显示在“成员管理”的下方，新增权限时默认不勾选
        //$module == 'CooperativeWork' || $module == 'ChinaMap'
		/*
		*edit: chj
		*date: 2020/8/25
		*reason: 42060: （https://61mis.com/kfbtest [^]）普通成员登陆，单据新建/编辑界面，“所属行业”、“公司性质”、“注册资金”字段下拉选项中没有工商信息可回填字段对应的字段值，进行回填操作后，该字段没有新增并显示对应的字段值（客户模块测试）
		*/
        if($module == 'CustomView' || $module == 'PickList')return 'yes';
		//43178: （https://61mis.com/kfbcrm [^]）角色权限中没有授权“渠道码”查看权限，普通成员应该不显示渠道码模块
		if($module == 'ChannelCode' && $actionname != 'index')return 'yes';
		//$module == 'ChannelCode'
		if($actionname == 'Save'){
		  if($module=="ServiceReturn")
          {
            //32118: 客户服务单明细界面>相关信息>非管理员用户，客户服务单相关信息新建服务回访单保存不了。提示您没有权限执行这个操作。
          //43211: （本地php54，8.3.0版本）服务管理-客户服务单-相关信息-服务回访单-新建-保存；打开服务回访单编辑操作，保存时提示您没有权限编辑其他成员的单据；
          //  $module="HelpDesk";
          }
			if(empty($_REQUEST['record'])){
				$actionname='Create';
			}else{
				$actionname='EditView';
			}
            if($module=='SalesGoal')
            {
                //销售目标编辑
                $actionname='EditView';
            }
		}
		//if($module == 'Documents' && $actionname == 'Copy')return 'yes';
		if($module == 'Prdtnums' && ($actionname = 'EditView')) $actionname = 'index';
        //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能（新增创建权限）
		if((/*$module == 'SalesBack' || $module == 'PurchaseBack' || $module == 'PurchaseCashBack' || $module == 'CashBack'|| */$module == 'PaymentPlan'|| $module == 'SendPayment') && $actionname =='Create'){
			$actionname ='EditView';
		}
        if($module == 'Settings' && !empty($_REQUEST['kingdee']) && $_REQUEST['kingdee']=='yes'){
            return 'yes';
        }
		/*
		*edit: chj
		*date: 2020/7/27
		*reason: 42127: （61mis.com/kfbcrm）出库单模块列表界面：使用普通用户登录，点击列表界面的“打印”按钮显示报错，使用管理员账号登录是正常的。
		*/
		if($actionname == 'Printview' && $module == 'Settings'){
			return 'yes';
		}
        //edit:can 2020-12-15 43763: （http://51mis.com/demo/yiwenjidian/ [^]）（义文帐套）销售管理-报价单/销售订单-新建；报价单和销售订单模块的分录中的“报价计量单位”，先选择客户，再选择产品信息，报价计量单位下拉框无法点击，这里涉及到了存储过程，成员无法点击
        if($actionname == 'getRelatedDetailField' && $module == 'Settings'){
			return 'yes';
		}
		if($module == 'Users'){
		  
			if($actionname != 'index' && $actionname != 'EditView' && $actionname != 'DetailView'
            &&$actionname!="RoleProfile"&&$actionname!="DataScope"&&$actionname!="UserStop"&&$actionname!="AllowSetRoleDataProfile"
            &&$actionname!="UserActivate"&&$actionname!=="Delete"&&$actionname!='Import'&&$actionname!="Export"
            &&$actionname!="Copy"&&$actionname!='Create' &&$actionname !='Department' && $actionname!='JobLevel'){
				return 'yes';
			}else{
			 	if($actionname == 'index' || $actionname == 'EditView'  || $actionname == 'DetailView'
            ||$actionname=="RoleProfile"||$actionname=="DataScope"||$actionname=="UserStop"||$actionname=="AllowSetRoleDataProfile"
            ||$actionname=="UserActivate"||$actionname==="Delete"||$actionname=='Import'||$actionname=="Export"
            ||$actionname=="Copy"||$actionname=='Create'||$actionname =='Department' || $actionname=='JobLevel')
                {
                    
                }
                else
				$actionname = 'index';
			}
			
		}
       
         if(isSearchCRMVersion()=='yes'&&$module!='MobileReport')
        {
            if($module=='Users'&&is_admin($current_user))
            {
                return 'yes';
            }
          $tmpactioninfos=  getAllActionInfo();
          $tmpactioninfos=$tmpactioninfos['action'];
      
          foreach($tmpactioninfos as $tmpindex=>$tmpactioninfo)
          {
            
             if(strtolower($tmpactioninfo['actionname'])==strtolower($actionname))
             {
                
                if($tmpactioninfo['securitycheck']==1)
                    return 'no';
                else
                    return 'yes';
             }
          }
          
          return 'yes';
            
        }
        
		$is_admin=is_admin($current_user);
        if($module=="Settings")
        {
            if($current_user->getHaveSetProfile("Settings")=='yes')
                return "yes";
        }
        //1、判断是否是管理员
		if($is_admin)
		{
			return 'yes';
		}
        $languageType= getLanguageType($current_user);
        if($module=='MobileReport')
        {
            static $mobilereport_relatednames;
            if(is_array($mobilereport_relatednames)&&$mobilereport_relatednames[0]!='')
            {
                if(!in_array(strtolower($actionname),$mobilereport_relatednames))
                {
                    return 'no';
                }
                return 'yes';
            }
            $sql='select * from ld_profile2standardpermissions where profileid=? and tabid=? ';
         
            $mobilereportresult=$adb->pquery($sql,array($current_user->profileid,-2));
            if($adb->num_rows($mobilereportresult)>0)
            {
                $relatenames=$adb->query_result($mobilereportresult,0,'relatednames');
                $mobilereport_relatednames=explode(",",strtolower($relatenames));
                if(!in_array(strtolower($actionname),$mobilereport_relatednames))
                {
                    return 'no';
                }
                return 'yes';
            }
           else
            {
                $mobilereport_relatednames=array('sssssssssss');
                return 'no';
            }
            
        }
		$permission = "no";
		if($module == 'Emails' && $_REQUEST['action'] == 'GroupEmail'){
			$tabid = getTabid('MassEmails');
		}else{
			$tabid = getTabid($module);	
		}
        if($tabid == 9)$tabid = 16;


		$actionid = getActionid($actionname);
        
	//	$moduleprofile = $this->getAllActionsFortab();//模块操作所有的按钮权限
		
		//2、特殊模块控制
		if(($module == 'Home' || $module == 'Approve' || $module == 'uploads'||$module == 'Reminds'||$module=='ModTracker'|| $module=='Reports' || $module=='XlsImport') && $_REQUEST['parenttab'] != 'Settings')
		{
			return 'yes';
		}
		if($module != 'Users'){
    		  //以下模块只有管理员才可以进入
              //$module=='RecycleBin'33802: PC端：角色权限中增加回收站，默认勾选。WEB端菜单定制中，工具菜单下显示回收站。
    		if($module == 'Settings' || $module == 'Administration' || $module == 'System'  || $_REQUEST['parenttab'] == 'Settings')
    		{
    			if(!$is_admin)
    				return 'no';
    			else
    				return 'yes';
    		}
		}
		
		//获取所有操作类型
		//$profileall = array_flip($this->getActionMappingNum());
		//获取用户数据权限
		$userPermission = $current_user->access;
        if($record_id>0)
        {
             $focus=CRMEntity::getInstance($module);
           
        }
        $smcreatorfieldname='';
		if($module != 'SalesGoal'){
			//3、用户数据操作权限
            if($actionname == 'DetailView'&&$record_id>0)
			{
			         
                    //edit:can 20200826 判断汇报人字段是否启用
                    if($current_user->isExistReprotertouserField()=='yes')
                    {
                        //edit:can 20200826 查看单据详情时，如果当前操作员是改单据“负责人”对应的“汇报人”，
                        //edit:can 20200826  则当前操作员也可以查看用户详情。权限优先级高于业务单据数据范围中的“查看其他成员的单据详情”
                         $focus->retrieve_entity_info($record_id,$module);//用这个函数，则detailview.php不用重新再读数据库
                         $smownercolumnname=$focus->getSmownerColumName();
                         $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$smownercolumnname,'fieldname');
                         $sql='select reportertouser from ld_users where id='.$focus->column_fields[$fieldname].' and reportertouser is not null and reportertouser <>"" ';
                         $result=$adb->pquery($sql,array());
                         if($adb->num_rows($result)>0)
                         {
                            $reportertouser=$adb->query_result($result,0,'reportertouser');
                            $reportertouser_arr=explode(",",$reportertouser);
                            if(in_array($current_user->id,$reportertouser_arr))
                            {
                                return 'yes';
                            }
                         }
                    }
			         $scopeobj=ScopOfAuthority::getInstance($adb,$module);
                 
                    
                       if($scopeobj->modulescolist[$module]['viewcreateme'] == 1 ){
                                
                                 $focus->retrieve_entity_info($record_id,$module);//用这个函数，则detailview.php不用重新再读数据库
                               
                                $creatorcolumnname= $focus->getCreateColumnName();  
                              
                                $tmp_allfields=$focus->fieldobj->getAllFields();     
                               
                                foreach($tmp_allfields as $blockid=>$tmp_arrfield){
                                    
                                    foreach($tmp_arrfield as $tmp_fields)
                                    {
                                        if($tmp_fields['columnname']==$creatorcolumnname)
                                        {
                                            $smcreatorfieldname=$tmp_fields['fieldname'];
                                            break;
                                        }
                                    }
                                }       
                       }
                                            
                        
                   
                if($module=='Accounts')
                {
					$focus->retrieve_entity_info($record_id,$module);//用这个函数，则detailview.php不用重新再读数据库
					crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
					$cls_PublicAccounts = cls_PublicAccounts::getInstance($module);
					$public_account = $cls_PublicAccounts->getPublicAccountConfig();
                    //公海未分配客户不控制数据权限（可查询所有公海未分配客户）)0：不控制，1：控制
                    if($public_account['status']=='yes'&&$public_account['public_account_pool'][$focus->column_fields['pool_id']]['dataprofile'] != 'yes')
                    {
                       
                       if($focus->column_fields['publicaccount']==1)
                       {
						   //chj 2021/3/10 44925: （https://61mis.com/kfbcrm [^]）chenzj这个账号的数据范围是：可以查看全部客户权限，并且可以查看详情，但是无法进入旧公海未分配客户的详情页面
                            if($scopeobj->modulescolist['Accounts']['viewothers'] == 1)
                            {
                                return 'yes';
                                
                            }
                            else
                            {

                                //@edit:liushuai,2020-10-14,reason:0042880: 客户模块列表界面>公海未分配>搜索编号为“ACC4021”：点击进入明细界面提示“您没有权限执行这个操作”，此客户的负责人是自身,却无法查看明细.
                                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
                                if($focus->column_fields[$fieldinfo->getFieldName()] == $current_user->id)  //如果当前登录用户是负责人，就有权限查看
                                {
                                    return 'yes';
                                }

                                if(($scopeobj->modulescolist['Accounts']['viewcreateme'] == 1&&$focus->column_fields[$smcreatorfieldname]==$current_user->id))
                                {
                                    return 'yes';
                                }
                                return 'no';
                            }
                       }
                    }
                   
                    
                }
                
    			 if($scopeobj->modulescolist[$module]['viewothers'] == 1 ){
    				return 'yes';
    			}
               
                if($scopeobj->modulescolist[$module]['viewcreateme'] == 1&&$focus->column_fields[$smcreatorfieldname]==$current_user->id)
                {
                    return 'yes';
                }
			}
			
		}
        //连接码
       if( isset($current_user)&&empty($current_user->profileid))
       {
           $use_info=getuserInfoByPrivileges($current_user);

           if( !is_array($use_info)||!array_key_exists('profileid',$use_info))
           {
               $current_user->profileid=0;
               return ;

           }
           $current_user->profileid=$use_info['profileid'];
       }
		//4、判断用户有没当前的角色权限
		$profileinfo = $this->getProfileAction_Used($current_user->profileid);
       
		if($actionid == '')
		{
			if($profileinfo[$tabid]['Index'] ==0 && !empty($profileinfo[$tabid]))
				$permission = "yes";
			else
				$permission ="no";
			return $permission;
		}

        if(!isset($profileinfo[$tabid][$actionid])||$profileinfo[$tabid][$actionid] === '')
    	{
    	   //36229: （1.6登录 ）模块没有删除权限，但成员管理界面设置可以删除其他成员单据时，则该模块列表界面和单据查看明细界面也不应该显示【删除】按钮（客户模块测试）
    			return 'no';
    	}
      
 	  if($module != 'SalesGoal'){
			///成员管理，编辑和删除权限优化
            if($actionname=='Delete')
            {
                $scopeobj=ScopOfAuthority::getInstance($adb,$module);
                if($module=='Accounts'&&!empty($record_id))
                {
					$focus=CRMEntity::getInstance($module);
                      $focus->retrieve_entity_info($record_id,$module);//有待优化用这个函数，则editview.php不用重新再读数据库
					crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
					$cls_PublicAccounts = cls_PublicAccounts::getInstance($module);
					$public_account = $cls_PublicAccounts->getPublicAccountConfig();
                    //公海未分配客户不控制数据权限（可查询所有公海未分配客户）)0：不控制，1：控制
                    if($public_account['status']=='yes'&&$public_account['public_account_pool'][$focus->column_fields['pool_id']]['dataprofile'] != 'yes')
                    {
                       
                       if($focus->column_fields['publicaccount']==1)
                       {
                            if($scopeobj->modulescolist['Accounts']['delothers'] == 1)
                            {
                                return 'yes';
                                
                            }
                            else
                            {
                                return 'no';
                            }
                       }
                    }
                   
                    
                }
               	if($scopeobj->modulescolist[$module]['delothers']== 1){
    				return 'yes';
    			}
            }
           
	        if($actionname == 'EditView'&&isset($profileinfo[$tabid][$actionid]))
			 {
			     $scopeobj=ScopOfAuthority::getInstance($adb,$module);
                  
			     if($scopeobj->modulescolist[$module]['editothers']== 1){
    				return 'yes';
    			}
               
			      if($scopeobj->modulescolist[$module]['editcreateme'] == 1&&$record_id>0 ){
                                                
                            $focus->retrieve_entity_info($record_id,$module);//用这个函数，则detailview.php不用重新再读数据库
                                
                            $creatorcolumnname= $focus->getCreateColumnName();  
                           
                           $tmp_allfields= $focus->fieldobj->getAllFields();  
                            foreach($tmp_allfields as $blockid=>$tmp_arrfield){
                                 
                                    foreach($tmp_arrfield as $tmp_fields)
                                    {
                                        if($tmp_fields['columnname']==$creatorcolumnname)
                                        {
                                            $smcreatorfieldname=$tmp_fields['fieldname'];
                                            break;
                                        }
                                    }
                                }            
                }
			     
              
                 if($scopeobj->modulescolist[$module]['editcreateme'] == 1&&$focus->column_fields[$smcreatorfieldname]==$current_user->id)
                {
                    return 'yes';
                }
                
       	        
			 }
		}
		if((empty($record_id) || trim($record_id) == '') && isset($profileinfo[$tabid][$actionid])){
			return 'yes';
		}
        
		if(isset($record_id)&&($actionid==1 || $actionid==4))
		{
		
			$approve = Approve::getInstance($currentModule);
			$approvestatus = '';
			$approveby = '';
			$approveinfo=$approve->approveStatus($record_id);
			$approvestatus=$approveinfo['approvestatus'];
			$approveby=$approveinfo['nextstepapproveby']??'';
			   
			$array_approveby = explode(",",$approveby);        
			$array_approvebyLen = sizeof($array_approveby);
			$approvebystatus = 0;
			for($i = 0; $i< $array_approvebyLen; $i++)
			{
				if($array_approveby[$i]==$current_user->id)
				{
					$approvebystatus = 1;
				}
			}
          
            //$approvestatus:并发审批中待审批
            //$approvestatus==10:表示最后一步为跳过审批
            $approveresult_arr = array(1,5,6,12,10,14,15,16,17,18);
			if(in_array($approvestatus,$approveresult_arr)&&$approvebystatus==1)//如果审批中，则有编辑权限
			{
				return 'yes';
			}           
		}
        
		//5、判断共享规则  0:公开：只读  1、公开：读取、编辑  2、公开：读取、编辑、删除  3：私有
		//获取单据模块和负责人ID
		$recOwnId='';
		$recordOwnerArr=getRecordOwnerId($record_id,$module);
		foreach($recordOwnerArr as $type=>$id)
		{
			$recOwnId=$id;
		}
		$ScopOfAuthority = ScopOfAuthority::getInstance($this->adb,$module);
		$others_permission_id = $ScopOfAuthority->getModuleShareInfo();

		//判断单据负责人是不是自己
		if($recOwnId == $current_user->id){
			return 'yes';
		}
		if($others_permission_id == 0 && $others_permission_id != '')
		{
			//编辑、删除
			if($actionid == 1 || $actionid == 0 || $actionid == 2)
                //wym XUQIU1001811 增加自定义规则，可设置满足条件的单据自动共享给成员/部门/角色
                if($ScopOfAuthority->getshareCustomrule($actionid,$record_id)) {
                    return 'yes';
                }else{
                    return 'no';
                }
			else
				return 'yes';
		}
		else if($others_permission_id == 1)
		{
			if($actionid == 2)	//删除
				return 'no';
			else
				return 'yes';
		}
		else if($others_permission_id == 2)
		{
	
			return 'yes';
		}
		else if($others_permission_id == 3 || $others_permission_id == '')
		{
			$userPermission = $current_user->access;
			if($actionid == 1 || $actionid == 0)	//编辑
			{
                //wym XUQIU1001811 增加自定义规则，可设置满足条件的单据自动共享给成员/部门/角色
                if($ScopOfAuthority->getshareCustomrule($actionid,$record_id)) {
                    return 'yes';
                }
				//首先判断负责人是否为自己  和 是否可以编辑其他的用户单据
				if($recOwnId == $current_user->id)
				{
					return 'yes';
				}
				$errProfile = getFixedLabel('YOUARENOTALLOWEDTOEDITOTHERUSERSDATE');
				return 'no';
			}
			else if($actionid == 2)
			{
				//首先判断负责人是否为自己  和 是否可以删除其他的用户单据
				if($recOwnId == $current_user->id){
					return 'yes';
				}else{
					return 'no';
				}
			}
			else if($actionid == 11)
			{
				//首先判断负责人是否为自己  和 是否可以编辑其他的用户单据
				if($recOwnId == $current_user->id || $userPermission['creator'] == 1){
					return 'yes';
				}else{
					return 'no';
				}
			}
			else if($actionid == 4)//查看
			{
                //wym XUQIU1001811 增加自定义规则，可设置满足条件的单据自动共享给成员/部门/角色
                if($ScopOfAuthority->getshareCustomrule($actionid,$record_id)){
                    return 'yes';
                }
				//首先判断负责人是否为自己  和 是否可以查看其他的用户单据
				if($recOwnId == $current_user->id){
					return 'yes';
				}else{
					$errProfile = getFixedLabel('YOUARENOTALLOWEDTOVIEWOTHERUSERSDATE');
					return 'no';
				}
			}
			else
			{
				return 'yes';
			}
		}
		return 'yes';
	}
	/**
	 * @version:6.0 角色权限改进
	 * @reason 删除用户对应角色信息
	 * @author Chj 
	 */
	public function deleteProfile($profileid)
	{
		global $adb;
		if(!empty($profileid) && $profileid >= 1)
		{
			$adb->pquery('delete from ld_profile where profileid=?',array($profileid));
			$adb->pquery('delete from ld_profile2field where profileid=?',array($profileid));
            $query = 'select profileid from ld_profile order by profileseq';
            $result = $adb->pquery($query);
			$num_rows = $adb->num_rows($result);
            for($i=0;$i<$num_rows;$i++)
            {
                $profileidnow=$adb->query_result($result,$i,'profileid');
                $adb->pquery('update ld_profile set profileseq=? where profileid=?',array($i+1,$profileidnow));
            }
			$this->deleteProfilePermissions($profileid);
		}
	}
    
    public function deleteProfilePermissions($profileid)
	{
		global $adb;
		if(!empty($profileid) && $profileid >= 1)
		{
			$adb->pquery('delete from ld_profile2standardpermissions where profileid=?',array($profileid));
		}
	}
	/**
	 * 获取用户对应的权限ID
	 * @param Integer $userid 用户id
	 * @return Integer $profileid 权限ID
	 * @author Tujt 2015-07-06
	 */
	public function getUserProfileId($userid) {
	    static $staticuserroleid;
		$statickey = 'staticgetUserRoleId'.$userid;
		if(!empty($staticuserroleid) && isset($staticuserroleid[$statickey]))
			return $staticuserroleid[$statickey];
		global $adb;
		/**
		 * 获取用户对应的权限ID
		 * @author Tujt 2015-04-20
		 */
		$query = 'select profileid from ld_users where id = ? limit 1;';
		$result = $adb->pquery($query,array($userid));    
		$profileid = $adb->query_result($result,0,'profileid');
		return $staticuserroleid[$statickey] = $profileid;
	}
}
?>