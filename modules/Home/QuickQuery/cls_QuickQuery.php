<?php
crm_load_class_file("cls_module_uitype",'include/fields');

class cls_QuickQuery 
{
    public $module;
    public $queryobj;
    public $customviewobj;
    public $productdetailobj;
    public $page_list_query;
    public $list_query;
    public function __construct($module)
    {
        global $current_user;
        $this->module=$module;
        $this->customviewobj=new UnifiedSearch_CustomView($module);
        if($module=='Reminds')
            $this->customviewobj->cvid=$this->customviewobj->getViewIdByName('quicksearchAll',$module);
        else if($module=='Calendar')
        $this->customviewobj->cvid=$this->customviewobj->getViewIdByName('All','events');
        else
            $this->customviewobj->cvid=$this->customviewobj->getViewIdByName('All',$module);
    //29285: pc端右上角快速查找不应该根据当前页面 查看范围来控制数据权限，应该根据当前用户的数据权限来控制（比如客户模块，查看范围选择A，然后右上角快速查找找一个不是A的数据查找，就查找不出来了。改账户数据权限是可以看到所有数据的。）
         $tmp=$_SESSION['lvs'][$this->module]['SearchScope'];
        $_SESSION['lvs'][$this->module]['SearchScope']='';
        $_REQUEST['viewname']=$this->customviewobj->cvid;
        crm_load_class_file('ProductDetails','include/ProductDetails');
       $this->productdetailobj= ProductDetails::getInstance($module,'');
      if($module=='Accounts'){
          $_REQUEST['pagepublicaccounttype']='ALLACCOUNT';
          $_REQUEST['publicaccount_whethershow']=0;
      }
       $this->queryobj= QueryGenerator::getInstance($module, $current_user,$this->customviewobj,$productdetailobj);
       $this->productdetailobj->queryGenerator=$this->queryobj;
      $this->queryobj->initForCustomViewById($this->customviewobj->cvid);
          $_SESSION['lvs'][$this->module]['SearchScope']=$tmp;
    }
    public function getWhereClause()
    {
		global $current_user;
		require(globalStatic::$root_directory."user_privileges/user_language_".$current_user->id.'.php');
		$this->queryobj->whereFieldTables=array();
		$focus=$this->queryobj->moduleobj;
		$moduleFieldList = $focus->fieldobj->getModuleFields();
		crm_load_class_file('cls_Uitype_table','include/fields');
		
        if($this->module=="Accounts" ||$this->module=='ServiceCharge')
        {
            $deploy_sys=getSys_deploy("72");
            if($deploy_sys['deploy_value']==0)
            {
                //$this->whereFieldTables['ld_contactdetails']=' ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid and ld_contactdetails.reference=1 and ld_contactdetails.deleted=0 ';
               //  $this->whereFieldTables['ld_contactscf']=' ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid ';
            }
        }
        
        $searchvalue=trim($_REQUEST['query_string']);
        $account_version = get_versionaccount();
       

          foreach($moduleFieldList as $fieldname=>$fieldinfo)
          {
			  //2021/12/22 chj 山水特殊控制，全局查找，客户和联系人 只查找：客户名称、联系人姓名、手机号，因为客户数据量太大，执行速度太大
			if($account_version == 'shanshui'){
				if($this->module == 'Accounts' && !in_array($fieldname,array('accountname','account_no'))){
					continue;
				}
				if($this->module == 'Contacts' && !in_array($fieldname,array('lastname','mobile'))){
					continue;
				}
			}
            if(!in_array($fieldinfo->getTableName(),$this->queryobj->moduleobj->tab_name))
                continue;
                
             if($fieldinfo->getSaveDataBase()=='no')
             {
                continue;
             }
             if($fieldinfo->getFieldName()==''||$fieldinfo->getColumnName()=='')
             {
                //源单字段
                continue;
             }
            
           $bigtype=$fieldinfo->getBigType();
           $uitype=$fieldinfo->getUIType();
           $columnname=$fieldinfo->getColumnName();
           $tablename=$fieldinfo->getTableName();
           //edit:can 20210507 045793: （https://61mis.com/kfbcrm/ [^]）公司系统全局查找无法查询到客户
           if($bigtype=='qrcode')
            continue;
           //wym 240105 BUG0077001 全局查找-查找单据（附件管理ATT53 ），显示为空
              //wym 加了这个判断后，全局查找附件模块会报错（sql中没有连附件自定义表），目前先注释了。
           //if($focus->module_name!='Attachment')
               $this->queryobj->whereFieldTables[$focus->customFieldTable[0]]=" ".$focus->customFieldTable[0]." on ".$focus->customFieldTable[0].".".$focus->customFieldTable[1].'='.$focus->table_name.".".$focus->table_index;
               //zkt 20240522 BUG20240513-16  销售订单模块>单据编号为“XSHT540”：该单据备注字段有输入值然后通过全局搜索搜索不到。
               if(!in_array($tablename,array_keys($this->queryobj->whereFieldTables))){
                   $this->queryobj->whereFieldTables[$tablename]=" ".$tablename." on ".$tablename.".".$focus->tab_name_index[$tablename].'='.$focus->table_name.".".$focus->table_index;
               }
            
            
             if( $fieldinfo->getUIType()==53)
             {
                $user_columnname=$fieldinfo->getColumnName();
				//chj 2021/5/27 46098: (http://14.116.189.133:85/crm [^])(易而普)是用全局查找查找‘与光同行’时客户模块中没有数据，但是客户模块中是有这个客户的
				$user_tablename=$fieldinfo->getTableName();
				//chj 2022/4/2 50709: https://kehu001.com/WX/kh47970/ [^] 【腾中锦鹏】客户的全局搜索功能检索关键字搜出来的数据信息不全（已设置全部模块
				crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
				$port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21
				 $wx_userarr =$port_obj->getwxUserid('like',$searchvalue);
				 $astablename='users_'.$fieldname;//表别名：模块名称小写_fieldname
				 if(is_array($wx_userarr) &&array_key_exists('userid',$wx_userarr))
				 {
					$wx_userid=implode("','",$wx_userarr['userid']);
					$wx_userid="'".$wx_userid."'";
					
					$wheresql[]= " $astablename.wx_userid in($wx_userid)";
				 }else{
					$wheresql[]=" $astablename.last_name like '%$searchvalue%'";
				 }
                 $this->queryobj->whereFieldTables[$astablename]=' ld_users as '.$astablename. " on $astablename.id=$user_tablename.$user_columnname";
                
                
             }
             else if($bigtype=='reference')
             {
               $uitypemodules=  cls_module_uitype::getUitypeModules();
               $referencemodule=$uitypemodules[$uitype];
               if(!empty($referencemodule)&&$this->module!=$referencemodule)
               {
                
                    $referencefocus=CRMEntity::getInstance($referencemodule);
                    $list_link_field=$referencefocus->list_link_field;
                    $table_index=$referencefocus->table_index;
                    $tmptablename=$referencefocus->fieldobj->getFieldInfoBykeyValue("fieldname",$list_link_field,'tablename');
                   
                    if($tmptablename==$referencefocus->table_name)
                    {
                      if($tmptablename==$focus->table_name)
                      {
                         $wheresql[]=" $columnname"."_"."$tmptablename.$list_link_field like '%$searchvalue%'";
                        
                        
                        $this->queryobj->whereFieldTables["$columnname"."_"."$tmptablename"]=" $tmptablename as $columnname"."_"."$tmptablename on $tmptablename.$table_index= $columnname"."_".$tmptablename.".".$fieldinfo->getColumnName();
                      }
                      else
                      {
                       
                          if($this->module=='Accounts'&&($tmptablename=='ld_contactdetails'||$tmptablename=='ld_contactscf'))
                          {
                            $this->whereContactsTable[$this->ld_contactdetails]=' ld_contactdetails on ld_contactdetails.accountid=ld_account.accountid and ld_contactdetails.deleted=0';
          
                          }
                          else
                          {
                             $wheresql[]=" $tmptablename.$list_link_field like '%$searchvalue%'";
                             $this->queryobj->whereFieldTables[$tmptablename]=" $tmptablename on $tmptablename.$table_index= ".$fieldinfo->getTableName().".".$fieldinfo->getColumnName();
                          }
                      }
                    }
               }
             }
             else if($fieldinfo->getUIType()==4)
             {
                $wheresql[]=$fieldinfo->getTableName().".".$fieldinfo->getColumnName(). " like '%$searchvalue%'";
             }elseif($fieldinfo->getUIType()==242){
                 $wheresql[]=" LOCATE('$searchvalue',".$fieldinfo->getTableName().".id)>0 ";
             }else
             {
				$table_uitype= cls_Uitype_table::getTableJoinByUitype($fieldinfo->getUIType(),'','');
				if(empty($table_uitype)){
				    
                    $wheresql[]=" LOCATE('$searchvalue',".$fieldinfo->getTableName().".".$fieldinfo->getColumnName().")>0 ";
					//$wheresql[]=$fieldinfo->getTableName().".".$fieldinfo->getColumnName()." like binary  '%$searchvalue%'";
				}
             }
          }

        $this->queryobj->whereMainTable=$this->queryobj->whereFieldTables;

		if(get_file_address($this->module,'ProductDetails')&&$this->module!='ServiceCharge')
		{
			$productDetails=ProductDetails::getInstance($this->module,$languageType);
			$modulefields=$productDetails->getModuleFields();
            //35184: （1.6账套）快速查找输入框>输入合同订单编号进行搜索：没有搜索出来。（需要补丁）
            $detailtable=$this->queryobj->moduleobj->Detail_table;
            $detailtablescf=$this->queryobj->moduleobj->Detail_table_scf;
			 $this->queryobj->whereProductTable['ld_products']=" ld_products on ld_products.productid=$detailtable.productid ";
			foreach($modulefields as $columnname => $field){
				if(   $field->getTableName() == $detailtablescf){
					$this->queryobj->whereProductTable[$detailtablescf]=" $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id ";
				}
                if($field->getTableName()=='ld_productcf')
                {
                    
                    $this->queryobj->whereProductTable['ld_productcf']='ld_productcf on ld_productcf.productid=ld_products.productid';
                }
				if(($columnname == 'productname' || $columnname == 'product_no' || $columnname == 'productsheet') && $field->getTableName() == 'ld_products'){
					$wheresql[]=" LOCATE('$searchvalue',".$field->getTableName().".".$field->getColumnName().")>0 ";
				}
			}
		}
        
		$ret_wheresql='  and ('.implode(" or ",$wheresql).")";
          
          
          return $ret_wheresql;
        
    }



