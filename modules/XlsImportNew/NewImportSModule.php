<?php
/**
*@another :      Andrew
*@date :         2014-07-24
*@brief :        XLS格式导入类文件
**/

include('user_privileges/user_language_'.$current_user->id.'.php');

class NewImport_Xls {
    private $importColumnname_indexarr;
    private $objexcel;
    public $import_nouitype='';
    public $importmodule;
    public $iskehu001;
    public $port_obj;
    public function __construct($importColumnname_indexarr,$module)
    {
        $this->importColumnname_indexarr=$importColumnname_indexarr;
       $this->importmodule=$module;
       $this->iskehu001=isKehu001ServerPc();
       $this->port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 D
        
    }
    /**
    *@description :获取导入模块的ld_field字段内容
    *@param :$cImportModule#模块名
    *@param :$moduleid#模块ID
    */
    function getInputFileName($cImportModule,$moduleid){
        
        global $adb,$current_user,$languageType;
        require('user_privileges/user_language_'.$current_user->id.'.php');
        
        $SQL = "select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,
                ld_field.columnname,tablename ,fieldonly,ld_field.fieldname,ld_field.is_checkimportfield
                from ld_field 
                inner join ld_blocks on ld_blocks.blockid=ld_field.block 
                inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
                inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
                where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
                and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
                and presence in(0,2) and ld_blocks.visible=0
                order by ld_blocks.sequence, ld_field.sequence ";
                
        $result=$adb->pquery($SQL,array($languageType,'ld_field',$moduleid,$languageType,'ld_blocks',$moduleid));
        //print_r($result);
        $defaultvalueHtml='';
        $rArrList=array();
        $rArrList['importcolumn'][]=array(0,'none-field','--无--');
        
        for($i=0;$i<$adb->num_rows($result);$i++){
            $uitype=$adb->query_result($result,$i,'uitype');
            $columnname=$adb->query_result($result,$i,'columnname');
            $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
            $typeofdata=$adb->query_result($result,$i,'typeofdata');
            $fieldonly=$adb->query_result($result,$i,'fieldonly');
            $tablename=$adb->query_result($result,$i,'tablename');
            $fieldname=$adb->query_result($result,$i,'fieldname');
            $is_checkimportfield = $adb->query_result($result,$i,'is_checkimportfield');
            $rArrList['sessionMainfield'][$i]['uitype']=$uitype;
            $rArrList['sessionMainfield'][$i]['columnname']=$columnname;
            $rArrList['sessionMainfield'][$i]['fieldlabel']=$fieldLabel;
            $rArrList['sessionMainfield'][$i]['typeofdata']=$typeofdata;
            $rArrList['sessionMainfield'][$i]['fieldonly']=$fieldonly;
            $rArrList['sessionMainfield'][$i]['tablename']=$tablename;
            
            $typedata=explode('~',$typeofdata);
            $rArrList['sessionMainfield'][$i]['is_checkimportfield']=$is_checkimportfield;
            /**
            andrew
            系统编号如果没有，则自动生成，改成非必选
            */
            //if($typedata[1]=='M'&&$uitype!=4){
            if($typedata[1]=='M'){
                $fieldLabel.='*';
            }
            
            if($uitype==15 ||$uitype==33){
                $profileid=$current_user->profileid;
                crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
                $picklistdrop = getAssignedPicklistValues($fieldname, $profileid, $adb);
                $rArrList['drophtml'][$columnname.'-field']=$picklistdrop;
            }
            
            $rArrList['importcolumn'][]=array($uitype,$columnname.'-field',trim($fieldLabel));
        }
        
        return $rArrList;
    }
    
    /**
    *@description :获取导入内容的列头和第一行
    *@param :$importcolumn#ld_field中相关模块的字段
    *@param :$currentModule#导入的文件名(/storage中的文件的名字)
    */
    function getPhpExcelTableHead($importcolumn,$inputFileName){
        
        include 'PHPExcel/PHPExcel/IOFactory.php';
        $inputFileType = 'Excel5';       
        $rArrList=array();        
        $objReader = PHPExcel_IOFactory::createReader($inputFileType);
        $objPHPExcel = $objReader->load($inputFileName);
        $objPHPExcel->setActiveSheetIndex(0);
        $objWorksheet = $objPHPExcel->getActiveSheet();//
    
        $highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
        $highestColumn = $objWorksheet->getHighestColumn();
        $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数

        for ($col = 0;$col < $highestColumnIndex;$col++){
            $uitype=0;
            $columnname='';
            $objvalue0= trim($objWorksheet->getCellByColumnAndRow($col, $highestRow[1])->getValue());  
            if($objvalue0==""){
                break;
            }
        
            $objvalue1= trim($objWorksheet->getCellByColumnAndRow($col, $highestRow[2])->getValue());  
			//echo $objvalue0;echo '<br><br>';
			
            foreach($importcolumn as $cols){
                if(in_array($objvalue0,$cols)||in_array($objvalue0.'*',$cols)){
                    $uitype=$cols[0];
                    $columnname=$cols[1];
                    $rArrList['selcolumnName'][$columnname]=''; 
                }
            }
			//税别 无法导入：特殊处理
			if($columnname == 'none-field' && getInventoryTaxId($objvalue0) > 0)
			{
				$columnname = 'taxclass-field';
			}
            $rArrList['objstr'][$col]=array($objvalue0,$objvalue1,$uitype,$columnname);      
        }
        return $rArrList;
    }
    
