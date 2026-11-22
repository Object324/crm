<div class="statistic-analysis-content">
    <div class="statistic-analysis-sidebar prelative lfloat">
        <div class="statistic-analysis-accordion">
            {include file='modules/CardSettings/LeftMenuForSetting.tpl'}
        </div>
    </div>
    <div class="main_grid lfloat" name="SettingRightContent" id="SettingRightContent">
    </div>
</div>

<script>
    var CardSettingsobj = new CardSettings();

    var childmenufile='{$menufile}';
    {literal}
    var formodule=getSearchString("formodule",window.location.href);


    if(childmenufile!='')
    {

        ld.each(ld(" [tag=settingleftmenu]"),function(){
            //39286: （51mis.com/kfbtest）系统设置界面，刷新浏览器后会自动跳转至首页界面
            var action=getSearchString("action",ld(this).attr("link"));
            if(action==childmenufile)
            {
                firstmenuobj=ld(this);
                ld(this).attr("page_addurl","&formodule="+formodule);
                var tmp_page_addurl=encodeURIComponent("&formodule="+formodule);
                var stateObject = {};
                //0041140: （61mis.com/kfbtest）设置>系统设置>页面设置：点击“客户”页面设置，然后刷新浏览器，页面设置界面显示空白
                var newUrl=location.href+"&page_addurl="+tmp_page_addurl;
                history.pushState(stateObject,"",newUrl);

                return false;
            }
        })


    }
    else
    {
        var firstmenuobj=ld(" [tag=settingleftmenu]").get(0);
    }

    firstmenuobj.click();
    ld(firstmenuobj).attr("page_addurl",'');
    {/literal}
</script>