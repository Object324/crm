<?php
include globalStatic::$root_directory."modules/Home/CustomMade/CustomMadeUtils.php";
class YichongUtils extends CustomMadeUtils
{
    public function getStuffData($dfid,$search_date,$scopeType,$senioruserid,$approve_value){
        if($dfid==37){
            $home_values = $this->getProjectSummary($scopeType,$senioruserid,$search_date);
        }else if($dfid==38) {
            $home_values = $this->getJobSummary($scopeType,$senioruserid,$search_date);
        }else if($dfid==51) {
            $home_values = $this->getMarketingOfYichong($scopeType,$senioruserid,$search_date);
        }
        return $home_values;
    }
    /**
     * @param $scopeType
     * @param $senioruserid
     * @param $search_date
     * @return array
     * @throws Exception
     * 销售简报数据
     */
    public function getMarketingOfYichong($scopeType,$senioruserid,$search_date)
    {
        global $adb;
        $where = "where deleted=0 ";
        $date_sql = getHomeDateScope($search_date);//时间
        $date_year_sql = $this->getYearDateScope($search_date);//获取所选择时间的当年时间范围
        $date_overonemonth = date("Y-m-d H:i:s",strtotime("-1 month"));
        $date_overthreemonth = date("Y-m-d H:i:s",strtotime("-3 month"));
        $date_over12month = date("Y-m-01 00:00:00",strtotime("-11 month"));//近12个月
		$date_over = $this->getDateScope($search_date);//累计时间
        //查看人员范围
        if(!empty($senioruserid)&&$senioruserid!="all"){
            $scope_obj = new ScopOfAuthority($adb,'Home');
            $where .= ' and '.$scope_obj->getHomeSmOwnerSearchSql($scopeType,$senioruserid);
        }
        //数据
        $label_arr = [
            //1.S2 新增  数量Potentials
            [
                "label"=>"new_s2_created",
                "name"=>"S2 新增数量 本期",
                "css"=>"item-ico-potentials",
                "module"=>"Potentials",
                "canSkip"=>"yes",//小程序端使用 判断能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_potential $where and  createdtime $date_sql",
                "nums"=>0
            ],
            // 2.S2 新增 EOL  数量   ld_potentialscf:cf_4779:cf_4779:Potentials_关闭日期:D   是否关闭：cf_3340 关闭原因不等于升级至S3阶段
            //value="ld_potentialscf:cf_3622:cf_3622:Potentials_关闭原因:V"
            [
                "label"=>"new_s2_eol_created",
                "name"=>"S2 新增EOL数量 本期",
                "css"=>"item-ico-potentials",
                "module"=>"Potentials",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and b.cf_3340='是' and b.cf_3622 not like '%升级至S3阶段%' and  b.cf_4779 $date_sql",
                "nums"=>0
            ],
            //3. S2 活跃数量累计  是否关闭为 否  b.cf_3340='否'
            [
                "label"=>"new_s2_huoyue_created",
                "name"=>"S2 活跃数量 累计",
                "css"=>"item-ico-potentials",
                "module"=>"Potentials",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and b.cf_3340='否'",
                "nums"=>0
            ],
            //4. S2 预警数量  【更新时间】大于一个月的  且【是否关闭=否】
            [
                "label"=>"new_s2_yujing_created",
                "name"=>"S2 预警数量 累计",
                "css"=>"item-ico-potentials",
                "module"=>"Potentials",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and modifiedtime<='$date_overonemonth' and b.cf_3340 ='否'",
                "nums"=>0
            ],
            //5. s2转化率 是否关闭为 是，关闭原因为 升级至S3阶段的S2单据数量
            [
                "label"=>"new_s2_zhuanhua_created",
                "name"=>"S2 转化率 本年",
                "css"=>"item-ico-potentials",
                "module"=>"Potentials",
                "canSkip"=>"yes",//能否穿透
                "subfix"=>"%",
                "sql"=>"select round(nums*100/total,2) as nums from (select ifnull(count(1),0) as nums,ifnull(null,0) as kk from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and b.cf_3340='是' and b.cf_3622='升级至S3阶段' and  createdtime $date_year_sql) a left join  (select ifnull(count(1),0) as total,ifnull(null,0) as kk from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and  createdtime $date_year_sql)b on a.kk=b.kk",
                "nums"=>0
            ],
            // 6.s2丢失率   新建S3后，S2 单据反写字段 是否关闭改为 是；关闭原因改为 升级至S3阶段 关闭原因非升级至S3阶段关闭的单据均为丢失单据
            [
                "label"=>"new_s2_diushi_created",
                "name"=>"S2 丢失率 本年",
                "css"=>"item-ico-potentials",
                "module"=>"Potentials",
                "canSkip"=>"yes",//能否穿透
                "subfix"=>"%",
                "sql"=>"select round(nums*100/total,2) as nums from (select ifnull(count(1),0) as nums,ifnull(null,0) as kk  from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and b.cf_3340='是' and b.cf_3622<>'升级至S3阶段' and  createdtime $date_year_sql) a left join (select ifnull(count(1),0) as total,ifnull(null,0) as kk from ld_potential a left join ld_potentialscf b on a.potentialid=b.potentialid $where and  createdtime $date_year_sql) as b on a.kk=b.kk",
                "nums"=>0
            ],
            // 7.s3新增数量 -当期
            [
                "label"=>"new_s3_created",
                "name"=>"S3 新增数量 本期",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform22 $where and  createdtime $date_sql",
                "nums"=>0
            ],
            // 8.s3新增EOL数量 -当月   ld_customform22scf:cf_4780:cf_4780:CustomForm22_关闭日期:D
            // cf_3077是
            // ld_customform22scf:cf_3456:cf_3456:CustomForm22_销售状态:V 等于S3
            // ld_customform22scf:cf_3623:cf_3623:CustomForm22_关闭原因:V 不等于升级至S4阶段
            [
                "label"=>"new_s3_eol_created",
                "name"=>"S3 新增EOL数量 本期",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and b.cf_3077='是' and b.cf_3456='S3' and b.cf_3623 not like '%升级至S4阶段%' and  b.cf_4780 $date_sql",
                "nums"=>0
            ],
            //9. total S3 活跃数量 是否关闭：否
            [
                "label"=>"new_s3_huoyue_created",
                "name"=>"S3 活跃数量 累计",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and b.cf_3077='否'",
                "nums"=>0
            ],
            //10. S3 预警项目数量
            //ld_customform22scf:cf_4783:cf_4783:CustomForm22_是否预警:V  是
            [
                "label"=>"new_s3_yujing_created",
                "name"=>"S3 预警数量 累计",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and ((b.cf_4783 like '%是%' and createdtime $date_year_sql) or (modifiedtime <='".$date_overthreemonth."' and b.cf_3077 like '%否%'))",
                "nums"=>0
            ],

            // 11.S3 转化率 是否关闭为 是，关闭原因为 升级至S3阶段的S2单据数量
            [
                "label"=>"new_s3_zhuanhua_created",
                "name"=>"S3 转化率 本年",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "subfix"=>"%",
                "sql"=>"select round(nums*100/total,2) as nums from (select ifnull(count(1),0) as nums,ifnull(null,0) as kk from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and b.cf_3077='是' and b.cf_3623='升级至S4阶段' and  createdtime $date_year_sql) a left join  (select ifnull(count(1),0) as total,ifnull(null,0) as kk from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and  createdtime $date_year_sql)b on a.kk=b.kk",
                "nums"=>0
            ],
            // 12.S3 丢失率   新建S3后，S2 单据反写字段 是否关闭改为 是；关闭原因改为 升级至S3阶段  是否关闭为是，关闭原因不是升级至S4阶段的单据均为丢失单据
            [
                "label"=>"new_s3_diushi_created",
                "name"=>"S3 丢失率 本年",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "subfix"=>"%",
                "sql"=>"select round(nums*100/total,2) as nums from (select ifnull(count(1),0) as nums,ifnull(null,0) as kk from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and b.cf_3077='是' and b.cf_3623<>'升级至S4阶段' and  createdtime $date_year_sql) a left join  (select ifnull(count(1),0) as total,ifnull(null,0) as kk from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and  createdtime $date_year_sql)b on a.kk=b.kk",
                "nums"=>0
            ],
            //13.S4新增数量CustomForm21    新增销售状态为S4 的单据数量
            [
                "label"=>"new_s4_created",
                "name"=>"S4 新增数量 本期",
                "css"=>"item-ico-project",
                "module"=>"CustomForm21",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform21 a left join ld_customform21scf b on a.customform21id=b.customform21id $where and b.cf_3457='S4' and  createdtime $date_sql",
                "nums"=>0
            ],
            //14.S4新增EOL数量
            // ld_customform21scf:cf_4781:cf_4781:CustomForm21_关闭日期:D
            //ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V  不等于S3
            [
                "label"=>"new_s4_eol_created",
                "name"=>"S4 新增EOL数量 本期",
                "css"=>"item-ico-project",
                "module"=>"CustomForm21",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform21 a left join ld_customform21scf b on a.customform21id=b.customform21id $where and b.cf_3457<>'S3' and b.cf_2968='是' and  b.cf_4781 $date_sql",
                "nums"=>0
            ],
            //15.S4活跃数量  1.S4 中（销售状态为S4）
            //2.是否关闭=否 的单据数量
            [
                "label"=>"new_s4_huoyue_created",
                "name"=>"S4 活跃数量 累计",
                "css"=>"item-ico-project",
                "module"=>"CustomForm21",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform21 a left join ld_customform21scf b on a.customform21id=b.customform21id $where and b.cf_2968='否' and b.cf_3457='S4'",
                "nums"=>0
            ],

            //16.转量产数量-当年
            [
                "label"=>"new_zhuanliangchuan_year",
                "name"=>"转量产数量 本年",
                "css"=>"item-ico-project",
                "module"=>"CustomForm21",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform21 a left join ld_customform21scf b on a.customform21id=b.customform21id $where and b.cf_3457 not like '%S3%' and  createdtime $date_year_sql",
                "nums"=>0
            ],
            //17.EOL 数量
            //ld_customform21scf:cf_2968:cf_2968:CustomForm21_是否关闭:V 是
            //ld_customform21scf:cf_4781:cf_4781:CustomForm21_关闭日期:D
            //ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V 不等于S3
            [
                "label"=>"new_s4_yujing_created",
                "name"=>"S4 EOL数量 本年",
                "css"=>"item-ico-project",
                "module"=>"CustomForm21",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_customform21 a left join ld_customform21scf b on a.customform21id=b.customform21id $where and b.cf_3457<>'S3' and b.cf_2968='是' and  b.cf_4781 $date_year_sql",
                "nums"=>0
            ],

            //18.S3 EOL数量 本年
            [
                "label"=>"new_zhuanliangchuan_month",
                "name"=>"S3 EOL数量 本年",
                "css"=>"item-ico-project",
                "module"=>"CustomForm22",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(distinct a.customform22id),0) as nums from ld_customform22 a left join ld_customform22scf b on a.customform22id=b.customform22id $where and b.cf_3077='是' and b.cf_3456='S3' and b.cf_3623 not like '%升级至S4阶段%' and b.cf_4780 $date_year_sql",
                "nums"=>0
            ],
            //19.2020-1214开始第二期
            //订单金额 当月  ld_salesorder:signed_data:signed_data:SalesOrder_订单日期:D
            //ld_salesorderdetailscf:sf18810:sf18810:products_订单单价(不含税):N
            //ld_salesorderdetail:quantity:quantity:products_数量:N
            //ld_salesorderdetailscf:sf7275:sf7275:products_汇率:N
            //ld_salesorder:conversion_rate:conversion_rate:SalesOrder_汇率:N  --1225汇率改成该值
            [
                "label"=>"order_money",
                "name"=>"订单金额 本期",
                "css"=>"item-ico-salesorder",
                "module"=>"SalesOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select sum(ifnull(b.quantity,0)*ifnull(c.sf18810,0)*ifnull(c.sf7275,0)) as nums from ld_salesorder a left join ld_salesorderdetail b on a.salesorderid=b.id left join ld_salesorderdetailscf c on b.lineitem_id=c.lineitem_id $where  and a.signed_data $date_sql",
                "nums"=>0,
                'endfix'=>'￥'
            ],
            //20.
            //未结订单金额 累计 时间不限制  ld_salesorder:signed_data:signed_data:SalesOrder_订单日期:D
            //ld_salesorderdetailscf:sf18810:sf18810:products_订单单价(不含税):N
            //ld_salesorderdetail:balanceoutproductcount:balanceoutproductcount:products_未出库数量:N
            //ld_salesorderdetailscf:sf7275:sf7275:products_汇率:N
            //ld_salesorder:conversion_rate:conversion_rate:SalesOrder_汇率:N  --1225汇率改成该值
            //ld_salesorderdetailscf:sf7275:sf7275:products_汇率:N --2021-0128姚会电话沟通汇率改成该值
            [
                "label"=>"unoutbounder_money",
                "name"=>"未结订单金额 累计",
                "css"=>"item-ico-salesorder",
                "module"=>"SalesOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select sum(ifnull(b.balanceoutproductcount,0)*ifnull(c.sf18810,0)*ifnull(c.sf7275,0)) as nums from ld_salesorder a left join ld_salesorderdetail b on a.salesorderid=b.id left join ld_salesorderdetailscf c on b.lineitem_id=c.lineitem_id $where and a.signed_data $date_over",
                "nums"=>0,
                'endfix'=>'￥'
            ],
            //21.
            //销售额 本期
            //ld_outboundorderdetailscf:sf19302:sf19302:products_销售额_不含税:N  --0104修改
            //ld_outboundordercf:cf_4702:cf_4702:OutboundOrder_出库日期:D//已被更改
            //ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D
            [
                "label"=>"sales_money",
                "name"=>"销售额 本期",
                "css"=>"item-ico-potentials",
                "module"=>"OutboundOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select sum(ifnull(d.sf19302,0)) as nums from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on  c.lineitem_id=d.lineitem_id $where  and a.outdate $date_sql",
                "nums"=>0,
                'endfix'=>'￥'
            ],
            //22.
            //销售额 本年
            //ld_outboundorderdetailscf:sf19302:sf19302:products_销售额_不含税:N  --0104修改
            //ld_outboundordercf:cf_4702:cf_4702:OutboundOrder_出库日期:D//已被更改
            //ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D
            [
                "label"=>"sales_year_money",
                "name"=>"销售额 本年",
                "css"=>"item-ico-potentials",
                "module"=>"OutboundOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select  sum(ifnull(d.sf19302,0)) as nums from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on c.lineitem_id=d.lineitem_id $where  and a.outdate $date_year_sql",
                "nums"=>0,
                'endfix'=>'￥'
            ],
            //23
            //交易客户数量  近12个月 （包含本月）
            //ld_outboundordercf:cf_4801:cf_4801:OutboundOrder_交易单位_（下单客户）:V
            [
                "label"=>"trading_unit",
                "name"=>"交易客户 近12个月",
                "css"=>"item-ico-potentials",
                "module"=>"OutboundOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select count(distinct a.cf_4801) as nums from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id $where  and a.outdate >='".$date_over12month."'",
                "nums"=>0,
            ],
            //24.交易客户交易额
            [
                "label"=>"trading_unit_money",
                "name"=>"交易客户交易额 本期",
                "css"=>"item-ico-potentials",
                "module"=>"OutboundOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select sum(ifnull(d.sf19302,0)) as nums from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on c.lineitem_id=d.lineitem_id $where  and a.outdate $date_sql",
                "nums"=>0,
                'endfix'=>'￥'
            ],
            //25. 客户数量  近12个月 （包含本月）
            //ld_outboundorder:accountid:account_id:OutboundOrder_客户名称:V
            //2021-0218 修改为本年
            [
                "label"=>"important_account_nums",
                "name"=>"客户 本年",
                "css"=>"item-ico-potentials",
                "module"=>"OutboundOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select count(distinct a.accountid) as nums from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id $where  and a.outdate $date_year_sql ",
                "nums"=>0,
            ],
            //26.
            //客户交易额  本期
            //ld_outboundordercf:cf_4700:cf_4700:OutboundOrder_交易单位:V
            //ld_outboundordercf:cf_4702:cf_4702:OutboundOrder_出库日期:D
            [
                "label"=>"business_year_money",
                "name"=>"客户交易额  本期",
                "css"=>"item-ico-potentials",
                "module"=>"OutboundOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select sum(ifnull(d.sf19302,0)) as nums from ld_outboundorder a left join ld_outboundordercf b on a.out_id=b.out_id left join ld_outboundorderdetail c on a.out_id=c.id left join ld_outboundorderdetailscf d on c.lineitem_id=d.lineitem_id $where  and a.outdate $date_sql",
                "nums"=>0,
                'endfix'=>'￥'
            ],
			 //27.订单新增  数量Potentials
            [
				"label"=>"new_created",
                "name"=>"订单新增数量 本期",
                "css"=>"item-ico-salesorder",
                "module"=>"SalesOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(1),0) as nums from ld_salesorder $where and ld_salesorder.signed_data $date_sql",				
                "nums"=>0
            ],
			 //28.未结订单数量 累计
            [
				"label"=>"unoutbounder_count",
                "name"=>"未结订单数量 累计",
                "css"=>"item-ico-salesorder",
                "module"=>"SalesOrder",
                "canSkip"=>"yes",//能否穿透
                "sql"=>"select ifnull(count(distinct a.salesorderid),0) as nums from ld_salesorder a join ld_salesorderdetail b on a.salesorderid=b.id $where and b.balanceoutproductcount!=0.00000000 and  a.signed_data $date_over",				
                "nums"=>0
            ]
        ];
        foreach($label_arr as $k=>&$v){
            $res = $adb->pquery($v['sql']);
            $v['nums'] = $adb->query_result($res,0,'nums');
            if(in_array($k,[18,19,20,21,23,25])){
                $v['nums'] = number_format( $v['nums'],2);
            }
            $v['nums'] = $v['endfix'] .$v['nums'] . $v['subfix'];
        }
        $label_arr = array_chunk($label_arr,2);
        return $label_arr;
    }


    /**
     * @param $search_date
     * @param $reportlabel
     * @return array
     * @throws Exception
     * 销售简报穿透
     */
    public function setMarketingReportSession($search_date,$reportlabel){
        $modulename = $_REQUEST['searchmodule'];
        $tmp_focus = CRMEntity::getInstance($modulename);
        $tablename = $tmp_focus->table_name;
        //审批参数
        $approveQuery = getApprove_Query($tablename);
        $approve_value = $approveQuery['value'];
        //时间参数
        $date_arr = self::getAdvancedQueryOfDate($search_date);
        //edit: xll 2024/01/30 没有方法getAdvancedQueryOfDateCumulative导致报错
		$date_arrCumulative = self::getAdvancedQueryOfDate($search_date);//self::getAdvancedQueryOfDateCumulative($search_date);
        // 关闭日期特殊值
        $date_close_date = $date_arr['date_year_value'];
        $date_close_date = explode(',',$date_close_date);
        foreach($date_close_date as &$v){
            $v = date('Y-m-d',strtotime($v));
        }
        $date_close_date = implode(',',$date_close_date);
        $advft_criteria = [];
        switch ($reportlabel){
            //以下是易冲的
            //1  S2 新增数量
            case "new_s2_created":
                $approve_columnname = "ld_potential:approvestatus:approvestatus:Potentials_审批状态:V";
                $time_columnname = "ld_potential:createdtime:createdtime:Potentials_创建时间:DT";
                break;
            //2   S2 新增 EOL数量  ld_potentialscf:cf_4779:cf_4779:Potentials_关闭日期:D   是否关闭：cf_3340
            case "new_s2_eol_created":
                // 是否关闭
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_3340:cf_3340:Potentials_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => ' and ',
                ];
                //关闭日期
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_4779:cf_4779:Potentials_关闭日期:D",
                    'comparator' => $date_arr['datecomparator'],//'bw',
                    'value' => $date_arr['date_value'],
                    'columncondition' => ' and ',
                ];
                //关闭原因
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_3622:cf_3622:Potentials_关闭原因:V",
                    'comparator' => 'k',
                    'value' => '升级至S3阶段',
                    'columncondition' => ' and ',
                ];
                break;
            //3   s2活跃数量累计 b.cf_3340='否' 是选择时间的当年数据
            case "new_s2_huoyue_created":
                //b.cf_3340='否'
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_3340:cf_3340:Potentials_是否关闭:V",
                    'comparator' => 'c',
                    'value' => "否",
                    'columncondition' => ' and ',
                ];
                break;
            //4   S2 预警数量 当年 一个月未更改字段数据 一个月未新增S3
            //modifiedtime<='$date_overonemonth' and b.cf_3622 <>'升级至S3阶段' and createdtime $date_year_sql
            case "new_s2_yujing_created":
                $date_overonemonth = date("Y-m-d H:i:s",strtotime("-1 month"));
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 1,
                    'columnname' => "ld_potential:modifiedtime:modifiedtime:Potentials_更新时间:DT",
                    "comparator" => "m",
                    "value" => $date_overonemonth,
                    "columncondition" => " and "
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_3340:cf_3340:Potentials_是否关闭:V",
                    'comparator' => 'c',
                    'value' => "否",
                    'columncondition' => ' and ',
                ];
                break;
            //5  s2转化率 当年 是否关闭为 是，关闭原因为 升级至S3阶段的S2单据数量
            case "new_s2_zhuanhua_created":
                //s2丢失率
            case "new_s2_diushi_created":
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 1,
                    'columnname' => "ld_potential:createdtime:createdtime:Potentials_创建时间:DT",
                    "comparator" => "bw",
                    "value" => $date_arr['date_year_value'],
                    "columncondition" => " and "
                ];
                // 是否关闭
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_3340:cf_3340:Potentials_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => ' and ',
                ];
                if($reportlabel=="new_s2_zhuanhua_created"){
                    //关闭原因：升级至S3阶段
                    $tem_comparator = "e";
                }else{
                    //关闭原因：不等于 升级至S3阶段
                    $tem_comparator = "n";
                }
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_potentialscf:cf_3622:cf_3622:Potentials_关闭原因:V",
                    'comparator' => $tem_comparator,
                    'value' => "升级至S3阶段",
                    'columncondition' => ' and ',
                ];
                break;
            case "new_s3_created":
                $approve_columnname = "ld_customform22:approvestatus:approvestatus:CustomForm22_审批状态:V";
                $time_columnname = "ld_customform22:createdtime:createdtime:CustomForm22_创建时间:DT";
                break;
            //s3新增EOL数量 -当期 ld_customform22scf:cf_4780:cf_4780:CustomForm22_关闭日期:D    cf_3077是
            case "new_s3_eol_created":
                //ld_customform22scf:cf_3456:cf_3456:CustomForm22_销售状态:V
                //ld_customform22scf:cf_3623:cf_3623:CustomForm22_关闭原因:V
                // 是否关闭
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3077:cf_3077:CustomForm22_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => ' and ',
                ];

                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_4780:cf_4780:CustomForm22_关闭日期:D",
                    'comparator' => $date_arr['datecomparator'],//'bw',
                    'value' => $date_arr['date_value'],
                    'columncondition' => ' and ',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3456:cf_3456:CustomForm22_销售状态:V",
                    'comparator' => 'c',
                    'value' => 'S3',
                    'columncondition' => ' and ',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3623:cf_3623:CustomForm22_关闭原因:V",
                    'comparator' => 'k',
                    'value' => '升级至S4阶段',
                    'columncondition' => ' and ',
                ];
                break;
            //S3 活跃数量 是否关闭：否
            case "new_s3_huoyue_created":
                //b.cf_3340='否'
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3077:cf_3077:CustomForm22_是否关闭:V",
                    'comparator' => 'c',
                    'value' => "否",
                    'columncondition' => ' and ',
                ];
                break;
            case "new_s3_yujing_created":
                // 1.3个月未更新字段信息的单据；//2.3个月未新增S4
                //ld_customform22scf:cf_4783:cf_4783:CustomForm22_是否预警:V
                $date_overthreemonth = date("Y-m-d H:i:s",strtotime("-3 month"));
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 1,
                    'columnname' => "ld_customform22:createdtime:createdtime:CustomForm22_创建时间:DT",
                    "comparator" => "bw",
                    "value" => $date_arr['date_year_value'],
                    "columncondition" => " and "
                ];
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 1,
                    'columnname' => "ld_customform22scf:cf_4783:cf_4783:CustomForm22_是否预警:V",
                    "comparator" => "c",
                    "value" => "是",
                    "columncondition" => " and "
                ];
                $advft_criteria['advft_criteria_groups'] = '[null,{"groupcondition":"or"}]';
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 2,
                    'columnname' => "ld_customform22:modifiedtime:modifiedtime:CustomForm22_更新时间:DT",
                    "comparator" => "m",
                    "value" => $date_overthreemonth,
                    "columncondition" => " and "
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>2,
                    'columnname' => "ld_customform22scf:cf_3077:cf_3077:CustomForm22_是否关闭:V",
                    'comparator' => 'c',
                    'value' => "否",
                    'columncondition' => ' and ',
                ];
                break;
            //S3 转化率 是否关闭为 是，关闭原因为 升级至S4阶段的S3单据数量 --todo --
            case "new_s3_zhuanhua_created":
            case "new_s3_diushi_created":
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 1,
                    'columnname' => "ld_customform22:createdtime:createdtime:CustomForm22_创建时间:DT",
                    "comparator" => "bw",
                    "value" => $date_arr['date_year_value'],
                    "columncondition" => " and "
                ];
                // 是否关闭
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3077:cf_3077:CustomForm22_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => ' and ',
                ];
                if($reportlabel=="new_s3_zhuanhua_created"){
                    //关闭原因：升级至S4阶段
                    $tem_comparator = "e";
                }else{
                    //关闭原因：不等于 升级至S4阶段
                    $tem_comparator = "n";
                }
                //关闭原因：不等于 升级至S3阶段
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3623:cf_3623:CustomForm22_关闭原因:V",
                    'comparator' => $tem_comparator,
                    'value' => "升级至S4阶段",
                    'columncondition' => ' and ',
                ];
                break;
            case "new_s4_created":
                $approve_columnname = "ld_customform21:approvestatus:approvestatus:CustomForm21_审批状态:V";
                $time_columnname = "ld_customform21:createdtime:createdtime:CustomForm21_创建时间:DT";
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V",
                    'comparator' => 'e',
                    'value' => "S4",
                    'columncondition' => ' and ',
                ];
                break;

            case "new_s4_huoyue_created":
                // 1.S4 中（销售状态为S4）
                //2.是否关闭为否的单据数量
                //b.cf_3340='否'
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_2968:cf_2968:CustomForm21_是否关闭:V",
                    'comparator' => 'c',
                    'value' => "否",
                    'columncondition' => 'and',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V",
                    'comparator' => 'c',
                    'value' => "S4",
                    'columncondition' => 'and',
                ];
                break;
            case "new_s4_eol_created":
                //S4 单据中，销售状态为S4，关闭日期为本期的单据数量 ld_customform21scf:cf_4781:cf_4781:CustomForm21_关闭日期:D   ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_4781:cf_4781:CustomForm21_关闭日期:D",
                    'comparator' => $date_arr['datecomparator'],//'bw',
                    'value' => $date_arr['date_value'],
                    'columncondition' => 'and',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V",
                    'comparator' => 'n',
                    'value' => "S3",
                    'columncondition' => 'and',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_2968:cf_2968:CustomForm21_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => 'and',
                ];
                break;
            case "new_s4_yujing_created":
                //customform03_id
                //b.cf_2968='是' and b.cf_3624='项目关闭' and b.cf_3457='EOL' and modifiedtime<='$date_oversixmonth' and a.customform03_id!=0
                //ld_customform21scf:cf_2968:cf_2968:CustomForm21_是否关闭:V
                //ld_customform21scf:cf_4781:cf_4781:CustomForm21_关闭日期:D
                //ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_4781:cf_4781:CustomForm21_关闭日期:D",
                    'comparator' => 'bw',
                    'value' => $date_close_date,
                    'columncondition' => 'and',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V",
                    'comparator' => 'k',
                    'value' => "S3",
                    'columncondition' => 'and',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_2968:cf_2968:CustomForm21_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => 'and',
                ];

                break;
            case "new_zhuanliangchuan_month"://转量产
                //and b.cf_3077='是' and  b.cf_4780
                // 是否关闭
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3077:cf_3077:CustomForm22_是否关闭:V",
                    'comparator' => 'e',
                    'value' => "是",
                    'columncondition' => 'and',
                ];
                //关闭原因：项目关闭
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_4780:cf_4780:CustomForm22_关闭日期:D",
                    'comparator' => 'bw',//'bw',
                    'value' => $date_arr['date_year_value'],
                    'columncondition' => ' and ',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3456:cf_3456:CustomForm22_销售状态:V",
                    'comparator' => 'c',
                    'value' => 'S3',
                    'columncondition' => ' and ',
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform22scf:cf_3623:cf_3623:CustomForm22_关闭原因:V",
                    'comparator' => 'k',
                    'value' => '升级至S4阶段',
                    'columncondition' => ' and ',
                ];
                break;
            case "new_zhuanliangchuan_year"://转量产
                $advft_criteria[$reportlabel][$modulename][] = [
                    'groupid' => 1,
                    'columnname' => "ld_customform21:createdtime:createdtime:CustomForm21_创建时间:DT",
                    "comparator" => "bw",
                    "value" => $date_close_date,
                    "columncondition" => " and "
                ];
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_customform21scf:cf_3457:cf_3457:CustomForm21_销售状态:V",
                    'comparator' => 'k',
                    'value' => "S3",
                    'columncondition' => ' and ',
                ];
                break;
            case "order_money":
                $time_columnname = "ld_salesorder:signed_data:signed_data:SalesOrder_订单日期:D";
                break;
            case "unoutbounder_money":
				$advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_salesorder:signed_data:signed_data:SalesOrder_订单日期:D",
                    'comparator' => 'bw',//'bw',
                    'value' => $date_arrCumulative['date_year_value'],
                    'columncondition' => 'and',
                ];
			    $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_salesorderdetail:balanceoutproductcount:balanceoutproductcount:products_未出库数量:N",
                    'comparator' => 'n',
                    'value' => "0",
                    'columncondition' => ' and ',
                ];
                break;
            case "trading_unit":
			
            case "important_account_nums":
            case "sales_money":
                $time_columnname = "ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D";
                break;
            case "sales_year_money":
            case "trading_unit_money":
            case "business_year_money":
                $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_outboundorder:outdate:outdate:OutboundOrder_出库日期:D",
                    'comparator' => 'bw',
                    'value' =>$date_close_date,
                    'columncondition' => ' and ',
                ];
                break;
			//27  订单新增数量
            case "new_created":
                $time_columnname = "ld_salesorder:signed_data:signed_data:SalesOrder_订单日期:D";
                break;
			//28  未结订单数量
			case "unoutbounder_count":
				$advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_salesorder:signed_data:signed_data:SalesOrder_订单日期:D",
                    'comparator' => 'bw' ,//'bw',
                    'value' => $date_arrCumulative['date_year_value'],
                    'columncondition' => 'and',
                ];
			    $advft_criteria[$reportlabel][$modulename][] =  [
                    'groupid' =>1,
                    'columnname' => "ld_salesorderdetail:balanceoutproductcount:balanceoutproductcount:products_未出库数量:N",
                    'comparator' => 'n',
                    'value' => "0",
                    'columncondition' => ' and ',
                ];
				break;
            default:
                $approve_value = "";
                $time_columnname = "";
                $modulename = "";
                $approve_columnname = "";
        }
        if(!empty($approve_value)){
            $advft_criteria[$reportlabel][$modulename][] =  [
                'groupid' =>1,
                'columnname' => $approve_columnname,
                'comparator' => 'e',
                'value' => $approve_value,
                'columncondition' => ' and ',
            ];
        }
        if(!empty($time_columnname)) {
            $advft_criteria[$reportlabel][$modulename][] = [
                'groupid' => 1,
                'columnname' => $time_columnname,
                "comparator" => $date_arr['datecomparator'],
                "value" => $date_arr['date_value'],
                "columncondition" => " and "
            ];
        }
        return $advft_criteria;
    }

    /**
     * @param $search_date
     * @return string
     * 获取所给时间的累计时间区间
     * gxy
     * 2021-0317
     */
    public static function getDateScope($search_date)
    {
        switch($search_date){
            case 'thistoday':   //今日
            case 'today'://手机daunt
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d');
                return " between '$year' and '$date'" ;
            case 'yestoday':    //昨日
            case 'syesterday'://手机daunt
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d',strtotime("-1 day"));
                return " between '$year' and '$date'" ;
            case 'thisweek':    //本周
                $year = date('Y-m-d',strtotime("-100 year"));
                $end = date('Y-m-d', (time() + (7 - (date('w') == 0 ? 7 : date('w'))) * 24 * 3600));
                return " between '$year 00:00:00' and '$end 23:59:59' " ;
            case 'lastweek':
                $date = date("Y-m-d");  //当前日期
                $first=1;     //$first =1 表示每周星期一为开始时间 0表示每周日为开始时间
                $w = date("w", strtotime($date));  //获取当前周的第几天 周日是 0 周一 到周六是 1 -6
                $d = $w ? $w - $first : 6;  //如果是周日 -6天
                $nowdate  = date("Y-m-d 00:00:00", strtotime("$date -".$d." days"));
                $nowStart  = date("Y-m-d 00:00:00", strtotime("$nowdate - 7 days")); //上周开始时间
                $year = date('Y-m-d',strtotime("-100 year"));
                $nowEnd    = date("Y-m-d 23:59:59", strtotime("$nowStart +6 days"));  //上周结束时间
                return " between '$year 00:00:00' and '$nowEnd 23:59:59' " ;
            case 'thismonth':   //本月
            case 'month':
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d');
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'lastmonth':   //上月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d',strtotime("-1 days",strtotime(date('Y-m-01'))));
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'nextmonth':   //下月
                $timestamp=strtotime(date('Y-m-d H:i:s'));
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m',strtotime(date('Y',$timestamp).'-'.(date('m',$timestamp)+2)));
                return " between '$year 00:00:00' and '$date-01 00-00-00' " ;
            case 'thisyear':    //本年度
            case 'year':
            case 'thisfy'://手机端
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-m-d');
                return " between '$year' and '$date'" ;
            case 'lastyear':    //上年度
            case 'prevfy'://手机端
                $year = date('Y-m-d',strtotime("-100 year"));
                $date = date('Y-01-01',strtotime("-1 day"));
                return " between '$year 00:00:00' and '$date 23:59:59' " ;
            case 'thisquarter': //本季度
            case 'quarter':
            case 'thisfq'://手机daunt
                $season = ceil((date('n'))/3);
                $year = date('Y-m-d',strtotime("-100 year"));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'lastquarter': //上季度
            case 'prevfq'://手机端
                $season = ceil((date('n'))/3)-1;
                $year = date('Y-m-d',strtotime("-100 year"));
                $end = date('Y-m-d H:i:s', mktime(23,59,59,$season*3,date('t',mktime(0, 0 , 0,$season*3,1,date("Y"))),date('Y')));
                return " between '$year' and '$end' " ;
            case 'all':
                return '';
            default:
                $date = explode('~',$search_date);
                $end_date = explode('-',$date[1]);
                $year = $end_date[0]."-01-01";
                if(sizeof($date) > 1){
                    return " between '$year 00:00:00' and '$date[1] 23:59:59' " ;
                }else{
                    $date = date('Y-m');
                    return " between '$year 00:00:00' and '$date 23:59:59'" ;
                }
        }
    }

    //徐江平的首页组件需求：项目汇总
    public function getProjectSummary($scope,$senioruserid=0,$search_date){
            global $adb;
            global $current_user;
            $date_sql = getHomeDateScope($search_date);
            $scopeobj = ScopOfAuthority::getInstance($adb,'Home');
            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scope,$senioruserid);
            if(!empty($scopesql)){
                $scopesql = str_replace("smownerid","id",$scopesql);
            }
            if(!empty($_REQUEST['approve_value'])){
    //        @edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
                if($_REQUEST['approve_value'] == 'all'){
                }else{
                    $approvestatus = ' AND a.approvestatus in ('.$_REQUEST["approve_value"].')';
                    $approvestatus = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$approvestatus);
                    $approvestatus = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$approvestatus);
                    $approvestatus = str_replace("approved","'" . D_A_S_APPROVED . "'",$approvestatus);
                    $approvestatus = str_replace("rejected","'" . D_A_S_REJECTED . "'",$approvestatus);
                    $approvestatus = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$approvestatus);
                }


            }
            $query = "SELECT
            a.customform02id,
            a.gongchengshi,
            a.xiangmubianhao,
            a.kehuxiangmuhao,
            c.cf_3127 AS xiangmustatus,
            a.accountname AS kehuming,
            a.accountid AS kehuming_id,
            a.pingtai_a,
            a.pingtai_b,
            a.youxianji
        FROM (
            SELECT
                a.customform02id,
                a.createdtime,
                b.cf_3029 AS gongchengshi,
                b.cf_3350 AS xiangmubianhao,
                b.cf_3349 AS kehuxiangmuhao,
                a.approvestatus,
                ld_account.accountname,
                ld_account.accountid,
                b.cf_3764 AS pingtai_a,
                b.cf_3765 AS pingtai_b,
                b.cf_3015 as youxianji
            FROM ld_customform02 a
            LEFT JOIN ld_customform02scf b ON b.customform02id=a.customform02id 
            LEFT JOIN ld_account on ld_account.accountid = a.accountid 
            WHERE a.deleted=0
                $approvestatus 
                AND IFNULL(b.cf_3029,'')<>''
            UNION 
            SELECT
                a.customform02id,
                a.createdtime,
                b.cf_3030 AS gongchengshi,
                b.cf_3350 AS xiangmubianhao,
                b.cf_3349 AS kehuxiangmuhao,
                a.approvestatus,
                ld_account.accountname,
                ld_account.accountid,
                b.cf_3764 AS pingtai_a,
                b.cf_3765 AS pingtai_b,
                b.cf_3015 as youxianji
            FROM ld_customform02 a
            LEFT JOIN ld_customform02scf b ON b.customform02id=a.customform02id 
            LEFT JOIN ld_account on ld_account.accountid = a.accountid 
            WHERE a.deleted=0
                $approvestatus 
                AND IFNULL(b.cf_3030,'')<>''
            UNION 
            SELECT
                a.customform02id,
                a.createdtime,
                b.cf_3031 AS gongchengshi,
                b.cf_3350 AS xiangmubianhao,
                b.cf_3349 AS kehuxiangmuhao,
                a.approvestatus,
                ld_account.accountname,
                ld_account.accountid,
                b.cf_3764 AS pingtai_a,
                b.cf_3765 AS pingtai_b,
                b.cf_3015 as youxianji
            FROM ld_customform02 a
            LEFT JOIN ld_customform02scf b ON b.customform02id=a.customform02id 
            LEFT JOIN ld_account on ld_account.accountid = a.accountid 
            WHERE a.deleted=0
                $approvestatus 
                AND IFNULL(b.cf_3031,'')<>''
        ) a
        LEFT JOIN (
            SELECT
                customform02_id,
                MAX(customform23id) AS maxid
            FROM ld_customform23 
            WHERE deleted=0
                $approvestatus2 
                AND customform02_id>0
            GROUP BY customform02_id
        ) b ON b.customform02_id=a.customform02id
        LEFT JOIN ld_customform23scf c ON c.customform23id=b.maxid
        INNER JOIN ld_users u ON u.last_name=a.gongchengshi
        WHERE 1=1
            -- 查询需要关联首页组件查询条件：时间、审批状态、查看范围
            AND a.createdtime $date_sql
            AND u.$scopesql
        GROUP BY a.customform02id,u.id
        ORDER BY CONVERT(a.gongchengshi USING GBK),a.xiangmubianhao,a.createdtime";
            //$query.= " limit 12";
            //echo $list_query;
            $result = $adb->pquery($query);
            $num_rows = $adb->num_rows($result);
            for($i=0;$i<$sendcashbillnum;$i++){
                $data[] = Array('customform02id' => $adb->query_result($result,$i,'customform02id'),
                    'gongchengshi' => $adb->query_result($result,$i,'gongchengshi'),
                    'xiangmubianhao' => $adb->query_result($result,$i,'xiangmubianhao'),
                    'kehuxiangmuhao' => $adb->query_result($result,$i,'kehuxiangmuhao'),
                    'xiangmustatus' => $adb->query_result($result,$i,'xiangmustatus'),
                    'kehuming' => $adb->query_result($result,$i,'kehuming'),
                    'kehuming_id' => $adb->query_result($result,$i,'kehuming_id'),
                    'pingtai_a' => $adb->query_result($result,$i,'pingtai_a'),
                    'pingtai_b' => $adb->query_result($result,$i,'pingtai_b')
                );
            }
            $CustomForm02_field_obj=Field::getInstance('CustomForm02',$adb);
            $arrFieldLabel=$CustomForm02_field_obj->getFieldLables();
            $title=array();
            $header=array();
            $header[] =  '<span title="'.getFixedLabel('Engineer').'">'.getFixedLabel('Engineer').'</span>';
            $header[] =  '<span title="'.getFixedLabel('Prjectnumber').'">'.getFixedLabel('Prjectnumber').'</span>';
            $header[] =  '<span title="'.getFixedLabel('customerprojectno').'">'.getFixedLabel('customerprojectno').'</span>';
            $header[] =  '<span title="'.getFixedLabel('currentprojectphase').'">'.getFixedLabel('currentprojectphase').'</span>';
            $header[] =  '<span title="'.$arrFieldLabel['account_id'].'">'.$arrFieldLabel['account_id'].'</span>';
            $header[] =  '<span title="'.$arrFieldLabel['cf_3764'].'">'.$arrFieldLabel['cf_3764'].'</span>';
            $header[] =  '<span title="'.$arrFieldLabel['cf_3765'].'">'.$arrFieldLabel['cf_3765'].'</span>';

            $entries=array();
            if($num_rows > 0){
                for($i = 0; $i < $num_rows; $i++){
                    $value=array();
                    $customform02id = $adb->query_result($result,$i,'customform02id');
                    $kehuming = $adb->query_result($result,$i,'kehuming');
                    $kehuming_id = $adb->query_result($result,$i,'kehuming_id');
                    $value[] = $adb->query_result($result,$i,'gongchengshi');
                    $xiangmubianhao = $adb->query_result($result,$i,'xiangmubianhao');
                    $value[]='<a href="javascript:;" referencemodule="CustomForm02" referencerecord="'.$customform02id.'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$xiangmubianhao.'">'.$xiangmubianhao.'</a>';
                    $value[] = $adb->query_result($result,$i,'kehuxiangmuhao');
                    $value[] = $adb->query_result($result,$i,'xiangmustatus');
                    $value[]='<a href="javascript:;" referencemodule="Accounts" referencerecord="'.$kehuming_id.'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$kehuming.'">'.$kehuming.'</a>';
                    $value[] = $adb->query_result($result,$i,'pingtai_a');
                    $value[] = $adb->query_result($result,$i,'pingtai_b');
                    $entries[$customform02id]=$value;
                }
            }

            $values=Array('ModuleName'=>'CustomForm02','Title'=>$title,'Header'=>$header,'Entries'=>$entries);

            if (($display_empty_home_blocks && count($entries) == 0 ) || (count($entries)>0))
                return $values;
        }
    //徐江平的首页组件需求：工单汇总
    public function getJobSummary($scope,$senioruserid=0,$search_date){
        global $adb;
        global $current_user;
        $date_sql = getHomeDateScope($search_date);
        $scopeobj = ScopOfAuthority::getInstance($adb,'Home');
        $scopesql = $scopeobj->getHomeSmOwnerSearchSql($scope,$senioruserid);
        if(!empty($_REQUEST['approve_value'])){
            //@edit:liushuai,2021-02-24,reason:【ID1001362】首页-审批状态可多选查看（四方光电）
            $approvestatus = ' and a.approvestatus in ('.$_REQUEST["approve_value"].')';
            $approvestatus = str_replace("unapproved","'" . D_A_S_UNAPPROVED . "'",$approvestatus);
            $approvestatus = str_replace("approving","'" . D_A_S_APPROVALOF . "'",$approvestatus);
            $approvestatus = str_replace("approved","'" . D_A_S_APPROVED . "'",$approvestatus);
            $approvestatus = str_replace("rejected","'" . D_A_S_REJECTED . "'",$approvestatus);
            $approvestatus = str_replace("dismissed","'" . D_A_S_DISMISSED . "'",$approvestatus);
        }
        $query = "SELECT
		a.ticketid,
		u.last_name AS fuwurenyuan,
		a.ticket_no AS fuwugongdan,
		b.cf_3471 AS kehuxiangmuhao,
		a.status AS ticketstatus,
		ld_account.accountname as kehuming,
		ld_account.accountid as kehuming_id,
		b.cf_2769 as pingtaia,b.cf_4025 as pingtaib
	FROM ld_troubletickets a
	LEFT JOIN ld_ticketcf b ON b.ticketid=a.ticketid
	LEFT JOIN ld_users u ON u.id=a.smownerid 
	LEFT JOIN ld_account on ld_account.accountid = a.accountid 
	WHERE a.deleted=0
		$approvestatus 
		-- 查询需要关联首页组件查询条件：时间、审批状态、查看范围
		AND a.createdtime $date_sql
		AND a.$scopesql
	ORDER BY FIELD(ticketstatus,'处理中','成功关闭') ,a.createdtime";
        $result = $adb->pquery($query);
        $num_rows = $adb->num_rows($result);
        for($i=0;$i<$num_rows;$i++){
            $data[] = Array('ticketid' => $adb->query_result($result,$i,'ticketid'),
                'fuwurenyuan' => $adb->query_result($result,$i,'fuwurenyuan'),
                'fuwugongdan' => $adb->query_result($result,$i,'fuwugongdan'),
                'kehuxiangmuhao' => $adb->query_result($result,$i,'kehuxiangmuhao'),
                'ticketstatus' => $adb->query_result($result,$i,'ticketstatus'),
                'kehuming' => $adb->query_result($result,$i,'kehuming'),
                'kehuming_id' => $adb->query_result($result,$i,'kehuming_id'),
                'pingtaia' => $adb->query_result($result,$i,'pingtaia'),
                'pingtaib'=>$adb->query_result($result,$i,'pingtaib'),
            );
        }
        $title=array();
        $header=array();
        $cashbill_field_obj=Field::getInstance('HelpDesk',$adb);
        $arrFieldLabel=$cashbill_field_obj->getFieldLables();
        $header=array();
        $header[] = '<span title="'.$arrFieldLabel['assigned_user_id'].'">'.$arrFieldLabel['assigned_user_id'].'</span>';
        $header[] = '<span title="'.$arrFieldLabel['ticket_no'].'">'.$arrFieldLabel['ticket_no'].'</span>';
        $header[] = '<span title="'.$arrFieldLabel['cf_3471'].'">'.$arrFieldLabel['cf_3471'].'</span>';
        $header[] = '<span title="'.$arrFieldLabel['ticketstatus'].'">'.$arrFieldLabel['ticketstatus'].'</span>';
        $header[] =  '<span title="'.$arrFieldLabel['account_id'].'">'.$arrFieldLabel['account_id'].'</span>';
        $header[] =  '<span title="'.$arrFieldLabel['cf_3727'].'">'.$arrFieldLabel['cf_3727'].'</span>';
        $header[] =  '<span title="'.$arrFieldLabel['cf_3728'].'">'.$arrFieldLabel['cf_3728'].'</span>';
        $entries=array();
        if($num_rows > 0){
            for($i = 0; $i < $num_rows; $i++){
                $value=array();
                $ticketid = $adb->query_result($result,$i,'ticketid');
                $kehuming = $adb->query_result($result,$i,'kehuming');
                $kehuming_id = $adb->query_result($result,$i,'kehuming_id');
                $value[] = $adb->query_result($result,$i,'fuwurenyuan');
                $fuwugongdan = $adb->query_result($result,$i,'fuwugongdan');
                $value[]='<a href="javascript:;" referencemodule="HelpDesk" referencerecord="'.$ticketid.'" onclick="ListReferenceLinkClick(ld(this),event)" title="'.$fuwugongdan.'">'.$fuwugongdan.'</a>';
                $value[] = $adb->query_result($result,$i,'kehuxiangmuhao');
                $value[] = $adb->query_result($result,$i,'ticketstatus');
                $value[]='<a target="_blank" href="index.php?action=DetailView&module=Accounts&record='.$kehuming_id.'&parenttab=Tools" title="'.$kehuming.'">'.$kehuming.'</a>';
                $value[] = $adb->query_result($result,$i,'pingtaia');
                $value[] = $adb->query_result($result,$i,'pingtaib');
                $entries[$ticketid]=$value;
            }
        }

        $values=Array('ModuleName'=>'HelpDesk','Title'=>$title,'Header'=>$header,'Entries'=>$entries);

        if (($display_empty_home_blocks && count($entries) == 0 ) || (count($entries)>0))
            return $values;

    }

}