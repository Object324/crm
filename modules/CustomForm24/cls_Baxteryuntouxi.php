<?php

class cls_Baxteryuntouxi
{
    public function __construct()
    {


    }

    //匹配病人信息
    public function matchPatient($crmid,$userId,$patientname,$hospitalID,$phone,$address,$sychScenario,$verifytime,$address_province,$buypill_province,$accountid,$match_way,$Pendingid,$modifiedby,$scene,$cf_6085){
        global $adb;
        //匹配条件：姓名+插管医院id+电话。或者 2、姓名+插管医院id+家庭地址。
        //$data=array("cf_6043"=>"张三","cf_6070"=>"282206","cf_6107"=> "17877878715","cf_6048"=>"湖北省武汉市东西湖区长青街田园大道99号","cf_6208"=>"",'cf_6121'=>'2023-02-15','customform24_no'=>'ZDYBD24-14','bill_state'=>'上海','cf_6485'=>'上海');
        //file_put_contents(globalStatic::$root_directory.'abc.txt',date("Y-m-d H:i:s")."\r\n".json_encode($_REQUEST,JSON_UNESCAPED_UNICODE),FILE_APPEND);
        //file_put_contents(globalStatic::$root_directory.'baxter/yuntouxi_requesttime.txt',"\r\n开始时间".date('Y-m-d H:i:s').",crmid:".$crmid,FILE_APPEND);

//ifnull(ld_customform24scf.cf_6085,'0000-00-00')='0000-00-00'
        if(($scene=='5'||$scene=='0')&&!(!empty($modifiedby) && $modifiedby != 1 && $accountid !=0 && $cf_6085<'1900-01-01')){//同步场景为5和0和空无需匹配
            $updatesql= 'delete from baxter_yuntouxi where crmid=? and id=? and sychscenario=?';
            $adb->pquery($updatesql, array($crmid,$Pendingid,$scene));
            return;
        }
        else if($cf_6085>'1900-01-01') {
            //20231031 需求:云透析公众号多次传场景值为2为3的场景时，增加是否已经匹配上病人的判断，只要有匹配的病人，则对已经匹配上的病人的状态进行变更，场景3需要对掉队原因为非死亡的病人进行转归（在掉队转归记录模块新增一条转归记录，同时更新病人状态为Active）

            //检查是否已经匹配过病人
            $checksql = "select accountid as pms_accountid from ld_customform24 where accountid>0 and customform24id = ?";
            $checkresult = $adb->pquery($checksql, array($crmid));
            if ($adb->num_rows($checkresult) > 0) {
                $userId_pms = $adb->query_result($checkresult, 0, 'pms_accountid');
                $manualSQL = 'select account.rating as pms_status,accountscf.cf_5428 as reason from ld_account account 
left join ld_accountscf accountscf on account.accountid=accountscf.accountid                                                                 
where account.accountid=? and account.deleted=0';
                $manualresult = $adb->pquery($manualSQL, array($userId_pms));

                if ($adb->num_rows($manualresult) > 0) {
                    $patientStatus_pms = $adb->query_result($manualresult, 0, 'pms_status');
                    $dropout_reason = $adb->query_result($manualresult, 0, 'reason');
                    if ($scene == '2' && in_array($patientStatus_pms, array("New", "Unreachable"))) {// 场景2 更新状态为Active
                        $this->updatePatientStatus($userId_pms);
                    } elseif ($scene == '3' && $patientStatus_pms == "Dropout" && $dropout_reason != "死亡") {// 场景3 创建转归记录并更新状态为Active
                        $this->CreateTransferRecord($userId_pms);//创建掉队转归记录
                        $this->updatePatientStatus($userId_pms);
                    }

                    $msg['userId'] = $userId;
                    $msg['patientStatus'] = 'Active';
                    $msg['matchStatus'] = 'Success';

                    $this->backPatientStatus($msg, $crmid, $Pendingid, $scene);//调用接口
                    return $msg;

                }

                return;
            }
        }
            if (!empty($modifiedby) && $modifiedby != 1 && $accountid !=0 && $cf_6085<'1900-01-01') {//手动匹配
                $matchStatus = 'Success';//匹配成功

                $manualSQL = 'select account.rating as pms_status,accountscf.cf_5428 as reason from ld_account account 
left join ld_accountscf accountscf on account.accountid=accountscf.accountid                                                                 
where account.accountid=?';
                $result = $adb->pquery($manualSQL, array($accountid));
                $userId_pms = $accountid;

                if($adb->num_rows($result) > 0) {
                    $patientStatus_pms = $adb->query_result($result, 0, 'pms_status');
                    $dropout_reason = $adb->query_result($result, 0, 'reason');
                }

                $verifymsg=$this->ChangeDetail(6,'','',$crmid,'',$accountid,'');
                $customform24id = $crmid;
//                $this->relatePatientToWx($userId_pms, $customform24id);//手动匹配应该是已经关联上的状态
                $patientStatus = $patientStatus_pms;
                if($patientStatus_pms == 'Active'){

                    $this->updateVerifyTime($verifytime,$userId_pms);

                }else if ($patientStatus_pms == 'New' || $patientStatus_pms == 'Unreachable') {

                    $this->updatePatientStatus($userId_pms);
                    $patientStatus = 'Active';
                    $this->updateVerifyTime($verifytime,$userId_pms);

                } else if ($patientStatus_pms == 'Dropout' ) {//判断上次掉队原因是否为死亡,创建掉队转归记录
                    $patientStatus=$patientStatus_pms;
                    $this->updateVerifyTime($verifytime,$userId_pms);

                }

                $this->ChangeDetail('','','','','',$accountid,$scene);

                if (!empty($modifiedby) && $modifiedby != '' && $modifiedby != 1 && $match_way!='自动匹配') {//手动匹配 不更新状态
                    $matchsql='update ld_customform24scf set cf_6084=?,cf_6085=?,cf_6216=?,cf_6086=?,cf_6059=? where customform24id=?';
                    $adb->pquery($matchsql, array('是', date('Y-m-d H:i:s'),$patientStatus,$patientStatus_pms,'手动匹配',$crmid));
                }

                file_put_contents(globalStatic::$root_directory.'baxter/yuntouxi_matchlog.txt',"\r\n".date('Y-m-d H:i:s')."：手动匹配：".json_encode(array("Pendingid"=>$Pendingid,"modifiedby"=>$modifiedby,"match_way"=>$match_way,"patientStatus"=>$patientStatus,"patientStatus_pms"=>$patientStatus_pms,"crmid"=>$crmid,),JSON_UNESCAPED_UNICODE),FILE_APPEND);

            } else {
                $query = "select  '姓名+插管医院ID+电话' as match_type,account.accountid as pms_accountid,account.rating as pms_status,accountscf.cf_5428 as reason 
from ld_account account 
left join ld_accountscf accountscf on account.accountid=accountscf.accountid 
LEFT JOIN ld_customform02 customform02 ON account.customform02_id = customform02.customform02id
LEFT JOIN ld_customform02 customform02_2 ON account.customform02_id2 = customform02_2.customform02id
where account.accountname='".$patientname."'
and (customform02.customform02_no='".$hospitalID."' or customform02_2.customform02_no='".$hospitalID."')
and locate('".$phone."',accountscf.cf_6140)>0

union
select  '姓名+购药医院ID+电话' as match_type,account.accountid as pms_accountid,account.rating as pms_status,accountscf.cf_5428 as reason 
from ld_account account 
left join ld_accountscf accountscf on account.accountid=accountscf.accountid 
LEFT JOIN ld_customform02 customform02 ON account.customform02_id = customform02.customform02id
LEFT JOIN ld_customform02 customform02_2 ON account.customform02_id2 = customform02_2.customform02id
where account.accountname='".$patientname."'
and (customform02.customform02_no='".$buypill_province."' or customform02_2.customform02_no='".$buypill_province."')
and locate('".$phone."',accountscf.cf_6140)>0

union 
select  '姓名+插管医院ID+家庭地址' as match_type,account.accountid as pms_accountid,account.rating as pms_status,accountscf.cf_5428 as reason 
from ld_account account 
left join ld_accountscf accountscf on account.accountid=accountscf.accountid 
LEFT JOIN ld_customform02 customform02 ON account.customform02_id = customform02.customform02id
LEFT JOIN ld_customform02 customform02_2 ON account.customform02_id2 = customform02_2.customform02id
where account.accountname='".$patientname."'
and (customform02.customform02_no='".$hospitalID."' or customform02_2.customform02_no='".$hospitalID."')
and ifnull(nullif(account.bill_street,''),'地址为空不能匹配')='".$address."'

union 
select  '姓名+购药医院ID+家庭地址' as match_type,account.accountid as pms_accountid,account.rating as pms_status,accountscf.cf_5428 as reason 
from ld_account account 
left join ld_accountscf accountscf on account.accountid=accountscf.accountid 
LEFT JOIN ld_customform02 customform02 ON account.customform02_id = customform02.customform02id
LEFT JOIN ld_customform02 customform02_2 ON account.customform02_id2 = customform02_2.customform02id
where account.accountname='".$patientname."'
and (customform02.customform02_no='".$buypill_province."' or customform02_2.customform02_no='".$buypill_province."')
and ifnull(nullif(account.bill_street,''),'地址为空不能匹配')='".$address."'
";

                $result=$adb->pquery($query,array());

                if($adb->num_rows($result) > 0){
                    $userId_pms = $adb->query_result($result, 0, 'pms_accountid');
                    $patientStatus_pms = $adb->query_result($result, 0, 'pms_status');
                    $dropout_reason = $adb->query_result($result, 0, 'reason');
                    $match_type = $adb->query_result($result, 0, 'match_type');//自动匹配时更新匹配类型
                }


            if ($scene == '1c' || $scene == '1d' ) {//场景1-1、场景3

                $verifymsg=$this->ChangeDetail(4,'','',$crmid,'','','');

            }else if( $scene == '3'){

                $verifymsg=$this->ChangeDetail(5,'','',$crmid,'','','');

            }



            if ($userId_pms != '' && !empty($userId_pms) && $userId_pms!=0) {
                $matchStatus = 'Success';//匹配成功
                $this->ChangeDetail('','','','','',$userId_pms,$scene);
                $this->ChangeDetail(7,'','',$crmid,'',$userId_pms,'');

                $customform24id = $crmid;
                $this->relatePatientToWx($userId_pms, $customform24id);//关联客户信息


                if ($scene == '1a' || $scene == '1b' || $scene == '2') {//场景1、场景2
                    $verifymsg=$this->ChangeDetail(3,'','',$crmid,'','','');

                    $patientStatus = $patientStatus_pms;
                    if ($patientStatus_pms == 'New' || $patientStatus_pms == 'Unreachable') {

                        $this->updatePatientStatus($userId_pms);
                        $patientStatus = 'Active';

                    }
                } else if ($scene == '1c' || $scene == '1d' || $scene == '3') {//场景1-1、场景3

                    $patientStatus = $patientStatus_pms;
                    if($scene == '3' && $patientStatus_pms == 'Active'){

                        $this->updateVerifyTime($verifytime,$userId_pms);

                    }else if ($patientStatus_pms == 'New' || $patientStatus_pms == 'Unreachable') {

                        $this->updatePatientStatus($userId_pms);
                        $patientStatus = 'Active';

                        if($scene == '3'){

                            $this->updateVerifyTime($verifytime,$userId_pms);

                        }
                    } else if ($patientStatus_pms == 'Dropout' && $dropout_reason != '死亡') {//判断上次掉队原因是否为死亡,创建掉队转归记录

                        $this->CreateTransferRecord($userId_pms);//创建掉队转归记录
                        $this->updatePatientStatus($userId_pms);
                        $patientStatus = 'Active';//状态转为active;

                        if($scene == '3'){

                            $this->updateVerifyTime($verifytime,$userId_pms);

                        }
                    }else if($patientStatus_pms == 'Dropout' && $dropout_reason == '死亡'){
                        $patientStatus=$patientStatus_pms;
                    }

                } else if ($scene == '4') {//场景4，不更改状态。

//                    $verifymsg=$this->ChangeDetail(3,'','',$crmid,'','','');
//                    $patientStatus = $patientStatus_pms;
//BUG20240718-41 240718
                    if ($patientStatus_pms == 'Dropout' || $patientStatus_pms == 'Active' ) {

                        $verifymsg=$this->ChangeDetail(3,'','',$crmid,'','','');

                        $patientStatus = $patientStatus_pms;

                    } else if ($patientStatus_pms == 'New' || $patientStatus_pms == 'Unreachable'){


                        $verifymsg=$this->ChangeDetail(3,'','',$crmid,'','','');

                        $this->updatePatientStatus($userId_pms);

                        $patientStatus = 'Active';//状态转为active;

                    }

                }


                file_put_contents(globalStatic::$root_directory.'baxter/yuntouxi_matchlog.txt',"\r\n".date('Y-m-d H:i:s')."：自动匹配：".json_encode(array("Pendingid"=>$Pendingid,"modifiedby"=>$modifiedby,"match_way"=>$match_way,"patientStatus"=>$patientStatus,"patientStatus_pms"=>$patientStatus_pms,"crmid"=>$crmid,),JSON_UNESCAPED_UNICODE),FILE_APPEND);
                if (!empty($modifiedby) && $modifiedby != '' && $modifiedby != 1 && $match_way!='自动匹配') {//手动匹配 不更新状态
                    $matchsql='update ld_customform24scf set cf_6084=?,cf_6085=?,cf_6216=?,cf_6086=?,cf_6059=? where customform24id=?';
                    $adb->pquery($matchsql, array('是', date('Y-m-d H:i:s'),$patientStatus,$patientStatus_pms,'手动匹配',$crmid));
                }else{
                    $this->ChangeDetail(1,$patientStatus,$patientStatus_pms,$crmid,$match_type,'','');
                }
            } else {
                $matchStatus = 'failure';//匹配失败。
                $patientStatus = '';//匹配失败病人状态为空。

                if($scene == '1a' || $scene == '1b' || $scene == '2' || $scene == '4'){
                    $verifymsg['isVerified']='0';
                    $verifymsg['verifyType']='';
                }

                //未匹配上的病人有疑似重复的写到分录中
                $hos_province = $this->getHospitalInfo($hospitalID);//插管医院省份
                $hos_buy = $this->getHospitalInfo($buypill_province);//插管医院省份
                $RepePatient = $this->getRepePatient($patientname, $hos_province, $address_province, $hos_buy, $address, $phone,$crmid);
            }
            }


        $msg['userId']=$userId;
        if($patientStatus!=''){
            $msg['patientStatus']=$patientStatus;
        }
        $msg['matchStatus']=$matchStatus;
        $msg['isVerified']=$verifymsg['isVerified'];
        $msg['verifyType']=$verifymsg['verifyType'];



        $this->backPatientStatus($msg,$crmid,$Pendingid,$scene);//调用接口
        //file_put_contents(globalStatic::$root_directory.'baxter/yuntouxi_requesttime.txt',"\r\n结束时间".date('Y-m-d H:i:s').",crmid:".$crmid,FILE_APPEND);
        return $msg;
    }

