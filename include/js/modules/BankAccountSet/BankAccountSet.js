function docheck(module)
{ 
	var scopepopupobj;//自定义弹出层页面html，绑定事件
    var popup_caption_value = arrJsPopLabel['LBL_SELECTUSER'];//标题
	var useridstr = ld('#owners').val();
	 var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&popup_module='+module+'&popup_inputtype=checkbox&popup_selecttype=user';
	getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
		var methodObj = {'popup_check_inactiveuser':'yes'};
		scopepopupobj =  new ScopePopupObj(methodObj);
        scopepopupobj.popup_caption_value = popup_caption_value;//标题title
		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
		   cls_ScopePopup.prop.popup_url = popup_url;//popup_url
           cls_ScopePopup.prop.popup_module = module;//模块
           cls_ScopePopup.prop.popup_value = useridstr;
		   var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
		    //重写确认按钮事件
            scopepopupobj.setEventBtnOk=function(){
                ld('.E_pbtn .E_pbtnok').unbind('click').on('click',function(){
					if(empty(cls_ScopePopup.return_obj.return_id)){
						var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
						return false;
                    }else{
						ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtncancel').click();
						 ld("#owners").val(cls_ScopePopup.return_obj.return_id);
					}
                });
            }
			
		});
	});
}

function SaveBankAccountSetAccount()
{
    var detailpopupobj=CrmPopup.getlastPopupObjByPageType(DetailViewPage.pagetype);
    
    var popupobj=CrmPopup.getPopupObj('last');
   
    var checkstand=ld("#"+popupobj.divid+" [name=aa]:checked").val();
  
    if(checkstand=="N"){
        var c=0;
       
        
        var useridstr = document.getElementById('owners').value;
        if(useridstr==''||useridstr=='-1'){
            var confirm_str = arrJsPopLabel['Pleaseselectatleastoneperson'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            docheck();
            return false;
        }
    }
    var form=document.forms['frmPotentialstShare'];
    
	var owners = form.owners.value;
	var aa = checkstand;
	var surl = "index.php?module=BankAccountSet&action=BankAccountSetAjax&file=SaveAccountProfile&bankaccountsetid="+detailpopupobj.record+"&owners="+owners+"&aa="+aa;
	ldAjax(surl,"",function(data){
		if(data.code == 1){
			fninvshnew('divPotentialsShare');
            popupobj.CancelEvent();
		}
        DelProgressObjs();
	})
}
SaveBankAccountSetAccount.funname='SaveBankAccountSetAccount';

function select_all(checkel,groupname){
    var checkel=$(checkel);
    var thechecked=checkel.checked;
    var allcheckvals=$$('.StepUserClass');
    for(var i=0;i<allcheckvals.length;i++){
    var el=allcheckvals[i];
    var groupnameattr=el.getAttribute("groupname");
    if(groupnameattr==groupname)
    {
       el.checked=thechecked; 
      
    }
   
     
    }
} 
function BankAccountDeleteDetail(confirmationMsg,formName,action){
   ld('#rptContentLoading').show();
    var delrecord=document.DetailView.record.value;
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=BankAccountSet&action=DeleteAjax&delrecord="+delrecord,
					onComplete: function(response) {
						ld('#rptContentLoading').hide();
                       
                        if(response.responseText.indexOf("#####:error")==-1)
                            {
                                 if(confirm(confirmationMsg))
                                   {
                                     submitFormForAction(formName,action);
                                   }
                            }
                            else 
                            {
                                //您选择的记录有已收款或者部分已收款的单据，删除失败！
                                var confirm_str = arrJsPopLabel['tpoadrcnbd'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            }
					}
				}
				);
}

function BankAccountMassDelete(alert_str,module,gstart,viewid,idlist,searchscope)
{   
      new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=BankAccountSet&action=DeleteAjax&idlist="+idlist+"&SearchScope="+searchscope,
					onComplete: function(response) {
					   results=response.responseText.split("#####:success");					   
					   var icds=results[1];
                       var idss = icds.split('-')[0];
                       var ids = icds.split('-')[1];
                       if(ids==';&excludedRecords='){
                        var confirm_str = arrJsPopLabel['araawtdcnbd'];
                        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                         return false;
                       }
                       RemindsMsg("","LdPopWidth400px","","yes","yes",alert_str);
                       //确定按钮
                       ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){   
                           new Ajax.Request(
                            'index.php',
                            {
                              queue: {
                                position: 'end',
                                scope: 'command'
                              },
                              method: 'post',
                              postBody:"module=Users&action=massdelete&return_module="+module+"&"+gstart+"&viewname="+viewid+"&idlist="+ids+"&SearchScope="+searchscope,
                              onComplete: function(response) {
                                ld('#rptContentLoading').hide();
                                          
                                result = response.responseText.split('&#&#&#');
                                            if(result[2]!="undefined")
                                            {
                                                var alert_str = arrJsPopLabel['Successfullyremoved'] + ' ' + idss + ' ' + arrJsPopLabel['Recordsc'];
                                                RemindsMsg("","LdPopWidth400px","","yes","",alert_str);
                                                $("ListViewContents").innerHTML= result[2];
                                            }
                                            else 
                                            {
                                                $("ListViewContents").innerHTML= "数据错误!";
                                            }
                              }
                            }
                          );
                       });
					}
				}
				);
                return false;
}

