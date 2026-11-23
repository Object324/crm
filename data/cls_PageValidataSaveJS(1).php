<?php


class cls_PageValidataSaveJs{
    
    public $module;
    public $record;
    public $focus;
    public $errortip;
    public $detailrowcnt;
    public $validatasave;
    
    public function __construct($module,$record,$detailrowcnt)
    {
      
        $this->module=$module;
        $this->record=$record;
        $this->focus=CRMEntity::getInstance($module);
        $this->errortip='';
        $this->detailrowcnt=$detailrowcnt;//明细总行数
        $this->validatasave = $this->getValidDataSave_arr($module);
        
    }
    //zkt 20230303 BUG0062472字段类型“手机”勾选“严格执行11位手机”，序时簿列表界面小编辑，编辑其他字段的时候也会提示，需要输入正确的手机号 
    //设置需要判断的验证规则的数据
    public function setmainValidDataJudge_arr($arr)
    {
        $savejudgefieldname = [];
        if(!empty($arr)){
            if(is_array($arr)&&sizeof($arr)>0){
                foreach($arr as $tmpindex=>$tmpfieldname){
                    $savejudgefieldname[] = $tmpfieldname;
                }
            }
        }
        $this->ValidDataJudge_arr['main'] = $savejudgefieldname;
    }
    public function getValidDataSave_arr($module)
    {
        if(empty($this->validatasave))
        {
            $this->validatasave = $this->getValidataSaveJs($module);
        }
        return $this->validatasave;
    }
    
    public function getValidataSaveJs($module)
    {
        global $adb;
        $sql='select  ld_validatasave.*,ld_validatasavedetail.relatefieldname,ld_validatasavedetail.relateformulavalue from ld_validatasave left join ld_validatasavedetail 
        on ld_validatasavedetail.relateid=ld_validatasave.id  where ld_validatasave.module=?
        and validatasavetype="js" and status="active"
         order by comparator,fieldname';
        $result=$adb->pquery($sql,array($module));
        $rows=$adb->num_rows($result);
        
       
        for($i=0;$i<$rows;$i++)
        {
            $fieldname=$adb->query_result($result,$i,'fieldname');
            $comparator=$adb->query_result($result,$i,'comparator');
            $relatetable=$adb->query_result($result,$i,'relatedtable');
            $nextfieldname=$fieldname;
            $relatefieldname=array();
            if($comparator=='duplicate')//重复字段判断
            {
                while($relatefieldname==$fieldname&&$i<$rows)
                {
                    $tmprelatefieldname=$adb->query_result($result,$i,'relatefieldname');
                    if($relatetable=='ld_field')
                    {
                        $arr['maincolsfieldlabel'][$tmprelatefieldname]=getRelatefieldlabel($module,$relatetable,$tmprelatefieldname);
                        
                    }
                    else if($relatetable=='ld_tabdetailfield')
                    {
                        $arr['detailcolsfieldlabel'][$tmprelatefieldname]=getRelatefieldlabel($module,$relatetable,$tmprelatefieldname);
                    }
                    $relatefieldname[]=$adb->query_result($result,$i,'relatefieldname');
                     $nextfieldname=$adb->query_result($result,$i,'fieldname');
                    $i++;
                }
            }
            else
            {
                    $tmprelatefieldname=$adb->query_result($result,$i,'relatefieldname');
                    //zkt 20230110 小编辑手机”字段类型勾选“严格11位手机号码格式”无效
                    if($comparator == 'regexp'&&empty($tmprelatefieldname)){
                        $tmprelatefieldname=$fieldname;
                    }
                    if($relatetable=='ld_field')
                    {
                        if(!empty($tmprelatefieldname))
                                $arr['maincolsfieldlabel'][$tmprelatefieldname]=getRelatefieldlabel($module,$relatetable,$tmprelatefieldname);
                        
                    }
                    else if($relatetable=='ld_tabdetailfield')
                    {
                        if(!empty($tmprelatefieldname))
                            $arr['detailcolsfieldlabel'][$tmprelatefieldname]=getRelatefieldlabel($module,$relatetable,$tmprelatefieldname);
                    }
    				else if($relatetable=='ld_producttoolfield')
                    {
                        if(!empty($tmprelatefieldname))
                            $arr['detailcolsfieldlabel'][$tmprelatefieldname]=getRelatefieldlabel($module,$relatetable,$tmprelatefieldname);
                    }
                    $relatefieldname[]=$tmprelatefieldname;
            }
            $relateformulavalue=$adb->query_result($result,$i,'relateformulavalue');
           
           if($relatetable=='ld_field')
                $arr['maincols'][$fieldname][]=array('relatefieldname'=>$relatefieldname,'comparator'=>$comparator ,'relateformulavalue'=>$relateformulavalue);
           else
                $arr['detailcols'][$fieldname][]=array('relatefieldname'=>$relatefieldname,'comparator'=>$comparator,'relateformulavalue'=>$relateformulavalue);
          
          
           
             if($relateformulavalue=='curdate')
            {
                //日期
                 $arr['curdate']=date("Y-m-d");
                 $arr['relateformulavalue']['curdate']['fieldlabel']=getFixedLabel('CURRENTDATE');
            }
            else if($relateformulavalue=='curdatetime')
            {
                //日期+时间，前端有添加时间的变量datetimecount;
                $arr['curdatetime']=date("Y-m-d H:i:s");
                $arr['relateformulavalue']['curdatetime']['fieldlabel']=getFixedLabel('CURRENTDATE');
            }
            else if($relateformulavalue=='curtime')
            {
                //时间，前端有添加时间的变量timecount;
                $arr['time']=date("H:i:s");
                $arr['relateformulavalue']['time']['fieldlabel']=getFixedLabel('CURRENTDATE');
            }
            else if($relateformulavalue!="")
            {
               $arr['value']=$relateformulavalue;
               $arr['relateformulavalue'][$relateformulavalue]['fieldlabel']=$relateformulavalue;
            }
          
           
        }
      
        return $arr;
    }
    