    //匹配完成更新赋值
    public function ChangeDetail($type='',$patientStatus='',$patientStatus_pms='',$crmid,$match_type='',$accountid='',$scene=''){
        global $adb;
        $verifymsg['isVerified']='';
        $verifymsg['verifyType']='';

        if($type==1){//匹配成功赋值
            $matchsql='update ld_customform24scf set cf_6084=?,cf_6085=?,cf_6216=?,cf_6086=?,cf_6059=?,cf_6087=?  where customform24id=?';
            $adb->pquery($matchsql, array('是', date('Y-m-d H:i:s'),$patientStatus,$patientStatus_pms,'自动匹配',$match_type,$crmid));
        }else if($type==2){
            $matchsql='update ld_customform24scf set cf_6083=? where customform24id=?';
            $adb->pquery($matchsql, array('是', $crmid));
        }else if($type==3){//是否已验证cf_6221  验证方式cf_6853
            $verifymsg['isVerified']=1;
            $verifymsg['verifyType']='PMS自动匹配验证';
            $selectsql="select cf_6853 from ld_customform24scf where customform24id=? and ifnull(cf_6853,'')=''";
            $result=$adb->pquery($selectsql, array($crmid));
            $nums=$adb->num_rows($result);
            if($nums>0){
                $matchsql='update ld_customform24scf set cf_6221=?,cf_6853=? where customform24id=?';
                $adb->pquery($matchsql, array($verifymsg['isVerified'],$verifymsg['verifyType'], $crmid));
            }
            return $verifymsg;
        }else if($type==4){//场景1-1
            $verifymsg['isVerified']=1;
            $verifymsg['verifyType']='二维码验证';
            $matchsql='update ld_customform24scf set cf_6221=?,cf_6853=? where customform24id=?';
            $adb->pquery($matchsql, array($verifymsg['isVerified'],$verifymsg['verifyType'],$crmid));
            return $verifymsg;
        }else if($type==5){//场景3
            $verifymsg['isVerified']=1;
            $verifymsg['verifyType']='条形码验证';
            $matchsql='update ld_customform24scf set cf_6221=?,cf_6853=? where customform24id=?';
            $adb->pquery($matchsql, array($verifymsg['isVerified'],$verifymsg['verifyType'], $crmid));
            return $verifymsg;
        }else if($type==6){//手动匹配
            $verifymsg['isVerified']=1;
            $verifymsg['verifyType']='PMS手动匹配验证';
            $selectsql="select cf_6853 from ld_customform24scf where customform24id=? and ifnull(cf_6853,'')=''";
            $result=$adb->pquery($selectsql, array($crmid));

            $updatesql='update ld_account set customform24_id =? where accountid=?';
            $adb->pquery($updatesql, array($crmid,$accountid));

            $nums=$adb->num_rows($result);
            if($nums>0) {
                $matchsql = 'update ld_customform24scf set cf_6221=?,cf_6853=? where customform24id=?';
                $adb->pquery($matchsql, array($verifymsg['isVerified'], $verifymsg['verifyType'], $crmid));
            }
            return $verifymsg;
        }else if($type==7){//自动匹配
            $updatesql='update ld_account set customform24_id =? where accountid=?';
            $adb->pquery($updatesql, array($crmid,$accountid));
            $updatesql2='update ld_accountscf set cf_6156 =? where accountid=?';
            $adb->pquery($updatesql2, array('微信联系病人',$accountid));
        }else if( $scene=='Active' || $scene=='Dropout'){
            $updatesql='update ld_account set customform24_id =? where accountid=?';
            $adb->pquery($updatesql, array($crmid,$accountid));
            $updatesql2='update ld_accountscf set cf_6156 =? where accountid=?';
            $adb->pquery($updatesql2, array('微信联系病人',$accountid));
        }

    }

