//快速创建弹出框
function PopupRecoverGroup()
{
    
    var parentshow=this.show;
    var parentcancelevent=this.CancelEvent;
    this.module="Users";
    this.createBottomHtml=function()
    {
       
        
    }
  
    this.show=function()
    {
        var module=this.module;
        var thatt=this;
   	    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
    		scopepopupobj =  new ScopePopupObj(module);
            scopepopupobj.popup_caption_value = "恢复隐藏部门";//标题title
    		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
    		   cls_ScopePopup.popup_selecttype="group";
               cls_ScopePopup.prop.popup_module = module;//模块
               scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\' ><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
               cls_ScopePopup.prop.popup_value = '';
              
    		   cls_ScopePopup.prop.popup_value = thatt.selectuserid;
               cls_ScopePopup.prop.popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module=Settings&selecttype=group&popup_inputtype=checkbox&triggertype='+thatt.triggertype;
                //ls 20220810 在成员管理->部门设置，点击没有反应(黄祝熊在ScopePopup.js里将弹窗改为可拖动时，divObj对象已经被去掉了)
    		   scopepopupobj.popupdrag='yes';
               var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
                cls_ScopePopup.triggertype = thatt.triggertype;
               // cls_ScopePopups.divObj.style.zIndex=CrmPopup.zIndex;
               // cls_ScopePopups.divObj.style.display = "block";

               //CrmPopup.global_listPopupObj.push(thatt);
               this.divid=cls_ScopePopup.popup_divid;

                ld("#"+this.divid+" [name=popup_title]").attr("id",this.divid+"_head");
                ld("#"+this.divid+" [name=popup_title]").css("cursor","move");
                ld('.D_pbtn .D_pbtnok').val(arrJsPopLabel['CONFIRMED']);
                ld('.E_pbtn .E_pbtnok').val(arrJsPopLabel['SAVE']);
                var that=this;
                // this.crmpopuplayerobj=new CrmPopupLayer(this);
                
                // this.crmpopuplayerobj.block();
                CrmPopup.zIndex++;
                PopupDrag(thatt,this.divid);   //弹出层拖拽
    		    //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                  
                  //  var popupobj=CrmPopup.getPopupObj('last');
                   // alert(ld('#'+cls_ScopePopup.popup_divid+' .E_pbtnok').length);
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtnok').unbind('click').on('click',function(){
                        var urlstring1="index.php?module=Users&action=UsersAjax&file=RecoverGroup&grouplist="+cls_ScopePopup.return_obj.return_id+"&type=save";
                        // urlstring1+="&userlist="+thatt.userlist;
                        ldAjaxNoProgress(urlstring1, '', function(data){
                            if(data.code==1)
                            {    
                                 $("status").style.display="none";
                                 
                                 ld('#'+cls_ScopePopup.popup_divid+' .E_pbtncancel').click();
                                showDefaultCustomView("","Users","",0);


                                
                            }
                            else{
                                     RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                            }
                        });
    					
                    });
                }
                
                //重写取消按钮事件
                /*scopepopupobj.setEventBtnCancel=function(){
                    //关闭事件
    				ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
    					ld('#'+cls_ScopePopup.popup_divid+' .E_pbtncancel').click();
    					return false;
    				});
                    //取消事件
                    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtncancel').unbind('click').on('click',function(){
                      
    					parentcancelevent.apply(that);
                    });
                }*/
    		});
	   });     
             
    }
   
}
PopupRecoverGroup.type='usergroup';
PopupRecoverGroup.load=function(selectuserid)
{
    
     PopupRecoverGroup.prototype=new CrmPopup();  
     PopupRecoverGroup.prototype.constructor=PopupRecoverGroup;  
    PopupRecoverGroup.prototype.selectuserid="";
     PopupRecoverGroup.prototype.triggertype="";
     PopupRecoverGroup.prototype.type=PopupRecoverGroup.type;
  

     var  PopupRecoverGroupobj=new PopupRecoverGroup();
     PopupRecoverGroupobj.selectuserid=selectuserid;
    // PopupUserGroupobj.setParams();
    return PopupRecoverGroupobj;
}
