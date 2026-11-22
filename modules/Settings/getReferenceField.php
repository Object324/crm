<?php
$fldmodule=$_REQUEST['fld_module'];

$focus=CRMEntity::getInstance($fldmodule);
$modulefields=$focus->fieldobj->getModuleFields();

$infos=Field::getAllFieldTypeInfo($adb);
$uitypes = [];
foreach($infos as $index=>$info)
{
    //edit:can 20210811 47401: （https://51mis.com/hy/gongcyans0806 [^]）(工程）【项目管理】-【工程竣工验收报告】 无法引用“项目负责人”字段
    if($info['type']!=''&&$info['type']!='Users'&&$info['fieldtype']!='reference'&&$info['fieldtype']!='multireference')//去除关联选择单据
    $uitypes[]=$info['uitype'];//获取相关的referencefield

}
$notShowModulecolumns = array();
$notShowModulecolumns[]='publicaccount';//ls 240510 公海状态属于特殊复选框字段,应该不支持引用
if($fldmodule == 'Users'){
    $notShowModulecolumns = $focus->getSearchNoshowfields();
    $notShowModulecolumns[]='user_name';
    $notShowModulecolumns[]='user_password';
    $notShowModulecolumns[]='confirm_password';
    $notShowModulecolumns[]='wx_userid';
    $notShowModulecolumns[]='wx_openid';
    $notShowModulecolumns[]='dingtalk_userid';
    $notShowModulecolumns[]='yunzhijia_wbuserid';
    $notShowModulecolumns[]='fanwei_userid';
    $notShowModulecolumns[]='zhiyuan_userid';
    $notShowModulecolumns[]="profileid";
    $notShowModulecolumns[]='helpdesk_log';
    $notShowModulecolumns[]='accountallview';
    $notShowModulecolumns[]='campaignsview';

    $selectmembers_arr = [];
    if(!empty($_REQUEST['frommodule'])) {
        $frommodule = $_REQUEST['frommodule'];
        $fromfocus = CRMEntity::getInstance($frommodule);

        $tmp_fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey('columnname', $fromfocus->getSmownerColumName());
        if ($tmp_fieldinfo && $tmp_fieldinfo->getDisplaytype() != 2) {
            $selectmembers_arr[$tmp_fieldinfo->getColumnName()] = $tmp_fieldinfo->getFieldLabel();
        }

        $tmp_fieldinfo = $fromfocus->fieldobj->getFieldInfoobjBykey('columnname', $fromfocus->getCreateColumnName());
        if ($tmp_fieldinfo && $tmp_fieldinfo->getDisplaytype() != 2) {
            $selectmembers_arr[$tmp_fieldinfo->getColumnName()] = $tmp_fieldinfo->getFieldLabel();
        }

        //所有单选用户类型的字段
        $fieldModules = $fromfocus->fieldobj->getModuleFields();
        foreach ($fieldModules as $temp_fieldname => $temp_fieldinfo) {
            //wym XUQIU1000290 displaytype=2 的字段不显示
            if ($temp_fieldinfo->getColumnName() != '' && (strtolower($temp_fieldinfo->getBigType()??'') == 'selectoneuser' || strtolower($temp_fieldinfo->getBigType()??'') == 'users') && $temp_fieldinfo->getDisplaytype() != 2) {//153
                $selectmembers_arr[$temp_fieldinfo->getColumnName()] = $temp_fieldinfo->getFieldLabel();
            }
        }
    }
}

foreach($modulefields as $fieldname=>$fieldinfo)
{
    $fieldLabel=$fieldinfo->getFieldLabel();
    $savedatabase=$fieldinfo->getSaveDataBase();
    if($savedatabase!='yes')
    {
        //42821: (61mis.com/kfbcrm)系统设置-页面设置；在设置字段为引用字段时，可以引用不是数据库中的“字段”；预期：引用字段不可以引用没有保存到数据库的字段
        continue;
    }
    $uitype=$fieldinfo->getUIType();
    $bigtype=$fieldinfo->getBigType();
    $tablename=$fieldinfo->getTableName();
    $parentbigtype=$fieldinfo->getParentBigType();
    //wym 231225 BUG0077489 放开不能引用 引用关联选择单据字段（不存数据库的已经被过滤掉了）
/*    if($fieldinfo->isRelatedModuleField()&&!empty($parentbigtype)&&$parentbigtype == 'reference'){
        //不能引用 引用关联选择单据字段
        continue;
    }*/
    if(!in_array($tablename,$focus->tab_name)&&($uitype!=1109&$tablename!='ld_attachments'))
    {
        continue;
    }

    if($fldmodule == 'Users' && $bigtype == 'qrcode'){//xxy 2023-12-15 引用字段选择成员管理中的字段时，排除二维码字段 
        continue;
    }
    if(in_array($fieldname,$notShowModulecolumns))
    {
        continue;
    }

	//chj 2020/11/16 引用字段，去除标签字段
    //wym XUQIU1001671 页面设置/单据分录定制，引用字段增加可选关联对象的“附件”和“图片”字段（李小亮）
    if($uitype==117 ||$uitype==301
            || $uitype==28||$bigtype=='selectsource'||in_array($uitype,$uitypes)||$uitype==222||$uitype==65 || $uitype==64
            ||$uitype==1500 || $uitype == 306  )
    {
        //edit:can 20230721 69513 患者档案（联系人模块），超链接字段改为编号后，跟进记录和订单中选择联系人后，增加引用字段，想带出来联系人姓名，选择不到姓名字段了，反而还是能选择编号 
        continue;
    }
    if(isset($_REQUEST['fromtabletype']) && $_REQUEST['fromtabletype'] == 'detail'){
        if($uitype == 153 || $uitype == 154){
            //continue;
        }
    }
    //edit: xll 2023/06/06 XUQIU1001203 引用字段增加“显示超链接”字段属性
    $isHrefField = 'no';
    if($uitype == '112' || $bigtype == 'reference'){
        $isHrefField = 'yes';
    }

    $arr[]=array('fieldname'=>$fieldname,'fieldlabel'=>$fieldLabel,'isHrefField'=>$isHrefField);
}
$_REQUEST['diony']='yes';
$tmp['list']=$arr;
$tmp['selectuser']=$selectmembers_arr;
ConvertTojsonString(1,$tmp,'success');

?>