    /**
    *@description :删除上传的XLS文件
    *@param :$currentModule#导入的文件名(/storage中的文件的名字)
    */
    function clearImportFile($currentModule){
        return @unlink ("storage/".$currentModule.".xls");
    }
	/**
     * 导crm_产品,返回产品ID
     * */
	public function insertIntoProducts($str,$excelrowIndex,$hrefcolumnname){
		global $adb,$current_user;
		$focus=CRMEntity::getInstance('Products');
		if($hrefcolumnname != 'productid' || $str == ''){
			return 0;
		}
		if(isset($str)){
			$focus->column_fields['productname']=$str;
			$focus->column_fields['assigned_user_id']=$current_user->id;
			$focus->column_fields['creator']=$current_user->id;
           // $focus->column_fields['discontinued']=1;
			$focus->id=0;
			$focus->mode='create';
			$focus->save('Products');
            $sql='update ld_products set discontinued=1 where productid=?';
            $adb->pquery($sql,array($focus->id));
			return $focus->id;
		}
	}
	/**
	 * edit:chj
	 * date:2020-07-15
	 * 导入供应商,返回供应商ID
	 */
	public function insertIntoVendor($str,$excelrowIndex,$hrefcolumnname) {
		global $adb,$current_user;
        if(trim($str)=='')
        {
            return '';
        }
		$focus=CRMEntity::getInstance('Vendors');
		$focus->column_fields['vendorname'] = $str;
		$focus->column_fields['assigned_user_id']=$current_user->id;
		$focus->column_fields['creator']=$current_user->id;
		$focus->id=0;
		$focus->mode='create';
        $focus->Imoportsave='yes';
		$focus->save('Vendors');
        if(empty($focus->id)){
            $this->errormsg = $focus->saveerrormsg;
        }
		return $focus->id;
	}
    /**
     * 导入客户,返回客户ID
     * */
    public function insertIntoAccount($str,$excelrowIndex,$hrefcolumnname)
    {
        global $adb,$current_user;
        $iskehu001=$this->iskehu001;
        $port_obj=$this->port_obj;
        $focus=CRMEntity::getInstance('Accounts');
        if($hrefcolumnname=='account_no')
        {
            return 0;
        }
        if(trim($str)=='')
        {
            return '';
        }
        $focus->column_fields['accountname']=$str;
        static $userids;
      
        if($this->importColumnname_indexarr['smownerid']>0)
         {
            $tmpusername=$_SESSION['import_'.$this->importmodule.'_'.$current_user->id.'_data'][$excelrowIndex][$this->importColumnname_indexarr['smownerid']];
            
            
            if(array_key_exists($tmpusername,$userids))
            {
                $focus->column_fields['assigned_user_id']=$userids[$tmpusername];
                
            }
            else
            {
                if($iskehu001=='yes'){
                     $sql='select id  from ld_users where wx_userid=? and deleted=0 ';
             
                  //   $result=$adb->pquery($sql,array($tmpusername));
                     
                     $wx_userarr =$port_obj->getwxUserid('eq',$tmpusername);
                    if(array_key_exists('userid',$wx_userarr))
                    {
                            $wx_userid=$wx_userarr['userid'][0];
                          $result=$adb->pquery($sql,array($wx_userid));
                    }
                    else{
                               
                    }
                }
                else
                {
                     $sql='select id  from ld_users where last_name=? and deleted=0 ';
             
                     $result=$adb->pquery($sql,array($tmpusername));
                }
            
                if($result&&$adb->num_rows($result)>0)
                    $Id=$adb->query_result($result,0,0);
                else
                    $Id=$current_user->id;
                $userids[$tmpusername]=$Id;
                //Liver 2017-04-25.bug0027731: 客户服务单：导入客户服务单文件中的客户名称系统中不存在，导入后，自动生成的客户单据销售负责人为空
                $focus->column_fields['assigned_user_id']=$Id;
            }
           
         }   
        else
        {
            $focus->column_fields['assigned_user_id']=$current_user->id;
        }
       
        if($this->importColumnname_indexarr['smcreatorid']>0)
        {
            $tmpusername=$_SESSION['import_'.$this->importmodule.'_'.$current_user->id.'_data'][$excelrowIndex][$this->importColumnname_indexarr['smcreatorid']];
            
            if(array_key_exists($tmpusername,$userids))
            {
                $focus->column_fields['creator']=$userids[$tmpusername];
                
            }
            else
            {
                 if($iskehu001=='yes'){
                     $sql='select id  from ld_users where wx_userid=? and deleted=0 ';
             
                     //$result=$adb->pquery($sql,array($tmpusername));
                     
                     $wx_userarr =$port_obj->getwxUserid('eq',$tmpusername);
                    if(array_key_exists('userid',$wx_userarr))
                    {
                            $wx_userid=$wx_userarr['userid'][0];
                          $result=$adb->pquery($sql,array($wx_userid));
                    }
                    else{
                               
                    }
                }
                else
                {
                     $sql='select id  from ld_users where last_name=? and deleted=0 ';
             
                     $result=$adb->pquery($sql,array($tmpusername));
                }
                if($result&&$adb->num_rows($result)>0)
                    $Id=$adb->query_result($result,0,0);
                else
                    $Id=$current_user->id;
                $userids[$tmpusername]=$Id;
            }
        }    
        else
        {
           
            $focus->column_fields['creator']=$current_user->id;
        }
      
        $focus->id=0;
        $focus->mode='create';
        $focus->Imoportsave='yes';
        //zkt 20220608 52517(http://erp.zonergy.com:85/crm/)(客户问题-龙卫东）销售合同导入时一直提示销售经理不能为空报错
        //导入单据客户不存在时，新增客户：若客户存在必填字段且值为空，则不导入客户
        foreach($focus->column_fields as $tmpfieldname=>$tmpfieldvalue)
        {
            $tmpfieldinfoobj = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$tmpfieldname);
            if(!empty($tmpfieldinfoobj))
            {
                $tmptypeofdata = $tmpfieldinfoobj->getTypeOfData();
                $tmpuitype = $tmpfieldinfoobj->getUIType();
                $tmpdefaultvalue = $tmpfieldinfoobj->getDefaultvalue();
                if($tmpuitype == 4){//单据编号字段保存时赋值
                    continue;
                }
                //字段值为空，但有默认值时，给字段赋默认值
                if(empty($tmpfieldvalue)&&!empty($tmpdefaultvalue))
                {
                    $tmpfieldvalue = $tmpdefaultvalue;
                    $focus->column_fields[$tmpfieldname] = $tmpfieldvalue;
                }
                //字段必填，但对应值为空时不保存客户值
                if(stripos($tmptypeofdata,'~m')===false)
                {
                    
                }
                else{
                    if(empty($tmpfieldvalue))
                    {
                        return $focus->id;
                    }
                }
            }
        }
        $focus->save('Accounts');
        if(empty($focus->id)){
            $this->errormsg = $focus->saveerrormsg;
        }
       
