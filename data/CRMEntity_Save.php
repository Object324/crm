<?php

class CRMEntity_Save
{
    //gyq161208 reason：删除base64图片保存方法
    /**
     *      This function is used to upload the attachment in the server and save that attachment information in db.
     * @param int $id             - entity id to which the file to be uploaded
     * @param string $module      - the current module name
     * @param array $file_details - array which contains the file information(name, type, size, tmp_name and error)
     *                            return void
     */
    static function uploadAndSaveFile($id, $module, $file_details, $focus)
    {

        global $adb, $current_user;
        global $upload_badext;

        $date_var = date("Y-m-d H:i:s");

        //to get the owner id
        $ownerid = $focus->column_fields['assigned_user_id'];
        if (!isset($ownerid) || $ownerid == '')
            $ownerid = $current_user->id;

        if (isset($file_details['original_name']) && $file_details['original_name'] != null) {
            $file_name = $file_details['original_name'];
        } else {
            $file_name = $file_details['name'];
        }
        $file_name = $file_details['name'];
        $binFile = sanitizeUploadFileName($file_name, $upload_badext);

        $lastfixs = explode(".", $binFile);
        $lastfix = $lastfixs[count($lastfixs) - 1];
        $current_id = $adb->getUniqueID("ld_crmentity");

        $filename = ltrim(basename(" " . $binFile)); //allowed filename like UTF-8 characters

        $filetype = $file_details['type'];
        $filesize = $file_details['size'];
        $filetmp_name = $file_details['tmp_name'];

        //get the file path inwhich folder we want to upload the file
        $upload_file_path = decideFilePath();

        $file_name = $current_id . "_" . $filename;//id加附件名称
        if ($file_details['noteid'] > 0) {//复制
            copy($upload_file_path . $file_details['attachmentsid'] . '_' . $file_details['original_name'], $upload_file_path . $file_name);
            $upload_status = 'true';
        } else {
            if (strtolower(PHP_OS) == 'freebsd' || strtolower(PHP_OS) == 'linux' || strtolower(PHP_OS) == 'unix') {
                //获取系统类型，如果是非windows系统则不用修改编码格式
                $upload_status = @move_uploaded_file($filetmp_name, $upload_file_path . $file_name);
            } else
                $upload_status = @move_uploaded_file($filetmp_name, mb_convert_encoding($upload_file_path . $file_name, 'gb2312', 'UTF-8'));
        }

        $save_file = 'true';
        if ($module != 'Emails' && $module != 'Documents')//群发邮件不需要判断文件格式
            $save_file = validateImageFile($file_details);//判断图片格式是否正确


        if ($save_file == 'true' && ($upload_status == 'true' || $upload_status == 1)) {
            //This is only to update the attached filename in the lingdang_notes lingdang_table for the Notes module

            $sql1 = 'insert into ld_crmentity (crmid,setype) values(?,?);';
            $params1 = array($current_id, $module . " Image");

            $adb->pquery($sql1, $params1);
            if($filetype=='')
            {
                 $filetype=getFileTypeByfilename(ltrim(basename(" " . $binFile)));

            }
            $sql2 = "insert into ld_attachments(attachmentsid, name, description, type, path) values(?, ?, ?, ?, ?)";
            $params2 = array($current_id, ltrim(basename(" " . $binFile)), $focus->column_fields['description'],
                $filetype, $upload_file_path);
            $result = $adb->pquery($sql2, $params2);

            if ($_REQUEST['mode'] == 'edit') {
                if ($id != '' && $_REQUEST['fileid'] != '') {
                    $delquery = 'delete from ld_seattachmentsrel  where crmid = ? and attachmentsid = ?';
                    $delparams = array($id, $_REQUEST['fileid']);
                    $adb->pquery($delquery, $delparams);
                }
            }
            if ($module == 'Documents') {
                $query = "delete from ld_seattachmentsrel where crmid = ?";
                $qparams = array($id);
                $adb->pquery($query, $qparams);
            }
            //if($module == 'Products'){
            $sql3 = 'insert into ld_seattachmentsrel values(?,?)';

            $adb->pquery($sql3, array($id, $current_id));


            return true;
        } else {

            return false;
        }
    }

