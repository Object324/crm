{*<!--
/*+********************************************************************************
  * The contents of this file are subject to the lingdang CRM Public License Version 1.0
  * ("License"); You may not use this file except in compliance with the License
  * The Original Code is:  lingdang CRM Open Source
  * The Initial Developer of the Original Code is lingdang.
  * Portions created by lingdang are Copyright (C) lingdang.
  * All Rights Reserved.
  *********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->
<div class="footer">
    <p>


       
        <br />
        {if $COMMON_VERSIONINFO.aboutweb neq ''}
        <a href="{$COMMON_VERSIONINFO.aboutweb}" target="_blank">{if $LANGUAGETYPE eq 'zh'}{$COMMON_VERSIONINFO.aboutweblabel}{else}{$COMMON_VERSIONINFO.EN_aboutweblabel}{/if}</a>|
        {/if}
		
      <a onclick="showregisterabout();" href="javascript:void(0);">{if $LANGUAGETYPE eq 'zh'}授权信息{else}Authorization Information{/if}</a>|
        
            <a href="javascript:void(0);" onclick="openWechatURL();">{if $LANGUAGETYPE eq 'zh'}{$COMMON_VERSIONINFO.Install_Weixinlabel}{else}{$COMMON_VERSIONINFO.EN_Install_Weixinlabel}{/if}</a>|
        
        <a href="javascript:void(0);" onclick="clearcache('{$TOKEN}');">{if $LANGUAGETYPE eq 'zh'}清除缓存{else}Clear Cache{/if}</a>
        <br />
        {if $LANGUAGETYPE eq 'zh'}版权所有{else}Copyright{/if} {$SOFTINFO.BeginYear}~{$smarty.now|date_format:'%Y'}  
            {if $LANGUAGETYPE eq 'zh'}
                {$SOFTINFO.CopyRight}
            {else}
                {$SOFTINFO.EN_CopyRight}
            {/if}
    </p>
</div>
</body>
{literal}
<script type="text/javascript">
function showregisterabout()
{
    
     if((document.all))
    {
        var s= window.showModalDialog("Register/about001.php",'sss,dd',"dialogWidth:550px;dialogHeight:550px;resizable:no;status:no;location:no"); 
    }
    else 
    {
        
         //35908: （灵当CRM和kehu001账套）产品授权信息【弹框】居中显示
          
          var url="Register/about001.php";                            //转向网页的地址;
          var name="";                           //网页名称，可为空;
          var iWidth=550;                         //弹出窗口的宽度;
          var iHeight=550;                        //弹出窗口的高度;
          //window.screen.height获得屏幕的高，window.screen.width获得屏幕的宽
          var iTop = (window.screen.height-30-iHeight)/2-25;       //获得窗口的垂直位置;
          var iLeft = (window.screen.width-10-iWidth)/2;        //获得窗口的水平位置;
          window.open(url,name,'height='+iHeight+',,innerHeight='+iHeight+',width='+iWidth+',innerWidth='+iWidth+',top='+iTop+',left='+iLeft+',toolbar=no,menubar=no,scrollbars=auto,resizeable=no,location=no,status=no');
         
         
       //window.open("Register/about001.php","","width=400,height=400,menubar=no,toolbar=no,location=no,scrollbars=yes,status=no,modal=yes,resizable=no");

    }
}
</script>
{/literal}
