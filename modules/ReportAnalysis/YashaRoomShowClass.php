<?php

class YashaRoomShowClass{
    public $adb;
    public $cf_8076='销售楼盘';
    public $smarty;
    public function __construct(){
        global $adb,$languageType,$current_user;
        $this->adb = $adb;
        $this->language = $languageType;
        $this->current_user = $current_user;
        $this->smarty = new lingdangCRM_Smarty();
    }

    public function index(){
        $smarty =  $this->smarty;
        $loupan_list = $this->getBuildingList();
        $this->smarty->assign("defaultlopan",$loupan_list[0]['loupan_name']);
        $this->smarty->assign("defaultbuildingnum",$loupan_list[0]['list'][0]['building_num']);
        $this->smarty->assign("loupan_list",$loupan_list);

        if($_REQUEST['frommobile']=='yes'){
            $smarty->assign("frommobile",$_REQUEST['frommobile']);
            $smarty->assign("wx_userid",$_REQUEST['userid']);

            //zxm 20230423 app端的判断
            global $PlatformMC;
            if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
            {
                $encryptobj=new cls_MyCRMcrypt();
                $smarty->assign("wx_userid",$encryptobj->encode($_REQUEST['userid']));
                $smarty->assign("appusertoken",$_REQUEST['appusertoken']);
            }else{
                $smarty->assign("wx_userid",$_REQUEST['userid']);
            }
            //移动端查看页
            $corpurl_all = getCorpUrl();
            $corpurl_arr = explode('WeiXinApp',$corpurl_all);
            $smarty->assign("JSURL",$corpurl_arr[0]);
            $smarty->assign("CSSURL",$corpurl_arr[0]);

            $smarty->assign("CRMCOMMONURL",$corpurl_arr[0]);
            //wx_version
            $versioninfo = getVersionInfo();
            $smarty->assign("wx_version",$versioninfo['wx_version']);
            //来自移动端
            global $weixin_user;
            if($weixin_user->environment=='wxwork'||$weixin_user->environment=='weixin'){
                //小程序
                $homefile = "index_mini.php";
            }else if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes') {
                //app
                $homefile = "indexnative.php";
            }else{
                //企业微信
                //云之家
                //钉钉
                $homefile = "index.php";
            }
            $smarty->assign("homefile",$homefile);
            $smarty->assign("environment",$weixin_user->environment);
            $smarty->assign("crm_url",$corpurl_arr[0]);
            $this->smarty->assign("THEME",'softed');
            $this->smarty->display("ReportAnalysis/YashaRoomShowMobile.tpl");
        }else{
            global $global_css_url,$global_js_url,$theme,$global_commonurl;
            $this->smarty->assign("JSURL",$global_js_url);
            $this->smarty->assign("CSSURL",$global_css_url);
            $this->smarty->assign("THEME",$theme);
            $this->smarty->assign("CRMCOMMONURL",$global_commonurl);
            $this->smarty->display("ReportAnalysis/YashaRoomShow.tpl");
        }

    }

    public function showRoom(){
        $loupan = $_REQUEST['loupan'];
        $buildingnum = $_REQUEST['buildingnum'];
        if($buildingnum=='别墅'||$buildingnum=='院墅'){
            $roomlist = $this->getRoomListBieshu($loupan,$buildingnum);
        }else{
            $roomlist = $this->getRoomList($loupan,$buildingnum);
            $this->smarty->assign("roomlist",$roomlist);
            $this->smarty->assign("loupan",$loupan);
            $this->smarty->assign("buildingNum",$buildingnum);



            $this->smarty->assign("danyuan_list",$roomlist['danyuan_list']);
            $this->smarty->assign("header_list",$roomlist['header_list']);

            $this->smarty->assign("numberallcols",$roomlist['numberallcols']);
        }
        $ratelist = $this->getRateList($loupan,$buildingnum);
        $this->smarty->assign("ratelist",$ratelist);
        $this->smarty->assign("roomlist",$roomlist['roomlist']);
        $this->smarty->assign("buildingnum",$buildingnum);
        $this->smarty->assign("terminal",$_REQUEST['terminal']);
        $content = $this->smarty->fetch("ReportAnalysis/YashaRoomShowContent.tpl");
        $_REQUEST['diony']='diony';
        $arr['content']=$content;
        ConvertTojsonString(1,$arr,"success");
    }
    /**
     * @param $loupan //楼盘名称
     * @param $buildingNum //楼栋号
     * @return void
     * //房间列表
     */
    public function getRoomList($loupan,$buildingNum){
        $header_sql = "select 
DISTINCT concat(case when ifnull(pcf.cf_8417,'')='' then '_' else pcf.cf_8417 end,RIGHT(productname,2)) as danyuan_number,
case when ifnull(pcf.cf_8417,'')='' then '_' else pcf.cf_8417 end as danyuan,
RIGHT(productname,2) as number
from ld_products p left join ld_productcf pcf on p.productid=pcf.productid
where p.deleted=0 and pcf.cf_8076=? and pcf.cf_8093=? and pcf.cf_8094=? 
order by danyuan asc,number asc 
;";
        $header_field = [];
        $header_list = [];//房间号表头循环

        $danyuan_list = [];//单元行表头循环
        $hearder_res = $this->adb->pquery($header_sql,array($this->cf_8076,$loupan,$buildingNum));
        $header_nums = $this->adb->num_rows($hearder_res);
        if($header_nums>0){
            for($i=0;$i<$header_nums;$i++){
                $danyuan_number = $this->adb->query_result($hearder_res,$i,'danyuan_number');
                $danyuan = $this->adb->query_result($hearder_res,$i,'danyuan');

                $header_field[] = "group_concat(case when danyuan_number='$danyuan_number' then productname else '' end SEPARATOR '') as name".$danyuan_number;//房间字段sql行转列
                $header_field[] = "group_concat(case when danyuan_number='$danyuan_number' then productid else '' end SEPARATOR '') as pid".$danyuan_number;
                $header_field[] = "group_concat(case when danyuan_number='$danyuan_number' then pick_color else '' end SEPARATOR '') as color".$danyuan_number;
                $header_field[] = "group_concat(case when danyuan_number='$danyuan_number' then `status` else '' end SEPARATOR '') as status".$danyuan_number;

                $header_list[$i]['danyuan_number'] = $danyuan_number;
                $header_list[$i]['namekey'] = 'name'.$danyuan_number;
                $header_list[$i]['pidkey'] = 'pid'.$danyuan_number;
                $header_list[$i]['colorkey'] = 'color'.$danyuan_number;
                $header_list[$i]['statuskey'] = 'status'.$danyuan_number;
                $header_list[$i]['danyuan'] = $danyuan;
                $header_list[$i]['number'] = $this->adb->query_result($hearder_res,$i,'number');
                $numberallcols++;
                if(!isset($danyuan_list[$danyuan])){
                    $danyuan_list[$danyuan] = ['danyuanname'=>$danyuan,'cols'=>0];
                }
                $danyuan_list[$danyuan]['cols'] = $danyuan_list[$danyuan]['cols']+1;
            }
        }

        $numberallcols = count($header_list)+2;//总共有多少列表头

        $header_field_str = implode(',',$header_field);
        $sql = "select 
$header_field_str,
floor
from (
	select 
	p.productname,
	p.productid,
	p.product_no,
	RIGHT(p.productname,2) as number,
	case when ifnull(pcf.cf_8417,'')='' then '_' else pcf.cf_8417 end  as danyuan,
	concat(case when ifnull(pcf.cf_8417,'')='' then '_' else pcf.cf_8417 end,RIGHT(productname,2)) as danyuan_number,
	(case when ifnull(pcf.cf_8418,'')='' then SUBSTRING(productname, 1, CHAR_LENGTH(productname) - 2) else pcf.cf_8418 end ) as floor,
	pcf.cf_8096 as `status`,
	statusinfo.pick_color
	from ld_products p 
	left join ld_productcf pcf on p.productid=pcf.productid
	left join (
		select 
		v.pick_color,
		v.listvalue
		from ld_picklist_set s 
		left join ld_picklist_values v on s.listid=v.listid 
		where s.listname='cf_8096'
	)statusinfo on statusinfo.listvalue=pcf.cf_8096
	where p.deleted=0 and pcf.cf_8076=? and pcf.cf_8093=? and pcf.cf_8094=?
) a 
group by (floor+0)
order by (floor+0) desc
;";
        $res = $this->adb->pquery($sql,array($this->cf_8076,$loupan,$buildingNum));
        $nums = $this->adb->num_rows($res);
        $roomlist = [];
        if($header_nums>0){
            for($j=0;$j<$nums;$j++){
                $roomlist[$j] = $this->adb->query_result_rowdata($res,$j);
            }
        }
        return [
            'danyuan_list'=>$danyuan_list,
            'header_list'=>$header_list,
            'roomlist'=>$roomlist,
            'numberallcols'=>$numberallcols,
        ];
    }

    //$buildingNum 是别墅或者院墅
    public function getRoomListBieshu($loupan,$buildingNum){
        $sql = "select 
p.productname,p.productid,statusinfo.pick_color
from ld_products p left join ld_productcf pcf on p.productid=pcf.productid
left join (
		select 
		v.pick_color,
		v.listvalue
		from ld_picklist_set s 
		left join ld_picklist_values v on s.listid=v.listid 
		where s.listname='cf_8096'
)statusinfo on statusinfo.listvalue=pcf.cf_8096
where p.deleted=0 and pcf.cf_8076=? and pcf.cf_8093=? and pcf.cf_8195=?
order by (cf_8094+0) asc 
;";
        $roomlist = [];

        $res = $this->adb->pquery($sql,array($this->cf_8076,$loupan,$buildingNum));
        $nums = $this->adb->num_rows($res);
        if($nums>0){
            $roomlist = $this->adb->query_result_all($res);

        }
        return [
            'roomlist'=>$roomlist,
        ];
    }
    /**
     * @return void
     * //查询楼盘 楼栋号 二级树数组  按楼栋号升序排
     */

    public function getBuildingList(){
        $sql = "select * from (
select pcf.cf_8093 as loupan_name,pcf.cf_8094 as building_num
from ld_products p 
left join ld_productcf pcf on p.productid=pcf.productid 
where p.deleted=0 and ifnull(pcf.cf_8093,'')!='' and ifnull(pcf.cf_8195,'')!='别墅' and ifnull(pcf.cf_8195,'')!='院墅' and ifnull(pcf.cf_8094,'')!=''  group by pcf.cf_8093,pcf.cf_8094


union all 
select pcf.cf_8093 as loupan_name,'别墅' as building_num
from ld_products p 
left join ld_productcf pcf on p.productid=pcf.productid 
where p.deleted=0 and ifnull(pcf.cf_8093,'')!='' and ifnull(pcf.cf_8195,'')='别墅' group by pcf.cf_8195


union all 
select pcf.cf_8093 as loupan_name,'院墅' as building_num
from ld_products p 
left join ld_productcf pcf on p.productid=pcf.productid 
where p.deleted=0 and ifnull(pcf.cf_8093,'')!='' and ifnull(pcf.cf_8195,'')='院墅'  group by pcf.cf_8195
) a order by loupan_name asc,building_num asc ";
        $res = $this->adb->pquery($sql,array());
        $nums = $this->adb->num_rows($res);
        $list = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $loupan_name = $this->adb->query_result($res,$i,'loupan_name');
                $building_num = $this->adb->query_result($res,$i,'building_num');
                if(!isset($list[$loupan_name]))$list[$loupan_name]=['loupan_name'=>$loupan_name];
                $list[$loupan_name]['list'][] = ['building_num'=>$building_num];
            }
        }
        return array_values($list);
    }

    //求这个楼盘这个楼栋房间各个状态的比例
    public function getRateList($loupan,$buildingNum){
        if($buildingNum!=='别墅'&&$buildingNum!='院墅') {
            $sql = "select 
a.listvalue,a.pick_color,
(case when ifnull(b.nums,0)=0 then 0  else b.nums end )as nums,
(case when ifnull(b.rate,0)=0 then 0  else round(b.rate*100,2) end )as rate
from (
	select 
		v.pick_color,
		v.listvalue
		from ld_picklist_set s 
		left join ld_picklist_values v on s.listid=v.listid 
		where s.listname='cf_8096'
)a left join (
	select 
	pcf.cf_8096 as `status`,
	count(1) as nums,
	count(1)/(select count(1) from ld_products p 
		left join ld_productcf pcf on p.productid=pcf.productid
		where p.deleted=0 and pcf.cf_8076=? and pcf.cf_8093=? and pcf.cf_8094=?) as rate
	from ld_products p 
	left join ld_productcf pcf on p.productid=pcf.productid 
	where p.deleted=0 and pcf.cf_8076=? and pcf.cf_8093=? and pcf.cf_8094=?  
	group by pcf.cf_8096
) b on a.listvalue=b.`status`";
            $res = $this->adb->pquery($sql,array($this->cf_8076,$loupan,$buildingNum,$this->cf_8076,$loupan,$buildingNum));
        }else{
    $sql="select 
    a.listvalue,a.pick_color,
    (case when ifnull(b.nums,0)=0 then 0  else b.nums end )as nums,
    (case when ifnull(b.rate,0)=0 then 0  else round(b.rate*100,2) end )as rate
    from (
        select 
            v.pick_color,
            v.listvalue
            from ld_picklist_set s 
            left join ld_picklist_values v on s.listid=v.listid 
            where s.listname='cf_8096'
    )a left join (
        select 
        pcf.cf_8096 as `status`,
        count(1) as nums,
        count(1)/(select count(1) from ld_products p 
            left join ld_productcf pcf on p.productid=pcf.productid
            where pcf.cf_8076=? and pcf.cf_8093=? and ifnull(pcf.cf_8195,'')=?) as rate
        from ld_products p 
        left join ld_productcf pcf on p.productid=pcf.productid 
        where p.deleted=0 and pcf.cf_8076=? and pcf.cf_8093=? and ifnull(pcf.cf_8195,'')=?
        group by pcf.cf_8096
    ) b on a.listvalue=b.`status`";
            $res = $this->adb->pquery($sql,array($this->cf_8076,$loupan,$buildingNum,$this->cf_8076,$loupan,$buildingNum));
        }
        $list = $this->adb->query_result_all($res);
        return $list;
    }
    //保存当前点击的楼盘名称和楼栋号 方便下次刷新的时候读取
    public function saveHistory(){

    }

}

?>