    public function getPageListQueryOrderByLeftJoin()
    {

        //请不要调用getOrderByLeftJoin
        $main_query=$this->moduleobj->table_name.'.'.$this->moduleobj->table_index;

        list($order_listquery,$order_by,$sorder) = $this->customview->getOrderWhere($order_listquery,'',$this);
        if(sizeof($this->moduleobj->orderby_tables)>0)
        {


            foreach($this->moduleobj->orderby_tables as $orderbytable=>$leftjoin )
            {
                //请不要调用getOrderByLeftJoin
                if($orderbytable=='ld_users'){//231012 wym XUQIU1001909 如果排序字段包括负责人字段,需要连表ld_users
                    $main_query_users=$this->moduleobj->table_name.'.'.$this->moduleobj->getSmownerColumName();
                    $order_by_table_index= 'id';
                    if(!empty($orderbytable)&&!empty($order_by_table_index)&&!array_key_exists('ld_users',$this->whereFieldTables)&&'ld_users'!=$this->moduleobj->table_name)
                    {
                        $sql.=' left join '.$leftjoin.' on ld_users.id='.$main_query_users;
                    }
                }else{
                    $order_by_table_index=$this->moduleobj->tab_name_index[$orderbytable];
                    //BUG0058733 ls 20221121 付款单新建时，采购负责人下拉框为空
                    if(!empty($orderbytable)&&!empty($order_by_table_index)&&!array_key_exists($orderbytable,$this->whereFieldTables)&&$orderbytable!=$this->moduleobj->table_name)
                    {
                        $sql.=' left join '. $orderbytable ." on $orderbytable.$order_by_table_index=$main_query";
                    }
                }
            }


        }
        return $sql;

    }

