<?php
/**
 * Edit: xll
 * Date: 2023/08/25
 * Reason: PC龙虎榜组件的类，含设置、展示龙虎榜的相关方法
 */
crm_load_class_file('SalesKitEditSetting','modules/Home/HomeBoardNew');
class DragonTigerList extends SalesKitEditSetting
{

    public static $DragonTigerListObjArr;
    public static function getInstance($boardid) {
        if(isset(self::$DragonTigerListObjArr[$boardid])){
            return self::$DragonTigerListObjArr[$boardid];
        }
        self::$DragonTigerListObjArr[$boardid]=new DragonTigerList($boardid);
        return self::$DragonTigerListObjArr[$boardid];
    }
    public function __construct($boardid)
    {
        parent::__construct($boardid);
        $this->stuffid=100;
    }

    //获取所有龙虎榜的SQL和对应参数，含看板是否已选信息
    public function getAllStuffDetailSQL(){
        $sql = "SELECT
                    ld_homestuffdetail.*, ld_homestuffsaleskit2board.sequence,
                    (
                        CASE
                        WHEN IFNULL(ld_homestuffsaleskit2board.homestuffdetailid,'') = '' THEN 'no'
                        ELSE 'yes'
                        END
                    ) AS selected
                FROM
                    ld_homestuffdetail
                LEFT JOIN ld_homestuffsaleskit2board ON ld_homestuffsaleskit2board.homestuffdetailid = ld_homestuffdetail.id
                AND ld_homestuffsaleskit2board.boardid = ?
                WHERE
                    ld_homestuffdetail.stuffid = ?
                ORDER BY -ld_homestuffsaleskit2board.sequence desc";
        $this->AllSQLParams = array($this->boardid,$this->stuffid);
        return $sql;
    }

    //调用方法获取所有龙虎榜信息
    public function getAllDragonTigerList()
    {
        parent::getAllSalesKitList($this->stuffid);
        $DragonTigerList = $this->saleskitlist;
        return $DragonTigerList;
    }

    public function getStuffLabelList()
    {
        parent::getStuffLabelList();
        $this->StuffLabelList['default']['label'] = getFixedLabel('DefaultDragonTigerList');
        $this->StuffLabelList['custom']['label'] = getFixedLabel('CustomDragonTigerList');
    }

    //设置龙虎榜，返回设置龙虎榜界面
    public function fun_EditDragonTigerList(){
        $dragontigerList = $this->getAllDragonTigerList();

        $smarty = new lingdangCRM_Smarty();
        $stuff_height = $_REQUEST['stuff_height'];
        $stuffinfo = ['stuffid'=>$this->stuffid];
        $smarty->assign('stuffinfo',$stuffinfo);
        $smarty->assign('DRAGONTIGERLIST',$dragontigerList);
        $smarty->assign('StuffLabelList',$this->StuffLabelList);
        $smarty->assign('stuff_height',($stuff_height-50).'px');
        $smarty->assign('stuff_con_height',($stuff_height-95).'px');
        crm_load_class_file('HomeBoardNew_100','modules/Home/HomeBoardNew');
        $stuffObj = new HomeBoardNew_100();
        $smarty -> assign('viewStyle','preview_');
        $OperationTip = '1. ' . getFixedLabel('DragonTigerListTip');
        $smarty -> assign('OperationTip',$OperationTip);
        $PageTabHtml = $this->getStuffPageTabHtml($smarty,$dragontigerList);
        //$stuffObj->getPageTabHtml($smarty,$dragontigerList);

        $str = $smarty->fetch('Home/HomeDragonTigerList.tpl');

        $arr['content'] = $str;
        $arr['PageTabHtml'] = $PageTabHtml;
        $arr['drangontigerlist'] = $dragontigerList;
        $arr['title']=getFixedLabel('DRAGONTIGERLISTCUSTOMIZATION');

        ConvertTojsonString(1,$arr,"success");
    }

    public function fun_getStuffPageTabHtml(){
        $PageTabList = $_REQUEST['PageTabList'];
        $PageTabList = json_decode($PageTabList,true);
        $smarty = new lingdangCRM_Smarty();
        $stuffinfo = ['stuffid'=>$this->stuffid];
        $smarty->assign('stuffinfo',$stuffinfo);
        $PageTabHtml = $this->getStuffPageTabHtml($smarty,$PageTabList);
        $arr['PageTabHtml'] = $PageTabHtml;
        ConvertTojsonString(1,$arr,"success");
    }

    public function getStuffPageTabHtml(&$smarty,$PageTabList){
        crm_load_class_file('HomeBoardNew_100','modules/Home/HomeBoardNew');
        $stuffObj = new HomeBoardNew_100();
        $stuffObj->getPageTabHtml($smarty,$PageTabList);
        return $stuffObj->PageTabHtml;
    }