        return $focus->id;
    }
	/** chj 2021/1/27 
    *@description :将导入字段转成ID
    *@param :$fieldinfo 字段对象 ，$str 导入的值
    */
	public function setImprtNameToId_details($fieldinfo,$str,$excelrowIndex='0'){
		global $adb,$currentModule;
		if($fieldinfo->getBigType() == 'reference'){
			$fld_module = $fieldinfo->getReferenceModule();
			if(!empty($fld_module)){
				$focus=CRMEntity::getInstance($fld_module);
				$entityname=getEntitynameByModulename($fld_module);
				$fieldname=$entityname['fieldname'];
				$tablename=$entityname['tablename'];
				$entityidfield=$entityname['entityidfield'];
				$query = 'select  '.$tablename.'.'.$entityidfield.' from '.$tablename;
				if(strtolower($focus->table_name) != strtolower($tablename)){
					$query .= " left join " . $focus->table_name . ' on ' . $focus->table_name . '.' . $focus->table_index .'='.$tablename.'.'.$focus->table_index;
				}
				$query .= " where deleted=0 and $fieldname = '$str' limit 0,1";
				$fieldResult=$adb->pquery($query,array());
				if($adb->num_rows($fieldResult)>0){
					$str=$adb->query_result($fieldResult,0,0);
				}else{
					$str = 0;
				}
			}
		}
		return $str;
	}
    /**
    *@description :将导入字段转成ID,如果有新模块添加导入功能，需要在这里添加转换字段
    *@param :$uitype大家都懂的
    *@param :$str中文字段
    */
    function setImprtNameToId($uitype,$str,$excelrowIndex='0'){
        global $adb,$currentModule,$current_user;
        static $importAccount,$importUsers,$importProducts;
        //duan 20230911 导入时增加为空判断，例如存在客户名称为空的单据，则导入空时会关联到该单据
        if(empty($str)){
            return $str;
        }
        if($uitype!=70){
           // $str=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$str);
        }   
       $this->import_nouitype='no';
       
        $uitypemodules=cls_module_uitype::getUitypeModules();
        $multireferenceuitypemodules=cls_module_uitype::getMultiReferenceUitype();

        switch($uitype){
            case 173:
            case 51://上级单位
            case 73://客户名称
                if(is_array($importAccount)&& array_key_exists($str,$importAccount))
                {
                    $str=$importAccount[$str];
                    
                }
                else
                {
                     $entityname=getEntitynameByModulename('Accounts');
                    $fieldname=$entityname['fieldname'];
                    $tablename=$entityname['tablename'];
                    $entityidfield=$entityname['entityidfield'];
                    //zkt 20220621 BUG0053347导入联系人是，联系人无法归集到对应客户，
                    $tmpfocus = CRMEntity::getInstance('Accounts');
                    $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                    if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                        $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                    }
                    $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                    $fieldResult=$adb->pquery($sqlfield,array($str));
                    if($adb->num_rows($fieldResult)>0){
                        $importAccount[$str]=$adb->query_result($fieldResult,0,0);
                        $str=$adb->query_result($fieldResult,0,0);
                        
                    }else{
                       
                        
                        if($this->importColumnname_indexarr!=''){
                          
                           $strid=$this->insertIntoAccount($str,$excelrowIndex,$entityidfield);
                           $importAccount[$str]=$strid;
                           $str=$strid;
                        }else{
                            $str=0;
                        }
                    }
                }
               
                                 
                break;
            case 59://意向产品
                if(isset($importProducts[$str]))
                {
                    $str=$importProducts[$str];
                }
                else
                {
                    $entityname=getEntitynameByModulename('Products');
                    $fieldname=$entityname['fieldname'];
                    $tablename=$entityname['tablename'];
                    $entityidfield=$entityname['entityidfield'];
                    $tmpfocus = CRMEntity::getInstance('Products');
                    $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                    if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                        $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                    }
                    $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                    $fieldResult=$adb->pquery($sqlfield,array($str));
                    if($adb->num_rows($fieldResult)>0){
                        $importProducts[$str]=$adb->query_result($fieldResult,0,0);
                        $str=$adb->query_result($fieldResult,0,0);
                    }else{
						$str=$this->insertIntoProducts($str,$excelrowIndex,$entityidfield);
                    }
                }
                
                
                break;
            case 151:
                $tmpsql='select * from ld_warehouse  where  status=0 and name=?';  
                    
                $tmpresult=$adb->pquery($tmpsql,array($str));
                $str=$adb->query_result($tmpresult,0,0);
                break;
            case 70:
               if(empty($str))
               {
                    $str=date('Y-m-d H:i:s',time());
               }
               break;
            case 131:
                if(array_key_exists($str,$importUsers))
                {
                    $importUsers[$str]=$str;
                }
                else
                {
                    $sqlfield='select id from ld_users where deleted=0 and  last_name=?  order by id desc limit 0,1';
                    $fieldResult=$adb->pquery($sqlfield,array($str));
                    if($adb->num_rows($fieldResult)>0){
                        $importUsers[$str]=$adb->query_result($fieldResult,0,0);
                        $str=$adb->query_result($fieldResult,0,0);
                    }else{
                        $importUsers[$str]=0;
                        $str=0;
                    } 
                }
               
                break;     
            case 102:
                $entityname=getEntitynameByModulename('SalesOrder');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $entityname2=getEntitynameByModulename('ServiceContracts');
                $fieldname2=$entityname2['fieldname'];
                $tablename2=$entityname2['tablename'];
                $entityidfield2=$entityname2['entityidfield'];

                $sqlfield="SELECT salesorderid,'SalesOrder' AS type FROM ".$tablename." WHERE deleted=0 and ".$fieldname."='$str' UNION 
                    SELECT servicecontractsid AS salesorderid,'ServiceContracts' AS type FROM ".$tablename2." WHERE deleted=0 and ".$fieldname2."='$str'";
                
                $fieldResult=$adb->pquery($sqlfield,array());
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,'salesorderid');
                }else{
                    $str=0;
                }
                break;   
            case 152:
            case 180:
         
                      $strs=explode('|##|',$str);
                      foreach($strs as $index=>$groupname)
                      {
                        $groupnames.="'".trim($groupname)."',";
                      }
                      
                      $groupnames=trim($groupnames,',');
                     
                        if($groupnames!='')
                        {
                            $sql='select GROUP_CONCAT(groupid) as groupids from ld_groups where groupname in('.$groupnames.')';
                            $result=$adb->pquery($sql,array());
                           
                            if($adb->num_rows($result)>0)
                            {
                                return $adb->query_result($result,0,0);
                            }
                            else
                            {
                                return "";
                            }
                        }
                        else
                        {
                            return "";
                        }
                      break;
            case 53:
            case 52:
            case 153:
                if(is_array($importUsers)&& array_key_exists($str,$importUsers))
                {
                   
                   return $importUsers[$str];
                }
                else
                {
                    if($this->iskehu001=='yes'){
                        $port_obj=$this->port_obj;
                         $wx_userarr =$port_obj->getwxUserid('eq',$str);
                         if(array_key_exists('userid',$wx_userarr))
                         {
                            $wx_userid=$wx_userarr['userid'][0];
                            $sqlfield='select id from ld_users where wx_userid=\''.$wx_userid.'\'  order by id desc limit 0,1';
                         }
                    }
                    else
                         $sqlfield='select id from ld_users where last_name=\''.$str.'\'  order by id desc limit 0,1';
                    if(!empty($sqlfield))
                         $fieldResult=$adb->pquery($sqlfield,array());
                    
                    if($fieldResult&&$adb->num_rows($fieldResult)>0){
                        
                        $importUsers[$str]=$adb->query_result($fieldResult,0,0);
                        $str=$adb->query_result($fieldResult,0,0);
                    }else{
                        if($str==''){
                            $str=$current_user->id;
                        }else{
                            $str=0;
                        }
                    }
                }
                                    
                break;
            case 154:
                //ls 2021-12-13 49102: （http://mydl666.gnway.vip/crm/ [^]）（客户问题-李发林）客户》导入》经管人字段（团队成员），导入不进去
                $strs=array_filter(explode('|##|',$str));
                $lastnames = '';
                foreach($strs as $index=>$lastname)
                {
                    $lastnames.="'".trim($lastname)."',";
                }

                $lastnames=trim($lastnames,',');

                if($lastnames!='')
                {
                    if($this->iskehu001=='yes'){
                        $port_obj=$this->port_obj;
                        $wx_userid_str = '';
                        foreach($strs as $index=>$tmp_lastname)
                        {
                            $wx_userarr =$port_obj->getwxUserid('eq',trim($tmp_lastname));
                            if(array_key_exists('userid',$wx_userarr))
                            {
                                $wx_userid=$wx_userarr['userid'][0];
                                $wx_userid_str.="'".trim($wx_userid)."',";

                            }
                        }
						//chj 2022/3/10 50210: (https://kehu001.com/WX/kh47970 [^])（客户问题：腾中锦鹏）当客户详情页面有字段关联团队成员的时候，录入时该字段没有内容
                        if (!empty($wx_userid_str)) {
                            $wx_userid_str=trim($wx_userid_str,',');
                            $sqlfield='select group_concat(id) as ids from ld_users where wx_userid in( '.$wx_userid_str.') ';
                        }
                    }else{
                        $sqlfield='select GROUP_CONCAT(id) as ids from ld_users where last_name in('.$lastnames.')';
                    }

                    if(!empty($sqlfield))
                        $fieldResult=$adb->pquery($sqlfield,array());

                    if($fieldResult&&$adb->num_rows($fieldResult)>0)
                    {
                        $str = $adb->query_result($fieldResult,0,0);
                    }
                    else
                    {
                        $str=0;
                    }
                }
                else
                {
                    $str=0;
                }
                break;
            case 56:
                if($str =='公海已分配' || strtolower($str) =='distributed of the high seas'){
                    $str=2;
                }elseif($str =='公海未分配' || $str=='是' || strtolower($str) =='no distribution of the high seas' || strtolower($str)=='yes'){
                    $str=1;
                }else{
                    $str=0;
                }
                break;
            case 57://联系人姓名
                $entityname=getEntitynameByModulename('Contacts');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $sqlfield='select  '.$entityidfield.' from '.$tablename ;
                $accountvalue="";
                //$this->importColumnname_indexarr['accountid']=="":代表导入没有客户列

                if($this->importColumnname_indexarr['accountid']!=""&&$this->importColumnname_indexarr['accountid']>=0)
                {
                    $accountentityname=getEntitynameByModulename('Accounts');
                    $accountfieldname=$accountentityname['fieldname'];

                //edit:can BUG20240221-19
                  $accountvalue=  $_SESSION['import_'.$this->importmodule.'_'.$current_user->id.'_data'][$excelrowIndex][$this->importColumnname_indexarr['accountid']];
                }
                $accountvalue=trim($accountvalue);

                if($accountvalue!="")
                {
                    //32394: 跟进记录导入， 导入列有客户和联系人，如果联系人在数据库中所对应的客户和导入的联系人所对应的客户不一致，则导入的联系人值为
                  if($tablename!='ld_contactdetails')
                  {
                    $sqlfield.=" left join ld_contactdetails.contactid=$tablename.contactid ";
                  }
                  $sqlfield.=' inner join ld_account on ld_contactdetails.accountid=ld_account.accountid ' ;
                  
                  $sqlfield.=" where ld_contactdetails.deleted=0 and $tablename.$fieldname='$str' 
                        and  ld_account.deleted=0 and  ld_account.$accountfieldname='$accountvalue'  order by $tablename.$entityidfield desc limit 0,1 ";    
                }
                else
                {
                    $sqlfield.=' where deleted=0 and '.$fieldname.'=\''.$str.'\' order by '.$entityidfield.' desc limit 0,1';    
                }
                              
                $fieldResult=$adb->pquery($sqlfield,array());
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                                 
                break;
            case 80://合同订单
                $entityname=getEntitynameByModulename('SalesOrder');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $tmpfocus = CRMEntity::getInstance('SalesOrder');
                $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                }
                $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                                    
                break;
            case 81://供应商
            case 75:
                $entityname=getEntitynameByModulename('Vendors');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $tmpfocus = CRMEntity::getInstance('Vendors');
                $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                }
                $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
					$strid=$this->insertIntoVendor($str,$excelrowIndex,$entityidfield);
					$str=$strid;
                }
                                    
                break;
            case 96:
                $entityname=getEntitynameByModulename('VendorContact');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $tmpfocus = CRMEntity::getInstance('VendorContact');
                $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                }
                $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                //echo $sqlfield;
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                                    
                break;
            case 76://销售机会
                $entityname=getEntitynameByModulename('Potentials');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $tmpfocus = CRMEntity::getInstance('Potentials');
                $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                }
                $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));
                //print_r($fieldResult);
                //echo $adb->num_rows($fieldResult);die();
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=NULL;
                }
                 break;
           
           case 240:
                $entityname=getEntitynameByModulename('HelpDesk');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
               $tmpfocus = CRMEntity::getInstance('HelpDesk');
               $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
               if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                   $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
               }
               $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                break;
            case 117:
                global $app_currency_strings;
              $checkvalue=array_keys($app_currency_strings,$str);
              if($checkvalue[0]==''){
                $checkvalue[0]=$str;
              }
              //echo $whereval;die;
                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';                   
                //echo $sqlfield;die;
                $fieldResult=$adb->pquery($sqlfield,array());
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,'id');                                  
                }elseif($str==''){
                    $str='';//Liver为空的情况下，就显示为空，导入时会判断，不然无法判断
                }else{
                    $str=0;
                }
                
                break; 
		   case 302://公海池
				global $languageType;
				$tableNamePool = 'ld_account_public_pool';
				//zxm 2021-0601 销售线索导入 公海池ID
				if($currentModule=="Leads"){
                    $tableNamePool = "ld_leads_public_pool";
                }
				if(!empty($str)){
					if($languageType == 'zh')
						$sqlfield="select id from $tableNamePool  where zh_name = ? and deleted = 0";
					else
						$sqlfield="select id from $tableNamePool  where en_name = ? and deleted = 0";
					$fieldResult=$adb->pquery($sqlfield,array($str));
					if($adb->num_rows($fieldResult)>0){
						$str=$adb->query_result($fieldResult,0,0);
					}else{
						$str=0;
					}
				}else{
					$str=0;
				}
                break;
           case 10:                       
                $entityname=getEntitynameByModulename('Project');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $entityname2=getEntitynameByModulename('ProjectTask');
                $fieldname2=$entityname2['fieldname'];
                $tablename2=$entityname2['tablename'];
                $entityidfield2=$entityname2['entityidfield'];
                $sqlfield='select '.$entityidfield.' from '.$tablename.' where deleted=0 and '.$fieldname.'=? union
                select '.$entityidfield2.' from '.$tablename2.' where '.$fieldname2.'=\''.$str.'\'';
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                break; 
            case 82://项目
                $entityname=getEntitynameByModulename('Project');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $tmpfocus = CRMEntity::getInstance('Project');
                $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                }
                $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));

                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                break;
            case 241://项目计划
                $entityname=getEntitynameByModulename('ProjectTask');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $tmpfocus = CRMEntity::getInstance('ProjectTask');
                $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                }
                $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));

                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                break; 
            case 151://仓库
                $sqlfield="select * from ld_warehouse  where name=? and status=0";
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }  
                break;
            case 251://银行账户
                $sqlfield="SELECT * FROM ld_bankaccountset WHERE accountname=? AND discontinued=1 AND deleted=0;"; 
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }  
                break;         
            case 243:
                $entityname=getEntitynameByModulename('ServiceContracts');
                $fieldname=$entityname['fieldname'];
                $tablename=$entityname['tablename'];
                $entityidfield=$entityname['entityidfield'];
                $sqlfield='select '.$entityidfield.' from '.$tablename.' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                $tmpfocus = CRMEntity::getInstance('ServiceContracts');
                if($tablename != $tmpfocus->table_name&&in_array($tablename,$tmpfocus->tab_name)&&$entityidfield == $tmpfocus->table_index){
                    $sqlfield='select '.$tablename.'.'.$entityidfield.' from '.$tablename;
                    $sqlfield.=' left join '.$tmpfocus->table_name.' on '.$tablename.'.'.$tmpfocus->table_index.'='.$tmpfocus->table_name.'.'.$tmpfocus->table_index;
                    $sqlfield.=' where deleted=0 and '.$fieldname.'=? order by '.$entityidfield.' desc limit 0,1';
                }
                $fieldResult=$adb->pquery($sqlfield,array($str));
                if($adb->num_rows($fieldResult)>0){
                    $str=$adb->query_result($fieldResult,0,0);
                }else{
                    $str=0;
                }
                break;
            case in_array($uitype,$multireferenceuitypemodules) : //array_key_exists($uitype,$multireferenceuitypemodules)
                //zkt 20240201 BUG20240131-53 关联选择单据多选字段，使用模板导入时填写多条单据。导入后，该关联选择单据多选字段为空值
                $str_arr=array_filter(explode('|##|',$str));
                $linkvalue_arr = array();
                foreach($str_arr as $linkvalue)
                {
                    if(!empty(trim($linkvalue))){
                        $linkvalue_arr[] = trim($linkvalue);
                    }
                }
                if(!empty($linkvalue_arr)){
                    $referencefocus=CRMEntity::getInstance($uitypemodules[$uitype]);

                    $tablename=$referencefocus->table_name;
                    $tableindex=$referencefocus->table_index;
                    $linkfield=$referencefocus->list_link_field;
                    if(empty($referencefocus->fieldobj))
                    {
                        $str='';
                    }
                    else
                    {
                        $linkfieldinfo=$referencefocus->fieldobj->getFieldInfoobjBykey("fieldname",$linkfield);
                        $linkcolumnname=$linkfieldinfo->getColumnName();
                        $linktablename=$linkfieldinfo->getTableName();
                        $sqlfield='select max('.$tablename.'.'.$tableindex.') as '.$tableindex.' from '.$linktablename;
                        if($tablename!=$linktablename)
                        {
                            $sqlfield.=" left join $tablename on $tablename.$tableindex=$linktablename.$tableindex";
                        }
                        $sqlfield.=" where deleted=0 and ".$linkcolumnname." in ('".implode("','",$linkvalue_arr)."') group by $linktablename.$linkcolumnname order by ".$referencefocus->table_index." desc";
                        $fieldResult=$adb->pquery($sqlfield,array());
                        $tmprows = $adb->num_rows($fieldResult);
                        if($tmprows>0){
                            $str = '';
                            for ($tmpi=0;$tmpi<$tmprows;$tmpi++)
                            {
                                $str.=$adb->query_result($fieldResult,$tmpi,0).',';
                            }
                            $str = trim($str,',');
                        }else{
                            $str='';
                        }
                    }
                }
                else{
                    $str='';
                }
                break;
            default:
               // dump($uitypemodules);
               // exit();
              if(array_key_exists($uitype,$uitypemodules))
              {
                $referencefocus=CRMEntity::getInstance($uitypemodules[$uitype]);
                $tablename=$referencefocus->table_name;
                $tableindex=$referencefocus->table_index;
                $linkfield=$referencefocus->list_link_field;
                
                $linkfieldinfo=$referencefocus->fieldobj->getFieldInfoobjBykey("fieldname",$linkfield);
                $linkcolumnname=$linkfieldinfo->getColumnName();
                $linktablename=$linkfieldinfo->getTableName();
                 $sqlfield='select '.$tablename.'.'.$tableindex.' from '.$linktablename;
                 if($tablename!=$linktablename)
                 {
                    $sqlfield.=" left join $tablename on $tablename.$tableindex=$linktablename.$tableindex";
                 }
                $sqlfield.=' where deleted=0 and '.$linkcolumnname.'=? order by '.$referencefocus->table_index.' desc limit 0,1';
                $fieldResult=$adb->pquery($sqlfield,array($str));
               
                    if($adb->num_rows($fieldResult)>0){
                        $str=$adb->query_result($fieldResult,0,0);
                    }else{
                        $str=0;
                    }
              }
              else
              {
                 $this->import_nouitype='yes';
                $str = $str;
              }
            break;
            
        }
        
        return $str;
    }
    
