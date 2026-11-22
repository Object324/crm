<?php

class HomeBoardNewParent
{
    public $PageTabHtml = '';
    public $boardid = 0;
    public $title_height = 64;//组件标题高度
    public $PageTabListSelKey;

    public $PageTabList;
    public $DefaultSelName;
    public $viewStyle;

    public function __construct(){
        $this->boardid  = $_REQUEST['boardid'];
    }

    public function getStuffLabel(&$stuffinfo){
        global $languageType;
        if($languageType == 'zh' && $stuffinfo['stufftitle_zh'] != '')
            $StuffLabelKey = 'stufftitle_zh';
        elseif ($languageType == 'en' && $stuffinfo['stufftitle_en'] != '')
            $StuffLabelKey = 'stufftitle_en';
        else
            $StuffLabelKey = 'stufftitle_label';
        $stuffinfo['StuffLabel'] = $stuffinfo[$StuffLabelKey];
        return $stuffinfo['StuffLabel'];
    }

    public function isActive($tabs){
        global $mod_strings,$app_strings;
        $isactive = true;
        foreach ($tabs as $tabname) {
            if (!vtlib_isModuleActive($tabname)) {
                $isactive = false;
                break;
            }
        }
        return $isactive;
    }

    public function get_stufftitle_lable($stufftitle){
        return getFixedLabel(decode_html($stufftitle));
    }

    public function get_stuff_content_html($stuffinfo)
    {
        global $current_user;
        $stufftitle = $this->getStuffLabel($stuffinfo);

        if ($stuffinfo['height'] != '') {
            $stuff_con_height = (int)explode('px', $stuffinfo['height'])[0];
        }
        $stuff_content_html = '<div id="stuff_' . $stuffinfo['stuffid'] . '" data-boardstuffid="'.$stuffinfo['boardstuffid'].'" class="ld_homeboard_index_layout_plate_stuff" style="height: ' . $stuffinfo['height'] . ';">
            <table width="100%" cellpadding="0" cellspacing="0" class="E_stripe">
                <tr id="headerrow_' . $stuffinfo['stuffid'] . '" >
                    <th class="ld-stuff-tit">
                        <div class="ld-stuff-tit-name sort-tip-items" data-tip="'.$stufftitle.'" data-direction="top" data-type="position" style="float: left;">
                            <span class="icon-bluelt"></span>';

        $stuff_content_html .= $stufftitle;
        if($stuffinfo['stuffid'] == 21){
            $stuff_content_html .= '（'.getFixedLabel('Double_click_to_enter_edit_mode').'）';
        }
        if($stuffinfo['stuffid'] != 36){
            $stuff_content_html .= '<span id="refresh_' . $stuffinfo['stuffid'] . '" style="position:relative;"></span>';
        }

        $stuff_content_html .= '</div>';
        if(is_admin($current_user)&&$stuffinfo['stuffid'] == 112){
            $stuff_content_html .= '<i class="ld-fonticon ld-fonticon-set lineheight24" onclick="EditSalesPhaseTransformationAnalysis(this,' . $stuffinfo['stuffid'] .','.$stuffinfo['boardid'].','.$stuffinfo['boardstuffid'].')"></i>';
            $getSelectList112 = [];
            //上级字段下拉框值
            $module = 'Potentials';
            $stagefieldname = "sales_stage";
            crm_load_class_file('ModuleUtils','modules/lingdang');
            $ModuleUtilsObj = new ModuleUtils();
            $sourcefield = $ModuleUtilsObj->getPrevAdvanceFieldname($module,$stagefieldname);
            //是级联字段 且有上级字段
            if (!empty($sourcefield)) {
                $getSelectList112 = getAllPickListValues($sourcefield);
            }
            if(!empty($getSelectList112)){
                $stuff_content_html.='<select class="ld-select-inner width300 marL10" style="height: 24px !important;" id="boardselect_stage_value" onchange="loadStuff(112,\'chart\',\'\')"><option value=""></option>';
                foreach($getSelectList112 as $tmpvalue){
                    $stuff_content_html.='<option value="'.$tmpvalue.'">'.$tmpvalue.'</option>';
                }
                $stuff_content_html.='</select>';
            }
        }
        $stuff_content_html .= '
                    </th>
                    <th colspan="2" class="N_con_tit" align="right">';
        if($stuffinfo['stuff_url']['url'] && $stuffinfo['stuff_url']['url'] != ''){
            $stuff_content_html .= '<a style="height: 25px; margin-right: 20px;float: right; font-size:12px; color:#999;font-weight: normal;"  title="'.getFixedLabel('MORE').'" onclick="homestuffObj.home_href_popup(\''.$stuffinfo['stuffid'].'\',\''.$stuffinfo['boardstuffid'].'\',\'\',\''.$stuffinfo['stuff_url']['url'].'\',\''.$stuffinfo['stuff_url']['page_addurl'].'\')" href="javascript:;" id="a_' . $stuffinfo['stuffid'] . '">
                            '.getFixedLabel('MORE').'<b class="home_next"></b>
                        </a>';
        }
        $stuff_content_html .= '</th>
                </tr>
	        </table>
            <table width="100%" cellpadding="0" cellspacing="0" class="small" style="table-layout: fixed">
                <tr id="maincont_row_' . $stuffinfo['stuffid'] . '">
                    <td colspan="2">';
        if($stuffinfo['stufftype'] == 'saleskit' || $stuffinfo['stuffid'] == '47'){
            $stuff_content_html .= '<div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow:hidden; overflow-x:hidden;width:100%;">';
        }
        elseif($stuffinfo['stuffid'] == '51' || $stuffinfo['stuffid'] == '64' || $stuffinfo['stuffid'] == '65'){
            $stuff_content_html .= '<div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-x:hidden;width:100%;">';
        }
        elseif($stuffinfo['stuffid'] == '112' || $stuffinfo['stuffid'] == '113'){
            $stuff_content_html .= '<div style="overflow-y: auto;width:100%;height:' . ($stuff_con_height - 50) . 'px;"><div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-x:hidden;"></div>';
        }
        elseif($stuffinfo['stuffid'] == '39'){
            $stuff_content_html .= '<div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-y: auto; overflow-x:auto;width:100%;height:' . ($stuff_con_height - $this->title_height) . 'px;">';
        }else{
            $stuff_content_html .= '<div id="stuffcont_' . $stuffinfo['stuffid'] . '" style="overflow-y: auto; overflow-x:hidden;width:100%;height:' . ($stuff_con_height - $this->title_height) . 'px;">';
        }
        $stuff_content_html .= '</div>
                    </td>
                </tr>
            </table>
        </div>';

        return $stuff_content_html;
    }