    //获取设置部分的内容
    public function fun_getStuffDetailSetContent(){
        //统计模块
        $ModuleArr = $this->getModuleArr();
        $computeinfo_arr = $_REQUEST['computeinfo'];
        //空则赋默认值
        $computeinfo_arr = json_decode($computeinfo_arr,true);
        //计算方法
        $computetypeArr = [
            'count'=>getFixedLabel('COUNT'),
            'ucount'=>getFixedLabel('UCOUNT'),
            'sum'=>getFixedLabel('Summation'),
            'max'=>getFixedLabel('MAXVALUE'),
            'min'=>getFixedLabel('MINVALUE'),
            'avg'=>getFixedLabel('AVGVALUE'),
        ];
        //统计字段
        $selectmodulefieldsList = [];
        foreach ($computeinfo_arr as $key => &$computeinfo){
            $computeinfo = (array)$computeinfo;
            //空则赋默认值
            $default_module = '';
            if(empty($computeinfo)){
                foreach ($ModuleArr as $tabid => $moduleinfo){
                    $default_module = $moduleinfo['modulename'];
                    break;
                }
                $computeinfo = ['computemodule'=>$default_module,'computetype'=>'sum'];
            }
            $selectmodule=$computeinfo['computemodule'];
            $selectmodulefields_arr=$this->getSalesKitModuleFields($selectmodule);
            //空则赋默认值
            if($default_module != ''){
                $computeinfo['computecolumns'] = $selectmodulefields_arr['sumField'][0]['compute_column'];
                $computeinfo['groupby'] = $selectmodulefields_arr['smowneridField'][0]['compute_column'];
                $computeinfo['viewrange'] = $selectmodulefields_arr['smowneridField'][0]['compute_column'];
                $computeinfo['daterange'] = $selectmodulefields_arr['timeField'][0]['compute_column'];
                $computeinfo['advance_demand'] = '';
                $computeinfo['advance_demand_groups'] = '';
            }
            $selectmodulefieldsList[$selectmodule] = $selectmodulefields_arr;
        }
        $smarty = new lingdangCRM_Smarty();
        $smarty->assign('MODULEARR',$ModuleArr);
        $smarty->assign('COMPUTETYPEARR',$computetypeArr);
        $smarty->assign('COMPUTEINFOARR',$computeinfo_arr);
        $smarty->assign('SELECTMODULEFIELDSLIST',$selectmodulefieldsList);
        $StuffDetailSearchHtml = $smarty->fetch('Home/StuffDetailSearch.tpl');
        $arr['StuffDetailSearchHtml'] = $StuffDetailSearchHtml;
        $arr['computeinfo_arr'] = $computeinfo_arr;
        ConvertTojsonString(1, $arr, "success");
    }

    //获取对应统计模块的字段信息
    public function fun_getModuleFields(){
        $selectmodule=$_REQUEST['selectedmodule'];
        $selectmodulefields_arr=$this->getSalesKitModuleFields($selectmodule);
        ConvertTojsonString(1, $selectmodulefields_arr, "success");
    }

