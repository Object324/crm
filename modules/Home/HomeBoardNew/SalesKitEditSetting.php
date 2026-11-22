<?php

class SalesKitEditSetting
{
    public $boardid;
    public $stuffid;
    public $boardStuffId;
    public $except = UNABLE2STATISTICSMODULE;
    public static $DragonTigerListObjArr;
    public $adb;
    public $language;
    public $StuffLabelList;
    public $current_user;
    public $havesaleskit_stufflabelarr = [];
    public $SelectedSQLParams;
    public $selected_saleskit_list;
    public $AllSQLParams;
    public $SetValueSQL;
    public $SetValueSQLParams;
    public $saleskitlist;
    public $newalltabs = [];

    public static function getInstance($boardid) {
        if(isset(self::$DragonTigerListObjArr[$boardid])){
            return self::$DragonTigerListObjArr[$boardid];
        }
        self::$DragonTigerListObjArr[$boardid]=new SalesKitEditSetting($boardid);
        return self::$DragonTigerListObjArr[$boardid];
    }

    public function __construct($boardid){
        global $adb, $languageType,$current_user;
        $this->stuffid = 35;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->boardid = $boardid;
        $this->getStuffLabelList();
    }

    public function setStuffId($stuffid){
        $this->stuffid = $stuffid;
    }
    public function setBoardStuffId($boardStuffId = ''){
        if(empty($boardStuffId)) {
            crm_load_class_file('home','include');
            $boardStuffId = (new Homestuff())->getBoardStuffId($this->boardid,$this->stuffid);
        }
        $this->boardStuffId = $boardStuffId;
    }

    public function getModuleArr()
    {

        $query="SELECT
        	ld_tab.tabid,
        	ld_tranlabel.fieldlabel AS newtabname,
        	languagetype,
        	ld_tab.name
        FROM
        	ld_tab
        INNER JOIN ld_tranlabel ON ld_tab.tabid = ld_tranlabel.relateid
        WHERE
            languagetype = '".$this->language."'
        AND trantable = 'ld_tab'
        AND ld_tab.presence = 0
        AND ld_tab.isentitytype= 1
        and ld_tab.name not in (".$this->except.")
        GROUP BY
        	ld_tab.tabid,
        	languagetype,
        	tabid
        ORDER BY
        	ld_tab.tabsequence ASC";

        $result = $this->adb->query($query);
        $num_rows=$this->adb->num_rows($result);
        $alltabs = [];
        for($i=0;$i<$num_rows;$i++){
            $name = $this->adb->query_result($result,$i,'name');
            if(isPermitted($name,'index') == 'yes'&&vtlib_isModuleActive($name)){
                $tabid = $this->adb->query_result($result,$i,'tabid');
                $newtabname=$this->adb->query_result($result,$i,'newtabname');
                $alltabs[$tabid]['tabid'] = $tabid;
                $alltabs[$tabid]['name'] = $newtabname;
                $alltabs[$tabid]['modulename'] = $name;
                $this->newalltabs[$name] = array('tabid'=> $tabid,'name'=>$newtabname,'modulename'=>$name);
            }
        }
        return $alltabs;
    }

