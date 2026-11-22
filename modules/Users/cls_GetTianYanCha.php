<?php
class cls_GetTianYanCha
{
    public $TianyanchaObj;
    public $searchtype;
    protected $keywords;
    protected $operationtype;
    private $needgoUpdateAddress = 'no';
    public static function getInstance($open_type,$keywords)
    {
        static $static_tianyanchaobj;
        if(isset($static_tianyanchaobj))
        {
            return $static_tianyanchaobj;
        }
        $static_tianyanchaobj=  new cls_GetTianYanCha($open_type,$keywords);
        return $static_tianyanchaobj;
    }

    public function __construct($open_type,$keywords)
    {
        crm_load_class_file('cls_TianYanCha', 'modules/Users');
        $this->TianyanchaObj =cls_TianYanCha::getInstance($open_type,$keywords);
        $this->setCURLOPT_PROXYPORT();
    }

    public function setCURLOPT_PROXYPORT(){
        global $LINGDANGCURLOPT_PROXYINFO;
        if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'])){
            $this->TianyanchaObj->curlopt_porxy = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXY'];
        }
        if(!empty($LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'])){
            $this->TianyanchaObj->curlopt_porxyport = $LINGDANGCURLOPT_PROXYINFO['CURLOPT_PROXYPORT'];
        }
    }

    public function setKeyWords($keywords)
    {
        $this->keywords=$keywords;
        $this->TianyanchaObj->keywords=$keywords;
    }

    public function setModulename($modulename){
        $this->TianyanchaObj->setModulename($modulename);
    }

    public function setSearchtype($searchtype){
        $this->searchtype = $searchtype;
        $this->TianyanchaObj->searchtype = ($searchtype);
    }
    public function getCode(){
        return $this->TianyanchaObj->code;
    }
    public function getReason(){
        return $this->TianyanchaObj->reason;
    }

    public function setOperationType($operationtype)
    {

        $this->operationtype = $operationtype;
        if($operationtype=='save'||$operationtype=='import')
        {
            $this->TianyanchaObj->setOpen_type('existinfo');

        }
        $this->TianyanchaObj->setOperationType($operationtype);

    }
    public function setNoblackwordsstr($noblackwordsstr)
    {
        $this->TianyanchaObj->setNoblackwordsstr($noblackwordsstr);

    }
    public function getCurlResult(){
        $VersionInfo = getVersionInfo();
        if($VersionInfo['account'] == 'zhongsi'){
            $this->setCertificateinfoarr();
        }
        $res = $this->TianyanchaObj->getCurlResult();
        if($this->TianyanchaObj->needGetAddress == 'yes'){// 是否需要通过接口获取地址信息
            $res = $this->getAddressInfo($res);
            $this->TianyanchaObj->needGetAddress = 'no';
			
            if($this->needgoUpdateAddress == 'yes'&&(empty($this->TianyanchaObj->curlopt_porxy))){// 需要反写更新地址信息到工商数据库
                $this->TianyanchaObj->goUpdateDatabase($res);
            }
        }
        if(!empty($res)){
            //需要过滤参数
            $datetype = array('type','isMicroEnt',"percentileScore");
            foreach($datetype as $tmpindex=>$datatypekey){
                //BUG20240219-17 hzx 20240219 工商信息--参保人数为空的时候应该显示为空，不应显示null
                if((empty($res[$datatypekey]) && $res[$datatypekey] != 0) || $res[$datatypekey] == null || $res[$datatypekey] == 'null' ){
                    $val = '';
                }else{
                    $val = $res[$datatypekey];
                }
                if(!empty($val)){
                    if($datatypekey == 'type'){
                        if($val == 1 || $val == '1'){
                            $val = '个人';
                        }
                        else if($val == 2 || $val == '2'){
                            $val = '公司';
                        }
                    }
                    else if($datatypekey == 'isMicroEnt'){
                        if($val == 0 || $val == '0'){
                            $val = '不是';
                        }
                        else if($val == 1 || $val == '1'){
                            $val = '是';
                        }
                    }
                    else if($datatypekey == 'percentileScore'){
                        if(is_numeric($val)){
                            $val = floor($val/100);
                        }
                    }
                    $res[$datatypekey] = $val;
                }
            }
            if($VersionInfo['account'] == 'zhongsi' && $this->TianyanchaObj->modulename == 'Accounts'){
                foreach($res as $tmpkey=>$tmpvalue){
                    if(strpos($tmpkey,'certificate_startDate')!== false||strpos($tmpkey,'certificate_endDate')!== false){
                        if(strpos($tmpvalue,'年')!== false){
                            $newvalue = str_replace(['年', '月', '日'], ['-', '-', ''], $tmpvalue);;
                            $res[$tmpkey] = $newvalue;
                        }
                    }
                }
            }
            foreach($res as $tmp_datatypekey => &$tmp_value){
                if($tmp_value == null){
                    $tmp_value = '';
                }
            }
            if(array_key_exists('poi_address',$res)){
                foreach($res['poi_address'] as $tmp_datatypekey => &$tmp_value){
                    if($tmp_value == null){
                        $tmp_value = '';
                    }
                }
            }
            else if($this->operationtype == 'businesssearchbtn'){
                $res['poi_address'] = array(
                    'address' => '',
                    'state' => '',
                    'city' => '',	//城市
                    'district' => '',	//区域
                    'point' => ',',
                    'country' => ''
                );
            }
        }
        return $res;
    }