    public function getQuery($type)
    {
        //请不要删除，目的：设置公海参数：公海未分配客户不控制数据权限（可查询所有公海未分配客户）选择，然后再客户界面点击公海未分配
        //再快速查询，

		$where=$this->getWhereClause();

		if($this->module=='Accounts')
		{
			$_REQUEST['pagepublicaccounttype']='ALLACCOUNT';
			$_REQUEST['publicaccount_whethershow']=0;
            //0049005: https://kehu001.com/weixin/kh46238/ [^]）001通用问题：全景查找-搜索“批发业”-显示两条客户信息，但是返回到客户模块-点击筛选“查看范围”--返回全景查找就搜不到客户信息了
            $tmp=$_SESSION['lvs'][$this->module]['SearchScope'];
            $_SESSION['lvs'][$this->module]['SearchScope']='';
			$this->queryobj->getSmOwnerSearchSql =  $this->queryobj->scopeobj->getSmOwnerSearchSql();
            $_SESSION['lvs'][$this->module]['SearchScope']=$tmp;
		}
		//东贸特殊开发：全局查找搜索客户档案或者商户档案的时候会出现两个模块信息；
		$version_info = getVersionInfo();
		if($version_info['account'] == 'dongmao'){
			if($this->module=='Accounts')
			{
				$where = " and ld_account.customform10_id in (select customform10id from ld_customform10 where form10_type in ('商户','代理')) " . $where;
			}else if($this->module=='ServiceCharge')
			{
				$where = " and ld_account.customform10_id in (select customform10id from ld_customform10 where form10_type in ('下游客户','大巴车')) " . $where;
			}
		}
         if($type==1)
        {
            $this->page_list_query=$this->queryobj->getQuery('',$type).$where;

            $sql=$this->page_list_query;
          //dump($sql);
        }
       
        else if($type==2)
        {
             $this->list_query=$this->queryobj->getQuery('',$type);
             
             
             $sql=$this->list_query;

        }
    
   
            
            return $sql;
    }
    
}
?>