    public function get_stuff_url($stuff_info)
    {
        global $adb;
        if($stuff_info['stufflisttype'] == 'defaultstuff'){
            $query = 'select `name`,usereportid from ld_usereport where presence <> 1';
            $result = $adb->pquery($query, array());
            $num_rows = $adb->num_rows($result);
            for ($i = 0; $i < $num_rows; $i++) {
                $name = $adb->query_result($result, $i, 'name');
                $usereportid = $adb->query_result($result, $i, 'usereportid');
                $usereport[$name] = $usereportid;
            }

            if ($stuff_info['stuffid'] == 36) {    //统计
                if (vtlib_isModuleActive('OftenUseReport') && !empty($usereport['SalesSumSequence'])) {
                    $info['url'] = 'index.php?pageto_module=OftenUseReport&pageto_action=newindex';
                    $info['page_addurl'] = '&UseReport=' . $usereport['SalesSumSequence'];
                }
            } else if (vtlib_isModuleActive('SalesOrder') && $stuff_info['stuffid'] == 16) {    //最新销售合同
                $info['url'] = 'index.php?pageto_module=SalesOrder&pageto_action=index';
                $info['page_addurl'] = '';
            } else if ($stuff_info['stuffid'] == 6) {    //应收/应付款汇总
                if (vtlib_isModuleActive('OftenUseReport') && !empty($usereport['CashBillSum_Paymentplan'])) {
                    $info['url'] = 'index.php?pageto_module=OftenUseReport&pageto_action=newindex';
                    $info['page_addurl'] = '&UseReport=' . $usereport['CashBillSum_Paymentplan'];
                }
            } else if (vtlib_isModuleActive('Calendar') && $stuff_info['stuffid'] == 10) {    //过去7天日程
                $info['url'] = 'index.php?pageto_module=Calendar&pageto_action=ListView';
                $info['page_addurl'] = '&from_homepage=upcoming_activities';
            } else if (vtlib_isModuleActive('Calendar') && $stuff_info['stuffid'] == 11) {    //未来7天日程
                $info['url'] = 'index.php?pageto_module=Calendar&pageto_action=ListView';
                $info['page_addurl'] = '&from_homepage=pending_activities';
            } else if (vtlib_isModuleActive('Calendar') && $stuff_info['stuffid'] == 12) {    //过期未完成日程
                $info['url'] = 'index.php?pageto_module=Calendar&pageto_action=ListView';
                $info['page_addurl'] = '&from_homepage=upcoming_nofinish_activities';
            } else if (vtlib_isModuleActive('Potentials') && $stuff_info['stuffid'] == 14) {    //最新销售机会
                $info['url'] = 'index.php?pageto_module=Potentials&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('Quotes') && $stuff_info['stuffid'] == 15) {    //最新报价单 zxm  20220908
                $info['url'] = 'index.php?pageto_module=Quotes&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('Invoice') && $stuff_info['stuffid'] == 17) {    //最新销售发票
                $info['url'] = 'index.php?pageto_module=Invoice&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('PaymentPlan') && $stuff_info['stuffid'] == 25) {    //30天内及过期回款计划
                $info['url'] = 'index.php?pageto_module=PaymentPlan&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('Expense') && $stuff_info['stuffid'] == 26) {    //最新费用报销单
                $info['url'] = 'index.php?pageto_module=Expense&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('CashBill') && $stuff_info['stuffid'] == 27) {    //最新收款单
                $info['url'] = 'index.php?pageto_module=CashBill&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('SendCashBill') && $stuff_info['stuffid'] == 28) {    //最新付款单
                $info['url'] = 'index.php?pageto_module=SendCashBill&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('CashDeposit') && $stuff_info['stuffid'] == 29) {    //最新出纳存现单
                $info['url'] = 'index.php?pageto_module=CashDeposit&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('PutCash') && $stuff_info['stuffid'] == 30) {    //最新出纳提现单
                $info['url'] = 'index.php?pageto_module=PutCash&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('BankCash') && $stuff_info['stuffid'] == 31) {    //现金银行流水账
                $info['url'] = 'index.php?pageto_module=BankCash&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if (vtlib_isModuleActive('Products') && $stuff_info['stuffid'] == 3) {    //产品资料
                //BUG0059534	已分派	周晓梅
                //库存资料缺少更多按钮
                $info['url'] = 'index.php?pageto_module=Products&pageto_action=index';
                $info['page_addurl'] = '&selectuid=';
            } else if ($stuff_info['stuffid'] == 34) {    //交易
                if (vtlib_isModuleActive('OftenUseReport') && !empty($usereport['SalesOrderTrack'])) {
                    $info['url'] = 'index.php?pageto_module=OftenUseReport&pageto_action=newindex';
                    $info['page_addurl'] = '&UseReport=' . $usereport['SalesOrderTrack'];
                }
            } else if (vtlib_isModuleActive('Approve') && $stuff_info['stuffid'] == 39) {    //待审批
                //@edit:liushuai,2020-07-16,reason:1000923/首页，增加“待审批”组件（右上角更多）
                $info['url'] = 'index.php?pageto_module=Approve&pageto_action=ApproveListViewCount';
                $info['page_addurl'] = '';
            }
        }
        return $info;
    }

    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 获取组件页签Html内容方法
     * Params: $PageTabList 页签数组
     * Params: $PageTabStyleInfo 页签样式数组（页签个数，宽度占比）
     */
    public function getPageTabHtml(&$smarty,$PageTabList,$PageTabStyleInfo=[]){
        global $languageType;
        //过滤数组
        if(method_exists($this,'getPageTabDefaultSelName')){
            $this->getPageTabDefaultSelName();
        }
        $this->FilterPageTabList($PageTabList);
        $PageTabHtml = '';
        if(!empty($PageTabList)){
            //为空则赋默认值
            if(empty($PageTabStyleInfo))
                $PageTabStyleInfo = array('TabNum'=>6,'TabWidth'=>0.14);
            //$PageTabListSelKey 选中的页签键值
            $PageTabListSelKey = $this->PageTabListSelKey;
            $PageTabNum = count($PageTabList);
            $TabNum = $PageTabStyleInfo['TabNum'];			//页签展示的数量
            $TabWidth = $PageTabStyleInfo['TabWidth'];		//展示页签宽度比
            if($PageTabNum > $TabNum){
                $PageTabSelInfo = $PageTabList[$PageTabListSelKey];
                $PageTabListMore = array_slice($PageTabList,$TabNum);
                //$PageTabList = array_slice($PageTabList,0,$TabNum);
            }
            $smarty -> assign('languageType',$languageType);
            $smarty -> assign('PageTabList',$PageTabList);
            $smarty -> assign('PageTabSelInfo',$PageTabSelInfo);
            $smarty -> assign('PageTabListMore',$PageTabListMore);
            $smarty -> assign('PageTabListSelKey',$PageTabListSelKey);
            $smarty -> assign('PageTabNum',$PageTabNum);
            $smarty -> assign('TabNum',$TabNum);
            $smarty -> assign('TabWidth',$TabWidth*100 . '%');
            $smarty -> assign('MoreTabWidth',(1-$TabNum*$TabWidth)*100 . '%');	//更多页签的宽度

            $PageTabHtml = '';//$smarty -> fetch("Home/HomeBoardNew_40_Content.tpl");
        }
        $this->PageTabHtml = $PageTabHtml;
        $this->PageTabList = $PageTabList;
        $smarty -> assign('PageTabHtml',$PageTabHtml);
        if($_REQUEST['getPageTabList'] === 'yes'){
            $msg = empty($PageTabList)?getFixedLabel('nosalesgoal'):'';//没有可查看的目标指标
            $code = empty($PageTabList)?-1:1;
            ConvertTojsonString($code,['NavBarList'=>$PageTabList,'NavBarSelKey'=>$PageTabListSelKey],$msg);
        }

        return $PageTabList;
    }
    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 过滤PageTabList，获取需要的值['id','name','selected','label']
     * Params: $PageTabListKeyArr 过滤依据的数组，包含内容的对应键值和过滤键值 filterKey 和过滤值 filterValue
     */
    public function FilterPageTabList(&$PageTabList){
        //$PageTabListKeyArr不为空则需要根据此数组获取页签的['id','name','selected','label']
        $PageTabListKeyArr = $this->getPageTabListKeyArr();
        if(!empty($PageTabListKeyArr)){
            //需要获取的内容的键值
            $tmp_KeyArr = ['id','name','selected','label'];
            $tmp_PageTabList = [];
            //过滤的键值和过滤的内容
            $tmp_FilterKey = $PageTabListKeyArr['filterKey'];
            $tmp_FilterValue = $PageTabListKeyArr['filterValue'];
            $tmp_SelKey = $PageTabListKeyArr['selected'];
            $this->PageTabListSelKey = '';
            $tmp_FirstKey = '';
            foreach ($PageTabList as $key => $PageTabInfo){
                //其他过滤条件
                if($this->FilterPageTabInfo($PageTabInfo))
                    continue;
                //主过滤条件
 
                $tmp_ValueArr = explode(',',$PageTabInfo[$tmp_FilterKey]??'');
                
                if(is_array($tmp_FilterValue)) {
                    $i_Filter = false;
                    foreach ($tmp_FilterValue as $i_FilterValue){
                        if(in_array($i_FilterValue,$tmp_ValueArr,true)) {
                            $i_Filter = true;
                            break;
                        }
                    }
                    if(!$i_Filter)
                        continue;
                } else {
                    if(!in_array($tmp_FilterValue,$tmp_ValueArr))
                        continue;
                }
                //过滤完成获取需要的内容
                foreach ($tmp_KeyArr as $tmpKey){
                    $tmp_PageTabList[$key][$tmpKey] = $PageTabInfo[$PageTabListKeyArr[$tmpKey]];
                }
                $tmp_PageTabList[$key]['fromKey'] = $key;
                //获取选中的键值，获取到选中的键值后则无需再获取
                if($this->PageTabListSelKey === ''){
                    //有 selected 标记的键值，则筛选该键值是否为yes
                    if(!empty($tmp_SelKey) && $PageTabInfo[$PageTabListKeyArr['selected']] == 'yes')
                        $this->PageTabListSelKey = $key;
                    //无 selected 标记的键值，则判断是否有指定的默认值
                    elseif(empty($tmp_SelKey) && !empty($this->DefaultSelName) && $PageTabInfo[$PageTabListKeyArr['name']] == $this->DefaultSelName){
                        $this->PageTabListSelKey = $key;
                    }
                    //既无 selected 标记的键值，也未指定的默认值，则默认第一个
                    elseif(empty($tmp_SelKey) && empty($this->DefaultSelName) )
                        $this->PageTabListSelKey = $key;
                }
                if(empty($tmp_FirstKey) && $tmp_FirstKey !== 0)
                    $tmp_FirstKey = $key;
            }
            //若默认值不在可选列表中，则选择第一个作为默认值
            if($this->PageTabListSelKey === '')
                $this->PageTabListSelKey = $tmp_FirstKey;
            $PageTabList = $tmp_PageTabList;
        }
        return $PageTabList;
    }
    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 过滤的键值、内容的键值都和被过滤数组有关，需要有一一对应关系的数组来进行过滤
     * Params: id,name.selected,label的值对应内容键值
     * Params: filterKey 过滤键值, filterValue 过滤需要对比是否符合的内容，都为空则无需进行主过滤
     */
    public function getPageTabListKeyArr(){
        $PageTabListKeyArr = ['id'=>'id','name'=>'name','selected'=>'selected','label'=>'label'
            ,'filterKey'=>'filterKey','filterValue'=>''];
        return $PageTabListKeyArr;
    }
    /**
     * Edit: xll
     * Date: 2023/08/22
     * Reason: 特殊的过滤条件，如权限判断
     */
    public function FilterPageTabInfo($PageTabInfo){
        return false;
    }
}

?>