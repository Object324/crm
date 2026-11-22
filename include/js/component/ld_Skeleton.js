/**
 * @class ld_Skeleton
 * @author diony
 * @date 2023/12/14 - 初始版本
 * Skeleton 骨架屏
 * @description 在需要等待加载内容的位置设置一个骨架屏，某些场景下比 Loading 的视觉效果更好。
 */
function ld_Skeleton(){
    var that = this;

    this.skeleton_id = 'ld-skeleton-component';

    this.skeleton_className = 'ld-skeleton-component';

    // 骨架宽度数组
    this.skeletonWidthArr = ['gwidth100', 'gwidth30', 'gwidth60', 'gwidth100'];

    /**
     * 获取骨架屏html
     * @param {int} contentHeight 骨架屏总高度,减去padding的60,再除以50(每个骨架高度),计算骨架个数
     */
    this.showSkeleton = function (contentHeight){
        var skeletonHeght = parseInt(contentHeight) - 60;
        var skeletonCount = parseInt(parseInt(skeletonHeght)/50);
        // 创建div
        var skeletonDiv = document.createElement('div');
        skeletonDiv.id = that.skeleton_id;
        skeletonDiv.className = that.skeleton_className;
        var skeletonHtml = '';
        // 循环生成骨架
        for (var i = 1;i <= skeletonCount; i++) {
            // 判断骨架宽度
            skeletonHtml += '<div class="ld-skeleton-item '+that.skeletonWidthArr[i%4]+'"></div>';
        }
        // 给div添加骨架
        skeletonDiv.innerHTML = skeletonHtml;
        return skeletonDiv;
    }
}

/**
 * 加载数据时,显示骨架屏
 * @param {HTMLElement} obj DOM对象
 */
ld_Skeleton.showSkeleton = function (obj, contentHeight){
    var ld_skeleton_obj = new ld_Skeleton();
    var skeletonHtml = ld_skeleton_obj.showSkeleton(contentHeight);
    obj.innerHTML = skeletonHtml;
    document.getElementById('ld-skeleton-component').style.height = contentHeight+'px';
}
/**
 * 数据加载完成后,删除骨架屏
 */
ld_Skeleton.hideSkeleton = function (obj){
    var ld_skeleton_obj = obj.querySelector('.ld-skeleton-wrap');
    ld_skeleton_obj.remove();
}

/**
 * crmPopup加载数据时,显示骨架屏
 * @param crmPopupObj对象
 */
ld_Skeleton.showSkeletonPop = function (crmPopupObj, contentHeight){
    var ld_skeleton_obj = new ld_Skeleton();

    var skeletonHtml = ld_skeleton_obj.showSkeleton(contentHeight);
    ld('#'+crmPopupObj.divid+' .E_pop_tit').after(skeletonHtml);//呼叫中心 修改这样
    document.querySelector('#'+crmPopupObj.divid+ ' #ld-skeleton-component').style.height = contentHeight+'px';

}