    /** Function to insert values in the specifed table for the specified module
     * @param $table_name -- table name:: Type varchar
     * @param $module     -- module:: Type varchar
     */
    static function insertIntoEntityTable($table_name, $module, $fileid = '', $focus=[])
    {

        global $current_user, $currentModule, $weixin_user;

        global $adb;
        $insertion_mode = $focus->mode;
        $time = date('Y-m-d H:i:s', time());
        // @edit:dong @date:2022/05/19 @reason:
        // api 移动端
        // link2erp  链接erp
        // crmapi    crm对外提供的api
        if(is_null($current_user))//小程序登录
            $current_user=new Users();
        if (in_array($focus->operate_api, array('api', 'link2erp'))) {//判断数据是否来自于接口调用方式；

            $current_user->id = $focus->column_fields['creator'];
        }
        if ($module == 'Stock' || $module == 'OutboundOrder') {
            $ownerid = $current_user->id;
        }
        //$sql = "select ownedby from ld_tab where name=?";
        //$res = $adb->pquery($sql, array($module));
        $focus->ownedby = getTabOwnedBy($module);

        if ($focus->ownedby == 1) {

            $ownerid = $current_user->id;
        }
        // Asha - Change ownerid from '' to null since its an integer field.
        // It is empty for modules like Invoice/Quotes/SO/PO which do not have Assigned to field
        if ($ownerid === '')
            $ownerid = 0;

        if ($module == 'Events') {
            $module = 'Calendar';
        }
        //Checkin whether an entry is already is present in the lingdang_table to update
        if ($insertion_mode == 'edit') {

            $tablekey = $focus->tab_name_index[$table_name];
            // Make selection on the primary key of the module table to check.
            $check_query = "select $tablekey from $table_name where $tablekey=?";
            $check_result = $adb->pquery($check_query, array($focus->id));

            $num_rows = $adb->num_rows($check_result);

            if ($num_rows <= 0) {
                $insertion_mode = '';
            }
        }

        $tabid = getTabid($module);

        $update = array();
        $update_params = array();
        if ($insertion_mode == 'edit') {

        } else {
            $table_index_column = $focus->tab_name_index[$table_name];
            if ($table_index_column == 'id' && strtolower($table_name) == 'ld_users') {
                $currentuser_id = $adb->getUniqueID("ld_users");
                $focus->id = $currentuser_id;
            }
            $column = array($table_index_column);
            $value = array($focus->id);

        }
        if ($currentModule == 'ServiceCharge') {
            if ($insertion_mode != 'edit') //服务收费  新增销售负责任默认为自己。
                $focus->column_fields['assigned_user_id'] = $current_user->id;

        }

        //duan 20230212 将获取字段权限放到方法里,用于重载
        $profilefields = $focus->getProfileFields($current_user->profileid);

        //duan 20230212 将获取字段新放到方法里,用于重载
        $fieldModules = $focus->getMainModuleFields();
        //zkt 20240701 BUG20240627-59  销售订单模块，分录有一个会员价是数字字段，是从产品引用过来的，在页面设置用分录函数统计的时候选不到这个字段，麻烦查一下
        $requestfieldname_arr = [];
        foreach ($fieldModules as $fieldname => $fieldinfo) {
            if ($fieldinfo->getSaveDataBase() == 'no') {
                continue;
            }
            $fieldid = $fieldinfo->getFieldid();

            if ($fieldinfo->getFieldDataType() == 'mobile' && fieldValueUitype::IsShowMobileTextBox($focus->id, $module) == 'no' && $insertion_mode == 'edit') {//手机类型字段，保存数据时，保存隐藏域的值。
                if (!array_key_exists($fieldname, $_REQUEST))//客户或服务收费管理保存
                    continue;

            }

           /* if ($current_user->is_admin == 'off' && !empty($profilefields) && $profilefields[$fieldid]['readonly'] == 1) {
                continue;
            }*/
            //移动端保存时，不保存富文本框字段类型的值
            if ($insertion_mode == 'edit' && !empty($weixin_user) && $weixin_user->environment_weixin && $fieldinfo->getBigType() == 'richtext') {
                continue;
            }
            //工单管理模块，生成解决方案特殊保存
            if ($_REQUEST['solution'] != '' && $currentModule == 'WorkSheet' && $fieldname == 'solution') {
                $fieldinfo->setDisplaytype(1);
            }

            if ($insertion_mode != 'edit') {

                if ($fieldinfo->getDisplaytype() != 3 && $fieldinfo->getDisplaytype() != 1 && $fieldinfo->getDisplaytype() != 4) {

                    continue;
                }


            } else {
                if ($fieldinfo->getDisplaytype() != 1 && $fieldinfo->getDisplaytype() != 3) {
                    continue;
                }
            }


            if ($fieldinfo->getTableName() != $table_name) {
                continue;
            }

            //知识管理>列表：编辑知识管理，保存。结果：列表中“附件”字段，不显示附件名称
            //Liver 2016-11-21 增加1108，原因是编辑附件保存后，附件不显示名称
            //edit:can 2021-01-07 041611: （公司自动账套，灵当科技）联系人新建界面，“照片”字段同时选择多张照片上传，点击保存后，列表没有显示该条单据
            if ($fieldinfo->getUIType() == 27 || $fieldinfo->getUIType() == 28 || $fieldinfo->getUIType() == 1108 || $fieldinfo->getUIType() == 69) {
                continue;
            }
            // ljj 20231106 BUG0075029 只有"新增"的时候才有sourcefrom（单据来源）
            if ($insertion_mode == 'edit' && $fieldinfo->getUIType() == 118) {
                continue;
            }

            $columname = $fieldinfo->getColumnName();


            $uitype = $fieldinfo->getUIType();

            $bigtype = $fieldinfo->getBigType();
            $typeofdata = $fieldinfo->getTypeOfData();


            $generatedtype = $fieldinfo->getGeneratedtype();
            $typeofdata = $fieldinfo->getTypeOfData();
            if ('approvestatus' == $columname || 'conversion_rate' == $columname) continue;//审批状态不允许编辑 tujt 2014-12-31 汇率不在这里编辑，全部统一在模块类文件save_module处理
            $typeofdata_array = explode("~", $typeofdata);
            $datatype = $typeofdata_array[0];


            $ajaxSave = false;
            if (($_REQUEST['file'] == 'DetailViewAjax' && $_REQUEST['ajxaction'] == 'DETAILVIEW'
                    && isset($_REQUEST["fldName"]) && $_REQUEST["fldName"] != $fieldname)
                || ($_REQUEST['action'] == 'MassEditSave' && !isset($_REQUEST[$fieldname . "_mass_edit_check"]))) {
                $ajaxSave = true;
            }
            //单据编号生成

            if ($uitype == 4 && $insertion_mode != 'edit') {
                $fldvalue = '';
                /**
                 * @by     andy
                 * @date   20140729
                 * @reason 系统编号改进，可手动录入
                 */
                //echo getModentityfield('isallow',$module).'--------';exit;
                if ($focus->Library('SystemCode')->getModentityfield('isallow', $module) == 1 || in_array($focus->operate_api, array('api', 'link2erp', 'crmapi'))) {
                    if ($_REQUEST[$columname] != '') {
                        $fldvalue = $_REQUEST[$columname];
                        //同时打开新建界面，保存 会有跳号
                        // $focus->Library('SystemCode')->setModuleSeqNumber("increment", $module);//使当前流水号加1，避免单据编号重复
                    } elseif (!CRMEntity::isBulkSaveMode()) {
                        $fldvalue = $focus->Library('SystemCode')->setModuleSeqNumber("increment", $module);
                    }
                } elseif (!CRMEntity::isBulkSaveMode()) {
//                    @edit:liushuai,2021-05-25,reason:0045613: 销售线索升级的时候，客户编号没有取线索的编号（灿哥说销售线索升级暂时先特殊判断）
                    if ($_REQUEST['upgradefrommodule'] != '' && $_REQUEST['upgradefromid'] > 0 && $columname == 'account_no') {
                        $fldvalue = $_REQUEST[$columname];
                    } else {
                        $fldvalue = $focus->Library('SystemCode')->setModuleSeqNumber("increment", $module);
                    }

                }

                $focus->column_fields[$fieldname] = $fldvalue;
            }

            if (isset($focus->column_fields[$fieldname])) {
                if ($bigtype == 'reference') {
                    /*  if(stripos($typeofdata,'~m')===false)
                      {
                        //先删除吧，页面设置必填，布局规则隐藏不应该提示
                      }
                      else
                      {
                          if(empty($focus->column_fields[$fieldname]) && $focus->operate_api !='link2erp')
                          {
                            $_REQUEST['diony']='yes';

                             ConvertTojsonString("-1",[],$fieldinfo->getFieldLabel().getFixedLabel('CANOTEMPTYGTH'));

                          }
                      }*/
                }
                if ($uitype == 56) {
                    if ($focus->column_fields[$fieldname] === 'on' || $focus->column_fields[$fieldname] == 1) {
                        $fldvalue = '1';
                    } else {
                        $fldvalue = '0';
                    }
                } elseif ($uitype == 15 || $uitype == 16) {

                    $fldvalue = $focus->column_fields[$fieldname];

                } else if ($uitype == 86 || $uitype == 5) {


                    //18300: 火狐浏览器上，日程管理-新增保存，结果页面显示空白
                    if (empty($focus->column_fields[$fieldname])) {
                        //日期，时间字段为空赋值为NULL
                        $fldvalue = null;


                    } else {
                        $fldvalue = $focus->column_fields[$fieldname];
                    }

                } elseif ($uitype == 33) {

                    $field_list = setsaveMutliPickListValue($focus->column_fields[$fieldname]);

                    $fldvalue = $field_list;
                } elseif ($uitype == 5 || $uitype == 6 || $uitype == 23) {
                    //Added to avoid function call getDBInsertDateValue in ajax save

                    if (isset($current_user->date_format) && !$ajaxSave) {
                        $fldvalue = getValidDBInsertDateValue($focus->column_fields[$fieldname]);
                    } else {
                        $fldvalue = $focus->column_fields[$fieldname];
                    }

                } elseif ($uitype == 7) {
                    //strip out the spaces and commas in numbers if given ie., in amounts there may be ,
                    $fldvalue = str_replace(",", "", $focus->column_fields[$fieldname]);
                    if (empty($fldvalue)) $fldvalue = 0;

                } elseif ($uitype == 26) {
                    if (empty($focus->column_fields[$fieldname])) {
                        $fldvalue = 1; //the documents will stored in default folder
                    } else {
                        $fldvalue = $focus->column_fields[$fieldname];
                    }
                } elseif ($uitype == 150 || $uitype == 151) {
                    $fldvalue = $focus->column_fields[$fieldname];
                } elseif ($uitype == 28) {
                    if ($focus->column_fields[$fieldname] == null) {
                        $fileQuery = $adb->pquery("SELECT filename from ld_notes WHERE notesid = ?", array($focus->id));
                        $fldvalue = null;
                        if (isset($fileQuery)) {
                            $rowCount = $adb->num_rows($fileQuery);
                            if ($rowCount > 0) {
                                $fldvalue = $adb->query_result($fileQuery, 0, 'filename');
                            }
                        }
                    } else {
                        $fldvalue = $focus->column_fields[$fieldname];
                    }
                } elseif ($uitype == 8) {
                    $focus->column_fields[$fieldname] = rtrim($focus->column_fields[$fieldname], ',');
                    $ids = explode(',', $focus->column_fields[$fieldname]);
                    $json = new Zend_Json();
                    if ($focus->column_fields[$fieldname] != '')
                        $fldvalue = $json->encode($ids);
                    else
                        $fldvalue = '';
                } elseif ($uitype == 12) {

                    // Bulk Sae Mode: Consider the FROM email address as specified, if not lookup
                    $fldvalue = $focus->column_fields[$fieldname];

                    if (empty($fldvalue)) {
                        $query = "SELECT email1 FROM ld_users WHERE id = ?";
                        $res = $adb->pquery($query, array($current_user->id));
                        $rows = $adb->num_rows($res);
                        if ($rows > 0) {
                            $fldvalue = $adb->query_result($res, 0, 'email1');
                        }
                    }
                    // END
                } elseif ($uitype == 72 && !$ajaxSave) {
                    // Some of the currency fields like Unit Price, Totoal , Sub-total - doesn't need currency conversion during save

                    $fldvalue = $focus->column_fields[$fieldname];
                } elseif ($uitype == 71 && !$ajaxSave) {

                    $fldvalue = $focus->column_fields[$fieldname];
                } elseif ($uitype == 53) {//smownerid 负责人

                    $fldvalue = $focus->column_fields[$fieldname];


                    if ($insertion_mode != 'edit' && (empty($fldvalue) || !is_numeric($fldvalue))) {
                        $fldvalue = $current_user->id;
                        $ownerid = $fldvalue;
                    }
                } else if ($uitype == 202 && ($focus->module_name != 'SendPayment' && $focus->module_name != 'PaymentPlan')) {

                    /* if ($focus->module_name == 'SalesOrder') {
                         $fldvalue = $focus->column_fields['quote_id'];
                     } else*/
                    $fldvalue = $focus->column_fields['selectlistval'];

                    $tmpfieldvalues = explode(",", $fldvalue);
                    $tmpfieldvalues = array_unique($tmpfieldvalues);
                    $fldvalue = implode(',', $tmpfieldvalues);

                    $fldvalue = trim(ltrim($fldvalue, '0'), ',');//只能删除左边的零，如果删除右边则会有bug,例如选择原单的id值最后一位为零
                    //小编辑之后，会导致源单类型entitytype清空
                    if(isset($_REQUEST['selectsourcename'])){
                        if (!empty($_REQUEST['selectsourcename'])||(empty($_REQUEST['selectsourcename'])&&empty($fldvalue))) {
                            $value[] = $_REQUEST['selectsourcename'];
                            $column[] = 'entitytype';

                            array_push($update, "entitytype=?");
                            $update_params[] = $_REQUEST['selectsourcename'];
                        }
                    }

                } elseif ($uitype == 170) {
                    if ($focus->column_fields[$fieldname] == '')
                        $fldvalue = 0;
                    else
                        $fldvalue = $focus->column_fields[$fieldname];
                } elseif ($uitype == 52 && $fieldname != 'servicecasher') {//modifiedby 修改人
                    if (in_array($focus->operate_api, array('api', 'link2erp', 'crmapi')))
                        $fldvalue = $focus->column_fields[$fieldname];
                    else
                        if (isset($_REQUEST[$fieldname]) && $_REQUEST[$fieldname] > 0) {

                            //申请为：推广大使
                            //  dump($fieldname);
                            $fldvalue = $_REQUEST[$fieldname];

                        } else
                            $fldvalue = $current_user->id;
                } elseif ($uitype == 118) {
                    if (isset($_REQUEST['source_platform']) && !empty($_REQUEST['source_platform'])) {
                        if($focus->column_fields[$fieldname] != ''){
                            $fldvalue = $_REQUEST['source_platform'] . '_' . $focus->column_fields[$fieldname];    
                        }
                        else{
                            $fldvalue = $_REQUEST['source_platform'];
                        }
                    } else {
                        $fldvalue = $focus->column_fields[$fieldname];
                        if (empty($fldvalue)) {
                            $fldvalue = '';
                        }
                    }
                } else {
                    //40996: 合同启用推进漏斗，时间分别为签约日期和交付日期，复制合同的时候推进阶段显示异常
                    if ($fieldname == 'advance_stage' && $insertion_mode != 'edit') {
                        $fldvalue = '';
                    } else {

                        $fldvalue = $focus->column_fields[$fieldname];
                    }
                }
                if ($uitype != 33 && $uitype != 8)
                    $fldvalue = from_html($fldvalue, ($insertion_mode == 'edit') ? true : false);
            } else if ($uitype == 202 && $focus->module_name != 'SendPayment') {

                /* if ($focus->module_name == 'SalesOrder') {
                     $fldvalue = $focus->column_fields['quote_id'];
                 } else*/
                $fldvalue = $focus->column_fields['selectlistval'];

                $tmpfieldvalues = explode(",", $fldvalue);
                $tmpfieldvalues = array_unique($tmpfieldvalues);
                $fldvalue = implode(',', $tmpfieldvalues);

                $fldvalue = trim(ltrim($fldvalue, '0'), ',');//只能删除左边的零，如果删除右边则会有bug,例如选择原单的id值最后一位为零

                $value[] = $_REQUEST['selectsourcename'];
                $column[] = 'entitytype';
                array_push($update, "entitytype=?");
                $update_params[] = $_REQUEST['selectsourcename'];


            } else if ($uitype == 53 && $insertion_mode != 'edit') {
                //右上角快速创建负责人为空
                $fldvalue = $current_user->id;
            } else if ($uitype == 86 || $uitype == 15) {
                $fldvalue = null;
            } else if ($uitype == 118) {
                if (isset($_REQUEST['source_platform']) && !empty($_REQUEST['source_platform'])) {
                    $fldvalue = $_REQUEST['source_platform'];
                } else {
                    $fldvalue = '';
                }
            } else {
                $fldvalue = '';
            }
            if ($fldvalue == '') {
                $fldvalue = $focus->get_column_value($columname, $fldvalue, $fieldname, $uitype, $datatype);
            }

            if ($insertion_mode == 'edit') {

                /**
                 * @by   andy
                 * @系统编号改进
                 * @允许手动录入编号
                 * @date 20140730
                 */
                if ($table_name != 'ld_ticketcomments') {

                    array_push($update, $columname . "=?");
                    array_push($update_params, $fldvalue);
                }

            } else {
                if ($module == 'Potentials' && $fldvalue == '') {
                    $defaultSql = 'SELECT  defaultvalue FROM ld_field WHERE tabid = 2 AND presence IN (0, 2) AND defaultvalue IS NOT NULL and
                      columnname=?;';
                    $result = $adb->pquery($defaultSql, array($columname));
                    $fldvalue = $adb->query_result($result, 0, "defaultvalue");

                }
                array_push($column, $columname);

                array_push($value, $fldvalue);

            }
            //echo  $fieldname."<br>";

            $requestfieldname_arr[$fieldname] = $fldvalue;
        }
        if ($insertion_mode == 'edit') {

            $focus->addComboxIntoDataBase($table_name);//下拉框改变历史记录，例如销售机会的销售阶段

            //Check done by Don. If update is empty the the query fails
            if (count($update) > 0) {

                if ($table_name != $focus->table_name) {
                    $sql1 = 'update ' . $table_name . ' set ' . implode(',', $update) . ' where ' . $focus->tab_name_index[$table_name] . '=?';
                    array_push($update_params, $focus->id);
                } else {
                    //ls 2021-11-26 【1002260】审批流程定制，审批结束重复提交审批时功能优化（保存时提示并更改审批状态）
                    $approveobj = Approve::getInstance($module);
                    $tmp_SaveResetApprovestatus = $approveobj->SaveResetApprovestatus($module);
                    if ($tmp_SaveResetApprovestatus) {
                        //审批结束，编辑单据保存后更新单据审批状态为“未提交”
                        array_push($update, "approvestatus=?");
                        array_push($update_params, D_A_S_UNAPPROVED);
                    }
                    /**
                     * 判断修改字段中是否有修改人字段，如果没有就添加
                     * @reason 0012691 银行初始化中最新修改人功能异常
                     * @author Tujt 2014-11-26
                     */
                    $updatefld = implode(',', $update);
                    if (!strpos($updatefld, 'modifiedby') && $module != 'WorkReportList') {
                        $updatefld .= ',modifiedby=?';
                        array_push($update_params, $current_user->id);
                    }
                    if ($module == 'WorkReportList') { //BUG0073495 xxy 2023-10-09 工作汇报（列表）-批量编辑功能不生效（kfbcrm也有这个问题） 工作汇报表没有修改人和修改时间导致更新语句执行不成功
                        $sql1 = 'update ' . $table_name . ' set ' . $updatefld . ' where ' . $focus->tab_name_index[$table_name] . '=?';
                    } else {
                        $sql1 = 'update ' . $table_name . ' set ' . $updatefld . ',modifiedtime=? where ' . $focus->tab_name_index[$table_name] . '=?';
                        array_push($update_params, $time);
                    }
                    array_push($update_params, $focus->id);
                }

                $adb->pquery($sql1, $update_params);
                if ($adb->database->_errorMsg != '') {
                    $errormsg = $adb->database->_errorMsg;
                    file_put_contents(globalStatic::$root_directory . 'dataCache/databaseerror.txt', $sql1 . $errormsg . date("Y-m-d H:i:s") . "\r\n", FILE_APPEND);
                }
                if ($tmp_SaveResetApprovestatus) {
                    //添加审批日志
                    global $before_approveinfo;
                    $approvelogid = $adb->getUniqueID('ld_approvelog');
                    $sql = 'insert into ld_approvelog(id,crmid,approveid,stepid,approved_by,approveresult,createdtime,seqtime) values(?,?,?,?,?,?,now(),current_timestamp(6))';
                    $adb->pquery($sql, array($approvelogid, $focus->id, 0, 0, $current_user->id, 13));
                    //根据模块反写字段(应在保存之后调用)
                    //edit:can 20211217 49268: （https://81mis.com/kfbtest/index.php [^]）服务合同》SERCON14 ，编辑该单据保存-审批状态变为未提交后，客户的服务到期日没清空
                    $old_account_id = $focus->column_fields['account_id'];
                    $before_approveinfo['approvestatus'] = constant('D_A_S_APPROVED');

                    $focus->column_fields['account_id'] = 0;
                    $focus->rejectApproved($focus->id);
                    $focus->column_fields['account_id'] = $old_account_id;
                }
            }
        }
        else {
            if ($table_name != $focus->table_name) {
                //ls 2021-07-28 【ID1001763】页面设置增加“成员所属部门”字段，选择成员后，带出成员所属部门（王杰）(设置为创建人 displaytype 2)
                foreach ($focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo) {
                    if (!in_array($tmp_fieldinfo->getColumnName(), $column) && $tmp_fieldinfo->getUIType() == 1600) {
                        //检查是否有关联带出值
                        $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                        $result_related_field = $adb->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                        if ($adb->num_rows($result_related_field) >= 1) {
                            //检查设置的触发字段类型
                            $tmp_trigger_fieldid = $adb->query_result($result_related_field, 0, 'trigger_fieldid');
                            $sql_field = "select uitype from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                            $result_field = $adb->pquery($sql_field, array($tmp_trigger_fieldid));
                            if ($adb->num_rows($result_field) >= 1 && $adb->query_result($result_field, 0, 'uitype') == 52) {//触发字段为创建人
                                require_once globalStatic::$root_directory . 'modules/Users/Group.class.php';
                                $group_focus = new Group();
                                $depInfo = $group_focus->getUserGroup($current_user->id);
                                ksort($depInfo);//按键升序
                                $depId = implode(',', array_keys($depInfo));//部门id

                                $column[] = $tmp_fieldinfo->getColumnName();
                                $value[] = $depId;
                            }
                        }
                    }
                }
                $sql1 = 'insert into ' . $table_name . '(' . implode(',', $column) . ') 
						values(' . generateQuestionMarks($value) . ');';
            }
            else {
                if (!in_array('smownerid', $column)) {
                    $column[] = 'smownerid';
                    $value[] = ($ownerid > 0) ? $ownerid : $current_user->id;
                }
                if (!in_array('smcreatorid', $column)) {
                    $column[] = 'smcreatorid';
                    if (in_array($focus->operate_api, array('api', 'link2erp', 'crmapi'))) {
                        if($focus->module_name=='ServiceContracts'){
                            $value[] = $focus->column_fields['ServiceContractscreator'];
                        }elseif (!empty($focus->column_fields['smcreatorid']))
                            $value[] = $focus->column_fields['smcreatorid'];
                        else {
                            $value[] = $focus->column_fields['creator'];
                        }
                    } else {
                        $smcreatorcolumn = $focus->getCreateColumnName();
                        //  $smcreat
                        if (!empty($focus->column_fields['smcreatorid']) && $table_name == 'ld_ambassador') {
                            //edit:can 20210705 46693: （http://lanniaofire.vicp.io:9085/crm/ [^]）客户问题（陈修宏），出库单复制单据（出库单编号：CK2021070245493）保存后，创建人显示错误，显示的是源单创建人
                            //推广大使
                            $value[] = $focus->column_fields['smcreatorid'];
                        } else
                            $value[] = $current_user->id;
                    }
                }
                if (!in_array('createdtime', $column)) {
                    $column[] = 'createdtime';
                    if (in_array($focus->operate_api, array('api', 'link2erp', 'crmapi'))) {
                        // @edit:dong @date:2021/08/20 @reason: 增加条件 值为空不赋值给数组 否则单据没有创建时间
                        if (isset($focus->column_fields['createdtime']) && $focus->column_fields['createdtime'] != '')
                            $value[] = $focus->column_fields['createdtime'];
                        else if (isset($focus->column_fields['procreatedtime']) && $focus->column_fields['procreatedtime'] != '')
                            $value[] = $focus->column_fields['procreatedtime'];
                        else if (isset($focus->column_fields['ServiceContractscreatedtime']) && $focus->column_fields['ServiceContractscreatedtime'] != '')
                            $value[] = $focus->column_fields['ServiceContractscreatedtime'];
                        else
                            $value[] = $time;
                    } else {
                        $value[] = $time;
                    }

                }

                $sql1 = 'insert into ' . $table_name . '(' . implode(',', $column) . ',modifiedtime) 
						values(' . generateQuestionMarks($value) . ',"' . $time . '");';


            }
            /*echo $sql1;echo '<br><br>';
            echo '<pre>';
            print_r($value);
            echo '</pre>';
            die;*/
            $adb->pquery($sql1, $value);
            if ($adb->database->_errorMsg != '') {
                $errormsg = $adb->database->_errorMsg;
                file_put_contents(globalStatic::$root_directory . 'dataCache/databaseerror.txt', $sql1 . $errormsg . date("Y-m-d H:i:s") . "\r\n", FILE_APPEND);
                file_put_contents(globalStatic::$root_directory . 'dataCache/databaseerror.txt', json_encode($value,JSON_UNESCAPED_UNICODE) . date("Y-m-d H:i:s") . "\r\n", FILE_APPEND);
            }
        }

        if(is_array($requestfieldname_arr)){
            $focus->requestfieldname_arr = array_merge($focus->requestfieldname_arr, $requestfieldname_arr);
        }


    }

