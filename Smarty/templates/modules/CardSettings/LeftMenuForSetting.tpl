<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/CardSettings/CardSettings.js?v={$GLOBALMINVERSION}"></script>
<div class="analysis-accordion-content">
    <a href="javascript:;" class="analysis-accordion-header displayblock selected" title="电子名片设置"><i class="dinline-block lfloat"></i><span class="dinline-block lfloat">电子名片设置</span></a>
    <div class="analysis-accordion" style="display: block;">
        <ul class="list">
            <li class="active"><a tag="settingleftmenu" name="cardinfo" link="index.php?module=CardSettings&action=CardInfoSettings" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="名片信息">名片信息</a></li>
            <li><a tag="settingleftmenu" name="marketing" link="index.php?module=CardSettings&action=MarketingSettings" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="营销按钮">营销按钮</a></li>
            <li><a tag="settingleftmenu" name="companyprofile" link="index.php?module=CardSettings&action=CompanyProfileSettings" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="公司简介">公司简介</a></li>
            <li><a tag="settingleftmenu" name="topicblock" link="index.php?module=CardSettings&action=TopicBlockSettings" href="javascript:;" onclick="LeftMenuSettingClick(event,ld(this))" title="专题区块">专题区块</a></li>

        </ul>
    </div>
</div>

<script type="text/javascript">
var module='{$MODULE}';

{literal}
    //18070: 控制面板>用户管理：点击下一页或上一页后，查看用户， 结果：用户管理页签收起。
    if(module=='Users')
    {
        var obj=document.getElementById('controlTitle_1');
        showControl(obj,1);
    }
    function showControl(obj,fori){
        var inputs = $(".ControlUl");
        for(var i=0;i<inputs.length;i++){
            inputs[i].style.display = 'none';
            document.getElementById('controlTitle_'+(i+1)).className = 'Title';
        }
        document.getElementById('controlUl_'+fori).style.display = 'block';
        obj.className = 'Title TitleOn';
    }
    ld(function(){
        //加载内容中点击事件
        initContentLeftMenuClick();
    });


    function LeftMenuSettingClick(event,jqueryobj){
        var link=ld(jqueryobj).attr("link");
        //获取link的action参数
        var action=getSearchString("action",link);
		//控制面板-产品授权中心
		if(link == 'index.php?action=isReg'){
			window.open('index.php?action=isReg&ReportHeader=dheader');
			return false;
		}
        link+="&ReportHeader=dheader";
        if(ld(jqueryobj).attr("page_addurl")!=undefined){
            link+=ld(jqueryobj).attr("page_addurl");
        }
        ld.ajax({
            url:link,
            type:"post",
            dataType:"json",
            success:function(data){
                //异地登录
                if(data.code==DataCode.logincontrol)
                {
                    Tools.Relogin();
                }
                var stateObject = {};
                var href=location.href;
                // var newUrl=href+"&pageto_menufile="+action;
                var hrefArr = href.split('&pageto_menufile');
                var newUrl=hrefArr[0]+"&pageto_menufile="+action;
                history.pushState(stateObject,"",newUrl);
                ld(" [name=SettingRightContent]").html(data.result.content);
                //将选择模块select下拉框设置为不显示，并在其后插入输入下拉框div
                var selectobj=ld(" [name=SettingRightContent] .main_grid_top").find("[fieldtype=select]");
                if(selectobj.length>0&&selectobj!=undefined){
                    var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
                    CrmPopup.global_listPopupObj=[];
                    var obj=new Object();
                    obj.divid="SettingRightContent";
                    CrmPopup.global_listPopupObj.push(obj);
                    obj.CancelEvent=function(){
                        return false;
                    }
                    cls_resetComboxHtmlobj.setPopupObj(obj);
                    cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,150);
                    ld(' .grid-view-title').css('width', ld(' .grid-view-title').width()+20+'px');
                    ld(' .chzn-container').css('margin-top', '17px');
                    ld(' .chzn-drop').css('margin-left', '10px');
                }
                initRightContentHeight();//加载右侧内容中菜单和详细内容高度
            }
        })
    }


{/literal}
</script>