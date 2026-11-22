<?php

/**
 * Created by PhpStorm.
 * User: Administrator
 * Date: 2016/11/16 0016
 * Time: 下午 5:02
 */
crm_load_class_file('cls_DetailViewWX', 'WeiXinApp/detail');
class cls_SocialPromotion_DetailViewWX extends cls_DetailViewWX
{
    public function getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode){
        global $adb,$current_user;
        $blockinfos = parent::getDetailBlockInformation($module, $result, $col_fields, $tabid, $block_label, $mode);
        //需要展示的列名
        $columnnames = array('activityname','mappingmodule','smcreatorid','assigned_user_id','createdtime','modifiedtime');
        //分享设置所需字段
        $shareColumns= array('sharetitle','shareintroduction','sharepicture');
        $useBlocks= array();
        foreach ($blockinfos as $temp){

                $useBlocks = array_merge($useBlocks,$temp['fieldinfo']);

        }
        $newFileds =array();
        $shareFields= array();
        foreach ($useBlocks as $key=>$field){
            if(in_array($field['fieldname'],$columnnames)){
                if($field['fieldname'] == 'mappingmodule'){
                    $newFileds[$key] = $field;
                    $newFileds[$key]['value_name'] = getTranstab($field['value_name']);
                    $newFileds[$key]['text'] = getTranstab($field['text']);
                }else{
                    $newFileds[] = $field;
                }
            }
            if(in_array($field['fieldname'],$shareColumns)){
                $shareFields[] = $field;
            }
        }
        require_once(globalStatic::$root_directory.'modules/SocialPromotion/SocialPromotionConfig.php');
        $htmlFileName = $prefix.$this->record.$suffix;
        global $site_URL;
        $shareUrl =$site_URL.'/'.$htmlPath.$htmlFileName.'?uid='.$current_user->id;
        $shareFields[] = array(
            'fieldname'=>'shareurl',
            'typeofdata'=>'V~O',
            'fieldlabel'=>'分享链接',
            'text'=>$shareUrl,
            'uitype'=>'17', //17为url
            'isadmin'=>'1',
            'value_name'=>$shareUrl,
            'phone'=>'no',
            'type'=>1
        );


        //        删除其他多余区块
        if(count($blockinfos)>1){
            for ($i =1 ;$i<=count($blockinfos)+1;$i++){
                unset($blockinfos[$i]);
            }
        }

        $blockinfos[0]['fieldinfo'] = $newFileds;
        $tmpBlock['blocklabel'] = '推广设置';
        $tmpBlock['display_status'] = '1';

        $tmpBlock['fieldinfo'] =$shareFields;

////        推广码 模块
//        $tmpBlock['blocklabel'] = '推广链接';
//        $tmpBlock['dispalay_status'] = '0';
//        $tmpBlock['fieldinfo'] =array();
//
//        //获取当前id的负责人
//        $sql = 'select smownerid  from ld_socialpromotion where socialpromotionid=?';
//        $result = $adb->pquery($sql,array($col_fields['record_id']));
//        $smownerid = $adb->query_result($result,0,0);
//
//        crm_load_class_file('cls_share','include/Functions/Share');
//        $objShare = new cls_share();
//        $shareUsers  = $objShare->getSelectedUser($col_fields['record_id']);
//        $shareUsers = array_filter(array_unique(array_merge(array($col_fields['smcreatorid']),array($smownerid),explode(',',$shareUsers['userid']))));
//
//
//        //加载二维码配置文件
//        require_once (globalStatic::$root_directory.'modules/SocialPromotion/SocialPromotionConfig.php');
//        $shareUserValue = makeUserQcrodeArr($prefix,$suffix,$htmlPath,$col_fields['record_id'],$qrcodePath,$currentModule,$shareUsers);
//        $shareArr=array();
//        foreach ($shareUserValue as $key =>$val){
//            $arr =array(
//                'fieldlabel' =>$val['lastname'],
//                'fieldname'=>'',
//                'isadmin'=>'',
//                'phone'=>'no',
//                'text'=>$val['shareUrl'],
//                'type'=>'1',
//                'typeofdata'=>'V~O',
//                'uitype'=>'1',
//                'value_name'=>$val['shareUrl']
//            );
//            $shareArr[] =$arr;
//        }
//        $tmpBlock['fieldinfo'] =$shareArr;

        //赋值推广码区块
        $blockinfos[] =$tmpBlock;
        $blockinfos =array_values($blockinfos);
        return $blockinfos;
    }
    //表单推广详情页面不需要按钮
    protected function init_detailButton(){
        $this->jsonArr['list2']='';
        return false;
    }
}