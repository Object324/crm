<?php
class cls_soukebao
{
    private static $_instance;//单例
    public $operationtype;
    public $modulename ;
    private $api_url = "https://data.51mis.cn/ldaccount3/index.php";
    //private $api_url = "127.0.0.1:85/ldgongshang/index.php";
    function __construct(){

    }
    public static function getInstance() {//单例
        static  $static_instance;
        if(isset($static_instance))
        {
            return $static_instance;
        }
        $static_instance=new cls_soukebao();
        return $static_instance;
    }
    //设置operationtype，用于区分操作，searchtext：搜客宝界面的搜索
    public function setoperationtype($operationtype)
    {
        $this->operationtype = $operationtype;
    }
    //
    public function setcorpids($corpids)
    {
        $this->corpids = $corpids;
    }
    //
    public function setsearchtext($searchtext)
    {
        $this->searchtext = $searchtext;
        crm_load_class_file('phpanalysis.class','modules/Users/PHPAnalysis');
        $pa = new PhpAnalysis('utf-8','utf-8',false);
        $analysis_tags = $pa->GetTianYanSearchByKeywords($searchtext);
        $analysis_tags_arr = explode(",", $analysis_tags);
        $noblackwordsstr = "";
        foreach($analysis_tags_arr as $index => $analysis_tagstr)
        {
            global $adb;
            $sql="SELECT * FROM ld_business_wordslist WHERE wordkey=? AND wordtype='blackkey'";
            $result=$adb->pquery($sql,array($analysis_tagstr));
            $rows = $adb->num_rows($result);
            if($rows<=0&&mb_strlen($analysis_tagstr)>=2){
                //zkt 20240411 BUG20240409-10  	搜可宝中输入（陕西泰坦实业集团有限公司）搜索不到信息，但是输入（陕西泰坦实业）可以搜索到
                $noblackwordsstr = $analysis_tagstr;
                break;
            }
        }
        $this->searchtextnoblack = $noblackwordsstr;
    }
    //
    public function setsearchcolumn($searchcolumn)
    {
        $this->searchcolumn = $searchcolumn;
    }
    //
    public function setcurrentpage($currentpage)
    {
        $this->currentpage = $currentpage;
    }
    //
    public function setpagesize($pagesize)
    {
        $this->pagesize = $pagesize;
    }
    //
    public function setsearchadvance($jsonsearchadvance)
    {
        $this->searchadvance = $jsonsearchadvance;
    }
    //
    public function setmapinfo($jsonmapinfo)
    {
        $this->mapinfo = $jsonmapinfo;
    }
    public function setmodulename($modulename)
    {
        $this->modulename = $modulename;
    }

    /*
     * 获取级联的搜索条件
	 *XUQIU20240423-02 搜客宝：搜索条件，级联
     * */
    public function getDependencySearchCondition($columnname,$sercharr){
        $condition_arr = [];

        foreach ($sercharr as $tmpindex=>$tmpsearchinfo){
            $tmpvalue = $tmpsearchinfo['value'];
            $tmpchildren = $tmpsearchinfo['children'];
            $tmpselected = $tmpsearchinfo['selected'];//是否选中
            $tmpindeterminate = $tmpsearchinfo['indeterminate'];//下级是否部分勾选
            $tmpvalue_arr = [];
            if ($tmpselected) {
                $tmpvalue_arr = [$columnname=>$tmpvalue];

            }
            elseif ($tmpindeterminate){
                $tmpvalue_arr = [$columnname=>$tmpvalue];
                $tmpvalue_arr = $this->collectSelected($tmpchildren,$tmpvalue_arr);

            }
            if(!empty($tmpvalue_arr)){
                $condition_arr[] = $tmpvalue_arr;  // 你可以根据需要调整收集的数据
            }

        }
        return $condition_arr;
    }
    // 递归函数来收集选中的项目
    public function collectSelected($items,$selectedItems) {
        //$selectedItems = [];
        foreach ($items as $item) {
            $columnname = $item['columnname'];
            if($item['value'] == 'all'){
                continue;
            }
            if ($item['selected']||$item['indeterminate']) {
                $selectedItems[$columnname] = $item['value'];  // 你可以根据需要调整收集的数据
            }
            if ($item['indeterminate']&&isset($item['children']) && count($item['children']) > 0) {
                $selectedItems = $this->collectSelected($item['children'],$selectedItems);
            }
        }
        return $selectedItems;
    }

