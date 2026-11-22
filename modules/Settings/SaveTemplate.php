<?php
/********************************************
 *{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:20130219
**DESCRIPTION:组件模板保存
********************************************/

global $current_user,$adb;

$templatename = from_html(trim($_REQUEST['templatename']));

$mode=$_REQUEST['mode'];


if(isset($_REQUEST['dup_check']) && $_REQUEST['dup_check']!='') {
    if($mode!='edit'){
        $query='select templatename from ld_templates where templatename=?';
        $params=array($templatename);
        $result = $adb->pquery($query, $params);
        if($adb->num_rows($result)>0){
            echo getFixedLabel('LBL_TEMPLATENAME_EXIST');
            die;
        }
    }
}
    if(isset($_REQUEST['returnaction']) && $_REQUEST['returnaction'] != '')
	{
		$returnaction=$_REQUEST['returnaction'];        
	}
     
    if(isset($_REQUEST['mode']) && $_REQUEST['mode'] == 'create'){        
        insertTemplates($templatename,$current_user->id);
    }
    else{
        $templateid=$_REQUEST['templateid'];
        $templatename=$_REQUEST['templatename'];        
        updateTemplate($templateid,$templatename,$current_user->id);
    }
    exit();
    
    function insertTemplates($templatename,$userId){
       
        global $adb;
       
        $templateid=$adb->getUniqueID('ld_templates');              
        $query='insert into ld_templates(templateid,templatename,smcreatorid,createdtime,modifiedtime,deleted)';
        $query .='values(?,?,?,?,?,?)';
          
        $param=array($templateid,$templatename,$userId,date("Y-m-d G:i:s"),date("Y-m-d G:i:s"),1);
        $result=$adb->pquery($query,$param);   
        insertAssmably($templateid);
        insertRole($templateid);
    }
    function updateTemplate($templateid,$templatename,$userId){
        global $adb;
        
        $query='update ld_templates set templatename=?,modifiedby=?,modifiedtime=? where templateid=?';
        $adb->pquery($query,array($templatename,$userId,date("Y-m-d G:i:s"),$templateid));
        deleteTemplate2Assambly($templateid);
        insertAssmably($templateid);
        deleteTemplate2Role($templateid);
        insertRole($templateid);
        
    }
    function insertAssmably($templateid){
        global $adb;
        //组件
        $selected_assmably_col_string=$_REQUEST['selectedAssmablyColumnsString'];
    
        $assmablyIdArray=array();
        $assmablyNameArray=array();
      
        $assmably_array=explode(';',$selected_assmably_col_string);
        foreach($assmably_array as $assmably){
            
            $assmablyArray=explode('::',$assmably);
            if($assmablyArray[1]!=''){
                $assmablyIdArray[]=$assmablyArray[0];
                $assmablyNameArray[]=$assmablyArray[1];
            }
        }
        foreach($assmablyIdArray as $key=>$stuffid){
            $source = 'home';
			switch($stuffid){
				case '34':
				   $Stufftype = 'transaction';
				   break;
				case '35':
				case '36':
                case '65':
				   $Stufftype = 'saleskit';
				   break;
				case '19':
				case '1':
				case '4':
				case '5':
				case '9':
				   $Stufftype = 'chart';
				   break;
				case '24':
				   $Stufftype = 'reportLog';
				   break;
				case '33':
				   $Stufftype = 'transaction';
				   break;
				case '2':
				   $Stufftype = 'twotable';
				   break;
				case '21':
				   $Stufftype = 'notebook';
				   break;
                case '39':
                    $Stufftype = 'pendingapproval';//@edit:liushuai,2020-07-16,reason:1000923/首页，增加“待审批”组件
                    break;
                case '40':
                    $Stufftype = 'chart';//@edit:zhouxiaomei,2020-09-7,reason:首页，增加“近6个月目标完成情况”组件
                    break;
                case '41':
                    $Stufftype = 'chart';//@edit:zhouxiaomei,2020-09-7,reason:首页，增加“签约额月度同比”组件
                    break;
                case '42':
                    $Stufftype = 'chart';//@edit:zhouxiaomei,2020-09-7,reason:首页，增加“出库额月度同比”组件
                    break;
                case '43':
                    $Stufftype = 'calendar';//@edit:zhouxiaomei,2020-09-9,reason:首页，增加“日程管理”组件
                    break;
                case '44':
                    $Stufftype = 'chart';//@edit:zxm,2020-1010,reason:首页，增加“商机统计图”组件——按负责人和销售阶段统计
                    break;
                case '45':
                    $Stufftype = 'chart';//@edit:zxm,2020-1010,reason:首页，增加“商机统计图”组件——按客户所属行业和销售阶段统计
                    break;
                case '46' :
                    $Stufftype = 'marketingreport';//@edit:zxm,2020-1126,reason:誉帆-首页增加营销报告
                    break;
                case '47':
                case '64':

                    $Stufftype = 'marketingreport';//@edit:zxm,2020-1126,reason:誉帆-首页增加项目报告
                    break;
                case '48':
                    $Stufftype = 'chart';//@edit:zxm,2020-1127,reason:誉帆-首页增加对比营销报告
                    break;
                case '49':
                    $Stufftype = 'chart';//@edit:zxm,2020-1127,reason:誉帆-首页增加对比项目报告
                    break;
                case '50':
                case '56':
                     $Stufftype = 'rankinglist';//@edit:zxm,2020-1201,reason:誉帆-首页增加排行榜
                    break;
                case '51':
                    $Stufftype = 'yichongsaleskit';//@edit:zxm,2020-1202,reason:易冲 新的销售简报
                    break;
                case '52':
                case '54':
                     $Stufftype = 'marketingreport';
                     break;
                case '53':
                case '55':
                case '57':
                case '61':
                case '62':
                case '63':
                    $Stufftype = 'chart';
                    break;
                case '66'://zxm 20211213 服务看板
                    $Stufftype = 'servicekanban';
                    break;
				default:
				    //zxm 2021-0329 自定义统计图  除去以上的情况 需要判断
                    $stuffid_arr = explode('_',$stuffid);
                    if($stuffid_arr[0]=='customEchart'){
                        $source = 'customechart';
                        $stuffid = $stuffid_arr[1];
                        $Stufftype = 'echart';
                        $stripos = stripos($assmablyNameArray[$key],'_');
                        $assmablyNameArray[$key] = substr($assmablyNameArray[$key],$stripos+1);
                    }else{
                        $Stufftype = 'default';
                    }
			}
            $query='insert into ld_templatesstuff(stuffId,templateid,Stufftype,stuffsequence,stufftitle,`source`)';
            $query.='values(?,?,?,?,?,?)';
            $param=array($stuffid,$templateid,$Stufftype,$key,$assmablyNameArray[$key],$source);
            $adb->pquery($query,$param);
          
        }
    }
    function insertRole($templateid){
        global $adb;
        //角色
        $selected_role_col_string=$_REQUEST['selectedRoleColumnsString']; 
        $roleArray=Array();
        $member_array=explode(';',$selected_role_col_string);
        foreach($member_array as $member){
            $memSubArray=explode(':',$member);
            if($memSubArray[0] == 'roles'){
                $roleArray[]=$memSubArray[1];
            }        
        }
        foreach($roleArray as $profileid){
			$query='insert into ld_templatesrole(templateid,roleid,profileid)';
			$query.='values(?,?,?)';
            $param=array($templateid,$profileid,$profileid);
            $adb->pquery($query,$param);
			$adb->pquery('delete from ld_templatesrole where profileid = ? and templateid != ?',array($profileid,$templateid));
           
        }
    }
    function deleteTemplate2Assambly($templateid){
        global $adb;
        
        $query='delete from ld_templatesstuff where templateid=?';
        $adb->pquery($query,array($templateid));
       
    }
    function deleteTemplate2Role($templateid){
        global $adb;
       
        $query='delete from ld_templatesrole where templateid=?';
        $adb->pquery($query,array($templateid));
        
    }
?>