    public function getValidDataJudgeJs()
    {
        
        $returnstatus = true;
        $module = $this->module;
        if(empty($this->validatasave))
        {
            $this->validatasave = $this->getValidDataSave_arr($module);
        }
        
        $returnstatus = $this->mainjsvalidata();
        if(!$returnstatus)
        {
            return $returnstatus;
        }
        if(get_file_address($module,"ProductDetails")&&$module!='ServiceCharge')
        {
            $returnstatus = $this->tabdetailvalidata();
        }
        else if(get_file_address($module,$module.'DetailFieldsHtml'))
        {
            $returnstatus = $this->producttoolvalidata();
        }
        return $returnstatus;
    }
    
    public function mainjsvalidata()
    {
        if(empty($this->validatasave)||empty($this->validatasave['maincols']))
        {
            return true;
        }
        $fieldobj = $this->focus->fieldobj;
        foreach($this->validatasave['maincols'] as $tmpfieldname =>$tmpvaldatasavearr )
        {
            if(!empty($this->ValidDataJudge_arr)&&!in_array($tmpfieldname,$this->ValidDataJudge_arr['main'])){
                continue;
            }
            $fieldinfo = $fieldobj->FieldInfoListByKeyValue('fieldname',$tmpfieldname);
            if(!$this->maincommonvalidata($tmpfieldname,$fieldinfo['uitype'],$fieldinfo['fieldlabel']))
            {
                return false;
            }
        }
        return true;
    }
    
    
    public function maincommonvalidata($fieldname,$uitype,$fieldlabel)
    {
        $curvalue = $_REQUEST[$fieldname];
        $tmpvalidata = $this->validatasave['maincols'][$fieldname];
        foreach($this->validatasave['maincols'][$fieldname] as $tmpindex=>$tmpvalidatasaveinfo)
        {
            $comparator = $tmpvalidatasaveinfo['comparator'];
            $tmprelateformulavalue  = $tmpvalidatasaveinfo['relateformulavalue'];
            if(!empty($tmpvalidatasaveinfo['relateformulavalue']))
            {
                if(strpos($tmprelateformulavalue,'_months_months')>0)
                {
                    $relatefieldname = $tmpvalidatasaveinfo['relatefieldname'][0];
                    $months = explode('_',$tmprelateformulavalue);
                    $month = (int)$months[0];//获取月份的数目要求
                    if(!empty($relatefieldname))
                    {
                        if(!isset($_REQUEST[$relatefieldname]))
                        {
                            continue;
                        }
                        $relatevalue = $_REQUEST[$relatefieldname];
                        $relatefieldlabel = $this->validatasave['maincolsfieldlabel'][$relatefieldname];
                        
                        for($i=0;$i<$month;$i++)
                        {
                            $dataobj = date('Y-d-m',strtotime($relatevalue));
                            $relatevalue=$this->next_month_today($dataobj);//获取日期的下个月日期
                            
                        }
                        
                        if(strtotime($curvalue)-strtotime($relatevalue))
                        {
                            $this->errortip = "要求".$fieldlabel."比".$relatefieldlabel."晚".$month."个月";
                            return false;
                        }
                    }
                    continue;
                }
                
                else if($comparator=='regexp')
                {
                    //正则表达式
                    $tmprelateformulavalue=$tmpvalidata[$tmpindex]['relateformulavalue'];
                    $relatefieldlabel = $this->validatasave['maincolsfieldlabel'][$fieldname];
                    //查看界面的处理
                    //zkt 20230228 BUG0061964字段类型为手机的字段，勾选“严格11位手机号码格式”，在序时簿列表界面，可以编辑不满足条件的手机号并保存 
                    $tmprelateformulavalue=str_replace('#####','\\',$tmprelateformulavalue);
                    if(!preg_match("/".$tmprelateformulavalue."/",$curvalue)&&!empty($curvalue))
                    {
                        $this->errortip = getFixedLabel('PLEASEENTERTHECORRECT').$relatefieldlabel;
                        return false;
                    }
                }
                else
                {
                       $relatevalue=$this->getformuladatefieldvalue($tmpvalidata[$tmpindex]['relateformulavalue']);
             
                        $relatefieldlabel=$this->validatasave['relateformulavalue'][$tmpvalidata[$tmpindex]['relateformulavalue']]['fieldlabel'];
                }
            }
            else
            {
                $relatevalue="";
                $relatefieldlabel="";      
                $relatefieldname=$this->validatasave['maincols'][$fieldname][$tmpindex]['relatefieldname'][0];
                
                if(!empty($relatefieldname))
                {
                    $isdetailfield='no';
                    if(strpos($relatefieldname,'detailfield:')===false)
                    {
                        
                    }
                    else
                    {
                        $tmp_arr=explode('detailfield:',$relatefieldname);
                        $relatefieldname=$tmp_arr[1];
                        $isdetailfield='yes';
                    }
                    if(!isset($_REQUEST[$relatefieldname]))
                    {
                        continue;
                    }
                    $relatevalue=$_REQUEST[$relatefieldname];
                   
                   if($isdetailfield=='yes')
                    {
                        //获取分录relatefieldlabel
                        $detailfieldobj =$this->focus->detailfieldobj;
                        if(!empty($detailfieldobj))
                        {
                            $relatefieldlabel = $detailfieldobj->getFieldInfoBykeyValue('fieldname',$relatefieldname,'fieldlabel');
                        } 
                         
                    }
                    else
                    {
                        $relatefieldlabel=$this->validatasave['maincolsfieldlabel'][$relatefieldname];
                    }
                    
                         
                }
            }
            
            if($uitype==5||$uitype==86)
            {
                if(!$this->jsdatevalidate($comparator,$curvalue,$relatevalue,$fieldlabel,$relatefieldlabel,0))
                {
                    return false;
                }
            }
            else if($uitype==71 || $uitype==72||$uitype==7||$uitype==9)
            {
                
                
                //金额
                if(!$this->jsmoneyvalidata($comparator,$curvalue,$relatevalue,$fieldlabel,$relatefieldlabel,0))
                {
                    return false;
                }
            }
            
            
        }
        
        
        return true;
    }
    
    
    public function getformuladatefieldvalue($relateformulavalue){
        
        if($relateformulavalue=='curdate'){
            return date('Y-m-d',time());
        }
        else if($relateformulavalue=='curdatetime'){
            //zkt 20230111 BUG0060730服务、热线记录下单据直接在当前页面修改提示日期不能大于当前日期，但实际上日期是不大于当前日期的
            $datetimeobj = date_create(date_format(date_create("now"),'Y-m-d H:i:s'));
            date_add($datetimeobj,date_interval_create_from_date_string('3 seconds'));
            $tmpdatetime = date_format($datetimeobj,'Y-m-d H:i:s');
            return $tmpdatetime;
        }
        else{
            //具体字符
            return $relateformulavalue;
        }
    }
    
