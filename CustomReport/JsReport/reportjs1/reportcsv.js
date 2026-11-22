var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StreamWriter = Stimulsoft.System.IO.StreamWriter;
            var StiLocalization = Stimulsoft.Base.Localization.StiLocalization;
            var StiCsvExportService = /** @class */ (function (_super) {
                __extends(StiCsvExportService, _super);
                function StiCsvExportService() {
                    var _this = _super !== null && _super.apply(this, arguments) || this;
                  
                    _this.multipleFiles = false;
                    return _this;
                }
                Object.defineProperty(StiCsvExportService.prototype, "defaultExtension", {
                    get: function () {
                        return "csv";
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiCsvExportService.prototype, "exportFormat", {
                    get: function () {
                        return Report.StiExportFormat.Csv;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiCsvExportService.prototype, "groupCategory", {
                    get: function () {
                        return "Data";
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiCsvExportService.prototype, "position", {
                    get: function () {
                        return Export.StiExportPosition.Data;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiCsvExportService.prototype, "exportNameInMenu", {
                    get: function () {
                        return StiLocalization.get("Export", "ExportTypeCsvFile");
                    },
                    enumerable: true,
                    configurable: true
                });
                StiCsvExportService.prototype.exportTo = function (report, stream, settings) {
                    this.exportCsv(report, stream, settings.sti.as(Export.StiDataExportSettings));
                };
                StiCsvExportService.prototype.exportToAsync = function (onExport, report, stream, settings) {
                    var service = this;
                    setTimeout(function () {
                        service.exportTo(report, stream, settings);
                        onExport();
                    });
                };
                Object.defineProperty(StiCsvExportService.prototype, "getFilter", {
                    get: function () {
                        return StiLocalization.get("FileFilters", "CsvFiles");
                    },
                    enumerable: true,
                    configurable: true
                });
            
                StiCsvExportService.prototype.exportCsv = function (report, stream, settings) {
                    // StiLogService.Write(this.GetType(), "Export report to Csv format");
                    // Read settings
                    if (settings == null)
                        throw new Error("The 'settings' argument cannot be equal in null.");
                    var pageRange = settings.pageRange;
                    var separator = settings.separator;
                    var encoding = settings.encoding;
                    var skipColumnHeaders = settings.skipColumnHeaders;
                    var mode = settings.dataExportMode;
                    if (separator == "\\t")
                        separator = "\t";
                    /*if (StiOptions.Export.Csv.ForcedSeparator != null &&
                        StiOptions.Export.Csv.ForcedSeparator.Trim().Length > 0)
                        separator = StiOptions.Export.Csv.ForcedSeparator.Trim();*/
                    var pages = pageRange.getSelectedPages(report.renderedPages);
                    this.currentPassNumber = 0;
                    this.maximumPassNumber = 3;
                    var matrix = new Export.StiMatrix(pages, false, this, null, mode);
                    matrix.scanComponentsPlacement(false);
                    if (this.isStopped)
                        return;
                    matrix.prepareDocument(this, mode);
                    this.writer = new StreamWriter(stream, encoding);
                    // StatusString = StiLocalization.get("Export", "ExportingCreatingDocument");
                    // Render document
                    if (!skipColumnHeaders) {
                        for (var columnIndex = 0; columnIndex < matrix.fields.length; columnIndex++) {
                            var text = matrix.fields[columnIndex].name.sti.replaceAll("\"", "\"\"");
                            if (text.indexOf(separator) != -1)
                                text = "\"" + text + "\"";
                            this.writer.write(text);
                            if (columnIndex < matrix.fields.length - 1) {
                                this.writer.write(separator);
                            }
                        }
                        this.writer.writeLine("");
                    }
                    this.currentPassNumber = 2;
                    for (var rowIndex = 0; rowIndex < matrix.dataArrayLength; rowIndex++) {
                        this.invokeExporting2(rowIndex, matrix.dataArrayLength - 1, this.currentPassNumber, this.maximumPassNumber);
                        if (this.isStopped)
                            return;
                        for (var columnIndex = 0; columnIndex < matrix.fields.length; columnIndex++) {
                            var text = matrix.fields[columnIndex].dataArray[rowIndex];
                            if (text == null)
                                text = "";
                            if (text != "") {
                                if ((text.indexOf(separator) != -1) ||
                                    (text.indexOf('\"') != -1) || (text.indexOf("\n") != -1)) {
                                    text = text.sti.replaceAll("\"", "\"\"");
                                    text = "\"" + text + "\"";
                                }
                                this.writer.write(text);
                            }
                            if (columnIndex < matrix.fields.length - 1) {
                                this.writer.write(separator);
                            }
                        }
                        this.writer.writeLine("");
                    }
                    this.writer.flush();
                    if (matrix != null) {
                        matrix.clear();
                        matrix = null;
                    }
                };
                return StiCsvExportService;
            }(Export.StiExportService));
            Export.StiCsvExportService = StiCsvExportService;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));