    public function getaddcertificatedata(){
        $this->setCertificateinfoarr();
        $res = $this->TianyanchaObj->addcertificatedata_byarr([]);
        foreach($res as $tmpkey=>$tmpvalue){
            if(strpos($tmpkey,'certificate_startDate')!== false||strpos($tmpkey,'certificate_endDate')!== false){
                if(strpos($tmpvalue,'年')!== false){
                    $newvalue = str_replace(['年', '月', '日'], ['-', '-', ''], $tmpvalue);;
                    $res[$tmpkey] = $newvalue;
                }
            }
        }
        return $res;
    }

    public function setCertificateinfoarr(){

        //证书编号
        $getCertificateinfoarr['certificate_certNo'] =['许可证号','证书编号','自我声明编号','注册证编号','行政许可决定文书号','证书编码','资质证书编号','生产许可证号'];
        //证书状态
        $getCertificateinfoarr['certificate_status'] =['证书状态','自我声明状态','当前状态','状态'];
        //颁证日期
        $getCertificateinfoarr['certificate_startDate'] =['颁证日期','发证日期','有效期自','自我声明时间','有效期起','批准日期'];
        //证书到期日期
        $getCertificateinfoarr['certificate_endDate'] =['证书到期日期','截止日期','有效期至','许可截止日期','到期日期','证书有效期','许可证有效日期止','有效期截止'];
        //认证项目
        $getCertificateinfoarr['certificate_certificateName'] =['认证项目','资质等级','管理类别','主体业态','产品类别','许可文件名称','申请事项','类别名称','许可内容','产品类别','食品类别','项目名称','业务领域','软件版本','资质类别'];
        //认证依据
        $getCertificateinfoarr['certificate_certbasis'] =['认证依据','实施规则','适用范围/预期用途','许可证书名称','证书级别','申请类别','认证依据的标准和技术要求','认证标准和技术要求','软件类型','证书类型','证书类别'];
        //认证覆盖的业务范围
        $getCertificateinfoarr['certificate_certBusinessscope'] =['认证覆盖的业务范围','业务领域','结构及组成/主要组成成分','明细、产品名称及单元（主）','认证范围','产品名称及单元','许可类别','经营项目','证书级别','软件名称','资质等级','许可范围'];
        //证书使用的认可标识
        $getCertificateinfoarr['certificate_certrecognitionmark'] =['证书使用的认可标识'];
        //获证组织-本证书体系覆盖人数
        $getCertificateinfoarr['certificate_certcoveredpeople'] =['获证组织-本证书体系覆盖人数','认证相关员工数量'];
        //发证机构-机构名称
        $getCertificateinfoarr['certificate_certInstitutionName'] =['发证机构-机构名称','发证机关','审批部门','许可机关','发证机构','评估机构'];
        $this->TianyanchaObj->Certificateinfoarr = $getCertificateinfoarr;
    }

