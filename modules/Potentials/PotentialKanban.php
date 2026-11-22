<?php
require_once(globalStatic::$root_directory."modules/lingdang/cls_KanBan.php");
class PotentialKanban extends cls_KanBan {
    public function __construct(){
        $this->module = 'Potentials';
    }

    public function getKanBanViewList($pagewidth,$pageheight){
        global $adb,$currentModule,$current_user;
        $defaultcurrency = getDefaultCurrecySymbol();//默认的币种符号
        //布局规则
        $focus = CRMEntity::getInstance($currentModule);
        //获取当前的的推进字段(自动化设置)--zxm改成读取缓存
        crm_load_class_file('cls_module_advance','modules/Settings');
        $cls_module_advance = new cls_module_advance($currentModule);
        $ModuleAdvanceinfo=$cls_module_advance->getModuleAdvance();//推进阶段设置信息

        //销售机会阶段字段
        crm_load_class_file("cls_PickList", 'modules/PickList');
        $objpinklist = new cls_PickList();
        $pick_fieldname=$ModuleAdvanceinfo['module_field'];
        $result_pick = $objpinklist->getPickListValues($pick_fieldname,'',array(),'kanban');
        $list_query = "SELECT ";
        $customView = new CustomView($currentModule);
        $showfieldvalueobj=new ShowFieldValue($focus->fieldobj,$focus->module_name,SHOW_POPUP);
    $queryGenerator =  QueryGenerator::getInstance($currentModule, $current_user,$customView);
    $meta = $queryGenerator->getMeta($queryGenerator->getModule());
    $modulefields = $meta->getModuleFields();

    $page_list_query = $queryGenerator->getQuery('','groupby');

    $currentField=$queryGenerator->getSQLColumn($pick_fieldname);
        $currentField_arr = explode('.',$currentField);//$list_query中表连接用字段名  当阶段推进字段是商机类型时 不这么处理有问题
    $SQLColumn=$this->getSelectColumnSQLbyMobileSettings();//获取移动端模块列表定制中启用的字段
    $SQLColumn=rtrim($SQLColumn,',');
    //zkt 20240716 BUG20240711-34 商机看板视图不显示
    if (strpos($SQLColumn, $currentField) === false) {//如果移动端模块列表定制中启用的字段不包括自动化设置中选择的跟踪字段,则添加上
        $SQLColumn.=','.$currentField;
    }

    $table_index = ','.$focus->table_name.'.'.$focus->table_index.' as crmid'; //单据id
        //zxm 20230801 币种符号显示不正确 没有换算.另外,每个类别的求和也不对
    $currency_id_field = ','.$focus->table_name.'.currency_id as currency_id'; //币种ID
    $currency_symbol_field = ','.$focus->table_name.'.currency_symbol as currency_symbol'; //币种符号
    $amount_sql = ',ifnull('.$focus->table_name.'.amount,0)/ifnull('.$focus->table_name.'.conversion_rate,1) as amountsum';//预计合同金额字段

    $SQLColumnFrom=$queryGenerator->getFromClause();//字段来源的表

        $list_query.= $SQLColumn.$table_index.$currency_id_field.$currency_symbol_field.$amount_sql.$SQLColumnFrom;

    $table_id_index=$focus->table_index;
    $list_query.=' inner join ( '.$page_list_query. " ) as tmp
             on tmp.$table_id_index=".$focus->table_name.'.'.$table_id_index;
    $list_query = "SELECT
	b.*,a.listvalue
FROM
	(
		SELECT
			b.*
		FROM
			ld_picklist_set a
		LEFT JOIN ld_picklist_values b ON a.listid = b.listid
		WHERE
			a.listname = '$pick_fieldname'
		ORDER BY
			b.id ASC
	) a
RIGHT JOIN (
	$list_query group by $focus->table_name.$table_id_index
) b ON a.listvalue = b.".$currentField_arr[1]." order by a.id asc ";

    $list_result = $adb->pquery($list_query, array());
    $listnums = $adb->num_rows($list_result);
    if($listnums>0){
        $fieldinfos = $adb->query_result_all($list_result);
    }
        $focus=CRMEntity::getInstance($currentModule);
        $Modulefields = $focus->fieldobj->getModuleFields();


        //wyt 230607 BUG0066510 kfbcrm-销售机会-看板视图 预计合同金额字段的数据小数位数应和单据详情界面字段数据小数位数保持一致
        foreach($fieldinfos as $k=>$info){
            //$focus->retrieve_entity_info($info['crmid'], $currentModule);
            //币种符号
            $currency_symbol = $info['currency_symbol'];
            foreach($info as $name=>$detail){
                $typeofdata=$Modulefields[$name]->typeofData;
                $bigtype=$Modulefields[$name]->bigtype;
                if($name=='amountsum'){
                    $typeofdata=$Modulefields['amount']->typeofData;
                    $bigtype=$Modulefields['amount']->bigtype;
                }
                if(!empty($typeofdata) && strpos($typeofdata, ',')){
                    $typeofdata_decimal=explode(',',$typeofdata)[1];
                    if($bigtype=='currency' && $name!='amountsum'){
                        //BUG20240823-27  销售机会看板视图下的合计显示不正确，希望能够显示原值，而不是显示带单位名称的数字（单据上合计值显示错误） 
                        //$fieldinfos[$k][$name]=number_format($detail,$typeofdata_decimal);//230607 wyt BUG0066476 kfbcrm-销售机会-看板视图-金额前加上币种符号
                    }else if($name!='amountsum'){
                        //$fieldinfos[$k][$name]=number_format($detail,$typeofdata_decimal);
                    }
                }
            }
        }

    //没有阶段的也做循环
    $detailinfo = [];
    foreach ($result_pick as $key => $stagename) {
        $temp = [];
        $amount_sum=0;
        foreach ($fieldinfos as $item) {

            if ($item['listvalue'] == $stagename['listvalue']) {
                $temp[$item['crmid']] = $item;
                $amount_sum=$amount_sum+$item['amountsum'];

                $showfieldvalueobj->setRecorId($item['crmid']);
                foreach ($item as $columnname => $value){
                    if ($columnname == 'crmid'){
                        continue;
                    }
                    $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$columnname,"fieldname");
                    $arr[$columnname]=$fieldname;
                    $fieldinfo=$modulefields[$fieldname];
                    $showvalue=$showfieldvalueobj->getFieldValueByField($fieldinfo,$value,$value);
                    if(is_string($showvalue)) $showvalue = [];
                    if (empty($showvalue['value']) || $showvalue['value'] == $item['currency_symbol']){
                        $showvalue['value'] = '';
                    }
                    $item[$columnname] = $showvalue['value'];
                }
                $temp[$item['crmid']]=$item;

            }
        }
        $stagename['amount'] = $amount_sum;//230608 wyt BUG0066485 kfbcrm-销售机会-阶段名称下方显示信息“xx个销售机会”修改为“xx个” 添加当前选项的销售机会总合计金额（若金额过大，以“万”和“亿”为单位）
        if(10000 < $amount_sum && $amount_sum < 100000000){

            $amount_sum=$amount_sum/10000;
            $amount_sum=number_format($amount_sum,2).'万';
        }else if($amount_sum >= 100000000){
            $amount_sum=$amount_sum/100000000;
            $amount_sum=number_format($amount_sum,2).'亿';
        }else{
            $amount_sum=number_format($amount_sum,2);
        }
        $stagename['amount']=$defaultcurrency.$amount_sum;

        $detailinfo[] = [
            'stagename' => $stagename,
            'info' => $temp
        ];
    }
    $viewid = $customView->getViewId($this->module);
    $html = '<input type="hidden" id="viewname" name="viewname" value="'.$viewid.'">';
    $html .= '<input type="hidden" id="viewid" name="viewid" value="'.$viewid.'">';
    //hzx BUG0077084
    $html .='<div class="ld-stageItem" id="hdScrolllistentries_yy" style="position:relative;visibility: visible;overflow-x:scroll;overflow-y: hidden;padding-right:20px;background-color: #F0F2F5;width: '.$pagewidth.'">';