    //依据验证时间更新上次拜访日期
    public function updateVerifyTime($verifytime,$userId_pms){

        global $adb;
        $updateQuery = 'update ld_accountscf set cf_5846=? where accountid=?';
        $adb->pquery($updateQuery, array(date("Y-m-d H:i:s"), $userId_pms));

    }


    //更新病人状态信息
    public function updatePatientStatus($accountid){
        global $adb;
        $query='update ld_account set rating="Active" where accountid="'.$accountid.'"';//更新患者信息表患者状态。
        $adb->pquery($query,array());
    }

    //创建转归记录
    public function CreateTransferRecord($accountid){
        global $adb;

        $Transferfocus = CRMEntity::getInstance('CustomForm05');

        $sql='select c05.customform05id,c05scf.cf_5653 from ld_customform05 c05 
left join ld_customform05scf c05scf on c05.customform05id = c05scf.customform05id
where c05.accountid=? and c05scf.cf_5648=? and c05.deleted=0
ORDER BY c05scf.cf_5651 desc,c05.customform05id desc LIMIT 1';
        $result=$adb->pquery($sql,array($accountid,'掉队'));
        if($adb->num_rows($result) > 0) {
            $dropout_reason = $adb->query_result($result, 0, 'cf_5653');
        }
        //映射关系
        if($dropout_reason=='移植'){$dropout_reason='移植转归';}
        else if($dropout_reason=='失访'){$dropout_reason='失访转归';}
        else if($dropout_reason=='经济原因放弃'){$dropout_reason='经济原因转归';}
        else if($dropout_reason=='过渡性透析'){$dropout_reason='过渡性透析转归';}
        else if($dropout_reason=='转用其他品牌产品'){$dropout_reason='其他品牌产品转归';}
        else if($dropout_reason=='转血透治疗'){$dropout_reason='血透转归';}
        else if($dropout_reason=='其它'){$dropout_reason='其它转归';}
        else if($dropout_reason=='无法获知'){$dropout_reason='无法获知';}

        $Transferfocus->column_fields['cf_5648']='转归';
        $Transferfocus->column_fields['cf_5660']=date('Y-m-d');//默认当前日期
        $Transferfocus->column_fields['account_id']=$accountid;
        $Transferfocus->column_fields['cf_5662']=$dropout_reason;
        $Transferfocus->column_fields['cf_5663']='其他';
        $Transferfocus->column_fields['assigned_user_id']=1;
        $Transferfocus->column_fields['smcreatorid']=1;

        $Transferfocus->save('CustomForm05');

    }

