/**
 * @class LoadStuffClass
 * @author xll
 * @date  2024/08/07 - 初始版本
 * - 组件展示类
 * @description 展示不同组件的组件界面
 */
function LoadStuffClass() {
    var that = this;
    /**
     * 初始化实例数据
     * @param stuffid
     * @param stuffConJqObj
     * @param stuffData
     */
    this.init = function (stuffId,stuffConJqObj,stuffData) {
        this.stuffId = stuffId;
        this.data = stuffData;
        this.stuffConJqObj = stuffConJqObj;
    }
    this.setData = function (data) {
        that.data = data;
    }
    /** 展示组件方法 */
    this.showStuff = function () {
        if(typeof this.showFun['stuff_'+this.stuffId] === "function") {
            this.showFun['stuff_'+this.stuffId]();
        }
        else {
            this.showFun['default']();
        }
    }
    /** 展示组件方法的集合 */
    this.showFun = {
        default : function () {

        },
        /** 线索分析 */
        stuff_116 : function () {
            var stuffHtml = '';
            stuffHtml += '<div class="leadsAnalysisDiv">';
            ld.each(that.data,function (index,contenInfo) {
                var subLabel = contenInfo.subLabel === '' ? '' : ('<div class="subLabel">'+contenInfo.subLabel+'</div>');
                stuffHtml += '<div class="leadsAnalysisRow">' +
                    '<div class="leadsAnalysisLeft">' +
                    `<div class="leadsAnalysisIcon ${contenInfo.module}"></div>` +
                    '<div class="leadsAnalysisLabel">' +
                    `<div class="titleLabel"><div class="white-space: nowrap;text-overflow: ellipsis;overflow: hidden;">${contenInfo.label}</div></div>` +
                    `${subLabel}` +
                    '</div>' +
                    '</div>' +
                    `<div class="leadsAnalysisRight"><span class="leadsAnalysisValue" module="${contenInfo.module}">${contenInfo.value}</span></div>` +
                    '</div>';
            });
            stuffHtml += '</div>';
            that.stuffConJqObj.html(stuffHtml);
            that.stuffConJqObj.find('.leadsAnalysisValue').bind('click',function () {
                var click_module = ld(this).attr('module');
                getJsScript('include/js/modules/Home/HomeStuffChuantou.js', function () {
                    var params_data = '&PenetrateType=LeadsAnalysis'+'&XAxisName='+click_module;
                    var ChartChuantouObj = new HomeStuffChuantou();
                    ChartChuantouObj.HomeChartChuantou(that.stuffId,params_data);
                });
            });
        },
        /** 轮播图 */
        stuff_117 : function () {
            ld('<link>', {
                rel: 'stylesheet',
                type: 'text/css',
                href: 'crmcommon/js/swiper/swiper-bundle.min.css'
            }).appendTo('head');
            let stuffCon,
                carouselList = '',
                swiperId = 'swiper_'+that.stuffId;
            ld.each(that.data.CarouselImgs,function (index, info) {
                carouselList += '' +
                `<div class="swiper-slide">` +
                    `<div class = "swiper-material-wrapper" >` +
                        `<div class = "swiper-material-content" >` +
                            `<img class = "material-image" data-swiper-material-scale = "1.25" src = "${info.path}"   alt="${info.title}">` +
                            `<span class = "material-label swiper-material-animate-opacity" >` +
                                `${info.title}` +
                            `</span>` +
                        `</div>` +
                    `</div>` +
                `</div>`;
            })
            stuffCon = `<div class="swiper swiper-material" id="${swiperId}">` +
                            `<div class="swiper-wrapper">` +
                                carouselList +
                            `</div>` +
                            `<div class="swiper-pagination"></div>` +
                            `<div class="swiper-button-prev"></div>` +
                            `<div class="swiper-button-next"></div>` +
                        `</div>`;
            that.stuffConJqObj.html(stuffCon);
            getCommonJsScript('crmcommon/js/swiper/swiper-bundle.min.js',function () {
                const swiper = new Swiper(that.stuffConJqObj.find('#'+swiperId).get(0), {
                    // Optional parameters
                    direction: 'horizontal',
                    loop: true,
                    // If we need pagination
                    pagination: {
                        el: '.swiper-pagination',
                        clickable: true
                    },
                    // Navigation arrows
                    navigation: {
                        nextEl: '.swiper-button-next',
                        prevEl: '.swiper-button-prev',
                    },
                    autoplay: {
                        delay: that.data.CarouselTimer * 1000,
                        pauseOnMouseEnter: true,
                    },
                });
                // 编辑界面不跳转
                var popupObj = CrmPopup.getPopupObj('last')
                if(!popupObj || !popupObj.divid || !popupObj.boardtype) {
                    swiper.on('click', function (swiperObj, event) {
                        var index = ld(event.target).parents('.swiper-slide').data('swiper-slide-index'),
                            link = that.data.CarouselImgs[index].link;
                        typeof link !== "undefined" && /http/.test(link) && (OpenNewWebTab(link))
                    });
                }
            });
        }
    }
}
LoadStuffClass.prototype.constructor = LoadStuffClass;
LoadStuffClass.prototype._instanceList = {};
/**
 * 获取单例
 * @param {jQuery} stuffConJqObj 组件内容DOM的jQuery对象
 * @return {LoadStuffClass} LoadStuffClass实例
 */
LoadStuffClass.getInstance = function (stuffConJqObj) {
    let instanceId = stuffConJqObj.attr('_stuff_instance_');
    let loadStuffObj;
    if(instanceId === null || typeof instanceId === "undefined"){
        loadStuffObj = new LoadStuffClass();
        instanceId = 'stuff_' + (new Date - 0);
        LoadStuffClass.prototype._instanceList[instanceId] = loadStuffObj;
        stuffConJqObj.attr('_stuff_instance_',instanceId);
    }
    else {
        loadStuffObj = LoadStuffClass.prototype._instanceList[instanceId];
    }
    return loadStuffObj
}
/**
 * 展示组件
 * @param {number} stuffId 组件id
 * @param {jQuery} stuffConJqObj 组件内容DOM的jQuery对象
 * @param {any} stuffData 组件数据
 * @return {LoadStuffClass} LoadStuffClass实例
 */
LoadStuffClass.showStuff = function (stuffId,stuffConJqObj,stuffData) {
    let loadStuffObj = LoadStuffClass.getInstance(stuffConJqObj);
    loadStuffObj.init(stuffId,stuffConJqObj,stuffData);
    loadStuffObj.showStuff();
    return loadStuffObj;
}