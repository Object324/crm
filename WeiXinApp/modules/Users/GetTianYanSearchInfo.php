<?php
global $adb;
if(!empty($_REQUEST['keywords'])){
    $keywords = $_REQUEST['keywords'];
	$open_type = $_REQUEST['open_type'];
    crm_load_class_file('cls_BusinessInformation', 'modules/Users');
    if($open_type == 'list'){
        $res = [];
        $state = 'no';
        $businessinformationobj = cls_BusinessInformation::getInstance($_REQUEST['frommodule']);
        //分词，并对分词结果进行判断，是否要前往进行工商查询
        crm_load_class_file('phpanalysis.class','modules/Users/PHPAnalysis');
        $pa = new PhpAnalysis('utf-8','utf-8',false);
        $analysis_tags = $pa->GetTianYanSearchByKeywords($keywords);
        $analysis_tags_arr = explode(",", $analysis_tags);
        $permit = 'no';
        $analysiis_words_len = 0;
        if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            foreach($analysis_tags_arr as $index => $analysis_tagstr)
            {
                $sql="SELECT * FROM ld_business_wordslist WHERE wordkey=? AND wordtype='blackkey'";
                $result=$adb->pquery($sql,array($analysis_tagstr));
                $rows = $adb->num_rows($result);
                if($rows<=0){
                    $permit='yes';
                    if(mb_strlen($analysis_tagstr)>=2){
                        $noblackwordsstr = $analysis_tagstr;
                        break;
                    }
                }
                $analysiis_words_len +=strlen($analysis_tagstr);
            }
            if($businessinformationobj->getBusinessfuzzyquerytosearchnum()>mb_strlen($keywords)){
                $permit = 'no';
            }
        }
        if($permit=='no'){
            $state = 'no';
        }else {
            crm_load_class_file('cls_GetTianYanCha', 'modules/Users');
            $cls_GetTianYanCha = new cls_GetTianYanCha($open_type, $keywords);
            $cls_GetTianYanCha->setSearchtype('advance');
            $cls_GetTianYanCha->setOperationType("list");
            $cls_GetTianYanCha->setNoblackwordsstr($noblackwordsstr);
            if(isset($_REQUEST['frommodule'])){
                $cls_GetTianYanCha->setModulename($_REQUEST['frommodule']);
            }
            $result = $cls_GetTianYanCha->getCurlResult();
            $code = $cls_GetTianYanCha->getCode();
            if(!empty($result)){
                $res = $result;
                $state = 'ok';
            }
        }
        $data['state'] = $state;
        $data['code'] = $code;
        $data['listData'] = $res;
        
        //duan 20221020 移动端增加翻译
        $label_arr=array(
            'BUSINESSINFORMATION',//工商信息
            'LEGALPERSON',//法人
            'REGSTATUS',//经营状态
            'nodata',//没有数据
            'CANCEL',//取消
            'PLEASEENTERINFORMATION',//请输入信息
            'LBL_PLEASE_SELECT',//请选择
        );
        $fixedlabel_arr = TransFieldlabel($label_arr,'no');
        $source_platform = $_REQUEST['source_platform'];
        $fixedlabel_arr['LEGALPERSON'] .= ': ';
        $fixedlabel_arr['REGSTATUS'] .= ': ';
        $data['arrFixedLabel']=$fixedlabel_arr;
        
        ConvertTojsonString(1, $data, 'success');
    }elseif ($open_type == 'info') {
        crm_load_class_file('cls_GetTianYanCha', 'modules/Users');
        $cls_GetTianYanCha = new cls_GetTianYanCha($open_type, $keywords);
        if(isset($_REQUEST['frommodule'])){
            $cls_GetTianYanCha->setModulename($_REQUEST['frommodule']);
    	}
      
    
        $cls_GetTianYanCha->setOperationType("mobilebusinesssearchbtn");
        $businessinformationobj = cls_BusinessInformation::getInstance($_REQUEST['frommodule']);
        $businessinformationobj = cls_BusinessInformation::getInstance($_REQUEST['frommodule']);
        if(!$businessinformationobj->IsEnableBusiness()){
            ConvertTojsonString(-1,array(),getFixedLabel('BUSINESSQUERYPARAMETERSNOTENABLED'));
        }
      
        $result = $cls_GetTianYanCha->getCurlResult();
        $code = $cls_GetTianYanCha->getCode();
        $res = '';
        $state = 'no';
        if (!empty($result)) {
            $res = $result;
            $state = 'ok';
            //注册地址的定位信息
            /*$poi_address = array();
            if(!empty($res['regLocation'])){
                crm_load_class_file('cls_Tencent_Map', 'include/utils');
                $cls_Tencent_Map = new cls_Tencent_Map();

                $address_info = $cls_Tencent_Map->getAddress($res['regLocation']);
                foreach($address_info as $arr){
                    $poi_address = array(
                        'address' => $arr[1],
                        'state' => $arr[5],
                        'city' => $arr[6],	//城市
                        'district' => $arr[7],	//区域
                        'point' => $arr[2].','.$arr[3],
                        'country' => '中国'
                    );
                }
            }*/
            $poi_address = $result['poi_address'];
            $data['poi_address'] = $poi_address;
            //工商查询按钮，返回查询结果
            if (isset($_REQUEST['frommodule'])) {
                $poiaddress_arr = array('address', 'state', 'city', 'district', 'point', 'country');
                $frommodule = $_REQUEST['frommodule'];
                $tabid = getTabid($frommodule);
                $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
                $backfillfields_arr = $businessinformationobj->getBackFillfields();
                //工商信息结果界面可回填字段前打钩
                $list = array();//fieldname为空不回填；display='no'不显示；
                foreach ($backfillfields_arr as $key => $backfillinfo) {
                    $label = $backfillinfo['label'];
                    $tianyanchaname = $backfillinfo['tianyanchaname'];
                    $trancolumnname = $backfillinfo['trancolumnname'];
                    $display = 'yes';
                    if ($trancolumnname == 'null') {
                        $trancolumnname = '';
                    }
                    if (in_array($tianyanchaname, $poiaddress_arr)) {
                        $display = 'no';
                        $value = $poi_address[$tianyanchaname];
                    } else {
                        $value = $result[$tianyanchaname];
                    }
                    $list[] = array('label' => $label, 'tianyanchaname' => $tianyanchaname, 'fieldname' => $trancolumnname, 'fieldvalue' => $value, 'display' => $display);
                }
                //非可设置回填工商查询结果，需额外添加
                //公司名称
                //            $companyname_arr = array('label'=>getFixedLabel('COMPANYNAME'),'tianyanchaname'=>'name','fieldname'=>'','fieldvalue'=>$result['name'],'display'=>'yes');
                //            array_splice($list,0,0,array($companyname_arr));
                //注册号
                $regNumber_arr = array('label' => getFixedLabel('regNumber'), 'tianyanchaname' => 'regNumber', 'fieldname' => '', 'fieldvalue' => $result['regNumber'], 'display' => 'yes');
                array_splice($list, 5, 0, array($regNumber_arr));
                //登记机关
                $regInstitute_arr = array('label' => getFixedLabel('regInstitute'), 'tianyanchaname' => 'regInstitute', 'fieldname' => '', 'fieldvalue' => $result['regInstitute'], 'display' => 'yes');
                array_splice($list, 8, 0, array($regInstitute_arr));
                $data['list'] = $list;
            }
        }else{
            $VersionInfo = getVersionInfo();
            if($VersionInfo['account'] == 'taikang'&& $_REQUEST['frommodule'] == 'Vendors'){
                $data['tkmsg'] = getFixedLabel('ADMINISTRATORCREATEVENDORS');
            }
        }
        if ($open_type == 'info') {
            $data['title'] = getFixedLabel('business') . getFixedLabel('INFORMATION');
        }
        $data['state'] = $state;
        $data['code'] = $code;
        $data['entries'] = $res;
        //duan 20221020 移动端增加翻译
        $label_arr=array(
            'COMPANYNAME',//公司名称
            'companyOrgType',//企业类型
            'regLocation',//注册地址
            'regCapital',//注册资本
            'creditCode',//纳税人识别号
            'regNumber',//注册号
            'estiblishTime',//注册时间
            'regInstitute',//登记机关
            'legalPersonName',//法定代表人
            'Industry',//行业
            'businessScope',//经营范围
            'TOTIME',//营业期限
            'nodata',//没有数据
            'CANCEL',//取消
            'Backfill',//回填
        );
        $fixedlabel_arr=TransFieldlabel($label_arr,'no');
        // 该客户工商信息不存在！
        $fixedlabel_arr['nodata'] = getFixedLabel('thecustomerbusiness');
        $data['arrFixedLabel']=$fixedlabel_arr;

        
        ConvertTojsonString(1, $data, 'success');
    }
}
?>