    /**
     * edit:can
     * reason:设置非编辑字段默认值
     * other:10353: 新增客户或导入客户时，建议“最新联系日期”字段取当前系统的日期。
     * */
    static function setFieldDefaultValue($id, $module, $focus)
    {
        global $adb;
        //导入字段默认值
        if (is_array($id)) {
            $id = implode(',', $id);
        }
        if(empty($id))
        {
            return ;
        }
        $tabid = getTabid($module);
        $sql = "select typeofdata, columnname,tablename,defaultvalue,uitype from ld_field where tabid=?  and presence in(0,2)  and ifnull(defaultvalue,'') <> '' ";
        $result = $adb->pquery($sql, array($tabid));
        for ($i = 0; $i < $adb->num_rows($result); $i++) {

            $defaultvalue = $adb->query_result($result, $i, 'defaultvalue');
            $typeofdata = $adb->query_result($result, $i, 'typeofdata');
            $columnname = $adb->query_result($result, $i, 'columnname');
            $tablename = $adb->query_result($result, $i, 'tablename');
            $uitype = $adb->query_result($result, $i, 'uitype');
            $table_index = $focus->tab_name_index[$tablename];
            if (empty($table_index)) {
                continue;
            }
            $focus->noEditFieldDefaultValue[] = array('defaultvalue' => $defaultvalue, 'typeofdata' => $typeofdata, 'columnname' => $columnname, 'tablename' => $tablename);
            if (!empty($defaultvalue)) {

                $uitypes = explode('DT', $typeofdata);
                if (sizeof($uitypes) >= 2) {
                    switch (strtolower($defaultvalue)) {
                        case 'thistoday':
                            $defaultvalue = date("Y-m-d H:i:s");
                            break;
                        case 'thistomorrow':
                            $defaultvalue = date("Y-m-d H:i:s", strtotime("+1 day"));
                            break;
                        case 'thisextmonth':
                            $date = date('Y-m-d');
                            $firstday = date("Y-m-01", strtotime($date));
                            $defaultvalue = date("Y-m-d H:i:s", strtotime("$firstday +1 month -1 day"));
                            break;

                    }
                } else {
                    $uitypes = explode('D', $typeofdata);
                    if (sizeof($uitypes) >= 2) {
                        switch (strtolower($defaultvalue)) {
                            case 'thistoday':
                                $defaultvalue = date("Y-m-d");
                                break;
                            case 'thistomorrow':
                                $defaultvalue = date("Y-m-d", strtotime("+1 day"));
                                break;
                            case 'thisextmonth':
                                $date = date('Y-m-d');
                                $firstday = date("Y-m-01", strtotime($date));
                                $defaultvalue = date("Y-m-d", strtotime("$firstday +1 month -1 day"));
                                break;
                        }
                    }
                }
                if ($uitype == 56) {
                    if ($defaultvalue == 'on' || $defaultvalue == 1) {
                        $defaultvalue = 1;

                    } else {
                        $defaultvalue = 0;

                    }
                    $updatesql = ' update ' . $tablename . ' set ' . $columnname . '=\'' . $defaultvalue .
                        '\' where ' . $table_index . ' in(' . $id . ") and  $columnname is null  ";

                } else {
                    $updatesql = ' update ' . $tablename . ' set ' . $columnname . '=\'' . $defaultvalue .
                        '\' where ' . $table_index . ' in(' . $id . ') and (' . $columnname . "='' or $columnname is null) ";
                }



                $adb->pquery($updatesql, array());

            }
        }
    }

