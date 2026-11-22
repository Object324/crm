/**
 * 图片预览，拖拽，缩放，滑动切换
 */
var ImagePreview = {
    default_params:{},
    img_list_obj : [],// 图像对象
    url : '',// 所点击图片的url
    url_arr : [],// 所有图片url
    url_index : 0,

    touchStartX: 0,
    touchStartY: 0,
    lastTouchX: 0,
    lastTouchY: 0,
    posX: 0,
    posY: 0,
    zoomFactor: 1,

    screenWidth: window.innerWidth,
    screenHeight: window.innerHeight,
    moveThreshold: 150, // 切换图片的移动阈值
    isSwitching: false, // 是否正在切换图片
    isDragging: false,// 是否正在拖动
    shouldSwitchImage: false,// 是否切换图片
    switchDirection: null,// 切换上一张/下一张图片
    isZooming: false,// 是否正在放大
    isLongImg: false,// 是否是长图

    touchStartDist: 0,
    maxZoom: 3,
    minZoom: 0.6,

    init:function (param) {
        let that = this;
        if (param) {
            $.extend(this.default_params, param.id);
        }
        this.url = param.url;
        this.url_arr = param.url_arr?param.url_arr:[];
        if(this.url_arr.length > 0){
            this.url_arr.forEach(function(item,index) {
                if(item.indexOf(that.url) != -1){
                    that.url_index = index;
                }
            });
        }
        var img_list_obj = [];
        var id = this.default_params.id;
        
        if (typeof id == 'string') {
            if ((img_list_obj = $("#"+id).find("img")).length == 0) {
                return;
            }
        } else if (typeof id == 'object' && id != null) {
            img_list_obj = $(id);
        }
        this.img_list_obj = img_list_obj;
        this.fnGenerateHtml();
        this.fnBindEvent(img_list_obj);
    },
    fnBindEvent:function (img_list_obj) {
        let that = this;
        if (img_list_obj.length == 0 && this.url == '') {
            return;
        }
        $(img_list_obj).off("click").on("click", this.onClickEvent);
        $("#ld-img-preview").off("mousewheel DOMMouseScroll").on('mousewheel DOMMouseScroll', this.onMouseScrollEvent);

        $("#ld-img-preview").css('touch-action','none');
        $("#ld-img-preview").off("touchstart").on('touchstart', function(event) {
            that.handleTouchStart(event);
        });
        $("#ld-img-preview").off("touchmove").on('touchmove', function(event) {
            that.handleTouchMove(event);
        });
        $("#ld-img-preview").off("touchend").on('touchend', function(event) {
            that.handleTouchEnd(event);
        });

        $('#ld-img-floatshadow').off("click").on("click", function () {
            that.fnCloseImg();
        });
        $('#ld-image-container').off("click").on("click", function () {
            that.fnCloseImg();
        });
        $("#ld-img-preview").off("click").on("click", function () {
            that.fnCloseImg();
        });
    },
    fnGenerateHtml:function () {
        if($("#ld-img-preview").length<1){
            var tmp_html = '<div id="ld-image-container" style="position: fixed; width: 100vw; left: 50%; top: 50%; transform: translate(-50%, -50%); z-index: 19941206;">'
                          +'<img id="ld-img-preview" src="'+this.url+'" style="width: 100%; cursor: move; display: block;object-fit: cover;"></div>'
                          +'<div id="ld-img-floatshadow" style="z-index: 19941205;background-color: #000;opacity: .5;top: 0;left: 0;width: 100%;height: 100%;position: fixed;display: " title="点击空白处关闭"></div>';
            $(".page-current").find('.content').eq(0).append(tmp_html);
        }else{
            this.onClickEvent();
            $("#ld-img-preview").css('width','100%');
        }
        ImagePreview.fnReset();
    },
    fnMouseOver:function () {
        $(this).css("background", "rgb(134, 134, 134)");
        $(this).css("border", "1px solid rgb(111, 111, 111)");
    },
    fnMouseOut:function () {
        $(this).css("background", "");
        $(this).css("border", "");
    },
    fnPrev:function () {
        if(this.url_arr[this.url_index-1]){
            $("#ld-img-preview").attr("src", this.url_arr[this.url_index-1]);
            this.url_index--;
            ImagePreview.fnReset();
        }
    },
    fnNext:function () {
        if(this.url_arr[this.url_index+1]){
            $("#ld-img-preview").attr("src", this.url_arr[this.url_index+1]);
            this.url_index++;
            ImagePreview.fnReset();
        }
    },
    onClickEvent:function (e) {
        $("#ld-img-preview").attr("src", this.url);
        $("#ld-img-floatshadow").show('fast');
        $("#ld-img-preview").show('fast');
    },
    fnReset:function () {
        $("#ld-img-preview").css("width","100%");
        $("#ld-img-preview").css("height","100%");
        $("#ld-img-preview").css("transform","");
        this.touchStartX = 0;
        this.touchStartY = 0;
        this.lastTouchX = 0;
        this.lastTouchY = 0;
        this.posX = 0;
        this.posY = 0;
        this.zoomFactor = 1;
        this.isZooming = false;
        this.isLongImg = false;
        ImagePreview.checkImageOrientation();
    },
    fnCloseImg:function () {
        $("#ld-img-preview").hide();
        $('#ld-img-floatshadow').hide();
        $("#ld-img-preview").attr("src", "");
        ImagePreview.fnReset();
    },
    onMouseScrollEvent:function (e) {
        e.preventDefault();
        // 获取滚动量
        var wheel = e.originalEvent ? (e.originalEvent.wheelDelta || -e.originalEvent.deltaY) : (e.wheelDelta || -e.deltaY);
        // ImagePreview.zoomFactor = wheel;

        var delta = Math.max(-1, Math.min(1, wheel));
        if (delta < 0) { //向下滚动
            $(this).width($(this).width() / 1.1);
            $(this).height($(this).height() / 1.1);
            ImagePreview.isZooming = false;
            setTimeout(() => {
                ImagePreview.checkAndCorrectBounds();
            }, 300);
        } else { //向上滚动
            $(this).width($(this).width() * 1.1);
            $(this).height($(this).height() * 1.1);
            ImagePreview.isZooming = true;
        }
    },
    handleTouchStart:function (event) {
        if (event.touches) {
            if (event.touches.length === 1) {
                // 单指触摸开始时的位置，用于移动图片
                this.touchStartX = event.touches[0].clientX;
                this.touchStartY = event.touches[0].clientY;
                this.lastTouchX = this.posX;
                this.lastTouchY = this.posY;
                this.isDragging = true; // 开始拖动
            } else if (event.touches.length > 1) {
                // 两指触摸开始时的位置，用于缩放图片
                this.touchStartDist = this.getDistance(event.touches[0], event.touches[1]);
            }
        }
    },
    handleTouchMove:function (event) {
        event.preventDefault(); // 阻止默认行为，如视图滚动
        if (event.touches) {
            if (event.touches.length === 1) {
                if (this.isDragging) {
                    // 单指拖动
                    let deltaX = event.touches[0].clientX - this.touchStartX;
                    let deltaY = event.touches[0].clientY - this.touchStartY;

                    // 预设新位置
                    let newX = this.lastTouchX + deltaX;
                    let newY = this.lastTouchY + deltaY;
                    // 检查是否超出阈值来切换图片
                    if (this.isZooming == false && this.url_arr.length > 0 && Math.abs(deltaX) > this.moveThreshold) {
                        this.shouldSwitchImage = true;
                        this.switchDirection = deltaX > 0 ? 'prev' : 'next';
                        // return; // 早退防止应用其他变换
                    }

                    // 应用位置调整
                    this.posX = newX;
                    this.posY = newY;
                    if(this.isZooming == false && this.isLongImg == false){// 当图片未放大且非长图时，仅可水平移动
                        this.applyTransformX();
                    }else{
                        this.applyTransform();
                    }
                }
            } else if (event.touches.length > 1) {
                // 两指缩放
                let currentDist = this.getDistance(event.touches[0], event.touches[1]);
                let zoomChange = (currentDist - this.touchStartDist) / 200; // 缩放速度控制因子
                let newZoomFactor = this.zoomFactor + zoomChange;

                // 限制缩放大小
                ImagePreview.zoomFactor = Math.min(this.maxZoom, Math.max(this.minZoom, newZoomFactor));
                ImagePreview.isZooming = true;
                this.applyZooming();
                
                // 更新开始距离
                this.touchStartDist = currentDist;
            }
        }
    },
    handleTouchEnd:function (event) {
        // 切换图片
        if (this.shouldSwitchImage && this.isZooming == false) {
            this.switchImage(this.switchDirection);
        } 
        // 触摸结束逻辑，检查并修正图片位置
        if (this.isZooming == false && this.isLongImg == false) {
            this.checkAndCorrectBounds();
        }
        this.shouldSwitchImage = false; 
        this.isDragging = false;
    },
    applyTransform:function () {
        const imgElement = document.getElementById('ld-img-preview');
        imgElement.style.transform = `translate(${this.posX}px, ${this.posY}px) scale(${ImagePreview.zoomFactor}`;
    },
    applyTransformX:function () {
        const imgElement = document.getElementById('ld-img-preview');
        imgElement.style.transform = `translate(${this.posX}px)`;
    },
    applyZooming:function () {
        const imgElement = document.getElementById('ld-img-preview');
        imgElement.style.transform = `translate(${this.posX}px, ${this.posY}px) scale(${ImagePreview.zoomFactor})`;
        if(ImagePreview.zoomFactor > 1){
            ImagePreview.isZooming = true;
        }else{
            ImagePreview.isZooming = false;
            setTimeout(() => {
                this.checkAndCorrectBounds();
            }, 300);
        }
    },
    getDistance: function(touch1, touch2) {
        let xDist = touch1.clientX - touch2.clientX;
        let yDist = touch1.clientY - touch2.clientY;
        return Math.sqrt(xDist * xDist + yDist * yDist);
    },
    switchImage:function (direction) {
        if (!this.isSwitching) {
            this.isSwitching = true; // 锁定切换状态

            // 在这里实现实际的图片切换逻辑
            if(direction == 'next'){
                this.fnNext();
            }else if(direction == 'prev'){
                this.fnPrev();
            }
            
            this.resetSwitchingState();
        }
    },
    resetSwitchingState:function () {
        // 可以在这里设置一个延时，模拟加载或过渡效果的时间
        setTimeout(() => {
            this.isSwitching = false;
        }, 300); // 假设300毫秒后可以再次切换
    },
    // 图片边缘溢出检测
    checkAndCorrectBounds:function () {
        const imgElement = document.getElementById('ld-img-preview');
        const rect = imgElement.getBoundingClientRect();
        const screenWidth = window.innerWidth;
        const screenHeight = window.innerHeight;

        // 计算图片的边界
        const leftBound = rect.left;
        const rightBound = rect.right;
        const topBound = rect.top;
        const bottomBound = rect.bottom;

        // 判断是否超出屏幕边界
        if (leftBound > 0) {
            this.posX -= leftBound; // 左边界超出
        }
        if (rightBound < screenWidth) {
            this.posX += (screenWidth - rightBound); // 右边界超出
        }
        if (topBound > 0) {
            this.posY -= topBound; // 顶边界超出
        }
        if (bottomBound < screenHeight) {
            this.posY += (screenHeight - bottomBound); // 底边界超出
        }

        // 如果进行了调整，重新应用transform
        if (leftBound > 0 || rightBound < screenWidth || topBound > 0 || bottomBound < screenHeight) {
            this.fnReset();
        }
    },
    // 长图检测
    checkImageOrientation: function () {
        const imgElement = document.getElementById('ld-img-preview');
        const screenHeight = window.innerHeight;
        if (imgElement.height > screenHeight) { // 长图判断
            ImagePreview.isLongImg = true; // 是长图
        } else {
            ImagePreview.isLongImg = false;
        }
    },
};