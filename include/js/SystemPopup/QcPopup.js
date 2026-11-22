//快速创建弹出框
function QcPopup()
{
    
    var parentshow=this.show;
    this.createBottomHtml=function()
    {
       
         if(this.OkText!=""&&this.CancelText!="")
       {
          if(this.refreshpage=='yes')
          {
             this.popupbottomhtml='<div class="D_pbtn" id="'+this.divid+'_popupbottom"> ';
                this.popupbottomhtml+=' <input name="button" id="'+this.divid+'_btnok" class="D_pbtnok" value="'+this.OkText+'" tagClick="'+this.Okfun.funname+'"  type="submit">';
                 this.popupbottomhtml+='<span>&nbsp;</span><input name="button" class="D_pbtncancel" value="'+this.CancelText+'" id="'+this.divid+'_btncancel" type="button">'
                 
                 this.popupbottomhtml+=' </div>';
          }
          else
          {
              this.popupbottomhtml='<div class="D_pbtn" id="'+this.divid+'_popupbottom"> ';
              this.popupbottomhtml+=' <input name="button" id="'+this.divid+'_btnok" class="D_pbtnok" value="'+this.OkText+'" tagClick="'+this.Okfun.funname+'"  type="button">';
              this.popupbottomhtml+='<span>&nbsp;</span><input name="button" class="D_pbtncancel" value="'+this.CancelText+'" id="'+this.divid+'_btncancel" type="button">'
             
              this.popupbottomhtml+=' </div>';
          }
           this.btnokid=this.divid+"_btnok";
          this.btncancelid=this.divid+"_btncancel";
       }
    }
    this.show=function(htmlcontent)
    {
             if(CrmPopup.getPopupObj('last')!=undefined&&CrmPopup.getPopupObj('last').type==selectSearchPopup.type)
             {
               // CrmPopup.getPopupObj('last').CancelEvent();//删除选择框的弹出层
             }
           
             parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
             fielddepend=new FieldDependencies(this.picklistdepency);
  	        fielddepend.setup(CrmPopup.findHtmlobj(this.divid,"QcEditView"));
             if(CrmPopup.global_listPopupObj.length>=2)
             {
                
                 //获取当前快创建的上一层页面，把上一层页面的具有相同name元素赋值给当前弹出层
                var prevpopupobj=CrmPopup.getPopupObj(CrmPopup.global_listPopupObj.length-2);
                var prevdivid=prevpopupobj.divid;
              
                if(prevpopupobj.module==this.module||(this.refreshpage=='yes'))
                {
                    return true;
                }
              
                
                    for(var i=0;i<this.fields.length;i++)
                    {
                         var curr_fieldname=this.fields[i].fieldname; 
                         curr_fieldname=CrmPopup.deletequotation(curr_fieldname);
                         var referencemodule=this.fields[i].referencemodule;
                         if(!CrmPopup.isExistsObj(prevdivid,curr_fieldname))
                         {
                            continue;
                         }
                          
                         //如果当前弹出层的元素在前一个弹出层也出现了，那么就把上一层的值赋值给当前层
                         if(CrmPopup.findHtmlobj(this.divid,curr_fieldname).attr("type")=="text"||
                          CrmPopup.findHtmlobj(this.divid,curr_fieldname).attr("type")=="hidden"  )
                          { 
                            CrmPopup.findHtmlobj(this.divid,curr_fieldname).val(CrmPopup.getHtmlobjval(prevdivid,curr_fieldname));
                            if(referencemodule!='')
                            {
                                CrmPopup.findHtmlobj(this.divid,referencemodule.toLowerCase()+"_name").val(CrmPopup.findHtmlobj(prevdivid,referencemodule.toLowerCase()+"_name").val());
                                
                            }
                          }
                          else if(CrmPopup.findHtmlobj(this.divid,curr_fieldname).attr("type")=='select')
                          {
                            
                          }
                        
                    }
                    
                
                
             }
             
             
    }
   
}
QcPopup.type='qcreate';
QcPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
     QcPopup.prototype=new CrmPopup();  
     QcPopup.prototype.constructor=QcPopup;  
     
     QcPopup.prototype.refreshpage='no';
     
     QcPopup.prototype.type=QcPopup.type;
     QcPopup.prototype.fieldname="";
     QcPopup.prototype.fieldlabel="";
     QcPopup.prototype.fielddatatype="";
     QcPopup.prototype.fields="";
     QcPopup.prototype.picklistdepency=[];

     var  QcPopupobj=new QcPopup();
     QcPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return QcPopupobj;
    
}
 