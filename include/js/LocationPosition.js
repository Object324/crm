    //显示实时位置
    //自定义DOM覆盖物 - 继承DOMOverlay
function myInfoWindow(options) {
    var mydom;
    TMap.DOMOverlay.call(this, options);
}
myInfoWindow.prototype = new TMap.DOMOverlay();

// 初始化
myInfoWindow.prototype.onInit = function(options) {
    this.position = options.position;
    this.content = options.content;
};

// 创建DOM元素，返回一个DOMElement
myInfoWindow.prototype.createDOM = function() {
    mydom=document.createElement("div");
    //设置DOM样式
    mydom.style.cssText = 'height:15px;max-width:120px;padding:5px;background:#fff;border:#ccc solid 1px;\
                    line-height:15px;font-size:12px;position:absolute;top:0px;left:0px;';
    mydom.innerHTML=this.content;
    return mydom;
};

// 更新DOM元素，在地图移动/缩放后执行
myInfoWindow.prototype.updateDOM = function() {
    if (!this.map) {
        return;
    }

    // 经纬度坐标转容器像素坐标
    let pixel = this.map.projectToContainer(this.position);

    //默认使用DOM左上角作为坐标焦点进行绘制（左上对齐）
    //如想以DOM中心点（横向&垂直居中）或其它位置为焦点，可结合this.dom.clientWidth和this.dom.clientHeight自行计算
    let left = pixel.getX() - this.dom.clientWidth / 2 + 'px'; //本例水平居中
    let top = pixel.getY() + 'px';

    //将平面坐标转为三维空间坐标
   // this.dom.style.transform = `translate3d(${left}, ${top}, 0px)`;
};

//自定义一个更新内容的方法
myInfoWindow.prototype.updateContent = function(content) {
    mydom.innerHTML=content;
};



function initShowPositionMap(mapid,locationinfo) {
    // 初始化地图
        if(!empty(locationinfo.lat)){
            var center_lat = locationinfo.lat;
            var center_lng = locationinfo.lng;
        }else{
            var center_lat = 31.247788;
            var center_lng = 121.548513;
        }

        mapPositionobj = new TMap.Map(mapid, {
            zoom:12, // 设置地图缩放级别
            center: new TMap.LatLng(center_lat,center_lng) // 设置地图中心点坐标
        });

        var content='<div style="width:300px;text-align: left;"><div style="display:flex;align-items: center;">' +
            '<div style="background-image: url('+locationinfo.imageurl+');width:36px;height:36px;background-size:100% 100%;border-radius: 100%;"></div>'
            +'<div style="color: #555;font-size: 16px;padding-left:8px;">'+locationinfo.last_name+'</div>'
            +' </div>' +
            '<div style="padding: 4px 0;">定位地址：'+locationinfo.address+'</div>'+
            '<div style="padding: 4px 0;">定位时间：'+locationinfo.createdtime+'</div>'+
            ' </div> ';

        if(!empty(locationinfo.lat)){
            //创建一个自定义的infoWindow
            var myIW = new TMap.InfoWindow({
                map:mapPositionobj,
                position: new TMap.LatLng(locationinfo.lat, locationinfo.lng),
                content:content
            })
        }


    //两秒钟后更新文字内容
    setInterval(function(){
        ldAjaxNoProgress("index.php?module=TrackLocationMap&action=TrackLocationMapAjax&file=ShowLocationPosition&getpoisiont=yes&userid="+userid,{},function(ajaxdata){

            mapPositionobj.setCenter(new TMap.LatLng(ajaxdata.result.info.lat,ajaxdata.result.info.lng));
        })

    },1000*60*2);

}
