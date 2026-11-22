{*该文件已经不使用 20240704 hzx*}


<!--中间-->
<div class="statistic-analysis-content ld-first">
    <div class="statistic-analysis-sidebar prelative lfloat" >
        <div class="statistic-analysis-accordion">
            {include file='LeftMenuForSetting.tpl'}
        </div>
    </div>
    <div class="main_grid lfloat" name="SettingRightContent" id="SettingRightContent">
    </div>
</div>
<!--中间 end-->
<script>
var childmenufile='{$menufile}';
var selftype='{$selftype}';
{literal}
var formodule=getSearchString("formodule",window.location.href);

	
    if(childmenufile!='')
    {
    
      ld.each(ld(" [tag=settingleftmenu]"),function(){
        //39286: （51mis.com/kfbtest）系统设置界面，刷新浏览器后会自动跳转至首页界面
         var action=getSearchString("action",ld(this).attr("link"));
         //duan 202207029 服务小程序和订单小程序跳转判断，因为访问的menufile相同，所以增加判断selftype
         if(action==childmenufile && (action!='SelfServiceConfig' || empty(selftype) || getSearchString("selftype",ld(this).attr("link"))== selftype) )
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