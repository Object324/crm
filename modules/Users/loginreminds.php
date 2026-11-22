<?php

/**
 * @author andy
 * @copyright 2014
 */
global $adb;
require_once('data/CRMEntity.php');

$file = 'remindsdate.php';
$content = file_get_contents($file); //读取文件中的内容
$date=date('Y-m-d');
if($content != $date && is_writable($file) == true){
    
    //获取已启用提醒规则
    $sql="select * from ld_automaticreminds where `status` = 1 order by tabid";
    $result=$adb->query($sql);
    $nums= $adb->num_rows($result);
    $ruleArray=array();
    for($i=0;$i<$nums;$i++){
        $ruleArray[$i]=array(
            'ruleid'=>$adb->query_result($result,$i,'id'),
            'tabid'=>$adb->query_result($result,$i,'tabid'),
            'name'=>$adb->query_result($result,$i,'name'),
            'columnname'=>$adb->query_result($result,$i,'columnname'),
            'startdate'=>$adb->query_result($result,$i,'startdate'),
            'remindnum'=>$adb->query_result($result,$i,'remindnum'),
            'remindway'=>$adb->query_result($result,$i,'remindway'),
            'remindday'=>$adb->query_result($result,$i,'remindday'),
            'reminder'=>$adb->query_result($result,$i,'reminder'),
            'remindcontent'=>$adb->query_result($result,$i,'remindcontent')
        );
    }
    print_r($ruleArray);
    foreach($ruleArray as $key_i => $vals){
        //print_r($vals);
        //获取当前规则的提醒条件- 基本条件
        $basicruleArr=getBasicrule($vals['ruleid']);
        //print_r($basicruleArr);
        //获取当前规则的提醒条件- 高级条件
        $AdvancedArr=getAdvancedrule($vals['ruleid']);
        //print_r($AdvancedArr);
        //获取提醒方式为指定时间的提醒设置信息
        $ReemindMethodArr=getReemindMethod($vals['ruleid']);
        //print_r($ReemindMethodArr);
        //获取表名
        $tabnames=getTabname($vals['tabid']);
        //echo $tabname.'<br>';
        switch($tabnames){           
            case 'Accounts':
            $tabname="ld_account";
            $moduleid='accountid';
            break;            
            default:
            $tabname="ld_".$tabnames;
            $moduleid=$tabnames.'id';
            break;
        }
        $query="";
        //基本查找
        $query.="select t2.smcreatorid,t2.smownerid from $tabname as t1 LEFT JOIN ld_crmentity as t2 on t1.$moduleid = t2.crmid 
                where 1=1";
        //规则基本查找 
        if($vals['columnname'] == 'dothis'){//自定义时间
            
            $startdate=$vals['startdate'];
            $remindnum=$vals['remindnum'];
            if($vals['remindway'] == 1){//固定提醒
                $reminddata=$startdate;
                $firstdatenum=$remindnum;
                $enddatenum=$remindnum*$vals['remindday'];
            }else{//指定提醒
                $reminddata=$startdate;
                $firstdatenum=$ReemindMethodArr[0]['min_remindsday'];
                $enddatenum=$ReemindMethodArr[0]['max_remindsday'];
                //echo $reminddata.'----'.$firstdatenum.'===='.$enddatenum;exit;
            }
            
        }else{//指定时间字段
            $field=$vals['columnname'];
            $field=explode(':',$field);
            $field=$field[1];
            $reminddata='t1.'.$field;
            $remindnum=$vals['remindnum'];
           
            if($vals['remindway'] == 1){//固定提醒
                $firstdatenum=$remindnum;
                $enddatenum=$remindnum*$vals['remindday'];
                //echo $firstdatenum.'========='.$enddatenum;exit();
            }else{//指定提醒
                $firstdatenum=$remindnum;
                $enddatenum=$ReemindMethodArr[0]['max_remindsday'];
            }
        }   
        if($vals['columnname'] == 'dothis'){
            $query="select t1.$moduleid as recordid,t2.smcreatorid,t2.smownerid,date_format('{$reminddata}','%Y-%m-%d') as remind_data, 
                date_format(date_add('{$reminddata}',interval $firstdatenum day),'%Y-%m-%d') as start_date, 
                date_format(date_add('{$reminddata}',interval $enddatenum day),'%Y-%m-%d') as end_date, 
                date_format(now(),'%Y-%m-%d') as now 
                from $tabname as t1 
                inner join ld_crmentity as t2 on t1.$moduleid=t2.crmid 
                
                where t2.deleted=0 and (date_format(now(),'%Y-%m-%d') 
                between date_format(date_add('{$reminddata}',interval $firstdatenum day),'%Y-%m-%d') 
                and date_format(date_add('{$reminddata}',interval $enddatenum day),'%Y-%m-%d')) 
                and t1.$moduleid not in (select related_to from ld_reminds where reminds_ruleid=105)";
        }else{
            $query="select t1.$moduleid as recordid,t2.smcreatorid,t2.smownerid,date_format($reminddata,'%Y-%m-%d') as remind_data, 
                date_format(date_add($reminddata,interval $firstdatenum day),'%Y-%m-%d') as start_date, 
                date_format(date_add($reminddata,interval $enddatenum day),'%Y-%m-%d') as end_date, 
                date_format(now(),'%Y-%m-%d') as now 
                from $tabname as t1 
                inner join ld_crmentity as t2 on t1.$moduleid=t2.crmid 
                
                where t2.deleted=0 and (date_format(now(),'%Y-%m-%d') 
                between date_format(date_add($reminddata,interval $firstdatenum day),'%Y-%m-%d') 
                and date_format(date_add($reminddata,interval $enddatenum day),'%Y-%m-%d')) 
                and t1.$moduleid not in (select related_to from ld_reminds where reminds_ruleid=105)";
        }
        
        
        //规则数据分类基本查询拼接
        $basicrulestartdate=$basicruleArr[0]['startdate'];
        $basicruleenddate=$basicruleArr[0]['enddate'];
        $query.=" and {$basicruleArr[0]['columnname']} BETWEEN date_format('{$basicrulestartdate}','%Y-%m-%d')
                and date_format('{$basicruleenddate}','%Y-%m-%d') and t2.deleted=0";
        //echo $query.'<br>';
        /*
        if($vals['reminder'] == 1)
        //高级条件查询待拼接
        $nums_rules=count($AdvancedArr);
        for($i=0;$i<$nums_rules;$i++){
            $sql.=" $AdvancedArr[$i]['columnname']";
        }
        */
        //执行查询
        $result=$adb->query($query);
        $nums_results=$adb->num_rows($result);
        //echo $nums_results;exit;
        if($nums_results>0){
      
            for($i=0;$i<$nums_results;$i++)
            {
                //判断提醒人是负责人还是创建人
                if($vals['reminder'] ==1 ){//负责人
                    $reminders=$adb->query_result($result,$i,'smownerid');
                    $recordid=$adb->query_result($result,$i,'recordid');
                }else{//创建人
                    $reminders=$adb->query_result($result,$i,'smcreatorid');
                    $recordid=$adb->query_result($result,$i,'recordid');
                }
               //提醒开始
               //echo $vals['remindway'].'=='.'<br>';
               if($vals['remindway'] == 2)
               {
                    foreach($ReemindMethodArr as $keys=>$val)
                    {
                       //提醒时间待处理
                        AutoReminds($vals['remindcontent'],'2014-05-20',$recordid,$vals['ruleid'],$reminders);
                        
                    } 
               }else{
                      
               }
            }
        }
        
    }
    
    //生成提醒后改写文件
    $newbuf = $date;
    $handle = fopen($file,'w+');
    //var_dump($handle);
    fputs($handle, $newbuf);
    fclose($file);
}
function AutoReminds($RemindsContent,$datetime,$record,$ruleid,$recieverid)
{
        global $adb;
        //echo $RemindsContent.'==='.$datetime.'==='.$record.'==='.$ruleid.'==='.$recieverid.'<br>';exit;
        $smownersql = 'select setype from ld_crmentity where crmid = '.$record.' limit 1;';
        $smownerresult = $adb->query($smownersql);
        $setype = $adb->query_result($smownerresult,0,'setype');
        $focus_rel =CRMEntity::getInstance('Reminds');
                           
    	$focus_rel->column_fields['date_time'] = $datetime;	   
        $focus_rel->column_fields['related_to']=$record;
        $focus_rel->column_fields['reltab']=$setype;
        
        $focus_rel->column_fields['recieverid']=$recieverid;
        
        $focus_rel->column_fields['status_rmd']='未读';
        $focus_rel->column_fields['content']=$RemindsContent;
        $focus_rel->column_fields['reminds_ruleid']=$ruleid;
        $focus_rel->mode="create";
      
        $focus_rel->save('Reminds'); ///exit();
}
function  getBasicrule($ruleid){
    global $adb;
    $sql="SELECT * from ld_remindcvstdfilter where cvid=?";
    $result=$adb->pquery($sql,array($ruleid));
    if($adb->num_rows($result) > 0)
    {
        $basicruleArr=array();
            $colunname=explode(":",$adb->query_result($result,0,'columnname'));
            $colunname=$colunname[1];
            $basicruleArr[]=array(
            'cvid'=>$adb->query_result($result,0,'cvid'),
            'columnname'=>$colunname,
            'stdfilter'=>$adb->query_result($result,0,'stdfilter'),
            'startdate'=>$adb->query_result($result,0,'startdate'),
            'enddate'=>$adb->query_result($result,0,'enddate')
        );
    }else{
        $basicruleArr=array();
    }
    
    return $basicruleArr;
}
function getAdvancedrule($ruleid){
    global $adb;
    $sql="SELECT * from ld_remindcvadvfilter where cvid =?";
    $result=$adb->pquery($sql,array($ruleid));
    if($adb->num_rows($result) > 0){
        for($i=0;$i<$adb->num_rows($result);$i++){
            $AdvancedArr[$i]=array(
                'cvid'=>$adb->query_result($result,0,'cvid'),
                'columnindex'=>$adb->query_result($result,$i,'columnindex'),
                'columnname'=>$adb->query_result($result,$i,'columnname'),
                'comparator'=>$adb->query_result($result,$i,'comparator'),
                'value'=>$adb->query_result($result,$i,'value'),
                'column_condition'=>$adb->query_result($result,$i,'column_condition')
            );
        }
    }else{
        $AdvancedArr=array();
    }
    
    
    return $AdvancedArr;
}
function getReemindMethod($ruleid){
    global $adb;
    $sql="SELECT * from ld_remindway where wayid =?";
    $result=$adb->pquery($sql,array($ruleid));
    if($adb->num_rows($result) > 0){
        $sqls="SELECT max(remindsday) as max_remindsday,min(remindsday) as min_remindsday  from ld_remindway where wayid =? GROUP BY wayid";
        $results=$adb->pquery($sqls,array($ruleid));
        for($i=0;$i<$adb->num_rows($result);$i++){
            $ReemindMethodArr[$i]=array(
                'wayid'=>$adb->query_result($result,$i,'wayid'),
                'remindsday'=>$adb->query_result($result,$i,'remindsday'),
                'sequence'=>$adb->query_result($result,$i,'sequence'),
                'max_remindsday'=>$adb->query_result($results,0,'max_remindsday'),
                'min_remindsday'=>$adb->query_result($results,0,'min_remindsday')
            );
        }
    }else{
        $ReemindMethodArr=array();
    }
    
    
    return $ReemindMethodArr;
}

//exit;
?>