    protected function getAddressInfo($res){
        //zkt 20220705 BUG0053557.天眼查接口慢以及出错 eg:中国中煤集团有限公司 $res['regLocation']为空时会出错
        $res['poi_address'] = array(
            'address' => $res['regLocation'],
            'state' => $res['province'],
            'city' => $res['city'],	//城市
            'district' => $res['district'],	//区域
            'point' =>  $res['jingdu'].','.$res['weidu'],
            'country' =>'中国'
        );
        crm_load_class_file('cls_Tencent_Map', 'include/utils');
        //20220610 改为使用腾讯地图接口
        if(!empty($res['regLocation'])&&(  $res['province']==''||$res['city']==''||$res['district']==''
            ||trim($res['poi_address']['point'],',')=='')){
            
            $tmp_type = 'regLocation';
                
        }
        else if(empty($res['regLocation']) && !empty($res['name'])){// 没有详细地址，用企业名称调接口

            $tmp_type = 'corpname';
        }
        $res = $this->getTencentPoint($res,$tmp_type);
		
        //zkt 20220615 BUG0052826   order自用系统工商查询当腾讯接口识别不到地址信息时，国家省份区域为空 
        if((empty($res['poi_address']['state']) || empty($res['poi_address']['city']) || empty($res['poi_address']['district']))){

            $res = $this->getTencentAddress($res,$tmp_type);
			
        }
		
        return $res;
    }
    protected function getTencentPoint($res,$type='regLocation'){
        // dump($res['regLocation']);
        $cls_Tencent_Map = new cls_Tencent_Map();
        if($type == 'corpname'){
            $keyvalue = $res['name'];// 企业名称
        }else{
            $keyvalue = $res['regLocation'];
        }
        $address_info = $cls_Tencent_Map->getPoint($keyvalue);
		
        if(!empty($address_info['province']) && !empty($address_info['city'])){// 省市都不为空
            $res['poi_address']['state'] = $address_info['province'];
            $res['poi_address']['city'] = $address_info['city'];	// 城市
            $res['poi_address']['district'] = $address_info['district'];	// 区域
			if(!empty(trim($address_info['lat'].','.$address_info['lng'],','))){
				$res['poi_address']['point'] = $address_info['lat'].','.$address_info['lng'];
			}
            if(!empty($res['poi_address']['state'])&&!empty($res['poi_address']['city'])&&!empty($res['poi_address']['district'])&&!empty(trim($res['poi_address']['point'],','))){
				$this->needgoUpdateAddress = 'yes';
			}
        }
        // dump($res);
        return $res;
    }
    // type为区分调接口用的详细地址还是企业名称
    protected function getTencentAddress($res,$type='regLocation'){
        $cls_Tencent_Map = new cls_Tencent_Map();
        if($type == 'corpname'){
            $keyvalue = $res['name'];// 企业名称
        }else{
            $keyvalue = $res['regLocation'];
        }
        $address_info = $cls_Tencent_Map->getAddress($keyvalue);
        
        if(!empty($address_info)){
            $compare_arr = [];
            foreach($address_info as $arr){
                if($type == 'corpname'){
                    $compare_arr[] = $arr[0];// 企业名称
                }else{
                    $compare_arr[] = $arr[1];
                }
            }
			
            // 获取到相似度最高的一个
            $target_index = $this->findMostSimilar($keyvalue, $compare_arr);
            $target_info = $address_info[$target_index];
			
            if(!empty($target_info[5]) && !empty($target_info[6])){// 省市都不为空
                $res['poi_address']['state'] = $target_info[5];
                $res['poi_address']['city'] = $target_info[6];	// 城市
                $res['poi_address']['district'] = $target_info[7];	// 区域
				$tmppoint = trim($target_info[2].','.$target_info[3],',');// 经纬度
                if(!empty($tmppoint)){
					$res['poi_address']['point'] = $tmppoint;
				}
                if(!empty($res['poi_address']['state'])&&!empty($res['poi_address']['city'])&&!empty($res['poi_address']['district'])&&!empty(trim($res['poi_address']['point'],','))){
					$this->needgoUpdateAddress = 'yes';
				}
            }else{
                if($type == 'regLocation'){
                    $res = self::getTencentAddress($res,'corpname');
                }
            }
        }else{
            // 通过详细地址获取不到直接再用企业名称调
            if($type == 'regLocation'){
                $res = self::getTencentAddress($res,'corpname');
            }
        }
        return $res;
    }
    // 找到相似度最高的字符串,返回index
    public function findMostSimilar($inputString, $stringArray) {
        $maxSimilarity = 0;
        $mostSimilarIndex = 0;
        $mostSimilarString = "";
    
        foreach ($stringArray as $index => $string) {
            similar_text($inputString, $string, $percent);
            if ($percent > $maxSimilarity) {
                $maxSimilarity = $percent;
                $mostSimilarString = $string;
                $mostSimilarIndex = $index;
            }
        }
    
        return $mostSimilarIndex;
    }
    
}
?>