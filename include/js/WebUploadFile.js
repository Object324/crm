//判定走哪种文件上传
var globalWebUploadType = '';
var globalWebUploadParam = {
    Bucket: '',
    Region: ''
};
function WebUploadFile(){
    this.file_fields = new Array();
    this.set_file_fields = function (file_fields){
        this.file_fields = file_fields;
    }
}
WebUploadFile.prototype.getScript = function(webUploadType){
    var that = this;
    if(!webUploadType) {
        webUploadType = that.uploadType();
        if (webUploadType === 'local') {
            //getScriptBackWithURL('include/js/webuploader.js', null);
            AjaxJSPage('webuploader_js','include/js/webuploader.js');
            
        } else if (webUploadType === 'cos') {
           // getScriptBackWithURL('include/js/webuploader/webUploaderCos.js', null);
           AjaxJSPage('webUploaderCos_js','include/js/webuploader/webUploaderCos.js');
        }
    }
    return webUploadType;
}
//获取文件上传方式
WebUploadFile.prototype.uploadType = function(){
    if(!empty(WebUploadFile.staticWebUploadType)){
        var upload_type = WebUploadFile.staticWebUploadType;
    }else{
        var upload_type = '';
        ldAjaxNoProgresssync('index.php?module=Users&action=UsersAjax&file=qcloudEvent&second_action=get_upload_type&ldencrypt=yes','',function (data) {
            if (data.code == 1) {
                if(data.result.encrypt_key_arr){
                    data.result = cls_AESencryptionbykey.Puyoung_Dncryptyvaluearrbyoperation(data.result,true,data.result.encrypt_key_arr);
                }
                upload_type = data.result.upload_type;
                WebUploadFile.staticWebUploadType = upload_type;
                globalWebUploadParam.Bucket = data.result.bucket;
                globalWebUploadParam.Region = data.result.region;
            }
        });
    }

    return upload_type;
}
//触发文件上传绑定事件
WebUploadFile.prototype.setEvent = function(webUploadType,fileuploader,rThat,i){
    var that = this;

    // if (rThat.filejsondata != "" && rThat.filejsondata != undefined)

    //  else
    // var jsondata = "";
    //duan 20231222 设置上传附件的字段信息允许额外设置
    if(this.file_field != undefined && this.file_fields.length>0){
        var fieldobj = this.file_fields[i];
    }else{
        var fieldobj = rThat.fields[i];
    }

    var jsondata = rThat.filejsondata[fieldobj.columnname];

    ld(function () {

        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/21 13:42
        if(webUploadType === 'local'){
            fileuploader.powerWebUpload({
                fileTypeDuplicate: 'yes',	//附件类型判断
                fileNameDuplicate: 'yes',	//同名附件判断
                mode: 'edit',	//当前单据 create or edit
                module: rThat.module,	//当前模块
                jsonData: jsondata,	//edit data
                record: rThat.record,	//单据单据id
                admin: rThat.isadmin,//是否是管理员
                supportformat: "",//支持格式
                uitype: fieldobj.uitype,
                allowedit: fieldobj.allowedit,
                inputFileName: fieldobj.fieldname,	//选择附件后赋值标签的name
                //edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
                pagetype: rThat.pagetype	//页面类型，为了标识小编辑页
            });
        }else if(webUploadType==='cos'){
            fileuploader.powerWebUploadCos({
                fileTypeDuplicate: 'yes',	//附件类型判断
                fileNameDuplicate: 'yes',	//同名附件判断
                mode: 'edit',	//当前单据 create or edit
                module: rThat.module,	//当前模块
                jsonData: jsondata,	//edit data
                record: rThat.record,	//单据单据id
                admin: rThat.isadmin,//是否是管理员
                supportformat: "",//支持格式
                uitype: fieldobj.uitype,
                allowedit: fieldobj.allowedit,
                inputFileName: fieldobj.fieldname,	//选择附件后赋值标签的name
                //edit: xll 2023/10/06 BUG0072908 客户管理（包括但不限于，比如报价单、销售订单等等）数据列表，无法通过快速编辑添加视频附件。
                pagetype: rThat.pagetype	//页面类型，为了标识小编辑页
            });
        }
    });
}

// ls 2022-06-13 【ID1002721】单据分录定制，增加“图片”字段类型(分录)
WebUploadFile.prototype.setDetailEvent= function(webUploadType,fileuploader,rThat,i,rowindex){
    var that = this;

    //若为空表示是新增操作，若当前行undefined表示是编辑页分录新增行
    if (!empty(rThat.detailfilejsondata) && typeof rThat.detailfilejsondata[rowindex] !== 'undefined'){
        var jsondata = rThat.detailfilejsondata[rowindex][rThat.detailimage_arr[i].columnname];
    }else{
        var jsondata = '';
    }
    ld(function () {
        //editor:gyq_169 reason:腾讯云COS文件上传预览   2020/2/21 13:42
        if(webUploadType === 'local'){
            fileuploader.powerWebUpload({
                fileTypeDuplicate: 'yes',	//附件类型判断
                fileNameDuplicate: 'yes',	//同名附件判断
                mode: 'edit',	//当前单据 create or edit
                module: rThat.module,	//当前模块
                jsonData: jsondata,	//edit data
                record: rThat.record,	//单据单据id
                admin: rThat.isadmin,//是否是管理员
                supportformat: "",//支持格式
                uitype: rThat.detailimage_arr[i].uitype,
                allowedit:(rThat.detailimage_arr[i].edit_permission==1?'no':'yes'),
                popupobj:rThat,
                inputFileName: rThat.detailimage_arr[i].fieldname,	//选择附件后赋值标签的name
                isdetails:'yes',
                rowindex:rowindex,
            });
        }else if(webUploadType==='cos'){
            fileuploader.powerWebUploadCos({
                fileTypeDuplicate: 'yes',	//附件类型判断
                fileNameDuplicate: 'yes',	//同名附件判断
                mode: 'edit',	//当前单据 create or edit
                module: rThat.module,	//当前模块
                jsonData: jsondata,	//edit data
                record: rThat.record,	//单据单据id
                admin: rThat.isadmin,//是否是管理员
                supportformat: "",//支持格式
                uitype: rThat.detailimage_arr[i].uitype,
                allowedit:(rThat.detailimage_arr[i].edit_permission==1?'no':'yes'),
                popupobj:rThat,
                inputFileName: rThat.detailimage_arr[i].fieldname,	//选择附件后赋值标签的name
                isdetails:'yes',
                rowindex:rowindex,
            });
        }
    });
}
WebUploadFile.staticWebUploadType = '';

