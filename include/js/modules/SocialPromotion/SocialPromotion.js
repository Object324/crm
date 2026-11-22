function socialCreateNextStep() {
    // h5pageurl的uitype类型不能选择网址 否则系统会自动去去掉http或https  general.js:1313  validateUrl()
    var that = this;
    var popupobj = CrmPopup.getPopupObj("last"),
        module = popupobj.module,
        step = parseInt(CrmPopup.findHtmlobj(popupobj.divid, 'step').val()),
        divs = ld('#' + popupobj.divid + ' .stepContent'),
        multi_step = ld('#' + popupobj.divid + ' .multi-step-soc .step');
    //字段英文和字段中文名称
    var fieldlabel = popupobj.fieldlabel.replace(/'/g, '').split(',');
    var fieldname = popupobj.fieldname.replace(/'/g, '').split(',');
    var activitynameIndex,h5pageurlIndex,sharetitleIndex,shareintroductionIndex,sharepictureIndex;
    ld.each(fieldname, function (i, val) {
        if (val == 'activityname') {
            activitynameIndex = i;
        }
        if (val == 'h5pageurl') {
            h5pageurlIndex = i;
        }
        if(val == 'sharetitle'){
            sharetitleIndex = i;
        }
        if(val == 'shareintroduction'){
            shareintroductionIndex=i;
        }
        if(val == 'sharepicture'){
            sharepictureIndex=i;
        }
    })
    this.swithStep = function () {
        var Social_ue;
        var actintro_textContent = "";
        switch (step) {
            case 1:
                var activitytype = ld('#' + popupobj.divid + ' [name =cmb_span_optiontext_social_activitytype]').val();
                if (activitytype == 'H5页面链接 + 表单') {
                    if (!SaveDataRecord.validate()) {
                        return false;
                    }
                    var h5pageurl = ld('#' + popupobj.divid + ' [name=h5pageurl').val();
                    if (!isURL(h5pageurl)) {
                        audioRemindsMsg("", "", "", "", "", arrJsPopLabel['PLEASEENTERTHECORRECT'] + fieldlabel[h5pageurlIndex]);
                        return false;
                    }
                } else {
                    if (!emptyCheck('activityname', fieldlabel[activitynameIndex], CrmPopup.findHtmlobj(popupobj.divid, 'activityname').attr("type"))) {
                        return false;
                    }
                }
                step++;
                // 显示上一步
                ld('#' + popupobj.divid + '_btnBack').show();
                ld('#' + popupobj.divid + ' [name=step]').val(step);
                
                if (!Social_ue) {
                    Social_ue = popupobj.oCKeditors['activityintroduction'];
                    Social_ue.ready(function() {
                        var id = ld('#activityintroduction').children("div:first-child").attr("id");
                        ld('#'+id).css('z-index','99999');
                        var activityintroduction = Social_ue.getContent();
                        actintro_textContent = extractTextWithSpacing(activityintroduction);
                        ld('#' + popupobj.divid + ' #activityintroduction').val(actintro_textContent); 
                        popupobj.center();
                        function syncContent(){
                            var activityintroduction = Social_ue.getContent();
                            actintro_textContent = extractTextWithSpacing(activityintroduction);
                            ld('#' + popupobj.divid + ' #activityintroduction').val(actintro_textContent); 
                            ld('#' + popupobj.divid + ' #show_activityintroduction').html(activityintroduction);
                        }
                        Social_ue.addListener('keyup', function() {
                            syncContent();
                        })
                        Social_ue.addListener('selectionchange', function() {
                            syncContent();
                        })
                    },2);
                }
                //活动名称复制给活动标题和事实展示的手机
                var activityname = ld('#' + popupobj.divid + ' #activityname').val();
                if(ld('#' + popupobj.divid + ' #activitytitle').val()==''){
                    ld('#' + popupobj.divid + ' #activitytitle').val(activityname);
                }
                ld('#' + popupobj.divid + ' #show_activitytitle').html(ld('#' + popupobj.divid + ' #activitytitle').val());
                 
                bindChangeEvent();
                that.hiddenDiv(step);
                // 重置窗口位置
                popupobj.center();
                that.changStep(step);

                break;
            case 2:
                step++;
                ld('#' + popupobj.divid + ' [name=step]').val(step);

                //把活动名称和介绍赋值
                var activitytitle = ld('#' + popupobj.divid + ' #activitytitle').val();
                var actintro_textContent = ld('#' + popupobj.divid + ' #activityintroduction').val();

                if(activitytitle != ''){
                    if( ld('#' + popupobj.divid + ' #sharetitle').val() == ''){
                        ld('#' + popupobj.divid + ' #sharetitle').val(activitytitle);
                    }
                }
                ld('#' + popupobj.divid + ' #show_sharetitle').html(ld('#' + popupobj.divid + ' #sharetitle').val());

                if(actintro_textContent !=''){
                    if( ld('#' + popupobj.divid + ' textarea#shareintroduction').val() == ''){
                        ld('#' + popupobj.divid + ' textarea#shareintroduction').val(actintro_textContent);
                    }
                }
                var tmp_shareintroduction = ld('#' + popupobj.divid + ' textarea#shareintroduction').val();
                tmp_shareintroduction = tmp_shareintroduction.replace(/\n/g, '<br>');
                ld('#' + popupobj.divid + ' #show_shareintroduction').html(tmp_shareintroduction);


                bindChangeEvent();
                that.hiddenDiv(step);
                // 重置窗口位置
                popupobj.center();
                that.changStep(step);
                //webuploader 上级隐藏导致无法触发，再次触发
                var imgFieldName = 'sharepicture';//再次需要触发的字段
                that.eventWebUpload(imgFieldName);
                //如果有附件图片
                if (popupobj.filejsondata.sharepicture != '' && popupobj.filejsondata.sharepicture != undefined) {
                    editShowPicture(popupobj.filejsondata.sharepicture[0]);
                }
                break;
            case 3:
                step++;
                // @edit:dong @date:2020/07/28 @reason: bug 0042152（表单推广）表单推广新建/编辑界面，分享设置页面，分享主题、分享说明及分享图片需必填
                if(ld('#' + popupobj.divid + ' [name=sharetitle]').val() == ''){
                    audioRemindsMsg("", "", "", "", "", fieldlabel[sharetitleIndex]+arrJsPopLabel['CANOTEMPTY'] );
                    return false;

                }
                if(ld('#' + popupobj.divid + ' [name=shareintroduction]').val() == ''){
                    audioRemindsMsg("", "", "", "", "",fieldlabel[shareintroductionIndex]+ arrJsPopLabel['CANOTEMPTY'] );
                    return false;
                }
                if(ld('#' + popupobj.divid + ' .showPicture img').attr('src') == 'themes/images/socialupload.jpg'){
                    audioRemindsMsg("", "", "", "", "",   fieldlabel[sharepictureIndex]+arrJsPopLabel['CANOTEMPTY']);
                    return false;
                }

                ld('#' + popupobj.divid + ' [name=step]').val(step);
                //保存数据 关闭弹窗
                that.saveCustomField(step);
                // SaveDataRecord.save();
                break;
            default:
                break;
        }
    }
    this.hiddenDiv = function (step) {
        for (var i = 0; i < divs.length; i++) {
            if (step == i + 1) {
                divs.eq(i).show()
            } else {
                divs.eq(i).hide()
            }
        }
    }
    this.changStep = function (step) {
        for (var i = 0; i < multi_step.length; i++) {
            if (step == i + 1) {
                multi_step.eq(i).addClass('current')
            } else if (i + 1 < step) {
                multi_step.eq(i).addClass('completed')
            }else if(i+1>step){
                //所有步骤大于当前步骤的去除class
                multi_step.eq(i).removeClass('completed').removeClass('current')
            }
        }
    }
    //图片字段触发webuploader
    this.eventWebUpload = function (imgFieldName) {
        //获取htmlobj
        var fileuploader = CrmPopup.findHtmlobj(popupobj.divid, imgFieldName);
        ld('#' + popupobj.divid + ' [name=' + imgFieldName + ']').html('');//把初始化加载的内容删除
        var uploadFile = new WebUploadFile();
        var globalWebUploadType = uploadFile.getScript(globalWebUploadType);
        var index = 0;
        //获取触发字段再fields中的下标
        ld.each(that.fields, function (i, value) {
            if (value['fieldname'] == imgFieldName) {
                index = i;
            }
        })
        uploadFile.setEvent(globalWebUploadType, fileuploader, that, index);
        //隐藏上传按钮
        ld('#' + popupobj.divid + ' [name=sharepicture] div').eq(0).height(0);
        ld('#' + popupobj.divid + ' [name=sharepicture] div').eq(0).css('overflow', 'hidden');
        //为img添加点击事件
        sharePictureBindUpload(popupobj, 'bind');
    }
    //保存保单数据
    this.saveCustomField = function (step) {
        var record = CrmPopup.getHtmlobjval(popupobj.divid, 'record');
        var formValues = ld('#' + popupobj.divid + ' [name=EditView]').serialize();

        formValues = formValues.slice(formValues.indexOf('socialpromotion_no'));

        var fullUrl = window.location.href;  // 获取完整的URL
        var indexPosition = fullUrl.indexOf('index.php');  // 获取'index.php'的位置
        if (indexPosition !== -1) {
            var resultUrl = fullUrl.substring(0, indexPosition);
            resultUrl = resultUrl.replace(/:/g, '%3A').replace(/\//g, '%2F');//转换成url编码
        }
        formValues = updateImageSrc(formValues,resultUrl);//对表单数据中的src路径做处理
        formValues = updateHref(formValues,resultUrl);//对表单数据中附件的href路径做处理

        var ajaxurl = 'index.php?module=SocialPromotion&action=SocialPromotionAjax&file=Save&refreshpage=no';
        if (record != undefined && record != '') {
            ajaxurl += '&record=' + record;
        }
        ldAjax(ajaxurl, formValues, function (data) {
            //返回数据 刷新列表页和详细页
            popupobj.record = data.result.fieldvalue.maintable_id;//保存的单据ID

            var tmparra = new Array();
            tmparra.push(popupobj.record);
            var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data, tmparra);
            var refreshlistmodules = data.result.refreshlistmodules;
            refreshlistmodules.push(popupobj.module);
            tmpobj.eachrefreshlistbyModules(refreshlistmodules);
            tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
            //发起请求生成二维码 第四步
            // popupobj.CancelEvent();
            // 生成外部访问静态单据页面
            that.createHtml(popupobj.record, data.result.form);
            if (data.result.form == 1) {
                that.createHtml(popupobj.record, 0);
            }
            //获取第四步内容 生成二维码

            that.lastStepFunction(step, popupobj.record, data.result.shareUsers, data.result.socialpromotion_no);

        })

    }
    // 生成html
    this.createHtml=function(record,form){
        var url='index.php?module=SocialPromotion&action=SocialPromotionAjax&file=SocialPromotionCreateHtml&record='+record+'&form='+form;
        ld.ajax({
            url: url,
            type: 'POST',
            data:'',
            dataType:'json',
            async: true,//
            timeout: 5000,
            success: function(data)
            {
                //console.log(data)
            }
        })
    }
    //第三步保存第四步生成二维码
    this.lastStepFunction=function(step,recordId,shareUsers,socialpromotion_no) {
        var lastthat = this;
       
        var ajaxurl = 'index.php?module=SocialPromotion&action=SocialPromotionAjax&file=EditViewLastStep&step='+step+'&recordId='+recordId+'&shareUsers='+shareUsers+'&socialpromotion_no='+socialpromotion_no;
        ldAjax(ajaxurl,{},function(data){
            // // 重载内容
            ld("#"+popupobj.divid+" .dvpopupsroll").html(data.result.content);
            //隐藏上一步 和取消按钮按钮 并绑定关闭事件
            ld('#'+popupobj.divid+'_btnok').val(data.result.oktext).unbind('click').bind('click',function () {
                lastthat.clickOktext();
            }); //data.result.oktext=完成
            ld('#'+popupobj.divid+'_btnBack').hide();
            ld('#'+popupobj.divid+'_btncancel').hide();
        })
        this.clickOktext=function(){
            //获取最近的弹出层 关闭
            // var temppopupobj= CrmPopup.getPopupObj('last');
            popupobj.CancelEvent();
        }

    }

    this.swithStep();
}

/**
* @edit:dong
* @data:2020/07/13
* @reason:上一步
* @description:
*/
function socialCreateBackStep() {
    var that =this;
    var popupobj = CrmPopup.getPopupObj("last"),
        module = popupobj.module,
        step = parseInt(CrmPopup.findHtmlobj(popupobj.divid,'step').val()),
        divs = ld('#'+popupobj.divid+ ' .stepContent'),
        multi_step =ld('#'+popupobj.divid+ ' .multi-step-soc .step');

    step--;
    // @edit:dong @date:2020/07/13 @reason: 如果是第一步隐藏上一步按钮
    if(step==1){
        ld('#'+popupobj.divid+ '_btnBack').hide();
    }
    // 赋值step
    ld('#'+popupobj.divid+' [name=step]').val(step);

    // 隐藏div 切换步骤
    this.hiddenDiv = function (step) {
        for (var i=0;i<divs.length;i++){
            if(step ==i+1){
                divs.eq(i).show()
            }else {
                divs.eq(i).hide()
            }
        }
    }
    this.changStep =function (step) {
        for (var i=0;i<multi_step.length;i++){
            if(step ==i+1){
                multi_step.eq(i).addClass('current')
            }else if(i+1<step) {
                multi_step.eq(i).addClass('completed')
            }else if(i+1>step){
                //所有步骤大于当前步骤的去除class
                multi_step.eq(i).removeClass('completed').removeClass('current')
            }
        }
    }
    this.hiddenDiv(step);
    this.changStep(step);
    popupobj.center();

}

/**
 * 为第三步图片添加/删除上传事件。
 * @param popupobj
 * @param type
 */
function  sharePictureBindUpload(popupobj,type){
    type = type||'unbind';
    if(type == 'bind'){
        ld('#'+popupobj.divid+' .showPicture img').unbind('click').bind('click',function () {
            //模拟点击事件
            ld('#'+popupobj.divid+' [name=sharepicture] input[name=file]').click();
        })
    }else{
        ld('#'+popupobj.divid+' .showPicture img').unbind('click');
    }

}


/**
 * 选择颜色
 * @param css_type
 */
function socialSetColpick(css_type){
    ld('#rptContentLoading').show();
    var surl='module=Settings&action=SettingsAjax&file=SelectColppick&css_type='+css_type;
    var popupobj=CrmPopup.getPopupObj("last");
    var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'SocialPromotion',"","","","");
    var divid = popupobj.divid;
    var _css_type = CrmPopup.findHtmlobj(divid,css_type).val();
    crmPopupobj.prevshow();
    ld.ajax({
        url: 'index.php?'+surl,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,
        success: function(data)
        {
            if(data.code==1)
            {
                //approvereminds:是一个非常重要变量，变量内容包括了审批提醒的显示内容
                //EditApproveStep.tpl文件中methodtaggroup非常重要，每一个html元素的命名都是以methodtaggroup开始
                ld('#rptContentLoading').hide();
                crmPopupobj.setParams(data.result.title,'',"","LdPopWidth350px",'Settings',"",'',"",'');
                crmPopupobj.show(data.result.content);
                var _color = '';
                var divid = crmPopupobj.divid;
                CrmPopup.findHtmlobj(divid,'picker').colpick({
                    color:_css_type,
                    flat:true,
                    layout:'RGB',
                    submitText:'确认',
                    onSubmit:function(hsb,hex,rgb,el){//ok之后的确认事件
                         _color = '#'+hex;
                        var popupobj=CrmPopup.getPopupObj("lastprev");
                        var prev_divid=popupobj.divid;
                        CrmPopup.findHtmlobj(prev_divid,css_type).val(_color);
                        CrmPopup.findHtmlobj(prev_divid,'div_'+css_type).css('background',_color);
                        // @edit:dong @date:2020/08/04 @reason:  同步颜色
                        if(css_type == 'buttoncolor'){
                            ld('#'+prev_divid+' .preview #show_buttonname').css('background',_color);
                        }
                        if(css_type == 'formheadcolor'){
                            ld('#'+prev_divid+' .preview .phone-content-header').css('background',_color);
                        }
                        crmPopupobj.CancelEvent();
                    }
                });
            }
        }
    })
}
//h5页面帮助
function activityH5PageHelp() {
    // index.php?module=Accounts&action=AccountsAjax&file=ListViewReportAjax
    var that=this;
    var popupobj=CrmPopup.getPopupObj("last");
    var ajaxurl = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=H5PageHelp';
    ldAjax(ajaxurl,{},function(data){
        var popupobj=  CrmPopup.load(data.result.title,that.clickOktext,"",1200,module,"",data.result.oktext,"",'');
        CrmPopup.setPopupobjHtmlContent_scroll(popupobj,data.result.content);
        DelProgressObjs();
    })
    that.clickOktext=function(){
        var temppopupobj=CrmPopup.getPopupObj("last");
        temppopupobj.CancelEvent();
    }

}

//判断是否是https://
function isURL(url) {
    var strRegex = /(https):\/\/([\w.]+\/?)\S*/;
    var re = new RegExp(strRegex);
    return re.test(url);
}

//绑定自定义字段的事件
function bindChangeEvent(){
    var popupobj = CrmPopup.getPopupObj('last'),
        step = CrmPopup.getHtmlobjval(popupobj.divid,'step');
    if(step ==2 ){
        // 自定义字段同步修改
        ld('#'+popupobj.divid+' #step2 #mainFields .inputValue').unbind('keyup').bind('keyup',function () {
            leftInputValueChange(popupobj,this);
        });
        // 非自定义字段同步修改
        // @edit:dong @date:2020/08/19 @reason: bug 实时预览里面的输入也会改变字段名
        ld('#'+popupobj.divid+' #step2  #coustomPage .detailedViewTextBox').not("#activityintroduction").unbind('keyup').bind('keyup',function () {
            leftInputValueChange(popupobj,this);
        });
        // 排序和删除
        ld('#step2 #mainFields tr').find('td[name=td_operation]').unbind('click').bind('click',function (e) {
            fieldOperation(popupobj,e);
        })
        // 同步必选
        ld('#step2 #mainFields tr').find('td[name=td_required] input[type=checkbox]').change(function () {
            leftRequiredChange(popupobj,this);
        })
    }
    if(step ==3){
        ld('#'+popupobj.divid+' .DetailContentTable .detailedViewTextBox').unbind('keyup').bind('keyup',function () {
            leftInputValueChange(popupobj,this);
        });
    }
}
//左侧必填同步
function leftRequiredChange(popupobj,obj){
    var columnname = ld(obj).attr('columnname');
    if(ld(obj).is(':checked')){
        ld('#'+popupobj.divid+' #show_r_'+columnname).show()
    }else{
        ld('#'+popupobj.divid+' #show_r_'+columnname).hide()
    }

}
// 自定义字段值改变
function leftInputValueChange(popupobj,obj){
    var value = ld(obj).val();
    value = value.replace(/\n/g, '<br>');
    var field = ld(obj).attr('columnname')
    if(field ==undefined){
        field =ld(obj).attr('name')
    }
    ld('#'+popupobj.divid+' .preview #show_'+field).html(value);
}

// 自定义字段排序和删除
function fieldOperation(popupobj,e){
    var trs = ld('#'+popupobj.divid+ ' #mainFields tr');
    var target = e.target;
    var tr = ld(target).parent().parent();
    var index = trs.index(tr);
    var divs = ld('#'+popupobj.divid+' .preview  #mainFieldsIphone div');
    if (ld(target).attr('name') == 'moveUp') {
        trs.eq(index).insertBefore(trs.eq(index - 1));
        divs.eq(index).insertBefore(divs.eq(index - 1));
    } else if (ld(target).attr('name') == 'moveDown') {
        trs.eq(index).insertAfter(trs.eq(index + 1));
        divs.eq(index).insertAfter(divs.eq(index + 1));
    } else if (ld(target).attr('name') == 'delete') {
        trs.eq(index).remove();
        divs.eq(index).remove();
        var customFieldsNum = ld('#'+popupobj.divid+ ' #mainFields [name=customFieldsNum]').val();
        ld('#'+popupobj.divid+ ' #mainFields [name=customFieldsNum]').val(parseInt(customFieldsNum)-1);
    }
    //zkt 0046985: https://81mis.com/kfbcrm/ [^]，表单推广——新建——定制活动页面——系统字段中最顶的字段下移后不出现上移箭头，最底下的字段上移后也不出现下移箭头
    var trs = ld('#'+popupobj.divid+ ' #mainFields tr');
    trs.eq(0).find(' span[name=moveUp]').css('display','none');
    trs.eq(1).find(' span[name=moveUp]').css('display','');
    //设置所有input的name值的排序
    var trs = ld('#'+popupobj.divid+ ' #mainFields tr');
    for (var i=0;i<trs.length;i++){
        var input = trs.eq(i).find('input');
        for(var j=0;j<input.length;j++){
            var nameValue = input.eq(j).attr('name');
            // @edit:dong @date:2020/07/14 @reason: 修复数值计算错误
            var array = nameValue.split('_');
            array[2] = i+1;
            input.eq(j).attr('name',array.join('_'));
        }
    }
}

/**
 * 图片上传展示
 * @param response
 */
function showPicture(response){
    var popupobj =CrmPopup.getPopupObj('last');
    var imgPath='';
// @edit:dong @date:2020/07/13 @reason:  判断上传类型是local还是cos 获取的图片地址
    if(globalWebUploadType == 'local'){
        imgPath= response.filePaht.substr(3)+response.newfile_name;
    }else{
        imgPath = response.Location;
        if(imgPath.indexOf('http')>-1){

        }else{
            imgPath = 'http://'+response.Location;
        }
    }

    if (imgPath.indexOf('http://https://') === 0) {
        tmp_url = 'http://https://';
        imgPath = 'http://' + imgPath.slice(tmp_url.length);
    }
    ld('#'+popupobj.divid+' .showPicture img').attr('src',imgPath);
    ld('#'+popupobj.divid+' #show_sharepicture').attr('src',imgPath);
    ld('#'+popupobj.divid).find('.webuploader-pick').parent('span').hide();
    imgDeleteEvent()
    //为img解绑点击事件
    sharePictureBindUpload(popupobj,'unbind');
}

/**
 * 已上传图片展示图片
 * @param sharepicture
 */
function editShowPicture(sharepicture) {
    var popupobj =CrmPopup.getPopupObj('last');
    var imgPath = '';
    if(sharepicture.storage_location == 'local'){
        imgPath = sharepicture.filepath_noEncrpt;
    }else{
        imgPath = sharepicture.filepath_noEncrpt;
        if(imgPath.indexOf('http')>-1){

        }else{
            imgPath = 'http://'+sharepicture.filepath_noEncrpt;
        }
    }
    if (imgPath.indexOf('http://https://') === 0) {
        tmp_url = 'http://https://';
        imgPath = 'http://' + imgPath.slice(tmp_url.length);
    }
    ld('#'+popupobj.divid+' .showPicture img').attr('src',imgPath);
    ld('#'+popupobj.divid+' #show_sharepicture').attr('src',imgPath);
    //为img解绑点击事件
    sharePictureBindUpload(popupobj,'unbind');
    setTimeout(function(){
        imgDeleteEvent();
        //为img添加点击事件
        ld('#'+popupobj.divid).find('.webuploader-pick').parent('span').hide();
    }, 300);
}
function imgDeleteEvent() {
    var popupobj =CrmPopup.getPopupObj('last');
    //给附件删除按钮添加点击事件
    ld('#'+popupobj.divid +' .uploader-list .webuploadDelbtn').bind('click',function () {
        ld('#'+popupobj.divid+' .showPicture img').attr('src','themes/images/socialupload.jpg');
        ld('#'+popupobj.divid+' #show_sharepicture').attr('src','themes/images/ldcrm100100.jpg');
        //为img绑定点击事件
        sharePictureBindUpload(popupobj,'bind');
        ld('#'+popupobj.divid).find('.webuploader-pick').parent('span').show();
    })
}
/**
 * 下载图片
 * @param obj
 */
function downloadImg(obj){
    var popupobj =CrmPopup.getPopupObj('last');
    var module = popupobj.module;
    var imgUrl = ld(obj).attr('imgUrl');
    var openUrl = 'index.php?module=uploads&frommodule='+module+'&action=downloadSocialPromotionQrcode&pathfile='+encodeURI(site_URL+'/'+imgUrl);
    window.open(openUrl);

}
// 发起请求获取自定义字段html
function getCustomFieldHtml(mappingmodule,record,type) {
    var popupobj =CrmPopup.getPopupObj('last');
    var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=getCustomFieldHtml&type='+type+'&mappingModule='+encodeURI(mappingmodule);
    if(record != '' && record != undefined){
        url +='&record='+record;
    }
    ld.ajax({
        url: url,
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 5000,
        success:function(data){
            if(data.code ==1){
                ld('#'+popupobj.divid +' #mainFields').html(data.result.content);
                ld('#'+popupobj.divid +' #mainFieldsIphone').html(data.result.contentIphone);
            }
        }
    })

}
//BUG0072440 xxy 2023-9-26 表单推广模块，新建单据后（活动说明字段添加图片），手机扫码二维码，不显示图片
function updateImageSrc(data,resultUrl) {// 将表单数据中的src相对路径改为绝对路径
    var regex = /src%3D%22(.*?)%22/g;
    return data.replace(regex, function(match, p1) {
        if (p1.startsWith(resultUrl)) {
            return match;  // 如果是，返回原始匹配，不做更改
        } else {
            return 'src%3D%22' + resultUrl + p1 + '%22';  // 更新 src 属性的值
        }
    });
}
//BUG0072708 xxy 2023-9-26 表单推广-新建，定制活动页面，上传视频，在编辑界面可以打开。复制链接在PC端，或这扫描二维码在移动端均无法打开
function updateHref(data,resultUrl) {// 将表单数据中的href相对路径改为绝对路径
    var regex = /href%3D%22(.*?)%22/g;
    return data.replace(regex, function(match, p1) {
        if (p1.startsWith(resultUrl)||p1.startsWith('http')) {
            return match;  // 如果是，返回原始匹配，不做更改
        } else {
            return 'href%3D%22' + resultUrl + p1 + '%22';  // 更新 href 属性的值
        }
    });
}
//根据获取的html获取text并做换行空格处理
function extractTextWithSpacing(htmlContent) {
    var textWithSpacing = "";
    var tempDiv = ld('<div>').html(htmlContent);
    
    tempDiv.contents().each(function() {
        if (this.nodeType === 3) {  // 文本节点
            textWithSpacing += this.nodeValue.trim();
        } else if (this.nodeType === 1) {  // 元素节点
            var element = ld(this);
            var elementText = element.text().trim();
            if (!elementText) return;  // 如果标签内容为空，则跳过
            switch (this.tagName.toLowerCase()) {
                case 'p':
                case 'div':
                case 'br':
                    textWithSpacing += element.text() + "\n";  // 对于<p>, <div>, 和<br>添加换行符
                    break;
                case 'span':
                    textWithSpacing += element.text() + " ";  // 对于<span>，添加空格
                    break;
                default:
                    textWithSpacing += element.text();
                    break;
            }
        }
    });
    return textWithSpacing;
}
/**
* user:dong
* data:2020/7/1
* desc:添加自定义字段
*/
function getCustomField(){
    var that =this;
    var popupobj = CrmPopup.getPopupObj('last');
    var inputs = ld('#' + popupobj.divid + ' #coustomPage input.inputValue');
    var usedFields ='';
    ld.each(inputs,function (i,val) {
        usedFields += ld(val).attr('columnname')+';';
    })
    var mappingModule = ld('#'+popupobj.divid+' [name=mappingmodule]').val();

    var Popupobj=CrmPopup.load("","","","LdPopWidth600px",popupobj.module,"","","","");
    Popupobj.prevshow();

    var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=getCustomField';
    ldAjax(url,{usedFields:usedFields,mappingModule:mappingModule},function(data){
        if(data.code==1)
        {
            //触发操作函数（显示字段，设置必填项）
            Popupobj.setParams(data.result.title,that.triggerAddCustomField,"","LdPopWidth600px",popupobj.module,"",data.result.oktext,"",data.result.canceltext);
            CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);

            ld("#"+Popupobj.divid+" .selectfields").select2({closeOnSelect: true,
                dropdownParent:ld("#"+Popupobj.divid)});
            ld("#"+Popupobj.divid+" .select2").css('width',"90%");

        }
    })

    // 获取添加字段的html
    this.triggerAddCustomField =function()
    {
        var prevpopupobj=CrmPopup.getPopupObj('lastprev');
        var prevdivid=prevpopupobj.divid;
        var customFieldsNum = ld('#'+prevdivid+' [name=customFieldsNum]').val();
        var popupobj=CrmPopup.getPopupObj('last');
        var divid=popupobj.divid;
        var selectdatas=  ld("#"+divid+" .selectfields").select2('data');
        popupobj.CancelEvent();
        if(selectdatas.length<=0)
        {
            return ;
        }
        var usedFields='';
        ld.each(selectdatas,function(index,info){
            var columnname=info.id;
            usedFields +=columnname+';';
        })
        var url = 'index.php?module='+popupobj.module+'&action='+popupobj.module+'Ajax&file=getCustomFieldHtml&type=add';
        ldAjax(url,{usedFields:usedFields,mappingModule:mappingModule,customFieldsNum:customFieldsNum},function(data){
            if(data.code==1)
            {
                ld('#'+prevdivid+' #mainFields').append(data.result.content);
                ld('#'+prevdivid+' #mainFieldsIphone').append(data.result.contentIphone);
                //设置自定字段的总数的值
                ld('#'+prevdivid+'  #mainFields [name=customFieldsNum]').val(data.result.customFieldsNum)
                //重新绑定所有事件
                bindChangeEvent();
            }
        })
    }
}