    public function tabdetailvalidata()
    {
        if(empty($this->validatasave)||empty($this->validatasave['detailcols']))
        {
            return true;
        }
        $rowcount = $this->detailrowcnt;
        $ret=true;
        for($rowindex =1; $rowindex<=$rowcount;$rowindex++)
        {
            foreach($this->validatasave['detailcols'] as $tmpfieldname => $tmpvalidatasavearr)
            {
                
                $tmpvalidata=$this->validatasave['detailcols'][$tmpfieldname];
                $detailfieldinfoobj = $this->focus->detailfieldobj->getFieldInfoBykeyValue('fieldname',$tmpfieldname);
                if(empty($detailfieldinfoobj))
                {
                    continue;
                }
                foreach($tmpvalidatasavearr as $tmpindex=>$tmpvalidatasaveinfo)
                {
                    if(!empty($tmpvalidata[$tmpindex]['relateformulavalue']))
        			{
        			   $relatevalue=$this->getformuladatefieldvalue($tmpvalidata[$tmpindex]['relateformulavalue']);
                     
        			   $relatefieldlabel=$this->validatasave['relateformulavalue'][$tmpvalidata[0]['relateformulavalue']]['fieldlabel'];
        			}
                    else
                    {
                        $relatefieldlabel="";
    					$relatevalue="0";
    					$relatefieldname=$this->validatasave['detailcols'][$tmpfieldname][$tmpindex]['relatefieldname'];
    				   
    					if(!empty($relatefieldname))
    					{
    						$tmprelatefieldname=$relatefieldname;
    					     if(!isset($_REQUEST[$tmprelatefieldname.$rowindex]))
                             {
                                continue;
                             }
    						$relatevalue=$_REQUEST[$tmprelatefieldname.$rowindex];
    						$relatefieldlabel=$this->validatasave['detailcolsfieldlabel'][$relatefieldname];
    					}
                    }
                    $comparator=$this->validatasave['detailcols'][$tmpfieldname][$tmpindex]['comparator'];
					$curvalue=$_REQUEST[$tmprelatefieldname.$rowindex];
					if($detailfieldinfoobj->getFieldType()=='Amount'||$detailfieldinfoobj->getFieldType()=='Num')//金额/数字
					{
					  if($this->module=='CashBill'&&$_REQUEST['cashbilltype']=='cashbill'&&$tmprelatefieldname=='total'){
					      //41449: （61mis.com/kfbtest）收款单新建/编辑界面，关联核销预收单后，“实际收款金额”为0时，无法保存
                          /*if($_REQUEST['cashbilltype']ld("#"+popupobj.divid+" [tag=debuction][deleted=no]").length>0)
                          {
                                 $ret=true;
                                 return false;
                          }*/
					  }
						if(!$that->jsmoneyvalidata($comparator,$curvalue,$relatevalue,$detailfieldinfoobj->getFieldLable(),$relatefieldlabel,$rowindex))
						{
						     $ret=false;
						     	return false;
						}
					}
					else if($detailfieldinfo['fieldtype']=='Date_Ymd' || $detailfieldinfo['fieldtype']=='Date_YmdHms')//日期
					{
					   
						if(!$that->jsdatevalidate($comparator,$curvalue,$relatevalue,$detailfieldinfoobj->getFieldLables(),$relatefieldlabel,$rowindex))
						{
					      	 $ret=false;
							return false;
						}
					}
                }
                
            }
        }
        return $ret;
    }
    
