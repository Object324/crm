//快速创建弹出框
function PopupUserGroup()
{
    
    var parentshow=this.show;
    var parentcancelevent=this.CancelEvent;
    var user_type = 'all';
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
            scopepopupobj.popup_caption_value = "部门设置";//标题title
    		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
    		   cls_ScopePopup.popup_selecttype="group";
               cls_ScopePopup.prop.popup_module = module;//模块
               scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder= \''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEGROUP']+'\' ><input id=\'viewuser_unfoldsubgroup\' type="checkbox" ><label for=\'viewuser_unfoldsubgroup\'>'+arrJsPopLabel['SUBGROUPUNFOLD']+'</label></div>';
               cls_ScopePopup.prop.popup_value = '';
              
    		   cls_ScopePopup.prop.popup_value = thatt.selectuserid;
    		   var popup_url = 'module=Users&action=UsersAjax&file=viewuserinfo&view=private&fld_module=Settings&selecttype=group&popup_inputtype=checkbox';
    		   if(!empty(thatt.user_type) && thatt.user_type != 'all'){
                   popup_url += '&user_type='+thatt.user_type;
               }
               cls_ScopePopup.prop.popup_url = popup_url;
                //ls 20220810 在成员管理->部门设置，点击没有反应(黄祝熊在ScopePopup.js里将弹窗改为可拖动时，divObj对象已经被去掉了)
    		   scopepopupobj.popupdrag='yes';
               var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
               // cls_ScopePopups.divObj.style.zIndex=CrmPopup.zIndex;
               // cls_ScopePopups.divObj.style.display = "block";
               
               //CrmPopup.global_listPopupObj.push(thatt);
               this.divid=cls_ScopePopup.popup_divid;

                ld("#"+this.divid+" [name=popup_title]").attr("id",this.divid+"_head");
                ld("#"+this.divid+" [name=popup_title]").css("cursor","move");
                ld('.D_pbtn .D_pbtnok').val(arrJsPopLabel['CONFIRMED']);
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
                        
    					if(empty(cls_ScopePopup.return_obj.return_id)){
                            var confirm_str = arrJsPopLabel['Pleaseselectatleastonedepartment'];
                            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
    						return false;
                        }else{
                            
                            
                             var urlstring1="index.php?module=Users&action=UsersAjax&file=setGroupUser&grouplist="+cls_ScopePopup.return_obj.return_id+"&type=save";
                             urlstring1+="&userlist="+thatt.userlist;
                                ld.ajax({
                                    url: urlstring1,
                                    type: 'POST',
                                    data:'',
                                   dataType:'json',
                                    async: true,//
                                    timeout: 5000,
                                    success: function(data)
                                    {
                                        if(data.code==1)
                                        {    
                                             $("status").style.display="none";
                                             
                                             ld('#'+cls_ScopePopup.popup_divid+' .E_pbtncancel').click();
                                             //showDefaultCustomView(Op_UserGroup.listparams['CustomViewObj'],"Users","",Op_UserGroup.listparams['viewid']);                   
                                           	var tmparra=new Array();
                                              //tmparra.push(popupobj.record);
                                              var tmpobj= new AfterUpdatePrevPopupObjContent('Users',{},tmparra);
                                                //新增刷新列表
                                                var refreshlistmodules=['Users'];
                                              tmpobj.eachrefreshlistbyModules(refreshlistmodules);
                                            
                                        }
                                        else{
                                                 RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                                            }
                                    }
                                });
    					
    					}
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
PopupUserGroup.type='usergroup';
PopupUserGroup.load=function(selectuserid)
{
     /*PopupUserGroup.prototype=new CrmPopup();
     PopupUserGroup.prototype.constructor=PopupUserGroup;  
    PopupUserGroup.prototype.selectuserid="";
     PopupUserGroup.prototype.userlist="";
     PopupUserGroup.prototype.type=PopupUserGroup.type;*/
  

     var  PopupUserGroupobj=new PopupUserGroup();
     PopupUserGroupobj.selectuserid=selectuserid;
    // PopupUserGroupobj.setParams();
    return PopupUserGroupobj;
    
}
