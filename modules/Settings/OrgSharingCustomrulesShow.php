<?php
global $current_user,$default_charset,$adb;

if(!empty($_REQUEST['mode'])){
    if($_REQUEST['mode'] == 'delete'){
        $query = 'delete from ld_org_share_customrules where customruleid = ? and tabid=?';
        $adb->pquery($query,array($_REQUEST['customrule_id'],$_REQUEST['frommodule']));
    }
}
if(!empty($_REQUEST['tabid'])){
    $tabid = $_REQUEST['tabid'];
}
$smarty = new lingdangCRM_Smarty();
$smarty->assign('rowindex',$_REQUEST['rowindex']);
$smarty->assign('tabid',$tabid);
$customrulearr=[];
$query = "select customruleid,permission,profileid,groupid,userid,share_demand,share_demand_groups from ld_org_share_customrules where tabid=? ";
$query .= "order by customruleid asc";
$result = $adb->pquery($query,array($tabid));

$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
    for($i = 0; $i < $num_rows; $i++){
        $index=$i+1;
        $customruleid = $adb->query_result($result,$i,'customruleid');
        $customrulearr[$index]['customruleid']=$customruleid;

        $permission = $adb->query_result($result,$i,'permission');
        if($permission=='read'){
            $permissiontd=getFixedLabel('Read Only');
        }else{
            $permissiontd=getFixedLabel('Read and write');
        }
        $customrulearr[$index]['permission']=$permissiontd;

        $profileid = $adb->query_result($result,$i,'profileid');
        $profilenametd='';
        if(!empty($profileid)){
            $profilename_arr=[];
            $profileid_arr=explode(',',trim($profileid));//指定角色
            if(sizeof($profileid_arr)>0){
                $profile = new Profile();
                foreach($profileid_arr as $tmp_profileid)
                {
                    $profileinfo = $profile->getProfileinfo($tmp_profileid);
                    $profilename_arr[] .= $profileinfo['profilename'];
                }
                $profilenametd = getFixedLabel('LBL_ROLE_NAME').'：'.implode(',',$profilename_arr).'；';
            }
        }
        $groupid = $adb->query_result($result,$i,'groupid');
        $groupnametd='';
        if(!empty($groupid)){
            $groupname_arr=[];
            $groupid_arr=explode(',',trim($groupid));//指定部门
            if(sizeof($groupid_arr)>0){
                foreach($groupid_arr as $tmp_groupid)
                {
                    $groupname_arr[] .= getGroupFullName($tmp_groupid);
                }
                $groupnametd = getFixedLabel('DEPARTMENT').'：'.implode(',',$groupname_arr).'；';
            }
        }
        $userid = $adb->query_result($result,$i,'userid');
        $usernametd='';
        if(!empty($userid)) {
            $username_arr=[];
            $userid_arr = explode(',', trim($userid));//指定用户
            if (sizeof($userid_arr) > 0) {
                foreach ($userid_arr as $tmp_userid) {
                    $username_arr[] .= getUserFullName($tmp_userid);
                }
                $usernametd =  getFixedLabel('USER').'：'. implode(',', $username_arr) . '；';
            }
        }
        $sharerange=$profilenametd.$groupnametd.$usernametd;
        $sharerangetd=trim($sharerange,"；");
        $customrulearr[$index]['shareto']=$sharerangetd;

        $advft_criteria = $adb->query_result($result,$i,'share_demand');
        $advft_criteria_groups = $adb->query_result($result,$i,'share_demand_groups');
        $advfilterlist = getAdvFilter($advft_criteria,$advft_criteria_groups);
        $advfttd = getAdvTdhtml($advfilterlist);
        $customrulearr[$index]['advft']=$advfttd;
    }
}
$smarty->assign('customrulearr',$customrulearr);
$arr['content'] = $smarty->fetch("OrgSharingCustomrulesList.tpl");
$_REQUEST['diony']='yes';

ConvertTojsonString(1,$arr,"success");

