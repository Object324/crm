<?php
global $adb,$current_user;
$mode = $_REQUEST['mode'];
$frommodule = $_REQUEST['frommodule'];

if($mode != 'save'){
    //表单码编辑界面
    
    //规定所有可在表单码中选择的字段类型
    $bigtype_arr = array('text','textarea','longtextarea','picklist','multipicklist','checkbox','mobile','phone',
            'date','time','datetime','qq','email','rfax','fileattachment','handwriting','url','currency','number');
    $smarty=new lingdangCRM_Smarty;
    $Fields = Field::getInstance($frommodule,$adb);
    $module_field = $Fields->getModuleFields();
    $all_field_arr = array(); 
    //遍历所有已启用字段
    foreach($module_field as $fieldinfo){
        if(empty($fieldinfo)||!$fieldinfo){
            continue;
        }
        $bigtype = $fieldinfo->getBigType();
        $allowedit = $fieldinfo->get_allowedit();
        $displaytype = $fieldinfo->getDisplaytype();
        $uitype = $fieldinfo->getUIType();
        $columnanme = $fieldinfo->getColumnName();
        //增加手写签名字段
        if($uitype != 222 && $columnanme != 'accountid' &&(!in_array($bigtype,$bigtype_arr)||$allowedit=='no'||$displaytype!=1) ){
            continue;
        }
        //图片类型的字段与附件区分开
        if($uitype=='69'||$uitype=='1108'){
            continue;
        }
        //团队成员字段不显示
        if($uitype=='154'){
            continue;
        }
        $fieldid = $fieldinfo->getFieldid();
        $fieldlabel = $fieldinfo->getFieldLabel();
        $allowedit = 'yes';
        if($columnanme == 'accountid'){
            $allowedit = 'no';
        }
        $all_field_arr[$fieldid] = array('columnname'=>$columnanme,'fieldlabel'=>$fieldlabel,'allowedit'=>$allowedit);
    }
    //若该模块带产品分录或其他分录则单据码增加产品分录字段
    $detail_arr=array();
    $focus = CRMEntity::getInstance($frommodule);
    $array_total_exist='no';
    $array_total=array();
    if($frommodule != 'ServiceCharge' && (get_file_address($frommodule,"ProductDetails")||get_file_address($frommodule,$frommodule."DetailFieldsHtml"))){
        $detailfieldobj = $focus->detailfieldobj;
        $detail_module_field = $detailfieldobj->getModuleFields();
        if(get_file_address($frommodule,"ProductDetails")){
            foreach($detail_module_field as $detail_fieldinfo){
                if(empty($detail_fieldinfo)||!$detail_fieldinfo){
                    continue;
                }
                $detail_bigtype = $detail_fieldinfo->getBigType();
                $detail_newline= $detail_fieldinfo->getNewLine();
                $detail_columnname=$detail_fieldinfo->getColumnName();
                $detail_fieldlabel = $detail_fieldinfo->getFieldLabel();
                if(in_array($detail_bigtype,array('image'))){
                    continue;
                }

                //ls 20221231  XUQIU1000922：表单码-分录可编辑(过滤分录不可编辑的字段)
                $allowedit = 'yes';
                if($detail_fieldinfo->getSaveDataBase()=='no'){
                    $allowedit = 'no';
                }
                else if($detail_fieldinfo->getedit_permission()!='0'){
                    $allowedit = 'no';
                }else if($detail_fieldinfo->getUIType() == 70 || $detail_bigtype=='reference'){
                    $allowedit = 'no';//产品名称及关联选择单据
                } else if (in_array($detail_bigtype,array('selectsource'))) {
                    $allowedit = 'no';//选择源单等类型不允许编辑
                }

                //排除设置调整按钮标签
                if($detail_newline==1&&$detail_columnname!='total'){
                    continue;
                }

                if($detail_columnname=='subtotal'){
                    continue;
                }
                if(get_file_address($frommodule,"ProductDetails")){
                    $detail_fieldid = $detail_fieldinfo->getProductToolFieldid();
                }else{
                    $detail_fieldid = $detail_fieldinfo->getTabDetailFieldid();
                }
                //合计字段排最后
                if($detail_columnname=='total'){
                    continue;//设置返回合计后，前端并没有使用，因此先不允许设置，需求变动去掉continue即可。
                    $array_total_exist='yes';
                    $total_fieldid = $detail_fieldid;
                    $total_fieldinfo=array('columnname'=>$detail_columnname,'fieldlabel'=>$detail_fieldlabel,'allowedit'=>'no');
                    continue;
                }
                $detail_arr[$detail_fieldid] = array('columnname'=>$detail_columnname,'fieldlabel'=>$detail_fieldlabel,'allowedit'=>$allowedit);
            }
        }else if(get_file_address($frommodule,$frommodule."DetailFieldsHtml")){
            foreach($detail_module_field as $detail_fieldinfo){
                if(empty($detail_fieldinfo)||!$detail_fieldinfo){
                    continue;
                }
                $detail_fieldtype = $detail_fieldinfo->getFieldType();
                $detail_newline= $detail_fieldinfo->getNewLine();
                $detail_columnname=$detail_fieldinfo->getColumnName();
                $detail_fieldlabel = $detail_fieldinfo->getFieldLabel();
                if(in_array($detail_fieldtype,array('Image'))){
                    continue;
                }

                //ls 20221231  XUQIU1000922：表单码-分录可编辑(过滤分录不可编辑的字段)
                $allowedit = 'yes';
                if($detail_fieldinfo->getSaveDataBase()=='no'){
                    $allowedit = 'no';
                }
                else if($detail_fieldinfo->getedit_permission()!='0'){
                    $allowedit = 'no';
                }else if($detail_fieldtype=='Reference'){
                    $allowedit = 'no';//关联选择单据
                } else if (in_array($detail_fieldtype,array('SelectSource'))) {
                    $allowedit = 'no';//选择源单等类型不允许编辑
                }

                //排除设置调整按钮标签
                if($detail_newline==1&&$detail_columnname!='total'){
                    continue;
                }

                if($detail_columnname=='subtotal'){
                    continue;
                }

                $detail_fieldid = $detail_fieldinfo->getTabDetailFieldid();

                //合计字段排最后
                if($detail_columnname=='total'){
                    continue;
                    $array_total_exist='yes';
                    $total_fieldid = $detail_fieldid;
                    $total_fieldinfo=array('columnname'=>$detail_columnname,'fieldlabel'=>$detail_fieldlabel,'allowedit'=>'no');
                    continue;
                }
                $detail_arr[$detail_fieldid] = array('columnname'=>$detail_columnname,'fieldlabel'=>$detail_fieldlabel,'allowedit'=>$allowedit);
            }
        }

        if($array_total_exist=='yes'){
            $detail_arr[$total_fieldid]=$total_fieldinfo;
            //$detail_arr=array_merge($detail_arr,$array_total);
        }

    }

    $smarty->assign('DETAILARRAY',$detail_arr);
    $smarty->assign('ALLFIELDS',$all_field_arr);
    
    $templateid= $_REQUEST['templateid'];
    if($templateid>0){
        $detailed_field_arr=array();
        $qrcode_field_arr = array();
        $sql = 'select template_content from ld_qrcode_template where qrcodetemplateid = ?';
        $result = $adb->pquery($sql,array($templateid));
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            $template_content_json = $adb->query_result($result,0,'template_content');
            $template_content = ldcrm_json_decode(html_entity_decode($template_content_json));
            $duration = $template_content['duration'];
            $endatetime = $template_content['endatetime'];
            $limit = $template_content['limit'];
        }
        
        $sql = 'select * from ld_qrcode_fieldsdetail where qrcodetemplateid = ? and fieldidtype="normal"';
        $result = $adb->pquery($sql,array($templateid));
        $num_rows = $adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++){
                $tmp_fieldid = $adb->query_result($result,$i,'fieldid');
                $qrcode_field_arr[$tmp_fieldid] = array('label'=>$adb->query_result($result,$i,'qrcode_fieldlabel'),
                                                        'view'=>$adb->query_result($result,$i,'viewpermit'),
                                                        'input'=>$adb->query_result($result,$i,'editpermit'),
                                                        'edit'=>$adb->query_result($result,$i,'editcontentpermit'),
                                                        'approve'=>$adb->query_result($result,$i,'approvepermit'),
                                                        'require'=>$adb->query_result($result,$i,'requirecontent')
                                                        );
            }
        }
        //产品明细或者其他附录明细的状态数组
        $query='select * from ld_qrcode_fieldsdetail where qrcodetemplateid = ? and fieldidtype="detailed"';
        $resulty=$adb->pquery($query,array($templateid));
        $row_number=$adb->num_rows($resulty);
        if($row_number>0){
            for($i=0;$i<$row_number;$i++){
                $detailed_fieldid=$adb->query_result($resulty,$i,'fieldid');
                $detailed_field_arr[$detailed_fieldid] = array('label'=>$adb->query_result($resulty,$i,'qrcode_fieldlabel'),
                                                        'view'=>$adb->query_result($resulty,$i,'viewpermit'),
                                                        'input'=>$adb->query_result($resulty,$i,'editpermit'),
                                                        'edit'=>$adb->query_result($resulty,$i,'editcontentpermit'),
                                                        'approve'=>$adb->query_result($resulty,$i,'approvepermit'),
                                                        'require'=>$adb->query_result($resulty,$i,'requirecontent')
                                                        );
                
            }
        }
        $smarty->assign('DETAILQRCODEFIELDS',$detailed_field_arr);
        $smarty->assign('QRCODEFIELDS',$qrcode_field_arr);
        $smarty->assign('DURATION',$duration);
        $smarty->assign('ENDDATETIME',$endatetime);
        $smarty->assign('LIMIT',$limit);
        $smarty->assign('QRCODEFIELDS',$qrcode_field_arr);
    }
    $trans_labelarr = array('label'=>getFixedLabel('FORMCODE').getFixedLabel('LISTFIELDS'),
                            'view'=>getFixedLabel('ALLOWVIEWING'),
                            'input'=>getFixedLabel('WHETHERTOEDIT'),
                            'edit'=>getFixedLabel('ALLOWVIEWINGNOTEMPTY'),
                            'approve'=>getFixedLabel('ALLOWVIEWINGAPPROVE'),
                            'require'=>getFixedLabel('LBL_MANDATORYFIELDS')
                            );
    $smarty->assign('TRANSLABEL',$trans_labelarr);
    $_REQUEST['diony']='diony';
    $arr['title'] = getFixedLabel('SOCIALPROMOTIONQRCODE').getFixedLabel('Contentcustomization');
    $arr['oktext'] = getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str = $smarty->fetch('Settings/FormcodeSet.tpl');
    $arr['content'] = $str;
}else{
    $detail_fieldinfo_arr=$_REQUEST['detail_fieldinfo'];
    $fieldinfo_arr = $_REQUEST['fieldinfo'];
    $content_arr = array();
    $content_arr['duration'] = $_REQUEST['duration'];
    if($_REQUEST['duration'] == 'endate'){
        $content_arr['endatetime'] = $_REQUEST['endatetime'];
    }
    $content_arr['limit'] = $_REQUEST['limit'];
    $content_json = ldcrm_json_encode($content_arr);
    if(isset($_REQUEST['templateid'])&&$_REQUEST['templateid']>0){
        $qrcodetemplateid = $_REQUEST['templateid'];
        $sql = "update ld_qrcode_template set template_content = ? where qrcodetemplateid = ?";
        $adb->pquery($sql,array($content_json,$qrcodetemplateid));
    }else{
        $sql = "insert into ld_qrcode_template(template_content) values(?)";
        $adb->pquery($sql,array($content_json));
        $qrcodetemplateid = $adb->getLastInsertID();
    }
    //删除原记录
    $sql = 'delete from ld_qrcode_fieldsdetail where qrcodetemplateid = ?';
    $adb->pquery($sql,array($qrcodetemplateid));
    
    foreach($fieldinfo_arr as $fieldid=>$fieldinfo){
        if($fieldinfo['view']=='yes'){
            $sql = 'insert into ld_qrcode_fieldsdetail(qrcodetemplateid,fieldid,qrcode_fieldlabel,viewpermit,
                editpermit,editcontentpermit,approvepermit,requirecontent,fieldidtype) values(?,?,?,?,?,?,?,?,?)';
            $adb->pquery($sql,array($qrcodetemplateid,$fieldid,$fieldinfo['label'],$fieldinfo['view'],$fieldinfo['input'],
                            $fieldinfo['edit'],$fieldinfo['approve'],$fieldinfo['require'],'normal'));
        }
    }
    //保存时往表里插入分录字段的信息
    foreach($detail_fieldinfo_arr as $detail_fieldid=>$detail_fieldinfo){
        if($detail_fieldinfo['view']=='yes'){
            $query = 'insert into ld_qrcode_fieldsdetail(qrcodetemplateid,fieldid,qrcode_fieldlabel,viewpermit,
                editpermit,editcontentpermit,approvepermit,requirecontent,fieldidtype) values(?,?,?,?,?,?,?,?,?)';
            $adb->pquery($query,array($qrcodetemplateid,$detail_fieldid,$detail_fieldinfo['label'],$detail_fieldinfo['view'],$detail_fieldinfo['input'],
                $detail_fieldinfo['edit'],$detail_fieldinfo['approve'],$detail_fieldinfo['require'],'detailed'));
        }
    }
    
    $arr['qrcodetemplateid'] = $qrcodetemplateid;
}
ConvertTojsonString(1,$arr,'success');
?>