    public function getSalesKitModuleFields($computemodule){
        if($computemodule=='ServiceCharge')$computemodule='Accounts';
        $countFieldOption = '';
        $sumFieldOption = '';
        $smowneridFieldOption = '';
        $timeFieldOption = '';

        $returnfield_arr = array();
        $focus = CRMEntity::getInstance($computemodule);
        $fieldobj = $focus->fieldobj;
        //主表字段
        $all_field = $fieldobj->getModuleFields();
        $returnfield_arr['main'] = array();
        $returnfield_arr['countField'] = array();
        $returnfield_arr['sumField'] = array();
        $returnfield_arr['smowneridField'] = array();//负责人字段改成第一个显示-- todo--
        $returnfield_arr['timeField'] = array();
        $mainlabel = getFixedLabel('DOCUMENTHEADERFIELD');
        $countFieldOption .= '<optgroup label="'.$mainlabel.'" class="select" style="border:none">';
        $sumFieldOption .= '<optgroup label="'.$mainlabel.'" class="select" style="border:none">';
        $smowneridFieldOption .= '<optgroup label="'.$mainlabel.'" class="select" style="border:none">';
        $timeFieldOption .= '<optgroup label="'.$mainlabel.'" class="select" style="border:none">';

        foreach ($all_field as $tmp_fieldinfoobj){
            if($tmp_fieldinfoobj->getSaveDataBase() == 'no'){
                continue;
            }
            $tmp_fieldinfo_arr = array();
            $columname = $tmp_fieldinfoobj->getColumnName();
            $fieldname = $tmp_fieldinfoobj->getFieldName();
            $tablename = $tmp_fieldinfoobj->getTableName();
            $typeofdata = $tmp_fieldinfoobj->getTypeOfData();
            $fieldlabel = $tmp_fieldinfoobj->getfieldLabel();
            $uitype = $tmp_fieldinfoobj->getUIType();
            $bigtype = $tmp_fieldinfoobj->getBigType();
            $ishreflink=$tmp_fieldinfoobj->get_ShowHyperlinks();
            $typeofdata_arr = explode('~',$typeofdata);

            $combine_column = $tablename.":".$columname.":".$fieldname.":".$computemodule."_fieldlabel:".$typeofdata_arr[0];
            $tmp_fieldinfo_arr['column'] = $combine_column;
            $ishreflink='no';
            if($fieldname==$focus->list_link_field)
                $ishreflink='yes';
            $tmp_fieldinfo_arr['ishreflink']=$ishreflink;

            $tmp_fieldinfo_arr['compute_column'] = $tablename.'.'.$columname;
            $tmp_fieldinfo_arr['label'] = $fieldlabel;
            //对象查询字段
            $tmp_fieldinfo_arr['referencefield'] = 'no';

            if ($uitype == 301){//标签
                continue;
            }
            if ($uitype == 132){//当前审批人
                continue;
            }
            if(in_array($bigtype,array('users','selectoneuser'))){
                $tmp_fieldinfo_arr['referencefield'] = 'yes';
                $smowneridFieldOption .=  '<option value="'.$combine_column.'">'.$fieldlabel.'</option>';//负责人字段
                $returnfield_arr['smowneridField'][] = $tmp_fieldinfo_arr;
            }else if($bigtype == 'reference'){
                $referencemodule=$computemodule[$uitype];
                if($referencemodule == $computemodule){
                    $tmp_fieldinfo_arr['referencefield'] = 'yes';
                }
            }
            //日期字段
            if(in_array($bigtype,array('date','datetime'))){
                $tmp_fieldinfo_arr['datefield'] = 'yes';
                $timeFieldOption .= '<option value="'.$combine_column.'">'.$fieldlabel.'</option>';//时间字段
                $returnfield_arr['timeField'][] = $tmp_fieldinfo_arr;
            }else{
                $tmp_fieldinfo_arr['datefield'] = 'no';
            }
            //统计字段
            if($tmp_fieldinfoobj->isFldNumOrMoney()){
                $tmp_fieldinfo_arr['counttotal'] = 'yes';
                $sumFieldOption .= '<option value="'.$tablename.".".$columname.'">'.$fieldlabel.'</option>';//求和的
                $returnfield_arr['sumField'][] = $tmp_fieldinfo_arr;
            }else{
                $tmp_fieldinfo_arr['counttotal'] = 'no';
            }
            $countFieldOption .= '<option value="'.$tablename.".".$columname.'">'.$fieldlabel.'</option>';//计数的
            $returnfield_arr['countField'][] = $tmp_fieldinfo_arr;
            $returnfield_arr['main'][] = $tmp_fieldinfo_arr;
        }
        $countFieldOption .= '</optgroup>';
        $sumFieldOption .= '</optgroup>';
        $smowneridFieldOption .= '</optgroup>';
        $timeFieldOption .= '</optgroup>';
        //分录字段
        $returnfield_arr['detail'] = array();
        if(get_file_address($computemodule,$computemodule."DetailFieldsHtml")||get_file_address($computemodule,"ProductDetails")){
            $all_detailfield = $focus->detailfieldobj->getModuleFields();
            $detaillabel = getFixedLabel('Entryfield');
            $countFieldOption .= '<optgroup label="'.$detaillabel.'" class="select" style="border:none">';
            $sumFieldOption .= '<optgroup label="'.$detaillabel.'" class="select" style="border:none">';
            $smowneridFieldOption .= '<optgroup label="'.$detaillabel.'" class="select" style="border:none">';
            $timeFieldOption .= '<optgroup label="'.$detaillabel.'" class="select" style="border:none">';

            foreach ($all_detailfield as $tmp_fieldinfoobj){
                if($tmp_fieldinfoobj->getSaveDataBase() == 'no'){
                    continue;
                }
                $tablename = $tmp_fieldinfoobj->getTableName();
                $columname = $tmp_fieldinfoobj->getColumnName();
                if($columname != 'productname' && $tablename != $focus->Detail_table && $tablename != $focus->Detail_table_scf){
                    continue;
                }
                $tmp_fieldinfo_arr = array();

                $fieldname = $tmp_fieldinfoobj->getFieldName();
                $typeofdata = $tmp_fieldinfoobj->getTypeOfData();
                $fieldlabel = $tmp_fieldinfoobj->getfieldLabel();
                $bigtype = $tmp_fieldinfoobj->getBigType();
                $typeofdata_arr = explode('~',$typeofdata);

                $tmp_module = $computemodule;
                if(get_file_address($computemodule,"ProductDetails")){
                    $tmp_module = 'Products';
                }
                $combine_column = $tablename.":".$columname.":".$fieldname.":".$tmp_module."_fieldlabel:".$typeofdata_arr[0];
                $tmp_fieldinfo_arr['column'] = $combine_column;
                $tmp_fieldinfo_arr['compute_column'] = $tablename.'.'.$columname;
                $tmp_fieldinfo_arr['label'] = $fieldlabel;
                //对象查询字段
                $tmp_fieldinfo_arr['referencefield'] = 'no';
                if($computemodule == 'Products'){
                    if($columname == 'productname'){
                        $tmp_fieldinfo_arr['referencefield'] = 'yes';
                        $smowneridFieldOption .=  '<option value="'.$combine_column.'">'.$fieldlabel.'</option>';//负责人字段
                        $returnfield_arr['smowneridField'][] = $tmp_fieldinfo_arr;
                    }
                }else{
                    if($bigtype == 'reference'){
                        $referencemodule=$tmp_fieldinfoobj->getReferenceModule();
                        if($referencemodule == $computemodule){
                            $tmp_fieldinfo_arr['referencefield'] = 'yes';
                        }
                        //zxm 20240626 分录字段 关联选择单据 是选用户的 需要当作数据范围映射字段
                        if($referencemodule=='Users'){
                            $tmp_fieldinfo_arr['referencefield'] = 'yes';
                            $smowneridFieldOption .=  '<option value="'.$combine_column.'">'.$fieldlabel.'</option>';//负责人字段
                        }
                    }
                }
                //zxm 20240626 分录字段 关联选择单据 是选用户的 需要当作数据范围映射字段
                if(in_array($bigtype,array('users','selectoneuser'))){
                    $tmp_fieldinfo_arr['referencefield'] = 'yes';
                    $smowneridFieldOption .=  '<option value="'.$combine_column.'">'.$fieldlabel.'</option>';//负责人字段
                    $returnfield_arr['smowneridField'][] = $tmp_fieldinfo_arr;
                }
                //日期字段
                if(in_array($typeofdata_arr[0],array('D','DT'))){
                    $tmp_fieldinfo_arr['datefield'] = 'yes';
                    $timeFieldOption .= '<option value="'.$combine_column.'">'.$fieldlabel.'</option>';//时间字段
                    $returnfield_arr['timeField'][] = $tmp_fieldinfo_arr;
                }else{
                    $tmp_fieldinfo_arr['datefield'] = 'no';
                }
                //统计字段
                if($tmp_fieldinfoobj->isFldNumOrMoney()){
                    $tmp_fieldinfo_arr['counttotal'] = 'yes';
                    $sumFieldOption .= '<option value="'.$tablename.".".$columname.'">'.$fieldlabel.'</option>';//求和的
                    $returnfield_arr['sumField'][] = $tmp_fieldinfo_arr;
                }else{
                    $tmp_fieldinfo_arr['counttotal'] = 'no';
                }
                $countFieldOption .= '<option value="'.$tablename.".".$columname.'">'.$fieldlabel.'</option>';//计数的
                $returnfield_arr['countField'][] = $tmp_fieldinfo_arr;
                $returnfield_arr['detail'][] = $tmp_fieldinfo_arr;
            }
            $countFieldOption .= '</optgroup>';
            $sumFieldOption .= '</optgroup>';
            $smowneridFieldOption .= '</optgroup>';
            $timeFieldOption .= '</optgroup>';
        }
        $returnfield_arr['countFieldOption'] =$countFieldOption;
        $returnfield_arr['ucountFieldOption'] =$countFieldOption;
        $returnfield_arr['sumFieldOption'] =$sumFieldOption;
        $returnfield_arr['maxFieldOption'] =$sumFieldOption;
        $returnfield_arr['minFieldOption'] =$sumFieldOption;
        $returnfield_arr['avgFieldOption'] =$sumFieldOption;
        $returnfield_arr['smowneridFieldOption'] =$smowneridFieldOption;
        $returnfield_arr['timeFieldOption'] =$timeFieldOption;
        return $returnfield_arr;
    }