    //关联客户微信病人和病人模块
    public function relatePatientToWx($accountid,$customform24id){
        global $adb;
        $query='update ld_customform24 set accountid=? where customform24id=? ';
        $adb->pquery($query,array($accountid,$customform24id));
    }

    //疑似重复病人写到分录中
    public function getRepePatient($patientname,$hos_province,$address_province,$hos_buy,$address,$phone,$crmid){
        global $adb;

        if($phone==''){
            $phone='000isnone';
        }
        if($address_province==''){
            $address_province='000isnone';
        }
        if($hos_buy==''){
            $hos_buy='000isnone';
        }
        if($hos_province==''){
            $hos_province='000isnone';
        }

        $sql="select GROUP_CONCAT(type) as seemrepeat_type,tmp.* from
(
SELECT DISTINCT
	'姓名+插管医院省份' AS 'type',ld_account.accountid AS billid,ld_accountscf.cf_5319 AS 'sf426',ld_accountscf.cf_5323 AS 'sf427',ld_accountscf.cf_5678 AS phone1,ld_accountscf.cf_5674 AS phone2,
	ld_accountscf.cf_5686 AS phone3,ld_accountscf.cf_5690 AS phone4,ld_accountscf.cf_5682 AS phone5,ld_accountscf.cf_6455 AS phone6,concat_ws(',',nullif(ifnull(cf_5678, ''),''),nullif(ifnull(cf_5674, ''),''),nullif(ifnull(cf_5686, ''),''),
	nullif(ifnull(cf_5690, ''),''),nullif(ifnull(cf_5682, ''),''),nullif(ifnull(cf_6455, ''),'')) AS phone,ld_account.bill_street AS 'sf429',ld_account.customform02_id AS 'sf430',ld_accountscf.cf_5392 AS 'sf431',ld_accountscf.cf_5964 AS 'sf432',
	ld_account.customform02_id2 AS 'sf433',ld_account.rating AS 'sf434',ld_accountscf.cf_5454 AS 'sf435',ld_accountscf.cf_5420 AS 'sf436',ld_accountscf.cf_5428 AS 'sf437','病人模块' AS 'sf438'
FROM ld_account
LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
left join ld_customform02 on ld_customform02.customform02id=ld_account.customform02_id 
left join ld_customform02scf on ld_customform02scf.customform02id =ld_customform02.customform02id
WHERE ld_account.deleted = 0 AND ld_account.accountname = '".$patientname."' AND ld_customform02scf.cf_5333 = '".$hos_province."'

UNION
SELECT DISTINCT '姓名+插管医院省份' AS 'type',ld_customform24.customform24id AS billid,ld_customform24scf.cf_6044 AS 'sf426',ld_customform24scf.cf_6045 AS 'sf427','' AS phone1,'' AS phone2,'' AS phone3,
'' AS phone4,'' AS phone5,'' AS phone6,ld_customform24scf.cf_6107 AS phone,ld_customform24scf.cf_6048 AS 'sf429',ld_customform02.customform02id AS 'sf430',ld_customform24scf.cf_6206 AS 'sf431','' AS 'sf432',
zhongduan.customform02id AS 'sf433',ld_customform24scf.cf_6050 AS 'sf434',ld_customform24scf.cf_6223 AS 'sf435','' AS 'sf436','' AS 'sf437','微信病人模块' AS 'sf438'
FROM ld_customform24
LEFT JOIN ld_customform24scf ON ld_customform24scf.customform24id = ld_customform24.customform24id
LEFT JOIN ld_customform02 ON ld_customform24scf.cf_6070 = ld_customform02.customform02_no
LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id = ld_customform02.customform02id
left join ld_customform02 zhongduan on zhongduan.customform02_no=ld_customform24scf.cf_6071 
left join ld_customform02scf zhongduan2 on zhongduan2.customform02id =zhongduan.customform02id 
WHERE ld_customform24.deleted = 0 AND ifnull(ld_customform24.accountid,0) <> 0
AND ld_customform24scf.cf_6043 ='".$patientname."' AND ld_customform02scf.cf_5333 = '".$hos_province."' 

UNION
SELECT DISTINCT
	'姓名+居住省份' AS 'type',ld_account.accountid AS billid,ld_accountscf.cf_5319 AS 'sf426',ld_accountscf.cf_5323 AS 'sf427',ld_accountscf.cf_5678 AS phone1,ld_accountscf.cf_5674 AS phone2,
	ld_accountscf.cf_5686 AS phone3,ld_accountscf.cf_5690 AS phone4,ld_accountscf.cf_5682 AS phone5,ld_accountscf.cf_6455 AS phone6,concat_ws(',',nullif(ifnull(cf_5678, ''),''),nullif(ifnull(cf_5674, ''),''),nullif(ifnull(cf_5686, ''),''),
	nullif(ifnull(cf_5690, ''),''),nullif(ifnull(cf_5682, ''),''),nullif(ifnull(cf_6455, ''),'')) AS phone,ld_account.bill_street AS 'sf429',ld_account.customform02_id AS 'sf430',ld_accountscf.cf_5392 AS 'sf431',ld_accountscf.cf_5964 AS 'sf432',
	ld_account.customform02_id2 AS 'sf433',ld_account.rating AS 'sf434',ld_accountscf.cf_5454 AS 'sf435',ld_accountscf.cf_5420 AS 'sf436',ld_accountscf.cf_5428 AS 'sf437','病人模块' AS 'sf438'
FROM ld_account
LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
left join ld_customform02 on ld_customform02.customform02id=ld_account.customform02_id 
left join ld_customform02scf on ld_customform02scf.customform02id =ld_customform02.customform02id 
WHERE ld_account.deleted = 0 AND ld_account.accountname = '".$patientname."' AND ld_account.bill_state = '".$address_province."'

UNION
SELECT DISTINCT '姓名+居住省份' AS 'type',ld_customform24.customform24id AS billid,ld_customform24scf.cf_6044 AS 'sf426',ld_customform24scf.cf_6045 AS 'sf427','' AS phone1,'' AS phone2,'' AS phone3,
'' AS phone4,'' AS phone5,'' AS phone6,ld_customform24scf.cf_6107 AS phone,ld_customform24scf.cf_6048 AS 'sf429',ld_customform02.customform02id AS 'sf430',ld_customform24scf.cf_6206 AS 'sf431','' AS 'sf432',
zhongduan.customform02id AS 'sf433',ld_customform24scf.cf_6050 AS 'sf434',ld_customform24scf.cf_6223 AS 'sf435','' AS 'sf436','' AS 'sf437','微信病人模块' AS 'sf438'
FROM ld_customform24
LEFT JOIN ld_customform24scf ON ld_customform24scf.customform24id = ld_customform24.customform24id
LEFT JOIN ld_customform02 ON ld_customform24scf.cf_6070 = ld_customform02.customform02_no
LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id = ld_customform02.customform02id
left join ld_customform02 zhongduan on zhongduan.customform02_no=ld_customform24scf.cf_6071 
left join ld_customform02scf zhongduan2 on zhongduan2.customform02id =zhongduan.customform02id 
WHERE ld_customform24.deleted = 0 AND ifnull(ld_customform24.accountid,0) <> 0
AND ld_customform24scf.cf_6043 ='".$patientname."' AND ld_customform24.bill_state = '".$address_province."' 



UNION
SELECT DISTINCT '姓名+购药医院省份' AS 'type',ld_customform24.customform24id AS billid,ld_customform24scf.cf_6044 AS 'sf426',ld_customform24scf.cf_6045 AS 'sf427','' AS phone1,'' AS phone2,'' AS phone3,
'' AS phone4,'' AS phone5,'' AS phone6,ld_customform24scf.cf_6107 AS phone,ld_customform24scf.cf_6048 AS 'sf429',ld_customform02.customform02id AS 'sf430',ld_customform24scf.cf_6206 AS 'sf431','' AS 'sf432',
zhongduan.customform02id AS 'sf433',ld_customform24scf.cf_6050 AS 'sf434',ld_customform24scf.cf_6223 AS 'sf435','' AS 'sf436','' AS 'sf437','微信病人模块' AS 'sf438'
FROM ld_customform24
LEFT JOIN ld_customform24scf ON ld_customform24scf.customform24id = ld_customform24.customform24id
LEFT JOIN ld_customform02 ON ld_customform24scf.cf_6070 = ld_customform02.customform02_no
LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id = ld_customform02.customform02id
left join ld_customform02 zhongduan on zhongduan.customform02_no=ld_customform24scf.cf_6071 
left join ld_customform02scf zhongduan2 on zhongduan2.customform02id =zhongduan.customform02id 
WHERE ld_customform24.deleted = 0 AND ifnull(ld_customform24.accountid,0) <> 0
AND ld_customform24scf.cf_6043 ='".$patientname."' AND ld_customform02scf.cf_5333 = '".$hos_buy."'  

union
SELECT DISTINCT
 '姓名+购药医院省份' AS 'type',ld_account.accountid AS billid,ld_accountscf.cf_5319 AS 'sf426',ld_accountscf.cf_5323 AS 'sf427',ld_accountscf.cf_5678 AS phone1,ld_accountscf.cf_5674 AS phone2,
 ld_accountscf.cf_5686 AS phone3,ld_accountscf.cf_5690 AS phone4,ld_accountscf.cf_5682 AS phone5,ld_accountscf.cf_6455 AS phone6,concat_ws(',',nullif(ifnull(cf_5678, ''),''),nullif(ifnull(cf_5674, ''),''),nullif(ifnull(cf_5686, ''),''),
 nullif(ifnull(cf_5690, ''),''),nullif(ifnull(cf_5682, ''),''),nullif(ifnull(cf_6455, ''),'')) AS phone,ld_account.bill_street AS 'sf429',ld_account.customform02_id AS 'sf430',ld_accountscf.cf_5392 AS 'sf431',ld_accountscf.cf_5964 AS 'sf432',
 ld_account.customform02_id2 AS 'sf433',ld_account.rating AS 'sf434',ld_accountscf.cf_5454 AS 'sf435',ld_accountscf.cf_5420 AS 'sf436',ld_accountscf.cf_5428 AS 'sf437','病人模块' AS 'sf438'
FROM ld_account
LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
left join ld_customform02 on ld_customform02.customform02id=ld_account.customform02_id2 
left join ld_customform02scf on ld_customform02scf.customform02id =ld_customform02.customform02id
WHERE ld_account.deleted = 0 AND ld_account.accountname = '".$patientname."' AND ld_customform02scf.cf_5333 = '".$hos_buy."'


UNION
SELECT DISTINCT
	'地址' AS 'type',ld_account.accountid AS billid,ld_accountscf.cf_5319 AS 'sf426',ld_accountscf.cf_5323 AS 'sf427',ld_accountscf.cf_5678 AS phone1,ld_accountscf.cf_5674 AS phone2,
	ld_accountscf.cf_5686 AS phone3,ld_accountscf.cf_5690 AS phone4,ld_accountscf.cf_5682 AS phone5,ld_accountscf.cf_6455 AS phone6,concat_ws(',',nullif(ifnull(cf_5678, ''),''),nullif(ifnull(cf_5674, ''),''),nullif(ifnull(cf_5686, ''),''),
	nullif(ifnull(cf_5690, ''),''),nullif(ifnull(cf_5682, ''),''),nullif(ifnull(cf_6455, ''),'')) AS phone,ld_account.bill_street AS 'sf429',ld_account.customform02_id AS 'sf430',ld_accountscf.cf_5392 AS 'sf431',ld_accountscf.cf_5964 AS 'sf432',
	ld_account.customform02_id2 AS 'sf433',ld_account.rating AS 'sf434',ld_accountscf.cf_5454 AS 'sf435',ld_accountscf.cf_5420 AS 'sf436',ld_accountscf.cf_5428 AS 'sf437','病人模块' AS 'sf438'
FROM ld_account
LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
left join ld_customform02 on ld_customform02.customform02id=ld_account.customform02_id2 
left join ld_customform02scf on ld_customform02scf.customform02id =ld_customform02.customform02id 
WHERE ld_account.deleted = 0 AND ld_account.bill_street = '".$address."' AND char_length(ld_account.bill_street)>6

UNION
SELECT DISTINCT '地址' AS 'type',ld_customform24.customform24id AS billid,ld_customform24scf.cf_6044 AS 'sf426',ld_customform24scf.cf_6045 AS 'sf427','' AS phone1,'' AS phone2,'' AS phone3,
'' AS phone4,'' AS phone5,'' AS phone6,ld_customform24scf.cf_6107 AS phone,ld_customform24scf.cf_6048 AS 'sf429',ld_customform02.customform02id AS 'sf430',ld_customform24scf.cf_6206 AS 'sf431','' AS 'sf432',
zhongduan.customform02id AS 'sf433',ld_customform24scf.cf_6050 AS 'sf434',ld_customform24scf.cf_6223 AS 'sf435','' AS 'sf436','' AS 'sf437','微信病人模块' AS 'sf438'
FROM ld_customform24
LEFT JOIN ld_customform24scf ON ld_customform24scf.customform24id = ld_customform24.customform24id
LEFT JOIN ld_customform02 ON ld_customform24scf.cf_6070 = ld_customform02.customform02_no
LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id = ld_customform02.customform02id
left join ld_customform02 zhongduan on zhongduan.customform02_no=ld_customform24scf.cf_6071 
left join ld_customform02scf zhongduan2 on zhongduan2.customform02id =zhongduan.customform02id 
WHERE ld_customform24.deleted = 0 AND ifnull(ld_customform24.accountid,0) <> 0
AND ld_customform24scf.cf_6048 = '".$address."' AND char_length(ld_customform24scf.cf_6048)>6

UNION
SELECT DISTINCT
	'电话' AS 'type',ld_account.accountid AS billid,ld_accountscf.cf_5319 AS 'sf426',ld_accountscf.cf_5323 AS 'sf427',ld_accountscf.cf_5678 AS phone1,ld_accountscf.cf_5674 AS phone2,
	ld_accountscf.cf_5686 AS phone3,ld_accountscf.cf_5690 AS phone4,ld_accountscf.cf_5682 AS phone5,ld_accountscf.cf_6455 AS phone6,concat_ws(',',nullif(ifnull(cf_5678, ''),''),nullif(ifnull(cf_5674, ''),''),nullif(ifnull(cf_5686, ''),''),
	nullif(ifnull(cf_5690, ''),''),nullif(ifnull(cf_5682, ''),''),nullif(ifnull(cf_6455, ''),'')) AS phone,ld_account.bill_street AS 'sf429',ld_account.customform02_id AS 'sf430',ld_accountscf.cf_5392 AS 'sf431',ld_accountscf.cf_5964 AS 'sf432',
	ld_account.customform02_id2 AS 'sf433',ld_account.rating AS 'sf434',ld_accountscf.cf_5454 AS 'sf435',ld_accountscf.cf_5420 AS 'sf436',ld_accountscf.cf_5428 AS 'sf437','病人模块' AS 'sf438'
FROM ld_account
LEFT JOIN ld_accountscf ON ld_accountscf.accountid = ld_account.accountid
left join ld_customform02 on ld_customform02.customform02id=ld_account.customform02_id 
left join ld_customform02scf on ld_customform02scf.customform02id =ld_customform02.customform02id 
WHERE ld_account.deleted = 0 AND (cf_5678 = '".$phone."' or cf_5674='".$phone."' or cf_5686='".$phone."' or cf_5690='".$phone."' or cf_5682='".$phone."' or cf_6455='".$phone."')

UNION
SELECT DISTINCT '电话' AS 'type',ld_customform24.customform24id AS billid,ld_customform24scf.cf_6044 AS 'sf426',ld_customform24scf.cf_6045 AS 'sf427','' AS phone1,'' AS phone2,'' AS phone3,
'' AS phone4,'' AS phone5,'' AS phone6,ld_customform24scf.cf_6107 AS phone,ld_customform24scf.cf_6048 AS 'sf429',ld_customform02.customform02id AS 'sf430',ld_customform24scf.cf_6206 AS 'sf431','' AS 'sf432',
zhongduan.customform02id AS 'sf433',ld_customform24scf.cf_6050 AS 'sf434',ld_customform24scf.cf_6223 AS 'sf435','' AS 'sf436','' AS 'sf437','微信病人模块' AS 'sf438'
FROM ld_customform24
LEFT JOIN ld_customform24scf ON ld_customform24scf.customform24id = ld_customform24.customform24id
LEFT JOIN ld_customform02 ON ld_customform24scf.cf_6070 = ld_customform02.customform02_no
LEFT JOIN ld_customform02scf ON ld_customform02scf.customform02id = ld_customform02.customform02id
left join ld_customform02 zhongduan on zhongduan.customform02_no=ld_customform24scf.cf_6071 
left join ld_customform02scf zhongduan2 on zhongduan2.customform02id =zhongduan.customform02id 
WHERE ld_customform24.deleted = 0 AND ifnull(ld_customform24.accountid,0) <> 0
AND ld_customform24scf.cf_6107='".$phone."'
)as tmp where billid <> '".$crmid."' GROUP BY billid";
        $result=$adb->pquery($sql,array());
        $nums=$adb->num_rows($result);

        $RepePatient=array();

        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $RepePatient['type'] = $adb->query_result($result, $i, 'seemrepeat_type');
                $RepePatient['billid'] = $adb->query_result($result, $i, 'billid');
                $RepePatient['sf426'] = $adb->query_result($result, $i, 'sf426');
                $RepePatient['sf427'] = $adb->query_result($result, $i, 'sf427');
                $RepePatient['phone'] = $adb->query_result($result, $i, 'phone');
                $RepePatient['sf429'] = $adb->query_result($result, $i, 'sf429');
                $RepePatient['sf430'] = $adb->query_result($result, $i, 'sf430');
                $RepePatient['sf431'] = $adb->query_result($result, $i, 'sf431');
                $RepePatient['sf432'] = $adb->query_result($result, $i, 'sf432');
                $RepePatient['sf433'] = $adb->query_result($result, $i, 'sf433');
                $RepePatient['sf434'] = $adb->query_result($result, $i, 'sf434');
                $RepePatient['sf435'] = $adb->query_result($result, $i, 'sf435');
                $RepePatient['sf436'] = $adb->query_result($result, $i, 'sf436');
                $RepePatient['sf437'] = $adb->query_result($result, $i, 'sf437');
                $RepePatient['sf438'] = $adb->query_result($result, $i, 'sf438');

                $this->addRepePatient($crmid, $RepePatient);
                //file_put_contents(globalStatic::$root_directory.'abc.txt',date("Y-m-d H:i:s")."\r\n".$i,FILE_APPEND);
            }
            $this->ChangeDetail(2,'','',$crmid,'','','');
        }


        return $RepePatient;
    }

    //新增疑似病人到分录中
    public function addRepePatient($crmid,$RepePatient){
        global $adb;

            $sql='select max(sequence) from ld_customform24detail where id =?';
            $tmpseq=$adb->pquery($sql,array($crmid));

            if($adb->num_rows($tmpseq) > 0) {
            $sequence = $adb->query_result($tmpseq, 0, 'sequence');
            }

            $sequence=$sequence+1;
            $insertSQL='insert into ld_customform24detail(id,sequence,line_accounts_id) select ?,?,? from dual where not exists (select 1 from ld_customform24detail where line_accounts_id=? and id=?)';
            $adb->pquery($insertSQL,array($crmid,$sequence,$RepePatient['billid'],$RepePatient['billid'],$crmid));
            $effectrow=$adb->getLastInsertID();

            if($effectrow>0){
                $sql2='select max(lineitem_id) as lineitem_id from ld_customform24detail';
                $result2=$adb->pquery($sql2,array());
                if($adb->num_rows($result2) > 0) {
                    $lineitem_id = $adb->query_result($result2, 0, 'lineitem_id');
                }
                $insertSQL2='insert into ld_customform24detailscf(lineitem_id,sf424,sf426,sf427,sf428,sf429,sf430,sf431,sf432,sf433,sf434,sf435,sf436,sf437,sf438) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?) ';
                $adb->pquery($insertSQL2,array($lineitem_id,$RepePatient['type'],$RepePatient['sf426'],$RepePatient['sf427'],$RepePatient['phone'],$RepePatient['sf429'],$RepePatient['sf430'],$RepePatient['sf431'],$RepePatient['sf432'],$RepePatient['sf433'],$RepePatient['sf434'],$RepePatient['sf435'],$RepePatient['sf436'],$RepePatient['sf437'],$RepePatient['sf438']));
            }

    }

    //获取插管医院信息
    public function getHospitalInfo($hospitalID){

        global $adb;
        $query='select cf_5333 from ld_customform02 left join ld_customform02scf  ON ld_customform02scf.customform02id = ld_customform02.customform02id where ld_customform02.customform02_no=?';
        $result=$adb->pquery($query,array($hospitalID));
        if($adb->num_rows($result) > 0) {
            $hos_province = $adb->query_result($result, 0, 'cf_5333');
        }
        return $hos_province;
    }

    //调用接口返回匹配状态信息
    public function backPatientStatus($updateString,$crmid,$Pendingid='',$scene=''){
        error_reporting(E_ALL^E_NOTICE^E_WARNING);
        header("content-type:text/html;charset=utf-8");
        $root_dir=dirname(__FILE__);
        include($root_dir.'/includefile.php');
        global $baxteryuntouxi_url;
//        $conurl='https://admin.baitoujia.com.cn/api/capd_patient/miniprogram/syncPatient/updatePatientStatus';//请求路径(测试)
        $conurl=$baxteryuntouxi_url;
        $method="POST";//请求方法
//      $updateString  =array('matchStatus' => 'Success','userId' => 'D10003907', 'patientStatus' => 'Active');//测试数据

        ksort($updateString);//排序升序
        $appKey = mt_rand(1000000000, 9999999999);//获取10位随机数字字符串

        foreach($updateString as $key=>$value){//拼接字符串
            if( $value!=''){
                $sign.=$key.$value;
            }
        }
        $sign=md5($sign.$appKey);//取md5值
        $data['sign'] = $sign;
        $header = array(
            'Content-Type: application/json',
            'method:POST',
            'app_key:'.$appKey,
            'sign:'.$sign
        );
        $con=$this->wx_post($conurl,$header,$updateString);
//      $con=json_encode($con,JSON_UNESCAPED_UNICODE);
//      file_put_contents(globalStatic::$root_directory.'abc.txt',date("Y-m-d H:i:s")."\r\n".$sign,FILE_APPEND);

        global $adb;
        if(!empty($Pendingid) && $Pendingid!='' && ((!empty($scene) && $scene!='') || $scene === 0)){
            if($con['status']==1){
                $updatesql= 'delete from baxter_yuntouxi where crmid=? and id=? and sychscenario=?';
                $adb->pquery($updatesql, array($crmid,$Pendingid,$scene));
            }else if($con['status']!=1 && ($scene=='Active' || $scene=='Dropout')){
                $updatesql="update baxter_yuntouxi set status=2 where crmid=? and id=? and sychscenario=?";
                $adb->pquery($updatesql,array($crmid,$Pendingid,$scene));
            }else {
                $updatesql="update baxter_yuntouxi set status=0 where crmid=? and id=? and sychscenario=?";
                $adb->pquery($updatesql,array($crmid,$Pendingid,$scene));
            }
        }
    }

    function wx_post($url,$header,$data){
        //将post的数据转换为json格式
        $post_data=json_encode($data,JSON_UNESCAPED_UNICODE);
        $chr = curl_init();
        curl_setopt ($chr, CURLOPT_URL, $url );
        curl_setopt ($chr, CURLOPT_SSL_VERIFYPEER, FALSE );
        curl_setopt ($chr, CURLOPT_SSL_VERIFYHOST, FALSE );
        curl_setopt($chr, CURLOPT_HEADER, 0);//设置header
        curl_setopt($chr, CURLOPT_HTTPHEADER, $header);
        // curl_setopt($chr, CURLOPT_CONNECTTIMEOUT, 1);
        curl_setopt($chr, CURLOPT_POST, true);
        curl_setopt($chr, CURLOPT_POSTFIELDS, $post_data);
        curl_setopt($chr, CURLOPT_RETURNTRANSFER, true);
        $output = curl_exec($chr);
        $request_time=date('Y-m-d H:i:s',time());
        if($error=curl_error($chr)){
            die($error);
        }
        curl_close($chr);
        //数据转换成数组格式
        $jsoninfo = json_decode($output, true);

        $response_time=date('Y-m-d H:i:s',time());
        $this->baitelog($url,$post_data,$output,$request_time,$response_time,'百特云透析返回匹配状态接口');

        return $jsoninfo;
    }

    //日志记录
    function baitelog($url='',$request='',$response='',$request_time='',$response_time='',$comment=''){
        global $adb;
        //url请求地址,接收数据的无 request请求数据 response响应 request_time请求时间 response_time响应时间 comment接口说明
        $logSQL='insert into ld_requestlog(url,request,response,request_time,response_time,comment) values(?,?,?,?,?,?)';
        $adb->pquery($logSQL,array($url,$request,$response,$request_time,$response_time,$comment));
    }

    //匹配待处理单据（微信病人）
    function getPendingOrder(){
        global $adb;
        $sql="select baxter_yuntouxi.id,baxter_yuntouxi.crmid,baxter_yuntouxi.sychscenario,ld_customform24.customform24_no,ld_customform24scf.cf_6043,ld_customform24scf.cf_6070,ld_customform24scf.cf_6071,ld_customform24scf.cf_6107,ld_customform24scf.cf_6048,ld_customform24scf.cf_6208,ld_customform24scf.cf_6121,ld_customform24.bill_state,ld_customform24scf.cf_6485,IFNULL(ld_customform24.accountid,0) as accountid,ld_customform24scf.cf_6059,ld_customform24.modifiedby,ifnull(ld_customform24scf.cf_6085,'0000-00-00') as cf_6085
 from baxter_yuntouxi left join ld_customform24 on baxter_yuntouxi.crmid=ld_customform24.customform24id left join ld_customform24scf on baxter_yuntouxi.crmid=ld_customform24scf.customform24id  where baxter_yuntouxi.status<>1 and baxter_yuntouxi.status<>2 limit 30";

        $result=$adb->pquery($sql,array());
        $nums=$adb->num_rows($result);
        $tmpcrmid='';
        /*$tmpPendingid='';
        for($i=0;$i<$nums;$i++){
            $tmpcrmid.=$adb->query_result($result, $i, 'crmid').',';
            $tmpPendingid.=$adb->query_result($result, $i, 'id').',';
        }
        $tmpcrmid=rtrim($tmpcrmid,',');
        $tmpPendingid=rtrim($tmpPendingid,',');
        $updatesql="update baxter_yuntouxi set status=1 where  id in ($tmpPendingid)";
        $adb->pquery($updatesql,array());*/

        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $Pendingid=$adb->query_result($result, $i, 'id');//待处理顺序id;
                $crmid = $adb->query_result($result, $i, 'crmid');//待处理微信病人id;
                $userId = $adb->query_result($result, $i, 'customform24_no');//对接唯一id
                $patientname = $adb->query_result($result, $i, 'cf_6043');//cf_6043姓名;
                $hospitalID = $adb->query_result($result, $i, 'cf_6070');//插管医院id
                $phone = $adb->query_result($result, $i, 'cf_6107');//病人手机;
                $address = $adb->query_result($result, $i, 'cf_6048');//家庭住址
                $sychScenario = $adb->query_result($result, $i, 'cf_6208');//同步场景
                $verifytime = $adb->query_result($result, $i, 'cf_6121');//扫码验证时间
                $address_province = $adb->query_result($result, $i, 'bill_state');//居住省份
                $buypill_province = $adb->query_result($result, $i, 'cf_6071');//购药医院id
                $accountid = $adb->query_result($result, $i, 'accountid');//关联病人id
                $match_way = $adb->query_result($result, $i, 'cf_6059');//判断上一次匹配方式
                $modifiedby = $adb->query_result($result, $i, 'modifiedby');//判断手动匹配还是自动匹配
                $scene = $adb->query_result($result, $i, 'sychscenario');//云透析传过来的场景值
                $cf_6085 = $adb->query_result($result, $i, 'cf_6085');//BUG0065900 判断匹配日期ld_customform24scf.cf_6085>'1900-01-01', 则不再走手动匹配流程

                $this->matchPatient($crmid,$userId,$patientname,$hospitalID,$phone,$address,$sychScenario,$verifytime,$address_province,$buypill_province,$accountid,$match_way,$Pendingid,$modifiedby,$scene,$cf_6085);

                $updatesql="update baxter_yuntouxi set status=1 where  id = ?";
                $adb->pquery($updatesql,array($Pendingid));

            }
        }

        $query="select baxter_yuntouxi.id,baxter_yuntouxi.crmid,baxter_yuntouxi.sychscenario,ld_customform24.customform24_no,ld_customform24.bill_state,ld_customform24.accountid,ld_customform24.modifiedby
 from baxter_yuntouxi left join ld_customform24 on baxter_yuntouxi.crmid=ld_customform24.customform24id  where baxter_yuntouxi.status=2 ";

        $result_query=$adb->pquery($query,array());
        $nums_query=$adb->num_rows($result_query);
        $tmpcrmid_query='';
        $tmpPendingid_query='';
        for($i=0;$i<$nums;$i++){
            $tmpcrmid_query.=$adb->query_result($result_query, $i, 'crmid').',';
            $tmpPendingid_query.=$adb->query_result($result_query, $i, 'id').',';
        }
        $tmpcrmid_query=rtrim($tmpcrmid_query,',');
        $tmpPendingid_query=rtrim($tmpPendingid_query,',');
        $updatesql_query="update baxter_yuntouxi set status=3 where crmid in ($tmpcrmid_query) and id in ($tmpPendingid_query)";
        $adb->pquery($updatesql_query,array());

        if($nums_query>0){
            for($i=0;$i<$nums_query;$i++){
                $Pendingid=$adb->query_result($result_query, $i, 'id');//待处理顺序id;
                $crmid = $adb->query_result($result_query, $i, 'crmid');//待处理微信病人id;
                $userId = $adb->query_result($result_query, $i, 'customform24_no');//对接唯一id
                $scene = $adb->query_result($result_query, $i, 'sychscenario');//云透析传过来的场景值

                $msg2['userId']=$userId;
                $msg2['patientStatus']=$scene;
                $msg2['matchStatus']='Success';//匹配成功

                $this->backPatientStatus($msg2,$crmid,$Pendingid,$scene);//调用接口

            }
        }



    }


}