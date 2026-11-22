<?php
class MobileDetailInfo{
    public $module;
    public $focus;
    public $mobiledetailinfoshowtype;
    public $fieldSelectedArr;//选中的字段
    public $fieldAllInfoArr;//全部字段
    public $detailtype = 'no';//分录类型  productdetail产品分录   tabdetail非产品分录  no没有分录
    public function __construct($module,$mobiledetailinfoshowtype){
        $this->module = $module;
        if(empty($mobiledetailinfoshowtype)){
            $this->getMobiledetailinfoshowtype();
        }else{
            $this->mobiledetailinfoshowtype = $mobiledetailinfoshowtype;
        }
        $this->focus = CRMEntity::getInstance($module);
        if(get_file_address($this->module,"ProductDetails")){
            $this->detailtype = 'productdetail';
        }

        if(!empty($this->focus->detailfieldobj)){
            $detailfieldobjname = get_class($this->focus->detailfieldobj);
            if($detailfieldobjname=='ProductToolFields'){
                $this->detailtype = 'productdetail';
            }
            if($detailfieldobjname=='TabDetailFields'){
                $this->detailtype = 'tabdetail';
            }

        }
        if($module == 'CashBill'||$module == 'SendCashBill'||$module == 'ServiceCharge'){
            $this->detailtype = 'no';
        }
    }
    public function getMobiledetailinfoshowtype(){
        global $adb;
        $tabid = getTabid($this->module);
        $select_sql = "select mobiledetailinfoshowtype from ld_tab where tabid = ? ";
        $res = $adb->pquery($select_sql,array($tabid));
        $mobiledetailinfoshowtype = $adb->query_result($res,0,'mobiledetailinfoshowtype');
        $this->mobiledetailinfoshowtype = empty($mobiledetailinfoshowtype)?'tile':$mobiledetailinfoshowtype;
        return  $this->mobiledetailinfoshowtype;
    }
    //获取所有可用的明细字段
    public function getAllDetailFields(){
        $focus = $this->focus;
        $fieldAllInfoArr = [];
        $fieldSelectedArr = $this->getSelectedDetailFields();
        if($this->detailtype != 'no')
        {
            $fieldinfoObj = $focus->detailfieldobj->getListSearchFields();
            foreach ($fieldinfoObj as $fieldinfo){
                //BUG0070666 hzx
                if($fieldinfo->getNewLine() != 0){
                    continue ;
                }
                $columnname = $fieldinfo->getColumnName();
                if(!array_key_exists($columnname,$fieldSelectedArr)){
                    $fieldAllInfoArr[$columnname] = ['columnname'=>$fieldinfo->getColumnName(),'fieldlabel'=>$fieldinfo->fieldLableKey];
                }
            }
        }
        $this->fieldAllInfoArr = $fieldAllInfoArr;
        return $fieldAllInfoArr;
    }

    //获取折叠或者表格显示的明细字段
    public function getSelectedDetailFields(){
        global $adb;
        $module = $this->module;
        $mobiledetailinfoshowtype = $this->mobiledetailinfoshowtype;
        $tabid = getTabid($module);
        $fieldSelectedArr = [];
        $fieldinfoObj = $this->focus->detailfieldobj->getListSearchFields();
        $tmpFieldAllInfoArr = [];

        foreach ($fieldinfoObj as $fieldinfo){
            $columnname = $fieldinfo->getColumnName();
            $tmpFieldAllInfoArr[$columnname] = ['columnname'=>$fieldinfo->getColumnName(),'fieldlabel'=>$fieldinfo->fieldLableKey];
        }
        $sql = "select * from ld_fieldwxdetailinfo where tabid=? and mobiledetailinfoshowtype=?";
        $res = $adb->pquery($sql,array($tabid,$mobiledetailinfoshowtype));
        $nums = $adb->num_rows($res);
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $columnname = $adb->query_result($res,$i,'columnname');
                //BUG0067892  zxm 20230728 设置好了字段显示之后 将字段隐藏 这里也不应该显示这个字段了
                if(isset($tmpFieldAllInfoArr[$columnname])){
                    $fieldlabel = $tmpFieldAllInfoArr[$columnname]['fieldlabel'];
                    $fieldSelectedArr[$columnname] = ['columnname'=>$columnname,'fieldlabel'=>$fieldlabel];
                }
            }
        }
        $this->fieldSelectedArr = $fieldSelectedArr;
        return $fieldSelectedArr;
    }

    //保存
    public function saveSelectedDetailFields(){
        global $adb;
        $selectedFields = $_REQUEST['selectedFields'];
        $selectedFields = trim($selectedFields,';');
        $selectedFieldsArray=explode(';',$selectedFields);
        //判断
        if(($this->mobiledetailinfoshowtype=='fold'||$this->mobiledetailinfoshowtype=='table')&&count($selectedFieldsArray)<=2){
            ConvertTojsonString(-1, [],getVarFixedLabel('bellowtovarcolumnstips',3));
        }

        //更新ld_tab表的mobiledetailinfoshowtype值
        $updatesql = "update ld_tab set mobiledetailinfoshowtype = ? where tabid=? ";
        $tabid = getTabid($this->module);
        $adb->pquery($updatesql,array($this->mobiledetailinfoshowtype,$tabid));
        //insert到 ld_fieldwxdetailinfo表
        $deletesql = "delete from ld_fieldwxdetailinfo where tabid=?";
        $adb->pquery($deletesql,array($tabid));


        $insertsql = 'insert into ld_fieldwxdetailinfo (tabid,relatedtable,columnname,sequence,mobiledetailinfoshowtype)values (?,?,?,?,?)';
        if($this->detailtype == 'productdetail'){
            //ld_producttoolfield
            foreach($selectedFieldsArray as $key=>$fieldname){
                if(!empty($fieldname)){
                    $adb->pquery($insertsql,array($tabid,'ld_producttoolfield',$fieldname,$key,$this->mobiledetailinfoshowtype));
                }
            }
        }
        if($this->detailtype == 'tabdetail'){
            //ld_tabdetailfield
            foreach($selectedFieldsArray as $key=>$fieldname){
                if(!empty($fieldname)) {
                    $adb->pquery($insertsql, array($tabid, 'ld_tabdetailfield', $fieldname, $key, $this->mobiledetailinfoshowtype));
                }
            }
        }
        //清除缓存
        Cache('ldcrmgetdetailshowtype',['a'=>'111']);
        return getFixedLabel('SUCCESSFULLYSAVED');
    }
}