    public function getSelectedStuffDetailSQL(){
        $sql = "select ld_homestuffdetail.*,tmp.sequence from ld_homestuffdetail 
        inner join ( 
            select ld_homestuffdetail.stufflabel,ld_homestuffsaleskit2board.sequence from ld_homestuffdetail
                    inner join ld_homestuffsaleskit2board on ld_homestuffsaleskit2board.homestuffdetailid=ld_homestuffdetail.id
            where ld_homestuffdetail.stuffid=? and ld_homestuffsaleskit2board.boardid=? group by ld_homestuffdetail.stufflabel
            ORDER BY ld_homestuffsaleskit2board.sequence asc
        )as tmp on tmp.stufflabel=ld_homestuffdetail.stufflabel order by tmp.sequence;";
        $this->SelectedSQLParams = array($this->stuffid,$this->boardid);
        return $sql;
    }

    public function getSelectedSalesKitList($stuffid){
        $adb = $this->adb;
        $languageType = $this->language;
        $selected_saleskit_list=[];
        $this->havesaleskit_stufflabelarr=[];
        //获取当前看板已经有的销售简报 homestuffdetailid的集合
        if(empty($this->stuffid))
            $this->setStuffId($stuffid);
        $sql_saleskit_default = $this->getSelectedStuffDetailSQL();
        $result=$adb->pquery($sql_saleskit_default,$this->SelectedSQLParams);
        $nums_saleskitset_default=$adb->num_rows($result);
        if($nums_saleskitset_default>0) {
            $selected_saleskit_list = $this->getStuffDetailList($result,'selected');
        }
        $this->selected_saleskit_list =$selected_saleskit_list;
    }

