<!--修改编码格式:统一编码：UTF-8-->
{*<!-- this file displays a widget div - the contents of the div are loaded later usnig javascript -->*}
{assign var="homepagedashboard_title" value='Home Page Dashboard'|@getTranslatedString:'Home'}
<script type="text/javascript">var vtdashboard_defaultDashbaordWidgetTitle = '{$homepagedashboard_title}';</script>
<style>
    /*zxm 20230911 这个样式不写在这里  流加载首次获取每个组件的offset的top值有误*/
    .ld_homeboard_index_layout_plate{
        float: left;
        overflow: hidden;
    }
</style>
{foreach key=index item=plateinfo from=$HOMEBOARD_CONTENT['homeboard_plate']}
    {if $plateinfo['platetype'] == 'whole'}
        <div class="ld_homeboard_index_layout">
            <div class="ld_homeboard_index_layout_plate" data-platewidth="{$plateinfo['platewidth']}" data-platetype="{$plateinfo['platetype']}" style="width: 100%;">
    {elseif $plateinfo['platetype'] == 'left'}
        <div class="ld_homeboard_index_layout">
            <div class="ld_homeboard_index_layout_plate" data-platewidth="{$plateinfo['platewidth']}" data-platetype="{$plateinfo['platetype']}" style="width: 66%;">
            {elseif $plateinfo['platetype'] == 'right'}
            <div class="ld_homeboard_index_layout_plate" data-platewidth="{$plateinfo['platewidth']}" data-platetype="{$plateinfo['platetype']}" style="width: 34%;">
    {else}
        <div class="ld_homeboard_index_layout_plate">
    {/if}

    {foreach key=index_stuff item=stuffinfo from=$plateinfo['homeboard_plate_stuff']}
        {$stuffinfo.stuff_html}
    {/foreach}

    {if $plateinfo['platetype'] == 'whole'}
            </div>
        </div>
    {elseif $plateinfo['platetype'] == 'left'}
            </div>
            {elseif $plateinfo['platetype'] == 'right'}
            </div>
        </div>
    {else}
        </div>
    {/if}
{/foreach}