    public function getImportedcorpidarr(){
        global $adb;
        $sql  = "select GROUP_CONCAT(corpid SEPARATOR ',') as corpids from ld_crmlog_import_soukebao;";
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $corpid_arr = array();
        if($num>0)
        {
            $corpids = $adb->query_result($result,0,'corpids');
            $corpid_arr = explode(',',$corpids);
        }
        return $corpid_arr;
    }
    /*
     * 过滤已导入数据返回未导入的数组
     * */
    public function getNoImportedcorpidarr($corpidarr){
        global $adb;
        $sql  = "select GROUP_CONCAT(corpid SEPARATOR ',') as corpids from ld_crmlog_import_soukebao where corpid in ('".implode("','",$corpidarr)."');";
        $result = $adb->pquery($sql,array());
        $num = $adb->num_rows($result);
        $corpid_arr = array();
        if($num>0)
        {
            $corpids = $adb->query_result($result,0,'corpids');
            if(is_null($corpids))
            {
                return [];
            }
            $corpid_arr = explode(',',$corpids);
            $corpidarr = array_diff($corpidarr, $corpid_arr);
        }
        return $corpidarr;
    }
    /*
     * 记录导入的数据
     * */
    public function setImportdatalog($tabid,$crmid,$corpid){
        global $adb;
        $sql  = "insert into ld_crmlog_import_soukebao(`tabid`,`crmid`,`corpid`) select ?,?,? from dual where not exists (select 1 from ld_crmlog_import_soukebao where corpid = ?)";
        $adb->pquery($sql,array($tabid,$crmid,$corpid,$corpid));
    }