    public function producttoolvalidata()
    {
        $ret = true;
        if(empty($this->validatasave)||empty($this->validatasave['detailcols']))
        {
            return true;
        }
        $rowcount = $this->detailrowcnt;
        $ret=true;
        for($rowindex =1; $rowindex<=$rowcount;$rowindex++)
        {
            foreach($this->validatasave['detailcols'] as $tmpfieldname => $tmpvalidatasavearr)
            {
                
                $tmpvalidata=$this->validatasave['detailcols'][$tmpfieldname];
                $detailfieldinfoobj = $this->focus->detailfieldobj->getFieldInfoobjBykey('fieldname',$tmpfieldname);
                if(empty($detailfieldinfoobj))
                {
                    continue;
                }
                $validatafieldname = $tmpfieldname;
                foreach($tmpvalidatasavearr as $tmpindex=>$tmpvalidatasaveinfo)
                {
                    if(!empty($tmpvalidata[$tmpindex]['relateformulavalue']))
        			{
        			   $relatevalue=$this->getformuladatefieldvalue($tmpvalidata[$tmpindex]['relateformulavalue']);
                     
        			   $relatefieldlabel=$this->validatasave['relateformulavalue'][$tmpvalidata[0]['relateformulavalue']]['fieldlabel'];
        			}
                    else
                    {
                        $relatefieldlabel="";
    					$relatevalue="0";
    					$relatefieldname=$this->validatasave['detailcols'][$tmpfieldname][$tmpindex]['relatefieldname'];
    				   
    					if(!empty($relatefieldname))
    					{
    						$tmprelatefieldname=$relatefieldname;
    					     if(!isset($_REQUEST[$tmprelatefieldname.$rowindex]))
                             {
                                continue;
                             }
    						$relatevalue=$_REQUEST[$tmprelatefieldname.$rowindex];
    						$relatefieldlabel=$this->validatasave['detailcolsfieldlabel'][$relatefieldname];
    					}
                    }
                    $comparator=$this->validatasave['detailcols'][$tmpfieldname][$tmpindex]['comparator'];
					$curvalue=$_REQUEST[$tmprelatefieldname.$rowindex];
					if($detailfieldinfoobj->getUIType()==28||$detailfieldinfoobj->getUIType()==10||$detailfieldinfoobj->getUIType()==163)//金额
					{
						if(!$that->jsmoneyvalidata($comparator,$curvalue,$relatevalue,$detailfieldinfoobj->getFieldLabel(),$relatefieldlabel,$rowindex))
						{
						     $ret=false;
						     	return false;
						}
					}
					else if($detailfieldinfoobj->getUIType()==51)//日期
					{
					   
						if(!$that->jsdatevalidate($comparator,$curvalue,$relatevalue,$detailfieldinfoobj->getFieldLabel(),$relatefieldlabel,$rowindex))
						{
					      	 $ret=false;
							return false;
						}
					}
                    
                }
            }
               
        }
        return $ret;
    }
    
