function ExportPopup(){ //导出弹出框PopupObj
    var parentshow=this.show;
    this.parentfun_show = parentshow;
    this.show=function()
    {
        var htmlcontent = "<div id='selectpopup_1'> " +
                                "<table class='D_pop_bod' width='100%' cellspacing='1' cellpadding='2' border='0' align='center'>" +
                                "<tr>" +
                                "<td style='padding: 10px;'>" +
                                "<div style='font-size: 16px;margin-bottom: 10px;color: #868686;text-align: center;' id='dvc' >" + arrJsPopLabel['EXPORTINGDATA'] + "</div>" +
                                    "<div id='dv'></div>" +
                                "<div class='progress' style='display:block'>" +
                                    "<div id='dvExportprogress' class='bar'>&nbsp;</div>" +
                                "</div>" +
                                "<div style='margin-top:10px;text-align:left' id='dvctimedescription' ></div>" +
                                "<div class='clear'></div>" +
                                "</td>"
                                "</tr>"
                                "</table>"
                                "</div>"
                                " <div style='height:20px'></div>';"
        parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
    }
    this.update_progress = function (startExportRow, totalRows){
        var width = parseInt(startExportRow / totalRows * 100);
        if (width >= 100) {
            width = 100;
        }
        ld("#dvExportprogress").css("width", width + "%");
    }
}


ExportPopup.type='ExportPopup';
ExportPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
    ExportPopup.prototype=new CrmPopup();
    ExportPopup.prototype.constructor=ExportPopup;
    ExportPopup.prototype.type=ExportPopup.type;
    var  ExportPopupObj=new ExportPopup();
    ExportPopupObj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return ExportPopupObj;

}

