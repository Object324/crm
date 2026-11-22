{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
{*
/*********************************************************************************
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/ *}
<!--修改编码格式:统一编码：UTF-8-->


<form method="POST" action="javascript:;" onsubmit="puyoungJS_DialogBox.block();">
<div class="main_grid_top">
    <div class="grid-view-title lfloat overflow-hidden">
        <span class="grid-view-name dinline-block lfloat">
            {'BackUpBeforeResotreDemo'|@getFixedLabel}
        </span>
        
    </div>
    
</div>
<div class="main_grid_box">
    {$listhtml}
</div>
</form>
<script type="text/javascript">
 var tipbackupcontent='{"MakeSureBackUp"|getFixedLabel}';
 var tiptitle='{"RestoreDataBaseDemo"|getFixedLabel}';
 var tipokbtn_text='{"HadBackUp"|getFixedLabel}';
 
 var tipcancelbtn_text='{"NoneBackUp"|getFixedLabel}';
 
</script>
{literal}
<script type="text/javascript">
var chooserestoretype='';
var restoreid='';

ld("a[tag='restoredata']").unbind("click").bind("click",function(){
  //headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText
  chooserestoretype=ld(this).attr("type");
  restoreid=ld(this).parent().parent().attr('tag');
 
   var  tipopupobj=CrmPopup.load(tiptitle,startRestorePopup, cancelRestore,'550',"Restore",'',tipokbtn_text,'',tipcancelbtn_text);
   var contenthtml="<div style='height:50px;line-height:50px'>"+tipbackupcontent+"</div>";
   
   tipopupobj.show(contenthtml);
})
var restorestartrow=0;
function startRestorePopup()
{
    var popupobj=CrmPopup.getPopupObj('last');
    ldAjax("index.php?module=Settings&action=SettingsAjax&file=RestoreDataBasePopup&chooserestoretype="+chooserestoretype,{},function(ajaxdata){

         var tipopupobj=CrmPopup.load(ajaxdata.result.title,'','','750',"Restore",'','','','');

           tipopupobj.show(ajaxdata.result.content);
         RestoreDataProgress();
         //wym BUG0069928 恢复行业演示账套，有进度条就不要显示加载图标了  
        ld("#rptContentLoading").hide();
          
          
           
           
   
    })
    
}
function RestoreDataProgress()
{
            var url="index.php?module=Settings&action=SettingsAjax&file=OperateRestoreDataBase&chooserestoretype="+chooserestoretype+"&restoreid="+restoreid;
           url+="&startrow="+restorestartrow;
           
           ldAjax(url,{},function(ajaxdata){
               
                
               if(ajaxdata.code=='-1')
               {
                 alert(ajaxdata.msg);
                 return false;
               }
               var progresswidth=710;
               restorestartrow=parseInt(ajaxdata.result.nextstartrow);
               var totalline=parseInt(ajaxdata.result.totalline);
               if(ajaxdata.code==1&&ajaxdata.result.finished=='no')
               {
                   
                    var step=progresswidth/totalline;
                    var dvwidth=restorestartrow*step;
                     if(dvwidth>progresswidth)  
                     {
                        dvwidth=progresswidth;
                     } 
                     document.getElementById("dv").innerHTML=restorestartrow+'/'+totalline;
                     document.getElementById("dvprogress").style.width = parseInt(dvwidth,10)+'px';
                     for(var i=0;i<2000;i++)
                     {
                        break;
                     }
                     
                    RestoreDataProgress();
                    return false;
               }
               document.getElementById("dv").innerHTML=totalline+'/'+totalline;
               document.getElementById("dvprogress").style.width =progresswidth+ 'px';
               EmptyProgressObjs();
               var popupobj=CrmPopup.getPopupObj('last');
               
                popupobj.CancelEvent();
               loginout();
           })
}
startRestorePopup.funname='startRestorePopup';
function cancelRestore()
{
   
    ld("[name=LBL_BACKUP_SET]").click();
   
}
cancelRestore.funname='cancelRestore';

</script>
{/literal}