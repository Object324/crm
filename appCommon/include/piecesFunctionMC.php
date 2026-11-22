<?php

/**
 * Created by PhpStorm.
 * User: gyq
 * Date: 2017/7/26 0026
 * Time: 下午 5:02
 */
/*editor:gyq_40_6 date:20170726
reason:联系人拍名片新增，可能存在同时关联创建客户的情况。供应商联系人同理
*/
function set_camcard_related_create_mc($camcard_content,$module,$special_fieldname){
    $fieldname_content = $_REQUEST[$special_fieldname];
    //editor:gyq date:20170330 reason:未考虑前端CamCard_RelatedCreate传值时可能出现undefined情况，导致下方代码仍然执行
    if (!empty($camcard_content)&& $camcard_content!='undefined' && !empty($fieldname_content)) {
        //editor:20180911 0035205: 企业微信>灵当CRM>联系人模块>拍名片创建：创建联系人拍照后，生成的联系人信息了手动关联选择了客
        $_REQUEST['cardcontent'] =  $_REQUEST['CamCard_RelatedCreate'];
        //阻止后面方法重复调接口获取cardcontent
        $map_arr = array('Accounts'=>'accountname','Vendors'=>'vendorname');
        require_once(globalStatic::$root_directory . 'expansion/camcard/cls_camcard.php');
        $camobj = new cls_camcard();
        $moduleArr = $camobj->getDefaultModuleList('detail');
        $comparid = $moduleArr[$module]['comparid'];
        if(!empty($comparid)){
            $fieldComparison = $camobj->createViewDefaultValues_VCARD($comparid, $camcard_content);
            //拍名片带过来的值，要和接口返回值中的值保持一致，才会判断是否新建客户
            if(!empty($fieldComparison[$map_arr[$module]]) && $fieldname_content==$fieldComparison[$map_arr[$module]]) {
            }else{
                return $fieldname_content;
            }
        }else{
            return $fieldname_content;
        }
        global $adb,$current_user;
        $focus = CRMEntity::getInstance($module);
        $sql = 'select '.$focus->table_index.' from '.$focus->table_name.' where  '.$map_arr[$module].'=?   and deleted=0 order by createdtime desc limit 1';
        $result = $adb->pquery($sql, array($fieldname_content));
        if ($adb->num_rows($result) <= 0) {
            //$accountfocus = cls_Instance::get_module_Instance('Accounts');
            unset($_REQUEST['record']);
            setObjectValuesFromRequest($focus);
            if(!empty($comparid) && !empty($fieldComparison)){
                foreach ($focus->column_fields as $fieldname => $val) {
                    if (!empty($fieldComparison[$fieldname])) {
                        $defaultvalue = $fieldComparison[$fieldname];
                        $focus->column_fields[$fieldname] = $defaultvalue;
                    }
                }
            }
            $focus->column_fields[$map_arr[$module]] = $fieldname_content;
            $focus->column_fields['creator']=$current_user->id;
            $focus->column_fields['assigned_user_id']=$current_user->id;
            $focus->column_fields['description'] = '拍照创建';
            $focus->save($module);
            return $focus->id;
        } else {
            return $adb->query_result($result, 0, 0);
        }
    }else{
        return $fieldname_content;
    }
}
/*
 * editor:gyq_40_1 date:20170728 reason:对冲提醒
 * */
 function set_duplicate_reminds_ac($accountname_orign,$accountname)
{
    global $adb,$current_user;
    //客户重复是否弹出对冲提醒  1:否，0:是
    $dialogcontent = '';
    $accountname = trim($accountname);
    //zkt 20220815 BUG0055102https://81mis.com/kfbtest/ 【客户】报备提醒，接收到两条一样的报备
    $sql = "SELECT accountid,smownerid,ld_account.createdtime,ld_users.phone_mobile lsphone,ld_users.last_name lsname,'Accounts' as modulename 
              FROM ld_account LEFT JOIN ld_users on ld_users.id = smownerid  WHERE ld_account.deleted=0 and accountname = '" . $accountname . "'";
    //wym 240417 1000195 销售线索和客户增加一起查重功能，包括新增、导入（邹晓宇）
    $joinmodule=getUsersettingByLabel('Accounts','1','JointCheckDuplicate');
    if(!empty($joinmodule) && $joinmodule!='no'){
        $sql .= "union SELECT leadsid as accountid,smownerid,ld_leads.createdtime,ld_users.phone_mobile lsphone,ld_users.last_name lsname,'Leads' as modulename
          FROM ld_leads LEFT JOIN ld_users on ld_users.id = smownerid  WHERE ld_leads.deleted=0 and accountname = '" . $accountname . "'";
    }
    $sqlResult = $adb->pquery($sql, array());
    $sqlCount = $adb->num_rows($sqlResult);
    if ($sqlCount > 0) {
        require_once(globalStatic::$root_directory . "modules/Reminds/Reminds.php");
        $remindinfo = array();
        for ($i = 0; $i < $sqlCount; $i++) {
            $remindinfo[$i] = array(
                'accountid' => $adb->query_result($sqlResult, $i, 'accountid'),
                'smownername' => $adb->query_result($sqlResult, $i, 'lsname'),
                'smownerid' => $adb->query_result($sqlResult, $i, 'smownerid'),
                'createdtime' => $adb->query_result($sqlResult, $i, 'createdtime'),
                'smownerphone' => $adb->query_result($sqlResult, $i, 'lsphone'),
                'modulename' => $adb->query_result($sqlResult, $i, 'modulename')
            );
            /*生成弹框提示
             {accountname}已被{smowner}在{createdtime}报备，请联系{smowner}，联系电话：{smownerphone}*/
            //若手机号码为空，显示“暂未录入”
            if (empty($remindinfo[$i]['smownerphone'])) {
                $smphone = getFixedLabel('NOENTRY');
            } else {
                $smphone = $remindinfo[$i]['smownerphone'];
            }
            $newfieldvalue = '[<span style="color: red">' . $accountname . '</span>] ';

            if(!empty($joinmodule) && $joinmodule!='no'){ //wym 240425 BUG20240424-60 客户->客户报备，若开启联合查重后，客户报备弹窗提示信息前面增加显示单据模块名称
                $newfieldvalue = getTranstab($remindinfo[$i]['modulename']) . '[<span style="color: red">' . $accountname . '</span>] ';
            }else{
                $newfieldvalue = '[<span style="color: red">' . $accountname . '</span>] ';
            }
            $search = array('/{accountname}/is', '/{smowner}/is', '/{createdtime}/is', '/{smownerphone}/is');
            $replace = array($newfieldvalue, $remindinfo[$i]['smownername'], $remindinfo[$i]['createdtime'], $smphone);
            $dialogcontent .= preg_replace($search, $replace, getFixedLabel('REMINDOWNEFORHEDGING')) . '<br>';
			//chj 2021/2/22 客户重复报备提醒，提醒人收到的报备提醒内容增加报备人
            /*向负责人发送提醒
              您的{accountname}客户已有{operator}在{nowtime}正在尝试报备，联系电话：{operatorphone}*/
            if (empty($current_user->phone_mobile))  //若手机号码为空，显示“暂未录入”
                $otphone = getFixedLabel('NOENTRY');
            else
                $otphone = $current_user->phone_mobile;
            $date_time = date('Y-m-d H:i:s', time());
            $search = array('/{module}/is', '/{operator}/is', '/{nowtime}/is', '/{operator}/is', '/{operatorphone}/is');//BUG20240419-47 客户报备提醒，开启联合查重，线索客户重复提醒负责人后，负责人收到的报备提醒应该根据模块中英文标签动态显示
            $replace = array(getTranstab($remindinfo[$i]['modulename']),$current_user->last_name, $date_time, $current_user->last_name, $otphone);
            $remindcontent = preg_replace($search, $replace, getFixedLabel('REMINDOPEAFORHEDGING'));
            $focusreminds = new Reminds();
            $focusreminds->column_fields['related_to'] = $remindinfo[$i]['accountid'];
            $focusreminds->column_fields['reltab'] = $remindinfo[$i]['modulename']; //Accounts
            $focusreminds->column_fields['is_del_send'] = 0;
            $focusreminds->column_fields['is_del_rec'] = 0;
            $focusreminds->column_fields['status_rmd'] = '未读';
            $focusreminds->column_fields['date_time'] = $date_time;
            $focusreminds->column_fields['recieverid'] = $remindinfo[$i]['smownerid'];
            $focusreminds->column_fields['remindstype'] = 'AccountsHEDGINGREMIND';
            $focusreminds->mode = 'create';

            $focusreminds->column_fields['content'] = $remindcontent;
            $focusreminds->save('Reminds');

            //wyt 220805 XUQIU1000508 小程序增加消息提醒功能，关注公众号，接收提醒（第三版） 客户报备提醒
            $sql1="select GROUP_CONCAT(remindsid) as remindsid,related_to,reltab,content,remindstype,GROUP_CONCAT(DISTINCT ld_users.wx_userid) as wx_userid,Q.date_time,Q.reminds_ruleid from ld_reminds as Q
            inner JOIN ld_users on ld_users.id = Q.recieverid
            LEFT JOIN ld_tab on ld_tab.name=Q.reltab
            where Q.deleted = 0 
            AND Q.status_rmd = '未读' 
            AND Q.is_del_rec = 0 
            AND Q.push_to_offiaccount = 2 
            AND Q.remindsid = "."'{$focusreminds->id}'" ."
            and ld_users.push_wx_reminds = 1
            and ifnull(wxremindstype,'')<> 'immediately'
            and remindstype='AccountsHEDGINGREMIND'
            group by content ,related_to,reltab,date_time
            order by date_time desc ";

            $sqlResult1 = $adb->pquery($sql1, array());
            $rows=$adb->num_rows($sqlResult1);
            for($j=0;$j<$rows;$j++){
                
            $remindsid=$adb->query_result($sqlResult1,$j,'remindsid');
            $remindstype=$adb->query_result($sqlResult1,$j,'remindstype');
            $content=$adb->query_result($sqlResult1,$j,'content');
            $wx_userid=$adb->query_result($sqlResult1,$j,'wx_userid');
            $reltab=$adb->query_result($sqlResult1,$j,'reltab');
            $related_to=$adb->query_result($sqlResult1,$j,'related_to');
            $reminds_ruleid=$adb->query_result($sqlResult1,$j,'reminds_ruleid');

//         $userids=$wx_userid;
            $tmparray['userid']=array_unique($wx_userid);
            $tmparray['message']=$content;
            $tmparray['reltab']=$reltab;
            $tmparray['related_to']=$related_to;
            $tmparray['date_time']=date("Y-m-d H:i:s");
            $tmparray['remindtype']='jiaofu';
            $tmparray['reminds_ruleid']=$reminds_ruleid;
            $r_multi_content[]=$tmparray;

            $date_time=$adb->query_result($sqlResult1,$j,'date_time');
            $rel_tab=$adb->query_result($sqlResult1,$j,'reltab');
            $crmid=$adb->query_result($sqlResult1,$j,'related_to');
            $tmpfocus = CRMEntity::getInstance($rel_tab);
            $tmpfocus->retrieve_entity_info($crmid,$rel_tab);
            $col_fields = $tmpfocus->column_fields;
            $subject[$crmid]['table_code']=$col_fields[$tmpfocus->table_code];//编号
            $subject[$crmid]['subject'] = $col_fields[$tmpfocus->list_link_field];
            //交付提醒获取单据负责人
            $smownercolumname = $tmpfocus->getSmownerColumName();
            $smownerid = $col_fields[$smownercolumname];//负责人编号
            $swomnerlastname = getUserFullName($smownerid);
            $subject[$crmid]['smownername'] = $swomnerlastname;//单据负责人
            }

            if(is_array($r_multi_content))
            {
                require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/MessageCorpconversation.php");
                $remind = new MessageCorpconversation();
                //wyt 220921 BUG0056085 客户-报备提醒，公众号没有提醒，右上角有
                $remindsid_array=array($remindsid);
                $errorno = $remind->sendAllTypeRemindsImmediately($remindsid_array,$r_multi_content,'jiaofu',$subject);
                //zxm 20221116 公众号提醒消息单独请求
                if($remind->judgeOffiaccount()=='yes'){
                    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                    $offiaccount_remind = new cls_reminds_offiaccount();
                    $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($remindsid_array,'Approve',$subject);
                }
            }
           // $focusreminds->sendAllTypeRemindsImmediately();
        }
        $restStr = str_replace('##error##', "", $dialogcontent);
        return $restStr;
       /* $detail['fieldname'] = $accountname_orign;
        ConvertTojsonString('-1', $detail, $restStr);*/
    }
}