    static function changeModuleNumber($module, $record, $focus, $cursion_count = 0)
    {
        //20834: 单据编号重复问题：单据编号重复时，需要点击三次才能保存
        global $adb;
        $module = $focus->module_name;

        $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("uitype", 4);
        $fieldonly = 0;
        if ($fieldinfo) {
            $columnname = $fieldinfo->getColumnName();
            $fieldname = $fieldinfo->getFieldName();
            $fieldonly = $fieldinfo->getfieldOnly();
        }
        //28297: 单据序时簿界面：勾选两条编号一样的单据，批量编辑，保存后其中一条单据的编号会变
        //批量编辑,不需要重新修改单据编号
        //&& $fieldonly == 1
        //38657: (51mis.com/kfbcrm）客户管理>跟进记录：新建单据“跟进记录编号”重复，没有自动生成新的编号。（应弹出提示框“跟进记录编号重复，已自动生成新的编号”）
        if (!empty($columnname) && isset($_REQUEST[$fieldname])) {
            $sql = "select COUNT(1) from " . $focus->table_name . "  
                    where deleted=0 and  $columnname =(select $columnname from " . $focus->table_name .
                "   where deleted=0 and  " . $focus->table_index . "=?)";

            $result = $adb->pquery($sql, array($record));

            if ($adb->num_rows($result) > 0) {
                $record_count = $adb->query_result($result, 0, 0);
                if ($record_count > 1) {
                    //require_once(globalStatic::$root_directory.'include/SystemCode/SystemCode.php');
                    crm_load_class_file('SystemCode', 'include/SystemCode');
                    $systemcode = new SystemCode();
                    //editor:gyq date:20180810 0034751: （1.6登录）服务收费管理模块：勾选单据进行合并，重新选择客户编号字段值作为主要记录，合并成功后客户编号为空值
                    //$_REQUEST['mergemode'] == 'mergesave' &&
                    //37548: 服务收费管理：编辑客户，当客户编号重复时，提示将生产新的编号，但是确定保存后编号为空
                    $tmpmodule = $module;
                    if ($module == 'ServiceCharge') {
                        $tmpmodule = 'Accounts';
                    }
                    $num_no = $systemcode->reSetModuleSeqNumRecord($tmpmodule);//重新生成编号
                    $systemcode->setModuleSeqNumber("increment", $tmpmodule);//编号重复，重新生成流水号
                    $sql = "update " . $focus->table_name . " set $columnname=? where " . $focus->table_index . "=?";
                    $adb->pquery($sql, array($num_no, $record));
                    $_SESSION[$module . '_modulebillnotip'] = 'yes';
                    //edit:can 2021-01-06 37335: 单据编号（合同订单）设置不允许重复，单据保存时单据编号重复的时候会自动生成新的编号（+1），但是这个编号还是重复的
                    self::changeModuleNumber($module, $record, $focus, ++$cursion_count);
                } else if ($focus->mode != 'edit' && empty($cursion_count)) {
                    if ($focus->Library('SystemCode')->getModentityfield('isallow', $module) == 1 || in_array($focus->operate_api, array('api', 'link2erp', 'crmapi'))) {

                        $focus->Library('SystemCode')->setModuleSeqNumber("increment", $module);//使当前流水号加1，避免单据编号重复

                    }
                }
            }
        }
    }


    /**
     *edit:can
     *date:201300603
     *reason:批量添加(合同订单创建回款计划)(付款计划采购订单创建付款计划)
     * $modules:表名称所对应的模块名称的集合,表名称=>模块
     * $columns:数组下标=>表名称=>字段名称=>字段值
     * ld_crmEntity表必须是数组的第一个元素
     **/
    static function MassSave($modules, $columns, $focus)
    {
        global $adb, $current_module, $current_user;

        $focus->db->startTransaction();
        $arrvalue = array();
        $arrSql = array();//插入语句的Sql数组

        for ($i = 0; $i < count($columns); $i++) {


            $tabcontent = $columns[$i];
            if (count($tabcontent) <= 0) {
                continue;
            }
            foreach ($tabcontent as $tabname => $cols) {
                $insertSql = " Insert into ";
                $valueSql = " values ( ";
                $insertSql .= $tabname . " ( ";
                $arrvalue = array();
                foreach ($cols as $colnames => $colvalue) {
                    $insertSql .= $colnames . ",";
                    $valueSql .= "?,";
                    if ($colvalue == "#:#:#:#:#")//自动生成编号
                    {
                        $focus = new $modules[$tabname];

                        $colvalue = $focus->Library('SystemCode')->setModuleSeqNumber("increment", $modules[$tabname]);
                    }
                    array_push($arrvalue, $colvalue);
                    $focus->column_fields[$colnames] = $colvalue;
                }

                if (strtolower($tabname) == "ld_crmentity") {

                    $current_id = $adb->getUniqueID("ld_crmentity");
                    $idname = "crmid";
                } elseif (in_array($tabname, $focus->customFieldTable)) {
                    $insertSql = trim($insertSql, ',');
                    $valueSql = trim($valueSql, ',');


                    $arrvalue[0] = $current_id;
                    //edit:can 20210331 45234: （http://42.193.112.228:85/crm [^])；客户—北京永和嘉业房地产经纪有限公司；付款计划单据中两个引用字段“房东联系方式” “房源名称” 引用失败

                    $adb->pquery("  $insertSql  ) $valueSql )", $arrvalue);

                    continue;
                    $idname = $focus->table_index;
                } else {
                    $focus = new $modules[$tabname];
                    $idname = $focus->table_index;

                }
                array_push($arrvalue, $current_id);
                //添加数据到数据库
                // echo $insertSql.$idname." ) $valueSql ? )".'</br>';
                // echo '<pre>';
                //print_r($arrvalue);
                $adb->pquery($insertSql . $idname . " ) $valueSql ? )", $arrvalue);
            }

            //edit:can 20230321 62960  	http://101.33.200.27:85/crm ；康明医疗；设置的工作流程定制（模块：收款计划）没有响应。 
            crm_load_class_file("cls_savereverse", 'include/SaveReverse');

            $workflowreverseobj = cls_savereverse::getInstance($focus->module_name);
            $workflowreverseobj->setRecord($current_id);
            $workflowreverseobj->getStartComputer([], $focus->column_fields, 'creation');

            if (array_key_exists('account_id', $focus->column_fields)) {
                $focus->column_fields['account_id'] = $columns[$i][$focus->table_name]['accountid'];
            } else if (array_key_exists('vendor_id', $focus->column_fields)) {

                $focus->column_fields['cpperiodtime'] = $columns[$i][$focus->table_name]['cpperiodtime'];
                $focus->column_fields['vendor_id'] = $columns[$i][$focus->table_name]['vendorid'];
            }

            $_REQUEST['plandate'] = $columns[$i][$focus->table_name]['plandate'];
            $_REQUEST['assigned_user_id'] = $columns[$i]['ld_crmentity']['smownerid'];
            $focus->column_fields['periodtime'] = $columns[$i][$focus->table_name]['periodtime'];

            $focus->column_fields['amount'] = $columns[$i][$focus->table_name]['amount'];
            $smownerfileobj = $focus->fieldobj->getFieldInfoobjBykey("columnname", 'smownerid');

            $focus->column_fields[$smownerfileobj->getFieldName()] = $current_user->id;
            $focus->id = $current_id;
            $focus->save_module('');
            //edit: xll 2023/08/03 BUG0070577 关联创建收、付款计划时需要更新自动化进度字段值
            $focus->save_advancestage($current_id, $focus->module_name);
            //edit:duan 批量创建收款计划触发自动化任务
            $focus->ModuleTaskCheck($focus->module_name);
        }

        $focus->db->completeTransaction();

    }


    /**
     * 批量修改/保存(保存前)
     * ids:单据id的集合(数组)
     * **/
    static function massEdit_save_before($module, $ids, $focus)
    {
        global $adb;
        $becurrency_id = $focus->column_fields['currency_id'];
        if (isset($_REQUEST['currency_id_mass_edit_check']) && $becurrency_id != $_REQUEST['currency_id_mass_edit_check']) {
            $focus->before_currencyobj = new Currency($adb, $becurrency_id);
            $becurrency_rate = $focus->before_currencyobj->getCurrencyRate();
            foreach ($focus->column_fields as $fieldname => $val) {
                $uitype = $focus->columns_uitype[$fieldname];
                if ($uitype == 71 || $uitype == 72) {
                    $currency_id = $_REQUEST['currency_id_mass_edit_check'];    //修改后的币种
                    $focus->currencyobj = Currency::getInstance($adb, $currency_id);
                    $conversion_rate = $focus->currencyobj->getCurrencyRate();
                    $currency_symbol = $focus->currencyobj->getCurrencySymbol();
                    $amount = $focus->column_fields[$fieldname];
                    if ($becurrency_id == 1)//更改前的币种如果为人民币
                        $focus->column_fields[$fieldname] = sprintf("%.2f", $amount * $conversion_rate);
                    else
                        $focus->column_fields[$fieldname] = sprintf("%.2f", $amount / $becurrency_rate * $conversion_rate);
                }
            }
            $focus->column_fields['conversion_rate'] = $focus->currencyobj->getCurrencyRate();
            $focus->column_fields['currency_symbol'] = $focus->currencyobj->getCurrencySymbol();
            $focus->currency_status = true;
        }
    }
}


?>