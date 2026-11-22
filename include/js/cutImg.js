function cutImg(){
    var that=this;
    that.imgInfo = {
        'imgurl':'',
        'imgname':'',
    };
    //打开裁剪图片的弹窗
    that.openPop = function(suggest_info,width,height){ 
        that.ratio = parseFloat(width)/parseFloat(height);
        var previewstyle='width:'+145+'px;height:'+145/that.ratio+'px;overflow:hidden';
        //创建裁剪图片的弹窗
        var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
        crmPopupobj.prevshow();
        crmPopupobj.setParams(arrJsPopLabel["Uploadpictures"],that.okcut,"","LdPopWidth800px",'Settings','',arrJsPopLabel["Confirm"],"",arrJsPopLabel["CANCEL"]); 
        var pop_html = '<div class="tailoring-content"> <div class="tailoring-box-parcel"><div class="square" style="border:none"><label for="chooseImg" class="tailor-btn"><input type="file" accept="image/jpg,image/jpeg,image/png" id="chooseImg" style="display:none" name="">'+arrJsPopLabel["Choosepictures"]+' </label><div class="tailor-btn resetImg"> '+arrJsPopLabel["Resetpictures"]+'</div><div class="tailor-btn rotateImg" >' +arrJsPopLabel["Rotatepictures"]+'</div></div> <div class="square tailoringImg"><img id="tailoringImg"></div> </div> <div class="preview-box-parcel"> <div class="square" style="border:none"><p>' +arrJsPopLabel["Previewpictures"]+'</p> </div><div class="square previewImg" style="'+previewstyle+'"></div> <div class="Imgsuggest">'+suggest_info+'</div><div class="Imgname" ></div></div> </div>';
        CrmPopup.setPopupobjHtmlContent_scroll_jquery(crmPopupobj,pop_html);        
        that.crmPopupobj = crmPopupobj;
        that.setEvent();
        //图片初始化
        that.setRatio(that.ratio);
        ld('#'+that.crmPopupobj.divid).find('#tailoringImg').cropper('replace',ld('#'+that.imgShowBox).attr("src"), false);
        that.file_name = that.lastPrevPop.imgInfo[that.label]['imgname'];
        ld('#'+that.crmPopupobj.divid).find('.Imgname').html(that.file_name);
    }

    that.setEvent = function(){
        //图片选择
        ld('#'+that.crmPopupobj.divid).find('#chooseImg').unbind('change').bind('change',function(){
            that.select(this);
        })
        //图片旋转
        ld('#'+that.crmPopupobj.divid).find('.rotateImg').unbind('click').bind('click',function(){
            ld('#'+that.crmPopupobj.divid).find('#tailoringImg').cropper("rotate", 45);
        })
        //图片复位
        ld('#'+that.crmPopupobj.divid).find('.resetImg').unbind('click').bind('click',function(){
            ld('#'+that.crmPopupobj.divid).find('#tailoringImg').cropper("reset");
        })
    }
    //选择图片
    that.select = function(file){
        that.setRatio(that.ratio);
        if (!file.files || !file.files[0] ) {
            var fileuploadproblems = arrJsPopLabel["FILEUPLOADPROBLEMS"];
            RemindsMsg("","LdPopWidth400px","","yes","yes",fileuploadproblems);
            return false;
        }
        else if( file.files[0].error){
            console.log(file.files[0].error.message);
            var fileuploadproblems = arrJsPopLabel["FILEUPLOADPROBLEMS"];
            RemindsMsg("","LdPopWidth400px","","yes","yes",fileuploadproblems);
            return false;
        }
        that.file_name = file.files[0].name;
        if(that.file_name!=undefined&&that.file_name.length > 255){
            var filenameproblems = arrJsPopLabel['FILENAMESCANOTEXCEED255CHAR'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",filenameproblems);
            return false;
        }else{
            ld('#'+that.crmPopupobj.divid).find('.Imgname').html(that.file_name);
            var reader = new FileReader();
            reader.readAsDataURL(file.files[0]);
            reader.onload = function (evt) {
                var replaceSrc = evt.target.result; 
                ld('#'+that.crmPopupobj.divid).find('#tailoringImg').cropper('replace', replaceSrc, false);
            }
        }
        
    }
    //设置图片比例
    that.setRatio = function(ratio){
        ld('#'+that.crmPopupobj.divid).find('#tailoringImg').cropper({
            aspectRatio: ratio,//裁剪比例
            preview: '.previewImg',//预览视图
            guides: false,  //裁剪框的虚线(九宫格)
            autoCropArea: 0.9,  //0-1之间的数值，定义自动剪裁区域的大小，默认1
            movable: false, //是否允许移动图片
            dragCrop: true,  //是否允许移除当前的剪裁框，并通过拖动来新建一个剪裁框区域
            movable: true,  //是否允许移动剪裁框
            resizable: true,  //是否允许改变裁剪框的大小
            zoomable: false,  //是否允许缩放图片大小
            mouseWheelZoom: false,  //是否允许通过鼠标滚轮来缩放图片
            touchDragZoom: true,  //是否允许通过触摸移动来缩放图片
            rotatable: true,  //是否允许旋转图片
            crop: function(e) {
                // 输出结果数据裁剪图像。
            }
        });
    }
    //图片确定裁剪
    that.okcut = function(){
        if (ld('#'+that.crmPopupobj.divid).find('#tailoringImg').attr("src") == null ){
            that.crmPopupobj.CancelEvent();
            return false;
        }else{
            var canvas = ld('#'+that.crmPopupobj.divid).find('#tailoringImg').cropper('getCroppedCanvas');//获取被裁剪后的canvas
            var base64url = canvas.toDataURL('image/png'); //转换为base64地址形式，且图像类型为png
            if(base64url == "data:,"){
                alert(arrJsPopLabel["FILEUPLOADPROBLEMS"]);
                return false;
            }else{
            that.imgInfo.imgurl = base64url;
            that.imgInfo.imgname = that.file_name;
            that.lastPrevPop.imgInfo[that.label]=that.imgInfo;
            ld('#'+that.lastPrevPop.divid).find('#'+that.imgShowBox).attr("src",base64url);
            ld('#'+that.lastPrevPop.divid).find('#'+that.imgShowName).html(that.file_name);
            that.crmPopupobj.CancelEvent();
            return false;}
        }
    }

}
