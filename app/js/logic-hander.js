var logicHanderObj = {};
//显示暂无数据(消息、审批、公告等)
logicHanderObj.NoinfoNotice = function (message) {
    if (typeof message === "undefined") {
        message = '数据';
    };
    var noticeHtml = '<div class="no_message_tip">' +
        '<img alt="" src="images/no_message_picture.png" >' +
        '<p>暂无' + message + '</p></div>';
    return noticeHtml;
};
//表单判断js 
logicHanderObj.Check = {
    //主表字段判断
    Empty: function () {
        var checkEmptyArr = new Array();
        checkEmptyArr = checkEmptyStr.split('&&&&&');
        var checkValue = '', checkfieldsArr = new Array();
        for (var i = 0; i < checkEmptyArr.length - 1; i++) {
            checkfieldsArr = checkEmptyArr[i].split(',');
            if (checkfieldsArr[2] == 'val') {
                checkValue = ld('#' + checkfieldsArr[0]).val();
            }
            else if (checkfieldsArr[2] == 'html') {
                checkValue = ld('#' + checkfieldsArr[0]).html();
            }
            if (checkValue == '') {
                PopPromptBox.show(checkfieldsArr[1] + '不能为空');
                return false;
            }
        }
        return true;
    },
    //不能重复
    Fieldonly: function (save_type) {
        if (empty(fieldonlyStr)) {
            return true;
        }
        var fieldonlyStrArr = new Array();
        var noticestatus = true;
        var curr_recordID = '';
        if (save_type === 'edit') {
            curr_recordID = recordID;
        }
        fieldonlyStrArr = fieldonlyStr.split('&&&&&');
        var checkValue = '', fieldonlyArr = new Array();
        for (var i = 0; i < fieldonlyStrArr.length - 1; i++) {
            fieldonlyArr = fieldonlyStrArr[i].split(',');
            if (fieldonlyArr[2] == 'val') {
                checkValue = ld('#' + fieldonlyArr[0]).val();
            }
            else if (fieldonlyArr[2] == 'html') {
                checkValue = ld('#' + fieldonlyArr[0]).html();
            }
            if (checkValue != '') {
                var urlstring = 'module=' + module + '&action=' + module + 'Ajax&file=FieldDuplicate' +
                    '&fieldname=' + fieldonlyArr[0] + '&fieldvalue=' + checkValue + '&fieldid=' + curr_recordID;
                WordReportAjax(urlstring, function (rest) {
                    if (empty(rest)) return false;
                    var restobj = eval('(' + rest + ')') ? eval('(' + rest + ')') : JSON.parse(rest);
                    if (restobj.code == -1 && noticestatus) {
                        PopPromptBox.show(restobj.msg);
                        noticestatus = false;
                    }
                }, { async: false });
                if (!noticestatus) return noticestatus;
            }
        }
        return noticestatus;
    },
    //明细表字段判断（产品、费用报销）
    DetailEmpty: function () {
        var fieldcheckEmptyArr = new Array();
        fieldcheckEmptyArr = fieldcheckEmptyStr.split('&&&&&');
        var checkValue = '', fieldcheckfieldsArr = new Array();
        for (var i = 0; i < fieldcheckEmptyArr.length - 1; i++) {
            fieldcheckfieldsArr = fieldcheckEmptyArr[i].split(',');
            if (fieldcheckfieldsArr[2] == 'val') {
                checkValue = ld('#' + fieldcheckfieldsArr[0]).val();
            }
            else if (fieldcheckfieldsArr[2] == 'html') {
                checkValue = ld('#' + fieldcheckfieldsArr[0]).html();
            }
            if (checkValue == '' || checkValue == undefined) {
                PopPromptBox.show(fieldcheckfieldsArr[1] + '不能为空');
                return false;
            }
        }
        return true;
    },
    //判断Email格式是否正确
    EmailField: function () {
        if (emailFieldNameArrayNum > 0) {
            var emailReg = new RegExp(/(\S)+[@]{1}(\S)+[.]{1}(\w)+/);
            //var emailReg=new RegExp(/^[a-zA-Z0-9]+([!"#$%&'()*+,./:;<=>?@\^_`{|}~-]?[a-zA-Z0-9])*@[a-zA-Z0-9]+([\_\-\.]?[a-zA-Z0-9]+)*\.([\-\_]?[a-zA-Z0-9])+(\.?[a-zA-Z0-9]+)?$/);
            for (i = 0; i < emailFieldNameArrayNum; i++) {
                var emailstr = ld('#' + emailFieldNameArray[i]['fieldname']).val();
                if (emailstr && !emailReg.test(emailstr)) {
                    PopPromptBox.show(emailFieldNameArray[i]['fieldlabel'] + '格式输入错误');
                    return false;
                }
            }
        }
        return true;
    },
    //时间比较
    DateField: function (sourceDate, targetDate) {
        var source_date = DateContorlObj.getDateValue(sourceDate),
            target_date = DateContorlObj.getDateValue(targetDate);
        if (Date.parse(source_date) > Date.parse(target_date)) {
            var source_str = ld('#' + sourceDate).parent().find('i').text().replace("*", "");
            var target_str = ld('#' + targetDate).parent().find('i').text().replace("*", "");
            PopPromptBox.show(target_str + '不能早于' + source_str);
            return false;
        }
        return true;
    },
    //特殊判断不能为空
    SpecialEmpty: function (fieldname) {
        if (ld('#' + fieldname).length === 1 && ld('#' + fieldname).val() == '') {
            PopPromptBox.show(ld('#' + fieldname).parent().find('i').text() + '不能为空');
            return false;
        }
        return true;
    }
};
//拨打电话
logicHanderObj.Telephone = function (phonevstr) {
    if (phonevstr == '' || phonevstr == null) return;
    var telhtml = '',
        callhtml = '',
        relmobile = /^1\d{10}$/,
        phonevstrarr = new Array();
    phonevstrarr = phonevstr.split("&&");
    for (var i = 0; i < phonevstrarr.length; i++) {
        var phonemobile = phonevstrarr[i];
        if (phonemobile != '') {
            telhtml += '<div class="opt"><span>' + phonemobile + '</span>';
            if (phoneversion == 'ios') {
                callhtml = 'href="tel:' + phonemobile + '"';
            }
            else {
                callhtml = "onclick=javatojs.callPhone('" + phonemobile + "');";
            }
            telhtml += '<a class="talk lnr-phone-handset2" ' + callhtml + '></a>';
            if (relmobile.test(phonemobile)) {  //为手机格式，则可发短信
                if (phoneversion == 'ios') {
                    callhtml = 'href="sms:' + phonemobile + '"';
                }
                else {
                    callhtml = "onclick=javatojs.smsPhone('" + phonemobile + "');";
                }
                telhtml += '<a class="msg lnr-call-msg" ' + callhtml + '></a>';
            }
            telhtml += '</div>';
        }
    }
    telhtml += '<div class="btn" tag="btnc_cancel">取消</div>';
    ld('#CallMsgMain').html(telhtml);//显示打电话，发短信弹框
    logicHanderObj.popUpMaskToggle('CallMsgMain');
};
//错误提示
logicHanderObj.errorNotice = function () {
    ld('#errorstatus').removeClass('ui-hide');
    logicHanderObj.countDown(3, 'errorstatus');
};
//计时
logicHanderObj.countDown = function (secs, divname) {
    if (--secs > 0) {
        setTimeout("logicHanderObj.countDown(" + secs + ",'" + divname + "')", 1000);
    }
    else {
        ld('#' + divname).addClass('ui-hide');
        ld("#status").css('display', 'none');
    }
};
//工作保存后清空值
logicHanderObj.toClear = function () {
    ld('#usersearch').val('');//清空搜索框内容
    //清空已选择弹框的内容:客户、联系人、部门、同事
    ld('#chosenlist_Accounts,#chosenlist_Contacts,#chosenSendrange_Group,#chosenSendrange_Colleague').html('');
    //清除发送范围记录
    sessionStorage.clear();
    btnshowCCname = '';
    //清除定位、关联客户、联系人、产品
    ld('#sendLogSign,#sendLogAcctlist,#sendLogContlist,#sendLogProlist').addClass('ui-hide');
    ld('#sendLogSignAddress,#sendLogSignPoint,#sendLogAcctlistCount,#sendLogContlistCount,#sendLogProlistCount').html('');
    t_choose_a_relationidobj = [], t_choose_a_relationnameobj = [];//关联数据id,关联数据名称，临时保存 客户
    t_choose_c_relationidobj = [], t_choose_c_relationnameobj = [];//关联数据id,关联数据名称，临时保存 联系人
    t_choose_p_relationidobj = [], t_choose_p_relationnameobj = [];//关联数据id,关联数据名称，临时保存 产品
    //清空发送信息
    ld('#wn-forword-footer .send_scop_icon,#ccrangeDIV').html('<span class="text-ellipsis">发送范围</span>');
    ld('#CommonDiv,#ColleagueDiv,#DepartmentDiv').html('');
    ld('#sendLog_at_user').val('');
    ld('#sendLog_at_group').val('');
    //清空图片
    imgid = '', imghtml = '';//之前上传的图片清空
    ld('#sendLogUploadImg').addClass('ui-hide').find('div[img-detail]').remove();
};
//显示、隐藏位于底部的弹出层和遮罩层
logicHanderObj.popUpMaskToggle = function (popUpId) {
    if(module!='Singin'){
        ld('#tplPhone div[tag=btnsub_photo]').removeClass('ui-hide');
    }
    ld('#' + popUpId).toggleClass('ui-hide');
    ld('#layerMask').toggle();
}
//获取焦点，光标在文字之后
logicHanderObj.getFocus = function (id) {
    var t = ld("#" + id).val();
    if (t != '') {
        ld("#" + id).val("").focus().val(t);
    }
    ld("#" + id).focus();
};
//获取焦点ID
logicHanderObj.isFocus = function (id) {
    ViewObj.rootScope.focusID = id;
};
//产品编辑界面更多币种弹出框隐藏和显示
logicHanderObj.fnshowHide = function (currObj, txtObj) {
    if (currObj.checked == true) {
        ld('#' + txtObj).css("visibility", "visible");
    } else {
        ld('#' + txtObj).css("visibility", "hidden");
    }
};
//系统提示,5秒自动关闭
logicHanderObj.syssetremind = function (tiptxt) {
    ld('.setreminder').html(tiptxt);
    ld('.setreminder').removeClass('ui-hide');
    logicHanderObj.selfClose(2);
};
//自动关闭
logicHanderObj.selfClose = function (secs) {
    if (--secs > 0) {
        setTimeout("logicHanderObj.selfClose(" + secs + ")", 1000);

    } else {
        ld('.setreminder').addClass('ui-hide');
        ld('.setreminder').html('');
    }
};
//格式化数字
logicHanderObj.fmoney = function (s, n) {
    n = n > 0 && n <= 20 ? n : 2;
    s = parseFloat((s + "").replace(/[^\d\.-]/g, "")).toFixed(n) + "";
    var l = s.split(".")[0].split("").reverse(),
        r = s.split(".")[1];
    t = "";
    for (i = 0; i < l.length; i++) {
        t += l[i] + ((i + 1) % 3 == 0 && (i + 1) != l.length ? "," : "");
    }
    return t.split("").reverse().join("") + "." + r;
}
//反格式化数字
logicHanderObj.rmoney = function (s) {
    if(s==undefined){
        return 0;
    }
    else{
        return parseFloat(s.replace(/[^\d\.-]/g, ""));    
    } 
}
//数据分类
logicHanderObj.headerDataClassify = function () {
    //if(!NetworkObj.isOnline()) return;
    if (ld('#head_mid span:visible').attr('classify') !== 'true') return;
    // 数据分类下拉
    var mark_tag = ld('#head_mid span:visible'),
        list_obj = ld('#pulldown_menu,#pulldown_menu ul'),
        c_id = ViewObj.getCurrentViewId();
    switch (c_id) {
        case 'crm-list-view':
            list_obj = ld('#pulldown_menu,#pulldown_menulists');
            break;
        case 'cwn-popuselect-view':
            list_obj = ld('#pulldown_menu,#sub_menulists');
            break;
        case 'work-release-view':
            list_obj = ld('#pulldown_menu,#work_releaselist');
            break;
    }
    if (mark_tag.hasClass('select')) {
        list_obj.addClass('ui-hide');
        mark_tag.removeClass('select');
        ld('#poplayerMask').hide();
        ld('#head_mid i:visible').removeClass('up').addClass('down');
    } else {
        ld('#pulldown_menulists,#sub_menulists').addClass('ui-hide');
        list_obj.removeClass('ui-hide');
        mark_tag.addClass('select');
        ld('#poplayerMask').show();
        ld('#head_mid i:visible').removeClass('down').addClass('up');
        // 当第一次 打开时 设置 头部数据分类 滚动对象
        if (!(SwiperObj.downMenu_swiper instanceof Swiper)) {
            SwiperObj.downMenu_swiper = new Swiper('.swiper-container.down-menu', {
                direction: 'vertical',
                slidesPerView: 'auto',
                freeMode: true,
                autoHeight: true,
                resistance: true,//开启页面拖离屏幕头部或者尾部 
                resistanceRatio: 0,
            });
        } else { // 已经有滚动对象
            SwiperObj.autoHeight(0, SwiperObj.downMenu_swiper);  // 直接重新设置高度
        }
    }
}
//根据默认内容或插入内容，调整文本框高度
logicHanderObj.getTxtautoH = function (str, fldname) {
    if (str == null) return 0;
    if (typeof str != "string") {
        str += "";
    }
    //widthview屏宽，
    var widthview = window.innerWidth / window.devicePixelRatio;
    var heightnum = Math.ceil(str.replace(/[^x00-xff]/g, "**").length / (widthview / 8));
    if (heightnum > 1) {
        ld('#' + fldname).height(heightnum * 25.5);
    }
}
//清空对应字段组合
logicHanderObj.clearFieldArray = function () {
    billfieldStr = '';//清空字段组合
    checkEmptyStr = '';//清空主表不为空字段信息组合
    fieldcheckEmptyStr = '';//分录不为空字段信息组合
    fieldonlyStr = '';//清空不能重复字段组合
    priceFieldNameNum = 0;
    priceFieldName = Array();//清空金额字段数组
    emailFieldNameArrayNum = 0;
    emailFieldNameArray = Array();//清空Email字段数组  
}
//图片加载完后，手动截取
logicHanderObj.loadimg = function (img) {
    var m = img.width / img.height;
    if (m >= 1) {
        img.style.maxWidth = SwiperObj.PHONE_WIDTH+"px";
        img.style.maxHeight = "100%";
    } else {
        img.style.maxHeight = SwiperObj.PHONE_HEIGHT+"px";
        img.style.maxWidth = "100%";
    }
}