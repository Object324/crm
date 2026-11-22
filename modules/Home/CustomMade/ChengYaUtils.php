<?php
class ChengYaUtils
{
    public function getList(){
        $org_name = $_REQUEST['search_zuzhi'];
        $org_name = $org_name=='全部'?'':$org_name;
        $search_stockname = $_REQUEST['search_stockname'];
        $search_productname = $_REQUEST['search_productname'];
        $search_productno = $_REQUEST['search_productno'];
        $search_productsheet = $_REQUEST['search_productsheet'];
        if(!empty($search_productname) || !empty($search_productno) || !empty($search_productsheet)){
            $FStockOrgId = 0;	//库存组织
            $data = '[{"FormId":"ORG_Organizations","FieldKeys":"FOrgID,FName,FNumber","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $org_result =$this->selectApiResult($data);
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
            //物料名称 物料编码 规格型号
            //库存状态
            $data = '[{"FormId":"BD_StockStatus","FieldKeys":"FStockStatusId,FName","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $stock_result =$this->selectApiResult($data);
            foreach($stock_result as $info){
                $stockstatus[$info[0]] = $info[1];
            }

            $FilterString_fstockorgid = [];
            //组织
            if(!empty($FStockOrgId)){
                $FilterString_fstockorgid[] = " FStockOrgId='".$FStockOrgId."'";
            }
            //仓库名称
            if(!empty($search_stockname)) {
                $FilterString_fstockorgid[] = " FStockName like '%".$search_stockname."%'";
            }
            $data = '[{"FormId":"BD_STOCK","FieldKeys":"FSTOCKID,FNAME,FDescription","FilterString":"","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $resultStock =$this->selectApiResult($data);
            $stockArr = [];
            foreach($resultStock as $stockV){
                //描述字段为空的再返回到页面
                $fdescription = $stockV[2];
                if(empty(trim($fdescription))){
                    $stockArr[] =  $stockV[0];
                }
            }
            //产品名称
            if(!empty($search_productname)){
                $FilterString_fstockorgid[] = " FMaterialName like '%".$search_productname."%'";
            }
            //物料编码
            if(!empty($search_productno)){
                $FilterString = "FNumber like '%".$search_productno."%'";
                $data = '[{"FormId":"BD_MATERIAL","FieldKeys":"FMATERIALID","FilterString":"'.$FilterString.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                $result2 =$this->selectApiResult($data);
                $FMATERIALID = [];
                if(!empty($result2)){
                    foreach($result2 as $info){
                        $FMATERIALID[] = 'FMaterialId='.$info[0];
                    }
                }

                if(!empty($FMATERIALID)){
                    $FilterString_fstockorgid[] = '('.implode(' or ',$FMATERIALID).')';
                }
            }

            //规格型号
            if(!empty($search_productsheet)){
                $FilterString_fstockorgid[] = " FModel like '%".$search_productsheet."%'";
            }

            $FilterString_fstockorgid_str = "1=2";

            if(!empty($FilterString_fstockorgid)){
                $compartor = ' and ';
                if(!empty($_REQUEST['compartor'])){
                    $compartor = $_REQUEST['compartor'];
                }
                $FilterString_fstockorgid_str = '(' . implode($compartor,$FilterString_fstockorgid) . ') and FBaseQty > 0';
            }


            //原材料库
            $data = '[{"FormId":"STK_Inventory","FieldKeys":"FBaseQty,FBaseAVBQty,FStockName,FMaterialId,FStockStatusId,FLot,FBaseUnitId,FStockOrgId,FProduceDate,FSTOCKID","FilterString":"'.$FilterString_fstockorgid_str.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
            $result3 =$this->selectApiResult($data);
            if(!empty($result3[0][0]->Result->ResponseStatus->Errors)){
                $info = explode('expression is',$result3[0][0]->Result->ResponseStatus->Errors[0]->Message);
                echo $info[0];
                die;
            }
            $stock_pro = [];
            $locakstock_pro = [];
            foreach($result3 as $info){
                $proid[$info[3]] = $info[3];
                $locakstock_pro[$info[7]] = $info[7];
            }

            //库存锁库
            foreach($locakstock_pro as $stockid){
                $data = '[{"FormId":"STK_LockStock","FieldKeys":"FLockQty,FStockOrgId,FMaterialId,FSTOCKID","FilterString":"FStockOrgId='.$stockid.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                $lockstock_data = $this->selectApiResult($data);
//                print_r($lockstock_data);
                if(sizeOf($lockstock_data) >= 1){
                    foreach($lockstock_data as $row){
                        $stock_pro[$row[1]][$row[3]][$row[2]] += $row[0];
                    }
                }
            }
//            dump($stock_pro);

            if(!empty($proid)){
                foreach($proid as $id){
                    $data = '[{"FormId":"BD_MATERIAL","FieldKeys":"FMATERIALID,FName,FNumber,FSpecification,FMnemonicCode,FDescription ","FilterString":"FMATERIALID ='.$id.'","OrderString":"","TopRowCount":"0","StartRow":"0","Limit":"0"}]';
                    $pro_result = $this->selectApiResult($data);
                    $pro_arr[$id] = array(
                        'fname' => $pro_result[0][1],
                        'fnumber' => $pro_result[0][2],
                        'fpecification' => $pro_result[0][3],
                        'fdescription' => $pro_result[0][5],
                    );
                }
            }
            foreach($result3 as $info){
                $fmateridalid = $info[3];
                $stockid = $info[9];
                $FStockOrgId = $info[7];
                if(in_array($stockid,$stockArr)){
                    $list[] = array(
                        'fname' => $pro_arr[$fmateridalid]['fname'],
                        'fnumber' => $pro_arr[$fmateridalid]['fnumber'],
                        'fpecification' => $pro_arr[$fmateridalid]['fpecification'],
                        'fbaseqty' => $info[0],
                        'fbaseavbqty' => $info[0] - $stock_pro[$FStockOrgId][$stockid][$fmateridalid],	//$info[1]
                        'fstockstatusid' => $stockstatus[$info[4]],
                        'stockname' => $info[2],
                        'zuzhi' => $org[$info[7]]
                    );
                }
            }
        }
        return $list;
    }
    public function DashboardChengYaKucun(){
        $_REQUEST['from_mobile']='yes';//来自移动端
        $searchcontent=$_REQUEST['filter']['searchcontent'];
        $_REQUEST['compartor'] = ' and ';
        if(!empty($searchcontent)){
            $_REQUEST['search_stockname'] = $searchcontent;
            $_REQUEST['search_productname'] = $searchcontent;
            $_REQUEST['search_productno'] = $searchcontent;
            $_REQUEST['search_productsheet'] = $searchcontent;
            $_REQUEST['compartor'] = ' or ';
        }
        $report_high_search = $_REQUEST['report_high_search'];
        $zuzhiArr = [
            '全部'=>'全部',
            '000诚亚集团'=>'诚亚集团',
            '010北京诚亚科技有限责任公司'=>'北京诚亚科技有限责任公司',
            '022天津诚亚科技有限责任公司'=>'天津诚亚科技有限责任公司',
            '024沈阳诚亚科技有限责任公司'=>'沈阳诚亚科技有限责任公司',
            '0371河南诚亚智能科技有限责任公司'=>'河南诚亚智能科技有限责任公司',
            '0531山东诚亚科技有限责任公司'=>'山东诚亚科技有限责任公司',
        ];

        if(!empty($report_high_search)){
            $_REQUEST['search_zuzhi'] = $zuzhiArr[$report_high_search[0]['text']];
            $_REQUEST['search_stockname'] = $report_high_search[1]['text'];
            $_REQUEST['search_productname'] = empty($report_high_search[2]['text'])?$_REQUEST['search_productname']:$report_high_search[2]['text'];
            $_REQUEST['search_productno'] = empty($report_high_search[3]['text'])?$_REQUEST['search_productno']:$report_high_search[3]['text'];
            $_REQUEST['search_productsheet'] = empty($report_high_search[4]['text'])?$_REQUEST['search_productsheet']:$report_high_search[4]['text'];
        }

        $list = $this->getList();
        $count = sizeof($list);
        $list1 = [];
        foreach($list as $k=>$v){
            $list1[] = array(
                'title'=>$v['fnumber'],//物料编码
                'field'=>array(
                    '规格型号：'.$v['fpecification'],
                    '可用量（主单位）：'.$v['fbaseavbqty'],
                    '仓库名称：'.$v['stockname'],
                    '库存组织：'.$v['zuzhi'],
                    '物料名称：'.$v['fname'],
                    '库存量（主单位）：'.$v['fbaseqty'],
                    '库存状态：'.$v['fstockstatusid'],
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
                        "value"=>"全部"),
                    array("select"=> "no",
                        "text"=>"000诚亚集团",
                        "value"=>"诚亚集团"),
                    array("select"=> "no",
                        "text"=>"010北京诚亚科技有限责任公司",
                        "value"=>"北京诚亚科技有限责任公司"),
                    array("select"=> "no",
                        "text"=>"022天津诚亚科技有限责任公司",
                        "value"=>"天津诚亚科技有限责任公司"),
                    array("select"=> "no",
                        "text"=>"024沈阳诚亚科技有限责任公司",
                        "value"=>"沈阳诚亚科技有限责任公司"),
                    array("select"=> "no",
                        "text"=>"0371河南诚亚智能科技有限责任公司",
                        "value"=>"河南诚亚智能科技有限责任公司"),
                    array("select"=> "no",
                        "text"=>"0531山东诚亚科技有限责任公司",
                        "value"=>"山东诚亚科技有限责任公司")
                )
            ),
            array(
                'fieldlabel'=>'仓库名称',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_stockname'
            ),
            array(
                'fieldlabel'=>'物料名称',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_productname'
            ),
            array(
                'fieldlabel'=>'物料编码',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_productno'
            ),
            array(
                'fieldlabel'=>'规格型号',
                'fieldtype'=>'1',
                'text'=>'',
                'fieldname'=>'search_productsheet'
            ),
        );
        $res['search_reminds'] = '搜索物料名称、规格型号、物料编码';//模糊搜索
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

    //api查询方法
    public function  selectApiResult($data){
        //$cloudUrl = 'https://cyent.test.ik3cloud.com/K3cloud/HTML5/';//金蝶云星空地址
//        $cloudUrl = 'https://cyent.test.ik3cloud.com/k3cloud/';
        $cloudUrl = 'https://cyent.ik3cloud.com/K3cloud/';
//        $dbname = '1366694459256870912';
        $dbname = '1366687177727023104';
        $user = 'kingdee';
        $pwd = '123qweasd!';
        //登陆参数
        $login_data = array(
            $dbname,//帐套Id
            $user,//用户名
            $pwd,//密码
            2052//语言标识
        );

        //定义记录Cloud服务端返回的Session
		$root_directory = explode('www',globalStatic::$root_directory);
		$cookie_jar = tempnam($root_directory[0].'/tmp','CloudSession');
        //$cookie_jar = tempnam('D:\ldcrm/tmp','CloudSession');
        $post_content = $this->create_postdata($login_data);

        $this->invoke_login($cloudUrl,$post_content,$cookie_jar);
        $post_content = $this->create_postdata($data);
        $result = $this->invoke_select($cloudUrl,$post_content,$cookie_jar);
        $result = json_decode($result);
        return $result;
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
}