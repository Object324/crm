<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');//gyq_24
class  cls_CustomForm01_ListViewWX extends cls_ListViewWX
{
    //联系人模块获取查询手机号码的查询语句 gyq_32
    protected function get_phone_sql($focus,$list_query){
        /*
        $moduleFields = $focus->fieldobj->getModuleFields();
        //设置手机号码的显示样式:如果手机控制样式，则只取uitype等于11的字段值
        $sysdeploy_mobile_style = getSys_deploy(80);
        foreach ($moduleFields as $fieldname => $fieldinfo) {
            if ($sysdeploy_mobile_style['deploy_value'] >= 1 && $fieldinfo->getUIType() == 11
                || $sysdeploy_mobile_style['deploy_value'] == 0 && ($fieldinfo->getUIType() == 11 || $fieldinfo->getUIType() == 1101)
            ) {
                $tablename = $fieldinfo->getTableName();
                $columnname = $fieldinfo->getColumnName();
                if ($tablename == 'ld_contactscf') {
                    $listscf = ' FROM ld_contactdetails left join ld_contactscf on ld_contactdetails.contactid = ld_contactscf.contactid ';
                    if(stripos(str_replace(' ','', $list_query),'leftjoinld_contactscf')  === false) {
                        $list_query = str_replace('FROM ld_contactdetails', $listscf, $list_query);
                    }
                }
                $querycolumnname[] = $tablename . '.' . $columnname;
            }
        }
        if (sizeOf($querycolumnname) >= 1) {
            $querycolumnname = 'CONCAT_WS(" ",' . implode(',', $querycolumnname) . ') as mobile,';
            $list_query = str_replace("ld_contactdetails.mobile,", $querycolumnname, $list_query);
        }*/
        return $list_query;

    }

	//230714 wym 客户“圣拉维”，自定义表单01切换日历视图
    protected $chooseDay = false;
    protected $choosemonth = false;
    public function setFilterRequest()
    {
        if ($_REQUEST['show_type'] == 'calendar') {
            $this->choosemonth = $_REQUEST['choosemonth'];
            $this->chooseDay = $_REQUEST['filter']['lastmodified'];
            unset($_REQUEST['filter']['lastmodified']);
            $this->jsonArr['color_days'] = $this->getcolor();
        }
        parent::setFilterRequest();
    }

    public function getcolor()
    {
        global $adb;
        $readDay = date('Y-m',strtotime($this->choosemonth));
        $date = new DateTime($readDay);
        $firstDay = $date->format('Y-m-01');
        $lastDay = $date->format('Y-m-t');
        $time_cod = " where date_start <= ' $lastDay ' AND date_end >= '$firstDay'";
        $color_query = "select * from ld_calendarcolorsetting";
        $color_query .= $time_cod;
        $color_result = $adb->pquery($color_query);
        $color_rows = $adb->num_rows($color_result);
        for($i=0;$i<$color_rows;$i++)
        {
            $colorsetting_id = $adb->query_result($color_result,$i,'colorsetting_id');
            $color_setting[$colorsetting_id]['start'] = $adb->query_result($color_result,$i,'date_start');
            $color_setting[$colorsetting_id]['end'] = $adb->query_result($color_result,$i,'date_end');
            $color_setting[$colorsetting_id]['color'] = $adb->query_result($color_result,$i,'color');
        }
        foreach ($color_setting as $item) {
            $startDate = $item['start'];
            $startDate = ($startDate <= $firstDay) ? $firstDay:$startDate;
            $startDay = (new DateTime($startDate))->format("j");

            $endDate = $item['end'];
            $endDate = ($endDate >= $lastDay) ? $lastDay:$endDate;
            $endDay = (new DateTime($endDate))->format("j");

            for($i=$startDay;$i<=$endDay;$i++){
                $color_setting_result[$i] = $item['color'];
            }
        }
        return $color_setting_result;
    }

