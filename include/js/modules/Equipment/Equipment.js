function cls_Equipment(module){
    var that = this;
    this.module = module;
    this.recordid = '';// 单条单据id
    
    // 导出设备码
    this.exportDevicecode = function(position,recordid=''){
        this.recordid = recordid;
        var selected_ids = '';
        var rows_num = 0;
        if(empty(recordid)){
            List_CheckBox_Ids.getIds(module);
            selected_ids = List_CheckBox_Ids.ids;// 列表界面所选单据id
            rows_num = parseInt(List_CheckBox_Ids.num_rows);// 单据数量
            if(rows_num == 1){
                this.recordid = selected_ids;
            }
        }else{
            selected_ids = recordid;
            rows_num = 1;
        }
        
        var surl = 'index.php?module='+this.module+'&action='+this.module+'Ajax&file=ExportDevicecode';
        var params = {'selected_ids': selected_ids};
        ldAjax(surl,params,function (data){
            if(data.code ==1){
                if (data.result.complete == 'yes') {
                    var downLoadUrl = 'index.php?module=uploads&frommodule=' + that.module + '&action=downloadLocalFile&pathfile=' + data.result.zipfile;
                    //zkt 20231013 XUQIU1001341 SQL注入
                    downLoadUrl = cls_encryptyurl.Puyoung_Encryptyurl(downLoadUrl, '');
                    window.location.href = downLoadUrl;
                    resultRemindsMsg(data.result.downLogTitle, "LdPopWidth600px", "", "yes", "yes", data.result.log);
                    if(position == 'listview'){
                        //附件批量下载后刷新列表页
                        var tmparra = new Array();
                        var tmpobj = new AfterUpdatePrevPopupObjContent(that.module, getEmptyValueInfo(), tmparra);
                        var refreshmodules = [];
                        refreshmodules.push(that.module);
                        tmpobj.eachrefreshlistbyModules(refreshmodules);
                    }
                }
            }else{
                MessagePopup.TipOne_warning(data.msg);
            }
            DelProgressObjs();
        })
    }
}