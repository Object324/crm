<?php
/**
 * V6.1 产品自定义类
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */
 crm_load_class_file("TabDetailToolFields",'include/TabDetailFields');
class  TabDetailFields{
  
	private $languageType;
	private $tabid;
	private $jsontabdetailfields;//所有自定义字段，包括隐藏字段
	private $tabPresenceDetailFields;//有权限看到并且启用的自定义字段
	private $tabNoPresenceDetailFields;//不启用(隐藏)字段
	private $tabDetailFormulaFields;//启用字段和字段公式字段
	private $tabNoPresneceFormulaFields;//不启用，并且有字段公式的字段
	private $tabSubtotalField;
	private $module_nullfield;	//模块空行基准字段
    private $execsetTabDetailFun='no';
   
    public $sourcemodulename='';
    public static function getInstance($module)
    {
        static $TabDetailFields_Objs;
      
        if($TabDetailFields_Objs[$module])
        {
            return $TabDetailFields_Objs[$module];
            
        }
        $TabDetailFields_Objs[$module]=new TabDetailFields(getTabid($module));
        return $TabDetailFields_Objs[$module];
    }
	function __construct($tabid){
		global $current_user;
       $languageType= getLanguageType($current_user);
		$this->languageType = $languageType;
		$this->tabid = $tabid;
      
		//$this->setTabDetailFields();
       
		//$this->setDetailFields();
	}
    function resetDetailFieldsobj(){
        //去除原有参数值
        $this->setDetailFields();
        $this->setTabDetailFormulaFields();
    }
    //设置源单类型
    function setsourceModuleType ($sourceModuletype)
    {
      // 
        $beforesourceModuletype=$this->sourceModuletype;
        $this->sourceModuletype = $sourceModuletype;
        if($sourceModuletype !== $beforesourceModuletype){
            //源单类型改变，重新获取字段信息
            $this->setsourceModulesqlwhere($sourceModuletype);
            $this->resetDetailFieldsobj();
            
        }
    }
    //收付款单，获取源单类型，设置对应的where条件
    function setsourceModulesqlwhere ($sourceModule )
    {
        $this->sourceModulesql = '';
        $this->sourcemodulename=$sourceModule;
        $module = getTabname($this->tabid);
        if($module == 'CashBill'||$module=='SendCashBill'){
            if($sourceModule == 'none'){
                $this->sourceModulesql = " (ld_tabdetailfield.sourcemodule='' or ld_tabdetailfield.sourcemodule is null ) ";
            }
            else if(!empty($sourceModule)){
                $this->sourceModulesql = " ld_tabdetailfield.sourcemodule='$sourceModule' ";
            }
           
        }
        if(!empty($this->jsontabdetailfields)){
            $this->jsontabdetailfields = [];
        }
    }
	//获取模块下的所有自定义字段
	public function getTabDetailFields() {
	    if(empty($this->jsontabdetailfields)){
            $this->setTabDetailFields();
        }
        
        $tabdetailfields =$this->jsontabdetailfields;
        $returntabdetailfields = array();
        foreach($tabdetailfields as $columnanme =>$tabdetailfieldobjs){
            if(is_array($tabdetailfieldobjs)){
                $returntabdetailfields[$columnanme] = $tabdetailfieldobjs[0];
            }
            else{
                $returntabdetailfields[$columnanme] = $tabdetailfieldobjs;
            }
        }
		return $returntabdetailfields;
	}
    /**
     * $sourcemodulename:源单类型 dbvalue：sourcemodule
     * $sorcefield_type:products使用产品分录，仅使用；TabDetail使用非产品分录
     */
    //获取模块下的所有自定义字段
	public function getTabDetailFields_BySourcemodule($sourcemodulename,$suorcefield_type='') {
	    if(empty($this->jsontabdetailfields)){
            $this->setTabDetailFields();
        }
        
        $tabdetailfields =$this->jsontabdetailfields;
        $returntabdetailfields = array();
        foreach($tabdetailfields as $columnanme =>$tabdetailfieldobjs){
            if(is_array($tabdetailfieldobjs)){
                foreach($tabdetailfieldobjs as $tabdetailfieldobj){
                    if($tabdetailfieldobj->getSourceModule()==$sourcemodulename){
                        
                        if($suorcefield_type == 'Products' && $tabdetailfieldobj instanceof ProductFields){
                            $returntabdetailfields[$columnanme] = $tabdetailfieldobj;
                        }
                        else if($suorcefield_type == 'TabDetail' && $tabdetailfieldobj instanceof TabDetailToolFields){
                            $returntabdetailfields[$columnanme] = $tabdetailfieldobj;
                        }
                        else if(empty($suorcefield_type)){
                            $returntabdetailfields[$columnanme] = $tabdetailfieldobj;
                        }
                    }
                }
            }
            else{
                if($tabdetailfieldobjs->getSourceModule()==$sourcemodulename){
                    $returntabdetailfields[$columnanme] = $tabdetailfieldobjs;
                }
            }
        }
		return $returntabdetailfields;
	}
	//获取模块下有权限看到的、并且启用的字段
	public function getTabPresenceDetailFields() {
	   if(empty($this->tabPresenceDetailFields))
         $this->setDetailFields();
		return $this->tabPresenceDetailFields;
	}
	//获取模块下不启用的字段
	public function getTabNoPresenceDetailFields() {
	   if(empty($this->tabNoPresenceDetailFields))
         $this->setDetailFields();
		return $this->tabNoPresenceDetailFields;
	}
	//获取显示字段和不启用并且有字段公式的字段
    public function getTabDetailFormulaField(){
        if(empty($this->tabDetailFormulaFields))
        {
            $this->setTabDetailFormulaFields();
        }
		return $this->tabDetailFormulaFields;
    }
	//获取状态为不显示并且有字段公式的自定义字段
	public function getNoPresenceInputDetailField($tabid){
		return $this->tabNoPresneceFormulaFields;
	}
	//获取小计字段
	public function getTabSubtotalField(){
		return $this->tabSubtotalField;
	}
	//获取名字空行基准字段
	public function getRowNullField(){
		return $this->module_nullfield;
	}
	public function getFieldInfoobjBykey_arr($key,$value)
	{

		$arr=[];
		$modulefieldsobj=$this->getModuleProductToolField();

		foreach($modulefieldsobj as $fieldname=>$fieldInfo)
		{
			if($fieldInfo->$key==$value)
			{
				$arr[]=$fieldInfo;
			}
		}
		return $arr;

	}
    public function getTabDetailFields1(){
        if(empty($this->jsontabdetailfields))
          {
            $this->setTabDetailFields();
          }
          foreach($this->jsontabdetailfields as $columnname => $field){
		      if(is_array($field)){
		          $field = $field[0];
		      }
            }
    }
	public function setDetailFields(){
		global $current_user;
      
 		$getUserNoTabDetailFieldsId = $this->getUserNoTabDetailFieldsId();

		$key = 0;
          if(empty($this->jsontabdetailfields))
          {
            $this->setTabDetailFields();
          }
      $this->execsetTabDetailFun='yes';

        $tabDetailFieldsProfile_array = $this->getTabDetailFieldsProfile($this->tabid);

          foreach($this->jsontabdetailfields as $columnname => $field){
		      if(is_array($field)){
		          $field = $field[0];
		      }
			if(!empty($field)){
				if($field->getPresence() == 0 || $field->getPresence() == 2){
					//用户有权限并且启用的字段
                    $tabdetailfieldid=$field->getTabDetailFieldid();

                    /*if(!is_admin($current_user) && in_array($tabdetailfieldid,$tabDetailFieldsProfile_array['fieldsid_array']) && empty($getUserNoTabDetailFieldsId[$tabdetailfieldid])){
                        //continue;
                        if($tabDetailFieldsProfile_array['fieldsprofile_info'][$tabdetailfieldid]['profilefieldtype'] == 'all'){

                        }else {
                            $field->setDetailsFieldsProfile('hidden', 'hidden', 'hidden');
                        }
                    }

				     if(!is_admin($current_user) && ((array_key_exists($tabdetailfieldid,$getUserNoTabDetailFieldsId)
                     &&!in_array($current_user->id,$getUserNoTabDetailFieldsId[$tabdetailfieldid]))))
                     {
                        //continue;
                         $field->setDetailsFieldsProfile('hidden','hidden','hidden');
                     }*/

                    if(in_array($tabdetailfieldid,$tabDetailFieldsProfile_array['fieldsid_array']) && empty($getUserNoTabDetailFieldsId[$tabdetailfieldid])){
                        //continue;
                        if($tabDetailFieldsProfile_array['fieldsprofile_info'][$tabdetailfieldid]['profilefieldtype'] == 'all'){

                        }else {
                            $field->setDetailsFieldsProfile('hidden', 'hidden', 'hidden');
                        }
                    }

                    if((array_key_exists($tabdetailfieldid,$getUserNoTabDetailFieldsId)
                            &&!in_array($current_user->id,$getUserNoTabDetailFieldsId[$tabdetailfieldid])))
                    {
                        //continue;
                        $field->setDetailsFieldsProfile('hidden','hidden','hidden');
                    }

                      if($columnname=='entitytypeid'&&empty($this->jsontabdetailfields['entitytype']))
                      {
                           $fieldinfo=new TabDetailToolFields();
                           $fieldinfo->setcolumnName("entitytype");
                           $fieldinfo->settypeOfData($field->getTypeOfData());
                           $fieldinfo->setTableName($field->getTableName());
                           $fieldinfo->setEdit_Permission($field->getEdit_permission());
                           $fieldinfo->setSaveDataBase($field->getSaveDataBase());
                           $fieldinfo->settranslatedModule($field->gettranslatedModule());
                           $fieldinfo->setinput_type(0);
                           $fieldinfo->setWidth(50);
                           $fieldinfo->setFieldType("entitytype");
                           $fieldinfo->setFieldName("entitytype");
                           $fieldinfo->setfieldLabel(getFixedLabel('SOURCETYPE'));
                           $fieldinfo->setBigType('entitytype');
                           $fieldinfo->setRelatedModuleField('no');
                           $fieldinfo->setSourceModule($field->getSourceModule());
                           $fieldinfo->setDetailsFieldsProfile($field->create_profile,$field->edit_profile,$field->details_profile);
                           $fieldinfo->set_ShowHyperlinks($field->get_ShowHyperlinks());
                           $this->tabPresenceDetailFields["entitytype"]=$fieldinfo;

                      }


                    $this->tabPresenceDetailFields[$columnname] = $field;
                    if($field->getNewLine() == 0 && ($field->getPresence() == 0 || $field->getPresence() == 2)){//0 表示第一行列
                        $key++;
                        //获取金额小计列(目前只有金额才进行小计)
                        //38211: 佣金单、费用报销单、自定义表单21-25，自定义单价字段，不应该显示小计
                        if($field->getFieldType() == 'Amount' ||$field->getFieldType() == 'RMB_Amount' || $field->getFieldType() == 'Num' || $field->getFieldType() == 'Number'  || $field->getFieldType() == 'Int'){
                            //dump($field);
                            if($field->getsubtotal_attr() == 'yes'){
                                $this->tabSubtotalField[$key] = $field->getColumnName();
                            }
                        }
                    }

				}
			}else{
				//不启用，并且有字段公式的字段
				if($field->getinput_type() == 2)
					$this->tabNoPresneceFormulaFields[$columnname] =$field;
				//所有不启用字段
				$this->tabNoPresenceDetailFields[$columnname] =$field;
			}
        }
		$this->setTabDetailFormulaFields();
	}
    public function getAllToolFields()
    {
            global $adb;
            $cachekey = 'TabDetailAllToolFields'.$this->tabid.$this->languageType;
            $this->alltabdetailfields=CacheDirectory($cachekey,'tabdetailfields');
            if($this->alltabdetailfields)
            {
                return $this->alltabdetailfields;
            }
            if(!is_array($this->alltabdetailfields))
            {
                $this->alltabdetailfields=[];
            }
            $module=getTabname($this->tabid);
            
             $query = 'select ld_tabdetailfield.tabdetailfieldid,columnname,width,presence,edit_permission,fieldtype,defaultvalue,
            			typeofdata,GROUP_CONCAT(ld_tranlabel.fieldlabel order by Tranlabelid asc SEPARATOR "||") as fieldlabel,tablename,input_type,newline ,defaultcolumn,formulastring,columnstring,fieldid,selectmodule,relation_columnname,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,fieldvaluecolor,fieldplaceholder,
                        parentbigtype,sourcemodule,mobiledetailshow,relatedmodulefield,showhyperlinks,ld_tabdetailfield.sequence,subtotal_attr,autowordwrap
            		from 
            			ld_tabdetailfield
            		LEFT JOIN ld_tranlabel on ld_tranlabel.relateid = ld_tabdetailfield.tabdetailfieldid and ld_tranlabel.tabid = ld_tabdetailfield.tabid 
            		left join ld_tabdetailfield_formula on ld_tabdetailfield_formula.tabdetailfieldid=ld_tabdetailfield.tabdetailfieldid
            		left join ld_tabdetailfield_relation on ld_tabdetailfield_relation.tabdetailfieldid = ld_tabdetailfield.tabdetailfieldid
            		where 
            			ld_tabdetailfield.tabid = ? 
            			and ld_tranlabel.trantable = ? ';
            if(!empty($this->sourceModulesql)){
                //$query .= ' and '.$this->sourceModulesql;
            }
            $query.=' GROUP BY ld_tabdetailfield.tabdetailfieldid order by ld_tabdetailfield.sequence asc';
    	//合计，小计
        $result = $adb->pquery($query,array($this->tabid,'ld_tabdetailfield'));
    	$num_rows = $adb->num_rows($result);
  
        
        for($i = 0; $i<$num_rows; $i++){
        			$presence = $adb->query_result($result,$i,'presence');
        			$tabdetailfieldid = $adb->query_result($result,$i,'tabdetailfieldid');
        			$input_type = $adb->query_result($result,$i,'input_type');
        			$fieldlabel_arr = explode('||',$adb->query_result($result,$i,'fieldlabel'));
        			$tabdetailfield[$i]['tabdetailfieldid'] = $tabdetailfieldid;
        			$TabDetailToolFields = new TabDetailToolFields();
        			$TabDetailToolFields->setTabDetailFieldid($tabdetailfieldid);
        			$TabDetailToolFields->setFieldName($adb->query_result($result,$i,'columnname'));
        			$TabDetailToolFields->setcolumnName($adb->query_result($result,$i,'columnname'));
        			$TabDetailToolFields->setTableName($adb->query_result($result,$i,'tablename'));
        			$TabDetailToolFields->setDefaultvalue($adb->query_result($result,$i,'defaultvalue'));
                    $fieldtype=$adb->query_result($result,$i,'fieldtype');
        			$TabDetailToolFields->setFieldType($adb->query_result($result,$i,'fieldtype'));
        			$TabDetailToolFields->settypeOfData($adb->query_result($result,$i,'typeofdata'));
        			$TabDetailToolFields->setEdit_Permission($adb->query_result($result,$i,'edit_permission'));
        			$TabDetailToolFields->setPresence($adb->query_result($result,$i,'presence'));
        			$TabDetailToolFields->setWidth($adb->query_result($result,$i,'width'));
        			$TabDetailToolFields->setdefaultColumn($adb->query_result($result,$i,'defaultcolumn'));
        			$TabDetailToolFields->setNewLine($adb->query_result($result,$i,'newline'));
        			$TabDetailToolFields->setinput_type($input_type);
        			$TabDetailToolFields->setFormulaString($adb->query_result($result,$i,'formulastring'));
        			$TabDetailToolFields->setColumnString($adb->query_result($result,$i,'columnstring'));
        			$TabDetailToolFields->setFieldid($adb->query_result($result,$i,'fieldid'));
        			$TabDetailToolFields->setSelectModule($adb->query_result($result,$i,'selectmodule'));
        			$TabDetailToolFields->setRelationColumnname($adb->query_result($result,$i,'relation_columnname'));
        			$TabDetailToolFields->setNullField($adb->query_result($result,$i,'nullfield'));

        			$TabDetailToolFields->setReferenceModule($adb->query_result($result,$i,'referencemodule'));
        			$TabDetailToolFields->setDataRang($adb->query_result($result,$i,'datarange'));
        			$TabDetailToolFields->setSaveDataBase($adb->query_result($result,$i,'savedatabase'));
        			$TabDetailToolFields->setFieldValueColor($adb->query_result($result,$i,'fieldvaluecolor'));
        			$TabDetailToolFields->setFieldPlaceholder($adb->query_result($result,$i,'fieldplaceholder'));
                    $TabDetailToolFields->setParentBigType($adb->query_result($result,$i,'parentbigtype'));
                    $TabDetailToolFields->setSourceModule($adb->query_result($result,$i,'sourcemodule'));
                    $TabDetailToolFields->setMobileDetailShow($adb->query_result($result,$i,'mobiledetailshow'));
                    $TabDetailToolFields->setRelatedModuleField($adb->query_result($result,$i,'relatedmodulefield'));
                    $TabDetailToolFields->set_ShowHyperlinks($adb->query_result($result,$i,'showhyperlinks'));
                    $TabDetailToolFields->setsubtotal_attr($adb->query_result($result,$i,'subtotal_attr'));
                    $TabDetailToolFields->setautowordwrap($adb->query_result($result,$i,'autowordwrap'));
        			$approve_demand = $adb->query_result($result,$i,'approve_demand');
        			if($approve_demand == 'approve'){
        				$approve_demand = 1;
        			}else{
        				$approve_demand = 0;
        			}
        			$TabDetailToolFields->set_approve_demand($approve_demand);
        			$TabDetailToolFields->setMaxRowsShow($adb->query_result($result,$i,'maxrowsshow'));
                    $bigtype=$adb->query_result($result,$i,'bigtype');
                    if(empty($bigtype))
                    {
                        if(strtolower($fieldtype)=='amount')
                            $bigtype='currency';
                        else if(strtolower($fieldtype)=='Date_Ymd')
                            $bigtype='date';
                        else if(strtolower($fieldtype)=='Num')
                            $bigtype='number';
                        else if(strtolower($fieldtype)=='select')
                            $bigtype='picklist';
                    }
        			$TabDetailToolFields->setBigType($bigtype);
        			if($adb->query_result($result,$i,'nullfield') == 0){
        				$this->module_nullfield[] = $adb->query_result($result,$i,'columnname');
        			}
        		 
        			if($this->languageType == 'zh')
        				$TabDetailToolFields->setfieldLabel($fieldlabel_arr[0]);
        			else
        				$TabDetailToolFields->setfieldLabel($fieldlabel_arr[1]);
        			$TabDetailToolFields->setFieldLabel_zh($fieldlabel_arr[0]);
        			$TabDetailToolFields->setFieldLabel_en($fieldlabel_arr[1]);
        			$TabDetailToolFields->setTranslatedModule(getTabModuleName($this->tabid) . 'Details');
                    $TabDetailToolFields->setSequence($adb->query_result($result,$i,'sequence'));

                    

                    $columnname = $TabDetailToolFields->getColumnName();
                    if(array_key_exists($columnname,$this->jsontabdetailfields)){
                        if(is_array($this->alltabdetailfields[$columnname])){
                            $this->alltabdetailfields[$columnname][]=$TabDetailToolFields;
                        }
                        else{
                            $beforetabdetailfields = $this->jsontabdetailfields[$columnname];
                            $this->alltabdetailfields[$columnname]=array();
                            if($module=='CashBill'||$module=='SendCashBill')
                            {
                                $this->alltabdetailfields[$columnname][]=$beforetabdetailfields;
                                $this->alltabdetailfields[$columnname][]=$TabDetailToolFields;
                            }
                            else{
                                $this->alltabdetailfields[$columnname] =$beforetabdetailfields;
                                $this->alltabdetailfields[$columnname] =$TabDetailToolFields;
                            }
                            
                        }
                    }
                    else{
                        
                        if($module=='CashBill'||$module=='SendCashBill')
                        {
                             $this->alltabdetailfields[$columnname][]=$TabDetailToolFields;
                        }
                        else{
                            $this->alltabdetailfields[$columnname]=$TabDetailToolFields;
                        }
        			  
                    }
            }
                CacheDirectory($cachekey,'tabdetailfields',$this->alltabdetailfields);
                
            return $this->alltabdetailfields;

    }
    public function setTabDetailFields_Bill()
    {
        global $current_user,$adb;
		
        $tabDetailField = array();
        $module=getTabname($this->tabid);
        $focus=CRMEntity::getInstance($module);
        $withdetail='';
 
        if(!empty($this->sourcemodulename))
        {
            $sourceModuleinfoarr=getSourceModule($module);
            foreach($sourceModuleinfoarr as $SourceInfo)
            {
                if($SourceInfo['entitytype']==$this->sourcemodulename)
                {
                    $withdetail=$SourceInfo['withdetail'];
                    break;
                }
            }
        }
        $columnseuqencearr = array();
        $resortsequence = 'no';
        $beforesequence = 0;

        if(($withdetail==''||$withdetail=='no')&&$withdetail!='yes')
        {
               
              
                $tabDetailFieldsProfile_array = $this->getTabDetailFieldsProfile($this->tabid);
                $this->alltabdetailfields=$this->getAllToolFields();
               
        		foreach($this->alltabdetailfields as $tabdetailfieldarr){
        		   
            		  foreach($tabdetailfieldarr as $tabdetailfieldinfo )
                      {
                        if($withdetail== 'no'&&!empty($this->sourcemodulename)&&$tabdetailfieldinfo->getSourceModule()!=$this->sourcemodulename){
                            continue; 
                        }
                                $tabdetailfieldid=$tabdetailfieldinfo->getTabDetailFieldid();
                                $TabDetailToolFields=$tabdetailfieldinfo;
                                //获取该字段 当前用户对应权限
                                if (in_array($tabdetailfieldid, $tabDetailFieldsProfile_array['fieldsid_array'])) {
                                    $tabDetailFieldsProfile = $tabDetailFieldsProfile_array['fieldsprofile_info'][$tabdetailfieldid];
            
                                    if ($tabDetailFieldsProfile['profilefieldtype'] == 'user') {
                                        $tabDetailFieldsProfile_data = $tabDetailFieldsProfile[$current_user->id];
                                    } elseif ($tabDetailFieldsProfile['profilefieldtype'] == 'role') {
                                        $tabDetailFieldsProfile_data = $tabDetailFieldsProfile[$current_user->profileid];
                                    } elseif ($tabDetailFieldsProfile['profilefieldtype'] == 'group'){
                                        $sql_group = "SELECT
                                                    CASE
                                                WHEN COUNT(p.create_profile = 'write' or NULL) >0 THEN
                                                    'write'
                                                WHEN COUNT(p.create_profile = 'read' or NULL) >0 THEN
                                                    'read'
                                                else 'hidden'
                                                END AS create_profile,
                                                    CASE
                                                WHEN COUNT(p.edit_profile = 'write' or NULL) >0 THEN
                                                    'write'
                                                WHEN COUNT(p.edit_profile = 'read' or NULL) >0 THEN
                                                    'read'
                                                else 'hidden'
                                                END AS edit_profile,
                                                    CASE
                                                WHEN COUNT(p.details_profile = 'write' or NULL) >0 THEN
                                                    'write'
                                                WHEN COUNT(p.details_profile = 'read' or NULL) >0 THEN
                                                    'read'
                                                else 'hidden'
                                                END AS details_profile
                                                FROM
                                                    ld_users2group g
                                                INNER JOIN ld_tabdetailprofile p ON g.groupid = p.userid
                                                WHERE
                                                    p.tabdetailfieldid = ?
                                                AND g.userid = ?
                                                ";
                                        $tmp_result_group = $adb->pquery($sql_group,array($tabdetailfieldid,$current_user->id));
                                        if($adb->num_rows($tmp_result_group) > 0){
                                            $tabDetailFieldsProfile_data = array('create_profile' => $adb->query_result($tmp_result_group,0,'create_profile'), 'edit_profile' => $adb->query_result($tmp_result_group,0,'edit_profile'),'details_profile' => $adb->query_result($tmp_result_group,0,'details_profile'));
                                        }else if($tabDetailFieldsProfile['profilefieldtype'] == 'all'){
                                            $tabDetailFieldsProfile_data = $tabDetailFieldsProfile[0];
                                        }
                                    }
            
                                    $TabDetailToolFields->setDetailsFieldsProfile($tabDetailFieldsProfile_data['create_profile'],$tabDetailFieldsProfile_data['edit_profile'],$tabDetailFieldsProfile_data['details_profile']);
                                } else {
                                    $TabDetailToolFields->setDetailsFieldsProfile('write', 'write', 'read');
                                }
                                $columnname=$TabDetailToolFields->getColumnName();
                                if(array_key_exists($columnname,$this->jsontabdetailfields)){
                                    if(is_array($this->jsontabdetailfields[$columnname])){
                                        $this->jsontabdetailfields[$columnname][]=$TabDetailToolFields;
                                    }
                                    else{
                                        $beforetabdetailfields = $this->jsontabdetailfields[$columnname];
                                        $this->jsontabdetailfields[$columnname]=array();
                                        $this->jsontabdetailfields[$columnname][]=$beforetabdetailfields;
                                        $this->jsontabdetailfields[$columnname][]=$TabDetailToolFields;
                                    }
                                }
                                else{
                    			   $this->jsontabdetailfields[$columnname][]=$TabDetailToolFields;
                                   if($TabDetailToolFields->getSequence()<$beforesequence){
                                       $resortsequence = 'yes';
                                   }
                                    $beforesequence = $TabDetailToolFields->getSequence();
                                    $columnseuqencearr[$columnname] = $TabDetailToolFields->getSequence();
                                }
                      }
        			
        		}
        }
       
		if(($withdetail==''||$withdetail=='yes')&&$withdetail!='no')
        {
                $module = getTabModuleName($this->tabid);
                //zkt 收付款单增加获取产品字段信息

                $productwithdetail = '';//默认获取产品分录

                crm_load_class_file('ProductToolFields','include/ProductDetails');
                 $productToolFieldsobj = ProductToolFields::getInstance($module);
                 if($withdetail=='yes')
                 {
                    $productToolFieldsobj->setsourceModulesqlwhere ($this->sourcemodulename);
                 }
                 else
                    $productToolFieldsobj->ResetBillEmpty();

                 $productToolFields = $productToolFieldsobj->getModuleProductToolField();

                $sourceModuleinfoarr=getSourceModule($module);

                foreach($sourceModuleinfoarr as $tmpindex=>$SourceInfo)
                {
                    $tmpSourceModulename = $SourceInfo['entitytype'];
                    $tmpwithdetail = $SourceInfo['withdetail'];

                    foreach($productToolFields as $tmpcolumnname=>$tmpproductobjs){
                            if($withdetail== 'no'&&!empty($this->sourcemodulename)&&$tmpproductobjs->getSourceModule()!=$this->sourcemodulename){
                                continue; 
                            }
                            if(!is_array($tmpproductobjs))
                            {
                                $this->jsontabdetailfields[$tmpcolumnname]=$tmpproductobjs;
                            }
                            else
                            foreach($tmpproductobjs as $tmpproductobj){
                                if($tmpproductobj->getSourceModule()==$tmpSourceModulename){
                                    $this->jsontabdetailfields[$tmpcolumnname][]=$tmpproductobj;
                                }
                            }
                     }

                }

        }
        //zkt 20231101 BUG0073881  	kfbcrm-收款单-源单选出库单，分录字段顺序与后台单据分录定制显示顺序不一致 
        if(!empty($this->sourcemodulename)&&!empty($columnseuqencearr)&&$resortsequence == 'yes'){
            $tmpjsontabdetailfields = $this->jsontabdetailfields;
            $diffarr = array_diff_key($tmpjsontabdetailfields, $columnseuqencearr);
            //两个数组没有差异才进行重新排序
            if(empty($diffarr)){
                $columnseuqencearr = array_flip($columnseuqencearr);
                ksort($columnseuqencearr);//根据关联数组的键，对数组进行升序排列
                $this->jsontabdetailfields = array_replace(array_flip($columnseuqencearr), $tmpjsontabdetailfields);
            }
        }



		$tabDetailField[$this->tabid] = $this->jsontabdetailfields;
	//	CacheDirectory($cachekey,'tabdetailfields',$tabDetailField);
        return $this->jsontabdetailfields;
    }
	public function setTabDetailFields() {
		global $current_user,$adb;
	
		//$tabDetailField = CacheDirectory($cachekey,'tabdetailfields');
        //23151: 客户明细界面：相关信息-费用报销，新建费用报销，结果【合计】【人民币金额】值错误
		if($this->jsontabdetailfields&&is_array($this->jsontabdetailfields)&&sizeof($this->jsontabdetailfields)>0){
		  return $this->jsontabdetailfields;

		}else{
			if(!$tabDetailField){
				$tabDetailField = array();
                $module=getTabname($this->tabid);
                if($module=='CashBill'||$module == 'SendCashBill'){
                    return $this->setTabDetailFields_Bill();
                }
                $focus=CRMEntity::getInstance($module);
				/*$query = 'select ld_tabdetailfield.tabdetailfieldid,columnname,width,presence,edit_permission,fieldtype,defaultvalue,
					typeofdata,GROUP_CONCAT(ld_tranlabel.fieldlabel order by Tranlabelid asc SEPARATOR "||") as fieldlabel,tablename,input_type,newline ,defaultcolumn,formulastring,columnstring,fieldid,selectmodule,relation_columnname,nullfield,referencemodule,datarange,approve_demand,maxrowsshow,bigtype,savedatabase,fieldvaluecolor,fieldplaceholder,
                    parentbigtype,sourcemodule,mobiledetailshow,relatedmodulefield,showhyperlinks
				from 
					ld_tabdetailfield
				LEFT JOIN ld_tranlabel on ld_tranlabel.relateid = ld_tabdetailfield.tabdetailfieldid and ld_tranlabel.tabid = ld_tabdetailfield.tabid 
				left join ld_tabdetailfield_formula on ld_tabdetailfield_formula.tabdetailfieldid=ld_tabdetailfield.tabdetailfieldid
				left join ld_tabdetailfield_relation on ld_tabdetailfield_relation.tabdetailfieldid = ld_tabdetailfield.tabdetailfieldid
				where 
					ld_tabdetailfield.tabid = ? 
					and ld_tranlabel.trantable = ?  GROUP BY ld_tabdetailfield.tabdetailfieldid order by ld_tabdetailfield.sequence asc';
				//合计，小计
                $result = $adb->pquery($query,array($this->tabid,'ld_tabdetailfield'));
				$num_rows = $adb->num_rows($result);*/
                $this->alltabdetailfields=$this->getAllToolFields();

                $tabDetailFieldsProfile_array = $this->getTabDetailFieldsProfile($this->tabid);


				foreach($this->alltabdetailfields as $tabdetailfieldinfo){
					 
					$tabdetailfieldid = $tabdetailfieldinfo->getTabDetailFieldid();
				     $TabDetailToolFields=$tabdetailfieldinfo;
                    $columnname=$tabdetailfieldinfo->getColumnName();
                    //获取该字段 当前用户对应权限
                    if (in_array($tabdetailfieldid, $tabDetailFieldsProfile_array['fieldsid_array'])) {
                        $tabDetailFieldsProfile = $tabDetailFieldsProfile_array['fieldsprofile_info'][$tabdetailfieldid];

                        if ($tabDetailFieldsProfile['profilefieldtype'] == 'user') {
                            $tabDetailFieldsProfile_data = $tabDetailFieldsProfile[$current_user->id];
                        } elseif ($tabDetailFieldsProfile['profilefieldtype'] == 'role') {
                            $tabDetailFieldsProfile_data = $tabDetailFieldsProfile[$current_user->profileid];
                        } elseif ($tabDetailFieldsProfile['profilefieldtype'] == 'group'){
                            $sql_group = "SELECT
                                        CASE
                                    WHEN COUNT(p.create_profile = 'write' or NULL) >0 THEN
                                        'write'
                                    WHEN COUNT(p.create_profile = 'read' or NULL) >0 THEN
                                        'read'
                                    else 'hidden'
                                    END AS create_profile,
                                        CASE
                                    WHEN COUNT(p.edit_profile = 'write' or NULL) >0 THEN
                                        'write'
                                    WHEN COUNT(p.edit_profile = 'read' or NULL) >0 THEN
                                        'read'
                                    else 'hidden'
                                    END AS edit_profile,
                                        CASE
                                    WHEN COUNT(p.details_profile = 'write' or NULL) >0 THEN
                                        'write'
                                    WHEN COUNT(p.details_profile = 'read' or NULL) >0 THEN
                                        'read'
                                    else 'hidden'
                                    END AS details_profile
                                    FROM
                                        ld_users2group g
                                    INNER JOIN ld_tabdetailprofile p ON g.groupid = p.userid
                                    WHERE
                                        p.tabdetailfieldid = ?
                                    AND g.userid = ?
                                    ";
                            $tmp_result_group = $adb->pquery($sql_group,array($tabdetailfieldid,$current_user->id));
                            if($adb->num_rows($tmp_result_group) > 0){
                                $tabDetailFieldsProfile_data = array('create_profile' => $adb->query_result($tmp_result_group,0,'create_profile'), 'edit_profile' => $adb->query_result($tmp_result_group,0,'edit_profile'),'details_profile' => $adb->query_result($tmp_result_group,0,'details_profile'));
                            }
                        }else if($tabDetailFieldsProfile['profilefieldtype'] == 'all'){
                            $tabDetailFieldsProfile_data = $tabDetailFieldsProfile[0];
                        }

                        $TabDetailToolFields->setDetailsFieldsProfile($tabDetailFieldsProfile_data['create_profile'],$tabDetailFieldsProfile_data['edit_profile'],$tabDetailFieldsProfile_data['details_profile']);
                    } else {
                        $TabDetailToolFields->setDetailsFieldsProfile('write', 'write', 'read');
                    }

                    $this->jsontabdetailfields[$columnname]=$TabDetailToolFields;
				}
				$tabDetailField[$this->tabid] = $this->jsontabdetailfields;
				
			}
			$this->jsontabdetailfields=$tabDetailField[$this->tabid];

            return $this->jsontabdetailfields;
		}
	}
	//设置所有能看到的字段和隐藏并且有字段公式的字段
	public function setTabDetailFormulaFields(){
        $i = 0;
       //edit:can $this->execsetTabDetailFun:自定义表单隐藏所有分录字段，会有死循环
        if(empty($this->tabPresenceDetailFields)&&$this->execsetTabDetailFun=='no')
        {
            $this->setDetailFields();
        }

		foreach($this->tabPresenceDetailFields as $columnname => $field){
			$tabDetailFormulaFields[$i]['producttoolfieldid'] =$field->getTabDetailFieldid();
			$tabDetailFormulaFields[$i]['columnname'] = $field->getColumnName();
			$tabDetailFormulaFields[$i]['typedata'] = $field->getTypeOfData();
			$tabDetailFormulaFields[$i]['width'] = $field->getWidth();
			$tabDetailFormulaFields[$i]['edit_permission'] = $field->getEdit_Permission();
			$tabDetailFormulaFields[$i]['defaultvalue'] = $field->getDefaultvalue();
			$tabDetailFormulaFields[$i]['fieldtype'] = $field->getFieldType();
			$tabDetailFormulaFields[$i]['fieldlabel'] = $field->getfieldLabel();
			$tabDetailFormulaFields[$i]['tablename'] = $field->getTableName();
			$tabDetailFormulaFields[$i]['input_type'] = $field->getinput_type();
			$tabDetailFormulaFields[$i]['newline'] = $field->getNewLine();
			$tabDetailFormulaFields[$i]['defaultcolumn'] = $field->getDefaultColumn();
			$tabDetailFormulaFields[$i]['columnstring']=htmlspecialchars_decode($field->getColumnString());
			$tabDetailFormulaFields[$i]['formulastring']=htmlspecialchars_decode($field->getFormulaString());
			$tabDetailFormulaFields[$i]['relation_columnname']=$field->getRelationColumnname();
            $tabDetailFormulaFields[$i]['subtotal_attr']=$field->getsubtotal_attr();
            $tabDetailFormulaFields[$i]['auto_wordwrap']=$field->getautowordwrap();
			$i++;
		}
		$this->tabDetailFormulaFields = $tabDetailFormulaFields;
	}
	public function getTabDetailFieldInfo($tabdetailfieldid) {
		foreach($this->tabDetailFieldsAll as $key => $fieldinfo){
			if($fieldinfo['tabdetailfieldid'] == $tabdetailfieldid){
				$typeofdata = explode('~',$fieldinfo);
				$fieldinfo['typedata'] = $typeofdata[1];
				//升级文本类型
				if($typeofdata[2] == 'LE'){
					$length = $typeofdata[3];
				}else{
					$length = $typeofdata[2];
				}
				if($fieldinfo['uitype'] == 10 || $fieldinfo['uitype'] == 20){//数字和数量取精度
					$len = explode(',',$length);
					$length = $len[1];
				}
			}
		}
		$fieldinfo['setuitype'] = $fieldinfo['uitype'];
		$fieldinfo['uitypeoption'] = $fieldinfo['uitype'];
		$fieldinfo['length'] = $length;
		return $fieldinfo;
	}
    public function getFieldInfoBykeyValue($key,$value,$retkey)
    {
      $jsonfields=  $this->getTabDetailFields();
       if($key=='columnname')
       {
        return $jsonfields[$value]->getTableName();

       }

       foreach($allfields as $columnname=>$fieldinfo)
       {
           if($fieldinfo[$key]==$value)
           {
            return $fieldinfo[$retkey];
           }
       }

    }
    public function getFieldInfoobjBykey($key,$value)
    {
        if($key!='columnname')
        {
            $value=$this->getFieldInfoBykeyValue($key,$value,'columnname');

        }


        $tabdetailfieldinfos=$this->getTabDetailFields();
		foreach($tabdetailfieldinfos as $field){
			if($field->getColumnName() == trim($value)){
				return $field;
			}
		}
    }
    //zkt 20220620 BUG0053020 	http://60.247.158.183:85/crm；四川中卉，新建【付款单】页面会有转圈
    public function getModuleAllPreseneceFields()
    {
        return $this->getModuleProductToolField();

    }
	public function getListSearchFields()
	{
		return $this->getModuleProductToolField();
	}
    public function getModuleProductToolField()
    {
        return $this->getTabPresenceDetailFields();
    }
     public function getFieldListArray()
    {
        crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
         $this->module=getTabname($this->tabid);

        $this->detailfieldruleobj=cls_detailfieldrule::getInstance($this->module);

        $fieldrulecolsproperty= $this->detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项
        $fieldrulerequirecolumn_arr=$fieldrulecolsproperty['requiredcolumns'];
        $tabPresenceDetailFields=$this->getTabPresenceDetailFields();
        //edit:can 2020-11-18 043326: （https://61mis.com/WX/kh40954 [^]）新建费用报销单，在填完内容之后点击保存，序时簿中看不到项目类别的内容；点击编辑-费用报销单明细中之前输入的内容不会显示。
        foreach($tabPresenceDetailFields as $fieldname=>$fieldinfo)
        {
            $typeofdatas=explode("~",$fieldinfo->getTypeOfData());

            if(is_array($fieldrulerequirecolumn_arr)&&in_array($fieldname,$fieldrulerequirecolumn_arr))
            {
                $typeofdatas[1]="M";

            }
			$uitype = $fieldinfo->getUIType();
			if (strtolower($fieldinfo->getBigType()) == 'image') {
				$uitype = 69;//ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(非产品分录模块没有uitype，但是上传文件类有用到，为了简化特殊判断，故在此返回uitype)
			}
            if (strtolower($fieldinfo->getBigType()) == 'fileattachment') {
                $uitype = 1109;//edit:xll 2023/06/30 XUQIU1000357 单据分录定制，增加“附件”字段类型(返回uitype)
            }
            $arr[]=array('uitype'=>$uitype,'fieldlabel'=>$fieldinfo->getFieldLabel()
                        ,'fieldname'=>$fieldname,'columnname'=>$fieldinfo->getColumnName()
                        ,'fieldonly'=>$fieldinfo->getfieldOnly(),'fieldtype'=>$fieldinfo->getFieldType()

                    ,'typeofdata'=>implode("~",$typeofdatas),'allowedit'=>$fieldinfo->get_allowedit()
				,'allowcreate'=>$fieldinfo->get_allowcreate(),'allowcreate_presence'=>$fieldinfo->get_allowcreate_presence()
                ,'tablename'=>$fieldinfo->getTableName(),'bigtype'=>$fieldinfo->getBigType(),'relatedmodulefield'=>$fieldinfo->getRelatedModuleField()
                ,'fieldvaluecolor'=>$fieldinfo->getFieldValueColor(),'ShowHyperlinks'=>$fieldinfo->get_ShowHyperlinks(),
                'fieldplaceholder'=>$fieldinfo->getFieldPlaceholder(),'edit_permission'=>$fieldinfo->getEdit_permission()
			);

        }
        return $arr;
    }
    public function getModuleFields()
    {
        return $this->getTabDetailFields();
    }
	/**
	 *
	 * @param
	 * @return
	 * @author Chj
	 */
	 //'columnname',$this->columnname
	public function getTabDetailFieldInfoobjBykey($tabdetailid,$value){
		$tabdetailfieldinfos=$this->getTabDetailFields();
		foreach($tabdetailfieldinfos as $field){
			if($field->getTabDetailFieldid() == trim($value)){
				return $field;
			}
		}
	}
	//获取用户无法查看到当前模块下的所有自定义字段
	public function getUserNoTabDetailFieldsId(){
		global $current_user,$adb;
		$cachekey = 'getUserTabDetailFields_'.$this->tabid;
		$userTabDetail = Cache($cachekey);
        
       // file_put_contents(globalStatic::$root_directory.'include/TabDetailFields/a.txt',2,FILE_APPEND);
	//	if(!$userTabDetail){
	   //edit:can 20200825 4.单据分录数据权限控制，支持按照“角色控制”
			$query = 'select ld_tabdetailprofile.tabdetailfieldid,ld_tabdetailprofile.userid from ld_tabdetailprofile where tabid = ? and profilefieldtype="user"
                union all select ld_tabdetailprofile.tabdetailfieldid,ld_users.id as userid  from ld_tabdetailprofile
                 inner join ld_profile on ld_profile.profileid=ld_tabdetailprofile.userid and profilefieldtype="role"
                 inner join ld_users on ld_users.profileid= ld_profile.profileid where tabid = ?
				 union all select ld_tabdetailprofile.tabdetailfieldid,ld_users2group.userid as userid  from ld_tabdetailprofile
				inner join ld_groups on ld_groups.groupid=ld_tabdetailprofile.userid and profilefieldtype="group"
				inner join ld_users2group on ld_users2group.groupid= ld_groups.groupid where tabid = ?
				 ';
			$result = $adb->pquery($query,array($this->tabid,$this->tabid,$this->tabid));
			$num_rows = $adb->num_rows($result);

			$userTabDetail = Array();
			for($i = 0; $i<$num_rows; $i++){
				$tabdetailfieldid=$adb->query_result($result,$i,'tabdetailfieldid');
		      	$data[$tabdetailfieldid][] = $adb->query_result($result,$i,'userid');
			}
			$userTabDetail=$data;
			Cache($cachekey,$data);
		//}

		return $userTabDetail;
	}