// 新建流程第三步 共享弹窗的完成按钮事件重写
function reWriteEventBtnOk(cls_ScopePopup) {

    ld('#'+cls_ScopePopup.popup_divid+' .E_pbtn .E_pbtnok').on('click',function() {
        var selected_user = cls_ScopePopup.return_obj.return_id;
        if (selected_user <= 0) {
            RemindsMsg('', "LdPopWidth400px", "", "yes", "yes", arrJsPopLabel['PLEASESELECTLESTONEUSER']);
            return false;
        }
        //取消按钮事件，隐藏用户选择界面
        ld('#' + cls_ScopePopup.popup_divid + ' .E_pbtn .E_pbtncancel').click();
        var popupobj = CrmPopup.getPopupObj('last');//编辑页
        ld('#' + popupobj.divid + ' [name=newShareUsers]').val(selected_user);
    })
}

// 新建流程第三步 清楚隐藏共享用户id
function clearHiddenShareUserValue() {
    var popupobj = CrmPopup.getPopupObj('last');
    ld('#'+popupobj.divid+' [name=newShareUsers]').val('');
}

/**
 * 社交推广 详细页 共享后刷新详细页
 * @param rIds
 */
function  afterDetailShareEvent(rIds) {
    var popupobj = CrmPopup.getPopupObj('last');
    var tmparra=new Array();
    tmparra.push(rIds);
    var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,'',tmparra);
    var refreshlistmodules=[];
    refreshlistmodules.push(popupobj.module);
    tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
}
/**
* @edit:dong
* @data:2020/07/13
* @reason: 弹出层buttonhtml生成
* @description:
*/
function socialCreateBtnHtml(popupobj,data) {
    var html = '';
    html='<div class="E_pbtn" id="'+popupobj.divid+'_popupbottom"> ';
    html+=' <input name="button" id="'+popupobj.divid+'_btnBack" class="E_pbtnok ld-button ld-button-primary" value="'+data.result.backStep+'" tagClick=""  type="button">';
    html+=' <span>&nbsp;</span><input name="button" id="'+popupobj.divid+'_btnok" class="E_pbtnok ld-button ld-button-primary" value="'+popupobj.OkText+'" tagClick=""  type="button">';
    html+='<span>&nbsp;</span><input name="button" class="E_pbtncancel ld-button" value="'+popupobj.CancelText+'" id="'+popupobj.divid+'_btncancel" type="button">'
    html+=' </div>';
    return html;
}

