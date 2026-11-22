function ReportAnalysisList() {
    ReportAnalysis.call(this);
    var that = this;
    this.listtype = 'list';

    that.setScroll = function(){
        var windowWidth = ld('#'+that.divid).outerWidth();
        var windowHeight = ld('#'+that.divid).outerHeight();
        var ld_tableContentObj = ld("#" + that.divid).find('#reportanalysis_tablecontent');
        var options = {'height': windowHeight-60, 'width': windowWidth, 'thwidth': 145};
        lockingHeaderColumn(ld_tableContentObj, options);
    }
}
ReportAnalysisList.prototype = Object.create(ReportAnalysis.prototype);
ReportAnalysisList.prototype.constructor = ReportAnalysisList;