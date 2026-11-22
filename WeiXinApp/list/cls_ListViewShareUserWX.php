<?php
crm_load_class_file('cls_ListViewWX','WeiXinApp/list');
//共享人列表
class  cls_ListViewShareUserWX{

    public function __construct($recordid)
    {
        $this->recordid = $recordid;
    }

    public function get_listdetail($showtype = '',$generatorName='',$where='')
    {
        global $current_user,$adb;

        $SQL = $this->getQuery();
        $SQL .= $where;
        if(!empty($_REQUEST['searchname'])){
            $SQL .= $this->addStdSearchContentWX($_REQUEST['searchname']);
        }
        $SQL .= ' GROUP BY ld_users.id ORDER BY last_name';
        
        $list_result = $adb->pquery($SQL,array());

        $num_rows = $adb->num_rows($list_result);

        $detail_value = array();
       
        
        
        for ($i = 0; $i < $num_rows; $i++) {
            $lastname = $adb->query_result($list_result,$i,'lastname');
            $wx_userid=$adb->query_result($list_result,$i,'wx_userid');
            $userid=$adb->query_result($list_result,$i,'id');
             $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->last_name=$lastname;
            $lastname=getUserlastName($userobj);
            $userlevel = $adb->query_result($list_result,$i,'userlevel');
            $profilename = $adb->query_result($list_result,$i,'profilename');
            $userimgpath = $adb->query_result($list_result,$i,'userimgpath');
            $userimgname = $adb->query_result($list_result,$i,'userimgname');
            $attachmentsid = $adb->query_result($list_result,$i,'attachmentsid');
            $groupname = $adb->query_result($list_result,$i,'groupname');
            $groupid=$adb->query_result($list_result,$i,'groupid');
            $groupobj=new Users();
            $groupid_arr=explode(",",$groupid);
            $groupname_arr=explode(",",$groupname);
            $tmp_group_arr=array();
            foreach($groupid_arr as $tmpgroupindex=>$tmpgroupid){
                $groupobj->groupname=$groupname_arr[$tmpgroupindex];
                $groupobj->groupid=$tmpgroupid;
                $tmp_group_arr[]=getWx_GroupName($groupobj);
            }
            $groupname=implode(',',$tmp_group_arr);
            $userfilepath = $this->getUserImage($userimgpath,$userimgname,$attachmentsid,$userid);
            $description = empty($groupname)?$profilename:$profilename.'-'.$groupname;
            $detail_value[] = array(
                                'lastname'=>$lastname,
                                'description'=>$description,
                                'userimg'=>$userfilepath,
                                'wx_userid'=>$wx_userid
                              );
        }

        $this->jsonArr['list1'] = $detail_value;
        $this->jsonArr['modulename'] = getFixedLabel('ShareUsers');
        return $this->jsonArr;
    }

    /**
     * edit:can
     * reason:获取用户头像路径
    **/
    public function getUserImage($path,$userimagename,$attachmentsid,$userid)
    {   $userimagetypes=explode('.',$userimagename);
        $userimagetype=$userimagetypes[sizeof($userimagetypes)-1];//获取用户照片的后缀名
        if(!empty($attachmentsid)&&!empty($path)){
            // ljj 20231214 BUG0077224 移动端，客户模块相关信息团队栏目下，成员没有显示头像
            $userfilepath=$path.$userimagename;
        }
        else{
            // ljj 20231201 XUQIU1000927 更换默认头像
            $userfilepath=getDefaultAvatar($userid);
        }
        $userfilepath_True = globalStatic::$root_directory.$userfilepath;//gyq date:20170324
        if(!file_exists($userfilepath_True))
        {
            $userfilepath='themes/images/defaultuser.png';
        }
        return $userfilepath;
    }

    protected function getQuery(){
        $sql='SELECT
                	ld_users.last_name AS lastname,
                    ld_users.wx_userid,
                	ld_users.userlevel,
                	ld_users.id,
                	ld_profile.profilename,
                	ld_attachments.`path` AS userimgpath,
                	ld_attachments.newfile_name AS userimgname,
                	ld_attachments.attachmentsid,
                    GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid asc ) as groupname,
                    GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid asc ) as groupid
                FROM
                	ld_tabshare
                RIGHT JOIN ld_users ON ld_users.id = ld_tabshare.viewuserid
                LEFT JOIN ld_profile ON ld_users.profileid = ld_profile.profileid
                LEFT JOIN ld_salesmanattachmentsrel ON ld_users.id = ld_salesmanattachmentsrel.smid
                LEFT JOIN ld_attachments ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid
                LEFT JOIN ld_users2group on ld_users2group.userid=ld_users.id
                LEFT JOIN ld_groups on ld_groups.groupid=ld_users2group.groupid
                WHERE
                	ld_tabshare.crmid ='.$this->recordid;
        return $sql;
    }

    public function addStdSearchContentWX($searchname){
        $query = ' and last_name like \'%'.$searchname.'%\'';
        return $query;
    }
}