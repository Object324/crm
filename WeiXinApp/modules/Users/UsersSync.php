<?php
/**
 * Created by PhpStorm.
 * editor:gyq_73 date:20180712 reason：成员同步速度优化
 */
crm_load_class_file('Users','modules/Users');
class UsersSync extends Users
{
    public function save($module_name, $fileid = '') {
        global  $adb,$current_user,$root_directory;
        //file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt","a\n");
       // file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt",json_encode($_REQUEST)."\n",FILE_APPEND);
        $this->saveentity($module_name);
        $uid=$this->id;
       // file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt","a1\n",FILE_APPEND);
        require_once(globalStatic::$root_directory.'modules/Users/SaveScope.php');
      //  file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt","a2\n",FILE_APPEND);
    }

    public function saveentity($module, $fileid = '') {
        global $current_user;
        $insertion_mode = $this->mode='create';
       // file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt", "saveentity\n",FILE_APPEND);
        crm_load_class_file('DateTimeField','include/fields');
        if($this->column_fields['approvestatus']==getFixedLabel("INACTIVATE"))
        {
            $this->column_fields['approvestatus']=1;
        }
        else if($this->column_fields['approvestatus']==getFixedLabel("ACTIVATE"))
        {
            $this->column_fields['approvestatus']=0;
        }
        if(empty($this->column_fields['date_format'])) {
            $this->column_fields['date_format'] = 'yyyy-mm-dd';
        }
        if(empty($this->column_fields['first_name'])) {
            $this->column_fields['first_name'] = '';
        }
       /// file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt", "saveentity1\n",FILE_APPEND);
        foreach($this->tab_name as $table_name) {
        //    file_put_contents(globalStatic::$root_directory."WeiXinApp/modules/Users/users.txt", "saveentity$table_name\n",FILE_APPEND);
            if (strtolower($table_name) == "ld_crmentity") {
                $this->insertIntoCrmEntity($module, $fileid);
            }
            else if(strtolower($table_name) == 'ld_attachments') {
//                @edit:liushuai,2020-12-30,reason:43859: （61mis.com/kfbcrm）系统设置-成员管理-详情；在成员管理界面进行小编辑操作，保存后个人头像没有了(小编辑其他字段导致个人头像被删除)

                  ///  $this->insertIntoAttachment($this->id,$module);
            }
            else
            $this->insertIntoEntityTable($table_name, $module);
        }
        if($insertion_mode != 'edit') {
            $this->createAccessKey();
        }
    }


}