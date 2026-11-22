<?php


class HuboshiUtils
{
    //月份数组
    public $fieldArrMonth = [
        "1"=>'form24detailscf.sf289 as amount',
        "2"=>'form24detailscf.sf290 as amount',
        "3"=>'form24detailscf.sf291 as amount',
        "4"=>'form24detailscf.sf293 as amount',
        "5"=>'form24detailscf.sf294 as amount',
        "6"=>'form24detailscf.sf295 as amount',
        "7"=>'form24detailscf.sf297 as amount',
        "8"=>'form24detailscf.sf298 as amount',
        "9"=>'form24detailscf.sf299 as amount',
        "10"=>'form24detailscf.sf301 as amount',
        "11"=>'form24detailscf.sf302 as amount',
        "12"=>'form24detailscf.sf303 as amount'
    ];
    //季度数组
    public $fieldArrQuarter = [
        "1"=>'form24detailscf.sf292 as amount',
        "2"=>'form24detailscf.sf296 as amount',
        "3"=>'form24detailscf.sf300 as amount',
        "4"=>'form24detailscf.sf304 as amount'
        ];
    //年度
    public $fieldArrYear = 'form24detail.amount';
    public function huboshivendorscompleteinfo(){
        global $current_user;
        global $adb;
        //1 月度/季度  2 年度
        $time_type = $_REQUEST['reporttype'];
        $curyear = date('Y');
        $curmonth = date('m')+0;
        $curquarter = ceil(date('m')/3)+0;
        $monthField = $this->fieldArrMonth[$curmonth];
        $quarterField = $this->fieldArrQuarter[$curquarter];
        $yearField = $this->fieldArrYear;
        $userid = $current_user->id;
        $sqlArrMonth = [
            'MonthTarget'=>['name'=>'月度任务量',
                'sql'=>"select $monthField from ld_customform24 form24
left join ld_customform24detail form24detail on form24.customform24id=form24detail.id 
left join ld_customform24detailscf form24detailscf on form24detailscf.lineitem_id=form24detail.lineitem_id 
where form24.deleted=0 and form24.list_nian=$curyear
and form24.mubiao_type='代理商'
and form24detail.lin_users_id=$userid order by form24.createdtime desc limit 1",
                'value'=>0],
            'MonthSales'=>['name'=>'月度任务完成情况',
                'sql'=>"select (case 
    when (ifnull(a.total,0)-ifnull(b.total,0)-ifnull(c.total,0))<=0 then 0 
    else (ifnull(a.total,0)-ifnull(b.total,0)-ifnull(c.total,0)) end )as amount
from
	ld_users u 
left join (
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from 
	ld_salesorder sales
	left join ld_account account on account.accountid=sales.accountid
	left join ld_users u on u.accountid=sales.accountid
	where sales.deleted=0 and u.id=$userid  and DATE_FORMAT(signed_data,'%Y')=$curyear and DATE_FORMAT(signed_data,'%m')+0=$curmonth
)a on u.id=a.uid
left join(
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from ld_customform12 form12 
	left join ld_customform12scf form12scf on form12scf.customform12id=form12.customform12id
	left join ld_account account on account.accountid=form12.accountid
	left join ld_users u on u.accountid=form12.accountid
	where form12.deleted=0 and u.id=$userid  and form12scf.cf_4514='返利充值'
	and DATE_FORMAT(form12scf.cf_4578,'%Y')=$curyear and DATE_FORMAT(form12scf.cf_4578,'%m')+0=$curmonth
)b on u.id=b.uid 
left join(
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from ld_expense expense 
	left join ld_account account on account.accountid=expense.accountid
	left join ld_users u on u.accountid=expense.accountid
	where expense.deleted=0 and u.id=$userid  and expense.approvestatus='已批准'
	and DATE_FORMAT(expense.expensedate,'%Y')=$curyear and DATE_FORMAT(expense.expensedate,'%m')+0=$curmonth
)c on u.id=c.uid 
where u.id=$userid ",
                'value'=>0],
            'MonthGap'=>['name'=>'月度任务差额',
                'sql'=>'',
                'value'=>0]
        ];
        $sqlArrQuarter = [
            'QuarterTarget'=>['name'=>'季度任务量',
                'sql'=>"select $quarterField from ld_customform24 form24
left join ld_customform24detail form24detail on form24.customform24id=form24detail.id 
left join ld_customform24detailscf form24detailscf on form24detailscf.lineitem_id=form24detail.lineitem_id 
where form24.deleted=0 and form24.list_nian=$curyear
and form24.mubiao_type='代理商'
and form24detail.lin_users_id=$userid order by form24.createdtime desc limit 1",
                'value'=>0],
            'QuarterSales'=>['name'=>'季度任务完成情况',
                'sql'=>"select (case 
    when (ifnull(a.total,0)-ifnull(b.total,0)-ifnull(c.total,0))<=0 then 0 
    else (ifnull(a.total,0)-ifnull(b.total,0)-ifnull(c.total,0)) end )as amount
from
	ld_users u 
left join (
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from 
	ld_salesorder sales
	left join ld_account account on account.accountid=sales.accountid
	left join ld_users u on u.accountid=sales.accountid
	where sales.deleted=0 and u.id=$userid  and DATE_FORMAT(signed_data,'%Y')=$curyear and QUARTER(signed_data)+0=$curquarter
)a on u.id=a.uid
left join(
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from ld_customform12 form12 
	left join ld_customform12scf form12scf on form12scf.customform12id=form12.customform12id
	left join ld_account account on account.accountid=form12.accountid
	left join ld_users u on u.accountid=form12.accountid
	where form12.deleted=0 and u.id=$userid  and form12scf.cf_4514='返利充值'
	and DATE_FORMAT(form12scf.cf_4578,'%Y')=$curyear and QUARTER(form12scf.cf_4578)+0=$curquarter
)b on u.id=b.uid 
left join(
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from ld_expense expense 
	left join ld_account account on account.accountid=expense.accountid
	left join ld_users u on u.accountid=expense.accountid
	where expense.deleted=0 and u.id=$userid  and expense.approvestatus='已批准'
	and DATE_FORMAT(expense.expensedate,'%Y')=$curyear and QUARTER(expense.expensedate)+0=$curquarter
)c on u.id=c.uid 
where u.id=$userid",
                'value'=>0],
            'QuarterGap'=>['name'=>'季度任务差额',
                'sql'=>'',
                'value'=>0]
        ];
        $sqlArrYear = [
            'YearTarget'=>['name'=>'年度任务量',
                'sql'=>"select $yearField from ld_customform24 form24
left join ld_customform24detail form24detail on form24.customform24id=form24detail.id 
left join ld_customform24detailscf form24detailscf on form24detailscf.lineitem_id=form24detail.lineitem_id 
where form24.deleted=0 and form24.list_nian=$curyear
and form24.mubiao_type='代理商'
and form24detail.lin_users_id=$userid order by form24.createdtime desc limit 1",
                'value'=>0],
            'YearSales'=>['name'=>'年度任务完成情况',
                'sql'=>"select (case 
    when (ifnull(a.total,0)-ifnull(b.total,0)-ifnull(c.total,0))<=0 then 0 
    else (ifnull(a.total,0)-ifnull(b.total,0)-ifnull(c.total,0)) end )as amount
from
	ld_users u 
left join (
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from 
	ld_salesorder sales
	left join ld_account account on account.accountid=sales.accountid
	left join ld_users u on u.accountid=sales.accountid
	where sales.deleted=0 and  u.id=$userid  and DATE_FORMAT(signed_data,'%Y')=$curyear 
)a on u.id=a.uid
left join(
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from ld_customform12 form12 
	left join ld_customform12scf form12scf on form12scf.customform12id=form12.customform12id
	left join ld_account account on account.accountid=form12.accountid
	left join ld_users u on u.accountid=form12.accountid
	where form12.deleted=0 and u.id=$userid  and form12scf.cf_4514='返利充值'
	and DATE_FORMAT(form12scf.cf_4578,'%Y')=$curyear 
)b on u.id=b.uid 
left join(
	select 
	sum(ifnull(total,0)) as total,
	u.id as uid 
	from ld_expense expense 
	left join ld_account account on account.accountid=expense.accountid
	left join ld_users u on u.accountid=expense.accountid
	where expense.deleted=0 and  u.id=$userid  and expense.approvestatus='已批准'
	and DATE_FORMAT(expense.expensedate,'%Y')=$curyear 
)c on u.id=c.uid 
where u.id=$userid",
                'value'=>0],
            'YearGap'=>['name'=>'年度任务差额',
                'sql'=>'',
                'value'=>0],
        ];
        $list = [];
        if($time_type=='year'){
            //年度
            $this->getTargetRes('Year',$sqlArrYear,$list);
        }else{
            //月度
            $this->getTargetRes('Month',$sqlArrMonth,$list);
            //季度
            $this->getTargetRes('Quarter',$sqlArrQuarter,$list);
        }
        $time_range = array(
            array('time_key'=>'month','label'=>'月度/季度','key'=>'month','selected'=>$time_type=='year'?'no':'yes'),
            array('time_key'=>'year','label'=>'年度','key'=>'year','selected'=>$time_type=='year'?'yes':'no')
        );
        ConvertTojsonString(1,[
            'list'=>array_values($list),
            'name'=>'经销商任务完成情况表',
            'time_range'=>$time_range,
            'userinfo'=>['lastname'=>'全部','permit'=>2],
        ],'');
    }

    /**
     * @param $type
     * @param $list
     * @param $sqlArr
     * @throws Exception
     */
    private function getTargetRes($type,$sqlArr,&$list){
        //月度
        global $adb;
        $list[$type.'Target']['name']=$sqlArr[$type.'Target']['name'];
        $list[$type.'Target']['value']=$sqlArr[$type.'Target']['value'];
        $TargetRes = $adb->pquery($sqlArr[$type.'Target']['sql']);
        $TargetNums = $adb->num_rows($TargetRes);
        if($TargetNums>0){
            $list[$type.'Target']['value'] = $adb->query_result($TargetRes,0);
        }

        $list[$type.'Sales']['name']=$sqlArr[$type.'Sales']['name'];
        $list[$type.'Sales']['value']=$sqlArr[$type.'Sales']['value'];
        $SalesRes = $adb->pquery($sqlArr[$type.'Sales']['sql']);
        $SalesNums = $adb->num_rows($SalesRes);
        if($SalesNums>0){
            $list[$type.'Sales']['value'] = $adb->query_result($SalesRes,0,0);
        }
        $list[$type.'Gap']['name']=$sqlArr[$type.'Gap']['name'];
        $list[$type.'Gap']['value']=$list[$type.'Target']['value']-$list[$type.'Sales']['value'];

        $list[$type.'Target']['value']=number_format($list[$type.'Target']['value'],2);
        $list[$type.'Sales']['value']=number_format($list[$type.'Sales']['value'],2);
        $list[$type.'Gap']['value'] = $list[$type.'Gap']['value']<=0?0:$list[$type.'Gap']['value'];
        $list[$type.'Gap']['value']=number_format($list[$type.'Gap']['value'],2);
        return $list;
    }
    public function huboshiuserscompleteinfo(){
        global $current_user;
        //1 月度  2 年度
        $time_type = $_REQUEST['reporttype'];
        $curyear = date('Y');
        $curmonth = date('m')+0;
        $monthField = $this->fieldArrMonth[$curmonth];
        $yearField = $this->fieldArrYear;
        $userid = $current_user->id;
        $sqlArrMonth = [
            'MonthTarget'=>['name'=>'月度任务量',
                'sql'=>"select $monthField from ld_customform24 form24
left join ld_customform24detail form24detail on form24.customform24id=form24detail.id 
left join ld_customform24detailscf form24detailscf on form24detailscf.lineitem_id=form24detail.lineitem_id 
where form24.deleted=0 and  form24.list_nian=$curyear
and form24.mubiao_type='业务员'
and form24detail.lin_users_id=$userid order by form24.createdtime desc limit 1",
                'value'=>0],
            'MonthSales'=>['name'=>'月度任务完成情况',
                'sql'=>"select (case 
    when (ifnull(a.total,0))<=0 then 0 
    else (ifnull(a.total,0)) end )as amount
from
	ld_users u 
left join (
	select 
	sum(ifnull(cash_jiesuan,0)) as total,
	u.id as uid 
	from 
	ld_salesorder sales
	left join ld_account account on account.accountid=sales.accountid
	left join ld_users u on u.id=account.smownerid
	where sales.deleted=0 and  u.id=$userid  and DATE_FORMAT(signed_data,'%Y')=$curyear and DATE_FORMAT(signed_data,'%m')+0=$curmonth
)a on u.id=a.uid
where u.id=$userid ",
                'value'=>0],
            'MonthGap'=>['name'=>'月度任务差额',
                'sql'=>'',
                'value'=>0]
        ];

        $sqlArrYear = [
            'YearTarget'=>['name'=>'年度任务量',
                'sql'=>"select $yearField from ld_customform24 form24
left join ld_customform24detail form24detail on form24.customform24id=form24detail.id 
left join ld_customform24detailscf form24detailscf on form24detailscf.lineitem_id=form24detail.lineitem_id 
where form24.deleted=0 and form24.list_nian=$curyear
and form24.mubiao_type='业务员'
and form24detail.lin_users_id=$userid order by form24.createdtime desc limit 1",
                'value'=>0],
            'YearSales'=>['name'=>'年度任务完成情况',
                'sql'=>"select (case 
    when (ifnull(a.total,0))<=0 then 0 
    else (ifnull(a.total,0)) end )as amount
from
	ld_users u 
left join (
	select 
	sum(ifnull(cash_jiesuan,0)) as total,
	u.id as uid 
	from 
	ld_salesorder sales
	left join ld_account account on account.accountid=sales.accountid
	left join ld_users u on u.id=account.smownerid
	where sales.deleted=0 and  u.id=$userid  and DATE_FORMAT(signed_data,'%Y')=$curyear 
)a on u.id=a.uid
where u.id=$userid",
                'value'=>0],
            'YearGap'=>['name'=>'年度任务差额',
                'sql'=>'',
                'value'=>0],
        ];
        $list = [];
        if($time_type=='year'){
            //年度
            $this->getTargetRes('Year',$sqlArrYear,$list);
        }else{
            //月度
            $this->getTargetRes('Month',$sqlArrMonth,$list);
        }
        $time_range = array(
            array('time_key'=>'month','label'=>'月度','key'=>'month','selected'=>$time_type=='year'?'no':'yes'),
            array('time_key'=>'year','label'=>'年度','key'=>'year','selected'=>$time_type=='year'?'yes':'no')
        );
        ConvertTojsonString(1,[
            'list'=>array_values($list),
            'name'=>'业务员任务完成情况表',
            'time_range'=>$time_range,
            'userinfo'=>['lastname'=>'全部','permit'=>2],
        ],'');

    }
}