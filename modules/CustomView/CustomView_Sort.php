<?php

class CustomView_Sort
{
    private $module;
    private $customviewobj;
    private $special_fieldname;
    public $orderby_tables = [];
    static function getInstance($customviewobj,$module)
    {
        static $sortobj_array=array();

        if(isset($sortobj_array[$module]))
        {
            //duan 20230206 获取到缓存的对象后,需要重设customviewobj 属性,避免调用对象的方法时错误
            $sort_obj = $sortobj_array[$module];
            $sort_obj->customviewobj=$customviewobj;
            $sortobj_array[$module]=$sort_obj;
            return $sort_obj;
        }
        else
        {
            $sort_obj=new CustomView_Sort($customviewobj,$module);
            $sortobj_array[$module]=$sort_obj;
            return $sort_obj;
        }
    }
    public function __construct($customviewobj,$module)
    {
        $this->module=$module;
        $this->customviewobj=$customviewobj;
        $this->special_fieldname = array('nolinkdays');
    }

    public function getSortMappField()
    {
        global $adb;
        $tabid=getTabid($this->module);

        $sql='select  * from ld_sortfieldmapping where tabid=? ';
        $result=$adb->pquery($sql,array($tabid));
        $rows=$adb->num_rows($result);
        $arr=[];
        for($i=0;$i<$rows;$i++)
        {
            $origin_columnname=$adb->query_result($result,$i,'origin_columnname');
            $mapping_columnname=$adb->query_result($result,$i,'mapping_columnname');
            $mapping_sorttype=$adb->query_result($result,$i,'mapping_sorttype');
            $isonlydata=$adb->query_result($result,$i,'isonlydata');
            $mapping_tablename=$adb->query_result($result,$i,'mapping_tablename');


            $arr[]=['origin_columnname'=>$origin_columnname,'mapping_columnname'=>$mapping_columnname,"mapping_sorttype"=>$mapping_sorttype
                ,"isonlydata"=>$isonlydata,'mapping_tablename'=>$mapping_tablename];

        }

        return $arr;

    }
    public function getOrderWhere($focus,$query,$setype='',$queryGenerator='')
    {
        global $currentModule,$adb;

        //  $focus=CRMEntity::getInstance($this->module);
        if(!empty($setype)){//修改排序session默认键值(相关信息)
            $focus->order_by_session_col .= $setype;
            $focus->desc_session_col .= $setype;
        }
        //chj 2020/12/1 43528: （https://61mis.com/kfbcrm/ [^]）服务收费管理-表头字段（最晚服务到期日）点击这个字段会进行一次重新排序，但是第二次点击没有反应
        // if( $focus->moduleName== 'ServiceCharge')$focus->moduleName = 'Accounts';
        $focus->setOrderSortInfo();//符合条件，则清空排序session值
        $order = $focus->getOrderBy();

        //if(empty($order) && 0 == $focus->order_by_idx) return array($query,'','');
        //获取当前模块的表和主键


        $entityname = getEntitynameByModulename($focus->moduleName);
        $entityidfield = $entityname['entityidfield'];
    //   $tablenameaa = $entityname['tablename'];
        $entityidfield=$focus->table_index;
        $tab_idx = '';
        //gyqX170725\

        //	if(!empty($tablenameaa)){
        $tab_idx = $focus->table_name.'.'.$entityidfield;//主键
        //	}

        if(1 == $focus->order_by_idx){//默认排序
            //获取数据分类默认排序
            global $customView,$viewid,$related_left_customView,$related_left_viewid;

            if(!empty($queryGenerator))
            {

                $customView=$queryGenerator->customview;
            }
            $customsortorder = '';
            //edit:can reason:15186: 所有模块明细界面>相关信息>列表数据：数据排序与模块列表中，数据的排序不一致。
            if((!empty($customView) && $viewid > 0)||(!empty($related_left_customView) && $related_left_viewid > 0))
            {
                if(!empty($customView))
                {

                    $viewinfoobj=$customView->getViewInfoObj();

                    if(!is_null($viewinfoobj)&&!empty($viewinfoobj->getCvid()))
                    {

                        $customsortorder =$this-> getCustomViewOrderBy($viewinfoobj->getCvid());

                    }
                    else
                        $customsortorder =$this-> getCustomViewOrderBy($viewid);// $customView->getCustomViewOrderBy($viewid);
                }
                else
                    $customsortorder = $related_left_customView->getCustomViewOrderBy($related_left_viewid);
            }

            $ordertype=substr(trim($customsortorder),-5);
            if(stripos($ordertype,"desc")!==false)
            {
                //33703: 列表显示数据查询脚本优化：设置的排序字段和accoutid的排序字段自动设置成一样的
                $ordertype_tableid="desc";
            }
            else
            {
                $ordertype_tableid="asc";
            }



            if($currentModule == 'Approve'&& (is_null($viewinfoobj)||empty($viewinfoobj->getCvid()))){
                if(!empty($customView)){

                    $customsortorder = $customView->getCustomViewOrderBy($viewid);
                }else{
                    $related_left_customView->orderby_tables;
                }
            }

            if($queryGenerator!='')
            {
                $focus->orderby_tables = $queryGenerator->customview->orderby_tables;

            }
            else{

				//0029129: 市场活动、产品、销售机会，点击明细进去，左边相关信息，点击客户，全部数据分类不显示数据
				if(!empty($customView)){
					$focus->orderby_tables=$customView->orderby_tables;
				}else{
					$focus->orderby_tables=$related_left_customView->orderby_tables;
				}
			}



            if(!empty($customsortorder)){
                $customsortorder = trim($customsortorder,',');

                if(strtolower($focus->moduleName)=='reminds'){
                    //33703: 列表显示数据查询脚本优化：设置的排序字段和accoutid的排序字段自动设置成一样的
                    $query .= ' ORDER BY ld_reminds.date_time desc, '.$tab_idx." desc ";
                }else{
                    //33703: 列表显示数据查询脚本优化：设置的排序字段和accoutid的排序字段自动设置成一样的
                    $query .= ' ORDER BY '.$customsortorder.' ,'.$tab_idx.' '.$ordertype_tableid;
                }
                if(get_file_address($focus->moduleName,'ProductDetails') && !empty($queryGenerator) && !in_array($focus->moduleName,array('ServiceCharge'))){
                    $detailtable=$focus->Detail_table;
                    //BUG20240719-43 ls 240722 	采购订单选源单整单销售订单时，分录没有按照销售订单上的顺序在采购订单分录中排序(源单列头没有产品字段时也应该排序,将lineitem_id排序改为sequence_no)
                    $ProductTableColumn = $queryGenerator->ProductTableColumn;
                    if(is_array($ProductTableColumn) && count($ProductTableColumn) >= 1){
                        $query .= ",$detailtable.sequence_no";
                    }
                }
                return array($query,$customsortorder.' ,'.$tab_idx,$ordertype_tableid);
            }else if(!empty($tab_idx)){
                //28862: 附件管理：预置的数据分类没有设置排序字段，此时应该按照 创建时间或者id倒叙排序
                $query .= ' ORDER BY '.$tab_idx.' desc ';
                if(get_file_address($focus->moduleName,'ProductDetails') && !empty($queryGenerator)){
                    $ProductTableColumn = $queryGenerator->ProductTableColumn;
                    if(is_array($ProductTableColumn) && count($ProductTableColumn) >= 1){
                        $detailtable=$focus->Detail_table;
                        $query .= ",$detailtable.sequence_no";
                    }
                }
                //30574: 首页--组件视图--销售漏斗弹出层中：本页 没有统计
                return array($query,$tab_idx,'desc');
            }

        }
        else{//组装排序query
            $desc = $focus->getSortOrder();

            if(!empty($tab_idx)){
                $tab_idx = ','.$tab_idx.' '.$desc;
            }
            //22910: 联系记录列表不显示单据的问题
            if(stripos($order,'.')===false)
            {

                $order_table_name=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$order,'tablename');

                $order=$order_table_name.'.'.$order;

            }

            $Approveortorder = '';
            if($currentModule == 'Approve'){
                //edit:can 20230113 60805 （http://crm.airmaster.com.cn/crm）8482版本，审批中心，已处理，项目信息表，表头点击立项时间升序或者降序，顺序是错乱的。
                $tablename = $focus->table_name;
                //组装排序不需要了
                //$Approveortorder = " (case when $tablename.approveexpediting='yes' then 0 when $tablename.approveurgent='yes' then 1 else 2 end),";
            }
            $descColumn = explode('.',$order);

            $field_obj=Field::getInstance($focus->moduleName,$adb);
            if(sizeof($descColumn)<2)//如果排序字段传值不带表名称，则根据columnname,获取表名称
            {
                //17823: 费用报销>列表：点击审批人排序，结果：列表数据全部都不显示了。
                $descColumn[1]=$descColumn[0];
                $order_table_name=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$descColumn[1],'tablename');
                $descColumn[0]=$order_table_name;

            }
            else
            {
                $order_table_name=$descColumn[0];
            }
            $focus->orderby_tables=array($order_table_name=>$order_table_name);

