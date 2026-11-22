//列表基本查询
function ListHigherSearchPopup(){
    
       this.divid="";
       
        var parentobj=this;
        this.show=function()
        {
            
            
            var popupobj=CrmPopup.getPopupObj("last");
           if(this.divid=="")
           {
             this.divid="dv_listhighersearch";
           }
        
           
           this.crmpopuplayerobj=new CrmPopupLayer(this);
            this.crmpopuplayerobj.block();
            this.divobj=ld('#'+this.divid);
             this.center();
            var that=this;
            this.setEvent();
             ld(window).resize(function(){
              that.center();
             });
              

             
             CrmPopup.global_listPopupObj.push(this);
             var divObj=this.divobj;
         	
    		divObj.addClass('E_pop_box') ;
            divObj.addClass(this.cssWidth);
    		divObj.css("position","fixed");
            divObj.css("display","block");
    		divObj.css("zIndex",CrmPopup.zIndex);
            CrmPopup.zIndex++;
    		
            
            ld("#"+this.divid).css("-moz-user-select","none");//拖动禁止选中文字
        }
         this.setInnerHtml=function()
       {
        
          /// document.getElementById(this.divid).innerHTML=this.popupheadhtml+this.htmlcontent+this.popupbottomhtml;
          /// document.getElementById(this.divid).style.display="block";
       }
       
    this.CancelEvent=function()
    {

         if(this.crmpopuplayerobj==undefined)
         {
            return ;
         }
           this.crmpopuplayerobj.unblock();
            CrmPopup.zIndex--;
           document.getElementById(this.divid).style.display="none";
          
            var tmpobj=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1];
		
            CrmPopup.global_listPopupObj.pop();//把最后一个对象移除，移除当前弹出层的对象
            for(var i=0;i<CrmPopup.global_signleInstance.length;i++)
            {
                 if(CrmPopup.global_signleInstance[i].type==tmpobj.type)
                 {
					 
                     CrmPopup.global_signleInstance.splice(i,1);
                     break;
                 }
            }
            delete tmpobj;
            
        
    }
}
ListHigherSearchPopup.type="ListHigherSearchPopup";
ListHigherSearchPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
    
     ListHigherSearchPopup.prototype=new CrmPopup();  
     ListHigherSearchPopup.prototype.constructor=ListHigherSearchPopup;  
     ListHigherSearchPopup.prototype.type=ListHigherSearchPopup.type;
     ListHigherSearchPopup.prototype.curmodule=module;//弹出层所在的模块
     
     var  datacategoryobj=new ListHigherSearchPopup();
     datacategoryobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return datacategoryobj;
    
}

ListHigherSearchPopup.loaddivid=function(divid,headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
    
     ListHigherSearchPopup.prototype=new CrmPopup();  
     ListHigherSearchPopup.prototype.constructor=ListHigherSearchPopup;  
     ListHigherSearchPopup.prototype.type=ListHigherSearchPopup.type;
     ListHigherSearchPopup.prototype.curmodule=module;//弹出层所在的模块
     
     var  datacategoryobj=new ListHigherSearchPopup();
     datacategoryobj.divid=divid;
     datacategoryobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return datacategoryobj;
    
}






//