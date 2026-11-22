{if $iskehu001 eq 'yes'}
    <script src="https://res.wx.qq.com/open/js/jweixin-1.2.0.js?v={$GLOBALMINVERSION}"></script>
    <script src="https://open.work.weixin.qq.com/wwopen/js/jwxwork-1.0.0.js?v={$GLOBALMINVERSION}"></script>
     <script type="text/javascript" language="javascript" src="{$JSURL}include/js/cls_wxOpenData.js?v={$GLOBALMINVERSION}"></script>
    {/if}
  <script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
{$Content}
<script>
	var ld = $;
 var wx_timestamp='{$timestamp}';
var wx_corpid='{$wx_corpid}';//'wxa246741d62d718f0';
var wx_agentid='{$wx_agentid}';//'1000345';
var wx_nonceStr='{$nonceStr}';
var wx_agent_signature='{$agentsignature}';
var wx_signature='{$signature}';
var iskehu001='{$iskehu001}';
{literal}
  
var cls_wxOpenDataobj;

if(iskehu001 =='yes')
{

 cls_wxOpenDataobj=new cls_wxOpenData();  
     
 cls_wxOpenDataobj.init();
    setTimeout(function(){
        window.print();
    },600);
}
else{
    
     window.print();
}

{/literal}
        

</script>