/**
*@description :判断插入数据的不能重复的字段是否有重复
*@param :$codenum需要查找的字段名
*@param :$tabname所在字段的表名
*/
function checkImportOnly($codenum,$tabname,$onlyfieldLabel){
    global $adb;
    $codenum=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$codenum);
    $SQL = "select 1 from $tabname where $onlyfieldLabel='$codenum'";
    //echo $SQL;
    $result=$adb->pquery($SQL,array());
    $resultcount = $adb->num_rows($result);
    
    if($resultcount>0){
        return false;
    }else{
        return true;
    }
}
/**
*@description :判断导入的币种和账户是否匹配
*@another : Liver 2017-04-20
*/
function get_importcurrencyAccount($currencyid,$bankaccountsetid){
    global $adb;
    $sql='select 1 from ld_bankaccountset where bankaccountsetid=? and currency_id=? and deleted=0';
    $result=$adb->pquery($sql,array($bankaccountsetid,$currencyid));
    $nums=$adb->num_rows($result);
    
    if($nums>0){//大于0表示匹配
        return true;
    }
        return false;
}
    
/**
*@description :获取模块编号字段
*/
function get_moduleNo($module){
    global $adb;
    $SQL = "select fieldname from ld_field where uitype=4 AND tabid=(select tabid from ld_tab where name=?)";
    $result=$adb->pquery($SQL,array($module));
    
    return $adb->query_result($result,0,0);
}

