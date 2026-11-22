<?php
//editor:gyq_138 reason:迅达别墅梯首页  2019/8/23 10:26
crm_load_class_file('WorkReportModelWX','WeiXinApp/modules/Home');
class home_page_model extends WorkReportModelWX
{
    //迅达别墅梯首页
    public function home_xdzg_($r_where){
        global $adb,$current_user;
        //线索签约表
        //累计线索
        $sql = 'select
                  count(case when month(createdtime)=1 then createdtime end) as m1,
                  count(case when month(createdtime)=2 then createdtime end) as m2,
                  count(case when month(createdtime)=3 then createdtime end) as m3,
                  count(case when month(createdtime)=4 then createdtime end) as m4,
                  count(case when month(createdtime)=5 then createdtime end) as m5,
                  count(case when month(createdtime)=6 then createdtime end) as m6,
                  count(case when month(createdtime)=7 then createdtime end) as m7,
                  count(case when month(createdtime)=8 then createdtime end) as m8,
                  count(case when month(createdtime)=9 then createdtime end) as m9,
                  count(case when month(createdtime)=10 then createdtime end) as m10,
                  count(case when month(createdtime)=11 then createdtime end) as m11,
                  count(case when month(createdtime)=12 then createdtime end) as m12,smownerid as useid
                from ld_account a
                where  a.deleted=0 and a.publicaccount=0 and a.smownerid'.$r_where;
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $series_data1 = array();
        for($i=0;$i<12;$i++){
            $series_data1[$i] = $adb->query_result($result,0,'m'.($i+1));
        }
        //累计签约
        $sql = 'select
                  count(case when month(createdtime)=1 then createdtime end) as m1,
                  count(case when month(createdtime)=2 then createdtime end) as m2,
                  count(case when month(createdtime)=3 then createdtime end) as m3,
                  count(case when month(createdtime)=4 then createdtime end) as m4,
                  count(case when month(createdtime)=5 then createdtime end) as m5,
                  count(case when month(createdtime)=6 then createdtime end) as m6,
                  count(case when month(createdtime)=7 then createdtime end) as m7,
                  count(case when month(createdtime)=8 then createdtime end) as m8,
                  count(case when month(createdtime)=9 then createdtime end) as m9,
                  count(case when month(createdtime)=10 then createdtime end) as m10,
                  count(case when month(createdtime)=11 then createdtime end) as m11,
                  count(case when month(createdtime)=12 then createdtime end) as m12,smownerid as useid
                from ld_project p1
                  inner join ld_projectcf p2 on p1.projectid=p2.projectid and p1.deleted=0 
                  where p1.smownerid'.$r_where;
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $series_data2 = array();
        for($i=0;$i<12;$i++){
            $series_data2[$i] = $adb->query_result($result,0,'m'.($i+1));
        }
        $data_list['xdzg_cluesigning'] = array($series_data1,$series_data2);

        //销售完成情况
        //认购台量
        $sql = 'select
              ifnull(sum(case when month(createdtime) = 1
                then ifnull(cf_2835, 0) end), 0) as m1,
              ifnull(sum(case when month(createdtime) = 2
                then ifnull(cf_2835, 0) end), 0) as m2,
              ifnull(sum(case when month(createdtime) = 3
                then ifnull(cf_2835, 0) end), 0) as m3,
              ifnull(sum(case when month(createdtime) = 4
                then ifnull(cf_2835, 0) end), 0) as m4,
              ifnull(sum(case when month(createdtime) = 5
                then ifnull(cf_2835, 0) end), 0) as m5,
              ifnull(sum(case when month(createdtime) = 6
                then ifnull(cf_2835, 0) end), 0) as m6,
              ifnull(sum(case when month(createdtime) = 7
                then ifnull(cf_2835, 0) end), 0) as m7,
              ifnull(sum(case when month(createdtime) = 8
                then ifnull(cf_2835, 0) end), 0) as m8,
              ifnull(sum(case when month(createdtime) = 9
                then ifnull(cf_2835, 0) end), 0) as m9,
              ifnull(sum(case when month(createdtime) = 10
                then ifnull(cf_2835, 0) end), 0) as m10,
              ifnull(sum(case when month(createdtime) = 11
                then ifnull(cf_2835, 0) end), 0) as m11,
              ifnull(sum(case when month(createdtime) = 12
                then ifnull(cf_2835, 0) end), 0) as m12,
              smownerid                          as useid
            from ld_potential p1
              inner join ld_potentialscf p2 on p1.potentialid = p2.potentialid and p1.deleted = 0
              where p1.smownerid'.$r_where;
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $series_data1 = array();
        if($num > 0){
            for($i=0;$i<12;$i++){
                $series_data1[$i] = $adb->query_result($result,0,'m'.($i+1));
            }
        }
        //已完成台量
        $sql = 'select
              ifnull(sum(case when month(cf_2959)=1 then ifnull(cf_3081,0) end),0) as m1,
              ifnull(sum(case when month(cf_2959)=2 then ifnull(cf_3081,0) end),0) as m2,
              ifnull(sum(case when month(cf_2959)=3 then ifnull(cf_3081,0) end),0) as m3,
              ifnull(sum(case when month(cf_2959)=4 then ifnull(cf_3081,0) end),0) as m4,
              ifnull(sum(case when month(cf_2959)=5 then ifnull(cf_3081,0) end),0) as m5,
              ifnull(sum(case when month(cf_2959)=6 then ifnull(cf_3081,0) end),0) as m6,
              ifnull(sum(case when month(cf_2959)=7 then ifnull(cf_3081,0) end),0) as m7,
              ifnull(sum(case when month(cf_2959)=8 then ifnull(cf_3081,0) end),0) as m8,
              ifnull(sum(case when month(cf_2959)=9 then ifnull(cf_3081,0) end),0) as m9,
              ifnull(sum(case when month(cf_2959)=10 then ifnull(cf_3081,0) end),0) as m10,
              ifnull(sum(case when month(cf_2959)=11 then ifnull(cf_3081,0) end),0) as m11,
              ifnull(sum(case when month(cf_2959)=12 then ifnull(cf_3081,0) end),0) as m12,smownerid as useid
            from ld_projecttask p1
              inner join ld_projecttaskcf p2 on p1.projecttaskid=p2.projecttaskid and p1.deleted=0
              where p1.smownerid'.$r_where;
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $series_data2 = array();
        for($i=0;$i<12;$i++){
            $series_data2[$i] = $adb->query_result($result,0,'m'.($i+1));
        }
        $data_list['xdzg_salesinfo'] = array($series_data1,$series_data2);

        //销售简报
        $sql = 'select \'线索\' as name,count(a.accountid) as number,\'Accounts\' as VALUE,smownerid as useid
            from ld_account a
            where a.deleted=0 and a.publicaccount=0
            union all
            select \'商机\' as name,count(a.potentialid) as number,\'Potentials\' as VALUE,a.smownerid as useid
            from ld_potential  a
              INNER JOIN ld_account a2 on a.accountid=a2.accountid and a2.deleted=0 and a.deleted=0
            union all
            select \'签约\' as name,count(projectid) as number,\'Project\' as VALUE,a.smownerid as useid
            from ld_project  a
              INNER JOIN ld_account a2 on a.accountid=a2.accountid and a2.deleted=0 and a.deleted=0
            union all
            select \'OIT\' as name,count(projecttaskid) as number,\'ProjectTask\' as VALUE,a.smownerid as useid
            from ld_projecttask  a
              INNER JOIN ld_account a2 on a.accountid=a2.accountid and a.deleted=0 and a2.deleted=0
              where a2.smownerid'.$r_where;
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $series_data = array();
        for($i=0;$i<$num;$i++){
            $name = $adb->query_result($result,$i,'value');
            $series_data[$name] = array(
                'name'=>$name,'label'=> $adb->query_result($result,$i,'name'),
                'number'=>$adb->query_result($result,$i,'number')
            );
        }
        $data_list['xdzg_briefing'] = $series_data;

        $sql = 'select
              sum(a.jg) as a,
              sum(a.zh) as b,
              sum(a.wg) as c,
              sum(a.qt) as d
            from (
                   select
                     a2.smownerid,
                     (case when cf_2935 = 1
                       then 1
                      else 0 end) as jg,
                     (case when cf_2937 = 1
                       then 1
                      else 0 end) as zh,
                     (case when cf_2938 = 1
                       then 1
                      else 0 end) as wg,
                     (case when cf_2939 = 1
                       then 1
                      else 0 end) as qt
                   from ld_potentialscf a1
                     INNER JOIN ld_potential a2 on a1.potentialid = a2.potentialid and a2.deleted = 0
                   where DATE_FORMAT(a2.createdtime, \'%Y\') = DATE_FORMAT(NOW(), \'%Y\') and a2.smownerid'.$r_where.'
                 ) as a ';
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $series_data = array();
        if($num > 0){
            $series_data['data'] = array(
                $adb->query_result($result,0,'a'),
                $adb->query_result($result,0,'b'),
                $adb->query_result($result,0,'c'),
                $adb->query_result($result,0,'d')
            );
            $series_data['name'] = array('价格','装潢','外观','其他');
        }
        $data_list['failure_potential'] = $series_data;
        return $data_list;
    }
}