function getAdvFilter($s_advft_criteria,$s_advft_criteria_groups) {

    global $adb,  $default_charset;
    $advfiltergroup=ldcrm_json_decode(html_entity_decode($s_advft_criteria_groups));
    $advfilterlist = ldcrm_json_decode(html_entity_decode($s_advft_criteria));

    $i = 1;
    $j = 0;
    foreach($advfiltergroup as $key => $relcriteriagroup){
        if(empty($relcriteriagroup)){
            continue;
        }
        $groupId = $key;
        $groupCondition = $relcriteriagroup["groupcondition"];

        foreach($advfilterlist as $k => $relcriteriarow){
            if($relcriteriarow['groupid'] == $key){
                $columnIndex = $relcriteriarow["columnindex"];
                $criteria = array();
                $criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
                $criteria['comparator'] = $relcriteriarow["comparator"];
                $criteria['search_comparator']= $relcriteriarow["comparator"];
                $advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
                $col = explode(":", $relcriteriarow["columnname"]);
                $temp_val = explode(",", $relcriteriarow["value"]);
                if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
                    crm_load_class_file("DateTimeField","include/fields");
                    $val = Array();
                    for ($x = 0; $x < count($temp_val); $x++) {
                        if ($col[4] == 'D') {
                            $date = new DateTimeField(trim($temp_val[$x]));
                            $val[$x] = $date->getDisplayDate();
                        } elseif ($col[4] == 'DT') {
                            $date = new DateTimeField(trim($temp_val[$x]));
                            $val[$x] = $date->getDisplayDateTimeValue();
                        } else {
                            $date = new DateTimeField(trim($temp_val[$x]));
                            $val[$x] = $date->getDisplayTime();
                        }
                    }
                    $advfilterval = implode(",", $val);
                }
                $criteria['value'] = $advfilterval;
                $criteria['column_condition'] = $relcriteriarow["columncondition"];

                $advft_criteria[$i]['columns'][$j] = $criteria;
                $advft_criteria[$i]['condition'] = $groupCondition;

                $j++;
            }
        }
        if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
            $advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
        }
        $i++;
    }
    // Clear the condition (and/or) for last group, if any.
    if (!empty($advft_criteria[$i - 1]['condition']))
        $advft_criteria[$i - 1]['condition'] = '';


    return $advft_criteria;
}

function getAdvTdhtml($advfilterlist) {
    global $current_user,$adb;
    $languageType= getLanguageType($current_user);
    $i=1;
    $advfttd='<div style="width: 100%;">';
    foreach ($advfilterlist as $advfilter){
        $each_advfilter=$advfilter['columns'];
        $advfttd .= '<div index="'.$i.'"> ';
        foreach ($each_advfilter as $each_advfilter){
            $columnname_str = $each_advfilter['columnname'];
            $columnname_arr = explode(":",$columnname_str);
            $columnname = $columnname_arr[1];
            $columntab = $columnname_arr[0];
            $sql = "select ld_tranlabel.fieldlabel from ld_field INNER JOIN ld_tranlabel on ld_tranlabel.Relateid=ld_field.fieldid 
                               where ld_field.columnname=? and ld_field.tablename=? and ld_tranlabel.languagetype=? and ld_tranlabel.trantable='ld_field'";
            $result=$adb->pquery($sql,array($columnname,$columntab,$languageType));
            $fieldlabel =  $adb->query_result($result,0);
            $comparator = getAdvCriteriaHTML($each_advfilter['comparator']);
            $value = $each_advfilter['value'];
            $advfttd .= " ".$fieldlabel." ".$comparator." ".$value;
            $condition='';
            if($each_advfilter['column_condition']=='and'){
                $condition = getFixedLabel('SEARCHAND');
            }elseif ($each_advfilter['column_condition']=='or'){
                $condition = getFixedLabel('OR');
            }
            if(!empty($condition)){
                $advfttd .='&nbsp&nbsp'.$condition.'<br>';
            }
        }
        $advfttd .= '</div>';
        $condition='';
        if($advfilter['condition']=='and'){
            $condition = getFixedLabel('SEARCHAND');
        }elseif ($advfilter['condition']=='or'){
            $condition = getFixedLabel('OR');
        }
        if(!empty($condition)){
            $advfttd .='<p style="text-indent: 10em">'.$condition.'</p>';
        }
        $i++;
    }
    $advfttd .= '</div>';
    return $advfttd;
}

function getAdvCriteriaHTML($condition)
{
    $adv_filter_options_label = array("e" => "" . getFixedLabel('EQ') . "",
        "n" => "" . getFixedLabel('NEQ')  . "",
        "s" => "" . getFixedLabel('Begins') . "",
        "ew" => "" .getFixedLabel('Ends') . "",
        "c" => "" . getFixedLabel('IN')  . "",
        "k" => getFixedLabel('NOT_IN'),
        "l" => getFixedLabel('LT'),
        "g" => getFixedLabel('GT'),
        "m" => getFixedLabel('LE'),
        "h" =>getFixedLabel('GE'),
        "b" => getFixedLabel('Before'),
        "a" => getFixedLabel('After'),
        "bw" => getFixedLabel('Interval'),
        "isnull" => getFixedLabel('ISNULL'),
        "isnotnull" => getFixedLabel('ISNOTNULL'),
        "or" => getFixedLabel('OR'),
        "and" => getFixedLabel('SEARCHAND'),
        "curuser" => getFixedLabel('CURUSER')
    );
    $adv_filter_options_label['has_changed'] = getFixedLabel('haschanged');
    $adv_filter_options_label['has_changed_to'] = getFixedLabel('haschangedto');
    $adv_filter_options_label['has_changed_from'] = getFixedLabel('haschangedfrom');
    $conditionhtml =$adv_filter_options_label[$condition];

    return $conditionhtml;
}

?>