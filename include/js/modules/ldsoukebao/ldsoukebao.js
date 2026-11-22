
function showCrmOverlay() {

    ld('#ldsoukebaooverlay').show().css('z-index','1001');
    ld('#ldsoukebaoiframe').show().css('z-index','1002');

}
function hideCrmOverlay() {
    ld('#ldsoukebaooverlay').hide();
    ld('#ldsoukebaoiframe').show().css('z-index','unset');
}