function importContacts($accountvalue,$codenum,$potentialid){
    global $adb;
        $codenum=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$codenum);
    if($accountvalue!=''){
            $accountvalue=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$accountvalue);
            $SQL = "SELECT ld_contactdetails.contactid FROM ld_contactdetails 
            LEFT JOIN ld_account ON ld_contactdetails.accountid=ld_account.accountid
            WHERE contact_no=? AND accountname=? LIMIT 1";
            $result=$adb->pquery($SQL,array($codenum,$accountvalue));
    }else{
            $SQL = "SELECT ld_contactdetails.contactid FROM ld_contactdetails 
            WHERE contact_no=? AND (ld_contactdetails.accountid='' or ld_contactdetails.accountid IS NULL) LIMIT 1";
            $result=$adb->pquery($SQL,array($codenum));
    }
    if($adb->num_rows($result)>0){
        $contactsid=$adb->query_result($result,0,0);
        $sqlContacts='insert into ld_contpotentialrel(contactid,potentialid)values(?,?)';
        $adb->pquery($sqlContacts,array($contactsid,$potentialid));
        return 2;//已有数据直接关联
    }else{
        return 3;//编号已经被使用
    }

}
//导入时根据其他字段获取信息
//$colnames:字段信息 $str：字段值 $colinfo:所有字段信息 $fieldvalue_arr：所有字段值
function getvaluebyfields($colnames,$str,$contact_detail_fields,$fieldvalue_arr){
    //所属部门字段，根据负责人或创建人获取对应部门    
    if($colnames[1]==1600){
        global $adb,$current_user;
        $module = $this->importmodule;
        if($colnames['tablename'] == 'ld_contactdetails' || $colnames['tablename'] == 'ld_contactscf'){
            $module = 'Contacts';
        }
        $tabid = getTabid($module);
        $columnname_group = $colnames[0];
        $focus = CRMEntity::getInstance($module);
        $all_groupid = '';
        //获取所属部门字段对应的用户字段
        $sql = 'SELECT tmp1.columnname,ld_related_field.fromvalue_info from ld_related_field 
                INNER JOIN (SELECT columnname,fieldid from ld_field where tabid = ?) as tmp1 on tmp1.fieldid = ld_related_field.trigger_fieldid
                INNER JOIN (SELECT columnname,fieldid from ld_field where tabid = ?) as tmp2 on tmp2.fieldid = ld_related_field.effect_fieldid
                where tmp2.columnname = ?;';
        $result = $adb->pquery($sql,array($tabid,$tabid,$columnname_group));
        if($adb->num_rows($result)>0){
            $columnname_user = $adb->query_result($result,0,'columnname');
            //通过columnname获取索引值，再获取用户名
            $user_index = -1; 
            $tmp_colnamesinfo = array();
            foreach($contact_detail_fields as $tablename => $colinfo){
                foreach($colinfo as $tmp_key => $tmp_colnames){
                    if($tmp_colnames[0]==$columnname_user){
                        $tmp_colnamesinfo = $tmp_colnames;
                        $user_index = $tmp_colnames[3];
                        $username = $fieldvalue_arr[$user_index];
                        break;
                    }
                }
                if($user_index>=0){
                    break;
                }
            }
            //zkt 20230911 BUG0072529 项目总览模块（CustomForm180）-导入异常，导入时销售人员办事处填写了石家庄办事处（销售人员办事处字段为引用字段，引用商机内的所属部门），导入后销售人员办事处显示的是深圳昂楷科技有限公司 
            if($focus->fieldobj){
                //引用成员部门字段,重新获取
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$colnames[0]);
                if(!empty($fieldinfo)){
                    if($fieldinfo->isRelatedModuleField()){
                        $trigger_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('columnname',$tmp_colnamesinfo[0]);
                        $trigger_record = $this->setImprtNameToId($tmp_colnamesinfo[1],$username);
                        //关联选择单单据字段引用
                        if(!empty($trigger_fieldinfo)&&!empty($trigger_record)&&$trigger_fieldinfo->getBigType()=='reference'){
                            $fromvaule_columnname = $adb->query_result($result,0,'fromvalue_info');
                            $frommodule = cls_module_uitype::getUitypeModule($trigger_fieldinfo->getUIType());
                            if(!empty($frommodule)){
                                $fromfocus = CRMEntity::getInstance($frommodule);
                                $fromfocus->retrieve_entity_info($trigger_record,$frommodule);
                                $fromvaule_fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey('columnname',$fromvaule_columnname);
                                if(!empty($fromvaule_fieldinfo)){
                                    return $fromfocus->column_fields[$fromvaule_fieldinfo->getFieldName()];
                                }
                            }
                        }
                        else if(empty($trigger_record)){
                            return '';
                        }
                    }
                }
            }
            //如果关联的用户字段为空则默认当前用户
            if(empty($username)||$username==''){
                $username = $current_user->last_name;
            }
            //通过用户名获取对应的部门id
            $sql = 'SELECT GROUP_CONCAT(ld_groups.groupid) as all_groupid from ld_users2group 
                    INNER JOIN ld_users on ld_users.id = ld_users2group.userid
                    INNER JOIN ld_groups on ld_groups.groupid = ld_users2group.groupid
                    where ld_users.last_name = ? GROUP BY ld_users2group.userid ORDER BY ld_groups.depth asc;';
            $result = $adb->pquery($sql,array($username));
            if($adb->num_rows($result)>0){
                $all_groupid = $adb->query_result($result,0,'all_groupid');
            }
        }
        //如果crm系统中不存在对应的用户则返回空
        return $all_groupid;
    }
}
    /*
     * 导入相关操作时是否有errormsg
     * */
    function  haveerrormsg(){
        $flag = false;
        if(!empty($this->errormsg)){
            $flag = true;
        }
        return $flag;
    }
    /*
     * 导入相关操作时提示信息输出
     * 同时要清空errormsg
     * */
    function  getouterrormsg(){
        $outmsg = '';
        $outmsg = $this->errormsg;
        $this->errormsg = '';
        return $outmsg;
    }
}
?>
