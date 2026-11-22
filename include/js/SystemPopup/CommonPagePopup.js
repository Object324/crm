function CommonPagePopup()
{
    
}
 //获取当前快创建的上一层页面，把上一层页面的具有相同fieldname元素赋值给当前弹出层
CommonPagePopup.sendprevPageValueToCurpage=function()
{

                 var popupobj=CrmPopup.getPopupObj("last");
                 var prevpopupobj=CrmPopup.getPopupObj("lastprev");

                 if(prevpopupobj==undefined|| prevpopupobj.type!=selectSearchPopup.type)
                 {
                    return ;
                 }
                var prev_prev_popupobj=CrmPopup.getPopupObj(CrmPopup.global_listPopupObj.length-3);//获取快速创建所在的编辑或新增的弹出层界面
                var prev_prevdivid=prev_prev_popupobj.divid;
                prev_prevreferencefields=[];
              //var tmpreferencefieldstr='[{';
                 ld.each(prev_prev_popupobj.fields ,function(index,fieldinfo){
                    //获取创建或编辑的界面所有可以模块的字段
                     if(ld.trim(fieldinfo.referencemodule)!="")
                     {
                        if(prev_prevreferencefields[fieldinfo.referencemodule]!=undefined)
                        {
                           //客户有最终客户
                             prev_prevreferencefields[fieldinfo.referencemodule][1]=fieldinfo;
                        }
                        else
                        {
                           /// prev_prevreferencefields[fieldinfo.referencemodule]=new Array();
                           prev_prevreferencefields[fieldinfo.referencemodule]=[];
                            prev_prevreferencefields[fieldinfo.referencemodule][0]=fieldinfo;
                        }
                     }
                 });
              
                if(prev_prev_popupobj.module==popupobj.module||(popupobj.refreshpage=='yes'))
                {
                    return true;
                }
                   
                    for(var i=0;i<popupobj.fields.length;i++)
                    {
                         var curr_fieldname=popupobj.fields[i].fieldname;
                         var curr_columnname=popupobj.fields[i].columnname;
                         var referencemodule=popupobj.fields[i].referencemodule;
                         
                         if(prev_prevreferencefields[referencemodule]==undefined)
                         {
                           
                            continue;
                         }
                         var prev_prevfieldname='';
                        ld.each(prev_prevreferencefields[referencemodule],function(index,tmpreferencefieldinfo)
                        {
                            prev_prevfieldname=tmpreferencefieldinfo.fieldname;
                            
                            if(curr_fieldname!=prev_prevfieldname)
                                return true;
                           
                            prev_prevfieldname=tmpreferencefieldinfo.fieldname;
                             popupobj.deskvaluearr[curr_fieldname+"_name"] =(CrmPopup.findHtmlobj(prev_prevdivid,prev_prevfieldname+"_name").val());
                             popupobj.deskvaluearr[curr_fieldname]=(CrmPopup.getHtmlobjval(prev_prevdivid,prev_prevfieldname));
                              //如果当前弹出层的元素在前一个弹出层也出现了，那么就把上一层的值赋值给当前层
                             if(CrmPopup.findHtmlobj(popupobj.divid,curr_fieldname).attr("type")=="text"||
                              CrmPopup.findHtmlobj(popupobj.divid,curr_fieldname).attr("type")=="hidden"  )
                              { 
                                CrmPopup.findHtmlobj(popupobj.divid,curr_fieldname).val(CrmPopup.getHtmlobjval(prev_prevdivid,prev_prevfieldname));
                                if(referencemodule!='')
                                {
                                    CrmPopup.findHtmlobj(popupobj.divid,curr_fieldname+"_name").val(CrmPopup.findHtmlobj(prev_prevdivid,prev_prevfieldname+"_name").val());
                                    //231229 wym BUG0077848 创建报价单时，引用销售机会位置快速创建销售机会，没有把“客户类别”“客户类型”带出来，需要再次选择客户名称才能触发引用
                                    var recordid = CrmPopup.getHtmlobjval(prev_prevdivid,prev_prevfieldname);
                                    //zkt 20240729 BUG20240722-77 蒂慕科：日程管理编辑界面，快速创建跟进记录，”客户状态“字段无法带出
                                    getScriptBack('include/js/relatedfield.js', function () {
                                        getRelatedFieldData(popupobj.module, recordid, '', curr_columnname, popupobj.module, 'select');
                                    });
                                }
                              }
                              else if(CrmPopup.findHtmlobj(popupobj.divid,curr_fieldname).attr("type")=='select')
                              {
                                
                              }
                         });
                        
                        
                    }
                    
             
}