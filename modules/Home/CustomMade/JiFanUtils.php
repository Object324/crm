<?php
class JiFanUtils
{
    public function getList(){

        $_REQUEST['diony']='yes';
        $org_name = $_REQUEST['search_zuzhi'];
        $F_TRXQ_BaseProperty1 = $_REQUEST['search_huohao'];
        $search_productname =$_REQUEST['search_productname'];
        $search_productno = $_REQUEST['search_productno'];
        $search_productsheet = $_REQUEST['search_productsheet'];
        $search_pihao = $_REQUEST['search_pihao'];
        $search_warename = $_REQUEST['search_warename'];
        if(!empty($F_TRXQ_BaseProperty1) || !empty($search_productname) || !empty($search_productno) || !empty($search_productsheet) || !empty($search_pihao) || !empty($search_warename)){
            $FStockOrgId = 0;	//库存组织
            $data = '[{"FormId":"ORG_Organizations","FieldKeys":"FOrgID,FName","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $org_result = $this->selectApiResult($data);
            if(!empty($org_result)){
                foreach($org_result as $info){
                    $org[$info[0]] = $info[1];
                    if($org_name == $info[1]){
                        $FStockOrgId = $info[0];
                    }
                }
            }
            if(!empty($org_name)){
                foreach($org as $id => $name){
                    if($org_name == $name){
                        $FStockOrgId = $id;
                    }
                }
                if(empty($FStockOrgId)){
                    ConvertTojsonString(-1,array(),"库存组织不存在！");
                }
            }

            $FUseOrgId = $org_result[0][0];
            //计量单位
            $data = '[{"FormId":"BD_UNIT","FieldKeys":"FUNITID,FNAME","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $result = $this->selectApiResult($data);
            if(!empty($result)){
                foreach($result as $info){
                    $unit[$info[0]] = $info[1];
                }
            }
            //物料名称 物料编码 货号 规格型号 批号 仓库名称
            //库存状态
            $data = '[{"FormId":"BD_StockStatus","FieldKeys":"FStockStatusId,FName","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $stock_result = $this->selectApiResult($data);
            foreach($stock_result as $info){
                $stockstatus[$info[0]] = $info[1];
            }
            $FilterString_fstockorgid = [];
            //货号
            if(!empty($F_TRXQ_BaseProperty1)){
                $FilterString_fstockorgid[] = " F_TRXQ_BaseProperty1 like '%".$F_TRXQ_BaseProperty1."%'";
            }
            //组织
            if(!empty($FStockOrgId)){
                $FilterString_fstockorgid[] = " FStockOrgId='".$FStockOrgId."'";
            }
            //产品名称
            if(!empty($search_productname)){
                $FilterString_fstockorgid[] = " FMaterialName like '%".$search_productname."%'";
            }
            //产品编号
            if(!empty($search_productno)){
                $FilterString = "FNumber like '%".$search_productno."%'";
                if(!empty($FStockOrgId)){
                    $FilterString .= " and FUseOrgId = '".$FStockOrgId."'";
                }
                $data = '[{"FormId":"BD_MATERIAL","FieldKeys":"FMATERIALID","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                $result = $this->selectApiResult($data);
                $FMATERIALID = [];
                if(!empty($result)){
                    foreach($result as $info){
                        $FMATERIALID[] = 'FMaterialId='.$info[0];
                    }
                }
                if(!empty($FMATERIALID)){
                    $FilterString_fstockorgid[] = '('.implode(' or ',$FMATERIALID).')';
                }

            }
            //规则型号
            if(!empty($search_productsheet)){
                /*$FilterString = "FSpecification like '%".$search_productsheet."%'";
                if(!empty($FStockOrgId)){
                    $FilterString .= " and FUseOrgId = '".$FStockOrgId."'";
                }
                $data = '[{"FormId":"BD_MATERIAL","FieldKeys":"FMATERIALID","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                $result =selectApiResult($data);
                $FMATERIALID = [];
                if(!empty($result)){
                    foreach($result as $info){
                        $FMATERIALID[] = 'FMaterialId='.$info[0];
                    }
                }
                if(!empty($FMATERIALID)){
                    $FilterString_fstockorgid[] = '('.implode(' or ',$FMATERIALID).')';
                }*/
                $FilterString_fstockorgid[] = " FModel like '%".$search_productsheet."%'";


            }
            //批号
            if(!empty($search_pihao)){
                $FilterString = "FNumber like '%".$search_pihao."%'";
                if(!empty($FStockOrgId)){
                    $FilterString .= " and FUseOrgId = '".$FStockOrgId."'";
                }
                $data = '[{"FormId":"BD_BatchMainFile","FieldKeys":"FLOTID","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';

                $pihao_result = $this->selectApiResult($data);

                if(!empty($pihao_result)){
                    foreach($pihao_result as $pihao_id){
                        $pids[] = " FLot =  '".$pihao_id[0]."'";
                    }
                    $FilterString_fstockorgid[] = '(' . implode(' or ', $pids) . ')';
                }
                //$pihao = $pihao_result[0][0];
                //$FilterString_fstockorgid[] = " FLot like '%".$search_pihao."%'";
            }
            //获取所有仓库
            if(!empty($FStockOrgId)){
                $FilterString .= "FUseOrgId = '".$FStockOrgId."'";
            }
            $data = '[{"FormId":"BD_STOCK","FieldKeys":"FName,FDescription","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $cangku_result = $this->selectApiResult($data);
            foreach($cangku_result as $arr){
                $all_cangk[$arr[0]] = trim($arr[1]);
            }
            //仓库名称
            if(!empty($search_warename)){
                $FilterString_fstockorgid[] = " FStockName like '%".$search_warename."%'";
            }else{
                if(!empty($org_name)){
                    if($org_name == '济凡生物科技（北京）有限公司'){
                        $FilterString_fstockorgid[] = " FStockName = '成品库'";
                    }else if($org_name == '济凡生物科技（常州）有限公司'){
                        $FilterString_fstockorgid[] = " (FStockName = '常州成品仓' or FStockName = '常州公司-北京临时成品仓' or FStockName = '广州临时仓'
				or FStockName = '泉州临时仓' or FStockName = '上海临时仓' or FStockName = '成品库'
				or FStockName = '武汉临时仓' or FStockName = '常州公司-蓝鲸临时成品仓' or FStockName = '退货仓')";
                    }else if($org_name == '江苏蓝鲸生物医疗科技有限公司'){
                        $FilterString_fstockorgid[] = " FStockName = '成品仓' ";
                    }else if($org_name == '苏州星谱生物科技有限公司'){
                        $FilterString_fstockorgid[] = " FStockName = '成品仓' ";
                    }else if($org_name == '得赛生物科技（南京）有限公司'){
                        $FilterString_fstockorgid[] = " FStockName = '仓库' ";
                    }else if($org_name == '知禾同创生物科技（北京）有限公司'){
                        $FilterString_fstockorgid[] = " FStockName = '成品库' ";
                    }else if($org_name == '谱帆生物科技（上海）有限公司'){
                        $FilterString_fstockorgid[] = " FStockName = '默认仓库' ";
                    }
                }
            }

            $FilterString_fstockorgid_str = "1=2";
            if(!empty($FilterString_fstockorgid)){
                $FilterString_fstockorgid_str = implode(' and ',$FilterString_fstockorgid) . ' and FBaseQty > 0 ';
            }
            //原材料库
            //echo $FilterString_fstockorgid_str;echo '<br><br>';die;
            $data = '[{"FormId":"STK_Inventory","FieldKeys":"FBaseQty,FBaseAVBQty,FStockName,FMaterialId,FStockStatusId,FLot,FBaseUnitId,FStockOrgId,FProduceDate","FilterString":"'.$FilterString_fstockorgid_str.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            //echo $data .'<br>';
            $result = $this->selectApiResult($data);

            if(!empty($result[0][0]->Result->ResponseStatus->Errors)){
                $info = explode('expression is',$result[0][0]->Result->ResponseStatus->Errors[0]->Message);
                echo $info[0];
                die;
            }
            $stock_pro = [];
            $locakstock_pro = [];
            foreach($result as $info){
                $proid[$info[3]] = $info[3];
                $locakstock_pro[$info[7]] = $info[7];
            }
            //库存锁库
            foreach($locakstock_pro as $stockid){
                $data = '[{"FormId":"STK_LockStock","FieldKeys":"FBaseLockQty,FStockId,FMaterialId","FilterString":"FStockId='.$stockid.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                $lockstock_data = $this->selectApiResult($data);

                if(sizeOf($lockstock_data) >= 1){
                    foreach($lockstock_data as $row){
                        $stock_pro[$info[7]][$row[2]] += $row[0];
                    }
                }
            }

            if(!empty($proid)){
                foreach($proid as $id){
                    $data = '[{"FormId":"BD_MATERIAL","FieldKeys":"FMATERIALID,FName,FNumber,FSpecification,FMnemonicCode","FilterString":"FMATERIALID ='.$id.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                    $pro_result = $this->selectApiResult($data);
                    $pro_arr[$id] = array(
                        'fname' => $pro_result[0][1],
                        'fnumber' => $pro_result[0][2],
                        'fpecification' => $pro_result[0][3],
                        'fmneminiccode' => $pro_result[0][4],
                    );
                }
            }

            foreach($result as $info){
                //if(empty($info[0]))continue;
                $fmateridalid = $info[3];
                $stockid = $info[7];
                //批号
                $pihao = '';
                if(!empty($info[5])){
                    $data = '[{"FormId":"BD_BatchMainFile","FieldKeys":"FNumber","FilterString":"FLOTID=\''.$info[5].'\'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                    $pihao_result = $this->selectApiResult($data);
                    $pihao = $pihao_result[0][0];
                }
                $cangku = $info[2];
                if(isset($all_cangk[$cangku]) && $all_cangk[$cangku] != '' ){
                    //echo $all_cangk[$cangku] . '<br>rrr3' . strlen($all_cangk[$cangku]);
                    continue;
                }
                $list[] = array(
                    'fname' => $pro_arr[$fmateridalid]['fname'],
                    'fnumber' => $pro_arr[$fmateridalid]['fnumber'],
                    'fpecification' => $pro_arr[$fmateridalid]['fpecification'],
                    'fmneminiccode' => $pro_arr[$fmateridalid]['fmneminiccode'],
                    'fbaseqty' => $info[0],
                    'fbaseavbqty' => $info[0] - $stock_pro[$stockid][$fmateridalid],	//$info[1]
                    'stickname' => $info[2],
                    'fmateridalid' => $fmateridalid,
                    'fstockstatusid' => $stockstatus[$info[4]],
                    'pihao' => $pihao,
                    'danwei' => $unit[$info[6]],
                    'duzhi' => $org[$info[7]],
                    'fproducedate' => $info[8]
                );
            }
        }
        return $list;
    }
    public function DashboardJiFanKucun(){
        $_REQUEST['from_mobile']='yes';//来自移动端
        $searchcontent=$_REQUEST['filter']['searchcontent'];
        $_REQUEST['compartor'] = ' and ';
        if(!empty($searchcontent)){
            $_REQUEST['search_zuzhi'] = $searchcontent == '全部'?'':$searchcontent;
            $_REQUEST['search_huohao'] = $searchcontent;
            $_REQUEST['search_productname'] = $searchcontent;
            $_REQUEST['search_productno'] = $searchcontent;
            $_REQUEST['search_productsheet'] = $searchcontent;
            $_REQUEST['search_pihao'] = $searchcontent;
            $_REQUEST['search_warename'] = $searchcontent;
        }
        $report_high_search = $_REQUEST['report_high_search'];
        $zuzhiArr = [
            ''=>'全部',
            '济凡集团'=>'济凡集团',
            '济凡生物科技（北京）有限公司'=>'济凡生物科技（北京）有限公司',
            '济凡生物科技（常州）有限公司'=>'济凡生物科技（常州）有限公司',
            '蓝鲸生物科技（南京）有限公司'=>'蓝鲸生物科技（南京）有限公司',
            '江苏蓝鲸生物医疗科技有限公司'=>'江苏蓝鲸生物医疗科技有限公司',
            '苏州星谱生物科技有限公司'=>'苏州星谱生物科技有限公司',
            '谱帆生物科技（上海）有限公司'=>'谱帆生物科技（上海）有限公司',
            '爱赛生物科技（南京）有限公司'=>'爱赛生物科技（南京）有限公司',
            '得赛生物科技（南京）有限公司'=>'得赛生物科技（南京）有限公司',
            '知禾同创生物科技（北京）有限公司'=>'知禾同创生物科技（北京）有限公司',
        ];

        if(!empty($report_high_search)){
            $_REQUEST['search_zuzhi'] = $zuzhiArr[$report_high_search[0]['text']] == '全部'?'':$zuzhiArr[$report_high_search[0]['text']];
            $_REQUEST['search_warename'] = $report_high_search[1]['text'];
            $_REQUEST['search_huohao'] = empty($report_high_search[2]['text'])?$_REQUEST['search_huohao']:$report_high_search[2]['text'];
            $_REQUEST['search_productno'] = empty($report_high_search[3]['text'])?$_REQUEST['search_productno']:$report_high_search[3]['text'];
            $_REQUEST['search_productname'] = empty($report_high_search[4]['text'])?$_REQUEST['search_productname']:$report_high_search[4]['text'];
            $_REQUEST['search_pihao'] = empty($report_high_search[5]['text'])?$_REQUEST['search_pihao']:$report_high_search[5]['text'];
            $_REQUEST['search_productsheet'] = empty($report_high_search[6]['text'])?$_REQUEST['search_productsheet']:$report_high_search[6]['text'];
        }
        //dump($_REQUEST['search_zuzhi'] );

        $list = $this->getList();
        $count = sizeof($list);
        $list1 = [];
        foreach($list as $k=>$v){
            $list1[] = array(
                'title'=>"物料编码：".$v['fnumber'],//物料编码
                'field'=>array(
                    '物料名称：'.$v['fname'],
                    '货号：'.$v['fmneminiccode'],
                    '仓库名称：'.$v['stickname'],
                    '可用量：'.$v['fbaseavbqty'],
                    '批号：'.$v['pihao'],
                    '生产日期：'.strstr($v['fproducedate'],0,10),
                    '规格型号：'.$v['fpecification'],
                    '基本单位：'.$v['danwei'],
                    '库存量：'.$v['fbaseqty'],
                    '库存状态：'.$v['fstockstatusid'],
                    '库存组织：'.$v['duzhi'],
                )
            );
        }
        $res['list1'] = $list1;//数据
        $res['report_high_search'] = array(//筛选条件
            array(
                'fieldlabel'=>'库存组织',
                'fieldname'=>'search_zuzhi',
                'fieldtype'=>'15',
                'text'=>'全部',
                'option'=>array(
                    array("select"=> "yes",
                        "text"=>"全部",
                        "value"=>""),
                    array("select"=> "no",
                        "text"=>"济凡集团",
                        "value"=>"济凡集团"),
                    array("select"=> "no",
                        "text"=>"济凡生物科技（北京）有限公司",
                        "value"=>"济凡生物科技（北京）有限公司"),
                    array("select"=> "no",
                        "text"=>"济凡生物科技（常州）有限公司",
                        "value"=>"济凡生物科技（常州）有限公司"),
                    array("select"=> "no",
                        "text"=>"蓝鲸生物科技（南京）有限公司",
                        "value"=>"蓝鲸生物科技（南京）有限公司"),
                    array("select"=> "no",
                        "text"=>"江苏蓝鲸生物医疗科技有限公司",
                        "value"=>"江苏蓝鲸生物医疗科技有限公司"),
                    array("select"=> "no",
                        "text"=>"苏州星谱生物科技有限公司",
                        "value"=>"苏州星谱生物科技有限公司"),
                    array("select"=> "no",
                        "text"=>"谱帆生物科技（上海）有限公司",
                        "value"=>"谱帆生物科技（上海）有限公司"),
                    array("select"=> "no",
                        "text"=>"爱赛生物科技（南京）有限公司",
                        "value"=>"爱赛生物科技（南京）有限公司"),
                    array("select"=> "no",
                       "text"=>"得赛生物科技（南京）有限公司",
                       "value"=>"得赛生物科技（南京）有限公司"),
                    array("select"=> "no",
                       "text"=>"知禾同创生物科技（北京）有限公司",
                       "value"=>"知禾同创生物科技（北京）有限公司")
                )
            ),
            array(
                'fieldlabel'=>'仓库名称',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_warename'
            ),
            array(
                 'fieldlabel'=>'货号',
                 'fieldtype'=>'1',
                 'text'=>'',
                 'fieldname'=>'search_huohao'
            ),
             array(
                 'fieldlabel'=>'物料编码',
                 'fieldtype'=>'1',
                 'text'=>'',
                 'fieldname'=>'search_productno'
             ),
            array(
                'fieldlabel'=>'物料名称',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_productname'
            ),
            array(
                'fieldlabel'=>'批号',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_pihao'
            ),
            array(
                'fieldlabel'=>'规格型号',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_productsheet'
            ),
        );
        $res['search_reminds'] = '搜索仓库名称、货号、物料编码、物料名称、批号、规格型号';//模糊搜索
        $res['havenextpage'] = 'no';
        $res['haveprevpage'] = 'no';
        $res['curpagenum'] = 1;
        $res['pagecount'] = $count>0?1:0;
        $res['totalrows'] = $count;
        ConvertTojsonString(1,$res,'');
    }
    public function getApiReturnData($FormId,$FieldKeys,$FilterString,$OrderString='',$TopRowCount = 0,$StartRow = 0,$Limit = 0){
        $data = '[{"FormId":"'.$FormId.'","FieldKeys":"'.$FieldKeys.'","FilterString":"'.$FilterString.'","OrderString":"'.$OrderString.'","TopRowCount":"'.$TopRowCount.'","StartRow":"'.$StartRow.'","Limit":"'.$Limit.'"}]';
        $result =$this->selectApiResult($data);
        $FieldKeys_array = explode(',',$FieldKeys);
        if(!empty($result)){
            foreach($result as $key => $res){
                foreach($res as $key1 => $value){
                    $fieldkey = $FieldKeys_array[$key1];
                    $return_data[$key][$fieldkey] = $value;
                }
            }
        }
        return $return_data;
    }



    //K3 Cloud 登陆验证
    public function check_invoke_login($cloudUrl,$user,$pwd,$dbname)
    {
        //登陆参数
        $data = array(
            $dbname,//帐套Id
            $user,//用户名
            $pwd,//密码
            2052//语言标识
        );
        //定义记录Cloud服务端返回的Session
		$root_directory = explode('www',globalStatic::$root_directory);
		$cookie_jar = tempnam($root_directory[0].'/tmp','CloudSession');
        //$cookie_jar = tempnam('G:\crm\ldcrm/tmp','CloudSession');
        $post_content = $this->create_postdata($data);
        $loginurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
        return $this->invoke_post($loginurl,$post_content,$cookie_jar,TRUE);
    }
    //K3 Cloud 登陆
    public function invoke_login($cloudUrl,$post_content,$cookie_jar)
    {
        $loginurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
        return $this->invoke_post($loginurl,$post_content,$cookie_jar,TRUE);
    }

    //K3 Cloud 保存
    public function invoke_save($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }

    //K3 Cloud 审核
    public function invoke_audit($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    //K3 Cloud 查看
    public function invoke_view($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.View.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    //K3 Cloud 删除
    public function invoke_delete($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    //K3 Cloud 分配
    public function invoke_allocate($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Allocate.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    //K3 Cloud 反审核
    public function invoke_unaudit($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.unAudit.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    //K3 Cloud 提交
    public function invoke_submit($cloudUrl,$post_content,$cookie_jar)
    {

        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    //K3 Cloud 状态转换
    public function invoke_statusconvert($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.StatusConvert.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }
    public function invoke_select($cloudUrl,$post_content,$cookie_jar)
    {
        $invokeurl = $cloudUrl.'Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
        return $this->invoke_post($invokeurl,$post_content,$cookie_jar,FALSE);
    }

    public function invoke_post($url,$post_content,$cookie_jar,$isLogin)
    {
        $ch = curl_init($url);

        $this_header = array(
            'Content-Type: application/json',
            'Content-Length: '.strlen($post_content)
        );

        curl_setopt($ch, CURLOPT_CUSTOMREQUEST, 'POST');
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $this_header);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $post_content);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        if($isLogin){
            curl_setopt($ch, CURLOPT_COOKIEJAR, $cookie_jar);
        }
        else{
            curl_setopt($ch, CURLOPT_COOKIEFILE, $cookie_jar);
        }
        curl_setopt($ch, CURLOPT_TIMEOUT, 30);

        $result = curl_exec($ch);
        curl_close($ch);

        return $result;
    }

    //构造Web API请求格式
    public function create_postdata($args) {
        $postdata = array(
            'format'=>1,
            'useragent'=>'ApiClient',
            'rid'=>$this->create_guid(),
            'parameters'=>$args,
            'timestamp'=>date('Y-m-d'),
            'v'=>'1.0'
        );
        return json_encode($postdata);
    }

    //生成guid
    public function create_guid() {
        $charid = strtoupper(md5(uniqid(mt_rand(), true)));
        $hyphen = chr(45);// "-"
        $uuid = chr(123)// "{"
            .substr($charid, 0, 8).$hyphen
            .substr($charid, 8, 4).$hyphen
            .substr($charid,12, 4).$hyphen
            .substr($charid,16, 4).$hyphen
            .substr($charid,20,12)
            .chr(125);// "}"
        return $uuid;
    }
    // api查询方法
    function  selectApiResult($data){
        global $adb;
        $query = "select api_cert,api_user,api_pwd,api_fromid from ld_module_api where module = 'SalesOrder'";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if(empty($num_rows)){
            return '';
        }
        $api_cert = $adb->query_result($result,0,'api_cert');
        $api_user = $adb->query_result($result,0,'api_user');
        $api_pwd = $adb->query_result($result,0,'api_pwd');
        $api_fromid = $adb->query_result($result,0,'api_fromid');
        $cloudUrl = $api_cert;
        $dbname = $api_fromid;
        $user = $api_user;
        $pwd = $api_pwd;
        //登陆参数
        $login_data = array(
            $dbname,//帐套Id
            $user,//用户名
            $pwd,//密码
            2052//语言标识
        );

        //定义记录Cloud服务端返回的Session
        //echo globalStatic::$root_directory;die;
        $cookie_jar = tempnam('G:\crm\ldcrm/tmp','CloudSession');
        $post_content = $this->create_postdata($login_data);

        $a = $this->invoke_login($cloudUrl,$post_content,$cookie_jar);
        //print_r($a);die;
        $post_content = $this->create_postdata($data);
        $result = $this->invoke_select($cloudUrl,$post_content,$cookie_jar);
        //print_r($result);die;
        $result = json_decode($result);
        return $result;
    }
}