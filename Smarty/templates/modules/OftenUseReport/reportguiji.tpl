<script language="javascript" type="text/javascript" src="jsbase/My97DatePicker/WdatePicker.js"></script>
<div id="dv_guijisearch">
    <table>
        <tr>
        <td>开始日期:</td>
        <td style="width: 250px;"><input class="Wdate btn-radius-system" name="startdate"  value="{$NOWTIME}" onclick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})" style="padding-left:5px;"/></td>
        <td>结束日期:</td>
        <td><input class="Wdate btn-radius-system" name="enddate"  value="{$ENDTIME}" onclick="WdatePicker({ldelim}dateFmt:'yyyy-MM-dd HH:mm:ss'{rdelim})" style="padding-left:5px;"/></td>
        
        </tr>
        <tr>
        <td>成员:</td>
        <td> {include file='Comprehensivereport/SmownerSearchScope.tpl'}
        <a class="icon-range" href="javascript:void(0);" title="查看范围" onclick="mutliSelectUser('')" style="margin-left: 10px;margin-top: 5px;height:20px;"></a>
        </td>
        <td><input  type="button" value="立即查询" name="search_btn" class="createauto b_radius3"/></td>
        <td><input  type="button" value="导出" name="search_export" class="createauto b_radius3"/></td>
        
        </tr>
    
    </table>
</div>
<div id="dv_guiji">
{include file="modules/OftenUseReport/reportguijicontent.tpl"}
</div>
<script>
{literal}
var popupobj=new Object();
popupobj.type="listpage";
popupobj.divid="dv_guijisearch";

CrmPopup.global_listPopupObj.push(popupobj);
var selected_user="";


function mutliSelectUser()
{   
	var scopepopupobj;
    var module="OftenUseReport";
    var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module=Users&popup_inputtype=checkbox&popup_selecttype=user';
    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = arrJsPopLabel['DISTRIBUT'];//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
		   cls_ScopePopup.prop.popup_value = selected_user;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                    //没有选择任何用户，则给出提示
                    if(empty(cls_ScopePopup.return_obj.return_id)){
                        //selected_user="";
                        
                        return false;
                    }else{
                         selected_user = cls_ScopePopup.return_obj.return_id;//选中的用户
                        
                         ld("#SmOwnerSearchScope").val("smowner_search_senior");
                         ld("[name='cmb_span_optiontext_SmOwnerSearchScope']").html("高级");
                         ld('.D_pbtn .D_pbtncancel').click();
                    }
                });
            }
		});
	});
}
//立即查询
ld("[name=search_btn]").unbind("click").bind("click",function(){
    
     $("status").style.display="inline";
        var startdate=ld("[name=startdate]").val();
        var enddate=ld("[name=enddate]").val();
        var userid=ld("#SmOwnerSearchScope").val();
        if(ld("#SmOwnerSearchScope").val()=="smowner_search_senior")
        {
            userid=selected_user;
        }
     new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=OftenUseReport&action=OftenUseReportAjax&file=ReportGuiJi&mode=ajax&startdate="+startdate+"&smowner="+userid+"&enddate="+enddate,
			onComplete: function(response) {
			     $("status").style.display="none";
    			 if(response.responseText.indexOf("##error##$$")>=0)
                 {
                    alert("开始日期和结束日期时间差不能超过24小时!");
                    return false;
                 }
                 else
     			{
                    
                    var results=response.responseText.split("##$$$###$$");
                    ld("#dv_guiji").html(results[1]);
                    setChkEvent();
                }
			}
		}
	);
    
});
//导出
ld("[name='search_export']").unbind("click").bind("click",function(){
   
  
   var tags="";
   var startdate=ld("[name=startdate]").val();
   var enddate=ld("[name=enddate]").val();
   var userid=ld("#SmOwnerSearchScope").val();
   if(ld("#SmOwnerSearchScope").val()=="smowner_search_senior")
   {
        userid=selected_user;
   }
    $("status").style.display="inline";
    ld("[name=chk_guiji]").each(function(){
       if(ld(this).is(":checked"))
       {
            tags+=","+ld(this).attr("tag");
            
       } 
        
    });

     new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody:"module=OftenUseReport&action=OftenUseReportAjax&file=ExportGuiji&startdate="+startdate+"&smowner="+userid+"&enddate="+enddate+"&tags="+tags,
			onComplete: function(response) {
		                  $("status").style.display="none";
        				if(response.responseText.indexOf("##error##$$")>=0)
                         {
                            alert("开始日期和结束日期时间差不能超过24小时!");
                            return false;
                         }
                         else
             			{
                                 ld('<form action="index.php?module=OftenUseReport&action=ExportGuiji&type=download" method="post">' +  // action请求路径及推送方法
                               
                            '</form>').appendTo('body').submit().remove();
                        }
                    
                   	
                
			}
		}
	);
    
})

function setChkEvent()
{
    ld("[name='chk_allguiji']").change(function(){
       
         if(ld(this).is(':checked'))
         {
            ld('[name=chk_guiji]').prop("checked",true);
         }
         else
         {
            ld('[name=chk_guiji]').prop("checked",false);
         }
    });
}
{/literal}
</script>