    require_once globalStatic::$root_directory.'modules/Settings/cls_module_advance.php';
    $moduleadvance_obj = cls_module_advance::getInstance('Potentials');
    foreach($detailinfo as $stagenums=>$stagerow){
    //230510 wyt BUG0066135 kfbcrm-销售机会-五个阶段前边的数字去掉
    //$counts=$stagenums+1;
        $html.='<div class="ld-kanban" style="height:'.$pageheight.'" ><div class="ld-stageName" style="background: '.$stagerow['stagename']['bgcolor'].';">'.$stagerow['stagename']['listvalue'].'</div>'; //每个阶段
        $stagecounts=(count($stagerow['info']));
        $html.='<div class="ld-stageInfo">'.getFixedLabel('TOTAL').'：'.$stagerow['stagename']['amount'].' | '.$stagecounts.getFixedLabel('GECOUNT');
        if($pick_fieldname == 'sales_stage'){
            $html.= ' | '.getFixedLabel('WinRate').$stagerow['stagename']['winrate'].'% ';
        }
        $html.= '</div>';
        //BUG0068919 txy 2023.07.03 kfbcrm-销售机会-看板视图-界面无法滑到最底部
        $tmp_pageheight = (int)explode('px',$pageheight??'')[0];
        $tmp_pageheight = $tmp_pageheight - 82;
        $html.='<div class="ld-stagelist" style="height: calc(100% - 80px)">';

        foreach($stagerow['info'] as $crmid=>$fieldinfo){
            $html.='<div class="ld-potential-item" style="overflow-y:hidden" record="'.$crmid.'" id="cube_'.$crmid.'" module="'.$currentModule.'" onmouseover="editshow(this)" onclick="ListLinkClick(ld(this),event)">';
            $title_nums=1;
            foreach($fieldinfo as $fieldname => $fieldvalue){//wyt 230615 BUG0068160 kfbcrm-销售机会-看板视图-预计合同金额字段不显示，且小数位数与单据详情界面不一致
                //zxm 20230922 BUG0073078   销售机会看板视图列表界面，若下方区块中显示的字段是上方横向的推进字段，下方就不再显示该字段
                if($fieldname!=$currentField_arr[1]&&$fieldname!='crmid' && $fieldname!='listvalue'&&$fieldname!='amountsum'&&$fieldname!='currency_id'&&$fieldname!='currency_symbol'){
                    $label=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$fieldname,"fieldlabel");
                    if($title_nums==1){
                        //BUG0069317 txy 2023.07.10 kfbcrm-【界面优化】销售机会-看板视图-当机会名称过长时，名称行行高不会调整，文字超出界线。
                        $html.='<div class="ld-potential-itemName groupuser-treediv-span tip-items-list" data-tip="'.$fieldvalue.'" data-direction="top" data-type="position"><span onclick="editshow()">'.$fieldvalue.'</span></div>';
                    }else if($title_nums==2){
                        $html.='<div class="ld-potential-itemInfo">';
                        if($label != ''){
                            $html.='<div style="display: flex;margin-left: 10px;"><span onclick="editshow()">'.$label.':'.$fieldvalue.'</span></div>';
                        }
                    }else{
                        if($label != ''){
                            $html.='<div style="display: flex;margin-left: 10px;"><span onclick="editshow()">'.$label.':'.$fieldvalue.'</span></div>';
                        }
                    }
                    $title_nums++;
                }
            }
			//项目视图看板增加停留时间 BUG20240530-17
            $listadvanceinfo = $moduleadvance_obj->getModtrackerData_public($crmid,$pick_fieldname);
            $staytimecontent = $listadvanceinfo[$stagerow['stagename']['listvalue']]['showstaytimecontent'];
            $html.='<div style="display: flex;margin-left: 10px;"><span>'.getFixedLabel('STAGEDETENTIONDURATION').':'.$staytimecontent.'</span></div>';
            if($title_nums >= 3){//xxy 2023-11-29 当没有字段显示时，没有<div class="ld-potential-itemInfo">
                $html.='</div>';
            }
            $html.='</div>';
            $html.='<div id="float_edit_'.$crmid.'" class="float-edit ld-potential-itembtns" onclick="editdetail(this,\''.$currentModule.'\',\'Edit\',\''.$crmid.'\')"><span class="ld-potential-itembtn">'.getFixedLabel('EDIT').'</span></div>';
            $html.='<div style="height: 7px;"></div>';
        }
        $html.='</div></div>';
        $html.='';
    }
    $html.='</div>';
    return $html;
}


