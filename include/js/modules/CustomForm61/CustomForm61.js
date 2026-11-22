// 20230410 百特送货上门模块数据导入到中间表
function listviewBaxterImport(obj, module) {
    var that = this;

    that.baxterImport = function () {
        var crmPopupobj = CrmPopup.load("导入", that.saveBaxterImport, "", "LdPopWidth800px", that.module, "", arrJsPopLabel['SAVE'], "", arrJsPopLabel['CANCEL']);
        // crmPopupobj.prevshow();
        // crmPopupobj.setParams('导入','',"","LdPopWidth800px",that.module,"",'保存',"","取消");

        // crmPopupobj.show('<input type="file" name="baxterImport" id="baxterImport" accept=".csv, .xlsx, .xls">');
        crmPopupobj.show('<div style="height:50px;cursor:pointer;"><input type="file" name="baxterImport" id="baxterImport" accept=".csv, .xlsx, .xls"></div>');

    }

    that.saveBaxterImport = function () {
        // 获取文件名
        // var fileName = ld("#baxterImport").val().split("\\").pop();
        // console.log("上传的文件名为：" + fileName);

        var crmPopupobj = CrmPopup.getPopupObj("last");
        var baxterImport = ld("#" + crmPopupobj.divid + " input[name='baxterImport']").get(0).files[0];
        if (empty(baxterImport)) {
            RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", '请先上传文件');
            return false;
        }
        var urlstring = "index.php?module=CustomForm61&action=CustomForm61Ajax&file=Baxter&mode=import";
        var formData = new FormData();
        formData.append("baxterImport", baxterImport);

        crmPopupobj.CancelEvent();
        ld('#rptContentLoading').show();

        //ldAjax 第二个参数不能放置formData对象
        ld.ajax({
            type: 'POST',
            dataType: 'json',
            data: formData,
            url: urlstring,
            timeout: 0,
            processData: false, // 告诉jquery不要处理数据
            contentType: false, // 告诉jquery不要设置contentType
            success: function (data) {
                // console.log(data);
                ld('#rptContentLoading').hide();
                if (data.code == 1) {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
                } else {
                    RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", data.msg);
                }

                return false;
            },
            error: function (xhr, textStatus, errorThrown) {
                //alert(2);
            }

        })

        /*ldAjax(urlstring,formData,function(data){
                 console.log(data);
                 if (data.code == 1) {
                     RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                 }else{
                     RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                 }
                 DelProgressObjs();

             })*/
    }
    that.saveBaxterImport.funname = 'that.saveBaxterImport';

}

listviewBaxterImport.getInstance = function () {
    if (listviewBaxterImport.Createobj == undefined) {
        listviewBaxterImport.Createobj = new listviewBaxterImport();
    }
    return listviewBaxterImport.Createobj;
}