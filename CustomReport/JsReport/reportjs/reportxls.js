var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StiString = Stimulsoft.System.StiString;
            var StiDashboardExport = Stimulsoft.Report.Dashboard.StiDashboardExport;
            var IStiDashboard = Stimulsoft.Report.Dashboard.IStiDashboard;
            var Hashtable = Stimulsoft.System.Collections.Hashtable;
            var Color = Stimulsoft.System.Drawing.Color;
            var Char = Stimulsoft.System.Char;
            var StiPagesCollection = Stimulsoft.Report.Components.StiPagesCollection;
            var Size = Stimulsoft.System.Drawing.Size;
            var StiTextHorAlignment = Stimulsoft.Base.Drawing.StiTextHorAlignment;
            var StiPenStyle = Stimulsoft.Base.Drawing.StiPenStyle;
            var StiVertAlignment = Stimulsoft.Base.Drawing.StiVertAlignment;
            var StiText = Stimulsoft.Report.Components.StiText;
            var StiBrush = Stimulsoft.Base.Drawing.StiBrush;
            var StringBuilder = Stimulsoft.System.Text.StringBuilder;
            var IStiExportImageExtended = Stimulsoft.Report.Components.IStiExportImageExtended;
            var Encoding = Stimulsoft.System.Text.Encoding;
            var StiTextRenderer = Stimulsoft.Base.Drawing.StiTextRenderer;
            var StiRichText = Stimulsoft.Report.Components.StiRichText;
            var MemoryStream = Stimulsoft.System.IO.MemoryStream;
            var XmlTextWriter = Stimulsoft.System.Xml.XmlTextWriter;
            var DateTime = Stimulsoft.System.DateTime;
            var StiCheckBox = Stimulsoft.Report.Components.StiCheckBox;
            var StiZipWriter20 = Stimulsoft.Base.Zip.StiZipWriter20;
            var CultureInfo = Stimulsoft.System.Globalization.CultureInfo;
            var StiPageOrientation = Stimulsoft.Report.Components.StiPageOrientation;
            var StiHtmlState = Stimulsoft.Base.Drawing.StiHtmlState;
            var StiHtmlTagsState = Stimulsoft.Base.Drawing.StiHtmlTagsState;
            var StiExcel2007ExportService = /** @class */ (function (_super) {
                __extends(StiExcel2007ExportService, _super);
                function StiExcel2007ExportService() {
                    var _this = _super !== null && _super.apply(this, arguments) || this;
                    _this.matrix = null;
                    _this.fontList = null;
                    _this.fillList = null;
                    _this.borderList = null;
                    _this.xfList = null;
                    _this.sstList = null;
                    _this.sstHash = null;
                    _this.sstHashIsTags = null;
                    _this.imageList = null;
                    _this.formatList = null;
                    _this.sstCount = 0;
                    _this.sheetNameList = null;
                    _this.imageListOffset = 0;
                    _this.printAreasList = null;
                    _this.matrixList = null;
                    _this.firstPageIndexList = null;
                    _this.hyperlinkList = null;
                    _this.minRowList = null;
                    _this.maxRowList = null;
                    _this.useOnePageHeaderAndFooter = false;
                    _this.exportDataOnly = false;
                    _this.exportObjectFormatting = true;
                    _this.exportEachPageToSheet = false;
                    _this.exportHorizontalPageBreaks = false;
                    _this.imageResolution = 1;
                    _this.imageQuality = 0.75;
                    _this.imageCache = null;
                    _this.restrictEditing = Export.StiExcel2007RestrictEditing.No;
                    _this.reportCulture = null;
                    _this.docCompanyString = null;
                    _this.docLastModifiedString = null;
                    _this.xmlIndentation = 1;
                    _this.wrongUrlSymbols = "\x20\x22\x23\x27\x2a\x2c\x3b\x3c\x3e\x5b\x5e\x60\x7b\x7c\x7d";
                    _this.refChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
                    // conversion from hundredths of inch to twips
                    _this.HiToTwips = 14.4 / 20 * 1.028;
                    // conversion from twips to units of column
                    _this.TwipsToColinfo = 2.438 * 0.921 * 0.075 * 1.03 * 0.99 * 1.01;
                    return _this;
                }
                StiExcel2007ExportService.prototype.getDefaultExtension = function () {
                    return "xlsx";
                };
                /// <summary>
                /// Exports a document to the stream without dialog of the saving file.
                /// </summary>
                /// <param name="report">A report which is to be exported.</param>
                /// <param name="stream">A stream in which report will be exported.</param>
                /// <param name="settings">A settings for the report exporting.</param>
                StiExcel2007ExportService.prototype.exportTo = function (report, stream, settings) {
                    this.exportExcel(report, stream, settings);
                };
                StiExcel2007ExportService.prototype.exportToAsync = function (onExport, report, stream, settings) {
                    var _this = this;
                    Stimulsoft.Report.Export.StiExportImageHelper.convertAllImages(report, Stimulsoft.System.Drawing.Imaging.ImageFormat.Jpeg)
                        .try(function () {
                        //#region Export Dashboard
                        if (!report.isDocument && report.getCurrentPage().sti.is(IStiDashboard)) {
                            StiDashboardExport.exportAsync(report, stream, settings).try(function () { return onExport(); });
                            return;
                        }
                        //#endregion
                        _this.exportTo(report, stream, settings);
                        onExport();
                    });
                };
                // struct DataFont
                // GetLineStyle
                StiExcel2007ExportService.prototype.getLineStyle = function (border) {
                    var penStyle = StiPenStyle.None;
                    var width = 0;
                    var mediumWidth = 1.5;
                    var thickWidth = 3;
                    if (border != null) {
                        penStyle = border.style;
                        width = border.size;
                    }
                    switch (penStyle) {
                        case StiPenStyle.Solid:
                            if (width > thickWidth)
                                return "thick";
                            if (width > mediumWidth)
                                return "medium";
                            return "thin";
                        case StiPenStyle.Dot:
                            if (width > mediumWidth)
                                return "dotted";
                            return "hair";
                        case StiPenStyle.Dash:
                            if (width > mediumWidth)
                                return "mediumDashed";
                            return "dashed";
                        case StiPenStyle.DashDot:
                            if (width > mediumWidth)
                                return "mediumDashDot";
                            return "dashDot";
                        case StiPenStyle.DashDotDot:
                            if (width > mediumWidth)
                                return "mediumDashDotDot";
                            return "dashDotDot";
                        case StiPenStyle.Double:
                            return "double";
                        default:
                            return null;
                    }
                };
                // this.getRefString
                StiExcel2007ExportService.prototype.getRefString = function (column, row) {
                    var columnHigh = Math.trunc(column / 26);
                    var columnLow = Math.trunc(column % 26);
                    var output = new StringBuilder();
                    if (columnHigh > 0) {
                        output.append(this.refChars.charAt(columnHigh - 1));
                    }
                    output.append(this.refChars.charAt(columnLow));
                    output.append((row + 1).toString());
                    return output.toString();
                };
                StiExcel2007ExportService.prototype.getRefAbsoluteString = function (column, row) {
                    var columnHigh = Math.trunc(column / 26);
                    var columnLow = Math.trunc(column % 26);
                    var output = new StringBuilder();
                    output.append("$");
                    if (columnHigh > 0) {
                        output.append(this.refChars.charAt(columnHigh - 1));
                    }
                    output.append(this.refChars.charAt(columnLow));
                    output.append("$");
                    output.append((row + 1).toString());
                    return output.toString();
                };
                // FloatToString
                StiExcel2007ExportService.prototype.floatToString = function (number_) {
                    var output = number_.toString().replace(",", ".");
                    return output;
                };
                // StringToUrl
                StiExcel2007ExportService.prototype.stringToUrl = function (input) {
                    var output = new StringBuilder();
                    for (var i = 0; i < input.length; i++) {
                        var byt = input.charAt(i);
                        if (byt == "'") {
                            continue;
                        }
                        else {
                            if ((byt.charCodeAt(0) < 0x20) || (this.wrongUrlSymbols.indexOf(byt) != -1)) {
                                output.append(StiString.format("%{0:x2}", byt.charCodeAt(0)));
                            }
                            else {
                                output.append(byt);
                            }
                        }
                    }
                    return output.toString();
                };
                // GetFontNumber
                StiExcel2007ExportService.prototype.getFontNumber = function (dataIn) {
                    if (this.fontList.length > 0) {
                        for (var index = 0; index < this.fontList.length; index++) {
                            if (this.fontList[index].sti.equals(dataIn)) {
                                // is already in table, return number
                                return index;
                            }
                        }
                    }
                    // add to table, return number
                    this.fontList.add(dataIn);
                    var temp = this.fontList.length - 1;
                    return temp;
                };
                // GetFillNumber
                StiExcel2007ExportService.prototype.getFillNumber = function (dataIn) {
                    if (this.fillList.length > 0) {
                        for (var index = 0; index < this.fillList.length; index++) {
                            if (this.fillList[index].sti.equals(dataIn)) {
                                // is already in table, return number
                                return index;
                            }
                        }
                    }
                    // add to table, return number
                    this.fillList.add(dataIn);
                    var temp = this.fillList.length - 1;
                    return temp;
                };
                // GetBorderNumber
                StiExcel2007ExportService.prototype.getBorderNumber = function (dataIn) {
                    if (this.borderList.length > 0) {
                        for (var index = 0; index < this.borderList.length; index++) {
                            if (this.borderList[index].sti.equals(dataIn)) {
                                // is already in table, return number
                                return index;
                            }
                        }
                    }
                    // add to table, return number
                    this.borderList.add(dataIn);
                    var temp = this.borderList.length - 1;
                    return temp;
                };
                // GetXFNumber
                StiExcel2007ExportService.prototype.getXFNumber = function (dataIn) {
                    if (this.xfList.length > 0) {
                        for (var index = 0; index < this.xfList.length; index++) {
                            if (this.xfList[index].equalDataXF(dataIn)) {
                                // are already in table, return number
                                return index;
                            }
                        }
                    }
                    // add to table, return number
                    this.xfList.add(dataIn);
                    var temp = this.xfList.length - 1;
                    return temp;
                };
                // GetSSTNumber
                StiExcel2007ExportService.prototype.getSSTNumber = function (dataIn) {
                    this.sstCount++;
                    if (this.sstList.length > 0) {
                        if (this.sstHash.containsKey(dataIn)) {
                            // is already in table, return number
                            return this.sstHash.get(dataIn);
                        }
                    }
                    // add to table, return number
                    this.sstList.add(dataIn);
                    var temp = this.sstList.length - 1;
                    this.sstHash.add(dataIn, temp);
                    return temp;
                };
                // GetFormatNumber
                StiExcel2007ExportService.prototype.getFormatNumber = function (dataIn) {
                    if (this.formatList.length > 0) {
                        for (var index = 0; index < this.formatList.length; index++) {
                            if (this.formatList[index] == dataIn) {
                                return index + 164;
                            }
                        }
                    }
                    this.formatList.add(dataIn);
                    var temp = this.formatList.length - 1;
                    return temp + 164;
                };
                StiExcel2007ExportService.prototype.convert = function (x) {
                    return (x * this.HiToTwips);
                };
                StiExcel2007ExportService.prototype.compareExcellSheetNames = function (name1, name2) {
                    var st1 = name1;
                    if ((st1 == null) || (st1.length == 0))
                        st1 = "";
                    var st2 = name2;
                    if ((st2 == null) || (st2.length == 0))
                        st2 = "";
                    return (st1 == st2);
                };
                // prepare data
                StiExcel2007ExportService.prototype.prepareData = function () {
                    this.fontList = new Array();
                    this.fillList = new Array();
                    this.borderList = new Array();
                    this.xfList = new Array();
                    this.sstList = new Array();
                    this.sstHash = new Hashtable();
                    this.sstHashIsTags = new Hashtable();
                    this.imageList = new Array();
                    this.formatList = new Array();
                    this.sheetNameList = new Array();
                    this.sstCount = 0;
                    this.printAreasList = new Array();
                    this.matrixList = new Array();
                    this.firstPageIndexList = new Array();
                    this.minRowList = new Array();
                    this.maxRowList = new Array();
                    this.imageCache = new Report.StiImageCache(StiOptions.Export.Excel.AllowImageComparer, true, Report.ImageFormat.Jpeg, this.imageQuality, false);
                    // add default
                    var tempFont = new DataFont("Arial", false, false, false, false, 10, Color.black, 0x01, 0);
                    this.getFontNumber(tempFont);
                    var tempFill = new DataFill("none", Color.transparent, Color.black);
                    this.getFillNumber(tempFill);
                    tempFill = new DataFill("gray125", Color.transparent, Color.black);
                    this.getFillNumber(tempFill);
                    var tempBorder = new DataBorder(null, null, null, null);
                    this.getBorderNumber(tempBorder);
                    var tempXF = new DataXF(0, 0, 0, 0, 0, StiTextHorAlignment.Left, StiVertAlignment.Bottom, 0, false, false, false);
                    this.getXFNumber(tempXF);
                };
                // WriteContentTypes
                StiExcel2007ExportService.prototype.writeContentTypes = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    //// writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);TODO??
                    //// writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);TODO??
                    writer.writeStartDocument();
                    writer.writeStartElement("Types");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/content-types");
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "rels");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-package.relationships+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "xml");
                    writer.writeAttributeString("ContentType", "application/xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "jpeg");
                    writer.writeAttributeString("ContentType", "image/jpeg");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "png");
                    writer.writeAttributeString("ContentType", "image/png");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "vml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.vmlDrawing");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/docProps/app.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.extended-properties+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/docProps/core.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-package.core-properties+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/xl/workbook.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml");
                    writer.writeEndElement();
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", StiString.format("/xl/worksheets/sheet{0}.xml", index + 1));
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml");
                        writer.writeEndElement();
                    }
                    // 			writer.writeStartElement("Override");
                    // 			writer.writeAttributeString("PartName", "/xl/theme/theme1.xml" );
                    // 			writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.theme+xml");
                    // 			writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/xl/styles.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml");
                    writer.writeEndElement();
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", StiString.format("/xl/drawings/drawing{0}.xml", index + 1));
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.drawing+xml");
                        writer.writeEndElement();
                    }
                    if (this.sstList.length > 0) {
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", "/xl/sharedStrings.xml");
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.spreadsheetml.sharedStrings+xml");
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteMainRels
                StiExcel2007ExportService.prototype.writeMainRels = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId1");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument");
                    writer.writeAttributeString("Target", "xl/workbook.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId2");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties");
                    writer.writeAttributeString("Target", "docProps/core.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId3");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties");
                    writer.writeAttributeString("Target", "docProps/app.xml");
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteDocPropsApp
                StiExcel2007ExportService.prototype.writeDocPropsApp = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Properties");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties");
                    writer.writeAttributeString("xmlns:vt", "http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes");
                    writer.writeElementString("Application", "Microsoft Excel");
                    writer.writeElementString("DocSecurity", "0");
                    writer.writeElementString("ScaleCrop", "false");
                    writer.writeElementString("Company", this.docCompanyString == null ? "" : this.docCompanyString);
                    writer.writeElementString("LinksUpToDate", "false");
                    writer.writeElementString("SharedDoc", "false");
                    writer.writeElementString("HyperlinksChanged", "false");
                    writer.writeElementString("AppVersion", "12.0000");
                    writer.writeStartElement("HeadingPairs");
                    writer.writeStartElement("vt:vector");
                    writer.writeAttributeString("size", "4");
                    writer.writeAttributeString("baseType", "variant");
                    writer.writeStartElement("vt:variant");
                    writer.writeElementString("vt:lpstr", "Worksheets");
                    writer.writeEndElement();
                    writer.writeStartElement("vt:variant");
                    writer.writeElementString("vt:i4", StiString.format("{0}", this.sheetNameList.length));
                    writer.writeEndElement();
                    writer.writeStartElement("vt:variant");
                    writer.writeElementString("vt:lpstr", "Named Ranges");
                    writer.writeEndElement();
                    writer.writeStartElement("vt:variant");
                    writer.writeElementString("vt:i4", StiString.format("{0}", this.sheetNameList.length));
                    writer.writeEndElement(); // vt:variant
                    writer.writeEndElement(); // vt:vector
                    writer.writeEndElement(); // HeadingPair
                    writer.writeStartElement("TitlesOfParts");
                    writer.writeStartElement("vt:vector");
                    writer.writeAttributeString("size", StiString.format("{0}", this.sheetNameList.length * 2));
                    writer.writeAttributeString("baseType", "lpstr");
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        writer.writeElementString("vt:lpstr", this.sheetNameList[index]);
                    }
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        writer.writeElementString("vt:lpstr", StiString.format("'{0}'!Print_Area", this.sheetNameList[index]));
                    }
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteDocPropsCore
                StiExcel2007ExportService.prototype.writeDocPropsCore = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("cp:coreProperties");
                    writer.writeAttributeString("xmlns:cp", "http://schemas.openxmlformats.org/package/2006/metadata/core-properties");
                    writer.writeAttributeString("xmlns:dc", "http://purl.org/dc/elements/1.1/");
                    writer.writeAttributeString("xmlns:dcterms", "http://purl.org/dc/terms/");
                    writer.writeAttributeString("xmlns:dcmitype", "http://purl.org/dc/dcmitype/");
                    writer.writeAttributeString("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
                    var dateTime = StiString.format("{0}{1}", DateTime.now.toString("yyyy-MM-dd"), DateTime.now.toString("THH:mm:ssZ"));
                    // string creator = Stimulsoft.Report.Export.StiExportUtils.GetReportVersion();
                    writer.writeElementString("dc:title", this.report.reportName == null ? "" : this.report.reportName);
                    writer.writeElementString("dc:subject", this.report.reportAlias == null ? "" : this.report.reportAlias);
                    writer.writeElementString("dc:creator", this.report.reportAuthor == null ? "" : this.report.reportAuthor);
                    writer.writeElementString("dc:description", this.report.reportDescription == null ? "" : this.report.reportDescription);
                    writer.writeElementString("cp:lastModifiedBy", this.docLastModifiedString == null ? "" : this.docLastModifiedString);
                    writer.writeStartElement("dcterms:created");
                    writer.writeAttributeString("xsi:type", "dcterms:W3CDTF");
                    writer.writeString(dateTime);
                    writer.writeEndElement();
                    writer.writeStartElement("dcterms:modified");
                    writer.writeAttributeString("xsi:type", "dcterms:W3CDTF");
                    writer.writeString(dateTime);
                    writer.writeEndElement();
                    writer.writeElementString("cp:contentStatus", Stimulsoft.StiVersion.platform());
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteWorkbookRels
                StiExcel2007ExportService.prototype.writeWorkbookRels = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", index + 1));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet");
                        writer.writeAttributeString("Target", StiString.format("worksheets/sheet{0}.xml", index + 1));
                        writer.writeEndElement();
                    }
                    // 			writer.writeStartElement("Relationship");
                    // 			writer.writeAttributeString("Id", StiString.format("rId{0}", this.sheetNameList.length + 1));
                    // 			writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/theme" );
                    // 			writer.writeAttributeString("Target", "theme/theme1.xml");
                    // 			writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", StiString.format("rId{0}", this.sheetNameList.length + 2));
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles");
                    writer.writeAttributeString("Target", "styles.xml");
                    writer.writeEndElement();
                    if (this.sstCount > 0) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", this.sheetNameList.length + 3));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/sharedStrings");
                        writer.writeAttributeString("Target", "sharedStrings.xml");
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteWorkbook
                StiExcel2007ExportService.prototype.writeWorkbook = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("workbook");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeStartElement("fileVersion");
                    writer.writeAttributeString("appName", "xl");
                    writer.writeAttributeString("lastEdited", "4");
                    writer.writeAttributeString("lowestEdited", "4");
                    writer.writeAttributeString("rupBuild", "4505");
                    writer.writeEndElement();
                    writer.writeStartElement("workbookPr");
                    writer.writeAttributeString("defaultThemeVersion", "124226");
                    writer.writeEndElement();
                    writer.writeStartElement("bookViews");
                    writer.writeStartElement("workbookView");
                    writer.writeAttributeString("xWindow", "120");
                    writer.writeAttributeString("yWindow", "15");
                    writer.writeAttributeString("windowWidth", "18975");
                    writer.writeAttributeString("windowHeight", "11955");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("sheets");
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        writer.writeStartElement("sheet");
                        writer.writeAttributeString("name", this.sheetNameList[index]);
                        writer.writeAttributeString("sheetId", StiString.format("{0}", index + 1));
                        writer.writeAttributeString("r:id", StiString.format("rId{0}", index + 1));
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                    writer.writeStartElement("definedNames");
                    for (var index = 0; index < this.sheetNameList.length; index++) {
                        var area = this.printAreasList[index];
                        if (area.height > 1048575)
                            area.height = 1048575;
                        if (area.width > 16383)
                            area.width = 16383;
                        var sref = this.getRefAbsoluteString(area.width, area.height);
                        writer.writeStartElement("definedName");
                        writer.writeAttributeString("name", "_xlnm.Print_Area");
                        writer.writeAttributeString("localSheetId", StiString.format("{0}", index));
                        writer.writeString(StiString.format("'{0}'!$A$1:{1}", this.sheetNameList[index], sref));
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                    writer.writeStartElement("calcPr");
                    writer.writeAttributeString("calcId", "124519");
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteSheetRels
                StiExcel2007ExportService.prototype.writeSheetRels = function (indexSheet) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    if (this.imageList.length - this.imageListOffset > 0) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 1));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/drawing");
                        writer.writeAttributeString("Target", StiString.format("../drawings/drawing{0}.xml", indexSheet + 1));
                        writer.writeEndElement();
                    }
                    if (this.hyperlinkList.length > 0) {
                        for (var index = 0; index < this.hyperlinkList.length; index++) {
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", StiString.format("rId{0}", 2 + index));
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink");
                            writer.writeAttributeString("Target", this.hyperlinkList[index]);
                            writer.writeAttributeString("TargetMode", "External");
                            writer.writeEndElement();
                        }
                    }
                    // *#if Demo
                    if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", "dId1");
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing");
                        writer.writeAttributeString("Target", "../drawings/vmlDrawingAdditional.vml");
                        writer.writeEndElement();
                    }
                    // #endif Demo*/
                    /*#if SERVER
                        if (StiVersionX.IsSvr) {
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", "dId1");
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/vmlDrawing");
                            writer.writeAttributeString("Target", "../drawings/vmlDrawingAdditional.vml");
                            writer.writeEndElement();
                        }
                    #endif*/
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteSheet
                StiExcel2007ExportService.prototype.writeSheet = function (indexSheet, page) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("worksheet");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    if (StiOptions.Export.Excel.FitToOnePageWide) {
                        writer.writeStartElement("sheetPr");
                        writer.writeStartElement("pageSetUpPr");
                        writer.writeAttributeString("fitToPage", "1");
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    this.matrix = this.matrixList[indexSheet];
                    var minRowIndex = this.minRowList[indexSheet];
                    var maxRowIndex = this.maxRowList[indexSheet];
                    var printAreaSize = new Size(this.matrix.coordX.countItems - 2, maxRowIndex - minRowIndex - 1);
                    if (printAreaSize.width < 0)
                        printAreaSize.width = 0;
                    if (printAreaSize.height < 0)
                        printAreaSize.height = 0;
                    this.printAreasList.add(printAreaSize);
                    var numberStoredAsText = new Array();
                    writer.writeStartElement("dimension");
                    writer.writeAttributeString("ref", StiString.format("{0}:{1}", this.getRefString(0, 0), this.getRefString(printAreaSize.width, printAreaSize.height)));
                    writer.writeEndElement();
                    // check for locked components for FreezePanes feature
                    var paneX = 0;
                    var paneY = 0;
                    if (StiOptions.Export.Excel.AllowFreezePanes) {
                        for (var indexRow = minRowIndex; indexRow < maxRowIndex; indexRow++) {
                            for (var indexColumn = 0; indexColumn < this.matrix.coordX.countItems - 1; indexColumn++) {
                                var cell = this.matrix.cells[indexRow][indexColumn];
                                if (cell != null && cell.component != null && (cell.component.locked || (cell.component.tagValue != null && cell.component.tagValue.toString().contains("excelfreezepanes")))) {
                                    var stPlacement = cell.component.componentPlacement;
                                    if (stPlacement != null && stPlacement.length > 0 && (stPlacement.sti.startsWith("rt") || stPlacement.sti.startsWith("ph") || stPlacement.sti.startsWith("h"))) {
                                        // use the bottom left corner of the component
                                        paneX = cell.left;
                                        paneY = cell.top + cell.height + 1;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    // sheetViews
                    writer.writeStartElement("sheetViews");
                    writer.writeStartElement("sheetView");
                    if (StiOptions.Export.Excel.ColumnsRightToLeft) {
                        writer.writeAttributeString("rightToLeft", "1");
                    }
                    if (!StiOptions.Export.Excel.ShowGridLines) {
                        writer.writeAttributeString("showGridLines", "0");
                    }
                    writer.writeAttributeString("tabSelected", "1");
                    writer.writeAttributeString("workbookViewId", "0");
                    if (paneX == 0 && paneY == 0) {
                        writer.writeStartElement("selection");
                        writer.writeAttributeString("activeCell", "A1");
                        writer.writeAttributeString("sqref", "A1");
                        writer.writeEndElement();
                    }
                    else {
                        if (paneX == 0) {
                            writer.writeStartElement("pane");
                            writer.writeAttributeString("ySplit", paneY.toString());
                            writer.writeAttributeString("topLeftCell", this.getRefString(paneX, paneY));
                            writer.writeAttributeString("activePane", "bottomLeft");
                            writer.writeAttributeString("state", "frozen");
                            writer.writeEndElement();
                            writer.writeStartElement("selection");
                            writer.writeAttributeString("pane", "bottomLeft");
                            writer.writeAttributeString("activeCell", this.getRefString(0, paneY));
                            writer.writeAttributeString("sqref", this.getRefString(0, paneY));
                            writer.writeEndElement();
                        }
                        else {
                            writer.writeStartElement("pane");
                            writer.writeAttributeString("xSplit", paneX.toString());
                            writer.writeAttributeString("ySplit", paneY.toString());
                            writer.writeAttributeString("topLeftCell", this.getRefString(paneX, paneY));
                            writer.writeAttributeString("activePane", "bottomRight");
                            writer.writeAttributeString("state", "frozen");
                            writer.writeEndElement();
                            writer.writeStartElement("selection");
                            writer.writeAttributeString("pane", "topRight");
                            writer.writeAttributeString("activeCell", this.getRefString(paneX, 0));
                            writer.writeAttributeString("sqref", this.getRefString(paneX, 0));
                            writer.writeEndElement();
                            writer.writeStartElement("selection");
                            writer.writeAttributeString("pane", "bottomLeft");
                            writer.writeAttributeString("activeCell", this.getRefString(0, paneY));
                            writer.writeAttributeString("sqref", this.getRefString(0, paneY));
                            writer.writeEndElement();
                            writer.writeStartElement("selection");
                            writer.writeAttributeString("pane", "bottomRight");
                            writer.writeAttributeString("activeCell", this.getRefString(paneX, paneY));
                            writer.writeAttributeString("sqref", this.getRefString(paneX, paneY));
                            writer.writeEndElement();
                        }
                    }
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("sheetFormatPr");
                    writer.writeAttributeString("defaultRowHeight", StiString.format("{0}", 15));
                    writer.writeEndElement();
                    var coordXKey = this.matrix.coordX.getKeys();
                    var coordYKey = this.matrix.coordY.getKeys();
                    // columns widths
                    if (this.exportObjectFormatting) {
                        writer.writeStartElement("cols");
                        for (var indexCol = 0; indexCol < this.matrix.coordX.countItems - 1; indexCol++) {
                            var value2 = this.matrix.coordX.getByIndex(indexCol + 1, coordXKey);
                            var value1 = this.matrix.coordX.getByIndex(indexCol, coordXKey);
                            var colWidth = this.convert(value2 - value1) * this.TwipsToColinfo;
                            writer.writeStartElement("col");
                            writer.writeAttributeString("min", StiString.format("{0}", indexCol + 1));
                            writer.writeAttributeString("max", StiString.format("{0}", indexCol + 1));
                            writer.writeAttributeString("width", StiString.format("{0}", colWidth));
                            writer.writeAttributeString("customWidth", "1");
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                    }
                    // rows
                    var richtextForConvert = null; // RichTextBox = null;
                    var readyCells = Array.create(Boolean, maxRowIndex + 1, this.matrix.coordX.countItems);
                    var mergedCellsStyle = Array.create(Number, maxRowIndex + 1, this.matrix.coordX.countItems);
                    var mergedCells = new Array();
                    var hlinks = new Array();
                    writer.writeStartElement("sheetData");
                    for (var indexRow = minRowIndex; indexRow < maxRowIndex; indexRow++) {
                        // this.invokeExporting(indexRow, this.matrix.coordY.count, this.currentPassNumber, this.maximumPassNumber);
                        var height = (this.matrix.coordY.getByIndex(indexRow + 1, coordYKey)
                            - this.matrix.coordY.getByIndex(indexRow, coordYKey));
                        writer.writeStartElement("row");
                        writer.writeAttributeString("r", StiString.format("{0}", indexRow + 1 - minRowIndex));
                        writer.writeAttributeString("spans", StiString.format("{0}:{1}", 1, this.matrix.coordX.countItems - 1));
                        if (this.exportObjectFormatting) {
                            writer.writeAttributeString("ht", StiString.format("{0}", this.convert(height)));
                            writer.writeAttributeString("customHeight", "1");
                        }
                        for (var indexColumn = 0; indexColumn < this.matrix.coordX.countItems - 1; indexColumn++) {
                            var cell = this.matrix.cells[indexRow][indexColumn];
                            if ((readyCells[indexRow] && readyCells[indexRow][indexColumn] == false) && (cell != null)) {
                                // readyCells & cells exists
                                readyCells[indexRow][indexColumn] = true;
                                var rtf = cell.component.sti.as(StiRichText);
                                var textComp = cell.component.sti.as(StiText);
                                var str = cell.text;
                                /*if ((rtf != null) && (rtf.RtfText != "")) {
                                    if (richtextForConvert == null) richtextForConvert = new RichTextBox();
                                    richtextForConvert.Rtf = rtf.RtfText;
                                    str = richtextForConvert.Text;
                                }*/ // TODO?
                                var checkComp = cell.component.sti.as(StiCheckBox);
                                var hasCheckBoxExcelDataValue = false;
                                if ((checkComp != null) && (checkComp.excelDataValue != null) && (checkComp.excelDataValue.length > 0)) {
                                    hasCheckBoxExcelDataValue = true;
                                    str = checkComp.excelDataValue;
                                }
                                // Hyperlink
                                var hyperlink = null;
                                if (cell.component.hyperlinkValue != null) {
                                    hyperlink = cell.component.hyperlinkValue.toString().trim();
                                    if (hyperlink.length > 0 && !hyperlink.sti.startsWith("javascript:")) {
                                        var description = str;
                                        if (description == null || description.length == 0)
                                            description = hyperlink;
                                        var range = new CellRangeAddress(indexRow - minRowIndex, indexRow - minRowIndex + cell.height, indexColumn, indexColumn + cell.width);
                                        var hl = new HlinkData(range, description, hyperlink);
                                        hlinks.add(hl);
                                    }
                                }
                                // Image
                                var isImage = false;
                                var exportImage = cell.component.sti.as(IStiExportImageExtended);
                                if (exportImage != null) {
                                    var zoom = this.imageResolution;
                                    /*if (StiOptions.Export.Excel.UseImageResolution &&
                                        (exportImage.sti.as(StiImage) != null && (exportImage.sti.as(StiImage).ImageToDraw != null)
                                    {
                                        float dpix = (exportImage.sti.as(StiImage).ImageToDraw.HorizontalResolution;
                                        if (dpix >= 50 && dpix <= 600) zoom *= dpix / 100f;
                                    }*/ // TODO?
                                    var image = null;
                                    if (cell.component.isExportAsImage(Report.StiExportFormat.Excel2007)) {
                                        var REFrsImageResolution = { ref: this.imageResolution };
                                        image = exportImage.getImage(REFrsImageResolution, Report.StiExportFormat.Excel);
                                    }
                                    if (image != null) {
                                        var img = this.matrix.getRealImageData(cell, image);
                                        if (img != null)
                                            image = img;
                                        var imageIndex = this.imageCache.addImageIntRaw(image, image.imageFormat);
                                        var imageData = new ExcelImageData((indexRow - minRowIndex), 0, (indexColumn), 0, (indexRow - minRowIndex + 1 + cell.height), 0, (indexColumn + 1 + cell.width), 0, imageIndex, hyperlink);
                                        this.imageList.add(imageData);
                                        // image.Dispose();
                                        isImage = true;
                                    }
                                }
                                // check for exceltext tag
                                var isExcelText = false;
                                if (cell.component != null && cell.component.tagValue != null) {
                                    var cellTag = cell.component.tagValue.toString().toLowerCase();
                                    if (cellTag.indexOf("exceltext") != -1) {
                                        isExcelText = true;
                                        numberStoredAsText.add(this.getRefString(indexColumn, indexRow));
                                    }
                                }
                                // Scan value format
                                var inputFormat = "";
                                if (textComp != null)
                                    inputFormat = textComp.format;
                                var isFormatCurrency = false;
                                var isFormatNumeric = false;
                                var isFormatPercent = false;
                                var isFormatDate = false;
                                var isFormatTime = false;
                                var isFormatCustom = false;
                                var isDefaultFormat = false;
                                var outputFormat = "";
                                var decimalDigits = 2;
                                var groupDigits = 0;
                                var currencySymbol = this.reportCulture.numberFormat.currencySymbol;
                                var currencyPositionBefore = this.reportCulture.numberFormat.currencyPositivePattern == 0 || this.reportCulture.numberFormat.currencyPositivePattern == 2;
                                var negativeBraces = false;
                                var hideZeros = (textComp != null) && textComp.hideZeros;
                                var positivePatternString = null;
                                var negativePatternString = null;
                                var posPatternDelimiter = inputFormat.indexOf("|");
                                if (posPatternDelimiter != -1) {
                                    positivePatternString = Export.StiExportUtils.getPositivePattern(inputFormat.charCodeAt(posPatternDelimiter + 1) - 65);
                                    negativePatternString = Export.StiExportUtils.getNegativePattern(inputFormat.charCodeAt(posPatternDelimiter + 2) - 65);
                                    inputFormat = inputFormat.substr(0, posPatternDelimiter);
                                }
                                // get value format
                                if ((inputFormat != null) && (inputFormat.length > 0)) {
                                    if (inputFormat[0] == "C") {
                                        isFormatCurrency = true;
                                    }
                                    else if (inputFormat[0] == "N") {
                                        isFormatNumeric = true;
                                    }
                                    else if (inputFormat[0] == "P") {
                                        isFormatPercent = true;
                                    }
                                    else if (inputFormat[0] == "D") {
                                        isFormatDate = true;
                                    }
                                    else if (inputFormat[0] == "T") {
                                        isFormatTime = true;
                                    }
                                    else if (inputFormat[0] == "U") {
                                        isFormatCustom = true;
                                    }
                                    if (inputFormat.length == 1) {
                                        isDefaultFormat = true;
                                    }
                                    else {
                                        if (isFormatCurrency || isFormatNumeric || isFormatPercent) {
                                            // scan parameters
                                            var indexPos = 1;
                                            if (Char.isDigit(inputFormat[indexPos])) {
                                                var decimalSB = new StringBuilder();
                                                while ((indexPos < inputFormat.length) && (Char.isDigit(inputFormat[indexPos]))) {
                                                    decimalSB.append(inputFormat[indexPos]);
                                                    indexPos++;
                                                }
                                                decimalDigits = parseInt(decimalSB.toString());
                                            }
                                            if ((indexPos < inputFormat.length) && (inputFormat[indexPos] == "G")) {
                                                indexPos++;
                                                groupDigits = 3;
                                            }
                                            if ((indexPos < inputFormat.length) && (inputFormat[indexPos] == "(")) {
                                                indexPos++;
                                                negativeBraces = true;
                                            }
                                            if ((indexPos < inputFormat.length) && (inputFormat[indexPos] == "." || inputFormat[indexPos] == ",")) {
                                                // excel don't allow to use custom decimal separator from file, only from options menu
                                                indexPos++;
                                            }
                                            if ((indexPos < inputFormat.length) &&
                                                ((inputFormat[indexPos] == "+") || (inputFormat[indexPos] == "-"))) {
                                                if (inputFormat[indexPos] == "+")
                                                    currencyPositionBefore = true;
                                                indexPos++;
                                                if (indexPos < inputFormat.length) {
                                                    currencySymbol = inputFormat.substring(indexPos);
                                                }
                                                else {
                                                    currencySymbol = "";
                                                }
                                            }
                                        }
                                    }
                                }
                                if (!(isFormatCurrency || isFormatNumeric || isFormatPercent)) {
                                    isDefaultFormat = true;
                                }
                                if (isFormatCurrency && isDefaultFormat)
                                    isDefaultFormat = false; // Excel2007 do not have default format for currency
                                if (hideZeros && !StiString.isNullOrEmpty(inputFormat))
                                    isDefaultFormat = false;
                                if (isExcelText)
                                    isDefaultFormat = true;
                                // make format string
                                if (!isDefaultFormat) {
                                    if (posPatternDelimiter != -1) {
                                        var outputSB = new StringBuilder();
                                        if (groupDigits > 1) {
                                            outputSB.append("#,");
                                            outputSB.appendCount("#", groupDigits - 1);
                                        }
                                        outputSB.append("0");
                                        if (decimalDigits > 0) {
                                            outputSB.append(".");
                                            outputSB.appendCount("0", decimalDigits);
                                        }
                                        var nn = outputSB.toString();
                                        var positivePattern = positivePatternString.replace("n", nn).replace("$", "\"" + currencySymbol + "\"");
                                        var negativePattern = negativePatternString.replace("n", nn).replace("$", "\"" + currencySymbol + "\"");
                                        outputFormat = positivePattern + ";" + negativePattern + (hideZeros ? ";" : "");
                                    }
                                    else {
                                        var outputSB = new StringBuilder();
                                        if ((isFormatCurrency) && (currencyPositionBefore == true)) {
                                            outputSB.append("\"");
                                            outputSB.append(currencySymbol);
                                            outputSB.append("\"");
                                        }
                                        if (groupDigits > 1) {
                                            outputSB.append("#,");
                                            outputSB.appendCount("#", groupDigits - 1);
                                        }
                                        outputSB.append("0");
                                        if (decimalDigits > 0) {
                                            outputSB.append(".");
                                            outputSB.appendCount("0", decimalDigits);
                                        }
                                        if ((isFormatCurrency) && (currencyPositionBefore == false)) {
                                            outputSB.append("\"");
                                            outputSB.append(currencySymbol);
                                            outputSB.append("\"");
                                        }
                                        if (isFormatPercent) {
                                            outputSB.append("%");
                                        }
                                        outputFormat = outputSB.toString();
                                        var negativePattern = (negativeBraces ? "(" : "-") + outputFormat + (negativeBraces ? ")" : "");
                                        if (hideZeros) {
                                            outputFormat = outputFormat + ";" + negativePattern + ";";
                                        }
                                        else {
                                            if (negativeBraces)
                                                outputFormat = outputFormat + ";" + negativePattern;
                                        }
                                    }
                                }
                                var formatIndex = 0; // general
                                if (isDefaultFormat) {
                                    if (isFormatNumeric) {
                                        formatIndex = 4; // decimal	# ##0.00
                                    }
                                    // 							if (isFormatCurrency)
                                    // 							{
                                    // 								formatIndex = 7;	//currency  # ##0.00
                                    // 							}
                                    if (isFormatPercent) {
                                        formatIndex = 10; // percent 0.00%
                                    }
                                    if (isFormatDate) {
                                        formatIndex = 14; // date M/D/YY
                                    }
                                    if (isFormatTime) {
                                        formatIndex = 21; // time h:mm:ss
                                    }
                                    if (isExcelText) {
                                        formatIndex = 49; // text @
                                    }
                                }
                                else {
                                    formatIndex = this.getFormatNumber(outputFormat);
                                }
                                // Style
                                var indexStyle = 0; // default style
                                if (this.exportObjectFormatting) {
                                    var style = cell.cellStyle;
                                    var tempFont = new DataFont(style.font.name, style.font.bold, style.font.italic, style.font.underline, style.font.strikeout, Math.round(style.font.sizeInPoints), style.textColor, 0x01 /*style.font.GdiCharSet*/, 0); // fontFamily auto
                                    if (hasCheckBoxExcelDataValue) {
                                        tempFont = new DataFont(StiOptions.Export.CheckBoxReplacementForExcelValue.Font.name, StiOptions.Export.CheckBoxReplacementForExcelValue.Font.bold, StiOptions.Export.CheckBoxReplacementForExcelValue.Font.italic, StiOptions.Export.CheckBoxReplacementForExcelValue.Font.underline, StiOptions.Export.CheckBoxReplacementForExcelValue.Font.strikeout, Math.round(StiOptions.Export.CheckBoxReplacementForExcelValue.Font.sizeInPoints), style.textColor, 0x01 /*StiOptions.Export.CheckBoxReplacementForExcelValue.Font.GdiCharSet*/, 0); // fontFamily auto
                                    }
                                    var tempFill = new DataFill("solid", style.color, style.color);
                                    if (isImage) {
                                        tempFill = new DataFill("solid", Color.transparent, Color.transparent);
                                    }
                                    var needBorderLeft = true;
                                    var needBorderRight = true;
                                    for (var index = 0; index < cell.height + 1; index++) {
                                        if (this.matrix.bordersY[cell.top + index][cell.left] == null)
                                            needBorderLeft = false;
                                        if (this.matrix.bordersY[cell.top + index][cell.left + cell.width + 1] == null)
                                            needBorderRight = false;
                                    }
                                    var needBorderTop = true;
                                    var needBorderBottom = true;
                                    for (var index = 0; index < cell.width + 1; index++) {
                                        if (this.matrix.bordersX[cell.top][cell.left + index] == null)
                                            needBorderTop = false;
                                        if (this.matrix.bordersX[cell.top + cell.height + 1][cell.left + index] == null)
                                            needBorderBottom = false;
                                    }
                                    var tempBorder = new DataBorder((needBorderLeft ? this.matrix.bordersY[cell.top][cell.left] : null), (needBorderRight ? this.matrix.bordersY[cell.top][cell.left + cell.width + 1] : null), (needBorderTop ? this.matrix.bordersX[cell.top][cell.left] : null), (needBorderBottom ? this.matrix.bordersX[cell.top + cell.height + 1][cell.left] : null));
                                    var rightToLeft = false;
                                    if (style.textOptions != null) {
                                        rightToLeft = style.textOptions.rightToLeft;
                                    }
                                    var textWordWrap = false;
                                    if (style.textOptions != null)
                                        textWordWrap = style.textOptions.wordWrap;
                                    if (!StiString.isNullOrEmpty(str)) {
                                        if ((str.indexOf("\r") != -1) ||
                                            (str.indexOf("\n") != -1))
                                            textWordWrap = true;
                                        if ((textComp != null) && textComp.checkAllowHtmlTags() &&
                                            ((str.indexOf("<br") != -1) || (str.indexOf("<ul") != -1) || (str.indexOf("<ol") != -1) || (str.indexOf("<p") != -1)))
                                            textWordWrap = true;
                                    }
                                    var rotationAngle = 0;
                                    if (style.textOptions != null) {
                                        var tempAngle = Math.ceil(style.textOptions.angle);
                                        if ((tempAngle >= 0) && (tempAngle <= 90)) {
                                            rotationAngle = tempAngle;
                                        }
                                        if ((tempAngle >= 270) && (tempAngle < 360)) {
                                            rotationAngle = 360 - tempAngle + 90;
                                        }
                                    }
                                    var editable = (this.restrictEditing == Export.StiExcel2007RestrictEditing.ExceptEditableFields) && (cell.component != null) && (cell.component.sti.is(StiText)) && (cell.component.sti.as(StiText).Editable);
                                    var tempXF = new DataXF(formatIndex, this.getFontNumber(tempFont), this.getFillNumber(tempFill), this.getBorderNumber(tempBorder), 0, // xfId
                                    hasCheckBoxExcelDataValue ? StiOptions.Export.CheckBoxReplacementForExcelValue.HorAlignment : style.horAlignment, hasCheckBoxExcelDataValue ? StiOptions.Export.CheckBoxReplacementForExcelValue.VertAlignment : style.vertAlignment, rotationAngle, textWordWrap, rightToLeft, editable);
                                    indexStyle = this.getXFNumber(tempXF);
                                }
                                writer.writeStartElement("c");
                                writer.writeAttributeString("r", this.getRefString(indexColumn, indexRow - minRowIndex));
                                writer.writeAttributeString("s", indexStyle.toString());
                                // Range
                                if (this.exportObjectFormatting) {
                                    for (var xx = 0; xx <= cell.width; xx++) {
                                        for (var yy = 0; yy <= cell.height; yy++) {
                                            readyCells[indexRow + yy][indexColumn + xx] = true;
                                            mergedCellsStyle[indexRow + yy][indexColumn + xx] = indexStyle;
                                        }
                                    }
                                    if ((cell.width > 0) || (cell.height > 0)) {
                                        var tempCellRange = new CellRangeAddress(indexRow - minRowIndex, indexRow - minRowIndex + cell.height, indexColumn, indexColumn + cell.width);
                                        mergedCells.add(tempCellRange);
                                    }
                                }
                                else {
                                    readyCells[indexRow][indexColumn] = true;
                                    mergedCellsStyle[indexRow][indexColumn] = indexStyle;
                                }
                                // Text
                                if ((!cell.component.isExportAsImage(Report.StiExportFormat.Excel2007)) &&
                                    (((str != null) && (str.length > 0)) || ((textComp != null) && (textComp.excelDataValue != null)))) {
                                    var isFormula = false;
                                    var isNumber = false;
                                    var number_ = 0;
                                    if (textComp != null &&
                                        textComp.excelDataValue != null &&
                                        textComp.excelDataValue != "-") {
                                        var value = textComp.excelDataValue;
                                        // let sep: string = this.reportCulture.numberFormat.numberDecimalSeparator;
                                        // let value3: string = value.sti.replaceAll(".", ",").sti.replaceAll(",", sep);
                                        var value3 = value.replace(/[^\d.,-]/g, "").sti.replaceAll(",", ".");
                                        if (value3 != null && value3.length > 0) {
                                            isNumber = true;
                                            try {
                                                if (isFormatDate || isFormatTime) {
                                                    // not realized in this version
                                                    isNumber = false;
                                                }
                                                else {
                                                    number_ = parseFloat(value3);
                                                    if (isNaN(number_)) {
                                                        isNumber = false;
                                                        number_ = 0;
                                                    }
                                                }
                                            }
                                            catch (e) {
                                                Stimulsoft.System.StiError.showError(e, false);
                                                isNumber = false;
                                            }
                                        }
                                        if (isFormatCustom)
                                            isNumber = false;
                                        if (value != str && value.sti.startsWith("=")) {
                                            isFormula = true;
                                        }
                                        if ((!isNumber) && (str == null)) {
                                            str = value;
                                        }
                                    }
                                    if (isFormula) {
                                        var strs = textComp.excelDataValue.sti.replaceAll("\r", "").sti.replaceAll("\t", " ").substring(1);
                                        if (StiOptions.Export.Excel.TrimTrailingSpaces)
                                            strs = Export.StiExportUtils.trimEndWhiteSpace(strs);
                                        writer.writeElementString("f", strs);
                                    }
                                    else {
                                        if (isNumber == true) {
                                            // writer.writeElementString("v", Number.toString().sti.replaceAll('.', ','));
                                            writer.writeElementString("v", number_.toString().sti.replaceAll(",", "."));
                                        }
                                        else {
                                            var strs = str.sti.replaceAll("\r", "").sti.replaceAll("\t", " ");
                                            if (StiOptions.Export.Excel.TrimTrailingSpaces)
                                                strs = Export.StiExportUtils.trimEndWhiteSpace(strs);
                                            var indexSST = 0;
                                            if ((textComp != null) && (textComp.checkAllowHtmlTags())) {
                                                strs = this.convertAllowHtmlTagsToExcelString(textComp, strs);
                                                indexSST = this.getSSTNumber(strs);
                                                this.sstHashIsTags.add(indexSST, null);
                                            }
                                            else {
                                                indexSST = this.getSSTNumber(strs);
                                            }
                                            writer.writeAttributeString("t", "s");
                                            writer.writeElementString("v", indexSST.toString());
                                        }
                                    }
                                }
                                writer.writeEndElement();
                            }
                            else {
                                var indexStyle = 0; // default
                                if (readyCells[indexRow][indexColumn]) {
                                    indexStyle = mergedCellsStyle[indexRow][indexColumn];
                                }
                                var needBorderLeft = this.matrix.bordersY[indexRow + 0][indexColumn + 0] != null;
                                var needBorderRight = this.matrix.bordersY[indexRow + 0][indexColumn + 1] != null;
                                var needBorderTop = this.matrix.bordersX[indexRow + 0][indexColumn + 0] != null;
                                var needBorderBottom = void 0;
                                try {
                                    needBorderBottom = this.matrix.bordersX[indexRow + 1][indexColumn + 0] != null;
                                }
                                catch (e) {
                                    Stimulsoft.System.StiError.showError(e, false);
                                }
                                if (needBorderLeft || needBorderRight || needBorderTop || needBorderBottom || (indexStyle != 0)) {
                                    // Style
                                    var tempBorder = new DataBorder((needBorderLeft ? this.matrix.bordersY[indexRow + 0][indexColumn + 0] : null), (needBorderRight ? this.matrix.bordersY[indexRow + 0][indexColumn + 1] : null), (needBorderTop ? this.matrix.bordersX[indexRow + 0][indexColumn + 0] : null), (needBorderBottom ? this.matrix.bordersX[indexRow + 1][indexColumn + 0] : null));
                                    var parentXF = this.xfList[indexStyle];
                                    var tempXF = new DataXF(parentXF.FormatIndex, parentXF.FontIndex, parentXF.FillIndex, this.getBorderNumber(tempBorder), parentXF.XFId, parentXF.HorAlign, parentXF.VertAlign, parentXF.TextRotationAngle, parentXF.TextWrapped, parentXF.RightToLeft, parentXF.Editable);
                                    var newIndexStyle = this.getXFNumber(tempXF);
                                    if (!this.exportObjectFormatting)
                                        newIndexStyle = 0; // default style
                                    writer.writeStartElement("c");
                                    writer.writeAttributeString("r", this.getRefString(indexColumn, indexRow - minRowIndex));
                                    writer.writeAttributeString("s", newIndexStyle.toString());
                                    writer.writeEndElement();
                                }
                            }
                        }
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                    // if (richtextForConvert != null) richtextForConvert.Dispose();
                    // sheet protection
                    if (this.restrictEditing != Export.StiExcel2007RestrictEditing.No) {
                        writer.writeStartElement("sheetProtection");
                        writer.writeAttributeString("password", "F05F"); // *TestPassword*
                        writer.writeAttributeString("sheet", "1");
                        writer.writeAttributeString("objects", "1");
                        writer.writeAttributeString("scenarios", "1");
                        writer.writeEndElement();
                    }
                    // merged cells
                    if ((mergedCells.length > 0) && (!this.exportDataOnly || this.exportObjectFormatting)) {
                        writer.writeStartElement("mergeCells");
                        writer.writeAttributeString("count", StiString.format("{0}", mergedCells.length));
                        for (var index = 0; index < mergedCells.length; index++) {
                            var tempCellRange = mergedCells[index];
                            writer.writeStartElement("mergeCell");
                            writer.writeAttributeString("ref", StiString.format("{0}:{1}", this.getRefString(tempCellRange.FirstColumn, tempCellRange.FirstRow), this.getRefString(tempCellRange.LastColumn, tempCellRange.LastRow)));
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                    }
                    // Hyperlinks
                    if (hlinks.length > 0) {
                        var found = false;
                        for (var indexHlink = 0; indexHlink < hlinks.length; indexHlink++) {
                            var hl = hlinks[indexHlink];
                            var hyperlink = hl.Bookmark;
                            if (hyperlink.sti.startsWith("#")) {
                                // find bookmark
                                hyperlink = hyperlink.substring(1);
                                var isFounded = false;
                                for (var indexMatrix = 0; indexMatrix < this.matrixList.length; indexMatrix++) {
                                    var bookmarks = this.matrixList[indexMatrix].bookmarksTable;
                                    if (bookmarks != null) {
                                        var obj = bookmarks.get(hyperlink);
                                        if (obj != null) {
                                            var minRow = this.minRowList[indexMatrix];
                                            var maxRow = this.maxRowList[indexMatrix];
                                            var pos = obj.sti.as(Size);
                                            if ((pos.height >= minRow) && (pos.height < maxRow)) {
                                                found = true;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                            else {
                                found = true;
                            }
                            if (found)
                                break;
                        }
                        if (found) {
                            writer.writeStartElement("hyperlinks");
                            for (var indexHlink = 0; indexHlink < hlinks.length; indexHlink++) {
                                var hl = hlinks[indexHlink];
                                var hyperlink = hl.Bookmark;
                                if (hyperlink.sti.startsWith("#")) {
                                    // find bookmark
                                    hyperlink = hyperlink.substring(1);
                                    var isFounded = false;
                                    for (var indexMatrix = 0; indexMatrix < this.matrixList.length; indexMatrix++) {
                                        var bookmarks = this.matrixList[indexMatrix].bookmarksTable;
                                        if (bookmarks != null) {
                                            var obj = bookmarks.get(hyperlink);
                                            if (obj != null) {
                                                var minRow = this.minRowList[indexMatrix];
                                                var maxRow = this.maxRowList[indexMatrix];
                                                var pos = obj.sti.as(Size);
                                                if ((pos.height >= minRow) && (pos.height < maxRow)) {
                                                    hyperlink = StiString.format("'{0}'!{1}", this.sheetNameList[indexMatrix], this.getRefString(pos.width, pos.height - minRow));
                                                    isFounded = true;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                    if (isFounded) {
                                        writer.writeStartElement("hyperlink");
                                        writer.writeAttributeString("ref", this.getRefString(hl.Range.FirstColumn, hl.Range.FirstRow));
                                        writer.writeAttributeString("location", hyperlink);
                                        writer.writeAttributeString("display", hl.Description);
                                        writer.writeEndElement();
                                    }
                                }
                                else {
                                    var display = hyperlink;
                                    if (hyperlink.sti.startsWith("file:\\\\\\")) {
                                        display = hyperlink.substring(8);
                                        hyperlink = "file:///" + display;
                                    }
                                    if (hyperlink.sti.startsWith("http:")) {
                                        hyperlink = hyperlink.sti.replaceAll(" ", "");
                                    }
                                    writer.writeStartElement("hyperlink");
                                    writer.writeAttributeString("ref", this.getRefString(hl.Range.FirstColumn, hl.Range.FirstRow));
                                    writer.writeAttributeString("r:id", StiString.format("rId{0}", 2 + this.hyperlinkList.length));
                                    writer.writeAttributeString("display", display);
                                    writer.writeEndElement();
                                    this.hyperlinkList.add(this.stringToUrl(hyperlink));
                                }
                            }
                            writer.writeEndElement();
                        }
                    }
                    // page info
                    writer.writeStartElement("pageMargins");
                    writer.writeAttributeString("left", this.floatToString(page.convertToHInches(page.unit, page.margins.left) / 100));
                    writer.writeAttributeString("right", this.floatToString(page.convertToHInches(page.unit, page.margins.right) / 100));
                    writer.writeAttributeString("top", this.floatToString(page.convertToHInches(page.unit, page.margins.top) / 100));
                    writer.writeAttributeString("bottom", this.floatToString(page.convertToHInches(page.unit, page.margins.bottom) / 100));
                    writer.writeAttributeString("header", this.floatToString(0.0));
                    writer.writeAttributeString("footer", this.floatToString(0.0));
                    writer.writeEndElement();
                    writer.writeStartElement("pageSetup");
                    writer.writeAttributeString("paperSize", StiString.format("{0}", page.paperSize));
                    writer.writeAttributeString("orientation", (page.orientation == StiPageOrientation.Portrait ? "portrait" : "landscape"));
                    if (StiOptions.Export.Excel.FitToOnePageWide) {
                        writer.writeAttributeString("fitToHeight", "0");
                    }
                    // 			writer.writeAttributeString("verticalDpi", StiString.format("{0}", 0));
                    // 			writer.writeAttributeString("r:id", StiString.format("rId{0}", indexSheet + 1));
                    writer.writeEndElement();
                    var horizontalPageBreaksCount = this.matrix.horizontalPageBreaks.length;
                    if ((this.exportHorizontalPageBreaks) && (horizontalPageBreaksCount > 0)) {
                        writer.writeStartElement("rowBreaks");
                        writer.writeAttributeString("count", horizontalPageBreaksCount.toString());
                        writer.writeAttributeString("manualBreakCount", horizontalPageBreaksCount.toString());
                        for (var indexBreak = 0; indexBreak < horizontalPageBreaksCount; indexBreak++) {
                            writer.writeStartElement("brk");
                            writer.writeAttributeString("id", StiString.format("{0}", this.matrix.horizontalPageBreaks[indexBreak]));
                            writer.writeAttributeString("max", indexBreak == 0 ? "16383" : "8");
                            writer.writeAttributeString("man", "1");
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                    }
                    // *#if Demo
                    if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        writer.writeStartElement("headerFooter");
                        writer.writeStartElement("oddHeader");
                        writer.writeRaw("&amp;C\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n&amp;G");
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    // #endif Demo*/
                    /*#if SERVER
                        if (StiVersionX.IsSvr) {
                            writer.writeStartElement("headerFooter");
                            writer.writeStartElement("oddHeader");
                            writer.writeRaw("&amp;C\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n\r\n&amp;G");
                            writer.writeEndElement();
                            writer.writeEndElement();
                        }
                    #endif*/
                    if (this.imageList.length > this.imageListOffset) {
                        writer.writeStartElement("drawing");
                        writer.writeAttributeString("r:id", StiString.format("rId{0}", 1));
                        writer.writeEndElement();
                    }
                    // *#if Demo
                    if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        writer.writeStartElement("legacyDrawingHF");
                        writer.writeAttributeString("r:id", "dId1");
                        writer.writeEndElement();
                    }
                    // #endif Demo*/
                    /*#if SERVER
                        if (StiVersionX.IsSvr) {
                            writer.writeStartElement("legacyDrawingHF");
                            writer.writeAttributeString("r:id", "dId1");
                            writer.writeEndElement();
                        }
                    #endif*/ // TODO!!!!!!!!!!
                    if (numberStoredAsText.length > 0) {
                        writer.writeStartElement("ignoredErrors");
                        // tslint:disable-next-line: forin
                        for (var sqref in numberStoredAsText) {
                            writer.writeStartElement("ignoredError");
                            writer.writeAttributeString("sqref", numberStoredAsText[sqref]);
                            writer.writeAttributeString("numberStoredAsText", "1");
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiExcel2007ExportService.prototype.prepareMatrix = function (pages) {
                    var dataMode = Export.StiDataExportMode.AllBands;
                    if (this.exportDataOnly) {
                        dataMode = Export.StiDataExportMode.Data | Export.StiDataExportMode.Headers;
                        if (StiOptions.Export.Excel.AllowExportFootersInDataOnlyMode)
                            dataMode |= Export.StiDataExportMode.Footers;
                    }
                    this.matrix = new Export.StiMatrix(pages, StiOptions.Export.Excel.DivideBigCells, this, null, dataMode);
                    // if (IsStoped) return;
                    if (this.useOnePageHeaderAndFooter) {
                        this.matrix.scanComponentsPlacement(true, this.exportObjectFormatting);
                        // prepare line info
                        // array must hold only first page header
                        var tempOffset = 0;
                        // find first header
                        while ((this.matrix.linePlacement[tempOffset] != Export.StiTableLineInfo.PageHeader) &&
                            (tempOffset < this.matrix.coordY.countItems - 1))
                            tempOffset++;
                        // header exist
                        if (this.matrix.linePlacement[tempOffset] == Export.StiTableLineInfo.PageHeader) {
                            // find first line after header
                            while ((this.matrix.linePlacement[tempOffset] == Export.StiTableLineInfo.PageHeader) &&
                                (tempOffset < this.matrix.coordY.countItems - 1))
                                tempOffset++;
                            // scan remains lines
                            while (tempOffset < this.matrix.coordY.countItems - 1) {
                                // it's header
                                if (this.matrix.linePlacement[tempOffset] == Export.StiTableLineInfo.PageHeader) {
                                    // cut this line
                                    this.matrix.linePlacement[tempOffset] = Export.StiTableLineInfo.Trash; // for cut
                                }
                                tempOffset++;
                            }
                        }
                        // array must hold only last page footer
                        tempOffset = this.matrix.coordY.countItems - 1;
                        // find last footer
                        while ((this.matrix.linePlacement[tempOffset] != Export.StiTableLineInfo.PageFooter) &&
                            (tempOffset > 0))
                            tempOffset--;
                        // header exist
                        if (this.matrix.linePlacement[tempOffset] == Export.StiTableLineInfo.PageFooter) {
                            // find first line before header
                            while ((this.matrix.linePlacement[tempOffset] == Export.StiTableLineInfo.PageFooter) &&
                                (tempOffset > 0))
                                tempOffset--;
                            // scan remains lines
                            while (tempOffset > 0) {
                                // it's header
                                if (this.matrix.linePlacement[tempOffset] == Export.StiTableLineInfo.PageFooter) {
                                    // cut this line
                                    this.matrix.linePlacement[tempOffset] = Export.StiTableLineInfo.Trash; // for cut
                                }
                                tempOffset--;
                            }
                        }
                        // this.matrix.AllowModification(true);TODO?
                        // remake this.matrix
                        var linesCount = 0;
                        for (var rowIndex = 0; rowIndex < this.matrix.coordY.countItems - 1; rowIndex++) {
                            if (this.matrix.linePlacement[rowIndex] != Export.StiTableLineInfo.Trash) {
                                // move line
                                for (var columnIndex = 0; columnIndex < this.matrix.coordX.countItems - 1; columnIndex++) {
                                    // move cell
                                    this.matrix.cells[linesCount][columnIndex] = this.matrix.cells[rowIndex][columnIndex];
                                    var cell = this.matrix.cells[linesCount][columnIndex];
                                    if (cell != null) {
                                        // correct coordinate
                                        cell.top = linesCount;
                                        if (cell.exportImage != null) {
                                            var component = cell.component;
                                            /*let objRect: any = this.matrix.imagesBaseRect[component];
                                            if (objRect != null) {
                                                let rect: RectangleD = objRect;
                                                let offset: number = this.matrix.coordY.getByIndex(rowIndex) - this.matrix.coordY.getByIndex(linesCount);
                                                rect.y -= offset;
                                                this.matrix.imagesBaseRect[component] = rect;
                                            }*/ // TODO!!!!
                                        }
                                    }
                                    // move border
                                    this.matrix.bordersX[linesCount][columnIndex] = this.matrix.bordersX[rowIndex][columnIndex];
                                    this.matrix.bordersY[linesCount][columnIndex] = this.matrix.bordersY[rowIndex][columnIndex];
                                    // move bookmarks
                                    this.matrix.bookmarks[linesCount][columnIndex] = this.matrix.bookmarks[rowIndex][columnIndex];
                                }
                                // move border - right line
                                this.matrix.bordersY[linesCount][this.matrix.coordX.countItems - 1] = this.matrix.bordersY[rowIndex][this.matrix.coordX.countItems - 1];
                                // count line height
                                var coordYKey = this.matrix.coordY.getKeys();
                                var lineHeight = this.matrix.coordY.getByIndex(rowIndex + 1, coordYKey) - this.matrix.coordY.getByIndex(rowIndex, coordYKey);
                                this.matrix.coordY.setByIndex(linesCount + 1, this.matrix.coordY.getByIndex(linesCount, coordYKey) + lineHeight);
                                linesCount++;
                            }
                        }
                        for (var columnIndex = 0; columnIndex < this.matrix.coordX.countItems - 1; columnIndex++) {
                            // move border - bottom line
                            this.matrix.bordersX[linesCount][columnIndex] = this.matrix.bordersX[this.matrix.coordY.countItems - 1][columnIndex];
                        }
                        var numAbove = this.matrix.coordY.countItems - 1 - linesCount;
                        if (numAbove > 0) {
                            // remove lines at end of array
                            for (var tempIndex = 0; tempIndex < numAbove; tempIndex++) {
                                this.matrix.coordY.removeByIndex(linesCount + 1);
                            }
                        }
                        // this.matrix.AllowModification(false);
                    }
                    if (this.exportDataOnly) {
                        this.matrix.scanComponentsPlacement(true, this.exportObjectFormatting);
                        // this.matrix.AllowModification(true);
                        // remake this.matrix
                        var linesCount = 0;
                        var headerNames = new Hashtable();
                        var lastParentBandName = null;
                        var allowExportFooters = StiOptions.Export.Excel.AllowExportFootersInDataOnlyMode;
                        for (var rowIndex = 0; rowIndex < this.matrix.coordY.countItems - 1; rowIndex++) {
                            var isHeader = false;
                            if ((this.matrix.linePlacement[rowIndex] == Export.StiTableLineInfo.HeaderD) || (this.matrix.linePlacement[rowIndex] == Export.StiTableLineInfo.HeaderAP)) {
                                var tempSt = this.matrix.parentBandName[rowIndex];
                                // check for new header component
                                var symPos = tempSt.indexOf("\x1f");
                                if (symPos != -1) {
                                    var parentBandName = tempSt.substring(0, symPos);
                                    if (parentBandName != lastParentBandName) {
                                        lastParentBandName = parentBandName;
                                        headerNames.clear();
                                    }
                                }
                                // check for repeated lines
                                if (!headerNames.containsKey(tempSt)) {
                                    isHeader = true;
                                    headerNames.add(tempSt, tempSt);
                                }
                            }
                            if ((this.matrix.linePlacement[rowIndex] == Export.StiTableLineInfo.Data) ||
                                (allowExportFooters && (this.matrix.linePlacement[rowIndex] == Export.StiTableLineInfo.FooterD)) ||
                                // 	(this.matrix.linePlacement[rowIndex] == StiTableLineInfo.FooterAP) ||
                                isHeader) {
                                // move line
                                for (var columnIndex = 0; columnIndex < this.matrix.coordX.countItems - 1; columnIndex++) {
                                    // move cell
                                    this.matrix.cells[linesCount][columnIndex] = this.matrix.cells[rowIndex][columnIndex];
                                    var cell = this.matrix.cells[linesCount][columnIndex];
                                    if (cell != null) {
                                        // correct coordinate
                                        cell.top = linesCount;
                                        if (cell.exportImage != null) {
                                            var component = cell.component;
                                            /*let objRect: object = this.matrix.imagesBaseRect[component];
                                            if (objRect != null) {
                                                let rect: RectangleD = objRect;
                                                let offset: number = this.matrix.coordY.getByIndex(rowIndex) - this.matrix.coordY.getByIndex(linesCount);
                                                rect.y -= offset;
                                                this.matrix.imagesBaseRect[component] = rect;
                                            }*/ // TODO!!!!
                                        }
                                    }
                                    // move border
                                    if ((linesCount == 0) || (this.matrix.bordersX[rowIndex][columnIndex] != null)) {
                                        this.matrix.bordersX[linesCount][columnIndex] = this.matrix.bordersX[rowIndex][columnIndex];
                                    }
                                    this.matrix.bordersX[linesCount + 1][columnIndex] = this.matrix.bordersX[rowIndex + 1][columnIndex];
                                    this.matrix.bordersY[linesCount][columnIndex] = this.matrix.bordersY[rowIndex][columnIndex];
                                    // move bookmarks
                                    this.matrix.bookmarks[linesCount][columnIndex] = this.matrix.bookmarks[rowIndex][columnIndex];
                                }
                                // move border - right line
                                this.matrix.bordersY[linesCount][this.matrix.coordX.countItems - 1] = this.matrix.bordersY[rowIndex][this.matrix.coordX.countItems - 1];
                                var coordYKey = this.matrix.coordY.getKeys();
                                // count line height
                                var lineHeight = this.matrix.coordY.getByIndex(rowIndex + 1, coordYKey) - this.matrix.coordY.getByIndex(rowIndex, coordYKey);
                                this.matrix.coordY.setByIndex(linesCount + 1, this.matrix.coordY.getByIndex(linesCount, coordYKey) + lineHeight);
                                linesCount++;
                            }
                        }
                        var numAbove = this.matrix.coordY.countItems - 1 - linesCount;
                        if (numAbove > 0) {
                            // remove lines at end of array
                            for (var tempIndex = 0; tempIndex < numAbove; tempIndex++) {
                                this.matrix.coordY.removeByIndex(linesCount + 1);
                            }
                        }
                        // this.matrix.allowModification(false);
                    }
                };
                StiExcel2007ExportService.prototype.convertAllowHtmlTagsToExcelString = function (textBox, input) {
                    // let output = new StringBuilder(input.length * 2);
                    // let sw = new StringWriter(output);
                    var writer = new XmlTextWriter(Encoding.UTF8);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    var baseTagsState = new StiHtmlTagsState(textBox.font.bold, textBox.font.italic, textBox.font.underline, textBox.font.strikeout, textBox.font.sizeInPoints, textBox.font.name, StiBrush.toColor(textBox.textBrush), StiBrush.toColor(textBox.brush), false, false, 0, 0, 1, textBox.horAlignment);
                    var baseState = new StiHtmlState(baseTagsState, 0);
                    var states = StiTextRenderer.parseHtmlToStates(textBox.text, baseState);
                    for (var index = 0; index < states.length; index++) {
                        var state = states[index];
                        writer.writeStartElement("r");
                        writer.writeStartElement("rPr");
                        if (state.ts.bold) {
                            writer.writeElementString("b", null);
                        }
                        if (state.ts.italic) {
                            writer.writeElementString("i", null);
                        }
                        if (state.ts.underline) {
                            writer.writeElementString("u", null);
                        }
                        if (state.ts.strikeout) {
                            writer.writeElementString("strike", null);
                        }
                        if (state.ts.superscript) {
                            writer.writeStartElement("vertAlign");
                            writer.writeAttributeString("val", "superscript");
                            writer.writeEndElement();
                        }
                        if (state.ts.subsript) {
                            writer.writeStartElement("vertAlign");
                            writer.writeAttributeString("val", "subscript");
                            writer.writeEndElement();
                        }
                        writer.writeStartElement("sz");
                        writer.writeAttributeString("val", state.ts.fontSize.toString());
                        writer.writeEndElement();
                        writer.writeStartElement("color");
                        writer.writeAttributeString("rgb", StiString.format("{0:X8}", state.ts.fontColor.toArgb()));
                        writer.writeEndElement();
                        writer.writeStartElement("rFont");
                        writer.writeAttributeString("val", state.ts.fontName);
                        writer.writeEndElement();
                        // writer.writeStartElement("charset");
                        // writer.writeAttributeString("val", StiString.format("{0}", state.ts.FontCharset));
                        // writer.writeEndElement();
                        writer.writeEndElement(); // rPr
                        this.convertTextToExcelString(writer, StiTextRenderer.prepareStateText(state.text).toString());
                        writer.writeEndElement(); // r
                    }
                    writer.flush();
                    writer.close();
                    return writer.textWriter.getStringBuilder().toString();
                };
                StiExcel2007ExportService.prototype.convertTextToExcelString = function (writer, input) {
                    writer.writeStartElement("t");
                    if ((input.length > 0) && (Char.isWhitespace(input, input.length - 1) || (input.indexOf("\n") != -1))) {
                        writer.writeAttributeString("xml:space", "preserve");
                    }
                    writer.writeString(input);
                    writer.writeFullEndElement();
                };
                // WriteDrawingRels
                StiExcel2007ExportService.prototype.writeDrawingRels = function (indexSheet) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    for (var index = this.imageListOffset; index < this.imageList.length; index++) {
                        var image = this.imageList[index];
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", index - this.imageListOffset + 1));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image");
                        writer.writeAttributeString("Target", StiString.format("../media/image{0:D5}.jpeg", image.ImageIndex + 1));
                        writer.writeEndElement();
                        if (!StiString.isNullOrWhiteSpace(image.Hyperlink)) {
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", StiString.format("hId{0}", index - this.imageListOffset + 1));
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink");
                            writer.writeAttributeString("Target", image.Hyperlink);
                            writer.writeAttributeString("TargetMode", "External");
                            writer.writeEndElement();
                        }
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteDrawing
                StiExcel2007ExportService.prototype.writeDrawing = function (indexSheet) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("xdr:wsDr");
                    writer.writeAttributeString("xmlns:xdr", "http://schemas.openxmlformats.org/drawingml/2006/spreadsheetDrawing");
                    writer.writeAttributeString("xmlns:a", "http://schemas.openxmlformats.org/drawingml/2006/main");
                    for (var index = this.imageListOffset; index < this.imageList.length; index++) {
                        var image = this.imageList[index];
                        writer.writeStartElement("xdr:twoCellAnchor");
                        writer.writeAttributeString("editAs", "oneCell");
                        writer.writeStartElement("xdr:from");
                        writer.writeElementString("xdr:col", StiString.format("{0}", image.FirstColumnIndex));
                        writer.writeElementString("xdr:colOff", StiString.format("{0}", image.FirstColumnOffset));
                        writer.writeElementString("xdr:row", StiString.format("{0}", image.FirstRowIndex));
                        writer.writeElementString("xdr:rowOff", StiString.format("{0}", image.FirstRowOffset));
                        writer.writeEndElement();
                        writer.writeStartElement("xdr:to");
                        writer.writeElementString("xdr:col", StiString.format("{0}", image.LastColumnIndex));
                        writer.writeElementString("xdr:colOff", StiString.format("{0}", image.LastColumnOffset));
                        writer.writeElementString("xdr:row", StiString.format("{0}", image.LastRowIndex));
                        writer.writeElementString("xdr:rowOff", StiString.format("{0}", image.LastRowOffset));
                        writer.writeEndElement();
                        writer.writeStartElement("xdr:pic");
                        writer.writeStartElement("xdr:nvPicPr");
                        writer.writeStartElement("xdr:cNvPr");
                        writer.writeAttributeString("id", StiString.format("{0}", index - this.imageListOffset + 2));
                        writer.writeAttributeString("name", StiString.format("Picture {0}", index - this.imageListOffset + 1));
                        writer.writeAttributeString("descr", StiString.format("image{0:D5}", index + 1));
                        if (!StiString.isNullOrWhiteSpace(image.Hyperlink)) {
                            writer.writeStartElement("a:hlinkClick");
                            writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                            writer.writeAttributeString("r:id", StiString.format("hId{0}", index - this.imageListOffset + 1));
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                        writer.writeStartElement("xdr:cNvPicPr");
                        writer.writeStartElement("a:picLocks");
                        writer.writeAttributeString("noChangeAspect", "1");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeStartElement("xdr:blipFill");
                        writer.writeStartElement("a:blip");
                        writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                        writer.writeAttributeString("r:embed", StiString.format("rId{0}", index - this.imageListOffset + 1));
                        writer.writeEndElement();
                        writer.writeStartElement("a:stretch");
                        writer.writeStartElement("a:fillRect");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeStartElement("xdr:spPr");
                        writer.writeStartElement("a:xfrm");
                        writer.writeStartElement("a:off");
                        writer.writeAttributeString("x", "1");
                        writer.writeAttributeString("y", "1");
                        writer.writeEndElement();
                        writer.writeStartElement("a:ext");
                        writer.writeAttributeString("cx", "2");
                        writer.writeAttributeString("cy", "2");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeStartElement("a:prstGeom");
                        writer.writeAttributeString("prst", "rect");
                        writer.writeStartElement("a:avLst");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeStartElement("xdr:clientData");
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteStyles
                StiExcel2007ExportService.prototype.writeStyles = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    // writer.Indentation = (xmlIndentation < 0 ? 0 : xmlIndentation);
                    // writer.Formatting = (xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("styleSheet");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");
                    // NumFmts
                    if (this.formatList.length > 0) {
                        writer.writeStartElement("numFmts");
                        writer.writeAttributeString("count", StiString.format("{0}", this.formatList.length));
                        for (var index = 0; index < this.formatList.length; index++) {
                            writer.writeStartElement("numFmt");
                            writer.writeAttributeString("numFmtId", StiString.format("{0}", 164 + index));
                            writer.writeAttributeString("formatCode", this.formatList[index]);
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                    }
                    // Fonts
                    writer.writeStartElement("fonts");
                    writer.writeAttributeString("count", StiString.format("{0}", this.fontList.length));
                    for (var index = 0; index < this.fontList.length; index++) {
                        var tempFont = this.fontList[index];
                        writer.writeStartElement("font");
                        if (tempFont.Bold) {
                            writer.writeElementString("b", "");
                        }
                        if (tempFont.Italic) {
                            writer.writeElementString("i", "");
                        }
                        if (tempFont.Underlined) {
                            writer.writeElementString("u", "");
                        }
                        if (tempFont.Strikeout) {
                            writer.writeElementString("strike", "");
                        }
                        writer.writeStartElement("sz");
                        writer.writeAttributeString("val", StiString.format("{0}", tempFont.Height));
                        writer.writeEndElement();
                        writer.writeStartElement("color");
                        writer.writeAttributeString("rgb", StiString.format("{0:X8}", tempFont.Color.toArgb()));
                        writer.writeEndElement();
                        writer.writeStartElement("name");
                        writer.writeAttributeString("val", tempFont.Name);
                        writer.writeEndElement();
                        // 				writer.writeStartElement("family");
                        // 				writer.writeAttributeString("val", StiString.format("{0}", 0));
                        // 				writer.writeEndElement();
                        writer.writeStartElement("charset");
                        writer.writeAttributeString("val", StiString.format("{0}", tempFont.Charset));
                        writer.writeEndElement();
                        writer.writeEndElement(); // font
                    }
                    writer.writeEndElement();
                    // Fills
                    writer.writeStartElement("fills");
                    writer.writeAttributeString("count", StiString.format("{0}", this.fillList.length));
                    for (var index = 0; index < this.fillList.length; index++) {
                        var tempFill = this.fillList[index];
                        writer.writeStartElement("fill");
                        writer.writeStartElement("patternFill");
                        writer.writeAttributeString("patternType", tempFill.Type);
                        if (tempFill.Type == "solid") {
                            writer.writeStartElement("fgColor");
                            writer.writeAttributeString("rgb", StiString.format("{0:X8}", tempFill.FgColor.toArgb())); // .toString("X8"));
                            writer.writeEndElement();
                            writer.writeStartElement("bgColor");
                            writer.writeAttributeString("indexed", StiString.format("{0}", 64));
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                    // Borders
                    writer.writeStartElement("borders");
                    writer.writeAttributeString("count", StiString.format("{0}", this.borderList.length));
                    for (var index = 0; index < this.borderList.length; index++) {
                        var tempBorder = this.borderList[index];
                        writer.writeStartElement("border");
                        this.writeBorderData(writer, "left", tempBorder.BorderLeft);
                        this.writeBorderData(writer, "right", tempBorder.BorderRight);
                        this.writeBorderData(writer, "top", tempBorder.BorderTop);
                        this.writeBorderData(writer, "bottom", tempBorder.BorderBottom);
                        this.writeBorderData(writer, "diagonal", null);
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                    // CellStyleXfs
                    writer.writeStartElement("cellStyleXfs");
                    writer.writeAttributeString("count", StiString.format("{0}", 1));
                    writer.writeStartElement("xf");
                    writer.writeAttributeString("numFmtId", StiString.format("{0}", 0));
                    writer.writeAttributeString("fontId", StiString.format("{0}", 0));
                    writer.writeAttributeString("fillId", StiString.format("{0}", 0));
                    writer.writeAttributeString("borderId", StiString.format("{0}", 0));
                    writer.writeEndElement();
                    writer.writeEndElement();
                    // CellXfs
                    writer.writeStartElement("cellXfs");
                    writer.writeAttributeString("count", StiString.format("{0}", this.xfList.length));
                    for (var index = 0; index < this.xfList.length; index++) {
                        var tempXF = this.xfList[index];
                        var tempFill = this.fillList[tempXF.FillIndex];
                        var fillIndex = tempXF.FillIndex;
                        if (tempFill.FgColor.a == 0)
                            fillIndex = 0;
                        writer.writeStartElement("xf");
                        writer.writeAttributeString("numFmtId", StiString.format("{0}", tempXF.FormatIndex));
                        writer.writeAttributeString("fontId", StiString.format("{0}", tempXF.FontIndex));
                        writer.writeAttributeString("fillId", StiString.format("{0}", fillIndex));
                        writer.writeAttributeString("borderId", StiString.format("{0}", tempXF.BorderIndex));
                        writer.writeAttributeString("xfId", StiString.format("{0}", tempXF.XFId));
                        if (tempXF.FormatIndex != 0) {
                            writer.writeAttributeString("applyNumberFormat", "1");
                        }
                        if (tempXF.FontIndex != 0) {
                            writer.writeAttributeString("applyFont", "1");
                        }
                        if (tempXF.FillIndex != 0) {
                            writer.writeAttributeString("applyFill", "1");
                        }
                        if (tempXF.BorderIndex != 0) {
                            writer.writeAttributeString("applyBorder", "1");
                        }
                        writer.writeAttributeString("applyAlignment", "1");
                        if (tempXF.Editable) {
                            writer.writeAttributeString("applyProtection", "1");
                        }
                        // alignment
                        writer.writeStartElement("alignment");
                        var horAlign = "left";
                        switch (tempXF.HorAlign) {
                            case StiTextHorAlignment.Right:
                                horAlign = "right";
                                break;
                            case StiTextHorAlignment.Center:
                                horAlign = "center";
                                break;
                            case StiTextHorAlignment.Width:
                                horAlign = "justify";
                                break;
                        }
                        writer.writeAttributeString("horizontal", horAlign);
                        if (tempXF.VertAlign != StiVertAlignment.Bottom) {
                            var vertAlign = "";
                            switch (tempXF.VertAlign) {
                                case StiVertAlignment.Top:
                                    vertAlign = "top";
                                    break;
                                case StiVertAlignment.Center:
                                    vertAlign = "center";
                                    break;
                            }
                            writer.writeAttributeString("vertical", vertAlign);
                        }
                        if (tempXF.TextRotationAngle != 0) {
                            writer.writeAttributeString("textRotation", tempXF.TextRotationAngle.toString());
                        }
                        if (tempXF.TextWrapped) {
                            writer.writeAttributeString("wrapText", "1");
                        }
                        if (tempXF.RightToLeft) {
                            writer.writeAttributeString("readingOrder", "2");
                        }
                        writer.writeEndElement();
                        //
                        if (tempXF.Editable) {
                            writer.writeStartElement("protection");
                            writer.writeAttributeString("locked", "0");
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                    // CellStyles
                    writer.writeStartElement("cellStyles");
                    writer.writeAttributeString("count", StiString.format("{0}", 1));
                    writer.writeStartElement("cellStyle");
                    writer.writeAttributeString("name", "Normal");
                    writer.writeAttributeString("xfId", StiString.format("{0}", 0));
                    writer.writeAttributeString("builtinId", StiString.format("{0}", 0));
                    writer.writeEndElement();
                    // 			writer.writeStartElement("cellStyle");
                    // 			writer.writeAttributeString("name", "Hyperlink");
                    // 			writer.writeAttributeString("xfId", StiString.format("{0}", 1));
                    // 			writer.writeAttributeString("builtinId", StiString.format("{0}", 8));
                    // 			writer.writeEndElement();
                    writer.writeEndElement();
                    // Dxfs
                    writer.writeStartElement("dxfs");
                    writer.writeAttributeString("count", StiString.format("{0}", 0));
                    writer.writeEndElement();
                    // TableStyles
                    writer.writeStartElement("tableStyles");
                    writer.writeAttributeString("count", StiString.format("{0}", 0));
                    writer.writeAttributeString("defaultTableStyle", "TableStyleMedium9");
                    writer.writeAttributeString("defaultPivotStyle", "PivotStyleLight16");
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiExcel2007ExportService.prototype.writeBorderData = function (writer, side, border) {
                    writer.writeStartElement(side);
                    if (border != null) {
                        var style = this.getLineStyle(border);
                        var color = border.color;
                        if (style != "") {
                            writer.writeAttributeString("style", style);
                            writer.writeStartElement("color");
                            writer.writeAttributeString("rgb", StiString.format("{0:X8}", color.toArgb())); // .toString("X8"));
                            writer.writeEndElement();
                        }
                    }
                    writer.writeEndElement();
                };
                // WriteSST
                StiExcel2007ExportService.prototype.writeSST = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.writeStartDocument();
                    writer.writeStartElement("sst");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/spreadsheetml/2006/main");
                    writer.writeAttributeString("count", StiString.format("{0}", this.sstCount));
                    writer.writeAttributeString("uniqueCount", StiString.format("{0}", this.sstList.length));
                    for (var index = 0; index < this.sstList.length; index++) {
                        writer.writeStartElement("si");
                        var st = this.sstList[index];
                        // remove codes 0x00-0x1f
                        var sb = new StringBuilder();
                        for (var i = 0; i < st.length; i++) {
                            if ((st.charCodeAt(i) >= 32) || (st.charAt(i) == "\n"))
                                sb.append(st.charAt(i));
                        }
                        st = sb.toString();
                        if (this.sstHashIsTags.containsKey(index)) {
                            writer.writeRaw(st);
                        }
                        else {
                            this.convertTextToExcelString(writer, st);
                        }
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                // WriteAdditionalData
                StiExcel2007ExportService.prototype.writeAdditionalData = function (st, base64) {
                    var ms = new MemoryStream();
                    var bytes = null;
                    if (base64) {
                        bytes = Stimulsoft.System.Convert.fromBase64String(st);
                    }
                    else {
                        bytes = Encoding.ASCII.getBytes(st);
                    }
                    ms.write(bytes, 0, bytes.length);
                    return ms;
                };
                // WriteImage
                StiExcel2007ExportService.prototype.writeImage = function (_number) {
                    var ms = new MemoryStream();
                    var image = this.imageList[_number];
                    var bytes = this.imageCache.imagePackedStore[_number];
                    if (bytes != null) {
                        ms.write(bytes, 0, bytes.length);
                    }
                    return ms;
                };
                /*
                /// <summary>
                /// Exports rendered report to an Excel file.
                /// </summary>
                /// <param name="report">A report which is to be exported.</param>
                /// <param name="stream">A stream for export of a document.</param>
                void ExportExcel(StiReport report, Stream stream)
            {
                StiExcelExportSettings settings = new StiExcelExportSettings();
        
                ExportExcel(report, stream, settings);
            }
        
                /// <summary>
                /// Exports rendered report to an Excel file.
                /// </summary>
                /// <param name="report">A report which is to be exported.</param>
                /// <param name="stream">A stream for export of a document.</param>
                /// <param name="pageRange">Describes range of pages of the document for the export.</param>
                void ExportExcel(StiReport report, Stream stream, StiPagesRange pageRange)
            {
                StiExcelExportSettings settings = new StiExcelExportSettings();
        
                settings.PageRange = pageRange;
        
                ExportExcel(report, stream, settings);
            }*/
                StiExcel2007ExportService.prototype.exportExcel = function (report, stream, settings) {
                    // StiLogService.Write(this.GetType(), "Export report to Excel 2007 format");
                    // Read settings
                    /*if (settings == null)
                        throw new ArgumentNullException("The 'settings' argument cannot be equal in null.");*/ // ?
                    var pageRange = settings.pageRange;
                    this.useOnePageHeaderAndFooter = settings.useOnePageHeaderAndFooter;
                    this.exportDataOnly = settings.exportDataOnly;
                    this.exportObjectFormatting = settings.exportObjectFormatting;
                    this.exportEachPageToSheet = settings.exportEachPageToSheet;
                    this.exportHorizontalPageBreaks = settings.exportPageBreaks;
                    this.imageResolution = settings.imageResolution;
                    this.imageQuality = settings.imageQuality;
                    this.docCompanyString = settings.companyString;
                    this.docLastModifiedString = settings.lastModifiedString;
                    this.restrictEditing = settings.restrictEditing;
                    this.xmlIndentation = -1;
                    if (this.imageResolution < 10)
                        this.imageResolution = 10;
                    this.imageResolution = this.imageResolution / 100;
                    if (this.exportDataOnly) {
                        this.useOnePageHeaderAndFooter = false;
                    }
                    else {
                        this.exportObjectFormatting = true;
                    }
                    if (StiOptions.Export.Excel.RestrictEditing > this.restrictEditing) {
                        this.restrictEditing = StiOptions.Export.Excel.RestrictEditing;
                    }
                    this.report = report;
                    // CultureInfo currentCulture = Stimulsoft.System.Threading.Thread.CurrentThread.CurrentCulture;
                    try {
                        /*Stimulsoft.System.Threading.Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US", false);
        
                        reportCulture = currentCulture;
                        if (!string.IsNullOrEmpty(report.Culture)) {
                            try {
                                reportCulture = new CultureInfo(report.Culture);
                            }
                            catch
                                {
                            }
                        }*/ // ?
                        this.reportCulture = CultureInfo.currentCulture;
                        var allPages = pageRange.getSelectedPages(report.renderedPages);
                        // if (IsStoped) return;
                        this.currentPassNumber = 0;
                        this.maximumPassNumber = 3;
                        // StatusString = StiLocalization.Get("Export", "ExportingCreatingDocument");
                        this.prepareData();
                        // prepare this.matrixList
                        var indexPage = 0;
                        while (indexPage < allPages.length) {
                            var pages = new StiPagesCollection(report, report.renderedPages);
                            pages.cacheMode = report.renderedPages.cacheMode;
                            pages.addV2Internal(allPages.getPageWithoutCache(indexPage));
                            var firstPageIndex = indexPage;
                            if (!this.exportEachPageToSheet) {
                                var pageName = allPages.getPageWithoutCache(indexPage).excelSheetValue;
                                while ((indexPage < allPages.length - 1) && this.compareExcellSheetNames(allPages.getPageWithoutCache(indexPage + 1).excelSheetValue, pageName)) {
                                    indexPage++;
                                    pages.addV2Internal(allPages.getPageWithoutCache(indexPage));
                                }
                            }
                            var sheetName = pages.getByIndex(0).excelSheetValue;
                            if ((sheetName == null) || (sheetName == "")) {
                                sheetName = StiString.format("Page {0}", this.sheetNameList.length + 1);
                            }
                            var sheetSuffix = "";
                            var sheetIndex = 1;
                            this.prepareMatrix(pages);
                            var minRowIndex = 0;
                            do {
                                this.firstPageIndexList.add(firstPageIndex);
                                this.matrixList.add(this.matrix);
                                var maxRowIndex = this.matrix.coordY.countItems - 1;
                                if (maxRowIndex - minRowIndex > StiOptions.Export.Excel.MaximumSheetHeight) {
                                    maxRowIndex = minRowIndex + StiOptions.Export.Excel.MaximumSheetHeight;
                                }
                                else {
                                    this.matrix = null;
                                }
                                this.minRowList.add(minRowIndex);
                                this.maxRowList.add(maxRowIndex);
                                minRowIndex = maxRowIndex;
                                if ((this.matrix != null) || (sheetSuffix.length > 0)) {
                                    sheetSuffix = StiString.format(" part{0}", sheetIndex++);
                                    if (sheetName.length > 24)
                                        sheetName = sheetName.substr(0, 24);
                                }
                                else {
                                    if (sheetName.length > 30)
                                        sheetName = sheetName.substr(0, 30);
                                }
                                this.sheetNameList.add(sheetName + sheetSuffix);
                                // if (IsStoped) return;
                            } while (this.matrix != null);
                            indexPage++;
                        }
                        // check sheet names
                        var ht = new Hashtable();
                        for (var index = 0; index < this.sheetNameList.length; index++) {
                            var titleString = this.sheetNameList[index];
                            titleString = titleString.sti.replaceAll("*", "_").sti.replaceAll("\\", "_").sti.replaceAll("/", "_").sti.replaceAll("[", "_").sti.replaceAll("]", "_").sti.replaceAll(":", "_").sti.replaceAll("?", "_");
                            if (ht.contains(titleString)) {
                                var numVariant = 1;
                                while (ht.contains(titleString + "-" + numVariant.toString())) {
                                    numVariant++;
                                }
                                titleString = titleString + "-" + numVariant.toString();
                            }
                            ht.add(titleString, titleString);
                            this.sheetNameList[index] = titleString;
                        }
                        var zip = new StiZipWriter20();
                        zip.begin(stream, true);
                        this.currentPassNumber = 2;
                        this.imageListOffset = 0;
                        for (var indexSheet = 0; indexSheet < this.matrixList.length; indexSheet++) {
                            this.hyperlinkList = new Array();
                            zip.addFile(StiString.format("xl/worksheets/sheet{0}.xml", indexSheet + 1), this.writeSheet(indexSheet, allPages.getByIndex(this.firstPageIndexList[indexSheet])));
                            /*#if !Demo
                                if ((hyperlinkList.length > 0) || (this.imageList.length - imageListOffset > 0))
                            #endif*/ // TODO!!!!
                            {
                                zip.addFile(StiString.format("xl/worksheets/_rels/sheet{0}.xml.rels", indexSheet + 1), this.writeSheetRels(indexSheet));
                            }
                            if (this.imageList.length - this.imageListOffset > 0) {
                                zip.addFile(StiString.format("xl/drawings/_rels/drawing{0}.xml.rels", indexSheet + 1), this.writeDrawingRels(indexSheet));
                                zip.addFile(StiString.format("xl/drawings/drawing{0}.xml", indexSheet + 1), this.writeDrawing(indexSheet));
                            }
                            this.imageListOffset = this.imageList.length;
                            // if (IsStoped) return;
                        }
                        zip.addFile("[Content_Types].xml", this.writeContentTypes());
                        zip.addFile("_rels/.rels", this.writeMainRels());
                        zip.addFile("docProps/app.xml", this.writeDocPropsApp());
                        zip.addFile("docProps/core.xml", this.writeDocPropsCore());
                        zip.addFile("xl/_rels/workbook.xml.rels", this.writeWorkbookRels());
                        zip.addFile("xl/workbook.xml", this.writeWorkbook());
                        zip.addFile("xl/styles.xml", this.writeStyles());
                        if (this.sstList.length > 0) {
                            zip.addFile("xl/sharedStrings.xml", this.writeSST());
                        }
                        if (this.imageCache.imagePackedStore.length > 0) {
                            for (var index = 0; index < this.imageCache.imagePackedStore.length; index++) {
                                zip.addFile(StiString.format("xl/media/image{0:D5}.jpeg", index + 1), this.writeImage(index));
                            }
                        }
                        // *#if Demo
                        if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                            !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                            zip.addFile("xl/media/imageAdditional.png", this.writeAdditionalData(Export.StiExportUtils.additionalData, true));
                            zip.addFile("xl/drawings/_rels/vmlDrawingAdditional.vml.rels", this.writeAdditionalData("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"dId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"../media/imageAdditional.png\"/></Relationships>", false));
                            zip.addFile("xl/drawings/vmlDrawingAdditional.vml", this.writeAdditionalData("<xml xmlns:v=\"urn:schemas-microsoft-com:vml\"\r\n xmlns:o=\"urn:schemas-microsoft-com:office:office\"\r\n xmlns:x=\"urn:schemas-microsoft-com:office:excel\">\r\n <o:shapelayout v:ext=\"edit\">\r\n  <o:idmap v:ext=\"edit\" data=\"1\"/>\r\n" +
                                " </o:shapelayout><v:shapetype id=\"_x0000_t75\" coordsize=\"21600,21600\" o:spt=\"75\"\r\n  o:preferrelative=\"t\" path=\"m@4@5l@4@11@9@11@9@5xe\" filled=\"f\" stroked=\"f\">\r\n  <v:stroke joinstyle=\"miter\"/>\r\n  <v:formulas>" +
                                "\r\n   <v:f eqn=\"if lineDrawn pixelLineWidth 0\"/>\r\n   <v:f eqn=\"sum @0 1 0\"/>\r\n   <v:f eqn=\"sum 0 0 @1\"/>\r\n   <v:f eqn=\"prod @2 1 2\"/>\r\n   <v:f eqn=\"prod @3 21600 pixelWidth\"/>\r\n   <v:f eqn=\"prod @3 21600 pixelHeight\"/>\r\n   <v:f eqn=\"sum @0 0 1\"/>" +
                                "\r\n   <v:f eqn=\"prod @6 1 2\"/>\r\n   <v:f eqn=\"prod @7 21600 pixelWidth\"/>\r\n   <v:f eqn=\"sum @8 21600 0\"/>\r\n   <v:f eqn=\"prod @7 21600 pixelHeight\"/>\r\n   <v:f eqn=\"sum @10 21600 0\"/>\r\n  </v:formulas>\r\n  <v:path o:extrusionok=\"f\" gradientshapeok=\"t\" o:connecttype=\"rect\"/>" +
                                "\r\n  <o:lock v:ext=\"edit\" aspectratio=\"t\"/>\r\n </v:shapetype><v:shape id=\"CH\" o:spid=\"_x0000_s1027\" type=\"#_x0000_t75\"\r\n  style='position:absolute;margin-left:0;margin-top:0;width:365pt;height:298pt;\r\n  z-index:1'>" +
                                "\r\n  <v:imagedata o:relid=\"dId1\" o:title=\"additional\"/>\r\n  <o:lock v:ext=\"edit\" rotation=\"t\"/>\r\n </v:shape></xml>", false));
                        }
                        // #endif Demo*/
                        /*#if SERVER
                            if (StiVersionX.IsSvr) {
                                zip.AddFile("xl/media/imageAdditional.png", WriteAdditionalData(StiExportUtils.AdditionalData, true));
                                zip.AddFile("xl/drawings/_rels/vmlDrawingAdditional.vml.rels", WriteAdditionalData("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"dId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"../media/imageAdditional.png\"/></Relationships>", false));
                                zip.AddFile("xl/drawings/vmlDrawingAdditional.vml", WriteAdditionalData(
                                    "<xml xmlns:v=\"urn:schemas-microsoft-com:vml\"\r\n xmlns:o=\"urn:schemas-microsoft-com:office:office\"\r\n xmlns:x=\"urn:schemas-microsoft-com:office:excel\">\r\n <o:shapelayout v:ext=\"edit\">\r\n  <o:idmap v:ext=\"edit\" data=\"1\"/>\r\n" +
                                    " </o:shapelayout><v:shapetype id=\"_x0000_t75\" coordsize=\"21600,21600\" o:spt=\"75\"\r\n  o:preferrelative=\"t\" path=\"m@4@5l@4@11@9@11@9@5xe\" filled=\"f\" stroked=\"f\">\r\n  <v:stroke joinstyle=\"miter\"/>\r\n  <v:formulas>" +
                                    "\r\n   <v:f eqn=\"if lineDrawn pixelLineWidth 0\"/>\r\n   <v:f eqn=\"sum @0 1 0\"/>\r\n   <v:f eqn=\"sum 0 0 @1\"/>\r\n   <v:f eqn=\"prod @2 1 2\"/>\r\n   <v:f eqn=\"prod @3 21600 pixelWidth\"/>\r\n   <v:f eqn=\"prod @3 21600 pixelHeight\"/>\r\n   <v:f eqn=\"sum @0 0 1\"/>" +
                                    "\r\n   <v:f eqn=\"prod @6 1 2\"/>\r\n   <v:f eqn=\"prod @7 21600 pixelWidth\"/>\r\n   <v:f eqn=\"sum @8 21600 0\"/>\r\n   <v:f eqn=\"prod @7 21600 pixelHeight\"/>\r\n   <v:f eqn=\"sum @10 21600 0\"/>\r\n  </v:formulas>\r\n  <v:path o:extrusionok=\"f\" gradientshapeok=\"t\" o:connecttype=\"rect\"/>" +
                                    "\r\n  <o:lock v:ext=\"edit\" aspectratio=\"t\"/>\r\n </v:shapetype><v:shape id=\"CH\" o:spid=\"_x0000_s1027\" type=\"#_x0000_t75\"\r\n  style='position:absolute;margin-left:0;margin-top:0;width:365.25pt;height:339pt;\r\n  z-index:1'>" +
                                    "\r\n  <v:imagedata o:relid=\"dId1\" o:title=\"additional\"/>\r\n  <o:lock v:ext=\"edit\" rotation=\"t\"/>\r\n </v:shape></xml>", false));
                            }
                        #endif//TODO!!!!!  */
                        zip.end();
                    }
                    catch (e) {
                        Stimulsoft.System.StiError.showError(e, false);
                    }
                    finally {
                        /*StiExportUtils.EnableFontSmoothing(report);
                        Stimulsoft.System.Threading.Thread.CurrentThread.CurrentCulture = currentCulture;*/
                        if (this.matrix != null) {
                            this.matrix.clear();
                            this.matrix = null;
                        }
                        this.fontList = null;
                        this.fillList = null;
                        this.borderList = null;
                        this.xfList = null;
                        this.sstList = null;
                        // this.sstHash.clear();
                        this.sstHash = null;
                        // this.sstHashIsTags.clear();
                        this.sstHashIsTags = null;
                        this.formatList = null;
                        this.sheetNameList = null;
                        this.imageList.clear();
                        this.imageList = null;
                        this.imageCache.clear();
                        this.printAreasList = null;
                        this.matrixList = null;
                        this.firstPageIndexList = null;
                        this.hyperlinkList = null;
                        this.minRowList = null;
                        this.maxRowList = null;
                        // if (this.report.RenderedPages.CacheMode) StiMatrix.GCCollect();
                    }
                };
                return StiExcel2007ExportService;
            }(Export.StiExportService));
            Export.StiExcel2007ExportService = StiExcel2007ExportService;
            var DataFont = /** @class */ (function () {
                function DataFont(Name, Bold, Italic, Underlined, Strikeout, Height, Color, Charset, Family) {
                    this.Name = Name;
                    this.Bold = Bold;
                    this.Italic = Italic;
                    this.Underlined = Underlined;
                    this.Strikeout = Strikeout;
                    this.Height = Height;
                    this.Color = Color;
                    this.Charset = Charset;
                    this.Family = Family;
                }
                DataFont.prototype.equals = function (obj) {
                    return this.Name == obj.Name && this.Bold == obj.Bold && this.Italic == obj.Italic && this.Underlined == obj.Underlined
                        && this.Strikeout == obj.Strikeout && this.Height == obj.Height && this.Color.sti.equals(obj.Color) && this.Charset == obj.Charset && this.Family == obj.Family;
                };
                return DataFont;
            }());
            Export.DataFont = DataFont;
            // struct DataFill
            var DataFill = /** @class */ (function () {
                function DataFill(Type, FgColor, BgColor) {
                    this.Type = Type;
                    this.FgColor = FgColor;
                    this.BgColor = BgColor;
                }
                DataFill.prototype.equals = function (obj) {
                    return this.Type == obj.Type && this.FgColor.sti.equals(obj.FgColor) && this.BgColor.sti.equals(obj.BgColor);
                };
                return DataFill;
            }());
            Export.DataFill = DataFill;
            // struct DataBorder
            var DataBorder = /** @class */ (function () {
                function DataBorder(BorderLeft, BorderRight, BorderTop, BorderBottom) {
                    this.BorderLeft = BorderLeft;
                    this.BorderRight = BorderRight;
                    this.BorderTop = BorderTop;
                    this.BorderBottom = BorderBottom;
                }
                DataBorder.prototype.equals = function (obj) {
                    return this.eq(this.BorderLeft, obj.BorderLeft) && this.eq(this.BorderRight, obj.BorderRight)
                        && this.eq(this.BorderTop, obj.BorderTop) && this.eq(this.BorderBottom, obj.BorderBottom);
                };
                DataBorder.prototype.eq = function (obj1, obj2) {
                    return (obj1 == null && obj2 == null) || (obj1 != null && obj2 != null && obj1.sti.equals(obj2));
                };
                return DataBorder;
            }());
            Export.DataBorder = DataBorder;
            // struct DataXF
            var DataXF = /** @class */ (function () {
                function DataXF(FormatIndex, FontIndex, FillIndex, BorderIndex, XFId, HorAlign, VertAlign, TextRotationAngle, TextWrapped, RightToLeft, Editable) {
                    this.FormatIndex = FormatIndex;
                    this.FontIndex = FontIndex;
                    this.FillIndex = FillIndex;
                    this.BorderIndex = BorderIndex;
                    this.XFId = XFId;
                    this.HorAlign = HorAlign;
                    this.VertAlign = VertAlign;
                    this.TextRotationAngle = TextRotationAngle;
                    this.TextWrapped = TextWrapped;
                    this.RightToLeft = RightToLeft;
                    this.Editable = Editable;
                }
                DataXF.prototype.equalDataXF = function (xf) {
                    if ((this.FormatIndex != xf.FormatIndex) ||
                        (this.FontIndex != xf.FontIndex) ||
                        (this.FillIndex != xf.FillIndex) ||
                        (this.BorderIndex != xf.BorderIndex) ||
                        (this.XFId != xf.XFId) ||
                        (this.HorAlign != xf.HorAlign) ||
                        (this.VertAlign != xf.VertAlign) ||
                        (this.TextRotationAngle != xf.TextRotationAngle) ||
                        (this.TextWrapped != xf.TextWrapped) ||
                        (this.RightToLeft != xf.RightToLeft) ||
                        (this.Editable != xf.Editable))
                        return false;
                    return true;
                };
                return DataXF;
            }());
            Export.DataXF = DataXF;
            // struct ExcelImageData
            var ExcelImageData = /** @class */ (function () {
                function ExcelImageData(FirstRowIndex, FirstRowOffset, FirstColumnIndex, FirstColumnOffset, LastRowIndex, LastRowOffset, LastColumnIndex, LastColumnOffset, ImageIndex, Hyperlink) {
                    this.FirstRowIndex = FirstRowIndex;
                    this.FirstRowOffset = FirstRowOffset;
                    this.FirstColumnIndex = FirstColumnIndex;
                    this.FirstColumnOffset = FirstColumnOffset;
                    this.LastRowIndex = LastRowIndex;
                    this.LastRowOffset = LastRowOffset;
                    this.LastColumnIndex = LastColumnIndex;
                    this.LastColumnOffset = LastColumnOffset;
                    this.ImageIndex = ImageIndex;
                    this.Hyperlink = Hyperlink;
                }
                return ExcelImageData;
            }());
            Export.ExcelImageData = ExcelImageData;
            // struct CellRangeAddress
            var CellRangeAddress = /** @class */ (function () {
                function CellRangeAddress(FirstRow, LastRow, FirstColumn, LastColumn) {
                    this.FirstRow = FirstRow;
                    this.LastRow = LastRow;
                    this.FirstColumn = FirstColumn;
                    this.LastColumn = LastColumn;
                }
                return CellRangeAddress;
            }());
            Export.CellRangeAddress = CellRangeAddress;
            // struct HlinkData
            var HlinkData = /** @class */ (function () {
                function HlinkData(Range, Description, Bookmark) {
                    this.Range = Range;
                    this.Description = Description;
                    this.Bookmark = Bookmark;
                }
                return HlinkData;
            }());
            Export.HlinkData = HlinkData;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));



var Stimulsoft;
(function (Stimulsoft) {
    var Report;
    (function (Report) {
        var Export;
        (function (Export) {
            var StiString = Stimulsoft.System.StiString;
            var Formatting = Stimulsoft.System.Xml.Formatting;
            var Encoding = Stimulsoft.System.Text.Encoding;
            var DateTime = Stimulsoft.System.DateTime;
            var StiZipWriter20 = Stimulsoft.Base.Zip.StiZipWriter20;
            var MemoryStream = Stimulsoft.System.IO.MemoryStream;
            var StiPageOrientation = Stimulsoft.Report.Components.StiPageOrientation;
            var StiPagesCollection = Stimulsoft.Report.Components.StiPagesCollection;
            var StiBorderSides = Stimulsoft.Base.Drawing.StiBorderSides;
            var StiVertAlignment = Stimulsoft.Base.Drawing.StiVertAlignment;
            var StiRichText = Stimulsoft.Report.Components.StiRichText;
            var StiText = Stimulsoft.Report.Components.StiText;
            var XmlTextWriter = Stimulsoft.System.Xml.XmlTextWriter;
            var Char = Stimulsoft.System.Char;
            var StringBuilder = Stimulsoft.System.Text.StringBuilder;
            var StiBrush = Stimulsoft.Base.Drawing.StiBrush;
            var IStiFont = Stimulsoft.Report.Components.IStiFont;
            var IStiTextBrush = Stimulsoft.Report.Components.IStiTextBrush;
            var IStiTextHorAlignment = Stimulsoft.Report.Components.IStiTextHorAlignment;
            var IStiTextOptions = Stimulsoft.Report.Components.IStiTextOptions;
            var StiPenStyle = Stimulsoft.Base.Drawing.StiPenStyle;
            var Hashtable = Stimulsoft.System.Collections.Hashtable;
            var StiTextHorAlignment = Stimulsoft.Base.Drawing.StiTextHorAlignment;
            var StiLocalization = Stimulsoft.Base.Localization.StiLocalization;
            var IStiHorAlignment = Stimulsoft.Report.Components.IStiHorAlignment;
            var StiHtmlTagsState = Stimulsoft.Base.Drawing.StiHtmlTagsState;
            var StiHtmlState = Stimulsoft.Base.Drawing.StiHtmlState;
            var IStiExportImageExtended = Stimulsoft.Report.Components.IStiExportImageExtended;
            var StiWord2007StyleInfo = /** @class */ (function () {
                function StiWord2007StyleInfo() {
                }
                return StiWord2007StyleInfo;
            }());
            var StiWord2007ExportService = /** @class */ (function (_super) {
                __extends(StiWord2007ExportService, _super);
                function StiWord2007ExportService() {
                    var _this = _super !== null && _super.apply(this, arguments) || this;
                    _this._matrix = null;
                    _this._removeEmptySpaceAtBottom = StiOptions.Export.Word.removeEmptySpaceAtBottom;
                    _this.fontList = null;
                    _this.styleList = null;
                    _this.imageCache = null;
                    _this.bookmarkList = null;
                    _this.hyperlinkList = null;
                    _this.embedsList = null;
                    _this.xmlIndentation = 1;
                    _this.imageQuality = 0.75;
                    _this.imageResolution = 96; // dpi
                    _this.lineSpace = null;
                    _this.lineSpace2 = null;
                    _this.usePageHeadersAndFooters = false;
                    _this.restrictEditing = Export.StiWord2007RestrictEditing.No;
                    _this.headersData = null;
                    _this.headersRels = null;
                    _this.footersData = null;
                    _this.footersRels = null;
                    _this.docCompanyString = null;
                    _this.docLastModifiedString = null;
                    _this.wrongUrlSymbols = "\x20\x22\x23\x27\x2a\x2c\x3b\x3c\x3e\x5b\x5e\x60\x7b\x7c\x7d";
                    return _this;
                }
                Object.defineProperty(StiWord2007ExportService.prototype, "defaultExtension", {
                    get: function () {
                        return "docx";
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiWord2007ExportService.prototype, "exportFormat", {
                    get: function () {
                        return Report.StiExportFormat.Word2007;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiWord2007ExportService.prototype, "groupCategory", {
                    get: function () {
                        return "Word";
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiWord2007ExportService.prototype, "position", {
                    get: function () {
                        return Export.StiExportPosition.Word2007;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiWord2007ExportService.prototype, "exportNameInMenu", {
                    get: function () {
                        return StiLocalization.get("Export", "ExportTypeWord2007File");
                    },
                    enumerable: true,
                    configurable: true
                });
                StiWord2007ExportService.prototype.exportTo = function (report, stream, settings) {
                    this.exportWord(report, stream, settings);
                };
                StiWord2007ExportService.prototype.exportToAsync = function (onExport, report, stream, settings) {
                    var _this = this;
                    Stimulsoft.Report.Export.StiExportImageHelper.convertAllImages(report, Stimulsoft.System.Drawing.Imaging.ImageFormat.Jpeg)
                        .try(function () {
                        _this.exportTo(report, stream, settings);
                        onExport();
                    });
                };
                Object.defineProperty(StiWord2007ExportService.prototype, "multipleFiles", {
                  
                    get: function () {
                        return false;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiWord2007ExportService.prototype.getFilter = function () {
                    return StiLocalization.get("FileFilters", "Word2007Files");
                };
                Object.defineProperty(StiWord2007ExportService.prototype, "matrix", {
                    get: function () {
                        return this._matrix;
                    },
                    enumerable: true,
                    configurable: true
                });
                Object.defineProperty(StiWord2007ExportService.prototype, "removeEmptySpaceAtBottom", {
                    get: function () {
                        return this._removeEmptySpaceAtBottom;
                    },
                    enumerable: true,
                    configurable: true
                });
                // private static fontsToCorrectHeight: Hashtable = new Hashtable() { { "Arial Unicode MS", null } };
                StiWord2007ExportService.prototype.checkFontsToCorrectHeight = function (name) {
                    return name == "Arial Unicode MS" || name == "Microsoft YaHei";
                };
                StiWord2007ExportService.prototype.getLineStyle = function (penStyle) {
                    switch (penStyle) {
                        case StiPenStyle.Solid:
                            return "single";
                        case StiPenStyle.Dot:
                            return "dotted";
                        case StiPenStyle.Dash:
                            return "dashSmallGap";
                        case StiPenStyle.DashDot:
                            return "dotDash";
                        case StiPenStyle.DashDotDot:
                            return "dotDotDash";
                        case StiPenStyle.Double:
                            return "double";
                        default:
                            return "";
                    }
                };
                StiWord2007ExportService.prototype.getColorString = function (color) {
                    if (color.a == 0)
                        return "auto";
                    if (color.a < 32)
                        return "FFFFFF";
                    return StiString.format("{0:X8}", color.toArgb()).substr(2);
                };
                StiWord2007ExportService.prototype.getStyleNumber = function (tmpStyleList, styleInfo) {
                    if (tmpStyleList.length > 0) {
                        for (var index = 0; index < tmpStyleList.length; index++) {
                            var tmpStyle = tmpStyleList[index];
                            if ((tmpStyle.alignment == styleInfo.alignment) &&
                                (tmpStyle.name == styleInfo.name) &&
                                (tmpStyle.fontName == styleInfo.fontName) &&
                                (tmpStyle.fontSize == styleInfo.fontSize) &&
                                (tmpStyle.bold == styleInfo.bold) &&
                                (tmpStyle.italic == styleInfo.italic) &&
                                (tmpStyle.underline == styleInfo.underline) &&
                                (tmpStyle.textColor == styleInfo.textColor) &&
                                (tmpStyle.rightToLeft == styleInfo.rightToLeft)) {
                                // style is already in table, return number
                                return index;
                            }
                        }
                    }
                    // add style to table, return style number
                    tmpStyleList.add(styleInfo);
                    var temp = tmpStyleList.length - 1;
                    return temp;
                };
                StiWord2007ExportService.prototype.getStyleFromComponent = function (component) {
                    if ((component != null) && (!StiString.isNullOrEmpty(component.componentStyle))) {
                        var mFont = component.sti.as(IStiFont);
                        var mTextBrush = component.sti.as(IStiTextBrush);
                        var mTextHorAlign = component.sti.as(IStiTextHorAlignment);
                        var textOpt = component.sti.as(IStiTextOptions);
                        var style = new StiWord2007StyleInfo();
                        style.name = component.componentStyle;
                        if (mFont != null) {
                            style.fontName = mFont.font.name;
                            style.fontSize = Math.round2(mFont.font.sizeInPoints * 2, 0);
                            style.bold = mFont.font.bold;
                            style.italic = mFont.font.italic;
                            style.underline = mFont.font.underline;
                        }
                        if (mTextBrush != null) {
                            style.textColor = StiBrush.toColor(mTextBrush.textBrush);
                        }
                        if (mTextHorAlign != null) {
                            style.alignment = mTextHorAlign.horAlignment;
                        }
                        if (textOpt != null) {
                            style.rightToLeft = textOpt.textOptions.rightToLeft;
                        }
                        return this.getStyleNumber(this.styleList, style);
                    }
                    return -1;
                };
                StiWord2007ExportService.prototype.stringToUrl = function (input) {
                    if (StiString.isNullOrEmpty(input))
                        return "";
                    var output = new StringBuilder();
                    if (input.sti.startsWith("file:")) {
                        for (var _i = 0, _a = input.split(""); _i < _a.length; _i++) {
                            var ch = _a[_i];
                            if ((ch.charCodeAt(0) < 0x20) || (ch == '"')) {
                                output.append(StiString.format("%{0:x2}", ch));
                            }
                            else {
                                output.append(ch);
                            }
                        }
                    }
                    else {
                        for (var _b = 0, _c = input.split(""); _b < _c.length; _b++) {
                            var ch = _c[_b];
                            if ((ch.charCodeAt(0) < 0x20) || (this.wrongUrlSymbols.indexOf(ch) != -1)) {
                                output.append("_");
                            }
                            else {
                                output.append(ch);
                            }
                        }
                    }
                    return output.toString();
                };
                Object.defineProperty(StiWord2007ExportService, "hiToTwips", {
                    // conversion from hundredths of inch to twips
                    get: function () {
                        return 14.4 * 0.995;
                    },
                    enumerable: true,
                    configurable: true
                });
                StiWord2007ExportService.prototype.convert = function (x) {
                    return Math.round2(x * StiWord2007ExportService.hiToTwips);
                };
                StiWord2007ExportService.prototype.convertHiToTwips = function (x) {
                    return Math.round2(x * 14.4);
                };
                // 1 inch = 914400 EMU
                StiWord2007ExportService.prototype.convertTwipsToEmu = function (x) {
                    return Math.round2((x / StiWord2007ExportService.hiToTwips) / 100 * 914400);
                };
                StiWord2007ExportService.prototype.convertStringToBookmark = function (inputString) {
                    var sbOutput = new StringBuilder();
                    for (var _i = 0, _a = inputString.split(""); _i < _a.length; _i++) {
                        var ch = _a[_i];
                        if (Char.isLetterOrDigit(ch))
                            sbOutput.append(ch);
                    }
                    if (sbOutput.length > 0 && sbOutput.toString()[0] != null && Char.isDigit(sbOutput.toString()[0]))
                        sbOutput.insert(0, "b");
                    return sbOutput.toString();
                };
                StiWord2007ExportService.prototype.writeFromMatrix = function (writer, startLine, endLine, outHeadersAndFooters) {
                    var maxCoordX = this.matrix.coordX.countItems;
                    var maxCoordY = this.matrix.coordY.countItems;
                    // recalculate matrix coordinates
                    var wordCoordX = Array.create(Number, maxCoordX);
                    var coordXKeys = this.matrix.coordX.getKeys();
                    for (var indexColumn = 0; indexColumn < maxCoordX; indexColumn++) {
                        var columnX = this.matrix.coordX.getByIndex(indexColumn, coordXKeys);
                        wordCoordX[indexColumn] = this.convert(columnX);
                    }
                    var wordCoordY = Array.create(Number, maxCoordY);
                    var coordYKeys = this.matrix.coordY.getKeys();
                    for (var indexRow = 0; indexRow < maxCoordY; indexRow++) {
                        var columnY = this.matrix.coordY.getByIndex(indexRow, coordYKeys);
                        wordCoordY[indexRow] = this.convert(columnY);
                    }
                    var isTable = false;
                    var skipCounter = 0;
                    // rows
                    var readyCells = Array.create(Boolean, maxCoordY, maxCoordX);
                    var readyCellsVert = Array.create(Boolean, maxCoordY, maxCoordX);
                    var lastHeaderName = "";
                    this.currentPassNumber = 2 + (StiOptions.Export.Word.divideSegmentPages ? 1 : 0);
                    for (var indexRow = 1; indexRow < maxCoordY; indexRow++) {
                        this.invokeExporting2(indexRow, maxCoordY, this.currentPassNumber, this.maximumPassNumber);
                        var needOutLine = ((indexRow - 1) >= startLine) && ((indexRow - 1) <= endLine);
                        if (outHeadersAndFooters == false) {
                            if ((this.matrix.linePlacement[indexRow - 1] == Export.StiTableLineInfo.PageHeader) ||
                                (this.matrix.linePlacement[indexRow - 1] == Export.StiTableLineInfo.PageFooter) ||
                                (this.matrix.linePlacement[indexRow - 1] == Export.StiTableLineInfo.Trash)) {
                                needOutLine = false;
                            }
                        }
                        if (skipCounter > 0) {
                            skipCounter--;
                            needOutLine = false;
                        }
                        var maxTopMargin = 100005;
                        // check for rtfparagraph, rtfnewpage and CanBreak
                        var paragraphList = [];
                        var needNewPage = false;
                        if (needOutLine) {
                            for (var columnIndex = 1; columnIndex < maxCoordX; columnIndex++) {
                                var cell = this.matrix.cells[indexRow - 1][columnIndex - 1];
                                if ((readyCells[indexRow][columnIndex] == false) && (cell != null) && (cell.component != null)) {
                                    if (cell.component.tagValue != null) {
                                        var cellTag = cell.component.tagValue.toString().toLowerCase();
                                        if (cellTag.indexOf("rtfparagraph") != -1) {
                                            paragraphList.add(cell);
                                            needOutLine = false;
                                        }
                                        if (cellTag.indexOf("rtfnewpage") != -1)
                                            needNewPage = true;
                                    }
                                    var margins = null;
                                    if (cell.component.sti.is(StiText))
                                        margins = cell.component.margins;
                                    if (cell.component.sti.is(StiRichText))
                                        margins = cell.component.margins;
                                    if (margins != null) {
                                        if (margins.top < maxTopMargin)
                                            maxTopMargin = margins.top;
                                        if (cell.height > 0) {
                                            maxTopMargin = 0;
                                        }
                                    }
                                }
                            }
                        }
                        maxTopMargin *= StiWord2007ExportService.hiToTwips;
                        var maxTopMarginInt = Math.round2(maxTopMargin);
                        if (needNewPage) {
                            if (isTable) {
                                writer.writeFullEndElement();
                                isTable = false;
                            }
                            writer.writeStartElement("w:p");
                            writer.writeStartElement("w:r");
                            writer.writeStartElement("w:br");
                            writer.writeAttributeString("w:type", "page");
                            writer.writeEndElement();
                            writer.writeEndElement();
                            writer.writeEndElement();
                        }
                        if (needOutLine) {
                            if ((this.usePageHeadersAndFooters) && (this.matrix.linePlacement[indexRow - 1] == Export.StiTableLineInfo.HeaderAP)) {
                                var headerName = this.matrix.parentBandName[indexRow - 1];
                                var symPos = headerName.indexOf("\x1f");
                                if (symPos != -1) {
                                    headerName = headerName.substr(0, symPos);
                                }
                                if (headerName != lastHeaderName) {
                                    lastHeaderName = headerName;
                                    if (isTable) {
                                        writer.writeFullEndElement();
                                    }
                                    writer.writeStartElement("w:p");
                                    writer.writeEndElement();
                                    writer.writeStartElement("w:tbl");
                                    this.writeTableInfo(writer, wordCoordX, maxCoordX);
                                    isTable = true;
                                }
                            }
                            if (!isTable) {
                                writer.writeStartElement("w:tbl");
                                this.writeTableInfo(writer, wordCoordX, maxCoordX);
                                isTable = true;
                            }
                            writer.writeStartElement("w:tr");
                            // row info
                            var rowHeight = wordCoordY[indexRow] - wordCoordY[indexRow - 1];
                            writer.writeStartElement("w:trPr");
                            if (!this.usePageHeadersAndFooters || StiOptions.Export.Word.forceLineHeight) {
                                writer.writeStartElement("w:trHeight");
                                if ((!this.usePageHeadersAndFooters) && (StiOptions.Export.Word.lineHeightExactly) ||
                                    this.usePageHeadersAndFooters && StiOptions.Export.Word.lineHeightExactlyForPHFMode) {
                                    writer.writeAttributeString("w:hRule", "exact");
                                }
                                writer.writeAttributeString("w:val", StiString.format("{0}", rowHeight));
                                writer.writeEndElement();
                            }
                            if ((this.usePageHeadersAndFooters) && (this.matrix.linePlacement[indexRow - 1] == Export.StiTableLineInfo.HeaderAP)) {
                                writer.writeStartElement("w:tblHeader");
                                writer.writeEndElement();
                            }
                            writer.writeEndElement();
                        }
                        var curCoordX = 0;
                        for (var indexColumn = 1; indexColumn < maxCoordX; indexColumn++) {
                            var cell = this.matrix.cells[indexRow - 1][indexColumn - 1];
                            if ((!readyCells[indexRow][indexColumn]) || (readyCellsVert[indexRow][indexColumn])) {
                                curCoordX++;
                                var needContent = true;
                                if (readyCellsVert[indexRow][indexColumn]) {
                                    var tempIndexRow = indexRow;
                                    while (readyCellsVert[tempIndexRow][indexColumn])
                                        tempIndexRow--;
                                    cell = this.matrix.cells[tempIndexRow - 1][indexColumn - 1];
                                    needContent = false;
                                }
                                if ((cell != null) && (needContent)) {
                                    // Range
                                    for (var yy = 0; yy <= cell.height; yy++) {
                                        for (var xx = 0; xx <= cell.width; xx++) {
                                            readyCells[indexRow + yy][indexColumn + xx] = true;
                                        }
                                    }
                                    if (cell.height > 0) {
                                        for (var yy = 1; yy <= cell.height; yy++) {
                                            readyCellsVert[indexRow + yy][indexColumn] = true;
                                        }
                                    }
                                }
                                if (needOutLine) {
                                    writer.writeStartElement("w:tc");
                                    if (cell != null) {
                                        // cell properties
                                        writer.writeStartElement("w:tcPr");
                                        // cell width
                                        var cellWidth = 0;
                                        for (var indexMerg = 0; indexMerg < cell.width + 1; indexMerg++) {
                                            cellWidth += wordCoordX[indexColumn + indexMerg] - wordCoordX[indexColumn - 1 + indexMerg];
                                        }
                                        writer.writeStartElement("w:tcW");
                                        writer.writeAttributeString("w:w", StiString.format("{0}", cellWidth));
                                        writer.writeAttributeString("w:type", "dxa");
                                        writer.writeEndElement();
                                        // merged cells
                                        if (cell.width > 0) {
                                            // merged width
                                            writer.writeStartElement("w:gridSpan");
                                            writer.writeAttributeString("w:val", StiString.format("{0}", cell.width + 1));
                                            writer.writeEndElement();
                                        }
                                        if (cell.height > 0) {
                                            // merged height
                                            if (!readyCellsVert[indexRow][indexColumn]) {
                                                // on first line
                                                writer.writeStartElement("w:vMerge");
                                                writer.writeAttributeString("w:val", "restart");
                                                writer.writeEndElement();
                                            }
                                            else {
                                                // on other lines
                                                writer.writeStartElement("w:vMerge");
                                                writer.writeEndElement();
                                            }
                                        }
                                        // text direction
                                        if (cell.cellStyle.textOptions != null) {
                                            var textAngle = cell.cellStyle.textOptions.angle;
                                            var stTextAngle = "";
                                            if ((textAngle > 45) && (textAngle < 135))
                                                stTextAngle = "btLr";
                                            if ((textAngle > 225) && (textAngle < 315))
                                                stTextAngle = "tbRl";
                                            if (stTextAngle != "") {
                                                writer.writeStartElement("w:textDirection");
                                                writer.writeAttributeString("w:val", stTextAngle);
                                                writer.writeEndElement();
                                            }
                                        }
                                        // cell margins
                                        var isEmbedRtfFlag = cell.component.sti.is(StiText) && cell.component.checkAllowHtmlTags() && !StiOptions.Export.Word.renderHtmlTagsAsImage;
                                        if (needContent && (cell.component.sti.is(StiText)) && (!cell.component.isExportAsImage(Report.StiExportFormat.Word2007) || isEmbedRtfFlag)) {
                                            var stiText = cell.component;
                                            var mLeft = this.convert(stiText.margins.left);
                                            var mRight = this.convert(stiText.margins.right - StiOptions.Export.Word.rightMarginCorrection);
                                            var mTop = this.convert(stiText.margins.top);
                                            if (mTop > maxTopMarginInt)
                                                mTop = maxTopMarginInt;
                                            if ((mLeft > 0) || (mRight > 0) || (mTop > 0)) {
                                                writer.writeStartElement("w:tcMar");
                                                if (mTop > 0) {
                                                    writer.writeStartElement("w:top");
                                                    writer.writeAttributeString("w:w", StiString.format("{0}", mTop));
                                                    writer.writeAttributeString("w:type", "dxa");
                                                    writer.writeEndElement();
                                                }
                                                if (mLeft > 0) {
                                                    writer.writeStartElement("w:left");
                                                    writer.writeAttributeString("w:w", StiString.format("{0}", mLeft));
                                                    writer.writeAttributeString("w:type", "dxa");
                                                    writer.writeEndElement();
                                                }
                                                if (mRight > 0) {
                                                    writer.writeStartElement("w:right");
                                                    writer.writeAttributeString("w:w", StiString.format("{0}", mRight));
                                                    writer.writeAttributeString("w:type", "dxa");
                                                    writer.writeEndElement();
                                                }
                                                writer.writeEndElement();
                                            }
                                        }
                                        // vertical align
                                        var stVertAlign = "";
                                        switch (cell.cellStyle.vertAlignment) {
                                            case StiVertAlignment.Center:
                                                stVertAlign = "center";
                                                break;
                                            case StiVertAlignment.Bottom:
                                                stVertAlign = "bottom";
                                                break;
                                        }
                                        if (stVertAlign != "") {
                                            writer.writeStartElement("w:vAlign");
                                            writer.writeAttributeString("w:val", stVertAlign);
                                            writer.writeEndElement();
                                        }
                                        this.writeBorders(writer, cell.top, cell.left, cell.height + 1, cell.width + 1);
                                        // fill color
                                        if (!cell.component.isExportAsImage(Report.StiExportFormat.Word2007)) {
                                            writer.writeStartElement("w:shd");
                                            writer.writeAttributeString("w:val", "clear");
                                            writer.writeAttributeString("w:color", "auto");
                                            writer.writeAttributeString("w:fill", this.getColorString(cell.cellStyle.color));
                                            writer.writeEndElement();
                                        }
                                        writer.writeEndElement();
                                        var needPerm = (this.restrictEditing == Export.StiWord2007RestrictEditing.ExceptEditableFields) && (cell.component != null) && (cell.component.sti.is(StiText)) && cell.component.editable;
                                        if (needPerm) {
                                            writer.writeStartElement("w:permStart");
                                            writer.writeAttributeString("w:id", "0");
                                            writer.writeEndElement();
                                        }
                                        var needEmptyParagraph = true;
                                        if (needContent) {
                                            // cell contents
                                            var REFneedEmptyParagraph = { ref: needEmptyParagraph };
                                            this.writeCellContent(writer, cell, REFneedEmptyParagraph, indexRow, indexColumn, wordCoordX, wordCoordY);
                                            needEmptyParagraph = REFneedEmptyParagraph.ref;
                                        }
                                        if (needEmptyParagraph) {
                                            writer.writeStartElement("w:p");
                                            writer.writeFullEndElement();
                                        }
                                        if (needPerm) {
                                            writer.writeStartElement("w:permEnd");
                                            writer.writeAttributeString("w:id", "0");
                                            writer.writeEndElement();
                                        }
                                    }
                                    else {
                                        // prepare data
                                        var baseSt = null;
                                        var REFbaseSt = { ref: baseSt };
                                        var baseSides = this.renderBorder2TableGetValues(indexRow, indexColumn, REFbaseSt);
                                        var newWidth = 0;
                                        if ((baseSides & StiBorderSides.Right) == 0) {
                                            while ((indexColumn + newWidth + 1 < maxCoordX) && (this.matrix.cells[indexRow - 1][indexColumn + newWidth + 1 - 1] == null) &&
                                                (readyCells[indexRow][indexColumn + newWidth + 1] == false) && (readyCellsVert[indexRow][indexColumn + newWidth + 1] == false)) {
                                                var newSt = null;
                                                var REFnewSt = { ref: newSt };
                                                var newSides = this.renderBorder2TableGetValues(indexRow, indexColumn + newWidth + 1, REFnewSt);
                                                if ((newSides & StiBorderSides.Left) > 0)
                                                    break;
                                                if ((newSides & (StiBorderSides.Top | StiBorderSides.Bottom)) != (baseSides & (StiBorderSides.Top | StiBorderSides.Bottom)))
                                                    break;
                                                if (baseSt != newSt)
                                                    break;
                                                newWidth++;
                                                if ((newSides & StiBorderSides.Right) > 0)
                                                    break;
                                            }
                                            if (newWidth > 0) {
                                                for (var xx = 1; xx <= newWidth; xx++) {
                                                    readyCells[indexRow][indexColumn + xx] = true;
                                                }
                                            }
                                        }
                                        // empty cell
                                        writer.writeStartElement("w:tcPr");
                                        var cellWidth = wordCoordX[indexColumn + newWidth] - wordCoordX[indexColumn - 1];
                                        writer.writeStartElement("w:tcW");
                                        writer.writeAttributeString("w:w", StiString.format("{0}", cellWidth));
                                        writer.writeAttributeString("w:type", "dxa");
                                        writer.writeEndElement();
                                        if (newWidth > 0) {
                                            // merged width
                                            writer.writeStartElement("w:gridSpan");
                                            writer.writeAttributeString("w:val", StiString.format("{0}", newWidth + 1));
                                            writer.writeEndElement();
                                        }
                                        this.writeBorders(writer, indexRow - 1, indexColumn - 1, 1, newWidth + 1);
                                        writer.writeEndElement();
                                        writer.writeStartElement("w:p");
                                        writer.writeFullEndElement();
                                    }
                                    writer.writeFullEndElement();
                                }
                            }
                            if (curCoordX >= 64)
                                break;
                        }
                        if (needOutLine) {
                            writer.writeFullEndElement(); // w:tr
                        }
                        for (var _i = 0, paragraphList_1 = paragraphList; _i < paragraphList_1.length; _i++) {
                            var paragraphCell = paragraphList_1[_i];
                            if (isTable) {
                                writer.writeEndElement(); // w:tbl
                            }
                            isTable = false;
                            skipCounter = paragraphCell.height;
                            var needEmptyParagraph2 = false;
                            var REFneedEmptyParagraph2 = { ref: needEmptyParagraph2 };
                            this.writeCellContent(writer, paragraphCell, REFneedEmptyParagraph2, paragraphCell.top + 1, paragraphCell.left + 1, wordCoordX, wordCoordY);
                            needEmptyParagraph2 = REFneedEmptyParagraph2.ref;
                        }
                    }
                    if (isTable) {
                        writer.writeEndElement(); // w:tbl
                    }
                };
                StiWord2007ExportService.prototype.writeCellContent = function (writer, cell, REFneedEmptyParagraph, indexRow, indexColumn, wordCoordX, wordCoordY) {
                    var needEmptyParagraph = REFneedEmptyParagraph.ref;
                    // get bookmarks, hyperlinks info
                    var bkmRefText = null;
                    var bkmRefId = -1;
                    var bkm = this.matrix.bookmarks[indexRow - 1][indexColumn - 1];
                    if ((bkm != null) && (!this.bookmarkList.containsKey(bkm))) {
                        bkmRefId = this.bookmarkList.count;
                        bkmRefText = this.convertStringToBookmark(bkm);
                        this.bookmarkList.set(bkm, bkmRefId);
                    }
                    var hypRefText = null;
                    var hypRefId = -1;
                    if (cell.component != null && cell.component.hyperlinkValue != null) {
                        var hyperlink = cell.component.hyperlinkValue.toString().trim();
                        if (hyperlink.length > 0 && !hyperlink.sti.startsWith("javascript:")) {
                            if (hyperlink.sti.startsWith("#")) {
                                hypRefText = this.convertStringToBookmark(hyperlink.substr(1));
                            }
                            else {
                                hypRefText = this.stringToUrl(hyperlink);
                                if (this.hyperlinkList.containsKey(hypRefText)) {
                                    hypRefId = Math.trunc(this.hyperlinkList.get(hypRefText));
                                }
                                else {
                                    hypRefId = this.hyperlinkList.count;
                                    this.hyperlinkList.add(hypRefText, hypRefId);
                                }
                            }
                        }
                    }
                    // cell contents
                    if ((cell.component.sti.is(StiText)) && (!cell.component.isExportAsImage(Report.StiExportFormat.Word2007)) && !cell.component.checkAllowHtmlTags()) {
                        // StiText
                        var sb = new StringBuilder(cell.text);
                        if (this.usePageHeadersAndFooters) {
                            var expr = cell.component.tagValue;
                            if (!StiString.isNullOrEmpty(expr)) {
                                if (expr.toLowerCase().indexOf("rtfnewpage") == -1 &&
                                    (expr.indexOf("#PageNumber#") != -1 ||
                                        expr.indexOf("#TotalPageCount#") != -1 ||
                                        expr.indexOf("#PageRef") != -1)) {
                                    sb = new StringBuilder(expr);
                                }
                            }
                        }
                        // count lines and make stringList
                        var stringList = [];
                        var st = "";
                        for (var _i = 0, _a = sb.toString().split(""); _i < _a.length; _i++) {
                            var ch = _a[_i];
                            if (Char.isControl(ch) && (ch != "\t")) {
                                if (ch == "\n") {
                                    stringList.add(st);
                                    st = "";
                                }
                            }
                            else {
                                st += ch;
                            }
                        }
                        if (st != "")
                            stringList.add(st);
                        if (stringList.length == 0)
                            stringList.add(st);
                        if (stringList.length > 0)
                            needEmptyParagraph = false;
                        var styleIndex = this.getStyleFromComponent(cell.component);
                        for (var indexLine = 0; indexLine < stringList.length; indexLine++) {
                            var textLine = stringList[indexLine];
                            writer.writeStartElement("w:p");
                            // paragraph properties
                            writer.writeStartElement("w:pPr");
                            var lineHeight = (cell.component.sti.as(StiText)).lineSpacing;
                            if (this.lineSpace != null || lineHeight != 1) {
                                var stLineSpace = this.lineSpace;
                                if (lineHeight != 1) {
                                    stLineSpace = (Math.round2(StiOptions.Export.Word.lineSpacing * 240 * lineHeight)).toString();
                                }
                                var font = cell.component.sti.as(IStiFont);
                                if (font != null && font.font != null) {
                                    if (this.checkFontsToCorrectHeight(font.font.name)) {
                                        stLineSpace = this.lineSpace2;
                                        if (lineHeight != 1) {
                                            stLineSpace = (Math.round2(StiOptions.Export.Word.lineSpacing * 240 * 0.772 * lineHeight)).toString();
                                        }
                                    }
                                }
                                writer.writeStartElement("w:spacing");
                                writer.writeAttributeString("w:line", stLineSpace);
                                writer.writeEndElement();
                            }
                            if (styleIndex != -1) {
                                writer.writeStartElement("w:pStyle");
                                writer.writeAttributeString("w:val", StiString.format("Style{0}", styleIndex));
                                writer.writeEndElement();
                            }
                            // horizontal align
                            var horAlignment = cell.cellStyle.horAlignment;
                            var rightToLeft = false;
                            if (cell.cellStyle.textOptions != null)
                                rightToLeft = cell.cellStyle.textOptions.rightToLeft;
                            var stHorAlignment = "";
                            if (((horAlignment == StiTextHorAlignment.Left) &&
                                (rightToLeft == true)) ||
                                ((horAlignment == StiTextHorAlignment.Right) &&
                                    (rightToLeft == false))) {
                                stHorAlignment = "right";
                            }
                            if (horAlignment == StiTextHorAlignment.Center)
                                stHorAlignment = "center";
                            if (horAlignment == StiTextHorAlignment.Width)
                                stHorAlignment = "both";
                            if (stHorAlignment != "") {
                                writer.writeStartElement("w:jc");
                                writer.writeAttributeString("w:val", stHorAlignment);
                                writer.writeEndElement();
                            }
                            if (styleIndex == -1) {
                                this.writeRunProperties(writer, cell);
                            }
                            writer.writeEndElement();
                            if (hypRefText != null) {
                                writer.writeStartElement("w:hyperlink");
                                if (hypRefId == -1) {
                                    writer.writeAttributeString("w:anchor", hypRefText);
                                }
                                else {
                                    writer.writeAttributeString("r:id", StiString.format("hId{0}", hypRefId));
                                }
                            }
                            if (bkmRefId != -1) {
                                writer.writeStartElement("w:bookmarkStart");
                                writer.writeAttributeString("w:id", bkmRefId.toString());
                                writer.writeAttributeString("w:name", bkmRefText);
                                writer.writeEndElement();
                            }
                            if (textLine != "") {
                                if (this.usePageHeadersAndFooters) {
                                    // write by runs
                                    textLine = textLine.sti.replaceAll("#PageNumber#", "\x01").sti.replaceAll("#TotalPageCount#", "\x02");
                                    // count lines and make runList
                                    var runList = [];
                                    var sbr = new StringBuilder();
                                    for (var _b = 0, _c = textLine.split(""); _b < _c.length; _b++) {
                                        var ch = _c[_b];
                                        if ((ch == "\x01") || (ch == "\x02")) {
                                            if (sbr.length > 0)
                                                runList.add(sbr.toString());
                                            runList.add(ch.toString());
                                            sbr = new StringBuilder();
                                        }
                                        else {
                                            sbr.append(ch);
                                        }
                                    }
                                    if (sbr.length > 0)
                                        runList.add(sbr.toString());
                                    if (runList.length == 0)
                                        runList.add(textLine);
                                    for (var indexRun = 0; indexRun < runList.length; indexRun++) {
                                        var run = runList[indexRun];
                                        if ((run.length > 0) && ((run[0] == "\x01") || (run[0] == "\x02"))) {
                                            // write field
                                            writer.writeStartElement("w:r");
                                            if (styleIndex == -1) {
                                                this.writeRunProperties(writer, cell);
                                            }
                                            writer.writeStartElement("w:fldChar");
                                            writer.writeAttributeString("w:fldCharType", "begin");
                                            writer.writeEndElement();
                                            writer.writeEndElement(); // w:r
                                            writer.writeStartElement("w:r");
                                            this.writeRunProperties(writer, cell);
                                            writer.writeStartElement("w:instrText");
                                            switch (run.charAt(0)) {
                                                case "\x01":
                                                    writer.writeString("PAGE");
                                                    break;
                                                case "\x02":
                                                    writer.writeString("NUMPAGES");
                                                    break;
                                            }
                                            writer.writeEndElement();
                                            writer.writeEndElement(); // w:r
                                            writer.writeStartElement("w:r");
                                            this.writeRunProperties(writer, cell);
                                            writer.writeStartElement("w:fldChar");
                                            writer.writeAttributeString("w:fldCharType", "end");
                                            writer.writeEndElement();
                                            writer.writeEndElement(); // w:r
                                        }
                                        else {
                                            writer.writeStartElement("w:r");
                                            if (styleIndex == -1) {
                                                this.writeRunProperties(writer, cell);
                                            }
                                            writer.writeStartElement("w:t");
                                            writer.writeAttributeString("xml:space", "preserve");
                                            writer.writeString(run);
                                            writer.writeEndElement();
                                            writer.writeEndElement(); // w:r
                                        }
                                    }
                                }
                                else {
                                    writer.writeStartElement("w:r");
                                    if (styleIndex == -1) {
                                        this.writeRunProperties(writer, cell);
                                    }
                                    writer.writeStartElement("w:t");
                                    writer.writeAttributeString("xml:space", "preserve");
                                    writer.writeString(textLine);
                                    writer.writeEndElement();
                                    writer.writeEndElement(); // w:r
                                }
                            }
                            if (bkmRefId != -1) {
                                writer.writeStartElement("w:bookmarkEnd");
                                writer.writeAttributeString("w:id", bkmRefId.toString());
                                writer.writeEndElement();
                            }
                            if (hypRefText != null) {
                                writer.writeEndElement();
                            }
                            writer.writeEndElement(); // w:p
                        }
                    }
                    else if (cell.component.sti.is(StiRichText) && !StiOptions.Export.Word.renderRichTextAsImage) {
                        // StiRichText
                        var rich = cell.component;
                       
                    }
                    else if (cell.component.sti.is(StiText) && cell.component.checkAllowHtmlTags() && !StiOptions.Export.Word.renderHtmlTagsAsImage) {
                        if (!StiString.isNullOrWhiteSpace(cell.text)) {
                            this.writeHtmlTags(writer, cell);
                        }
                    }
                    else if (cell.component.isExportAsImage(Report.StiExportFormat.Word2007)) {
                        // Image
                        var exportImage = cell.component.sti.as(IStiExportImageExtended);
                        if (exportImage != null) {
                            var rsImageResolution = this.imageResolution;
                            var REFzoom = { ref: rsImageResolution };
                            var image = exportImage.getImage(REFzoom);
                            rsImageResolution = REFzoom.ref;
                            if (image != null) {
                                var img = this.matrix.getRealImageData(cell, image);
                                needEmptyParagraph = false;
                                var imageIndex = 0;
                                if (img != null)
                                    imageIndex = this.imageCache.addImageIntRaw(img, img.imageFormat);
                                else
                                    imageIndex = this.imageCache.addImageIntRaw(image, image.imageFormat);
                                var richWidth = -1;
                                var richHeight = -1;
                                // if ((cell.component.sti.is(StiRichText)) && StiOptions.Engine.FullTrust)
                                // {
                                //    StiRichText rich = cell.Component as StiRichText;
                                //    rich.RenderMetafile();
                                //    richWidth = Convert(rich.Image.PhysicalDimension.Width / 25.4);
                                //    richHeight = Convert(rich.Image.PhysicalDimension.Height / 25.4);
                                //    imageCache.ImagePackedStore[imageIndex] = ConvertRichTextToImageInFullTrust(rich);
                                // }
                                // write image info
                                writer.writeStartElement("w:p");
                                // paragraph properties
                                writer.writeStartElement("w:pPr");
                                // horizontal align
                                var horAlignment = cell.cellStyle.horAlignment;
                                var rightToLeft = false;
                                if (cell.cellStyle.textOptions != null)
                                    rightToLeft = cell.cellStyle.textOptions.rightToLeft;
                                if ((cell.component.sti.as(IStiTextHorAlignment)) == null) {
                                    var horAlignComp = cell.component.sti.as(IStiHorAlignment);
                                    // if (horAlignComp != null) horAlignment = (StiTextHorAlignment)horAlignComp.horAlignment;
                                }
                                // string stHorAlignment = "left";
                                var stHorAlignment = "";
                                if (((horAlignment == StiTextHorAlignment.Left) &&
                                    (rightToLeft == true)) ||
                                    ((horAlignment == StiTextHorAlignment.Right) &&
                                        (rightToLeft == false))) {
                                    stHorAlignment = "right";
                                }
                                if (horAlignment == StiTextHorAlignment.Center)
                                    stHorAlignment = "center";
                                if (horAlignment == StiTextHorAlignment.Width)
                                    stHorAlignment = "both";
                                if (stHorAlignment != "") {
                                    writer.writeStartElement("w:jc");
                                    writer.writeAttributeString("w:val", stHorAlignment);
                                    writer.writeEndElement();
                                }
                                writer.writeEndElement();
                                if (bkmRefId != -1) {
                                    writer.writeStartElement("w:bookmarkStart");
                                    writer.writeAttributeString("w:id", bkmRefId.toString());
                                    writer.writeAttributeString("w:name", bkmRefText);
                                    writer.writeEndElement();
                                }
                                writer.writeStartElement("w:r");
                                // Image
                                writer.writeStartElement("w:rPr");
                                writer.writeElementString("w:noProof", "");
                                writer.writeEndElement();
                                // drawing
                                writer.writeStartElement("w:drawing");
                                writer.writeStartElement("wp:inline");
                                writer.writeAttributeString("distT", "0");
                                writer.writeAttributeString("distB", "0");
                                writer.writeAttributeString("distL", "0");
                                writer.writeAttributeString("distR", "0");
                                var imageHeight = wordCoordY[indexRow - 1 + cell.height + 1] - wordCoordY[indexRow - 1];
                                var imageWidth = wordCoordX[indexColumn - 1 + cell.width + 1] - wordCoordX[indexColumn - 1];
                                if (richWidth != -1) {
                                    imageWidth = richWidth;
                                    imageHeight = richHeight;
                                }
                                // drawing properties
                                writer.writeStartElement("wp:extent");
                                writer.writeAttributeString("cx", StiString.format("{0}", this.convertTwipsToEmu(imageWidth)));
                                writer.writeAttributeString("cy", StiString.format("{0}", this.convertTwipsToEmu(imageHeight)));
                                writer.writeEndElement();
                                writer.writeStartElement("wp:effectExtent");
                                writer.writeAttributeString("l", "0");
                                writer.writeAttributeString("t", "0");
                                writer.writeAttributeString("r", "0");
                                writer.writeAttributeString("b", "0");
                                writer.writeEndElement();
                                writer.writeStartElement("wp:docPr");
                                writer.writeAttributeString("id", StiString.format("{0}", imageIndex + 2));
                                writer.writeAttributeString("name", StiString.format("Picture {0}", imageIndex + 1));
                                writer.writeAttributeString("descr", StiString.format("Image{0:D5}.jpg", imageIndex + 1));
                                if (hypRefText != null) {
                                    if (hypRefId == -1) {
                                        hypRefText = "#" + hypRefText;
                                        if (this.hyperlinkList.containsKey(hypRefText)) {
                                            hypRefId = this.hyperlinkList.get(hypRefText);
                                        }
                                        else {
                                            hypRefId = this.hyperlinkList.count;
                                            this.hyperlinkList.add(hypRefText, hypRefId);
                                        }
                                    }
                                    writer.writeStartElement("a:hlinkClick");
                                    writer.writeAttributeString("xmlns:a", "http://schemas.openxmlformats.org/drawingml/2006/main");
                                    writer.writeAttributeString("r:id", StiString.format("hId{0}", hypRefId));
                                    writer.writeEndElement();
                                }
                                writer.writeEndElement();
                                writer.writeStartElement("wp:cNvGraphicFramePr");
                                writer.writeStartElement("a:graphicFrameLocks");
                                writer.writeAttributeString("xmlns:a", "http://schemas.openxmlformats.org/drawingml/2006/main");
                                writer.writeAttributeString("noChangeAspect", "1");
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeStartElement("a:graphic");
                                writer.writeAttributeString("xmlns:a", "http://schemas.openxmlformats.org/drawingml/2006/main");
                                writer.writeStartElement("a:graphicData");
                                writer.writeAttributeString("uri", "http://schemas.openxmlformats.org/drawingml/2006/picture");
                                writer.writeStartElement("pic:pic");
                                writer.writeAttributeString("xmlns:pic", "http://schemas.openxmlformats.org/drawingml/2006/picture");
                                writer.writeStartElement("pic:nvPicPr");
                                writer.writeStartElement("pic:cNvPr");
                                writer.writeAttributeString("id", "0");
                                writer.writeAttributeString("name", StiString.format("Image{0:D5}.jpg", imageIndex + 1));
                                writer.writeEndElement();
                                writer.writeStartElement("pic:cNvPicPr");
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeStartElement("pic:blipFill");
                                writer.writeStartElement("a:blip");
                                writer.writeAttributeString("r:embed", StiString.format("rId{0}", 5 + imageIndex));
                                writer.writeAttributeString("cstate", "print");
                                writer.writeEndElement();
                                writer.writeStartElement("a:stretch");
                                writer.writeStartElement("a:fillRect");
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeStartElement("pic:spPr");
                                writer.writeStartElement("a:xfrm");
                                writer.writeStartElement("a:off");
                                writer.writeAttributeString("x", "0");
                                writer.writeAttributeString("y", "0");
                                writer.writeEndElement();
                                writer.writeStartElement("a:ext");
                                writer.writeAttributeString("cx", StiString.format("{0}", this.convertTwipsToEmu(imageWidth)));
                                writer.writeAttributeString("cy", StiString.format("{0}", this.convertTwipsToEmu(imageHeight)));
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeStartElement("a:prstGeom");
                                writer.writeAttributeString("prst", "rect");
                                writer.writeStartElement("a:avLst");
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeEndElement();
                                writer.writeEndElement(); // pic:pic
                                writer.writeEndElement(); // a:graphicData
                                writer.writeEndElement(); // a:graphic
                                writer.writeEndElement(); // wp:inline
                                writer.writeEndElement(); // w:drawing
                                writer.writeEndElement(); // w:r
                                if (bkmRefId != -1) {
                                    writer.writeStartElement("w:bookmarkEnd");
                                    writer.writeAttributeString("w:id", bkmRefId.toString());
                                    writer.writeEndElement();
                                }
                                writer.writeEndElement(); // w:p
                            }
                        }
                    }
                    else {
                        // Bookmarks
                        if (bkmRefId != -1) {
                            writer.writeStartElement("w:bookmarkStart");
                            writer.writeAttributeString("w:id", bkmRefId.toString());
                            writer.writeAttributeString("w:name", bkmRefText);
                            writer.writeEndElement();
                            writer.writeStartElement("w:bookmarkEnd");
                            writer.writeAttributeString("w:id", bkmRefId.toString());
                            writer.writeEndElement();
                        }
                    }
                    REFneedEmptyParagraph.ref = needEmptyParagraph;
                };
                /*private byte[] ConvertRichTextToImageInFullTrust(StiRichText rich)
            {
                let ms: MemoryStream = new MemoryStream();
        
                Image bmp = null;
                using(Bitmap bmpTemp = new Bitmap(1, 1))
                using(Graphics grfx = Graphics.FromImage(bmpTemp))
                {
                    IntPtr ipHdc = grfx.GetHdc();
                    bmp = new Metafile(ms, ipHdc);
                    //bmp = new Metafile(@"d:\test.emf", ipHdc);
                    grfx.ReleaseHdc(ipHdc);
                }
        
                //rich.Image.Save(ms, ImageFormat.Emf);
                using(Graphics gr = Graphics.FromImage(bmp))
                {
                    gr.DrawImage(rich.Image, 0, 0);
                }
                ms.flush();
        
                return ms.ToArray();
            }*/
                StiWord2007ExportService.prototype.writeTableInfo = function (writer, wordCoordX, maxCoordX) {
                    // table properties
                    writer.writeStartElement("w:tblPr");
                    writer.writeStartElement("w:tblStyle");
                    writer.writeAttributeString("w:val", "a1");
                    writer.writeEndElement();
                    writer.writeStartElement("w:tblW");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:tblLayout");
                    writer.writeAttributeString("w:type", "fixed");
                    writer.writeEndElement();
                    writer.writeStartElement("w:tblCellMar");
                    writer.writeStartElement("w:top");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:left");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:bottom");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:right");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:tblLook");
                    writer.writeAttributeString("w:val", "04A0");
                    writer.writeEndElement();
                    writer.writeEndElement(); // w:tblPr
                    // columns info
                    writer.writeStartElement("w:tblGrid");
                    for (var indexColumn = 1; indexColumn < maxCoordX; indexColumn++) {
                        var columnWidth = wordCoordX[indexColumn] - wordCoordX[indexColumn - 1];
                        writer.writeStartElement("w:gridCol");
                        writer.writeAttributeString("w:w", StiString.format("{0}", columnWidth));
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                };
                StiWord2007ExportService.prototype.writeHtmlTags = function (writer, cell) {
                    var stiText = cell.component;
                    var inputText = cell.text;
                    //#region Prepare states
                    var baseTagsState = new StiHtmlTagsState(stiText.font.bold, stiText.font.italic, stiText.font.underline, stiText.font.strikeout, stiText.font.sizeInPoints, stiText.font.name, StiBrush.toColor(stiText.textBrush), StiBrush.toColor(stiText.brush), false, false, 0, 0, stiText.lineSpacing, stiText.horAlignment);
                    var baseState = new StiHtmlState(baseTagsState, 0);
                    var statesList = Stimulsoft.Base.Drawing.StiTextRenderer.parseHtmlToStates(inputText, baseState);
                    //#endregion
                    var styleIndex = this.getStyleFromComponent(cell.component);
                    this.writeParagraphBegin(writer, cell, styleIndex, statesList, 0);
                    for (var index = 0; index < statesList.length; index++) {
                        var htmlState = statesList[index];
                        var state = htmlState.ts;
                        if ((htmlState.text.toString() == "\n") && (index < statesList.countItems - 1)) {
                            writer.writeEndElement(); // w:p
                            this.writeParagraphBegin(writer, cell, styleIndex, statesList, index + 1);
                            continue;
                        }
                        writer.writeStartElement("w:r");
                        writer.writeStartElement("w:rPr");
                        if (state.bold) {
                            writer.writeStartElement("w:b");
                            writer.writeEndElement();
                        }
                        if (state.italic) {
                            writer.writeStartElement("w:i");
                            writer.writeEndElement();
                        }
                        if (state.underline) {
                            writer.writeStartElement("w:u");
                            writer.writeAttributeString("w:val", "single");
                            writer.writeEndElement();
                        }
                        if (state.strikeout) {
                            writer.writeStartElement("w:strike");
                            writer.writeEndElement();
                        }
                        if (state.superscript) {
                            writer.writeStartElement("w:vertAlign");
                            writer.writeAttributeString("w:val", "superscript");
                            writer.writeEndElement();
                        }
                        if (state.subsript) {
                            writer.writeStartElement("w:vertAlign");
                            writer.writeAttributeString("w:val", "subscript");
                            writer.writeEndElement();
                        }
                        if (state.fontColor.toArgb() != baseTagsState.fontColor.toArgb()) {
                            writer.writeStartElement("w:color");
                            writer.writeAttributeString("w:val", this.getColorString(state.fontColor));
                            writer.writeEndElement();
                        }
                        if (state.backColor.toArgb() != baseTagsState.backColor.toArgb()) {
                            writer.writeStartElement("w:shd");
                            writer.writeAttributeString("w:val", "clear");
                            writer.writeAttributeString("w:color", "auto");
                            writer.writeAttributeString("w:fill", this.getColorString(state.backColor));
                            writer.writeEndElement();
                        }
                        // if (state.FontSize != baseTagsState.FontSize)
                        // {
                        writer.writeStartElement("w:sz");
                        writer.writeAttributeString("w:val", (state.fontSize * 2).toString());
                        writer.writeEndElement();
                        writer.writeStartElement("w:szCs");
                        writer.writeAttributeString("w:val", (state.fontSize * 2).toString());
                        writer.writeEndElement();
                        // }
                        // if (state.FontName != baseTagsState.FontName)
                        // {
                        writer.writeStartElement("w:rFonts");
                        var fontName = state.fontName;
                        this.fontList.set(fontName, fontName);
                        writer.writeAttributeString("w:ascii", fontName);
                        writer.writeAttributeString("w:hAnsi", fontName);
                        writer.writeAttributeString("w:eastAsia", fontName);
                        writer.writeAttributeString("w:cs", fontName);
                        writer.writeEndElement();
                        // }
                        // if (state.WordSpacing != baseTagsState.WordSpacing)
                        // {
                        //    fontStyle.Append(string.Format("word-spacing:{0}em;", state.WordSpacing).Replace(",", "."));
                        // }
                        var letterSpacing = state.letterSpacing * state.fontSize * 18.8 + StiOptions.Export.Word.spaceBetweenCharacters;
                        if (letterSpacing != 0) {
                            writer.writeStartElement("w:spacing");
                            writer.writeAttributeString("w:val", letterSpacing.toString());
                            writer.writeEndElement();
                        }
                        if (cell.cellStyle.textOptions != null && cell.cellStyle.textOptions.rightToLeft) {
                            // if (cell.CellStyle.Font.Bold)
                            // {
                            //    writer.writeStartElement("w:bCs");
                            //    writer.writeEndElement();
                            // }
                            // if (cell.CellStyle.Font.Italic)
                            // {
                            //    writer.writeStartElement("w:iCs");
                            //    writer.writeEndElement();
                            // }
                            // writer.writeStartElement("w:szCs");
                            // writer.writeAttributeString("w:val", string.Format("{0}", cell.CellStyle.Font.SizeInPoints * 2));
                            // writer.writeEndElement();
                            writer.writeStartElement("w:rtl");
                            writer.writeEndElement();
                        }
                        writer.writeEndElement(); // w:rPr
                        writer.writeStartElement("w:t");
                        writer.writeAttributeString("xml:space", "preserve");
                        writer.writeString(Stimulsoft.Base.Drawing.StiTextRenderer.prepareStateText(htmlState.text).toString());
                        writer.writeEndElement();
                        writer.writeEndElement(); // w:r
                    }
                    writer.writeEndElement(); // w:p
                };
                StiWord2007ExportService.prototype.writeParagraphBegin = function (writer, cell, styleIndex, states, stateIndex) {
                    writer.writeStartElement("w:p");
                    // paragraph properties
                    writer.writeStartElement("w:pPr");
                    if (styleIndex != -1) {
                        writer.writeStartElement("w:pStyle");
                        writer.writeAttributeString("w:val", StiString.format("Style{0}", styleIndex));
                        writer.writeEndElement();
                    }
                    else {
                        this.writeRunProperties(writer, cell);
                    }
                    // Find last state in current paragraph
                    var lastState = states[stateIndex];
                    if (lastState.text.toString() != "\n") {
                        var indexS = stateIndex + 1;
                        while ((indexS < states.length) && (states[indexS].text.toString() != "\n")) {
                            lastState = states[indexS];
                            indexS++;
                        }
                    }
                    // LineHeight
                    var lineSpacing = StiOptions.Export.Word.lineSpacing * lastState.ts.lineHeight;
                    if (this.checkFontsToCorrectHeight(lastState.ts.fontName)) {
                        lineSpacing *= 0.772;
                    }
                    if (lineSpacing != 1) {
                        writer.writeStartElement("w:spacing");
                        writer.writeAttributeString("w:line", (Math.round2(lineSpacing * 240)).toString());
                        writer.writeEndElement();
                    }
                    // Horizontal align
                    var stHorAlignment = null;
                    if (lastState.ts.textAlign == StiTextHorAlignment.Center)
                        stHorAlignment = "center";
                    if (lastState.ts.textAlign == StiTextHorAlignment.Right)
                        stHorAlignment = "right";
                    if (lastState.ts.textAlign == StiTextHorAlignment.Width)
                        stHorAlignment = "both";
                    if (stHorAlignment != null) {
                        writer.writeStartElement("w:jc");
                        writer.writeAttributeString("w:val", stHorAlignment);
                        writer.writeEndElement();
                    }
                    writer.writeEndElement(); // w:pPr
                };
                StiWord2007ExportService.prototype.writeRunProperties = function (writer, cell) {
                    // run properties
                    writer.writeStartElement("w:rPr");
                    writer.writeStartElement("w:rFonts");
                    var fontName = cell.cellStyle.font.name;
                    this.fontList.set(fontName, fontName);
                    writer.writeAttributeString("w:ascii", fontName);
                    writer.writeAttributeString("w:hAnsi", fontName);
                    writer.writeAttributeString("w:eastAsia", fontName);
                    writer.writeAttributeString("w:cs", fontName);
                    writer.writeEndElement();
                    if (cell.cellStyle.font.bold) {
                        writer.writeStartElement("w:b");
                        writer.writeEndElement();
                    }
                    if (cell.cellStyle.font.italic) {
                        writer.writeStartElement("w:i");
                        writer.writeEndElement();
                    }
                    if (cell.cellStyle.font.underline) {
                        writer.writeStartElement("w:u");
                        writer.writeAttributeString("w:val", "single");
                        writer.writeEndElement();
                    }
                    writer.writeStartElement("w:color");
                    writer.writeAttributeString("w:val", this.getColorString(cell.cellStyle.textColor));
                    writer.writeEndElement();
                    writer.writeStartElement("w:sz");
                    writer.writeAttributeString("w:val", StiString.format("{0}", cell.cellStyle.font.sizeInPoints * 2));
                    writer.writeEndElement();
                    if (StiOptions.Export.Word.spaceBetweenCharacters != 0) {
                        writer.writeStartElement("w:spacing");
                        writer.writeAttributeString("w:val", StiString.format("{0}", StiOptions.Export.Word.spaceBetweenCharacters));
                        writer.writeEndElement();
                    }
                    if (cell.cellStyle.textOptions != null && cell.cellStyle.textOptions.rightToLeft) {
                        if (cell.cellStyle.font.bold) {
                            writer.writeStartElement("w:bCs");
                            writer.writeEndElement();
                        }
                        if (cell.cellStyle.font.italic) {
                            writer.writeStartElement("w:iCs");
                            writer.writeEndElement();
                        }
                        writer.writeStartElement("w:szCs");
                        writer.writeAttributeString("w:val", StiString.format("{0}", cell.cellStyle.font.sizeInPoints * 2));
                        writer.writeEndElement();
                        writer.writeStartElement("w:rtl");
                        writer.writeEndElement();
                    }
                    writer.writeEndElement();
                };
                StiWord2007ExportService.prototype.renderBorder2TableGetValues = function (rowIndex, columnIndex, REFstyles) {
                    var styles = REFstyles.ref;
                    var sides = StiBorderSides.None;
                    var sb = new StringBuilder();
                    if (this.matrix.bordersY[rowIndex - 1][columnIndex - 1] != null) {
                        sides |= StiBorderSides.Left;
                    }
                    if (this.matrix.bordersY[rowIndex - 1][columnIndex - 1 + 1] != null) {
                        sides |= StiBorderSides.Right;
                    }
                    if (this.matrix.bordersX[rowIndex - 1][columnIndex - 1] != null) {
                        sb.append("\\t" + this.getLineStyle2TableGetValues(this.matrix.bordersX[rowIndex - 1][columnIndex - 1]));
                        sides |= StiBorderSides.Top;
                    }
                    if (this.matrix.bordersX[rowIndex - 1 + 1][columnIndex - 1] != null) {
                        sb.append("\\b" + this.getLineStyle2TableGetValues(this.matrix.bordersX[rowIndex - 1 + 1][columnIndex - 1]));
                        sides |= StiBorderSides.Bottom;
                    }
                    styles = sb.toString();
                    REFstyles.ref = styles;
                    return sides;
                };
                StiWord2007ExportService.prototype.getLineStyle2TableGetValues = function (border) {
                    var sb = new StringBuilder();
                    sb.append(this.getLineStyle(border.style));
                    sb.append(Math.trunc(border.size * 15));
                    sb.append(StiString.format("c{0}", this.getColorString(border.color)));
                    return sb.toString();
                };
                StiWord2007ExportService.prototype.writeDocument = function (pages, report, outHeadersAndFooters) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:document");
                    writer.writeAttributeString("xmlns:ve", "http://schemas.openxmlformats.org/markup-compatibility/2006");
                    writer.writeAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:m", "http://schemas.openxmlformats.org/officeDocument/2006/math");
                    writer.writeAttributeString("xmlns:v", "urn:schemas-microsoft-com:vml");
                    writer.writeAttributeString("xmlns:wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing");
                    writer.writeAttributeString("xmlns:w10", "urn:schemas-microsoft-com:office:word");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeAttributeString("xmlns:wne", "http://schemas.microsoft.com/office/word/2006/wordml");
                    writer.writeStartElement("w:body");
                    var allPages = pages;
                    pages = null;
                    var indexPage = 0;
                    var partIndex = 0;
                    while (indexPage < allPages.count) {
                        pages = new StiPagesCollection(report, allPages);
                        pages.cacheMode = report.renderedPages.cacheMode;
                        pages.addV2Internal(allPages.getPageWithoutCache(indexPage));
                        var sheetName = allPages.getPageWithoutCache(indexPage).excelSheetValue;
                        while ((indexPage < allPages.count - 1) && this.compareExcellSheetNames(allPages.getPageWithoutCache(indexPage + 1).excelSheetValue, sheetName) &&
                            (allPages.getPageWithoutCache(indexPage + 1).orientation == allPages.getPageWithoutCache(indexPage).orientation)) {
                            indexPage++;
                            pages.addV2Internal(allPages.getPageWithoutCache(indexPage));
                        }
                        var firstPage = pages.getByIndex(0);
                        if (firstPage != null) {
                            pages.getPage(firstPage);
                            if (this.usePageHeadersAndFooters) {
                                // write header and footer
                                var pages2 = new StiPagesCollection(report, report.renderedPages);
                                pages2.cacheMode = report.renderedPages.cacheMode;
                                pages2.add(pages.getByIndex(0));
                                this._matrix = new Export.StiMatrix(pages2, StiOptions.Export.Word.divideBigCells, this);
                                // if (IsStoped) return null;
                                this.matrix.scanComponentsPlacement(false);
                                var startLine = 0;
                                var endLine = 0;
                                var needHeader = false;
                                endLine = (this.matrix.coordY.countItems - 1) - 1;
                                while ((endLine > 0) && (this.matrix.linePlacement[endLine] != Export.StiTableLineInfo.PageHeader))
                                    endLine--;
                                if (endLine >= 0 && this.matrix.linePlacement[endLine] == Export.StiTableLineInfo.PageHeader) {
                                    startLine = 0;
                                    while (this.matrix.linePlacement[startLine] != Export.StiTableLineInfo.PageHeader)
                                        startLine++;
                                    needHeader = true;
                                }
                                this.headersData.add(this.writeHeader(startLine, endLine, needHeader));
                                if (this.imageCache.imagePackedStore.length > 0) {
                                    this.headersRels.add(this.writeHeaderFooterRels());
                                }
                                else
                                    this.headersRels.add(null);
                                var needFooter = false;
                                startLine = 0;
                                while ((this.matrix.linePlacement[startLine] != Export.StiTableLineInfo.PageFooter) && (startLine < (this.matrix.coordY.countItems - 1) - 1))
                                    startLine++;
                                if (this.matrix.linePlacement[startLine] == Export.StiTableLineInfo.PageFooter) {
                                    endLine = (this.matrix.coordY.countItems - 1) - 1;
                                    while (this.matrix.linePlacement[endLine] != Export.StiTableLineInfo.PageFooter)
                                        endLine--;
                                    needFooter = true;
                                }
                                this.footersData.add(this.writeFooter(startLine, endLine, needFooter));
                                if (this.imageCache.imagePackedStore.length > 0) {
                                    this.footersRels.add(this.writeHeaderFooterRels());
                                }
                                else
                                    this.footersRels.add(null);
                                this._matrix = new Export.StiMatrix(pages, StiOptions.Export.Word.divideBigCells, this);
                                this.matrix.scanComponentsPlacement(true);
                                endLine = (this.matrix.coordY.countItems - 1) - 1;
                                this.writeFromMatrix(writer, 0, endLine, false);
                            }
                            else {
                                this._matrix = new Export.StiMatrix(pages, StiOptions.Export.Word.divideBigCells, this);
                                // if (IsStoped) return null;
                                this.writeFromMatrix(writer, 0, (this.matrix.coordY.countItems - 1) - 1, true);
                            }
                            if (indexPage < allPages.count - 1) {
                                writer.writeStartElement("w:p");
                                writer.writeStartElement("w:pPr");
                                this.writePageInfo(writer, pages.getByIndex(0), partIndex);
                                writer.writeEndElement();
                                writer.writeEndElement();
                            }
                        }
                        indexPage++;
                        partIndex++;
                    }
                    if (pages.count > 0) {
                        this.writePageInfo(writer, pages.getByIndex(0), partIndex - 1);
                    }
                    writer.writeFullEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.compareExcellSheetNames = function (name1, name2) {
                    var st1 = name1;
                    if (StiString.isNullOrEmpty(st1))
                        st1 = "";
                    var st2 = name2;
                    if (StiString.isNullOrEmpty(st2))
                        st2 = "";
                    return (st1 == st2);
                };
                StiWord2007ExportService.prototype.writePageInfo = function (writer, page, partIndex) {
                    var pageHeight = this.convertHiToTwips(page.unit.convertToHInches(page.pageHeight * (this.usePageHeadersAndFooters ? 1 : page.segmentPerHeight)));
                    var pageWidth = this.convertHiToTwips(page.unit.convertToHInches(page.pageWidth * (this.usePageHeadersAndFooters ? 1 : page.segmentPerWidth)));
                    var mgLeft = this.convertHiToTwips(page.unit.convertToHInches(page.margins.left));
                    var mgRight = this.convertHiToTwips(page.unit.convertToHInches(page.margins.right));
                    var mgTop = this.convertHiToTwips(page.unit.convertToHInches(page.margins.top));
                    var mgBottom = this.convertHiToTwips(page.unit.convertToHInches(page.margins.bottom)) - StiOptions.Export.Word.bottomMarginCorrection;
                    if (mgBottom < 0)
                        mgBottom = 0;
                    if (pageWidth > 31500)
                        pageWidth = 31500;
                    if (pageHeight > 31500)
                        pageHeight = 31500;
                    writer.writeStartElement("w:sectPr");
                    if (this.usePageHeadersAndFooters) {
                        writer.writeStartElement("w:headerReference");
                        writer.writeAttributeString("w:type", "default");
                        writer.writeAttributeString("r:id", StiString.format("rIdh{0}", partIndex + 1));
                        writer.writeEndElement();
                        writer.writeStartElement("w:footerReference");
                        writer.writeAttributeString("w:type", "default");
                        writer.writeAttributeString("r:id", StiString.format("rIdf{0}", partIndex + 1));
                        writer.writeEndElement();
                    }
                    // *#if Demo
                    else if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        writer.writeStartElement("w:headerReference");
                        writer.writeAttributeString("w:type", "default");
                        writer.writeAttributeString("r:id", "rIdh1");
                        writer.writeEndElement();
                    }
                    // #endif Demo*/
                    // #if SERVER
                    //    else if (StiVersionX.IsSvr) {
                    //    writer.writeStartElement("w:headerReference");
                    //    writer.writeAttributeString("w:type", "default");
                    //    writer.writeAttributeString("r:id", "rIdh1");
                    //    writer.writeEndElement();
                    // }
                    // #endif
                    writer.writeStartElement("w:pgSz");
                    writer.writeAttributeString("w:w", StiString.format("{0}", pageWidth));
                    writer.writeAttributeString("w:h", StiString.format("{0}", pageHeight));
                    if (page.orientation == StiPageOrientation.Landscape) {
                        writer.writeAttributeString("w:orient", "landscape");
                    }
                    writer.writeEndElement();
                    writer.writeStartElement("w:pgMar");
                    writer.writeAttributeString("w:top", StiString.format("{0}", mgTop));
                    writer.writeAttributeString("w:right", StiString.format("{0}", mgRight));
                    writer.writeAttributeString("w:bottom", StiString.format("{0}", mgBottom));
                    writer.writeAttributeString("w:left", StiString.format("{0}", mgLeft));
                    writer.writeAttributeString("w:header", StiString.format("{0}", mgTop));
                    writer.writeAttributeString("w:footer", StiString.format("{0}", mgBottom));
                    writer.writeAttributeString("w:gutter", "0");
                    writer.writeEndElement();
                    writer.writeEndElement();
                };
                StiWord2007ExportService.prototype.writeBorders = function (writer, indexRow, indexColumn, height, width) {
                    var needBorderLeft = true;
                    var needBorderRight = true;
                    for (var index = 0; index < height; index++) {
                        if (this.matrix.bordersY[indexRow + index][indexColumn] == null)
                            needBorderLeft = false;
                        if (this.matrix.bordersY[indexRow + index][indexColumn + width] == null)
                            needBorderRight = false;
                    }
                    var needBorderTop = true;
                    var needBorderBottom = true;
                    for (var index = 0; index < width; index++) {
                        if (this.matrix.bordersX[indexRow][indexColumn + index] == null)
                            needBorderTop = false;
                        if (this.matrix.bordersX[indexRow + height][indexColumn + index] == null)
                            needBorderBottom = false;
                    }
                    if (needBorderTop || needBorderLeft || needBorderBottom || needBorderRight) {
                        writer.writeStartElement("w:tcBorders");
                        if (needBorderTop)
                            this.writeBorderData(writer, "w:top", this.matrix.bordersX[indexRow][indexColumn]);
                        if (needBorderLeft)
                            this.writeBorderData(writer, "w:left", this.matrix.bordersY[indexRow][indexColumn]);
                        if (needBorderBottom)
                            this.writeBorderData(writer, "w:bottom", this.matrix.bordersX[indexRow + height][indexColumn]);
                        if (needBorderRight)
                            this.writeBorderData(writer, "w:right", this.matrix.bordersY[indexRow][indexColumn + width]);
                        writer.writeEndElement();
                    }
                };
                StiWord2007ExportService.prototype.writeBorderData = function (writer, side, border) {
                    if (border != null) {
                        var style = this.getLineStyle(border.style);
                        if (style != "") {
                            writer.writeStartElement(side);
                            writer.writeAttributeString("w:val", style);
                            writer.writeAttributeString("w:sz", StiString.format("{0}", Math.trunc(border.size * 5)));
                            writer.writeAttributeString("w:space", "0");
                            writer.writeAttributeString("w:color", this.getColorString(border.color));
                            writer.writeEndElement();
                        }
                    }
                };
                StiWord2007ExportService.prototype.writeFootNotes = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:footnotes");
                    writer.writeAttributeString("xmlns:ve", "http://schemas.openxmlformats.org/markup-compatibility/2006");
                    writer.writeAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:m", "http://schemas.openxmlformats.org/officeDocument/2006/math");
                    writer.writeAttributeString("xmlns:v", "urn:schemas-microsoft-com:vml");
                    writer.writeAttributeString("xmlns:wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing");
                    writer.writeAttributeString("xmlns:w10", "urn:schemas-microsoft-com:office:word");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeAttributeString("xmlns:wne", "http://schemas.microsoft.com/office/word/2006/wordml");
                    writer.writeStartElement("w:footnote");
                    writer.writeAttributeString("w:type", "separator");
                    writer.writeAttributeString("w:id", "0");
                    writer.writeStartElement("w:p");
                    writer.writeStartElement("w:r");
                    writer.writeStartElement("w:separator");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeStartElement("w:footnote");
                    writer.writeAttributeString("w:type", "continuationSeparator");
                    writer.writeAttributeString("w:id", "1");
                    writer.writeStartElement("w:p");
                    writer.writeStartElement("w:r");
                    writer.writeStartElement("w:continuationSeparator");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeFullEndElement(); // footnotes
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeEndNotes = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:endnotes");
                    writer.writeAttributeString("xmlns:ve", "http://schemas.openxmlformats.org/markup-compatibility/2006");
                    writer.writeAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:m", "http://schemas.openxmlformats.org/officeDocument/2006/math");
                    writer.writeAttributeString("xmlns:v", "urn:schemas-microsoft-com:vml");
                    writer.writeAttributeString("xmlns:wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing");
                    writer.writeAttributeString("xmlns:w10", "urn:schemas-microsoft-com:office:word");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeAttributeString("xmlns:wne", "http://schemas.microsoft.com/office/word/2006/wordml");
                    writer.writeStartElement("w:endnote");
                    writer.writeAttributeString("w:type", "separator");
                    writer.writeAttributeString("w:id", "0");
                    writer.writeStartElement("w:p");
                    writer.writeStartElement("w:r");
                    writer.writeStartElement("w:separator");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeStartElement("w:endnote");
                    writer.writeAttributeString("w:type", "continuationSeparator");
                    writer.writeAttributeString("w:id", "1");
                    writer.writeStartElement("w:p");
                    writer.writeStartElement("w:r");
                    writer.writeStartElement("w:continuationSeparator");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeFullEndElement(); // endnotes
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeHeader = function (startLine, endLine, needHeader) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:hdr");
                    writer.writeAttributeString("xmlns:ve", "http://schemas.openxmlformats.org/markup-compatibility/2006");
                    writer.writeAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:m", "http://schemas.openxmlformats.org/officeDocument/2006/math");
                    writer.writeAttributeString("xmlns:v", "urn:schemas-microsoft-com:vml");
                    writer.writeAttributeString("xmlns:wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing");
                    writer.writeAttributeString("xmlns:w10", "urn:schemas-microsoft-com:office:word");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeAttributeString("xmlns:wne", "http://schemas.microsoft.com/office/word/2006/wordml");
                    if (needHeader) {
                        this.writeFromMatrix(writer, startLine, endLine, true);
                    }
                    else {
                        writer.writeStartElement("w:p");
                        writer.writeStartElement("w:r");
                        writer.writeStartElement("w:cr");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement(); // hdr
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeFooter = function (startLine, endLine, needFooter) {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:ftr");
                    writer.writeAttributeString("xmlns:ve", "http://schemas.openxmlformats.org/markup-compatibility/2006");
                    writer.writeAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:m", "http://schemas.openxmlformats.org/officeDocument/2006/math");
                    writer.writeAttributeString("xmlns:v", "urn:schemas-microsoft-com:vml");
                    writer.writeAttributeString("xmlns:wp", "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing");
                    writer.writeAttributeString("xmlns:w10", "urn:schemas-microsoft-com:office:word");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeAttributeString("xmlns:wne", "http://schemas.microsoft.com/office/word/2006/wordml");
                    if (needFooter) {
                        this.writeFromMatrix(writer, startLine, endLine, true);
                    }
                    else {
                        writer.writeStartElement("w:p");
                        writer.writeStartElement("w:r");
                        writer.writeStartElement("w:cr");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement(); // ftr
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeContentTypes = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Types");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/content-types");
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "rels");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-package.relationships+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "xml");
                    writer.writeAttributeString("ContentType", "application/xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "jpeg");
                    writer.writeAttributeString("ContentType", "image/jpeg");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "emf");
                    writer.writeAttributeString("ContentType", "image/x-emf");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "rtf");
                    writer.writeAttributeString("ContentType", "application/rtf");
                    writer.writeEndElement();
                    writer.writeStartElement("Default");
                    writer.writeAttributeString("Extension", "png");
                    writer.writeAttributeString("ContentType", "image/png");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/docProps/app.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.extended-properties+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/docProps/core.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-package.core-properties+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/word/document.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/word/styles.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/word/settings.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.settings+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/word/webSettings.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.webSettings+xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Override");
                    writer.writeAttributeString("PartName", "/word/fontTable.xml");
                    writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.fontTable+xml");
                    writer.writeEndElement();
                    if (this.usePageHeadersAndFooters) {
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", "/word/footnotes.xml");
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml");
                        writer.writeEndElement();
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", "/word/endnotes.xml");
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml");
                        writer.writeEndElement();
                        for (var index = 0; index < this.headersData.length; index++) {
                            writer.writeStartElement("Override");
                            writer.writeAttributeString("PartName", StiString.format("/word/footer{0}.xml", index + 1));
                            writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.footer+xml");
                            writer.writeEndElement();
                            writer.writeStartElement("Override");
                            writer.writeAttributeString("PartName", StiString.format("/word/header{0}.xml", index + 1));
                            writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml");
                            writer.writeEndElement();
                        }
                    }
                    // *#if Demo
                    else if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", "/word/footnotes.xml");
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.footnotes+xml");
                        writer.writeEndElement();
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", "/word/endnotes.xml");
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.endnotes+xml");
                        writer.writeEndElement();
                        writer.writeStartElement("Override");
                        writer.writeAttributeString("PartName", "/word/headerAdditional.xml");
                        writer.writeAttributeString("ContentType", "application/vnd.openxmlformats-officedocument.wordprocessingml.header+xml");
                        writer.writeEndElement();
                    }
                    // #endif Demo*/
                    // #if SERVER
                    //    else if (StiVersionX.IsSvr) {
                    //    writer.writeStartElement("w:headerReference");
                    //    writer.writeAttributeString("w:type", "default");
                    //    writer.writeAttributeString("r:id", "rIdh1");
                    //    writer.writeEndElement();
                    // }
                    // #endif
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeMainRels = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId1");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument");
                    writer.writeAttributeString("Target", "word/document.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId2");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties");
                    writer.writeAttributeString("Target", "docProps/core.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId3");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties");
                    writer.writeAttributeString("Target", "docProps/app.xml");
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeDocPropsApp = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Properties");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/officeDocument/2006/extended-properties");
                    writer.writeAttributeString("xmlns:vt", "http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes");
                    writer.writeElementString("Application", "Microsoft Office Word");
                    writer.writeElementString("Company", this.docCompanyString == null ? "" : this.docCompanyString);
                    writer.writeElementString("Template", "Normal.dotm");
                    writer.writeElementString("TotalTime", "0");
                    writer.writeElementString("Pages", "1");
                    writer.writeElementString("Words", "1");
                    writer.writeElementString("Characters", "1");
                    writer.writeElementString("DocSecurity", this.restrictEditing == Export.StiWord2007RestrictEditing.No ? "0" : "8");
                    writer.writeElementString("Lines", "1");
                    writer.writeElementString("Paragraphs", "1");
                    writer.writeElementString("ScaleCrop", "false");
                    writer.writeElementString("LinksUpToDate", "false");
                    writer.writeElementString("CharactersWithSpaces", "1");
                    writer.writeElementString("SharedDoc", "false");
                    writer.writeElementString("HyperlinksChanged", "false");
                    writer.writeElementString("AppVersion", "12.0000");
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeDocPropsCore = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("cp:coreProperties");
                    writer.writeAttributeString("xmlns:cp", "http://schemas.openxmlformats.org/package/2006/metadata/core-properties");
                    writer.writeAttributeString("xmlns:dc", "http://purl.org/dc/elements/1.1/");
                    writer.writeAttributeString("xmlns:dcterms", "http://purl.org/dc/terms/");
                    writer.writeAttributeString("xmlns:dcmitype", "http://purl.org/dc/dcmitype/");
                    writer.writeAttributeString("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
                    var dateTime = StiString.format("{0}{1}", DateTime.now.toString("yyyy-MM-dd"), DateTime.now.toString("THH:mm:ssZ"));
                    writer.writeElementString("dc:title", this.report.reportName == null ? "" : this.report.reportName);
                    writer.writeElementString("dc:subject", this.report.reportAlias == null ? "" : this.report.reportAlias);
                    writer.writeElementString("dc:creator", this.report.reportAuthor == null ? "" : this.report.reportAuthor);
                    writer.writeElementString("cp:keywords", "");
                    writer.writeElementString("dc:description", this.report.reportDescription == null ? "" : this.report.reportDescription);
                    writer.writeElementString("cp:lastModifiedBy", this.docLastModifiedString == null ? "" : this.docLastModifiedString);
                    writer.writeElementString("cp:revision", "1");
                    writer.writeStartElement("dcterms:created");
                    writer.writeAttributeString("xsi:type", "dcterms:W3CDTF");
                    writer.writeString(dateTime);
                    writer.writeEndElement();
                    writer.writeStartElement("dcterms:modified");
                    writer.writeAttributeString("xsi:type", "dcterms:W3CDTF");
                    writer.writeString(dateTime);
                    writer.writeEndElement();
                    writer.writeElementString("cp:contentStatus", Stimulsoft.StiVersion.platform());
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeSettings = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:settings");
                    writer.writeAttributeString("xmlns:o", "urn:schemas-microsoft-com:office:office");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:m", "http://schemas.openxmlformats.org/officeDocument/2006/math");
                    writer.writeAttributeString("xmlns:v", "urn:schemas-microsoft-com:vml");
                    writer.writeAttributeString("xmlns:w10", "urn:schemas-microsoft-com:office:word");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeAttributeString("xmlns:sl", "http://schemas.openxmlformats.org/schemaLibrary/2006/main");
                    if (this.restrictEditing != Export.StiWord2007RestrictEditing.No) {
                        writer.writeStartElement("w:documentProtection");
                        writer.writeAttributeString("w:edit", "readOnly");
                        writer.writeAttributeString("w:enforcement", "1");
                        writer.writeAttributeString("w:cryptProviderType", "rsaFull");
                        writer.writeAttributeString("w:cryptAlgorithmClass", "hash");
                        writer.writeAttributeString("w:cryptAlgorithmType", "typeAny");
                        writer.writeAttributeString("w:cryptAlgorithmSid", "4");
                        writer.writeAttributeString("w:cryptSpinCount", "50000");
                        writer.writeAttributeString("w:hash", "aw5VYrxGrQVOl7/SJDI9GvbcwaE="); // *TestPassword*
                        writer.writeAttributeString("w:salt", "974T1u8C/8p0OAB+3ev3nQ==");
                        writer.writeEndElement();
                    }
                    writer.writeStartElement("w:zoom");
                    writer.writeAttributeString("w:percent", "100");
                    writer.writeEndElement();
                    writer.writeStartElement("w:proofState");
                    writer.writeAttributeString("w:spelling", "clean");
                    writer.writeAttributeString("w:grammar", "clean");
                    writer.writeEndElement();
                    writer.writeStartElement("w:defaultTabStop");
                    writer.writeAttributeString("w:val", "708");
                    writer.writeEndElement();
                    writer.writeStartElement("w:characterSpacingControl");
                    writer.writeAttributeString("w:val", "doNotCompress");
                    writer.writeEndElement();
                    if (this.usePageHeadersAndFooters) {
                        writer.writeStartElement("w:footnotePr");
                        writer.writeStartElement("w:footnote");
                        writer.writeAttributeString("w:id", "0");
                        writer.writeEndElement();
                        writer.writeStartElement("w:footnote");
                        writer.writeAttributeString("w:id", "1");
                        writer.writeEndElement();
                        writer.writeEndElement();
                        writer.writeStartElement("w:endnotePr");
                        writer.writeStartElement("w:endnote");
                        writer.writeAttributeString("w:id", "0");
                        writer.writeEndElement();
                        writer.writeStartElement("w:endnote");
                        writer.writeAttributeString("w:id", "1");
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    writer.writeStartElement("w:compat");
                    writer.writeEndElement();
                    writer.writeStartElement("m:mathPr");
                    writer.writeStartElement("m:mathFont");
                    writer.writeAttributeString("m:val", "Cambria Math");
                    writer.writeEndElement();
                    writer.writeStartElement("m:brkBin");
                    writer.writeAttributeString("m:val", "before");
                    writer.writeEndElement();
                    writer.writeStartElement("m:brkBinSub");
                    writer.writeAttributeString("m:val", "--");
                    writer.writeEndElement();
                    writer.writeStartElement("m:smallFrac");
                    writer.writeAttributeString("m:val", "off");
                    writer.writeEndElement();
                    writer.writeStartElement("m:dispDef");
                    writer.writeEndElement();
                    writer.writeStartElement("m:lMargin");
                    writer.writeAttributeString("m:val", "0");
                    writer.writeEndElement();
                    writer.writeStartElement("m:rMargin");
                    writer.writeAttributeString("m:val", "0");
                    writer.writeEndElement();
                    writer.writeStartElement("m:defJc");
                    writer.writeAttributeString("m:val", "centerGroup");
                    writer.writeEndElement();
                    writer.writeStartElement("m:wrapIndent");
                    writer.writeAttributeString("m:val", "1440");
                    writer.writeEndElement();
                    writer.writeStartElement("m:intLim");
                    writer.writeAttributeString("m:val", "subSup");
                    writer.writeEndElement();
                    writer.writeStartElement("m:naryLim");
                    writer.writeAttributeString("m:val", "undOvr");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:themeFontLang");
                    writer.writeAttributeString("w:val", "en-EN");
                    writer.writeEndElement();
                    writer.writeStartElement("w:clrSchemeMapping");
                    writer.writeAttributeString("w:bg1", "light1");
                    writer.writeAttributeString("w:t1", "dark1");
                    writer.writeAttributeString("w:bg2", "light2");
                    writer.writeAttributeString("w:t2", "dark2");
                    writer.writeAttributeString("w:accent1", "accent1");
                    writer.writeAttributeString("w:accent2", "accent2");
                    writer.writeAttributeString("w:accent3", "accent3");
                    writer.writeAttributeString("w:accent4", "accent4");
                    writer.writeAttributeString("w:accent5", "accent5");
                    writer.writeAttributeString("w:accent6", "accent6");
                    writer.writeAttributeString("w:hyperlink", "hyperlink");
                    writer.writeAttributeString("w:followedHyperlink", "followedHyperlink");
                    writer.writeEndElement();
                    writer.writeStartElement("w:shapeDefaults");
                    writer.writeStartElement("o:shapedefaults");
                    writer.writeAttributeString("v:ext", "edit");
                    writer.writeAttributeString("spidmax", "2050");
                    writer.writeEndElement();
                    writer.writeStartElement("o:shapelayout");
                    writer.writeAttributeString("v:ext", "edit");
                    writer.writeStartElement("o:idmap");
                    writer.writeAttributeString("v:ext", "edit");
                    writer.writeAttributeString("data", "1");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:decimalSymbol");
                    writer.writeAttributeString("w:val", ",");
                    writer.writeEndElement();
                    writer.writeStartElement("w:listSeparator");
                    writer.writeAttributeString("w:val", ";");
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeWebSettings = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:webSettings");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeStartElement("w:optimizeForBrowser");
                    writer.writeEndElement();
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeFontTable = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:fonts");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    this.fontList.set("Calibri", "Calibri");
                    this.fontList.set("Cambria", "Cambria");
                    for (var _i = 0, _a = this.fontList.values; _i < _a.length; _i++) {
                        var fontName = _a[_i];
                        writer.writeStartElement("w:font");
                        writer.writeAttributeString("w:name", fontName);
                        writer.writeFullEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeDocumentRels = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId1");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles");
                    writer.writeAttributeString("Target", "styles.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId2");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/settings");
                    writer.writeAttributeString("Target", "settings.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId3");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/webSettings");
                    writer.writeAttributeString("Target", "webSettings.xml");
                    writer.writeEndElement();
                    writer.writeStartElement("Relationship");
                    writer.writeAttributeString("Id", "rId4");
                    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/fontTable");
                    writer.writeAttributeString("Target", "fontTable.xml");
                    writer.writeEndElement();
                    for (var index = 0; index < this.imageCache.imagePackedStore.length; index++) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + index));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image");
                        writer.writeAttributeString("Target", StiString.format("media/image{0:D5}.jpeg", index + 1));
                        writer.writeEndElement();
                    }
                    if (this.usePageHeadersAndFooters) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + this.imageCache.imagePackedStore.length + 0));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes");
                        writer.writeAttributeString("Target", "footnotes.xml");
                        writer.writeEndElement();
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + this.imageCache.imagePackedStore.length + 1));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes");
                        writer.writeAttributeString("Target", "endnotes.xml");
                        writer.writeEndElement();
                        for (var index = 0; index < this.headersData.length; index++) {
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", StiString.format("rIdh{0}", index + 1));
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header");
                            writer.writeAttributeString("Target", StiString.format("header{0}.xml", index + 1));
                            writer.writeEndElement();
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", StiString.format("rIdf{0}", index + 1));
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footer");
                            writer.writeAttributeString("Target", StiString.format("footer{0}.xml", index + 1));
                            writer.writeEndElement();
                        }
                    }
                    // *#if Demo
                    else if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() &&
                        !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + this.imageCache.imagePackedStore.length + 0));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes");
                        writer.writeAttributeString("Target", "footnotes.xml");
                        writer.writeEndElement();
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + this.imageCache.imagePackedStore.length + 1));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes");
                        writer.writeAttributeString("Target", "endnotes.xml");
                        writer.writeEndElement();
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", "rIdh1");
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header");
                        writer.writeAttributeString("Target", "headerAdditional.xml");
                        writer.writeEndElement();
                    }
                    // #endif Demo*/
                    // #if SERVER
                    //    else if (StiVersionX.IsSvr) {
                    //    writer.writeStartElement("Relationship");
                    //    writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + imageCache.ImagePackedStore.count + 0));
                    //    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/footnotes");
                    //    writer.writeAttributeString("Target", "footnotes.xml");
                    //    writer.writeEndElement();
                    //    writer.writeStartElement("Relationship");
                    //    writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + imageCache.ImagePackedStore.count + 1));
                    //    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/endnotes");
                    //    writer.writeAttributeString("Target", "endnotes.xml");
                    //    writer.writeEndElement();
                    //    writer.writeStartElement("Relationship");
                    //    writer.writeAttributeString("Id", "rIdh1");
                    //    writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/header");
                    //    writer.writeAttributeString("Target", "headerAdditional.xml");
                    //    writer.writeEndElement();
                    // }
                    // #endif
                    if (this.hyperlinkList.count > 0) {
                        for (var _i = 0, _a = this.hyperlinkList.keys; _i < _a.length; _i++) {
                            var key = _a[_i];
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", StiString.format("hId{0}", Math.trunc(this.hyperlinkList.get(key))));
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink");
                            writer.writeAttributeString("Target", key);
                            writer.writeAttributeString("TargetMode", "External");
                            writer.writeEndElement();
                        }
                    }
                    if (this.embedsList.length > 0) {
                        for (var index = 0; index < this.embedsList.length; index++) {
                            writer.writeStartElement("Relationship");
                            writer.writeAttributeString("Id", StiString.format("reId{0}", 1 + index));
                            writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/aFChunk");
                            writer.writeAttributeString("Target", StiString.format("embeddings/richtext{0:D5}.rtf", index + 1));
                            writer.writeAttributeString("TargetMode", "Internal");
                            writer.writeEndElement();
                        }
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeHeaderFooterRels = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("Relationships");
                    writer.writeAttributeString("xmlns", "http://schemas.openxmlformats.org/package/2006/relationships");
                    for (var index = 0; index < this.imageCache.imagePackedStore.length; index++) {
                        writer.writeStartElement("Relationship");
                        writer.writeAttributeString("Id", StiString.format("rId{0}", 5 + index));
                        writer.writeAttributeString("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/image");
                        writer.writeAttributeString("Target", StiString.format("media/image{0:D5}.jpeg", index + 1));
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeStyles = function () {
                    var ms = new MemoryStream();
                    var writer = new XmlTextWriter(Encoding.UTF8, ms);
                    writer.indentation = (this.xmlIndentation < 0 ? 0 : this.xmlIndentation);
                    writer.formatting = (this.xmlIndentation < 0 ? Formatting.None : Formatting.Indented);
                    writer.writeStartDocument();
                    writer.writeStartElement("w:styles");
                    writer.writeAttributeString("xmlns:r", "http://schemas.openxmlformats.org/officeDocument/2006/relationships");
                    writer.writeAttributeString("xmlns:w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main");
                    writer.writeStartElement("w:style");
                    writer.writeAttributeString("w:type", "paragraph");
                    writer.writeAttributeString("w:default", "1");
                    writer.writeAttributeString("w:styleId", "a");
                    writer.writeStartElement("w:name");
                    writer.writeAttributeString("w:val", "Normal");
                    writer.writeEndElement();
                    writer.writeStartElement("w:qFormat");
                    writer.writeEndElement();
                    writer.writeStartElement("w:pPr");
                    writer.writeStartElement("w:spacing");
                    writer.writeAttributeString("w:after", "0");
                    writer.writeAttributeString("w:line", "240");
                    writer.writeAttributeString("w:lineRule", "auto");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:rPr");
                    writer.writeStartElement("w:sz");
                    writer.writeAttributeString("w:val", StiString.format("{0}", Math.round2(StiOptions.Export.Word.normalStyleDefaultFontSize * 2)));
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:style");
                    writer.writeAttributeString("w:type", "character");
                    writer.writeAttributeString("w:default", "1");
                    writer.writeAttributeString("w:styleId", "a0");
                    writer.writeStartElement("w:name");
                    writer.writeAttributeString("w:val", "Default Paragraph Font");
                    writer.writeEndElement();
                    writer.writeStartElement("w:uiPriority");
                    writer.writeAttributeString("w:val", "1");
                    writer.writeEndElement();
                    writer.writeStartElement("w:semiHidden");
                    writer.writeEndElement();
                    writer.writeStartElement("w:unhideWhenUsed");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:style");
                    writer.writeAttributeString("w:type", "table");
                    writer.writeAttributeString("w:default", "1");
                    writer.writeAttributeString("w:styleId", "a1");
                    writer.writeStartElement("w:name");
                    writer.writeAttributeString("w:val", "Normal Table");
                    writer.writeEndElement();
                    writer.writeStartElement("w:uiPriority");
                    writer.writeAttributeString("w:val", "99");
                    writer.writeEndElement();
                    writer.writeStartElement("w:semiHidden");
                    writer.writeEndElement();
                    writer.writeStartElement("w:unhideWhenUsed");
                    writer.writeEndElement();
                    writer.writeStartElement("w:qFormat");
                    writer.writeEndElement();
                    writer.writeStartElement("w:tblPr");
                    writer.writeStartElement("w:tblInd");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:tblCellMar");
                    writer.writeStartElement("w:top");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:left");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:bottom");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeStartElement("w:right");
                    writer.writeAttributeString("w:w", "0");
                    writer.writeAttributeString("w:type", "dxa");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeEndElement();
                    writer.writeStartElement("w:style");
                    writer.writeAttributeString("w:type", "numbering");
                    writer.writeAttributeString("w:default", "1");
                    writer.writeAttributeString("w:styleId", "a2");
                    writer.writeStartElement("w:name");
                    writer.writeAttributeString("w:val", "No List");
                    writer.writeEndElement();
                    writer.writeStartElement("w:uiPriority");
                    writer.writeAttributeString("w:val", "99");
                    writer.writeEndElement();
                    writer.writeStartElement("w:semiHidden");
                    writer.writeEndElement();
                    writer.writeStartElement("w:unhideWhenUsed");
                    writer.writeEndElement();
                    writer.writeEndElement();
                    for (var index = 0; index < this.styleList.length; index++) {
                        var style = this.styleList[index];
                        writer.writeStartElement("w:style");
                        writer.writeAttributeString("w:type", "paragraph");
                        writer.writeAttributeString("w:customStyle", "1");
                        writer.writeAttributeString("w:styleId", StiString.format("Style{0}", index));
                        writer.writeStartElement("w:name");
                        writer.writeAttributeString("w:val", style.name);
                        writer.writeEndElement();
                        writer.writeStartElement("w:basedOn");
                        writer.writeAttributeString("w:val", "a");
                        writer.writeEndElement();
                        writer.writeStartElement("w:rPr");
                        writer.writeStartElement("w:rFonts");
                        writer.writeAttributeString("w:ascii", style.fontName);
                        writer.writeAttributeString("w:hAnsi", style.fontName);
                        writer.writeAttributeString("w:cs", style.fontName);
                        writer.writeEndElement();
                        if (style.bold) {
                            writer.writeStartElement("w:b");
                            writer.writeEndElement();
                        }
                        if (style.italic) {
                            writer.writeStartElement("w:i");
                            writer.writeEndElement();
                        }
                        if (style.underline) {
                            writer.writeStartElement("w:u");
                            writer.writeAttributeString("w:val", "single");
                            writer.writeEndElement();
                        }
                        writer.writeStartElement("w:color");
                        writer.writeAttributeString("w:val", this.getColorString(style.textColor));
                        writer.writeEndElement();
                        writer.writeStartElement("w:sz");
                        writer.writeAttributeString("w:val", StiString.format("{0}", style.fontSize));
                        writer.writeEndElement();
                        if (StiOptions.Export.Word.spaceBetweenCharacters != 0) {
                            writer.writeStartElement("w:spacing");
                            writer.writeAttributeString("w:val", StiString.format("{0}", StiOptions.Export.Word.spaceBetweenCharacters));
                            writer.writeEndElement();
                        }
                        if (style.rightToLeft) {
                            if (style.bold) {
                                writer.writeStartElement("w:bCs");
                                writer.writeEndElement();
                            }
                            if (style.italic) {
                                writer.writeStartElement("w:iCs");
                                writer.writeEndElement();
                            }
                            writer.writeStartElement("w:szCs");
                            writer.writeAttributeString("w:val", StiString.format("{0}", style.fontSize));
                            writer.writeEndElement();
                            writer.writeStartElement("w:rtl");
                            writer.writeEndElement();
                        }
                        writer.writeEndElement();
                        writer.writeEndElement();
                    }
                    writer.writeFullEndElement();
                    writer.writeEndDocument();
                    writer.flush();
                    return ms;
                };
                StiWord2007ExportService.prototype.writeImage = function (_number) {
                    var ms = new MemoryStream();
                    var buf = this.imageCache.imagePackedStore[_number];
                    if (buf != null) {
                        ms.write(buf, 0, buf.length);
                    }
                    return ms;
                };
                /*private MemoryStream WriteEmbed(int number)
            {
                let ms: MemoryStream = new MemoryStream();
                StreamWriter sw = new StreamWriter(ms, Encoding.GetEncoding(1252));
        
                string st = (string)embedsList[number];
        
                string st2 = Stimulsoft.Report.Export.StiExportUtils.CorrectEncoding(st);
                if (st2 != null) st = st2;
        
                sw.write(st);
                sw.flush();
                return ms;
            }*/
                StiWord2007ExportService.prototype.writeAdditionalData = function (st, base64) {
                    var ms = new MemoryStream();
                    var bytes = null;
                    if (base64) {
                        bytes = Stimulsoft.System.Convert.fromBase64String(st);
                    }
                    else {
                        bytes = Encoding.ASCII.getBytes(st);
                    }
                    ms.write(bytes, 0, bytes.length);
                    return ms;
                };
                /*exportWord(report: StiReport, fileName: string)
            {
                FileStream stream = null;
                try {
                    StiFileUtils.ProcessReadOnly(fileName);
                    stream = new FileStream(fileName, FileMode.Create);
                    ExportWord(report, stream);
                }
                finally {
                    if (stream != null) {
                        stream.flush();
                        stream.Close();
                    }
                }
            }*/
                /*void ExportWord(StiReport report, Stream stream)
                {
                    StiWord2007ExportSettings settings = new StiWord2007ExportSettings();
        
                    ExportWord(report, stream, settings);
                }
        
                    /// <summary>
                    /// Exports rendered report to an Word file.
                    /// </summary>
                    /// <param name="report">A report which is to be exported.</param>
                    /// <param name="stream">A stream for export of a document.</param>
                    /// <param name="pageRange">Describes range of pages of the document for the export.</param>
                    void ExportWord(StiReport report, Stream stream, StiPagesRange pageRange)
                {
                    StiWord2007ExportSettings settings = new StiWord2007ExportSettings();
        
                    settings.PageRange = pageRange;
        
                    ExportWord(report, stream, settings);
                }
        
                    */
                StiWord2007ExportService.prototype.exportWord = function (report, stream, settings) {
                    // StiLogService.write(this.GetType(), "Export report to Word 2007 format");
                    // Read settings
                    if (settings == null)
                        throw new Error(("The 'settings' argument cannot be equal in null."));
                    var pageRange = settings.pageRange;
                    this.usePageHeadersAndFooters = settings.usePageHeadersAndFooters;
                    this._removeEmptySpaceAtBottom = settings.removeEmptySpaceAtBottom;
                    this.imageResolution = settings.imageResolution;
                    this.imageQuality = settings.imageQuality;
                    this.docCompanyString = settings.companyString;
                    this.docLastModifiedString = settings.lastModifiedString;
                    this.restrictEditing = settings.restrictEditing;
                    this.xmlIndentation = -1;
                    if (this.imageQuality < 0)
                        this.imageQuality = 0;
                    if (this.imageQuality > 1)
                        this.imageQuality = 1;
                    if (this.imageResolution < 10)
                        this.imageResolution = 10;
                    this.imageResolution = this.imageResolution / 100;
                    if (StiOptions.Export.Word.lineSpacing != 1) {
                        this.lineSpace = (Math.round2(StiOptions.Export.Word.lineSpacing * 240)).toString();
                        this.lineSpace2 = (Math.round2(StiOptions.Export.Word.lineSpacing * 0.772 * 240)).toString();
                    }
                    if (StiOptions.Export.Word.restrictEditing > this.restrictEditing) {
                        this.restrictEditing = StiOptions.Export.Word.restrictEditing;
                    }
                    this.report = report;
                    try {
                        // Stimulsoft.System.Threading.Thread.CurrentThread.CurrentCulture = new CultureInfo("en-US", false);
                        this.styleList = [];
                        this.fontList = new Hashtable();
                        this.imageCache = new Report.StiImageCache(StiOptions.Export.Word.allowImageComparer, true, Report.ImageFormat.Jpeg, this.imageQuality, false);
                        this.bookmarkList = new Hashtable();
                        this.hyperlinkList = new Hashtable();
                        this.embedsList = [];
                        this.currentPassNumber = 0;
                        this.maximumPassNumber = 3 + (StiOptions.Export.Word.divideSegmentPages ? 1 : 0);
                        var pages = pageRange.getSelectedPages(report.renderedPages);
                        if (StiOptions.Export.Word.divideSegmentPages) {
                            var needDivideSegments = true;
                            if (this.usePageHeadersAndFooters && (pages.count > 0) && pages.getByIndex(0).unlimitedHeight && (pages.getByIndex(0).segmentPerWidth == 1))
                                needDivideSegments = false;
                            if (needDivideSegments) {
                                pages = Export.StiSegmentPagesDivider.divide(pages, this);
                                this.currentPassNumber++;
                            }
                        }
                        // if (IsStoped) return;
                        // this.StatusString = StiLocalization.Get("Export", "ExportingCreatingDocument");
                        var zip = new StiZipWriter20();
                        zip.begin(stream, true);
                        if (this.usePageHeadersAndFooters) {
                            this.headersData = [];
                            this.headersRels = [];
                            this.footersData = [];
                            this.footersRels = [];
                        }
                        // write document
                        zip.addFile("word/document.xml", this.writeDocument(pages, report, this.usePageHeadersAndFooters), true);
                        // if (IsStoped) return;
                        if (this.usePageHeadersAndFooters) {
                            for (var index = 0; index < this.headersData.length; index++) {
                                zip.addFile(StiString.format("word/header{0}.xml", index + 1), this.headersData[index]);
                                if (this.headersRels[index] != null)
                                    zip.addFile(StiString.format("word/_rels/header{0}.xml.rels", index + 1), this.headersRels[index]);
                                zip.addFile(StiString.format("word/footer{0}.xml", index + 1), this.footersData[index]);
                                if (this.footersRels[index] != null)
                                    zip.addFile(StiString.format("word/_rels/footer{0}.xml.rels", index + 1), this.footersRels[index]);
                            }
                        }
                        if (this.usePageHeadersAndFooters) {
                            zip.addFile("word/footnotes.xml", this.writeFootNotes());
                            zip.addFile("word/endnotes.xml", this.writeEndNotes());
                        }
                        zip.addFile("[Content_Types].xml", this.writeContentTypes());
                        zip.addFile("_rels/.rels", this.writeMainRels());
                        zip.addFile("docProps/app.xml", this.writeDocPropsApp());
                        zip.addFile("docProps/core.xml", this.writeDocPropsCore());
                        zip.addFile("word/settings.xml", this.writeSettings());
                        zip.addFile("word/webSettings.xml", this.writeWebSettings());
                        zip.addFile("word/fontTable.xml", this.writeFontTable());
                        zip.addFile("word/_rels/document.xml.rels", this.writeDocumentRels());
                        zip.addFile("word/styles.xml", this.writeStyles());
                        if (this.imageCache.imagePackedStore.length > 0) {
                            for (var index = 0; index < this.imageCache.imagePackedStore.length; index++) {
                                zip.addFile(StiString.format("word/media/image{0:D5}.jpeg", index + 1), this.writeImage(index));
                            }
                        }
                        // if (embedsList.count > 0) {
                        //    for (let index: number = 0; index < embedsList.count; index++) {
                        //        zip.AddFile(StiString.format("word/embeddings/richtext{0:D5}.rtf", index + 1), WriteEmbed(index));
                        //    }
                        // }
                        // *#if Demo
                        if (!Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnJS() && !Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnDbsJS() && !this.usePageHeadersAndFooters &&
                            !(Stimulsoft.Base.Licenses.StiLicenseKeyValidator.isValidOnBI() && Stimulsoft.StiVersion.isStandaloneVersion())) {
                            zip.addFile("word/footnotes.xml", this.writeFootNotes());
                            zip.addFile("word/endnotes.xml", this.writeEndNotes());
                            zip.addFile("word/media/imageAdditional.png", this.writeAdditionalData(Export.StiExportUtils.additionalData, true));
                            zip.addFile("word/headerAdditional.xml", this.writeAdditionalData("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<w:hdr xmlns:ve=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" " +
                                "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\" xmlns:v=\"urn:schemas-microsoft-com:vml\" " +
                                "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:w10=\"urn:schemas-microsoft-com:office:word\" xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" " +
                                "xmlns:wne=\"http://schemas.microsoft.com/office/word/2006/wordml\"><w:p><w:pPr><w:pStyle w:val=\"a3\"/></w:pPr><w:r><w:rPr><w:noProof/><w:lang w:eastAsia=\"ru-RU\"/></w:rPr><w:pict>" +
                                "<v:shapetype id=\"_x0000_t75\" coordsize=\"21600,21600\" o:spt=\"75\" o:preferrelative=\"t\" path=\"m@4@5l@4@11@9@11@9@5xe\" filled=\"f\" stroked=\"f\"> <v:stroke joinstyle=\"miter\"/> <v:formulas>" +
                                "<v:f eqn=\"if lineDrawn pixelLineWidth 0\"/><v:f eqn=\"sum @0 1 0\"/><v:f eqn=\"sum 0 0 @1\"/><v:f eqn=\"prod @2 1 2\"/><v:f eqn=\"prod @3 21600 pixelWidth\"/><v:f eqn=\"prod @3 21600 pixelHeight\"/><v:f eqn=\"sum @0 0 1\"/>" +
                                "<v:f eqn=\"prod @6 1 2\"/><v:f eqn=\"prod @7 21600 pixelWidth\"/><v:f eqn=\"sum @8 21600 0\"/><v:f eqn=\"prod @7 21600 pixelHeight\"/><v:f eqn=\"sum @10 21600 0\"/></v:formulas><v:path o:extrusionok=\"f\" gradientshapeok=\"t\" o:connecttype=\"rect\"/>" +
                                "<o:lock v:ext=\"edit\" aspectratio=\"t\"/></v:shapetype><v:shape id=\"WordPictureWatermark11777093\" o:spid=\"_x0000_s2050\" type=\"#_x0000_t75\" " +
                                "style=\"position:absolute;margin-left:0;margin-top:0;width:467.45pt;height:433.85pt;z-index:-251657216;mso-position-horizontal:center;mso-position-horizontal-relative:margin;mso-position-vertical:center;mso-position-vertical-relative:margin\" " +
                                "o:allowincell=\"f\"><v:imagedata r:id=\"rId1\" o:title=\"additional\"/></v:shape></w:pict></w:r></w:p></w:hdr>", false));
                            zip.addFile("word/_rels/headerAdditional.xml.rels", this.writeAdditionalData("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/imageAdditional.png\" /></Relationships>", false));
                        }
                        // #endif Demo*/
                        // #if SERVER
                        //    if (!usePageHeadersAndFooters && StiVersionX.IsSvr) {
                        //        zip.AddFile("word/footnotes.xml", WriteFootNotes());
                        //        zip.AddFile("word/endnotes.xml", WriteEndNotes());
                        //        zip.AddFile("word/media/imageAdditional.png", WriteAdditionalData(StiExportUtils.AdditionalData, true));
                        //        zip.AddFile("word/headerAdditional.xml", WriteAdditionalData(
                        //            "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<w:hdr xmlns:ve=\"http://schemas.openxmlformats.org/markup-compatibility/2006\" xmlns:o=\"urn:schemas-microsoft-com:office:office\" " +
                        //            "xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\" xmlns:m=\"http://schemas.openxmlformats.org/officeDocument/2006/math\" xmlns:v=\"urn:schemas-microsoft-com:vml\" " +
                        //            "xmlns:wp=\"http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing\" xmlns:w10=\"urn:schemas-microsoft-com:office:word\" xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\" " +
                        //            "xmlns:wne=\"http://schemas.microsoft.com/office/word/2006/wordml\"><w:p><w:pPr><w:pStyle w:val=\"a3\"/></w:pPr><w:r><w:rPr><w:noProof/><w:lang w:eastAsia=\"ru-RU\"/></w:rPr><w:pict>" +
                        //            "<v:shapetype id=\"_x0000_t75\" coordsize=\"21600,21600\" o:spt=\"75\" o:preferrelative=\"t\" path=\"m@4@5l@4@11@9@11@9@5xe\" filled=\"f\" stroked=\"f\"> <v:stroke joinstyle=\"miter\"/> <v:formulas>" +
                        //            "<v:f eqn=\"if lineDrawn pixelLineWidth 0\"/><v:f eqn=\"sum @0 1 0\"/><v:f eqn=\"sum 0 0 @1\"/><v:f eqn=\"prod @2 1 2\"/><v:f eqn=\"prod @3 21600 pixelWidth\"/><v:f eqn=\"prod @3 21600 pixelHeight\"/><v:f eqn=\"sum @0 0 1\"/>" +
                        //            "<v:f eqn=\"prod @6 1 2\"/><v:f eqn=\"prod @7 21600 pixelWidth\"/><v:f eqn=\"sum @8 21600 0\"/><v:f eqn=\"prod @7 21600 pixelHeight\"/><v:f eqn=\"sum @10 21600 0\"/></v:formulas><v:path o:extrusionok=\"f\" gradientshapeok=\"t\" o:connecttype=\"rect\"/>" +
                        //            "<o:lock v:ext=\"edit\" aspectratio=\"t\"/></v:shapetype><v:shape id=\"WordPictureWatermark11777093\" o:spid=\"_x0000_s2050\" type=\"#_x0000_t75\" " +
                        //            "style=\"position:absolute;margin-left:0;margin-top:0;width:467.45pt;height:433.85pt;z-index:-251657216;mso-position-horizontal:center;mso-position-horizontal-relative:margin;mso-position-vertical:center;mso-position-vertical-relative:margin\" " +
                        //            "o:allowincell=\"f\"><v:imagedata r:id=\"rId1\" o:title=\"additional\"/></v:shape></w:pict></w:r></w:p></w:hdr>", false));
                        //        zip.AddFile("word/_rels/headerAdditional.xml.rels", WriteAdditionalData(
                        //            "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\r\n<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\"><Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/image\" Target=\"media/imageAdditional.png\" /></Relationships>", false));
                        //    }
                        // #endif
                        zip.end();
                    }
                    finally {
                        // StiExportUtils.EnableFontSmoothing(report);
                        // Stimulsoft.System.Threading.Thread.CurrentThread.CurrentCulture = currentCulture;
                        if (this.matrix != null) {
                            this.matrix.clear();
                            this._matrix = null;
                        }
                        this.fontList.clear();
                        this.fontList = null;
                        this.imageCache.clear();
                        this.imageCache = null;
                        this.styleList.clear();
                        this.styleList = null;
                        this.bookmarkList.clear();
                        this.bookmarkList = null;
                        this.hyperlinkList.clear();
                        this.hyperlinkList = null;
                        this.embedsList.clear();
                        this.embedsList = null;
                        if (this.usePageHeadersAndFooters) {
                            this.headersData.clear();
                            this.headersData = null;
                            this.headersRels.clear();
                            this.headersRels = null;
                            this.footersData.clear();
                            this.footersData = null;
                            this.footersRels.clear();
                            this.footersRels = null;
                        }
                        if (report.renderedPages.cacheMode)
                            Export.StiMatrix.GCCollect();
                    }
                };
                return StiWord2007ExportService;
            }(Export.StiExportService));
            Export.StiWord2007ExportService = StiWord2007ExportService;
        })(Export = Report.Export || (Report.Export = {}));
    })(Report = Stimulsoft.Report || (Stimulsoft.Report = {}));
})(Stimulsoft || (Stimulsoft = {}));
