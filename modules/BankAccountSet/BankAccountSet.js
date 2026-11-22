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
                ld('.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
					if(empty(cls_ScopePopup.return_obj.return_id)){
						var confirm_str = arrJsPopLabel['PLEASESELECTLESTONEUSER'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
						return false;
                    }else{
						ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
						 ld("#owners").val(cls_ScopePopup.return_obj.return_id);
					}
                });
            }
			scopepopupobj.setEventBtnCancel=function(){
				 //关闭事件
				ld('#'+cls_ScopePopup.popup_divid+' .D_pop_tit .D_ptitc').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
					return false;
				});
				//取消事件
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').trigger('closediv');
				});
				ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').unbind('closediv').on('closediv',function(){
					if(ld('#'+cls_ScopePopup.popup_divid).length > 0){
						//删除div
						var divobj = ld('#'+cls_ScopePopup.popup_divid).get(0);
						divobj.parentNode.removeChild(divobj);
					}
				});
				return true;
			}
		});
	});
}

function SaveBankAccountSetAccount(obj)
{
    var obj = document.getElementsByName("aa");
    for(var i=0; i<obj.length; i ++){
        if(obj[i].checked){
            var checkstand = obj[i].value;
        }
    }
if(checkstand=="N"){
    var c=0;
    var ld=$$('.StepUserClass').length;
    var d=$$('.StepUserClass');
    /*for(var i=0; i<ld; i ++){
            if(d[i].checked){
              if(d[i].value!=''){
                c++;
              }  
            }
    }*/
    var useridstr = document.getElementById('owners').value;
    if(useridstr==''||useridstr=='-1'){
        var confirm_str = arrJsPopLabel['Pleaseselectatleastoneperson'];
        RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
        docheck();
        return false;
    }
    }
    var form=document.forms['frmPotentialstShare'];
    form.submit();
    return false;
}

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
    $("status").style.display="inline";
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
						$("status").style.display="none";
                       
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
                                $("status").style.display="none";
                                          
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
        $("status").style.display="inline";

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
						$("status").style.display="none";
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
          new Ajax.Request("index.php",
            {
              queue:{
                position:"end",
                scope:"command"
              },
              method:"post",
              postBody:"action=BankAccountConfirm&module=BankAccountSet&record="+stockid+uv,
              onComplete:function (response) {
                     var results = response.responseText.split("&#&#&#");
                if(type == 1)
                      { 
                        if(results[2]!="undefined")
                        {
                        $("ListViewContents").innerHTML= results[2];
                        }
                        else 
                        {
                        $("ListViewContents").innerHTML= "数据错误!";
                        }
                      }
                      else if(type == 2)
                      {
                       window.location.href="index.php?module=BankAccountSet&parenttab=Finacial&action=DetailView&record="+stockid; 
                      }else if(type == 3)
                      {
                        return true;
                      }
                  
              }
            }
          );  
     });
  return false;
}


function PotentialsShare(obj,id)
{
    $("status").style.display="inline";
      new Ajax.Request("index.php",
    	{
    		queue:
            {
    			position:"end",
    			scope:"command"
    		},
    		method:"post",
    		postBody:"module=BankAccountSet&action=BankAccountProfile&id="+id,
    		onComplete:function (response) {
    		    var results=response.responseText.split('##SUCCESS##');
                
                $('divPotentialsShare').innerHTML=results[1];
                
               
                Lay = 'divPotentialsShare';
				var tagName = document.getElementById(Lay);
				var leftSide = findPosX(obj);
				var topSide = findPosY(obj);
				var maxW = tagName.style.width;
                var H = screen.height;  //获取当前分辨率高度
                var W = screen.width;   //获取当前分辨率宽度
              
				var widthM = maxW.substring(0,maxW.length-2);
				var getVal = parseInt(leftSide) + parseInt(widthM);
                //if(getVal  > document.body.clientWidth ){                
				if(topSide < H){
				    /*leftSide = parseInt(leftSide) - parseInt(widthM);
					tagName.style.left = leftSide + 50 + 'px';*/
					tagName.style.top = topSide + 20 + 'px';
                    tagName.style.left = (W-parseInt(widthM))/2 + 'px';
                    //tagName.style.top = topSide - 30 + 'px';                    
				}else{
				    //tagName.style.left = leftSide + 50 + 'px';
                   // tagName.style.top = (topSide - H/2) + 60 + 'px';
					tagName.style.left = (W-parseInt(widthM))/2 + 'px';                    
				}
		
                lingdangJS_DialogBox.block();
				tagName.style.display = 'block';
				tagName.style.visibility = "visible";
                $("status").style.display="none";
              }                
    		
    	});
}