    /**
    * 
    *日期、时间类型的字段判断
    *     
    */
    public function jsdatevalidate($comparator,$curvalue,$relatevalue,$curfieldlabel,$relatefieldlabel,$row)
    {
        global $languageType;
        if($comparator=='m'){	//小于等于
            if(trim($relatevalue)=='')
            {
                //36750: （1.6）项目立项新增界面>实际完成日期字段：当实际完成日期字段值为空时不判断，实际完成日期不能小于开始日期
                return true;
            }
            if($curvalue>$relatevalue){
                $confirm_str = getFixedLabel('CANNOTTHAN');//不能大于
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
        }else if($comparator == 'h'){	//大于等于
            if(trim($curvalue)=='')
            {
                //36750: （1.6）项目立项新增界面>实际完成日期字段：当实际完成日期字段值为空时不判断，实际完成日期不能小于开始日期
                return true;
            }
			if($curvalue<$relatevalue){
                $confirm_str = getFixedLabel('cannotbelessthan1');
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                       
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
		}
        return true;
    }
    /**
    * 
    *金额类型的字段判断
    *     
    */
    public function jsmoneyvalidata($comparator,$curvalue,$relatevalue,$curfieldlabel,$relatefieldlabel,$row)
    {
        global $languageType;
        if(empty($curvalue))
        {
            return false;
        }
        if($comparator=='notempty')
        {   
            if(trim($curvalue)==''||round((Float)$curvalue,2)=="0.00")
            {
                $confirm_str = getFixedLabel('CANNOTEMPTYORZERO');//不能为空或0
                
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                       
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
        }
        else if($comparator =='m')
        {
            
            if((Float)($curvalue)>(Float)($relatevalue))
            {
                $confirm_str = getFixedLabel('CANNOTTHAN');//不能大于
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                       
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
        }
        else if($comparator =='h')
        {
            if((Float)($relatevalue)>(Float)($curvalue))
            {
                $confirm_str = getFixedLabel('SHOULDGREATEROREQUAL');//应大于或等于
                
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                       
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
        }
        else if($comparator =='g')
        {
            if((Float)($relatevalue)>=(Float)($curvalue))
            {
                $confirm_str = getFixedLabel('SHOULDBEGREATER');//应大于
                
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                       
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
        }
        else if($comparator=='c')
        {
            if((Float)($relatevalue)!=(Float)($curvalue))
            {
                $confirm_str = getFixedLabel('NEQ');//不等于
                
                if($row>0){
                    
                     if($languageType=='zh')
                     {
                        $this->errortip = getFixedLabel('LINE').$row.getFixedLabel('row').$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                     else
                     {
                        $this->errortip = getFixedLabel('LINE').$row.' '.$curfieldlabel.$confirm_str.$relatefieldlabel;
                     }
                       
                }
                else{
                    $this->errortip = $curfieldlabel.$confirm_str.$relatefieldlabel;
                }
                return false;
            }
        }
        return true;
        
    }
    
    
    public function  getNextMonthEndDate( $date ){
         $firstday  =  date ( 'Y-m-01' ,  strtotime ( $date ));
         $lastday  =  date ( 'Y-m-d' ,  strtotime ( "$firstday +2 month -1 day" ));
         return   $lastday ;
     }
     //获取给定日期的下个月日期
     public function  next_month_today( $date ){        
         //获取今天是一个月中的第多少天
         $current_month_t  =   date ( "t" ,  strtotime ( $date ));
         $current_month_d =  date ( "d" ,  strtotime ( $date ));
         $current_month_m =  date ( "m" ,  strtotime ( $date ));
         
         //获取下个月最后一天及下个月的总天数
         $next_month_end =getNextMonthEndDate( $date );
         $next_month_t  =   date ( "t" ,  strtotime ( $next_month_end ));
         
         $returnDate = '' ;
         if ( $current_month_d == $current_month_t ){ //月末
             //获取下个月的月末
             $returnDate = $next_month_end ;
         } else { //非月末
             //获取下个月的今天
             if ( $current_month_d > $next_month_t ){  //如 01-30，二月没有今天,直接返回2月最后一天
                 $returnDate = $next_month_end ;
             } else {
                 $returnDate = date ( "Y-m" ,  strtotime ( $next_month_end )). "-" . $current_month_d ;
             }
         }
         return  $returnDate ;
     }
}

?>