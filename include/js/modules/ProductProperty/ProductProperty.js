function ProductProperty() {
    var popupobj = '';
    var divid = '';
    var proTabObj = '';
    var that = this;
    this.setPopupobj = function(popupobj){
        that.popupobj = popupobj;
        that.divid = popupobj.divid;
    }
    this.setInitEvent=function(){

    };


}
ProductProperty.moduleEdit = function(){
    var ProductPropertyObj = new ProductProperty();
    var popupObj = CrmPopup.getPopupObj('last');
    ProductPropertyObj.setPopupobj(popupObj);
    ProductPropertyObj.setInitEvent();
}