    /**
     * 根据当前用户ID和当前模块ID，获取用户对应模块分录的权限
     * @param $tabid:当前选中模块ID
     * @return
     * @author hzx 2023/5/29
     */
    static function getTabDetailFieldsProfile($tabid){
        global $adb,$current_user;
       
        $profile_scope_array = [];
        $profile_fieldid_array = [];
       // $cachkey="tabdetailprofile".$tabid;
       // $profilefields=Cache($cachkey);
        //if($profilefields)
          //  return $profilefields;
          //不允許加緩存 非管理員創建該緩存，然後管理員使用非管理的字段權限
         
        //if(!is_admin($current_user)){
            $sql = "SELECT tabdetailfieldid,userid,profilefieldtype,create_profile,edit_profile,details_profile FROM ld_tabdetailprofile
             WHERE tabid = ? and presence = 1 ";
            $result = $adb->pquery($sql,array($tabid));
            if($adb->num_rows($result) > 0){
                $profile_scope_array = [];
                for($i = 0;$i<$adb->num_rows($result);$i++){
                    $profile_scope_array[$adb->query_result($result,$i,'tabdetailfieldid')]['profilefieldtype'] = $adb->query_result($result,$i,'profilefieldtype');
                    $profile_scope_array[$adb->query_result($result,$i,'tabdetailfieldid')][$adb->query_result($result,$i,'userid')] = array(
                        'create_profile'=>$adb->query_result($result,$i,'create_profile'),
                        'edit_profile'=>$adb->query_result($result,$i,'edit_profile'),
                        'details_profile'=>$adb->query_result($result,$i,'details_profile')
                    );
                    $profile_fieldid_array[$adb->query_result($result,$i,'tabdetailfieldid')] = $adb->query_result($result,$i,'tabdetailfieldid');
                }
            }
        //}
       // Cache($cachkey,array('fieldsprofile_info'=>$profile_scope_array,'fieldsid_array'=>$profile_fieldid_array));
        return array('fieldsprofile_info'=>$profile_scope_array,'fieldsid_array'=>$profile_fieldid_array);
    }



	public function object_to_array($obj){
		$_arr = is_object($obj) ? get_object_vars($obj) :$obj;
		foreach ($_arr as $key=>$val){
			$val = (is_array($val) || is_object($val)) ? $this->object_to_array($val):$val;
			$arr[$key] = $val;
		}
		return $arr;
	}
}
?>