    public function get_page_list_query($showtype)
    {
        $search_columnname = $this->get_search_columnname();
        if ($_REQUEST['show_type'] == 'calendar') {
            $module = $this->module;
            $focus = CRMEntity::getInstance($module);
            $focus->getModuleLogic($module);
            $table_name = $focus->table_name;
            $table_index = $focus->table_index;
            $fieldInfoobj = $focus->fieldobj->getFieldInfoobjBykey('columnname',$search_columnname);
            $tablename = $fieldInfoobj->getTableName();
            if ($this->choosemonth) {
                $readDay = date('Y-m',strtotime($this->choosemonth));
                $date = new DateTime($readDay);
                $firstDay = $date->format('Y-m-01');
                $lastDay = $date->format('Y-m-t');
                $time_cod = " between '$firstDay' and '$lastDay' ";
                $where .= " and $tablename.$search_columnname $time_cod ";
            }
            $this->obj_query->whereFieldTables[$tablename] = "$tablename on $tablename.$table_index = $table_name.$table_index";
            $query = $this->obj_query->getQuery($showtype, 1);
            $query .= $where;
        }else {
            $query = Parent::get_page_list_query($showtype);
        }
        return  $query;
    }

    public function page_list_query($noofrows, $page_list_query, $order_by)
    {
        //zkt 20240119 BUG20240118-38 请分配给小光。档期管理，日历界面，2024-3-23，门店：浦东海岛店，PC端显示4个档期，小程序只显示1个记录。
        if ($_REQUEST['show_type'] == 'calendar') {
            global $mobile_pagerecordcount,$weixin_user;
            $this->jsonArr['pageTip'] = getVarFixedLabel('DSFMFFQOTSTT5OTQR',$mobile_pagerecordcount);
            $havenextpage = 'no';
            $haveprevpage = 'no';
            $this->jsonArr['pagecount'] = 1;
            $this->jsonArr['totalrows'] = $noofrows;
            $this->jsonArr['havenextpage'] = $havenextpage;
            $this->jsonArr['haveprevpage'] = $haveprevpage;
            $this->jsonArr['curpagenum'] = 1;

            // diony 2023-09-21 水印
            crm_load_class_file('MenuUtils','modules/Users');
            $MenuUtilsObj = new MenuUtils();
            $watermark_txt = $MenuUtilsObj->getwatermark_setting();
            $this->jsonArr['watermark_txt'] =$watermark_txt;
        }
        else{
            $page_list_query = parent::page_list_query($noofrows, $page_list_query, $order_by);
        }


        return $page_list_query;
    }

    public function getListViewEntries($adb, $list_result, $approvestatus)
    {
        $list1_complex = Parent::getListViewEntries($adb, $list_result, $approvestatus);
        $search_columnname = $this->get_search_columnname();
        if ($_REQUEST['show_type'] == 'calendar') {
            global $adb;
            $field_num = $adb->num_rows($list_result);
            $arr = $list1_complex;
            unset($list1_complex);
            for ($i = 0; $i < $field_num; $i++) {
                $date = $adb->query_result($list_result, $i, $search_columnname);
                $day = new DateTime($date);
                $day = $day->format("j");
                $spot_day .= $day . ',';

                if(date('Y-m-d',strtotime($this->chooseDay)) == $date){
                    $curid = $adb->query_result($list_result, $i, $this->focus->table_index);
                    foreach($arr as $tmpinfo){
                        $tmpcurid = $tmpinfo['curid'];
                        if($tmpcurid == $curid){
                            $list1_complex[] = $tmpinfo;
                            break;
                        }
                    }
                }
            }
            $this->jsonArr['spot_days'] = $spot_day;
        }
        return $list1_complex;
    }

    //当前设置为圣拉维的婚期字段，后续做成公共方法时可以修改
    public function get_search_columnname(){
        $search_columnname = 'cf_7441';
        return $search_columnname;
    }
}
?>