    public function getStuffLabelList(){
        $this->StuffLabelList = [
            'default' => [
                'label' => getFixedLabel('DefaultSaleskit'),
                'list' => [],
            ],
            'custom' => [
                'label' => getFixedLabel('CustomSaleskit'),
                'list' => [],
            ],
        ];
    }

    public function getStuffDetailList($result,$type){
        $adb = $this->adb;
        $languageType = $this->language;
        $StuffDetailList = [];
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for ($i = 0; $i < $num_rows; $i++) {
                $homestuffdetailid = $adb->query_result($result, $i,'id');
                $stufflabel = $adb->query_result($result, $i, 'stufflabel');
                $stufflabel_zh = $adb->query_result($result, $i, 'stufflabel_zh');
                $stufflabel_en = $adb->query_result($result, $i, 'stufflabel_en');
                $compute_type = $adb->query_result($result, $i, 'compute_type');
                $compute_columns = $adb->query_result($result, $i, 'compute_columns');
                $compute_module = $adb->query_result($result, $i, 'compute_module');
                $icon=$adb->query_result($result,$i,'icon');
                $css=$adb->query_result($result,$i,'cssname');
                $is_default=$adb->query_result($result,$i,'is_default');
                $viewrange = $adb->query_result($result, $i, 'viewrange');
                $daterange = $adb->query_result($result, $i, 'daterange');
                $advance_demand=$adb->query_result($result,$i,'advance_demand');
                $advance_demand_groups=$adb->query_result($result,$i,'advance_demand_groups');
                $selected = $adb->query_result($result,$i,'selected');
                $sequence = $adb->query_result($result,$i,'sequence');
                $topnumber = $adb->query_result($result,$i,'topnumber');
                $groupby = $adb->query_result($result,$i,'groupby');
                $used = 'yes';
                //chj 2021/1/21 42915: 客户001销售增强版>首页>销售简报：应该将“服务合同收款额”去掉，因为销售增强版没有服务合同模块。（服务增强版需要“合同订单收款额”去掉）
                /*if ($stufflabel == 'NewServiceContractsReceipts' && !vtlib_isModuleActive('ServiceContracts')&& !vtlib_isModuleActive('CashBill')) {
                    continue;
                }
                else if ($stufflabel == 'NewSalesOrderReceipts' && !vtlib_isModuleActive('SalesOrder')&& !vtlib_isModuleActive('CashBill')) {
                    continue;
                }
                //zxm 20240313 签约应收余额 收款单没激活 不应该显示这个简报组件
                if ($stufflabel == 'SignContractBalanceReceivable' && !vtlib_isModuleActive('CashBill')) {
                    continue;
                }
                //duan 2022-0302 客户和销售机会模块都开启后，才会显示‘线索升级到客户和销售机会数’
                else if ($stufflabel == "LeadUgradeToPotentials" && (!vtlib_isModuleActive('Accounts') || !vtlib_isModuleActive('Potentials'))) {
                    continue;
                }else */
                if(!vtlib_isModuleActive($compute_module)){
                    //zxm 20230823 模块未激活 则这个简报不显示
                    continue;
                }
                //将中文字段名 转换成fieldlabel
                if(!empty($advance_demand)) {
                    $advance_demand_arr = json_decode($advance_demand, true);
                    foreach ($advance_demand_arr as $k=>&$tmp_advance_demand_line) {
                        if (!empty($tmp_advance_demand_line)) {
                            $tmpcolumnname = $tmp_advance_demand_line['columnname'];
                            $tmpcolumnname_arr = explode(':', $tmpcolumnname);
                            $tmpmodulefieldlabel = $tmpcolumnname_arr[3];
                            $tmpmodulefieldlabel_arr = explode('_',$tmpmodulefieldlabel);
                            $tmpmodulefieldlabel_arr[1] = 'fieldlabel';
                            $tmpcolumnname_arr[3] = implode('_',$tmpmodulefieldlabel_arr);
                            $tmp_advance_demand_line['columnname'] = implode(':', $tmpcolumnname_arr);
                            //edit: xll 2023/08/17 BUG0071167 销售简报“线索升级到客户”、“线索升级到客户和销售机会”数据丢失
                            if($tmp_advance_demand_line['value'] == 'from_leads' && ($tmpcolumnname_arr[1] == 'upgrade_source'||$tmpcolumnname_arr[1] == 'kis_no')){
                                if($stufflabel == 'LeadUgradeToPotentials'){
                                    $tmpvalue = getFixedLabel('UPGRADETOPOTENTIALS');
                                } else {
                                    $tmpvalue = getFixedLabel('UPGRADETOACCOUNT');
                                }
                                $tmp_advance_demand_line['value'] = $tmpvalue;
                            }

                        }
                    }
                    $advance_demand = json_encode($advance_demand_arr);
                }
                if($type == 'selected')
                    $this->havesaleskit_stufflabelarr[] = $stufflabel;
                else{
                    $used = in_array($stufflabel,$this->havesaleskit_stufflabelarr)?'yes':'no';
                }
                $moduleactive = 'no';
                if (vtlib_isModuleActive($compute_module) || $compute_module == 'Singin') {
                    $moduleactive = 'yes';
                }
                if($stufflabel_zh=='')
                {
                    $stufflabel_zh=getFixedLabel($stufflabel);

                }
                if($stufflabel_en=='')
                {
                    $stufflabel_en=getFixedLabel($stufflabel);
                }
                if ($moduleactive == 'yes') {

                    $tmpinfo = array(
                        'homestuffdetailid' => $homestuffdetailid,
                        'stufflabel' => $stufflabel,
                        'zh' => $stufflabel_zh,
                        'en' => $stufflabel_en,
                        'sequence' => $sequence,
                        'computeinfo' => array(),
                        'icon' => $icon,
                        'css' => $css,
                        'is_default' => $is_default,
                        'used' => $used,//简报是否被选中
                        'selected' => $selected,//龙虎榜是否被选中
                        'topnumber' => $topnumber//前几名
                    );
                    $tmpinfo['label'] = $tmpinfo[$languageType];
                    $tmpcomputeinfo = array(
                        'homestuffdetailid' => $homestuffdetailid,
                        'computemodule' => $compute_module,
                        'computetype' => $compute_type,
                        'computecolumns' => $compute_columns,
                        'groupby' => $groupby,//龙虎榜 统计维度
                        'viewrange' => $viewrange,
                        'viewrange_isrelated' => empty($viewrange)?false:true,//是否限制数据范围
                        'daterange' => $daterange,
                        'daterange_isrelated' => empty($daterange)?false:true,//是否限制时间范围
                        'advance_demand' => $advance_demand,
                        'advance_demand_groups' => $advance_demand_groups
                    );
                    if(!isset($StuffDetailList[$stufflabel])) {
                        $tmpinfo['computeinfo'][] = $tmpcomputeinfo;
                        $StuffDetailList[$stufflabel] = $tmpinfo;
                    }else{
                        $StuffDetailList[$stufflabel]['computeinfo'][]= $tmpcomputeinfo;
                    }
                    //edit: xll 2023/12/04 XUQIU1002171 简报划分为两个区块
                    $this->PushToStuffLabelList($is_default,$StuffDetailList[$stufflabel]);
                    if($this->stuffid == 100){
                        $SetValue = $this->getStuffDetailSetValue($StuffDetailList[$stufflabel]);
                        $StuffDetailList[$stufflabel]['SetValue'] = $SetValue;
                    }
                }
            }
        }
        return $StuffDetailList;
    }

    public function PushToStuffLabelList($is_default,$StuffDetailInfo){
        $type = ($is_default === 'yes') ? 'default' : 'custom';
        $this->StuffLabelList[$type]['list'][$StuffDetailInfo['stufflabel']] = $StuffDetailInfo;
    }

    public function getNewStuffInfoArr(){
        $tmpinfo = array(
            'stufflabel' => '',
            'zh' => '',
            'en' => '',
            'sequence' => 0,
            'label' => getFixedLabel('NEWCUSTOMSALESKIT'),
            'computeinfo' => array(),
            'icon' => '',
            'css' => '',
            'is_default' => 'no',
            'used' => 'yes'//是否被选中
        );
        $tmpcomputeinfo = array(
            'homestuffdetailid' => 0,
            'computemodule' => 'Accounts',
            'computetype' => 'count',
            'computecolumns' => 'ld_account.accountid',
            'viewrange' => '',
            'daterange' => '',
            'advance_demand' => '[]',
            'advance_demand_groups' => '[]',
        );
        $tmpinfo['computeinfo'][] = $tmpcomputeinfo;
        return $tmpinfo;
    }

    public function getAllStuffDetailSQL(){
        $sql = "select 
            ld_homestuffdetail.id,stufflabel_zh,stufflabel_en,stufflabel,pageurl,compute_type,compute_columns,
            viewrange,daterange,icon,cssname,is_default,compute_module,advance_demand,advance_demand_groups,groupby
            from ld_homestuffdetail 
            where stuffid=? 
            order by id asc;";
        $this->AllSQLParams = array($this->stuffid);
        return $sql;
    }

    //获取所有的简报信息和被选中的简报信息
    public function getAllSalesKitList($stuffid){
        $adb = $this->adb;
        $languageType = $this->language;
        $havesaleskit_stufflabelarr = $this->havesaleskit_stufflabelarr;

        $saleskitlist = [];
        //获取销售简报列表（相关模块已开启）
        if(empty($this->stuffid))
            $this->setStuffId($stuffid);
        $sql=$this->getAllStuffDetailSQL();
        $result = $this->adb->pquery($sql, $this->AllSQLParams);
        $rows = $this->adb->num_rows($result);
        if ($rows > 0) {
            $saleskitlist = $this->getStuffDetailList($result,'all');
        }

        $this->saleskitlist =$saleskitlist ;
    }

    //获取简报的布局设置信息 比如每一行多高 一行多少个简报 等
    public function getSaleskitLayout($count)
    {
        $adb = $this->adb;
        $sql_saleskitset_layout = "select ld_homeboard.saleskit_colcount,ld_homeboard.saleskit_height,ld_homeboard.saleskit_isshowpredata,boardtype 
    from ld_homeboard where boardid=? and deleted=0";
        $result_saleskitset_layout = $adb->pquery($sql_saleskitset_layout, array($this->boardid));
        $nums_saleskitset_layout = $adb->num_rows($result_saleskitset_layout);
        //工程行业收支报告  需要默认值
        $saleskit_layout['boardtype'] = $_REQUEST['boardtype'];
        $saleskit_layout['count'] = 1;//简报个数
        $saleskit_layout['colcount'] = 4;//每行简报个数
        $saleskit_layout['height'] = '120';//每行简报高度
        $saleskit_layout['rowcount'] = 1;//有多少行简报
        $saleskit_layout['blockwidth'] = 0;//每个简报的宽度
        $saleskit_layout['isshowprevious'] = 'yes';//是否显示上期对比数据
        $saleskit_layout['ShowPercent'] = 'yes';//是否显示百分比

        if($_REQUEST['boardtype']=='MobileReport'||$_REQUEST['boardtype'] =='prmMobileHome' || empty($this->boardid) || $this->boardid < 0){
            //zxm 20231117 移动端看板 简报编辑的时候没有布局信息导致界面错误  给默认值
            $saleskit_layout['boardtype'] = $_REQUEST['boardtype'];
            $saleskit_layout['count'] = 1;//简报个数
            $saleskit_layout['colcount'] = 2;//每行简报个数
            $saleskit_layout['height'] = '120';//每行简报高度
            $saleskit_layout['rowcount'] = 1;//有多少行简报
        }
        if ($nums_saleskitset_layout > 0) {
            $colcount = $adb->query_result($result_saleskitset_layout, 0, 'saleskit_colcount');
            $height = $adb->query_result($result_saleskitset_layout, 0, 'saleskit_height');
            $isshowprevious = $adb->query_result($result_saleskitset_layout, 0, 'saleskit_isshowpredata');
            $boardtype = $adb->query_result($result_saleskitset_layout, 0, 'boardtype');
            if (empty($colcount) || $colcount == '') {//初始为0代表第一次设置销售简报
                $colcount = 4;
            }
            if($boardtype=='MobileReport'||$boardtype=='prmMobileHome')$colcount=2;//移动端工作台 简报固定每行一个

            if (empty($height) || $height == '') {
                $height = 120;
            } elseif ($height < 120) {
                $height = 120;
            }
            $blockwidth = (100 / $colcount);


            $saleskit_layout['boardtype'] = $boardtype;
            $saleskit_layout['count'] = $count;//简报个数
            $saleskit_layout['colcount'] = $colcount;//每行简报个数
            $saleskit_layout['height'] = $height;//每行简报高度
            $saleskit_layout['rowcount'] = ceil($count / $colcount);//有多少行简报
            $saleskit_layout['blockwidth'] = $blockwidth;//每个简报的宽度
            $saleskit_layout['isshowprevious'] = $isshowprevious;//是否显示上期对比数据
        }
        if(empty($this->boardStuffId)){
            $this->setBoardStuffId('');
        }
        $typeArr = ['EqualDuration','ShowPercent'];
        foreach ($typeArr as $type) {
            $sql = "SELECT setvalue FROM ld_homeboard_plate_setting WHERE boardid = ? AND stuffid = ? AND boardstuffid = ? AND type = 'SalesKit_$type'";
            $result = $adb->pquery($sql, [$this->boardid,$this->stuffid,$this->boardStuffId]);
            if($adb->num_rows($result) > 0) {
                $setvalue = $adb->query_result($result, 0, 'setvalue');
            }
            else {
                $setvalue = 'no';
            }
            $saleskit_layout[$type] = $setvalue;
        }

        if(empty($this->boardid) || $this->boardid < 0){
            //默认看板  或者移动端默认看板 报表页签的简报
            $saleskit_layout['isshowprevious'] = 'yes';//是否显示上期对比数据
            $saleskit_layout['ShowPercent'] = 'yes';//是否显示百分比
        }
        $saleskit_layout['boardid'] = $this->boardid;

        return $saleskit_layout;
    }
    //获取js翻译
    public function getJspopLabel(){
        return array(
            'SALESKITZHNAME'=>getFixedLabel('SALESKITZHNAME'),
            'SALESKITENNAME'=>getFixedLabel('SALESKITENNAME'),
            'SelectIcon'=>getFixedLabel('SelectIcon'),
            'SETTINGS'=>getFixedLabel('SETTINGS'),
            'StatisticsModule'=>getFixedLabel('StatisticsModule'),
            'COMPUTINGMETHOD'=>getFixedLabel('COMPUTINGMETHOD'),
            'STATISTICALFIELD'=>getFixedLabel('STATISTICALFIELD'),
            'FILTERSVIEWSCOPEMAPPINGFIELDS'=>getFixedLabel('FILTERSVIEWSCOPEMAPPINGFIELDS'),
            'FILTERTIMERANGEMAPPINGFIELD'=>getFixedLabel('FILTERTIMERANGEMAPPINGFIELD'),
            'SETSEARCHCONDITIONS'=>getFixedLabel('SETSEARCHCONDITIONS'),
            'Summation'=>getFixedLabel('Summation'),
            'COUNT'=>getFixedLabel('COUNT'),
            // 新增选项值唯一计数、平均值、最大值、最小值
            'UCOUNT'=>getFixedLabel('UCOUNT'),
            'AVGVALUE'=>getFixedLabel('AVGVALUE'),
            'MAXVALUE'=>getFixedLabel('MAXVALUE'),
            'MINVALUE'=>getFixedLabel('MINVALUE')
        );
    }

    //edit: xll 2023/08/17 对于预设的销售简报组件“线索升级到客户”和“线索升级到客户和销售机会”需要对其高级查找条件中的线索升级状态值做处理
    //获取线索升级状态的中英文翻译
    public static function getKis_no_FixedLabel($stufflabel,&$advance_demand){
        //将预设的线索升级状态的值改为翻译值
        if(!empty($advance_demand)) {
            $advance_demand_arr = Zend_Json::decode($advance_demand, true);
            foreach ($advance_demand_arr as $k=>&$tmp_advance_demand_line) {
                if (!empty($tmp_advance_demand_line)) {
                    $columnname = explode(':',$tmp_advance_demand_line['columnname'])[1];
                    if($tmp_advance_demand_line['value'] == 'from_leads' && ($columnname[1] == 'upgrade_source'||$columnname[1] == 'kis_no')){
                        if($stufflabel == 'LeadUgradeToPotentials'){
                            $tmpvalue = getFixedLabel('UPGRADETOPOTENTIALS');
                        } else {
                            $tmpvalue = getFixedLabel('UPGRADETOACCOUNT');
                        }
                        $tmp_advance_demand_line['value'] = $tmpvalue;
                    }
                }
            }
            $advance_demand = Zend_Json::encode($advance_demand_arr);
        }
        return $advance_demand;
    }


    public function getStuffDetailSetValueSQL($StuffDetaiInfo){
        $this->SetValueSQL = 'SELECT type,setvalue from ld_homestuffdetail_setting WHERE homestuffdetailid = ?';
        $this->SetValueSQLParams = [$StuffDetaiInfo['homestuffdetailid']];
        return $this->SetValueSQL;
    }

    public function getStuffDetailSetValue(&$StuffDetaiInfo){
        $sql = $this->getStuffDetailSetValueSQL($StuffDetaiInfo);
        $adb = $this->adb;
        $result = $adb->pquery($sql, $this->SetValueSQLParams);
        $num_rows = $adb->num_rows($result);
        $SetValue['showZero'] = false;
        $SetValue['can_penetrate'] = true;
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $type = $adb->query_result($result, $i, 'type');
                $setvalue = $adb->query_result($result, $i, 'setvalue');
                $SetValue[$type] = $setvalue;
            }
        }
        return $SetValue;
    }

}

?>