    public function getlistByoperationtype(){
        global $current_user;
        $data = $this->getData();
        $resultdata = $data['result'];
        if($data['error_code']=='-1')
        {
            ConvertTojsonString(-1,[],$data['reason']);
        }
        if($this->operationtype == 'searchtext'||$this->operationtype == 'searchcondition'){
            $tmplistdata = $resultdata['list'];
            $newdata = [];
            $showcontentarr = $resultdata['showcontentarr']??[['legalPersonName'=>'法定代表人','regCapital'=>'注册资本','estiblishTime'=>"成立日期"],['regLocation'=>"地址"],['businessScope'=>"经营范围"]];
            $contactinfoarr = $resultdata['contactinfoarr']??array('phoneNumber'=>"电话",'email'=>"邮箱",'websiteList'=>"网址");

            $regstatusvaluecolorarr = $resultdata['regstatusvaluecolorarr']??[
                '个体转企业'=>array( 'color'=>'64, 158, 255'),
                '开业'=>array( 'color'=>'103, 194, 58'),
                '吊销'=>array( 'color'=>'230, 162, 60'),
                '注销'=>array( 'color'=>'230, 162, 60'),
                '停业'=>array( 'color'=>'144, 147, 153'),
                '迁出'=>array( 'color'=>'144, 147, 153'),
                '撤销'=>array( 'color'=>'144, 147, 153'),
                '解散'=>array( 'color'=>'144, 147, 153'),
                '在业'=>array( 'color'=>'103, 194, 58')
            ];
            $haveimportcorpid_arr = $this->getImportedcorpidarr();
            $importmodule = getUsersettingByLabel('ldsoukebao','1','soukebaoimportmodule')?:'Accounts';
            foreach ($tmplistdata as $tmpindex=>$tmpdatainfo)
            {
                $tmpdata = [];
                $tmpdata['id'] = $tmpdatainfo['corpid'];
                $otherinfo = array();
                foreach ($showcontentarr as $showcontentlinearr){
                    $tmparr = [];
                    if(count($showcontentlinearr) == 1){
                        $tianyanchaname = key($showcontentlinearr);
                        $tmparr = array('label'=>$showcontentlinearr[$tianyanchaname],'text'=>$tmpdatainfo[$tianyanchaname]);
                    }
                    else{
                        foreach ($showcontentlinearr as $tianyanchaname=>$tranlabel){
                            $tmparr[] = array('label'=>$tranlabel,'text'=>$tmpdatainfo[$tianyanchaname]);
                        }
                    }
                    $otherinfo[] = $tmparr;
                }
                $namelabel = $tmpdatainfo['namelabel'];

                $tmpdata['data'] = array('name'=>$tmpdatainfo['name'],'namelabel'=>$namelabel,'otherinfo'=>$otherinfo);
                if(!empty($tmpdatainfo['regStatus'])){
                    $regstatusinfo = [];
                    $tmpregStatus = $tmpdatainfo['regStatus'];
                    $tmpcolor = '';
                    if(array_key_exists($tmpregStatus,$regstatusvaluecolorarr)){
                        $tmpcolor = $regstatusvaluecolorarr[$tmpregStatus]['color'];
                    }
                    $regstatusinfo = array('text'=>$tmpdatainfo['regStatus'],'color'=>$tmpcolor);
                    $tmpdata['data']['regstatus'] = $regstatusinfo;
                }
                $contactinfo = array();
                foreach ($contactinfoarr as $tianyanchaname=>$tranlabel){
                    $contactinfo[] = array('label'=>$tranlabel,'text'=>$tmpdatainfo[$tianyanchaname]);
                }
                $tmpdata['contactinfo'] = $contactinfo;

                $tmpdata['operation'] = [['label'=>'导入','disabled'=>false]];
                if(in_array($tmpdatainfo['corpid'],$haveimportcorpid_arr)){
                    $tmpdata['operation'] = [['label'=>'已导入','disabled'=>true]];
                }
                $newdata [] =$tmpdata;
            }
            $resultdata['list'] = $newdata;
            $resultdata['importmodulename'] = getTranstab($importmodule);
        }
        elseif($this->operationtype == 'conditionshowdata'){
            $newdata = [];
            $soukebaocondition = getUsersettingByLabel($this->modulename,$current_user->id,'soukebaocondition');

            $dependencydatacondition = [];
            if(!empty($soukebaocondition)){
                $soukebaocondition = ldcrm_json_decode($soukebaocondition);
                //级联数组默认值赋值
                if(array_key_exists('dependency',$soukebaocondition)){
                    $dependencydatacondition = $soukebaocondition['dependency'];
                }
            }
            if(array_key_exists('searchcolumnarr',$resultdata))
            {
                foreach ($resultdata['searchcolumnarr'] as $tmpcolumnname=>$tmplabel)
                {
                    $newdata['searchcolumnoption'][] = array('value'=>$tmpcolumnname,'label'=>$tmplabel);
                }
            }
            $dependencydata = [];
            if(array_key_exists('dependencydata',$resultdata))
            {
                $dependencydata = $resultdata['dependencydata'];
                $newdata['regionoptions'] = $dependencydata;
            }
            if(array_key_exists('conditiondata',$resultdata))
            {
                if(array_key_exists('basic',$resultdata['conditiondata']))
                {
                    if(!empty($resultdata['conditiondata']['basic'])){
                        $newdata['FilterBaseData'] = ['value'=>'查找条件','label'=>'查找条件','filtergroup'=>[]];
                    }
                    foreach ($resultdata['conditiondata']['basic'] as $tmpcolumnname=>$tmpinfo)
                    {
                        $tmppicklistarr = [];
                        foreach($tmpinfo as $tmpindex=>$tmpvalueinfo)
                        {
                            if(empty($tmppicklistarr)){
                                $tmppicklistarr = ['value'=>$tmpcolumnname,'label'=>$tmpvalueinfo['maplabel'],'checklist'=>[]];
                            }
                            $tmpselected = false;
                            if(array_key_exists($tmpcolumnname,$soukebaocondition)&&in_array($tmpvalueinfo['picklistid'],$soukebaocondition[$tmpcolumnname])){
                                $tmpselected = true;
                            }
                            $tmpchecklist = array('value'=>$tmpvalueinfo['picklistid'],'label'=>$tmpvalueinfo['picklistvalue'],'display'=>$tmpvalueinfo['showpage'],'selected'=>$tmpselected);


                            if(!empty($tmpvalueinfo['dependencyfield'])&&$tmpvalueinfo['dependencyfield']=='yes'){
                                $tmppicklistarr['dependencyfield'] = $tmpvalueinfo['dependencyfield'];
                                if($tmpcolumnname == 'province')
                                $tmppicklistarr['dependencyfieldlabel'] = '更多区域';
                                //是级联字段时控制赋值children
                                if(is_array($dependencydata)&&array_key_exists($tmpcolumnname,$dependencydata)){
                                    $tmpchecklist['indeterminate'] = false;
                                    $tmpchecklist['children'] = $dependencydata[$tmpcolumnname][$tmpindex]['children'];
                                }
                            }
                            $tmppicklistarr['checklist'][] =$tmpchecklist;

                        }
                        if(is_array($dependencydatacondition)&&array_key_exists($tmpcolumnname,$dependencydatacondition)){
                            $tmpdependencycondition = $this->transformdependencyData($dependencydatacondition[$tmpcolumnname]);
                            $this->applySelection($tmppicklistarr['checklist'],$tmpdependencycondition);
                        }
                        $newdata['FilterBaseData']['filtergroup'][] = $tmppicklistarr;
                    }
                }
                if(array_key_exists('advance',$resultdata['conditiondata']))
                {
                    if(!empty($resultdata['conditiondata']['advance'])){
                        $newdata['FilterAdvanceData'] = ['value'=>'更多筛选','label'=>'更多筛选','filtergroup'=>[]];
                    }
                    foreach ($resultdata['conditiondata']['advance'] as $tmpcolumnname=>$tmpinfo)
                    {
                        $tmppicklistarr = [];
                        foreach($tmpinfo as $tmpindex=>$tmpvalueinfo)
                        {
                            if(empty($tmppicklistarr)){
                                $tmppicklistarr = ['value'=>$tmpcolumnname,'label'=>$tmpvalueinfo['maplabel'],'checklist'=>[]];
                            }
                            $tmpselected = false;
                            if(array_key_exists($tmpcolumnname,$soukebaocondition)&&in_array($tmpvalueinfo['picklistid'],$soukebaocondition[$tmpcolumnname])){
                                $tmpselected = true;
                            }
                            $tmppicklistarr['checklist'][] = array('value'=>$tmpvalueinfo['picklistid'],'label'=>$tmpvalueinfo['picklistvalue'],'selected'=>$tmpselected);

                        }
                        $newdata['FilterAdvanceData']['filtergroup'][] = $tmppicklistarr;
                    }
                }
            }
            $resultdata = $newdata;
        }
        elseif($this->operationtype == 'getdatalistbycorpids'){
            $resultdata = $resultdata['list'];
        }
        return $resultdata;
    }
    function transformdependencyData($input) {
        $result = [];
        foreach ($input as $item) {
            // Start building from the outermost element
            $nested = [];
            foreach (array_reverse($item) as $key => $value) {
                if (empty($nested)) {
                    $nested = [$value];
                } else {
                    $nested = [$value, $nested];
                }
            }
            $result[] = $nested;
        }
        return $result;
    }
    function applySelection(&$cascadingData, $selectedArray) {
        foreach ($selectedArray as $selectedInfo) {
            $selected = false;
            $indeterminate = false;
            $nodeId = $selectedInfo[0];  // 该节点的ID
            $hasChildren = count($selectedInfo) > 1;

            // 查找和更新对应节点
            foreach ($cascadingData as &$node) {
                if ($node['value'] == $nodeId) {
                    if ($hasChildren) {
                        $indeterminate = true;
                        // 递归调用更新子节点
                        $this->applySelection($node['children'], [$selectedInfo[1]]);
                        // 检查所有子节点确定是否全部选中
                        $allSelected = true;
                        foreach ($node['children'] as $child) {
                            if (!$child['selected']) {
                                $allSelected = false;
                                break;
                            }
                        }
                        $node['selected'] = $allSelected;
                        $node['indeterminate'] = !$allSelected;
                    } else {
                        $node['selected'] = true;  // 没有子节点信息，标记为选中
                    }
                    break;  // 匹配到节点后不需要继续搜索
                }
            }
        }

    }


