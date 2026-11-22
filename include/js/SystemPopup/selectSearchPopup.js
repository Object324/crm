//选择弹出框
function selectSearchPopup(){
    
   
}
selectSearchPopup.type="selectsearch";
selectSearchPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
     selectSearchPopup.prototype=new CrmPopup();  
     selectSearchPopup.prototype.constructor=selectSearchPopup;  
     selectSearchPopup.prototype.type=selectSearchPopup.type;
     selectSearchPopup.prototype.curmodule=module;//弹出层所在的模块
     selectSearchPopup.prototype.reload_showrelationlistobj=undefined;
     var  selectSearchPopupobj=new selectSearchPopup();
     selectSearchPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,searchmodule,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
     selectSearchPopupobj.isShowFullscreen='yes';
     selectSearchPopupobj.Fullscreencallback = function (switchtotype){
          var divid = selectSearchPopupobj.divid;
          if(selectSearchPopupobj.listresizeobj != undefined){
               selectSearchPopupobj.listresizeobj.setPopupResizeTable_Init(selectSearchPopupobj.module, 'Ajax');
          }
          var fullscreen_obj = ld("#" + selectSearchPopupobj.divid + "_fullscreen");
          var windowHeight = CrmPopup.getClientHeight();
          //弹窗标题固定为50px
          var minusheight=ld('#'+selectSearchPopupobj.divid+'_head').outerHeight(true);
          //查询分类/搜索框/查找按钮
          if(CrmPopup.isExistsObj(selectSearchPopupobj.divid,'basicSearch')){
               minusheight+=CrmPopup.findHtmlobj(selectSearchPopupobj.divid,'basicSearch').height();
          }
          //表格外边距10
          minusheight+=30;
          //表头
          var headerheight = ld("#" + selectSearchPopupobj.divid).find('#resize_header_tableid').height();
          //红字提醒
          var redFont = ld("#" + selectSearchPopupobj.divid).find('#redfont_tip').outerHeight(true);
          var scrolldivobj = ld("#" + selectSearchPopupobj.divid+'_scroll');
          if(switchtotype=="fullscreen"){//全屏
               if(CrmPopup.isExistsObj(selectSearchPopupobj.divid,'popupListViewContents')){
                    CrmPopup.findHtmlobj(selectSearchPopupobj.divid,'popupListViewContents').css('height',windowHeight-minusheight);
                    var listHeight = windowHeight-minusheight-headerheight-redFont-10;
                    CrmPopup.findHtmlobj(selectSearchPopupobj.divid,'resize_content_table_divid').css('max-height',listHeight);
                    scrolldivobj.css('overflow-y','hidden');
                    scrolldivobj.css('max-height','unset');
               }
          }else{//缩小
               scrolldivobj.css('overflow-y','auto');
               if(CrmPopup.isExistsObj(selectSearchPopupobj.divid,'popupListViewContents')){
                    setRelatedListMaxHeight(selectSearchPopupobj);
                    CrmPopup.findHtmlobj(selectSearchPopupobj.divid,'popupListViewContents').css('height','unset');
               }
               selectSearchPopupobj.center();
          }
          //树结构调整高度
          if (ld('#'+divid).find('#isshowPopupModuleListTree') != undefined && ld('#'+divid).find('#isshowPopupModuleListTree').val() == 'yes'&&PopupModuleListTree!=undefined){
               PopupModuleListTree.setHeight();
               if(switchtotype!="fullscreen"){
                    selectSearchPopupobj.center();

               }
          }
     }
    return selectSearchPopupobj;
    
}