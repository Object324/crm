<?php
/**
 * reason：外部联系人进入系统需要判断查询的客户名对应多少个客户，进入不同的页面
 * date：20180418
 * editor：xxs
 */
    global $currentModule,$current_user,$adb;
    crm_load_class_file('cls_ListViewWX', 'WeiXinApp/list');
    $currentModule = 'Accounts';
    $searchfield = 'accountname';
    $searchcontent = $_REQUEST['searchcontent'];
    $_REQUEST['SearchScope'] = 'SmOwner_Search_All';
    
    $mobj = new cls_ListViewWX($currentModule);
    
    $customview_obj = $mobj->init_custom();
    crm_load_class_file('QueryGeneratorWX', 'WeiXinApp/QueryGenerator');
    $querygenerator = QueryGeneratorWX::getInstance($mobj->module, $current_user,$customview_obj,'','yes');
    $querygenerator->initForCustomViewById($mobj->viewid);
    
    $querygenerator->addCondition($searchfield, $searchcontent, 'c');
    $page_list_query = $querygenerator->getQuery('', 1);
    //echo $page_list_query;exit;
    $result = $adb->pquery($page_list_query);
    $num_rows = $adb->num_rows($result);
    //$num_rows = 0;
    if($num_rows>1){
        $output = array('type'=>2,'value'=>$searchcontent);
    }elseif($num_rows==1){
        $id =  $adb->query_result($result,0,0);
        $output = array('type'=>1,'value'=>$id);
    }else{
        $sql = "select accountname from ld_account where accountname like '%$searchcontent%' and deleted=0";
        $accountobj = $mobj->fieldobj->getFieldInfoobjBykey('accountname');
        if(!empty($accountobj)){
            $accountnamelabel = $accountobj->getFieldLabel();
        }
        $result2 = $adb->pquery($sql,array());
        $num_rows2 = $adb->num_rows($result2);
        //系统存在模糊查询到的客户，但不在此用户数据范围中
        if($num_rows2){
            $accountnamestr = '';
            $limitaccount = 5;//客户名称限制个数
            for($i=0;$i<$num_rows2;$i++){
                $idot = $i<$num_rows2-1&&$i<=$limitaccount-2?'、':'';
                $accountnamestr .= $adb->query_result($result2,$i,'accountname').$idot;
                if($i>$limitaccount-2){
                    $accountnamestr .= '等';
                    break;
                }
            }
            $output = array('type'=>4,'value'=>$accountnamelabel.'：'.$accountnamestr);
        }else{
            $output = array('type'=>3,'value'=>'');
        }
    }
    $output['modulelabel'] = getTransTab('Accounts');
    ConvertTojsonString(1,$output,'success');