<script language="javascript" >

    function HomeBoardResize() {
        //监听右侧内容大小变化重新计算 首页宽度
        let MutationObserver = window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
        let main_content_obj = ld('section.main-content').get(0);
        let observer = new MutationObserver((mutationList) => {
            setTimeout(function(){
                setHomeBoardWidth();
            },500);
        })
        observer.observe(main_content_obj, { attributes: true, attributeFilter: ['style'], attributeOldValue: true })
    }
    HomeBoardResize();
    setTimeout(function(){
        setHomeBoardWidth();
    },500);
    //hzx BUG0076241 优化首页看板宽度
    function setHomeBoardWidth() {
        var pagecontent_width = ld('#pagecontent .wrapper-panel-inner').get(0).offsetWidth - 10;
        //console.log(pagecontent_width);
        ld('#pagecontent .wrapper-panel-inner .ld_homeboard_index_layout').each(function () {
            var plate_length = ld(this).find('.ld_homeboard_index_layout_plate').length;
            var padding_width = plate_length * 10;//区块间隔宽度
            var page_width = pagecontent_width - padding_width;
            ld(this).find('.ld_homeboard_index_layout_plate').each(function () {
                var width_array = ld(this).data('platewidth').split('-');
                var plate_width = page_width / parseInt(width_array[1]) * parseInt(width_array[0]);
                ld(this).css('width', plate_width + 'px');
                //服务看板  特殊判断:需要增加横向滚动条
                if (ld(this).find('#stuffcont_66').length > 0) {
                    ld(this).find('#stuffcont_66').css('width', plate_width + 'px');
                }
                if (ld(this).data('platetype') != 'right') {
                    ld(this).css('margin-right', '10px');//区块间隔宽度
                }
            })
        });
    }
    //看板根据页面大小自适应 BUG20240308-04
    /*ld(window).resize(function() {
        setHomeBoardWidth();
        //setHeight();
    });*/
    function setHeight(){
        ld('body').css('overflow','hidden');
        var a = ld('.Header').outerHeight(),//头部高度
            b = ld('.home_header_top').outerHeight(),//筛选高度
            c_height = 0,
            s_height = ld('#pagecontent').height();

        if(a==null) a=0;
        if(b==null) b=0;
        c_height = s_height;
        //edit: xll 2023/08/12 BUG0070844 报表分析--管理驾驶舱--客户分析，界面无法全部显示 其他分析模块如果需要滚动显示都会最下面有一块无法显示
        var module = getUrlParam("pageto_module");
        if(module == 'VisualAnalysis'){
            var module_head_height = b = ld('#VisualAnalysis_index .ld_VisualAnalysis_top').outerHeight()
            c_height -= (module_head_height+8);
        }else{
            c_height = c_height;
        }
        var homeIndexObj = ld('#home_index');
        homeIndexObj.css('height',c_height);
    }
    (function ScrollBoard() {
        //edit: xll 2024/02/22 BUG20240219-35 kfbcrm-首页看板-点击看板后再打开下拉框，应自动滚动到当前看板位置
        ld('#home_index').find('#homeboard_name').one('mouseover',function () {
            ScrollBoardIntoView(ld(this).attr('boardid'))
        })
    })();

    //首页组件穿透方法
    function home_href(surl,page_addurl){
        if(page_addurl != ''){
            page_addurl = '&page_addurl='+encodeURIComponent(page_addurl);
        }
        window.open(surl+page_addurl);

    }


    function SalesRankings(stuffid){
        if(stuffid == 33){
            ld('#stuffcont_'+stuffid+' .widget-content .tab span').each(function(){
                var tab_item = ld(this).attr('class');
                if(tab_item == 'tab-item cur'){
                    var data_type = ld(this).attr('data-type'),page_addurl;
                    if(data_type == 'amount'){
                        page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value=sendpament_amount');
                        window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
                    }else if(data_type == 'contractaount'){
                        page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value=due_amount');
                        window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
                    }else if(data_type == 'contractquantity'){
                        page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value=due_num');
                        window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
                    }
                    else {
                        page_addurl = encodeURIComponent('&UseReportName=Salesranking&salesranking_value='+data_type);
                        window.open('index.php?pageto_module=ReportAnalysis&pageto_action=newindex&page_addurl='+page_addurl);
                    }
                }
            })
        }else if(stuffid == 40 || stuffid == 101){
            //@edit:zhouxiaomei @date:2020-9-7 @reason: 首页增加近6个月销售目标完成情况组件  更多按钮的跳转路由
            //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘
            window.open("index.php?pageto_module=SalesGoal&pageto_action=index");
        }else if(stuffid == 43){
            //@edit:zhouxiaomei @date:2020-9-9 @reason: 首页增加日程管理组件  更多按钮的跳转路由
            window.open("index.php?pageto_module=Calendar&pageto_action=index");
        }

    }
    /**
     * @edit:zhouxiaomei
     * @date:2020-09-07
     * @reason:近6个月销售目标完成情况 tab切换点击事件
     * @param stuffId
     * @param obj
     */
    function tabChange(stuffId,obj)
    {
        //edit: xll 2023/08/14 XUQIU1001400 首页组件增加目标完成率仪表盘（更多页签的处理）
        var curObj = obj;
        var objTag = ld(obj).attr('tag');
        if(objTag == 'more'){
            curObj = ld(obj).parents('.tab_more');
        } else {
            var TabMoreTextObj = ld(obj).siblings('.tab_more').find('.tab_more_text');
            TabMoreTextObj.text('');
        }
        //销售指标
        if(stuffId == 40 || stuffId == 101 || stuffId == 100 ){
            let data_type = ld(obj).attr('data-type');
            ld('#maincont_row_'+stuffId+' #sales_target_tab .tab span').removeClass('cur');
            ld(curObj).addClass('cur');
            loadStuff(stuffId,'chart',data_type);
        }
        //销售指标
        if(stuffId == 50||stuffId == 56){
            let data_type = ld(obj).attr('data-type');
            ld('#maincont_row_'+stuffId+' .widget-content .tab span').removeClass('cur');
            ld(curObj).addClass('cur');
            loadStuff(stuffId,'rankinglist',data_type);
        }
    }

</script>
