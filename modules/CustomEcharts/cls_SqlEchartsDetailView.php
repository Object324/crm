<?php
class cls_SqlEchartsDetailView
{
    public $CustomEchartsActionsObj;
    public $report_id;
    public $smarty;
    public $params;
    public function __construct($params)
    {
        $this->params = $params;//前段传过来的所有参数
        $this->smarty = new lingdangCRM_Smarty();
        include_once globalStatic::$root_directory . 'modules/CustomEcharts/CustomEchartsActions.php';
        $this->CustomEchartsActionsObj = new CustomEchartsActions($this->params);
        $this->CustomEchartsActionsObj->setHomeParams($this->params);
    }
    public function index(){

    }
    /**
     * 报表详情页
     */
    public function getChart()
    {
        $smarty = $this->smarty;
        $this->CustomEchartsActionsObj->ChartSetInfo['report_id'] = $this->params['report_id'];
        $charts = $this->CustomEchartsActionsObj->getSqlDetailData($this->params['report_id']);
        $smarty->assign('mainInfo',$charts['mainInfo']);//主表信息 选择文件夹 统计图名称 描述 设为链接模块
        $smarty->assign('chartSet',$charts['chartSet']);//图表设置信息  图表类型
        $smarty->assign('sqlColumnsArr',$charts['sqlColumnsArr']);//sql解析出来的字段信息
        $smarty->assign('groupInfo',$charts['groupInfo']);//统计维度信息
        $smarty->assign('columnInfo',$charts['columnInfo']);//统计字段信息

        //返回变量
        $filterArr = $charts['sqlFilterArr'];
        $filterArr = $this->CustomEchartsActionsObj->setSqlFilterValue($filterArr);
        if($this->params['frommobile']=='yes'){
            //移动端一行显示一个条件
            $filterArr = array_chunk($filterArr,1);
        }else{
            $filterArr = array_chunk($filterArr,2);
        }
        $smarty->assign('sqlFilterArr',$filterArr);//sql变量信息
        $smarty->assign('request',$this->params);
        $chart_type = $charts['chartSet']['chart_type'];
        $showPercent = "no";
        //显示百分比
        if($chart_type=="pie"||$chart_type=="solid_pie"||$chart_type=="rose_pie"||$chart_type=="nesting_pie"){
            $showPercent = "yes";
        }

        $smarty->assign("showPercent",$showPercent);
        $smarty->assign("frommobile",$this->params['frommobile']);
        $smarty->assign("wx_userid",$this->params['userid']);
        //zxm 20230423 app端的判断
        global $PlatformMC;
        if(is_array($PlatformMC) && array_key_exists('isnativeapp',$PlatformMC) && $PlatformMC['isnativeapp']=='yes')
        {
            $encryptobj=new cls_MyCRMcrypt();
            $smarty->assign("wx_userid",$encryptobj->encode($this->params['userid']));
            $smarty->assign("appusertoken",$this->params['appusertoken']);
        }else{
            $smarty->assign("wx_userid",$this->params['userid']);
        }

        if($this->params['frommobile']=='yes'){
            //移动端查看页
            $corpurl_all = getCorpUrl();
            $corpurl_arr = explode('WeiXinApp',$corpurl_all);
            $smarty->assign("JSURL",$corpurl_arr[0]);
            $smarty->assign("CSSURL",$corpurl_arr[0]);
            $smarty->assign("CRMCOMMONURL",$corpurl_arr[0]);
            //wx_version
            $versioninfo = getVersionInfo();
            $smarty->assign("wx_version",$versioninfo['wx_version']);
            //来自移动端
            global $weixin_user;
            if($weixin_user->environment=='wxwork'||$weixin_user->environment=='weixin'){
                //小程序
                $homefile = "index_mini.php";
            }else if(array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes') {
                //app
                $homefile = "indexnative.php";
            }else{
                //企业微信
                //云之家
                //钉钉
                $homefile = "index.php";
            }
            $smarty->assign("homefile",$homefile);
            $smarty->assign("environment",$weixin_user->environment);
            $smarty->assign("crm_url",$corpurl_arr[0]);
        }
        $isAjax = $this->params['isAjax'];
        $permit_create = isPermitted('ReportAnalysis','Create');
        $permit_edit = isPermitted('ReportAnalysis','EditView');
        if($isAjax=="no"){
            //链接模块
            $content = $smarty->fetch('CustomEcharts/detailviewsql.tpl');
            echo $content;die;
        }else{
            $content = $smarty->fetch('CustomEcharts/detailviewsql.tpl');
            $this->params['diony']='diony';
            $res['content'] = $content;
            $res['title'] = $charts['mainInfo']['report_name'];
            $res['permit_create'] = $permit_create;
            $res['permit_edit'] = $permit_edit;
            $arr['oktext'] = getFixedLabel("SAVE");
            $arr['canceltext'] = getFixedLabel("CANCEL");
            $res['chart_info'] = $charts['data'];
            $res['ChartSetInfo'] = $charts['ChartSetInfo'];
            $res['ChartSetInfo'] = $charts['ChartSetInfo'];
            $res['sqlFilterArr'] = $charts['sqlFilterArr'];
            ConvertTojsonString(1,$res,'success');die;
        }
    }

    public function getChartData(){
        $charts = $this->CustomEchartsActionsObj->getSqlDetailData($this->params['report_id']);
        ConvertTojsonString($charts['code'],$charts,'');die;
    }

}