//列表基本查询
function ListBasicSearchPopup(){
    /*
    创建弹出层标题栏
    */
    this.createHeadHtml=function()
    {
        this.popupheadhtml='<div class="E_pop_tit" id="'+this.divid+'_head" style="cursor:move">';
        this.popupheadhtml+='<strong class="E_ptita">'+basicfind_label+'</strong>';
        this.popupheadhtml+='<button class="E_ptitc" value="'+arrJsPopLabel['LBL_CLOSE']+'" title="'+arrJsPopLabel['LBL_CLOSE']+'" id="'+this.divid+'_imgclose"/></div>';
    }
    /*
    创建弹出层底部包括按钮
    */
    this.createBottomHtml=function()
    {
        var ok_class = '';
        this.popupbottomhtml='<div class="E_pbtn" id="'+this.divid+'_popupbottom"> ';
        this.popupbottomhtml+=' <input name="button" id="'+this.divid+'_btnok" class="E_pbtnok'+ok_class+'" value="'+this.OkText+'" tagClick="'+this.Okfun.funname+'"  type="button">';
        this.popupbottomhtml+='<span>&nbsp;</span>'
        this.popupbottomhtml+=' </div>';
        this.btnokid=this.divid+"_btnok";
    }
    var parentshow=this.show;
    this.show=function(htmlcontent)
    {
        parentshow.apply(this,[htmlcontent]);
        //zxm BUG0057188   20220928 在基本查找，例如在服务合同模块，先进行一次查找。在第二次查找的时候光标的位置停留在上次查找的最前面，能否改到后面
        var search_text = ld("#"+this.divid+" [name=search_text]").val();
        ld("#"+this.divid+" [name=search_text]").val("").focus().val(search_text);
    }
   
       
  //  this.CancelEvent=function()
//    {
//		  
//         
//         if(this.crmpopuplayerobj==undefined)
//         {
//            return ;
//         }
//           this.crmpopuplayerobj.unblock();
//            CrmPopup.zIndex--;
//           document.getElementById(this.divid).style.display="none";
//          
//            var tmpobj=CrmPopup.global_listPopupObj[CrmPopup.global_listPopupObj.length-1];
//		
//            CrmPopup.global_listPopupObj.pop();//把最后一个对象移除，移除当前弹出层的对象
//            for(var i=0;i<CrmPopup.global_signleInstance.length;i++)
//            {
//                 if(CrmPopup.global_signleInstance[i].type==tmpobj.type)
//                 {
//					 
//                     CrmPopup.global_signleInstance.splice(i,1);
//                     break;
//                 }
//            }
//            delete tmpobj;
//            
//        
//    }
}
ListBasicSearchPopup.type="ListBasicSearchPopup";
ListBasicSearchPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
    
     ListBasicSearchPopup.prototype=new CrmPopup();  
     ListBasicSearchPopup.prototype.constructor=ListBasicSearchPopup;  
     ListBasicSearchPopup.prototype.type=ListBasicSearchPopup.type;
     ListBasicSearchPopup.prototype.curmodule=module;//弹出层所在的模块
     
     var  datacategoryobj=new ListBasicSearchPopup();
     datacategoryobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return datacategoryobj;
    
}








//