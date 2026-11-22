//快速创建弹出框
function PopupUsers()
{
    
    this.scopepopupobj=undefined;
    var parentshow=this.show;
    var parentcancelevent=this.CancelEvent;
    this.EventBtnOk=undefined;//确定/保存 回调函数
    this.module="Users";
    this.leastchooseone='yes';//是否至少选择一个用户
    this.url="";
    
    this.createBottomHtml=function()
    {
       
        
    }
    var parentsetheadtitle=this.setHeadTitle;
  this.setHeadTitle=function(headtitle)
  {
     parentsetheadtitle.apply(this,[headtitle]);  //调用父类show()函数
  }
  this.leastchooseone=function(leastchooseone)
  {
     this.leastchooseone=leastchooseone;
    
  }
    this.show=function()
    {
        var module=this.module;
        var thatt=this;
   	    getJsScript('include/js/ScopePopup/ScopePopupObj.js',function(){
   	        
    		scopepopupobj =  new ScopePopupObj(module);
           
            thatt.scopepopupobj=scopepopupobj;
          
            scopepopupobj.popup_caption_value = thatt.headtitle;//标题title
           
    		getJsScript('include/js/ScopePopup/ScopePopup.js',function(){
    		  if(thatt.url!="")
               {
                cls_ScopePopup.prop.popup_url=thatt.url;
               }
    		  cls_ScopePopup.prototype.center=function(obj){
    		   
    		      CrmPopup.center( obj);
                   //查询选择:进入焦点时触发
                    var popup_searchvalue = arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER'];
                    ld('#popup_locationdiv').unbind('focus').on('focus',function(){
                     
                        cls_ScopePopup.searchTextFocus('popup_locationdiv',popup_searchvalue);
                    });
                    //查询选择:失去焦点时触发
                    ld('#popup_locationdiv').unbind('blur').on('blur',function(){
                		cls_ScopePopup.searchTextBlur('popup_locationdiv',popup_searchvalue);
                	});
    		  }
    		   cls_ScopePopup.popup_selecttype="user";
               cls_ScopePopup.prop.popup_module = module;//模块
               	scopepopupobj.popup_footer = '<div class="D_pbtn"><div>已选<span name="selectnum">0</span>/<span name="totalnum">77</span></div><div><input class="D_pbtnok" value="'+arrJsPopLabel['CONFIRME']+'" type="button"><span>&nbsp;</span>'+'<input class="D_pbtncancel" value="'+arrJsPopLabel['CANCEL']+'" type="button"></div></div>';
               scopepopupobj.popup_header = '<div class="select-input"><label class="padL0">'+arrJsPopLabel['LBL_SEARCHCHOOSE']+'</label><input type="text" class="ld-input-inner width150 marLR10" id=\'popup_locationdiv\' placeholder=\''+arrJsPopLabel['PLEASEINPUTYOUWANTTOFINDTHEUSER']+'\'></div>';
               cls_ScopePopup.prop.popup_value = '';
              
    		  cls_ScopePopup.prop.popup_value = thatt.selectuserid;
              
    		   scopepopupobj.popupdrag='yes';
               var cls_ScopePopups = new cls_ScopePopup(scopepopupobj);
               cls_ScopePopups.divObj.style.zIndex=CrmPopup.zIndex;
               cls_ScopePopups.divObj.style.display = "block";
               
               
               this.divid=cls_ScopePopups.divObj.id;
                
                ld("#"+this.divid+" [name=popup_title]").attr("id",this.divid+"_head");
                ld("#"+this.divid+" [name=popup_title]").css("cursor","move");
                ld('.D_pbtn .D_pbtnok').val(arrJsPopLabel['CONFIRMED']);
                var that=this;
                this.crmpopuplayerobj=new CrmPopupLayer(this);
                
                this.crmpopuplayerobj.block();
                CrmPopup.zIndex++;
                PopupDrag(this,this.divid);   //弹出层拖拽
              
                
                //加载用户总数和已选的用户数
    			scopepopupobj.setEventLoad=function(){
    			  
    				var selectUseridAll = [];//显示的全部用户数
    				var viewuser_nogroupuser = ld('#viewuser_nogroupuser').prop('checked');
    				//alert(cls_ScopePopup.popup_divid);
    				ld('#'+cls_ScopePopup.popup_divid+' .filetree span').each(function(){
    					var record = ld(this).attr('record');
    					var recordarr = record.split('_');
    					//处理用户图标
    					if('user' == recordarr[0]){
    					  
    						var parentfilter = ld(this).attr('parent');
    						var parentarr = parentfilter.split('_');
    						if('Inactive' != parentarr[1] &&  'Inactive' != parentarr[2]){//因为停用用户不显示，所以在这不进行计算
    							if('nogroup' == parentarr[1]){
    								
    									selectUseridAll[selectUseridAll.length] = recordarr[1];
    							
    							}else{
    								selectUseridAll[selectUseridAll.length] = recordarr[1];
    							}
    						}
    					}
    				});
                   
    				var userAll = js_unique(selectUseridAll);
                    var selectNum=thatt.selectuserid.split(',').length;
    				ld('#'+cls_ScopePopup.popup_divid+" [name=selectnum]").html(selectNum);//已选
    				ld('#'+cls_ScopePopup.popup_divid+" [name=totalnum]").html(userAll.length);//全部
    				ld('#viewuser_nogroupuser').unbind('click').on('click',function(){
    					cls_ScopePopups.noGroupUser('viewuser_nogroupuser');
    					if(!empty(cls_ScopePopup.return_obj.return_id)){
    						var userid = cls_ScopePopup.return_obj.return_id.split(',');
    						selectNum = userid.length;//已选
    					}else{
    						selectNum = 0;
    					}
                        
    					scopepopupobj.setEventLoad();
    				});
    			}
    			//用户选择后的执行事件
    			scopepopupobj.setEventSelGroupByUsers=function(){
    			 
               
    				if(!empty(cls_ScopePopup.return_obj.return_id)){
    					var userid = cls_ScopePopup.return_obj.return_id.split(',');
    					ld('#'+cls_ScopePopup.popup_divid+" [name=selectnum]").html(userid.length);//已选
    			
    				}else{
    				        ld('#'+cls_ScopePopup.popup_divid+" [name=selectnum]").html(0);
    				}
    
    			}
    		    //重写确认按钮事件
                scopepopupobj.setEventBtnOk=function(){
                    ld('.D_pbtn .D_pbtnok').unbind('click').on('click',function(){
                        
    				        //回调
                            if(thatt.EventBtnOk!=undefined)
                                    thatt.EventBtnOk(cls_ScopePopup.return_obj.return_id);
                            else
                            {
                                	ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
                            }
                           // alert(cls_ScopePopup.return_obj.return_id+'aaa');
                    });
                }
                
                //重写取消按钮事件
                scopepopupobj.setEventBtnCancel=function(){
                    //关闭事件
    				ld('#'+cls_ScopePopup.popup_divid+' .E_pop_tit .E_ptitc').unbind('click').on('click',function(){
    					ld('#'+cls_ScopePopup.popup_divid+' .D_pbtn .D_pbtncancel').click();
    					return false;
    				});
                    //取消事件
                    ld('.D_pbtn .D_pbtncancel').unbind('click').on('click',function(){
                       
    					parentcancelevent.apply(that);
                    });
                }
    		});
	   });     
             
    }
   
}
PopupUsers.type='popupusers';
PopupUsers.load=function(selectuserid,HeadTitle)
{
     PopupUsers.prototype=new CrmPopup();  
     PopupUsers.prototype.constructor=PopupUsers;  
    PopupUsers.prototype.selectuserid="";
     PopupUsers.prototype.userlist="";
     PopupUsers.prototype.type=PopupUsers.type;
  
        
     var  PopupUserGroupobj=new PopupUsers();
     PopupUserGroupobj.selectuserid=selectuserid;
     PopupUserGroupobj.setHeadTitle(HeadTitle);
    // PopupUserGroupobj.setParams();
    return PopupUserGroupobj;
    
}
 