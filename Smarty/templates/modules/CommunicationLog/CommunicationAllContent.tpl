<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/CommunicationLog.js"></script>
<div id="communicationallcontent">
   
</div>

{literal}
<script>
    ld(function(){
       ld.ajax({
            url:"index.php?module=CommunicationLog&action=CommunicationLogAjax&file=smslist",
            dataType:"json",
            type:"post",
            success:function(data){
                ld("#communicationallcontent").html(data.result.content);
                //wsh BUG20240726-36 2024-08-05
                tooltip(ld("#communicationallcontent").find("[name=failed_tips]"), {transition: true, time: 200});
                communcationtabClick();
            }
       })
      
      //ld("[tag=tab_CommunicationLog][tabtype=smslist]").click();
    })
    
    function communcationtabClick(){
        
          ld("[tag=tab_CommunicationLog]").unbind("click").bind("click",function(){
          
          ld.ajax({
            url:"index.php?module=CommunicationLog&action=CommunicationLogAjax&file=TabTypeList&tabtype="+ld(this).attr("tabtype"),
            type:"post",
            
            timeout:20000,
            dataType:"json",
            success:function(data){
             
                ld("#communicationallcontent").html(data.result.content);
                if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
                     //通讯录(pc端企业微信)
                    cls_wxOpenDataobj.bindAllOpenData();
            }
          })
        
                
            
        })
    }

if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
     //通讯录(pc端企业微信)
    cls_wxOpenDataobj.bindAllOpenData();
</script>
{/literal}