            $fieldname =$field_obj->getFieldInfoBykeyValue('columnname',$descColumn[1],'fieldname');

            $typeofdata=$field_obj->getFieldInfoBykeyValue('columnname',$descColumn[1],'typeofdata');
            $moduleFieldList = $field_obj->getModuleFields();
            $field = $moduleFieldList[$fieldname];
            if(!empty($field))
            {
                if($field->getFieldDataType() == 'currency' || in_array($fieldname,$this->special_fieldname)){
                    $query .= ' ORDER BY '.$Approveortorder.$order .' ' . $desc.' '.$tab_idx.' ';
                }elseif($field->getColumnName()==$focus->getSmownerColumName()){//XUQIU1001909 点击列头负责人字段进行排序时,排序字段为负责人姓名而不是负责人id
                    //  $focus->orderby_tables['ld_users']=' (select @i:=@i+1 as userpingyin_seq,id,last_name,wx_userid ,user_name
                    //                   from ld_users ,(select @i:=0) as tmpsortuser order by pinyin_name asc) as ld_users ';
                    //wym XUQIU1002097 数据分类负责人排序代码优化：用户表增加一个姓名拼音的字段
                    $focus->orderby_tables['ld_users']='ld_users';
                    $orderby_name='ld_users.pinyin_name';
                    //wym BUG0073920 修改成拼音的字母顺序排序
                    $query .= ' ORDER BY '.$Approveortorder.$orderby_name.' '.$desc.' '.$tab_idx.' ';
                } else{
                    if(strtolower(substr($typeofdata,0,1))=='v')
                    {
                        $query .= ' ORDER BY '.$Approveortorder.' convert('.$descColumn[0].'.'.$descColumn[1].' using gbk) '.$desc.' '.$tab_idx.' ';
                    }
                    else
                    {
                        $query .= ' ORDER BY '.$Approveortorder.$descColumn[0].'.'.$descColumn[1].'  '.$desc.' '.$tab_idx.' ';
                    }
                }
                if(get_file_address($focus->moduleName,'ProductDetails') && !empty($queryGenerator)){
                    $ProductTableColumn = $queryGenerator->ProductTableColumn;
                    if(is_array($ProductTableColumn) && count($ProductTableColumn) >= 1){
                        $detailtable=$focus->Detail_table;
                        $query .= " ,$detailtable.sequence_no ";
                    }
                }
                return array($query,$order,$desc);
            }
        }
        return array($query,'','');//017383: 库存流水账/即时库存查询>序时簿,关于无法显示记录的问题
    }
    public function getCvColumnSort($cvid)
    {
        global $adb,$currentModule;
        $sortorder = array(0=>'',1=>'',2=>'',3=>'');
        $query = 'select columnname,sorttype from ld_cvcolumnlistsort where cvid = ?';
        $result = $adb->pquery($query,array($cvid));
        $numrows = $adb->num_rows($result);
        if($numrows == 0)
        {
            $columnnamesort = explode('|',$this->customviewobj->setCustonviewSortOrder($currentModule));
            $sortinfo = explode(',',$columnnamesort[0]);
            $orderinfo = explode(',',$columnnamesort[1]);

            for($i = 0; $i<count($sortinfo); $i++)
            {
                $sortorder[$i] = [];
                $sortorder[$i]['columnname'] = $sortinfo[$i];
                $sortorder[$i]['sort'] = $orderinfo[$i];
            }
            //print_r($sortorder);

        }
        else
        {
            for($i = 0; $i<$numrows; $i++)
            {
                $sortorder[$i] = [];
                $sortorder[$i]['columnname'] = $adb->query_result($result,$i,'columnname');
                $sortorder[$i]['sort'] = $adb->query_result($result,$i,'sorttype');
            }
        }

        return $sortorder;
    }
    public function save_sort()
    {
        global $adb;
        $module=$this->module;
        if($this->module != 'Home'){
            include_once(globalStatic::$root_directory.'modules/'.$module.'/'.$module.'.php');
            $focus = CRMEntity::getInstance($module);
            $tablename = $focus->table_name;
            $tabid = getTabid($module);

            $query = 'select tablename,fieldname,columnname,typeofdata from ld_field where tabid = ?';
            switch($module)
            {
                case 'Potentials':
                    $query .= " and columnname = 'modifiedtime'";
                    break;
                case 'HelpDesk':
                    $query .= " and columnname = 'hopetime'";
                    break;
                case 'ServiceCharge':
                    $query .= " and columnname in ('servicecasher','createdtime')";
                    break;
                case 'Reminds':
                    $query .= " and columnname = 'date_time'";
                    break;
                default:
                    // $query .= " and columnname = 'date_time'";
                    $query .= " and columnname = 'createdtime'";
            }
            $result = $adb->pquery($query,array($tabid));
            $num_rows = $adb->num_rows($result);
            for($i = 0; $i<$num_rows; $i++)
            {
                $tablename = $adb->query_result($result,$i,'tablename');
                $fieldname = $adb->query_result($result,$i,'fieldname');
                $columnname = $adb->query_result($result,$i,'columnname');
                $typeofdata = $adb->query_result($result,$i,'typeofdata');
                $column[$i] = $tablename .':'.$columnname.':'.$fieldname.':'.$module.'_'.$typeofdata.':fieldlabel';
                if($module == 'ServiceCharge' && $columnname == 'servicecasher')
                    $sortorder[$i] = 'asc';
                else
                    $sortorder[$i] = 'desc';

            }
            //$sort .= ','.$tablename.'.'.$focus->table_index.' '.' desc';
            $columnstr = '';$sortorderstr = '';
            if(!empty($column)) $columnstr = implode(',',$column);
            if(!empty($sortorder)) $sortorderstr = implode(',',$sortorder);
            return $columnstr . '|' .$sortorderstr;
        }
    }
    public function getModuleSortOrder()
    {
        global $adb,$current_user;
        $module=$this->module;
        require(globalStatic::$root_directory.'user_privileges/user_language_' . $current_user->id . '.php');
        $tableid = getTabid($module);
        $focus = CRMEntity::getInstance($module);
        $tablename = $focus->table_name;
        // wym XUQIU1001870 查询分类：排序字段增加允许设置单据编号、文本(1/2)、下拉框、数字、货币、负责人类型的字段(多个排序字段)
        // wym BUG20240514-11 排序方式里没有单选用户字段类型的排序方式，应该也添加
        $query = 'select tablename,columnname,fieldname,typeofdata,ld_tranlabel.fieldlabel from ld_field 
        inner join ld_tranlabel on ld_field.fieldid=ld_tranlabel.relateid 
        where languagetype = ? and trantable = ? and ld_tranlabel.tabid = ? 
        and presence in (0,2) and (uitype in(4, 1, 2, 15, 7, 53, 153, 71,5,70,86) or columnname in (\'servicecasher\',\'smownerid\')) 
         and ld_field.savedatabase="yes" order by block asc,sequence asc;';
        $result = $adb->pquery($query,array($languageType,'ld_field',$tableid));
        $numrows = $adb->num_rows($result);
        for($i = 0; $i<$numrows;$i++)
        {
            $tablename = $adb->query_result($result,$i,'tablename');
            //focus中没有该表时，无法连表
            if(array_key_exists($tablename,$focus->tab_name_index)){
                $columnname = $adb->query_result($result,$i,'columnname');
                $fieldname = $adb->query_result($result,$i,'fieldname');
                $typeofdata = $adb->query_result($result,$i,'typeofdata');
                $fieldlabel = $adb->query_result($result,$i,'fieldlabel');
                $sortArr[$i]['columnname'] =  $tablename .':'.$columnname.':'.$fieldname.':'.$module.'_'.$typeofdata.':fieldlabel';
                $sortArr[$i]['fieldlabel'] = $fieldlabel;
            }
        }
        return $sortArr;
    }
    public function getSortOrderArr($cvid)
    {
        $sortmappingfield_arr= $this->getSortMappField();//获取排序字段的映射

        global $adb;
        $query = 'select columnname,sorttype from ld_cvcolumnlistsort where cvid = ?';
        $result = $adb->pquery($query,array($cvid));
        $num_rows = $adb->num_rows($result);
        $focus=CRMEntity::getInstance($this->module);
        $orderby = array();

        if($num_rows >= 1)
        {
            for($i = 0; $i<$num_rows;$i++)
            {
                $columnname = $adb->query_result($result,$i,'columnname');

                $sortorder = $adb->query_result($result,$i,'sorttype');
                $columninfo = explode(':',$columnname);
                $typeofdata = explode('_',$columninfo[3]);
                $type = explode('~',$typeofdata[1]);

                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columninfo[1]);
                if($fieldinfo)
                {

                    $sortcolumnname=$fieldinfo->getColumnname();
                    $mapping_tablename=$fieldinfo->getTableName();

                    for($j=0;$j<sizeof($sortmappingfield_arr);$j++)
                    {
                        if($sortmappingfield_arr[$j]['origin_columnname']==$fieldinfo->getColumnname())
                        {
                            $mapping_tablename=$sortmappingfield_arr[$j]['mapping_tablename'];
                            $sortcolumnname=$sortmappingfield_arr[$j]['mapping_columnname'];

                        }
                    }
                    //XUQIU1001909 查询分类排序方式为负责人时,排序字段为负责人姓名而不是负责人id
                    if($fieldinfo->getColumnname()==$focus->getSmownerColumName()){
                        //wym XUQIU1002097 数据分类负责人排序代码优化：用户表增加一个姓名拼音的字段
                        $orderby_name='ld_users.pinyin_name';
                        //  $this->customviewobj->orderby_tables['ld_users']=' (select @i:=@i+1 as userpingyin_seq,id,last_name,wx_userid
                        //                                   , user_name   from ld_users ,(select @i:=0) as tmpsortuser order by pinyin_name asc) as ld_users ';


                        $this->customviewobj->orderby_tables['ld_users']='ld_users';

                        $orderby[$i] = array('orderby'=>$orderby_name ,'orderbytype'=>' ' . $sortorder) ;
                    } elseif($type[0] == 'DT' || $type[0] == 'D' || $type[0] == 'T'||$type[0]=='V'||$type[0]=='N'||$type[0]=='NN') {
                        $this->customviewobj->orderby_tables[$mapping_tablename]=$mapping_tablename;

                        $orderby[$i] = array('orderby'=>$mapping_tablename . '.' .$sortcolumnname,'orderbytype'=>' ' . $sortorder) ;
                    } else {
                        $this->customviewobj->orderby_tables['ld_users']='ld_users';
                        $orderby[$i] = array('orderby'=>'ld_users.user_name' ,'orderbytype'=>' ' . $sortorder) ;
                    }
                }
                else{
                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",'modifiedtime');
                    $sortorder='desc';

                    if(!$fieldinfo)
                    {
                        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",'createdtime');
                    }

                    if(!$fieldinfo)
                    {

                        $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$focus->getSmownerColumName());
                        //$this->orderby_tables['ld_users']='ld_users';
                        // $orderby[0] = array('orderby'=>'ld_users.user_name' ,'orderbytype'=>' ' . $sortorder) ; ;
                    }

                    if($fieldinfo)
                    {
                        $this->customviewobj->orderby_tables[$fieldinfo->getTableName()]=$fieldinfo->getTableName();
                        $orderby[0] = array('orderby'=>$fieldinfo->getTableName() . '.' .$fieldinfo->getColumnName(),'orderbytype'=>' ' . $sortorder) ;
                    }
                }
            }
        }
        else
        {

            //默认
            $columnnamesort = explode('|',$this->customviewobj->setCustonviewSortOrder($this->module));
            if($columnnamesort[0] != '')
            {
                $sortinfo = explode(',',$columnnamesort[0]);
                $orderinfo = explode(',',$columnnamesort[1]);
                for($i = 0; $i<count($sortinfo); $i++)
                {
                    $columninfo = explode(':',$sortinfo[$i]);
                    $typeofdata = explode('_',$columninfo[3]);
                    $type = explode('~',$typeofdata[1]);
                    if($type[0] == 'DT' || $type[0] == 'D' || $type[0] == 'T'||$type[0]=='N'||$type[0]=='NN')
                        $orderby[$i] = array('orderby'=>$columninfo[0] . '.' .$columninfo[1],'orderbytype'=>' ' . $orderinfo[$i]) ;
                    else{
                        $this->customviewobj->orderby_tables['ld_users']='ld_users';
                        $orderby[$i] = array('orderby'=>'ld_users.user_name' ,'orderbytype'=>' ' . $orderinfo[$i]) ;
                    }

                }
            }
        }

        if(count($orderby) >= 1)
        {
            //$orderby = array_unique($orderby);
            $orderbys['sortcolumns']=$orderby;
            $orderbys['tables']=$this->customviewobj->orderby_tables;
            return $orderbys;
        }
        else
        {
            return '';
        }
    }
    public function getCustomViewOrderBy($cvid)
    {
        static $moduleSortInfo;
        //zxm @date:2024/10/24 @reason: 首页组件:最新合同订单  获取排序获取到了,排序所在的表没获取到
        static $moduleSortTableInfo;

        if(isset($moduleSortInfo[$this->module]) && $moduleSortInfo[$this->module][$cvid])
        {
            $this->orderby_tables= $moduleSortTableInfo[$this->module][$cvid];
            $this->customviewobj->orderby_tables= $moduleSortTableInfo[$this->module][$cvid];
            return $moduleSortInfo[$this->module][$cvid];
        }
        global $adb,$currentModule;
        global $related_left_type,$related_left_listmodule;
        if(isset($related_left_type) && $related_left_type > 0){
            $currentModule = $related_left_listmodule;
        }
        if(!$cvid) return '';

        $sortinfos=$this->getSortOrderArr($cvid);
        $this->orderby_tables=$sortinfos['tables'];
        $sortstr = '';
        foreach($sortinfos['sortcolumns'] as $index =>$sortcontent)
        {
            $sortstr.=' '.$sortcontent['orderby'].$sortcontent['orderbytype'].',';
        }
        $moduleSortTableInfo[$this->module][$cvid] = $sortinfos['tables'];
        $moduleSortInfo[$this->module][$cvid]=$sortstr;
        return $sortstr;
    }
}

?>