/**
 * 统计图标  里面的设置时间
 * @param obj
 * @param type
 * @param day1
 * @param day2
 */
function socialchangedaytime(obj,type,day1,day2){
    document.getElementById('startmonth').value=day1+' '+'-'+' '+day2;
    ld('#startmonth').daterangepicker(null, function(start, end, label) {
    });

    ld('#OftenUseReport_search_date a').each(function(){
        if(ld(this).attr('id') == type){
            ld(this).attr('class','onselected_A changeday');
        }else{
            ld(this).attr('class','changeday');
        }
    });
    if(ld('#daterangepicker_search') != undefined){
        ld('#daterangepicker_search').attr('class','changeday')
    }
    
}
// 获取当前查询条件的表单推广的统计报表的html
function getReportContentHtml(obj,formname) {
    var popupobj = CrmPopup.getPopupObj('last');
    var record = ld('#'+popupobj.divid+' [name=return_id]').val();
    var param = ld('#'+popupobj.divid+' form[name='+formname+']').serialize();
    var url = 'index.php?module='+popupobj.headermodule+'&action='+popupobj.headermodule+'Ajax&file=getReportContentHtml';

    ldAjax(url,param+'&record='+record,function (data) {
        if(data.code ==1){
            //获取内容 替换div html
            ld('#'+popupobj.divid+' #UseReportList').html(data.result.content)
            ld('#rptContentLoading').hide();
        }
    })

}
//wym XUQIU1002093 表单推广的映射模块，客户/销售线索的签到统计界面需要增加一个导出功能（刘明）
function ExportSocialPromotion(record){
    var surl='index.php?module=SocialPromotion&action=SocialPromotionAjax&file=ExportSocialPromotionSign&record='+record+'&export_style=firstcolheader';
    surl+='&getprogress=yes';
    ldAjax(surl,'',function(data){
        if(data.code==1){
            var listcount = data.result.listcount;
            if (listcount > 2000 && listcount < 5000) {
                var eachexportcount = 100;
            } else if (listcount >= 5000) {
                var eachexportcount = 200;
            } else {
                var eachexportcount = 20;
            }
            //第二次导出，将结束行作为下一次的起始行，结束行加每次导出行数作为下一次的结束行。
            DownloadSocialPromotion(record,data.result.endexportrow,eachexportcount);
        }
    });
}

function DownloadSocialPromotion(record,startexportrow,eachexportcount){
    var surl='index.php?module=SocialPromotion&action=SocialPromotionAjax&file=ExportSocialPromotionSign&record='+record+'&export_style=firstcolheader';
    surl += "&startexportrow=" + startexportrow + "&eachexportcount=" +eachexportcount;
    ldAjax(surl,'',function(data){
        //先走后台判断是否已经导出完毕,没有导出完返回code=1继续导出,导出完返回code=2跳转到下载的url
        if (data.code == 1) {
            DownloadSocialPromotion(record,data.result.endexportrow,eachexportcount);
        } else if (data.code == 2) {
            window.location.href = 'index.php?module=uploads&frommodule=SocialPromotion&action=downloadxls&exportformat=exportxls&export_related=yes';
            ld('#rptContentLoading').hide();
        }
    });
}