    function sendCurlPost($uri,$data){
        $ch = curl_init ();
        curl_setopt ( $ch, CURLOPT_URL, $uri );
        curl_setopt ( $ch, CURLOPT_POST, 1 );
        curl_setopt ( $ch, CURLOPT_HEADER, 0 );
        curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 3);
        curl_setopt ( $ch, CURLOPT_RETURNTRANSFER, 1 );
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
        curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, FALSE);
        curl_setopt ( $ch, CURLOPT_POSTFIELDS, http_build_query($data));

        $output = curl_exec ( $ch );

        curl_close ($ch);
        return $output;
    }

    private function getData(){
        $data_arr=[];
        $url = $this->getUrl($data_arr);
        if(!empty($url)){
           /* $ch = curl_init();
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "GET");
            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); //不验证证书
            curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, false); //不验证证书
            curl_setopt($ch, CURLOPT_TIMEOUT, 0);
            curl_setopt($ch, CURLOPT_HEADER, 0);
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
            $curl_data = curl_exec($ch);
            curl_close($ch);*/
            $curl_data=$this->sendCurlPost($url,$data_arr);


            $data = json_decode($curl_data,true);
        }
        return $data;
    }

    //根据类型匹配url
    private function getUrl(&$data_arr){
        global $current_user;
        $url = $this->api_url;
        $url .= "?";
        global $dbconfig;
        switch($this->operationtype){
            case 'getdatalistbycorpids':
                $url .= 'corpids='.$this->corpids;
                $url .= '&operationtype='.$this->operationtype;
                $url .= '&ld_file=getDataList';
                break;
            case 'searchtext':
                $url .= 'searchtext='.$this->searchtext;
                $url .= '&searchtextnoblack='.$this->searchtextnoblack;
                $url .= '&searchcolumn='.$this->searchcolumn;
                $url .= '&operationtype='.$this->operationtype;
                $url .= '&ld_file=getDataList';
                break;
            case 'searchcondition':
                $url .= 'searchtext='.$this->searchtext;
                $url .= '&searchtextnoblack='.$this->searchtextnoblack;
                $url .= '&searchcolumn='.$this->searchcolumn;
                $url .= '&operationtype='.$this->operationtype;
                $url .= '&thiscurrentpage='.$this->currentpage;
                $url .= '&pagesize='.$this->pagesize;
                $url .= '&searchadvance='.$this->searchadvance;
                if(isset($this->mapinfo)&&!empty($this->mapinfo)){
                    $url .= '&mapinfo='.$this->mapinfo;
                }
                $url .= '&ld_file=getDataList';
                break;
            case 'conditionshowdata':
                $url .= 'searchtext='.$this->searchtext;
                $url .= '&searchcolumn='.$this->searchcolumn;
                $url .= '&operationtype='.$this->operationtype;
                $url .= '&ld_file=getShowData';
                break;
            default:
                $url = '';
        }

        $regopobj=RegOp::getInstance();
        $regrecordid=0;
        $companyname='';
        $crmpath='';
        $crmhost='';
        $sassurl="";
        $tokenkey='';

        if($regopobj instanceof RegOp){
            $regfrom = 'local';
            $serialnum=$regopobj->GetSerialNum();
            $regrecordid=$regopobj->GetRegRecordId();
            $companyname=$regopobj->softCompany();
            $token=getSoukeBaoToken($serialnum,$tokenkey);
        }
        else  if($regopobj instanceof Reg_weixinInfo)
        {
            $regfrom = 'kehu001';
            $serialnum=$regopobj->getPreNo();
            $token=getSoukeBaoToken($serialnum,$tokenkey);

        }
        else
        {
            $regfrom='sasscrm';
            $serialnum=$regopobj->GetSerialNum();
            $token=getSoukeBaoToken($serialnum,$tokenkey);
            $crmpath=$regopobj->getEncryptCrmPath($serialnum.$tokenkey);
            $crmhost=$regopobj->getHttpHost();
            $sassurl=$regopobj->getServerUrl($serialnum.$tokenkey);

        }
        $tmptoken='';
        $databasename=getSoukeBaoEncrypt($dbconfig['db_name'],$serialnum.$tokenkey);

      //  $tokenkey=strtotime(date("Y-m-d H:i:s")).rand(100000,10000000);

        $data_arr['token']=$token;
        $data_arr['crmpath']=str_replace("+","!####!",$crmpath); // ($crmpath);
        $data_arr['databasename']= str_replace("+","!####!",$data_arr);
        $data_arr['sassurl']= str_replace("+","!####!",$sassurl); //$sassurl;

        $url.="&serialnum=".$serialnum.'&tokenkey='.rawurldecode($tokenkey).'&ldregfrom='.$regfrom;
        $url.='&ldregcompanyname='.urlencode($companyname);
        $url.='&regrecordid='.$regrecordid;
        $url.='&httphost='.urlencode($crmhost);
      //  $url.='&sassurl='.urlencode($sassurl);
        $url.='&userid='.$current_user->id;
        //echo $url;
       // dump($data_arr);


        return $url;
    }
}

?>