function BankAccountDelete(alert_str,url)
{
       ld('#rptContentLoading').show();

    var delrecord=url.split("&")[url.split("&").length-1]
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=BankAccountSet&action=DeleteAjax&"+delrecord,
					onComplete: function(response) {
						ld('#rptContentLoading').hide();
                        if(response.responseText.indexOf("#####:error")==-1)
                            {  
                                 if(confirm(alert_str))
                                   {  
                                     document.location.href=url;
                                   }
                            }
                            else 
                            {
                                var confirm_str = arrJsPopLabel['tpoadrcnbd'];
                                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                            }
					}
				}
				);

}

function set_bank_checks_presence(stockid,type)
{
    var confirm_str = arrJsPopLabel['UPDATEBANKCURRENCY'];//UPDATbank
    var uv='';
    if(type == 1){	
        var searchurl = $('search_url').value;
        var viewid = getviewId();
        var idstring = "";
        var select_options = $('allselectedboxes').value;
        var excludedRecords = $('excludedRecords').value;
        var searchScope="";
        /* 因为银行账户模块里边没有查看范围，所以不需要加这些判断。
           if(document.getElementById("SmOwnerSearchScope")!=undefined)
              searchScope= encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
          else if (module=="Reminds"||module=="BankAccountSet")
                  searchScope="SmOwner_Search_All";
        */
        var gstart = '';
        uv="&return_module=BankAccountSet&"+gstart+"&viewname="+viewid;//+"&SearchScope="+searchScope
     }

     RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
     //确定按钮
     ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
         // BUG0074291 lius 20231020 银行账户-点击列表操作栏“结束初始化”按钮，界面显示“undefined”
         var urlstring='index.php?module=BankAccountSet&action=BankAccountSetAjax&file=BankAccountConfirm&&record='+stockid+uv;
         ldAjax(urlstring,"",function(data){
             if(data.code==1){
                 if (type == 1) {
                     BankAccountconfirm();
                     return true;
                 } else if (type == 2) {
                     var tmparra = new Array();
                     tmparra.push(stockid);
                     var tmpobj = new AfterUpdatePrevPopupObjContent('BankAccountSet', getEmptyValueInfo(), tmparra);
                     var refreshlistmodules = new Array('BankAccountSet');
                     tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                     //edit:can 2021-01-06 44116: 银行账户->新增银行账户->更多->结束初始化之后，界面没有刷新还显示更多->结束初始化
                     tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
                     console.log(tmparra);
                 } else if (type == 3) {
                     return true;
                 }
                 //@edit:liushuai,2021-04-06,reason: 0045257: （61mis.com/kfbcrm）财务管理-银行账户；本月新建的银行账户，点击结束初始化后，列表下面不显示了
                 setContentHeight('BankAccountSet');//计算内容高度
             }

         })
     });
}


function PotentialsShare(obj,id)
{
    ldAjax("index.php?module=BankAccountSet&action=BankAccountSetAjax&file=BankAccountProfile&id="+id,{},function(data){
        //SaveBankAccountSetAccount
        var popupobj=CrmPopup.load(data.result.title,SaveBankAccountSetAccount, "",400,'BankAccountSet',"",data.result.oktext,"",data.result.canceltext);
        CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content)
        DelProgressObjs();
    })
  
}

//批量禁用
function Inactivating(obj, module, popup_type, mode) {
    var idlist='';
    idlist = document.getElementById('allselectedboxes').value;
    if(idlist==null || idlist=='' || idlist==undefined){
        RemindsMsg("", "LdPopWidth400px", module, "yes", "yes", "");
        return false;
    }
    var url='index.php?module=BankAccountSet&action=BankAccountSetAjax&file=Inactivating';
    url += '&mode=disable';
    url += '&idlist='+idlist;
    var Popupobj=CrmPopup.load("","","","LdPopWidth650px",module,"","","","");
    ldAjax(url,'',function(data){
        if(data.code==1){
            var title=data.result.title;
            var oktext=data.result.oktext;
            var content_html='';
            //var canceltext="cancel";
            for(i=0;i<data.result.message_arr.length;i++){
                content_html+=data.result.message_arr[i];
            }
            Popupobj.setParams(data.result.title,BankAccountconfirm,"","LdPopWidth650px",module,"",data.result.oktext,"","");
            //接收PHP返回的【回复】弹出层的内容并进行展示   
            content_html = '<div id="Inactivating_content" class="pop_remind_content">'+content_html+'</div>';  // hjz 给提示信息添加div   
            Popupobj.show(content_html);
            
        }
    });     
}


function BankAccountconfirm(){
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.CancelEvent();
    var tmparra=new Array();
    var tmpobj= new AfterUpdatePrevPopupObjContent(module,"",tmparra);
    var refreshlistmodules = new Array(module);
    //刷新页面，更新页面信息
    tmpobj.eachrefreshlistbyModules(refreshlistmodules);

}