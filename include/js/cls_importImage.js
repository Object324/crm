// ljj 2024-11-6 XUQIU20241023-04 产品可以导入图片（郭良峰）
function cls_importImage(module){
    this.module = module;
    this.popupobj = '';//导入图片第一个弹窗 上传图片
    this.divobj = '';
    this.startIndex = 0;
    this.importImageLength = 0;
    this.progress_popupobj = '';//导入图片第二个弹窗 开始导入图片
    this.progressDivobj = '';

    //后台赋值部分
    this.nameFormatExample = '';//示例
    this.title = '';

    var that = this;

    //赋值
    this.setParams = function (paramobj){
        ld.each(paramobj,function (key,value) {
            if (that.hasOwnProperty(key) && typeof that[key] !== 'function' && !empty(value)) {
                that[key] = value;
            }
        });
    }

    //显示导入图片弹窗
    this.showPopup = function (){
        var url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportImage&mode=showPopup';
        ldAjax(url,'',function (data){
            if (data.code == 1){
                var popupobj = CrmPopup.load(data.result.title,that.startImportImage,'','LdPopWidth800px',that.module,'',data.result.oktext,'',data.result.canceltext);
                popupobj.show(data.result.content);
                that.popupobj = popupobj;
                that.divobj = ld('#'+popupobj.divid);
                var maxheight = popupobj.getPopContentHeight();
                maxheight -= that.divobj.find('#description').get(0).offsetHeight;
                that.divobj.find('#content').css({'max-height':maxheight,'height':maxheight});
                popupobj.center();
                popupobj.importImageArr = {};
                popupobj.importImageAllArr = {};
                popupobj.popuptype = 'importImage';
                that.setParams(data.result);
                that.changeExample();
                that.setEvents();

            }else {
                MessagePopup.TipOne_warning(data.msg);
            }
            DelProgressObjs();
        });

    }

    //绑定事件
    this.setEvents = function (){
        //示例显示
        var nameformatfield = that.divobj.find('#nameformatfield');
        var nameformatexplode = that.divobj.find('#nameformatexplode');
        nameformatfield.off('change').on('change',function () {
            that.changeExample();
        });
        nameformatexplode.off('change').on('change',function () {
            that.changeExample();
        });

        //加载图片上传插件
        that.setUploadEvent();
        //按钮绑定上传
        that.divobj.find('#importImageAddBtn').off('click').on('click',function () {
            that.divobj.find('#importImageHiddenBtn').find('input[name=file]').trigger('click');
        })
        that.divobj.find('#importImageBtn').off('click').on('click',function (event) {
            that.divobj.find('#importImageHiddenBtn').find('input[name=file]').trigger('click');
        })
        //提示
        tooltip(that.divobj.find('[tag=label]'), {transition: true, time: 200});

    }

    //加载上传插件
    this.setUploadEvent = function (){
        var fileuploader = that.divobj.find('#importImageHiddenBtn');
        var uploadFile = new WebUploadFile();
        globalWebUploadType = uploadFile.getScript(globalWebUploadType);
        if(globalWebUploadType === 'local'){
            fileuploader.powerWebUpload({
                // fileTypeDuplicate: 'yes',	//附件类型判断
                // fileNameDuplicate: 'yes',	//同名附件判断
                module: that.module,	//当前模块
                mode: 'importImage',
                uitype: 69,
                allowedit: 'yes',
                dnd: '#importImageAddBtn',
                popupobj : that.popupobj,
                inputFileName : 'importImageHiddenBtn'
            });
        }else if(globalWebUploadType === 'cos'){
            fileuploader.powerWebUploadCos({
                // fileTypeDuplicate: 'yes',	//附件类型判断
                // fileNameDuplicate: 'yes',	//同名附件判断
                module: that.module,	//当前模块
                mode: 'importImage',
                uitype: 69,
                allowedit: 'yes',
                dnd: '#importImageAddBtn',
                popupobj : that.popupobj,
                inputFileName : 'importImageHiddenBtn'
            });
        }
    }

    //示例change
    this.changeExample = function (){
        var nameformatfieldtext = that.divobj.find('#nameformatfield').find('option:selected').text();
        var nameformatexplode = that.divobj.find('#nameformatexplode').val();
        var nameFormatExample = that.nameFormatExample;
        var exampleDivobj = that.divobj.find('#example');
        var example_label = '';
        var tmplabel = nameFormatExample[nameformatexplode];
        example_label += nameformatfieldtext+tmplabel.replace('{Var}',1);
        example_label += '、';
        example_label += nameformatfieldtext+tmplabel.replace('{Var}',2);
        exampleDivobj.html(example_label);
    }

    //开始导入图片第一步
    this.startImportImage = function (){
        var importImageArr = that.popupobj.importImageArr;
        that.importImageLength = Object.keys(importImageArr).length;
        if (empty(that.importImageLength) || that.importImageLength === 0){
            MessagePopup.TipOne_warning(arrJsPopLabel['IMPORTFILECANOTEMPTY']);
            return false;
        }
        console.log(importImageArr);
        var imagefield = that.divobj.find('#imagefield').val();
        var nameformatfield = that.divobj.find('#nameformatfield').val();
        var nameformatexplode = that.divobj.find('#nameformatexplode').val();
        var url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportImage&mode=startImportImage';
        var params = {'importImageArr':JSON.stringify(importImageArr)}
        params.imagefield = imagefield;
        params.nameformatfield = nameformatfield;
        params.nameformatexplode = nameformatexplode;
        ldAjax(url,params,function (data) {
            if (data.code == 1){
                //关闭
                that.popupobj.CancelEvent();
                that.popupobj = '';
                that.divobj = '';
                that.showImportProgressPopup();
            }else {
                MessagePopup.TipOne_warning(data.msg);
            }
            DelProgressObjs();
        })
    }

    this.showImportProgressPopup = function (){
        var html = '<div id="importImage" class="pop_up_content" autofocus="autofocus" style="width:100%;overflow:auto;">';
        html += '<div class="pop_up_content_inner" style="padding-left: 50px">';
        html += '<div class="import_process" id="import_process">';
        html += '<div class="process_bar">';
        html += '<div class="process_now" id="process_now" style="width:0%;"><span class="percent" id="percent"</span></div>';
        html += '</div>';
        html += '<div class="import_info" id="import_info">';
        html += arrJsPopLabel['ImportProgressTip']+'<span class="num"><span class="num"></span></span>';
        html += '</div></div>';
        html += '<span class="num"><span class="num"></span></span>';
        html += '<div class="pop_item" id="pop_item" style="display: none">';
        html += '<div class="pop_info" id="pop_info" style="width:380px;">';
        html += '</div></div></div>';
        var progress_popupobj = CrmPopup.load(that.title,'','','LdPopWidth800px',that.module,'',arrJsPopLabel['FINISHED'],'','');
        progress_popupobj.prevshow();
        progress_popupobj.setParams(that.title,progress_popupobj.CancelEvent,'','LdPopWidth800px',that.module,'',arrJsPopLabel['FINISHED'],'','')
        progress_popupobj.show(html);
        that.progress_popupobj = progress_popupobj;
        that.progressDivobj = ld('#'+progress_popupobj.divid);
        that.startIndex = 0;
        that.ImportImage();
    }

    //开始导入图片
    this.ImportImage = function (){
        var url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportImage&mode=ImportImage';
        var endIndex = that.startIndex+9;
        endIndex = endIndex > that.importImageLength ? parseInt(that.importImageLength)-1 : endIndex;
        var params = {'startIndex':that.startIndex,'endIndex':endIndex};
        ldAjax(url,params,function (data) {
            if (data.code == 1){
                that.progressDivobj.find("#import_info").html(data.result.timeDescription);
                that.progressDivobj.find("#process_now").css("width",data.result.progressPercentage+"%");
                that.progressDivobj.find("#percent").html(data.result.progressPercentage+"%");
                that.startIndex = parseInt(data.result.endIndex)+1;
                console.log(that.startIndex)
                if (that.startIndex > parseInt(that.importImageLength)-1){
                    that.finishImportImage();
                }else {
                    that.ImportImage();
                }
            }
            DelProgressObjs();
        })

    }

    //导入图片结束
    this.finishImportImage = function (){
        var url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportImage&mode=finishImportImage';
        ldAjax(url,'',function (data) {
            if (data.code == 1){
                var tmp_content  = data.result.FixedLabelArr['ImageImportTimeFinishTip1'];
                tmp_content = tmp_content.replace('{Var}',that.importImageLength).replace('{Var}',data.result.successNums)
                var importinfo_content = '<p style="font-weight:bold;">'+tmp_content;
                var errorNums = data.result.errorNums;
                if (errorNums >0){
                    importinfo_content += ',&nbsp;<span style="color:red">';
                    tmp_content  = data.result.FixedLabelArr['ImageImportTimeFinishTip2'];
                    tmp_content = tmp_content.replace('{Var}',data.result.errorNums);
                    importinfo_content += tmp_content;
                    importinfo_content += '</span>';
                }
                importinfo_content += '</p>';
                that.progressDivobj.find('#import_info').html(importinfo_content);
                if (errorNums > 0){
                    var pop_tip_content = '<p class="pop_tip" style="color:red;">'+arrJsPopLabel['ImageImportTimeFinishDownloadTip']+'</p>';
                    pop_tip_content += '<div class="show_attachment_upload" style="width: 618px"><div class="show_attachment_border"><div class="show_attachment_content">';
                    pop_tip_content += '<div style="display: block;" class="uploadifyQueue">';
                    pop_tip_content += '<div class="uploadifyQueueItem bothclear" style="display: flex;padding-bottom: 10px">';
                    pop_tip_content += '<span class="fileClass file_class_excel"></span>';
                    pop_tip_content += '<span class="fileName">'+arrJsPopLabel['ImportImageLog']+'.txt</span>';
                    pop_tip_content += '<span class="fileDownload">';
                    var url = 'index.php?module='+that.module+'&action='+that.module+'Ajax&file=ImportImage&mode=download&time='+data.result.timestr;
                    url= cls_encryptyurl.Puyoung_Encryptyurlhavephp(url,'');
                    pop_tip_content += '<a href="'+url+'" target="_blank">'+arrJsPopLabel['DOWNLOAD']+'</a>'
                    pop_tip_content += '</span>'
                    pop_tip_content += '</div></div>';
                    pop_tip_content += '</div></div></div>';
                    that.progressDivobj.find('#pop_item').css('display','');
                    that.progressDivobj.find('#pop_item').html(pop_tip_content);
                    that.progress_popupobj.center();
                }

            }
            DelProgressObjs();
        });


    }



}