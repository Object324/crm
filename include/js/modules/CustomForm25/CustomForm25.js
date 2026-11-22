/* 郎捷：需求
reason:空运订单回传单据分录自动根据选定的“空运订单”带出
*/
function getLangjieModuleRelatedInfo(selectmodule,record){
    var popupobj=CrmPopup.getPopupObj('last');
    if(CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() != undefined  && CrmPopup.findHtmlobj(popupobj.divid,'version_account').val() == 'langjie'){
        var customForm24_id =CrmPopup.findHtmlobj(popupobj.divid,'customform24_id').val();
        if(customForm24_id >= 1){
            var surl = "index.php?module=CustomForm25&action=CustomForm25Ajax&file=getLangjieModuleDetails&record_id="+record+"&selectmodule="+selectmodule;
            ldAjax(surl,"",function(data){
                if(data.code==1){
                    // console.log(data)
                    var popupobj=CrmPopup.getPopupObj("last");
                    rowcnt = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'rowcnt').val());
                    var dataLength =data.result.object_data.length;
                    if(dataLength != 0 && rowcnt>dataLength){
                        for(var i=1;i<=rowcnt;i++){
                            if(i >dataLength){
                                deleteRow(i);
                            }
                        }
                    }

                    for(var i_row=0;i_row <dataLength;i_row++){
                        if(eval(i_row+1) > rowcnt){
                            fnAddTabDetailRow('CustomForm25');
                        }
                        var object_data = data.result.object_data[i_row];
                        for (var columnname in object_data) {
                            var col_value = object_data[columnname];
                            if(CrmPopup.findHtmlobj(popupobj.divid,columnname+eval(i_row+1)).val() != undefined){
                                CrmPopup.findHtmlobj(popupobj.divid,columnname+eval(i_row+1)).val(col_value);
                                CrmPopup.findHtmlobj(popupobj.divid,columnname+eval(i_row+1)).attr('readonly',true);
                                CrmPopup.findHtmlobj(popupobj.divid,columnname+eval(i_row+1)).css('cursor','not-allowed');
                            }
                        }
                    }
                    DelProgressObjs();
                }
            })
        }
    }
}

// 详细页面空运订单回传 禁止编辑
function setDetailTableReadyOnly(){
    var popupobj = CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid+ " .ProductTab.DetailContentTable input").attr('readonly',true);
    ld('#'+popupobj.divid+ " .ProductTab.DetailContentTable input").css('cursor','not-allowed');
    ld('#'+popupobj.divid+ " .ProductTab.DetailContentTable textarea").attr('readonly',true);
    ld('#'+popupobj.divid+ " .ProductTab.DetailContentTable textarea").css('cursor','not-allowed');

    /**
     * 毛重 计费重量货物尺寸 可以编辑
     */
    var rowcnt = ld('#'+popupobj.divid+' [name=rowcnt]').val();
      var trobjs=popupobj.getTrObjsByDelType('no');
    ld.each(trobjs,function(){
        ld(this).find(" [name=sf173]").attr("readonly",true);
        ld(this).find(" [name=sf173]").attr("cursor",auto);
        ld(this).find(" [name=sf174]").attr("readonly",true);
        ld(this).find(" [name=sf174]").attr("cursor",auto);
        ld(this).find(" [name=sf175]").attr("readonly",true);
        ld(this).find(" [name=sf175]").attr("cursor",auto);
    })
    
    /*for (var i=0;i<rowcnt;i++){
        ld('#'+popupobj.divid+ " [name=sf173"+(i+1)+"]").attr('readonly',false);
        ld('#'+popupobj.divid+ " [name=sf173"+(i+1)+"]").css('cursor','auto');
        ld('#'+popupobj.divid+ " [name=sf174"+(i+1)+"]").attr('readonly',false);
        ld('#'+popupobj.divid+ " [name=sf174"+(i+1)+"]").css('cursor','auto');
        ld('#'+popupobj.divid+ " [name=sf175"+(i+1)+"]").attr('readonly',false);
        ld('#'+popupobj.divid+ " [name=sf175"+(i+1)+"]").css('cursor','auto');
    }*/
}


//ls 20230301  XUQIU1001143【百特】不良事件报告模块生成pdf和xml文件
//百特 不良事件模块导出PDF和XML，并上传到亚马逊，支持下载及删除
function baxterCreatePdfAndXml()
{
    var that=this;
    that.popupobj=CrmPopup.getPopupObj('last');//查看界面
    that.createPdfAndXml=function()
    {
        var record=that.popupobj.record;
        var urlstring = "index.php?module=CustomForm25&action=CustomForm25Ajax&file=CreatePdfAndXml&record="+record+"&operatetype=create";

        ldAjax(urlstring,'',function(data){
            //console.log(data);
            if(data.code==1){
                audioRemindsMsg("","LdPopWidth400px","","yes","yes",'生成PDF和XML文件成功');
            }else{
                var confirm_str = data.msg;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
            DelProgressObjs();

            var tmparra=new Array();
            tmparra.push(that.popupobj.record);
            var tmpobj= new AfterUpdatePrevPopupObjContent(that.popupobj.module,"",tmparra);
            tmpobj.eachrefreshDetailViewByModules(new Array(that.popupobj.module));//刷新查看界面

        })
    }

    that.aws_download=function(obj,fileid)
    {
        var urlstring = "index.php?module=CustomForm25&action=CustomForm25Ajax&file=CreatePdfAndXml&operatetype=download&fileid="+fileid;
        window.open(urlstring);// window.location.href=urlstring;
        /*ldAjax(urlstring,'',function(data){
            console.log(data);
            if(data.code==1){
                audioRemindsMsg("","LdPopWidth400px","","yes","yes",'生成PDF和XML文件成功');
            }else{
                var confirm_str = data.msg;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
            DelProgressObjs();
        })*/
    }
    that.aws_delete=function(obj,fileid)
    {
        var urlstring = "index.php?module=CustomForm25&action=CustomForm25Ajax&file=CreatePdfAndXml&operatetype=delete&fileid="+fileid;
        ldAjax(urlstring,'',function(data){
            //console.log(data);
            if(data.code==1){
                audioRemindsMsg("","LdPopWidth400px","","yes","yes",'文件删除成功');
            }else{
                var confirm_str = data.msg;
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
            DelProgressObjs();

            var tmparra=new Array();
            tmparra.push(that.popupobj.record);
            var tmpobj= new AfterUpdatePrevPopupObjContent(that.popupobj.module,"",tmparra);
            tmpobj.eachrefreshDetailViewByModules(new Array(that.popupobj.module));//刷新查看界面
        })
    }

}

baxterCreatePdfAndXml.getInstance=function(){
    if(baxterCreatePdfAndXml.Createobj==undefined){
        baxterCreatePdfAndXml.Createobj=new baxterCreatePdfAndXml();
    }
	return baxterCreatePdfAndXml.Createobj;
}