    //保存龙虎榜
    public function fun_SaveDragonTigerList(){
        $adb = $this->adb;
        $stuffid = $this->stuffid;
        $boardid = $_REQUEST['boardid'];
        $this->boardid = $_REQUEST['boardid'];
        $DragonTigerListInfo=$_REQUEST['DragonTigerListInfo'];
        $DragonTigerListInfo = json_decode($DragonTigerListInfo,true);

        $delete_sql='delete from ld_homestuffsaleskit2board where boardid=? and homestuffdetailid in (
                        select id from ld_homestuffdetail where stuffid = ?
                    )';
        $adb->pquery($delete_sql,array($boardid,$stuffid));
        $all_stufflabel = [];
        $sql_stufflabel = 'SELECT id,stufflabel from ld_homestuffdetail where stuffid = ?';
        $result = $adb->pquery($sql_stufflabel,array($stuffid));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for ($i = 0;$i < $num_rows ;$i++){
                $tmp_stufflabel = $adb->query_result($result, $i,'stufflabel');
                $all_stufflabel[$tmp_stufflabel] = ['fun_name'=>'_old'];
            }
        }
        foreach ($DragonTigerListInfo as $stufflabel => $stufflabelInfo){
            $this->SaveStuffDetailInfo = $stufflabelInfo;
            $fun_name = 'SaveDragonTiger' . $all_stufflabel[$stufflabel]['fun_name'];
            $this->$fun_name();
        }
        ConvertTojsonString(1, '', "success");
    }

    //保存已有的龙虎榜
    public function SaveDragonTiger_old(){
        $adb = $this->adb;
        $SaveStuffDetailInfo = $this->SaveStuffDetailInfo;
        $sql_old='update ld_homestuffdetail set stufflabel_zh=?,stufflabel_en=?,compute_columns=?,compute_type=?,cssname=?,daterange=?,viewrange=?,compute_module=?,pageurl=?,advance_demand=?,advance_demand_groups=?,topnumber=? ,groupby=? where id=?';
        $selectSetSql = "select  1 from ld_homestuffdetail_setting where `type`=? and homestuffdetailid=?";

        $sqlSetInset = "INSERT INTO ld_homestuffdetail_setting ( setvalue,homestuffdetailid,`type`) values (?,?,?)";
        $sqlSetUpdate = "update ld_homestuffdetail_setting set setvalue = ? where homestuffdetailid = ? and type = ? ;";
        foreach($SaveStuffDetailInfo['computeinfo'] as $key=>$computeinfo){
            $id = $computeinfo['homestuffdetailid'];
            if(!$computeinfo['viewrange_isrelated']) $computeinfo['viewrange'] = '';
            if(!$computeinfo['daterange_isrelated']) $computeinfo['daterange'] = '';
            $params = array(
                $SaveStuffDetailInfo['zh'],$SaveStuffDetailInfo['en'],$computeinfo['computecolumns'],$computeinfo['computetype'],
                $SaveStuffDetailInfo['css'],$computeinfo['daterange'],$computeinfo['viewrange'],$computeinfo['computemodule'],
                $SaveStuffDetailInfo['pageurl'],$computeinfo['advance_demand'],$computeinfo['advance_demand_groups'],
                $SaveStuffDetailInfo['topnumber'],$computeinfo['groupby'],$id
            );
            $adb->pquery($sql_old,$params);
            $this->homestuffdetailid = $id;
            foreach ($SaveStuffDetailInfo['SetValue'] as $setType => $setVal) {
                //zxm 20240606 龙虎榜增加是否穿透的参数
                if($setType === 'showZero'||$setType ==='can_penetrate')
                    $setVal = ($setVal === true || $setVal === 'yes') ? 'yes' : 'no';
                $paramsSet = [$setVal,$id,$setType];
                $selectSetRes = $adb->pquery($selectSetSql,array($setType,$id));

                if($adb->num_rows($selectSetRes)>0){
                    $adb->pquery($sqlSetUpdate,$paramsSet);
                }else{
                    $adb->pquery($sqlSetInset,$paramsSet);
                }
            }
            $this->SaveDragonTigerToBoard();
        }
    }

    //保存首次新增的龙虎榜
    public function SaveDragonTiger(){
        $adb = $this->adb;
        $SaveStuffDetailInfo = $this->SaveStuffDetailInfo;
        $sql_new='insert into ld_homestuffdetail(stufflabel,stuffid,stufflabeltype,stufflabel_zh,stufflabel_en,
                               compute_columns,compute_type,cssname,daterange,viewrange,compute_module,pageurl,
                               advance_demand,advance_demand_groups,topnumber,is_default,groupby) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
        $sqlSet = "insert into ld_homestuffdetail_setting(homestuffdetailid, type, setvalue) values (?,?,?);";
        foreach($SaveStuffDetailInfo['computeinfo'] as $key=>$computeinfo){
            $SaveStuffDetailInfo['stufflabel'] = explode('_new',$SaveStuffDetailInfo['stufflabel'])[0];
            if(!$computeinfo['viewrange_isrelated']) $computeinfo['viewrange'] = '';
            if(!$computeinfo['daterange_isrelated']) $computeinfo['daterange'] = '';
            $params = array(
                $SaveStuffDetailInfo['stufflabel'],$this->stuffid,'fixedstr',$SaveStuffDetailInfo['zh'],$SaveStuffDetailInfo['en'],
                $computeinfo['computecolumns'],$computeinfo['computetype'],$SaveStuffDetailInfo['css'],$computeinfo['daterange'],
                $computeinfo['viewrange'],$computeinfo['computemodule'],'',$computeinfo['advance_demand'],$computeinfo['advance_demand_groups'],
                $SaveStuffDetailInfo['topnumber'],$SaveStuffDetailInfo['is_default'],$computeinfo['groupby']
            );
            $adb->pquery($sql_new,$params);
            $id = $adb->getLastInsertID();
            //避免stufflabel重复
            $update_stufflabel_sql = "update ld_homestuffdetail set stufflabel=? where id=?";
            $adb->pquery($update_stufflabel_sql,array('custom_dragontiger_'.$id,$id));
            $this->homestuffdetailid = $id;
            foreach ($SaveStuffDetailInfo['SetValue'] as $setType => $setVal) {
                $paramsSet = [$id,$setType,$setVal];
                $adb->pquery($sqlSet,$paramsSet);
            }
            $this->SaveDragonTigerToBoard();
        }
    }

    //保存龙虎榜至看板
    public function SaveDragonTigerToBoard(){
        $SaveStuffDetailInfo = $this->SaveStuffDetailInfo;
        if($SaveStuffDetailInfo['selected'] === false || $SaveStuffDetailInfo['selected'] === 'no')
            return false;
        $adb = $this->adb;
        $homestuffdetailid = $this->homestuffdetailid;
        $insert_board = 'insert into ld_homestuffsaleskit2board(boardid,homestuffdetailid,sequence) values(?,?,?)';
        $adb->pquery($insert_board,array($this->boardid,$homestuffdetailid,$SaveStuffDetailInfo['sequence']));
    }

    public function fun_DeleteCustom(){
        $DeleteStuffLabelInfo = json_decode($_REQUEST['DeleteStuffLabelInfo'],true);
        $delete_sql = 'delete from ld_homestuffdetail where `id` = ?';
        $adb = $this->adb;
        $adb->pquery($delete_sql,array($DeleteStuffLabelInfo['homestuffdetailid']));
        ConvertTojsonString(1, '', "success");
    }


}

?>