//列表页JS
function CustomTables(){
    var that = this;
    this.pagemode='';
    this.pageto_module = 'ReportAnalysis';
    this.init = function(){

    }
    //打印--公共方法 之前的打印会导致页面js事件失效
    this.customPrint = function (content, options = {}) {
        const removeOldIframe = () => {
            const oldPrintIframe = document.getElementById('printIframe')
            oldPrintIframe && oldPrintIframe.remove && oldPrintIframe.remove()
        }
        removeOldIframe()
        const printIframe = document.createElement('iframe')
        printIframe.id = 'printIframe'
        document.body.appendChild(printIframe)
        const printIframeWindow = printIframe.contentWindow
        printIframeWindow.document.title = options.title || ''
        printIframeWindow.document.write(content)
        printIframeWindow.addEventListener('beforeprint', () => {
            options.beforePrint && options.beforePrint(printIframe)
        })
        printIframeWindow.addEventListener('afterprint', () => {
            options.afterPrint && options.afterPrint(printIframe)
            removeOldIframe()
        })
        setTimeout(() => {
            printIframeWindow.focus()
            printIframeWindow.print()
        })
    }

    this.connotempty = function(tips,inputobj){
        var value = ld(inputobj).val();
        if(value==''||value==undefined){
            RemindsMsg("","LdPopWidth400px","","yes","yes",tips+arrJsPopLabel['CANOTEMPTY']);
            ld('input[tagclick="msgConfirm"]').unbind('click').on('click', function () {
                ld(inputobj).focus();
            });
            ld('input[class="E_pbtncancel"]').unbind('click').on('click', function () {
                ld(inputobj).focus();
            });
            return false;
        }
        return true;
    }
}

var CustomTablesObj = new CustomTables();
