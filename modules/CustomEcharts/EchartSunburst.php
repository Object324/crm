<?php
//旭日图
//只能有一个统计维度　
//需要根据 统计维度查询级联字段 拼接ＳＱＬ
//图表参数的设置：只需要设置统计维度　　
class EchartSunburst extends EchartReport
{
    public function getSunburstData($report_id){
        $echartSet = $this->getEchartSet($report_id);
        $echartSet['groupInfo'] = $this->groupInfo;
        //统计维度 -旭日图只有一个统计维度
        $group_sql = "select * from ld_customreport_group where report_id=? order by `sequence` asc";
        $group_res = $this->adb->pquery($group_sql,[$report_id]);
        $groupbytype = $this->adb->query_result($group_res,0,'groupbytype');
        $groupcolumns = $this->adb->query_result($group_res,0,'columns');
        $bigtype = $this->adb->query_result($group_res,0,'bigtype');
        $temp_groupcolumns = explode(':',$groupcolumns);
        //递归字段
        $dependentFields = $this->getDependentFields($echartSet['mainmodule'],$temp_groupcolumns[1]);
        // 统计字段--只有一个统计字段
        $columns = $this->getTotalColumn($report_id);
        $echartSet['totalColumns'] = $columns;
        $field = implode(',',$this->field);
        // 先不管条件 拼接sql

    }
}