//获取产品图片路径，productid->imagearray
function getProductImageArr($productid,$columnname = 'imagename'){
    $imagepathArray = [];
    global $adb;
    $query = 'select productname, ld_attachments.path, ld_attachments.attachmentsid, 
    ld_attachments.newfile_name,ld_attachments.cloud_path,ld_attachments.storage_location,
    ld_crmentity.setype from ld_products 
    left join ld_seattachmentsrel on ld_seattachmentsrel.crmid=ld_products.productid 
    inner join ld_attachments on ld_attachments.attachmentsid=ld_seattachmentsrel.attachmentsid 
    inner join ld_crmentity on ld_crmentity.crmid = ld_attachments.attachmentsid 
    where ld_crmentity.setype="Products Image" and ld_seattachmentsrel.attachmentcolumnname=? and productid=?';
    //echo $query;echo $productid;die;
    $result = $adb->pquery($query, array($columnname,$productid));
    $noofrows = $adb->num_rows($result);
    for($i=0;$i<$noofrows;$i++){
        $attachmentsid = $adb->query_result($result,$i,'attachmentsid');
        $name = urlencode(decode_html($adb->query_result($result,$i,'newfile_name')));
        $storage_location = $adb->query_result($result,$i,'storage_location');
        if($storage_location == 'cos'){
            $imgpath = $adb->query_result($result, $i, 'cloud_path');
        }
        else{
            // $imgpath=$this->getUserImage($userimgpath,$userimgname,$attachmentsid);
            $path = $adb->query_result($result,$i,'path');
            $imgpath = $path.$attachmentsid.'_'.$name;   
            if(!file_exists($imgpath)){
                $imgpath = $path.$name;
            }
        }
        $imagepathArray[$i]['path'] = $imgpath;
    }
    return $imagepathArray;
}