public function getAccountname($id)
{
    global $adb;
    $sql = "select accountname from ld_account where accountid = $id";
    $result = $adb->pquery($sql, array());
    return $adb->query_result($result,0,"accountname");
}

public function getRealValue($value){
    global $adb;
    $query = 'select id,last_name,wx_userid from ld_users where id =?';
    $result = $adb->pquery($query, array($value));
    $userobj=new Users();
    if ($adb->num_rows($result) >= 1) {
        for ($i = 0; $i < $adb->num_rows($result); $i++) {
            $userobj->wx_userid= $adb->query_result($result, $i, 'wx_userid');
            $userobj->last_name= $adb->query_result($result, $i, 'last_name');
            $userobj->id=$adb->query_result($result,$i,'id');
            $username[$i]= getUserlastName($userobj);
        }
    }
    unset($userobj);
    $value = implode('、', $username);
    return $value;
}

    //获取移动端模块列表定制中的字段 用于sql查询
    public function getSelectColumnSQLbyMobileSettings(){
        global $currentModule,$current_user,$adb;

        $queryGenerator=new QueryGenerator($currentModule,$current_user);

        //ld_cvcolumnlist_wx 通过modulename确定模块，presence确定是否启用。Showtag是否显示字段名
        $sql="select rownumber,columnname,presence,showtag from ld_cvcolumnlist_wx where modulename='".$currentModule."' and presence=0 order by rownumber asc ";
        $result=$adb->query($sql,array());
        $nums=$adb->num_rows($result);

        $SQLColumn='';

        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $rownumber=$adb->query_result($result,$i,'rownumber');//第几行
                $columnname=explode(':',$adb->query_result($result,$i,'columnname'));
                $presence=$adb->query_result($result,$i,'presence');//该字段是否启用
                $showtag=$adb->query_result($result,$i,'showtag');
                $fieldinfoobj = $queryGenerator->fieldobj->getFieldInfoobjBykey('fieldname',$columnname[2]);
                if($presence==0 && !empty($fieldinfoobj)){
                    $objfield[$rownumber]=$columnname[2];
                    $SQLColumn.=$fieldinfoobj->getTableName().'.'.$columnname[1].',';
                }
            }
        }

        return $SQLColumn;
    }

}


